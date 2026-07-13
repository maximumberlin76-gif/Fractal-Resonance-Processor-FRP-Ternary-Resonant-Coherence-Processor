// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Retained State Update Module
//
// Project:
//   Fractal Resonance Processor (FRP)
//   Ternary Fractal Resonant Coherence Processor
//
// Version:
//   FRP v1.8.0
//
// Milestone:
//   M16 — RTL Core Realization and Execution Semantics Package
//
// Preserved writeback contract:
//   - reset initializes retained state to active neutral 0;
//   - disabled ticks retain the complete state bank;
//   - state-changing writeback requires a qualified candidate and capacity;
//   - same-state retention consumes no capacity;
//   - opposite polarity commits only the legal first leg +/-1 -> 0;
//   - pending completion commits only on a later eligible tick from 0;
//   - capacity rejection defers without state or pending-route corruption;
//   - reserved encoding and direct -1 <-> +1 writeback are never committed.

`ifndef FRP_M16_STATE_UPDATE_SV
`define FRP_M16_STATE_UPDATE_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"

module frp_m16_state_update #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,
  input logic [(CELLS*STATE_BITS)-1:0] state_candidate_d,
  input logic [CELLS-1:0] capacity_accept_mask,
  input logic [CELLS-1:0] accepted_change_candidate_mask,
  input logic [CELLS-1:0] neutral_routed_mask,
  input logic [CELLS-1:0] pending_completion_mask,
  input logic [CELLS-1:0] reserved_transition_mask,
  input logic [CELLS-1:0] actual_direct_mask,
  output logic [(CELLS*STATE_BITS)-1:0] state_q,
  output logic [(CELLS*STATE_BITS)-1:0] state_d,
  output logic [(CELLS*STATE_BITS)-1:0] state_out,
  output logic [CELLS-1:0] state_write_enable_mask,
  output logic [CELLS-1:0] state_hold_mask,
  output logic [CELLS-1:0] state_reset_mask,
  output logic [CELLS-1:0] state_reserved_mask,
  output logic [COUNTER_BITS-1:0] accepted_changes,
  output logic [COUNTER_BITS-1:0] switch_load_numerator,
  output logic [COUNTER_BITS-1:0] state_write_events,
  output logic [COUNTER_BITS-1:0] state_hold_events,
  output logic [COUNTER_BITS-1:0] state_reset_events,
  output logic [COUNTER_BITS-1:0] accepted_change_events,
  output logic [COUNTER_BITS-1:0] neutral_routed_commit_events,
  output logic [COUNTER_BITS-1:0] pending_completion_commit_events,
  output logic [COUNTER_BITS-1:0] reserved_state_events,
  output logic [COUNTER_BITS-1:0] actual_direct_events,
  output logic state_domain_valid,
  output logic state_output_domain_valid,
  output logic state_update_valid,
  output logic state_write_capacity_valid,
  output logic same_state_hold_valid,
  output logic active_neutral_writeback_valid,
  output logic pending_completion_writeback_valid,
  output logic no_reserved_state_output,
  output logic no_actual_direct_events
);

  import frp_m16_pkg::*;

  localparam logic [COUNTER_BITS-1:0] COUNTER_ONE =
    {{(COUNTER_BITS-1){1'b0}}, 1'b1};

  localparam logic [COUNTER_BITS-1:0] REQUEST_LANE_LIMIT =
    REQUEST_LANES[COUNTER_BITS-1:0];

  logic [(CELLS*STATE_BITS)-1:0] state_next;
  logic writeback_contract_valid;

  function automatic logic [STATE_BITS-1:0] packed_state_value(
    input logic [(CELLS*STATE_BITS)-1:0] packed_state,
    input int element_index
  );
    begin
      packed_state_value =
        packed_state[(element_index*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [(CELLS*STATE_BITS)-1:0] set_packed_state_value(
    input logic [(CELLS*STATE_BITS)-1:0] packed_state,
    input int element_index,
    input logic [STATE_BITS-1:0] value
  );
    logic [(CELLS*STATE_BITS)-1:0] updated_state;

    begin
      updated_state = packed_state;

      updated_state[
        (element_index*STATE_BITS) +: STATE_BITS
      ] = value;

      set_packed_state_value = updated_state;
    end
  endfunction

  always_comb begin
    state_next = state_q;

    state_write_enable_mask = '0;
    state_hold_mask = '0;
    state_reset_mask = '0;
    state_reserved_mask = '0;

    accepted_changes = '0;
    switch_load_numerator = '0;

    state_write_events = '0;
    state_hold_events = '0;
    state_reset_events = '0;
    accepted_change_events = '0;
    neutral_routed_commit_events = '0;
    pending_completion_commit_events = '0;
    reserved_state_events = '0;
    actual_direct_events = '0;

    state_domain_valid = 1'b1;
    state_output_domain_valid = 1'b1;
    state_update_valid = 1'b1;
    state_write_capacity_valid = 1'b1;
    same_state_hold_valid = 1'b1;
    active_neutral_writeback_valid = 1'b1;
    pending_completion_writeback_valid = 1'b1;
    no_reserved_state_output = 1'b1;
    no_actual_direct_events = 1'b1;
    writeback_contract_valid = 1'b1;

    if (!rst_n) begin
      state_next = '0;
      state_reset_mask = '1;

      for (
        int element_index = 0;
        element_index < CELLS;
        element_index++
      ) begin
        state_reset_events =
          state_reset_events + COUNTER_ONE;
      end
    end else begin

      // First pass:
      // preserve retained state by default and admit only a complete,
      // scheduler-legal and capacity-approved transition contract.

      for (
        int element_index = 0;
        element_index < CELLS;
        element_index++
      ) begin
        logic [STATE_BITS-1:0] current_state;
        logic [STATE_BITS-1:0] candidate_state;

        logic current_valid;
        logic candidate_valid;
        logic state_changes;
        logic capacity_approved;
        logic candidate_qualified;
        logic neutral_routed;
        logic pending_completion;
        logic reserved_transition;
        logic direct_candidate;
        logic scheduler_valid;
        logic scheduler_commit_capable;
        logic scheduler_neutralize_capable;
        logic transition_scheduler_legal;
        logic transition_metadata_legal;
        logic commit_allowed;

        current_state =
          packed_state_value(
            state_q,
            element_index
          );

        candidate_state =
          packed_state_value(
            state_candidate_d,
            element_index
          );

        current_valid =
          frp_is_valid_ternary(current_state);

        candidate_valid =
          frp_is_valid_ternary(candidate_state);

        state_changes =
          (current_state != candidate_state);

        capacity_approved =
          capacity_accept_mask[element_index];

        candidate_qualified =
          accepted_change_candidate_mask[element_index];

        neutral_routed =
          neutral_routed_mask[element_index];

        pending_completion =
          pending_completion_mask[element_index];

        reserved_transition =
          reserved_transition_mask[element_index];

        direct_candidate =
          actual_direct_mask[element_index]
          || (
            current_valid
            && candidate_valid
            && frp_is_opposite_polarity(
              current_state,
              candidate_state
            )
          );

        scheduler_valid =
          frp_scheduler_state_is_valid(
            scheduler_state
          );

        scheduler_commit_capable =
          frp_scheduler_is_commit_capable(
            scheduler_state
          );

        scheduler_neutralize_capable =
          frp_scheduler_is_neutralize_capable(
            scheduler_state
          );

        transition_scheduler_legal = 1'b1;
        transition_metadata_legal = 1'b1;
        commit_allowed = 1'b0;

        if (
          !current_valid
          || !candidate_valid
          || reserved_transition
        ) begin
          state_reserved_mask[element_index] = 1'b1;

          reserved_state_events =
            reserved_state_events + COUNTER_ONE;

          state_domain_valid = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        // A direct candidate is blocked at the writeback boundary.
        // It is not counted as an actual direct event unless it reaches
        // the final retained state.

        if (direct_candidate) begin
          transition_metadata_legal = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        if (
          neutral_routed
          && pending_completion
        ) begin
          active_neutral_writeback_valid = 1'b0;
          pending_completion_writeback_valid = 1'b0;
          transition_metadata_legal = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        if (
          candidate_qualified
          && !state_changes
        ) begin
          same_state_hold_valid = 1'b0;
          transition_metadata_legal = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        if (state_changes) begin
          if (!candidate_qualified) begin
            state_write_capacity_valid = 1'b0;
            transition_metadata_legal = 1'b0;
            writeback_contract_valid = 1'b0;
          end

          if (neutral_routed) begin
            transition_scheduler_legal =
              scheduler_valid
              && scheduler_neutralize_capable;

            if (
              !frp_is_nonzero(current_state)
              || !frp_is_zero(candidate_state)
            ) begin
              active_neutral_writeback_valid = 1'b0;
              transition_metadata_legal = 1'b0;
              writeback_contract_valid = 1'b0;
            end
          end else if (pending_completion) begin
            transition_scheduler_legal =
              scheduler_valid
              && scheduler_commit_capable;

            if (
              !frp_is_zero(current_state)
              || !frp_is_nonzero(candidate_state)
            ) begin
              pending_completion_writeback_valid = 1'b0;
              transition_metadata_legal = 1'b0;
              writeback_contract_valid = 1'b0;
            end
          end else if (
            frp_is_zero(current_state)
            && frp_is_nonzero(candidate_state)
          ) begin
            transition_scheduler_legal =
              scheduler_valid
              && scheduler_commit_capable;
          end else if (
            frp_is_nonzero(current_state)
            && frp_is_zero(candidate_state)
          ) begin
            transition_scheduler_legal =
              scheduler_valid
              && scheduler_neutralize_capable;
          end else begin
            transition_scheduler_legal = 1'b0;
          end
        end

        if (!transition_scheduler_legal) begin
          if (neutral_routed) begin
            active_neutral_writeback_valid = 1'b0;
          end

          if (pending_completion) begin
            pending_completion_writeback_valid = 1'b0;
          end

          transition_metadata_legal = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        commit_allowed =
          tick_enable
          && current_valid
          && candidate_valid
          && state_changes
          && capacity_approved
          && candidate_qualified
          && !reserved_transition
          && !direct_candidate
          && transition_scheduler_legal
          && transition_metadata_legal;

        if (commit_allowed) begin
          state_next =
            set_packed_state_value(
              state_next,
              element_index,
              candidate_state
            );
        end
      end

      // Second pass:
      // derive write/hold masks and event sources from the actual
      // retained-state edge state_q -> state_d.

      for (
        int element_index = 0;
        element_index < CELLS;
        element_index++
      ) begin
        logic [STATE_BITS-1:0] current_state;
        logic [STATE_BITS-1:0] next_state;
        logic state_changed;
        logic final_direct_transition;

        current_state =
          packed_state_value(
            state_q,
            element_index
          );

        next_state =
          packed_state_value(
            state_next,
            element_index
          );

        state_changed =
          (current_state != next_state);

        final_direct_transition =
          frp_is_valid_ternary(current_state)
          && frp_is_valid_ternary(next_state)
          && frp_is_opposite_polarity(
            current_state,
            next_state
          );

        if (!frp_is_valid_ternary(next_state)) begin
          state_reserved_mask[element_index] = 1'b1;
          state_output_domain_valid = 1'b0;
          no_reserved_state_output = 1'b0;
        end

        if (final_direct_transition) begin
          actual_direct_events =
            actual_direct_events + COUNTER_ONE;

          no_actual_direct_events = 1'b0;
          writeback_contract_valid = 1'b0;
        end

        if (state_changed) begin
          state_write_enable_mask[element_index] = 1'b1;

          accepted_changes =
            accepted_changes + COUNTER_ONE;

          state_write_events =
            state_write_events + COUNTER_ONE;

          accepted_change_events =
            accepted_change_events + COUNTER_ONE;

          if (!capacity_accept_mask[element_index]) begin
            state_write_capacity_valid = 1'b0;
          end

          if (
            !accepted_change_candidate_mask[
              element_index
            ]
          ) begin
            state_write_capacity_valid = 1'b0;
          end

          if (neutral_routed_mask[element_index]) begin
            if (
              frp_is_nonzero(current_state)
              && frp_is_zero(next_state)
              && frp_scheduler_is_neutralize_capable(
                scheduler_state
              )
            ) begin
              neutral_routed_commit_events =
                neutral_routed_commit_events
                + COUNTER_ONE;
            end else begin
              active_neutral_writeback_valid = 1'b0;
            end
          end

          if (pending_completion_mask[element_index]) begin
            if (
              frp_is_zero(current_state)
              && frp_is_nonzero(next_state)
              && frp_scheduler_is_commit_capable(
                scheduler_state
              )
            ) begin
              pending_completion_commit_events =
                pending_completion_commit_events
                + COUNTER_ONE;
            end else begin
              pending_completion_writeback_valid = 1'b0;
            end
          end
        end else begin
          state_hold_mask[element_index] = 1'b1;

          state_hold_events =
            state_hold_events + COUNTER_ONE;
        end
      end
    end

    switch_load_numerator =
      accepted_changes;

    state_write_capacity_valid =
      state_write_capacity_valid
      && (
        accepted_changes
        <= REQUEST_LANE_LIMIT
      )
      && (
        (
          state_write_enable_mask
          & ~capacity_accept_mask
        )
        == '0
      )
      && (
        (
          state_write_enable_mask
          & ~accepted_change_candidate_mask
        )
        == '0
      );

    same_state_hold_valid =
      same_state_hold_valid
      && (
        (
          state_write_enable_mask
          & state_hold_mask
        )
        == '0
      )
      && (
        (
          state_write_enable_mask
          | state_hold_mask
          | state_reset_mask
        )
        == {CELLS{1'b1}}
      );

    state_domain_valid =
      state_domain_valid
      && state_output_domain_valid
      && no_reserved_state_output;

    state_update_valid =
      writeback_contract_valid
      && frp_scheduler_state_is_valid(
        scheduler_state
      )
      && state_domain_valid
      && state_write_capacity_valid
      && same_state_hold_valid
      && active_neutral_writeback_valid
      && pending_completion_writeback_valid
      && no_reserved_state_output
      && no_actual_direct_events;
  end

  assign state_d =
    state_next;

  assign state_out =
    state_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q <= '0;
    end else if (tick_enable) begin
      state_q <= state_d;
    end
  end

endmodule : frp_m16_state_update

`endif

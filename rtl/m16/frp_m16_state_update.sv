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
// Purpose:
//   Implements the M16 retained-state writeback layer.
//
// This module preserves the M15-qualified retained-state semantics:
//   - reset initializes retained state to active neutral 0
//   - tick-disabled cycles preserve retained state
//   - state-changing writeback requires capacity approval
//   - same-state retention does not consume transition capacity
//   - active-neutral routed writeback terminates in 0
//   - pending-route completion starts from 0
//   - reserved state 2'b10 is never emitted
//   - direct opposite-polarity writeback remains zero

`ifndef FRP_M16_STATE_UPDATE_SV
`define FRP_M16_STATE_UPDATE_SV

`include "frp_m16_pkg.sv"

module frp_m16_state_update #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic clk,
  input  logic rst_n,

  input  logic tick_enable,

  input  frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

  input  logic [(CELLS*STATE_BITS)-1:0] state_candidate_d,

  input  logic [CELLS-1:0] capacity_accept_mask,
  input  logic [CELLS-1:0] accepted_change_candidate_mask,
  input  logic [CELLS-1:0] neutral_routed_mask,
  input  logic [CELLS-1:0] pending_completion_mask,
  input  logic [CELLS-1:0] reserved_transition_mask,
  input  logic [CELLS-1:0] actual_direct_mask,

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

  // --------------------------------------------------------------------------
  // Local extraction helpers
  // --------------------------------------------------------------------------

  function automatic logic [STATE_BITS-1:0] cell_state_q(
    input int element_index
  );
    begin
      cell_state_q =
        state_q[(element_index*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_state_candidate_d(
    input int element_index
  );
    begin
      cell_state_candidate_d =
        state_candidate_d[(element_index*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_state_d(
    input int element_index
  );
    begin
      cell_state_d =
        state_d[(element_index*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  task automatic set_state_d(
    input int element_index,
    input logic [STATE_BITS-1:0] value
  );
    begin
      state_d[(element_index*STATE_BITS) +: STATE_BITS] = value;
    end
  endtask

  // --------------------------------------------------------------------------
  // Combinational state writeback logic
  // --------------------------------------------------------------------------

  always_comb begin
    state_d = state_q;

    state_write_enable_mask = '0;
    state_hold_mask         = '0;
    state_reset_mask        = '0;
    state_reserved_mask     = '0;

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

    // ----------------------------------------------------------------------
    // Tick-disabled cycles preserve retained state.
    // ----------------------------------------------------------------------

    if (!tick_enable) begin
      state_d = state_q;

      for (int element_index = 0; element_index < CELLS; element_index++) begin
        state_hold_mask[element_index] = 1'b1;

        state_hold_events =
          state_hold_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
      end
    end else begin

      // --------------------------------------------------------------------
      // Tick-enabled writeback.
      // --------------------------------------------------------------------

      for (int element_index = 0; element_index < CELLS; element_index++) begin
        logic [STATE_BITS-1:0] current_state;
        logic [STATE_BITS-1:0] candidate_state;
        logic                  candidate_valid;
        logic                  current_valid;
        logic                  state_changes;
        logic                  capacity_approved;

        current_state = cell_state_q(element_index);
        candidate_state = cell_state_candidate_d(element_index);

        current_valid = frp_is_valid_ternary(current_state);
        candidate_valid = frp_is_valid_ternary(candidate_state);

        state_changes = (current_state != candidate_state);

        capacity_approved = capacity_accept_mask[element_index];

        if (!current_valid) begin
          state_reserved_mask[element_index] = 1'b1;

          reserved_state_events =
            reserved_state_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          state_domain_valid = 1'b0;
          no_reserved_state_output = 1'b0;

          set_state_d(element_index, FRP_STATE_ZERO);

          state_write_enable_mask[element_index] = 1'b1;
          state_reset_mask[element_index] = 1'b1;

          state_reset_events =
            state_reset_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (!candidate_valid || reserved_transition_mask[element_index]) begin
          set_state_d(element_index, current_state);

          state_reserved_mask[element_index] = 1'b1;

          reserved_state_events =
            reserved_state_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          state_hold_mask[element_index] = 1'b1;

          state_hold_events =
            state_hold_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          state_output_domain_valid = 1'b0;
          no_reserved_state_output = 1'b0;
        end else if (actual_direct_mask[element_index]) begin
          set_state_d(element_index, current_state);

          actual_direct_events =
            actual_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          state_hold_mask[element_index] = 1'b1;

          state_hold_events =
            state_hold_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          no_actual_direct_events = 1'b0;
        end else if (!state_changes) begin
          set_state_d(element_index, current_state);

          state_hold_mask[element_index] = 1'b1;

          state_hold_events =
            state_hold_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (state_changes && capacity_approved) begin
          set_state_d(element_index, candidate_state);

          state_write_enable_mask[element_index] = 1'b1;

          accepted_changes =
            accepted_changes + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          state_write_events =
            state_write_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          accepted_change_events =
            accepted_change_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (neutral_routed_mask[element_index]) begin
            if (candidate_state == FRP_STATE_ZERO) begin
              neutral_routed_commit_events =
                neutral_routed_commit_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
            end else begin
              active_neutral_writeback_valid = 1'b0;
            end
          end

          if (pending_completion_mask[element_index]) begin
            if (current_state == FRP_STATE_ZERO) begin
              pending_completion_commit_events =
                pending_completion_commit_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
            end else begin
              pending_completion_writeback_valid = 1'b0;
            end
          end
        end else begin
          set_state_d(element_index, current_state);

          state_hold_mask[element_index] = 1'b1;

          state_hold_events =
            state_hold_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (accepted_change_candidate_mask[element_index]) begin
            state_write_capacity_valid = 1'b0;
          end
        end
      end
    end

    // ----------------------------------------------------------------------
    // Final output-domain and direct-transition scan.
    // ----------------------------------------------------------------------

    for (int element_index = 0; element_index < CELLS; element_index++) begin
      logic [STATE_BITS-1:0] current_state;
      logic [STATE_BITS-1:0] next_state;

      current_state = cell_state_q(element_index);
      next_state = cell_state_d(element_index);

      if (!frp_is_valid_ternary(next_state)) begin
        state_reserved_mask[element_index] = 1'b1;
        state_output_domain_valid = 1'b0;
        no_reserved_state_output = 1'b0;
      end

      if (
        frp_is_valid_ternary(current_state) &&
        frp_is_valid_ternary(next_state) &&
        frp_is_opposite_polarity(current_state, next_state)
      ) begin
        actual_direct_events =
          actual_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        no_actual_direct_events = 1'b0;
      end
    end

    switch_load_numerator = accepted_changes;

    if (accepted_changes > REQUEST_LANES[COUNTER_BITS-1:0]) begin
      state_write_capacity_valid = 1'b0;
    end

    same_state_hold_valid =
      same_state_hold_valid &&
      ((state_write_enable_mask & state_hold_mask) == '0);

    state_domain_valid =
      state_domain_valid &&
      state_output_domain_valid &&
      no_reserved_state_output;

    state_update_valid =
      state_domain_valid &&
      state_write_capacity_valid &&
      same_state_hold_valid &&
      active_neutral_writeback_valid &&
      pending_completion_writeback_valid &&
      no_reserved_state_output &&
      no_actual_direct_events;
  end

  // --------------------------------------------------------------------------
  // Sequential retained-state register
  // --------------------------------------------------------------------------

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q <= '0;
    end else if (tick_enable) begin
      state_q <= state_d;
    end
  end

  assign state_out = state_q;

endmodule : frp_m16_state_update

`endif

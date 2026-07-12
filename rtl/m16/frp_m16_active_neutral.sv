// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Active Neutral Transition Module
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
//   Implements the M16 active-neutral transition layer for legal
//   retained-state transition generation.
//
// This module preserves the M15-qualified transition semantics:
//   - same-state retention
//   - legal 0 -> +/-1 release
//   - legal +/-1 -> 0 neutralization
//   - forbidden direct -1 -> +1 transition
//   - forbidden direct +1 -> -1 transition
//   - mandatory active-neutral routing through 0
//   - pending-route completion only from state 0
//   - zero direct opposite-polarity execution

`ifndef FRP_M16_ACTIVE_NEUTRAL_SV
`define FRP_M16_ACTIVE_NEUTRAL_SV

`include "frp_m16_pkg.sv"

module frp_m16_active_neutral #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic tick_enable,

  input  frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

  input  logic [(CELLS*STATE_BITS)-1:0] state_q,
  input  logic [(CELLS*STATE_BITS)-1:0] pending_route_q,

  input  logic [REQUEST_LANES-1:0] request_accept,
  input  logic [REQUEST_LANES-1:0] request_neutralized,
  input  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index,
  input  logic [(REQUEST_LANES*STATE_BITS)-1:0]      request_target,

  input  logic [CELLS-1:0] pending_completion_enable,

  output logic [(CELLS*STATE_BITS)-1:0] state_candidate_d,

  output logic [CELLS-1:0] transition_valid_mask,
  output logic [CELLS-1:0] same_state_mask,
  output logic [CELLS-1:0] zero_to_nonzero_mask,
  output logic [CELLS-1:0] nonzero_to_zero_mask,
  output logic [CELLS-1:0] opposite_polarity_mask,
  output logic [CELLS-1:0] neutral_routed_mask,
  output logic [CELLS-1:0] pending_completion_mask,
  output logic [CELLS-1:0] actual_direct_mask,
  output logic [CELLS-1:0] reserved_transition_mask,
  output logic [CELLS-1:0] accepted_change_candidate_mask,

  output logic [COUNTER_BITS-1:0] same_state_events,
  output logic [COUNTER_BITS-1:0] zero_to_nonzero_events,
  output logic [COUNTER_BITS-1:0] nonzero_to_zero_events,
  output logic [COUNTER_BITS-1:0] requested_direct_events,
  output logic [COUNTER_BITS-1:0] prevented_direct_events,
  output logic [COUNTER_BITS-1:0] neutral_routed_events,
  output logic [COUNTER_BITS-1:0] pending_completion_events,
  output logic [COUNTER_BITS-1:0] actual_direct_events,
  output logic [COUNTER_BITS-1:0] reserved_transition_events,
  output logic [COUNTER_BITS-1:0] accepted_change_candidate_events,

  output logic transition_domain_valid,
  output logic active_neutral_routing_valid,
  output logic pending_completion_from_zero_valid,
  output logic no_reserved_transition,
  output logic no_actual_direct_events,
  output logic transition_capacity_valid,
  output logic state_output_domain_valid,
  output logic transition_replay_deterministic
);

  import frp_m16_pkg::*;

  // --------------------------------------------------------------------------
  // Local extraction helpers
  // --------------------------------------------------------------------------

  function automatic logic [CELL_INDEX_BITS-1:0] lane_cell_index(
    input int lane
  );
    begin
      lane_cell_index =
        request_cell_index[(lane*CELL_INDEX_BITS) +: CELL_INDEX_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] lane_target(
    input int lane
  );
    begin
      lane_target =
        request_target[(lane*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_state_q(
    input int cell
  );
    begin
      cell_state_q =
        state_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_pending_q(
    input int cell
  );
    begin
      cell_pending_q =
        pending_route_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_state_candidate_d(
    input int cell
  );
    begin
      cell_state_candidate_d =
        state_candidate_d[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  task automatic set_state_candidate_d(
    input int cell,
    input logic [STATE_BITS-1:0] value
  );
    begin
      state_candidate_d[(cell*STATE_BITS) +: STATE_BITS] = value;
    end
  endtask

  // --------------------------------------------------------------------------
  // Scheduler eligibility helpers
  // --------------------------------------------------------------------------

  function automatic logic scheduler_allows_zero_to_nonzero(
    input frp_m16_scheduler_state_e sched
  );
    begin
      scheduler_allows_zero_to_nonzero =
        frp_scheduler_is_commit_capable(sched);
    end
  endfunction

  function automatic logic scheduler_allows_nonzero_to_zero(
    input frp_m16_scheduler_state_e sched
  );
    begin
      scheduler_allows_nonzero_to_zero =
        frp_scheduler_is_neutralize_capable(sched);
    end
  endfunction

  function automatic logic scheduler_allows_pending_completion(
    input frp_m16_scheduler_state_e sched
  );
    begin
      scheduler_allows_pending_completion =
        frp_scheduler_is_commit_capable(sched);
    end
  endfunction

  // --------------------------------------------------------------------------
  // Active-neutral transition logic
  // --------------------------------------------------------------------------

  always_comb begin
    state_candidate_d = state_q;

    transition_valid_mask           = '0;
    same_state_mask                 = '0;
    zero_to_nonzero_mask            = '0;
    nonzero_to_zero_mask            = '0;
    opposite_polarity_mask          = '0;
    neutral_routed_mask             = '0;
    pending_completion_mask         = '0;
    actual_direct_mask              = '0;
    reserved_transition_mask        = '0;
    accepted_change_candidate_mask  = '0;

    same_state_events               = '0;
    zero_to_nonzero_events          = '0;
    nonzero_to_zero_events          = '0;
    requested_direct_events         = '0;
    prevented_direct_events         = '0;
    neutral_routed_events           = '0;
    pending_completion_events       = '0;
    actual_direct_events            = '0;
    reserved_transition_events      = '0;
    accepted_change_candidate_events = '0;

    transition_domain_valid              = 1'b1;
    active_neutral_routing_valid         = 1'b1;
    pending_completion_from_zero_valid   = 1'b1;
    no_reserved_transition               = 1'b1;
    no_actual_direct_events              = 1'b1;
    transition_capacity_valid            = 1'b1;
    state_output_domain_valid            = 1'b1;
    transition_replay_deterministic      = 1'b1;

    // ----------------------------------------------------------------------
    // Initial state-domain scan
    // ----------------------------------------------------------------------

    for (int cell = 0; cell < CELLS; cell++) begin
      logic [STATE_BITS-1:0] state_value;
      logic [STATE_BITS-1:0] pending_value;

      state_value   = cell_state_q(cell);
      pending_value = cell_pending_q(cell);

      if (
        !frp_is_valid_ternary(state_value) ||
        !frp_is_valid_ternary(pending_value)
      ) begin
        reserved_transition_mask[cell] = 1'b1;

        reserved_transition_events =
          reserved_transition_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        transition_domain_valid = 1'b0;
        no_reserved_transition  = 1'b0;
      end
    end

    // ----------------------------------------------------------------------
    // Pending-route completion has priority over new request transitions.
    // ----------------------------------------------------------------------

    if (tick_enable) begin
      for (int cell = 0; cell < CELLS; cell++) begin
        logic [STATE_BITS-1:0] state_value;
        logic [STATE_BITS-1:0] pending_value;

        state_value   = cell_state_q(cell);
        pending_value = cell_pending_q(cell);

        if (
          pending_completion_enable[cell] &&
          frp_is_valid_ternary(state_value) &&
          frp_is_valid_ternary(pending_value) &&
          frp_is_nonzero(pending_value)
        ) begin
          if (
            frp_is_zero(state_value) &&
            scheduler_allows_pending_completion(scheduler_state)
          ) begin
            set_state_candidate_d(cell, pending_value);

            transition_valid_mask[cell] = 1'b1;
            pending_completion_mask[cell] = 1'b1;
            zero_to_nonzero_mask[cell] = 1'b1;
            accepted_change_candidate_mask[cell] = 1'b1;

            pending_completion_events =
              pending_completion_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

            zero_to_nonzero_events =
              zero_to_nonzero_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

            accepted_change_candidate_events =
              accepted_change_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
          end else if (!frp_is_zero(state_value)) begin
            pending_completion_from_zero_valid = 1'b0;
          end
        end
      end
    end

    // ----------------------------------------------------------------------
    // Accepted request transitions.
    // Cells already completing pending routes are not overwritten.
    // ----------------------------------------------------------------------

    if (tick_enable) begin
      for (int lane = 0; lane < REQUEST_LANES; lane++) begin
        logic [CELL_INDEX_BITS-1:0] cell_index_value;
        int                         cell_index_int;
        logic [STATE_BITS-1:0]      state_value;
        logic [STATE_BITS-1:0]      target_value;
        logic                       valid_cell;
        logic                       valid_target;
        frp_m16_transition_class_e  transition_class;

        cell_index_value = lane_cell_index(lane);
        cell_index_int   = int'(cell_index_value);
        target_value     = lane_target(lane);

        valid_cell   = (cell_index_int < CELLS);
        valid_target = frp_is_valid_ternary(target_value);

        if (
          request_accept[lane] &&
          valid_cell &&
          valid_target &&
          !pending_completion_mask[cell_index_int]
        ) begin
          state_value =
            cell_state_q(cell_index_int);

          transition_class =
            frp_classify_transition(
              state_value,
              target_value,
              FRP_STATE_ZERO
            );

          unique case (transition_class)
            FRP_TRANS_SAME_STATE: begin
              set_state_candidate_d(cell_index_int, state_value);

              transition_valid_mask[cell_index_int] = 1'b1;
              same_state_mask[cell_index_int] = 1'b1;

              same_state_events =
                same_state_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
            end

            FRP_TRANS_ZERO_TO_NONZERO: begin
              if (scheduler_allows_zero_to_nonzero(scheduler_state)) begin
                set_state_candidate_d(cell_index_int, target_value);

                transition_valid_mask[cell_index_int] = 1'b1;
                zero_to_nonzero_mask[cell_index_int] = 1'b1;
                accepted_change_candidate_mask[cell_index_int] = 1'b1;

                zero_to_nonzero_events =
                  zero_to_nonzero_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

                accepted_change_candidate_events =
                  accepted_change_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
              end
            end

            FRP_TRANS_NONZERO_TO_ZERO: begin
              if (scheduler_allows_nonzero_to_zero(scheduler_state)) begin
                set_state_candidate_d(cell_index_int, FRP_STATE_ZERO);

                transition_valid_mask[cell_index_int] = 1'b1;
                nonzero_to_zero_mask[cell_index_int] = 1'b1;
                accepted_change_candidate_mask[cell_index_int] = 1'b1;

                nonzero_to_zero_events =
                  nonzero_to_zero_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

                accepted_change_candidate_events =
                  accepted_change_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
              end
            end

            FRP_TRANS_OPPOSITE_POLARITY: begin
              requested_direct_events =
                requested_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

              if (
                request_neutralized[lane] &&
                scheduler_allows_nonzero_to_zero(scheduler_state)
              ) begin
                set_state_candidate_d(cell_index_int, FRP_STATE_ZERO);

                transition_valid_mask[cell_index_int] = 1'b1;
                opposite_polarity_mask[cell_index_int] = 1'b1;
                neutral_routed_mask[cell_index_int] = 1'b1;
                nonzero_to_zero_mask[cell_index_int] = 1'b1;
                accepted_change_candidate_mask[cell_index_int] = 1'b1;

                prevented_direct_events =
                  prevented_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

                neutral_routed_events =
                  neutral_routed_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

                nonzero_to_zero_events =
                  nonzero_to_zero_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

                accepted_change_candidate_events =
                  accepted_change_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
              end else begin
                active_neutral_routing_valid = 1'b0;
              end
            end

            FRP_TRANS_RESERVED_OPERAND: begin
              reserved_transition_mask[cell_index_int] = 1'b1;

              reserved_transition_events =
                reserved_transition_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

              transition_domain_valid = 1'b0;
              no_reserved_transition  = 1'b0;
            end

            default: begin
              set_state_candidate_d(cell_index_int, state_value);
            end
          endcase
        end else if (
          request_accept[lane] &&
          (!valid_cell || !valid_target)
        ) begin
          transition_domain_valid = 1'b0;
          no_reserved_transition  = 1'b0;
        end
      end
    end

    // ----------------------------------------------------------------------
    // Direct-transition and output-domain scan.
    // ----------------------------------------------------------------------

    for (int cell = 0; cell < CELLS; cell++) begin
      logic [STATE_BITS-1:0] state_value;
      logic [STATE_BITS-1:0] next_value;

      state_value = cell_state_q(cell);
      next_value  = cell_state_candidate_d(cell);

      if (!frp_is_valid_ternary(next_value)) begin
        reserved_transition_mask[cell] = 1'b1;
        state_output_domain_valid = 1'b0;
        no_reserved_transition = 1'b0;
      end

      if (frp_is_opposite_polarity(state_value, next_value)) begin
        actual_direct_mask[cell] = 1'b1;

        actual_direct_events =
          actual_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        no_actual_direct_events = 1'b0;
      end
    end

    active_neutral_routing_valid =
      active_neutral_routing_valid &&
      (neutral_routed_events >= prevented_direct_events) &&
      (actual_direct_events == '0);

    transition_domain_valid =
      transition_domain_valid &&
      no_reserved_transition &&
      state_output_domain_valid;

    transition_capacity_valid = 1'b1;

    transition_replay_deterministic = 1'b1;
  end

endmodule : frp_m16_active_neutral

`endif

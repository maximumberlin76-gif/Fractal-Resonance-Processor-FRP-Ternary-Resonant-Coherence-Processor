// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Request-Lane Arbitration Module
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
//   Implements deterministic request-lane arbitration for the M16 RTL core.
//
// This module preserves the M15-qualified request semantics:
//   - deterministic ascending lane order
//   - valid cell-index checking
//   - valid ternary target checking
//   - duplicate-cell rejection
//   - scheduler eligibility gating
//   - pending-route priority protection
//   - active-neutral routing classification
//   - transition-capacity compatibility
//   - zero direct opposite-polarity execution

`ifndef FRP_M16_REQUEST_LANES_SV
`define FRP_M16_REQUEST_LANES_SV

`include "frp_m16_pkg.sv"

module frp_m16_request_lanes #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic tick_enable,

  input  frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

  input  logic [REQUEST_LANES-1:0] request_valid,
  input  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index,
  input  logic [(REQUEST_LANES*STATE_BITS)-1:0]      request_target,

  input  logic [(CELLS*STATE_BITS)-1:0] state_q,
  input  logic [(CELLS*STATE_BITS)-1:0] target_q,
  input  logic [(CELLS*STATE_BITS)-1:0] pending_route_q,

  output logic [REQUEST_LANES-1:0] request_accept,
  output logic [REQUEST_LANES-1:0] request_reject,

  output logic [REQUEST_LANES-1:0] request_reject_invalid_cell,
  output logic [REQUEST_LANES-1:0] request_reject_invalid_target,
  output logic [REQUEST_LANES-1:0] request_reject_duplicate_cell,
  output logic [REQUEST_LANES-1:0] request_reject_scheduler,
  output logic [REQUEST_LANES-1:0] request_reject_capacity,
  output logic [REQUEST_LANES-1:0] request_reject_pending_busy,
  output logic [REQUEST_LANES-1:0] request_reject_tick_disabled,

  output logic [REQUEST_LANES-1:0] request_neutralized,

  output logic [CELLS-1:0] accepted_cell_mask,
  output logic [CELLS-1:0] rejected_cell_mask,
  output logic [CELLS-1:0] neutral_routed_cell_mask,
  output logic [CELLS-1:0] requested_direct_cell_mask,

  output logic [COUNTER_BITS-1:0] accepted_changes,
  output logic [COUNTER_BITS-1:0] requested_lane_events,
  output logic [COUNTER_BITS-1:0] accepted_lane_events,
  output logic [COUNTER_BITS-1:0] rejected_lane_events,
  output logic [COUNTER_BITS-1:0] requested_direct_events,
  output logic [COUNTER_BITS-1:0] prevented_direct_events,
  output logic [COUNTER_BITS-1:0] neutral_routed_events,

  output logic request_lane_order_valid,
  output logic request_cell_domain_valid,
  output logic request_target_domain_valid,
  output logic duplicate_cell_guard_valid,
  output logic scheduler_gate_valid,
  output logic transition_capacity_valid,
  output logic active_neutral_routing_valid,
  output logic no_actual_direct_events,
  output logic no_queue_overflow
);

  import frp_m16_pkg::*;

  // --------------------------------------------------------------------------
  // Local helpers
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

  function automatic logic [STATE_BITS-1:0] cell_state(
    input int cell
  );
    begin
      cell_state =
        state_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_target_q(
    input int cell
  );
    begin
      cell_target_q =
        target_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] cell_pending(
    input int cell
  );
    begin
      cell_pending =
        pending_route_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic scheduler_allows_class(
    input frp_m16_scheduler_state_e sched,
    input frp_m16_transition_class_e trans_class
  );
    begin
      unique case (trans_class)
        FRP_TRANS_SAME_STATE: begin
          scheduler_allows_class = 1'b1;
        end

        FRP_TRANS_ZERO_TO_NONZERO: begin
          scheduler_allows_class = frp_scheduler_is_commit_capable(sched);
        end

        FRP_TRANS_NONZERO_TO_ZERO: begin
          scheduler_allows_class = frp_scheduler_is_neutralize_capable(sched);
        end

        FRP_TRANS_OPPOSITE_POLARITY: begin
          scheduler_allows_class = frp_scheduler_is_neutralize_capable(sched);
        end

        default: begin
          scheduler_allows_class = 1'b0;
        end
      endcase
    end
  endfunction

  // --------------------------------------------------------------------------
  // Arbitration logic
  // --------------------------------------------------------------------------

  always_comb begin
    request_accept              = '0;
    request_reject              = '0;

    request_reject_invalid_cell   = '0;
    request_reject_invalid_target = '0;
    request_reject_duplicate_cell = '0;
    request_reject_scheduler      = '0;
    request_reject_capacity       = '0;
    request_reject_pending_busy   = '0;
    request_reject_tick_disabled  = '0;

    request_neutralized = '0;

    accepted_cell_mask       = '0;
    rejected_cell_mask       = '0;
    neutral_routed_cell_mask = '0;
    requested_direct_cell_mask = '0;

    accepted_changes        = '0;
    requested_lane_events   = '0;
    accepted_lane_events    = '0;
    rejected_lane_events    = '0;
    requested_direct_events = '0;
    prevented_direct_events = '0;
    neutral_routed_events   = '0;

    request_lane_order_valid     = 1'b1;
    request_cell_domain_valid    = 1'b1;
    request_target_domain_valid  = 1'b1;
    duplicate_cell_guard_valid   = 1'b1;
    scheduler_gate_valid         = 1'b1;
    transition_capacity_valid    = 1'b1;
    active_neutral_routing_valid = 1'b1;
    no_actual_direct_events      = 1'b1;
    no_queue_overflow            = 1'b1;

    for (int lane = 0; lane < REQUEST_LANES; lane++) begin
      logic [CELL_INDEX_BITS-1:0] cell_index;
      logic [STATE_BITS-1:0]      target_value;
      logic [STATE_BITS-1:0]      state_value;
      logic [STATE_BITS-1:0]      pending_value;
      logic                       valid_cell;
      logic                       valid_target;
      logic                       duplicate_cell;
      logic                       pending_busy;
      logic                       state_changes;
      logic                       capacity_available;
      frp_m16_transition_class_e  transition_class;

      cell_index   = lane_cell_index(lane);
      target_value = lane_target(lane);

      valid_cell   = (cell_index < CELLS[CELL_INDEX_BITS-1:0]);
      valid_target = frp_is_valid_ternary(target_value);

      state_value   = FRP_STATE_ZERO;
      pending_value = FRP_STATE_ZERO;

      if (valid_cell) begin
        state_value   = cell_state(cell_index);
        pending_value = cell_pending(cell_index);
      end

      duplicate_cell = 1'b0;

      if (valid_cell) begin
        duplicate_cell = accepted_cell_mask[cell_index];
      end

      pending_busy =
        valid_cell &&
        (pending_value != FRP_STATE_ZERO);

      transition_class =
        frp_classify_transition(
          state_value,
          target_value,
          FRP_STATE_ZERO
        );

      state_changes =
        valid_cell &&
        valid_target &&
        (state_value != target_value);

      if (transition_class == FRP_TRANS_OPPOSITE_POLARITY) begin
        state_changes = 1'b1;
      end

      capacity_available =
        (accepted_changes < REQUEST_LANES[COUNTER_BITS-1:0]);

      if (request_valid[lane]) begin
        requested_lane_events =
          requested_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        if (!tick_enable) begin
          request_reject[lane] = 1'b1;
          request_reject_tick_disabled[lane] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (!valid_cell) begin
          request_reject[lane] = 1'b1;
          request_reject_invalid_cell[lane] = 1'b1;
          request_cell_domain_valid = 1'b0;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (!valid_target) begin
          request_reject[lane] = 1'b1;
          request_reject_invalid_target[lane] = 1'b1;
          request_target_domain_valid = 1'b0;
          rejected_cell_mask[cell_index] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (duplicate_cell) begin
          request_reject[lane] = 1'b1;
          request_reject_duplicate_cell[lane] = 1'b1;
          rejected_cell_mask[cell_index] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (pending_busy) begin
          request_reject[lane] = 1'b1;
          request_reject_pending_busy[lane] = 1'b1;
          rejected_cell_mask[cell_index] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (!scheduler_allows_class(scheduler_state, transition_class)) begin
          request_reject[lane] = 1'b1;
          request_reject_scheduler[lane] = 1'b1;
          rejected_cell_mask[cell_index] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (state_changes && !capacity_available) begin
          request_reject[lane] = 1'b1;
          request_reject_capacity[lane] = 1'b1;
          rejected_cell_mask[cell_index] = 1'b1;
          rejected_lane_events =
            rejected_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else begin
          request_accept[lane] = 1'b1;
          accepted_cell_mask[cell_index] = 1'b1;

          accepted_lane_events =
            accepted_lane_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (state_changes) begin
            accepted_changes =
              accepted_changes + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
          end

          if (transition_class == FRP_TRANS_OPPOSITE_POLARITY) begin
            request_neutralized[lane] = 1'b1;
            neutral_routed_cell_mask[cell_index] = 1'b1;
            requested_direct_cell_mask[cell_index] = 1'b1;

            requested_direct_events =
              requested_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

            prevented_direct_events =
              prevented_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

            neutral_routed_events =
              neutral_routed_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
          end
        end
      end
    end

    transition_capacity_valid =
      (accepted_changes <= REQUEST_LANES[COUNTER_BITS-1:0]);

    active_neutral_routing_valid =
      (neutral_routed_events >= prevented_direct_events);

    no_actual_direct_events = 1'b1;

    no_queue_overflow = 1'b1;
  end

endmodule : frp_m16_request_lanes

`endif

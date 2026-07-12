// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Pending-Route Register Module
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
//   Implements retained pending-route storage for active-neutral routed
//   opposite-polarity transitions.
//
// The module preserves the required M16 routing law:
//
//   -1 -> 0 -> +1
//   +1 -> 0 -> -1
//
// A direct opposite-polarity request is not committed directly.
// The current tick routes the retained state to active neutral 0.
// The requested opposite polarity is stored as a pending route.
// A later eligible tick completes the pending route from 0.

`ifndef FRP_M16_PENDING_ROUTES_SV
`define FRP_M16_PENDING_ROUTES_SV

`include "frp_m16_pkg.sv"

module frp_m16_pending_routes #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic clk,
  input  logic rst_n,

  input  logic tick_enable,

  input  logic [(CELLS*STATE_BITS)-1:0] state_q,

  input  logic [REQUEST_LANES-1:0] request_accept,
  input  logic [REQUEST_LANES-1:0] request_neutralized,
  input  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index,
  input  logic [(REQUEST_LANES*STATE_BITS)-1:0]      request_target,

  input  logic [CELLS-1:0] pending_completion_accept_mask,

  output logic [(CELLS*STATE_BITS)-1:0] pending_route_q,
  output logic [(CELLS*STATE_BITS)-1:0] pending_route_d,

  output logic [CELLS-1:0] pending_active_mask,
  output logic [CELLS-1:0] pending_created_mask,
  output logic [CELLS-1:0] pending_completed_mask,
  output logic [CELLS-1:0] pending_cleared_mask,
  output logic [CELLS-1:0] pending_retained_mask,
  output logic [CELLS-1:0] pending_blocked_mask,
  output logic [CELLS-1:0] pending_reserved_mask,
  output logic [CELLS-1:0] pending_overflow_mask,

  output logic [COUNTER_BITS-1:0] pending_active_count,
  output logic [COUNTER_BITS-1:0] pending_created_events,
  output logic [COUNTER_BITS-1:0] pending_completed_events,
  output logic [COUNTER_BITS-1:0] pending_cleared_events,
  output logic [COUNTER_BITS-1:0] pending_retained_events,
  output logic [COUNTER_BITS-1:0] pending_reserved_events,
  output logic [COUNTER_BITS-1:0] neutral_routed_events,
  output logic [COUNTER_BITS-1:0] prevented_direct_events,
  output logic [COUNTER_BITS-1:0] queue_overflow_events,
  output logic [COUNTER_BITS-1:0] actual_direct_events,

  output logic pending_domain_valid,
  output logic pending_polarity_valid,
  output logic pending_completion_from_zero_valid,
  output logic pending_non_overwrite_valid,
  output logic pending_capacity_valid,
  output logic pending_replay_deterministic,
  output logic no_pending_reserved_state,
  output logic no_queue_overflow,
  output logic no_actual_direct_events
);

  import frp_m16_pkg::*;

  function automatic logic [STATE_BITS-1:0] cell_state_value(
    input logic [(CELLS*STATE_BITS)-1:0] packed_state,
    input int cell
  );
    begin
      cell_state_value = packed_state[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] pending_q_value(
    input int cell
  );
    begin
      pending_q_value = pending_route_q[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] pending_d_value(
    input int cell
  );
    begin
      pending_d_value = pending_route_d[(cell*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  function automatic logic [CELL_INDEX_BITS-1:0] lane_cell_index_value(
    input int lane
  );
    begin
      lane_cell_index_value =
        request_cell_index[(lane*CELL_INDEX_BITS) +: CELL_INDEX_BITS];
    end
  endfunction

  function automatic logic [STATE_BITS-1:0] lane_target_value(
    input int lane
  );
    begin
      lane_target_value =
        request_target[(lane*STATE_BITS) +: STATE_BITS];
    end
  endfunction

  task automatic set_pending_d(
    input int cell,
    input logic [STATE_BITS-1:0] value
  );
    begin
      pending_route_d[(cell*STATE_BITS) +: STATE_BITS] = value;
    end
  endtask

  always_comb begin
    pending_route_d = pending_route_q;

    pending_active_mask = '0;
    pending_created_mask = '0;
    pending_completed_mask = '0;
    pending_cleared_mask = '0;
    pending_retained_mask = '0;
    pending_blocked_mask = '0;
    pending_reserved_mask = '0;
    pending_overflow_mask = '0;

    pending_active_count = '0;
    pending_created_events = '0;
    pending_completed_events = '0;
    pending_cleared_events = '0;
    pending_retained_events = '0;
    pending_reserved_events = '0;
    neutral_routed_events = '0;
    prevented_direct_events = '0;
    queue_overflow_events = '0;
    actual_direct_events = '0;

    pending_domain_valid = 1'b1;
    pending_polarity_valid = 1'b1;
    pending_completion_from_zero_valid = 1'b1;
    pending_non_overwrite_valid = 1'b1;
    pending_capacity_valid = 1'b1;
    pending_replay_deterministic = 1'b1;
    no_pending_reserved_state = 1'b1;
    no_queue_overflow = 1'b1;
    no_actual_direct_events = 1'b1;

    for (int cell = 0; cell < CELLS; cell++) begin
      logic [STATE_BITS-1:0] pending_value;
      logic [STATE_BITS-1:0] retained_state;

      pending_value = pending_q_value(cell);
      retained_state = cell_state_value(state_q, cell);

      if (!frp_is_valid_ternary(pending_value)) begin
        pending_reserved_mask[cell] = 1'b1;
        pending_reserved_events =
          pending_reserved_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        pending_domain_valid = 1'b0;
        no_pending_reserved_state = 1'b0;

        set_pending_d(cell, FRP_STATE_ZERO);
      end else if (frp_is_nonzero(pending_value)) begin
        pending_active_mask[cell] = 1'b1;

        if (tick_enable && pending_completion_accept_mask[cell]) begin
          if (!frp_is_zero(retained_state)) begin
            pending_completion_from_zero_valid = 1'b0;
          end

          set_pending_d(cell, FRP_STATE_ZERO);

          pending_completed_mask[cell] = 1'b1;
          pending_cleared_mask[cell] = 1'b1;

          pending_completed_events =
            pending_completed_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          pending_cleared_events =
            pending_cleared_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else begin
          pending_retained_mask[cell] = 1'b1;

          pending_retained_events =
            pending_retained_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end
      end
    end

    if (tick_enable) begin
      for (int lane = 0; lane < REQUEST_LANES; lane++) begin
        logic [CELL_INDEX_BITS-1:0] cell_index_value;
        int                         cell_index_int;
        logic [STATE_BITS-1:0]      target_value;
        logic [STATE_BITS-1:0]      existing_pending;

        cell_index_value = lane_cell_index_value(lane);
        cell_index_int = int'(cell_index_value);
        target_value = lane_target_value(lane);

        if (request_accept[lane] && request_neutralized[lane]) begin
          prevented_direct_events =
            prevented_direct_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          neutral_routed_events =
            neutral_routed_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (cell_index_int < CELLS) begin
            existing_pending = pending_q_value(cell_index_int);

            if (!frp_is_valid_ternary(target_value)) begin
              pending_reserved_mask[cell_index_int] = 1'b1;
              pending_polarity_valid = 1'b0;
              pending_domain_valid = 1'b0;
              no_pending_reserved_state = 1'b0;
            end else if (!frp_is_nonzero(target_value)) begin
              pending_polarity_valid = 1'b0;
            end else if (
              frp_is_nonzero(existing_pending) &&
              !pending_completion_accept_mask[cell_index_int]
            ) begin
              pending_blocked_mask[cell_index_int] = 1'b1;
              pending_overflow_mask[cell_index_int] = 1'b1;

              queue_overflow_events =
                queue_overflow_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

              pending_non_overwrite_valid = 1'b0;
              no_queue_overflow = 1'b0;
            end else begin
              set_pending_d(cell_index_int, target_value);

              pending_created_mask[cell_index_int] = 1'b1;

              pending_created_events =
                pending_created_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
            end
          end
        end
      end
    end

    for (int cell = 0; cell < CELLS; cell++) begin
      logic [STATE_BITS-1:0] pending_next;

      pending_next = pending_d_value(cell);

      if (!frp_is_valid_ternary(pending_next)) begin
        pending_reserved_mask[cell] = 1'b1;
        pending_domain_valid = 1'b0;
        no_pending_reserved_state = 1'b0;
      end

      if (frp_is_nonzero(pending_next)) begin
        pending_active_count =
          pending_active_count + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
      end
    end

    if (queue_overflow_events != '0) begin
      no_queue_overflow = 1'b0;
      pending_capacity_valid = 1'b0;
    end

    if (actual_direct_events != '0) begin
      no_actual_direct_events = 1'b0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pending_route_q <= '0;
    end else if (tick_enable) begin
      pending_route_q <= pending_route_d;
    end
  end

endmodule : frp_m16_pending_routes

`endif

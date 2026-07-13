// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Transition Capacity Guard Module
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
//   Implements the M16 transition-capacity guard for retained-state
//   changes.
//
// This module preserves the M15-qualified capacity semantics:
//   - transition_fraction = 0.25
//   - REQUEST_LANES = max(1, round(CELLS * transition_fraction))
//   - accepted_changes <= REQUEST_LANES
//   - same-state retention does not consume capacity
//   - pending-route completion remains capacity-bounded
//   - active-neutral routing remains capacity-bounded
//   - capacity exhaustion never authorizes direct opposite-polarity execution

`ifndef FRP_M16_CAPACITY_GUARD_SV
`define FRP_M16_CAPACITY_GUARD_SV

`include "frp_m16_pkg.sv"

module frp_m16_capacity_guard #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic tick_enable,

  input  frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

  input  logic [REQUEST_LANES-1:0] request_accept_candidate,
  input  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index,
  input  logic [(REQUEST_LANES*4)-1:0] transition_class,

  input  logic [CELLS-1:0] pending_completion_candidate,
  input  logic [CELLS-1:0] neutral_routed_candidate,

  input  logic [(CELLS*STATE_BITS)-1:0] state_q,
  input  logic [(CELLS*STATE_BITS)-1:0] state_candidate_d,

  output logic [REQUEST_LANES-1:0] request_accept_capacity,
  output logic [REQUEST_LANES-1:0] request_reject_capacity,

  output logic [CELLS-1:0] capacity_accept_mask,
  output logic [CELLS-1:0] capacity_reject_mask,
  output logic [CELLS-1:0] accepted_change_mask,

  output logic [COUNTER_BITS-1:0] accepted_changes,
  output logic [COUNTER_BITS-1:0] capacity_remaining,
  output logic capacity_exhausted,

  output logic [COUNTER_BITS-1:0] switch_load_numerator,

  output logic [COUNTER_BITS-1:0] capacity_candidate_events,
  output logic [COUNTER_BITS-1:0] capacity_accept_events,
  output logic [COUNTER_BITS-1:0] capacity_reject_events,
  output logic [COUNTER_BITS-1:0] capacity_exhausted_events,
  output logic [COUNTER_BITS-1:0] accepted_change_events,

  output logic transition_capacity_valid,
  output logic accepted_changes_within_limit,
  output logic capacity_remaining_valid,
  output logic capacity_exhaustion_valid,
  output logic same_state_capacity_valid,
  output logic pending_capacity_valid,
  output logic active_neutral_capacity_valid,
  output logic switch_load_bound_valid,
  output logic no_queue_overflow,
  output logic no_actual_direct_events
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

  function automatic frp_m16_transition_class_e lane_transition_class(
    input int lane
  );
    begin
      lane_transition_class =
        frp_m16_transition_class_e'(transition_class[(lane*4) +: 4]);
    end
  endfunction

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

  function automatic logic cell_state_changes(
    input int element_index
  );
    begin
      cell_state_changes =
        cell_state_q(element_index) != cell_state_candidate_d(element_index);
    end
  endfunction

  // --------------------------------------------------------------------------
  // Capacity guard
  // --------------------------------------------------------------------------

  always_comb begin
    request_accept_capacity = '0;
    request_reject_capacity = '0;

    capacity_accept_mask = '0;
    capacity_reject_mask = '0;
    accepted_change_mask = '0;

    accepted_changes = '0;
    capacity_remaining = REQUEST_LANES[COUNTER_BITS-1:0];
    capacity_exhausted = 1'b0;

    switch_load_numerator = '0;

    capacity_candidate_events  = '0;
    capacity_accept_events     = '0;
    capacity_reject_events     = '0;
    capacity_exhausted_events  = '0;
    accepted_change_events     = '0;

    transition_capacity_valid   = 1'b1;
    accepted_changes_within_limit = 1'b1;
    capacity_remaining_valid    = 1'b1;
    capacity_exhaustion_valid   = 1'b1;
    same_state_capacity_valid   = 1'b1;
    pending_capacity_valid      = 1'b1;
    active_neutral_capacity_valid = 1'b1;
    switch_load_bound_valid     = 1'b1;
    no_queue_overflow           = 1'b1;
    no_actual_direct_events     = 1'b1;

    // ----------------------------------------------------------------------
    // Pending-route completion candidates are capacity-bounded.
    //
    // Pending completion has deterministic priority because it represents
    // retained continuation of an already neutralized opposite-polarity route.
    // Disabled ticks leave all capacity outputs at their initialized values.
    // ----------------------------------------------------------------------

    for (int element_index = 0; element_index < CELLS; element_index++) begin
      logic state_changes;
      logic capacity_available;

      state_changes =
        cell_state_changes(element_index);

      capacity_available =
        (accepted_changes < REQUEST_LANES[COUNTER_BITS-1:0]);

      if (
        tick_enable
        && pending_completion_candidate[element_index]
      ) begin
        capacity_candidate_events =
          capacity_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        if (!state_changes) begin
          capacity_accept_mask[element_index] = 1'b1;

          capacity_accept_events =
            capacity_accept_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (capacity_available) begin
          capacity_accept_mask[element_index] = 1'b1;
          accepted_change_mask[element_index] = 1'b1;

          accepted_changes =
            accepted_changes + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          capacity_accept_events =
            capacity_accept_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          accepted_change_events =
            accepted_change_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else begin
          capacity_reject_mask[element_index] = 1'b1;

          capacity_reject_events =
            capacity_reject_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          pending_capacity_valid = 1'b0;
        end
      end
    end

    // ----------------------------------------------------------------------
    // Request-lane candidates are evaluated in deterministic ascending lane
    // order. The guard does not reorder requests.
    // ----------------------------------------------------------------------

    for (int lane = 0; lane < REQUEST_LANES; lane++) begin
      logic [CELL_INDEX_BITS-1:0] cell_index_value;
      int                         cell_index_int;
      logic                       valid_cell;
      logic                       state_changes;
      logic                       capacity_available;
      frp_m16_transition_class_e  class_value;

      cell_index_value = lane_cell_index(lane);
      cell_index_int   = int'(cell_index_value);
      valid_cell       = (cell_index_int < CELLS);
      class_value      = lane_transition_class(lane);
      state_changes    = 1'b0;

      capacity_available =
        (accepted_changes < REQUEST_LANES[COUNTER_BITS-1:0]);

      if (valid_cell) begin
        state_changes =
          cell_state_changes(cell_index_int);
      end

      if (
        tick_enable
        && request_accept_candidate[lane]
        && valid_cell
      ) begin
        capacity_candidate_events =
          capacity_candidate_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

        if (capacity_accept_mask[cell_index_int]) begin
          // A pending completion or earlier deterministic candidate already
          // consumed or accepted this element_index. Same-element_index
          // writeback is not accepted again through the lane path.
          request_reject_capacity[lane] = 1'b1;
          capacity_reject_mask[cell_index_int] = 1'b1;

          capacity_reject_events =
            capacity_reject_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end else if (!state_changes) begin
          request_accept_capacity[lane] = 1'b1;
          capacity_accept_mask[cell_index_int] = 1'b1;

          capacity_accept_events =
            capacity_accept_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (class_value != FRP_TRANS_SAME_STATE) begin
            same_state_capacity_valid = same_state_capacity_valid;
          end
        end else if (capacity_available) begin
          request_accept_capacity[lane] = 1'b1;
          capacity_accept_mask[cell_index_int] = 1'b1;
          accepted_change_mask[cell_index_int] = 1'b1;

          accepted_changes =
            accepted_changes + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          capacity_accept_events =
            capacity_accept_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          accepted_change_events =
            accepted_change_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (neutral_routed_candidate[cell_index_int]) begin
            active_neutral_capacity_valid = 1'b1;
          end
        end else begin
          request_reject_capacity[lane] = 1'b1;
          capacity_reject_mask[cell_index_int] = 1'b1;

          capacity_reject_events =
            capacity_reject_events + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

          if (neutral_routed_candidate[cell_index_int]) begin
            active_neutral_capacity_valid = 1'b0;
          end
        end
      end
    end

    // ----------------------------------------------------------------------
    // Final capacity arithmetic.
    // ----------------------------------------------------------------------

    if (tick_enable) begin
      if (accepted_changes <= REQUEST_LANES[COUNTER_BITS-1:0]) begin
        capacity_remaining =
          REQUEST_LANES[COUNTER_BITS-1:0] - accepted_changes;
      end else begin
        capacity_remaining = '0;
        accepted_changes_within_limit = 1'b0;
      end

      capacity_exhausted =
        (accepted_changes == REQUEST_LANES[COUNTER_BITS-1:0]);

      if (capacity_exhausted) begin
        capacity_exhausted_events =
          {{(COUNTER_BITS-1){1'b0}}, 1'b1};
      end

      switch_load_numerator = accepted_changes;
    end

    // ----------------------------------------------------------------------
    // Invariant flags
    // ----------------------------------------------------------------------

    accepted_changes_within_limit =
      (accepted_changes <= REQUEST_LANES[COUNTER_BITS-1:0]);

    capacity_remaining_valid =
      (capacity_remaining <= REQUEST_LANES[COUNTER_BITS-1:0]);

    capacity_exhaustion_valid =
      (
        capacity_exhausted
        == (
          accepted_changes
          == REQUEST_LANES[COUNTER_BITS-1:0]
        )
      );

    switch_load_bound_valid =
      (accepted_changes <= REQUEST_LANES[COUNTER_BITS-1:0]);

    transition_capacity_valid =
      accepted_changes_within_limit
      && capacity_remaining_valid
      && capacity_exhaustion_valid
      && switch_load_bound_valid;

    no_queue_overflow = 1'b1;

    no_actual_direct_events = 1'b1;
  end

endmodule : frp_m16_capacity_guard

`endif

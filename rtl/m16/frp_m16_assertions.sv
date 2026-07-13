// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Assertion Binding Layer
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
//   Defines the M16 RTL assertion layer for the integrated core boundary.
//
// This module preserves the M15-qualified invariant set:
//   - canonical balanced ternary state domain
//   - zero reserved-state output
//   - zero direct opposite-polarity execution
//   - zero queue-overflow qualification target
//   - scheduler counter consistency
//   - request-lane acceptance/rejection separation
//   - transition-capacity boundary
//   - active-neutral routing invariant flags
//   - pending-route polarity invariant flags

`ifndef FRP_M16_ASSERTIONS_SV
`define FRP_M16_ASSERTIONS_SV

`include "frp_m16_pkg.sv"

module frp_m16_assertions #(
  parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
  parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
  parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input logic clk,
  input logic rst_n,

  input logic tick_enable,

  input frp_m16_pkg::frp_m16_scheduler_mode_e  scheduler_mode_q,
  input frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state_q,

  input logic [COUNTER_BITS-1:0] ticks_recorded_q,

  input logic [COUNTER_BITS-1:0] scheduler_count_free_q,
  input logic [COUNTER_BITS-1:0] scheduler_count_balance_q,
  input logic [COUNTER_BITS-1:0] scheduler_count_commit_q,
  input logic [COUNTER_BITS-1:0] scheduler_count_excite_q,
  input logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q,

  input logic [(CELLS*STATE_BITS)-1:0] state_out,
  input logic [(CELLS*STATE_BITS)-1:0] pending_route_out,

  input logic [REQUEST_LANES-1:0] request_accept,
  input logic [REQUEST_LANES-1:0] request_reject,

  input logic [CELLS-1:0] accepted_cell_mask,
  input logic [CELLS-1:0] neutral_routed_cell_mask,
  input logic [CELLS-1:0] accepted_change_mask,

  input logic [COUNTER_BITS-1:0] accepted_changes,
  input logic [COUNTER_BITS-1:0] capacity_remaining,
  input logic capacity_exhausted,
  input logic [COUNTER_BITS-1:0] switch_load_numerator,

  input logic [COUNTER_BITS-1:0] requested_direct_events,
  input logic [COUNTER_BITS-1:0] prevented_direct_events,
  input logic [COUNTER_BITS-1:0] neutral_routed_events,
  input logic [COUNTER_BITS-1:0] actual_direct_events,
  input logic [COUNTER_BITS-1:0] reserved_state_events,
  input logic [COUNTER_BITS-1:0] queue_overflow_events,

  input logic [frp_m16_pkg::FRP_M16_INVARIANT_FLAGS-1:0] invariant_flags
);

  import frp_m16_pkg::*;

  logic [COUNTER_BITS-1:0] scheduler_count_sum;

  assign scheduler_count_sum =
    scheduler_count_free_q +
    scheduler_count_balance_q +
    scheduler_count_commit_q +
    scheduler_count_excite_q +
    scheduler_count_neutralize_q;

  // --------------------------------------------------------------------------
  // Default assertion clock
  // --------------------------------------------------------------------------

  default clocking frp_m16_assertion_clock @(posedge clk);
  endclocking

  // --------------------------------------------------------------------------
  // State-domain assertions
  // --------------------------------------------------------------------------

  genvar state_cell;

  generate
    for (
      state_cell = 0;
      state_cell < CELLS;
      state_cell++
    ) begin : g_state_domain_assertions

      localparam int LSB = state_cell * STATE_BITS;

      assert property (
        disable iff (!rst_n)
        frp_is_valid_ternary(
          state_out[LSB +: STATE_BITS]
        )
      ) else $error(
        "FRP M16 assertion failed: state_out contains reserved ternary encoding"
      );

      assert property (
        disable iff (!rst_n)
        frp_is_valid_ternary(
          pending_route_out[LSB +: STATE_BITS]
        )
      ) else $error(
        "FRP M16 assertion failed: pending_route_out contains reserved ternary encoding"
      );

    end
  endgenerate

  // --------------------------------------------------------------------------
  // Scheduler assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    frp_is_valid_scheduler_mode(scheduler_mode_q)
  ) else $error(
    "FRP M16 assertion failed: invalid scheduler mode"
  );

  assert property (
    disable iff (!rst_n)
    frp_scheduler_state_is_valid(scheduler_state_q)
  ) else $error(
    "FRP M16 assertion failed: invalid scheduler state"
  );

  assert property (
    disable iff (!rst_n)
    scheduler_count_sum == ticks_recorded_q
  ) else $error(
    "FRP M16 assertion failed: scheduler counters do not sum to ticks_recorded"
  );

  assert property (
    disable iff (!rst_n)
    (scheduler_mode_q == FRP_MODE_FREE)
    |->
    (scheduler_state_q == FRP_SCHED_FREE)
  ) else $error(
    "FRP M16 assertion failed: free mode emitted non-free scheduler state"
  );

  assert property (
    disable iff (!rst_n)
    (scheduler_mode_q == FRP_MODE_7_1)
    |->
    (
      (scheduler_state_q == FRP_SCHED_BALANCE)
      || (scheduler_state_q == FRP_SCHED_COMMIT)
    )
  ) else $error(
    "FRP M16 assertion failed: 7/1 mode emitted invalid scheduler state"
  );

  assert property (
    disable iff (!rst_n)
    (scheduler_mode_q == FRP_MODE_1_7)
    |->
    (
      (scheduler_state_q == FRP_SCHED_EXCITE)
      || (scheduler_state_q == FRP_SCHED_NEUTRALIZE)
    )
  ) else $error(
    "FRP M16 assertion failed: 1/7 mode emitted invalid scheduler state"
  );

  // --------------------------------------------------------------------------
  // Request-lane assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    (request_accept & request_reject) == '0
  ) else $error(
    "FRP M16 assertion failed: request lane accepted and rejected simultaneously"
  );

  assert property (
    disable iff (!rst_n)
    $countones(accepted_cell_mask) <= REQUEST_LANES
  ) else $error(
    "FRP M16 assertion failed: accepted_cell_mask exceeds REQUEST_LANES"
  );

  assert property (
    disable iff (!rst_n)
    $countones(accepted_change_mask) <= REQUEST_LANES
  ) else $error(
    "FRP M16 assertion failed: accepted_change_mask exceeds REQUEST_LANES"
  );

  assert property (
    disable iff (!rst_n)
    accepted_changes <= REQUEST_LANES
  ) else $error(
    "FRP M16 assertion failed: accepted_changes exceeds REQUEST_LANES"
  );

  // --------------------------------------------------------------------------
  // Transition-capacity assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    capacity_remaining <= REQUEST_LANES
  ) else $error(
    "FRP M16 assertion failed: capacity_remaining exceeds REQUEST_LANES"
  );

  assert property (
    disable iff (!rst_n)
    capacity_remaining
    == (REQUEST_LANES - accepted_changes)
  ) else $error(
    "FRP M16 assertion failed: capacity_remaining mismatch"
  );

  assert property (
    disable iff (!rst_n)
    capacity_exhausted
    == (accepted_changes == REQUEST_LANES)
  ) else $error(
    "FRP M16 assertion failed: capacity_exhausted relation mismatch"
  );

  assert property (
    disable iff (!rst_n)
    switch_load_numerator == accepted_changes
  ) else $error(
    "FRP M16 assertion failed: switch_load_numerator must equal accepted_changes"
  );

  // --------------------------------------------------------------------------
  // Event-counter assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    actual_direct_events == '0
  ) else $error(
    "FRP M16 assertion failed: actual_direct_events must remain zero"
  );

  assert property (
    disable iff (!rst_n)
    reserved_state_events == '0
  ) else $error(
    "FRP M16 assertion failed: reserved_state_events must remain zero"
  );

  assert property (
    disable iff (!rst_n)
    queue_overflow_events == '0
  ) else $error(
    "FRP M16 assertion failed: queue_overflow_events must remain zero"
  );

  assert property (
    disable iff (!rst_n)
    prevented_direct_events >= requested_direct_events
  ) else $error(
    "FRP M16 assertion failed: prevented_direct_events < requested_direct_events"
  );

  assert property (
    disable iff (!rst_n)
    neutral_routed_events >= prevented_direct_events
  ) else $error(
    "FRP M16 assertion failed: neutral_routed_events < prevented_direct_events"
  );

  // --------------------------------------------------------------------------
  // Invariant-flag assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_STATE_DOMAIN_VALID]
  ) else $error(
    "FRP M16 assertion failed: state-domain invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_SCHEDULER_COUNTS_VALID]
  ) else $error(
    "FRP M16 assertion failed: scheduler-count invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_REQUEST_LANE_ORDER_VALID]
  ) else $error(
    "FRP M16 assertion failed: request-lane invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_PENDING_POLARITY_VALID]
  ) else $error(
    "FRP M16 assertion failed: pending-polarity invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_ACTIVE_NEUTRAL_VALID]
  ) else $error(
    "FRP M16 assertion failed: active-neutral invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_TRANSITION_CAPACITY_VALID]
  ) else $error(
    "FRP M16 assertion failed: transition-capacity invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_STATE_UPDATE_VALID]
  ) else $error(
    "FRP M16 assertion failed: state-update invariant flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_NO_ACTUAL_DIRECT_EVENTS]
  ) else $error(
    "FRP M16 assertion failed: no-actual-direct-events flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_NO_RESERVED_STATE]
  ) else $error(
    "FRP M16 assertion failed: no-reserved-state flag is false"
  );

  assert property (
    disable iff (!rst_n)
    invariant_flags[FRP_INV_NO_QUEUE_OVERFLOW]
  ) else $error(
    "FRP M16 assertion failed: no-queue-overflow flag is false"
  );

  // --------------------------------------------------------------------------
  // Tick-disabled hold assertions
  // --------------------------------------------------------------------------

  assert property (
    disable iff (!rst_n)
    !tick_enable
    |=>
    $stable(state_out)
  ) else $error(
    "FRP M16 assertion failed: state_out changed while tick_enable was low"
  );

  assert property (
    disable iff (!rst_n)
    !tick_enable
    |=>
    $stable(pending_route_out)
  ) else $error(
    "FRP M16 assertion failed: pending_route_out changed while tick_enable was low"
  );

  // ticks_recorded_q must hold while tick_enable is low, except for the
  // architecturally defined synchronous clear of the complete scheduler
  // counter bank.
  assert property (
    disable iff (!rst_n)
    !tick_enable
    |=>
    (
      $stable(ticks_recorded_q)
      || (
        (ticks_recorded_q == '0)
        && (scheduler_count_free_q == '0)
        && (scheduler_count_balance_q == '0)
        && (scheduler_count_commit_q == '0)
        && (scheduler_count_excite_q == '0)
        && (scheduler_count_neutralize_q == '0)
      )
    )
  ) else $error(
    "FRP M16 assertion failed: ticks_recorded changed without a complete scheduler counter clear"
  );

  // --------------------------------------------------------------------------
  // Qualification-cover properties
  // --------------------------------------------------------------------------

  cover property (
    scheduler_mode_q == FRP_MODE_FREE
  );

  cover property (
    scheduler_mode_q == FRP_MODE_7_1
  );

  cover property (
    scheduler_mode_q == FRP_MODE_1_7
  );

  cover property (
    neutral_routed_cell_mask != '0
  );

  cover property (
    accepted_change_mask != '0
  );

endmodule : frp_m16_assertions

`endif

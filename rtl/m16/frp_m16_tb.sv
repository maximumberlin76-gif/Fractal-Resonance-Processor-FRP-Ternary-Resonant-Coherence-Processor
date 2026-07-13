// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Deterministic RTL Testbench
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
//   Provides the first deterministic simulation harness for the integrated
//   M16 RTL core boundary.
//
// This testbench exercises:
//   - reset-to-neutral state initialization
//   - free scheduler mode
//   - 7/1 scheduler mode
//   - 1/7 scheduler mode
//   - neutral release 0 -> +1
//   - neutralization +1 -> 0
//   - opposite-polarity request +1 -> 0 with pending route to -1
//   - pending-route completion 0 -> -1
//   - invariant flags
//   - zero direct opposite-polarity events
//   - zero reserved-state events
//   - zero queue-overflow events

`ifndef FRP_M16_TB_SV
`define FRP_M16_TB_SV

`timescale 1ns/1ps

`include "frp_m16_pkg.sv"
`include "frp_m16_core.sv"
`include "frp_m16_assertions.sv"

module frp_m16_tb;

  import frp_m16_pkg::*;

  localparam int CELLS = 8;
  localparam int STATE_BITS = FRP_M16_STATE_BITS;
  localparam int REQUEST_LANES = frp_calc_request_lanes(CELLS);
  localparam int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS);
  localparam int COUNTER_BITS = FRP_M16_COUNTER_BITS;

  logic clk;
  logic rst_n;

  logic tick_enable;
  logic clear_counters;

  frp_m16_scheduler_mode_e scheduler_mode;

  logic [REQUEST_LANES-1:0] request_valid;
  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index;
  logic [(REQUEST_LANES*STATE_BITS)-1:0] request_target;

  logic [(CELLS*STATE_BITS)-1:0] target_q;

  logic [(CELLS*STATE_BITS)-1:0] state_out;
  logic [(CELLS*STATE_BITS)-1:0] pending_route_out;

  frp_m16_scheduler_mode_e  scheduler_mode_q;
  frp_m16_scheduler_state_e scheduler_state_q;

  logic [COUNTER_BITS-1:0] ticks_recorded_q;

  logic [COUNTER_BITS-1:0] scheduler_count_free_q;
  logic [COUNTER_BITS-1:0] scheduler_count_balance_q;
  logic [COUNTER_BITS-1:0] scheduler_count_commit_q;
  logic [COUNTER_BITS-1:0] scheduler_count_excite_q;
  logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q;

  logic [REQUEST_LANES-1:0] request_accept;
  logic [REQUEST_LANES-1:0] request_reject;

  logic [CELLS-1:0] accepted_cell_mask;
  logic [CELLS-1:0] neutral_routed_cell_mask;
  logic [CELLS-1:0] accepted_change_mask;

  logic [COUNTER_BITS-1:0] accepted_changes;
  logic [COUNTER_BITS-1:0] capacity_remaining;
  logic capacity_exhausted;
  logic [COUNTER_BITS-1:0] switch_load_numerator;

  logic [COUNTER_BITS-1:0] requested_direct_events;
  logic [COUNTER_BITS-1:0] prevented_direct_events;
  logic [COUNTER_BITS-1:0] neutral_routed_events;
  logic [COUNTER_BITS-1:0] actual_direct_events;
  logic [COUNTER_BITS-1:0] reserved_state_events;
  logic [COUNTER_BITS-1:0] queue_overflow_events;

  logic [FRP_M16_INVARIANT_FLAGS-1:0] invariant_flags;

  // --------------------------------------------------------------------------
  // Clock
  // --------------------------------------------------------------------------

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // --------------------------------------------------------------------------
  // DUT
  // --------------------------------------------------------------------------

  frp_m16_core #(
    .CELLS(CELLS),
    .STATE_BITS(STATE_BITS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(scheduler_mode),
    .request_valid(request_valid),
    .request_cell_index(request_cell_index),
    .request_target(request_target),
    .target_q(target_q),
    .state_out(state_out),
    .pending_route_out(pending_route_out),
    .scheduler_mode_q(scheduler_mode_q),
    .scheduler_state_q(scheduler_state_q),
    .ticks_recorded_q(ticks_recorded_q),
    .scheduler_count_free_q(scheduler_count_free_q),
    .scheduler_count_balance_q(scheduler_count_balance_q),
    .scheduler_count_commit_q(scheduler_count_commit_q),
    .scheduler_count_excite_q(scheduler_count_excite_q),
    .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
    .request_accept(request_accept),
    .request_reject(request_reject),
    .accepted_cell_mask(accepted_cell_mask),
    .neutral_routed_cell_mask(neutral_routed_cell_mask),
    .accepted_change_mask(accepted_change_mask),
    .accepted_changes(accepted_changes),
    .capacity_remaining(capacity_remaining),
    .capacity_exhausted(capacity_exhausted),
    .switch_load_numerator(switch_load_numerator),
    .requested_direct_events(requested_direct_events),
    .prevented_direct_events(prevented_direct_events),
    .neutral_routed_events(neutral_routed_events),
    .actual_direct_events(actual_direct_events),
    .reserved_state_events(reserved_state_events),
    .queue_overflow_events(queue_overflow_events),
    .invariant_flags(invariant_flags)
  );

  // --------------------------------------------------------------------------
  // Assertion layer
  // --------------------------------------------------------------------------

  frp_m16_assertions #(
    .CELLS(CELLS),
    .STATE_BITS(STATE_BITS),
    .REQUEST_LANES(REQUEST_LANES),
    .COUNTER_BITS(COUNTER_BITS)
  ) assertions (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode_q(scheduler_mode_q),
    .scheduler_state_q(scheduler_state_q),
    .ticks_recorded_q(ticks_recorded_q),
    .scheduler_count_free_q(scheduler_count_free_q),
    .scheduler_count_balance_q(scheduler_count_balance_q),
    .scheduler_count_commit_q(scheduler_count_commit_q),
    .scheduler_count_excite_q(scheduler_count_excite_q),
    .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
    .state_out(state_out),
    .pending_route_out(pending_route_out),
    .request_accept(request_accept),
    .request_reject(request_reject),
    .accepted_cell_mask(accepted_cell_mask),
    .neutral_routed_cell_mask(neutral_routed_cell_mask),
    .accepted_change_mask(accepted_change_mask),
    .accepted_changes(accepted_changes),
    .capacity_remaining(capacity_remaining),
    .capacity_exhausted(capacity_exhausted),
    .switch_load_numerator(switch_load_numerator),
    .requested_direct_events(requested_direct_events),
    .prevented_direct_events(prevented_direct_events),
    .neutral_routed_events(neutral_routed_events),
    .actual_direct_events(actual_direct_events),
    .reserved_state_events(reserved_state_events),
    .queue_overflow_events(queue_overflow_events),
    .invariant_flags(invariant_flags)
  );

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  task automatic clear_requests;
    begin
      request_valid = '0;
      request_cell_index = '0;
      request_target = '0;
      target_q = '0;
    end
  endtask

  task automatic set_lane(
    input int lane,
    input int element_index,
    input logic [STATE_BITS-1:0] target
  );
    begin
      request_valid[lane] = 1'b1;
      request_cell_index[(lane*CELL_INDEX_BITS) +: CELL_INDEX_BITS] =
        element_index[CELL_INDEX_BITS-1:0];
      request_target[(lane*STATE_BITS) +: STATE_BITS] = target;
      target_q[(element_index*STATE_BITS) +: STATE_BITS] = target;
    end
  endtask

  task automatic tick_once;
    begin
      @(negedge clk);
      tick_enable = 1'b1;
      @(negedge clk);
      tick_enable = 1'b0;
    end
  endtask

  task automatic expect_global_invariants;
    begin
      if (actual_direct_events != '0) begin
        $fatal(1, "FRP M16 TB failed: actual_direct_events is not zero");
      end

      if (reserved_state_events != '0) begin
        $fatal(1, "FRP M16 TB failed: reserved_state_events is not zero");
      end

      if (queue_overflow_events != '0) begin
        $fatal(1, "FRP M16 TB failed: queue_overflow_events is not zero");
      end

      if (!invariant_flags[FRP_INV_NO_ACTUAL_DIRECT_EVENTS]) begin
        $fatal(1, "FRP M16 TB failed: no-actual-direct invariant flag is false");
      end

      if (!invariant_flags[FRP_INV_NO_RESERVED_STATE]) begin
        $fatal(1, "FRP M16 TB failed: no-reserved-state invariant flag is false");
      end

      if (!invariant_flags[FRP_INV_NO_QUEUE_OVERFLOW]) begin
        $fatal(1, "FRP M16 TB failed: no-queue-overflow invariant flag is false");
      end
    end
  endtask

  // --------------------------------------------------------------------------
  // Test sequence
  // --------------------------------------------------------------------------

  initial begin
    rst_n = 1'b0;
    tick_enable = 1'b0;
    clear_counters = 1'b0;
    scheduler_mode = FRP_MODE_FREE;

    clear_requests();

    repeat (4) @(negedge clk);

    rst_n = 1'b1;

    repeat (2) @(negedge clk);

    // ----------------------------------------------------------------------
    // Reset expectation:
    // all retained states and pending routes must be active neutral 0.
    // ----------------------------------------------------------------------

    if (state_out !== '0) begin
      $fatal(1, "FRP M16 TB failed: reset did not initialize state_out to zero");
    end

    if (pending_route_out !== '0) begin
      $fatal(1, "FRP M16 TB failed: reset did not initialize pending_route_out to zero");
    end

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Free mode: neutral release 0 -> +1 on element_index 0.
    // ----------------------------------------------------------------------

    clear_requests();
    scheduler_mode = FRP_MODE_FREE;
    set_lane(0, 0, FRP_STATE_POS);
    tick_once();

    clear_requests();
    tick_once();

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Free mode: neutralization +1 -> 0 on element_index 0.
    // ----------------------------------------------------------------------

    clear_requests();
    set_lane(0, 0, FRP_STATE_ZERO);
    tick_once();

    clear_requests();
    tick_once();

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Free mode: create +1 state again.
    // ----------------------------------------------------------------------

    clear_requests();
    set_lane(0, 0, FRP_STATE_POS);
    tick_once();

    clear_requests();
    tick_once();

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Free mode: opposite-polarity request +1 -> -1.
    // Required behavior:
    //   current tick writes +1 -> 0
    //   pending route stores -1
    // ----------------------------------------------------------------------

    clear_requests();
    set_lane(0, 0, FRP_STATE_NEG);
    tick_once();

    clear_requests();
    tick_once();

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Pending completion:
    //   0 -> -1
    // ----------------------------------------------------------------------

    clear_requests();
    tick_once();

    clear_requests();
    tick_once();

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // 7/1 scheduler profile smoke.
    // ----------------------------------------------------------------------

    clear_counters = 1'b1;
    @(negedge clk);
    clear_counters = 1'b0;

    scheduler_mode = FRP_MODE_7_1;

    clear_requests();

    repeat (16) begin
      tick_once();
    end

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // 1/7 scheduler profile smoke.
    // ----------------------------------------------------------------------

    clear_counters = 1'b1;
    @(negedge clk);
    clear_counters = 1'b0;

    scheduler_mode = FRP_MODE_1_7;

    clear_requests();

    repeat (16) begin
      tick_once();
    end

    expect_global_invariants();

    // ----------------------------------------------------------------------
    // Final report.
    // ----------------------------------------------------------------------

    $display("FRP M16 deterministic RTL testbench completed.");
    $display("CELLS=%0d REQUEST_LANES=%0d", CELLS, REQUEST_LANES);
    $display("ticks_recorded=%0d", ticks_recorded_q);
    $display("actual_direct_events=%0d", actual_direct_events);
    $display("reserved_state_events=%0d", reserved_state_events);
    $display("queue_overflow_events=%0d", queue_overflow_events);

    $finish;
  end

endmodule : frp_m16_tb

`endif

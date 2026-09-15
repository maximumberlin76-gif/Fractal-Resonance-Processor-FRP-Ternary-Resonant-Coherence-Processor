// SPDX-License-Identifier: Apache-2.0
// Compare the execution netlist with the complete RTL routing workload.

`ifndef FRP_M31_EXECUTION_ROUTING_POST_SYNTHESIS_TB_SV
`define FRP_M31_EXECUTION_ROUTING_POST_SYNTHESIS_TB_SV
`include "frp_m31_execution_routing_tb.sv"

module frp_m31_execution_routing_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Synthesize the unmodified execution core with CELLS=8, REQUEST_LANES=2
  // and COUNTER_BITS=32, then rename its top to frp_m31_execution_core_netlist.
  // The reference retains its independent transition table and assertions.
  frp_m31_execution_routing_tb reference_test();

  typedef struct packed {
    logic [15:0] state_out, pending_route_out;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [31:0] ticks_recorded_q;
    logic [31:0] scheduler_count_free_q, scheduler_count_balance_q;
    logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q;
    logic [31:0] scheduler_count_neutralize_q;
    logic [1:0] request_accept, request_reject;
    logic [7:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
    logic [31:0] accepted_changes, capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load_numerator;
    logic [31:0] requested_direct_events, prevented_direct_events;
    logic [31:0] neutral_routed_events, actual_direct_events;
    logic [31:0] reserved_state_events, queue_overflow_events;
    logic [9:0] invariant_flags;
  } outputs_t;

  localparam int OUTPUT_BITS = $bits(outputs_t);
  wire outputs_t reference_outputs;
  outputs_t netlist_outputs;
  bit armed = 0, mismatch_seen = 0;
  bit previous_clk = 0, previous_rst_n = 1;
  int unsigned comparisons = 0, enabled_ticks = 0, hold_edges = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0;
  int unsigned clear_tick_edges = 0, clear_hold_edges = 0;

  frp_m31_execution_core_netlist u_execution_netlist (
    .clk(reference_test.clk),
    .rst_n(reference_test.rst_n),
    .tick_enable(reference_test.tick_enable),
    .clear_counters(reference_test.clear_counters),
    .scheduler_mode(reference_test.scheduler_mode),
    .request_valid(reference_test.request_valid),
    .request_cell_index(reference_test.request_cell_index),
    .request_target(reference_test.request_target),
    .target_q(reference_test.target_q),
    .state_out(netlist_outputs.state_out),
    .pending_route_out(netlist_outputs.pending_route_out),
    .scheduler_mode_q(netlist_outputs.scheduler_mode_q),
    .scheduler_state_q(netlist_outputs.scheduler_state_q),
    .ticks_recorded_q(netlist_outputs.ticks_recorded_q),
    .scheduler_count_free_q(netlist_outputs.scheduler_count_free_q),
    .scheduler_count_balance_q(netlist_outputs.scheduler_count_balance_q),
    .scheduler_count_commit_q(netlist_outputs.scheduler_count_commit_q),
    .scheduler_count_excite_q(netlist_outputs.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(netlist_outputs.scheduler_count_neutralize_q),
    .request_accept(netlist_outputs.request_accept),
    .request_reject(netlist_outputs.request_reject),
    .accepted_cell_mask(netlist_outputs.accepted_cell_mask),
    .neutral_routed_cell_mask(netlist_outputs.neutral_routed_cell_mask),
    .accepted_change_mask(netlist_outputs.accepted_change_mask),
    .accepted_changes(netlist_outputs.accepted_changes),
    .capacity_remaining(netlist_outputs.capacity_remaining),
    .capacity_exhausted(netlist_outputs.capacity_exhausted),
    .switch_load_numerator(netlist_outputs.switch_load_numerator),
    .requested_direct_events(netlist_outputs.requested_direct_events),
    .prevented_direct_events(netlist_outputs.prevented_direct_events),
    .neutral_routed_events(netlist_outputs.neutral_routed_events),
    .actual_direct_events(netlist_outputs.actual_direct_events),
    .reserved_state_events(netlist_outputs.reserved_state_events),
    .queue_overflow_events(netlist_outputs.queue_overflow_events),
    .invariant_flags(netlist_outputs.invariant_flags)
  );

  assign reference_outputs = '{
    state_out: reference_test.state_out,
    pending_route_out: reference_test.pending_route_out,
    scheduler_mode_q: reference_test.scheduler_mode_q,
    scheduler_state_q: reference_test.scheduler_state_q,
    ticks_recorded_q: reference_test.ticks_recorded_q,
    scheduler_count_free_q: reference_test.scheduler_count_free_q,
    scheduler_count_balance_q: reference_test.scheduler_count_balance_q,
    scheduler_count_commit_q: reference_test.scheduler_count_commit_q,
    scheduler_count_excite_q: reference_test.scheduler_count_excite_q,
    scheduler_count_neutralize_q: reference_test.scheduler_count_neutralize_q,
    request_accept: reference_test.request_accept,
    request_reject: reference_test.request_reject,
    accepted_cell_mask: reference_test.accepted_cell_mask,
    neutral_routed_cell_mask: reference_test.neutral_routed_cell_mask,
    accepted_change_mask: reference_test.accepted_change_mask,
    accepted_changes: reference_test.accepted_changes,
    capacity_remaining: reference_test.capacity_remaining,
    capacity_exhausted: reference_test.capacity_exhausted,
    switch_load_numerator: reference_test.switch_load_numerator,
    requested_direct_events: reference_test.requested_direct_events,
    prevented_direct_events: reference_test.prevented_direct_events,
    neutral_routed_events: reference_test.neutral_routed_events,
    actual_direct_events: reference_test.actual_direct_events,
    reserved_state_events: reference_test.reserved_state_events,
    queue_overflow_events: reference_test.queue_overflow_events,
    invariant_flags: reference_test.invariant_flags
  };

  initial begin
    if (OUTPUT_BITS != 556)
      $fatal(1, "Incomplete execution output bundle: %0d bits", OUTPUT_BITS);
  end

  // Sample all public outputs after zero-delay cells settle. The 1 fs delay
  // precedes the reference's 1 ns checks, including admission before a tick,
  // state after a tick, disabled clocks, counter clears and asynchronous reset.
  always @(reference_test.clk or reference_test.rst_n
           or reference_test.tick_enable or reference_test.clear_counters
           or reference_test.scheduler_mode or reference_test.request_valid
           or reference_test.request_cell_index or reference_test.request_target
           or reference_test.target_q) begin : compare_settled
    bit rising_edge, reset_assertion;
    #1fs;
    rising_edge = !previous_clk && reference_test.clk;
    reset_assertion = previous_rst_n && !reference_test.rst_n;
    previous_clk = reference_test.clk;
    previous_rst_n = reference_test.rst_n;
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs})
          || netlist_outputs !== reference_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "Execution post-synthesis mismatch time=%0t step=%0d reference=%h netlist=%h",
               $time, reference_test.steps, reference_outputs, netlist_outputs);
      end
      comparisons++;
      if (reset_assertion) reset_assertions++;
      if (rising_edge) begin
        if (!reference_test.rst_n) reset_clock_edges++;
        else begin
          if (reference_test.tick_enable) enabled_ticks++;
          else hold_edges++;
          if (reference_test.clear_counters) begin
            if (reference_test.tick_enable) clear_tick_edges++;
            else clear_hold_edges++;
          end
        end
      end
    end
  end

  final begin
    if (!armed || mismatch_seen || comparisons < 8792
        || enabled_ticks != 5664 || hold_edges != 1984
        || reset_assertions != 1144 || reset_clock_edges != 1144
        || clear_tick_edges != 32 || clear_hold_edges != 32)
      $fatal(1, "Incomplete execution post-synthesis coverage comparisons=%0d ticks=%0d holds=%0d reset_assertions=%0d reset_clock_edges=%0d clear_tick_edges=%0d clear_hold_edges=%0d",
             comparisons, enabled_ticks, hold_edges, reset_assertions,
             reset_clock_edges, clear_tick_edges, clear_hold_edges);
    if (reference_test.enabled_ticks != enabled_ticks
        || reference_test.hold_edges != hold_edges
        || reference_test.steps != enabled_ticks + hold_edges
        || reference_test.resets != reset_assertions
        || reference_test.counter_clears != clear_tick_edges + clear_hold_edges
        || reference_test.matrix_cases != 720 || reference_test.duplicate_cases != 216
        || reference_test.pending_cases != 32 || reference_test.capacity_cases != 128
        || reference_test.backlog_cases != 32 || reference_test.reserved_cases != 16
        || reference_test.first_legs != 496 || reference_test.second_legs != 352)
      $fatal(1, "Incomplete execution routing reference qualification");
    $display("FRP_M31_EXECUTION_ROUTING_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d enabled_ticks=%0d hold_edges=%0d reset_assertions=%0d reset_clock_edges=%0d clear_tick_edges=%0d clear_hold_edges=%0d matrix_cases=%0d duplicate_cases=%0d pending_cases=%0d capacity_cases=%0d backlog_cases=%0d reserved_cases=%0d first_legs=%0d second_legs=%0d",
             comparisons, OUTPUT_BITS, enabled_ticks, hold_edges,
             reset_assertions, reset_clock_edges, clear_tick_edges, clear_hold_edges,
             reference_test.matrix_cases, reference_test.duplicate_cases,
             reference_test.pending_cases, reference_test.capacity_cases,
             reference_test.backlog_cases, reference_test.reserved_cases,
             reference_test.first_legs, reference_test.second_legs);
  end
endmodule : frp_m31_execution_routing_post_synthesis_tb
`endif

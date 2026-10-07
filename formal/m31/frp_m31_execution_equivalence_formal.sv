// SPDX-License-Identifier: Apache-2.0
// Exact output equivalence of the M31 execution block used by M32.
// Profile: eight cells, two request lanes, 32-bit counters.
// All 26 output ports (556 bits) are compared on shared arbitrary inputs.
// The only assumption is an initial sampled reset. Later resets, holds,
// counter clears, all four mode codes, requests and targets are unrestricted.
// No DUT register is initialized or constrained to match the other DUT.
// Each formal step represents a sampled rising edge; use async2sync.
// Load the freshly synthesized frp_m31_execution_core_netlist with
// read_verilog -icells, then expose its tick_index_q and period_index_q
// as read-only outputs before reading this harness with read_slang.
// The two cadence equalities are proven auxiliary assertions, not assumptions.
// This scope excludes the phase engine, the M32 target register, liveness,
// physical timing, four-state simulation and Python-model equivalence.

`ifndef FRP_M31_EXECUTION_EQUIVALENCE_FORMAL_SV
`define FRP_M31_EXECUTION_EQUIVALENCE_FORMAL_SV
`include "frp_m31_pkg.sv"
`include "frp_m31_execution_core.sv"

module frp_m31_execution_equivalence_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  input logic [1:0] request_valid,
  input logic [5:0] request_cell_index,
  input logic [3:0] request_target,
  input logic [15:0] target_bank,
  output wire [555:0] rtl_outputs,
  output wire [555:0] netlist_outputs,
  output wire [31:0] rtl_tick_index, netlist_tick_index,
  output wire [2:0] rtl_period_index, netlist_period_index,
  output logic [25:0] mismatch,
  output logic [7:0] reach
);
  import frp_m31_pkg::*;

  // Packed order is the public execution-core output-port order.
  typedef struct packed {
    logic [15:0] state_out;
    logic [15:0] pending_route_out;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [31:0] ticks_recorded_q;
    logic [31:0] scheduler_count_free_q;
    logic [31:0] scheduler_count_balance_q;
    logic [31:0] scheduler_count_commit_q;
    logic [31:0] scheduler_count_excite_q;
    logic [31:0] scheduler_count_neutralize_q;
    logic [1:0] request_accept;
    logic [1:0] request_reject;
    logic [7:0] accepted_cell_mask;
    logic [7:0] neutral_routed_cell_mask;
    logic [7:0] accepted_change_mask;
    logic [31:0] accepted_changes;
    logic [31:0] capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load_numerator;
    logic [31:0] requested_direct_events;
    logic [31:0] prevented_direct_events;
    logic [31:0] neutral_routed_events;
    logic [31:0] actual_direct_events;
    logic [31:0] reserved_state_events;
    logic [31:0] queue_overflow_events;
    logic [9:0] invariant_flags;
  } observations_t;

  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;
  assign rtl_tick_index = rtl_dut.tick_index_q;
  assign rtl_period_index = rtl_dut.period_index_q;

  frp_m31_execution_core #(
    .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
    .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
  ) rtl_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .request_valid(request_valid),
    .request_cell_index(request_cell_index),
    .request_target(request_target),
    .target_q(target_bank),
    .state_out(rtl_observed.state_out),
    .pending_route_out(rtl_observed.pending_route_out),
    .scheduler_mode_q(rtl_observed.scheduler_mode_q),
    .scheduler_state_q(rtl_observed.scheduler_state_q),
    .ticks_recorded_q(rtl_observed.ticks_recorded_q),
    .scheduler_count_free_q(rtl_observed.scheduler_count_free_q),
    .scheduler_count_balance_q(rtl_observed.scheduler_count_balance_q),
    .scheduler_count_commit_q(rtl_observed.scheduler_count_commit_q),
    .scheduler_count_excite_q(rtl_observed.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(rtl_observed.scheduler_count_neutralize_q),
    .request_accept(rtl_observed.request_accept),
    .request_reject(rtl_observed.request_reject),
    .accepted_cell_mask(rtl_observed.accepted_cell_mask),
    .neutral_routed_cell_mask(rtl_observed.neutral_routed_cell_mask),
    .accepted_change_mask(rtl_observed.accepted_change_mask),
    .accepted_changes(rtl_observed.accepted_changes),
    .capacity_remaining(rtl_observed.capacity_remaining),
    .capacity_exhausted(rtl_observed.capacity_exhausted),
    .switch_load_numerator(rtl_observed.switch_load_numerator),
    .requested_direct_events(rtl_observed.requested_direct_events),
    .prevented_direct_events(rtl_observed.prevented_direct_events),
    .neutral_routed_events(rtl_observed.neutral_routed_events),
    .actual_direct_events(rtl_observed.actual_direct_events),
    .reserved_state_events(rtl_observed.reserved_state_events),
    .queue_overflow_events(rtl_observed.queue_overflow_events),
    .invariant_flags(rtl_observed.invariant_flags)
  );

  frp_m31_execution_core_netlist netlist_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .request_valid(request_valid),
    .request_cell_index(request_cell_index),
    .request_target(request_target),
    .target_q(target_bank),
    .state_out(netlist_observed.state_out),
    .pending_route_out(netlist_observed.pending_route_out),
    .scheduler_mode_q(netlist_observed.scheduler_mode_q),
    .scheduler_state_q(netlist_observed.scheduler_state_q),
    .ticks_recorded_q(netlist_observed.ticks_recorded_q),
    .scheduler_count_free_q(netlist_observed.scheduler_count_free_q),
    .scheduler_count_balance_q(netlist_observed.scheduler_count_balance_q),
    .scheduler_count_commit_q(netlist_observed.scheduler_count_commit_q),
    .scheduler_count_excite_q(netlist_observed.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(netlist_observed.scheduler_count_neutralize_q),
    .request_accept(netlist_observed.request_accept),
    .request_reject(netlist_observed.request_reject),
    .accepted_cell_mask(netlist_observed.accepted_cell_mask),
    .neutral_routed_cell_mask(netlist_observed.neutral_routed_cell_mask),
    .accepted_change_mask(netlist_observed.accepted_change_mask),
    .accepted_changes(netlist_observed.accepted_changes),
    .capacity_remaining(netlist_observed.capacity_remaining),
    .capacity_exhausted(netlist_observed.capacity_exhausted),
    .switch_load_numerator(netlist_observed.switch_load_numerator),
    .requested_direct_events(netlist_observed.requested_direct_events),
    .prevented_direct_events(netlist_observed.prevented_direct_events),
    .neutral_routed_events(netlist_observed.neutral_routed_events),
    .actual_direct_events(netlist_observed.actual_direct_events),
    .reserved_state_events(netlist_observed.reserved_state_events),
    .queue_overflow_events(netlist_observed.queue_overflow_events),
    .invariant_flags(netlist_observed.invariant_flags),
    .tick_index_q(netlist_tick_index),
    .period_index_q(netlist_period_index)
  );

  logic history_valid = 0;
  logic previous_reset, previous_tick;
  logic [15:0] previous_pending, previous_target;

  always @(posedge clk) begin
    history_valid <= 1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_pending <= rtl_observed.pending_route_out;
    previous_target <= target_bank;
  end

  // Mismatch bits follow the field order above; zero means exact equality.
  always_comb begin
    if (!history_valid) assume (!rst_n);
    mismatch[0] = rtl_observed.state_out != netlist_observed.state_out;
    mismatch[1] = rtl_observed.pending_route_out != netlist_observed.pending_route_out;
    mismatch[2] = rtl_observed.scheduler_mode_q != netlist_observed.scheduler_mode_q;
    mismatch[3] = rtl_observed.scheduler_state_q != netlist_observed.scheduler_state_q;
    mismatch[4] = rtl_observed.ticks_recorded_q != netlist_observed.ticks_recorded_q;
    mismatch[5] = rtl_observed.scheduler_count_free_q != netlist_observed.scheduler_count_free_q;
    mismatch[6] = rtl_observed.scheduler_count_balance_q != netlist_observed.scheduler_count_balance_q;
    mismatch[7] = rtl_observed.scheduler_count_commit_q != netlist_observed.scheduler_count_commit_q;
    mismatch[8] = rtl_observed.scheduler_count_excite_q != netlist_observed.scheduler_count_excite_q;
    mismatch[9] = rtl_observed.scheduler_count_neutralize_q != netlist_observed.scheduler_count_neutralize_q;
    mismatch[10] = rtl_observed.request_accept != netlist_observed.request_accept;
    mismatch[11] = rtl_observed.request_reject != netlist_observed.request_reject;
    mismatch[12] = rtl_observed.accepted_cell_mask != netlist_observed.accepted_cell_mask;
    mismatch[13] = rtl_observed.neutral_routed_cell_mask != netlist_observed.neutral_routed_cell_mask;
    mismatch[14] = rtl_observed.accepted_change_mask != netlist_observed.accepted_change_mask;
    mismatch[15] = rtl_observed.accepted_changes != netlist_observed.accepted_changes;
    mismatch[16] = rtl_observed.capacity_remaining != netlist_observed.capacity_remaining;
    mismatch[17] = rtl_observed.capacity_exhausted != netlist_observed.capacity_exhausted;
    mismatch[18] = rtl_observed.switch_load_numerator != netlist_observed.switch_load_numerator;
    mismatch[19] = rtl_observed.requested_direct_events != netlist_observed.requested_direct_events;
    mismatch[20] = rtl_observed.prevented_direct_events != netlist_observed.prevented_direct_events;
    mismatch[21] = rtl_observed.neutral_routed_events != netlist_observed.neutral_routed_events;
    mismatch[22] = rtl_observed.actual_direct_events != netlist_observed.actual_direct_events;
    mismatch[23] = rtl_observed.reserved_state_events != netlist_observed.reserved_state_events;
    mismatch[24] = rtl_observed.queue_overflow_events != netlist_observed.queue_overflow_events;
    mismatch[25] = rtl_observed.invariant_flags != netlist_observed.invariant_flags;
    if (history_valid) begin
      a_tick_index: assert (rtl_tick_index == netlist_tick_index);
      a_period_index: assert (rtl_period_index == netlist_period_index);
      a_state_out: assert (!mismatch[0]);
      a_pending_route_out: assert (!mismatch[1]);
      a_scheduler_mode_q: assert (!mismatch[2]);
      a_scheduler_state_q: assert (!mismatch[3]);
      a_ticks_recorded_q: assert (!mismatch[4]);
      a_scheduler_count_free_q: assert (!mismatch[5]);
      a_scheduler_count_balance_q: assert (!mismatch[6]);
      a_scheduler_count_commit_q: assert (!mismatch[7]);
      a_scheduler_count_excite_q: assert (!mismatch[8]);
      a_scheduler_count_neutralize_q: assert (!mismatch[9]);
      a_request_accept: assert (!mismatch[10]);
      a_request_reject: assert (!mismatch[11]);
      a_accepted_cell_mask: assert (!mismatch[12]);
      a_neutral_routed_cell_mask: assert (!mismatch[13]);
      a_accepted_change_mask: assert (!mismatch[14]);
      a_accepted_changes: assert (!mismatch[15]);
      a_capacity_remaining: assert (!mismatch[16]);
      a_capacity_exhausted: assert (!mismatch[17]);
      a_switch_load_numerator: assert (!mismatch[18]);
      a_requested_direct_events: assert (!mismatch[19]);
      a_prevented_direct_events: assert (!mismatch[20]);
      a_neutral_routed_events: assert (!mismatch[21]);
      a_actual_direct_events: assert (!mismatch[22]);
      a_reserved_state_events: assert (!mismatch[23]);
      a_queue_overflow_events: assert (!mismatch[24]);
      a_invariant_flags: assert (!mismatch[25]);
    end
  end

  // Independent satisfiability targets, never additional assumptions.
  always_comb begin
    reach = 0;
    if (history_valid && previous_reset && rst_n) begin
      reach[0] = rtl_observed.scheduler_mode_q == 0 && rtl_observed.pending_route_out != 0;
      reach[1] = rtl_observed.scheduler_mode_q == 1 && rtl_observed.pending_route_out != 0;
      reach[2] = rtl_observed.scheduler_mode_q == 2 && rtl_observed.pending_route_out != 0;
      reach[3] = rtl_observed.scheduler_mode_q == 3 && rtl_observed.pending_route_out != 0;
      reach[4] = previous_pending != 0 && !previous_tick;
      reach[5] = rtl_observed.pending_route_out != 0 && clear_counters;
      reach[6] = rtl_observed.pending_route_out != 0 && target_bank != previous_target;
    end
    reach[7] = history_valid && previous_reset && !rst_n && previous_pending != 0;
  end
endmodule
`endif

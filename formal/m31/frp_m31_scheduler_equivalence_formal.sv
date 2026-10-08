// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Exact equivalence of all 19 public M31 scheduler outputs on shared inputs.
// COUNTER_BITS=32 compares 241 bits; COUNTER_BITS=3 compares 38 bits and
// exposes counter wrap in short traces. Both profiles require induction.
// Only an initial sampled reset is assumed. Later reset, tick, counter-clear
// and all four mode codes are unrestricted, including reserved mode.
// No DUT register is initialized, forced or assumed equal to the other DUT.
// Each formal step is a sampled rising edge in a two-state model.
// Load a freshly synthesized frp_m31_scheduler_netlist of the SAME width
// with read_verilog -icells before reading this harness with read_slang.
// Use async2sync, then alumacc and opt -full to normalize both arithmetic
// cones before SAT; prove both the induction base case and induction step.
// No internal probes or extra netlist ports are required.
// Reach bits 0..16 use twelve-step traces at width 32; bits 17..19 at width 3.
// Reachability is separate from the unbounded equivalence proof.
// Functional cadence/accounting correctness is checked by the independent
// scheduler contract; this harness compares the implementations directly.
// Scope excludes full-core equivalence, routing, phase arithmetic, liveness,
// physical asynchronous-reset timing, four-state and Python-model equivalence.

`ifndef FRP_M31_SCHEDULER_EQUIVALENCE_FORMAL_SV
`define FRP_M31_SCHEDULER_EQUIVALENCE_FORMAL_SV
`include "frp_m31_pkg.sv"
`include "frp_m31_scheduler.sv"

module frp_m31_scheduler_equivalence_formal #(
  parameter int COUNTER_BITS = 32
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  output wire [(7*COUNTER_BITS)+16:0] rtl_outputs,
  output wire [(7*COUNTER_BITS)+16:0] netlist_outputs,
  output logic [18:0] mismatch,
  output logic [19:0] reach
);
  import frp_m31_pkg::*;

  typedef struct packed {
    logic [1:0] mode;
    logic [2:0] state;
    logic [COUNTER_BITS-1:0] index;
    logic [2:0] period;
    logic [COUNTER_BITS-1:0] ticks;
    logic [(5*COUNTER_BITS)-1:0] counts;
    logic [4:0] enables;
    logic mode_reserved, state_reserved, valid, counts_valid;
  } observations_t;

  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m31_scheduler #(.COUNTER_BITS(COUNTER_BITS)) rtl_dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .scheduler_mode_q(rtl_observed.mode), .scheduler_state_q(rtl_observed.state),
    .tick_index_q(rtl_observed.index), .period_index_q(rtl_observed.period),
    .ticks_recorded_q(rtl_observed.ticks),
    .scheduler_count_free_q(rtl_observed.counts[0*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_balance_q(rtl_observed.counts[1*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_commit_q(rtl_observed.counts[2*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_excite_q(rtl_observed.counts[3*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_neutralize_q(rtl_observed.counts[4*COUNTER_BITS +: COUNTER_BITS]),
    .free_enable(rtl_observed.enables[0]), .balance_enable(rtl_observed.enables[1]),
    .commit_enable(rtl_observed.enables[2]), .excite_enable(rtl_observed.enables[3]),
    .neutralize_enable(rtl_observed.enables[4]),
    .scheduler_mode_reserved(rtl_observed.mode_reserved),
    .scheduler_state_reserved(rtl_observed.state_reserved),
    .scheduler_valid(rtl_observed.valid), .scheduler_counts_valid(rtl_observed.counts_valid)
  );

  frp_m31_scheduler_netlist netlist_dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .scheduler_mode_q(netlist_observed.mode), .scheduler_state_q(netlist_observed.state),
    .tick_index_q(netlist_observed.index), .period_index_q(netlist_observed.period),
    .ticks_recorded_q(netlist_observed.ticks),
    .scheduler_count_free_q(netlist_observed.counts[0*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_balance_q(netlist_observed.counts[1*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_commit_q(netlist_observed.counts[2*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_excite_q(netlist_observed.counts[3*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_neutralize_q(netlist_observed.counts[4*COUNTER_BITS +: COUNTER_BITS]),
    .free_enable(netlist_observed.enables[0]), .balance_enable(netlist_observed.enables[1]),
    .commit_enable(netlist_observed.enables[2]), .excite_enable(netlist_observed.enables[3]),
    .neutralize_enable(netlist_observed.enables[4]),
    .scheduler_mode_reserved(netlist_observed.mode_reserved),
    .scheduler_state_reserved(netlist_observed.state_reserved),
    .scheduler_valid(netlist_observed.valid), .scheduler_counts_valid(netlist_observed.counts_valid)
  );

  logic history_valid = 1'b0;
  logic previous_reset, previous_tick, previous_clear;
  observations_t previous;
  wire live_transition = history_valid && previous_reset && rst_n;

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear_counters;
    previous <= rtl_observed;
  end

  // Each mismatch bit represents one complete public output port.
  // State correspondence is proved, never assumed or forced.
  always_comb begin
    if (!history_valid) assume (!rst_n);
    mismatch[0] = rtl_observed.mode
      != netlist_observed.mode;
    mismatch[1] = rtl_observed.state
      != netlist_observed.state;
    mismatch[2] = rtl_observed.index
      != netlist_observed.index;
    mismatch[3] = rtl_observed.period
      != netlist_observed.period;
    mismatch[4] = rtl_observed.ticks
      != netlist_observed.ticks;
    mismatch[5] = rtl_observed.counts[0*COUNTER_BITS +: COUNTER_BITS]
      != netlist_observed.counts[0*COUNTER_BITS +: COUNTER_BITS];
    mismatch[6] = rtl_observed.counts[1*COUNTER_BITS +: COUNTER_BITS]
      != netlist_observed.counts[1*COUNTER_BITS +: COUNTER_BITS];
    mismatch[7] = rtl_observed.counts[2*COUNTER_BITS +: COUNTER_BITS]
      != netlist_observed.counts[2*COUNTER_BITS +: COUNTER_BITS];
    mismatch[8] = rtl_observed.counts[3*COUNTER_BITS +: COUNTER_BITS]
      != netlist_observed.counts[3*COUNTER_BITS +: COUNTER_BITS];
    mismatch[9] = rtl_observed.counts[4*COUNTER_BITS +: COUNTER_BITS]
      != netlist_observed.counts[4*COUNTER_BITS +: COUNTER_BITS];
    mismatch[10] = rtl_observed.enables[0]
      != netlist_observed.enables[0];
    mismatch[11] = rtl_observed.enables[1]
      != netlist_observed.enables[1];
    mismatch[12] = rtl_observed.enables[2]
      != netlist_observed.enables[2];
    mismatch[13] = rtl_observed.enables[3]
      != netlist_observed.enables[3];
    mismatch[14] = rtl_observed.enables[4]
      != netlist_observed.enables[4];
    mismatch[15] = rtl_observed.mode_reserved
      != netlist_observed.mode_reserved;
    mismatch[16] = rtl_observed.state_reserved
      != netlist_observed.state_reserved;
    mismatch[17] = rtl_observed.valid
      != netlist_observed.valid;
    mismatch[18] = rtl_observed.counts_valid
      != netlist_observed.counts_valid;
    if (history_valid) begin
      a_scheduler_mode_q: assert (!mismatch[0]);
      a_scheduler_state_q: assert (!mismatch[1]);
      a_tick_index_q: assert (!mismatch[2]);
      a_period_index_q: assert (!mismatch[3]);
      a_ticks_recorded_q: assert (!mismatch[4]);
      a_scheduler_count_free_q: assert (!mismatch[5]);
      a_scheduler_count_balance_q: assert (!mismatch[6]);
      a_scheduler_count_commit_q: assert (!mismatch[7]);
      a_scheduler_count_excite_q: assert (!mismatch[8]);
      a_scheduler_count_neutralize_q: assert (!mismatch[9]);
      a_free_enable: assert (!mismatch[10]);
      a_balance_enable: assert (!mismatch[11]);
      a_commit_enable: assert (!mismatch[12]);
      a_excite_enable: assert (!mismatch[13]);
      a_neutralize_enable: assert (!mismatch[14]);
      a_scheduler_mode_reserved: assert (!mismatch[15]);
      a_scheduler_state_reserved: assert (!mismatch[16]);
      a_scheduler_valid: assert (!mismatch[17]);
      a_scheduler_counts_valid: assert (!mismatch[18]);
    end
  end

  // These trackers only describe witnesses; they constrain no DUT input.
  logic [3:0] run_7_1, run_1_7;
  always @(posedge clk) begin
    if (!rst_n || clear_counters || rtl_observed.mode != 1 || scheduler_mode != 1)
      run_7_1 <= 0;
    else if (tick_enable && run_7_1 < 8)
      run_7_1 <= run_7_1 + 1'b1;
    if (!rst_n || clear_counters || rtl_observed.mode != 2 || scheduler_mode != 2)
      run_1_7 <= 0;
    else if (tick_enable && run_1_7 < 8)
      run_1_7 <= run_1_7 + 1'b1;
  end

  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = run_7_1 == 8 && rtl_observed.mode == 1
        && rtl_observed.ticks == COUNTER_BITS'(8)
        && rtl_observed.counts == {COUNTER_BITS'(0), COUNTER_BITS'(0),
          COUNTER_BITS'(1), COUNTER_BITS'(7), COUNTER_BITS'(0)};
      reach[1] = run_1_7 == 8 && rtl_observed.mode == 2
        && rtl_observed.ticks == COUNTER_BITS'(8)
        && rtl_observed.counts == {COUNTER_BITS'(7), COUNTER_BITS'(1),
          COUNTER_BITS'(0), COUNTER_BITS'(0), COUNTER_BITS'(0)};
      reach[12] = rtl_observed.enables == 5'b00001;
      reach[13] = rtl_observed.enables == 5'b00010;
      reach[14] = rtl_observed.enables == 5'b01000;
      reach[15] = rtl_observed.enables == 5'b10000;
      reach[16] = scheduler_mode == 3 && rtl_observed.mode != 3
        && tick_enable && rtl_observed.valid;
    end
    if (live_transition) begin
      reach[2] = previous.mode == 1 && rtl_observed.mode == 2
        && !previous_tick && rtl_observed.period != 0;
      reach[3] = previous.mode == 2 && rtl_observed.mode == 1
        && previous_tick && previous.period == 7 && rtl_observed.period == 0;
      reach[4] = previous.mode != 3 && rtl_observed.mode == 3 && previous_tick;
      reach[5] = previous.mode == 3 && rtl_observed.mode != 3
        && previous_tick && !previous_clear && !rtl_observed.counts_valid;
      reach[6] = previous_clear && !previous_tick && previous.ticks != 0;
      reach[7] = previous_clear && previous_tick && previous.state == 2
        && rtl_observed.mode == 2 && rtl_observed.ticks == 1;
      reach[8] = previous_clear && previous_tick && previous.state == 7
        && rtl_observed.ticks == 1 && rtl_observed.counts == 0 && !rtl_observed.counts_valid;
      reach[9] = previous.mode == 1 && rtl_observed.mode == 1 && !previous_tick
        && previous.period == 7 && rtl_observed.state == 2 && rtl_observed.enables == 5'b00100;
      reach[10] = previous_clear && !previous_tick && previous.index != 0
        && rtl_observed.index == previous.index && rtl_observed.period != 0;
      reach[17] = previous_tick && (&previous.index) && rtl_observed.index == 0;
      reach[18] = previous_tick && !previous_clear
        && (&previous.ticks) && rtl_observed.ticks == 0;
      reach[19] = previous_tick && !previous_clear && previous.state == 0
        && (&previous.counts[0 +: COUNTER_BITS])
        && rtl_observed.counts[0 +: COUNTER_BITS] == 0;
    end
    reach[11] = history_valid && previous_reset && !rst_n && previous.index != 0;
  end
endmodule

`endif

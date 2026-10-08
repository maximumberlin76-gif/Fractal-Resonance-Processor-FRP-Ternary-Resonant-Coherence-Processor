// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent scheduler contract for the real M31 block inherited by M32.
// FREE, 7/1 and 1/7 cadence, registered mode handoff, pause, reset, clear,
// finite-width accounting and reserved-mode diagnostics are checked together.
// No DUT decode or validity helper is used by the reference contract.
// COUNTER_BITS=32 is the production profile; 3 exposes wrap in short traces.
// Only an initial sampled reset is assumed; all later inputs are arbitrary.
// Prove by temporal induction, including its reset base case. DUT registers
// are never initialized or constrained by this harness.
// Formal steps are sampled rising edges in a two-state model; use async2sync.
// Normalize the complete proof model with techmap and abc -g AND before SAT.
// Define FRP_M31_SCHEDULER_CONTRACT_NETLIST to use a freshly synthesized
// frp_m31_scheduler_netlist built with the same counter width.
// Reach bits 0..16 use twelve-step witnesses at width 32; bits 17..19 use
// width 3. Reachability does not replace the induction proof at either width.
// Scope excludes full-core equivalence, routing, phase arithmetic, liveness,
// physical asynchronous-reset timing and four-state simulation.

`ifndef FRP_M31_SCHEDULER_CONTRACT_FORMAL_SV
`define FRP_M31_SCHEDULER_CONTRACT_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_SCHEDULER_CONTRACT_NETLIST
`include "frp_m31_scheduler.sv"
`endif

module frp_m31_scheduler_contract_formal #(
  parameter int COUNTER_BITS = 32
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  output wire [(7*COUNTER_BITS)+16:0] observed_outputs,
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

  wire observations_t actual;
  assign observed_outputs = actual;

`ifdef FRP_M31_SCHEDULER_CONTRACT_NETLIST
  frp_m31_scheduler_netlist dut (
`else
  frp_m31_scheduler #(.COUNTER_BITS(COUNTER_BITS)) dut (
`endif
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .scheduler_mode_q(actual.mode), .scheduler_state_q(actual.state),
    .tick_index_q(actual.index), .period_index_q(actual.period),
    .ticks_recorded_q(actual.ticks),
    .scheduler_count_free_q(actual.counts[0*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_balance_q(actual.counts[1*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_commit_q(actual.counts[2*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_excite_q(actual.counts[3*COUNTER_BITS +: COUNTER_BITS]),
    .scheduler_count_neutralize_q(actual.counts[4*COUNTER_BITS +: COUNTER_BITS]),
    .free_enable(actual.enables[0]), .balance_enable(actual.enables[1]),
    .commit_enable(actual.enables[2]), .excite_enable(actual.enables[3]),
    .neutralize_enable(actual.enables[4]),
    .scheduler_mode_reserved(actual.mode_reserved),
    .scheduler_state_reserved(actual.state_reserved),
    .scheduler_valid(actual.valid), .scheduler_counts_valid(actual.counts_valid)
  );

  // Octal digits encode states at positions 7..0: FREE=0, BALANCE=1,
  // COMMIT=2, EXCITE=3, NEUTRALIZE=4, INVALID=7.
  function automatic logic [2:0] reference_state(
    input logic [1:0] mode, input logic [2:0] position
  );
    logic [23:0] sequence_word;
    case (mode)
      2'd0: sequence_word = 24'o00000000;
      2'd1: sequence_word = 24'o21111111;
      2'd2: sequence_word = 24'o44444443;
      default: sequence_word = 24'o77777777;
    endcase
    return sequence_word[3*position +: 3];
  endfunction

  logic history_valid = 1'b0;
  logic previous_reset, previous_tick, previous_clear;
  logic [1:0] previous_input_mode;
  observations_t previous;
  wire live_transition = history_valid && previous_reset && rst_n;
  wire [2:0] expected_state = reference_state(actual.mode, actual.index[2:0]);
  wire [2:0] counted_state = reference_state(previous.mode, previous.index[2:0]);
  logic [4:0] expected_enables;
  logic [COUNTER_BITS-1:0] count_sum, expected_index, expected_ticks;
  logic [(5*COUNTER_BITS)-1:0] expected_counts;

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear_counters;
    previous_input_mode <= scheduler_mode;
    previous <= actual;
  end

  // Clear precedes counting an enabled tick. The previously presented state
  // is counted; the incoming mode only selects the state after that edge.
  // Arithmetic is modulo 2**COUNTER_BITS, including the diagnostic sum.
  always_comb begin
    if (!history_valid) assume (!rst_n);
    expected_enables = '0;
    if (tick_enable && expected_state < 5)
      expected_enables[expected_state] = 1'b1;
    count_sum = '0;
    expected_index = previous.index + COUNTER_BITS'(previous_tick);
    expected_ticks = (previous_clear ? COUNTER_BITS'(0) : previous.ticks)
      + COUNTER_BITS'(previous_tick);
    expected_counts = '0;
    for (int state_id = 0; state_id < 5; state_id++) begin
      count_sum = count_sum + actual.counts[state_id*COUNTER_BITS +: COUNTER_BITS];
      expected_counts[state_id*COUNTER_BITS +: COUNTER_BITS] =
        (previous_clear ? COUNTER_BITS'(0)
          : previous.counts[state_id*COUNTER_BITS +: COUNTER_BITS])
        + COUNTER_BITS'(previous_tick && counted_state == state_id);
    end
    if (history_valid) begin
      a_state_sequence: assert (actual.state == expected_state);
      a_period: assert (actual.period == actual.index[2:0]);
      a_enables: assert (actual.enables == expected_enables);
      a_mode_diagnostic: assert (actual.mode_reserved == (actual.mode == 3));
      a_state_diagnostic: assert (actual.state_reserved == (expected_state == 7));
      a_valid: assert (actual.valid == (actual.mode != 3));
      a_count_diagnostic: assert (actual.counts_valid == (count_sum == actual.ticks));
      if (!rst_n || !previous_reset) begin
        a_reset_mode: assert (actual.mode == 0);
        a_reset_state: assert (actual.state == 0);
        a_reset_index: assert (actual.index == 0);
        a_reset_period: assert (actual.period == 0);
        a_reset_ticks: assert (actual.ticks == 0);
        a_reset_counts: assert (actual.counts == 0);
      end
      if (live_transition) begin
        a_registered_mode: assert (actual.mode == previous_input_mode);
        a_tick_index: assert (actual.index == expected_index);
        a_recorded_ticks: assert (actual.ticks == expected_ticks);
      end
    end
  end

  for (genvar state_id = 0; state_id < 5; state_id++) begin : counter_contract
    always_comb begin
      if (live_transition)
        a_state_counter: assert (
          actual.counts[state_id*COUNTER_BITS +: COUNTER_BITS]
          == expected_counts[state_id*COUNTER_BITS +: COUNTER_BITS]
        );
    end
  end

  // These trackers only describe witnesses; they constrain no DUT input.
  logic [3:0] run_7_1, run_1_7;
  always @(posedge clk) begin
    if (!rst_n || clear_counters || actual.mode != 1 || scheduler_mode != 1)
      run_7_1 <= 0;
    else if (tick_enable && run_7_1 < 8)
      run_7_1 <= run_7_1 + 1'b1;
    if (!rst_n || clear_counters || actual.mode != 2 || scheduler_mode != 2)
      run_1_7 <= 0;
    else if (tick_enable && run_1_7 < 8)
      run_1_7 <= run_1_7 + 1'b1;
  end

  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = run_7_1 == 8 && actual.mode == 1
        && actual.ticks == COUNTER_BITS'(8)
        && actual.counts == {COUNTER_BITS'(0), COUNTER_BITS'(0),
          COUNTER_BITS'(1), COUNTER_BITS'(7), COUNTER_BITS'(0)};
      reach[1] = run_1_7 == 8 && actual.mode == 2
        && actual.ticks == COUNTER_BITS'(8)
        && actual.counts == {COUNTER_BITS'(7), COUNTER_BITS'(1),
          COUNTER_BITS'(0), COUNTER_BITS'(0), COUNTER_BITS'(0)};
      reach[12] = actual.enables == 5'b00001;
      reach[13] = actual.enables == 5'b00010;
      reach[14] = actual.enables == 5'b01000;
      reach[15] = actual.enables == 5'b10000;
      reach[16] = scheduler_mode == 3 && actual.mode != 3
        && tick_enable && actual.valid;
    end
    if (live_transition) begin
      reach[2] = previous.mode == 1 && actual.mode == 2
        && !previous_tick && actual.period != 0;
      reach[3] = previous.mode == 2 && actual.mode == 1
        && previous_tick && previous.period == 7 && actual.period == 0;
      reach[4] = previous.mode != 3 && actual.mode == 3 && previous_tick;
      reach[5] = previous.mode == 3 && actual.mode != 3
        && previous_tick && !previous_clear && !actual.counts_valid;
      reach[6] = previous_clear && !previous_tick && previous.ticks != 0;
      reach[7] = previous_clear && previous_tick && counted_state == 2
        && actual.mode == 2 && actual.ticks == 1;
      reach[8] = previous_clear && previous_tick && counted_state == 7
        && actual.ticks == 1 && actual.counts == 0 && !actual.counts_valid;
      reach[9] = previous.mode == 1 && actual.mode == 1 && !previous_tick
        && previous.period == 7 && actual.state == 2 && actual.enables == 5'b00100;
      reach[10] = previous_clear && !previous_tick && previous.index != 0
        && actual.index == previous.index && actual.period != 0;
      reach[17] = previous_tick && (&previous.index) && actual.index == 0;
      reach[18] = previous_tick && !previous_clear
        && (&previous.ticks) && actual.ticks == 0;
      reach[19] = previous_tick && !previous_clear && counted_state == 0
        && (&previous.counts[0 +: COUNTER_BITS])
        && actual.counts[0 +: COUNTER_BITS] == 0;
    end
    reach[11] = history_valid && previous_reset && !rst_n && previous.index != 0;
  end
endmodule

`endif

// SPDX-License-Identifier: Apache-2.0
// M31 scheduler control: literal cadence, registered mode changes and counters.
// Each profile covers all 4 old modes x 8 positions x 4 new modes x 2 tick
// enables x 2 clears, including reserved-mode diagnostics and recovery.
// Counter widths 3 and 8 exercise natural wrap; 32 is the production width.
`timescale 1ns/1ps
`include "frp_m31_scheduler.sv"

module frp_m31_scheduler_control_case #(parameter int COUNTER_BITS = 32);
  import frp_m31_pkg::*;

  // Independent contract table: FREE=0, BALANCE=1, COMMIT=2, EXCITE=3,
  // NEUTRALIZE=4, INVALID=7. No DUT decode or validity helper is used.
  localparam int CADENCE [0:3][0:7] = '{
    '{0, 0, 0, 0, 0, 0, 0, 0},
    '{1, 1, 1, 1, 1, 1, 1, 2},
    '{3, 4, 4, 4, 4, 4, 4, 4},
    '{7, 7, 7, 7, 7, 7, 7, 7}
  };
  localparam longint unsigned MASK = (64'd1 << COUNTER_BITS) - 1;

  typedef struct packed {
    logic [1:0] mode;
    logic [2:0] state;
    logic [COUNTER_BITS-1:0] index;
    logic [2:0] period;
    logic [COUNTER_BITS-1:0] ticks;
    logic [(5*COUNTER_BITS)-1:0] counts;
    logic [4:0] enables;
    logic mode_reserved, state_reserved, valid, counts_valid;
  } outputs_t;

  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  outputs_t actual;
  bit done = 0;
  longint unsigned gold_index = 0, gold_ticks = 0;
  longint unsigned gold_counts [0:4] = '{default: 0};
  int gold_mode = 0;
  logic [511:0] matrix_seen = '0;
  int matrix_cases = 0, steady_ticks = 0, recovery_cases = 0;
  int steps = 0, enabled_edges = 0, hold_edges = 0, clear_edges = 0;
  int resets = 0, observations = 0;
  int index_wraps = 0, recorded_wraps = 0, counter_wraps = 0;
  int state_hits [0:7] = '{default: 0};

  frp_m31_scheduler #(.COUNTER_BITS(COUNTER_BITS)) dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .scheduler_mode,
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

  task automatic check_outputs;
    outputs_t expected;
    longint unsigned total;
    int state;
    state = CADENCE[gold_mode][gold_index % 8];
    expected = '0;
    expected.mode = 2'(gold_mode);
    expected.state = 3'(state);
    expected.index = COUNTER_BITS'(gold_index);
    expected.period = 3'(gold_index % 8);
    expected.ticks = COUNTER_BITS'(gold_ticks);
    total = 0;
    for (int i = 0; i < 5; i++) begin
      expected.counts[i*COUNTER_BITS +: COUNTER_BITS] = COUNTER_BITS'(gold_counts[i]);
      total += gold_counts[i];
    end
    if (tick_enable && state < 5) expected.enables[state] = 1;
    expected.mode_reserved = gold_mode == 3;
    expected.state_reserved = state == 7;
    expected.valid = gold_mode != 3;
    expected.counts_valid = (gold_ticks & MASK) == (total & MASK);
    if ($isunknown(actual) || actual !== expected)
      $fatal(1, "Scheduler mismatch bits=%0d check=%0d step=%0d input_mode=%0d tick=%b clear=%b reset_n=%b actual=%h expected=%h",
        COUNTER_BITS, observations, steps, scheduler_mode, tick_enable,
        clear_counters, rst_n, actual, expected);
    observations++;
  endtask

  task automatic step(input int next_mode, input bit enabled, input bit cleared);
    int presented_state;
    scheduler_mode = frp_m31_scheduler_mode_e'(next_mode);
    tick_enable = enabled;
    clear_counters = cleared;
    #1;
    check_outputs(); // Inputs must not change registered mode, position or counts.
    presented_state = CADENCE[gold_mode][gold_index % 8];
    if (cleared) begin
      gold_ticks = 0;
      foreach (gold_counts[i]) gold_counts[i] = 0;
      clear_edges++;
    end
    if (enabled) begin
      if ((gold_index & MASK) == MASK) index_wraps++;
      if ((gold_ticks & MASK) == MASK) recorded_wraps++;
      gold_index++;
      gold_ticks++;
      enabled_edges++;
      state_hits[presented_state]++;
      if (presented_state < 5) begin
        if ((gold_counts[presented_state] & MASK) == MASK) counter_wraps++;
        gold_counts[presented_state]++;
      end
    end else hold_edges++;
    // This edge counts the previously presented state. The new mode is
    // visible only after the edge, even when the tick is disabled.
    gold_mode = next_mode;
    clk = 1;
    #1;
    steps++;
    check_outputs();
    clk = 0;
    #1;
    check_outputs(); // Falling edges cannot consume ticks or reconfigure mode.
  endtask

  task automatic reset_scheduler(
      input int incoming = 0, input bit enabled = 0, input bit cleared = 0);
    scheduler_mode = frp_m31_scheduler_mode_e'(incoming);
    tick_enable = enabled;
    clear_counters = cleared;
    #1;
    rst_n = 0;
    gold_mode = 0; gold_index = 0; gold_ticks = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    #1;
    check_outputs(); // Asynchronous assertion, before any rising clock edge.
    clk = 1;
    #1;
    check_outputs(); // Reset dominates mode, tick and clear at the clock edge.
    clk = 0;
    #1;
    check_outputs();
    rst_n = 1;
    #1;
    check_outputs(); // Deassertion alone cannot register the incoming mode.
    resets++;
  endtask

  task automatic print_result;
    $display("FRP_M31_SCHEDULER_CONTROL_PROFILE: PASS counter_bits=%0d output_bits=%0d matrix_cases=%0d steady_ticks=%0d recovery_cases=%0d resets=%0d enabled_edges=%0d hold_edges=%0d clear_edges=%0d observations=%0d index_wraps=%0d recorded_wraps=%0d counter_wraps=%0d",
      COUNTER_BITS, $bits(actual), matrix_cases, steady_ticks, recovery_cases,
      resets, enabled_edges, hold_edges, clear_edges, observations,
      index_wraps, recorded_wraps, counter_wraps);
  endtask

  initial begin : regression
    int coverage_index;
    if (!(COUNTER_BITS == 3 || COUNTER_BITS == 8 || COUNTER_BITS == 32)
        || $bits(actual) != 7*COUNTER_BITS + 17)
      $fatal(1, "Unsupported scheduler test profile or incomplete output bundle");

    // Every legal or reserved mode change, at every period position, with
    // every tick/clear combination. Position is reached through real ticks.
    for (int old_mode = 0; old_mode < 4; old_mode++)
      for (int position = 0; position < 8; position++)
        for (int next_mode = 0; next_mode < 4; next_mode++)
          for (int enabled = 0; enabled < 2; enabled++)
            for (int cleared = 0; cleared < 2; cleared++) begin
              reset_scheduler();
              step(old_mode, 0, 0);
              repeat (position) step(old_mode, 1, 0);
              coverage_index = ((((old_mode*8 + position)*4 + next_mode)*2
                                + enabled)*2 + cleared);
              if (matrix_seen[coverage_index])
                $fatal(1, "Repeated scheduler matrix case");
              step(next_mode, 1'(enabled), 1'(cleared));
              matrix_seen[coverage_index] = 1;
              matrix_cases++;
            end

    // 64 uninterrupted eight-tick periods per valid mode, with a disabled
    // edge after each period. Wide event totals are narrowed only on output
    // comparison, independently checking finite-width counter arithmetic.
    for (int mode = 0; mode < 3; mode++) begin
      reset_scheduler();
      step(mode, 0, 0);
      for (int tick = 0; tick < 512; tick++) begin
        step(mode, 1, 0);
        steady_ticks++;
        if ((tick % 8) == 7) step(mode, 0, 0);
      end
      step(mode, 0, 1);
      step(mode, 1, 1);
    end

    // An invalid-state tick has no legal-state counter. Returning to a valid
    // mode must not erase that discrepancy; an explicit clear restores it.
    for (int mode = 0; mode < 3; mode++) begin
      reset_scheduler();
      step(3, 0, 0);
      step(3, 1, 0);
      step(mode, 0, 0);
      step(mode, 1, 0);
      step(mode, 0, 1);
      step(mode, 1, 1);
      recovery_cases++;
    end

    // Reset and release under all incoming modes and both control levels.
    for (int mode = 0; mode < 4; mode++)
      for (int enabled = 0; enabled < 2; enabled++)
        for (int cleared = 0; cleared < 2; cleared++) begin
          reset_scheduler(mode, 1'(enabled), 1'(cleared));
          step(mode, 1'(enabled), 1'(cleared));
        end

    if (matrix_cases != 512 || matrix_seen !== {512{1'b1}}
        || steady_ticks != 1536 || recovery_cases != 3 || resets != 534
        || steps != 4587 || enabled_edges != 3604 || hold_edges != 983
        || clear_edges != 276 || observations != 15897
        || state_hits[0] != 1035 || state_hits[1] != 955 || state_hits[2] != 72
        || state_hits[3] != 185 || state_hits[4] != 842 || state_hits[5] != 0
        || state_hits[6] != 0 || state_hits[7] != 515)
      $fatal(1, "Incomplete scheduler control coverage bits=%0d checks=%0d steps=%0d",
        COUNTER_BITS, observations, steps);
    if ((COUNTER_BITS == 3 && {index_wraps, recorded_wraps, counter_wraps}
            !== {32'd224, 32'd208, 32'd196})
        || (COUNTER_BITS == 8 && {index_wraps, recorded_wraps, counter_wraps}
            !== {32'd6, 32'd6, 32'd4})
        || (COUNTER_BITS == 32 && {index_wraps, recorded_wraps, counter_wraps} !== 96'b0))
      $fatal(1, "Incomplete scheduler counter-wrap coverage bits=%0d", COUNTER_BITS);
    done = 1;
  end
endmodule

module frp_m31_scheduler_control_tb;
  frp_m31_scheduler_control_case #(.COUNTER_BITS(3)) width3();
  frp_m31_scheduler_control_case #(.COUNTER_BITS(8)) width8();
  frp_m31_scheduler_control_case #(.COUNTER_BITS(32)) width32();

  initial begin
    wait (width3.done && width8.done && width32.done);
    width3.print_result();
    width8.print_result();
    width32.print_result();
    $display("FRP_M31_SCHEDULER_CONTROL_TB: PASS profiles=3 matrix_cases=%0d steady_ticks=%0d recovery_cases=%0d observations=%0d",
      width3.matrix_cases + width8.matrix_cases + width32.matrix_cases,
      width3.steady_ticks + width8.steady_ticks + width32.steady_ticks,
      width3.recovery_cases + width8.recovery_cases + width32.recovery_cases,
      width3.observations + width8.observations + width32.observations);
    $finish;
  end

  initial begin
    #100000;
    $fatal(1, "FRP M31 scheduler control watchdog expired");
  end
endmodule

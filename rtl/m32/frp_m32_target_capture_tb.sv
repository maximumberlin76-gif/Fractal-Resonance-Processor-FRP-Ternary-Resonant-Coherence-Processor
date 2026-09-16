// SPDX-License-Identifier: Apache-2.0
// M32 registered target boundary: exhaustive source words and capture controls.
// Literal encoding contract: 00 = active 0, 01 = 1, 11 = -1, 10 = reserved.
// Targets are captured atomically; target capture is not retained-state execution.
// Small counters reach saturation naturally; the 32-bit profile checks normal
// increments, holds, clears and resets without forcing internal state.
`timescale 1ns/1ps
`include "frp_m32_registered_target_boundary.sv"

module frp_m32_target_capture_case #(
    parameter int CELLS = 8, parameter int COUNTER_BITS = 32);
  localparam int WORD_BITS = 2 * CELLS;
  localparam int SOURCE_WORDS = 1 << WORD_BITS;
  localparam int VALID_WORDS = 3 ** CELLS;
  localparam longint unsigned LIMIT = (64'd1 << COUNTER_BITS) - 1;
  localparam int PRESSURE = (COUNTER_BITS <= 8) ? (1 << COUNTER_BITS) + 3 : 260;
  localparam logic [WORD_BITS-1:0] POS_WORD = {CELLS{2'b01}};
  localparam logic [WORD_BITS-1:0] NEG_WORD = {CELLS{2'b11}};
  localparam logic [WORD_BITS-1:0] BAD_WORD = {CELLS{2'b10}};

  typedef struct packed {
    logic [WORD_BITS-1:0] target;
    logic history_valid, source_domain, target_domain, accepted, rejected;
    logic [COUNTER_BITS-1:0] accepted_count, rejected_count;
  } outputs_t;

  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  logic phase_target_valid = 0;
  logic [WORD_BITS-1:0] phase_target = '0;
  outputs_t actual;
  logic [WORD_BITS-1:0] gold_target = '0;
  bit gold_valid = 0, done = 0;
  longint unsigned gold_accepted = 0, gold_rejected = 0;
  bit [7:0] matrix_seen [0:SOURCE_WORDS-1];
  int matrix_cases = 0, valid_words = 0, invalid_words = 0;
  int steps = 0, observations = 0, resets = 0, reset_cases = 0;
  int accepted_edges = 0, rejected_edges = 0, hold_edges = 0;
  int clear_edges = 0, clear_accepts = 0, clear_rejects = 0;
  int accepted_cap_holds = 0, rejected_cap_holds = 0;
  int pressure_accept_holds = 0, pressure_reject_holds = 0;

  frp_m32_registered_target_boundary #(
    .CELLS(CELLS), .COUNTER_BITS(COUNTER_BITS)
  ) dut (
    .clk, .rst_n, .tick_enable, .clear_counters,
    .phase_target_valid, .phase_target,
    .registered_target_q(actual.target),
    .registered_target_valid_q(actual.history_valid),
    .phase_target_domain_valid(actual.source_domain),
    .registered_target_domain_valid(actual.target_domain),
    .capture_accepted(actual.accepted), .capture_rejected(actual.rejected),
    .accepted_capture_events_q(actual.accepted_count),
    .rejected_capture_events_q(actual.rejected_count)
  );

  // Decode the enumerated source as base-four digits. No DUT or package
  // validity function, capture flag or registered output feeds this oracle.
  function automatic bit canonical(input logic [WORD_BITS-1:0] word);
    int unsigned digits;
    bit valid;
    digits = int'(word);
    valid = 1;
    repeat (CELLS) begin
      if ((digits % 4) == 2) valid = 0;
      digits /= 4;
    end
    return valid;
  endfunction

  task automatic check_outputs;
    outputs_t expected;
    expected = '0;
    expected.target = gold_target;
    expected.history_valid = gold_valid;
    expected.source_domain = canonical(phase_target);
    expected.target_domain = 1;
    // Capture diagnostics classify the presented controls, also during reset;
    // reset overrides storage and counters, not these combinational outputs.
    expected.accepted = tick_enable && phase_target_valid && expected.source_domain;
    expected.rejected = tick_enable && phase_target_valid && !expected.source_domain;
    expected.accepted_count = COUNTER_BITS'(
      (gold_accepted > LIMIT) ? LIMIT : gold_accepted);
    expected.rejected_count = COUNTER_BITS'(
      (gold_rejected > LIMIT) ? LIMIT : gold_rejected);
    if ($isunknown(actual) || actual !== expected)
      $fatal(1, "Target capture mismatch cells=%0d bits=%0d check=%0d step=%0d source=%h valid=%b tick=%b clear=%b reset_n=%b actual=%h expected=%h",
        CELLS, COUNTER_BITS, observations, steps, phase_target,
        phase_target_valid, tick_enable, clear_counters, rst_n, actual, expected);
    observations++;
  endtask

  task automatic step(input logic [WORD_BITS-1:0] word,
      input bit offered, input bit enabled, input bit cleared);
    bit accepted, rejected;
    phase_target = word;
    phase_target_valid = offered;
    tick_enable = enabled;
    clear_counters = cleared;
    #1;
    check_outputs(); // Source and controls cannot bypass the register.
    accepted = enabled && offered && canonical(word);
    rejected = enabled && offered && !canonical(word);
    if (!enabled) hold_edges++;
    if (accepted) begin
      gold_target = word;
      gold_valid = 1;
      accepted_edges++;
    end
    if (rejected) rejected_edges++;
    if (cleared) begin
      gold_accepted = 0;
      gold_rejected = 0;
      clear_edges++;
      if (accepted) clear_accepts++;
      if (rejected) clear_rejects++;
    end else begin
      // Unbounded event totals are clamped only when comparing outputs.
      if (accepted) begin
        gold_accepted++;
        if (gold_accepted > LIMIT) accepted_cap_holds++;
      end
      if (rejected) begin
        gold_rejected++;
        if (gold_rejected > LIMIT) rejected_cap_holds++;
      end
    end
    clk = 1;
    #1;
    steps++;
    check_outputs();
    clk = 0;
    #1;
    check_outputs(); // Falling edges cannot capture or count an event.
  endtask

  task automatic reset_boundary(input logic [WORD_BITS-1:0] word,
      input bit offered, input bit enabled, input bit cleared);
    phase_target = word;
    phase_target_valid = offered;
    tick_enable = enabled;
    clear_counters = cleared;
    #1;
    rst_n = 0;
    gold_target = '0;
    gold_valid = 0;
    gold_accepted = 0;
    gold_rejected = 0;
    #1;
    check_outputs(); // Asynchronous reset before a rising clock edge.
    clk = 1;
    #1;
    check_outputs(); // Reset dominates capture and clear at the edge.
    clk = 0;
    #1;
    check_outputs();
    rst_n = 1;
    #1;
    check_outputs(); // Release alone cannot establish capture history.
    resets++;
  endtask

  task automatic print_result;
    $display("FRP_M32_TARGET_CAPTURE_PROFILE: PASS cells=%0d counter_bits=%0d output_bits=%0d source_words=%0d valid_words=%0d invalid_words=%0d matrix_cases=%0d reset_cases=%0d resets=%0d pressure_events=%0d accepted_edges=%0d rejected_edges=%0d hold_edges=%0d clear_edges=%0d clear_accepts=%0d clear_rejects=%0d accepted_saturation_holds=%0d rejected_saturation_holds=%0d observations=%0d",
      CELLS, COUNTER_BITS, $bits(actual), SOURCE_WORDS, valid_words, invalid_words,
      matrix_cases, reset_cases, resets, 2*PRESSURE, accepted_edges, rejected_edges,
      hold_edges, clear_edges, clear_accepts, clear_rejects,
      pressure_accept_holds, pressure_reject_holds, observations);
  endtask

  initial begin : regression
    logic [WORD_BITS-1:0] word, seed_word;
    int cap_accept_before, cap_reject_before;
    if (!((CELLS == 1 && COUNTER_BITS == 1)
          || (CELLS == 8 && (COUNTER_BITS == 3
              || COUNTER_BITS == 8 || COUNTER_BITS == 32)))
        || $bits(actual) != WORD_BITS + 5 + 2*COUNTER_BITS)
      $fatal(1, "Unsupported target capture profile or incomplete output bundle");
    if (frp_m31_pkg::FRP_M31_STATE_BITS != 2
        || frp_m31_pkg::FRP_ACTIVE_NEUTRAL !== 2'b00
        || frp_m31_pkg::FRP_STATE_POS !== 2'b01
        || frp_m31_pkg::FRP_STATE_NEG !== 2'b11
        || frp_m31_pkg::FRP_STATE_RESERVED !== 2'b10)
      $fatal(1, "Target capture encoding contract changed");
    foreach (matrix_seen[w]) matrix_seen[w] = '0;
    reset_boundary('0, 0, 0, 0);

    // Exhaust all 4^CELLS source words and all valid/tick/clear combinations.
    // A distinct canonical word is captured before each case, so rejected or
    // disabled captures must preserve the complete previous word and history.
    for (int encoded = 0; encoded < SOURCE_WORDS; encoded++) begin
      word = WORD_BITS'(encoded);
      if (canonical(word)) valid_words++;
      else invalid_words++;
      seed_word = (word == POS_WORD) ? NEG_WORD : POS_WORD;
      for (int controls = 0; controls < 8; controls++) begin
        step(seed_word, 1, 1, 0);
        if (matrix_seen[encoded][controls])
          $fatal(1, "Repeated target capture matrix case");
        step(word, controls[2], controls[1], controls[0]);
        matrix_seen[encoded][controls] = 1;
        matrix_cases++;
      end
    end
    foreach (matrix_seen[w])
      if (matrix_seen[w] !== 8'hff)
        $fatal(1, "Missing target capture controls word=%0d", w);
    if (matrix_cases != 8*SOURCE_WORDS || valid_words != VALID_WORDS
        || invalid_words != SOURCE_WORDS - VALID_WORDS
        || steps != 16*SOURCE_WORDS
        || accepted_edges != 8*SOURCE_WORDS + 2*VALID_WORDS
        || rejected_edges != 2*(SOURCE_WORDS - VALID_WORDS)
        || hold_edges != 4*SOURCE_WORDS || clear_edges != 4*SOURCE_WORDS
        || clear_accepts != VALID_WORDS
        || clear_rejects != SOURCE_WORDS - VALID_WORDS)
      $fatal(1, "Incomplete exhaustive target capture coverage");

    // Reach both counter ceilings independently with real edges. Captures
    // continue to replace targets after the accepted-event counter saturates.
    reset_boundary(NEG_WORD, 1, 1, 0);
    cap_accept_before = accepted_cap_holds;
    cap_reject_before = rejected_cap_holds;
    for (int i = 0; i < PRESSURE; i++)
      step((i % 3 == 0) ? '0 : ((i % 3 == 1) ? POS_WORD : NEG_WORD), 1, 1, 0);
    repeat (PRESSURE) step(BAD_WORD, 1, 1, 0);
    pressure_accept_holds = accepted_cap_holds - cap_accept_before;
    pressure_reject_holds = rejected_cap_holds - cap_reject_before;
    if (gold_accepted != 64'(PRESSURE) || gold_rejected != 64'(PRESSURE)
        || pressure_accept_holds != ((COUNTER_BITS <= 8) ? 4 : 0)
        || pressure_reject_holds != ((COUNTER_BITS <= 8) ? 4 : 0))
      $fatal(1, "Incomplete natural counter saturation coverage");
    step(NEG_WORD, 1, 0, 0);
    step(NEG_WORD, 0, 1, 0);
    step(NEG_WORD, 0, 0, 1);
    step(POS_WORD, 1, 1, 0);
    step(BAD_WORD, 1, 1, 1);
    step(NEG_WORD, 1, 1, 1);
    step('0, 1, 0, 1);

    // Start every reset case with valid history and nonzero event counters.
    // Exercise valid and reserved sources under all eight control settings,
    // including capture diagnostics during reset and the first released edge.
    for (int invalid = 0; invalid < 2; invalid++)
      for (int controls = 0; controls < 8; controls++) begin
        step(POS_WORD, 1, 1, 0);
        step(BAD_WORD, 1, 1, 0);
        word = (invalid != 0) ? BAD_WORD : NEG_WORD;
        reset_boundary(word, controls[2], controls[1], controls[0]);
        step(word, controls[2], controls[1], controls[0]);
        reset_cases++;
      end

    if (reset_cases != 16 || resets != 18
        || steps != 16*SOURCE_WORDS + 2*PRESSURE + 55
        || observations != 3*steps + 4*resets
        || accepted_edges != 8*SOURCE_WORDS + 2*VALID_WORDS + PRESSURE + 20
        || rejected_edges != 2*(SOURCE_WORDS - VALID_WORDS) + PRESSURE + 19
        || hold_edges != 4*SOURCE_WORDS + 11
        || clear_edges != 4*SOURCE_WORDS + 12
        || clear_accepts != VALID_WORDS + 2
        || clear_rejects != SOURCE_WORDS - VALID_WORDS + 2)
      $fatal(1, "Incomplete target capture sequence cells=%0d bits=%0d steps=%0d checks=%0d",
        CELLS, COUNTER_BITS, steps, observations);
    done = 1;
  end
endmodule

module frp_m32_target_capture_tb;
  frp_m32_target_capture_case #(.CELLS(1), .COUNTER_BITS(1)) single();
  frp_m32_target_capture_case #(.COUNTER_BITS(3)) width3();
  frp_m32_target_capture_case #(.COUNTER_BITS(8)) width8();
  frp_m32_target_capture_case #(.COUNTER_BITS(32)) width32();

  initial begin
    wait (single.done && width3.done && width8.done && width32.done);
    single.print_result();
    width3.print_result();
    width8.print_result();
    width32.print_result();
    $display("FRP_M32_TARGET_CAPTURE_TB: PASS profiles=4 matrix_cases=%0d reset_cases=%0d pressure_events=%0d observations=%0d",
      single.matrix_cases + width3.matrix_cases + width8.matrix_cases + width32.matrix_cases,
      single.reset_cases + width3.reset_cases + width8.reset_cases + width32.reset_cases,
      2*(single.PRESSURE + width3.PRESSURE + width8.PRESSURE + width32.PRESSURE),
      single.observations + width3.observations + width8.observations + width32.observations);
    $finish;
  end

  initial begin
    #4000000;
    $fatal(1, "FRP M32 target capture watchdog expired");
  end
endmodule

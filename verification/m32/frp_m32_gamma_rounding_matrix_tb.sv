// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m32_gamma_target_source.sv"

module frp_m32_gamma_rounding_matrix_tb #(parameter int CELLS = 8);
  // Between consecutive Q16.16 codes k and k+1 there is one exact half tie.
  // One input unit here is 2^-53 in random(), or 2^-36 in Q16.16 code units.
  localparam int BOUNDARIES = 131072;
  localparam int CASES_PER_BOUNDARY = 6;
  localparam int TOTAL = BOUNDARIES * CASES_PER_BOUNDARY;
  localparam int DRAWS_PER_IMAGE = 256;  // 512 of 624 checkpoint words

  logic clk = 0, rst_n = 0;
  logic load_begin = 0, load_valid = 0, request_valid = 0, bank_ready = 0;
  logic [9:0] checkpoint_index = 0;
  logic [31:0] load_word = 0;
  wire load_ready, configured, load_error, request_ready, busy, bank_valid;
  wire [CELLS*32-1:0] gamma_targets_q16;
  int unsigned checked = 0;

  frp_m32_gamma_target_source #(.CELLS(CELLS)) dut (.*);

  task automatic cycle();
    #1; clk = 1; #1; clk = 0; #1;
  endtask

  // Undo MT19937 tempering to put the desired output pair in a checkpoint.
  function automatic logic [31:0] untemper(input logic [31:0] word_out);
    logic [31:0] a, b, x;
    a = word_out ^ (word_out >> 18);
    x = a;
    repeat (2) x = a ^ ((x << 15) & 32'hefc60000);
    b = x;
    repeat (4) x = b ^ ((x << 7) & 32'h9d2c5680);
    a = x;
    repeat (2) x = a ^ (x >> 11);
    return x;
  endfunction

  function automatic logic [31:0] checkpoint_word(input int id, input bit second);
    logic [52:0] fraction;
    logic [31:0] word_out;
    int unsigned boundary_index, neighbor;
    boundary_index = id / CASES_PER_BOUNDARY;
    neighbor = (id % CASES_PER_BOUNDARY) / 2;
    // Center the three fractions on the exact tie. Repeat with both discarded-bit patterns.
    fraction = {boundary_index[16:0], 1'b1, 35'b0} - 53'd1 + 53'(neighbor);
    if (second) word_out = {fraction[25:0], {6{id[0]}}};
    else        word_out = {fraction[52:26], {5{id[0]}}};
    return untemper(word_out);
  endfunction

  function automatic int expected_code(input int id);
    int lower;
    lower = id / CASES_PER_BOUNDARY - 65536;
    case ((id % CASES_PER_BOUNDARY) / 2)
      0: return lower;                        // one unit below the tie
      1: return (lower < 0) ? lower : lower+1; // exact tie, away from zero
      default: return lower+1;                // one unit above the tie
    endcase
  endfunction

  task automatic load_image(input int first);
    load_begin = 1;
    cycle();
    load_begin = 0;
    load_valid = 1;
    for (int w = 0; w < 624; w++) begin
      #1;
      if (load_ready !== 1'b1) $fatal(1, "load stalled first=%0d word=%0d", first, w);
      if (w < 2*DRAWS_PER_IMAGE) load_word = checkpoint_word(first + w/2, w[0]);
      else load_word = '0;
      cycle();
    end
    load_valid = 0;
    if ({configured, load_error, request_ready} !== 3'b101)
      $fatal(1, "checkpoint rejected first=%0d", first);
  endtask

  task automatic check_bank(input int first);
    int want, got, waited;
    if (request_ready !== 1'b1) $fatal(1, "request stalled first=%0d", first);
    request_valid = 1;
    cycle();
    request_valid = 0;
    waited = 0;
    while (bank_valid === 1'b0) begin
      if (busy !== 1'b1 || waited >= 4*CELLS)
        $fatal(1, "draw stalled first=%0d cycles=%0d", first, waited);
      cycle();
      waited++;
    end
    if ({busy, bank_valid} !== 2'b01) $fatal(1, "missing bank first=%0d", first);
    for (int lane = 0; lane < CELLS; lane++) begin
      want = expected_code(first + lane);
      got = $signed(gamma_targets_q16[32*lane +: 32]);
      if (got !== want)
        $fatal(1, "cells=%0d case=%0d lane=%0d got=%0d expected=%0d",
               CELLS, first + lane, lane, got, want);
      checked++;
    end
    bank_ready = 1;
    cycle();
    bank_ready = 0;
    if (bank_valid !== 1'b0) $fatal(1, "bank retained first=%0d", first);
  endtask

  initial begin
    if (!(CELLS inside {8, 16, 32, 64})) $fatal(1, "unsupported CELLS=%0d", CELLS);
    cycle();
    rst_n = 1;
    cycle();
    for (int first = 0; first < TOTAL; first += DRAWS_PER_IMAGE) begin
      load_image(first);
      for (int offset = 0; offset < DRAWS_PER_IMAGE; offset += CELLS)
        check_bank(first + offset);
    end
    if (checked != TOTAL) $fatal(1, "incomplete matrix checked=%0d", checked);
    $display("PASS gamma_rounding cells=%0d boundaries=%0d targets=%0d",
             CELLS, BOUNDARIES, checked);
    $finish;
  end
endmodule

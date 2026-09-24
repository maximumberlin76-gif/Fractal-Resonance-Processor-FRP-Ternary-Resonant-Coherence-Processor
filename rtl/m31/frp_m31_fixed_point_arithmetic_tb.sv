// SPDX-License-Identifier: Apache-2.0
// FRP M31 fixed-point arithmetic boundaries. Author: Alchimist.
// Build from the repository root with --binary --timing --assert,
// -Irtl/m31 and --top-module frp_m31_fixed_point_arithmetic_tb.
// The probe calls the unchanged package. The independent oracle uses signed
// 128-bit division/remainders, not DUT rounding or saturation helpers.
// Fixed signatures were also calculated with Python arbitrary-size integers.
// Qualifies numerical primitives, not phase-interference or model equivalence.
// Nonzero rounding shifts are 14/16/30 with magnitudes at most 2^62;
// signed 64-bit extrema are used only with shift zero and saturation.
// Phase conversion preserves the implemented modulo-2^32 output semantics.

`ifndef FRP_M31_FIXED_POINT_ARITHMETIC_TB_SV
`define FRP_M31_FIXED_POINT_ARITHMETIC_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_fixed_point_pkg.sv"

package frp_m31_fixed_point_arithmetic_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic signed [31:0] left_word, right_word;
    logic signed [63:0] wide_word;
    logic [5:0] shift;
  } inputs_t;
  typedef struct packed {
    logic signed [31:0] saturated;
    logic signed [63:0] rounded;
    logic signed [31:0] product_q16, product_q30, mixed_q16;
    logic signed [31:0] down_q16, up_q30, phase_step;
  } outputs_t;
endpackage

// Verification probe only; no production module or parameter is changed.
module frp_m31_fixed_point_arithmetic_probe (
  input frp_m31_fixed_point_arithmetic_tb_pkg::inputs_t inputs,
  output frp_m31_fixed_point_arithmetic_tb_pkg::outputs_t outputs
);
  import frp_m31_fixed_point_pkg::*;
  always_comb begin
    outputs.saturated = frp_m31_sat_s32(inputs.wide_word);
    outputs.rounded = frp_m31_round_shift_s64(inputs.wide_word, 32'(inputs.shift));
    outputs.product_q16 = frp_m31_mul_q16(inputs.left_word, inputs.right_word);
    outputs.product_q30 = frp_m31_mul_q30(inputs.left_word, inputs.right_word);
    outputs.mixed_q16 = frp_m31_mul_q16_q30(inputs.left_word, inputs.right_word);
    outputs.down_q16 = frp_m31_q30_to_q16(inputs.left_word);
    outputs.up_q30 = frp_m31_q16_to_q30(inputs.left_word);
    outputs.phase_step = frp_m31_velocity_to_phase_word(inputs.left_word);
  end
endmodule

module frp_m31_fixed_point_arithmetic_tb;
  import frp_m31_fixed_point_arithmetic_tb_pkg::*;
  localparam logic signed [31:0] WORDS [0:47] = '{
    32'sh80000000, -2147483647, -2147483646,
    -1073741825, -1073741824, -1073741823,
    -536870913, -536870912, -536870911,
    -131073, -131072, -131071, -65537, -65536, -65535,
    -32769, -32768, -32767, -8193, -8192, -8191, -3, -2, -1,
    0, 1, 2, 3, 8191, 8192, 8193, 32767, 32768, 32769,
    65535, 65536, 65537, 131071, 131072, 131073,
    536870911, 536870912, 536870913,
    1073741823, 1073741824, 1073741825, 2147483646, 2147483647
  };
  localparam logic signed [63:0] WIDE_WORDS [0:18] = '{
    64'sh8000000000000000, 64'sh8000000000000001, -64'sd4611686018427387904,
    -64'sd4294967297, -64'sd4294967296, -64'sd2147483649,
    -64'sd2147483648, -64'sd2147483647, -64'sd1, 64'sd0, 64'sd1,
    64'sd2147483646, 64'sd2147483647, 64'sd2147483648,
    64'sd4294967295, 64'sd4294967296, 64'sd4611686018427387904,
    64'sh7ffffffffffffffe, 64'sh7fffffffffffffff
  };
  localparam longint signed QUOTIENTS [0:7] = '{
    0, 1, 2, 32767, 131071, 2147483646, 2147483647, 64'sd2147483648
  };
  localparam int RESIDUE_QUOTIENTS [0:2] = '{0, 1, 131071};
  localparam int SHIFTS [0:3] = '{0, 14, 16, 30};
  localparam int WRAPS [0:10] = '{-5000, -4096, -1024, -64, -1, 0, 1, 64, 1024, 4096, 5000};
  localparam int EXPECTED_COUNTS [0:5] = '{2304, 19, 98304, 144, 66, 8192};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'h3e6bc088cdd3e601, 64'hd81673c6c6e82db1, 64'h1f75182cfc635ec9,
    64'h36b23192e43db8c1, 64'h483d4db9cec63b54, 64'heb5e16fa27069f34
  };

  inputs_t inputs = '0;
  outputs_t outputs;
  int unsigned vectors = 0, checks = 0, stage_counts[6];
  logic [63:0] signature = 64'hcbf29ce484222325;
  bit residues_seen[2][16384];
  int unsigned residue_counts[2];
  bit [3:0][1:0] tie_mask = '0;
  bit [4:0] positive_saturation = 0, negative_saturation = 0;
  bit [1:0] phase_wrap_signs = 0;
  bit [3:0] shifts_seen = 0;
  bit done = 0;

  frp_m31_fixed_point_arithmetic_probe dut (.inputs, .outputs);

  function automatic wide_t rounded_division(input wide_t numerator, input int shift);
    wide_t denominator, quotient, remainder;
    denominator = 128'sd1 << shift;
    quotient = numerator / denominator;
    remainder = numerator % denominator;
    if (remainder * 2 >= denominator) quotient++;
    if (remainder * 2 <= -denominator) quotient--;
    return quotient;
  endfunction

  function automatic logic signed [31:0] clip_word(input wide_t value);
    if (value > 128'sd2147483647) return 32'sh7fffffff;
    if (value < -128'sd2147483648) return 32'sh80000000;
    return value[31:0];
  endfunction

  function automatic outputs_t predict(input inputs_t value);
    outputs_t expected;
    wide_t left_value, product, rounded_value;
    left_value = wide_t'(value.left_word);
    product = left_value * wide_t'(value.right_word);
    expected.saturated = clip_word(wide_t'(value.wide_word));
    rounded_value = rounded_division(wide_t'(value.wide_word), int'(value.shift));
    expected.rounded = rounded_value[63:0];
    expected.product_q16 = clip_word(rounded_division(product, 16));
    expected.product_q30 = clip_word(rounded_division(product, 30));
    expected.mixed_q16 = clip_word(rounded_division(product, 30));
    expected.down_q16 = clip_word(rounded_division(left_value, 14));
    expected.up_q30 = clip_word(left_value * 128'sd16384);
    rounded_value = rounded_division(left_value * 128'sd44798133900177, 32);
    expected.phase_step = rounded_value[31:0];
    return expected;
  endfunction

  function automatic logic [31:0] advance(input logic [31:0] word_value);
    logic [31:0] result;
    result = word_value ^ (word_value << 13);
    result = result ^ (result >> 17);
    return result ^ (result << 5);
  endfunction

  task automatic compare_word(input string field_name,
      input logic [63:0] actual, expected);
    checks++;
    if (actual !== expected)
      $fatal(1, "Arithmetic mismatch vector=%0d field=%s actual=%h expected=%h inputs=%h",
             vectors, field_name, actual, expected, inputs);
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic record_saturation(input int operation, input wide_t value);
    if (value > 128'sd2147483647) positive_saturation[operation] = 1;
    if (value < -128'sd2147483648) negative_saturation[operation] = 1;
  endtask

  task automatic record_tie(input int operation, input wide_t value, input int shift);
    wide_t magnitude;
    magnitude = value < 0 ? -value : value;
    if (magnitude % (128'sd1 << shift) == (128'sd1 << (shift - 1)))
      tie_mask[operation][value < 0] = 1;
  endtask

  task automatic drive(input int stage, input logic signed [31:0] left_word, right_word,
      input logic signed [63:0] wide_word, input int shift);
    outputs_t expected;
    wide_t product, phase_value, magnitude;
    if (stage < 0 || stage > 5 || !(shift inside {0, 14, 16, 30}))
      $fatal(1, "Arithmetic stimulus outside the declared profile");
    if (shift != 0 && (wide_t'(wide_word) < -(128'sd1 << 62)
        || wide_t'(wide_word) > (128'sd1 << 62)))
      $fatal(1, "Rounding stimulus exceeds the declared magnitude");
    inputs = '{left_word, right_word, wide_word, 6'(shift)};
    expected = predict(inputs);
    #1ps;
    compare_word("saturated", 64'(outputs.saturated), 64'(expected.saturated));
    compare_word("rounded", outputs.rounded, expected.rounded);
    compare_word("product_q16", 64'(outputs.product_q16), 64'(expected.product_q16));
    compare_word("product_q30", 64'(outputs.product_q30), 64'(expected.product_q30));
    compare_word("mixed_q16", 64'(outputs.mixed_q16), 64'(expected.mixed_q16));
    compare_word("down_q16", 64'(outputs.down_q16), 64'(expected.down_q16));
    compare_word("up_q30", 64'(outputs.up_q30), 64'(expected.up_q30));
    compare_word("phase_step", 64'(outputs.phase_step), 64'(expected.phase_step));
    vectors++; stage_counts[stage]++;
    for (int k = 0; k < 4; k++) if (shift == SHIFTS[k]) shifts_seen[k] = 1;
    hash_word(inputs.left_word); hash_word(inputs.right_word);
    hash_word(inputs.wide_word[63:32]); hash_word(inputs.wide_word[31:0]);
    hash_word({26'b0, inputs.shift}); hash_word(outputs.saturated);
    hash_word(outputs.rounded[63:32]); hash_word(outputs.rounded[31:0]);
    hash_word(outputs.product_q16); hash_word(outputs.product_q30);
    hash_word(outputs.mixed_q16); hash_word(outputs.down_q16);
    hash_word(outputs.up_q30); hash_word(outputs.phase_step);

    product = wide_t'(left_word) * wide_t'(right_word);
    record_saturation(0, wide_t'(wide_word));
    record_saturation(1, rounded_division(product, 16));
    record_saturation(2, rounded_division(product, 30));
    record_saturation(3, rounded_division(product, 30));
    record_saturation(4, wide_t'(left_word) * 128'sd16384);
    record_tie(0, product, 16); record_tie(1, product, 30);
    record_tie(2, wide_t'(left_word), 14);
    record_tie(3, wide_t'(left_word) * 128'sd44798133900177, 32);
    phase_value = rounded_division(wide_t'(left_word) * 128'sd44798133900177, 32);
    if (phase_value > 128'sd2147483647) phase_wrap_signs[0] = 1;
    if (phase_value < -128'sd2147483648) phase_wrap_signs[1] = 1;
    if (stage == 2) begin
      magnitude = wide_t'(left_word);
      if (magnitude < 0) magnitude = -magnitude;
      if (!residues_seen[left_word < 0][int'(magnitude % 16384)])
        residue_counts[left_word < 0]++;
      residues_seen[left_word < 0][int'(magnitude % 16384)] = 1;
    end
  endtask

  task automatic finish_stage(input int stage);
    if (stage_counts[stage] != EXPECTED_COUNTS[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Arithmetic stage mismatch stage=%0d vectors=%0d signature=%h expected=%0d/%h",
             stage, stage_counts[stage], signature, EXPECTED_COUNTS[stage], EXPECTED_SIGNATURES[stage]);
    $display("FRP_M31_FIXED_POINT_ARITHMETIC_STAGE: PASS stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
  endtask

  initial begin : qualification
    longint signed value, denominator, center;
    logic signed [31:0] left_word, right_word;
    logic [31:0] random_word;
    wide_t target;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (residues_seen[s, r]) residues_seen[s][r] = 0;
    foreach (residue_counts[s]) residue_counts[s] = 0;
    if ($bits(inputs) != 134 || $bits(outputs) != 288)
      $fatal(1, "Arithmetic probe interface width mismatch");

    for (int a = 0; a < 48; a++)
      for (int b = 0; b < 48; b++)
        drive(0, WORDS[a], WORDS[b], longint'(WORDS[a]) * longint'(WORDS[b]), 16);
    finish_stage(0);
    foreach (WIDE_WORDS[k]) drive(1, 32'(WIDE_WORDS[k]), 1, WIDE_WORDS[k], 0);
    finish_stage(1);

    // Every Q30-to-Q16 remainder for both signs, near zero and both extrema.
    for (int sign_index = 0; sign_index < 2; sign_index++)
      for (int q = 0; q < 3; q++)
        for (int residue = 0; residue < 16384; residue++) begin
          value = longint'(RESIDUE_QUOTIENTS[q]) * 16384 + longint'(residue);
          if (sign_index == 1) value = -value;
          drive(2, 32'(value), 65536, value * 65536, 16);
        end
    finish_stage(2);

    // Immediately below, at and above signed half-way rounding boundaries.
    for (int s = 1; s < 4; s++)
      for (int q = 0; q < 8; q++)
        for (int sign_index = 0; sign_index < 2; sign_index++)
          for (int offset = -1; offset <= 1; offset++) begin
            denominator = 64'sd1 << SHIFTS[s];
            value = QUOTIENTS[q] * denominator + denominator / 2 + longint'(offset);
            if (sign_index == 1) value = -value;
            drive(3, 32'(value), 32'(denominator - 1), value, SHIFTS[s]);
          end
    finish_stage(3);

    // Signed-output crossings and complete phase turns, including large wraps.
    foreach (WRAPS[k])
      for (int half_turn = 0; half_turn < 2; half_turn++)
        for (int offset = -1; offset <= 1; offset++) begin
          target = wide_t'(WRAPS[k]) * 128'sd4294967296 + wide_t'(half_turn) * 128'sd2147483648;
          center = 64'((target * 128'sd4294967296) / 128'sd44798133900177);
          value = center + longint'(offset);
          if (value < -64'sd2147483648 || value > 64'sd2147483647)
            $fatal(1, "Phase conversion stimulus outside signed 32-bit range");
          drive(4, 32'(value), 32'sh40000000, value * 65536, 16);
        end
    finish_stage(4);

    random_word = 32'h4d333146;
    repeat (8192) begin
      random_word = advance(random_word); left_word = $signed(random_word);
      random_word = advance(random_word); right_word = $signed(random_word);
      drive(5, left_word, right_word, longint'(left_word) * longint'(right_word),
            SHIFTS[stage_counts[5] % 4]);
    end
    finish_stage(5);

    foreach (residues_seen[s, r])
      if (!residues_seen[s][r]) $fatal(1, "Missing conversion remainder sign=%0d residue=%0d", s, r);
    if (vectors != 109029 || checks != 872232 || shifts_seen != 4'hf
        || residue_counts[0] != 16384 || residue_counts[1] != 16384
        || positive_saturation != 5'h1f || negative_saturation != 5'h1f
        || tie_mask != 8'hbf || phase_wrap_signs != 2'b11)
      $fatal(1, "Arithmetic coverage incomplete vectors=%0d checks=%0d shifts=%h residues=%0d/%0d saturation=%h/%h ties=%h wraps=%h",
             vectors, checks, shifts_seen, residue_counts[0], residue_counts[1],
             positive_saturation, negative_saturation, tie_mask, phase_wrap_signs);
    $display("FRP_M31_FIXED_POINT_ARITHMETIC_TB: PASS stages=6 vectors=%0d checks=%0d input_bits=134 output_bits=288 signed_remainders=32768 positive_saturation=%0d negative_saturation=%0d ties=%0d phase_wrap_signs=%0d signature=%h",
             vectors, checks, positive_saturation, negative_saturation, tie_mask, phase_wrap_signs, signature);
    done = 1;
    $finish;
  end

  initial begin
    #10000;
    if (!done) $fatal(1, "Fixed-point arithmetic watchdog");
  end
endmodule
`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent combinational contract for the unchanged arithmetic probe.
// Profiles ROUND_SHIFT=0/14/16/30 match the existing arithmetic regression.
// Both signed 32-bit operands are unrestricted. The standalone 64-bit
// rounding input is unrestricted for shift zero and bounded to +/-2^62
// otherwise, matching the documented nonzero-shift qualification domain.
// The oracle uses signed floor quotients and nonnegative remainders, with
// sign-dependent tie correction; it never calls DUT numerical helpers.
// Phase conversion retains modulo-2^32 semantics, not saturation.
// Scope: these eight primitives only; not the complete phase engine,
// real-number accuracy, physical timing or Python-model equivalence.
// Define FRP_M31_FIXED_POINT_CONTRACT_NETLIST for the same contract on a
// fresh frp_m31_fixed_point_arithmetic_netlist of the unchanged probe.

`ifndef FRP_M31_FIXED_POINT_CONTRACT_FORMAL_SV
`define FRP_M31_FIXED_POINT_CONTRACT_FORMAL_SV
`include "frp_m31_fixed_point_arithmetic_tb.sv"

module frp_m31_fixed_point_contract_formal #(
  parameter int ROUND_SHIFT = 14
) (
  input logic signed [31:0] left_word,
  input logic signed [31:0] right_word,
  input logic signed [63:0] wide_word,
  output wire [287:0] observed_outputs,
  output wire [287:0] expected_outputs,
  output wire [7:0] mismatch,
  output logic [27:0] reach
);
  import frp_m31_fixed_point_arithmetic_tb_pkg::*;
  typedef logic signed [79:0] oracle_t;
  inputs_t inputs;
  outputs_t actual, expected;
  logic signed [63:0] product;
  oracle_t phase_product, phase_rounded;
  oracle_t wide_extended;

  assign inputs = '{left_word, right_word, wide_word, 6'(ROUND_SHIFT)};
  assign observed_outputs = actual;
  assign expected_outputs = expected;

`ifdef FRP_M31_FIXED_POINT_CONTRACT_NETLIST
  frp_m31_fixed_point_arithmetic_netlist dut (.inputs(inputs), .outputs(actual));
`else
  frp_m31_fixed_point_arithmetic_probe dut (.inputs(inputs), .outputs(actual));
`endif

  // For floor quotient q and 0 <= r < 2^s, negative ties keep q;
  // positive ties increment q. This is round-nearest, ties away from zero.
  function automatic oracle_t round_reference(input oracle_t value, input int shift);
    oracle_t quotient, remainder, denominator;
    begin
      denominator = 80'sd1 << shift;
      quotient = value >>> shift;
      remainder = value - (quotient <<< shift);
      if (shift != 0 && (remainder > (denominator >>> 1)
          || (remainder == (denominator >>> 1) && value >= 0)))
        quotient = quotient + 80'sd1;
      return quotient;
    end
  endfunction

  // Exact sign-extension recognition rather than DUT signed-rail comparisons.
  function automatic logic signed [31:0] clip_reference(input oracle_t value);
    if (value[79:31] == {49{value[31]}}) return value[31:0];
    return value[79] ? 32'sh80000000 : 32'sh7fffffff;
  endfunction

  initial begin
    if (!(ROUND_SHIFT == 0 || ROUND_SHIFT == 14
        || ROUND_SHIFT == 16 || ROUND_SHIFT == 30))
      $fatal(1, "Unsupported fixed-point formal shift profile");
  end

  always_comb begin
    product = $signed(left_word) * $signed(right_word);
    wide_extended = oracle_t'(wide_word);
    phase_product = oracle_t'(left_word) * 80'sd44798133900177;
    phase_rounded = round_reference(phase_product, 32);
    expected.saturated = clip_reference(wide_extended);
    expected.rounded = 64'(round_reference(wide_extended, ROUND_SHIFT));
    expected.product_q16 = clip_reference(round_reference(oracle_t'(product), 16));
    expected.product_q30 = clip_reference(round_reference(oracle_t'(product), 30));
    expected.mixed_q16 = expected.product_q30;
    expected.down_q16 = clip_reference(round_reference(oracle_t'(left_word), 14));
    expected.up_q30 = clip_reference(oracle_t'(left_word) * 80'sd16384);
    expected.phase_step = phase_rounded[31:0];
  end

  if (ROUND_SHIFT != 0) begin : rounding_domain
    always_comb begin
      a_declared_magnitude: assume (wide_word >= -64'sd4611686018427387904
        && wide_word <= 64'sd4611686018427387904);
    end
  end

  assign mismatch = {
    actual.phase_step != expected.phase_step,
    actual.up_q30 != expected.up_q30,
    actual.down_q16 != expected.down_q16,
    actual.mixed_q16 != expected.mixed_q16,
    actual.product_q30 != expected.product_q30,
    actual.product_q16 != expected.product_q16,
    actual.rounded != expected.rounded,
    actual.saturated != expected.saturated
  };

  always_comb begin
    a_saturated: assert (!mismatch[0]);
    a_rounded: assert (!mismatch[1]);
    a_product_q16: assert (!mismatch[2]);
    a_product_q30: assert (!mismatch[3]);
    a_mixed_q16: assert (!mismatch[4]);
    a_down_q16: assert (!mismatch[5]);
    a_up_q30: assert (!mismatch[6]);
    a_phase_step: assert (!mismatch[7]);
  end

  // Separate satisfiability targets, not proof assumptions.
  always_comb begin
    reach = '0;
    reach[0] = wide_word == 64'sd2147483648;
    reach[1] = wide_word == -64'sd2147483649;
    reach[2] = wide_word == 64'sd2147483647;
    reach[3] = wide_word == -64'sd2147483648;
    reach[4] = ROUND_SHIFT == 0 && wide_word == 64'sh8000000000000000;
    reach[5] = ROUND_SHIFT == 0 && wide_word == 64'sh7fffffffffffffff;
    if (ROUND_SHIFT != 0) begin
      reach[6] = wide_extended == (80'sd1 << (ROUND_SHIFT - 1));
      reach[7] = wide_extended == -(80'sd1 << (ROUND_SHIFT - 1));
      reach[8] = wide_extended == (80'sd1 << (ROUND_SHIFT - 1)) - 1;
      reach[9] = wide_extended == -(80'sd1 << (ROUND_SHIFT - 1)) - 1;
    end
    reach[10] = expected.product_q16 == 32'sh7fffffff;
    reach[11] = expected.product_q16 == 32'sh80000000;
    reach[12] = expected.product_q30 == 32'sh7fffffff;
    reach[13] = expected.product_q30 == 32'sh80000000;
    reach[14] = left_word == 32'sd8192;
    reach[15] = left_word == -32'sd8192;
    reach[16] = left_word == 32'sd131072;
    reach[17] = left_word == -32'sd131073;
    reach[18] = left_word == -32'sd131072;
    reach[19] = left_word == 32'sd131071;
    reach[20] = left_word == 32'sd655360;
    reach[21] = left_word == -32'sd655360;
    reach[22] = left_word == 32'sh80000000;
    reach[23] = left_word == 0 && right_word == 0 && wide_word == 0;
    reach[24] = left_word < 0 && right_word > 0;
    reach[25] = left_word < 0 && right_word < 0;
    reach[26] = left_word == 32'sh80000000 && right_word == 32'sh80000000;
    reach[27] = left_word == 32'sh80000000 && right_word == 32'sh7fffffff;
  end
endmodule
`endif

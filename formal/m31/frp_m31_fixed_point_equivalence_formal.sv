// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Direct equivalence of all eight arithmetic output fields (288 bits).
// Load a fresh frp_m31_fixed_point_arithmetic_netlist with read_verilog
// -icells before reading this harness with read_slang. Both implementations
// receive the same packed inputs; no internal equality is assumed.
// ROUND_SHIFT=0/14/16/30 matches the independent arithmetic contract.
// Both signed 32-bit operands are unrestricted. The signed 64-bit rounding
// input is unrestricted at shift zero and bounded to inclusive +/-2^62
// otherwise. This is a combinational two-state proof with no clock/reset.
// Normalize both arithmetic cones with alumacc and opt -full before SAT.
// Reach bits describe separate satisfiability targets, never assumptions.
// Independent numerical correctness belongs to the fixed-point contract;
// this harness proves preservation by synthesis within the same domain.
// Phase conversion retains modulo-2^32 semantics, not saturation.
// Scope excludes the complete phase engine, physical timing, four-state
// semantics, real-number accuracy and Python-model equivalence.

`ifndef FRP_M31_FIXED_POINT_EQUIVALENCE_FORMAL_SV
`define FRP_M31_FIXED_POINT_EQUIVALENCE_FORMAL_SV
`include "frp_m31_fixed_point_arithmetic_tb.sv"

module frp_m31_fixed_point_equivalence_formal #(
  parameter int ROUND_SHIFT = 14
) (
  input logic signed [31:0] left_word,
  input logic signed [31:0] right_word,
  input logic signed [63:0] wide_word,
  output wire [287:0] rtl_outputs,
  output wire [287:0] netlist_outputs,
  output wire [7:0] mismatch,
  output logic [27:0] reach
);
  import frp_m31_fixed_point_arithmetic_tb_pkg::*;
  wire inputs_t inputs;
  wire outputs_t rtl_observed, netlist_observed;
  wire signed [63:0] half_value;

  assign inputs = '{left_word, right_word, wide_word, 6'(ROUND_SHIFT)};
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;
  assign half_value = (64'sd1 << ROUND_SHIFT) >>> 1;

  frp_m31_fixed_point_arithmetic_probe rtl_dut (
    .inputs(inputs), .outputs(rtl_observed)
  );
  frp_m31_fixed_point_arithmetic_netlist netlist_dut (
    .inputs(inputs), .outputs(netlist_observed)
  );

  initial begin
    if (!(ROUND_SHIFT == 0 || ROUND_SHIFT == 14
        || ROUND_SHIFT == 16 || ROUND_SHIFT == 30))
      $fatal(1, "Unsupported fixed-point equivalence shift profile");
  end

  if (ROUND_SHIFT != 0) begin : rounding_domain
    always_comb begin
      a_declared_magnitude: assume (wide_word >= -64'sd4611686018427387904
        && wide_word <= 64'sd4611686018427387904);
    end
  end

  // Bit zero compares saturated; bit seven compares phase_step.
  // Each comparison covers the entire field, including sign/high bits.
  assign mismatch = {
    rtl_observed.phase_step != netlist_observed.phase_step,
    rtl_observed.up_q30 != netlist_observed.up_q30,
    rtl_observed.down_q16 != netlist_observed.down_q16,
    rtl_observed.mixed_q16 != netlist_observed.mixed_q16,
    rtl_observed.product_q30 != netlist_observed.product_q30,
    rtl_observed.product_q16 != netlist_observed.product_q16,
    rtl_observed.rounded != netlist_observed.rounded,
    rtl_observed.saturated != netlist_observed.saturated
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

  always_comb begin
    reach = '0;
    reach[0] = wide_word == 64'sd2147483648;
    reach[1] = wide_word == -64'sd2147483649;
    reach[2] = wide_word == 64'sd2147483647;
    reach[3] = wide_word == -64'sd2147483648;
    reach[4] = ROUND_SHIFT == 0 && wide_word == 64'sh8000000000000000;
    reach[5] = ROUND_SHIFT == 0 && wide_word == 64'sh7fffffffffffffff;
    if (ROUND_SHIFT != 0) begin
      reach[6] = wide_word == half_value;
      reach[7] = wide_word == -half_value;
      reach[8] = wide_word == half_value - 1;
      reach[9] = wide_word == -half_value - 1;
    end
    reach[10] = rtl_observed.product_q16 == 32'sh7fffffff;
    reach[11] = rtl_observed.product_q16 == 32'sh80000000;
    reach[12] = rtl_observed.product_q30 == 32'sh7fffffff;
    reach[13] = rtl_observed.product_q30 == 32'sh80000000;
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

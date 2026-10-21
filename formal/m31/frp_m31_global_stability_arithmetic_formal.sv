// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Arithmetic contracts for the unchanged M31 global stability RTL.
// Reference rounding uses floor quotients and sign-dependent tie correction.
// Reference saturation recognizes exact signed extension.
// Compression is composed from checked square/round and gain/sum stages.
// PROFILE 0: three means and active-zero fraction; no cutpoints.
// PROFILE 1: compression argument; cut previous_margin_q16 and
//            mean_thermal_overload_q16 to unrestricted signed 32-bit values.
// PROFILE 2: clipping, numerator, ROM address; cut compression_arg_q16.
// PROFILE 3: effective coherence and mixed-product lemma;
//            cut next_coherence_compression_q30.
// PROFILE 4: capacity; cut next_effective_coherence_q30,
//            neutral_fraction_q30 and mean_frequency_lag_q16.
// PROFILE 5: Q16 multiplication lemma on two arbitrary signed operands.
// The thermal-square contract composes this lemma with the actual operands.
// Capacity composes the Q16 and mixed-product lemmas with its four gains.
// Each cut replaces the driver for both DUT and reference consumers.
// Preserve all logic downstream of the listed boundaries.
// Reach bits describe local arithmetic domains for the selected profile.
// ROM address mapping is checked here; table values retain their RTL source.

`ifndef FRP_M31_GLOBAL_STABILITY_ARITHMETIC_FORMAL_SV
`define FRP_M31_GLOBAL_STABILITY_ARITHMETIC_FORMAL_SV
`include "frp_m31_global_stability.sv"

module frp_m31_global_stability_arithmetic_formal #(
  parameter int CELLS = 8,
  parameter int PROFILE = 0
) (
  input logic clk, rst_n, tick_enable,
  input logic [(CELLS*2)-1:0] retained_state,
  input logic signed [31:0] raw_phase_coherence_q30,
  input logic signed [31:0] cluster_coherence_q30,
  input logic [(CELLS*32)-1:0] heat_q16,
  input logic [(CELLS*32)-1:0] thermal_overload_q16,
  input logic [(CELLS*32)-1:0] frequency_lag_q16,
  input logic signed [31:0] switch_load_q16,
  output wire [13:0] mismatch,
  output logic [7:0] reach
);
  wire signed [31:0] mean_heat_q16, mean_thermal_overload_q16;
  wire signed [31:0] mean_frequency_lag_q16, neutral_fraction_q30;
  wire signed [31:0] compression_arg_q16;
  wire signed [31:0] next_coherence_compression_q30, next_effective_coherence_q30;
  wire signed [31:0] next_coherence_capacity_q16, next_pressure_q16;
  wire signed [31:0] next_stability_margin_q16;
  wire next_stable;
  wire signed [31:0] coherence_compression_q30, effective_coherence_q30;
  wire signed [31:0] coherence_capacity_q16, pressure_q16;
  wire signed [31:0] stability_margin_q16, previous_margin_q16;
  wire stable;
  frp_m31_global_stability #(.CELLS(CELLS)) dut (.*);

  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Unsupported global stability cell count");
    if (PROFILE < 0 || PROFILE > 5)
      $fatal(1, "Unsupported global stability arithmetic profile");
  end

  function automatic logic signed [63:0] widen(input logic signed [31:0] x);
    return {{32{x[31]}}, x};
  endfunction

  function automatic logic signed [63:0] rounded(
    input logic signed [63:0] x, input int shift
  );
    logic signed [63:0] quotient;
    logic [63:0] remainder, half_value;
    quotient = x >>> shift;
    remainder = $unsigned(x) & ((64'd1 << shift) - 64'd1);
    half_value = 64'd1 << (shift - 1);
    if (remainder > half_value || (remainder == half_value && !x[63]))
      quotient = quotient + 64'sd1;
    return quotient;
  endfunction

  function automatic logic signed [31:0] clipped(input logic signed [63:0] x);
    if (x[63:31] == {33{x[31]}}) return x[31:0];
    return x[63] ? 32'sh80000000 : 32'sh7fffffff;
  endfunction

  function automatic logic signed [31:0] product_reference(
    input logic signed [31:0] a, b, input int shift
  );
    logic signed [63:0] product;
    product = a * b;
    return clipped(rounded(product, shift));
  endfunction

  logic signed [63:0] heat_sum, overload_sum, lag_sum, zero_count;
  always_comb begin
    heat_sum = 0;
    overload_sum = 0;
    lag_sum = 0;
    zero_count = 0;
    for (int i = 0; i < CELLS; i++) begin
      heat_sum += widen($signed(heat_q16[i*32 +: 32]));
      overload_sum += widen($signed(thermal_overload_q16[i*32 +: 32]));
      lag_sum += widen($signed(frequency_lag_q16[i*32 +: 32]));
      if (retained_state[i*2 +: 2] == 2'b00)
        zero_count = zero_count + 64'sd1;
    end
  end

  logic signed [63:0] margin_distance, margin_square;
  logic signed [31:0] expected_margin_square, expected_thermal_square;
  logic signed [31:0] expected_argument, expected_capacity;
  logic signed [63:0] argument_sum, capacity_sum;
  wire signed [31:0] margin_square_stage = dut.compression_argument.margin_sq_q16;
  wire signed [31:0] thermal_square_stage = dut.compression_argument.thermal_sq_q16;
  always_comb begin
    margin_distance = 64'sd16384 - widen(previous_margin_q16);
    if (margin_distance < 0) margin_distance = 0;
    margin_square = margin_distance * margin_distance;
    expected_margin_square = clipped(rounded(margin_square, 16));
    expected_thermal_square = frp_m31_fixed_point_pkg::frp_m31_mul_q16(
      mean_thermal_overload_q16, mean_thermal_overload_q16);
    argument_sum = widen(product_reference(32'sd196608, thermal_square_stage, 16))
      + widen(product_reference(32'sd98304, margin_square_stage, 16));
    expected_argument = clipped(argument_sum);
    capacity_sum = 64'sd53740
      + widen(frp_m31_fixed_point_pkg::frp_m31_mul_q16_q30(
        32'sd22282, next_effective_coherence_q30))
      + widen(frp_m31_fixed_point_pkg::frp_m31_mul_q16_q30(
        32'sd10486, cluster_coherence_q30))
      + widen(frp_m31_fixed_point_pkg::frp_m31_mul_q16_q30(
        32'sd5243, neutral_fraction_q30))
      - widen(frp_m31_fixed_point_pkg::frp_m31_mul_q16(
        32'sd6554, mean_frequency_lag_q16));
    expected_capacity = clipped(capacity_sum);
  end

  logic [31:0] expected_clip;
  logic [63:0] address_product, expected_numerator, expected_address;
  always_comb begin
    if (compression_arg_q16 < 0) expected_clip = 0;
    else if (compression_arg_q16 > 32'sd524288) expected_clip = 32'd524288;
    else expected_clip = $unsigned(compression_arg_q16);
    address_product = {32'd0, expected_clip} * 64'd4095;
    expected_numerator = address_product + 64'd262144;
    expected_address = (address_product >> 19)
      + ((address_product[18:0] >= 19'd262144) ? 64'd1 : 64'd0);
  end

  assign mismatch[0] = mean_heat_q16 != clipped(rounded(heat_sum, $clog2(CELLS)));
  assign mismatch[1] = mean_thermal_overload_q16 != clipped(rounded(overload_sum, $clog2(CELLS)));
  assign mismatch[2] = mean_frequency_lag_q16 != clipped(rounded(lag_sum, $clog2(CELLS)));
  assign mismatch[3] = widen(neutral_fraction_q30) != (zero_count << (30-$clog2(CELLS)));
  assign mismatch[4] = compression_arg_q16 != expected_argument;
  assign mismatch[5] = dut.clipped_arg_q16 != expected_clip;
  assign mismatch[6] = dut.address_numerator != expected_numerator;
  assign mismatch[7] = {52'd0, dut.rom_address} != expected_address;
  assign mismatch[8] = next_effective_coherence_q30 != product_reference(
    raw_phase_coherence_q30, next_coherence_compression_q30, 30);
  assign mismatch[9] = next_coherence_capacity_q16 != expected_capacity;
  assign mismatch[10] = margin_square_stage != expected_margin_square;
  assign mismatch[11] = thermal_square_stage != expected_thermal_square;
  assign mismatch[12] = frp_m31_fixed_point_pkg::frp_m31_mul_q16(
    raw_phase_coherence_q30, cluster_coherence_q30)
    != product_reference(raw_phase_coherence_q30, cluster_coherence_q30, 16);
  assign mismatch[13] = frp_m31_fixed_point_pkg::frp_m31_mul_q16_q30(
    raw_phase_coherence_q30, next_coherence_compression_q30)
    != product_reference(raw_phase_coherence_q30, next_coherence_compression_q30, 30);

  if (PROFILE == 0) begin : means_contract
    always_comb begin
      a_mean_heat: assert (!mismatch[0]);
      a_mean_overload: assert (!mismatch[1]);
      a_mean_lag: assert (!mismatch[2]);
      a_active_zero_fraction: assert (!mismatch[3]);
    end
  end else if (PROFILE == 1) begin : argument_contract
    always_comb begin
      a_margin_square: assert (!mismatch[10]);
      a_thermal_square: assert (!mismatch[11]);
      a_compression_argument: assert (!mismatch[4]);
    end
  end else if (PROFILE == 2) begin : address_contract
    always_comb begin
      a_argument_clip: assert (!mismatch[5]);
      a_address_numerator: assert (!mismatch[6]);
      a_rom_address: assert (!mismatch[7]);
    end
  end else if (PROFILE == 3) begin : effective_contract
    always_comb begin
      a_effective_coherence: assert (!mismatch[8]);
      a_mixed_product: assert (!mismatch[13]);
    end
  end else if (PROFILE == 4) begin : capacity_contract
    always_comb a_capacity: assert (!mismatch[9]);
  end else begin : q16_lemma
    always_comb a_q16_product: assert (!mismatch[12]);
  end

  wire signed [31:0] right_operand = PROFILE == 5
    ? cluster_coherence_q30 : next_coherence_compression_q30;

  always_comb begin
    reach = '0;
    case (PROFILE)
      0: begin
        reach[0] = heat_sum == 64'(CELLS/2);
        reach[1] = heat_sum == -64'(CELLS/2);
        reach[2] = heat_q16 == {CELLS{32'h80000000}};
        reach[3] = heat_q16 == {CELLS{32'h7fffffff}};
        reach[4] = retained_state == '0;
        reach[5] = retained_state == {CELLS{2'b10}};
        reach[6] = overload_sum == 64'(CELLS/2);
        reach[7] = lag_sum == -64'(CELLS/2);
      end
      1: begin
        reach[0] = previous_margin_q16 == 32'sh80000000;
        reach[1] = previous_margin_q16 == 32'sh7fffffff;
        reach[2] = previous_margin_q16 == 32'sd16383;
        reach[3] = previous_margin_q16 == 32'sd16384;
        reach[4] = previous_margin_q16 == 32'sd16385;
        reach[5] = mean_thermal_overload_q16 == 32'sh80000000;
        reach[6] = mean_thermal_overload_q16 == 32'sh7fffffff;
        reach[7] = previous_margin_q16 == 0 && mean_thermal_overload_q16 == 0;
      end
      2: begin
        reach[0] = compression_arg_q16 == 32'sh80000000;
        reach[1] = compression_arg_q16 == -32'sd1;
        reach[2] = compression_arg_q16 == 0;
        reach[3] = compression_arg_q16 == 1;
        reach[4] = compression_arg_q16 == 32'sd524287;
        reach[5] = compression_arg_q16 == 32'sd524288;
        reach[6] = compression_arg_q16 == 32'sd524289;
        reach[7] = compression_arg_q16 == 32'sh7fffffff;
      end
      3, 5: begin
        reach[0] = raw_phase_coherence_q30 == 32'sh80000000
          && right_operand == 32'sh80000000;
        reach[1] = raw_phase_coherence_q30 == 32'sh7fffffff
          && right_operand == 32'sh7fffffff;
        reach[2] = raw_phase_coherence_q30 == 0;
        reach[3] = raw_phase_coherence_q30 == 1
          && right_operand == (PROFILE == 5 ? 32'sd32768 : 32'sd536870912);
        reach[4] = raw_phase_coherence_q30 == -32'sd1
          && right_operand == (PROFILE == 5 ? 32'sd32768 : 32'sd536870912);
        reach[5] = raw_phase_coherence_q30 == 32'sh80000000
          && right_operand == (PROFILE == 5 ? 32'sd65536 : 32'sd1073741824);
        reach[6] = raw_phase_coherence_q30 == 32'sh7fffffff
          && right_operand == (PROFILE == 5 ? 32'sd65536 : 32'sd1073741824);
        reach[7] = raw_phase_coherence_q30 == 32'sh80000000
          && right_operand == 32'sh7fffffff;
      end
      4: begin
        reach[0] = next_effective_coherence_q30 == 32'sh80000000;
        reach[1] = next_effective_coherence_q30 == 32'sh7fffffff;
        reach[2] = cluster_coherence_q30 == 32'sh80000000;
        reach[3] = cluster_coherence_q30 == 32'sh7fffffff;
        reach[4] = neutral_fraction_q30 == 0;
        reach[5] = neutral_fraction_q30 == 32'sd1073741824;
        reach[6] = mean_frequency_lag_q16 == 32'sh80000000;
        reach[7] = mean_frequency_lag_q16 == 32'sh7fffffff;
      end
      default: reach = '0;
    endcase
  end
endmodule
`endif

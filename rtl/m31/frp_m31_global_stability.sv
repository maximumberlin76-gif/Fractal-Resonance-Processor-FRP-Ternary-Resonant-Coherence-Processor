// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Source: QuantizedReferenceShadowProcessor.update_global_stability,
// frp_prototype_v1_7_0.py. Q16.16 and Q2.30 use half-away rounding.
// Inputs describe one completed phase/thermal/retained-state snapshot.
// Combinational next_* outputs use the previous committed C-minus-P.
// tick_enable commits one snapshot and advances the margin history.
// On hold, registered outputs/history retain their values; next_* follows inputs.
// Reset initializes history to Q16(0.60), C to Q16(1.0), P to Q16(0.05),
// compression to Q30(1.0), and sampled effective coherence to zero.
// State encoding: 00 = active zero, 01 = +1, 11 = -1; 10 is reserved.
// EXP_NEG_Q30 is the reference 4096-word table on Q16 [0, 524288].
// ROM_D4 and ROM_SEEDS reconstruct its exact integers at elaboration.

`ifndef FRP_M31_GLOBAL_STABILITY_SV
`define FRP_M31_GLOBAL_STABILITY_SV

`timescale 1ns / 1ps
`include "frp_m31_fixed_point_pkg.sv"

module frp_m31_global_stability #(
  parameter int CELLS = 8
) (
  input  logic clk,
  input  logic rst_n,
  input  logic tick_enable,
  input  logic [(CELLS*2)-1:0] retained_state,
  input  logic signed [31:0] raw_phase_coherence_q30,
  input  logic signed [31:0] cluster_coherence_q30,
  input  logic [(CELLS*32)-1:0] heat_q16,
  input  logic [(CELLS*32)-1:0] thermal_overload_q16,
  input  logic [(CELLS*32)-1:0] frequency_lag_q16,
  input  logic signed [31:0] switch_load_q16,

  output logic signed [31:0] mean_heat_q16,
  output logic signed [31:0] mean_thermal_overload_q16,
  output logic signed [31:0] mean_frequency_lag_q16,
  output logic signed [31:0] neutral_fraction_q30,
  output logic signed [31:0] compression_arg_q16,

  output wire signed [31:0] next_coherence_compression_q30,
  output wire signed [31:0] next_effective_coherence_q30,
  output logic signed [31:0] next_coherence_capacity_q16,
  output logic signed [31:0] next_pressure_q16,
  output logic signed [31:0] next_stability_margin_q16,
  output wire next_stable,

  output logic signed [31:0] coherence_compression_q30,
  output logic signed [31:0] effective_coherence_q30,
  output logic signed [31:0] coherence_capacity_q16,
  output logic signed [31:0] pressure_q16,
  output logic signed [31:0] stability_margin_q16,
  output logic stable,
  output logic signed [31:0] previous_margin_q16
);

  import frp_m31_fixed_point_pkg::*;

  localparam int MEAN_SHIFT = $clog2(CELLS);
  localparam logic signed [31:0] BASE_CAPACITY_Q16 = 32'sd53740;
  localparam logic signed [31:0] GLOBAL_GAIN_Q16 = 32'sd22282;
  localparam logic signed [31:0] CLUSTER_GAIN_Q16 = 32'sd10486;
  localparam logic signed [31:0] NEUTRAL_GAIN_Q16 = 32'sd5243;
  localparam logic signed [31:0] LAG_GAIN_Q16 = 32'sd6554;
  localparam logic signed [31:0] THERMAL_COMPRESSION_GAIN_Q16 = 32'sd196608;
  localparam logic signed [31:0] MARGIN_COMPRESSION_GAIN_Q16 = 32'sd98304;

  localparam logic [16367:0] ROM_D4 = {
    128'ha5d2e11fe4ef11e2e11e2e2e11ff11e2,
    128'he2e2e12b5ef2e11ff2e2e2e2ff11ff2e,
    128'h2e2ff2e2ff2e2e3b6b21f0f2e2ff2ff2,
    128'hff2ff3b6b3e2f0f3b6b3ff3b6c02ff2f,
    128'h00f2f0f3c3ff3c3ff3c4c22d03c3f00f,
    128'h3c30d3ff3d03c4c30d3f000000000000,
    128'h00000001d3f1d4c4d03d11d30d4d1000,
    128'h1d4d11d4c4d2d4d101e1001e11d4d2e1,
    128'h001e2e101e11e11e11e2d5a5ee4ef11e,
    128'h2e2e11e2e2e2e2e12b5ef2e2e2ff12b6,
    128'ha6b3e2e2f0f11f0f2ff2ff2ff2f0f2ff,
    128'h3c3e20c6c02f0f3c3ff3c4c3f0f3d020,
    128'hd3f000000f3d10f3d1000000001d4d03,
    128'hd101d4d1001d4d2d4d101e101e101e2d,
    128'h4ee4ee4ef101fe4ef11e2e2e2e2e11ff,
    128'h2e2e2e2ff2e2ff2e2f0f2e2f0f2ff2f0,
    128'hf2f0f3c3ff3c3f00f3c3f01c6c10f3d1,
    128'hf3d03d1000001d4c4d101d4d101e1001,
    128'he11e101e11e2d4ef11e11ff11e2e2e2e,
    128'h2e2e3b5e0f12b6b3ff2ff2f0f2f0f3c2,
    128'h2d020d22d03c4c4c3f1d3f1d4c4d03d1,
    128'h1d4d1001d4ee4d11e11d5a5d2e2e11e2,
    128'he2e12b6a6b21ff2e3b6b3ff2ff2f00f2,
    128'hf00f3c3f000000f3d1f3d1001d4c4d10,
    128'h1e1001e11d5a5d2e11e2e11ff11ff2e2,
    128'he2ff2ff2ff2f0f3c22c4c3f0f3d03c4c,
    128'h4d03d10001d4d101e101e11e11e2e11e,
    128'h2e2e2ff11ff2ff2f0f2e3c3f0f3c3f1d,
    128'h3e3d1001d30d4d101d4d2e101e2e11e1,
    128'h2b5ef2e2e3b6b3e2f00f2f00f3c3f1d3,
    128'hf01d4c4d101d4d11e11e2d5a5ef12b5e,
    128'h0f12c22c3ff2f0000f3c4c4c4c4d101d,
    128'h4d2d4d2e11e2e11ff2e2e3b6b3ff3c3f,
    128'hf3d03c30e03d1001d4ee4d2e11e2e2e2,
    128'he2ff2ff3c22c3f000000000001d4d2d4,
    128'hee4ef11e2e2ff2e3c22c3f0f3d03c4c4,
    128'hd101d4ee4d2e11ff11ff2e3c22c4c3e3,
    128'hd10000001e101e11e11ff2e2e2f0f2f0,
    128'h0f3c4c4d03d2d4d11e11fe5b22b6b3ff,
    128'h3c3f000001d4c5a5c5b202b5e0f2e20c,
    128'h6c03d03c4d11d4d2e11ff11ff2f0f2f0,
    128'h00000001e101e11e2ff11f0f3c3f0f3d,
    128'h101d4d2d5a5ef2e3b6b3f000000001d4,
    128'hef102b5e0f2ff3c3f1d30d4ee4d2e2e2,
    128'he3b6c020d3f1d4d11e11ff11f0f20d22,
    128'hd11d30e2e11ff110c6b4c4c4c4d2d5a5,
    128'hef2e2f0f3d03c4d11e11e2ff2e3c3f1d,
    128'h30d4d2e2e12b6c02f0001d4d2e11ff2e,
    128'h3c3f0001e101e12b6b3f000f3ee4d11f,
    128'hf12c3f000f4a5d11e2f0f2e3d1001d4e,
    128'hf2e2ff20d30d4d2e11ff2f000f3d2e10,
    128'h1f0f2e3d1f3ee4ef12c3e3c4d101e11f,
    128'hf2f000001d5a5e0f2f000001e2e2ff2f,
    128'h1d30d5a5e0f2ff3d2d4d2e2f0f3c4d10,
    128'h1ff2e20d30e101ff2ff3d03ee5a6b3e3,
    128'hd1001ff110c6de30e2e2f0f3d1002b6b,
    128'h3e3d11d5a6b3f0001d5b22c3f01e11e2,
    128'hff3d1001ff2ff3d11e11f0f3d101e2ff,
    128'h3c4d101f0f3c4d11e2f0f3d11ff12c4d,
    128'h101ff2f01d4ef12c4c4ee5b3f0001e2e,
    128'h3c4d101ff3c30e2e2ff3d2d5b22d1002,
    128'hb6b4c4d2e3c3f01e2f0f3d2e12c30e11,
    128'he3c4c4d3b6c03ef2e3c4d12c22d2d5b3,
    128'hf001e2ff3d2e2e3c4d2ff2f1e2e2f01d,
    128'h5b3f1d4ef20d4ef2f001e2f01d4e0f3d,
    128'h11f00001ff3d102c3f1e2ff3d2e2f001,
    128'hff20e11e3d11e2f1d5b22d2e2ff3ef2f,
    128'h01e2e3d11ff3d2e2f1e110d4d2f01e11,
    128'h0d4e0f3d12c30ff2f01f0f3ef2f1e2e3,
    128'hd12c30e12d11ff3d12c4d2e3c5b3e4b2,
    128'h2d102d101f01e2f0010d4d2f01e3c4ef,
    128'h20e2f01e20d5b3f1f001e20e12c4e0f4,
    128'ha6b4e0f3d3c4d2f01f001ff3ef3d2e3d,
    128'h12c5a6c2e20e2f01e3d2f01e20e2f02c,
    128'h30e3d110e2e3ef20ff3d3c4d20e20d5b,
    128'h4d3c4e001f01f001f1e3c5b30f0010d5,
    128'hb4d20e20d5c110d5b4e001f1e2f1f1e2,
    128'h0e20e20e20e20e3d2e4b3f2c4e01f002,
    128'hc5c04c110d5c2e3e001f1f002d2f1e3d,
    128'h20f001f2c4d3d20ff3fd4e1f002d20e2,
    128'hf2d110f1e2f2d12d3d12ef4b300e2f10,
    128'he3d20e3d3d3d13a796df3e010e2f2d20,
    128'he21c5b4e02d2f1f10e20f02d20f010e3,
    128'hd3e01f2c4e10e20f2c4e1f10e20f10e3,
    128'hd3e01f2d2f2d20f1f1f1f10e4b4e02e0,
    128'h03b4e02d3d3e1e4b4ff010f03b31d3d3,
    128'he02d3d3fe200e4b5c20f10e4c13b4ff0,
    128'h2e0100e3fe3fe21d3e02d4b5c21c5d01,
    128'h1c5d010f2e010f2e011d21d21d3e1f2d,
    128'h4b5d0100f2d21e02e1f2e02e2d21e02e,
    128'h03c21c6a5c3e100f100f11d3e1000f1f,
    128'h3c21d4b5d100f1000f11e02ff11d21ff,
    128'h10f3b5ee30c6a5d100f2fe4d10f2ff11,
    128'he03d02ff2e11e03d02f0f2e2e11d4ee3,
    128'hf1d3f000f2f0f2ff2ff3b6b3e2f0f2ff,
    128'h3c4c3f00001e101e2e2e2f0000001e2e,
    128'h2e3c4d101e3c3e4a5d2f0001e12c30e2,
    128'he3c4d11f1d4ef3c4e0f3d2e3d12c30e2,
    128'hf1e2f01e3d12c4ef3d2f01e3ef20e20e,
    128'h20d5c2e3d20e13a6c2e4a796c110f01e,
    128'h3e01f01f1f1e3e1e20e4b4e01f10e20f,
    128'h1f1f1f02d3d3d3e01f2d20f1f10e3fe3,
    128'hd3fe200f03b31e011c5c3d3ff011d21d,
    128'h3d4c200f10f1000e4c21d3e2e011e10f,
    128'h1000f11d3ff11d3ff11e03c3e11e10f3,
    128'hc21fe5a40e03c4c3ff3c22c3ff2f00f2,
    128'hf1d3f1d4ee5a6b30d30e11f00001e3c3,
    128'hf1ff2f1e3c3f2c3f1f001e3d110e12d2,
    128'he3ef3d2f1f002d2f02c5b4e01f02d2f1,
    128'h0e20f1f02d20f02d3e002fd5df4c3c6a,
    128'h31d3e02e02d3fe3e2d3e1f2e1f2d4c3e,
    128'h1f2ff03c21e10f2fe4d1f2f0f11e11d3,
    128'h0d4c4c30d3f001d4d102b5e000001ff1,
    128'h2ee4ef3d12c30e2f1e2f1e3c5b4d20e2,
    128'hf10d5b5b4e002ef3fd5b5df21d20f02d,
    128'h3e02d3e011d20f2d3fe3e2d3e2d3e11d,
    128'h3e11d3ff2d4c4c3ff11e2e101e1001e2,
    128'he11e3c3f001e2f0001ff3d12d102c4e0,
    128'h01f1e20e3d2f2c5b4e010f010e4b4e1f,
    128'h10f1f100e3fe4b697b21d21d4d011e03,
    128'hd012b5d2d4d11d4d11e11ff3c30e2e3c,
    128'h4ef20e12ee5c2e3ef3d3ef3d3e01f1f1,
    128'hf2c5c3d3e02e02e1f11d21d4c21e03c3,
    128'he11e11d30d4d03d2e11ff3c4ef2f01f0,
    128'h01f1d5c2e4a7a23b4e1e3e1f1f1f2d3f,
    128'he21e1f11d3e101d3e2e2e101e101e11e,
    128'h3c3f1e2e3ee5c2e20f002c5c12d3d20f,
    112'h10f02d3fe3fe4c21e1f3b5d11d4c
  };

  localparam logic [511:0] ROM_SEEDS = {
    128'h002850c1002864ef0028792800288d6b,
    128'h012a09e0012a9f14012b3492012bca5b,
    128'h089b4cb1089f9bb008a3ecd708a84027,
    128'h3fa041e53fc01bf93fe0060040000000
  };
  logic [31:0] exp_rom [0:4095];

  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32))
      $fatal(1, "FRP global stability requires 8, 16 or 32 cells");
  end

  for (genvar page = 0; page < 4; page = page + 1) begin : g_rom_page
    localparam logic signed [31:0] SEED_0 = ROM_SEEDS[page*128 +: 32];
    localparam logic signed [31:0] SEED_1 = ROM_SEEDS[page*128+32 +: 32];
    localparam logic signed [31:0] SEED_2 = ROM_SEEDS[page*128+64 +: 32];
    localparam logic signed [31:0] SEED_3 = ROM_SEEDS[page*128+96 +: 32];

    initial begin : initialize_rom
      integer value_q30;
      integer difference_1;
      integer difference_2;
      integer difference_3;
      logic signed [3:0] difference_4;
      exp_rom[page*1024] = SEED_0;
      exp_rom[page*1024+1] = SEED_1;
      exp_rom[page*1024+2] = SEED_2;
      exp_rom[page*1024+3] = SEED_3;
      value_q30 = SEED_3;
      difference_1 = SEED_3 - SEED_2;
      difference_2 = difference_1 - (SEED_2 - SEED_1);
      difference_3 = difference_2 - ((SEED_2 - SEED_1) - (SEED_1 - SEED_0));
      for (integer offset = 4; offset < 1024; offset = offset + 1) begin
        difference_4 = $signed(ROM_D4[(page*1024+offset-4)*4 +: 4]);
        difference_3 = difference_3 + {{28{difference_4[3]}}, difference_4};
        difference_2 = difference_2 + difference_3;
        difference_1 = difference_1 + difference_2;
        value_q30 = value_q30 + difference_1;
        exp_rom[page*1024+offset] = value_q30;
      end
    end
  end

  function automatic logic signed [63:0] extend_s32(
    input logic signed [31:0] value
  );
    extend_s32 = {{32{value[31]}}, value};
  endfunction

  always_comb begin : reduce_cells
    logic signed [63:0] heat_sum;
    logic signed [63:0] overload_sum;
    logic signed [63:0] lag_sum;
    logic signed [63:0] neutral_count;
    heat_sum = 64'sd0;
    overload_sum = 64'sd0;
    lag_sum = 64'sd0;
    neutral_count = 64'sd0;
    for (int cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin
      heat_sum = heat_sum + extend_s32($signed(heat_q16[cell_index*32 +: 32]));
      overload_sum = overload_sum
        + extend_s32($signed(thermal_overload_q16[cell_index*32 +: 32]));
      lag_sum = lag_sum
        + extend_s32($signed(frequency_lag_q16[cell_index*32 +: 32]));
      if (retained_state[cell_index*2 +: 2] == 2'b00)
        neutral_count = neutral_count + 64'sd1;
    end
    mean_heat_q16 = frp_m31_sat_s32(frp_m31_round_shift_s64(heat_sum, MEAN_SHIFT));
    mean_thermal_overload_q16 = frp_m31_sat_s32(
      frp_m31_round_shift_s64(overload_sum, MEAN_SHIFT));
    mean_frequency_lag_q16 = frp_m31_sat_s32(
      frp_m31_round_shift_s64(lag_sum, MEAN_SHIFT));
    neutral_fraction_q30 = frp_m31_sat_s32(
      frp_m31_round_shift_s64(neutral_count <<< 30, MEAN_SHIFT));
  end

  always_comb begin : compression_argument
    logic signed [63:0] margin_pressure;
    logic signed [63:0] margin_square;
    logic signed [31:0] margin_sq_q16;
    logic signed [31:0] thermal_sq_q16;
    logic signed [63:0] argument_sum;
    // The difference can exceed signed 32 bits when history is INT32_MIN.
    margin_pressure = 64'sd16384 - extend_s32(previous_margin_q16);
    if (margin_pressure < 64'sd0)
      margin_pressure = 64'sd0;
    margin_square = margin_pressure * margin_pressure;
    margin_sq_q16 = frp_m31_sat_s32(
      frp_m31_round_shift_s64(margin_square, 16));
    thermal_sq_q16 = frp_m31_mul_q16(
      mean_thermal_overload_q16, mean_thermal_overload_q16);
    argument_sum = extend_s32(frp_m31_mul_q16(
      THERMAL_COMPRESSION_GAIN_Q16, thermal_sq_q16))
      + extend_s32(frp_m31_mul_q16(MARGIN_COMPRESSION_GAIN_Q16, margin_sq_q16));
    compression_arg_q16 = frp_m31_sat_s32(argument_sum);
  end

  logic [31:0] clipped_arg_q16;
  logic [63:0] address_numerator;
  logic [11:0] rom_address;
  assign clipped_arg_q16 = (compression_arg_q16 < 32'sd0) ? 32'd0
    : (compression_arg_q16 > 32'sd524288) ? 32'd524288
    : $unsigned(compression_arg_q16);
  assign address_numerator = {32'd0, clipped_arg_q16} * 64'd4095 + 64'd262144;
  assign rom_address = 12'(address_numerator >> 19);
  assign next_coherence_compression_q30 = $signed(exp_rom[rom_address]);
  assign next_effective_coherence_q30 = frp_m31_mul_q30(
    raw_phase_coherence_q30, next_coherence_compression_q30);

  always_comb begin : capacity_and_pressure
    logic signed [63:0] capacity_sum;
    capacity_sum = extend_s32(BASE_CAPACITY_Q16);
    capacity_sum = capacity_sum + extend_s32(frp_m31_mul_q16_q30(
      GLOBAL_GAIN_Q16, next_effective_coherence_q30));
    capacity_sum = capacity_sum + extend_s32(frp_m31_mul_q16_q30(
      CLUSTER_GAIN_Q16, cluster_coherence_q30));
    capacity_sum = capacity_sum + extend_s32(frp_m31_mul_q16_q30(
      NEUTRAL_GAIN_Q16, neutral_fraction_q30));
    capacity_sum = capacity_sum - extend_s32(frp_m31_mul_q16(
      LAG_GAIN_Q16, mean_frequency_lag_q16));
    next_coherence_capacity_q16 = frp_m31_sat_s32(capacity_sum);
    next_pressure_q16 = frp_m31_sat_s32(
      extend_s32(mean_heat_q16) + extend_s32(switch_load_q16));
    next_stability_margin_q16 = frp_m31_sat_s32(
      extend_s32(next_coherence_capacity_q16) - extend_s32(next_pressure_q16));
  end
  assign next_stable = next_stability_margin_q16 > 32'sd0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      coherence_compression_q30 <= 32'sd1073741824;
      effective_coherence_q30 <= 32'sd0;
      coherence_capacity_q16 <= 32'sd65536;
      pressure_q16 <= 32'sd3277;
      stability_margin_q16 <= 32'sd62259;
      stable <= 1'b1;
      previous_margin_q16 <= 32'sd39322;
    end else if (tick_enable) begin
      coherence_compression_q30 <= next_coherence_compression_q30;
      effective_coherence_q30 <= next_effective_coherence_q30;
      coherence_capacity_q16 <= next_coherence_capacity_q16;
      pressure_q16 <= next_pressure_q16;
      stability_margin_q16 <= next_stability_margin_q16;
      stable <= next_stable;
      previous_margin_q16 <= next_stability_margin_q16;
    end
  end

endmodule

`endif

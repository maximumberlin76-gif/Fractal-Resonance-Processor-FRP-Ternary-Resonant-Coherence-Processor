// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Source: frp_prototype_v1_7_0.py, update_thermal_node_factors.
// Default thermal coupling gain: 163840 in signed Q16.16.
// The exponent uses half that gain, signed saturation and half-away rounding.
// EXP_NEG_Q30 contains 4096 Q30 words over the Q16.16 interval [0, 524288].
// ROM_D4 stores their exact signed fourth differences, lowest index first
// in the least significant nibble; initialization reconstructs the integers.
// This constant decoding runs at elaboration, with no clocked decoder.
// The candidate output uses the supplied overload; tick_enable commits it.

`ifndef FRP_M31_LOCAL_THERMAL_ATTENUATION_SV
`define FRP_M31_LOCAL_THERMAL_ATTENUATION_SV

`timescale 1ns / 1ps
`include "frp_m31_fixed_point_pkg.sv"

module frp_m31_local_thermal_attenuation #(
  parameter int CELLS = 8
) (
  input  logic clk,
  input  logic rst_n,
  input  logic tick_enable,
  input  logic [(CELLS*32)-1:0] thermal_overload_q16,
  output wire [(CELLS*32)-1:0] thermal_node_factor_q30,
  output wire [(CELLS*32)-1:0] next_thermal_node_factor_q30
);

  import frp_m31_fixed_point_pkg::*;

  localparam logic signed [31:0] HALF_GAIN_Q16 = 32'sd81920;
  localparam logic [16367:0] ROM_D4 = {
    512'ha5d2e11fe4ef11e2e11e2e2e11ff11e2e2e2e12b5ef2e11ff2e2e2e2ff11ff2e2e2ff2e2ff2e2e3b6b21f0f2e2ff2ff2ff2ff3b6b3e2f0f3b6b3ff3b6c02ff2f,
    512'h00f2f0f3c3ff3c3ff3c4c22d03c3f00f3c30d3ff3d03c4c30d3f00000000000000000000001d3f1d4c4d03d11d30d4d10001d4d11d4c4d2d4d101e1001e11d4d2e1,
    512'h001e2e101e11e11e11e2d5a5ee4ef11e2e2e11e2e2e2e2e12b5ef2e2e2ff12b6a6b3e2e2f0f11f0f2ff2ff2ff2f0f2ff3c3e20c6c02f0f3c3ff3c4c3f0f3d020,
    512'hd3f000000f3d10f3d1000000001d4d03d101d4d1001d4d2d4d101e101e101e2d4ee4ee4ef101fe4ef11e2e2e2e2e11ff2e2e2e2ff2e2ff2e2f0f2e2f0f2ff2f0,
    512'hf2f0f3c3ff3c3f00f3c3f01c6c10f3d1f3d03d1000001d4c4d101d4d101e1001e11e101e11e2d4ef11e11ff11e2e2e2e2e2e3b5e0f12b6b3ff2ff2f0f2f0f3c2,
    512'h2d020d22d03c4c4c3f1d3f1d4c4d03d11d4d1001d4ee4d11e11d5a5d2e2e11e2e2e12b6a6b21ff2e3b6b3ff2ff2f00f2f00f3c3f000000f3d1f3d1001d4c4d10,
    512'h1e1001e11d5a5d2e11e2e11ff11ff2e2e2ff2ff2ff2f0f3c22c4c3f0f3d03c4c4d03d10001d4d101e101e11e11e2e11e2e2e2ff11ff2ff2f0f2e3c3f0f3c3f1d,
    512'h3e3d1001d30d4d101d4d2e101e2e11e12b5ef2e2e3b6b3e2f00f2f00f3c3f1d3f01d4c4d101d4d11e11e2d5a5ef12b5e0f12c22c3ff2f0000f3c4c4c4c4d101d,
    512'h4d2d4d2e11e2e11ff2e2e3b6b3ff3c3ff3d03c30e03d1001d4ee4d2e11e2e2e2e2ff2ff3c22c3f000000000001d4d2d4ee4ef11e2e2ff2e3c22c3f0f3d03c4c4,
    512'hd101d4ee4d2e11ff11ff2e3c22c4c3e3d10000001e101e11e11ff2e2e2f0f2f00f3c4c4d03d2d4d11e11fe5b22b6b3ff3c3f000001d4c5a5c5b202b5e0f2e20c,
    512'h6c03d03c4d11d4d2e11ff11ff2f0f2f000000001e101e11e2ff11f0f3c3f0f3d101d4d2d5a5ef2e3b6b3f000000001d4ef102b5e0f2ff3c3f1d30d4ee4d2e2e2,
    512'he3b6c020d3f1d4d11e11ff11f0f20d22d11d30e2e11ff110c6b4c4c4c4c4d2d5a5ef2e2f0f3d03c4d11e11e2ff2e3c3f1d30d4d2e2e12b6c02f0001d4d2e11ff2e,
    512'h3c3f0001e101e12b6b3f000f3ee4d11ff12c3f000f4a5d11e2f0f2e3d1001d4ef2e2ff20d30d4d2e11ff2f000f3d2e101f0f2e3d1f3ee4ef12c3e3c4d101e11f,
    512'hf2f000001d5a5e0f2f000001e2e2ff2f1d30d5a5e0f2ff3d2d4d2e2f0f3c4d101ff2e20d30e101ff2ff3d03ee5a6b3e3d1001ff110c6de30e2e2f0f3d1002b6b,
    512'h3e3d11d5a6b3f0001d5b22c3f01e11e2ff3d1001ff2ff3d11e11f0f3d101e2ff3c4d101f0f3c4d11e2f0f3d11ff12c4d101ff2f01d4ef12c4c4ee5b3f0001e2e,
    512'h3c4d101ff3c30e2e2ff3d2d5b22d1002b6b4c4d2e3c3f01e2f0f3d2e12c30e11e3c4c4d3b6c03ef2e3c4d12c22d2d5b3f001e2ff3d2e2e3c4d2ff2f1e2e2f01d,
    512'h5b3f1d4ef20d4ef2f001e2f01d4e0f3d11f00001ff3d102c3f1e2ff3d2e2f001ff20e11e3d11e2f1d5b22d2e2ff3ef2f01e2e3d11ff3d2e2f1e110d4d2f01e11,
    512'h0d4e0f3d12c30ff2f01f0f3ef2f1e2e3d12c30e12d11ff3d12c4d2e3c5b3e4b22d102d101f01e2f0010d4d2f01e3c4ef20e2f01e20d5b3f1f001e20e2f02c30e3d110e2e3ef20ff3d3c4d20e20d5b4d3c4e001f01f001f1e3c5b30f0010d5,
    512'hb4d20e20d5c110d5b4e001f1e2f1f1e20e20e20e20e20e20e3d2e4b3f2c4e01f002c5c04c110d5c2e3e001f1f002d2f1e3d20f001f2c4d3d20ff3fd4e1f002d20e2,
    512'hf2d110f1e2f2d12d3d12ef4b300e2f10e3d20e3d3d3d13a796df3e010e2f2d20e21c5b4e02d2f1f10e20f02d20f010e3d3e01f2c4e10e20f2c4e1f10e20f10e3,
    512'hd3e01f2d2f2d20f1f1f1f10e4b4e02e003b4e02d3d3e1e4b4ff010f03b31d3d3e02d3d3fe200e4b5c20f10e4c13b4ff02e0100e3fe3fe21d3e02d4b5c21c5d01,
    512'h1c5d010f2e010f2e011d21d21d3e1f2d4b5d0100f2d21e02e1f2e02e2d21e02e03c21c6a5c3e100f100f11d3e1000f1f3c21d4b5d100f1000f11e02ff11d21ff,
    512'h10f3b5ee30c6a5d100f2fe4d10f2ff11e03d02ff2e11e03d02f0f2e2e11d4ee3f1d3f000f2f0f2ff2ff3b6b3e2f0f2ff3c4c3f00001e101e2e2e2f0000001e2e,
    512'h2e3c4d101e3c3e4a5d2f0001e12c30e2e3c4d11f1d4ef3c4e0f3d2e3d12c30e2f1e2f01e3d12c4ef3d2f01e3ef20e20e20d5c2e3d20e13a6c2e4a796c110f01e,
    512'h3e01f01f1f1e3e1e20e4b4e01f10e20f1f1f1f02d3d3d3e01f2d20f1f10e3fe3d3fe200f03b31e011c5c3d3ff011d21d3d4c200f10f1000e4c21d3e2e011e10f,
    512'h1000f11d3ff11d3ff11e03c3e11e10f3c21fe5a40e03c4c3ff3c22c3ff2f00f2f1d3f1d4ee5a6b30d30e11f00001e3c3f1ff2f1e3c3f2c3f1f001e3d110e12d2,
    512'he3ef3d2f1f002d2f02c5b4e01f02d2f10e20f1f02d20f02d3e002fd5df4c3c6a31d3e02e02d3fe3e2d3e1f2e1f2d4c3e1f2ff03c21e10f2fe4d1f2f0f11e11d3,
    512'h0d4c4c30d3f001d4d102b5e000001ff12ee4ef3d12c30e2f1e2f1e3c5b4d20e2f10d5b5b4e002ef3fd5b5df21d20f02d3e02d3e011d20f2d3fe3e2d3e2d3e11d,
    512'h3e11d3ff2d4c4c3ff11e2e101e1001e2e11e3c3f001e2f0001ff3d12d102c4e001f1e20e3d2f2c5b4e010f010e4b4e1f10f1f100e3fe4b697b21d21d4d011e03,
    512'hd012b5d2d4d11d4d11e11ff3c30e2e3c4ef20e12ee5c2e3ef3d3ef3d3e01f1f1f2c5c3d3e02e02e1f11d21d4c21e03c3e11e11d30d4d03d2e11ff3c4ef2f01f0,
    496'h01f1d5c2e4a7a23b4e1e3e1f1f1f2d3fe21e1f11d3e101d3e2e2e101e101e11e3c3f1e2e3ee5c2e20f002c5c12d3d20f10f02d3fe3fe4c21e1f3b5d11d4c
  };

  localparam logic [511:0] ROM_SEEDS = {
    128'h002850c1002864ef0028792800288d6b,
    128'h012a09e0012a9f14012b3492012bca5b,
    128'h089b4cb1089f9bb008a3ecd708a84027,
    128'h3fa041e53fc01bf93fe0060040000000
  };
  logic [31:0] exp_rom [0:4095];

  initial begin
    if (CELLS < 1)
      $fatal(1, "FRP local thermal attenuation requires at least one cell");
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

  for (genvar lane = 0; lane < CELLS; lane = lane + 1) begin : g_cell
    logic signed [31:0] exponent_arg_q16;
    logic [31:0] clipped_arg_q16;
    logic [63:0] address_numerator;
    logic [11:0] rom_address;
    logic [31:0] factor_q;
    logic [31:0] factor_d;

    assign exponent_arg_q16 = frp_m31_mul_q16(
      HALF_GAIN_Q16, $signed(thermal_overload_q16[lane*32 +: 32])
    );
    assign clipped_arg_q16 = (exponent_arg_q16 < 32'sd0) ? 32'd0
      : (exponent_arg_q16 > 32'sd524288) ? 32'd524288
      : $unsigned(exponent_arg_q16);
    assign address_numerator = {32'd0, clipped_arg_q16} * 64'd4095
      + 64'd262144;
    assign rom_address = 12'(address_numerator >> 19);
    assign factor_d = exp_rom[rom_address];
    assign next_thermal_node_factor_q30[lane*32 +: 32] = factor_d;
    assign thermal_node_factor_q30[lane*32 +: 32] = factor_q;

    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        factor_q <= 32'd1073741824;
      else if (tick_enable)
        factor_q <= factor_d;
    end
  end

endmodule

`endif

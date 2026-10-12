// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Source: frp_prototype_v1_7_0.py, QuantizedReferenceShadowProcessor,
// update_local_gamma_drift, default gamma and correlation parameters.
// Noise targets, noise state and thermal overload use signed Q16.16.
// Gamma outputs use the signed 32-bit phase-word representation modulo 2**32.
// On an enabled tick, a valid target is used in that same noise update.
// The drift uses the updated noise state and the supplied thermal overload.
// next_gamma outputs expose the candidate update before its clocked commit.

`ifndef FRP_M31_LOCAL_GAMMA_DRIFT_SV
`define FRP_M31_LOCAL_GAMMA_DRIFT_SV

`timescale 1ns / 1ps
`include "frp_m31_fixed_point_pkg.sv"

module frp_m31_local_gamma_drift #(
  parameter int CELLS = 8
) (
  input  logic clk,
  input  logic rst_n,
  input  logic tick_enable,
  input  logic gamma_update_valid,
  input  logic [(CELLS*32)-1:0] gamma_targets_q16,
  input  logic [(CELLS*32)-1:0] thermal_overload_q16,
  output wire [(CELLS*32)-1:0] gamma_noise_target_q16,
  output wire [(CELLS*32)-1:0] gamma_noise_state_q16,
  output wire [(CELLS*32)-1:0] gamma_drift_word,
  output wire [(CELLS*32)-1:0] gamma_effective_word,
  output wire [(CELLS*32)-1:0] next_gamma_drift_word,
  output wire [(CELLS*32)-1:0] next_gamma_effective_word
);

  import frp_m31_fixed_point_pkg::*;

  localparam logic signed [31:0] CORRELATION_ALPHA_Q16 = 32'sd9830;
  localparam logic signed [31:0] THERMAL_GAIN_Q16 = 32'sd5243;

  initial begin
    if (CELLS < 1)
      $fatal(1, "FRP local gamma drift requires at least one cell");
  end

  for (genvar lane = 0; lane < CELLS; lane = lane + 1) begin : g_cell
    logic signed [31:0] target_q;
    logic signed [31:0] noise_q;
    logic signed [31:0] drift_q;
    logic signed [31:0] effective_q;
    logic signed [31:0] target_d;
    logic signed [31:0] noise_d;
    logic signed [31:0] drift_d;
    logic signed [31:0] effective_d;
    logic signed [63:0] target_difference;
    logic signed [63:0] correlation_product;
    logic signed [31:0] noise_increment;
    logic signed [31:0] thermal_gain;
    logic signed [31:0] drift_rad_q16;

    assign gamma_noise_target_q16[lane*32 +: 32] = target_q;
    assign gamma_noise_state_q16[lane*32 +: 32] = noise_q;
    assign gamma_drift_word[lane*32 +: 32] = drift_q;
    assign gamma_effective_word[lane*32 +: 32] = effective_q;
    assign next_gamma_drift_word[lane*32 +: 32] = drift_d;
    assign next_gamma_effective_word[lane*32 +: 32] = effective_d;

    always_comb begin
      target_d = gamma_update_valid
        ? $signed(gamma_targets_q16[lane*32 +: 32]) : target_q;

      // Two signed 32-bit words can differ by more than a signed word.
      target_difference = {{32{target_d[31]}}, target_d}
        - {{32{noise_q[31]}}, noise_q};
      correlation_product = target_difference * CORRELATION_ALPHA_Q16;
      noise_increment = frp_m31_sat_s32(
        frp_m31_round_shift_s64(correlation_product, 16)
      );
      noise_d = frp_m31_sat_s32(
        {{32{noise_q[31]}}, noise_q}
        + {{32{noise_increment[31]}}, noise_increment}
      );
      thermal_gain = frp_m31_mul_q16(
        THERMAL_GAIN_Q16, $signed(thermal_overload_q16[lane*32 +: 32])
      );
      drift_rad_q16 = frp_m31_mul_q16(thermal_gain, noise_d);
      drift_d = frp_m31_velocity_to_phase_word(drift_rad_q16);
      effective_d = FRP_M31_GAMMA_NOMINAL + drift_d;
    end

    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        target_q <= 32'sd0;
        noise_q <= 32'sd0;
        drift_q <= 32'sd0;
        effective_q <= FRP_M31_GAMMA_NOMINAL;
      end else if (tick_enable) begin
        target_q <= target_d;
        noise_q <= noise_d;
        drift_q <= drift_d;
        effective_q <= effective_d;
      end
    end
  end

endmodule

`endif

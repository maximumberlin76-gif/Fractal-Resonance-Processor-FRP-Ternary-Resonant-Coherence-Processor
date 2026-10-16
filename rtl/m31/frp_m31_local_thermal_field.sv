 // Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
 // Local thermal state, power, dissipation and diffusion for 8, 16, 32 and 64 cells.
 // Source: frp_prototype_v1_7_0.py, QuantizedReferenceShadowProcessor,
 // thermal_weighted_sum_q16 and update_local_thermal_field, default parameters.
 // Heat and power use signed Q16.16; weights use signed Q2.30.
 // Frequency lag is unsigned Q16.16, the absolute target/current difference.
 // Each weighted difference is rounded before summation, as in the source.
 // Products round to nearest, with half cases away from zero, then saturate.
 // All cell updates read the same retained heat bank before the clock edge.
 // rst_n clears thermal history; tick_enable commits one thermal update.
 // next_heat_q16 and next_overload_q16 expose that update before its commit.

`ifndef FRP_M31_LOCAL_THERMAL_FIELD_SV
`define FRP_M31_LOCAL_THERMAL_FIELD_SV

`timescale 1ns / 1ps
`include "frp_m31_fixed_point_pkg.sv"

module frp_m31_local_thermal_field #(
  parameter int CELLS = 8
) (
  input  logic clk,
  input  logic rst_n,
  input  logic tick_enable,
  input  logic [CELLS-1:0] switch_activity,
  input  logic [(CELLS*32)-1:0] frequency_lag_q16,
  output wire [(CELLS*32)-1:0] heat_q16,
  output wire [(CELLS*32)-1:0] local_heat_peak_q16,
  output wire [(CELLS*32)-1:0] generated_power_q16,
  output wire [(CELLS*32)-1:0] thermal_dissipation_q16,
  output wire [(CELLS*32)-1:0] thermal_diffusion_q16,
  output wire [(CELLS*32)-1:0] thermal_overload_q16,
  output wire [(CELLS*32)-1:0] next_heat_q16,
  output wire [(CELLS*32)-1:0] next_overload_q16,
  output logic signed [31:0] mean_heat_q16,
  output logic signed [31:0] mean_heat_peak_q16,
  output logic signed [31:0] maximum_local_heat_q16
);

  import frp_m31_fixed_point_pkg::*;

  localparam logic signed [31:0] AMBIENT_Q16 = 32'sd3277;
  localparam logic signed [31:0] SOFT_LIMIT_Q16 = 32'sd14418;
  localparam logic signed [31:0] BASE_POWER_Q16 = 32'sd118;
  localparam logic signed [31:0] SWITCH_POWER_Q16 = 32'sd3408;
  localparam logic signed [31:0] LAG_GAIN_Q16 = 32'sd1180;
  localparam logic signed [31:0] DIFFUSION_GAIN_Q16 = 32'sd2294;

  localparam int DEPTH = $clog2(CELLS);

  logic signed [31:0] heat_q [0:CELLS-1];
  logic signed [31:0] peak_q [0:CELLS-1];
  logic signed [31:0] power_q [0:CELLS-1];
  logic signed [31:0] dissipation_q [0:CELLS-1];
  logic signed [31:0] diffusion_q [0:CELLS-1];
  logic signed [31:0] overload_q [0:CELLS-1];
  logic signed [31:0] heat_d [0:CELLS-1];
  logic signed [31:0] power_d [0:CELLS-1];
  logic signed [31:0] dissipation_d [0:CELLS-1];
  logic signed [31:0] diffusion_d [0:CELLS-1];
  logic signed [31:0] overload_d [0:CELLS-1];
  logic signed [31:0] mean_heat_d;

  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32) && (CELLS != 64))
      $fatal(1, "FRP M31 local thermal field requires 8, 16, 32 or 64 cells");
  end

  // quantized_level_weights(CELLS, 1.20); each row sums to 2**30.
  function automatic logic signed [31:0] thermal_weight_q30(
    input int unsigned left_index,
    input int unsigned right_index
  );
    int unsigned differing;
    begin
      differing = left_index ^ right_index;
      thermal_weight_q30 = 32'sd0;
      if (differing != 0) begin
        case (CELLS)
          8: begin
            if (differing < 2) thermal_weight_q30 = 32'sd630553580;
            else if (differing < 4) thermal_weight_q30 = 32'sd137232194;
            else thermal_weight_q30 = 32'sd42180964;
          end
          16: begin
            if (differing < 2) thermal_weight_q30 = 32'sd567420738;
            else if (differing < 4) thermal_weight_q30 = 32'sd123492111;
            else if (differing < 8) thermal_weight_q30 = 32'sd37957684;
            else thermal_weight_q30 = 32'sd13438266;
          end
          32: begin
            if (differing < 2) thermal_weight_q30 = 32'sd527047716;
            else if (differing < 4) thermal_weight_q30 = 32'sd114705422;
            else if (differing < 8) thermal_weight_q30 = 32'sd35256926;
            else if (differing < 16) thermal_weight_q30 = 32'sd12482109;
            else thermal_weight_q30 = 32'sd4774918;
          end
          64: begin
            if (differing < 2) thermal_weight_q30 = 32'sd498545852;
            else if (differing < 4) thermal_weight_q30 = 32'sd108502338;
            else if (differing < 8) thermal_weight_q30 = 32'sd33350288;
            else if (differing < 16) thermal_weight_q30 = 32'sd11807096;
            else if (differing < 32) thermal_weight_q30 = 32'sd4516698;
            else thermal_weight_q30 = 32'sd1814569;
          end
          default: thermal_weight_q30 = 32'sd0;
        endcase
      end
    end
  endfunction

  for (genvar cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin : g_cell
    assign heat_q16[cell_index*32 +: 32] = heat_q[cell_index];
    assign local_heat_peak_q16[cell_index*32 +: 32] = peak_q[cell_index];
    assign generated_power_q16[cell_index*32 +: 32] = power_q[cell_index];
    assign thermal_dissipation_q16[cell_index*32 +: 32] = dissipation_q[cell_index];
    assign thermal_diffusion_q16[cell_index*32 +: 32] = diffusion_q[cell_index];
    assign thermal_overload_q16[cell_index*32 +: 32] = overload_q[cell_index];
    assign next_heat_q16[cell_index*32 +: 32] = heat_d[cell_index];
    assign next_overload_q16[cell_index*32 +: 32] = overload_d[cell_index];

    always_comb begin : thermal_step
      logic signed [63:0] heat_difference;
      logic signed [63:0] weighted_sum;
      logic signed [63:0] weighted_product;
      logic signed [63:0] lag_extended;
      logic signed [63:0] lag_product;
      logic signed [63:0] power_sum;
      logic signed [63:0] excess_heat;
      logic signed [63:0] candidate_heat;
      logic signed [31:0] lag_power;
      logic signed [31:0] weighted_difference;
      logic signed [31:0] candidate_clipped;

      weighted_sum = 64'sd0;
      heat_difference = 64'sd0;
      weighted_product = 64'sd0;
      weighted_difference = 32'sd0;
      for (int other = 0; other < CELLS; other = other + 1) begin
        if (other != cell_index) begin
          heat_difference =
            {{32{heat_q[other][31]}}, heat_q[other]} -
            {{32{heat_q[cell_index][31]}}, heat_q[cell_index]};
          weighted_product = heat_difference * thermal_weight_q30(cell_index, other);
          weighted_difference = frp_m31_sat_s32(
            frp_m31_round_shift_s64(weighted_product, 30)
          );
          weighted_sum = weighted_sum +
            {{32{weighted_difference[31]}}, weighted_difference};
        end
      end
      diffusion_d[cell_index] = frp_m31_mul_q16(
        DIFFUSION_GAIN_Q16, frp_m31_sat_s32(weighted_sum)
      );

      lag_extended = $signed({32'd0, frequency_lag_q16[cell_index*32 +: 32]});
      lag_product = lag_extended * LAG_GAIN_Q16;
      lag_power = frp_m31_sat_s32(frp_m31_round_shift_s64(lag_product, 16));
      power_sum = {{32{BASE_POWER_Q16[31]}}, BASE_POWER_Q16}
        + {{32{lag_power[31]}}, lag_power};
      if (switch_activity[cell_index])
        power_sum = power_sum + {{32{SWITCH_POWER_Q16[31]}}, SWITCH_POWER_Q16};
      power_d[cell_index] = frp_m31_sat_s32(power_sum);

      // round((heat - ambient) * 65536 / (14 * 65536)).
      excess_heat = {{32{heat_q[cell_index][31]}}, heat_q[cell_index]}
        - {{32{AMBIENT_Q16[31]}}, AMBIENT_Q16};
      if (excess_heat < 0)
        dissipation_d[cell_index] = 32'(-((-excess_heat + 64'sd7) / 64'sd14));
      else
        dissipation_d[cell_index] = 32'((excess_heat + 64'sd7) / 64'sd14);

      candidate_heat = {{32{heat_q[cell_index][31]}}, heat_q[cell_index]}
        + {{32{power_d[cell_index][31]}}, power_d[cell_index]}
        - {{32{dissipation_d[cell_index][31]}}, dissipation_d[cell_index]}
        + {{32{diffusion_d[cell_index][31]}}, diffusion_d[cell_index]};
      candidate_clipped = frp_m31_sat_s32(candidate_heat);
      heat_d[cell_index] = (candidate_clipped < AMBIENT_Q16)
        ? AMBIENT_Q16 : candidate_clipped;
      overload_d[cell_index] = (heat_d[cell_index] > SOFT_LIMIT_Q16)
        ? heat_d[cell_index] - SOFT_LIMIT_Q16 : 32'sd0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        heat_q[cell_index] <= AMBIENT_Q16;
        peak_q[cell_index] <= AMBIENT_Q16;
        power_q[cell_index] <= 32'sd0;
        dissipation_q[cell_index] <= 32'sd0;
        diffusion_q[cell_index] <= 32'sd0;
        overload_q[cell_index] <= 32'sd0;
      end else if (tick_enable) begin
        heat_q[cell_index] <= heat_d[cell_index];
        if (heat_d[cell_index] > peak_q[cell_index])
          peak_q[cell_index] <= heat_d[cell_index];
        power_q[cell_index] <= power_d[cell_index];
        dissipation_q[cell_index] <= dissipation_d[cell_index];
        diffusion_q[cell_index] <= diffusion_d[cell_index];
        overload_q[cell_index] <= overload_d[cell_index];
      end
    end
  end

  always_comb begin : aggregate_heat
    logic signed [63:0] current_sum;
    logic signed [63:0] next_sum;
    current_sum = 64'sd0;
    next_sum = 64'sd0;
    maximum_local_heat_q16 = AMBIENT_Q16;
    for (int cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin
      current_sum = current_sum + {{32{heat_q[cell_index][31]}}, heat_q[cell_index]};
      next_sum = next_sum + {{32{heat_d[cell_index][31]}}, heat_d[cell_index]};
      if (peak_q[cell_index] > maximum_local_heat_q16)
        maximum_local_heat_q16 = peak_q[cell_index];
    end
    mean_heat_q16 = 32'(frp_m31_round_shift_s64(current_sum, DEPTH));
    mean_heat_d = 32'(frp_m31_round_shift_s64(next_sum, DEPTH));
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      mean_heat_peak_q16 <= AMBIENT_Q16;
    else if (tick_enable && (mean_heat_d > mean_heat_peak_q16))
      mean_heat_peak_q16 <= mean_heat_d;
  end

endmodule

`endif

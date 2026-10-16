 // SPDX-License-Identifier: Apache-2.0
 // FRP M31 retained relative-phase interference for 8, 16, 32 and 64 cells.
 // Q30 shell weights: frp_prototype_v1_7_0.py, quantized_level_weights(N, 0.70).
 // Groups are packed by ascending dyadic level, then ascending cell range.
 // Level statistics use rounded means and integer RMS deviations.
 // The eight-cell organization output retains its existing rounded half-gap.

`ifndef FRP_M31_PHASE_INTERFERENCE_SV
`define FRP_M31_PHASE_INTERFERENCE_SV

`timescale 1ns / 1ps

`include "frp_m31_pkg.sv"
`include "frp_m31_fixed_point_pkg.sv"
`include "frp_m31_isqrt_u64.sv"

module frp_m31_phase_interference #(
  parameter int CELLS = 8,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic load_valid,

  input logic [(CELLS*32)-1:0] phase_load,
  input logic [(CELLS*32)-1:0] frequency_load_q16,
  input logic [(CELLS*32)-1:0] gamma_effective_word,
  input logic [(CELLS*32)-1:0] thermal_node_factor_q30,
  input logic [(CELLS*2)-1:0] retained_state,
  input logic [CELLS-1:0] switch_activity,
  input frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state,

  output logic [(CELLS*32)-1:0] phase_word_q,
  output logic [(CELLS*32)-1:0] frequency_current_q16,
  output logic [(CELLS*32)-1:0] coupling_field_q16,
  output logic [(CELLS*32)-1:0] phase_projection_q30,
  output logic [(CELLS*2)-1:0] phase_target,
  output logic signed [31:0] pair_coherence_q30,
  output logic signed [31:0] cluster_coherence_q30,
  output logic signed [31:0] global_coherence_q30,
  output logic signed [31:0] organization_dispersion_q30,
  output wire [((CELLS-1)*32)-1:0] group_coherence_q30,
  output logic [($clog2(CELLS)*32)-1:0] level_mean_coherence_q30,
  output logic [($clog2(CELLS)*32)-1:0] level_min_coherence_q30,
  output logic [($clog2(CELLS)*32)-1:0] level_max_coherence_q30,
  output wire [($clog2(CELLS)*32)-1:0] level_dispersion_q30
);

  import frp_m31_pkg::*;
  import frp_m31_fixed_point_pkg::*;

  logic signed [31:0] sin_lut [0:FRP_M31_TRIG_ENTRIES-1];

  logic [31:0] phase_q [0:CELLS-1];
  logic [31:0] phase_d [0:CELLS-1];
  logic signed [31:0] frequency_q [0:CELLS-1];
  logic signed [31:0] frequency_d [0:CELLS-1];
  logic signed [31:0] sine_q30 [0:CELLS-1];
  logic signed [31:0] cosine_q30 [0:CELLS-1];
  logic signed [31:0] coupling_q16 [0:CELLS-1];
  localparam int DEPTH = $clog2(CELLS);
  localparam int GROUPS = CELLS - 1;
  localparam int PAIRS = CELLS / 2;
  localparam int CLUSTERS = CELLS / 4;
  localparam logic [31:0] RESET_PHASE_STEP = 32'(64'h100000000 / CELLS);

  logic [63:0] coherence_square_q60 [0:GROUPS-1];
  wire [31:0] coherence_magnitude_q30 [0:GROUPS-1];
  wire signed [31:0] coherence_value_q30 [0:GROUPS-1];
  logic [63:0] level_variance_q60 [0:DEPTH-1];
  wire [31:0] level_deviation_q30 [0:DEPTH-1];

  for (genvar group_index = 0; group_index < GROUPS; group_index++) begin : g_coherence
    frp_m31_isqrt_u64 magnitude (
      .radicand(coherence_square_q60[group_index]),
      .root(coherence_magnitude_q30[group_index]), .remainder()
    );
    assign coherence_value_q30[group_index] =
      (coherence_magnitude_q30[group_index] > 32'd1073741824)
      ? FRP_M31_Q30_ONE : $signed(coherence_magnitude_q30[group_index]);
    assign group_coherence_q30[group_index*32 +: 32] = coherence_value_q30[group_index];
  end

  for (genvar level_index = 0; level_index < DEPTH; level_index++) begin : g_dispersion
    frp_m31_isqrt_u64 deviation (
      .radicand(level_variance_q60[level_index]),
      .root(level_deviation_q30[level_index]), .remainder()
    );
    assign level_dispersion_q30[level_index*32 +: 32] = level_deviation_q30[level_index];
  end

  function automatic logic signed [31:0] phase_weight_q30(
    input int unsigned left_index, right_index
  );
    int unsigned differing;
    begin
      differing = left_index ^ right_index;
      phase_weight_q30 = 32'sd0;
      if (differing != 0) begin
        case (CELLS)
          8: begin
            if (differing < 2) phase_weight_q30 = 32'sd516461574;
            else if (differing < 4) phase_weight_q30 = 32'sd158959695;
            else phase_weight_q30 = 32'sd59840215;
          end
          16: begin
            if (differing < 2) phase_weight_q30 = 32'sd436841896;
            else if (differing < 4) phase_weight_q30 = 32'sd134453864;
            else if (differing < 8) phase_weight_q30 = 32'sd50615020;
            else phase_weight_q30 = 32'sd20691515;
          end
          32: begin
            if (differing < 2) phase_weight_q30 = 32'sd385947114;
            else if (differing < 4) phase_weight_q30 = 32'sd118789159;
            else if (differing < 8) phase_weight_q30 = 32'sd44718058;
            else if (differing < 16) phase_weight_q30 = 32'sd18280826;
            else phase_weight_q30 = 32'sd7818597;
          end
          64: begin
            if (differing < 2) phase_weight_q30 = 32'sd350050538;
            else if (differing < 4) phase_weight_q30 = 32'sd107740697;
            else if (differing < 8) phase_weight_q30 = 32'sd40558875;
            else if (differing < 16) phase_weight_q30 = 32'sd16580545;
            else if (differing < 32) phase_weight_q30 = 32'sd7091397;
            else phase_weight_q30 = 32'sd3120865;
          end
          default: phase_weight_q30 = 32'sd0;
        endcase
      end
    end
  endfunction

  function automatic logic signed [31:0] sin_phase_q30(
    input logic [31:0] phase_word
  );
    begin
      sin_phase_q30 = sin_lut[phase_word[31:20]];
    end
  endfunction

  function automatic logic signed [31:0] cos_phase_q30(
    input logic [31:0] phase_word
  );
    logic [11:0] index;
    begin
      index = phase_word[31:20] + 12'd1024;
      cos_phase_q30 = sin_lut[index];
    end
  endfunction

  function automatic logic signed [63:0] round_div_s64(
    input logic signed [63:0] numerator,
    input int unsigned denominator
  );
    logic signed [63:0] magnitude;
    logic signed [63:0] half_denominator;
    begin
      half_denominator = denominator / 2;
      if (numerator < 0) begin
        magnitude = -numerator;
        round_div_s64 = -((magnitude + half_denominator) / denominator);
      end else begin
        round_div_s64 = (numerator + half_denominator) / denominator;
      end
    end
  endfunction

  function automatic logic [63:0] coherence_square_from_sums(
    input logic signed [63:0] sum_cos_q30,
    input logic signed [63:0] sum_sin_q30,
    input int unsigned population
  );
    logic signed [63:0] mean_cos_q30;
    logic signed [63:0] mean_sin_q30;
    begin
      mean_cos_q30 = round_div_s64(sum_cos_q30, population);
      mean_sin_q30 = round_div_s64(sum_sin_q30, population);
      coherence_square_from_sums =
        (mean_cos_q30 * mean_cos_q30) +
        (mean_sin_q30 * mean_sin_q30);
    end
  endfunction

  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32) && (CELLS != 64))
      $fatal(1, "FRP M31 phase engine requires 8, 16, 32 or 64 cells");
    $readmemh(SIN_LUT_FILE, sin_lut);
    if (sin_lut[0] !== 32'sd0)
      $fatal(1, "FRP M31 sine LUT zero-point mismatch");
    if (sin_lut[1024] !== FRP_M31_Q30_ONE)
      $fatal(1, "FRP M31 sine LUT quarter-cycle mismatch");
    if (sin_lut[2048] !== 32'sd0)
      $fatal(1, "FRP M31 sine LUT half-cycle mismatch");
    if (sin_lut[3072] !== -FRP_M31_Q30_ONE)
      $fatal(1, "FRP M31 sine LUT three-quarter-cycle mismatch");
  end

  for (genvar cell_index = 0; cell_index < CELLS; cell_index++) begin : g_phase_cell
    always_comb begin : update_cell
    logic signed [63:0] total_q30;
    logic signed [31:0] pair_factor_q30;
    logic signed [31:0] weighted_factor_q30;
    logic signed [31:0] pair_term_q30;
    logic signed [31:0] target_frequency_q16;
    logic signed [63:0] frequency_delta_q16;
    logic signed [31:0] filtered_delta_q16;
    logic signed [31:0] velocity_q16;
    logic signed [31:0] phase_step;
    logic signed [31:0] state_gain_q16;
    logic signed [31:0] switch_gain_q16;
    logic [31:0] phase_plus_gamma;
    logic [31:0] relative_phase;
    logic signed [31:0] thermal_i_q30;
    logic signed [31:0] thermal_j_q30;
    logic signed [31:0] topology_weight_q30;
    logic [1:0] state_value;

      sine_q30[cell_index] = sin_phase_q30(phase_q[cell_index]);
      cosine_q30[cell_index] = cos_phase_q30(phase_q[cell_index]);
      phase_word_q[(cell_index*32) +: 32] = phase_q[cell_index];
      frequency_current_q16[(cell_index*32) +: 32] = frequency_q[cell_index];
      phase_projection_q30[(cell_index*32) +: 32] = sine_q30[cell_index];

      if (sine_q30[cell_index] > FRP_M31_TARGET_THRESHOLD_Q30)
        phase_target[(cell_index*2) +: 2] = FRP_STATE_POS;
      else if (sine_q30[cell_index] < -FRP_M31_TARGET_THRESHOLD_Q30)
        phase_target[(cell_index*2) +: 2] = FRP_STATE_NEG;
      else
        phase_target[(cell_index*2) +: 2] = FRP_ACTIVE_NEUTRAL;
      total_q30 = 64'sd0;
      thermal_i_q30 = thermal_node_factor_q30[(cell_index*32) +: 32];
      phase_plus_gamma = phase_q[cell_index] + gamma_effective_word[(cell_index*32) +: 32];

      for (int other = 0; other < CELLS; other = other + 1) begin
        if (other != cell_index) begin
          thermal_j_q30 = thermal_node_factor_q30[(other*32) +: 32];
          topology_weight_q30 = phase_weight_q30(cell_index, other);
          pair_factor_q30 = frp_m31_mul_q30(thermal_i_q30, thermal_j_q30);
          weighted_factor_q30 = frp_m31_mul_q30(
            topology_weight_q30,
            pair_factor_q30
          );
          relative_phase = phase_q[other] - phase_plus_gamma;
          pair_term_q30 = frp_m31_mul_q30(
            weighted_factor_q30,
            sin_phase_q30(relative_phase)
          );
          total_q30 = total_q30 + pair_term_q30;
        end
      end

      coupling_q16[cell_index] = frp_m31_mul_q16(
        FRP_M31_COUPLING_NOMINAL_Q16,
        frp_m31_q30_to_q16(frp_m31_sat_s32(total_q30))
      );
      coupling_field_q16[(cell_index*32) +: 32] = coupling_q16[cell_index];

      state_value = retained_state[(cell_index*2) +: 2];
      if ((state_value == FRP_STATE_NEG) || (state_value == FRP_STATE_POS))
        state_gain_q16 = FRP_M31_STATE_FREQUENCY_GAIN_Q16;
      else
        state_gain_q16 = FRP_M31_Q16_ZERO;

      if (switch_activity[cell_index])
        switch_gain_q16 = FRP_M31_SWITCH_FREQUENCY_GAIN_Q16;
      else
        switch_gain_q16 = FRP_M31_Q16_ZERO;

      target_frequency_q16 = FRP_M31_BASE_FREQUENCY_Q16
        + state_gain_q16 + switch_gain_q16;
      // The difference of two signed Q16 words may require 33 bits.
      // Keep the difference and product wide until rounding, so a valid
      // negative frequency cannot wrap the correction toward the wrong sign.
      frequency_delta_q16 =
        {{32{target_frequency_q16[31]}}, target_frequency_q16} -
        {{32{frequency_q[cell_index][31]}}, frequency_q[cell_index]};
      filtered_delta_q16 = frp_m31_sat_s32(
        frp_m31_round_shift_s64(
          frequency_delta_q16 * FRP_M31_DELAY_ALPHA_Q16,
          FRP_M31_Q16_FRACTION_BITS
        )
      );
      frequency_d[cell_index] = frp_m31_sat_s32(
        {{32{frequency_q[cell_index][31]}}, frequency_q[cell_index]} +
        {{32{filtered_delta_q16[31]}}, filtered_delta_q16}
      );

      velocity_q16 = frp_m31_mul_q16(
        FRP_M31_BASE_VELOCITY_GAIN_Q16,
        frequency_d[cell_index]
      ) + frp_m31_scheduler_push_q16(scheduler_state) + coupling_q16[cell_index];
      phase_step = frp_m31_velocity_to_phase_word(velocity_q16);
      phase_d[cell_index] = phase_q[cell_index] + phase_step;
    end
  end

  for (genvar level = 1; level <= DEPTH; level++) begin : g_level
    for (genvar group = 0; group < (CELLS >> level); group++) begin : g_group
      localparam int INDEX = CELLS - (CELLS >> (level-1)) + group;
      logic signed [63:0] sum_cos_q30;
      logic signed [63:0] sum_sin_q30;
      always_comb begin
        sum_cos_q30 = 64'sd0;
        sum_sin_q30 = 64'sd0;
        for (int member = 0; member < (1 << level); member++) begin
          sum_cos_q30 += 64'(cosine_q30[(group << level)+member]);
          sum_sin_q30 += 64'(sine_q30[(group << level)+member]);
        end
        coherence_square_q60[INDEX] =
          coherence_square_from_sums(sum_cos_q30, sum_sin_q30, 1 << level);
      end
    end
  end

  always_comb begin : coherence_combinational
    logic signed [63:0] group_sum_q30;
    logic signed [63:0] mean_q30;
    logic signed [63:0] deviation_q30;
    logic [63:0] square_sum_q60;
    logic signed [31:0] minimum_q30;
    logic signed [31:0] maximum_q30;
    logic signed [63:0] cluster_difference_q30;

    level_mean_coherence_q30 = '0;
    level_min_coherence_q30 = '0;
    level_max_coherence_q30 = '0;
    for (int level = 1; level <= DEPTH; level++) begin
      group_sum_q30 = 64'sd0;
      minimum_q30 = FRP_M31_Q30_ONE;
      maximum_q30 = 32'sd0;
      for (int group = 0; group < (CELLS >> level); group++) begin
        group_sum_q30 += 64'(coherence_value_q30[CELLS-(CELLS >> (level-1))+group]);
        if (coherence_value_q30[CELLS-(CELLS >> (level-1))+group] < minimum_q30)
          minimum_q30 = coherence_value_q30[CELLS-(CELLS >> (level-1))+group];
        if (coherence_value_q30[CELLS-(CELLS >> (level-1))+group] > maximum_q30)
          maximum_q30 = coherence_value_q30[CELLS-(CELLS >> (level-1))+group];
      end
      mean_q30 = round_div_s64(group_sum_q30, CELLS >> level);
      square_sum_q60 = 64'd0;
      for (int group = 0; group < (CELLS >> level); group++) begin
        deviation_q30 = 64'(coherence_value_q30[CELLS-(CELLS >> (level-1))+group]) - mean_q30;
        square_sum_q60 += 64'(deviation_q30 * deviation_q30);
      end
      level_variance_q60[level-1] = square_sum_q60 / 64'(CELLS >> level);
      level_mean_coherence_q30[(level-1)*32 +: 32] = 32'(mean_q30);
      level_min_coherence_q30[(level-1)*32 +: 32] = minimum_q30;
      level_max_coherence_q30[(level-1)*32 +: 32] = maximum_q30;
    end
    pair_coherence_q30 = level_mean_coherence_q30[0 +: 32];
    cluster_coherence_q30 = level_mean_coherence_q30[32 +: 32];
    global_coherence_q30 = coherence_value_q30[GROUPS-1];
    cluster_difference_q30 = 64'(coherence_value_q30[PAIRS]) -
                             64'(coherence_value_q30[PAIRS+1]);
    if (cluster_difference_q30 < 0) cluster_difference_q30 = -cluster_difference_q30;
    if (CELLS == 8)
      organization_dispersion_q30 = 32'(round_div_s64(cluster_difference_q30, 2));
    else
      organization_dispersion_q30 = $signed(level_dispersion_q30[32 +: 32]);
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin
        phase_q[cell_index] <= 32'(cell_index) * RESET_PHASE_STEP;
        frequency_q[cell_index] <= FRP_M31_BASE_FREQUENCY_Q16;
      end
    end else if (load_valid) begin
      for (int cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin
        phase_q[cell_index] <= phase_load[(cell_index*32) +: 32];
        frequency_q[cell_index] <= frequency_load_q16[(cell_index*32) +: 32];
      end
    end else if (tick_enable) begin
      for (int cell_index = 0; cell_index < CELLS; cell_index = cell_index + 1) begin
        phase_q[cell_index] <= phase_d[cell_index];
        frequency_q[cell_index] <= frequency_d[cell_index];
      end
    end
  end

endmodule

`endif

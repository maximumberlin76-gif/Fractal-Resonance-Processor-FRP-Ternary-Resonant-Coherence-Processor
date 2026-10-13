 // SPDX-License-Identifier: Apache-2.0
 // FRP M32 integrated registered-target composition over the M31 RTL contour.

`ifndef FRP_M32_CORE_SV
`define FRP_M32_CORE_SV

`timescale 1ns / 1ps

`include "frp_m31_execution_core.sv"
`include "frp_m31_phase_interference.sv"
`include "frp_m32_registered_target_request_path.sv"
`include "frp_m31_thermal_proxy.sv"
`include "frp_m31_local_thermal_field.sv"
`include "frp_m31_local_gamma_drift.sv"
`include "frp_m31_local_thermal_attenuation.sv"
`include "frp_m31_stability.sv"
`include "frp_m31_global_stability.sv"

module frp_m32_core #(
  parameter int CELLS = 8,
  parameter int REQUEST_LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m31_pkg::FRP_M31_COUNTER_BITS,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode,

  input logic phase_load_valid,
  input logic [(CELLS*32)-1:0] phase_load,
  input logic [(CELLS*32)-1:0] frequency_load_q16,
  input logic [(CELLS*32)-1:0] gamma_effective_word,
  input logic [(CELLS*32)-1:0] thermal_node_factor_q30,

  input logic auto_target_enable,
  input logic [REQUEST_LANES-1:0] external_request_valid,
  input logic [
    (REQUEST_LANES*CELL_INDEX_BITS)-1:0
  ] external_request_cell_index,
  input logic [
    (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] external_request_target,
  input logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] external_target_bank,

  output logic [(CELLS*32)-1:0] phase_word_q,
  output logic [(CELLS*32)-1:0] frequency_current_q16,
  output logic [(CELLS*32)-1:0] coupling_field_q16,
  output logic [(CELLS*32)-1:0] phase_projection_q30,
  output logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] phase_target_source,

  output logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] registered_target_q,
  output logic registered_target_valid_q,
  output logic phase_target_domain_valid,
  output logic registered_target_domain_valid,
  output logic target_capture_accepted,
  output logic target_capture_rejected,
  output logic [COUNTER_BITS-1:0] accepted_target_capture_events_q,
  output logic [COUNTER_BITS-1:0] rejected_target_capture_events_q,
  output logic registered_request_enable,

  output logic [REQUEST_LANES-1:0] phase_request_valid,
  output logic [
    (REQUEST_LANES*CELL_INDEX_BITS)-1:0
  ] phase_request_cell_index,
  output logic [
    (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] phase_request_target,

  output logic [REQUEST_LANES-1:0] execution_request_valid,
  output logic [
    (REQUEST_LANES*CELL_INDEX_BITS)-1:0
  ] execution_request_cell_index,
  output logic [
    (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] execution_request_target,
  output logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] execution_target_bank,

  output logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] state_out,
  output logic [
    (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0
  ] pending_route_out,

  output frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode_q,
  output frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state_q,
  output logic [COUNTER_BITS-1:0] ticks_recorded_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_free_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_balance_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_commit_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_excite_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q,

  output logic [REQUEST_LANES-1:0] request_accept,
  output logic [REQUEST_LANES-1:0] request_reject,
  output logic [CELLS-1:0] accepted_cell_mask,
  output logic [CELLS-1:0] neutral_routed_cell_mask,
  output logic [CELLS-1:0] accepted_change_mask,
  output logic [COUNTER_BITS-1:0] accepted_changes,
  output logic [COUNTER_BITS-1:0] capacity_remaining,
  output logic capacity_exhausted,
  output logic [COUNTER_BITS-1:0] switch_load_numerator,

  output logic [COUNTER_BITS-1:0] requested_direct_events,
  output logic [COUNTER_BITS-1:0] prevented_direct_events,
  output logic [COUNTER_BITS-1:0] neutral_routed_events,
  output logic [COUNTER_BITS-1:0] actual_direct_events,
  output logic [COUNTER_BITS-1:0] reserved_state_events,
  output logic [COUNTER_BITS-1:0] queue_overflow_events,
  output logic [
    frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0
  ] invariant_flags,

  output logic signed [31:0] pair_coherence_q30,
  output logic signed [31:0] cluster_coherence_q30,
  output logic signed [31:0] global_coherence_q30,
  output logic signed [31:0] organization_dispersion_q30,
  output logic signed [31:0] normalized_cycle_cost_q16,
  output logic signed [31:0] temperature_proxy_q16,
  output logic signed [31:0] peak_temperature_proxy_q16,
  output logic [31:0] thermal_sample_count_q,
  output logic signed [31:0] coherence_capacity_q16,
  output logic signed [31:0] pressure_q16,
  output logic signed [31:0] stability_margin_q16,
  output logic stable,

  output wire [(CELLS*32)-1:0] local_heat_q16,
  output wire [(CELLS*32)-1:0] local_heat_peak_q16,
  output wire [(CELLS*32)-1:0] local_generated_power_q16,
  output wire [(CELLS*32)-1:0] local_thermal_dissipation_q16,
  output wire [(CELLS*32)-1:0] local_thermal_diffusion_q16,
  output wire [(CELLS*32)-1:0] local_thermal_overload_q16,
  output wire [(CELLS*32)-1:0] local_next_heat_q16,
  output wire [(CELLS*32)-1:0] local_next_overload_q16,
  output logic [(CELLS*32)-1:0] local_frequency_lag_q16,
  output wire signed [31:0] local_mean_heat_q16,
  output wire signed [31:0] local_mean_heat_peak_q16,
  output wire signed [31:0] local_maximum_heat_peak_q16,

  input logic local_gamma_enable = 1'b0,
  input logic gamma_update_valid = 1'b0,
  input logic [(CELLS*32)-1:0] gamma_targets_q16 = '0,
  output wire [(CELLS*32)-1:0] local_gamma_noise_target_q16,
  output wire [(CELLS*32)-1:0] local_gamma_noise_state_q16,
  output wire [(CELLS*32)-1:0] local_gamma_drift_word,
  output wire [(CELLS*32)-1:0] local_gamma_effective_word,
  output wire [(CELLS*32)-1:0] local_next_gamma_drift_word,
  output wire [(CELLS*32)-1:0] local_next_gamma_effective_word,
  output wire [(CELLS*32)-1:0] phase_gamma_effective_word,

  input logic local_thermal_enable = 1'b0,
  output wire [(CELLS*32)-1:0] local_thermal_node_factor_q30,
  output wire [(CELLS*32)-1:0] local_next_thermal_node_factor_q30,
  output wire [(CELLS*32)-1:0] phase_thermal_node_factor_q30,

  output wire [((CELLS-1)*32)-1:0] group_coherence_q30,
  output wire [($clog2(CELLS)*32)-1:0] level_mean_coherence_q30,
  output wire [($clog2(CELLS)*32)-1:0] level_min_coherence_q30,
  output wire [($clog2(CELLS)*32)-1:0] level_max_coherence_q30,
  output wire [($clog2(CELLS)*32)-1:0] level_dispersion_q30,

  output wire signed [31:0] local_coherence_compression_q30,
  output wire signed [31:0] local_effective_coherence_q30,
  output wire signed [31:0] local_coherence_capacity_q16,
  output wire signed [31:0] local_pressure_q16,
  output wire signed [31:0] local_stability_margin_q16,
  output wire local_stable,
  output wire signed [31:0] local_previous_margin_q16,
  output logic local_stability_valid_q,
  output logic [31:0] local_stability_sample_count_q,
  output logic signed [31:0] local_stability_raw_coherence_q30,
  output logic signed [31:0] local_stability_cluster_coherence_q30,
  output logic signed [31:0] local_stability_mean_heat_q16,
  output logic signed [31:0] local_stability_mean_overload_q16,
  output logic signed [31:0] local_stability_mean_lag_q16,
  output logic signed [31:0] local_stability_neutral_fraction_q30,
  output logic signed [31:0] local_stability_compression_arg_q16,
  output logic signed [31:0] local_stability_switch_load_q16
);

  logic [63:0] normalized_cycle_cost_wide;

  import frp_m31_fixed_point_pkg::*;

  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32))
      $fatal(1, "FRP M32 core requires 8, 16 or 32 cells");
  end

  // The local thermal field uses the frequency selected for this edge.
  // A phase load selects frequency_load_q16; otherwise the phase engine's
  // rounded delay update is used. Both paths use the retained ternary state
  // and accepted changes visible before the edge, as in the M32 phase path.
  // A disabled tick holds thermal history; clear_counters does not clear it.
  for (genvar lane = 0; lane < CELLS; lane = lane + 1) begin : g_local_frequency_lag
    logic signed [31:0] selected_frequency_q16;
    logic signed [31:0] target_frequency_q16;
    logic signed [31:0] current_frequency_q16;
    logic signed [31:0] correction_q16;
    logic signed [31:0] state_gain_q16;
    logic signed [31:0] switch_gain_q16;
    logic signed [63:0] difference_q16;
    logic signed [63:0] residual_q16;
    logic [1:0] cell_state;

    always_comb begin
      cell_state = state_out[lane*2 +: 2];
      current_frequency_q16 = frequency_current_q16[lane*32 +: 32];
      state_gain_q16 = ((cell_state == frp_m31_pkg::FRP_STATE_NEG) ||
                        (cell_state == frp_m31_pkg::FRP_STATE_POS))
        ? FRP_M31_STATE_FREQUENCY_GAIN_Q16 : FRP_M31_Q16_ZERO;
      switch_gain_q16 = accepted_change_mask[lane]
        ? FRP_M31_SWITCH_FREQUENCY_GAIN_Q16 : FRP_M31_Q16_ZERO;
      target_frequency_q16 = FRP_M31_BASE_FREQUENCY_Q16
        + state_gain_q16 + switch_gain_q16;
      difference_q16 = {{32{target_frequency_q16[31]}}, target_frequency_q16}
        - {{32{current_frequency_q16[31]}}, current_frequency_q16};
      correction_q16 = frp_m31_sat_s32(frp_m31_round_shift_s64(
        difference_q16 * FRP_M31_DELAY_ALPHA_Q16, FRP_M31_Q16_FRACTION_BITS
      ));
      selected_frequency_q16 = frp_m31_sat_s32(
        {{32{current_frequency_q16[31]}}, current_frequency_q16}
        + {{32{correction_q16[31]}}, correction_q16}
      );
      if (phase_load_valid)
        selected_frequency_q16 = frequency_load_q16[lane*32 +: 32];
      residual_q16 = {{32{target_frequency_q16[31]}}, target_frequency_q16}
        - {{32{selected_frequency_q16[31]}}, selected_frequency_q16};
      if (residual_q16 < 0)
        residual_q16 = -residual_q16;
      local_frequency_lag_q16[lane*32 +: 32] = residual_q16[31:0];
    end
  end

  frp_m31_local_thermal_field #(
    .CELLS(CELLS)
  ) u_local_thermal_field (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .switch_activity(accepted_change_mask),
    .frequency_lag_q16(local_frequency_lag_q16),
    .heat_q16(local_heat_q16),
    .local_heat_peak_q16(local_heat_peak_q16),
    .generated_power_q16(local_generated_power_q16),
    .thermal_dissipation_q16(local_thermal_dissipation_q16),
    .thermal_diffusion_q16(local_thermal_diffusion_q16),
    .thermal_overload_q16(local_thermal_overload_q16),
    .next_heat_q16(local_next_heat_q16),
    .next_overload_q16(local_next_overload_q16),
    .mean_heat_q16(local_mean_heat_q16),
    .mean_heat_peak_q16(local_mean_heat_peak_q16),
    .maximum_local_heat_q16(local_maximum_heat_peak_q16)
  );

  // Thermal and gamma candidates feed the same enabled phase update.
  // Both local histories advance on tick_enable in either source mode.
  // Omitted local_gamma_enable selects the external gamma interface.
  // gamma_update_valid is sampled with tick_enable; targets are signed Q16.16.
  frp_m31_local_gamma_drift #(
    .CELLS(CELLS)
  ) u_local_gamma_drift (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .gamma_update_valid(gamma_update_valid),
    .gamma_targets_q16(gamma_targets_q16),
    .thermal_overload_q16(local_next_overload_q16),
    .gamma_noise_target_q16(local_gamma_noise_target_q16),
    .gamma_noise_state_q16(local_gamma_noise_state_q16),
    .gamma_drift_word(local_gamma_drift_word),
    .gamma_effective_word(local_gamma_effective_word),
    .next_gamma_drift_word(local_next_gamma_drift_word),
    .next_gamma_effective_word(local_next_gamma_effective_word)
  );

  assign phase_gamma_effective_word = local_gamma_enable
    ? local_next_gamma_effective_word : gamma_effective_word;

  // The next local overload supplies attenuation for the same phase edge.
  // Attenuation history advances on tick_enable in either source mode.
  // Omitted local_thermal_enable selects the external thermal interface.
  frp_m31_local_thermal_attenuation #(
    .CELLS(CELLS)
  ) u_local_thermal_attenuation (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .thermal_overload_q16(local_next_overload_q16),
    .thermal_node_factor_q30(local_thermal_node_factor_q30),
    .next_thermal_node_factor_q30(local_next_thermal_node_factor_q30)
  );

  assign phase_thermal_node_factor_q30 = local_thermal_enable
    ? local_next_thermal_node_factor_q30 : thermal_node_factor_q30;

  frp_m32_registered_target_request_path #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS)
  ) u_registered_target_request_path (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .phase_target_valid(1'b1),
    .phase_target_source(phase_target_source),
    .auto_target_enable(auto_target_enable),
    .retained_state(state_out),
    .pending_route(pending_route_out),
    .scheduler_state(scheduler_state_q),
    .registered_target_q(registered_target_q),
    .registered_target_valid_q(registered_target_valid_q),
    .phase_target_domain_valid(phase_target_domain_valid),
    .registered_target_domain_valid(registered_target_domain_valid),
    .capture_accepted(target_capture_accepted),
    .capture_rejected(target_capture_rejected),
    .accepted_capture_events_q(accepted_target_capture_events_q),
    .rejected_capture_events_q(rejected_target_capture_events_q),
    .registered_request_enable(registered_request_enable),
    .phase_request_valid(phase_request_valid),
    .phase_request_cell_index(phase_request_cell_index),
    .phase_request_target(phase_request_target)
  );

  always_comb begin
    if (auto_target_enable) begin
      execution_request_valid = phase_request_valid;
      execution_request_cell_index = phase_request_cell_index;
      execution_request_target = phase_request_target;
      execution_target_bank = registered_target_q;
    end else begin
      execution_request_valid = external_request_valid;
      execution_request_cell_index = external_request_cell_index;
      execution_request_target = external_request_target;
      execution_target_bank = external_target_bank;
    end

    normalized_cycle_cost_wide = switch_load_numerator;
    normalized_cycle_cost_wide = normalized_cycle_cost_wide << 16;
    normalized_cycle_cost_q16 =
      (normalized_cycle_cost_wide + (CELLS / 2)) / CELLS;
  end

  frp_m31_execution_core #(
    .CELLS(CELLS),
    .STATE_BITS(frp_m31_pkg::FRP_M31_STATE_BITS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS)
  ) u_execution (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(scheduler_mode),
    .request_valid(execution_request_valid),
    .request_cell_index(execution_request_cell_index),
    .request_target(execution_request_target),
    .target_q(execution_target_bank),
    .state_out(state_out),
    .pending_route_out(pending_route_out),
    .scheduler_mode_q(scheduler_mode_q),
    .scheduler_state_q(scheduler_state_q),
    .ticks_recorded_q(ticks_recorded_q),
    .scheduler_count_free_q(scheduler_count_free_q),
    .scheduler_count_balance_q(scheduler_count_balance_q),
    .scheduler_count_commit_q(scheduler_count_commit_q),
    .scheduler_count_excite_q(scheduler_count_excite_q),
    .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
    .request_accept(request_accept),
    .request_reject(request_reject),
    .accepted_cell_mask(accepted_cell_mask),
    .neutral_routed_cell_mask(neutral_routed_cell_mask),
    .accepted_change_mask(accepted_change_mask),
    .accepted_changes(accepted_changes),
    .capacity_remaining(capacity_remaining),
    .capacity_exhausted(capacity_exhausted),
    .switch_load_numerator(switch_load_numerator),
    .requested_direct_events(requested_direct_events),
    .prevented_direct_events(prevented_direct_events),
    .neutral_routed_events(neutral_routed_events),
    .actual_direct_events(actual_direct_events),
    .reserved_state_events(reserved_state_events),
    .queue_overflow_events(queue_overflow_events),
    .invariant_flags(invariant_flags)
  );

  frp_m31_phase_interference #(
    .CELLS(CELLS),
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_phase_interference (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .load_valid(phase_load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(phase_gamma_effective_word),
    .thermal_node_factor_q30(phase_thermal_node_factor_q30),
    .retained_state(state_out),
    .switch_activity(accepted_change_mask),
    .scheduler_state(scheduler_state_q),
    .phase_word_q(phase_word_q),
    .frequency_current_q16(frequency_current_q16),
    .coupling_field_q16(coupling_field_q16),
    .phase_projection_q30(phase_projection_q30),
    .phase_target(phase_target_source),
    .pair_coherence_q30(pair_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .global_coherence_q30(global_coherence_q30),
    .organization_dispersion_q30(organization_dispersion_q30),
    .group_coherence_q30(group_coherence_q30),
    .level_mean_coherence_q30(level_mean_coherence_q30),
    .level_min_coherence_q30(level_min_coherence_q30),
    .level_max_coherence_q30(level_max_coherence_q30),
    .level_dispersion_q30(level_dispersion_q30)
  );

  frp_m31_thermal_proxy u_thermal_proxy (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear(clear_counters),
    .normalized_cycle_cost_q16(normalized_cycle_cost_q16),
    .temperature_proxy_q16(temperature_proxy_q16),
    .peak_temperature_proxy_q16(peak_temperature_proxy_q16),
    .sample_count_q(thermal_sample_count_q)
  );

  frp_m31_stability #(
    .CELLS(CELLS)
  ) u_stability (
    .retained_state(state_out),
    .global_coherence_q30(global_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .temperature_proxy_q16(temperature_proxy_q16),
    .switch_load_q16(normalized_cycle_cost_q16),
    .coherence_capacity_q16(coherence_capacity_q16),
    .pressure_q16(pressure_q16),
    .stability_margin_q16(stability_margin_q16),
    .stable(stable)
  );

  // Local stability consumes the completed snapshot from the preceding edge.
  // Phase, retained state and local heat are registered by their source blocks.
  // Capture the pre-edge lag and switch load that produced that thermal sample.
  // A pending snapshot commits on the following edge even if tick_enable is low.
  // A phase-only load creates no sample; clear_counters leaves this history intact.
  // local_stability_valid_q identifies each result; the sample count wraps at 2^32.
  logic local_stability_pending_q;
  logic [(CELLS*32)-1:0] local_stability_lag_snapshot_q16;
  logic signed [31:0] local_stability_switch_snapshot_q16;
  wire signed [31:0] stability_mean_heat_d;
  wire signed [31:0] stability_mean_overload_d;
  wire signed [31:0] stability_mean_lag_d;
  wire signed [31:0] stability_neutral_fraction_d;
  wire signed [31:0] stability_compression_arg_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      local_stability_pending_q <= 1'b0;
      local_stability_lag_snapshot_q16 <= '0;
      local_stability_switch_snapshot_q16 <= 32'sd0;
      local_stability_valid_q <= 1'b0;
      local_stability_sample_count_q <= 32'd0;
      local_stability_raw_coherence_q30 <= 32'sd0;
      local_stability_cluster_coherence_q30 <= 32'sd0;
      local_stability_mean_heat_q16 <= 32'sd3277;
      local_stability_mean_overload_q16 <= 32'sd0;
      local_stability_mean_lag_q16 <= 32'sd0;
      local_stability_neutral_fraction_q30 <= 32'sd1073741824;
      local_stability_compression_arg_q16 <= 32'sd0;
      local_stability_switch_load_q16 <= 32'sd0;
    end else begin
      local_stability_pending_q <= tick_enable;
      local_stability_valid_q <= local_stability_pending_q;
      if (tick_enable) begin
        local_stability_lag_snapshot_q16 <= local_frequency_lag_q16;
        local_stability_switch_snapshot_q16 <= normalized_cycle_cost_q16;
      end
      if (local_stability_pending_q) begin
        local_stability_sample_count_q <= local_stability_sample_count_q + 32'd1;
        local_stability_raw_coherence_q30 <= global_coherence_q30;
        local_stability_cluster_coherence_q30 <= cluster_coherence_q30;
        local_stability_mean_heat_q16 <= stability_mean_heat_d;
        local_stability_mean_overload_q16 <= stability_mean_overload_d;
        local_stability_mean_lag_q16 <= stability_mean_lag_d;
        local_stability_neutral_fraction_q30 <= stability_neutral_fraction_d;
        local_stability_compression_arg_q16 <= stability_compression_arg_d;
        local_stability_switch_load_q16 <= local_stability_switch_snapshot_q16;
      end
    end
  end

  frp_m31_global_stability #(
    .CELLS(CELLS)
  ) u_local_global_stability (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(local_stability_pending_q),
    .retained_state(state_out),
    .raw_phase_coherence_q30(global_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .heat_q16(local_heat_q16),
    .thermal_overload_q16(local_thermal_overload_q16),
    .frequency_lag_q16(local_stability_lag_snapshot_q16),
    .switch_load_q16(local_stability_switch_snapshot_q16),
    .mean_heat_q16(stability_mean_heat_d),
    .mean_thermal_overload_q16(stability_mean_overload_d),
    .mean_frequency_lag_q16(stability_mean_lag_d),
    .neutral_fraction_q30(stability_neutral_fraction_d),
    .compression_arg_q16(stability_compression_arg_d),
    .next_coherence_compression_q30(),
    .next_effective_coherence_q30(),
    .next_coherence_capacity_q16(),
    .next_pressure_q16(),
    .next_stability_margin_q16(),
    .next_stable(),
    .coherence_compression_q30(local_coherence_compression_q30),
    .effective_coherence_q30(local_effective_coherence_q30),
    .coherence_capacity_q16(local_coherence_capacity_q16),
    .pressure_q16(local_pressure_q16),
    .stability_margin_q16(local_stability_margin_q16),
    .stable(local_stable),
    .previous_margin_q16(local_previous_margin_q16)
  );

endmodule

`endif

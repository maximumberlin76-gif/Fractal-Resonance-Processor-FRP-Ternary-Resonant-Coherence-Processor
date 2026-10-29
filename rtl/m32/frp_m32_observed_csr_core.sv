// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M32 observed computation core with atomic snapshot CSR readout.
// All computation controls and observed-core outputs retain their interfaces.
// The core, recorder and snapshot CSR share clk and rst_n.
// Snapshot commands: address 00, write exactly 1 to capture or 2 to release.
// Capture stores the recorder values present immediately before the bus edge.
// Consecutive valid/ready edges accept consecutive transactions.
// Readout map and error responses follow frp_m32_boundary_snapshot_csr.sv.
// Core computation proceeds while the captured snapshot is read or replaced.
// clear_counters is forwarded to the computation core and preserves recorder
// history and the snapshot. Release clears the snapshot copy; rst_n resets both.
// rst_n asserts asynchronously; its release is synchronized by the caller.
// Parameters and scheduler/active-zero behavior follow frp_m32_observed_core.

`ifndef FRP_M32_OBSERVED_CSR_CORE_SV
`define FRP_M32_OBSERVED_CSR_CORE_SV
`timescale 1ns/1ps
`include "frp_m32_observed_core.sv"
`include "frp_m32_boundary_snapshot_csr.sv"

module frp_m32_observed_csr_core #(
  parameter int CELLS = 8,
  parameter int REQUEST_LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m31_pkg::FRP_M31_COUNTER_BITS,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem",
  parameter int RECORDER_COUNT_BITS = 64
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
  output logic signed [31:0] local_stability_switch_load_q16,

  output logic record_sample_seen_q,
  output logic [RECORDER_COUNT_BITS-1:0] record_sample_count_q,
  output logic record_count_overflow_q,
  output logic signed [31:0] record_previous_margin_q16,
  output logic signed [31:0] record_minimum_margin_q16,
  output logic [63:0] record_minimum_margin_tick_q,
  output logic signed [31:0] record_peak_switch_load_q16,
  output logic [63:0] record_peak_switch_load_tick_q,

  output logic boundary_valid_q,
  output logic boundary_pulse_q,
  output logic [63:0] boundary_tick_q,
  output logic [1:0] boundary_scheduler_mode_q,
  output logic [2:0] boundary_scheduler_state_q,
  output logic signed [31:0] boundary_previous_margin_q16,
  output logic signed [31:0] boundary_margin_q16,
  output logic signed [31:0] boundary_capacity_q16,
  output logic signed [31:0] boundary_pressure_q16,
  output logic signed [31:0] boundary_mean_heat_q16,
  output logic signed [31:0] boundary_switch_load_q16,
  output logic [(CELLS*2)-1:0] boundary_retained_state_q,
  output logic [(CELLS*2)-1:0] boundary_pending_route_q,
  output logic record_alignment_error_q,

  input logic csr_valid,
  input logic csr_write,
  input logic [7:0] csr_addr,
  input logic [31:0] csr_wdata,
  output logic csr_ready,
  output logic csr_error,
  output logic [31:0] csr_rdata
);
  frp_m32_observed_core #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS),
    .SIN_LUT_FILE(SIN_LUT_FILE),
    .RECORDER_COUNT_BITS(RECORDER_COUNT_BITS)
  ) u_observed_core (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(auto_target_enable),
    .external_request_valid(external_request_valid),
    .external_request_cell_index(external_request_cell_index),
    .external_request_target(external_request_target),
    .external_target_bank(external_target_bank),
    .phase_word_q(phase_word_q),
    .frequency_current_q16(frequency_current_q16),
    .coupling_field_q16(coupling_field_q16),
    .phase_projection_q30(phase_projection_q30),
    .phase_target_source(phase_target_source),
    .registered_target_q(registered_target_q),
    .registered_target_valid_q(registered_target_valid_q),
    .phase_target_domain_valid(phase_target_domain_valid),
    .registered_target_domain_valid(registered_target_domain_valid),
    .target_capture_accepted(target_capture_accepted),
    .target_capture_rejected(target_capture_rejected),
    .accepted_target_capture_events_q(accepted_target_capture_events_q),
    .rejected_target_capture_events_q(rejected_target_capture_events_q),
    .registered_request_enable(registered_request_enable),
    .phase_request_valid(phase_request_valid),
    .phase_request_cell_index(phase_request_cell_index),
    .phase_request_target(phase_request_target),
    .execution_request_valid(execution_request_valid),
    .execution_request_cell_index(execution_request_cell_index),
    .execution_request_target(execution_request_target),
    .execution_target_bank(execution_target_bank),
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
    .invariant_flags(invariant_flags),
    .pair_coherence_q30(pair_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .global_coherence_q30(global_coherence_q30),
    .organization_dispersion_q30(organization_dispersion_q30),
    .normalized_cycle_cost_q16(normalized_cycle_cost_q16),
    .temperature_proxy_q16(temperature_proxy_q16),
    .peak_temperature_proxy_q16(peak_temperature_proxy_q16),
    .thermal_sample_count_q(thermal_sample_count_q),
    .coherence_capacity_q16(coherence_capacity_q16),
    .pressure_q16(pressure_q16),
    .stability_margin_q16(stability_margin_q16),
    .stable(stable),
    .local_heat_q16(local_heat_q16),
    .local_heat_peak_q16(local_heat_peak_q16),
    .local_generated_power_q16(local_generated_power_q16),
    .local_thermal_dissipation_q16(local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(local_thermal_diffusion_q16),
    .local_thermal_overload_q16(local_thermal_overload_q16),
    .local_next_heat_q16(local_next_heat_q16),
    .local_next_overload_q16(local_next_overload_q16),
    .local_frequency_lag_q16(local_frequency_lag_q16),
    .local_mean_heat_q16(local_mean_heat_q16),
    .local_mean_heat_peak_q16(local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(local_maximum_heat_peak_q16),
    .local_gamma_enable(local_gamma_enable),
    .gamma_update_valid(gamma_update_valid),
    .gamma_targets_q16(gamma_targets_q16),
    .local_gamma_noise_target_q16(local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(local_gamma_noise_state_q16),
    .local_gamma_drift_word(local_gamma_drift_word),
    .local_gamma_effective_word(local_gamma_effective_word),
    .local_next_gamma_drift_word(local_next_gamma_drift_word),
    .local_next_gamma_effective_word(local_next_gamma_effective_word),
    .phase_gamma_effective_word(phase_gamma_effective_word),
    .local_thermal_enable(local_thermal_enable),
    .local_thermal_node_factor_q30(local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(phase_thermal_node_factor_q30),
    .group_coherence_q30(group_coherence_q30),
    .level_mean_coherence_q30(level_mean_coherence_q30),
    .level_min_coherence_q30(level_min_coherence_q30),
    .level_max_coherence_q30(level_max_coherence_q30),
    .level_dispersion_q30(level_dispersion_q30),
    .local_coherence_compression_q30(local_coherence_compression_q30),
    .local_effective_coherence_q30(local_effective_coherence_q30),
    .local_coherence_capacity_q16(local_coherence_capacity_q16),
    .local_pressure_q16(local_pressure_q16),
    .local_stability_margin_q16(local_stability_margin_q16),
    .local_stable(local_stable),
    .local_previous_margin_q16(local_previous_margin_q16),
    .local_stability_valid_q(local_stability_valid_q),
    .local_stability_sample_count_q(local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(local_stability_switch_load_q16),
    .record_sample_seen_q(record_sample_seen_q),
    .record_sample_count_q(record_sample_count_q),
    .record_count_overflow_q(record_count_overflow_q),
    .record_previous_margin_q16(record_previous_margin_q16),
    .record_minimum_margin_q16(record_minimum_margin_q16),
    .record_minimum_margin_tick_q(record_minimum_margin_tick_q),
    .record_peak_switch_load_q16(record_peak_switch_load_q16),
    .record_peak_switch_load_tick_q(record_peak_switch_load_tick_q),
    .boundary_valid_q(boundary_valid_q),
    .boundary_pulse_q(boundary_pulse_q),
    .boundary_tick_q(boundary_tick_q),
    .boundary_scheduler_mode_q(boundary_scheduler_mode_q),
    .boundary_scheduler_state_q(boundary_scheduler_state_q),
    .boundary_previous_margin_q16(boundary_previous_margin_q16),
    .boundary_margin_q16(boundary_margin_q16),
    .boundary_capacity_q16(boundary_capacity_q16),
    .boundary_pressure_q16(boundary_pressure_q16),
    .boundary_mean_heat_q16(boundary_mean_heat_q16),
    .boundary_switch_load_q16(boundary_switch_load_q16),
    .boundary_retained_state_q(boundary_retained_state_q),
    .boundary_pending_route_q(boundary_pending_route_q),
    .record_alignment_error_q(record_alignment_error_q)
  );

  frp_m32_boundary_snapshot_csr #(
    .CELLS(CELLS),
    .RECORDER_COUNT_BITS(RECORDER_COUNT_BITS)
  ) u_snapshot_csr (
    .clk(clk),
    .rst_n(rst_n),
    .csr_valid(csr_valid),
    .csr_write(csr_write),
    .csr_addr(csr_addr),
    .csr_wdata(csr_wdata),
    .csr_ready(csr_ready),
    .csr_error(csr_error),
    .csr_rdata(csr_rdata),
    .record_sample_seen_q(record_sample_seen_q),
    .record_sample_count_q(record_sample_count_q),
    .record_count_overflow_q(record_count_overflow_q),
    .record_previous_margin_q16(record_previous_margin_q16),
    .record_minimum_margin_q16(record_minimum_margin_q16),
    .record_minimum_margin_tick_q(record_minimum_margin_tick_q),
    .record_peak_switch_load_q16(record_peak_switch_load_q16),
    .record_peak_switch_load_tick_q(record_peak_switch_load_tick_q),
    .boundary_valid_q(boundary_valid_q),
    .boundary_pulse_q(boundary_pulse_q),
    .boundary_tick_q(boundary_tick_q),
    .boundary_scheduler_mode_q(boundary_scheduler_mode_q),
    .boundary_scheduler_state_q(boundary_scheduler_state_q),
    .boundary_previous_margin_q16(boundary_previous_margin_q16),
    .boundary_margin_q16(boundary_margin_q16),
    .boundary_capacity_q16(boundary_capacity_q16),
    .boundary_pressure_q16(boundary_pressure_q16),
    .boundary_mean_heat_q16(boundary_mean_heat_q16),
    .boundary_switch_load_q16(boundary_switch_load_q16),
    .boundary_retained_state_q(boundary_retained_state_q),
    .boundary_pending_route_q(boundary_pending_route_q),
    .record_alignment_error_q(record_alignment_error_q)
  );
endmodule
`endif

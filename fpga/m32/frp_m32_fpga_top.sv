// SPDX-License-Identifier: Apache-2.0
// FRP M32 FPGA integration boundary for the complete registered-target core.
//
// The integrated phase engine supports 8, 16 and 32 cells. The default
// eight-cell profile exposes two request lanes and three-bit cell indexes.
// All core outputs are forwarded without added registers or output masking.
// The core retains its -1/0/1 encoding and free, 7/1, and 1/7 execution modes.
//
// Assert rst_n_async low at startup. Assertion is asynchronous; release
// propagates through two registers clocked by clk. core_ready rises after
// the second rising edge following release. The core can first sample an
// enabled operation on the following rising edge.
//
// Tick, counter clear, phase load, automatic request selection, and external
// request validity are blocked while core_ready is low. Pulses entirely
// within that interval are discarded. A control held high is presented to
// the core once core_ready is high; this wrapper does not queue operations.
//
// All inputs other than rst_n_async must be synchronous to clk. core_ready
// reports reset release, not phase-load completion or request acceptance.
// Local gamma and thermal selectors are independent synchronous controls.
// Omitted selectors choose the external gamma and thermal data inputs.
// gamma_update_valid is qualified by core_ready and is accepted only on an
// enabled tick; gamma_targets_q16 carries CELLS signed Q16.16 target words.
// A target-update pulse during reset release is discarded. A held request
// becomes visible after release and is sampled on the next enabled tick.
// Local thermal, gamma, and attenuation histories advance with enabled ticks
// in either source mode. Counter clear retains all three local histories.
// Retained values, next-update candidates, and selected phase inputs are
// forwarded separately, without an additional cycle of latency.
//
// Local stability results and their sample-valid/count outputs are forwarded
// directly. Their one-edge snapshot latency is provided by the core.
// Multiscale coherence outputs expose every dyadic group and level.
//
// Data buses and combinational status outputs retain the core's semantics
// during reset. SIN_LUT_FILE is passed directly to the phase engine.

`ifndef FRP_M32_FPGA_TOP_SV
`define FRP_M32_FPGA_TOP_SV

`timescale 1ns / 1ps

`include "frp_m32_core.sv"

module frp_m32_fpga_top #(
  parameter int CELLS = 8,
  parameter int REQUEST_LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m31_pkg::FRP_M31_COUNTER_BITS,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input logic clk,
  input logic rst_n_async,
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

  output logic core_ready,
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

  logic [1:0] reset_sync_q;
  logic rst_n_core;
  logic tick_enable_core;
  logic clear_counters_core;
  logic phase_load_valid_core;
  logic auto_target_enable_core;
  logic gamma_update_valid_core;
  logic [REQUEST_LANES-1:0] external_request_valid_core;

`ifndef SYNTHESIS
  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32))
      $fatal(1, "FRP M32 FPGA top requires 8, 16 or 32 cells");
    if (REQUEST_LANES != frp_m31_pkg::frp_calc_request_lanes(CELLS))
      $fatal(1, "FRP M32 FPGA top request-lane count mismatch");
    if (CELL_INDEX_BITS != ((CELLS <= 1) ? 1 : $clog2(CELLS)))
      $fatal(1, "FRP M32 FPGA top cell-index width mismatch");
    if (COUNTER_BITS < 1)
      $fatal(1, "FRP M32 FPGA top requires COUNTER_BITS >= 1");
  end
`endif

  // The first stage only feeds the second stage. All core reset consumers
  // and input qualification gates use the second stage.
  always_ff @(posedge clk or negedge rst_n_async) begin
    if (!rst_n_async)
      reset_sync_q <= 2'b00;
    else
      reset_sync_q <= {reset_sync_q[0], 1'b1};
  end

  assign rst_n_core = reset_sync_q[1];
  assign core_ready = rst_n_core;

  assign tick_enable_core = tick_enable && core_ready;
  assign clear_counters_core = clear_counters && core_ready;
  assign phase_load_valid_core = phase_load_valid && core_ready;
  assign auto_target_enable_core = auto_target_enable && core_ready;
  assign gamma_update_valid_core = gamma_update_valid && core_ready;
  assign external_request_valid_core =
    external_request_valid & {REQUEST_LANES{core_ready}};

  frp_m32_core #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS),
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_m32_core (
    .clk(clk),
    .rst_n(rst_n_core),
    .tick_enable(tick_enable_core),
    .clear_counters(clear_counters_core),
    .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid_core),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(auto_target_enable_core),
    .external_request_valid(external_request_valid_core),
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
    .local_gamma_noise_target_q16(local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(local_gamma_noise_state_q16),
    .local_gamma_drift_word(local_gamma_drift_word),
    .local_gamma_effective_word(local_gamma_effective_word),
    .local_next_gamma_drift_word(local_next_gamma_drift_word),
    .local_next_gamma_effective_word(local_next_gamma_effective_word),
    .phase_gamma_effective_word(phase_gamma_effective_word),
    .local_thermal_node_factor_q30(local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(phase_thermal_node_factor_q30),
    .local_gamma_enable(local_gamma_enable),
    .gamma_update_valid(gamma_update_valid_core),
    .gamma_targets_q16(gamma_targets_q16),
    .local_thermal_enable(local_thermal_enable),
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
    .local_stability_switch_load_q16(local_stability_switch_load_q16)
  );

endmodule : frp_m32_fpga_top

`endif

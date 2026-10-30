// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 internal MT19937 gamma, local thermal feedback and atomic snapshot CSR.
// All signals are synchronous to clk except the asynchronous active-low reset.
// Restore a post-initialization Python checkpoint through the 624-word load port.
// checkpoint_load_begin aborts any prefetched bank and blocks ticks on that edge.
// A full valid checkpoint is required before any tick can be accepted.
//
// tick_valid/tick_ready form a rising-edge handshake. While waiting, hold the
// tick's controls and payload stable; a pulse with tick_ready low is not queued.
// Gamma targets update on accepted logical ticks 0, 8, 16, ... after reset.
// A single bank is prefetched; an update tick waits until that bank is complete.
// No physical clock stall advances the logical cadence or consumes a bank.
// clear_counters, phase loads and checkpoint reloads retain the logical cadence.
// A checkpoint reload supplies the PRNG state preceding the NEXT gamma update;
// it retains the core's execution, thermal, gamma and stability histories.
// Reset restarts both the core and gamma cadence and requires a fresh checkpoint.
//
// phase_load_valid/phase_load_ready is a separate rising-edge handshake.
// With tick_valid high the phase load joins that accepted tick; with tick_valid
// low it is a phase-only load, including while the checkpoint is being loaded.
// checkpoint_load_begin blocks phase-load acceptance on its own edge.
// Counter clear retains the existing core's independent control semantics.
// Both local gamma and local thermal feedback are enabled in this composition.
// All existing core outputs are forwarded without added output registers.
// A pending stability snapshot may retire on a clock with no accepted tick.
// The boundary recorder observes accepted ticks with its two-edge pipeline.
// A stalled tick_valid advances neither the recorder tag nor gamma cadence.
// A pending recorder sample may retire during checkpoint loading or CSR reads.
// Checkpoint begin/reload and clear_counters preserve recorder and snapshot;
// rst_n resets the full composition, including the internal gamma source.
// CSR shares clk/rst_n and is independent of tick/phase/checkpoint handshakes.
// Address 00 writes exactly 1 to capture or 2 to release the snapshot copy.
// Capture uses recorder values immediately before the accepting clock edge.
// Read map, error responses and geometry follow frp_m32_boundary_snapshot_csr.
// CSR remains accessible while gamma is unconfigured or waiting for a bank.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CORE_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CORE_SV
`timescale 1ns/1ps
`include "frp_m32_observed_csr_core.sv"
`include "frp_m32_gamma_target_source.sv"

module frp_m32_internal_gamma_observed_csr_core #(
  parameter int CELLS = 8,
  parameter int REQUEST_LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m31_pkg::FRP_M31_COUNTER_BITS,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem",
  parameter int RECORDER_COUNT_BITS = 64
) (
  input logic clk,
  input logic rst_n,
  input logic tick_valid,
  input logic clear_counters,
  input frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode,
  input logic phase_load_valid,
  input logic [(CELLS*32)-1:0] phase_load,
  input logic [(CELLS*32)-1:0] frequency_load_q16,
  input logic auto_target_enable,
  input logic [REQUEST_LANES-1:0] external_request_valid,
  input logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] external_request_cell_index,
  input logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] external_request_target,
  input logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] external_target_bank,
  output logic [(CELLS*32)-1:0] phase_word_q,
  output logic [(CELLS*32)-1:0] frequency_current_q16,
  output logic [(CELLS*32)-1:0] coupling_field_q16,
  output logic [(CELLS*32)-1:0] phase_projection_q30,
  output logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_target_source,
  output logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] registered_target_q,
  output logic registered_target_valid_q,
  output logic phase_target_domain_valid,
  output logic registered_target_domain_valid,
  output logic target_capture_accepted,
  output logic target_capture_rejected,
  output logic [COUNTER_BITS-1:0] accepted_target_capture_events_q,
  output logic [COUNTER_BITS-1:0] rejected_target_capture_events_q,
  output logic registered_request_enable,
  output logic [REQUEST_LANES-1:0] phase_request_valid,
  output logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] phase_request_cell_index,
  output logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_request_target,
  output logic [REQUEST_LANES-1:0] execution_request_valid,
  output logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] execution_request_cell_index,
  output logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_request_target,
  output logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_target_bank,
  output logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] state_out,
  output logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] pending_route_out,
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
  output logic [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ] invariant_flags,
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
  output wire [(CELLS*32)-1:0] local_gamma_noise_target_q16,
  output wire [(CELLS*32)-1:0] local_gamma_noise_state_q16,
  output wire [(CELLS*32)-1:0] local_gamma_drift_word,
  output wire [(CELLS*32)-1:0] local_gamma_effective_word,
  output wire [(CELLS*32)-1:0] local_next_gamma_drift_word,
  output wire [(CELLS*32)-1:0] local_next_gamma_effective_word,
  output wire [(CELLS*32)-1:0] phase_gamma_effective_word,
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
  input logic checkpoint_load_begin,
  input logic [9:0] checkpoint_index,
  input logic checkpoint_load_valid,
  input logic [31:0] checkpoint_load_word,
  output wire checkpoint_load_ready,
  output wire gamma_configured,
  output wire gamma_load_error,
  output wire gamma_source_busy,
  output wire gamma_bank_valid,
  output wire tick_ready,
  output wire tick_accepted,
  output wire phase_load_ready,
  output wire phase_load_accepted,
  output wire gamma_update_accepted,
  output logic [2:0] gamma_tick_phase_q,

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
  wire source_request_ready;
  wire source_request_valid;
  wire [CELLS*32-1:0] source_targets_q16;

  assign tick_ready = rst_n && !checkpoint_load_begin && gamma_configured
    && ((gamma_tick_phase_q != 3'd0) || gamma_bank_valid);
  assign tick_accepted = tick_valid && tick_ready;
  assign gamma_update_accepted = tick_accepted && (gamma_tick_phase_q == 3'd0);
  assign phase_load_ready = rst_n && !checkpoint_load_begin
    && (!tick_valid || tick_ready);
  assign phase_load_accepted = phase_load_valid && phase_load_ready;
  assign source_request_valid = source_request_ready && gamma_configured
    && !gamma_source_busy && !gamma_bank_valid;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      gamma_tick_phase_q <= 3'd0;
    else if (tick_accepted)
      gamma_tick_phase_q <= gamma_tick_phase_q + 3'd1;
  end

  frp_m32_gamma_target_source #(.CELLS(CELLS)) u_gamma_source (
    .clk(clk),
    .rst_n(rst_n),
    .load_begin(checkpoint_load_begin),
    .checkpoint_index(checkpoint_index),
    .load_valid(checkpoint_load_valid),
    .load_word(checkpoint_load_word),
    .load_ready(checkpoint_load_ready),
    .configured(gamma_configured),
    .load_error(gamma_load_error),
    .request_valid(source_request_valid),
    .request_ready(source_request_ready),
    .busy(gamma_source_busy),
    .bank_valid(gamma_bank_valid),
    .bank_ready(gamma_update_accepted),
    .gamma_targets_q16(source_targets_q16)
  );

  frp_m32_observed_csr_core #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS),
    .SIN_LUT_FILE(SIN_LUT_FILE),
    .RECORDER_COUNT_BITS(RECORDER_COUNT_BITS)
  ) u_core (
    .tick_enable(tick_accepted),
    .phase_load_valid(phase_load_accepted),
    .gamma_effective_word({CELLS{32'd0}}),
    .thermal_node_factor_q30({CELLS{32'h40000000}}),
    .local_gamma_enable(1'b1),
    .gamma_update_valid(gamma_update_accepted),
    .gamma_targets_q16(source_targets_q16),
    .local_thermal_enable(1'b1),
    .*
  );
endmodule
`endif

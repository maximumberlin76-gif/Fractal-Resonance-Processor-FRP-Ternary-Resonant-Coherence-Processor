// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M32 observed-core integration and deterministic replay testbench.
// Profiles: 8/16/32/64 cells; free, 7/1 and 1/7 scheduler modes.
// Compare all 103 original core outputs with a separate frp_m32_core instance.
// A testbench queue associates each completed snapshot with its accepted tick.
// The queue checks the two-edge recorder latency and pre-edge scheduler metadata.
// Recorder expectations use the original core's public stability outputs and
// independently retained tick/state/pending/heat/switch snapshots.
// Check all 22 observation outputs on every comparison, including reset edges.
// Exercise counter clears, phase-only loads, contiguous ticks and pause/drain.
// Reset with zero, one and two in-flight snapshots; check sample conservation.
// Check both active-zero route legs and forbid direct -1 <-> 1 transitions.
// FNV-1a-style word hashing covers every compared core/recorder observation.
// A repeated run emits the same PASS record and 64-bit trajectory signature.
// Build from the repository root with Verilator --binary --timing --assert,
// -Irtl/m31 -Irtl/m32 --top-module frp_m32_observed_core_tb -GCELLS=8.

`ifndef FRP_M32_OBSERVED_CORE_TB_SV
`define FRP_M32_OBSERVED_CORE_TB_SV
`timescale 1ns/1ps
`include "frp_m32_observed_core.sv"
module frp_m32_observed_core_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int REQUEST_LANES=frp_calc_request_lanes(CELLS);
  localparam int CELL_INDEX_BITS=$clog2(CELLS);
  localparam int COUNTER_BITS=32;
  localparam int RECORDER_COUNT_BITS=64;
  logic clk = '0;
  logic rst_n = '0;
  logic tick_enable = '0;
  logic clear_counters = '0;
  frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  logic phase_load_valid = '0;
  logic [(CELLS*32)-1:0] phase_load = '0;
  logic [(CELLS*32)-1:0] frequency_load_q16 = '0;
  logic [(CELLS*32)-1:0] gamma_effective_word = '0;
  logic [(CELLS*32)-1:0] thermal_node_factor_q30 = '0;
  logic auto_target_enable = '0;
  logic [REQUEST_LANES-1:0] external_request_valid = '0;
  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] external_request_cell_index = '0;
  logic [(REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] external_request_target = '0;
  logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] external_target_bank = '0;
  logic local_gamma_enable = '0;
  logic gamma_update_valid = '0;
  logic [(CELLS*32)-1:0] gamma_targets_q16 = '0;
  logic local_thermal_enable = '0;
  typedef struct packed {
    logic [(CELLS*32)-1:0] phase_word_q;
    logic [(CELLS*32)-1:0] frequency_current_q16;
    logic [(CELLS*32)-1:0] coupling_field_q16;
    logic [(CELLS*32)-1:0] phase_projection_q30;
    logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] phase_target_source;
    logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] registered_target_q;
    logic registered_target_valid_q;
    logic phase_target_domain_valid;
    logic registered_target_domain_valid;
    logic target_capture_accepted;
    logic target_capture_rejected;
    logic [COUNTER_BITS-1:0] accepted_target_capture_events_q;
    logic [COUNTER_BITS-1:0] rejected_target_capture_events_q;
    logic registered_request_enable;
    logic [REQUEST_LANES-1:0] phase_request_valid;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] phase_request_cell_index;
    logic [(REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] phase_request_target;
    logic [REQUEST_LANES-1:0] execution_request_valid;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] execution_request_cell_index;
    logic [(REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] execution_request_target;
    logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] execution_target_bank;
    logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] state_out;
    logic [(CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0] pending_route_out;
    frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode_q;
    frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state_q;
    logic [COUNTER_BITS-1:0] ticks_recorded_q;
    logic [COUNTER_BITS-1:0] scheduler_count_free_q;
    logic [COUNTER_BITS-1:0] scheduler_count_balance_q;
    logic [COUNTER_BITS-1:0] scheduler_count_commit_q;
    logic [COUNTER_BITS-1:0] scheduler_count_excite_q;
    logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q;
    logic [REQUEST_LANES-1:0] request_accept;
    logic [REQUEST_LANES-1:0] request_reject;
    logic [CELLS-1:0] accepted_cell_mask;
    logic [CELLS-1:0] neutral_routed_cell_mask;
    logic [CELLS-1:0] accepted_change_mask;
    logic [COUNTER_BITS-1:0] accepted_changes;
    logic [COUNTER_BITS-1:0] capacity_remaining;
    logic capacity_exhausted;
    logic [COUNTER_BITS-1:0] switch_load_numerator;
    logic [COUNTER_BITS-1:0] requested_direct_events;
    logic [COUNTER_BITS-1:0] prevented_direct_events;
    logic [COUNTER_BITS-1:0] neutral_routed_events;
    logic [COUNTER_BITS-1:0] actual_direct_events;
    logic [COUNTER_BITS-1:0] reserved_state_events;
    logic [COUNTER_BITS-1:0] queue_overflow_events;
    logic [frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;
    logic signed [31:0] pair_coherence_q30;
    logic signed [31:0] cluster_coherence_q30;
    logic signed [31:0] global_coherence_q30;
    logic signed [31:0] organization_dispersion_q30;
    logic signed [31:0] normalized_cycle_cost_q16;
    logic signed [31:0] temperature_proxy_q16;
    logic signed [31:0] peak_temperature_proxy_q16;
    logic [31:0] thermal_sample_count_q;
    logic signed [31:0] coherence_capacity_q16;
    logic signed [31:0] pressure_q16;
    logic signed [31:0] stability_margin_q16;
    logic stable;
    logic [(CELLS*32)-1:0] local_heat_q16;
    logic [(CELLS*32)-1:0] local_heat_peak_q16;
    logic [(CELLS*32)-1:0] local_generated_power_q16;
    logic [(CELLS*32)-1:0] local_thermal_dissipation_q16;
    logic [(CELLS*32)-1:0] local_thermal_diffusion_q16;
    logic [(CELLS*32)-1:0] local_thermal_overload_q16;
    logic [(CELLS*32)-1:0] local_next_heat_q16;
    logic [(CELLS*32)-1:0] local_next_overload_q16;
    logic [(CELLS*32)-1:0] local_frequency_lag_q16;
    logic signed [31:0] local_mean_heat_q16;
    logic signed [31:0] local_mean_heat_peak_q16;
    logic signed [31:0] local_maximum_heat_peak_q16;
    logic [(CELLS*32)-1:0] local_gamma_noise_target_q16;
    logic [(CELLS*32)-1:0] local_gamma_noise_state_q16;
    logic [(CELLS*32)-1:0] local_gamma_drift_word;
    logic [(CELLS*32)-1:0] local_gamma_effective_word;
    logic [(CELLS*32)-1:0] local_next_gamma_drift_word;
    logic [(CELLS*32)-1:0] local_next_gamma_effective_word;
    logic [(CELLS*32)-1:0] phase_gamma_effective_word;
    logic [(CELLS*32)-1:0] local_thermal_node_factor_q30;
    logic [(CELLS*32)-1:0] local_next_thermal_node_factor_q30;
    logic [(CELLS*32)-1:0] phase_thermal_node_factor_q30;
    logic [((CELLS-1)*32)-1:0] group_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_mean_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_min_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_max_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_dispersion_q30;
    logic signed [31:0] local_coherence_compression_q30;
    logic signed [31:0] local_effective_coherence_q30;
    logic signed [31:0] local_coherence_capacity_q16;
    logic signed [31:0] local_pressure_q16;
    logic signed [31:0] local_stability_margin_q16;
    logic local_stable;
    logic signed [31:0] local_previous_margin_q16;
    logic local_stability_valid_q;
    logic [31:0] local_stability_sample_count_q;
    logic signed [31:0] local_stability_raw_coherence_q30;
    logic signed [31:0] local_stability_cluster_coherence_q30;
    logic signed [31:0] local_stability_mean_heat_q16;
    logic signed [31:0] local_stability_mean_overload_q16;
    logic signed [31:0] local_stability_mean_lag_q16;
    logic signed [31:0] local_stability_neutral_fraction_q30;
    logic signed [31:0] local_stability_compression_arg_q16;
    logic signed [31:0] local_stability_switch_load_q16;
  } core_t;
  core_t a,g;
  typedef struct packed {
    logic record_sample_seen_q;
    logic [RECORDER_COUNT_BITS-1:0] record_sample_count_q;
    logic record_count_overflow_q;
    logic signed [31:0] record_previous_margin_q16;
    logic signed [31:0] record_minimum_margin_q16;
    logic [63:0] record_minimum_margin_tick_q;
    logic signed [31:0] record_peak_switch_load_q16;
    logic [63:0] record_peak_switch_load_tick_q;
    logic boundary_valid_q;
    logic boundary_pulse_q;
    logic [63:0] boundary_tick_q;
    logic [1:0] boundary_scheduler_mode_q;
    logic [2:0] boundary_scheduler_state_q;
    logic signed [31:0] boundary_previous_margin_q16;
    logic signed [31:0] boundary_margin_q16;
    logic signed [31:0] boundary_capacity_q16;
    logic signed [31:0] boundary_pressure_q16;
    logic signed [31:0] boundary_mean_heat_q16;
    logic signed [31:0] boundary_switch_load_q16;
    logic [(CELLS*2)-1:0] boundary_retained_state_q;
    logic [(CELLS*2)-1:0] boundary_pending_route_q;
    logic record_alignment_error_q;
  } record_t;
  record_t r,e;
  frp_m32_observed_core #(.CELLS(CELLS),.REQUEST_LANES(REQUEST_LANES),.COUNTER_BITS(COUNTER_BITS)) dut (
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
    .local_gamma_enable(local_gamma_enable),
    .gamma_update_valid(gamma_update_valid),
    .gamma_targets_q16(gamma_targets_q16),
    .local_thermal_enable(local_thermal_enable),
    .phase_word_q(a.phase_word_q),
    .frequency_current_q16(a.frequency_current_q16),
    .coupling_field_q16(a.coupling_field_q16),
    .phase_projection_q30(a.phase_projection_q30),
    .phase_target_source(a.phase_target_source),
    .registered_target_q(a.registered_target_q),
    .registered_target_valid_q(a.registered_target_valid_q),
    .phase_target_domain_valid(a.phase_target_domain_valid),
    .registered_target_domain_valid(a.registered_target_domain_valid),
    .target_capture_accepted(a.target_capture_accepted),
    .target_capture_rejected(a.target_capture_rejected),
    .accepted_target_capture_events_q(a.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(a.rejected_target_capture_events_q),
    .registered_request_enable(a.registered_request_enable),
    .phase_request_valid(a.phase_request_valid),
    .phase_request_cell_index(a.phase_request_cell_index),
    .phase_request_target(a.phase_request_target),
    .execution_request_valid(a.execution_request_valid),
    .execution_request_cell_index(a.execution_request_cell_index),
    .execution_request_target(a.execution_request_target),
    .execution_target_bank(a.execution_target_bank),
    .state_out(a.state_out),
    .pending_route_out(a.pending_route_out),
    .scheduler_mode_q(a.scheduler_mode_q),
    .scheduler_state_q(a.scheduler_state_q),
    .ticks_recorded_q(a.ticks_recorded_q),
    .scheduler_count_free_q(a.scheduler_count_free_q),
    .scheduler_count_balance_q(a.scheduler_count_balance_q),
    .scheduler_count_commit_q(a.scheduler_count_commit_q),
    .scheduler_count_excite_q(a.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(a.scheduler_count_neutralize_q),
    .request_accept(a.request_accept),
    .request_reject(a.request_reject),
    .accepted_cell_mask(a.accepted_cell_mask),
    .neutral_routed_cell_mask(a.neutral_routed_cell_mask),
    .accepted_change_mask(a.accepted_change_mask),
    .accepted_changes(a.accepted_changes),
    .capacity_remaining(a.capacity_remaining),
    .capacity_exhausted(a.capacity_exhausted),
    .switch_load_numerator(a.switch_load_numerator),
    .requested_direct_events(a.requested_direct_events),
    .prevented_direct_events(a.prevented_direct_events),
    .neutral_routed_events(a.neutral_routed_events),
    .actual_direct_events(a.actual_direct_events),
    .reserved_state_events(a.reserved_state_events),
    .queue_overflow_events(a.queue_overflow_events),
    .invariant_flags(a.invariant_flags),
    .pair_coherence_q30(a.pair_coherence_q30),
    .cluster_coherence_q30(a.cluster_coherence_q30),
    .global_coherence_q30(a.global_coherence_q30),
    .organization_dispersion_q30(a.organization_dispersion_q30),
    .normalized_cycle_cost_q16(a.normalized_cycle_cost_q16),
    .temperature_proxy_q16(a.temperature_proxy_q16),
    .peak_temperature_proxy_q16(a.peak_temperature_proxy_q16),
    .thermal_sample_count_q(a.thermal_sample_count_q),
    .coherence_capacity_q16(a.coherence_capacity_q16),
    .pressure_q16(a.pressure_q16),
    .stability_margin_q16(a.stability_margin_q16),
    .stable(a.stable),
    .local_heat_q16(a.local_heat_q16),
    .local_heat_peak_q16(a.local_heat_peak_q16),
    .local_generated_power_q16(a.local_generated_power_q16),
    .local_thermal_dissipation_q16(a.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(a.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(a.local_thermal_overload_q16),
    .local_next_heat_q16(a.local_next_heat_q16),
    .local_next_overload_q16(a.local_next_overload_q16),
    .local_frequency_lag_q16(a.local_frequency_lag_q16),
    .local_mean_heat_q16(a.local_mean_heat_q16),
    .local_mean_heat_peak_q16(a.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(a.local_maximum_heat_peak_q16),
    .local_gamma_noise_target_q16(a.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(a.local_gamma_noise_state_q16),
    .local_gamma_drift_word(a.local_gamma_drift_word),
    .local_gamma_effective_word(a.local_gamma_effective_word),
    .local_next_gamma_drift_word(a.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(a.local_next_gamma_effective_word),
    .phase_gamma_effective_word(a.phase_gamma_effective_word),
    .local_thermal_node_factor_q30(a.local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(a.local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(a.phase_thermal_node_factor_q30),
    .group_coherence_q30(a.group_coherence_q30),
    .level_mean_coherence_q30(a.level_mean_coherence_q30),
    .level_min_coherence_q30(a.level_min_coherence_q30),
    .level_max_coherence_q30(a.level_max_coherence_q30),
    .level_dispersion_q30(a.level_dispersion_q30),
    .local_coherence_compression_q30(a.local_coherence_compression_q30),
    .local_effective_coherence_q30(a.local_effective_coherence_q30),
    .local_coherence_capacity_q16(a.local_coherence_capacity_q16),
    .local_pressure_q16(a.local_pressure_q16),
    .local_stability_margin_q16(a.local_stability_margin_q16),
    .local_stable(a.local_stable),
    .local_previous_margin_q16(a.local_previous_margin_q16),
    .local_stability_valid_q(a.local_stability_valid_q),
    .local_stability_sample_count_q(a.local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(a.local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(a.local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(a.local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(a.local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(a.local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(a.local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(a.local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(a.local_stability_switch_load_q16),
    .record_sample_seen_q(r.record_sample_seen_q),
    .record_sample_count_q(r.record_sample_count_q),
    .record_count_overflow_q(r.record_count_overflow_q),
    .record_previous_margin_q16(r.record_previous_margin_q16),
    .record_minimum_margin_q16(r.record_minimum_margin_q16),
    .record_minimum_margin_tick_q(r.record_minimum_margin_tick_q),
    .record_peak_switch_load_q16(r.record_peak_switch_load_q16),
    .record_peak_switch_load_tick_q(r.record_peak_switch_load_tick_q),
    .boundary_valid_q(r.boundary_valid_q),
    .boundary_pulse_q(r.boundary_pulse_q),
    .boundary_tick_q(r.boundary_tick_q),
    .boundary_scheduler_mode_q(r.boundary_scheduler_mode_q),
    .boundary_scheduler_state_q(r.boundary_scheduler_state_q),
    .boundary_previous_margin_q16(r.boundary_previous_margin_q16),
    .boundary_margin_q16(r.boundary_margin_q16),
    .boundary_capacity_q16(r.boundary_capacity_q16),
    .boundary_pressure_q16(r.boundary_pressure_q16),
    .boundary_mean_heat_q16(r.boundary_mean_heat_q16),
    .boundary_switch_load_q16(r.boundary_switch_load_q16),
    .boundary_retained_state_q(r.boundary_retained_state_q),
    .boundary_pending_route_q(r.boundary_pending_route_q),
    .record_alignment_error_q(r.record_alignment_error_q)
  );
  frp_m32_core #(.CELLS(CELLS),.REQUEST_LANES(REQUEST_LANES),.COUNTER_BITS(COUNTER_BITS)) gold (
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
    .local_gamma_enable(local_gamma_enable),
    .gamma_update_valid(gamma_update_valid),
    .gamma_targets_q16(gamma_targets_q16),
    .local_thermal_enable(local_thermal_enable),
    .phase_word_q(g.phase_word_q),
    .frequency_current_q16(g.frequency_current_q16),
    .coupling_field_q16(g.coupling_field_q16),
    .phase_projection_q30(g.phase_projection_q30),
    .phase_target_source(g.phase_target_source),
    .registered_target_q(g.registered_target_q),
    .registered_target_valid_q(g.registered_target_valid_q),
    .phase_target_domain_valid(g.phase_target_domain_valid),
    .registered_target_domain_valid(g.registered_target_domain_valid),
    .target_capture_accepted(g.target_capture_accepted),
    .target_capture_rejected(g.target_capture_rejected),
    .accepted_target_capture_events_q(g.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(g.rejected_target_capture_events_q),
    .registered_request_enable(g.registered_request_enable),
    .phase_request_valid(g.phase_request_valid),
    .phase_request_cell_index(g.phase_request_cell_index),
    .phase_request_target(g.phase_request_target),
    .execution_request_valid(g.execution_request_valid),
    .execution_request_cell_index(g.execution_request_cell_index),
    .execution_request_target(g.execution_request_target),
    .execution_target_bank(g.execution_target_bank),
    .state_out(g.state_out),
    .pending_route_out(g.pending_route_out),
    .scheduler_mode_q(g.scheduler_mode_q),
    .scheduler_state_q(g.scheduler_state_q),
    .ticks_recorded_q(g.ticks_recorded_q),
    .scheduler_count_free_q(g.scheduler_count_free_q),
    .scheduler_count_balance_q(g.scheduler_count_balance_q),
    .scheduler_count_commit_q(g.scheduler_count_commit_q),
    .scheduler_count_excite_q(g.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(g.scheduler_count_neutralize_q),
    .request_accept(g.request_accept),
    .request_reject(g.request_reject),
    .accepted_cell_mask(g.accepted_cell_mask),
    .neutral_routed_cell_mask(g.neutral_routed_cell_mask),
    .accepted_change_mask(g.accepted_change_mask),
    .accepted_changes(g.accepted_changes),
    .capacity_remaining(g.capacity_remaining),
    .capacity_exhausted(g.capacity_exhausted),
    .switch_load_numerator(g.switch_load_numerator),
    .requested_direct_events(g.requested_direct_events),
    .prevented_direct_events(g.prevented_direct_events),
    .neutral_routed_events(g.neutral_routed_events),
    .actual_direct_events(g.actual_direct_events),
    .reserved_state_events(g.reserved_state_events),
    .queue_overflow_events(g.queue_overflow_events),
    .invariant_flags(g.invariant_flags),
    .pair_coherence_q30(g.pair_coherence_q30),
    .cluster_coherence_q30(g.cluster_coherence_q30),
    .global_coherence_q30(g.global_coherence_q30),
    .organization_dispersion_q30(g.organization_dispersion_q30),
    .normalized_cycle_cost_q16(g.normalized_cycle_cost_q16),
    .temperature_proxy_q16(g.temperature_proxy_q16),
    .peak_temperature_proxy_q16(g.peak_temperature_proxy_q16),
    .thermal_sample_count_q(g.thermal_sample_count_q),
    .coherence_capacity_q16(g.coherence_capacity_q16),
    .pressure_q16(g.pressure_q16),
    .stability_margin_q16(g.stability_margin_q16),
    .stable(g.stable),
    .local_heat_q16(g.local_heat_q16),
    .local_heat_peak_q16(g.local_heat_peak_q16),
    .local_generated_power_q16(g.local_generated_power_q16),
    .local_thermal_dissipation_q16(g.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(g.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(g.local_thermal_overload_q16),
    .local_next_heat_q16(g.local_next_heat_q16),
    .local_next_overload_q16(g.local_next_overload_q16),
    .local_frequency_lag_q16(g.local_frequency_lag_q16),
    .local_mean_heat_q16(g.local_mean_heat_q16),
    .local_mean_heat_peak_q16(g.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(g.local_maximum_heat_peak_q16),
    .local_gamma_noise_target_q16(g.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(g.local_gamma_noise_state_q16),
    .local_gamma_drift_word(g.local_gamma_drift_word),
    .local_gamma_effective_word(g.local_gamma_effective_word),
    .local_next_gamma_drift_word(g.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(g.local_next_gamma_effective_word),
    .phase_gamma_effective_word(g.phase_gamma_effective_word),
    .local_thermal_node_factor_q30(g.local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(g.local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(g.phase_thermal_node_factor_q30),
    .group_coherence_q30(g.group_coherence_q30),
    .level_mean_coherence_q30(g.level_mean_coherence_q30),
    .level_min_coherence_q30(g.level_min_coherence_q30),
    .level_max_coherence_q30(g.level_max_coherence_q30),
    .level_dispersion_q30(g.level_dispersion_q30),
    .local_coherence_compression_q30(g.local_coherence_compression_q30),
    .local_effective_coherence_q30(g.local_effective_coherence_q30),
    .local_coherence_capacity_q16(g.local_coherence_capacity_q16),
    .local_pressure_q16(g.local_pressure_q16),
    .local_stability_margin_q16(g.local_stability_margin_q16),
    .local_stable(g.local_stable),
    .local_previous_margin_q16(g.local_previous_margin_q16),
    .local_stability_valid_q(g.local_stability_valid_q),
    .local_stability_sample_count_q(g.local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(g.local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(g.local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(g.local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(g.local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(g.local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(g.local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(g.local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(g.local_stability_switch_load_q16)
  );

  typedef struct packed {
    longint unsigned due, tag;
    logic [1:0] mode;
    logic [2:0] state;
    logic [CELLS*2-1:0] bank, pending;
    int signed heat, switches;
  } event_t;
  event_t waiting[$];
  longint unsigned edge_index=0, next_tag=0, total_samples=0;
  int clears=0, resets=0, crossings=0, forwarded_checks=0;
  bit [2:0] modes_seen=0;
  bit [4:0] states_seen=0;
  int accepted=0, dropped=0, loaded_without_tick=0;
  int first_legs=0, second_legs=0;
  logic [63:0] trace_signature=64'hcbf29ce484222325;
  localparam int OBS_BITS=$bits(core_t)+$bits(record_t);
  localparam int HASH_WORDS=(OBS_BITS+31)/32;

  task automatic reset_expected();
    e='0;
    e.record_previous_margin_q16=39322;
    next_tag=0;
    dropped+=waiting.size();
    waiting.delete();
  endtask

  task automatic consume(input event_t event_data);
    int signed margin,sw;
    int zeros;
    margin=g.local_stability_margin_q16;
    sw=g.local_stability_switch_load_q16;
    if (g.local_stability_mean_heat_q16!==event_data.heat || sw!==event_data.switches)
      $fatal(1,"Snapshot mismatch N=%0d edge=%0d",CELLS,edge_index);
    zeros=0;
    for(int c=0;c<CELLS;c++) if(event_data.bank[c*2+:2]==0) zeros++;
    if(g.local_stability_neutral_fraction_q30 !== 32'((64'(zeros)*1073741824)/CELLS))
      $fatal(1,"Retained state belongs to another snapshot");
    if(!e.record_sample_seen_q || margin<e.record_minimum_margin_q16) begin
      e.record_minimum_margin_q16=margin;
      e.record_minimum_margin_tick_q=event_data.tag;
    end
    if(!e.record_sample_seen_q || sw>e.record_peak_switch_load_q16) begin
      e.record_peak_switch_load_q16=sw;
      e.record_peak_switch_load_tick_q=event_data.tag;
    end
    if(!e.boundary_valid_q && e.record_previous_margin_q16>0 && margin<=0) begin
      e.boundary_valid_q=1;
      e.boundary_pulse_q=1;
      e.boundary_tick_q=event_data.tag;
      e.boundary_scheduler_mode_q=event_data.mode;
      e.boundary_scheduler_state_q=event_data.state;
      e.boundary_previous_margin_q16=e.record_previous_margin_q16;
      e.boundary_margin_q16=margin;
      e.boundary_capacity_q16=g.local_coherence_capacity_q16;
      e.boundary_pressure_q16=g.local_pressure_q16;
      e.boundary_mean_heat_q16=event_data.heat;
      e.boundary_switch_load_q16=event_data.switches;
      e.boundary_retained_state_q=event_data.bank;
      e.boundary_pending_route_q=event_data.pending;
      crossings++;
    end
    e.record_sample_seen_q=1;
    e.record_sample_count_q++;
    e.record_previous_margin_q16=margin;
    total_samples++;
    modes_seen[event_data.mode]=1;
    states_seen[event_data.state]=1;
  endtask

  task automatic compare_outputs();
    logic [HASH_WORDS*32-1:0] hash_data;
    if($isunknown({a,g,r,e}))
      $fatal(1,"Unknown observation N=%0d edge=%0d",CELLS,edge_index);
    if(a!==g) $fatal(1,"Forwarded core mismatch N=%0d edge=%0d",CELLS,edge_index);
    if(r!==e) begin
      $display("actual=%h expected=%h",r,e);
      $fatal(1,"Recorder mismatch N=%0d edge=%0d count=%0d expected_count=%0d",
             CELLS,edge_index,r.record_sample_count_q,e.record_sample_count_q);
    end
    if(a.actual_direct_events || a.reserved_state_events || a.queue_overflow_events)
      $fatal(1,"Core invariant events N=%0d",CELLS);
    hash_data='0;
    hash_data[OBS_BITS-1:0]={a,r};
    for(int word_index=0;word_index<HASH_WORDS;word_index++)
      trace_signature=(trace_signature^{32'b0,hash_data[word_index*32+:32]})
                      *64'h00000100000001b3;
    forwarded_checks++;
  endtask

  task automatic step();
    event_t incoming,outgoing;
    bit take, due_now;
    longint signed heat_sum;
    logic [CELLS*2-1:0] previous_bank, previous_pending;
    clk=0; #2;
    take=rst_n && tick_enable;
    previous_bank=a.state_out;
    previous_pending=a.pending_route_out;
    e.boundary_pulse_q=0;
    if(!rst_n) reset_expected();
    else begin
      due_now=0;
      if(waiting.size()!=0) due_now=waiting[0].due==edge_index;
      if(a.local_stability_valid_q!==due_now)
        $fatal(1,"Local stability latency N=%0d edge=%0d",CELLS,edge_index);
      if(due_now) begin outgoing=waiting.pop_front();consume(outgoing);end
      if(take) begin
        incoming='0;
        incoming.due=edge_index+2;
        incoming.tag=next_tag;
        incoming.mode=g.scheduler_mode_q;
        incoming.state=g.scheduler_state_q;
        incoming.switches=g.normalized_cycle_cost_q16;
        next_tag++;
        accepted++;
      end
      if(clear_counters) clears++;
      if(phase_load_valid && !tick_enable) loaded_without_tick++;
    end
    clk=1; #2;
    compare_outputs();
    if(take) begin
      for(int c=0;c<CELLS;c++) begin
        if((previous_bank[c*2+:2]==2'b01 && a.state_out[c*2+:2]==2'b11) ||
           (previous_bank[c*2+:2]==2'b11 && a.state_out[c*2+:2]==2'b01))
          $fatal(1,"Direct opposite-polarity transition cell=%0d",c);
        if(a.state_out[c*2+:2]==2'b10 || a.pending_route_out[c*2+:2]==2'b10)
          $fatal(1,"Reserved ternary code cell=%0d",c);
        if(a.pending_route_out[c*2+:2]!=0 && a.state_out[c*2+:2]!=0)
          $fatal(1,"Pending route requires retained active zero cell=%0d",c);
        if(previous_bank[c*2+:2]!=0 && a.state_out[c*2+:2]==0 &&
           a.pending_route_out[c*2+:2]!=0)
          first_legs++;
        if(previous_bank[c*2+:2]==0 && previous_pending[c*2+:2]!=0 &&
           a.state_out[c*2+:2]==previous_pending[c*2+:2] &&
           a.pending_route_out[c*2+:2]==0)
          second_legs++;
      end
      incoming.bank=g.state_out;
      incoming.pending=g.pending_route_out;
      heat_sum=0;
      for(int c=0;c<CELLS;c++) heat_sum+=longint'($signed(g.local_heat_q16[c*32+:32]));
      incoming.heat=int'(heat_sum<0 ? -((-heat_sum+CELLS/2)/CELLS) : (heat_sum+CELLS/2)/CELLS);
      waiting.push_back(incoming);
    end
    clk=0; #2;
    edge_index++;
  endtask

  task automatic reset_core();
    clk=0;
    rst_n=1; #1;
    rst_n=0; #1;
    reset_expected();
    compare_outputs();
    resets++;
    tick_enable=0;
    clear_counters=0;
    phase_load_valid=0;
    step();rst_n=1;step();
  endtask

  initial begin
    if(CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64)
      $fatal(1,"Observed-core profiles: 8/16/32/64 cells");
    rst_n=1;
    reset_expected();
    for(int c=0;c<CELLS;c++) begin
      gamma_effective_word[c*32+:32]=644245094;
      thermal_node_factor_q30[c*32+:32]=1073741824;
    end
    local_gamma_enable=1;
    local_thermal_enable=1;
    for(int mode=0;mode<3;mode++) begin
      reset_core();
      scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      step();
      for(int k=0;k<320;k++) begin
        tick_enable=(k%32<24) || (k%3==0);
        clear_counters=(k%7==0);
        phase_load_valid=(k%13==0) || (k==80);
        gamma_update_valid=(k%8==0);
        auto_target_enable=(k%5==0);
        if(k%43==0) scheduler_mode=frp_m31_scheduler_mode_e'((mode+k/43)%3);
        for(int c=0;c<CELLS;c++) begin
          phase_load[c*32+:32]=32'(64'(c)*4294967296/CELLS+64'(k)*100003);
          frequency_load_q16[c*32+:32]=(k>=80 && k<160) ? 1048576 : 65536;
          gamma_targets_q16[c*32+:32]=32'((c%2==0 ? 1 : -1)*(k*31+c));
          external_target_bank[c*2+:2]=(c+k)%3==0 ? 2'b00 : ((c+k)%3==1 ? 2'b01 : 2'b11);
        end
        for(int lane=0;lane<REQUEST_LANES;lane++) begin
          external_request_valid[lane]=1;
          external_request_cell_index[lane*CELL_INDEX_BITS+:CELL_INDEX_BITS]=CELL_INDEX_BITS'((k+lane)%CELLS);
          external_request_target[lane*2+:2]=k%2 ? 2'b01 : 2'b11;
        end
        step();
      end
      tick_enable=0;phase_load_valid=0;clear_counters=0;
      repeat(4)step();
      if(waiting.size()!=0) $fatal(1,"Drain left pending snapshots");
      if(!r.boundary_valid_q) $fatal(1,"Boundary scenario did not cross N=%0d mode=%0d",CELLS,mode);
    end
    // Reset at each pipeline occupancy, then accept new ticks immediately.
    for(int occupancy=0;occupancy<3;occupancy++) begin
      reset_core();
      tick_enable=1;
      repeat(occupancy) step();
      reset_core();
      tick_enable=1;repeat(12)step();
      tick_enable=0;repeat(3)step();
    end
    if(modes_seen!==3'b111 || states_seen!==5'b11111)
      $fatal(1,"Scheduler coverage modes=%b states=%b",modes_seen,states_seen);
    if(longint'(accepted)!=total_samples+longint'(dropped))
      $fatal(1,"Sample conservation");
    if(accepted!=840 || total_samples!=837 || dropped!=3 || crossings!=3 ||
       resets!=9 || clears!=138 || loaded_without_tick!=12 || forwarded_checks!=1050)
      $fatal(1,"Observed-core scenario coverage counts");
    if(first_legs==0 || second_legs==0)
      $fatal(1,"Both active-zero route legs must occur");
    $display("PASS OBSERVED_CORE cells=%0d accepted=%0d recorded=%0d dropped=%0d crossings=%0d resets=%0d clears=%0d phase_only=%0d comparisons=%0d first_legs=%0d second_legs=%0d signature=%016h",
      CELLS,accepted,total_samples,dropped,crossings,resets,clears,loaded_without_tick,forwarded_checks,first_legs,second_legs,trace_signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"watchdog");end
endmodule

`endif

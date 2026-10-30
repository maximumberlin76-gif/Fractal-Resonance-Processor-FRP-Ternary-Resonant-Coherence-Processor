// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Internal gamma + observed core + atomic snapshot CSR qualification.
// Profiles: CELLS=8/16/32/64, COUNT_BITS=3 or 64; +seed=<unsigned>.
// Compare all 114 common outputs with frp_m32_internal_gamma_core before and
// after every tested edge, including checkpoint loading and gamma stalls.
// The CSR scoreboard captures public recorder fields before the accepting edge
// and independently decodes every response; it uses no CSR internal registers.
// A two-edge accepted-tick model checks recorder count, overflow and reset loss.
// Exercise free, 7/1 and 1/7 scheduling, both active-zero route legs, phase-only
// loads, counter clears, boundary pulses, ten checkpoints and frozen readout.
// Stress requests are one-cycle offers; blocked offers are withdrawn between
// clocks. Reset scenarios also exercise consecutive held-valid requests.
// Checkpoint words are deterministic nonzero synthetic MT19937 state words.
// Restore index 624 exercises twisting and prefetch before the first tick.
// Build from repository root with Verilator --binary --timing --assert,
// --unroll-count 1 --output-split-cfuncs 0 -Irtl/m31 -Irtl/m32,
// --top-module frp_m32_internal_gamma_observed_csr_tb.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_TB_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_core.sv"
`include "frp_m32_internal_gamma_core.sv"

module frp_m32_internal_gamma_observed_csr_tb #(
  parameter int CELLS=8,
  parameter int COUNT_BITS=64
);
  import frp_m31_pkg::*;
  localparam int LANES=frp_calc_request_lanes(CELLS);
  localparam int INDEX_BITS=$clog2(CELLS);
  localparam int COUNTER_BITS=FRP_M31_COUNTER_BITS;
  localparam int REQUEST_LANES=LANES;
  localparam int CELL_INDEX_BITS=INDEX_BITS;
  localparam logic [COUNT_BITS-1:0] COUNT_MAX='1;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_load_valid=0, auto_target_enable=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE, mode_q;
  frp_m31_scheduler_state_e state_q;
  logic [CELLS*32-1:0] phase_load='0, frequency_load_q16='0;
  logic [LANES-1:0] request_valid='0;
  logic [LANES*INDEX_BITS-1:0] request_index='0;
  logic [LANES*2-1:0] request_target='0;
  logic [CELLS*2-1:0] target_bank='0, state_bank, pending_bank;
  logic [31:0] direct_events, reserved_events, overflow_events;
  logic csr_valid=0, csr_write=0, csr_ready, csr_error;
  logic [7:0] csr_addr=0;
  logic [31:0] csr_wdata=0, csr_rdata;

  typedef struct packed {
    logic seen;
    logic [COUNT_BITS-1:0] count;
    logic overflow;
    logic [31:0] previous_margin, minimum_margin;
    logic [63:0] minimum_tick;
    logic [31:0] peak_switch;
    logic [63:0] peak_tick;
    logic boundary_valid, boundary_pulse;
    logic [63:0] boundary_tick;
    logic [1:0] mode;
    logic [2:0] state;
    logic [31:0] boundary_previous, boundary_margin, capacity, pressure;
    logic [31:0] heat, switches;
    logic [CELLS*2-1:0] retained, pending;
    logic alignment_error;
  } sample_t;
  sample_t live = '0, held = '0;
  bit held_valid = 0;

  logic checkpoint_load_begin=0, checkpoint_load_valid=0;
  logic [9:0] checkpoint_index=624;
  logic [31:0] checkpoint_load_word=0;
  int stalled_ticks=0, stalled_csr=0, checkpoint_reloads=0;
  typedef struct packed {
    logic [(CELLS*32)-1:0] phase_word_q;
    logic [(CELLS*32)-1:0] frequency_current_q16;
    logic [(CELLS*32)-1:0] coupling_field_q16;
    logic [(CELLS*32)-1:0] phase_projection_q30;
    logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_target_source;
    logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] registered_target_q;
    logic registered_target_valid_q;
    logic phase_target_domain_valid;
    logic registered_target_domain_valid;
    logic target_capture_accepted;
    logic target_capture_rejected;
    logic [COUNTER_BITS-1:0] accepted_target_capture_events_q;
    logic [COUNTER_BITS-1:0] rejected_target_capture_events_q;
    logic registered_request_enable;
    logic [REQUEST_LANES-1:0] phase_request_valid;
    logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] phase_request_cell_index;
    logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_request_target;
    logic [REQUEST_LANES-1:0] execution_request_valid;
    logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] execution_request_cell_index;
    logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_request_target;
    logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_target_bank;
    logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] state_out;
    logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] pending_route_out;
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
    logic [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ] invariant_flags;
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
    logic checkpoint_load_ready;
    logic gamma_configured;
    logic gamma_load_error;
    logic gamma_source_busy;
    logic gamma_bank_valid;
    logic tick_ready;
    logic tick_accepted;
    logic phase_load_ready;
    logic phase_load_accepted;
    logic gamma_update_accepted;
    logic [2:0] gamma_tick_phase_q;
  } common_t;
  common_t actual, reference_core;

  frp_m32_internal_gamma_observed_csr_core #(
    .CELLS(CELLS), .RECORDER_COUNT_BITS(COUNT_BITS)
  ) core (
    .clk(clk), .rst_n(rst_n), .tick_valid(tick_enable),
    .clear_counters(clear_counters), .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid), .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),

    .auto_target_enable(auto_target_enable),
    .external_request_valid(request_valid),
    .external_request_cell_index(request_index),
    .external_request_target(request_target), .external_target_bank(target_bank),

    .state_out(actual.state_out), .pending_route_out(actual.pending_route_out),
    .scheduler_mode_q(actual.scheduler_mode_q), .scheduler_state_q(actual.scheduler_state_q),
    .actual_direct_events(actual.actual_direct_events), .reserved_state_events(actual.reserved_state_events),
    .queue_overflow_events(actual.queue_overflow_events),
    .record_sample_seen_q(live.seen), .record_sample_count_q(live.count),
    .record_count_overflow_q(live.overflow),
    .record_previous_margin_q16(live.previous_margin),
    .record_minimum_margin_q16(live.minimum_margin),
    .record_minimum_margin_tick_q(live.minimum_tick),
    .record_peak_switch_load_q16(live.peak_switch),
    .record_peak_switch_load_tick_q(live.peak_tick),
    .boundary_valid_q(live.boundary_valid), .boundary_pulse_q(live.boundary_pulse),
    .boundary_tick_q(live.boundary_tick), .boundary_scheduler_mode_q(live.mode),
    .boundary_scheduler_state_q(live.state),
    .boundary_previous_margin_q16(live.boundary_previous),
    .boundary_margin_q16(live.boundary_margin), .boundary_capacity_q16(live.capacity),
    .boundary_pressure_q16(live.pressure), .boundary_mean_heat_q16(live.heat),
    .boundary_switch_load_q16(live.switches),
    .boundary_retained_state_q(live.retained), .boundary_pending_route_q(live.pending),
    .record_alignment_error_q(live.alignment_error),
    .csr_valid(csr_valid),
    .csr_write(csr_write),
    .csr_addr(csr_addr),
    .csr_wdata(csr_wdata),
    .csr_ready(csr_ready),
    .csr_error(csr_error),
    .csr_rdata(csr_rdata),
    .phase_word_q(actual.phase_word_q),
    .frequency_current_q16(actual.frequency_current_q16),
    .coupling_field_q16(actual.coupling_field_q16),
    .phase_projection_q30(actual.phase_projection_q30),
    .phase_target_source(actual.phase_target_source),
    .registered_target_q(actual.registered_target_q),
    .registered_target_valid_q(actual.registered_target_valid_q),
    .phase_target_domain_valid(actual.phase_target_domain_valid),
    .registered_target_domain_valid(actual.registered_target_domain_valid),
    .target_capture_accepted(actual.target_capture_accepted),
    .target_capture_rejected(actual.target_capture_rejected),
    .accepted_target_capture_events_q(actual.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(actual.rejected_target_capture_events_q),
    .registered_request_enable(actual.registered_request_enable),
    .phase_request_valid(actual.phase_request_valid),
    .phase_request_cell_index(actual.phase_request_cell_index),
    .phase_request_target(actual.phase_request_target),
    .execution_request_valid(actual.execution_request_valid),
    .execution_request_cell_index(actual.execution_request_cell_index),
    .execution_request_target(actual.execution_request_target),
    .execution_target_bank(actual.execution_target_bank),
    .ticks_recorded_q(actual.ticks_recorded_q),
    .scheduler_count_free_q(actual.scheduler_count_free_q),
    .scheduler_count_balance_q(actual.scheduler_count_balance_q),
    .scheduler_count_commit_q(actual.scheduler_count_commit_q),
    .scheduler_count_excite_q(actual.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(actual.scheduler_count_neutralize_q),
    .request_accept(actual.request_accept),
    .request_reject(actual.request_reject),
    .accepted_cell_mask(actual.accepted_cell_mask),
    .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
    .accepted_change_mask(actual.accepted_change_mask),
    .accepted_changes(actual.accepted_changes),
    .capacity_remaining(actual.capacity_remaining),
    .capacity_exhausted(actual.capacity_exhausted),
    .switch_load_numerator(actual.switch_load_numerator),
    .requested_direct_events(actual.requested_direct_events),
    .prevented_direct_events(actual.prevented_direct_events),
    .neutral_routed_events(actual.neutral_routed_events),
    .invariant_flags(actual.invariant_flags),
    .pair_coherence_q30(actual.pair_coherence_q30),
    .cluster_coherence_q30(actual.cluster_coherence_q30),
    .global_coherence_q30(actual.global_coherence_q30),
    .organization_dispersion_q30(actual.organization_dispersion_q30),
    .normalized_cycle_cost_q16(actual.normalized_cycle_cost_q16),
    .temperature_proxy_q16(actual.temperature_proxy_q16),
    .peak_temperature_proxy_q16(actual.peak_temperature_proxy_q16),
    .thermal_sample_count_q(actual.thermal_sample_count_q),
    .coherence_capacity_q16(actual.coherence_capacity_q16),
    .pressure_q16(actual.pressure_q16),
    .stability_margin_q16(actual.stability_margin_q16),
    .stable(actual.stable),
    .local_heat_q16(actual.local_heat_q16),
    .local_heat_peak_q16(actual.local_heat_peak_q16),
    .local_generated_power_q16(actual.local_generated_power_q16),
    .local_thermal_dissipation_q16(actual.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(actual.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(actual.local_thermal_overload_q16),
    .local_next_heat_q16(actual.local_next_heat_q16),
    .local_next_overload_q16(actual.local_next_overload_q16),
    .local_frequency_lag_q16(actual.local_frequency_lag_q16),
    .local_mean_heat_q16(actual.local_mean_heat_q16),
    .local_mean_heat_peak_q16(actual.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(actual.local_maximum_heat_peak_q16),
    .local_gamma_noise_target_q16(actual.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(actual.local_gamma_noise_state_q16),
    .local_gamma_drift_word(actual.local_gamma_drift_word),
    .local_gamma_effective_word(actual.local_gamma_effective_word),
    .local_next_gamma_drift_word(actual.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(actual.local_next_gamma_effective_word),
    .phase_gamma_effective_word(actual.phase_gamma_effective_word),
    .local_thermal_node_factor_q30(actual.local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(actual.local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(actual.phase_thermal_node_factor_q30),
    .group_coherence_q30(actual.group_coherence_q30),
    .level_mean_coherence_q30(actual.level_mean_coherence_q30),
    .level_min_coherence_q30(actual.level_min_coherence_q30),
    .level_max_coherence_q30(actual.level_max_coherence_q30),
    .level_dispersion_q30(actual.level_dispersion_q30),
    .local_coherence_compression_q30(actual.local_coherence_compression_q30),
    .local_effective_coherence_q30(actual.local_effective_coherence_q30),
    .local_coherence_capacity_q16(actual.local_coherence_capacity_q16),
    .local_pressure_q16(actual.local_pressure_q16),
    .local_stability_margin_q16(actual.local_stability_margin_q16),
    .local_stable(actual.local_stable),
    .local_previous_margin_q16(actual.local_previous_margin_q16),
    .local_stability_valid_q(actual.local_stability_valid_q),
    .local_stability_sample_count_q(actual.local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(actual.local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(actual.local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(actual.local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(actual.local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(actual.local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(actual.local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(actual.local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(actual.local_stability_switch_load_q16),
    .checkpoint_load_ready(actual.checkpoint_load_ready),
    .gamma_configured(actual.gamma_configured),
    .gamma_load_error(actual.gamma_load_error),
    .gamma_source_busy(actual.gamma_source_busy),
    .gamma_bank_valid(actual.gamma_bank_valid),
    .tick_ready(actual.tick_ready),
    .tick_accepted(actual.tick_accepted),
    .phase_load_ready(actual.phase_load_ready),
    .phase_load_accepted(actual.phase_load_accepted),
    .gamma_update_accepted(actual.gamma_update_accepted),
    .gamma_tick_phase_q(actual.gamma_tick_phase_q),
    .checkpoint_load_begin(checkpoint_load_begin),
    .checkpoint_index(checkpoint_index),
    .checkpoint_load_valid(checkpoint_load_valid),
    .checkpoint_load_word(checkpoint_load_word)
  );

  frp_m32_internal_gamma_core #(.CELLS(CELLS)) golden (
    .clk(clk),
    .rst_n(rst_n),
    .tick_valid(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .auto_target_enable(auto_target_enable),
    .external_request_valid(request_valid),
    .external_request_cell_index(request_index),
    .external_request_target(request_target),
    .external_target_bank(target_bank),
    .checkpoint_load_begin(checkpoint_load_begin),
    .checkpoint_index(checkpoint_index),
    .checkpoint_load_valid(checkpoint_load_valid),
    .checkpoint_load_word(checkpoint_load_word),
    .phase_word_q(reference_core.phase_word_q),
    .frequency_current_q16(reference_core.frequency_current_q16),
    .coupling_field_q16(reference_core.coupling_field_q16),
    .phase_projection_q30(reference_core.phase_projection_q30),
    .phase_target_source(reference_core.phase_target_source),
    .registered_target_q(reference_core.registered_target_q),
    .registered_target_valid_q(reference_core.registered_target_valid_q),
    .phase_target_domain_valid(reference_core.phase_target_domain_valid),
    .registered_target_domain_valid(reference_core.registered_target_domain_valid),
    .target_capture_accepted(reference_core.target_capture_accepted),
    .target_capture_rejected(reference_core.target_capture_rejected),
    .accepted_target_capture_events_q(reference_core.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(reference_core.rejected_target_capture_events_q),
    .registered_request_enable(reference_core.registered_request_enable),
    .phase_request_valid(reference_core.phase_request_valid),
    .phase_request_cell_index(reference_core.phase_request_cell_index),
    .phase_request_target(reference_core.phase_request_target),
    .execution_request_valid(reference_core.execution_request_valid),
    .execution_request_cell_index(reference_core.execution_request_cell_index),
    .execution_request_target(reference_core.execution_request_target),
    .execution_target_bank(reference_core.execution_target_bank),
    .state_out(reference_core.state_out),
    .pending_route_out(reference_core.pending_route_out),
    .scheduler_mode_q(reference_core.scheduler_mode_q),
    .scheduler_state_q(reference_core.scheduler_state_q),
    .ticks_recorded_q(reference_core.ticks_recorded_q),
    .scheduler_count_free_q(reference_core.scheduler_count_free_q),
    .scheduler_count_balance_q(reference_core.scheduler_count_balance_q),
    .scheduler_count_commit_q(reference_core.scheduler_count_commit_q),
    .scheduler_count_excite_q(reference_core.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(reference_core.scheduler_count_neutralize_q),
    .request_accept(reference_core.request_accept),
    .request_reject(reference_core.request_reject),
    .accepted_cell_mask(reference_core.accepted_cell_mask),
    .neutral_routed_cell_mask(reference_core.neutral_routed_cell_mask),
    .accepted_change_mask(reference_core.accepted_change_mask),
    .accepted_changes(reference_core.accepted_changes),
    .capacity_remaining(reference_core.capacity_remaining),
    .capacity_exhausted(reference_core.capacity_exhausted),
    .switch_load_numerator(reference_core.switch_load_numerator),
    .requested_direct_events(reference_core.requested_direct_events),
    .prevented_direct_events(reference_core.prevented_direct_events),
    .neutral_routed_events(reference_core.neutral_routed_events),
    .actual_direct_events(reference_core.actual_direct_events),
    .reserved_state_events(reference_core.reserved_state_events),
    .queue_overflow_events(reference_core.queue_overflow_events),
    .invariant_flags(reference_core.invariant_flags),
    .pair_coherence_q30(reference_core.pair_coherence_q30),
    .cluster_coherence_q30(reference_core.cluster_coherence_q30),
    .global_coherence_q30(reference_core.global_coherence_q30),
    .organization_dispersion_q30(reference_core.organization_dispersion_q30),
    .normalized_cycle_cost_q16(reference_core.normalized_cycle_cost_q16),
    .temperature_proxy_q16(reference_core.temperature_proxy_q16),
    .peak_temperature_proxy_q16(reference_core.peak_temperature_proxy_q16),
    .thermal_sample_count_q(reference_core.thermal_sample_count_q),
    .coherence_capacity_q16(reference_core.coherence_capacity_q16),
    .pressure_q16(reference_core.pressure_q16),
    .stability_margin_q16(reference_core.stability_margin_q16),
    .stable(reference_core.stable),
    .local_heat_q16(reference_core.local_heat_q16),
    .local_heat_peak_q16(reference_core.local_heat_peak_q16),
    .local_generated_power_q16(reference_core.local_generated_power_q16),
    .local_thermal_dissipation_q16(reference_core.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(reference_core.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(reference_core.local_thermal_overload_q16),
    .local_next_heat_q16(reference_core.local_next_heat_q16),
    .local_next_overload_q16(reference_core.local_next_overload_q16),
    .local_frequency_lag_q16(reference_core.local_frequency_lag_q16),
    .local_mean_heat_q16(reference_core.local_mean_heat_q16),
    .local_mean_heat_peak_q16(reference_core.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(reference_core.local_maximum_heat_peak_q16),
    .local_gamma_noise_target_q16(reference_core.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(reference_core.local_gamma_noise_state_q16),
    .local_gamma_drift_word(reference_core.local_gamma_drift_word),
    .local_gamma_effective_word(reference_core.local_gamma_effective_word),
    .local_next_gamma_drift_word(reference_core.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(reference_core.local_next_gamma_effective_word),
    .phase_gamma_effective_word(reference_core.phase_gamma_effective_word),
    .local_thermal_node_factor_q30(reference_core.local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(reference_core.local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(reference_core.phase_thermal_node_factor_q30),
    .group_coherence_q30(reference_core.group_coherence_q30),
    .level_mean_coherence_q30(reference_core.level_mean_coherence_q30),
    .level_min_coherence_q30(reference_core.level_min_coherence_q30),
    .level_max_coherence_q30(reference_core.level_max_coherence_q30),
    .level_dispersion_q30(reference_core.level_dispersion_q30),
    .local_coherence_compression_q30(reference_core.local_coherence_compression_q30),
    .local_effective_coherence_q30(reference_core.local_effective_coherence_q30),
    .local_coherence_capacity_q16(reference_core.local_coherence_capacity_q16),
    .local_pressure_q16(reference_core.local_pressure_q16),
    .local_stability_margin_q16(reference_core.local_stability_margin_q16),
    .local_stable(reference_core.local_stable),
    .local_previous_margin_q16(reference_core.local_previous_margin_q16),
    .local_stability_valid_q(reference_core.local_stability_valid_q),
    .local_stability_sample_count_q(reference_core.local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(reference_core.local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(reference_core.local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(reference_core.local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(reference_core.local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(reference_core.local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(reference_core.local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(reference_core.local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(reference_core.local_stability_switch_load_q16),
    .checkpoint_load_ready(reference_core.checkpoint_load_ready),
    .gamma_configured(reference_core.gamma_configured),
    .gamma_load_error(reference_core.gamma_load_error),
    .gamma_source_busy(reference_core.gamma_source_busy),
    .gamma_bank_valid(reference_core.gamma_bank_valid),
    .tick_ready(reference_core.tick_ready),
    .tick_accepted(reference_core.tick_accepted),
    .phase_load_ready(reference_core.phase_load_ready),
    .phase_load_accepted(reference_core.phase_load_accepted),
    .gamma_update_accepted(reference_core.gamma_update_accepted),
    .gamma_tick_phase_q(reference_core.gamma_tick_phase_q)
  );
  assign state_bank = actual.state_out;
  assign pending_bank = actual.pending_route_out;
  assign mode_q = actual.scheduler_mode_q;
  assign state_q = actual.scheduler_state_q;
  assign direct_events = actual.actual_direct_events;
  assign reserved_events = actual.reserved_state_events;
  assign overflow_events = actual.queue_overflow_events;

  int unsigned seed=76, random_state;
  int cycles=0, comparisons=0, captures=0, releases=0, errors=0;
  int resets=0, clears=0, phase_only=0, first_legs=0, second_legs=0;
  int concurrent_captures=0, frozen_reads=0, pulse_captures=0, pulse_reads=0;
  int empty_captures=0, saturated_captures=0, idle_cycles=0;
  longint unsigned accepted=0, recorded=0, dropped=0, epoch_recorded=0;
  bit [1:0] pending_ticks=0;
  bit [2:0] modes_seen=0;
  bit [4:0] states_seen=0;
  bit [25:0] payload_reads=0;
  bit read_pulse_pending=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  localparam int SOURCE_WORDS=($bits(sample_t)+31)/32;

  function automatic int unsigned next_random();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 17;
    random_state ^= random_state << 5;
    return random_state;
  endfunction

  function automatic logic [33:0] expected_bus();
    logic error;
    logic [31:0] data;
    logic [63:0] count64;
    logic [127:0] retained128, pending128;
    error = 0;
    data = 0;
    count64 = 64'(held.count);
    retained128 = 128'(held.retained);
    pending128 = 128'(held.pending);
    if (!rst_n) return 34'd0;
    if (csr_valid) begin
      if (csr_addr%4 != 0) error = 1;
      else if (csr_write)
        error = !(csr_addr==0 && (csr_wdata==1 || csr_wdata==2));
      else begin
        case (csr_addr)
          8'h04: data = {26'd0,held.alignment_error,held.boundary_pulse,
                         held.boundary_valid,held.overflow,held.seen,held_valid};
          8'h08: data = 32'h46524201;
          8'h0c: data = (32'(COUNT_BITS)<<16) | 32'(CELLS);
          default: begin
            if (!held_valid) error = 1;
            else case (csr_addr)
              8'h10: data = count64[31:0];
              8'h14: data = count64[63:32];
              8'h18: data = held.previous_margin;
              8'h1c: data = held.minimum_margin;
              8'h20: data = held.minimum_tick[31:0];
              8'h24: data = held.minimum_tick[63:32];
              8'h28: data = held.peak_switch;
              8'h2c: data = held.peak_tick[31:0];
              8'h30: data = held.peak_tick[63:32];
              8'h34: data = held.boundary_tick[31:0];
              8'h38: data = held.boundary_tick[63:32];
              8'h3c: data = {27'd0,held.state,held.mode};
              8'h40: data = held.boundary_previous;
              8'h44: data = held.boundary_margin;
              8'h48: data = held.capacity;
              8'h4c: data = held.pressure;
              8'h50: data = held.heat;
              8'h54: data = held.switches;
              8'h58: data = retained128[31:0];
              8'h5c: data = retained128[63:32];
              8'h60: data = retained128[95:64];
              8'h64: data = retained128[127:96];
              8'h68: data = pending128[31:0];
              8'h6c: data = pending128[63:32];
              8'h70: data = pending128[95:64];
              8'h74: data = pending128[127:96];
              default: error = 1;
            endcase
          end
        endcase
      end
    end
    return {1'b1,error,data};
  endfunction

  task automatic compare(input int phase);
    logic [33:0] expected;
    if (actual !== reference_core)
      $fatal(1,"COMMON_OUTPUT_MISMATCH cells=%0d cycle=%0d phase=%0d",CELLS,cycles,phase);
    expected = expected_bus();
    if ($isunknown({csr_ready,csr_error,csr_rdata}) ||
        {csr_ready,csr_error,csr_rdata} !== expected)
      $fatal(1,"SNAPSHOT_CSR cells=%0d bits=%0d cycle=%0d phase=%0d addr=%h got=%h expected=%h",
             CELLS,COUNT_BITS,cycles,phase,csr_addr,{csr_ready,csr_error,csr_rdata},expected);
    signature = (signature ^ {20'd0,csr_valid,csr_write,csr_addr,
                               csr_ready,csr_error,csr_rdata}) * 64'h100000001b3;
    comparisons++;
  endtask

  task automatic step(input bit valid, input bit write_enable,
                      input logic [7:0] address, input logic [31:0] data);
    logic [33:0] response;
    logic [CELLS*2-1:0] previous_bank, previous_pending;
    logic [SOURCE_WORDS*32-1:0] hash_data;
    bit capture_now, due_now;
    clk=0;
    csr_valid=valid; csr_write=write_enable; csr_addr=address; csr_wdata=data;
    #2;
    // Preserve the transient boundary pulse and read its stored flag next.
    if (live.boundary_pulse) begin
      csr_valid=1; csr_write=1; csr_addr=0; csr_wdata=1;
    end else if (read_pulse_pending) begin
      csr_valid=1; csr_write=0; csr_addr=4; csr_wdata=0;
      read_pulse_pending=0;
    end
    #1;
    compare(0);
    response=expected_bus();
    capture_now=csr_valid && csr_write && csr_addr==0 && csr_wdata==1;
    due_now=pending_ticks[1];
    previous_bank=state_bank;
    previous_pending=pending_bank;
    if (!csr_valid) idle_cycles++;
    if (response[32]) errors++;
    if (capture_now) begin
      held=live; held_valid=1; captures++;
      if (!live.seen) empty_captures++;
      if (live.overflow) saturated_captures++;
      if (live.boundary_pulse) begin
        pulse_captures++; read_pulse_pending=1;
      end
    end else if (csr_valid && csr_write && csr_addr==0 && csr_wdata==2) begin
      held='0; held_valid=0; releases++;
    end
    if (csr_valid && !csr_write && !response[32]) begin
      if (csr_addr>=8'h10 && csr_addr<=8'h74)
        payload_reads[(int'(csr_addr)-16)/4]=1;
      if (held_valid && held!==live) frozen_reads++;
      if (csr_addr==4 && held.boundary_pulse) pulse_reads++;
    end
    if (due_now) begin epoch_recorded++; recorded++; end
    pending_ticks={pending_ticks[0],actual.tick_accepted};
    if (tick_enable && !actual.tick_accepted) begin
      stalled_ticks++;
      if (csr_valid) stalled_csr++;
    end
    if (actual.tick_accepted) begin
      accepted++;
      modes_seen[int'(mode_q)]=1;
      states_seen[int'(state_q)]=1;
    end
    if (clear_counters) clears++;
    if (phase_load_valid && !tick_enable) phase_only++;
    clk=1; #2;
    compare(1);
    if (live.alignment_error || direct_events!=0 || reserved_events!=0 || overflow_events!=0)
      $fatal(1,"Observed snapshot core invariants cycle=%0d",cycles);
    if (live.count !== COUNT_BITS'(epoch_recorded>64'(COUNT_MAX) ?
                                  64'(COUNT_MAX) : epoch_recorded) ||
        live.overflow !== (epoch_recorded>64'(COUNT_MAX)) ||
        live.seen !== (epoch_recorded!=0))
      $fatal(1,"Recorder sample accounting cycle=%0d expected=%0d got=%0d",
             cycles,epoch_recorded,live.count);
    if (capture_now && due_now && held!==live) concurrent_captures++;
    for (int c=0;c<CELLS;c++) begin
      if ((previous_bank[c*2+:2]==1 && state_bank[c*2+:2]==3) ||
          (previous_bank[c*2+:2]==3 && state_bank[c*2+:2]==1))
        $fatal(1,"Direct polarity transition cell=%0d",c);
      if (state_bank[c*2+:2]==2 || pending_bank[c*2+:2]==2 ||
          (pending_bank[c*2+:2]!=0 && state_bank[c*2+:2]!=0))
        $fatal(1,"Ternary domain or active-zero invariant cell=%0d",c);
      if (previous_bank[c*2+:2]!=0 && state_bank[c*2+:2]==0 &&
          pending_bank[c*2+:2]!=0) first_legs++;
      if (previous_bank[c*2+:2]==0 && previous_pending[c*2+:2]!=0 &&
          state_bank[c*2+:2]==previous_pending[c*2+:2] &&
          pending_bank[c*2+:2]==0) second_legs++;
    end
    hash_data='0;
    hash_data[$bits(sample_t)-1:0]=live;
    for (int w=0;w<SOURCE_WORDS;w++)
      signature=(signature^{32'd0,hash_data[w*32+:32]})*64'h100000001b3;
    clk=0; #1; cycles++;
  endtask

  task automatic read_all();
    for (int address=4;address<=116;address+=4)
      step(1,0,8'(address),0);
  endtask

  task automatic restore_checkpoint();
    int limit;
    tick_enable=0; phase_load_valid=0;
    checkpoint_index=624;
    checkpoint_load_begin=1;
    step(1,1,0,1);
    checkpoint_load_begin=0; #1;
    for (int word_index=0;word_index<624;word_index++) begin
      if (!actual.checkpoint_load_ready) $fatal(1,"Checkpoint unexpectedly blocked");
      checkpoint_load_word=32'h80000000 ^ (32'(word_index)*32'h9e3779b9) ^ seed;
      checkpoint_load_valid=1;
      step(1,0,8'h04,0);
    end
    checkpoint_load_valid=0;
    limit=0;
    while (!actual.tick_ready) begin
      step(1,0,8'h08,0);
      limit++;
      if (limit>5000) $fatal(1,"Gamma prefetch timeout");
    end
    if (!actual.gamma_configured || actual.gamma_load_error)
      $fatal(1,"Checkpoint configuration failure");
    checkpoint_reloads++;
  endtask

  task automatic reset_system();
    clk=0; rst_n=1; #1;
    rst_n=0;
    dropped+=longint'(pending_ticks[0])+longint'(pending_ticks[1]);
    pending_ticks=0; epoch_recorded=0;
    held='0; held_valid=0; read_pulse_pending=0;
    tick_enable=0; clear_counters=0; phase_load_valid=0;
    csr_valid=1; csr_write=1; csr_addr=0; csr_wdata=1;
    #2; compare(2);
    if (live.seen || live.count!=0 || live.boundary_valid || live.alignment_error)
      $fatal(1,"Recorder asynchronous reset");
    clk=1; #2; compare(3);
    clk=0; #2; rst_n=1;
    resets++;
    restore_checkpoint();
    step(1,0,8'h10,0);
    step(1,1,0,1);
    read_all();
  endtask

  task automatic stimulus(input int mode, input int k);
    tick_enable=(k%32<24) || (k%3==0);
    clear_counters=(k%7==0);
    phase_load_valid=(k%13==0) || (k==80);
    auto_target_enable=(k%5==0);
    if (k%43==0) scheduler_mode=frp_m31_scheduler_mode_e'((mode+k/43)%3);
    for (int c=0;c<CELLS;c++) begin
      phase_load[c*32+:32]=32'(64'(c)*4294967296/CELLS+64'(k)*100003);
      frequency_load_q16[c*32+:32]=(k>=80 && k<160) ? 1048576 : 65536;
      target_bank[c*2+:2]=(c+k)%3==0 ? 2'b00 : ((c+k)%3==1 ? 2'b01 : 2'b11);
    end
    for (int lane=0;lane<LANES;lane++) begin
      request_valid[lane]=1;
      request_index[lane*INDEX_BITS+:INDEX_BITS]=INDEX_BITS'((k+lane)%CELLS);
      request_target[lane*2+:2]=k%2 ? 2'b01 : 2'b11;
    end
  endtask

  initial begin
    if ((CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64) ||
        (COUNT_BITS!=3 && COUNT_BITS!=64))
      $fatal(1,"Profiles: CELLS=8/16/32/64; COUNT_BITS=3/64");
    if ($value$plusargs("seed=%d",seed)) begin end
    random_state=seed ^ (32'(CELLS)<<16) ^ 32'(COUNT_BITS);
    if (random_state==0) random_state=32'h6d2b79f5;
    for (int mode=0;mode<3;mode++) begin
      reset_system();
      scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      for (int k=0;k<480;k++) begin
        int slot;
        int unsigned random_word;
        stimulus(mode,k);
        slot=k%64;
        random_word=next_random();
        if (slot==0) step(1,1,0,1);
        else if (slot<=29) step(1,0,8'(slot*4),0);
        else if (slot==30) step(1,1,0,3);
        else if (slot==31) step(1,1,8'h10,1);
        else if (slot==32) step(0,1,0,2);
        else if (slot==63) step(1,1,0,2);
        else step(1,1,8'(random_word | 1),random_word);
        tick_enable=0; #1;
      end
      tick_enable=0; clear_counters=0; phase_load_valid=0;
      repeat(4) step(0,0,0,0);
      if (pending_ticks!=0 || !live.boundary_valid)
        $fatal(1,"Drain/boundary coverage cells=%0d mode=%0d",CELLS,mode);
      step(1,1,0,1); read_all();
      step(1,1,0,2); read_all();
      step(1,1,0,1); read_all();
    end
    for (int occupancy=0;occupancy<3;occupancy++) begin
      reset_system();
      tick_enable=1;
      repeat(occupancy) step(1,1,0,1);
      reset_system();
      tick_enable=1;
      repeat(12) step(1,1,0,1);
      tick_enable=0;
      repeat(3) step(0,0,0,0);
      step(1,1,0,1); read_all();
    end
    if (accepted!=recorded+dropped || dropped!=3 || pending_ticks!=0)
      $fatal(1,"Accepted/recorded/reset-discarded conservation");
    if (modes_seen!==3'b111 || states_seen!==5'b11111 || payload_reads!=='1 ||
        concurrent_captures==0 || frozen_reads==0 || pulse_captures==0 ||
        pulse_reads<pulse_captures || empty_captures==0 || releases==0 || errors==0 ||
        first_legs==0 || second_legs==0 || phase_only==0 || clears==0 || idle_cycles==0)
      $fatal(1,"Integration coverage concurrent=%0d frozen=%0d pulses=%0d reads=%0d legs=%0d/%0d",
             concurrent_captures,frozen_reads,pulse_captures,pulse_reads,first_legs,second_legs);
    if ((COUNT_BITS==3 && saturated_captures==0) ||
        (COUNT_BITS==64 && saturated_captures!=0) || comparisons!=2*(cycles+resets))
      $fatal(1,"Saturation/comparison coverage");
    if (stalled_ticks==0 || stalled_csr==0 || checkpoint_reloads!=9)
      $fatal(1,"Handshake/checkpoint coverage");
    // Reload during existing history while an atomic snapshot is retained.
    step(1,1,0,1);
    restore_checkpoint();
    read_all();
    $display("PASS INTERNAL_GAMMA_OBSERVED cells=%0d outputs=114 stalls=%0d stalled_csr=%0d reloads=%0d", CELLS,stalled_ticks,stalled_csr,checkpoint_reloads);
    $display("PASS OBSERVED_SNAPSHOT_CSR cells=%0d count_bits=%0d seed=%0d cycles=%0d comparisons=%0d accepted=%0d recorded=%0d dropped=%0d captures=%0d concurrent=%0d frozen_reads=%0d pulse_captures=%0d pulse_reads=%0d saturated=%0d resets=%0d first_legs=%0d second_legs=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,cycles,comparisons,accepted,recorded,dropped,captures,
      concurrent_captures,frozen_reads,pulse_captures,pulse_reads,saturated_captures,
      resets,first_legs,second_legs,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Internal gamma observed CSR watchdog"); end
endmodule
`endif

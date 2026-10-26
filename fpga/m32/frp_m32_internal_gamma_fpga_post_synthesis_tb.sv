// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Compare the synthesized full FPGA composition against the internal-gamma RTL core.
// The netlist must include the core, gamma source and two-stage reset boundary.
// Export top: frp_m32_internal_gamma_fpga_netlist, specialized for CELLS.
// Lower dynamic selects before export:
//   techmap -map +/techmap.v t:$shiftx t:$bwmux; opt -fast; check -assert
// Compile that netlist alongside this test; select this test top explicitly.
// Include paths: rtl/m31, rtl/m32, fpga/m32. Profiles: 8/16/32/64 cells.
// STATE_FILE: 625 hexadecimal words from the Python checkpoint after FRP init
// (624 MT19937 state words followed by its index). TARGET_FILE: 80*CELLS Q16
// target words generated from that same checkpoint, in event-major order.
// Checks all 114 core outputs and four FPGA boundary outputs every checked clock.
// Exercises three scheduler modes, reset-release pulses/held controls, partial
// loads, invalid checkpoint index, reload during operation, prefetch backpressure,
// phase-only and combined loads, counter clears and continuously held tick valid.
// Python target words independently check gamma on each accepted update.
// Expected per run: 120 accepted ticks, 15 gamma updates, 8 resets, 18 load begins,
// 8747 state-word transfers and 15 phase loads. Run two deterministic replays.
// Functional generic-netlist simulation, without timing annotation.
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_fpga_top.sv"

module frp_m32_internal_gamma_fpga_post_synthesis_tb #(
  parameter int CELLS=8,
  parameter string STATE_FILE="internal_gamma_checkpoint.mem",
  parameter string TARGET_FILE="internal_gamma_targets.mem"
);

import frp_m31_pkg::*;
localparam int REQUEST_LANES=CELLS/4,CELL_INDEX_BITS=$clog2(CELLS),COUNTER_BITS=32;

logic clk;
logic rst_n_async;
logic tick_valid;
logic clear_counters;
frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode;
logic phase_load_valid;
logic [(CELLS*32)-1:0] phase_load;
logic [(CELLS*32)-1:0] frequency_load_q16;
logic auto_target_enable;
logic [REQUEST_LANES-1:0] external_request_valid;
logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] external_request_cell_index;
logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] external_request_target;
logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] external_target_bank;

wire [(CELLS*32)-1:0] phase_word_q;
wire [(CELLS*32)-1:0] frequency_current_q16;
wire [(CELLS*32)-1:0] coupling_field_q16;
wire [(CELLS*32)-1:0] phase_projection_q30;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_target_source;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] registered_target_q;
wire registered_target_valid_q;
wire phase_target_domain_valid;
wire registered_target_domain_valid;
wire target_capture_accepted;
wire target_capture_rejected;
wire [COUNTER_BITS-1:0] accepted_target_capture_events_q;
wire [COUNTER_BITS-1:0] rejected_target_capture_events_q;
wire registered_request_enable;
wire [REQUEST_LANES-1:0] phase_request_valid;
wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] phase_request_cell_index;
wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_request_target;
wire [REQUEST_LANES-1:0] execution_request_valid;
wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] execution_request_cell_index;
wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_request_target;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_target_bank;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] state_out;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] pending_route_out;
wire [1:0] scheduler_mode_q;
wire [2:0] scheduler_state_q;
wire [COUNTER_BITS-1:0] ticks_recorded_q;
wire [COUNTER_BITS-1:0] scheduler_count_free_q;
wire [COUNTER_BITS-1:0] scheduler_count_balance_q;
wire [COUNTER_BITS-1:0] scheduler_count_commit_q;
wire [COUNTER_BITS-1:0] scheduler_count_excite_q;
wire [COUNTER_BITS-1:0] scheduler_count_neutralize_q;
wire [REQUEST_LANES-1:0] request_accept;
wire [REQUEST_LANES-1:0] request_reject;
wire [CELLS-1:0] accepted_cell_mask;
wire [CELLS-1:0] neutral_routed_cell_mask;
wire [CELLS-1:0] accepted_change_mask;
wire [COUNTER_BITS-1:0] accepted_changes;
wire [COUNTER_BITS-1:0] capacity_remaining;
wire capacity_exhausted;
wire [COUNTER_BITS-1:0] switch_load_numerator;
wire [COUNTER_BITS-1:0] requested_direct_events;
wire [COUNTER_BITS-1:0] prevented_direct_events;
wire [COUNTER_BITS-1:0] neutral_routed_events;
wire [COUNTER_BITS-1:0] actual_direct_events;
wire [COUNTER_BITS-1:0] reserved_state_events;
wire [COUNTER_BITS-1:0] queue_overflow_events;
wire [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ] invariant_flags;
wire signed [31:0] pair_coherence_q30;
wire signed [31:0] cluster_coherence_q30;
wire signed [31:0] global_coherence_q30;
wire signed [31:0] organization_dispersion_q30;
wire signed [31:0] normalized_cycle_cost_q16;
wire signed [31:0] temperature_proxy_q16;
wire signed [31:0] peak_temperature_proxy_q16;
wire [31:0] thermal_sample_count_q;
wire signed [31:0] coherence_capacity_q16;
wire signed [31:0] pressure_q16;
wire signed [31:0] stability_margin_q16;
wire stable;
wire [(CELLS*32)-1:0] local_heat_q16;
wire [(CELLS*32)-1:0] local_heat_peak_q16;
wire [(CELLS*32)-1:0] local_generated_power_q16;
wire [(CELLS*32)-1:0] local_thermal_dissipation_q16;
wire [(CELLS*32)-1:0] local_thermal_diffusion_q16;
wire [(CELLS*32)-1:0] local_thermal_overload_q16;
wire [(CELLS*32)-1:0] local_next_heat_q16;
wire [(CELLS*32)-1:0] local_next_overload_q16;
wire [(CELLS*32)-1:0] local_frequency_lag_q16;
wire signed [31:0] local_mean_heat_q16;
wire signed [31:0] local_mean_heat_peak_q16;
wire signed [31:0] local_maximum_heat_peak_q16;
wire [(CELLS*32)-1:0] local_gamma_noise_target_q16;
wire [(CELLS*32)-1:0] local_gamma_noise_state_q16;
wire [(CELLS*32)-1:0] local_gamma_drift_word;
wire [(CELLS*32)-1:0] local_gamma_effective_word;
wire [(CELLS*32)-1:0] local_next_gamma_drift_word;
wire [(CELLS*32)-1:0] local_next_gamma_effective_word;
wire [(CELLS*32)-1:0] phase_gamma_effective_word;
wire [(CELLS*32)-1:0] local_thermal_node_factor_q30;
wire [(CELLS*32)-1:0] local_next_thermal_node_factor_q30;
wire [(CELLS*32)-1:0] phase_thermal_node_factor_q30;
wire [((CELLS-1)*32)-1:0] group_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] level_mean_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] level_min_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] level_max_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] level_dispersion_q30;
wire signed [31:0] local_coherence_compression_q30;
wire signed [31:0] local_effective_coherence_q30;
wire signed [31:0] local_coherence_capacity_q16;
wire signed [31:0] local_pressure_q16;
wire signed [31:0] local_stability_margin_q16;
wire local_stable;
wire signed [31:0] local_previous_margin_q16;
wire local_stability_valid_q;
wire [31:0] local_stability_sample_count_q;
wire signed [31:0] local_stability_raw_coherence_q30;
wire signed [31:0] local_stability_cluster_coherence_q30;
wire signed [31:0] local_stability_mean_heat_q16;
wire signed [31:0] local_stability_mean_overload_q16;
wire signed [31:0] local_stability_mean_lag_q16;
wire signed [31:0] local_stability_neutral_fraction_q30;
wire signed [31:0] local_stability_compression_arg_q16;
wire signed [31:0] local_stability_switch_load_q16;

logic checkpoint_load_begin;
logic [9:0] checkpoint_index;
logic checkpoint_load_valid;
logic [31:0] checkpoint_load_word;
wire checkpoint_load_ready;
wire gamma_configured;
wire gamma_load_error;
wire gamma_source_busy;
wire gamma_bank_valid;
wire tick_ready;
wire tick_accepted;
wire phase_load_ready;
wire phase_load_accepted;
wire gamma_update_accepted;
wire [2:0] gamma_tick_phase_q;

wire [(CELLS*32)-1:0] gold_phase_word_q;
wire [(CELLS*32)-1:0] gold_frequency_current_q16;
wire [(CELLS*32)-1:0] gold_coupling_field_q16;
wire [(CELLS*32)-1:0] gold_phase_projection_q30;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_phase_target_source;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_registered_target_q;
wire gold_registered_target_valid_q;
wire gold_phase_target_domain_valid;
wire gold_registered_target_domain_valid;
wire gold_target_capture_accepted;
wire gold_target_capture_rejected;
wire [COUNTER_BITS-1:0] gold_accepted_target_capture_events_q;
wire [COUNTER_BITS-1:0] gold_rejected_target_capture_events_q;
wire gold_registered_request_enable;
wire [REQUEST_LANES-1:0] gold_phase_request_valid;
wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] gold_phase_request_cell_index;
wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_phase_request_target;
wire [REQUEST_LANES-1:0] gold_execution_request_valid;
wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] gold_execution_request_cell_index;
wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_execution_request_target;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_execution_target_bank;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_state_out;
wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] gold_pending_route_out;
wire frp_m31_pkg::frp_m31_scheduler_mode_e gold_scheduler_mode_q;
wire frp_m31_pkg::frp_m31_scheduler_state_e gold_scheduler_state_q;
wire [COUNTER_BITS-1:0] gold_ticks_recorded_q;
wire [COUNTER_BITS-1:0] gold_scheduler_count_free_q;
wire [COUNTER_BITS-1:0] gold_scheduler_count_balance_q;
wire [COUNTER_BITS-1:0] gold_scheduler_count_commit_q;
wire [COUNTER_BITS-1:0] gold_scheduler_count_excite_q;
wire [COUNTER_BITS-1:0] gold_scheduler_count_neutralize_q;
wire [REQUEST_LANES-1:0] gold_request_accept;
wire [REQUEST_LANES-1:0] gold_request_reject;
wire [CELLS-1:0] gold_accepted_cell_mask;
wire [CELLS-1:0] gold_neutral_routed_cell_mask;
wire [CELLS-1:0] gold_accepted_change_mask;
wire [COUNTER_BITS-1:0] gold_accepted_changes;
wire [COUNTER_BITS-1:0] gold_capacity_remaining;
wire gold_capacity_exhausted;
wire [COUNTER_BITS-1:0] gold_switch_load_numerator;
wire [COUNTER_BITS-1:0] gold_requested_direct_events;
wire [COUNTER_BITS-1:0] gold_prevented_direct_events;
wire [COUNTER_BITS-1:0] gold_neutral_routed_events;
wire [COUNTER_BITS-1:0] gold_actual_direct_events;
wire [COUNTER_BITS-1:0] gold_reserved_state_events;
wire [COUNTER_BITS-1:0] gold_queue_overflow_events;
wire [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ] gold_invariant_flags;
wire signed [31:0] gold_pair_coherence_q30;
wire signed [31:0] gold_cluster_coherence_q30;
wire signed [31:0] gold_global_coherence_q30;
wire signed [31:0] gold_organization_dispersion_q30;
wire signed [31:0] gold_normalized_cycle_cost_q16;
wire signed [31:0] gold_temperature_proxy_q16;
wire signed [31:0] gold_peak_temperature_proxy_q16;
wire [31:0] gold_thermal_sample_count_q;
wire signed [31:0] gold_coherence_capacity_q16;
wire signed [31:0] gold_pressure_q16;
wire signed [31:0] gold_stability_margin_q16;
wire gold_stable;
wire [(CELLS*32)-1:0] gold_local_heat_q16;
wire [(CELLS*32)-1:0] gold_local_heat_peak_q16;
wire [(CELLS*32)-1:0] gold_local_generated_power_q16;
wire [(CELLS*32)-1:0] gold_local_thermal_dissipation_q16;
wire [(CELLS*32)-1:0] gold_local_thermal_diffusion_q16;
wire [(CELLS*32)-1:0] gold_local_thermal_overload_q16;
wire [(CELLS*32)-1:0] gold_local_next_heat_q16;
wire [(CELLS*32)-1:0] gold_local_next_overload_q16;
wire [(CELLS*32)-1:0] gold_local_frequency_lag_q16;
wire signed [31:0] gold_local_mean_heat_q16;
wire signed [31:0] gold_local_mean_heat_peak_q16;
wire signed [31:0] gold_local_maximum_heat_peak_q16;
wire [(CELLS*32)-1:0] gold_local_gamma_noise_target_q16;
wire [(CELLS*32)-1:0] gold_local_gamma_noise_state_q16;
wire [(CELLS*32)-1:0] gold_local_gamma_drift_word;
wire [(CELLS*32)-1:0] gold_local_gamma_effective_word;
wire [(CELLS*32)-1:0] gold_local_next_gamma_drift_word;
wire [(CELLS*32)-1:0] gold_local_next_gamma_effective_word;
wire [(CELLS*32)-1:0] gold_phase_gamma_effective_word;
wire [(CELLS*32)-1:0] gold_local_thermal_node_factor_q30;
wire [(CELLS*32)-1:0] gold_local_next_thermal_node_factor_q30;
wire [(CELLS*32)-1:0] gold_phase_thermal_node_factor_q30;
wire [((CELLS-1)*32)-1:0] gold_group_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] gold_level_mean_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] gold_level_min_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] gold_level_max_coherence_q30;
wire [($clog2(CELLS)*32)-1:0] gold_level_dispersion_q30;
wire signed [31:0] gold_local_coherence_compression_q30;
wire signed [31:0] gold_local_effective_coherence_q30;
wire signed [31:0] gold_local_coherence_capacity_q16;
wire signed [31:0] gold_local_pressure_q16;
wire signed [31:0] gold_local_stability_margin_q16;
wire gold_local_stable;
wire signed [31:0] gold_local_previous_margin_q16;
wire gold_local_stability_valid_q;
wire [31:0] gold_local_stability_sample_count_q;
wire signed [31:0] gold_local_stability_raw_coherence_q30;
wire signed [31:0] gold_local_stability_cluster_coherence_q30;
wire signed [31:0] gold_local_stability_mean_heat_q16;
wire signed [31:0] gold_local_stability_mean_overload_q16;
wire signed [31:0] gold_local_stability_mean_lag_q16;
wire signed [31:0] gold_local_stability_neutral_fraction_q30;
wire signed [31:0] gold_local_stability_compression_arg_q16;
wire signed [31:0] gold_local_stability_switch_load_q16;
wire gold_checkpoint_load_ready;
wire gold_gamma_configured;
wire gold_gamma_load_error;
wire gold_gamma_source_busy;
wire gold_gamma_bank_valid;
wire gold_tick_ready;
wire gold_tick_accepted;
wire gold_phase_load_ready;
wire gold_phase_load_accepted;
wire gold_gamma_update_accepted;
wire [2:0] gold_gamma_tick_phase_q;

wire core_ready,checkpoint_begin_ready,checkpoint_begin_accepted,checkpoint_word_accepted;
int release_edges=0,cycles=0,logical_ticks=0,draws=0,total_ticks=0,updates=0;
int begin_transfers=0,word_transfers=0,phase_transfers=0,blocked=0,resets=0;
wire rst_n_ref = rst_n_async && release_edges==2;
logic [31:0] snapshot[0:624],expected[0:80*CELLS-1];

frp_m32_internal_gamma_fpga_netlist dut(.*);

frp_m32_internal_gamma_core #(.CELLS(CELLS)) gold(
.clk(clk),
.rst_n(rst_n_ref),
.tick_valid(tick_valid && rst_n_ref),
.clear_counters(clear_counters && rst_n_ref),
.scheduler_mode(scheduler_mode),
.phase_load_valid(phase_load_valid && rst_n_ref),
.phase_load(phase_load),
.frequency_load_q16(frequency_load_q16),
.auto_target_enable(auto_target_enable && rst_n_ref),
.external_request_valid(external_request_valid & {REQUEST_LANES{rst_n_ref}}),
.external_request_cell_index(external_request_cell_index),
.external_request_target(external_request_target),
.external_target_bank(external_target_bank),
.phase_word_q(gold_phase_word_q),
.frequency_current_q16(gold_frequency_current_q16),
.coupling_field_q16(gold_coupling_field_q16),
.phase_projection_q30(gold_phase_projection_q30),
.phase_target_source(gold_phase_target_source),
.registered_target_q(gold_registered_target_q),
.registered_target_valid_q(gold_registered_target_valid_q),
.phase_target_domain_valid(gold_phase_target_domain_valid),
.registered_target_domain_valid(gold_registered_target_domain_valid),
.target_capture_accepted(gold_target_capture_accepted),
.target_capture_rejected(gold_target_capture_rejected),
.accepted_target_capture_events_q(gold_accepted_target_capture_events_q),
.rejected_target_capture_events_q(gold_rejected_target_capture_events_q),
.registered_request_enable(gold_registered_request_enable),
.phase_request_valid(gold_phase_request_valid),
.phase_request_cell_index(gold_phase_request_cell_index),
.phase_request_target(gold_phase_request_target),
.execution_request_valid(gold_execution_request_valid),
.execution_request_cell_index(gold_execution_request_cell_index),
.execution_request_target(gold_execution_request_target),
.execution_target_bank(gold_execution_target_bank),
.state_out(gold_state_out),
.pending_route_out(gold_pending_route_out),
.scheduler_mode_q(gold_scheduler_mode_q),
.scheduler_state_q(gold_scheduler_state_q),
.ticks_recorded_q(gold_ticks_recorded_q),
.scheduler_count_free_q(gold_scheduler_count_free_q),
.scheduler_count_balance_q(gold_scheduler_count_balance_q),
.scheduler_count_commit_q(gold_scheduler_count_commit_q),
.scheduler_count_excite_q(gold_scheduler_count_excite_q),
.scheduler_count_neutralize_q(gold_scheduler_count_neutralize_q),
.request_accept(gold_request_accept),
.request_reject(gold_request_reject),
.accepted_cell_mask(gold_accepted_cell_mask),
.neutral_routed_cell_mask(gold_neutral_routed_cell_mask),
.accepted_change_mask(gold_accepted_change_mask),
.accepted_changes(gold_accepted_changes),
.capacity_remaining(gold_capacity_remaining),
.capacity_exhausted(gold_capacity_exhausted),
.switch_load_numerator(gold_switch_load_numerator),
.requested_direct_events(gold_requested_direct_events),
.prevented_direct_events(gold_prevented_direct_events),
.neutral_routed_events(gold_neutral_routed_events),
.actual_direct_events(gold_actual_direct_events),
.reserved_state_events(gold_reserved_state_events),
.queue_overflow_events(gold_queue_overflow_events),
.invariant_flags(gold_invariant_flags),
.pair_coherence_q30(gold_pair_coherence_q30),
.cluster_coherence_q30(gold_cluster_coherence_q30),
.global_coherence_q30(gold_global_coherence_q30),
.organization_dispersion_q30(gold_organization_dispersion_q30),
.normalized_cycle_cost_q16(gold_normalized_cycle_cost_q16),
.temperature_proxy_q16(gold_temperature_proxy_q16),
.peak_temperature_proxy_q16(gold_peak_temperature_proxy_q16),
.thermal_sample_count_q(gold_thermal_sample_count_q),
.coherence_capacity_q16(gold_coherence_capacity_q16),
.pressure_q16(gold_pressure_q16),
.stability_margin_q16(gold_stability_margin_q16),
.stable(gold_stable),
.local_heat_q16(gold_local_heat_q16),
.local_heat_peak_q16(gold_local_heat_peak_q16),
.local_generated_power_q16(gold_local_generated_power_q16),
.local_thermal_dissipation_q16(gold_local_thermal_dissipation_q16),
.local_thermal_diffusion_q16(gold_local_thermal_diffusion_q16),
.local_thermal_overload_q16(gold_local_thermal_overload_q16),
.local_next_heat_q16(gold_local_next_heat_q16),
.local_next_overload_q16(gold_local_next_overload_q16),
.local_frequency_lag_q16(gold_local_frequency_lag_q16),
.local_mean_heat_q16(gold_local_mean_heat_q16),
.local_mean_heat_peak_q16(gold_local_mean_heat_peak_q16),
.local_maximum_heat_peak_q16(gold_local_maximum_heat_peak_q16),
.local_gamma_noise_target_q16(gold_local_gamma_noise_target_q16),
.local_gamma_noise_state_q16(gold_local_gamma_noise_state_q16),
.local_gamma_drift_word(gold_local_gamma_drift_word),
.local_gamma_effective_word(gold_local_gamma_effective_word),
.local_next_gamma_drift_word(gold_local_next_gamma_drift_word),
.local_next_gamma_effective_word(gold_local_next_gamma_effective_word),
.phase_gamma_effective_word(gold_phase_gamma_effective_word),
.local_thermal_node_factor_q30(gold_local_thermal_node_factor_q30),
.local_next_thermal_node_factor_q30(gold_local_next_thermal_node_factor_q30),
.phase_thermal_node_factor_q30(gold_phase_thermal_node_factor_q30),
.group_coherence_q30(gold_group_coherence_q30),
.level_mean_coherence_q30(gold_level_mean_coherence_q30),
.level_min_coherence_q30(gold_level_min_coherence_q30),
.level_max_coherence_q30(gold_level_max_coherence_q30),
.level_dispersion_q30(gold_level_dispersion_q30),
.local_coherence_compression_q30(gold_local_coherence_compression_q30),
.local_effective_coherence_q30(gold_local_effective_coherence_q30),
.local_coherence_capacity_q16(gold_local_coherence_capacity_q16),
.local_pressure_q16(gold_local_pressure_q16),
.local_stability_margin_q16(gold_local_stability_margin_q16),
.local_stable(gold_local_stable),
.local_previous_margin_q16(gold_local_previous_margin_q16),
.local_stability_valid_q(gold_local_stability_valid_q),
.local_stability_sample_count_q(gold_local_stability_sample_count_q),
.local_stability_raw_coherence_q30(gold_local_stability_raw_coherence_q30),
.local_stability_cluster_coherence_q30(gold_local_stability_cluster_coherence_q30),
.local_stability_mean_heat_q16(gold_local_stability_mean_heat_q16),
.local_stability_mean_overload_q16(gold_local_stability_mean_overload_q16),
.local_stability_mean_lag_q16(gold_local_stability_mean_lag_q16),
.local_stability_neutral_fraction_q30(gold_local_stability_neutral_fraction_q30),
.local_stability_compression_arg_q16(gold_local_stability_compression_arg_q16),
.local_stability_switch_load_q16(gold_local_stability_switch_load_q16),
.checkpoint_load_begin(checkpoint_load_begin && rst_n_ref),
.checkpoint_index(checkpoint_index),
.checkpoint_load_valid(checkpoint_load_valid && rst_n_ref),
.checkpoint_load_word(checkpoint_load_word),
.checkpoint_load_ready(gold_checkpoint_load_ready),
.gamma_configured(gold_gamma_configured),
.gamma_load_error(gold_gamma_load_error),
.gamma_source_busy(gold_gamma_source_busy),
.gamma_bank_valid(gold_gamma_bank_valid),
.tick_ready(gold_tick_ready),
.tick_accepted(gold_tick_accepted),
.phase_load_ready(gold_phase_load_ready),
.phase_load_accepted(gold_phase_load_accepted),
.gamma_update_accepted(gold_gamma_update_accepted),
.gamma_tick_phase_q(gold_gamma_tick_phase_q)
);

always @(negedge rst_n_async) release_edges=0;

event compare_event;
always @(compare_event) begin
 if(phase_word_q !== gold_phase_word_q)$fatal(1,"forward phase_word_q n=%0d cycle=%0d",CELLS,cycles);
 if(frequency_current_q16 !== gold_frequency_current_q16)$fatal(1,"forward frequency_current_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(coupling_field_q16 !== gold_coupling_field_q16)$fatal(1,"forward coupling_field_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(phase_projection_q30 !== gold_phase_projection_q30)$fatal(1,"forward phase_projection_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(phase_target_source !== gold_phase_target_source)$fatal(1,"forward phase_target_source n=%0d cycle=%0d",CELLS,cycles);
 if(registered_target_q !== gold_registered_target_q)$fatal(1,"forward registered_target_q n=%0d cycle=%0d",CELLS,cycles);
 if(registered_target_valid_q !== gold_registered_target_valid_q)$fatal(1,"forward registered_target_valid_q n=%0d cycle=%0d",CELLS,cycles);
 if(phase_target_domain_valid !== gold_phase_target_domain_valid)$fatal(1,"forward phase_target_domain_valid n=%0d cycle=%0d",CELLS,cycles);
 if(registered_target_domain_valid !== gold_registered_target_domain_valid)$fatal(1,"forward registered_target_domain_valid n=%0d cycle=%0d",CELLS,cycles);
 if(target_capture_accepted !== gold_target_capture_accepted)$fatal(1,"forward target_capture_accepted n=%0d cycle=%0d",CELLS,cycles);
 if(target_capture_rejected !== gold_target_capture_rejected)$fatal(1,"forward target_capture_rejected n=%0d cycle=%0d",CELLS,cycles);
 if(accepted_target_capture_events_q !== gold_accepted_target_capture_events_q)$fatal(1,"forward accepted_target_capture_events_q n=%0d cycle=%0d",CELLS,cycles);
 if(rejected_target_capture_events_q !== gold_rejected_target_capture_events_q)$fatal(1,"forward rejected_target_capture_events_q n=%0d cycle=%0d",CELLS,cycles);
 if(registered_request_enable !== gold_registered_request_enable)$fatal(1,"forward registered_request_enable n=%0d cycle=%0d",CELLS,cycles);
 if(phase_request_valid !== gold_phase_request_valid)$fatal(1,"forward phase_request_valid n=%0d cycle=%0d",CELLS,cycles);
 if(phase_request_cell_index !== gold_phase_request_cell_index)$fatal(1,"forward phase_request_cell_index n=%0d cycle=%0d",CELLS,cycles);
 if(phase_request_target !== gold_phase_request_target)$fatal(1,"forward phase_request_target n=%0d cycle=%0d",CELLS,cycles);
 if(execution_request_valid !== gold_execution_request_valid)$fatal(1,"forward execution_request_valid n=%0d cycle=%0d",CELLS,cycles);
 if(execution_request_cell_index !== gold_execution_request_cell_index)$fatal(1,"forward execution_request_cell_index n=%0d cycle=%0d",CELLS,cycles);
 if(execution_request_target !== gold_execution_request_target)$fatal(1,"forward execution_request_target n=%0d cycle=%0d",CELLS,cycles);
 if(execution_target_bank !== gold_execution_target_bank)$fatal(1,"forward execution_target_bank n=%0d cycle=%0d",CELLS,cycles);
 if(state_out !== gold_state_out)$fatal(1,"forward state_out n=%0d cycle=%0d",CELLS,cycles);
 if(pending_route_out !== gold_pending_route_out)$fatal(1,"forward pending_route_out n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_mode_q !== gold_scheduler_mode_q)$fatal(1,"forward scheduler_mode_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_state_q !== gold_scheduler_state_q)$fatal(1,"forward scheduler_state_q n=%0d cycle=%0d",CELLS,cycles);
 if(ticks_recorded_q !== gold_ticks_recorded_q)$fatal(1,"forward ticks_recorded_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_count_free_q !== gold_scheduler_count_free_q)$fatal(1,"forward scheduler_count_free_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_count_balance_q !== gold_scheduler_count_balance_q)$fatal(1,"forward scheduler_count_balance_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_count_commit_q !== gold_scheduler_count_commit_q)$fatal(1,"forward scheduler_count_commit_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_count_excite_q !== gold_scheduler_count_excite_q)$fatal(1,"forward scheduler_count_excite_q n=%0d cycle=%0d",CELLS,cycles);
 if(scheduler_count_neutralize_q !== gold_scheduler_count_neutralize_q)$fatal(1,"forward scheduler_count_neutralize_q n=%0d cycle=%0d",CELLS,cycles);
 if(request_accept !== gold_request_accept)$fatal(1,"forward request_accept n=%0d cycle=%0d",CELLS,cycles);
 if(request_reject !== gold_request_reject)$fatal(1,"forward request_reject n=%0d cycle=%0d",CELLS,cycles);
 if(accepted_cell_mask !== gold_accepted_cell_mask)$fatal(1,"forward accepted_cell_mask n=%0d cycle=%0d",CELLS,cycles);
 if(neutral_routed_cell_mask !== gold_neutral_routed_cell_mask)$fatal(1,"forward neutral_routed_cell_mask n=%0d cycle=%0d",CELLS,cycles);
 if(accepted_change_mask !== gold_accepted_change_mask)$fatal(1,"forward accepted_change_mask n=%0d cycle=%0d",CELLS,cycles);
 if(accepted_changes !== gold_accepted_changes)$fatal(1,"forward accepted_changes n=%0d cycle=%0d",CELLS,cycles);
 if(capacity_remaining !== gold_capacity_remaining)$fatal(1,"forward capacity_remaining n=%0d cycle=%0d",CELLS,cycles);
 if(capacity_exhausted !== gold_capacity_exhausted)$fatal(1,"forward capacity_exhausted n=%0d cycle=%0d",CELLS,cycles);
 if(switch_load_numerator !== gold_switch_load_numerator)$fatal(1,"forward switch_load_numerator n=%0d cycle=%0d",CELLS,cycles);
 if(requested_direct_events !== gold_requested_direct_events)$fatal(1,"forward requested_direct_events n=%0d cycle=%0d",CELLS,cycles);
 if(prevented_direct_events !== gold_prevented_direct_events)$fatal(1,"forward prevented_direct_events n=%0d cycle=%0d",CELLS,cycles);
 if(neutral_routed_events !== gold_neutral_routed_events)$fatal(1,"forward neutral_routed_events n=%0d cycle=%0d",CELLS,cycles);
 if(actual_direct_events !== gold_actual_direct_events)$fatal(1,"forward actual_direct_events n=%0d cycle=%0d",CELLS,cycles);
 if(reserved_state_events !== gold_reserved_state_events)$fatal(1,"forward reserved_state_events n=%0d cycle=%0d",CELLS,cycles);
 if(queue_overflow_events !== gold_queue_overflow_events)$fatal(1,"forward queue_overflow_events n=%0d cycle=%0d",CELLS,cycles);
 if(invariant_flags !== gold_invariant_flags)$fatal(1,"forward invariant_flags n=%0d cycle=%0d",CELLS,cycles);
 if(pair_coherence_q30 !== gold_pair_coherence_q30)$fatal(1,"forward pair_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(cluster_coherence_q30 !== gold_cluster_coherence_q30)$fatal(1,"forward cluster_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(global_coherence_q30 !== gold_global_coherence_q30)$fatal(1,"forward global_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(organization_dispersion_q30 !== gold_organization_dispersion_q30)$fatal(1,"forward organization_dispersion_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(normalized_cycle_cost_q16 !== gold_normalized_cycle_cost_q16)$fatal(1,"forward normalized_cycle_cost_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(temperature_proxy_q16 !== gold_temperature_proxy_q16)$fatal(1,"forward temperature_proxy_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(peak_temperature_proxy_q16 !== gold_peak_temperature_proxy_q16)$fatal(1,"forward peak_temperature_proxy_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(thermal_sample_count_q !== gold_thermal_sample_count_q)$fatal(1,"forward thermal_sample_count_q n=%0d cycle=%0d",CELLS,cycles);
 if(coherence_capacity_q16 !== gold_coherence_capacity_q16)$fatal(1,"forward coherence_capacity_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(pressure_q16 !== gold_pressure_q16)$fatal(1,"forward pressure_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(stability_margin_q16 !== gold_stability_margin_q16)$fatal(1,"forward stability_margin_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(stable !== gold_stable)$fatal(1,"forward stable n=%0d cycle=%0d",CELLS,cycles);
 if(local_heat_q16 !== gold_local_heat_q16)$fatal(1,"forward local_heat_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_heat_peak_q16 !== gold_local_heat_peak_q16)$fatal(1,"forward local_heat_peak_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_generated_power_q16 !== gold_local_generated_power_q16)$fatal(1,"forward local_generated_power_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_thermal_dissipation_q16 !== gold_local_thermal_dissipation_q16)$fatal(1,"forward local_thermal_dissipation_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_thermal_diffusion_q16 !== gold_local_thermal_diffusion_q16)$fatal(1,"forward local_thermal_diffusion_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_thermal_overload_q16 !== gold_local_thermal_overload_q16)$fatal(1,"forward local_thermal_overload_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_next_heat_q16 !== gold_local_next_heat_q16)$fatal(1,"forward local_next_heat_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_next_overload_q16 !== gold_local_next_overload_q16)$fatal(1,"forward local_next_overload_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_frequency_lag_q16 !== gold_local_frequency_lag_q16)$fatal(1,"forward local_frequency_lag_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_mean_heat_q16 !== gold_local_mean_heat_q16)$fatal(1,"forward local_mean_heat_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_mean_heat_peak_q16 !== gold_local_mean_heat_peak_q16)$fatal(1,"forward local_mean_heat_peak_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_maximum_heat_peak_q16 !== gold_local_maximum_heat_peak_q16)$fatal(1,"forward local_maximum_heat_peak_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_gamma_noise_target_q16 !== gold_local_gamma_noise_target_q16)$fatal(1,"forward local_gamma_noise_target_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_gamma_noise_state_q16 !== gold_local_gamma_noise_state_q16)$fatal(1,"forward local_gamma_noise_state_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_gamma_drift_word !== gold_local_gamma_drift_word)$fatal(1,"forward local_gamma_drift_word n=%0d cycle=%0d",CELLS,cycles);
 if(local_gamma_effective_word !== gold_local_gamma_effective_word)$fatal(1,"forward local_gamma_effective_word n=%0d cycle=%0d",CELLS,cycles);
 if(local_next_gamma_drift_word !== gold_local_next_gamma_drift_word)$fatal(1,"forward local_next_gamma_drift_word n=%0d cycle=%0d",CELLS,cycles);
 if(local_next_gamma_effective_word !== gold_local_next_gamma_effective_word)$fatal(1,"forward local_next_gamma_effective_word n=%0d cycle=%0d",CELLS,cycles);
 if(phase_gamma_effective_word !== gold_phase_gamma_effective_word)$fatal(1,"forward phase_gamma_effective_word n=%0d cycle=%0d",CELLS,cycles);
 if(local_thermal_node_factor_q30 !== gold_local_thermal_node_factor_q30)$fatal(1,"forward local_thermal_node_factor_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_next_thermal_node_factor_q30 !== gold_local_next_thermal_node_factor_q30)$fatal(1,"forward local_next_thermal_node_factor_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(phase_thermal_node_factor_q30 !== gold_phase_thermal_node_factor_q30)$fatal(1,"forward phase_thermal_node_factor_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(group_coherence_q30 !== gold_group_coherence_q30)$fatal(1,"forward group_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(level_mean_coherence_q30 !== gold_level_mean_coherence_q30)$fatal(1,"forward level_mean_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(level_min_coherence_q30 !== gold_level_min_coherence_q30)$fatal(1,"forward level_min_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(level_max_coherence_q30 !== gold_level_max_coherence_q30)$fatal(1,"forward level_max_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(level_dispersion_q30 !== gold_level_dispersion_q30)$fatal(1,"forward level_dispersion_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_coherence_compression_q30 !== gold_local_coherence_compression_q30)$fatal(1,"forward local_coherence_compression_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_effective_coherence_q30 !== gold_local_effective_coherence_q30)$fatal(1,"forward local_effective_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_coherence_capacity_q16 !== gold_local_coherence_capacity_q16)$fatal(1,"forward local_coherence_capacity_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_pressure_q16 !== gold_local_pressure_q16)$fatal(1,"forward local_pressure_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_margin_q16 !== gold_local_stability_margin_q16)$fatal(1,"forward local_stability_margin_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stable !== gold_local_stable)$fatal(1,"forward local_stable n=%0d cycle=%0d",CELLS,cycles);
 if(local_previous_margin_q16 !== gold_local_previous_margin_q16)$fatal(1,"forward local_previous_margin_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_valid_q !== gold_local_stability_valid_q)$fatal(1,"forward local_stability_valid_q n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_sample_count_q !== gold_local_stability_sample_count_q)$fatal(1,"forward local_stability_sample_count_q n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_raw_coherence_q30 !== gold_local_stability_raw_coherence_q30)$fatal(1,"forward local_stability_raw_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_cluster_coherence_q30 !== gold_local_stability_cluster_coherence_q30)$fatal(1,"forward local_stability_cluster_coherence_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_mean_heat_q16 !== gold_local_stability_mean_heat_q16)$fatal(1,"forward local_stability_mean_heat_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_mean_overload_q16 !== gold_local_stability_mean_overload_q16)$fatal(1,"forward local_stability_mean_overload_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_mean_lag_q16 !== gold_local_stability_mean_lag_q16)$fatal(1,"forward local_stability_mean_lag_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_neutral_fraction_q30 !== gold_local_stability_neutral_fraction_q30)$fatal(1,"forward local_stability_neutral_fraction_q30 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_compression_arg_q16 !== gold_local_stability_compression_arg_q16)$fatal(1,"forward local_stability_compression_arg_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(local_stability_switch_load_q16 !== gold_local_stability_switch_load_q16)$fatal(1,"forward local_stability_switch_load_q16 n=%0d cycle=%0d",CELLS,cycles);
 if(checkpoint_load_ready !== gold_checkpoint_load_ready)$fatal(1,"forward checkpoint_load_ready n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_configured !== gold_gamma_configured)$fatal(1,"forward gamma_configured n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_load_error !== gold_gamma_load_error)$fatal(1,"forward gamma_load_error n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_source_busy !== gold_gamma_source_busy)$fatal(1,"forward gamma_source_busy n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_bank_valid !== gold_gamma_bank_valid)$fatal(1,"forward gamma_bank_valid n=%0d cycle=%0d",CELLS,cycles);
 if(tick_ready !== gold_tick_ready)$fatal(1,"forward tick_ready n=%0d cycle=%0d",CELLS,cycles);
 if(tick_accepted !== gold_tick_accepted)$fatal(1,"forward tick_accepted n=%0d cycle=%0d",CELLS,cycles);
 if(phase_load_ready !== gold_phase_load_ready)$fatal(1,"forward phase_load_ready n=%0d cycle=%0d",CELLS,cycles);
 if(phase_load_accepted !== gold_phase_load_accepted)$fatal(1,"forward phase_load_accepted n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_update_accepted !== gold_gamma_update_accepted)$fatal(1,"forward gamma_update_accepted n=%0d cycle=%0d",CELLS,cycles);
 if(gamma_tick_phase_q !== gold_gamma_tick_phase_q)$fatal(1,"forward gamma_tick_phase_q n=%0d cycle=%0d",CELLS,cycles);
 if(core_ready!==rst_n_ref || checkpoint_begin_ready!==rst_n_ref)$fatal(1,"reset release");
 if(checkpoint_begin_accepted!==(rst_n_ref&&checkpoint_load_begin))$fatal(1,"begin handshake");
 if(checkpoint_word_accepted!==(checkpoint_load_valid&&gold_checkpoint_load_ready))$fatal(1,"word handshake");
 if(tick_accepted!==(tick_valid&&gold_tick_ready))$fatal(1,"tick handshake");
 if(phase_load_accepted!==(phase_load_valid&&gold_phase_load_ready))$fatal(1,"phase handshake");
 if(gamma_tick_phase_q!==3'(logical_ticks%8))$fatal(1,"logical cadence");
 if(actual_direct_events || reserved_state_events || queue_overflow_events)$fatal(1,"invariant");
end

task automatic compare;
 ->compare_event;#0.01;
endtask

task automatic cycle;
 bit fire,update;
 #1;compare();fire=tick_accepted;update=gamma_update_accepted;
 if(update!==(fire&&logical_ticks%8==0))$fatal(1,"update cadence");
 if(checkpoint_begin_accepted)begin_transfers++;
 if(checkpoint_word_accepted)word_transfers++;
 if(phase_load_accepted)phase_transfers++;
 if(tick_valid&&!fire)blocked++;
 clk=1;#1;
 if(rst_n_async && release_edges<2)release_edges++;
 if(fire)begin logical_ticks++;total_ticks++;end
 if(update)begin
  for(int k=0;k<CELLS;k++)if(local_gamma_noise_target_q16[k*32+:32]!==expected[draws*CELLS+k])
   $fatal(1,"Python gamma n=%0d draw=%0d lane=%0d net=%h rtl=%h expected=%h",CELLS,draws,k,local_gamma_noise_target_q16[k*32+:32],gold_local_gamma_noise_target_q16[k*32+:32],expected[draws*CELLS+k]);
  draws++;updates++;
 end
 clk=0;#1;cycles++;compare();
endtask

task automatic idle_controls;
 tick_valid=0;phase_load_valid=0;clear_counters=0;checkpoint_load_begin=0;checkpoint_load_valid=0;
endtask

task automatic assert_reset;
 // Exercise assertion between clock edges, with no clock needed to clear ready.
 rst_n_async=0;logical_ticks=0;draws=0;#0.2;compare();resets++;
 if(core_ready || gamma_configured || gamma_bank_valid || tick_ready || checkpoint_load_ready || phase_load_ready)$fatal(1,"async reset");
 cycle();
endtask

task automatic release_reset;
 rst_n_async=1;cycle();if(core_ready)$fatal(1,"early release");
 cycle();if(!core_ready)$fatal(1,"late release");
endtask

task automatic load_snapshot;
 int before_words;
 checkpoint_load_begin=1;checkpoint_index=10'(snapshot[624]);cycle();checkpoint_load_begin=0;draws=0;
 before_words=word_transfers;
 for(int i=0;i<624;i++)begin
  checkpoint_load_word=snapshot[i];checkpoint_load_valid=1;
  #0.1;if(!checkpoint_load_ready)$fatal(1,"load ready");cycle();
  if(i%13==0)begin checkpoint_load_valid=0;cycle();end
 end
 checkpoint_load_valid=0;
 if(word_transfers-before_words!=624 || !gamma_configured || gamma_load_error)$fatal(1,"checkpoint transfer");
endtask

task automatic accept_tick;
 int before_ticks;
 tick_valid=1;before_ticks=logical_ticks;
 for(int t=0;t<2000&&logical_ticks==before_ticks;t++)cycle();
 if(logical_ticks!=before_ticks+1)$fatal(1,"lost or duplicate tick");
 tick_valid=0;phase_load_valid=0;clear_counters=0;
endtask

initial begin
 clk=0;rst_n_async=1;idle_controls();scheduler_mode=FRP_MODE_FREE;
 phase_load='0;frequency_load_q16={CELLS{32'd65536}};
 auto_target_enable=1;external_request_valid='1;external_request_cell_index='0;
 external_request_target='0;external_target_bank='0;checkpoint_index=0;checkpoint_load_word=0;
 $readmemh(STATE_FILE,snapshot);$readmemh(TARGET_FILE,expected);

 // Pulses confined to reset release must not become operations afterward.
 assert_reset();checkpoint_load_begin=1;checkpoint_load_valid=1;phase_load_valid=1;tick_valid=1;clear_counters=1;
 rst_n_async=1;cycle();idle_controls();cycle();cycle();
 if(begin_transfers || word_transfers || phase_transfers || total_ticks || gamma_configured || checkpoint_load_ready)$fatal(1,"reset pulse leaked");

 // Held controls first become eligible on the third release edge.
 assert_reset();checkpoint_load_begin=1;checkpoint_load_valid=1;phase_load_valid=1;tick_valid=1;
 checkpoint_index=10'(snapshot[624]);release_reset();
 if(begin_transfers || word_transfers || phase_transfers || total_ticks)$fatal(1,"release edge consumed control");
 cycle();if(begin_transfers!=1 || word_transfers || phase_transfers || total_ticks)$fatal(1,"held begin priority");
 idle_controls();

 // Reset in a partial load, then in generation, then with a completed bank.
 checkpoint_load_valid=1;checkpoint_load_word=snapshot[0];repeat(11)cycle();assert_reset();idle_controls();release_reset();
 load_snapshot();cycle();if(!gamma_source_busy)$fatal(1,"source did not start");assert_reset();idle_controls();release_reset();
 load_snapshot();for(int t=0;!gamma_bank_valid&&t<2000;t++)cycle();
 if(!gamma_bank_valid)$fatal(1,"bank timeout");assert_reset();idle_controls();release_reset();

 for(int m=0;m<3;m++)begin
  idle_controls();assert_reset();release_reset();scheduler_mode=frp_m31_scheduler_mode_e'(m);
  for(int i=0;i<CELLS;i++)phase_load[i*32+:32]=32'(i*32'h13851cab+m*32'h01111000);
  phase_load_valid=1;cycle();phase_load_valid=0;
  if(phase_word_q!==phase_load || gamma_configured)$fatal(1,"phase-only before checkpoint");
  tick_valid=1;load_snapshot();tick_valid=0;

  for(int step=0;step<24;step++)begin
   if(step==6)repeat(700)cycle();
   if(step==8 || step==13)begin tick_valid=1;load_snapshot();tick_valid=0;end
   if(step==17)begin
    checkpoint_load_begin=1;checkpoint_index=625;tick_valid=1;cycle();checkpoint_load_begin=0;repeat(5)cycle();
    if(!gamma_load_error || gamma_configured || tick_ready)$fatal(1,"invalid checkpoint accepted");
    load_snapshot();tick_valid=0;
   end
   auto_target_enable=(step/4)%2==0;
   for(int lane=0;lane<REQUEST_LANES;lane++)begin
    external_request_cell_index[lane*CELL_INDEX_BITS+:CELL_INDEX_BITS]=CELL_INDEX_BITS'((step+lane)%CELLS);
    external_request_target[lane*2+:2]=(step%3==0)?FRP_STATE_NEG:FRP_STATE_POS;
   end
   for(int i=0;i<CELLS;i++)external_target_bank[i*2+:2]=(step%3==0)?FRP_STATE_NEG:FRP_STATE_POS;
   if(step%7==0)begin
    phase_load_valid=1;
    for(int i=0;i<CELLS;i++)begin
     phase_load[i*32+:32]=32'(i*32'h13a5f123+step*32'h019abcde);
     frequency_load_q16[i*32+:32]=32'(50000+step*130+i*71);
    end
   end
   clear_counters=step%5==0;accept_tick();
   if(logical_ticks!=step+1)$fatal(1,"logical tick count");
   repeat(step%3)cycle();
  end

  // A continuously asserted valid performs one tick on each ready edge.
  tick_valid=1;
  for(int t=0;t<5000&&logical_ticks<40;t++)cycle();
  tick_valid=0;
  if(logical_ticks!=40)$fatal(1,"held tick stream");
  repeat(3)cycle();
 end

 if(total_ticks!=120 || updates!=15 || blocked==0)$fatal(1,"coverage count");
 $display("PASS INTERNAL_GAMMA_FPGA_NETLIST cells=%0d outputs=114 ticks=%0d gamma_updates=%0d resets=%0d begin_transfers=%0d word_transfers=%0d phase_transfers=%0d blocked=%0d cycles=%0d",CELLS,total_ticks,updates,resets,begin_transfers,word_transfers,phase_transfers,blocked,cycles);
 $finish;
end

initial begin #10000000;$fatal(1,"watchdog");end

endmodule

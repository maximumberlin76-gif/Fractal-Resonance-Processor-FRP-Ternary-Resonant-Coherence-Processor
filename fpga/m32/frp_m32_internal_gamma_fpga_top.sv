// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FPGA boundary for the M32 core with internal gamma and local thermal feedback.
// Profiles: 8/16/32/64 cells. All inputs except rst_n_async are synchronous to clk.
// Include paths: rtl/m31, rtl/m32, fpga/m32.
//
// Assert rst_n_async low at startup. Reset assertion is asynchronous; release
// passes through two clk registers. core_ready rises after the second release
// edge; the first operation can be sampled on the following rising edge.
// core_ready indicates reset release. gamma_configured indicates a complete
// accepted checkpoint. tick_ready additionally accounts for gamma-bank stalls.
//
// All accepted outputs denote rising-edge handshakes, not registered pulses.
// Controls entirely within reset release are discarded. A held control is
// presented after release; payload must remain stable until its accepted edge.
// No operation queue or clock gating is inserted at this boundary.
//
// checkpoint_load_begin/checkpoint_begin_ready starts or restarts loading and
// samples checkpoint_index (0..624). It aborts any prefetched gamma bank and
// blocks tick and phase-load acceptance on that edge. Then transfer exactly
// 624 words through checkpoint_load_valid/checkpoint_load_ready, in order.
// checkpoint_begin_accepted and checkpoint_word_accepted expose these transfers.
// A held load_begin restarts loading at every accepted edge; deassert it before
// sending words. Load stalls retain progress; invalid checkpoints set the error.
// Restore the Python PRNG checkpoint taken after processor initialization.
//
// tick_valid/tick_ready advances one logical tick per accepted edge. Hold the
// tick controls and payload stable while waiting. Gamma updates occur on logical
// ticks 0, 8, 16, ...; waiting physical clocks do not advance this cadence.
// phase_load_valid/phase_load_ready accepts a phase-only load when tick_valid=0,
// including before gamma configuration. With tick_valid=1 it joins that tick.
// Counter clear retains the core's independent control semantics and histories.
// Checkpoint reload retains core histories and gamma cadence; reset clears them.
//
// All core outputs are forwarded directly. Local gamma and thermal feedback are
// enabled inside the composition. A pending stability sample can retire while
// tick_ready is low. SIN_LUT_FILE is passed unchanged to the phase engine.

`ifndef FRP_M32_INTERNAL_GAMMA_FPGA_TOP_SV
`define FRP_M32_INTERNAL_GAMMA_FPGA_TOP_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_core.sv"

module frp_m32_internal_gamma_fpga_top #(
  parameter int CELLS = 8,
  parameter int REQUEST_LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
  parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
  parameter int COUNTER_BITS = frp_m31_pkg::FRP_M31_COUNTER_BITS,
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input logic clk,
  input logic rst_n_async,
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
  output wire [(CELLS*32)-1:0] phase_word_q,
  output wire [(CELLS*32)-1:0] frequency_current_q16,
  output wire [(CELLS*32)-1:0] coupling_field_q16,
  output wire [(CELLS*32)-1:0] phase_projection_q30,
  output wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_target_source,
  output wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] registered_target_q,
  output wire registered_target_valid_q,
  output wire phase_target_domain_valid,
  output wire registered_target_domain_valid,
  output wire target_capture_accepted,
  output wire target_capture_rejected,
  output wire [COUNTER_BITS-1:0] accepted_target_capture_events_q,
  output wire [COUNTER_BITS-1:0] rejected_target_capture_events_q,
  output wire registered_request_enable,
  output wire [REQUEST_LANES-1:0] phase_request_valid,
  output wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] phase_request_cell_index,
  output wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] phase_request_target,
  output wire [REQUEST_LANES-1:0] execution_request_valid,
  output wire [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ] execution_request_cell_index,
  output wire [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_request_target,
  output wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] execution_target_bank,
  output wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] state_out,
  output wire [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ] pending_route_out,
  output frp_m31_pkg::frp_m31_scheduler_mode_e scheduler_mode_q,
  output frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state_q,
  output wire [COUNTER_BITS-1:0] ticks_recorded_q,
  output wire [COUNTER_BITS-1:0] scheduler_count_free_q,
  output wire [COUNTER_BITS-1:0] scheduler_count_balance_q,
  output wire [COUNTER_BITS-1:0] scheduler_count_commit_q,
  output wire [COUNTER_BITS-1:0] scheduler_count_excite_q,
  output wire [COUNTER_BITS-1:0] scheduler_count_neutralize_q,
  output wire [REQUEST_LANES-1:0] request_accept,
  output wire [REQUEST_LANES-1:0] request_reject,
  output wire [CELLS-1:0] accepted_cell_mask,
  output wire [CELLS-1:0] neutral_routed_cell_mask,
  output wire [CELLS-1:0] accepted_change_mask,
  output wire [COUNTER_BITS-1:0] accepted_changes,
  output wire [COUNTER_BITS-1:0] capacity_remaining,
  output wire capacity_exhausted,
  output wire [COUNTER_BITS-1:0] switch_load_numerator,
  output wire [COUNTER_BITS-1:0] requested_direct_events,
  output wire [COUNTER_BITS-1:0] prevented_direct_events,
  output wire [COUNTER_BITS-1:0] neutral_routed_events,
  output wire [COUNTER_BITS-1:0] actual_direct_events,
  output wire [COUNTER_BITS-1:0] reserved_state_events,
  output wire [COUNTER_BITS-1:0] queue_overflow_events,
  output wire [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ] invariant_flags,
  output wire signed [31:0] pair_coherence_q30,
  output wire signed [31:0] cluster_coherence_q30,
  output wire signed [31:0] global_coherence_q30,
  output wire signed [31:0] organization_dispersion_q30,
  output wire signed [31:0] normalized_cycle_cost_q16,
  output wire signed [31:0] temperature_proxy_q16,
  output wire signed [31:0] peak_temperature_proxy_q16,
  output wire [31:0] thermal_sample_count_q,
  output wire signed [31:0] coherence_capacity_q16,
  output wire signed [31:0] pressure_q16,
  output wire signed [31:0] stability_margin_q16,
  output wire stable,
  output wire [(CELLS*32)-1:0] local_heat_q16,
  output wire [(CELLS*32)-1:0] local_heat_peak_q16,
  output wire [(CELLS*32)-1:0] local_generated_power_q16,
  output wire [(CELLS*32)-1:0] local_thermal_dissipation_q16,
  output wire [(CELLS*32)-1:0] local_thermal_diffusion_q16,
  output wire [(CELLS*32)-1:0] local_thermal_overload_q16,
  output wire [(CELLS*32)-1:0] local_next_heat_q16,
  output wire [(CELLS*32)-1:0] local_next_overload_q16,
  output wire [(CELLS*32)-1:0] local_frequency_lag_q16,
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
  output wire local_stability_valid_q,
  output wire [31:0] local_stability_sample_count_q,
  output wire signed [31:0] local_stability_raw_coherence_q30,
  output wire signed [31:0] local_stability_cluster_coherence_q30,
  output wire signed [31:0] local_stability_mean_heat_q16,
  output wire signed [31:0] local_stability_mean_overload_q16,
  output wire signed [31:0] local_stability_mean_lag_q16,
  output wire signed [31:0] local_stability_neutral_fraction_q30,
  output wire signed [31:0] local_stability_compression_arg_q16,
  output wire signed [31:0] local_stability_switch_load_q16,
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
  output wire [2:0] gamma_tick_phase_q,
  output wire core_ready,
  output wire checkpoint_begin_ready,
  output wire checkpoint_begin_accepted,
  output wire checkpoint_word_accepted
);
  (* ASYNC_REG = "TRUE" *) logic [1:0] reset_sync_q;
  wire rst_n_core;

`ifndef SYNTHESIS
  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Internal-gamma FPGA top requires 8, 16, 32 or 64 cells");
    if (REQUEST_LANES != frp_m31_pkg::frp_calc_request_lanes(CELLS))
      $fatal(1, "Internal-gamma FPGA top request-lane count mismatch");
    if (CELL_INDEX_BITS != ((CELLS <= 1) ? 1 : $clog2(CELLS)))
      $fatal(1, "Internal-gamma FPGA top cell-index width mismatch");
    if (COUNTER_BITS < 1)
      $fatal(1, "Internal-gamma FPGA top requires COUNTER_BITS >= 1");
  end
`endif

  // Only the second stage drives reset consumers and control qualification.
  always_ff @(posedge clk or negedge rst_n_async) begin
    if (!rst_n_async)
      reset_sync_q <= 2'b00;
    else
      reset_sync_q <= {reset_sync_q[0], 1'b1};
  end

  assign rst_n_core = reset_sync_q[1];
  assign core_ready = rst_n_core;
  assign checkpoint_begin_ready = core_ready;
  assign checkpoint_begin_accepted = checkpoint_load_begin && checkpoint_begin_ready;
  assign checkpoint_word_accepted = checkpoint_load_valid && checkpoint_load_ready;

  frp_m32_internal_gamma_core #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS),
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_internal_gamma_core (
    .rst_n(rst_n_core),
    .tick_valid(tick_valid && core_ready),
    .clear_counters(clear_counters && core_ready),
    .phase_load_valid(phase_load_valid && core_ready),
    .auto_target_enable(auto_target_enable && core_ready),
    .external_request_valid(external_request_valid & {REQUEST_LANES{core_ready}}),
    .checkpoint_load_begin(checkpoint_begin_accepted),
    .checkpoint_load_valid(checkpoint_load_valid && core_ready),
    .*
  );
endmodule : frp_m32_internal_gamma_fpga_top
`endif

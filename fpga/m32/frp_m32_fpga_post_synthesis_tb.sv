// SPDX-License-Identifier: Apache-2.0
// FRP M32 deterministic post-synthesis FPGA testbench.
//
// Scope: the flattened eight-cell, two-request-lane FPGA netlist.
// Prepare the simulation netlist from the synthesized JSON in Yosys:
//   read_json netlist-run-1.json
//   techmap -map +/techmap.v t:$shiftx
//   opt_clean
//   check -assert
//   select -assert-none t:$shiftx t:$connect
//   rename frp_m32_fpga_top frp_m32_fpga_netlist
//   write_verilog -noattr frp_m32_fpga_netlist.v
//
// Mapping $shiftx before export gives explicit selection logic for signed
// indices in the simulation netlist. This avoids the indexed part-select
// mismatch reproduced with Verilator 5.020 on the unmapped export.
// The original synthesis JSON is the input; its file remains unchanged.
// Compile the generated Verilog module together with this testbench and
// the simlib.v cell models from the same Yosys package used for synthesis.
// Use --timing --assert and -DSIMLIB_NOCONNECT with Verilator 5.020;
// the export check above requires that the design contains no $connect.
// The distinct DUT module name requires the generated netlist input.
//
// All 59 synthesized core outputs are compared with a separate RTL
// frp_m32_core instance. Reference reset release follows scenario
// expectations independently of the synthesized reset synchronizer.
// The five escaped control names refer to preserved flattened netlist
// wires; they are observed only and do not drive the reference.
// Direct checks cover reset latency, startup control blocking, phase-load
// priority, registered-target capture, retained active zero and pending
// polarity, scheduler counts, pause, and counter clear.
// Both 7/1 and 1/7 modes are exercised alongside free execution.
//
// Run from the repository root with include directories rtl/m31 and
// rtl/m32; select frp_m32_fpga_post_synthesis_tb as the simulation top.
// The reference reads the canonical rtl/m31/frp_m31_sin_q30.mem file;
// the synthesized DUT uses the initialization embedded in its netlist.

`ifndef FRP_M32_FPGA_POST_SYNTHESIS_TB_SV
`define FRP_M32_FPGA_POST_SYNTHESIS_TB_SV

`timescale 1ns / 1ps
`include "frp_m32_core.sv"

module frp_m32_fpga_post_synthesis_tb;
  import frp_m31_pkg::*;
  import frp_m31_fixed_point_pkg::*;
  localparam int CELLS = 8;
  localparam int STATE_BITS = FRP_M31_STATE_BITS;
  localparam int REQUEST_LANES = 2;
  localparam int CELL_INDEX_BITS = 3;
  localparam int COUNTER_BITS = 32;
  logic clk;
  logic rst_n_async;
  logic tick_enable;
  logic clear_counters;
  frp_m31_scheduler_mode_e scheduler_mode;
  logic phase_load_valid;
  logic [(CELLS*32)-1:0] phase_load;
  logic [(CELLS*32)-1:0] frequency_load_q16;
  logic [(CELLS*32)-1:0] gamma_effective_word;
  logic [(CELLS*32)-1:0] thermal_node_factor_q30;
  logic auto_target_enable;
  logic [REQUEST_LANES-1:0] external_request_valid;
  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] external_request_cell_index;
  logic [(REQUEST_LANES*STATE_BITS)-1:0] external_request_target;
  logic [(CELLS*STATE_BITS)-1:0] external_target_bank;
  logic core_ready;
  logic reference_rst_n;
  typedef struct packed {
    logic [(CELLS*32)-1:0] phase_word_q;
    logic [(CELLS*32)-1:0] frequency_current_q16;
    logic [(CELLS*32)-1:0] coupling_field_q16;
    logic [(CELLS*32)-1:0] phase_projection_q30;
    logic [(CELLS*STATE_BITS)-1:0] phase_target_source;
    logic [(CELLS*STATE_BITS)-1:0] registered_target_q;
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
    logic [(REQUEST_LANES*STATE_BITS)-1:0] phase_request_target;
    logic [REQUEST_LANES-1:0] execution_request_valid;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] execution_request_cell_index;
    logic [(REQUEST_LANES*STATE_BITS)-1:0] execution_request_target;
    logic [(CELLS*STATE_BITS)-1:0] execution_target_bank;
    logic [(CELLS*STATE_BITS)-1:0] state_out;
    logic [(CELLS*STATE_BITS)-1:0] pending_route_out;
    frp_m31_scheduler_mode_e scheduler_mode_q;
    frp_m31_scheduler_state_e scheduler_state_q;
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
    logic [FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;
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
  } outputs_t;
  outputs_t actual, expected;
  logic [(CELLS*FRP_M31_STATE_BITS)-1:0] previous_state;
  logic [(CELLS*STATE_BITS)-1:0] source_before_edge;
  logic [STATE_BITS-1:0] route_target;
  outputs_t retained_snapshot;
  int samples = 0;
  bit initialized = 1'b0;

  initial begin
    #100000;
    $fatal(1, "FRP M32 FPGA post-synthesis TB timeout");
  end

  frp_m32_fpga_netlist dut (
    .clk(clk),
    .rst_n_async(rst_n_async),
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
    .state_out(actual.state_out),
    .pending_route_out(actual.pending_route_out),
    .scheduler_mode_q(actual.scheduler_mode_q),
    .scheduler_state_q(actual.scheduler_state_q),
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
    .actual_direct_events(actual.actual_direct_events),
    .reserved_state_events(actual.reserved_state_events),
    .queue_overflow_events(actual.queue_overflow_events),
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
    .core_ready(core_ready)
  );

  frp_m32_core #(
    .CELLS(CELLS),
    .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS)
  ) reference_core (
    .clk(clk),
    .rst_n(reference_rst_n),
    .tick_enable(tick_enable && reference_rst_n),
    .clear_counters(clear_counters && reference_rst_n),
    .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid && reference_rst_n),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(auto_target_enable && reference_rst_n),
    .external_request_valid(external_request_valid & {REQUEST_LANES{reference_rst_n}}),
    .external_request_cell_index(external_request_cell_index),
    .external_request_target(external_request_target),
    .external_target_bank(external_target_bank),
    .phase_word_q(expected.phase_word_q),
    .frequency_current_q16(expected.frequency_current_q16),
    .coupling_field_q16(expected.coupling_field_q16),
    .phase_projection_q30(expected.phase_projection_q30),
    .phase_target_source(expected.phase_target_source),
    .registered_target_q(expected.registered_target_q),
    .registered_target_valid_q(expected.registered_target_valid_q),
    .phase_target_domain_valid(expected.phase_target_domain_valid),
    .registered_target_domain_valid(expected.registered_target_domain_valid),
    .target_capture_accepted(expected.target_capture_accepted),
    .target_capture_rejected(expected.target_capture_rejected),
    .accepted_target_capture_events_q(expected.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(expected.rejected_target_capture_events_q),
    .registered_request_enable(expected.registered_request_enable),
    .phase_request_valid(expected.phase_request_valid),
    .phase_request_cell_index(expected.phase_request_cell_index),
    .phase_request_target(expected.phase_request_target),
    .execution_request_valid(expected.execution_request_valid),
    .execution_request_cell_index(expected.execution_request_cell_index),
    .execution_request_target(expected.execution_request_target),
    .execution_target_bank(expected.execution_target_bank),
    .state_out(expected.state_out),
    .pending_route_out(expected.pending_route_out),
    .scheduler_mode_q(expected.scheduler_mode_q),
    .scheduler_state_q(expected.scheduler_state_q),
    .ticks_recorded_q(expected.ticks_recorded_q),
    .scheduler_count_free_q(expected.scheduler_count_free_q),
    .scheduler_count_balance_q(expected.scheduler_count_balance_q),
    .scheduler_count_commit_q(expected.scheduler_count_commit_q),
    .scheduler_count_excite_q(expected.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(expected.scheduler_count_neutralize_q),
    .request_accept(expected.request_accept),
    .request_reject(expected.request_reject),
    .accepted_cell_mask(expected.accepted_cell_mask),
    .neutral_routed_cell_mask(expected.neutral_routed_cell_mask),
    .accepted_change_mask(expected.accepted_change_mask),
    .accepted_changes(expected.accepted_changes),
    .capacity_remaining(expected.capacity_remaining),
    .capacity_exhausted(expected.capacity_exhausted),
    .switch_load_numerator(expected.switch_load_numerator),
    .requested_direct_events(expected.requested_direct_events),
    .prevented_direct_events(expected.prevented_direct_events),
    .neutral_routed_events(expected.neutral_routed_events),
    .actual_direct_events(expected.actual_direct_events),
    .reserved_state_events(expected.reserved_state_events),
    .queue_overflow_events(expected.queue_overflow_events),
    .invariant_flags(expected.invariant_flags),
    .pair_coherence_q30(expected.pair_coherence_q30),
    .cluster_coherence_q30(expected.cluster_coherence_q30),
    .global_coherence_q30(expected.global_coherence_q30),
    .organization_dispersion_q30(expected.organization_dispersion_q30),
    .normalized_cycle_cost_q16(expected.normalized_cycle_cost_q16),
    .temperature_proxy_q16(expected.temperature_proxy_q16),
    .peak_temperature_proxy_q16(expected.peak_temperature_proxy_q16),
    .thermal_sample_count_q(expected.thermal_sample_count_q),
    .coherence_capacity_q16(expected.coherence_capacity_q16),
    .pressure_q16(expected.pressure_q16),
    .stability_margin_q16(expected.stability_margin_q16),
    .stable(expected.stable)
  );

  task automatic check_outputs;
    if (core_ready !== reference_rst_n)
      $fatal(1, "Readiness changed outside its expected release edge");
    if ($isunknown(actual) || $isunknown(expected))
      $fatal(1, "Unknown core output at sample %0d", samples);
    if (actual.phase_word_q !== expected.phase_word_q)
      $fatal(1, "Output mismatch: phase_word_q at sample %0d", samples);
    if (actual.frequency_current_q16 !== expected.frequency_current_q16)
      $fatal(1, "Output mismatch: frequency_current_q16 at sample %0d", samples);
    if (actual.coupling_field_q16 !== expected.coupling_field_q16)
      $fatal(1, "Output mismatch: coupling_field_q16 at sample %0d", samples);
    if (actual.phase_projection_q30 !== expected.phase_projection_q30)
      $fatal(1, "Output mismatch: phase_projection_q30 at sample %0d", samples);
    if (actual.phase_target_source !== expected.phase_target_source)
      $fatal(1, "Output mismatch: phase_target_source at sample %0d", samples);
    if (actual.registered_target_q !== expected.registered_target_q)
      $fatal(1, "Output mismatch: registered_target_q at sample %0d", samples);
    if (actual.registered_target_valid_q !== expected.registered_target_valid_q)
      $fatal(1, "Output mismatch: registered_target_valid_q at sample %0d", samples);
    if (actual.phase_target_domain_valid !== expected.phase_target_domain_valid)
      $fatal(1, "Output mismatch: phase_target_domain_valid at sample %0d", samples);
    if (actual.registered_target_domain_valid !== expected.registered_target_domain_valid)
      $fatal(1, "Output mismatch: registered_target_domain_valid at sample %0d", samples);
    if (actual.target_capture_accepted !== expected.target_capture_accepted)
      $fatal(1, "Output mismatch: target_capture_accepted at sample %0d", samples);
    if (actual.target_capture_rejected !== expected.target_capture_rejected)
      $fatal(1, "Output mismatch: target_capture_rejected at sample %0d", samples);
    if (actual.accepted_target_capture_events_q !== expected.accepted_target_capture_events_q)
      $fatal(1, "Output mismatch: accepted_target_capture_events_q at sample %0d", samples);
    if (actual.rejected_target_capture_events_q !== expected.rejected_target_capture_events_q)
      $fatal(1, "Output mismatch: rejected_target_capture_events_q at sample %0d", samples);
    if (actual.registered_request_enable !== expected.registered_request_enable)
      $fatal(1, "Output mismatch: registered_request_enable at sample %0d", samples);
    if (actual.phase_request_valid !== expected.phase_request_valid)
      $fatal(1, "Output mismatch: phase_request_valid at sample %0d", samples);
    if (actual.phase_request_cell_index !== expected.phase_request_cell_index)
      $fatal(1, "Output mismatch: phase_request_cell_index at sample %0d", samples);
    if (actual.phase_request_target !== expected.phase_request_target)
      $fatal(1, "Output mismatch: phase_request_target at sample %0d", samples);
    if (actual.execution_request_valid !== expected.execution_request_valid)
      $fatal(1, "Output mismatch: execution_request_valid at sample %0d", samples);
    if (actual.execution_request_cell_index !== expected.execution_request_cell_index)
      $fatal(1, "Output mismatch: execution_request_cell_index at sample %0d", samples);
    if (actual.execution_request_target !== expected.execution_request_target)
      $fatal(1, "Output mismatch: execution_request_target at sample %0d", samples);
    if (actual.execution_target_bank !== expected.execution_target_bank)
      $fatal(1, "Output mismatch: execution_target_bank at sample %0d", samples);
    if (actual.state_out !== expected.state_out)
      $fatal(1, "Output mismatch: state_out at sample %0d", samples);
    if (actual.pending_route_out !== expected.pending_route_out)
      $fatal(1, "Output mismatch: pending_route_out at sample %0d", samples);
    if (actual.scheduler_mode_q !== expected.scheduler_mode_q)
      $fatal(1, "Output mismatch: scheduler_mode_q at sample %0d", samples);
    if (actual.scheduler_state_q !== expected.scheduler_state_q)
      $fatal(1, "Output mismatch: scheduler_state_q at sample %0d", samples);
    if (actual.ticks_recorded_q !== expected.ticks_recorded_q)
      $fatal(1, "Output mismatch: ticks_recorded_q at sample %0d", samples);
    if (actual.scheduler_count_free_q !== expected.scheduler_count_free_q)
      $fatal(1, "Output mismatch: scheduler_count_free_q at sample %0d", samples);
    if (actual.scheduler_count_balance_q !== expected.scheduler_count_balance_q)
      $fatal(1, "Output mismatch: scheduler_count_balance_q at sample %0d", samples);
    if (actual.scheduler_count_commit_q !== expected.scheduler_count_commit_q)
      $fatal(1, "Output mismatch: scheduler_count_commit_q at sample %0d", samples);
    if (actual.scheduler_count_excite_q !== expected.scheduler_count_excite_q)
      $fatal(1, "Output mismatch: scheduler_count_excite_q at sample %0d", samples);
    if (actual.scheduler_count_neutralize_q !== expected.scheduler_count_neutralize_q)
      $fatal(1, "Output mismatch: scheduler_count_neutralize_q at sample %0d", samples);
    if (actual.request_accept !== expected.request_accept)
      $fatal(1, "Output mismatch: request_accept at sample %0d", samples);
    if (actual.request_reject !== expected.request_reject)
      $fatal(1, "Output mismatch: request_reject at sample %0d", samples);
    if (actual.accepted_cell_mask !== expected.accepted_cell_mask)
      $fatal(1, "Output mismatch: accepted_cell_mask at sample %0d", samples);
    if (actual.neutral_routed_cell_mask !== expected.neutral_routed_cell_mask)
      $fatal(1, "Output mismatch: neutral_routed_cell_mask at sample %0d", samples);
    if (actual.accepted_change_mask !== expected.accepted_change_mask)
      $fatal(1, "Output mismatch: accepted_change_mask at sample %0d", samples);
    if (actual.accepted_changes !== expected.accepted_changes)
      $fatal(1, "Output mismatch: accepted_changes at sample %0d", samples);
    if (actual.capacity_remaining !== expected.capacity_remaining)
      $fatal(1, "Output mismatch: capacity_remaining at sample %0d", samples);
    if (actual.capacity_exhausted !== expected.capacity_exhausted)
      $fatal(1, "Output mismatch: capacity_exhausted at sample %0d", samples);
    if (actual.switch_load_numerator !== expected.switch_load_numerator)
      $fatal(1, "Output mismatch: switch_load_numerator at sample %0d", samples);
    if (actual.requested_direct_events !== expected.requested_direct_events)
      $fatal(1, "Output mismatch: requested_direct_events at sample %0d", samples);
    if (actual.prevented_direct_events !== expected.prevented_direct_events)
      $fatal(1, "Output mismatch: prevented_direct_events at sample %0d", samples);
    if (actual.neutral_routed_events !== expected.neutral_routed_events)
      $fatal(1, "Output mismatch: neutral_routed_events at sample %0d", samples);
    if (actual.actual_direct_events !== expected.actual_direct_events)
      $fatal(1, "Output mismatch: actual_direct_events at sample %0d", samples);
    if (actual.reserved_state_events !== expected.reserved_state_events)
      $fatal(1, "Output mismatch: reserved_state_events at sample %0d", samples);
    if (actual.queue_overflow_events !== expected.queue_overflow_events)
      $fatal(1, "Output mismatch: queue_overflow_events at sample %0d", samples);
    if (actual.invariant_flags !== expected.invariant_flags)
      $fatal(1, "Output mismatch: invariant_flags at sample %0d", samples);
    if (actual.pair_coherence_q30 !== expected.pair_coherence_q30)
      $fatal(1, "Output mismatch: pair_coherence_q30 at sample %0d", samples);
    if (actual.cluster_coherence_q30 !== expected.cluster_coherence_q30)
      $fatal(1, "Output mismatch: cluster_coherence_q30 at sample %0d", samples);
    if (actual.global_coherence_q30 !== expected.global_coherence_q30)
      $fatal(1, "Output mismatch: global_coherence_q30 at sample %0d", samples);
    if (actual.organization_dispersion_q30 !== expected.organization_dispersion_q30)
      $fatal(1, "Output mismatch: organization_dispersion_q30 at sample %0d", samples);
    if (actual.normalized_cycle_cost_q16 !== expected.normalized_cycle_cost_q16)
      $fatal(1, "Output mismatch: normalized_cycle_cost_q16 at sample %0d", samples);
    if (actual.temperature_proxy_q16 !== expected.temperature_proxy_q16)
      $fatal(1, "Output mismatch: temperature_proxy_q16 at sample %0d", samples);
    if (actual.peak_temperature_proxy_q16 !== expected.peak_temperature_proxy_q16)
      $fatal(1, "Output mismatch: peak_temperature_proxy_q16 at sample %0d", samples);
    if (actual.thermal_sample_count_q !== expected.thermal_sample_count_q)
      $fatal(1, "Output mismatch: thermal_sample_count_q at sample %0d", samples);
    if (actual.coherence_capacity_q16 !== expected.coherence_capacity_q16)
      $fatal(1, "Output mismatch: coherence_capacity_q16 at sample %0d", samples);
    if (actual.pressure_q16 !== expected.pressure_q16)
      $fatal(1, "Output mismatch: pressure_q16 at sample %0d", samples);
    if (actual.stability_margin_q16 !== expected.stability_margin_q16)
      $fatal(1, "Output mismatch: stability_margin_q16 at sample %0d", samples);
    if (actual.stable !== expected.stable)
      $fatal(1, "Output mismatch: stable at sample %0d", samples);
    for (int cell_index = 0; cell_index < CELLS; cell_index++) begin
      if (actual.state_out[2*cell_index +: 2] == FRP_STATE_RESERVED)
        $fatal(1, "Reserved state at sample %0d", samples);
      if (((previous_state[2*cell_index +: 2] == FRP_STATE_POS)
           && (actual.state_out[2*cell_index +: 2] == FRP_STATE_NEG))
          || ((previous_state[2*cell_index +: 2] == FRP_STATE_NEG)
              && (actual.state_out[2*cell_index +: 2] == FRP_STATE_POS)))
        $fatal(1, "Direct polarity transition at sample %0d", samples);
    end
    previous_state = actual.state_out;
    if (actual.actual_direct_events !== '0
        || actual.reserved_state_events !== '0
        || actual.queue_overflow_events !== '0)
      $fatal(1, "Architectural error counter at sample %0d", samples);
    if (!core_ready) begin
      if (dut.\u_m32_core.tick_enable  !== 1'b0
          || dut.\u_m32_core.clear_counters  !== 1'b0
          || dut.\u_m32_core.phase_load_valid  !== 1'b0
          || dut.\u_m32_core.auto_target_enable  !== 1'b0
          || dut.\u_m32_core.external_request_valid  !== '0)
        $fatal(1, "Control escaped reset qualification");
      if (actual.execution_request_valid || actual.phase_request_valid
          || actual.target_capture_accepted || actual.target_capture_rejected)
        $fatal(1, "Request or capture visible before readiness");
    end
    samples++;
  endtask

  task automatic check_counters_zero;
    if ({actual.ticks_recorded_q,
         actual.scheduler_count_free_q,
         actual.scheduler_count_balance_q,
         actual.scheduler_count_commit_q,
         actual.scheduler_count_excite_q,
         actual.scheduler_count_neutralize_q,
         actual.accepted_target_capture_events_q,
         actual.rejected_target_capture_events_q,
         actual.thermal_sample_count_q} !== '0)
      $fatal(1, "Event counters did not clear");
  endtask

  task automatic check_retained_words;
    if (actual.state_out !== retained_snapshot.state_out
        || actual.pending_route_out !== retained_snapshot.pending_route_out
        || actual.registered_target_q !== retained_snapshot.registered_target_q
        || actual.registered_target_valid_q
           !== retained_snapshot.registered_target_valid_q
        || actual.phase_word_q !== retained_snapshot.phase_word_q
        || actual.frequency_current_q16
           !== retained_snapshot.frequency_current_q16
        || actual.scheduler_mode_q !== retained_snapshot.scheduler_mode_q
        || actual.scheduler_state_q !== retained_snapshot.scheduler_state_q)
      $fatal(1, "Retained data changed during pause or counter clear");
  endtask

  task automatic check_mode_counts(input int mode_index);
    if (actual.ticks_recorded_q !== 32'd97
        || actual.accepted_target_capture_events_q !== 32'd97)
      $fatal(1, "Tick/capture count mismatch in mode %0d", mode_index);
    case (mode_index)
      0: if (actual.scheduler_count_free_q !== 32'd97
             || actual.scheduler_count_balance_q !== '0
             || actual.scheduler_count_commit_q !== '0
             || actual.scheduler_count_excite_q !== '0
             || actual.scheduler_count_neutralize_q !== '0)
           $fatal(1, "Free scheduler counts mismatch");
      1: if (actual.scheduler_count_free_q !== 32'd1
             || actual.scheduler_count_balance_q !== 32'd84
             || actual.scheduler_count_commit_q !== 32'd12
             || actual.scheduler_count_excite_q !== '0
             || actual.scheduler_count_neutralize_q !== '0)
           $fatal(1, "7/1 scheduler counts mismatch");
      2: if (actual.scheduler_count_free_q !== 32'd1
             || actual.scheduler_count_balance_q !== '0
             || actual.scheduler_count_commit_q !== '0
             || actual.scheduler_count_excite_q !== 32'd12
             || actual.scheduler_count_neutralize_q !== 32'd84)
           $fatal(1, "1/7 scheduler counts mismatch");
      default: $fatal(1, "Unexpected test mode");
    endcase
    // The first tick executes the reset scheduler state FREE. The next
    // 96 ticks cover twelve complete periods of the selected mode.
  endtask

  task automatic check_reset_values;
    check_counters_zero();
    if (actual.state_out != '0 || actual.pending_route_out != '0
        || actual.registered_target_q != '0
        || actual.registered_target_valid_q
        || actual.ticks_recorded_q
        || actual.accepted_target_capture_events_q
        || actual.rejected_target_capture_events_q
        || actual.thermal_sample_count_q)
      $fatal(1, "Reset state/counters differ from canonical defaults");
    for (int cell_index = 0; cell_index < CELLS; cell_index++) begin
      if (actual.phase_word_q[32*cell_index +: 32]
          !== (cell_index * 32'h20000000))
        $fatal(1, "Phase changed during reset or release");
      if (actual.frequency_current_q16[32*cell_index +: 32]
          !== FRP_M31_BASE_FREQUENCY_Q16)
        $fatal(1, "Frequency changed during reset or release");
    end
  endtask

  // The expected release edge is supplied by each scenario, independently
  // of the DUT synchronizer. No internal DUT signal drives the reference.
  task automatic cycle(input bit expected_ready);
    #4;
    if (initialized)
      check_outputs();
    clk = 1'b1;
    #1;
    if (core_ready !== expected_ready)
      $fatal(1, "Wrong ready latency, expected %0b", expected_ready);
    reference_rst_n = expected_ready;
    #1;
    check_outputs();
    initialized = 1'b1;
    #4;
    clk = 1'b0;
    #1;
    check_outputs();
  endtask

  task automatic assert_reset;
    // No clock edge occurs in this task.
    #1;
    rst_n_async = 1'b0;
    reference_rst_n = 1'b0;
    #1;
    if (core_ready !== 1'b0)
      $fatal(1, "Reset assertion waited for a clock edge");
    check_outputs();
    check_reset_values();
  endtask

  task automatic release_reset;
    rst_n_async = 1'b1;
    #1;
    if (core_ready !== 1'b0)
      $fatal(1, "Asynchronous reset release");
    cycle(1'b0);
    check_reset_values();
    cycle(1'b1);
    check_reset_values();
  endtask

  initial begin
    clk = 1'b0;
    rst_n_async = 1'b0;
    reference_rst_n = 1'b0;
    previous_state = '0;
    tick_enable = 1'b1;
    clear_counters = 1'b1;
    phase_load_valid = 1'b1;
    scheduler_mode = FRP_MODE_FREE;
    auto_target_enable = 1'b1;
    external_request_valid = '1;
    external_request_cell_index = {3'd1, 3'd0};
    external_request_target = {FRP_STATE_NEG, FRP_STATE_POS};
    external_target_bank = {CELLS{FRP_STATE_POS}};
    phase_load = '0;
    frequency_load_q16 = '0;
    gamma_effective_word = '0;
    thermal_node_factor_q30 = '0;
    for (int cell_index = 0; cell_index < CELLS; cell_index++) begin
      phase_load[32*cell_index +: 32] =
        32'h10000000 + cell_index * 32'h08000000;
      frequency_load_q16[32*cell_index +: 32] =
        FRP_M31_BASE_FREQUENCY_Q16 + 100 + cell_index;
      gamma_effective_word[32*cell_index +: 32] = FRP_M31_GAMMA_NOMINAL;
      thermal_node_factor_q30[32*cell_index +: 32] = FRP_M31_Q30_ONE;
    end

    // Establish startup reset on a clock edge in the two-state simulator.
    // Subsequent reset pulses are checked before any further clock edge.
    #1;
    cycle(1'b0);
    check_reset_values();
    cycle(1'b0);
    // Pulses ending before readiness must never be replayed.
    rst_n_async = 1'b1;
    cycle(1'b0);
    tick_enable = 1'b0;
    clear_counters = 1'b0;
    phase_load_valid = 1'b0;
    auto_target_enable = 1'b0;
    external_request_valid = '0;
    cycle(1'b1);
    cycle(1'b1);
    check_reset_values();

    // Phase loading is legal independently of tick_enable after readiness.
    phase_load_valid = 1'b1;
    cycle(1'b1);
    if (actual.phase_word_q !== phase_load
        || actual.frequency_current_q16 !== frequency_load_q16
        || actual.ticks_recorded_q || actual.thermal_sample_count_q
        || actual.accepted_target_capture_events_q)
      $fatal(1, "Phase-load operation was lost or produced an execution tick");
    phase_load_valid = 1'b0;

    $display("PASS: startup pulses discarded; phase load without tick");

    // Exercise both mandatory polarity routes through a retained active
    // zero. Disable ticks while each pending polarity remains stored.
    tick_enable = 1'b1;
    external_request_valid = 2'b01;
    external_request_cell_index = '0;
    external_request_target = {FRP_STATE_ZERO, FRP_STATE_POS};
    external_target_bank = '0;
    external_target_bank[0 +: STATE_BITS] = FRP_STATE_POS;
    cycle(1'b1);
    if (actual.state_out[0 +: STATE_BITS] !== FRP_STATE_POS)
      $fatal(1, "External positive request was not executed");
    for (int route_index = 0; route_index < 2; route_index++) begin
      route_target = route_index == 0 ? FRP_STATE_NEG : FRP_STATE_POS;
      external_request_target[0 +: STATE_BITS] = route_target;
      external_target_bank[0 +: STATE_BITS] = route_target;
      tick_enable = 1'b1;
      cycle(1'b1);
      if (actual.state_out[0 +: STATE_BITS] !== FRP_ACTIVE_NEUTRAL
          || actual.pending_route_out[0 +: STATE_BITS] !== route_target)
        $fatal(1, "Opposite request did not enter active zero with pending target");
      tick_enable = 1'b0;
      external_request_valid = '0;
      retained_snapshot = actual;
      repeat (3) begin
        cycle(1'b1);
        check_retained_words();
      end
      tick_enable = 1'b1;
      cycle(1'b1);
      if (actual.state_out[0 +: STATE_BITS] !== route_target
          || actual.pending_route_out[0 +: STATE_BITS] !== FRP_ACTIVE_NEUTRAL)
        $fatal(1, "Pending route failed to complete without a new request");
      external_request_valid = 2'b01;
    end
    $display("PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause");

    // Interrupt release after its first rising edge. The next release
    // must again require two complete rising edges.
    tick_enable = 1'b1;
    phase_load_valid = 1'b1;
    auto_target_enable = 1'b1;
    external_request_valid = '1;
    assert_reset();
    rst_n_async = 1'b1;
    cycle(1'b0);
    assert_reset();
    release_reset();
    $display("PASS: reset reassertion restarts both release stages");

    for (int mode_index = 0; mode_index < 3; mode_index++) begin
      scheduler_mode = frp_m31_scheduler_mode_e'(mode_index);
      tick_enable = 1'b1;
      phase_load_valid = 1'b1;
      auto_target_enable = 1'b1;
      external_request_valid = '1;
      // A short reset pulse entirely between clock edges must restart both
      // release stages, even when every operation source is active.
      assert_reset();
      release_reset();
      source_before_edge = actual.phase_target_source;
      cycle(1'b1);
      if (actual.registered_target_q !== source_before_edge
          || actual.state_out !== {CELLS{FRP_ACTIVE_NEUTRAL}})
        $fatal(1, "First capture bypassed the registered-target boundary");
      if (actual.phase_word_q !== phase_load
          || actual.frequency_current_q16 !== frequency_load_q16
          || actual.ticks_recorded_q != 1
          || actual.accepted_target_capture_events_q != 1)
        $fatal(1, "Held control did not reach the first active edge");
      phase_load_valid = 1'b0;

      for (int tick_index = 0; tick_index < 96; tick_index++) begin
        auto_target_enable = (tick_index % 12) < 6;
        external_request_valid = (tick_index % 5) == 0 ? 2'b01 : 2'b11;
        external_request_cell_index =
          {3'((tick_index + 1) % CELLS), 3'(tick_index % CELLS)};
        external_request_target = (tick_index % 2) == 0
          ? {FRP_STATE_POS, FRP_STATE_NEG}
          : {FRP_STATE_NEG, FRP_STATE_POS};
        for (int cell_index = 0; cell_index < CELLS; cell_index++) begin
          gamma_effective_word[32*cell_index +: 32] =
            FRP_M31_GAMMA_NOMINAL
            + ((tick_index + cell_index) % 9) * 32'h01000000;
          thermal_node_factor_q30[32*cell_index +: 32] =
            FRP_M31_Q30_ONE
            - ((tick_index + cell_index) % 8) * 32'h02000000;
          external_target_bank[2*cell_index +: 2] =
            ((tick_index + cell_index) % 3) == 0
              ? FRP_STATE_ZERO
              : ((tick_index + cell_index) % 2) == 0
                ? FRP_STATE_POS : FRP_STATE_NEG;
        end
        cycle(1'b1);
      end
      check_mode_counts(mode_index);
      if (actual.scheduler_mode_q !== scheduler_mode)
        $fatal(1, "Scheduler mode not forwarded");

      // Pause preserves retained state, phase, frequency, and target bank.
      tick_enable = 1'b0;
      retained_snapshot = actual;
      repeat (4) begin
        cycle(1'b1);
        check_retained_words();
        check_mode_counts(mode_index);
        if (actual.thermal_sample_count_q
            !== retained_snapshot.thermal_sample_count_q)
          $fatal(1, "Thermal sampler advanced during pause");
      end

      clear_counters = 1'b1;
      cycle(1'b1);
      check_counters_zero();
      check_retained_words();

      // With clear and tick both asserted, the scheduler records one
      // tick; capture and thermal event counters retain clear priority.
      tick_enable = 1'b1;
      cycle(1'b1);
      if (actual.ticks_recorded_q !== 32'd1
          || actual.accepted_target_capture_events_q !== '0
          || actual.rejected_target_capture_events_q !== '0
          || actual.thermal_sample_count_q !== '0)
        $fatal(1, "Concurrent tick and counter clear priority mismatch");
      clear_counters = 1'b0;
      tick_enable = 1'b0;
      case (mode_index)
        0: $display("PASS: free, 97 ticks, pause, isolated and concurrent clear");
        1: $display("PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear");
        2: $display("PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear");
      endcase
    end
    assert_reset();
    release_reset();
    cycle(1'b1);
    check_reset_values();
    $display("PASS: 59 synthesized outputs match standalone M32 across %0d samples", samples);
    $display("FRP M32 FPGA post-synthesis testbench PASS");
    $finish;
  end
endmodule : frp_m32_fpga_post_synthesis_tb

`endif

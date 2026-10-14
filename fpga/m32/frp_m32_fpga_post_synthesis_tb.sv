// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Parameterized M32 FPGA post-synthesis comparison: 8, 16 or 32 cells.
// Build one netlist per CELLS value, rename its top frp_m32_fpga_netlist,
// and compile this top with the identical CELLS parameter override.
// The DUT is the generated netlist; the reference is canonical frp_m32_core.
// Compare all 103 core outputs before and after clock edges. Independently
// check reset release, active-zero routes, scheduler cadence, source selection,
// local history retention, gamma target capture and stability sample latency.
// Sources use ternary -1/0/+1 and scheduler free, 7/1 and 1/7.
// Map Yosys $shiftx with techmap.v before export, preserve the original JSON,
// require no $connect, and compile with the matching simlib.v plus
// -DSIMLIB_NOCONNECT --timing --assert and include paths rtl/m31 and rtl/m32.
// The six escaped DUT control wires are observations, not reference drivers.
// Run from the repository root for the canonical sine ROM used by the RTL.

`ifndef FRP_M32_FPGA_POST_SYNTHESIS_TB_SV
`define FRP_M32_FPGA_POST_SYNTHESIS_TB_SV
`timescale 1ns/1ps
`include "frp_m32_core.sv"

`define FRP_M32_PS_OUTPUTS(M) \
  `M(logic [(CELLS*32)-1:0], phase_word_q) \
  `M(logic [(CELLS*32)-1:0], frequency_current_q16) \
  `M(logic [(CELLS*32)-1:0], coupling_field_q16) \
  `M(logic [(CELLS*32)-1:0], phase_projection_q30) \
  `M(logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], phase_target_source) \
  `M(logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], registered_target_q) \
  `M(logic, registered_target_valid_q) \
  `M(logic, phase_target_domain_valid) \
  `M(logic, registered_target_domain_valid) \
  `M(logic, target_capture_accepted) \
  `M(logic, target_capture_rejected) \
  `M(logic [COUNTER_BITS-1:0], accepted_target_capture_events_q) \
  `M(logic [COUNTER_BITS-1:0], rejected_target_capture_events_q) \
  `M(logic, registered_request_enable) \
  `M(logic [REQUEST_LANES-1:0], phase_request_valid) \
  `M(logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ], phase_request_cell_index) \
  `M(logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], phase_request_target) \
  `M(logic [REQUEST_LANES-1:0], execution_request_valid) \
  `M(logic [ (REQUEST_LANES*CELL_INDEX_BITS)-1:0 ], execution_request_cell_index) \
  `M(logic [ (REQUEST_LANES*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], execution_request_target) \
  `M(logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], execution_target_bank) \
  `M(logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], state_out) \
  `M(logic [ (CELLS*frp_m31_pkg::FRP_M31_STATE_BITS)-1:0 ], pending_route_out) \
  `M(frp_m31_pkg::frp_m31_scheduler_mode_e, scheduler_mode_q) \
  `M(frp_m31_pkg::frp_m31_scheduler_state_e, scheduler_state_q) \
  `M(logic [COUNTER_BITS-1:0], ticks_recorded_q) \
  `M(logic [COUNTER_BITS-1:0], scheduler_count_free_q) \
  `M(logic [COUNTER_BITS-1:0], scheduler_count_balance_q) \
  `M(logic [COUNTER_BITS-1:0], scheduler_count_commit_q) \
  `M(logic [COUNTER_BITS-1:0], scheduler_count_excite_q) \
  `M(logic [COUNTER_BITS-1:0], scheduler_count_neutralize_q) \
  `M(logic [REQUEST_LANES-1:0], request_accept) \
  `M(logic [REQUEST_LANES-1:0], request_reject) \
  `M(logic [CELLS-1:0], accepted_cell_mask) \
  `M(logic [CELLS-1:0], neutral_routed_cell_mask) \
  `M(logic [CELLS-1:0], accepted_change_mask) \
  `M(logic [COUNTER_BITS-1:0], accepted_changes) \
  `M(logic [COUNTER_BITS-1:0], capacity_remaining) \
  `M(logic, capacity_exhausted) \
  `M(logic [COUNTER_BITS-1:0], switch_load_numerator) \
  `M(logic [COUNTER_BITS-1:0], requested_direct_events) \
  `M(logic [COUNTER_BITS-1:0], prevented_direct_events) \
  `M(logic [COUNTER_BITS-1:0], neutral_routed_events) \
  `M(logic [COUNTER_BITS-1:0], actual_direct_events) \
  `M(logic [COUNTER_BITS-1:0], reserved_state_events) \
  `M(logic [COUNTER_BITS-1:0], queue_overflow_events) \
  `M(logic [ frp_m31_pkg::FRP_M31_INVARIANT_FLAGS-1:0 ], invariant_flags) \
  `M(logic signed [31:0], pair_coherence_q30) \
  `M(logic signed [31:0], cluster_coherence_q30) \
  `M(logic signed [31:0], global_coherence_q30) \
  `M(logic signed [31:0], organization_dispersion_q30) \
  `M(logic signed [31:0], normalized_cycle_cost_q16) \
  `M(logic signed [31:0], temperature_proxy_q16) \
  `M(logic signed [31:0], peak_temperature_proxy_q16) \
  `M(logic [31:0], thermal_sample_count_q) \
  `M(logic signed [31:0], coherence_capacity_q16) \
  `M(logic signed [31:0], pressure_q16) \
  `M(logic signed [31:0], stability_margin_q16) \
  `M(logic, stable) \
  `M(logic [(CELLS*32)-1:0], local_heat_q16) \
  `M(logic [(CELLS*32)-1:0], local_heat_peak_q16) \
  `M(logic [(CELLS*32)-1:0], local_generated_power_q16) \
  `M(logic [(CELLS*32)-1:0], local_thermal_dissipation_q16) \
  `M(logic [(CELLS*32)-1:0], local_thermal_diffusion_q16) \
  `M(logic [(CELLS*32)-1:0], local_thermal_overload_q16) \
  `M(logic [(CELLS*32)-1:0], local_next_heat_q16) \
  `M(logic [(CELLS*32)-1:0], local_next_overload_q16) \
  `M(logic [(CELLS*32)-1:0], local_frequency_lag_q16) \
  `M(logic signed [31:0], local_mean_heat_q16) \
  `M(logic signed [31:0], local_mean_heat_peak_q16) \
  `M(logic signed [31:0], local_maximum_heat_peak_q16) \
  `M(logic [(CELLS*32)-1:0], local_gamma_noise_target_q16) \
  `M(logic [(CELLS*32)-1:0], local_gamma_noise_state_q16) \
  `M(logic [(CELLS*32)-1:0], local_gamma_drift_word) \
  `M(logic [(CELLS*32)-1:0], local_gamma_effective_word) \
  `M(logic [(CELLS*32)-1:0], local_next_gamma_drift_word) \
  `M(logic [(CELLS*32)-1:0], local_next_gamma_effective_word) \
  `M(logic [(CELLS*32)-1:0], phase_gamma_effective_word) \
  `M(logic [(CELLS*32)-1:0], local_thermal_node_factor_q30) \
  `M(logic [(CELLS*32)-1:0], local_next_thermal_node_factor_q30) \
  `M(logic [(CELLS*32)-1:0], phase_thermal_node_factor_q30) \
  `M(logic [((CELLS-1)*32)-1:0], group_coherence_q30) \
  `M(logic [($clog2(CELLS)*32)-1:0], level_mean_coherence_q30) \
  `M(logic [($clog2(CELLS)*32)-1:0], level_min_coherence_q30) \
  `M(logic [($clog2(CELLS)*32)-1:0], level_max_coherence_q30) \
  `M(logic [($clog2(CELLS)*32)-1:0], level_dispersion_q30) \
  `M(logic signed [31:0], local_coherence_compression_q30) \
  `M(logic signed [31:0], local_effective_coherence_q30) \
  `M(logic signed [31:0], local_coherence_capacity_q16) \
  `M(logic signed [31:0], local_pressure_q16) \
  `M(logic signed [31:0], local_stability_margin_q16) \
  `M(logic, local_stable) \
  `M(logic signed [31:0], local_previous_margin_q16) \
  `M(logic, local_stability_valid_q) \
  `M(logic [31:0], local_stability_sample_count_q) \
  `M(logic signed [31:0], local_stability_raw_coherence_q30) \
  `M(logic signed [31:0], local_stability_cluster_coherence_q30) \
  `M(logic signed [31:0], local_stability_mean_heat_q16) \
  `M(logic signed [31:0], local_stability_mean_overload_q16) \
  `M(logic signed [31:0], local_stability_mean_lag_q16) \
  `M(logic signed [31:0], local_stability_neutral_fraction_q30) \
  `M(logic signed [31:0], local_stability_compression_arg_q16) \
  `M(logic signed [31:0], local_stability_switch_load_q16)

module frp_m32_fpga_post_synthesis_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  import frp_m31_fixed_point_pkg::*;
  localparam int STATE_BITS = FRP_M31_STATE_BITS;
  localparam int REQUEST_LANES = frp_calc_request_lanes(CELLS);
  localparam int CELL_INDEX_BITS = $clog2(CELLS);
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
  logic local_gamma_enable, local_thermal_enable, gamma_update_valid;
  logic [CELLS*32-1:0] gamma_targets_q16;
`define FRP_PS_DECLARE(T,N) T N;
  typedef struct packed {
    `FRP_M32_PS_OUTPUTS(FRP_PS_DECLARE)
  } outputs_t;
`undef FRP_PS_DECLARE
  outputs_t actual, expected;
  logic [(CELLS*FRP_M31_STATE_BITS)-1:0] previous_state;
  logic [(CELLS*STATE_BITS)-1:0] source_before_edge;
  logic [STATE_BITS-1:0] route_target;
  outputs_t retained_snapshot;
  int samples = 0;
  bit initialized = 1'b0;

  initial begin
    #2000000;
    $fatal(1, "FRP M32 FPGA post-synthesis TB timeout");
  end

`define FRP_PS_ACTUAL(T,N) .N(actual.N),
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
    .local_gamma_enable(local_gamma_enable),
    .local_thermal_enable(local_thermal_enable),
    .gamma_update_valid(gamma_update_valid),
    .gamma_targets_q16(gamma_targets_q16),
    `FRP_M32_PS_OUTPUTS(FRP_PS_ACTUAL)
    .core_ready(core_ready)
  );

`undef FRP_PS_ACTUAL
`define FRP_PS_EXPECTED(T,N) .N(expected.N),
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
    .local_gamma_enable(local_gamma_enable),
    .local_thermal_enable(local_thermal_enable),
    .gamma_update_valid(gamma_update_valid && reference_rst_n),
    `FRP_M32_PS_OUTPUTS(FRP_PS_EXPECTED)
    .gamma_targets_q16(gamma_targets_q16)
  );
`undef FRP_PS_EXPECTED

`define FRP_PS_COMPARE(T,N) if (a.N !== e.N) return index; index++;
  function automatic int compare_outputs(input outputs_t a, e);
    /*verilator no_inline_task*/
    int index;
    index=0;
    `FRP_M32_PS_OUTPUTS(FRP_PS_COMPARE)
    return -1;
  endfunction
`undef FRP_PS_COMPARE
`define FRP_PS_NAME(T,N) if (index==k) return `"N`"; k++;
  function automatic string output_name(input int index);
    /*verilator no_inline_task*/
    int k;
    k=0;
    `FRP_M32_PS_OUTPUTS(FRP_PS_NAME)
    return "unknown";
  endfunction
`undef FRP_PS_NAME
  task automatic check_outputs;
    int mismatch;
    if (core_ready !== reference_rst_n)
      $fatal(1, "Readiness changed outside its expected release edge");
    if ($isunknown(actual) || $isunknown(expected))
      $fatal(1, "Unknown core output at sample %0d", samples);
    mismatch=compare_outputs(actual,expected);
    if (mismatch>=0)
      $fatal(1,"Output mismatch %s cells=%0d sample=%0d",output_name(mismatch),CELLS,samples);
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
          || dut.\u_m32_core.external_request_valid  !== '0
          || dut.\u_m32_core.gamma_update_valid  !== 1'b0)
        $fatal(1, "Control escaped reset qualification");
      if (actual.execution_request_valid || actual.phase_request_valid
          || actual.target_capture_accepted || actual.target_capture_rejected)
        $fatal(1, "Request or capture visible before readiness");
    end
    samples++;
  endtask

`undef FRP_PS_COMPARE

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
    if (actual.local_heat_q16!=={CELLS{32'sd3277}}
        || actual.local_gamma_noise_target_q16!='0
        || actual.local_gamma_noise_state_q16!='0
        || actual.local_thermal_node_factor_q30!=={CELLS{32'd1073741824}}
        || actual.local_stability_sample_count_q!=0 || actual.local_stability_valid_q)
      $fatal(1,"Local reset defaults mismatch");
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
          !== 32'(64'(cell_index) * (64'h100000000 / CELLS)))
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
    before_edge();
    clk = 1'b1;
    #1;
    if (core_ready !== expected_ready)
      $fatal(1, "Wrong ready latency, expected %0b", expected_ready);
    reference_rst_n = expected_ready;
    #1;
    after_edge();
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
    pending_model=0; stability_count_model=0; stability_valid_model=0;
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

  outputs_t before_sample;
  bit edge_active, edge_tick, edge_gamma_valid;
  bit pending_model=0, stability_valid_model=0;
  logic [31:0] stability_count_model=0;
  logic [CELLS*32-1:0] target_at_edge;
  int profiles=0, route_cases=0, random_steps=0;
  int gamma_accepts=0, gamma_holds=0, stability_drains=0, clear_retains=0;
  int nonzero_coupling=0, heated_samples=0, attenuation_samples=0;
  bit [3:0] selector_seen=0;
  int unsigned rng=32'h81f32a79;

  function automatic int unsigned random_word();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction

  task automatic before_edge;
    before_sample=actual;
    edge_active=reference_rst_n;
    edge_tick=tick_enable;
    edge_gamma_valid=gamma_update_valid;
    target_at_edge=gamma_targets_q16;
    if (!edge_active) begin
      pending_model=0; stability_valid_model=0; stability_count_model=0;
    end else begin
      stability_valid_model=pending_model;
      if (pending_model) begin
        stability_count_model++;
        if (!tick_enable) stability_drains++;
      end
      pending_model=tick_enable;
    end
  endtask

  task automatic after_edge;
    if (actual.local_stability_valid_q!==stability_valid_model
        || actual.local_stability_sample_count_q!==stability_count_model)
      $fatal(1,"Stability latency/count cells=%0d sample=%0d",CELLS,samples);
    if (edge_active) begin
      if (stability_valid_model
          && (actual.local_stability_raw_coherence_q30!==before_sample.global_coherence_q30
          || actual.local_stability_cluster_coherence_q30!==before_sample.cluster_coherence_q30))
        $fatal(1,"Stability did not capture the completed phase snapshot");
      if (edge_tick) begin
        if (actual.local_heat_q16!==before_sample.local_next_heat_q16
            || actual.local_gamma_drift_word!==before_sample.local_next_gamma_drift_word
            || actual.local_gamma_effective_word!==before_sample.local_next_gamma_effective_word
            || actual.local_thermal_node_factor_q30!==before_sample.local_next_thermal_node_factor_q30)
          $fatal(1,"Local candidate commit mismatch cells=%0d sample=%0d",CELLS,samples);
        if (edge_gamma_valid) begin
          if (actual.local_gamma_noise_target_q16!==target_at_edge)
            $fatal(1,"Gamma target update lost");
          gamma_accepts++;
        end else begin
          if (actual.local_gamma_noise_target_q16!==before_sample.local_gamma_noise_target_q16)
            $fatal(1,"Gamma target changed without update request");
          gamma_holds++;
        end
        selector_seen[{local_thermal_enable,local_gamma_enable}]=1;
        if (actual.coupling_field_q16!='0) nonzero_coupling++;
        if (actual.local_mean_heat_q16>3277) heated_samples++;
        if (actual.local_thermal_node_factor_q30!={CELLS{32'd1073741824}})
          attenuation_samples++;
      end else begin
        if (actual.local_heat_q16!==before_sample.local_heat_q16
            || actual.local_heat_peak_q16!==before_sample.local_heat_peak_q16
            || actual.local_mean_heat_peak_q16!==before_sample.local_mean_heat_peak_q16
            || actual.local_maximum_heat_peak_q16!==before_sample.local_maximum_heat_peak_q16
            || actual.local_gamma_noise_target_q16!==before_sample.local_gamma_noise_target_q16
            || actual.local_gamma_noise_state_q16!==before_sample.local_gamma_noise_state_q16
            || actual.local_gamma_drift_word!==before_sample.local_gamma_drift_word
            || actual.local_gamma_effective_word!==before_sample.local_gamma_effective_word
            || actual.local_thermal_node_factor_q30!==before_sample.local_thermal_node_factor_q30)
          $fatal(1,"Local history changed without tick");
        if (clear_counters) clear_retains++;
      end
    end
    if (actual.phase_gamma_effective_word !==
        (local_gamma_enable?actual.local_next_gamma_effective_word:gamma_effective_word)
        || actual.phase_thermal_node_factor_q30 !==
        (local_thermal_enable?actual.local_next_thermal_node_factor_q30:thermal_node_factor_q30))
      $fatal(1,"Local/external source selection mismatch");
  endtask

  task automatic extended_profiles;
    logic [1:0] desired;
    int unsigned word;
    // Exercise both polarity routes at every physical cell index, including
    // indexes above seven in the sixteen- and thirty-two-cell configurations.
    scheduler_mode=FRP_MODE_FREE; local_gamma_enable=1; local_thermal_enable=1;
    gamma_update_valid=0; phase_load_valid=0; clear_counters=0;
    tick_enable=0; auto_target_enable=0; external_request_valid='0;
    for (int c=0;c<CELLS;c++) begin
      assert_reset(); release_reset();
      external_request_cell_index='0;
      external_request_cell_index[0+:CELL_INDEX_BITS]=CELL_INDEX_BITS'(c);
      external_request_target='0;
      external_request_target[0+:STATE_BITS]=FRP_STATE_POS;
      external_target_bank='0;
      external_target_bank[c*STATE_BITS+:STATE_BITS]=FRP_STATE_POS;
      external_request_valid='0; external_request_valid[0]=1;
      tick_enable=1; cycle(1);
      if (actual.state_out[c*STATE_BITS+:STATE_BITS]!==FRP_STATE_POS)
        $fatal(1,"Indexed positive request failed cell=%0d",c);
      for (int polarity=0;polarity<2;polarity++) begin
        desired=(polarity==0)?FRP_STATE_NEG:FRP_STATE_POS;
        external_request_valid[0]=1;
        external_request_target[0+:STATE_BITS]=desired;
        external_target_bank[c*STATE_BITS+:STATE_BITS]=desired;
        tick_enable=1; cycle(1);
        if (actual.state_out[c*STATE_BITS+:STATE_BITS]!==FRP_ACTIVE_NEUTRAL
            || actual.pending_route_out[c*STATE_BITS+:STATE_BITS]!==desired)
          $fatal(1,"Indexed active-zero route failed cell=%0d",c);
        tick_enable=0; external_request_valid='0; retained_snapshot=actual;
        repeat(3) begin cycle(1); check_retained_words(); end
        clear_counters=1; cycle(1); check_retained_words(); check_counters_zero();
        clear_counters=0; tick_enable=1; cycle(1);
        if (actual.state_out[c*STATE_BITS+:STATE_BITS]!==desired
            || actual.pending_route_out[c*STATE_BITS+:STATE_BITS]!==FRP_ACTIVE_NEUTRAL)
          $fatal(1,"Indexed pending route failed cell=%0d",c);
        route_cases++;
      end
      tick_enable=0; external_request_valid='0;
    end
    $display("PASS: both active-zero routes at every cell index");

    // Three scheduler modes x four source selections x two request sources.
    // Each profile runs reproducible lane traffic, loads, pauses and clear.
    for (int mode=0;mode<3;mode++) begin
      for (int sources=0;sources<4;sources++) begin
        for (int automatic_requests=0;automatic_requests<2;automatic_requests++) begin
          tick_enable=0; clear_counters=0; phase_load_valid=0;
          external_request_valid='0; gamma_update_valid=1;
          scheduler_mode=frp_m31_scheduler_mode_e'(mode);
          local_gamma_enable=1'(sources%2); local_thermal_enable=1'(sources/2);
          auto_target_enable=1'(automatic_requests);
          gamma_targets_q16={CELLS{32'sd32768}};
          assert_reset(); release_reset();
          // A request held through release is accepted only on an enabled tick.
          cycle(1);
          if (actual.local_gamma_noise_target_q16!='0)
            $fatal(1,"Gamma target accepted while tick disabled");
          for (int c=0;c<CELLS;c++) begin
            phase_load[c*32+:32]=32'(64'(c)*(64'h100000000/CELLS));
            frequency_load_q16[c*32+:32]=(c%2==0)?32'sd0:32'sd1048576;
          end
          phase_load_valid=1; tick_enable=1; cycle(1); phase_load_valid=0;
          for (int iteration=0;iteration<128;iteration++) begin
            tick_enable=(iteration%9!=0);
            clear_counters=(iteration%31==0);
            phase_load_valid=(iteration%29==0);
            gamma_update_valid=(iteration%5==0);
            for (int c=0;c<CELLS;c++) begin
              word=random_word(); phase_load[c*32+:32]=word;
              frequency_load_q16[c*32+:32]=32'((word%2097153))-32'sd1048576;
              gamma_targets_q16[c*32+:32]=32'(random_word()%131073)-32'sd65536;
              gamma_effective_word[c*32+:32]=random_word();
              thermal_node_factor_q30[c*32+:32]=32'(random_word()%1073741825);
              external_target_bank[c*2+:2]=(c+iteration)%3==0?FRP_STATE_ZERO:
                ((c+iteration)%2==0?FRP_STATE_POS:FRP_STATE_NEG);
            end
            for (int lane=0;lane<REQUEST_LANES;lane++) begin
              external_request_valid[lane]=(iteration+lane)%4!=0;
              external_request_cell_index[lane*CELL_INDEX_BITS+:CELL_INDEX_BITS]=
                CELL_INDEX_BITS'((iteration+lane)%CELLS);
              external_request_target[lane*2+:2]=(iteration+lane)%3==0?FRP_STATE_ZERO:
                ((iteration+lane)%2==0?FRP_STATE_POS:FRP_STATE_NEG);
            end
            cycle(1); random_steps++;
          end
          tick_enable=0; phase_load_valid=0; gamma_update_valid=1;
          external_request_valid='0; clear_counters=0;
          // Drain the preceding snapshot before checking retained stability.
          cycle(1); cycle(1); retained_snapshot=actual;
          repeat(3) begin
            gamma_targets_q16=~gamma_targets_q16;
            clear_counters=1; cycle(1); check_retained_words();
            if (actual.local_stability_sample_count_q!==retained_snapshot.local_stability_sample_count_q
                || actual.local_stability_margin_q16!==retained_snapshot.local_stability_margin_q16)
              $fatal(1,"Counter clear changed drained stability history");
          end
          clear_counters=0; profiles++;
        end
      end
    end
    $display("PASS: 24 scheduler/thermal/gamma/request profiles and 3072 fixed-seed steps");
    tick_enable=0; phase_load_valid=0; gamma_update_valid=0;
    assert_reset(); release_reset(); cycle(1); check_reset_values();
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
    external_request_cell_index = '0;
    for (int lane=0;lane<REQUEST_LANES;lane++)
      external_request_cell_index[lane*CELL_INDEX_BITS+:CELL_INDEX_BITS]=CELL_INDEX_BITS'(lane);
    external_request_target = {REQUEST_LANES{FRP_STATE_POS}};
    external_target_bank = {CELLS{FRP_STATE_POS}};
    phase_load = '0;
    frequency_load_q16 = '0;
    gamma_effective_word = '0;
    thermal_node_factor_q30 = '0;
    local_gamma_enable=0; local_thermal_enable=0; gamma_update_valid=1;
    gamma_targets_q16={CELLS{32'sd16384}};
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
    gamma_update_valid=0;
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
    external_request_valid = {{(REQUEST_LANES-1){1'b0}},1'b1};
    external_request_cell_index = '0;
    external_request_target = '0;
    external_request_target[0+:STATE_BITS]=FRP_STATE_POS;
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
      external_request_valid = {{(REQUEST_LANES-1){1'b0}},1'b1};
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
        for (int lane=0;lane<REQUEST_LANES;lane++) begin
          external_request_valid[lane]=(tick_index%5!=0 || lane==0);
          external_request_cell_index[lane*CELL_INDEX_BITS+:CELL_INDEX_BITS]=
            CELL_INDEX_BITS'((tick_index+lane)%CELLS);
          external_request_target[lane*STATE_BITS+:STATE_BITS]=
            ((tick_index+lane)%2==0)?FRP_STATE_POS:FRP_STATE_NEG;
        end
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
    extended_profiles();
    if (profiles!=24 || route_cases!=2*CELLS || random_steps!=3072
        || selector_seen!=4'b1111 || !(gamma_accepts>0 && gamma_holds>0
        && stability_drains>0 && clear_retains>0 && nonzero_coupling>0
        && heated_samples>0 && attenuation_samples>0))
      $fatal(1,"Incomplete extended post-synthesis scenarios");
    $display("PASS M32_POST_SYNTH cells=%0d lanes=%0d outputs=103 samples=%0d profiles=%0d routes=%0d random=%0d",
      CELLS,REQUEST_LANES,samples,profiles,route_cases,random_steps);
    $display("M32_POST_SYNTH_EVENTS cells=%0d gamma_accepts=%0d gamma_holds=%0d stability_drains=%0d clear_retains=%0d coupling=%0d heated=%0d attenuated=%0d",
      CELLS,gamma_accepts,gamma_holds,stability_drains,clear_retains,nonzero_coupling,heated_samples,attenuation_samples);
    $display("FRP M32 FPGA post-synthesis testbench PASS");
    $finish;
  end
endmodule : frp_m32_fpga_post_synthesis_tb
`undef FRP_M32_PS_OUTPUTS

`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Complete M32 core: 103 public outputs after generic RTL synthesis.
// Runs the unchanged full-state oracle and all three stress/scaling tests.
// Includes local feedback, delayed stability history and all scheduler modes.
// Synthesize frp_m32_core separately for the selected CELLS; rename its exported
// module to frp_m32_core_netlist and compile it alongside this simulation top.
// Select this top explicitly; do not select the included standalone tops.
// This is functional netlist verification, without physical timing annotation.
`timescale 1ns/1ps
`include "frp_m32_stress_scaling_tb.sv"

module frp_m32_full_core_post_synthesis_tb #(parameter int CELLS=8);
  localparam int N=CELLS, L=N/4, I=$clog2(N), D=$clog2(N);

  typedef struct packed {
    logic [31:0] compression;
    logic [31:0] effective;
    logic [31:0] capacity;
    logic [31:0] pressure;
    logic [31:0] margin;
    logic stable;
    logic [31:0] previous;
    logic valid;
    logic [31:0] samples;
    logic [31:0] raw;
    logic [31:0] cluster;
    logic [31:0] heat;
    logic [31:0] overload;
    logic [31:0] lag;
    logic [31:0] neutral;
    logic [31:0] argument;
    logic [31:0] switching;
  } stability_t;

  typedef struct packed {
    stability_t stability;
    logic [N-1:0] accepted_cell_mask, accepted_change_mask, neutral_routed_cell_mask;
    logic [31:0] accepted_changes, accepted_target_capture_events_q, actual_direct_events;
    logic [31:0] capacity_remaining, cluster_coherence_q30, coherence_capacity_q16;
    logic [31:0] global_coherence_q30, neutral_routed_events, normalized_cycle_cost_q16;
    logic [31:0] organization_dispersion_q30, pair_coherence_q30, peak_temperature_proxy_q16;
    logic [31:0] pressure_q16, prevented_direct_events, queue_overflow_events;
    logic [31:0] rejected_target_capture_events_q, requested_direct_events, reserved_state_events;
    logic [31:0] scheduler_count_balance_q, scheduler_count_commit_q, scheduler_count_excite_q;
    logic [31:0] scheduler_count_free_q, scheduler_count_neutralize_q, stability_margin_q16;
    logic [31:0] switch_load_numerator, temperature_proxy_q16, thermal_sample_count_q;
    logic [31:0] ticks_recorded_q;
    logic capacity_exhausted, phase_target_domain_valid, registered_request_enable;
    logic registered_target_domain_valid, registered_target_valid_q, stable;
    logic target_capture_accepted, target_capture_rejected;
    logic [N*32-1:0] coupling_field_q16, frequency_current_q16, phase_projection_q30;
    logic [N*32-1:0] phase_word_q, local_heat_q16, local_heat_peak_q16;
    logic [N*32-1:0] local_generated_power_q16, local_thermal_dissipation_q16, local_thermal_diffusion_q16;
    logic [N*32-1:0] local_thermal_overload_q16, local_gamma_noise_target_q16, local_gamma_noise_state_q16;
    logic [N*32-1:0] local_gamma_drift_word, local_gamma_effective_word, local_thermal_node_factor_q30;
    logic [N*32-1:0] local_next_heat_q16, local_next_overload_q16, local_frequency_lag_q16;
    logic [N*32-1:0] local_next_gamma_drift_word, local_next_gamma_effective_word, phase_gamma_effective_word;
    logic [N*32-1:0] local_next_thermal_node_factor_q30, phase_thermal_node_factor_q30;
    logic [L*I-1:0] execution_request_cell_index, phase_request_cell_index;
    logic [L*2-1:0] execution_request_target, phase_request_target;
    logic [L-1:0] execution_request_valid, phase_request_valid, request_accept;
    logic [L-1:0] request_reject;
    logic [N*2-1:0] execution_target_bank, pending_route_out, phase_target_source;
    logic [N*2-1:0] registered_target_q, state_out;
    logic [9:0] invariant_flags;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [32-1:0] local_mean_heat_q16, local_mean_heat_peak_q16, local_maximum_heat_peak_q16;
    logic [(N-1)*32-1:0] group_coherence_q30;
    logic [D*32-1:0] level_mean_coherence_q30, level_min_coherence_q30, level_max_coherence_q30;
    logic [D*32-1:0] level_dispersion_q30;
  } observation_t;

  localparam int BITS=$bits(observation_t), WORDS=(BITS+31)/32;
  observation_t net_outputs;
  wire [BITS-1:0] rtl_outputs=reference_test.model.actual;
  longint unsigned samples=0, checks=0;
  longint unsigned reset_samples=0, enabled_samples=0, held_samples=0;
  longint unsigned source_samples[3][4]='{default:'{default:0}};
  longint unsigned signature=64'hcbf29ce484222325;
  bit mismatch_seen=0;

  frp_m32_stress_scaling_tb #(.CELLS(CELLS)) reference_test();

  frp_m32_core_netlist netlist(
    .auto_target_enable(reference_test.model.auto_target_enable),
    .clear_counters(reference_test.model.clear_counters),
    .clk(reference_test.model.clk),
    .external_request_cell_index(reference_test.model.external_request_cell_index),
    .external_request_target(reference_test.model.external_request_target),
    .external_request_valid(reference_test.model.external_request_valid),
    .external_target_bank(reference_test.model.external_target_bank),
    .frequency_load_q16(reference_test.model.frequency_load_q16),
    .gamma_effective_word(reference_test.model.gamma_effective_word),
    .phase_load(reference_test.model.phase_load),
    .phase_load_valid(reference_test.model.phase_load_valid),
    .rst_n(reference_test.model.rst_n),
    .scheduler_mode(reference_test.model.scheduler_mode),
    .thermal_node_factor_q30(reference_test.model.thermal_node_factor_q30),
    .tick_enable(reference_test.model.tick_enable),
    .local_gamma_enable(reference_test.model.local_gamma_enable),
    .local_thermal_enable(reference_test.model.local_thermal_enable),
    .gamma_update_valid(reference_test.model.gamma_update_valid),
    .gamma_targets_q16(reference_test.model.gamma_targets_q16),
    .accepted_cell_mask(net_outputs.accepted_cell_mask),
    .accepted_change_mask(net_outputs.accepted_change_mask),
    .accepted_changes(net_outputs.accepted_changes),
    .accepted_target_capture_events_q(net_outputs.accepted_target_capture_events_q),
    .actual_direct_events(net_outputs.actual_direct_events),
    .capacity_exhausted(net_outputs.capacity_exhausted),
    .capacity_remaining(net_outputs.capacity_remaining),
    .cluster_coherence_q30(net_outputs.cluster_coherence_q30),
    .coherence_capacity_q16(net_outputs.coherence_capacity_q16),
    .coupling_field_q16(net_outputs.coupling_field_q16),
    .execution_request_cell_index(net_outputs.execution_request_cell_index),
    .execution_request_target(net_outputs.execution_request_target),
    .execution_request_valid(net_outputs.execution_request_valid),
    .execution_target_bank(net_outputs.execution_target_bank),
    .frequency_current_q16(net_outputs.frequency_current_q16),
    .global_coherence_q30(net_outputs.global_coherence_q30),
    .invariant_flags(net_outputs.invariant_flags),
    .neutral_routed_cell_mask(net_outputs.neutral_routed_cell_mask),
    .neutral_routed_events(net_outputs.neutral_routed_events),
    .normalized_cycle_cost_q16(net_outputs.normalized_cycle_cost_q16),
    .organization_dispersion_q30(net_outputs.organization_dispersion_q30),
    .pair_coherence_q30(net_outputs.pair_coherence_q30),
    .peak_temperature_proxy_q16(net_outputs.peak_temperature_proxy_q16),
    .pending_route_out(net_outputs.pending_route_out),
    .phase_projection_q30(net_outputs.phase_projection_q30),
    .phase_request_cell_index(net_outputs.phase_request_cell_index),
    .phase_request_target(net_outputs.phase_request_target),
    .phase_request_valid(net_outputs.phase_request_valid),
    .phase_target_domain_valid(net_outputs.phase_target_domain_valid),
    .phase_target_source(net_outputs.phase_target_source),
    .phase_word_q(net_outputs.phase_word_q),
    .pressure_q16(net_outputs.pressure_q16),
    .prevented_direct_events(net_outputs.prevented_direct_events),
    .queue_overflow_events(net_outputs.queue_overflow_events),
    .registered_request_enable(net_outputs.registered_request_enable),
    .registered_target_domain_valid(net_outputs.registered_target_domain_valid),
    .registered_target_q(net_outputs.registered_target_q),
    .registered_target_valid_q(net_outputs.registered_target_valid_q),
    .rejected_target_capture_events_q(net_outputs.rejected_target_capture_events_q),
    .request_accept(net_outputs.request_accept),
    .request_reject(net_outputs.request_reject),
    .requested_direct_events(net_outputs.requested_direct_events),
    .reserved_state_events(net_outputs.reserved_state_events),
    .scheduler_count_balance_q(net_outputs.scheduler_count_balance_q),
    .scheduler_count_commit_q(net_outputs.scheduler_count_commit_q),
    .scheduler_count_excite_q(net_outputs.scheduler_count_excite_q),
    .scheduler_count_free_q(net_outputs.scheduler_count_free_q),
    .scheduler_count_neutralize_q(net_outputs.scheduler_count_neutralize_q),
    .scheduler_mode_q(net_outputs.scheduler_mode_q),
    .scheduler_state_q(net_outputs.scheduler_state_q),
    .stability_margin_q16(net_outputs.stability_margin_q16),
    .stable(net_outputs.stable),
    .state_out(net_outputs.state_out),
    .switch_load_numerator(net_outputs.switch_load_numerator),
    .target_capture_accepted(net_outputs.target_capture_accepted),
    .target_capture_rejected(net_outputs.target_capture_rejected),
    .temperature_proxy_q16(net_outputs.temperature_proxy_q16),
    .thermal_sample_count_q(net_outputs.thermal_sample_count_q),
    .ticks_recorded_q(net_outputs.ticks_recorded_q),
    .local_heat_q16(net_outputs.local_heat_q16),
    .local_heat_peak_q16(net_outputs.local_heat_peak_q16),
    .local_generated_power_q16(net_outputs.local_generated_power_q16),
    .local_thermal_dissipation_q16(net_outputs.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(net_outputs.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(net_outputs.local_thermal_overload_q16),
    .local_gamma_noise_target_q16(net_outputs.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(net_outputs.local_gamma_noise_state_q16),
    .local_gamma_drift_word(net_outputs.local_gamma_drift_word),
    .local_gamma_effective_word(net_outputs.local_gamma_effective_word),
    .local_thermal_node_factor_q30(net_outputs.local_thermal_node_factor_q30),
    .local_next_heat_q16(net_outputs.local_next_heat_q16),
    .local_next_overload_q16(net_outputs.local_next_overload_q16),
    .local_frequency_lag_q16(net_outputs.local_frequency_lag_q16),
    .local_next_gamma_drift_word(net_outputs.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(net_outputs.local_next_gamma_effective_word),
    .phase_gamma_effective_word(net_outputs.phase_gamma_effective_word),
    .local_next_thermal_node_factor_q30(net_outputs.local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(net_outputs.phase_thermal_node_factor_q30),
    .local_mean_heat_q16(net_outputs.local_mean_heat_q16),
    .local_mean_heat_peak_q16(net_outputs.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(net_outputs.local_maximum_heat_peak_q16),
    .group_coherence_q30(net_outputs.group_coherence_q30),
    .level_mean_coherence_q30(net_outputs.level_mean_coherence_q30),
    .level_min_coherence_q30(net_outputs.level_min_coherence_q30),
    .level_max_coherence_q30(net_outputs.level_max_coherence_q30),
    .level_dispersion_q30(net_outputs.level_dispersion_q30),
    .local_coherence_compression_q30(net_outputs.stability.compression),
    .local_effective_coherence_q30(net_outputs.stability.effective),
    .local_coherence_capacity_q16(net_outputs.stability.capacity),
    .local_pressure_q16(net_outputs.stability.pressure),
    .local_stability_margin_q16(net_outputs.stability.margin),
    .local_stable(net_outputs.stability.stable),
    .local_previous_margin_q16(net_outputs.stability.previous),
    .local_stability_valid_q(net_outputs.stability.valid),
    .local_stability_sample_count_q(net_outputs.stability.samples),
    .local_stability_raw_coherence_q30(net_outputs.stability.raw),
    .local_stability_cluster_coherence_q30(net_outputs.stability.cluster),
    .local_stability_mean_heat_q16(net_outputs.stability.heat),
    .local_stability_mean_overload_q16(net_outputs.stability.overload),
    .local_stability_mean_lag_q16(net_outputs.stability.lag),
    .local_stability_neutral_fraction_q30(net_outputs.stability.neutral),
    .local_stability_compression_arg_q16(net_outputs.stability.argument),
    .local_stability_switch_load_q16(net_outputs.stability.switching));

  task automatic compare_outputs();
    logic [WORDS*32-1:0] actual, expected;
    int mode, source;
    actual=(WORDS*32)'(net_outputs);
    expected=(WORDS*32)'(rtl_outputs);

    for(int w=0;w<WORDS;w++) begin
      if(actual[w*32+:32]!==expected[w*32+:32]) begin
        mismatch_seen=1;
        $fatal(1,"FULL_CORE_NETLIST cells=%0d sample=%0d time=%0t word=%0d net=%h rtl=%h",
          CELLS,samples,$time,w,actual[w*32+:32],expected[w*32+:32]);
      end
      checks++;
      signature=(signature^{32'b0,actual[w*32+:32]})*64'h100000001b3;
    end

    if(!reference_test.model.rst_n) reset_samples++;
    else if(reference_test.model.tick_enable) begin
      enabled_samples++;
      mode=int'(reference_test.model.scheduler_mode);
      source=int'(reference_test.model.local_gamma_enable)+
        2*int'(reference_test.model.local_thermal_enable);
      if(mode<0 || mode>2) $fatal(1,"Invalid scheduler mode");
      source_samples[mode][source]++;
    end else held_samples++;
    samples++;
  endtask

  initial begin
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    // The reference first asserts reset at 1 ns. Sampling between its integer
    // nanosecond events observes settled pre-edge, post-edge and held values.
    #1250ps;
    forever begin compare_outputs(); #1ns; end
  end

  // The unmodified campaign owns $finish. Require completion of its baseline,
  // sustained workload, reset storm and all six normalized scaling cases.
  final begin
    if(mismatch_seen) $fatal(1,"Earlier full-core netlist mismatch");

    if(!reference_test.baseline_done || reference_test.enabled_ticks!=24576 ||
       reference_test.paused_ticks!=88 || reference_test.reset_cases!=64 ||
       reference_test.scaling_cases!=6 || reference_test.saturation_edges!=280 ||
       reference_test.model.steps-reference_test.steps_start!=26339 ||
       reference_test.longest_run!=2048)
      $fatal(1,"Incomplete full-core reference campaign");

    foreach(reference_test.traffic_cross[m,s,a,k])
      if(reference_test.traffic_cross[m][s][a][k]==0)
        $fatal(1,"Missing reference traffic cross %0d/%0d/%0d/%0d",m,s,a,k);

    compare_outputs();

    if(samples!=longint'($realtime/1ns) || samples<100000 ||
       checks!=samples*64'(WORDS))
      $fatal(1,"Incomplete full-core sampling samples=%0d checks=%0d",samples,checks);

    if(reset_samples==0 || enabled_samples==0 || held_samples==0 ||
       reset_samples+enabled_samples+held_samples!=samples)
      $fatal(1,"Missing reset, enabled or held history");

    foreach(source_samples[m,s]) if(source_samples[m][s]==0)
      $fatal(1,"Missing synthesized feedback source cross mode=%0d source=%0d",m,s);

    $display("PASS FULL_CORE_NETLIST cells=%0d ports=103 bits=%0d words=%0d samples=%0d checks=%0d reset=%0d enabled=%0d held=%0d signature=%016h",
      CELLS,BITS,WORDS,samples,checks,reset_samples,enabled_samples,held_samples,signature);
    $display("PASS FULL_CORE_NETLIST_ALL cells=%0d tests=3 scaling_cases=6 source_cross=12 traffic_cross=96",CELLS);
  end
endmodule

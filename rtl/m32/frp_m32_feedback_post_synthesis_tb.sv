// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Gamma drift, thermal attenuation and global stability after synthesis.
// All 26 public outputs are compared with the unchanged snapshot regression.
// The original independent arithmetic oracles and stimulus guards remain active.
// Synthesize frp_m32_feedback_bundle with CELLS=8/16/32/64 and rename the
// exported module to frp_m32_feedback_bundle_netlist before simulation.
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"
`include "frp_m31_local_thermal_attenuation.sv"
`include "frp_m31_global_stability.sv"

module frp_m32_feedback_bundle #(parameter int CELLS=8)(
  input logic clk,
  input logic [2:0] reset_n, enabled,
  input logic gamma_update_valid,
  input logic [CELLS*32-1:0] gamma_targets_q16, thermal_overload_q16,
  input logic [CELLS*32-1:0] heat_q16, frequency_lag_q16,
  input logic [CELLS*2-1:0] retained_state,
  input logic signed [31:0] raw_phase_coherence_q30, cluster_coherence_q30,
  input logic signed [31:0] switch_load_q16,
  output wire [CELLS*192-1:0] gamma_outputs,
  output wire [CELLS*64-1:0] attenuation_outputs,
  output wire [575:0] stability_outputs
);
  typedef logic signed [31:0] word_t;
  wire [CELLS*32-1:0] gamma_noise_target_q16, gamma_noise_state_q16;
  wire [CELLS*32-1:0] gamma_drift_word, gamma_effective_word;
  wire [CELLS*32-1:0] next_gamma_drift_word, next_gamma_effective_word;
  wire [CELLS*32-1:0] thermal_node_factor_q30, next_thermal_node_factor_q30;
  word_t mean_heat_q16, mean_thermal_overload_q16, mean_frequency_lag_q16;
  word_t neutral_fraction_q30, compression_arg_q16;
  word_t next_coherence_compression_q30, next_effective_coherence_q30;
  word_t next_coherence_capacity_q16, next_pressure_q16, next_stability_margin_q16;
  wire next_stable;
  word_t coherence_compression_q30, effective_coherence_q30;
  word_t coherence_capacity_q16, pressure_q16, stability_margin_q16, previous_margin_q16;
  wire stable;

  frp_m31_local_gamma_drift #(.CELLS(CELLS)) gamma_dut(
    .clk, .rst_n(reset_n[0]), .tick_enable(enabled[0]), .gamma_update_valid,
    .gamma_targets_q16, .thermal_overload_q16, .gamma_noise_target_q16,
    .gamma_noise_state_q16, .gamma_drift_word, .gamma_effective_word,
    .next_gamma_drift_word, .next_gamma_effective_word);
  frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) attenuation_dut(
    .clk, .rst_n(reset_n[1]), .tick_enable(enabled[1]), .thermal_overload_q16,
    .thermal_node_factor_q30, .next_thermal_node_factor_q30);
  frp_m31_global_stability #(.CELLS(CELLS)) stability_dut(
    .clk, .rst_n(reset_n[2]), .tick_enable(enabled[2]), .retained_state,
    .raw_phase_coherence_q30, .cluster_coherence_q30, .heat_q16,
    .thermal_overload_q16, .frequency_lag_q16, .switch_load_q16,
    .mean_heat_q16, .mean_thermal_overload_q16, .mean_frequency_lag_q16,
    .neutral_fraction_q30, .compression_arg_q16, .next_coherence_compression_q30,
    .next_effective_coherence_q30, .next_coherence_capacity_q16, .next_pressure_q16,
    .next_stability_margin_q16, .next_stable, .coherence_compression_q30,
    .effective_coherence_q30, .coherence_capacity_q16, .pressure_q16,
    .stability_margin_q16, .stable, .previous_margin_q16);

  assign gamma_outputs={
    gamma_noise_target_q16,
    gamma_noise_state_q16,
    gamma_drift_word,
    gamma_effective_word,
    next_gamma_drift_word,
    next_gamma_effective_word};
  assign attenuation_outputs={
    thermal_node_factor_q30,
    next_thermal_node_factor_q30};
  assign stability_outputs={
    mean_heat_q16,
    mean_thermal_overload_q16,
    mean_frequency_lag_q16,
    neutral_fraction_q30,
    compression_arg_q16,
    next_coherence_compression_q30,
    next_effective_coherence_q30,
    next_coherence_capacity_q16,
    next_pressure_q16,
    next_stability_margin_q16,
    {31'b0,next_stable},
    coherence_compression_q30,
    effective_coherence_q30,
    coherence_capacity_q16,
    pressure_q16,
    stability_margin_q16,
    {31'b0,stable},
    previous_margin_q16};
endmodule

`ifndef SYNTHESIS
`include "frp_m32_feedback_snapshot_tb.sv"

module frp_m32_feedback_post_synthesis_tb #(parameter int CELLS=8);
  localparam int MAX_WORDS=6*CELLS;
  wire [CELLS*192-1:0] gamma_outputs, gamma_reference;
  wire [CELLS*64-1:0] attenuation_outputs, attenuation_reference;
  wire [575:0] stability_outputs, stability_reference;
  longint unsigned samples=0;
  longint unsigned checks[3]='{default:0};
  longint unsigned signatures[3]='{default:64'hcbf29ce484222325};
  longint unsigned reset_samples[3]='{default:0};
  longint unsigned enabled_samples[3]='{default:0};
  longint unsigned held_samples[3]='{default:0};
  bit mismatch_seen=0;

  frp_m32_feedback_snapshot_tb #(.CELLS(CELLS)) reference_test();
  frp_m32_feedback_bundle_netlist netlist(
    .clk(reference_test.clk),
    .reset_n(reference_test.reset_n),
    .enabled(reference_test.enabled),
    .gamma_update_valid(reference_test.gamma_update_valid),
    .gamma_targets_q16(reference_test.gamma_targets_q16),
    .thermal_overload_q16(reference_test.thermal_overload_q16),
    .heat_q16(reference_test.heat_q16),
    .frequency_lag_q16(reference_test.frequency_lag_q16),
    .retained_state(reference_test.retained_state),
    .raw_phase_coherence_q30(reference_test.raw_phase_coherence_q30),
    .cluster_coherence_q30(reference_test.cluster_coherence_q30),
    .switch_load_q16(reference_test.switch_load_q16),
    .gamma_outputs, .attenuation_outputs, .stability_outputs);

  assign gamma_reference={
    reference_test.gamma_noise_target_q16,
    reference_test.gamma_noise_state_q16,
    reference_test.gamma_drift_word,
    reference_test.gamma_effective_word,
    reference_test.next_gamma_drift_word,
    reference_test.next_gamma_effective_word};
  assign attenuation_reference={
    reference_test.thermal_node_factor_q30,
    reference_test.next_thermal_node_factor_q30};
  assign stability_reference={
    reference_test.mean_heat_q16,
    reference_test.mean_thermal_overload_q16,
    reference_test.mean_frequency_lag_q16,
    reference_test.neutral_fraction_q30,
    reference_test.compression_arg_q16,
    reference_test.next_coherence_compression_q30,
    reference_test.next_effective_coherence_q30,
    reference_test.next_coherence_capacity_q16,
    reference_test.next_pressure_q16,
    reference_test.next_stability_margin_q16,
    {31'b0,reference_test.next_stable},
    reference_test.coherence_compression_q30,
    reference_test.effective_coherence_q30,
    reference_test.coherence_capacity_q16,
    reference_test.pressure_q16,
    reference_test.stability_margin_q16,
    {31'b0,reference_test.stable},
    reference_test.previous_margin_q16};

  task automatic compare_outputs();
    logic [MAX_WORDS*32-1:0] actual, expected;
    int words;
    for(int t=0;t<3;t++) begin
      case(t)
        0: begin
          actual=(MAX_WORDS*32)'(gamma_outputs);
          expected=(MAX_WORDS*32)'(gamma_reference); words=6*CELLS;
        end
        1: begin
          actual=(MAX_WORDS*32)'(attenuation_outputs);
          expected=(MAX_WORDS*32)'(attenuation_reference); words=2*CELLS;
        end
        2: begin
          actual=(MAX_WORDS*32)'(stability_outputs);
          expected=(MAX_WORDS*32)'(stability_reference); words=18;
        end
        default: $fatal(1,"Unknown feedback comparison");
      endcase
      for(int w=0;w<words;w++) begin
        if(actual[w*32+:32]!==expected[w*32+:32]) begin
          mismatch_seen=1;
          $fatal(1,"FEEDBACK_NETLIST cells=%0d test=%0d sample=%0d word=%0d net=%h rtl=%h",
            CELLS,t,samples,w,actual[w*32+:32],expected[w*32+:32]);
        end
        checks[t]++;
        signatures[t]=(signatures[t]^{32'b0,actual[w*32+:32]})*64'h100000001b3;
      end
      if(!reference_test.reset_n[t]) reset_samples[t]++;
      else if(reference_test.enabled[t]) enabled_samples[t]++;
      else held_samples[t]++;
    end
    samples++;
  endtask

  initial begin
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    // The original test asserts its first reset at 1 ns.
    // Sample after settling, between its integer-nanosecond stimulus steps.
    #1250ps;
    forever begin compare_outputs(); #1ns; end
  end

  // The original test owns normal termination. Include its last settled probe
  // and require its complete workload before reporting netlist success.
  final begin
    if(mismatch_seen) $fatal(1,"Earlier feedback netlist mismatch");
    if(reference_test.probes!=44960 || reference_test.edges!=22214 ||
       reference_test.matrix_cases!=128 || reference_test.boundaries!=12285 ||
       reference_test.random_cases!=8192 || reference_test.event_seen!=8'hff)
      $fatal(1,"Incomplete reference workload at netlist termination");
    compare_outputs();
    if(samples!=89389) $fatal(1,"Incomplete netlist sampling: %0d",samples);
    for(int t=0;t<3;t++) begin
      if(reset_samples[t]==0 || enabled_samples[t]==0 || held_samples[t]==0 ||
         reset_samples[t]+enabled_samples[t]+held_samples[t]!=samples)
        $fatal(1,"Missing netlist history class test=%0d",t);
      if(checks[t]!=samples*((t==0)?64'(6*CELLS):(t==1)?64'(2*CELLS):64'd18))
        $fatal(1,"Incomplete feedback output comparisons test=%0d",t);
      $display("PASS FEEDBACK_NETLIST cells=%0d test=%0d ports=%0d samples=%0d checks=%0d reset=%0d enabled=%0d held=%0d signature=%016h",
        CELLS,t,(t==0)?6:(t==1)?2:18,samples,checks[t],
        reset_samples[t],enabled_samples[t],held_samples[t],signatures[t]);
    end
    $display("PASS FEEDBACK_NETLIST_ALL cells=%0d tests=3 ports=26",CELLS);
  end
endmodule
`endif

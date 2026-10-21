// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M31 fractal hierarchy: functional post-synthesis regression.
// Reuses the unchanged hierarchy campaign and its independent arithmetic oracle.
// Compile this file plus the separately synthesized, CELLS-specialized module
// frp_m31_phase_interference_netlist; do not compile the included TB separately.
// The eight-cell anchor remains RTL; the CELLS=8 matrix row qualifies that size.
// Use --timing --assert -Irtl/m31 and --flatten for CELLS=8.

`timescale 1ns/1ps
`include "frp_m31_fractal_hierarchy_tb.sv"

module frp_m31_fractal_hierarchy_post_synthesis_tb #(
  parameter int CELLS=8
)();
  import frp_m31_pkg::*;
  localparam int DEPTH=$clog2(CELLS);

  typedef struct packed {
    logic [CELLS*32-1:0] phase_word_q;
    logic [CELLS*32-1:0] frequency_current_q16;
    logic [CELLS*32-1:0] coupling_field_q16;
    logic [CELLS*32-1:0] phase_projection_q30;
    logic [CELLS*2-1:0] phase_target;
    logic [32-1:0] pair_coherence_q30;
    logic [32-1:0] cluster_coherence_q30;
    logic [32-1:0] global_coherence_q30;
    logic [32-1:0] organization_dispersion_q30;
    logic [(CELLS-1)*32-1:0] group_coherence_q30;
    logic [DEPTH*32-1:0] level_mean_coherence_q30;
    logic [DEPTH*32-1:0] level_min_coherence_q30;
    logic [DEPTH*32-1:0] level_max_coherence_q30;
    logic [DEPTH*32-1:0] level_dispersion_q30;
  } observation_t;

  localparam int BITS=$bits(observation_t);
  localparam int WORDS=(BITS+31)/32;
  localparam longint EXPECTED_SAMPLES=4382+228*CELLS;
  localparam longint EXPECTED_ENABLED=144*(CELLS+16);

  observation_t rtl_outputs, net_outputs;
  longint unsigned samples=0, checks=0;
  longint unsigned reset_samples=0, enabled_samples=0, held_samples=0;
  longint unsigned cadence_samples[5]='{default:0};
  logic [63:0] signature=64'hcbf29ce484222325;
  bit mismatch_seen=0;

  frp_m31_fractal_hierarchy_tb #(.CELLS(CELLS)) reference_test();

  assign rtl_outputs.phase_word_q=reference_test.subject.phase_word_q;
  assign rtl_outputs.frequency_current_q16=reference_test.subject.frequency_current_q16;
  assign rtl_outputs.coupling_field_q16=reference_test.subject.coupling_field_q16;
  assign rtl_outputs.phase_projection_q30=reference_test.subject.phase_projection_q30;
  assign rtl_outputs.phase_target=reference_test.subject.phase_target;
  assign rtl_outputs.pair_coherence_q30=reference_test.subject.pair_coherence_q30;
  assign rtl_outputs.cluster_coherence_q30=reference_test.subject.cluster_coherence_q30;
  assign rtl_outputs.global_coherence_q30=reference_test.subject.global_coherence_q30;
  assign rtl_outputs.organization_dispersion_q30=reference_test.subject.organization_dispersion_q30;
  assign rtl_outputs.group_coherence_q30=reference_test.subject.group_coherence_q30;
  assign rtl_outputs.level_mean_coherence_q30=reference_test.subject.level_mean_coherence_q30;
  assign rtl_outputs.level_min_coherence_q30=reference_test.subject.level_min_coherence_q30;
  assign rtl_outputs.level_max_coherence_q30=reference_test.subject.level_max_coherence_q30;
  assign rtl_outputs.level_dispersion_q30=reference_test.subject.level_dispersion_q30;

  frp_m31_phase_interference_netlist netlist(
    .clk(reference_test.subject.clk),
    .rst_n(reference_test.subject.rst_n),
    .tick_enable(reference_test.subject.tick_enable),
    .load_valid(reference_test.subject.load_valid),
    .phase_load(reference_test.subject.phase_load),
    .frequency_load_q16(reference_test.subject.frequency_load_q16),
    .gamma_effective_word(reference_test.subject.gamma_effective_word),
    .thermal_node_factor_q30(reference_test.subject.thermal_node_factor_q30),
    .retained_state(reference_test.subject.retained_state),
    .switch_activity(reference_test.subject.switch_activity),
    .scheduler_state(reference_test.subject.scheduler_state),
    .phase_word_q(net_outputs.phase_word_q),
    .frequency_current_q16(net_outputs.frequency_current_q16),
    .coupling_field_q16(net_outputs.coupling_field_q16),
    .phase_projection_q30(net_outputs.phase_projection_q30),
    .phase_target(net_outputs.phase_target),
    .pair_coherence_q30(net_outputs.pair_coherence_q30),
    .cluster_coherence_q30(net_outputs.cluster_coherence_q30),
    .global_coherence_q30(net_outputs.global_coherence_q30),
    .organization_dispersion_q30(net_outputs.organization_dispersion_q30),
    .group_coherence_q30(net_outputs.group_coherence_q30),
    .level_mean_coherence_q30(net_outputs.level_mean_coherence_q30),
    .level_min_coherence_q30(net_outputs.level_min_coherence_q30),
    .level_max_coherence_q30(net_outputs.level_max_coherence_q30),
    .level_dispersion_q30(net_outputs.level_dispersion_q30));

  task automatic compare_outputs();
    logic [WORDS*32-1:0] actual, expected;
    int state_id;

    // Zero extension includes every public output bit, including phase_target.
    actual=(WORDS*32)'(net_outputs);
    expected=(WORDS*32)'(rtl_outputs);

    for(int w=0;w<WORDS;w++) begin
      if(actual[w*32+:32]!==expected[w*32+:32]) begin
        mismatch_seen=1;
        $fatal(1,"HIERARCHY_NETLIST cells=%0d sample=%0d time=%0t word=%0d net=%h rtl=%h",
          CELLS,samples,$time,w,actual[w*32+:32],expected[w*32+:32]);
      end
      checks++;
      signature=(signature^{32'b0,actual[w*32+:32]})*64'h100000001b3;
    end

    if(!reference_test.subject.rst_n) reset_samples++;
    else if(reference_test.subject.tick_enable && !reference_test.subject.load_valid) begin
      enabled_samples++;
      state_id=int'(reference_test.subject.scheduler_state);
      if(state_id<0 || state_id>4) $fatal(1,"Invalid phase scheduler state");
      cadence_samples[state_id]++;
    end else held_samples++;

    // held_samples includes load intervals and time spent exercising the anchor.
    samples++;
  endtask

  initial begin
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    if(BITS!=162*CELLS+96+128*DEPTH) $fatal(1,"Output observation width");

    // Reset starts at time zero. Offset sampling observes settled pre-edge,
    // post-edge and held values between the reference's integer-ns events.
    #250ps;
    forever begin compare_outputs(); #1ns; end
  end

  // The unchanged reference owns $finish. Reject premature completion before
  // accepting the final netlist sample or printing the post-synthesis records.
  final begin
    if(mismatch_seen) $fatal(1,"Earlier hierarchy netlist mismatch");

    if(reference_test.swaps!=6*(CELLS-1) || reference_test.compositions!=96 ||
       reference_test.nested_cases!=8*(CELLS-1)+1 ||
       reference_test.scaling_cases!=128 || reference_test.hierarchy_breaks!=1 ||
       reference_test.trajectory_checks!=10*(6*(CELLS-1)+96) ||
       reference_test.subject.samples!=76*CELLS+1203 ||
       reference_test.anchor.samples!=256 || reference_test.subject.resets!=1 ||
       reference_test.anchor.resets!=1)
      $fatal(1,"Incomplete hierarchy reference campaign");

    compare_outputs();

    if(samples!=EXPECTED_SAMPLES || samples!=longint'($realtime/1ns)+1 ||
       checks!=samples*64'(WORDS))
      $fatal(1,"Incomplete hierarchy sampling samples=%0d checks=%0d",samples,checks);

    if(reset_samples!=1 || enabled_samples!=EXPECTED_ENABLED || held_samples==0 ||
       reset_samples+enabled_samples+held_samples!=samples)
      $fatal(1,"Incomplete reset, enabled or held history");

    if(cadence_samples[FRP_SCHED_FREE]!=48*(CELLS+16) ||
       cadence_samples[FRP_SCHED_BALANCE]!=42*(CELLS+16) ||
       cadence_samples[FRP_SCHED_COMMIT]!=6*(CELLS+16) ||
       cadence_samples[FRP_SCHED_EXCITE]!=6*(CELLS+16) ||
       cadence_samples[FRP_SCHED_NEUTRALIZE]!=42*(CELLS+16))
      $fatal(1,"Incomplete five-state phase cadence");

    $display("PASS HIERARCHY_NETLIST cells=%0d ports=14 bits=%0d words=%0d samples=%0d checks=%0d reset=%0d enabled=%0d held=%0d signature=%016h",
      CELLS,BITS,WORDS,samples,checks,reset_samples,enabled_samples,held_samples,signature);
    $display("PASS HIERARCHY_NETLIST_ALL cells=%0d tests=3 states=5 motifs=128 negative_controls=1",CELLS);
  end
endmodule

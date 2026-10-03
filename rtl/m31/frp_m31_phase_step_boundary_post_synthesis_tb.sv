// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 phase-step netlist versus the unchanged RTL workload. Author: Alchimist.
`ifndef FRP_M31_PHASE_STEP_BOUNDARY_POST_SYNTHESIS_TB_SV
`define FRP_M31_PHASE_STEP_BOUNDARY_POST_SYNTHESIS_TB_SV
`include "frp_m31_phase_step_boundary_tb.sv"

module frp_m31_phase_step_boundary_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m31_phase_step_boundary_tb_pkg::*;

  // Synthesize the eight-cell frp_m31_phase_interference with its packages
  // and sine ROM, retaining all 20 ports. In the synthesis copy only, remove
  // the four ROM simulation fatal guards; retain $readmemh and all functional
  // logic. All four guards remain active in the unchanged RTL reference.
  // Flatten and rename to frp_m31_phase_interference_netlist, then compile
  // with its cell simulation library, --timing, --assert and -Irtl/m31.
  // Keep rtl/m31/frp_m31_sin_q30.mem available from the simulation directory.
  // The reference's independent arithmetic, analytic sine, integer roots,
  // coverage checks, signatures, completion guard and watchdog stay active.
  // Observe each requested event after settling, before the reference's
  // 1 ps sample. Check its completed oracle sample on the following event;
  // check the last oracle sample in final. No driver changes are required.
  // This qualifies the declared finite phase-step workload on a generic
  // functional netlist. It does not establish scheduler cadence, full-core
  // reachability, exhaustive coverage, physical timing or model v0.9.3
  // equivalence. Reserved input codes are diagnostics; targets are not
  // executed ternary transitions. Thermal factors stay in [0, Q30 one].
  frp_m31_phase_step_boundary_tb reference_test();

  typedef struct packed {
    logic reset_n, tick, load;
    logic [255:0] phase_load, frequency_load, gamma, thermal;
    logic [15:0] retained;
    logic [7:0] activity;
    logic [2:0] scheduler;
  } stimulus_t;
  localparam int unsigned EXPECTED_COUNTS [0:4] = '{170, 1728, 98304, 7692, 5184};
  localparam int unsigned EXPECTED_EVENTS [0:4] = '{37688, 37688, 9, 9, 37684};
  localparam int unsigned EXPECTED_SCHEDULER [0:7] = '{3857, 3858, 3855, 3857, 3854, 168, 168, 168};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:4] = '{
    64'hc1c4ee441879b449, 64'h5a2098207a15f3d9, 64'hb43edecaecd9441b,
    64'ha6efa8b02a901d66, 64'h10edd9da06ef2aad
  };
  localparam logic [1053:0] EXPECTED_INPUT_MASK = {
    {515{1'b1}},
    256'hffffffe8fffffff7ffffffe6ffffffedfffffffcffffffe7fffffff2fffffffd,
    256'h3fffffe73fffffe37fffffff3ffffffb3ffffff77ffffff33fffffef3fffffeb,
    {27{1'b1}}
  };

  wire clock;
  wire stimulus_t inputs;
  wire outputs_t reference_outputs, netlist_outputs;
  assign clock = reference_test.dut.clk;
  assign inputs = '{reference_test.dut.rst_n, reference_test.dut.tick_enable,
                   reference_test.dut.load_valid, reference_test.dut.phase_load,
                   reference_test.dut.frequency_load_q16, reference_test.dut.gamma_effective_word,
                   reference_test.dut.thermal_node_factor_q30, reference_test.dut.retained_state,
                   reference_test.dut.switch_activity, reference_test.dut.scheduler_state};
  assign reference_outputs = '{reference_test.dut.phase_word_q,
                              reference_test.dut.frequency_current_q16,
                              reference_test.dut.coupling_field_q16,
                              reference_test.dut.phase_projection_q30,
                              reference_test.dut.phase_target,
                              reference_test.dut.pair_coherence_q30,
                              reference_test.dut.cluster_coherence_q30,
                              reference_test.dut.global_coherence_q30,
                              reference_test.dut.organization_dispersion_q30};

  frp_m31_phase_interference_netlist u_netlist (
    .clk(clock), .rst_n(inputs.reset_n), .tick_enable(inputs.tick), .load_valid(inputs.load),
    .phase_load(inputs.phase_load), .frequency_load_q16(inputs.frequency_load),
    .gamma_effective_word(inputs.gamma), .thermal_node_factor_q30(inputs.thermal),
    .retained_state(inputs.retained), .switch_activity(inputs.activity),
    .scheduler_state(inputs.scheduler),
    .phase_word_q(netlist_outputs.phase_bank),
    .frequency_current_q16(netlist_outputs.frequency_bank),
    .coupling_field_q16(netlist_outputs.coupling),
    .phase_projection_q30(netlist_outputs.projection),
    .phase_target(netlist_outputs.target),
    .pair_coherence_q30(netlist_outputs.pair_order),
    .cluster_coherence_q30(netlist_outputs.cluster_order),
    .global_coherence_q30(netlist_outputs.global_order),
    .organization_dispersion_q30(netlist_outputs.dispersion)
  );

  int unsigned comparisons = 0, field_checks = 0, completed_stages = 0;
  int unsigned loads = 0, ticks = 0, holds = 0, reset_updates = 0;
  int unsigned load_over_tick = 0, reset_low = 0, reset_high = 0;
  int unsigned stage_counts[5], event_counts[5], scheduler_counts[8];
  logic [63:0] stage_signatures[5];
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [1053:0] input_ones = '0, input_zeros = '0;
  logic [1167:0] output_ones = '0, output_zeros = '0;
  outputs_t previous_outputs = '0;
  logic previous_clock = 0, previous_reset = 1;
  bit mismatch_seen = 0;

  task automatic compare_word(input string field_name, input logic [255:0] actual, expected);
    field_checks++;
    if ($isunknown({actual, expected}) || actual !== expected) begin
      mismatch_seen = 1;
      $fatal(1, "Phase-step netlist mismatch observation=%0d field=%s actual=%h expected=%h stage=%0d",
             comparisons, field_name, actual, expected, completed_stages);
    end
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_sample(input int kind);
    if (kind < 0 || kind > 4 || completed_stages >= 5 || reference_test.done
        || !reference_test.sample_busy || reference_test.requested_kind != kind
        || reference_test.stage != completed_stages || reference_test.observations != comparisons
        || reference_test.checks != field_checks || field_checks != 9 * comparisons
        || reference_test.signature !== signature
        || reference_test.stage_counts[completed_stages] != stage_counts[completed_stages])
      $fatal(1, "Phase-step netlist sample alignment failed observation=%0d kind=%0d stage=%0d",
             comparisons, kind, completed_stages);
    if (comparisons != 0 && (previous_outputs !== reference_test.expected
        || output_ones !== reference_test.output_ones || output_zeros !== reference_test.output_zeros))
      $fatal(1, "Phase-step netlist preceding oracle sample mismatch observation=%0d", comparisons);
    if ($isunknown({clock, inputs, reference_outputs}) || clock !== reference_test.clk
        || inputs !== {reference_test.rst_n, reference_test.tick_enable, reference_test.load_valid,
                       reference_test.phase_load, reference_test.frequency_load_q16,
                       reference_test.gamma_effective_word, reference_test.thermal_node_factor_q30,
                       reference_test.retained_state, reference_test.switch_activity,
                       reference_test.scheduler_state}
        || reference_outputs !== reference_test.outputs)
      $fatal(1, "Unknown or mismatched phase-step netlist stimulus binding");
    if ((kind == 0 && (previous_clock !== 1'b1 || clock !== 1'b0))
        || (kind == 1 && (previous_clock !== 1'b0 || clock !== 1'b1))
        || (kind >= 2 && clock !== previous_clock)
        || (kind == 2 && (previous_reset !== 1'b1 || inputs.reset_n !== 1'b0))
        || (kind == 3 && (previous_reset !== 1'b0 || inputs.reset_n !== 1'b1))
        || ((kind == 0 || kind == 1 || kind == 4) && inputs.reset_n !== previous_reset))
      $fatal(1, "Phase-step netlist event edge mismatch observation=%0d kind=%0d", comparisons, kind);

    compare_word("phase", netlist_outputs.phase_bank, reference_outputs.phase_bank);
    compare_word("frequency", netlist_outputs.frequency_bank, reference_outputs.frequency_bank);
    compare_word("coupling", netlist_outputs.coupling, reference_outputs.coupling);
    compare_word("projection", netlist_outputs.projection, reference_outputs.projection);
    compare_word("target", 256'(netlist_outputs.target), 256'(reference_outputs.target));
    compare_word("pair", 256'(netlist_outputs.pair_order), 256'(reference_outputs.pair_order));
    compare_word("cluster", 256'(netlist_outputs.cluster_order), 256'(reference_outputs.cluster_order));
    compare_word("global", 256'(netlist_outputs.global_order), 256'(reference_outputs.global_order));
    compare_word("dispersion", 256'(netlist_outputs.dispersion), 256'(reference_outputs.dispersion));

    if (kind == 2 || (kind == 1 && !inputs.reset_n)) begin
      reset_updates++;
      if (kind == 2) begin if (clock) reset_high++; else reset_low++; end
    end else if (kind == 1 && inputs.load) begin
      loads++;
      if (inputs.tick) load_over_tick++;
    end else if (kind == 1 && inputs.tick) begin
      ticks++;
      scheduler_counts[inputs.scheduler]++;
    end else if (kind == 1) holds++;
    input_ones |= inputs; input_zeros |= ~inputs;
    output_ones |= netlist_outputs; output_zeros |= ~netlist_outputs;
    previous_outputs = netlist_outputs;
    previous_clock = clock; previous_reset = inputs.reset_n;

    // Same 73-word event/input/output order as the independent oracle digest.
    hash_word(completed_stages); hash_word(32'(kind));
    hash_word({25'b0, clock, inputs.reset_n, inputs.load, inputs.tick, inputs.scheduler});
    hash_word({8'b0, inputs.retained, inputs.activity});
    for (int i = 0; i < 8; i++) begin
      hash_word(inputs.phase_load[i*32 +: 32]); hash_word(inputs.frequency_load[i*32 +: 32]);
      hash_word(inputs.gamma[i*32 +: 32]); hash_word(inputs.thermal[i*32 +: 32]);
    end
    for (int i = 0; i < 8; i++) begin
      hash_word(netlist_outputs.phase_bank[i*32 +: 32]);
      hash_word(netlist_outputs.frequency_bank[i*32 +: 32]);
      hash_word(netlist_outputs.coupling[i*32 +: 32]);
      hash_word(netlist_outputs.projection[i*32 +: 32]);
    end
    hash_word({16'b0, netlist_outputs.target}); hash_word(netlist_outputs.pair_order);
    hash_word(netlist_outputs.cluster_order); hash_word(netlist_outputs.global_order);
    hash_word(netlist_outputs.dispersion);
    comparisons++; event_counts[kind]++; stage_counts[completed_stages]++;
    if (stage_counts[completed_stages] == EXPECTED_COUNTS[completed_stages]) begin
      stage_signatures[completed_stages] = signature;
      if (signature !== EXPECTED_SIGNATURES[completed_stages])
        $fatal(1, "Phase-step netlist stage signature mismatch stage=%0d", completed_stages);
      completed_stages++;
    end
  endtask

  initial begin
    foreach (stage_counts[k]) begin stage_counts[k] = 0; stage_signatures[k] = 0; end
    foreach (event_counts[k]) event_counts[k] = 0;
    foreach (scheduler_counts[k]) scheduler_counts[k] = 0;
    if ($bits(inputs) != 1054 || $bits(netlist_outputs) != 1168
        || $bits(u_netlist.clk) != 1 || $bits(u_netlist.rst_n) != 1
        || $bits(u_netlist.tick_enable) != 1 || $bits(u_netlist.load_valid) != 1
        || $bits(u_netlist.phase_load) != 256 || $bits(u_netlist.frequency_load_q16) != 256
        || $bits(u_netlist.gamma_effective_word) != 256 || $bits(u_netlist.thermal_node_factor_q30) != 256
        || $bits(u_netlist.retained_state) != 16 || $bits(u_netlist.switch_activity) != 8
        || $bits(u_netlist.scheduler_state) != 3 || $bits(u_netlist.phase_word_q) != 256
        || $bits(u_netlist.frequency_current_q16) != 256 || $bits(u_netlist.coupling_field_q16) != 256
        || $bits(u_netlist.phase_projection_q30) != 256 || $bits(u_netlist.phase_target) != 16
        || $bits(u_netlist.pair_coherence_q30) != 32 || $bits(u_netlist.cluster_coherence_q30) != 32
        || $bits(u_netlist.global_coherence_q30) != 32 || $bits(u_netlist.organization_dispersion_q30) != 32)
      $fatal(1, "Phase-step netlist interface width mismatch");
    forever begin
      @reference_test.sample_request;
      #1fs;
      compare_sample(reference_test.requested_kind);
    end
  end

  final begin
    if (mismatch_seen || !reference_test.done || reference_test.sample_busy || completed_stages != 5
        || comparisons != 113078 || field_checks != 1017702 || field_checks != 9 * comparisons
        || reference_test.observations != comparisons || reference_test.checks != field_checks
        || reference_test.stage != completed_stages || clock !== 1'b0 || inputs.reset_n !== 1'b1)
      $fatal(1, "Incomplete phase-step netlist replay observations=%0d checks=%0d stages=%0d reference_done=%0d",
             comparisons, field_checks, completed_stages, reference_test.done);
    foreach (stage_counts[k])
      if (stage_counts[k] != EXPECTED_COUNTS[k] || stage_counts[k] != reference_test.stage_counts[k]
          || stage_signatures[k] !== EXPECTED_SIGNATURES[k])
        $fatal(1, "Incomplete phase-step netlist stage=%0d", k);
    foreach (event_counts[k])
      if (event_counts[k] != EXPECTED_EVENTS[k] || event_counts[k] != reference_test.event_counts[k])
        $fatal(1, "Incomplete phase-step netlist event coverage kind=%0d", k);
    foreach (scheduler_counts[k])
      if (scheduler_counts[k] != EXPECTED_SCHEDULER[k]
          || scheduler_counts[k] != reference_test.scheduler_counts[k])
        $fatal(1, "Incomplete phase-step netlist scheduler-input coverage code=%0d", k);
    if (loads != 17174 || ticks != 19785 || holds != 721 || reset_updates != 17
        || load_over_tick != 73 || reset_low != 5 || reset_high != 4
        || loads + ticks + holds + reset_updates != event_counts[1] + event_counts[2]
        || loads != reference_test.loads || ticks != reference_test.ticks || holds != reference_test.holds
        || reset_updates != reference_test.reset_updates || load_over_tick != reference_test.load_over_tick
        || reset_low != reference_test.reset_low || reset_high != reference_test.reset_high)
      $fatal(1, "Incomplete phase-step netlist control coverage");
    if ((input_ones & input_zeros) !== EXPECTED_INPUT_MASK
        || (output_ones & output_zeros) !==
           {{1040{1'b1}}, 32'h3fffffff, 32'h3fffffff, 32'h3fffffff, 32'h1fffffff}
        || output_ones !== reference_test.output_ones || output_zeros !== reference_test.output_zeros)
      $fatal(1, "Phase-step netlist bit coverage mismatch");
    if (signature !== 64'h10edd9da06ef2aad || signature !== reference_test.signature
        || $isunknown({reference_outputs, netlist_outputs}) || netlist_outputs !== reference_outputs
        || previous_outputs !== netlist_outputs || netlist_outputs !== reference_test.expected)
      $fatal(1, "Final phase-step netlist signature or oracle mismatch");
    $display("FRP_M31_PHASE_STEP_BOUNDARY_POST_SYNTHESIS_TB: PASS stages=%0d comparisons=%0d field_checks=%0d rising_edges=%0d falling_edges=%0d asynchronous_resets=%0d reset_releases=%0d input_settles=%0d loads=%0d ticks=%0d holds=%0d reset_updates=%0d load_over_tick=%0d reset_low=%0d reset_high=%0d input_bits=1054 output_bits=1168 input_exercised=%0d output_exercised=%0d reference_observations=%0d reference_checks=%0d signature=%h",
             completed_stages, comparisons, field_checks, event_counts[1], event_counts[0],
             event_counts[2], event_counts[3], event_counts[4], loads, ticks, holds, reset_updates,
             load_over_tick, reset_low, reset_high, $countones(input_ones & input_zeros),
             $countones(output_ones & output_zeros), reference_test.observations, reference_test.checks, signature);
  end
endmodule : frp_m31_phase_step_boundary_post_synthesis_tb
`endif

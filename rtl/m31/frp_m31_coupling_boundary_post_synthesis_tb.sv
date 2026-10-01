// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 coupling netlist versus the unchanged RTL workload. Author: Alchimist.
`ifndef FRP_M31_COUPLING_BOUNDARY_POST_SYNTHESIS_TB_SV
`define FRP_M31_COUPLING_BOUNDARY_POST_SYNTHESIS_TB_SV
`include "frp_m31_coupling_boundary_tb.sv"

module frp_m31_coupling_boundary_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m31_coupling_boundary_tb_pkg::*;

  // Synthesize the eight-cell frp_m31_phase_interference with its packages
  // and sine ROM, retaining all 20 ports. Use the established synthesis-copy
  // normalization: remove only the four ROM simulation fatal guards, retain
  // $readmemh and all functional logic, and leave the RTL reference unchanged.
  // All four ROM guards remain active in that reference. Flatten and rename to
  // frp_m31_phase_interference_netlist, then compile the netlist and its cell
  // simulation library with this top, --timing, --assert and -Irtl/m31.
  // Keep rtl/m31/frp_m31_sin_q30.mem available from the simulation directory.
  // The reference's analytic sine, 128-bit coupling oracle, integer roots,
  // coverage assertions, signatures and watchdog remain active and unchanged.
  // Compare all nine public fields after both clock edges of every vector.
  // Tick stays disabled. Stages 0-4 use thermal factors in [0, Q30 one];
  // stage 5 separately exercises raw signed ports and saturation. This does
  // not claim that diagnostic inputs are reachable physical thermal states.
  // Scheduler/state encodings are diagnostics, not an execution trace.
  // This qualifies the declared loaded/held coupling workload on a generic
  // functional netlist, not phase recurrence, scheduler cadence, full input
  // or state coverage, physical timing or equivalence to model v0.9.3.
  frp_m31_coupling_boundary_tb reference_test();

  typedef struct packed {
    logic reset_n, tick, load;
    logic [255:0] phase_load, frequency_load, gamma, thermal;
    logic [15:0] retained;
    logic [7:0] activity;
    logic [2:0] scheduler;
  } stimulus_t;
  localparam int unsigned EXPECTED_COUNTS [0:5] = '{2241, 32769, 8960, 14336, 4096, 5640};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'ha934bff9a4040fe7, 64'h63c9decb64f3f7a4, 64'hc06ee89cab3825fe,
    64'ha9acc27ddfc9ba0e, 64'h1d06b40a7bb098e4, 64'hd76b2702931c48af
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

  int unsigned vectors = 0, comparisons = 0, field_checks = 0, completed_stages = 0;
  int unsigned rising_edges = 0, falling_edges = 0, loads = 0, holds = 0, resets = 0;
  int unsigned stage_counts[6], stage_observations[6], scheduler_bins[8];
  logic [63:0] stage_signatures[6];
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [1053:0] input_ones = '0, input_zeros = '0;
  logic [1167:0] output_ones = '0, output_zeros = '0;
  stimulus_t rising_inputs = '0;
  outputs_t rising_outputs = '0;
  bit mismatch_seen = 0, replay_done = 0, expect_rising = 1;

  task automatic compare_word(input string field_name, input logic [255:0] actual, expected);
    field_checks++;
    if ($isunknown({actual, expected}) || actual !== expected) begin
      mismatch_seen = 1;
      $fatal(1, "Coupling netlist mismatch observation=%0d field=%s actual=%h expected=%h vector=%0d clock=%b",
             comparisons, field_name, actual, expected, vectors, clock);
    end
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_sample(input bit rising);
    if (reference_test.done || completed_stages >= 6 || reference_test.stage != completed_stages
        || rising != expect_rising || reference_test.vectors != vectors + (rising ? 0 : 1)
        || reference_test.checks != 9 * reference_test.vectors
        || comparisons != 2 * vectors + (rising ? 0 : 1) || field_checks != 9 * comparisons)
      $fatal(1, "Coupling netlist sample alignment failed observation=%0d vector=%0d stage=%0d rising=%0d",
             comparisons, vectors, completed_stages, rising);
    if ($isunknown({clock, inputs}) || clock !== rising || clock !== reference_test.clk
        || inputs !== {reference_test.rst_n, 1'b0, reference_test.load_valid,
                       reference_test.phase_load, reference_test.frequency_load_q16,
                       reference_test.gamma_effective_word, reference_test.thermal_node_factor_q30,
                       reference_test.retained_state, reference_test.switch_activity,
                       reference_test.scheduler_state}
        || reference_outputs !== reference_test.outputs)
      $fatal(1, "Unknown or mismatched coupling netlist stimulus binding");

    compare_word("phase", netlist_outputs.phase_bank, reference_outputs.phase_bank);
    compare_word("frequency", netlist_outputs.frequency_bank, reference_outputs.frequency_bank);
    compare_word("coupling", netlist_outputs.coupling, reference_outputs.coupling);
    compare_word("projection", netlist_outputs.projection, reference_outputs.projection);
    compare_word("target", 256'(netlist_outputs.target), 256'(reference_outputs.target));
    compare_word("pair", 256'(netlist_outputs.pair_order), 256'(reference_outputs.pair_order));
    compare_word("cluster", 256'(netlist_outputs.cluster_order), 256'(reference_outputs.cluster_order));
    compare_word("global", 256'(netlist_outputs.global_order), 256'(reference_outputs.global_order));
    compare_word("dispersion", 256'(netlist_outputs.dispersion), 256'(reference_outputs.dispersion));
    input_ones |= inputs; input_zeros |= ~inputs;
    output_ones |= netlist_outputs; output_zeros |= ~netlist_outputs;
    comparisons++;
    stage_observations[completed_stages]++;
    expect_rising = !rising;

    if (rising) begin
      rising_edges++;
      if (!inputs.reset_n) resets++;
      else if (inputs.load) loads++;
      else holds++;
      scheduler_bins[inputs.scheduler]++;
      rising_inputs = inputs;
      rising_outputs = netlist_outputs;
      // Same 72-word stimulus/output order as the independent reference digest.
      hash_word(completed_stages);
      hash_word({27'b0, inputs.reset_n, inputs.load, inputs.scheduler});
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
    end else begin
      if (inputs !== rising_inputs || netlist_outputs !== rising_outputs
          || netlist_outputs !== reference_test.expected || signature !== reference_test.signature)
        $fatal(1, "Coupling netlist falling-edge retention or oracle mismatch vector=%0d", vectors);
      falling_edges++;
      vectors++;
      stage_counts[completed_stages]++;
      if (stage_counts[completed_stages] == EXPECTED_COUNTS[completed_stages]) begin
        stage_signatures[completed_stages] = signature;
        if (stage_observations[completed_stages] != 2 * EXPECTED_COUNTS[completed_stages]
            || signature !== EXPECTED_SIGNATURES[completed_stages])
          $fatal(1, "Coupling netlist stage mismatch stage=%0d observations=%0d signature=%h",
                 completed_stages, stage_observations[completed_stages], signature);
        completed_stages++;
      end
    end
  endtask

  initial begin
    foreach (stage_counts[k]) begin
      stage_counts[k] = 0; stage_observations[k] = 0; stage_signatures[k] = 0;
    end
    foreach (scheduler_bins[k]) scheduler_bins[k] = 0;
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
      $fatal(1, "Coupling netlist interface width mismatch");

    // The reference drives rising/falling edges 1 ps apart. Observe 1 fs
    // after each drive, before its next action, without changing the driver.
    #1fs;
    repeat (68042) begin
      compare_sample(1); #1ps;
      compare_sample(0); #1ps;
    end
    replay_done = 1;
  end

  final begin
    if (mismatch_seen || !replay_done || !reference_test.done || completed_stages != 6
        || vectors != 68042 || comparisons != 136084 || field_checks != 1224756
        || rising_edges != vectors || falling_edges != vectors || !expect_rising
        || comparisons != 2 * vectors || field_checks != 9 * comparisons
        || reference_test.vectors != vectors || reference_test.checks != 612378
        || reference_test.checks != 9 * vectors || reference_test.stage != completed_stages
        || clock !== 1'b0)
      $fatal(1, "Incomplete coupling netlist replay vectors=%0d observations=%0d checks=%0d stages=%0d reference_done=%0d",
             vectors, comparisons, field_checks, completed_stages, reference_test.done);
    foreach (stage_counts[k])
      if (stage_counts[k] != EXPECTED_COUNTS[k] || stage_counts[k] != reference_test.stage_counts[k]
          || stage_observations[k] != 2 * EXPECTED_COUNTS[k]
          || stage_signatures[k] !== EXPECTED_SIGNATURES[k])
        $fatal(1, "Incomplete coupling netlist stage=%0d", k);
    foreach (scheduler_bins[k])
      if (scheduler_bins[k] != (k < 2 ? 8506 : 8505)
          || scheduler_bins[k] != reference_test.scheduler_bins[k])
        $fatal(1, "Incomplete coupling netlist scheduler-input coverage code=%0d", k);
    if (loads != 33225 || holds != 34816 || resets != 1 || loads + holds + resets != vectors
        || loads != reference_test.loads || holds != reference_test.holds || resets != reference_test.resets)
      $fatal(1, "Incomplete coupling netlist control coverage");
    if ((input_ones & input_zeros) !== {3'b101, {1051{1'b1}}}
        || (output_ones & output_zeros) !==
           {{1040{1'b1}}, 32'h7fffffff, 32'h7fffffff, 32'h7fffffff, 32'h1fffffff}
        || output_ones !== reference_test.output_ones || output_zeros !== reference_test.output_zeros)
      $fatal(1, "Coupling netlist bit coverage mismatch");
    if (signature !== 64'hd76b2702931c48af || signature !== reference_test.signature
        || inputs !== rising_inputs || $isunknown({reference_outputs, netlist_outputs})
        || netlist_outputs !== reference_outputs || netlist_outputs !== reference_test.expected)
      $fatal(1, "Final coupling netlist signature or output mismatch");
    $display("FRP_M31_COUPLING_BOUNDARY_POST_SYNTHESIS_TB: PASS stages=%0d vectors=%0d comparisons=%0d field_checks=%0d rising_edges=%0d falling_edges=%0d loads=%0d holds=%0d resets=%0d input_bits=1054 output_bits=1168 input_exercised=%0d output_exercised=%0d reference_vectors=%0d reference_checks=%0d signature=%h",
             completed_stages, vectors, comparisons, field_checks, rising_edges, falling_edges,
             loads, holds, resets, $countones(input_ones & input_zeros), $countones(output_ones & output_zeros),
             reference_test.vectors, reference_test.checks, signature);
  end
endmodule : frp_m31_coupling_boundary_post_synthesis_tb
`endif

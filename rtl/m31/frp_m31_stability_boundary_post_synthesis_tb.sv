// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 stability netlist versus the unchanged RTL workload. Author: Alchimist.
`ifndef FRP_M31_STABILITY_BOUNDARY_POST_SYNTHESIS_TB_SV
`define FRP_M31_STABILITY_BOUNDARY_POST_SYNTHESIS_TB_SV
`include "frp_m31_stability_boundary_tb.sv"

module frp_m31_stability_boundary_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m31_stability_boundary_tb_pkg::*;

  // Synthesize the unchanged frp_m31_stability module with CELLS=8 from
  // rtl/m31/frp_m31_stability.sv and its fixed-point package. Flatten it
  // and rename it to frp_m31_stability_netlist, retaining all nine ports.
  // Compile the generated netlist and its simulation-cell library with
  // this top, --timing and -Irtl/m31. Do not synthesize the reference test.
  // The original stimulus, independent oracle and watchdog remain active.
  // This is functional comparison of a generic synthesis netlist for the
  // declared workload, without physical timing or model-equivalence claims.
  frp_m31_stability_boundary_tb reference_test();

  localparam int INPUT_BITS = $bits(inputs_t);
  localparam int OUTPUT_BITS = $bits(outputs_t);
  localparam int unsigned EXPECTED_COUNTS [0:5] = '{65536, 4563, 1764, 15876, 4096, 8192};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'h229d24de44365d37, 64'hb1a535a763bde271, 64'h518ab8db267550d7,
    64'hecf46a8aea3d0b15, 64'hc598b2e8564266fd, 64'h0de3e2d82f831ac7
  };
  localparam int unsigned EXPECTED_NEUTRAL_BINS [0:8] = '{6561, 17496, 20412, 13608, 5670, 1512, 252, 24, 1};
  localparam int unsigned EXPECTED_MARGIN_SIGNS [0:2] = '{19258, 3287, 77482};

  wire inputs_t inputs;
  wire outputs_t reference_outputs;
  wire outputs_t netlist_outputs;
  assign inputs = '{reference_test.dut.retained_state,
                   reference_test.dut.global_coherence_q30,
                   reference_test.dut.cluster_coherence_q30,
                   reference_test.dut.temperature_proxy_q16,
                   reference_test.dut.switch_load_q16};
  assign reference_outputs = '{reference_test.dut.coherence_capacity_q16,
                              reference_test.dut.pressure_q16,
                              reference_test.dut.stability_margin_q16,
                              reference_test.dut.stable};

  frp_m31_stability_netlist u_netlist (
    .retained_state(inputs.state_bank),
    .global_coherence_q30(inputs.global_order),
    .cluster_coherence_q30(inputs.cluster_order),
    .temperature_proxy_q16(inputs.temperature),
    .switch_load_q16(inputs.switch_load),
    .coherence_capacity_q16(netlist_outputs.capacity),
    .pressure_q16(netlist_outputs.pressure),
    .stability_margin_q16(netlist_outputs.margin),
    .stable(netlist_outputs.stable)
  );

  int unsigned comparisons = 0, field_checks = 0, completed_stages = 0;
  int unsigned input_transitions = 0, repeated_inputs = 0;
  int unsigned stage_counts[6], margin_sign_counts[3];
  int unsigned stable_true = 0, stable_false = 0;
  logic [63:0] stage_signatures[6];
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [INPUT_BITS-1:0] input_ones = '0, input_zeros = '0;
  logic [OUTPUT_BITS-1:0] output_ones = '0, output_zeros = '0;
  inputs_t previous_inputs = '0;
  bit mismatch_seen = 0;

  task automatic compare_word(input string field_name,
      input logic [63:0] actual, expected);
    field_checks++;
    if ($isunknown({actual, expected}) || actual !== expected) begin
      mismatch_seen = 1;
      $fatal(1, "Stability netlist mismatch vector=%0d field=%s actual=%h expected=%h inputs=%h",
             comparisons, field_name, actual, expected, inputs);
    end
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_sample;
    // Each reference vector lasts 1 ps and is checked at the end of that interval.
    // Sample at 1 fs after its drive, then once per interval, including repeats.
    // This checks every settled vector without racing the reference assertions.
    if (reference_test.done || reference_test.vectors != comparisons
        || reference_test.checks != 4 * comparisons || completed_stages >= 6)
      $fatal(1, "Stability netlist sample alignment failed sample=%0d reference=%0d checks=%0d stage=%0d",
             comparisons, reference_test.vectors, reference_test.checks, completed_stages);
    if ($isunknown(inputs) || inputs !== reference_test.inputs)
      $fatal(1, "Unknown or mismatched stability netlist input");

    compare_word("capacity", 64'(netlist_outputs.capacity), 64'(reference_outputs.capacity));
    compare_word("pressure", 64'(netlist_outputs.pressure), 64'(reference_outputs.pressure));
    compare_word("margin", 64'(netlist_outputs.margin), 64'(reference_outputs.margin));
    compare_word("stable", {63'b0, netlist_outputs.stable}, {63'b0, reference_outputs.stable});

    if (comparisons != 0) begin
      if (inputs !== previous_inputs) input_transitions++;
      else repeated_inputs++;
    end
    previous_inputs = inputs;
    input_ones |= inputs;
    input_zeros |= ~inputs;
    output_ones |= netlist_outputs;
    output_zeros |= ~netlist_outputs;
    if (netlist_outputs.margin < 0) margin_sign_counts[0]++;
    else if (netlist_outputs.margin == 0) margin_sign_counts[1]++;
    else margin_sign_counts[2]++;
    if (netlist_outputs.stable) stable_true++;
    else stable_false++;

    // Hash actual netlist outputs in the same word order as the RTL oracle test.
    hash_word({16'b0, inputs.state_bank});
    hash_word(inputs.global_order); hash_word(inputs.cluster_order);
    hash_word(inputs.temperature); hash_word(inputs.switch_load);
    hash_word(netlist_outputs.capacity); hash_word(netlist_outputs.pressure);
    hash_word(netlist_outputs.margin); hash_word({31'b0, netlist_outputs.stable});

    comparisons++;
    stage_counts[completed_stages]++;
    if (stage_counts[completed_stages] == EXPECTED_COUNTS[completed_stages]) begin
      stage_signatures[completed_stages] = signature;
      if (signature !== EXPECTED_SIGNATURES[completed_stages])
        $fatal(1, "Stability netlist stage signature failed stage=%0d signature=%h expected=%h",
               completed_stages, signature, EXPECTED_SIGNATURES[completed_stages]);
      completed_stages++;
    end
  endtask

  initial begin
    foreach (stage_counts[k]) begin
      stage_counts[k] = 0;
      stage_signatures[k] = 0;
    end
    foreach (margin_sign_counts[k]) margin_sign_counts[k] = 0;
    if (INPUT_BITS != 144 || OUTPUT_BITS != 97
        || $bits(u_netlist.retained_state) != 16
        || $bits(u_netlist.global_coherence_q30) != 32
        || $bits(u_netlist.cluster_coherence_q30) != 32
        || $bits(u_netlist.temperature_proxy_q16) != 32
        || $bits(u_netlist.switch_load_q16) != 32
        || $bits(u_netlist.coherence_capacity_q16) != 32
        || $bits(u_netlist.pressure_q16) != 32
        || $bits(u_netlist.stability_margin_q16) != 32
        || $bits(u_netlist.stable) != 1)
      $fatal(1, "Stability netlist interface width mismatch");
    #1fs;
    forever begin
      compare_sample();
      #1ps;
    end
  end

  final begin
    if (mismatch_seen || !reference_test.done || comparisons != 100027
        || field_checks != 400108 || completed_stages != 6
        || reference_test.vectors != comparisons || reference_test.checks != field_checks
        || input_transitions != 100026 || repeated_inputs != 0
        || input_transitions + repeated_inputs + 1 != comparisons)
      $fatal(1, "Incomplete stability netlist replay comparisons=%0d checks=%0d stages=%0d changes=%0d repeats=%0d reference_done=%0d",
             comparisons, field_checks, completed_stages, input_transitions,
             repeated_inputs, reference_test.done);
    foreach (stage_counts[k]) begin
      if (stage_counts[k] != EXPECTED_COUNTS[k]
          || stage_counts[k] != reference_test.stage_counts[k]
          || stage_signatures[k] !== EXPECTED_SIGNATURES[k])
        $fatal(1, "Incomplete stability netlist stage=%0d count=%0d signature=%h",
               k, stage_counts[k], stage_signatures[k]);
    end
    foreach (margin_sign_counts[k])
      if (margin_sign_counts[k] != EXPECTED_MARGIN_SIGNS[k]
          || margin_sign_counts[k] != reference_test.margin_sign_counts[k]
          || reference_test.boundary_bins[k] != 1521)
        $fatal(1, "Stability netlist margin coverage failed bin=%0d count=%0d",
               k, margin_sign_counts[k]);
    foreach (reference_test.neutral_bins[k])
      if (reference_test.neutral_bins[k] != EXPECTED_NEUTRAL_BINS[k])
        $fatal(1, "Incomplete stability reference neutral coverage zeros=%0d", k);
    if (stable_true != 77482 || stable_false != 22545
        || stable_true + stable_false != comparisons
        || stable_true != margin_sign_counts[2]
        || (input_ones & input_zeros) !== {INPUT_BITS{1'b1}}
        || (output_ones & output_zeros) !== {OUTPUT_BITS{1'b1}}
        || input_ones !== reference_test.input_ones || input_zeros !== reference_test.input_zeros
        || output_ones !== reference_test.output_ones || output_zeros !== reference_test.output_zeros)
      $fatal(1, "Stability netlist bit or decision coverage failed inputs=%h outputs=%h true=%0d false=%0d",
             input_ones & input_zeros, output_ones & output_zeros, stable_true, stable_false);
    if (reference_test.valid_state_words != 6561 || reference_test.reserved_state_words != 58975
        || reference_test.pressure_high != 6471 || reference_test.pressure_low != 1316
        || reference_test.margin_high_wraps != 3167 || reference_test.margin_low_wraps != 25
        || reference_test.global_ties != 2'b11 || reference_test.cluster_ties != 2'b11
        || reference_test.neutral_ties != 9543 || reference_test.diagnostic_vectors != 82276)
      $fatal(1, "Incomplete stability reference diagnostic coverage during netlist replay");
    if (signature !== 64'h0de3e2d82f831ac7 || signature !== reference_test.signature
        || inputs !== previous_inputs || $isunknown({reference_outputs, netlist_outputs})
        || reference_outputs !== netlist_outputs)
      $fatal(1, "Final stability netlist signature or output mismatch");
    $display("FRP_M31_STABILITY_BOUNDARY_POST_SYNTHESIS_TB: PASS stages=%0d comparisons=%0d field_checks=%0d input_bits=%0d output_bits=%0d input_transitions=%0d repeated_inputs=%0d input_exercised=%0d output_exercised=%0d negative_margins=%0d zero_margins=%0d positive_margins=%0d stable_true=%0d stable_false=%0d reference_vectors=%0d reference_checks=%0d signature=%h",
             completed_stages, comparisons, field_checks, INPUT_BITS, OUTPUT_BITS,
             input_transitions, repeated_inputs, $countones(input_ones & input_zeros),
             $countones(output_ones & output_zeros), margin_sign_counts[0], margin_sign_counts[1],
             margin_sign_counts[2], stable_true, stable_false, reference_test.vectors,
             reference_test.checks, signature);
  end
endmodule : frp_m31_stability_boundary_post_synthesis_tb
`endif

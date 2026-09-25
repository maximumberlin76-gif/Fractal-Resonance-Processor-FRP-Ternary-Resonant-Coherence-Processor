// SPDX-License-Identifier: Apache-2.0
// FRP M31 arithmetic netlist versus the unchanged RTL workload. Author: Alchimist.
`ifndef FRP_M31_FIXED_POINT_ARITHMETIC_POST_SYNTHESIS_TB_SV
`define FRP_M31_FIXED_POINT_ARITHMETIC_POST_SYNTHESIS_TB_SV
`include "frp_m31_fixed_point_arithmetic_tb.sv"

module frp_m31_fixed_point_arithmetic_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m31_fixed_point_arithmetic_tb_pkg::*;

  // Synthesize frp_m31_fixed_point_arithmetic_probe from the unchanged
  // frp_m31_fixed_point_arithmetic_tb.sv and fixed-point package. Flatten it
  // and rename it to frp_m31_fixed_point_arithmetic_netlist. Keep both packed
  // ports: inputs[133:0] and outputs[287:0]. Compile that generated netlist
  // and its simulation-cell library with this top, --timing and -Irtl/m31.
  // The oracle, stimulus, stage signatures and watchdog remain in the
  // reference testbench; neither the oracle nor stimulus is synthesized.
  // This checks numerical primitives for the declared workload. It does not
  // establish physical timing, complete input coverage or model equivalence.
  frp_m31_fixed_point_arithmetic_tb reference_test();

  localparam int INPUT_BITS = $bits(inputs_t);
  localparam int OUTPUT_BITS = $bits(outputs_t);
  localparam int unsigned EXPECTED_COUNTS [0:5] = '{2304, 19, 98304, 144, 66, 8192};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'h3e6bc088cdd3e601, 64'hd81673c6c6e82db1, 64'h1f75182cfc635ec9,
    64'h36b23192e43db8c1, 64'h483d4db9cec63b54, 64'heb5e16fa27069f34
  };
  localparam int unsigned EXPECTED_SHIFT_COUNTS [0:3] = '{2067, 2096, 102770, 2096};
  // Only shifts 0, 14, 16 and 30 belong to the reference qualification.
  // Shift bits 0 and 5 stay zero; all other input bits take both values.
  localparam logic [133:0] EXPECTED_INPUT_EXERCISE = {{128{1'b1}}, 6'b011110};

  wire inputs_t inputs;
  wire outputs_t reference_outputs;
  wire outputs_t netlist_outputs;
  assign inputs = reference_test.dut.inputs;
  assign reference_outputs = reference_test.dut.outputs;

  frp_m31_fixed_point_arithmetic_netlist u_netlist (
    .inputs(inputs),
    .outputs(netlist_outputs)
  );

  int unsigned comparisons = 0, field_checks = 0, completed_stages = 0;
  int unsigned input_transitions = 0, repeated_inputs = 0;
  int unsigned stage_counts[6], shift_counts[4];
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
      $fatal(1, "Arithmetic netlist mismatch vector=%0d field=%s actual=%h expected=%h inputs=%h",
             comparisons, field_name, actual, expected, inputs);
    end
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_sample;
    // The reference checks this vector at the end of its 1 ps interval.
    // Sampling 1 fs after the drive gives combinational logic time to settle.
    // Counting every interval also detects skipped or duplicated samples.
    if (reference_test.done || reference_test.vectors != comparisons
        || reference_test.checks != 8 * comparisons || completed_stages >= 6)
      $fatal(1, "Arithmetic netlist sample alignment failed sample=%0d reference=%0d checks=%0d stage=%0d",
             comparisons, reference_test.vectors, reference_test.checks, completed_stages);
    if ($isunknown(inputs)) $fatal(1, "Unknown arithmetic netlist input");

    compare_word("saturated", 64'(netlist_outputs.saturated), 64'(reference_outputs.saturated));
    compare_word("rounded", netlist_outputs.rounded, reference_outputs.rounded);
    compare_word("product_q16", 64'(netlist_outputs.product_q16), 64'(reference_outputs.product_q16));
    compare_word("product_q30", 64'(netlist_outputs.product_q30), 64'(reference_outputs.product_q30));
    compare_word("mixed_q16", 64'(netlist_outputs.mixed_q16), 64'(reference_outputs.mixed_q16));
    compare_word("down_q16", 64'(netlist_outputs.down_q16), 64'(reference_outputs.down_q16));
    compare_word("up_q30", 64'(netlist_outputs.up_q30), 64'(reference_outputs.up_q30));
    compare_word("phase_step", 64'(netlist_outputs.phase_step), 64'(reference_outputs.phase_step));

    if (comparisons != 0) begin
      if (inputs !== previous_inputs) input_transitions++;
      else repeated_inputs++;
    end
    previous_inputs = inputs;
    input_ones |= inputs;
    input_zeros |= ~inputs;
    output_ones |= netlist_outputs;
    output_zeros |= ~netlist_outputs;
    case (inputs.shift)
      6'd0: shift_counts[0]++;
      6'd14: shift_counts[1]++;
      6'd16: shift_counts[2]++;
      6'd30: shift_counts[3]++;
      default: $fatal(1, "Arithmetic netlist shift outside the declared profile");
    endcase

    // Hash netlist results independently, preserving the reference word order.
    hash_word(inputs.left_word); hash_word(inputs.right_word);
    hash_word(inputs.wide_word[63:32]); hash_word(inputs.wide_word[31:0]);
    hash_word({26'b0, inputs.shift}); hash_word(netlist_outputs.saturated);
    hash_word(netlist_outputs.rounded[63:32]); hash_word(netlist_outputs.rounded[31:0]);
    hash_word(netlist_outputs.product_q16); hash_word(netlist_outputs.product_q30);
    hash_word(netlist_outputs.mixed_q16); hash_word(netlist_outputs.down_q16);
    hash_word(netlist_outputs.up_q30); hash_word(netlist_outputs.phase_step);

    comparisons++;
    stage_counts[completed_stages]++;
    if (stage_counts[completed_stages] == EXPECTED_COUNTS[completed_stages]) begin
      stage_signatures[completed_stages] = signature;
      if (signature !== EXPECTED_SIGNATURES[completed_stages])
        $fatal(1, "Arithmetic netlist stage signature failed stage=%0d signature=%h expected=%h",
               completed_stages, signature, EXPECTED_SIGNATURES[completed_stages]);
      completed_stages++;
    end
  endtask

  initial begin
    foreach (stage_counts[k]) begin
      stage_counts[k] = 0;
      stage_signatures[k] = 0;
    end
    foreach (shift_counts[k]) shift_counts[k] = 0;
    if (INPUT_BITS != 134 || OUTPUT_BITS != 288
        || $bits(u_netlist.inputs) != INPUT_BITS || $bits(u_netlist.outputs) != OUTPUT_BITS)
      $fatal(1, "Arithmetic netlist interface width mismatch");
    #1fs;
    forever begin
      compare_sample();
      #1ps;
    end
  end

  final begin
    if (mismatch_seen || !reference_test.done || comparisons != 109029
        || field_checks != 872232 || completed_stages != 6
        || reference_test.vectors != comparisons || reference_test.checks != field_checks
        || input_transitions != 109028 || repeated_inputs != 0
        || input_transitions + repeated_inputs + 1 != comparisons)
      $fatal(1, "Incomplete arithmetic netlist replay comparisons=%0d checks=%0d stages=%0d changes=%0d repeats=%0d reference_done=%0d",
             comparisons, field_checks, completed_stages, input_transitions,
             repeated_inputs, reference_test.done);
    foreach (stage_counts[k]) begin
      if (stage_counts[k] != EXPECTED_COUNTS[k]
          || stage_counts[k] != reference_test.stage_counts[k]
          || stage_signatures[k] !== EXPECTED_SIGNATURES[k])
        $fatal(1, "Incomplete arithmetic netlist stage=%0d count=%0d signature=%h",
               k, stage_counts[k], stage_signatures[k]);
    end
    foreach (shift_counts[k])
      if (shift_counts[k] != EXPECTED_SHIFT_COUNTS[k])
        $fatal(1, "Arithmetic netlist shift coverage failed index=%0d count=%0d expected=%0d",
               k, shift_counts[k], EXPECTED_SHIFT_COUNTS[k]);
    if ((input_ones & input_zeros) !== EXPECTED_INPUT_EXERCISE
        || (output_ones & output_zeros) !== {OUTPUT_BITS{1'b1}})
      $fatal(1, "Arithmetic netlist bit exercise failed inputs=%h outputs=%h",
             input_ones & input_zeros, output_ones & output_zeros);
    if (reference_test.shifts_seen != 4'hf
        || reference_test.residue_counts[0] != 16384 || reference_test.residue_counts[1] != 16384
        || reference_test.positive_saturation != 5'h1f || reference_test.negative_saturation != 5'h1f
        || reference_test.tie_mask != 8'hbf || reference_test.phase_wrap_signs != 2'b11)
      $fatal(1, "Incomplete arithmetic reference coverage during netlist replay");
    foreach (reference_test.residues_seen[s, r])
      if (!reference_test.residues_seen[s][r])
        $fatal(1, "Missing arithmetic reference remainder sign=%0d residue=%0d", s, r);
    if (signature !== 64'heb5e16fa27069f34 || signature !== reference_test.signature
        || inputs !== previous_inputs || $isunknown({reference_outputs, netlist_outputs})
        || reference_outputs !== netlist_outputs)
      $fatal(1, "Final arithmetic netlist signature or output mismatch");
    $display("FRP_M31_FIXED_POINT_ARITHMETIC_POST_SYNTHESIS_TB: PASS stages=%0d comparisons=%0d field_checks=%0d input_bits=%0d output_bits=%0d input_transitions=%0d repeated_inputs=%0d input_exercised=%0d output_exercised=%0d shift_0=%0d shift_14=%0d shift_16=%0d shift_30=%0d reference_vectors=%0d reference_checks=%0d signature=%h",
             completed_stages, comparisons, field_checks, INPUT_BITS, OUTPUT_BITS,
             input_transitions, repeated_inputs, $countones(input_ones & input_zeros),
             $countones(output_ones & output_zeros), shift_counts[0], shift_counts[1],
             shift_counts[2], shift_counts[3], reference_test.vectors,
             reference_test.checks, signature);
  end
endmodule : frp_m31_fixed_point_arithmetic_post_synthesis_tb
`endif

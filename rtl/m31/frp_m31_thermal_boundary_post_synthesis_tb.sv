// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 thermal netlist versus the unchanged RTL workload. Author: Alchimist.
`ifndef FRP_M31_THERMAL_BOUNDARY_POST_SYNTHESIS_TB_SV
`define FRP_M31_THERMAL_BOUNDARY_POST_SYNTHESIS_TB_SV
`include "frp_m31_thermal_boundary_tb.sv"

module frp_m31_thermal_boundary_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m31_thermal_boundary_tb_pkg::*;

  // Synthesize the unchanged frp_m31_thermal_proxy from rtl/m31 and its
  // fixed-point package. Flatten it, retain all eight ports, and rename it
  // to frp_m31_thermal_proxy_netlist. Compile that netlist and its simulation
  // cell library with this top, --timing, --assert and -Irtl/m31.
  // Do not synthesize or modify the reference test. Its independent 128-bit
  // oracle, coverage assertions, signatures and watchdog remain active.
  // Comparison covers all 96 output bits on this workload, including holds
  // and asynchronous reset assertion/release at both clock levels.
  // This is functional generic-netlist simulation, not physical timing,
  // physical heat, exhaustive state coverage or model v0.9.3 equivalence.
  frp_m31_thermal_boundary_tb reference_test();

  typedef struct packed {
    logic reset_n, clear, tick;
    logic signed [31:0] cost;
  } stimulus_t;
  localparam int unsigned EXPECTED_CYCLES [0:6] =
    '{144, 196611, 196608, 216, 24588, 65541, 32770};
  localparam int unsigned EXPECTED_OBSERVATIONS [0:6] =
    '{480, 589833, 589824, 648, 73764, 196623, 98378};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:6] = '{
    64'h7de57c7b58f4c12c, 64'h491f697fe39a148c, 64'hb2c6118f0c4e8a25,
    64'h83ad4b39ec0e196b, 64'h3ff3ff6737faa5d9, 64'hd2e7f48157cb7a04,
    64'h0247f52a740b51d9
  };
  localparam int unsigned EXPECTED_KINDS [0:4] = '{516478, 516478, 516478, 58, 58};

  wire clock;
  wire stimulus_t inputs;
  wire outputs_t reference_outputs, netlist_outputs;
  assign clock = reference_test.dut.clk;
  assign inputs = '{reference_test.dut.rst_n, reference_test.dut.clear,
                   reference_test.dut.tick_enable, reference_test.dut.normalized_cycle_cost_q16};
  assign reference_outputs = '{reference_test.dut.temperature_proxy_q16,
                              reference_test.dut.peak_temperature_proxy_q16,
                              reference_test.dut.sample_count_q};

  frp_m31_thermal_proxy_netlist u_netlist (
    .clk(clock), .rst_n(inputs.reset_n), .clear(inputs.clear),
    .tick_enable(inputs.tick), .normalized_cycle_cost_q16(inputs.cost),
    .temperature_proxy_q16(netlist_outputs.temperature),
    .peak_temperature_proxy_q16(netlist_outputs.peak),
    .sample_count_q(netlist_outputs.samples)
  );

  int unsigned cycles = 0, comparisons = 0, field_checks = 0, completed_stages = 0;
  int unsigned stage_counts[7], stage_observations[7], kind_counts[5];
  int unsigned updates = 0, holds = 0, clear_edges = 0, reset_edges = 0;
  int unsigned low_reset_pulses = 0, high_reset_pulses = 0;
  int unsigned previous_kind = 2;
  logic previous_clock = 0;
  stimulus_t previous_inputs = '0;
  logic [63:0] stage_signatures[7];
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [34:0] input_ones = '0, input_zeros = '0;
  logic [95:0] output_ones = '0, output_zeros = '0;
  bit mismatch_seen = 0, replay_done = 0;

  task automatic compare_word(input string field_name, input logic [31:0] actual, expected);
    field_checks++;
    if ($isunknown({actual, expected}) || actual !== expected) begin
      mismatch_seen = 1;
      $fatal(1, "Thermal netlist mismatch observation=%0d field=%s actual=%h expected=%h cycle=%0d clock=%b inputs=%h",
             comparisons, field_name, actual, expected, cycles, clock, inputs);
    end
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_sample(input int unsigned kind);
    if (reference_test.done || reference_test.observations != comparisons
        || reference_test.checks != 3 * comparisons || reference_test.cycles != cycles
        || completed_stages >= 7 || reference_test.stage != completed_stages || kind > 4)
      $fatal(1, "Thermal netlist sample alignment failed observation=%0d reference=%0d cycle=%0d stage=%0d kind=%0d",
             comparisons, reference_test.observations, cycles, completed_stages, kind);
    if ($isunknown({clock, inputs}) || clock !== reference_test.clk
        || inputs !== {reference_test.rst_n, reference_test.clear,
                       reference_test.tick_enable, reference_test.normalized_cycle_cost_q16}
        || reference_outputs !== reference_test.outputs)
      $fatal(1, "Unknown or mismatched thermal netlist stimulus binding");

    // Check the event sequence using public pins, independently of the oracle.
    if (kind == 0) begin
      if (clock !== 1'b0 || previous_kind != 2)
        $fatal(1, "Thermal netlist pre-edge sequence mismatch");
    end else begin
      if ({inputs.clear, inputs.tick, inputs.cost}
          !== {previous_inputs.clear, previous_inputs.tick, previous_inputs.cost})
        $fatal(1, "Thermal netlist controls changed within a cycle");
      case (kind)
        1, 2: begin
          if (inputs !== previous_inputs || clock !== (kind == 1)
              || previous_clock !== (kind == 2)
              || (previous_kind != (kind == 1 ? 0 : 1) && previous_kind != 4))
            $fatal(1, "Thermal netlist clock-edge sequence mismatch kind=%0d", kind);
        end
        3: begin
          if (clock !== previous_clock || inputs.reset_n !== 1'b0
              || previous_inputs.reset_n !== 1'b1
              || previous_kind != (clock ? 1 : 0))
            $fatal(1, "Thermal netlist asynchronous reset assertion sequence mismatch");
          if (clock) high_reset_pulses++;
          else low_reset_pulses++;
        end
        4: begin
          if (clock !== previous_clock || inputs.reset_n !== 1'b1
              || previous_inputs.reset_n !== 1'b0 || previous_kind != 3)
            $fatal(1, "Thermal netlist asynchronous reset release sequence mismatch");
        end
        default: $fatal(1, "Invalid thermal netlist observation kind");
      endcase
    end

    compare_word("temperature", netlist_outputs.temperature, reference_outputs.temperature);
    compare_word("peak", netlist_outputs.peak, reference_outputs.peak);
    compare_word("samples", netlist_outputs.samples, reference_outputs.samples);
    input_ones |= inputs; input_zeros |= ~inputs;
    output_ones |= netlist_outputs; output_zeros |= ~netlist_outputs;
    hash_word(kind); hash_word({29'b0, inputs.reset_n, inputs.clear, inputs.tick});
    hash_word(inputs.cost); hash_word(netlist_outputs.temperature);
    hash_word(netlist_outputs.peak); hash_word(netlist_outputs.samples);
    previous_inputs = inputs; previous_clock = clock; previous_kind = kind;
    kind_counts[kind]++;
    stage_observations[completed_stages]++;
    comparisons++;

    if (kind == 1) begin
      if (!inputs.reset_n) reset_edges++;
      else if (inputs.clear) clear_edges++;
      else if (inputs.tick) updates++;
      else holds++;
    end
    if (kind == 2) begin
      cycles++;
      stage_counts[completed_stages]++;
      if (stage_counts[completed_stages] == EXPECTED_CYCLES[completed_stages]) begin
        stage_signatures[completed_stages] = signature;
        if (stage_observations[completed_stages] != EXPECTED_OBSERVATIONS[completed_stages]
            || signature !== EXPECTED_SIGNATURES[completed_stages])
          $fatal(1, "Thermal netlist stage mismatch stage=%0d observations=%0d signature=%h",
                 completed_stages, stage_observations[completed_stages], signature);
        completed_stages++;
      end
    end
  endtask

  initial begin
    foreach (stage_counts[k]) begin
      stage_counts[k] = 0; stage_observations[k] = 0; stage_signatures[k] = 0;
    end
    foreach (kind_counts[k]) kind_counts[k] = 0;
    if ($bits(inputs) != 35 || $bits(netlist_outputs) != 96
        || $bits(u_netlist.clk) != 1 || $bits(u_netlist.rst_n) != 1
        || $bits(u_netlist.clear) != 1 || $bits(u_netlist.tick_enable) != 1
        || $bits(u_netlist.normalized_cycle_cost_q16) != 32
        || $bits(u_netlist.temperature_proxy_q16) != 32
        || $bits(u_netlist.peak_temperature_proxy_q16) != 32
        || $bits(u_netlist.sample_count_q) != 32)
      $fatal(1, "Thermal netlist interface width mismatch");

    // Reference observations are 1 ps apart. Sample 1 fs after each drive,
    // before its oracle check, avoiding same-timestamp changes to the pins.
    // Include both extra observations whenever reset pulses off the edge.
    #1fs;
    repeat (516478) begin
      compare_sample(0); #1ps;
      if (clock === 1'b0) begin
        compare_sample(3); #1ps;
        compare_sample(4); #1ps;
      end
      compare_sample(1); #1ps;
      if (clock === 1'b1) begin
        compare_sample(3); #1ps;
        compare_sample(4); #1ps;
      end
      compare_sample(2); #1ps;
    end
    replay_done = 1;
  end

  final begin
    if (mismatch_seen || !replay_done || !reference_test.done || completed_stages != 7
        || cycles != 516478 || comparisons != 1549550 || field_checks != 4648650
        || reference_test.cycles != cycles || reference_test.observations != comparisons
        || reference_test.checks != field_checks || reference_test.stage != completed_stages
        || comparisons != 3 * cycles + 2 * (low_reset_pulses + high_reset_pulses)
        || field_checks != 3 * comparisons || previous_kind != 2 || clock !== 1'b0)
      $fatal(1, "Incomplete thermal netlist replay cycles=%0d observations=%0d checks=%0d stages=%0d reference_done=%0d",
             cycles, comparisons, field_checks, completed_stages, reference_test.done);
    foreach (stage_counts[k])
      if (stage_counts[k] != EXPECTED_CYCLES[k] || stage_counts[k] != reference_test.stage_counts[k]
          || stage_observations[k] != EXPECTED_OBSERVATIONS[k]
          || stage_signatures[k] !== EXPECTED_SIGNATURES[k])
        $fatal(1, "Incomplete thermal netlist stage=%0d", k);
    foreach (kind_counts[k])
      if (kind_counts[k] != EXPECTED_KINDS[k])
        $fatal(1, "Incomplete thermal netlist observation kind=%0d count=%0d", k, kind_counts[k]);
    if (updates != 245697 || holds != 139292 || clear_edges != 131343 || reset_edges != 146
        || updates + holds + clear_edges + reset_edges != cycles
        || updates != reference_test.updates || holds != reference_test.holds
        || clear_edges != reference_test.clear_edges || reset_edges != reference_test.reset_edges
        || low_reset_pulses != 30 || high_reset_pulses != 28
        || low_reset_pulses + high_reset_pulses != reference_test.async_pulses)
      $fatal(1, "Incomplete thermal netlist control coverage");
    if ((input_ones & input_zeros) !== 35'h7ffffffff
        || (output_ones & output_zeros) !== 96'hffffffff1fffffff0001ffff
        || input_ones !== reference_test.input_ones || input_zeros !== reference_test.input_zeros
        || output_ones !== reference_test.output_ones || output_zeros !== reference_test.output_zeros)
      $fatal(1, "Thermal netlist bit coverage mismatch");
    if (signature !== 64'h0247f52a740b51d9 || signature !== reference_test.signature
        || inputs !== previous_inputs || $isunknown({reference_outputs, netlist_outputs})
        || reference_outputs !== netlist_outputs || netlist_outputs.temperature != 85020103
        || netlist_outputs.peak != 85020103 || netlist_outputs.samples != 23)
      $fatal(1, "Final thermal netlist signature or output mismatch");
    $display("FRP_M31_THERMAL_BOUNDARY_POST_SYNTHESIS_TB: PASS stages=%0d cycles=%0d comparisons=%0d field_checks=%0d pre_edges=%0d rising_edges=%0d falling_edges=%0d reset_assertions=%0d reset_releases=%0d updates=%0d holds=%0d clear_edges=%0d reset_edges=%0d low_reset_pulses=%0d high_reset_pulses=%0d input_bits=35 output_bits=96 input_exercised=%0d output_exercised=%0d reference_observations=%0d reference_checks=%0d signature=%h",
             completed_stages, cycles, comparisons, field_checks, kind_counts[0], kind_counts[1],
             kind_counts[2], kind_counts[3], kind_counts[4], updates, holds, clear_edges, reset_edges,
             low_reset_pulses, high_reset_pulses, $countones(input_ones & input_zeros),
             $countones(output_ones & output_zeros), reference_test.observations,
             reference_test.checks, signature);
  end
endmodule : frp_m31_thermal_boundary_post_synthesis_tb
`endif

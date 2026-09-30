// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 phase-order arithmetic and geometry boundaries. Author: Alchimist.
// Build from the repository root with --binary --timing --assert -Irtl/m31
// and --top-module frp_m31_phase_order_boundary_tb.
// All nine public outputs are checked against an independent oracle using
// analytic sine samples, signed 128-bit means and binary-search integer roots.
// No DUT helper, internal state or ROM data is used to derive expected values.
// Expected counts and signatures also come from a Python arbitrary-integer oracle.
// Ticks stay disabled and thermal factors stay zero: coupling must be zero.
// This isolates loaded phase geometry; nonzero coupling and phase evolution
// remain covered by separate tests. Raw scheduler/state encodings are input
// diagnostics here, not a qualification of cadence or full-core reachability.
// Targets are phase observations, not executed ternary state transitions.
// The exhaustive domain is 4^8 cardinal-phase banks, not the full phase space.
// No physical timing, hardware readiness or model v0.9.3 equivalence is claimed.

`ifndef FRP_M31_PHASE_ORDER_BOUNDARY_TB_SV
`define FRP_M31_PHASE_ORDER_BOUNDARY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"

package frp_m31_phase_order_boundary_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic [255:0] phase_bank, frequency_bank, coupling, projection;
    logic [15:0] target;
    logic signed [31:0] pair_order, cluster_order, global_order, dispersion;
  } outputs_t;
endpackage

module frp_m31_phase_order_boundary_tb;
  import frp_m31_phase_order_boundary_tb_pkg::*;
  localparam int unsigned EXPECTED_COUNTS [0:5] = '{65537, 16384, 2048, 1024, 2048, 2048};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'hd1adf5d6dee56313,
    64'h428702501bbf0a71,
    64'h3140e569d9b5bd57,
    64'hf50c21b2096e794b,
    64'haa0f1506a19a2f97,
    64'h540a693ef2011a97
  };
  localparam int unsigned EXPECTED_MEANS [0:2][0:6] = '{
    '{628258, 0, 48002, 0, 0, 36452, 0},
    '{298358, 7629, 16841, 7605, 7547, 10811, 7565},
    '{148680, 5585, 5861, 5763, 4507, 2983, 4799}
  };
  localparam int unsigned EXPECTED_ZERO [0:2] = '{258, 1298, 8998};
  localparam int unsigned EXPECTED_UNIT [0:2] = '{259, 18, 6};
  localparam int unsigned EXPECTED_TARGETS [0:2] = '{186534, 339568, 186610};
  localparam logic [31:0] LOW_BITS [0:3] = '{0, 1, 32'h0007ffff, 32'h000fffff};

  logic clk = 0, rst_n = 1, load_valid = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0, gamma_effective_word = 0;
  logic [15:0] retained_state = 0;
  logic [7:0] switch_activity = 0;
  frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state = frp_m31_pkg::FRP_SCHED_FREE;
  outputs_t outputs, expected;
  logic [255:0] model_phase = 0, model_frequency = 0;
  logic signed [31:0] sine_reference[4096];
  logic [31:0] random_word = 76;
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [1167:0] output_ones = '0, output_zeros = '0;
  int unsigned stage = 0, vectors = 0, checks = 0, loads = 0, holds = 0, resets = 0;
  int unsigned stage_counts[6], mean_bins[3][7], scheduler_bins[8], target_bins[3];
  int unsigned zero_orders[3], unit_orders[3];
  int unsigned wide_sums = 0, sqrt_exact = 0, sqrt_floor = 0, clamps = 0, dispersion_zero = 0;
  int unsigned rotation_relations = 0, low_bits_relations = 0, permutation_relations = 0;
  int unsigned hold_relations = 0;
  bit done = 0;

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable(1'b0), .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30(256'd0), .retained_state,
    .switch_activity, .scheduler_state,
    .phase_word_q(outputs.phase_bank), .frequency_current_q16(outputs.frequency_bank),
    .coupling_field_q16(outputs.coupling), .phase_projection_q30(outputs.projection),
    .phase_target(outputs.target), .pair_coherence_q30(outputs.pair_order),
    .cluster_coherence_q30(outputs.cluster_order), .global_coherence_q30(outputs.global_order),
    .organization_dispersion_q30(outputs.dispersion)
  );

  initial begin #10000; $fatal(1, "Phase order boundary watchdog"); end

  function automatic logic [31:0] next_word;
    random_word = random_word * 32'd1664525 + 32'd1013904223;
    return random_word;
  endfunction

  function automatic wide_t rounded(input wide_t value, input int unsigned denominator);
    wide_t quotient, remainder;
    quotient = value / wide_t'(denominator);
    remainder = value % wide_t'(denominator);
    if (2 * remainder >= wide_t'(denominator)) quotient++;
    if (2 * remainder <= -wide_t'(denominator)) quotient--;
    return quotient;
  endfunction

  function automatic wide_t mean_component(input wide_t value, input int unsigned population);
    wide_t remainder;
    int row, bin_index;
    if (value < -128'sd2147483648 || value > 128'sd2147483647) wide_sums++;
    row = population == 2 ? 0 : population == 4 ? 1 : 2;
    remainder = (value < 0 ? -value : value) % wide_t'(population);
    bin_index = 0;
    if (remainder != 0) begin
      bin_index = value < 0 ? 4 : 1;
      if (2 * remainder == wide_t'(population)) bin_index++;
      if (2 * remainder > wide_t'(population)) bin_index += 2;
    end
    mean_bins[row][bin_index]++;
    return rounded(value, population);
  endfunction

  function automatic logic signed [31:0] order_for(input int first, population);
    wide_t sum_cos, sum_sin, mean_cos, mean_sin, square, lower, upper, midpoint;
    int address;
    sum_cos = 0; sum_sin = 0;
    for (int i = first; i < first + population; i++) begin
      address = int'(model_phase[i*32 +: 32] >> 20);
      sum_cos += wide_t'(sine_reference[(address + 1024) % 4096]);
      sum_sin += wide_t'(sine_reference[address]);
    end
    mean_cos = mean_component(sum_cos, population);
    mean_sin = mean_component(sum_sin, population);
    square = mean_cos * mean_cos + mean_sin * mean_sin;
    // Binary search with 128-bit squares, independent of the DUT bit-trial root.
    lower = 0; upper = 128'sd4294967296;
    while (upper - lower > 1) begin
      midpoint = (lower + upper) / 2;
      if (midpoint * midpoint <= square) lower = midpoint;
      else upper = midpoint;
    end
    if (lower * lower > square || (lower + 1) * (lower + 1) <= square)
      $fatal(1, "Invalid reference integer-root bounds");
    if (lower * lower == square) sqrt_exact++;
    else sqrt_floor++;
    if (lower > 128'sd1073741824) begin clamps++; return 32'sd1073741824; end
    return lower[31:0];
  endfunction

  task automatic predict_outputs;
    wide_t pair_sum, cluster_sum, difference;
    logic signed [31:0] first_cluster, second_cluster, sine_value;
    int address;
    expected = '0;
    expected.phase_bank = model_phase;
    expected.frequency_bank = model_frequency;
    for (int i = 0; i < 8; i++) begin
      address = int'(model_phase[i*32 +: 32] >> 20);
      sine_value = sine_reference[address];
      expected.projection[i*32 +: 32] = sine_value;
      if (sine_value > 354334802) begin expected.target[i*2 +: 2] = 2'b01; target_bins[2]++; end
      else if (sine_value < -354334802) begin expected.target[i*2 +: 2] = 2'b11; target_bins[0]++; end
      else target_bins[1]++;
    end
    pair_sum = 0;
    for (int group = 0; group < 4; group++) pair_sum += wide_t'(order_for(group*2, 2));
    first_cluster = order_for(0, 4); second_cluster = order_for(4, 4);
    cluster_sum = wide_t'(first_cluster) + wide_t'(second_cluster);
    difference = wide_t'(first_cluster) - wide_t'(second_cluster);
    if (difference < 0) difference = -difference;
    expected.pair_order = 32'(rounded(pair_sum, 4));
    expected.cluster_order = 32'(rounded(cluster_sum, 2));
    expected.global_order = order_for(0, 8);
    expected.dispersion = 32'(rounded(difference, 2));
  endtask

  task automatic compare_word(input string field_name, input logic [255:0] actual, wanted);
    checks++;
    if ($isunknown({actual, wanted}) || actual !== wanted)
      $fatal(1, "Phase order mismatch stage=%0d vector=%0d field=%s actual=%h expected=%h",
             stage, vectors, field_name, actual, wanted);
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic sample(input bit load_request);
    if (stage >= 6 || clk !== 1'b0) $fatal(1, "Invalid phase order driver state");
    load_valid = load_request;
    for (int i = 0; i < 8; i++) begin
      frequency_load_q16[i*32 +: 32] = next_word() ^ 32'(vectors);
      gamma_effective_word[i*32 +: 32] = next_word();
    end
    retained_state = 16'(vectors);
    switch_activity = 8'(vectors >> 3);
    scheduler_state = frp_m31_pkg::frp_m31_scheduler_state_e'(vectors % 8);
    scheduler_bins[vectors % 8]++;
    if (!rst_n) begin
      for (int i = 0; i < 8; i++) begin
        model_phase[i*32 +: 32] = 32'(i) << 29;
        model_frequency[i*32 +: 32] = 32'd65536;
      end
      resets++;
    end else if (load_request) begin
      model_phase = phase_load; model_frequency = frequency_load_q16; loads++;
    end else holds++;
    clk = 1;
    #1ps;
    predict_outputs();
    compare_word("phase", outputs.phase_bank, expected.phase_bank);
    compare_word("frequency", outputs.frequency_bank, expected.frequency_bank);
    compare_word("coupling", outputs.coupling, expected.coupling);
    compare_word("projection", outputs.projection, expected.projection);
    compare_word("target", 256'(outputs.target), 256'(expected.target));
    compare_word("pair", 256'(outputs.pair_order), 256'(expected.pair_order));
    compare_word("cluster", 256'(outputs.cluster_order), 256'(expected.cluster_order));
    compare_word("global", 256'(outputs.global_order), 256'(expected.global_order));
    compare_word("dispersion", 256'(outputs.dispersion), 256'(expected.dispersion));
    if (outputs.pair_order == 0) zero_orders[0]++;
    if (outputs.cluster_order == 0) zero_orders[1]++;
    if (outputs.global_order == 0) zero_orders[2]++;
    if (outputs.pair_order == 1073741824) unit_orders[0]++;
    if (outputs.cluster_order == 1073741824) unit_orders[1]++;
    if (outputs.global_order == 1073741824) unit_orders[2]++;
    if (outputs.dispersion == 0) dispersion_zero++;
    output_ones |= outputs; output_zeros |= ~outputs;
    hash_word(stage); hash_word({27'b0, rst_n, load_valid, scheduler_state});
    hash_word({8'b0, retained_state, switch_activity});
    for (int i = 0; i < 8; i++) begin
      hash_word(phase_load[i*32 +: 32]); hash_word(frequency_load_q16[i*32 +: 32]);
      hash_word(gamma_effective_word[i*32 +: 32]);
    end
    for (int i = 0; i < 8; i++) begin
      hash_word(outputs.phase_bank[i*32 +: 32]); hash_word(outputs.frequency_bank[i*32 +: 32]);
      hash_word(outputs.coupling[i*32 +: 32]); hash_word(outputs.projection[i*32 +: 32]);
    end
    hash_word({16'b0, outputs.target}); hash_word(outputs.pair_order);
    hash_word(outputs.cluster_order); hash_word(outputs.global_order); hash_word(outputs.dispersion);
    vectors++; stage_counts[stage]++;
    clk = 0;
    #1ps;
  endtask

  task automatic random_bank(output logic [255:0] bank);
    for (int i = 0; i < 8; i++) bank[i*32 +: 32] = next_word();
  endtask

  task automatic finish_stage;
    if (stage_counts[stage] != EXPECTED_COUNTS[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Phase order stage mismatch stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
    $display("FRP_M31_PHASE_ORDER_BOUNDARY_STAGE: PASS stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
    stage++;
  endtask

  initial begin : qualification
    real scaled;
    int address;
    logic [255:0] base_bank;
    logic [127:0] base_orders;
    logic [399:0] base_projection_orders;
    outputs_t held_outputs;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (mean_bins[r, k]) mean_bins[r][k] = 0;
    foreach (scheduler_bins[k]) scheduler_bins[k] = 0;
    foreach (target_bins[k]) begin target_bins[k] = 0; zero_orders[k] = 0; unit_orders[k] = 0; end
    if ($bits(outputs) != 1168) $fatal(1, "Phase order output width mismatch");
    for (int k = 0; k < 4096; k++) begin
      scaled = $sin(6.283185307179586476925286766559 * real'(k) / 4096.0) * 1073741824.0;
      sine_reference[k] = $rtoi(scaled < 0 ? scaled - 0.5 : scaled + 0.5);
    end
    rst_n = 0; sample(0); rst_n = 1;
    // Four cardinal phases per cell: every one of the 4^8 labelled banks.
    for (int code = 0; code < 65536; code++) begin
      for (int i = 0; i < 8; i++)
        phase_load[i*32 +: 32] = (32'((code >> (2*i)) & 3) << 30)
          | ((32'(code) ^ (32'(i) * 32'd127267)) & 32'h000fffff);
      sample(1);
    end
    finish_stage();

    // Full LUT separation sweep in four distinct pair/cluster arrangements.
    for (int profile = 0; profile < 4; profile++)
      for (int distance = 0; distance < 4096; distance++) begin
        for (int i = 0; i < 8; i++) begin
          case (profile)
            0: address = i % 2 ? distance : 0;
            1: address = (i / 2) * 1024 + (i % 2 ? distance : 0);
            2: address = i >= 4 && i % 2 ? distance : 0;
            default: address = distance * (2*i+1) + i*137;
          endcase
          phase_load[i*32 +: 32] = (32'(address & 4095) << 20) | LOW_BITS[i % 4];
        end
        sample(1);
      end
    finish_stage();

    for (int bank = 0; bank < 512; bank++) begin
      random_bank(base_bank);
      for (int rotation = 0; rotation < 4; rotation++) begin
        for (int i = 0; i < 8; i++)
          phase_load[i*32 +: 32] = base_bank[i*32 +: 32] + (32'(rotation) << 30);
        sample(1);
        if (rotation == 0) base_orders = outputs[127:0];
        else begin
          if (outputs[127:0] !== base_orders) $fatal(1, "Quarter-turn order invariance failed");
          rotation_relations++;
        end
      end
    end
    finish_stage();

    for (int bank = 0; bank < 256; bank++) begin
      random_bank(base_bank);
      for (int variant = 0; variant < 4; variant++) begin
        for (int i = 0; i < 8; i++)
          phase_load[i*32 +: 32] = (base_bank[i*32 +: 32] & 32'hfff00000) | LOW_BITS[variant];
        sample(1);
        if (variant == 0) base_projection_orders = outputs[399:0];
        else begin
          if (outputs[399:0] !== base_projection_orders) $fatal(1, "Low phase-bit invariance failed");
          low_bits_relations++;
        end
      end
    end
    finish_stage();

    // XOR relabelling preserves each dyadic pair and cluster partition.
    for (int bank = 0; bank < 256; bank++) begin
      random_bank(base_bank);
      for (int permutation = 0; permutation < 8; permutation++) begin
        for (int i = 0; i < 8; i++) phase_load[i*32 +: 32] = base_bank[(i^permutation)*32 +: 32];
        sample(1);
        if (permutation == 0) base_orders = outputs[127:0];
        else begin
          if (outputs[127:0] !== base_orders) $fatal(1, "Dyadic relabelling invariance failed");
          permutation_relations++;
        end
      end
    end
    finish_stage();

    for (int bank = 0; bank < 1024; bank++) begin
      random_bank(base_bank); phase_load = base_bank; sample(1);
      held_outputs = outputs;
      phase_load = ~base_bank; sample(0);
      if (outputs !== held_outputs) $fatal(1, "Disabled load changed phase order outputs");
      hold_relations++;
    end
    finish_stage();

    foreach (mean_bins[r, k])
      if (mean_bins[r][k] != EXPECTED_MEANS[r][k])
        $fatal(1, "Phase order mean coverage mismatch population=%0d bin=%0d actual=%0d",
               2 << r, k, mean_bins[r][k]);
    foreach (scheduler_bins[k])
      if (scheduler_bins[k] != (k == 0 ? 11137 : 11136))
        $fatal(1, "Phase order scheduler-input coverage mismatch code=%0d", k);
    foreach (target_bins[k])
      if (target_bins[k] != EXPECTED_TARGETS[k] || zero_orders[k] != EXPECTED_ZERO[k]
          || unit_orders[k] != EXPECTED_UNIT[k])
        $fatal(1, "Phase order target or endpoint coverage mismatch bin=%0d", k);
    if (stage != 6 || vectors != 89089 || checks != 801801 || checks != 9 * vectors
        || loads != 88064 || holds != 1024 || resets != 1 || loads + holds + resets != vectors
        || rotation_relations != 1536 || low_bits_relations != 768
        || permutation_relations != 1792 || hold_relations != 1024
        || wide_sums != 168788 || sqrt_exact != 221593 || sqrt_floor != 402030
        || sqrt_exact + sqrt_floor != 7 * vectors || clamps != 0 || dispersion_zero != 27066)
      $fatal(1, "Phase order boundary totals incomplete");
    if ((output_ones & output_zeros) !==
        {{512{1'b1}}, 256'b0, {272{1'b1}}, 32'h7fffffff, 32'h7fffffff, 32'h7fffffff, 32'h3fffffff}
        || signature !== 64'h540a693ef2011a97)
      $fatal(1, "Phase order boundary bit coverage or final signature mismatch");
    for (int row = 0; row < 3; row++)
      $display("FRP_M31_PHASE_ORDER_BOUNDARY_MEAN: PASS population=%0d exact=%0d positive_below=%0d positive_half=%0d positive_above=%0d negative_below=%0d negative_half=%0d negative_above=%0d",
               2 << row, mean_bins[row][0], mean_bins[row][1], mean_bins[row][2], mean_bins[row][3],
               mean_bins[row][4], mean_bins[row][5], mean_bins[row][6]);
    done = 1;
    $display("FRP_M31_PHASE_ORDER_BOUNDARY_TB: PASS stages=%0d vectors=%0d checks=%0d loads=%0d holds=%0d resets=%0d cardinal_banks=65536 separation_cases=16384 rotation_relations=%0d low_bits_relations=%0d permutation_relations=%0d hold_relations=%0d wide_sums=%0d sqrt_exact=%0d sqrt_floor=%0d clamps=%0d pair_zero=%0d pair_one=%0d cluster_zero=%0d cluster_one=%0d global_zero=%0d global_one=%0d dispersion_zero=%0d target_negative=%0d target_zero=%0d target_positive=%0d output_bits=1168 output_exercised=%0d signature=%h",
             stage, vectors, checks, loads, holds, resets, rotation_relations, low_bits_relations,
             permutation_relations, hold_relations, wide_sums, sqrt_exact, sqrt_floor, clamps,
             zero_orders[0], unit_orders[0], zero_orders[1], unit_orders[1], zero_orders[2], unit_orders[2],
             dispersion_zero, target_bins[0], target_bins[1], target_bins[2],
             $countones(output_ones & output_zeros), signature);
    #1ps;
    $finish;
  end
endmodule : frp_m31_phase_order_boundary_tb
`endif

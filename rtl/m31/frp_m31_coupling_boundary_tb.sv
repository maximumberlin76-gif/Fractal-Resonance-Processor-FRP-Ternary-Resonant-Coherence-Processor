// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 coupling arithmetic boundaries. Author: Alchimist.
// Build from the repository root with --binary --timing --assert -Irtl/m31
// and --top-module frp_m31_coupling_boundary_tb.
// All nine public outputs are checked using independent 128-bit arithmetic,
// analytic sine samples and binary-search integer roots. Expected values do
// not read DUT helpers, internal state or ROM data. Counts and signatures
// are independently predicted by a Python arbitrary-integer oracle.
// Stages 0-4 use thermal factors in [0, Q30 one]; stage 5 separately probes
// raw signed-port limits and saturation, without claiming physical meaning.
// Tick stays disabled. This qualifies loaded/held coupling and geometry,
// not phase recurrence, scheduler cadence, full-core reachable states,
// physical hardware or equivalence to model v0.9.3. Targets are observations,
// not executed ternary transitions. All 4096 relative LUT addresses are
// covered for all 56 directed edges; this is not exhaustive input coverage.

`ifndef FRP_M31_COUPLING_BOUNDARY_TB_SV
`define FRP_M31_COUPLING_BOUNDARY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"

package frp_m31_coupling_boundary_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic [255:0] phase_bank, frequency_bank, coupling, projection;
    logic [15:0] target;
    logic signed [31:0] pair_order, cluster_order, global_order, dispersion;
  } outputs_t;
endpackage

module frp_m31_coupling_boundary_tb;
  import frp_m31_coupling_boundary_tb_pkg::*;
  localparam int unsigned EXPECTED_COUNTS [0:5] = '{2241, 32769, 8960, 14336, 4096, 5640};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'ha934bff9a4040fe7,
    64'h63c9decb64f3f7a4,
    64'hc06ee89cab3825fe,
    64'ha9acc27ddfc9ba0e,
    64'h1d06b40a7bb098e4,
    64'hd76b2702931c48af
  };
  localparam int unsigned EXPECTED_ROUNDING [0:4][0:6] = '{
    '{2942576, 403206, 2464, 403408, 29434, 0, 29264},
    '{1111188, 1583032, 1648, 1064134, 25450, 0, 24900},
    '{1129559, 658490, 0, 625403, 584250, 0, 812650},
    '{141081, 132763, 0, 105607, 124339, 5, 40541},
    '{151017, 122102, 1, 111346, 72404, 1, 87465}
  };
  localparam int unsigned EXPECTED_SATURATIONS [0:5][0:1] = '{
    '{10022, 9468},
    '{0, 0},
    '{0, 0},
    '{0, 0},
    '{0, 0},
    '{16, 0}
  };
  localparam int unsigned EXPECTED_SIGNS [0:2] = '{159692, 151377, 233267};
  localparam logic [31:0] PHASE_CASES [0:7] = '{32'h00000000, 32'h00000001, 32'h3fffffff, 32'h40000000, 32'h80000000, 32'hbfffffff, 32'hc0000000, 32'hffffffff};
  localparam logic [31:0] ATTENUATIONS [0:4] = '{32'h40000000, 32'h3fffffff, 32'h20000000, 32'h00004000, 32'h00000001};
  localparam logic [31:0] NORMAL_FACTORS [0:15] = '{32'h00000000, 32'h00000001, 32'h00000002, 32'h00003fff, 32'h00004000, 32'h00004001, 32'h00007fff, 32'h00008000, 32'h00008001, 32'h1fffffff, 32'h20000000, 32'h20000001, 32'h30000000, 32'h3ffffffe, 32'h3fffffff, 32'h40000000};
  localparam logic [31:0] RAW_FACTORS [0:7] = '{32'h80000000, 32'h80000001, 32'hc0000000, 32'hffffffff, 32'h00000000, 32'h00000001, 32'h40000000, 32'h7fffffff};
  localparam logic [31:0] UNIFORM_RAW [0:3] = '{32'h80000000, 32'h7fffffff, 32'hc0000000, 32'h40000000};

  logic clk = 0, rst_n = 1, load_valid = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0, thermal_node_factor_q30 = 0;
  logic [15:0] retained_state = 0;
  logic [7:0] switch_activity = 0;
  frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state = frp_m31_pkg::FRP_SCHED_FREE;
  outputs_t outputs, expected, previous_outputs;
  logic [255:0] model_phase = 0, model_frequency = 0;
  logic signed [31:0] sine_reference[4096];
  logic [4095:0] address_seen[8][8];
  logic [31:0] random_word = 31013;
  logic [63:0] signature = 64'hcbf29ce484222325;
  logic [1167:0] output_ones = '0, output_zeros = '0;
  int unsigned stage = 0, vectors = 0, checks = 0, loads = 0, holds = 0, resets = 0;
  int unsigned locality_checks = 0, phase_gamma_wraps = 0, pair_terms = 0;
  int unsigned stage_counts[6], rounding_bins[5][7], saturations[6][2];
  int unsigned scheduler_bins[8], coupling_signs[3];
  logic [7:0] swept_positive = 0, swept_negative = 0;
  bit done = 0;

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable(1'b0), .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30, .retained_state,
    .switch_activity, .scheduler_state,
    .phase_word_q(outputs.phase_bank), .frequency_current_q16(outputs.frequency_bank),
    .coupling_field_q16(outputs.coupling), .phase_projection_q30(outputs.projection),
    .phase_target(outputs.target), .pair_coherence_q30(outputs.pair_order),
    .cluster_coherence_q30(outputs.cluster_order), .global_coherence_q30(outputs.global_order),
    .organization_dispersion_q30(outputs.dispersion)
  );

  initial begin #10000; $fatal(1, "Coupling boundary watchdog"); end

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

  function automatic wide_t saturate(input wide_t value, input int row);
    if (value > 128'sd2147483647) begin saturations[row][0]++; return 128'sd2147483647; end
    if (value < -128'sd2147483648) begin saturations[row][1]++; return -128'sd2147483648; end
    return value;
  endfunction

  function automatic wide_t scale(input wide_t value, input int unsigned denominator, row);
    wide_t remainder;
    int bin_index;
    remainder = (value < 0 ? -value : value) % wide_t'(denominator);
    bin_index = 0;
    if (remainder != 0) begin
      bin_index = value < 0 ? 4 : 1;
      if (2 * remainder == wide_t'(denominator)) bin_index++;
      if (2 * remainder > wide_t'(denominator)) bin_index += 2;
    end
    rounding_bins[row][bin_index]++;
    return saturate(rounded(value, denominator), int'(row));
  endfunction

  function automatic logic signed [31:0] order_for(input int first, population);
    wide_t sum_cos, sum_sin, x, y, square, lower, upper, midpoint;
    int address;
    sum_cos = 0; sum_sin = 0;
    for (int i = first; i < first + population; i++) begin
      address = int'(model_phase[i*32 +: 32] >> 20);
      sum_cos += wide_t'(sine_reference[(address + 1024) % 4096]);
      sum_sin += wide_t'(sine_reference[address]);
    end
    x = rounded(sum_cos, population); y = rounded(sum_sin, population);
    square = x*x + y*y;
    lower = 0; upper = 128'sd4294967296;
    while (upper - lower > 1) begin
      midpoint = (lower + upper) / 2;
      if (midpoint * midpoint <= square) lower = midpoint;
      else upper = midpoint;
    end
    if (lower * lower > square || (lower + 1) * (lower + 1) <= square)
      $fatal(1, "Invalid reference integer-root bounds");
    return lower > 128'sd1073741824 ? 32'sd1073741824 : lower[31:0];
  endfunction

  task automatic predict_outputs(input int local_receiver);
    wide_t total, factor, weight, weighted, relative, phase_gamma;
    wide_t pair_sum, cluster_sum, difference, value;
    logic signed [31:0] first_cluster, second_cluster, sine_value;
    int address, distance;
    expected = '0;
    expected.phase_bank = model_phase;
    expected.frequency_bank = model_frequency;
    for (int i = 0; i < 8; i++) begin
      address = int'(model_phase[i*32 +: 32] >> 20);
      sine_value = sine_reference[address];
      expected.projection[i*32 +: 32] = sine_value;
      if (sine_value > 354334802) expected.target[i*2 +: 2] = 2'b01;
      else if (sine_value < -354334802) expected.target[i*2 +: 2] = 2'b11;
      if (stage < 5 && ($signed(thermal_node_factor_q30[i*32 +: 32]) < 0
                       || thermal_node_factor_q30[i*32 +: 32] > 32'd1073741824))
        $fatal(1, "Normal thermal factor outside [0, Q30 one]");
      total = 0;
      phase_gamma = wide_t'({1'b0, model_phase[i*32 +: 32]})
                  + wide_t'({1'b0, gamma_effective_word[i*32 +: 32]});
      if (phase_gamma > 128'sd4294967295) phase_gamma_wraps++;
      for (int j = 0; j < 8; j++) begin
        if (i == j) continue;
        factor = scale(wide_t'($signed(thermal_node_factor_q30[i*32 +: 32]))
                     * wide_t'($signed(thermal_node_factor_q30[j*32 +: 32])), 1073741824, 0);
        // Shells are equivalence classes in the dyadic eight-cell topology.
        distance = i ^ j;
        case (distance)
          1: weight = 516461574;
          2, 3: weight = 158959695;
          default: weight = 59840215;
        endcase
        weighted = scale(weight * factor, 1073741824, 1);
        // Reduce the full difference modulo 2^32 before selecting the LUT bin.
        relative = (wide_t'({1'b0, model_phase[j*32 +: 32]}) - phase_gamma)
                   % 128'sd4294967296;
        if (relative < 0) relative += 128'sd4294967296;
        address = int'(relative / 128'sd1048576);
        if (i == local_receiver) address_seen[i][j][address] = 1'b1;
        total += scale(weighted * wide_t'(sine_reference[address]), 1073741824, 2);
        pair_terms++;
      end
      value = scale(scale(saturate(total, 5), 16384, 3) * 128'sd18350, 65536, 4);
      expected.coupling[i*32 +: 32] = value[31:0];
      if (i == local_receiver && value > 0) swept_positive[i] = 1'b1;
      if (i == local_receiver && value < 0) swept_negative[i] = 1'b1;
      coupling_signs[value < 0 ? 0 : value > 0 ? 2 : 1]++;
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
      $fatal(1, "Coupling mismatch stage=%0d vector=%0d field=%s actual=%h expected=%h",
             stage, vectors, field_name, actual, wanted);
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic sample(input bit load_request, input int local_receiver = -1);
    outputs_t isolated_current, isolated_previous;
    if (stage >= 6 || clk !== 1'b0) $fatal(1, "Invalid coupling driver state");
    load_valid = load_request;
    for (int i = 0; i < 8; i++) frequency_load_q16[i*32 +: 32] = next_word() ^ 32'(vectors);
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
    predict_outputs(local_receiver);
    compare_word("phase", outputs.phase_bank, expected.phase_bank);
    compare_word("frequency", outputs.frequency_bank, expected.frequency_bank);
    compare_word("coupling", outputs.coupling, expected.coupling);
    compare_word("projection", outputs.projection, expected.projection);
    compare_word("target", 256'(outputs.target), 256'(expected.target));
    compare_word("pair", 256'(outputs.pair_order), 256'(expected.pair_order));
    compare_word("cluster", 256'(outputs.cluster_order), 256'(expected.cluster_order));
    compare_word("global", 256'(outputs.global_order), 256'(expected.global_order));
    compare_word("dispersion", 256'(outputs.dispersion), 256'(expected.dispersion));
    if (local_receiver >= 0) begin
      if (stage != 1 || load_request || local_receiver > 7) $fatal(1, "Invalid locality sample");
      isolated_current = outputs; isolated_previous = previous_outputs;
      isolated_current.coupling[local_receiver*32 +: 32] = 0;
      isolated_previous.coupling[local_receiver*32 +: 32] = 0;
      if (isolated_current !== isolated_previous) $fatal(1, "Gamma changed another receiver or held geometry");
      locality_checks++;
    end
    previous_outputs = outputs;
    output_ones |= outputs; output_zeros |= ~outputs;
    hash_word(stage); hash_word({27'b0, rst_n, load_valid, scheduler_state});
    hash_word({8'b0, retained_state, switch_activity});
    for (int i = 0; i < 8; i++) begin
      hash_word(phase_load[i*32 +: 32]); hash_word(frequency_load_q16[i*32 +: 32]);
      hash_word(gamma_effective_word[i*32 +: 32]); hash_word(thermal_node_factor_q30[i*32 +: 32]);
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

  task automatic finish_stage;
    if (stage_counts[stage] != EXPECTED_COUNTS[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Coupling stage mismatch stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
    $display("FRP_M31_COUPLING_BOUNDARY_STAGE: PASS stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
    stage++;
  endtask

  task automatic isolated_pair(input int i, j, input logic [31:0] phase_j, factor_i, factor_j);
    phase_load = 0; phase_load[j*32 +: 32] = phase_j;
    gamma_effective_word = 0; thermal_node_factor_q30 = 0;
    thermal_node_factor_q30[i*32 +: 32] = factor_i;
    thermal_node_factor_q30[j*32 +: 32] = factor_j;
  endtask

  initial begin : qualification
    real scaled;
    int address;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (rounding_bins[r, k]) rounding_bins[r][k] = 0;
    foreach (saturations[r, k]) saturations[r][k] = 0;
    foreach (scheduler_bins[k]) scheduler_bins[k] = 0;
    foreach (coupling_signs[k]) coupling_signs[k] = 0;
    foreach (address_seen[i, j]) address_seen[i][j] = 0;
    if ($bits(outputs) != 1168) $fatal(1, "Coupling output width mismatch");
    for (int k = 0; k < 4096; k++) begin
      scaled = $sin(6.283185307179586476925286766559 * real'(k) / 4096.0) * 1073741824.0;
      sine_reference[k] = scaled < 0.0 ? -$rtoi(-scaled + 0.5) : $rtoi(scaled + 0.5);
    end
    sine_reference[0] = 0; sine_reference[1024] = 1073741824;
    sine_reference[2048] = 0; sine_reference[3072] = -1073741824;
    rst_n = 0; sample(0); rst_n = 1;

    // Stage 0: every directed topology edge, sign/address boundary and attenuation.
    for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) begin
      if (i == j) continue;
      foreach (PHASE_CASES[p]) foreach (ATTENUATIONS[t]) begin
        isolated_pair(i, j, PHASE_CASES[p], ATTENUATIONS[t], 32'h40000000);
        sample(1);
      end
    end
    finish_stage();

    // Stage 1: local gamma sweeps all 4096 relative addresses of every directed edge.
    for (int i = 0; i < 8; i++) begin
      phase_load[i*32 +: 32] = 32'h12345678 + 32'(i)*32'h23456789;
      gamma_effective_word[i*32 +: 32] = 32'(i+1)*32'h17ab0001;
      thermal_node_factor_q30[i*32 +: 32] = 32'h40000000 - 32'(i)*32'h04000000;
    end
    sample(1);
    for (int i = 0; i < 8; i++) for (int a = 0; a < 4096; a++) begin
      gamma_effective_word[i*32 +: 32] = (32'(a) << 20) | 32'h0005a55a;
      phase_load = ~phase_load;
      sample(0, i);
    end
    finish_stage();

    // Stage 2: +/- two phase-word units around selected relative LUT boundaries.
    for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) begin
      if (i == j) continue;
      for (int k = 0; k < 32; k++) begin
        for (int n = 0; n < 8; n++) begin
          phase_load[n*32 +: 32] = next_word();
          gamma_effective_word[n*32 +: 32] = next_word();
          thermal_node_factor_q30[n*32 +: 32] = 32'd268435456 + next_word() % 32'd805306369;
        end
        address = (k*127 + i*31 + j*17) % 4096;
        for (int delta = -2; delta <= 2; delta++) begin
          gamma_effective_word[i*32 +: 32] = phase_load[j*32 +: 32] - phase_load[i*32 +: 32]
                                          - (32'(address) << 20) - 32'(delta);
          sample(1);
        end
      end
    end
    finish_stage();

    // Stage 3: normal-domain factor cross-product on every directed edge.
    for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) begin
      if (i == j) continue;
      for (int a = 0; a < 16; a++) for (int b = 0; b < 16; b++) begin
        isolated_pair(i, j, (a+b)%2 == 0 ? 32'h40000000 : 32'hc0000000,
                      NORMAL_FACTORS[a], NORMAL_FACTORS[b]);
        sample(1);
      end
    end
    finish_stage();

    // Stage 4: dense normal factors, then changed combinational inputs with held banks.
    for (int k = 0; k < 2048; k++) begin
      for (int n = 0; n < 8; n++) begin
        phase_load[n*32 +: 32] = next_word();
        gamma_effective_word[n*32 +: 32] = next_word();
        thermal_node_factor_q30[n*32 +: 32] = next_word() % 32'd1073741825;
      end
      sample(1);
      phase_load = ~phase_load;
      for (int n = 0; n < 8; n++) thermal_node_factor_q30[n*32 +: 32] = next_word() % 32'd1073741825;
      gamma_effective_word[(k%8)*32 +: 32] = next_word();
      sample(0);
    end
    finish_stage();

    // Stage 5: signed-port diagnostics, not physical thermal factors or core reachability.
    for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) begin
      if (i == j) continue;
      for (int a = 0; a < 8; a++) for (int b = 0; b < 8; b++) begin
        isolated_pair(i, j, (a+b)%2 == 0 ? 32'h40000000 : 32'hc0000000,
                      RAW_FACTORS[a], RAW_FACTORS[b]);
        sample(1);
      end
    end
    foreach (UNIFORM_RAW[t]) for (int s = 0; s < 2; s++) begin
      phase_load = 0;
      gamma_effective_word = {8{s == 0 ? 32'hc0000000 : 32'h40000000}};
      thermal_node_factor_q30 = {8{UNIFORM_RAW[t]}};
      sample(1);
    end
    for (int k = 0; k < 2048; k++) begin
      for (int n = 0; n < 8; n++) begin
        phase_load[n*32 +: 32] = next_word();
        gamma_effective_word[n*32 +: 32] = next_word();
        thermal_node_factor_q30[n*32 +: 32] = next_word();
      end
      sample(1);
    end
    finish_stage();

    foreach (rounding_bins[r, k])
      if (rounding_bins[r][k] != EXPECTED_ROUNDING[r][k]) $fatal(1, "Coupling rounding coverage mismatch");
    foreach (saturations[r, k])
      if (saturations[r][k] != EXPECTED_SATURATIONS[r][k]) $fatal(1, "Coupling saturation coverage mismatch");
    foreach (coupling_signs[k])
      if (coupling_signs[k] != EXPECTED_SIGNS[k]) $fatal(1, "Coupling sign coverage mismatch");
    foreach (scheduler_bins[k])
      if (scheduler_bins[k] != (k < 2 ? 8506 : 8505)) $fatal(1, "Coupling scheduler input coverage mismatch");
    foreach (address_seen[i, j])
      if (address_seen[i][j] !== (i == j ? 4096'b0 : {4096{1'b1}}))
        $fatal(1, "Coupling address coverage incomplete receiver=%0d sender=%0d", i, j);
    if (stage != 6 || vectors != 68042 || checks != 612378 || loads != 33225
        || holds != 34816 || resets != 1 || locality_checks != 32768
        || phase_gamma_wraps != 250536 || pair_terms != 3810352
        || swept_positive !== 8'hff || swept_negative !== 8'hff)
      $fatal(1, "Coupling boundary totals incomplete");
    if ((output_ones & output_zeros) !==
        {{1040{1'b1}}, 32'h7fffffff, 32'h7fffffff, 32'h7fffffff, 32'h1fffffff}
        || signature !== 64'hd76b2702931c48af)
      $fatal(1, "Coupling output bit coverage or signature mismatch");
    for (int row = 0; row < 5; row++)
      $display("FRP_M31_COUPLING_BOUNDARY_ROUND: PASS operation=%0d exact=%0d positive_below=%0d positive_half=%0d positive_above=%0d negative_below=%0d negative_half=%0d negative_above=%0d saturated_positive=%0d saturated_negative=%0d",
               row, rounding_bins[row][0], rounding_bins[row][1], rounding_bins[row][2],
               rounding_bins[row][3], rounding_bins[row][4], rounding_bins[row][5],
               rounding_bins[row][6], saturations[row][0], saturations[row][1]);
    done = 1;
    $display("FRP_M31_COUPLING_BOUNDARY_TB: PASS stages=%0d vectors=%0d checks=%0d loads=%0d holds=%0d resets=%0d ordered_pairs=56 swept_addresses=229376 locality_checks=%0d phase_gamma_wraps=%0d pair_terms=%0d diagnostic_vectors=%0d total_saturated_positive=%0d total_saturated_negative=%0d coupling_negative=%0d coupling_zero=%0d coupling_positive=%0d output_bits=1168 output_exercised=%0d signature=%h",
             stage, vectors, checks, loads, holds, resets, locality_checks, phase_gamma_wraps,
             pair_terms, stage_counts[5], saturations[5][0], saturations[5][1],
             coupling_signs[0], coupling_signs[1], coupling_signs[2],
             $countones(output_ones & output_zeros), signature);
    #1ps;
    $finish;
  end
endmodule : frp_m31_coupling_boundary_tb
`endif

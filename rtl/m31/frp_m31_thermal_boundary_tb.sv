// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 thermal rounding, retention and control boundaries. Author: Alchimist.
// Build with --binary --timing --assert -Irtl/m31 and
// --top-module frp_m31_thermal_boundary_tb from the repository root.
// The oracle uses literal coefficients and signed 128-bit division/remainder;
// it never calls DUT helpers, reads internal state, or forces registers.
// All three public outputs are checked before and after each rising edge,
// after falling edges, and during asynchronous reset assertion and release.
// Costs outside [0,65536] are signed-interface diagnostics, not claims about
// reachable full-core activity. Temperature remains a normalized RC proxy.
// Separate product rounding, the zero-initialized peak, and nonzero cooling
// fixed points are preserved. Sample-count carries through bit 16 are tested;
// 32-bit counter rollover, full input/state coverage and physical heat are not.
// Expected signatures and counts also come from a Python arbitrary-integer
// oracle. Clock timing here schedules observations, not physical timing checks.

`ifndef FRP_M31_THERMAL_BOUNDARY_TB_SV
`define FRP_M31_THERMAL_BOUNDARY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_thermal_proxy.sv"

package frp_m31_thermal_boundary_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic signed [31:0] temperature, peak;
    logic [31:0] samples;
  } outputs_t;
endpackage

module frp_m31_thermal_boundary_tb;
  import frp_m31_thermal_boundary_tb_pkg::*;
  localparam int unsigned EXPECTED_CYCLES [0:6] =
    '{144, 196611, 196608, 216, 24588, 65541, 32770};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:6] = '{
    64'h7de57c7b58f4c12c, 64'h491f697fe39a148c, 64'hb2c6118f0c4e8a25,
    64'h83ad4b39ec0e196b, 64'h3ff3ff6737faa5d9, 64'hd2e7f48157cb7a04,
    64'h0247f52a740b51d9
  };
  localparam int unsigned EXPECTED_GAIN_BINS [0:6] = '{14366, 109624, 5, 49019, 36909, 4, 35770};
  localparam int unsigned EXPECTED_DECAY_BINS [0:6] = '{133544, 83824, 0, 18643, 4769, 0, 4917};
  localparam int unsigned EXPECTED_SIGNS [0:2] = '{75299, 2184, 168214};
  localparam logic signed [31:0] EDGES [0:19] = '{
    32'sh80000000, -2147483647, -1073741824, -65537, -65536,
    -51, -50, -49, -1, 0, 1, 49, 50, 51, 65535, 65536,
    65537, 1073741824, 2147483646, 2147483647
  };
  localparam logic signed [31:0] LOADS [0:11] = '{
    0, 8192, 16384, 24576, 32768, 40960, 49152, 57344, 65536,
    2147483647, 32'sh80000000, -65536
  };
  localparam logic signed [31:0] EXPECTED_HOT [0:11] = '{
    0, 1631, 3271, 4911, 6551, 8191, 9831, 11451, 13091,
    429496712, -429496712, -13091
  };
  localparam logic signed [31:0] EXPECTED_COOL [0:11] =
    '{0, 10, 10, 10, 10, 10, 10, 10, 10, 10, -10, -10};

  logic clk = 0, rst_n = 1, tick_enable = 0, clear = 0;
  logic signed [31:0] normalized_cycle_cost_q16 = 0;
  outputs_t outputs, expected = '0;
  int unsigned cycles = 0, observations = 0, checks = 0, stage = 0;
  int unsigned stage_counts[7], gain_bins[7], decay_bins[7], sign_bins[3];
  int unsigned control_bins[8], pulse_bins[8];
  int unsigned updates = 0, holds = 0, clear_edges = 0, reset_edges = 0;
  int unsigned async_pulses = 0, peak_changes = 0, diagnostic_updates = 0;
  int unsigned separate_rounding = 0, saturations = 0;
  int unsigned negative_fixed = 0, positive_fixed = 0;
  int unsigned normal_cases = 0, negative_cases = 0, rounding_cases = 0;
  int unsigned profiles = 0, long_ticks = 0, stream_ticks = 0;
  logic [34:0] input_ones = '0, input_zeros = '0;
  logic [95:0] output_ones = '0, output_zeros = '0;
  logic [63:0] signature = 64'hcbf29ce484222325;
  bit done = 0;

  frp_m31_thermal_proxy dut (
    .clk, .rst_n, .tick_enable, .clear, .normalized_cycle_cost_q16,
    .temperature_proxy_q16(outputs.temperature),
    .peak_temperature_proxy_q16(outputs.peak),
    .sample_count_q(outputs.samples)
  );

  initial begin #10000; $fatal(1, "Thermal boundary watchdog"); end

  function automatic wide_t rounded(input wide_t numerator);
    wide_t quotient, remainder;
    quotient = numerator / 128'sd1073741824;
    remainder = numerator % 128'sd1073741824;
    if (remainder >= 128'sd536870912) quotient++;
    if (remainder <= -128'sd536870912) quotient--;
    return quotient;
  endfunction

  function automatic logic signed [31:0] clip(input wide_t value);
    if (value > 128'sd2147483647) return 32'sh7fffffff;
    if (value < -128'sd2147483648) return 32'sh80000000;
    return value[31:0];
  endfunction

  // Bins: exact, positive below/at/above half, negative below/at/above half.
  function automatic int round_bin(input wide_t product);
    wide_t remainder;
    int result;
    remainder = (product < 0 ? -product : product) % 128'sd1073741824;
    if (remainder == 0) return 0;
    result = product < 0 ? 4 : 1;
    if (remainder == 128'sd536870912) result++;
    if (remainder > 128'sd536870912) result += 2;
    return result;
  endfunction

  function automatic logic [31:0] advance(input logic [31:0] value);
    logic [31:0] result;
    result = value ^ (value << 13);
    result = result ^ (result >> 17);
    return result ^ (result << 5);
  endfunction

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_word(input string field_name, input logic [31:0] actual, wanted);
    checks++;
    if ($isunknown({actual, wanted}) || actual !== wanted)
      $fatal(1, "Thermal boundary mismatch stage=%0d cycle=%0d observation=%0d field=%s actual=%h expected=%h controls=%b cost=%h",
             stage, cycles, observations, field_name, actual, wanted,
             {rst_n, clear, tick_enable}, normalized_cycle_cost_q16);
  endtask

  task automatic observe(input int unsigned kind);
    logic [34:0] inputs;
    inputs = {rst_n, clear, tick_enable, normalized_cycle_cost_q16};
    if ($isunknown({clk, inputs})) $fatal(1, "Unknown thermal stimulus");
    compare_word("temperature", outputs.temperature, expected.temperature);
    compare_word("peak", outputs.peak, expected.peak);
    compare_word("samples", outputs.samples, expected.samples);
    if (outputs.peak < 0 || outputs.peak < outputs.temperature)
      $fatal(1, "Thermal peak invariant failed");
    input_ones |= inputs; input_zeros |= ~inputs;
    output_ones |= outputs; output_zeros |= ~outputs;
    hash_word(kind); hash_word({29'b0, rst_n, clear, tick_enable});
    hash_word(normalized_cycle_cost_q16); hash_word(outputs.temperature);
    hash_word(outputs.peak); hash_word(outputs.samples);
    observations++;
  endtask

  task automatic predict_edge;
    wide_t decay_product, gain_product, total;
    logic signed [31:0] previous_temperature;
    if (!rst_n) begin
      expected = '0;
      reset_edges++;
    end else if (clear) begin
      expected = '0;
      clear_edges++;
    end else if (tick_enable) begin
      previous_temperature = expected.temperature;
      decay_product = wide_t'(previous_temperature) * 128'sd1020054733;
      gain_product = wide_t'(normalized_cycle_cost_q16) * 128'sd10737418;
      decay_bins[round_bin(decay_product)]++;
      gain_bins[round_bin(gain_product)]++;
      total = wide_t'(clip(rounded(decay_product))) + wide_t'(clip(rounded(gain_product)));
      expected.temperature = clip(total);
      if (total != wide_t'(expected.temperature)) saturations++;
      if (expected.temperature != clip(rounded(decay_product + gain_product))) separate_rounding++;
      if (normalized_cycle_cost_q16 < 0 || normalized_cycle_cost_q16 > 65536) diagnostic_updates++;
      if (expected.temperature < 0) sign_bins[0]++;
      else if (expected.temperature == 0) sign_bins[1]++;
      else sign_bins[2]++;
      if (normalized_cycle_cost_q16 == 0 && expected.temperature == previous_temperature) begin
        if (previous_temperature < 0) negative_fixed++;
        if (previous_temperature > 0) positive_fixed++;
      end
      if (expected.temperature > expected.peak) begin
        expected.peak = expected.temperature;
        peak_changes++;
      end
      expected.samples++;
      updates++;
    end else holds++;
  endtask

  task automatic pulse_reset;
    rst_n = 0;
    expected = '0;
    async_pulses++;
    #1ps; observe(3);
    rst_n = 1;
    #1ps; observe(4);
  endtask

  task automatic cycle(input bit reset_value, clear_value, tick_value,
      input logic signed [31:0] cost, input int unsigned pulse = 0);
    if (clk !== 1'b0 || stage >= 7 || pulse > 2 || (!reset_value && pulse != 0))
      $fatal(1, "Invalid thermal cycle driver state");
    rst_n = reset_value; clear = clear_value; tick_enable = tick_value;
    normalized_cycle_cost_q16 = cost;
    if (!rst_n) expected = '0;
    #1ps; observe(0);
    if (pulse == 1) pulse_reset();
    clk = 1;
    predict_edge();
    #1ps; observe(1);
    if (pulse == 2) pulse_reset();
    clk = 0;
    #1ps; observe(2);
    cycles++;
    stage_counts[stage]++;
  endtask

  task automatic prepare(input logic signed [31:0] seed);
    cycle(0, 0, 0, 0);
    cycle(1, 0, 1, seed);
  endtask

  task automatic cold_sample(input logic signed [31:0] cost, input bit check_hold);
    cycle(1, 1, 1, ~cost);
    cycle(1, 0, 1, cost);
    if (check_hold) cycle(1, 0, 0, ~cost);
  endtask

  task automatic finish_stage;
    if (stage_counts[stage] != EXPECTED_CYCLES[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Thermal stage mismatch stage=%0d cycles=%0d signature=%h expected=%h",
             stage, stage_counts[stage], signature, EXPECTED_SIGNATURES[stage]);
    $display("FRP_M31_THERMAL_BOUNDARY_STAGE: PASS stage=%0d cycles=%0d signature=%h",
             stage, stage_counts[stage], signature);
    stage++;
  endtask

  initial begin : qualification
    logic signed [31:0] seed, test_cost, hot;
    logic [31:0] word;
    bit reset_value;
    int unsigned pulse;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (gain_bins[k]) begin gain_bins[k] = 0; decay_bins[k] = 0; end
    foreach (sign_bins[k]) sign_bins[k] = 0;
    foreach (control_bins[k]) begin control_bins[k] = 0; pulse_bins[k] = 0; end
    if ($bits(outputs) != 96) $fatal(1, "Thermal output width mismatch");

    for (int seed_index = 0; seed_index < 3; seed_index++) begin
      seed = seed_index == 0 ? 0 : (seed_index == 1 ? 65536 : -65536);
      test_cost = seed >= 0 ? 32'sh80000000 : 32'sh7fffffff;
      for (int control = 0; control < 8; control++) begin
        prepare(seed);
        cycle(control[2], control[1], control[0], test_cost);
        control_bins[control]++;
      end
      for (int phase = 1; phase <= 2; phase++)
        for (int control = 0; control < 4; control++) begin
          prepare(seed);
          cycle(1, control[1], control[0], test_cost, phase);
          pulse_bins[(phase-1)*4 + control]++;
        end
    end
    finish_stage();

    for (int cost = 0; cost <= 65536; cost++) begin
      cold_sample(cost, 1);
      normal_cases++;
    end
    finish_stage();
    for (int magnitude = 1; magnitude <= 65536; magnitude++) begin
      cold_sample(-magnitude, 1);
      negative_cases++;
    end
    finish_stage();

    for (int sign_index = 0; sign_index < 2; sign_index++)
      for (int odd = 1; odd <= 7; odd += 2)
        for (int delta = -1; delta <= 1; delta++) begin
          test_cost = odd * 268435456 + delta;
          if (sign_index == 1) test_cost = -test_cost;
          cold_sample(test_cost, 0);
          rounding_cases++;
        end
    for (int bit_index = 0; bit_index < 32; bit_index++) begin
      cold_sample(32'(1) << bit_index, 0);
      cold_sample(~(32'(1) << bit_index), 0);
      rounding_cases += 2;
    end
    foreach (EDGES[k]) begin cold_sample(EDGES[k], 0); rounding_cases++; end
    finish_stage();

    foreach (LOADS[k]) begin
      cycle(1, 1, 1, LOADS[k]);
      for (int n = 0; n < 1024; n++) begin
        cycle(1, 0, 1, LOADS[k]);
        if (n >= 896 && outputs.temperature !== EXPECTED_HOT[k])
          $fatal(1, "Thermal heating plateau mismatch profile=%0d tick=%0d", k, n);
      end
      hot = outputs.temperature;
      for (int n = 0; n < 1024; n++) begin
        cycle(1, 0, 1, 0);
        if (n >= 896 && outputs.temperature !== EXPECTED_COOL[k])
          $fatal(1, "Thermal cooling plateau mismatch profile=%0d tick=%0d", k, n);
      end
      if (outputs.samples != 2048 || outputs.peak !== (EXPECTED_HOT[k] > 0 ? EXPECTED_HOT[k] : 0))
        $fatal(1, "Thermal profile count or peak mismatch profile=%0d", k);
      profiles++;
      $display("FRP_M31_THERMAL_BOUNDARY_PROFILE: PASS profile=%0d cost=%0d hot=%0d cool=%0d peak=%0d samples=%0d",
               k, LOADS[k], hot, outputs.temperature, outputs.peak, outputs.samples);
    end
    finish_stage();

    cycle(1, 1, 1, 65536);
    repeat (65538) begin cycle(1, 0, 1, 65536); long_ticks++; end
    cycle(1, 0, 0, 32'sh80000000);
    if (outputs.samples != 65538 || outputs.temperature != 13091 || outputs.peak != 13091)
      $fatal(1, "Thermal long-run counter or plateau mismatch");
    cycle(1, 1, 1, 32'sh7fffffff);
    finish_stage();

    for (int profile = 0; profile < 2; profile++) begin
      cycle(1, 1, 0, 0);
      word = 32'h6d2b79f5 + 32'(profile);
      for (int n = 0; n < 16384; n++) begin
        word = advance(word);
        test_cost = profile == 0 ? $signed(word % 32'd65537) : $signed(word);
        reset_value = n % 389 != 7;
        pulse = reset_value && n % 997 == 11 ? 1 + ((n / 997) % 2) : 0;
        cycle(reset_value, n % 257 == 3, word[1:0] != 0, test_cost, pulse);
        stream_ticks++;
      end
    end
    finish_stage();

    foreach (control_bins[k])
      if (control_bins[k] != 3 || pulse_bins[k] != 3) $fatal(1, "Thermal control matrix incomplete bin=%0d", k);
    foreach (gain_bins[k])
      if (gain_bins[k] != EXPECTED_GAIN_BINS[k] || decay_bins[k] != EXPECTED_DECAY_BINS[k])
        $fatal(1, "Thermal rounding coverage mismatch bin=%0d gain=%0d decay=%0d", k, gain_bins[k], decay_bins[k]);
    foreach (sign_bins[k])
      if (sign_bins[k] != EXPECTED_SIGNS[k]) $fatal(1, "Thermal sign coverage mismatch bin=%0d", k);
    if (stage != 7 || cycles != 516478 || observations != 1549550 || checks != 4648650
        || updates != 245697 || holds != 139292 || clear_edges != 131343 || reset_edges != 146
        || updates + holds + clear_edges + reset_edges != cycles || async_pulses != 58
        || observations != 3*cycles + 2*async_pulses || checks != 3*observations
        || peak_changes != 71610 || diagnostic_updates != 80894 || separate_rounding != 74466
        || saturations != 0 || negative_fixed != 1569 || positive_fixed != 7886
        || normal_cases != 65537 || negative_cases != 65536 || rounding_cases != 108
        || profiles != 12 || long_ticks != 65538 || stream_ticks != 32768)
      $fatal(1, "Thermal boundary totals incomplete");
    if ((input_ones & input_zeros) !== 35'h7ffffffff
        || (output_ones & output_zeros) !== 96'hffffffff1fffffff0001ffff
        || signature !== 64'h0247f52a740b51d9
        || outputs.temperature != 85020103 || outputs.peak != 85020103 || outputs.samples != 23)
      $fatal(1, "Thermal boundary final state, signature or bit coverage mismatch");
    done = 1;
    $display("FRP_M31_THERMAL_BOUNDARY_TB: PASS stages=%0d cycles=%0d observations=%0d checks=%0d updates=%0d holds=%0d clear_edges=%0d reset_edges=%0d async_pulses=%0d normal_cases=%0d negative_cases=%0d rounding_cases=%0d profiles=%0d long_ticks=%0d stream_ticks=%0d peak_changes=%0d diagnostic_updates=%0d separate_rounding=%0d gain_positive_ties=%0d gain_negative_ties=%0d negative_fixed=%0d positive_fixed=%0d saturations=%0d input_bits=35 output_bits=96 input_exercised=%0d output_exercised=%0d signature=%h",
             stage, cycles, observations, checks, updates, holds, clear_edges, reset_edges,
             async_pulses, normal_cases, negative_cases, rounding_cases, profiles, long_ticks,
             stream_ticks, peak_changes, diagnostic_updates, separate_rounding,
             gain_bins[2], gain_bins[5], negative_fixed, positive_fixed, saturations,
             $countones(input_ones & input_zeros), $countones(output_ones & output_zeros), signature);
    #1ps;
    $finish;
  end
endmodule : frp_m31_thermal_boundary_tb
`endif

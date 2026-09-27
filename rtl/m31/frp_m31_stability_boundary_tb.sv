// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 stability observer boundaries. Author: Alchimist.
// Build from the repository root with --binary --timing --assert,
// -Irtl/m31 and --top-module frp_m31_stability_boundary_tb.
// This stateless observer test does not drive execution-state transitions.
// All 65536 state-bank encodings include 6561 legal ternary banks; the other
// banks are diagnostic inputs. Encoding 00 alone contributes active zero.
// Normalized coherence and nonnegative pressure inputs are tested separately
// from signed interface diagnostics, which need not be reachable in the core.
// Pressure saturates to signed 32 bits; the margin is a modulo-2^32 signed
// subtraction, and stable means that wrapped margin is strictly positive.
// Preserve those implemented semantics, including diagnostic overflow cases.
// The independent oracle uses signed 128-bit division and remainder, with
// literal gains; it never calls DUT helpers or reads DUT internal signals.
// Fixed signatures and coverage counts were also calculated with Python
// arbitrary-size integers. This is not model or physical-system equivalence.

`ifndef FRP_M31_STABILITY_BOUNDARY_TB_SV
`define FRP_M31_STABILITY_BOUNDARY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_stability.sv"

package frp_m31_stability_boundary_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic [15:0] state_bank;
    logic signed [31:0] global_order, cluster_order, temperature, switch_load;
  } inputs_t;
  typedef struct packed {
    logic signed [31:0] capacity, pressure, margin;
    logic stable;
  } outputs_t;
endpackage

module frp_m31_stability_boundary_tb;
  import frp_m31_stability_boundary_tb_pkg::*;
  localparam logic signed [31:0] NORMAL [0:12] = '{
    0, 1, 268435455, 268435456, 268435457, 536870911, 536870912,
    536870913, 805306367, 805306368, 805306369, 1073741823, 1073741824
  };
  localparam logic signed [31:0] PRESSURE [0:13] = '{
    32'sh80000000, -2147483647, -1073741825, -1073741824, -65536, -1, 0,
    1, 65535, 65536, 1073741823, 1073741824, 2147483646, 2147483647
  };
  localparam logic signed [31:0] COHERENCE [0:13] = '{
    32'sh80000000, -1073741825, -1073741824, -805306368, -536870912,
    -268435456, -1, 0, 1, 268435456, 805306368, 1073741823,
    1073741824, 2147483647
  };
  localparam longint signed BOUNDARIES [0:2] = '{-2147483647, 0, 64'sd2147483648};
  localparam int EXPECTED_COUNTS [0:5] = '{65536, 4563, 1764, 15876, 4096, 8192};
  localparam logic [63:0] EXPECTED_SIGNATURES [0:5] = '{
    64'h229d24de44365d37, 64'hb1a535a763bde271, 64'h518ab8db267550d7,
    64'hecf46a8aea3d0b15, 64'hc598b2e8564266fd, 64'h0de3e2d82f831ac7
  };
  localparam int EXPECTED_NEUTRAL_BINS [0:8] = '{6561, 17496, 20412, 13608, 5670, 1512, 252, 24, 1};
  localparam int EXPECTED_MARGIN_SIGNS [0:2] = '{19258, 3287, 77482};

  inputs_t inputs = '0;
  outputs_t outputs;
  int unsigned vectors = 0, checks = 0, stage_counts[6];
  int unsigned valid_state_words = 0, reserved_state_words = 0, neutral_bins[9];
  int unsigned boundary_bins[3], margin_sign_counts[3];
  int unsigned pressure_high = 0, pressure_low = 0, margin_high_wraps = 0, margin_low_wraps = 0;
  int unsigned neutral_ties = 0, diagnostic_vectors = 0;
  bit [1:0] global_ties = 0, cluster_ties = 0;
  logic [143:0] input_ones = '0, input_zeros = '0;
  logic [96:0] output_ones = '0, output_zeros = '0;
  logic [63:0] signature = 64'hcbf29ce484222325;
  bit done = 0;

  frp_m31_stability #(.CELLS(8)) dut (
    .retained_state(inputs.state_bank),
    .global_coherence_q30(inputs.global_order),
    .cluster_coherence_q30(inputs.cluster_order),
    .temperature_proxy_q16(inputs.temperature),
    .switch_load_q16(inputs.switch_load),
    .coherence_capacity_q16(outputs.capacity),
    .pressure_q16(outputs.pressure),
    .stability_margin_q16(outputs.margin),
    .stable(outputs.stable)
  );

  function automatic int zero_count(input logic [15:0] bank);
    int result;
    result = 0;
    for (int k = 0; k < 8; k++) if (bank[2*k +: 2] == 2'b00) result++;
    return result;
  endfunction

  function automatic bit has_reserved(input logic [15:0] bank);
    for (int k = 0; k < 8; k++) if (bank[2*k +: 2] == 2'b10) return 1;
    return 0;
  endfunction

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

  function automatic logic signed [31:0] capacity_oracle(input logic [15:0] bank,
      input logic signed [31:0] global_value, cluster_value);
    wide_t fraction, capacity;
    fraction = (wide_t'(zero_count(bank)) * 128'sd1073741824) / 8;
    capacity = 128'sd53740 + rounded(128'sd22282 * wide_t'(global_value))
      + rounded(128'sd10486 * wide_t'(cluster_value)) + rounded(128'sd5243 * fraction);
    return clip(capacity);
  endfunction

  function automatic outputs_t predict(input inputs_t value);
    outputs_t expected;
    wide_t margin;
    expected.capacity = capacity_oracle(value.state_bank, value.global_order, value.cluster_order);
    expected.pressure = clip(wide_t'(value.temperature) + wide_t'(value.switch_load));
    margin = wide_t'(expected.capacity) - wide_t'(expected.pressure);
    if (margin > 128'sd2147483647) margin -= 128'sd4294967296;
    if (margin < -128'sd2147483648) margin += 128'sd4294967296;
    expected.margin = margin[31:0];
    expected.stable = margin > 0;
    return expected;
  endfunction

  function automatic logic [15:0] bank_with_zeros(input int zeros);
    logic [15:0] result;
    for (int k = 0; k < 8; k++)
      result[2*k +: 2] = k < zeros ? 2'b00 : (k % 2 == 0 ? 2'b01 : 2'b11);
    return result;
  endfunction

  function automatic logic [15:0] ternary_bank(input int unsigned number);
    logic [15:0] result;
    int unsigned remaining;
    remaining = number;
    for (int k = 0; k < 8; k++) begin
      case (remaining % 3)
        0: result[2*k +: 2] = 2'b00;
        1: result[2*k +: 2] = 2'b01;
        default: result[2*k +: 2] = 2'b11;
      endcase
      remaining /= 3;
    end
    return result;
  endfunction

  function automatic logic [31:0] advance(input logic [31:0] value);
    logic [31:0] result;
    result = value ^ (value << 13);
    result = result ^ (result >> 17);
    return result ^ (result << 5);
  endfunction

  function automatic bit is_tie(input wide_t numerator);
    wide_t magnitude;
    magnitude = numerator < 0 ? -numerator : numerator;
    return magnitude % 128'sd1073741824 == 128'sd536870912;
  endfunction

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  task automatic compare_word(input string field_name, input logic [63:0] actual, expected);
    checks++;
    if ($isunknown({actual, expected}) || actual !== expected)
      $fatal(1, "Stability mismatch vector=%0d field=%s actual=%h expected=%h inputs=%h",
             vectors, field_name, actual, expected, inputs);
  endtask

  task automatic drive(input int stage, input logic [15:0] bank,
      input logic signed [31:0] global_value, cluster_value, temperature, switch_load);
    outputs_t expected;
    wide_t pressure, margin, global_product, cluster_product, fraction;
    int zeros;
    if (stage < 0 || stage > 5) $fatal(1, "Stability stage outside the declared profile");
    inputs = '{bank, global_value, cluster_value, temperature, switch_load};
    expected = predict(inputs);
    #1ps;
    compare_word("capacity", 64'(outputs.capacity), 64'(expected.capacity));
    compare_word("pressure", 64'(outputs.pressure), 64'(expected.pressure));
    compare_word("margin", 64'(outputs.margin), 64'(expected.margin));
    compare_word("stable", {63'b0, outputs.stable}, {63'b0, expected.stable});
    vectors++; stage_counts[stage]++;
    input_ones |= inputs; input_zeros |= ~inputs;
    output_ones |= outputs; output_zeros |= ~outputs;
    hash_word({16'b0, bank}); hash_word(global_value); hash_word(cluster_value);
    hash_word(temperature); hash_word(switch_load); hash_word(outputs.capacity);
    hash_word(outputs.pressure); hash_word(outputs.margin); hash_word({31'b0, outputs.stable});

    zeros = zero_count(bank);
    if (stage == 0) begin
      neutral_bins[zeros]++;
      if (has_reserved(bank)) reserved_state_words++;
      else valid_state_words++;
    end
    if (stage == 1) begin
      if (expected.margin < -1 || expected.margin > 1)
        $fatal(1, "Stability boundary stimulus missed the intended margin");
      boundary_bins[int'(expected.margin) + 1]++;
    end
    if (expected.margin < 0) margin_sign_counts[0]++;
    else if (expected.margin == 0) margin_sign_counts[1]++;
    else margin_sign_counts[2]++;
    pressure = wide_t'(temperature) + wide_t'(switch_load);
    margin = wide_t'(expected.capacity) - wide_t'(expected.pressure);
    if (pressure > 128'sd2147483647) pressure_high++;
    if (pressure < -128'sd2147483648) pressure_low++;
    if (margin > 128'sd2147483647) margin_high_wraps++;
    if (margin < -128'sd2147483648) margin_low_wraps++;
    global_product = 128'sd22282 * wide_t'(global_value);
    cluster_product = 128'sd10486 * wide_t'(cluster_value);
    if (is_tie(global_product)) global_ties[global_product < 0] = 1;
    if (is_tie(cluster_product)) cluster_ties[cluster_product < 0] = 1;
    fraction = (wide_t'(zeros) * 128'sd1073741824) / 8;
    if (is_tie(128'sd5243 * fraction)) neutral_ties++;
    if (has_reserved(bank) || global_value < 0 || global_value > 1073741824
        || cluster_value < 0 || cluster_value > 1073741824 || temperature < 0 || switch_load < 0)
      diagnostic_vectors++;
  endtask

  task automatic finish_stage(input int stage);
    if (stage_counts[stage] != EXPECTED_COUNTS[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Stability stage mismatch stage=%0d count=%0d signature=%h expected=%0d/%h",
             stage, stage_counts[stage], signature, EXPECTED_COUNTS[stage], EXPECTED_SIGNATURES[stage]);
    $display("FRP_M31_STABILITY_BOUNDARY_STAGE: PASS stage=%0d vectors=%0d signature=%h",
             stage, stage_counts[stage], signature);
  endtask

  initial begin : qualification
    logic [15:0] bank;
    logic [31:0] random_word, random_values[5];
    longint signed capacity, pressure, temperature;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (neutral_bins[k]) neutral_bins[k] = 0;
    foreach (boundary_bins[k]) boundary_bins[k] = 0;
    foreach (margin_sign_counts[k]) margin_sign_counts[k] = 0;
    if ($bits(inputs) != 144 || $bits(outputs) != 97)
      $fatal(1, "Stability observer interface width mismatch");

    for (int code = 0; code < 65536; code++)
      drive(0, 16'(code), 357913941, 715827882, 12345, 23456);
    finish_stage(0);

    // Cross the strict stable boundary for every normalized coherence pair.
    for (int zeros = 0; zeros <= 8; zeros++) begin
      bank = bank_with_zeros(zeros);
      foreach (NORMAL[g]) foreach (NORMAL[c])
        for (int offset = -1; offset <= 1; offset++) begin
          pressure = longint'(capacity_oracle(bank, NORMAL[g], NORMAL[c])) + longint'(offset);
          temperature = pressure / 2;
          drive(1, bank, NORMAL[g], NORMAL[c], 32'(temperature), 32'(pressure - temperature));
        end
    end
    finish_stage(1);

    // Independent signed pressure operands exercise both saturation limits.
    for (int zeros = 0; zeros <= 8; zeros++)
      foreach (PRESSURE[t]) foreach (PRESSURE[s])
        drive(2, bank_with_zeros(zeros), 0, 1073741824, PRESSURE[t], PRESSURE[s]);
    finish_stage(2);

    // Around both signed margin limits and zero, including coherence diagnostics.
    for (int zeros = 0; zeros <= 8; zeros++) begin
      bank = bank_with_zeros(zeros);
      foreach (COHERENCE[g]) foreach (COHERENCE[c]) begin
        capacity = longint'(capacity_oracle(bank, COHERENCE[g], COHERENCE[c]));
        foreach (BOUNDARIES[b]) for (int offset = -1; offset <= 1; offset++) begin
          pressure = capacity + BOUNDARIES[b] + longint'(offset);
          temperature = pressure / 2;
          if (temperature < -64'sd2147483648 || temperature > 64'sd2147483647
              || pressure - temperature < -64'sd2147483648 || pressure - temperature > 64'sd2147483647)
            $fatal(1, "Stability diagnostic operand outside signed 32-bit range");
          drive(3, bank, COHERENCE[g], COHERENCE[c], 32'(temperature), 32'(pressure - temperature));
        end
      end
    end
    finish_stage(3);

    // Separate reproducible streams for normalized inputs and all signed bits.
    random_word = 32'h4d333153;
    for (int stage = 4; stage <= 5; stage++) begin
      repeat (EXPECTED_COUNTS[stage]) begin
        foreach (random_values[k]) begin
          random_word = advance(random_word);
          random_values[k] = random_word;
        end
        if (stage == 4)
          drive(stage, ternary_bank(random_values[0] % 6561),
                32'(random_values[1] % 1073741825), 32'(random_values[2] % 1073741825),
                32'(random_values[3] % 131073), 32'(random_values[4] % 65537));
        else
          drive(stage, random_values[0][15:0], $signed(random_values[1]), $signed(random_values[2]),
                $signed(random_values[3]), $signed(random_values[4]));
      end
      finish_stage(stage);
    end

    foreach (neutral_bins[k])
      if (neutral_bins[k] != EXPECTED_NEUTRAL_BINS[k])
        $fatal(1, "Stability neutral-count bin mismatch zeros=%0d count=%0d", k, neutral_bins[k]);
    foreach (boundary_bins[k])
      if (boundary_bins[k] != 1521 || margin_sign_counts[k] != EXPECTED_MARGIN_SIGNS[k])
        $fatal(1, "Stability margin coverage mismatch bin=%0d boundaries=%0d signs=%0d",
               k, boundary_bins[k], margin_sign_counts[k]);
    if (vectors != 100027 || checks != 400108 || valid_state_words != 6561 || reserved_state_words != 58975
        || pressure_high != 6471 || pressure_low != 1316 || margin_high_wraps != 3167 || margin_low_wraps != 25
        || global_ties != 2'b11 || cluster_ties != 2'b11 || neutral_ties != 9543 || diagnostic_vectors != 82276
        || (input_ones & input_zeros) !== {144{1'b1}} || (output_ones & output_zeros) !== {97{1'b1}})
      $fatal(1, "Stability boundary coverage incomplete vectors=%0d checks=%0d pressure=%0d/%0d wraps=%0d/%0d diagnostics=%0d",
             vectors, checks, pressure_high, pressure_low, margin_high_wraps, margin_low_wraps, diagnostic_vectors);
    $display("FRP_M31_STABILITY_BOUNDARY_TB: PASS stages=6 vectors=%0d checks=%0d input_bits=144 output_bits=97 state_words=65536 valid_state_words=%0d reserved_state_words=%0d neutral_bins=9 boundary_cases=4563 pressure_high=%0d pressure_low=%0d margin_high_wraps=%0d margin_low_wraps=%0d negative_margins=%0d zero_margins=%0d positive_margins=%0d global_ties=%0d cluster_ties=%0d neutral_ties=%0d diagnostic_vectors=%0d input_exercised=%0d output_exercised=%0d signature=%h",
             vectors, checks, valid_state_words, reserved_state_words, pressure_high, pressure_low,
             margin_high_wraps, margin_low_wraps, margin_sign_counts[0], margin_sign_counts[1], margin_sign_counts[2],
             global_ties, cluster_ties, neutral_ties, diagnostic_vectors,
             $countones(input_ones & input_zeros), $countones(output_ones & output_zeros), signature);
    done = 1;
    $finish;
  end

  initial begin
    #10000;
    if (!done) $fatal(1, "Stability boundary watchdog");
  end
endmodule : frp_m31_stability_boundary_tb
`endif

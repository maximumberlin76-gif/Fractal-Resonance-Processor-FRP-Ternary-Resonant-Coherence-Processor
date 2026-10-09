// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent functional contracts for two unchanged M31 blocks.
// Elaborate one top at a time. Define FRP_M31_THERMAL_STABILITY_CONTRACT_NETLIST
// to check the selected freshly synthesized *_netlist instead of RTL.
// Neither oracle calls DUT helpers or reads internal DUT signals.
// All signed input words are unrestricted; stability uses eight cells.
// Thermal assumes only initial sampled reset. Prove reset base AND induction
// after async2sync; bounded witnesses alone do not establish this contract.
// The thermal checker specifies each transition from public observed state,
// including full-width modulo-2^32 counting; no state is forced or abstracted.
// Products are rounded separately, nearest with ties away from zero.
// Stability pressure saturates; its margin wraps to 32 bits as in the current
// numeric contract. A negative pressure extreme can therefore yield stable=0.
// This documents that behavior; it does not endorse a physical stability rule.
// Only encoding 00 contributes to neutral capacity; reserved 10 is diagnostic.
// Scope excludes integrated-core reachability, physical temperature/timing,
// four-state behavior, parameter profiles other than eight cells, and Python
// model equivalence. Reach outputs are witness targets, never assumptions.

`ifndef FRP_M31_THERMAL_STABILITY_CONTRACT_FORMAL_SV
`define FRP_M31_THERMAL_STABILITY_CONTRACT_FORMAL_SV
`include "frp_m31_thermal_proxy.sv"
`include "frp_m31_stability.sv"

package frp_m31_thermal_stability_contract_pkg;
  typedef logic signed [63:0] wide_t;

  // Floor quotient and nonnegative remainder, unlike DUT magnitude rounding.
  // Callers use signed-32-bit operands and positive coefficients below 2^30;
  // their products and the operations below fit in signed 64 bits exactly.
  function automatic wide_t round_q30(input wide_t value);
    wide_t quotient;
    logic [29:0] remainder_bits;
    begin
      quotient = value >>> 30;
      remainder_bits = value[29:0];
      if (remainder_bits > 30'd536870912
          || (remainder_bits == 30'd536870912 && value >= 0))
        quotient = quotient + 64'sd1;
      return quotient;
    end
  endfunction

  // Recognize exact sign extension instead of comparing against DUT rails.
  function automatic logic signed [31:0] clip_s32(input wide_t value);
    if (value[63:31] == {33{value[31]}}) return value[31:0];
    return value[63] ? 32'sh80000000 : 32'sh7fffffff;
  endfunction
endpackage

module frp_m31_thermal_contract_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear,
  input logic signed [31:0] normalized_cycle_cost_q16,
  output wire [95:0] observed_outputs,
  output wire [95:0] expected_outputs,
  output logic [2:0] mismatch,
  output logic [15:0] reach
);
  import frp_m31_thermal_stability_contract_pkg::*;
  typedef struct packed {
    logic signed [31:0] temperature;
    logic signed [31:0] peak;
    logic [31:0] count;
  } observations_t;
  wire observations_t actual;
  observations_t expected, next_expected;
  logic signed [31:0] decayed, generated, next_temperature;
  logic history_valid = 1'b0;

  assign observed_outputs = actual;
  assign expected_outputs = expected;
`ifdef FRP_M31_THERMAL_STABILITY_CONTRACT_NETLIST
  frp_m31_thermal_proxy_netlist dut (
`else
  frp_m31_thermal_proxy dut (
`endif
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable), .clear(clear),
    .normalized_cycle_cost_q16(normalized_cycle_cost_q16),
    .temperature_proxy_q16(actual.temperature),
    .peak_temperature_proxy_q16(actual.peak), .sample_count_q(actual.count)
  );

  always_comb begin
    decayed = clip_s32(round_q30(wide_t'(actual.temperature) * 64'sd1020054733));
    generated = clip_s32(round_q30(wide_t'(normalized_cycle_cost_q16) * 64'sd10737418));
    next_temperature = clip_s32(wide_t'(decayed) + wide_t'(generated));
    next_expected = actual;
    if (clear) next_expected = '0;
    else if (tick_enable) begin
      next_expected.temperature = next_temperature;
      next_expected.peak = actual.peak >= next_temperature ? actual.peak : next_temperature;
      next_expected.count = 32'(wide_t'({1'b0, actual.count}) + 64'sd1);
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) expected <= '0;
    else expected <= next_expected;
  end
  always @(posedge clk) history_valid <= 1'b1;

  always_comb begin
    a_initial_reset: if (!history_valid) assume (!rst_n);
    mismatch[0] = actual.temperature != expected.temperature;
    mismatch[1] = actual.peak != expected.peak;
    mismatch[2] = actual.count != expected.count;
    if (history_valid) begin
      a_temperature: assert (!mismatch[0]);
      a_peak: assert (!mismatch[1]);
      a_count: assert (!mismatch[2]);
      a_peak_nonnegative: assert (actual.peak >= 0);
      a_peak_dominates: assert (actual.peak >= actual.temperature);
    end
  end

  // History below observes ports only and introduces no assumptions.
  logic previous_reset, previous_tick, previous_clear;
  logic signed [31:0] previous_cost;
  observations_t previous;
  wire live_transition = history_valid && previous_reset && rst_n;
  always @(posedge clk) begin
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear;
    previous_cost <= normalized_cycle_cost_q16;
    previous <= actual;
  end

  always_comb begin
    reach = '0;
    if (live_transition) begin
      if (previous_tick && !previous_clear) begin
        reach[0] = previous.temperature == 0 && previous_cost > 0 && actual.temperature > 0;
        reach[1] = previous.temperature == 0 && previous_cost < 0
          && actual.temperature < 0 && actual.peak == 0;
        reach[2] = previous.peak > 0 && actual.temperature < previous.temperature
          && actual.peak == previous.peak;
        reach[3] = actual.peak > previous.peak;
        reach[8] = previous_cost == 32'sh7fffffff && actual.temperature > 0;
        reach[9] = previous_cost == 32'sh80000000 && actual.temperature < 0;
        reach[10] = previous_cost == 0 && previous.temperature > 0
          && actual.temperature < previous.temperature;
        reach[11] = previous_cost == 0 && previous.temperature < 0
          && actual.temperature > previous.temperature;
        reach[12] = previous.temperature == 0 && previous_cost == 50 && actual.temperature == 0;
        reach[13] = previous.temperature == 0 && previous_cost == 51 && actual.temperature == 1;
        reach[14] = previous.temperature == 0 && previous_cost == -50 && actual.temperature == 0;
        reach[15] = previous.temperature == 0 && previous_cost == -51 && actual.temperature == -1;
      end
      reach[4] = !previous_tick && !previous_clear && previous.temperature != 0;
      reach[5] = previous_clear && !previous_tick && previous.count != 0;
      reach[6] = previous_clear && previous_tick && previous.count != 0 && previous_cost != 0;
    end
    reach[7] = history_valid && previous_reset && !rst_n && previous.count != 0;
  end
endmodule

module frp_m31_stability_contract_formal (
  input logic [15:0] retained_state,
  input logic signed [31:0] global_coherence_q30,
  input logic signed [31:0] cluster_coherence_q30,
  input logic signed [31:0] temperature_proxy_q16,
  input logic signed [31:0] switch_load_q16,
  output wire [96:0] observed_outputs,
  output wire [96:0] expected_outputs,
  output logic [3:0] mismatch,
  output logic [19:0] reach
);
  import frp_m31_thermal_stability_contract_pkg::*;
  typedef struct packed {
    logic signed [31:0] capacity;
    logic signed [31:0] pressure;
    logic signed [31:0] margin;
    logic stable;
  } observations_t;
  wire observations_t actual;
  observations_t expected;
  logic [7:0] neutral_mask;
  logic [3:0] neutral_count;
  logic signed [31:0] neutral_bonus, global_bonus, cluster_bonus;
  wide_t pressure_wide, margin_wide;

  assign observed_outputs = actual;
  assign expected_outputs = expected;
`ifdef FRP_M31_THERMAL_STABILITY_CONTRACT_NETLIST
  frp_m31_stability_netlist dut (
`else
  frp_m31_stability #(.CELLS(8)) dut (
`endif
    .retained_state(retained_state), .global_coherence_q30(global_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30), .temperature_proxy_q16(temperature_proxy_q16),
    .switch_load_q16(switch_load_q16), .coherence_capacity_q16(actual.capacity),
    .pressure_q16(actual.pressure), .stability_margin_q16(actual.margin), .stable(actual.stable)
  );

  always_comb begin
    for (int cell_id = 0; cell_id < 8; cell_id++)
      neutral_mask[cell_id] = ~|retained_state[2*cell_id +: 2];
    neutral_count = 4'($countones(neutral_mask));
    // Independently tabulated round(5243*n/8), n=0..8; exact eight-cell profile.
    case (neutral_count)
      0: neutral_bonus = 0;
      1: neutral_bonus = 655;
      2: neutral_bonus = 1311;
      3: neutral_bonus = 1966;
      4: neutral_bonus = 2622;
      5: neutral_bonus = 3277;
      6: neutral_bonus = 3932;
      7: neutral_bonus = 4588;
      8: neutral_bonus = 5243;
      default: neutral_bonus = 0;
    endcase
    global_bonus = clip_s32(round_q30(wide_t'(global_coherence_q30) * 64'sd22282));
    cluster_bonus = clip_s32(round_q30(wide_t'(cluster_coherence_q30) * 64'sd10486));
    expected.capacity = clip_s32(64'sd53740 + wide_t'(global_bonus)
      + wide_t'(cluster_bonus) + wide_t'(neutral_bonus));
    pressure_wide = wide_t'(temperature_proxy_q16) + wide_t'(switch_load_q16);
    expected.pressure = clip_s32(pressure_wide);
    margin_wide = wide_t'(expected.capacity) - wide_t'(expected.pressure);
    expected.margin = margin_wide[31:0];
    expected.stable = !expected.margin[31] && |expected.margin;

    mismatch[0] = actual.capacity != expected.capacity;
    mismatch[1] = actual.pressure != expected.pressure;
    mismatch[2] = actual.margin != expected.margin;
    mismatch[3] = actual.stable != expected.stable;
    a_capacity: assert (!mismatch[0]);
    a_pressure: assert (!mismatch[1]);
    a_margin: assert (!mismatch[2]);
    a_stable: assert (!mismatch[3]);

    reach = '0;
    for (int count = 0; count <= 8; count++) reach[count] = neutral_count == count;
    reach[9] = pressure_wide > 64'sd2147483647;
    reach[10] = pressure_wide < -64'sd2147483648;
    reach[11] = margin_wide > 64'sd2147483647 && expected.margin < 0 && !actual.stable;
    reach[12] = expected.margin == 0 && !actual.stable;
    reach[13] = expected.margin == 1 && actual.stable;
    reach[14] = expected.margin == -1 && !actual.stable;
    reach[15] = retained_state == 16'haaaa && neutral_count == 0;
    reach[16] = global_coherence_q30 == 32'sh80000000 && cluster_coherence_q30 == 32'sh7fffffff;
    reach[17] = global_coherence_q30 == 32'sh7fffffff && cluster_coherence_q30 == 32'sh80000000;
    reach[18] = global_coherence_q30 == 32'sd268435456 && global_bonus == 5571;
    reach[19] = global_coherence_q30 == -32'sd268435456 && global_bonus == -5571;
  end
endmodule
`endif

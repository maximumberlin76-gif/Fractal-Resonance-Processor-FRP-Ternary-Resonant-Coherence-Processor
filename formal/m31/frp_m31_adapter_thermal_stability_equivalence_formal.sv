// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Three independently elaborated RTL/netlist equivalence checks in one file:
// phase-request adapter (12 bits), thermal proxy (96 bits), stability (97 bits).
// Compare every public output port, including inactive-lane payloads, the
// thermal peak and full 32-bit sample counter, and all stability word bits.
// Eight-cell/two-lane profile; all combinational inputs are unrestricted.
// Thermal proof assumes only an initial sampled reset. All later reset,
// clear, tick and signed cost inputs are arbitrary. No DUT state is forced.
// After async2sync, prove the two-edge reset base with this thermal top;
// prove the one-step inductive transition with equiv_make/equiv_simple on
// the two thermal cores, matching ONLY the 96 public output/state bits.
// Require all 96 equivalence cells proven and no other state in either core.
// The transition proof alone is insufficient: the reset base is mandatory.
// Load the selected block's freshly synthesized *_netlist using
// read_verilog -icells, then elaborate ONE of the three tops below.
// Use alumacc and opt -full to normalize arithmetic before SAT.
// Reach outputs describe witnesses, not assumptions. Thermal witnesses use
// six sampled edges; they do not replace the unbounded induction proof.
// Reserved pending 10 follows the existing adapter's not-busy behavior.
// Stability uses the existing wrapping 32-bit margin subtraction, including
// nonphysical extreme inputs; equality does not certify that numeric policy.
// These are implementation-equivalence proofs, not independent functional
// contracts or an integrated-core proof. Scope excludes phase arithmetic,
// physical timing, four-state behavior, liveness and Python-model equivalence.

`ifndef FRP_M31_ADAPTER_THERMAL_STABILITY_EQUIVALENCE_FORMAL_SV
`define FRP_M31_ADAPTER_THERMAL_STABILITY_EQUIVALENCE_FORMAL_SV
`include "frp_m31_phase_request_adapter.sv"
`include "frp_m31_thermal_proxy.sv"
`include "frp_m31_stability.sv"

module frp_m31_phase_request_equivalence_formal (
  input logic enable,
  input logic [15:0] retained_state,
  input logic [15:0] pending_route,
  input logic [15:0] phase_target,
  input logic [2:0] scheduler_state,
  output wire [11:0] rtl_outputs,
  output wire [11:0] netlist_outputs,
  output logic [2:0] mismatch,
  output logic [7:0] reach
);
  typedef struct packed {
    logic [1:0] request_valid;
    logic [5:0] request_cell_index;
    logic [3:0] request_target;
  } observations_t;
  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m31_phase_request_adapter #(.CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3)) rtl_dut (
    .enable(enable),
    .retained_state(retained_state),
    .pending_route(pending_route),
    .phase_target(phase_target),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .request_valid(rtl_observed.request_valid),
    .request_cell_index(rtl_observed.request_cell_index),
    .request_target(rtl_observed.request_target)
  );

  frp_m31_phase_request_adapter_netlist netlist_dut (
    .enable(enable),
    .retained_state(retained_state),
    .pending_route(pending_route),
    .phase_target(phase_target),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .request_valid(netlist_observed.request_valid),
    .request_cell_index(netlist_observed.request_cell_index),
    .request_target(netlist_observed.request_target)
  );

  always_comb begin
    mismatch[0] = rtl_observed.request_valid != netlist_observed.request_valid;
    mismatch[1] = rtl_observed.request_cell_index != netlist_observed.request_cell_index;
    mismatch[2] = rtl_observed.request_target != netlist_observed.request_target;
    a_request_valid: assert (!mismatch[0]);
    a_request_cell_index: assert (!mismatch[1]);
    a_request_target: assert (!mismatch[2]);
  end

  always_comb begin
    reach = '0;
    reach[0] = !enable && retained_state == 0 && pending_route == 0
      && phase_target == 16'h5555 && scheduler_state == 0;
    reach[1] = enable && rtl_observed.request_valid == 1
      && rtl_observed.request_cell_index[2:0] == 7;
    reach[2] = enable && rtl_observed.request_valid == 3
      && rtl_observed.request_target == 4'b1101;
    reach[3] = enable && retained_state[1:0] == 1 && phase_target[1:0] == 3
      && rtl_observed.request_valid[0] && rtl_observed.request_cell_index[2:0] == 0;
    reach[4] = enable && pending_route[1:0] == 1 && retained_state[1:0] == 0
      && phase_target[1:0] == 1 && scheduler_state == 0
      && rtl_observed.request_valid[0] && rtl_observed.request_cell_index[2:0] != 0;
    reach[5] = enable && scheduler_state == 2 && retained_state == 0
      && rtl_observed.request_valid == 3;
    reach[6] = enable && scheduler_state >= 5 && retained_state == 0
      && pending_route == 0 && phase_target == 16'h5555;
    reach[7] = enable && pending_route[1:0] == 2 && retained_state[1:0] == 0
      && phase_target[1:0] == 1 && scheduler_state == 0
      && rtl_observed.request_valid[0] && rtl_observed.request_cell_index[2:0] == 0;
  end
endmodule

module frp_m31_thermal_equivalence_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear,
  input logic signed [31:0] normalized_cycle_cost_q16,
  output wire [95:0] rtl_outputs,
  output wire [95:0] netlist_outputs,
  output logic [2:0] mismatch,
  output logic [11:0] reach
);
  typedef struct packed {
    logic signed [31:0] temperature_proxy_q16;
    logic signed [31:0] peak_temperature_proxy_q16;
    logic [31:0] sample_count_q;
  } observations_t;
  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m31_thermal_proxy rtl_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear(clear),
    .normalized_cycle_cost_q16(normalized_cycle_cost_q16),
    .temperature_proxy_q16(rtl_observed.temperature_proxy_q16),
    .peak_temperature_proxy_q16(rtl_observed.peak_temperature_proxy_q16),
    .sample_count_q(rtl_observed.sample_count_q)
  );

  frp_m31_thermal_proxy_netlist netlist_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear(clear),
    .normalized_cycle_cost_q16(normalized_cycle_cost_q16),
    .temperature_proxy_q16(netlist_observed.temperature_proxy_q16),
    .peak_temperature_proxy_q16(netlist_observed.peak_temperature_proxy_q16),
    .sample_count_q(netlist_observed.sample_count_q)
  );

  logic history_valid = 1'b0;
  always @(posedge clk) history_valid <= 1'b1;

  always_comb begin
    a_initial_reset: if (!history_valid) assume (!rst_n);
    mismatch[0] = rtl_observed.temperature_proxy_q16 != netlist_observed.temperature_proxy_q16;
    mismatch[1] = rtl_observed.peak_temperature_proxy_q16 != netlist_observed.peak_temperature_proxy_q16;
    mismatch[2] = rtl_observed.sample_count_q != netlist_observed.sample_count_q;
    if (history_valid) begin
      a_temperature_proxy_q16: assert (!mismatch[0]);
      a_peak_temperature_proxy_q16: assert (!mismatch[1]);
      a_sample_count_q: assert (!mismatch[2]);
    end
  end

  // Previous samples describe reachability only; they constrain no input.
  logic previous_reset, previous_tick, previous_clear;
  logic signed [31:0] previous_cost;
  observations_t previous;
  wire live_transition = history_valid && previous_reset && rst_n;
  always @(posedge clk) begin
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear;
    previous_cost <= normalized_cycle_cost_q16;
    previous <= rtl_observed;
  end

  always_comb begin
    reach = '0;
    if (live_transition) begin
      if (previous_tick && !previous_clear) begin
        reach[0] = previous.temperature_proxy_q16 == 0 && previous_cost > 0
          && rtl_observed.temperature_proxy_q16 > 0;
        reach[1] = previous.temperature_proxy_q16 == 0 && previous_cost < 0
          && rtl_observed.temperature_proxy_q16 < 0 && rtl_observed.peak_temperature_proxy_q16 == 0;
        reach[2] = previous.peak_temperature_proxy_q16 > 0
          && rtl_observed.temperature_proxy_q16 < previous.temperature_proxy_q16
          && rtl_observed.peak_temperature_proxy_q16 == previous.peak_temperature_proxy_q16;
        reach[3] = rtl_observed.peak_temperature_proxy_q16 > previous.peak_temperature_proxy_q16;
        reach[8] = previous_cost == 32'sh7fffffff && rtl_observed.temperature_proxy_q16 > 0;
        reach[9] = previous_cost == 32'sh80000000 && rtl_observed.temperature_proxy_q16 < 0;
        reach[10] = previous_cost == 0 && previous.temperature_proxy_q16 > 0
          && rtl_observed.temperature_proxy_q16 < previous.temperature_proxy_q16;
        reach[11] = previous_cost == 0 && previous.temperature_proxy_q16 < 0
          && rtl_observed.temperature_proxy_q16 > previous.temperature_proxy_q16;
      end
      reach[4] = !previous_tick && !previous_clear && previous.temperature_proxy_q16 != 0;
      reach[5] = previous_clear && !previous_tick && previous.sample_count_q != 0;
      reach[6] = previous_clear && previous_tick && previous.sample_count_q != 0 && previous_cost != 0;
    end
    reach[7] = history_valid && previous_reset && !rst_n && previous.sample_count_q != 0;
  end
endmodule

module frp_m31_stability_equivalence_formal (
  input logic [15:0] retained_state,
  input logic signed [31:0] global_coherence_q30,
  input logic signed [31:0] cluster_coherence_q30,
  input logic signed [31:0] temperature_proxy_q16,
  input logic signed [31:0] switch_load_q16,
  output wire [96:0] rtl_outputs,
  output wire [96:0] netlist_outputs,
  output logic [3:0] mismatch,
  output logic [15:0] reach
);
  typedef struct packed {
    logic signed [31:0] coherence_capacity_q16;
    logic signed [31:0] pressure_q16;
    logic signed [31:0] stability_margin_q16;
    logic stable;
  } observations_t;
  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m31_stability #(.CELLS(8)) rtl_dut (
    .retained_state(retained_state),
    .global_coherence_q30(global_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .temperature_proxy_q16(temperature_proxy_q16),
    .switch_load_q16(switch_load_q16),
    .coherence_capacity_q16(rtl_observed.coherence_capacity_q16),
    .pressure_q16(rtl_observed.pressure_q16),
    .stability_margin_q16(rtl_observed.stability_margin_q16),
    .stable(rtl_observed.stable)
  );

  frp_m31_stability_netlist netlist_dut (
    .retained_state(retained_state),
    .global_coherence_q30(global_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .temperature_proxy_q16(temperature_proxy_q16),
    .switch_load_q16(switch_load_q16),
    .coherence_capacity_q16(netlist_observed.coherence_capacity_q16),
    .pressure_q16(netlist_observed.pressure_q16),
    .stability_margin_q16(netlist_observed.stability_margin_q16),
    .stable(netlist_observed.stable)
  );

  always_comb begin
    mismatch[0] = rtl_observed.coherence_capacity_q16 != netlist_observed.coherence_capacity_q16;
    mismatch[1] = rtl_observed.pressure_q16 != netlist_observed.pressure_q16;
    mismatch[2] = rtl_observed.stability_margin_q16 != netlist_observed.stability_margin_q16;
    mismatch[3] = rtl_observed.stable != netlist_observed.stable;
    a_coherence_capacity_q16: assert (!mismatch[0]);
    a_pressure_q16: assert (!mismatch[1]);
    a_stability_margin_q16: assert (!mismatch[2]);
    a_stable: assert (!mismatch[3]);
  end

  logic [3:0] neutral_count;
  logic signed [32:0] wide_pressure, wide_margin;
  always_comb begin
    neutral_count = 0;
    for (int cell_id = 0; cell_id < 8; cell_id++)
      neutral_count = neutral_count + 4'(retained_state[2*cell_id +: 2] == 0);
    wide_pressure = {temperature_proxy_q16[31], temperature_proxy_q16}
      + {switch_load_q16[31], switch_load_q16};
    wide_margin = {rtl_observed.coherence_capacity_q16[31], rtl_observed.coherence_capacity_q16}
      - {rtl_observed.pressure_q16[31], rtl_observed.pressure_q16};
    reach = '0;
    for (int count = 0; count <= 8; count++)
      reach[count] = neutral_count == count;
    reach[9] = wide_pressure > 33'sd2147483647;
    reach[10] = wide_pressure < -33'sd2147483648;
    reach[11] = rtl_observed.stability_margin_q16 == 0;
    reach[12] = rtl_observed.stability_margin_q16 == 1;
    reach[13] = rtl_observed.stability_margin_q16 == -32'sd1;
    reach[14] = wide_margin > 33'sd2147483647;
    reach[15] = wide_margin < -33'sd2147483648;
  end
endmodule

`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Global stability register, history, and output arithmetic contracts.
// One formal step represents one rising clock edge after async2sync.
// Reset is required initially; subsequent reset/tick/data are unrestricted.
// This harness checks transfers from public next_* outputs. It does not
// independently establish the exponential ROM or capacity formula.
// Physical asynchronous-reset timing is outside this sampled two-state model.
// FRP_M31_GLOBAL_STABILITY_NETLIST selects a separately loaded netlist named
// frp_m31_global_stability, specialized to the same CELLS value.
// For compositional induction, mean_heat_q16 and next_{coherence_compression,
// effective_coherence,coherence_capacity}_{q30,q30,q16} may be cut to anyseq.
// These four boundaries are unrestricted, not constrained to expected values.
// Keep pressure, margin, stable, all registers, and reset/tick logic intact.

`ifndef FRP_M31_GLOBAL_STABILITY_HISTORY_FORMAL_SV
`define FRP_M31_GLOBAL_STABILITY_HISTORY_FORMAL_SV

`ifndef FRP_M31_GLOBAL_STABILITY_NETLIST
`include "frp_m31_global_stability.sv"
`endif

module frp_m31_global_stability_history_formal #(
  parameter int CELLS = 8
) (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic [(CELLS*2)-1:0] retained_state,
  input logic signed [31:0] raw_phase_coherence_q30,
  input logic signed [31:0] cluster_coherence_q30,
  input logic [(CELLS*32)-1:0] heat_q16,
  input logic [(CELLS*32)-1:0] thermal_overload_q16,
  input logic [(CELLS*32)-1:0] frequency_lag_q16,
  input logic signed [31:0] switch_load_q16,
  output wire [513:0] observed_outputs,
  output wire [5:0] reach
);

  wire signed [31:0] mean_heat_q16, mean_thermal_overload_q16;
  wire signed [31:0] mean_frequency_lag_q16, neutral_fraction_q30;
  wire signed [31:0] compression_arg_q16;
  wire signed [31:0] next_coherence_compression_q30;
  wire signed [31:0] next_effective_coherence_q30;
  wire signed [31:0] next_coherence_capacity_q16, next_pressure_q16;
  wire signed [31:0] next_stability_margin_q16;
  wire next_stable;
  wire signed [31:0] coherence_compression_q30, effective_coherence_q30;
  wire signed [31:0] coherence_capacity_q16, pressure_q16;
  wire signed [31:0] stability_margin_q16, previous_margin_q16;
  wire stable;

`ifdef FRP_M31_GLOBAL_STABILITY_NETLIST
  frp_m31_global_stability dut (.*);
`else
  frp_m31_global_stability #(.CELLS(CELLS)) dut (.*);
`endif

  localparam logic [192:0] RESET_REGISTERS = {
    32'sd1073741824, 32'sd0, 32'sd65536, 32'sd3277,
    32'sd62259, 32'sd39322, 1'b1
  };

  wire [192:0] registers_now = {
    coherence_compression_q30, effective_coherence_q30,
    coherence_capacity_q16, pressure_q16,
    stability_margin_q16, previous_margin_q16, stable
  };
  wire [192:0] commit_now = {
    next_coherence_compression_q30, next_effective_coherence_q30,
    next_coherence_capacity_q16, next_pressure_q16,
    next_stability_margin_q16, next_stability_margin_q16, next_stable
  };
  assign observed_outputs = {
    mean_heat_q16, mean_thermal_overload_q16, mean_frequency_lag_q16,
    neutral_fraction_q30, compression_arg_q16,
    next_coherence_compression_q30, next_effective_coherence_q30,
    next_coherence_capacity_q16, next_pressure_q16,
    next_stability_margin_q16, next_stable, registers_now
  };

  // Independent signed 33-bit addition/subtraction cannot overflow here.
  function automatic logic signed [31:0] saturate33(
    input logic signed [32:0] value
  );
    if (value > 33'sd2147483647) return 32'sh7fffffff;
    if (value < -33'sd2147483648) return 32'sh80000000;
    return value[31:0];
  endfunction

  wire signed [32:0] pressure_sum =
    $signed({mean_heat_q16[31], mean_heat_q16})
    + $signed({switch_load_q16[31], switch_load_q16});
  wire signed [32:0] margin_difference =
    $signed({next_coherence_capacity_q16[31], next_coherence_capacity_q16})
    - $signed({next_pressure_q16[31], next_pressure_q16});

  logic history_valid = 1'b0;
  logic previous_reset, previous_tick;
  logic earlier_reset = 1'b0;
  logic earlier_tick = 1'b0;
  logic [192:0] previous_registers, previous_commit;
  logic signed [31:0] previous_switch_load;
  logic committed_since_reset = 1'b0;
  logic previous_committed = 1'b0;

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    earlier_reset <= previous_reset;
    earlier_tick <= previous_tick;
    previous_registers <= registers_now;
    previous_commit <= commit_now;
    previous_switch_load <= switch_load_q16;
    previous_committed <= committed_since_reset;
    if (!rst_n) committed_since_reset <= 1'b0;
    else if (tick_enable) committed_since_reset <= 1'b1;
  end

  wire live_transition = history_valid && previous_reset && rst_n;

  always_comb begin
    if (!history_valid) assume (!rst_n);

    if (history_valid) begin
      a_pressure_saturation: assert (next_pressure_q16 == saturate33(pressure_sum));
      a_margin_saturation: assert (next_stability_margin_q16 == saturate33(margin_difference));
      a_next_threshold: assert (next_stable == (next_stability_margin_q16 > 32'sd0));
      a_registered_threshold: assert (stable == (stability_margin_q16 > 32'sd0));

      if (!rst_n || !previous_reset) begin
        a_reset_priority: assert (registers_now == RESET_REGISTERS);
      end

      if (live_transition) begin
        if (previous_tick) begin
          a_commit_snapshot: assert (registers_now == previous_commit);
        end else begin
          a_hold_snapshot: assert (registers_now == previous_registers);
        end

        if (committed_since_reset) begin
          a_committed_history: assert (previous_margin_q16 == stability_margin_q16);
        end else begin
          a_initial_history: assert (previous_margin_q16 == 32'sd39322);
          a_initial_margin: assert (stability_margin_q16 == 32'sd62259);
        end
      end
    end
  end

  // Reachability targets for separate SAT queries; these are not assumptions.
  // 0: first commit; 1: consecutive commits; 2: hold while input changes;
  // 3: reset after a commit; 4: reset with tick; 5: reset release on hold.
  assign reach[0] = live_transition && previous_tick && !previous_committed;
  assign reach[1] = live_transition && previous_tick && earlier_reset && earlier_tick;
  assign reach[2] = live_transition && !previous_tick
    && switch_load_q16 != previous_switch_load;
  assign reach[3] = history_valid && !rst_n && committed_since_reset;
  assign reach[4] = history_valid && !rst_n && tick_enable;
  assign reach[5] = history_valid && !previous_reset && rst_n && !tick_enable;

endmodule

`endif

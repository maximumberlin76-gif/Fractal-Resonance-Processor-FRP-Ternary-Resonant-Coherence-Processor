// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Exact RTL/netlist equivalence of the complete eight-cell M31 phase engine.
// All nine public output ports (1168 bits) are compared on shared inputs:
// retained phases and frequency memory, thermal-weighted coupling, phase
// projection, ternary targets, pair/cluster/global coherence and dispersion.
// All input bits are unrestricted, including signed frequency and thermal
// extremes, every scheduler-state code, loads during ticks, and later resets.
// The sole assumption is an initial sampled reset; DUT state is never forced.
// Formal edges use two-state sampled semantics after async2sync conversion.
//
// Load a fresh frp_m31_phase_interference_netlist using read_verilog -icells.
// The original 4096-word sine ROM must be retained and identity-checked.
// For synthesis, only the four simulation-only ROM $fatal guards may be
// removed from a private source copy after validating the ROM independently;
// retain $readmemh, all arithmetic and every sequential/combinational branch.
// The repository RTL itself must remain byte-identical.
//
// Qualification requires the reset base and an inductive transition proof.
// All 512 retained state bits must be accounted for by phase_word_q and
// frequency_current_q16. Intermediate wire or ROM-address matches are proof
// obligations, not assumptions: every introduced equivalence cell must be
// discharged, including every public output bit; reject unresolved cells.
// Verify ROM contents and read-port correspondence before sharing a ROM.
// Matching internal names or a transition-only proof is insufficient.
// Reach bits describe witness targets and add no assumptions.
// Discharging these obligations establishes implementation equivalence only;
// it does not establish physical resonance, full M32, liveness or an
// independent phase equation or Python-model equivalence.

`ifndef FRP_M31_PHASE_INTERFERENCE_EQUIVALENCE_FORMAL_SV
`define FRP_M31_PHASE_INTERFERENCE_EQUIVALENCE_FORMAL_SV
`include "frp_m31_phase_interference.sv"

module frp_m31_phase_interference_equivalence_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic load_valid,
  input logic [255:0] phase_load,
  input logic [255:0] frequency_load_q16,
  input logic [255:0] gamma_effective_word,
  input logic [255:0] thermal_node_factor_q30,
  input logic [15:0] retained_state,
  input logic [7:0] switch_activity,
  input logic [2:0] scheduler_state,
  output wire [1167:0] rtl_outputs,
  output wire [1167:0] netlist_outputs,
  output logic [8:0] mismatch,
  output logic [15:0] reach
);
  typedef struct packed {
    logic [255:0] phase_word_q;
    logic [255:0] frequency_current_q16;
    logic [255:0] coupling_field_q16;
    logic [255:0] phase_projection_q30;
    logic [15:0] phase_target;
    logic [31:0] pair_coherence_q30;
    logic [31:0] cluster_coherence_q30;
    logic [31:0] global_coherence_q30;
    logic [31:0] organization_dispersion_q30;
  } observations_t;
  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m31_phase_interference #(.CELLS(8)) rtl_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .load_valid(load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .retained_state(retained_state),
    .switch_activity(switch_activity),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .phase_word_q(rtl_observed.phase_word_q),
    .frequency_current_q16(rtl_observed.frequency_current_q16),
    .coupling_field_q16(rtl_observed.coupling_field_q16),
    .phase_projection_q30(rtl_observed.phase_projection_q30),
    .phase_target(rtl_observed.phase_target),
    .pair_coherence_q30(rtl_observed.pair_coherence_q30),
    .cluster_coherence_q30(rtl_observed.cluster_coherence_q30),
    .global_coherence_q30(rtl_observed.global_coherence_q30),
    .organization_dispersion_q30(rtl_observed.organization_dispersion_q30)
  );

  frp_m31_phase_interference_netlist netlist_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .load_valid(load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .retained_state(retained_state),
    .switch_activity(switch_activity),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .phase_word_q(netlist_observed.phase_word_q),
    .frequency_current_q16(netlist_observed.frequency_current_q16),
    .coupling_field_q16(netlist_observed.coupling_field_q16),
    .phase_projection_q30(netlist_observed.phase_projection_q30),
    .phase_target(netlist_observed.phase_target),
    .pair_coherence_q30(netlist_observed.pair_coherence_q30),
    .cluster_coherence_q30(netlist_observed.cluster_coherence_q30),
    .global_coherence_q30(netlist_observed.global_coherence_q30),
    .organization_dispersion_q30(netlist_observed.organization_dispersion_q30)
  );

  logic history_valid = 1'b0;
  logic previous_reset, previous_tick, previous_load;
  logic [2:0] previous_schedule;
  logic [255:0] previous_phase_load, previous_frequency_load;
  logic [255:0] previous_phase, previous_frequency;
  wire live_transition = history_valid && previous_reset && rst_n;

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_load <= load_valid;
    previous_schedule <= scheduler_state;
    previous_phase_load <= phase_load;
    previous_frequency_load <= frequency_load_q16;
    previous_phase <= rtl_observed.phase_word_q;
    previous_frequency <= rtl_observed.frequency_current_q16;
  end

  always_comb begin
    a_initial_reset: if (!history_valid) assume (!rst_n);
    mismatch[0] = rtl_observed.phase_word_q != netlist_observed.phase_word_q;
    mismatch[1] = rtl_observed.frequency_current_q16 != netlist_observed.frequency_current_q16;
    mismatch[2] = rtl_observed.coupling_field_q16 != netlist_observed.coupling_field_q16;
    mismatch[3] = rtl_observed.phase_projection_q30 != netlist_observed.phase_projection_q30;
    mismatch[4] = rtl_observed.phase_target != netlist_observed.phase_target;
    mismatch[5] = rtl_observed.pair_coherence_q30 != netlist_observed.pair_coherence_q30;
    mismatch[6] = rtl_observed.cluster_coherence_q30 != netlist_observed.cluster_coherence_q30;
    mismatch[7] = rtl_observed.global_coherence_q30 != netlist_observed.global_coherence_q30;
    mismatch[8] = rtl_observed.organization_dispersion_q30 != netlist_observed.organization_dispersion_q30;
    if (history_valid) begin
      a_phase_word_q: assert (!mismatch[0]);
      a_frequency_current_q16: assert (!mismatch[1]);
      a_coupling_field_q16: assert (!mismatch[2]);
      a_phase_projection_q30: assert (!mismatch[3]);
      a_phase_target: assert (!mismatch[4]);
      a_pair_coherence_q30: assert (!mismatch[5]);
      a_cluster_coherence_q30: assert (!mismatch[6]);
      a_global_coherence_q30: assert (!mismatch[7]);
      a_organization_dispersion_q30: assert (!mismatch[8]);
    end
  end

  // Load and hold witnesses exercise the state boundary; dynamic witnesses
  // exercise all legal phases and a reserved scheduler encoding.
  // Current thermal/gamma controls remain independent of retained phases.
  always_comb begin
    reach = '0;
    if (live_transition) begin
      reach[0] = previous_load && previous_tick
        && rtl_observed.phase_word_q == previous_phase_load
        && rtl_observed.frequency_current_q16 == previous_frequency_load
        && previous_phase_load != previous_phase;
      reach[1] = previous_load && !previous_tick
        && rtl_observed.phase_word_q == previous_phase_load
        && previous_frequency_load != previous_frequency;
      reach[2] = !previous_load && !previous_tick
        && rtl_observed.phase_word_q == previous_phase
        && rtl_observed.frequency_current_q16 == previous_frequency;
      for (int state_code = 0; state_code < 5; state_code++)
        reach[3+state_code] = !previous_load && previous_tick
          && previous_schedule == 3'(state_code)
          && rtl_observed.phase_word_q != previous_phase;
      reach[8] = !previous_load && previous_tick && previous_schedule == 3'd7
        && rtl_observed.phase_word_q != previous_phase;
      reach[9] = previous_load && previous_frequency_load[31]
        && rtl_observed.frequency_current_q16[31:0] == previous_frequency_load[31:0];
      reach[10] = previous_load
        && previous_frequency_load[31:0] == 32'h80000000
        && previous_frequency_load[63:32] == 32'h7fffffff;
    end
    if (history_valid && rst_n) begin
      reach[11] = thermal_node_factor_q30 == 0
        && rtl_observed.coupling_field_q16 == 0;
      reach[12] = gamma_effective_word[31:0] == 32'hffffffff
        && rtl_observed.phase_word_q[31:0] != 0;
      reach[13] = thermal_node_factor_q30[31:0] == 32'h40000000
        && thermal_node_factor_q30[63:32] == 0
        && rtl_observed.coupling_field_q16[31:0] != 0;
      reach[14] = rtl_observed.phase_target[5:0] == 6'b001101
        && rtl_observed.global_coherence_q30 != 0;
    end
    reach[15] = history_valid && previous_reset && !rst_n
      && previous_phase != 256'he0000000c0000000a00000008000000060000000400000002000000000000000;
  end
endmodule

`endif

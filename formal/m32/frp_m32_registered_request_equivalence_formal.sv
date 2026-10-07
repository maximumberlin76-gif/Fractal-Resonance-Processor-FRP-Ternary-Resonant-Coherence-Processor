// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Exact RTL/netlist equivalence of the M32 registered-target/request path.
// Profile: eight cells, two request lanes, full 32-bit capture counters.
// All 12 public output ports (98 bits) are compared on shared arbitrary inputs.
// Only an initial sampled reset is assumed. Later resets, disabled ticks, counter
// clears, source banks, source-valid and automatic-mode controls, retained
// states, pending codes and all eight scheduler-state codes are unrestricted.
// No DUT register is initialized or constrained to match the other DUT.
// Prove the assertions by temporal induction, including its reset base case.
// Formal steps represent sampled rising edges in a two-state model.
// Load a fresh frp_m32_registered_target_request_path_netlist using
// read_verilog -icells before this harness; use async2sync before SAT.
// No internal state probes or additional netlist ports are required.
// This scope excludes phase arithmetic, scheduler cadence, execution through
// active state 0, full-core equivalence, liveness, physical timing, four-state
// simulation and Python-model equivalence; these remain separate boundaries.

`ifndef FRP_M32_REGISTERED_REQUEST_EQUIVALENCE_FORMAL_SV
`define FRP_M32_REGISTERED_REQUEST_EQUIVALENCE_FORMAL_SV
`include "frp_m31_pkg.sv"
`include "frp_m32_registered_target_request_path.sv"

module frp_m32_registered_request_equivalence_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic phase_target_valid,
  input logic [15:0] phase_target_source,
  input logic auto_target_enable,
  input logic [15:0] retained_state,
  input logic [15:0] pending_route,
  input logic [2:0] scheduler_state,
  output wire [97:0] rtl_outputs,
  output wire [97:0] netlist_outputs,
  output logic [11:0] mismatch,
  output logic [15:0] reach
);
  import frp_m31_pkg::*;

  // Packed fields and mismatch bits follow the DUT's public output order.
  typedef struct packed {
    logic [15:0] registered_target_q;
    logic registered_target_valid_q;
    logic phase_target_domain_valid;
    logic registered_target_domain_valid;
    logic capture_accepted;
    logic capture_rejected;
    logic [31:0] accepted_capture_events_q;
    logic [31:0] rejected_capture_events_q;
    logic registered_request_enable;
    logic [1:0] phase_request_valid;
    logic [5:0] phase_request_cell_index;
    logic [3:0] phase_request_target;
  } observations_t;

  wire observations_t rtl_observed, netlist_observed;
  assign rtl_outputs = rtl_observed;
  assign netlist_outputs = netlist_observed;

  frp_m32_registered_target_request_path #(
    .CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
  ) rtl_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .phase_target_valid(phase_target_valid),
    .phase_target_source(phase_target_source),
    .auto_target_enable(auto_target_enable),
    .retained_state(retained_state),
    .pending_route(pending_route),
    .scheduler_state(frp_m31_scheduler_state_e'(scheduler_state)),
    .registered_target_q(rtl_observed.registered_target_q),
    .registered_target_valid_q(rtl_observed.registered_target_valid_q),
    .phase_target_domain_valid(rtl_observed.phase_target_domain_valid),
    .registered_target_domain_valid(rtl_observed.registered_target_domain_valid),
    .capture_accepted(rtl_observed.capture_accepted),
    .capture_rejected(rtl_observed.capture_rejected),
    .accepted_capture_events_q(rtl_observed.accepted_capture_events_q),
    .rejected_capture_events_q(rtl_observed.rejected_capture_events_q),
    .registered_request_enable(rtl_observed.registered_request_enable),
    .phase_request_valid(rtl_observed.phase_request_valid),
    .phase_request_cell_index(rtl_observed.phase_request_cell_index),
    .phase_request_target(rtl_observed.phase_request_target)
  );

  frp_m32_registered_target_request_path_netlist netlist_dut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .phase_target_valid(phase_target_valid),
    .phase_target_source(phase_target_source),
    .auto_target_enable(auto_target_enable),
    .retained_state(retained_state),
    .pending_route(pending_route),
    .scheduler_state(frp_m31_scheduler_state_e'(scheduler_state)),
    .registered_target_q(netlist_observed.registered_target_q),
    .registered_target_valid_q(netlist_observed.registered_target_valid_q),
    .phase_target_domain_valid(netlist_observed.phase_target_domain_valid),
    .registered_target_domain_valid(netlist_observed.registered_target_domain_valid),
    .capture_accepted(netlist_observed.capture_accepted),
    .capture_rejected(netlist_observed.capture_rejected),
    .accepted_capture_events_q(netlist_observed.accepted_capture_events_q),
    .rejected_capture_events_q(netlist_observed.rejected_capture_events_q),
    .registered_request_enable(netlist_observed.registered_request_enable),
    .phase_request_valid(netlist_observed.phase_request_valid),
    .phase_request_cell_index(netlist_observed.phase_request_cell_index),
    .phase_request_target(netlist_observed.phase_request_target)
  );

  logic history_valid = 1'b0;
  logic previous_reset, previous_clear, previous_accept, previous_reject;
  logic previous_target_valid;
  wire live_transition = history_valid && previous_reset && rst_n;

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_clear <= clear_counters;
    previous_accept <= rtl_observed.capture_accepted;
    previous_reject <= rtl_observed.capture_rejected;
    previous_target_valid <= rtl_observed.registered_target_valid_q;
  end

  // State correspondence is proved, never assumed or forced at initialization.
  always_comb begin
    if (!history_valid) assume (!rst_n);
    mismatch[0] = rtl_observed.registered_target_q != netlist_observed.registered_target_q;
    mismatch[1] = rtl_observed.registered_target_valid_q != netlist_observed.registered_target_valid_q;
    mismatch[2] = rtl_observed.phase_target_domain_valid != netlist_observed.phase_target_domain_valid;
    mismatch[3] = rtl_observed.registered_target_domain_valid != netlist_observed.registered_target_domain_valid;
    mismatch[4] = rtl_observed.capture_accepted != netlist_observed.capture_accepted;
    mismatch[5] = rtl_observed.capture_rejected != netlist_observed.capture_rejected;
    mismatch[6] = rtl_observed.accepted_capture_events_q != netlist_observed.accepted_capture_events_q;
    mismatch[7] = rtl_observed.rejected_capture_events_q != netlist_observed.rejected_capture_events_q;
    mismatch[8] = rtl_observed.registered_request_enable != netlist_observed.registered_request_enable;
    mismatch[9] = rtl_observed.phase_request_valid != netlist_observed.phase_request_valid;
    mismatch[10] = rtl_observed.phase_request_cell_index != netlist_observed.phase_request_cell_index;
    mismatch[11] = rtl_observed.phase_request_target != netlist_observed.phase_request_target;
    if (history_valid) begin
      a_registered_target_q: assert (!mismatch[0]);
      a_registered_target_valid_q: assert (!mismatch[1]);
      a_phase_target_domain_valid: assert (!mismatch[2]);
      a_registered_target_domain_valid: assert (!mismatch[3]);
      a_capture_accepted: assert (!mismatch[4]);
      a_capture_rejected: assert (!mismatch[5]);
      a_accepted_capture_events_q: assert (!mismatch[6]);
      a_rejected_capture_events_q: assert (!mismatch[7]);
      a_registered_request_enable: assert (!mismatch[8]);
      a_phase_request_valid: assert (!mismatch[9]);
      a_phase_request_cell_index: assert (!mismatch[10]);
      a_phase_request_target: assert (!mismatch[11]);
    end
  end

  function automatic logic polarized(input logic [1:0] code);
    return code == 2'b01 || code == 2'b11;
  endfunction

  function automatic logic opposite(input logic [1:0] a, b);
    return (a == 2'b01 && b == 2'b11) || (a == 2'b11 && b == 2'b01);
  endfunction

  // Six-step satisfiability targets exercise the comparison without adding
  // assumptions. They do not replace the unbounded induction proof above.
  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = rtl_observed.capture_accepted
        && phase_target_source != rtl_observed.registered_target_q;
      reach[1] = rtl_observed.capture_rejected && rtl_observed.registered_target_valid_q;
      reach[2] = !tick_enable && phase_target_valid && rtl_observed.phase_request_valid[0]
        && phase_target_source != rtl_observed.registered_target_q;
      reach[3] = tick_enable && !phase_target_valid && rtl_observed.phase_request_valid[0]
        && phase_target_source != rtl_observed.registered_target_q;
      reach[4] = !auto_target_enable && rtl_observed.registered_target_valid_q
        && retained_state == 0 && pending_route == 0 && scheduler_state == 0
        && rtl_observed.registered_target_q != 0;
      reach[5] = scheduler_state == 3'd0 && rtl_observed.phase_request_valid == 2'b11;
      reach[6] = scheduler_state == 3'd1 && rtl_observed.phase_request_valid[0]
        && rtl_observed.phase_request_cell_index[2:0] == 0
        && opposite(retained_state[1:0], rtl_observed.phase_request_target[1:0]);
      reach[7] = scheduler_state == 3'd2 && rtl_observed.phase_request_valid[0]
        && rtl_observed.phase_request_cell_index[2:0] == 0 && retained_state[1:0] == 0;
      reach[8] = scheduler_state == 3'd3 && rtl_observed.phase_request_valid[0]
        && rtl_observed.phase_request_cell_index[2:0] == 0 && retained_state[1:0] == 0;
      reach[9] = scheduler_state == 3'd4 && rtl_observed.phase_request_valid[0]
        && rtl_observed.phase_request_cell_index[2:0] == 0
        && opposite(retained_state[1:0], rtl_observed.phase_request_target[1:0]);
      reach[10] = rtl_observed.registered_request_enable && polarized(pending_route[1:0])
        && retained_state[1:0] != 2'b10 && retained_state[1:0] != rtl_observed.registered_target_q[1:0]
        && rtl_observed.phase_request_valid[0] && rtl_observed.phase_request_cell_index[2:0] != 0;
      reach[11] = rtl_observed.registered_request_enable && scheduler_state >= 3'd5
        && rtl_observed.phase_request_valid == 0;
      reach[12] = live_transition && previous_clear && previous_accept
        && rtl_observed.registered_target_valid_q;
      reach[13] = live_transition && previous_clear && previous_reject
        && rtl_observed.registered_target_valid_q;
      reach[15] = rtl_observed.phase_request_valid[0]
        && rtl_observed.phase_request_cell_index[2:0] == 3'd7;
    end
    reach[14] = history_valid && previous_reset && !rst_n && previous_target_valid;
  end
endmodule

`endif

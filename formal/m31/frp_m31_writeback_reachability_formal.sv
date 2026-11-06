// SPDX-License-Identifier: Apache-2.0
// Writeback invariants under unrestricted public input codes and metadata.
// The first sampled cycle is in reset; subsequent resets are unrestricted.
// Formal time denotes sampled rising edges after async2sync.
// Coverage guards in frp_m31_state_update.sv: 468, 476, 502, 517, 550.
`ifndef FRP_M31_WRITEBACK_REACHABILITY_FORMAL_SV
`define FRP_M31_WRITEBACK_REACHABILITY_FORMAL_SV
`include "frp_m31_state_update.sv"

module frp_m31_writeback_reachability_formal #(
  parameter int CELLS = 9,
  parameter int LANES = 3
) (
  input logic clk, rst_n, tick_enable,
  input logic [2:0] scheduler_code,
  input logic [2*CELLS-1:0] candidate,
  input logic [CELLS-1:0] capacity, accepted, neutral_route,
  input logic [CELLS-1:0] pending_complete, reserved_transition, direct_flag,
  output wire [2*CELLS-1:0] state_q, state_d,
  output wire [CELLS-1:0] write_mask,
  output logic [4:0] guard_ok,
  output logic [11:0] reach
);
  import frp_m31_pkg::*;
  initial begin
    a_size: assert (CELLS >= 2 && CELLS <= 64);
    a_lanes: assert (LANES >= 1 && LANES <= CELLS);
  end
  wire [2*CELLS-1:0] visible;
  wire [CELLS-1:0] hold_mask, reset_mask;
  wire [31:0] writes, holds, resets, direct_events;
  wire update_valid, output_valid, capacity_valid, no_reserved, no_direct;
  frp_m31_state_update #(
    .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES), .COUNTER_BITS(32)
  ) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .scheduler_state(frp_m31_scheduler_state_e'(scheduler_code)),
    .state_candidate_d(candidate), .capacity_accept_mask(capacity),
    .accepted_change_candidate_mask(accepted), .neutral_routed_mask(neutral_route),
    .pending_completion_mask(pending_complete), .reserved_transition_mask(reserved_transition),
    .actual_direct_mask(direct_flag), .state_q(state_q), .state_d(state_d),
    .state_out(visible), .state_write_enable_mask(write_mask),
    .state_hold_mask(hold_mask), .state_reset_mask(reset_mask),
    .state_write_events(writes), .state_hold_events(holds), .state_reset_events(resets),
    .actual_direct_events(direct_events),
    .state_update_valid(update_valid), .state_output_domain_valid(output_valid),
    .state_write_capacity_valid(capacity_valid),
    .no_reserved_state_output(no_reserved), .no_actual_direct_events(no_direct)
  );

  logic history_valid = 0;
  logic previous_reset, previous_tick;
  logic [2*CELLS-1:0] previous_q, previous_d;
  always_comb begin
    if (!history_valid) initial_reset: assume (!rst_n);
  end
  always @(posedge clk) begin
    history_valid <= 1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_q <= state_q;
    previous_d <= state_d;
  end

  function automatic bit polarized(input logic [1:0] value);
    return value == 2'b01 || value == 2'b11;
  endfunction

  logic current_domain;
  logic [CELLS-1:0] changed;
  logic neutral_phase, commit_phase;
  always_comb begin
    neutral_phase = scheduler_code == 0 || scheduler_code == 1 || scheduler_code == 4;
    commit_phase = scheduler_code == 0 || scheduler_code == 2 || scheduler_code == 3;
    current_domain = 1;
    changed = '0;
    guard_ok = '1;
    for (int c = 0; c < CELLS; c++) begin
      changed[c] = state_q[2*c+:2] != state_d[2*c+:2];
      current_domain &= state_q[2*c+:2] != 2'b10;
      guard_ok[0] &= state_d[2*c+:2] != 2'b10;
      guard_ok[1] &= !(polarized(state_q[2*c+:2]) && polarized(state_d[2*c+:2]) && changed[c]);
      guard_ok[2] &= !changed[c] || (capacity[c] && accepted[c]);
      guard_ok[3] &= !(changed[c] && neutral_route[c]) ||
          (polarized(state_q[2*c+:2]) && state_d[2*c+:2] == 0 && neutral_phase);
      guard_ok[4] &= !(changed[c] && pending_complete[c]) ||
          (state_q[2*c+:2] == 0 && polarized(state_d[2*c+:2]) && commit_phase);
    end
    if (history_valid) begin
      a_current_domain: assert (current_domain);
      a_output_domain: assert (guard_ok[0]);
      a_no_direct: assert (guard_ok[1]);
      a_public_state: assert (visible == state_q);
      if (!rst_n || !previous_reset) begin
        a_reset_register: assert (state_q == 0);
      end else if (previous_tick) begin
        a_commit_register: assert (state_q == previous_d);
      end else begin
        a_pause_register: assert (state_q == previous_q);
      end
      if (rst_n) begin
        a_qualified_write: assert (guard_ok[2]);
        a_neutral_write: assert (guard_ok[3]);
        a_pending_write: assert (guard_ok[4]);
        a_masks: assert (write_mask == changed && hold_mask == ~changed && reset_mask == 0);
        a_output_flags: assert (output_valid && no_reserved && no_direct && direct_events == 0);
        if (!tick_enable) a_disabled_tick: assert (state_d == state_q);
        if (writes > LANES) a_lane_diagnostic: assert (!capacity_valid && !update_valid);
      end else begin
        a_reset_outputs: assert (state_d == 0 && write_mask == 0 && hold_mask == 0 &&
            reset_mask == {CELLS{1'b1}} && resets == CELLS && writes == 0 && holds == 0);
      end
    end
  end

  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = state_q[1:0] == 2'b01;
      reach[1] = state_q[1:0] == 2'b11;
      reach[2] = changed[0] && neutral_route[0];
      reach[3] = changed[0] && pending_complete[0];
      reach[4] = state_q != 0 && !tick_enable;
      reach[5] = write_mask == {CELLS{1'b1}};
      reach[6] = writes > LANES && !capacity_valid && !update_valid;
      reach[7] = candidate[1:0] == 2'b10 && capacity[0] && accepted[0] &&
          tick_enable && !changed[0] && !update_valid;
      reach[8] = scheduler_code >= 5 && tick_enable && state_q != 0 &&
          state_d == state_q && !update_valid;
      reach[10] = changed[CELLS-1];
      reach[11] = state_q[1:0] == 2'b01 && state_q[3:2] == 2'b11;
    end
    reach[9] = history_valid && previous_reset && !rst_n && previous_q != 0;
  end
endmodule
`endif

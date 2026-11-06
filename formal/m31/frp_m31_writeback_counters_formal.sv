// SPDX-License-Identifier: Apache-2.0
// Public-output writeback counter identities with unrestricted input metadata.
// CHECK=0 selects all groups; CHECK=1..7 selects one arithmetic group.
// Groups: writes/aliases, holds, resets, neutral, pending, reserved, direct.
// Formal time denotes sampled rising edges after async2sync.
// No reset or input-domain assumptions are imposed.
`ifndef FRP_M31_WRITEBACK_COUNTERS_FORMAL_SV
`define FRP_M31_WRITEBACK_COUNTERS_FORMAL_SV
`include "frp_m31_state_update.sv"

module frp_m31_writeback_counters_formal #(
  parameter int CELLS = 9,
  parameter int LANES = 3,
  parameter int CHECK = 0
) (
  input logic clk, rst_n, tick_enable,
  input logic [2:0] scheduler_code,
  input logic [2*CELLS-1:0] candidate,
  input logic [CELLS-1:0] capacity, accepted, neutral_route,
  input logic [CELLS-1:0] pending_complete, reserved_transition, direct_flag,
  output wire [2*CELLS-1:0] state_q, state_d,
  output logic [7:0] reach
);
  import frp_m31_pkg::*;
  initial begin
    a_cells: assert (CELLS >= 2 && CELLS <= 64);
    a_lanes: assert (LANES >= 1 && LANES <= CELLS);
    a_check: assert (CHECK >= 0 && CHECK <= 7);
  end
  wire [CELLS-1:0] write_mask, hold_mask, reset_mask, reserved_mask;
  wire [31:0] changes, load, writes, holds, resets, accepted_events;
  wire [31:0] neutral_events, pending_events, reserved_events, direct_events;
  frp_m31_state_update #(
    .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES), .COUNTER_BITS(32)
  ) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .scheduler_state(frp_m31_scheduler_state_e'(scheduler_code)),
    .state_candidate_d(candidate), .capacity_accept_mask(capacity),
    .accepted_change_candidate_mask(accepted), .neutral_routed_mask(neutral_route),
    .pending_completion_mask(pending_complete), .reserved_transition_mask(reserved_transition),
    .actual_direct_mask(direct_flag), .state_q(state_q), .state_d(state_d),
    .state_write_enable_mask(write_mask), .state_hold_mask(hold_mask),
    .state_reset_mask(reset_mask), .state_reserved_mask(reserved_mask),
    .accepted_changes(changes), .switch_load_numerator(load),
    .state_write_events(writes), .state_hold_events(holds), .state_reset_events(resets),
    .accepted_change_events(accepted_events), .neutral_routed_commit_events(neutral_events),
    .pending_completion_commit_events(pending_events), .reserved_state_events(reserved_events),
    .actual_direct_events(direct_events)
  );

  logic [31:0] count_write, count_hold, count_reset, count_neutral;
  logic [31:0] count_pending, count_reserved, count_direct;
  logic [CELLS-1:0] changed, neutral_commit, pending_commit, direct_commit;
  function automatic bit polarized(input logic [1:0] value);
    return value == 2'b01 || value == 2'b11;
  endfunction
  always_comb begin
    count_write = 0;
    count_hold = 0;
    count_reset = 0;
    count_neutral = 0;
    count_pending = 0;
    count_reserved = 0;
    count_direct = 0;
    for (int c = 0; c < CELLS; c++) begin
      changed[c] = state_q[2*c+:2] != state_d[2*c+:2];
      neutral_commit[c] = changed[c] && neutral_route[c] &&
          polarized(state_q[2*c+:2]) && state_d[2*c+:2] == 0 &&
          (scheduler_code == 0 || scheduler_code == 1 || scheduler_code == 4);
      pending_commit[c] = changed[c] && pending_complete[c] &&
          state_q[2*c+:2] == 0 && polarized(state_d[2*c+:2]) &&
          (scheduler_code == 0 || scheduler_code == 2 || scheduler_code == 3);
      direct_commit[c] = changed[c] && polarized(state_q[2*c+:2]) &&
          polarized(state_d[2*c+:2]);
      if (write_mask[c]) count_write = count_write + 32'd1;
      if (hold_mask[c]) count_hold = count_hold + 32'd1;
      if (reset_mask[c]) count_reset = count_reset + 32'd1;
      if (rst_n && neutral_commit[c]) count_neutral = count_neutral + 32'd1;
      if (rst_n && pending_commit[c]) count_pending = count_pending + 32'd1;
      if (reserved_mask[c]) count_reserved = count_reserved + 32'd1;
      if (rst_n && direct_commit[c]) count_direct = count_direct + 32'd1;
    end
    if (CHECK == 0 || CHECK == 1) begin
      a_writes: assert (writes == count_write);
      a_changes: assert (changes == count_write);
      a_load: assert (load == count_write);
      a_accepted: assert (accepted_events == count_write);
    end
    if (CHECK == 0 || CHECK == 2) a_holds: assert (holds == count_hold);
    if (CHECK == 0 || CHECK == 3) a_resets: assert (resets == count_reset);
    if (CHECK == 0 || CHECK == 4) a_neutral: assert (neutral_events == count_neutral);
    if (CHECK == 0 || CHECK == 5) a_pending: assert (pending_events == count_pending);
    if (CHECK == 0 || CHECK == 6) a_reserved: assert (reserved_events == count_reserved);
    if (CHECK == 0 || CHECK == 7) a_direct: assert (direct_events == count_direct);
    reach = '0;
    reach[0] = rst_n && writes == CELLS;
    reach[1] = rst_n && holds == CELLS;
    reach[2] = !rst_n && resets == CELLS;
    reach[3] = rst_n && neutral_events == CELLS;
    reach[4] = rst_n && pending_events == CELLS;
    reach[5] = rst_n && reserved_events == CELLS;
    reach[6] = rst_n && writes == LANES;
    reach[7] = rst_n && writes > LANES;
  end
endmodule
`endif

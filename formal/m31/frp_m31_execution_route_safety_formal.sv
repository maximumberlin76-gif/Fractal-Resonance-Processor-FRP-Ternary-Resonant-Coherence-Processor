// SPDX-License-Identifier: Apache-2.0
// Safety of the real M31 execution block used by the integrated M32 core.
// Fixed profile: eight cells, two request lanes, 32-bit counters.
// Only the initial sampled reset is assumed. Requests, target banks, holds,
// counter clears, subsequent resets and all four mode codes are unrestricted.
// Properties use public outputs and independently recorded previous samples.
// This is execution-route safety, not phase-dynamics equivalence, liveness,
// full-core coverage or physical asynchronous-reset timing qualification.
// Formal steps represent sampled rising edges; use async2sync before SAT.
// Define FRP_M31_ROUTE_SAFETY_NETLIST to check the same properties against a
// freshly synthesized frp_m31_execution_core_netlist with the same interface.

`ifndef FRP_M31_EXECUTION_ROUTE_SAFETY_FORMAL_SV
`define FRP_M31_EXECUTION_ROUTE_SAFETY_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_ROUTE_SAFETY_NETLIST
`include "frp_m31_execution_core.sv"
`endif

module frp_m31_execution_route_safety_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  input logic [1:0] request_valid,
  input logic [5:0] request_cell_index,
  input logic [3:0] request_target,
  input logic [15:0] target_bank,
  output wire [15:0] state_out,
  output wire [15:0] pending_route_out,
  output logic [15:0] reach
);
  import frp_m31_pkg::*;

  wire [1:0] mode_q;
  wire [1:0] request_accept, request_reject;
  wire [7:0] accepted_change_mask;
  wire [31:0] accepted_changes, capacity_remaining, switch_load_numerator;
  wire capacity_exhausted;
  wire [31:0] actual_direct_events, queue_overflow_events;

`ifdef FRP_M31_ROUTE_SAFETY_NETLIST
  frp_m31_execution_core_netlist dut (
`else
  frp_m31_execution_core #(
    .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
    .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
  ) dut (
`endif
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
    .request_valid(request_valid), .request_cell_index(request_cell_index),
    .request_target(request_target), .target_q(target_bank),
    .state_out(state_out), .pending_route_out(pending_route_out),
    .scheduler_mode_q(mode_q), .scheduler_state_q(), .ticks_recorded_q(),
    .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(),
    .scheduler_count_neutralize_q(), .request_accept(request_accept),
    .request_reject(request_reject), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(accepted_change_mask),
    .accepted_changes(accepted_changes), .capacity_remaining(capacity_remaining),
    .capacity_exhausted(capacity_exhausted),
    .switch_load_numerator(switch_load_numerator),
    .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .actual_direct_events(actual_direct_events),
    .reserved_state_events(), .queue_overflow_events(queue_overflow_events),
    .invariant_flags()
  );

  logic history_valid = 0;
  logic previous_reset, previous_tick, previous_clear;
  logic [1:0] previous_mode;
  logic [15:0] previous_state, previous_pending, previous_target;
  logic [7:0] previous_change_mask;
  logic [31:0] previous_changes;
  logic [7:0] changed_cells;
  wire live_transition = history_valid && previous_reset && rst_n;

  // No initial value is imposed on the DUT registers. The initial reset
  // establishes the reachable state through the DUT's real reset logic.
  always_comb begin
    if (!history_valid) assume (!rst_n);
  end

  always @(posedge clk) begin
    history_valid <= 1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear_counters;
    previous_mode <= mode_q;
    previous_state <= state_out;
    previous_pending <= pending_route_out;
    previous_target <= target_bank;
    previous_change_mask <= accepted_change_mask;
    previous_changes <= accepted_changes;
  end

  function automatic logic legal(input logic [1:0] code);
    return code == 2'b00 || code == 2'b01 || code == 2'b11;
  endfunction

  function automatic logic opposite(input logic [1:0] a, b);
    return (a == 2'b01 && b == 2'b11) || (a == 2'b11 && b == 2'b01);
  endfunction

  always_comb begin
    for (int cell_id = 0; cell_id < 8; cell_id++)
      changed_cells[cell_id] = state_out[2*cell_id +: 2] != previous_state[2*cell_id +: 2];
    if (history_valid) begin
      if (!rst_n || !previous_reset) begin
        a_reset_state: assert (state_out == 0);
        a_reset_routes: assert (pending_route_out == 0);
      end
      if (live_transition) begin
        a_change_mask: assert (changed_cells == previous_change_mask);
        a_change_count: assert ($countones(changed_cells) == previous_changes);
        a_transition_capacity: assert ($countones(changed_cells) <= 2);
        if (!previous_tick) begin
          a_held_state: assert (state_out == previous_state);
          a_held_routes: assert (pending_route_out == previous_pending);
        end
      end
      if (rst_n) begin
        a_capacity_limit: assert (accepted_changes <= 2);
        a_capacity_accounting: assert (capacity_remaining + accepted_changes == 2);
        a_capacity_exhaustion: assert (capacity_exhausted == (capacity_remaining == 0));
        a_mask_count: assert ($countones(accepted_change_mask) == accepted_changes);
        a_switch_load: assert (switch_load_numerator == accepted_changes);
        a_no_direct_events: assert (actual_direct_events == 0);
        a_no_overflow: assert (queue_overflow_events == 0);
        a_lane_exclusion: assert ((request_accept & request_reject) == 0);
      end
    end
  end

  for (genvar cell_id = 0; cell_id < 8; cell_id++) begin : cell_safety
    wire [1:0] current = state_out[2*cell_id +: 2];
    wire [1:0] pending = pending_route_out[2*cell_id +: 2];
    wire [1:0] old_state = previous_state[2*cell_id +: 2];
    wire [1:0] old_pending = previous_pending[2*cell_id +: 2];
    always_comb begin
      if (history_valid) begin
        a_state_domain: assert (legal(current));
        a_pending_domain: assert (legal(pending));
        a_pending_at_zero: assert (pending == 0 || current == 0);
        if (live_transition) begin
          a_no_direct_transition: assert (!opposite(old_state, current));
          if (old_pending != 0) begin
            if (pending != 0) begin
              a_saved_destination: assert (pending == old_pending);
              a_waiting_at_zero: assert (current == 0);
            end else begin
              a_completed_destination: assert (current == old_pending);
              a_enabled_completion: assert (previous_tick);
            end
          end else if (pending != 0) begin
            a_opposite_route: assert (opposite(old_state, pending));
            a_first_leg_at_zero: assert (current == 0);
            a_enabled_first_leg: assert (previous_tick);
          end
        end
      end
    end
  end

  // Each reach bit is an independent satisfiability target, not an assumption
  // and not a replacement for proving the safety assertions.
  always_comb begin
    reach = 0;
    if (live_transition) begin
      reach[0] = mode_q == 0 && pending_route_out != 0;
      reach[1] = mode_q == 1 && pending_route_out != 0;
      reach[2] = mode_q == 2 && pending_route_out != 0;
      reach[3] = previous_pending != 0 && !previous_tick;
      reach[4] = pending_route_out != 0 && previous_clear;
      reach[5] = pending_route_out != 0 && target_bank != previous_target;
      reach[6] = previous_pending[1:0] == 3 && pending_route_out[1:0] == 0 && state_out[1:0] == 3;
      reach[7] = previous_pending[1:0] == 1 && pending_route_out[1:0] == 0 && state_out[1:0] == 1;
      reach[8] = previous_pending[15:14] == 3 && pending_route_out[15:14] == 0 && state_out[15:14] == 3;
      reach[9] = previous_pending[15:14] == 1 && pending_route_out[15:14] == 0 && state_out[15:14] == 1;
      reach[10] = previous_state[1:0] == 1 && pending_route_out[1:0] == 3;
      reach[11] = previous_state[1:0] == 3 && pending_route_out[1:0] == 1;
      reach[13] = mode_q == 3 && pending_route_out != 0;
      reach[14] = $countones(changed_cells) == 2;
      reach[15] = pending_route_out != 0 && mode_q != previous_mode;
    end
    reach[12] = history_valid && previous_reset && !rst_n && previous_pending != 0;
  end
endmodule
`endif

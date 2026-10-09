// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent integrated execution contract: eight cells, two request lanes,
// 32-bit counters. All 26 public outputs (556 bits) are checked together.
// The reference owns its registers and computes the architectural result
// without instantiating reference copies of RTL or calling DUT helpers.
// Pending completions have priority by cell rank; accepted request lanes
// then share the remaining two-change budget. Same-state requests are free.
// Direct-request telemetry describes pre-capacity transition generation;
// accepted masks describe post-capacity admission. These are distinct cuts.
// Mode capture occurs even while paused. Counter clear precedes counting
// the old mode's enabled tick and does not restart the cadence index.
//
// Only the initial sampled reset is assumed. All later resets, pauses,
// clears, four mode codes, target-bank codes and requests are unrestricted.
// Temporal induction must prove both its reset base and inductive step.
// Auxiliary cadence and state-domain assertions are proven, never assumed.
// Formal steps are sampled rising edges; use async2sync before SAT.
// Define FRP_M31_EXECUTION_CONTRACT_NETLIST for a freshly synthesized
// frp_m31_execution_core_netlist. Expose its existing tick_index_q and
// period_index_q wires as read-only outputs with Yosys expose before loading
// this harness. This instrumentation changes no logic or architectural port.
// Reach bits 0..31 are separate twelve-step satisfiability targets.
// Scope excludes phase arithmetic, full M32, liveness, physical timing,
// four-state behavior and any claim of complete processor qualification.

`ifndef FRP_M31_EXECUTION_CONTRACT_FORMAL_SV
`define FRP_M31_EXECUTION_CONTRACT_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_EXECUTION_CONTRACT_NETLIST
`include "frp_m31_execution_core.sv"
`endif

module frp_m31_execution_contract_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  input logic [1:0] request_valid,
  input logic [5:0] request_cell_index,
  input logic [3:0] request_target,
  input logic [15:0] target_bank,
  output wire [555:0] observed_outputs,
  output wire [555:0] expected_outputs,
  output wire [31:0] observed_tick_index,
  output wire [2:0] observed_period_index,
  output wire [31:0] expected_tick_index,
  output logic [25:0] mismatch,
  output logic [31:0] reach
);
  typedef struct packed {
    logic [15:0] state_out;
    logic [15:0] pending_route_out;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [31:0] ticks_recorded_q;
    logic [31:0] scheduler_count_free_q;
    logic [31:0] scheduler_count_balance_q;
    logic [31:0] scheduler_count_commit_q;
    logic [31:0] scheduler_count_excite_q;
    logic [31:0] scheduler_count_neutralize_q;
    logic [1:0] request_accept;
    logic [1:0] request_reject;
    logic [7:0] accepted_cell_mask;
    logic [7:0] neutral_routed_cell_mask;
    logic [7:0] accepted_change_mask;
    logic [31:0] accepted_changes;
    logic [31:0] capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load_numerator;
    logic [31:0] requested_direct_events;
    logic [31:0] prevented_direct_events;
    logic [31:0] neutral_routed_events;
    logic [31:0] actual_direct_events;
    logic [31:0] reserved_state_events;
    logic [31:0] queue_overflow_events;
    logic [9:0] invariant_flags;
  } result_t;

  result_t actual, expected;
  assign observed_outputs = actual;
  assign expected_outputs = expected;

`ifdef FRP_M31_EXECUTION_CONTRACT_NETLIST
  frp_m31_execution_core_netlist dut (
`else
  assign observed_tick_index = dut.tick_index_q;
  assign observed_period_index = dut.period_index_q;
  frp_m31_execution_core #(
    .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
    .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
  ) dut (
`endif
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_pkg::frp_m31_scheduler_mode_e'(scheduler_mode)),
    .request_valid(request_valid), .request_cell_index(request_cell_index),
    .request_target(request_target), .target_q(target_bank),
    .state_out(actual.state_out),
    .pending_route_out(actual.pending_route_out),
    .scheduler_mode_q(actual.scheduler_mode_q),
    .scheduler_state_q(actual.scheduler_state_q),
    .ticks_recorded_q(actual.ticks_recorded_q),
    .scheduler_count_free_q(actual.scheduler_count_free_q),
    .scheduler_count_balance_q(actual.scheduler_count_balance_q),
    .scheduler_count_commit_q(actual.scheduler_count_commit_q),
    .scheduler_count_excite_q(actual.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(actual.scheduler_count_neutralize_q),
    .request_accept(actual.request_accept),
    .request_reject(actual.request_reject),
    .accepted_cell_mask(actual.accepted_cell_mask),
    .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
    .accepted_change_mask(actual.accepted_change_mask),
    .accepted_changes(actual.accepted_changes),
    .capacity_remaining(actual.capacity_remaining),
    .capacity_exhausted(actual.capacity_exhausted),
    .switch_load_numerator(actual.switch_load_numerator),
    .requested_direct_events(actual.requested_direct_events),
    .prevented_direct_events(actual.prevented_direct_events),
    .neutral_routed_events(actual.neutral_routed_events),
    .actual_direct_events(actual.actual_direct_events),
    .reserved_state_events(actual.reserved_state_events),
    .queue_overflow_events(actual.queue_overflow_events),
    .invariant_flags(actual.invariant_flags)
`ifdef FRP_M31_EXECUTION_CONTRACT_NETLIST
    , .tick_index_q(observed_tick_index),
    .period_index_q(observed_period_index)
`endif
  );

  function automatic logic polarized(input logic [1:0] value);
    return value == 1 || value == 3;
  endfunction

  function automatic logic opposite(input logic [1:0] a, b);
    return (a == 1 && b == 3) || (a == 3 && b == 1);
  endfunction

  function automatic logic [3:0] population(input logic [7:0] mask);
    logic [3:0] total;
    total = 0;
    for (int i = 0; i < 8; i++) total += {3'b0, mask[i]};
    return total;
  endfunction

  function automatic logic [2:0] schedule(
    input logic [1:0] mode, input logic [2:0] position
  );
    case (mode)
      0: return 0;
      1: return position == 7 ? 3'd2 : 3'd1;
      2: return position == 0 ? 3'd3 : 3'd4;
      default: return 7;
    endcase
  endfunction

  // Independent retained reference state; no initialization of DUT state.
  logic [15:0] state_ref, pending_ref, next_state, next_pending;
  logic [1:0] mode_ref;
  logic [31:0] index_ref, ticks_ref;
  logic [159:0] counts_ref;
  wire [2:0] phase_ref = schedule(mode_ref, index_ref[2:0]);
  wire commit_phase = phase_ref == 0 || phase_ref == 2 || phase_ref == 3;
  wire neutral_phase = phase_ref == 0 || phase_ref == 1 || phase_ref == 4;
  assign expected_tick_index = index_ref;

  logic [7:0] pending_candidates, completions, lane_cells;
  logic [1:0] admitted, direct, changing;
  logic [2:0] lane_index [0:1];
  logic [1:0] old_value [0:1], wanted [0:1];
  logic [31:0] used, count_sum;
  logic target_domain, duplicate, allowed;

  always_comb begin
    expected = '0;
    expected.state_out = state_ref;
    expected.pending_route_out = pending_ref;
    expected.scheduler_mode_q = mode_ref;
    expected.scheduler_state_q = phase_ref;
    expected.ticks_recorded_q = ticks_ref;
    expected.scheduler_count_free_q = counts_ref[0*32 +: 32];
    expected.scheduler_count_balance_q = counts_ref[1*32 +: 32];
    expected.scheduler_count_commit_q = counts_ref[2*32 +: 32];
    expected.scheduler_count_excite_q = counts_ref[3*32 +: 32];
    expected.scheduler_count_neutralize_q = counts_ref[4*32 +: 32];
    next_state = state_ref;
    next_pending = pending_ref;
    pending_candidates = 0;
    completions = 0;
    lane_cells = 0;
    admitted = 0;
    direct = 0;
    changing = 0;
    target_domain = 1;
    count_sum = 0;
    for (int i = 0; i < 5; i++) count_sum += counts_ref[32*i +: 32];
    for (int i = 0; i < 8; i++) begin
      if (target_bank[2*i +: 2] == 2) target_domain = 0;
      pending_candidates[i] = tick_enable && commit_phase
        && state_ref[2*i +: 2] == 0 && polarized(pending_ref[2*i +: 2]);
    end
    // Ranking is independent of the DUT's mutable capacity loop.
    for (int i = 0; i < 8; i++) begin
      completions[i] = pending_candidates[i]
        && population(pending_candidates & (8'hff >> (8-i))) < 2;
      if (completions[i]) begin
        next_state[2*i +: 2] = pending_ref[2*i +: 2];
        next_pending[2*i +: 2] = 0;
      end
    end
    expected.accepted_change_mask = completions;
    used = {28'b0, population(completions)};
    for (int lane = 0; lane < 2; lane++) begin
      lane_index[lane] = request_cell_index[3*lane +: 3];
      old_value[lane] = state_ref[2*lane_index[lane] +: 2];
      wanted[lane] = request_target[2*lane +: 2];
      duplicate = lane == 1 && admitted[0] && lane_index[0] == lane_index[1];
      allowed = phase_ref < 5 && old_value[lane] != 2 && wanted[lane] != 2
        && (old_value[lane] == wanted[lane]
          || (old_value[lane] == 0 && commit_phase)
          || (polarized(old_value[lane]) && neutral_phase));
      admitted[lane] = tick_enable && request_valid[lane] && allowed
        && !duplicate && !polarized(pending_ref[2*lane_index[lane] +: 2]);
      direct[lane] = admitted[lane] && opposite(old_value[lane], wanted[lane]);
      changing[lane] = admitted[lane] && old_value[lane] != wanted[lane];
      if (tick_enable && request_valid[lane] && wanted[lane] == 2)
        target_domain = 0;
      // Admission before capacity also owns the duplicate-lane decision.
      if (admitted[lane]) begin
        lane_cells[lane_index[lane]] = 1;
        if (!changing[lane] || used < 2) begin
          expected.request_accept[lane] = 1;
          expected.accepted_cell_mask[lane_index[lane]] = 1;
          if (changing[lane]) begin
            expected.accepted_change_mask[lane_index[lane]] = 1;
            used += 1;
            next_state[2*lane_index[lane] +: 2] = direct[lane] ? 2'd0 : wanted[lane];
            if (direct[lane]) begin
              expected.neutral_routed_cell_mask[lane_index[lane]] = 1;
              next_pending[2*lane_index[lane] +: 2] = wanted[lane];
            end
          end
        end
      end
    end
    expected.request_reject = request_valid & {2{tick_enable}} & ~expected.request_accept;
    expected.accepted_changes = used;
    expected.capacity_remaining = 2 - used;
    expected.capacity_exhausted = used == 2;
    expected.switch_load_numerator = used;
    expected.requested_direct_events = {28'b0, population({6'b0, direct})};
    expected.prevented_direct_events = expected.requested_direct_events;
    expected.neutral_routed_events = expected.requested_direct_events;
    // Canonical reachable state makes direct writes, reserved-state emission
    // and pending overwrite impossible; invalid inputs still affect diagnostics.
    expected.invariant_flags = 10'h3ff;
    expected.invariant_flags[0] = target_domain;
    expected.invariant_flags[1] = mode_ref != 3 && count_sum == ticks_ref;
    expected.invariant_flags[2] = target_domain;
    expected.invariant_flags[4] = phase_ref < 5;
    expected.invariant_flags[5] = phase_ref < 5 && (rst_n || used == 0);
    expected.invariant_flags[6] = phase_ref < 5;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_ref <= 0;
      pending_ref <= 0;
      mode_ref <= 0;
      index_ref <= 0;
      ticks_ref <= 0;
      counts_ref <= 0;
    end else begin
      mode_ref <= scheduler_mode;
      index_ref <= index_ref + {31'b0, tick_enable};
      ticks_ref <= (clear_counters ? 32'd0 : ticks_ref) + {31'b0, tick_enable};
      for (int i = 0; i < 5; i++)
        counts_ref[32*i +: 32] <= (clear_counters ? 32'd0 : counts_ref[32*i +: 32])
          + {31'b0, (tick_enable && phase_ref == i)};
      if (tick_enable) begin
        state_ref <= next_state;
        pending_ref <= next_pending;
      end
    end
  end

  logic history_valid = 0;
  logic previous_reset, previous_tick, previous_clear;
  logic [1:0] previous_mode;
  logic [15:0] previous_state, previous_pending, previous_target;
  logic [31:0] previous_ticks, previous_index;
  always @(posedge clk) begin
    history_valid <= 1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_clear <= clear_counters;
    previous_mode <= mode_ref;
    previous_state <= state_ref;
    previous_pending <= pending_ref;
    previous_target <= target_bank;
    previous_ticks <= ticks_ref;
    previous_index <= index_ref;
  end

  always_comb begin
    if (!history_valid) assume (!rst_n);
    if (history_valid) begin
      a_cadence_index: assert (observed_tick_index == index_ref);
      a_cadence_period: assert (observed_period_index == index_ref[2:0]);
    end
  end

  for (genvar i = 0; i < 8; i++) begin : reachable_state
    always_comb begin
      if (history_valid) begin
        a_state_domain: assert (state_ref[2*i +: 2] != 2);
        a_pending_domain: assert (pending_ref[2*i +: 2] != 2);
        a_pending_at_zero: assert (pending_ref[2*i +: 2] == 0 || state_ref[2*i +: 2] == 0);
      end
    end
  end

  // Each mismatch bit covers a complete public field, including counter MSBs.
  always_comb begin
    mismatch[0] = actual.state_out != expected.state_out;
    if (history_valid) a_state_out: assert (!mismatch[0]);
  end
  always_comb begin
    mismatch[1] = actual.pending_route_out != expected.pending_route_out;
    if (history_valid) a_pending_route_out: assert (!mismatch[1]);
  end
  always_comb begin
    mismatch[2] = actual.scheduler_mode_q != expected.scheduler_mode_q;
    if (history_valid) a_scheduler_mode_q: assert (!mismatch[2]);
  end
  always_comb begin
    mismatch[3] = actual.scheduler_state_q != expected.scheduler_state_q;
    if (history_valid) a_scheduler_state_q: assert (!mismatch[3]);
  end
  always_comb begin
    mismatch[4] = actual.ticks_recorded_q != expected.ticks_recorded_q;
    if (history_valid) a_ticks_recorded_q: assert (!mismatch[4]);
  end
  always_comb begin
    mismatch[5] = actual.scheduler_count_free_q != expected.scheduler_count_free_q;
    if (history_valid) a_scheduler_count_free_q: assert (!mismatch[5]);
  end
  always_comb begin
    mismatch[6] = actual.scheduler_count_balance_q != expected.scheduler_count_balance_q;
    if (history_valid) a_scheduler_count_balance_q: assert (!mismatch[6]);
  end
  always_comb begin
    mismatch[7] = actual.scheduler_count_commit_q != expected.scheduler_count_commit_q;
    if (history_valid) a_scheduler_count_commit_q: assert (!mismatch[7]);
  end
  always_comb begin
    mismatch[8] = actual.scheduler_count_excite_q != expected.scheduler_count_excite_q;
    if (history_valid) a_scheduler_count_excite_q: assert (!mismatch[8]);
  end
  always_comb begin
    mismatch[9] = actual.scheduler_count_neutralize_q != expected.scheduler_count_neutralize_q;
    if (history_valid) a_scheduler_count_neutralize_q: assert (!mismatch[9]);
  end
  always_comb begin
    mismatch[10] = actual.request_accept != expected.request_accept;
    if (history_valid) a_request_accept: assert (!mismatch[10]);
  end
  always_comb begin
    mismatch[11] = actual.request_reject != expected.request_reject;
    if (history_valid) a_request_reject: assert (!mismatch[11]);
  end
  always_comb begin
    mismatch[12] = actual.accepted_cell_mask != expected.accepted_cell_mask;
    if (history_valid) a_accepted_cell_mask: assert (!mismatch[12]);
  end
  always_comb begin
    mismatch[13] = actual.neutral_routed_cell_mask != expected.neutral_routed_cell_mask;
    if (history_valid) a_neutral_routed_cell_mask: assert (!mismatch[13]);
  end
  always_comb begin
    mismatch[14] = actual.accepted_change_mask != expected.accepted_change_mask;
    if (history_valid) a_accepted_change_mask: assert (!mismatch[14]);
  end
  always_comb begin
    mismatch[15] = actual.accepted_changes != expected.accepted_changes;
    if (history_valid) a_accepted_changes: assert (!mismatch[15]);
  end
  always_comb begin
    mismatch[16] = actual.capacity_remaining != expected.capacity_remaining;
    if (history_valid) a_capacity_remaining: assert (!mismatch[16]);
  end
  always_comb begin
    mismatch[17] = actual.capacity_exhausted != expected.capacity_exhausted;
    if (history_valid) a_capacity_exhausted: assert (!mismatch[17]);
  end
  always_comb begin
    mismatch[18] = actual.switch_load_numerator != expected.switch_load_numerator;
    if (history_valid) a_switch_load_numerator: assert (!mismatch[18]);
  end
  always_comb begin
    mismatch[19] = actual.requested_direct_events != expected.requested_direct_events;
    if (history_valid) a_requested_direct_events: assert (!mismatch[19]);
  end
  always_comb begin
    mismatch[20] = actual.prevented_direct_events != expected.prevented_direct_events;
    if (history_valid) a_prevented_direct_events: assert (!mismatch[20]);
  end
  always_comb begin
    mismatch[21] = actual.neutral_routed_events != expected.neutral_routed_events;
    if (history_valid) a_neutral_routed_events: assert (!mismatch[21]);
  end
  always_comb begin
    mismatch[22] = actual.actual_direct_events != expected.actual_direct_events;
    if (history_valid) a_actual_direct_events: assert (!mismatch[22]);
  end
  always_comb begin
    mismatch[23] = actual.reserved_state_events != expected.reserved_state_events;
    if (history_valid) a_reserved_state_events: assert (!mismatch[23]);
  end
  always_comb begin
    mismatch[24] = actual.queue_overflow_events != expected.queue_overflow_events;
    if (history_valid) a_queue_overflow_events: assert (!mismatch[24]);
  end
  always_comb begin
    mismatch[25] = actual.invariant_flags != expected.invariant_flags;
    if (history_valid) a_invariant_flags: assert (!mismatch[25]);
  end

  // Witness predicates impose no assumptions on any input or DUT register.
  always_comb begin
    reach = 0;
    if (history_valid && rst_n) begin
      reach[0] = expected.request_accept == 3 && used == 2 && completions == 0;
      reach[1] = expected.request_accept == 3 && used == 0;
      reach[2] = admitted == 1 && request_valid == 3 && lane_index[0] == lane_index[1];
      reach[3] = admitted == 2 && request_valid == 3 && wanted[0] == 2 && lane_index[0] == lane_index[1];
      reach[4] = direct == 3 && expected.request_accept == 3;
      reach[5] = direct[0] && old_value[0] == 1 && expected.request_accept[0];
      reach[6] = direct[0] && old_value[0] == 3 && expected.request_accept[0];
      reach[7] = population(pending_candidates) > 2 && population(completions) == 2;
      reach[8] = population(completions) == 2 && admitted[0] && changing[0] && !expected.request_accept[0];
      reach[9] = population(completions) == 2 && expected.request_accept[0] && !changing[0];
      reach[10] = population(completions) == 1 && admitted == 3 && changing == 3 && expected.request_accept == 1;
      reach[11] = population(completions) == 2 && direct != 0 && expected.neutral_routed_cell_mask == 0;
      reach[12] = pending_ref != 0 && tick_enable && phase_ref == 1;
      reach[13] = pending_ref != 0 && tick_enable && phase_ref == 4;
      reach[14] = pending_ref != 0 && phase_ref == 7 && request_valid == 3;
      reach[15] = !tick_enable && pending_ref != 0 && request_valid == 3;
      reach[16] = completions[7] && pending_ref[15:14] == 1;
      reach[17] = completions[7] && pending_ref[15:14] == 3;
      reach[18] = phase_ref == 2 && completions != 0;
      reach[19] = phase_ref == 3 && completions != 0;
      reach[20] = target_bank == 16'haaaa && expected.request_accept == 3 && !target_domain;
      reach[21] = !tick_enable && request_target == 4'ha && target_bank == 0 && target_domain;
      reach[22] = tick_enable && request_valid[0] && polarized(pending_ref[2*lane_index[0] +: 2])
        && !expected.request_accept[0] && completions[lane_index[0]];
      reach[23] = scheduler_mode == 3 && mode_ref != 3 && expected.request_accept != 0;
    end
    if (history_valid && previous_reset && rst_n) begin
      reach[24] = previous_clear && previous_tick && ticks_ref == 1 && pending_ref != 0;
      reach[25] = previous_clear && !previous_tick && ticks_ref == 0 && index_ref != 0;
      reach[26] = previous_mode != mode_ref && !previous_tick && pending_ref != 0;
      reach[27] = previous_mode == 3 && previous_tick && mode_ref != 3 && !expected.invariant_flags[1];
      reach[28] = previous_pending != 0 && target_bank != previous_target && pending_ref == previous_pending && !previous_tick;
      reach[29] = previous_pending != 0 && pending_ref == 0 && state_ref != previous_state;
      reach[30] = previous_clear && previous_tick && previous_mode == 3 && ticks_ref == 1 && counts_ref == 0;
    end
    reach[31] = history_valid && previous_reset && !rst_n && previous_pending != 0;
  end
endmodule

`endif

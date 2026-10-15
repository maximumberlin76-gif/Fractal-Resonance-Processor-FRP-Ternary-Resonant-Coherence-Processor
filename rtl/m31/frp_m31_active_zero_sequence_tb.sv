// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Active-zero execution sequences on the integrated M31 execution core.
// Independent integer oracle; only public DUT ports are observed.
// Sweep: cells x lanes x directions x modes x positions x pauses x endings.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_active_zero_sequence_tb #(
  parameter int CELLS = 8,
  localparam int LANES = CELLS/4,
  localparam int INDEX_BITS = $clog2(CELLS)
);
  import frp_m31_pkg::*;
  bit clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [LANES-1:0] request_valid = 0, request_accept, request_reject;
  logic [LANES*INDEX_BITS-1:0] request_cell_index = 0;
  logic [LANES*2-1:0] request_target = 0;
  logic [CELLS*2-1:0] target_q = 0, state_out, pending_route_out;
  logic [CELLS-1:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q, scheduler_count_balance_q;
  logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q;
  logic [31:0] scheduler_count_neutralize_q, accepted_changes, capacity_remaining;
  logic [31:0] switch_load_numerator, requested_direct_events, prevented_direct_events;
  logic [31:0] neutral_routed_events, actual_direct_events, reserved_state_events;
  logic [31:0] queue_overflow_events;
  logic capacity_exhausted;
  logic [9:0] invariant_flags;
  int state_ref[CELLS], pending_ref[CELLS], counts_ref[5];
  int mode_ref = 0, position_ref = 0, ticks_ref = 0;
  int cell_id = 0, lane_id = 0, destination = 0;
  int cases = 0, cycles = 0, checks = 0, resets = 0;
  int routes = 0, completions = 0, aborted = 0, handovers = 0;
  int paused_pending = 0, deferred_pending = 0, busy_rejections = 0;
  int route_cycle[CELLS], route_tick[CELLS];
  int completed_hits[3][8][CELLS][LANES][2];
  int aborted_hits[3][8][CELLS][LANES][2];
  logic [63:0] signature = 64'hcbf29ce484222325;

  frp_m31_execution_core #(
    .CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(INDEX_BITS)
  ) dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .scheduler_mode,
    .request_valid, .request_cell_index, .request_target, .target_q,
    .state_out, .pending_route_out, .scheduler_mode_q, .scheduler_state_q,
    .ticks_recorded_q, .scheduler_count_free_q, .scheduler_count_balance_q,
    .scheduler_count_commit_q, .scheduler_count_excite_q, .scheduler_count_neutralize_q,
    .request_accept, .request_reject, .accepted_cell_mask, .neutral_routed_cell_mask,
    .accepted_change_mask, .accepted_changes, .capacity_remaining, .capacity_exhausted,
    .switch_load_numerator, .requested_direct_events, .prevented_direct_events,
    .neutral_routed_events, .actual_direct_events, .reserved_state_events,
    .queue_overflow_events, .invariant_flags
  );

  function automatic logic [1:0] enc(input int value);
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: return 2'b10;
    endcase
  endfunction
  function automatic int schedule(input int mode, position);
    case (mode)
      0: return 0;
      1: return position == 7 ? 2 : 1;
      2: return position == 0 ? 3 : 4;
      default: return 7;
    endcase
  endfunction
  function automatic bit allows(input int sched, old_value, new_value);
    if (old_value == new_value) return 1;
    case (sched)
      0: return 1;
      1, 4: return old_value != 0;
      2, 3: return old_value == 0;
      default: return 0;
    endcase
  endfunction
  task automatic eq(input logic [63:0] got, expected, input string label_text);
    checks++;
    if (got !== expected)
      $fatal(1, "cells=%0d case=%0d cycle=%0d cell=%0d lane=%0d %s got=%h expected=%h",
        CELLS, cases, cycles, cell_id, lane_id, label_text, got, expected);
    signature = (signature ^ expected) * 64'h100000001b3;
  endtask
  task automatic check_registers;
    for (int c = 0; c < CELLS; c++) begin
      eq(64'(state_out[2*c+:2]), 64'(enc(state_ref[c])), "retained state");
      eq(64'(pending_route_out[2*c+:2]), 64'(enc(pending_ref[c])), "pending polarity");
    end
    eq(64'(scheduler_mode_q), 64'(mode_ref), "scheduler mode");
    eq(64'(scheduler_state_q), 64'(schedule(mode_ref, position_ref)), "scheduler position");
    eq(64'(ticks_recorded_q), 64'(ticks_ref), "enabled ticks since clear");
    eq(64'(scheduler_count_free_q), 64'(counts_ref[0]), "free count");
    eq(64'(scheduler_count_balance_q), 64'(counts_ref[1]), "balance count");
    eq(64'(scheduler_count_commit_q), 64'(counts_ref[2]), "commit count");
    eq(64'(scheduler_count_excite_q), 64'(counts_ref[3]), "excite count");
    eq(64'(scheduler_count_neutralize_q), 64'(counts_ref[4]), "neutralize count");
  endtask
  task automatic drive(input bit valid, input int value);
    request_valid = '0; request_cell_index = '0; request_target = '0;
    destination = value;
    request_valid[lane_id] = valid;
    request_cell_index[lane_id*INDEX_BITS+:INDEX_BITS] = INDEX_BITS'(cell_id);
    request_target[lane_id*2+:2] = enc(value);
  endtask

  task automatic cycle;
    int next_state[CELLS], next_pending[CELLS];
    int sched, used, opposite_count;
    bit release_ok, accepted, opposite;
    logic [LANES-1:0] accept_ref, reject_ref;
    logic [CELLS-1:0] writes_ref, cells_ref, neutral_ref;
    logic [CELLS*2-1:0] before_state;
    #1;
    check_registers();
    before_state = state_out;
    sched = schedule(mode_ref, position_ref);
    release_ok = sched == 0 || sched == 2 || sched == 3;
    used = 0; opposite_count = 0;
    accept_ref = '0; reject_ref = '0;
    writes_ref = '0; cells_ref = '0; neutral_ref = '0;
    for (int c = 0; c < CELLS; c++) begin
      next_state[c] = state_ref[c]; next_pending[c] = pending_ref[c];
      if (pending_ref[c] != 0) begin
        eq(64'(state_ref[c]), 0, "pending requires active zero");
        if (!tick_enable) paused_pending++;
        else if (!release_ok) deferred_pending++;
        if (tick_enable && release_ok && used < LANES) begin
          if (cycles <= route_cycle[c]) $fatal(1, "Same-cycle route completion");
          // route_tick records the position after the first leg.
          if (position_ref != route_tick[c] && mode_ref == 0)
            $fatal(1, "Unexpected free-mode route age");
          next_state[c] = pending_ref[c]; next_pending[c] = 0;
          writes_ref[c] = 1; used++; completions++;
        end
      end
    end
    if (tick_enable && request_valid[lane_id]) begin
      accepted = pending_ref[cell_id] == 0 &&
        allows(sched, state_ref[cell_id], destination) && used < LANES;
      opposite = state_ref[cell_id] * destination == -1;
      if (accepted) begin
        accept_ref[lane_id] = 1; cells_ref[cell_id] = 1;
        if (state_ref[cell_id] != destination) begin
          writes_ref[cell_id] = 1; used++;
          if (opposite) begin
            next_state[cell_id] = 0; next_pending[cell_id] = destination;
            neutral_ref[cell_id] = 1; opposite_count++; routes++;
            route_cycle[cell_id] = cycles;
            route_tick[cell_id] = (position_ref + 1) % 8;
          end else next_state[cell_id] = destination;
        end
      end else begin
        reject_ref[lane_id] = 1;
        if (pending_ref[cell_id] != 0) busy_rejections++;
      end
    end
    eq(64'(request_accept), 64'(accept_ref), "accepted lane");
    eq(64'(request_reject), 64'(reject_ref), "rejected lane");
    eq(64'(accepted_cell_mask), 64'(cells_ref), "accepted cell");
    eq(64'(neutral_routed_cell_mask), 64'(neutral_ref), "neutral route");
    eq(64'(accepted_change_mask), 64'(writes_ref), "write mask");
    eq(64'(accepted_changes), 64'(used), "write count");
    eq(64'(capacity_remaining), 64'(LANES-used), "remaining capacity");
    eq(64'(capacity_exhausted), 64'(used == LANES), "capacity exhausted");
    eq(64'(switch_load_numerator), 64'(used), "switch load");
    eq(64'(requested_direct_events), 64'(opposite_count), "opposite requests");
    eq(64'(prevented_direct_events), 64'(opposite_count), "prevented direct");
    eq(64'(neutral_routed_events), 64'(opposite_count), "neutral candidates");
    eq(64'(actual_direct_events), 0, "direct events");
    eq(64'(reserved_state_events), 0, "reserved states");
    eq(64'(queue_overflow_events), 0, "pending overflow");
    eq(64'(invariant_flags), 1023, "execution invariants");
    if (clear_counters) begin
      ticks_ref = 0;
      foreach (counts_ref[k]) counts_ref[k] = 0;
    end
    if (tick_enable) begin
      ticks_ref++; counts_ref[sched]++; position_ref = (position_ref + 1) % 8;
    end
    mode_ref = int'(scheduler_mode);
    for (int c = 0; c < CELLS; c++) begin
      state_ref[c] = next_state[c]; pending_ref[c] = next_pending[c];
    end
    clk = 1; #1;
    check_registers();
    for (int c = 0; c < CELLS; c++) begin
      if ((before_state[2*c+:2] == 2'b11 && state_out[2*c+:2] == 2'b01) ||
          (before_state[2*c+:2] == 2'b01 && state_out[2*c+:2] == 2'b11))
        $fatal(1, "Direct polarity reversal on public retained state");
    end
    clk = 0; #1; cycles++;
  endtask

  task automatic reset_core;
    tick_enable = 0; clear_counters = 0; drive(0, 0);
    scheduler_mode = FRP_MODE_FREE; target_q = '0;
    rst_n = 0; #1;
    foreach (state_ref[c]) begin
      state_ref[c] = 0; pending_ref[c] = 0;
      route_cycle[c] = -1; route_tick[c] = -1;
    end
    foreach (counts_ref[k]) counts_ref[k] = 0;
    mode_ref = 0; position_ref = 0; ticks_ref = 0;
    check_registers();
    clk = 1; #1; clk = 0; #1; rst_n = 1; #1;
    check_registers(); resets++;
  endtask

  initial begin : stimulus
    int start_value, pause_length, bound, completion_start, route_start;
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32))
      $fatal(1, "CELLS must be 8, 16 or 32");
    for (int mode = 0; mode < 3; mode++)
      for (int position = 0; position < 8; position++)
        for (int c = 0; c < CELLS; c++)
          for (int lane = 0; lane < LANES; lane++)
            for (int direction = 0; direction < 2; direction++)
              for (int pause_case = 0; pause_case < 3; pause_case++)
                for (int ending = 0; ending < 3; ending++) begin
                  cell_id = c; lane_id = lane; cases++;
                  start_value = direction == 0 ? -1 : 1;
                  pause_length = pause_case == 0 ? 0 : pause_case == 1 ? 1 : 9;
                  reset_core();
                  tick_enable = 1; drive(1, start_value); cycle();
                  eq(64'(state_out[2*c+:2]), 64'(enc(start_value)), "seed polarity");
                  drive(0, 0); tick_enable = 0;
                  scheduler_mode = frp_m31_scheduler_mode_e'(mode); cycle();
                  tick_enable = 1;
                  while (position_ref != position) cycle();
                  target_q[2*c+:2] = enc(-start_value);
                  drive(1, -start_value);
                  completion_start = completions; route_start = routes;
                  bound = 0;
                  while (pending_ref[c] == 0 && bound < 8) begin cycle(); bound++; end
                  eq(64'(routes-route_start), 1, "first leg must execute");
                  eq(64'(completions-completion_start), 0, "separate completion tick");
                  eq(64'(state_out[2*c+:2]), 0, "first leg enters active zero");
                  eq(64'(pending_route_out[2*c+:2]), 64'(enc(-start_value)), "saved destination");
                  // Contradictory input and boundary target must not replace the route.
                  drive(1, start_value); target_q[2*c+:2] = enc(start_value);
                  tick_enable = 0;
                  repeat (pause_length) begin
                    clear_counters = !clear_counters; cycle();
                  end
                  clear_counters = 0;
                  if (ending == 1) begin
                    reset_core(); aborted++; aborted_hits[mode][position][c][lane][direction]++;
                    tick_enable = 1;
                    repeat (8) cycle();
                    eq(64'(completions-completion_start), 0, "reset cancels pending work");
                  end else begin
                    if (ending == 2) begin
                      scheduler_mode = frp_m31_scheduler_mode_e'((mode+1)%3);
                      cycle(); handovers++;
                    end
                    tick_enable = 1; clear_counters = 1; bound = 0;
                    while (pending_ref[c] != 0 && bound < 8) begin cycle(); bound++; end
                    clear_counters = 0; drive(0, 0);
                    eq(64'(completions-completion_start), 1, "exactly one completion");
                    eq(64'(state_out[2*c+:2]), 64'(enc(-start_value)), "saved polarity wins");
                    eq(64'(pending_route_out[2*c+:2]), 0, "completed route cleared");
                    repeat (8) cycle();
                    eq(64'(completions-completion_start), 1, "completion is not replayed");
                    completed_hits[mode][position][c][lane][direction]++;
                  end
                end
    foreach (completed_hits[m,p,c,l,d]) begin
      eq(64'(completed_hits[m][p][c][l][d]), 6, "completion coverage");
      eq(64'(aborted_hits[m][p][c][l][d]), 3, "reset coverage");
    end
    eq(64'(cases), 64'(3*8*CELLS*LANES*2*3*3), "scenario count");
    eq(64'(routes), 64'(cases), "route count");
    eq(64'(completions), 64'(cases*2/3), "completion count");
    eq(64'(aborted), 64'(cases/3), "abort count");
    eq(64'(handovers), 64'(cases/3), "handover count");
    if (paused_pending == 0 || deferred_pending == 0 || busy_rejections == 0)
      $fatal(1, "Missing pause, scheduler deferral or busy-request coverage");
    $display("PASS ACTIVE_ZERO cells=%0d cases=%0d cycles=%0d checks=%0d resets=%0d signature=%016h",
      CELLS, cases, cycles, checks, resets, signature);
    $display("ACTIVE_ZERO_EVENTS cells=%0d routes=%0d completions=%0d aborted=%0d handovers=%0d paused=%0d deferred=%0d busy=%0d",
      CELLS, routes, completions, aborted, handovers, paused_pending, deferred_pending, busy_rejections);
    $finish;
  end
  initial begin
    #100000000;
    $fatal(1, "Active-zero sequence watchdog expired");
  end
endmodule

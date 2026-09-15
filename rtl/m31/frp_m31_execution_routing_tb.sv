 // SPDX-License-Identifier: Apache-2.0
 // FRP M31 execution: complete single-request transition matrix and route conflicts.
 // Expected transitions use an explicit -1/0/1 truth table and public ports only.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_routing_tb;
  import frp_m31_pkg::*;
  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [1:0] request_valid = 0, request_accept, request_reject;
  logic [5:0] request_cell_index = 0;
  logic [3:0] request_target = 0;
  logic [15:0] target_q = 0, state_out, pending_route_out;
  logic [7:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q, scheduler_count_balance_q;
  logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q;
  logic [31:0] scheduler_count_neutralize_q, accepted_changes, capacity_remaining;
  logic [31:0] switch_load_numerator, requested_direct_events, prevented_direct_events;
  logic [31:0] neutral_routed_events, actual_direct_events, reserved_state_events;
  logic [31:0] queue_overflow_events;
  logic capacity_exhausted;
  logic [9:0] invariant_flags;
  logic [15:0] gold_state = 0, gold_pending = 0;
  int gold_mode = 0, gold_position = 0, gold_ticks = 0, gold_counts[5];
  int steps = 0, enabled_ticks = 0, hold_edges = 0, resets = 0, counter_clears = 0;
  int matrix_cases = 0, duplicate_cases = 0, pending_cases = 0;
  int capacity_cases = 0, backlog_cases = 0, reserved_cases = 0;
  int first_legs = 0, second_legs = 0;

  frp_m31_execution_core #(.CELLS(8), .REQUEST_LANES(2)) dut (
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

  function automatic logic [1:0] symbol(input int value);
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1, "Invalid test symbol %0d", value); return 2'b10; end
    endcase
  endfunction

  function automatic logic [15:0] put(
      input logic [15:0] bank, input int cell_index, input int value);
    logic [15:0] result;
    result = bank;
    result[2*cell_index +: 2] = symbol(value);
    return result;
  endfunction

  function automatic int cadence(input int mode, input int position);
    case (mode)
      0: return 0;
      1: return (position == 7) ? 2 : 1;
      2: return (position == 0) ? 3 : 4;
      default: begin $fatal(1, "Invalid test mode"); return 7; end
    endcase
  endfunction

  // Bit (3*(old+1)+(target+1)) describes admission, ordered -1, 0, 1.
  // FREE: all nine; BALANCE/NEUTRALIZE: no release from 0;
  // COMMIT/EXCITE: retention and release from 0 only.
  function automatic bit admitted(input int sched, input int old_value, input int goal);
    logic [8:0] table_bits;
    case (sched)
      0: table_bits = 9'b111111111;
      1, 4: table_bits = 9'b111010111;
      2, 3: table_bits = 9'b100111001;
      default: begin $fatal(1, "Invalid test scheduler state"); table_bits = 0; end
    endcase
    return table_bits[3*(old_value+1)+(goal+1)];
  endfunction

  task automatic clear_requests;
    request_valid = 0; request_cell_index = 0; request_target = 0; target_q = 0;
  endtask

  task automatic lane(input int index, input int cell_index, input int value);
    request_valid[index] = 1;
    request_cell_index[3*index +: 3] = 3'(cell_index);
    request_target[2*index +: 2] = symbol(value);
    target_q = put(target_q, cell_index, value);
  endtask

  task automatic check_retained;
    if (state_out !== gold_state || pending_route_out !== gold_pending)
      $fatal(1, "Retained mismatch step=%0d state=%h/%h pending=%h/%h",
        steps, state_out, gold_state, pending_route_out, gold_pending);
    if (scheduler_mode_q !== 2'(gold_mode) ||
        scheduler_state_q !== 3'(cadence(gold_mode, gold_position)) ||
        ticks_recorded_q !== 32'(gold_ticks) ||
        scheduler_count_free_q !== 32'(gold_counts[0]) ||
        scheduler_count_balance_q !== 32'(gold_counts[1]) ||
        scheduler_count_commit_q !== 32'(gold_counts[2]) ||
        scheduler_count_excite_q !== 32'(gold_counts[3]) ||
        scheduler_count_neutralize_q !== 32'(gold_counts[4]))
      $fatal(1, "Scheduler/counter mismatch step=%0d", steps);
  endtask

  task automatic step(input bit enabled, input logic [1:0] accept, reject,
      input logic [15:0] next_state, next_pending, input logic [9:0] flags = 10'h3ff);
    logic [7:0] writes, routes, accepted_cells;
    int changes, route_events, sched;
    writes = 0; routes = 0; accepted_cells = 0;
    sched = cadence(gold_mode, gold_position);
    for (int i = 0; i < 8; i++) begin
      writes[i] = (next_state[2*i +: 2] != gold_state[2*i +: 2]);
      routes[i] = writes[i] && next_state[2*i +: 2] == 0 &&
        next_pending[2*i +: 2] != 0 && gold_pending[2*i +: 2] == 0;
      if (writes[i] && gold_state[2*i +: 2] != 0 && next_state[2*i +: 2] != 0)
        $fatal(1, "Test attempted a direct opposite-polarity transition");
      if (gold_pending[2*i +: 2] != 0 && next_pending[2*i +: 2] == 0) begin
        if (!enabled || gold_state[2*i +: 2] != 0 ||
            next_state[2*i +: 2] != gold_pending[2*i +: 2])
          $fatal(1, "Invalid expected pending completion");
        second_legs++;
      end
    end
    for (int j = 0; j < 2; j++)
      if (accept[j]) accepted_cells[request_cell_index[3*j +: 3]] = 1;
    changes = $countones(writes); route_events = $countones(routes);
    first_legs += route_events;
    tick_enable = enabled;
    #1;
    check_retained();
    if (request_accept !== accept || request_reject !== reject ||
        accepted_cell_mask !== accepted_cells || accepted_change_mask !== writes ||
        neutral_routed_cell_mask !== routes || accepted_changes !== 32'(changes) ||
        capacity_remaining !== 32'(2-changes) || capacity_exhausted !== (changes == 2) ||
        switch_load_numerator !== 32'(changes) ||
        requested_direct_events !== 32'(route_events) ||
        prevented_direct_events !== 32'(route_events) ||
        neutral_routed_events !== 32'(route_events) ||
        actual_direct_events !== 0 || reserved_state_events !== 0 ||
        queue_overflow_events !== 0 || invariant_flags !== flags)
      $fatal(1, "Admission mismatch step=%0d sched=%0d accept=%b/%b reject=%b/%b changes=%0d/%0d flags=%h/%h",
        steps, sched, request_accept, accept, request_reject, reject,
        accepted_changes, changes, invariant_flags, flags);
    if (clear_counters) begin
      gold_ticks = 0;
      foreach (gold_counts[i]) gold_counts[i] = 0;
      counter_clears++;
    end
    if (enabled) begin
      gold_ticks++; gold_counts[sched]++; gold_position = (gold_position+1)%8;
      enabled_ticks++;
    end else hold_edges++;
    gold_mode = int'(scheduler_mode);
    gold_state = next_state; gold_pending = next_pending;
    clk = 1;
    #1;
    steps++;
    check_retained();
    clk = 0;
    #1;
    tick_enable = 0;
    #1;
  endtask

  task automatic reset_core;
    clear_requests(); tick_enable = 0; clear_counters = 0; scheduler_mode = FRP_MODE_FREE;
    #1; rst_n = 0;
    gold_state = 0; gold_pending = 0; gold_mode = 0; gold_position = 0; gold_ticks = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    #1; check_retained();
    clk = 1;
    #1; check_retained();
    clk = 0;
    #1; rst_n = 1;
    #1; resets++;
  endtask

  task automatic seed(input int cell_index, input int value);
    reset_core();
    lane(0, cell_index, value);
    step(1, 1, 0, put(0, cell_index, value), 0);
    clear_requests();
  endtask

  task automatic select_state(input int wanted);
    case (wanted)
      0: scheduler_mode = FRP_MODE_FREE;
      1, 2: scheduler_mode = FRP_MODE_7_1;
      3, 4: scheduler_mode = FRP_MODE_1_7;
      default: $fatal(1, "Invalid requested test state");
    endcase
    step(0, 0, 0, gold_state, gold_pending);
    for (int n = 0; n < 8 && cadence(gold_mode, gold_position) != wanted; n++)
      step(1, 0, 0, gold_state, gold_pending);
    if (cadence(gold_mode, gold_position) != wanted) $fatal(1, "Scheduler alignment failed");
  endtask

  initial begin : regression
    logic [15:0] next_state, next_pending;
    logic [1:0] accept, reject;
    bit allow, opposite;
    int a, b, c, d, changed;
    foreach (gold_counts[i]) gold_counts[i] = 0;

    // 8 cells x 2 lanes x 5 scheduler states x all 9 canonical transitions.
    for (int cell_index = 0; cell_index < 8; cell_index++)
      for (int request_lane = 0; request_lane < 2; request_lane++)
        for (int sched = 0; sched < 5; sched++)
          for (int old_value = -1; old_value <= 1; old_value++)
            for (int goal = -1; goal <= 1; goal++) begin
              seed(cell_index, old_value);
              select_state(sched);
              lane(request_lane, cell_index, goal);
              step(0, 0, 0, gold_state, gold_pending);
              allow = admitted(sched, old_value, goal);
              opposite = (old_value * goal == -1);
              accept = allow ? (2'b01 << request_lane) : 0;
              reject = request_valid & ~accept;
              next_state = allow ? put(gold_state, cell_index, opposite ? 0 : goal) : gold_state;
              next_pending = allow && opposite ? put(0, cell_index, goal) : 0;
              step(1, accept, reject, next_state, next_pending);
              matrix_cases++;
            end

    // The first admitted lane owns a cell, including an accepted same-state request.
    for (int cell_index = 0; cell_index < 8; cell_index++)
      for (int old_value = -1; old_value <= 1; old_value++)
        for (int first = -1; first <= 1; first++)
          for (int second = -1; second <= 1; second++) begin
            seed(cell_index, old_value);
            lane(0, cell_index, first); lane(1, cell_index, second);
            opposite = (old_value * first == -1);
            step(1, 1, 2, put(gold_state, cell_index, opposite ? 0 : first),
              opposite ? put(0, cell_index, first) : 16'b0);
            duplicate_cases++;
          end

    // A pending destination survives disabled clocks, counter clears and new requests.
    for (int mode = 1; mode <= 2; mode++)
      for (int cell_index = 0; cell_index < 8; cell_index++)
        for (int polarity = -1; polarity <= 1; polarity += 2) begin
          seed(cell_index, polarity);
          select_state(mode == 1 ? 1 : 4);
          lane(0, cell_index, -polarity);
          step(1, 1, 0, 0, put(0, cell_index, -polarity));
          clear_requests(); lane(0, cell_index, polarity); lane(1, cell_index, 0);
          repeat (2) step(0, 0, 0, gold_state, gold_pending);
          clear_counters = 1;
          step(0, 0, 0, gold_state, gold_pending);
          step(1, 0, 3, gold_state, gold_pending);
          clear_counters = 0;
          while (cadence(gold_mode, gold_position) == (mode == 1 ? 1 : 4))
            step(1, 0, 3, gold_state, gold_pending);
          step(1, 0, 3, put(0, cell_index, -polarity), 0);
          pending_cases++;
        end

    // Pending completions precede lanes; same-state admission consumes no capacity.
    for (int mode = 1; mode <= 2; mode++)
      for (int rotation = 0; rotation < 8; rotation++)
        for (int polarity = -1; polarity <= 1; polarity += 2)
          for (int pending_count = 1; pending_count <= 2; pending_count++)
            for (int same_state = 0; same_state <= 1; same_state++) begin
              a = rotation; b = (rotation+3)%8; c = (rotation+1)%8; d = (rotation+2)%8;
              reset_core(); lane(0, a, polarity);
              next_state = put(0, a, polarity);
              if (pending_count == 2) begin lane(1, b, -polarity); next_state = put(next_state, b, -polarity); end
              step(1, pending_count == 2 ? 2'b11 : 2'b01, 0, next_state, 0);
              clear_requests(); select_state(mode == 1 ? 1 : 4);
              lane(0, a, -polarity); next_pending = put(0, a, -polarity);
              if (pending_count == 2) begin lane(1, b, polarity); next_pending = put(next_pending, b, polarity); end
              step(1, pending_count == 2 ? 2'b11 : 2'b01, 0, 0, next_pending);
              clear_requests(); select_state(mode == 1 ? 2 : 3);
              lane(0, c, same_state ? 0 : polarity); lane(1, d, -polarity);
              next_state = gold_pending;
              accept = 0;
              if (same_state) begin
                accept[0] = 1;
                if (pending_count == 1) begin accept[1] = 1; next_state = put(next_state, d, -polarity); end
              end else if (pending_count == 1) begin
                accept[0] = 1; next_state = put(next_state, c, polarity);
              end
              step(1, accept, ~accept, next_state, 0);
              capacity_cases++;
            end

    // Four retained destinations drain two per eligible tick, in ascending cell order.
    for (int mode = 1; mode <= 2; mode++)
      for (int rotation = 0; rotation < 8; rotation++)
        for (int polarity = -1; polarity <= 1; polarity += 2) begin
          reset_core();
          for (int pair = 0; pair < 2; pair++) begin
            clear_requests(); next_state = gold_state;
            for (int j = 0; j < 2; j++) begin
              a = (rotation+2*pair+j)%8;
              lane(j, a, polarity); next_state = put(next_state, a, polarity);
            end
            step(1, 3, 0, next_state, 0);
          end
          clear_requests(); select_state(mode == 1 ? 1 : 4);
          for (int pair = 0; pair < 2; pair++) begin
            clear_requests(); next_state = gold_state; next_pending = gold_pending;
            for (int j = 0; j < 2; j++) begin
              a = (rotation+2*pair+j)%8;
              lane(j, a, -polarity);
              next_state = put(next_state, a, 0); next_pending = put(next_pending, a, -polarity);
            end
            step(1, 3, 0, next_state, next_pending);
          end
          clear_requests();
          repeat (2) begin
            select_state(mode == 1 ? 2 : 3);
            next_state = gold_state; next_pending = gold_pending; changed = 0;
            for (int i = 0; i < 8; i++)
              if (gold_pending[2*i +: 2] != 0 && changed < 2) begin
                next_state = put(next_state, i, -polarity); next_pending = put(next_pending, i, 0); changed++;
              end
            step(0, 0, 0, gold_state, gold_pending);
            step(1, 0, 0, next_state, next_pending);
          end
          backlog_cases++;
        end

    // A rejected reserved request does not claim the cell ahead of a valid lane.
    for (int cell_index = 0; cell_index < 8; cell_index++)
      for (int polarity = -1; polarity <= 1; polarity += 2) begin
        seed(cell_index, 0);
        lane(0, cell_index, 0); request_target[1:0] = 2'b10;
        lane(1, cell_index, polarity);
        step(1, 2, 1, put(0, cell_index, polarity), 0, 10'h3fa);
        reserved_cases++;
      end
    clear_requests();
    if (matrix_cases != 720 || duplicate_cases != 216 || pending_cases != 32 ||
        capacity_cases != 128 || backlog_cases != 32 || reserved_cases != 16 ||
        counter_clears != 64 || resets != 1144 || first_legs == 0 || second_legs == 0)
      $fatal(1, "Incomplete routing regression coverage");
    $display("FRP_M31_EXECUTION_ROUTING_TB: PASS matrix_cases=%0d duplicate_cases=%0d pending_cases=%0d capacity_cases=%0d backlog_cases=%0d reserved_cases=%0d counter_clears=%0d resets=%0d enabled_ticks=%0d hold_edges=%0d first_legs=%0d second_legs=%0d",
      matrix_cases, duplicate_cases, pending_cases, capacity_cases, backlog_cases,
      reserved_cases, counter_clears, resets, enabled_ticks, hold_edges, first_legs, second_legs);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "FRP M31 execution routing watchdog expired");
  end
endmodule

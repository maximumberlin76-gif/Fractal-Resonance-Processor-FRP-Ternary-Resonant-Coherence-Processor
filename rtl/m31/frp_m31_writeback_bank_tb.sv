// SPDX-License-Identifier: Apache-2.0
// Whole-bank writeback decisions, diagnostics and event accounting.
// The reference bank advances through public inputs and sampled clock edges.
`timescale 1ns/1ps
`include "frp_m31_state_update.sv"

module frp_m31_writeback_bank_tb #(
  parameter int CELLS = 9,
  parameter int LANES = 3
);
  import frp_m31_pkg::*;
  typedef logic [2*CELLS-1:0] bank_t;
  typedef logic [CELLS-1:0] mask_t;
  typedef struct packed {
    bank_t state_q, state_d, state_out;
    mask_t state_write_enable_mask, state_hold_mask, state_reset_mask, state_reserved_mask;
    logic [31:0] accepted_changes, switch_load_numerator, state_write_events, state_hold_events, state_reset_events, accepted_change_events, neutral_routed_commit_events, pending_completion_commit_events, reserved_state_events, actual_direct_events;
    logic state_domain_valid, state_output_domain_valid, state_update_valid, state_write_capacity_valid, same_state_hold_valid, active_neutral_writeback_valid, pending_completion_writeback_valid, no_reserved_state_output, no_actual_direct_events;
  } result_t;
  result_t actual, expected;
  bank_t candidate, reference_q = '0;
  mask_t cap, change, route, complete, reserved, direct_flag;
  logic clk = 0, rst_n = 1, tick;
  frp_m31_scheduler_state_e sched;
  int unsigned seed, rng, checks = 0, enumerated = 0, resets = 0;
  int unsigned random_steps = 0, threshold_cases = 0;
  int unsigned seen_bad [0:8];
  int unsigned seen_zero = 0, seen_full = 0, seen_over_limit = 0;
  logic [63:0] signature = 64'hcbf29ce484222325;

  frp_m31_state_update #(.CELLS(CELLS), .STATE_BITS(2),
      .REQUEST_LANES(LANES), .COUNTER_BITS(32)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick), .scheduler_state(sched),
    .state_candidate_d(candidate), .capacity_accept_mask(cap),
    .accepted_change_candidate_mask(change), .neutral_routed_mask(route),
    .pending_completion_mask(complete), .reserved_transition_mask(reserved),
    .actual_direct_mask(direct_flag),
    .state_q(actual.state_q),
    .state_d(actual.state_d),
    .state_out(actual.state_out),
    .state_write_enable_mask(actual.state_write_enable_mask),
    .state_hold_mask(actual.state_hold_mask),
    .state_reset_mask(actual.state_reset_mask),
    .state_reserved_mask(actual.state_reserved_mask),
    .accepted_changes(actual.accepted_changes),
    .switch_load_numerator(actual.switch_load_numerator),
    .state_write_events(actual.state_write_events),
    .state_hold_events(actual.state_hold_events),
    .state_reset_events(actual.state_reset_events),
    .accepted_change_events(actual.accepted_change_events),
    .neutral_routed_commit_events(actual.neutral_routed_commit_events),
    .pending_completion_commit_events(actual.pending_completion_commit_events),
    .reserved_state_events(actual.reserved_state_events),
    .actual_direct_events(actual.actual_direct_events),
    .state_domain_valid(actual.state_domain_valid),
    .state_output_domain_valid(actual.state_output_domain_valid),
    .state_update_valid(actual.state_update_valid),
    .state_write_capacity_valid(actual.state_write_capacity_valid),
    .same_state_hold_valid(actual.same_state_hold_valid),
    .active_neutral_writeback_valid(actual.active_neutral_writeback_valid),
    .pending_completion_writeback_valid(actual.pending_completion_writeback_valid),
    .no_reserved_state_output(actual.no_reserved_state_output),
    .no_actual_direct_events(actual.no_actual_direct_events)
  );

  function automatic bit polarized(input logic [1:0] value);
    return value == 1 || value == 3;
  endfunction

  function automatic int unsigned draw();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  task automatic oracle();
    mask_t changed, invalid, opposite, same_bad, missing_change;
    mask_t phase_ok, bad_route, bad_completion, bad_metadata, writes;
    logic [1:0] old_value, wanted;
    bit enter_phase, leave_phase;
    expected = '0;
    expected.state_q = reference_q;
    expected.state_out = reference_q;
    expected.state_d = reference_q;
    changed = '0; invalid = reserved; opposite = direct_flag;
    phase_ok = '1;
    bad_route = route & complete;
    bad_completion = route & complete;
    enter_phase = int'(sched) inside {0, 2, 3};
    leave_phase = int'(sched) inside {0, 1, 4};
    for (int c = 0; c < CELLS; c++) begin
      old_value = reference_q[2*c+:2];
      wanted = candidate[2*c+:2];
      changed[c] = old_value != wanted;
      invalid[c] |= old_value == 2 || wanted == 2;
      opposite[c] |= polarized(old_value) && polarized(wanted) && changed[c];
      if (changed[c]) begin
        if (route[c]) begin
          phase_ok[c] = leave_phase;
          bad_route[c] |= !polarized(old_value) || wanted != 0;
        end else if (complete[c]) begin
          phase_ok[c] = enter_phase;
          bad_completion[c] |= old_value != 0 || !polarized(wanted);
        end else begin
          case ({old_value, wanted})
            4'b0001, 4'b0011: phase_ok[c] = enter_phase;
            4'b0100, 4'b1100: phase_ok[c] = leave_phase;
            default: phase_ok[c] = 0;
          endcase
        end
      end
    end
    bad_route |= route & ~phase_ok;
    bad_completion |= complete & ~phase_ok;
    same_bad = change & ~changed;
    missing_change = changed & ~change;
    bad_metadata = opposite | same_bad | missing_change |
                   bad_route | bad_completion | ~phase_ok;
    writes = {CELLS{tick}} & changed & cap & change & ~invalid & ~bad_metadata;
    for (int c = 0; c < CELLS; c++)
      if (writes[c]) expected.state_d[2*c+:2] = candidate[2*c+:2];
    expected.state_write_enable_mask = writes;
    expected.state_hold_mask = ~writes;
    expected.state_reserved_mask = invalid;
    expected.accepted_changes = $countones(writes);
    expected.switch_load_numerator = $countones(writes);
    expected.state_write_events = $countones(writes);
    expected.state_hold_events = CELLS - $countones(writes);
    expected.accepted_change_events = $countones(writes);
    expected.neutral_routed_commit_events = $countones(writes & route);
    expected.pending_completion_commit_events = $countones(writes & complete);
    expected.reserved_state_events = $countones(invalid);
    expected.state_domain_valid = invalid == 0;
    expected.state_output_domain_valid = 1;
    expected.state_write_capacity_valid = missing_change == 0 && $countones(writes) <= LANES;
    expected.same_state_hold_valid = same_bad == 0;
    expected.active_neutral_writeback_valid = bad_route == 0;
    expected.pending_completion_writeback_valid = bad_completion == 0;
    expected.no_reserved_state_output = 1;
    expected.no_actual_direct_events = 1;
    expected.state_update_valid = invalid == 0 && bad_metadata == 0 &&
        int'(sched) < 5 && expected.state_write_capacity_valid;
    if (!rst_n) begin
      expected = '0;
      expected.state_q = reference_q;
      expected.state_out = reference_q;
      expected.state_reset_mask = '1;
      expected.state_reset_events = CELLS;
      expected.state_domain_valid = 1;
      expected.state_output_domain_valid = 1;
      expected.state_update_valid = int'(sched) < 5;
      expected.state_write_capacity_valid = 1;
      expected.same_state_hold_valid = 1;
      expected.active_neutral_writeback_valid = 1;
      expected.pending_completion_writeback_valid = 1;
      expected.no_reserved_state_output = 1;
      expected.no_actual_direct_events = 1;
    end
  endtask

  task automatic step();
    logic [8:0] diagnostics;
    #1;
    oracle();
    if (actual !== expected)
      $fatal(1, "BANK mismatch cells=%0d lanes=%0d check=%0d sched=%0d tick=%b expected=%h actual=%h",
             CELLS, LANES, checks, sched, tick, expected, actual);
    diagnostics = {actual.state_domain_valid, actual.state_output_domain_valid,
        actual.state_update_valid, actual.state_write_capacity_valid,
        actual.same_state_hold_valid, actual.active_neutral_writeback_valid,
        actual.pending_completion_writeback_valid, actual.no_reserved_state_output,
        actual.no_actual_direct_events};
    for (int k = 0; k < 9; k++) seen_bad[k] += int'(!diagnostics[k]);
    seen_zero += int'(actual.state_write_events == 0 && rst_n);
    seen_full += int'(actual.state_write_events == CELLS && rst_n);
    seen_over_limit += int'(actual.state_write_events > LANES && rst_n);
    for (int c = 0; c < CELLS; c++)
      signature = (signature ^ 64'(expected.state_d[2*c+:2]) ^
                   (64'(c) << 8)) * 64'h100000001b3;
    signature = (signature ^ 64'(diagnostics) ^
        (64'(actual.state_write_events) << 16) ^
        (64'(actual.reserved_state_events) << 32)) * 64'h100000001b3;
    clk = 1; #1;
    reference_q = expected.state_d;
    if (actual.state_q !== reference_q || actual.state_out !== reference_q)
      $fatal(1, "BANK register check=%0d expected=%h got=%h", checks, reference_q, actual.state_q);
    clk = 0; #1;
    checks++;
  endtask

  task automatic idle_inputs();
    tick = 0; sched = FRP_SCHED_FREE; candidate = reference_q;
    cap = '0; change = '0; route = '0; complete = '0;
    reserved = '0; direct_flag = '0;
  endtask

  task automatic reset_bank();
    idle_inputs();
    rst_n = 1; #1; rst_n = 0;
    reference_q = '0;
    #1;
    if (actual.state_q !== '0 || actual.state_out !== '0)
      $fatal(1, "BANK asynchronous reset failed");
    step();
    rst_n = 1;
    resets++;
  endtask

  task automatic preload(input logic [1:0] value);
    reset_bank();
    tick = 1; candidate = {CELLS{value}};
    cap = {CELLS{value != 0}}; change = cap;
    step();
  endtask

  initial begin
    if (CELLS < 2 || CELLS > 64 || LANES < 1 || LANES > CELLS)
      $fatal(1, "Unsupported CELLS/LANES");
    if (!$value$plusargs("SEED=%d", seed)) seed = 0;
    rng = seed ^ 32'h9e3779b9;
    if (rng == 0) rng = 1;
    for (int k = 0; k < 9; k++) seen_bad[k] = 0;
    for (int src = 0; src < 3; src++)
      for (int dst = 0; dst < 4; dst++)
        for (int mode = 0; mode < 8; mode++)
          for (int f = 0; f < 128; f++) begin
            preload(src == 2 ? 2'b11 : 2'(src));
            sched = frp_m31_scheduler_state_e'(mode);
            candidate = {CELLS{2'(dst)}};
            tick = 1'(f >> 6); cap = {CELLS{1'(f >> 5)}};
            change = {CELLS{1'(f >> 4)}}; route = {CELLS{1'(f >> 3)}};
            complete = {CELLS{1'(f >> 2)}}; reserved = {CELLS{1'(f >> 1)}};
            direct_flag = {CELLS{1'(f)}};
            step(); enumerated++;
          end
    // Every write population, rotated across the entire bank, in both polarities.
    for (int offset = 0; offset < CELLS; offset++)
      for (int population = 0; population <= CELLS; population++)
        for (int sign = 0; sign < 2; sign++) begin
          reset_bank(); idle_inputs(); tick = 1;
          for (int k = 0; k < population; k++) begin
            candidate[2*((offset+k)%CELLS)+:2] = sign ? 2'b11 : 2'b01;
            cap[(offset+k)%CELLS] = 1; change[(offset+k)%CELLS] = 1;
          end
          step(); threshold_cases++;
          idle_inputs(); step();
          tick = 1; candidate = '0; cap = '1; route = '1;
          for (int c = 0; c < CELLS; c++) change[c] = reference_q[2*c+:2] != 0;
          step();
        end
    // Stateful mixed traffic, diagnostics and resets with no forced DUT state.
    for (int sample = 0; sample < 4096; sample++) begin
      if (sample % 97 == 0) reset_bank();
      sched = frp_m31_scheduler_state_e'(3'(draw()));
      tick = 1'(draw());
      for (int c = 0; c < CELLS; c++) begin
        candidate[2*c+:2] = 2'(draw());
        {cap[c], change[c], route[c], complete[c], reserved[c], direct_flag[c]} = 6'(draw());
        if (sample % 4 == 0) begin
          cap[c] = 1; change[c] = candidate[2*c+:2] != reference_q[2*c+:2];
          route[c] = 0; complete[c] = 0; reserved[c] = 0; direct_flag[c] = 0;
        end
      end
      step(); random_steps++;
    end
    // Reset diagnostics also cover every scheduler encoding with hostile inputs.
    for (int mode = 0; mode < 8; mode++) begin
      reset_bank(); rst_n = 0; sched = frp_m31_scheduler_state_e'(mode);
      tick = 1; candidate = '1; cap = '1; change = '1;
      route = '1; complete = '1; reserved = '1; direct_flag = '1;
      step(); rst_n = 1;
    end
    if (enumerated != 12288 || threshold_cases != 2*CELLS*(CELLS+1) ||
        random_steps != 4096 || seen_zero == 0 || seen_full == 0 ||
        (LANES < CELLS && seen_over_limit == 0))
      $fatal(1, "BANK stimulus accounting failed");
    foreach (seen_bad[k])
      if ((k inside {2, 3, 4, 5, 6, 8}) && seen_bad[k] == 0)
        $fatal(1, "BANK missing diagnostic bit=%0d", k);
    $display("PASS WRITEBACK_BANK cells=%0d lanes=%0d seed=%0d enumerated=%0d threshold_cases=%0d random_steps=%0d checks=%0d resets=%0d signature=%016h",
        CELLS, LANES, seed, enumerated, threshold_cases, random_steps, checks, resets, signature);
    $finish;
  end
endmodule

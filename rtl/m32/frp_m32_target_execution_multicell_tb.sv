// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Registered phase-target boundary -> requests -> active-zero execution.
// Public-port reference model uses integer -1/0/+1 states and no DUT helpers.
// The phase engine is qualified separately by the phase multicell regression.
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"
`include "frp_m31_execution_core.sv"

module frp_m32_target_execution_checker #(
  parameter int N = 8,
  localparam int L = N/4,
  localparam int I = $clog2(N)
)(output bit done = 0);
  import frp_m31_pkg::*;
  bit clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  bit phase_target_valid = 0, auto_target_enable = 1;
  logic [2*N-1:0] phase_target_source = 0, registered_target_q;
  logic [2*N-1:0] state_out, pending_route_out;
  logic registered_target_valid_q, phase_target_domain_valid;
  logic registered_target_domain_valid, capture_accepted, capture_rejected;
  logic registered_request_enable;
  logic [7:0] accepted_capture_events_q, rejected_capture_events_q;
  logic [L-1:0] phase_request_valid, request_accept, request_reject;
  logic [L*I-1:0] phase_request_cell_index;
  logic [2*L-1:0] phase_request_target;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q, scheduler_count_balance_q;
  logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q;
  logic [31:0] scheduler_count_neutralize_q, accepted_changes, capacity_remaining;
  logic [31:0] switch_load_numerator, requested_direct_events, prevented_direct_events;
  logic [31:0] neutral_routed_events, actual_direct_events, reserved_state_events;
  logic [31:0] queue_overflow_events;
  logic [N-1:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
  logic capacity_exhausted;
  logic [9:0] invariant_flags;

  int state_ref[N], pending_ref[N], target_ref[N];
  bit valid_ref = 0;
  int mode_ref = 0, position_ref = 0, ticks_ref = 0, counts_ref[5];
  int capture_ref = 0, reject_ref = 0;
  int cycles = 0, comparisons = 0, patterns = 0, faults = 0, resets = 0;
  int routes = 0, completions = 0, retargeted = 0, blocked = 0;
  int paused = 0, auto_off_completion = 0, saturations = 0;
  int transition_hits[3][3], scheduler_hits[3][8], lane_hits[L];
  int control_hits[16], cell_routes[N], cell_completions[N];
  int unsigned random_state = 32'h31c0ffee ^ N;
  logic [63:0] signature = 64'hcbf29ce484222325;

  frp_m32_registered_target_request_path #(
    .CELLS(N), .REQUEST_LANES(L), .CELL_INDEX_BITS(I), .COUNTER_BITS(8)
  ) boundary_dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .phase_target_valid,
    .phase_target_source, .auto_target_enable, .retained_state(state_out),
    .pending_route(pending_route_out), .scheduler_state(scheduler_state_q),
    .registered_target_q, .registered_target_valid_q, .phase_target_domain_valid,
    .registered_target_domain_valid, .capture_accepted, .capture_rejected,
    .accepted_capture_events_q, .rejected_capture_events_q, .registered_request_enable,
    .phase_request_valid, .phase_request_cell_index, .phase_request_target
  );
  frp_m31_execution_core #(.CELLS(N), .REQUEST_LANES(L)) execution_dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .scheduler_mode,
    .request_valid(phase_request_valid), .request_cell_index(phase_request_cell_index),
    .request_target(phase_request_target), .target_q(registered_target_q),
    .state_out, .pending_route_out, .scheduler_mode_q, .scheduler_state_q,
    .ticks_recorded_q, .scheduler_count_free_q, .scheduler_count_balance_q,
    .scheduler_count_commit_q, .scheduler_count_excite_q, .scheduler_count_neutralize_q,
    .request_accept, .request_reject, .accepted_cell_mask, .neutral_routed_cell_mask,
    .accepted_change_mask, .accepted_changes, .capacity_remaining, .capacity_exhausted,
    .switch_load_numerator, .requested_direct_events, .prevented_direct_events,
    .neutral_routed_events, .actual_direct_events, .reserved_state_events,
    .queue_overflow_events, .invariant_flags
  );

  function automatic logic [1:0] enc(input int v);
    case (v)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: return 2'b10;
    endcase
  endfunction
  function automatic int dec(input logic [1:0] v);
    case (v)
      2'b11: return -1;
      2'b00: return 0;
      2'b01: return 1;
      default: return 2;
    endcase
  endfunction
  function automatic int schedule(input int m, p);
    case (m)
      0: return 0;
      1: return p == 7 ? 2 : 1;
      2: return p == 0 ? 3 : 4;
      default: return 7;
    endcase
  endfunction
  function automatic bit eligible(input int s, a, b);
    if (a == b) return 0;
    case (s)
      0: return 1;
      1, 4: return a != 0;
      2, 3: return a == 0;
      default: return 0;
    endcase
  endfunction
  function automatic int unsigned random_word();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 17;
    random_state ^= random_state << 5;
    return random_state;
  endfunction
  task automatic eq(input logic [63:0] actual, expected, input string label_text);
    comparisons++;
    if (actual !== expected)
      $fatal(1, "N=%0d cycle=%0d %s actual=%h expected=%h",
        N, cycles, label_text, actual, expected);
  endtask
  task automatic check_registers;
    for (int c = 0; c < N; c++) begin
      eq(64'(state_out[2*c+:2]), 64'(enc(state_ref[c])), "retained state");
      eq(64'(pending_route_out[2*c+:2]), 64'(enc(pending_ref[c])), "retained route");
      eq(64'(registered_target_q[2*c+:2]), 64'(enc(target_ref[c])), "registered target");
    end
    eq(64'(registered_target_valid_q), 64'(valid_ref), "target validity");
    eq(64'(registered_target_domain_valid), 1, "registered domain");
    eq(64'(accepted_capture_events_q), 64'(capture_ref), "capture count");
    eq(64'(rejected_capture_events_q), 64'(reject_ref), "reject count");
    eq(64'(scheduler_mode_q), 64'(mode_ref), "mode register");
    eq(64'(scheduler_state_q), 64'(schedule(mode_ref, position_ref)), "scheduler");
    eq(64'(ticks_recorded_q), 64'(ticks_ref), "tick count");
    eq(64'(scheduler_count_free_q), 64'(counts_ref[0]), "free count");
    eq(64'(scheduler_count_balance_q), 64'(counts_ref[1]), "balance count");
    eq(64'(scheduler_count_commit_q), 64'(counts_ref[2]), "commit count");
    eq(64'(scheduler_count_excite_q), 64'(counts_ref[3]), "excite count");
    eq(64'(scheduler_count_neutralize_q), 64'(counts_ref[4]), "neutralize count");
  endtask

  task automatic cycle;
    int next_state[N], next_pending[N], selected[L];
    int s, used, count, opposite_requests, c;
    bit source_ok, releasing, gate;
    logic [L-1:0] rv, ra, rr;
    logic [L*I-1:0] ri;
    logic [2*L-1:0] rt;
    logic [N-1:0] writes, accepted, neutral;
    #1;
    check_registers();
    s = schedule(mode_ref, position_ref);
    releasing = s == 0 || s == 2 || s == 3;
    source_ok = 1;
    for (int k = 0; k < N; k++) begin
      if (dec(phase_target_source[2*k+:2]) == 2) source_ok = 0;
      next_state[k] = state_ref[k]; next_pending[k] = pending_ref[k];
    end
    gate = auto_target_enable && valid_ref;
    rv = 0; ri = 0; rt = 0; ra = 0; rr = 0;
    writes = 0; accepted = 0; neutral = 0;
    count = 0; used = 0; opposite_requests = 0;
    // Requests use the PRE-edge registered target and retained state.
    for (int k = 0; k < N; k++)
      if (gate && pending_ref[k] == 0 && eligible(s, state_ref[k], target_ref[k])
          && count < L) begin
        rv[count] = 1; ri[count*I+:I] = I'(k);
        rt[count*2+:2] = enc(target_ref[k]); selected[count] = k; count++;
      end
    // Retained destinations have priority over new requests.
    if (tick_enable) begin
      for (int k = 0; k < N; k++)
        if (pending_ref[k] != 0 && releasing && used < L) begin
          if (state_ref[k] != 0) $fatal(1, "Reference route lost active zero");
          next_state[k] = pending_ref[k]; next_pending[k] = 0;
          writes[k] = 1; used++; completions++; cell_completions[k]++;
          if (target_ref[k] != pending_ref[k]) retargeted++;
          if (!auto_target_enable) auto_off_completion++;
        end
      for (int lane = 0; lane < count; lane++) begin
        c = selected[lane];
        if (state_ref[c]*target_ref[c] == -1) opposite_requests++;
        if (used < L) begin
          ra[lane] = 1; accepted[c] = 1; writes[c] = 1; used++; lane_hits[lane]++;
          if (state_ref[c]*target_ref[c] == -1) begin
            next_state[c] = 0; next_pending[c] = target_ref[c];
            neutral[c] = 1; routes++; cell_routes[c]++;
          end else next_state[c] = target_ref[c];
        end else begin rr[lane] = 1; blocked++; end
      end
    end else paused++;
    eq(64'(phase_target_domain_valid), 64'(source_ok), "source domain");
    eq(64'(capture_accepted), 64'(tick_enable && phase_target_valid && source_ok), "capture");
    eq(64'(capture_rejected), 64'(tick_enable && phase_target_valid && !source_ok), "reject");
    eq(64'(registered_request_enable), 64'(gate), "automatic gate");
    eq(64'(phase_request_valid), 64'(rv), "request mask");
    eq(64'(phase_request_cell_index), 64'(ri), "ascending cells");
    eq(64'(phase_request_target), 64'(rt), "request targets");
    eq(64'(request_accept), 64'(ra), "accepted lanes");
    eq(64'(request_reject), 64'(rr), "rejected lanes");
    eq(64'(accepted_cell_mask), 64'(accepted), "accepted cells");
    eq(64'(neutral_routed_cell_mask), 64'(neutral), "neutral routes");
    eq(64'(accepted_change_mask), 64'(writes), "write mask");
    eq(64'(accepted_changes), 64'(used), "capacity used");
    eq(64'(capacity_remaining), 64'(L-used), "capacity remaining");
    eq(64'(capacity_exhausted), 64'(used == L), "capacity exhausted");
    eq(64'(switch_load_numerator), 64'(used), "switch load");
    eq(64'(requested_direct_events), 64'(opposite_requests), "opposite requests");
    eq(64'(prevented_direct_events), 64'(opposite_requests), "prevented direct");
    eq(64'(neutral_routed_events), 64'(opposite_requests), "neutral candidates");
    eq(64'(actual_direct_events), 0, "actual direct");
    eq(64'(reserved_state_events), 0, "reserved execution");
    eq(64'(queue_overflow_events), 0, "route overflow");
    eq(64'(invariant_flags), 1023, "execution invariants");
    control_hits[{tick_enable, phase_target_valid, auto_target_enable, clear_counters}]++;
    if (clear_counters) begin
      capture_ref = 0; reject_ref = 0; ticks_ref = 0;
      foreach (counts_ref[k]) counts_ref[k] = 0;
    end
    if (tick_enable) begin
      scheduler_hits[mode_ref][position_ref]++;
      ticks_ref++; counts_ref[s]++; position_ref = (position_ref+1)%8;
      if (phase_target_valid) begin
        if (!clear_counters) begin
          if (source_ok && capture_ref < 255) capture_ref++;
          if (!source_ok && reject_ref < 255) reject_ref++;
          if (capture_ref == 255 || reject_ref == 255) saturations++;
        end
        if (source_ok) begin
          for (int k = 0; k < N; k++) target_ref[k] = dec(phase_target_source[2*k+:2]);
          valid_ref = 1;
        end
      end
    end
    for (int k = 0; k < N; k++) begin
      if (state_ref[k]*next_state[k] == -1) $fatal(1, "Direct polarity execution");
      transition_hits[state_ref[k]+1][next_state[k]+1]++;
      state_ref[k] = next_state[k]; pending_ref[k] = next_pending[k];
      signature = (signature ^ 64'(enc(state_ref[k]))) * 64'h100000001b3;
      signature = (signature ^ 64'(enc(pending_ref[k]))) * 64'h100000001b3;
      signature = (signature ^ 64'(enc(target_ref[k]))) * 64'h100000001b3;
    end
    mode_ref = int'(scheduler_mode);
    clk = 1; #1; cycles++; check_registers();
    clk = 0; #1;
  endtask

  task automatic reset_all;
    clk = 0; tick_enable = 0; clear_counters = 0;
    phase_target_valid = 0; auto_target_enable = 1; phase_target_source = 0;
    scheduler_mode = FRP_MODE_FREE;
    rst_n = 0;
    for (int k = 0; k < N; k++) begin
      state_ref[k] = 0; pending_ref[k] = 0; target_ref[k] = 0;
    end
    valid_ref = 0; mode_ref = 0; position_ref = 0; ticks_ref = 0;
    capture_ref = 0; reject_ref = 0;
    foreach (counts_ref[k]) counts_ref[k] = 0;
    #1; check_registers(); rst_n = 1; #1; resets++;
  endtask
  task automatic uniform_target(input int v);
    for (int k = 0; k < N; k++) phase_target_source[2*k+:2] = enc(v);
  endtask
  task automatic settle;
    tick_enable = 1; phase_target_valid = 1; auto_target_enable = 1; clear_counters = 0;
    repeat (80) cycle();
    for (int k = 0; k < N; k++) begin
      eq(64'(state_out[2*k+:2]), 64'(phase_target_source[2*k+:2]), "target convergence");
      eq(64'(pending_route_out[2*k+:2]), 0, "route drained");
    end
  endtask

  initial begin : regression
    int digits, code, rotation;
    int unsigned noise;
    reset_all();
    for (int m = 0; m < 3; m++) begin
      scheduler_mode = frp_m31_scheduler_mode_e'(m); cycle();
      // Every cell traverses both polarity bridges and active neutral.
      uniform_target(1); settle();
      uniform_target(-1); settle();
      uniform_target(1); settle();
      uniform_target(0); settle();
      // All 3^8 ordered ternary target motifs, tiled and rotated across N cells.
      for (int pattern = 0; pattern < 6561; pattern++) begin
        digits = pattern; rotation = pattern % N;
        for (int k = 0; k < 8; k++) begin
          code = digits % 3 - 1; digits /= 3;
          for (int group_index = 0; group_index < N/8; group_index++)
            phase_target_source[2*((rotation+8*group_index+k)%N)+:2] = enc(code);
        end
        tick_enable = 1; phase_target_valid = 1; clear_counters = 0;
        auto_target_enable = 1; cycle();
        phase_target_valid = 0; cycle();
        if (pattern % 17 == 0) begin tick_enable = 0; cycle(); end
        patterns++;
      end
      settle();
      // Reject a reserved symbol at every source position under every control tuple.
      for (int bad = 0; bad < N; bad++)
        for (int controls = 0; controls < 16; controls++) begin
          uniform_target((bad%3)-1); phase_target_source[2*bad+:2] = 2'b10;
          tick_enable = 1'(controls>>3); phase_target_valid = 1'(controls>>2);
          auto_target_enable = 1'(controls>>1); clear_counters = 1'(controls);
          cycle(); faults++;
        end
      // Capture counters saturate independently, including repeated invalid sources.
      tick_enable = 1; phase_target_valid = 1; clear_counters = 0; auto_target_enable = 1;
      uniform_target(0); repeat (270) cycle();
      phase_target_source[2*(N-1)+:2] = 2'b10; repeat (270) cycle();
      uniform_target(0); settle();
    end
    // Drain an opposite-polarity route after retargeting and disabling automatic requests.
    for (int m = 1; m <= 2; m++) begin
      reset_all(); uniform_target(1); settle();
      scheduler_mode = frp_m31_scheduler_mode_e'(m);
      tick_enable = 0; phase_target_valid = 0; cycle();
      while (schedule(mode_ref, position_ref) != (m == 1 ? 1 : 4)) begin
        tick_enable = 1; cycle();
      end
      uniform_target(-1); tick_enable = 1; phase_target_valid = 1; cycle();
      uniform_target(1); cycle();
      auto_target_enable = 0; phase_target_valid = 0;
      tick_enable = 0; repeat (3) cycle();
      clear_counters = 1; cycle(); clear_counters = 0;
      tick_enable = 1; repeat (16) cycle();
      uniform_target(0); settle();
    end
    // Reproducible mixed controls, mode handoffs, faults and resets under load.
    for (int n = 0; n < 8192; n++) begin
      if (n % 1024 == 0) reset_all();
      noise = random_word();
      scheduler_mode = frp_m31_scheduler_mode_e'(noise % 3);
      tick_enable = noise[3] || noise[4]; phase_target_valid = noise[5];
      auto_target_enable = noise[6] || noise[7]; clear_counters = (noise[12:8] == 0);
      for (int k = 0; k < N; k++) begin
        noise = random_word(); phase_target_source[2*k+:2] = enc(int'(noise%3)-1);
      end
      if (n % 19 == 0) phase_target_source[2*(n%N)+:2] = 2'b10;
      cycle();
    end
    uniform_target(0); settle();
    for (int m = 0; m < 3; m++)
      for (int p = 0; p < 8; p++)
        if (scheduler_hits[m][p] == 0) $fatal(1, "Missing cadence coverage");
    for (int a = 0; a < 3; a++)
      for (int b = 0; b < 3; b++)
        if ((a == 0 && b == 2) || (a == 2 && b == 0))
          eq(64'(transition_hits[a][b]), 0, "forbidden transition coverage");
        else if (transition_hits[a][b] == 0) $fatal(1, "Missing legal transition");
    foreach (lane_hits[k]) if (lane_hits[k] == 0) $fatal(1, "Unused request lane");
    foreach (control_hits[k]) if (control_hits[k] == 0) $fatal(1, "Missing controls");
    for (int k = 0; k < N; k++)
      if (cell_routes[k] == 0 || cell_completions[k] == 0) $fatal(1, "Uncovered cell route");
    if (patterns != 19683 || faults != 48*N || routes == 0 || completions == 0 ||
        retargeted == 0 || blocked == 0 || paused == 0 || auto_off_completion == 0 || saturations == 0)
      $fatal(1, "Incomplete execution coverage");
    $display("PASS TARGET_EXECUTION cells=%0d cycles=%0d checks=%0d patterns=%0d faults=%0d resets=%0d signature=%h",
      N, cycles, comparisons, patterns, faults, resets, signature);
    $display("EXECUTION_EVENTS cells=%0d routes=%0d completions=%0d retargeted=%0d blocked=%0d paused=%0d auto_off_completion=%0d saturations=%0d",
      N, routes, completions, retargeted, blocked, paused, auto_off_completion, saturations);
    done = 1;
  end
endmodule

module frp_m32_target_execution_multicell_tb;
  wire done8, done16, done32;
  frp_m32_target_execution_checker #(.N(8)) c8(done8);
  frp_m32_target_execution_checker #(.N(16)) c16(done16);
  frp_m32_target_execution_checker #(.N(32)) c32(done32);
  initial begin
    wait (done8 && done16 && done32);
    $display("PASS TARGET_EXECUTION_ALL cells=8,16,32");
    $finish;
  end
  initial begin
    #2000000;
    $fatal(1, "Target execution regression watchdog");
  end
endmodule

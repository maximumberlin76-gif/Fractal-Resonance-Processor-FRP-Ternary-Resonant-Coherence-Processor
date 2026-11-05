// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_pending_routes.sv"

module frp_m31_pending_boundary_tb #(
  parameter int CELLS = 9,
  parameter int LANES = 3
);
  localparam int IW = (CELLS <= 1) ? 1 : $clog2(CELLS);
  typedef logic [2*CELLS-1:0] bank_t;
  typedef logic [CELLS-1:0] mask_t;
  typedef struct packed {
    bank_t next_bank;
    mask_t active, created, completed, cleared, retained, blocked, reserved, overflow;
    logic [31:0] live, births, deaths, clears, holds, bad_states;
    logic [31:0] routed, prevented, collisions, direct_events;
    logic domain_ok, polarity_ok, zero_ok, owner_ok, capacity_ok;
    logic replay_ok, no_reserved, no_overflow, no_direct;
  } result_t;

  logic clk = 0, rst_n = 1, tick;
  bank_t state_in, pending_q, model;
  logic [LANES-1:0] accept, neutral;
  logic [LANES*IW-1:0] addr;
  logic [2*LANES-1:0] target;
  mask_t grant;
  result_t got, want;
  int unsigned seed, random_state;
  longint unsigned checks = 0, cases = 0, resets = 0;
  longint unsigned invalid_cases = 0, random_cases = 0;
  logic [63:0] signature = 64'hcbf29ce484222325;

  frp_m31_pending_routes #(.CELLS(CELLS), .REQUEST_LANES(LANES),
    .CELL_INDEX_BITS(IW), .COUNTER_BITS(32)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick), .state_q(state_in),
    .request_accept(accept), .request_neutralized(neutral),
    .request_cell_index(addr), .request_target(target),
    .pending_completion_accept_mask(grant), .pending_route_q(pending_q),
    .pending_route_d(got.next_bank), .pending_active_mask(got.active),
    .pending_created_mask(got.created), .pending_completed_mask(got.completed),
    .pending_cleared_mask(got.cleared), .pending_retained_mask(got.retained),
    .pending_blocked_mask(got.blocked), .pending_reserved_mask(got.reserved),
    .pending_overflow_mask(got.overflow), .pending_active_count(got.live),
    .pending_created_events(got.births), .pending_completed_events(got.deaths),
    .pending_cleared_events(got.clears), .pending_retained_events(got.holds),
    .pending_reserved_events(got.bad_states), .neutral_routed_events(got.routed),
    .prevented_direct_events(got.prevented), .queue_overflow_events(got.collisions),
    .actual_direct_events(got.direct_events), .pending_domain_valid(got.domain_ok),
    .pending_polarity_valid(got.polarity_ok),
    .pending_completion_from_zero_valid(got.zero_ok),
    .pending_non_overwrite_valid(got.owner_ok), .pending_capacity_valid(got.capacity_ok),
    .pending_replay_deterministic(got.replay_ok), .no_pending_reserved_state(got.no_reserved),
    .no_queue_overflow(got.no_overflow), .no_actual_direct_events(got.no_direct)
  );

  // Literal wire encodings and an independent per-cell ownership scoreboard.
  function automatic bit opposite(input logic [1:0] a, b);
    return ((a == 2'b01) && (b == 2'b11)) ||
           ((a == 2'b11) && (b == 2'b01));
  endfunction

  function automatic int unsigned draw();
    random_state = random_state ^ (random_state << 13);
    random_state = random_state ^ (random_state >> 17);
    random_state = random_state ^ (random_state << 5);
    return random_state;
  endfunction

  task automatic idle();
    tick = 1; state_in = '0; accept = '0; neutral = '0;
    addr = '0; target = '0; grant = '0;
  endtask

  task automatic lane(input int l, c, input logic [1:0] dest);
    addr[l*IW+:IW] = IW'(c); target[2*l+:2] = dest;
    accept[l] = 1; neutral[l] = 1;
  endtask

  task automatic predict();
    want = '0;
    want.next_bank = model;
    want.domain_ok = 1; want.polarity_ok = 1; want.zero_ok = 1;
    want.owner_ok = 1; want.capacity_ok = 1; want.replay_ok = 1;
    want.no_reserved = 1; want.no_overflow = 1; want.no_direct = 1;
    for (int c = 0; c < CELLS; c++) begin
      bit occupied, completed, claimed;
      occupied = (model[2*c+:2] != 0);
      completed = tick && grant[c] && occupied && (state_in[2*c+:2] == 0);
      claimed = 0;
      if (model[2*c+:2] == 2'b10) $fatal(1, "PENDING_BOUNDARY oracle domain");
      want.active[c] = occupied;
      want.completed[c] = completed;
      want.cleared[c] = completed;
      want.retained[c] = occupied && !completed;
      want.blocked[c] = want.retained[c];
      if (completed) want.next_bank[2*c+:2] = 0;
      if (tick && grant[c] && !completed) begin
        want.capacity_ok = 0; want.replay_ok = 0;
        if (occupied) want.zero_ok = 0;
      end
      // Only the first legal lane may acquire an initially empty slot.
      for (int l = 0; l < LANES; l++) begin
        if (tick && accept[l] && neutral[l] && (int'(addr[l*IW+:IW]) == c)) begin
          if (!opposite(state_in[2*c+:2], target[2*l+:2])) begin
            want.polarity_ok = 0; want.replay_ok = 0;
          end else if (occupied || claimed) begin
            want.blocked[c] = 1; want.overflow[c] = 1;
            want.collisions++;
            want.owner_ok = 0; want.replay_ok = 0;
          end else begin
            claimed = 1; want.created[c] = 1;
            want.next_bank[2*c+:2] = target[2*l+:2];
          end
        end
      end
    end
    for (int l = 0; l < LANES; l++) begin
      if (tick && accept[l] && neutral[l]) begin
        want.routed++;
        if (int'(addr[l*IW+:IW]) >= CELLS) begin
          want.domain_ok = 0; want.replay_ok = 0;
        end
      end
    end
    want.live = $countones(want.active);
    want.births = $countones(want.created);
    want.deaths = $countones(want.completed);
    want.clears = want.deaths;
    want.holds = tick ? $countones(want.retained) : 0;
    want.prevented = want.routed;
    want.no_overflow = (want.collisions == 0);
    if (want.deaths > LANES) want.capacity_ok = 0;
  endtask

  task automatic step(input int phase);
    predict();
    #1;
    if (pending_q !== model || got !== want)
      $fatal(1, "PENDING_BOUNDARY outputs phase=%0d case=%0d cells=%0d q=%h model=%h got=%h want=%h",
             phase, cases, CELLS, pending_q, model, got, want);
    // Fold every output bit; no packed-bank truncation in the signature.
    for (int b = 0; b < $bits(result_t); b++)
      signature = (signature ^ {63'b0, got[b]}) * 64'h100000001b3;
    clk = 1; #1;
    if (tick) model = want.next_bank;
    if (pending_q !== model)
      $fatal(1, "PENDING_BOUNDARY register phase=%0d case=%0d cells=%0d got=%h want=%h",
             phase, cases, CELLS, pending_q, model);
    clk = 0; #1;
    checks++;
  endtask

  task automatic reset_bank();
    idle(); tick = 0; clk = 0; rst_n = 0; #1;
    model = '0;
    if (pending_q !== model) $fatal(1, "PENDING_BOUNDARY asynchronous reset");
    rst_n = 1; #1;
    resets++;
  endtask

  task automatic prime(input int c, input logic [1:0] polarity);
    idle();
    state_in[2*c+:2] = (polarity == 2'b01) ? 2'b11 : 2'b01;
    lane(0, c, polarity);
    step(1);
  endtask

  initial begin
    int c, l0, l1;
    logic [1:0] polarity;
    if (CELLS < 2 || CELLS > 64 || LANES < 2 || LANES > CELLS)
      $fatal(1, "PENDING_BOUNDARY parameter range");
    seed = 0;
    if ($value$plusargs("SEED=%d", seed)) begin end
    random_state = seed ^ 32'h6d2b79f5;
    if (random_state == 0) random_state = 1;
    reset_bank();
    // All state codes, both target codes, six control bits, three reachable
    // pending states, and every cell. Pending is created through public ports.
    for (int offset = 0; offset < CELLS; offset++) begin
      c = int'((32'(offset) + seed % CELLS) % CELLS);
      l0 = int'((32'(offset) + seed % LANES) % LANES);
      l1 = (l0 + 1) % LANES;
      for (int p = 0; p < 3; p++)
        for (int s = 0; s < 4; s++)
          for (int ctl = 0; ctl < 64; ctl++)
            for (int targets = 0; targets < 16; targets++) begin
              reset_bank();
              if (p != 0) prime(c, (p == 1) ? 2'b01 : 2'b11);
              idle();
              state_in[2*c+:2] = 2'(s);
              lane(l0, c, 2'(targets)); lane(l1, c, 2'(targets >> 2));
              tick = ctl[0]; grant[c] = ctl[1];
              accept[l0] = ctl[2]; neutral[l0] = ctl[3];
              accept[l1] = ctl[4]; neutral[l1] = ctl[5];
              step(2); cases++;
            end
    end
    // Out-of-range addresses remain observable with non-power-of-two CELLS.
    reset_bank();
    for (int a = CELLS; a < (1 << IW); a++)
      for (int l = 0; l < LANES; l++)
        for (int t = 0; t < 4; t++)
          for (int ctl = 0; ctl < 8; ctl++) begin
            idle(); lane(l, a, 2'(t));
            tick = ctl[0]; accept[l] = ctl[1]; neutral[l] = ctl[2];
            step(3); invalid_cases++;
          end
    // Fill all slots, pause without clearing, then complete all slots at once.
    for (int sign = 0; sign < 2; sign++) begin
      reset_bank(); polarity = sign ? 2'b11 : 2'b01;
      for (int j = 0; j < CELLS; j++) prime(j, polarity);
      for (int pause = 0; pause < 8; pause++) begin
        idle(); tick = 0; grant = '1;
        for (int l = 0; l < LANES; l++) lane(l, l, polarity);
        step(4);
      end
      idle(); grant = '1; step(5);
      idle(); step(6);
      prime(CELLS-1, polarity);
      reset_bank(); step(7);
    end
    // Stateful mixed-cell traffic, malformed inputs, pauses and reset recovery.
    for (int r = 0; r < 4096; r++) begin
      if ((r % 127) == 0) reset_bank();
      idle(); tick = 1'(draw());
      for (int j = 0; j < CELLS; j++) begin
        state_in[2*j+:2] = 2'(draw()); grant[j] = 1'(draw());
      end
      for (int l = 0; l < LANES; l++) begin
        addr[l*IW+:IW] = IW'(draw()); target[2*l+:2] = 2'(draw());
        accept[l] = 1'(draw()); neutral[l] = 1'(draw());
      end
      step(8); random_cases++;
    end
    idle(); grant = '1; step(9);
    if (model !== '0) $fatal(1, "PENDING_BOUNDARY final drain");
    if (cases != 64'(CELLS)*12288 || random_cases != 4096 ||
        invalid_cases != 64'((1 << IW)-CELLS)*LANES*32)
      $fatal(1, "PENDING_BOUNDARY enumeration count");
    $display("PASS PENDING_BOUNDARY cells=%0d lanes=%0d seed=%0d cases=%0d invalid=%0d random=%0d checks=%0d resets=%0d signature=%h",
             CELLS, LANES, seed, cases, invalid_cases, random_cases, checks, resets, signature);
    $finish;
  end
endmodule

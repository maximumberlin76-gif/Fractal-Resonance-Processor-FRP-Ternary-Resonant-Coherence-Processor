// SPDX-License-Identifier: Apache-2.0
// Pending-register invariants under unrestricted public input codes.
// The first sampled cycle is held in reset; subsequent resets are unrestricted.
// Formal time denotes sampled rising edges after async2sync.
// Coverage correspondence in frp_m31_pending_routes.sv:
// current domain: line 205; next domain: line 429; retained polarity: line 435;
// completed route clearing: line 444; created route polarity: line 451.
// Cover targets record reachable activity separately from invariant proofs.
`ifndef FRP_M31_PENDING_REACHABILITY_FORMAL_SV
`define FRP_M31_PENDING_REACHABILITY_FORMAL_SV
`include "frp_m31_pending_routes.sv"

module frp_m31_pending_reachability_formal #(
  parameter int CELLS = 9,
  parameter int LANES = 3,
  parameter int EXTRA_INDEX_BIT = 0,
  localparam int IW = $clog2(CELLS) + EXTRA_INDEX_BIT
) (
  input logic clk, rst_n, tick_enable,
  input logic [2*CELLS-1:0] state_q,
  input logic [LANES-1:0] request_accept, request_neutralized,
  input logic [LANES*IW-1:0] request_cell_index,
  input logic [2*LANES-1:0] request_target,
  input logic [CELLS-1:0] completion_grant,
  output wire [2*CELLS-1:0] pending_q, pending_d,
  output logic [5:0] invariant_ok,
  output logic [9:0] reach
);
  initial begin
    a_size: assert (CELLS >= 2 && CELLS <= 64);
    a_lanes: assert (LANES >= 1 && LANES <= CELLS);
    a_index: assert (EXTRA_INDEX_BIT == 0 || EXTRA_INDEX_BIT == 1);
  end

  wire [CELLS-1:0] created, completed, reserved, overflow;
  wire [31:0] reserved_events;
  wire no_reserved, polarity_valid, completion_from_zero_valid;
  frp_m31_pending_routes #(
    .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES),
    .CELL_INDEX_BITS(IW), .COUNTER_BITS(32)
  ) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable), .state_q(state_q),
    .request_accept(request_accept), .request_neutralized(request_neutralized),
    .request_cell_index(request_cell_index), .request_target(request_target),
    .pending_completion_accept_mask(completion_grant),
    .pending_route_q(pending_q), .pending_route_d(pending_d),
    .pending_created_mask(created), .pending_completed_mask(completed),
    .pending_reserved_mask(reserved), .pending_overflow_mask(overflow),
    .pending_reserved_events(reserved_events), .no_pending_reserved_state(no_reserved),
    .pending_polarity_valid(polarity_valid),
    .pending_completion_from_zero_valid(completion_from_zero_valid)
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
    previous_q <= pending_q;
    previous_d <= pending_d;
  end

  function automatic bit polarized(input logic [1:0] value);
    return value == 2'b01 || value == 2'b11;
  endfunction

  // The five coverage guards are checked directly from public outputs.
  always_comb begin
    invariant_ok = '1;
    for (int c = 0; c < CELLS; c++) begin
      invariant_ok[0] &= pending_q[2*c+:2] != 2'b10;
      invariant_ok[1] &= pending_d[2*c+:2] != 2'b10;
      invariant_ok[2] &= !polarized(pending_q[2*c+:2]) || completed[c]
        || pending_d[2*c+:2] == pending_q[2*c+:2];
      invariant_ok[3] &= !completed[c] || pending_d[2*c+:2] == 0;
      invariant_ok[4] &= !created[c] || polarized(pending_d[2*c+:2]);
    end
    invariant_ok[5] = no_reserved && reserved == 0 && reserved_events == 0;
    if (history_valid) begin
      a_current_domain: assert (invariant_ok[0]);
      a_next_domain: assert (invariant_ok[1]);
      a_retained_polarity: assert (invariant_ok[2]);
      a_completion_clears: assert (invariant_ok[3]);
      a_creation_polarity: assert (invariant_ok[4]);
      a_reserved_diagnostics: assert (invariant_ok[5]);
      if (!rst_n || !previous_reset) begin
        a_reset_register: assert (pending_q == 0);
      end else if (previous_tick) begin
        a_commit_register: assert (pending_q == previous_d);
      end else begin
        a_pause_register: assert (pending_q == previous_q);
      end
    end
  end

  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = pending_q[1:0] == 2'b01;
      reach[1] = pending_q[1:0] == 2'b11;
      reach[2] = pending_q != 0 && !tick_enable;
      reach[3] = completed[0] && polarized(pending_q[1:0]);
      reach[4] = overflow != 0;
      for (int l = 0; l < LANES; l++)
        reach[5] |= tick_enable && request_accept[l] && request_neutralized[l]
          && int'(request_cell_index[l*IW+:IW]) >= CELLS;
      reach[6] = !polarity_valid;
      reach[7] = !completion_from_zero_valid;
      reach[9] = polarized(pending_q[2*CELLS-1-:2]);
    end
    reach[8] = history_valid && previous_reset && !rst_n && previous_q != 0;
  end
endmodule
`endif

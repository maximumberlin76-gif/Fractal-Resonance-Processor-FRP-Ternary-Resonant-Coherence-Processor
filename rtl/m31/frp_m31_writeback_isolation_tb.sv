// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_state_update.sv"

module frp_m31_writeback_isolation_tb #(parameter int CELLS = 9);
  import frp_m31_pkg::*;
  typedef logic [2*CELLS-1:0] bank_t;
  typedef logic [CELLS-1:0] mask_t;
  logic clk, rst_n, tick;
  frp_m31_scheduler_state_e sched;
  bank_t candidate, q, d, visible;
  mask_t cap, change, route, complete, reserved, direct_flag;
  mask_t wr, hold_m, reset_m, bad_m;
  logic [31:0] writes, holds, resets, routed, completed, direct_events;
  logic update_ok, output_ok;
  int unsigned seed;
  int unsigned cases /* verilator public_flat_rw */ = 0;
  int unsigned probe_writes /* verilator public_flat_rw */ = 0;
  int unsigned isolated_writes /* verilator public_flat_rw */ = 0;
  logic [63:0] signature /* verilator public_flat_rw */ = 64'hcbf29ce484222325;

  frp_m31_state_update #(.CELLS(CELLS), .STATE_BITS(2),
      .REQUEST_LANES(2), .COUNTER_BITS(32)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick), .scheduler_state(sched),
    .state_candidate_d(candidate), .capacity_accept_mask(cap),
    .accepted_change_candidate_mask(change), .neutral_routed_mask(route),
    .pending_completion_mask(complete), .reserved_transition_mask(reserved),
    .actual_direct_mask(direct_flag), .state_q(q), .state_d(d),
    .state_out(visible), .state_write_enable_mask(wr), .state_hold_mask(hold_m),
    .state_reset_mask(reset_m), .state_reserved_mask(bad_m),
    .state_write_events(writes), .state_hold_events(holds),
    .state_reset_events(resets), .neutral_routed_commit_events(routed),
    .pending_completion_commit_events(completed), .actual_direct_events(direct_events),
    .state_update_valid(update_ok), .state_output_domain_valid(output_ok)
  );

  task automatic pulse();
    #1; clk = 1; #1; clk = 0; #1;
  endtask

  function automatic logic [1:0] symbol(input int k);
    case (k)
      0: return FRP_STATE_ZERO;
      1: return FRP_STATE_POS;
      2: return FRP_STATE_NEG;
      default: return FRP_STATE_RESERVED;
    endcase
  endfunction

  task automatic trial(input int src, dst, mode, input logic [6:0] flags);
    int p, neighbor;
    bank_t before_q, expected;
    mask_t want_w, want_bad;
    bit to_zero, from_zero, can_enter, can_leave, allow, peer_write;
    p = int'((cases % CELLS + seed % CELLS) % CELLS);
    neighbor = (p+1) % CELLS;

    rst_n=0; tick=0; sched=FRP_SCHED_FREE; candidate='0;
    cap='0; change='0; route='0; complete='0; reserved='0; direct_flag='0;
    pulse();
    if ({q,d,visible,wr,hold_m} !== '0 || reset_m !== '1 || resets !== CELLS)
      $fatal(1,"WRITEBACK reset case=%0d",cases);

    rst_n=1; tick=1;
    before_q='0; before_q[2*p+:2]=symbol(src);
    candidate=before_q; cap[p]=(src!=0); change=cap;
    pulse();
    if (q !== before_q || visible !== before_q)
      $fatal(1,"WRITEBACK preload cell=%0d src=%0d",p,src);

    sched=frp_m31_scheduler_state_e'(mode);
    {tick,cap[p],change[p],route[p],complete[p],reserved[p],direct_flag[p]}=flags;
    candidate[2*p+:2]=symbol(dst);
    // The peer requests an ordinary positive write from active neutral.
    candidate[2*neighbor+:2]=FRP_STATE_POS; cap[neighbor]=1; change[neighbor]=1;
    #1;
    // Independent transition table indexed by source, destination and mode.
    from_zero=(src==0 && (dst==1 || dst==2));
    to_zero=(src!=0 && dst==0);
    can_enter=(mode==0 || mode==2 || mode==3);
    can_leave=(mode==0 || mode==1 || mode==4);
    allow=flags[6] && flags[5] && flags[4] && !flags[1] && !flags[0] &&
          ((from_zero && can_enter && !flags[3]) ||
           (to_zero && can_leave && !flags[2]));
    peer_write=flags[6] && can_enter;
    expected=before_q; want_w='0; want_bad='0;
    if (allow) begin expected[2*p+:2]=symbol(dst); want_w[p]=1; end
    if (peer_write) begin expected[2*neighbor+:2]=FRP_STATE_POS; want_w[neighbor]=1; end
    want_bad[p]=(dst==3 || flags[1]);

    if (q !== before_q || visible !== before_q || d !== expected ||
        wr !== want_w || hold_m !== ~want_w || reset_m !== '0 || bad_m !== want_bad ||
        writes !== $countones(want_w) || holds !== CELLS-$countones(want_w) ||
        routed !== 32'(allow && flags[3]) || completed !== 32'(allow && flags[2]) ||
        direct_events !== 0 || output_ok !== 1'b1)
      $fatal(1,"WRITEBACK decision case=%0d p=%0d src=%0d dst=%0d mode=%0d flags=%07b expected=%h got=%h",
             cases,p,src,dst,mode,flags,expected,d);
    if ((dst==3 || flags[1] || flags[0] || mode>=5 ||
         (src!=0 && dst!=0 && dst!=3 && src!=dst)) && update_ok !== 1'b0)
      $fatal(1,"WRITEBACK missing diagnostic case=%0d",cases);
    if (allow && peer_write && update_ok !== 1'b1)
      $fatal(1,"WRITEBACK legal transition flagged case=%0d",cases);
    pulse();
    if (q !== expected || visible !== expected)
      $fatal(1,"WRITEBACK register case=%0d expected=%h got=%h",cases,expected,q);
    probe_writes += int'(allow);
    isolated_writes += int'(peer_write && !allow);
    signature=(signature ^ 64'(cases) ^ (64'(p)<<32) ^
               (64'(q[2*p+:2])<<48) ^ (64'(q[2*neighbor+:2])<<56))
              * 64'h00000100000001b3;
    cases++;
  endtask

  initial begin
    if (CELLS<2) $fatal(1,"CELLS must be at least two");
    if (!$value$plusargs("SEED=%d",seed)) seed=0;
    clk=0;
    for (int src=0;src<3;src++)
      for (int dst=0;dst<4;dst++)
        for (int mode=0;mode<8;mode++)
          for (int f=0;f<128;f++)
            trial(src,dst,mode,7'(f));
    if (cases!=12288 || probe_writes!=24 || isolated_writes!=2288)
      $fatal(1,"WRITEBACK coverage cases=%0d writes=%0d isolated=%0d",
             cases,probe_writes,isolated_writes);
    $display("PASS WRITEBACK_ISOLATION cells=%0d seed=%0d cases=%0d probe_writes=%0d isolated_writes=%0d signature=%016h",
             CELLS,seed,cases,probe_writes,isolated_writes,signature);
    $finish;
  end
endmodule

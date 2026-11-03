// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_pending_routes.sv"

module frp_m31_pending_ownership_tb #(parameter int CELLS=9);
  import frp_m31_pkg::*;
  localparam int IW=(CELLS<=1)?1:$clog2(CELLS);
  typedef logic [CELLS-1:0] mask_t;
  typedef logic [2*CELLS-1:0] bank_t;
  logic clk, rst_n, tick;
  logic [2:0] accept, neutral;
  logic [3*IW-1:0] addr;
  logic [5:0] target;
  bank_t state_in, q, d, model;
  mask_t grant, active, created, done, cleared, retained, blocked, overflow;
  logic [31:0] count_active, ncreate, ndone, nclear, nkeep, ncollision;
  logic [31:0] routed, prevented, direct_events;
  logic cap_ok, zero_ok, owner_ok, no_overflow, polarity_ok, domain_ok;
  int unsigned seed;
  int unsigned checks /* verilator public_flat_rw */ = 0;
  logic [63:0] signature /* verilator public_flat_rw */ = 64'hcbf29ce484222325;

  frp_m31_pending_routes #(.CELLS(CELLS),.REQUEST_LANES(3),
    .CELL_INDEX_BITS(IW),.COUNTER_BITS(32)) dut (
    .clk(clk),.rst_n(rst_n),.tick_enable(tick),.state_q(state_in),
    .request_accept(accept),.request_neutralized(neutral),
    .request_cell_index(addr),.request_target(target),
    .pending_completion_accept_mask(grant),.pending_route_q(q),.pending_route_d(d),
    .pending_active_mask(active),.pending_created_mask(created),
    .pending_completed_mask(done),.pending_cleared_mask(cleared),
    .pending_retained_mask(retained),.pending_blocked_mask(blocked),
    .pending_overflow_mask(overflow),.pending_active_count(count_active),
    .pending_created_events(ncreate),.pending_completed_events(ndone),
    .pending_cleared_events(nclear),.pending_retained_events(nkeep),
    .queue_overflow_events(ncollision),.neutral_routed_events(routed),
    .prevented_direct_events(prevented),.actual_direct_events(direct_events),
    .pending_capacity_valid(cap_ok),.pending_completion_from_zero_valid(zero_ok),
    .pending_non_overwrite_valid(owner_ok),.no_queue_overflow(no_overflow),
    .pending_domain_valid(domain_ok),.pending_polarity_valid(polarity_ok)
  );

  task automatic idle();
    tick=1; accept='0; neutral='0; addr='0; target='0; grant='0; state_in='0;
  endtask

  task automatic request_lane(input int lane,cell_id,input logic [1:0] dest);
    addr[lane*IW+:IW]=IW'(cell_id); target[2*lane+:2]=dest;
    accept[lane]=1; neutral[lane]=1;
  endtask

  task automatic step(input int phase, input bank_t next_bank,
      input mask_t births, deaths, collisions, input int hits, attempts,
      input bit capacity_valid, completion_valid);
    mask_t live, keep;
    live='0;
    for (int j=0;j<CELLS;j++) live[j]=(model[2*j+:2]!=FRP_STATE_ZERO);
    keep=live & ~deaths;
    #1;
    if (q!==model || d!==next_bank || active!==live || created!==births ||
        done!==deaths || cleared!==deaths || retained!==keep ||
        blocked!==(keep|collisions) || overflow!==collisions)
      $fatal(1,"PENDING ownership phase=%0d check=%0d expected=%h got=%h",phase,checks,next_bank,d);
    if (count_active!==$countones(live) || ncreate!==$countones(births) ||
        ndone!==$countones(deaths) || nclear!==ndone ||
        nkeep!==(tick?$countones(keep):0) || ncollision!==hits ||
        routed!==attempts || prevented!==attempts || direct_events!==0)
      $fatal(1,"PENDING accounting phase=%0d check=%0d",phase,checks);
    if (cap_ok!==capacity_valid || zero_ok!==completion_valid ||
        owner_ok!==(hits==0) || no_overflow!==(hits==0) ||
        domain_ok!==1'b1 || polarity_ok!==1'b1)
      $fatal(1,"PENDING diagnostic phase=%0d check=%0d",phase,checks);
    clk=1; #1;
    if (q!==next_bank)
      $fatal(1,"PENDING register phase=%0d check=%0d",phase,checks);
    for (int j=0;j<CELLS;j++)
      signature=(signature ^ 64'(q[2*j+:2])) * 64'h100000001b3;
    model=next_bank; checks++; clk=0; #1;
  endtask

  task automatic scenario(input int a,b,pol);
    mask_t ma,mb;
    bank_t both,only_a,only_b;
    logic [1:0] x,y;
    ma='0; ma[a]=1; mb='0; mb[b]=1;
    x=pol!=0?FRP_STATE_POS:FRP_STATE_NEG;
    y=pol!=0?FRP_STATE_NEG:FRP_STATE_POS;
    only_a='0; only_a[2*a+:2]=x;
    only_b='0; only_b[2*b+:2]=y; both=only_a|only_b;

    // A duplicate claim and an independent allocation on the same edge.
    idle(); state_in[2*a+:2]=y; state_in[2*b+:2]=x;
    request_lane(0,a,x); request_lane(1,b,y); request_lane(2,a,x);
    step(1,both,ma|mb,'0,ma,1,3,1,1);

    // Pause with both grants asserted and a live overwrite attempt.
    idle(); tick=0; grant=ma|mb; state_in[2*a+:2]=x; request_lane(1,a,y);
    step(2,both,'0,'0,'0,0,0,1,1);

    // Two injected requests would replace A by its opposite; B can retire.
    idle(); grant=mb; state_in[2*a+:2]=x;
    request_lane(0,a,y); request_lane(2,a,y);
    step(3,only_a,'0,mb,ma,2,2,1,1);

    // Completion from nonzero must fail locally; B can allocate again.
    idle(); grant=ma; state_in[2*a+:2]=y; state_in[2*b+:2]=x;
    request_lane(2,b,y);
    step(4,both,mb,'0,'0,0,1,0,0);

    // With both retained cells at active neutral, only granted A retires.
    idle(); grant=ma;
    step(5,only_b,'0,ma,'0,0,0,1,1);

    // A stale grant and B's legal completion coexist.
    idle(); grant=ma|mb;
    step(6,'0,'0,mb,'0,0,0,0,1);
  endtask

  initial begin
    if (CELLS<2) $fatal(1,"CELLS must be at least two");
    if (!$value$plusargs("SEED=%d",seed)) seed=0;
    clk=0; rst_n=0; model='0; idle(); #1; clk=1; #1; clk=0; rst_n=1;
    for (int i=0;i<CELLS;i++)
      for (int pol=0;pol<2;pol++) begin
        int a,b;
        a=int'((seed%CELLS+i)%CELLS);
        b=(a+1+int'(seed%(CELLS-1)))%CELLS;
        scenario(a,b,pol);
      end
    if (checks!=12*CELLS || q!=='0) $fatal(1,"PENDING incomplete");
    $display("PASS PENDING_OWNERSHIP cells=%0d seed=%0d scenarios=%0d checks=%0d signature=%016h",
             CELLS,seed,2*CELLS,checks,signature);
    $finish;
  end
endmodule

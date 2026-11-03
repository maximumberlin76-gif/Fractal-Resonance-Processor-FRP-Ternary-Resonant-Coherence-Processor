// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Same cells and stimulus, adjacent service widths. The extra lane is idle.
// For a closed pending set, eligible tick j retires address ranks
// [j*K,(j+1)*K); repeated destination requests cannot replace pending work.
// Drain starts at phase 7. Latencies count enabled ticks, excluding pauses.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_service_width_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
  typedef logic [1:0] trit_t;
  logic clk=0,rst_n=1,tick_enable=0,clear_counters=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE;
  logic [L-1:0] valid='0;
  logic [L*B-1:0] addr='0;
  logic [2*L-1:0] goal='0;
  logic [2*CELLS-1:0] destination='0;
  wire [2*CELLS-1:0] state_word[2],pending[2];
  wire [CELLS-1:0] changed[2];
  wire [L:0] take[2],deny[2];
  wire [31:0] count[2],remaining[2],load[2],illegal[2],reserved[2],overflow[2],recorded[2];
  wire [FRP_M31_INVARIANT_FLAGS-1:0] flags[2];
  wire frp_m31_scheduler_state_e phase_state[2];
  int order_list[CELLS],rank_id[CELLS];
  int ticks,ledger,mode_id,population,opps,elapsed;
  int cases=0,checks=0,pauses=0,early=0,equal_finish=0,ack_splits=0;
  int unsigned seed=76,rng;
  logic [63:0] signature=64'hcbf29ce484222325;

  for (genvar d=0;d<2;d++) begin : g_core
    localparam int K=L+d;
    wire [K-1:0] ack,rej;
    assign take[d]=(L+1)'(ack);
    assign deny[d]=(L+1)'(rej);
    frp_m31_execution_core #(.CELLS(CELLS),.REQUEST_LANES(K),.COUNTER_BITS(32)) dut (
      .clk,.rst_n,.tick_enable,.clear_counters,.scheduler_mode,
      .request_valid(K'(valid)),.request_cell_index((K*B)'(addr)),.request_target((2*K)'(goal)),
      .target_q(destination),.state_out(state_word[d]),.pending_route_out(pending[d]),
      .request_accept(ack),.request_reject(rej),.accepted_change_mask(changed[d]),
      .accepted_changes(count[d]),.capacity_remaining(remaining[d]),.switch_load_numerator(load[d]),
      .actual_direct_events(illegal[d]),.reserved_state_events(reserved[d]),.queue_overflow_events(overflow[d]),
      .ticks_recorded_q(recorded[d]),.scheduler_state_q(phase_state[d]),.invariant_flags(flags[d])
    );
  end

  function automatic int unsigned rnd();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction
  function automatic int cadence(input int m,n);
    case (m) 0:return 0; 1:return n%8==7?2:1; default:return n%8==0?3:4; endcase
  endfunction

  task automatic pulse(input bit en,input int next_mode);
    logic [2*CELLS-1:0] h[2],p[2];
    logic [CELLS-1:0] mask[2];
    int pre_cadence;
    tick_enable=en; scheduler_mode=frp_m31_scheduler_mode_e'(next_mode); #1;
    for (int d=0;d<2;d++) begin
      h[d]=state_word[d]; p[d]=pending[d]; mask[d]=changed[d];
      if (flags[d]!=='1 || {illegal[d],reserved[d],overflow[d]}!=='0 ||
          count[d]!=$countones(mask[d]) || remaining[d]!=L+d-count[d] || load[d]!=count[d])
        $fatal(1,"SERVICE_WIDTH capacity or invariant");
      if (!en && {take[d],deny[d],mask[d]}!=='0) $fatal(1,"SERVICE_WIDTH disabled grant");
    end
    clk=1; #1; if (clear_counters) ledger=0;
    if (en) begin ticks++; ledger++; end else pauses++;
    for (int d=0;d<2;d++) begin
      if (recorded[d]!==32'(ledger) || (!en && pending[d]!==p[d]))
        $fatal(1,"SERVICE_WIDTH pause or counter");
      for (int c=0;c<CELLS;c++) begin
        trit_t a,b,q;
        a=h[d][2*c+:2]; b=state_word[d][2*c+:2]; q=pending[d][2*c+:2];
        if ((a!=b)!=mask[d][c] || (a!=0 && b!=0 && a!=b) ||
            b==2 || q==2 || (q!=0 && b!=0)) $fatal(1,"SERVICE_WIDTH writeback");
      end
    end
    clk=0; #1;
  endtask

  task automatic prepare(input int style);
    int a,j,tmp,next_rank;
    for (int c=0;c<CELLS;c++) begin order_list[c]=(c+cases)%CELLS; rank_id[c]=-1; end
    if (style==1) for (int i=CELLS-1;i>0;i--) begin
      j=int'(rnd()%(i+1)); tmp=order_list[i]; order_list[i]=order_list[j]; order_list[j]=tmp;
    end
    destination='0;
    for (int i=0;i<population;i++) begin
      a=order_list[i]; destination[2*a+:2]=rnd()%2?1:3;
    end
    next_rank=0;
    for (int c=0;c<CELLS;c++) if (destination[2*c+:2]!=0) begin
      rank_id[c]=next_rank; next_rank++;
    end
    ticks=0; ledger=0; valid=0; addr=0; goal=0; tick_enable=0; clear_counters=0;
    scheduler_mode=FRP_MODE_FREE; rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1; #1;
    for (int leg=0;leg<2;leg++) begin
      for (int base=0;base<population;base+=L) begin
        valid=0; addr=0; goal=0;
        for (int k=0;k<L;k++) if (base+k<population) begin
          a=order_list[base+k]; valid[k]=1; addr[k*B+:B]=B'(a);
          goal[2*k+:2]=destination[2*a+:2]^(leg==0?2'b10:2'b00);
        end
        pulse(1,leg);
      end
      valid=0;
      if (leg==0) begin while (ticks%8!=0) pulse(1,0); pulse(0,1); end
      else while (ticks%8!=7) pulse(1,1);
    end
    pulse(0,mode_id);
    for (int d=0;d<2;d++) if (state_word[d]!=='0 || pending[d]!==destination)
      $fatal(1,"SERVICE_WIDTH common backlog");
  endtask

  task automatic service(input bit eligible);
    logic [CELLS-1:0] grants;
    logic [L:0] yes,no;
    int low,high,a;
    for (int d=0;d<2;d++) begin
      low=opps*(L+d); high=low+(eligible?(L+d):0);
      grants='0; yes='0; no='0;
      for (int c=0;c<CELLS;c++) begin
        int r;
        trit_t settled,waiting;
        r=rank_id[c]; settled=0; waiting=0;
        if (r>=0 && r<low) settled=destination[2*c+:2];
        if (r>=low) waiting=destination[2*c+:2];
        if (r>=low && r<high) grants[c]=1;
        if (state_word[d][2*c+:2]!==settled || pending[d][2*c+:2]!==waiting)
          $fatal(1,"SERVICE_WIDTH retained prefix cell=%0d rank=%0d width=%0d",c,r,L+d);
      end
      for (int k=0;k<L;k++) begin
        a=int'(addr[k*B+:B]);
        if (rank_id[a]>=low) no[k]=1; else yes[k]=1;
      end
      if (int'(phase_state[d])!=cadence(mode_id,ticks) || changed[d]!==grants ||
          take[d]!==yes || deny[d]!==no) $fatal(1,"SERVICE_WIDTH rank or ownership");
      signature=(signature^64'(grants))*64'h100000001b3;
      checks++;
    end
    if (take[0]!=take[1]) ack_splits++;
  endtask

  task automatic episode(input int style);
    int finished[2],need,deadline,a;
    bit eligible;
    prepare(style); elapsed=0; opps=0;
    for (int d=0;d<2;d++) finished[d]=(population==0)?0:-1;
    do begin
      for (int k=0;k<L;k++) begin
        a=order_list[(elapsed+k)%CELLS]; addr[k*B+:B]=B'(a); goal[2*k+:2]=destination[2*a+:2];
      end
      valid='1; clear_counters=(elapsed%5==2);
      if (elapsed%3==0) pulse(0,mode_id);
      tick_enable=1; #1; eligible=cadence(mode_id,ticks) inside {0,2,3};
      service(eligible); pulse(1,mode_id); elapsed++; if (eligible) opps++;
      for (int d=0;d<2;d++) if (pending[d]=='0 && finished[d]<0) finished[d]=elapsed;
      if (elapsed>8*((CELLS+L-1)/L)+1) $fatal(1,"SERVICE_WIDTH drain timeout");
    end while (finished[0]<0 || finished[1]<0);
    for (int d=0;d<2;d++) begin
      need=(population+L+d-1)/(L+d);
      deadline=(need==0)?0:((mode_id==0)?need:8*(need-1)+mode_id);
      if (finished[d]!=deadline || state_word[d]!==destination || pending[d]!=='0)
        $fatal(1,"SERVICE_WIDTH deadline width=%0d got=%0d want=%0d",L+d,finished[d],deadline);
    end
    if (finished[1]<finished[0]) early++; else equal_finish++;
    cases++;
  endtask

  initial begin
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    rng=seed^32'h9e3779b9; if (rng==0) rng=1;
    #1;
    for (mode_id=0;mode_id<3;mode_id++) for (population=0;population<=CELLS;population++)
      for (int style=0;style<2;style++) episode(style);
    if (cases!=6*(CELLS+1) || early==0 || equal_finish==0 || ack_splits==0)
      $fatal(1,"SERVICE_WIDTH missing activity");
    $display("PASS EXECUTION_SERVICE_WIDTH cells=%0d lanes=%0d seed=%0d cases=%0d checks=%0d pauses=%0d early=%0d equal_finish=%0d ack_splits=%0d signature=%h",
      CELLS,L,seed,cases,checks,pauses,early,equal_finish,ack_splits,signature);
    $finish;
  end
endmodule

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Sparse address embedding of the M31 execution core at fixed lane capacity.
// Compare public traces for order-preserving maps; reverse the address order
// as a control and predict which pending cells get the limited service slots.
// CELLS=8,9,16,32,64; runtime +SEED=0 or +SEED=76.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_embedding_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int S=(CELLS==9)?8:((CELLS==16)?9:CELLS/2);
  localparam int L=frp_calc_request_lanes(S), B=$clog2(S);
  typedef logic [1:0] trit_t;
  typedef struct packed {
    logic [2*CELLS-1:0] states,routes;
    logic [CELLS-1:0] owners,routed,changed;
    logic [L-1:0] take,deny;
    logic [31:0] count,remaining,load,ticks,requested,prevented,via_zero,illegal,reserved,overflow;
    logic [4:0][31:0] visits;
    logic exhausted;
    frp_m31_scheduler_mode_e mode;
    frp_m31_scheduler_state_e sched;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] flags;
  } sample_t;
  logic clk=0,rst_n=1,tick_enable=0,clear_counters=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE;
  logic [L-1:0] request_valid='0;
  logic [L*B-1:0] addr='0;
  logic [2*L-1:0] request_target='0;
  logic [2*S-1:0] goals='0;
  int physical[S];
  logic [CELLS-1:0] active;
  wire sample_t obs[2];
  int unsigned seed=76,rng;
  int layout,mode_id,ticks,checks=0,comparisons=0,pauses=0;
  int ranked_edges=0,split_grants=0,backlogs=0,conflicts=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  for (genvar d=0;d<2;d++) begin : g_core
    localparam int N=d?CELLS:S, AB=$clog2(N);
    wire [L*AB-1:0] indices;
    logic [2*N-1:0] targets;
    wire [2*N-1:0] states,routes;
    wire [N-1:0] owners,routed,changed;
    for (genvar k=0;k<L;k++)
      assign indices[k*AB+:AB]=AB'(d?physical[addr[k*B+:B]]:int'(addr[k*B+:B]));
    always_comb begin
      targets='0;
      for (int c=0;c<S;c++) targets[2*(d?physical[c]:c)+:2]=goals[2*c+:2];
    end
    assign obs[d].states=(2*CELLS)'(states); assign obs[d].routes=(2*CELLS)'(routes);
    assign obs[d].owners=CELLS'(owners); assign obs[d].routed=CELLS'(routed);
    assign obs[d].changed=CELLS'(changed);
    frp_m31_execution_core #(.CELLS(N),.REQUEST_LANES(L),.COUNTER_BITS(32)) dut (
      .clk,.rst_n,.tick_enable,.clear_counters,.scheduler_mode,.request_valid,
      .request_cell_index(indices),.request_target,.target_q(targets),
      .state_out(states),.pending_route_out(routes),.scheduler_mode_q(obs[d].mode),
      .scheduler_state_q(obs[d].sched),.ticks_recorded_q(obs[d].ticks),
      .scheduler_count_free_q(obs[d].visits[0]),.scheduler_count_balance_q(obs[d].visits[1]),
      .scheduler_count_commit_q(obs[d].visits[2]),.scheduler_count_excite_q(obs[d].visits[3]),
      .scheduler_count_neutralize_q(obs[d].visits[4]),.request_accept(obs[d].take),
      .request_reject(obs[d].deny),.accepted_cell_mask(owners),.neutral_routed_cell_mask(routed),
      .accepted_change_mask(changed),.accepted_changes(obs[d].count),.capacity_remaining(obs[d].remaining),
      .capacity_exhausted(obs[d].exhausted),.switch_load_numerator(obs[d].load),
      .requested_direct_events(obs[d].requested),.prevented_direct_events(obs[d].prevented),
      .neutral_routed_events(obs[d].via_zero),.actual_direct_events(obs[d].illegal),
      .reserved_state_events(obs[d].reserved),.queue_overflow_events(obs[d].overflow),
      .invariant_flags(obs[d].flags)
    );
  end

  function automatic sample_t project(input sample_t v);
    sample_t r;
    r=v; r.states='0; r.routes='0; r.owners='0; r.routed='0; r.changed='0;
    for (int c=0;c<S;c++) begin
      r.states[2*c+:2]=v.states[2*physical[c]+:2]; r.routes[2*c+:2]=v.routes[2*physical[c]+:2];
      r.owners[c]=v.owners[physical[c]]; r.routed[c]=v.routed[physical[c]]; r.changed[c]=v.changed[physical[c]];
    end
    return r;
  endfunction
  function automatic int unsigned rnd();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction
  function automatic trit_t sign_for(input int c);
    return ((c+seed)%2)?3:1;
  endfunction

  task automatic inspect(input bit compare_all);
    for (int d=0;d<2;d++) begin
      if (obs[d].flags!=='1 || {obs[d].illegal,obs[d].reserved,obs[d].overflow}!=='0 ||
          obs[d].count!=$countones(obs[d].changed) || obs[d].remaining+obs[d].count!=L)
        $fatal(1,"EMBEDDING capacity/domain layout=%0d tick=%0d",layout,ticks);
      for (int c=0;c<CELLS;c++) begin
        if (obs[d].states[2*c+:2]==2 || obs[d].routes[2*c+:2]==2 ||
            (obs[d].routes[2*c+:2]!=0 && obs[d].states[2*c+:2]!=0))
          $fatal(1,"EMBEDDING retained domain");
        if (d==1 && !active[c] && {obs[d].states[2*c+:2],obs[d].routes[2*c+:2],
            obs[d].owners[c],obs[d].routed[c],obs[d].changed[c]}!=='0)
          $fatal(1,"EMBEDDING inactive address %0d",c);
      end
    end
    if (compare_all) begin
      comparisons++;
      if (obs[0]!==project(obs[1])) $fatal(1,"EMBEDDING projection layout=%0d tick=%0d",layout,ticks);
    end
    checks++;
  endtask

  task automatic step(input bit en,input int new_mode,input bit equal_ports);
    sample_t old[2];
    trit_t a,b;
    tick_enable=en; scheduler_mode=frp_m31_scheduler_mode_e'(new_mode);
    #1; inspect(equal_ports); old=obs; clk=1; #1;
    if (en) ticks++; else pauses++;
    for (int d=0;d<2;d++) for (int c=0;c<CELLS;c++) begin
      a=old[d].states[2*c+:2]; b=obs[d].states[2*c+:2];
      if ((a!=b)!=old[d].changed[c] || (a!=0 && b!=0 && a!=b) ||
          (!en && old[d].routes[2*c+:2]!=obs[d].routes[2*c+:2]))
        $fatal(1,"EMBEDDING writeback core=%0d cell=%0d",d,c);
    end
    signature=(signature^64'(old[0].changed))*64'h100000001b3;
    clk=0; #1;
  endtask

  task automatic batch(input int base,input bit opposite);
    request_valid='0; addr='0; request_target='0;
    for (int k=0;k<L;k++) if (base+k<S) begin
      addr[k*B+:B]=B'(base+k); request_valid[k]=1;
      request_target[2*k+:2]=sign_for(base+k)^(opposite?2'b10:2'b00);
    end
  endtask

  task automatic episode();
    int used,n,gap,a;
    bit eligible;
    logic [CELLS-1:0] want[2];
    sample_t projected;
    ticks=0; active='0;
    for (int c=0;c<S;c++) begin
      case (layout)
        0:a=c;
        1:a=CELLS-S+c;
        2:a=(c*(CELLS-1))/(S-1);
        default:a=((S-1-c)*(CELLS-1))/(S-1);
      endcase
      if (active[a]) $fatal(1,"Non-injective address map");
      physical[c]=a; active[a]=1;
    end
    request_valid=0; addr=0; request_target=0; goals=0; tick_enable=0; clear_counters=0;
    scheduler_mode=FRP_MODE_FREE; rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1; #1;
    for (int base=0;base<S;base+=L) begin batch(base,0); step(1,0,1); end
    request_valid=0;
    while (ticks%8!=0) step(1,0,1);
    step(0,1,1);
    for (int base=0;base<S;base+=L) begin batch(base,1); step(1,1,1); end
    request_valid=0;
    while (ticks%8!=7) step(1,1,1);
    for (int c=0;c<S;c++)
      if (obs[0].routes[2*c+:2]!=(sign_for(c)^2'b10) ||
          obs[1].routes[2*physical[c]+:2]!=(sign_for(c)^2'b10))
        $fatal(1,"EMBEDDING pending batch not formed");
    backlogs++;
    step(0,mode_id,1); used=0; gap=0;
    while (used<S && gap<8*((S+L-1)/L)) begin
      tick_enable=1; #1;
      eligible=(mode_id==0) || ((mode_id==1)?ticks%8==7:ticks%8==0);
      n=eligible?((S-used<L)?S-used:L):0;
      want[0]='0; want[1]='0;
      for (int j=used;j<used+n;j++) begin
        want[0][j]=1; want[1][physical[(layout==3)?S-1-j:j]]=1;
      end
      if (obs[0].changed!==want[0] || obs[1].changed!==want[1])
        $fatal(1,"EMBEDDING service rank layout=%0d tick=%0d",layout,ticks);
      projected=project(obs[1]);
      if (projected.changed!=obs[0].changed) split_grants++;
      if (n!=0) ranked_edges++;
      step(1,mode_id,layout!=3); used+=n; gap++;
    end
    if (used!=S || obs[0].routes!='0 || obs[1].routes!='0)
      $fatal(1,"EMBEDDING incomplete service");
    inspect(1);
    if (layout!=3) for (int s=0;s<128;s++) begin
      for (int c=0;c<S;c++) goals[2*c+:2]=sign_for(c+s);
      for (int k=0;k<L;k++) begin
        a=(s%4==0)?s%S:int'(rnd()%S); addr[k*B+:B]=B'(a);
        request_valid[k]=s%4==0 || rnd()%5!=0;
        request_target[2*k+:2]=(s%4==0)?((k%2)?1:3):
                                      ((rnd()%3==0)?0:sign_for(a+s));
      end
      if (s%4==0 && L>1) conflicts++;
      clear_counters=(s%31==5);
      if (s%6==2) step(0,mode_id,1);
      step(1,mode_id,1);
    end
    inspect(1);
  endtask

  initial begin
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    rng=seed^32'h91e10da5; if (rng==0) rng=1;
    #1;
    for (layout=0;layout<4;layout++) for (mode_id=0;mode_id<3;mode_id++) episode();
    if (backlogs!=12 || split_grants==0 || ranked_edges==0 || comparisons==0 ||
        (L>1 && conflicts==0)) $fatal(1,"EMBEDDING missing activity");
    $display("PASS EXECUTION_EMBEDDING cells=%0d small=%0d lanes=%0d seed=%0d backlogs=%0d checks=%0d comparisons=%0d pauses=%0d ranked_edges=%0d split_grants=%0d conflicts=%0d signature=%h",
      CELLS,S,L,seed,backlogs,checks,comparisons,pauses,ranked_edges,split_grants,conflicts,signature);
    $finish;
  end
endmodule

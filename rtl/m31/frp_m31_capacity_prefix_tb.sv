// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Compare adjacent transition budgets on an identical candidate batch.
// The extra request port of the larger guard stays inactive. Pending changes
// rank by cell address, then explicit changes by lane; retention costs zero.
// Profiles: CELLS=8,9,16,32,64. Runtime: +SEED=0 or +SEED=76.
`timescale 1ns/1ps
`include "frp_m31_capacity_guard.sv"

module frp_m31_capacity_prefix_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
  typedef struct packed {
    logic [L:0] take,deny;
    logic [CELLS-1:0] accept_cells,reject_cells,changed;
    logic [31:0] count,remaining,load,candidates,accepts,rejects,exhaustions,events;
    logic exhausted;
    logic [9:0] flags;
  } result_t;
  logic tick_enable;
  logic [L-1:0] valid,holds;
  logic [L*B-1:0] addr;
  logic [L*4-1:0] kind;
  logic [CELLS-1:0] pending,routed;
  logic [2*CELLS-1:0] before_state,after_state;
  wire result_t got[2];
  int unsigned seed=76,rng;
  int batches=0,checks=0,extra=0,extra_pending=0,extra_lane=0;
  int saturated_holds=0,zero_holds=0,collisions=0,spare_collisions=0,neutral_grants=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  for (genvar d=0;d<2;d++) begin : g_guard
    localparam int K=L+d;
    wire [K-1:0] take,deny;
    assign got[d].take=(L+1)'(take);
    assign got[d].deny=(L+1)'(deny);
    frp_m31_capacity_guard #(.CELLS(CELLS),.REQUEST_LANES(K),.COUNTER_BITS(32)) dut (
      .tick_enable,.scheduler_state(FRP_SCHED_FREE),.request_accept_candidate(K'(valid)),
      .request_cell_index((K*B)'(addr)),.transition_class((K*4)'(kind)),
      .pending_completion_candidate(pending),.neutral_routed_candidate(routed),
      .state_q(before_state),.state_candidate_d(after_state),
      .request_accept_capacity(take),.request_reject_capacity(deny),
      .capacity_accept_mask(got[d].accept_cells),.capacity_reject_mask(got[d].reject_cells),
      .accepted_change_mask(got[d].changed),.accepted_changes(got[d].count),
      .capacity_remaining(got[d].remaining),.capacity_exhausted(got[d].exhausted),
      .switch_load_numerator(got[d].load),.capacity_candidate_events(got[d].candidates),
      .capacity_accept_events(got[d].accepts),.capacity_reject_events(got[d].rejects),
      .capacity_exhausted_events(got[d].exhaustions),.accepted_change_events(got[d].events),
      .transition_capacity_valid(got[d].flags[9]),.accepted_changes_within_limit(got[d].flags[8]),
      .capacity_remaining_valid(got[d].flags[7]),.capacity_exhaustion_valid(got[d].flags[6]),
      .same_state_capacity_valid(got[d].flags[5]),.pending_capacity_valid(got[d].flags[4]),
      .active_neutral_capacity_valid(got[d].flags[3]),.switch_load_bound_valid(got[d].flags[2]),
      .no_queue_overflow(got[d].flags[1]),.no_actual_direct_events(got[d].flags[0])
    );
  end

  function automatic int unsigned rnd();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction

  function automatic result_t expected(input int budget);
    result_t r;
    int rank_id,a;
    r='0; r.flags='1; r.remaining=budget;
    if (!tick_enable) return r;
    for (int c=0;c<CELLS;c++) if (pending[c]) begin
      rank_id=0;
      for (int j=0;j<c;j++) rank_id+=int'(pending[j]);
      if (rank_id<budget) r.changed[c]=1;
      else begin r.reject_cells[c]=1; r.rejects++; end
    end
    r.candidates=$countones(pending);
    for (int k=0;k<L;k++) if (valid[k]) begin
      a=int'(addr[k*B+:B]);
      if (!pending[a]) begin
        if (holds[k]) r.take[k]=1;
        else begin
          // Rank counts the entire pending set plus earlier eligible changes.
          rank_id=$countones(pending);
          for (int j=0;j<k;j++)
            if (valid[j] && !holds[j] && !pending[addr[j*B+:B]]) rank_id++;
          r.candidates++;
          if (rank_id<budget) begin r.take[k]=1; r.changed[a]=1; end
        end
      end
      if (r.take[k]) r.accept_cells[a]=1;
      else begin r.deny[k]=1; r.reject_cells[a]=1; r.rejects++; end
    end
    r.accept_cells|=r.changed;
    r.count=$countones(r.changed); r.remaining=budget-r.count;
    r.load=r.count; r.accepts=r.count; r.events=r.count;
    r.exhausted=(r.remaining==0); r.exhaustions=int'(r.exhausted);
    return r;
  endfunction

  task automatic inspect(input string phase);
    result_t want;
    #1;
    for (int d=0;d<2;d++) begin
      want=expected(L+d); checks++;
      if (got[d]!==want)
        $fatal(1,"CAPACITY_PREFIX %s cells=%0d batch=%0d budget=%0d got=%h want=%h",
               phase,CELLS,batches,L+d,got[d],want);
    end
  endtask

  task automatic trial();
    result_t saved[2];
    logic [L-1:0] original;
    logic [CELLS-1:0] added;
    original=valid; tick_enable=1; inspect("rank");
    for (int d=0;d<2;d++) saved[d]=got[d];
    added=saved[1].changed & ~saved[0].changed;
    if (|(saved[0].changed & ~saved[1].changed) ||
        $countones(added)!=int'(saved[0].candidates>L))
      $fatal(1,"CAPACITY_PREFIX adjacent budget displaced a grant");
    if (|added) begin
      extra++; if (|(added & pending)) extra_pending++; else extra_lane++;
    end
    for (int k=0;k<L;k++) if (valid[k]) begin
      if (pending[addr[k*B+:B]]) begin
        collisions++; if (saved[1].remaining!=0) spare_collisions++;
      end
      if (saved[0].take[k] && holds[k] && saved[0].exhausted) saturated_holds++;
      if (saved[0].take[k] && holds[k] && before_state[2*int'(addr[k*B+:B])+:2]==0) zero_holds++;
    end
    neutral_grants+=$countones(saved[0].changed & routed);
    valid=original & ~holds; inspect("remove_holds");
    for (int d=0;d<2;d++)
      if (got[d].changed!==saved[d].changed || got[d].remaining!==saved[d].remaining)
        $fatal(1,"CAPACITY_PREFIX retention consumed a slot");
    tick_enable=0; valid=original; inspect("disabled");
    tick_enable=1; inspect("restored");
    for (int d=0;d<2;d++) begin
      if (got[d]!==saved[d]) $fatal(1,"CAPACITY_PREFIX replay mismatch");
      signature=(signature^64'(saved[d].changed))*64'h100000001b3;
      signature=(signature^64'(saved[d].take))*64'h100000001b3;
      signature=(signature^64'(saved[d].reject_cells))*64'h100000001b3;
    end
    batches++;
  endtask

  task automatic batch(input int pressure,offset,style);
    int a,code;
    logic [1:0] polarity;
    before_state='0; after_state='0; routed='0; pending='0;
    addr='0; kind='0; valid='0; holds='0;
    for (int j=0;j<pressure;j++) begin
      a=(offset+j)%CELLS; pending[a]=1; after_state[2*a+:2]=rnd()%2?1:3;
    end
    for (int k=0;k<L;k++) begin
      a=(style==3)?(offset+k)%CELLS:(offset+CELLS-1-k)%CELLS; addr[k*B+:B]=B'(a);
      valid[k]=(style!=2 || rnd()%4!=0);
      code=(style==0)?k%4:((style==1)?0:int'(rnd()%4));
      polarity=rnd()%2?1:3;
      if (pending[a]) kind[k*4+:4]=1;
      else begin
        kind[k*4+:4]=4'(code);
        case (code)
          0: begin holds[k]=1; before_state[2*a+:2]=(k%2)?polarity:0;
                   after_state[2*a+:2]=before_state[2*a+:2]; end
          1: after_state[2*a+:2]=polarity;
          2: before_state[2*a+:2]=polarity;
          3: begin before_state[2*a+:2]=polarity; routed[a]=1; end
        endcase
      end
    end
    trial();
  endtask

  initial begin : run
    int p,o;
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    rng=seed^32'hc2b2ae35; if (rng==0) rng=1;
    for (p=0;p<=CELLS;p++) for (o=0;o<CELLS;o++) begin
      batch(p,o,0); batch(p,o,1);
    end
    // A lane targeting a pending owner is rejected even with a spare slot.
    for (o=0;o<CELLS;o++) batch(1,o,3);
    for (int j=0;j<512;j++) begin
      p=int'(rnd()%(CELLS+1)); o=int'(rnd()%CELLS); batch(p,o,2);
    end
    if (batches!=2*CELLS*(CELLS+1)+CELLS+512 || checks!=8*batches ||
        !(extra_pending && extra_lane && saturated_holds && zero_holds && spare_collisions && neutral_grants))
      $fatal(1,"CAPACITY_PREFIX missing event");
    $display("PASS CAPACITY_PREFIX cells=%0d lanes=%0d seed=%0d batches=%0d checks=%0d extra=%0d extra_pending=%0d extra_lane=%0d saturated_holds=%0d zero_holds=%0d collisions=%0d spare_collisions=%0d neutral_grants=%0d signature=%h",
      CELLS,L,seed,batches,checks,extra,extra_pending,extra_lane,saturated_holds,
      zero_holds,collisions,spare_collisions,neutral_grants,signature);
    $finish;
  end
endmodule

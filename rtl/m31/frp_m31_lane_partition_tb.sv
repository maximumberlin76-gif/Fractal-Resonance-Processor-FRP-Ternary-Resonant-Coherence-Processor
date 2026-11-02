// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Per-address arbitration: independent winner election, disjoint batch union,
// stable lane permutation and exact replay. Exercises the request-stage ports.
// Profiles: CELLS=8,9,16,32,64; runtime +SEED=0 or +SEED=76.
`timescale 1ns/1ps
`include "frp_m31_request_lanes.sv"

module frp_m31_lane_partition_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
  typedef logic [B-1:0] addr_t;
  typedef logic [1:0] trit_t;
  typedef struct packed {
    logic [L-1:0] take,deny,index_err,target_err,duplicate,gate,capacity,busy,paused,via_zero;
    logic [CELLS-1:0] owned,refused,routed,direct_req;
    logic [31:0] changes,asked,taken,rejected,opposite,prevented,neutral;
    logic [8:0] flags;
  } result_t;
  logic tick_enable;
  frp_m31_scheduler_state_e scheduler_state;
  logic [L-1:0] request_valid;
  logic [L*B-1:0] request_cell_index;
  logic [2*L-1:0] request_target;
  logic [2*CELLS-1:0] state_q,target_q,pending_route_q;
  wire result_t got;
  int vectors=0, comparisons=0, split_accepts=0, moved_valid=0, fallback=0;
  int duplicates=0, busy=0, gates=0, invalid_targets=0, paused=0, routes=0, zero_owners=0;
  logic [(1<<B)-1:0] bad_addresses='0;
  int unsigned seed=76, rng;
  logic [63:0] signature=64'hcbf29ce484222325;

  frp_m31_request_lanes #(.CELLS(CELLS),.COUNTER_BITS(32)) dut (
    .tick_enable,.scheduler_state,.request_valid,.request_cell_index,.request_target,
    .state_q,.target_q,.pending_route_q,
    .request_accept(got.take),.request_reject(got.deny),
    .request_reject_invalid_cell(got.index_err),.request_reject_invalid_target(got.target_err),
    .request_reject_duplicate_cell(got.duplicate),.request_reject_scheduler(got.gate),
    .request_reject_capacity(got.capacity),.request_reject_pending_busy(got.busy),
    .request_reject_tick_disabled(got.paused),.request_neutralized(got.via_zero),
    .accepted_cell_mask(got.owned),.rejected_cell_mask(got.refused),
    .neutral_routed_cell_mask(got.routed),.requested_direct_cell_mask(got.direct_req),
    .accepted_changes(got.changes),.requested_lane_events(got.asked),
    .accepted_lane_events(got.taken),.rejected_lane_events(got.rejected),
    .requested_direct_events(got.opposite),.prevented_direct_events(got.prevented),
    .neutral_routed_events(got.neutral),.request_lane_order_valid(got.flags[8]),
    .request_cell_domain_valid(got.flags[7]),.request_target_domain_valid(got.flags[6]),
    .duplicate_cell_guard_valid(got.flags[5]),.scheduler_gate_valid(got.flags[4]),
    .transition_capacity_valid(got.flags[3]),.active_neutral_routing_valid(got.flags[2]),
    .no_actual_direct_events(got.flags[1]),.no_queue_overflow(got.flags[0])
  );

  function automatic int unsigned rnd();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction

  function automatic trit_t legal(input int unsigned v);
    case (v%3) 0:return 0; 1:return 1; default:return 3; endcase
  endfunction

  function automatic bit allowed(input trit_t old_value, goal, input int s);
    if (s>4 || goal==2) return 0;
    if (old_value==goal || s==0) return 1;
    if (old_value==0) return s==2 || s==3;
    return s==1 || s==4;
  endfunction

  function automatic result_t predict();
    result_t r;
    int first[CELLS],a;
    trit_t h,t;
    r='0; r.flags='1;
    // Elect the lowest eligible lane for each cell without using DUT helpers.
    for (int c=0;c<CELLS;c++) begin
      first[c]=L;
      for (int k=L-1;k>=0;k--)
        if (request_valid[k] && int'(request_cell_index[k*B+:B])==c &&
            pending_route_q[2*c+:2]==0 &&
            allowed(state_q[2*c+:2],request_target[2*k+:2],int'(scheduler_state))) first[c]=k;
    end
    for (int k=0;k<L;k++) if (request_valid[k]) begin
      a=int'(request_cell_index[k*B+:B]); t=request_target[2*k+:2];
      if (!tick_enable) r.paused[k]=1;
      else if (a>=CELLS) begin r.deny[k]=1; r.index_err[k]=1; r.flags[7]=0; end
      else begin
        h=state_q[2*a+:2];
        if (t==2) begin r.target_err[k]=1; r.flags[6]=0; end
        else if (first[a]<k) r.duplicate[k]=1;
        else if (pending_route_q[2*a+:2]!=0) r.busy[k]=1;
        else if (first[a]!=k) r.gate[k]=1;
        else begin
          r.take[k]=1; r.owned[a]=1;
          if (h!=t) r.changes++;
          if (h!=0 && t!=0 && h!=t) begin
            r.via_zero[k]=1; r.direct_req[a]=1; r.routed[a]=1;
          end
        end
        if (!r.take[k]) begin r.deny[k]=1; r.refused[a]=1; end
      end
    end
    r.taken=$countones(r.take); r.rejected=$countones(r.deny);
    r.asked=r.taken+r.rejected; r.opposite=$countones(r.via_zero);
    r.prevented=r.opposite; r.neutral=r.opposite;
    return r;
  endfunction

  task automatic compare(input string label_text,input result_t expected);
    comparisons++;
    if (got!==expected)
      $fatal(1,"LANE_PARTITION %s cells=%0d vector=%0d got=%h expected=%h",
        label_text,CELLS,vectors,got,expected);
  endtask

  function automatic result_t combine(input result_t a,b);
    result_t r;
    r=a|b; r.flags=a.flags&b.flags;
    r.changes=a.changes+b.changes; r.asked=a.asked+b.asked;
    r.taken=a.taken+b.taken; r.rejected=a.rejected+b.rejected;
    r.opposite=a.opposite+b.opposite; r.prevented=a.prevented+b.prevented;
    r.neutral=a.neutral+b.neutral;
    return r;
  endfunction

  task automatic trial();
    logic [L-1:0] valid0,part;
    logic [L*B-1:0] index0;
    logic [2*L-1:0] target0;
    result_t whole,left,right,remapped;
    int src,dst,a;
    #1; compare("winner",predict()); whole=got;
    valid0=request_valid; index0=request_cell_index; target0=request_target;
    part='0;
    for (int k=0;k<L;k++) begin
      a=int'(index0[k*B+:B]); part[k]=a[(vectors%B)];
      if (whole.index_err[k]) bad_addresses[a]=1;
      if (whole.take[k] && state_q[2*a+:2]==0 && target0[2*k+:2]==0) zero_owners++;
      if (whole.take[k])
        for (int j=0;j<k;j++) if (index0[j*B+:B]==a && whole.deny[j]) fallback++;
    end
    duplicates+=$countones(whole.duplicate); busy+=$countones(whole.busy);
    gates+=$countones(whole.gate); invalid_targets+=$countones(whole.target_err);
    paused+=$countones(whole.paused); routes+=$countones(whole.via_zero);
    request_valid=valid0 & part; #1; left=got;
    request_valid=valid0 & ~part; #1; right=got;
    if (left.taken && right.taken) split_accepts++;
    request_valid=valid0; #1; compare("partition_union",combine(left,right));

    // Stable partition: requests to the same address keep their relative order.
    dst=0; remapped=whole;
    for (int group_id=1;group_id>=0;group_id--) begin
      for (src=0;src<L;src++) if (int'(part[src])==group_id) begin
        request_valid[dst]=valid0[src]; request_cell_index[dst*B+:B]=index0[src*B+:B];
        request_target[2*dst+:2]=target0[2*src+:2];
        {remapped.take[dst],remapped.deny[dst],remapped.index_err[dst],remapped.target_err[dst],
         remapped.duplicate[dst],remapped.gate[dst],remapped.capacity[dst],remapped.busy[dst],
         remapped.paused[dst],remapped.via_zero[dst]}=
        {whole.take[src],whole.deny[src],whole.index_err[src],whole.target_err[src],
         whole.duplicate[src],whole.gate[src],whole.capacity[src],whole.busy[src],
         whole.paused[src],whole.via_zero[src]};
        if (src!=dst && valid0[src]) moved_valid++;
        dst++;
      end
    end
    #1; compare("stable_permutation",remapped);
    request_valid=valid0; request_cell_index=index0; request_target=target0;
    #1; compare("restored",whole);
    for (int k=0;k<L;k++)
      signature=(signature^{54'b0,whole.take[k],whole.deny[k],whole.index_err[k],
        whole.target_err[k],whole.duplicate[k],whole.gate[k],whole.capacity[k],whole.busy[k],
        whole.paused[k],whole.via_zero[k]})*64'h100000001b3;
    vectors++;
  endtask

  initial begin : run
    int a;
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    rng=seed^32'h9e3779b9; if (!rng) rng=1;
    // Five legal histories: empty zero, both pending polarities at zero,
    // and both retained polarities without pending ownership.
    for (int hist=0;hist<5;hist++) for (int t0=0;t0<4;t0++) for (int t1=0;t1<4;t1++)
      for (int s=0;s<8;s++) for (int tick=0;tick<2;tick++) begin
        a=vectors%CELLS; state_q='0; pending_route_q='0; target_q='0;
        if (hist==1 || hist==2) pending_route_q[2*a+:2]=(hist==1)?1:3;
        if (hist==3 || hist==4) state_q[2*a+:2]=(hist==3)?1:3;
        scheduler_state=frp_m31_scheduler_state_e'(s); tick_enable=1'(tick);
        request_valid='0; request_valid[0]=1; request_valid[L-1]=1;
        request_cell_index={L{addr_t'(a)}}; request_target='0;
        request_target[0+:2]=trit_t'(t0); request_target[2*(L-1)+:2]=trit_t'(t1);
        trial();
      end
    for (int n=0;n<2048;n++) begin
      scheduler_state=frp_m31_scheduler_state_e'(n%8); tick_enable=(n%11!=0);
      for (int c=0;c<CELLS;c++) begin
        state_q[2*c+:2]=legal(rnd()); target_q[2*c+:2]=legal(rnd());
        pending_route_q[2*c+:2]=(state_q[2*c+:2]==0 && rnd()%3==0)?legal(rnd()):0;
      end
      for (int k=0;k<L;k++) begin
        request_valid[k]=(rnd()%4!=0); request_target[2*k+:2]=trit_t'(rnd());
        case (n%3)
          0: a=(n+k)%CELLS;
          1: a=(n+k%2)%CELLS;
          default: a=int'(rnd()%(1<<B));
        endcase
        request_cell_index[k*B+:B]=addr_t'(a);
      end
      trial();
    end
    // Walk every representable out-of-range index with competing valid work.
    for (int addr=CELLS;addr<(1<<B);addr++) begin
      tick_enable=1; scheduler_state=FRP_SCHED_FREE;
      state_q='0; pending_route_q='0; target_q='0;
      request_valid='1; request_target='0; request_cell_index='0;
      request_cell_index[0+:B]=addr_t'(addr); trial();
      if (!bad_addresses[addr]) $fatal(1,"Missing rejected address %0d",addr);
    end
    if (vectors!=3328+(1<<B)-CELLS || comparisons!=4*vectors ||
        !(duplicates && busy && gates && invalid_targets && paused && routes && zero_owners &&
          fallback && split_accepts && moved_valid)) $fatal(1,"Incomplete arbitration coverage");
    $display("PASS LANE_PARTITION cells=%0d lanes=%0d seed=%0d vectors=%0d comparisons=%0d invalid_addresses=%0d split_accepts=%0d moved_valid=%0d fallback=%0d duplicates=%0d busy=%0d gates=%0d invalid_targets=%0d paused=%0d routes=%0d zero_owners=%0d signature=%h",
      CELLS,L,seed,vectors,comparisons,$countones(bad_addresses),split_accepts,moved_valid,
      fallback,duplicates,busy,gates,invalid_targets,paused,routes,zero_owners,signature);
    $finish;
  end
endmodule

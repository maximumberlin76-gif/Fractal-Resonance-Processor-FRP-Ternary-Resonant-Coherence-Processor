// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Replay the execution core with address-local polarity exchanges. States
// and saved destinations transform; admissions, capacity, counters and cadence
// must match the baseline at the same edges. Only public ports are sampled.
// Build with --timing --assert -Irtl/m31 and -GCELLS=8 (9/16/32/64).
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_polarity_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
  localparam int DIRECTED=32*((CELLS+L-1)/L), STEPS=DIRECTED+96+8;
  typedef logic [1:0] trit_t;
  typedef struct packed {
    logic [2*CELLS-1:0] state_word,route;
    logic [L-1:0] take,deny;
    logic [CELLS-1:0] accepted,routed,changed;
    logic [31:0] changes,remaining,load,ticks,requested,prevented,via_zero,illegal,reserved,overflow;
    logic [4:0][31:0] visits;
    logic exhausted;
    frp_m31_scheduler_mode_e mode;
    frp_m31_scheduler_state_e sched;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] flags;
  } sample_t;
  logic clk=0,rst_n=1,tick_enable=0,clear_counters=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE;
  logic [L-1:0] request_valid='0;
  logic [L*B-1:0] request_cell_index='0;
  logic [2*L-1:0] request_target,base_goal='0;
  logic [2*CELLS-1:0] target_q,base_target='0;
  logic [CELLS-1:0] flip='0,created[2],served[2];
  wire sample_t obs;
  sample_t reference_trace[4*STEPS+4];
  int unsigned seed=76;
  int tag,mode_id,tick,slot,checks=0,epochs=0,comparisons=0;
  int pauses=0,pending_holds=0,disagreements=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic trit_t reflect(input trit_t x,input bit invert);
    if (invert && (x==1 || x==3)) return x^2'b10;
    return x;
  endfunction
  always_comb begin
    for (int c=0;c<CELLS;c++) target_q[2*c+:2]=reflect(base_target[2*c+:2],flip[c]);
    for (int k=0;k<L;k++)
      request_target[2*k+:2]=reflect(base_goal[2*k+:2],flip[request_cell_index[k*B+:B]]);
  end
  frp_m31_execution_core #(.CELLS(CELLS),.REQUEST_LANES(L),.COUNTER_BITS(32)) dut (
    .clk,.rst_n,.tick_enable,.clear_counters,.scheduler_mode,.request_valid,
    .request_cell_index,.request_target,.target_q,.state_out(obs.state_word),.pending_route_out(obs.route),
    .scheduler_mode_q(obs.mode),.scheduler_state_q(obs.sched),.ticks_recorded_q(obs.ticks),
    .scheduler_count_free_q(obs.visits[0]),.scheduler_count_balance_q(obs.visits[1]),
    .scheduler_count_commit_q(obs.visits[2]),.scheduler_count_excite_q(obs.visits[3]),
    .scheduler_count_neutralize_q(obs.visits[4]),.request_accept(obs.take),.request_reject(obs.deny),
    .accepted_cell_mask(obs.accepted),.neutral_routed_cell_mask(obs.routed),.accepted_change_mask(obs.changed),
    .accepted_changes(obs.changes),.capacity_remaining(obs.remaining),.capacity_exhausted(obs.exhausted),
    .switch_load_numerator(obs.load),.requested_direct_events(obs.requested),.prevented_direct_events(obs.prevented),
    .neutral_routed_events(obs.via_zero),.actual_direct_events(obs.illegal),.reserved_state_events(obs.reserved),
    .queue_overflow_events(obs.overflow),.invariant_flags(obs.flags)
  );

  function automatic int unsigned mix(input int unsigned x);
    x^=x>>16; x*=32'h85ebca6b; x^=x>>13; return x;
  endfunction
  function automatic int cadence();
    case (mode_id)
      0:return 0;
      1:return (tick%8==7)?2:1;
      default:return (tick%8==0)?3:4;
    endcase
  endfunction
  task automatic sample_ports();
    sample_t canon;
    canon=obs;
    if (obs.flags!=='1 || {obs.illegal,obs.reserved,obs.overflow}!=='0 ||
        int'(obs.mode)!=mode_id || int'(obs.sched)!=cadence())
      $fatal(1,"POLARITY cadence/invariants mode=%0d tick=%0d",mode_id,tick);
    for (int c=0;c<CELLS;c++) begin
      if (obs.state_word[2*c+:2]==2 || obs.route[2*c+:2]==2 ||
          (obs.route[2*c+:2]!=0 && obs.state_word[2*c+:2]!=0))
        $fatal(1,"POLARITY retained domain cell=%0d",c);
      canon.state_word[2*c+:2]=reflect(obs.state_word[2*c+:2],flip[c]);
      canon.route[2*c+:2]=reflect(obs.route[2*c+:2],flip[c]);
    end
    if (tag<0) begin
      reference_trace[slot]=canon;
      for (int c=0;c<CELLS;c++) signature=(signature^{60'b0,canon.state_word[2*c+:2],
                                                canon.route[2*c+:2]})*64'h100000001b3;
    end else begin
      comparisons++;
      if (canon!==reference_trace[slot])
        $fatal(1,"POLARITY trace mismatch mode=%0d mask=%h sample=%0d",mode_id,flip,slot);
    end
    checks++; slot++;
  endtask

  task automatic edge_check(input bit enabled);
    sample_t old;
    trit_t h,n,p,q;
    tick_enable=enabled; #1; sample_ports(); old=obs;
    clk=1; #1; if (enabled) tick++;
    sample_ports();
    for (int c=0;c<CELLS;c++) begin
      h=old.state_word[2*c+:2]; n=obs.state_word[2*c+:2];
      p=old.route[2*c+:2]; q=obs.route[2*c+:2];
      if ((h!=0 && n!=0 && h!=n) || (h!=n)!=old.changed[c] ||
          (!enabled && (p!=q || h!=n))) $fatal(1,"POLARITY writeback cell=%0d",c);
      if (p!=0) begin
        if (q!=0 && q!=p) $fatal(1,"POLARITY overwritten route");
        if (q==0) begin
          if (n!=p) $fatal(1,"POLARITY wrong completion");
          served[p==3][c]=1;
        end else if (!enabled) pending_holds++;
      end else if (q!=0) begin
        if (h==0 || n!=0 || h==q) $fatal(1,"POLARITY wrong first leg");
        created[q==3][c]=1;
      end
    end
    if (!enabled) pauses++;
    clk=0; #1;
  endtask

  task automatic drive(input int s);
    int a,grp;
    int unsigned word_value;
    trit_t sign_value,goal;
    request_valid='0; request_cell_index='0; base_goal='0;
    for (int c=0;c<CELLS;c++) base_target[2*c+:2]=((s+c)%2)?1:3;
    for (int k=0;k<L;k++) begin
      word_value=mix(seed^(32'(s+1)*32'h9e3779b9)^32'(k));
      if (s<DIRECTED) begin
        grp=s/32; a=grp*L+k;
        if (a>=CELLS) continue;
        sign_value=(a%2)?3:1;
        case ((s%32)/8)
          0,2:goal=sign_value;
          1:goal=reflect(sign_value,1);
          default:goal=0;
        endcase
        request_valid[k]=1;
      end else begin
        a=(s%3==0)?s%CELLS:int'(word_value%CELLS);
        case ((word_value>>8)%3) 0:goal=0; 1:goal=1; default:goal=3; endcase
        request_valid[k]=(s<STEPS-8) && word_value[3];
      end
      request_cell_index[k*B+:B]=B'(a); base_goal[2*k+:2]=goal;
    end
    if (s>=DIRECTED && s<STEPS-8)
      for (int j=1;j<L;j++) if (request_valid[j] && request_valid[0] &&
          request_cell_index[j*B+:B]==request_cell_index[0+:B] &&
          base_goal[2*j+:2]!=base_goal[0+:2]) disagreements++;
  endtask

  initial begin : run
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    #1;
    for (mode_id=0;mode_id<3;mode_id++) for (tag=-1;tag<=CELLS+2;tag++) begin
      flip='0;
      if (tag>=0 && tag<CELLS) flip[tag]=1;
      if (tag==CELLS) flip='1;
      if (tag==CELLS+1) for (int c=0;c<CELLS;c++) flip[c]=1'(c);
      tick=0; slot=0; request_valid=0; tick_enable=0; clear_counters=0;
      scheduler_mode=frp_m31_scheduler_mode_e'(mode_id);
      rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1; #1;
      if ({obs.state_word,obs.route}!=='0) $fatal(1,"POLARITY reset history");
      clk=1; #1; clk=0; #1;
      for (int j=0;j<2;j++) begin created[j]='0; served[j]='0; end
      for (int s=0;s<STEPS;s++) begin
        drive(s); clear_counters=(s%43==17);
        if (s%7==2 || s%8==1) edge_check(0);
        edge_check(1);
        if (s==DIRECTED-1 && (created[0]!=='1 || created[1]!=='1 ||
            served[0]!=='1 || served[1]!=='1)) $fatal(1,"POLARITY incomplete directed routes");
      end
      if (obs.route!=='0 || tick!=STEPS) $fatal(1,"POLARITY final drain");
      epochs++;
    end
    if (epochs!=3*(CELLS+4) || !(comparisons && pending_holds && disagreements))
      $fatal(1,"POLARITY missing activity");
    $display("PASS EXECUTION_POLARITY cells=%0d lanes=%0d seed=%0d epochs=%0d checks=%0d comparisons=%0d pauses=%0d pending_holds=%0d disagreements=%0d signature=%h",
      CELLS,L,seed,epochs,checks,comparisons,pauses,pending_holds,disagreements,signature);
    $finish;
  end
endmodule

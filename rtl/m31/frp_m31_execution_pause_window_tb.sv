// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Execution-core quiet-window equivalence: a burst of disabled clock edges
// is summarized by its final scheduler mode and the OR of its counter clears.
// Compare full public traces at the next eight enabled ticks, with live pending
// routes and conflicting requests. Profiles: 8,9,16,32,64; +SEED=0 or 76.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_pause_window_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
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
  logic [2*L-1:0] request_target='0;
  logic [2*CELLS-1:0] target_q='0;
  wire sample_t obs;
  sample_t gold[16];
  int ref_mode,ticks,recorded,visits[5],case_id=0,pass_id;
  int unsigned seed=76;
  int epochs=0,checks=0,trace_checks=0,quiet_edges=0,busy_lanes=0;
  int cleared_pending=0,noise_conflicts=0,immediate=0,deferred=0;
  logic [63:0] signature=64'hcbf29ce484222325;

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

  function automatic int cadence(input int mode_id,n);
    case (mode_id)
      0:return 0;
      1:return (n%8==7)?2:1;
      default:return (n%8==0)?3:4;
    endcase
  endfunction

  task automatic inspect();
    if (int'(obs.mode)!=ref_mode || int'(obs.sched)!=cadence(ref_mode,ticks))
      $fatal(1,"PAUSE_WINDOW cadence case=%0d tick=%0d",case_id,ticks);
    if (obs.ticks!==32'(recorded)) $fatal(1,"PAUSE_WINDOW tick counter");
    for (int j=0;j<5;j++)
      if (obs.visits[j]!==32'(visits[j])) $fatal(1,"PAUSE_WINDOW visit counter");
    if (obs.flags!=='1 || {obs.illegal,obs.reserved,obs.overflow}!=='0)
      $fatal(1,"PAUSE_WINDOW invariants");
    checks++;
  endtask

  task automatic pulse(input bit enabled,input int next_mode,input bit clear);
    sample_t old;
    int pre_cadence;
    trit_t a,b;
    tick_enable=enabled; clear_counters=clear;
    scheduler_mode=frp_m31_scheduler_mode_e'(next_mode);
    #1; inspect(); old=obs; pre_cadence=cadence(ref_mode,ticks);
    if (!enabled && {obs.take,obs.deny,obs.changed,obs.changes,obs.load}!=='0)
      $fatal(1,"PAUSE_WINDOW disabled acknowledgement");
    clk=1; #1;
    if (clear) begin recorded=0; foreach (visits[j]) visits[j]=0; end
    if (enabled) begin recorded++; visits[pre_cadence]++; ticks++; end
    ref_mode=next_mode;
    if (!enabled && {old.state_word,old.route}!=={obs.state_word,obs.route})
      $fatal(1,"PAUSE_WINDOW disabled writeback");
    inspect();
    for (int c=0;c<CELLS;c++) begin
      a=old.state_word[2*c+:2]; b=obs.state_word[2*c+:2];
      if (b==2 || obs.route[2*c+:2]==2 || (obs.route[2*c+:2]!=0 && b!=0) ||
          (a!=0 && b!=0 && a!=b) || (a!=b)!=old.changed[c])
        $fatal(1,"PAUSE_WINDOW state transition cell=%0d",c);
    end
    clk=0; #1;
  endtask

  task automatic reset_core();
    tick_enable=0; clear_counters=0; scheduler_mode=FRP_MODE_FREE;
    request_valid=0; request_cell_index=0; request_target=0; target_q=0;
    rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1; #1;
    ticks=0; ref_mode=0; recorded=0; foreach (visits[j]) visits[j]=0;
    if ({obs.state_word,obs.route}!=='0) $fatal(1,"PAUSE_WINDOW reset");
    inspect();
  endtask

  task automatic point(input int index);
    if (pass_id==0) begin
      gold[index]=obs;
      signature=(signature^64'(obs.changed))*64'h100000001b3;
      for (int c=0;c<CELLS;c++) signature=(signature^{60'b0,obs.state_word[2*c+:2],
                                                  obs.route[2*c+:2]})*64'h100000001b3;
    end else begin
      trace_checks++;
      if (obs!==gold[index])
        $fatal(1,"PAUSE_WINDOW trace case=%0d pass=%0d sample=%0d",case_id,pass_id,index);
    end
  endtask

  task automatic episode(input int first,last,pos,input bit want_clear);
    int base,a,length,selected,clear_at;
    bit one_clear,done,can_commit;
    trit_t polarity;
    logic [2*CELLS-1:0] destinations;
    reset_core(); base=int'((seed+32'(case_id))%CELLS);
    repeat ((pos+6)%8) pulse(1,0,0);
    destinations='0; request_valid='1;
    for (int k=0;k<L;k++) begin
      a=(base+k)%CELLS; polarity=((a+case_id)%2)?1:3;
      request_cell_index[k*B+:B]=B'(a); request_target[2*k+:2]=polarity;
      destinations[2*a+:2]=polarity^2'b10;
    end
    pulse(1,0,0);
    for (int k=0;k<L;k++) request_target[2*k+:2]^=2'b10;
    pulse(1,first,0);
    if (ticks%8!=pos || obs.state_word!=='0 || obs.route!==destinations)
      $fatal(1,"PAUSE_WINDOW route setup");
    // Compact run: omit the quiet window if neither control needs changing.
    length=(pass_id==0)?int'(first!=last || want_clear):((pass_id==1)?4:9);
    clear_at=(length==0)?0:int'((seed+32'(case_id))%length);
    for (int j=0;j<length;j++) begin
      selected=(j==length-1)?last:(first+j+1)%3;
      one_clear=want_clear && (j==clear_at || (pass_id==2 && j==0));
      request_valid='1;
      for (int k=0;k<L;k++) begin
        request_cell_index[k*B+:B]=B'(base);
        request_target[2*k+:2]=((j+k)%2)?1:3;
      end
      for (int c=0;c<CELLS;c++) target_q[2*c+:2]=((c+j)%3==0)?0:((c+j)%2?1:3);
      pulse(0,selected,one_clear); quiet_edges++;
      if (request_valid[0] && request_valid[1] && request_cell_index[0+:B]==request_cell_index[B+:B]
          && request_target[0+:2]!=request_target[2+:2]) noise_conflicts++;
      if (one_clear && obs.route!=0) cleared_pending++;
    end
    done=0;
    for (int j=0;j<8;j++) begin
      target_q='0; request_valid=done?'0:'1;
      for (int k=0;k<L;k++) begin
        a=(base+k)%CELLS; request_cell_index[k*B+:B]=B'(a);
        request_target[2*k+:2]=destinations[2*a+:2]^2'b10;
      end
      tick_enable=1; clear_counters=0; scheduler_mode=frp_m31_scheduler_mode_e'(last);
      #1; point(2*j);
      can_commit=cadence(last,ticks) inside {0,2,3};
      if (!done) begin
        if (obs.take!=='0 || obs.deny!=='1 || obs.route!==destinations)
          $fatal(1,"PAUSE_WINDOW pending ownership");
        busy_lanes+=L;
        if (can_commit) begin
          if (j==0) immediate++; else deferred++;
          done=1;
        end
      end
      pulse(1,last,0); point(2*j+1);
      if (obs.state_word!==(done?destinations:'0) || obs.route!==(done?'0:destinations))
        $fatal(1,"PAUSE_WINDOW service phase case=%0d offset=%0d",case_id,j);
    end
    if (!done) $fatal(1,"PAUSE_WINDOW service deadline");
    epochs++;
  endtask

  initial begin
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    #1;
    for (int first=0;first<3;first++) for (int last=0;last<3;last++)
      for (int pos=0;pos<8;pos++) for (int clr=0;clr<2;clr++) begin
        for (pass_id=0;pass_id<3;pass_id++) episode(first,last,pos,bit'(clr));
        case_id++;
      end
    if (case_id!=144 || epochs!=432 || trace_checks!=4608 ||
        !(cleared_pending>0 && noise_conflicts>0 && immediate>0 && deferred>0))
      $fatal(1,"PAUSE_WINDOW missing coverage");
    $display("PASS EXECUTION_PAUSE_WINDOW cells=%0d lanes=%0d seed=%0d cases=%0d epochs=%0d checks=%0d trace_checks=%0d quiet_edges=%0d busy_lanes=%0d noise_conflicts=%0d cleared_pending=%0d immediate=%0d deferred=%0d signature=%h",
      CELLS,L,seed,case_id,epochs,checks,trace_checks,quiet_edges,busy_lanes,noise_conflicts,cleared_pending,
      immediate,deferred,signature);
    $finish;
  end
endmodule

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Exhaustive two-bit operand and scheduler-code boundaries at public ports.
// Independent truth tables check candidates, diagnostics, masks and counters.
// CELLS=8,9,16,32,64; +SEED=0 or +SEED=76 rotates cell and lane placement.
// Build: --binary --timing --assert --coverage-line -Irtl/m31
// --top-module frp_m31_transition_boundary_tb -GCELLS=9.
`timescale 1ns/1ps
`include "frp_m31_active_neutral.sv"
`include "frp_m31_capacity_guard.sv"

module frp_m31_transition_boundary_tb #(parameter int CELLS=9);
  import frp_m31_pkg::*;
  localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
  typedef struct packed {
    logic [2*CELLS-1:0] state_word;
    logic [CELLS-1:0] valid,same,release_mask,neutral,opposite,routed,
                       pending,direct,reserved,changed;
    logic [31:0] same_n,release_n,neutral_n,requested_n,prevented_n,
                 routed_n,pending_n,direct_n,reserved_n,changed_n;
    logic domain_ok,route_ok,pending_ok,reserved_ok,direct_ok,
          capacity_ok,output_ok,replay_ok;
  } active_t;
  typedef struct packed {
    logic [L-1:0] take,deny;
    logic [CELLS-1:0] accepted,rejected,changed;
    logic [31:0] count,remaining,load,candidates,accepts,rejects,exhaustions,events;
    logic exhausted;
    logic [9:0] flags;
  } guard_t;
  logic tick;
  frp_m31_scheduler_state_e scheduler;
  logic [2*CELLS-1:0] retained,pending_word,candidate;
  logic [L-1:0] request,neutralized;
  logic [L*B-1:0] addresses;
  logic [2*L-1:0] targets;
  logic [4*L-1:0] classes;
  logic [CELLS-1:0] completion,route;
  wire active_t a;
  wire guard_t g;
  int unsigned seed=76;
  int active_cases=0,guard_cases=0,invalid_addresses=0,duplicates=0,checks=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  frp_m31_active_neutral #(.CELLS(CELLS),.REQUEST_LANES(L)) active_dut (
    .tick_enable(tick),.scheduler_state(scheduler),.state_q(retained),
    .pending_route_q(pending_word),.request_accept(request),
    .request_neutralized(neutralized),.request_cell_index(addresses),
    .request_target(targets),.pending_completion_enable(completion),
    .state_candidate_d(a.state_word),.transition_valid_mask(a.valid),
    .same_state_mask(a.same),.zero_to_nonzero_mask(a.release_mask),
    .nonzero_to_zero_mask(a.neutral),.opposite_polarity_mask(a.opposite),
    .neutral_routed_mask(a.routed),.pending_completion_mask(a.pending),
    .actual_direct_mask(a.direct),.reserved_transition_mask(a.reserved),
    .accepted_change_candidate_mask(a.changed),.same_state_events(a.same_n),
    .zero_to_nonzero_events(a.release_n),.nonzero_to_zero_events(a.neutral_n),
    .requested_direct_events(a.requested_n),.prevented_direct_events(a.prevented_n),
    .neutral_routed_events(a.routed_n),.pending_completion_events(a.pending_n),
    .actual_direct_events(a.direct_n),.reserved_transition_events(a.reserved_n),
    .accepted_change_candidate_events(a.changed_n),.transition_domain_valid(a.domain_ok),
    .active_neutral_routing_valid(a.route_ok),.pending_completion_from_zero_valid(a.pending_ok),
    .no_reserved_transition(a.reserved_ok),.no_actual_direct_events(a.direct_ok),
    .transition_capacity_valid(a.capacity_ok),.state_output_domain_valid(a.output_ok),
    .transition_replay_deterministic(a.replay_ok)
  );
  frp_m31_capacity_guard #(.CELLS(CELLS),.REQUEST_LANES(L)) guard_dut (
    .tick_enable(tick),.scheduler_state(scheduler),.request_accept_candidate(request),
    .request_cell_index(addresses),.transition_class(classes),
    .pending_completion_candidate(completion),.neutral_routed_candidate(route),
    .state_q(retained),.state_candidate_d(candidate),
    .request_accept_capacity(g.take),.request_reject_capacity(g.deny),
    .capacity_accept_mask(g.accepted),.capacity_reject_mask(g.rejected),
    .accepted_change_mask(g.changed),.accepted_changes(g.count),
    .capacity_remaining(g.remaining),.capacity_exhausted(g.exhausted),
    .switch_load_numerator(g.load),.capacity_candidate_events(g.candidates),
    .capacity_accept_events(g.accepts),.capacity_reject_events(g.rejects),
    .capacity_exhausted_events(g.exhaustions),.accepted_change_events(g.events),
    .transition_capacity_valid(g.flags[9]),.accepted_changes_within_limit(g.flags[8]),
    .capacity_remaining_valid(g.flags[7]),.capacity_exhaustion_valid(g.flags[6]),
    .same_state_capacity_valid(g.flags[5]),.pending_capacity_valid(g.flags[4]),
    .active_neutral_capacity_valid(g.flags[3]),.switch_load_bound_valid(g.flags[2]),
    .no_queue_overflow(g.flags[1]),.no_actual_direct_events(g.flags[0])
  );

  function automatic bit nonzero(input int value);
    return value==1 || value==3;
  endfunction
  function automatic bit opposite(input int q,d);
    return (q==1 && d==3) || (q==3 && d==1);
  endfunction

  // One cell, one lane, with optional completion ownership of the same cell.
  function automatic active_t active_expected(input int cell_id,lane_id,q,p,t,s,
                                               input bit en,req,comp,neut,valid_addr);
    active_t r;
    bit commit_ok,neutral_ok,completed;
    int value;
    r='0; r.state_word[2*cell_id+:2]=2'(q);
    r.domain_ok=1; r.route_ok=1; r.pending_ok=1; r.reserved_ok=1;
    r.direct_ok=1; r.capacity_ok=1; r.output_ok=(q!=2); r.replay_ok=1;
    commit_ok=(s==0 || s==2 || s==3);
    neutral_ok=(s==0 || s==1 || s==4);
    completed=en && comp && q==0 && nonzero(p) && commit_ok;
    value=q;
    if (q==2 || p==2) begin
      r.reserved[cell_id]=1; r.reserved_n=1;
      r.domain_ok=0; r.reserved_ok=0;
    end
    if (en && comp) begin
      if (completed) begin
        value=p; r.valid[cell_id]=1; r.release_mask[cell_id]=1;
        r.pending[cell_id]=1; r.changed[cell_id]=1;
        r.release_n=1; r.pending_n=1; r.changed_n=1;
      end else begin
        r.pending_ok=0; r.replay_ok=0;
        if (q==2 || !nonzero(p)) begin
          r.reserved[cell_id]=1; r.domain_ok=0; r.reserved_ok=0;
        end
      end
    end
    if (en && req) begin
      if (!valid_addr) begin
        r.domain_ok=0; r.reserved_ok=0; r.replay_ok=0;
      end else if (q==2 || t==2) begin
        r.reserved[cell_id]=1; r.reserved_n++;
        r.domain_ok=0; r.reserved_ok=0; r.replay_ok=0;
      end else if (completed) r.replay_ok=0;
      else if (q==t) begin
        r.valid[cell_id]=1; r.same[cell_id]=1; r.same_n=1;
      end else if (q==0) begin
        if (commit_ok) begin
          value=t; r.valid[cell_id]=1; r.release_mask[cell_id]=1;
          r.changed[cell_id]=1; r.release_n=1; r.changed_n=1;
        end
      end else if (t==0) begin
        if (neutral_ok) begin
          value=0; r.valid[cell_id]=1; r.neutral[cell_id]=1;
          r.changed[cell_id]=1; r.neutral_n=1; r.changed_n=1;
        end
      end else begin
        r.requested_n=1;
        if (neut && neutral_ok) begin
          value=0; r.valid[cell_id]=1; r.neutral[cell_id]=1;
          r.opposite[cell_id]=1; r.routed[cell_id]=1; r.changed[cell_id]=1;
          r.neutral_n=1; r.prevented_n=1; r.routed_n=1; r.changed_n=1;
        end else r.route_ok=0;
      end
    end
    r.state_word[2*cell_id+:2]=2'(value);
    r.replay_ok &= s<5 && r.domain_ok && r.pending_ok && r.route_ok;
    return r;
  endfunction

  function automatic guard_t guard_expected(input int cell_id,lane_id,q,d,kind,s,
                                             input bit en,req,comp,routed,valid_addr);
    guard_t r;
    bit bad,legal_pending,grant,change;
    r='0; r.flags='1; r.remaining=L;
    legal_pending=(q==0 && nonzero(d));
    if (en && comp) begin
      if (legal_pending) begin
        r.accepted[cell_id]=1; r.changed[cell_id]=1; r.candidates=1;
      end else begin
        r.rejected[cell_id]=1; r.rejects=1; r.flags[4]=0;
      end
    end
    if (en && req) begin
      grant=0; change=0;
      bad=q==2 || d==2 || kind>3 || opposite(q,d);
      if (!valid_addr) r.flags[9]=0;
      else if (comp) begin end
      else if (bad) begin
        r.flags[9]=0;
        if (opposite(q,d)) r.flags[3]=0;
      end else if (kind==3) begin
        r.candidates++;
        grant=routed && nonzero(q) && d==0;
        change=grant;
        if (!grant) r.flags[3]=0;
      end else if (q==d) begin
        grant=(kind==0);
        if (!grant) r.flags[5]=0;
      end else if (kind==0) r.flags[5]=0;
      else begin grant=1; change=1; r.candidates++; end
      if (grant) begin
        r.take[lane_id]=1; r.accepted[cell_id]=1;
        if (change) r.changed[cell_id]=1;
      end else begin
        r.deny[lane_id]=1; r.rejects++;
        if (valid_addr) r.rejected[cell_id]=1;
      end
    end
    r.count=$countones(r.changed); r.remaining=L-r.count;
    r.load=r.count; r.accepts=r.count; r.events=r.count;
    r.exhausted=(r.count==L); r.exhaustions=int'(r.exhausted);
    if (routed && r.accepted[cell_id] && !r.changed[cell_id]) r.flags[3]=0;
    r.flags[9] &= s<5 && r.flags[5] && r.flags[4] && r.flags[3];
    return r;
  endfunction

  task automatic clear_inputs();
    tick=0; scheduler=FRP_SCHED_FREE; retained='0; pending_word='0;
    candidate='0; request='0; neutralized='0; addresses='0;
    targets='0; classes='0; completion='0; route='0;
  endtask
  task automatic check_active(input active_t want);
    #1; checks++;
    if (a!==want) $fatal(1,"TRANSITION_BOUNDARY active case=%0d cells=%0d got=%h want=%h",
                        active_cases,CELLS,a,want);
    signature=(signature^64'(a))*64'h100000001b3;
    active_cases++;
  endtask
  task automatic check_guard(input guard_t want);
    #1; checks++;
    if (g!==want) $fatal(1,"TRANSITION_BOUNDARY capacity case=%0d cells=%0d got=%h want=%h",
                        guard_cases,CELLS,g,want);
    signature=(signature^64'(g))*64'h100000001b3;
    guard_cases++;
  endtask

  initial begin : exercise
    int c,k,other;
    bit en,req,comp,neut;
    guard_t want;
    if (!(CELLS inside {8,9,16,32,64})) $fatal(1,"Unsupported CELLS");
    if (!$value$plusargs("SEED=%d",seed)) seed=76;
    for (int pos=0;pos<CELLS;pos++) begin
      c=(pos+int'(seed%CELLS))%CELLS; k=(pos+int'(seed%L))%L;
      for (int q=0;q<4;q++) for (int p=0;p<4;p++) for (int t=0;t<4;t++)
      for (int s=0;s<8;s++) for (int mode=0;mode<4;mode++) for (int nr=0;nr<2;nr++) begin
        en=(mode!=0); req=(mode!=2); comp=(mode!=1); neut=1'(nr);
        clear_inputs(); tick=en; scheduler=frp_m31_scheduler_state_e'(s);
        retained[2*c+:2]=2'(q); pending_word[2*c+:2]=2'(p);
        request[k]=req; neutralized[k]=neut; addresses[k*B+:B]=B'(c);
        targets[2*k+:2]=2'(t); completion[c]=comp;
        check_active(active_expected(c,k,q,p,t,s,en,req,comp,neut,1));
      end
      for (int q=0;q<4;q++) for (int d=0;d<4;d++) for (int kind=0;kind<16;kind++)
      for (int s=0;s<8;s++) for (int mode=0;mode<8;mode++) begin
        en=1'(mode>>2); comp=1'(mode>>1); neut=1'(mode);
        clear_inputs(); tick=en; scheduler=frp_m31_scheduler_state_e'(s);
        retained[2*c+:2]=2'(q); candidate[2*c+:2]=2'(d);
        request[k]=1; addresses[k*B+:B]=B'(c); classes[4*k+:4]=4'(kind);
        completion[c]=comp; route[c]=neut;
        check_guard(guard_expected(c,k,q,d,kind,s,en,1,comp,neut,1));
      end
      clear_inputs(); tick=1; request[k]=1; addresses[k*B+:B]=B'(c);
      classes[4*k+:4]=1; candidate[2*c+:2]=1;
      other=(k+1)%L; request[other]=1; addresses[other*B+:B]=B'(c); classes[4*other+:4]=1;
      want=guard_expected(c,(k<other?k:other),0,1,1,0,1,1,0,0,1);
      want.deny[k<other?other:k]=1; want.rejected[c]=1; want.rejects=1;
      check_guard(want); duplicates++;
    end
    for (int address=CELLS;address<(1<<B);address++) for (int lane=0;lane<L;lane++) begin
      clear_inputs(); tick=1; request[lane]=1; addresses[lane*B+:B]=B'(address);
      targets[2*lane+:2]=1; classes[4*lane+:4]=1;
      check_active(active_expected(0,lane,0,0,1,0,1,1,0,0,0));
      check_guard(guard_expected(0,lane,0,0,1,0,1,1,0,0,0));
      invalid_addresses++;
    end
    if (active_cases!=4096*CELLS+invalid_addresses ||
        guard_cases!=16384*CELLS+CELLS+invalid_addresses ||
        duplicates!=CELLS || invalid_addresses!=((1<<B)-CELLS)*L)
      $fatal(1,"TRANSITION_BOUNDARY incomplete enumeration");
    $display("PASS TRANSITION_BOUNDARY cells=%0d seed=%0d active=%0d capacity=%0d invalid_addresses=%0d duplicates=%0d checks=%0d signature=%016h",
             CELLS,seed,active_cases,guard_cases,invalid_addresses,duplicates,checks,signature);
    $finish;
  end
endmodule

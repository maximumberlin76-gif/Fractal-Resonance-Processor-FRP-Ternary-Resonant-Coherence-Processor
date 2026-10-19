// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Three downstream contracts with separate references and qualification records.
// A: active-neutral candidates. C: capacity arbitration. W: retained writeback.
// References use explicit encoding/cadence tables and independent saved state.
// Input faults are driven at public ports; all public outputs are compared.
// CELLS=8,16,32,64; canonical and extended address configurations.
`timescale 1ns/1ps
`include "frp_m31_active_neutral.sv"
`include "frp_m31_capacity_guard.sv"
`include "frp_m31_state_update.sv"

module frp_m32_downstream_checker #(
  parameter int N=8, EXTRA=0, L=N/4, I=$clog2(N)+EXTRA
)(output bit done=0);
  import frp_m31_pkg::frp_m31_scheduler_state_e;
  logic tick=0, clk=0, rst_n=1;
  frp_m31_scheduler_state_e sched=frp_m31_scheduler_state_e'(0);
  logic [2*N-1:0] state_in=0, pending=0, candidate=0;
  logic [L-1:0] accept=0, neutral=0;
  logic [L*I-1:0] indices=0;
  logic [2*L-1:0] targets=0;
  logic [4*L-1:0] classes=0;
  logic [N-1:0] complete=0, routed=0;
  logic [N-1:0] capacity=0, changed=0, reserved=0, direct=0;
  int saved[N], next_saved[N];
  longint unsigned checks[3]='{default:0}, probes[3]='{default:0};
  longint unsigned signature[3]='{default:64'hcbf29ce484222325};
  longint unsigned hits[3][8]='{default:'{default:0}};
  longint unsigned cycles=0, resets=0;
  logic [31:0] rng=32'h86d13e75;
  typedef struct packed {
    logic [(N * 2) - 1:0] state_candidate_d;
    logic [N - 1:0] transition_valid_mask;
    logic [N - 1:0] same_state_mask;
    logic [N - 1:0] zero_to_nonzero_mask;
    logic [N - 1:0] nonzero_to_zero_mask;
    logic [N - 1:0] opposite_polarity_mask;
    logic [N - 1:0] neutral_routed_mask;
    logic [N - 1:0] pending_completion_mask;
    logic [N - 1:0] actual_direct_mask;
    logic [N - 1:0] reserved_transition_mask;
    logic [N - 1:0] accepted_change_candidate_mask;
    logic [32 - 1:0] same_state_events;
    logic [32 - 1:0] zero_to_nonzero_events;
    logic [32 - 1:0] nonzero_to_zero_events;
    logic [32 - 1:0] requested_direct_events;
    logic [32 - 1:0] prevented_direct_events;
    logic [32 - 1:0] neutral_routed_events;
    logic [32 - 1:0] pending_completion_events;
    logic [32 - 1:0] actual_direct_events;
    logic [32 - 1:0] reserved_transition_events;
    logic [32 - 1:0] accepted_change_candidate_events;
    logic  transition_domain_valid;
    logic  active_neutral_routing_valid;
    logic  pending_completion_from_zero_valid;
    logic  no_reserved_transition;
    logic  no_actual_direct_events;
    logic  transition_capacity_valid;
    logic  state_output_domain_valid;
    logic  transition_replay_deterministic;
  } a_t;
  a_t a, ea;
  typedef struct packed {
    logic [L - 1:0] request_accept_capacity;
    logic [L - 1:0] request_reject_capacity;
    logic [N - 1:0] capacity_accept_mask;
    logic [N - 1:0] capacity_reject_mask;
    logic [N - 1:0] accepted_change_mask;
    logic [32 - 1:0] accepted_changes;
    logic [32 - 1:0] capacity_remaining;
    logic  capacity_exhausted;
    logic [32 - 1:0] switch_load_numerator;
    logic [32 - 1:0] capacity_candidate_events;
    logic [32 - 1:0] capacity_accept_events;
    logic [32 - 1:0] capacity_reject_events;
    logic [32 - 1:0] capacity_exhausted_events;
    logic [32 - 1:0] accepted_change_events;
    logic  transition_capacity_valid;
    logic  accepted_changes_within_limit;
    logic  capacity_remaining_valid;
    logic  capacity_exhaustion_valid;
    logic  same_state_capacity_valid;
    logic  pending_capacity_valid;
    logic  active_neutral_capacity_valid;
    logic  switch_load_bound_valid;
    logic  no_queue_overflow;
    logic  no_actual_direct_events;
  } c_t;
  c_t c, ec;
  typedef struct packed {
    logic [(N*2)-1:0] state_q;
    logic [(N*2)-1:0] state_d;
    logic [(N*2)-1:0] state_out;
    logic [N-1:0] state_write_enable_mask;
    logic [N-1:0] state_hold_mask;
    logic [N-1:0] state_reset_mask;
    logic [N-1:0] state_reserved_mask;
    logic [32-1:0] accepted_changes;
    logic [32-1:0] switch_load_numerator;
    logic [32-1:0] state_write_events;
    logic [32-1:0] state_hold_events;
    logic [32-1:0] state_reset_events;
    logic [32-1:0] accepted_change_events;
    logic [32-1:0] neutral_routed_commit_events;
    logic [32-1:0] pending_completion_commit_events;
    logic [32-1:0] reserved_state_events;
    logic [32-1:0] actual_direct_events;
    logic  state_domain_valid;
    logic  state_output_domain_valid;
    logic  state_update_valid;
    logic  state_write_capacity_valid;
    logic  same_state_hold_valid;
    logic  active_neutral_writeback_valid;
    logic  pending_completion_writeback_valid;
    logic  no_reserved_state_output;
    logic  no_actual_direct_events;
  } w_t;
  w_t w, ew;
  localparam int AW=($bits(a_t)+31)/32;
  localparam int CW=($bits(c_t)+31)/32;
  localparam int WW=($bits(w_t)+31)/32;
  localparam int MAXW=(AW>CW ? (AW>WW ? AW : WW) : (CW>WW ? CW : WW));

  frp_m31_active_neutral #(
    .CELLS(N), .REQUEST_LANES(L), .COUNTER_BITS(32), .CELL_INDEX_BITS(I)
  ) dut_a (
    .tick_enable(tick), .scheduler_state(sched), .state_q(state_in),
    .pending_route_q(pending), .request_accept(accept), .request_neutralized(neutral),
    .request_cell_index(indices), .request_target(targets), .pending_completion_enable(complete),
    .state_candidate_d(a.state_candidate_d),
    .transition_valid_mask(a.transition_valid_mask),
    .same_state_mask(a.same_state_mask),
    .zero_to_nonzero_mask(a.zero_to_nonzero_mask),
    .nonzero_to_zero_mask(a.nonzero_to_zero_mask),
    .opposite_polarity_mask(a.opposite_polarity_mask),
    .neutral_routed_mask(a.neutral_routed_mask),
    .pending_completion_mask(a.pending_completion_mask),
    .actual_direct_mask(a.actual_direct_mask),
    .reserved_transition_mask(a.reserved_transition_mask),
    .accepted_change_candidate_mask(a.accepted_change_candidate_mask),
    .same_state_events(a.same_state_events),
    .zero_to_nonzero_events(a.zero_to_nonzero_events),
    .nonzero_to_zero_events(a.nonzero_to_zero_events),
    .requested_direct_events(a.requested_direct_events),
    .prevented_direct_events(a.prevented_direct_events),
    .neutral_routed_events(a.neutral_routed_events),
    .pending_completion_events(a.pending_completion_events),
    .actual_direct_events(a.actual_direct_events),
    .reserved_transition_events(a.reserved_transition_events),
    .accepted_change_candidate_events(a.accepted_change_candidate_events),
    .transition_domain_valid(a.transition_domain_valid),
    .active_neutral_routing_valid(a.active_neutral_routing_valid),
    .pending_completion_from_zero_valid(a.pending_completion_from_zero_valid),
    .no_reserved_transition(a.no_reserved_transition),
    .no_actual_direct_events(a.no_actual_direct_events),
    .transition_capacity_valid(a.transition_capacity_valid),
    .state_output_domain_valid(a.state_output_domain_valid),
    .transition_replay_deterministic(a.transition_replay_deterministic)
  );

  frp_m31_capacity_guard #(
    .CELLS(N), .REQUEST_LANES(L), .COUNTER_BITS(32), .CELL_INDEX_BITS(I)
  ) dut_c (
    .tick_enable(tick), .scheduler_state(sched), .state_q(state_in),
    .state_candidate_d(candidate), .request_accept_candidate(accept),
    .request_cell_index(indices), .transition_class(classes),
    .pending_completion_candidate(complete), .neutral_routed_candidate(routed),
    .request_accept_capacity(c.request_accept_capacity),
    .request_reject_capacity(c.request_reject_capacity),
    .capacity_accept_mask(c.capacity_accept_mask),
    .capacity_reject_mask(c.capacity_reject_mask),
    .accepted_change_mask(c.accepted_change_mask),
    .accepted_changes(c.accepted_changes),
    .capacity_remaining(c.capacity_remaining),
    .capacity_exhausted(c.capacity_exhausted),
    .switch_load_numerator(c.switch_load_numerator),
    .capacity_candidate_events(c.capacity_candidate_events),
    .capacity_accept_events(c.capacity_accept_events),
    .capacity_reject_events(c.capacity_reject_events),
    .capacity_exhausted_events(c.capacity_exhausted_events),
    .accepted_change_events(c.accepted_change_events),
    .transition_capacity_valid(c.transition_capacity_valid),
    .accepted_changes_within_limit(c.accepted_changes_within_limit),
    .capacity_remaining_valid(c.capacity_remaining_valid),
    .capacity_exhaustion_valid(c.capacity_exhaustion_valid),
    .same_state_capacity_valid(c.same_state_capacity_valid),
    .pending_capacity_valid(c.pending_capacity_valid),
    .active_neutral_capacity_valid(c.active_neutral_capacity_valid),
    .switch_load_bound_valid(c.switch_load_bound_valid),
    .no_queue_overflow(c.no_queue_overflow),
    .no_actual_direct_events(c.no_actual_direct_events)
  );

  frp_m31_state_update #(
    .CELLS(N), .REQUEST_LANES(L), .COUNTER_BITS(32)
  ) dut_w (
    .clk, .rst_n, .tick_enable(tick), .scheduler_state(sched),
    .state_candidate_d(candidate), .capacity_accept_mask(capacity),
    .accepted_change_candidate_mask(changed), .neutral_routed_mask(routed),
    .pending_completion_mask(complete), .reserved_transition_mask(reserved),
    .actual_direct_mask(direct),
    .state_q(w.state_q),
    .state_d(w.state_d),
    .state_out(w.state_out),
    .state_write_enable_mask(w.state_write_enable_mask),
    .state_hold_mask(w.state_hold_mask),
    .state_reset_mask(w.state_reset_mask),
    .state_reserved_mask(w.state_reserved_mask),
    .accepted_changes(w.accepted_changes),
    .switch_load_numerator(w.switch_load_numerator),
    .state_write_events(w.state_write_events),
    .state_hold_events(w.state_hold_events),
    .state_reset_events(w.state_reset_events),
    .accepted_change_events(w.accepted_change_events),
    .neutral_routed_commit_events(w.neutral_routed_commit_events),
    .pending_completion_commit_events(w.pending_completion_commit_events),
    .reserved_state_events(w.reserved_state_events),
    .actual_direct_events(w.actual_direct_events),
    .state_domain_valid(w.state_domain_valid),
    .state_output_domain_valid(w.state_output_domain_valid),
    .state_update_valid(w.state_update_valid),
    .state_write_capacity_valid(w.state_write_capacity_valid),
    .same_state_hold_valid(w.same_state_hold_valid),
    .active_neutral_writeback_valid(w.active_neutral_writeback_valid),
    .pending_completion_writeback_valid(w.pending_completion_writeback_valid),
    .no_reserved_state_output(w.no_reserved_state_output),
    .no_actual_direct_events(w.no_actual_direct_events)
  );

  function automatic bit nonzero(input int x);
    return x==1 || x==3;
  endfunction
  function automatic bit opposite(input int x,y);
    return (x==1 && y==3) || (x==3 && y==1);
  endfunction
  function automatic bit activate();
    return int'(sched)==0 || int'(sched)==2 || int'(sched)==3;
  endfunction
  function automatic bit neutralize();
    return int'(sched)==0 || int'(sched)==1 || int'(sched)==4;
  endfunction
  function automatic int unsigned random_word();
    rng=rng^(rng<<13); rng=rng^(rng>>17); rng=rng^(rng<<5);
    return rng;
  endfunction
  task automatic clear_inputs();
    tick=0; sched=frp_m31_scheduler_state_e'(0);
    state_in=0; pending=0; candidate=0; accept=0; neutral=0;
    indices=0; targets=0; classes=0; complete=0; routed=0;
    capacity=0; changed=0; reserved=0; direct=0;
  endtask
  task automatic lane(input int k,address,target,kind);
    indices[k*I+:I]=I'(address); targets[k*2+:2]=2'(target);
    classes[k*4+:4]=4'(kind); accept[k]=1;
  endtask

  task automatic predict_a();
    int s,p,t,address;
    bit domain_ok,replay_ok,completion_ok,output_ok;
    domain_ok=1; replay_ok=1; completion_ok=1; output_ok=1;
    ea='0; ea.state_candidate_d=state_in;
    for(int j=0;j<N;j++) begin
      s=int'(state_in[j*2+:2]); p=int'(pending[j*2+:2]);
      if(s==2 || p==2) begin
        ea.reserved_transition_mask[j]=1; ea.reserved_transition_events++;
        domain_ok=0;
      end
      if(tick && complete[j]) begin
        if(s==0 && nonzero(p) && activate()) begin
          ea.state_candidate_d[j*2+:2]=2'(p);
          ea.transition_valid_mask[j]=1; ea.zero_to_nonzero_mask[j]=1;
          ea.pending_completion_mask[j]=1; ea.accepted_change_candidate_mask[j]=1;
          ea.zero_to_nonzero_events++; ea.pending_completion_events++;
          ea.accepted_change_candidate_events++;
        end else begin
          completion_ok=0; replay_ok=0;
          if(s==2 || !nonzero(p)) begin
            ea.reserved_transition_mask[j]=1; domain_ok=0;
          end
        end
      end
    end
    for(int k=0;k<L;k++) if(tick && accept[k]) begin
      address=int'(indices[k*I+:I]); t=int'(targets[k*2+:2]);
      if(address>=N) begin domain_ok=0; replay_ok=0; end
      else begin
        s=int'(state_in[address*2+:2]);
        if(s==2 || t==2) begin
          ea.reserved_transition_mask[address]=1; ea.reserved_transition_events++;
          domain_ok=0; replay_ok=0;
        end else if(ea.pending_completion_mask[address]) replay_ok=0;
        else if(s==t) begin
          ea.transition_valid_mask[address]=1; ea.same_state_mask[address]=1;
          ea.same_state_events++;
        end else begin
          if(opposite(s,t)) ea.requested_direct_events++;
          if((s==0 && activate()) || (nonzero(s) && neutralize()
             && (t==0 || (opposite(s,t) && neutral[k])))) begin
            ea.state_candidate_d[address*2+:2]=(s==0) ? 2'(t) : 2'b00;
            ea.transition_valid_mask[address]=1;
            ea.accepted_change_candidate_mask[address]=1;
            ea.accepted_change_candidate_events++;
            if(s==0) begin
              ea.zero_to_nonzero_mask[address]=1; ea.zero_to_nonzero_events++;
            end else begin
              ea.nonzero_to_zero_mask[address]=1; ea.nonzero_to_zero_events++;
            end
            if(opposite(s,t)) begin
              ea.opposite_polarity_mask[address]=1; ea.neutral_routed_mask[address]=1;
              ea.prevented_direct_events++; ea.neutral_routed_events++;
            end
          end
        end
      end
    end
    for(int j=0;j<N;j++) if(ea.state_candidate_d[j*2+:2]==2) begin
      output_ok=0; ea.reserved_transition_mask[j]=1;
    end
    ea.state_output_domain_valid=output_ok;
    ea.no_reserved_transition=domain_ok && output_ok;
    ea.transition_domain_valid=domain_ok && output_ok;
    ea.no_actual_direct_events=1;
    ea.active_neutral_routing_valid=(ea.requested_direct_events==ea.prevented_direct_events);
    ea.pending_completion_from_zero_valid=completion_ok;
    ea.transition_capacity_valid=(ea.accepted_change_candidate_events==32'($countones(ea.accepted_change_candidate_mask)));
    ea.transition_replay_deterministic=replay_ok && int'(sched)<5 && ea.transition_domain_valid
      && completion_ok && ea.active_neutral_routing_valid;
  endtask

  task automatic predict_c();
    int s,t,address,kind,used;
    bit ok,pending_ok,neutral_ok,same_ok,approve,reject,change;
    ec='0; used=0; ok=1; pending_ok=1; neutral_ok=1; same_ok=1;
    for(int j=0;j<N;j++) if(tick && complete[j]) begin
      s=int'(state_in[j*2+:2]); t=int'(candidate[j*2+:2]);
      if(s!=0 || !nonzero(t)) begin
        pending_ok=0; ec.capacity_reject_mask[j]=1; ec.capacity_reject_events++;
      end else begin
        ec.capacity_candidate_events++;
        if(used<L) begin
          ec.capacity_accept_mask[j]=1; ec.accepted_change_mask[j]=1; used++;
        end else begin ec.capacity_reject_mask[j]=1; ec.capacity_reject_events++; end
      end
    end
    for(int k=0;k<L;k++) if(tick && accept[k]) begin
      address=int'(indices[k*I+:I]); kind=int'(classes[k*4+:4]);
      approve=0; reject=0; change=0;
      if(address>=N) begin reject=1; ok=0; end
      else begin
        s=int'(state_in[address*2+:2]); t=int'(candidate[address*2+:2]);
        change=(s!=t);
        if(complete[address] || ec.capacity_accept_mask[address]) reject=1;
        else if(s==2 || t==2 || kind>3 || opposite(s,t)) begin
          reject=1; ok=0;
          if(opposite(s,t)) neutral_ok=0;
        end else if(kind==3) begin
          ec.capacity_candidate_events++;
          if(!routed[address] || !nonzero(s) || t!=0) begin reject=1; neutral_ok=0; end
          else if(used<L) approve=1;
          else reject=1;
        end else if(change==(kind==0)) begin reject=1; same_ok=0; end
        else if(!change) approve=1;
        else begin
          ec.capacity_candidate_events++;
          if(used<L) approve=1; else reject=1;
        end
        if(approve) begin
          ec.capacity_accept_mask[address]=1;
          if(change) begin ec.accepted_change_mask[address]=1; used++; end
        end
        if(reject) ec.capacity_reject_mask[address]=1;
      end
      ec.request_accept_capacity[k]=approve;
      ec.request_reject_capacity[k]=reject;
      if(reject) ec.capacity_reject_events++;
    end
    ec.accepted_changes=32'(used); ec.accepted_change_events=32'(used);
    ec.capacity_accept_events=32'(used); ec.switch_load_numerator=32'(used);
    ec.capacity_remaining=32'(L-used); ec.capacity_exhausted=(used==L);
    ec.capacity_exhausted_events=32'(used==L);
    ec.accepted_changes_within_limit=1; ec.capacity_remaining_valid=1;
    ec.capacity_exhaustion_valid=1; ec.same_state_capacity_valid=same_ok;
    ec.pending_capacity_valid=pending_ok;
    ec.active_neutral_capacity_valid=neutral_ok
      && ((ec.accepted_change_mask & routed)==(ec.capacity_accept_mask & routed));
    ec.switch_load_bound_valid=1; ec.no_queue_overflow=1; ec.no_actual_direct_events=1;
    ec.transition_capacity_valid=ok && int'(sched)<5 && same_ok
      && pending_ok && ec.active_neutral_capacity_valid;
  endtask

  task automatic predict_w();
    int s,t,writes;
    bit contract_ok,domain_ok,cap_ok,same_ok,neutral_ok,pending_ok;
    bit metadata_ok,schedule_ok,change,blocked;
    ew='0; writes=0;
    contract_ok=1; domain_ok=1; cap_ok=1; same_ok=1; neutral_ok=1; pending_ok=1;
    for(int j=0;j<N;j++) begin
      s=saved[j]; t=int'(candidate[j*2+:2]); next_saved[j]=s;
      ew.state_q[j*2+:2]=2'(s); ew.state_out[j*2+:2]=2'(s);
      if(!rst_n) begin next_saved[j]=0; ew.state_reset_mask[j]=1; ew.state_reset_events++; end
      else begin
        change=(s!=t); metadata_ok=1; schedule_ok=1;
        blocked=(t==2 || reserved[j] || direct[j] || opposite(s,t));
        if(t==2 || reserved[j]) begin
          ew.state_reserved_mask[j]=1; ew.reserved_state_events++;
          domain_ok=0; contract_ok=0;
        end
        if(direct[j] || opposite(s,t)) begin metadata_ok=0; contract_ok=0; end
        if(routed[j] && complete[j]) begin
          neutral_ok=0; pending_ok=0; metadata_ok=0; contract_ok=0;
        end
        if(changed[j] && !change) begin same_ok=0; metadata_ok=0; contract_ok=0; end
        if(change) begin
          if(!changed[j]) begin cap_ok=0; metadata_ok=0; contract_ok=0; end
          if(routed[j]) begin
            schedule_ok=neutralize();
            if(!nonzero(s) || t!=0) begin neutral_ok=0; metadata_ok=0; contract_ok=0; end
          end else if(complete[j]) begin
            schedule_ok=activate();
            if(s!=0 || !nonzero(t)) begin pending_ok=0; metadata_ok=0; contract_ok=0; end
          end else if(s==0 && nonzero(t)) schedule_ok=activate();
          else if(nonzero(s) && t==0) schedule_ok=neutralize();
          else schedule_ok=0;
        end
        if(!schedule_ok) begin
          if(routed[j]) neutral_ok=0;
          if(complete[j]) pending_ok=0;
          metadata_ok=0; contract_ok=0;
        end
        if(tick && change && capacity[j] && changed[j] && !blocked && metadata_ok && schedule_ok) begin
          next_saved[j]=t; writes++; ew.state_write_enable_mask[j]=1;
          if(routed[j]) ew.neutral_routed_commit_events++;
          if(complete[j]) ew.pending_completion_commit_events++;
        end else begin ew.state_hold_mask[j]=1; ew.state_hold_events++; end
      end
      ew.state_d[j*2+:2]=2'(next_saved[j]);
    end
    ew.accepted_changes=32'(writes); ew.switch_load_numerator=32'(writes);
    ew.state_write_events=32'(writes); ew.accepted_change_events=32'(writes);
    ew.state_domain_valid=domain_ok; ew.state_output_domain_valid=1;
    ew.state_write_capacity_valid=cap_ok && writes<=L;
    ew.same_state_hold_valid=same_ok; ew.active_neutral_writeback_valid=neutral_ok;
    ew.pending_completion_writeback_valid=pending_ok;
    ew.no_reserved_state_output=1; ew.no_actual_direct_events=1;
    ew.state_update_valid=contract_ok && int'(sched)<5 && domain_ok
      && ew.state_write_capacity_valid && same_ok && neutral_ok && pending_ok;
  endtask

  task automatic probe(input int test_id);
    logic [MAXW*32-1:0] got,want;
    int words;
    #1;
    case(test_id)
      0: begin
        predict_a(); got=(MAXW*32)'(a); want=(MAXW*32)'(ea); words=AW;
        hits[0][0]+=64'(!a.transition_domain_valid);
        hits[0][1]+=64'(!a.active_neutral_routing_valid);
        hits[0][2]+=64'(!a.pending_completion_from_zero_valid);
        hits[0][3]+=64'(!a.transition_capacity_valid);
        hits[0][4]+=64'(!a.transition_replay_deterministic);
        hits[0][5]+=64'(a.accepted_change_candidate_events!=0);
        hits[0][6]+=64'(a.same_state_events!=0);
        hits[0][7]+=64'(a.pending_completion_events!=0);
      end
      1: begin
        predict_c(); got=(MAXW*32)'(c); want=(MAXW*32)'(ec); words=CW;
        hits[1][0]+=64'(!c.transition_capacity_valid);
        hits[1][1]+=64'(!c.same_state_capacity_valid);
        hits[1][2]+=64'(!c.pending_capacity_valid);
        hits[1][3]+=64'(!c.active_neutral_capacity_valid);
        hits[1][4]+=64'(c.capacity_exhausted);
        hits[1][5]+=64'(c.accepted_changes!=0);
        hits[1][6]+=64'(c.capacity_reject_events!=0);
        hits[1][7]+=64'((|c.request_accept_capacity) && c.accepted_changes==0);
      end
      2: begin
        predict_w(); got=(MAXW*32)'(w); want=(MAXW*32)'(ew); words=WW;
        hits[2][0]+=64'(!w.state_domain_valid);
        hits[2][1]+=64'(!w.same_state_hold_valid);
        hits[2][2]+=64'(!w.active_neutral_writeback_valid);
        hits[2][3]+=64'(!w.pending_completion_writeback_valid);
        hits[2][4]+=64'(!w.state_write_capacity_valid);
        hits[2][5]+=64'(w.state_write_events!=0);
        hits[2][6]+=64'(w.state_hold_events!=0);
        hits[2][7]+=64'(w.state_reset_events!=0);
      end
      default: $fatal(1,"Unknown downstream test");
    endcase
    probes[test_id]++;
    for(int k=0;k<words;k++) begin
      checks[test_id]++;
      if(got[k*32+:32]!==want[k*32+:32])
        $fatal(1,"DOWNSTREAM test=%0d cells=%0d extra=%0d probe=%0d word=%0d got=%h expected=%h",
          test_id,N,EXTRA,probes[test_id],k,got[k*32+:32],want[k*32+:32]);
      signature[test_id]=(signature[test_id]^{32'b0,got[k*32+:32]})*64'h100000001b3;
    end
  endtask
  task automatic clock_w();
    probe(2);
    if(!rst_n) for(int j=0;j<N;j++) saved[j]=0;
    else if(tick) for(int j=0;j<N;j++) saved[j]=next_saved[j];
    clk=1; #1; probe(2); clk=0; cycles++;
  endtask
  task automatic reset_w();
    clear_inputs(); rst_n=0;
    for(int j=0;j<N;j++) saved[j]=0;
    probe(2); rst_n=1; probe(2); resets++;
  endtask
  task automatic hold_candidates();
    for(int j=0;j<N;j++) candidate[j*2+:2]=2'(saved[j]);
  endtask

  initial begin : campaign
    int k,s,address,goal;
    if(!(N inside {8,16,32,64}) || L!=N/4 || !(EXTRA inside {0,1}))
      $fatal(1,"Unsupported downstream contract parameters");
    reset_w();
    // Test A: ternary operands, all scheduler codes and all four control bits.
    for(int j=0;j<N;j++) for(int current=0;current<4;current++)
      for(int p=0;p<4;p++) for(int t=0;t<4;t++)
        for(int cadence=0;cadence<8;cadence++) for(int control=0;control<16;control++) begin
          clear_inputs(); tick=control[0]; sched=frp_m31_scheduler_state_e'(cadence);
          state_in[j*2+:2]=2'(current); pending[j*2+:2]=2'(p);
          complete[j]=control[1]; k=(j+control)%L;
          lane(k,j,t,0); accept[k]=control[2]; neutral[k]=control[3]; probe(0);
        end
    for(int j=0;j<N;j++) for(int first=0;first<L;first++)
      for(int second=0;second<L;second++) if(first!=second) begin
        clear_inputs(); tick=1;
        lane(first,j,1,1); lane(second,j,3,1); probe(0);
        pending[j*2+:2]=2'b11; complete[j]=1; probe(0);
      end
    // Test C: independently supplied candidate banks and all 16 class encodings.
    for(int j=0;j<N;j++) for(int current=0;current<4;current++)
      for(int t=0;t<4;t++) for(int kind=0;kind<16;kind++)
        for(int control=0;control<16;control++) begin
          clear_inputs(); tick=control[0]; sched=frp_m31_scheduler_state_e'((kind+control)%8);
          state_in[j*2+:2]=2'(current); candidate[j*2+:2]=2'(t);
          complete[j]=control[1]; routed[j]=control[2]; k=(j+kind+control)%L;
          lane(k,j,0,kind); accept[k]=control[3]; probe(1);
        end
    // Extended addresses exercise public-port rejection without internal forcing.
    for(int j=N;j<(1<<I);j++) for(int slot=0;slot<L;slot++)
      for(int code=0;code<16;code++) begin
        clear_inputs(); tick=1; lane(slot,j,code%4,code); neutral[slot]=1;
        probe(0); probe(1); tick=0; probe(0); probe(1);
      end
    // Completion priority, rotating backlog, duplicate lanes and exact capacity edges.
    for(int offset=0;offset<N;offset++) for(int count=0;count<=N;count++) begin
      clear_inputs(); tick=1;
      for(int j=0;j<N;j++) candidate[j*2+:2]=2'b01;
      for(int j=0;j<count;j++) complete[(j+offset)%N]=1;
      for(int slot=0;slot<L;slot++) lane(slot,(slot+offset)%N,0,1);
      probe(1);
      for(int slot=0;slot<L;slot++) lane(slot,offset,0,1);
      probe(1);
    end
    // Test W: saved legal states, all candidate codes and all seven control bits.
    for(int j=0;j<N;j++) for(int retained=0;retained<3;retained++) begin
      reset_w(); s=(retained==2) ? 3 : retained;
      if(s!=0) begin
        tick=1; candidate[j*2+:2]=2'(s); capacity[j]=1; changed[j]=1; clock_w();
      end
      for(int t=0;t<4;t++) for(int cadence=0;cadence<8;cadence++)
        for(int control=0;control<128;control++) begin
          clear_inputs(); hold_candidates(); sched=frp_m31_scheduler_state_e'(cadence);
          candidate[j*2+:2]=2'(t); tick=control[0]; capacity[j]=control[1];
          changed[j]=control[2]; routed[j]=control[3]; complete[j]=control[4];
          reserved[j]=control[5]; direct[j]=control[6]; probe(2);
        end
    end
    // Writeback count boundaries and asynchronous reset during active input.
    for(int count=0;count<=N;count++) begin
      reset_w(); tick=1;
      for(int j=0;j<count;j++) begin candidate[j*2+:2]=2'b01; capacity[j]=1; changed[j]=1; end
      clock_w(); rst_n=0;
      for(int j=0;j<N;j++) saved[j]=0;
      probe(2); clock_w(); rst_n=1; probe(2); resets++;
    end
    // Legal neutral and pending completion histories in every cadence, then pauses.
    for(int mode=0;mode<3;mode++) begin
      reset_w();
      for(int iteration=0;iteration<256;iteration++) begin
        clear_inputs(); hold_candidates(); tick=(iteration%11!=0);
        s=(mode==0) ? 0 : ((mode==1) ? ((iteration%8==7) ? 2 : 1)
                                                   : ((iteration%8==0) ? 3 : 4));
        sched=frp_m31_scheduler_state_e'(s);
        for(int slot=0;slot<L;slot++) begin
          address=(iteration*L+slot)%N;
          if(saved[address]==0 && activate()) begin
            candidate[address*2+:2]=((iteration+slot)%2==0) ? 2'b01 : 2'b11;
            capacity[address]=1; changed[address]=1; complete[address]=1;
          end else if(nonzero(saved[address]) && neutralize()) begin
            candidate[address*2+:2]=0; capacity[address]=1; changed[address]=1; routed[address]=1;
          end
        end
        clock_w();
      end
    end
    // Mixed histories: independent candidates and metadata across the whole bank.
    for(int iteration=0;iteration<4096;iteration++) begin
      if(iteration%257==0) reset_w();
      clear_inputs(); tick=(random_word()%5!=0); sched=frp_m31_scheduler_state_e'(random_word()%8);
      for(int j=0;j<N;j++) begin
        state_in[j*2+:2]=2'(random_word()); pending[j*2+:2]=2'(random_word());
        candidate[j*2+:2]=2'(random_word()); complete[j]=(random_word()%4==0);
        routed[j]=(random_word()%3==0); capacity[j]=(random_word()%4!=0);
        changed[j]=(random_word()%4!=0); reserved[j]=(random_word()%7==0);
        direct[j]=(random_word()%7==0);
      end
      for(int slot=0;slot<L;slot++) begin
        address=int'(random_word()%(1<<I)); goal=int'(random_word()%4);
        lane(slot,address,goal,int'(random_word()%16));
        accept[slot]=(random_word()%4!=0); neutral[slot]=(random_word()%2!=0);
      end
      probe(0); probe(1); clock_w();
    end
    reset_w();
    for(int test_id=0;test_id<3;test_id++) begin
      for(int b=0;b<8;b++) if(hits[test_id][b]==0)
        $fatal(1,"Missing downstream bin test=%0d bin=%0d",test_id,b);
      $display("DOWNSTREAM_BINS cells=%0d extra=%0d test=%0d hits=%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
        N,EXTRA,test_id,hits[test_id][0],hits[test_id][1],hits[test_id][2],hits[test_id][3],
        hits[test_id][4],hits[test_id][5],hits[test_id][6],hits[test_id][7]);
      $display("PASS DOWNSTREAM cells=%0d extra=%0d test=%0d ports=%0d probes=%0d checks=%0d signature=%016h",
        N,EXTRA,test_id,(test_id==0) ? 29 : ((test_id==1) ? 24 : 26),
        probes[test_id],checks[test_id],signature[test_id]);
    end
    $display("DOWNSTREAM_HISTORY cells=%0d extra=%0d cycles=%0d resets=%0d",N,EXTRA,cycles,resets);
    done=1;
  end
endmodule

module frp_m32_downstream_contract_tb #(parameter int CELLS=8);
  wire [1:0] done;
  frp_m32_downstream_checker #(.N(CELLS),.EXTRA(0)) canonical(done[0]);
  frp_m32_downstream_checker #(.N(CELLS),.EXTRA(1)) extended_address(done[1]);
  initial begin
    wait(&done);
    $display("PASS DOWNSTREAM_ALL cells=%0d tests=3 configurations=2",CELLS);
    $finish;
  end
  initial begin #100000000; $fatal(1,"Downstream contract watchdog"); end
endmodule

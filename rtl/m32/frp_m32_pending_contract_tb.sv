// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Pending-route contract: all 29 outputs, independent retained-route model.
// Covers legal history, malformed approvals, duplicate lane ownership,
// completion capacity, pauses, asynchronous reset and deterministic recovery.
// Canonical and extended address widths run as separate configurations.
// Compile from repository root; include rtl/m31 and rtl/m32.
`timescale 1ns/1ps
`include "frp_m31_pending_routes.sv"

module frp_m32_pending_contract_checker #(
  parameter int N=8, EXTRA=0, L=N/4, I=$clog2(N)+EXTRA
)(output bit done=0);
  logic clk=0, rst_n=1, tick_enable=0;
  logic [2*N-1:0] state_q=0;
  logic [L-1:0] request_accept=0, request_neutralized=0;
  logic [L*I-1:0] request_cell_index=0;
  logic [2*L-1:0] request_target=0;
  logic [N-1:0] pending_completion_accept_mask=0;
  typedef struct packed {
    logic [(N * 2) - 1:0] pending_route_q;
    logic [(N * 2) - 1:0] pending_route_d;
    logic [N - 1:0] pending_active_mask;
    logic [N - 1:0] pending_created_mask;
    logic [N - 1:0] pending_completed_mask;
    logic [N - 1:0] pending_cleared_mask;
    logic [N - 1:0] pending_retained_mask;
    logic [N - 1:0] pending_blocked_mask;
    logic [N - 1:0] pending_reserved_mask;
    logic [N - 1:0] pending_overflow_mask;
    logic [32 - 1:0] pending_active_count;
    logic [32 - 1:0] pending_created_events;
    logic [32 - 1:0] pending_completed_events;
    logic [32 - 1:0] pending_cleared_events;
    logic [32 - 1:0] pending_retained_events;
    logic [32 - 1:0] pending_reserved_events;
    logic [32 - 1:0] neutral_routed_events;
    logic [32 - 1:0] prevented_direct_events;
    logic [32 - 1:0] queue_overflow_events;
    logic [32 - 1:0] actual_direct_events;
    logic  pending_domain_valid;
    logic  pending_polarity_valid;
    logic  pending_completion_from_zero_valid;
    logic  pending_non_overwrite_valid;
    logic  pending_capacity_valid;
    logic  pending_replay_deterministic;
    logic  no_pending_reserved_state;
    logic  no_queue_overflow;
    logic  no_actual_direct_events;
  } observation_t;
  observation_t actual, expected;
  localparam int WORDS=($bits(observation_t)+31)/32;
  int saved[N], future[N];
  longint unsigned checks=0, probes=0, cycles=0, resets=0;
  longint unsigned signature=64'hcbf29ce484222325;
  // create, complete, paused, bad address, bad polarity, occupied,
  // duplicate, illegal active completion, excess capacity, empty completion.
  longint unsigned hits[10]='{default:0};
  bit [N-1:0] created_seen=0, completed_seen=0;
  bit [L-1:0] lane_seen=0;
  bit [3:0] state_seen=0, target_seen=0;
  logic [31:0] rng=32'h85a7c319;

  frp_m31_pending_routes #(
    .CELLS(N), .REQUEST_LANES(L), .CELL_INDEX_BITS(I), .COUNTER_BITS(32)
  ) dut (
    .clk, .rst_n, .tick_enable, .state_q, .request_accept,
    .request_neutralized, .request_cell_index, .request_target,
    .pending_completion_accept_mask,
    .pending_route_q(actual.pending_route_q),
    .pending_route_d(actual.pending_route_d),
    .pending_active_mask(actual.pending_active_mask),
    .pending_created_mask(actual.pending_created_mask),
    .pending_completed_mask(actual.pending_completed_mask),
    .pending_cleared_mask(actual.pending_cleared_mask),
    .pending_retained_mask(actual.pending_retained_mask),
    .pending_blocked_mask(actual.pending_blocked_mask),
    .pending_reserved_mask(actual.pending_reserved_mask),
    .pending_overflow_mask(actual.pending_overflow_mask),
    .pending_active_count(actual.pending_active_count),
    .pending_created_events(actual.pending_created_events),
    .pending_completed_events(actual.pending_completed_events),
    .pending_cleared_events(actual.pending_cleared_events),
    .pending_retained_events(actual.pending_retained_events),
    .pending_reserved_events(actual.pending_reserved_events),
    .neutral_routed_events(actual.neutral_routed_events),
    .prevented_direct_events(actual.prevented_direct_events),
    .queue_overflow_events(actual.queue_overflow_events),
    .actual_direct_events(actual.actual_direct_events),
    .pending_domain_valid(actual.pending_domain_valid),
    .pending_polarity_valid(actual.pending_polarity_valid),
    .pending_completion_from_zero_valid(actual.pending_completion_from_zero_valid),
    .pending_non_overwrite_valid(actual.pending_non_overwrite_valid),
    .pending_capacity_valid(actual.pending_capacity_valid),
    .pending_replay_deterministic(actual.pending_replay_deterministic),
    .no_pending_reserved_state(actual.no_pending_reserved_state),
    .no_queue_overflow(actual.no_queue_overflow),
    .no_actual_direct_events(actual.no_actual_direct_events)
  );

  function automatic int unsigned random_word();
    rng=rng^(rng<<13); rng=rng^(rng>>17); rng=rng^(rng<<5);
    return rng;
  endfunction

  task automatic idle_inputs();
    tick_enable=0; state_q=0; request_accept=0; request_neutralized=0;
    request_cell_index=0; request_target=0; pending_completion_accept_mask=0;
  endtask

  task automatic lane(input int k, cell_id, goal, input bit accept=1, neutral=1);
    request_cell_index[k*I+:I]=I'(cell_id);
    request_target[k*2+:2]=2'(goal);
    request_accept[k]=accept; request_neutralized[k]=neutral;
  endtask

  task automatic predict();
    int nactive, ncreate, ncomplete, nrouted, noverflow;
    int addressed, goal, current, winner;
    bit domain_ok, polarity_ok, completion_ok, owner_ok, capacity_ok;
    bit relation;
    nactive=0; ncreate=0; ncomplete=0; nrouted=0; noverflow=0;
    domain_ok=1; polarity_ok=1; completion_ok=1; owner_ok=1; capacity_ok=1;
    expected='0;
    // The model stores mathematical symbols -1, 0, +1.
    // Prediction uses neither DUT helpers nor observed DUT state.
    for(int c=0;c<N;c++) begin
      future[c]=saved[c];
      expected.pending_route_q[2*c+:2]=2'(saved[c]);
      if(saved[c]!=0) begin
        nactive++;
        expected.pending_active_mask[c]=1;
        if(tick_enable && pending_completion_accept_mask[c] && state_q[2*c+:2]==0) begin
          future[c]=0; ncomplete++;
          expected.pending_completed_mask[c]=1;
          expected.pending_cleared_mask[c]=1;
          hits[1]++; completed_seen[c]=1;
        end else begin
          expected.pending_retained_mask[c]=1;
          expected.pending_blocked_mask[c]=1;
          if(!tick_enable) hits[2]++;
          if(tick_enable && pending_completion_accept_mask[c]) begin
            completion_ok=0; capacity_ok=0; hits[7]++;
          end
        end
      end else if(tick_enable && pending_completion_accept_mask[c]) begin
        capacity_ok=0; hits[9]++;
      end
    end
    // Count malformed addresses per active lane, separately from cell arbitration.
    for(int k=0;k<L;k++) begin
      if(tick_enable && request_accept[k] && request_neutralized[k]) begin
        nrouted++; lane_seen[k]=1;
        if(int'(request_cell_index[k*I+:I])>=N) begin
          domain_ok=0; hits[3]++;
        end
      end
    end
    // Per-cell priority: first eligible opposite-polarity lane owns the slot.
    for(int c=0;c<N;c++) begin
      winner=-1;
      current=int'(state_q[2*c+:2]);
      for(int k=0;k<L;k++) begin
        addressed=int'(request_cell_index[k*I+:I]);
        goal=int'(request_target[2*k+:2]);
        if(tick_enable && request_accept[k] && request_neutralized[k] && addressed==c) begin
          state_seen[current]=1; target_seen[goal]=1;
          relation=((current==1 && goal==3) || (current==3 && goal==1));
          if(!relation) begin
            polarity_ok=0; hits[4]++;
          end else if(saved[c]!=0 || winner>=0) begin
            owner_ok=0; noverflow++;
            expected.pending_blocked_mask[c]=1;
            expected.pending_overflow_mask[c]=1;
            if(saved[c]!=0) hits[5]++; else hits[6]++;
          end else begin
            winner=k; future[c]=(goal==3) ? -1 : 1;
            ncreate++; expected.pending_created_mask[c]=1;
            hits[0]++; created_seen[c]=1;
          end
        end
      end
      expected.pending_route_d[2*c+:2]=2'(future[c]);
    end
    if(ncomplete>L) begin capacity_ok=0; hits[8]++; end
    expected.pending_active_count=32'(nactive);
    expected.pending_created_events=32'(ncreate);
    expected.pending_completed_events=32'(ncomplete);
    expected.pending_cleared_events=32'(ncomplete);
    expected.pending_retained_events=tick_enable ? 32'(nactive-ncomplete) : 0;
    expected.neutral_routed_events=32'(nrouted);
    expected.prevented_direct_events=32'(nrouted);
    expected.queue_overflow_events=32'(noverflow);
    expected.pending_domain_valid=domain_ok;
    expected.pending_polarity_valid=polarity_ok;
    expected.pending_completion_from_zero_valid=completion_ok;
    expected.pending_non_overwrite_valid=owner_ok;
    expected.pending_capacity_valid=capacity_ok;
    // The capacity flag separately diagnoses a completion count above the budget.
    expected.pending_replay_deterministic=domain_ok && polarity_ok && owner_ok
      && completion_ok && !(tick_enable && |(pending_completion_accept_mask & ~expected.pending_active_mask));
    expected.no_pending_reserved_state=1;
    expected.no_queue_overflow=(noverflow==0);
    expected.no_actual_direct_events=1;
  endtask

  task automatic probe();
    logic [WORDS*32-1:0] got, want;
    #1; predict();
    got=actual; want=expected; probes++;
    for(int w=0;w<WORDS;w++) begin
      checks++;
      if(got[w*32+:32]!==want[w*32+:32])
        $fatal(1,"PENDING N=%0d extra=%0d cycle=%0d probe=%0d word=%0d got=%h expected=%h",
          N,EXTRA,cycles,probes,w,got[w*32+:32],want[w*32+:32]);
      signature=(signature ^ {32'b0,got[w*32+:32]})*64'h100000001b3;
    end
  endtask

  task automatic step();
    probe();
    if(tick_enable) for(int c=0;c<N;c++) saved[c]=future[c];
    clk=1; #1; probe(); clk=0; cycles++;
  endtask

  task automatic reset_model();
    idle_inputs(); rst_n=0;
    for(int c=0;c<N;c++) saved[c]=0;
    // Observe asynchronous reset without a rising clock edge.
    probe(); rst_n=1; probe(); resets++;
  endtask

  task automatic seed_cell(input int c, polarity);
    idle_inputs(); tick_enable=1;
    state_q[2*c+:2]=(polarity>0) ? 2'b11 : 2'b01;
    lane(c%L,c,(polarity>0) ? 1 : 3);
    step(); idle_inputs();
  endtask

  task automatic seed_all();
    reset_model();
    for(int base=0;base<N;base+=L) begin
      idle_inputs(); tick_enable=1;
      for(int k=0;k<L;k++) begin
        state_q[2*(base+k)+:2]=((base+k)%2) ? 2'b01 : 2'b11;
        lane(k,base+k,((base+k)%2) ? 3 : 1);
      end
      step();
    end
    idle_inputs();
  endtask

  initial begin : campaign
    int address, goal, choice;
    if(!(N inside {8,16,32,64}) || L!=N/4 || !(EXTRA inside {0,1}))
      $fatal(1,"Unsupported pending contract parameters");
    reset_model();
    // Every cell, stored polarity, input code and control combination on every lane.
    for(int c=0;c<N;c++) for(int p=-1;p<=1;p++) begin
      reset_model();
      if(p!=0) seed_cell(c,p);
      for(int s=0;s<4;s++) for(int t=0;t<4;t++)
        for(int control=0;control<16;control++) for(int k=0;k<L;k++) begin
          idle_inputs(); state_q[2*c+:2]=2'(s);
          tick_enable=control[0]; pending_completion_accept_mask[c]=control[1];
          lane(k,c,t,control[2],control[3]); probe();
        end
    end
    // Invalid addresses, all target codes and all lane positions.
    for(int a=N;a<(1<<I);a++) for(int t=0;t<4;t++)
      for(int k=0;k<L;k++) for(int control=0;control<8;control++) begin
        idle_inputs(); tick_enable=control[0];
        lane(k,a,t,control[1],control[2]); probe();
      end
    // Ordered lane pairs: duplicate, invalid-before-valid and occupied slot.
    for(int c=0;c<N;c++) for(int a=0;a<L;a++) for(int b=0;b<L;b++)
      if(a!=b) for(int t=0;t<4;t++) begin
        reset_model(); tick_enable=1; state_q[2*c+:2]=2'b01;
        lane(a,c,t); lane(b,c,3); step();
        step();
      end
    // Completion budget boundaries, including more approvals than lanes.
    for(int count=0;count<=N;count++) begin
      seed_all(); tick_enable=1;
      for(int c=0;c<count;c++) pending_completion_accept_mask[c]=1;
      step(); idle_inputs(); tick_enable=1; step();
    end
    // Paused backlog, batch completion, immediate reuse and reset recovery.
    seed_all();
    for(int k=0;k<33;k++) begin
      tick_enable=0; pending_completion_accept_mask='1; step();
    end
    for(int base=0;base<N;base+=L) begin
      idle_inputs(); tick_enable=1;
      for(int k=0;k<L;k++) pending_completion_accept_mask[base+k]=1;
      step();
    end
    for(int c=0;c<N;c++) seed_cell(c,(c%2) ? -1 : 1);
    reset_model(); seed_cell(0,1);
    idle_inputs(); tick_enable=1; pending_completion_accept_mask[0]=1; step();
    // Deterministic mixed histories with malformed port-level approvals.
    for(int iteration=0;iteration<8192;iteration++) begin
      if(iteration%257==0) reset_model();
      idle_inputs(); tick_enable=(iteration%7!=0);
      for(int c=0;c<N;c++) begin
        state_q[2*c+:2]=2'(random_word());
        pending_completion_accept_mask[c]=(random_word()%5==0);
      end
      for(int k=0;k<L;k++) begin
        address=int'(random_word()%(1<<I));
        goal=int'(random_word()%4); choice=int'(random_word()%4);
        if(choice<2 && address<N) begin
          state_q[2*address+:2]=(choice==0) ? 2'b01 : 2'b11;
          goal=(choice==0) ? 3 : 1;
        end
        lane(k,address,goal,(random_word()%4!=0),(random_word()%4!=0));
      end
      step();
    end
    reset_model();
    if(created_seen!=='1 || completed_seen!=='1 || lane_seen!=='1
       || state_seen!==4'b1111 || target_seen!==4'b1111)
      $fatal(1,"Missing cell/lane/domain coverage N=%0d extra=%0d",N,EXTRA);
    for(int k=0;k<10;k++) begin
      if(k==3 && EXTRA==0) begin
        if(hits[k]!=0) $fatal(1,"Canonical address domain mismatch");
      end else if(hits[k]==0) $fatal(1,"Missing pending reason bin %0d",k);
    end
    $display("PENDING_EVENTS cells=%0d extra=%0d create=%0d complete=%0d paused=%0d bad_address=%0d bad_polarity=%0d occupied=%0d duplicate=%0d illegal_complete=%0d excess=%0d empty_complete=%0d",
      N,EXTRA,hits[0],hits[1],hits[2],hits[3],hits[4],hits[5],hits[6],hits[7],hits[8],hits[9]);
    $display("PASS PENDING cells=%0d extra=%0d ports=29 cycles=%0d probes=%0d resets=%0d checks=%0d signature=%016h",
      N,EXTRA,cycles,probes,resets,checks,signature);
    done=1;
  end
endmodule

module frp_m32_pending_contract_tb #(parameter int CELLS=8);
  wire [1:0] done;
  frp_m32_pending_contract_checker #(.N(CELLS),.EXTRA(0)) canonical(done[0]);
  frp_m32_pending_contract_checker #(.N(CELLS),.EXTRA(1)) extended_address(done[1]);
  initial begin
    wait(&done);
    $display("PASS PENDING_ALL cells=%0d configurations=2",CELLS);
    $finish;
  end
  initial begin #100000000; $fatal(1,"Pending contract watchdog"); end
endmodule

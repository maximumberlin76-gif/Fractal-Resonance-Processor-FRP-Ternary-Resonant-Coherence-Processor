// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 ingress contract: registered target capture and M31 lane arbitration.
// Independent reference state and explicit encoding/scheduler truth tables.
// All public outputs are checked before and after each clock transition.
// Covers reserved inputs, rejection priority, pending ownership, lane ordering,
// counter clear/capture overlap, saturation, asynchronous reset and recovery.
// Normal address widths and one extended-width interface are tested separately.
// Input-domain faults are applied at module ports; retained core state is not forced.
// Compile top with CELLS=8,16,32,64; include paths rtl/m31 and rtl/m32.
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"
`include "frp_m31_request_lanes.sv"

module frp_m32_ingress_contract_checker #(
  parameter int N=8, C=4, EXTRA=0,
  parameter int L=N/4, I=$clog2(N)+EXTRA
)(output bit done=0);
  import frp_m31_pkg::frp_m31_scheduler_state_e;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_target_valid=0, auto_target_enable=0;
  logic [2*N-1:0] phase_target_source=0, retained_state=0, pending_route=0;
  logic [2*N-1:0] external_bank=0;
  logic [L-1:0] external_valid=0;
  logic [L*I-1:0] external_index=0;
  logic [2*L-1:0] external_goal=0;
  frp_m31_scheduler_state_e scheduler_state=frp_m31_scheduler_state_e'(0);

  typedef struct packed {
    logic [ (N*2)-1:0 ] registered_target_q;
    logic  registered_target_valid_q;
    logic  phase_target_domain_valid;
    logic  registered_target_domain_valid;
    logic  capture_accepted;
    logic  capture_rejected;
    logic [C-1:0] accepted_capture_events_q;
    logic [C-1:0] rejected_capture_events_q;
    logic  registered_request_enable;
    logic [L-1:0] phase_request_valid;
    logic [ (L*I)-1:0 ] phase_request_cell_index;
    logic [ (L*2)-1:0 ] phase_request_target;
    logic [L - 1:0] request_accept;
    logic [L - 1:0] request_reject;
    logic [L - 1:0] request_reject_invalid_cell;
    logic [L - 1:0] request_reject_invalid_target;
    logic [L - 1:0] request_reject_duplicate_cell;
    logic [L - 1:0] request_reject_scheduler;
    logic [L - 1:0] request_reject_capacity;
    logic [L - 1:0] request_reject_pending_busy;
    logic [L - 1:0] request_reject_tick_disabled;
    logic [L - 1:0] request_neutralized;
    logic [N - 1:0] accepted_cell_mask;
    logic [N - 1:0] rejected_cell_mask;
    logic [N - 1:0] neutral_routed_cell_mask;
    logic [N - 1:0] requested_direct_cell_mask;
    logic [32 - 1:0] accepted_changes;
    logic [32 - 1:0] requested_lane_events;
    logic [32 - 1:0] accepted_lane_events;
    logic [32 - 1:0] rejected_lane_events;
    logic [32 - 1:0] requested_direct_events;
    logic [32 - 1:0] prevented_direct_events;
    logic [32 - 1:0] neutral_routed_events;
    logic  request_lane_order_valid;
    logic  request_cell_domain_valid;
    logic  request_target_domain_valid;
    logic  duplicate_cell_guard_valid;
    logic  scheduler_gate_valid;
    logic  transition_capacity_valid;
    logic  active_neutral_routing_valid;
    logic  no_actual_direct_events;
    logic  no_queue_overflow;
  } observation_t;
  observation_t actual, expected;
  localparam int WORDS=($bits(observation_t)+31)/32;
  localparam longint unsigned LIMIT=(64'd1<<C)-1;
  logic [2*N-1:0] saved_target=0;
  bit saved_valid=0;
  longint unsigned accepted=0, rejected=0, checks=0, cycles=0, probes=0;
  longint unsigned captures=0, faults=0, clears=0, resets=0;
  longint unsigned sat_accept=0, sat_reject=0;
  longint unsigned reason_hits[7]='{default:0};
  longint unsigned signature=64'hcbf29ce484222325;
  bit [N-1:0] invalid_source_seen=0, accepted_seen=0;
  bit [L-1:0] lane_seen=0;
  bit [7:0] scheduler_seen=0;
  logic [31:0] rng=32'h7384a921;
  wire [L-1:0] selected_valid=auto_target_enable ? actual.phase_request_valid : external_valid;
  wire [L*I-1:0] selected_index=auto_target_enable ? actual.phase_request_cell_index : external_index;
  wire [2*L-1:0] selected_goal=auto_target_enable ? actual.phase_request_target : external_goal;
  wire [2*N-1:0] selected_bank=auto_target_enable ? actual.registered_target_q : external_bank;

  frp_m32_registered_target_request_path #(
    .CELLS(N), .REQUEST_LANES(L), .CELL_INDEX_BITS(I), .COUNTER_BITS(C)
  ) boundary_dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .phase_target_valid,
    .phase_target_source, .auto_target_enable, .retained_state, .pending_route,
    .scheduler_state,
    .registered_target_q(actual.registered_target_q),
    .registered_target_valid_q(actual.registered_target_valid_q),
    .phase_target_domain_valid(actual.phase_target_domain_valid),
    .registered_target_domain_valid(actual.registered_target_domain_valid),
    .capture_accepted(actual.capture_accepted),
    .capture_rejected(actual.capture_rejected),
    .accepted_capture_events_q(actual.accepted_capture_events_q),
    .rejected_capture_events_q(actual.rejected_capture_events_q),
    .registered_request_enable(actual.registered_request_enable),
    .phase_request_valid(actual.phase_request_valid),
    .phase_request_cell_index(actual.phase_request_cell_index),
    .phase_request_target(actual.phase_request_target)
  );

  frp_m31_request_lanes #(
    .CELLS(N), .REQUEST_LANES(L), .CELL_INDEX_BITS(I), .COUNTER_BITS(32)
  ) arbitration_dut (
    .tick_enable, .scheduler_state, .request_valid(selected_valid),
    .request_cell_index(selected_index), .request_target(selected_goal),
    .state_q(retained_state), .target_q(selected_bank), .pending_route_q(pending_route),
    .request_accept(actual.request_accept),
    .request_reject(actual.request_reject),
    .request_reject_invalid_cell(actual.request_reject_invalid_cell),
    .request_reject_invalid_target(actual.request_reject_invalid_target),
    .request_reject_duplicate_cell(actual.request_reject_duplicate_cell),
    .request_reject_scheduler(actual.request_reject_scheduler),
    .request_reject_capacity(actual.request_reject_capacity),
    .request_reject_pending_busy(actual.request_reject_pending_busy),
    .request_reject_tick_disabled(actual.request_reject_tick_disabled),
    .request_neutralized(actual.request_neutralized),
    .accepted_cell_mask(actual.accepted_cell_mask),
    .rejected_cell_mask(actual.rejected_cell_mask),
    .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
    .requested_direct_cell_mask(actual.requested_direct_cell_mask),
    .accepted_changes(actual.accepted_changes),
    .requested_lane_events(actual.requested_lane_events),
    .accepted_lane_events(actual.accepted_lane_events),
    .rejected_lane_events(actual.rejected_lane_events),
    .requested_direct_events(actual.requested_direct_events),
    .prevented_direct_events(actual.prevented_direct_events),
    .neutral_routed_events(actual.neutral_routed_events),
    .request_lane_order_valid(actual.request_lane_order_valid),
    .request_cell_domain_valid(actual.request_cell_domain_valid),
    .request_target_domain_valid(actual.request_target_domain_valid),
    .duplicate_cell_guard_valid(actual.duplicate_cell_guard_valid),
    .scheduler_gate_valid(actual.scheduler_gate_valid),
    .transition_capacity_valid(actual.transition_capacity_valid),
    .active_neutral_routing_valid(actual.active_neutral_routing_valid),
    .no_actual_direct_events(actual.no_actual_direct_events),
    .no_queue_overflow(actual.no_queue_overflow)
  );

  function automatic bit valid_symbol(input int value);
    return value==0 || value==1 || value==3;
  endfunction

  function automatic bit nonzero_symbol(input int value);
    return value==1 || value==3;
  endfunction

  function automatic bit admits(input int state_code, goal_code, cadence);
    if (!valid_symbol(state_code) || !valid_symbol(goal_code) || cadence>4)
      return 0;
    if (state_code==goal_code) return 1;
    if (state_code==0) return cadence==0 || cadence==2 || cadence==3;
    return cadence==0 || cadence==1 || cadence==4;
  endfunction

  function automatic logic [31:0] random_word();
    rng=rng^(rng<<13); rng=rng^(rng>>17); rng=rng^(rng<<5);
    return rng;
  endfunction

  task automatic predict;
    logic [L-1:0] valids;
    logic [L*I-1:0] indices;
    logic [2*L-1:0] goals;
    logic [2*N-1:0] bank;
    bit domain_ok, eligible, opposite;
    int count, cell_id, current_code, goal_code, pending_code, reason;
    expected='0;
    domain_ok=1;
    for (int c=0;c<N;c++)
      domain_ok &= valid_symbol(int'(phase_target_source[2*c+:2]));
    expected.registered_target_q=saved_target;
    expected.registered_target_valid_q=saved_valid;
    expected.phase_target_domain_valid=domain_ok;
    expected.registered_target_domain_valid=1;
    expected.capture_accepted=tick_enable && phase_target_valid && domain_ok;
    expected.capture_rejected=tick_enable && phase_target_valid && !domain_ok;
    expected.accepted_capture_events_q=C'(accepted);
    expected.rejected_capture_events_q=C'(rejected);
    expected.registered_request_enable=auto_target_enable && saved_valid;
    count=0;
    for (int c=0;c<N;c++) begin
      current_code=int'(retained_state[2*c+:2]);
      goal_code=int'(saved_target[2*c+:2]);
      pending_code=int'(pending_route[2*c+:2]);
      eligible=expected.registered_request_enable && current_code!=goal_code
        && !nonzero_symbol(pending_code) && admits(current_code,goal_code,int'(scheduler_state));
      if (eligible && count<L) begin
        expected.phase_request_valid[count]=1;
        expected.phase_request_cell_index[count*I+:I]=I'(c);
        expected.phase_request_target[2*count+:2]=2'(goal_code);
        count++;
      end
    end
    valids=auto_target_enable ? expected.phase_request_valid : external_valid;
    indices=auto_target_enable ? expected.phase_request_cell_index : external_index;
    goals=auto_target_enable ? expected.phase_request_target : external_goal;
    bank=auto_target_enable ? saved_target : external_bank;
    expected.request_cell_domain_valid=1;
    expected.request_target_domain_valid=1;
    for (int c=0;c<N;c++) begin
      if (!valid_symbol(int'(retained_state[2*c+:2]))) expected.request_cell_domain_valid=0;
      if (!valid_symbol(int'(bank[2*c+:2])) || !valid_symbol(int'(pending_route[2*c+:2])))
        expected.request_target_domain_valid=0;
    end
    if (!tick_enable) expected.request_reject_tick_disabled=valids;
    for (int lane=0;lane<L;lane++) begin
      if (tick_enable && valids[lane]) begin
        expected.requested_lane_events++;
        cell_id=int'(indices[lane*I+:I]);
        goal_code=int'(goals[2*lane+:2]);
        reason=0; current_code=0; pending_code=0;
        if (cell_id<N) begin
          current_code=int'(retained_state[2*cell_id+:2]);
          pending_code=int'(pending_route[2*cell_id+:2]);
        end
        if (cell_id>=N) reason=1;
        else if (!valid_symbol(goal_code)) reason=2;
        else if (expected.accepted_cell_mask[cell_id]) reason=3;
        else if (nonzero_symbol(pending_code)) reason=4;
        else if (!admits(current_code,goal_code,int'(scheduler_state))) reason=5;
        if (reason!=0) begin
          expected.request_reject[lane]=1;
          expected.rejected_lane_events++;
          if (cell_id<N) expected.rejected_cell_mask[cell_id]=1;
          case (reason)
            1: begin
              expected.request_reject_invalid_cell[lane]=1;
              expected.request_cell_domain_valid=0;
            end
            2: begin
              expected.request_reject_invalid_target[lane]=1;
              expected.request_target_domain_valid=0;
            end
            3: expected.request_reject_duplicate_cell[lane]=1;
            4: expected.request_reject_pending_busy[lane]=1;
            5: expected.request_reject_scheduler[lane]=1;
            default: $fatal(1,"Invalid reference rejection reason");
          endcase
        end else begin
          expected.request_accept[lane]=1;
          expected.accepted_lane_events++;
          expected.accepted_cell_mask[cell_id]=1;
          if (current_code!=goal_code) expected.accepted_changes++;
          opposite=nonzero_symbol(current_code) && nonzero_symbol(goal_code)
                   && current_code!=goal_code;
          if (opposite) begin
            expected.request_neutralized[lane]=1;
            expected.neutral_routed_cell_mask[cell_id]=1;
            expected.requested_direct_cell_mask[cell_id]=1;
            expected.requested_direct_events++;
            expected.prevented_direct_events++;
            expected.neutral_routed_events++;
          end
        end
      end
    end
    expected.request_lane_order_valid=1;
    expected.duplicate_cell_guard_valid=1;
    expected.scheduler_gate_valid=1;
    expected.transition_capacity_valid=1;
    expected.active_neutral_routing_valid=1;
    expected.no_actual_direct_events=1;
    expected.no_queue_overflow=1;
  endtask

  task automatic inspect;
    logic [WORDS*32-1:0] got, want;
    predict();
    got=actual; want=expected;
    for (int w=0;w<WORDS;w++) begin
      if (got[32*w+:32] !== want[32*w+:32])
        $fatal(1,"INGRESS N=%0d C=%0d EXTRA=%0d cycle=%0d probe=%0d word=%0d got=%h expected=%h",
          N,C,EXTRA,cycles,probes,w,got[32*w+:32],want[32*w+:32]);
      signature=(signature ^ {32'd0,got[32*w+:32]})*64'h100000001b3;
      checks++;
    end
    probes++;
  endtask

  task automatic sample;
    #1; inspect();
    scheduler_seen[int'(scheduler_state)]=1;
    accepted_seen |= expected.accepted_cell_mask;
    lane_seen |= expected.request_accept;
    reason_hits[0]+=$countones(expected.request_accept);
    reason_hits[1]+=$countones(expected.request_reject_invalid_cell);
    reason_hits[2]+=$countones(expected.request_reject_invalid_target);
    reason_hits[3]+=$countones(expected.request_reject_duplicate_cell);
    reason_hits[4]+=$countones(expected.request_reject_pending_busy);
    reason_hits[5]+=$countones(expected.request_reject_scheduler);
    reason_hits[6]+=$countones(expected.request_reject_tick_disabled);
  endtask

  task automatic step;
    bit accept_now, reject_now;
    sample();
    accept_now=expected.capture_accepted;
    reject_now=expected.capture_rejected;
    if (accept_now) begin saved_target=phase_target_source; saved_valid=1; captures++; end
    if (reject_now) begin
      faults++;
      for (int c=0;c<N;c++)
        if (phase_target_source[2*c+:2]==2'b10) invalid_source_seen[c]=1;
    end
    if (clear_counters) begin accepted=0; rejected=0; clears++; end
    else begin
      if (accept_now) begin
        if (accepted<LIMIT) accepted++; else sat_accept++;
      end
      if (reject_now) begin
        if (rejected<LIMIT) rejected++; else sat_reject++;
      end
    end
    clk=1; #1; inspect();
    clk=0; #1; inspect(); cycles++;
  endtask

  task automatic reset_path;
    rst_n=0;
    saved_target=0; saved_valid=0; accepted=0; rejected=0;
    #1; inspect();
    rst_n=1; #1; inspect(); resets++;
  endtask

  task automatic defaults;
    tick_enable=0; clear_counters=0; phase_target_valid=0;
    auto_target_enable=0; phase_target_source=0; retained_state=0;
    pending_route=0; external_bank=0; external_valid=0;
    external_index=0; external_goal=0;
    scheduler_state=frp_m31_scheduler_state_e'(0);
  endtask

  task automatic lane(input int slot, cell_id, goal);
    external_valid[slot]=1;
    external_index[slot*I+:I]=I'(cell_id);
    external_goal[2*slot+:2]=2'(goal);
  endtask

  initial begin : qualification
    int address, peer, first, second;
    if (!(N inside {8,16,32,64}) || !(C inside {1,4,32}) || !(EXTRA inside {0,1}))
      $fatal(1,"Unsupported ingress qualification parameters");
    defaults(); reset_path();

    // Clear has priority for counters while accepted capture still updates data.
    tick_enable=1; phase_target_valid=1; auto_target_enable=1;
    for (int polarity=1;polarity<=3;polarity+=2) begin
      phase_target_source={N{2'(polarity)}};
      for (int k=0;k<40;k++) step();
      phase_target_source[2*(N-1)+:2]=2'b10;
      for (int k=0;k<40;k++) step();
      clear_counters=1; step();
      phase_target_source='0; step();
      clear_counters=0; step();
    end

    // Each source position and control combination, all scheduler encodings.
    for (int c=0;c<N;c++)
      for (int symbol=0;symbol<4;symbol++)
        for (int flags=0;flags<16;flags++)
          for (int cadence=0;cadence<8;cadence++) begin
            defaults();
            tick_enable=flags[0]; phase_target_valid=flags[1];
            clear_counters=flags[2]; auto_target_enable=flags[3];
            scheduler_state=frp_m31_scheduler_state_e'(cadence);
            for (int j=0;j<N;j++) begin
              phase_target_source[2*j+:2]=(j%2==0) ? 2'b01 : 2'b11;
              retained_state[2*j+:2]=2'(j%4);
              pending_route[2*j+:2]=2'((j+c)%4);
            end
            phase_target_source[2*c+:2]=2'(symbol);
            step();
          end

    // One reserved source in every ordered pair of positions: capture is atomic.
    for (int a=0;a<N;a++)
      for (int b=0;b<N;b++) begin
        defaults(); tick_enable=1; phase_target_valid=1; auto_target_enable=1;
        phase_target_source={N{2'b01}}; step();
        phase_target_source[2*a+:2]=2'b10;
        phase_target_source[2*b+:2]=2'b10; step();
        phase_target_source={N{2'b11}}; step();
      end

    // All retained/target/pending codes and all cadence/tick combinations.
    // Address values beyond N exist only in the extended-width interface.
    for (int c=0;c<(1<<I);c++)
      for (int current_code=0;current_code<4;current_code++)
        for (int goal=0;goal<4;goal++)
          for (int pending_code=0;pending_code<4;pending_code++)
            for (int cadence=0;cadence<8;cadence++)
              for (int enabled=0;enabled<2;enabled++) begin
                defaults(); tick_enable=1'(enabled);
                scheduler_state=frp_m31_scheduler_state_e'(cadence);
                address=c%N;
                retained_state[2*address+:2]=2'(current_code);
                pending_route[2*address+:2]=2'(pending_code);
                external_bank[2*address+:2]=2'((current_code+goal)%4);
                lane(c%L,c,goal); sample();
              end

    // Every ordered lane pair: invalid target, duplicate, busy, scheduler priority.
    for (int a=0;a<L;a++)
      for (int b=0;b<L;b++)
        if (a!=b)
          for (int goals=0;goals<16;goals++)
            for (int mask=0;mask<4;mask++)
              for (int scenario=0;scenario<8;scenario++) begin
                defaults(); tick_enable=1;
                first=(a+b)%N; second=(scenario<4) ? first : (first+1)%N;
                scheduler_state=frp_m31_scheduler_state_e'(scenario%4);
                retained_state[2*first+:2]=2'(scenario%4);
                pending_route[2*second+:2]=(scenario==3 || scenario==7) ? 2'b01 : 2'b00;
                lane(a,first,goals%4); lane(b,second,goals/4);
                external_valid[a]=mask[0]; external_valid[b]=mask[1]; sample();
              end

    // Every cell can lead a full request batch; valid lanes remain in ascending order.
    for (int rotate=0;rotate<N;rotate++) begin
      defaults(); tick_enable=1;
      for (int k=0;k<L;k++) lane(k,(rotate+k)%N,(k%2==0) ? 1 : 3);
      sample();
    end

    // Deterministic mixed source/mux/counter history and recovery after asynchronous reset.
    for (int k=0;k<4096;k++) begin
      defaults();
      tick_enable=(k%5!=0); clear_counters=(k%31==0);
      phase_target_valid=(k%7!=0); auto_target_enable=k[0];
      scheduler_state=frp_m31_scheduler_state_e'(k%8);
      for (int c=0;c<N;c++) begin
        phase_target_source[2*c+:2]=2'(random_word()%3);
        if (phase_target_source[2*c+:2]==2'b10) phase_target_source[2*c+:2]=2'b11;
        retained_state[2*c+:2]=2'(random_word());
        pending_route[2*c+:2]=2'(random_word());
        external_bank[2*c+:2]=2'(random_word());
      end
      if (k%3==0) phase_target_source[2*(k%N)+:2]=2'b10;
      for (int slot=0;slot<L;slot++) begin
        lane(slot,int'(random_word()% (1<<I)),int'(random_word()%4));
        external_valid[slot]=1'(random_word());
      end
      step();
      if (k%127==0) reset_path();
    end
    defaults(); reset_path();
    tick_enable=1; phase_target_valid=1; auto_target_enable=1;
    phase_target_source={N{2'b01}}; step();
    if (!saved_valid || accepted!=1 || rejected!=0) $fatal(1,"Recovery model gate failed");
    if (invalid_source_seen!=='1 || accepted_seen!=='1 || lane_seen!=='1 || scheduler_seen!==8'hff)
      $fatal(1,"Incomplete ingress functional coverage");
    for (int reason=0;reason<7;reason++)
      if ((reason!=1 || EXTRA==1) && reason_hits[reason]==0)
        $fatal(1,"Missing ingress reason %0d",reason);
    if (C<32 && (sat_accept==0 || sat_reject==0)) $fatal(1,"Missing counter saturation");
    if (captures==0 || faults==0 || clears==0 || resets<2) $fatal(1,"Missing boundary history");
    $display("INGRESS_EVENTS cells=%0d counter_bits=%0d extra_index=%0d captures=%0d faults=%0d clears=%0d resets=%0d saturated_accept=%0d saturated_reject=%0d reasons=%0d,%0d,%0d,%0d,%0d,%0d,%0d",
      N,C,EXTRA,captures,faults,clears,resets,sat_accept,sat_reject,
      reason_hits[0],reason_hits[1],reason_hits[2],reason_hits[3],reason_hits[4],reason_hits[5],reason_hits[6]);
    $display("PASS INGRESS cells=%0d counter_bits=%0d extra_index=%0d ports=42 cycles=%0d probes=%0d checks=%0d signature=%h",
      N,C,EXTRA,cycles,probes,checks,signature);
    done=1;
  end
endmodule

module frp_m32_ingress_contract_tb #(parameter int CELLS=8);
  wire [3:0] done;
  frp_m32_ingress_contract_checker #(.N(CELLS),.C(1)) c1(done[0]);
  frp_m32_ingress_contract_checker #(.N(CELLS),.C(4)) c4(done[1]);
  frp_m32_ingress_contract_checker #(.N(CELLS),.C(32)) c32(done[2]);
  frp_m32_ingress_contract_checker #(.N(CELLS),.C(4),.EXTRA(1)) wide_index(done[3]);
  initial begin
    wait (&done); #1;
    $display("PASS INGRESS_ALL cells=%0d configurations=4",CELLS);
    $finish;
  end
  initial begin
    #10000000;
    $fatal(1,"Ingress testbench watchdog expired");
  end
endmodule

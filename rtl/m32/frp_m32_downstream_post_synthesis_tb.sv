// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Three post-synthesis comparisons reuse the qualified downstream oracles.
// The synthesis top exports every output in the oracle's packed-field order.
// Synthesize N=8/16/32/64 and EXTRA=0/1 into bundle_net0 and bundle_net1.
// Simulation samples settled outputs between the original 1 ns stimulus steps.
`timescale 1ns/1ps
`include "frp_m31_active_neutral.sv"
`include "frp_m31_capacity_guard.sv"
`include "frp_m31_state_update.sv"

module frp_m32_downstream_bundle #(
  parameter int N=8, EXTRA=0, L=N/4, I=$clog2(N)+EXTRA
)(
  input logic clk, rst_n, tick,
  input frp_m31_pkg::frp_m31_scheduler_state_e sched,
  input logic [2*N-1:0] state_in, pending, candidate,
  input logic [L-1:0] accept, neutral,
  input logic [L*I-1:0] indices,
  input logic [2*L-1:0] targets,
  input logic [4*L-1:0] classes,
  input logic [N-1:0] complete, routed, capacity, changed, reserved, direct,
  output wire [12*N+328-1:0] active_outputs,
  output wire [2*L+3*N+267-1:0] capacity_outputs,
  output wire [10*N+329-1:0] writeback_outputs
);
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
  a_t a;
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
  c_t c;
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
  w_t w;
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

  assign active_outputs=a;
  assign capacity_outputs=c;
  assign writeback_outputs=w;
endmodule

`ifndef SYNTHESIS
`include "frp_m32_downstream_contract_tb.sv"

module frp_m32_downstream_netlist_case #(
  parameter int N=8, EXTRA=0, L=N/4, I=$clog2(N)+EXTRA
)(output bit done=0);
  localparam int A_BITS=12*N+328, C_BITS=2*L+3*N+267, W_BITS=10*N+329;
  localparam int MAX_BITS=(A_BITS>C_BITS) ?
    ((A_BITS>W_BITS)?A_BITS:W_BITS) : ((C_BITS>W_BITS)?C_BITS:W_BITS);
  localparam int WORDS=(MAX_BITS+31)/32;
  localparam int A_WORDS=(A_BITS+31)/32, C_WORDS=(C_BITS+31)/32, W_WORDS=(W_BITS+31)/32;
  wire reference_done;
  wire [A_BITS-1:0] active_outputs;
  wire [C_BITS-1:0] capacity_outputs;
  wire [W_BITS-1:0] writeback_outputs;
  longint unsigned samples=0;
  longint unsigned word_checks[3]='{default:0};
  longint unsigned signature[3]='{default:64'hcbf29ce484222325};
  longint unsigned reset_samples=0, enabled_samples=0, held_samples=0;
  frp_m32_downstream_checker #(.N(N),.EXTRA(EXTRA)) reference_test(.done(reference_done));
  if(EXTRA==0) begin : canonical
    frp_m32_downstream_bundle_net0 netlist(
      .clk(reference_test.clk),
      .rst_n(reference_test.rst_n),
      .tick(reference_test.tick),
      .sched(reference_test.sched),
      .state_in(reference_test.state_in),
      .pending(reference_test.pending),
      .candidate(reference_test.candidate),
      .accept(reference_test.accept),
      .neutral(reference_test.neutral),
      .indices(reference_test.indices),
      .targets(reference_test.targets),
      .classes(reference_test.classes),
      .complete(reference_test.complete),
      .routed(reference_test.routed),
      .capacity(reference_test.capacity),
      .changed(reference_test.changed),
      .reserved(reference_test.reserved),
      .direct(reference_test.direct),
      .active_outputs, .capacity_outputs, .writeback_outputs);
  end else begin : extended_address
    frp_m32_downstream_bundle_net1 netlist(
      .clk(reference_test.clk),
      .rst_n(reference_test.rst_n),
      .tick(reference_test.tick),
      .sched(reference_test.sched),
      .state_in(reference_test.state_in),
      .pending(reference_test.pending),
      .candidate(reference_test.candidate),
      .accept(reference_test.accept),
      .neutral(reference_test.neutral),
      .indices(reference_test.indices),
      .targets(reference_test.targets),
      .classes(reference_test.classes),
      .complete(reference_test.complete),
      .routed(reference_test.routed),
      .capacity(reference_test.capacity),
      .changed(reference_test.changed),
      .reserved(reference_test.reserved),
      .direct(reference_test.direct),
      .active_outputs, .capacity_outputs, .writeback_outputs);
  end

  task automatic compare_outputs();
    logic [WORDS*32-1:0] got, wanted;
    int bits_count, words_count;
    for(int test_id=0;test_id<3;test_id++) begin
      case(test_id)
        0: begin
          bits_count=A_BITS; got=(WORDS*32)'(active_outputs);
          wanted=(WORDS*32)'(reference_test.a);
        end
        1: begin
          bits_count=C_BITS; got=(WORDS*32)'(capacity_outputs);
          wanted=(WORDS*32)'(reference_test.c);
        end
        2: begin
          bits_count=W_BITS; got=(WORDS*32)'(writeback_outputs);
          wanted=(WORDS*32)'(reference_test.w);
        end
        default: $fatal(1,"Unknown equivalence test");
      endcase
      words_count=(bits_count+31)/32;
      for(int k=0;k<words_count;k++) begin
        if(got[k*32+:32]!==wanted[k*32+:32])
          $fatal(1,"NETLIST cells=%0d extra=%0d test=%0d sample=%0d word=%0d net=%h rtl=%h",
            N,EXTRA,test_id,samples,k,got[k*32+:32],wanted[k*32+:32]);
        word_checks[test_id]++;
        signature[test_id]=(signature[test_id]^{32'b0,got[k*32+:32]})*64'h100000001b3;
      end
    end
    samples++;
    if(!reference_test.rst_n) reset_samples++;
    else if(reference_test.tick) enabled_samples++;
    else held_samples++;
  endtask

  initial begin
    if(!(N inside {8,16,32,64}) || !(EXTRA inside {0,1}) || L!=N/4 || I!=$clog2(N)+EXTRA)
      $fatal(1,"Unsupported netlist configuration");
    if($bits(reference_test.a)!=A_BITS || $bits(reference_test.c)!=C_BITS ||
       $bits(reference_test.w)!=W_BITS) $fatal(1,"Output packing changed");
    #250ps;
    while(!reference_done) begin
      compare_outputs();
      #1ns;
    end
    compare_outputs();
    if(reset_samples==0 || enabled_samples==0 || held_samples==0)
      $fatal(1,"Missing equivalence history class");
    if(samples!=reset_samples+enabled_samples+held_samples)
      $fatal(1,"Incorrect equivalence accounting");
    for(int t=0;t<3;t++) begin
      if(word_checks[t]!=samples*((t==0)?64'(A_WORDS):
          (t==1)?64'(C_WORDS):64'(W_WORDS)))
        $fatal(1,"Incomplete output comparisons");
      $display("PASS DOWNSTREAM_NETLIST cells=%0d extra=%0d test=%0d ports=%0d bits=%0d samples=%0d checks=%0d signature=%016h",
        N,EXTRA,t,(t==0)?29:(t==1)?24:26,(t==0)?A_BITS:(t==1)?C_BITS:W_BITS,
        samples,word_checks[t],signature[t]);
    end
    $display("NETLIST_HISTORY cells=%0d extra=%0d reset=%0d enabled=%0d held=%0d",
      N,EXTRA,reset_samples,enabled_samples,held_samples);
    done=1;
  end
endmodule

module frp_m32_downstream_post_synthesis_tb #(parameter int CELLS=8);
  wire [1:0] done;
  frp_m32_downstream_netlist_case #(.N(CELLS),.EXTRA(0)) canonical(done[0]);
  frp_m32_downstream_netlist_case #(.N(CELLS),.EXTRA(1)) extended_address(done[1]);
  initial begin
    wait(&done);
    $display("PASS DOWNSTREAM_NETLIST_ALL cells=%0d tests=3 configurations=2",CELLS);
    $finish;
  end
  initial begin #100000000; $fatal(1,"Downstream netlist watchdog"); end
endmodule
`endif

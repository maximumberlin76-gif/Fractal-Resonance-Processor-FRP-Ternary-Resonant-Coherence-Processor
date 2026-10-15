// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Formal protection of retained ternary execution against direct polarity reversal.
// Top: frp_m31_no_direct_transition_formal; configurations: CELLS=8,16,32.
// All input ports are symbolic. No assumption trusts upstream classification,
// scheduler validity, capacity masks or the actual_direct_mask diagnostic.
// Encoding is checked explicitly: negative=11, active zero=00, positive=01.
// Properties observe public state_out, state_d and write-enable ports.
// Phase targets may change independently; these properties guard execution.
`timescale 1ns/1ps
`include "frp_m31_state_update.sv"

module frp_m31_no_direct_transition_formal #(
  parameter int CELLS=8
)(
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state,
  input logic [CELLS*2-1:0] state_candidate_d,
  input logic [CELLS-1:0] capacity_accept_mask,
  input logic [CELLS-1:0] accepted_change_candidate_mask,
  input logic [CELLS-1:0] neutral_routed_mask,
  input logic [CELLS-1:0] pending_completion_mask,
  input logic [CELLS-1:0] reserved_transition_mask,
  input logic [CELLS-1:0] actual_direct_mask,
  output wire [CELLS*2-1:0] retained_state,
  output wire [CELLS*2-1:0] writeback_state,
  output wire no_direct_writeback,
  output wire no_direct_observed,
  output wire opposite_candidate_blocked,
  output wire neutral_route_from_nonzero,
  output wire completion_from_zero,
  output wire disabled_tick_holds,
  output wire reset_writes_zero,
  output wire witness_negative_request,
  output wire witness_positive_request,
  output wire witness_negative_to_zero,
  output wire witness_positive_to_zero,
  output wire witness_zero_to_negative,
  output wire witness_zero_to_positive,
  output wire all_properties
);
  wire [CELLS-1:0] write_enable;
  logic [CELLS*2-1:0] previous_state;
  logic history_valid=1'b0;

  frp_m31_state_update #(
    .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(CELLS/4), .COUNTER_BITS(32)
  ) dut (
    .clk, .rst_n, .tick_enable, .scheduler_state, .state_candidate_d,
    .capacity_accept_mask, .accepted_change_candidate_mask,
    .neutral_routed_mask, .pending_completion_mask,
    .reserved_transition_mask, .actual_direct_mask,
    .state_q(), .state_d(writeback_state), .state_out(retained_state),
    .state_write_enable_mask(write_enable),
    .state_hold_mask(), .state_reset_mask(), .state_reserved_mask(),
    .accepted_changes(), .switch_load_numerator(),
    .state_write_events(), .state_hold_events(), .state_reset_events(),
    .accepted_change_events(), .neutral_routed_commit_events(),
    .pending_completion_commit_events(), .reserved_state_events(),
    .actual_direct_events(), .state_domain_valid(), .state_output_domain_valid(),
    .state_update_valid(), .state_write_capacity_valid(), .same_state_hold_valid(),
    .active_neutral_writeback_valid(), .pending_completion_writeback_valid(),
    .no_reserved_state_output(), .no_actual_direct_events()
  );

  // Sample actual retained outputs. The first sample has no predecessor.
  // An asynchronous reset produces zero, which cannot be a polarity reversal.
  always_ff @(posedge clk) begin
    previous_state <= retained_state;
    history_valid <= 1'b1;
  end

  wire [CELLS-1:0] writeback_safe, observed_safe, blocked;
  wire [CELLS-1:0] neutral_safe, completion_safe;
  wire [CELLS-1:0] negative_request, positive_request;
  wire [CELLS-1:0] negative_zero, positive_zero, zero_negative, zero_positive;

  for(genvar c=0;c<CELLS;c++) begin : g_cell
    wire [1:0] old_value=retained_state[c*2+:2];
    wire [1:0] next_value=writeback_state[c*2+:2];
    wire [1:0] requested_value=state_candidate_d[c*2+:2];
    wire [1:0] prior_value=previous_state[c*2+:2];
    wire opposite_request=(old_value==2'b11 && requested_value==2'b01) ||
                          (old_value==2'b01 && requested_value==2'b11);

    assign writeback_safe[c]=!((old_value==2'b11 && next_value==2'b01) ||
                              (old_value==2'b01 && next_value==2'b11));
    assign observed_safe[c]=!history_valid ||
      !((prior_value==2'b11 && old_value==2'b01) ||
        (prior_value==2'b01 && old_value==2'b11));
    assign blocked[c]=!(rst_n && tick_enable && opposite_request) ||
                      (next_value==old_value && !write_enable[c]);
    assign neutral_safe[c]=!(write_enable[c] && neutral_routed_mask[c]) ||
      ((old_value==2'b11 || old_value==2'b01) && next_value==2'b00);
    assign completion_safe[c]=!(write_enable[c] && pending_completion_mask[c]) ||
      (old_value==2'b00 && (next_value==2'b11 || next_value==2'b01));

    // Reachability witnesses prevent a passing proof from hiding a frozen DUT.
    // Opposite candidates are exercised with the diagnostic mask deasserted.
    assign negative_request[c]=rst_n && tick_enable &&
      capacity_accept_mask[c] && accepted_change_candidate_mask[c] &&
      !actual_direct_mask[c] && old_value==2'b11 && requested_value==2'b01;
    assign positive_request[c]=rst_n && tick_enable &&
      capacity_accept_mask[c] && accepted_change_candidate_mask[c] &&
      !actual_direct_mask[c] && old_value==2'b01 && requested_value==2'b11;
    assign negative_zero[c]=write_enable[c] && neutral_routed_mask[c] &&
      old_value==2'b11 && next_value==2'b00;
    assign positive_zero[c]=write_enable[c] && neutral_routed_mask[c] &&
      old_value==2'b01 && next_value==2'b00;
    assign zero_negative[c]=write_enable[c] && pending_completion_mask[c] &&
      old_value==2'b00 && next_value==2'b11;
    assign zero_positive[c]=write_enable[c] && pending_completion_mask[c] &&
      old_value==2'b00 && next_value==2'b01;
  end

  assign no_direct_writeback=&writeback_safe;
  assign no_direct_observed=&observed_safe;
  assign opposite_candidate_blocked=&blocked;
  assign neutral_route_from_nonzero=&neutral_safe;
  assign completion_from_zero=&completion_safe;
  assign disabled_tick_holds=!rst_n || tick_enable || writeback_state==retained_state;
  assign reset_writes_zero=rst_n || writeback_state=={CELLS*2{1'b0}};
  assign witness_negative_request=|negative_request;
  assign witness_positive_request=|positive_request;
  assign witness_negative_to_zero=|negative_zero;
  assign witness_positive_to_zero=|positive_zero;
  assign witness_zero_to_negative=|zero_negative;
  assign witness_zero_to_positive=|zero_positive;
  assign all_properties=no_direct_writeback && no_direct_observed &&
    opposite_candidate_blocked && neutral_route_from_nonzero &&
    completion_from_zero && disabled_tick_holds && reset_writes_zero;

  always_comb begin : safety_assertions
    assert(no_direct_writeback);
    assert(no_direct_observed);
    assert(opposite_candidate_blocked);
    assert(neutral_route_from_nonzero);
    assert(completion_from_zero);
    assert(disabled_tick_holds);
    assert(reset_writes_zero);
  end
endmodule

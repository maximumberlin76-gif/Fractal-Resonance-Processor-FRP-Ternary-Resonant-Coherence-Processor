// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent combinational contract for the M31 phase-request adapter.
// Qualified profile: eight cells, two lanes, three-bit cell indexes.
// All 52 input bits are unrestricted; there are no assumptions or clocks.
// Literal transition tables and candidate ranks do not call DUT helpers.
// A candidate's rank is the number of eligible lower-numbered cells.
// Ranks zero and one own the two lanes; later candidates are not emitted.
// Opposite-polarity requests keep the final target, not the neutral bridge.
// Execution of that bridge belongs to the downstream execution contract.
// The existing adapter treats pending 01/11 as busy and 00/10 as not busy.
// Reserved pending 10 is deliberately included, not assumed away or certified
// as a valid pending state. Reserved current/target codes never qualify.
// Scheduler codes 5, 6 and 7 suppress every request.
// Define FRP_M31_PHASE_REQUEST_CONTRACT_NETLIST to use a fresh synthesized
// frp_m31_phase_request_adapter_netlist with the same fixed profile.
// Prove all assertions in a two-state combinational SAT model. Reach bits
// 0..23 are witness predicates, not assumptions or replacements for proof.
// Scope excludes phase arithmetic, state writeback, fairness, full-core
// equivalence, physical timing and four-state simulation.

`ifndef FRP_M31_PHASE_REQUEST_CONTRACT_FORMAL_SV
`define FRP_M31_PHASE_REQUEST_CONTRACT_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_PHASE_REQUEST_CONTRACT_NETLIST
`include "frp_m31_phase_request_adapter.sv"
`endif

module frp_m31_phase_request_contract_formal (
  input logic enable,
  input logic [15:0] retained_state,
  input logic [15:0] pending_route,
  input logic [15:0] phase_target,
  input logic [2:0] scheduler_state,
  output wire [11:0] observed_outputs,
  output logic [23:0] reach
);
  wire [1:0] request_valid;
  wire [5:0] request_cell_index;
  wire [3:0] request_target;
  assign observed_outputs = {request_valid, request_cell_index, request_target};

`ifdef FRP_M31_PHASE_REQUEST_CONTRACT_NETLIST
  frp_m31_phase_request_adapter_netlist dut (
`else
  frp_m31_phase_request_adapter #(
    .CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3)
  ) dut (
`endif
    .enable(enable), .retained_state(retained_state),
    .pending_route(pending_route), .phase_target(phase_target),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .request_valid(request_valid), .request_cell_index(request_cell_index),
    .request_target(request_target)
  );

  function automatic logic eligible(
    input logic [1:0] current_code, target_code, pending_code,
    input logic [2:0] schedule
  );
    if (pending_code == 2'b01 || pending_code == 2'b11) return 1'b0;
    case ({current_code, target_code})
      4'b0001, 4'b0011:
        return schedule == 0 || schedule == 2 || schedule == 3;
      4'b0100, 4'b1100, 4'b0111, 4'b1101:
        return schedule == 0 || schedule == 1 || schedule == 4;
      default: return 1'b0;
    endcase
  endfunction

  logic [7:0] candidate;
  logic [3:0] rank [0:7];
  logic [1:0] expected_valid;
  logic [5:0] expected_index;
  logic [3:0] expected_target;
  logic [3:0] candidate_count;

  always_comb begin
    for (int cell_id = 0; cell_id < 8; cell_id++)
      candidate[cell_id] = eligible(retained_state[2*cell_id +: 2],
        phase_target[2*cell_id +: 2], pending_route[2*cell_id +: 2], scheduler_state);
    candidate_count = 4'($countones(candidate));
    for (int cell_id = 0; cell_id < 8; cell_id++)
      rank[cell_id] = 4'($countones(candidate & ((8'b1 << cell_id) - 8'b1)));

    expected_valid = '0;
    expected_index = '0;
    expected_target = '0;
    for (int lane = 0; lane < 2; lane++)
      for (int cell_id = 0; cell_id < 8; cell_id++)
        if (enable && candidate[cell_id] && rank[cell_id] == lane) begin
          expected_valid[lane] = 1'b1;
          expected_index[3*lane +: 3] |= 3'(cell_id);
          expected_target[2*lane +: 2] |= phase_target[2*cell_id +: 2];
        end

    a_valid: assert (request_valid == expected_valid);
    a_index: assert (request_cell_index == expected_index);
    a_target: assert (request_target == expected_target);
    a_first_present: assert (request_valid[0] == (enable && candidate_count != 0));
    a_second_present: assert (request_valid[1] == (enable && candidate_count >= 2));
    a_compact: assert (!request_valid[1] || request_valid[0]);
    if (!enable || scheduler_state >= 5)
      a_disabled: assert (observed_outputs == 0);
    if (&request_valid)
      a_ascending: assert (request_cell_index[2:0] < request_cell_index[5:3]);
  end

  for (genvar lane = 0; lane < 2; lane++) begin : lane_contract
    wire [2:0] selected_cell = request_cell_index[3*lane +: 3];
    always_comb begin
      if (request_valid[lane]) begin
        a_eligible: assert (enable && candidate[selected_cell]);
        a_rank: assert (rank[selected_cell] == lane);
        a_original_target: assert (
          request_target[2*lane +: 2] == phase_target[2*selected_cell +: 2]);
        a_target_domain: assert (request_target[2*lane +: 2] != 2'b10);
      end else begin
        a_zero_index: assert (selected_cell == 0);
        a_zero_target: assert (request_target[2*lane +: 2] == 0);
      end
    end
  end

  always_comb begin
    reach = '0;
    reach[0] = !enable && candidate == 8'hff && observed_outputs == 0;
    if (enable) begin
      reach[1] = candidate == 0 && scheduler_state < 5;
      reach[2] = candidate == 8'h80 && request_valid == 2'b01;
      reach[3] = candidate == 8'hff && request_cell_index == {3'd1, 3'd0};
      reach[4] = candidate == 8'h81 && request_cell_index == {3'd7, 3'd0};
      reach[5] = (&request_valid) && request_target == {2'b11, 2'b01};
      reach[6] = (&request_valid) && request_target == {2'b01, 2'b11};
      reach[7] = (&request_valid) && request_target == 0;
      reach[8] = candidate[0] && retained_state[1:0] == 2'b01
        && phase_target[1:0] == 2'b11;
      reach[9] = candidate[0] && retained_state[1:0] == 2'b11
        && phase_target[1:0] == 2'b01;
      reach[10] = candidate == 8'h02 && retained_state[1:0] == 0
        && phase_target[1:0] == 1 && pending_route[1:0] == 1 && scheduler_state == 0;
      reach[11] = candidate == 8'h02 && retained_state[1:0] == 0
        && phase_target[1:0] == 1 && pending_route[1:0] == 3 && scheduler_state == 0;
      reach[12] = candidate == 8'h02 && retained_state[1:0] == 2
        && phase_target[1:0] == 1 && pending_route[1:0] == 0 && scheduler_state == 0;
      reach[13] = candidate == 8'h02 && retained_state[1:0] == 0
        && phase_target[1:0] == 2 && pending_route[1:0] == 0 && scheduler_state == 0;
      reach[14] = candidate == 8'h02 && retained_state[1:0] == 1
        && phase_target[1:0] == 1 && pending_route[1:0] == 0 && scheduler_state == 0;
      for (int invalid_code = 5; invalid_code < 8; invalid_code++)
        reach[invalid_code+10] = scheduler_state == invalid_code
          && retained_state == 0 && pending_route == 0 && phase_target == 16'h5555;
      reach[18] = scheduler_state == 0 && retained_state[3:0] == 4'b0100
        && phase_target[3:0] == 4'b0001 && pending_route[3:0] == 0
        && request_valid == 2'b11;
      for (int schedule = 1; schedule < 5; schedule++)
        reach[schedule+18] = scheduler_state == schedule
          && retained_state == 16'h0001 && phase_target == 16'h0007
          && pending_route == 0 && request_valid == 2'b01;
      reach[23] = candidate == 8'h01 && retained_state[1:0] == 0
        && phase_target[1:0] == 1 && pending_route[1:0] == 2 && scheduler_state == 0;
    end
  end
endmodule

`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Inductive safety of the real M32 registered-target/request-path composition.
// Fixed profile: eight cells, two request lanes, full 32-bit capture counters.
// Only the initial sampled reset is assumed; subsequent inputs are arbitrary.
// The reference predicates below do not call the DUT's transition helpers.
// Request priority is checked by each eligible cell's rank, not by replaying
// the adapter's mutable lane-selection loop. Target capture and counter
// properties use independently recorded previous inputs and public outputs.
// State 0 remains active. Opposite-polarity requests describe an intended
// destination; execution through retained state 0 is qualified separately.
// This boundary excludes phase arithmetic, scheduler cadence, execution,
// eventual progress, full-core equivalence and physical reset timing.
// Formal steps are sampled rising edges; use async2sync before SAT.
// Define FRP_M32_REGISTERED_REQUEST_NETLIST to prove the same properties on a
// fresh frp_m32_registered_target_request_path_netlist with the same ports.

`ifndef FRP_M32_REGISTERED_REQUEST_SAFETY_FORMAL_SV
`define FRP_M32_REGISTERED_REQUEST_SAFETY_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M32_REGISTERED_REQUEST_NETLIST
`include "frp_m32_registered_target_request_path.sv"
`endif

module frp_m32_registered_request_safety_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic phase_target_valid,
  input logic [15:0] phase_target_source,
  input logic auto_target_enable,
  input logic [15:0] retained_state,
  input logic [15:0] pending_route,
  input logic [2:0] scheduler_state,
  output wire [15:0] registered_target_q,
  output wire registered_target_valid_q,
  output wire phase_target_domain_valid,
  output wire registered_target_domain_valid,
  output wire capture_accepted,
  output wire capture_rejected,
  output wire [31:0] accepted_capture_events_q,
  output wire [31:0] rejected_capture_events_q,
  output wire registered_request_enable,
  output wire [1:0] phase_request_valid,
  output wire [5:0] phase_request_cell_index,
  output wire [3:0] phase_request_target,
  output logic [15:0] reach
);
  import frp_m31_pkg::*;

`ifdef FRP_M32_REGISTERED_REQUEST_NETLIST
  frp_m32_registered_target_request_path_netlist dut (
`else
  frp_m32_registered_target_request_path #(
    .CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
  ) dut (
`endif
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters), .phase_target_valid(phase_target_valid),
    .phase_target_source(phase_target_source),
    .auto_target_enable(auto_target_enable), .retained_state(retained_state),
    .pending_route(pending_route),
    .scheduler_state(frp_m31_scheduler_state_e'(scheduler_state)),
    .registered_target_q(registered_target_q),
    .registered_target_valid_q(registered_target_valid_q),
    .phase_target_domain_valid(phase_target_domain_valid),
    .registered_target_domain_valid(registered_target_domain_valid),
    .capture_accepted(capture_accepted), .capture_rejected(capture_rejected),
    .accepted_capture_events_q(accepted_capture_events_q),
    .rejected_capture_events_q(rejected_capture_events_q),
    .registered_request_enable(registered_request_enable),
    .phase_request_valid(phase_request_valid),
    .phase_request_cell_index(phase_request_cell_index),
    .phase_request_target(phase_request_target)
  );

  function automatic logic legal(input logic [1:0] code);
    return code != 2'b10;
  endfunction

  function automatic logic legal_bank(input logic [15:0] bank);
    logic result;
    result = 1'b1;
    for (int cell_index = 0; cell_index < 8; cell_index++)
      result = result && legal(bank[2*cell_index +: 2]);
    return result;
  endfunction

  function automatic logic polarized(input logic [1:0] code);
    return code == 2'b01 || code == 2'b11;
  endfunction

  function automatic logic opposite(input logic [1:0] a, b);
    return (a == 2'b01 && b == 2'b11) || (a == 2'b11 && b == 2'b01);
  endfunction

  function automatic logic eligible_cell(
    input logic [1:0] current_value, destination, pending,
    input logic [2:0] schedule
  );
    logic allowed;
    case (schedule)
      3'd0: allowed = 1'b1;
      3'd1, 3'd4: allowed = polarized(current_value);
      3'd2, 3'd3: allowed = current_value == 2'b00;
      default: allowed = 1'b0;
    endcase
    // Pending 01/11 denotes a retained route in the existing port contract.
    // All four pending codes are exercised; none is assumed away.
    return legal(current_value) && legal(destination)
      && current_value != destination && !polarized(pending) && allowed;
  endfunction

  function automatic logic [31:0] increment_saturated(input logic [31:0] value);
    return value == 32'hffffffff ? value : value + 32'd1;
  endfunction

  wire source_legal = legal_bank(phase_target_source);
  wire bank_legal = legal_bank(registered_target_q);
  wire expected_accept = tick_enable && phase_target_valid && source_legal;
  wire expected_reject = tick_enable && phase_target_valid && !source_legal;
  wire expected_enable = auto_target_enable && registered_target_valid_q && bank_legal;
  wire [7:0] eligible;
  logic [3:0] eligible_count;

  logic history_valid = 1'b0;
  logic previous_reset, previous_clear, previous_accept, previous_reject;
  logic previous_target_valid;
  logic [15:0] previous_source, previous_target;
  logic [31:0] previous_accepted_events, previous_rejected_events;
  wire live_transition = history_valid && previous_reset && rst_n;

  // DUT registers have no imposed initial values: reset establishes state.
  always_comb begin
    if (!history_valid) assume (!rst_n);
  end

  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_clear <= clear_counters;
    previous_accept <= expected_accept;
    previous_reject <= expected_reject;
    previous_source <= phase_target_source;
    previous_target <= registered_target_q;
    previous_target_valid <= registered_target_valid_q;
    previous_accepted_events <= accepted_capture_events_q;
    previous_rejected_events <= rejected_capture_events_q;
  end

  always_comb begin
    eligible_count = 0;
    for (int cell_index = 0; cell_index < 8; cell_index++)
      eligible_count = eligible_count + {3'b000, eligible[cell_index]};
  end

  for (genvar cell_index = 0; cell_index < 8; cell_index++) begin : cell_properties
    wire [1:0] current_value = retained_state[2*cell_index +: 2];
    wire [1:0] destination = registered_target_q[2*cell_index +: 2];
    wire [1:0] pending = pending_route[2*cell_index +: 2];
    logic [3:0] rank;
    assign eligible[cell_index] = eligible_cell(current_value, destination, pending, scheduler_state);
    always_comb begin
      rank = 0;
      for (int earlier = 0; earlier < cell_index; earlier++)
        rank = rank + {3'b000, eligible[earlier]};
      if (expected_enable && eligible[cell_index] && rank == 0)
        a_first_choice: assert (phase_request_valid[0]
          && phase_request_cell_index[2:0] == 3'(cell_index)
          && phase_request_target[1:0] == destination);
      if (expected_enable && eligible[cell_index] && rank == 1)
        a_second_choice: assert (phase_request_valid[1]
          && phase_request_cell_index[5:3] == 3'(cell_index)
          && phase_request_target[3:2] == destination);
      if (polarized(pending))
        a_pending_excluded: assert (
          !(phase_request_valid[0] && phase_request_cell_index[2:0] == 3'(cell_index))
          && !(phase_request_valid[1] && phase_request_cell_index[5:3] == 3'(cell_index)));
      if (!legal(current_value))
        a_reserved_state_excluded: assert (
          !(phase_request_valid[0] && phase_request_cell_index[2:0] == 3'(cell_index))
          && !(phase_request_valid[1] && phase_request_cell_index[5:3] == 3'(cell_index)));
    end
  end

  always_comb begin
    a_source_domain: assert (phase_target_domain_valid == source_legal);
    a_registered_domain: assert (registered_target_domain_valid == bank_legal);
    a_capture_accept: assert (capture_accepted == expected_accept);
    a_capture_reject: assert (capture_rejected == expected_reject);
    a_capture_exclusive: assert (!(capture_accepted && capture_rejected));
    a_request_gate: assert (registered_request_enable == expected_enable);
    a_lane_zero_valid: assert (phase_request_valid[0] == (expected_enable && eligible_count > 0));
    a_lane_one_valid: assert (phase_request_valid[1] == (expected_enable && eligible_count > 1));
    if (!phase_request_valid[0])
      a_lane_zero_padding: assert (phase_request_cell_index[2:0] == 0 && phase_request_target[1:0] == 0);
    if (!phase_request_valid[1])
      a_lane_one_padding: assert (phase_request_cell_index[5:3] == 0 && phase_request_target[3:2] == 0);
    if (phase_request_valid[1])
      a_lane_order: assert (phase_request_valid[0]
        && phase_request_cell_index[2:0] < phase_request_cell_index[5:3]);
    if (history_valid) begin
      a_retained_domain: assert (bank_legal);
      if (!rst_n || !previous_reset) begin
        a_reset_bank: assert (registered_target_q == 16'b0);
        a_reset_valid: assert (!registered_target_valid_q);
        a_reset_accepted: assert (accepted_capture_events_q == 0);
        a_reset_rejected: assert (rejected_capture_events_q == 0);
      end else begin
        if (previous_accept) begin
          a_capture_bank: assert (registered_target_q == previous_source);
          a_capture_valid: assert (registered_target_valid_q);
        end else begin
          a_hold_bank: assert (registered_target_q == previous_target);
          a_hold_valid: assert (registered_target_valid_q == previous_target_valid);
        end
        if (previous_clear) begin
          a_clear_accepted: assert (accepted_capture_events_q == 0);
          a_clear_rejected: assert (rejected_capture_events_q == 0);
        end else begin
          a_accepted_counter: assert (accepted_capture_events_q ==
            (previous_accept ? increment_saturated(previous_accepted_events) : previous_accepted_events));
          a_rejected_counter: assert (rejected_capture_events_q ==
            (previous_reject ? increment_saturated(previous_rejected_events) : previous_rejected_events));
        end
      end
    end
  end

  // Each reach bit is requested in a separate SAT query; none is an assumption.
  always_comb begin
    reach = '0;
    if (history_valid && rst_n) begin
      reach[0] = expected_accept && phase_target_source != registered_target_q;
      reach[1] = expected_reject && registered_target_valid_q;
      reach[2] = !tick_enable && phase_target_valid && phase_request_valid[0]
        && phase_target_source != registered_target_q;
      reach[3] = tick_enable && !phase_target_valid && phase_request_valid[0]
        && phase_target_source != registered_target_q;
      reach[4] = !auto_target_enable && registered_target_valid_q && eligible_count > 1;
      reach[5] = scheduler_state == 3'd0 && phase_request_valid == 2'b11;
      reach[6] = scheduler_state == 3'd1 && phase_request_valid[0]
        && phase_request_cell_index[2:0] == 0 && opposite(retained_state[1:0], phase_request_target[1:0]);
      reach[7] = scheduler_state == 3'd2 && phase_request_valid[0]
        && phase_request_cell_index[2:0] == 0 && retained_state[1:0] == 0;
      reach[8] = scheduler_state == 3'd3 && phase_request_valid[0]
        && phase_request_cell_index[2:0] == 0 && retained_state[1:0] == 0;
      reach[9] = scheduler_state == 3'd4 && phase_request_valid[0]
        && phase_request_cell_index[2:0] == 0 && opposite(retained_state[1:0], phase_request_target[1:0]);
      reach[10] = expected_enable && polarized(pending_route[1:0])
        && legal(retained_state[1:0]) && retained_state[1:0] != registered_target_q[1:0]
        && phase_request_valid[0] && phase_request_cell_index[2:0] != 0;
      reach[11] = expected_enable && scheduler_state >= 3'd5 && phase_request_valid == 0;
      reach[12] = live_transition && previous_clear && previous_accept && registered_target_valid_q;
      reach[13] = live_transition && previous_clear && previous_reject && registered_target_valid_q;
      reach[15] = phase_request_valid[0] && phase_request_cell_index[2:0] == 3'd7;
    end
    reach[14] = history_valid && previous_reset && !rst_n && previous_target_valid;
  end
endmodule

`endif

// SPDX-License-Identifier: Apache-2.0
// M31 phase-request selection: independent truth table and all candidate masks.
// Eight cells, two lanes; pending inputs use only canonical -1/0/1 encodings.
`timescale 1ns/1ps
`include "frp_m31_phase_request_adapter.sv"

module frp_m31_phase_request_adapter_tb;
  import frp_m31_pkg::*;
  logic enable = 0;
  logic [15:0] retained_state = 0, pending_route = 0, phase_target = 0;
  frp_m31_scheduler_state_e scheduler_state = FRP_SCHED_FREE;
  logic [1:0] request_valid;
  logic [5:0] request_cell_index;
  logic [3:0] request_target;
  logic [7:0] lane0_cells = 0, lane1_cells = 0;
  int matrix_cases = 0, mask_cases = 0;
  int disable_checks = 0, reenable_checks = 0, observations = 0;
  int empty_outputs = 0, one_request_outputs = 0, two_request_outputs = 0;

  frp_m31_phase_request_adapter #(.CELLS(8), .REQUEST_LANES(2)) dut (
    .enable, .retained_state, .pending_route, .phase_target, .scheduler_state,
    .request_valid, .request_cell_index, .request_target
  );

  function automatic logic [1:0] symbol(input int value);
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1, "Invalid test symbol %0d", value); return 2'b10; end
    endcase
  endfunction

  // Literal scheduler codes: FREE=0, BALANCE=1, COMMIT=2, EXCITE=3,
  // NEUTRALIZE=4. No DUT classification or scheduling helper is used here.
  // Opposite requests retain their final target; execution later routes via 0.
  function automatic bit eligible(
      input logic [1:0] old_value, goal, pending, input int sched);
    if (pending != 2'b00) return 0;
    case ({old_value, goal})
      4'b1100, 4'b0100, 4'b1101, 4'b0111:
        return sched == 0 || sched == 1 || sched == 4;
      4'b0001, 4'b0011:
        return sched == 0 || sched == 2 || sched == 3;
      default: return 0;
    endcase
  endfunction

  task automatic check_outputs(input logic [7:0] candidate_mask);
    logic [1:0] expected_valid;
    logic [5:0] expected_index;
    logic [3:0] expected_target;
    int first_cell, second_cell;
    expected_valid = 0; expected_index = 0; expected_target = 0;
    first_cell = -1; second_cell = -1;
    // Descending scan retains the two smallest indices independently of the
    // DUT's ascending bounded append. Inactive lanes must be entirely zero.
    for (int i = 7; i >= 0; i--)
      if (candidate_mask[i]) begin
        second_cell = first_cell;
        first_cell = i;
      end
    if (enable && first_cell >= 0) begin
      expected_valid[0] = 1;
      expected_index[2:0] = 3'(first_cell);
      expected_target[1:0] = phase_target[2*first_cell +: 2];
    end
    if (enable && second_cell >= 0) begin
      expected_valid[1] = 1;
      expected_index[5:3] = 3'(second_cell);
      expected_target[3:2] = phase_target[2*second_cell +: 2];
    end
    #1;
    if (request_valid !== expected_valid || request_cell_index !== expected_index ||
        request_target !== expected_target) begin
      $display("Adapter inputs: enable=%b sched=%0d state=%h pending=%h target=%h mask=%h",
        enable, scheduler_state, retained_state, pending_route, phase_target, candidate_mask);
      $fatal(1, "Adapter mismatch check=%0d valid=%b/%b index=%h/%h target=%h/%h",
        observations, request_valid, expected_valid, request_cell_index, expected_index,
        request_target, expected_target);
    end
    observations++;
    case (expected_valid)
      2'b00: empty_outputs++;
      2'b01: one_request_outputs++;
      2'b11: two_request_outputs++;
      default: $fatal(1, "Invalid expected lane packing");
    endcase
    if (request_valid[0]) lane0_cells[request_cell_index[2:0]] = 1;
    if (request_valid[1]) lane1_cells[request_cell_index[5:3]] = 1;
  endtask

  initial begin : regression
    logic [7:0] expected_mask;
    logic [1:0] polarity;

    // 2 enables * 8 positions * 8 scheduler codes * 4 old symbols *
    // 4 target symbols * 3 canonical pending symbols = 6144 matrix cases.
    for (int en = 0; en < 2; en++)
      for (int cell_index = 0; cell_index < 8; cell_index++)
        for (int sched = 0; sched < 8; sched++)
          for (int old_code = 0; old_code < 4; old_code++)
            for (int target_code = 0; target_code < 4; target_code++)
              for (int pending = -1; pending <= 1; pending++) begin
                enable = 1'(en);
                scheduler_state = frp_m31_scheduler_state_e'(sched);
                retained_state = 0; pending_route = 0; phase_target = 0;
                retained_state[2*cell_index +: 2] = 2'(old_code);
                pending_route[2*cell_index +: 2] = symbol(pending);
                phase_target[2*cell_index +: 2] = 2'(target_code);
                expected_mask = 0;
                expected_mask[cell_index] = eligible(
                  2'(old_code), 2'(target_code), symbol(pending), sched);
                check_outputs(expected_mask);
                matrix_cases++;
              end

    // Every candidate mask, all five valid scheduler states, both polarities.
    // Blocked cells mix retention, pending ownership, reserved operands and
    // scheduler-ineligible requests. Eligible banks also mix target polarities.
    for (int sched = 0; sched < 5; sched++)
      for (int sign = 0; sign < 2; sign++)
        for (int mask = 0; mask < 256; mask++) begin
          scheduler_state = frp_m31_scheduler_state_e'(sched);
          retained_state = 0; pending_route = 0; phase_target = 0;
          expected_mask = 8'(mask);
          for (int cell_index = 0; cell_index < 8; cell_index++) begin
            polarity = ((cell_index + sign) % 2 == 0) ? 2'b01 : 2'b11;
            if (sched == 2 || sched == 3) begin
              retained_state[2*cell_index +: 2] = 2'b00;
              phase_target[2*cell_index +: 2] = polarity;
            end else begin
              retained_state[2*cell_index +: 2] = polarity;
              phase_target[2*cell_index +: 2] =
                ((cell_index + sign) % 3 == 0) ? 2'b00 : (polarity ^ 2'b10);
            end
            if (!expected_mask[cell_index])
              case ((cell_index + mask + sign) % 5)
                0: phase_target[2*cell_index +: 2] = retained_state[2*cell_index +: 2];
                1: pending_route[2*cell_index +: 2] = polarity;
                2: retained_state[2*cell_index +: 2] = 2'b10;
                3: phase_target[2*cell_index +: 2] = 2'b10;
                4: begin
                  if (sched == 1 || sched == 4) begin
                    retained_state[2*cell_index +: 2] = 2'b00;
                    phase_target[2*cell_index +: 2] = polarity;
                  end else if (sched == 2 || sched == 3) begin
                    retained_state[2*cell_index +: 2] = polarity;
                    phase_target[2*cell_index +: 2] = 2'b00;
                  end else
                    pending_route[2*cell_index +: 2] = polarity ^ 2'b10;
                end
                default: $fatal(1, "Invalid blocker selector");
              endcase
            if (eligible(retained_state[2*cell_index +: 2],
                         phase_target[2*cell_index +: 2],
                         pending_route[2*cell_index +: 2], sched) !== expected_mask[cell_index])
              $fatal(1, "Incorrect candidate-mask stimulus sched=%0d mask=%h cell=%0d",
                sched, expected_mask, cell_index);
          end
          enable = 1; check_outputs(expected_mask); mask_cases++;
          // Only enable changes: dropping it must clear all outputs, and
          // raising it again must immediately reproduce the same selection.
          enable = 0; check_outputs(expected_mask); disable_checks++;
          enable = 1; check_outputs(expected_mask); reenable_checks++;
        end

    if (matrix_cases != 6144 || mask_cases != 2560 || disable_checks != 2560 ||
        reenable_checks != 2560 || observations != 13824 || empty_outputs != 8580 ||
        one_request_outputs != 304 || two_request_outputs != 4940 ||
        lane0_cells !== 8'hff || lane1_cells !== 8'hfe)
      $fatal(1, "Incomplete adapter coverage: matrix=%0d masks=%0d disabled=%0d reenabled=%0d checks=%0d empty=%0d one=%0d two=%0d lane0=%h lane1=%h",
        matrix_cases, mask_cases, disable_checks, reenable_checks, observations,
        empty_outputs, one_request_outputs, two_request_outputs, lane0_cells, lane1_cells);
    $display("FRP_M31_PHASE_REQUEST_ADAPTER_TB: PASS matrix_cases=%0d mask_cases=%0d disable_checks=%0d reenable_checks=%0d observations=%0d empty_outputs=%0d one_request_outputs=%0d two_request_outputs=%0d lane0_cells=%0d lane1_cells=%0d",
      matrix_cases, mask_cases, disable_checks, reenable_checks, observations,
      empty_outputs, one_request_outputs, two_request_outputs, lane0_cells, lane1_cells);
    $finish;
  end

  initial begin
    #100000;
    $fatal(1, "FRP M31 phase-request adapter watchdog expired");
  end
endmodule

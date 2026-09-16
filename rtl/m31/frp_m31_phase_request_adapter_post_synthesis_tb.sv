// SPDX-License-Identifier: Apache-2.0
// Compare the phase-request netlist with the unchanged RTL adapter workload.

`ifndef FRP_M31_PHASE_REQUEST_ADAPTER_POST_SYNTHESIS_TB_SV
`define FRP_M31_PHASE_REQUEST_ADAPTER_POST_SYNTHESIS_TB_SV
`include "frp_m31_phase_request_adapter_tb.sv"

module frp_m31_phase_request_adapter_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Synthesize the unmodified adapter with CELLS=8, REQUEST_LANES=2 and
  // CELL_INDEX_BITS=3; rename its top to frp_m31_phase_request_adapter_netlist.
  // The reference keeps its independent truth table and output assertions.
  frp_m31_phase_request_adapter_tb reference_test();

  typedef struct packed {
    logic [1:0] request_valid;
    logic [5:0] request_cell_index;
    logic [3:0] request_target;
  } outputs_t;

  localparam int OUTPUT_BITS = $bits(outputs_t);
  wire outputs_t reference_outputs;
  outputs_t netlist_outputs;
  bit mismatch_seen = 0;
  int unsigned comparisons = 0, enabled_checks = 0, disabled_checks = 0;
  int unsigned empty_outputs = 0, one_request_outputs = 0, two_request_outputs = 0;
  logic [7:0] lane0_cells = 0, lane1_cells = 0;

  frp_m31_phase_request_adapter_netlist u_adapter_netlist (
    .enable(reference_test.enable),
    .retained_state(reference_test.retained_state),
    .pending_route(reference_test.pending_route),
    .phase_target(reference_test.phase_target),
    .scheduler_state(reference_test.scheduler_state),
    .request_valid(netlist_outputs.request_valid),
    .request_cell_index(netlist_outputs.request_cell_index),
    .request_target(netlist_outputs.request_target)
  );

  assign reference_outputs = '{
    request_valid: reference_test.request_valid,
    request_cell_index: reference_test.request_cell_index,
    request_target: reference_test.request_target
  };

  // Sample the first vector explicitly, then every input change after cells
  // settle. Each sample precedes the reference's 1 ns assertion for that vector.
  // The observation index and final count reject skipped or repeated samples.
  initial begin : compare_settled
    if (OUTPUT_BITS != 12)
      $fatal(1, "Incomplete adapter output bundle: %0d bits", OUTPUT_BITS);
    #1fs;
    forever begin
      if (comparisons != reference_test.observations) begin
        mismatch_seen = 1;
        $fatal(1, "Adapter sampling mismatch comparisons=%0d reference_checks=%0d",
               comparisons, reference_test.observations);
      end
      if ($isunknown({reference_outputs, netlist_outputs})
          || netlist_outputs !== reference_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "Adapter post-synthesis mismatch time=%0t check=%0d enable=%b sched=%0d state=%h pending=%h target=%h reference=%h netlist=%h",
               $time, comparisons, reference_test.enable, reference_test.scheduler_state,
               reference_test.retained_state, reference_test.pending_route,
               reference_test.phase_target, reference_outputs, netlist_outputs);
      end
      comparisons++;
      if (reference_test.enable) enabled_checks++;
      else disabled_checks++;
      case (netlist_outputs.request_valid)
        2'b00: empty_outputs++;
        2'b01: one_request_outputs++;
        2'b11: two_request_outputs++;
        default: begin
          mismatch_seen = 1;
          $fatal(1, "Invalid netlist lane packing");
        end
      endcase
      if (netlist_outputs.request_valid[0])
        lane0_cells[netlist_outputs.request_cell_index[2:0]] = 1;
      if (netlist_outputs.request_valid[1])
        lane1_cells[netlist_outputs.request_cell_index[5:3]] = 1;
      @(reference_test.enable or reference_test.retained_state
        or reference_test.pending_route or reference_test.phase_target
        or reference_test.scheduler_state);
      #1fs;
    end
  end

  final begin
    if (mismatch_seen || comparisons != 13824
        || enabled_checks != 8192 || disabled_checks != 5632
        || empty_outputs != 8580 || one_request_outputs != 304
        || two_request_outputs != 4940 || lane0_cells !== 8'hff || lane1_cells !== 8'hfe)
      $fatal(1, "Incomplete adapter post-synthesis coverage comparisons=%0d enabled=%0d disabled=%0d empty=%0d one=%0d two=%0d lane0=%h lane1=%h",
             comparisons, enabled_checks, disabled_checks, empty_outputs,
             one_request_outputs, two_request_outputs, lane0_cells, lane1_cells);
    if (reference_test.observations != comparisons
        || reference_test.empty_outputs != empty_outputs
        || reference_test.one_request_outputs != one_request_outputs
        || reference_test.two_request_outputs != two_request_outputs
        || reference_test.lane0_cells !== lane0_cells || reference_test.lane1_cells !== lane1_cells
        || reference_test.matrix_cases != 6144 || reference_test.mask_cases != 2560
        || reference_test.disable_checks != 2560 || reference_test.reenable_checks != 2560)
      $fatal(1, "Incomplete phase-request adapter reference qualification");
    $display("FRP_M31_PHASE_REQUEST_ADAPTER_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d enabled_checks=%0d disabled_checks=%0d empty_outputs=%0d one_request_outputs=%0d two_request_outputs=%0d matrix_cases=%0d mask_cases=%0d disable_checks=%0d reenable_checks=%0d lane0_cells=%0d lane1_cells=%0d",
             comparisons, OUTPUT_BITS, enabled_checks, disabled_checks,
             empty_outputs, one_request_outputs, two_request_outputs,
             reference_test.matrix_cases, reference_test.mask_cases,
             reference_test.disable_checks, reference_test.reenable_checks,
             lane0_cells, lane1_cells);
  end
endmodule : frp_m31_phase_request_adapter_post_synthesis_tb
`endif

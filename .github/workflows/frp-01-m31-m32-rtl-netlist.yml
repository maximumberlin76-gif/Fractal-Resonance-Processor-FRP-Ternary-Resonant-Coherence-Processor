// SPDX-License-Identifier: Apache-2.0
// Compare three complete registered-request netlists on the unchanged RTL workload.
// Each netlist includes the target register and request adapter; all 12 outputs
// are compared after zero-delay cells settle, including live downstream inputs.

`ifndef FRP_M32_REGISTERED_REQUEST_POST_SYNTHESIS_TB_SV
`define FRP_M32_REGISTERED_REQUEST_POST_SYNTHESIS_TB_SV
`include "frp_m32_registered_request_tb.sv"

module frp_m32_registered_request_netlist_check #(
  parameter int CELLS = 8, parameter int LANES = 2,
  parameter int COUNTER_BITS = 32,
  parameter int INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS)
) (
  input wire clk, rst_n, tick_enable, clear_counters, phase_target_valid,
  input wire [2*CELLS-1:0] phase_target_source,
  input wire auto_target_enable,
  input wire [2*CELLS-1:0] retained_state, pending_route,
  input wire [2:0] scheduler_state,
  input wire [2*CELLS+6+2*COUNTER_BITS+LANES*(INDEX_BITS+3)-1:0] reference_outputs
);
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 2*CELLS + 6 + 2*COUNTER_BITS + LANES*(INDEX_BITS+3);
  localparam int CONTROL_BITS = 6*CELLS + 7;
  localparam int MATRIX_CASES = 18432*CELLS;
  localparam int MASK_CASES = 10*(1 << CELLS);
  localparam int PRESSURE = (COUNTER_BITS <= 8) ? (1 << COUNTER_BITS)+3 : 260;
  localparam int STEPS = 1043 + 2*MATRIX_CASES + MASK_CASES + 2*PRESSURE;
  // Independently enumerated settled stimulus events, including coalesced
  // control changes and repeated identical inputs on successive clock edges.
  localparam int EXPECTED_COMPARISONS = (CELLS == 1) ? 114839 :
                                         ((COUNTER_BITS == 3) ? 900227 : 901721);
  localparam int EXPECTED_INPUT_CHANGES = (CELLS == 1) ? 37421 :
                                           ((COUNTER_BITS == 3) ? 301609 : 302107);
  wire [2*CELLS-1:0] registered_target_q;
  wire registered_target_valid_q, phase_target_domain_valid, registered_target_domain_valid;
  wire capture_accepted, capture_rejected, registered_request_enable;
  wire [COUNTER_BITS-1:0] accepted_capture_events_q, rejected_capture_events_q;
  wire [LANES-1:0] phase_request_valid;
  wire [LANES*INDEX_BITS-1:0] phase_request_cell_index;
  wire [2*LANES-1:0] phase_request_target;
  wire [OUTPUT_BITS-1:0] netlist_outputs;
  wire [CONTROL_BITS-1:0] controls;

  // Synthesize and flatten the unmodified frp_m32_registered_target_request_path
  // for (CELLS, REQUEST_LANES, COUNTER_BITS) = (1,1,1), (8,2,3), (8,2,32).
  // Rename each synthesized top as below and retain every public port name.
  generate
    if (CELLS == 1 && LANES == 1 && COUNTER_BITS == 1 && INDEX_BITS == 1) begin : single
      frp_m32_registered_request_1_1_1_netlist u_path (.*);
    end else if (CELLS == 8 && LANES == 2 && COUNTER_BITS == 3 && INDEX_BITS == 3) begin : width3
      frp_m32_registered_request_8_2_3_netlist u_path (.*);
    end else if (CELLS == 8 && LANES == 2 && COUNTER_BITS == 32 && INDEX_BITS == 3) begin : wide
      frp_m32_registered_request_8_2_32_netlist u_path (.*);
    end else begin : unsupported
      initial $fatal(1, "Unsupported registered request netlist cells=%0d lanes=%0d bits=%0d index_bits=%0d",
                     CELLS, LANES, COUNTER_BITS, INDEX_BITS);
    end
  endgenerate

  assign netlist_outputs = {
    registered_target_q, registered_target_valid_q, phase_target_domain_valid,
    registered_target_domain_valid, capture_accepted, capture_rejected,
    accepted_capture_events_q, rejected_capture_events_q, registered_request_enable,
    phase_request_valid, phase_request_cell_index, phase_request_target
  };
  assign controls = {phase_target_source, retained_state, pending_route,
                     scheduler_state, auto_target_enable, phase_target_valid,
                     tick_enable, clear_counters};

  bit armed = 0, mismatch_seen = 0;
  bit previous_clk = 0, previous_rst_n = 1;
  logic [CONTROL_BITS-1:0] previous_controls = '0;
  logic [CELLS-1:0] lane0_cells = '0, lane1_cells = '0;
  int unsigned comparisons = 0, input_changes = 0;
  int unsigned enabled_edges = 0, hold_edges = 0, falling_edges = 0;
  int unsigned accepted_edges = 0, rejected_edges = 0, auto_disabled_capture_edges = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0, reset_releases = 0;
  int unsigned clear_tick_edges = 0, clear_hold_edges = 0;
  int unsigned empty_outputs = 0, one_request_outputs = 0, two_request_outputs = 0;
  int unsigned request_enabled_checks = 0, upstream_independent_checks = 0;

  // Sample once after initialization, then on every input event and both clock
  // edges after netlist settling, before the reference's 1 ns assertions.
  // The explicit first sample also checks reset before the first clock edge.
  // This also observes requests from a saved target while its source is invalid,
  // absent or unticked, and while retained state, pending routes or modes change.
  always begin : compare_events
    bit rising_edge, falling_edge, reset_assertion, reset_release, controls_changed;
    #1fs;
    rising_edge = !previous_clk && clk;
    falling_edge = previous_clk && !clk;
    reset_assertion = previous_rst_n && !rst_n;
    reset_release = !previous_rst_n && rst_n;
    controls_changed = previous_controls != controls;
    previous_clk = clk;
    previous_rst_n = rst_n;
    previous_controls = controls;
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs})
          || netlist_outputs !== reference_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "Registered request post-synthesis mismatch cells=%0d lanes=%0d bits=%0d time=%0t check=%0d source=%h retained=%h pending=%h scheduler=%0d valid=%b tick=%b clear=%b auto=%b reset_n=%b reference=%h netlist=%h",
               CELLS, LANES, COUNTER_BITS, $time, comparisons, phase_target_source,
               retained_state, pending_route, scheduler_state, phase_target_valid,
               tick_enable, clear_counters, auto_target_enable, rst_n,
               reference_outputs, netlist_outputs);
      end
      comparisons++;
      if (controls_changed) input_changes++;
      if (reset_assertion) reset_assertions++;
      if (reset_release) reset_releases++;
      if (falling_edge) falling_edges++;
      if (rising_edge) begin
        if (!rst_n) reset_clock_edges++;
        else begin
          if (tick_enable) enabled_edges++;
          else hold_edges++;
          if (capture_accepted) accepted_edges++;
          if (capture_rejected) rejected_edges++;
          if (capture_accepted && !auto_target_enable) auto_disabled_capture_edges++;
          if (clear_counters) begin
            if (tick_enable) clear_tick_edges++;
            else clear_hold_edges++;
          end
        end
      end
      if (registered_request_enable) begin
        request_enabled_checks++;
        if (!phase_target_valid || !tick_enable || !phase_target_domain_valid)
          upstream_independent_checks++;
      end
      case ($countones(phase_request_valid))
        0: empty_outputs++;
        1: one_request_outputs++;
        2: two_request_outputs++;
        default: $fatal(1, "Unsupported registered request lane count");
      endcase
      for (int lane = 0; lane < LANES; lane++)
        if (phase_request_valid[lane]) begin
          if (int'(phase_request_cell_index[lane*INDEX_BITS +: INDEX_BITS]) >= CELLS)
            $fatal(1, "Registered request cell index out of bounds");
          if (lane == 0) lane0_cells[phase_request_cell_index[lane*INDEX_BITS +: INDEX_BITS]] = 1;
          if (lane == 1) lane1_cells[phase_request_cell_index[lane*INDEX_BITS +: INDEX_BITS]] = 1;
        end
    end
    @(clk or rst_n or tick_enable or clear_counters or phase_target_valid
      or phase_target_source or auto_target_enable or retained_state
      or pending_route or scheduler_state);
  end

  task automatic check_coverage;
    if (!armed || mismatch_seen || comparisons != EXPECTED_COMPARISONS
        || input_changes != EXPECTED_INPUT_CHANGES
        || enabled_edges != 786 + 3*MATRIX_CASES/2 + MASK_CASES + 2*PRESSURE
        || hold_edges != 257 + MATRIX_CASES/2 || falling_edges != STEPS + 514
        || accepted_edges != 610 + 19*MATRIX_CASES/16 + MASK_CASES + PRESSURE
        || rejected_edges != 32 + MATRIX_CASES/16 + PRESSURE
        || auto_disabled_capture_edges != 48 + 35*MATRIX_CASES/32
        || reset_assertions != 514 || reset_clock_edges != 514 || reset_releases != 514
        || clear_tick_edges != 130 + 5*MATRIX_CASES/4 + MASK_CASES
        || clear_hold_edges != 129 + MATRIX_CASES/4
        || request_enabled_checks == 0 || upstream_independent_checks == 0
        || empty_outputs == 0 || one_request_outputs == 0
        || empty_outputs + one_request_outputs + two_request_outputs != comparisons
        || ((LANES == 1) ? (two_request_outputs != 0) : (two_request_outputs == 0))
        || lane0_cells !== {CELLS{1'b1}}
        || lane1_cells !== ((LANES == 1) ? CELLS'(0) : ({CELLS{1'b1}} ^ CELLS'(1))))
      $fatal(1, "Incomplete registered request post-synthesis coverage cells=%0d lanes=%0d bits=%0d comparisons=%0d inputs=%0d enabled=%0d held=%0d falling=%0d accepted=%0d rejected=%0d auto_disabled_capture=%0d resets=%0d reset_clocks=%0d releases=%0d clear_tick=%0d clear_hold=%0d",
             CELLS, LANES, COUNTER_BITS, comparisons, input_changes, enabled_edges,
             hold_edges, falling_edges, accepted_edges, rejected_edges,
             auto_disabled_capture_edges, reset_assertions, reset_clock_edges,
             reset_releases, clear_tick_edges, clear_hold_edges);
  endtask

  task automatic print_result;
    $display("FRP_M32_REGISTERED_REQUEST_POST_SYNTHESIS_PROFILE: PASS cells=%0d lanes=%0d counter_bits=%0d output_bits=%0d comparisons=%0d input_changes=%0d enabled_edges=%0d hold_edges=%0d falling_edges=%0d accepted_edges=%0d rejected_edges=%0d auto_disabled_capture_edges=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d clear_tick_edges=%0d clear_hold_edges=%0d request_enabled_checks=%0d upstream_independent_checks=%0d empty_outputs=%0d one_request_outputs=%0d two_request_outputs=%0d lane0_cells=%0d lane1_cells=%0d",
             CELLS, LANES, COUNTER_BITS, OUTPUT_BITS, comparisons, input_changes,
             enabled_edges, hold_edges, falling_edges, accepted_edges, rejected_edges,
             auto_disabled_capture_edges, reset_assertions, reset_clock_edges,
             reset_releases, clear_tick_edges, clear_hold_edges, request_enabled_checks,
             upstream_independent_checks, empty_outputs, one_request_outputs,
             two_request_outputs, lane0_cells, lane1_cells);
  endtask
endmodule : frp_m32_registered_request_netlist_check

module frp_m32_registered_request_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Keep the independent RTL scoreboard, all stimuli and the watchdog intact.
  // Its four result records must match the standalone RTL regression exactly.
  frp_m32_registered_request_tb reference_test();

  `define FRP_REGISTERED_REQUEST_CHECK_INPUTS(test_case) \
    .clk(test_case.clk), .rst_n(test_case.rst_n), \
    .tick_enable(test_case.tick_enable), .clear_counters(test_case.clear_counters), \
    .phase_target_valid(test_case.phase_target_valid), \
    .phase_target_source(test_case.phase_target_source), \
    .auto_target_enable(test_case.auto_target_enable), \
    .retained_state(test_case.retained_state), .pending_route(test_case.pending_route), \
    .scheduler_state(test_case.scheduler_state), \
    .reference_outputs({test_case.registered_target_q, test_case.registered_target_valid_q, \
      test_case.phase_target_domain_valid, test_case.registered_target_domain_valid, \
      test_case.capture_accepted, test_case.capture_rejected, \
      test_case.accepted_capture_events_q, test_case.rejected_capture_events_q, \
      test_case.registered_request_enable, test_case.phase_request_valid, \
      test_case.phase_request_cell_index, test_case.phase_request_target})

  frp_m32_registered_request_netlist_check #(.CELLS(1), .LANES(1), .COUNTER_BITS(1)) single (
    `FRP_REGISTERED_REQUEST_CHECK_INPUTS(reference_test.single_cell)
  );
  frp_m32_registered_request_netlist_check #(.COUNTER_BITS(3)) width3 (
    `FRP_REGISTERED_REQUEST_CHECK_INPUTS(reference_test.small_counter)
  );
  frp_m32_registered_request_netlist_check #(.COUNTER_BITS(32)) wide (
    `FRP_REGISTERED_REQUEST_CHECK_INPUTS(reference_test.wide_counter)
  );
  `undef FRP_REGISTERED_REQUEST_CHECK_INPUTS

  final begin
    if (!reference_test.single_cell.done || !reference_test.small_counter.done
        || !reference_test.wide_counter.done
        || reference_test.single_cell.observations != 115927
        || reference_test.small_counter.observations != 905347
        || reference_test.wide_counter.observations != 906841)
      $fatal(1, "Incomplete registered request reference qualification");
    single.check_coverage();
    width3.check_coverage();
    wide.check_coverage();
    single.print_result();
    width3.print_result();
    wide.print_result();
    $display("FRP_M32_REGISTERED_REQUEST_POST_SYNTHESIS_TB: PASS profiles=3 comparisons=%0d output_bits=%0d reference_observations=%0d matrix_cases=%0d mask_cases=%0d reset_cases=%0d pressure_events=%0d scheduler_samples=%0d",
             single.comparisons + width3.comparisons + wide.comparisons,
             $bits(single.netlist_outputs) + $bits(width3.netlist_outputs) + $bits(wide.netlist_outputs),
             reference_test.single_cell.observations + reference_test.small_counter.observations
               + reference_test.wide_counter.observations,
             reference_test.single_cell.matrix_cases + reference_test.small_counter.matrix_cases
               + reference_test.wide_counter.matrix_cases,
             reference_test.single_cell.mask_cases + reference_test.small_counter.mask_cases
               + reference_test.wide_counter.mask_cases,
             reference_test.single_cell.reset_cases + reference_test.small_counter.reset_cases
               + reference_test.wide_counter.reset_cases,
             reference_test.single_cell.pressure_events + reference_test.small_counter.pressure_events
               + reference_test.wide_counter.pressure_events,
             reference_test.single_cell.scheduler_samples + reference_test.small_counter.scheduler_samples
               + reference_test.wide_counter.scheduler_samples);
  end
endmodule : frp_m32_registered_request_post_synthesis_tb
`endif

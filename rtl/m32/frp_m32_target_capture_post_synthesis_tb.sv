// SPDX-License-Identifier: Apache-2.0
// Compare four target-boundary netlists with the unchanged RTL workload.
// This checks zero-delay functional behavior, not implementation timing.

`ifndef FRP_M32_TARGET_CAPTURE_POST_SYNTHESIS_TB_SV
`define FRP_M32_TARGET_CAPTURE_POST_SYNTHESIS_TB_SV
`include "frp_m32_target_capture_tb.sv"

module frp_m32_target_capture_netlist_check #(
  parameter int CELLS = 8, parameter int COUNTER_BITS = 32
) (
  input wire clk, rst_n, tick_enable, clear_counters, phase_target_valid,
  input wire [2*CELLS-1:0] phase_target,
  input wire [2*CELLS+2*COUNTER_BITS+4:0] reference_outputs
);
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 2*CELLS + 5 + 2*COUNTER_BITS;
  localparam int SOURCE_WORDS = 1 << (2*CELLS);
  localparam int VALID_WORDS = 3 ** CELLS;
  localparam int PRESSURE = (COUNTER_BITS <= 8) ? (1 << COUNTER_BITS) + 3 : 260;
  localparam int STEPS = 16*SOURCE_WORDS + 2*PRESSURE + 55;
  wire [2*CELLS-1:0] registered_target_q;
  wire registered_target_valid_q, phase_target_domain_valid;
  wire registered_target_domain_valid, capture_accepted, capture_rejected;
  wire [COUNTER_BITS-1:0] accepted_capture_events_q, rejected_capture_events_q;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  // Synthesize the unmodified frp_m32_registered_target_boundary separately
  // for (CELLS, COUNTER_BITS) = (1,1), (8,3), (8,8), (8,32).
  // Rename each synthesized top as below; retain its public port names.
  generate
    if (CELLS == 1 && COUNTER_BITS == 1) begin : single
      frp_m32_target_capture_1_1_netlist u_boundary (.*);
    end else if (CELLS == 8 && COUNTER_BITS == 3) begin : width3
      frp_m32_target_capture_8_3_netlist u_boundary (.*);
    end else if (CELLS == 8 && COUNTER_BITS == 8) begin : width8
      frp_m32_target_capture_8_8_netlist u_boundary (.*);
    end else if (CELLS == 8 && COUNTER_BITS == 32) begin : width32
      frp_m32_target_capture_8_32_netlist u_boundary (.*);
    end else begin : unsupported
      initial $fatal(1, "Unsupported target capture netlist cells=%0d bits=%0d",
                     CELLS, COUNTER_BITS);
    end
  endgenerate

  // Match the reference's outputs_t exactly: all eight public output ports.
  assign netlist_outputs = {
    registered_target_q, registered_target_valid_q,
    phase_target_domain_valid, registered_target_domain_valid,
    capture_accepted, capture_rejected,
    accepted_capture_events_q, rejected_capture_events_q
  };

  bit armed = 0, mismatch_seen = 0;
  bit previous_clk = 0, previous_rst_n = 1;
  logic [2*CELLS+2:0] previous_controls = '0;
  int unsigned comparisons = 0, enabled_edges = 0, hold_edges = 0;
  int unsigned accepted_edges = 0, rejected_edges = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0, reset_releases = 0;
  int unsigned falling_edges = 0, input_changes = 0;
  int unsigned clear_tick_edges = 0, clear_hold_edges = 0;
  int unsigned clear_accepts = 0, clear_rejects = 0;

  // Start at the first asynchronous reset. Settle zero-delay cells before
  // comparing, ahead of the reference's 1 ns checks. Clock comparisons also
  // cover repeated identical inputs, including natural counter saturation.
  always @(clk or rst_n or tick_enable or clear_counters
           or phase_target_valid or phase_target) begin
    bit rising_edge, falling_edge, reset_assertion, reset_release, controls_changed;
    #1fs;
    rising_edge = !previous_clk && clk;
    falling_edge = previous_clk && !clk;
    reset_assertion = previous_rst_n && !rst_n;
    reset_release = !previous_rst_n && rst_n;
    controls_changed = previous_controls !=
      {phase_target, phase_target_valid, tick_enable, clear_counters};
    previous_clk = clk;
    previous_rst_n = rst_n;
    previous_controls = {phase_target, phase_target_valid, tick_enable, clear_counters};
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs})
          || netlist_outputs !== reference_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "Target capture post-synthesis mismatch cells=%0d bits=%0d time=%0t check=%0d source=%h valid=%b tick=%b clear=%b reset_n=%b reference=%h netlist=%h",
               CELLS, COUNTER_BITS, $time, comparisons, phase_target,
               phase_target_valid, tick_enable, clear_counters, rst_n,
               reference_outputs, netlist_outputs);
      end
      comparisons++;
      if (reset_assertion) reset_assertions++;
      if (reset_release) reset_releases++;
      if (falling_edge) falling_edges++;
      if (controls_changed) input_changes++;
      if (rising_edge) begin
        if (!rst_n) reset_clock_edges++;
        else begin
          if (tick_enable) enabled_edges++;
          else hold_edges++;
          if (capture_accepted) accepted_edges++;
          if (capture_rejected) rejected_edges++;
          if (clear_counters) begin
            if (tick_enable) clear_tick_edges++;
            else clear_hold_edges++;
            if (capture_accepted) clear_accepts++;
            if (capture_rejected) clear_rejects++;
          end
        end
      end
    end
  end

  task automatic check_coverage;
    // Exact stimulus event counts, independently enumerated per profile.
    // Reset does not gate combinational capture diagnostics; only released
    // rising edges contribute to the accepted/rejected/clear edge counts.
    if (!armed || mismatch_seen
        || comparisons != 48*SOURCE_WORDS + 5*PRESSURE + 238
        || input_changes != 16*SOURCE_WORDS + PRESSURE + 56
        || enabled_edges != 12*SOURCE_WORDS + 2*PRESSURE + 44
        || hold_edges != 4*SOURCE_WORDS + 11
        || accepted_edges != 8*SOURCE_WORDS + 2*VALID_WORDS + PRESSURE + 20
        || rejected_edges != 2*(SOURCE_WORDS - VALID_WORDS) + PRESSURE + 19
        || reset_assertions != 18 || reset_clock_edges != 18
        || reset_releases != 18 || falling_edges != STEPS + 18
        || clear_tick_edges != 2*SOURCE_WORDS + 6
        || clear_hold_edges != 2*SOURCE_WORDS + 6
        || clear_accepts != VALID_WORDS + 2
        || clear_rejects != SOURCE_WORDS - VALID_WORDS + 2)
      $fatal(1, "Incomplete target capture post-synthesis coverage cells=%0d bits=%0d comparisons=%0d inputs=%0d enabled=%0d held=%0d accepted=%0d rejected=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d falling_edges=%0d clear_tick=%0d clear_hold=%0d clear_accepts=%0d clear_rejects=%0d",
             CELLS, COUNTER_BITS, comparisons, input_changes, enabled_edges,
             hold_edges, accepted_edges, rejected_edges, reset_assertions,
             reset_clock_edges, reset_releases, falling_edges,
             clear_tick_edges, clear_hold_edges, clear_accepts, clear_rejects);
  endtask

  task automatic print_result;
    $display("FRP_M32_TARGET_CAPTURE_POST_SYNTHESIS_PROFILE: PASS cells=%0d counter_bits=%0d output_bits=%0d comparisons=%0d enabled_edges=%0d hold_edges=%0d accepted_edges=%0d rejected_edges=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d falling_edges=%0d input_changes=%0d clear_tick_edges=%0d clear_hold_edges=%0d clear_accepts=%0d clear_rejects=%0d",
             CELLS, COUNTER_BITS, OUTPUT_BITS, comparisons, enabled_edges,
             hold_edges, accepted_edges, rejected_edges, reset_assertions,
             reset_clock_edges, reset_releases, falling_edges, input_changes,
             clear_tick_edges, clear_hold_edges, clear_accepts, clear_rejects);
  endtask
endmodule : frp_m32_target_capture_netlist_check

module frp_m32_target_capture_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Reuse every stimulus, independent oracle, assertion and watchdog without
  // editing the RTL test. Its five result records must remain unchanged.
  frp_m32_target_capture_tb reference_test();

  frp_m32_target_capture_netlist_check #(.CELLS(1), .COUNTER_BITS(1)) single (
    .clk(reference_test.single.clk),
    .rst_n(reference_test.single.rst_n),
    .tick_enable(reference_test.single.tick_enable),
    .clear_counters(reference_test.single.clear_counters),
    .phase_target_valid(reference_test.single.phase_target_valid),
    .phase_target(reference_test.single.phase_target),
    .reference_outputs(reference_test.single.actual)
  );
  frp_m32_target_capture_netlist_check #(.COUNTER_BITS(3)) width3 (
    .clk(reference_test.width3.clk),
    .rst_n(reference_test.width3.rst_n),
    .tick_enable(reference_test.width3.tick_enable),
    .clear_counters(reference_test.width3.clear_counters),
    .phase_target_valid(reference_test.width3.phase_target_valid),
    .phase_target(reference_test.width3.phase_target),
    .reference_outputs(reference_test.width3.actual)
  );
  frp_m32_target_capture_netlist_check #(.COUNTER_BITS(8)) width8 (
    .clk(reference_test.width8.clk),
    .rst_n(reference_test.width8.rst_n),
    .tick_enable(reference_test.width8.tick_enable),
    .clear_counters(reference_test.width8.clear_counters),
    .phase_target_valid(reference_test.width8.phase_target_valid),
    .phase_target(reference_test.width8.phase_target),
    .reference_outputs(reference_test.width8.actual)
  );
  frp_m32_target_capture_netlist_check #(.COUNTER_BITS(32)) width32 (
    .clk(reference_test.width32.clk),
    .rst_n(reference_test.width32.rst_n),
    .tick_enable(reference_test.width32.tick_enable),
    .clear_counters(reference_test.width32.clear_counters),
    .phase_target_valid(reference_test.width32.phase_target_valid),
    .phase_target(reference_test.width32.phase_target),
    .reference_outputs(reference_test.width32.actual)
  );

  final begin
    if (!reference_test.single.done || !reference_test.width3.done
        || !reference_test.width8.done || !reference_test.width32.done
        || reference_test.single.observations != 459
        || reference_test.width3.observations != 3146031
        || reference_test.width8.observations != 3147519
        || reference_test.width32.observations != 3147525)
      $fatal(1, "Incomplete target capture reference qualification");
    single.check_coverage();
    width3.check_coverage();
    width8.check_coverage();
    width32.check_coverage();
    single.print_result();
    width3.print_result();
    width8.print_result();
    width32.print_result();
    $display("FRP_M32_TARGET_CAPTURE_POST_SYNTHESIS_TB: PASS profiles=4 comparisons=%0d output_bits=%0d reference_observations=%0d matrix_cases=%0d reset_cases=%0d pressure_events=%0d",
             single.comparisons + width3.comparisons + width8.comparisons
               + width32.comparisons,
             $bits(single.netlist_outputs) + $bits(width3.netlist_outputs)
               + $bits(width8.netlist_outputs) + $bits(width32.netlist_outputs),
             reference_test.single.observations + reference_test.width3.observations
               + reference_test.width8.observations + reference_test.width32.observations,
             reference_test.single.matrix_cases + reference_test.width3.matrix_cases
               + reference_test.width8.matrix_cases + reference_test.width32.matrix_cases,
             reference_test.single.reset_cases + reference_test.width3.reset_cases
               + reference_test.width8.reset_cases + reference_test.width32.reset_cases,
             2*(reference_test.single.PRESSURE + reference_test.width3.PRESSURE
                + reference_test.width8.PRESSURE + reference_test.width32.PRESSURE));
  end
endmodule : frp_m32_target_capture_post_synthesis_tb
`endif

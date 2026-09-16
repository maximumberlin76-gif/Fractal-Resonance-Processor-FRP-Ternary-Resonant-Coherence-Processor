// SPDX-License-Identifier: Apache-2.0
// Compare three scheduler netlists with the unchanged RTL control workload.

`ifndef FRP_M31_SCHEDULER_CONTROL_POST_SYNTHESIS_TB_SV
`define FRP_M31_SCHEDULER_CONTROL_POST_SYNTHESIS_TB_SV
`include "frp_m31_scheduler_control_tb.sv"

module frp_m31_scheduler_control_netlist_check #(
  parameter int COUNTER_BITS = 32
) (
  input wire clk, rst_n, tick_enable, clear_counters,
  input wire [1:0] scheduler_mode,
  input wire [7*COUNTER_BITS+16:0] reference_outputs
);
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 7*COUNTER_BITS + 17;
  wire [1:0] scheduler_mode_q;
  wire [2:0] scheduler_state_q, period_index_q;
  wire [COUNTER_BITS-1:0] tick_index_q, ticks_recorded_q;
  wire [COUNTER_BITS-1:0] scheduler_count_free_q, scheduler_count_balance_q;
  wire [COUNTER_BITS-1:0] scheduler_count_commit_q, scheduler_count_excite_q;
  wire [COUNTER_BITS-1:0] scheduler_count_neutralize_q;
  wire free_enable, balance_enable, commit_enable, excite_enable, neutralize_enable;
  wire scheduler_mode_reserved, scheduler_state_reserved;
  wire scheduler_valid, scheduler_counts_valid;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  // Synthesize the unmodified frp_m31_scheduler three times, with
  // COUNTER_BITS=3, 8 and 32; rename the tops as shown below.
  // Every netlist port connects by its original public interface name.
  generate
    if (COUNTER_BITS == 3) begin : width3
      frp_m31_scheduler_3_netlist u_scheduler (.*);
    end else if (COUNTER_BITS == 8) begin : width8
      frp_m31_scheduler_8_netlist u_scheduler (.*);
    end else if (COUNTER_BITS == 32) begin : width32
      frp_m31_scheduler_32_netlist u_scheduler (.*);
    end else begin : unsupported
      initial $fatal(1, "Unsupported scheduler netlist width: %0d", COUNTER_BITS);
    end
  endgenerate

  // Match the reference's packed outputs_t: all 19 public output ports.
  // The five counters and five enables are packed from index 4 down to 0.
  assign netlist_outputs = {
    scheduler_mode_q, scheduler_state_q, tick_index_q, period_index_q,
    ticks_recorded_q, scheduler_count_neutralize_q, scheduler_count_excite_q,
    scheduler_count_commit_q, scheduler_count_balance_q, scheduler_count_free_q,
    neutralize_enable, excite_enable, commit_enable, balance_enable, free_enable,
    scheduler_mode_reserved, scheduler_state_reserved,
    scheduler_valid, scheduler_counts_valid
  };

  bit armed = 0, mismatch_seen = 0;
  bit previous_clk = 0, previous_rst_n = 1;
  logic [3:0] previous_controls = '0;
  int unsigned comparisons = 0, enabled_edges = 0, hold_edges = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0, reset_releases = 0;
  int unsigned falling_edges = 0, clear_tick_edges = 0, clear_hold_edges = 0;
  int unsigned input_changes = 0;

  // Start at the first asynchronous reset. Sample every clock, reset or
  // control change after zero-delay cells settle, before the reference's
  // 1 ns assertions. Consecutive identical controls still get both clock
  // edge comparisons; combinational enables are checked between ticks.
  always @(clk or rst_n or tick_enable or clear_counters or scheduler_mode) begin
    bit rising_edge, falling_edge, reset_assertion, reset_release, controls_changed;
    #1fs;
    rising_edge = !previous_clk && clk;
    falling_edge = previous_clk && !clk;
    reset_assertion = previous_rst_n && !rst_n;
    reset_release = !previous_rst_n && rst_n;
    controls_changed = previous_controls != {scheduler_mode, tick_enable, clear_counters};
    previous_clk = clk;
    previous_rst_n = rst_n;
    previous_controls = {scheduler_mode, tick_enable, clear_counters};
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs})
          || netlist_outputs !== reference_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "Scheduler post-synthesis mismatch bits=%0d time=%0t check=%0d input_mode=%0d tick=%b clear=%b reset_n=%b reference=%h netlist=%h",
               COUNTER_BITS, $time, comparisons, scheduler_mode, tick_enable,
               clear_counters, rst_n, reference_outputs, netlist_outputs);
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
          if (clear_counters) begin
            if (tick_enable) clear_tick_edges++;
            else clear_hold_edges++;
          end
        end
      end
    end
  end

  task automatic check_coverage;
    // Exact event counts for the committed control workload, per width.
    if (!armed || mismatch_seen || comparisons != 13533
        || enabled_edges != 3604 || hold_edges != 983
        || reset_assertions != 534 || reset_clock_edges != 534
        || reset_releases != 534 || falling_edges != 5121
        || clear_tick_edges != 138 || clear_hold_edges != 138
        || input_changes != 2223)
      $fatal(1, "Incomplete scheduler post-synthesis coverage bits=%0d comparisons=%0d enabled=%0d held=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d falling_edges=%0d clear_tick_edges=%0d clear_hold_edges=%0d input_changes=%0d",
             COUNTER_BITS, comparisons, enabled_edges, hold_edges, reset_assertions,
             reset_clock_edges, reset_releases, falling_edges,
             clear_tick_edges, clear_hold_edges, input_changes);
  endtask

  task automatic print_result;
    $display("FRP_M31_SCHEDULER_CONTROL_POST_SYNTHESIS_PROFILE: PASS counter_bits=%0d output_bits=%0d comparisons=%0d enabled_edges=%0d hold_edges=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d falling_edges=%0d clear_tick_edges=%0d clear_hold_edges=%0d input_changes=%0d",
             COUNTER_BITS, OUTPUT_BITS, comparisons, enabled_edges, hold_edges,
             reset_assertions, reset_clock_edges, reset_releases, falling_edges,
             clear_tick_edges, clear_hold_edges, input_changes);
  endtask
endmodule : frp_m31_scheduler_control_netlist_check

module frp_m31_scheduler_control_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Keep the independent cadence table, wide counter model, coverage checks
  // and watchdog in the original test. Its four result records are unchanged.
  frp_m31_scheduler_control_tb reference_test();

  frp_m31_scheduler_control_netlist_check #(.COUNTER_BITS(3)) width3 (
    .clk(reference_test.width3.clk),
    .rst_n(reference_test.width3.rst_n),
    .tick_enable(reference_test.width3.tick_enable),
    .clear_counters(reference_test.width3.clear_counters),
    .scheduler_mode(reference_test.width3.scheduler_mode),
    .reference_outputs(reference_test.width3.actual)
  );
  frp_m31_scheduler_control_netlist_check #(.COUNTER_BITS(8)) width8 (
    .clk(reference_test.width8.clk),
    .rst_n(reference_test.width8.rst_n),
    .tick_enable(reference_test.width8.tick_enable),
    .clear_counters(reference_test.width8.clear_counters),
    .scheduler_mode(reference_test.width8.scheduler_mode),
    .reference_outputs(reference_test.width8.actual)
  );
  frp_m31_scheduler_control_netlist_check #(.COUNTER_BITS(32)) width32 (
    .clk(reference_test.width32.clk),
    .rst_n(reference_test.width32.rst_n),
    .tick_enable(reference_test.width32.tick_enable),
    .clear_counters(reference_test.width32.clear_counters),
    .scheduler_mode(reference_test.width32.scheduler_mode),
    .reference_outputs(reference_test.width32.actual)
  );

  final begin
    if (!reference_test.width3.done || !reference_test.width8.done
        || !reference_test.width32.done
        || reference_test.width3.observations != 15897
        || reference_test.width8.observations != 15897
        || reference_test.width32.observations != 15897)
      $fatal(1, "Incomplete scheduler control reference qualification");
    width3.check_coverage();
    width8.check_coverage();
    width32.check_coverage();
    width3.print_result();
    width8.print_result();
    width32.print_result();
    $display("FRP_M31_SCHEDULER_CONTROL_POST_SYNTHESIS_TB: PASS profiles=3 comparisons=%0d output_bits=%0d reference_observations=%0d matrix_cases=%0d steady_ticks=%0d recovery_cases=%0d",
             width3.comparisons + width8.comparisons + width32.comparisons,
             $bits(width3.netlist_outputs) + $bits(width8.netlist_outputs)
               + $bits(width32.netlist_outputs),
             reference_test.width3.observations + reference_test.width8.observations
               + reference_test.width32.observations,
             reference_test.width3.matrix_cases + reference_test.width8.matrix_cases
               + reference_test.width32.matrix_cases,
             reference_test.width3.steady_ticks + reference_test.width8.steady_ticks
               + reference_test.width32.steady_ticks,
             reference_test.width3.recovery_cases + reference_test.width8.recovery_cases
               + reference_test.width32.recovery_cases);
  end
endmodule : frp_m31_scheduler_control_post_synthesis_tb
`endif

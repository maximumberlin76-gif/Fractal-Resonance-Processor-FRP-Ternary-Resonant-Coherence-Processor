 // SPDX-License-Identifier: Apache-2.0
 // FRP M31 signed-frequency range equivalence after synthesis.
 // Author: Alchimist

`ifndef FRP_M31_FREQUENCY_RANGE_POST_SYNTHESIS_TB_SV
`define FRP_M31_FREQUENCY_RANGE_POST_SYNTHESIS_TB_SV
`include "frp_m31_frequency_range_tb.sv"

module frp_m31_frequency_range_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 1168;
  localparam int CELLS = 8;
  localparam int BATCHES_PER_STATE = 18;

  // Compile with the independently synthesized and renamed eight-cell
  // phase engine: frp_m31_phase_interference_netlist.
  // The reference retains all 144 independent fixed vectors in each of
  // the five scheduler states, plus load, hold and reset checks.
  frp_m31_frequency_range_tb reference_test();

  logic [255:0] net_phase, net_frequency, net_coupling, net_projection;
  logic [15:0] net_target;
  logic signed [31:0] net_pair, net_cluster, net_global, net_dispersion;
  wire [OUTPUT_BITS-1:0] reference_outputs;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  bit armed = 0;
  bit previous_clk = 0;
  bit previous_rst_n = 1;
  int unsigned comparisons = 0, tick_comparisons = 0, hold_comparisons = 0;
  int unsigned load_comparisons = 0, reset_assertions = 0, reset_clock_edges = 0;
  int unsigned state_ticks [0:4] = '{default: 0};
  int unsigned state_loads [0:4] = '{default: 0};

  frp_m31_phase_interference_netlist u_phase_netlist (
    .clk(reference_test.clk),
    .rst_n(reference_test.rst_n),
    .tick_enable(reference_test.tick_enable),
    .load_valid(reference_test.load_valid),
    .phase_load(reference_test.phase_load),
    .frequency_load_q16(reference_test.frequency_load_q16),
    .gamma_effective_word(reference_test.gamma_effective_word),
    .thermal_node_factor_q30(reference_test.thermal_node_factor_q30),
    .retained_state(reference_test.retained_state),
    .switch_activity(reference_test.switch_activity),
    .scheduler_state(reference_test.scheduler_state),
    .phase_word_q(net_phase),
    .frequency_current_q16(net_frequency),
    .coupling_field_q16(net_coupling),
    .phase_projection_q30(net_projection),
    .phase_target(net_target),
    .pair_coherence_q30(net_pair),
    .cluster_coherence_q30(net_cluster),
    .global_coherence_q30(net_global),
    .organization_dispersion_q30(net_dispersion)
  );

  // Compare every output, including combinational ports left unconnected
  // by the original frequency-memory regression.
  assign reference_outputs = {
    reference_test.phase_word_q,
    reference_test.frequency_current_q16,
    reference_test.dut.coupling_field_q16,
    reference_test.dut.phase_projection_q30,
    reference_test.dut.phase_target,
    reference_test.dut.pair_coherence_q30,
    reference_test.dut.cluster_coherence_q30,
    reference_test.dut.global_coherence_q30,
    reference_test.dut.organization_dispersion_q30
  };
  assign netlist_outputs = {
    net_phase, net_frequency, net_coupling, net_projection, net_target,
    net_pair, net_cluster, net_global, net_dispersion
  };

  // Settle zero-delay cells before comparison, ahead of the reference's
  // 1 ps checks. Scheduler inputs are driven on falling clock edges.
  always @(reference_test.clk or reference_test.rst_n
           or reference_test.tick_enable or reference_test.load_valid
           or reference_test.phase_load or reference_test.frequency_load_q16
           or reference_test.gamma_effective_word
           or reference_test.thermal_node_factor_q30
           or reference_test.retained_state
           or reference_test.switch_activity or reference_test.scheduler_state) begin : compare_settled
    bit rising_edge, reset_assertion;
    int unsigned executed_state;
    #1fs;
    rising_edge = !previous_clk && reference_test.clk;
    reset_assertion = previous_rst_n && !reference_test.rst_n;
    previous_clk = reference_test.clk;
    previous_rst_n = reference_test.rst_n;
    executed_state = int'(reference_test.scheduler_state);
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs}))
        $fatal(1, "Unknown frequency post-synthesis output at time=%0t", $time);
      if (netlist_outputs !== reference_outputs)
        $fatal(1, "Frequency post-synthesis mismatch time=%0t ticks=%0d reference=%h netlist=%h",
               $time, tick_comparisons, reference_outputs, netlist_outputs);
      comparisons++;

      if (reset_assertion) reset_assertions++;
      if (rising_edge) begin
        if (!reference_test.rst_n) reset_clock_edges++;
        else if (reference_test.load_valid || reference_test.tick_enable) begin
          if (executed_state > 4)
            $fatal(1, "Invalid frequency post-synthesis scheduler state=%0d", executed_state);
          if (reference_test.load_valid) begin
            load_comparisons++;
            state_loads[executed_state]++;
          end else begin
            tick_comparisons++;
            state_ticks[executed_state]++;
          end
        end else hold_comparisons++;
      end
    end
  end

  final begin
    if (!armed || tick_comparisons != 90 || load_comparisons != 90
        || hold_comparisons < 360 || reset_assertions != 2
        || reset_clock_edges != 2 || comparisons < 544)
      $fatal(1, "Incomplete frequency post-synthesis coverage comparisons=%0d ticks=%0d loads=%0d holds=%0d reset_assertions=%0d reset_clock_edges=%0d",
             comparisons, tick_comparisons, load_comparisons, hold_comparisons,
             reset_assertions, reset_clock_edges);
    for (int state_index = 0; state_index < 5; state_index++)
      if (state_ticks[state_index] != BATCHES_PER_STATE
          || state_loads[state_index] != BATCHES_PER_STATE)
        $fatal(1, "Incomplete frequency post-synthesis scheduler coverage state=%0d ticks=%0d loads=%0d",
               state_index, state_ticks[state_index], state_loads[state_index]);
    if (reference_test.VECTOR_COUNT != 144 || reference_test.updates != 720
        || reference_test.loads != 90 || reference_test.hold_edges != 360
        || reference_test.reset_checks != 3
        || tick_comparisons * CELLS != reference_test.updates
        || load_comparisons != reference_test.loads)
      $fatal(1, "Incomplete fixed-vector frequency range reference qualification");
    $display("FRP_M31_FREQUENCY_RANGE_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d vectors=144 scheduler_states=5 updates=%0d ticks=%0d loads=%0d hold_edges=%0d reset_assertions=%0d reset_clock_edges=%0d free_ticks=%0d balance_ticks=%0d commit_ticks=%0d excite_ticks=%0d neutralize_ticks=%0d",
             comparisons, OUTPUT_BITS, tick_comparisons * CELLS, tick_comparisons,
             load_comparisons, hold_comparisons, reset_assertions, reset_clock_edges,
             state_ticks[0], state_ticks[1], state_ticks[2], state_ticks[3], state_ticks[4]);
  end
endmodule : frp_m31_frequency_range_post_synthesis_tb
`endif

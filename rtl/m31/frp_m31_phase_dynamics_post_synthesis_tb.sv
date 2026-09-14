// SPDX-License-Identifier: Apache-2.0
// FRP M31 phase-engine equivalence on the fixed clocked dynamics workload.

`ifndef FRP_M31_PHASE_DYNAMICS_POST_SYNTHESIS_TB_SV
`define FRP_M31_PHASE_DYNAMICS_POST_SYNTHESIS_TB_SV
`include "frp_m31_phase_dynamics_tb.sv"

module frp_m31_phase_dynamics_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 1168;

  // Compile with the independently synthesized and renamed eight-cell
  // phase engine: frp_m31_phase_interference_netlist.
  // The reference retains its fixed GOLD vectors and actual RTL scheduler.
  frp_m31_phase_dynamics_tb reference_test();

  logic [255:0] net_phase, net_frequency, net_coupling, net_projection;
  logic [15:0] net_target;
  logic signed [31:0] net_pair, net_cluster, net_global, net_dispersion;
  wire [OUTPUT_BITS-1:0] reference_outputs;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  bit armed = 0;
  bit previous_clk = 0;
  bit previous_rst_n = 1;
  int unsigned previous_scheduler_state = 0;
  int unsigned comparisons = 0, tick_comparisons = 0, hold_comparisons = 0;
  int unsigned load_comparisons = 0, reset_comparisons = 0;
  int unsigned state_comparisons [0:4] = '{default: 0};

  frp_m31_phase_interference_netlist u_phase_netlist (
    .clk(reference_test.clk),
    .rst_n(reference_test.rst_n),
    .tick_enable(reference_test.tick_enable),
    .load_valid(reference_test.load_valid),
    .phase_load(reference_test.phase_load),
    .frequency_load_q16(reference_test.frequency_load_q16),
    .gamma_effective_word(reference_test.gamma_effective_word),
    .thermal_node_factor_q30(reference_test.thermal_node_factor_q30),
    .retained_state(reference_test.dut.retained_state),
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

  // Hierarchical port references also retain the combinational observables
  // that the original fixed-vector test leaves unconnected.
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
  // 1 ps checks. The saved scheduler state is the state before the edge;
  // the scheduler itself advances concurrently with the phase engine.
  always @(reference_test.clk or reference_test.rst_n
           or reference_test.tick_enable or reference_test.load_valid
           or reference_test.phase_load or reference_test.frequency_load_q16
           or reference_test.gamma_effective_word
           or reference_test.thermal_node_factor_q30
           or reference_test.dut.retained_state
           or reference_test.switch_activity or reference_test.scheduler_state) begin : compare_settled
    bit rising_edge, reset_assertion;
    int unsigned executed_state;
    #1fs;
    rising_edge = !previous_clk && reference_test.clk;
    reset_assertion = previous_rst_n && !reference_test.rst_n;
    executed_state = previous_scheduler_state;
    previous_clk = reference_test.clk;
    previous_rst_n = reference_test.rst_n;
    previous_scheduler_state = int'(reference_test.scheduler_state);
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs}))
        $fatal(1, "Unknown phase post-synthesis output at time=%0t", $time);
      if (netlist_outputs !== reference_outputs)
        $fatal(1, "Phase post-synthesis mismatch time=%0t ticks=%0d reference=%h netlist=%h",
               $time, tick_comparisons, reference_outputs, netlist_outputs);
      comparisons++;

      if (reset_assertion) reset_comparisons++;
      if (rising_edge && reference_test.rst_n) begin
        if (reference_test.load_valid) load_comparisons++;
        else if (reference_test.tick_enable) begin
          if (executed_state > 4)
            $fatal(1, "Invalid phase post-synthesis scheduler state=%0d", executed_state);
          tick_comparisons++;
          state_comparisons[executed_state]++;
        end else hold_comparisons++;
      end
    end
  end

  final begin
    if (!armed || tick_comparisons != 48 || hold_comparisons < 96
        || load_comparisons != 6 || reset_comparisons != 6 || comparisons < 156)
      $fatal(1, "Incomplete phase post-synthesis coverage comparisons=%0d ticks=%0d holds=%0d loads=%0d resets=%0d",
             comparisons, tick_comparisons, hold_comparisons,
             load_comparisons, reset_comparisons);
    if (state_comparisons[0] != 16 || state_comparisons[1] != 14
        || state_comparisons[2] != 2 || state_comparisons[3] != 2
        || state_comparisons[4] != 14)
      $fatal(1, "Incomplete phase post-synthesis scheduler coverage free=%0d balance=%0d commit=%0d excite=%0d neutralize=%0d",
             state_comparisons[0], state_comparisons[1], state_comparisons[2],
             state_comparisons[3], state_comparisons[4]);
    if (reference_test.profiles != 6 || reference_test.ticks != 48
        || reference_test.hold_edges != 96 || reference_test.loads != 6
        || reference_test.resets != 6)
      $fatal(1, "Incomplete fixed-vector phase dynamics reference qualification");
    for (int state_index = 0; state_index < 5; state_index++)
      if (state_comparisons[state_index] != reference_test.state_hits[state_index])
        $fatal(1, "Phase post-synthesis scheduler count differs from reference state=%0d",
               state_index);
    $display("FRP_M31_PHASE_DYNAMICS_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d ticks=%0d hold_edges=%0d loads=%0d resets=%0d free_ticks=%0d balance_ticks=%0d commit_ticks=%0d excite_ticks=%0d neutralize_ticks=%0d",
             comparisons, OUTPUT_BITS, tick_comparisons, hold_comparisons,
             load_comparisons, reset_comparisons, state_comparisons[0],
             state_comparisons[1], state_comparisons[2], state_comparisons[3],
             state_comparisons[4]);
  end
endmodule : frp_m31_phase_dynamics_post_synthesis_tb
`endif

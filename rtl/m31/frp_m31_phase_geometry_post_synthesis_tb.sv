 // SPDX-License-Identifier: Apache-2.0
 // FRP M31 phase-engine equivalence on the loaded phase-geometry workload.

`ifndef FRP_M31_PHASE_GEOMETRY_POST_SYNTHESIS_TB_SV
`define FRP_M31_PHASE_GEOMETRY_POST_SYNTHESIS_TB_SV
`include "frp_m31_phase_geometry_tb.sv"

module frp_m31_phase_geometry_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 1168;

  // Compile with the independently synthesized and renamed eight-cell
  // phase engine: frp_m31_phase_interference_netlist.
  // The reference retains its independent sine oracle and geometry cases.
  // Ticks remain disabled throughout this loaded-geometry workload.
  frp_m31_phase_geometry_tb reference_test();

  logic [255:0] net_phase, net_frequency, net_coupling, net_projection;
  logic [15:0] net_target;
  logic signed [31:0] net_pair, net_cluster, net_global, net_dispersion;
  wire [OUTPUT_BITS-1:0] reference_outputs;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  bit armed = 0;
  bit previous_clk = 0;
  bit previous_rst_n = 1;
  int unsigned comparisons = 0, load_comparisons = 0, hold_comparisons = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0;

  frp_m31_phase_interference_netlist u_phase_netlist (
    .clk(reference_test.clk),
    .rst_n(reference_test.rst_n),
    .tick_enable(1'b0),
    .load_valid(reference_test.load_valid),
    .phase_load(reference_test.phase_load),
    .frequency_load_q16({8{32'h00010000}}),
    .gamma_effective_word(reference_test.gamma_effective_word),
    .thermal_node_factor_q30(reference_test.thermal_node_factor_q30),
    .retained_state(16'd0),
    .switch_activity(8'd0),
    .scheduler_state(frp_m31_pkg::FRP_SCHED_FREE),
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

  assign reference_outputs = {
    reference_test.phase_word_q,
    reference_test.frequency_current_q16,
    reference_test.coupling_field_q16,
    reference_test.phase_projection_q30,
    reference_test.phase_target,
    reference_test.pair_order,
    reference_test.cluster_order,
    reference_test.global_order,
    reference_test.dispersion
  };
  assign netlist_outputs = {
    net_phase, net_frequency, net_coupling, net_projection, net_target,
    net_pair, net_cluster, net_global, net_dispersion
  };

  // Compare after zero-delay cells settle and before the reference's 1 ps
  // checks. Input changes also exercise the combinational observables
  // between bank loads, including receiver-local gamma and thermal factors.
  always @(reference_test.clk or reference_test.rst_n
           or reference_test.load_valid or reference_test.phase_load
           or reference_test.gamma_effective_word
           or reference_test.thermal_node_factor_q30) begin : compare_settled
    bit rising_edge, reset_assertion;
    #1fs;
    rising_edge = !previous_clk && reference_test.clk;
    reset_assertion = previous_rst_n && !reference_test.rst_n;
    previous_clk = reference_test.clk;
    previous_rst_n = reference_test.rst_n;
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs}))
        $fatal(1, "Unknown geometry post-synthesis output at time=%0t", $time);
      if (netlist_outputs !== reference_outputs)
        $fatal(1, "Geometry post-synthesis mismatch time=%0t loads=%0d reference=%h netlist=%h",
               $time, load_comparisons, reference_outputs, netlist_outputs);
      comparisons++;

      if (reset_assertion) reset_assertions++;
      if (rising_edge) begin
        if (!reference_test.rst_n) reset_clock_edges++;
        else if (reference_test.load_valid) load_comparisons++;
        else hold_comparisons++;
      end
    end
  end

  final begin
    if (!armed || load_comparisons != 634 || hold_comparisons < 634
        || reset_assertions != 1 || reset_clock_edges != 1 || comparisons < 1270)
      $fatal(1, "Incomplete geometry post-synthesis coverage comparisons=%0d loads=%0d holds=%0d reset_assertions=%0d reset_clock_edges=%0d",
             comparisons, load_comparisons, hold_comparisons,
             reset_assertions, reset_clock_edges);
    if (reference_test.loads != load_comparisons
        || reference_test.lut_samples != 4096 || reference_test.target_samples != 4096
        || reference_test.geometry_cases != 5 || reference_test.gamma_cases != 8
        || reference_test.topology_cases != 16 || reference_test.thermal_cases != 13
        || reference_test.rotation_cases != 60 || reference_test.coupling_checks != 296)
      $fatal(1, "Incomplete phase geometry reference qualification");
    $display("FRP_M31_PHASE_GEOMETRY_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d loads=%0d hold_edges=%0d reset_assertions=%0d reset_clock_edges=%0d lut_samples=%0d target_samples=%0d geometry_cases=%0d gamma_cases=%0d topology_cases=%0d thermal_cases=%0d rotation_cases=%0d coupling_checks=%0d",
             comparisons, OUTPUT_BITS, load_comparisons, hold_comparisons,
             reset_assertions, reset_clock_edges, reference_test.lut_samples,
             reference_test.target_samples, reference_test.geometry_cases,
             reference_test.gamma_cases, reference_test.topology_cases,
             reference_test.thermal_cases, reference_test.rotation_cases,
             reference_test.coupling_checks);
  end
endmodule : frp_m31_phase_geometry_post_synthesis_tb
`endif

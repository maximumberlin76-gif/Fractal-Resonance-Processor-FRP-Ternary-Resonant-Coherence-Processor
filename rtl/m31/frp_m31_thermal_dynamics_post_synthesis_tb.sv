// SPDX-License-Identifier: Apache-2.0
// FRP M31 thermal and stability equivalence against the fixed-vector RTL test.

`ifndef FRP_M31_THERMAL_DYNAMICS_POST_SYNTHESIS_TB_SV
`define FRP_M31_THERMAL_DYNAMICS_POST_SYNTHESIS_TB_SV
`include "frp_m31_thermal_dynamics_tb.sv"

module frp_m31_thermal_dynamics_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  localparam int OUTPUT_BITS = 193;

  // Compile with independently synthesized and renamed netlist modules:
  // frp_m31_thermal_proxy_netlist and frp_m31_stability_netlist.
  frp_m31_thermal_dynamics_tb reference_test();

  logic signed [31:0] net_temperature, net_peak;
  logic [31:0] net_samples;
  logic signed [31:0] net_capacity, net_pressure, net_margin;
  logic net_stable;
  wire [OUTPUT_BITS-1:0] reference_outputs;
  wire [OUTPUT_BITS-1:0] netlist_outputs;

  bit armed = 0;
  bit previous_clk = 0;
  bit previous_rst_n = 1;
  int unsigned comparisons = 0, update_comparisons = 0, hold_comparisons = 0;
  int unsigned clear_comparisons = 0, reset_comparisons = 0;
  int unsigned boundary_comparisons = 0;

  frp_m31_thermal_proxy_netlist u_thermal_netlist (
    .clk(reference_test.clk),
    .rst_n(reference_test.rst_n),
    .tick_enable(reference_test.tick_enable),
    .clear(reference_test.clear),
    .normalized_cycle_cost_q16(reference_test.normalized_cycle_cost_q16),
    .temperature_proxy_q16(net_temperature),
    .peak_temperature_proxy_q16(net_peak),
    .sample_count_q(net_samples)
  );

  frp_m31_stability_netlist u_stability_netlist (
    .retained_state(reference_test.retained_state),
    .global_coherence_q30(reference_test.global_coherence_q30),
    .cluster_coherence_q30(reference_test.cluster_coherence_q30),
    .temperature_proxy_q16(net_temperature),
    .switch_load_q16(reference_test.normalized_cycle_cost_q16),
    .coherence_capacity_q16(net_capacity),
    .pressure_q16(net_pressure),
    .stability_margin_q16(net_margin),
    .stable(net_stable)
  );

  assign reference_outputs = {
    reference_test.temperature_proxy_q16,
    reference_test.peak_temperature_proxy_q16,
    reference_test.sample_count_q,
    reference_test.coherence_capacity_q16,
    reference_test.pressure_q16,
    reference_test.stability_margin_q16,
    reference_test.stable
  };
  assign netlist_outputs = {
    net_temperature, net_peak, net_samples,
    net_capacity, net_pressure, net_margin, net_stable
  };

  // Settle zero-delay cells before comparing. The reference checks each
  // boundary vector after 1 ps, so this 1 fs check also observes every
  // intermediate boundary vector before the next stimulus is applied.
  always @(reference_test.clk or reference_test.rst_n
           or reference_test.tick_enable or reference_test.clear
           or reference_test.normalized_cycle_cost_q16
           or reference_test.retained_state
           or reference_test.global_coherence_q30
           or reference_test.cluster_coherence_q30) begin : compare_settled
    bit rising_edge, reset_assertion;
    #1fs;
    rising_edge = !previous_clk && reference_test.clk;
    reset_assertion = previous_rst_n && !reference_test.rst_n;
    previous_clk = reference_test.clk;
    previous_rst_n = reference_test.rst_n;
    if (reset_assertion) armed = 1;

    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs}))
        $fatal(1, "Unknown thermal post-synthesis output at time=%0t", $time);
      if (netlist_outputs !== reference_outputs)
        $fatal(1, "Thermal post-synthesis mismatch time=%0t updates=%0d reference=%h netlist=%h",
               $time, update_comparisons, reference_outputs, netlist_outputs);
      comparisons++;

      if (reset_assertion) reset_comparisons++;
      if (rising_edge && reference_test.rst_n) begin
        if (reference_test.clear) clear_comparisons++;
        else if (reference_test.tick_enable) update_comparisons++;
        else hold_comparisons++;
      end

      // The reference presents its 108 capacity-boundary vectors while
      // thermal ticks are paused, before the first accumulation workload.
      if (reference_test.rst_n && !reference_test.clear
          && !reference_test.tick_enable && reference_test.boundary_cases < 108
          && reference_test.normalized_cycle_cost_q16
             >= reference_test.coherence_capacity_q16 - 32'sd1
          && reference_test.normalized_cycle_cost_q16
             <= reference_test.coherence_capacity_q16 + 32'sd1)
        boundary_comparisons++;
    end
  end

  final begin
    if (!armed || update_comparisons != 324 || hold_comparisons < 128
        || clear_comparisons != 4 || reset_comparisons != 3
        || boundary_comparisons != 108 || comparisons < 567)
      $fatal(1, "Incomplete thermal post-synthesis coverage comparisons=%0d updates=%0d holds=%0d clears=%0d resets=%0d boundaries=%0d",
             comparisons, update_comparisons, hold_comparisons, clear_comparisons,
             reset_comparisons, boundary_comparisons);
    if (reference_test.profiles != 2 || reference_test.vectors != 64
        || reference_test.cooling_ticks != 256 || reference_test.warmup_ticks != 4
        || reference_test.updates != 324 || reference_test.hold_edges != 128
        || reference_test.clears != 4 || reference_test.resets != 3
        || reference_test.capacity_cases != 36 || reference_test.boundary_cases != 108
        || reference_test.saturation_cases != 22)
      $fatal(1, "Incomplete fixed-vector thermal reference qualification");
    $display("FRP_M31_THERMAL_DYNAMICS_POST_SYNTHESIS_TB: PASS comparisons=%0d output_bits=%0d updates=%0d hold_edges=%0d clears=%0d resets=%0d boundary_cases=%0d",
             comparisons, OUTPUT_BITS, update_comparisons, hold_comparisons,
             clear_comparisons, reset_comparisons, boundary_comparisons);
  end
endmodule : frp_m31_thermal_dynamics_post_synthesis_tb
`endif

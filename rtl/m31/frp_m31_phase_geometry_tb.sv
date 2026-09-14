// SPDX-License-Identifier: Apache-2.0
// FRP M31 phase geometry, local gamma and thermal-coupling regression.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert,
// -Irtl/m31 and --top-module frp_m31_phase_geometry_tb.
//
// The sine oracle uses real arithmetic, independent of the DUT ROM and
// fixed-point helpers. All 4096 LUT addresses include nonzero low phase
// bits where possible; expected targets use the published Q30 threshold.
// Exact geometry cases distinguish pair, cluster and global phase order.
// Coupling checks cover both interference signs, all three dyadic shells,
// receiver-local gamma_i, pairwise thermal attenuation and node isolation.
// Common quarter-turn rotations preserve relative coupling and phase order.
// Ticks remain disabled: this bench qualifies the loaded phase geometry.

`ifndef FRP_M31_PHASE_GEOMETRY_TB_SV
`define FRP_M31_PHASE_GEOMETRY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_phase_geometry_tb;
  localparam logic signed [31:0] ONE = 32'sd1073741824;
  localparam logic signed [31:0] THRESHOLD = 32'sd354334802;
  localparam logic signed [31:0] THERMAL_GOLD [0:4] =
    '{32'sd0, -32'sd1147, -32'sd4588, -32'sd10322, -32'sd18350};

  logic clk = 0, rst_n = 1, load_valid = 0;
  logic [255:0] phase_load = 0, gamma_effective_word = 0;
  logic [255:0] thermal_node_factor_q30 = {8{32'h40000000}};
  logic [255:0] phase_word_q, frequency_current_q16;
  logic [255:0] coupling_field_q16, phase_projection_q30;
  logic [15:0] phase_target;
  logic signed [31:0] pair_order, cluster_order, global_order, dispersion;
  logic [255:0] base_phase, base_coupling;
  logic [127:0] base_orders;
  logic [31:0] random_word = 32'd76;
  int loads = 0, lut_samples = 0, target_samples = 0, geometry_cases = 0;
  int gamma_cases = 0, topology_cases = 0, thermal_cases = 0;
  int rotation_cases = 0, coupling_checks = 0;

  always #5 clk = ~clk;
  initial begin #100000; $fatal(1, "Phase geometry watchdog"); end

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable(1'b0), .load_valid, .phase_load,
    .frequency_load_q16({8{32'h00010000}}), .gamma_effective_word,
    .thermal_node_factor_q30, .retained_state(16'd0), .switch_activity(8'd0),
    .scheduler_state(frp_m31_pkg::FRP_SCHED_FREE),
    .phase_word_q, .frequency_current_q16, .coupling_field_q16,
    .phase_projection_q30, .phase_target,
    .pair_coherence_q30(pair_order), .cluster_coherence_q30(cluster_order),
    .global_coherence_q30(global_order), .organization_dispersion_q30(dispersion)
  );

  function automatic logic signed [31:0] sine_oracle(input int unsigned address);
    real scaled;
    scaled = $sin(6.283185307179586476925286766559 * real'(address) / 4096.0)
      * 1073741824.0;
    return $rtoi(scaled < 0.0 ? scaled - 0.5 : scaled + 0.5);
  endfunction

  function automatic logic [31:0] next_word(input logic [31:0] previous);
    return previous * 32'd1664525 + 32'd1013904223;
  endfunction

  task automatic load_bank();
    @(negedge clk); load_valid = 1;
    @(posedge clk); #1ps;
    if (phase_word_q !== phase_load || frequency_current_q16 !== {8{32'h00010000}})
      $fatal(1, "Phase geometry bank load mismatch load=%0d", loads);
    loads++;
    @(negedge clk); load_valid = 0;
    #1ps;
  endtask

  task automatic expect_orders(
    input logic signed [31:0] pair_gold, cluster_gold, global_gold, dispersion_gold
  );
    if ({pair_order, cluster_order, global_order, dispersion}
        !== {pair_gold, cluster_gold, global_gold, dispersion_gold})
      $fatal(1, "Phase order mismatch case=%0d actual=%h expected=%h", geometry_cases,
             {pair_order, cluster_order, global_order, dispersion},
             {pair_gold, cluster_gold, global_gold, dispersion_gold});
    geometry_cases++;
  endtask

  task automatic expect_coupling(input int cell_index, input logic signed [31:0] gold);
    if (coupling_field_q16[cell_index*32 +: 32] !== gold)
      $fatal(1, "Coupling mismatch load=%0d cell=%0d actual=%h expected=%h",
             loads, cell_index, coupling_field_q16[cell_index*32 +: 32], gold);
    coupling_checks++;
  endtask

  initial begin : qualification
    logic signed [31:0] sine_gold, coupling_gold;
    logic [1:0] target_gold;
    int address, shell;

    #1ps; rst_n = 0;
    @(negedge clk); rst_n = 1;

    for (int batch = 0; batch < 4096; batch += 8) begin
      for (int cell_index = 0; cell_index < 8; cell_index++) begin
        address = batch + cell_index;
        phase_load[cell_index*32 +: 32] =
          (32'(address) << 20) | (32'(address * 977) & 32'h000fffff);
      end
      load_bank();
      for (int cell_index = 0; cell_index < 8; cell_index++) begin
        sine_gold = sine_oracle(batch + cell_index);
        if (phase_projection_q30[cell_index*32 +: 32] !== sine_gold)
          $fatal(1, "Sine projection mismatch address=%0d actual=%h expected=%h",
                 batch + cell_index, phase_projection_q30[cell_index*32 +: 32], sine_gold);
        lut_samples++;
        target_gold = sine_gold > THRESHOLD ? 2'b01
          : sine_gold < -THRESHOLD ? 2'b11 : 2'b00;
        if (phase_target[cell_index*2 +: 2] !== target_gold)
          $fatal(1, "Ternary phase target mismatch address=%0d", batch + cell_index);
        target_samples++;
      end
    end

    // Coherent, opposite-pair, quarter-spread, split-cluster and mixed banks.
    phase_load = '0;
    load_bank(); expect_orders(ONE, ONE, ONE, 0);
    for (int cell_index = 0; cell_index < 8; cell_index++)
      phase_load[cell_index*32 +: 32] = (cell_index % 2) ? 32'h80000000 : 0;
    load_bank(); expect_orders(0, 0, 0, 0);
    for (int cell_index = 0; cell_index < 8; cell_index++)
      phase_load[cell_index*32 +: 32] = 32'(cell_index % 4) * 32'h40000000;
    load_bank(); expect_orders(32'sd759250124, 0, 0, 0);
    for (int cell_index = 0; cell_index < 8; cell_index++)
      phase_load[cell_index*32 +: 32] = cell_index < 4 ? 0 : 32'h80000000;
    load_bank(); expect_orders(ONE, ONE, 0, 0);
    for (int cell_index = 0; cell_index < 8; cell_index++)
      phase_load[cell_index*32 +: 32] =
        cell_index < 4 ? 0 : 32'(cell_index - 4) * 32'h40000000;
    load_bank(); expect_orders(32'sd916495974, ONE/2, ONE/2, ONE/2);

    // Equal phases with gamma_i = pi/2: only receiving cell i sees -K_0.
    phase_load = '0;
    for (int receiver = 0; receiver < 8; receiver++) begin
      gamma_effective_word = '0;
      gamma_effective_word[receiver*32 +: 32] = 32'h40000000;
      load_bank();
      for (int cell_index = 0; cell_index < 8; cell_index++)
        expect_coupling(cell_index, cell_index == receiver ? -32'sd18350 : 32'sd0);
      gamma_cases++;
    end

    // One quarter-shifted source isolates each shell weight and both signs.
    gamma_effective_word = '0;
    for (int polarity = 0; polarity < 2; polarity++) begin
      for (int source_cell = 0; source_cell < 8; source_cell++) begin
        phase_load = '0;
        phase_load[source_cell*32 +: 32] = polarity == 0 ? 32'h40000000 : 32'hc0000000;
        load_bank();
        for (int cell_index = 0; cell_index < 8; cell_index++) begin
          shell = cell_index ^ source_cell;
          // Independently rounded Q16 values of K_0 times each Q16 shell weight.
          coupling_gold = shell == 0 ? -32'sd18350 : shell < 2 ? 32'sd8826
            : shell < 4 ? 32'sd2717 : 32'sd1023;
          expect_coupling(cell_index, polarity == 0 ? coupling_gold : -coupling_gold);
        end
        topology_cases++;
      end
    end

    phase_load = '0;
    gamma_effective_word = {8{32'h40000000}};
    for (int attenuation = 0; attenuation <= 4; attenuation++) begin
      thermal_node_factor_q30 = {8{32'(attenuation) * 32'h10000000}};
      load_bank();
      for (int cell_index = 0; cell_index < 8; cell_index++)
        expect_coupling(cell_index, THERMAL_GOLD[attenuation]);
      thermal_cases++;
    end
    for (int isolated = 0; isolated < 8; isolated++) begin
      thermal_node_factor_q30 = {8{32'h40000000}};
      thermal_node_factor_q30[isolated*32 +: 32] = 0;
      load_bank();
      for (int cell_index = 0; cell_index < 8; cell_index++) begin
        if (cell_index == isolated) begin
          expect_coupling(cell_index, 0);
        end else begin
          coupling_gold = $signed(coupling_field_q16[cell_index*32 +: 32]);
          if (coupling_gold >= 0 || coupling_gold <= -32'sd18350)
            $fatal(1, "Thermal node isolation did not attenuate its neighbor cell=%0d", cell_index);
          coupling_checks++;
        end
      end
      thermal_cases++;
    end

    // Arbitrary phase/gamma words and nonuniform thermal factors.
    for (int sample_index = 0; sample_index < 20; sample_index++) begin
      for (int cell_index = 0; cell_index < 8; cell_index++) begin
        random_word = next_word(random_word);
        base_phase[cell_index*32 +: 32] = random_word;
        random_word = next_word(random_word);
        gamma_effective_word[cell_index*32 +: 32] = random_word;
        thermal_node_factor_q30[cell_index*32 +: 32] =
          32'((sample_index + cell_index) % 5) * 32'h10000000;
      end
      phase_load = base_phase;
      load_bank();
      base_coupling = coupling_field_q16;
      base_orders = {pair_order, cluster_order, global_order, dispersion};
      for (int rotation = 1; rotation <= 3; rotation++) begin
        for (int cell_index = 0; cell_index < 8; cell_index++)
          phase_load[cell_index*32 +: 32] =
            base_phase[cell_index*32 +: 32] + 32'(rotation) * 32'h40000000;
        load_bank();
        if (coupling_field_q16 !== base_coupling
            || {pair_order, cluster_order, global_order, dispersion} !== base_orders)
          $fatal(1, "Common phase rotation changed relative geometry sample=%0d rotation=%0d",
                 sample_index, rotation);
        rotation_cases++;
      end
    end

    if (loads != 634 || lut_samples != 4096 || target_samples != 4096
        || geometry_cases != 5 || gamma_cases != 8 || topology_cases != 16
        || thermal_cases != 13 || rotation_cases != 60 || coupling_checks != 296)
      $fatal(1, "Phase geometry scenarios incomplete");
    $display("FRP_M31_PHASE_GEOMETRY_TB: PASS loads=%0d lut_samples=%0d target_samples=%0d geometry_cases=%0d gamma_cases=%0d topology_cases=%0d thermal_cases=%0d rotation_cases=%0d coupling_checks=%0d",
             loads, lut_samples, target_samples, geometry_cases, gamma_cases,
             topology_cases, thermal_cases, rotation_cases, coupling_checks);
    $finish;
  end
endmodule : frp_m31_phase_geometry_tb
`endif

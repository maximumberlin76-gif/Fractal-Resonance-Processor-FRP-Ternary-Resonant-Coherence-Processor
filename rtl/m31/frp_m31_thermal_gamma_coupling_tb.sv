`timescale 1ns/1ps
`include "frp_m31_global_stability.sv"
`include "frp_m31_local_thermal_attenuation.sv"
`include "frp_m31_local_gamma_drift.sv"

// Exercise a shared overload vector at the three public RTL boundaries.
module frp_m31_thermal_gamma_coupling_tb #(parameter int CELLS = 64);
  localparam logic [31:0] UNITY = 32'd1073741824;
  localparam logic [31:0] EXP_MINUS_EIGHT = 32'd360200;
  logic clk = 0, rst_n = 1, tick_enable = 0, gamma_valid = 0;
  logic [32*CELLS-1:0] overload = '0, targets = '0;
  wire [32*CELLS-1:0] factor, next_factor, stored_target;
  wire signed [31:0] mean_overload, argument, next_compression, compression;
  logic [32*CELLS-1:0] expected_factor, held_factor, held_target;
  logic [31:0] held_compression;
  int checks = 0;

  frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) attenuation (
    .clk, .rst_n, .tick_enable, .thermal_overload_q16(overload),
    .thermal_node_factor_q30(factor), .next_thermal_node_factor_q30(next_factor)
  );
  frp_m31_global_stability #(.CELLS(CELLS)) stability (
    .clk, .rst_n, .tick_enable, .thermal_overload_q16(overload),
    .retained_state('0), .raw_phase_coherence_q30('0), .cluster_coherence_q30('0),
    .heat_q16('0), .frequency_lag_q16('0), .switch_load_q16('0),
    .mean_thermal_overload_q16(mean_overload), .compression_arg_q16(argument),
    .next_coherence_compression_q30(next_compression), .coherence_compression_q30(compression)
  );
  frp_m31_local_gamma_drift #(.CELLS(CELLS)) gamma_dut (
    .clk, .rst_n, .tick_enable, .gamma_update_valid(gamma_valid),
    .gamma_targets_q16(targets), .thermal_overload_q16(overload),
    .gamma_noise_target_q16(stored_target)
  );

  task automatic clock_edge;
    #1; clk = 1; #1; clk = 0; #1;
  endtask

  // Zero, uniformly hot, and alternating signed interface stress.
  task automatic drive(input int scenario, input bit enable_tick, input bit update);
    int signed word_value, expected_mean;
    logic [31:0] candidate_compression;
    held_factor = factor;
    held_target = stored_target;
    held_compression = compression;
    tick_enable = enable_tick;
    gamma_valid = update;
    expected_mean = scenario == 1 ? 524288 : 0;
    for (int lane = 0; lane < CELLS; lane++) begin
      case (scenario)
        0: word_value = 0;
        1: word_value = 524288;
        default: word_value = (lane % 2 == 0) ? -524288 : 524288;
      endcase
      overload[32*lane +: 32] = word_value;
      expected_factor[32*lane +: 32] = word_value > 0 ? EXP_MINUS_EIGHT : UNITY;
      targets[32*lane +: 32] = (scenario+1)*1000 + lane;
    end
    #1;
    if (mean_overload !== expected_mean || next_factor !== expected_factor)
      $fatal(1, "overload reduction or lane mapping mismatch scenario=%0d", scenario);
    if (scenario == 1 && (argument <= 524288 || next_compression !== EXP_MINUS_EIGHT))
      $fatal(1, "global upper clamp mismatch");
    if (scenario == 0 && (argument !== 0 || next_compression !== UNITY))
      $fatal(1, "global zero endpoint mismatch");
    candidate_compression = next_compression;
    clock_edge();
    if (factor !== (enable_tick ? expected_factor : held_factor) ||
        compression !== (enable_tick ? candidate_compression : held_compression) ||
        stored_target !== ((enable_tick && update) ? targets : held_target))
      $fatal(1, "commit/hold mismatch scenario=%0d tick=%0b valid=%0b",
             scenario, enable_tick, update);
    checks++;
  endtask

  initial begin
    #1; rst_n = 0; #1;
    if (factor !== {CELLS{UNITY}} || stored_target !== '0 || compression !== UNITY)
      $fatal(1, "reset mismatch");
    rst_n = 1;
    drive(0, 1, 0);
    drive(1, 0, 1);
    drive(1, 1, 1);
    drive(2, 1, 0);
    drive(2, 0, 1);
    drive(2, 1, 1);
    $display("PASS THERMAL_GAMMA_COUPLING cells=%0d cases=%0d", CELLS, checks);
    $finish;
  end
endmodule

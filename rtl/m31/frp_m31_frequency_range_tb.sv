// SPDX-License-Identifier: Apache-2.0
// FRP M31 signed-frequency range and retained-update regression.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert,
// -Irtl/m31 and --top-module frp_m31_frequency_range_tb.
//
// The 144 fixed vectors cover signed endpoints, overflow boundaries,
// deterministic interior samples and positive/negative half-way rounding.
// Every -1/0/1 state and both switch-activity values are represented.
// Expected Q16 words were computed with independent integer arithmetic:
//   target = 65536 + (state != 0 ? 3932 : 0) + (activity ? 7864 : 0)
//   next = clamp_s32(f + round_half_away((target - f) * 19661 / 65536))
// No DUT arithmetic helper is used to compute the expected result.
//
// Each packed vector is input_frequency[31:0], state[3:0], activity[3:0],
// expected_frequency[31:0]. State codes are 0 = active zero, 1 = 1, 3 = -1.
// All vectors run in each of the five scheduler states, including balance,
// commit, excite and neutralize from schedules 7/1 and 1/7.
// The test also checks load priority, disabled-tick retention, and reset.
// This is a frequency-memory regression; cadence is checked by the M32
// mode-7/1 and mode-1/7 testbenches.

`ifndef FRP_M31_FREQUENCY_RANGE_TB_SV
`define FRP_M31_FREQUENCY_RANGE_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_frequency_range_tb;
  import frp_m31_pkg::*;

  localparam int VECTOR_COUNT = 144;
  localparam logic [71:0] VECTORS [0:VECTOR_COUNT-1] = '{
    72'h80000000_0_0_a666cccd, 72'h80000001_0_0_a666ccce, 72'h8000ffff_0_0_a6677fff,
    72'h80010000_0_0_a6678000, 72'h80010001_0_0_a6678001, 72'h80012e13_0_0_a667a040,
    72'h80012e14_0_0_a667a041, 72'h80012e15_0_0_a667a042, 72'h7fffffff_0_0_5999cccc,
    72'h00000000_0_0_00004ccd, 72'h00010000_0_0_00010000, 72'hffff0000_0_0_ffff999a,
    72'h9c459f57_0_0_ba311d16, 72'hf94a9332_0_0_fb4e1b94, 72'h0cccd8e5_0_0_08f61544,
    72'hd611a4e4_0_0_e2a6489c, 72'hc694b0ba_0_0_d7ced3fe, 72'h521a45b1_0_0_397906c4,
    72'h352147d3_0_0_253127a7, 72'h5c051d0c_0_0_406a3521, 72'h00008000_0_0_0000a667,
    72'h00018000_0_0_00015999, 72'hffff8000_0_0_fffff334, 72'h00028000_0_0_00020ccc,
    72'h80000000_0_1_a666d604, 72'h80000001_0_1_a666d605, 72'h8000ffff_0_1_a6678937,
    72'h80010000_0_1_a6678937, 72'h80010001_0_1_a6678938, 72'h80012e13_0_1_a667a978,
    72'h80012e14_0_1_a667a978, 72'h80012e15_0_1_a667a979, 72'h7fffffff_0_1_5999d604,
    72'h00000000_0_1_00005604, 72'h00010000_0_1_00010937, 72'hffff0000_0_1_ffffa2d1,
    72'h48e1c37f_0_1_3304b6b0, 72'h607fa89f_0_1_438cd25a, 72'h55ffc797_0_1_3c335088,
    72'he16eedc5_0_1_ea9acf5e, 72'h56b6faed_0_1_3cb38dec, 72'h4ec6b40c_0_1_3724f77e,
    72'h6e5eeb5d_0_1_4d42b17f, 72'h0b43f650_0_1_07e319c8, 72'h00009eb8_0_1_0000c51f,
    72'h00019eb8_0_1_00017851, 72'hffff9eb8_0_1_000011ec, 72'h00029eb8_0_1_00022b84,
    72'h80000000_1_0_a666d169, 72'h80000001_1_0_a666d169, 72'h8000ffff_1_0_a667849b,
    72'h80010000_1_0_a667849c, 72'h80010001_1_0_a667849c, 72'h80012e13_1_0_a667a4dc,
    72'h80012e14_1_0_a667a4dd, 72'h80012e15_1_0_a667a4dd, 72'h7fffffff_1_0_5999d168,
    72'h00000000_1_0_00005169, 72'h00010000_1_0_0001049c, 72'hffff0000_1_0_ffff9e36,
    72'heb0bf329_1_0_f1557fd0, 72'h95f5112b_1_0_b5c58c3c, 72'h68f0a713_1_0_49757e2c,
    72'h1f1487ff_1_0_15c1dd97, 72'hd79757a3_1_0_e3b716d6, 72'h9abe3a54_1_0_b91f2817,
    72'hea872daa_1_0_f0f88f45, 72'h5fd982de_1_0_4318803f, 72'h00008f5c_1_0_0000b5c3,
    72'h00018f5c_1_0_000168f5, 72'hffff8f5c_1_0_00000290, 72'h00028f5c_1_0_00021c28,
    72'h80000000_1_1_a666daa0, 72'h80000001_1_1_a666daa1, 72'h8000ffff_1_1_a6678dd2,
    72'h80010000_1_1_a6678dd3, 72'h80010001_1_1_a6678dd4, 72'h80012e13_1_1_a667ae13,
    72'h80012e14_1_1_a667ae14, 72'h80012e15_1_1_a667ae15, 72'h7fffffff_1_1_5999da9f,
    72'h00000000_1_1_00005aa0, 72'h00010000_1_1_00010dd3, 72'hffff0000_1_1_ffffa76d,
    72'hdc7c1d0c_1_1_e7240fa9, 72'h09aa14bb_1_1_06c43401, 72'h853691cd_1_1_aa0d0c71,
    72'h3fff64a1_1_1_2cccaddd, 72'h8bb5976e_1_1_ae9928af, 72'hfca8b1a9_1_1_fda9a474,
    72'h6ab70907_1_1_4ab39867, 72'h69ef8b1d_1_1_4a27f39e, 72'h0000ae14_1_1_0000d47b,
    72'h0001ae14_1_1_000187ad, 72'hffffae14_1_1_00002148, 72'h0002ae14_1_1_00023ae0,
    72'h80000000_3_0_a666d169, 72'h80000001_3_0_a666d169, 72'h8000ffff_3_0_a667849b,
    72'h80010000_3_0_a667849c, 72'h80010001_3_0_a667849c, 72'h80012e13_3_0_a667a4dc,
    72'h80012e14_3_0_a667a4dd, 72'h80012e15_3_0_a667a4dd, 72'h7fffffff_3_0_5999d168,
    72'h00000000_3_0_00005169, 72'h00010000_3_0_0001049c, 72'hffff0000_3_0_ffff9e36,
    72'hbed69c56_3_0_d263657a, 72'h0ecae33a_3_0_0a5b20b5, 72'ha2779da3_3_0_be875276,
    72'hb10c890a_3_0_c8bc5aba, 72'heeee25f1_3_0_f40d6f62, 72'ha6d9ea02_3_0_c198ed72,
    72'h96281fa2_3_0_b5e94985, 72'h89c1f020_3_0_ad3b5df2, 72'h00008f5c_3_0_0000b5c3,
    72'h00018f5c_3_0_000168f5, 72'hffff8f5c_3_0_00000290, 72'h00028f5c_3_0_00021c28,
    72'h80000000_3_1_a666daa0, 72'h80000001_3_1_a666daa1, 72'h8000ffff_3_1_a6678dd2,
    72'h80010000_3_1_a6678dd3, 72'h80010001_3_1_a6678dd4, 72'h80012e13_3_1_a667ae13,
    72'h80012e14_3_1_a667ae14, 72'h80012e15_3_1_a667ae15, 72'h7fffffff_3_1_5999da9f,
    72'h00000000_3_1_00005aa0, 72'h00010000_3_1_00010dd3, 72'hffff0000_3_1_ffffa76d,
    72'hbe8dd078_3_1_d23079a4, 72'hb29d9a8f_3_1_c9d52318, 72'h09c70346_3_1_06d8748f,
    72'h5debeb3f_3_1_41bf061d, 72'h275a112f_3_1_1b8c2b95, 72'h44fdb8cf_3_1_304b8164,
    72'hb4864351_3_1_cb2b3271, 72'h519f680b_3_1_39231321, 72'h0000ae14_3_1_0000d47b,
    72'h0001ae14_3_1_000187ad, 72'hffffae14_3_1_00002148, 72'h0002ae14_3_1_00023ae0
  };

  logic clk = 0, rst_n = 1, tick_enable = 0, load_valid = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0;
  logic [255:0] thermal_node_factor_q30 = {8{32'h40000000}};
  logic [15:0] retained_state = 0;
  logic [7:0] switch_activity = 0;
  frp_m31_scheduler_state_e scheduler_state = FRP_SCHED_FREE;
  logic [255:0] phase_word_q, frequency_current_q16;
  logic [255:0] held_phase, held_frequency;
  int updates = 0, loads = 0, hold_edges = 0, reset_checks = 0;

  always #5 clk = ~clk;
  initial begin #100000; $fatal(1, "Frequency range watchdog"); end

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable, .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30, .retained_state,
    .switch_activity, .scheduler_state, .phase_word_q, .frequency_current_q16,
    .coupling_field_q16(), .phase_projection_q30(), .phase_target(),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30()
  );

  task automatic check_reset();
    for (int cell_index = 0; cell_index < 8; cell_index++) begin
      if (frequency_current_q16[cell_index*32 +: 32] !== 32'h00010000
          || phase_word_q[cell_index*32 +: 32] !== 32'(cell_index * 32'h20000000))
        $fatal(1, "Frequency/phase reset failed cell=%0d", cell_index);
    end
    reset_checks++;
  endtask

  task automatic check_hold();
    if (frequency_current_q16 !== held_frequency || phase_word_q !== held_phase)
      $fatal(1, "Disabled tick changed retained frequency or phase");
    hold_edges++;
  endtask

  initial begin
    // An explicit reset edge also works in two-state simulators.
    #1ps; rst_n = 0;
    #1ps;
    check_reset();
    @(negedge clk); rst_n = 1;
    for (int scheduler = 0; scheduler < 5; scheduler++) begin
      for (int batch = 0; batch < VECTOR_COUNT; batch += 8) begin
        @(negedge clk);
        scheduler_state = frp_m31_scheduler_state_e'(scheduler);
        load_valid = 1;
        tick_enable = 1;
        for (int cell_index = 0; cell_index < 8; cell_index++) begin
          frequency_load_q16[cell_index*32 +: 32] = VECTORS[batch+cell_index][71:40];
          retained_state[cell_index*2 +: 2] = VECTORS[batch+cell_index][37:36];
          switch_activity[cell_index] = VECTORS[batch+cell_index][32];
          phase_load[cell_index*32 +: 32] = 32'(cell_index * 32'h20000000);
        end
        @(posedge clk); #1ps;
        if (frequency_current_q16 !== frequency_load_q16 || phase_word_q !== phase_load)
          $fatal(1, "Load lost priority over tick scheduler=%0d batch=%0d", scheduler, batch);
        loads++;
        held_frequency = frequency_current_q16;
        held_phase = phase_word_q;
        @(negedge clk);
        load_valid = 0; tick_enable = 0;
        frequency_load_q16 = ~frequency_load_q16;
        phase_load = ~phase_load;
        repeat (2) begin @(posedge clk); #1ps; check_hold(); end

        @(negedge clk); tick_enable = 1;
        @(posedge clk); #1ps;
        for (int cell_index = 0; cell_index < 8; cell_index++) begin
          if (frequency_current_q16[cell_index*32 +: 32] !== VECTORS[batch+cell_index][31:0])
            $fatal(1, "Frequency recurrence scheduler=%0d vector=%0d input=%h actual=%h expected=%h",
                   scheduler, batch+cell_index, VECTORS[batch+cell_index][71:40],
                   frequency_current_q16[cell_index*32 +: 32], VECTORS[batch+cell_index][31:0]);
          updates++;
        end
        held_frequency = frequency_current_q16;
        held_phase = phase_word_q;
        @(negedge clk); tick_enable = 0;
        repeat (2) begin @(posedge clk); #1ps; check_hold(); end
      end
    end

    // Assert reset between clock edges while both load and tick are requested.
    @(negedge clk); #1ps;
    load_valid = 1; tick_enable = 1;
    frequency_load_q16 = {8{32'h80000000}};
    phase_load = '1;
    rst_n = 0;
    #1ps; check_reset();
    @(posedge clk); #1ps; check_reset();
    if (updates != 720 || loads != 90 || hold_edges != 360 || reset_checks != 3)
      $fatal(1, "Frequency range scenarios incomplete");
    $display("FRP_M31_FREQUENCY_RANGE_TB: PASS vectors=%0d scheduler_states=5 updates=%0d loads=%0d hold_edges=%0d reset_checks=%0d",
             VECTOR_COUNT, updates, loads, hold_edges, reset_checks);
    $finish;
  end
endmodule : frp_m31_frequency_range_tb
`endif

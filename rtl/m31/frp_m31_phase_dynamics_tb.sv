// SPDX-License-Identifier: Apache-2.0
// FRP M31 clocked phase dynamics with the RTL scheduler.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert,
// -Irtl/m31 and --top-module frp_m31_phase_dynamics_tb.
//
// Two eight-cell workloads run in free, 7/1 and 1/7 for eight ticks each:
// signed-frequency endpoints without coupling, then mixed phases with
// receiver-local gamma_i and nonuniform pairwise thermal attenuation.
// Positive/negative phase wrap and steps larger than one turn are included.
// The actual scheduler drives the phase engine; two paused edges follow
// every enabled tick, without advancing either retained bank or tick index.
//
// GOLD contains offline arbitrary-precision integer reference results,
// with independently evaluated sine values and no DUT helper calls:
//   f_next = sat32(f + round_away((target - f) * 19661 / 65536))
//   velocity = round_away(3932 * f_next / 65536) + push + coupling
//   phase_next = (phase + round_away(velocity * 44798133900177 / 2^32)) mod 2^32
// Coupling uses the pre-tick phase bank, local gamma and thermal factors.
// Packed words place cell 0 in the least-significant 32 bits.
// Each GOLD entry is {phase_bank[255:0], frequency_bank[255:0]}, ordered
// by workload, scheduler mode (free, 7/1, 1/7), then tick 1 through 8.

`ifndef FRP_M31_PHASE_DYNAMICS_TB_SV
`define FRP_M31_PHASE_DYNAMICS_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"
`include "frp_m31_scheduler.sv"

module frp_m31_phase_dynamics_tb;
  import frp_m31_pkg::*;

  localparam logic [255:0] INITIAL_PHASE [0:1] = '{
    256'hc0000000400000007fffffff80000000ffff000000000001fffffff000000000,
    256'h7ff00001000fffffc0000000deadbeef800000014000000012345678ffffffff
  };
  localparam logic [255:0] INITIAL_FREQUENCY [0:1] = '{
    256'h40000000ffff8000000080000000000000010000ffff00007fffffff80000000,
    256'hfffe000000012e140000800000000000ffff800000028000ffff000000010000
  };
  localparam logic [255:0] GAMMA [0:1] = '{
    256'h0000000000000000000000000000000000000000000000000000000000000000,
    256'h20000000f00000001000000080000000c0000000400000000000000026666666
  };
  localparam logic [255:0] THERMAL [0:1] = '{
    256'h0000000000000000000000000000000000000000000000000000000000000000,
    256'h3000000040000000000000001000000040000000200000003000000040000000
  };
  localparam logic [7:0] ACTIVITY [0:1] = '{8'h5a, 8'ha5};
  localparam logic [511:0] GOLD [0:47] = '{
    512'h447e59ad4016999a81c1741b80fce5af02a6c032ff304d85082d00cff9ab0cd7_2ccd1169fffffc6b0000ab0200005aa000010937ffff9e365999da9fa666cccd,
    512'heec49edf4102263a83cc6fca8294cfb3055e4203ff6f54035b6e0625a9608fd0_1f5ca16f000053820000c91d00009a1000010fab00000cf53eb8c824c148547b,
    512'h99ea0c804282aaec860afc6c849944e50820bf24006be835b016f08958768e01_15f455bd000090790000de300000c6780001142f00005a7b2be80d61d4196148,
    512'h2c16c039446b6eb8886d811f86e9cd900aeb08b601ed0fe1d291ec853a470343_0f5e89090000bb260000ecf00000e58d00011758000090bf1ebc5b35e1454ce1,
    512'h79987eef469d3fdc8ae95411896f7e9d0dbabb9103cb29da6b8ca8aba5f9eb32_0ac27b0f0000d9050000f7440000fb4f0001198e0000b6bb15842decea7da25d,
    512'he3d8141f490227b78d76d18f8c1a6daf108e178705ea333d3de57772d893aa82_078872330000edee0000fe7e00010a8a00011b1b0000d1520f101011f0f1dc5b,
    512'hc89e13614b8adee59010b90e8edf76b7136428210836c150053669b1166556f0_054639710000fc910001038d0001153300011c310000e3ef0a8b960ff5766a10,
    512'hcff6928a4e2cbb9392b338b591b6a486163c21a80aa3241f119d8e950f4265a3_03b17890000106d00001071800011caa00011cf30000f0f607620e5bf89fff8d,
    512'h447e59ad4016999a81c1741b80fce5af02a6c032ff304d85082d00cff9ab0cd7_2ccd1169fffffc6b0000ab0200005aa000010937ffff9e365999da9fa666cccd,
    512'heec49edf4102263a83cc6fca8294cfb3055e4203ff6f54035b6e0625a9608fd0_1f5ca16f000053820000c91d00009a1000010fab00000cf53eb8c824c148547b,
    512'h99ea0c804282aaec860afc6c849944e50820bf24006be835b016f08958768e01_15f455bd000090790000de300000c6780001142f00005a7b2be80d61d4196148,
    512'h2c16c039446b6eb8886d811f86e9cd900aeb08b601ed0fe1d291ec853a470343_0f5e89090000bb260000ecf00000e58d00011758000090bf1ebc5b35e1454ce1,
    512'h79987eef469d3fdc8ae95411896f7e9d0dbabb9103cb29da6b8ca8aba5f9eb32_0ac27b0f0000d9050000f7440000fb4f0001198e0000b6bb15842decea7da25d,
    512'he3d8141f490227b78d76d18f8c1a6daf108e178705ea333d3de57772d893aa82_078872330000edee0000fe7e00010a8a00011b1b0000d1520f101011f0f1dc5b,
    512'hc89e13614b8adee59010b90e8edf76b7136428210836c150053669b1166556f0_054639710000fc910001038d0001153300011c310000e3ef0a8b960ff5766a10,
    512'hd03f77244e75a02c92fc1d4f91ff891f168506410aec08b811e6732e0f8b4a3d_03b17890000106d00001071800011caa00011cf30000f0f607620e5bf89fff8d,
    512'h449d8b6f4035cb5c81e0a5de811c177102c5f1f4ff4f7f47084c3291f9ca3e9a_2ccd1169fffffc6b0000ab0200005aa000010937ffff9e365999da9fa666cccd,
    512'heee3d0a1412157fc83eba18d82b40175057d73c5ff8e85c55b8d37e7a97fc193_1f5ca16f000053820000c91d00009a1000010fab00000cf53eb8c824c148547b,
    512'h9a093e4242a1dcae862a2e2f84b876a7083ff0e6008b19f7b036224b5895bfc4_15f455bd000090790000de300000c6780001142f00005a7b2be80d61d4196148,
    512'h2c35f1fb448aa07a888cb2e28708ff520b0a3a78020c41a3d2b11e473a663506_0f5e89090000bb260000ecf00000e58d00011758000090bf1ebc5b35e1454ce1,
    512'h79b7b0b146bc719e8b0885d4898eb05f0dd9ed5303ea5b9c6babda6da6191cf5_0ac27b0f0000d9050000f7440000fb4f0001198e0000b6bb15842decea7da25d,
    512'he3f745e1492159798d9603528c399f7110ad4949060964ff3e04a934d8b2dc45_078872330000edee0000fe7e00010a8a00011b1b0000d1520f101011f0f1dc5b,
    512'hc8bd45234baa10a7902fead18efea879138359e30855f31205559b73168488b3_054639710000fc910001038d0001153300011c310000e3ef0a8b960ff5766a10,
    512'hd015c44c4e4bed5592d26a7891d5d648165b536a0ac255e111bcc0570f619766_03b17890000106d00001071800011caa00011cf30000f0f607620e5bf89fff8d,
    512'h80aceabc01d8c651c1d7e4f8df552d457ce5a85f450d22481090f6e90245b618_fffef43a000120410000b43900005169fffff33400021a9fffff9e3600010937,
    512'h82ed890903ab4200c4093be0e08486b27b2391494909512d1072e25b0471523b_ffff9f2f000116940000d8c800008a65000043d80001d3a800000cf500010fab,
    512'h8656fa45056a0178c6791f0be2142a0a7a57366b4c48be1611597fed06900a21_000016da00010fce0000f25f0000b24900007c4b0001a1fb00005a7b0001142f,
    512'h8aabf82106fdc826c914c6b8e3e8e0227a399c194f05063712ee63d008aa9eb1_00006a9f00010b10000104490000ce350000a3ce00017f36000090bf00011758,
    512'h8fc48ff408516b21cbcefd2ee5ef66ff7a96142b5167b3a914f25ec70ac39bd2_0000a542000107be000110d30000e1c10000bf77000166df0000b6bb0001198e,
    512'h95858a940952ee61ce9eb009e81ab1a57b48a690538b835b173c0f770cdd132e_0000ce4e0001056b0001199a0000ef700000d2d3000155d50000d15200011b1b,
    512'h9bd7313209f6dc5bd17d818aea61adb17c36965855845a4319ad61540ef6104f_0000eb09000103cb00011fbf0000f9040000e061000149e80000e3ef00011c31,
    512'ha2a26ff90a381d42d466d420ecbdfd647d4b5b9457612e491c305dbd110d9ebe_0000ff26000102a80001240c0000ffb80000e9de0001418f0000f0f600011cf3,
    512'h80aceabc01d8c651c1d7e4f8df552d457ce5a85f450d22481090f6e90245b618_fffef43a000120410000b43900005169fffff33400021a9fffff9e3600010937,
    512'h82ed890903ab4200c4093be0e08486b27b2391494909512d1072e25b0471523b_ffff9f2f000116940000d8c800008a65000043d80001d3a800000cf500010fab,
    512'h8656fa45056a0178c6791f0be2142a0a7a57366b4c48be1611597fed06900a21_000016da00010fce0000f25f0000b24900007c4b0001a1fb00005a7b0001142f,
    512'h8aabf82106fdc826c914c6b8e3e8e0227a399c194f05063712ee63d008aa9eb1_00006a9f00010b10000104490000ce350000a3ce00017f36000090bf00011758,
    512'h8fc48ff408516b21cbcefd2ee5ef66ff7a96142b5167b3a914f25ec70ac39bd2_0000a542000107be000110d30000e1c10000bf77000166df0000b6bb0001198e,
    512'h95858a940952ee61ce9eb009e81ab1a57b48a690538b835b173c0f770cdd132e_0000ce4e0001056b0001199a0000ef700000d2d3000155d50000d15200011b1b,
    512'h9bd7313209f6dc5bd17d818aea61adb17c36965855845a4319ad61540ef6104f_0000eb09000103cb00011fbf0000f9040000e061000149e80000e3ef00011c31,
    512'ha2eb54920a8101dbd4afb8b9ed06e1fd7d94402d57aa12e21c79425611568357_0000ff26000102a80001240c0000ffb80000e9de0001418f0000f0f600011cf3,
    512'h80cc1c7e01f7f813c1f716badf745f077d04da21452c540a10b028ab0264e7da_fffef43a000120410000b43900005169fffff33400021a9fffff9e3600010937,
    512'h830cbacb03ca73c2c4286da2e0a3b8747b42c30b492882ef1092141d049083fd_ffff9f2f000116940000d8c800008a65000043d80001d3a800000cf500010fab,
    512'h86762c070589333ac69850cde2335bcc7a76682d4c67efd81178b1af06af3be3_000016da00010fce0000f25f0000b24900007c4b0001a1fb00005a7b0001142f,
    512'h8acb29e3071cf9e8c933f87ae40811e47a58cddb4f2437f9130d959208c9d073_00006a9f00010b10000104490000ce350000a3ce00017f36000090bf00011758,
    512'h8fe3c1b608709ce3cbee2ef0e60e98c17ab545ed5186e56b151190890ae2cd94_0000a542000107be000110d30000e1c10000bf77000166df0000b6bb0001198e,
    512'h95a4bc5609722023cebde1cbe839e3677b67d85253aab51d175b41390cfc44f0_0000ce4e0001056b0001199a0000ef700000d2d3000155d50000d15200011b1b,
    512'h9bf662f40a160e1dd19cb34cea80df737c55c81a55a38c0519cc93160f154211_0000eb09000103cb00011fbf0000f9040000e061000149e80000e3ef00011c31,
    512'ha2c1a1bb0a574f04d48605e2ecdd2f267d6a8d565780600b1c4f8f7f112cd080_0000ff26000102a80001240c0000ffb80000e9de0001418f0000f0f600011cf3
  };

  logic clk = 0, rst_n = 1, tick_enable = 0, load_valid = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0, thermal_node_factor_q30 = 0;
  logic [7:0] switch_activity = 0;
  logic [255:0] phase_word_q, frequency_current_q16;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  frp_m31_scheduler_state_e scheduler_state;
  logic [31:0] tick_index_q, ticks_recorded_q;
  logic [511:0] held_bank;
  int profiles = 0, ticks = 0, hold_edges = 0, loads = 0, resets = 0;
  int state_hits [0:4] = '{default: 0};

  always #5 clk = ~clk;
  initial begin #100000; $fatal(1, "Phase dynamics watchdog"); end

  frp_m31_scheduler scheduler (
    .clk, .rst_n, .tick_enable, .clear_counters(1'b0), .scheduler_mode,
    .scheduler_mode_q(), .scheduler_state_q(scheduler_state),
    .tick_index_q, .period_index_q(), .ticks_recorded_q,
    .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(),
    .scheduler_count_neutralize_q(), .free_enable(), .balance_enable(),
    .commit_enable(), .excite_enable(), .neutralize_enable(),
    .scheduler_mode_reserved(), .scheduler_state_reserved(),
    .scheduler_valid(), .scheduler_counts_valid()
  );

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable, .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30,
    .retained_state(16'h4734), .switch_activity, .scheduler_state,
    .phase_word_q, .frequency_current_q16,
    .coupling_field_q16(), .phase_projection_q30(), .phase_target(),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30()
  );

  function automatic string mode_name(input int mode);
    case (mode)
      0: return "free";
      1: return "7/1";
      2: return "1/7";
      default: return "invalid";
    endcase
  endfunction

  initial begin : qualification
    int expected_state, vector_index;
    for (int workload = 0; workload < 2; workload++) begin
      for (int mode = 0; mode < 3; mode++) begin
        @(negedge clk);
        rst_n = 0; tick_enable = 0; load_valid = 0;
        scheduler_mode = frp_m31_scheduler_mode_e'(mode);
        #1ps;
        for (int cell_index = 0; cell_index < 8; cell_index++) begin
          if (phase_word_q[cell_index*32 +: 32] !== 32'(cell_index) * 32'h20000000
              || frequency_current_q16[cell_index*32 +: 32] !== 32'h00010000)
            $fatal(1, "Phase dynamics reset mismatch cell=%0d", cell_index);
        end
        if (tick_index_q !== 0 || ticks_recorded_q !== 0)
          $fatal(1, "Phase dynamics scheduler reset mismatch");
        resets++;
        @(negedge clk); rst_n = 1;
        phase_load = INITIAL_PHASE[workload];
        frequency_load_q16 = INITIAL_FREQUENCY[workload];
        gamma_effective_word = GAMMA[workload];
        thermal_node_factor_q30 = THERMAL[workload];
        switch_activity = ACTIVITY[workload];
        @(negedge clk); load_valid = 1;
        @(posedge clk); #1ps;
        if ({phase_word_q, frequency_current_q16}
            !== {INITIAL_PHASE[workload], INITIAL_FREQUENCY[workload]})
          $fatal(1, "Phase dynamics initial bank load mismatch");
        loads++;
        @(negedge clk); load_valid = 0;

        for (int step_index = 0; step_index < 8; step_index++) begin
          @(negedge clk); tick_enable = 1;
          #1ps;
          expected_state = mode == 0 ? 0 : mode == 1
            ? (step_index == 7 ? 2 : 1) : (step_index == 0 ? 3 : 4);
          if (scheduler_state !== frp_m31_scheduler_state_e'(expected_state)
              || tick_index_q !== 32'(step_index))
            $fatal(1, "Phase dynamics cadence mismatch mode=%s tick=%0d",
                   mode_name(mode), step_index + 1);
          state_hits[expected_state]++;
          @(posedge clk); #1ps;
          vector_index = workload * 24 + mode * 8 + step_index;
          if ({phase_word_q, frequency_current_q16} !== GOLD[vector_index])
            $fatal(1, "Phase dynamics mismatch workload=%0d mode=%s tick=%0d actual=%h expected=%h",
                   workload, mode_name(mode), step_index + 1,
                   {phase_word_q, frequency_current_q16}, GOLD[vector_index]);
          if (tick_index_q !== 32'(step_index + 1) || ticks_recorded_q !== 32'(step_index + 1))
            $fatal(1, "Phase dynamics scheduler tick count mismatch");
          ticks++;
          $display("FRP_M31_PHASE_DYNAMICS_TICK: workload=%0d mode=%s tick=%0d scheduler=%0d phase=%h frequency=%h",
                   workload, mode_name(mode), step_index + 1, expected_state,
                   phase_word_q, frequency_current_q16);
          held_bank = {phase_word_q, frequency_current_q16};
          @(negedge clk); tick_enable = 0;
          phase_load = ~phase_load;
          frequency_load_q16 = ~frequency_load_q16;
          repeat (2) begin
            @(posedge clk); #1ps;
            if ({phase_word_q, frequency_current_q16} !== held_bank
                || tick_index_q !== 32'(step_index + 1)
                || ticks_recorded_q !== 32'(step_index + 1))
              $fatal(1, "Paused clock edge changed phase, frequency or scheduler");
            hold_edges++;
          end
        end
        profiles++;
        $display("FRP_M31_PHASE_DYNAMICS_PROFILE: PASS workload=%0d mode=%s ticks=8",
                 workload, mode_name(mode));
      end
    end
    if (profiles != 6 || ticks != 48 || hold_edges != 96 || loads != 6 || resets != 6
        || state_hits[0] != 16 || state_hits[1] != 14 || state_hits[2] != 2
        || state_hits[3] != 2 || state_hits[4] != 14)
      $fatal(1, "Phase dynamics scenarios incomplete");
    $display("FRP_M31_PHASE_DYNAMICS_TB: PASS profiles=%0d ticks=%0d phase_words=%0d frequency_words=%0d hold_edges=%0d loads=%0d resets=%0d free_ticks=%0d balance_ticks=%0d commit_ticks=%0d excite_ticks=%0d neutralize_ticks=%0d",
             profiles, ticks, ticks * 8, ticks * 8, hold_edges, loads, resets,
             state_hits[0], state_hits[1], state_hits[2], state_hits[3], state_hits[4]);
    $finish;
  end
endmodule : frp_m31_phase_dynamics_tb
`endif

// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"

// Local gamma stage instantiated by frp_m32_core. Inputs are signed Q16.16.
module frp_m32_gamma_drift_matrix_tb #(parameter int CELLS = 64);
  localparam int SCALE = 65536;
  localparam int PROFILES = 5;
  localparam int PAIRS = (2*SCALE + 1) * PROFILES;
  localparam logic [31:0] NOMINAL = 32'd644245094;

  typedef logic signed [31:0] word_t;
  typedef logic [32*CELLS-1:0] bank_t;
  bit clk, rst_n, tick_enable, gamma_update_valid;
  bank_t gamma_targets_q16, thermal_overload_q16;
  wire [32*CELLS-1:0] gamma_noise_target_q16, gamma_noise_state_q16;
  wire [32*CELLS-1:0] gamma_drift_word, gamma_effective_word;
  wire [32*CELLS-1:0] next_gamma_drift_word, next_gamma_effective_word;
  frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut (.*);

  word_t held_target[CELLS], held_noise[CELLS], held_drift[CELLS];
  int pairs_checked /* verilator public_flat_rw */;
  int stages_checked /* verilator public_flat_rw */;

  // Integer division with nearest rounding and ties away from zero.
  function automatic longint signed nearest(input longint signed x, divisor);
    longint signed magnitude;
    magnitude = x < 0 ? -x : x;
    magnitude = (magnitude + divisor/2) / divisor;
    return x < 0 ? -magnitude : magnitude;
  endfunction

  function automatic int heat_code(input int profile);
    case (profile)
      0: return 0;
      1: return 32767;
      2: return 32768;
      3: return 32769;
      default: return 65536;
    endcase
  endfunction

  task automatic pulse();
    #1; clk = 1; #1; clk = 0;
  endtask

  task automatic run_batch(input int base);
    int ordinal, goal, heat;
    word_t target, noise, drift;
    longint signed gain, radians;
    rst_n = 0; tick_enable = 0; gamma_update_valid = 0;
    gamma_targets_q16 = '0; thermal_overload_q16 = '0;
    pulse();
    if (gamma_noise_target_q16 !== '0 || gamma_noise_state_q16 !== '0 || gamma_drift_word !== '0 ||
        gamma_effective_word !== {CELLS{NOMINAL}})
      $fatal(1, "Reset mismatch base=%0d", base);
    rst_n = 1;
    for (int lane = 0; lane < CELLS; lane++) begin
      held_target[lane] = 0; held_noise[lane] = 0; held_drift[lane] = 0;
    end

    // Load, preview reversal while paused, reuse saved target, commit reversal.
    for (int stage = 0; stage < 4; stage++) begin
      tick_enable = stage != 1;
      gamma_update_valid = stage != 2;
      for (int lane = 0; lane < CELLS; lane++) begin
        ordinal = base + lane;
        if (ordinal >= PAIRS) continue;
        goal = ordinal / PROFILES - SCALE;
        gamma_targets_q16[32*lane +: 32] = stage == 0 ? goal : -goal;
        thermal_overload_q16[32*lane +: 32] = heat_code(ordinal % PROFILES);
      end
      #1;
      for (int lane = 0; lane < CELLS; lane++) begin
        ordinal = base + lane;
        if (ordinal >= PAIRS) continue;
        goal = ordinal / PROFILES - SCALE;
        heat = heat_code(ordinal % PROFILES);
        case (stage)
          0: target = goal;
          2: target = held_target[lane];
          default: target = -goal;
        endcase
        noise = held_noise[lane] +
                word_t'(nearest((longint'(target) - longint'(held_noise[lane])) * 9830, longint'(SCALE)));
        gain = nearest(64'sd5243 * heat, longint'(SCALE));
        radians = nearest(gain * noise, longint'(SCALE));
        drift = word_t'(nearest(radians * 64'sd44798133900177, 64'sd4294967296));
        if ({next_gamma_drift_word[32*lane +: 32], next_gamma_effective_word[32*lane +: 32]}
            !== {drift, NOMINAL + drift})
          $fatal(1, "Preview mismatch cells=%0d lane=%0d target=%0d overload=%0d stage=%0d",
                 CELLS, lane, goal, heat, stage);
        if (stage != 1) begin
          held_target[lane] = target; held_noise[lane] = noise; held_drift[lane] = drift;
        end
      end
      pulse();
      for (int lane = 0; lane < CELLS; lane++) begin
        if (base + lane >= PAIRS) continue;
        if ({gamma_noise_target_q16[32*lane +: 32], gamma_noise_state_q16[32*lane +: 32],
             gamma_drift_word[32*lane +: 32], gamma_effective_word[32*lane +: 32]}
            !== {held_target[lane], held_noise[lane], held_drift[lane], NOMINAL + held_drift[lane]})
          $fatal(1, "Register mismatch cells=%0d lane=%0d ordinal=%0d stage=%0d",
                 CELLS, lane, base + lane, stage);
        stages_checked++;
        if (stage == 3) begin
          if (pairs_checked != base + lane)
            $fatal(1, "Unexpected pair order at ordinal %0d", base + lane);
          pairs_checked++;
        end
      end
    end
  endtask

  initial begin
    pairs_checked = 0; stages_checked = 0;
    for (int base = 0; base < PAIRS; base += CELLS) run_batch(base);
    if (pairs_checked != PAIRS || stages_checked != 4*PAIRS)
      $fatal(1, "Incomplete matrix pairs=%0d stages=%0d", pairs_checked, stages_checked);
    $display("PASS GAMMA_DRIFT_MATRIX cells=%0d targets=131073 profiles=5 pairs=%0d stages=%0d",
             CELLS, pairs_checked, stages_checked);
    $finish;
  end
endmodule

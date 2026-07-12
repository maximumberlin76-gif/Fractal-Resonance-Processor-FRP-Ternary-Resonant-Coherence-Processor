// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 Scheduler State RTL Realization
//
// Project:
//   Fractal Resonance Processor (FRP)
//   Ternary Fractal Resonant Coherence Processor
//
// Version:
//   FRP v1.8.0
//
// Milestone:
//   M16 — RTL Core Realization and Execution Semantics Package
//
// Purpose:
//   Implements the M16 scheduler-state realization for the explicit
//   FRP execution modes:
//
//     - free
//     - 7/1
//     - 1/7
//
// This module preserves the M15-qualified temporal execution semantics:
//   - free mode: every enabled tick is free / commit-capable
//   - 7/1 mode: seven balance ticks followed by one commit tick
//   - 1/7 mode: one excite tick followed by seven neutralize ticks
//
// Required inherited profiles:
//   - free: 16 ticks -> free = 16
//   - 7/1: 64 ticks -> balance = 56, commit = 8
//   - 1/7: 16 ticks -> excite = 2, neutralize = 14

`ifndef FRP_M16_SCHEDULER_SV
`define FRP_M16_SCHEDULER_SV

`include "frp_m16_pkg.sv"

module frp_m16_scheduler #(
  parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
  input  logic clk,
  input  logic rst_n,

  input  logic tick_enable,
  input  logic clear_counters,

  input  frp_m16_pkg::frp_m16_scheduler_mode_e scheduler_mode,

  output frp_m16_pkg::frp_m16_scheduler_mode_e  scheduler_mode_q,
  output frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state_q,

  output logic [COUNTER_BITS-1:0] tick_index_q,
  output logic [2:0]              period_index_q,

  output logic [COUNTER_BITS-1:0] ticks_recorded_q,

  output logic [COUNTER_BITS-1:0] scheduler_count_free_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_balance_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_commit_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_excite_q,
  output logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q,

  output logic free_enable,
  output logic balance_enable,
  output logic commit_enable,
  output logic excite_enable,
  output logic neutralize_enable,

  output logic scheduler_mode_reserved,
  output logic scheduler_state_reserved,
  output logic scheduler_valid,
  output logic scheduler_counts_valid
);

  import frp_m16_pkg::*;

  // --------------------------------------------------------------------------
  // Internal next-state signals
  // --------------------------------------------------------------------------

  frp_m16_scheduler_mode_e  scheduler_mode_d;
  frp_m16_scheduler_state_e scheduler_state_d;

  logic [COUNTER_BITS-1:0] tick_index_d;
  logic [2:0]              period_index_d;

  logic [COUNTER_BITS-1:0] ticks_recorded_d;

  logic [COUNTER_BITS-1:0] scheduler_count_free_d;
  logic [COUNTER_BITS-1:0] scheduler_count_balance_d;
  logic [COUNTER_BITS-1:0] scheduler_count_commit_d;
  logic [COUNTER_BITS-1:0] scheduler_count_excite_d;
  logic [COUNTER_BITS-1:0] scheduler_count_neutralize_d;

  logic [COUNTER_BITS-1:0] scheduler_count_sum;

  // --------------------------------------------------------------------------
  // Mode registration
  // --------------------------------------------------------------------------

  always_comb begin
    if (frp_is_valid_scheduler_mode(scheduler_mode)) begin
      scheduler_mode_d = scheduler_mode;
    end else begin
      scheduler_mode_d = FRP_MODE_RESERVED;
    end
  end

  // --------------------------------------------------------------------------
  // Period index and scheduler-state decode
  // --------------------------------------------------------------------------

  always_comb begin
    period_index_d = tick_index_q[2:0];

    scheduler_state_d =
      frp_decode_scheduler_state(
        scheduler_mode_d,
        period_index_d
      );
  end

  // --------------------------------------------------------------------------
  // Scheduler enable decode
  // --------------------------------------------------------------------------

  always_comb begin
    free_enable       = 1'b0;
    balance_enable    = 1'b0;
    commit_enable     = 1'b0;
    excite_enable     = 1'b0;
    neutralize_enable = 1'b0;

    unique case (scheduler_state_q)
      FRP_SCHED_FREE: begin
        free_enable = tick_enable;
      end

      FRP_SCHED_BALANCE: begin
        balance_enable = tick_enable;
      end

      FRP_SCHED_COMMIT: begin
        commit_enable = tick_enable;
      end

      FRP_SCHED_EXCITE: begin
        excite_enable = tick_enable;
      end

      FRP_SCHED_NEUTRALIZE: begin
        neutralize_enable = tick_enable;
      end

      default: begin
        free_enable       = 1'b0;
        balance_enable    = 1'b0;
        commit_enable     = 1'b0;
        excite_enable     = 1'b0;
        neutralize_enable = 1'b0;
      end
    endcase
  end

  // --------------------------------------------------------------------------
  // Reserved-mode and reserved-state detection
  // --------------------------------------------------------------------------

  always_comb begin
    scheduler_mode_reserved =
      (scheduler_mode_q == FRP_MODE_RESERVED);

    scheduler_state_reserved =
      !frp_scheduler_state_is_valid(scheduler_state_q);

    scheduler_valid =
      !scheduler_mode_reserved &&
      !scheduler_state_reserved;
  end

  // --------------------------------------------------------------------------
  // Counter next-state logic
  // --------------------------------------------------------------------------

  always_comb begin
    tick_index_d = tick_index_q;

    ticks_recorded_d = ticks_recorded_q;

    scheduler_count_free_d       = scheduler_count_free_q;
    scheduler_count_balance_d    = scheduler_count_balance_q;
    scheduler_count_commit_d     = scheduler_count_commit_q;
    scheduler_count_excite_d     = scheduler_count_excite_q;
    scheduler_count_neutralize_d = scheduler_count_neutralize_q;

    if (clear_counters) begin
      ticks_recorded_d = '0;

      scheduler_count_free_d       = '0;
      scheduler_count_balance_d    = '0;
      scheduler_count_commit_d     = '0;
      scheduler_count_excite_d     = '0;
      scheduler_count_neutralize_d = '0;
    end

    if (tick_enable) begin
      tick_index_d = tick_index_q + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

      ticks_recorded_d =
        ticks_recorded_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};

      unique case (scheduler_state_d)
        FRP_SCHED_FREE: begin
          scheduler_count_free_d =
            scheduler_count_free_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end

        FRP_SCHED_BALANCE: begin
          scheduler_count_balance_d =
            scheduler_count_balance_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end

        FRP_SCHED_COMMIT: begin
          scheduler_count_commit_d =
            scheduler_count_commit_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end

        FRP_SCHED_EXCITE: begin
          scheduler_count_excite_d =
            scheduler_count_excite_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end

        FRP_SCHED_NEUTRALIZE: begin
          scheduler_count_neutralize_d =
            scheduler_count_neutralize_d + {{(COUNTER_BITS-1){1'b0}}, 1'b1};
        end

        default: begin
          scheduler_count_free_d       = scheduler_count_free_d;
          scheduler_count_balance_d    = scheduler_count_balance_d;
          scheduler_count_commit_d     = scheduler_count_commit_d;
          scheduler_count_excite_d     = scheduler_count_excite_d;
          scheduler_count_neutralize_d = scheduler_count_neutralize_d;
        end
      endcase
    end
  end

  // --------------------------------------------------------------------------
  // Sequential state
  // --------------------------------------------------------------------------

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scheduler_mode_q  <= FRP_MODE_FREE;
      scheduler_state_q <= FRP_SCHED_FREE;

      tick_index_q   <= '0;
      period_index_q <= 3'd0;

      ticks_recorded_q <= '0;

      scheduler_count_free_q       <= '0;
      scheduler_count_balance_q    <= '0;
      scheduler_count_commit_q     <= '0;
      scheduler_count_excite_q     <= '0;
      scheduler_count_neutralize_q <= '0;
    end else begin
      scheduler_mode_q  <= scheduler_mode_d;
      scheduler_state_q <= scheduler_state_d;

      tick_index_q   <= tick_index_d;
      period_index_q <= period_index_d;

      ticks_recorded_q <= ticks_recorded_d;

      scheduler_count_free_q       <= scheduler_count_free_d;
      scheduler_count_balance_q    <= scheduler_count_balance_d;
      scheduler_count_commit_q     <= scheduler_count_commit_d;
      scheduler_count_excite_q     <= scheduler_count_excite_d;
      scheduler_count_neutralize_q <= scheduler_count_neutralize_d;
    end
  end

  // --------------------------------------------------------------------------
  // Scheduler count validity
  // --------------------------------------------------------------------------

  always_comb begin
    scheduler_count_sum =
      scheduler_count_free_q       +
      scheduler_count_balance_q    +
      scheduler_count_commit_q     +
      scheduler_count_excite_q     +
      scheduler_count_neutralize_q;

    scheduler_counts_valid =
      (scheduler_count_sum == ticks_recorded_q);
  end

endmodule : frp_m16_scheduler

`endif

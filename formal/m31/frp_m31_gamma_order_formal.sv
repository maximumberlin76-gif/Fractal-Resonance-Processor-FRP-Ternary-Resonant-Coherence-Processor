// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Relational safety of the actual local-gamma noise update.
// Two lanes with the same selected target cannot reverse their order or
// increase their separation. A separation >= 7 Q16 integer units contracts.
// This is a one-step, all-state contract, not a bounded simulation.
// No reset, reachability, target-range or thermal-range assumption is used.
// Prove combinational outputs with retained registers left unconstrained.
// Candidate updates are checked even when tick_enable is low; committing
// both candidates on an enabled tick transfers the relation to the registers.
// Repeated shared-target updates reach a separation <= 6, not necessarily 0.
// Pauses do not count as updates. No fairness or wall-clock deadline is claimed.
// Internal observation is deliberate: no copied recurrence or replacement DUT.
// A successful compile or a SAT witness is not a completed safety proof.
// Check all three property outputs universally, then require all four witnesses.
// Frontend: read_slang --top frp_m31_gamma_order_formal -Irtl/m31
//           formal/m31/frp_m31_gamma_order_formal.sv
`ifndef FRP_M31_GAMMA_ORDER_FORMAL_SV
`define FRP_M31_GAMMA_ORDER_FORMAL_SV
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"

module frp_m31_gamma_order_formal #(
    parameter int CELLS = 8,
    parameter int LANE_A = 0,
    parameter int LANE_B = CELLS-1
) (
    input logic clk, rst_n, tick_enable, gamma_update_valid,
    input logic [32*CELLS-1:0] gamma_targets_q16,
    input logic [32*CELLS-1:0] thermal_overload_q16,
    output wire same_target,
    output wire order_preserved,
    output wire separation_nonincreasing,
    output wire strict_contraction,
    output wire all_properties,
    output wire [3:0] witness
);
    typedef logic signed [63:0] wide_t;

    initial begin
        a_size: assert (CELLS >= 2);
        a_lane_a: assert (LANE_A >= 0 && LANE_A < CELLS);
        a_lane_b: assert (LANE_B >= 0 && LANE_B < CELLS);
        a_distinct: assert (LANE_A != LANE_B);
    end

    wire [32*CELLS-1:0] targets, noises;

    frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tick_enable(tick_enable),
        .gamma_update_valid(gamma_update_valid),
        .gamma_targets_q16(gamma_targets_q16),
        .thermal_overload_q16(thermal_overload_q16),
        .gamma_noise_target_q16(targets),
        .gamma_noise_state_q16(noises),
        .gamma_drift_word(),
        .gamma_effective_word(),
        .next_gamma_drift_word(),
        .next_gamma_effective_word()
    );

    wire signed [31:0] noise_a = noises[32*LANE_A +: 32];
    wire signed [31:0] noise_b = noises[32*LANE_B +: 32];

    wire signed [31:0] target_a = gamma_update_valid
        ? gamma_targets_q16[32*LANE_A +: 32]
        : targets[32*LANE_A +: 32];

    wire signed [31:0] target_b = gamma_update_valid
        ? gamma_targets_q16[32*LANE_B +: 32]
        : targets[32*LANE_B +: 32];

    wire signed [31:0] next_a = dut.g_cell[LANE_A].noise_d;
    wire signed [31:0] next_b = dut.g_cell[LANE_B].noise_d;

    // Widen before subtracting: the full signed-word span is 4294967295.
    wire signed [63:0] gap =
        wide_t'(noise_b) - wide_t'(noise_a);
    wire signed [63:0] next_gap =
        wide_t'(next_b) - wide_t'(next_a);

    wire signed [63:0] distance_now = gap < 0 ? -gap : gap;
    wire signed [63:0] distance_next =
        next_gap < 0 ? -next_gap : next_gap;

    assign same_target = target_a == target_b;

    assign order_preserved = !same_target
        || ((gap >= 0 && next_gap >= 0)
         || (gap <= 0 && next_gap <= 0));

    assign separation_nonincreasing =
        !same_target || distance_next <= distance_now;

    assign strict_contraction =
        !same_target || distance_now < 64'sd7
        || distance_next < distance_now;

    assign all_properties =
        order_preserved && separation_nonincreasing
        && strict_contraction;

    always_comb begin
        a_order: assert (order_preserved);
        a_nonexpansion: assert (separation_nonincreasing);
        a_contraction: assert (strict_contraction);
    end

    // SAT witnesses exercise each premise, including the irreducible band.
    // These are all-state witnesses, not reset-reachability claims.
    assign witness[0] =
        same_target && gap > 64'sd6 && next_gap > 0
        && distance_next < distance_now;

    assign witness[1] =
        same_target && gap < -64'sd6 && next_gap < 0
        && distance_next < distance_now;

    assign witness[2] =
        same_target && target_a == 0
        && noise_a == -32'sd3 && noise_b == 32'sd3
        && next_a == noise_a && next_b == noise_b;

    assign witness[3] =
        same_target && noise_a == 32'sh80000000
        && noise_b == 32'sh7fffffff
        && distance_next < distance_now;
endmodule
`endif

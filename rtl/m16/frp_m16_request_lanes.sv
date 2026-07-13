// SPDX-License-Identifier: Apache-2.0
/*
    FRP M16 Request-Lane Arbitration Module

    Project:
        Fractal Resonance Processor (FRP)
        Ternary Fractal Resonant Coherence Processor

    Version:
        FRP v1.8.0

    Milestone:
        M16 — RTL Core Realization and Execution Semantics Package

    Purpose:
        Compute the deterministic request-lane arbitration boundary for the
        M16 retained-state RTL execution layer.

        This module preserves:

        - CELLS parameterization;
        - current_state indexed by element_index;
        - target_state indexed by element_index;
        - request_mask generation;
        - accepted_mask generation;
        - deterministic REQUEST_LANES capacity;
        - requested_changes counting;
        - accepted_changes counting.

        The module does not perform active-neutral routing.
        It only determines which requested state changes are admitted into
        the current execution tick.

    Verilator portability:
        The local identifier "cell" is not used.
        Dynamic packed-vector bit assignment is avoided.
*/

`timescale 1ns / 1ps

import frp_m16_pkg::*;

module frp_m16_request_lanes #(
    parameter int CELLS = FRP_M16_DEFAULT_CELLS,
    parameter int COUNTER_BITS = FRP_M16_COUNTER_BITS
) (
    input  logic clk,
    input  logic rst_n,
    input  logic enable,

    input  frp_tern_t current_state [CELLS],
    input  frp_tern_t target_state  [CELLS],

    output logic [CELLS-1:0] request_mask,
    output logic [CELLS-1:0] accepted_mask,

    output logic [COUNTER_BITS-1:0] request_lanes,
    output logic [COUNTER_BITS-1:0] requested_changes,
    output logic [COUNTER_BITS-1:0] accepted_changes
);

    localparam int REQUEST_LANES_INT = frp_calc_request_lanes(CELLS);

    logic [CELLS-1:0] next_request_mask;
    logic [CELLS-1:0] next_accepted_mask;
    logic [CELLS-1:0] one_hot_mask;

    logic [COUNTER_BITS-1:0] next_requested_changes;
    logic [COUNTER_BITS-1:0] next_accepted_changes;

    int element_index;
    int accepted_count;

    always_comb begin
        next_request_mask      = '0;
        next_accepted_mask     = '0;
        next_requested_changes = '0;
        next_accepted_changes  = '0;
        accepted_count         = 0;
        one_hot_mask           = '0;

        for (element_index = 0; element_index < CELLS; element_index = element_index + 1) begin
            one_hot_mask = {{(CELLS - 1){1'b0}}, 1'b1} << element_index;

            if (
                frp_is_valid_ternary(current_state[element_index])
                && frp_is_valid_ternary(target_state[element_index])
                && (current_state[element_index] != target_state[element_index])
            ) begin
                next_request_mask = next_request_mask | one_hot_mask;
                next_requested_changes = next_requested_changes + 1;

                if (accepted_count < REQUEST_LANES_INT) begin
                    next_accepted_mask = next_accepted_mask | one_hot_mask;
                    next_accepted_changes = next_accepted_changes + 1;
                    accepted_count = accepted_count + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            request_mask      <= '0;
            accepted_mask     <= '0;
            request_lanes     <= REQUEST_LANES_INT;
            requested_changes <= '0;
            accepted_changes  <= '0;
        end else if (enable) begin
            request_mask      <= next_request_mask;
            accepted_mask     <= next_accepted_mask;
            request_lanes     <= REQUEST_LANES_INT;
            requested_changes <= next_requested_changes;
            accepted_changes  <= next_accepted_changes;
        end
    end

endmodule

// SPDX-License-Identifier: Apache-2.0
/*
    FRP M16 Request-Lane Arbitration Module

    Project:
        Fractal Resonance Processor (FRP)
        Ternary Fractal Resonant Coherence Processor

    Version:
        FRP v1.8.0

    Milestone:
        M16 RTL Core Realization and Execution Semantics Package

    Purpose:
        Compute deterministic request-lane admission for the M16 retained-state
        RTL execution layer.

        Preserved semantics:
            - CELLS parameterization;
            - retained current_state array;
            - target_state array;
            - request_mask generation;
            - accepted_mask generation;
            - deterministic REQUEST_LANES capacity;
            - requested_changes counter;
            - accepted_changes counter.

        This module does not perform active-neutral routing.
        It only admits requested state changes into the current execution tick.
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

    logic [CELLS-1:0] request_mask_next;
    logic [CELLS-1:0] accepted_mask_next;
    logic [CELLS-1:0] lane_bit;

    logic [COUNTER_BITS-1:0] requested_changes_next;
    logic [COUNTER_BITS-1:0] accepted_changes_next;
    logic [COUNTER_BITS-1:0] request_lanes_next;

    int idx;
    int accepted_count;

    always_comb begin
        request_mask_next      = '0;
        accepted_mask_next     = '0;
        requested_changes_next = '0;
        accepted_changes_next  = '0;
        request_lanes_next     = REQUEST_LANES_INT;
        accepted_count         = 0;
        lane_bit               = '0;

        for (idx = 0; idx < CELLS; idx = idx + 1) begin
            lane_bit = '0;
            lane_bit = ({{(CELLS - 1){1'b0}}, 1'b1} << idx);

            if (
                frp_is_valid_ternary(current_state[idx])
                && frp_is_valid_ternary(target_state[idx])
                && (current_state[idx] != target_state[idx])
            ) begin
                request_mask_next = request_mask_next | lane_bit;
                requested_changes_next = requested_changes_next
                    + {{(COUNTER_BITS - 1){1'b0}}, 1'b1};

                if (accepted_count < REQUEST_LANES_INT) begin
                    accepted_mask_next = accepted_mask_next | lane_bit;
                    accepted_changes_next = accepted_changes_next
                        + {{(COUNTER_BITS - 1){1'b0}}, 1'b1};
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
            request_mask      <= request_mask_next;
            accepted_mask     <= accepted_mask_next;
            request_lanes     <= request_lanes_next;
            requested_changes <= requested_changes_next;
            accepted_changes  <= accepted_changes_next;
        end
    end

endmodule

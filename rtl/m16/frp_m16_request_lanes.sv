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
        Compute the deterministic request-lane boundary for the M16 RTL
        retained-state execution layer.

        This module preserves the FRP cell-array execution semantics:

            - CELLS defines the number of retained-state processing elements.
            - current_state[element_index] is the retained ternary state.
            - target_state[element_index] is the requested ternary target.
            - request_mask[element_index] marks a requested state change.
            - accepted_mask[element_index] marks an admitted state change.

        The module derives:

            - request_mask;
            - accepted_mask;
            - request_lanes;
            - requested_changes;
            - accepted_changes.

        It preserves the inherited M15/M16 transition-capacity relation:

            REQUEST_LANES = max(1, round(CELLS × 0.25))

        The module does not perform active-neutral transition routing.
        It only determines which requested state changes are admitted into
        the current execution tick.

    Verilator portability:
        The local identifier named "cell" is not used anywhere in this
        source file because Verilator treats that token as a Verilog
        configuration reserved word. The FRP cell-array architecture is
        preserved; only the local iteration identifier is named
        "element_index".
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

    logic [COUNTER_BITS-1:0] next_requested_changes;
    logic [COUNTER_BITS-1:0] next_accepted_changes;

    int element_index;
    int accepted_count;

    function automatic logic request_is_valid_change(
        input frp_tern_t current_value,
        input frp_tern_t target_value
    );
        begin
            request_is_valid_change =
                frp_is_valid_ternary(current_value)
                && frp_is_valid_ternary(target_value)
                && (current_value != target_value);
        end
    endfunction

    function automatic logic [COUNTER_BITS-1:0] counter_one();
        begin
            counter_one = '0;
            counter_one[0] = 1'b1;
        end
    endfunction

    function automatic logic [COUNTER_BITS-1:0] request_lane_count();
        logic [COUNTER_BITS-1:0] value;
        int bit_index;
        int lane_value;
        begin
            value = '0;
            lane_value = REQUEST_LANES_INT;

            for (bit_index = 0; bit_index < COUNTER_BITS; bit_index = bit_index + 1) begin
                value[bit_index] = lane_value % 2;
                lane_value = lane_value / 2;
            end

            request_lane_count = value;
        end
    endfunction

    always_comb begin
        next_request_mask      = '0;
        next_accepted_mask     = '0;
        next_requested_changes = '0;
        next_accepted_changes  = '0;
        accepted_count         = 0;

        for (element_index = 0; element_index < CELLS; element_index = element_index + 1) begin
            if (request_is_valid_change(
                current_state[element_index],
                target_state[element_index]
            )) begin
                next_request_mask[element_index] = 1'b1;
                next_requested_changes = next_requested_changes + counter_one();

                if (accepted_count < REQUEST_LANES_INT) begin
                    next_accepted_mask[element_index] = 1'b1;
                    next_accepted_changes = next_accepted_changes + counter_one();
                    accepted_count = accepted_count + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            request_mask      <= '0;
            accepted_mask     <= '0;
            request_lanes     <= request_lane_count();
            requested_changes <= '0;
            accepted_changes  <= '0;
        end else if (enable) begin
            request_mask      <= next_request_mask;
            accepted_mask     <= next_accepted_mask;
            request_lanes     <= request_lane_count();
            requested_changes <= next_requested_changes;
            accepted_changes  <= next_accepted_changes;
        end
    end

endmodule

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

        This module preserves the FRP retained-state array semantics:

            - CELLS defines the number of retained-state processing elements.
            - current_state[element_index] is the current retained ternary state.
            - target_state[element_index] is the requested target ternary state.
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

        This module does not perform active-neutral transition routing.
        It only determines which requested state changes are admitted into
        the current execution tick.

    Verilator portability:
        The local identifier "cell" is not used because Verilator treats it
        as a Verilog configuration reserved word.
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

    function automatic logic admission_capacity_available(
        input int current_accepted_count
    );
        begin
            admission_capacity_available = (current_accepted_count < REQUEST_LANES_INT);
        end
    endfunction

    function automatic logic [COUNTER_BITS-1:0] counter_increment();
        begin
            counter_increment = '0;
            counter_increment[0] = 1'b1;
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
                next_requested_changes = next_requested_changes + counter_increment();

                if (admission_capacity_available(accepted_count)) begin
                    next_accepted_mask[element_index] = 1'b1;
                    next_accepted_changes = next_accepted_changes + counter_increment();
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

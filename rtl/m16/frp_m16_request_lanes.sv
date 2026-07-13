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
        It only admits requested changes into the current execution tick.
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

    localparam logic [COUNTER_BITS-1:0] REQUEST_LANES_VALUE =
        REQUEST_LANES_INT;

    localparam logic [COUNTER_BITS-1:0] COUNTER_ONE =
        {{(COUNTER_BITS - 1){1'b0}}, 1'b1};

    localparam logic [CELLS-1:0] ONE_HOT_LSB =
        {{(CELLS - 1){1'b0}}, 1'b1};

    logic [CELLS-1:0] request_mask_next;
    logic [CELLS-1:0] accepted_mask_next;
    logic [CELLS-1:0] one_hot_mask;

    logic [COUNTER_BITS-1:0] requested_changes_next;
    logic [COUNTER_BITS-1:0] accepted_changes_next;

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
            admission_capacity_available =
                (current_accepted_count < REQUEST_LANES_INT);
        end
    endfunction

    function automatic logic [CELLS-1:0] one_hot_for_index(
        input int requested_index
    );
        begin
            one_hot_for_index = ONE_HOT_LSB << requested_index;
        end
    endfunction

    always_comb begin
        request_mask_next      = '0;
        accepted_mask_next     = '0;
        requested_changes_next = '0;
        accepted_changes_next  = '0;
        one_hot_mask           = '0;
        accepted_count         = 0;

        for (
            element_index = 0;
            element_index < CELLS;
            element_index = element_index + 1
        ) begin
            one_hot_mask = one_hot_for_index(element_index);

            if (
                request_is_valid_change(
                    current_state[element_index],
                    target_state[element_index]
                )
            ) begin
                request_mask_next =
                    request_mask_next | one_hot_mask;

                requested_changes_next =
                    requested_changes_next + COUNTER_ONE;

                if (admission_capacity_available(accepted_count)) begin
                    accepted_mask_next =
                        accepted_mask_next | one_hot_mask;

                    accepted_changes_next =
                        accepted_changes_next + COUNTER_ONE;

                    accepted_count = accepted_count + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            request_mask      <= '0;
            accepted_mask     <= '0;
            request_lanes     <= REQUEST_LANES_VALUE;
            requested_changes <= '0;
            accepted_changes  <= '0;
        end else if (enable) begin
            request_mask      <= request_mask_next;
            accepted_mask     <= accepted_mask_next;
            request_lanes     <= REQUEST_LANES_VALUE;
            requested_changes <= requested_changes_next;
            accepted_changes  <= accepted_changes_next;
        end
    end

endmodule

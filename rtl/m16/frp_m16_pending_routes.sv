// SPDX-License-Identifier: Apache-2.0
/*
    FRP M16 Pending-Route Register Module

    Project:
        Fractal Resonance Processor (FRP)
        Ternary Fractal Resonant Coherence Processor

    Version:
        FRP v1.8.0

    Milestone:
        M16 RTL Core Realization and Execution Semantics Package

    Purpose:
        Implements retained pending-route storage for active-neutral routed
        opposite-polarity transitions.

        Required M16 routing law:

            -1 -> 0 -> +1
            +1 -> 0 -> -1

        A direct opposite-polarity request is not committed directly.
        The current tick routes the retained state to active neutral 0.
        The requested opposite polarity is stored as a pending route.
        A later eligible tick completes the pending route from 0.

    Verilator portability:
        This source does not use the lowercase reserved identifier that
        Verilator treats as a Verilog configuration keyword.
*/

`ifndef FRP_M16_PENDING_ROUTES_SV
`define FRP_M16_PENDING_ROUTES_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"

module frp_m16_pending_routes #(
    parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
    parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
    parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
    parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
    parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
    input logic clk,
    input logic rst_n,
    input logic tick_enable,

    input logic [(CELLS * STATE_BITS) - 1:0] state_q,

    input logic [REQUEST_LANES - 1:0] request_accept,
    input logic [REQUEST_LANES - 1:0] request_neutralized,
    input logic [(REQUEST_LANES * CELL_INDEX_BITS) - 1:0] request_cell_index,
    input logic [(REQUEST_LANES * STATE_BITS) - 1:0] request_target,

    input logic [CELLS - 1:0] pending_completion_accept_mask,

    output logic [(CELLS * STATE_BITS) - 1:0] pending_route_q,
    output logic [(CELLS * STATE_BITS) - 1:0] pending_route_d,

    output logic [CELLS - 1:0] pending_active_mask,
    output logic [CELLS - 1:0] pending_created_mask,
    output logic [CELLS - 1:0] pending_completed_mask,
    output logic [CELLS - 1:0] pending_cleared_mask,
    output logic [CELLS - 1:0] pending_retained_mask,
    output logic [CELLS - 1:0] pending_blocked_mask,
    output logic [CELLS - 1:0] pending_reserved_mask,
    output logic [CELLS - 1:0] pending_overflow_mask,

    output logic [COUNTER_BITS - 1:0] pending_active_count,
    output logic [COUNTER_BITS - 1:0] pending_created_events,
    output logic [COUNTER_BITS - 1:0] pending_completed_events,
    output logic [COUNTER_BITS - 1:0] pending_cleared_events,
    output logic [COUNTER_BITS - 1:0] pending_retained_events,
    output logic [COUNTER_BITS - 1:0] pending_reserved_events,

    output logic [COUNTER_BITS - 1:0] neutral_routed_events,
    output logic [COUNTER_BITS - 1:0] prevented_direct_events,
    output logic [COUNTER_BITS - 1:0] queue_overflow_events,
    output logic [COUNTER_BITS - 1:0] actual_direct_events,

    output logic pending_domain_valid,
    output logic pending_polarity_valid,
    output logic pending_completion_from_zero_valid,
    output logic pending_non_overwrite_valid,
    output logic pending_capacity_valid,
    output logic pending_replay_deterministic,

    output logic no_pending_reserved_state,
    output logic no_queue_overflow,
    output logic no_actual_direct_events
);

    import frp_m16_pkg::*;

    localparam logic [COUNTER_BITS - 1:0] COUNTER_ONE =
        {{(COUNTER_BITS - 1){1'b0}}, 1'b1};

    function automatic logic [STATE_BITS - 1:0] state_value_at_index(
        input logic [(CELLS * STATE_BITS) - 1:0] packed_state,
        input int element_index
    );
        begin
            state_value_at_index =
                packed_state[(element_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] pending_q_value_at_index(
        input int element_index
    );
        begin
            pending_q_value_at_index =
                pending_route_q[(element_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] pending_d_value_at_index(
        input int element_index
    );
        begin
            pending_d_value_at_index =
                pending_route_d[(element_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    function automatic logic [CELL_INDEX_BITS - 1:0] lane_index_value(
        input int lane_index
    );
        begin
            lane_index_value =
                request_cell_index[(lane_index * CELL_INDEX_BITS) +: CELL_INDEX_BITS];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] lane_target_value(
        input int lane_index
    );
        begin
            lane_target_value =
                request_target[(lane_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    task automatic set_pending_d_at_index(
        input int element_index,
        input logic [STATE_BITS - 1:0] route_value
    );
        begin
            pending_route_d[(element_index * STATE_BITS) +: STATE_BITS] =
                route_value;
        end
    endtask

    always_comb begin
        pending_route_d = pending_route_q;

        pending_active_mask = '0;
        pending_created_mask = '0;
        pending_completed_mask = '0;
        pending_cleared_mask = '0;
        pending_retained_mask = '0;
        pending_blocked_mask = '0;
        pending_reserved_mask = '0;
        pending_overflow_mask = '0;

        pending_active_count = '0;
        pending_created_events = '0;
        pending_completed_events = '0;
        pending_cleared_events = '0;
        pending_retained_events = '0;
        pending_reserved_events = '0;

        neutral_routed_events = '0;
        prevented_direct_events = '0;
        queue_overflow_events = '0;
        actual_direct_events = '0;

        pending_domain_valid = 1'b1;
        pending_polarity_valid = 1'b1;
        pending_completion_from_zero_valid = 1'b1;
        pending_non_overwrite_valid = 1'b1;
        pending_capacity_valid = 1'b1;
        pending_replay_deterministic = 1'b1;

        no_pending_reserved_state = 1'b1;
        no_queue_overflow = 1'b1;
        no_actual_direct_events = 1'b1;

        for (int element_index = 0; element_index < CELLS; element_index = element_index + 1) begin
            logic [STATE_BITS - 1:0] pending_value;
            logic [STATE_BITS - 1:0] retained_state;

            pending_value =
                pending_q_value_at_index(element_index);

            retained_state =
                state_value_at_index(state_q, element_index);

            if (!frp_is_valid_ternary(pending_value)) begin
                pending_reserved_mask[element_index] = 1'b1;
                pending_reserved_events =
                    pending_reserved_events + COUNTER_ONE;
                pending_domain_valid = 1'b0;
                no_pending_reserved_state = 1'b0;

                set_pending_d_at_index(element_index, FRP_STATE_ZERO);
            end else if (frp_is_nonzero(pending_value)) begin
                pending_active_mask[element_index] = 1'b1;

                if (
                    tick_enable
                    && pending_completion_accept_mask[element_index]
                ) begin
                    if (!frp_is_zero(retained_state)) begin
                        pending_completion_from_zero_valid = 1'b0;
                    end

                    set_pending_d_at_index(element_index, FRP_STATE_ZERO);

                    pending_completed_mask[element_index] = 1'b1;
                    pending_cleared_mask[element_index] = 1'b1;

                    pending_completed_events =
                        pending_completed_events + COUNTER_ONE;
                    pending_cleared_events =
                        pending_cleared_events + COUNTER_ONE;
                end else begin
                    pending_retained_mask[element_index] = 1'b1;
                    pending_retained_events =
                        pending_retained_events + COUNTER_ONE;
                end
            end
        end

        if (tick_enable) begin
            for (int lane_index = 0; lane_index < REQUEST_LANES; lane_index = lane_index + 1) begin
                logic [CELL_INDEX_BITS - 1:0] packed_index_value;
                int element_index_int;
                logic [STATE_BITS - 1:0] target_value;
                logic [STATE_BITS - 1:0] existing_pending;

                packed_index_value =
                    lane_index_value(lane_index);

                element_index_int =
                    int'(packed_index_value);

                target_value =
                    lane_target_value(lane_index);

                if (request_accept[lane_index] && request_neutralized[lane_index]) begin
                    prevented_direct_events =
                        prevented_direct_events + COUNTER_ONE;
                    neutral_routed_events =
                        neutral_routed_events + COUNTER_ONE;

                    if (element_index_int < CELLS) begin
                        existing_pending =
                            pending_q_value_at_index(element_index_int);

                        if (!frp_is_valid_ternary(target_value)) begin
                            pending_reserved_mask[element_index_int] = 1'b1;
                            pending_polarity_valid = 1'b0;
                            pending_domain_valid = 1'b0;
                            no_pending_reserved_state = 1'b0;
                        end else if (!frp_is_nonzero(target_value)) begin
                            pending_polarity_valid = 1'b0;
                        end else if (
                            frp_is_nonzero(existing_pending)
                            && !pending_completion_accept_mask[element_index_int]
                        ) begin
                            pending_blocked_mask[element_index_int] = 1'b1;
                            pending_overflow_mask[element_index_int] = 1'b1;

                            queue_overflow_events =
                                queue_overflow_events + COUNTER_ONE;

                            pending_non_overwrite_valid = 1'b0;
                            no_queue_overflow = 1'b0;
                        end else begin
                            set_pending_d_at_index(element_index_int, target_value);

                            pending_created_mask[element_index_int] = 1'b1;
                            pending_created_events =
                                pending_created_events + COUNTER_ONE;
                        end
                    end
                end
            end
        end

        for (int element_index = 0; element_index < CELLS; element_index = element_index + 1) begin
            logic [STATE_BITS - 1:0] pending_next;

            pending_next =
                pending_d_value_at_index(element_index);

            if (!frp_is_valid_ternary(pending_next)) begin
                pending_reserved_mask[element_index] = 1'b1;
                pending_domain_valid = 1'b0;
                no_pending_reserved_state = 1'b0;
            end

            if (frp_is_nonzero(pending_next)) begin
                pending_active_count =
                    pending_active_count + COUNTER_ONE;
            end
        end

        if (queue_overflow_events != '0) begin
            no_queue_overflow = 1'b0;
            pending_capacity_valid = 1'b0;
        end

        if (actual_direct_events != '0) begin
            no_actual_direct_events = 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_route_q <= '0;
        end else if (tick_enable) begin
            pending_route_q <= pending_route_d;
        end
    end

endmodule : frp_m16_pending_routes

`endif

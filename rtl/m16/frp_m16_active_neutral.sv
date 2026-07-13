// SPDX-License-Identifier: Apache-2.0
/*
    FRP M16 Active Neutral Transition Module

    Project:
        Fractal Resonance Processor (FRP)
        Ternary Fractal Resonant Coherence Processor

    Version:
        FRP v1.8.0

    Milestone:
        M16 RTL Core Realization and Execution Semantics Package

    Purpose:
        Implements the M16 active-neutral transition layer for legal
        retained-state transition generation.

        Preserved transition semantics:
            - same-state retention;
            - legal 0 -> +/-1 release;
            - legal +/-1 -> 0 neutralization;
            - forbidden direct -1 -> +1 transition;
            - forbidden direct +1 -> -1 transition;
            - mandatory active-neutral routing through 0;
            - pending-route completion only from state 0;
            - zero direct opposite-polarity execution.
*/

`ifndef FRP_M16_ACTIVE_NEUTRAL_SV
`define FRP_M16_ACTIVE_NEUTRAL_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"

module frp_m16_active_neutral #(
    parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
    parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
    parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
    parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
    parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
    input logic tick_enable,
    input frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

    input logic [(CELLS * STATE_BITS) - 1:0] state_q,
    input logic [(CELLS * STATE_BITS) - 1:0] pending_route_q,

    input logic [REQUEST_LANES - 1:0] request_accept,
    input logic [REQUEST_LANES - 1:0] request_neutralized,
    input logic [(REQUEST_LANES * CELL_INDEX_BITS) - 1:0] request_cell_index,
    input logic [(REQUEST_LANES * STATE_BITS) - 1:0] request_target,

    input logic [CELLS - 1:0] pending_completion_enable,

    output logic [(CELLS * STATE_BITS) - 1:0] state_candidate_d,

    output logic [CELLS - 1:0] transition_valid_mask,
    output logic [CELLS - 1:0] same_state_mask,
    output logic [CELLS - 1:0] zero_to_nonzero_mask,
    output logic [CELLS - 1:0] nonzero_to_zero_mask,
    output logic [CELLS - 1:0] opposite_polarity_mask,
    output logic [CELLS - 1:0] neutral_routed_mask,
    output logic [CELLS - 1:0] pending_completion_mask,
    output logic [CELLS - 1:0] actual_direct_mask,
    output logic [CELLS - 1:0] reserved_transition_mask,
    output logic [CELLS - 1:0] accepted_change_candidate_mask,

    output logic [COUNTER_BITS - 1:0] same_state_events,
    output logic [COUNTER_BITS - 1:0] zero_to_nonzero_events,
    output logic [COUNTER_BITS - 1:0] nonzero_to_zero_events,
    output logic [COUNTER_BITS - 1:0] requested_direct_events,
    output logic [COUNTER_BITS - 1:0] prevented_direct_events,
    output logic [COUNTER_BITS - 1:0] neutral_routed_events,
    output logic [COUNTER_BITS - 1:0] pending_completion_events,
    output logic [COUNTER_BITS - 1:0] actual_direct_events,
    output logic [COUNTER_BITS - 1:0] reserved_transition_events,
    output logic [COUNTER_BITS - 1:0] accepted_change_candidate_events,

    output logic transition_domain_valid,
    output logic active_neutral_routing_valid,
    output logic pending_completion_from_zero_valid,
    output logic no_reserved_transition,
    output logic no_actual_direct_events,
    output logic transition_capacity_valid,
    output logic state_output_domain_valid,
    output logic transition_replay_deterministic
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
                packed_state[
                    (element_index * STATE_BITS) +: STATE_BITS
                ];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] pending_value_at_index(
        input int element_index
    );
        begin
            pending_value_at_index =
                pending_route_q[
                    (element_index * STATE_BITS) +: STATE_BITS
                ];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] candidate_value_at_index(
        input int element_index
    );
        begin
            candidate_value_at_index =
                state_candidate_d[
                    (element_index * STATE_BITS) +: STATE_BITS
                ];
        end
    endfunction

    function automatic logic [CELL_INDEX_BITS - 1:0] lane_index_value(
        input int lane_index
    );
        begin
            lane_index_value =
                request_cell_index[
                    (lane_index * CELL_INDEX_BITS) +: CELL_INDEX_BITS
                ];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] lane_target_value(
        input int lane_index
    );
        begin
            lane_target_value =
                request_target[
                    (lane_index * STATE_BITS) +: STATE_BITS
                ];
        end
    endfunction

    task automatic set_candidate_value_at_index(
        input int element_index,
        input logic [STATE_BITS - 1:0] candidate_value
    );
        begin
            state_candidate_d[
                (element_index * STATE_BITS) +: STATE_BITS
            ] = candidate_value;
        end
    endtask

    function automatic logic scheduler_allows_zero_to_nonzero(
        input frp_m16_scheduler_state_e sched
    );
        begin
            scheduler_allows_zero_to_nonzero =
                frp_scheduler_is_commit_capable(sched);
        end
    endfunction

    function automatic logic scheduler_allows_nonzero_to_zero(
        input frp_m16_scheduler_state_e sched
    );
        begin
            scheduler_allows_nonzero_to_zero =
                frp_scheduler_is_neutralize_capable(sched);
        end
    endfunction

    function automatic logic scheduler_allows_pending_completion(
        input frp_m16_scheduler_state_e sched
    );
        begin
            scheduler_allows_pending_completion =
                frp_scheduler_is_commit_capable(sched);
        end
    endfunction

    always_comb begin
        for (
            int element_index = 0;
            element_index < CELLS;
            element_index = element_index + 1
        ) begin
            set_candidate_value_at_index(
                element_index,
                state_value_at_index(
                    state_q,
                    element_index
                )
            );
        end

        transition_valid_mask = '0;
        same_state_mask = '0;
        zero_to_nonzero_mask = '0;
        nonzero_to_zero_mask = '0;
        opposite_polarity_mask = '0;
        neutral_routed_mask = '0;
        pending_completion_mask = '0;
        actual_direct_mask = '0;
        reserved_transition_mask = '0;
        accepted_change_candidate_mask = '0;

        same_state_events = '0;
        zero_to_nonzero_events = '0;
        nonzero_to_zero_events = '0;
        requested_direct_events = '0;
        prevented_direct_events = '0;
        neutral_routed_events = '0;
        pending_completion_events = '0;
        actual_direct_events = '0;
        reserved_transition_events = '0;
        accepted_change_candidate_events = '0;

        transition_domain_valid = 1'b1;
        active_neutral_routing_valid = 1'b1;
        pending_completion_from_zero_valid = 1'b1;
        no_reserved_transition = 1'b1;
        no_actual_direct_events = 1'b1;
        transition_capacity_valid = 1'b1;
        state_output_domain_valid = 1'b1;
        transition_replay_deterministic = 1'b1;

        for (
            int element_index = 0;
            element_index < CELLS;
            element_index = element_index + 1
        ) begin
            logic [STATE_BITS - 1:0] state_value;
            logic [STATE_BITS - 1:0] pending_value;

            state_value =
                state_value_at_index(
                    state_q,
                    element_index
                );

            pending_value =
                pending_value_at_index(
                    element_index
                );

            if (
                !frp_is_valid_ternary(state_value)
                || !frp_is_valid_ternary(pending_value)
            ) begin
                reserved_transition_mask[element_index] = 1'b1;

                reserved_transition_events =
                    reserved_transition_events
                    + COUNTER_ONE;

                transition_domain_valid = 1'b0;
                no_reserved_transition = 1'b0;
            end
        end

        for (
            int element_index = 0;
            element_index < CELLS;
            element_index = element_index + 1
        ) begin
            logic [STATE_BITS - 1:0] state_value;
            logic [STATE_BITS - 1:0] pending_value;

            state_value =
                state_value_at_index(
                    state_q,
                    element_index
                );

            pending_value =
                pending_value_at_index(
                    element_index
                );

            if (
                tick_enable
                && pending_completion_enable[element_index]
                && frp_is_valid_ternary(state_value)
                && frp_is_valid_ternary(pending_value)
                && frp_is_nonzero(pending_value)
            ) begin
                if (
                    frp_is_zero(state_value)
                    && scheduler_allows_pending_completion(
                        scheduler_state
                    )
                ) begin
                    set_candidate_value_at_index(
                        element_index,
                        pending_value
                    );

                    transition_valid_mask[element_index] = 1'b1;
                    pending_completion_mask[element_index] = 1'b1;
                    zero_to_nonzero_mask[element_index] = 1'b1;

                    accepted_change_candidate_mask[
                        element_index
                    ] = 1'b1;

                    pending_completion_events =
                        pending_completion_events
                        + COUNTER_ONE;

                    zero_to_nonzero_events =
                        zero_to_nonzero_events
                        + COUNTER_ONE;

                    accepted_change_candidate_events =
                        accepted_change_candidate_events
                        + COUNTER_ONE;
                end else if (!frp_is_zero(state_value)) begin
                    pending_completion_from_zero_valid = 1'b0;
                end
            end
        end

        for (
            int lane_index = 0;
            lane_index < REQUEST_LANES;
            lane_index = lane_index + 1
        ) begin
            logic [CELL_INDEX_BITS - 1:0] packed_index_value;
            int element_index_int;
            logic [STATE_BITS - 1:0] state_value;
            logic [STATE_BITS - 1:0] target_value;
            logic valid_index;
            logic valid_target;
            frp_m16_transition_class_e transition_class;

            packed_index_value =
                lane_index_value(
                    lane_index
                );

            element_index_int =
                int'(packed_index_value);

            target_value =
                lane_target_value(
                    lane_index
                );

            valid_index =
                (element_index_int < CELLS);

            valid_target =
                frp_is_valid_ternary(
                    target_value
                );

            state_value = FRP_STATE_ZERO;
            transition_class = FRP_TRANS_RESERVED_OPERAND;

            if (valid_index) begin
                state_value =
                    state_value_at_index(
                        state_q,
                        element_index_int
                    );
            end

            if (
                tick_enable
                && request_accept[lane_index]
                && valid_index
                && valid_target
                && !pending_completion_mask[element_index_int]
            ) begin
                transition_class =
                    frp_classify_transition(
                        state_value,
                        target_value,
                        FRP_STATE_ZERO
                    );

                unique case (transition_class)
                    FRP_TRANS_SAME_STATE: begin
                        set_candidate_value_at_index(
                            element_index_int,
                            state_value
                        );

                        transition_valid_mask[
                            element_index_int
                        ] = 1'b1;

                        same_state_mask[
                            element_index_int
                        ] = 1'b1;

                        same_state_events =
                            same_state_events
                            + COUNTER_ONE;
                    end

                    FRP_TRANS_ZERO_TO_NONZERO: begin
                        if (
                            scheduler_allows_zero_to_nonzero(
                                scheduler_state
                            )
                        ) begin
                            set_candidate_value_at_index(
                                element_index_int,
                                target_value
                            );

                            transition_valid_mask[
                                element_index_int
                            ] = 1'b1;

                            zero_to_nonzero_mask[
                                element_index_int
                            ] = 1'b1;

                            accepted_change_candidate_mask[
                                element_index_int
                            ] = 1'b1;

                            zero_to_nonzero_events =
                                zero_to_nonzero_events
                                + COUNTER_ONE;

                            accepted_change_candidate_events =
                                accepted_change_candidate_events
                                + COUNTER_ONE;
                        end
                    end

                    FRP_TRANS_NONZERO_TO_ZERO: begin
                        if (
                            scheduler_allows_nonzero_to_zero(
                                scheduler_state
                            )
                        ) begin
                            set_candidate_value_at_index(
                                element_index_int,
                                FRP_STATE_ZERO
                            );

                            transition_valid_mask[
                                element_index_int
                            ] = 1'b1;

                            nonzero_to_zero_mask[
                                element_index_int
                            ] = 1'b1;

                            accepted_change_candidate_mask[
                                element_index_int
                            ] = 1'b1;

                            nonzero_to_zero_events =
                                nonzero_to_zero_events
                                + COUNTER_ONE;

                            accepted_change_candidate_events =
                                accepted_change_candidate_events
                                + COUNTER_ONE;
                        end
                    end

                    FRP_TRANS_OPPOSITE_POLARITY: begin
                        requested_direct_events =
                            requested_direct_events
                            + COUNTER_ONE;

                        if (
                            request_neutralized[lane_index]
                            && scheduler_allows_nonzero_to_zero(
                                scheduler_state
                            )
                        ) begin
                            set_candidate_value_at_index(
                                element_index_int,
                                FRP_STATE_ZERO
                            );

                            transition_valid_mask[
                                element_index_int
                            ] = 1'b1;

                            opposite_polarity_mask[
                                element_index_int
                            ] = 1'b1;

                            neutral_routed_mask[
                                element_index_int
                            ] = 1'b1;

                            nonzero_to_zero_mask[
                                element_index_int
                            ] = 1'b1;

                            accepted_change_candidate_mask[
                                element_index_int
                            ] = 1'b1;

                            prevented_direct_events =
                                prevented_direct_events
                                + COUNTER_ONE;

                            neutral_routed_events =
                                neutral_routed_events
                                + COUNTER_ONE;

                            nonzero_to_zero_events =
                                nonzero_to_zero_events
                                + COUNTER_ONE;

                            accepted_change_candidate_events =
                                accepted_change_candidate_events
                                + COUNTER_ONE;
                        end else begin
                            active_neutral_routing_valid = 1'b0;
                        end
                    end

                    FRP_TRANS_RESERVED_OPERAND: begin
                        reserved_transition_mask[
                            element_index_int
                        ] = 1'b1;

                        reserved_transition_events =
                            reserved_transition_events
                            + COUNTER_ONE;

                        transition_domain_valid = 1'b0;
                        no_reserved_transition = 1'b0;
                    end

                    default: begin
                        set_candidate_value_at_index(
                            element_index_int,
                            state_value
                        );
                    end
                endcase
            end else if (
                tick_enable
                && request_accept[lane_index]
                && (!valid_index || !valid_target)
            ) begin
                transition_domain_valid = 1'b0;
                no_reserved_transition = 1'b0;
            end
        end

        for (
            int element_index = 0;
            element_index < CELLS;
            element_index = element_index + 1
        ) begin
            if (
                !frp_is_valid_ternary(
                    candidate_value_at_index(
                        element_index
                    )
                )
            ) begin
                reserved_transition_mask[
                    element_index
                ] = 1'b1;

                state_output_domain_valid = 1'b0;
                no_reserved_transition = 1'b0;
            end

            if (
                frp_is_opposite_polarity(
                    state_value_at_index(
                        state_q,
                        element_index
                    ),
                    candidate_value_at_index(
                        element_index
                    )
                )
            ) begin
                actual_direct_mask[
                    element_index
                ] = 1'b1;

                actual_direct_events =
                    actual_direct_events
                    + COUNTER_ONE;

                no_actual_direct_events = 1'b0;
            end
        end

        active_neutral_routing_valid =
            active_neutral_routing_valid
            && (
                neutral_routed_events
                >= prevented_direct_events
            )
            && (actual_direct_events == '0);

        transition_domain_valid =
            transition_domain_valid
            && no_reserved_transition
            && state_output_domain_valid;

        transition_capacity_valid = 1'b1;
        transition_replay_deterministic = 1'b1;
    end

endmodule : frp_m16_active_neutral

`endif

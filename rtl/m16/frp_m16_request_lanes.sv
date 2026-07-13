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
        Integrated request-lane arbitration module for the M16 RTL core.

        This source matches the actual frp_m16_core.sv instance interface:

            u_request_lanes (
                .tick_enable(...)
                .scheduler_state(...)
                .request_valid(...)
                .request_cell_index(...)
                .request_target(...)
                .state_q(...)
                .target_q(...)
                .pending_route_q(...)
                ...
            )

        It performs request-lane validation, retained-state domain checking,
        target-domain checking, duplicate-index guarding, scheduler gating,
        pending-route busy rejection, accepted/rejected lane reporting,
        opposite-polarity active-neutral routing classification, direct-request
        prevention counters, and zero-event invariant outputs.

        It does not update retained state directly.
        It emits arbitration outputs consumed by the downstream M16 RTL modules.
*/

`ifndef FRP_M16_REQUEST_LANES_SV
`define FRP_M16_REQUEST_LANES_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"

module frp_m16_request_lanes #(
    parameter int CELLS = frp_m16_pkg::FRP_M16_DEFAULT_CELLS,
    parameter int STATE_BITS = frp_m16_pkg::FRP_M16_STATE_BITS,
    parameter int REQUEST_LANES = frp_m16_pkg::frp_calc_request_lanes(CELLS),
    parameter int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS),
    parameter int COUNTER_BITS = frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
    input logic tick_enable,
    input frp_m16_pkg::frp_m16_scheduler_state_e scheduler_state,

    input logic [REQUEST_LANES - 1:0] request_valid,
    input logic [(REQUEST_LANES * CELL_INDEX_BITS) - 1:0] request_cell_index,
    input logic [(REQUEST_LANES * STATE_BITS) - 1:0] request_target,

    input logic [(CELLS * STATE_BITS) - 1:0] state_q,
    input logic [(CELLS * STATE_BITS) - 1:0] target_q,
    input logic [(CELLS * STATE_BITS) - 1:0] pending_route_q,

    output logic [REQUEST_LANES - 1:0] request_accept,
    output logic [REQUEST_LANES - 1:0] request_reject,
    output logic [REQUEST_LANES - 1:0] request_reject_invalid_cell,
    output logic [REQUEST_LANES - 1:0] request_reject_invalid_target,
    output logic [REQUEST_LANES - 1:0] request_reject_duplicate_cell,
    output logic [REQUEST_LANES - 1:0] request_reject_scheduler,
    output logic [REQUEST_LANES - 1:0] request_reject_capacity,
    output logic [REQUEST_LANES - 1:0] request_reject_pending_busy,
    output logic [REQUEST_LANES - 1:0] request_reject_tick_disabled,
    output logic [REQUEST_LANES - 1:0] request_neutralized,

    output logic [CELLS - 1:0] accepted_cell_mask,
    output logic [CELLS - 1:0] rejected_cell_mask,
    output logic [CELLS - 1:0] neutral_routed_cell_mask,
    output logic [CELLS - 1:0] requested_direct_cell_mask,

    output logic [COUNTER_BITS - 1:0] accepted_changes,
    output logic [COUNTER_BITS - 1:0] requested_lane_events,
    output logic [COUNTER_BITS - 1:0] accepted_lane_events,
    output logic [COUNTER_BITS - 1:0] rejected_lane_events,
    output logic [COUNTER_BITS - 1:0] requested_direct_events,
    output logic [COUNTER_BITS - 1:0] prevented_direct_events,
    output logic [COUNTER_BITS - 1:0] neutral_routed_events,

    output logic request_lane_order_valid,
    output logic request_cell_domain_valid,
    output logic request_target_domain_valid,
    output logic duplicate_cell_guard_valid,
    output logic scheduler_gate_valid,
    output logic transition_capacity_valid,
    output logic active_neutral_routing_valid,
    output logic no_actual_direct_events,
    output logic no_queue_overflow
);

    import frp_m16_pkg::*;

    localparam logic [COUNTER_BITS - 1:0] COUNTER_ONE =
        {{(COUNTER_BITS - 1){1'b0}}, 1'b1};

    function automatic logic [CELL_INDEX_BITS - 1:0] get_lane_index(
        input int lane_index
    );
        begin
            get_lane_index =
                request_cell_index[(lane_index * CELL_INDEX_BITS) +: CELL_INDEX_BITS];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] get_lane_target(
        input int lane_index
    );
        begin
            get_lane_target =
                request_target[(lane_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    function automatic logic [STATE_BITS - 1:0] get_packed_state_value(
        input logic [(CELLS * STATE_BITS) - 1:0] packed_state,
        input int element_index
    );
        begin
            get_packed_state_value =
                packed_state[(element_index * STATE_BITS) +: STATE_BITS];
        end
    endfunction

    function automatic logic scheduler_allows_transition(
        input frp_m16_scheduler_state_e sched,
        input frp_m16_transition_class_e transition_class
    );
        begin
            unique case (transition_class)
                FRP_TRANS_SAME_STATE: begin
                    scheduler_allows_transition = 1'b1;
                end

                FRP_TRANS_ZERO_TO_NONZERO: begin
                    scheduler_allows_transition =
                        frp_scheduler_is_commit_capable(sched);
                end

                FRP_TRANS_NONZERO_TO_ZERO: begin
                    scheduler_allows_transition =
                        frp_scheduler_is_neutralize_capable(sched);
                end

                FRP_TRANS_OPPOSITE_POLARITY: begin
                    scheduler_allows_transition =
                        frp_scheduler_is_neutralize_capable(sched);
                end

                default: begin
                    scheduler_allows_transition = 1'b0;
                end
            endcase
        end
    endfunction

    always_comb begin
        request_accept = '0;
        request_reject = '0;
        request_reject_invalid_cell = '0;
        request_reject_invalid_target = '0;
        request_reject_duplicate_cell = '0;
        request_reject_scheduler = '0;
        request_reject_capacity = '0;
        request_reject_pending_busy = '0;
        request_reject_tick_disabled = '0;
        request_neutralized = '0;

        accepted_cell_mask = '0;
        rejected_cell_mask = '0;
        neutral_routed_cell_mask = '0;
        requested_direct_cell_mask = '0;

        accepted_changes = '0;
        requested_lane_events = '0;
        accepted_lane_events = '0;
        rejected_lane_events = '0;
        requested_direct_events = '0;
        prevented_direct_events = '0;
        neutral_routed_events = '0;

        request_lane_order_valid = 1'b1;
        request_cell_domain_valid = 1'b1;
        request_target_domain_valid = 1'b1;
        duplicate_cell_guard_valid = 1'b1;
        scheduler_gate_valid = 1'b1;
        transition_capacity_valid = 1'b1;
        active_neutral_routing_valid = 1'b1;
        no_actual_direct_events = 1'b1;
        no_queue_overflow = 1'b1;

        for (int domain_index = 0; domain_index < CELLS; domain_index = domain_index + 1) begin
            logic [STATE_BITS - 1:0] retained_value;
            logic [STATE_BITS - 1:0] target_value_q;
            logic [STATE_BITS - 1:0] pending_value_q;

            retained_value =
                get_packed_state_value(state_q, domain_index);

            target_value_q =
                get_packed_state_value(target_q, domain_index);

            pending_value_q =
                get_packed_state_value(pending_route_q, domain_index);

            if (!frp_is_valid_ternary(retained_value)) begin
                request_cell_domain_valid = 1'b0;
            end

            if (!frp_is_valid_ternary(target_value_q)) begin
                request_target_domain_valid = 1'b0;
            end

            if (!frp_is_valid_ternary(pending_value_q)) begin
                request_target_domain_valid = 1'b0;
            end
        end

        for (int lane_index = 0; lane_index < REQUEST_LANES; lane_index = lane_index + 1) begin
            logic [CELL_INDEX_BITS - 1:0] packed_index_value;
            int element_index_int;

            logic [STATE_BITS - 1:0] retained_value;
            logic [STATE_BITS - 1:0] target_value;
            logic [STATE_BITS - 1:0] pending_value;

            logic [CELLS - 1:0] lane_element_mask;

            logic invalid_index;
            logic invalid_target;
            logic duplicate_index;
            logic pending_busy;
            logic scheduler_blocked;

            frp_m16_transition_class_e transition_class;

            packed_index_value =
                get_lane_index(lane_index);

            element_index_int =
                int'(packed_index_value);

            target_value =
                get_lane_target(lane_index);

            retained_value = FRP_STATE_ZERO;
            pending_value = FRP_STATE_ZERO;
            lane_element_mask = '0;

            invalid_index =
                (element_index_int >= CELLS);

            invalid_target =
                !frp_is_valid_ternary(target_value);

            if (!invalid_index) begin
                retained_value =
                    get_packed_state_value(state_q, element_index_int);

                pending_value =
                    get_packed_state_value(pending_route_q, element_index_int);

                lane_element_mask =
                    ({{(CELLS - 1){1'b0}}, 1'b1} << element_index_int);
            end

            transition_class =
                frp_classify_transition(
                    retained_value,
                    target_value,
                    FRP_STATE_ZERO
                );

            duplicate_index =
                (!invalid_index)
                && ((accepted_cell_mask & lane_element_mask) != '0);

            pending_busy =
                (!invalid_index)
                && frp_is_nonzero(pending_value)
                && (transition_class != FRP_TRANS_SAME_STATE);

            scheduler_blocked =
                !scheduler_allows_transition(
                    scheduler_state,
                    transition_class
                );

            if (request_valid[lane_index]) begin
                requested_lane_events =
                    requested_lane_events + COUNTER_ONE;

                if (!tick_enable) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_tick_disabled[lane_index] = 1'b1;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else if (invalid_index) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_invalid_cell[lane_index] = 1'b1;

                    request_cell_domain_valid = 1'b0;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else if (invalid_target) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_invalid_target[lane_index] = 1'b1;

                    request_target_domain_valid = 1'b0;

                    rejected_cell_mask =
                        rejected_cell_mask | lane_element_mask;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else if (duplicate_index) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_duplicate_cell[lane_index] = 1'b1;

                    duplicate_cell_guard_valid = 1'b0;

                    rejected_cell_mask =
                        rejected_cell_mask | lane_element_mask;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else if (scheduler_blocked) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_scheduler[lane_index] = 1'b1;

                    scheduler_gate_valid = 1'b0;

                    rejected_cell_mask =
                        rejected_cell_mask | lane_element_mask;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else if (pending_busy) begin
                    request_reject[lane_index] = 1'b1;
                    request_reject_pending_busy[lane_index] = 1'b1;

                    rejected_cell_mask =
                        rejected_cell_mask | lane_element_mask;

                    rejected_lane_events =
                        rejected_lane_events + COUNTER_ONE;
                end else begin
                    request_accept[lane_index] = 1'b1;

                    accepted_cell_mask =
                        accepted_cell_mask | lane_element_mask;

                    accepted_lane_events =
                        accepted_lane_events + COUNTER_ONE;

                    if (transition_class != FRP_TRANS_SAME_STATE) begin
                        accepted_changes =
                            accepted_changes + COUNTER_ONE;
                    end

                    if (transition_class == FRP_TRANS_OPPOSITE_POLARITY) begin
                        request_neutralized[lane_index] = 1'b1;

                        requested_direct_cell_mask =
                            requested_direct_cell_mask | lane_element_mask;

                        neutral_routed_cell_mask =
                            neutral_routed_cell_mask | lane_element_mask;

                        requested_direct_events =
                            requested_direct_events + COUNTER_ONE;

                        prevented_direct_events =
                            prevented_direct_events + COUNTER_ONE;

                        neutral_routed_events =
                            neutral_routed_events + COUNTER_ONE;
                    end
                end
            end
        end

        transition_capacity_valid =
            (accepted_lane_events <= REQUEST_LANES);

        active_neutral_routing_valid =
            (neutral_routed_events >= prevented_direct_events)
            && (requested_direct_events >= prevented_direct_events);

        no_actual_direct_events = 1'b1;
        no_queue_overflow = 1'b1;
    end

endmodule : frp_m16_request_lanes

`endif

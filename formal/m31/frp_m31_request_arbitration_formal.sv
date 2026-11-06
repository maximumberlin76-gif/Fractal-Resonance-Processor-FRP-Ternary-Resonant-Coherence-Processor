// SPDX-License-Identifier: Apache-2.0
// M31 request arbitration: complete public-output contract.
// Unrestricted combinational inputs, including reserved encodings and addresses.
// Earlier accepted lanes own cells; rejected lanes do not reserve them.
// Native and extended indices share the same independent reference model.
`ifndef FRP_M31_REQUEST_ARBITRATION_FORMAL_SV
`define FRP_M31_REQUEST_ARBITRATION_FORMAL_SV
`include "frp_m31_request_lanes.sv"

`define FRP_M31_RA_CHECK(FIELD, BIT) \
    always_comb begin \
        mismatch[BIT] = actual.FIELD != expected.FIELD; \
        a_``FIELD: assert (!mismatch[BIT]); \
    end

module frp_m31_request_arbitration_formal #(
    parameter int CELLS = 9,
    parameter int LANES = 3,
    parameter int EXTRA_INDEX_BIT = 0,
    parameter int INDEX_BITS = $clog2(CELLS) + EXTRA_INDEX_BIT
) (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [LANES-1:0] request_valid,
    input logic [LANES*INDEX_BITS-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [2*CELLS-1:0] state_q, target_q, pending_route_q,
    output logic [29:0] mismatch,
    output logic [23:0] reach
);
    always_comb begin
        a_parameters: assert(CELLS >= 2 && CELLS <= 64
            && LANES >= 1 && LANES <= CELLS
            && (EXTRA_INDEX_BIT == 0 || EXTRA_INDEX_BIT == 1)
            && INDEX_BITS == $clog2(CELLS) + EXTRA_INDEX_BIT);
    end
    typedef struct packed {
        logic [LANES-1:0] request_accept;
        logic [LANES-1:0] request_reject;
        logic [LANES-1:0] request_reject_invalid_cell;
        logic [LANES-1:0] request_reject_invalid_target;
        logic [LANES-1:0] request_reject_duplicate_cell;
        logic [LANES-1:0] request_reject_scheduler;
        logic [LANES-1:0] request_reject_capacity;
        logic [LANES-1:0] request_reject_pending_busy;
        logic [LANES-1:0] request_reject_tick_disabled;
        logic [LANES-1:0] request_neutralized;
        logic [CELLS-1:0] accepted_cell_mask;
        logic [CELLS-1:0] rejected_cell_mask;
        logic [CELLS-1:0] neutral_routed_cell_mask;
        logic [CELLS-1:0] requested_direct_cell_mask;
        logic [31:0] accepted_changes;
        logic [31:0] requested_lane_events;
        logic [31:0] accepted_lane_events;
        logic [31:0] rejected_lane_events;
        logic [31:0] requested_direct_events;
        logic [31:0] prevented_direct_events;
        logic [31:0] neutral_routed_events;
        logic request_lane_order_valid;
        logic request_cell_domain_valid;
        logic request_target_domain_valid;
        logic duplicate_cell_guard_valid;
        logic scheduler_gate_valid;
        logic transition_capacity_valid;
        logic active_neutral_routing_valid;
        logic no_actual_direct_events;
        logic no_queue_overflow;
    } result_t;
    result_t actual, expected;
    frp_m31_request_lanes #(
        .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES),
        .CELL_INDEX_BITS(INDEX_BITS), .COUNTER_BITS(32)
    ) dut (
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .request_valid(request_valid), .request_cell_index(request_cell_index),
        .request_target(request_target), .state_q(state_q),
        .target_q(target_q), .pending_route_q(pending_route_q),
        .request_accept(actual.request_accept),
        .request_reject(actual.request_reject),
        .request_reject_invalid_cell(actual.request_reject_invalid_cell),
        .request_reject_invalid_target(actual.request_reject_invalid_target),
        .request_reject_duplicate_cell(actual.request_reject_duplicate_cell),
        .request_reject_scheduler(actual.request_reject_scheduler),
        .request_reject_capacity(actual.request_reject_capacity),
        .request_reject_pending_busy(actual.request_reject_pending_busy),
        .request_reject_tick_disabled(actual.request_reject_tick_disabled),
        .request_neutralized(actual.request_neutralized),
        .accepted_cell_mask(actual.accepted_cell_mask),
        .rejected_cell_mask(actual.rejected_cell_mask),
        .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
        .requested_direct_cell_mask(actual.requested_direct_cell_mask),
        .accepted_changes(actual.accepted_changes),
        .requested_lane_events(actual.requested_lane_events),
        .accepted_lane_events(actual.accepted_lane_events),
        .rejected_lane_events(actual.rejected_lane_events),
        .requested_direct_events(actual.requested_direct_events),
        .prevented_direct_events(actual.prevented_direct_events),
        .neutral_routed_events(actual.neutral_routed_events),
        .request_lane_order_valid(actual.request_lane_order_valid),
        .request_cell_domain_valid(actual.request_cell_domain_valid),
        .request_target_domain_valid(actual.request_target_domain_valid),
        .duplicate_cell_guard_valid(actual.duplicate_cell_guard_valid),
        .scheduler_gate_valid(actual.scheduler_gate_valid),
        .transition_capacity_valid(actual.transition_capacity_valid),
        .active_neutral_routing_valid(actual.active_neutral_routing_valid),
        .no_actual_direct_events(actual.no_actual_direct_events),
        .no_queue_overflow(actual.no_queue_overflow)
    );

    function automatic logic polarized(input logic [1:0] value);
        return value == 2'b01 || value == 2'b11;
    endfunction
    function automatic logic [31:0] population(input logic [LANES-1:0] bits);
        logic [31:0] total;
        total = 0;
        for (int lane = 0; lane < LANES; lane++)
            if (bits[lane]) total = total + 32'd1;
        return total;
    endfunction

    logic [INDEX_BITS-1:0] index [LANES];
    logic [1:0] retained [LANES], wanted [LANES], pending [LANES];
    logic [LANES-1:0] active, in_range, duplicate, busy, allowed, direct, changed;
    always_comb begin
        expected = '0;
        expected.request_lane_order_valid = 1;
        expected.request_cell_domain_valid = 1;
        expected.request_target_domain_valid = 1;
        expected.duplicate_cell_guard_valid = 1;
        expected.scheduler_gate_valid = 1;
        expected.transition_capacity_valid = 1;
        expected.active_neutral_routing_valid = 1;
        expected.no_actual_direct_events = 1;
        expected.no_queue_overflow = 1;
        active = request_valid & {LANES{tick_enable}};
        expected.request_reject_tick_disabled = request_valid & {LANES{!tick_enable}};
        for (int cell_id = 0; cell_id < CELLS; cell_id++) begin
            if (state_q[2*cell_id +: 2] == 2'b10)
                expected.request_cell_domain_valid = 0;
            if (target_q[2*cell_id +: 2] == 2'b10
                || pending_route_q[2*cell_id +: 2] == 2'b10)
                expected.request_target_domain_valid = 0;
        end
        for (int lane = 0; lane < LANES; lane++) begin
            index[lane] = request_cell_index[INDEX_BITS*lane +: INDEX_BITS];
            in_range[lane] = int'(index[lane]) < CELLS;
            wanted[lane] = request_target[2*lane +: 2];
            retained[lane] = 0;
            pending[lane] = 0;
            if (in_range[lane]) begin
                retained[lane] = state_q[2*int'(index[lane]) +: 2];
                pending[lane] = pending_route_q[2*int'(index[lane]) +: 2];
            end
            duplicate[lane] = 0;
            // Ownership comes from accepted prefixes, independently of cell masks.
            for (int prior = 0; prior < lane; prior++)
                duplicate[lane] |= expected.request_accept[prior]
                    && index[prior] == index[lane];
            busy[lane] = polarized(pending[lane]);
            direct[lane] = {retained[lane], wanted[lane]} == 4'b0111
                || {retained[lane], wanted[lane]} == 4'b1101;
            allowed[lane] = scheduler_state < 5
                && retained[lane] != 2'b10 && wanted[lane] != 2'b10
                && (retained[lane] == wanted[lane]
                    || (retained[lane] == 0 && polarized(wanted[lane])
                        && (scheduler_state == 0 || scheduler_state == 2 || scheduler_state == 3))
                    || (polarized(retained[lane]) && (wanted[lane] == 0 || direct[lane])
                        && (scheduler_state == 0 || scheduler_state == 1 || scheduler_state == 4)));
            // Priority: address, target, accepted owner, pending owner, scheduler.
            expected.request_reject_invalid_cell[lane] = active[lane] && !in_range[lane];
            expected.request_reject_invalid_target[lane] = active[lane] && in_range[lane]
                && wanted[lane] == 2'b10;
            expected.request_reject_duplicate_cell[lane] = active[lane] && in_range[lane]
                && wanted[lane] != 2'b10 && duplicate[lane];
            expected.request_reject_pending_busy[lane] = active[lane] && in_range[lane]
                && wanted[lane] != 2'b10 && !duplicate[lane] && busy[lane];
            expected.request_reject_scheduler[lane] = active[lane] && in_range[lane]
                && wanted[lane] != 2'b10 && !duplicate[lane] && !busy[lane] && !allowed[lane];
            expected.request_accept[lane] = active[lane] && in_range[lane]
                && wanted[lane] != 2'b10 && !duplicate[lane] && !busy[lane] && allowed[lane];
            expected.request_reject[lane] = active[lane] && !expected.request_accept[lane];
            expected.request_neutralized[lane] = expected.request_accept[lane] && direct[lane];
            changed[lane] = expected.request_accept[lane] && retained[lane] != wanted[lane];
            if (expected.request_reject_invalid_cell[lane]) expected.request_cell_domain_valid = 0;
            if (expected.request_reject_invalid_target[lane]) expected.request_target_domain_valid = 0;
        end
        // Build cell masks by a cell/lane reduction, without variable-index writes.
        for (int cell_id = 0; cell_id < CELLS; cell_id++)
            for (int lane = 0; lane < LANES; lane++)
                if (int'(index[lane]) == cell_id) begin
                    expected.accepted_cell_mask[cell_id] |= expected.request_accept[lane];
                    expected.rejected_cell_mask[cell_id] |= expected.request_reject[lane];
                    expected.neutral_routed_cell_mask[cell_id] |= expected.request_neutralized[lane];
                end
        expected.requested_direct_cell_mask = expected.neutral_routed_cell_mask;
        expected.accepted_changes = population(changed);
        expected.requested_lane_events = population(active);
        expected.accepted_lane_events = population(expected.request_accept);
        expected.rejected_lane_events = population(expected.request_reject);
        expected.requested_direct_events = population(expected.request_neutralized);
        expected.prevented_direct_events = expected.requested_direct_events;
        expected.neutral_routed_events = expected.requested_direct_events;
    end

    // Reach bits are independent SAT witness targets, not assumptions.
    // Bits 3, 4, 22 require a representable out-of-range address.
    // Bits 12, 13, 14, 23 require at least two request lanes.
    always_comb begin
        reach = 0;
        reach[0] = !tick_enable && (&request_valid);
        reach[1] = (&actual.request_accept) && actual.accepted_changes == LANES;
        reach[2] = (&actual.request_accept) && actual.accepted_changes == 0;
        reach[3] = actual.request_reject_invalid_cell[0];
        reach[4] = actual.request_reject_invalid_cell[0] && wanted[0] == 2'b10;
        reach[5] = actual.request_reject_invalid_target[0] && busy[0];
        reach[6] = actual.request_reject_pending_busy[0] && !allowed[0];
        reach[7] = actual.request_reject_scheduler[0] && retained[0] == 2'b10;
        reach[8] = actual.request_accept[0] && pending[0] == 2'b10;
        reach[9] = actual.request_accept[0] && int'(index[0]) == CELLS-1;
        reach[10] = actual.request_neutralized[0] && retained[0] == 2'b01;
        reach[11] = actual.request_neutralized[0] && retained[0] == 2'b11;
        if (LANES >= 2) begin
            reach[12] = actual.request_reject[0] && actual.request_accept[LANES-1]
                && index[0] == index[LANES-1];
            reach[13] = actual.request_accept[0] && actual.request_reject_duplicate_cell[LANES-1];
            reach[14] = actual.request_reject_invalid_target[LANES-1] && duplicate[LANES-1];
            reach[23] = (|(actual.accepted_cell_mask & actual.rejected_cell_mask));
        end
        reach[15] = actual.request_reject_scheduler[0] && scheduler_state == 5;
        reach[16] = actual.request_reject_scheduler[0] && scheduler_state == 6;
        reach[17] = actual.request_reject_scheduler[0] && scheduler_state == 7;
        reach[18] = (&actual.request_neutralized);
        reach[19] = !tick_enable && !actual.request_cell_domain_valid;
        reach[20] = !tick_enable && !actual.request_target_domain_valid;
        reach[21] = actual.request_accept[0] && wanted[0] == 0 && retained[0] == 0;
        reach[22] = !tick_enable && request_valid[0] && !in_range[0]
            && actual.request_cell_domain_valid;
    end

    `FRP_M31_RA_CHECK(request_accept, 0)
    `FRP_M31_RA_CHECK(request_reject, 1)
    `FRP_M31_RA_CHECK(request_reject_invalid_cell, 2)
    `FRP_M31_RA_CHECK(request_reject_invalid_target, 3)
    `FRP_M31_RA_CHECK(request_reject_duplicate_cell, 4)
    `FRP_M31_RA_CHECK(request_reject_scheduler, 5)
    `FRP_M31_RA_CHECK(request_reject_capacity, 6)
    `FRP_M31_RA_CHECK(request_reject_pending_busy, 7)
    `FRP_M31_RA_CHECK(request_reject_tick_disabled, 8)
    `FRP_M31_RA_CHECK(request_neutralized, 9)
    `FRP_M31_RA_CHECK(accepted_cell_mask, 10)
    `FRP_M31_RA_CHECK(rejected_cell_mask, 11)
    `FRP_M31_RA_CHECK(neutral_routed_cell_mask, 12)
    `FRP_M31_RA_CHECK(requested_direct_cell_mask, 13)
    `FRP_M31_RA_CHECK(accepted_changes, 14)
    `FRP_M31_RA_CHECK(requested_lane_events, 15)
    `FRP_M31_RA_CHECK(accepted_lane_events, 16)
    `FRP_M31_RA_CHECK(rejected_lane_events, 17)
    `FRP_M31_RA_CHECK(requested_direct_events, 18)
    `FRP_M31_RA_CHECK(prevented_direct_events, 19)
    `FRP_M31_RA_CHECK(neutral_routed_events, 20)
    `FRP_M31_RA_CHECK(request_lane_order_valid, 21)
    `FRP_M31_RA_CHECK(request_cell_domain_valid, 22)
    `FRP_M31_RA_CHECK(request_target_domain_valid, 23)
    `FRP_M31_RA_CHECK(duplicate_cell_guard_valid, 24)
    `FRP_M31_RA_CHECK(scheduler_gate_valid, 25)
    `FRP_M31_RA_CHECK(transition_capacity_valid, 26)
    `FRP_M31_RA_CHECK(active_neutral_routing_valid, 27)
    `FRP_M31_RA_CHECK(no_actual_direct_events, 28)
    `FRP_M31_RA_CHECK(no_queue_overflow, 29)
endmodule
`undef FRP_M31_RA_CHECK
`endif

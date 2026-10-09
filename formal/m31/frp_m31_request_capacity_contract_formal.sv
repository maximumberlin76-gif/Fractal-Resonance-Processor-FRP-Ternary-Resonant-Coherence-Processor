// SPDX-License-Identifier: Apache-2.0
// Independent M31 request arbitration and capacity contracts.
// Profile: eight cells, two lanes, three-bit indices, 32-bit event counters.
// All input bits are unconstrained, including reserved ternary/scheduler codes.
// Three-bit indices cannot address outside this eight-cell profile.
// No assumptions, DUT internals, or DUT classification/arithmetic helpers.
// Proves local functional behavior, not full-core or physical correctness.
`ifndef FRP_M31_REQUEST_CAPACITY_CONTRACT_FORMAL_SV
`define FRP_M31_REQUEST_CAPACITY_CONTRACT_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_REQUEST_CAPACITY_CONTRACT_NETLIST
`include "frp_m31_request_lanes.sv"
`include "frp_m31_capacity_guard.sv"
`endif

package frp_m31_request_capacity_contract_spec;
    function automatic logic nonzero(input logic [1:0] value);
        return value == 2'b01 || value == 2'b11;
    endfunction
    function automatic logic opposite(input logic [1:0] a, b);
        return {a, b} == 4'b0111 || {a, b} == 4'b1101;
    endfunction
    function automatic logic [31:0] count8(input logic [7:0] bits);
        logic [31:0] total;
        total = 0;
        for (int i = 0; i < 8; i++) total += {31'b0, bits[i]};
        return total;
    endfunction
endpackage

// Each named assertion covers the entire public output field.
`define FRP_M31_RC_CHECK(FIELD, BIT) \
    always_comb begin \
        mismatch[BIT] = actual.FIELD != expected.FIELD; \
        a_``FIELD: assert(actual.FIELD == expected.FIELD); \
    end

module frp_m31_request_contract_formal (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [1:0] request_valid,
    input logic [5:0] request_cell_index,
    input logic [3:0] request_target,
    input logic [15:0] state_q,
    input logic [15:0] target_q,
    input logic [15:0] pending_route_q,
    output wire [284:0] observed_outputs, expected_outputs,
    output logic [29:0] mismatch,
    output logic [23:0] reach
);
    import frp_m31_request_capacity_contract_spec::*;
    typedef struct packed {
        logic [1:0] request_accept;
        logic [1:0] request_reject;
        logic [1:0] request_reject_invalid_cell;
        logic [1:0] request_reject_invalid_target;
        logic [1:0] request_reject_duplicate_cell;
        logic [1:0] request_reject_scheduler;
        logic [1:0] request_reject_capacity;
        logic [1:0] request_reject_pending_busy;
        logic [1:0] request_reject_tick_disabled;
        logic [1:0] request_neutralized;
        logic [7:0] accepted_cell_mask;
        logic [7:0] rejected_cell_mask;
        logic [7:0] neutral_routed_cell_mask;
        logic [7:0] requested_direct_cell_mask;
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
    assign observed_outputs = actual;
    assign expected_outputs = expected;
`ifdef FRP_M31_REQUEST_CAPACITY_CONTRACT_NETLIST
    frp_m31_request_lanes_netlist dut (
`else
    frp_m31_request_lanes #(
        .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
        .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
    ) dut (
`endif
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .request_valid(request_valid),
        .request_cell_index(request_cell_index),
        .request_target(request_target),
        .state_q(state_q),
        .target_q(target_q),
        .pending_route_q(pending_route_q),
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

    logic [1:0] changed;
    logic [1:0] old_value [0:1];
    logic [1:0] wanted [0:1];
    logic [1:0] pending [0:1];
    logic [2:0] index [0:1];
    logic [1:0] active, allowed, duplicate, busy;
    logic [1:0] commit_request, neutral_request, direct_request;

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
        changed = 0;
        active = request_valid & {2{tick_enable}};
        expected.request_reject_tick_disabled = request_valid & {2{!tick_enable}};
        for (int element = 0; element < 8; element++) begin
            if (state_q[2*element +: 2] == 2)
                expected.request_cell_domain_valid = 0;
            if (target_q[2*element +: 2] == 2 || pending_route_q[2*element +: 2] == 2)
                expected.request_target_domain_valid = 0;
        end
        for (int lane = 0; lane < 2; lane++) begin
            index[lane] = request_cell_index[3*lane +: 3];
            old_value[lane] = state_q[2*index[lane] +: 2];
            wanted[lane] = request_target[2*lane +: 2];
            pending[lane] = pending_route_q[2*index[lane] +: 2];
            commit_request[lane] = old_value[lane] == 0 && nonzero(wanted[lane]);
            neutral_request[lane] = nonzero(old_value[lane]) && wanted[lane] == 0;
            direct_request[lane] = opposite(old_value[lane], wanted[lane]);
            allowed[lane] = scheduler_state < 5 && old_value[lane] != 2 && wanted[lane] != 2
                && ((old_value[lane] == wanted[lane])
                    || (commit_request[lane] && (scheduler_state == 0 || scheduler_state == 2 || scheduler_state == 3))
                    || ((neutral_request[lane] || direct_request[lane])
                        && (scheduler_state == 0 || scheduler_state == 1 || scheduler_state == 4)));
            // A rejected lane never reserves a element for arbitration.
            duplicate[lane] = lane == 1 && expected.request_accept[0]
                && request_cell_index[2:0] == request_cell_index[5:3];
            busy[lane] = nonzero(pending[lane]);
            expected.request_reject_invalid_target[lane] = active[lane] && wanted[lane] == 2;
            expected.request_reject_duplicate_cell[lane] = active[lane] && wanted[lane] != 2 && duplicate[lane];
            expected.request_reject_pending_busy[lane] = active[lane] && wanted[lane] != 2 && !duplicate[lane] && busy[lane];
            expected.request_reject_scheduler[lane] = active[lane] && wanted[lane] != 2 && !duplicate[lane] && !busy[lane] && !allowed[lane];
            expected.request_accept[lane] = active[lane] && wanted[lane] != 2 && !duplicate[lane] && !busy[lane] && allowed[lane];
            expected.request_reject[lane] = active[lane] && !expected.request_accept[lane];
            expected.request_neutralized[lane] = expected.request_accept[lane] && direct_request[lane];
            changed[lane] = expected.request_accept[lane] && old_value[lane] != wanted[lane];
            if (expected.request_reject_invalid_target[lane]) expected.request_target_domain_valid = 0;
            if (expected.request_accept[lane]) expected.accepted_cell_mask[index[lane]] = 1;
            if (expected.request_reject[lane]) expected.rejected_cell_mask[index[lane]] = 1;
            if (expected.request_neutralized[lane]) expected.neutral_routed_cell_mask[index[lane]] = 1;
        end
        expected.requested_direct_cell_mask = expected.neutral_routed_cell_mask;
        expected.accepted_changes = count8({6'b0, changed});
        expected.requested_lane_events = count8({6'b0, active});
        expected.accepted_lane_events = count8({6'b0, expected.request_accept});
        expected.rejected_lane_events = count8({6'b0, expected.request_reject});
        expected.requested_direct_events = count8({6'b0, expected.request_neutralized});
        expected.prevented_direct_events = expected.requested_direct_events;
        expected.neutral_routed_events = expected.requested_direct_events;
    end

    always_comb begin
        reach = 0;
        reach[0] = !tick_enable && request_valid == 3;
        reach[1] = expected.request_accept == 3 && expected.accepted_changes == 2;
        reach[2] = expected.request_accept == 3 && expected.accepted_changes == 0;
        reach[3] = expected.request_accept == 1 && expected.request_reject_duplicate_cell == 2;
        reach[4] = expected.request_reject_invalid_target[0];
        reach[5] = expected.request_reject_pending_busy[0] && pending[0] == 1;
        reach[6] = expected.request_reject_pending_busy[0] && pending[0] == 3;
        reach[7] = expected.request_reject_scheduler[0] && old_value[0] == 2;
        reach[8] = expected.request_accept[0] && pending[0] == 2;
        reach[9] = expected.request_reject[0] && expected.request_accept[1] && index[0] == index[1];
        reach[10] = !tick_enable && !expected.request_target_domain_valid && target_q == 16'haaaa;
        reach[11] = expected.request_reject_scheduler[0] && scheduler_state == 5;
        reach[12] = expected.request_reject_scheduler[0] && scheduler_state == 6;
        reach[13] = expected.request_reject_scheduler[0] && scheduler_state == 7;
        reach[14] = expected.request_neutralized[0] && old_value[0] == 1 && wanted[0] == 3;
        reach[15] = expected.request_neutralized[0] && old_value[0] == 3 && wanted[0] == 1;
        reach[16] = expected.request_neutralized[0] && scheduler_state == 1;
        reach[17] = expected.request_neutralized[0] && scheduler_state == 4;
        reach[18] = expected.request_accept[0] && commit_request[0] && scheduler_state == 2;
        reach[19] = expected.request_accept[0] && commit_request[0] && scheduler_state == 3;
        reach[20] = expected.request_accept[0] && neutral_request[0] && scheduler_state == 0;
        reach[21] = expected.request_reject_invalid_target[1] && duplicate[1];
        reach[22] = expected.request_reject_pending_busy[0] && !allowed[0];
        reach[23] = expected.request_neutralized == 3;
    end

    `FRP_M31_RC_CHECK(request_accept, 0)
    `FRP_M31_RC_CHECK(request_reject, 1)
    `FRP_M31_RC_CHECK(request_reject_invalid_cell, 2)
    `FRP_M31_RC_CHECK(request_reject_invalid_target, 3)
    `FRP_M31_RC_CHECK(request_reject_duplicate_cell, 4)
    `FRP_M31_RC_CHECK(request_reject_scheduler, 5)
    `FRP_M31_RC_CHECK(request_reject_capacity, 6)
    `FRP_M31_RC_CHECK(request_reject_pending_busy, 7)
    `FRP_M31_RC_CHECK(request_reject_tick_disabled, 8)
    `FRP_M31_RC_CHECK(request_neutralized, 9)
    `FRP_M31_RC_CHECK(accepted_cell_mask, 10)
    `FRP_M31_RC_CHECK(rejected_cell_mask, 11)
    `FRP_M31_RC_CHECK(neutral_routed_cell_mask, 12)
    `FRP_M31_RC_CHECK(requested_direct_cell_mask, 13)
    `FRP_M31_RC_CHECK(accepted_changes, 14)
    `FRP_M31_RC_CHECK(requested_lane_events, 15)
    `FRP_M31_RC_CHECK(accepted_lane_events, 16)
    `FRP_M31_RC_CHECK(rejected_lane_events, 17)
    `FRP_M31_RC_CHECK(requested_direct_events, 18)
    `FRP_M31_RC_CHECK(prevented_direct_events, 19)
    `FRP_M31_RC_CHECK(neutral_routed_events, 20)
    `FRP_M31_RC_CHECK(request_lane_order_valid, 21)
    `FRP_M31_RC_CHECK(request_cell_domain_valid, 22)
    `FRP_M31_RC_CHECK(request_target_domain_valid, 23)
    `FRP_M31_RC_CHECK(duplicate_cell_guard_valid, 24)
    `FRP_M31_RC_CHECK(scheduler_gate_valid, 25)
    `FRP_M31_RC_CHECK(transition_capacity_valid, 26)
    `FRP_M31_RC_CHECK(active_neutral_routing_valid, 27)
    `FRP_M31_RC_CHECK(no_actual_direct_events, 28)
    `FRP_M31_RC_CHECK(no_queue_overflow, 29)
endmodule

module frp_m31_capacity_contract_formal (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [1:0] request_accept_candidate,
    input logic [5:0] request_cell_index,
    input logic [7:0] transition_class,
    input logic [7:0] pending_completion_candidate,
    input logic [7:0] neutral_routed_candidate,
    input logic [15:0] state_q,
    input logic [15:0] state_candidate_d,
    output wire [294:0] observed_outputs, expected_outputs,
    output logic [23:0] mismatch,
    output logic [23:0] reach
);
    import frp_m31_request_capacity_contract_spec::*;
    typedef struct packed {
        logic [1:0] request_accept_capacity;
        logic [1:0] request_reject_capacity;
        logic [7:0] capacity_accept_mask;
        logic [7:0] capacity_reject_mask;
        logic [7:0] accepted_change_mask;
        logic [31:0] accepted_changes;
        logic [31:0] capacity_remaining;
        logic capacity_exhausted;
        logic [31:0] switch_load_numerator;
        logic [31:0] capacity_candidate_events;
        logic [31:0] capacity_accept_events;
        logic [31:0] capacity_reject_events;
        logic [31:0] capacity_exhausted_events;
        logic [31:0] accepted_change_events;
        logic transition_capacity_valid;
        logic accepted_changes_within_limit;
        logic capacity_remaining_valid;
        logic capacity_exhaustion_valid;
        logic same_state_capacity_valid;
        logic pending_capacity_valid;
        logic active_neutral_capacity_valid;
        logic switch_load_bound_valid;
        logic no_queue_overflow;
        logic no_actual_direct_events;
    } result_t;
    result_t actual, expected;
    assign observed_outputs = actual;
    assign expected_outputs = expected;
`ifdef FRP_M31_REQUEST_CAPACITY_CONTRACT_NETLIST
    frp_m31_capacity_guard_netlist dut (
`else
    frp_m31_capacity_guard #(
        .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
        .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
    ) dut (
`endif
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .request_accept_candidate(request_accept_candidate),
        .request_cell_index(request_cell_index),
        .transition_class(transition_class),
        .pending_completion_candidate(pending_completion_candidate),
        .neutral_routed_candidate(neutral_routed_candidate),
        .state_q(state_q),
        .state_candidate_d(state_candidate_d),
        .request_accept_capacity(actual.request_accept_capacity),
        .request_reject_capacity(actual.request_reject_capacity),
        .capacity_accept_mask(actual.capacity_accept_mask),
        .capacity_reject_mask(actual.capacity_reject_mask),
        .accepted_change_mask(actual.accepted_change_mask),
        .accepted_changes(actual.accepted_changes),
        .capacity_remaining(actual.capacity_remaining),
        .capacity_exhausted(actual.capacity_exhausted),
        .switch_load_numerator(actual.switch_load_numerator),
        .capacity_candidate_events(actual.capacity_candidate_events),
        .capacity_accept_events(actual.capacity_accept_events),
        .capacity_reject_events(actual.capacity_reject_events),
        .capacity_exhausted_events(actual.capacity_exhausted_events),
        .accepted_change_events(actual.accepted_change_events),
        .transition_capacity_valid(actual.transition_capacity_valid),
        .accepted_changes_within_limit(actual.accepted_changes_within_limit),
        .capacity_remaining_valid(actual.capacity_remaining_valid),
        .capacity_exhaustion_valid(actual.capacity_exhaustion_valid),
        .same_state_capacity_valid(actual.same_state_capacity_valid),
        .pending_capacity_valid(actual.pending_capacity_valid),
        .active_neutral_capacity_valid(actual.active_neutral_capacity_valid),
        .switch_load_bound_valid(actual.switch_load_bound_valid),
        .no_queue_overflow(actual.no_queue_overflow),
        .no_actual_direct_events(actual.no_actual_direct_events)
    );

    logic [7:0] eligible, selected, pending_reject, bad_pending, direct_mask;
    logic [1:0] lane_candidate, lane_change, bad_general, bad_neutral, bad_same;
    logic [1:0] old_value [0:1], next_value [0:1];
    logic [2:0] index [0:1];
    logic [3:0] kind [0:1];
    logic [1:0] raw_direct, blocked, legal_route;
    logic [31:0] used;

    always_comb begin
        expected = '0;
        eligible = 0;
        selected = 0;
        direct_mask = 0;
        lane_candidate = 0;
        lane_change = 0;
        bad_general = 0;
        bad_neutral = 0;
        bad_same = 0;
        // Rank eligible pending cells independently; the lowest two own slots.
        for (int element = 0; element < 8; element++)
            eligible[element] = tick_enable && pending_completion_candidate[element]
                && state_q[2*element +: 2] == 0 && nonzero(state_candidate_d[2*element +: 2]);
        for (int element = 0; element < 8; element++)
            selected[element] = eligible[element] && count8(eligible & (8'hff >> (8-element))) < 2;
        pending_reject = ({8{tick_enable}} & pending_completion_candidate) & ~selected;
        bad_pending = ({8{tick_enable}} & pending_completion_candidate) & ~eligible;
        expected.capacity_accept_mask = selected;
        expected.accepted_change_mask = selected;
        expected.capacity_reject_mask = pending_reject;
        used = count8(selected);
        for (int lane = 0; lane < 2; lane++) begin
            index[lane] = request_cell_index[3*lane +: 3];
            old_value[lane] = state_q[2*index[lane] +: 2];
            next_value[lane] = state_candidate_d[2*index[lane] +: 2];
            kind[lane] = transition_class[4*lane +: 4];
            raw_direct[lane] = opposite(old_value[lane], next_value[lane]);
            if (raw_direct[lane]) direct_mask[index[lane]] = 1;
            legal_route[lane] = neutral_routed_candidate[index[lane]]
                && nonzero(old_value[lane]) && next_value[lane] == 0;
            blocked[lane] = pending_completion_candidate[index[lane]] || expected.capacity_accept_mask[index[lane]];
            if (tick_enable && request_accept_candidate[lane]) begin
                // Raw pending ownership precedes operand/class diagnostics.
                if (!blocked[lane]) begin
                    bad_general[lane] = old_value[lane] == 2 || next_value[lane] == 2 || kind[lane] > 3 || raw_direct[lane];
                    if (!bad_general[lane]) begin
                        if (kind[lane] == 3) begin
                            lane_candidate[lane] = 1;
                            bad_neutral[lane] = !legal_route[lane];
                        end else begin
                            bad_same[lane] = (kind[lane] == 0) != (old_value[lane] == next_value[lane]);
                            lane_candidate[lane] = !bad_same[lane] && kind[lane] != 0;
                        end
                        if (!bad_neutral[lane] && !bad_same[lane]) begin
                            if (!lane_candidate[lane] || used < 2) begin
                                expected.request_accept_capacity[lane] = 1;
                                expected.capacity_accept_mask[index[lane]] = 1;
                                lane_change[lane] = lane_candidate[lane];
                                if (lane_change[lane]) expected.accepted_change_mask[index[lane]] = 1;
                                used += {31'b0, lane_change[lane]};
                            end
                        end
                    end
                end
                expected.request_reject_capacity[lane] = !expected.request_accept_capacity[lane];
                if (expected.request_reject_capacity[lane]) expected.capacity_reject_mask[index[lane]] = 1;
            end
        end
        expected.accepted_changes = used;
        expected.capacity_remaining = 2 - used;
        expected.capacity_exhausted = used == 2;
        expected.switch_load_numerator = used;
        expected.capacity_candidate_events = count8(eligible) + count8({6'b0, lane_candidate});
        expected.capacity_accept_events = used;
        expected.capacity_reject_events = count8(pending_reject) + count8({6'b0, expected.request_reject_capacity});
        expected.capacity_exhausted_events = {31'b0, expected.capacity_exhausted};
        expected.accepted_change_events = used;
        expected.accepted_changes_within_limit = 1;
        expected.capacity_remaining_valid = 1;
        expected.capacity_exhaustion_valid = 1;
        expected.same_state_capacity_valid = bad_same == 0;
        expected.pending_capacity_valid = bad_pending == 0;
        expected.active_neutral_capacity_valid = bad_neutral == 0 && (bad_general & raw_direct) == 0
            && ((expected.capacity_accept_mask & ~expected.accepted_change_mask & neutral_routed_candidate) == 0);
        expected.switch_load_bound_valid = 1;
        expected.no_queue_overflow = 1;
        expected.no_actual_direct_events = (expected.capacity_accept_mask & direct_mask) == 0;
        expected.transition_capacity_valid = scheduler_state < 5 && bad_general == 0
            && expected.same_state_capacity_valid && expected.pending_capacity_valid
            && expected.active_neutral_capacity_valid && expected.no_actual_direct_events;
    end

    always_comb begin
        reach = 0;
        reach[0] = !tick_enable && request_accept_candidate == 3 && pending_completion_candidate == 8'hff;
        reach[1] = count8(eligible) == 8 && selected == 3;
        reach[2] = count8(eligible) == 1 && expected.accepted_changes == 1;
        reach[3] = count8(eligible) == 2 && expected.request_accept_capacity[0] && kind[0] == 0;
        reach[4] = expected.request_accept_capacity == 3 && expected.accepted_changes == 0;
        reach[5] = expected.request_accept_capacity == 3 && expected.accepted_changes == 2;
        reach[6] = expected.request_accept_capacity[0] && expected.request_reject_capacity[1] && index[0] == index[1];
        reach[7] = tick_enable && request_accept_candidate[0] && bad_pending[index[0]];
        reach[8] = bad_general[0] && old_value[0] == 2;
        reach[9] = bad_general[0] && next_value[0] == 2;
        reach[10] = bad_general[0] && kind[0] == 15;
        reach[11] = bad_general[0] && raw_direct[0] && old_value[0] == 1;
        reach[12] = bad_general[0] && raw_direct[0] && old_value[0] == 3;
        reach[13] = expected.request_accept_capacity[0] && kind[0] == 3 && old_value[0] == 1;
        reach[14] = expected.request_accept_capacity[0] && kind[0] == 3 && old_value[0] == 3;
        reach[15] = bad_neutral[0] && !neutral_routed_candidate[index[0]];
        reach[16] = bad_same[0] && kind[0] == 0;
        reach[17] = bad_same[0] && kind[0] == 1;
        reach[18] = lane_candidate[0] && !bad_neutral[0] && expected.request_reject_capacity[0] && count8(selected) == 2;
        reach[19] = tick_enable && expected.request_accept_capacity[0] && scheduler_state == 7;
        reach[20] = expected.request_accept_capacity[0] && kind[0] == 0 && neutral_routed_candidate[index[0]];
        reach[21] = count8(eligible) == 0 && expected.capacity_candidate_events == 0 && bad_pending != 0;
        reach[22] = expected.request_reject_capacity[0] && expected.request_accept_capacity[1] && index[0] == index[1];
        reach[23] = count8(eligible) == 7 && lane_candidate[0] && expected.capacity_candidate_events == 8 && expected.capacity_reject_events >= 6;
    end

    `FRP_M31_RC_CHECK(request_accept_capacity, 0)
    `FRP_M31_RC_CHECK(request_reject_capacity, 1)
    `FRP_M31_RC_CHECK(capacity_accept_mask, 2)
    `FRP_M31_RC_CHECK(capacity_reject_mask, 3)
    `FRP_M31_RC_CHECK(accepted_change_mask, 4)
    `FRP_M31_RC_CHECK(accepted_changes, 5)
    `FRP_M31_RC_CHECK(capacity_remaining, 6)
    `FRP_M31_RC_CHECK(capacity_exhausted, 7)
    `FRP_M31_RC_CHECK(switch_load_numerator, 8)
    `FRP_M31_RC_CHECK(capacity_candidate_events, 9)
    `FRP_M31_RC_CHECK(capacity_accept_events, 10)
    `FRP_M31_RC_CHECK(capacity_reject_events, 11)
    `FRP_M31_RC_CHECK(capacity_exhausted_events, 12)
    `FRP_M31_RC_CHECK(accepted_change_events, 13)
    `FRP_M31_RC_CHECK(transition_capacity_valid, 14)
    `FRP_M31_RC_CHECK(accepted_changes_within_limit, 15)
    `FRP_M31_RC_CHECK(capacity_remaining_valid, 16)
    `FRP_M31_RC_CHECK(capacity_exhaustion_valid, 17)
    `FRP_M31_RC_CHECK(same_state_capacity_valid, 18)
    `FRP_M31_RC_CHECK(pending_capacity_valid, 19)
    `FRP_M31_RC_CHECK(active_neutral_capacity_valid, 20)
    `FRP_M31_RC_CHECK(switch_load_bound_valid, 21)
    `FRP_M31_RC_CHECK(no_queue_overflow, 22)
    `FRP_M31_RC_CHECK(no_actual_direct_events, 23)
endmodule

`undef FRP_M31_RC_CHECK
`endif

// Copyright (c) 2026 Maksym Marnov. All rights reserved.
// Proprietary. No license is granted by this file.
// Independent contracts: active neutral, pending routes, state writeback.
// Fixed profile: eight two-bit cells, two lanes, 32-bit event counters.
// All input combinations are checked, including invalid metadata and codes.
// Sequential tops assume reset at the first sampled edge only; later reset,
// tick, scheduler, requests and masks remain unrestricted.
// Three-bit indices cover exactly eight cells; out-of-range indices are absent.
// These are local functional contracts, not full-core or physical proofs.
`ifndef FRP_M31_ROUTE_WRITEBACK_CONTRACT_FORMAL_SV
`define FRP_M31_ROUTE_WRITEBACK_CONTRACT_FORMAL_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_ROUTE_WRITEBACK_CONTRACT_NETLIST
`include "frp_m31_active_neutral.sv"
`include "frp_m31_pending_routes.sv"
`include "frp_m31_state_update.sv"
`endif

package frp_m31_route_writeback_contract_spec;
    function automatic logic nonzero(input logic [1:0] value);
        return value == 1 || value == 3;
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
    function automatic logic [7:0] zero8(input logic [15:0] bank);
        for (int i = 0; i < 8; i++) zero8[i] = bank[2*i +: 2] == 0;
    endfunction
    function automatic logic [7:0] nonzero8(input logic [15:0] bank);
        for (int i = 0; i < 8; i++) nonzero8[i] = nonzero(bank[2*i +: 2]);
    endfunction
    function automatic logic [7:0] reserved8(input logic [15:0] bank);
        for (int i = 0; i < 8; i++) reserved8[i] = bank[2*i +: 2] == 2;
    endfunction
endpackage

`define FRP_M31_RW_CHECK(FIELD, BIT) \
    always_comb begin \
        mismatch[BIT] = ready && actual.FIELD != expected.FIELD; \
        if (ready) begin \
            a_``FIELD: assert(actual.FIELD == expected.FIELD); \
        end \
    end

module frp_m31_neutral_contract_formal (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [15:0] state_q,
    input logic [15:0] pending_route_q,
    input logic [1:0] request_accept,
    input logic [1:0] request_neutralized,
    input logic [5:0] request_cell_index,
    input logic [3:0] request_target,
    input logic [7:0] pending_completion_enable,
    output wire [423:0] observed_outputs, expected_outputs,
    output logic [28:0] mismatch,
    output logic [23:0] reach
);
    import frp_m31_route_writeback_contract_spec::*;
    typedef struct packed {
        logic [15:0] state_candidate_d;
        logic [7:0] transition_valid_mask;
        logic [7:0] same_state_mask;
        logic [7:0] zero_to_nonzero_mask;
        logic [7:0] nonzero_to_zero_mask;
        logic [7:0] opposite_polarity_mask;
        logic [7:0] neutral_routed_mask;
        logic [7:0] pending_completion_mask;
        logic [7:0] actual_direct_mask;
        logic [7:0] reserved_transition_mask;
        logic [7:0] accepted_change_candidate_mask;
        logic [31:0] same_state_events;
        logic [31:0] zero_to_nonzero_events;
        logic [31:0] nonzero_to_zero_events;
        logic [31:0] requested_direct_events;
        logic [31:0] prevented_direct_events;
        logic [31:0] neutral_routed_events;
        logic [31:0] pending_completion_events;
        logic [31:0] actual_direct_events;
        logic [31:0] reserved_transition_events;
        logic [31:0] accepted_change_candidate_events;
        logic transition_domain_valid;
        logic active_neutral_routing_valid;
        logic pending_completion_from_zero_valid;
        logic no_reserved_transition;
        logic no_actual_direct_events;
        logic transition_capacity_valid;
        logic state_output_domain_valid;
        logic transition_replay_deterministic;
    } result_t;
    result_t actual, expected;
    assign observed_outputs = actual;
    assign expected_outputs = expected;
    wire ready = 1'b1;
`ifdef FRP_M31_ROUTE_WRITEBACK_CONTRACT_NETLIST
    frp_m31_active_neutral_netlist dut (
`else
    frp_m31_active_neutral #(
        .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
        .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
    ) dut (
`endif
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .state_q(state_q),
        .pending_route_q(pending_route_q),
        .request_accept(request_accept),
        .request_neutralized(request_neutralized),
        .request_cell_index(request_cell_index),
        .request_target(request_target),
        .pending_completion_enable(pending_completion_enable),
        .state_candidate_d(actual.state_candidate_d),
        .transition_valid_mask(actual.transition_valid_mask),
        .same_state_mask(actual.same_state_mask),
        .zero_to_nonzero_mask(actual.zero_to_nonzero_mask),
        .nonzero_to_zero_mask(actual.nonzero_to_zero_mask),
        .opposite_polarity_mask(actual.opposite_polarity_mask),
        .neutral_routed_mask(actual.neutral_routed_mask),
        .pending_completion_mask(actual.pending_completion_mask),
        .actual_direct_mask(actual.actual_direct_mask),
        .reserved_transition_mask(actual.reserved_transition_mask),
        .accepted_change_candidate_mask(actual.accepted_change_candidate_mask),
        .same_state_events(actual.same_state_events),
        .zero_to_nonzero_events(actual.zero_to_nonzero_events),
        .nonzero_to_zero_events(actual.nonzero_to_zero_events),
        .requested_direct_events(actual.requested_direct_events),
        .prevented_direct_events(actual.prevented_direct_events),
        .neutral_routed_events(actual.neutral_routed_events),
        .pending_completion_events(actual.pending_completion_events),
        .actual_direct_events(actual.actual_direct_events),
        .reserved_transition_events(actual.reserved_transition_events),
        .accepted_change_candidate_events(actual.accepted_change_candidate_events),
        .transition_domain_valid(actual.transition_domain_valid),
        .active_neutral_routing_valid(actual.active_neutral_routing_valid),
        .pending_completion_from_zero_valid(actual.pending_completion_from_zero_valid),
        .no_reserved_transition(actual.no_reserved_transition),
        .no_actual_direct_events(actual.no_actual_direct_events),
        .transition_capacity_valid(actual.transition_capacity_valid),
        .state_output_domain_valid(actual.state_output_domain_valid),
        .transition_replay_deterministic(actual.transition_replay_deterministic)
    );

    logic [7:0] bank_bad, done_mask, completion_bad, completion_operand_bad;
    logic [1:0] lane_bad, lane_owned, lane_same, lane_commit, lane_zero, lane_opposite, lane_route;
    logic [1:0] old_value [0:1], wanted [0:1];
    logic [2:0] index [0:1];
    logic commit_phase, neutral_phase;

    always_comb begin
        expected = '0;
        expected.state_candidate_d = state_q;
        bank_bad = reserved8(state_q) | reserved8(pending_route_q);
        done_mask = 0;
        completion_operand_bad = 0;
        commit_phase = scheduler_state == 0 || scheduler_state == 2 || scheduler_state == 3;
        neutral_phase = scheduler_state == 0 || scheduler_state == 1 || scheduler_state == 4;
        for (int i = 0; i < 8; i++) begin
            if (tick_enable && pending_completion_enable[i]) begin
                completion_operand_bad[i] = state_q[2*i +: 2] == 2 || !nonzero(pending_route_q[2*i +: 2]);
                done_mask[i] = state_q[2*i +: 2] == 0 && nonzero(pending_route_q[2*i +: 2]) && commit_phase;
                if (done_mask[i]) expected.state_candidate_d[2*i +: 2] = pending_route_q[2*i +: 2];
            end
        end
        completion_bad = ({8{tick_enable}} & pending_completion_enable) & ~done_mask;
        expected.transition_valid_mask = done_mask;
        expected.zero_to_nonzero_mask = done_mask;
        expected.pending_completion_mask = done_mask;
        expected.accepted_change_candidate_mask = done_mask;
        expected.reserved_transition_mask = bank_bad | completion_operand_bad;
        lane_bad = 0;
        lane_owned = 0;
        lane_same = 0;
        lane_commit = 0;
        lane_zero = 0;
        lane_opposite = 0;
        lane_route = 0;
        for (int lane = 0; lane < 2; lane++) begin
            index[lane] = request_cell_index[3*lane +: 3];
            old_value[lane] = state_q[2*index[lane] +: 2];
            wanted[lane] = request_target[2*lane +: 2];
            if (tick_enable && request_accept[lane]) begin
                lane_bad[lane] = old_value[lane] == 2 || wanted[lane] == 2;
                lane_owned[lane] = !lane_bad[lane] && done_mask[index[lane]];
                if (lane_bad[lane]) expected.reserved_transition_mask[index[lane]] = 1;
                if (!lane_bad[lane] && !lane_owned[lane]) begin
                    lane_same[lane] = old_value[lane] == wanted[lane];
                    lane_commit[lane] = old_value[lane] == 0 && nonzero(wanted[lane]) && commit_phase;
                    lane_zero[lane] = nonzero(old_value[lane]) && wanted[lane] == 0 && neutral_phase;
                    lane_opposite[lane] = opposite(old_value[lane], wanted[lane]);
                    lane_route[lane] = lane_opposite[lane] && request_neutralized[lane] && neutral_phase;
                    if (lane_same[lane]) expected.same_state_mask[index[lane]] = 1;
                    if (lane_commit[lane]) begin
                        expected.state_candidate_d[2*index[lane] +: 2] = wanted[lane];
                        expected.zero_to_nonzero_mask[index[lane]] = 1;
                    end
                    if (lane_zero[lane] || lane_route[lane]) begin
                        expected.state_candidate_d[2*index[lane] +: 2] = 0;
                        expected.nonzero_to_zero_mask[index[lane]] = 1;
                    end
                    if (lane_route[lane]) begin
                        expected.opposite_polarity_mask[index[lane]] = 1;
                        expected.neutral_routed_mask[index[lane]] = 1;
                    end
                    if (lane_commit[lane] || lane_zero[lane] || lane_route[lane])
                        expected.accepted_change_candidate_mask[index[lane]] = 1;
                    if (lane_same[lane] || lane_commit[lane] || lane_zero[lane] || lane_route[lane])
                        expected.transition_valid_mask[index[lane]] = 1;
                end
            end
        end
        expected.same_state_events = count8({6'b0, lane_same});
        expected.zero_to_nonzero_events = count8(done_mask) + count8({6'b0, lane_commit});
        expected.nonzero_to_zero_events = count8({6'b0, lane_zero | lane_route});
        expected.requested_direct_events = count8({6'b0, lane_opposite});
        expected.prevented_direct_events = count8({6'b0, lane_route});
        expected.neutral_routed_events = expected.prevented_direct_events;
        expected.pending_completion_events = count8(done_mask);
        expected.reserved_transition_events = count8(bank_bad) + count8({6'b0, lane_bad});
        expected.accepted_change_candidate_events = count8(done_mask) + count8({6'b0, lane_commit | lane_zero | lane_route});
        expected.state_output_domain_valid = reserved8(expected.state_candidate_d) == 0;
        expected.no_reserved_transition = expected.reserved_transition_mask == 0;
        expected.transition_domain_valid = expected.no_reserved_transition && expected.state_output_domain_valid;
        expected.no_actual_direct_events = 1;
        expected.pending_completion_from_zero_valid = completion_bad == 0;
        expected.active_neutral_routing_valid = lane_opposite == lane_route;
        expected.transition_capacity_valid = expected.accepted_change_candidate_events == count8(expected.accepted_change_candidate_mask);
        expected.transition_replay_deterministic = lane_bad == 0 && lane_owned == 0 && scheduler_state < 5
            && expected.transition_domain_valid && expected.pending_completion_from_zero_valid && expected.active_neutral_routing_valid;
    end

    always_comb begin
        reach = 0;
        reach[0] = !tick_enable && bank_bad != 0 && expected.reserved_transition_events != 0;
        reach[1] = done_mask[0] && pending_route_q[1:0] == 1;
        reach[2] = done_mask[0] && pending_route_q[1:0] == 3;
        reach[3] = done_mask == 8'hff;
        reach[4] = completion_bad[0] && nonzero(state_q[1:0]) && nonzero(pending_route_q[1:0]);
        reach[5] = completion_bad[0] && state_q[1:0] == 0 && nonzero(pending_route_q[1:0]) && scheduler_state == 1;
        reach[6] = completion_operand_bad[0] && pending_route_q[1:0] == 0 && bank_bad == 0 && expected.reserved_transition_events == 0;
        reach[7] = bank_bad == 8'hff && expected.reserved_transition_events == 8;
        reach[8] = lane_same[0] && scheduler_state == 7;
        reach[9] = lane_route[0] && old_value[0] == 1;
        reach[10] = lane_route[0] && old_value[0] == 3;
        reach[11] = lane_opposite[0] && !request_neutralized[0];
        reach[12] = lane_opposite[0] && request_neutralized[0] && scheduler_state == 2;
        reach[13] = expected.accepted_change_candidate_events == 2 && count8(expected.accepted_change_candidate_mask) == 2;
        reach[14] = expected.accepted_change_candidate_events == 2 && count8(expected.accepted_change_candidate_mask) == 1;
        reach[15] = lane_commit == 3 && index[0] == index[1] && wanted[0] == 1 && wanted[1] == 3;
        reach[16] = lane_owned[0];
        reach[17] = lane_bad[0] && done_mask[index[0]];
        reach[18] = lane_bad[0] && old_value[0] == 2;
        reach[19] = lane_bad == 3 && index[0] == index[1] && bank_bad == 0;
        reach[20] = lane_commit[0] && scheduler_state == 2;
        reach[21] = lane_route[0] && scheduler_state == 4;
        reach[22] = !tick_enable && pending_completion_enable == 8'hff && bank_bad == 0;
        reach[23] = lane_commit[0] && reserved8(pending_route_q) != 0;
    end

    `FRP_M31_RW_CHECK(state_candidate_d, 0)
    `FRP_M31_RW_CHECK(transition_valid_mask, 1)
    `FRP_M31_RW_CHECK(same_state_mask, 2)
    `FRP_M31_RW_CHECK(zero_to_nonzero_mask, 3)
    `FRP_M31_RW_CHECK(nonzero_to_zero_mask, 4)
    `FRP_M31_RW_CHECK(opposite_polarity_mask, 5)
    `FRP_M31_RW_CHECK(neutral_routed_mask, 6)
    `FRP_M31_RW_CHECK(pending_completion_mask, 7)
    `FRP_M31_RW_CHECK(actual_direct_mask, 8)
    `FRP_M31_RW_CHECK(reserved_transition_mask, 9)
    `FRP_M31_RW_CHECK(accepted_change_candidate_mask, 10)
    `FRP_M31_RW_CHECK(same_state_events, 11)
    `FRP_M31_RW_CHECK(zero_to_nonzero_events, 12)
    `FRP_M31_RW_CHECK(nonzero_to_zero_events, 13)
    `FRP_M31_RW_CHECK(requested_direct_events, 14)
    `FRP_M31_RW_CHECK(prevented_direct_events, 15)
    `FRP_M31_RW_CHECK(neutral_routed_events, 16)
    `FRP_M31_RW_CHECK(pending_completion_events, 17)
    `FRP_M31_RW_CHECK(actual_direct_events, 18)
    `FRP_M31_RW_CHECK(reserved_transition_events, 19)
    `FRP_M31_RW_CHECK(accepted_change_candidate_events, 20)
    `FRP_M31_RW_CHECK(transition_domain_valid, 21)
    `FRP_M31_RW_CHECK(active_neutral_routing_valid, 22)
    `FRP_M31_RW_CHECK(pending_completion_from_zero_valid, 23)
    `FRP_M31_RW_CHECK(no_reserved_transition, 24)
    `FRP_M31_RW_CHECK(no_actual_direct_events, 25)
    `FRP_M31_RW_CHECK(transition_capacity_valid, 26)
    `FRP_M31_RW_CHECK(state_output_domain_valid, 27)
    `FRP_M31_RW_CHECK(transition_replay_deterministic, 28)
endmodule

module frp_m31_pending_contract_formal (
    input logic clk,
    input logic rst_n,
    input logic tick_enable,
    input logic [15:0] state_q,
    input logic [1:0] request_accept,
    input logic [1:0] request_neutralized,
    input logic [5:0] request_cell_index,
    input logic [3:0] request_target,
    input logic [7:0] pending_completion_accept_mask,
    output wire [424:0] observed_outputs, expected_outputs,
    output logic [28:0] mismatch,
    output logic [23:0] reach
);
    import frp_m31_route_writeback_contract_spec::*;
    typedef struct packed {
        logic [15:0] pending_route_q;
        logic [15:0] pending_route_d;
        logic [7:0] pending_active_mask;
        logic [7:0] pending_created_mask;
        logic [7:0] pending_completed_mask;
        logic [7:0] pending_cleared_mask;
        logic [7:0] pending_retained_mask;
        logic [7:0] pending_blocked_mask;
        logic [7:0] pending_reserved_mask;
        logic [7:0] pending_overflow_mask;
        logic [31:0] pending_active_count;
        logic [31:0] pending_created_events;
        logic [31:0] pending_completed_events;
        logic [31:0] pending_cleared_events;
        logic [31:0] pending_retained_events;
        logic [31:0] pending_reserved_events;
        logic [31:0] neutral_routed_events;
        logic [31:0] prevented_direct_events;
        logic [31:0] queue_overflow_events;
        logic [31:0] actual_direct_events;
        logic pending_domain_valid;
        logic pending_polarity_valid;
        logic pending_completion_from_zero_valid;
        logic pending_non_overwrite_valid;
        logic pending_capacity_valid;
        logic pending_replay_deterministic;
        logic no_pending_reserved_state;
        logic no_queue_overflow;
        logic no_actual_direct_events;
    } result_t;
    result_t actual, expected;
    assign observed_outputs = actual;
    assign expected_outputs = expected;
    logic history_valid = 0;
    logic [15:0] reference_q;
    wire ready = history_valid;
    always @(posedge clk) begin
        history_valid <= 1;
        if (!history_valid) begin
            initial_reset: assume(!rst_n);
        end
    end
    // Predict each registered transition from public state and independent D.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) reference_q <= 0;
        else if (tick_enable) reference_q <= expected.pending_route_d;
    end
    always_comb begin
        if (ready) begin
            a_retained_encoding: assert(reserved8(actual.pending_route_q) == 0);
        end
    end
`ifdef FRP_M31_ROUTE_WRITEBACK_CONTRACT_NETLIST
    frp_m31_pending_routes_netlist dut (
`else
    frp_m31_pending_routes #(
        .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
        .CELL_INDEX_BITS(3), .COUNTER_BITS(32)
    ) dut (
`endif
        .clk(clk),
        .rst_n(rst_n),
        .tick_enable(tick_enable),
        .state_q(state_q),
        .request_accept(request_accept),
        .request_neutralized(request_neutralized),
        .request_cell_index(request_cell_index),
        .request_target(request_target),
        .pending_completion_accept_mask(pending_completion_accept_mask),
        .pending_route_q(actual.pending_route_q),
        .pending_route_d(actual.pending_route_d),
        .pending_active_mask(actual.pending_active_mask),
        .pending_created_mask(actual.pending_created_mask),
        .pending_completed_mask(actual.pending_completed_mask),
        .pending_cleared_mask(actual.pending_cleared_mask),
        .pending_retained_mask(actual.pending_retained_mask),
        .pending_blocked_mask(actual.pending_blocked_mask),
        .pending_reserved_mask(actual.pending_reserved_mask),
        .pending_overflow_mask(actual.pending_overflow_mask),
        .pending_active_count(actual.pending_active_count),
        .pending_created_events(actual.pending_created_events),
        .pending_completed_events(actual.pending_completed_events),
        .pending_cleared_events(actual.pending_cleared_events),
        .pending_retained_events(actual.pending_retained_events),
        .pending_reserved_events(actual.pending_reserved_events),
        .neutral_routed_events(actual.neutral_routed_events),
        .prevented_direct_events(actual.prevented_direct_events),
        .queue_overflow_events(actual.queue_overflow_events),
        .actual_direct_events(actual.actual_direct_events),
        .pending_domain_valid(actual.pending_domain_valid),
        .pending_polarity_valid(actual.pending_polarity_valid),
        .pending_completion_from_zero_valid(actual.pending_completion_from_zero_valid),
        .pending_non_overwrite_valid(actual.pending_non_overwrite_valid),
        .pending_capacity_valid(actual.pending_capacity_valid),
        .pending_replay_deterministic(actual.pending_replay_deterministic),
        .no_pending_reserved_state(actual.no_pending_reserved_state),
        .no_queue_overflow(actual.no_queue_overflow),
        .no_actual_direct_events(actual.no_actual_direct_events)
    );

    logic [7:0] active_mask, done_mask, invalid_completion, claimed;
    logic [1:0] route_lane, bad_relation, overflow_lane;
    logic [2:0] index [0:1];
    logic [1:0] old_value [0:1], wanted [0:1];

    always_comb begin
        expected = '0;
        expected.pending_route_q = reference_q;
        expected.pending_route_d = actual.pending_route_q;
        active_mask = nonzero8(actual.pending_route_q);
        done_mask = active_mask & {8{tick_enable}} & pending_completion_accept_mask & zero8(state_q);
        invalid_completion = ({8{tick_enable}} & pending_completion_accept_mask) & ~done_mask;
        expected.pending_active_mask = active_mask;
        expected.pending_completed_mask = done_mask;
        expected.pending_cleared_mask = done_mask;
        expected.pending_retained_mask = active_mask & ~done_mask;
        expected.pending_blocked_mask = expected.pending_retained_mask;
        expected.pending_reserved_mask = reserved8(actual.pending_route_q);
        for (int i = 0; i < 8; i++)
            if (done_mask[i]) expected.pending_route_d[2*i +: 2] = 0;
        claimed = 0;
        route_lane = request_accept & request_neutralized & {2{tick_enable}};
        bad_relation = 0;
        overflow_lane = 0;
        for (int lane = 0; lane < 2; lane++) begin
            index[lane] = request_cell_index[3*lane +: 3];
            old_value[lane] = state_q[2*index[lane] +: 2];
            wanted[lane] = request_target[2*lane +: 2];
            if (route_lane[lane]) begin
                bad_relation[lane] = !opposite(old_value[lane], wanted[lane]);
                if (!bad_relation[lane]) begin
                    overflow_lane[lane] = actual.pending_route_q[2*index[lane] +: 2] != 0 || done_mask[index[lane]] || claimed[index[lane]];
                    if (overflow_lane[lane]) begin
                        expected.pending_blocked_mask[index[lane]] = 1;
                        expected.pending_overflow_mask[index[lane]] = 1;
                    end else begin
                        claimed[index[lane]] = 1;
                        expected.pending_route_d[2*index[lane] +: 2] = wanted[lane];
                    end
                end
            end
        end
        expected.pending_created_mask = claimed;
        expected.pending_active_count = count8(active_mask);
        expected.pending_created_events = count8(claimed);
        expected.pending_completed_events = count8(done_mask);
        expected.pending_cleared_events = expected.pending_completed_events;
        expected.pending_retained_events = tick_enable ? count8(expected.pending_retained_mask) : 0;
        expected.pending_reserved_events = count8(expected.pending_reserved_mask);
        expected.neutral_routed_events = count8({6'b0, route_lane});
        expected.prevented_direct_events = expected.neutral_routed_events;
        expected.queue_overflow_events = count8({6'b0, overflow_lane});
        expected.pending_domain_valid = expected.pending_reserved_mask == 0;
        expected.pending_polarity_valid = bad_relation == 0;
        expected.pending_completion_from_zero_valid = (invalid_completion & active_mask) == 0;
        expected.pending_non_overwrite_valid = overflow_lane == 0;
        expected.pending_capacity_valid = invalid_completion == 0 && count8(done_mask) <= 2;
        expected.pending_replay_deterministic = invalid_completion == 0 && bad_relation == 0 && overflow_lane == 0;
        expected.no_pending_reserved_state = expected.pending_domain_valid;
        expected.no_queue_overflow = overflow_lane == 0;
        expected.no_actual_direct_events = 1;
    end

    always_comb begin
        reach = 0;
        if (ready) begin
            reach[0] = claimed[index[0]] && route_lane[0] && old_value[0] == 1 && wanted[0] == 3;
            reach[1] = claimed[index[0]] && route_lane[0] && old_value[0] == 3 && wanted[0] == 1;
            reach[2] = count8(claimed) == 2;
            reach[3] = expected.pending_created_events == 1 && overflow_lane == 2 && index[0] == index[1];
            reach[4] = overflow_lane[0] && active_mask[index[0]];
            reach[5] = done_mask[0] && actual.pending_route_q[1:0] == 3;
            reach[6] = invalid_completion[0] && active_mask[0] && state_q[1:0] == 1;
            reach[7] = invalid_completion[0] && !active_mask[0] && expected.pending_completion_from_zero_valid;
            reach[8] = !tick_enable && active_mask != 0 && expected.pending_retained_events == 0;
            reach[9] = tick_enable && request_accept == 3 && request_neutralized == 0;
            reach[10] = bad_relation[0] && wanted[0] == 2;
            reach[11] = bad_relation[0] && wanted[0] == 1 && old_value[0] == 1;
            reach[12] = count8(done_mask) == 3 && !expected.pending_capacity_valid;
            reach[13] = active_mask == 8'hff;
            reach[14] = !rst_n && count8(claimed) == 2 && actual.pending_route_q == 0;
            reach[15] = done_mask != 0 && claimed != 0;
            reach[16] = count8(done_mask) == 1 && expected.pending_retained_events == 7;
            reach[17] = overflow_lane == 3 && count8(expected.pending_overflow_mask) == 1;
            reach[18] = bad_relation[0] && wanted[0] == 0;
            reach[19] = bad_relation[0] && old_value[0] == 2;
            reach[20] = !tick_enable && request_accept == 3 && request_neutralized == 3;
            reach[21] = count8(active_mask) == 6 && count8(claimed) == 2;
            reach[22] = done_mask == 8'hff && expected.pending_replay_deterministic;
            reach[23] = !tick_enable && pending_completion_accept_mask == 8'hff && active_mask == 8'hff;
        end
    end

    `FRP_M31_RW_CHECK(pending_route_q, 0)
    `FRP_M31_RW_CHECK(pending_route_d, 1)
    `FRP_M31_RW_CHECK(pending_active_mask, 2)
    `FRP_M31_RW_CHECK(pending_created_mask, 3)
    `FRP_M31_RW_CHECK(pending_completed_mask, 4)
    `FRP_M31_RW_CHECK(pending_cleared_mask, 5)
    `FRP_M31_RW_CHECK(pending_retained_mask, 6)
    `FRP_M31_RW_CHECK(pending_blocked_mask, 7)
    `FRP_M31_RW_CHECK(pending_reserved_mask, 8)
    `FRP_M31_RW_CHECK(pending_overflow_mask, 9)
    `FRP_M31_RW_CHECK(pending_active_count, 10)
    `FRP_M31_RW_CHECK(pending_created_events, 11)
    `FRP_M31_RW_CHECK(pending_completed_events, 12)
    `FRP_M31_RW_CHECK(pending_cleared_events, 13)
    `FRP_M31_RW_CHECK(pending_retained_events, 14)
    `FRP_M31_RW_CHECK(pending_reserved_events, 15)
    `FRP_M31_RW_CHECK(neutral_routed_events, 16)
    `FRP_M31_RW_CHECK(prevented_direct_events, 17)
    `FRP_M31_RW_CHECK(queue_overflow_events, 18)
    `FRP_M31_RW_CHECK(actual_direct_events, 19)
    `FRP_M31_RW_CHECK(pending_domain_valid, 20)
    `FRP_M31_RW_CHECK(pending_polarity_valid, 21)
    `FRP_M31_RW_CHECK(pending_completion_from_zero_valid, 22)
    `FRP_M31_RW_CHECK(pending_non_overwrite_valid, 23)
    `FRP_M31_RW_CHECK(pending_capacity_valid, 24)
    `FRP_M31_RW_CHECK(pending_replay_deterministic, 25)
    `FRP_M31_RW_CHECK(no_pending_reserved_state, 26)
    `FRP_M31_RW_CHECK(no_queue_overflow, 27)
    `FRP_M31_RW_CHECK(no_actual_direct_events, 28)
endmodule

module frp_m31_writeback_contract_formal (
    input logic clk,
    input logic rst_n,
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [15:0] state_candidate_d,
    input logic [7:0] capacity_accept_mask,
    input logic [7:0] accepted_change_candidate_mask,
    input logic [7:0] neutral_routed_mask,
    input logic [7:0] pending_completion_mask,
    input logic [7:0] reserved_transition_mask,
    input logic [7:0] actual_direct_mask,
    output wire [408:0] observed_outputs, expected_outputs,
    output logic [25:0] mismatch,
    output logic [23:0] reach
);
    import frp_m31_route_writeback_contract_spec::*;
    typedef struct packed {
        logic [15:0] state_q;
        logic [15:0] state_d;
        logic [15:0] state_out;
        logic [7:0] state_write_enable_mask;
        logic [7:0] state_hold_mask;
        logic [7:0] state_reset_mask;
        logic [7:0] state_reserved_mask;
        logic [31:0] accepted_changes;
        logic [31:0] switch_load_numerator;
        logic [31:0] state_write_events;
        logic [31:0] state_hold_events;
        logic [31:0] state_reset_events;
        logic [31:0] accepted_change_events;
        logic [31:0] neutral_routed_commit_events;
        logic [31:0] pending_completion_commit_events;
        logic [31:0] reserved_state_events;
        logic [31:0] actual_direct_events;
        logic state_domain_valid;
        logic state_output_domain_valid;
        logic state_update_valid;
        logic state_write_capacity_valid;
        logic same_state_hold_valid;
        logic active_neutral_writeback_valid;
        logic pending_completion_writeback_valid;
        logic no_reserved_state_output;
        logic no_actual_direct_events;
    } result_t;
    result_t actual, expected;
    assign observed_outputs = actual;
    assign expected_outputs = expected;
    logic history_valid = 0;
    logic [15:0] reference_q;
    wire ready = history_valid;
    always @(posedge clk) begin
        history_valid <= 1;
        if (!history_valid) begin
            initial_reset: assume(!rst_n);
        end
    end
    // Predict each registered transition from public state and independent D.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) reference_q <= 0;
        else if (tick_enable) reference_q <= expected.state_d;
    end
    always_comb begin
        if (ready) begin
            a_retained_encoding: assert(reserved8(actual.state_q) == 0);
        end
    end
`ifdef FRP_M31_ROUTE_WRITEBACK_CONTRACT_NETLIST
    frp_m31_state_update_netlist dut (
`else
    frp_m31_state_update #(
        .CELLS(8), .STATE_BITS(2), .REQUEST_LANES(2),
        .COUNTER_BITS(32)
    ) dut (
`endif
        .clk(clk),
        .rst_n(rst_n),
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .state_candidate_d(state_candidate_d),
        .capacity_accept_mask(capacity_accept_mask),
        .accepted_change_candidate_mask(accepted_change_candidate_mask),
        .neutral_routed_mask(neutral_routed_mask),
        .pending_completion_mask(pending_completion_mask),
        .reserved_transition_mask(reserved_transition_mask),
        .actual_direct_mask(actual_direct_mask),
        .state_q(actual.state_q),
        .state_d(actual.state_d),
        .state_out(actual.state_out),
        .state_write_enable_mask(actual.state_write_enable_mask),
        .state_hold_mask(actual.state_hold_mask),
        .state_reset_mask(actual.state_reset_mask),
        .state_reserved_mask(actual.state_reserved_mask),
        .accepted_changes(actual.accepted_changes),
        .switch_load_numerator(actual.switch_load_numerator),
        .state_write_events(actual.state_write_events),
        .state_hold_events(actual.state_hold_events),
        .state_reset_events(actual.state_reset_events),
        .accepted_change_events(actual.accepted_change_events),
        .neutral_routed_commit_events(actual.neutral_routed_commit_events),
        .pending_completion_commit_events(actual.pending_completion_commit_events),
        .reserved_state_events(actual.reserved_state_events),
        .actual_direct_events(actual.actual_direct_events),
        .state_domain_valid(actual.state_domain_valid),
        .state_output_domain_valid(actual.state_output_domain_valid),
        .state_update_valid(actual.state_update_valid),
        .state_write_capacity_valid(actual.state_write_capacity_valid),
        .same_state_hold_valid(actual.same_state_hold_valid),
        .active_neutral_writeback_valid(actual.active_neutral_writeback_valid),
        .pending_completion_writeback_valid(actual.pending_completion_writeback_valid),
        .no_reserved_state_output(actual.no_reserved_state_output),
        .no_actual_direct_events(actual.no_actual_direct_events)
    );

    logic [7:0] changed, invalid_mask, direct_metadata, both_routes, same_bad, missing_change;
    logic [7:0] scheduler_legal, bad_neutral, bad_pending, metadata_bad, writes, final_reserved;
    logic commit_phase, neutral_phase;
    logic [1:0] old_value [0:7], wanted [0:7];

    always_comb begin
        expected = '0;
        expected.state_q = reference_q;
        expected.state_out = reference_q;
        expected.state_d = actual.state_q;
        changed = 0;
        direct_metadata = actual_direct_mask;
        scheduler_legal = 8'hff;
        bad_neutral = neutral_routed_mask & pending_completion_mask;
        bad_pending = bad_neutral;
        commit_phase = scheduler_state == 0 || scheduler_state == 2 || scheduler_state == 3;
        neutral_phase = scheduler_state == 0 || scheduler_state == 1 || scheduler_state == 4;
        for (int i = 0; i < 8; i++) begin
            old_value[i] = actual.state_q[2*i +: 2];
            wanted[i] = state_candidate_d[2*i +: 2];
            changed[i] = old_value[i] != wanted[i];
            direct_metadata[i] |= opposite(old_value[i], wanted[i]);
            if (changed[i]) begin
                if (neutral_routed_mask[i]) begin
                    scheduler_legal[i] = neutral_phase;
                    bad_neutral[i] |= !nonzero(old_value[i]) || wanted[i] != 0;
                end else if (pending_completion_mask[i]) begin
                    scheduler_legal[i] = commit_phase;
                    bad_pending[i] |= old_value[i] != 0 || !nonzero(wanted[i]);
                end else if (old_value[i] == 0 && nonzero(wanted[i])) scheduler_legal[i] = commit_phase;
                else if (nonzero(old_value[i]) && wanted[i] == 0) scheduler_legal[i] = neutral_phase;
                else scheduler_legal[i] = 0;
            end
        end
        bad_neutral |= neutral_routed_mask & ~scheduler_legal;
        bad_pending |= pending_completion_mask & ~scheduler_legal;
        invalid_mask = reserved8(actual.state_q) | reserved8(state_candidate_d) | reserved_transition_mask;
        both_routes = neutral_routed_mask & pending_completion_mask;
        same_bad = accepted_change_candidate_mask & ~changed;
        missing_change = changed & ~accepted_change_candidate_mask;
        metadata_bad = direct_metadata | both_routes | same_bad | missing_change | bad_neutral | bad_pending | ~scheduler_legal;
        writes = {8{tick_enable}} & changed & capacity_accept_mask & accepted_change_candidate_mask & ~invalid_mask & ~metadata_bad;
        for (int i = 0; i < 8; i++)
            if (writes[i]) expected.state_d[2*i +: 2] = wanted[i];
        final_reserved = reserved8(expected.state_d);
        expected.state_write_enable_mask = writes;
        expected.state_hold_mask = ~writes;
        expected.state_reserved_mask = invalid_mask | final_reserved;
        expected.accepted_changes = count8(writes);
        expected.switch_load_numerator = expected.accepted_changes;
        expected.state_write_events = expected.accepted_changes;
        expected.state_hold_events = count8(~writes);
        expected.accepted_change_events = expected.accepted_changes;
        expected.neutral_routed_commit_events = count8(writes & neutral_routed_mask);
        expected.pending_completion_commit_events = count8(writes & pending_completion_mask);
        expected.reserved_state_events = count8(invalid_mask);
        expected.state_output_domain_valid = final_reserved == 0;
        expected.state_domain_valid = invalid_mask == 0 && final_reserved == 0;
        expected.state_write_capacity_valid = missing_change == 0 && count8(writes) <= 2;
        expected.same_state_hold_valid = same_bad == 0;
        expected.active_neutral_writeback_valid = bad_neutral == 0;
        expected.pending_completion_writeback_valid = bad_pending == 0;
        expected.no_reserved_state_output = final_reserved == 0;
        expected.no_actual_direct_events = 1;
        expected.state_update_valid = invalid_mask == 0 && metadata_bad == 0 && scheduler_state < 5
            && expected.state_domain_valid && expected.state_write_capacity_valid;
        if (!rst_n) begin
            expected = '0;
            expected.state_q = reference_q;
            expected.state_out = reference_q;
            expected.state_reset_mask = 8'hff;
            expected.state_reset_events = 8;
            expected.state_domain_valid = 1;
            expected.state_output_domain_valid = 1;
            expected.state_update_valid = scheduler_state < 5;
            expected.state_write_capacity_valid = 1;
            expected.same_state_hold_valid = 1;
            expected.active_neutral_writeback_valid = 1;
            expected.pending_completion_writeback_valid = 1;
            expected.no_reserved_state_output = 1;
            expected.no_actual_direct_events = 1;
        end
    end

    always_comb begin
        reach = 0;
        if (ready) begin
            reach[0] = rst_n && !tick_enable && changed != 0 && metadata_bad == 0 && invalid_mask == 0;
            reach[1] = !rst_n && tick_enable && state_candidate_d != 0 && expected.state_reset_events == 8;
            reach[2] = rst_n && writes[0] && old_value[0] == 0 && wanted[0] == 1;
            reach[3] = rst_n && writes[0] && old_value[0] == 0 && wanted[0] == 3;
            reach[4] = rst_n && writes[0] && neutral_routed_mask[0] && old_value[0] == 1;
            reach[5] = rst_n && writes[0] && neutral_routed_mask[0] && old_value[0] == 3;
            reach[6] = rst_n && expected.pending_completion_commit_events == 2;
            reach[7] = rst_n && opposite(old_value[0], wanted[0]) && capacity_accept_mask[0] && tick_enable;
            reach[8] = rst_n && actual_direct_mask[0] && old_value[0] == 0 && wanted[0] == 1 && capacity_accept_mask[0] && tick_enable;
            reach[9] = rst_n && wanted[0] == 2;
            reach[10] = rst_n && reserved_transition_mask[0] && wanted[0] == 1;
            reach[11] = rst_n && both_routes[0];
            reach[12] = rst_n && same_bad[0];
            reach[13] = rst_n && missing_change[0];
            reach[14] = rst_n && tick_enable && capacity_accept_mask == 0 && changed != 0 && metadata_bad == 0 && invalid_mask == 0;
            reach[15] = rst_n && old_value[0] == 0 && wanted[0] == 1 && scheduler_state == 1;
            reach[16] = rst_n && scheduler_state == 7 && changed == 0 && same_bad == 0;
            reach[17] = rst_n && writes == 8'hff;
            reach[18] = rst_n && expected.accepted_changes == 2 && expected.state_update_valid;
            reach[19] = rst_n && expected.state_hold_events == 8 && expected.state_update_valid;
            reach[20] = rst_n && bad_neutral[0] && old_value[0] == 0 && wanted[0] == 1;
            reach[21] = rst_n && bad_pending[0] && old_value[0] == 1 && wanted[0] == 0;
            reach[22] = rst_n && actual.state_out == 16'hffff;
            reach[23] = !rst_n && scheduler_state == 7 && !expected.state_update_valid;
        end
    end

    `FRP_M31_RW_CHECK(state_q, 0)
    `FRP_M31_RW_CHECK(state_d, 1)
    `FRP_M31_RW_CHECK(state_out, 2)
    `FRP_M31_RW_CHECK(state_write_enable_mask, 3)
    `FRP_M31_RW_CHECK(state_hold_mask, 4)
    `FRP_M31_RW_CHECK(state_reset_mask, 5)
    `FRP_M31_RW_CHECK(state_reserved_mask, 6)
    `FRP_M31_RW_CHECK(accepted_changes, 7)
    `FRP_M31_RW_CHECK(switch_load_numerator, 8)
    `FRP_M31_RW_CHECK(state_write_events, 9)
    `FRP_M31_RW_CHECK(state_hold_events, 10)
    `FRP_M31_RW_CHECK(state_reset_events, 11)
    `FRP_M31_RW_CHECK(accepted_change_events, 12)
    `FRP_M31_RW_CHECK(neutral_routed_commit_events, 13)
    `FRP_M31_RW_CHECK(pending_completion_commit_events, 14)
    `FRP_M31_RW_CHECK(reserved_state_events, 15)
    `FRP_M31_RW_CHECK(actual_direct_events, 16)
    `FRP_M31_RW_CHECK(state_domain_valid, 17)
    `FRP_M31_RW_CHECK(state_output_domain_valid, 18)
    `FRP_M31_RW_CHECK(state_update_valid, 19)
    `FRP_M31_RW_CHECK(state_write_capacity_valid, 20)
    `FRP_M31_RW_CHECK(same_state_hold_valid, 21)
    `FRP_M31_RW_CHECK(active_neutral_writeback_valid, 22)
    `FRP_M31_RW_CHECK(pending_completion_writeback_valid, 23)
    `FRP_M31_RW_CHECK(no_reserved_state_output, 24)
    `FRP_M31_RW_CHECK(no_actual_direct_events, 25)
endmodule

`undef FRP_M31_RW_CHECK
`endif

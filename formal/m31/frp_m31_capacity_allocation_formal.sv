// SPDX-License-Identifier: Apache-2.0
// M31 capacity allocation: pending priority, lane ownership, retention,
// active-neutral admission, address boundaries and complete output accounting.
// All input encodings are unrestricted. Capacity equals the configured LANES.
`ifndef FRP_M31_CAPACITY_ALLOCATION_FORMAL_SV
`define FRP_M31_CAPACITY_ALLOCATION_FORMAL_SV
`include "frp_m31_capacity_guard.sv"

`define FRP_M31_CA_CHECK(FIELD, BIT) \
    always_comb begin \
        mismatch[BIT] = actual.FIELD != expected.FIELD; \
        a_``FIELD: assert (!mismatch[BIT]); \
    end

module frp_m31_capacity_allocation_formal #(
    parameter int CELLS = 9,
    parameter int LANES = 3,
    parameter int EXTRA_INDEX_BIT = 0,
    parameter int INDEX_BITS = $clog2(CELLS) + EXTRA_INDEX_BIT
) (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [LANES-1:0] request_accept_candidate,
    input logic [LANES*INDEX_BITS-1:0] request_cell_index,
    input logic [4*LANES-1:0] transition_class,
    input logic [CELLS-1:0] pending_completion_candidate, neutral_routed_candidate,
    input logic [2*CELLS-1:0] state_q, state_candidate_d,
    output logic [23:0] mismatch,
    output logic [31:0] reach
);
    localparam int SLOT_BITS = $clog2(LANES + 1);
    always_comb begin
        a_parameters: assert(CELLS >= 2 && CELLS <= 64 && LANES >= 1 && LANES <= CELLS
            && (EXTRA_INDEX_BIT == 0 || EXTRA_INDEX_BIT == 1)
            && INDEX_BITS == $clog2(CELLS) + EXTRA_INDEX_BIT);
    end
    typedef struct packed {
        logic [LANES-1:0] request_accept_capacity;
        logic [LANES-1:0] request_reject_capacity;
        logic [CELLS-1:0] capacity_accept_mask;
        logic [CELLS-1:0] capacity_reject_mask;
        logic [CELLS-1:0] accepted_change_mask;
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
    frp_m31_capacity_guard #(
        .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES),
        .CELL_INDEX_BITS(INDEX_BITS), .COUNTER_BITS(32)
    ) dut (
        .tick_enable(tick_enable),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .request_accept_candidate(request_accept_candidate),
        .request_cell_index(request_cell_index), .transition_class(transition_class),
        .pending_completion_candidate(pending_completion_candidate),
        .neutral_routed_candidate(neutral_routed_candidate),
        .state_q(state_q), .state_candidate_d(state_candidate_d),
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

    function automatic logic polarized(input logic [1:0] value);
        return value == 2'b01 || value == 2'b11;
    endfunction
    function automatic logic opposite(input logic [1:0] a, b);
        return {a,b} == 4'b0111 || {a,b} == 4'b1101;
    endfunction
    function automatic logic [31:0] count_cells(input logic [CELLS-1:0] bits);
        logic [31:0] total;
        total = 0;
        for (int i = 0; i < CELLS; i++) if (bits[i]) total += 32'd1;
        return total;
    endfunction

    logic [CELLS-1:0] eligible, selected, pending_reject, bad_pending, direct_mask;
    logic [SLOT_BITS-1:0] rank [0:CELLS];
    logic [INDEX_BITS-1:0] index [LANES];
    logic [1:0] retained [LANES], proposed [LANES];
    logic [3:0] kind [LANES];
    logic [LANES-1:0] active, in_range, blocked, raw_direct, legal_route;
    logic [LANES-1:0] lane_candidate, lane_change, bad_general, bad_neutral, bad_same;
    logic [LANES-1:0] raw_pending, neutral_marker;
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
        active = request_accept_candidate & {LANES{tick_enable}};
        // Bounded prefix ranks select the lowest eligible pending cells.
        rank[0] = '0;
        for (int cell_id = 0; cell_id < CELLS; cell_id++) begin
            eligible[cell_id] = tick_enable && pending_completion_candidate[cell_id]
                && state_q[2*cell_id +: 2] == 0
                && polarized(state_candidate_d[2*cell_id +: 2]);
            selected[cell_id] = eligible[cell_id] && int'(rank[cell_id]) < LANES;
            rank[cell_id+1] = rank[cell_id] + SLOT_BITS'(selected[cell_id]);
        end
        pending_reject = ({CELLS{tick_enable}} & pending_completion_candidate) & ~selected;
        bad_pending = ({CELLS{tick_enable}} & pending_completion_candidate) & ~eligible;
        expected.capacity_accept_mask = selected;
        expected.accepted_change_mask = selected;
        expected.capacity_reject_mask = pending_reject;
        expected.capacity_candidate_events = count_cells(eligible);
        expected.capacity_reject_events = count_cells(pending_reject);
        used = int'(rank[CELLS]);
        for (int lane = 0; lane < LANES; lane++) begin
            index[lane] = request_cell_index[INDEX_BITS*lane +: INDEX_BITS];
            in_range[lane] = int'(index[lane]) < CELLS;
            kind[lane] = transition_class[4*lane +: 4];
            retained[lane] = 0;
            proposed[lane] = 0;
            raw_pending[lane] = 0;
            neutral_marker[lane] = 0;
            blocked[lane] = 0;
            if (in_range[lane]) begin
                retained[lane] = state_q[2*int'(index[lane]) +: 2];
                proposed[lane] = state_candidate_d[2*int'(index[lane]) +: 2];
                raw_pending[lane] = pending_completion_candidate[index[lane]];
                neutral_marker[lane] = neutral_routed_candidate[index[lane]];
                blocked[lane] = raw_pending[lane] || selected[index[lane]];
            end
            for (int prior = 0; prior < lane; prior++)
                blocked[lane] |= expected.request_accept_capacity[prior]
                    && index[prior] == index[lane];
            raw_direct[lane] = opposite(retained[lane], proposed[lane]);
            if (in_range[lane] && raw_direct[lane]) direct_mask[index[lane]] = 1;
            legal_route[lane] = neutral_marker[lane]
                && polarized(retained[lane]) && proposed[lane] == 0;
            if (active[lane]) begin
                bad_general[lane] = !in_range[lane];
                if (in_range[lane] && !blocked[lane]) begin
                    bad_general[lane] = retained[lane] == 2'b10 || proposed[lane] == 2'b10
                        || kind[lane] > 3 || raw_direct[lane];
                    if (!bad_general[lane]) begin
                        if (kind[lane] == 3) begin
                            lane_candidate[lane] = 1;
                            bad_neutral[lane] = !legal_route[lane];
                        end else begin
                            bad_same[lane] = (kind[lane] == 0) != (retained[lane] == proposed[lane]);
                            lane_candidate[lane] = !bad_same[lane] && kind[lane] != 0;
                        end
                        expected.request_accept_capacity[lane] = !bad_neutral[lane]
                            && !bad_same[lane] && (!lane_candidate[lane] || used < LANES);
                    end
                end
                expected.request_reject_capacity[lane] = !expected.request_accept_capacity[lane];
            end
            lane_change[lane] = expected.request_accept_capacity[lane] && lane_candidate[lane];
            if (lane_change[lane]) used += 32'd1;
            if (lane_candidate[lane]) expected.capacity_candidate_events += 32'd1;
            if (expected.request_reject_capacity[lane]) expected.capacity_reject_events += 32'd1;
        end
        // Cell masks are reductions of pending decisions and lane decisions.
        for (int cell_id = 0; cell_id < CELLS; cell_id++)
            for (int lane = 0; lane < LANES; lane++)
                if (int'(index[lane]) == cell_id) begin
                    expected.capacity_accept_mask[cell_id] |= expected.request_accept_capacity[lane];
                    expected.capacity_reject_mask[cell_id] |= expected.request_reject_capacity[lane];
                    expected.accepted_change_mask[cell_id] |= lane_change[lane];
                end
        expected.accepted_changes = used;
        expected.capacity_remaining = LANES - used;
        expected.capacity_exhausted = used == LANES;
        expected.switch_load_numerator = used;
        expected.capacity_accept_events = used;
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

    // Reach bits are SAT witness targets. Address witnesses 24/25 need spare codes;
    // 6/22/28/30 need multiple lanes; 3/18 need CELLS > LANES.
    always_comb begin
        reach = 0;
        reach[0] = !tick_enable && (&request_accept_candidate) && (&pending_completion_candidate);
        reach[1] = (&eligible) && actual.accepted_changes == LANES;
        reach[2] = count_cells(eligible) == 1 && actual.accepted_changes == 1;
        reach[3] = count_cells(selected) == LANES && actual.request_accept_capacity[0] && kind[0] == 0;
        reach[4] = (&actual.request_accept_capacity) && actual.accepted_changes == 0;
        reach[5] = (&actual.request_accept_capacity) && actual.accepted_changes == LANES;
        if (LANES >= 2) begin
            reach[6] = actual.request_accept_capacity[0] && actual.request_reject_capacity[LANES-1]
                && index[0] == index[LANES-1];
            reach[22] = actual.request_reject_capacity[0] && actual.request_accept_capacity[LANES-1]
                && index[0] == index[LANES-1];
            reach[30] = actual.request_reject_capacity[LANES-1] && !raw_pending[LANES-1]
                && kind[LANES-1] == 15 && actual.transition_capacity_valid;
        end
        reach[7] = active[0] && in_range[0] && raw_pending[0] && !actual.pending_capacity_valid;
        reach[8] = bad_general[0] && in_range[0] && retained[0] == 2'b10;
        reach[9] = bad_general[0] && in_range[0] && proposed[0] == 2'b10;
        reach[10] = bad_general[0] && in_range[0] && kind[0] == 15;
        reach[11] = bad_general[0] && raw_direct[0] && retained[0] == 2'b01;
        reach[12] = bad_general[0] && raw_direct[0] && retained[0] == 2'b11;
        reach[13] = actual.request_accept_capacity[0] && kind[0] == 3 && retained[0] == 2'b01;
        reach[14] = actual.request_accept_capacity[0] && kind[0] == 3 && retained[0] == 2'b11;
        reach[15] = bad_neutral[0] && !neutral_marker[0];
        reach[16] = bad_same[0] && kind[0] == 0;
        reach[17] = bad_same[0] && kind[0] == 1;
        reach[18] = lane_candidate[0] && !bad_neutral[0] && actual.request_reject_capacity[0]
            && count_cells(selected) == LANES;
        reach[19] = actual.request_accept_capacity[0] && scheduler_state == 7;
        reach[20] = actual.request_accept_capacity[0] && kind[0] == 0 && neutral_marker[0];
        reach[21] = eligible == 0 && actual.capacity_candidate_events == 0 && bad_pending != 0;
        reach[23] = count_cells(eligible) == CELLS-1 && lane_candidate[0]
            && actual.capacity_candidate_events == CELLS;
        reach[24] = active[0] && !in_range[0] && actual.capacity_reject_mask == 0;
        reach[25] = !tick_enable && !in_range[0] && actual.transition_capacity_valid;
        reach[26] = selected[CELLS-1] && count_cells(eligible) == LANES;
        reach[27] = actual.request_accept_capacity[0] && int'(index[0]) == CELLS-1;
        reach[28] = actual.capacity_candidate_events > CELLS;
        reach[29] = actual.capacity_reject_events == CELLS + LANES;
        reach[31] = active[0] && raw_pending[0] && kind[0] == 15 && actual.transition_capacity_valid;
    end

    `FRP_M31_CA_CHECK(request_accept_capacity, 0)
    `FRP_M31_CA_CHECK(request_reject_capacity, 1)
    `FRP_M31_CA_CHECK(capacity_accept_mask, 2)
    `FRP_M31_CA_CHECK(capacity_reject_mask, 3)
    `FRP_M31_CA_CHECK(accepted_change_mask, 4)
    `FRP_M31_CA_CHECK(accepted_changes, 5)
    `FRP_M31_CA_CHECK(capacity_remaining, 6)
    `FRP_M31_CA_CHECK(capacity_exhausted, 7)
    `FRP_M31_CA_CHECK(switch_load_numerator, 8)
    `FRP_M31_CA_CHECK(capacity_candidate_events, 9)
    `FRP_M31_CA_CHECK(capacity_accept_events, 10)
    `FRP_M31_CA_CHECK(capacity_reject_events, 11)
    `FRP_M31_CA_CHECK(capacity_exhausted_events, 12)
    `FRP_M31_CA_CHECK(accepted_change_events, 13)
    `FRP_M31_CA_CHECK(transition_capacity_valid, 14)
    `FRP_M31_CA_CHECK(accepted_changes_within_limit, 15)
    `FRP_M31_CA_CHECK(capacity_remaining_valid, 16)
    `FRP_M31_CA_CHECK(capacity_exhaustion_valid, 17)
    `FRP_M31_CA_CHECK(same_state_capacity_valid, 18)
    `FRP_M31_CA_CHECK(pending_capacity_valid, 19)
    `FRP_M31_CA_CHECK(active_neutral_capacity_valid, 20)
    `FRP_M31_CA_CHECK(switch_load_bound_valid, 21)
    `FRP_M31_CA_CHECK(no_queue_overflow, 22)
    `FRP_M31_CA_CHECK(no_actual_direct_events, 23)
endmodule
`undef FRP_M31_CA_CHECK
`endif

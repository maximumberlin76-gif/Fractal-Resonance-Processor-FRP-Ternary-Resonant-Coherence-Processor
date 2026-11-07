// SPDX-License-Identifier: Apache-2.0
// One combinational tick before capacity selection. Pending storage is external.
`ifndef FRP_M31_ACTIVE_NEUTRAL_ROUTING_FORMAL_SV
`define FRP_M31_ACTIVE_NEUTRAL_ROUTING_FORMAL_SV
`include "frp_m31_active_neutral.sv"

module frp_m31_active_neutral_routing_formal #(
    parameter int CELLS = 9, LANES = 3, EXTRA_INDEX_BIT = 0,
    parameter int INDEX_BITS = $clog2(CELLS) + EXTRA_INDEX_BIT
) (
    input logic tick_enable,
    input logic [2:0] scheduler_state,
    input logic [2*CELLS-1:0] state_q, pending_route_q,
    input logic [LANES-1:0] request_accept, request_neutralized,
    input logic [INDEX_BITS*LANES-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [CELLS-1:0] pending_completion_enable,
    output logic [28:0] mismatch,
    output logic [19:0] reach
);
    // Mask order: valid, hold, release, neutralize, opposite, routed,
    // completed, actual direct, reserved, changed.
    logic [2*CELLS-1:0] candidate, ref_candidate;
    logic [CELLS-1:0] mask [10], ref_mask [10];
    logic [31:0] count [10], ref_count [10];
    logic [7:0] flag, ref_flag;
    frp_m31_active_neutral #(
        .CELLS(CELLS), .REQUEST_LANES(LANES), .STATE_BITS(2),
        .CELL_INDEX_BITS(INDEX_BITS), .COUNTER_BITS(32)
    ) dut (
        .tick_enable, .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .state_q, .pending_route_q, .request_accept, .request_neutralized,
        .request_cell_index, .request_target, .pending_completion_enable,
        .state_candidate_d(candidate), .transition_valid_mask(mask[0]),
        .same_state_mask(mask[1]), .zero_to_nonzero_mask(mask[2]),
        .nonzero_to_zero_mask(mask[3]), .opposite_polarity_mask(mask[4]),
        .neutral_routed_mask(mask[5]), .pending_completion_mask(mask[6]),
        .actual_direct_mask(mask[7]), .reserved_transition_mask(mask[8]),
        .accepted_change_candidate_mask(mask[9]), .same_state_events(count[0]),
        .zero_to_nonzero_events(count[1]), .nonzero_to_zero_events(count[2]),
        .requested_direct_events(count[3]), .prevented_direct_events(count[4]),
        .neutral_routed_events(count[5]), .pending_completion_events(count[6]),
        .actual_direct_events(count[7]), .reserved_transition_events(count[8]),
        .accepted_change_candidate_events(count[9]), .transition_domain_valid(flag[0]),
        .active_neutral_routing_valid(flag[1]), .pending_completion_from_zero_valid(flag[2]),
        .no_reserved_transition(flag[3]), .no_actual_direct_events(flag[4]),
        .transition_capacity_valid(flag[5]), .state_output_domain_valid(flag[6]),
        .transition_replay_deterministic(flag[7])
    );

    wire commit_ok = scheduler_state == 0 || scheduler_state == 2 || scheduler_state == 3;
    wire neutral_ok = scheduler_state == 0 || scheduler_state == 1 || scheduler_state == 4;
    logic [CELLS-1:0] start_bad, state_bad, done, bad_completion, bad_operand;
    for (genvar c = 0; c < CELLS; c++) begin : g_pending
        wire [1:0] s = state_q[2*c+:2], p = pending_route_q[2*c+:2];
        wire attempt = tick_enable && pending_completion_enable[c];
        assign state_bad[c] = s == 2'b10;
        assign start_bad[c] = state_bad[c] || p == 2'b10;
        assign bad_operand[c] = attempt && (state_bad[c] || !p[0]);
        assign done[c] = attempt && s == 0 && p[0] && commit_ok;
        assign bad_completion[c] = attempt && !done[c];
    end

    logic [LANES-1:0] invalid_addr, invalid_data, conflict, hold_lane, up_lane,
        down_lane, opposite_lane, route_lane, change_lane;
    logic [INDEX_BITS-1:0] addr [LANES];
    logic [1:0] target [LANES];
    for (genvar l = 0; l < LANES; l++) begin : g_lane
        assign addr[l] = request_cell_index[l*INDEX_BITS+:INDEX_BITS];
        assign target[l] = request_target[2*l+:2];
        wire in_range = int'(addr[l]) < CELLS;
        wire [1:0] s = in_range ? state_q[2*int'(addr[l])+:2] : 2'b00;
        wire active = tick_enable && request_accept[l];
        assign invalid_addr[l] = active && !in_range;
        assign invalid_data[l] = active && in_range && (s == 2'b10 || target[l] == 2'b10);
        assign conflict[l] = active && in_range && !invalid_data[l] && done[addr[l]];
        wire admit = active && in_range && !invalid_data[l] && !conflict[l];
        assign hold_lane[l] = admit && s == target[l];
        assign up_lane[l] = admit && s == 0 && target[l][0] && commit_ok;
        assign down_lane[l] = admit && s[0] && target[l] == 0 && neutral_ok;
        assign opposite_lane[l] = admit && s[0] && target[l][0] && s != target[l];
        assign route_lane[l] = opposite_lane[l] && neutral_ok && request_neutralized[l];
        assign change_lane[l] = up_lane[l] || down_lane[l] || route_lane[l];
    end

    // Per-cell reference: holds do not overwrite an earlier changing lane;
    // among changing lanes the highest numbered lane supplies the candidate.
    logic [CELLS-1:0] duplicate_change;
    for (genvar c = 0; c < CELLS; c++) begin : g_cell
        logic [LANES-1:0] hit;
        for (genvar l = 0; l < LANES; l++)
            assign hit[l] = int'(addr[l]) == c;
        assign ref_mask[1][c] = |(hit & hold_lane);
        assign ref_mask[2][c] = done[c] || |(hit & up_lane);
        assign ref_mask[3][c] = |(hit & (down_lane | route_lane));
        assign ref_mask[4][c] = |(hit & route_lane);
        assign ref_mask[5][c] = ref_mask[4][c];
        assign ref_mask[6][c] = done[c];
        assign ref_mask[7][c] = 0;
        assign ref_mask[8][c] = start_bad[c] || bad_operand[c] || |(hit & invalid_data);
        assign ref_mask[9][c] = ref_mask[2][c] || ref_mask[3][c];
        assign ref_mask[0][c] = ref_mask[1][c] || ref_mask[9][c];
        assign duplicate_change[c] = $countones(hit & change_lane) > 1;
        always_comb begin
            ref_candidate[2*c+:2] = done[c] ? pending_route_q[2*c+:2] : state_q[2*c+:2];
            for (int l = 0; l < LANES; l++)
                if (hit[l] && change_lane[l])
                    ref_candidate[2*c+:2] = up_lane[l] ? target[l] : 2'b00;
        end
        // Check the executed leg directly on the public candidate.
        always_comb assert (!(state_q[2*c] && candidate[2*c]
            && candidate[2*c+1] != state_q[2*c+1]));
    end

    assign ref_count[0] = $countones(hold_lane);
    assign ref_count[1] = $countones(done) + $countones(up_lane);
    assign ref_count[2] = $countones(down_lane | route_lane);
    assign ref_count[3] = $countones(opposite_lane);
    assign ref_count[4] = $countones(route_lane);
    assign ref_count[5] = ref_count[4];
    assign ref_count[6] = $countones(done);
    assign ref_count[7] = 0;
    // Malformed pending attempts can set a mask without adding an event.
    assign ref_count[8] = $countones(start_bad) + $countones(invalid_data);
    assign ref_count[9] = $countones(done) + $countones(change_lane);
    assign ref_flag[0] = !(|ref_mask[8]) && !(|invalid_addr);
    assign ref_flag[1] = opposite_lane == route_lane;
    assign ref_flag[2] = !(|bad_completion);
    assign ref_flag[3] = ref_flag[0];
    assign ref_flag[4] = 1;
    assign ref_flag[5] = !(|duplicate_change);
    assign ref_flag[6] = !(|state_bad);
    assign ref_flag[7] = scheduler_state < 5 && ref_flag[0] && ref_flag[1]
        && ref_flag[2] && !(|conflict);

    assign mismatch[0] = candidate != ref_candidate;
    for (genvar i = 0; i < 10; i++) begin : g_compare
        assign mismatch[1+i] = mask[i] != ref_mask[i];
        assign mismatch[11+i] = count[i] != ref_count[i];
    end
    assign mismatch[28:21] = flag ^ ref_flag;
    always_comb begin
        a_parameters: assert (CELLS >= 2 && CELLS <= 64 && LANES >= 1 && LANES <= CELLS
            && (EXTRA_INDEX_BIT == 0 || EXTRA_INDEX_BIT == 1)
            && INDEX_BITS == $clog2(CELLS) + EXTRA_INDEX_BIT);
        a_outputs: assert (mismatch == 0);
    end

    // Witness 16 needs spare address codes; 17 and 18 need multiple lanes.
    wire [1:0] s0 = state_q[1:0], p0 = pending_route_q[1:0];
    assign reach[0] = !tick_enable && (&request_accept) && (&pending_completion_enable);
    assign reach[1] = s0 == 2'b01 && mask[5][0] && candidate[1:0] == 0;
    assign reach[2] = s0 == 2'b11 && mask[5][0] && candidate[1:0] == 0;
    assign reach[3] = p0 == 2'b01 && mask[6][0] && candidate[1:0] == p0;
    assign reach[4] = p0 == 2'b11 && mask[6][0] && candidate[1:0] == p0;
    assign reach[5] = mask[1][0] && s0 == 0 && !mask[9][0];
    assign reach[6] = mask[2][0] && !mask[6][0] && s0 == 0;
    assign reach[7] = mask[3][0] && !mask[5][0] && s0[0];
    assign reach[8] = opposite_lane[0] && !request_neutralized[0] && neutral_ok && !flag[1];
    assign reach[9] = opposite_lane[0] && request_neutralized[0] && !neutral_ok && !flag[1];
    assign reach[10] = conflict[0] && mask[6][0] && addr[0] == 0 && !flag[7];
    assign reach[11] = s0 == 0 && p0[0] && bad_completion[0] && !commit_ok;
    assign reach[12] = s0[0] && p0[0] && bad_completion[0] && commit_ok;
    assign reach[13] = s0 == 0 && p0 == 0 && bad_operand[0] && count[8] == 0;
    assign reach[14] = !tick_enable && s0 == 2'b10 && !flag[6];
    assign reach[15] = invalid_data[0] && target[0] == 2'b10 && count[8] != 0;
    assign reach[16] = invalid_addr[0] && mask[8] == 0 && !flag[0];
    assign reach[17] = duplicate_change[0] && !flag[5];
    assign reach[18] = mask[1][0] && mask[9][0] && flag[5];
    assign reach[19] = scheduler_state == 7 && mask[1][CELLS-1] && !flag[7];
endmodule
`endif

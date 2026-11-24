// SPDX-License-Identifier: Apache-2.0
// Per-cycle diagnostics of M31 writeback. Inputs and retained state are unrestricted.
// The lane-limit comparison uses the public accepted_changes count (32 bits).
`timescale 1ns/1ps
`include "frp_m31_state_update.sv"

module frp_m31_writeback_diagnostic_matrix_formal #(
    parameter int CELLS = 8,
    parameter int LANES = 2
) (
    input logic clk, rst_n, tick_enable,
    input logic [2:0] scheduler_code,
    input logic [2*CELLS-1:0] candidate,
    input logic [CELLS-1:0] capacity, accepted, neutral_route, completion,
    input logic [CELLS-1:0] reserved_fault, direct_fault,
    output logic [13:0] reach
);
    localparam int LAST = CELLS - 1;
    localparam logic [CELLS-1:0] LAST_MASK = {1'b1, {(CELLS-1){1'b0}}};
    wire [2*CELLS-1:0] stored, preview;
    wire [CELLS-1:0] writes;
    wire [31:0] changes;
    wire domain_ok, output_ok, update_ok, capacity_ok, hold_ok;
    wire neutral_ok, completion_ok, no_reserved, no_direct;

    frp_m31_state_update #(
        .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES), .COUNTER_BITS(32)
    ) dut (
        .clk, .rst_n, .tick_enable,
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_code)),
        .state_candidate_d(candidate), .capacity_accept_mask(capacity),
        .accepted_change_candidate_mask(accepted), .neutral_routed_mask(neutral_route),
        .pending_completion_mask(completion), .reserved_transition_mask(reserved_fault),
        .actual_direct_mask(direct_fault), .state_q(stored), .state_d(preview),
        .state_write_enable_mask(writes), .accepted_changes(changes),
        .state_domain_valid(domain_ok), .state_output_domain_valid(output_ok),
        .state_update_valid(update_ok), .state_write_capacity_valid(capacity_ok),
        .same_state_hold_valid(hold_ok), .active_neutral_writeback_valid(neutral_ok),
        .pending_completion_writeback_valid(completion_ok),
        .no_reserved_state_output(no_reserved), .no_actual_direct_events(no_direct)
    );

    wire may_enter = scheduler_code == 0 || scheduler_code == 1 || scheduler_code == 4;
    wire may_leave = scheduler_code == 0 || scheduler_code == 2 || scheduler_code == 3;
    wire [CELLS-1:0] changed, invalid_input, invalid_output, direct_output;
    wire [CELLS-1:0] bad_neutral, bad_completion, opposite, bad_untagged;
    for (genvar i = 0; i < CELLS; i++) begin : g_cell
        wire [1:0] q = stored[2*i +: 2];
        wire [1:0] target = candidate[2*i +: 2];
        wire [1:0] d = preview[2*i +: 2];
        wire enter = q[0] && target == 0 && may_enter;
        wire leave = q == 0 && target[0] && may_leave;
        wire dual = neutral_route[i] && completion[i];
        assign changed[i] = q != target;
        assign invalid_input[i] = q == 2'b10 || target == 2'b10 || reserved_fault[i];
        assign invalid_output[i] = d == 2'b10;
        assign direct_output[i] = q[0] && d[0] && d != q;
        assign opposite[i] = q[0] && target[0] && target != q;
        assign bad_neutral[i] = dual || (changed[i] && neutral_route[i] && !enter);
        assign bad_completion[i] = dual || (changed[i] && completion[i] && !leave);
        assign bad_untagged[i] = changed[i] && !neutral_route[i] && !completion[i]
                                 && !(enter || leave);
    end

    wire want_output = invalid_output == '0;
    wire want_domain = want_output && (!rst_n || invalid_input == '0);
    wire want_hold = !rst_n || (accepted & ~changed) == '0;
    wire want_capacity = changes <= LANES && (writes & ~(capacity & accepted)) == '0
                         && (!rst_n || (changed & ~accepted) == '0);
    wire want_neutral = !rst_n || bad_neutral == '0;
    wire want_completion = !rst_n || bad_completion == '0;
    wire [CELLS-1:0] other_fault = direct_fault | opposite | bad_untagged;
    wire want_update = scheduler_code <= 4 && want_domain && want_hold && want_capacity
                       && want_neutral && want_completion && direct_output == '0
                       && (!rst_n || other_fault == '0);

    always_comb begin
        a_domain:     assert (domain_ok == want_domain);
        a_output:     assert (output_ok == want_output);
        a_reserved:   assert (no_reserved == want_output);
        a_direct:     assert (no_direct == (direct_output == '0));
        a_hold:       assert (hold_ok == want_hold);
        a_capacity:   assert (capacity_ok == want_capacity);
        a_neutral:    assert (neutral_ok == want_neutral);
        a_completion: assert (completion_ok == want_completion);
        a_update:     assert (update_ok == want_update);
    end

    // Diagnostic signatures in order: domain, hold, capacity, neutral, completion.
    wire [4:0] flags = {domain_ok, hold_ok, capacity_ok, neutral_ok, completion_ok};
    wire live = rst_n && tick_enable && scheduler_code <= 4;
    wire clean = other_fault == '0;
    wire release_last = stored[2*LAST +: 2] == 0 && candidate[2*LAST];
    always_comb begin
        reach[0] = live && update_ok && changes == LANES;
        reach[1] = live && clean && accepted == changed && (writes & ~capacity) == '0
                   && changes == LANES + 1 && flags == 5'b11011 && !update_ok;
        reach[2] = live && release_last && may_leave && accepted[LAST] && !capacity[LAST]
                   && !writes[LAST] && changes == 0 && update_ok;
        reach[3] = rst_n && !tick_enable && scheduler_code == 0 && clean
                   && (changed & ~accepted) == LAST_MASK && flags == 5'b11011 && !update_ok;
        reach[4] = live && clean && (accepted & ~changed) == LAST_MASK
                   && flags == 5'b10111 && !update_ok;
        reach[5] = live && clean && reserved_fault == LAST_MASK && invalid_input == LAST_MASK
                   && flags == 5'b01111 && !update_ok;
        reach[6] = live && clean && release_last && neutral_route[LAST] && !completion[LAST]
                   && flags == 5'b11101 && !update_ok;
        reach[7] = live && clean && stored[2*LAST] && candidate[2*LAST +: 2] == 0
                   && completion[LAST] && !neutral_route[LAST] && flags == 5'b11110 && !update_ok;
        reach[8] = live && clean && (neutral_route & completion) == LAST_MASK
                   && flags == 5'b11100 && !update_ok;
        reach[9] = live && direct_fault == LAST_MASK && opposite == '0 && bad_untagged == '0
                   && flags == 5'b11111 && !update_ok && no_direct;
        reach[10] = live && direct_fault == '0 && opposite == LAST_MASK
                    && other_fault == LAST_MASK && flags == 5'b11111 && !update_ok && no_direct;
        reach[11] = live && release_last && !may_leave && direct_fault == '0 && opposite == '0
                    && bad_untagged == LAST_MASK && flags == 5'b11111 && !update_ok;
        reach[12] = !rst_n && scheduler_code >= 5 && flags == 5'b11111 && !update_ok;
        reach[13] = live && candidate[1:0] == 2'b10 && release_last && neutral_route[LAST]
                    && !completion[LAST] && writes[CELLS/2] && flags == 5'b01101 && !update_ok;
    end
    for (genvar c = 0; c < 14; c++) begin : g_cover
        always_comb c_reach: cover (reach[c]);
    end
endmodule

// SPDX-License-Identifier: Apache-2.0
// Observe one address of the full pending-route bank. All lanes and all
// completion grants remain independent, including collisions and invalid codes.
`include "frp_m31_pending_routes.sv"

module frp_m31_pending_cell_lifecycle_formal #(
    parameter int CELLS = 64,
    parameter int PROBE = CELLS - 1,
    localparam int LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
    localparam int IW = $clog2(CELLS)
) (
    input logic clk, rst_n, tick_enable,
    input logic [2*CELLS-1:0] state_q,
    input logic [LANES-1:0] request_accept, request_neutralized,
    input logic [IW*LANES-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [CELLS-1:0] completion_grant,
    output logic [7:0] reach
);
    wire [2*CELLS-1:0] bank, candidate;
    wire [CELLS-1:0] active, created, completed, cleared, held, blocked, overflow;
    frp_m31_pending_routes #(.CELLS(CELLS), .REQUEST_LANES(LANES),
        .CELL_INDEX_BITS(IW), .COUNTER_BITS(32)) dut (
        .clk, .rst_n, .tick_enable, .state_q, .request_accept, .request_neutralized,
        .request_cell_index, .request_target,
        .pending_completion_accept_mask(completion_grant),
        .pending_route_q(bank), .pending_route_d(candidate),
        .pending_active_mask(active), .pending_created_mask(created),
        .pending_completed_mask(completed), .pending_cleared_mask(cleared),
        .pending_retained_mask(held), .pending_blocked_mask(blocked),
        .pending_overflow_mask(overflow)
    );

    wire [1:0] state_now = state_q[2*PROBE+:2];
    wire [1:0] saved = bank[2*PROBE+:2];
    wire [1:0] opposite = state_now ^ 2'b10;
    wire [LANES-1:0] eligible;
    for (genvar l=0; l<LANES; l++) begin : lane
        assign eligible[l] = tick_enable && request_accept[l] && request_neutralized[l] &&
            request_cell_index[l*IW+:IW] == IW'(PROBE) && state_now[0] &&
            request_target[2*l+:2] == opposite;
    end

    wire any_hit = |eligible;
    wire duplicate = |(eligible & (eligible - 1'b1));
    wire take = any_hit && saved == 0;
    wire finish = tick_enable && completion_grant[PROBE] && saved[0] && state_now == 0;
    wire keep = saved[0] && !finish;
    wire collision = any_hit && (saved != 0 || duplicate);
    wire [1:0] predicted = finish ? 2'b00 : take ? opposite : saved;

    logic sampled = 0;
    logic [1:0] expected_q;
    always @(posedge clk) sampled <= 1;
    always_comb if (!sampled) a_initial_reset: assume (!rst_n);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) expected_q <= 0;
        else expected_q <= tick_enable ? predicted : saved;
    end

    always_comb begin
        a_profile: assert ((CELLS inside {8,9,16,32,64}) && PROBE >= 0 && PROBE < CELLS);
        if (sampled) begin
            a_registered: assert (saved == expected_q);
            a_domain: assert (saved != 2'b10);
            a_next: assert (candidate[2*PROBE+:2] == predicted);
            a_active: assert (active[PROBE] == saved[0]);
            a_created: assert (created[PROBE] == take);
            a_completed: assert (completed[PROBE] == finish);
            a_cleared: assert (cleared[PROBE] == finish);
            a_held: assert (held[PROBE] == keep);
            a_collision: assert (overflow[PROBE] == collision);
            a_blocked: assert (blocked[PROBE] == (keep || collision));
        end
    end

    always_comb begin
        reach = '0;
        if (sampled && rst_n) begin
            reach[0] = take && opposite == 2'b01;
            reach[1] = take && opposite == 2'b11;
            reach[2] = take && duplicate && overflow[PROBE];
            reach[3] = keep && any_hit && overflow[PROBE];
            reach[4] = finish && saved == 2'b01;
            reach[5] = finish && saved == 2'b11;
            reach[6] = keep && !tick_enable && completion_grant[PROBE];
            reach[7] = keep && tick_enable && completion_grant[PROBE] && state_now != 0;
        end
    end
endmodule

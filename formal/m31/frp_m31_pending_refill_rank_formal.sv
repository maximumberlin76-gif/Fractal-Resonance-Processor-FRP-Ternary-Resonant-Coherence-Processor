// SPDX-License-Identifier: Apache-2.0
// Pending-route service under continuing requests, sampled after async2sync.
`include "frp_m31_execution_core.sv"

module frp_m31_pending_refill_rank_formal #(
    parameter int CELLS = 9,
    parameter int LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
    parameter int PROBE = CELLS - 1,
    localparam int IW = $clog2(CELLS),
    localparam int CW = $clog2(CELLS + 1)
) (
    input logic clk, rst_n, tick_enable, clear_counters,
    input logic [1:0] scheduler_mode,
    input logic [LANES-1:0] request_valid,
    input logic [IW*LANES-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [2*CELLS-1:0] target_q,
    output logic [7:0] reach
);
    import frp_m31_pkg::*;
    wire [2*CELLS-1:0] state_q, pending_q;
    wire [CELLS-1:0] routed;
    frp_m31_scheduler_state_e phase;

    frp_m31_execution_core #(
        .CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(IW)
    ) dut (
        .clk, .rst_n, .tick_enable, .clear_counters,
        .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
        .request_valid, .request_cell_index, .request_target, .target_q,
        .state_out(state_q), .pending_route_out(pending_q),
        .neutral_routed_cell_mask(routed), .scheduler_state_q(phase)
    );

    // Rank counts pending cells strictly below the selected address.
    typedef logic [CW:0] count_t;
    localparam count_t CAPACITY = count_t'(LANES);
    count_t rank_now, births;
    always_comb begin
        rank_now = '0;
        births = '0;
        for (int i = 0; i < PROBE; i++) begin
            rank_now += count_t'(pending_q[2*i]);
            births += count_t'(routed[i]);
        end
    end

    wire [1:0] saved = pending_q[2*PROBE+:2];
    wire [1:0] retained = state_q[2*PROBE+:2];
    wire service = tick_enable && (phase == FRP_SCHED_FREE ||
        phase == FRP_SCHED_COMMIT || phase == FRP_SCHED_EXCITE);
    wire due = service && rank_now < CAPACITY;
    wire deferred = saved[0] && service && !due;

    // The sampled reset establishes both the RTL and the observer.
    logic sampled = 0;
    always @(posedge clk) sampled <= 1;
    always_comb if (!sampled) a_start: assume (!rst_n);

    logic watched, was_due;
    logic [1:0] old_target;
    count_t expected_rank;
    logic interval_live;
    count_t start_rank;
    count_t refill;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            watched <= 0;
            was_due <= 0;
            old_target <= 0;
            expected_rank <= 0;
            interval_live <= 0;
            start_rank <= 0;
            refill <= 0;
        end else begin
            watched <= saved[0];
            was_due <= due;
            old_target <= saved;
            if (!service)
                expected_rank <= rank_now + births;
            else if (due)
                expected_rank <= births;
            else
                expected_rank <= rank_now - CAPACITY + births;

            if (deferred) begin
                interval_live <= 1;
                start_rank <= rank_now;
                refill <= births;
            end else if (!saved[0] || due) begin
                interval_live <= 0;
                refill <= 0;
            end else if (interval_live) begin
                refill <= refill + births;
            end
        end
    end

    for (genvar i = 0; i < CELLS; i++) begin : g_domain
        wire [1:0] p = pending_q[2*i+:2], s = state_q[2*i+:2];
        always_comb if (sampled && rst_n) begin
            a_symbols: assert (p != 2'b10 && s != 2'b10);
            a_active_zero: assert (p == 0 || s == 0);
        end
    end

    always_comb begin
        a_profile: assert (CELLS >= 2 && CELLS <= 64 &&
            LANES >= 1 && LANES <= CELLS && PROBE >= 0 && PROBE < CELLS);
        if (sampled && rst_n && watched) begin
            a_rank_step: assert (rank_now == expected_rank);
            if (was_due) begin
                a_commit: assert (saved == 0 && retained == old_target);
            end else begin
                a_hold: assert (saved == old_target && retained == 0);
            end
        end
        if (sampled && rst_n && interval_live) begin
            a_start_rank: assert (int'(start_rank) >= LANES && int'(start_rank) <= PROBE);
            a_waiting: assert (saved[0] && retained == 0);
            a_refill_range: assert (refill <= count_t'(PROBE));
            a_balance: assert (int'(rank_now) + LANES ==
                int'(start_rank) + int'(refill));
            if (service && int'(refill) < LANES)
                a_progress: assert (rank_now < start_rank);
            if (service && int'(refill) == LANES)
                a_same_rank: assert (rank_now == start_rank);
        end
    end

    always_comb begin
        reach = '0;
        if (sampled && rst_n) begin
            reach[0] = watched && was_due && retained == 2'b01;
            reach[1] = watched && was_due && retained == 2'b11;
            reach[2] = deferred;
            reach[3] = interval_live && !tick_enable && clear_counters;
            reach[4] = interval_live && service && refill == 0;
            reach[5] = interval_live && service && refill > 0 && int'(refill) < LANES;
            reach[6] = interval_live && service && int'(refill) == LANES;
            reach[7] = interval_live && service && int'(refill) > LANES;
        end
    end
endmodule

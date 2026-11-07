// SPDX-License-Identifier: Apache-2.0
// End-to-end admission and registered writeback at the M31 public boundary.
`ifndef FRP_M31_ROUTE_CAPACITY_BOUNDARY_FORMAL_SV
`define FRP_M31_ROUTE_CAPACITY_BOUNDARY_FORMAL_SV
`include "frp_m31_execution_core.sv"

module frp_m31_route_capacity_boundary_formal #(
    parameter int CELLS = 9, LANES = 3, EXTRA_INDEX_BIT = 0,
    parameter int INDEX_BITS = $clog2(CELLS) + EXTRA_INDEX_BIT
) (
    input logic clk, rst_n, tick_enable, clear_counters,
    input logic [1:0] scheduler_mode,
    input logic [LANES-1:0] request_valid,
    input logic [LANES*INDEX_BITS-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [2*CELLS-1:0] target_q,
    output logic [5:0] mismatch,
    output logic [11:0] reach
);
    wire [2*CELLS-1:0] state_q, pending_q;
    wire [LANES-1:0] accepted, rejected;
    wire [CELLS-1:0] accepted_cell, routed, changed;
    wire [31:0] changes, remaining, load, direct_events, overflow_events;
    wire full;
    frp_m31_pkg::frp_m31_scheduler_state_e phase;
    frp_m31_execution_core #(.CELLS(CELLS), .REQUEST_LANES(LANES),
        .CELL_INDEX_BITS(INDEX_BITS), .STATE_BITS(2), .COUNTER_BITS(32)) dut (
        .clk, .rst_n, .tick_enable, .clear_counters,
        .scheduler_mode(frp_m31_pkg::frp_m31_scheduler_mode_e'(scheduler_mode)),
        .request_valid, .request_cell_index, .request_target, .target_q,
        .scheduler_state_q(phase), .state_out(state_q), .pending_route_out(pending_q),
        .request_accept(accepted), .request_reject(rejected),
        .accepted_cell_mask(accepted_cell), .neutral_routed_cell_mask(routed),
        .accepted_change_mask(changed), .accepted_changes(changes),
        .capacity_remaining(remaining), .capacity_exhausted(full),
        .switch_load_numerator(load), .actual_direct_events(direct_events),
        .queue_overflow_events(overflow_events)
    );

    wire release_ok = phase == 0 || phase == 2 || phase == 3;
    wire neutral_ok = phase == 0 || phase == 1 || phase == 4;
    logic [CELLS-1:0] legal, eligible, served, claimed, explicit_cell, route, change;
    logic [LANES-1:0] take, denied_by_limit;
    logic [2*CELLS-1:0] next_state, next_pending;
    int unsigned used;
    for (genvar c = 0; c < CELLS; c++) begin : g_domain
        wire [1:0] s = state_q[2*c+:2], p = pending_q[2*c+:2];
        assign legal[c] = s != 2'b10 && (p == 0 || (p[0] && s == 0));
        assign eligible[c] = tick_enable && release_ok && s == 0 && p[0];
    end
    always_comb begin
        served = '0; claimed = '0; explicit_cell = '0; route = '0; change = '0;
        take = '0; denied_by_limit = '0; used = 0;
        next_state = state_q;
        next_pending = pending_q;
        // Pending completions receive capacity in ascending cell order.
        for (int c = 0; c < CELLS; c++) begin
            if (eligible[c] && used < LANES) begin
                served[c] = 1;
                change[c] = 1;
                next_state[2*c+:2] = pending_q[2*c+:2];
                next_pending[2*c+:2] = 0;
                used++;
            end
        end
        for (int l = 0; l < LANES; l++) begin
            int unsigned i;
            logic [1:0] s, t;
            i = int'(request_cell_index[l*INDEX_BITS+:INDEX_BITS]);
            t = request_target[2*l+:2];
            s = 0;
            if (tick_enable && request_valid[l] && i < CELLS) begin
                s = state_q[2*i+:2];
                if (!claimed[i] && pending_q[2*i+:2] == 0 && t != 2'b10
                    && s != 2'b10 && phase < 5
                    && (s == t || (s == 0 ? release_ok : neutral_ok))) begin
                    // Arbitration owns the cell even when capacity later refuses it.
                    claimed[i] = 1;
                    if (s == t || used < LANES) begin
                        take[l] = 1;
                        explicit_cell[i] = 1;
                        if (s != t) begin
                            change[i] = 1;
                            used++;
                            if (s[0] && t[0]) begin
                                route[i] = 1;
                                next_state[2*i+:2] = 0;
                                next_pending[2*i+:2] = t;
                            end else next_state[2*i+:2] = t;
                        end
                    end else denied_by_limit[l] = 1;
                end
            end
        end
    end

    // Compare registered outputs on the next sample, including stalled ticks.
    logic checked = 0;
    logic [2*CELLS-1:0] expected_state, expected_pending;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            checked <= 1;
            expected_state <= 0;
            expected_pending <= 0;
        end else begin
            checked <= &legal;
            expected_state <= next_state;
            expected_pending <= next_pending;
        end
    end

    wire domain = &legal;
    wire live = rst_n && domain;
    assign mismatch[0] = checked && state_q != expected_state;
    assign mismatch[1] = checked && pending_q != expected_pending;
    assign mismatch[2] = live && (accepted != take ||
        rejected != ((request_valid & {LANES{tick_enable}}) & ~take));
    assign mismatch[3] = live && (accepted_cell != explicit_cell ||
        routed != route || changed != change);
    assign mismatch[4] = live && (changes != used || remaining != LANES-used ||
        full != (used == LANES) || load != used);
    assign mismatch[5] = (checked && !domain) ||
        (live && (direct_events != 0 || overflow_events != 0));
    always_comb begin
        a_parameters: assert (CELLS >= 2 && CELLS <= 64 && LANES >= 1 && LANES <= CELLS
            && (EXTRA_INDEX_BIT == 0 || EXTRA_INDEX_BIT == 1)
            && INDEX_BITS == $clog2(CELLS) + EXTRA_INDEX_BIT);
        a_boundary: assert (mismatch == 0);
    end

    // Witness runs start from reset. Cell 0 identifies both route directions.
    assign reach[0] = live && routed[0] && state_q[1:0] == 2'b01;
    assign reach[1] = live && routed[0] && state_q[1:0] == 2'b11;
    assign reach[2] = live && served[0] && pending_q[1:0] == 2'b01;
    assign reach[3] = live && served[0] && pending_q[1:0] == 2'b11;
    assign reach[4] = live && (|(eligible & ~served));
    assign reach[5] = live && (|denied_by_limit);
    assign reach[6] = live && full && (|(explicit_cell & ~changed));
    assign reach[7] = live && (|served) && (|route);
    assign reach[8] = live && !tick_enable && pending_q[0] && (|request_valid);
    assign reach[9] = live && served[0] && request_valid[0] &&
        request_cell_index[0+:INDEX_BITS] == 0 && rejected[0];
    assign reach[10] = live && (|routed) && changed[CELLS-1];
    assign reach[11] = live && request_valid[0] && tick_enable &&
        int'(request_cell_index[0+:INDEX_BITS]) >= CELLS && rejected[0];
endmodule
`endif

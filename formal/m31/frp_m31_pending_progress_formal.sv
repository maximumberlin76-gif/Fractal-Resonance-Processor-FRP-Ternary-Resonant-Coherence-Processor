// Copyright (c) 2026 Maksym Marnov. All rights reserved.
// Proprietary. No license is granted by this file.
// Pending-route service contracts for the M31 execution core used by M32.
// Profiles: 8/16/32/64 cells, native request-lane count, 32-bit counters.
// Only the first sampled reset is assumed. Later inputs are unrestricted.
// Service means an enabled tick in FREE, COMMIT or EXCITE state.
// A quiet interval has no valid new request lanes. During that interval,
// at most ceil(CELLS / REQUEST_LANES) service ticks drain every route.
// Pauses and non-service scheduler states do not consume this budget.
// Formal time is sampled rising edges; prepare with async2sync.

`ifndef FRP_M31_PENDING_PROGRESS_FORMAL_SV
`define FRP_M31_PENDING_PROGRESS_FORMAL_SV
`include "frp_m31_execution_core.sv"

module frp_m31_pending_progress_formal #(
    parameter int CELLS = 8,
    localparam int LANES = frp_m31_pkg::frp_calc_request_lanes(CELLS),
    localparam int INDEX_BITS = $clog2(CELLS),
    localparam int COUNT_BITS = $clog2(CELLS + 1),
    localparam int DRAIN_TICKS = (CELLS + LANES - 1) / LANES,
    localparam int BUDGET_BITS = $clog2(DRAIN_TICKS + 1)
) (
    input logic clk, rst_n, tick_enable, clear_counters,
    input logic [1:0] scheduler_mode,
    input logic [LANES-1:0] request_valid,
    input logic [LANES*INDEX_BITS-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [2*CELLS-1:0] target_bank,
    output wire [2*CELLS-1:0] state_out, pending_route_out,
    output logic [COUNT_BITS-1:0] pending_count,
    output logic [BUDGET_BITS-1:0] quiet_budget,
    output logic [15:0] reach
);
    import frp_m31_pkg::*;

    initial begin
        a_supported_size: assert (
            CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64
        );
    end

    wire [2:0] phase;
    wire [1:0] mode_q;
    frp_m31_execution_core #(
        .CELLS(CELLS), .STATE_BITS(2), .REQUEST_LANES(LANES),
        .CELL_INDEX_BITS(INDEX_BITS), .COUNTER_BITS(32)
    ) dut (
        .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
        .clear_counters(clear_counters),
        .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
        .request_valid(request_valid), .request_cell_index(request_cell_index),
        .request_target(request_target), .target_q(target_bank),
        .state_out(state_out), .pending_route_out(pending_route_out),
        .scheduler_state_q(phase), .scheduler_mode_q(mode_q)
    );

    function automatic logic polarized(input logic [1:0] value);
        return value == 2'b01 || value == 2'b11;
    endfunction

    function automatic logic opposite(input logic [1:0] a, b);
        return {a, b} == 4'b0111 || {a, b} == 4'b1101;
    endfunction

    wire service = tick_enable && (phase == 0 || phase == 2 || phase == 3);
    wire quiet = request_valid == '0;
    logic [CELLS-1:0] pending_mask, expected_service;
    logic [COUNT_BITS-1:0] service_count;
    logic [COUNT_BITS-1:0] prefix_count [0:CELLS];

    // Independent ascending-cell selection of the first LANES saved routes.
    always_comb begin
        pending_count = '0;
        service_count = '0;
        prefix_count[0] = '0;
        for (int i = 0; i < CELLS; i++) begin
            pending_mask[i] = polarized(pending_route_out[2*i +: 2]);
            expected_service[i] = service && pending_mask[i]
                && prefix_count[i] < LANES;
            prefix_count[i+1] = prefix_count[i] + COUNT_BITS'(pending_mask[i]);
            pending_count += COUNT_BITS'(pending_mask[i]);
            service_count += COUNT_BITS'(expected_service[i]);
        end
    end

    logic history_valid = 1'b0;
    logic previous_reset, previous_tick, previous_quiet, previous_service;
    logic previous_clear;
    logic [1:0] previous_mode;
    logic [2*CELLS-1:0] previous_state, previous_pending;
    logic [CELLS-1:0] previous_service_mask;
    logic [COUNT_BITS-1:0] previous_count, previous_service_count;
    logic quiet_active = 1'b0;
    logic quiet_started_nonempty = 1'b0;
    wire live = history_valid && previous_reset && rst_n;

    always_comb begin
        if (!history_valid) initial_reset: assume (!rst_n);
    end

    always @(posedge clk) begin
        history_valid <= 1'b1;
        previous_reset <= rst_n;
        previous_tick <= tick_enable;
        previous_quiet <= quiet;
        previous_service <= service;
        previous_clear <= clear_counters;
        previous_mode <= mode_q;
        previous_state <= state_out;
        previous_pending <= pending_route_out;
        previous_service_mask <= expected_service;
        previous_count <= pending_count;
        previous_service_count <= service_count;

        if (!rst_n || !quiet) begin
            quiet_active <= 1'b0;
            quiet_started_nonempty <= 1'b0;
            quiet_budget <= BUDGET_BITS'(DRAIN_TICKS);
        end else begin
            quiet_active <= 1'b1;
            if (!quiet_active)
                quiet_started_nonempty <= pending_count != 0;
            if (!quiet_active)
                quiet_budget <= BUDGET_BITS'(DRAIN_TICKS - (service ? 1 : 0));
            else if (service && quiet_budget != 0)
                quiet_budget <= quiet_budget - 1'b1;
        end
    end

    always_comb begin
        if (history_valid) begin
            if (!rst_n || !previous_reset) begin
                a_reset_state: assert (state_out == '0);
                a_reset_pending: assert (pending_route_out == '0);
            end
            if (live) begin
                if (!previous_tick) begin
                    a_pause_state: assert (state_out == previous_state);
                    a_pause_pending: assert (pending_route_out == previous_pending);
                end
                if (previous_quiet) begin
                    a_exact_drain: assert (
                        pending_count == previous_count - previous_service_count
                    );
                    if (previous_service && previous_count != 0)
                        a_strict_progress: assert (pending_count < previous_count);
                end
                if (quiet_active) begin
                    a_budget_range: assert (quiet_budget <= DRAIN_TICKS);
                    a_remaining_bound: assert (pending_count <= quiet_budget * LANES);
                    if (quiet_budget == 0)
                        a_drained: assert (pending_route_out == '0);
                end
            end
            if (rst_n) begin
                a_service_size: assert (service_count == (
                    service ? ((pending_count < LANES) ? pending_count : LANES) : 0
                ));
            end
        end
    end

    for (genvar i = 0; i < CELLS; i++) begin : cell_contract
        wire [1:0] current = state_out[2*i +: 2];
        wire [1:0] saved = pending_route_out[2*i +: 2];
        wire [1:0] old_state = previous_state[2*i +: 2];
        wire [1:0] old_saved = previous_pending[2*i +: 2];
        always_comb begin
            if (history_valid) begin
                a_state_domain: assert (current != 2'b10);
                a_route_domain: assert (saved != 2'b10);
                a_active_zero: assert (saved == 0 || current == 0);
                if (live) begin
                    a_no_direct: assert (!opposite(old_state, current));
                    if (polarized(old_saved)) begin
                        if (previous_service_mask[i]) begin
                            a_service_clears: assert (saved == 0);
                            a_service_destination: assert (current == old_saved);
                        end else begin
                            a_retained_polarity: assert (saved == old_saved);
                            a_retained_zero: assert (current == 0);
                        end
                    end else if (polarized(saved)) begin
                        a_creation_polarity: assert (opposite(old_state, saved));
                        a_creation_enabled: assert (previous_tick && !previous_quiet);
                    end
                end
            end
        end
    end

    always_comb begin
        reach = '0;
        if (live) begin
            reach[0] = previous_pending[1:0] == 1 && state_out[1:0] == 1
                && pending_route_out[1:0] == 0;
            reach[1] = previous_pending[1:0] == 3 && state_out[1:0] == 3
                && pending_route_out[1:0] == 0;
            reach[2] = previous_pending[2*CELLS-1 -: 2] == 1
                && state_out[2*CELLS-1 -: 2] == 1
                && pending_route_out[2*CELLS-1 -: 2] == 0;
            reach[3] = previous_pending[2*CELLS-1 -: 2] == 3
                && state_out[2*CELLS-1 -: 2] == 3
                && pending_route_out[2*CELLS-1 -: 2] == 0;
            reach[4] = pending_count != 0 && !previous_tick;
            reach[5] = pending_count != 0 && previous_clear;
            reach[6] = previous_count != 0 && previous_service && !previous_quiet;
            reach[7] = previous_count > LANES && previous_service && previous_quiet;
            reach[8] = previous_count != 0 && previous_quiet && pending_count == 0;
            reach[9] = pending_count != 0 && mode_q == 1;
            reach[10] = pending_count != 0 && mode_q == 2;
            reach[11] = pending_count != 0 && mode_q == 3;
            reach[12] = pending_count != 0 && mode_q != previous_mode;
            reach[13] = quiet_active && quiet_started_nonempty
                && quiet_budget == 0 && pending_count == 0;
            reach[14] = previous_count != 0 && previous_quiet && !previous_service;
        end
        reach[15] = history_valid && previous_reset && !rst_n && previous_count != 0;
    end
endmodule
`endif

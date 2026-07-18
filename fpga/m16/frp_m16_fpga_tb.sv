// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 FPGA Integration Testbench
//
// Project:
//   Fractal Resonance Processor (FRP)
//   Ternary Fractal Resonant Coherence Processor
//
// Version:
//   FRP v1.8.0
//
// Layer:
//   FPGA Preparation Layer
//
// Purpose:
//   Verifies asynchronous reset assertion, two-stage synchronous reset
//   release, core_ready input gating, scheduler propagation, request
//   propagation, active-neutral routing, retained pending completion,
//   zero-event counters, and the complete integrated invariant set.

`ifndef FRP_M16_FPGA_TB_SV
`define FRP_M16_FPGA_TB_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"
`include "frp_m16_fpga_top.sv"
`include "frp_m16_assertions.sv"

module frp_m16_fpga_tb;

    import frp_m16_pkg::*;

    localparam int CELLS = 8;
    localparam int STATE_BITS = FRP_M16_STATE_BITS;
    localparam int REQUEST_LANES = frp_calc_request_lanes(CELLS);
    localparam int CELL_INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS);
    localparam int COUNTER_BITS = FRP_M16_COUNTER_BITS;

    logic clk;
    logic rst_n_async;
    logic tick_enable;
    logic clear_counters;
    frp_m16_scheduler_mode_e scheduler_mode;

    logic [REQUEST_LANES-1:0] request_valid;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cell_index;
    logic [(REQUEST_LANES*STATE_BITS)-1:0] request_target;
    logic [(CELLS*STATE_BITS)-1:0] target_q;

    logic core_ready;
    logic [(CELLS*STATE_BITS)-1:0] state_out;
    logic [(CELLS*STATE_BITS)-1:0] pending_route_out;
    frp_m16_scheduler_mode_e scheduler_mode_q;
    frp_m16_scheduler_state_e scheduler_state_q;

    logic [COUNTER_BITS-1:0] ticks_recorded_q;
    logic [COUNTER_BITS-1:0] scheduler_count_free_q;
    logic [COUNTER_BITS-1:0] scheduler_count_balance_q;
    logic [COUNTER_BITS-1:0] scheduler_count_commit_q;
    logic [COUNTER_BITS-1:0] scheduler_count_excite_q;
    logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q;

    logic [REQUEST_LANES-1:0] request_accept;
    logic [REQUEST_LANES-1:0] request_reject;
    logic [CELLS-1:0] accepted_cell_mask;
    logic [CELLS-1:0] neutral_routed_cell_mask;
    logic [CELLS-1:0] accepted_change_mask;

    logic [COUNTER_BITS-1:0] accepted_changes;
    logic [COUNTER_BITS-1:0] capacity_remaining;
    logic capacity_exhausted;
    logic [COUNTER_BITS-1:0] switch_load_numerator;

    logic [COUNTER_BITS-1:0] requested_direct_events;
    logic [COUNTER_BITS-1:0] prevented_direct_events;
    logic [COUNTER_BITS-1:0] neutral_routed_events;
    logic [COUNTER_BITS-1:0] actual_direct_events;
    logic [COUNTER_BITS-1:0] reserved_state_events;
    logic [COUNTER_BITS-1:0] queue_overflow_events;
    logic [FRP_M16_INVARIANT_FLAGS-1:0] invariant_flags;

    logic tick_enable_qualified;
    logic clear_counters_qualified;

    assign tick_enable_qualified = tick_enable && core_ready;
    assign clear_counters_qualified = clear_counters && core_ready;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    frp_m16_fpga_top #(
        .CELLS(CELLS),
        .STATE_BITS(STATE_BITS),
        .REQUEST_LANES(REQUEST_LANES),
        .CELL_INDEX_BITS(CELL_INDEX_BITS),
        .COUNTER_BITS(COUNTER_BITS)
    ) dut (
        .clk(clk),
        .rst_n_async(rst_n_async),
        .tick_enable(tick_enable),
        .clear_counters(clear_counters),
        .scheduler_mode(scheduler_mode),
        .request_valid(request_valid),
        .request_cell_index(request_cell_index),
        .request_target(request_target),
        .target_q(target_q),
        .core_ready(core_ready),
        .state_out(state_out),
        .pending_route_out(pending_route_out),
        .scheduler_mode_q(scheduler_mode_q),
        .scheduler_state_q(scheduler_state_q),
        .ticks_recorded_q(ticks_recorded_q),
        .scheduler_count_free_q(scheduler_count_free_q),
        .scheduler_count_balance_q(scheduler_count_balance_q),
        .scheduler_count_commit_q(scheduler_count_commit_q),
        .scheduler_count_excite_q(scheduler_count_excite_q),
        .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
        .request_accept(request_accept),
        .request_reject(request_reject),
        .accepted_cell_mask(accepted_cell_mask),
        .neutral_routed_cell_mask(neutral_routed_cell_mask),
        .accepted_change_mask(accepted_change_mask),
        .accepted_changes(accepted_changes),
        .capacity_remaining(capacity_remaining),
        .capacity_exhausted(capacity_exhausted),
        .switch_load_numerator(switch_load_numerator),
        .requested_direct_events(requested_direct_events),
        .prevented_direct_events(prevented_direct_events),
        .neutral_routed_events(neutral_routed_events),
        .actual_direct_events(actual_direct_events),
        .reserved_state_events(reserved_state_events),
        .queue_overflow_events(queue_overflow_events),
        .invariant_flags(invariant_flags)
    );

    frp_m16_assertions #(
        .CELLS(CELLS),
        .STATE_BITS(STATE_BITS),
        .REQUEST_LANES(REQUEST_LANES),
        .COUNTER_BITS(COUNTER_BITS)
    ) assertions (
        .clk(clk),
        .rst_n(core_ready),
        .tick_enable(tick_enable_qualified),
        .clear_counters(clear_counters_qualified),
        .scheduler_mode_q(scheduler_mode_q),
        .scheduler_state_q(scheduler_state_q),
        .ticks_recorded_q(ticks_recorded_q),
        .scheduler_count_free_q(scheduler_count_free_q),
        .scheduler_count_balance_q(scheduler_count_balance_q),
        .scheduler_count_commit_q(scheduler_count_commit_q),
        .scheduler_count_excite_q(scheduler_count_excite_q),
        .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
        .state_out(state_out),
        .pending_route_out(pending_route_out),
        .request_accept(request_accept),
        .request_reject(request_reject),
        .accepted_cell_mask(accepted_cell_mask),
        .neutral_routed_cell_mask(neutral_routed_cell_mask),
        .accepted_change_mask(accepted_change_mask),
        .accepted_changes(accepted_changes),
        .capacity_remaining(capacity_remaining),
        .capacity_exhausted(capacity_exhausted),
        .switch_load_numerator(switch_load_numerator),
        .requested_direct_events(requested_direct_events),
        .prevented_direct_events(prevented_direct_events),
        .neutral_routed_events(neutral_routed_events),
        .actual_direct_events(actual_direct_events),
        .reserved_state_events(reserved_state_events),
        .queue_overflow_events(queue_overflow_events),
        .invariant_flags(invariant_flags)
    );

    function automatic logic [STATE_BITS-1:0] packed_cell_value(
        input logic [(CELLS*STATE_BITS)-1:0] packed_value,
        input int element_index
    );
        packed_cell_value = packed_value[(element_index*STATE_BITS) +: STATE_BITS];
    endfunction

    task automatic clear_requests;
        begin
            request_valid = '0;
            request_cell_index = '0;
            request_target = '0;
            target_q = '0;
        end
    endtask

    task automatic set_lane(
        input int lane_index,
        input int element_index,
        input logic [STATE_BITS-1:0] target_value
    );
        begin
            request_valid[lane_index] = 1'b1;
            request_cell_index[(lane_index*CELL_INDEX_BITS) +: CELL_INDEX_BITS] =
                element_index[CELL_INDEX_BITS-1:0];
            request_target[(lane_index*STATE_BITS) +: STATE_BITS] = target_value;
            target_q[(element_index*STATE_BITS) +: STATE_BITS] = target_value;
        end
    endtask

    task automatic expect_cell(
        input int element_index,
        input logic [STATE_BITS-1:0] expected_state,
        input logic [STATE_BITS-1:0] expected_pending
    );
        begin
            if (packed_cell_value(state_out, element_index) !== expected_state) begin
                $fatal(1, "FRP M16 FPGA TB: retained state mismatch at cell %0d", element_index);
            end
            if (packed_cell_value(pending_route_out, element_index) !== expected_pending) begin
                $fatal(1, "FRP M16 FPGA TB: pending route mismatch at cell %0d", element_index);
            end
        end
    endtask

    task automatic expect_reset_domain;
        begin
            if (core_ready !== 1'b0) begin
                $fatal(1, "FRP M16 FPGA TB: core_ready is active during external reset");
            end
            if (state_out !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: retained state is not active neutral during reset");
            end
            if (pending_route_out !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: pending-route bank is not zero during reset");
            end
            if (ticks_recorded_q !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: tick counter is not zero during reset");
            end
            if (request_accept !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: request accepted during external reset");
            end
        end
    endtask

    task automatic expect_zero_events_and_flags;
        begin
            if (actual_direct_events !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: actual_direct_events is nonzero");
            end
            if (reserved_state_events !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: reserved_state_events is nonzero");
            end
            if (queue_overflow_events !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: queue_overflow_events is nonzero");
            end
            if (invariant_flags !== {FRP_M16_INVARIANT_FLAGS{1'b1}}) begin
                $fatal(1, "FRP M16 FPGA TB: integrated invariant flag set is incomplete");
            end
        end
    endtask

    task automatic release_reset_and_verify_blocking;
        begin
            @(negedge clk);
            rst_n_async = 1'b1;

            @(negedge clk);
            #1;
            if (core_ready !== 1'b0) begin
                $fatal(1, "FRP M16 FPGA TB: core_ready asserted before the second release edge");
            end
            if (ticks_recorded_q !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: tick crossed the first reset-release stage");
            end
            if (request_accept !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: request crossed the first reset-release stage");
            end

            @(negedge clk);
            #1;
            if (core_ready !== 1'b1) begin
                $fatal(1, "FRP M16 FPGA TB: core_ready did not assert after two release edges");
            end
            if (ticks_recorded_q !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: blocked tick executed during reset release");
            end
            if (state_out !== '0 || pending_route_out !== '0) begin
                $fatal(1, "FRP M16 FPGA TB: blocked request changed retained execution state");
            end

            tick_enable = 1'b0;
            clear_counters = 1'b0;
            clear_requests();
        end
    endtask

    task automatic start_tick(input frp_m16_scheduler_state_e expected_state);
        begin
            @(negedge clk);
            if (core_ready !== 1'b1) begin
                $fatal(1, "FRP M16 FPGA TB: attempted execution before core_ready");
            end
            if (scheduler_state_q !== expected_state) begin
                $fatal(
                    1,
                    "FRP M16 FPGA TB: scheduler state mismatch, expected=%0d actual=%0d",
                    expected_state,
                    scheduler_state_q
                );
            end
            tick_enable = 1'b1;
            #1;
        end
    endtask

    task automatic finish_tick;
        begin
            @(negedge clk);
            tick_enable = 1'b0;
            clear_requests();
            #1;
        end
    endtask

    initial begin
        rst_n_async = 1'b0;
        tick_enable = 1'b0;
        clear_counters = 1'b0;
        scheduler_mode = FRP_MODE_FREE;
        clear_requests();

        // Reset assertion and blocked execution inputs.
        repeat (2) @(negedge clk);
        #1;
        expect_reset_domain();

        tick_enable = 1'b1;
        clear_counters = 1'b1;
        set_lane(0, 0, FRP_STATE_POS);
        release_reset_and_verify_blocking();

        repeat (1) @(negedge clk);
        #1;
        if (scheduler_mode_q !== FRP_MODE_FREE || scheduler_state_q !== FRP_SCHED_FREE) begin
            $fatal(1, "FRP M16 FPGA TB: free scheduler did not propagate after core_ready");
        end
        expect_zero_events_and_flags();

        // Qualified request propagation: 0 -> 1.
        clear_requests();
        set_lane(0, 0, FRP_STATE_POS);
        start_tick(FRP_SCHED_FREE);
        if (
            request_accept[0] !== 1'b1
            || request_reject[0] !== 1'b0
            || accepted_cell_mask[0] !== 1'b1
            || accepted_change_mask[0] !== 1'b1
            || accepted_changes !== 1
            || switch_load_numerator !== 1
        ) begin
            $fatal(1, "FRP M16 FPGA TB: zero-to-positive request did not cross the FPGA boundary");
        end
        finish_tick();
        expect_cell(0, FRP_STATE_POS, FRP_STATE_ZERO);
        if (ticks_recorded_q !== 1 || scheduler_count_free_q !== 1) begin
            $fatal(1, "FRP M16 FPGA TB: first qualified free tick was not recorded");
        end
        expect_zero_events_and_flags();

        // Active-neutral first leg: 1 -> 0 with retained target -1.
        clear_requests();
        set_lane(0, 0, FRP_STATE_NEG);
        start_tick(FRP_SCHED_FREE);
        if (
            request_accept[0] !== 1'b1
            || neutral_routed_cell_mask[0] !== 1'b1
            || requested_direct_events !== 1
            || prevented_direct_events !== 1
            || neutral_routed_events !== 1
            || actual_direct_events !== 0
        ) begin
            $fatal(1, "FRP M16 FPGA TB: opposite-polarity request was not routed through active neutral");
        end
        finish_tick();
        expect_cell(0, FRP_STATE_ZERO, FRP_STATE_NEG);
        expect_zero_events_and_flags();

        // Retained pending-route completion: 0 -> -1.
        clear_requests();
        start_tick(FRP_SCHED_FREE);
        if (
            accepted_change_mask[0] !== 1'b1
            || accepted_changes !== 1
            || switch_load_numerator !== 1
        ) begin
            $fatal(1, "FRP M16 FPGA TB: retained pending route did not receive qualified capacity");
        end
        finish_tick();
        expect_cell(0, FRP_STATE_NEG, FRP_STATE_ZERO);
        if (ticks_recorded_q !== 3 || scheduler_count_free_q !== 3) begin
            $fatal(1, "FRP M16 FPGA TB: active-neutral route tick profile mismatch");
        end
        expect_zero_events_and_flags();

        // Asynchronous reset assertion after retained-state activity.
        @(negedge clk);
        #2;
        rst_n_async = 1'b0;
        #1;
        expect_reset_domain();
        if (
            scheduler_count_free_q !== '0
            || scheduler_count_balance_q !== '0
            || scheduler_count_commit_q !== '0
            || scheduler_count_excite_q !== '0
            || scheduler_count_neutralize_q !== '0
        ) begin
            $fatal(1, "FRP M16 FPGA TB: asynchronous reset did not clear scheduler counters");
        end

        // Second release and scheduler-mode propagation.
        scheduler_mode = FRP_MODE_7_1;
        tick_enable = 1'b1;
        clear_counters = 1'b1;
        clear_requests();
        set_lane(0, 1, FRP_STATE_POS);
        release_reset_and_verify_blocking();

        @(negedge clk);
        #1;
        if (scheduler_mode_q !== FRP_MODE_7_1 || scheduler_state_q !== FRP_SCHED_BALANCE) begin
            $fatal(1, "FRP M16 FPGA TB: 7/1 scheduler mode did not propagate");
        end
        if (state_out !== '0 || pending_route_out !== '0 || ticks_recorded_q !== '0) begin
            $fatal(1, "FRP M16 FPGA TB: mode registration modified retained execution state");
        end

        scheduler_mode = FRP_MODE_1_7;
        @(negedge clk);
        #1;
        if (scheduler_mode_q !== FRP_MODE_1_7 || scheduler_state_q !== FRP_SCHED_EXCITE) begin
            $fatal(1, "FRP M16 FPGA TB: 1/7 scheduler mode did not propagate");
        end

        clear_requests();
        set_lane(0, 1, FRP_STATE_POS);
        start_tick(FRP_SCHED_EXCITE);
        if (request_accept[0] !== 1'b1 || accepted_change_mask[1] !== 1'b1) begin
            $fatal(1, "FRP M16 FPGA TB: 1/7 excite request did not cross the FPGA boundary");
        end
        finish_tick();
        expect_cell(1, FRP_STATE_POS, FRP_STATE_ZERO);
        if (
            ticks_recorded_q !== 1
            || scheduler_count_excite_q !== 1
            || scheduler_state_q !== FRP_SCHED_NEUTRALIZE
        ) begin
            $fatal(1, "FRP M16 FPGA TB: 1/7 excite-to-neutralize progression mismatch");
        end
        expect_zero_events_and_flags();

        $display("FRP M16 FPGA integration testbench completed.");
        $display("CELLS=%0d REQUEST_LANES=%0d", CELLS, REQUEST_LANES);
        $display("core_ready=%0d", core_ready);
        $display("ticks_recorded=%0d", ticks_recorded_q);
        $display("actual_direct_events=%0d", actual_direct_events);
        $display("reserved_state_events=%0d", reserved_state_events);
        $display("queue_overflow_events=%0d", queue_overflow_events);
        $display("invariant_flags=%b", invariant_flags);
        $finish;
    end

endmodule : frp_m16_fpga_tb

`endif

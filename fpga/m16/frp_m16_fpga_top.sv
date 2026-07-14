// SPDX-License-Identifier: Apache-2.0
//
// FRP M16 FPGA Integration Top
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
//   Provides the target-independent FPGA integration boundary for the
//   qualified M16 retained balanced ternary execution core.
//
// Preserved M16 execution architecture:
//   - canonical balanced ternary encoding {-1, 0, +1};
//   - active neutral state 0;
//   - free / 7/1 / 1/7 temporal execution;
//   - deterministic request-lane arbitration;
//   - retained pending-route polarity;
//   - tick-separated opposite-polarity routing through 0;
//   - distributed transition-capacity enforcement;
//   - retained-state writeback;
//   - architectural telemetry;
//   - integrated invariant outputs.
//
// FPGA integration functions:
//   - asynchronous external reset assertion;
//   - synchronous reset release in the FPGA clock domain;
//   - request and execution blocking until core_ready;
//   - complete exposure of the qualified M16 core interface.
//
// No vendor-specific primitive is instantiated.

`ifndef FRP_M16_FPGA_TOP_SV
`define FRP_M16_FPGA_TOP_SV

`timescale 1ns / 1ps

`include "frp_m16_pkg.sv"
`include "frp_m16_core.sv"

module frp_m16_fpga_top #(
    parameter int CELLS =
        frp_m16_pkg::FRP_M16_DEFAULT_CELLS,

    parameter int STATE_BITS =
        frp_m16_pkg::FRP_M16_STATE_BITS,

    parameter int REQUEST_LANES =
        frp_m16_pkg::frp_calc_request_lanes(CELLS),

    parameter int CELL_INDEX_BITS =
        (CELLS <= 1) ? 1 : $clog2(CELLS),

    parameter int COUNTER_BITS =
        frp_m16_pkg::FRP_M16_COUNTER_BITS
) (
    input logic clk,
    input logic rst_n_async,

    input logic tick_enable,
    input logic clear_counters,

    input frp_m16_pkg::frp_m16_scheduler_mode_e
        scheduler_mode,

    input logic [REQUEST_LANES - 1:0]
        request_valid,

    input logic [
        (REQUEST_LANES * CELL_INDEX_BITS) - 1:0
    ] request_cell_index,

    input logic [
        (REQUEST_LANES * STATE_BITS) - 1:0
    ] request_target,

    input logic [
        (CELLS * STATE_BITS) - 1:0
    ] target_q,

    output logic core_ready,

    output logic [
        (CELLS * STATE_BITS) - 1:0
    ] state_out,

    output logic [
        (CELLS * STATE_BITS) - 1:0
    ] pending_route_out,

    output frp_m16_pkg::frp_m16_scheduler_mode_e
        scheduler_mode_q,

    output frp_m16_pkg::frp_m16_scheduler_state_e
        scheduler_state_q,

    output logic [COUNTER_BITS - 1:0]
        ticks_recorded_q,

    output logic [COUNTER_BITS - 1:0]
        scheduler_count_free_q,

    output logic [COUNTER_BITS - 1:0]
        scheduler_count_balance_q,

    output logic [COUNTER_BITS - 1:0]
        scheduler_count_commit_q,

    output logic [COUNTER_BITS - 1:0]
        scheduler_count_excite_q,

    output logic [COUNTER_BITS - 1:0]
        scheduler_count_neutralize_q,

    output logic [REQUEST_LANES - 1:0]
        request_accept,

    output logic [REQUEST_LANES - 1:0]
        request_reject,

    output logic [CELLS - 1:0]
        accepted_cell_mask,

    output logic [CELLS - 1:0]
        neutral_routed_cell_mask,

    output logic [CELLS - 1:0]
        accepted_change_mask,

    output logic [COUNTER_BITS - 1:0]
        accepted_changes,

    output logic [COUNTER_BITS - 1:0]
        capacity_remaining,

    output logic
        capacity_exhausted,

    output logic [COUNTER_BITS - 1:0]
        switch_load_numerator,

    output logic [COUNTER_BITS - 1:0]
        requested_direct_events,

    output logic [COUNTER_BITS - 1:0]
        prevented_direct_events,

    output logic [COUNTER_BITS - 1:0]
        neutral_routed_events,

    output logic [COUNTER_BITS - 1:0]
        actual_direct_events,

    output logic [COUNTER_BITS - 1:0]
        reserved_state_events,

    output logic [COUNTER_BITS - 1:0]
        queue_overflow_events,

    output logic [
        frp_m16_pkg::FRP_M16_INVARIANT_FLAGS - 1:0
    ] invariant_flags
);

    import frp_m16_pkg::*;

    localparam int EXPECTED_REQUEST_LANES =
        frp_calc_request_lanes(CELLS);

    localparam int EXPECTED_CELL_INDEX_BITS =
        (CELLS <= 1) ? 1 : $clog2(CELLS);

    logic [1:0] reset_sync_q;

    logic rst_n_core;
    logic tick_enable_core;
    logic clear_counters_core;

    logic [REQUEST_LANES - 1:0]
        request_valid_core;

    // ----------------------------------------------------------------------
    // Parameter relations
    // ----------------------------------------------------------------------

`ifndef SYNTHESIS

    initial begin
        if (CELLS < 1) begin
            $fatal(
                1,
                "FRP M16 FPGA top requires CELLS >= 1"
            );
        end

        if (STATE_BITS != FRP_M16_STATE_BITS) begin
            $fatal(
                1,
                "FRP M16 FPGA top requires canonical STATE_BITS"
            );
        end

        if (REQUEST_LANES != EXPECTED_REQUEST_LANES) begin
            $fatal(
                1,
                "FRP M16 FPGA top REQUEST_LANES relation is invalid"
            );
        end

        if (CELL_INDEX_BITS != EXPECTED_CELL_INDEX_BITS) begin
            $fatal(
                1,
                "FRP M16 FPGA top CELL_INDEX_BITS relation is invalid"
            );
        end

        if (COUNTER_BITS < 1) begin
            $fatal(
                1,
                "FRP M16 FPGA top requires COUNTER_BITS >= 1"
            );
        end
    end

`endif

    // ----------------------------------------------------------------------
    // FPGA reset synchronization
    // ----------------------------------------------------------------------
    //
    // External reset assertion reaches the synchronization register
    // asynchronously.
    //
    // Reset release reaches the M16 core after two rising clock edges:
    //
    //   reset_sync_q[0] = first synchronization stage
    //   reset_sync_q[1] = core reset release and core_ready
    //
    // No tick, counter-clear operation, or request-valid event reaches the
    // closed M16 core before core_ready becomes active.

    always_ff @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async) begin
            reset_sync_q <= 2'b00;
        end else begin
            reset_sync_q[0] <= 1'b1;
            reset_sync_q[1] <= reset_sync_q[0];
        end
    end

    assign rst_n_core =
        reset_sync_q[1];

    assign core_ready =
        rst_n_core;

    // ----------------------------------------------------------------------
    // Reset-qualified M16 execution inputs
    // ----------------------------------------------------------------------

    assign tick_enable_core =
        tick_enable
        && core_ready;

    assign clear_counters_core =
        clear_counters
        && core_ready;

    assign request_valid_core =
        request_valid
        & {REQUEST_LANES{core_ready}};

    // ----------------------------------------------------------------------
    // Qualified M16 RTL execution core
    // ----------------------------------------------------------------------

    frp_m16_core #(
        .CELLS(CELLS),
        .STATE_BITS(STATE_BITS),
        .REQUEST_LANES(REQUEST_LANES),
        .CELL_INDEX_BITS(CELL_INDEX_BITS),
        .COUNTER_BITS(COUNTER_BITS)
    ) u_m16_core (
        .clk(clk),
        .rst_n(rst_n_core),

        .tick_enable(tick_enable_core),
        .clear_counters(clear_counters_core),

        .scheduler_mode(scheduler_mode),

        .request_valid(request_valid_core),
        .request_cell_index(request_cell_index),
        .request_target(request_target),

        .target_q(target_q),

        .state_out(state_out),
        .pending_route_out(pending_route_out),

        .scheduler_mode_q(scheduler_mode_q),
        .scheduler_state_q(scheduler_state_q),

        .ticks_recorded_q(ticks_recorded_q),

        .scheduler_count_free_q(
            scheduler_count_free_q
        ),

        .scheduler_count_balance_q(
            scheduler_count_balance_q
        ),

        .scheduler_count_commit_q(
            scheduler_count_commit_q
        ),

        .scheduler_count_excite_q(
            scheduler_count_excite_q
        ),

        .scheduler_count_neutralize_q(
            scheduler_count_neutralize_q
        ),

        .request_accept(request_accept),
        .request_reject(request_reject),

        .accepted_cell_mask(
            accepted_cell_mask
        ),

        .neutral_routed_cell_mask(
            neutral_routed_cell_mask
        ),

        .accepted_change_mask(
            accepted_change_mask
        ),

        .accepted_changes(
            accepted_changes
        ),

        .capacity_remaining(
            capacity_remaining
        ),

        .capacity_exhausted(
            capacity_exhausted
        ),

        .switch_load_numerator(
            switch_load_numerator
        ),

        .requested_direct_events(
            requested_direct_events
        ),

        .prevented_direct_events(
            prevented_direct_events
        ),

        .neutral_routed_events(
            neutral_routed_events
        ),

        .actual_direct_events(
            actual_direct_events
        ),

        .reserved_state_events(
            reserved_state_events
        ),

        .queue_overflow_events(
            queue_overflow_events
        ),

        .invariant_flags(
            invariant_flags
        )
    );

endmodule : frp_m16_fpga_top

`endif

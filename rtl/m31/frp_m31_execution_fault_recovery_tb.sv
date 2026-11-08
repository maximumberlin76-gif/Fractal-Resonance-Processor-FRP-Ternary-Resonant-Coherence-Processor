// SPDX-License-Identifier: Apache-2.0
// Exercise public execution-core ports with a two-batch pending backlog.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_execution_fault_recovery_tb #(parameter int CELLS=64);
    import frp_m31_pkg::*;
    localparam int LANES = frp_calc_request_lanes(CELLS);
    localparam int IB = $clog2(CELLS);
    typedef logic [LANES-1:0] lanes_t;
    typedef logic [2*CELLS-1:0] bank_t;

    logic clk=0, rst_n=1, tick=0, clear=0;
    frp_m31_scheduler_mode_e mode=FRP_MODE_FREE;
    frp_m31_scheduler_state_e sched;
    lanes_t valid, accept, reject;
    logic [LANES*IB-1:0] address;
    logic [2*LANES-1:0] goal;
    bank_t target, state_bank, routes, want_state, want_routes;
    logic [CELLS-1:0] changed;
    logic [31:0] ticks, changes, direct, overflow;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] flags;
    int checks=0, edges=0;
    int completed[2][CELLS], cancelled[2][CELLS];
    int unsigned want_ticks=0;

    frp_m31_execution_core #(.CELLS(CELLS), .REQUEST_LANES(LANES), .COUNTER_BITS(32)) dut (
        .clk, .rst_n, .tick_enable(tick), .clear_counters(clear), .scheduler_mode(mode),
        .request_valid(valid), .request_cell_index(address), .request_target(goal), .target_q(target),
        .state_out(state_bank), .pending_route_out(routes), .scheduler_state_q(sched),
        .request_accept(accept), .request_reject(reject), .accepted_change_mask(changed),
        .accepted_changes(changes), .ticks_recorded_q(ticks), .actual_direct_events(direct),
        .queue_overflow_events(overflow), .invariant_flags(flags)
    );

    task automatic check(input bit ok, input string field);
        checks++;
        if (!ok) $fatal(1, "cells=%0d edge=%0d %s", CELLS, edges, field);
    endtask

    task automatic drive(input int base, input logic [1:0] dest);
        valid='1;
        for (int l=0; l<LANES; l++) begin
            address[l*IB+:IB]=IB'((base+l)%CELLS);
            goal[2*l+:2]=dest;
        end
    endtask

    task automatic expect_group(input int base, input logic [1:0] retained, pending);
        for (int l=0; l<LANES; l++) begin
            want_state[2*((base+l)%CELLS)+:2]=retained;
            want_routes[2*((base+l)%CELLS)+:2]=pending;
        end
    endtask

    task automatic advance(input lanes_t admits, denies);
        logic [CELLS-1:0] delta;
        #1;
        if (rst_n) begin
            for (int c=0; c<CELLS; c++) begin
                delta[c] = state_bank[2*c+:2] != want_state[2*c+:2];
                check(!(state_bank[2*c+:2] == 1 && want_state[2*c+:2] == 3) &&
                      !(state_bank[2*c+:2] == 3 && want_state[2*c+:2] == 1), "direct transition");
            end
            check(accept === admits && reject === denies, "lane responses");
            check(changed === delta && changes == $countones(delta), "writeback mask/count");
            check(direct == 0 && overflow == 0, "direct/overflow events");
            if (clear) want_ticks=0;
            if (tick) want_ticks++;
        end else want_ticks=0;
        clk=1; #1;
        check(state_bank === want_state && routes === want_routes, "retained state or pending destination");
        check(ticks == want_ticks, "clear/tick order");
        clk=0; #1;
        edges++;
    endtask

    task automatic serve_batch(input int direction);
        int grants;
        grants=0;
        for (int c=0; c<CELLS; c++) begin
            if (want_routes[2*c+:2] != 0 && grants < LANES) begin
                want_state[2*c+:2]=want_routes[2*c+:2];
                want_routes[2*c+:2]=0;
                completed[direction][c]++;
                grants++;
            end
        end
        check(grants == LANES, "full service batch");
        advance(0,'1);
    endtask

    task automatic episode(input int origin, input logic [1:0] first, input bit reset_backlog);
        logic [1:0] opposite;
        lanes_t lane0;
        int second, fresh, probe, direction;
        opposite = first ^ 2'b10;
        second = (origin+LANES)%CELLS;
        fresh = (origin+2*LANES)%CELLS;
        probe = (origin+2*LANES-1)%CELLS;
        direction = int'(first == 2'b11);
        lane0 = lanes_t'(1);
        rst_n=0; tick=0; clear=0; mode=FRP_MODE_FREE;
        target=0; valid=0; address=0; goal=0; want_state=0; want_routes=0;
        advance(0,0);
        rst_n=1; tick=1;
        drive(origin,first); expect_group(origin,first,0); advance('1,0);
        drive(second,first); expect_group(second,first,0); advance('1,0);

        tick=0; mode=FRP_MODE_7_1; advance(0,0);
        check(sched == FRP_SCHED_BALANCE, "balance entry");
        tick=1; drive(origin,opposite); expect_group(origin,0,opposite); advance('1,0);
        drive(second,opposite); expect_group(second,0,opposite); advance('1,0);

        tick=0; clear=1; mode=FRP_MODE_RESERVED;
        target[2*probe+:2]=2'b10;
        #1; check(!flags[FRP_INV_STATE_DOMAIN_VALID], "reserved target bank");
        advance(0,0);
        check(sched == FRP_SCHED_INVALID, "reserved cadence");
        target='0; clear=0;
        if (reset_backlog) begin
            for (int c=0; c<CELLS; c++)
                if (want_routes[2*c+:2] != 0) cancelled[direction][c]++;
            rst_n=0; want_state=0; want_routes=0; advance(0,0);
            return;
        end

        drive(fresh,first); tick=1; mode=FRP_MODE_FREE;
        advance(0,'1);
        check(sched == FRP_SCHED_FREE, "scheduler recovery");
        // Both batches now request completion. Low addresses receive capacity first.
        clear=1; serve_batch(direction);
        clear=0; serve_batch(direction);
        expect_group(fresh,first,0); advance('1,0);

        // An invalid lane cannot acquire ownership; a later valid lane can.
        for (int l=0; l<LANES; l++) address[l*IB+:IB]=IB'(probe);
        goal[1:0]=2'b10;
        for (int l=1; l<LANES; l++) goal[2*l+:2]=opposite;
        advance(lane0 << 1, ~(lane0 << 1));
        if (CELLS < (1 << IB)) begin
            valid=lane0; address[0+:IB]=IB'(CELLS); advance(0,lane0);
        end
    endtask

    initial begin
        foreach (completed[dir,c]) begin
            completed[dir][c]=0;
            cancelled[dir][c]=0;
        end
        for (int origin=0; origin<CELLS; origin++) begin
            episode(origin,2'b01,0); episode(origin,2'b11,0);
            episode(origin,2'b01,1); episode(origin,2'b11,1);
        end
        for (int dir=0; dir<2; dir++) for (int c=0; c<CELLS; c++) begin
            check(completed[dir][c] == 2*LANES, "per-address completions");
            check(cancelled[dir][c] == 2*LANES, "per-address reset cancellations");
        end
        $display("PASS EXECUTION_FAULT_RECOVERY cells=%0d lanes=%0d edges=%0d checks=%0d", CELLS,LANES,edges,checks);
        $finish;
    end
endmodule

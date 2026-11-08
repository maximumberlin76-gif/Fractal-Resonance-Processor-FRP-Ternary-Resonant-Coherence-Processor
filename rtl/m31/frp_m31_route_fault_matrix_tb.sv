// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_request_lanes.sv"
`include "frp_m31_active_neutral.sv"
`include "frp_m31_pending_routes.sv"
`include "frp_m31_capacity_guard.sv"

module frp_m31_route_fault_matrix_tb #(
    parameter int CELLS = 128, B = $clog2(CELLS)
);
    import frp_m31_pkg::*;
    localparam int L = frp_calc_request_lanes(CELLS);
    typedef logic [2*CELLS-1:0] bank_t;
    typedef logic [CELLS-1:0] mask_t;

    bit clk, rst_n, inject;
    bank_t state_q, q, d, candidate, fault_bank;
    mask_t service, created, cleared, retained, reserved, direct_mask, grants;
    logic [L-1:0] req, accept, neutral, bad_addr, raw, denied;
    logic [B*L-1:0] addr;
    logic [2*L-1:0] target;
    logic [4*L-1:0] kind;
    logic [31:0] direct_count, free_slots;
    logic domain_ok, polarity_ok, owner_ok, pending_cap_ok, safe_direct;
    logic route_domain, guard_ok, limit_ok;
    int trials, invalid_addresses;

    frp_m31_request_lanes #(.CELLS(CELLS), .CELL_INDEX_BITS(B)) lanes (
        .tick_enable(1'b1), .scheduler_state(FRP_SCHED_FREE), .request_valid(req),
        .request_cell_index(addr), .request_target(target), .state_q, .target_q('0),
        .pending_route_q(q), .request_accept(accept), .request_neutralized(neutral),
        .request_reject_invalid_cell(bad_addr)
    );
    frp_m31_active_neutral #(.CELLS(CELLS), .CELL_INDEX_BITS(B)) active (
        .tick_enable(1'b1), .scheduler_state(FRP_SCHED_FREE), .state_q, .pending_route_q(q),
        .request_accept(accept | raw), .request_neutralized(neutral | raw), .request_cell_index(addr),
        .request_target(target), .pending_completion_enable(service), .state_candidate_d(candidate),
        .actual_direct_mask(direct_mask), .actual_direct_events(direct_count),
        .no_actual_direct_events(safe_direct), .transition_domain_valid(route_domain)
    );
    frp_m31_pending_routes #(.CELLS(CELLS), .CELL_INDEX_BITS(B)) pending (
        .clk, .rst_n, .tick_enable(1'b1), .state_q, .request_accept(accept | raw),
        .request_neutralized(neutral | raw), .request_cell_index(addr), .request_target(target),
        .pending_completion_accept_mask(service), .pending_route_q(q), .pending_route_d(d),
        .pending_created_mask(created), .pending_cleared_mask(cleared), .pending_retained_mask(retained),
        .pending_reserved_mask(reserved), .pending_domain_valid(domain_ok),
        .pending_polarity_valid(polarity_ok), .pending_non_overwrite_valid(owner_ok),
        .pending_capacity_valid(pending_cap_ok)
    );
    frp_m31_capacity_guard #(.CELLS(CELLS), .CELL_INDEX_BITS(B)) guard_dut (
        .tick_enable(1'b1), .scheduler_state(FRP_SCHED_FREE), .state_q, .state_candidate_d(candidate),
        .request_accept_candidate(accept | raw), .request_cell_index(addr), .transition_class(kind),
        .pending_completion_candidate(service), .neutral_routed_candidate(created),
        .request_reject_capacity(denied), .capacity_accept_mask(grants), .capacity_remaining(free_slots),
        .transition_capacity_valid(guard_ok), .accepted_changes_within_limit(limit_ok)
    );

    task automatic pulse();
        #1; clk = 1; #1; clk = 0; #1;
    endtask
    task automatic check(input logic ok, input int p, input string stage);
        if (ok !== 1'b1) $fatal(1, "cells=%0d bits=%0d cell=%0d %s", CELLS, B, p, stage);
    endtask

    task automatic trial(input int p, input logic [1:0] sign_code);
        bank_t original, opposite;
        mask_t probe;
        probe = '0; probe[p] = 1;
        original = '0; original[2*p+:2] = sign_code;
        opposite = '0;
        opposite[2*p+:2] = (sign_code == FRP_STATE_POS) ? FRP_STATE_NEG : FRP_STATE_POS;
        state_q = original; req = '0; raw = '0; service = '0; target = '0;
        addr = '0; addr[0+:B] = B'(p); kind = '0; kind[0+:4] = FRP_TRANS_OPPOSITE_POLARITY;
        rst_n = 0; pulse(); rst_n = 1;
        req[0] = 1; target[0+:2] = opposite[2*p+:2]; #1;
        check(accept == 1 && neutral == 1 && created == probe && q == 0 && d == opposite &&
              candidate == 0 && direct_mask == 0 && direct_count == 0 && safe_direct &&
              grants == probe && free_slots == L-1 && guard_ok && polarity_ok, p, "legal creation");

        if (inject) begin
            fault_bank = opposite;
            force active.state_candidate_next = fault_bank; #1;
            check(candidate == opposite && direct_mask == probe && direct_count == 1 &&
                  !safe_direct && q == 0, p, "direct candidate");
            release active.state_candidate_next;
            force pending.pending_route_next = '0; #1;
            check(created == probe && d == 0 && q == 0 && !polarity_ok && domain_ok,
                  p, "lost new route");
            release pending.pending_route_next;
            fault_bank = '0; fault_bank[2*p+:2] = FRP_STATE_RESERVED;
            force pending.pending_route_next = fault_bank; #1;
            check(reserved == probe && !domain_ok && q == 0 && d == fault_bank, p, "reserved route");
            release pending.pending_route_next;
        end
        #1;
        check(candidate == 0 && safe_direct && d == opposite && domain_ok && polarity_ok,
              p, "creation restored");
        pulse(); req = '0; state_q = '0; #1;
        check(q == opposite && d == opposite && retained == probe && owner_ok, p, "retained owner");
        if (inject) begin
            fault_bank = original;
            force pending.pending_route_next = fault_bank; #1;
            check(q == opposite && d == original && !owner_ok && !polarity_ok && domain_ok,
                  p, "overwritten polarity");
            release pending.pending_route_next;
        end
        service = probe; #1;
        check(cleared == probe && d == 0 && candidate == opposite && pending_cap_ok &&
              direct_count == 0 && grants == probe, p, "legal completion");
        if (inject) begin
            fault_bank = opposite;
            force pending.pending_route_next = fault_bank; #1;
            check(cleared == probe && q == opposite && d == opposite && !pending_cap_ok,
                  p, "uncleared completion");
            release pending.pending_route_next;
        end
        #1; check(cleared == probe && d == 0 && pending_cap_ok, p, "completion restored");
        pulse(); service = '0; #1;
        check(q == 0 && d == 0 && limit_ok && guard_ok && free_slots == L, p, "empty bank");
        if (inject) begin
            force guard_dut.accepted_changes = L+1; #1;
            check(free_slots == 0 && !limit_ok && !guard_ok && grants == 0, p, "excess changes");
            release guard_dut.accepted_changes;
            #1; check(free_slots == L && limit_ok && guard_ok, p, "capacity restored");
        end
        trials++;
    endtask

    initial begin
        inject = $test$plusargs("inject");
        for (int p = 0; p < CELLS; p++) begin
            trial(p, FRP_STATE_NEG);
            trial(p, FRP_STATE_POS);
        end
        // Present every unused encoding to each component and check the full bank for aliasing.
        for (int code = CELLS; code < (1 << B); code++) begin
            req = 1; raw = 1; addr[0+:B] = B'(code); #1;
            check(bad_addr == 1 && accept == 0 && !route_domain && !domain_ok && denied == 1 &&
                  !guard_ok && candidate == 0 && d == 0 && q == 0 && grants == 0, code, "invalid address");
            invalid_addresses++;
        end
        $display("PASS ROUTE_FAULT_MATRIX cells=%0d bits=%0d inject=%0d trials=%0d invalid=%0d",
                 CELLS, B, inject, trials, invalid_addresses);
        $finish;
    end
endmodule

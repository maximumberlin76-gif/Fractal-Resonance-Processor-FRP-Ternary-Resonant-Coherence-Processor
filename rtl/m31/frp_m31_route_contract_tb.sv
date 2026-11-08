// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_request_lanes.sv"
`include "frp_m31_active_neutral.sv"
`include "frp_m31_pending_routes.sv"

module frp_m31_route_contract_tb #(parameter int CELLS = 128);
    import frp_m31_pkg::*;
    localparam int L = frp_calc_request_lanes(CELLS), B = $clog2(CELLS);
    typedef logic [2*CELLS-1:0] bank_t;
    typedef logic [CELLS-1:0] mask_t;
    bit clk, rst_n;
    bank_t state_q, pending_q, pending_d, candidate, pending_fault;
    wire [2*CELLS-1:0] observed_pending = pending_q | pending_fault;
    logic [L-1:0] valid, accept, neutral, busy, bad_addr, blocked, inject_accept;
    logic [L*B-1:0] addr;
    logic [2*L-1:0] target;
    mask_t service, created, cleared, retained, changed, reserved;
    logic cell_ok, target_ok, output_ok, completion_ok, routing_ok, pending_ok, capacity_ok;
    logic [31:0] direct_events;
    frp_m31_scheduler_state_e sched;
    int checks;

    frp_m31_request_lanes #(.CELLS(CELLS)) lanes (
        .tick_enable(1'b1), .scheduler_state(sched), .request_valid(valid),
        .request_cell_index(addr), .request_target(target), .state_q,
        .target_q('0), .pending_route_q(observed_pending), .request_accept(accept),
        .request_neutralized(neutral), .request_reject_pending_busy(busy),
        .request_reject_invalid_cell(bad_addr), .request_reject_scheduler(blocked),
        .request_cell_domain_valid(cell_ok), .request_target_domain_valid(target_ok)
    );
    frp_m31_active_neutral #(.CELLS(CELLS)) active (
        .tick_enable(1'b1), .scheduler_state(sched), .state_q, .pending_route_q(observed_pending),
        .request_accept(accept | inject_accept), .request_neutralized(neutral),
        .request_cell_index(addr), .request_target(target), .pending_completion_enable(service),
        .state_candidate_d(candidate), .accepted_change_candidate_mask(changed),
        .reserved_transition_mask(reserved), .state_output_domain_valid(output_ok),
        .pending_completion_from_zero_valid(completion_ok), .active_neutral_routing_valid(routing_ok),
        .actual_direct_events(direct_events)
    );
    frp_m31_pending_routes #(.CELLS(CELLS)) pending (
        .clk, .rst_n, .tick_enable(1'b1), .state_q, .request_accept(accept),
        .request_neutralized(neutral), .request_cell_index(addr), .request_target(target),
        .pending_completion_accept_mask(service), .pending_route_q(pending_q),
        .pending_route_d(pending_d), .pending_created_mask(created), .pending_cleared_mask(cleared),
        .pending_retained_mask(retained), .pending_capacity_valid(capacity_ok),
        .pending_completion_from_zero_valid(pending_ok)
    );

    task automatic pulse();
        #1; clk = 1; #1; clk = 0; #1;
    endtask
    task automatic check(input logic ok, input int p, input string label_text);
        if (ok !== 1'b1 || direct_events !== 0)
            $fatal(1, "cells=%0d cell=%0d %s", CELLS, p, label_text);
        checks++;
    endtask

    task automatic trial(input int p, input logic [1:0] sign_code);
        mask_t probe;
        bank_t original, opposite;
        probe = '0; probe[p] = 1;
        original = '0; original[2*p+:2] = sign_code;
        opposite = '0;
        opposite[2*p+:2] = (sign_code == FRP_STATE_POS) ? FRP_STATE_NEG : FRP_STATE_POS;
        state_q = original; valid = '0; addr = '0; addr[0+:B] = B'(p);
        target = '0; pending_fault = '0; inject_accept = '0; service = '0;
        sched = FRP_SCHED_FREE; rst_n = 0; pulse(); rst_n = 1;

        valid[0] = 1; target[0+:2] = opposite[2*p+:2]; #1;
        check(accept == 1 && neutral == 1 && candidate == 0 && changed == probe &&
              created == probe && pending_d == opposite && routing_ok, p, "first leg");
        pulse(); service = probe; #1;
        check(pending_q == opposite && pending_d == opposite && busy == 1 && accept == 0 &&
              retained == probe && !pending_ok && !capacity_ok && !completion_ok &&
              candidate == original && changed == 0 && reserved == 0, p, "early completion");
        state_q = '0; target[0+:2] = sign_code; #1;
        check(busy == 1 && accept == 0 && candidate == opposite && changed == probe &&
              cleared == probe && pending_d == 0 && completion_ok && capacity_ok, p, "owner priority");
        valid = '0; pulse();
        check(pending_q == 0 && !capacity_ok && !completion_ok && reserved == probe &&
              candidate == 0 && changed == 0, p, "empty completion");

        service = '0; state_q[2*p+:2] = FRP_STATE_RESERVED; #1;
        check(!cell_ok && !output_ok && reserved == probe && candidate == state_q, p, "retained domain");
        state_q = '0; pending_fault[2*p+:2] = FRP_STATE_RESERVED; #1;
        check(!target_ok && output_ok && reserved == probe && candidate == 0, p, "pending domain");
        pending_fault = '0;

        // Drive the component accept port while the upstream scheduler rejects the lane.
        valid[0] = 1; inject_accept[0] = 1; sched = FRP_SCHED_BALANCE; #1;
        check(blocked == 1 && accept == 0 && changed == 0 && candidate == 0, p, "blocked exit from zero");
        state_q = original; target = '0; sched = FRP_SCHED_COMMIT; #1;
        check(blocked == 1 && accept == 0 && changed == 0 && candidate == original, p, "blocked entry to zero");
        target[0+:2] = opposite[2*p+:2]; #1;
        check(!routing_ok && candidate == original && changed == 0 && created == 0, p, "missing route tag");
        target = '0; sched = FRP_SCHED_FREE; inject_accept = '0; #1;
        check(accept == 1 && candidate == 0 && changed == probe && created == 0, p, "legal entry to zero");

        if (CELLS < (1 << B)) begin
            addr[0+:B] = B'(CELLS); #1;
            check(bad_addr == 1 && accept == 0 && candidate == original && changed == 0 &&
                  pending_d == 0 && !cell_ok, p, "unused address");
        end
    endtask

    initial begin
        for (int p = 0; p < CELLS; p++) begin
            trial(p, FRP_STATE_NEG);
            trial(p, FRP_STATE_POS);
        end
        $display("PASS ROUTE_CONTRACT cells=%0d checks=%0d", CELLS, checks);
        $finish;
    end
endmodule

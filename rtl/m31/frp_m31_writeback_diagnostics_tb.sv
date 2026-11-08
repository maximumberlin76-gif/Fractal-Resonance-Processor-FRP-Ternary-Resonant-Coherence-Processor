// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m31_state_update.sv"

module frp_m31_writeback_diagnostics_tb #(parameter int CELLS = 128);
    import frp_m31_pkg::*;
    typedef logic [2*CELLS-1:0] bank_t;
    typedef logic [CELLS-1:0] mask_t;
    typedef enum int {RESERVED, DIRECT, NO_GRANT, NO_CHANGE,
                      BAD_ROUTE, BAD_COMPLETION} fault_t;

    bit clk, rst_n;
    bank_t candidate, q, d, visible;
    mask_t grant, change, route, complete, writes, holds, flagged, injected;
    logic output_ok, capacity_ok, route_ok, completion_ok, update_ok;
    logic no_reserved, no_direct;
    logic [31:0] accepted, direct_count, route_count, completion_count;
    int cases;

    frp_m31_state_update #(.CELLS(CELLS)) dut (
        .clk, .rst_n, .tick_enable(1'b1), .scheduler_state(FRP_SCHED_FREE),
        .state_candidate_d(candidate), .capacity_accept_mask(grant),
        .accepted_change_candidate_mask(change), .neutral_routed_mask(route),
        .pending_completion_mask(complete), .reserved_transition_mask('0),
        .actual_direct_mask('0), .state_q(q), .state_d(d), .state_out(visible),
        .state_write_enable_mask(writes), .state_hold_mask(holds),
        .state_reserved_mask(flagged), .accepted_changes(accepted),
        .actual_direct_events(direct_count), .no_actual_direct_events(no_direct),
        .state_output_domain_valid(output_ok), .no_reserved_state_output(no_reserved),
        .state_write_capacity_valid(capacity_ok), .active_neutral_writeback_valid(route_ok),
        .pending_completion_writeback_valid(completion_ok), .state_update_valid(update_ok),
        .neutral_routed_commit_events(route_count), .pending_completion_commit_events(completion_count)
    );

    task automatic pulse();
        #1; clk = 1; #1; clk = 0; #1;
    endtask

    task automatic trial(input int cell_id, input logic [1:0] sign_code, input fault_t fault);
        bank_t baseline;
        mask_t probe;
        logic [1:0] dest;
        probe = '0;
        probe[cell_id] = 1;
        candidate = '0; grant = '0; change = '0; route = '0; complete = '0;
        rst_n = 0; pulse(); rst_n = 1;
        baseline = '0;
        if (fault inside {DIRECT, BAD_COMPLETION}) begin
            baseline[2*cell_id+:2] = sign_code;
            candidate = baseline; grant = probe; change = probe;
            pulse();
        end
        if (q !== baseline) $fatal(1, "preload cell=%0d", cell_id);

        case (fault)
            RESERVED: dest = FRP_STATE_RESERVED;
            DIRECT: dest = (sign_code == FRP_STATE_POS) ? FRP_STATE_NEG : FRP_STATE_POS;
            BAD_COMPLETION: dest = FRP_STATE_ZERO;
            default: dest = sign_code;
        endcase
        candidate[2*cell_id+:2] = dest;
        grant = (fault == NO_GRANT) ? '0 : probe;
        change = (fault == NO_CHANGE) ? '0 : probe;
        route = (fault == BAD_ROUTE) ? probe : '0;
        complete = (fault == BAD_COMPLETION) ? probe : '0;
        #1;
        if (q !== baseline || d !== baseline || writes !== '0 || holds !== '1 ||
            accepted !== 0 || direct_count !== 0 || output_ok !== 1'b1)
            $fatal(1, "native rejection cell=%0d fault=%0d", cell_id, fault);

        // Override only the final write permission, without clocking the fault into q.
        injected = probe;
        force dut.commit_allowed_w = injected;
        #1;
        if (q !== baseline || visible !== baseline || d !== candidate ||
            writes !== probe || holds !== ~probe || accepted !== 1 || update_ok !== 1'b0 ||
            flagged !== ((fault == RESERVED) ? probe : '0) ||
            output_ok !== (fault != RESERVED) || no_reserved !== (fault != RESERVED) ||
            direct_count !== int'(fault == DIRECT) || no_direct !== (fault != DIRECT) ||
            capacity_ok !== !(fault inside {NO_GRANT, NO_CHANGE}) ||
            route_ok !== (fault != BAD_ROUTE) || completion_ok !== (fault != BAD_COMPLETION) ||
            route_count !== 0 || completion_count !== 0)
            $fatal(1, "injected diagnostic cell=%0d fault=%0d", cell_id, fault);

        release dut.commit_allowed_w;
        candidate = baseline; grant = '0; change = '0; route = '0; complete = '0;
        #1;
        if (d !== baseline || writes !== '0 || holds !== '1 || update_ok !== 1'b1)
            $fatal(1, "release cell=%0d fault=%0d", cell_id, fault);
        pulse();
        if (q !== baseline) $fatal(1, "retention after release cell=%0d", cell_id);
        cases++;
    endtask

    initial begin
        for (int p = 0; p < CELLS; p++)
            for (int s = 0; s < 2; s++)
                for (int f = int'(RESERVED); f <= int'(BAD_COMPLETION); f++)
                    trial(p, s ? FRP_STATE_POS : FRP_STATE_NEG, fault_t'(f));
        $display("PASS WRITEBACK_DIAGNOSTICS cells=%0d cases=%0d", CELLS, cases);
        $finish;
    end
endmodule

// SPDX-License-Identifier: Apache-2.0
// Faults enter through component ports. Capacity grants drive writeback directly.
`timescale 1ns/1ps
`include "frp_m31_capacity_guard.sv"
`include "frp_m31_state_update.sv"

module frp_m31_capacity_writeback_isolation_tb #(parameter int CELLS=128);
    import frp_m31_pkg::*;
    localparam int LANES=frp_calc_request_lanes(CELLS), IB=$clog2(CELLS);
    typedef logic [CELLS-1:0] mask_t;
    typedef logic [2*CELLS-1:0] bank_t;
    typedef logic [1:0] trit_t;
    typedef enum int {BAD_SYMBOL, DIRECT, BAD_CLASS, FALSE_CLASS, MISSING_CHANGE,
        SPURIOUS_CHANGE, DUAL_TAG, WRONG_ROUTE, WRONG_COMPLETE, BAD_GRANT,
        BLOCK_ROUTE, BLOCK_COMPLETE, BLOCK_PLAIN, DIRECT_FLAG, RESERVED_FLAG,
        LEGAL_ROUTE, LEGAL_COMPLETE, BAD_ADDRESS} scenario_t;

    bit clk, rst_n, tick;
    frp_m31_scheduler_state_e sched;
    bank_t candidate, q, d, visible, model;
    logic [LANES-1:0] requests, admit, deny;
    logic [LANES*IB-1:0] address;
    logic [4*LANES-1:0] classes;
    mask_t service, route, complete, change, reserved, direct;
    mask_t grants, rejects, writes, holds, flagged;
    logic cap_ok, update_ok, output_ok;
    logic [31:0] granted_changes, committed_changes, direct_events;
    int cases=0, checks=0;

    frp_m31_capacity_guard #(.CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(IB)) guard (
        .tick_enable(tick), .scheduler_state(sched), .request_accept_candidate(requests),
        .request_cell_index(address), .transition_class(classes), .pending_completion_candidate(service),
        .neutral_routed_candidate(route), .state_q(q), .state_candidate_d(candidate),
        .request_accept_capacity(admit), .request_reject_capacity(deny),
        .capacity_accept_mask(grants), .capacity_reject_mask(rejects),
        .accepted_changes(granted_changes), .transition_capacity_valid(cap_ok)
    );
    frp_m31_state_update #(.CELLS(CELLS), .REQUEST_LANES(LANES)) wb (
        .clk, .rst_n, .tick_enable(tick), .scheduler_state(sched), .state_candidate_d(candidate),
        .capacity_accept_mask(grants), .accepted_change_candidate_mask(change),
        .neutral_routed_mask(route), .pending_completion_mask(complete),
        .reserved_transition_mask(reserved), .actual_direct_mask(direct),
        .state_q(q), .state_d(d), .state_out(visible), .state_write_enable_mask(writes),
        .state_hold_mask(holds), .state_reserved_mask(flagged), .accepted_changes(committed_changes),
        .actual_direct_events(direct_events), .state_update_valid(update_ok), .state_output_domain_valid(output_ok)
    );

    task automatic check(input bit ok, input string label_text);
        checks++;
        if (!ok) $fatal(1,"cells=%0d case=%0d %s",CELLS,cases,label_text);
    endtask
    task automatic edge_step();
        #1; clk=1; #1; clk=0; #1;
    endtask
    task automatic clear_ports();
        requests=0; address=0; classes=0; service=0; route=0; complete=0;
        change=0; reserved=0; direct=0; candidate=model; sched=FRP_SCHED_FREE;
    endtask
    task automatic lane(input int l, cell_id, input trit_t dest,
                        input frp_m31_transition_class_e kind);
        requests[l]=1; address[IB*l+:IB]=IB'(cell_id); classes[4*l+:4]=kind;
        if (cell_id<CELLS) begin
            candidate[2*cell_id+:2]=dest;
            change[cell_id]=(model[2*cell_id+:2]!=dest);
        end
    endtask

    task automatic trial(input int p, input trit_t sign_code, input scenario_t test_case);
        int peer;
        bit pre_probe, pre_peer, grant_p, write_p, guard_valid, wb_valid;
        trit_t dest, peer_dest;
        mask_t expected_grants, expected_writes, expected_bad, expected_rejects;
        logic [LANES-1:0] expected_admit, expected_deny;
        bank_t next_bank;
        peer=(p+1)%CELLS;
        rst_n=0; tick=0; model=0; clear_ports(); edge_step();
        check(q==='0, "reset bank");
        rst_n=1; tick=1;
        pre_probe=test_case inside {DIRECT,WRONG_COMPLETE,BAD_GRANT,BLOCK_ROUTE,LEGAL_ROUTE};
        pre_peer=test_case inside {BLOCK_COMPLETE,BLOCK_PLAIN};
        if (pre_probe) lane(0,p,sign_code,FRP_TRANS_ZERO_TO_NONZERO);
        if (pre_peer) lane(1,peer,sign_code,FRP_TRANS_ZERO_TO_NONZERO);
        model=candidate; edge_step(); check(q===model,"preload");

        clear_ports();
        dest=pre_probe ? FRP_STATE_ZERO : sign_code;
        peer_dest=pre_peer ? FRP_STATE_ZERO : sign_code;
        lane(0,p,dest,pre_probe ? FRP_TRANS_NONZERO_TO_ZERO : FRP_TRANS_ZERO_TO_NONZERO);
        lane(1,peer,peer_dest,pre_peer ? FRP_TRANS_NONZERO_TO_ZERO : FRP_TRANS_ZERO_TO_NONZERO);
        grant_p=1; write_p=0; guard_valid=1; wb_valid=0;
        case (test_case)
            BAD_SYMBOL: begin candidate[2*p+:2]=FRP_STATE_RESERVED; grant_p=0; guard_valid=0; end
            DIRECT: begin candidate[2*p+:2]=sign_code^2'b10; grant_p=0; guard_valid=0; end
            BAD_CLASS: begin classes[3:0]=FRP_TRANS_INVALID; grant_p=0; guard_valid=0; wb_valid=1; end
            FALSE_CLASS: begin candidate[2*p+:2]=0; change[p]=0; grant_p=0; guard_valid=0; wb_valid=1; end
            MISSING_CHANGE: change[p]=0;
            SPURIOUS_CHANGE: begin candidate[2*p+:2]=0; classes[3:0]=FRP_TRANS_SAME_STATE; end
            DUAL_TAG: begin route[p]=1; complete[p]=1; end
            WRONG_ROUTE: route[p]=1;
            WRONG_COMPLETE: complete[p]=1;
            BAD_GRANT: begin service[p]=1; complete[p]=1; grant_p=0; guard_valid=0; end
            BLOCK_ROUTE: begin sched=FRP_SCHED_COMMIT; route[p]=1; end
            BLOCK_COMPLETE: begin sched=FRP_SCHED_BALANCE; complete[p]=1; end
            BLOCK_PLAIN: sched=FRP_SCHED_BALANCE;
            DIRECT_FLAG: direct[p]=1;
            RESERVED_FLAG: reserved[p]=1;
            LEGAL_ROUTE: begin route[p]=1; classes[3:0]=FRP_TRANS_OPPOSITE_POLARITY; write_p=1; wb_valid=1; end
            LEGAL_COMPLETE: begin requests[0]=0; service[p]=1; complete[p]=1; write_p=1; wb_valid=1; end
            BAD_ADDRESS: begin address[0+:IB]=IB'(CELLS); candidate[2*p+:2]=0;
                change[p]=0; grant_p=0; guard_valid=0; wb_valid=1; end
        endcase

        expected_grants='0; expected_grants[peer]=1; expected_grants[p]=grant_p;
        expected_writes='0; expected_writes[peer]=1; expected_writes[p]=write_p;
        expected_admit='0; expected_admit[1]=1; expected_admit[0]=grant_p && requests[0];
        expected_deny='0; expected_deny[0]=!grant_p;
        expected_rejects='0; expected_rejects[p]=!grant_p && test_case!=BAD_ADDRESS;
        expected_bad='0; expected_bad[p]=test_case inside {BAD_SYMBOL,RESERVED_FLAG};
        next_bank=model; next_bank[2*peer+:2]=peer_dest;
        if (write_p) next_bank[2*p+:2]=dest;
        #1;
        check(admit===expected_admit && deny===expected_deny,"lane decision");
        check(grants===expected_grants && rejects===expected_rejects && cap_ok===guard_valid,"guard masks/diagnostic");
        check(granted_changes==1+int'(grant_p && test_case!=SPURIOUS_CHANGE),"guard change count");
        check(q===model && visible===model && d===next_bank,"writeback isolation");
        check(writes===expected_writes && holds===~expected_writes && flagged===expected_bad,"writeback masks");
        check(committed_changes==$countones(expected_writes) && direct_events==0,"writeback accounting");
        check(update_ok===wb_valid && output_ok,"writeback diagnostic");
        model=next_bank; edge_step(); check(q===model,"committed bank");

        // Retry the same address with clean metadata on a legal leg through zero.
        clear_ports(); dest=(model[2*p+:2]==0) ? sign_code : FRP_STATE_ZERO;
        lane(0,p,dest,(dest==0) ? FRP_TRANS_NONZERO_TO_ZERO : FRP_TRANS_ZERO_TO_NONZERO);
        #1; check(cap_ok && update_ok && writes[p] && committed_changes==1,"clean retry");
        model[2*p+:2]=dest; edge_step(); check(q===model,"retry bank");
        cases++;
    endtask

    // Fill every grant, rotate the pending addresses, then compare rejection
    // before allocation with a conflicting writeback tag after allocation.
    task automatic saturated(input int origin, variant, input trit_t sign_code);
        int bad_cell, used;
        mask_t expected_grants, expected_writes, expected_bad, expected_rejects;
        bank_t next_bank;
        rst_n=0; tick=0; model=0; clear_ports(); edge_step();
        rst_n=1; tick=1; bad_cell=CELLS;
        for (int j=0; j<=LANES; j++) begin
            int c;
            c=(origin+j)%CELLS;
            service[c]=1; complete[c]=1; change[c]=1; candidate[2*c+:2]=sign_code;
            if (c<bad_cell) bad_cell=c;
        end
        expected_bad='0;
        if (variant==1) begin
            candidate[2*bad_cell+:2]=FRP_STATE_RESERVED;
            expected_bad[bad_cell]=1;
        end
        if (variant==2) route[bad_cell]=1;
        expected_rejects='0;
        for (int l=0; l<LANES; l++) begin
            int c;
            c=(origin+LANES+1+l)%CELLS;
            lane(l,c,sign_code,FRP_TRANS_ZERO_TO_NONZERO);
            expected_rejects[c]=1;
        end
        expected_grants='0; used=0;
        for (int c=0; c<CELLS; c++) if (service[c]) begin
            if (!expected_bad[c] && used<LANES) begin expected_grants[c]=1; used++; end
            else expected_rejects[c]=1;
        end
        expected_writes=expected_grants;
        if (variant==2) expected_writes[bad_cell]=0;
        next_bank='0;
        for (int c=0; c<CELLS; c++)
            if (expected_writes[c]) next_bank[2*c+:2]=sign_code;
        #1;
        check(admit==='0 && deny==='1 && used==LANES,"pending priority over all lanes");
        check(grants===expected_grants && rejects===expected_rejects && granted_changes==LANES,
              "full grant allocation");
        check(writes===expected_writes && holds===~expected_writes &&
              committed_changes==$countones(expected_writes),"commit after grant");
        check(cap_ok===(variant!=1) && update_ok===(variant==0) &&
              flagged===expected_bad && output_ok && direct_events==0,"full-bank diagnostic");
        check(d===next_bank,"full-bank decision"); edge_step();
        check(q===next_bank,"full-bank commit");
        cases++;
    endtask

    initial begin
        for (int p=0; p<CELLS; p++)
            for (int sign_id=0; sign_id<2; sign_id++)
                for (int t=0; t<=int'(BAD_ADDRESS); t++)
                    if (t!=int'(BAD_ADDRESS) || CELLS<(1<<IB))
                        trial(p,(sign_id!=0) ? FRP_STATE_NEG : FRP_STATE_POS,scenario_t'(t));
        for (int p=0; p<CELLS; p++)
            for (int sign_id=0; sign_id<2; sign_id++)
                for (int variant=0; variant<3; variant++)
                    saturated(p,variant,(sign_id!=0) ? FRP_STATE_NEG : FRP_STATE_POS);
        $display("PASS CAPACITY_WRITEBACK_ISOLATION cells=%0d lanes=%0d cases=%0d checks=%0d",CELLS,LANES,cases,checks);
        $finish;
    end
endmodule

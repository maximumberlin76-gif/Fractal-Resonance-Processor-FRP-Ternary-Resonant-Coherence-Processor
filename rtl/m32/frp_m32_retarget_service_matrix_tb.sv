// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"
`include "frp_m31_execution_core.sv"

module frp_m32_retarget_service_matrix_tb #(parameter int CELLS=128);
    import frp_m31_pkg::*;
    localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
    typedef logic [CELLS-1:0] mask_t;
    typedef logic [2*CELLS-1:0] bank_t;
    bit clk, rst_n, tick, clear, valid, auto_en, history;
    bank_t src, goal, state_out, owner, state_ref, owner_ref, goal_ref;
    frp_m31_scheduler_mode_e mode;
    frp_m31_scheduler_state_e sched;
    logic [L-1:0] lanes, admit, deny;
    logic [B*L-1:0] addr;
    logic [2*L-1:0] targets;
    mask_t issued, routed, writes;
    logic take, reject, qvalid;
    logic [31:0] used, remaining, direct_count, overflow;
    logic [9:0] flags;
    int phase, last_mode, steps, cases;
    bit [L-1:0] hit[3][3][L+1][2];
    mask_t owner_locations;

    frp_m32_registered_target_request_path #(.CELLS(CELLS)) path (
        .clk,.rst_n,.tick_enable(tick),.clear_counters(clear),.phase_target_valid(valid),
        .phase_target_source(src),.auto_target_enable(auto_en),.retained_state(state_out),
        .pending_route(owner),.scheduler_state(sched),.registered_target_q(goal),
        .registered_target_valid_q(qvalid),.capture_accepted(take),.capture_rejected(reject),
        .phase_request_valid(lanes),.phase_request_cell_index(addr),.phase_request_target(targets)
    );
    frp_m31_execution_core #(.CELLS(CELLS)) core (
        .clk,.rst_n,.tick_enable(tick),.clear_counters(clear),.scheduler_mode(mode),
        .request_valid(lanes),.request_cell_index(addr),.request_target(targets),.target_q(goal),
        .state_out,.pending_route_out(owner),.scheduler_state_q(sched),.request_accept(admit),
        .request_reject(deny),.accepted_cell_mask(issued),.neutral_routed_cell_mask(routed),
        .accepted_change_mask(writes),.accepted_changes(used),.capacity_remaining(remaining),
        .actual_direct_events(direct_count),.queue_overflow_events(overflow),.invariant_flags(flags)
    );

    task automatic pulse();
        #1; clk=1; #1; clk=0; #1;
    endtask

    task automatic step();
        bank_t ns, np;
        mask_t fresh, bridge, change;
        logic [L-1:0] rv, ra, rr;
        logic [B*L-1:0] ri;
        logic [2*L-1:0] rt;
        int s, count, slot;
        bit release_ok, route_ok, legal;
        #1;
        s=(last_mode==0) ? 0 : ((last_mode==1) ? ((phase==7)?2:1) : ((phase==0)?3:4));
        release_ok=s inside {0,2,3}; route_ok=s inside {0,1,4};
        ns=state_ref; np=owner_ref; fresh='0; bridge='0; change='0;
        rv='0; ra='0; rr='0; ri='0; rt='0; count=0; slot=0; legal=1;
        for (int i=0;i<CELLS;i++) begin
            if (src[2*i+:2]==2) legal=0;
            if (tick && release_ok && count<L && owner_ref[2*i+:2]!=0) begin
                if (state_ref[2*i+:2]!=0) $fatal(1,"owner outside neutral");
                ns[2*i+:2]=owner_ref[2*i+:2]; np[2*i+:2]=0; change[i]=1; count++;
            end
        end
        for (int i=0;i<CELLS;i++) begin
            if (auto_en && history && slot<L && owner_ref[2*i+:2]==0 &&
                state_ref[2*i+:2]!=goal_ref[2*i+:2] &&
                ((state_ref[2*i+:2]==0) ? release_ok : route_ok)) begin
                rv[slot]=1; ri[B*slot+:B]=B'(i); rt[2*slot+:2]=goal_ref[2*i+:2];
                if (tick && count<L) begin
                    ra[slot]=1; fresh[i]=1; change[i]=1; count++;
                    if (state_ref[2*i+:2]!=0 && goal_ref[2*i+:2]!=0) begin
                        bridge[i]=1; ns[2*i+:2]=0; np[2*i+:2]=goal_ref[2*i+:2];
                    end else ns[2*i+:2]=goal_ref[2*i+:2];
                end else if (tick) rr[slot]=1;
                slot++;
            end
        end
        if ({state_out,owner,goal,qvalid}!=={state_ref,owner_ref,goal_ref,history} ||
            int'(sched)!=s || {lanes,addr,targets}!=={rv,ri,rt} ||
            {admit,deny,issued,routed,writes}!=={ra,rr,fresh,bridge,change} ||
            used!==count || remaining!==L-count || direct_count!==0 || overflow!==0 ||
            flags!=='1 || take!==(tick && valid && legal) || reject!==(tick && valid && !legal))
            $fatal(1,"pre-edge mismatch cells=%0d step=%0d",CELLS,steps);
        if (tick && valid && legal) begin goal_ref=src; history=1; end
        if (tick) phase=(phase+1)%8;
        last_mode=int'(mode); state_ref=ns; owner_ref=np;
        pulse();
        if ({state_out,owner,goal,qvalid}!=={state_ref,owner_ref,goal_ref,history})
            $fatal(1,"post-edge mismatch cells=%0d step=%0d",CELLS,steps);
        steps++;
    endtask

    task automatic trial(input int origin, r, m, action, pol);
        bank_t first, reverse_goal, replacement, incoming;
        mask_t owners;
        logic [1:0] sign_code, opposite;
        int service_phase, rounds, fresh_rank, seen_mode, seen_action;
        sign_code=pol ? 3 : 1; opposite=pol ? 1 : 3;
        first='0; reverse_goal='0; replacement={CELLS{sign_code}}; owners='0;
        for (int j=0;j<r;j++) begin
            int i;
            i=(origin+j)%CELLS; owners[i]=1;
            first[2*i+:2]=sign_code; reverse_goal[2*i+:2]=opposite;
            replacement[2*i+:2]=(j%2) ? 0 : sign_code;
        end
        fresh_rank=0;
        for (int i=0;i<CELLS;i++) if (!owners[i]) begin
            replacement[2*i+:2]=(fresh_rank%2) ? opposite : sign_code;
            fresh_rank++;
        end
        rst_n=0; tick=0; valid=0; auto_en=0; clear=0; src='0; mode=FRP_MODE_FREE;
        pulse(); rst_n=1; phase=0; last_mode=0; state_ref='0; owner_ref='0; goal_ref='0; history=0;
        tick=1; valid=1; auto_en=1; src=first; step();
        src=reverse_goal; step();
        auto_en=0; valid=0;
        service_phase=(m==1) ? 7 : 0;
        while ((phase+1)%8!=service_phase) step();
        mode=frp_m31_scheduler_mode_e'(m); src=replacement; valid=1; auto_en=1; step();
        if (owner!==reverse_goal || state_out!=='0 || goal!==replacement)
            $fatal(1,"route creation");
        owner_locations |= owners;

        tick=0; clear=1; src='0; step();
        tick=1; clear=(action!=1); valid=(action!=2); mode=FRP_MODE_FREE;
        incoming={CELLS{opposite}};
        if (action==1) incoming[2*origin+:2]=2;
        src=incoming; #1;
        if (lanes!=='1 || used!==L || $countones(admit)!=L-r || $countones(deny)!=r ||
            (issued & owners)!='0 || (writes & owners)!==owners)
            $fatal(1,"residual capacity cells=%0d owners=%0d",CELLS,r);
        case (sched)
            FRP_SCHED_FREE: seen_mode=0;
            FRP_SCHED_COMMIT: seen_mode=1;
            FRP_SCHED_EXCITE: seen_mode=2;
            default: $fatal(1,"wrong service phase");
        endcase
        seen_action=take ? 0 : (reject ? 1 : 2);
        if (seen_mode!=m || seen_action!=action || (take && reject)) $fatal(1,"service controls");
        for (int k=0;k<L;k++) begin
            if (targets[2*k+:2]!==((k%2) ? opposite : sign_code) || admit[k] !== (k<L-r))
                $fatal(1,"capacity cutoff cells=%0d owners=%0d lane=%0d",CELLS,r,k);
            hit[seen_mode][seen_action][$countones(owners)][targets[2*k+:2]==3][k]=1;
        end
        step();
        if (owner!=='0) $fatal(1,"old owner did not complete");
        for (int i=0;i<CELLS;i++) if (owners[i] && state_out[2*i+:2]!==opposite)
            $fatal(1,"saved polarity lost cell=%0d",i);

        auto_en=0; valid=0; clear=0; step();
        auto_en=1; rounds=0;
        while (state_out!==goal || owner!='0) begin
            if (rounds>=4*((CELLS+L-1)/L)+4) $fatal(1,"drain timeout");
            step(); rounds++;
        end
        step(); cases++;
    endtask

    initial begin
        int covered;
        for (int m=0;m<3;m++) for (int a=0;a<3;a++)
            for (int r=0;r<=L;r++) for (int p=0;p<2;p++)
                trial((r*3+a*5+m+p)%CELLS,r,m,a,p);
        for (int i=0;i<CELLS;i++) trial(i,(L+1)/2,i%3,(i/3)%3,i%2);
        covered=0;
        for (int m=0;m<3;m++) for (int a=0;a<3;a++)
            for (int r=0;r<=L;r++) for (int p=0;p<2;p++) begin
                if (hit[m][a][r][p]!=='1) $fatal(1,"missing service rank");
                covered+=$countones(hit[m][a][r][p]);
                $display("SERVICE_MAP mode=%0d action=%0d occupied=%0d negative=%0d lanes=%h",
                         m,a,r,p,hit[m][a][r][p]);
            end
        if (owner_locations!=='1) $fatal(1,"missing owner address");
        $display("PASS RETARGET_SERVICE cells=%0d lanes=%0d trials=%0d steps=%0d bins=%0d owners=%0d",
                 CELLS,L,cases,steps,covered,$countones(owner_locations));
        $finish;
    end
endmodule

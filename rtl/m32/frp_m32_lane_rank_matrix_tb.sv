// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"
`include "frp_m31_request_lanes.sv"

// Same observation edge and bin definition for the baseline and new workload.
module frp_m32_lane_rank_monitor #(parameter int N=8,L=2,B=3)(
    input logic clk, rst_n, tick,
    input logic [L-1:0] valid, input logic [L*B-1:0] addr, input logic [2*L-1:0] target
);
    bit [N-1:0] seen[L][4];
    always @(posedge clk) if (rst_n && tick) begin
        for (int k=0;k<L;k++) if (valid[k]) begin
            if (int'(addr[k*B+:B])>=N || target[2*k+:2]==2)
                $fatal(1,"invalid observed request");
            seen[k][target[2*k+:2]][addr[k*B+:B]]=1;
        end
    end
    final begin
        for (int k=0;k<L;k++)
            $display("RANK_MAP lane=%0d zero=%h pos=%h neg=%h",k,seen[k][0],seen[k][1],seen[k][3]);
    end
endmodule

bind frp_m32_registered_target_request_path frp_m32_lane_rank_monitor
    #(.N(CELLS),.L(REQUEST_LANES),.B(CELL_INDEX_BITS)) rank_monitor
    (.clk, .rst_n, .tick(tick_enable), .valid(phase_request_valid),
     .addr(phase_request_cell_index), .target(phase_request_target));

module frp_m32_lane_rank_matrix_tb #(parameter int CELLS=128);
    import frp_m31_pkg::*;
    localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
    typedef logic [CELLS-1:0] mask_t;
    typedef logic [2*CELLS-1:0] bank_t;
    bit clk, rst_n, tick, valid, auto_en;
    bank_t src, q, retained, pending, model;
    logic [L-1:0] lanes, accepted, rejected, neutral, paused;
    logic [L*B-1:0] addr;
    logic [2*L-1:0] targets;
    mask_t selected, routed;
    logic [31:0] changes;
    logic take, drop, enable;
    frp_m31_scheduler_state_e sched;
    int observations, deletions, masks, batches;

    frp_m32_registered_target_request_path #(.CELLS(CELLS)) path (
        .clk,.rst_n,.tick_enable(tick),.clear_counters(1'b0),.phase_target_valid(valid),
        .phase_target_source(src),.auto_target_enable(auto_en),.retained_state(retained),
        .pending_route(pending),.scheduler_state(sched),.registered_target_q(q),
        .capture_accepted(take),.capture_rejected(drop),.registered_request_enable(enable),
        .phase_request_valid(lanes),.phase_request_cell_index(addr),.phase_request_target(targets)
    );
    frp_m31_request_lanes #(.CELLS(CELLS)) sink (
        .tick_enable(tick),.scheduler_state(sched),.request_valid(lanes),.request_cell_index(addr),
        .request_target(targets),.state_q(retained),.target_q(q),.pending_route_q(pending),
        .request_accept(accepted),.request_reject(rejected),.request_neutralized(neutral),
        .request_reject_tick_disabled(paused),.accepted_cell_mask(selected),
        .neutral_routed_cell_mask(routed),.accepted_changes(changes)
    );

    task automatic pulse();
        #1; clk=1; #1; clk=0; #1;
    endtask
    task automatic capture(input bank_t word);
        src=word; valid=1; tick=1; #1;
        if ({take,drop}!==2'b10) $fatal(1,"capture refused");
        pulse(); model=word; valid=0;
        if (q!==model) $fatal(1,"captured bank mismatch");
    endtask
    task automatic observe(input mask_t available);
        mask_t eligible, want_cells, want_routes, prior;
        logic [L-1:0] vm, nm;
        logic [L*B-1:0] am;
        logic [2*L-1:0] tm;
        int rank;
        eligible='0; want_cells='0; want_routes='0;
        vm='0; nm='0; am='0; tm='0;
        for (int i=0;i<CELLS;i++) begin
            if (available[i]) begin
                if (model[2*i+:2]==0) retained[2*i+:2]=(i%2) ? 3 : 1;
                else retained[2*i+:2]=(i%2) ? (model[2*i+:2]^2'b10) : 0;
                pending[2*i+:2]=0;
                if (auto_en && (sched==FRP_SCHED_FREE ||
                    (retained[2*i+:2]==0 && sched inside {FRP_SCHED_COMMIT,FRP_SCHED_EXCITE}) ||
                    (retained[2*i+:2]!=0 && sched inside {FRP_SCHED_BALANCE,FRP_SCHED_NEUTRALIZE})))
                    eligible[i]=1;
            end else begin
                retained[2*i+:2]=(i%2) ? model[2*i+:2] : 0;
                pending[2*i+:2]=(i%2) ? 0 : 1;
            end
        end
        for (int i=0;i<CELLS;i++) if (eligible[i]) begin
            prior=(mask_t'(1)<<i)-1'b1;
            rank=$countones(prior & eligible);
            if (rank<L) begin
                vm[rank]=1; am[B*rank+:B]=B'(i); tm[2*rank+:2]=model[2*i+:2];
                nm[rank]=(retained[2*i+:2]!=0 && model[2*i+:2]!=0);
                want_cells[i]=1; want_routes[i]=nm[rank];
            end
        end
        #1;
        if (q!==model || enable!==auto_en || {lanes,addr,targets}!=={vm,am,tm})
            $fatal(1,"rank projection cells=%0d step=%0d",CELLS,observations);
        if ((tick && (accepted!==vm || selected!==want_cells || neutral!==nm ||
                      routed!==want_routes || changes!==$countones(vm))) ||
            (!tick && (accepted!='0 || selected!='0 || changes!=0 || paused!==vm)) || rejected!=='0)
            $fatal(1,"downstream acceptance cells=%0d step=%0d",CELLS,observations);
        pulse(); observations++;
    endtask

    initial begin
        mask_t candidates, before_service;
        bank_t word;
        int rounds;
        sched=FRP_SCHED_FREE; auto_en=1; rst_n=0; pulse(); rst_n=1;
        for (int symbol=0;symbol<4;symbol++) if (symbol!=2) begin
            capture({CELLS{2'(symbol)}});
            for (int p=0;p<CELLS;p++) for (int k=0;k<L && k<=p;k++) begin
                candidates='1;
                for (int i=0;i<p-k;i++) candidates[i]=0;
                observe(candidates);
                candidates[p]=0; observe(candidates);
                candidates[p]=1; observe(candidates);
                deletions++;
            end
        end
        for (int i=0;i<CELLS;i++)
            case (i%3)
                0: word[2*i+:2]=0;
                1: word[2*i+:2]=1;
                2: word[2*i+:2]=3;
            endcase
        capture(word);
        if (CELLS<=16) begin
            for (int m=0;m<(1<<CELLS);m++) begin observe(mask_t'(m)); masks++; end
        end
        for (int p=0;p<CELLS;p++) begin
            for (int s=0;s<8;s++) begin
                candidates='0;
                for (int j=0;j<L+1;j++) candidates[(p+j)%CELLS]=1;
                sched=frp_m31_scheduler_state_e'(s); observe(candidates);
            end
        end
        sched=FRP_SCHED_FREE; candidates='1;
        tick=0; observe(candidates); tick=1;
        auto_en=0; observe(candidates); auto_en=1;
        src=model; src[2*(CELLS-1)+:2]=2; valid=1; #1;
        if ({take,drop}!==2'b01) $fatal(1,"corrupt update");
        observe(candidates); valid=0;
        rounds=0;
        while (candidates!='0) begin
            observe(candidates); before_service=selected;
            if (before_service=='0 || (before_service & ~candidates)!='0)
                $fatal(1,"backlog did not advance");
            candidates &= ~before_service; rounds++;
        end
        observe('0); batches=rounds;
        if (batches!=(CELLS+L-1)/L) $fatal(1,"batch count");
        $display("PASS LANE_RANK cells=%0d lanes=%0d checks=%0d deletions=%0d masks=%0d batches=%0d",
                 CELLS,L,observations,deletions,masks,batches);
        $finish;
    end
endmodule

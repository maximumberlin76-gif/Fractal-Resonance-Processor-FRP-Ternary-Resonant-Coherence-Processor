// SPDX-License-Identifier: Apache-2.0
`include "frp_m32_registered_target_request_path.sv"

module frp_m32_target_recovery_formal #(parameter int CELLS=128, CW=32, WATCH=CELLS-1, OPEN_BANKS=0) (
    input logic clk, rst_n, tick, valid, clear, auto_en,
    input logic [2*CELLS-1:0] src, free_state, free_pending,
    input logic [1:0] state0, statew, pending0, pendingw,
    input frp_m31_pkg::frp_m31_scheduler_state_e sched,
    output wire [6:0] bad,
    output wire [8:0] witness
);
    localparam int L=frp_m31_pkg::frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
    typedef logic [2*CELLS-1:0] bank_t;
    bank_t q, retained, pending;
    always_comb begin
        retained=OPEN_BANKS ? free_state : '0;
        pending=OPEN_BANKS ? free_pending : {CELLS{2'b01}};
        retained[1:0]=state0; retained[2*WATCH+:2]=statew;
        pending[1:0]=pending0; pending[2*WATCH+:2]=pendingw;
    end
    wire hist, source_ok, bank_ok, accept, reject, enable;
    wire [CW-1:0] ac, rc;
    wire [L-1:0] lanes;
    wire [L*B-1:0] addr;
    wire [2*L-1:0] targets;

    frp_m32_registered_target_request_path #(.CELLS(CELLS), .COUNTER_BITS(CW)) dut (
        .clk, .rst_n, .tick_enable(tick), .clear_counters(clear),
        .phase_target_valid(valid), .phase_target_source(src), .auto_target_enable(auto_en),
        .retained_state(retained), .pending_route(pending), .scheduler_state(sched),
        .registered_target_q(q), .registered_target_valid_q(hist),
        .phase_target_domain_valid(source_ok), .registered_target_domain_valid(bank_ok),
        .capture_accepted(accept), .capture_rejected(reject), .registered_request_enable(enable),
        .accepted_capture_events_q(ac), .rejected_capture_events_q(rc),
        .phase_request_valid(lanes), .phase_request_cell_index(addr), .phase_request_target(targets)
    );

    // For each 2-bit symbol, 10 is the only reserved encoding.
    function automatic logic legal(input bank_t v);
        return ((v >> 1) & ~v & {CELLS{2'b01}}) == '0;
    endfunction

    wire take = tick && valid && legal(src);
    wire drop = tick && valid && !legal(src);
    wire issue = auto_en && hist && legal(q);
    bank_t expected_q;
    logic expected_hist;
    logic [CW-1:0] expected_ac, expected_rc;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            expected_q <= '0; expected_hist <= 0;
            expected_ac <= '0; expected_rc <= '0;
        end else begin
            expected_q <= take ? src : q;
            expected_hist <= hist || take;
            expected_ac <= clear ? '0 : ac + CW'(take && !(&ac));
            expected_rc <= clear ? '0 : rc + CW'(drop && !(&rc));
        end
    end

    assign bad[0] = {source_ok,bank_ok} != {legal(src),legal(q)};
    assign bad[1] = {accept,reject} != {take,drop};
    assign bad[2] = enable != issue || (!issue && {lanes,addr,targets}!='0);
    assign bad[3] = {q,hist} != {expected_q,expected_hist};
    assign bad[4] = ac != expected_ac;
    assign bad[5] = rc != expected_rc;

    // Only cells 0 and WATCH can compete. Check every lane, including unused lanes.
    import frp_m31_pkg::*;
    function automatic logic eligible(input logic [1:0] state_word, goal, owner);
        if (owner!=0 || state_word==2 || goal==2 || state_word==goal) return 0;
        if (state_word==0) return sched inside {FRP_SCHED_FREE,FRP_SCHED_COMMIT,FRP_SCHED_EXCITE};
        return sched inside {FRP_SCHED_FREE,FRP_SCHED_BALANCE,FRP_SCHED_NEUTRALIZE};
    endfunction
    logic [L-1:0] vm;
    logic [L*B-1:0] am;
    logic [2*L-1:0] tm;
    always_comb begin
        vm='0; am='0; tm='0;
        if (issue && eligible(state0,q[1:0],pending0)) begin
            vm[0]=1; tm[1:0]=q[1:0];
        end
        if (issue && eligible(statew,q[2*WATCH+:2],pendingw)) begin
            if (vm[0]) begin
                vm[1]=1; am[B+:B]=B'(WATCH); tm[2+:2]=q[2*WATCH+:2];
            end else begin
                vm[0]=1; am[0+:B]=B'(WATCH); tm[0+:2]=q[2*WATCH+:2];
            end
        end
    end
    assign bad[6] = !OPEN_BANKS && pending0!=2 && pendingw!=2 && {lanes,addr,targets}!={vm,am,tm};

    // A reserved code at WATCH becomes a legal request on the next sample.
    localparam bank_t LAST_BAD = bank_t'(2) << (2*WATCH);
    localparam bank_t LAST_POS = bank_t'(1) << (2*WATCH);
    assign witness[0] = rst_n && hist && q==LAST_BAD && auto_en && take && src==LAST_POS && !enable;
    assign witness[1] = rst_n && hist && q==LAST_POS && issue && statew==0 && pendingw==0 &&
                        lanes==1 && addr==B'(WATCH) && targets==1;
    assign witness[2] = rst_n && hist && q==LAST_BAD && src==LAST_BAD && drop && !enable;
    assign witness[3] = rst_n && (&ac) && take && !clear;
    assign witness[4] = rst_n && (&rc) && drop && !clear;
    assign witness[5] = witness[0] && clear && (ac!='0 || rc!='0);
    assign witness[6] = rst_n && hist && q==LAST_POS && ac=='0 && rc=='0;
    assign witness[7] = rst_n && lanes==3 && addr[0+:B]==0 && addr[B+:B]==B'(WATCH) &&
                        targets[0+:2]==3 && targets[2+:2]==1;
    assign witness[8] = !rst_n && !hist && q=='0 && ac=='0 && rc=='0;
endmodule

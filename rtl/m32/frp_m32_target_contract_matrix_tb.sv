// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"

module frp_m32_target_contract_matrix_tb #(parameter int CELLS=128, CW=4);
    import frp_m31_pkg::*;
    localparam int L=frp_calc_request_lanes(CELLS), B=$clog2(CELLS);
    typedef logic [2*CELLS-1:0] bank_t;
    bit clk, rst_n, tick, clear, valid, auto_en, full;
    bank_t src, current, pending, q, model, corrupted;
    logic qvalid, src_ok, q_ok, take, reject, enable;
    logic [CW-1:0] accepts, rejects, ac_ref, rc_ref;
    bit history;
    logic [L-1:0] lanes;
    logic [L*B-1:0] addresses;
    logic [2*L-1:0] targets;
    frp_m31_scheduler_state_e sched;
    int steps, rows, faults;

    frp_m32_registered_target_request_path #(.CELLS(CELLS), .COUNTER_BITS(CW)) dut (
        .clk, .rst_n, .tick_enable(tick), .clear_counters(clear),
        .phase_target_valid(valid), .phase_target_source(src), .auto_target_enable(auto_en),
        .retained_state(current), .pending_route(pending), .scheduler_state(sched),
        .registered_target_q(q), .registered_target_valid_q(qvalid),
        .phase_target_domain_valid(src_ok), .registered_target_domain_valid(q_ok),
        .capture_accepted(take), .capture_rejected(reject), .registered_request_enable(enable),
        .accepted_capture_events_q(accepts), .rejected_capture_events_q(rejects),
        .phase_request_valid(lanes), .phase_request_cell_index(addresses), .phase_request_target(targets)
    );

    function automatic bit permit(input int s, k);
        case (k)
            0,5: return s < 5;
            1,4: return s inside {0,2,3};
            2,3: return s inside {0,1,4};
            default: return 0;
        endcase
    endfunction

    task automatic primitives();
        int k, dest, expected, bits_needed;
        for (int s=0; s<4; s++) for (int t=0; t<4; t++) for (int p=0; p<4; p++) begin
            if (s==2 || t==2 || p==2) begin k=7; dest=s; end
            else if (s==0 && p!=0) begin k=4; dest=p; end
            else if (s==t) begin k=0; dest=s; end
            else if (s==0) begin k=1; dest=t; end
            else if (t==0) begin k=2; dest=0; end
            else begin k=3; dest=0; end
            if (frp_classify_transition(2'(s),2'(t),2'(p)) !== 4'(k) ||
                frp_transition_selected_target(2'(s),2'(t),2'(p)) !== 2'(dest))
                $fatal(1,"transition s=%0d t=%0d p=%0d",s,t,p);
            rows++;
        end
        for (int s=0;s<8;s++) for (int k=0;k<16;k++) begin
            if (frp_scheduler_allows_transition(frp_m31_scheduler_state_e'(s),
                    frp_m31_transition_class_e'(k)) !== permit(s,k) ||
                frp_transition_consumes_capacity(frp_m31_transition_class_e'(k)) !== (k inside {[1:4]}))
                $fatal(1,"scheduler s=%0d class=%0d",s,k);
            rows++;
        end
        for (int m=0;m<4;m++) for (int p=0;p<8;p++) begin
            case (m)
                0: expected=0;
                1: expected=(p==7) ? 2 : 1;
                2: expected=(p==0) ? 3 : 4;
                default: expected=7;
            endcase
            if (frp_decode_scheduler_state(frp_m31_scheduler_mode_e'(m),3'(p)) !== 3'(expected))
                $fatal(1,"mode=%0d phase=%0d",m,p);
            rows++;
        end
        for (int n=1;n<=128;n++) begin
            bits_needed=1;
            while ((1<<bits_needed)<n) bits_needed++;
            if (frp_calc_cell_index_bits(n)!=bits_needed ||
                frp_calc_request_lanes(n)!=((n<2) ? 1 : (n+2)/4) ||
                frp_calc_packed_state_bits(n)!=2*n || frp_cell_msb(n-1)!=2*n-1 ||
                frp_cell_lsb(n-1)!=2*n-2) $fatal(1,"geometry n=%0d",n);
            rows++;
        end
    endtask

    task automatic downstream_fault(input int p);
        int slot;
        logic [L*B-1:0] wanted_addr;
        logic [2*L-1:0] wanted_target;
        wanted_addr='0; wanted_target='0; slot=0;
        for (int i=0;i<CELLS;i++) if (i!=p && slot<L) begin
            wanted_addr[B*slot+:B]=B'(i);
            wanted_target[2*slot+:2]=model[2*i+:2]; slot++;
        end
        force dut.registered_request_enable=1;
        #1;
        if (q_ok!==0 || lanes!=='1 || addresses!==wanted_addr || targets!==wanted_target)
            $fatal(1,"adapter isolation cell=%0d",p);
        release dut.registered_request_enable;
        #1;
        if (enable!==0 || {lanes,addresses,targets}!=='0) $fatal(1,"gate release cell=%0d",p);
    endtask

    task automatic cycle(input bit legal);
        logic [L-1:0] vm;
        logic [L*B-1:0] am;
        logic [2*L-1:0] tm;
        int used, a, b;
        #1; vm='0; am='0; tm='0; used=0;
        for (int i=0;i<CELLS;i++) begin
            a=current[2*i+:2]; b=model[2*i+:2];
            if (history && auto_en && a!=2 && a!=b && pending[2*i+:2]==0 && used<L &&
                permit(int'(sched),(a==0) ? 1 : ((b==0) ? 2 : 3))) begin
                vm[used]=1; am[used*B+:B]=B'(i); tm[used*2+:2]=2'(b); used++;
            end
        end
        if ({q,qvalid,accepts,rejects} !== {model,history,ac_ref,rc_ref} ||
            {src_ok,q_ok,take,reject,enable} !== {legal,1'b1,(tick&&valid&&legal),
                (tick&&valid&&!legal),(history&&auto_en)} ||
            {lanes,addresses,targets} !== {vm,am,tm}) $fatal(1,"pre-edge step=%0d",steps);
        if (tick && valid && legal) begin model=src; history=1; end
        if (clear) begin ac_ref=0; rc_ref=0; end
        else if (tick && valid) begin
            if (legal && !(&ac_ref)) ac_ref++;
            if (!legal && !(&rc_ref)) rc_ref++;
        end
        clk=1; #1; clk=0; #1;
        if ({q,qvalid,accepts,rejects} !== {model,history,ac_ref,rc_ref})
            $fatal(1,"post-edge step=%0d",steps);
        steps++;
    endtask

    initial begin
        full=$test$plusargs("full");
        if (full) primitives();
        rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1;
        model='0; current='0; pending='0; ac_ref=0; rc_ref=0;
        for (int p=0;p<CELLS;p++) for (int sign_id=0;sign_id<2;sign_id++) begin
            src=sign_id ? {CELLS{2'b11}} : {CELLS{2'b01}};
            current='0; pending='0; sched=FRP_SCHED_FREE;
            valid=1; tick=1; auto_en=1; clear=0; cycle(1);
            for (int i=0;i<CELLS;i++) begin
                case ((i+CELLS-p)%CELLS%4)
                    0: current[2*i+:2]=sign_id ? 1 : 3;
                    1: pending[2*i+:2]=1;
                    2: current[2*i+:2]=src[2*i+:2];
                    default: current[2*i+:2]=0;
                endcase
            end
            src[2*p+:2]=2'b10;
            for (int s=0;s<8;s++) begin
                sched=frp_m31_scheduler_state_e'(s);
                tick=(s!=1); valid=(s!=2); auto_en=(s!=3); clear=(s==7 && p==0);
                cycle(0);
            end
            // Make the selected address the sole eligible lane, then block that address.
            current=model; current[2*p+:2]=0; pending='0;
            auto_en=1; sched=FRP_SCHED_FREE; tick=0; valid=1; clear=0; cycle(0);
            pending[2*p+:2]=sign_id ? 3 : 1; cycle(0);
            pending='0; current[2*p+:2]=2; cycle(0);
            if (full) begin
                sched=FRP_SCHED_FREE; current='0; pending='0; auto_en=1; tick=0; clear=0; #1;
                if (lanes!=='1 || !enable) $fatal(1,"pre-fault requests cell=%0d",p);
                corrupted=model; corrupted[2*p+:2]=2'b10;
                force dut.u_registered_target_boundary.registered_target_q=corrupted; #1;
                if (q!==corrupted || !qvalid || q_ok!==0 || enable!==0 ||
                    {lanes,addresses,targets}!=='0) $fatal(1,"fault cell=%0d",p);
                downstream_fault(p);
                release dut.u_registered_target_boundary.registered_target_q;
                // Recover the register through an accepted capture on the next clock.
                tick=1; valid=1; src=model; clear=1; #1;
                if (!take || reject) $fatal(1,"recovery capture cell=%0d",p);
                clk=1; #1; clk=0; #1; ac_ref=0; rc_ref=0;
                if (q!==model || !q_ok || !enable || lanes!=='1 || accepts!==0 || rejects!==0)
                    $fatal(1,"recovery cell=%0d",p);
                faults++;
            end
        end
        // Exercise both counter limits naturally on the small-width profile.
        sched=FRP_SCHED_FREE; tick=1; valid=1; clear=0; auto_en=1;
        if (full && CW==32) begin
            force dut.u_registered_target_boundary.accepted_capture_events_q=32'hfffffffe;
            force dut.u_registered_target_boundary.rejected_capture_events_q=32'hfffffffe;
            #1; release dut.u_registered_target_boundary.accepted_capture_events_q;
            release dut.u_registered_target_boundary.rejected_capture_events_q;
            ac_ref='1; ac_ref--; rc_ref=ac_ref;
        end
        src='0; repeat (20) cycle(1);
        src[1:0]=2'b10; repeat (20) cycle(0);
        if ((CW==4 || full) && !((&ac_ref) && (&rc_ref))) $fatal(1,"saturation");
        $display("PASS TARGET_MATRIX cells=%0d bits=%0d full=%0d rows=%0d steps=%0d faults=%0d",
                 CELLS,CW,full,rows,steps,faults);
        $finish;
    end
endmodule

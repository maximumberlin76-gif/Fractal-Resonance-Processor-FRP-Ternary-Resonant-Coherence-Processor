// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Integrated execution-stage regression for the M31 core used by M32.
// A closed batch of CELLS accepted polarity routes drains in CELLS/LANES
// activation opportunities. New input may compete for capacity, request a
// conflicting target or repeat a cell, but creates no new route during drain.
// Paused clocks do not count as processor ticks or service opportunities.
// The reference tracks ternary symbols, saved destinations and logical changes.
// Compile from the repository root with --binary --timing --assert,
// -Irtl/m31 --top-module frp_m31_pending_service_tb -GCELLS=8 (or 16,32).
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"

module frp_m31_pending_service_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int LANES=CELLS/4, IB=$clog2(CELLS);
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE;
  frp_m31_scheduler_mode_e scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [LANES-1:0] request_valid=0;
  logic [LANES*IB-1:0] request_cell_index=0;
  logic [LANES*2-1:0] request_target=0;
  logic [CELLS*2-1:0] target_q=0;
  wire [CELLS*2-1:0] state_out, pending_route_out;
  wire [LANES-1:0] request_accept, request_reject;
  wire [CELLS-1:0] accepted_change_mask;
  wire [31:0] ticks_recorded_q, accepted_changes;
  wire [31:0] actual_direct_events, reserved_state_events, queue_overflow_events;
  wire [FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;

  frp_m31_execution_core #(.CELLS(CELLS), .REQUEST_LANES(LANES)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters), .scheduler_mode(scheduler_mode),
    .request_valid(request_valid), .request_cell_index(request_cell_index),
    .request_target(request_target), .target_q(target_q),
    .state_out(state_out), .pending_route_out(pending_route_out),
    .scheduler_mode_q(scheduler_mode_q), .scheduler_state_q(scheduler_state_q),
    .ticks_recorded_q(ticks_recorded_q),
    .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(),
    .scheduler_count_neutralize_q(),
    .request_accept(request_accept), .request_reject(request_reject),
    .accepted_cell_mask(), .neutral_routed_cell_mask(),
    .accepted_change_mask(accepted_change_mask), .accepted_changes(accepted_changes),
    .capacity_remaining(), .capacity_exhausted(), .switch_load_numerator(),
    .requested_direct_events(), .prevented_direct_events(), .neutral_routed_events(),
    .actual_direct_events(actual_direct_events), .reserved_state_events(reserved_state_events),
    .queue_overflow_events(queue_overflow_events), .invariant_flags(invariant_flags)
  );

  int state_ref[CELLS], pending_ref[CELLS], destination[CELLS];
  int created_bin[3][CELLS][2], completed_bin[3][CELLS][2];
  int service_rank[CELLS];
  int mode_ref=0, tick_ref=0, counter_ref=0, case_id=0;
  int drain_mode=0, opportunities=0, drain_ticks=0;
  bit draining=0;
  longint unsigned checks=0, cycles=0, created=0, completed=0;
  longint unsigned paused_routes=0, blocked_routes=0, busy_requests=0;
  longint unsigned capacity_rejects=0, duplicate_rejects=0, clears_with_pending=0;
  longint unsigned signature=64'hcbf29ce484222325;

  function automatic logic [1:0] encode(input int value);
    case(value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1,"Invalid reference symbol"); return 2'b10; end
    endcase
  endfunction

  function automatic int decode(input logic [1:0] value);
    case(value)
      2'b11: return -1;
      2'b00: return 0;
      2'b01: return 1;
      default: begin $fatal(1,"Reserved or unknown symbol"); return 2; end
    endcase
  endfunction

  function automatic int schedule(input int mode, input int tick);
    case(mode)
      0: return 0;
      1: return (tick%8==7) ? 2 : 1;
      2: return (tick%8==0) ? 3 : 4;
      default: begin $fatal(1,"Invalid reference mode"); return 7; end
    endcase
  endfunction

  function automatic int pending_count();
    int count;
    count=0;
    for(int c=0;c<CELLS;c++) if(pending_ref[c]!=0) count++;
    return count;
  endfunction

  task automatic equal(input longint unsigned got, expected, input string label);
    checks++;
    if(got!==expected)
      $fatal(1,"SERVICE N=%0d case=%0d cycle=%0d %s got=%h expected=%h",
             CELLS,case_id,cycles,label,got,expected);
  endtask

  task automatic set_lane(input int lane, cell_index, value);
    request_valid[lane]=1;
    request_cell_index[lane*IB+:IB]=IB'(cell_index);
    request_target[lane*2+:2]=encode(value);
  endtask

  task automatic step(input bit enabled);
    int next_state[CELLS], next_pending[CELLS];
    int sched, used, old_pending, changes, cell_index, goal, prior_state;
    bit activate, neutralize, allowed;
    bit claimed[CELLS];
    logic [LANES-1:0] accept_ref, reject_ref;
    logic [CELLS-1:0] changed_ref;
    tick_enable=enabled;
    #2;
    sched=schedule(mode_ref,tick_ref);
    equal(64'(scheduler_state_q),64'(sched),"scheduler cadence");
    equal(64'(scheduler_mode_q),64'(mode_ref),"registered scheduler mode");
    activate=(sched==0 || sched==2 || sched==3);
    neutralize=(sched==0 || sched==1 || sched==4);
    old_pending=pending_count();
    if(clear_counters && old_pending>0) clears_with_pending++;
    if(draining && enabled) begin
      drain_ticks++;
      if(activate) opportunities++;
    end
    used=0; accept_ref=0; reject_ref=0; changed_ref=0;
    for(int c=0;c<CELLS;c++) begin
      next_state[c]=state_ref[c]; next_pending[c]=pending_ref[c]; claimed[c]=0;
      equal(64'(state_out[c*2+:2]),64'(encode(state_ref[c])),"pre-edge state");
      equal(64'(pending_route_out[c*2+:2]),64'(encode(pending_ref[c])),"pre-edge route");
      if(pending_ref[c]!=0) begin
        equal(64'(state_ref[c]),0,"active zero retains pending destination");
        if(enabled && activate && used<LANES) begin
          next_state[c]=pending_ref[c]; next_pending[c]=0;
          changed_ref[c]=1; used++; completed++;
          if(draining) begin
            equal(64'(opportunities),64'(service_rank[c]),"bounded service rank");
            equal(64'(next_state[c]),64'(destination[c]),"saved destination executes");
            completed_bin[drain_mode][c][destination[c]>0]++;
          end
        end else if(!enabled) paused_routes++;
        else blocked_routes++;
      end
    end
    for(int lane=0;lane<LANES;lane++) begin
      if(request_valid[lane]) begin
        cell_index=int'(request_cell_index[lane*IB+:IB]);
        goal=decode(request_target[lane*2+:2]);
        prior_state=state_ref[cell_index];
        allowed=(prior_state==goal) || ((prior_state==0) ? activate : neutralize);
        // Disabled ticks produce no public request acknowledgement.
        if(!enabled) reject_ref[lane]=0;
        else if(claimed[cell_index]) begin
          reject_ref[lane]=1; duplicate_rejects++;
        end else if(pending_ref[cell_index]!=0) begin
          reject_ref[lane]=1; busy_requests++;
        end else if(!allowed) reject_ref[lane]=1;
        else begin
          claimed[cell_index]=1;
          if(prior_state!=goal && used>=LANES) begin
            reject_ref[lane]=1; capacity_rejects++;
          end else begin
            accept_ref[lane]=1;
            if(prior_state!=goal) begin
              used++; changed_ref[cell_index]=1;
              if(prior_state*goal==-1) begin
                if(draining) $fatal(1,"Drain contract: new route admitted");
                next_state[cell_index]=0; next_pending[cell_index]=goal;
                created++; created_bin[drain_mode][cell_index][goal>0]++;
              end else next_state[cell_index]=goal;
            end
          end
        end
      end
    end
    equal(64'(request_accept),64'(accept_ref),"request acceptance");
    equal(64'(request_reject),64'(reject_ref),"request rejection");
    equal(64'(accepted_change_mask),64'(changed_ref),"logical change mask");
    equal(64'(accepted_changes),64'(used),"capacity accounting");
    equal(64'(actual_direct_events),0,"direct event count");
    equal(64'(reserved_state_events),0,"reserved event count");
    equal(64'(queue_overflow_events),0,"overflow event count");
    equal(64'(invariant_flags),64'((1<<FRP_M31_INVARIANT_FLAGS)-1),"core invariants");
    if(clear_counters) counter_ref=0;
    if(enabled) begin tick_ref++; counter_ref++; end
    mode_ref=int'(scheduler_mode);
    clk=1; #2;
    changes=0;
    for(int c=0;c<CELLS;c++) begin
      equal(64'(state_out[c*2+:2]),64'(encode(next_state[c])),"retained writeback");
      equal(64'(pending_route_out[c*2+:2]),64'(encode(next_pending[c])),"pending writeback");
      if(state_ref[c]*decode(state_out[c*2+:2])==-1)
        $fatal(1,"Forbidden direct polarity transition");
      if(state_ref[c]!=next_state[c]) changes++;
      state_ref[c]=next_state[c]; pending_ref[c]=next_pending[c];
      signature=(signature ^ (64'(c)<<8) ^ 64'(encode(next_state[c]))
                 ^ (64'(encode(next_pending[c]))<<2))*64'h100000001b3;
    end
    equal(64'(changes),64'(used),"observed logical transitions");
    equal(64'(ticks_recorded_q),64'(counter_ref),"counter clear preserves progress");
    if(draining && (opportunities>4 || drain_ticks>32))
      $fatal(1,"Bounded batch service exceeded");
    clk=0; #1; cycles++;
  endtask

  task automatic reset_case();
    request_valid=0; target_q=0; tick_enable=0; clear_counters=0;
    scheduler_mode=FRP_MODE_FREE; draining=0;
    rst_n=0; #2; clk=1; #2; clk=0; #1; rst_n=1;
    mode_ref=0; tick_ref=0; counter_ref=0;
    for(int c=0;c<CELLS;c++) begin state_ref[c]=0; pending_ref[c]=0; end
    step(0);
  endtask

  task automatic interference(input int serial);
    int victim, c;
    victim=-1;
    for(int i=CELLS-1;i>=0;i--) if(pending_ref[i]!=0 && victim<0) victim=i;
    request_valid=0;
    for(int lane=0;lane<LANES;lane++) begin
      c=(serial+lane*3)%CELLS;
      if(serial%3==0 && victim>=0) c=victim;
      if(pending_ref[c]!=0)
        set_lane(lane,c,(serial%2==0) ? -pending_ref[c] : 0);
      else
        set_lane(lane,c,(state_ref[c]==0) ? destination[c] : 0);
    end
    for(int i=0;i<CELLS;i++) target_q[i*2+:2]=encode(((i+serial)%3)-1);
  endtask

  initial begin : regression
    int cell_index, polarity, guard, serial;
    if(!(CELLS inside {8,16,32})) $fatal(1,"Supported CELLS: 8,16,32");
    for(int mode=0;mode<3;mode++)
      for(int direction=0;direction<2;direction++)
        for(int permutation=0;permutation<4;permutation++)
          for(int epoch=0;epoch<4;epoch++) begin
            case_id++; drain_mode=mode; reset_case();
            polarity=(direction==0) ? -1 : 1;
            for(int c=0;c<CELLS;c++) begin
              destination[c]=-polarity; service_rank[c]=1+c/LANES;
            end
            for(int group_index=0;group_index<4;group_index++) begin
              request_valid=0;
              for(int lane=0;lane<LANES;lane++)
                set_lane(lane,group_index*LANES+lane,polarity);
              step(1);
            end
            request_valid=0; scheduler_mode=FRP_MODE_7_1; step(0);
            guard=0;
            while(scheduler_state_q!=FRP_SCHED_COMMIT) begin
              step(1); guard++; if(guard>8) $fatal(1,"Fill alignment timeout");
            end
            step(1);
            for(int group_index=0;group_index<4;group_index++) begin
              request_valid=0;
              for(int lane=0;lane<LANES;lane++) begin
                cell_index=((group_index*LANES+lane)*(2*permutation+1)+epoch)%CELLS;
                set_lane(lane,cell_index,-polarity);
              end
              step(1);
            end
            equal(64'(pending_count()),64'(CELLS),"full retained route batch");
            request_valid=0; scheduler_mode=frp_m31_scheduler_mode_e'(mode); step(0);
            opportunities=0; drain_ticks=0; draining=1;
            for(int pause_index=0;pause_index<17+epoch;pause_index++) begin
              interference(pause_index); clear_counters=(pause_index%3==0); step(0);
            end
            serial=0;
            while(pending_count()!=0) begin
              interference(serial); clear_counters=(serial%5==0);
              step(1); serial++;
              if(serial>32) $fatal(1,"Drain watchdog expired");
              if(pending_count()!=0 && serial%3==0) begin
                interference(serial+37); step(0);
              end
            end
            equal(64'(opportunities),4,"four service opportunities");
            draining=0; clear_counters=0; request_valid=0;
            // Probe ascending lane ownership after the batch has completed.
            scheduler_mode=FRP_MODE_FREE; step(0);
            for(int lane=0;lane<LANES;lane++) set_lane(lane,epoch%CELLS,0);
            step(1);
          end
    for(int m=0;m<3;m++) for(int c=0;c<CELLS;c++) for(int d=0;d<2;d++) begin
      equal(64'(created_bin[m][c][d]),16,"indexed route creation coverage");
      equal(64'(completed_bin[m][c][d]),16,"indexed route service coverage");
    end
    equal(created,completed,"all accepted routes complete");
    if(paused_routes==0 || blocked_routes==0 || busy_requests==0
       || capacity_rejects==0 || duplicate_rejects==0 || clears_with_pending==0)
      $fatal(1,"Missing contention or retention coverage");
    $display("PASS PENDING_SERVICE N=%0d cases=%0d checks=%0d cycles=%0d signature=%016h",
             CELLS,case_id,checks,cycles,signature);
    $display("ROUTES N=%0d created=%0d completed=%0d service_bound=4 direct=0",
             CELLS,created,completed);
    $display("CONTENTION N=%0d paused_routes=%0d blocked_routes=%0d busy_requests=%0d capacity_rejects=%0d duplicate_rejects=%0d clears_with_pending=%0d",
             CELLS,paused_routes,blocked_routes,busy_requests,capacity_rejects,
             duplicate_rejects,clears_with_pending);
    $finish;
  end

  initial begin #1000000; $fatal(1,"Pending service watchdog expired"); end
endmodule

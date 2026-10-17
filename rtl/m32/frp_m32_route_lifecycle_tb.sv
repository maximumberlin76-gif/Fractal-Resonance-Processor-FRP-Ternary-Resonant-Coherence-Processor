// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Route lifecycle accounting over the M32 cross-feedback workload.
// Observe testbench wires connected to public DUT ports; no state forcing.
// Each retained route receives an ID and keeps its original destination.
// created = completed + reset_cancelled + pending is checked after every sample.
// Service age counts enabled FREE/COMMIT/EXCITE edges after route creation.
// Drain service is bounded while automatic and external admissions are disabled.
// Paused and balancing edges are counted separately from service opportunities.
// Compile with --binary --timing --assert -Irtl/m31 -Irtl/m32
// --top-module frp_m32_route_lifecycle_tb -GCELLS=8 (or 16,32,64).
// Run the complete workload with +CASE=0; +SEED selects backlog stimuli.
`timescale 1ns/1ps
`include "frp_m32_cross_feedback_tb.sv"

module frp_m32_route_lifecycle_tb #(parameter int CELLS=8);
  localparam int LANES=CELLS/4;
  localparam int SERVICE_BOUND=(CELLS+LANES-1)/LANES;
  frp_m32_cross_feedback_tb #(.CELLS(CELLS)) stimulus();

  bit live[CELLS];
  logic [1:0] destination[CELLS];
  longint unsigned route_id[CELLS];
  int origin_mode[CELLS];
  int wall_age[CELLS], enabled_age[CELLS], service_age[CELLS], drain_age[CELLS];
  longint unsigned created=0, completed=0, reset_cancelled=0;
  longint unsigned checks=0, samples=0, reset_events=0, occupied_resets=0;
  longint unsigned paused_holds=0, cadence_holds=0, target_conflicts=0;
  longint unsigned clear_holds=0, source_handoffs=0, capacity_waits=0;
  longint unsigned signature=64'hcbf29ce484222325;
  longint unsigned made_by_mode[3], done_by_mode[3], cancelled_by_mode[3];
  longint unsigned cancelled_at_mode[3], made_by_cell[CELLS], done_by_cell[CELLS];
  longint unsigned cancelled_by_cell[CELLS], direction_hits[3][2];
  int max_wall_age=0, max_enabled_age=0, max_service_age=0;
  int peak_pending=0, max_drain_age=0;
  longint unsigned drained_routes=0;
  bit previous_auto=0, previous_gamma=0, previous_thermal=0;
  bit source_valid=0, initialized=0;

  task automatic check(input bit condition, input string label_text);
    checks++;
    if(!condition)
      $fatal(1,"LIFECYCLE cells=%0d sample=%0d %s",CELLS,samples,label_text);
  endtask

  task automatic event_record(input int kind, cell_index, mode, age);
    signature=(signature^64'(kind))*64'h100000001b3;
    signature=(signature^64'(cell_index))*64'h100000001b3;
    signature=(signature^route_id[cell_index])*64'h100000001b3;
    signature=(signature^64'(destination[cell_index]))*64'h100000001b3;
    signature=(signature^64'(mode))*64'h100000001b3;
    signature=(signature^64'(age))*64'h100000001b3;
  endtask

  task automatic conservation;
    int outstanding, mode_pending[3];
    outstanding=0;
    foreach(mode_pending[m]) mode_pending[m]=0;
    for(int c=0;c<CELLS;c++) begin
      if(live[c]) begin
        outstanding++; mode_pending[origin_mode[c]]++;
        check(stimulus.pending[2*c+:2]===destination[c],"ledger destination matches pending");
        check(stimulus.state[2*c+:2]===2'b00,"live route owns active zero");
      end else check(stimulus.pending[2*c+:2]===2'b00,"no untracked pending route");
      check(made_by_cell[c]==done_by_cell[c]+cancelled_by_cell[c]+64'(live[c]),
            "per-cell lifecycle conservation");
    end
    check(created==completed+reset_cancelled+64'(outstanding),"global lifecycle conservation");
    for(int m=0;m<3;m++)
      check(made_by_mode[m]==done_by_mode[m]+cancelled_by_mode[m]+64'(mode_pending[m]),
            "origin-mode lifecycle conservation");
    if(outstanding>peak_pending) peak_pending=outstanding;
  endtask

  initial begin
    int requested_case;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    foreach(live[c]) begin
      live[c]=0; destination[c]=0; route_id[c]=0; origin_mode[c]=0;
      wall_age[c]=0; enabled_age[c]=0; service_age[c]=0; drain_age[c]=0;
      made_by_cell[c]=0; done_by_cell[c]=0; cancelled_by_cell[c]=0;
    end
    for(int m=0;m<3;m++) begin
      made_by_mode[m]=0; done_by_mode[m]=0; cancelled_by_mode[m]=0; cancelled_at_mode[m]=0;
      for(int d=0;d<2;d++) direction_hits[m][d]=0;
    end
    requested_case=0;
    if($value$plusargs("CASE=%d",requested_case)) begin end
    if(requested_case!=0) $fatal(1,"Lifecycle qualification requires CASE=0");
  end

  // One observer serializes reset cancellation and clock-edge accounting.
  // The workload leaves at least two ns between an edge and its next mutation.
  always @(posedge stimulus.clk or negedge stimulus.rst_n) begin : observe
    logic [CELLS*2-1:0] before_state, before_pending, before_target;
    logic [LANES*2-1:0] request_targets;
    logic [LANES*$clog2(CELLS)-1:0] request_indexes;
    logic [LANES-1:0] request_valid;
    bit enabled, service, clearing, automatic_source, target_valid, changed_source, draining;
    int mode, cadence, outstanding, serviced, rank;
    samples++;
    if(!stimulus.rst_n) begin
      outstanding=0;
      mode=int'(stimulus.registered_mode);
      for(int c=0;c<CELLS;c++) if(live[c]) begin
        check(mode>=0 && mode<3,"reset mode domain");
        reset_cancelled++; cancelled_by_mode[origin_mode[c]]++;
        cancelled_at_mode[mode]++; cancelled_by_cell[c]++;
        event_record(3,c,origin_mode[c],service_age[c]);
        live[c]=0; outstanding++;
      end
      if(outstanding>0) occupied_resets++;
      if(!initialized || source_valid) reset_events++;
      source_valid=0;
      #1;
      check(stimulus.state==='0 && stimulus.pending==='0,"reset clears state and routes");
      conservation(); initialized=1;
    end else begin
      check(initialized,"initial reset observed");
      before_state=stimulus.state; before_pending=stimulus.pending;
      before_target=stimulus.registered_target; target_valid=stimulus.registered_valid;
      request_targets=stimulus.external_request_target;
      request_indexes=stimulus.external_request_cell_index;
      request_valid=stimulus.external_request_valid;
      enabled=stimulus.tick_enable; clearing=stimulus.clear_counters;
      automatic_source=stimulus.auto_target_enable;
      mode=int'(stimulus.registered_mode); cadence=int'(stimulus.scheduler_state);
      check(mode>=0 && mode<3,"scheduler mode domain");
      check(cadence>=0 && cadence<5,"scheduler cadence domain");
      service=enabled && (cadence==0 || cadence==2 || cadence==3);
      draining=!automatic_source && request_valid==0;
      changed_source=source_valid &&
        (previous_auto!=automatic_source || previous_gamma!=stimulus.local_gamma_enable ||
         previous_thermal!=stimulus.local_thermal_enable);
      previous_auto=automatic_source;
      previous_gamma=stimulus.local_gamma_enable;
      previous_thermal=stimulus.local_thermal_enable; source_valid=1;
      conservation();
      outstanding=0;
      for(int c=0;c<CELLS;c++) if(live[c]) begin
        outstanding++; wall_age[c]++;
        if(enabled) enabled_age[c]++;
        if(service) service_age[c]++;
        if(!draining) drain_age[c]=0;
        else if(service) drain_age[c]++;
        if(!enabled) paused_holds++;
        if(enabled && !service) cadence_holds++;
        if(clearing) clear_holds++;
        if(changed_source) source_handoffs++;
        if(automatic_source && target_valid && before_target[2*c+:2]!=destination[c])
          target_conflicts++;
        if(!automatic_source) for(int lane=0;lane<LANES;lane++)
          if(request_valid[lane] && int'(request_indexes[$clog2(CELLS)*lane+:$clog2(CELLS)])==c &&
             request_targets[2*lane+:2]!=destination[c]) target_conflicts++;
      end
      #1;
      serviced=0; rank=0;
      for(int c=0;c<CELLS;c++) begin
        check(stimulus.state[2*c+:2]!==2'b10,"retained symbol domain");
        check(stimulus.pending[2*c+:2]!==2'b10,"pending symbol domain");
        check(!((before_state[2*c+:2]==2'b01 && stimulus.state[2*c+:2]==2'b11) ||
                (before_state[2*c+:2]==2'b11 && stimulus.state[2*c+:2]==2'b01)),
              "no direct opposite-polarity transition");
        if(!enabled) begin
          check(stimulus.state[2*c+:2]===before_state[2*c+:2],"paused state retention");
          check(stimulus.pending[2*c+:2]===before_pending[2*c+:2],"paused route retention");
        end
        if(live[c]) begin
          rank++;
          check(drain_age[c]<=SERVICE_BOUND,"bounded drain service opportunities");
          if(drain_age[c]>max_drain_age) max_drain_age=drain_age[c];
          if(wall_age[c]>max_wall_age) max_wall_age=wall_age[c];
          if(enabled_age[c]>max_enabled_age) max_enabled_age=enabled_age[c];
          if(service_age[c]>max_service_age) max_service_age=service_age[c];
          if(stimulus.pending[2*c+:2]==0) begin
            check(service,"completion requires an enabled activation cadence");
            check(rank<=LANES,"pending service respects cell-order capacity");
            check(stimulus.state[2*c+:2]===destination[c],"completion uses original destination");
            if(draining) drained_routes++;
            completed++; done_by_mode[origin_mode[c]]++; done_by_cell[c]++; serviced++;
            event_record(2,c,origin_mode[c],service_age[c]); live[c]=0;
          end else begin
            check(stimulus.pending[2*c+:2]===destination[c],"destination survives target churn");
            check(!service || rank>LANES,"eligible pending route receives service");
            if(service) capacity_waits++;
          end
        end else if(stimulus.pending[2*c+:2]!=0) begin
          check(enabled,"route creation requires enabled tick");
          check(stimulus.pending[2*c+:2]===2'b01 || stimulus.pending[2*c+:2]===2'b11,
                "route destination polarity");
          check((before_state[2*c+:2]==2'b01 && stimulus.pending[2*c+:2]==2'b11) ||
                (before_state[2*c+:2]==2'b11 && stimulus.pending[2*c+:2]==2'b01),
                "route originates from opposite retained polarity");
          created++; made_by_mode[mode]++; made_by_cell[c]++;
          live[c]=1; destination[c]=stimulus.pending[2*c+:2];
          route_id[c]=created; origin_mode[c]=mode;
          wall_age[c]=0; enabled_age[c]=0; service_age[c]=0; drain_age[c]=0;
          direction_hits[mode][destination[c]==2'b01]++;
          event_record(1,c,mode,0);
        end
      end
      check(serviced==(service ? (outstanding<LANES ? outstanding:LANES):0),
            "pending service count before new admissions");
      conservation();
    end
  end

  final begin
    if(stimulus.source_cases!=384 || stimulus.reset_cases!=96 || stimulus.stream_ticks!=6144)
      $fatal(1,"Lifecycle workload did not finish");
    if(created!=completed+reset_cancelled || stimulus.pending!='0)
      $fatal(1,"Final lifecycle conservation failed");
    if(created!=64'(stimulus.routes) || completed!=64'(stimulus.completions))
      $fatal(1,"Independent lifecycle totals disagree with cross-feedback totals");
    if(occupied_resets!=96 || reset_cancelled!=96*LANES)
      $fatal(1,"Reset cancellation coverage incomplete");
    if(paused_holds==0 || cadence_holds==0 || target_conflicts==0 || clear_holds==0 ||
       source_handoffs==0 || capacity_waits==0 || peak_pending<=LANES || drained_routes==0)
      $fatal(1,"Lifecycle stress coverage incomplete");
    for(int c=0;c<CELLS;c++)
      if(live[c] || made_by_cell[c]==0 || done_by_cell[c]==0 || cancelled_by_cell[c]==0)
        $fatal(1,"Lifecycle cell coverage missing cell=%0d",c);
    for(int m=0;m<3;m++) begin
      if(made_by_mode[m]==0 || done_by_mode[m]==0 || cancelled_at_mode[m]==0 ||
         direction_hits[m][0]==0 || direction_hits[m][1]==0)
        $fatal(1,"Lifecycle mode coverage missing mode=%0d",m);
      $display("LIFECYCLE_MODE cells=%0d mode=%0d created=%0d completed=%0d reset_cancelled=%0d cancelled_at_mode=%0d negative=%0d positive=%0d",
        CELLS,m,made_by_mode[m],done_by_mode[m],cancelled_by_mode[m],cancelled_at_mode[m],
        direction_hits[m][0],direction_hits[m][1]);
    end
    $display("LIFECYCLE_COVERAGE cells=%0d samples=%0d checks=%0d resets=%0d occupied_resets=%0d paused=%0d cadence_holds=%0d conflicts=%0d counter_clear=%0d source_handoffs=%0d capacity_waits=%0d peak_pending=%0d",
      CELLS,samples,checks,reset_events,occupied_resets,paused_holds,cadence_holds,
      target_conflicts,clear_holds,source_handoffs,capacity_waits,peak_pending);
    $display("PASS ROUTE_LIFECYCLE cells=%0d created=%0d completed=%0d reset_cancelled=%0d pending=0 max_wall_age=%0d max_enabled_age=%0d max_service_age=%0d drained_routes=%0d max_drain_age=%0d drain_service_bound=%0d signature=%016h",
      CELLS,created,completed,reset_cancelled,max_wall_age,max_enabled_age,max_service_age,
      drained_routes,max_drain_age,SERVICE_BOUND,signature);
  end
endmodule

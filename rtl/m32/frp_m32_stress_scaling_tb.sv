// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Three tests: sustained mixed traffic, pending-reset storms, functional scaling.
// Reuses the unchanged independent 103-output oracle, including its baseline.
// Scaling measures DUT clock cycles and service opportunities, not host speed.
// Select this top explicitly; the included standalone top must not be selected.
`timescale 1ns/1ps
`include "frp_m32_full_state_oracle_tb.sv"

module frp_m32_stress_scaling_tb #(
  parameter int CELLS=8,
  parameter int STRESS_TICKS=8192,
  parameter int unsigned SEED=32'h90c0ffee
);
  import frp_m31_pkg::*;
  localparam int LANES=CELLS/4;
  wire baseline_done;
  frp_m32_full_state_oracle_checker #(.N(CELLS)) model(.done(baseline_done));
  int unsigned rng=SEED;
  int enabled_ticks=0, paused_ticks=0, reset_cases=0, scaling_cases=0;
  int traffic_cross[3][4][2][4];
  int longest_run=0, run_length=0, saturation_edges=0;
  int checks_start, steps_start, routes_start, completions_start;
  int start_checks, start_steps, reset_start;
  int offered=0, accepted=0, rejected=0;
  logic [CELLS-1:0] offered_cells=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic int unsigned next_word;
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction

  task automatic no_requests;
    model.external_request_valid=0;
    model.external_request_cell_index=0;
    model.external_request_target=0;
    model.external_target_bank=0;
    model.auto_target_enable=0;
  endtask

  // Compare every public output through the independent oracle on each edge.
  // Separate events avoid inlining the large oracle into every stimulus loop.
  event advance, advanced;
  bit edge_enabled, edge_clear;
  initial forever begin
    @advance;
    model.step(edge_enabled,edge_clear);
    ->advanced;
  end
  task automatic edge_step(input bit enabled, input bit clear=0);
    edge_enabled=enabled; edge_clear=clear;
    ->advance; @advanced;
    signature=(signature^{32'd0,model.actual.ticks_recorded_q})*64'h100000001b3;
    signature=(signature^{32'd0,model.actual.stability.margin})*64'h100000001b3;
  endtask

  // Fill every cell, then create a full opposite-polarity backlog while the
  // scheduler forbids completion. All writes are ordinary public requests.
  task automatic full_backlog(input int polarity);
    model.reset_core(); no_requests();
    model.local_gamma_enable=1; model.local_thermal_enable=1;
    for(int batch=0;batch<4;batch++) begin
      no_requests();
      for(int lane=0;lane<LANES;lane++) model.lane(lane,batch*LANES+lane,polarity);
      model.tick_enable=1; #1; model.check();
      if(model.actual.accepted_changes!=LANES || !model.actual.capacity_exhausted)
        $fatal(1,"SCALING throughput cells=%0d batch=%0d",CELLS,batch);
      saturation_edges++; edge_step(1);
    end
    no_requests();
    while(model.gold_position!=0) edge_step(1);
    model.scheduler_mode=FRP_MODE_7_1; edge_step(0);
    for(int batch=0;batch<4;batch++) begin
      no_requests();
      for(int lane=0;lane<LANES;lane++) model.lane(lane,batch*LANES+lane,-polarity);
      edge_step(1);
    end
    no_requests();
    for(int c=0;c<CELLS;c++)
      if(model.actual.state_out[2*c+:2]!=0 ||
         model.actual.pending_route_out[2*c+:2]!==model.symbol(-polarity))
        $fatal(1,"Full backlog missing cells=%0d cell=%0d",CELLS,c);
  endtask

  initial begin : campaign
    int unsigned r;
    int source, kind, destination, previous_pending, remaining;
    int cycles, services, holds, expected_cycles, service_count;
    bit service;
    logic [CELLS*2-1:0] held_pending;
    if((CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64) ||
       STRESS_TICKS<8192 || STRESS_TICKS>65536 || STRESS_TICKS%8192!=0 || SEED==0)
      $fatal(1,"Unsupported stress/scaling configuration");
    wait(baseline_done); #1;
    checks_start=model.checks; steps_start=model.steps;

    // Test 1: no reset between scheduler modes. Preserve thermal, gamma,
    // frequency and stability histories throughout the complete workload.
    model.reset_core();
    model.phase_load_valid=1;
    for(int c=0;c<CELLS;c++) begin
      model.phase_load[32*c+:32]=next_word();
      model.frequency_load_q16[32*c+:32]=c%2!=0?32'h80000000:32'h7fffffff;
    end
    edge_step(0); model.phase_load_valid=0;
    routes_start=model.first_legs; completions_start=model.second_legs;
    for(int mode=0;mode<3;mode++) begin
      model.scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      edge_step(0);
      for(int t=0;t<STRESS_TICKS;t++) begin
        source=(t/1024)%4; kind=(t/32)%4;
        no_requests(); model.auto_target_enable=1'((t/128)%2);
        model.local_gamma_enable=1'(source);
        model.local_thermal_enable=1'(source>>1);
        for(int lane=0;lane<LANES;lane++) begin
          r=next_word();
          case(kind)
            0: destination=(t*LANES+lane)%CELLS;
            1: destination=(t/32)%CELLS;
            2: destination=(t+3*lane)%CELLS;
            default: destination=int'(r%CELLS);
          endcase
          model.lane(lane,destination,int'((r>>8)%3)-1);
          if(kind==3) model.external_request_valid[lane]=r[31] && (t%8<3);
          if(!model.auto_target_enable && model.external_request_valid[lane])
            offered_cells[destination]=1;
        end
        model.gamma_update_valid=t%13==0;
        for(int c=0;c<CELLS;c++) begin
          if(model.gamma_update_valid) begin
            r=next_word();
            case((t/13)%4)
              0: model.gamma_targets_q16[32*c+:32]=32'h7fffffff;
              1: model.gamma_targets_q16[32*c+:32]=32'h80000000;
              2: model.gamma_targets_q16[32*c+:32]=r;
              default: model.gamma_targets_q16[32*c+:32]=0;
            endcase
          end
          if(t%17==0) begin
            model.gamma_effective_word[32*c+:32]=next_word();
            model.thermal_node_factor_q30[32*c+:32]=32'((c+t/17)%5)*32'h10000000;
          end
        end
        // Long contiguous runs alternate with bursts of 1, 4 and 17 holds.
        if(t%2048==2047) begin
          holds=mode==0?1:mode==1?4:17;
          repeat(holds) begin edge_step(0,1); paused_ticks++; end
          run_length=0;
        end
        model.tick_enable=1; model.clear_counters=t%257==0;
        #1; model.check();
        offered+=$countones(model.actual.execution_request_valid);
        accepted+=$countones(model.actual.request_accept);
        rejected+=$countones(model.actual.request_reject);
        edge_step(1,t%257==0);
        traffic_cross[mode][source][int'(model.auto_target_enable)][kind]++;
        enabled_ticks++; run_length++;
        if(run_length>longest_run) longest_run=run_length;
      end
    end
    no_requests(); model.scheduler_mode=FRP_MODE_FREE; edge_step(0);
    repeat(4) edge_step(1);
    edge_step(0); edge_step(0);
    if(model.actual.pending_route_out!=0 || enabled_ticks!=3*STRESS_TICKS ||
       longest_run<2047 || offered_cells!={CELLS{1'b1}} ||
       offered!=accepted+rejected || accepted==0 || rejected==0 ||
       model.first_legs==routes_start || model.second_legs==completions_start)
      $fatal(1,"Stress event coverage incomplete cells=%0d",CELLS);
    foreach(traffic_cross[m,s,a,k]) if(traffic_cross[m][s][a][k]==0)
      $fatal(1,"Missing stress cross %0d/%0d/%0d/%0d",m,s,a,k);
    $display("PASS STRESS cells=%0d seed=%08h enabled=%0d held=%0d longest=%0d offered=%0d accepted=%0d rejected=%0d routes=%0d completions=%0d checks=%0d",
      CELLS,SEED,enabled_ticks,paused_ticks,longest_run,offered,accepted,rejected,
      model.first_legs-routes_start,model.second_legs-completions_start,model.checks-checks_start);

    // Test 2: cancel a full backlog, including delayed feedback history.
    start_checks=model.checks; reset_start=model.resets;
    for(int trial=0;trial<64;trial++) begin
      full_backlog(trial%2!=0?1:-1);
      model.scheduler_mode=frp_m31_scheduler_mode_e'(trial%3);
      repeat(trial%5) edge_step(0,trial%2==0);
      model.gamma_update_valid=1;
      model.gamma_targets_q16={CELLS{32'h80000000}};
      model.tick_enable=1'(trial%2);
      model.reset_core(1);
      no_requests(); edge_step(0); edge_step(1); edge_step(0); edge_step(0);
      if(model.actual.state_out!=0 || model.actual.pending_route_out!=0)
        $fatal(1,"Stale execution after reset trial=%0d",trial);
      reset_cases++;
    end
    if(reset_cases!=64 || model.resets-reset_start!=128)
      $fatal(1,"Incomplete reset storm");
    $display("PASS RESET_STORM cells=%0d cases=%0d resets=%0d checks=%0d",
      CELLS,reset_cases,model.resets-reset_start,model.checks-start_checks);

    // Test 3: fixed normalized work at each size. Expect N/4 writes per
    // enabled service edge, exactly four service edges, and cadence latency.
    for(int mode=0;mode<3;mode++) for(int sign_index=0;sign_index<2;sign_index++) begin
      start_checks=model.checks; start_steps=model.steps;
      full_backlog(sign_index==0?1:-1);
      model.scheduler_mode=frp_m31_scheduler_mode_e'(mode); edge_step(0);
      cycles=0; services=0; remaining=CELLS;
      expected_cycles=mode==0?4:mode==1?28:29;
      while(remaining!=0 && cycles<32) begin
        held_pending=model.actual.pending_route_out;
        repeat(2) edge_step(0,1);
        if(model.actual.pending_route_out!==held_pending)
          $fatal(1,"Paused backlog changed");
        service=model.cadence()==0 || model.cadence()==2 || model.cadence()==3;
        previous_pending=remaining;
        edge_step(1); cycles++;
        remaining=0;
        for(int c=0;c<CELLS;c++) if(model.actual.pending_route_out[2*c+:2]!=0) remaining++;
        service_count=previous_pending-remaining;
        if(service_count!=(service?LANES:0))
          $fatal(1,"Scaling completion rate cells=%0d mode=%0d cycle=%0d",CELLS,mode,cycles);
        if(service) services++;
      end
      if(remaining!=0 || services!=4 || cycles!=expected_cycles)
        $fatal(1,"Scaling latency cells=%0d mode=%0d cycles=%0d",CELLS,mode,cycles);
      for(int c=0;c<CELLS;c++)
        if(model.actual.state_out[2*c+:2]!==model.symbol(sign_index==0?-1:1))
          $fatal(1,"Scaling final polarity cell=%0d",c);
      scaling_cases++;
      $display("PASS SCALING cells=%0d lanes=%0d mode=%0d polarity=%0d completed=%0d service_edges=%0d enabled_edges=%0d held_edges=%0d total_edges=%0d checks=%0d",
        CELLS,LANES,mode,sign_index==0?-1:1,CELLS,services,cycles,2*cycles,
        model.steps-start_steps,model.checks-start_checks);
    end
    if(scaling_cases!=6 || saturation_edges!=4*(64+6))
      $fatal(1,"Incomplete scaling matrix");
    $display("PASS STRESS_SCALING_ALL cells=%0d ports=103 tests=3 scaling_cases=%0d saturation_edges=%0d steps=%0d checks=%0d signature=%016h oracle_signature=%016h",
      CELLS,scaling_cases,saturation_edges,model.steps-steps_start,model.checks-checks_start,
      signature,model.signature);
    $finish;
  end
  initial begin
    #10000000;
    $fatal(1,"Stress/scaling watchdog cells=%0d",CELLS);
  end
endmodule

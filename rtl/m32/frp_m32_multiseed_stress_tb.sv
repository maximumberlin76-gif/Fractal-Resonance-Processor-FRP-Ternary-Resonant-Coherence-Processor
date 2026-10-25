// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Runtime-seeded stress, control crosses, pending-reset storms and scaling.
// Run the same executable with +FRP_SEED=90c0ffee +FRP_TICKS=8192.
// FRP_SEED is exactly eight hexadecimal digits and must be nonzero.
// FRP_TICKS is decimal, 8192..65536 inclusive, in multiples of 8192.
// Each invocation retains histories across all three scheduler modes.
// Compare identical invocations for replay; vary seeds without rebuilding.
// Reuses the unchanged independent 103-output oracle, including its baseline.
// Scaling measures DUT clock cycles and service opportunities, not host speed.
// Select this top explicitly; the included standalone top must not be selected.
`timescale 1ns/1ps
`include "frp_m32_full_state_oracle_tb.sv"

module frp_m32_multiseed_stress_tb #(
  parameter int CELLS=8,
  parameter int STRESS_TICKS=8192,
  parameter int unsigned SEED=32'h90c0ffee
);
  import frp_m31_pkg::*;
  localparam int LANES=CELLS/4;
  wire baseline_done;
  frp_m32_full_state_oracle_checker #(.N(CELLS)) model(.done(baseline_done));
  int unsigned runtime_seed=SEED, rng=SEED;
  int runtime_ticks=STRESS_TICKS;
  int random_draws=0, control_edges=0;
  int control_cross[3][4][2][2][2][2];
  logic [63:0] stimulus_signature=64'hcbf29ce484222325;
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
    random_draws++;
    stimulus_signature=(stimulus_signature^{32'd0,rng})*64'h100000001b3;
    return rng;
  endfunction

  function automatic int unsigned parse_number(input string text, input int radix);
    int digit;
    int unsigned result;
    result=0;
    if(text.len()==0 || (radix==16 && text.len()!=8) ||
       (radix==10 && text.len()>5))
      $fatal(1,"Invalid runtime number: %s",text);
    for(int i=0;i<text.len();i++) begin
      digit=int'(text.getc(i));
      if(digit>=48 && digit<=57) digit-=48;
      else if(radix==16 && digit>=65 && digit<=70) digit-=55;
      else if(radix==16 && digit>=97 && digit<=102) digit-=87;
      else $fatal(1,"Invalid runtime digit: %s",text);
      if(digit>=radix) $fatal(1,"Invalid runtime radix: %s",text);
      result=result*32'(radix)+32'(digit);
    end
    return result;
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

  task automatic control_sweep(input int mode);
    int unsigned word_value;
    for(int source=0;source<4;source++)
      for(int automatic_source=0;automatic_source<2;automatic_source++)
        for(int update=0;update<2;update++)
          for(int clear=0;clear<2;clear++)
            for(int enabled=0;enabled<2;enabled++) begin
              no_requests();
              model.local_gamma_enable=1'(source);
              model.local_thermal_enable=1'(source>>1);
              model.auto_target_enable=1'(automatic_source);
              model.gamma_update_valid=1'(update);
              for(int lane=0;lane<LANES;lane++) begin
                word_value=next_word();
                model.lane(lane,int'(word_value%CELLS),int'((word_value>>8)%3)-1);
              end
              for(int c=0;c<CELLS;c++) begin
                model.gamma_targets_q16[32*c+:32]=next_word();
                model.gamma_effective_word[32*c+:32]=next_word();
                model.thermal_node_factor_q30[32*c+:32]=
                  32'((c+source+update)%5)*32'h10000000;
              end
              edge_step(1'(enabled),1'(clear));
              control_cross[mode][source][automatic_source][enabled][update][clear]++;
              control_edges++;
            end
  endtask

  initial begin : campaign
    int unsigned r;
    string seed_text, ticks_text;
    int source, kind, destination, previous_pending, remaining;
    int cycles, services, holds, expected_cycles, service_count;
    bit service;
    logic [CELLS*2-1:0] held_pending;
    if($test$plusargs("FRP_SEED")) begin
      if(!$value$plusargs("FRP_SEED=%s",seed_text))
        $fatal(1,"Expected +FRP_SEED= followed by eight hexadecimal digits");
      runtime_seed=parse_number(seed_text,16);
    end
    if($test$plusargs("FRP_TICKS")) begin
      if(!$value$plusargs("FRP_TICKS=%s",ticks_text))
        $fatal(1,"Expected +FRP_TICKS= followed by decimal ticks per mode");
      runtime_ticks=int'(parse_number(ticks_text,10));
    end
    rng=runtime_seed;
    if((CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64) ||
       runtime_ticks<8192 || runtime_ticks>65536 || runtime_ticks%8192!=0 || runtime_seed==0)
      $fatal(1,"Unsupported stress/scaling configuration");
    $display("MULTISEED_CONFIG cells=%0d seed=%08h ticks_per_mode=%0d",
      CELLS,runtime_seed,runtime_ticks);
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
    reset_start=model.resets;
    for(int mode=0;mode<3;mode++) begin
      model.scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      edge_step(0);
      control_sweep(mode);
      run_length=0;
      for(int t=0;t<runtime_ticks;t++) begin
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
    if(model.actual.pending_route_out!=0 || enabled_ticks!=3*runtime_ticks ||
       longest_run<2047 || offered_cells!={CELLS{1'b1}} ||
       offered!=accepted+rejected || accepted==0 || rejected==0 ||
       model.first_legs==routes_start || model.second_legs==completions_start)
      $fatal(1,"Stress event coverage incomplete cells=%0d",CELLS);
    if(model.resets!=reset_start || control_edges!=192)
      $fatal(1,"Mode history or control sweep incomplete");
    foreach(control_cross[m,s,a,e,u,c]) if(control_cross[m][s][a][e][u][c]!=1)
      $fatal(1,"Missing control cross %0d/%0d/%0d/%0d/%0d/%0d",m,s,a,e,u,c);
    $display("PASS MULTISEED_CONTROLS cells=%0d bins=192 edges=%0d resets=0",
      CELLS,control_edges);
    foreach(traffic_cross[m,s,a,k]) if(traffic_cross[m][s][a][k]==0)
      $fatal(1,"Missing stress cross %0d/%0d/%0d/%0d",m,s,a,k);
    $display("PASS STRESS cells=%0d seed=%08h enabled=%0d held=%0d longest=%0d offered=%0d accepted=%0d rejected=%0d routes=%0d completions=%0d checks=%0d",
      CELLS,runtime_seed,enabled_ticks,paused_ticks,longest_run,offered,accepted,rejected,
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
    $display("PASS MULTISEED_STRESS_ALL cells=%0d ports=103 tests=4 scaling_cases=%0d saturation_edges=%0d steps=%0d checks=%0d signature=%016h oracle_signature=%016h",
      CELLS,scaling_cases,saturation_edges,model.steps-steps_start,model.checks-checks_start,
      signature,model.signature);
    $display("PASS MULTISEED_REPLAY cells=%0d seed=%08h ticks_per_mode=%0d traffic_bins=96 control_bins=192 draws=%0d stimulus_signature=%016h",
      CELLS,runtime_seed,runtime_ticks,random_draws,stimulus_signature);
    $finish;
  end
  initial begin
    #10000000;
    $fatal(1,"Multiseed stress watchdog cells=%0d",CELLS);
  end
endmodule

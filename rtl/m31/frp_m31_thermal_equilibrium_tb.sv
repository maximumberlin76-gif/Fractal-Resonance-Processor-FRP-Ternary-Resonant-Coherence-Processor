// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Exact uniform equilibria and heterogeneous thermal relaxation.
// For uniform integer power P, half-away dissipation gives the fixed interval
// [3277 + 14*P - 7, 3277 + 14*P + 6] in raw Q16.16 units.
// Cold and hot approaches check both endpoints against an integer recurrence.
// Eight spatial heating histories settle within 512 cooling updates, retain
// their peaks and replay exactly with different disabled-clock intervals.
// Build: --binary --timing --assert -Irtl/m31
// --top-module frp_m31_thermal_equilibrium_tb -GCELLS=8 (16/32/64).
// Runtime: +SEED=76. Only public ports of the unchanged thermal field are used.
`timescale 1ns/1ps
`include "frp_m31_local_thermal_field.sv"

module frp_m31_thermal_equilibrium_tb #(
  parameter int CELLS=8
);
  localparam int AMBIENT=3277, LIMIT=512, REST=32;
  localparam logic [31:0] LAGS[9]='{
    0,1,27,28,65536,32'h7fffffff,32'h80000000,32'hffffffff,65536
  };
  typedef logic signed [31:0] word_t;
  typedef logic [CELLS*192+95:0] retained_t;
  logic clk=0, rst_n=1, tick_enable=0;
  logic [CELLS-1:0] switch_activity='0;
  logic [CELLS*32-1:0] frequency_lag_q16='0;
  wire [CELLS*32-1:0] heat_q16, local_heat_peak_q16, generated_power_q16;
  wire [CELLS*32-1:0] thermal_dissipation_q16, thermal_diffusion_q16;
  wire [CELLS*32-1:0] thermal_overload_q16, next_heat_q16, next_overload_q16;
  wire signed [31:0] mean_heat_q16, mean_heat_peak_q16, maximum_local_heat_q16;
  word_t observed_peak[CELLS], observed_mean_peak;
  retained_t replay_state[8];
  int replay_ticks[8];
  int unsigned seed=76;
  int checks=0, updates=0, holds=0, resets=0, uniform_cases=0;
  int relaxations=0, replays=0, steady_updates=0, maximum_settle=0;
  int low_endpoints=0, high_endpoints=0, nonuniform_histories=0;
  int retained_peaks=0, candidate_changes=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  frp_m31_local_thermal_field #(.CELLS(CELLS)) dut (.*);

  function automatic logic [31:0] mix(input logic [31:0] x);
    x^=x<<13; x^=x>>17; x^=x<<5;
    return x;
  endfunction

  function automatic longint signed input_power(input logic [31:0] lag_word,
                                                input bit switching);
    return 118+(longint'({32'b0,lag_word})*1180+32768)/65536
              +(switching?3408:0);
  endfunction

  function automatic retained_t retained();
    return {heat_q16,local_heat_peak_q16,generated_power_q16,
            thermal_dissipation_q16,thermal_diffusion_q16,thermal_overload_q16,
            mean_heat_q16,mean_heat_peak_q16,maximum_local_heat_q16};
  endfunction

  task automatic eq(input string field, input longint signed got,want);
    checks++;
    if (got!==want)
      $fatal(1,"THERMAL_EQUILIBRIUM %s cells=%0d update=%0d got=%0d want=%0d",
        field,CELLS,updates,got,want);
  endtask

  task automatic uniform_input(input logic [31:0] value, input bit switching);
    frequency_lag_q16={CELLS{value}};
    switch_activity={CELLS{switching}};
    #1;
  endtask

  task automatic clock_tick();
    longint signed sum,largest,h,mean_value;
    tick_enable=1; #1; clk=1; #1; clk=0; #1; tick_enable=0;
    updates++; sum=0; largest=AMBIENT;
    for (int c=0;c<CELLS;c++) begin
      h=longint'(word_t'(heat_q16[c*32+:32]));
      if (h<AMBIENT) $fatal(1,"THERMAL_EQUILIBRIUM below ambient");
      if (h>observed_peak[c]) observed_peak[c]=word_t'(h);
      eq("peak_history",longint'(word_t'(local_heat_peak_q16[c*32+:32])),observed_peak[c]);
      if (observed_peak[c]>h) retained_peaks++;
      if (observed_peak[c]>largest) largest=observed_peak[c];
      sum+=h;
      signature=(signature^{32'b0,heat_q16[c*32+:32]})*64'h100000001b3;
    end
    mean_value=(sum+CELLS/2)/CELLS;
    if (mean_value>observed_mean_peak) observed_mean_peak=word_t'(mean_value);
    eq("mean",mean_heat_q16,mean_value);
    eq("mean_peak",mean_heat_peak_q16,observed_mean_peak);
    eq("maximum_peak",maximum_local_heat_q16,largest);
  endtask

  task automatic pause_with_noise();
    retained_t saved;
    logic [CELLS*32-1:0] saved_lag,saved_candidate;
    logic [CELLS-1:0] saved_switch;
    saved=retained(); saved_lag=frequency_lag_q16;
    saved_switch=switch_activity; saved_candidate=next_heat_q16;
    frequency_lag_q16=~saved_lag; switch_activity=~saved_switch;
    tick_enable=0; #1;
    if (next_heat_q16!==saved_candidate) candidate_changes++;
    clk=1; #1; clk=0; #1;
    if (retained()!==saved) $fatal(1,"THERMAL_EQUILIBRIUM HOLD changed history");
    checks++; holds++; frequency_lag_q16=saved_lag; switch_activity=saved_switch; #1;
  endtask

  task automatic reset_field();
    tick_enable=1; rst_n=0; #1;
    for (int sample_id=0;sample_id<2;sample_id++) begin
      for (int c=0;c<CELLS;c++) begin
        eq("reset_heat",longint'(word_t'(heat_q16[c*32+:32])),AMBIENT);
        eq("reset_peak",longint'(word_t'(local_heat_peak_q16[c*32+:32])),AMBIENT);
        eq("reset_power",longint'(word_t'(generated_power_q16[c*32+:32])),0);
        eq("reset_dissipation",longint'(word_t'(thermal_dissipation_q16[c*32+:32])),0);
        eq("reset_diffusion",longint'(word_t'(thermal_diffusion_q16[c*32+:32])),0);
        eq("reset_overload",longint'(word_t'(thermal_overload_q16[c*32+:32])),0);
      end
      eq("reset_mean",mean_heat_q16,AMBIENT);
      eq("reset_mean_peak",mean_heat_peak_q16,AMBIENT);
      eq("reset_maximum",maximum_local_heat_q16,AMBIENT);
      if (sample_id==0) begin clk=1; #1; clk=0; #1; end
    end
    for (int c=0;c<CELLS;c++) observed_peak[c]=AMBIENT;
    observed_mean_peak=AMBIENT;
    tick_enable=0; rst_n=1; #1; resets++;
  endtask

  task automatic uniform_tick(input longint signed power, inout longint signed model);
    longint signed diss,next_value,candidate;
    diss=(model-AMBIENT+7)/14;
    next_value=model+power-diss;
    if (next_value<AMBIENT || next_value>2147483647)
      $fatal(1,"Uniform reference outside declared range");
    for (int c=0;c<CELLS;c++)
      eq("uniform_candidate_before",longint'(word_t'(next_heat_q16[c*32+:32])),next_value);
    clock_tick(); model=next_value;
    candidate=model+power-(model-AMBIENT+7)/14;
    for (int c=0;c<CELLS;c++) begin
      eq("uniform_heat",longint'(word_t'(heat_q16[c*32+:32])),model);
      eq("uniform_power",longint'(word_t'(generated_power_q16[c*32+:32])),power);
      eq("uniform_dissipation",longint'(word_t'(thermal_dissipation_q16[c*32+:32])),diss);
      eq("uniform_diffusion",longint'(word_t'(thermal_diffusion_q16[c*32+:32])),0);
      eq("uniform_overload",longint'(word_t'(thermal_overload_q16[c*32+:32])),model>14418?model-14418:0);
      eq("uniform_candidate_after",longint'(word_t'(next_heat_q16[c*32+:32])),candidate);
      eq("uniform_next_overload",longint'(word_t'(next_overload_q16[c*32+:32])),candidate>14418?candidate-14418:0);
    end
  endtask

  task automatic heat_pattern(input int pattern,step_id);
    logic [31:0] value;
    for (int c=0;c<CELLS;c++) begin
      value=mix(seed^32'h7f4a7c15^(32'(step_id+1)*32'h9e3779b9)
                ^(32'(c+1)*32'h85ebca6b));
      switch_activity[c]=value[0];
      case (pattern)
        0: frequency_lag_q16[c*32+:32]=(c==step_id%CELLS)?32'hffffffff:0;
        1: frequency_lag_q16[c*32+:32]=(c<CELLS/2)?32'hffffffff:0;
        2: frequency_lag_q16[c*32+:32]=(c%2)?32'h80000000:0;
        3: frequency_lag_q16[c*32+:32]=32'((64'hffffffff*64'(c))/(CELLS-1));
        4: frequency_lag_q16[c*32+:32]=value;
        5: frequency_lag_q16[c*32+:32]=value%262145;
        6: frequency_lag_q16[c*32+:32]=32'hffffffff;
        default: frequency_lag_q16[c*32+:32]=0;
      endcase
    end
    #1;
  endtask

  task automatic steady_check(input longint signed low,high);
    for (int c=0;c<CELLS;c++) begin
      if (longint'(word_t'(heat_q16[c*32+:32]))<low
          || longint'(word_t'(heat_q16[c*32+:32]))>high)
        $fatal(1,"THERMAL_EQUILIBRIUM outside fixed interval cell=%0d",c);
    end
    if (next_heat_q16!==heat_q16)
      $fatal(1,"THERMAL_EQUILIBRIUM fixed point moved");
    checks+=CELLS+1;
  endtask

  initial begin : run
    longint signed model,previous,power,low,high;
    retained_t saved;
    int elapsed;
    bit settled,different;
    if (!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    #1;
    for (int profile=0;profile<9;profile++) begin
      for (int side=0;side<2;side++) begin
        uniform_input(32'hffffffff,1); reset_field(); model=AMBIENT;
        if (side==1)
          repeat(320) uniform_tick(input_power(32'hffffffff,1),model);
        uniform_input(LAGS[profile],profile==8);
        power=input_power(LAGS[profile],profile==8);
        low=AMBIENT+14*power-7; high=AMBIENT+14*power+6;
        if ((side==0 && model>=low) || (side==1 && model<=high))
          $fatal(1,"Uniform approach did not start outside the fixed interval");
        settled=0; elapsed=0;
        while (!settled && elapsed<LIMIT) begin
          previous=model; uniform_tick(power,model); elapsed++;
          if (elapsed%17==0) pause_with_noise();
          settled=(model==previous);
        end
        if (!settled) $fatal(1,"Uniform convergence budget exceeded");
        eq("endpoint",model,side==0?low:high);
        if (side==0) low_endpoints++; else high_endpoints++;
        steady_check(low,high); saved=retained();
        repeat(REST) begin
          uniform_tick(power,model); steady_check(low,high);
          if (retained()!==saved) $fatal(1,"Uniform equilibrium history changed");
          checks++; steady_updates++;
        end
        uniform_cases++;
      end
    end

    for (int pattern=0;pattern<8;pattern++) begin
      for (int replay=0;replay<2;replay++) begin
        heat_pattern(pattern,0); reset_field();
        for (int step_id=0;step_id<64;step_id++) begin
          heat_pattern(pattern,step_id);
          if ((step_id+replay)%5==0) pause_with_noise();
          clock_tick();
        end
        different=0;
        for (int c=1;c<CELLS;c++)
          if (heat_q16[c*32+:32]!==heat_q16[0+:32]) different=1;
        if (different) nonuniform_histories++;
        uniform_input(0,0); elapsed=0; settled=0;
        while (!settled && elapsed<LIMIT) begin
          if ((elapsed+replay)%7==0) pause_with_noise();
          clock_tick(); elapsed++;
          settled=(next_heat_q16===heat_q16);
        end
        if (!settled) $fatal(1,"Spatial relaxation budget exceeded pattern=%0d",pattern);
        if (elapsed>maximum_settle) maximum_settle=elapsed;
        // Retire telemetry for the stationary state before retaining its record.
        clock_tick(); steady_check(4922,4935);
        for (int c=0;c<CELLS;c++) begin
          eq("rest_power",longint'(word_t'(generated_power_q16[c*32+:32])),118);
          eq("rest_dissipation",longint'(word_t'(thermal_dissipation_q16[c*32+:32])),118);
          eq("rest_diffusion",longint'(word_t'(thermal_diffusion_q16[c*32+:32])),0);
        end
        saved=retained();
        repeat(REST) begin
          pause_with_noise(); clock_tick(); steady_check(4922,4935);
          if (retained()!==saved) $fatal(1,"Spatial equilibrium history changed");
          checks++; steady_updates++;
        end
        if (replay==0) begin replay_state[pattern]=saved; replay_ticks[pattern]=elapsed; end
        else begin
          if (saved!==replay_state[pattern]) $fatal(1,"Spatial replay state mismatch");
          eq("replay_settle_ticks",elapsed,replay_ticks[pattern]); checks++; replays++;
        end
        relaxations++;
      end
    end
    eq("uniform_cases",uniform_cases,18); eq("relaxations",relaxations,16);
    eq("replays",replays,8); eq("resets",resets,34);
    eq("low_endpoints",low_endpoints,9); eq("high_endpoints",high_endpoints,9);
    eq("steady_updates",steady_updates,34*REST);
    if (!(nonuniform_histories>0 && retained_peaks>0 && candidate_changes>0))
      $fatal(1,"Missing thermal equilibrium event");
    $display("PASS THERMAL_EQUILIBRIUM cells=%0d seed=%0d checks=%0d updates=%0d holds=%0d resets=%0d uniform_cases=%0d relaxations=%0d replays=%0d low_endpoints=%0d high_endpoints=%0d steady_updates=%0d maximum_settle=%0d nonuniform_histories=%0d retained_peaks=%0d candidate_changes=%0d signature=%h",
      CELLS,seed,checks,updates,holds,resets,uniform_cases,relaxations,replays,
      low_endpoints,high_endpoints,steady_updates,maximum_settle,
      nonuniform_histories,retained_peaks,candidate_changes,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"THERMAL_EQUILIBRIUM watchdog"); end
endmodule

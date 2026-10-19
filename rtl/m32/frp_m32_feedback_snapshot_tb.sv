// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Three public-port oracles: gamma drift, attenuation and global stability.
// Shared overload snapshots cross independent enable/reset masks and target valid.
// Arithmetic uses division, half-away rounding and analytic exponential values.
// No DUT helper functions or internal signals participate in expected results.
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"
`include "frp_m31_local_thermal_attenuation.sv"
`include "frp_m31_global_stability.sv"

module frp_m32_feedback_snapshot_tb #(parameter int CELLS=8);
  typedef logic signed [31:0] word_t;
  typedef struct packed { word_t target, noise, drift, effective; } gamma_t;
  typedef struct packed {
    word_t heat, overload, lag, neutral, argument;
    word_t compression, effective, capacity, pressure, margin;
    bit stable;
  } stability_t;
  localparam word_t MIN32=32'sh80000000, MAX32=32'sh7fffffff;
  localparam word_t UNITY=1073741824, NOMINAL=644245094;
  logic clk=0;
  logic [2:0] reset_n=7, enabled=0;
  logic gamma_update_valid=0;
  logic [CELLS*32-1:0] gamma_targets_q16='0, thermal_overload_q16='0;
  logic [CELLS*32-1:0] heat_q16='0, frequency_lag_q16='0;
  logic [CELLS*2-1:0] retained_state='0;
  word_t raw_phase_coherence_q30=0, cluster_coherence_q30=0, switch_load_q16=0;
  wire [CELLS*32-1:0] gamma_noise_target_q16, gamma_noise_state_q16;
  wire [CELLS*32-1:0] gamma_drift_word, gamma_effective_word;
  wire [CELLS*32-1:0] next_gamma_drift_word, next_gamma_effective_word;
  wire [CELLS*32-1:0] thermal_node_factor_q30, next_thermal_node_factor_q30;
  word_t mean_heat_q16, mean_thermal_overload_q16, mean_frequency_lag_q16;
  word_t neutral_fraction_q30, compression_arg_q16;
  word_t next_coherence_compression_q30, next_effective_coherence_q30;
  word_t next_coherence_capacity_q16, next_pressure_q16, next_stability_margin_q16;
  wire next_stable;
  word_t coherence_compression_q30, effective_coherence_q30;
  word_t coherence_capacity_q16, pressure_q16, stability_margin_q16, previous_margin_q16;
  wire stable;

  frp_m31_local_gamma_drift #(.CELLS(CELLS)) gamma_dut(
    .clk, .rst_n(reset_n[0]), .tick_enable(enabled[0]), .gamma_update_valid,
    .gamma_targets_q16, .thermal_overload_q16, .gamma_noise_target_q16,
    .gamma_noise_state_q16, .gamma_drift_word, .gamma_effective_word,
    .next_gamma_drift_word, .next_gamma_effective_word);
  frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) attenuation_dut(
    .clk, .rst_n(reset_n[1]), .tick_enable(enabled[1]), .thermal_overload_q16,
    .thermal_node_factor_q30, .next_thermal_node_factor_q30);
  frp_m31_global_stability #(.CELLS(CELLS)) stability_dut(
    .clk, .rst_n(reset_n[2]), .tick_enable(enabled[2]), .retained_state,
    .raw_phase_coherence_q30, .cluster_coherence_q30, .heat_q16,
    .thermal_overload_q16, .frequency_lag_q16, .switch_load_q16,
    .mean_heat_q16, .mean_thermal_overload_q16, .mean_frequency_lag_q16,
    .neutral_fraction_q30, .compression_arg_q16, .next_coherence_compression_q30,
    .next_effective_coherence_q30, .next_coherence_capacity_q16, .next_pressure_q16,
    .next_stability_margin_q16, .next_stable, .coherence_compression_q30,
    .effective_coherence_q30, .coherence_capacity_q16, .pressure_q16,
    .stability_margin_q16, .stable, .previous_margin_q16);

  gamma_t gq[CELLS], gd[CELLS];
  word_t aq[CELLS], ad[CELLS], exponential[4096];
  stability_t sq, sd;
  word_t history=39322;
  longint unsigned checks[3]='{default:0};
  longint unsigned signatures[3]='{default:64'hcbf29ce484222325};
  int commits[3]='{default:0}, holds[3]='{default:0}, resets[3]='{default:0};
  int probes=0, edges=0, matrix_cases=0, boundaries=0, random_cases=0;
  bit [127:0] matrix_seen='0;
  bit [4095:0] address_seen[CELLS];
  bit [7:0] event_seen='0;
  int unsigned rng=32'h873a0d65;

  function automatic word_t sat(input longint signed x);
    if (x>2147483647) return MAX32;
    if (x< -64'sd2147483648) return MIN32;
    return word_t'(x);
  endfunction
  function automatic longint signed rnd(input longint signed x, d);
    return x<0 ? -((-x+d/2)/d) : (x+d/2)/d;
  endfunction
  function automatic word_t mul(input word_t a,b, input int fraction);
    return sat(rnd(longint'(a)*longint'(b),64'sd1<<fraction));
  endfunction
  function automatic word_t phase(input word_t x);
    longint signed a,v;
    a=longint'(x); if (a<0) a=-a;
    v=a*64'sd10430+(a*64'sd1625002897+64'sd2147483648)/64'sd4294967296;
    return word_t'(x<0 ? -v : v);
  endfunction
  function automatic int address(input word_t x);
    longint signed clipped;
    clipped=longint'(x);
    if (clipped<0) clipped=0;
    if (clipped>524288) clipped=524288;
    return int'((clipped*4095+262144)/524288);
  endfunction
  function automatic int unsigned random_word();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction
  function automatic word_t boundary(input int k);
    case(k%16)
      0:return MIN32; 1:return MIN32+1; 2:return -65537;
      3:return -32768; 4:return -2; 5:return -1;
      6:return 0; 7:return 1; 8:return 2; 9:return 32768;
      10:return 65536; 11:return 419429; 12:return 419430;
      13:return 419431; 14:return MAX32-1; default:return MAX32;
    endcase
  endfunction

  task automatic candidate();
    longint signed hs,os,ls,zeros,deficit,total;
    word_t gain,radians,thermal_square,margin_square;
    hs=0; os=0; ls=0; zeros=0;
    for(int c=0;c<CELLS;c++) begin
      gd[c].target=gamma_update_valid ? word_t'(gamma_targets_q16[c*32+:32]) : gq[c].target;
      gd[c].noise=sat(longint'(gq[c].noise)+longint'(sat(rnd(
        (longint'(gd[c].target)-longint'(gq[c].noise))*9830,65536))));
      gain=mul(5243,word_t'(thermal_overload_q16[c*32+:32]),16);
      radians=mul(gain,gd[c].noise,16);
      gd[c].drift=phase(radians);
      gd[c].effective=word_t'(longint'(NOMINAL)+longint'(gd[c].drift));
      ad[c]=exponential[address(sat(rnd(longint'(
        word_t'(thermal_overload_q16[c*32+:32]))*5,4)))];
      hs+=longint'(word_t'(heat_q16[c*32+:32]));
      os+=longint'(word_t'(thermal_overload_q16[c*32+:32]));
      ls+=longint'(word_t'(frequency_lag_q16[c*32+:32]));
      if(retained_state[c*2+:2]==0) zeros++;
    end
    sd.heat=sat(rnd(hs,longint'(CELLS))); sd.overload=sat(rnd(os,longint'(CELLS)));
    sd.lag=sat(rnd(ls,longint'(CELLS))); sd.neutral=sat(rnd(zeros*1073741824,longint'(CELLS)));
    deficit=16384-longint'(history); if(deficit<0) deficit=0;
    margin_square=sat(rnd(deficit*deficit,65536));
    thermal_square=mul(sd.overload,sd.overload,16);
    sd.argument=sat(longint'(mul(196608,thermal_square,16))+
      longint'(mul(98304,margin_square,16)));
    sd.compression=exponential[address(sd.argument)];
    sd.effective=mul(raw_phase_coherence_q30,sd.compression,30);
    total=53740+longint'(mul(22282,sd.effective,30))+
      longint'(mul(10486,cluster_coherence_q30,30))+
      longint'(mul(5243,sd.neutral,30))-longint'(mul(6554,sd.lag,16));
    sd.capacity=sat(total);
    sd.pressure=sat(longint'(sd.heat)+longint'(switch_load_q16));
    sd.margin=sat(longint'(sd.capacity)-longint'(sd.pressure));
    sd.stable=sd.margin>0;
  endtask

  task automatic equal_word(input int test_id, input string label,
                            input word_t actual, expected);
    checks[test_id]++;
    if(actual!==expected)
      $fatal(1,"FEEDBACK cells=%0d test=%0d probe=%0d %s actual=%0d expected=%0d",
        CELLS,test_id,probes,label,actual,expected);
    signatures[test_id]=(signatures[test_id]^{32'b0,$unsigned(actual)})*64'h100000001b3;
  endtask

  task automatic probe();
    candidate(); #1;
    for(int c=0;c<CELLS;c++) begin
      equal_word(0,"target",gamma_noise_target_q16[c*32+:32],gq[c].target);
      equal_word(0,"noise",gamma_noise_state_q16[c*32+:32],gq[c].noise);
      equal_word(0,"drift",gamma_drift_word[c*32+:32],gq[c].drift);
      equal_word(0,"effective",gamma_effective_word[c*32+:32],gq[c].effective);
      equal_word(0,"next_drift",next_gamma_drift_word[c*32+:32],gd[c].drift);
      equal_word(0,"next_effective",next_gamma_effective_word[c*32+:32],gd[c].effective);
      equal_word(1,"factor",thermal_node_factor_q30[c*32+:32],aq[c]);
      equal_word(1,"next_factor",next_thermal_node_factor_q30[c*32+:32],ad[c]);
      address_seen[c][address(sat(rnd(longint'(
        word_t'(thermal_overload_q16[c*32+:32]))*5,4)))]=1;
    end
    equal_word(2,"mean_heat",mean_heat_q16,sd.heat);
    equal_word(2,"mean_overload",mean_thermal_overload_q16,sd.overload);
    equal_word(2,"mean_lag",mean_frequency_lag_q16,sd.lag);
    equal_word(2,"neutral",neutral_fraction_q30,sd.neutral);
    equal_word(2,"argument",compression_arg_q16,sd.argument);
    equal_word(2,"next_compression",next_coherence_compression_q30,sd.compression);
    equal_word(2,"next_coherence",next_effective_coherence_q30,sd.effective);
    equal_word(2,"next_capacity",next_coherence_capacity_q16,sd.capacity);
    equal_word(2,"next_pressure",next_pressure_q16,sd.pressure);
    equal_word(2,"next_margin",next_stability_margin_q16,sd.margin);
    equal_word(2,"next_stable",word_t'(next_stable),word_t'(sd.stable));
    equal_word(2,"compression",coherence_compression_q30,sq.compression);
    equal_word(2,"coherence",effective_coherence_q30,sq.effective);
    equal_word(2,"capacity",coherence_capacity_q16,sq.capacity);
    equal_word(2,"pressure",pressure_q16,sq.pressure);
    equal_word(2,"margin",stability_margin_q16,sq.margin);
    equal_word(2,"stable",word_t'(stable),word_t'(sq.stable));
    equal_word(2,"history",previous_margin_q16,history);
    if(sd.pressure==MAX32) event_seen[0]=1;
    if(sd.pressure==MIN32) event_seen[1]=1;
    if(history==MAX32) event_seen[2]=1;
    if(history==MIN32) event_seen[3]=1;
    if(sd.margin==0) event_seen[4]=1;
    if(sd.margin>0) event_seen[5]=1;
    if(sd.margin<0) event_seen[6]=1;
    if(sd.argument==MAX32) event_seen[7]=1;
    probes++;
  endtask

  task automatic reset_model(input bit [2:0] mask);
    if(mask[0]) for(int c=0;c<CELLS;c++) gq[c]='{0,0,0,NOMINAL};
    if(mask[1]) for(int c=0;c<CELLS;c++) aq[c]=UNITY;
    if(mask[2]) begin
      sq='0; sq.compression=UNITY; sq.capacity=65536;
      sq.pressure=3277; sq.margin=62259; sq.stable=1; history=39322;
    end
  endtask
  task automatic reset_blocks(input bit [2:0] mask);
    clk=0; reset_n=~mask; reset_model(mask);
    for(int t=0;t<3;t++) if(mask[t]) resets[t]++;
    probe();
  endtask
  task automatic edge_step(input bit [2:0] mask);
    clk=0; enabled=mask; probe();
    // All models consume the same pre-edge input snapshot.
    if(reset_n[0] && enabled[0]) for(int c=0;c<CELLS;c++) gq[c]=gd[c];
    if(reset_n[1] && enabled[1]) for(int c=0;c<CELLS;c++) aq[c]=ad[c];
    if(reset_n[2] && enabled[2]) begin sq=sd; history=sd.margin; end
    reset_model(~reset_n);
    for(int t=0;t<3;t++) begin
      if(reset_n[t] && enabled[t]) commits[t]++;
      else if(reset_n[t]) holds[t]++;
    end
    clk=1; #1; probe(); clk=0; #1; edges++;
  endtask
  task automatic release_blocks();
    reset_n=7; probe();
  endtask
  task automatic inputs(input int iteration, input bit full_range);
    for(int c=0;c<CELLS;c++) begin
      gamma_targets_q16[c*32+:32]=full_range ? word_t'(random_word()) : boundary(iteration+c);
      thermal_overload_q16[c*32+:32]=full_range ? word_t'(random_word()) : boundary(iteration+3*c+1);
      heat_q16[c*32+:32]=full_range ? word_t'(random_word()) : boundary(iteration+5*c+2);
      frequency_lag_q16[c*32+:32]=full_range ? word_t'(random_word()) : boundary(iteration+7*c+3);
      retained_state[c*2+:2]=2'((iteration+c)%4);
    end
    raw_phase_coherence_q30=full_range ? word_t'(random_word()) : boundary(iteration+4);
    cluster_coherence_q30=full_range ? word_t'(random_word()) : boundary(iteration+5);
    switch_load_q16=full_range ? word_t'(random_word()) : boundary(iteration+6);
  endtask

  initial begin : run
    longint signed minimum_arg;
    word_t first, wanted;
    int index;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    for(int i=0;i<4096;i++) exponential[i]=word_t'($rtoi(
      $exp(-8.0*real'(i)/4095.0)*1073741824.0+0.5));
    if(exponential[0]!=UNITY || exponential[4095]!=360200)
      $fatal(1,"Exponential reference endpoints");
    foreach(address_seen[c]) address_seen[c]='0;
    #1; reset_blocks(7); edge_step(7); release_blocks();

    // Every enable/reset/target-valid combination, after nonzero history.
    for(int rm=0;rm<8;rm++) for(int em=0;em<8;em++) for(int v=0;v<2;v++) begin
      gamma_update_valid=1;
      for(int warm=0;warm<8;warm++) begin inputs(warm+rm+em,0); edge_step(7); end
      inputs(rm*16+em*2+v,1); gamma_update_valid=1'(v); enabled=3'(em);
      reset_blocks(3'(rm));
      edge_step(3'(em));
      inputs(rm+em+v,0); probe();
      edge_step(3'(em)); release_blocks();
      edge_step(0); edge_step(3'(em)); edge_step(7);
      matrix_seen[rm*16+em*2+v]=1; matrix_cases++;
    end

    // Independent pauses at every attenuation lookup boundary in every cell.
    // Other consumers receive the same changing overload throughout.
    for(int a=1;a<4096;a++) for(int side=-1;side<=1;side++) begin
      inputs(a,0); gamma_update_valid=1'(a);
      for(int c=0;c<CELLS;c++) begin
        index=1+((a-1+127*c)%4095);
        minimum_arg=(longint'(index)*524288-262144+4094)/4095;
        first=word_t'((4*minimum_arg-2+4)/5);
        thermal_overload_q16[c*32+:32]=first+word_t'(side);
      end
      edge_step(3'(a+side+1)); boundaries++;
    end

    // Exact stability thresholds and saturated histories reached through ports.
    for(int k=0;k<8;k++) begin
      gamma_targets_q16='0; thermal_overload_q16='0;
      heat_q16='0; frequency_lag_q16='0; retained_state='0;
      raw_phase_coherence_q30=0; cluster_coherence_q30=0; switch_load_q16=0;
      reset_blocks(4); release_blocks(); candidate();
      if(k<6) begin
        wanted=word_t'((k/3)*16384+k%3-1);
        switch_load_q16=sd.capacity-wanted;
      end else begin
        wanted=(k==6)?MIN32:MAX32;
        for(int c=0;c<CELLS;c++) begin
          heat_q16[c*32+:32]=(k==6)?MAX32:MIN32;
          thermal_overload_q16[c*32+:32]=(k==6)?MAX32:MIN32;
          frequency_lag_q16[c*32+:32]=(k==6)?MAX32:MIN32;
        end
        switch_load_q16=(k==6)?MAX32:MIN32;
      end
      edge_step(7);
      if(history!==wanted) $fatal(1,"Directed history was not reached");
      for(int h=0;h<8;h++) begin inputs(h+k,1); edge_step(3'(h%4)); end
    end

    for(int i=0;i<8192;i++) begin
      inputs(i,1); gamma_update_valid=1'(random_word());
      if(i%127==0) begin reset_blocks(3'(i/127)); release_blocks(); end
      edge_step(3'(random_word())); random_cases++;
    end
    if(matrix_seen!='1 || matrix_cases!=128 || boundaries!=12285 || random_cases!=8192)
      $fatal(1,"Incomplete stimulus matrix");
    if(event_seen!=8'hff) $fatal(1,"Missing arithmetic event mask=%h",event_seen);
    foreach(address_seen[c]) if(address_seen[c]!='1)
      $fatal(1,"Incomplete attenuation addresses cell=%0d count=%0d",c,$countones(address_seen[c]));
    for(int t=0;t<3;t++) begin
      if(commits[t]==0 || holds[t]==0 || resets[t]==0) $fatal(1,"Missing history operation");
      if(checks[t]!=longint'(probes)*((t==0)?6*CELLS:(t==1)?2*CELLS:18))
        $fatal(1,"Output accounting mismatch");
      $display("PASS FEEDBACK_SNAPSHOT cells=%0d test=%0d probes=%0d checks=%0d commits=%0d holds=%0d resets=%0d signature=%016h",
        CELLS,t,probes,checks[t],commits[t],holds[t],resets[t],signatures[t]);
    end
    $display("FEEDBACK_MATRIX cells=%0d edges=%0d cases=%0d boundaries=%0d random=%0d rom_cell_pairs=%0d events=%02h",
      CELLS,edges,matrix_cases,boundaries,random_cases,4096*CELLS,event_seen);
    $finish;
  end
  initial begin #10000000; $fatal(1,"Feedback snapshot timeout"); end
endmodule

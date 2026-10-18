// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Included dependencies retain their existing licenses.
// Independent input-driven phase/coupling recurrence, using signed 128-bit
// arithmetic, analytic sine quantization and formula-derived dyadic weights.
// Weight contract: quantized_level_weights(N, 0.70), frp_prototype_v1_7_0.py.
// No DUT outputs, arithmetic helpers or ROM contents feed the reference state.
// Retained state and switch activity are upstream inputs; targets are checked
// separately. Scheduler inputs exercise free, 7/1 and 1/7 cadences.
// Compile from repository root: --binary --timing --assert -Irtl/m31
// --top-module frp_m31_coupling_oracle_tb -GCELLS=8 (or 16, 32, 64).
`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_coupling_oracle_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  typedef logic signed [127:0] wide_t;
  typedef logic [32*CELLS-1:0] bank_t;
  localparam int DEPTH=$clog2(CELLS);
  logic clk=0, rst_n=1, tick_enable=0, load_valid=0;
  bank_t phase_load='0, frequency_load='0, gamma_input='0, thermal='0;
  wire [32*CELLS-1:0] phase, frequency, coupling, projection;
  logic [2*CELLS-1:0] retained='0;
  wire [2*CELLS-1:0] target;
  logic [CELLS-1:0] activity='0;
  frp_m31_scheduler_state_e scheduler_state=FRP_SCHED_FREE;
  logic [31:0] mp[CELLS], next_phase[CELLS];
  word_t mf[CELLS], next_frequency[CELLS], sine[4096], weights[DEPTH+1];
  bit [4095:0] addresses='0;
  bit [2:0] residues='0;
  bit [29:0] state_cross='0;
  int cadence[5]='{default:0};
  longint unsigned checks=0, loads=0, updates=0, holds=0, edges=0;
  longint unsigned positive=0, negative=0, isolated=0, neutral_updates=0;
  longint unsigned pair_cases=0, boundary_cases=0, load_ticks=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  int stage=0, step_id=0;

  frp_m31_phase_interference #(.CELLS(CELLS)) dut (
    .clk, .rst_n, .tick_enable, .load_valid, .phase_load,
    .frequency_load_q16(frequency_load), .gamma_effective_word(gamma_input),
    .thermal_node_factor_q30(thermal), .retained_state(retained),
    .switch_activity(activity), .scheduler_state,
    .phase_word_q(phase), .frequency_current_q16(frequency),
    .coupling_field_q16(coupling), .phase_projection_q30(projection), .phase_target(target),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30(), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(),
    .level_max_coherence_q30(), .level_dispersion_q30()
  );

  function automatic wide_t rounded(input wide_t value, divisor);
    /*verilator no_inline_task*/
    wide_t q, r;
    q=value/divisor; r=value%divisor;
    if(2*r>=divisor) q++;
    if(2*r<=-divisor) q--;
    return q;
  endfunction
  function automatic word_t clip(input wide_t value);
    if(value>2147483647) return 32'sh7fffffff;
    if(value< -128'sd2147483648) return 32'sh80000000;
    return word_t'(value);
  endfunction
  function automatic word_t mul(input word_t a,b, input int bits);
    /*verilator no_inline_task*/
    return clip(rounded(wide_t'(a)*wide_t'(b),128'sd1<<bits));
  endfunction
  function automatic logic [31:0] pattern(input int c,t,salt);
    logic [31:0] x;
    x=32'h9e3779b9^(32'(c+1)*32'h85ebca6b)
      ^(32'(t+1)*32'hc2b2ae35)^(32'(salt+1)*32'h27d4eb2d);
    x^=x<<13; x^=x>>17; x^=x<<5;
    return x;
  endfunction
  function automatic word_t field(input int i);
    wide_t sum;
    word_t attenuation, weighted;
    logic [31:0] relative_word;
    int level;
    sum=0;
    for(int j=0;j<CELLS;j++) if(j!=i) begin
      level=1;
      while(i/(1<<level)!=j/(1<<level)) level++;
      relative_word=mp[j]-mp[i]-gamma_input[32*i+:32];
      attenuation=mul(word_t'(thermal[32*i+:32]),word_t'(thermal[32*j+:32]),30);
      weighted=mul(weights[level],attenuation,30);
      sum+=wide_t'(mul(weighted,sine[relative_word>>20],30));
    end
    return mul(18350,clip(rounded(wide_t'(clip(sum)),16384)),16);
  endfunction
  task automatic equal_word(input string label,input int lane,
                            input logic [31:0] actual,expected);
    checks++;
    if(actual!==expected)
      $fatal(1,"COUPLING_ORACLE cells=%0d stage=%0d step=%0d lane=%0d %s got=%h expected=%h",
             CELLS,stage,step_id,lane,label,actual,expected);
    signature=(signature^{32'd0,actual})*64'h100000001b3;
  endtask
  task automatic inspect();
    word_t f,s;
    logic [1:0] wanted;
    logic [31:0] relative_word;
    for(int c=0;c<CELLS;c++) begin
      f=field(c); s=sine[mp[c]>>20];
      wanted=s>354334802?2'b01:(s< -354334802?2'b11:2'b00);
      equal_word("phase",c,phase[32*c+:32],mp[c]);
      equal_word("frequency",c,frequency[32*c+:32],mf[c]);
      equal_word("coupling",c,coupling[32*c+:32],f);
      equal_word("projection",c,projection[32*c+:32],s);
      equal_word("target",c,{30'd0,target[2*c+:2]},{30'd0,wanted});
      if(f>0) positive++;
      if(f<0) negative++;
      if(thermal[32*c+:32]==0) begin
        equal_word("isolated",c,coupling[32*c+:32],0); isolated++;
      end
      for(int j=0;j<CELLS;j++) if(j!=c && thermal[32*c+:32]!=0 && thermal[32*j+:32]!=0) begin
        relative_word=mp[j]-mp[c]-gamma_input[32*c+:32];
        addresses[relative_word>>20]=1;
      end
    end
  endtask
  task automatic sample(input bit enable,reload);
    word_t f,delta,velocity,push_value;
    wide_t wanted;
    int state_index;
    clk=0; tick_enable=enable; load_valid=reload; #1; inspect();
    if(reload) begin
      for(int c=0;c<CELLS;c++) begin
        mp[c]=phase_load[32*c+:32]; mf[c]=word_t'(frequency_load[32*c+:32]);
      end
      loads++; if(enable) load_ticks++;
    end else if(enable) begin
      push_value=scheduler_state==FRP_SCHED_COMMIT?655:
        (scheduler_state==FRP_SCHED_EXCITE?393:197);
      for(int c=0;c<CELLS;c++) begin
        f=field(c);
        wanted=65536+(retained[2*c+:2]!=0?3932:0)+(activity[c]?7864:0);
        delta=clip(rounded((wanted-wide_t'(mf[c]))*19661,65536));
        next_frequency[c]=clip(wide_t'(mf[c])+wide_t'(delta));
        velocity=word_t'(mul(next_frequency[c],3932,16)+push_value+f);
        next_phase[c]=mp[c]+32'(rounded(wide_t'(velocity)*128'sd44798133900177,
                                       128'sd4294967296));
        state_index=retained[2*c+:2]==0?0:(retained[2*c+:2]==1?1:2);
        state_cross[int'(scheduler_state)*6+state_index*2+int'(activity[c])]=1;
        if(state_index==0 && next_phase[c]!=mp[c]) neutral_updates++;
      end
      for(int c=0;c<CELLS;c++) begin mp[c]=next_phase[c]; mf[c]=next_frequency[c]; end
      updates++; cadence[int'(scheduler_state)]++;
    end else holds++;
    clk=1; #1; inspect(); clk=0; #1; edges++;
  endtask
  task automatic reset_model();
    clk=0; tick_enable=0; load_valid=0; rst_n=0;
    for(int c=0;c<CELLS;c++) begin
      mp[c]=32'(c)*(32'hffffffff/CELLS+1); mf[c]=65536;
    end
    #1; inspect(); rst_n=1; #1;
  endtask
  task automatic dynamic_inputs(input int t,mode_id);
    for(int c=0;c<CELLS;c++) begin
      phase_load[32*c+:32]=pattern(c,t,mode_id);
      case(c%4)
        0:frequency_load[32*c+:32]=32'h80000000;
        1:frequency_load[32*c+:32]=32'h7fffffff;
        2:frequency_load[32*c+:32]=0;
        default:frequency_load[32*c+:32]=pattern(c,t,5);
      endcase
      gamma_input[32*c+:32]=pattern(c,t,17);
      case((c+t)%5)
        0:thermal[32*c+:32]=0;
        1:thermal[32*c+:32]=1;
        2:thermal[32*c+:32]=32'h20000001;
        3:thermal[32*c+:32]=32'h3fffffff;
        default:thermal[32*c+:32]=32'h40000000;
      endcase
      case((c+t)%3)
        0:retained[2*c+:2]=0;
        1:retained[2*c+:2]=1;
        default:retained[2*c+:2]=3;
      endcase
      activity[c]=1'((c+t/3)%2);
    end
    case(mode_id)
      0:scheduler_state=FRP_SCHED_FREE;
      1:scheduler_state=t%8==7?FRP_SCHED_COMMIT:FRP_SCHED_BALANCE;
      default:scheduler_state=t%8==0?FRP_SCHED_EXCITE:FRP_SCHED_NEUTRALIZE;
    endcase
  endtask

  initial begin : campaign
    real normalizer,value;
    wide_t aggregate;
    int partner;
    logic [31:0] desired;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    normalizer=0.0;
    for(int d=1;d<=DEPTH;d++) normalizer+=1.0/(real'(d)**0.70);
    aggregate=0; weights[0]=0;
    for(int d=1;d<=DEPTH;d++) begin
      value=1073741824.0/(real'(1<<(d-1))*(real'(d)**0.70)*normalizer);
      weights[d]=$rtoi(value+0.5); aggregate+=wide_t'(weights[d])*(128'sd1<<(d-1));
    end
    weights[1]+=word_t'(128'sd1073741824-aggregate);
    aggregate=0;
    for(int d=1;d<=DEPTH;d++) aggregate+=wide_t'(weights[d])*(128'sd1<<(d-1));
    if(aggregate!=1073741824) $fatal(1,"Weight normalization");
    for(int a=0;a<4096;a++) begin
      value=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*1073741824.0;
      sine[a]=$rtoi(value<0.0?value-0.5:value+0.5);
    end
    reset_model();
    // Every relative LUT address at boundary-1, boundary, boundary+1,
    // separately targeting each dyadic shell with nonuniform receiver gamma.
    stage=1;
    for(int shell=1;shell<=DEPTH;shell++)
      for(int residue=-1;residue<=1;residue++)
        for(int base=0;base<4096;base+=CELLS) begin
          for(int c=0;c<CELLS;c++) phase_load[32*c+:32]=pattern(c,base,shell);
          for(int c=0;c<CELLS;c++) begin
            partner=c^(1<<(shell-1)); desired=(32'(base+c)<<20)+32'(residue);
            gamma_input[32*c+:32]=phase_load[32*partner+:32]-phase_load[32*c+:32]-desired;
            thermal[32*c+:32]=32'h40000000; frequency_load[32*c+:32]=65536;
          end
          sample(1,1); sample(0,0); residues[residue+1]=1; boundary_cases++; step_id++;
        end
    $display("COUPLING_ORACLE_BOUNDARIES cells=%0d cases=%0d addresses=%0d residues=%0d",
             CELLS,boundary_cases,$countones(addresses),$countones(residues));
    // Isolate every ordered pair at both quadratures, retaining receiver gamma.
    stage=2;
    for(int a=0;a<CELLS;a++) for(int b=0;b<CELLS;b++) if(a!=b)
      for(int sign_id=0;sign_id<2;sign_id++) begin
        phase_load='0; thermal='0; gamma_input='0;
        thermal[32*a+:32]=32'h3fffffff; thermal[32*b+:32]=32'h20000001;
        gamma_input[32*a+:32]=32'h000fffff;
        phase_load[32*b+:32]=(sign_id==0?32'h40000000:32'hc0000000)+32'h000fffff;
        sample(1,1); pair_cases++; step_id++;
      end
    $display("COUPLING_ORACLE_PAIRS cells=%0d cases=%0d",CELLS,pair_cases);
    // All receivers aligned, nonzero gamma: self interaction must be excluded.
    stage=3;
    phase_load='0;
    for(int c=0;c<CELLS;c++) begin thermal[32*c+:32]=32'h40000000; gamma_input[32*c+:32]=32'h40000000; end
    sample(0,1);
    for(int c=0;c<CELLS;c++) equal_word("aligned_no_self",c,coupling[32*c+:32],32'(-18350));
    // Fully independent trajectories with per-update gamma/thermal changes.
    stage=4;
    for(int mode_id=0;mode_id<3;mode_id++) begin
      dynamic_inputs(0,mode_id); reset_model();
      for(int t=0;t<512;t++) begin
        step_id=t; dynamic_inputs(t,mode_id);
        if(t%64==0) sample(1,1);
        if(t%7==0) sample(0,0);
        sample(1,0);
      end
      $display("COUPLING_ORACLE_DYNAMICS cells=%0d mode=%0d updates=512 loads=8 holds=74",CELLS,mode_id);
    end
    if(addresses!=='1 || residues!=3'b111 || state_cross!==30'h3fffffff
        || boundary_cases!=64'(DEPTH*3*4096/CELLS) || pair_cases!=64'(2*CELLS*(CELLS-1))
        || updates!=1536 || loads!=boundary_cases+pair_cases+25
        || holds!=boundary_cases+222 || load_ticks!=boundary_cases+pair_cases+24
        || edges!=loads+updates+holds || cadence[0]!=512 || cadence[1]!=448
        || cadence[2]!=64 || cadence[3]!=64 || cadence[4]!=448
        || positive==0 || negative==0 || isolated==0 || neutral_updates==0)
      $fatal(1,"COUPLING_ORACLE coverage incomplete cross=%h",state_cross);
    $display("FRP_COUPLING_ORACLE_PASS cells=%0d edges=%0d checks=%0d loads=%0d updates=%0d holds=%0d boundary=%0d pairs=%0d positive=%0d negative=%0d isolated=%0d neutral=%0d signature=%016h",
             CELLS,edges,checks,loads,updates,holds,boundary_cases,pair_cases,
             positive,negative,isolated,neutral_updates,signature);
    $finish;
  end
  initial begin #100000; $fatal(1,"COUPLING_ORACLE watchdog"); end
endmodule

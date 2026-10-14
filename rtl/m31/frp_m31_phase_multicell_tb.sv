// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M31 coupled phase dynamics and multiscale coherence, 8/16/32 cells.
// Build from the repository root with --binary --timing --assert -Irtl/m31
// and --top-module frp_m31_phase_multicell_tb.
// The oracle uses analytic sine samples, integer division and binary-search
// roots. Expected state is retained independently of DUT outputs and helpers.
// Scheduler stimuli follow free, 7/1 and 1/7 cadence for phase-engine inputs.
// Boundary targets are checked separately from supplied retained ternary state.

`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_phase_multicell_checker #(
  parameter int CELLS=8
)(output logic done=0);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  localparam int DEPTH=$clog2(CELLS);
  localparam longint signed ONE=1073741824;
  logic clk=0, rst_n=1, tick_enable=0, load_valid=0;
  logic [CELLS*32-1:0] phase_load='0, frequency_load_q16='0;
  logic [CELLS*32-1:0] gamma_effective_word='0;
  logic [CELLS*32-1:0] thermal_node_factor_q30={CELLS{32'h40000000}};
  logic [CELLS*2-1:0] retained_state='0;
  logic [CELLS-1:0] switch_activity='0;
  frp_m31_scheduler_state_e scheduler_state=FRP_SCHED_FREE;
  wire [CELLS*32-1:0] phase_word_q, frequency_current_q16;
  wire [CELLS*32-1:0] coupling_field_q16, phase_projection_q30;
  wire [CELLS*2-1:0] phase_target;
  wire signed [31:0] pair_coherence_q30, cluster_coherence_q30;
  wire signed [31:0] global_coherence_q30, organization_dispersion_q30;
  wire [(CELLS-1)*32-1:0] group_coherence_q30;
  wire [DEPTH*32-1:0] level_mean_coherence_q30, level_min_coherence_q30;
  wire [DEPTH*32-1:0] level_max_coherence_q30, level_dispersion_q30;
  frp_m31_phase_interference #(.CELLS(CELLS)) dut(.*);

  logic [31:0] phase[CELLS];
  word_t frequency[CELLS], sine_table[4096], coupling[CELLS];
  word_t groups[CELLS-1], means[DEPTH], deviations[DEPTH];
  logic [4095:0] projection_seen='0, relative_seen='0;
  bit [29:0] state_cross='0;
  int target_bins[3];
  int samples=0, checks=0, loads=0, updates=0, holds=0, resets=0;
  int positive_coupling=0, negative_coupling=0, isolated=0, zero_adapts=0;
  int rotations=0, permutations=0, shell_cases=0, random_steps=0;
  int wraps=0, load_priority=0;
  int unsigned rng=32'h31c08e57;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic logic [31:0] next_word();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction

  function automatic longint signed rounded(input longint signed v, d);
    /*verilator no_inline_task*/
    longint signed q, r;
    if (d<=0) $fatal(1,"Reference denominator must be positive");
    q=v/d; r=v%d;
    if (2*r>=d) q++;
    if (2*r<=-d) q--;
    return q;
  endfunction

  function automatic word_t clipped(input longint signed v);
    /*verilator no_inline_task*/
    if (v>2147483647) return 32'sh7fffffff;
    if (v< -64'sd2147483648) return 32'sh80000000;
    return word_t'(v);
  endfunction

  function automatic word_t product(input word_t a,b, input int fraction);
    /*verilator no_inline_task*/
    return clipped(rounded(longint'(a)*longint'(b),64'sd1<<fraction));
  endfunction

  function automatic word_t root_floor(input longint unsigned square);
    /*verilator no_inline_task*/
    longint unsigned lo,hi,mid;
    lo=0; hi=64'd4294967296;
    while (hi-lo>1) begin
      mid=(lo+hi)/2;
      if (mid*mid<=square) lo=mid; else hi=mid;
    end
    if (lo*lo>square || (lo+1)*(lo+1)<=square)
      $fatal(1,"Reference root bounds");
    return word_t'(lo);
  endfunction

  function automatic word_t weight(input int a,b);
    /*verilator no_inline_task*/
    int span,level;
    // Find the smallest aligned dyadic block containing both cells.
    span=2; level=0;
    while (a/span!=b/span) begin span*=2; level++; end
    case(CELLS)
      8: case(level)
        0:return 516461574; 1:return 158959695; default:return 59840215;
      endcase
      16: case(level)
        0:return 436841896; 1:return 134453864;
        2:return 50615020; default:return 20691515;
      endcase
      default: case(level)
        0:return 385947114; 1:return 118789159; 2:return 44718058;
        3:return 18280826; default:return 7818597;
      endcase
    endcase
  endfunction

  function automatic word_t field_for(input int receiver);
    longint signed sum;
    word_t factor, term;
    logic [31:0] relative_phase;
    sum=0;
    for (int j=0;j<CELLS;j++) if (j!=receiver) begin
      relative_phase=phase[j]-phase[receiver]-gamma_effective_word[receiver*32+:32];
      relative_seen[relative_phase[31:20]]=1;
      factor=product(word_t'(thermal_node_factor_q30[receiver*32+:32]),
                     word_t'(thermal_node_factor_q30[j*32+:32]),30);
      term=product(product(weight(receiver,j),factor,30),
                   sine_table[relative_phase[31:20]],30);
      sum+=longint'(term);
    end
    return product(18350,clipped(rounded(longint'(clipped(sum)),16384)),16);
  endfunction

  function automatic word_t order_for(input int start,count);
    longint signed sx,sy,mx,my;
    word_t magnitude;
    int address;
    sx=0; sy=0;
    for (int c=start;c<start+count;c++) begin
      address=int'(phase[c]>>20);
      sx+=longint'(sine_table[(address+1024)%4096]);
      sy+=longint'(sine_table[address]);
    end
    mx=rounded(sx,count); my=rounded(sy,count);
    magnitude=root_floor(64'(mx*mx+my*my));
    return (longint'(magnitude)>ONE)?word_t'(ONE):magnitude;
  endfunction

  task automatic equal_word(input string label, input int index,
                            input logic [31:0] got,want);
    checks++;
    if (got!==want)
      $fatal(1,"PHASE cells=%0d sample=%0d %s[%0d] got=%h expected=%h",
        CELLS,samples,label,index,got,want);
    signature=(signature^{32'b0,got})*64'h100000001b3;
  endtask

  task automatic check_all();
    word_t s,target,minimum,maximum;
    longint signed sum,delta,variance,gap;
    int base,count;
    for (int c=0;c<CELLS;c++) begin
      s=sine_table[phase[c][31:20]];
      projection_seen[phase[c][31:20]]=1;
      target=(s>354334802)?1:((s< -354334802)?3:0);
      target_bins[(target==3)?0:((target==0)?1:2)]++;
      coupling[c]=field_for(c);
      if (coupling[c]>0) positive_coupling++;
      if (coupling[c]<0) negative_coupling++;
      if (thermal_node_factor_q30[c*32+:32]==0) begin
        equal_word("isolated",c,coupling_field_q16[c*32+:32],0); isolated++;
      end
      equal_word("phase",c,phase_word_q[c*32+:32],phase[c]);
      equal_word("frequency",c,frequency_current_q16[c*32+:32],frequency[c]);
      equal_word("projection",c,phase_projection_q30[c*32+:32],s);
      equal_word("target",c,32'(phase_target[c*2+:2]),target);
      equal_word("coupling",c,coupling_field_q16[c*32+:32],coupling[c]);
    end
    base=0;
    for (int level=1;level<=DEPTH;level++) begin
      count=CELLS/(1<<level); sum=0; minimum=word_t'(ONE); maximum=0;
      for (int g=0;g<count;g++) begin
        groups[base+g]=order_for(g*(1<<level),1<<level);
        equal_word("group",base+g,group_coherence_q30[(base+g)*32+:32],groups[base+g]);
        sum+=longint'(groups[base+g]);
        if (groups[base+g]<minimum) minimum=groups[base+g];
        if (groups[base+g]>maximum) maximum=groups[base+g];
      end
      means[level-1]=word_t'(rounded(sum,count)); variance=0;
      for (int g=0;g<count;g++) begin
        delta=longint'(groups[base+g])-longint'(means[level-1]);
        variance+=delta*delta;
      end
      deviations[level-1]=root_floor(64'(variance/count));
      equal_word("mean",level,level_mean_coherence_q30[(level-1)*32+:32],means[level-1]);
      equal_word("minimum",level,level_min_coherence_q30[(level-1)*32+:32],minimum);
      equal_word("maximum",level,level_max_coherence_q30[(level-1)*32+:32],maximum);
      equal_word("deviation",level,level_dispersion_q30[(level-1)*32+:32],deviations[level-1]);
      base+=count;
    end
    equal_word("pair",0,pair_coherence_q30,means[0]);
    equal_word("cluster",0,cluster_coherence_q30,means[1]);
    equal_word("global",0,global_coherence_q30,groups[CELLS-2]);
    gap=longint'(groups[CELLS/2])-longint'(groups[CELLS/2+1]);
    if (gap<0) gap=-gap;
    equal_word("organization",0,organization_dispersion_q30,
      (CELLS==8)?word_t'(rounded(gap,2)):deviations[1]);
  endtask

  task automatic advance();
    word_t target,next_frequency,velocity,correction;
    longint signed delta,magnitude,step_word,total;
    int state_index,push;
    logic [1:0] ternary;
    if (!rst_n) begin
      for (int c=0;c<CELLS;c++) begin
        phase[c]=32'(longint'(c)*(64'sd4294967296/CELLS)); frequency[c]=65536;
      end
      resets++;
    end else if (load_valid) begin
      for (int c=0;c<CELLS;c++) begin
        phase[c]=phase_load[c*32+:32]; frequency[c]=word_t'(frequency_load_q16[c*32+:32]);
      end
      loads++; if (tick_enable) load_priority++;
    end else if (tick_enable) begin
      // Snapshot all relative fields before changing any model phase.
      for (int c=0;c<CELLS;c++) coupling[c]=field_for(c);
      push=(int'(scheduler_state)==2)?655:((int'(scheduler_state)==3)?393:197);
      for (int c=0;c<CELLS;c++) begin
        ternary=retained_state[c*2+:2];
        if (ternary==2) $fatal(1,"Reserved ternary stimulus");
        state_index=(ternary==0)?0:((ternary==1)?1:2);
        state_cross[int'(scheduler_state)*6+state_index*2+int'(switch_activity[c])]=1;
        target=65536+((ternary==0)?0:3932)+(switch_activity[c]?7864:0);
        delta=longint'(target)-longint'(frequency[c]);
        correction=clipped(rounded(delta*19661,65536));
        next_frequency=clipped(longint'(frequency[c])+longint'(correction));
        if (ternary==0 && next_frequency!=frequency[c]) zero_adapts++;
        velocity=word_t'(longint'(product(next_frequency,3932,16))+push+longint'(coupling[c]));
        magnitude=longint'(velocity); if (magnitude<0) magnitude=-magnitude;
        step_word=magnitude*10430+rounded(magnitude*64'sd1625002897,64'sd4294967296);
        if (velocity<0) step_word=-step_word;
        total=longint'({1'b0,phase[c]})+step_word;
        if (total<0 || total>=64'sd4294967296) wraps++;
        phase[c]=32'(total); frequency[c]=next_frequency;
      end
      updates++;
    end else holds++;
  endtask

  task automatic sample(input bit tick,load);
    clk=0; tick_enable=tick; load_valid=load;
    #1; check_all(); advance(); clk=1;
    #1; check_all(); clk=0; #1; samples++;
  endtask

  task automatic reset_dut();
    clk=0; rst_n=0; advance();
    #1; check_all(); rst_n=1; #1;
  endtask

  task automatic random_inputs();
    logic [1:0] prior,desired;
    int choice;
    for (int c=0;c<CELLS;c++) begin
      phase_load[c*32+:32]=next_word(); frequency_load_q16[c*32+:32]=next_word();
      gamma_effective_word[c*32+:32]=next_word();
      thermal_node_factor_q30[c*32+:32]=next_word()%32'd1073741825;
      prior=retained_state[c*2+:2]; choice=int'(next_word()%3);
      desired=(choice==0)?2'b00:((choice==1)?2'b01:2'b11);
      if (prior!=0 && desired!=0 && prior!=desired) desired=0;
      retained_state[c*2+:2]=desired; switch_activity[c]=(desired!=prior);
    end
  endtask

  initial begin : regression
    real scaled;
    logic [CELLS*32-1:0] bank,gamma_bank,thermal_bank,base_coupling;
    logic [DEPTH*32-1:0] base_mean,base_min,base_max,base_deviation;
    logic [127:0] base_orders;
    int cadence[5];
    int state_code,expected_count;
    for (int a=0;a<4096;a++) begin
      scaled=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*1073741824.0;
      sine_table[a]=$rtoi(scaled<0?scaled-0.5:scaled+0.5);
    end
    foreach(target_bins[k]) target_bins[k]=0;
    #1; reset_dut();
    // Every sine address with four distinct sub-address residues.
    for (int low=0;low<4;low++)
      for (int base=0;base<4096;base+=CELLS) begin
        for (int c=0;c<CELLS;c++) begin
          phase_load[c*32+:32]=(32'(base+c)<<20)|32'(low*349525);
          frequency_load_q16[c*32+:32]=32'(65536+c);
          gamma_effective_word[c*32+:32]=32'd644245094;
        end
        sample(0,1);
      end
    // Exhaustive relative-address sweep through receiver-local gamma.
    phase_load='0; sample(0,1);
    for (int a=0;a<4096;a++) begin
      for (int c=0;c<CELLS;c++) gamma_effective_word[c*32+:32]=32'(a)<<20;
      sample(0,0);
    end
    // Every ordered node pair, both coupling signs, isolated thermal edges.
    gamma_effective_word='0;
    for (int a=0;a<CELLS;a++) for (int b=0;b<CELLS;b++) if(a!=b)
      for (int sign_index=0;sign_index<2;sign_index++) begin
        phase_load='0; thermal_node_factor_q30='0;
        thermal_node_factor_q30[a*32+:32]=32'h40000000;
        thermal_node_factor_q30[b*32+:32]=32'h20000000;
        phase_load[b*32+:32]=(sign_index==0)?32'h40000000:32'hc0000000;
        sample(1,1); shell_cases++;
      end
    // Quarter-turn symmetry and every XOR relabelling of the dyadic tree.
    for (int trial=0;trial<32;trial++) begin
      random_inputs(); bank=phase_load; gamma_bank=gamma_effective_word;
      thermal_bank=thermal_node_factor_q30; sample(0,1);
      base_coupling=coupling_field_q16;
      base_orders={pair_coherence_q30,cluster_coherence_q30,global_coherence_q30,organization_dispersion_q30};
      base_mean=level_mean_coherence_q30; base_min=level_min_coherence_q30;
      base_max=level_max_coherence_q30; base_deviation=level_dispersion_q30;
      for (int turn=1;turn<4;turn++) begin
        for (int c=0;c<CELLS;c++) phase_load[c*32+:32]=bank[c*32+:32]+(32'(turn)<<30);
        sample(0,1);
        if (coupling_field_q16!==base_coupling || level_mean_coherence_q30!==base_mean
            || level_min_coherence_q30!==base_min || level_max_coherence_q30!==base_max
            || level_dispersion_q30!==base_deviation
            || {pair_coherence_q30,cluster_coherence_q30,global_coherence_q30,organization_dispersion_q30}!==base_orders)
          $fatal(1,"Common quarter-turn relation cells=%0d",CELLS);
        rotations++;
      end
      for (int mask=0;mask<CELLS;mask++) begin
        for (int c=0;c<CELLS;c++) begin
          phase_load[c*32+:32]=bank[(c^mask)*32+:32];
          gamma_effective_word[c*32+:32]=gamma_bank[(c^mask)*32+:32];
          thermal_node_factor_q30[c*32+:32]=thermal_bank[(c^mask)*32+:32];
        end
        sample(0,1);
        for (int c=0;c<CELLS;c++)
          equal_word("permuted_coupling",c,coupling_field_q16[c*32+:32],base_coupling[(c^mask)*32+:32]);
        if (level_mean_coherence_q30!==base_mean || level_min_coherence_q30!==base_min
            || level_max_coherence_q30!==base_max || level_dispersion_q30!==base_deviation
            || {pair_coherence_q30,cluster_coherence_q30,global_coherence_q30,organization_dispersion_q30}!==base_orders)
          $fatal(1,"Dyadic relabelling relation cells=%0d",CELLS);
        permutations++;
      end
    end
    // Coupled recurrence under all scheduler cadences, pauses and reloads.
    for (int mode=0;mode<3;mode++) begin
      foreach(cadence[k]) cadence[k]=0;
      reset_dut(); random_inputs(); sample(0,1);
      for (int tick=0;tick<1024;tick++) begin
        random_inputs();
        state_code=(mode==0)?0:((mode==1)?((tick%8==7)?2:1):((tick%8==0)?3:4));
        scheduler_state=frp_m31_scheduler_state_e'(state_code);
        if (tick%17==0) sample(0,0);
        if (tick%127==0) sample(1,1);
        sample(1,0); cadence[state_code]++; random_steps++;
      end
      for (int s=0;s<5;s++) begin
        expected_count=0;
        if (mode==0 && s==0) expected_count=1024;
        if (mode==1) expected_count=(s==1)?896:((s==2)?128:0);
        if (mode==2) expected_count=(s==3)?128:((s==4)?896:0);
        equal_word("cadence",s,32'(cadence[s]),32'(expected_count));
      end
    end
    tick_enable=1; load_valid=1; reset_dut(); sample(0,0);
    if (projection_seen!=='1 || relative_seen!=='1 || state_cross!==30'h3fffffff
        || rotations!=96 || permutations!=32*CELLS || shell_cases!=2*CELLS*(CELLS-1)
        || random_steps!=3072 || updates!=3072 || resets!=5
        || samples!=loads+updates+holds || load_priority!=shell_cases+27)
      $fatal(1,"Incomplete phase coverage cells=%0d cross=%h",CELLS,state_cross);
    foreach(target_bins[k]) if(target_bins[k]==0) $fatal(1,"Missing phase target");
    if (positive_coupling==0 || negative_coupling==0 || isolated==0 || zero_adapts==0 || wraps==0)
      $fatal(1,"Missing coupled phase event");
    $display("PASS PHASE_MULTICELL cells=%0d samples=%0d checks=%0d loads=%0d updates=%0d holds=%0d resets=%0d projection=%0d relative=%0d cross=%0d rotations=%0d permutations=%0d edges=%0d signature=%h",
      CELLS,samples,checks,loads,updates,holds,resets,$countones(projection_seen),
      $countones(relative_seen),$countones(state_cross),rotations,permutations,shell_cases,signature);
    $display("PHASE_EVENTS cells=%0d positive=%0d negative=%0d isolated=%0d zero_adapts=%0d wraps=%0d targets=%0d,%0d,%0d",
      CELLS,positive_coupling,negative_coupling,isolated,zero_adapts,wraps,target_bins[0],target_bins[1],target_bins[2]);
    done=1;
  end
endmodule

module frp_m31_phase_multicell_tb;
  wire done8,done16,done32;
  frp_m31_phase_multicell_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_phase_multicell_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_phase_multicell_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS PHASE_MULTICELL_ALL cells=8,16,32");
    $finish;
  end
  initial begin #1000000; $fatal(1,"Phase multicell timeout"); end
endmodule

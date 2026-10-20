// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M31 fractal hierarchy: subtree automorphisms, nested phase coherence,
// and eight-cell motif replication at 8/16/32/64 cells.
// Independent analytic sine, formula-derived weights and integer arithmetic.
// All expected trajectories are retained outside the DUT; no DUT helpers used.
// Build with --binary --timing --assert -Irtl/m31
// --top-module frp_m31_fractal_hierarchy_tb -GCELLS=8 (or 16,32,64).
// Add --flatten for the two eight-cell instances when CELLS=8.

`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_hierarchy_probe #(
  parameter int CELLS=8,
  parameter bit ANCHOR=0
)();
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
  word_t shell_weights[DEPTH];
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
    int span,level;
    // Find the smallest aligned dyadic block containing both cells.
    span=2; level=0;
    while (a/span!=b/span) begin span*=2; level++; end
    return shell_weights[level];
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
    longint signed sum,delta,gap;
    longint unsigned variance;
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
      deviations[level-1]=root_floor(variance/64'(count));
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

  task automatic initialize();
    real normalizer, value;
    longint signed total;
    if(ANCHOR && CELLS!=8) $fatal(1,"Anchor requires eight cells");
    if (!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported hierarchy size");
    normalizer=0.0; total=0;
    for(int d=1;d<=DEPTH;d++) normalizer+=1.0/(real'(d)**0.70);
    for(int d=1;d<=DEPTH;d++) begin
      value=real'(ONE)/(real'(1<<(d-1))*(real'(d)**0.70)*normalizer);
      shell_weights[d-1]=$rtoi(value+0.5);
      total+=longint'(shell_weights[d-1])*(64'sd1<<(d-1));
    end
    shell_weights[0]+=word_t'(ONE-total);
    total=0;
    for(int d=0;d<DEPTH;d++) total+=longint'(shell_weights[d])*(64'sd1<<d);
    if(total!=ONE) $fatal(1,"Hierarchy weight normalization");
    for(int a=0;a<4096;a++) begin
      value=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*real'(ONE);
      sine_table[a]=$rtoi(value<0.0?value-0.5:value+0.5);
    end
    reset_dut();
  endtask

  typedef struct packed {
    logic [CELLS*32-1:0] phase, frequency, field, projection;
    logic [CELLS*2-1:0] target;
    logic [(CELLS-1)*32-1:0] groups;
    logic [DEPTH*32-1:0] mean_order, minimum, maximum, dispersion;
    logic [127:0] summary;
  } snapshot_t;
  snapshot_t saved[10];

  task automatic capture(input int slot);
    saved[slot]='{phase_word_q,frequency_current_q16,coupling_field_q16,
      phase_projection_q30,phase_target,group_coherence_q30,
      level_mean_coherence_q30,level_min_coherence_q30,level_max_coherence_q30,
      level_dispersion_q30,
      {pair_coherence_q30,cluster_coherence_q30,global_coherence_q30,organization_dispersion_q30}};
  endtask

  task automatic compare_mapping(input int slot, input int mapping[CELLS]);
    int base,source;
    for(int c=0;c<CELLS;c++) begin
      source=mapping[c];
      equal_word("mapped_phase",c,phase_word_q[32*c+:32],saved[slot].phase[32*source+:32]);
      equal_word("mapped_frequency",c,frequency_current_q16[32*c+:32],saved[slot].frequency[32*source+:32]);
      equal_word("mapped_field",c,coupling_field_q16[32*c+:32],saved[slot].field[32*source+:32]);
      equal_word("mapped_projection",c,phase_projection_q30[32*c+:32],saved[slot].projection[32*source+:32]);
      equal_word("mapped_target",c,32'(phase_target[2*c+:2]),32'(saved[slot].target[2*source+:2]));
    end
    base=0;
    for(int d=1;d<=DEPTH;d++) begin
      for(int g=0;g<(CELLS>>d);g++) begin
        source=mapping[g<<d]>>d;
        equal_word("mapped_group",base+g,group_coherence_q30[32*(base+g)+:32],
                   saved[slot].groups[32*(base+source)+:32]);
      end
      equal_word("mapped_mean",d,level_mean_coherence_q30[32*(d-1)+:32],saved[slot].mean_order[32*(d-1)+:32]);
      equal_word("mapped_min",d,level_min_coherence_q30[32*(d-1)+:32],saved[slot].minimum[32*(d-1)+:32]);
      equal_word("mapped_max",d,level_max_coherence_q30[32*(d-1)+:32],saved[slot].maximum[32*(d-1)+:32]);
      equal_word("mapped_dispersion",d,level_dispersion_q30[32*(d-1)+:32],saved[slot].dispersion[32*(d-1)+:32]);
      base+=CELLS>>d;
    end
    equal_word("mapped_pair",0,pair_coherence_q30,saved[slot].summary[127:96]);
    equal_word("mapped_cluster",0,cluster_coherence_q30,saved[slot].summary[95:64]);
    equal_word("mapped_global",0,global_coherence_q30,saved[slot].summary[63:32]);
    equal_word("mapped_organization",0,organization_dispersion_q30,saved[slot].summary[31:0]);
  endtask
endmodule

module frp_m31_fractal_hierarchy_tb #(
  parameter int CELLS=8
);
  import frp_m31_pkg::*;
  localparam int DEPTH=$clog2(CELLS);
  frp_m31_hierarchy_probe #(.CELLS(CELLS)) subject();
  frp_m31_hierarchy_probe #(.CELLS(8),.ANCHOR(1)) anchor();
  logic [CELLS*32-1:0] phases,frequencies,gammas,thermals;
  logic [CELLS*2-1:0] states;
  logic [CELLS-1:0] activity;
  int mapping[CELLS];
  int swaps=0,compositions=0,nested_cases=0,scaling_cases=0;
  int hierarchy_breaks=0,trajectory_checks=0;
  int unsigned rng=32'h92f12ac7;

  function automatic int unsigned random_word();
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction

  task automatic identity();
    for(int c=0;c<CELLS;c++) mapping[c]=c;
  endtask

  task automatic swap_children(input int start,span);
    int temporary;
    for(int c=0;c<span/2;c++) begin
      temporary=mapping[start+c];
      mapping[start+c]=mapping[start+c+span/2];
      mapping[start+c+span/2]=temporary;
    end
  endtask

  task automatic drive_mapping();
    bit [CELLS-1:0] seen;
    seen='0;
    for(int c=0;c<CELLS;c++) begin
      if(mapping[c]<0 || mapping[c]>=CELLS || seen[mapping[c]])
        $fatal(1,"Invalid tree permutation");
      seen[mapping[c]]=1;
      subject.phase_load[32*c+:32]=phases[32*mapping[c]+:32];
      subject.frequency_load_q16[32*c+:32]=frequencies[32*mapping[c]+:32];
      subject.gamma_effective_word[32*c+:32]=gammas[32*mapping[c]+:32];
      subject.thermal_node_factor_q30[32*c+:32]=thermals[32*mapping[c]+:32];
      subject.retained_state[2*c+:2]=states[2*mapping[c]+:2];
      subject.switch_activity[c]=activity[mapping[c]];
    end
  endtask

  task automatic set_cadence(input int mode,step_id);
    case(mode)
      0:subject.scheduler_state=FRP_SCHED_FREE;
      1:subject.scheduler_state=step_id%8==7?FRP_SCHED_COMMIT:FRP_SCHED_BALANCE;
      default:subject.scheduler_state=step_id%8==0?FRP_SCHED_EXCITE:FRP_SCHED_NEUTRALIZE;
    endcase
  endtask

  task automatic trajectory(input int mode, input bit save_reference);
    drive_mapping(); set_cadence(mode,0); subject.sample(0,1);
    if(save_reference) subject.capture(0); else subject.compare_mapping(0,mapping);
    for(int t=0;t<8;t++) begin
      set_cadence(mode,t); subject.sample(1,0);
      if(save_reference) subject.capture(t+1); else subject.compare_mapping(t+1,mapping);
    end
    subject.sample(0,0);
    if(save_reference) subject.capture(9); else subject.compare_mapping(9,mapping);
    if(!save_reference) trajectory_checks+=10;
  endtask

  initial begin : campaign
    int base,span,offset,small_index,large_index,choice;
    logic [31:0] turn;
    logic [(CELLS-1)*32-1:0] ordered_groups;
    subject.initialize(); anchor.initialize();
    // Each internal node is exercised separately, then swaps are composed.
    for(int mode=0;mode<3;mode++) for(int trial=0;trial<2;trial++) begin
      for(int c=0;c<CELLS;c++) begin
        phases[32*c+:32]=random_word(); frequencies[32*c+:32]=random_word();
        gammas[32*c+:32]=random_word();
        thermals[32*c+:32]=random_word()%32'd1073741825;
        choice=int'(random_word()%3);
        states[2*c+:2]=choice==0?2'b00:(choice==1?2'b01:2'b11);
        activity[c]=1'(random_word());
      end
      identity(); trajectory(mode,1);
      for(int d=1;d<=DEPTH;d++) for(int g=0;g<(CELLS>>d);g++) begin
        identity(); swap_children(g<<d,1<<d); trajectory(mode,0); swaps++;
      end
      for(int trial_map=0;trial_map<16;trial_map++) begin
        identity();
        for(int d=1;d<=DEPTH;d++) for(int g=0;g<(CELLS>>d);g++)
          if((random_word()&1)!=0) swap_children(g<<d,1<<d);
        trajectory(mode,0); compositions++;
      end
    end
    $display("PASS HIERARCHY_PERMUTATIONS cells=%0d swaps=%0d compositions=%0d snapshots=%0d",
             CELLS,swaps,compositions,trajectory_checks);

    // Exact phasor witnesses at every internal node: aligned children and
    // opposed children. Parent coherence uses vector sums, not scalar means.
    subject.frequency_load_q16={CELLS{32'd65536}};
    subject.gamma_effective_word='0; subject.thermal_node_factor_q30={CELLS{32'h40000000}};
    subject.retained_state='0; subject.switch_activity='0;
    for(int d=1;d<=DEPTH;d++) for(int g=0;g<(CELLS>>d);g++)
      for(int orientation=0;orientation<4;orientation++) for(int opposed=0;opposed<2;opposed++) begin
        span=1<<d; base=g*span; turn=32'(orientation)<<30;
        for(int c=0;c<CELLS;c++) subject.phase_load[32*c+:32]=random_word();
        for(int c=base;c<base+span;c++)
          subject.phase_load[32*c+:32]=turn+((opposed!=0 && c>=base+span/2)?32'h80000000:0);
        subject.sample(0,1);
        offset=CELLS-(CELLS>>(d-1))+g;
        subject.equal_word("parent_witness",offset,subject.group_coherence_q30[32*offset+:32],
                         opposed!=0?0:32'h40000000);
        if(d>1) for(int child=0;child<2;child++) begin
          offset=CELLS-(CELLS>>(d-2))+2*g+child;
          subject.equal_word("child_witness",offset,subject.group_coherence_q30[32*offset+:32],32'h40000000);
        end
        subject.sample(0,0); nested_cases++;
      end
    // Half the pairs have order one, half zero: the variance sum reaches
    // 2^63 at 64 cells and requires unsigned 64-bit accumulation.
    for(int c=0;c<CELLS;c++)
      subject.phase_load[32*c+:32]=c%4==3?32'h80000000:0;
    subject.sample(0,1);
    subject.equal_word("maximum_pair_variance_mean",0,subject.level_mean_coherence_q30[0+:32],32'h20000000);
    subject.equal_word("maximum_pair_variance_rms",0,subject.level_dispersion_q30[0+:32],32'h20000000);
    nested_cases++;
    // A non-tree permutation must be observable in labelled pair coherence.
    subject.phase_load='0; subject.phase_load[32*2+:32]=32'h80000000;
    subject.phase_load[32*3+:32]=32'h80000000; subject.sample(0,1);
    ordered_groups=subject.group_coherence_q30;
    subject.phase_load[32*1+:32]=32'h80000000; subject.phase_load[32*2+:32]=0;
    subject.sample(0,1);
    if(subject.group_coherence_q30===ordered_groups) $fatal(1,"Hierarchy-breaking control invisible");
    subject.equal_word("broken_pair_0",0,subject.group_coherence_q30[0+:32],0);
    subject.equal_word("broken_pair_1",1,subject.group_coherence_q30[32+:32],0);
    hierarchy_breaks++;
    $display("PASS HIERARCHY_NESTING cells=%0d cases=%0d negative_controls=%0d",
             CELLS,nested_cases,hierarchy_breaks);

    // Tile an eight-cell phase motif across the larger tree. Coherence is
    // invariant under exact replication; coupling is checked independently
    // with the normalized shell weights for each actual population.
    for(int pattern=0;pattern<128;pattern++) begin
      for(int c=0;c<8;c++) begin
        case(pattern%4)
          0:anchor.phase_load[32*c+:32]=random_word();
          1:anchor.phase_load[32*c+:32]=32'(c)<<29;
          2:anchor.phase_load[32*c+:32]=c<4?0:32'h80000000;
          default:anchor.phase_load[32*c+:32]=32'(pattern)<<25;
        endcase
        anchor.frequency_load_q16[32*c+:32]=random_word();
        anchor.gamma_effective_word[32*c+:32]=random_word();
        anchor.thermal_node_factor_q30[32*c+:32]=random_word()%32'd1073741825;
      end
      for(int c=0;c<CELLS;c++) begin
        subject.phase_load[32*c+:32]=anchor.phase_load[32*(c%8)+:32];
        subject.frequency_load_q16[32*c+:32]=anchor.frequency_load_q16[32*(c%8)+:32];
        subject.gamma_effective_word[32*c+:32]=anchor.gamma_effective_word[32*(c%8)+:32];
        subject.thermal_node_factor_q30[32*c+:32]=anchor.thermal_node_factor_q30[32*(c%8)+:32];
      end
      anchor.sample(0,1); subject.sample(0,1);
      for(int d=1;d<=DEPTH;d++) for(int g=0;g<(CELLS>>d);g++) begin
        large_index=CELLS-(CELLS>>(d-1))+g;
        small_index=d<=3?8-(8>>(d-1))+(g%(8>>d)):6;
        subject.equal_word("replicated_group",large_index,
          subject.group_coherence_q30[32*large_index+:32],anchor.group_coherence_q30[32*small_index+:32]);
      end
      for(int d=0;d<3;d++) begin
        subject.equal_word("replicated_mean",d,subject.level_mean_coherence_q30[32*d+:32],anchor.level_mean_coherence_q30[32*d+:32]);
        subject.equal_word("replicated_min",d,subject.level_min_coherence_q30[32*d+:32],anchor.level_min_coherence_q30[32*d+:32]);
        subject.equal_word("replicated_max",d,subject.level_max_coherence_q30[32*d+:32],anchor.level_max_coherence_q30[32*d+:32]);
        subject.equal_word("replicated_dispersion",d,subject.level_dispersion_q30[32*d+:32],anchor.level_dispersion_q30[32*d+:32]);
      end
      for(int d=3;d<DEPTH;d++)
        subject.equal_word("replicated_upper_dispersion",d,subject.level_dispersion_q30[32*d+:32],0);
      subject.sample(0,0); anchor.sample(0,0); scaling_cases++;
    end
    if(swaps!=6*(CELLS-1) || compositions!=96 || nested_cases!=8*(CELLS-1)+1
       || scaling_cases!=128 || hierarchy_breaks!=1
       || trajectory_checks!=10*(swaps+compositions)) $fatal(1,"Incomplete hierarchy coverage");
    $display("PASS HIERARCHY_SCALING cells=%0d anchor=8 motifs=%0d levels=%0d groups=%0d",
             CELLS,scaling_cases,DEPTH,CELLS-1);
    $display("PASS FRACTAL_HIERARCHY_ALL cells=%0d checks=%0d anchor_checks=%0d signature=%h anchor_signature=%h",
             CELLS,subject.checks,anchor.checks,subject.signature,anchor.signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Fractal hierarchy timeout"); end
endmodule

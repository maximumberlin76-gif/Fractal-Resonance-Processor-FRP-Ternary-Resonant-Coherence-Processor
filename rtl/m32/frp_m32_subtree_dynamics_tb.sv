// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Local sibling-subtree exchanges and composed tree automorphisms.
// Paired phase, thermal, gamma and attenuation trajectories use permuted inputs.
// Thermal candidates feed gamma and attenuation candidates before phase update.
// Retained ternary state and switching activity are explicit upstream stimuli.
// Run from the repository root; CELLS supports 8, 16, 32 and 64.
`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"
`include "frp_m31_local_thermal_field.sv"
`include "frp_m31_local_gamma_drift.sv"
`include "frp_m31_local_thermal_attenuation.sv"

module frp_m32_subtree_dynamics_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int DEPTH=$clog2(CELLS);
  localparam int COMPOSITIONS=8;
  typedef logic [CELLS*32-1:0] bank_t;
  typedef logic [11*CELLS*32+32-1:0] history_t;
  logic clk=0, rst_n=1, tick_enable=0, load_valid=0;
  logic gamma_update_valid=0, local_gamma=0, local_thermal=0;
  frp_m31_scheduler_state_e scheduler_state=FRP_SCHED_FREE;
  bank_t phase_load[2], frequency_load[2], gamma_input[2], factor_input[2];
  bank_t gamma_targets[2];
  logic [CELLS*2-1:0] retained[2];
  logic [CELLS-1:0] activity[2];
  bank_t phase[2], frequency[2], coupling[2], projection[2], lag[2];
  logic [CELLS*2-1:0] target[2];
  bank_t heat[2], peak[2], power_value[2], dissipation[2], diffusion[2];
  bank_t overload[2], next_heat[2], next_overload[2];
  bank_t noise_target[2], noise_state[2], gamma_drift[2], gamma_effective[2];
  bank_t next_drift[2], next_gamma[2], factor[2], next_factor[2];
  bank_t selected_gamma[2], selected_factor[2];
  wire signed [31:0] mean_heat[2], mean_peak[2], maximum_heat[2];
  wire signed [31:0] pair_order[2], cluster_order[2], global_order[2], organization[2];
  wire [(CELLS-1)*32-1:0] groups[2];
  wire [DEPTH*32-1:0] means[2], minima[2], maxima[2], dispersions[2];
  int mapping[CELLS];
  int mode_id=0, case_id=0, step_id=0;
  int cases=0, edges=0, updates=0, holds=0, loads=0;
  int local_cases=0, composed_cases=0, non_xor_cases=0, non_involutive_cases=0;
  int source_hits[3][4], cadence_hits[5], ternary_hits[3];
  longint unsigned checks=0, renamed=0, moving=0, warm=0, drifting=0, attenuated=0;
  longint unsigned positive_diffusion=0, negative_diffusion=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  history_t before_history[2];
  bank_t before_phase[2], before_frequency[2];
  event check_request, mapping_request;
  bit check_done=0, mapping_done=0;

  function automatic longint signed rounded(input longint signed value, divisor);
    /*verilator no_inline_task*/
    longint signed q,r;
    q=value/divisor; r=value%divisor;
    if(2*r>=divisor) q++;
    if(2*r<=-divisor) q--;
    return q;
  endfunction
  function automatic logic signed [31:0] clipped(input longint signed value);
    /*verilator no_inline_task*/
    if(value>2147483647) return 32'sh7fffffff;
    if(value< -64'sd2147483648) return 32'sh80000000;
    return 32'(value);
  endfunction
  function automatic int shell(input int a,b);
    /*verilator no_inline_task*/
    int span,level;
    if(a==b) return 0;
    span=2; level=1;
    while(a/span!=b/span) begin span*=2; level++; end
    return level;
  endfunction
  function automatic logic [31:0] stimulus(input int cell_id,t,salt);
    /*verilator no_inline_task*/
    logic [31:0] x;
    x=32'h9e3779b9 ^ (32'(cell_id+1)*32'h85ebca6b)
      ^ (32'(t+1)*32'hc2b2ae35) ^ (32'(salt+1)*32'h27d4eb2d);
    x^=x<<13; x^=x>>17; x^=x<<5;
    return x;
  endfunction

  for(genvar b=0;b<2;b++) begin : g_bank
    for(genvar c=0;c<CELLS;c++) begin : g_lag
      always_comb begin : predict_residual
        longint signed wanted,current,selected,residual;
        wanted=65536+(retained[b][2*c+:2]!=0?3932:0)+(activity[b][c]?7864:0);
        current=longint'($signed(frequency[b][32*c+:32]));
        selected=longint'(clipped(current+longint'(clipped(rounded((wanted-current)*19661,65536)))));
        if(load_valid) selected=longint'($signed(frequency_load[b][32*c+:32]));
        residual=wanted-selected;
        if(residual<0) residual=-residual;
        lag[b][32*c+:32]=32'(residual);
      end
    end
    assign selected_gamma[b]=local_gamma?next_gamma[b]:gamma_input[b];
    assign selected_factor[b]=local_thermal?next_factor[b]:factor_input[b];
    frp_m31_local_thermal_field #(.CELLS(CELLS)) thermal (
      .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
      .switch_activity(activity[b]), .frequency_lag_q16(lag[b]),
      .heat_q16(heat[b]), .local_heat_peak_q16(peak[b]),
      .generated_power_q16(power_value[b]), .thermal_dissipation_q16(dissipation[b]),
      .thermal_diffusion_q16(diffusion[b]), .thermal_overload_q16(overload[b]),
      .next_heat_q16(next_heat[b]), .next_overload_q16(next_overload[b]),
      .mean_heat_q16(mean_heat[b]), .mean_heat_peak_q16(mean_peak[b]),
      .maximum_local_heat_q16(maximum_heat[b])
    );
    frp_m31_local_gamma_drift #(.CELLS(CELLS)) gamma (
      .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
      .gamma_update_valid(gamma_update_valid), .gamma_targets_q16(gamma_targets[b]),
      .thermal_overload_q16(next_overload[b]),
      .gamma_noise_target_q16(noise_target[b]), .gamma_noise_state_q16(noise_state[b]),
      .gamma_drift_word(gamma_drift[b]), .gamma_effective_word(gamma_effective[b]),
      .next_gamma_drift_word(next_drift[b]), .next_gamma_effective_word(next_gamma[b])
    );
    frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) attenuation (
      .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
      .thermal_overload_q16(next_overload[b]), .thermal_node_factor_q30(factor[b]),
      .next_thermal_node_factor_q30(next_factor[b])
    );
    frp_m31_phase_interference #(.CELLS(CELLS)) engine (
      .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable), .load_valid(load_valid),
      .phase_load(phase_load[b]), .frequency_load_q16(frequency_load[b]),
      .gamma_effective_word(selected_gamma[b]), .thermal_node_factor_q30(selected_factor[b]),
      .retained_state(retained[b]), .switch_activity(activity[b]), .scheduler_state(scheduler_state),
      .phase_word_q(phase[b]), .frequency_current_q16(frequency[b]),
      .coupling_field_q16(coupling[b]), .phase_projection_q30(projection[b]), .phase_target(target[b]),
      .pair_coherence_q30(pair_order[b]), .cluster_coherence_q30(cluster_order[b]),
      .global_coherence_q30(global_order[b]), .organization_dispersion_q30(organization[b]),
      .group_coherence_q30(groups[b]), .level_mean_coherence_q30(means[b]),
      .level_min_coherence_q30(minima[b]), .level_max_coherence_q30(maxima[b]),
      .level_dispersion_q30(dispersions[b])
    );
  end

  task automatic require(input bit condition, input string label_text);
    checks++;
    if(!condition) $fatal(1,"SUBTREE cells=%0d mode=%0d case=%0d step=%0d %s",
      CELLS,mode_id,case_id,step_id,label_text);
  endtask
  task automatic equal_word(input string label_text, input logic [31:0] actual,expected);
    require(actual===expected,label_text);
    signature=(signature^{32'b0,actual})*64'h100000001b3;
  endtask
  task automatic compare_bank(input string label_text, input bank_t a,b);
    for(int i=0;i<CELLS;i++) equal_word(label_text,b[32*i+:32],a[32*mapping[i]+:32]);
  endtask
  function automatic history_t history(input int b);
    return {heat[b],peak[b],power_value[b],dissipation[b],diffusion[b],overload[b],
      noise_target[b],noise_state[b],gamma_drift[b],gamma_effective[b],factor[b],mean_peak[b]};
  endfunction

  task automatic check_relation;
    int offset,count,span,mapped_group;
    compare_bank("phase",phase[0],phase[1]);
    compare_bank("frequency",frequency[0],frequency[1]);
    compare_bank("coupling",coupling[0],coupling[1]);
    compare_bank("projection",projection[0],projection[1]);
    compare_bank("lag",lag[0],lag[1]);
    compare_bank("heat",heat[0],heat[1]);
    compare_bank("peak",peak[0],peak[1]);
    compare_bank("power_value",power_value[0],power_value[1]);
    compare_bank("dissipation",dissipation[0],dissipation[1]);
    compare_bank("diffusion",diffusion[0],diffusion[1]);
    compare_bank("overload",overload[0],overload[1]);
    compare_bank("next_heat",next_heat[0],next_heat[1]);
    compare_bank("next_overload",next_overload[0],next_overload[1]);
    compare_bank("noise_target",noise_target[0],noise_target[1]);
    compare_bank("noise_state",noise_state[0],noise_state[1]);
    compare_bank("gamma_drift",gamma_drift[0],gamma_drift[1]);
    compare_bank("gamma_effective",gamma_effective[0],gamma_effective[1]);
    compare_bank("next_drift",next_drift[0],next_drift[1]);
    compare_bank("next_gamma",next_gamma[0],next_gamma[1]);
    compare_bank("factor",factor[0],factor[1]);
    compare_bank("next_factor",next_factor[0],next_factor[1]);
    compare_bank("selected_gamma",selected_gamma[0],selected_gamma[1]);
    compare_bank("selected_factor",selected_factor[0],selected_factor[1]);
    for(int i=0;i<CELLS;i++) begin
      equal_word("target",32'(target[1][2*i+:2]),32'(target[0][2*mapping[i]+:2]));
      require(target[0][2*i+:2]!=2 && retained[0][2*i+:2]!=2,"ternary alphabet");
      if(mapping[i]!=i && phase[0][32*i+:32]!=phase[0][32*mapping[i]+:32]) renamed++;
      if(heat[0][32*i+:32]!=heat[0][31:0]) warm++;
      if(gamma_drift[0][32*i+:32]!=0) drifting++;
      if(factor[0][32*i+:32]<32'h40000000) attenuated++;
      if($signed(diffusion[0][32*i+:32])>0) positive_diffusion++;
      if($signed(diffusion[0][32*i+:32])<0) negative_diffusion++;
    end
    offset=0;
    for(int level=1;level<=DEPTH;level++) begin
      span=1<<level; count=CELLS/span;
      for(int g=0;g<count;g++) begin
        mapped_group=mapping[g*span]/span;
        equal_word("group",groups[1][32*(offset+g)+:32],groups[0][32*(offset+mapped_group)+:32]);
      end
      equal_word("level mean",means[1][32*(level-1)+:32],means[0][32*(level-1)+:32]);
      equal_word("level minimum",minima[1][32*(level-1)+:32],minima[0][32*(level-1)+:32]);
      equal_word("level maximum",maxima[1][32*(level-1)+:32],maxima[0][32*(level-1)+:32]);
      equal_word("level dispersion",dispersions[1][32*(level-1)+:32],dispersions[0][32*(level-1)+:32]);
      offset+=count;
    end
    equal_word("pair_order",pair_order[1],pair_order[0]);
    equal_word("cluster_order",cluster_order[1],cluster_order[0]);
    equal_word("global_order",global_order[1],global_order[0]);
    equal_word("organization",organization[1],organization[0]);
    equal_word("mean_heat",mean_heat[1],mean_heat[0]);
    equal_word("mean_peak",mean_peak[1],mean_peak[0]);
    equal_word("maximum_heat",maximum_heat[1],maximum_heat[0]);
  endtask
  always @(check_request) begin check_relation(); check_done=1; end
  task automatic inspect;
    check_done=0; ->check_request; wait(check_done);
  endtask

  task automatic edge_step(input bit enabled,load,check_before=1);
    tick_enable=enabled; load_valid=load; #1;
    if(check_before) inspect();
    for(int b=0;b<2;b++) begin
      before_history[b]=history(b); before_phase[b]=phase[b]; before_frequency[b]=frequency[b];
    end
    clk=1; #1; inspect();
    for(int b=0;b<2;b++) begin
      if(!enabled) require(history(b)===before_history[b],"paused thermal/gamma history");
      if(load) begin
        require(phase[b]===phase_load[b],"phase load priority");
        require(frequency[b]===frequency_load[b],"frequency load priority");
      end else if(!enabled) begin
        require(phase[b]===before_phase[b],"paused phase");
        require(frequency[b]===before_frequency[b],"paused frequency");
      end else if(phase[b]!==before_phase[b]) moving++;
    end
    edges++;
    if(load) loads++;
    else if(enabled) updates++;
    else holds++;
    if(enabled) begin
      source_hits[mode_id][2*int'(local_thermal)+int'(local_gamma)]++;
      cadence_hits[int'(scheduler_state)]++;
    end
    clk=0; #1;
  endtask

  task automatic copy_inputs;
    for(int i=0;i<CELLS;i++) begin
      phase_load[1][32*i+:32]=phase_load[0][32*mapping[i]+:32];
      frequency_load[1][32*i+:32]=frequency_load[0][32*mapping[i]+:32];
      gamma_input[1][32*i+:32]=gamma_input[0][32*mapping[i]+:32];
      factor_input[1][32*i+:32]=factor_input[0][32*mapping[i]+:32];
      gamma_targets[1][32*i+:32]=gamma_targets[0][32*mapping[i]+:32];
      retained[1][2*i+:2]=retained[0][2*mapping[i]+:2];
      activity[1][i]=activity[0][mapping[i]];
    end
  endtask
  task automatic drive(input int t);
    int selector;
    logic [1:0] old_state,new_state;
    selector=(t/24)%4; local_gamma=(selector&1)!=0; local_thermal=(selector&2)!=0;
    gamma_update_valid=(t%5)==0;
    scheduler_state=frp_m31_scheduler_state_e'(mode_id==0?0:
      mode_id==1?(t%8==7?2:1):(t%8==0?3:4));
    for(int i=0;i<CELLS;i++) begin
      phase_load[0][32*i+:32]=stimulus(i,t,case_id);
      frequency_load[0][32*i+:32]=32'(16000+stimulus(i,t,3)%180000);
      gamma_input[0][32*i+:32]=stimulus(i,t,7);
      factor_input[0][32*i+:32]=stimulus(i,t,11)%32'd1073741825;
      gamma_targets[0][32*i+:32]=32'(int'(stimulus(i,t,13)%131073)-65536);
      old_state=retained[0][2*i+:2];
      case((t+i)%4) 1:new_state=1; 3:new_state=3; default:new_state=0; endcase
      require(!(old_state!=0 && new_state!=0 && old_state!=new_state),"stimulus transition via zero");
      retained[0][2*i+:2]=new_state; activity[0][i]=(old_state!=new_state);
      ternary_hits[new_state==3?2:int'(new_state)]++;
    end
    copy_inputs();
  endtask

  task automatic validate_mapping;
    bit seen[CELLS];
    bit is_xor,involution;
    foreach(seen[i]) seen[i]=0;
    is_xor=1; involution=1;
    for(int i=0;i<CELLS;i++) begin
      require(mapping[i]>=0 && mapping[i]<CELLS,"mapping range");
      require(!seen[mapping[i]],"mapping bijection"); seen[mapping[i]]=1;
      if(mapping[i]!=(i^mapping[0])) is_xor=0;
    end
    for(int i=0;i<CELLS;i++) begin
      if(mapping[mapping[i]]!=i) involution=0;
      for(int j=0;j<CELLS;j++)
        require(shell(i,j)==shell(mapping[i],mapping[j]),"pair shell preservation");
    end
    for(int level=1;level<=DEPTH;level++)
      for(int base=0;base<CELLS;base+=(1<<level))
        for(int i=base;i<base+(1<<level);i++)
          require(mapping[i]/(1<<level)==mapping[base]/(1<<level),"mapped group membership");
    if(!is_xor) non_xor_cases++;
    if(!involution) non_involutive_cases++;
  endtask
  always @(mapping_request) begin validate_mapping(); mapping_done=1; end

  task automatic exchange(input int level,base);
    for(int i=0;i<CELLS;i++)
      if(mapping[i]>=base && mapping[i]<base+(1<<level)) mapping[i]^=1<<(level-1);
  endtask

  task automatic run_case;
    longint unsigned renamed_start,warm_start,drift_start,factor_start,moving_start;
    mapping_done=0; ->mapping_request; wait(mapping_done);
    renamed_start=renamed; warm_start=warm; drift_start=drifting;
    factor_start=attenuated; moving_start=moving;
    clk=0; tick_enable=1; load_valid=1; rst_n=0; #1;
    for(int b=0;b<2;b++) begin
      for(int i=0;i<CELLS;i++) begin
        equal_word("reset phase",phase[b][32*i+:32],32'(64'(i)*(64'h100000000/64'(CELLS))));
        equal_word("reset frequency",frequency[b][32*i+:32],65536);
        equal_word("reset heat",heat[b][32*i+:32],3277);
        equal_word("reset peak",peak[b][32*i+:32],3277);
        equal_word("reset noise",noise_state[b][32*i+:32],0);
        equal_word("reset gamma",gamma_effective[b][32*i+:32],644245094);
        equal_word("reset factor",factor[b][32*i+:32],1073741824);
      end
      retained[b]='0; activity[b]='0;
    end
    rst_n=1; drive(0); edge_step(0,1,0);
    // Begin a consecutive ternary stimulus sequence after initial phase load.
    retained[0]='0; activity[0]='0;
    for(int t=0;t<96;t++) begin
      step_id=t; drive(t);
      if(t%11==0) begin
        gamma_update_valid=1; edge_step(0,0);
        gamma_update_valid=(t%5)==0;
      end
      if(t==64) edge_step(0,1);
      edge_step(1,t==32);
    end
    require(renamed>renamed_start,"nonuniform renamed phase witness");
    require(warm>warm_start,"nonuniform thermal trajectory");
    require(drifting>drift_start,"gamma drift exercised");
    require(attenuated>factor_start,"thermal attenuation exercised");
    require(moving>moving_start,"phase evolution exercised");
    cases++; case_id++;
  endtask

  initial begin
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    for(int b=0;b<2;b++) begin
      phase_load[b]='0; frequency_load[b]='0; gamma_input[b]='0;
      factor_input[b]='0; gamma_targets[b]='0; retained[b]='0; activity[b]='0;
    end
    for(int mode=0;mode<3;mode++) begin
      mode_id=mode;
      for(int level=1;level<=DEPTH;level++) begin
        for(int base=0;base<CELLS;base+=(1<<level)) begin
          for(int i=0;i<CELLS;i++) mapping[i]=i;
          exchange(level,base); run_case(); local_cases++;
        end
        $display("SUBTREE_LEVEL cells=%0d mode=%0d level=%0d cases=%0d",CELLS,mode,level,CELLS>>level);
      end
      for(int trial=0;trial<COMPOSITIONS;trial++) begin
        for(int i=0;i<CELLS;i++) mapping[i]=i;
        for(int level=1;level<=DEPTH;level++)
          for(int base=0;base<CELLS;base+=(1<<level)) begin
            if(level==1 && base<6) begin
              if(((trial>>(base/2))&1)!=0) exchange(level,base);
            end else if(stimulus(base,level,trial)%5<2) exchange(level,base);
          end
        // Compose a local leaf exchange with a root exchange.
        exchange(1,0); exchange(DEPTH,0); run_case(); composed_cases++;
      end
      $display("SUBTREE_COMPOSED cells=%0d mode=%0d cases=%0d",CELLS,mode,COMPOSITIONS);
    end
    require(cases==3*(CELLS-1+COMPOSITIONS),"case coverage");
    require(local_cases==3*(CELLS-1) && composed_cases==3*COMPOSITIONS,"mapping coverage");
    require(non_xor_cases>0 && non_involutive_cases>0,"local and composed mapping witnesses");
    require(edges==107*cases && updates==95*cases && holds==9*cases && loads==3*cases,"edge coverage");
    foreach(source_hits[m,s]) require(source_hits[m][s]==24*(CELLS-1+COMPOSITIONS),"mode/source cross");
    foreach(cadence_hits[c]) require(cadence_hits[c]>0,"scheduler cadence coverage");
    foreach(ternary_hits[s]) require(ternary_hits[s]>0,"retained ternary coverage");
    require(positive_diffusion>0 && negative_diffusion>0,"both diffusion signs");
    $display("PASS SUBTREE_DYNAMICS cells=%0d cases=%0d local_cases=%0d composed_cases=%0d edges=%0d updates=%0d holds=%0d loads=%0d checks=%0d non_xor=%0d non_involutive=%0d renamed=%0d moving=%0d warm=%0d drifting=%0d attenuated=%0d diffusion_positive=%0d diffusion_negative=%0d signature=%016h",
      CELLS,cases,local_cases,composed_cases,edges,updates,holds,loads,checks,non_xor_cases,non_involutive_cases,
      renamed,moving,warm,drifting,attenuated,positive_diffusion,negative_diffusion,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Subtree dynamics timeout"); end
endmodule

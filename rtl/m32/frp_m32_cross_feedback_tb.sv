// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Full M32 cross-feedback qualification: relative-phase interference,
// multiscale coherence, retained ternary execution and active-zero service.
// Independent arithmetic references use public ports; no DUT state forcing.
// CASE=0 runs all; CASE=1 source handoffs; CASE=2 hot reset; CASE=3 backlog.
// Optional +SEED=<decimal> selects reproducible backlog stimuli.
// Build once per CELLS=8/16/32; run from repository root for the sine ROM.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_cross_feedback_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int LANES=CELLS/4, INDEX_BITS=$clog2(CELLS);
  localparam longint Q16=65536, Q30=1073741824;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_load_valid=0, auto_target_enable=1;
  logic local_gamma_enable=0, local_thermal_enable=0, gamma_update_valid=0;
  logic [CELLS*32-1:0] phase_load=0, frequency_load_q16=0;
  logic [CELLS*32-1:0] gamma_effective_word=0, gamma_targets_q16=0;
  logic [CELLS*32-1:0] thermal_node_factor_q30={CELLS{32'h40000000}};
  logic [LANES-1:0] external_request_valid=0;
  logic [LANES*INDEX_BITS-1:0] external_request_cell_index=0;
  logic [LANES*2-1:0] external_request_target=0;
  logic [CELLS*2-1:0] external_target_bank=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE;
  frp_m31_scheduler_state_e scheduler_state;
  frp_m31_scheduler_mode_e registered_mode;
  wire [31:0] recorded_ticks, state_counts[5];
  wire [CELLS*2-1:0] registered_target;
  wire registered_valid;
  int gold_mode=0, position=0, gold_ticks=0, counts[5];
  logic [CELLS*2-1:0] gold_target=0;
  bit gold_valid=0;
  int state_hits[5], mode_changes=0;
  int source_hits[3][4][4][8], reset_hits[3][4][8];
  int source_cases=0, reset_cases=0, stream_ticks=0;
  int retention=0, neutralization=0, balancing=0, arbitration=0;
  int hierarchy_split=0, uneven_heat=0, auto_switches=0, backlog_hits=0;
  int shock_count=0, negative_margin=0, positive_margin=0;
  int stream_cross[3][4][2];
  int case_id=0;
  int unsigned seed=32'h70a12345, random_word;
  logic [CELLS*32-1:0] noise_target_model=0;
  wire [CELLS*32-1:0] noise_target;
  wire [(CELLS-1)*32-1:0] groups;
  wire [INDEX_BITS*32-1:0] means, minima, maxima, dispersions;
  wire [LANES-1:0] accepts, rejects;
  wire [31:0] remaining;
  wire exhausted;
  logic [CELLS-1:0] first_cells=0, second_cells=0;
  wire [CELLS*32-1:0] phase, freq, coupling, heat, overload, lag, noise, gamma, selected_gamma, atten, selected_atten;
  wire signed [31:0] raw, cluster, load_cost, compression, effective, capacity, pressure, margin, previous_margin, sample_raw, sample_cluster, sample_heat, sample_overload, sample_lag, sample_neutral, sample_arg, sample_load;
  wire [CELLS*2-1:0] state, pending;
  wire [CELLS-1:0] changes;
  wire [31:0] sample_count, direct_events;
  wire [9:0] invariants;
  wire sample_valid, stable;

  frp_m32_core #(.CELLS(CELLS)) dut (
    .clk, .rst_n, .tick_enable,
    .clear_counters, .scheduler_mode, .phase_load_valid,
    .phase_load, .frequency_load_q16, .gamma_effective_word,
    .thermal_node_factor_q30, .auto_target_enable, .external_request_valid,
    .external_request_cell_index, .external_request_target, .external_target_bank,
    .local_gamma_enable, .gamma_update_valid, .gamma_targets_q16,
    .local_thermal_enable, .phase_word_q(phase), .frequency_current_q16(freq),
    .coupling_field_q16(coupling), .phase_projection_q30(), .phase_target_source(),
    .registered_target_q(registered_target), .registered_target_valid_q(registered_valid), .state_out(state),
    .pending_route_out(pending), .scheduler_mode_q(registered_mode), .scheduler_state_q(scheduler_state),
    .accepted_changes(), .switch_load_numerator(), .actual_direct_events(direct_events),
    .invariant_flags(invariants), .local_mean_heat_q16(), .stability_margin_q16(),
    .local_stability_margin_q16(margin), .phase_target_domain_valid(), .registered_target_domain_valid(),
    .target_capture_accepted(), .target_capture_rejected(), .accepted_target_capture_events_q(),
    .rejected_target_capture_events_q(), .registered_request_enable(), .phase_request_valid(),
    .phase_request_cell_index(), .phase_request_target(), .execution_request_valid(),
    .execution_request_cell_index(), .execution_request_target(), .execution_target_bank(),
    .ticks_recorded_q(recorded_ticks), .scheduler_count_free_q(state_counts[0]), .scheduler_count_balance_q(state_counts[1]),
    .scheduler_count_commit_q(state_counts[2]), .scheduler_count_excite_q(state_counts[3]), .scheduler_count_neutralize_q(state_counts[4]),
    .request_accept(accepts), .request_reject(rejects), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(changes), .capacity_remaining(remaining),
    .capacity_exhausted(exhausted), .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .reserved_state_events(), .queue_overflow_events(),
    .pair_coherence_q30(), .cluster_coherence_q30(cluster), .global_coherence_q30(raw),
    .organization_dispersion_q30(), .normalized_cycle_cost_q16(load_cost), .temperature_proxy_q16(),
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stable(), .local_heat_q16(heat),
    .local_heat_peak_q16(), .local_generated_power_q16(), .local_thermal_dissipation_q16(),
    .local_thermal_diffusion_q16(), .local_thermal_overload_q16(overload), .local_next_heat_q16(),
    .local_next_overload_q16(), .local_frequency_lag_q16(lag), .local_mean_heat_peak_q16(),
    .local_maximum_heat_peak_q16(), .local_gamma_noise_target_q16(noise_target), .local_gamma_noise_state_q16(noise),
    .local_gamma_drift_word(), .local_gamma_effective_word(gamma), .local_next_gamma_drift_word(),
    .local_next_gamma_effective_word(), .phase_gamma_effective_word(selected_gamma), .local_thermal_node_factor_q30(atten),
    .local_next_thermal_node_factor_q30(), .phase_thermal_node_factor_q30(selected_atten), .group_coherence_q30(groups),
    .level_mean_coherence_q30(means), .level_min_coherence_q30(minima), .level_max_coherence_q30(maxima),
    .level_dispersion_q30(dispersions), .local_coherence_compression_q30(compression), .local_effective_coherence_q30(effective),
    .local_coherence_capacity_q16(capacity), .local_pressure_q16(pressure), .local_stable(stable),
    .local_previous_margin_q16(previous_margin), .local_stability_valid_q(sample_valid), .local_stability_sample_count_q(sample_count),
    .local_stability_raw_coherence_q30(sample_raw), .local_stability_cluster_coherence_q30(sample_cluster), .local_stability_mean_heat_q16(sample_heat),
    .local_stability_mean_overload_q16(sample_overload), .local_stability_mean_lag_q16(sample_lag), .local_stability_neutral_fraction_q30(sample_neutral),
    .local_stability_compression_arg_q16(sample_arg), .local_stability_switch_load_q16(sample_load)
  );

  int sine_table[4096], exp_table[4096];
  int checks=0, cycles=0, routes=0, completions=0;
  int zero_memory=0, held_edges=0, hot_edges=0, cooling_edges=0;
  int gamma_edges=0, attenuation_edges=0, delayed_commits=0;
  int mode_id=0, profile=0;
  bit pending_sample=0;
  longint saved_lag=0, saved_load=0, history=39322;
  longint result_c=65536, result_p=3277, result_m=62259;
  longint result_comp=Q30, result_eff=0;
  int samples=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic longint rounded(input longint n, d);
    /*verilator no_inline_task*/
    return n<0 ? -((-n+d/2)/d) : (n+d/2)/d;
  endfunction
  function automatic longint sat(input longint n);
    return n>2147483647 ? 2147483647 :
      (n< -64'sd2147483648 ? -64'sd2147483648 : n);
  endfunction
  function automatic longint mul(input longint a,b,d);
    /*verilator no_inline_task*/
    return sat(rounded(a*b,d));
  endfunction
  function automatic logic [31:0] phase_delta(input longint v);
    longint a,d;
    a=v<0?-v:v;
    d=a*(64'sd44798133900177/64'sd4294967296)
      +rounded(a*(64'sd44798133900177%64'sd4294967296),64'sd4294967296);
    return 32'(v<0?-d:d);
  endfunction
  function automatic int symbol(input logic [1:0] s);
    case(s)
      2'b00:return 0; 2'b01:return 1; 2'b11:return -1;
      default:begin $fatal(1,"Reserved ternary symbol"); return 2; end
    endcase
  endfunction
  function automatic longint signed shell(input int a,b, input bit thermal);
    /*verilator no_inline_task*/
    int level, span;
    level=0; span=2;
    while (a/span!=b/span) begin span*=2; level++; end
    case(CELLS)
      8: case(level)
        0:return thermal?630553580:516461574;
        1:return thermal?137232194:158959695;
        default:return thermal?42180964:59840215;
      endcase
      16: case(level)
        0:return thermal?567420738:436841896;
        1:return thermal?123492111:134453864;
        2:return thermal?37957684:50615020;
        default:return thermal?13438266:20691515;
      endcase
      default: case(level)
        0:return thermal?527047716:385947114;
        1:return thermal?114705422:118789159;
        2:return thermal?35256926:44718058;
        3:return thermal?12482109:18280826;
        default:return thermal?4774918:7818597;
      endcase
    endcase
  endfunction

  function automatic longint order(input int first, count);
    longint x=0,y=0,lo=0,hi=2147483647,mid,answer=0,square;
    logic [31:0] a,b;
    for(int i=first;i<first+count;i++) begin
      a=phase[32*i+:32]; b=a+32'h40000000;
      x+=sine_table[b>>20]; y+=sine_table[a>>20];
    end
    x=rounded(x,count); y=rounded(y,count); square=x*x+y*y;
    while(lo<=hi) begin
      mid=(lo+hi)/2;
      if(mid*mid<=square) begin answer=mid; lo=mid+1; end
      else hi=mid-1;
    end
    return answer>Q30?Q30:answer;
  endfunction
  function automatic longint root_floor(input longint square);
    longint lo=0, hi=2147483647, mid, result_value=0;
    while(lo<=hi) begin
      mid=(lo+hi)/2;
      if(mid*mid<=square) begin result_value=mid; lo=mid+1; end
      else hi=mid-1;
    end
    return result_value;
  endfunction
  task automatic hierarchy;
    longint values[CELLS], total, minimum, maximum, mean, variance, delta;
    int base=0, count;
    for(int level=1;level<=INDEX_BITS;level++) begin
      count=CELLS/(1<<level); total=0; minimum=Q30; maximum=0;
      for(int k=0;k<count;k++) begin
        values[k]=order(k*(1<<level),1<<level);
        eq("group coherence",$signed(groups[32*(base+k)+:32]),values[k]);
        total+=values[k];
        if(values[k]<minimum) minimum=values[k];
        if(values[k]>maximum) maximum=values[k];
      end
      mean=rounded(total,count); variance=0;
      for(int k=0;k<count;k++) begin delta=values[k]-mean; variance+=delta*delta; end
      eq("level mean",$signed(means[32*(level-1)+:32]),mean);
      eq("level minimum",$signed(minima[32*(level-1)+:32]),minimum);
      eq("level maximum",$signed(maxima[32*(level-1)+:32]),maximum);
      eq("level dispersion",$signed(dispersions[32*(level-1)+:32]),root_floor(variance/count));
      if(level==1 && maximum-minimum>Q30/4) hierarchy_split++;
      base+=count;
    end
  endtask

  task automatic eq(input string label, input longint got,want);
    checks++;
    if(got!=want) $fatal(1,"%s cells=%0d mode=%0d profile=%0d cycle=%0d got=%0d expected=%0d",
      label,CELLS,mode_id,profile,cycles,got,want);
    signature=(signature^64'(got))*64'h100000001b3;
  endtask

  function automatic int cadence;
    case(gold_mode)
      0:return 0;
      1:return position==7?2:1;
      2:return position==0?3:4;
      default:begin $fatal(1,"Invalid reference mode"); return 7; end
    endcase
  endfunction
  function automatic bit allowed(input int old_value, goal);
    logic [8:0] admission;
    case(cadence())
      0:admission=9'b111111111;
      1,4:admission=9'b111010111;
      2,3:admission=9'b100111001;
      default:admission=0;
    endcase
    return admission[3*(old_value+1)+(goal+1)];
  endfunction
  function automatic logic [1:0] code(input int v);
    return v<0?2'b11:v>0?2'b01:2'b00;
  endfunction
  task automatic predict_execution(
    output logic [CELLS*2-1:0] ns,np,
    output logic [CELLS-1:0] writes,
    output logic [LANES-1:0] accepted, rejected);
    logic [LANES-1:0] valid;
    logic [LANES*INDEX_BITS-1:0] indexes;
    logic [LANES*2-1:0] goals;
    logic [CELLS-1:0] claimed;
    int used,k,ci,old_value,goal;
    ns=state; np=pending; writes=0; claimed=0; used=0; k=0; accepted=0; rejected=0;
    valid=external_request_valid; indexes=external_request_cell_index;
    goals=external_request_target;
    if(auto_target_enable) begin
      valid=0; indexes=0; goals=0;
      for(int i=0;i<CELLS;i++) begin
        old_value=symbol(state[2*i+:2]); goal=symbol(gold_target[2*i+:2]);
        if(gold_valid && k<LANES && pending[2*i+:2]==0 &&
           old_value!=goal && allowed(old_value,goal)) begin
          valid[k]=1; indexes[INDEX_BITS*k+:INDEX_BITS]=INDEX_BITS'(i);
          goals[2*k+:2]=code(goal); k++;
        end
      end
    end
    if(tick_enable) begin
      for(int i=0;i<CELLS;i++)
        if(pending[2*i+:2]!=0 && allowed(0,symbol(pending[2*i+:2])) && used<LANES) begin
          ns[2*i+:2]=pending[2*i+:2]; np[2*i+:2]=0; writes[i]=1; used++;
        end
      for(int j=0;j<LANES;j++) if(valid[j]) begin
        rejected[j]=1;
        ci=int'(indexes[INDEX_BITS*j+:INDEX_BITS]);
        old_value=symbol(state[2*ci+:2]); goal=symbol(goals[2*j+:2]);
        if(!claimed[ci] && pending[2*ci+:2]==0 && allowed(old_value,goal)) begin
          claimed[ci]=1;
          if(old_value==goal || used<LANES) begin accepted[j]=1; rejected[j]=0; end
          if(old_value!=goal && used<LANES) begin
            used++; writes[ci]=1;
            ns[2*ci+:2]=old_value*goal==-1?2'b00:code(goal);
            if(old_value*goal==-1) np[2*ci+:2]=code(goal);
          end
        end
      end
    end
  endtask

  task automatic step(input bit enabled);
    logic [CELLS*32-1:0] next_f, next_h, next_noise, next_gamma, next_atten, next_phase;
    logic [CELLS*2-1:0] old_state, old_pending, next_state, next_pending;
    logic [CELLS-1:0] old_changes, expected_changes;
    logic [31:0] relative_phase;
    longint total,factor,coupling_ref;
    logic [CELLS*32-1:0] candidate_gamma,candidate_atten,old_heat;
    longint target,f,lag_sum,h,diff,power,diss,over,n,g,arg,lag_value;
    longint heat_sum,over_sum,neutral_sum,raw_ref,cluster_ref;
    longint mh,mo,nf,compression_arg,pressure_history,thermal_square;
    longint comp,eff,c,p,m,mean_lag;
    bit commit_sample;
    logic [LANES-1:0] expected_accept, expected_reject;
    int old_cadence, pending_cells;
    longint low_heat, high_heat, noise_goal;
    tick_enable=enabled; #2;
    eq("registered mode before edge",registered_mode,gold_mode);
    eq("cadence before edge",scheduler_state,cadence());
    predict_execution(next_state,next_pending,expected_changes,expected_accept,expected_reject);
    eq("lane acceptance",accepts,expected_accept); eq("lane rejection",rejects,expected_reject);
    eq("remaining transition capacity",remaining,LANES-$countones(expected_changes));
    eq("capacity exhausted",exhausted,$countones(expected_changes)==LANES);
    old_cadence=cadence();
    pending_cells=0;
    for(int i=0;i<CELLS;i++) if(pending[2*i+:2]!=0) pending_cells++;
    if(enabled && pending_cells>LANES) backlog_hits++;
    if(enabled && pending!=0 && external_request_valid!=0 && !auto_target_enable && rejects!=0) arbitration++;
    hierarchy();
    eq("execution change mask",changes,expected_changes);
    old_state=state; old_pending=pending; old_changes=expected_changes;
    eq("logical switch load",load_cost,$countones(changes)*(Q16/CELLS));
    lag_sum=0; heat_sum=0; over_sum=0; neutral_sum=0;
    low_heat=2147483647; high_heat=0;
    old_heat=heat; next_f=freq; next_h=heat; next_noise=noise; next_gamma=gamma;
    next_atten=atten; next_phase=phase;
    for(int i=0;i<CELLS;i++) begin
      target=Q16+(symbol(state[2*i+:2])!=0?3932:0)+(changes[i]?7864:0);
      f=$signed(freq[32*i+:32]);
      f=sat(f+mul(target-f,19661,Q16));
      if(phase_load_valid) f=$signed(frequency_load_q16[32*i+:32]);
      lag_value=target-f; if(lag_value<0) lag_value=-lag_value;
      eq("frequency lag",$signed(lag[32*i+:32]),lag_value);
      lag_sum+=lag_value;
      h=$signed(heat[32*i+:32]); heat_sum+=h;
      if(h<low_heat) low_heat=h; if(h>high_heat) high_heat=h;
      over_sum+=$signed(overload[32*i+:32]);
      neutral_sum+=(state[2*i+:2]==0);
      diff=0;
      for(int j=0;j<CELLS;j++) if(i!=j)
        diff+=mul($signed(heat[32*j+:32])-h,shell(i,j,1),Q30);
      diff=mul(2294,sat(diff),Q16);
      power=sat(118+(changes[i]?3408:0)+mul(lag_value,1180,Q16));
      diss=rounded(h-3277,14); h=sat(h+power-diss+diff);
      if(h<3277) h=3277;
      over=h>14418?h-14418:0;
      n=$signed(noise[32*i+:32]);
      noise_goal=gamma_update_valid?$signed(gamma_targets_q16[32*i+:32]):$signed(noise_target_model[32*i+:32]);
      n=sat(n+mul(noise_goal-n,9830,Q16));
      if(enabled) noise_target_model[32*i+:32]=32'(noise_goal);
      g=mul(mul(5243,over,Q16),n,Q16);
      arg=mul(81920,over,Q16); if(arg>524288) arg=524288;
      candidate_gamma[32*i+:32]=local_gamma_enable?
        32'h26666666+phase_delta(g):gamma_effective_word[32*i+:32];
      candidate_atten[32*i+:32]=local_thermal_enable?
        32'(exp_table[rounded(arg*4095,524288)]):thermal_node_factor_q30[32*i+:32];
      eq("selected gamma candidate",selected_gamma[32*i+:32],candidate_gamma[32*i+:32]);
      eq("selected thermal candidate",selected_atten[32*i+:32],candidate_atten[32*i+:32]);
      if(enabled) begin
        next_f[32*i+:32]=32'(f); next_h[32*i+:32]=32'(h);
        next_noise[32*i+:32]=32'(n);
        next_gamma[32*i+:32]=32'h26666666+phase_delta(g);
        next_atten[32*i+:32]=32'(exp_table[rounded(arg*4095,524288)]);
      end
      if(phase_load_valid) begin
        next_f[32*i+:32]=frequency_load_q16[32*i+:32];
        next_phase[32*i+:32]=phase_load[32*i+:32];
      end
    end
    if(high_heat-low_heat>4096) uneven_heat++;
    // Relative-phase interference uses independently predicted feedback.
    for(int i=0;i<CELLS;i++) begin
      total=0;
      for(int j=0;j<CELLS;j++) if(i!=j) begin
        factor=mul($signed(candidate_atten[32*i+:32]),$signed(candidate_atten[32*j+:32]),Q30);
        factor=mul(shell(i,j,0),factor,Q30);
        relative_phase=phase[32*j+:32]-phase[32*i+:32]-candidate_gamma[32*i+:32];
        total+=mul(factor,sine_table[relative_phase>>20],Q30);
      end
      coupling_ref=mul(18350,rounded(sat(total),16384),Q16);
      eq("relative-phase coupling",$signed(coupling[32*i+:32]),coupling_ref);
      if(enabled && !phase_load_valid)
        next_phase[32*i+:32]=phase[32*i+:32]+phase_delta(sat(
          mul(3932,$signed(next_f[32*i+:32]),Q16)+(cadence()==2?655:cadence()==3?393:197)+coupling_ref));
    end
    // Independent coherence from the pre-edge phase snapshot.
    raw_ref=order(0,CELLS); cluster_ref=0;
    for(int i=0;i<CELLS;i+=4) cluster_ref+=order(i,4);
    cluster_ref=rounded(cluster_ref,CELLS/4);
    eq("raw coherence",raw,raw_ref); eq("cluster coherence",cluster,cluster_ref);
    mh=rounded(heat_sum,CELLS); mo=rounded(over_sum,CELLS);
    nf=rounded(neutral_sum*Q30,CELLS); mean_lag=saved_lag;
    pressure_history=16384-history; if(pressure_history<0) pressure_history=0;
    thermal_square=mul(mo,mo,Q16);
    compression_arg=sat(mul(196608,thermal_square,Q16)
      +mul(98304,sat(rounded(pressure_history*pressure_history,Q16)),Q16));
    arg=compression_arg; if(arg>524288) arg=524288; if(arg<0) arg=0;
    comp=exp_table[rounded(arg*4095,524288)]; eff=mul(raw_ref,comp,Q30);
    c=sat(53740+mul(22282,eff,Q30)+mul(10486,cluster_ref,Q30)
      +mul(5243,nf,Q30)-mul(6554,mean_lag,Q16));
    p=sat(mh+saved_load); m=sat(c-p);
    commit_sample=pending_sample;
    if(commit_sample) begin
      if(m<0) negative_margin++; if(m>0) positive_margin++;
      result_c=c; result_p=p; result_m=m; history=m;
      result_comp=comp; result_eff=eff; samples++;
    end
    if(enabled) begin saved_lag=rounded(lag_sum,CELLS); saved_load=load_cost; end
    pending_sample=enabled;
    if(clear_counters) begin gold_ticks=0; foreach(counts[i]) counts[i]=0; end
    if(enabled) begin
      gold_ticks++; counts[cadence()]++; state_hits[cadence()]++;
      for(int i=0;i<CELLS;i++) begin
        g=sine_table[phase[32*i+:32]>>20];
        gold_target[2*i+:2]=code(g>354334802?1:g< -354334802?-1:0);
      end
      gold_valid=1; position=(position+1)%8;
    end
    if(gold_mode!=int'(scheduler_mode)) mode_changes++;
    gold_mode=int'(scheduler_mode);
    clk=1; #2; cycles++;
    eq("registered mode after edge",registered_mode,gold_mode);
    eq("cadence after edge",scheduler_state,cadence());
    eq("recorded ticks",recorded_ticks,gold_ticks);
    foreach(counts[i]) eq("scheduler count",state_counts[i],counts[i]);
    eq("registered target valid",registered_valid,gold_valid);
    eq("snapshot valid",sample_valid,commit_sample);
    eq("snapshot count",sample_count,samples);
    eq("C",capacity,result_c); eq("P",pressure,result_p);
    eq("C-P",margin,result_m); eq("previous C-P",previous_margin,history);
    eq("compression",compression,result_comp); eq("effective coherence",effective,result_eff);
    eq("stable predicate",stable,result_m>0);
    if(commit_sample) begin
      eq("sample raw",sample_raw,raw_ref); eq("sample cluster",sample_cluster,cluster_ref);
      eq("sample heat",sample_heat,mh); eq("sample overload",sample_overload,mo);
      eq("sample lag",sample_lag,mean_lag); eq("sample neutral",sample_neutral,nf);
      eq("sample compression argument",sample_arg,compression_arg);
      eq("sample switch load",sample_load,p-mh);
      if(!enabled) delayed_commits++;
    end
    for(int i=0;i<CELLS;i++) begin
      eq("registered phase target",registered_target[2*i+:2],gold_target[2*i+:2]);
      eq("ternary execution",state[2*i+:2],next_state[2*i+:2]);
      eq("pending route execution",pending[2*i+:2],next_pending[2*i+:2]);
      if(enabled && $signed(next_h[32*i+:32])<$signed(old_heat[32*i+:32])) cooling_edges++;
      eq("retained frequency",$signed(freq[32*i+:32]),$signed(next_f[32*i+:32]));
      eq("phase integration",phase[32*i+:32],next_phase[32*i+:32]);
      eq("local heat",$signed(heat[32*i+:32]),$signed(next_h[32*i+:32]));
      h=$signed(next_h[32*i+:32]);
      eq("local overload",$signed(overload[32*i+:32]),h>14418?h-14418:0);
      eq("executed change",state[2*i+:2]!=old_state[2*i+:2],old_changes[i]);
      eq("retained noise target",noise_target[32*i+:32],noise_target_model[32*i+:32]);
      eq("noise memory",$signed(noise[32*i+:32]),$signed(next_noise[32*i+:32]));
      eq("gamma memory",gamma[32*i+:32],next_gamma[32*i+:32]);
      eq("attenuation memory",atten[32*i+:32],next_atten[32*i+:32]);
      if(symbol(old_state[2*i+:2])*symbol(state[2*i+:2])==-1)
        $fatal(1,"Direct opposite-polarity transition");
      if(pending[2*i+:2]!=0) begin
        eq("pending active zero",state[2*i+:2],0);
        if(old_pending[2*i+:2]!=0) begin
          eq("retained route polarity",pending[2*i+:2],old_pending[2*i+:2]); retention++;
        end
      end
      if(old_pending[2*i+:2]==0 && pending[2*i+:2]!=0) begin
        routes++; first_cells[i]=1;
        if(old_cadence==1) balancing++;
        if(old_cadence==4) neutralization++;
      end
      if(old_pending[2*i+:2]!=0 && pending[2*i+:2]==0) begin
        eq("route destination",state[2*i+:2],old_pending[2*i+:2]); completions++; second_cells[i]=1;
      end
      if(!enabled) begin
        eq("held state",state[2*i+:2],old_state[2*i+:2]);
        eq("held route",pending[2*i+:2],old_pending[2*i+:2]);
      end
      if(enabled && old_state[2*i+:2]==0 && $signed(freq[32*i+:32])!=65536) zero_memory++;
      if(enabled && $signed(overload[32*i+:32])>0) hot_edges++;
      if(enabled && $signed(gamma[32*i+:32])!=32'h26666666) gamma_edges++;
      if(enabled && $signed(atten[32*i+:32])<Q30) attenuation_edges++;
    end
    eq("direct events",direct_events,0); eq("invariants",invariants,1023);
    if(!enabled) held_edges++;
    clk=0; #1;
  endtask

  task automatic reset_check;
    eq("reset ternary state",state==0,1); eq("reset route state",pending==0,1);
    eq("reset target",registered_target==0,1); eq("reset target valid",registered_valid,0);
    eq("reset mode",registered_mode,0); eq("reset ticks",recorded_ticks,0);
    foreach(counts[i]) eq("reset scheduler count",state_counts[i],0);
    eq("reset sample valid",sample_valid,0); eq("reset sample count",sample_count,0);
    eq("reset C",capacity,65536); eq("reset P",pressure,3277);
    eq("reset C-P",margin,62259); eq("reset history",previous_margin,39322);
    eq("reset compression",compression,Q30); eq("reset effective",effective,0);
    eq("reset stable",stable,1); eq("reset raw sample",sample_raw,0);
    eq("reset cluster sample",sample_cluster,0); eq("reset heat sample",sample_heat,3277);
    eq("reset overload sample",sample_overload,0); eq("reset lag sample",sample_lag,0);
    eq("reset neutral sample",sample_neutral,Q30); eq("reset compression argument",sample_arg,0);
    eq("reset switch sample",sample_load,0);
    for(int i=0;i<CELLS;i++) begin
      eq("reset phase",phase[32*i+:32],32'(64'(i)*(64'd4294967296/CELLS)));
      eq("reset frequency",freq[32*i+:32],65536); eq("reset heat",heat[32*i+:32],3277);
      eq("reset overload",overload[32*i+:32],0); eq("reset noise target",noise_target[32*i+:32],0);
      eq("reset noise",noise[32*i+:32],0); eq("reset gamma",gamma[32*i+:32],32'h26666666);
      eq("reset attenuation",atten[32*i+:32],Q30);
    end
  endtask
  task automatic reset_case(input bit preserve_inputs=0);
    if(!preserve_inputs) begin
      tick_enable=0; phase_load_valid=0; clear_counters=0;
      scheduler_mode=FRP_MODE_FREE; auto_target_enable=0;
      external_request_valid=0; external_request_cell_index=0;
      external_request_target=0; external_target_bank=0;
      local_gamma_enable=1; local_thermal_enable=1; gamma_update_valid=1;
    end
    rst_n=0; #2; reset_check(); clk=1; #2; reset_check(); clk=0;
    rst_n=1; #2;
    gold_mode=0; position=0; gold_ticks=0; gold_target=0; gold_valid=0;
    foreach(counts[i]) counts[i]=0;
    noise_target_model=0; pending_sample=0; saved_lag=0; saved_load=0; history=39322;
    result_c=65536; result_p=3277; result_m=62259;
    result_comp=Q30; result_eff=0; samples=0;
  endtask

  task automatic request_block(input int first, input bit reverse, zero_goal);
    external_request_valid='1;
    for(int j=0;j<LANES;j++) begin
      external_request_cell_index[INDEX_BITS*j+:INDEX_BITS]=INDEX_BITS'(first+j);
      external_request_target[2*j+:2]=zero_goal?2'b00:code(((first+j)%2==0)^reverse?1:-1);
      external_target_bank[2*(first+j)+:2]=external_request_target[2*j+:2];
    end
  endtask

  task automatic source_select(input int source_id);
    local_gamma_enable=source_id[0]; local_thermal_enable=source_id[1];
  endtask
  task automatic prepare(input int mode, source_id, pos);
    int first;
    reset_case(); mode_id=mode; first=(pos%4)*LANES;
    source_select(source_id);
    for(int i=0;i<CELLS;i++) begin
      gamma_targets_q16[32*i+:32]=32'(i%2==0?65536:-65536);
      gamma_effective_word[32*i+:32]=32'h10000000+32'(i)*32'h03123456;
      thermal_node_factor_q30[32*i+:32]=32'(Q30-(i%4)*(Q30/4));
      phase_load[32*i+:32]=(i<2)?32'h20000000:32'(i%2)*32'h80000000;
      frequency_load_q16[32*i+:32]=32'(65536+257*i);
    end
    phase_load_valid=1; step(0); phase_load_valid=0;
    for(int b=0;b<4;b++) begin request_block(b*LANES,0,0); step(1); end
    for(int t=0;t<48;t++) begin request_block(first,0,t%2==0); step(1); end
    external_request_valid=0;
    while(position!=(pos+7)%8) step(1);
    request_block(first,1,0); scheduler_mode=frp_m31_scheduler_mode_e'(mode); step(1);
    eq("prepared cadence position",position,pos);
    eq("prepared snapshot pending",pending_sample,1);
    for(int j=0;j<LANES;j++) begin
      eq("prepared active zero",state[2*(first+j)+:2],0);
      eq("prepared retained destination",pending[2*(first+j)+:2],code((first+j)%2==0?-1:1));
      if($signed(overload[32*(first+j)+:32])<=0 || gamma[32*(first+j)+:32]==32'h26666666)
        $fatal(1,"Preparation requires hot cells and gamma memory");
    end
  endtask
  task automatic sources;
    logic [CELLS*2-1:0] destinations;
    int first, controls;
    for(int m=0;m<3;m++) for(int a=0;a<4;a++) for(int b=0;b<4;b++) begin
      for(int pos=0;pos<8;pos++) begin
        prepare(m,a,pos); destinations=pending; first=(pos%4)*LANES;
        controls=(pos+a+b)%4;
        request_block(first,0,0); source_select(b);
        clear_counters=controls[1]; gamma_update_valid=controls[0];
        gamma_targets_q16=~gamma_targets_q16;
        step(controls[0]); clear_counters=0;
        // Drain saved destinations without admitting a replacement request.
        external_request_valid=0; repeat(16) step(1);
        eq("source handoff drained",pending==0,1);
        for(int j=0;j<LANES;j++)
          eq("source handoff destination",state[2*(first+j)+:2],destinations[2*(first+j)+:2]);
        step(0); step(0); source_hits[m][a][b][pos]++; source_cases++;
      end
      $display("SOURCE cells=%0d mode=%0d from=%0d to=%0d cases=8",CELLS,m,a,b);
    end
    foreach(source_hits[m,a,b,p]) eq("source cross coverage",source_hits[m][a][b][p],1);
    eq("source cases",source_cases,384);
  endtask
  task automatic resets;
    for(int m=0;m<3;m++) for(int src=0;src<4;src++) for(int pos=0;pos<8;pos++) begin
      prepare(m,src,pos);
      // Reset outranks load, requests, target update, counter clear and tick.
      phase_load_valid=pos[0]; clear_counters=pos[1]; tick_enable=pos[2];
      auto_target_enable=pos[0]; gamma_update_valid=1;
      reset_case(1);
      phase_load_valid=0; clear_counters=0; tick_enable=0; external_request_valid=0;
      auto_target_enable=0; gamma_update_valid=0;
      step(0); step(0); eq("no stale snapshot after reset",sample_count,0);
      step(1); eq("fresh snapshot not early",sample_count,0);
      step(0); eq("fresh snapshot committed",sample_count,1);
      step(0); eq("fresh snapshot not duplicated",sample_count,1);
      repeat(8) step(1); step(0); step(0);
      reset_hits[m][src][pos]++; reset_cases++;
    end
    foreach(reset_hits[m,s,p]) eq("reset cross coverage",reset_hits[m][s][p],1);
    eq("reset cases",reset_cases,96);
    $display("RESET cells=%0d cases=%0d",CELLS,reset_cases);
  endtask
  function automatic int unsigned random_next;
    random_word^=random_word<<13; random_word^=random_word>>17;
    random_word^=random_word<<5; return random_word;
  endfunction
  task automatic backlog;
    int v, ci, previous_auto, completed_before, selected;
    logic [CELLS*2-1:0] destinations;
    for(int m=0;m<3;m++) begin
      prepare(m,3,1); random_word=seed^32'(m+1); previous_auto=0;
      if(m!=0) begin
        request_block(0,1,0); step(1);
        request_block(2*LANES,1,0); step(1);
        request_block(3*LANES,1,0); step(1);
      end
      // Retained continuations remain authoritative across request-source changes.
      for(int t=0;t<2048;t++) begin
        v=int'(random_next()); source_select(int'((random_word>>8)&3));
        auto_target_enable=(t%32)>=16;
        if(previous_auto!=int'(auto_target_enable)) auto_switches++;
        previous_auto=int'(auto_target_enable);
        gamma_update_valid=t%5==0; clear_counters=t%61==0;
        for(int i=0;i<CELLS;i++) begin
          gamma_targets_q16[32*i+:32]=32'(int'(random_next()%131073)-65536);
          gamma_effective_word[32*i+:32]=random_next();
          thermal_node_factor_q30[32*i+:32]=random_next()&32'h3fffffff;
        end
        phase_load_valid=t%257==0;
        if(phase_load_valid) begin
          phase_load=phase; frequency_load_q16=freq; ci=(t/257)%CELLS;
          phase_load[32*ci+:32]=phase[32*ci+:32]+32'h40000000;
          for(int j=0;j<LANES;j++) frequency_load_q16[32*((ci+j)%CELLS)+:32]=32'd4194304;
          shock_count++;
        end
        external_request_valid='1;
        for(int lane=0;lane<LANES;lane++) begin
          ci=int'(random_next()%CELLS);
          // Repeated conflicting traffic targets retained routes when present.
          for(int i=CELLS-1;i>=0;i--) if(pending[2*i+:2]!=0) ci=i;
          external_request_cell_index[INDEX_BITS*lane+:INDEX_BITS]=INDEX_BITS'(ci);
          selected=symbol(state[2*ci+:2]);
          external_request_target[2*lane+:2]=code(selected==0?(v[0]?1:-1):-selected);
          external_target_bank[2*ci+:2]=external_request_target[2*lane+:2];
        end
        if(t%29==0) step(0);
        step(1); stream_ticks++; clear_counters=0;
        stream_cross[m][2*int'(local_thermal_enable)+int'(local_gamma_enable)][int'(auto_target_enable)]++;
        phase_load_valid=0;
      end
      destinations=pending; completed_before=completions;
      auto_target_enable=0; external_request_valid=0;
      repeat(32) step(1);
      for(int i=0;i<CELLS;i++) if(destinations[2*i+:2]!=0)
        eq("backlog destination",state[2*i+:2],destinations[2*i+:2]);
      eq("backlog drained",pending==0,1);
      step(0); step(0);
      $display("BACKLOG cells=%0d mode=%0d ticks=2048 final_services=%0d",CELLS,m,completions-completed_before);
    end
    eq("stream ticks",stream_ticks,6144); eq("local disturbances",shock_count,24);
    foreach(stream_cross[m,s,a]) if(stream_cross[m][s][a]==0) $fatal(1,"Stream source cross missing");
    if(negative_margin==0 || positive_margin==0) $fatal(1,"C-P sign coverage missing");
    if(backlog_hits==0 || auto_switches==0 || arbitration==0 || retention==0 || balancing==0 || neutralization==0)
      $fatal(1,"Backlog service coverage incomplete");
  endtask
  initial begin : qualification
    real v;
    if(CELLS!=8 && CELLS!=16 && CELLS!=32) $fatal(1,"Use 8, 16 or 32 cells");
    if($value$plusargs("CASE=%d",case_id)) begin end
    if($value$plusargs("SEED=%d",seed)) begin end
    if(case_id<0 || case_id>3 || seed==0 || seed==1 || seed==2 || seed==3)
      $fatal(1,"CASE must be 0..3; SEED must exceed 3");
    for(int i=0;i<4096;i++) begin
      v=$sin(6.283185307179586476925286766559*i/4096.0)*real'(Q30);
      sine_table[i]=$rtoi(v<0?v-0.5:v+0.5);
      exp_table[i]=$rtoi($exp(-8.0*i/4095.0)*real'(Q30)+0.5);
    end
    eq("rounding self-check",rounded(-3,2),-2); eq("exp endpoint",exp_table[4095],360200);
    if(case_id==0 || case_id==1) sources();
    if(case_id==0 || case_id==2) resets();
    if(case_id==0 || case_id==3) backlog();
    if(routes==0 || zero_memory==0 || hot_edges==0 || gamma_edges==0 ||
       attenuation_edges==0 || cooling_edges==0 || held_edges==0 || delayed_commits==0 ||
       hierarchy_split==0 || uneven_heat==0)
      $fatal(1,"Cross-feedback coverage incomplete");
    if(case_id==0 || case_id==1) begin
      eq("all cells routed",first_cells,{CELLS{1'b1}});
      eq("all cells completed",second_cells,{CELLS{1'b1}});
    end
    foreach(state_hits[i]) if(state_hits[i]==0) $fatal(1,"Scheduler coverage missing");
    $display("PASS CROSS_FEEDBACK cells=%0d case=%0d seed=%0d cycles=%0d checks=%0d sources=%0d resets=%0d stream=%0d routes=%0d completions=%0d retention=%0d balancing=%0d neutralization=%0d arbitration=%0d backlog=%0d hierarchy=%0d uneven_heat=%0d auto_switches=%0d shocks=%0d negative_margin=%0d positive_margin=%0d signature=%016h",
      CELLS,case_id,seed,cycles,checks,source_cases,reset_cases,stream_ticks,routes,completions,
      retention,balancing,neutralization,arbitration,backlog_hits,hierarchy_split,uneven_heat,auto_switches,shock_count,negative_margin,positive_margin,signature);
    $finish;
  end
  initial begin #2000000; $fatal(1,"Cross-feedback timeout"); end
endmodule

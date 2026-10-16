// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 live mode handoff with local thermal/gamma feedback, 8/16/32 cells.
// Checks FREE / 7:1 / 1:7 at all eight cadence positions, with tick hold
// and counter clear, retained active-zero routes and delayed C-P snapshots.
// Independent scheduler, ternary execution, relative-phase coupling,
// thermal/gamma and stability references; public DUT ports only.
// Run from repository root with Verilator --binary --timing --assert
// -Irtl/m31 -Irtl/m32 --top-module frp_m32_feedback_handoff_tb -GCELLS=8.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_feedback_handoff_tb #(parameter int CELLS=8);
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
  int coverage_hits[3][3][8][4], state_hits[5];
  int matrix_cases=0, stream_ticks=0, mode_changes=0;
  int hot_handoffs=0, deferred=0, serviced=0;
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
    .request_accept(), .request_reject(), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(changes), .capacity_remaining(),
    .capacity_exhausted(), .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .reserved_state_events(), .queue_overflow_events(),
    .pair_coherence_q30(), .cluster_coherence_q30(cluster), .global_coherence_q30(raw),
    .organization_dispersion_q30(), .normalized_cycle_cost_q16(load_cost), .temperature_proxy_q16(),
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stable(), .local_heat_q16(heat),
    .local_heat_peak_q16(), .local_generated_power_q16(), .local_thermal_dissipation_q16(),
    .local_thermal_diffusion_q16(), .local_thermal_overload_q16(overload), .local_next_heat_q16(),
    .local_next_overload_q16(), .local_frequency_lag_q16(lag), .local_mean_heat_peak_q16(),
    .local_maximum_heat_peak_q16(), .local_gamma_noise_target_q16(), .local_gamma_noise_state_q16(noise),
    .local_gamma_drift_word(), .local_gamma_effective_word(gamma), .local_next_gamma_drift_word(),
    .local_next_gamma_effective_word(), .phase_gamma_effective_word(selected_gamma), .local_thermal_node_factor_q30(atten),
    .local_next_thermal_node_factor_q30(), .phase_thermal_node_factor_q30(selected_atten), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(), .level_max_coherence_q30(),
    .level_dispersion_q30(), .local_coherence_compression_q30(compression), .local_effective_coherence_q30(effective),
    .local_coherence_capacity_q16(capacity), .local_pressure_q16(pressure), .local_stable(stable),
    .local_previous_margin_q16(previous_margin), .local_stability_valid_q(sample_valid), .local_stability_sample_count_q(sample_count),
    .local_stability_raw_coherence_q30(sample_raw), .local_stability_cluster_coherence_q30(sample_cluster), .local_stability_mean_heat_q16(sample_heat),
    .local_stability_mean_overload_q16(sample_overload), .local_stability_mean_lag_q16(sample_lag), .local_stability_neutral_fraction_q30(sample_neutral),
    .local_stability_compression_arg_q16(sample_arg), .local_stability_switch_load_q16(sample_load)
  );

  int sine_table[4096], exp_table[4096];
  int checks=0, cycles=0, cases=0, routes=0, completions=0;
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
    output logic [CELLS-1:0] writes);
    logic [LANES-1:0] valid;
    logic [LANES*INDEX_BITS-1:0] indexes;
    logic [LANES*2-1:0] goals;
    logic [CELLS-1:0] claimed;
    int used,k,ci,old_value,goal;
    ns=state; np=pending; writes=0; claimed=0; used=0; k=0;
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
        ci=int'(indexes[INDEX_BITS*j+:INDEX_BITS]);
        old_value=symbol(state[2*ci+:2]); goal=symbol(goals[2*j+:2]);
        if(!claimed[ci] && pending[2*ci+:2]==0 && allowed(old_value,goal)) begin
          claimed[ci]=1;
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
    tick_enable=enabled; #2;
    eq("registered mode before edge",registered_mode,gold_mode);
    eq("cadence before edge",scheduler_state,cadence());
    predict_execution(next_state,next_pending,expected_changes);
    eq("execution change mask",changes,expected_changes);
    old_state=state; old_pending=pending; old_changes=expected_changes;
    eq("logical switch load",load_cost,$countones(changes)*(Q16/CELLS));
    lag_sum=0; heat_sum=0; over_sum=0; neutral_sum=0;
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
      n=sat(n+mul($signed(gamma_targets_q16[32*i+:32])-n,9830,Q16));
      g=mul(mul(5243,over,Q16),n,Q16);
      arg=mul(81920,over,Q16); if(arg>524288) arg=524288;
      eq("candidate gamma",selected_gamma[32*i+:32],32'(32'h26666666+phase_delta(g)));
      eq("candidate attenuation",$signed(selected_atten[32*i+:32]),exp_table[rounded(arg*4095,524288)]);
      candidate_gamma[32*i+:32]=32'h26666666+phase_delta(g);
      candidate_atten[32*i+:32]=32'(exp_table[rounded(arg*4095,524288)]);
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
      eq("noise memory",$signed(noise[32*i+:32]),$signed(next_noise[32*i+:32]));
      eq("gamma memory",gamma[32*i+:32],next_gamma[32*i+:32]);
      eq("attenuation memory",atten[32*i+:32],next_atten[32*i+:32]);
      if(symbol(old_state[2*i+:2])*symbol(state[2*i+:2])==-1)
        $fatal(1,"Direct opposite-polarity transition");
      if(pending[2*i+:2]!=0) begin
        eq("pending active zero",state[2*i+:2],0);
        if(old_pending[2*i+:2]!=0)
          eq("retained route polarity",pending[2*i+:2],old_pending[2*i+:2]);
      end
      if(old_pending[2*i+:2]==0 && pending[2*i+:2]!=0) begin
        routes++; first_cells[i]=1;
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

  task automatic reset_case;
    tick_enable=0; phase_load_valid=0; clear_counters=0;
    scheduler_mode=FRP_MODE_FREE; auto_target_enable=0;
    external_request_valid=0; external_request_cell_index=0;
    external_request_target=0; external_target_bank=0;
    rst_n=0; #2; clk=1; #2; clk=0; rst_n=1; #2;
    local_gamma_enable=1; local_thermal_enable=1; gamma_update_valid=1;
    gold_mode=0; position=0; gold_ticks=0; gold_target=0; gold_valid=0;
    foreach(counts[i]) counts[i]=0;
    pending_sample=0; saved_lag=0; saved_load=0; history=39322;
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

  task automatic handoff(input int from_mode,to_mode,pos,controls);
    int first;
    logic [CELLS*2-1:0] saved_routes;
    logic [CELLS*32-1:0] saved_phase;
    bit ready;
    reset_case(); mode_id=from_mode; profile=controls; first=(pos%4)*LANES;
    gamma_targets_q16={CELLS{controls[1]?32'hffff0000:32'h00010000}};
    for(int i=0;i<CELLS;i++) begin
      phase_load[32*i+:32]=32'(i)*32'h10000000;
      frequency_load_q16[32*i+:32]=32'(65536+257*i);
    end
    phase_load_valid=1; step(0); phase_load_valid=0;
    for(int block_id=0;block_id<4;block_id++) begin request_block(block_id*LANES,0,0); step(1); end
    // Repeated legal neutral/nonzero writes establish local feedback history.
    for(int t=0;t<48;t++) begin request_block(first,0,t%2==0); step(1); end
    external_request_valid=0;
    while(position!=(pos+7)%8) step(1);
    request_block(first,1,0); scheduler_mode=frp_m31_scheduler_mode_e'(from_mode); step(1);
    eq("handoff position",position,pos); saved_routes=pending; ready=0;
    for(int j=0;j<LANES;j++) begin
      eq("prepared zero",state[2*(first+j)+:2],0);
      eq("prepared route",pending[2*(first+j)+:2],code((first+j)%2==0?-1:1));
      if($signed(overload[32*(first+j)+:32])>0) ready=1;
    end
    if(!ready) $fatal(1,"Handoff lacks active thermal overload");
    hot_handoffs++; saved_phase=phase;
    // Conflicting new goals must not overwrite retained route destinations.
    request_block(first,0,0); scheduler_mode=frp_m31_scheduler_mode_e'(to_mode);
    clear_counters=controls[1]; step(controls[0]); clear_counters=0;
    if(!controls[0]) begin
      eq("held handoff phase",phase==saved_phase,1);
      eq("held handoff routes",pending==saved_routes,1); deferred++;
    end
    external_request_valid=0;
    // New cadence must service every saved route within two complete periods.
    repeat(16) step(1);
    eq("drained routes",pending==0,1);
    for(int j=0;j<LANES;j++) eq("saved destination",state[2*(first+j)+:2],saved_routes[2*(first+j)+:2]);
    serviced++; step(0); step(0);
    coverage_hits[from_mode][to_mode][pos][controls]++; matrix_cases++;
  endtask

  initial begin : qualification
    real v;
    logic [31:0] random_word;
    if(CELLS!=8 && CELLS!=16 && CELLS!=32) $fatal(1,"Use 8, 16 or 32 cells");
    for(int i=0;i<4096;i++) begin
      v=$sin(6.283185307179586476925286766559*i/4096.0)*real'(Q30);
      sine_table[i]=$rtoi(v<0?v-0.5:v+0.5);
      exp_table[i]=$rtoi($exp(-8.0*i/4095.0)*real'(Q30)+0.5);
    end
    eq("rounding self-check",rounded(-3,2),-2);
    eq("exp endpoint",exp_table[4095],360200);
    for(int a=0;a<3;a++) for(int b=0;b<3;b++) begin
      for(int p=0;p<8;p++) for(int c=0;c<4;c++) handoff(a,b,p,c);
      $display("HANDOFF cells=%0d from=%0d to=%0d cases=32",CELLS,a,b);
    end
    foreach(coverage_hits[a,b,p,c]) eq("handoff coverage",coverage_hits[a][b][p][c],1);
    // Autonomous phase-target execution with repeated mode changes and holds.
    for(profile=0;profile<2;profile++) begin
      reset_case(); auto_target_enable=1;
      gamma_targets_q16={CELLS{profile==0?32'h00010000:32'hffff0000}};
      random_word=32'h69a12345+32'(profile);
      for(int t=0;t<1024;t++) begin
        random_word=random_word*32'd1664525+32'd1013904223;
        mode_id=int'((random_word>>24)%3);
        scheduler_mode=frp_m31_scheduler_mode_e'(mode_id);
        clear_counters=t%61==0;
        if(t%11==0) step(0);
        step(1); stream_ticks++; clear_counters=0;
      end
      step(0); step(0);
      $display("STREAM cells=%0d profile=%0d ticks=1024 snapshots=%0d",CELLS,profile,samples);
      eq("stream snapshots",samples,1024);
    end
    eq("matrix cases",matrix_cases,288); eq("hot handoffs",hot_handoffs,288);
    eq("deferred handoffs",deferred,144); eq("serviced handoffs",serviced,288);
    eq("stream ticks",stream_ticks,2048);
    eq("all cells routed",first_cells,{CELLS{1'b1}});
    eq("all cells completed",second_cells,{CELLS{1'b1}});
    foreach(state_hits[i]) if(state_hits[i]==0) $fatal(1,"Scheduler coverage missing");
    if(routes==0 || completions==0 || zero_memory==0 || hot_edges==0 ||
       gamma_edges==0 || attenuation_edges==0 || cooling_edges==0 ||
       held_edges==0 || delayed_commits==0 || mode_changes==0)
      $fatal(1,"Feedback handoff coverage incomplete");
    $display("PASS FEEDBACK_HANDOFF cells=%0d cases=%0d cycles=%0d checks=%0d streams=%0d modes=%0d routes=%0d completions=%0d zero_memory=%0d hot=%0d gamma=%0d attenuation=%0d cooling=%0d holds=%0d delayed=%0d signature=%016h",
      CELLS,matrix_cases,cycles,checks,stream_ticks,mode_changes,routes,completions,
      zero_memory,hot_edges,gamma_edges,attenuation_edges,cooling_edges,held_edges,delayed_commits,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Feedback handoff timeout"); end
endmodule

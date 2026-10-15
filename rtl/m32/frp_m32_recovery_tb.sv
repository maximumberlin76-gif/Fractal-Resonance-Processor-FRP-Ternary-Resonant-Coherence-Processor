// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 phase disturbance and autonomous recovery, 8/16/32 cells.
// Checks the delayed C-P snapshot, local thermal/gamma feedback, frequency
// memory and tick-separated active-zero routes through public ports only.
// Four phase-burst profiles cross FREE / 7:1 / 1:7 scheduling. Each burst
// preserves frequency and is followed by 1024 autonomous enabled ticks.
// Recovery requires mean R >= 15/16 over the final 64 ticks, improvement
// over the immediate shock, and C-P > 0 throughout the recovery window.
// Independent integer rounding, analytic sine/exp tables and snapshot oracle.
// Run from repository root with Verilator --binary --timing --assert
// -Irtl/m31 -Irtl/m32 --top-module frp_m32_recovery_tb -GCELLS=8.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_recovery_tb #(parameter int CELLS=8);
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
    .registered_target_q(), .registered_target_valid_q(), .state_out(state),
    .pending_route_out(pending), .scheduler_mode_q(), .scheduler_state_q(scheduler_state),
    .accepted_changes(), .switch_load_numerator(), .actual_direct_events(direct_events),
    .invariant_flags(invariants), .local_mean_heat_q16(), .stability_margin_q16(),
    .local_stability_margin_q16(margin), .phase_target_domain_valid(), .registered_target_domain_valid(),
    .target_capture_accepted(), .target_capture_rejected(), .accepted_target_capture_events_q(),
    .rejected_target_capture_events_q(), .registered_request_enable(), .phase_request_valid(),
    .phase_request_cell_index(), .phase_request_target(), .execution_request_valid(),
    .execution_request_cell_index(), .execution_request_target(), .execution_target_bank(),
    .ticks_recorded_q(), .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(), .scheduler_count_neutralize_q(),
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
  bit pending_sample=0, recovery_window=0;
  int recovery_samples=0;
  longint early_margin,late_margin,early_raw,late_raw,min_margin,peak_heat,prior_heat;
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
  function automatic longint thermal_weight(input int a,b);
    int span=2, level=0;
    while(a/span!=b/span) begin span*=2; level++; end
    case(CELLS)
      8:case(level)
        0:return 630553580; 1:return 137232194; default:return 42180964;
      endcase
      16:case(level)
        0:return 567420738; 1:return 123492111;
        2:return 37957684; default:return 13438266;
      endcase
      default:case(level)
        0:return 527047716; 1:return 114705422; 2:return 35256926;
        3:return 12482109; default:return 4774918;
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

  task automatic step(input bit enabled);
    logic [CELLS*32-1:0] next_f, next_h, next_noise, next_gamma, next_atten, next_phase;
    logic [CELLS*2-1:0] old_state, old_pending;
    logic [CELLS-1:0] old_changes;
    longint target,f,lag_sum,h,diff,power,diss,over,n,g,arg,lag_value;
    longint heat_sum,over_sum,neutral_sum,raw_ref,cluster_ref;
    longint mh,mo,nf,compression_arg,pressure_history,thermal_square;
    longint comp,eff,c,p,m,mean_lag;
    bit commit_sample;
    tick_enable=enabled; #2;
    old_state=state; old_pending=pending; old_changes=changes;
    eq("logical switch load",load_cost,$countones(changes)*(Q16/CELLS));
    lag_sum=0; heat_sum=0; over_sum=0; neutral_sum=0;
    next_f=freq; next_h=heat; next_noise=noise; next_gamma=gamma;
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
        diff+=mul($signed(heat[32*j+:32])-h,thermal_weight(i,j),Q30);
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
      if(enabled) begin
        next_f[32*i+:32]=32'(f); next_h[32*i+:32]=32'(h);
        next_noise[32*i+:32]=32'(n);
        next_gamma[32*i+:32]=32'h26666666+phase_delta(g);
        next_atten[32*i+:32]=32'(exp_table[rounded(arg*4095,524288)]);
        next_phase[32*i+:32]=phase[32*i+:32]+phase_delta(
          sat(mul(3932,f,Q16)+(scheduler_state==FRP_SCHED_COMMIT?655:
          scheduler_state==FRP_SCHED_EXCITE?393:197)+$signed(coupling[32*i+:32])));
      end
      if(phase_load_valid) begin
        next_f[32*i+:32]=frequency_load_q16[32*i+:32];
        next_phase[32*i+:32]=phase_load[32*i+:32];
      end
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
    clk=1; #2; cycles++;
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
      if(recovery_window) begin
        recovery_samples++;
        if(margin<=0) $fatal(1,"Non-positive C-P during recovery");
        if(recovery_samples<=64) begin early_margin+=margin; early_raw+=sample_raw; end
        if(recovery_samples>960) begin late_margin+=margin; late_raw+=sample_raw; end
        if(margin<min_margin) min_margin=margin;
        if(sample_heat>peak_heat) peak_heat=sample_heat;
        if(sample_heat<prior_heat) cooling_edges++;
        prior_heat=sample_heat;
      end
    end
    for(int i=0;i<CELLS;i++) begin
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
      if(old_pending[2*i+:2]==0 && pending[2*i+:2]!=0) routes++;
      if(old_pending[2*i+:2]!=0 && pending[2*i+:2]==0) begin
        eq("route destination",state[2*i+:2],old_pending[2*i+:2]); completions++;
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
    rst_n=0; #2; clk=1; #2; clk=0; rst_n=1; #2;
    local_gamma_enable=1; local_thermal_enable=1; gamma_update_valid=1;
    pending_sample=0; saved_lag=0; saved_load=0; history=39322;
    result_c=65536; result_p=3277; result_m=62259;
    result_comp=Q30; result_eff=0; samples=0;
  endtask

  initial begin : qualification
    real v;
    longint start_heat,end_heat,shock_raw;
    int initial_routes,initial_completions;
    if(CELLS!=8 && CELLS!=16 && CELLS!=32) $fatal(1,"Use 8, 16 or 32 cells");
    for(int i=0;i<4096;i++) begin
      v=$sin(6.283185307179586476925286766559*i/4096.0)*real'(Q30);
      sine_table[i]=$rtoi(v<0?v-0.5:v+0.5);
      exp_table[i]=$rtoi($exp(-8.0*i/4095.0)*real'(Q30)+0.5);
    end
    eq("rounding self-check",rounded(-3,2),-2);
    eq("exp endpoint",exp_table[4095],360200);
    for(mode_id=0;mode_id<3;mode_id++) for(profile=0;profile<4;profile++) begin
      reset_case(); scheduler_mode=frp_m31_scheduler_mode_e'(mode_id);
      gamma_targets_q16={CELLS{profile[0]?32'hffff0000:32'h00010000}};
      phase_load={CELLS{32'h20000000}}; frequency_load_q16={CELLS{32'd65536}};
      phase_load_valid=1; step(0); phase_load_valid=0;
      repeat(256) step(1);
      initial_routes=routes; initial_completions=completions;
      // Sixteen relative impulses, then a defined two-group phase split.
      // Preserve the common phase origin and every retained frequency.
      // No thermal or execution-state reset occurs during the disturbance.
      for(int kick=0;kick<17;kick++) begin
        frequency_load_q16=freq;
        for(int i=0;i<CELLS;i++) begin
          if(profile<2)
            phase_load[32*i+:32]=(kick==16?phase[31:0]:phase[32*i+:32])+(i<CELLS/2?32'h78000000:0);
          else
            phase_load[32*i+:32]=(kick==16?phase[31:0]:phase[32*i+:32])+(i%2?32'h38000000:32'hc8000000);
        end
        // Drain the previous stability snapshot before a phase-only load.
        step(0); phase_load_valid=1; step(0); phase_load_valid=0;
        if(kick<16) repeat(8) step(1);
      end
      shock_raw=raw;
      if(shock_raw>=Q30/4) $fatal(1,"Phase shock coverage missing R=%0d",shock_raw);
      early_margin=0; late_margin=0; early_raw=0; late_raw=0;
      min_margin=2147483647; peak_heat=0; start_heat=sample_heat; prior_heat=start_heat;
      recovery_samples=0; recovery_window=1;
      // No phase/frequency loads, reset or external requests in this window.
      for(int t=0;t<1024;t++) begin
        clear_counters=(t==127 || t==511); step(1); clear_counters=0;
        if(t%97==0) begin step(0); step(0); end

      end
      step(0); step(0); recovery_window=0; end_heat=sample_heat;
      eq("recovery snapshots",recovery_samples,1024);
      $display("RECOVERY cells=%0d mode=%0d profile=%0d early_margin=%0d late_margin=%0d early_R=%0d late_R=%0d shock_R=%0d min_margin=%0d start_heat=%0d end_heat=%0d peak_heat=%0d routes=%0d completions=%0d",
        CELLS,mode_id,profile,early_margin/64,late_margin/64,early_raw/64,late_raw/64,
        shock_raw,min_margin,start_heat,end_heat,peak_heat,routes-initial_routes,completions-initial_completions);
      if(min_margin<=0 || late_raw<64*(Q30*15/16) ||
         late_raw/64<shock_raw+Q30/16 || routes==initial_routes ||
         completions==initial_completions)
        $fatal(1,"Recovery acceptance failed cells=%0d mode=%0d profile=%0d",CELLS,mode_id,profile);
      cases++;
    end
    if(cases!=12 || zero_memory==0 || hot_edges==0 || gamma_edges==0 ||
       attenuation_edges==0 || cooling_edges==0 || held_edges==0 || delayed_commits==0)
      $fatal(1,"Recovery feedback coverage incomplete");
    $display("PASS RECOVERY cells=%0d cases=%0d cycles=%0d checks=%0d routes=%0d completions=%0d zero_memory=%0d hot=%0d gamma=%0d attenuation=%0d cooling=%0d holds=%0d delayed=%0d signature=%016h",
      CELLS,cases,cycles,checks,routes,completions,zero_memory,hot_edges,gamma_edges,
      attenuation_edges,cooling_edges,held_edges,delayed_commits,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Recovery timeout"); end
endmodule

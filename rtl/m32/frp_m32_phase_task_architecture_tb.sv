// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Common sampled phase-selection task: binary arithmetic reference and M32.
// Inputs: initial phases, retained polarity/frequency, gamma, attenuation, mode.
// Both paths evolve the same phase recurrence and must select the same symbols.
// The binary reference evaluates signed fixed-point sums and directly commits
// two-rail symbols. M32 uses its phase engine, registered boundary and routes.
// After the compute window, phase loads retain the sampled phase/frequency
// snapshot while execution completes. A second window exercises zero memory.
// Historical v0.9.3 execution heat rules are reported separately from native
// M32 thermal/stability telemetry. Reference arithmetic is evaluated behaviorally.
// Compile from repository root: --binary --timing --assert -Irtl/m31 -Irtl/m32
// --top-module frp_m32_phase_task_architecture_tb -GCELLS=8 (or 16,32,64).
// Per-mode records retain separate execution-heat and native telemetry units.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_phase_task_architecture_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  localparam int LANES=CELLS/4, INDEX_BITS=$clog2(CELLS);
  localparam int BANK_WORDS=(2*CELLS+63)/64;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_load_valid=0, auto_target_enable=0;
  logic local_gamma_enable=0, gamma_update_valid=0, local_thermal_enable=0;
  logic [CELLS*32-1:0] phase_load=0, frequency_load_q16=0;
  logic [CELLS*32-1:0] gamma_effective_word=0, gamma_targets_q16=0;
  logic [CELLS*32-1:0] thermal_node_factor_q30={CELLS{32'h40000000}};
  logic [LANES-1:0] external_request_valid=0;
  logic [LANES*INDEX_BITS-1:0] external_request_cell_index=0;
  logic [LANES*2-1:0] external_request_target=0;
  logic [CELLS*2-1:0] external_target_bank=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  wire [CELLS*32-1:0] phase_word_q, frequency_current_q16;
  wire [CELLS*32-1:0] coupling_field_q16, phase_projection_q30;
  wire [CELLS*2-1:0] phase_target_source, registered_target_q;
  wire [CELLS*2-1:0] state_out, pending_route_out;
  wire registered_target_valid_q;
  wire [31:0] accepted_changes, switch_load_numerator, actual_direct_events;
  wire [9:0] invariant_flags;
  wire signed [31:0] local_mean_heat_q16, stability_margin_q16;
  wire signed [31:0] local_stability_margin_q16, temperature_proxy_q16;

  frp_m32_core #(.CELLS(CELLS)) dut (
    .clk, .rst_n, .tick_enable,
    .clear_counters, .scheduler_mode, .phase_load_valid,
    .phase_load, .frequency_load_q16, .gamma_effective_word,
    .thermal_node_factor_q30, .auto_target_enable, .external_request_valid,
    .external_request_cell_index, .external_request_target, .external_target_bank,
    .local_gamma_enable, .gamma_update_valid, .gamma_targets_q16,
    .local_thermal_enable, .phase_word_q, .frequency_current_q16,
    .coupling_field_q16, .phase_projection_q30, .phase_target_source,
    .registered_target_q, .registered_target_valid_q, .state_out,
    .pending_route_out, .scheduler_mode_q, .scheduler_state_q,
    .accepted_changes, .switch_load_numerator, .actual_direct_events,
    .invariant_flags, .local_mean_heat_q16, .stability_margin_q16,
    .local_stability_margin_q16, .phase_target_domain_valid(), .registered_target_domain_valid(),
    .target_capture_accepted(), .target_capture_rejected(), .accepted_target_capture_events_q(),
    .rejected_target_capture_events_q(), .registered_request_enable(), .phase_request_valid(),
    .phase_request_cell_index(), .phase_request_target(), .execution_request_valid(),
    .execution_request_cell_index(), .execution_request_target(), .execution_target_bank(),
    .ticks_recorded_q(), .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(), .scheduler_count_neutralize_q(),
    .request_accept(), .request_reject(), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(), .capacity_remaining(),
    .capacity_exhausted(), .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .reserved_state_events(), .queue_overflow_events(),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30(), .normalized_cycle_cost_q16(), .temperature_proxy_q16,
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stable(), .local_heat_q16(),
    .local_heat_peak_q16(), .local_generated_power_q16(), .local_thermal_dissipation_q16(),
    .local_thermal_diffusion_q16(), .local_thermal_overload_q16(), .local_next_heat_q16(),
    .local_next_overload_q16(), .local_frequency_lag_q16(), .local_mean_heat_peak_q16(),
    .local_maximum_heat_peak_q16(), .local_gamma_noise_target_q16(), .local_gamma_noise_state_q16(),
    .local_gamma_drift_word(), .local_gamma_effective_word(), .local_next_gamma_drift_word(),
    .local_next_gamma_effective_word(), .phase_gamma_effective_word(), .local_thermal_node_factor_q30(),
    .local_next_thermal_node_factor_q30(), .phase_thermal_node_factor_q30(), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(), .level_max_coherence_q30(),
    .level_dispersion_q30(), .local_coherence_compression_q30(), .local_effective_coherence_q30(),
    .local_coherence_capacity_q16(), .local_pressure_q16(), .local_stable(),
    .local_previous_margin_q16(), .local_stability_valid_q(), .local_stability_sample_count_q(),
    .local_stability_raw_coherence_q30(), .local_stability_cluster_coherence_q30(), .local_stability_mean_heat_q16(),
    .local_stability_mean_overload_q16(), .local_stability_mean_lag_q16(), .local_stability_neutral_fraction_q30(),
    .local_stability_compression_arg_q16(), .local_stability_switch_load_q16()
  );

  word_t sine_table[4096], frequency[CELLS], fields[CELLS];
  logic [31:0] phase[CELLS], uncoupled[CELLS];
  int reference_state[CELLS], goal[CELLS], binary_state[CELLS];
  int mode_ref=0, position_ref=0, cases=0, checks=0, cycles=0;
  int phase_updates=0, relative_decisions=0, target_bins[3];
  int first_legs=0, second_legs=0, retained_pauses=0, balance_holds=0;
  int balance_entries=0, neutralize_entries=0, neutral_goals=0;
  int zero_memory_updates=0, zero_phase_updates=0, boundary_lags=0;
  int binary_direct=0, binary_toggles=0, frp_changes=0;
  int binary_peak_heat=0, frp_peak_heat=0, frp_heat=0;
  int binary_peak_switch=0, frp_peak_switch=0, execution_ticks=0;
  int binary_min_margin=2147483647, frp_min_margin=2147483647;
  int native_peak_heat=0, native_min_margin=2147483647;
  int native_local_min_margin=2147483647;
  int routed[3][CELLS][2], completed[3][CELLS][2];
  typedef struct {
    int cases, relative_decisions, routes, completed;
    int binary_direct, binary_toggles, changes, ticks, max_task_ticks;
    int binary_heat_peak, frp_heat_peak, binary_switch_peak, frp_switch_peak;
    int binary_margin_min, frp_margin_min;
    int local_heat_peak, proxy_peak, margin_min, local_margin_min;
  } mode_stats_t;
  mode_stats_t mode_stats[3];
  int task_hits[3][2][4][6], mode_targets[3][3];
  int mode_checks=0, bank_words_checked=0;
  int case_mode=0, case_seed_state=0;
  bit measure=0;
  int unsigned rng=32'h64a031f7;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic logic [31:0] random_word;
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction

  function automatic logic [1:0] enc(input int value);
    case(value)
      -1:return 2'b11; 0:return 2'b00; 1:return 2'b01;
      default:begin $fatal(1,"Invalid reference symbol"); return 2'b10; end
    endcase
  endfunction

  function automatic int dec(input logic [1:0] value);
    case(value)
      2'b11:return -1; 2'b00:return 0; 2'b01:return 1;
      default:begin $fatal(1,"Reserved retained symbol"); return 2; end
    endcase
  endfunction

  function automatic int selection(input logic [31:0] angle);
    word_t v;
    v=sine_table[angle[31:20]];
    return v>354334802 ? 1 : (v< -354334802 ? -1 : 0);
  endfunction

  function automatic int cadence;
    case(mode_ref)
      0:return 0;
      1:return position_ref==7 ? 2:1;
      2:return position_ref==0 ? 3:4;
      default:begin $fatal(1,"Invalid mode"); return 7; end
    endcase
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
      64: case(level)
        0:return 350050538; 1:return 107740697; 2:return 40558875;
        3:return 16580545; 4:return 7091397; default:return 3120865;
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
    logic [31:0] angle;
    sum=0;
    for(int j=0;j<CELLS;j++) if(j!=receiver) begin
      angle=phase[j]-phase[receiver]-gamma_effective_word[receiver*32+:32];
      factor=product(word_t'(thermal_node_factor_q30[receiver*32+:32]),
                     word_t'(thermal_node_factor_q30[j*32+:32]),30);
      term=product(product(weight(receiver,j),factor,30),sine_table[angle[31:20]],30);
      sum+=longint'(term);
    end
    return product(18350,clipped(rounded(longint'(clipped(sum)),16384)),16);
  endfunction

  function automatic logic [31:0] phase_step(input word_t velocity);
    longint signed magnitude, delta;
    magnitude=longint'(velocity);
    if(magnitude<0) magnitude=-magnitude;
    delta=magnitude*10430+rounded(magnitude*64'sd1625002897,64'sd4294967296);
    return 32'(velocity<0 ? -delta:delta);
  endfunction

  task automatic eq(input logic [63:0] got,wanted,input string label_text);
    checks++;
    if(got!==wanted)
      $fatal(1,"PHASE_TASK N=%0d case=%0d cycle=%0d %s got=%h expected=%h",
             CELLS,cases,cycles,label_text,got,wanted);
    signature=(signature^wanted)*64'h100000001b3;
  endtask

  task automatic eq_bank(
    input logic [CELLS*2-1:0] got, wanted,
    input string label_text
  );
    logic [BANK_WORDS*64-1:0] padded_got, padded_wanted;
    padded_got='0; padded_wanted='0;
    padded_got[CELLS*2-1:0]=got;
    padded_wanted[CELLS*2-1:0]=wanted;
    // Low-word check order preserves the 8/16/32-cell regression signatures.
    for(int w=0;w<BANK_WORDS;w++) begin
      eq(padded_got[w*64+:64],padded_wanted[w*64+:64],
         $sformatf("%s word=%0d",label_text,w));
      bank_words_checked++;
    end
  endtask

  task automatic mode_require(input bit condition, input string label_text);
    mode_checks++;
    if(!condition) $fatal(1,"Mode qualification N=%0d %s",CELLS,label_text);
  endtask

  task automatic check_phase;
    for(int c=0;c<CELLS;c++) begin
      eq(64'(phase_word_q[c*32+:32]),64'(phase[c]),"computed phase");
      eq(64'(frequency_current_q16[c*32+:32]),64'($unsigned(frequency[c])),"retained frequency");
      eq(64'(coupling_field_q16[c*32+:32]),64'($unsigned(field_for(c))),"relative field");
      eq(64'(phase_projection_q30[c*32+:32]),64'($unsigned(sine_table[phase[c][31:20]])),"projection");
      eq(64'(phase_target_source[c*2+:2]),64'(enc(selection(phase[c]))),"resonant selection");
    end
  endtask

  task automatic predict_phase;
    word_t target, correction, velocity, isolated_velocity, old_frequency;
    logic [31:0] old_phase;
    int push;
    for(int c=0;c<CELLS;c++) fields[c]=field_for(c);
    push=cadence()==2 ? 655:(cadence()==3 ? 393:197);
    for(int c=0;c<CELLS;c++) begin
      old_frequency=frequency[c]; old_phase=phase[c];
      target=65536+(reference_state[c]!=0 ? 3932:0);
      correction=clipped(rounded((longint'(target)-longint'(frequency[c]))*19661,65536));
      frequency[c]=clipped(longint'(frequency[c])+longint'(correction));
      isolated_velocity=word_t'(longint'(product(frequency[c],3932,16))+push);
      velocity=word_t'(longint'(isolated_velocity)+longint'(fields[c]));
      uncoupled[c]=phase[c]+phase_step(isolated_velocity);
      phase[c]+=phase_step(velocity);
      if(reference_state[c]==0) begin
        if(frequency[c]!=old_frequency && frequency[c]!=0) zero_memory_updates++;
        if(phase[c]!=old_phase) zero_phase_updates++;
      end
    end
    phase_updates++;
  endtask

  task automatic clock_step(input bit enabled);
    logic [CELLS*2-1:0] old_state,old_pending,old_target,captured;
    logic [CELLS*32-1:0] old_phase,old_frequency;
    int old_cadence, changes, zeros, active, debt, conflicts, margin;
    int old_value,new_value,saved_value,new_saved, advertised_changes;
    bit old_valid;
    clk=0; tick_enable=enabled; #1;
    old_state=state_out; old_pending=pending_route_out;
    old_phase=phase_word_q; old_frequency=frequency_current_q16;
    old_target=registered_target_q; old_valid=registered_target_valid_q;
    captured=phase_target_source; old_cadence=cadence();
    advertised_changes=int'(accepted_changes);
    eq(64'(scheduler_mode_q),64'(mode_ref),"scheduler mode");
    eq(64'(scheduler_state_q),64'(old_cadence),"scheduler cadence");
    eq(64'(actual_direct_events),0,"direct event signal");
    eq(64'(invariant_flags),1023,"execution invariants");
    if(enabled) position_ref=(position_ref+1)%8;
    mode_ref=int'(scheduler_mode);
    clk=1; #1;
    if(enabled) begin
      eq_bank(registered_target_q,captured,"pre-edge phase capture");
      eq(64'(registered_target_valid_q),1,"capture valid");
    end else begin
      eq_bank(registered_target_q,old_target,"target retention");
      eq(64'(registered_target_valid_q),64'(old_valid),"valid retention");
      eq_bank(state_out,old_state,"paused state retention");
      eq_bank(pending_route_out,old_pending,"paused route retention");
      if(!phase_load_valid && (phase_word_q!==old_phase || frequency_current_q16!==old_frequency))
        $fatal(1,"Paused phase/frequency retention");
    end
    changes=0; zeros=0; active=0; debt=0; conflicts=0;
    for(int c=0;c<CELLS;c++) begin
      old_value=dec(old_state[c*2+:2]); new_value=dec(state_out[c*2+:2]);
      saved_value=dec(old_pending[c*2+:2]); new_saved=dec(pending_route_out[c*2+:2]);
      if(old_value*new_value==-1) $fatal(1,"Direct polarity transition");
      if(new_value!=old_value) changes++;
      if(new_value==0) zeros++; else active++;
      if(new_value!=goal[c]) debt++;
      if(new_value*goal[c]==-1) conflicts++;
      if(new_saved!=0) eq(64'(state_out[c*2+:2]),0,"pending owns active zero");
      if(saved_value!=0) begin
        if(new_saved==0) begin
          eq(64'(state_out[c*2+:2]),64'(enc(saved_value)),"retained destination completes");
          if(measure) begin
            second_legs++; completed[case_mode][c][saved_value==1]++;
            mode_stats[case_mode].completed++;
          end
        end else begin
          eq(64'(enc(new_saved)),64'(enc(saved_value)),"saved destination retained");
          if(measure && !enabled) retained_pauses++;
          if(measure && enabled && (old_cadence==1 || old_cadence==4)) balance_holds++;
        end
      end
      if(old_value==0 && new_value!=0 && !(old_cadence==0 || old_cadence==2 || old_cadence==3))
        $fatal(1,"Zero released outside activation cadence");
      if(measure && saved_value==0 && new_saved!=0) begin
        if(old_value*new_saved!=-1 || new_value!=0) $fatal(1,"Malformed mediated route");
        first_legs++; routed[case_mode][c][new_saved==1]++;
        mode_stats[case_mode].routes++;
      end
      if(measure && old_value!=0 && new_value==0) begin
        if(old_cadence==1) balance_entries++;
        if(old_cadence==4) neutralize_entries++;
        if(goal[c]==0) neutral_goals++;
      end
    end
    eq(64'(changes),64'(advertised_changes),"observed changes");
    if(changes>LANES) $fatal(1,"Distributed transition capacity");
    if(measure && enabled) begin
      execution_ticks++; frp_changes+=changes;
      if(registered_target_q!=state_out) boundary_lags++;
      frp_heat+=40*changes+2*active-20*zeros-6*CELLS;
      if(frp_heat<0) frp_heat=0;
      if(frp_heat>frp_peak_heat) frp_peak_heat=frp_heat;
      if(changes>frp_peak_switch) frp_peak_switch=changes;
      margin=2000*CELLS-400*debt-1000*conflicts-frp_heat-2000*changes;
      if(margin<frp_min_margin) frp_min_margin=margin;
      if(local_mean_heat_q16>native_peak_heat) native_peak_heat=local_mean_heat_q16;
      if(stability_margin_q16<native_min_margin) native_min_margin=stability_margin_q16;
      if(local_stability_margin_q16<native_local_min_margin)
        native_local_min_margin=local_stability_margin_q16;
      mode_stats[case_mode].ticks++;
      mode_stats[case_mode].changes+=changes;
      if(frp_heat>mode_stats[case_mode].frp_heat_peak)
        mode_stats[case_mode].frp_heat_peak=frp_heat;
      if(changes>mode_stats[case_mode].frp_switch_peak)
        mode_stats[case_mode].frp_switch_peak=changes;
      if(margin<mode_stats[case_mode].frp_margin_min)
        mode_stats[case_mode].frp_margin_min=margin;
      if(local_mean_heat_q16>mode_stats[case_mode].local_heat_peak)
        mode_stats[case_mode].local_heat_peak=local_mean_heat_q16;
      if(temperature_proxy_q16>mode_stats[case_mode].proxy_peak)
        mode_stats[case_mode].proxy_peak=temperature_proxy_q16;
      if(stability_margin_q16<mode_stats[case_mode].margin_min)
        mode_stats[case_mode].margin_min=stability_margin_q16;
      if(local_stability_margin_q16<mode_stats[case_mode].local_margin_min)
        mode_stats[case_mode].local_margin_min=local_stability_margin_q16;
    end
    clk=0; #1; cycles++;
  endtask

  task automatic load_snapshot;
    for(int c=0;c<CELLS;c++) begin
      phase_load[c*32+:32]=phase[c]; frequency_load_q16[c*32+:32]=frequency[c];
    end
    phase_load_valid=1; clock_step(0); check_phase();
  endtask

  task automatic reset_and_seed(input int polarity);
    measure=0; auto_target_enable=0; tick_enable=0; phase_load_valid=0;
    clear_counters=0; scheduler_mode=FRP_MODE_FREE;
    rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1;
    mode_ref=0; position_ref=0;
    for(int c=0;c<CELLS;c++) begin
      phase[c]=polarity==1 ? 32'h40000000:32'hc0000000;
      frequency[c]=65536; reference_state[c]=polarity; goal[c]=polarity;
    end
    load_snapshot(); auto_target_enable=1;
    repeat(2*CELLS+4) clock_step(1);
    for(int c=0;c<CELLS;c++) eq(64'(state_out[c*2+:2]),64'(enc(polarity)),"common initial state");
    eq_bank(pending_route_out,'0,"initial route empty");
    auto_target_enable=0;
    scheduler_mode=frp_m31_scheduler_mode_e'(case_mode); clock_step(0);
  endtask

  function automatic bit finished;
    for(int c=0;c<CELLS;c++)
      if(state_out[c*2+:2]!==enc(goal[c]) || pending_route_out[c*2+:2]!=0) return 0;
    return 1;
  endfunction

  task automatic binary_commit;
    int toggles,opposites,active,heat,margin;
    toggles=0; opposites=0; active=0;
    for(int c=0;c<CELLS;c++) begin
      binary_state[c]=case_seed_state;
      toggles+=int'((binary_state[c]==-1)!=(goal[c]==-1));
      toggles+=int'((binary_state[c]==1)!=(goal[c]==1));
      if(binary_state[c]*goal[c]==-1) opposites++;
      binary_state[c]=goal[c];
      if(binary_state[c]!=0) active++;
    end
    // Historical two-rail binary rule, integer units of 1/(2000*CELLS).
    heat=20*toggles+60*opposites+2*active;
    margin=2000*CELLS-1000*opposites-heat-1000*toggles;
    binary_toggles+=toggles; binary_direct+=opposites;
    if(heat>binary_peak_heat) binary_peak_heat=heat;
    if(toggles>binary_peak_switch) binary_peak_switch=toggles;
    if(margin<binary_min_margin) binary_min_margin=margin;
    mode_stats[case_mode].binary_direct+=opposites;
    mode_stats[case_mode].binary_toggles+=toggles;
    if(heat>mode_stats[case_mode].binary_heat_peak)
      mode_stats[case_mode].binary_heat_peak=heat;
    if(toggles>mode_stats[case_mode].binary_switch_peak)
      mode_stats[case_mode].binary_switch_peak=toggles;
    if(margin<mode_stats[case_mode].binary_margin_min)
      mode_stats[case_mode].binary_margin_min=margin;
  endtask

  task automatic qualify_modes;
    int sum_cases, sum_relative, sum_routes, sum_completed;
    int sum_direct, sum_toggles, sum_changes, sum_ticks;
    int peak_binary_heat, peak_frp_heat, peak_binary_switch, peak_frp_switch;
    int min_binary_margin, min_frp_margin, peak_local_heat, min_margin, min_local_margin;
    sum_cases=0; sum_relative=0; sum_routes=0; sum_completed=0;
    sum_direct=0; sum_toggles=0; sum_changes=0; sum_ticks=0;
    peak_binary_heat=0; peak_frp_heat=0; peak_binary_switch=0; peak_frp_switch=0;
    min_binary_margin=2147483647; min_frp_margin=2147483647;
    peak_local_heat=0; min_margin=2147483647; min_local_margin=2147483647;
    foreach(task_hits[m,d,s,p])
      mode_require(task_hits[m][d][s][p]==1,"mode/direction/seed/pattern coverage");
    for(int m=0;m<3;m++) begin
      mode_require(mode_stats[m].cases==48,"48 tasks per mode");
      mode_require(mode_stats[m].routes>0 &&
                   mode_stats[m].routes==mode_stats[m].completed &&
                   mode_stats[m].routes==mode_stats[m].binary_direct,
                   "per-mode opposite-polarity tasks and completed routes");
      mode_require(mode_stats[m].relative_decisions>0,"per-mode relative-phase selection");
      mode_require(mode_stats[m].ticks>0 && mode_stats[m].changes>0,"per-mode execution");
      mode_require(mode_stats[m].max_task_ticks>0 &&
                   mode_stats[m].max_task_ticks<=16*CELLS+32,"per-mode completion bound");
      mode_require(mode_stats[m].frp_switch_peak<=LANES &&
                   mode_stats[m].binary_switch_peak<=2*CELLS,"per-mode switching bounds");
      for(int t=0;t<3;t++) mode_require(mode_targets[m][t]>0,"per-mode ternary selection");
      sum_cases+=mode_stats[m].cases; sum_relative+=mode_stats[m].relative_decisions;
      sum_routes+=mode_stats[m].routes; sum_completed+=mode_stats[m].completed;
      sum_direct+=mode_stats[m].binary_direct; sum_toggles+=mode_stats[m].binary_toggles;
      sum_changes+=mode_stats[m].changes; sum_ticks+=mode_stats[m].ticks;
      if(mode_stats[m].binary_heat_peak>peak_binary_heat) peak_binary_heat=mode_stats[m].binary_heat_peak;
      if(mode_stats[m].frp_heat_peak>peak_frp_heat) peak_frp_heat=mode_stats[m].frp_heat_peak;
      if(mode_stats[m].binary_switch_peak>peak_binary_switch) peak_binary_switch=mode_stats[m].binary_switch_peak;
      if(mode_stats[m].frp_switch_peak>peak_frp_switch) peak_frp_switch=mode_stats[m].frp_switch_peak;
      if(mode_stats[m].binary_margin_min<min_binary_margin) min_binary_margin=mode_stats[m].binary_margin_min;
      if(mode_stats[m].frp_margin_min<min_frp_margin) min_frp_margin=mode_stats[m].frp_margin_min;
      if(mode_stats[m].local_heat_peak>peak_local_heat) peak_local_heat=mode_stats[m].local_heat_peak;
      if(mode_stats[m].margin_min<min_margin) min_margin=mode_stats[m].margin_min;
      if(mode_stats[m].local_margin_min<min_local_margin) min_local_margin=mode_stats[m].local_margin_min;
    end
    mode_require(sum_cases==cases && sum_relative==relative_decisions,"task totals");
    mode_require(sum_routes==first_legs && sum_completed==second_legs,"route totals");
    mode_require(sum_direct==binary_direct && sum_toggles==binary_toggles,"binary totals");
    mode_require(sum_changes==frp_changes && sum_ticks==execution_ticks,"execution totals");
    mode_require(peak_binary_heat==binary_peak_heat && peak_frp_heat==frp_peak_heat,"heat maxima");
    mode_require(peak_binary_switch==binary_peak_switch && peak_frp_switch==frp_peak_switch,"switch maxima");
    mode_require(min_binary_margin==binary_min_margin && min_frp_margin==frp_min_margin,"execution margin minima");
    mode_require(peak_local_heat==native_peak_heat && min_margin==native_min_margin &&
                 min_local_margin==native_local_min_margin,"native telemetry extrema");
    mode_require(bank_words_checked>0 && bank_words_checked%BANK_WORDS==0,"complete bank checks");
  endtask

  task automatic report_modes;
    for(int m=0;m<3;m++) begin
      $display("MODE_TASK N=%0d mode=%0d cases=%0d relative_decisions=%0d routes=%0d completed=%0d negative=%0d zero=%0d positive=%0d max_execution_ticks=%0d",
        CELLS,m,mode_stats[m].cases,mode_stats[m].relative_decisions,
        mode_stats[m].routes,mode_stats[m].completed,mode_targets[m][0],
        mode_targets[m][1],mode_targets[m][2],mode_stats[m].max_task_ticks);
      $display("MODE_BINARY N=%0d mode=%0d match=1 direct=%0d rail_toggles=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
        CELLS,m,mode_stats[m].binary_direct,mode_stats[m].binary_toggles,
        real'(mode_stats[m].binary_heat_peak)/(2000*CELLS),
        real'(mode_stats[m].binary_switch_peak)/(2*CELLS),
        real'(mode_stats[m].binary_margin_min)/(2000*CELLS));
      $display("MODE_M32 N=%0d mode=%0d match=1 direct=0 logical_changes=%0d ticks=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
        CELLS,m,mode_stats[m].changes,mode_stats[m].ticks,
        real'(mode_stats[m].frp_heat_peak)/(2000*CELLS),
        real'(mode_stats[m].frp_switch_peak)/CELLS,
        real'(mode_stats[m].frp_margin_min)/(2000*CELLS));
      $display("MODE_NATIVE N=%0d mode=%0d execution_window_mean_heat_peak_q16=%0d execution_window_proxy_peak_q16=%0d margin_min_q16=%0d local_margin_min_q16=%0d",
        CELLS,m,mode_stats[m].local_heat_peak,mode_stats[m].proxy_peak,
        mode_stats[m].margin_min,mode_stats[m].local_margin_min);
    end
    $display("MODE_COVERAGE N=%0d checks=%0d task_bins=144 route_bins=%0d bank_words_checked=%0d bank_bits=%0d",
      CELLS,mode_checks,3*CELLS*2,bank_words_checked,2*CELLS);
  endtask

  initial begin : run
    real scaled;
    int iterations,elapsed;
    bit paused;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    for(int m=0;m<3;m++) begin
      mode_stats[m]='{default:0};
      mode_stats[m].binary_margin_min=2147483647;
      mode_stats[m].frp_margin_min=2147483647;
      mode_stats[m].margin_min=2147483647;
      mode_stats[m].local_margin_min=2147483647;
    end
    for(int a=0;a<4096;a++) begin
      scaled=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*1073741824.0;
      sine_table[a]=$rtoi(scaled<0 ? scaled-0.5:scaled+0.5);
    end
    for(int mode=0;mode<3;mode++) for(int direction=0;direction<2;direction++)
      for(int seed=0;seed<4;seed++) for(int pattern=0;pattern<6;pattern++) begin
        case_mode=mode; case_seed_state=direction==0 ? -1:1; cases++;
        mode_stats[mode].cases++; task_hits[mode][direction][seed][pattern]++;
        rng=32'h64a031f7 ^ 32'(seed*1000003+pattern*101+CELLS);
        reset_and_seed(case_seed_state);
        for(int c=0;c<CELLS;c++) begin
          case(pattern)
            0:phase[c]=direction==0 ? 32'h40000000:32'hc0000000;
            1:phase[c]=0;
            2:phase[c]=32'd219<<20;
            3:phase[c]=c%2==0 ? 0:32'h80000000;
            4:phase[c]=random_word();
            5:phase[c]=32'(c%4)<<30;
          endcase
          frequency[c]=word_t'(65536+seed*1024+c*17);
          gamma_effective_word[c*32+:32]=seed%2==0 ? 32'd644245094:32'd3650722202;
          thermal_node_factor_q30[c*32+:32]=seed<2 ? 32'h40000000:32'h20000000;
        end
        load_snapshot(); phase_load_valid=0;
        iterations=pattern<3 ? 1:16;
        repeat(iterations) begin
          check_phase(); predict_phase(); clock_step(1); check_phase();
          for(int c=0;c<CELLS;c++)
            eq(64'(state_out[c*2+:2]),64'(enc(reference_state[c])),"compute state retained");
        end
        for(int c=0;c<CELLS;c++) begin
          goal[c]=selection(phase[c]); target_bins[goal[c]+1]++;
          mode_targets[mode][goal[c]+1]++;
          if(goal[c]!=selection(uncoupled[c])) begin
            relative_decisions++; mode_stats[mode].relative_decisions++;
          end
        end
        binary_commit(); load_snapshot();
        // Snapshot loads preserve the computed task while its routes complete.
        auto_target_enable=0; clock_step(1);
        auto_target_enable=1; measure=1; frp_heat=0; elapsed=0; paused=0;
        while(!finished() && elapsed<16*CELLS+32) begin
          clock_step(1); elapsed++;
          if(!paused && pending_route_out!=0) begin
            // Change incoming phase targets while retained routes are paused.
            for(int c=0;c<CELLS;c++) phase_load[c*32+:32]=phase[c]+32'h80000000;
            repeat(3) begin clear_counters=!clear_counters; clock_step(0); end
            clear_counters=0;
            for(int c=0;c<CELLS;c++) phase_load[c*32+:32]=phase[c];
            clock_step(0); paused=1;
          end
        end
        if(!finished()) $fatal(1,"Sampled phase task did not complete");
        if(elapsed>mode_stats[mode].max_task_ticks) mode_stats[mode].max_task_ticks=elapsed;
        for(int c=0;c<CELLS;c++) begin
          eq(64'(state_out[c*2+:2]),64'(enc(binary_state[c])),"architecture task match");
          reference_state[c]=goal[c];
        end
        measure=0; auto_target_enable=0; phase_load_valid=0;
        // Frequency and phase continue evolving while retained zeros persist.
        repeat(8) begin predict_phase(); clock_step(1); check_phase(); end
      end
    eq(64'(cases),144,"task matrix");
    eq(64'(first_legs),64'(second_legs),"all mediated routes complete");
    eq(64'(first_legs),64'(binary_direct),"opposite-polarity task count");
    for(int m=0;m<3;m++) for(int c=0;c<CELLS;c++) for(int d=0;d<2;d++)
      if(routed[m][c][d]==0 || routed[m][c][d]!=completed[m][c][d])
        $fatal(1,"Missing indexed route mode=%0d cell=%0d direction=%0d",m,c,d);
    foreach(target_bins[k]) if(target_bins[k]==0) $fatal(1,"Missing selected symbol");
    if(relative_decisions==0 || retained_pauses==0 || balance_holds==0 || balance_entries==0
       || neutralize_entries==0 || neutral_goals==0 || zero_memory_updates==0
       || zero_phase_updates==0 || boundary_lags==0) $fatal(1,"Incomplete active-zero coverage");

    qualify_modes();
    $display("PASS PHASE_TASK N=%0d cases=%0d checks=%0d phase_updates=%0d relative_decisions=%0d signature=%016h",
      CELLS,cases,checks,phase_updates,relative_decisions,signature);
    $display("ACTIVE_ZERO N=%0d routes=%0d completed=%0d paused_retention=%0d balance_retention=%0d balance_entries=%0d neutralize_entries=%0d zero_goals=%0d frequency_memory=%0d phase_evolution=%0d boundary_lag=%0d",
      CELLS,first_legs,second_legs,retained_pauses,balance_holds,balance_entries,
      neutralize_entries,neutral_goals,zero_memory_updates,zero_phase_updates,boundary_lags);
    $display("BINARY_REFERENCE N=%0d match=1 direct=%0d rail_toggles=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
      CELLS,binary_direct,binary_toggles,real'(binary_peak_heat)/(2000*CELLS),
      real'(binary_peak_switch)/(2*CELLS),real'(binary_min_margin)/(2000*CELLS));
    $display("M32_EXECUTION N=%0d match=1 direct=0 logical_changes=%0d ticks=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
      CELLS,frp_changes,execution_ticks,real'(frp_peak_heat)/(2000*CELLS),
      real'(frp_peak_switch)/CELLS,real'(frp_min_margin)/(2000*CELLS));
    $display("M32_NATIVE N=%0d execution_window_mean_heat_peak_q16=%0d margin_min_q16=%0d local_margin_min_q16=%0d",
      CELLS,native_peak_heat,native_min_margin,native_local_min_margin);
    report_modes();
    $finish;
  end

  initial begin #10000000; $fatal(1,"Phase task watchdog expired"); end
endmodule// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Common sampled phase-selection task: binary arithmetic reference and M32.
// Inputs: initial phases, retained polarity/frequency, gamma, attenuation, mode.
// Both paths evolve the same phase recurrence and must select the same symbols.
// The binary reference evaluates signed fixed-point sums and directly commits
// two-rail symbols. M32 uses its phase engine, registered boundary and routes.
// After the compute window, phase loads retain the sampled phase/frequency
// snapshot while execution completes. A second window exercises zero memory.
// Historical v0.9.3 execution heat rules are reported separately from native
// M32 thermal/stability telemetry. Reference arithmetic is evaluated behaviorally.
// Compile from repository root: --binary --timing --assert -Irtl/m31 -Irtl/m32
// --top-module frp_m32_phase_task_architecture_tb -GCELLS=8 (or 16,32,64).
// Per-mode records retain separate execution-heat and native telemetry units.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_phase_task_architecture_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  localparam int LANES=CELLS/4, INDEX_BITS=$clog2(CELLS);
  localparam int BANK_WORDS=(2*CELLS+63)/64;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_load_valid=0, auto_target_enable=0;
  logic local_gamma_enable=0, gamma_update_valid=0, local_thermal_enable=0;
  logic [CELLS*32-1:0] phase_load=0, frequency_load_q16=0;
  logic [CELLS*32-1:0] gamma_effective_word=0, gamma_targets_q16=0;
  logic [CELLS*32-1:0] thermal_node_factor_q30={CELLS{32'h40000000}};
  logic [LANES-1:0] external_request_valid=0;
  logic [LANES*INDEX_BITS-1:0] external_request_cell_index=0;
  logic [LANES*2-1:0] external_request_target=0;
  logic [CELLS*2-1:0] external_target_bank=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  wire [CELLS*32-1:0] phase_word_q, frequency_current_q16;
  wire [CELLS*32-1:0] coupling_field_q16, phase_projection_q30;
  wire [CELLS*2-1:0] phase_target_source, registered_target_q;
  wire [CELLS*2-1:0] state_out, pending_route_out;
  wire registered_target_valid_q;
  wire [31:0] accepted_changes, switch_load_numerator, actual_direct_events;
  wire [9:0] invariant_flags;
  wire signed [31:0] local_mean_heat_q16, stability_margin_q16;
  wire signed [31:0] local_stability_margin_q16, temperature_proxy_q16;

  frp_m32_core #(.CELLS(CELLS)) dut (
    .clk, .rst_n, .tick_enable,
    .clear_counters, .scheduler_mode, .phase_load_valid,
    .phase_load, .frequency_load_q16, .gamma_effective_word,
    .thermal_node_factor_q30, .auto_target_enable, .external_request_valid,
    .external_request_cell_index, .external_request_target, .external_target_bank,
    .local_gamma_enable, .gamma_update_valid, .gamma_targets_q16,
    .local_thermal_enable, .phase_word_q, .frequency_current_q16,
    .coupling_field_q16, .phase_projection_q30, .phase_target_source,
    .registered_target_q, .registered_target_valid_q, .state_out,
    .pending_route_out, .scheduler_mode_q, .scheduler_state_q,
    .accepted_changes, .switch_load_numerator, .actual_direct_events,
    .invariant_flags, .local_mean_heat_q16, .stability_margin_q16,
    .local_stability_margin_q16, .phase_target_domain_valid(), .registered_target_domain_valid(),
    .target_capture_accepted(), .target_capture_rejected(), .accepted_target_capture_events_q(),
    .rejected_target_capture_events_q(), .registered_request_enable(), .phase_request_valid(),
    .phase_request_cell_index(), .phase_request_target(), .execution_request_valid(),
    .execution_request_cell_index(), .execution_request_target(), .execution_target_bank(),
    .ticks_recorded_q(), .scheduler_count_free_q(), .scheduler_count_balance_q(),
    .scheduler_count_commit_q(), .scheduler_count_excite_q(), .scheduler_count_neutralize_q(),
    .request_accept(), .request_reject(), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(), .capacity_remaining(),
    .capacity_exhausted(), .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .reserved_state_events(), .queue_overflow_events(),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30(), .normalized_cycle_cost_q16(), .temperature_proxy_q16,
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stable(), .local_heat_q16(),
    .local_heat_peak_q16(), .local_generated_power_q16(), .local_thermal_dissipation_q16(),
    .local_thermal_diffusion_q16(), .local_thermal_overload_q16(), .local_next_heat_q16(),
    .local_next_overload_q16(), .local_frequency_lag_q16(), .local_mean_heat_peak_q16(),
    .local_maximum_heat_peak_q16(), .local_gamma_noise_target_q16(), .local_gamma_noise_state_q16(),
    .local_gamma_drift_word(), .local_gamma_effective_word(), .local_next_gamma_drift_word(),
    .local_next_gamma_effective_word(), .phase_gamma_effective_word(), .local_thermal_node_factor_q30(),
    .local_next_thermal_node_factor_q30(), .phase_thermal_node_factor_q30(), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(), .level_max_coherence_q30(),
    .level_dispersion_q30(), .local_coherence_compression_q30(), .local_effective_coherence_q30(),
    .local_coherence_capacity_q16(), .local_pressure_q16(), .local_stable(),
    .local_previous_margin_q16(), .local_stability_valid_q(), .local_stability_sample_count_q(),
    .local_stability_raw_coherence_q30(), .local_stability_cluster_coherence_q30(), .local_stability_mean_heat_q16(),
    .local_stability_mean_overload_q16(), .local_stability_mean_lag_q16(), .local_stability_neutral_fraction_q30(),
    .local_stability_compression_arg_q16(), .local_stability_switch_load_q16()
  );

  word_t sine_table[4096], frequency[CELLS], fields[CELLS];
  logic [31:0] phase[CELLS], uncoupled[CELLS];
  int reference_state[CELLS], goal[CELLS], binary_state[CELLS];
  int mode_ref=0, position_ref=0, cases=0, checks=0, cycles=0;
  int phase_updates=0, relative_decisions=0, target_bins[3];
  int first_legs=0, second_legs=0, retained_pauses=0, balance_holds=0;
  int balance_entries=0, neutralize_entries=0, neutral_goals=0;
  int zero_memory_updates=0, zero_phase_updates=0, boundary_lags=0;
  int binary_direct=0, binary_toggles=0, frp_changes=0;
  int binary_peak_heat=0, frp_peak_heat=0, frp_heat=0;
  int binary_peak_switch=0, frp_peak_switch=0, execution_ticks=0;
  int binary_min_margin=2147483647, frp_min_margin=2147483647;
  int native_peak_heat=0, native_min_margin=2147483647;
  int native_local_min_margin=2147483647;
  int routed[3][CELLS][2], completed[3][CELLS][2];
  typedef struct {
    int cases, relative_decisions, routes, completed;
    int binary_direct, binary_toggles, changes, ticks, max_task_ticks;
    int binary_heat_peak, frp_heat_peak, binary_switch_peak, frp_switch_peak;
    int binary_margin_min, frp_margin_min;
    int local_heat_peak, proxy_peak, margin_min, local_margin_min;
  } mode_stats_t;
  mode_stats_t mode_stats[3];
  int task_hits[3][2][4][6], mode_targets[3][3];
  int mode_checks=0, bank_words_checked=0;
  int case_mode=0, case_seed_state=0;
  bit measure=0;
  int unsigned rng=32'h64a031f7;
  logic [63:0] signature=64'hcbf29ce484222325;

  function automatic logic [31:0] random_word;
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng;
  endfunction

  function automatic logic [1:0] enc(input int value);
    case(value)
      -1:return 2'b11; 0:return 2'b00; 1:return 2'b01;
      default:begin $fatal(1,"Invalid reference symbol"); return 2'b10; end
    endcase
  endfunction

  function automatic int dec(input logic [1:0] value);
    case(value)
      2'b11:return -1; 2'b00:return 0; 2'b01:return 1;
      default:begin $fatal(1,"Reserved retained symbol"); return 2; end
    endcase
  endfunction

  function automatic int selection(input logic [31:0] angle);
    word_t v;
    v=sine_table[angle[31:20]];
    return v>354334802 ? 1 : (v< -354334802 ? -1 : 0);
  endfunction

  function automatic int cadence;
    case(mode_ref)
      0:return 0;
      1:return position_ref==7 ? 2:1;
      2:return position_ref==0 ? 3:4;
      default:begin $fatal(1,"Invalid mode"); return 7; end
    endcase
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
      64: case(level)
        0:return 350050538; 1:return 107740697; 2:return 40558875;
        3:return 16580545; 4:return 7091397; default:return 3120865;
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
    logic [31:0] angle;
    sum=0;
    for(int j=0;j<CELLS;j++) if(j!=receiver) begin
      angle=phase[j]-phase[receiver]-gamma_effective_word[receiver*32+:32];
      factor=product(word_t'(thermal_node_factor_q30[receiver*32+:32]),
                     word_t'(thermal_node_factor_q30[j*32+:32]),30);
      term=product(product(weight(receiver,j),factor,30),sine_table[angle[31:20]],30);
      sum+=longint'(term);
    end
    return product(18350,clipped(rounded(longint'(clipped(sum)),16384)),16);
  endfunction

  function automatic logic [31:0] phase_step(input word_t velocity);
    longint signed magnitude, delta;
    magnitude=longint'(velocity);
    if(magnitude<0) magnitude=-magnitude;
    delta=magnitude*10430+rounded(magnitude*64'sd1625002897,64'sd4294967296);
    return 32'(velocity<0 ? -delta:delta);
  endfunction

  task automatic eq(input logic [63:0] got,wanted,input string label_text);
    checks++;
    if(got!==wanted)
      $fatal(1,"PHASE_TASK N=%0d case=%0d cycle=%0d %s got=%h expected=%h",
             CELLS,cases,cycles,label_text,got,wanted);
    signature=(signature^wanted)*64'h100000001b3;
  endtask

  task automatic eq_bank(
    input logic [CELLS*2-1:0] got, wanted,
    input string label_text
  );
    logic [BANK_WORDS*64-1:0] padded_got, padded_wanted;
    padded_got='0; padded_wanted='0;
    padded_got[CELLS*2-1:0]=got;
    padded_wanted[CELLS*2-1:0]=wanted;
    // Low-word check order preserves the 8/16/32-cell regression signatures.
    for(int w=0;w<BANK_WORDS;w++) begin
      eq(padded_got[w*64+:64],padded_wanted[w*64+:64],
         $sformatf("%s word=%0d",label_text,w));
      bank_words_checked++;
    end
  endtask

  task automatic mode_require(input bit condition, input string label_text);
    mode_checks++;
    if(!condition) $fatal(1,"Mode qualification N=%0d %s",CELLS,label_text);
  endtask

  task automatic check_phase;
    for(int c=0;c<CELLS;c++) begin
      eq(64'(phase_word_q[c*32+:32]),64'(phase[c]),"computed phase");
      eq(64'(frequency_current_q16[c*32+:32]),64'($unsigned(frequency[c])),"retained frequency");
      eq(64'(coupling_field_q16[c*32+:32]),64'($unsigned(field_for(c))),"relative field");
      eq(64'(phase_projection_q30[c*32+:32]),64'($unsigned(sine_table[phase[c][31:20]])),"projection");
      eq(64'(phase_target_source[c*2+:2]),64'(enc(selection(phase[c]))),"resonant selection");
    end
  endtask

  task automatic predict_phase;
    word_t target, correction, velocity, isolated_velocity, old_frequency;
    logic [31:0] old_phase;
    int push;
    for(int c=0;c<CELLS;c++) fields[c]=field_for(c);
    push=cadence()==2 ? 655:(cadence()==3 ? 393:197);
    for(int c=0;c<CELLS;c++) begin
      old_frequency=frequency[c]; old_phase=phase[c];
      target=65536+(reference_state[c]!=0 ? 3932:0);
      correction=clipped(rounded((longint'(target)-longint'(frequency[c]))*19661,65536));
      frequency[c]=clipped(longint'(frequency[c])+longint'(correction));
      isolated_velocity=word_t'(longint'(product(frequency[c],3932,16))+push);
      velocity=word_t'(longint'(isolated_velocity)+longint'(fields[c]));
      uncoupled[c]=phase[c]+phase_step(isolated_velocity);
      phase[c]+=phase_step(velocity);
      if(reference_state[c]==0) begin
        if(frequency[c]!=old_frequency && frequency[c]!=0) zero_memory_updates++;
        if(phase[c]!=old_phase) zero_phase_updates++;
      end
    end
    phase_updates++;
  endtask

  task automatic clock_step(input bit enabled);
    logic [CELLS*2-1:0] old_state,old_pending,old_target,captured;
    logic [CELLS*32-1:0] old_phase,old_frequency;
    int old_cadence, changes, zeros, active, debt, conflicts, margin;
    int old_value,new_value,saved_value,new_saved, advertised_changes;
    bit old_valid;
    clk=0; tick_enable=enabled; #1;
    old_state=state_out; old_pending=pending_route_out;
    old_phase=phase_word_q; old_frequency=frequency_current_q16;
    old_target=registered_target_q; old_valid=registered_target_valid_q;
    captured=phase_target_source; old_cadence=cadence();
    advertised_changes=int'(accepted_changes);
    eq(64'(scheduler_mode_q),64'(mode_ref),"scheduler mode");
    eq(64'(scheduler_state_q),64'(old_cadence),"scheduler cadence");
    eq(64'(actual_direct_events),0,"direct event signal");
    eq(64'(invariant_flags),1023,"execution invariants");
    if(enabled) position_ref=(position_ref+1)%8;
    mode_ref=int'(scheduler_mode);
    clk=1; #1;
    if(enabled) begin
      eq_bank(registered_target_q,captured,"pre-edge phase capture");
      eq(64'(registered_target_valid_q),1,"capture valid");
    end else begin
      eq_bank(registered_target_q,old_target,"target retention");
      eq(64'(registered_target_valid_q),64'(old_valid),"valid retention");
      eq_bank(state_out,old_state,"paused state retention");
      eq_bank(pending_route_out,old_pending,"paused route retention");
      if(!phase_load_valid && (phase_word_q!==old_phase || frequency_current_q16!==old_frequency))
        $fatal(1,"Paused phase/frequency retention");
    end
    changes=0; zeros=0; active=0; debt=0; conflicts=0;
    for(int c=0;c<CELLS;c++) begin
      old_value=dec(old_state[c*2+:2]); new_value=dec(state_out[c*2+:2]);
      saved_value=dec(old_pending[c*2+:2]); new_saved=dec(pending_route_out[c*2+:2]);
      if(old_value*new_value==-1) $fatal(1,"Direct polarity transition");
      if(new_value!=old_value) changes++;
      if(new_value==0) zeros++; else active++;
      if(new_value!=goal[c]) debt++;
      if(new_value*goal[c]==-1) conflicts++;
      if(new_saved!=0) eq(64'(state_out[c*2+:2]),0,"pending owns active zero");
      if(saved_value!=0) begin
        if(new_saved==0) begin
          eq(64'(state_out[c*2+:2]),64'(enc(saved_value)),"retained destination completes");
          if(measure) begin
            second_legs++; completed[case_mode][c][saved_value==1]++;
            mode_stats[case_mode].completed++;
          end
        end else begin
          eq(64'(enc(new_saved)),64'(enc(saved_value)),"saved destination retained");
          if(measure && !enabled) retained_pauses++;
          if(measure && enabled && (old_cadence==1 || old_cadence==4)) balance_holds++;
        end
      end
      if(old_value==0 && new_value!=0 && !(old_cadence==0 || old_cadence==2 || old_cadence==3))
        $fatal(1,"Zero released outside activation cadence");
      if(measure && saved_value==0 && new_saved!=0) begin
        if(old_value*new_saved!=-1 || new_value!=0) $fatal(1,"Malformed mediated route");
        first_legs++; routed[case_mode][c][new_saved==1]++;
        mode_stats[case_mode].routes++;
      end
      if(measure && old_value!=0 && new_value==0) begin
        if(old_cadence==1) balance_entries++;
        if(old_cadence==4) neutralize_entries++;
        if(goal[c]==0) neutral_goals++;
      end
    end
    eq(64'(changes),64'(advertised_changes),"observed changes");
    if(changes>LANES) $fatal(1,"Distributed transition capacity");
    if(measure && enabled) begin
      execution_ticks++; frp_changes+=changes;
      if(registered_target_q!=state_out) boundary_lags++;
      frp_heat+=40*changes+2*active-20*zeros-6*CELLS;
      if(frp_heat<0) frp_heat=0;
      if(frp_heat>frp_peak_heat) frp_peak_heat=frp_heat;
      if(changes>frp_peak_switch) frp_peak_switch=changes;
      margin=2000*CELLS-400*debt-1000*conflicts-frp_heat-2000*changes;
      if(margin<frp_min_margin) frp_min_margin=margin;
      if(local_mean_heat_q16>native_peak_heat) native_peak_heat=local_mean_heat_q16;
      if(stability_margin_q16<native_min_margin) native_min_margin=stability_margin_q16;
      if(local_stability_margin_q16<native_local_min_margin)
        native_local_min_margin=local_stability_margin_q16;
      mode_stats[case_mode].ticks++;
      mode_stats[case_mode].changes+=changes;
      if(frp_heat>mode_stats[case_mode].frp_heat_peak)
        mode_stats[case_mode].frp_heat_peak=frp_heat;
      if(changes>mode_stats[case_mode].frp_switch_peak)
        mode_stats[case_mode].frp_switch_peak=changes;
      if(margin<mode_stats[case_mode].frp_margin_min)
        mode_stats[case_mode].frp_margin_min=margin;
      if(local_mean_heat_q16>mode_stats[case_mode].local_heat_peak)
        mode_stats[case_mode].local_heat_peak=local_mean_heat_q16;
      if(temperature_proxy_q16>mode_stats[case_mode].proxy_peak)
        mode_stats[case_mode].proxy_peak=temperature_proxy_q16;
      if(stability_margin_q16<mode_stats[case_mode].margin_min)
        mode_stats[case_mode].margin_min=stability_margin_q16;
      if(local_stability_margin_q16<mode_stats[case_mode].local_margin_min)
        mode_stats[case_mode].local_margin_min=local_stability_margin_q16;
    end
    clk=0; #1; cycles++;
  endtask

  task automatic load_snapshot;
    for(int c=0;c<CELLS;c++) begin
      phase_load[c*32+:32]=phase[c]; frequency_load_q16[c*32+:32]=frequency[c];
    end
    phase_load_valid=1; clock_step(0); check_phase();
  endtask

  task automatic reset_and_seed(input int polarity);
    measure=0; auto_target_enable=0; tick_enable=0; phase_load_valid=0;
    clear_counters=0; scheduler_mode=FRP_MODE_FREE;
    rst_n=0; #1; clk=1; #1; clk=0; #1; rst_n=1;
    mode_ref=0; position_ref=0;
    for(int c=0;c<CELLS;c++) begin
      phase[c]=polarity==1 ? 32'h40000000:32'hc0000000;
      frequency[c]=65536; reference_state[c]=polarity; goal[c]=polarity;
    end
    load_snapshot(); auto_target_enable=1;
    repeat(2*CELLS+4) clock_step(1);
    for(int c=0;c<CELLS;c++) eq(64'(state_out[c*2+:2]),64'(enc(polarity)),"common initial state");
    eq_bank(pending_route_out,'0,"initial route empty");
    auto_target_enable=0;
    scheduler_mode=frp_m31_scheduler_mode_e'(case_mode); clock_step(0);
  endtask

  function automatic bit finished;
    for(int c=0;c<CELLS;c++)
      if(state_out[c*2+:2]!==enc(goal[c]) || pending_route_out[c*2+:2]!=0) return 0;
    return 1;
  endfunction

  task automatic binary_commit;
    int toggles,opposites,active,heat,margin;
    toggles=0; opposites=0; active=0;
    for(int c=0;c<CELLS;c++) begin
      binary_state[c]=case_seed_state;
      toggles+=int'((binary_state[c]==-1)!=(goal[c]==-1));
      toggles+=int'((binary_state[c]==1)!=(goal[c]==1));
      if(binary_state[c]*goal[c]==-1) opposites++;
      binary_state[c]=goal[c];
      if(binary_state[c]!=0) active++;
    end
    // Historical two-rail binary rule, integer units of 1/(2000*CELLS).
    heat=20*toggles+60*opposites+2*active;
    margin=2000*CELLS-1000*opposites-heat-1000*toggles;
    binary_toggles+=toggles; binary_direct+=opposites;
    if(heat>binary_peak_heat) binary_peak_heat=heat;
    if(toggles>binary_peak_switch) binary_peak_switch=toggles;
    if(margin<binary_min_margin) binary_min_margin=margin;
    mode_stats[case_mode].binary_direct+=opposites;
    mode_stats[case_mode].binary_toggles+=toggles;
    if(heat>mode_stats[case_mode].binary_heat_peak)
      mode_stats[case_mode].binary_heat_peak=heat;
    if(toggles>mode_stats[case_mode].binary_switch_peak)
      mode_stats[case_mode].binary_switch_peak=toggles;
    if(margin<mode_stats[case_mode].binary_margin_min)
      mode_stats[case_mode].binary_margin_min=margin;
  endtask

  task automatic qualify_modes;
    int sum_cases, sum_relative, sum_routes, sum_completed;
    int sum_direct, sum_toggles, sum_changes, sum_ticks;
    int peak_binary_heat, peak_frp_heat, peak_binary_switch, peak_frp_switch;
    int min_binary_margin, min_frp_margin, peak_local_heat, min_margin, min_local_margin;
    sum_cases=0; sum_relative=0; sum_routes=0; sum_completed=0;
    sum_direct=0; sum_toggles=0; sum_changes=0; sum_ticks=0;
    peak_binary_heat=0; peak_frp_heat=0; peak_binary_switch=0; peak_frp_switch=0;
    min_binary_margin=2147483647; min_frp_margin=2147483647;
    peak_local_heat=0; min_margin=2147483647; min_local_margin=2147483647;
    foreach(task_hits[m,d,s,p])
      mode_require(task_hits[m][d][s][p]==1,"mode/direction/seed/pattern coverage");
    for(int m=0;m<3;m++) begin
      mode_require(mode_stats[m].cases==48,"48 tasks per mode");
      mode_require(mode_stats[m].routes>0 &&
                   mode_stats[m].routes==mode_stats[m].completed &&
                   mode_stats[m].routes==mode_stats[m].binary_direct,
                   "per-mode opposite-polarity tasks and completed routes");
      mode_require(mode_stats[m].relative_decisions>0,"per-mode relative-phase selection");
      mode_require(mode_stats[m].ticks>0 && mode_stats[m].changes>0,"per-mode execution");
      mode_require(mode_stats[m].max_task_ticks>0 &&
                   mode_stats[m].max_task_ticks<=16*CELLS+32,"per-mode completion bound");
      mode_require(mode_stats[m].frp_switch_peak<=LANES &&
                   mode_stats[m].binary_switch_peak<=2*CELLS,"per-mode switching bounds");
      for(int t=0;t<3;t++) mode_require(mode_targets[m][t]>0,"per-mode ternary selection");
      sum_cases+=mode_stats[m].cases; sum_relative+=mode_stats[m].relative_decisions;
      sum_routes+=mode_stats[m].routes; sum_completed+=mode_stats[m].completed;
      sum_direct+=mode_stats[m].binary_direct; sum_toggles+=mode_stats[m].binary_toggles;
      sum_changes+=mode_stats[m].changes; sum_ticks+=mode_stats[m].ticks;
      if(mode_stats[m].binary_heat_peak>peak_binary_heat) peak_binary_heat=mode_stats[m].binary_heat_peak;
      if(mode_stats[m].frp_heat_peak>peak_frp_heat) peak_frp_heat=mode_stats[m].frp_heat_peak;
      if(mode_stats[m].binary_switch_peak>peak_binary_switch) peak_binary_switch=mode_stats[m].binary_switch_peak;
      if(mode_stats[m].frp_switch_peak>peak_frp_switch) peak_frp_switch=mode_stats[m].frp_switch_peak;
      if(mode_stats[m].binary_margin_min<min_binary_margin) min_binary_margin=mode_stats[m].binary_margin_min;
      if(mode_stats[m].frp_margin_min<min_frp_margin) min_frp_margin=mode_stats[m].frp_margin_min;
      if(mode_stats[m].local_heat_peak>peak_local_heat) peak_local_heat=mode_stats[m].local_heat_peak;
      if(mode_stats[m].margin_min<min_margin) min_margin=mode_stats[m].margin_min;
      if(mode_stats[m].local_margin_min<min_local_margin) min_local_margin=mode_stats[m].local_margin_min;
    end
    mode_require(sum_cases==cases && sum_relative==relative_decisions,"task totals");
    mode_require(sum_routes==first_legs && sum_completed==second_legs,"route totals");
    mode_require(sum_direct==binary_direct && sum_toggles==binary_toggles,"binary totals");
    mode_require(sum_changes==frp_changes && sum_ticks==execution_ticks,"execution totals");
    mode_require(peak_binary_heat==binary_peak_heat && peak_frp_heat==frp_peak_heat,"heat maxima");
    mode_require(peak_binary_switch==binary_peak_switch && peak_frp_switch==frp_peak_switch,"switch maxima");
    mode_require(min_binary_margin==binary_min_margin && min_frp_margin==frp_min_margin,"execution margin minima");
    mode_require(peak_local_heat==native_peak_heat && min_margin==native_min_margin &&
                 min_local_margin==native_local_min_margin,"native telemetry extrema");
    mode_require(bank_words_checked>0 && bank_words_checked%BANK_WORDS==0,"complete bank checks");
  endtask

  task automatic report_modes;
    for(int m=0;m<3;m++) begin
      $display("MODE_TASK N=%0d mode=%0d cases=%0d relative_decisions=%0d routes=%0d completed=%0d negative=%0d zero=%0d positive=%0d max_execution_ticks=%0d",
        CELLS,m,mode_stats[m].cases,mode_stats[m].relative_decisions,
        mode_stats[m].routes,mode_stats[m].completed,mode_targets[m][0],
        mode_targets[m][1],mode_targets[m][2],mode_stats[m].max_task_ticks);
      $display("MODE_BINARY N=%0d mode=%0d match=1 direct=%0d rail_toggles=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
        CELLS,m,mode_stats[m].binary_direct,mode_stats[m].binary_toggles,
        real'(mode_stats[m].binary_heat_peak)/(2000*CELLS),
        real'(mode_stats[m].binary_switch_peak)/(2*CELLS),
        real'(mode_stats[m].binary_margin_min)/(2000*CELLS));
      $display("MODE_M32 N=%0d mode=%0d match=1 direct=0 logical_changes=%0d ticks=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
        CELLS,m,mode_stats[m].changes,mode_stats[m].ticks,
        real'(mode_stats[m].frp_heat_peak)/(2000*CELLS),
        real'(mode_stats[m].frp_switch_peak)/CELLS,
        real'(mode_stats[m].frp_margin_min)/(2000*CELLS));
      $display("MODE_NATIVE N=%0d mode=%0d execution_window_mean_heat_peak_q16=%0d execution_window_proxy_peak_q16=%0d margin_min_q16=%0d local_margin_min_q16=%0d",
        CELLS,m,mode_stats[m].local_heat_peak,mode_stats[m].proxy_peak,
        mode_stats[m].margin_min,mode_stats[m].local_margin_min);
    end
    $display("MODE_COVERAGE N=%0d checks=%0d task_bins=144 route_bins=%0d bank_words_checked=%0d bank_bits=%0d",
      CELLS,mode_checks,3*CELLS*2,bank_words_checked,2*CELLS);
  endtask

  initial begin : run
    real scaled;
    int iterations,elapsed;
    bit paused;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    for(int m=0;m<3;m++) begin
      mode_stats[m]='{default:0};
      mode_stats[m].binary_margin_min=2147483647;
      mode_stats[m].frp_margin_min=2147483647;
      mode_stats[m].margin_min=2147483647;
      mode_stats[m].local_margin_min=2147483647;
    end
    for(int a=0;a<4096;a++) begin
      scaled=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*1073741824.0;
      sine_table[a]=$rtoi(scaled<0 ? scaled-0.5:scaled+0.5);
    end
    for(int mode=0;mode<3;mode++) for(int direction=0;direction<2;direction++)
      for(int seed=0;seed<4;seed++) for(int pattern=0;pattern<6;pattern++) begin
        case_mode=mode; case_seed_state=direction==0 ? -1:1; cases++;
        mode_stats[mode].cases++; task_hits[mode][direction][seed][pattern]++;
        rng=32'h64a031f7 ^ 32'(seed*1000003+pattern*101+CELLS);
        reset_and_seed(case_seed_state);
        for(int c=0;c<CELLS;c++) begin
          case(pattern)
            0:phase[c]=direction==0 ? 32'h40000000:32'hc0000000;
            1:phase[c]=0;
            2:phase[c]=32'd219<<20;
            3:phase[c]=c%2==0 ? 0:32'h80000000;
            4:phase[c]=random_word();
            5:phase[c]=32'(c%4)<<30;
          endcase
          frequency[c]=word_t'(65536+seed*1024+c*17);
          gamma_effective_word[c*32+:32]=seed%2==0 ? 32'd644245094:32'd3650722202;
          thermal_node_factor_q30[c*32+:32]=seed<2 ? 32'h40000000:32'h20000000;
        end
        load_snapshot(); phase_load_valid=0;
        iterations=pattern<3 ? 1:16;
        repeat(iterations) begin
          check_phase(); predict_phase(); clock_step(1); check_phase();
          for(int c=0;c<CELLS;c++)
            eq(64'(state_out[c*2+:2]),64'(enc(reference_state[c])),"compute state retained");
        end
        for(int c=0;c<CELLS;c++) begin
          goal[c]=selection(phase[c]); target_bins[goal[c]+1]++;
          mode_targets[mode][goal[c]+1]++;
          if(goal[c]!=selection(uncoupled[c])) begin
            relative_decisions++; mode_stats[mode].relative_decisions++;
          end
        end
        binary_commit(); load_snapshot();
        // Snapshot loads preserve the computed task while its routes complete.
        auto_target_enable=0; clock_step(1);
        auto_target_enable=1; measure=1; frp_heat=0; elapsed=0; paused=0;
        while(!finished() && elapsed<16*CELLS+32) begin
          clock_step(1); elapsed++;
          if(!paused && pending_route_out!=0) begin
            // Change incoming phase targets while retained routes are paused.
            for(int c=0;c<CELLS;c++) phase_load[c*32+:32]=phase[c]+32'h80000000;
            repeat(3) begin clear_counters=!clear_counters; clock_step(0); end
            clear_counters=0;
            for(int c=0;c<CELLS;c++) phase_load[c*32+:32]=phase[c];
            clock_step(0); paused=1;
          end
        end
        if(!finished()) $fatal(1,"Sampled phase task did not complete");
        if(elapsed>mode_stats[mode].max_task_ticks) mode_stats[mode].max_task_ticks=elapsed;
        for(int c=0;c<CELLS;c++) begin
          eq(64'(state_out[c*2+:2]),64'(enc(binary_state[c])),"architecture task match");
          reference_state[c]=goal[c];
        end
        measure=0; auto_target_enable=0; phase_load_valid=0;
        // Frequency and phase continue evolving while retained zeros persist.
        repeat(8) begin predict_phase(); clock_step(1); check_phase(); end
      end
    eq(64'(cases),144,"task matrix");
    eq(64'(first_legs),64'(second_legs),"all mediated routes complete");
    eq(64'(first_legs),64'(binary_direct),"opposite-polarity task count");
    for(int m=0;m<3;m++) for(int c=0;c<CELLS;c++) for(int d=0;d<2;d++)
      if(routed[m][c][d]==0 || routed[m][c][d]!=completed[m][c][d])
        $fatal(1,"Missing indexed route mode=%0d cell=%0d direction=%0d",m,c,d);
    foreach(target_bins[k]) if(target_bins[k]==0) $fatal(1,"Missing selected symbol");
    if(relative_decisions==0 || retained_pauses==0 || balance_holds==0 || balance_entries==0
       || neutralize_entries==0 || neutral_goals==0 || zero_memory_updates==0
       || zero_phase_updates==0 || boundary_lags==0) $fatal(1,"Incomplete active-zero coverage");

    qualify_modes();
    $display("PASS PHASE_TASK N=%0d cases=%0d checks=%0d phase_updates=%0d relative_decisions=%0d signature=%016h",
      CELLS,cases,checks,phase_updates,relative_decisions,signature);
    $display("ACTIVE_ZERO N=%0d routes=%0d completed=%0d paused_retention=%0d balance_retention=%0d balance_entries=%0d neutralize_entries=%0d zero_goals=%0d frequency_memory=%0d phase_evolution=%0d boundary_lag=%0d",
      CELLS,first_legs,second_legs,retained_pauses,balance_holds,balance_entries,
      neutralize_entries,neutral_goals,zero_memory_updates,zero_phase_updates,boundary_lags);
    $display("BINARY_REFERENCE N=%0d match=1 direct=%0d rail_toggles=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
      CELLS,binary_direct,binary_toggles,real'(binary_peak_heat)/(2000*CELLS),
      real'(binary_peak_switch)/(2*CELLS),real'(binary_min_margin)/(2000*CELLS));
    $display("M32_EXECUTION N=%0d match=1 direct=0 logical_changes=%0d ticks=%0d execution_heat_peak=%.9f switch_peak=%.9f margin_min=%.9f",
      CELLS,frp_changes,execution_ticks,real'(frp_peak_heat)/(2000*CELLS),
      real'(frp_peak_switch)/CELLS,real'(frp_min_margin)/(2000*CELLS));
    $display("M32_NATIVE N=%0d execution_window_mean_heat_peak_q16=%0d margin_min_q16=%0d local_margin_min_q16=%0d",
      CELLS,native_peak_heat,native_min_margin,native_local_min_margin);
    report_modes();
    $finish;
  end

  initial begin #10000000; $fatal(1,"Phase task watchdog expired"); end
endmodule

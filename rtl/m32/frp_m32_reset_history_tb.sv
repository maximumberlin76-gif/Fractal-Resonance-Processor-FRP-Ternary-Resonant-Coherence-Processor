// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Compare all 103 public outputs after history-bearing asynchronous resets.
// Cross three scheduler modes, four feedback sources, two clock levels,
// and all tick/load/clear/auto control combinations at reset assertion.
// Check reset constants, pipeline cancellation and a 96-edge restart trace.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_reset_history_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int REQUEST_LANES=CELLS/4, CELL_INDEX_BITS=$clog2(CELLS);
  localparam int COUNTER_BITS=32, STEPS=96;
  logic clk=0, rst_n=1;

  typedef struct packed {
    logic tick_enable, clear_counters, phase_load_valid;
    logic auto_target_enable, local_gamma_enable, gamma_update_valid;
    logic local_thermal_enable;
    frp_m31_scheduler_mode_e scheduler_mode;
    logic [(CELLS*32)-1:0] phase_load, frequency_load_q16, gamma_effective_word;
    logic [(CELLS*32)-1:0] thermal_node_factor_q30, gamma_targets_q16;
    logic [REQUEST_LANES-1:0] external_request_valid;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] external_request_cell_index;
    logic [(REQUEST_LANES*FRP_M31_STATE_BITS)-1:0] external_request_target;
    logic [(CELLS*FRP_M31_STATE_BITS)-1:0] external_target_bank;
  } transaction_t;

  typedef struct packed {
    logic [(CELLS*32)-1:0] phase_word_q, frequency_current_q16, coupling_field_q16;
    logic [(CELLS*32)-1:0] phase_projection_q30, local_heat_q16, local_heat_peak_q16;
    logic [(CELLS*32)-1:0] local_generated_power_q16, local_thermal_dissipation_q16, local_thermal_diffusion_q16;
    logic [(CELLS*32)-1:0] local_thermal_overload_q16, local_next_heat_q16, local_next_overload_q16;
    logic [(CELLS*32)-1:0] local_frequency_lag_q16, local_gamma_noise_target_q16, local_gamma_noise_state_q16;
    logic [(CELLS*32)-1:0] local_gamma_drift_word, local_gamma_effective_word, local_next_gamma_drift_word;
    logic [(CELLS*32)-1:0] local_next_gamma_effective_word, phase_gamma_effective_word, local_thermal_node_factor_q30;
    logic [(CELLS*32)-1:0] local_next_thermal_node_factor_q30, phase_thermal_node_factor_q30;
    logic [(CELLS*FRP_M31_STATE_BITS)-1:0] phase_target_source, registered_target_q, execution_target_bank;
    logic [(CELLS*FRP_M31_STATE_BITS)-1:0] state_out, pending_route_out;
    logic registered_target_valid_q, phase_target_domain_valid, registered_target_domain_valid;
    logic target_capture_accepted, target_capture_rejected, registered_request_enable;
    logic capacity_exhausted, stable, local_stable;
    logic local_stability_valid_q;
    logic [COUNTER_BITS-1:0] accepted_target_capture_events_q, rejected_target_capture_events_q, ticks_recorded_q;
    logic [COUNTER_BITS-1:0] scheduler_count_free_q, scheduler_count_balance_q, scheduler_count_commit_q;
    logic [COUNTER_BITS-1:0] scheduler_count_excite_q, scheduler_count_neutralize_q, accepted_changes;
    logic [COUNTER_BITS-1:0] capacity_remaining, switch_load_numerator, requested_direct_events;
    logic [COUNTER_BITS-1:0] prevented_direct_events, neutral_routed_events, actual_direct_events;
    logic [COUNTER_BITS-1:0] reserved_state_events, queue_overflow_events;
    logic [REQUEST_LANES-1:0] phase_request_valid, execution_request_valid, request_accept;
    logic [REQUEST_LANES-1:0] request_reject;
    logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] phase_request_cell_index, execution_request_cell_index;
    logic [(REQUEST_LANES*FRP_M31_STATE_BITS)-1:0] phase_request_target, execution_request_target;
    frp_m31_scheduler_mode_e scheduler_mode_q;
    frp_m31_scheduler_state_e scheduler_state_q;
    logic [CELLS-1:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;
    logic signed [31:0] pair_coherence_q30, cluster_coherence_q30, global_coherence_q30;
    logic signed [31:0] organization_dispersion_q30, normalized_cycle_cost_q16, temperature_proxy_q16;
    logic signed [31:0] peak_temperature_proxy_q16, coherence_capacity_q16, pressure_q16;
    logic signed [31:0] stability_margin_q16, local_mean_heat_q16, local_mean_heat_peak_q16;
    logic signed [31:0] local_maximum_heat_peak_q16, local_coherence_compression_q30, local_effective_coherence_q30;
    logic signed [31:0] local_coherence_capacity_q16, local_pressure_q16, local_stability_margin_q16;
    logic signed [31:0] local_previous_margin_q16, local_stability_raw_coherence_q30, local_stability_cluster_coherence_q30;
    logic signed [31:0] local_stability_mean_heat_q16, local_stability_mean_overload_q16, local_stability_mean_lag_q16;
    logic signed [31:0] local_stability_neutral_fraction_q30, local_stability_compression_arg_q16, local_stability_switch_load_q16;
    logic [31:0] thermal_sample_count_q, local_stability_sample_count_q;
    logic [((CELLS-1)*32)-1:0] group_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_mean_coherence_q30, level_min_coherence_q30, level_max_coherence_q30;
    logic [($clog2(CELLS)*32)-1:0] level_dispersion_q30;
  } observation_t;

  transaction_t drive;
  observation_t actual;

  frp_m32_core #(.CELLS(CELLS), .COUNTER_BITS(COUNTER_BITS)) dut (
    .clk, .rst_n,
    .tick_enable(drive.tick_enable), .clear_counters(drive.clear_counters),
    .scheduler_mode(drive.scheduler_mode), .phase_load_valid(drive.phase_load_valid),
    .phase_load(drive.phase_load), .frequency_load_q16(drive.frequency_load_q16),
    .gamma_effective_word(drive.gamma_effective_word), .thermal_node_factor_q30(drive.thermal_node_factor_q30),
    .auto_target_enable(drive.auto_target_enable), .external_request_valid(drive.external_request_valid),
    .external_request_cell_index(drive.external_request_cell_index), .external_request_target(drive.external_request_target),
    .external_target_bank(drive.external_target_bank), .phase_word_q(actual.phase_word_q),
    .frequency_current_q16(actual.frequency_current_q16), .coupling_field_q16(actual.coupling_field_q16),
    .phase_projection_q30(actual.phase_projection_q30), .phase_target_source(actual.phase_target_source),
    .registered_target_q(actual.registered_target_q), .registered_target_valid_q(actual.registered_target_valid_q),
    .phase_target_domain_valid(actual.phase_target_domain_valid), .registered_target_domain_valid(actual.registered_target_domain_valid),
    .target_capture_accepted(actual.target_capture_accepted), .target_capture_rejected(actual.target_capture_rejected),
    .accepted_target_capture_events_q(actual.accepted_target_capture_events_q), .rejected_target_capture_events_q(actual.rejected_target_capture_events_q),
    .registered_request_enable(actual.registered_request_enable), .phase_request_valid(actual.phase_request_valid),
    .phase_request_cell_index(actual.phase_request_cell_index), .phase_request_target(actual.phase_request_target),
    .execution_request_valid(actual.execution_request_valid), .execution_request_cell_index(actual.execution_request_cell_index),
    .execution_request_target(actual.execution_request_target), .execution_target_bank(actual.execution_target_bank),
    .state_out(actual.state_out), .pending_route_out(actual.pending_route_out),
    .scheduler_mode_q(actual.scheduler_mode_q), .scheduler_state_q(actual.scheduler_state_q),
    .ticks_recorded_q(actual.ticks_recorded_q), .scheduler_count_free_q(actual.scheduler_count_free_q),
    .scheduler_count_balance_q(actual.scheduler_count_balance_q), .scheduler_count_commit_q(actual.scheduler_count_commit_q),
    .scheduler_count_excite_q(actual.scheduler_count_excite_q), .scheduler_count_neutralize_q(actual.scheduler_count_neutralize_q),
    .request_accept(actual.request_accept), .request_reject(actual.request_reject),
    .accepted_cell_mask(actual.accepted_cell_mask), .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
    .accepted_change_mask(actual.accepted_change_mask), .accepted_changes(actual.accepted_changes),
    .capacity_remaining(actual.capacity_remaining), .capacity_exhausted(actual.capacity_exhausted),
    .switch_load_numerator(actual.switch_load_numerator), .requested_direct_events(actual.requested_direct_events),
    .prevented_direct_events(actual.prevented_direct_events), .neutral_routed_events(actual.neutral_routed_events),
    .actual_direct_events(actual.actual_direct_events), .reserved_state_events(actual.reserved_state_events),
    .queue_overflow_events(actual.queue_overflow_events), .invariant_flags(actual.invariant_flags),
    .pair_coherence_q30(actual.pair_coherence_q30), .cluster_coherence_q30(actual.cluster_coherence_q30),
    .global_coherence_q30(actual.global_coherence_q30), .organization_dispersion_q30(actual.organization_dispersion_q30),
    .normalized_cycle_cost_q16(actual.normalized_cycle_cost_q16), .temperature_proxy_q16(actual.temperature_proxy_q16),
    .peak_temperature_proxy_q16(actual.peak_temperature_proxy_q16), .thermal_sample_count_q(actual.thermal_sample_count_q),
    .coherence_capacity_q16(actual.coherence_capacity_q16), .pressure_q16(actual.pressure_q16),
    .stability_margin_q16(actual.stability_margin_q16), .stable(actual.stable),
    .local_heat_q16(actual.local_heat_q16), .local_heat_peak_q16(actual.local_heat_peak_q16),
    .local_generated_power_q16(actual.local_generated_power_q16), .local_thermal_dissipation_q16(actual.local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(actual.local_thermal_diffusion_q16), .local_thermal_overload_q16(actual.local_thermal_overload_q16),
    .local_next_heat_q16(actual.local_next_heat_q16), .local_next_overload_q16(actual.local_next_overload_q16),
    .local_frequency_lag_q16(actual.local_frequency_lag_q16), .local_mean_heat_q16(actual.local_mean_heat_q16),
    .local_mean_heat_peak_q16(actual.local_mean_heat_peak_q16), .local_maximum_heat_peak_q16(actual.local_maximum_heat_peak_q16),
    .local_gamma_enable(drive.local_gamma_enable), .gamma_update_valid(drive.gamma_update_valid),
    .gamma_targets_q16(drive.gamma_targets_q16), .local_gamma_noise_target_q16(actual.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(actual.local_gamma_noise_state_q16), .local_gamma_drift_word(actual.local_gamma_drift_word),
    .local_gamma_effective_word(actual.local_gamma_effective_word), .local_next_gamma_drift_word(actual.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(actual.local_next_gamma_effective_word), .phase_gamma_effective_word(actual.phase_gamma_effective_word),
    .local_thermal_enable(drive.local_thermal_enable), .local_thermal_node_factor_q30(actual.local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(actual.local_next_thermal_node_factor_q30), .phase_thermal_node_factor_q30(actual.phase_thermal_node_factor_q30),
    .group_coherence_q30(actual.group_coherence_q30), .level_mean_coherence_q30(actual.level_mean_coherence_q30),
    .level_min_coherence_q30(actual.level_min_coherence_q30), .level_max_coherence_q30(actual.level_max_coherence_q30),
    .level_dispersion_q30(actual.level_dispersion_q30), .local_coherence_compression_q30(actual.local_coherence_compression_q30),
    .local_effective_coherence_q30(actual.local_effective_coherence_q30), .local_coherence_capacity_q16(actual.local_coherence_capacity_q16),
    .local_pressure_q16(actual.local_pressure_q16), .local_stability_margin_q16(actual.local_stability_margin_q16),
    .local_stable(actual.local_stable), .local_previous_margin_q16(actual.local_previous_margin_q16),
    .local_stability_valid_q(actual.local_stability_valid_q), .local_stability_sample_count_q(actual.local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(actual.local_stability_raw_coherence_q30), .local_stability_cluster_coherence_q30(actual.local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(actual.local_stability_mean_heat_q16), .local_stability_mean_overload_q16(actual.local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(actual.local_stability_mean_lag_q16), .local_stability_neutral_fraction_q30(actual.local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(actual.local_stability_compression_arg_q16), .local_stability_switch_load_q16(actual.local_stability_switch_load_q16)
  );


  observation_t reset_asserted[16], reset_released[16], idle_expected[3];
  observation_t before_expected[STEPS], after_expected[STEPS];
  int profile_mode=0, profile_source=0, controls=0, clock_level=0, cycle=0;
  int checks=0, reset_checks=0, cases=0, restart_edges=0;
  int pending_resets=0, live_samples=0, dirty_heat=0, dirty_gamma=0;
  int reset_bins[3][4][2][16], positions[3][4][8], states[5];
  int first_legs=0, second_legs=0;
  logic [CELLS-1:0] first_cells='0, second_cells='0;

  task automatic compare(input observation_t expected, input string stage);
    checks++;
    if (actual !== expected) begin
      for (int b=0;b<$bits(observation_t);b++)
        if (actual[b] !== expected[b]) begin
          $display("M32_RESET_MISMATCH cells=%0d mode=%0d sources=%0d controls=%0d clock=%0d cycle=%0d stage=%s bit=%0d got=%b expected=%b",
            CELLS,profile_mode,profile_source,controls,clock_level,cycle,stage,b,actual[b],expected[b]);
          break;
        end
      $fatal(1,"M32 reset history mismatch");
    end
  endtask

  task automatic defaults;
    drive='0;
    drive.scheduler_mode=frp_m31_scheduler_mode_e'(profile_mode);
    drive.local_gamma_enable=1'(profile_source);
    drive.local_thermal_enable=1'(profile_source>>1);
    drive.thermal_node_factor_q30={CELLS{32'h40000000}};
    drive.gamma_effective_word={CELLS{32'h26666666}};
  endtask

  task automatic reset_constants;
    reset_checks++;
    if (actual.state_out !== '0 || actual.pending_route_out !== '0 ||
        actual.registered_target_q !== '0 || actual.registered_target_valid_q !== 0 ||
        actual.accepted_target_capture_events_q !== 0 || actual.rejected_target_capture_events_q !== 0 ||
        actual.ticks_recorded_q !== 0 || actual.scheduler_mode_q !== FRP_MODE_FREE ||
        actual.scheduler_state_q !== FRP_SCHED_FREE ||
        actual.scheduler_count_free_q !== 0 || actual.scheduler_count_balance_q !== 0 ||
        actual.scheduler_count_commit_q !== 0 || actual.scheduler_count_excite_q !== 0 ||
        actual.scheduler_count_neutralize_q !== 0 || actual.thermal_sample_count_q !== 0 ||
        actual.local_stability_sample_count_q !== 0 || actual.local_stability_valid_q !== 0 ||
        actual.local_stability_raw_coherence_q30 !== 0 || actual.local_stability_cluster_coherence_q30 !== 0 ||
        actual.local_stability_mean_heat_q16 !== 3277 || actual.local_stability_mean_overload_q16 !== 0 ||
        actual.local_stability_mean_lag_q16 !== 0 || actual.local_stability_switch_load_q16 !== 0 ||
        actual.local_stability_neutral_fraction_q30 !== 1073741824 ||
        actual.local_stability_compression_arg_q16 !== 0 || actual.local_previous_margin_q16 !== 39322 ||
        actual.local_coherence_compression_q30 !== 1073741824 || actual.local_effective_coherence_q30 !== 0 ||
        actual.local_coherence_capacity_q16 !== 65536 || actual.local_pressure_q16 !== 3277 ||
        actual.local_stability_margin_q16 !== 62259 || actual.local_stable !== 1 ||
        actual.local_mean_heat_peak_q16 !== 3277)
      $fatal(1,"M32 reset history scalar reset constants");
    for (int i=0;i<CELLS;i++) begin
      if (actual.phase_word_q[32*i+:32] !== 32'(64'(i)*(64'd4294967296/CELLS)) ||
          actual.frequency_current_q16[32*i+:32] !== 65536 ||
          actual.local_heat_q16[32*i+:32] !== 3277 || actual.local_heat_peak_q16[32*i+:32] !== 3277 ||
          actual.local_generated_power_q16[32*i+:32] !== 0 || actual.local_thermal_dissipation_q16[32*i+:32] !== 0 ||
          actual.local_thermal_diffusion_q16[32*i+:32] !== 0 || actual.local_thermal_overload_q16[32*i+:32] !== 0 ||
          actual.local_gamma_noise_target_q16[32*i+:32] !== 0 || actual.local_gamma_noise_state_q16[32*i+:32] !== 0 ||
          actual.local_gamma_drift_word[32*i+:32] !== 0 || actual.local_gamma_effective_word[32*i+:32] !== 32'h26666666)
        $fatal(1,"M32 reset history cell reset constants cell=%0d",i);
    end
  endtask

  task automatic cold_reset;
    clk=0; defaults(); #2; rst_n=0; #2;
    reset_constants();
    clk=1; #2; clk=0; #2; rst_n=1; #2;
  endtask

  task automatic stimulus(input int t, input bit warm);
    defaults();
    drive.tick_enable=warm || (t%11!=7);
    drive.phase_load_valid=(t==0 || (!warm && t==37));
    drive.clear_counters=(!warm && t==51);
    drive.auto_target_enable=(t>=64);
    drive.gamma_update_valid=(t%5==0);
    for (int i=0;i<CELLS;i++) begin
      drive.phase_load[32*i+:32]=32'h10203040*32'(i+1)+32'(t)*32'h07135791;
      drive.frequency_load_q16[32*i+:32]=32'((i%5-2)*65536);
      drive.gamma_effective_word[32*i+:32]=32'h26666666+32'((i+t)%17)*32'h00100000;
      drive.gamma_targets_q16[32*i+:32]=32'(((i*19+t*7)%129-64)*256);
      drive.thermal_node_factor_q30[32*i+:32]=32'h40000000-32'((i+t)%9)*32'h02000000;
      drive.external_target_bank[2*i+:2]=((t/8)%2) ? FRP_STATE_NEG : FRP_STATE_POS;
    end
    for (int lane=0;lane<REQUEST_LANES;lane++) begin
      drive.external_request_valid[lane]=1;
      drive.external_request_cell_index[CELL_INDEX_BITS*lane+:CELL_INDEX_BITS]=
        CELL_INDEX_BITS'(((t/16)%4)*REQUEST_LANES+lane);
      drive.external_request_target[2*lane+:2]=((t/8)%2) ? FRP_STATE_NEG : FRP_STATE_POS;
    end
    #2;
  endtask

  task automatic checked_edge;
    observation_t previous;
    previous=actual;
    if (actual.invariant_flags !== '1 || actual.actual_direct_events != 0 ||
        actual.reserved_state_events != 0 || actual.queue_overflow_events != 0)
      $fatal(1,"M32 reset history execution invariant");
    clk=1; #2;
    for (int i=0;i<CELLS;i++) begin
      if (actual.state_out[2*i+:2]==FRP_STATE_RESERVED || actual.pending_route_out[2*i+:2]==FRP_STATE_RESERVED ||
          (previous.state_out[2*i+:2]==FRP_STATE_POS && actual.state_out[2*i+:2]==FRP_STATE_NEG) ||
          (previous.state_out[2*i+:2]==FRP_STATE_NEG && actual.state_out[2*i+:2]==FRP_STATE_POS))
        $fatal(1,"M32 reset history ternary transition cell=%0d",i);
      if (previous.state_out[2*i+:2]!=0 && actual.state_out[2*i+:2]==0 && actual.pending_route_out[2*i+:2]!=0) begin
        first_legs++; first_cells[i]=1;
      end
      if (previous.pending_route_out[2*i+:2]!=0 && actual.pending_route_out[2*i+:2]==0 &&
          actual.state_out[2*i+:2]==previous.pending_route_out[2*i+:2]) begin
        second_legs++; second_cells[i]=1;
      end
    end
  endtask

  task automatic collision;
    stimulus(93,0);
    drive.tick_enable=1'(controls);
    drive.phase_load_valid=1'(controls>>1);
    drive.clear_counters=1'(controls>>2);
    drive.auto_target_enable=1'(controls>>3);
    drive.gamma_update_valid=1;
    #2;
  endtask

  task automatic restart(input bit reference_run);
    clk=0; defaults(); #2;
    for (int k=0;k<3;k++) begin
      clk=1; #2;
      if (actual.local_stability_valid_q !== 0 || actual.local_stability_sample_count_q !== 0 ||
          actual.state_out !== '0 || actual.pending_route_out !== '0 || actual.registered_target_valid_q !== 0)
        $fatal(1,"M32 reset history stale work after reset idle=%0d",k);
      if (reference_run) idle_expected[k]=actual;
      else compare(idle_expected[k],"empty restart pipeline");
      clk=0; #2;
    end
    for (int t=0;t<STEPS;t++) begin
      cycle=t; stimulus(t,0);
      if (reference_run) before_expected[t]=actual;
      else compare(before_expected[t],"restart before edge");
      checked_edge();
      if (reference_run) after_expected[t]=actual;
      else compare(after_expected[t],"restart after edge");
      restart_edges++;
      clk=0; #2;
    end
  endtask

  initial begin
    if (CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64)
      $fatal(1,"M32 reset history requires 8/16/32/64 cells");
    foreach(reset_bins[m,s,h,c]) reset_bins[m][s][h][c]=0;
    foreach(positions[m,s,p]) positions[m][s][p]=0;
    foreach(states[s]) states[s]=0;
    for (int m=0;m<3;m++) begin
      profile_mode=m;
      for (int s=0;s<4;s++) begin
        profile_source=s;
        // Reset-state observations use the same collision pins as warm cases.
        cold_reset();
        for (int c=0;c<16;c++) begin
          controls=c; collision(); rst_n=0; #2; reset_constants();
          reset_asserted[c]=actual;
          clk=1; #2; compare(reset_asserted[c],"reference reset held");
          clk=0; #2; rst_n=1; #2; reset_released[c]=actual;
        end
        cold_reset(); restart(1);
        for (int h=0;h<2;h++) begin
          clock_level=h;
          for (int c=0;c<16;c++) begin
            controls=c; cold_reset();
            for (int t=0;t<64+c%8;t++) begin
              cycle=t; stimulus(t,1); checked_edge();
              if (t<63+c%8 || h==0) begin clk=0; #2; end
            end
            if (actual.local_heat_q16=={CELLS{32'd3277}} ||
                actual.local_gamma_noise_state_q16=='0 || actual.local_stability_sample_count_q==0)
              $fatal(1,"M32 reset history missing accumulated feedback");
            dirty_heat++; dirty_gamma++;
            if (actual.pending_route_out!='0) pending_resets++;
            if (actual.local_stability_valid_q) live_samples++;
            if (actual.scheduler_state_q>FRP_SCHED_NEUTRALIZE)
              $fatal(1,"M32 reset history invalid scheduler state");
            states[int'(actual.scheduler_state_q)]++;
            positions[m][s][c%8]++;
            collision(); rst_n=0; #2;
            // No rising edge occurs between assertion and this comparison.
            reset_constants(); compare(reset_asserted[c],"asynchronous assertion");
            for (int k=0;k<2;k++) begin
              clk=0; #2; clk=1; #2;
              reset_constants(); compare(reset_asserted[c],"reset held under controls");
            end
            clk=1'(h); #2; rst_n=1; #2;
            compare(reset_released[c],"reset release without edge");
            restart(0);
            reset_bins[m][s][h][c]++; cases++;
          end
        end
        $display("M32_RESET_HISTORY_PROFILE: PASS cells=%0d mode=%0d sources=%0d cases=32 restart_steps=%0d",
          CELLS,m,s,STEPS);
      end
    end
    foreach(reset_bins[m,s,h,c])
      if(reset_bins[m][s][h][c]!=1) $fatal(1,"M32 reset history missing control bin");
    foreach(positions[m,s,p])
      if(positions[m][s][p]!=4) $fatal(1,"M32 reset history missing scheduler position");
    foreach(states[s])
      if(states[s]==0) $fatal(1,"M32 reset history missing scheduler state");
    if(cases!=384 || dirty_heat!=384 || dirty_gamma!=384 || live_samples!=384 ||
       pending_resets==0 || first_cells!='1 || second_cells!='1 ||
       restart_edges!=38016 || checks!=76608 || reset_checks!=1752)
      $fatal(1,"M32 reset history coverage cases=%0d pending=%0d first=%h second=%h checks=%0d resets=%0d",
        cases,pending_resets,first_cells,second_cells,checks,reset_checks);
    $display("FRP_M32_RESET_HISTORY_TB: PASS cells=%0d output_ports=103 output_bits=%0d profiles=12 cases=%0d checks=%0d reset_checks=%0d restart_edges=%0d pending_resets=%0d live_samples=%0d dirty_heat=%0d dirty_gamma=%0d first=%0d second=%0d",
      CELLS,$bits(observation_t),cases,checks,reset_checks,restart_edges,
      pending_resets,live_samples,dirty_heat,dirty_gamma,first_legs,second_legs);
    $finish;
  end

  initial begin #2000000; $fatal(1,"M32 reset history watchdog"); end
endmodule

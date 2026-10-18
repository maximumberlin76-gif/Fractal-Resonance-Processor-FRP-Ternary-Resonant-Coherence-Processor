// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Compare all public M32 outputs before and after each enabled edge.
// Replay the same transactions with two deterministic pause schedules.
// During inserted pauses: reset released, tick/load/clear low, mode held.
// Other input pins vary, then return to the sampled transaction values.
// Twelve profiles: FREE/7:1/1:7 crossed with four thermal/gamma source pairs.
// Two disabled edges complete and deassert the delayed stability sample.
// Compare those edges separately before testing additional pause retention.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_pause_replay_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int REQUEST_LANES=CELLS/4, CELL_INDEX_BITS=$clog2(CELLS);
  localparam int COUNTER_BITS=32, STEPS=512;
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

  observation_t expected_drain[STEPS][2];
  transaction_t drive;
  observation_t actual, expected_before[STEPS], expected_after[STEPS];

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

  int checks=0, paused_edges=0, enabled_edges=0, reset_cases=0;
  int profile_mode=0, profile_source=0, replay=0, cycle=0;
  int pause_bins[3][4][8], state_hits[5], first_legs=0, second_legs=0;
  int heat_changes=0, gamma_changes=0, phase_changes=0;
  int pending_pauses=0, target_separations=0, clear_edges=0, load_edges=0;
  logic [CELLS-1:0] first_cells=0, second_cells=0;

  task automatic compare(input observation_t expected, input string stage);
    checks++;
    if (actual !== expected) begin
      for (int bit_index=0; bit_index<$bits(observation_t); bit_index++)
        if (actual[bit_index] !== expected[bit_index]) begin
          $display("M32_PAUSE_MISMATCH cells=%0d mode=%0d source=%0d replay=%0d cycle=%0d stage=%s bit=%0d got=%b expected=%b",
            CELLS,profile_mode,profile_source,replay,cycle,stage,bit_index,
            actual[bit_index],expected[bit_index]);
          break;
        end
      $fatal(1,"M32 pause replay output mismatch");
    end
  endtask

  task automatic reset_core;
    drive='0;
    drive.scheduler_mode=FRP_MODE_FREE;
    drive.thermal_node_factor_q30={CELLS{32'h40000000}};
    clk=0; #1; rst_n=0; #2;
    if (actual.state_out !== '0 || actual.pending_route_out !== '0 ||
        actual.registered_target_q !== '0 || actual.registered_target_valid_q !== 0 ||
        actual.ticks_recorded_q !== 0 || actual.local_stability_sample_count_q !== 0)
      $fatal(1,"M32 pause replay reset mismatch");
    for (int i=0;i<CELLS;i++) begin
      if (actual.phase_word_q[32*i+:32] !== 32'(64'(i)*(64'd4294967296/CELLS)) ||
          actual.frequency_current_q16[32*i+:32] !== 32'd65536 ||
          actual.local_heat_q16[32*i+:32] !== 32'd3277 ||
          actual.local_gamma_noise_state_q16[32*i+:32] !== 0)
        $fatal(1,"M32 pause replay cell reset mismatch cell=%0d",i);
    end
    clk=1; #2; clk=0; rst_n=1; #2;
    reset_cases++;
  endtask

  task automatic stimulus(input int t);
    drive='0;
    drive.tick_enable=1;
    drive.scheduler_mode=frp_m31_scheduler_mode_e'(profile_mode);
    drive.local_gamma_enable=1'(profile_source);
    drive.local_thermal_enable=1'(profile_source>>1);
    drive.auto_target_enable=(t>=64 && ((t/64)%2)==1);
    drive.phase_load_valid=(t==0 || t==173 || t==346);
    drive.clear_counters=(t==257);
    drive.gamma_update_valid=(t%7==0);
    for (int i=0;i<CELLS;i++) begin
      drive.phase_load[32*i+:32]=32'h10203040*32'(i+1)+32'(t)*32'h07135791;
      drive.frequency_load_q16[32*i+:32]=32'((i%5-2)*65536);
      drive.gamma_effective_word[32*i+:32]=32'h26666666+32'((i+t)%17)*32'h00100000;
      drive.gamma_targets_q16[32*i+:32]=32'(((i*19+t*7)%129-64)*256);
      drive.thermal_node_factor_q30[32*i+:32]=32'h40000000-32'((i+t)%9)*32'h02000000;
      drive.external_target_bank[2*i+:2]=((t/16)%2) ? FRP_STATE_NEG : FRP_STATE_POS;
    end
    for (int lane=0;lane<REQUEST_LANES;lane++) begin
      drive.external_request_valid[lane]=1;
      drive.external_request_cell_index[CELL_INDEX_BITS*lane+:CELL_INDEX_BITS]=
        CELL_INDEX_BITS'(((t/32)%4)*REQUEST_LANES+lane);
      drive.external_request_target[2*lane+:2]=((t/16)%2) ? FRP_STATE_NEG : FRP_STATE_POS;
    end
    #2;
  endtask

  task automatic insert_pauses(input int count);
    transaction_t saved, quiet;
    observation_t held;
    saved=drive;
    quiet=drive;
    quiet.tick_enable=0;
    quiet.phase_load_valid=0;
    quiet.clear_counters=0;
    quiet.scheduler_mode=actual.scheduler_mode_q;
    drive=quiet; #2; held=actual;
    for (int p=0;p<count;p++) begin
      drive=quiet;
      drive.auto_target_enable=~quiet.auto_target_enable;
      drive.local_gamma_enable=~quiet.local_gamma_enable;
      drive.local_thermal_enable=~quiet.local_thermal_enable;
      drive.gamma_update_valid=1;
      drive.phase_load=~quiet.phase_load;
      drive.frequency_load_q16=~quiet.frequency_load_q16;
      drive.gamma_effective_word=~quiet.gamma_effective_word;
      drive.gamma_targets_q16=~quiet.gamma_targets_q16;
      drive.thermal_node_factor_q30='0;
      drive.external_request_valid='1;
      drive.external_request_cell_index='1;
      drive.external_request_target={REQUEST_LANES{2'b10}};
      drive.external_target_bank={CELLS{2'b10}};
      #2; clk=1; #2; clk=0;
      drive=quiet; #2;
      compare(held,"pause retention");
      paused_edges++;
      if (held.pending_route_out != 0) pending_pauses++;
    end
    drive=saved; #2;
    if(count>0) pause_bins[profile_mode][profile_source][cycle%8]++;
  endtask

  task automatic drain_stability;
    transaction_t saved, quiet;
    saved=drive; quiet=drive;
    quiet.tick_enable=0; quiet.phase_load_valid=0; quiet.clear_counters=0;
    quiet.scheduler_mode=actual.scheduler_mode_q;
    for(int edge_id=0;edge_id<2;edge_id++) begin
      drive=quiet;
      if(replay>0) begin
        drive.auto_target_enable=~quiet.auto_target_enable;
        drive.local_gamma_enable=~quiet.local_gamma_enable;
        drive.local_thermal_enable=~quiet.local_thermal_enable;
        drive.gamma_update_valid=1;
        drive.gamma_targets_q16=~quiet.gamma_targets_q16;
        drive.external_request_valid='1;
        drive.external_request_target={REQUEST_LANES{2'b10}};
        drive.external_target_bank={CELLS{2'b10}};
      end
      #2; clk=1; #2; clk=0; drive=quiet; #2;
      if(actual.local_stability_valid_q !== (edge_id==0) ||
         actual.local_stability_sample_count_q !== 32'(cycle+1))
        $fatal(1,"M32 pause replay stability completion cycle=%0d edge=%0d",cycle,edge_id);
      if(replay==0) expected_drain[cycle][edge_id]=actual;
      else compare(expected_drain[cycle][edge_id],"stability completion");
    end
    drive=saved; #2;
  endtask

  task automatic enabled_step;
    observation_t before_edge;
    before_edge=actual;
    if (actual.scheduler_state_q>FRP_SCHED_NEUTRALIZE)
      $fatal(1,"M32 pause replay invalid scheduler state");
    state_hits[int'(actual.scheduler_state_q)]++;
    if (actual.actual_direct_events != 0 || actual.reserved_state_events != 0 ||
        actual.queue_overflow_events != 0 || actual.invariant_flags != '1)
      $fatal(1,"M32 pause replay execution invariant");
    if (actual.registered_target_q != actual.state_out) target_separations++;
    if (drive.clear_counters) clear_edges++;
    if (drive.phase_load_valid) load_edges++;
    clk=1; #2; clk=0; #2;
    enabled_edges++;
    for (int i=0;i<CELLS;i++) begin
      if (actual.state_out[2*i+:2]==2'b10 || actual.pending_route_out[2*i+:2]==2'b10)
        $fatal(1,"M32 pause replay reserved state cell=%0d",i);
      if ((before_edge.state_out[2*i+:2]==FRP_STATE_POS && actual.state_out[2*i+:2]==FRP_STATE_NEG) ||
          (before_edge.state_out[2*i+:2]==FRP_STATE_NEG && actual.state_out[2*i+:2]==FRP_STATE_POS))
        $fatal(1,"M32 pause replay direct transition cell=%0d",i);
      if (before_edge.state_out[2*i+:2]!=0 && actual.state_out[2*i+:2]==0 &&
          actual.pending_route_out[2*i+:2]!=0) begin
        first_legs++; first_cells[i]=1;
      end
      if (before_edge.pending_route_out[2*i+:2]!=0 && actual.pending_route_out[2*i+:2]==0 &&
          actual.state_out[2*i+:2]==before_edge.pending_route_out[2*i+:2]) begin
        second_legs++; second_cells[i]=1;
      end
    end
    if(actual.phase_word_q!=before_edge.phase_word_q) phase_changes++;
    if(actual.local_heat_q16!=before_edge.local_heat_q16) heat_changes++;
    if(actual.local_gamma_noise_state_q16!=before_edge.local_gamma_noise_state_q16) gamma_changes++;
  endtask

  initial begin
    if (CELLS!=8 && CELLS!=16 && CELLS!=32 && CELLS!=64)
      $fatal(1,"M32 pause replay requires 8/16/32/64 cells");
    foreach(pause_bins[m,s,p]) pause_bins[m][s][p]=0;
    foreach(state_hits[s]) state_hits[s]=0;
    for (int m=0;m<3;m++) begin
      profile_mode=m;
      for (int s=0;s<4;s++) begin
        profile_source=s;
        for (int r=0;r<3;r++) begin
          replay=r;
          reset_core();
          for (int t=0;t<STEPS;t++) begin
            cycle=t; stimulus(t);
            if(r>0) insert_pauses(r==1 ? 1+(t%4) : ((t%31)==0 ? 17 : 1+((t*5+3)%7)));
            if(r==0) expected_before[t]=actual;
            else compare(expected_before[t],"before enabled edge");
            enabled_step();
            if(r==0) expected_after[t]=actual;
            else compare(expected_after[t],"after enabled edge");
            drain_stability();
          end
        end
        $display("M32_PAUSE_PROFILE: PASS cells=%0d mode=%0d sources=%0d steps=%0d replays=2",CELLS,m,s,STEPS);
      end
    end
    foreach(pause_bins[m,s,p])
      if(pause_bins[m][s][p]!=128) $fatal(1,"M32 pause replay missing pause bin");
    foreach(state_hits[s])
      if(state_hits[s]==0) $fatal(1,"M32 pause replay missing scheduler state");
    if(reset_cases!=36 || enabled_edges!=18432 || clear_edges!=36 || load_edges!=108 ||
       first_legs==0 || second_legs==0 || first_cells!='1 || second_cells!='1 ||
       pending_pauses==0 || target_separations==0 || phase_changes==0 ||
       heat_changes==0 || gamma_changes==0 || checks!=paused_edges+49152)
      $fatal(1,"M32 pause replay incomplete activity first=%h second=%h pending=%0d checks=%0d paused=%0d",
        first_cells,second_cells,pending_pauses,checks,paused_edges);
    $display("FRP_M32_PAUSE_REPLAY_TB: PASS cells=%0d output_ports=103 output_bits=%0d profiles=12 replays=2 enabled=%0d paused=%0d checks=%0d resets=%0d first=%0d second=%0d pending_pauses=%0d target_separations=%0d phase_changes=%0d heat_changes=%0d gamma_changes=%0d",
      CELLS,$bits(observation_t),enabled_edges,paused_edges,checks,reset_cases,
      first_legs,second_legs,pending_pauses,target_separations,phase_changes,heat_changes,gamma_changes);
    $finish;
  end

  initial begin
    #2000000;
    $fatal(1,"M32 pause replay watchdog");
  end
endmodule

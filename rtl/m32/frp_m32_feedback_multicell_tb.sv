// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 continuous phase / active-zero execution / local thermal-gamma feedback.
// Independent integer oracle: no DUT functions, internal signals or memory reads.
// Analytic sine and exponential tables; dyadic coherence at every scale.
// Select CELLS=8,16,32 on top frp_m32_feedback_multicell_tb.
// Compile from repository root with --binary --timing --assert -Irtl/m31 -Irtl/m32.
// Checks public feedback, execution and legacy stability ports before/after edges.
// Registered local stability telemetry has its own regression.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_feedback_multicell_checker #(
  parameter int N=8, L=N/4, I=$clog2(N), D=$clog2(N)
)(output bit done=0);
  import frp_m31_pkg::*;
  logic auto_target_enable = 0;
  logic clear_counters = 0;
  logic clk = 0;
  logic [L*I-1:0] external_request_cell_index = 0;
  logic [L*2-1:0] external_request_target = 0;
  logic [L-1:0] external_request_valid = 0;
  logic [N*2-1:0] external_target_bank = 0;
  logic [N*32-1:0] frequency_load_q16 = 0;
  logic [N*32-1:0] gamma_effective_word = 0;
  logic [N*32-1:0] phase_load = 0;
  logic phase_load_valid = 0;
  logic rst_n = 1;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  logic [N*32-1:0] thermal_node_factor_q30 = 0;
  logic tick_enable = 0;

  logic local_gamma_enable=0, local_thermal_enable=0, gamma_update_valid=0;
  logic [N*32-1:0] gamma_targets_q16=0;

  typedef struct packed {
    logic [N-1:0] accepted_cell_mask, accepted_change_mask, neutral_routed_cell_mask;
    logic [31:0] accepted_changes, accepted_target_capture_events_q, actual_direct_events;
    logic [31:0] capacity_remaining, cluster_coherence_q30, coherence_capacity_q16;
    logic [31:0] global_coherence_q30, neutral_routed_events, normalized_cycle_cost_q16;
    logic [31:0] organization_dispersion_q30, pair_coherence_q30, peak_temperature_proxy_q16;
    logic [31:0] pressure_q16, prevented_direct_events, queue_overflow_events;
    logic [31:0] rejected_target_capture_events_q, requested_direct_events, reserved_state_events;
    logic [31:0] scheduler_count_balance_q, scheduler_count_commit_q, scheduler_count_excite_q;
    logic [31:0] scheduler_count_free_q, scheduler_count_neutralize_q, stability_margin_q16;
    logic [31:0] switch_load_numerator, temperature_proxy_q16, thermal_sample_count_q;
    logic [31:0] ticks_recorded_q;
    logic capacity_exhausted, phase_target_domain_valid, registered_request_enable;
    logic registered_target_domain_valid, registered_target_valid_q, stable;
    logic target_capture_accepted, target_capture_rejected;
    logic [N*32-1:0] coupling_field_q16, frequency_current_q16, phase_projection_q30;
    logic [N*32-1:0] phase_word_q, local_heat_q16, local_heat_peak_q16;
    logic [N*32-1:0] local_generated_power_q16, local_thermal_dissipation_q16, local_thermal_diffusion_q16;
    logic [N*32-1:0] local_thermal_overload_q16, local_gamma_noise_target_q16, local_gamma_noise_state_q16;
    logic [N*32-1:0] local_gamma_drift_word, local_gamma_effective_word, local_thermal_node_factor_q30;
    logic [N*32-1:0] local_next_heat_q16, local_next_overload_q16, local_frequency_lag_q16;
    logic [N*32-1:0] local_next_gamma_drift_word, local_next_gamma_effective_word, phase_gamma_effective_word;
    logic [N*32-1:0] local_next_thermal_node_factor_q30, phase_thermal_node_factor_q30;
    logic [L*I-1:0] execution_request_cell_index, phase_request_cell_index;
    logic [L*2-1:0] execution_request_target, phase_request_target;
    logic [L-1:0] execution_request_valid, phase_request_valid, request_accept;
    logic [L-1:0] request_reject;
    logic [N*2-1:0] execution_target_bank, pending_route_out, phase_target_source;
    logic [N*2-1:0] registered_target_q, state_out;
    logic [9:0] invariant_flags;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [32-1:0] local_mean_heat_q16, local_mean_heat_peak_q16, local_maximum_heat_peak_q16;
    logic [(N-1)*32-1:0] group_coherence_q30;
    logic [D*32-1:0] level_mean_coherence_q30, level_min_coherence_q30, level_max_coherence_q30;
    logic [D*32-1:0] level_dispersion_q30;
  } observation_t;
  observation_t actual, expected;

  frp_m32_core #(.CELLS(N), .REQUEST_LANES(L), .COUNTER_BITS(32)) dut (
    .auto_target_enable, .clear_counters,
    .clk, .external_request_cell_index,
    .external_request_target, .external_request_valid,
    .external_target_bank, .frequency_load_q16,
    .gamma_effective_word, .phase_load,
    .phase_load_valid, .rst_n,
    .scheduler_mode, .thermal_node_factor_q30,
    .tick_enable, .accepted_cell_mask(actual.accepted_cell_mask),
    .accepted_change_mask(actual.accepted_change_mask), .accepted_changes(actual.accepted_changes),
    .accepted_target_capture_events_q(actual.accepted_target_capture_events_q), .actual_direct_events(actual.actual_direct_events),
    .capacity_exhausted(actual.capacity_exhausted), .capacity_remaining(actual.capacity_remaining),
    .cluster_coherence_q30(actual.cluster_coherence_q30), .coherence_capacity_q16(actual.coherence_capacity_q16),
    .coupling_field_q16(actual.coupling_field_q16), .execution_request_cell_index(actual.execution_request_cell_index),
    .execution_request_target(actual.execution_request_target), .execution_request_valid(actual.execution_request_valid),
    .execution_target_bank(actual.execution_target_bank), .frequency_current_q16(actual.frequency_current_q16),
    .global_coherence_q30(actual.global_coherence_q30), .invariant_flags(actual.invariant_flags),
    .neutral_routed_cell_mask(actual.neutral_routed_cell_mask), .neutral_routed_events(actual.neutral_routed_events),
    .normalized_cycle_cost_q16(actual.normalized_cycle_cost_q16), .organization_dispersion_q30(actual.organization_dispersion_q30),
    .pair_coherence_q30(actual.pair_coherence_q30), .peak_temperature_proxy_q16(actual.peak_temperature_proxy_q16),
    .pending_route_out(actual.pending_route_out), .phase_projection_q30(actual.phase_projection_q30),
    .phase_request_cell_index(actual.phase_request_cell_index), .phase_request_target(actual.phase_request_target),
    .phase_request_valid(actual.phase_request_valid), .phase_target_domain_valid(actual.phase_target_domain_valid),
    .phase_target_source(actual.phase_target_source), .phase_word_q(actual.phase_word_q),
    .pressure_q16(actual.pressure_q16), .prevented_direct_events(actual.prevented_direct_events),
    .queue_overflow_events(actual.queue_overflow_events), .registered_request_enable(actual.registered_request_enable),
    .registered_target_domain_valid(actual.registered_target_domain_valid), .registered_target_q(actual.registered_target_q),
    .registered_target_valid_q(actual.registered_target_valid_q), .rejected_target_capture_events_q(actual.rejected_target_capture_events_q),
    .request_accept(actual.request_accept), .request_reject(actual.request_reject),
    .requested_direct_events(actual.requested_direct_events), .reserved_state_events(actual.reserved_state_events),
    .scheduler_count_balance_q(actual.scheduler_count_balance_q), .scheduler_count_commit_q(actual.scheduler_count_commit_q),
    .scheduler_count_excite_q(actual.scheduler_count_excite_q), .scheduler_count_free_q(actual.scheduler_count_free_q),
    .scheduler_count_neutralize_q(actual.scheduler_count_neutralize_q), .scheduler_mode_q(actual.scheduler_mode_q),
    .scheduler_state_q(actual.scheduler_state_q), .stability_margin_q16(actual.stability_margin_q16),
    .stable(actual.stable), .state_out(actual.state_out),
    .switch_load_numerator(actual.switch_load_numerator), .target_capture_accepted(actual.target_capture_accepted),
    .target_capture_rejected(actual.target_capture_rejected), .temperature_proxy_q16(actual.temperature_proxy_q16),
    .thermal_sample_count_q(actual.thermal_sample_count_q), .ticks_recorded_q(actual.ticks_recorded_q),
    .local_gamma_enable, .local_thermal_enable, .gamma_update_valid, .gamma_targets_q16, .local_heat_q16(actual.local_heat_q16),
    .local_heat_peak_q16(actual.local_heat_peak_q16), .local_generated_power_q16(actual.local_generated_power_q16),
    .local_thermal_dissipation_q16(actual.local_thermal_dissipation_q16), .local_thermal_diffusion_q16(actual.local_thermal_diffusion_q16),
    .local_thermal_overload_q16(actual.local_thermal_overload_q16), .local_gamma_noise_target_q16(actual.local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(actual.local_gamma_noise_state_q16), .local_gamma_drift_word(actual.local_gamma_drift_word),
    .local_gamma_effective_word(actual.local_gamma_effective_word), .local_thermal_node_factor_q30(actual.local_thermal_node_factor_q30),
    .local_next_heat_q16(actual.local_next_heat_q16), .local_next_overload_q16(actual.local_next_overload_q16),
    .local_frequency_lag_q16(actual.local_frequency_lag_q16), .local_next_gamma_drift_word(actual.local_next_gamma_drift_word),
    .local_next_gamma_effective_word(actual.local_next_gamma_effective_word), .phase_gamma_effective_word(actual.phase_gamma_effective_word),
    .local_next_thermal_node_factor_q30(actual.local_next_thermal_node_factor_q30), .phase_thermal_node_factor_q30(actual.phase_thermal_node_factor_q30),
    .local_mean_heat_q16(actual.local_mean_heat_q16), .local_mean_heat_peak_q16(actual.local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(actual.local_maximum_heat_peak_q16), .group_coherence_q30(actual.group_coherence_q30),
    .level_mean_coherence_q30(actual.level_mean_coherence_q30), .level_min_coherence_q30(actual.level_min_coherence_q30),
    .level_max_coherence_q30(actual.level_max_coherence_q30), .level_dispersion_q30(actual.level_dispersion_q30),
    .local_coherence_compression_q30(), .local_effective_coherence_q30(), .local_coherence_capacity_q16(), .local_pressure_q16(), .local_stability_margin_q16(), .local_stable(), .local_previous_margin_q16(), .local_stability_valid_q(), .local_stability_sample_count_q(), .local_stability_raw_coherence_q30(), .local_stability_cluster_coherence_q30(), .local_stability_mean_heat_q16(), .local_stability_mean_overload_q16(), .local_stability_mean_lag_q16(), .local_stability_neutral_fraction_q30(), .local_stability_compression_arg_q16(), .local_stability_switch_load_q16()
  );
  logic [N*32-1:0] gold_phase = 0, gold_frequency = 0;
  logic [N*2-1:0] gold_target = 0, gold_state = 0, gold_pending = 0;
  bit gold_valid = 0;
  int unsigned gold_captures = 0, gold_ticks = 0, gold_counts[5];
  int gold_mode = 0, gold_position = 0;
  longint signed gold_temperature = 0, gold_peak = 0;
  int unsigned gold_samples = 0;
  logic [N*2-1:0] next_state, next_pending, source_word, selected_bank;
  logic [L-1:0] auto_valid, selected_valid, accept, reject;
  logic [L*I-1:0] auto_index, selected_index;
  logic [L*2-1:0] auto_target, selected_target;
  logic [N-1:0] writes, routes, accepted_cells, completions;
  int changes, candidate_routes, blocked_lanes;
  int signed reference_sine[4096];
  longint signed coupling[N];
  typedef struct packed {
    logic [N*32-1:0] heat;
    logic [N*32-1:0] peak;
    logic [N*32-1:0] power;
    logic [N*32-1:0] dissipation;
    logic [N*32-1:0] diffusion;
    logic [N*32-1:0] overload;
    logic [N*32-1:0] noise_target;
    logic [N*32-1:0] noise;
    logic [N*32-1:0] drift;
    logic [N*32-1:0] effective;
    logic [N*32-1:0] attenuation;
  } local_state_t;
  local_state_t local_q, local_d;
  logic [N*32-1:0] selected_gamma, selected_thermal;
  int signed exp_table[4096];
  longint signed mean_peak=3277, next_mean, groups[N-1], means[D];
  int profiles=0, source_hits[4], overload_hits=0, cooling_hits=0;
  int gamma_hits=0, attenuation_hits=0, load_ticks=0;
  logic [N-1:0] hot_cells=0, gamma_cells=0, attenuated_cells=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  int checks = 0, steps = 0, resets = 0;
  int dynamic_ticks = 0, held_edges = 0, loads = 0, clear_ticks = 0, clear_holds = 0;
  int first_legs = 0, second_legs = 0, pending_resets = 0;
  int automatic_ticks = 0, external_ticks = 0, target_lag_samples = 0;
  int state_feedback_samples = 0, switch_feedback_samples = 0;
  int heating_ticks = 0, cooling_ticks = 0, live_control_checks = 0;
  int dynamic_streak = 0, longest_streak = 0;
  int state_hits[5];
  logic [N-1:0] first_cells = 0, second_cells = 0;

  function automatic longint signed rounded(input longint signed n, d);
    /*verilator no_inline_task*/
    if (d <= 0) $fatal(1, "Invalid oracle denominator");
    return n < 0 ? -((-n+d/2)/d) : (n+d/2)/d;
  endfunction

  function automatic longint signed saturate(input longint signed n);
    /*verilator no_inline_task*/
    if (n > 2147483647) return 2147483647;
    if (n < -64'sd2147483648) return -64'sd2147483648;
    return n;
  endfunction

  function automatic longint signed product(input longint signed a, b, scale);
    /*verilator no_inline_task*/
    return saturate(rounded(a*b, scale));
  endfunction

  function automatic longint signed sine(input logic [31:0] phase);
    return reference_sine[phase >> 20];
  endfunction

  function automatic longint signed order(input int first, population);
    longint signed x, y, low, high, middle, answer, square;
    x = 0; y = 0;
    for (int i = first; i < first+population; i++) begin
      x += sine(gold_phase[32*i +: 32]+32'h40000000);
      y += sine(gold_phase[32*i +: 32]);
    end
    x = rounded(x, population); y = rounded(y, population);
    square = x*x+y*y; low = 0; high = 2147483647; answer = 0;
    while (low <= high) begin
      middle = (low+high)/2;
      if (middle*middle <= square) begin answer = middle; low = middle+1; end
      else high = middle-1;
    end
    return answer > 1073741824 ? 1073741824 : answer;
  endfunction

  // Split the conversion constant so signed-frequency endpoints do not
  // overflow 64-bit products. Retain only the final modulo-2^32 phase step.
  function automatic logic [31:0] phase_delta(input longint signed velocity);
    /*verilator no_inline_task*/
    longint signed magnitude, delta;
    magnitude = velocity < 0 ? -velocity : velocity;
    delta = magnitude*(64'sd44798133900177/64'sd4294967296)
      + rounded(magnitude*(64'sd44798133900177%64'sd4294967296), 64'sd4294967296);
    return 32'(velocity < 0 ? -delta : delta);
  endfunction

  function automatic logic [1:0] symbol(input int value);
    /*verilator no_inline_task*/
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1, "Invalid oracle symbol"); return 2'b10; end
    endcase
  endfunction

  function automatic int value(input logic [1:0] code);
    /*verilator no_inline_task*/
    case (code)
      2'b11: return -1;
      2'b00: return 0;
      2'b01: return 1;
      default: begin $fatal(1, "Reserved oracle symbol"); return 2; end
    endcase
  endfunction

  function automatic int cadence;
    case (gold_mode)
      0: return 0;
      1: return gold_position == 7 ? 2 : 1;
      2: return gold_position == 0 ? 3 : 4;
      default: begin $fatal(1, "Invalid oracle mode"); return 7; end
    endcase
  endfunction

  // Bits ordered by 3*(old+1)+(goal+1); no DUT transition helpers are used.
  function automatic bit allowed(input int old_value, goal);
    logic [8:0] admission;
    case (cadence())
      0: admission = 9'b111111111;
      1, 4: admission = 9'b111010111;
      2, 3: admission = 9'b100111001;
      default: admission = 0;
    endcase
    return admission[3*(old_value+1)+(goal+1)];
  endfunction

  function automatic longint signed shell(input int a,b, input bit thermal);
    /*verilator no_inline_task*/
    int level, span;
    level=0; span=2;
    while (a/span!=b/span) begin span*=2; level++; end
    case(N)
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

  function automatic longint signed root_floor(input longint signed square);
    /*verilator no_inline_task*/
    longint signed lo, hi, mid, result_value;
    lo=0; hi=2147483647; result_value=0;
    while(lo<=hi) begin
      mid=(lo+hi)/2;
      if(mid*mid<=square) begin result_value=mid; lo=mid+1; end
      else hi=mid-1;
    end
    return result_value;
  endfunction

  task automatic predict;
    int selected, cell_index, old_value, goal;
    logic [N-1:0] claimed;
    selected = 0; auto_valid = 0; auto_index = 0; auto_target = 0;
    for (int i = 0; i < N; i++) begin
      old_value = value(gold_state[2*i +: 2]); goal = value(gold_target[2*i +: 2]);
      if (auto_target_enable && gold_valid && selected < L &&
          gold_pending[2*i +: 2] == 0 && old_value != goal && allowed(old_value, goal)) begin
        auto_valid[selected] = 1; auto_index[I*selected +: I] = I'(i);
        auto_target[2*selected +: 2] = symbol(goal); selected++;
      end
    end
    selected_valid = auto_target_enable ? auto_valid : external_request_valid;
    selected_index = auto_target_enable ? auto_index : external_request_cell_index;
    selected_target = auto_target_enable ? auto_target : external_request_target;
    selected_bank = auto_target_enable ? gold_target : external_target_bank;
    next_state = gold_state; next_pending = gold_pending;
    accept = 0; reject = 0; claimed = 0; accepted_cells = 0;
    writes = 0; routes = 0; completions = 0; changes = 0; candidate_routes = 0; blocked_lanes = 0;
    if (tick_enable) begin
      // Retained routes own capacity before new lanes, in ascending cell order.
      for (int i = 0; i < N; i++)
        if (gold_pending[2*i +: 2] != 0 && allowed(0, value(gold_pending[2*i +: 2])) && changes < L) begin
          if (gold_state[2*i +: 2] != 0) $fatal(1, "Pending route did not start at zero");
          next_state[2*i +: 2] = gold_pending[2*i +: 2];
          next_pending[2*i +: 2] = 0; writes[i] = 1; completions[i] = 1; changes++;
        end
      for (int lane = 0; lane < L; lane++) begin
        cell_index = int'(selected_index[I*lane +: I]);
        old_value = value(gold_state[2*cell_index +: 2]);
        goal = value(selected_target[2*lane +: 2]);
        if (selected_valid[lane]) begin
          reject[lane] = 1;
          if (!claimed[cell_index] && gold_pending[2*cell_index +: 2] == 0 && allowed(old_value, goal)) begin
            claimed[cell_index] = 1;
            if (old_value * goal == -1) candidate_routes++;
            if (old_value == goal || changes < L) begin
              accept[lane] = 1; reject[lane] = 0; accepted_cells[cell_index] = 1;
              if (old_value != goal) begin
                writes[cell_index] = 1; changes++;
                if (old_value * goal == -1) begin
                  next_state[2*cell_index +: 2] = 0;
                  next_pending[2*cell_index +: 2] = symbol(goal); routes[cell_index] = 1;
                end else next_state[2*cell_index +: 2] = symbol(goal);
              end
            end else blocked_lanes++;
          end
        end
      end
    end
  endtask

  // All candidates use the same pre-edge retained model snapshot.
  task automatic local_candidate;
    longint signed f,target,selected,lag,total,power,diss,diff,heat,over;
    longint signed noise_target,noise,arg,thermal_gain,sum_heat,max_peak;
    logic [31:0] drift;
    local_d=local_q; sum_heat=0; max_peak=3277; next_mean=0;
    for(int i=0;i<N;i++) begin
      f=$signed(gold_frequency[32*i+:32]);
      target=65536+(gold_state[2*i+:2]!=0?3932:0)+(writes[i]?7864:0);
      selected=saturate(f+product(target-f,19661,65536));
      if(phase_load_valid) selected=$signed(frequency_load_q16[32*i+:32]);
      lag=target-selected; if(lag<0) lag=-lag;
      expected.local_frequency_lag_q16[32*i+:32]=32'(lag);
      heat=$signed(local_q.heat[32*i+:32]); total=0;
      for(int j=0;j<N;j++) if(j!=i)
        total+=product($signed(local_q.heat[32*j+:32])-heat,shell(i,j,1),1073741824);
      diff=product(2294,saturate(total),65536);
      power=saturate(118+(writes[i]?3408:0)+product(lag,1180,65536));
      diss=rounded(heat-3277,14);
      heat=saturate(heat+power-diss+diff); if(heat<3277) heat=3277;
      over=heat>14418?heat-14418:0;
      local_d.heat[32*i+:32]=32'(heat);
      local_d.peak[32*i+:32]=32'(heat>$signed(local_q.peak[32*i+:32])?
        heat:$signed(local_q.peak[32*i+:32]));
      local_d.power[32*i+:32]=32'(power);
      local_d.dissipation[32*i+:32]=32'(diss);
      local_d.diffusion[32*i+:32]=32'(diff);
      local_d.overload[32*i+:32]=32'(over);
      noise_target=gamma_update_valid?$signed(gamma_targets_q16[32*i+:32]):
        $signed(local_q.noise_target[32*i+:32]);
      noise=$signed(local_q.noise[32*i+:32]);
      noise=saturate(noise+product(noise_target-noise,9830,65536));
      thermal_gain=product(5243,over,65536);
      drift=phase_delta(product(thermal_gain,noise,65536));
      local_d.noise_target[32*i+:32]=32'(noise_target);
      local_d.noise[32*i+:32]=32'(noise);
      local_d.drift[32*i+:32]=drift;
      local_d.effective[32*i+:32]=32'h26666666+drift;
      arg=product(81920,over,65536);
      if(arg<0) arg=0; if(arg>524288) arg=524288;
      local_d.attenuation[32*i+:32]=32'(exp_table[int'(rounded(arg*4095,524288))]);
      sum_heat+=$signed(local_q.heat[32*i+:32]); next_mean+=heat;
      if($signed(local_q.peak[32*i+:32])>max_peak) max_peak=$signed(local_q.peak[32*i+:32]);
    end
    next_mean=rounded(next_mean,N);
    selected_gamma=local_gamma_enable?local_d.effective:gamma_effective_word;
    selected_thermal=local_thermal_enable?local_d.attenuation:thermal_node_factor_q30;
    expected.local_heat_q16=local_q.heat;
    expected.local_heat_peak_q16=local_q.peak;
    expected.local_generated_power_q16=local_q.power;
    expected.local_thermal_dissipation_q16=local_q.dissipation;
    expected.local_thermal_diffusion_q16=local_q.diffusion;
    expected.local_thermal_overload_q16=local_q.overload;
    expected.local_gamma_noise_target_q16=local_q.noise_target;
    expected.local_gamma_noise_state_q16=local_q.noise;
    expected.local_gamma_drift_word=local_q.drift;
    expected.local_gamma_effective_word=local_q.effective;
    expected.local_thermal_node_factor_q30=local_q.attenuation;
    expected.local_next_heat_q16=local_d.heat;
    expected.local_next_overload_q16=local_d.overload;
    expected.local_next_gamma_drift_word=local_d.drift;
    expected.local_next_gamma_effective_word=local_d.effective;
    expected.local_next_thermal_node_factor_q30=local_d.attenuation;
    expected.phase_gamma_effective_word=selected_gamma;
    expected.phase_thermal_node_factor_q30=selected_thermal;
    expected.local_mean_heat_q16=32'(rounded(sum_heat,N));
    expected.local_mean_heat_peak_q16=32'(mean_peak);
    expected.local_maximum_heat_peak_q16=32'(max_peak);
  endtask

  task automatic observe;
    longint signed total, factor, weight, term, projection;
    longint signed pairs, cluster0, cluster1, global_order, capacity, pressure;
    logic [31:0] relative_phase;
    int neutral_count;
    expected = '0;
    predict(); local_candidate();
    expected.phase_word_q = gold_phase;
    expected.frequency_current_q16 = gold_frequency;
    for (int i = 0; i < N; i++) begin
      projection = sine(gold_phase[32*i +: 32]);
      source_word[2*i +: 2] = symbol(projection > 354334802 ? 1 :
                                    projection < -354334802 ? -1 : 0);
      expected.phase_projection_q30[32*i +: 32] = 32'(projection);
      total = 0;
      for (int j = 0; j < N; j++) if (j != i) begin
        weight = shell(i,j,0);
        factor = product($signed(selected_thermal[32*i +: 32]),
                         $signed(selected_thermal[32*j +: 32]), 1073741824);
        factor = product(weight, factor, 1073741824);
        relative_phase = gold_phase[32*j +: 32]-gold_phase[32*i +: 32]
                         -selected_gamma[32*i +: 32];
        term = product(factor, sine(relative_phase), 1073741824);
        total += term;
      end
      coupling[i] = product(18350, rounded(saturate(total), 16384), 65536);
      expected.coupling_field_q16[32*i +: 32] = 32'(coupling[i]);
    end
    begin : coherence
      longint signed total_order,minimum,maximum,variance,delta;
      int base,count;
      base=0;
      for(int level=1;level<=D;level++) begin
        count=N/(1<<level); total_order=0; minimum=1073741824; maximum=0;
        for(int g=0;g<count;g++) begin
          groups[base+g]=order(g*(1<<level),1<<level);
          expected.group_coherence_q30[32*(base+g)+:32]=32'(groups[base+g]);
          total_order+=groups[base+g];
          if(groups[base+g]<minimum) minimum=groups[base+g];
          if(groups[base+g]>maximum) maximum=groups[base+g];
        end
        means[level-1]=rounded(total_order,count); variance=0;
        for(int g=0;g<count;g++) begin
          delta=groups[base+g]-means[level-1]; variance+=delta*delta;
        end
        expected.level_mean_coherence_q30[32*(level-1)+:32]=32'(means[level-1]);
        expected.level_min_coherence_q30[32*(level-1)+:32]=32'(minimum);
        expected.level_max_coherence_q30[32*(level-1)+:32]=32'(maximum);
        expected.level_dispersion_q30[32*(level-1)+:32]=32'(root_floor(variance/count));
        base+=count;
      end
      global_order=groups[N-2]; cluster0=means[1]; cluster1=means[1];
      expected.pair_coherence_q30=32'(means[0]);
      expected.cluster_coherence_q30=32'(means[1]);
      expected.global_coherence_q30=32'(global_order);
      delta=groups[N/2]-groups[N/2+1]; if(delta<0) delta=-delta;
      expected.organization_dispersion_q30=N==8?32'(rounded(delta,2)):
        expected.level_dispersion_q30[32+:32];
    end
    expected.phase_target_source = source_word;
    expected.registered_target_q = gold_target;
    expected.registered_target_valid_q = gold_valid;
    expected.phase_target_domain_valid = 1;
    expected.registered_target_domain_valid = 1;
    expected.target_capture_accepted = tick_enable;
    expected.accepted_target_capture_events_q = gold_captures;
    expected.registered_request_enable = auto_target_enable && gold_valid;
    expected.phase_request_valid = auto_valid;
    expected.phase_request_cell_index = auto_index;
    expected.phase_request_target = auto_target;
    expected.execution_request_valid = selected_valid;
    expected.execution_request_cell_index = selected_index;
    expected.execution_request_target = selected_target;
    expected.execution_target_bank = selected_bank;
    expected.state_out = gold_state;
    expected.pending_route_out = gold_pending;
    expected.scheduler_mode_q = 2'(gold_mode);
    expected.scheduler_state_q = 3'(cadence());
    expected.ticks_recorded_q = gold_ticks;
    expected.scheduler_count_free_q = gold_counts[0];
    expected.scheduler_count_balance_q = gold_counts[1];
    expected.scheduler_count_commit_q = gold_counts[2];
    expected.scheduler_count_excite_q = gold_counts[3];
    expected.scheduler_count_neutralize_q = gold_counts[4];
    expected.request_accept = accept; expected.request_reject = reject;
    expected.accepted_cell_mask = accepted_cells;
    expected.neutral_routed_cell_mask = routes; expected.accepted_change_mask = writes;
    expected.accepted_changes = 32'(changes);
    expected.capacity_remaining = 32'(L-changes);
    expected.capacity_exhausted = changes == L;
    expected.switch_load_numerator = 32'(changes);
    expected.requested_direct_events = 32'(candidate_routes);
    expected.prevented_direct_events = 32'(candidate_routes);
    expected.neutral_routed_events = 32'(candidate_routes);
    // Admission is combinational during reset, but retained writeback is
    // suppressed. Bit 5 explicitly reports this candidate/writeback mismatch.
    expected.invariant_flags = !rst_n && changes != 0 ? 10'h3df : 10'h3ff;
    expected.normalized_cycle_cost_q16 = 32'(changes*(65536/N));
    expected.temperature_proxy_q16 = 32'(gold_temperature);
    expected.peak_temperature_proxy_q16 = 32'(gold_peak);
    expected.thermal_sample_count_q = gold_samples;
    neutral_count = 0;
    for (int i = 0; i < N; i++) if (gold_state[2*i +: 2] == 0) neutral_count++;
    capacity = saturate(53740 + product(22282, global_order, 1073741824)
      + product(10486, rounded(cluster0+cluster1, 2), 1073741824)
      + product(5243, rounded(neutral_count*64'sd1073741824,N), 1073741824));
    pressure = saturate(gold_temperature+changes*(65536/N));
    expected.coherence_capacity_q16 = 32'(capacity);
    expected.pressure_q16 = 32'(pressure);
    expected.stability_margin_q16 = 32'(capacity-pressure);
    expected.stable = capacity > pressure;
  endtask

  task automatic check;
    localparam int WORDS=($bits(observation_t)+31)/32;
    logic [WORDS*32-1:0] got,want;
    observe(); got=(WORDS*32)'(actual); want=(WORDS*32)'(expected);
    for(int w=0;w<WORDS;w++) begin
      checks++;
      if(got[w*32+:32]!==want[w*32+:32])
        $fatal(1,"FEEDBACK cells=%0d step=%0d word=%0d got=%h expected=%h",
          N,steps,w,got[w*32+:32],want[w*32+:32]);
      signature=(signature^{32'd0,want[w*32+:32]})*64'h100000001b3;
    end
  endtask

  task automatic step(input bit enabled, input bit clear = 0);
    longint signed frequency, target, next_frequency, push, next_temperature;
    int signed velocity;
    logic [N*32-1:0] new_phase, new_frequency;
    tick_enable = enabled; clear_counters = clear;
    #1; check();
    new_phase = gold_phase; new_frequency = gold_frequency;
    if (phase_load_valid) begin
      new_phase = phase_load; new_frequency = frequency_load_q16;
      loads++; dynamic_streak = 0;
    end else if (enabled) begin
      dynamic_ticks++; dynamic_streak++;
      if (dynamic_streak > longest_streak) longest_streak = dynamic_streak;
      for (int i = 0; i < N; i++) begin
        frequency = $signed(gold_frequency[32*i +: 32]);
        target = 65536 + (gold_state[2*i +: 2] != 0 ? 3932 : 0) + (writes[i] ? 7864 : 0);
        next_frequency = saturate(frequency+saturate(rounded((target-frequency)*19661, 65536)));
        push = cadence() == 2 ? 655 : cadence() == 3 ? 393 : 197;
        velocity = 32'(product(3932, next_frequency, 65536)+push+coupling[i]);
        new_phase[32*i +: 32] = gold_phase[32*i +: 32]+phase_delta(velocity);
        new_frequency[32*i +: 32] = 32'(next_frequency);
        if (gold_state[2*i +: 2] != 0) state_feedback_samples++;
        if (writes[i]) switch_feedback_samples++;
      end
    end
    if (clear) begin
      gold_temperature = 0; gold_peak = 0; gold_samples = 0;
      gold_captures = 0; gold_ticks = 0;
      foreach (gold_counts[i]) gold_counts[i] = 0;
      if (enabled) clear_ticks++; else clear_holds++;
    end else if (enabled) begin
      next_temperature = saturate(product(gold_temperature, 1020054733, 1073741824)
        + product(changes*(65536/N), 10737418, 1073741824));
      if (next_temperature > gold_temperature) heating_ticks++;
      if (next_temperature < gold_temperature) cooling_ticks++;
      gold_temperature = next_temperature;
      if (gold_temperature > gold_peak) gold_peak = gold_temperature;
      gold_samples++; gold_captures++;
    end
    if (enabled) begin
      source_hits[2*int'(local_thermal_enable)+int'(local_gamma_enable)]++;
      for(int i=0;i<N;i++) begin
        if(local_d.overload[32*i+:32]!=0) begin overload_hits++; hot_cells[i]=1; end
        if($signed(local_d.heat[32*i+:32])<$signed(local_q.heat[32*i+:32])) cooling_hits++;
        if(local_d.drift[32*i+:32]!=0) begin gamma_hits++; gamma_cells[i]=1; end
        if(local_d.attenuation[32*i+:32]!=32'h40000000) begin
          attenuation_hits++; attenuated_cells[i]=1;
        end
      end
      local_q=local_d; if(next_mean>mean_peak) mean_peak=next_mean;
      if(phase_load_valid) load_ticks++;
      state_hits[cadence()]++; gold_counts[cadence()]++; gold_ticks++;
      gold_position = (gold_position+1)%8;
      if (auto_target_enable) automatic_ticks++; else external_ticks++;
      if (source_word != gold_target) target_lag_samples++;
      gold_target = source_word; gold_valid = 1;
      first_legs += $countones(routes); second_legs += $countones(completions);
      first_cells |= routes; second_cells |= completions;
      for (int i = 0; i < N; i++)
        if (value(gold_state[2*i +: 2])*value(next_state[2*i +: 2]) == -1)
          $fatal(1, "Oracle attempted direct opposite-polarity write");
    end else held_edges++;
    gold_phase = new_phase; gold_frequency = new_frequency;
    gold_state = next_state; gold_pending = next_pending;
    gold_mode = int'(scheduler_mode);
    clk = 1; #1; steps++; check();
    clk = 0; #1; check();
  endtask

  task automatic reset_core(input bit keep_controls = 0);
    if (!keep_controls) begin
      tick_enable = 0; clear_counters = 0; phase_load_valid = 0;
      local_gamma_enable=0; local_thermal_enable=0;
      gamma_update_valid=0; gamma_targets_q16=0;
      auto_target_enable = 0; scheduler_mode = FRP_MODE_FREE;
      external_request_valid = 0; external_request_cell_index = 0;
      external_request_target = 0; external_target_bank = 0;
      phase_load = 0; frequency_load_q16 = 0;
      gamma_effective_word = {N{32'h26666666}};
      thermal_node_factor_q30 = {N{32'h40000000}};
    end
    if (gold_pending != 0) pending_resets++;
    #1; rst_n = 0;
    local_q='0; mean_peak=3277;
    local_q.heat={N{32'd3277}}; local_q.peak={N{32'd3277}};
    local_q.effective={N{32'h26666666}}; local_q.attenuation={N{32'h40000000}};
    gold_target = 0; gold_valid = 0; gold_state = 0; gold_pending = 0;
    gold_captures = 0; gold_ticks = 0; gold_mode = 0; gold_position = 0;
    gold_temperature = 0; gold_peak = 0; gold_samples = 0; dynamic_streak = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    for (int i = 0; i < N; i++) begin
      gold_phase[32*i +: 32] = 32'(64'(i)*(64'd4294967296/N));
      gold_frequency[32*i +: 32] = 32'd65536;
    end
    #1; check(); clk = 1; #1; check(); clk = 0; #1; check();
    rst_n = 1; #1; check(); resets++;
  endtask

  task automatic lane(input int lane_index, cell_index, goal);
    external_request_valid[lane_index] = 1;
    external_request_cell_index[I*lane_index +: I] = I'(cell_index);
    external_request_target[2*lane_index +: 2] = symbol(goal);
    external_target_bank[2*cell_index +: 2] = symbol(goal);
  endtask

  int unsigned rng=32'h60c1a57e;
  function automatic logic [31:0] random_word;
    rng^=rng<<13; rng^=rng>>17; rng^=rng<<5;
    return rng;
  endfunction

  initial begin : qualification
    real sample;
    logic [31:0] r;
    int before_dynamic;
    if((N!=8 && N!=16 && N!=32) || L!=N/4 || I!=$clog2(N) || D!=$clog2(N))
      $fatal(1,"Unsupported feedback configuration");
    for(int i=0;i<4096;i++) begin
      sample=$sin(6.283185307179586476925286766559*i/4096.0)*1073741824.0;
      reference_sine[i]=$rtoi(sample<0?sample-0.5:sample+0.5);
      exp_table[i]=$rtoi($exp(-8.0*real'(i)/4095.0)*1073741824.0+0.5);
    end
    if(reference_sine[1024]!=1073741824 || reference_sine[3072]!=-1073741824 ||
       exp_table[0]!=1073741824 || exp_table[4095]!=360200 ||
       rounded(-3,2)!=-2 || phase_delta(-65536)!=32'hd7419f24)
      $fatal(1,"Reference arithmetic self-check");
    foreach(state_hits[i]) state_hits[i]=0;
    foreach(source_hits[i]) source_hits[i]=0;
    foreach(gold_counts[i]) gold_counts[i]=0;

    // Every cell traverses both active-zero routes, including a held edge,
    // conflicting input, clear, completion and reset with pending work.
    for(int c=0;c<N;c++) for(int sign_index=0;sign_index<2;sign_index++) begin
      reset_core(); local_gamma_enable=1; local_thermal_enable=1;
      gamma_update_valid=1; gamma_targets_q16={N{32'd65536}};
      lane(0,c,sign_index==0?-1:1); step(1);
      lane(0,c,sign_index==0?1:-1); step(1);
      if(gold_state[2*c+:2]!=0 || gold_pending[2*c+:2]==0)
        $fatal(1,"Directed route did not reach active zero");
      lane(0,c,sign_index==0?-1:1); step(0,1); step(1);
      if(gold_pending!=0) $fatal(1,"Directed route did not complete");
      step(1); reset_core(1);
    end

    // Cross all four source selections with all three scheduler modes.
    // Noise changes while held, frequency loads and live source handovers
    // exercise candidate selection separately from retained thermal history.
    for(int source=0;source<4;source++) for(int mode=0;mode<3;mode++) begin
      reset_core(); local_gamma_enable=1'(source); local_thermal_enable=1'(source>>1);
      scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      for(int i=0;i<N;i++) begin
        phase_load[32*i+:32]=random_word();
        frequency_load_q16[32*i+:32]=i%2==0?32'h7fffffff:32'h80000000;
        gamma_targets_q16[32*i+:32]=i%2==0?32'h00010000:32'hffff0000;
      end
      gamma_update_valid=1; phase_load_valid=1; step(0); step(1);
      phase_load_valid=0; before_dynamic=dynamic_ticks;
      for(int n=0;n<1024;n++) begin
        r=random_word(); auto_target_enable=n<256 || n%5!=0;
        external_request_valid=0; external_request_cell_index=0;
        external_request_target=0; external_target_bank=0;
        for(int k=0;k<L;k++) begin
          r=random_word(); lane(k,int'(r%N),int'((r>>8)%3)-1);
          external_request_valid[k]=r[31];
        end
        gamma_update_valid=n%13==0;
        if(gamma_update_valid) for(int i=0;i<N;i++) begin
          r=random_word();
          case((n/13)%4)
            0:gamma_targets_q16[32*i+:32]=32'h7fffffff;
            1:gamma_targets_q16[32*i+:32]=32'h80000000;
            2:gamma_targets_q16[32*i+:32]=32'($signed(r)>>>14);
            default:gamma_targets_q16[32*i+:32]=0;
          endcase
        end
        if(n%17==0) for(int i=0;i<N;i++) begin
          gamma_effective_word[32*i+:32]=random_word();
          thermal_node_factor_q30[32*i+:32]=32'((i+n/17)%5)*32'h10000000;
        end
        if(n%31==0) step(0,n%62==0);
        if(n%127==0) begin
          // A handover without an edge must change only combinational outputs.
          local_gamma_enable=~local_gamma_enable;
          local_thermal_enable=~local_thermal_enable; #1; check();
          local_gamma_enable=~local_gamma_enable;
          local_thermal_enable=~local_thermal_enable; #1; check();
          live_control_checks+=2;
        end
        if(n==512) begin
          phase_load_valid=1;
          for(int i=0;i<N;i++) begin
            phase_load[32*i+:32]=random_word();
            frequency_load_q16[32*i+:32]=32'((i+1)*65536);
          end
          step(0,1); phase_load_valid=0;
        end
        step(1,n%67==0);
      end
      if(dynamic_ticks-before_dynamic!=1024) $fatal(1,"Incomplete continuous profile");
      profiles++;
    end
    if(profiles!=12 || dynamic_ticks<12288 || longest_streak<512 ||
       first_cells!={N{1'b1}} || second_cells!={N{1'b1}} || pending_resets<2*N ||
       hot_cells!={N{1'b1}} || gamma_cells!={N{1'b1}} || attenuated_cells!={N{1'b1}} ||
       cooling_hits==0 || load_ticks!=12 || held_edges==0 || clear_ticks==0 || clear_holds==0 ||
       target_lag_samples==0 || state_feedback_samples==0 || switch_feedback_samples==0)
      $fatal(1,"Feedback coverage incomplete cells=%0d",N);
    foreach(state_hits[i]) if(state_hits[i]==0) $fatal(1,"Missing scheduler state %0d",i);
    foreach(source_hits[i]) if(source_hits[i]<1024) $fatal(1,"Missing source mode %0d",i);
    $display("PASS FEEDBACK cells=%0d profiles=%0d steps=%0d checks=%0d resets=%0d signature=%016h",
      N,profiles,steps,checks,resets,signature);
    $display("FEEDBACK_EVENTS cells=%0d routes=%0d completions=%0d overload=%0d gamma=%0d attenuation=%0d cooling=%0d handovers=%0d",
      N,first_legs,second_legs,overload_hits,gamma_hits,attenuation_hits,cooling_hits,live_control_checks);
    done=1;
  end
endmodule

module frp_m32_feedback_multicell_tb #(parameter int CELLS=8);
  wire done;
  frp_m32_feedback_multicell_checker #(.N(CELLS)) checker_instance(.done);
  initial begin
    wait(done); #1;
    $display("PASS FEEDBACK_ALL cells=%0d",CELLS);
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1,"Feedback regression timeout cells=%0d",CELLS);
  end
endmodule

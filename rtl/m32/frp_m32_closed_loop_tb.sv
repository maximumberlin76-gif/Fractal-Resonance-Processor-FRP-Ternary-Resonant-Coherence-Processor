// SPDX-License-Identifier: Apache-2.0
// Continuous eight-cell M32 feedback qualification, free / 7/1 / 1/7.
// Independent integer oracle; no DUT helpers or internal signals are read.
// Sine entries are independently rounded from mathematical sine. All later
// arithmetic is integer, including square roots and wide phase conversion.
// Every observation compares all 59 public outputs (2075 bits).
// This checks the implemented fixed-point contract, not model v0.9.3,
// physical temperature, power, or global RTL coverage closure.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_closed_loop_tb;
  import frp_m31_pkg::*;
  logic auto_target_enable = 0;
  logic clear_counters = 0;
  logic clk = 0;
  logic [5:0] external_request_cell_index = 0;
  logic [3:0] external_request_target = 0;
  logic [1:0] external_request_valid = 0;
  logic [15:0] external_target_bank = 0;
  logic [255:0] frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0;
  logic [255:0] phase_load = 0;
  logic phase_load_valid = 0;
  logic rst_n = 1;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  logic [255:0] thermal_node_factor_q30 = 0;
  logic tick_enable = 0;

  typedef struct packed {
    logic [7:0] accepted_cell_mask;
    logic [7:0] accepted_change_mask;
    logic [31:0] accepted_changes;
    logic [31:0] accepted_target_capture_events_q;
    logic [31:0] actual_direct_events;
    logic capacity_exhausted;
    logic [31:0] capacity_remaining;
    logic [31:0] cluster_coherence_q30;
    logic [31:0] coherence_capacity_q16;
    logic [255:0] coupling_field_q16;
    logic [5:0] execution_request_cell_index;
    logic [3:0] execution_request_target;
    logic [1:0] execution_request_valid;
    logic [15:0] execution_target_bank;
    logic [255:0] frequency_current_q16;
    logic [31:0] global_coherence_q30;
    logic [9:0] invariant_flags;
    logic [7:0] neutral_routed_cell_mask;
    logic [31:0] neutral_routed_events;
    logic [31:0] normalized_cycle_cost_q16;
    logic [31:0] organization_dispersion_q30;
    logic [31:0] pair_coherence_q30;
    logic [31:0] peak_temperature_proxy_q16;
    logic [15:0] pending_route_out;
    logic [255:0] phase_projection_q30;
    logic [5:0] phase_request_cell_index;
    logic [3:0] phase_request_target;
    logic [1:0] phase_request_valid;
    logic phase_target_domain_valid;
    logic [15:0] phase_target_source;
    logic [255:0] phase_word_q;
    logic [31:0] pressure_q16;
    logic [31:0] prevented_direct_events;
    logic [31:0] queue_overflow_events;
    logic registered_request_enable;
    logic registered_target_domain_valid;
    logic [15:0] registered_target_q;
    logic registered_target_valid_q;
    logic [31:0] rejected_target_capture_events_q;
    logic [1:0] request_accept;
    logic [1:0] request_reject;
    logic [31:0] requested_direct_events;
    logic [31:0] reserved_state_events;
    logic [31:0] scheduler_count_balance_q;
    logic [31:0] scheduler_count_commit_q;
    logic [31:0] scheduler_count_excite_q;
    logic [31:0] scheduler_count_free_q;
    logic [31:0] scheduler_count_neutralize_q;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [31:0] stability_margin_q16;
    logic stable;
    logic [15:0] state_out;
    logic [31:0] switch_load_numerator;
    logic target_capture_accepted;
    logic target_capture_rejected;
    logic [31:0] temperature_proxy_q16;
    logic [31:0] thermal_sample_count_q;
    logic [31:0] ticks_recorded_q;
  } observation_t;
  observation_t actual, expected;

  frp_m32_core #(.CELLS(8), .REQUEST_LANES(2), .COUNTER_BITS(32)) dut (
    .auto_target_enable,
    .clear_counters,
    .clk,
    .external_request_cell_index,
    .external_request_target,
    .external_request_valid,
    .external_target_bank,
    .frequency_load_q16,
    .gamma_effective_word,
    .phase_load,
    .phase_load_valid,
    .rst_n,
    .scheduler_mode,
    .thermal_node_factor_q30,
    .tick_enable,
    .accepted_cell_mask(actual.accepted_cell_mask),
    .accepted_change_mask(actual.accepted_change_mask),
    .accepted_changes(actual.accepted_changes),
    .accepted_target_capture_events_q(actual.accepted_target_capture_events_q),
    .actual_direct_events(actual.actual_direct_events),
    .capacity_exhausted(actual.capacity_exhausted),
    .capacity_remaining(actual.capacity_remaining),
    .cluster_coherence_q30(actual.cluster_coherence_q30),
    .coherence_capacity_q16(actual.coherence_capacity_q16),
    .coupling_field_q16(actual.coupling_field_q16),
    .execution_request_cell_index(actual.execution_request_cell_index),
    .execution_request_target(actual.execution_request_target),
    .execution_request_valid(actual.execution_request_valid),
    .execution_target_bank(actual.execution_target_bank),
    .frequency_current_q16(actual.frequency_current_q16),
    .global_coherence_q30(actual.global_coherence_q30),
    .invariant_flags(actual.invariant_flags),
    .neutral_routed_cell_mask(actual.neutral_routed_cell_mask),
    .neutral_routed_events(actual.neutral_routed_events),
    .normalized_cycle_cost_q16(actual.normalized_cycle_cost_q16),
    .organization_dispersion_q30(actual.organization_dispersion_q30),
    .pair_coherence_q30(actual.pair_coherence_q30),
    .peak_temperature_proxy_q16(actual.peak_temperature_proxy_q16),
    .pending_route_out(actual.pending_route_out),
    .phase_projection_q30(actual.phase_projection_q30),
    .phase_request_cell_index(actual.phase_request_cell_index),
    .phase_request_target(actual.phase_request_target),
    .phase_request_valid(actual.phase_request_valid),
    .phase_target_domain_valid(actual.phase_target_domain_valid),
    .phase_target_source(actual.phase_target_source),
    .phase_word_q(actual.phase_word_q),
    .pressure_q16(actual.pressure_q16),
    .prevented_direct_events(actual.prevented_direct_events),
    .queue_overflow_events(actual.queue_overflow_events),
    .registered_request_enable(actual.registered_request_enable),
    .registered_target_domain_valid(actual.registered_target_domain_valid),
    .registered_target_q(actual.registered_target_q),
    .registered_target_valid_q(actual.registered_target_valid_q),
    .rejected_target_capture_events_q(actual.rejected_target_capture_events_q),
    .request_accept(actual.request_accept),
    .request_reject(actual.request_reject),
    .requested_direct_events(actual.requested_direct_events),
    .reserved_state_events(actual.reserved_state_events),
    .scheduler_count_balance_q(actual.scheduler_count_balance_q),
    .scheduler_count_commit_q(actual.scheduler_count_commit_q),
    .scheduler_count_excite_q(actual.scheduler_count_excite_q),
    .scheduler_count_free_q(actual.scheduler_count_free_q),
    .scheduler_count_neutralize_q(actual.scheduler_count_neutralize_q),
    .scheduler_mode_q(actual.scheduler_mode_q),
    .scheduler_state_q(actual.scheduler_state_q),
    .stability_margin_q16(actual.stability_margin_q16),
    .stable(actual.stable),
    .state_out(actual.state_out),
    .switch_load_numerator(actual.switch_load_numerator),
    .target_capture_accepted(actual.target_capture_accepted),
    .target_capture_rejected(actual.target_capture_rejected),
    .temperature_proxy_q16(actual.temperature_proxy_q16),
    .thermal_sample_count_q(actual.thermal_sample_count_q),
    .ticks_recorded_q(actual.ticks_recorded_q)
  );

  logic [255:0] gold_phase = 0, gold_frequency = 0;
  logic [15:0] gold_target = 0, gold_state = 0, gold_pending = 0;
  bit gold_valid = 0;
  int unsigned gold_captures = 0, gold_ticks = 0, gold_counts[5];
  int gold_mode = 0, gold_position = 0;
  longint signed gold_temperature = 0, gold_peak = 0;
  int unsigned gold_samples = 0;
  logic [15:0] next_state, next_pending, source_word, selected_bank;
  logic [1:0] auto_valid, selected_valid, accept, reject;
  logic [5:0] auto_index, selected_index;
  logic [3:0] auto_target, selected_target;
  logic [7:0] writes, routes, accepted_cells, completions;
  int changes, candidate_routes, blocked_lanes;
  int signed reference_sine[4096];
  longint signed coupling[8];
  int checks = 0, steps = 0, resets = 0, profiles = 0;
  int dynamic_ticks = 0, held_edges = 0, loads = 0, clear_ticks = 0, clear_holds = 0;
  int first_legs = 0, second_legs = 0, pending_resets = 0;
  int automatic_ticks = 0, external_ticks = 0, target_lag_samples = 0;
  int state_feedback_samples = 0, switch_feedback_samples = 0;
  int heating_ticks = 0, cooling_ticks = 0, live_control_checks = 0;
  int dynamic_streak = 0, longest_streak = 0;
  int state_hits[5];
  logic [7:0] first_cells = 0, second_cells = 0;

  function automatic longint signed rounded(input longint signed n, d);
    if (d <= 0) $fatal(1, "Invalid oracle denominator");
    return n < 0 ? -((-n+d/2)/d) : (n+d/2)/d;
  endfunction

  function automatic longint signed saturate(input longint signed n);
    if (n > 2147483647) return 2147483647;
    if (n < -64'sd2147483648) return -64'sd2147483648;
    return n;
  endfunction

  function automatic longint signed product(input longint signed a, b, scale);
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
    longint signed magnitude, delta;
    magnitude = velocity < 0 ? -velocity : velocity;
    delta = magnitude*(64'sd44798133900177/64'sd4294967296)
      + rounded(magnitude*(64'sd44798133900177%64'sd4294967296), 64'sd4294967296);
    return 32'(velocity < 0 ? -delta : delta);
  endfunction

  function automatic logic [1:0] symbol(input int value);
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1, "Invalid oracle symbol"); return 2'b10; end
    endcase
  endfunction

  function automatic int value(input logic [1:0] code);
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

  task automatic predict;
    int selected, cell_index, old_value, goal;
    logic [7:0] claimed;
    selected = 0; auto_valid = 0; auto_index = 0; auto_target = 0;
    for (int i = 0; i < 8; i++) begin
      old_value = value(gold_state[2*i +: 2]); goal = value(gold_target[2*i +: 2]);
      if (auto_target_enable && gold_valid && selected < 2 &&
          gold_pending[2*i +: 2] == 0 && old_value != goal && allowed(old_value, goal)) begin
        auto_valid[selected] = 1; auto_index[3*selected +: 3] = 3'(i);
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
      for (int i = 0; i < 8; i++)
        if (gold_pending[2*i +: 2] != 0 && allowed(0, value(gold_pending[2*i +: 2])) && changes < 2) begin
          if (gold_state[2*i +: 2] != 0) $fatal(1, "Pending route did not start at zero");
          next_state[2*i +: 2] = gold_pending[2*i +: 2];
          next_pending[2*i +: 2] = 0; writes[i] = 1; completions[i] = 1; changes++;
        end
      for (int lane = 0; lane < 2; lane++) begin
        cell_index = int'(selected_index[3*lane +: 3]);
        old_value = value(gold_state[2*cell_index +: 2]);
        goal = value(selected_target[2*lane +: 2]);
        if (selected_valid[lane]) begin
          reject[lane] = 1;
          if (!claimed[cell_index] && gold_pending[2*cell_index +: 2] == 0 && allowed(old_value, goal)) begin
            claimed[cell_index] = 1;
            if (old_value * goal == -1) candidate_routes++;
            if (old_value == goal || changes < 2) begin
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

  task automatic observe;
    longint signed total, factor, weight, term, projection;
    longint signed pairs, cluster0, cluster1, global_order, capacity, pressure;
    logic [31:0] relative_phase;
    int neutral_count;
    expected = '0;
    expected.phase_word_q = gold_phase;
    expected.frequency_current_q16 = gold_frequency;
    for (int i = 0; i < 8; i++) begin
      projection = sine(gold_phase[32*i +: 32]);
      source_word[2*i +: 2] = symbol(projection > 354334802 ? 1 :
                                    projection < -354334802 ? -1 : 0);
      expected.phase_projection_q30[32*i +: 32] = 32'(projection);
      total = 0;
      for (int j = 0; j < 8; j++) if (j != i) begin
        weight = i/2 == j/2 ? 516461574 : i/4 == j/4 ? 158959695 : 59840215;
        factor = product($signed(thermal_node_factor_q30[32*i +: 32]),
                         $signed(thermal_node_factor_q30[32*j +: 32]), 1073741824);
        factor = product(weight, factor, 1073741824);
        relative_phase = gold_phase[32*j +: 32]-gold_phase[32*i +: 32]
                         -gamma_effective_word[32*i +: 32];
        term = product(factor, sine(relative_phase), 1073741824);
        total += term;
      end
      coupling[i] = product(18350, rounded(saturate(total), 16384), 65536);
      expected.coupling_field_q16[32*i +: 32] = 32'(coupling[i]);
    end
    pairs = 0;
    for (int i = 0; i < 8; i += 2) pairs += order(i, 2);
    cluster0 = order(0, 4); cluster1 = order(4, 4); global_order = order(0, 8);
    expected.pair_coherence_q30 = 32'(rounded(pairs, 4));
    expected.cluster_coherence_q30 = 32'(rounded(cluster0+cluster1, 2));
    expected.global_coherence_q30 = 32'(global_order);
    expected.organization_dispersion_q30 = 32'(rounded(
      cluster0 > cluster1 ? cluster0-cluster1 : cluster1-cluster0, 2));
    predict();
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
    expected.capacity_remaining = 32'(2-changes);
    expected.capacity_exhausted = changes == 2;
    expected.switch_load_numerator = 32'(changes);
    expected.requested_direct_events = 32'(candidate_routes);
    expected.prevented_direct_events = 32'(candidate_routes);
    expected.neutral_routed_events = 32'(candidate_routes);
    // Admission is combinational during reset, but retained writeback is
    // suppressed. Bit 5 explicitly reports this candidate/writeback mismatch.
    expected.invariant_flags = !rst_n && changes != 0 ? 10'h3df : 10'h3ff;
    expected.normalized_cycle_cost_q16 = 32'(changes*8192);
    expected.temperature_proxy_q16 = 32'(gold_temperature);
    expected.peak_temperature_proxy_q16 = 32'(gold_peak);
    expected.thermal_sample_count_q = gold_samples;
    neutral_count = 0;
    for (int i = 0; i < 8; i++) if (gold_state[2*i +: 2] == 0) neutral_count++;
    capacity = saturate(53740 + product(22282, global_order, 1073741824)
      + product(10486, rounded(cluster0+cluster1, 2), 1073741824)
      + product(5243, neutral_count*64'sd134217728, 1073741824));
    pressure = saturate(gold_temperature+changes*8192);
    expected.coherence_capacity_q16 = 32'(capacity);
    expected.pressure_q16 = 32'(pressure);
    expected.stability_margin_q16 = 32'(capacity-pressure);
    expected.stable = capacity > pressure;
  endtask

  task automatic check;
    observe(); checks++;
    if (actual !== expected) begin
      $display("M32 closed-loop mismatch step=%0d mode=%0d cadence=%0d", steps, gold_mode, cadence());
      if (actual.accepted_cell_mask !== expected.accepted_cell_mask)
        $display("accepted_cell_mask actual=%h expected=%h", actual.accepted_cell_mask, expected.accepted_cell_mask);
      if (actual.accepted_change_mask !== expected.accepted_change_mask)
        $display("accepted_change_mask actual=%h expected=%h", actual.accepted_change_mask, expected.accepted_change_mask);
      if (actual.accepted_changes !== expected.accepted_changes)
        $display("accepted_changes actual=%h expected=%h", actual.accepted_changes, expected.accepted_changes);
      if (actual.accepted_target_capture_events_q !== expected.accepted_target_capture_events_q)
        $display("accepted_target_capture_events_q actual=%h expected=%h", actual.accepted_target_capture_events_q, expected.accepted_target_capture_events_q);
      if (actual.actual_direct_events !== expected.actual_direct_events)
        $display("actual_direct_events actual=%h expected=%h", actual.actual_direct_events, expected.actual_direct_events);
      if (actual.capacity_exhausted !== expected.capacity_exhausted)
        $display("capacity_exhausted actual=%h expected=%h", actual.capacity_exhausted, expected.capacity_exhausted);
      if (actual.capacity_remaining !== expected.capacity_remaining)
        $display("capacity_remaining actual=%h expected=%h", actual.capacity_remaining, expected.capacity_remaining);
      if (actual.cluster_coherence_q30 !== expected.cluster_coherence_q30)
        $display("cluster_coherence_q30 actual=%h expected=%h", actual.cluster_coherence_q30, expected.cluster_coherence_q30);
      if (actual.coherence_capacity_q16 !== expected.coherence_capacity_q16)
        $display("coherence_capacity_q16 actual=%h expected=%h", actual.coherence_capacity_q16, expected.coherence_capacity_q16);
      if (actual.coupling_field_q16 !== expected.coupling_field_q16)
        $display("coupling_field_q16 actual=%h expected=%h", actual.coupling_field_q16, expected.coupling_field_q16);
      if (actual.execution_request_cell_index !== expected.execution_request_cell_index)
        $display("execution_request_cell_index actual=%h expected=%h", actual.execution_request_cell_index, expected.execution_request_cell_index);
      if (actual.execution_request_target !== expected.execution_request_target)
        $display("execution_request_target actual=%h expected=%h", actual.execution_request_target, expected.execution_request_target);
      if (actual.execution_request_valid !== expected.execution_request_valid)
        $display("execution_request_valid actual=%h expected=%h", actual.execution_request_valid, expected.execution_request_valid);
      if (actual.execution_target_bank !== expected.execution_target_bank)
        $display("execution_target_bank actual=%h expected=%h", actual.execution_target_bank, expected.execution_target_bank);
      if (actual.frequency_current_q16 !== expected.frequency_current_q16)
        $display("frequency_current_q16 actual=%h expected=%h", actual.frequency_current_q16, expected.frequency_current_q16);
      if (actual.global_coherence_q30 !== expected.global_coherence_q30)
        $display("global_coherence_q30 actual=%h expected=%h", actual.global_coherence_q30, expected.global_coherence_q30);
      if (actual.invariant_flags !== expected.invariant_flags)
        $display("invariant_flags actual=%h expected=%h", actual.invariant_flags, expected.invariant_flags);
      if (actual.neutral_routed_cell_mask !== expected.neutral_routed_cell_mask)
        $display("neutral_routed_cell_mask actual=%h expected=%h", actual.neutral_routed_cell_mask, expected.neutral_routed_cell_mask);
      if (actual.neutral_routed_events !== expected.neutral_routed_events)
        $display("neutral_routed_events actual=%h expected=%h", actual.neutral_routed_events, expected.neutral_routed_events);
      if (actual.normalized_cycle_cost_q16 !== expected.normalized_cycle_cost_q16)
        $display("normalized_cycle_cost_q16 actual=%h expected=%h", actual.normalized_cycle_cost_q16, expected.normalized_cycle_cost_q16);
      if (actual.organization_dispersion_q30 !== expected.organization_dispersion_q30)
        $display("organization_dispersion_q30 actual=%h expected=%h", actual.organization_dispersion_q30, expected.organization_dispersion_q30);
      if (actual.pair_coherence_q30 !== expected.pair_coherence_q30)
        $display("pair_coherence_q30 actual=%h expected=%h", actual.pair_coherence_q30, expected.pair_coherence_q30);
      if (actual.peak_temperature_proxy_q16 !== expected.peak_temperature_proxy_q16)
        $display("peak_temperature_proxy_q16 actual=%h expected=%h", actual.peak_temperature_proxy_q16, expected.peak_temperature_proxy_q16);
      if (actual.pending_route_out !== expected.pending_route_out)
        $display("pending_route_out actual=%h expected=%h", actual.pending_route_out, expected.pending_route_out);
      if (actual.phase_projection_q30 !== expected.phase_projection_q30)
        $display("phase_projection_q30 actual=%h expected=%h", actual.phase_projection_q30, expected.phase_projection_q30);
      if (actual.phase_request_cell_index !== expected.phase_request_cell_index)
        $display("phase_request_cell_index actual=%h expected=%h", actual.phase_request_cell_index, expected.phase_request_cell_index);
      if (actual.phase_request_target !== expected.phase_request_target)
        $display("phase_request_target actual=%h expected=%h", actual.phase_request_target, expected.phase_request_target);
      if (actual.phase_request_valid !== expected.phase_request_valid)
        $display("phase_request_valid actual=%h expected=%h", actual.phase_request_valid, expected.phase_request_valid);
      if (actual.phase_target_domain_valid !== expected.phase_target_domain_valid)
        $display("phase_target_domain_valid actual=%h expected=%h", actual.phase_target_domain_valid, expected.phase_target_domain_valid);
      if (actual.phase_target_source !== expected.phase_target_source)
        $display("phase_target_source actual=%h expected=%h", actual.phase_target_source, expected.phase_target_source);
      if (actual.phase_word_q !== expected.phase_word_q)
        $display("phase_word_q actual=%h expected=%h", actual.phase_word_q, expected.phase_word_q);
      if (actual.pressure_q16 !== expected.pressure_q16)
        $display("pressure_q16 actual=%h expected=%h", actual.pressure_q16, expected.pressure_q16);
      if (actual.prevented_direct_events !== expected.prevented_direct_events)
        $display("prevented_direct_events actual=%h expected=%h", actual.prevented_direct_events, expected.prevented_direct_events);
      if (actual.queue_overflow_events !== expected.queue_overflow_events)
        $display("queue_overflow_events actual=%h expected=%h", actual.queue_overflow_events, expected.queue_overflow_events);
      if (actual.registered_request_enable !== expected.registered_request_enable)
        $display("registered_request_enable actual=%h expected=%h", actual.registered_request_enable, expected.registered_request_enable);
      if (actual.registered_target_domain_valid !== expected.registered_target_domain_valid)
        $display("registered_target_domain_valid actual=%h expected=%h", actual.registered_target_domain_valid, expected.registered_target_domain_valid);
      if (actual.registered_target_q !== expected.registered_target_q)
        $display("registered_target_q actual=%h expected=%h", actual.registered_target_q, expected.registered_target_q);
      if (actual.registered_target_valid_q !== expected.registered_target_valid_q)
        $display("registered_target_valid_q actual=%h expected=%h", actual.registered_target_valid_q, expected.registered_target_valid_q);
      if (actual.rejected_target_capture_events_q !== expected.rejected_target_capture_events_q)
        $display("rejected_target_capture_events_q actual=%h expected=%h", actual.rejected_target_capture_events_q, expected.rejected_target_capture_events_q);
      if (actual.request_accept !== expected.request_accept)
        $display("request_accept actual=%h expected=%h", actual.request_accept, expected.request_accept);
      if (actual.request_reject !== expected.request_reject)
        $display("request_reject actual=%h expected=%h", actual.request_reject, expected.request_reject);
      if (actual.requested_direct_events !== expected.requested_direct_events)
        $display("requested_direct_events actual=%h expected=%h", actual.requested_direct_events, expected.requested_direct_events);
      if (actual.reserved_state_events !== expected.reserved_state_events)
        $display("reserved_state_events actual=%h expected=%h", actual.reserved_state_events, expected.reserved_state_events);
      if (actual.scheduler_count_balance_q !== expected.scheduler_count_balance_q)
        $display("scheduler_count_balance_q actual=%h expected=%h", actual.scheduler_count_balance_q, expected.scheduler_count_balance_q);
      if (actual.scheduler_count_commit_q !== expected.scheduler_count_commit_q)
        $display("scheduler_count_commit_q actual=%h expected=%h", actual.scheduler_count_commit_q, expected.scheduler_count_commit_q);
      if (actual.scheduler_count_excite_q !== expected.scheduler_count_excite_q)
        $display("scheduler_count_excite_q actual=%h expected=%h", actual.scheduler_count_excite_q, expected.scheduler_count_excite_q);
      if (actual.scheduler_count_free_q !== expected.scheduler_count_free_q)
        $display("scheduler_count_free_q actual=%h expected=%h", actual.scheduler_count_free_q, expected.scheduler_count_free_q);
      if (actual.scheduler_count_neutralize_q !== expected.scheduler_count_neutralize_q)
        $display("scheduler_count_neutralize_q actual=%h expected=%h", actual.scheduler_count_neutralize_q, expected.scheduler_count_neutralize_q);
      if (actual.scheduler_mode_q !== expected.scheduler_mode_q)
        $display("scheduler_mode_q actual=%h expected=%h", actual.scheduler_mode_q, expected.scheduler_mode_q);
      if (actual.scheduler_state_q !== expected.scheduler_state_q)
        $display("scheduler_state_q actual=%h expected=%h", actual.scheduler_state_q, expected.scheduler_state_q);
      if (actual.stability_margin_q16 !== expected.stability_margin_q16)
        $display("stability_margin_q16 actual=%h expected=%h", actual.stability_margin_q16, expected.stability_margin_q16);
      if (actual.stable !== expected.stable)
        $display("stable actual=%h expected=%h", actual.stable, expected.stable);
      if (actual.state_out !== expected.state_out)
        $display("state_out actual=%h expected=%h", actual.state_out, expected.state_out);
      if (actual.switch_load_numerator !== expected.switch_load_numerator)
        $display("switch_load_numerator actual=%h expected=%h", actual.switch_load_numerator, expected.switch_load_numerator);
      if (actual.target_capture_accepted !== expected.target_capture_accepted)
        $display("target_capture_accepted actual=%h expected=%h", actual.target_capture_accepted, expected.target_capture_accepted);
      if (actual.target_capture_rejected !== expected.target_capture_rejected)
        $display("target_capture_rejected actual=%h expected=%h", actual.target_capture_rejected, expected.target_capture_rejected);
      if (actual.temperature_proxy_q16 !== expected.temperature_proxy_q16)
        $display("temperature_proxy_q16 actual=%h expected=%h", actual.temperature_proxy_q16, expected.temperature_proxy_q16);
      if (actual.thermal_sample_count_q !== expected.thermal_sample_count_q)
        $display("thermal_sample_count_q actual=%h expected=%h", actual.thermal_sample_count_q, expected.thermal_sample_count_q);
      if (actual.ticks_recorded_q !== expected.ticks_recorded_q)
        $display("ticks_recorded_q actual=%h expected=%h", actual.ticks_recorded_q, expected.ticks_recorded_q);
      $fatal(1, "M32 closed-loop public output mismatch");
    end
  endtask

  task automatic step(input bit enabled, input bit clear = 0);
    longint signed frequency, target, next_frequency, push, next_temperature;
    int signed velocity;
    logic [255:0] new_phase, new_frequency;
    tick_enable = enabled; clear_counters = clear;
    #1; check();
    new_phase = gold_phase; new_frequency = gold_frequency;
    if (phase_load_valid) begin
      new_phase = phase_load; new_frequency = frequency_load_q16;
      loads++; dynamic_streak = 0;
    end else if (enabled) begin
      dynamic_ticks++; dynamic_streak++;
      if (dynamic_streak > longest_streak) longest_streak = dynamic_streak;
      for (int i = 0; i < 8; i++) begin
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
        + product(changes*8192, 10737418, 1073741824));
      if (next_temperature > gold_temperature) heating_ticks++;
      if (next_temperature < gold_temperature) cooling_ticks++;
      gold_temperature = next_temperature;
      if (gold_temperature > gold_peak) gold_peak = gold_temperature;
      gold_samples++; gold_captures++;
    end
    if (enabled) begin
      state_hits[cadence()]++; gold_counts[cadence()]++; gold_ticks++;
      gold_position = (gold_position+1)%8;
      if (auto_target_enable) automatic_ticks++; else external_ticks++;
      if (source_word != gold_target) target_lag_samples++;
      gold_target = source_word; gold_valid = 1;
      first_legs += $countones(routes); second_legs += $countones(completions);
      first_cells |= routes; second_cells |= completions;
      for (int i = 0; i < 8; i++)
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
      auto_target_enable = 0; scheduler_mode = FRP_MODE_FREE;
      external_request_valid = 0; external_request_cell_index = 0;
      external_request_target = 0; external_target_bank = 0;
      phase_load = 0; frequency_load_q16 = 0;
      gamma_effective_word = {8{32'h26666666}};
      thermal_node_factor_q30 = {8{32'h40000000}};
    end
    if (gold_pending != 0) pending_resets++;
    #1; rst_n = 0;
    gold_target = 0; gold_valid = 0; gold_state = 0; gold_pending = 0;
    gold_captures = 0; gold_ticks = 0; gold_mode = 0; gold_position = 0;
    gold_temperature = 0; gold_peak = 0; gold_samples = 0; dynamic_streak = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    for (int i = 0; i < 8; i++) begin
      gold_phase[32*i +: 32] = 32'(i)*32'h20000000;
      gold_frequency[32*i +: 32] = 32'd65536;
    end
    #1; check(); clk = 1; #1; check(); clk = 0; #1; check();
    rst_n = 1; #1; check(); resets++;
  endtask

  task automatic lane(input int lane_index, cell_index, goal);
    external_request_valid[lane_index] = 1;
    external_request_cell_index[3*lane_index +: 3] = 3'(cell_index);
    external_request_target[2*lane_index +: 2] = symbol(goal);
    external_target_bank[2*cell_index +: 2] = symbol(goal);
  endtask

  function automatic string mode_name(input int mode);
    case (mode)
      0: return "free";
      1: return "7/1";
      2: return "1/7";
      default: return "invalid";
    endcase
  endfunction

  initial begin : qualification
    real sample;
    logic [31:0] random_word;
    logic [255:0] saved_gamma;
    int before_dynamic;
    for (int i = 0; i < 4096; i++) begin
      sample = $sin(6.283185307179586476925286766559*i/4096.0)*1073741824.0;
      reference_sine[i] = $rtoi(sample < 0 ? sample-0.5 : sample+0.5);
    end
    if (reference_sine[0] != 0 || reference_sine[1024] != 1073741824 ||
        reference_sine[2048] != 0 || reference_sine[3072] != -1073741824 ||
        rounded(-3, 2) != -2 || rounded(3, 2) != 2 ||
        phase_delta(-65536) != 32'hd7419f24 || $bits(actual) != 2075)
      $fatal(1, "Oracle arithmetic initialization mismatch");
    foreach (state_hits[i]) state_hits[i] = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;

    // Separate route legs keep the saved destination despite a conflicting
    // new request and counter clear. Then assert reset while a route is pending.
    for (int cell_id = 0; cell_id < 8; cell_id++) begin
      reset_core(); lane(0, cell_id, -1); step(1);
      lane(0, cell_id, 1); step(1);
      if (actual.state_out[2*cell_id +: 2] != 0 ||
          actual.pending_route_out[2*cell_id +: 2] != 1)
        $fatal(1, "Missing active-zero first leg");
      lane(0, cell_id, -1); step(0, 1); step(1);
      if (actual.state_out[2*cell_id +: 2] != 1 || actual.pending_route_out != 0)
        $fatal(1, "Saved destination failed to complete");
      step(1); reset_core(1);
    end

    random_word = 32'h32c10fed;
    for (int workload = 0; workload < 2; workload++)
      for (int mode = 0; mode < 3; mode++) begin
        reset_core(); scheduler_mode = frp_m31_scheduler_mode_e'(mode);
        phase_load = workload == 0 ?
          256'hc0000000400000007fffffff80000000ffff000000000001fffffff000000000 :
          256'h7ff00001000fffffc0000000deadbeef800000014000000012345678ffffffff;
        frequency_load_q16 = workload == 0 ?
          256'h40000000ffff8000000080000000000000010000ffff00007fffffff80000000 :
          256'hfffe000000012e140000800000000000ffff800000028000ffff000000010000;
        gamma_effective_word = workload == 0 ? 0 :
          256'h20000000f00000001000000080000000c0000000400000000000000026666666;
        thermal_node_factor_q30 = workload == 0 ? 0 :
          256'h3000000040000000000000001000000040000000200000003000000040000000;
        phase_load_valid = 1; step(0); phase_load_valid = 0;
        before_dynamic = dynamic_ticks;
        for (int n = 0; n < 512; n++) begin
          random_word = random_word*32'd1664525+32'd1013904223;
          auto_target_enable = n < 192 || n%5 != 0;
          external_request_valid = 0; external_request_cell_index = 0;
          external_request_target = 0; external_target_bank = 0;
          for (int k = 0; k < 2; k++)
            lane(k, int'((random_word >> (7*k)) & 7), int'((random_word >> (9+k))%3)-1);
          external_request_valid = random_word[29:28];
          if (workload == 1) begin
            if (n%17 == 0) for (int i = 0; i < 8; i++)
              gamma_effective_word[32*i +: 32] += 32'(i+1)*32'h00100000;
            if (n%19 == 0) for (int i = 0; i < 8; i++)
              thermal_node_factor_q30[32*i +: 32] = 32'((i+n/19)%5)*32'h10000000;
          end
          // Change coupling controls with the clock stopped, then restore them.
          if (n%41 == 0) begin
            saved_gamma = gamma_effective_word;
            gamma_effective_word[31:0] += 32'h12345678;
            #1; check(); gamma_effective_word = saved_gamma; #1; check();
            live_control_checks += 2;
          end
          if (n%23 == 0) step(0, n%46 == 0);
          if (n == 256) begin
            // Load wins over a held tick; clear resets telemetry, not capture history.
            phase_load = ~phase_load; frequency_load_q16 = ~frequency_load_q16;
            phase_load_valid = 1; step(0, 1); phase_load_valid = 0;
          end
          step(1, n%61 == 0);
        end
        if (dynamic_ticks-before_dynamic != 512) $fatal(1, "Incomplete continuous profile");
        profiles++;
        $display("FRP_M32_CLOSED_LOOP_PROFILE: PASS workload=%0d mode=%s ticks=512 phase=%h frequency=%h state=%h pending=%h temperature=%h peak=%h",
          workload, mode_name(mode), actual.phase_word_q, actual.frequency_current_q16,
          actual.state_out, actual.pending_route_out, actual.temperature_proxy_q16,
          actual.peak_temperature_proxy_q16);
      end
    if (profiles != 6 || dynamic_ticks < 3072 || longest_streak != 256 ||
        checks != 3*steps+4*resets+live_control_checks || first_cells != 8'hff ||
        second_cells != 8'hff || pending_resets < 8 || clear_ticks == 0 || clear_holds == 0 ||
        state_feedback_samples == 0 || switch_feedback_samples == 0 ||
        heating_ticks == 0 || cooling_ticks == 0 || target_lag_samples == 0 ||
        automatic_ticks == 0 || external_ticks == 0)
      $fatal(1, "Incomplete continuous M32 feedback coverage");
    foreach (state_hits[i]) if (state_hits[i] == 0) $fatal(1, "Missing scheduler state");
    $display("FRP_M32_CLOSED_LOOP_TB: PASS profiles=%0d steps=%0d checks=%0d output_bits=2075 dynamic_ticks=%0d longest_streak=%0d held_edges=%0d loads=%0d resets=%0d pending_resets=%0d clear_ticks=%0d clear_holds=%0d automatic_ticks=%0d external_ticks=%0d target_lag_samples=%0d state_feedback_samples=%0d switch_feedback_samples=%0d heating_ticks=%0d cooling_ticks=%0d first_legs=%0d second_legs=%0d first_cells=%0d second_cells=%0d live_control_checks=%0d free_ticks=%0d balance_ticks=%0d commit_ticks=%0d excite_ticks=%0d neutralize_ticks=%0d",
      profiles, steps, checks, dynamic_ticks, longest_streak, held_edges, loads, resets,
      pending_resets, clear_ticks, clear_holds, automatic_ticks, external_ticks,
      target_lag_samples, state_feedback_samples, switch_feedback_samples, heating_ticks,
      cooling_ticks, first_legs, second_legs, first_cells, second_cells, live_control_checks,
      state_hits[0], state_hits[1], state_hits[2], state_hits[3], state_hits[4]);
    $finish;
  end

  initial begin
    #100000;
    $fatal(1, "M32 continuous feedback watchdog expired");
  end
endmodule

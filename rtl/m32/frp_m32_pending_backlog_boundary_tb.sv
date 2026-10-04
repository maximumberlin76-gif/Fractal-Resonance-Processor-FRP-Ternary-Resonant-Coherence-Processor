// SPDX-License-Identifier: Apache-2.0
// M32 eight-cell pending-backlog qualification through public inputs only.
// All 256 pending masks, two mixed-polarity patterns, forward/reverse insertion
// and both 7/1 and 1/7 modes; backlogs reach all eight retained destinations.
// Pending routes complete in ascending cell order before new state changes.
// Active zero, two changes per enabled tick, held clocks, competing requests,
// target replacement, counter clears, asynchronous reset and feedback remain
// checked by an independent integer oracle over all 59 outputs (2075 bits).
// Define FRP_M32_PENDING_BACKLOG_NETLIST to replay the same standalone bench
// against frp_m32_core_netlist. No DUT internals or arithmetic helpers are read.
// Finite functional qualification, not global coverage, physical validation
// or equivalence to model v0.9.3.
`ifndef FRP_M32_PENDING_BACKLOG_BOUNDARY_TB_SV
`define FRP_M32_PENDING_BACKLOG_BOUNDARY_TB_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M32_PENDING_BACKLOG_NETLIST
`include "frp_m32_core.sv"
`endif

module frp_m32_pending_backlog_boundary_tb;
  timeunit 1ns;
  timeprecision 1ps;
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

`ifdef FRP_M32_PENDING_BACKLOG_NETLIST
  frp_m32_core_netlist dut (
`else
  frp_m32_core #(.CELLS(8), .REQUEST_LANES(2), .COUNTER_BITS(32)) dut (
`endif
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
  bit gold_valid = 0, completed = 0;
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
  int checks = 0, matrix_cases = 0, reset_cases = 0, profiles = 0;
  int reset_low = 0, reset_high = 0, reset_pending = 0;
  int enabled_edges = 0, held_edges = 0, load_ticks = 0, load_holds = 0;
  int clear_ticks = 0, clear_holds = 0, old_source_captures = 0;
  int mode_tick_handoffs = 0, mode_hold_handoffs = 0;
  int first_legs = 0, second_legs = 0, capacity_blocks = 0;
  int state_feedback = 0, switch_feedback = 0, target_lags = 0;
  int heating = 0, cooling = 0, streak = 0, longest_streak = 0;
  int edge_hits[5], state_hits[5], matrix_bins[2][256][2][2];
  int reset_bins[2][2][16], depth_bins[9];
  int full_backlogs = 0, full_backlog_resets = 0, pending_holds = 0;
  int eligible_drain_edges = 0, blocked_drain_edges = 0, drained_destinations = 0;
  int busy_rejections = 0, saturated_noops = 0, drain_clear_ticks = 0;
  int drain_clear_holds = 0, drain_target_changes = 0;
  bit measuring_drain = 0;
  logic [7:0] first_cells = 0, second_cells = 0;
  logic [63:0] signature = 64'hbac810a0b0320001;
  event model_request, model_done;
  int model_operation, sample_kind;

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

  // The model uses only its retained state and test inputs, never DUT state.
  task automatic check_outputs(input int kind);
    logic [2079:0] padded;
    observe();
    if (actual !== expected) begin
      $display("M32 pending-backlog mismatch sample=%0d event=%0d mode=%0d position=%0d tick=%b load=%b clear=%b auto=%b reset=%b",
        checks, kind, gold_mode, gold_position, tick_enable, phase_load_valid,
        clear_counters, auto_target_enable, rst_n);
      $display("actual=%h", actual);
      $display("expected=%h", expected);
      $fatal(1, "M32 pending-backlog-boundary output mismatch");
    end
    if (kind < 0 || kind > 4) $fatal(1, "Invalid sample kind");
    edge_hits[kind]++; checks++;
    padded = {5'b0, actual};
    for (int i = 0; i < 65; i++)
      signature = {signature[58:0], signature[63:59]} ^
        {32'b0, padded[32*i +: 32]} ^ 64'(checks);
  endtask

  task automatic reset_values;
    gold_target = 0; gold_valid = 0; gold_state = 0; gold_pending = 0;
    gold_captures = 0; gold_ticks = 0; gold_mode = 0; gold_position = 0;
    gold_temperature = 0; gold_peak = 0; gold_samples = 0; streak = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    for (int i = 0; i < 8; i++) begin
      gold_phase[32*i +: 32] = 32'(i)*32'h20000000;
      gold_frequency[32*i +: 32] = 32'd65536;
    end
  endtask

  task automatic advance_model;
    longint signed frequency, target, next_frequency, push, temperature;
    int signed velocity;
    logic [255:0] new_phase, new_frequency;
    if (!rst_n) begin reset_values(); return; end
    observe();
    new_phase = gold_phase; new_frequency = gold_frequency;
    if (measuring_drain) begin
      int depth;
      depth = 0;
      for (int i = 0; i < 8; i++) if (gold_pending[2*i +: 2] != 0) depth++;
      depth_bins[depth]++;
      if (depth != 0) begin
        if (!tick_enable) pending_holds++;
        else if (cadence() == 0 || cadence() == 2 || cadence() == 3)
          eligible_drain_edges++;
        else blocked_drain_edges++;
        if (clear_counters) begin
          if (tick_enable) drain_clear_ticks++; else drain_clear_holds++;
        end
        if (selected_bank != gold_pending) drain_target_changes++;
        for (int lane_id = 0; lane_id < 2; lane_id++) begin
          int cell_id;
          cell_id = int'(selected_index[3*lane_id +: 3]);
          if (tick_enable && selected_valid[lane_id]) begin
            if (gold_pending[2*cell_id +: 2] != 0 && reject[lane_id]) busy_rejections++;
            if (changes == 2 && accept[lane_id] &&
                selected_target[2*lane_id +: 2] == gold_state[2*cell_id +: 2]) saturated_noops++;
          end
        end
      end
      if (tick_enable) drained_destinations += $countones(completions);
    end
    if (phase_load_valid) begin
      new_phase = phase_load; new_frequency = frequency_load_q16;
      if (tick_enable) load_ticks++; else load_holds++;
      streak = 0;
    end else if (tick_enable) begin
      streak++;
      if (streak > longest_streak) longest_streak = streak;
      for (int i = 0; i < 8; i++) begin
        frequency = $signed(gold_frequency[32*i +: 32]);
        target = 65536 + (gold_state[2*i +: 2] != 0 ? 3932 : 0) + (writes[i] ? 7864 : 0);
        next_frequency = saturate(frequency+saturate(rounded((target-frequency)*19661, 65536)));
        push = cadence() == 2 ? 655 : cadence() == 3 ? 393 : 197;
        velocity = 32'(product(3932, next_frequency, 65536)+push+coupling[i]);
        new_phase[32*i +: 32] = gold_phase[32*i +: 32]+phase_delta(velocity);
        new_frequency[32*i +: 32] = 32'(next_frequency);
        if (gold_state[2*i +: 2] != 0) state_feedback++;
        if (writes[i]) switch_feedback++;
      end
    end
    // Capture and thermal counters give clear priority over an enabled tick;
    // scheduler counters clear first, then count that tick in the OLD cadence.
    if (clear_counters) begin
      gold_temperature = 0; gold_peak = 0; gold_samples = 0;
      gold_captures = 0; gold_ticks = 0;
      foreach (gold_counts[i]) gold_counts[i] = 0;
      if (tick_enable) clear_ticks++; else clear_holds++;
    end else if (tick_enable) begin
      temperature = saturate(product(gold_temperature, 1020054733, 1073741824)
        + product(changes*8192, 10737418, 1073741824));
      if (temperature > gold_temperature) heating++;
      if (temperature < gold_temperature) cooling++;
      gold_temperature = temperature;
      if (temperature > gold_peak) gold_peak = temperature;
      gold_samples++;
      if (gold_captures != 32'hffffffff) gold_captures++;
    end
    if (tick_enable) begin
      enabled_edges++; state_hits[cadence()]++;
      gold_counts[cadence()]++; gold_ticks++;
      gold_position = (gold_position+1)%8;
      if (source_word != gold_target) target_lags++;
      // Capture observes the pre-edge phase even when this edge loads a bank.
      if (phase_load_valid) old_source_captures++;
      gold_target = source_word; gold_valid = 1;
      first_legs += $countones(routes); second_legs += $countones(completions);
      first_cells |= routes; second_cells |= completions;
      capacity_blocks += blocked_lanes;
      for (int i = 0; i < 8; i++)
        if (value(gold_state[2*i +: 2])*value(next_state[2*i +: 2]) == -1)
          $fatal(1, "Oracle attempted direct opposite-polarity execution");
    end else held_edges++;
    if (gold_mode != int'(scheduler_mode)) begin
      if (tick_enable) mode_tick_handoffs++; else mode_hold_handoffs++;
    end
    gold_phase = new_phase; gold_frequency = new_frequency;
    gold_state = next_state; gold_pending = next_pending;
    gold_mode = int'(scheduler_mode);
  endtask

  // One model process avoids replicating the integer oracle at every call site.
  task automatic call_model(input int operation, input int kind = 0);
    model_operation = operation; sample_kind = kind;
    -> model_request; @model_done;
  endtask

  initial forever begin
    @model_request;
    case (model_operation)
      0: check_outputs(sample_kind);
      1: advance_model();
      2: reset_values();
      default: $fatal(1, "Unknown oracle operation");
    endcase
    -> model_done;
  end

  task automatic sample(input int kind);
    call_model(0, kind);
  endtask

  task automatic edge_to(input bit level);
    if (clk == level) $fatal(1, "Missing requested clock edge");
    if (level) call_model(1);
    clk = level; #1; sample(level ? 1 : 2);
  endtask

  task automatic step(input bit enabled, input bit clear = 0);
    if (clk) $fatal(1, "Step must start with clock low");
    tick_enable = enabled; clear_counters = clear;
    #1; sample(0); edge_to(1); edge_to(0);
  endtask

  task automatic reset_core;
    if (!rst_n) $fatal(1, "Reset assertion requires released reset");
    if (clk) reset_high++; else reset_low++;
    if (gold_pending != 0) reset_pending++;
    rst_n = 0; call_model(2); #1; sample(3);
    edge_to(!clk); edge_to(!clk);
    rst_n = 1; #1; sample(4);
    if (clk) edge_to(0);
  endtask

  task automatic defaults;
    tick_enable = 0; clear_counters = 0; phase_load_valid = 0;
    auto_target_enable = 0; scheduler_mode = FRP_MODE_FREE;
    external_request_valid = 0; external_request_cell_index = 0;
    external_request_target = 0; external_target_bank = 0;
    phase_load = 0; frequency_load_q16 = 0;
    gamma_effective_word = {8{32'h26666666}};
    thermal_node_factor_q30 = {8{32'h40000000}};
  endtask

  task automatic lane(input int index, cell_index, goal);
    external_request_valid[index] = 1;
    external_request_cell_index[3*index +: 3] = 3'(cell_index);
    external_request_target[2*index +: 2] = symbol(goal);
    external_target_bank[2*cell_index +: 2] = symbol(goal);
  endtask

  function automatic logic [7:0] pending_mask(input logic [15:0] bank);
    logic [7:0] result;
    result = 0;
    for (int i = 0; i < 8; i++) result[i] = bank[2*i +: 2] != 0;
    return result;
  endfunction

  function automatic int first_cell(input logic [7:0] mask);
    for (int i = 0; i < 8; i++) if (mask[i]) return i;
    return -1;
  endfunction

  // Each backlog is reached through legal requests: no forced state or routes.
  task automatic seed_backlog(input int mode, mask, polarity, reverse_order);
    logic [15:0] destinations;
    int cell_id, used;
    defaults(); reset_core(); destinations = 0;
    for (int i = 0; i < 8; i++) begin
      phase_load[32*i +: 32] = 32'(i+polarity)*32'h20000000 + 32'(mask)*32'h00100000;
      frequency_load_q16[32*i +: 32] = 32'(65536+(i-4)*3932);
      gamma_effective_word[32*i +: 32] = 32'(i+1)*32'h06666666;
      thermal_node_factor_q30[32*i +: 32] = 32'((i+polarity)%5)*32'h10000000;
      if (mask[i]) destinations[2*i +: 2] = symbol((i+polarity)%2 == 0 ? -1 : 1);
    end
    phase_load_valid = 1; step(0); phase_load_valid = 0;
    for (int pair_id = 0; pair_id < 4; pair_id++) begin
      external_request_valid = 0;
      for (int k = 0; k < 2; k++) begin
        cell_id = 2*pair_id+k;
        lane(k, cell_id, -value(destinations[2*cell_id +: 2]));
      end
      step(1);
    end
    external_request_valid = 0;
    // Start at BALANCE position 0 or NEUTRALIZE position 1: four insertion
    // ticks cannot reach COMMIT/EXCITE, so no pending destination drains.
    while (gold_position != 0) step(1);
    scheduler_mode = frp_m31_scheduler_mode_e'(mode); step(0);
    if (mode == 2) step(1);
    used = 0;
    for (int n = 0; n < 8; n++) begin
      cell_id = reverse_order != 0 ? 7-n : n;
      if (mask[cell_id]) begin
        lane(used, cell_id, value(destinations[2*cell_id +: 2]));
        used++;
        if (used == 2) begin step(1); external_request_valid = 0; used = 0; end
      end
    end
    if (used != 0) step(1);
    external_request_valid = 0; tick_enable = 0;
    #1; sample(0);
    if (gold_pending !== destinations || actual.pending_route_out !== destinations ||
        actual.state_out !== 16'b0)
      $fatal(1, "Public-input backlog construction failed");
    if (mask == 255) full_backlogs++;
  endtask

  task automatic drain_case(input int mode, mask, polarity, reverse_order);
    logic [15:0] destinations;
    int busy_cell, empty_cell, drain_ticks, eligible_ticks;
    seed_backlog(mode, mask, polarity, reverse_order);
    destinations = gold_pending;
    measuring_drain = 1;
    // Replace every external bank destination while retaining pending routes.
    external_target_bank = 0;
    for (int i = 0; i < 8; i++)
      external_target_bank[2*i +: 2] = symbol(-value(destinations[2*i +: 2]));
    empty_cell = first_cell(~8'(mask));
    step(0, 1);
    auto_target_enable = 1; #1; sample(0);
    auto_target_enable = 0; #1; sample(0);
    drain_ticks = 0; eligible_ticks = 0;
    while (gold_pending != 0 && drain_ticks < 32) begin
      busy_cell = first_cell(pending_mask(gold_pending));
      external_request_valid = 0;
      // Lane 0 tries to retarget a busy cell. Lane 1 either requests a new
      // write or a same-state acceptance, which must cost no capacity.
      lane(0, busy_cell, -value(gold_pending[2*busy_cell +: 2]));
      if (empty_cell >= 0) lane(1, empty_cell, reverse_order == 0 ? 0 : 1);
      step(0, drain_ticks%3 == 0);
      if (cadence() == 2 || cadence() == 3) eligible_ticks++;
      step(1, drain_ticks%5 == 0);
      drain_ticks++;
    end
    if (gold_pending != 0 || eligible_ticks != ($countones(8'(mask))+1)/2)
      $fatal(1, "Backlog failed its four-eligible-tick drain bound");
    for (int i = 0; i < 8; i++)
      if (mask[i] && actual.state_out[2*i +: 2] !== destinations[2*i +: 2])
        $fatal(1, "A pending destination was overwritten or lost");
    external_request_valid = 0; step(0);
    measuring_drain = 0;
    matrix_bins[mode-1][mask][polarity][reverse_order]++; matrix_cases++;
  endtask

  task automatic checkpoint(input int stage);
    $display("FRP_M32_PENDING_BACKLOG_STAGE: PASS stage=%0d checks=%0d signature=%h",
      stage, checks, signature);
  endtask

  initial begin : qualification
    real sine_value;
    logic [31:0] random_word;
    int profile_ticks, profile_counts[5];
    #1;
    for (int i = 0; i < 4096; i++) begin
      sine_value = $sin(6.283185307179586476925286766559*i/4096.0)*1073741824.0;
      reference_sine[i] = $rtoi(sine_value < 0 ? sine_value-0.5 : sine_value+0.5);
    end
    if ($bits(actual) != 2075 || reference_sine[0] != 0 ||
        reference_sine[1024] != 1073741824 || reference_sine[2048] != 0 ||
        reference_sine[3072] != -1073741824 || rounded(3, 2) != 2 ||
        rounded(-3, 2) != -2 || phase_delta(-65536) != 32'hd7419f24)
      $fatal(1, "Independent oracle initialization failed");
    foreach (edge_hits[i]) edge_hits[i] = 0;
    foreach (state_hits[i]) state_hits[i] = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    foreach (depth_bins[i]) depth_bins[i] = 0;
    foreach (matrix_bins[a,b,c,d]) matrix_bins[a][b][c][d] = 0;
    foreach (reset_bins[a,b,c]) reset_bins[a][b][c] = 0;

    for (int mode = 1; mode <= 2; mode++)
      for (int mask = 0; mask < 256; mask++)
        for (int polarity = 0; polarity < 2; polarity++)
          for (int reverse_order = 0; reverse_order < 2; reverse_order++)
            drain_case(mode, mask, polarity, reverse_order);
    foreach (matrix_bins[a,b,c,d])
      if (matrix_bins[a][b][c][d] != 1) $fatal(1, "Missing backlog matrix bin");
    foreach (depth_bins[i]) if (depth_bins[i] == 0) $fatal(1, "Missing backlog depth");
    if (drained_destinations != 8192 || full_backlogs != 8)
      $fatal(1, "Incomplete retained-destination matrix");
    checkpoint(0);

    // Reset must clear a FULL backlog even without a clock edge, with every
    // tick/load/clear/automatic combination and the clock either low or high.
    for (int mode = 1; mode <= 2; mode++)
      for (int high_clock = 0; high_clock < 2; high_clock++)
        for (int controls = 0; controls < 16; controls++) begin
          seed_backlog(mode, 255, controls%2, high_clock);
          if (high_clock != 0) edge_to(1);
          if (pending_mask(gold_pending) != 8'hff) $fatal(1, "Reset fixture lost full backlog");
          phase_load = ~gold_phase; frequency_load_q16 = ~gold_frequency;
          tick_enable = controls[0]; phase_load_valid = controls[1];
          clear_counters = controls[2]; auto_target_enable = controls[3];
          lane(0, 7, -1); lane(1, 0, 1);
          #1; sample(0); reset_core(); full_backlog_resets++;
          if (actual.pending_route_out != 0 || actual.state_out != 0)
            $fatal(1, "Reset retained a pending destination");
          defaults(); step(0); step(1);
          if (actual.pending_route_out != 0 || actual.state_out != 0)
            $fatal(1, "Pending destination reappeared after reset");
          reset_bins[mode-1][high_clock][controls]++; reset_cases++;
        end
    foreach (reset_bins[a,b,c])
      if (reset_bins[a][b][c] != 1) $fatal(1, "Missing full-backlog reset bin");
    checkpoint(1);

    // Release a full backlog into continuous feedback, including automatic
    // contention, live mux handoffs and 1024 enabled ticks in each mode.
    random_word = 32'hbacc1032;
    for (int mode = 0; mode < 3; mode++) begin
      seed_backlog(mode == 2 ? 2 : 1, 255, mode%2, mode%2);
      scheduler_mode = frp_m31_scheduler_mode_e'(mode); step(0);
      profile_ticks = 0; foreach (profile_counts[i]) profile_counts[i] = 0;
      for (int n = 0; n < 1024; n++) begin
        random_word = random_word*32'd1664525 + 32'd1013904223;
        auto_target_enable = n%8 != 0;
        external_request_valid = 0;
        for (int k = 0; k < 2; k++)
          lane(k, (n+3*k)%8, int'((random_word >> (8*k))%3)-1);
        if (n%17 == 0) for (int i = 0; i < 8; i++)
          gamma_effective_word[32*i +: 32] += 32'(i+1)*32'h00100000;
        if (n%19 == 0) for (int i = 0; i < 8; i++)
          thermal_node_factor_q30[32*i +: 32] = 32'((n+i)%5)*32'h10000000;
        if (n%31 == 0) step(0, n%62 == 0);
        profile_counts[cadence()]++; profile_ticks++;
        step(1, n%127 == 0);
      end
      if (profile_ticks != 1024 ||
          (mode == 0 && profile_counts[0] != 1024) ||
          (mode == 1 && (profile_counts[1] != 896 || profile_counts[2] != 128)) ||
          (mode == 2 && (profile_counts[3] != 128 || profile_counts[4] != 896)))
        $fatal(1, "Incomplete continuous backlog profile");
      $display("FRP_M32_PENDING_BACKLOG_PROFILE: PASS mode=%0d ticks=1024 free=%0d balance=%0d commit=%0d excite=%0d neutralize=%0d signature=%h",
        mode, profile_counts[0], profile_counts[1], profile_counts[2],
        profile_counts[3], profile_counts[4], signature);
      profiles++;
    end
    checkpoint(2);
    if (matrix_cases != 2048 || reset_cases != 64 || profiles != 3 ||
        full_backlogs != 75 || full_backlog_resets != 64 ||
        pending_holds == 0 || eligible_drain_edges == 0 || blocked_drain_edges == 0 ||
        busy_rejections == 0 || saturated_noops == 0 || capacity_blocks == 0 ||
        drain_clear_ticks == 0 || drain_clear_holds == 0 || drain_target_changes == 0 ||
        first_cells != 8'hff || second_cells != 8'hff ||
        state_feedback == 0 || switch_feedback == 0 || heating == 0 || cooling == 0 ||
        longest_streak < 1024)
      $fatal(1, "Incomplete M32 pending-backlog qualification");
    foreach (edge_hits[i]) if (edge_hits[i] == 0) $fatal(1, "Missing event kind");
    foreach (state_hits[i]) if (state_hits[i] == 0) $fatal(1, "Missing cadence");
    $display("FRP_M32_PENDING_BACKLOG_TB: PASS matrix_cases=%0d reset_cases=%0d profiles=%0d checks=%0d fields=59 output_bits=2075 full_backlogs=%0d full_backlog_resets=%0d drained_destinations=%0d eligible_drain_edges=%0d blocked_drain_edges=%0d pending_holds=%0d busy_rejections=%0d saturated_noops=%0d capacity_blocks=%0d drain_clear_ticks=%0d drain_clear_holds=%0d drain_target_changes=%0d enabled=%0d held=%0d first_legs=%0d second_legs=%0d first_cells=%0d second_cells=%0d signature=%h",
      matrix_cases, reset_cases, profiles, checks, full_backlogs, full_backlog_resets,
      drained_destinations, eligible_drain_edges, blocked_drain_edges, pending_holds,
      busy_rejections, saturated_noops, capacity_blocks, drain_clear_ticks,
      drain_clear_holds, drain_target_changes, enabled_edges, held_edges,
      first_legs, second_legs, first_cells, second_cells, signature);
    completed = 1; $finish;
  end

  initial begin
    #2000000;
    $fatal(1, "M32 pending-backlog-boundary watchdog expired");
  end
  final begin
    if (!completed) $fatal(1, "M32 pending-backlog-boundary qualification ended early");
  end
endmodule
`endif

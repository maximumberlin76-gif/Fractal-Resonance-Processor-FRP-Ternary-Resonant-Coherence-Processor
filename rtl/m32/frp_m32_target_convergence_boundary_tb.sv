// SPDX-License-Identifier: Apache-2.0
// Eight-cell automatic target-convergence qualification, two request lanes.
// Independent integer oracle checks all 59 public outputs on every sample.
// All 3^8 legal goal banks are reached in each scheduler mode, without reset
// between banks. The finite matrix holds phase inputs during convergence;
// three additional 1024-tick profiles exercise continuous phase feedback.
// Held loads and enabled capture edges must preserve the previous execution
// bank. Opposite-polarity execution must traverse active zero on separate ticks.
// Define FRP_M32_TARGET_CONVERGENCE_NETLIST for the same stimulus and oracle
// against a flattened frp_m32_core_netlist with the original port contract.
// This is finite eight-cell functional qualification, not exhaustive state
// coverage, physical validation or equivalence to reference model v0.9.3.
`ifndef FRP_M32_TARGET_CONVERGENCE_BOUNDARY_TB_SV
`define FRP_M32_TARGET_CONVERGENCE_BOUNDARY_TB_SV
`include "frp_m31_pkg.sv"
`ifndef FRP_M32_TARGET_CONVERGENCE_NETLIST
`include "frp_m32_core.sv"
`endif

module frp_m32_target_convergence_boundary_tb;
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

`ifdef FRP_M32_TARGET_CONVERGENCE_NETLIST
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
    .peak_temperature_proxy_q16(actual.peak_temperature_proxy_q16),
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
  int checks = 0, matrix_cases = 0, profiles = 0;
  int reset_low = 0, reset_high = 0, reset_pending = 0;
  int enabled_edges = 0, held_edges = 0, load_ticks = 0, load_holds = 0;
  int clear_ticks = 0, clear_holds = 0, old_source_captures = 0;
  int mode_tick_handoffs = 0, mode_hold_handoffs = 0;
  int first_legs = 0, second_legs = 0, capacity_blocks = 0;
  int state_feedback = 0, switch_feedback = 0, target_lags = 0;
  int heating = 0, cooling = 0, streak = 0, longest_streak = 0;
  int edge_hits[5], state_hits[5];
  int permutation[6561], goal_seen[3][6561], start_seen[3][8];
  int transition_seen[3][8][9], maximum_ticks[3];
  int capture_barriers = 0, settled_cells = 0, idle_ticks = 0;
  int pending_holds = 0, pending_clear_ticks = 0, pending_clear_holds = 0;
  int ignored_external_edges = 0, dynamic_ticks = 0;
  logic [7:0] first_cells = 0, second_cells = 0;
  logic [63:0] signature = 64'hc032c0a17e000001;
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
      $display("M32 target-convergence mismatch sample=%0d event=%0d mode=%0d position=%0d tick=%b load=%b clear=%b auto=%b reset=%b",
        checks, kind, gold_mode, gold_position, tick_enable, phase_load_valid,
        clear_counters, auto_target_enable, rst_n);
      $display("actual=%h", actual);
      $display("expected=%h", expected);
      $fatal(1, "M32 target-convergence-boundary output mismatch");
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
    if (auto_target_enable && external_request_valid != 0) ignored_external_edges++;
    if (gold_pending != 0) begin
      if (!tick_enable) pending_holds++;
      if (clear_counters && tick_enable) pending_clear_ticks++;
      if (clear_counters && !tick_enable) pending_clear_holds++;
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

  // Values come from base-three digits, independently of the DUT encoding.
  function automatic logic [15:0] goal_bank(input int number);
    logic [15:0] result;
    int remainder;
    remainder = number;
    for (int i = 0; i < 8; i++) begin
      result[2*i +: 2] = symbol(remainder%3-1);
      remainder /= 3;
    end
    return result;
  endfunction

  task automatic load_goal(input logic [15:0] goal, input int variant);
    int target;
    for (int i = 0; i < 8; i++) begin
      target = value(goal[2*i +: 2]);
      case (target)
        -1: case ((i+variant)%3)
          0: phase_load[32*i +: 32] = 32'hc0000000;
          1: phase_load[32*i +: 32] = 32'd2268 << 20;
          2: phase_load[32*i +: 32] = (32'd3876 << 20) | 32'h000fffff;
        endcase
         0: case ((i+variant)%4)
          0: phase_load[32*i +: 32] = 0;
          1: phase_load[32*i +: 32] = 32'h80000000;
          2: phase_load[32*i +: 32] = (32'd219 << 20) | 32'h000fffff;
          3: phase_load[32*i +: 32] = 32'd1829 << 20;
        endcase
         1: case ((i+variant)%3)
          0: phase_load[32*i +: 32] = 32'h40000000;
          1: phase_load[32*i +: 32] = 32'd220 << 20;
          2: phase_load[32*i +: 32] = (32'd1828 << 20) | 32'h000fffff;
        endcase
        default: $fatal(1, "Illegal convergence goal");
      endcase
      frequency_load_q16[32*i +: 32] = 32'(65536+(i-4)*3932);
      gamma_effective_word[32*i +: 32] = 32'(i+variant)*32'h17ab0001;
      thermal_node_factor_q30[32*i +: 32] = 32'((i+variant)%5)*32'h10000000;
    end
  endtask

  // Valid contradictory external requests must be ignored throughout auto mode.
  task automatic decoys(input logic [15:0] goal, input int variant);
    int index, target;
    external_request_valid = 0; external_target_bank = 0;
    for (int k = 0; k < 2; k++) begin
      index = (variant+k*3)%8;
      target = value(goal[2*index +: 2]);
      lane(k, index, target == 0 ? 1 : -target);
    end
  endtask

  initial begin : qualification
    real sine_value;
    logic [31:0] random_word;
    logic [15:0] goal, previous;
    int pick, swap_value, bank_number, position, elapsed_ticks, bound;
    int mode_ticks, profile_ticks, profile_counts[5];
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
    foreach (goal_seen[m,b]) goal_seen[m][b] = 0;
    foreach (start_seen[m,p]) start_seen[m][p] = 0;
    foreach (transition_seen[m,c,t]) transition_seen[m][c][t] = 0;
    foreach (maximum_ticks[m]) maximum_ticks[m] = 0;
    foreach (permutation[i]) permutation[i] = i;
    random_word = 32'hc03219a5;
    for (int i = 6560; i > 0; i--) begin
      random_word = random_word*32'd1664525+32'd1013904223;
      pick = int'(random_word%32'(i+1));
      swap_value = permutation[i]; permutation[i] = permutation[pick];
      permutation[pick] = swap_value;
    end

    for (int mode = 0; mode < 3; mode++) begin
      defaults(); reset_core();
      scheduler_mode = frp_m31_scheduler_mode_e'(mode);
      auto_target_enable = 1; phase_load_valid = 1;
      load_goal(16'b0, mode); decoys(16'b0, mode);
      step(0); step(1);
      if (gold_target != 0 || gold_state != 0 || gold_pending != 0)
        $fatal(1, "Convergence initialization did not settle at active zero");
      mode_ticks = 0; bound = mode == 0 ? 8 : 64;
      for (int ordinal = 0; ordinal < 6561; ordinal++) begin
        // Align each case while the preceding bank remains fully settled.
        position = ordinal%8;
        while (gold_position != position) step(1);
        previous = gold_state;
        if (!gold_valid || gold_target != previous || gold_pending != 0)
          $fatal(1, "Previous goal has not settled");
        bank_number = permutation[(ordinal+2187*mode)%6561];
        goal = goal_bank(bank_number);
        load_goal(goal, ordinal+mode); decoys(goal, ordinal+mode);
        // Loading source phases while held must not capture or execute the goal.
        step(0, ordinal%7 == 0);
        if (actual.phase_target_source !== goal || actual.registered_target_q !== previous ||
            actual.state_out !== previous || actual.pending_route_out !== 0)
          $fatal(1, "Held phase load crossed the target capture barrier");
        start_seen[mode][position]++;
        // The enabled edge captures the source but executes the OLD target.
        step(1, ordinal%11 == 0);
        if (actual.registered_target_q !== goal || actual.state_out !== previous ||
            actual.pending_route_out !== 0)
          $fatal(1, "Newly captured target executed on its own capture edge");
        capture_barriers++;
        elapsed_ticks = 0;
        while (gold_state != goal || gold_pending != 0) begin
          if (elapsed_ticks >= bound)
            $fatal(1, "Convergence bound exceeded mode=%0d bank=%0d ticks=%0d",
              mode, bank_number, elapsed_ticks);
          // Holds do not consume the bound. Counter clears must preserve routes.
          if (elapsed_ticks%2 == 0) step(0, elapsed_ticks%4 == 0);
          step(1, elapsed_ticks%5 == 0);
          elapsed_ticks++;
        end
        if (actual.state_out !== goal || actual.pending_route_out !== 0 ||
            actual.phase_request_valid !== 0 || actual.accepted_changes !== 0)
          $fatal(1, "Settled goal is not quiescent");
        if (elapsed_ticks > maximum_ticks[mode]) maximum_ticks[mode] = elapsed_ticks;
        mode_ticks += elapsed_ticks;
        for (int i = 0; i < 8; i++) begin
          transition_seen[mode][i][3*(value(previous[2*i +: 2])+1)
                                     +value(goal[2*i +: 2])+1]++;
          settled_cells++;
        end
        goal_seen[mode][bank_number]++; matrix_cases++;
        if (ordinal%81 == 0) begin
          step(1); idle_ticks++;
          if (actual.state_out !== goal || actual.pending_route_out !== 0 ||
              actual.accepted_changes !== 0) $fatal(1, "Settled goal changed on idle tick");
        end
      end
      $display("FRP_M32_TARGET_CONVERGENCE_MATRIX: PASS mode=%0d banks=6561 settled_cells=52488 enabled_ticks=%0d max_ticks=%0d bound=%0d checks=%0d signature=%h",
        mode, mode_ticks, maximum_ticks[mode], bound, checks, signature);
    end
    foreach (goal_seen[m,b])
      if (goal_seen[m][b] != 1) $fatal(1, "Missing or repeated legal target bank");
    foreach (start_seen[m,p])
      if (start_seen[m][p] == 0) $fatal(1, "Missing mode/cadence start bin");
    foreach (transition_seen[m,c,t])
      if (transition_seen[m][c][t] == 0) $fatal(1, "Missing per-cell old/new ternary transition");

    // Release phase loading and retain the complete state across three profiles.
    // This exercises continuous phase/frequency/coupling/execution feedback;
    // it does not claim convergence to a fixed goal while that goal is moving.
    phase_load_valid = 0; auto_target_enable = 1;
    for (int mode = 0; mode < 3; mode++) begin
      scheduler_mode = frp_m31_scheduler_mode_e'(mode); step(0);
      profile_ticks = enabled_edges;
      foreach (profile_counts[i]) profile_counts[i] = state_hits[i];
      for (int n = 0; n < 1024; n++) begin
        decoys(gold_target, n+mode);
        if (n%17 == 0) for (int i = 0; i < 8; i++)
          gamma_effective_word[32*i +: 32] += 32'(i+1)*32'h00100000;
        if (n%19 == 0) for (int i = 0; i < 8; i++)
          thermal_node_factor_q30[32*i +: 32] = 32'((i+n/19)%5)*32'h10000000;
        if (n%23 == 0) step(0, n%46 == 0);
        step(1, n%61 == 0); dynamic_ticks++;
      end
      foreach (profile_counts[i]) profile_counts[i] = state_hits[i]-profile_counts[i];
      if (enabled_edges-profile_ticks != 1024 ||
          profile_counts[0] != (mode == 0 ? 1024 : 0) ||
          profile_counts[1] != (mode == 1 ? 896 : 0) ||
          profile_counts[2] != (mode == 1 ? 128 : 0) ||
          profile_counts[3] != (mode == 2 ? 128 : 0) ||
          profile_counts[4] != (mode == 2 ? 896 : 0))
        $fatal(1, "Incomplete continuous automatic scheduler profile");
      profiles++;
      $display("FRP_M32_TARGET_CONVERGENCE_PROFILE: PASS mode=%0d ticks=1024 free=%0d balance=%0d commit=%0d excite=%0d neutralize=%0d signature=%h",
        mode, profile_counts[0], profile_counts[1], profile_counts[2],
        profile_counts[3], profile_counts[4], signature);
    end
    if (matrix_cases != 19683 || capture_barriers != 19683 || settled_cells != 157464 ||
        profiles != 3 || dynamic_ticks != 3072 || longest_streak != 3072 ||
        idle_ticks != 243 || maximum_ticks[0] == 0 || maximum_ticks[1] == 0 ||
        maximum_ticks[2] == 0 || pending_holds == 0 || pending_clear_ticks == 0 ||
        pending_clear_holds == 0 || ignored_external_edges == 0 || capacity_blocks == 0 ||
        first_legs == 0 || second_legs == 0 || first_cells != 8'hff || second_cells != 8'hff ||
        state_feedback == 0 || switch_feedback == 0 || heating == 0 || cooling == 0)
      $fatal(1, "Incomplete automatic target-convergence qualification");
    foreach (edge_hits[i]) if (edge_hits[i] == 0) $fatal(1, "Missing event kind");
    foreach (state_hits[i]) if (state_hits[i] == 0) $fatal(1, "Missing cadence");
    $display("FRP_M32_TARGET_CONVERGENCE_TB: PASS banks_per_mode=6561 cases=%0d capture_barriers=%0d settled_cells=%0d profiles=%0d checks=%0d fields=59 output_bits=2075 max_free=%0d max_7_1=%0d max_1_7=%0d pending_holds=%0d pending_clear_ticks=%0d pending_clear_holds=%0d ignored_external_edges=%0d idle_ticks=%0d first_legs=%0d second_legs=%0d capacity_blocks=%0d dynamic_ticks=%0d first_cells=%0d second_cells=%0d signature=%h",
      matrix_cases, capture_barriers, settled_cells, profiles, checks,
      maximum_ticks[0], maximum_ticks[1], maximum_ticks[2], pending_holds,
      pending_clear_ticks, pending_clear_holds, ignored_external_edges, idle_ticks,
      first_legs, second_legs, capacity_blocks, dynamic_ticks, first_cells, second_cells, signature);
    completed = 1; $finish;
  end

  initial begin
    #10000000;
    $fatal(1, "M32 target-convergence watchdog expired");
  end
  final begin
    if (!completed) $fatal(1, "M32 target-convergence qualification ended early");
  end
endmodule
`endif

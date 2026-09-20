
// SPDX-License-Identifier: Apache-2.0
// M32 source -> registered target -> request mux -> retained execution.
// Independent ternary/cadence oracle; only public DUT ports are observed.
// Phase loads use exact cardinal angles. Continuous phase dynamics and the
// thermal model remain separate qualifications; this is not a v0.9.3 replay.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_execution_integration_tb;
  import frp_m31_pkg::*;
  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  logic phase_load_valid = 1, auto_target_enable = 0;
  logic [255:0] phase_load = 0, phase_word_q;
  logic [1:0] external_request_valid = 0, phase_request_valid, execution_request_valid;
  logic [5:0] external_request_cell_index = 0, phase_request_cell_index, execution_request_cell_index;
  logic [3:0] external_request_target = 0, phase_request_target, execution_request_target;
  logic [15:0] external_target_bank = 0, execution_target_bank, phase_target_source;
  logic [15:0] registered_target_q, state_out, pending_route_out;
  logic registered_target_valid_q, phase_target_domain_valid, registered_target_domain_valid;
  logic target_capture_accepted, target_capture_rejected, registered_request_enable;
  logic [31:0] accepted_target_capture_events_q, rejected_target_capture_events_q;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q, scheduler_count_balance_q;
  logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q, scheduler_count_neutralize_q;
  logic [1:0] request_accept, request_reject;
  logic [7:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
  logic [31:0] accepted_changes, capacity_remaining, switch_load_numerator;
  logic capacity_exhausted;
  logic [31:0] requested_direct_events, prevented_direct_events, neutral_routed_events;
  logic [31:0] actual_direct_events, reserved_state_events, queue_overflow_events;
  logic [9:0] invariant_flags;
  logic signed [31:0] normalized_cycle_cost_q16;

  frp_m32_core #(.CELLS(8), .REQUEST_LANES(2)) dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .scheduler_mode,
    .phase_load_valid, .phase_load, .frequency_load_q16(256'b0),
    .gamma_effective_word(256'b0), .thermal_node_factor_q30({8{32'h40000000}}),
    .auto_target_enable, .external_request_valid, .external_request_cell_index,
    .external_request_target, .external_target_bank, .phase_word_q,
    .frequency_current_q16(), .coupling_field_q16(), .phase_projection_q30(),
    .phase_target_source, .registered_target_q, .registered_target_valid_q,
    .phase_target_domain_valid, .registered_target_domain_valid,
    .target_capture_accepted, .target_capture_rejected, .accepted_target_capture_events_q,
    .rejected_target_capture_events_q, .registered_request_enable,
    .phase_request_valid, .phase_request_cell_index, .phase_request_target,
    .execution_request_valid, .execution_request_cell_index, .execution_request_target,
    .execution_target_bank, .state_out, .pending_route_out, .scheduler_mode_q,
    .scheduler_state_q, .ticks_recorded_q, .scheduler_count_free_q,
    .scheduler_count_balance_q, .scheduler_count_commit_q, .scheduler_count_excite_q,
    .scheduler_count_neutralize_q, .request_accept, .request_reject,
    .accepted_cell_mask, .neutral_routed_cell_mask, .accepted_change_mask,
    .accepted_changes, .capacity_remaining, .capacity_exhausted, .switch_load_numerator,
    .requested_direct_events, .prevented_direct_events, .neutral_routed_events,
    .actual_direct_events, .reserved_state_events, .queue_overflow_events, .invariant_flags,
    .normalized_cycle_cost_q16, .pair_coherence_q30(), .cluster_coherence_q30(),
    .global_coherence_q30(), .organization_dispersion_q30(), .temperature_proxy_q16(),
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stability_margin_q16(), .stable()
  );

  logic [255:0] gold_phase = 0;
  logic [15:0] gold_target = 0, gold_state = 0, gold_pending = 0;
  bit gold_valid = 0;
  int unsigned gold_captures = 0, gold_ticks = 0, gold_counts[5];
  int gold_mode = 0, gold_position = 0;
  logic [15:0] next_state, next_pending, source_word, selected_bank;
  logic [1:0] auto_valid, selected_valid, accept, reject;
  logic [5:0] auto_index, selected_index;
  logic [3:0] auto_target, selected_target;
  logic [7:0] writes, routes, accepted_cells, completions;
  int changes, candidate_routes, blocked_lanes;
  int checks = 0, steps = 0, resets = 0, matrix_cases = 0, mask_cases = 0;
  int stream_steps = 0, enabled_ticks = 0, held_ticks = 0;
  int clear_enabled = 0, clear_held = 0, first_legs = 0, second_legs = 0;
  int mux_changes = 0, target_lag_samples = 0, capacity_blocks = 0;
  logic [7:0] automatic_cells = 0, external_cells = 0, first_cells = 0, second_cells = 0;
  logic [4:0] scheduler_states = 0;
  bit prior_auto = 0;

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

  function automatic logic [15:0] put(input logic [15:0] bank, input int cell_index, v);
    logic [15:0] result;
    result = bank; result[2*cell_index +: 2] = symbol(v); return result;
  endfunction

  function automatic logic [255:0] phases(input logic [15:0] bank);
    logic [255:0] result;
    for (int i = 0; i < 8; i++)
      case (value(bank[2*i +: 2]))
        -1: result[32*i +: 32] = 32'hc0000000;
         0: result[32*i +: 32] = 32'h00000000;
         1: result[32*i +: 32] = 32'h40000000;
      endcase
    return result;
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
      // Reset phases include eighth turns; loaded phases are cardinal angles.
      case (gold_phase[32*i +: 32])
        32'h00000000, 32'h80000000: source_word[2*i +: 2] = symbol(0);
        32'h20000000, 32'h40000000, 32'h60000000: source_word[2*i +: 2] = symbol(1);
        32'ha0000000, 32'hc0000000, 32'he0000000: source_word[2*i +: 2] = symbol(-1);
        default: $fatal(1, "Unexpected oracle phase");
      endcase
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

  task automatic check;
    predict(); checks++;
    if (phase_word_q !== gold_phase || phase_target_source !== source_word ||
        registered_target_q !== gold_target || registered_target_valid_q !== gold_valid ||
        phase_target_domain_valid !== 1'b1 || registered_target_domain_valid !== 1'b1 ||
        target_capture_accepted !== tick_enable || target_capture_rejected !== 1'b0 ||
        accepted_target_capture_events_q !== gold_captures || rejected_target_capture_events_q !== 0 ||
        registered_request_enable !== (auto_target_enable && gold_valid))
      $fatal(1, "M32 capture mismatch step=%0d source=%h/%h saved=%h/%h", steps,
        phase_target_source, source_word, registered_target_q, gold_target);
    if ({phase_request_valid, phase_request_cell_index, phase_request_target} !==
        {auto_valid, auto_index, auto_target} ||
        {execution_request_valid, execution_request_cell_index, execution_request_target, execution_target_bank} !==
        {selected_valid, selected_index, selected_target, selected_bank})
      $fatal(1, "M32 request mux mismatch step=%0d auto=%b", steps, auto_target_enable);
    if (state_out !== gold_state || pending_route_out !== gold_pending ||
        scheduler_mode_q !== 2'(gold_mode) || scheduler_state_q !== 3'(cadence()) ||
        ticks_recorded_q !== gold_ticks || scheduler_count_free_q !== gold_counts[0] ||
        scheduler_count_balance_q !== gold_counts[1] || scheduler_count_commit_q !== gold_counts[2] ||
        scheduler_count_excite_q !== gold_counts[3] || scheduler_count_neutralize_q !== gold_counts[4])
      $fatal(1, "M32 retained mismatch step=%0d state=%h/%h pending=%h/%h", steps,
        state_out, gold_state, pending_route_out, gold_pending);
    if (request_accept !== accept || request_reject !== reject || accepted_cell_mask !== accepted_cells ||
        neutral_routed_cell_mask !== routes || accepted_change_mask !== writes ||
        accepted_changes !== 32'(changes) || capacity_remaining !== 32'(2-changes) ||
        capacity_exhausted !== (changes == 2) || switch_load_numerator !== 32'(changes) ||
        normalized_cycle_cost_q16 !== 32'(changes*8192) ||
        requested_direct_events !== 32'(candidate_routes) || prevented_direct_events !== 32'(candidate_routes) ||
        neutral_routed_events !== 32'(candidate_routes) || actual_direct_events !== 0 ||
        reserved_state_events !== 0 || queue_overflow_events !== 0 || invariant_flags !== 10'h3ff)
      $fatal(1, "M32 admission mismatch step=%0d mode=%0d state=%0d accept=%b/%b reject=%b/%b writes=%h/%h flags=%h",
        steps, gold_mode, cadence(), request_accept, accept, request_reject, reject,
        accepted_change_mask, writes, invariant_flags);
    for (int i = 0; i < 8; i++)
      if (value(gold_state[2*i +: 2]) * value(next_state[2*i +: 2]) == -1)
        $fatal(1, "Oracle attempted a direct opposite-polarity write");
  endtask

  task automatic step(input bit enabled, input bit clear = 0);
    if (enabled && !phase_load_valid) $fatal(1, "This test requires phase loads on enabled ticks");
    tick_enable = enabled; clear_counters = clear;
    #1; check();
    if (prior_auto != auto_target_enable) mux_changes++;
    prior_auto = auto_target_enable;
    if (source_word != gold_target) target_lag_samples++;
    if (clear) begin
      gold_captures = 0; gold_ticks = 0;
      foreach (gold_counts[i]) gold_counts[i] = 0;
      if (enabled) clear_enabled++; else clear_held++;
    end else if (enabled) gold_captures++;
    if (enabled) begin
      enabled_ticks++; scheduler_states[cadence()] = 1;
      gold_ticks++; gold_counts[cadence()]++; gold_position = (gold_position+1)%8;
      gold_target = source_word; gold_valid = 1;
      if (auto_target_enable) automatic_cells |= accepted_cells; else external_cells |= accepted_cells;
      first_legs += $countones(routes); second_legs += $countones(completions);
      first_cells |= routes; second_cells |= completions;
      capacity_blocks += blocked_lanes;
    end else held_ticks++;
    gold_state = next_state; gold_pending = next_pending;
    gold_mode = int'(scheduler_mode);
    if (phase_load_valid) gold_phase = phase_load;
    clk = 1; #1; steps++; check();
    clk = 0; #1; check();
  endtask

  task automatic reset_core;
    tick_enable = 0; clear_counters = 0; phase_load_valid = 0;
    auto_target_enable = 0; scheduler_mode = FRP_MODE_FREE;
    external_request_valid = 0; external_request_cell_index = 0;
    external_request_target = 0; external_target_bank = 0; phase_load = 0;
    #1; rst_n = 0;
    gold_target = 0; gold_valid = 0; gold_state = 0; gold_pending = 0;
    gold_captures = 0; gold_ticks = 0; gold_mode = 0; gold_position = 0;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    for (int i = 0; i < 8; i++) gold_phase[32*i +: 32] = 32'(i)*32'h20000000;
    #1; check(); clk = 1; #1; check(); clk = 0; #1; check();
    rst_n = 1; #1; check(); resets++; phase_load_valid = 1;
  endtask

  task automatic lane(input int lane_index, cell_index, goal);
    external_request_valid[lane_index] = 1;
    external_request_cell_index[3*lane_index +: 3] = 3'(cell_index);
    external_request_target[2*lane_index +: 2] = symbol(goal);
    external_target_bank = put(external_target_bank, cell_index, goal);
  endtask

  task automatic select_state(input int wanted);
    scheduler_mode = frp_m31_scheduler_mode_e'(wanted == 0 ? 0 : wanted < 3 ? 1 : 2);
    step(0);
    for (int i = 0; i < 8 && cadence() != wanted; i++) step(1);
    if (cadence() != wanted) $fatal(1, "Scheduler alignment failed");
  endtask

  initial begin : regression
    logic [15:0] goal_bank, saved_destination;
    logic [31:0] random_word;
    int wanted, cell_index;
    foreach (gold_counts[i]) gold_counts[i] = 0;
    // Both mux paths, every cell, all 9 transitions and 5 scheduler states,
    // with each combination of tick_enable and clear_counters.
    for (int path = 0; path < 2; path++)
      for (int sched = 0; sched < 5; sched++)
        for (int cell_id = 0; cell_id < 8; cell_id++)
          for (int old_value = -1; old_value <= 1; old_value++)
            for (int goal = -1; goal <= 1; goal++)
              for (int control = 0; control < 4; control++) begin
                reset_core(); goal_bank = put(0, cell_id, goal);
                phase_load = phases(goal_bank); step(0); step(1);
                lane(0, cell_id, old_value); step(1);
                external_request_valid = 0; select_state(sched);
                auto_target_enable = 1'(path);
                // The unselected external path deliberately disagrees with auto.
                lane(0, cell_id, path == 0 ? goal : -goal);
                step(control[0], control[1]); matrix_cases++;
                saved_destination = gold_pending;
                if (saved_destination != 0) begin
                  // New source and external goals must not overwrite a pending route.
                  auto_target_enable = 0; phase_load = phases(put(0, cell_id, old_value));
                  lane(0, cell_id, old_value); step(0, 1);
                  for (int n = 0; n < 8 && gold_pending != 0; n++) step(1);
                  if (gold_pending != 0 || gold_state[2*cell_id +: 2] != saved_destination[2*cell_id +: 2])
                    $fatal(1, "Pending destination failed to survive mux/clear/source changes");
                end
              end

    // Every cell mask reaches its target, then the opposite target, through
    // two-lane arbitration. Twelve ticks exceed the eight-cell drain bound.
    for (int mask = 0; mask < 256; mask++) begin
      reset_core(); auto_target_enable = 1;
      goal_bank = 0;
      for (int i = 0; i < 8; i++) if (mask[i]) goal_bank = put(goal_bank, i, i[0] ? -1 : 1);
      phase_load = phases(goal_bank); step(0);
      repeat (12) step(1);
      if (gold_state != goal_bank || gold_pending != 0) $fatal(1, "Mask failed to drain");
      for (int i = 0; i < 8; i++) goal_bank = put(goal_bank, i, -value(goal_bank[2*i +: 2]));
      phase_load = phases(goal_bank); step(0, 1);
      repeat (12) step(1);
      if (gold_state != goal_bank || gold_pending != 0) $fatal(1, "Opposite mask failed to drain");
      mask_cases++;
    end

    // Fixed local PRNG: repeatable live mux changes, duplicate lanes, phase
    // replacement, mode changes on held clocks, clears and asynchronous resets.
    random_word = 32'h32c09a71;
    for (int mode = 0; mode < 3; mode++) begin
      reset_core();
      for (int n = 0; n < 1024; n++) begin
        if (n != 0 && n % 257 == 0) reset_core();
        random_word = random_word*32'd1664525 + 32'd1013904223;
        scheduler_mode = frp_m31_scheduler_mode_e'(n % 31 == 0 ? (mode+1)%3 : mode);
        auto_target_enable = random_word[20];
        goal_bank = 0;
        for (int i = 0; i < 8; i++)
          goal_bank = put(goal_bank, i, int'((random_word >> (3*i)) % 3)-1);
        phase_load = phases(goal_bank);
        external_request_valid = 0; external_request_cell_index = 0;
        external_request_target = 0; external_target_bank = 0;
        for (int j = 0; j < 2; j++) begin
          cell_index = int'((random_word >> (7*j)) & 7);
          wanted = int'((random_word >> (9+j)) % 3)-1;
          lane(j, cell_index, wanted);
        end
        external_request_valid = random_word[29:28];
        step(random_word[27:26] != 0, n % 17 == 0); stream_steps++;
      end
    end
    if (matrix_cases != 2880 || mask_cases != 256 || stream_steps != 3072 ||
        checks != 3*steps+4*resets || automatic_cells != 8'hff || external_cells != 8'hff ||
        first_cells != 8'hff || second_cells != 8'hff || scheduler_states != 5'b11111 ||
        clear_enabled == 0 || clear_held == 0 || mux_changes == 0 ||
        target_lag_samples == 0 || capacity_blocks == 0 || first_legs == 0 || second_legs == 0)
      $fatal(1, "Incomplete M32 integration coverage");
    $display("FRP_M32_EXECUTION_INTEGRATION_TB: PASS cells=8 lanes=2 matrix_cases=%0d mask_cases=%0d stream_steps=%0d steps=%0d checks=%0d resets=%0d enabled_ticks=%0d held_ticks=%0d clear_enabled=%0d clear_held=%0d mux_changes=%0d target_lag_samples=%0d capacity_blocks=%0d first_legs=%0d second_legs=%0d automatic_cells=%0d external_cells=%0d first_cells=%0d second_cells=%0d scheduler_states=%0d",
      matrix_cases, mask_cases, stream_steps, steps, checks, resets, enabled_ticks, held_ticks,
      clear_enabled, clear_held, mux_changes, target_lag_samples, capacity_blocks,
      first_legs, second_legs, automatic_cells, external_cells, first_cells, second_cells, scheduler_states);
    $finish;
  end

  initial begin
    #2000000;
    $fatal(1, "M32 execution integration watchdog expired");
  end
endmodule

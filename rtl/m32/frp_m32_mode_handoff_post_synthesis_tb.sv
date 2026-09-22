// SPDX-License-Identifier: Apache-2.0
// Complete M32 netlist versus the unchanged mode-handoff RTL workload.
`ifndef FRP_M32_MODE_HANDOFF_POST_SYNTHESIS_TB_SV
`define FRP_M32_MODE_HANDOFF_POST_SYNTHESIS_TB_SV
`include "frp_m32_mode_handoff_tb.sv"

module frp_m32_mode_handoff_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;

  // Synthesize frp_m32_core with CELLS=8, REQUEST_LANES=2,
  // CELL_INDEX_BITS=3 and COUNTER_BITS=32; rename to frp_m32_core_netlist.
  // Keep every top-level port. The synthesis view removes only the four
  // initial sine-LUT assertions, as in workflow 01; the RTL stays intact.
  // The reference keeps its independent fixed-point oracle and watchdog.
  // Both implementations receive the same unmodified input events.
  // This is eight-cell RTL/netlist equivalence, not model v0.9.3 qualification.
  frp_m32_mode_handoff_tb reference_test();

  typedef struct packed {
    logic clk;
    logic rst_n;
    logic tick_enable;
    logic clear_counters;
    logic [1:0] scheduler_mode;
    logic phase_load_valid;
    logic [255:0] phase_load;
    logic [255:0] frequency_load_q16;
    logic [255:0] gamma_effective_word;
    logic [255:0] thermal_node_factor_q30;
    logic auto_target_enable;
    logic [1:0] external_request_valid;
    logic [5:0] external_request_cell_index;
    logic [3:0] external_request_target;
    logic [15:0] external_target_bank;
  } inputs_t;

  typedef struct packed {
    logic [255:0] phase_word_q;
    logic [255:0] frequency_current_q16;
    logic [255:0] coupling_field_q16;
    logic [255:0] phase_projection_q30;
    logic [15:0] phase_target_source;
    logic [15:0] registered_target_q;
    logic registered_target_valid_q;
    logic phase_target_domain_valid;
    logic registered_target_domain_valid;
    logic target_capture_accepted;
    logic target_capture_rejected;
    logic [31:0] accepted_target_capture_events_q;
    logic [31:0] rejected_target_capture_events_q;
    logic registered_request_enable;
    logic [1:0] phase_request_valid;
    logic [5:0] phase_request_cell_index;
    logic [3:0] phase_request_target;
    logic [1:0] execution_request_valid;
    logic [5:0] execution_request_cell_index;
    logic [3:0] execution_request_target;
    logic [15:0] execution_target_bank;
    logic [15:0] state_out;
    logic [15:0] pending_route_out;
    logic [1:0] scheduler_mode_q;
    logic [2:0] scheduler_state_q;
    logic [31:0] ticks_recorded_q;
    logic [31:0] scheduler_count_free_q;
    logic [31:0] scheduler_count_balance_q;
    logic [31:0] scheduler_count_commit_q;
    logic [31:0] scheduler_count_excite_q;
    logic [31:0] scheduler_count_neutralize_q;
    logic [1:0] request_accept;
    logic [1:0] request_reject;
    logic [7:0] accepted_cell_mask;
    logic [7:0] neutral_routed_cell_mask;
    logic [7:0] accepted_change_mask;
    logic [31:0] accepted_changes;
    logic [31:0] capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load_numerator;
    logic [31:0] requested_direct_events;
    logic [31:0] prevented_direct_events;
    logic [31:0] neutral_routed_events;
    logic [31:0] actual_direct_events;
    logic [31:0] reserved_state_events;
    logic [31:0] queue_overflow_events;
    logic [9:0] invariant_flags;
    logic [31:0] pair_coherence_q30;
    logic [31:0] cluster_coherence_q30;
    logic [31:0] global_coherence_q30;
    logic [31:0] organization_dispersion_q30;
    logic [31:0] normalized_cycle_cost_q16;
    logic [31:0] temperature_proxy_q16;
    logic [31:0] peak_temperature_proxy_q16;
    logic [31:0] thermal_sample_count_q;
    logic [31:0] coherence_capacity_q16;
    logic [31:0] pressure_q16;
    logic [31:0] stability_margin_q16;
    logic stable;
  } outputs_t;

  localparam int INPUT_BITS = $bits(inputs_t);
  localparam int OUTPUT_BITS = $bits(outputs_t);
  wire inputs_t inputs;
  wire outputs_t reference_outputs;
  outputs_t netlist_outputs, previous_outputs;
  inputs_t previous_inputs;
  bit armed = 0, mismatch_seen = 0;
  int unsigned comparisons = 0, input_changes = 0;
  int unsigned enabled_ticks = 0, hold_edges = 0, falling_edges = 0;
  int unsigned reset_assertions = 0, reset_clock_edges = 0, reset_releases = 0;
  int unsigned clear_tick_edges = 0, clear_hold_edges = 0, phase_load_edges = 0;
  int unsigned automatic_ticks = 0, external_ticks = 0;
  int unsigned first_legs = 0, second_legs = 0;
  logic [7:0] first_cells = 0, second_cells = 0;
  logic [4:0] scheduler_states = 0;
  int unsigned dynamic_ticks = 0, dynamic_streak = 0, longest_streak = 0;
  int unsigned phase_updates = 0, frequency_updates = 0;
  int unsigned stopped_clock_changes = 0, pending_resets = 0, target_lag_samples = 0;
  int unsigned state_feedback_samples = 0, switch_feedback_samples = 0;
  int unsigned heating_ticks = 0, cooling_ticks = 0;
  int unsigned state_hits[5];
  int unsigned mode_capture_edges = 0, mode_change_edges = 0;
  int unsigned mode_change_ticks = 0, mode_change_holds = 0;
  int unsigned mode_change_clears = 0, mode_change_loads = 0;
  int unsigned mode_change_automatic = 0, pending_mode_changes = 0;
  int unsigned dynamic_mode_changes = 0, handoff_phase_updates = 0;
  int unsigned mode_input_changes = 0, stopped_clock_mode_changes = 0;
  logic [1:0] expected_mode = 0;
  int unsigned expected_position = 0;

  // Track the registered cadence using input events and literal mode rules.
  // A mode write and counter clear preserve the eight-tick cycle position.
  function automatic logic [2:0] cadence(input logic [1:0] mode,
                                        input int unsigned position);
    case (mode)
      2'd0: return 3'd0;
      2'd1: return position == 7 ? 3'd2 : 3'd1;
      2'd2: return position == 0 ? 3'd3 : 3'd4;
      default: return 3'd7;
    endcase
  endfunction

  // DUT reads use public ports only; final checks also inspect testbench counters.
  // Every reference output is independently checked by its unchanged oracle.
  assign inputs = '{
    clk: reference_test.dut.clk,
    rst_n: reference_test.dut.rst_n,
    tick_enable: reference_test.dut.tick_enable,
    clear_counters: reference_test.dut.clear_counters,
    scheduler_mode: reference_test.dut.scheduler_mode,
    phase_load_valid: reference_test.dut.phase_load_valid,
    phase_load: reference_test.dut.phase_load,
    frequency_load_q16: reference_test.dut.frequency_load_q16,
    gamma_effective_word: reference_test.dut.gamma_effective_word,
    thermal_node_factor_q30: reference_test.dut.thermal_node_factor_q30,
    auto_target_enable: reference_test.dut.auto_target_enable,
    external_request_valid: reference_test.dut.external_request_valid,
    external_request_cell_index: reference_test.dut.external_request_cell_index,
    external_request_target: reference_test.dut.external_request_target,
    external_target_bank: reference_test.dut.external_target_bank
  };

  assign reference_outputs = '{
    phase_word_q: reference_test.dut.phase_word_q,
    frequency_current_q16: reference_test.dut.frequency_current_q16,
    coupling_field_q16: reference_test.dut.coupling_field_q16,
    phase_projection_q30: reference_test.dut.phase_projection_q30,
    phase_target_source: reference_test.dut.phase_target_source,
    registered_target_q: reference_test.dut.registered_target_q,
    registered_target_valid_q: reference_test.dut.registered_target_valid_q,
    phase_target_domain_valid: reference_test.dut.phase_target_domain_valid,
    registered_target_domain_valid: reference_test.dut.registered_target_domain_valid,
    target_capture_accepted: reference_test.dut.target_capture_accepted,
    target_capture_rejected: reference_test.dut.target_capture_rejected,
    accepted_target_capture_events_q: reference_test.dut.accepted_target_capture_events_q,
    rejected_target_capture_events_q: reference_test.dut.rejected_target_capture_events_q,
    registered_request_enable: reference_test.dut.registered_request_enable,
    phase_request_valid: reference_test.dut.phase_request_valid,
    phase_request_cell_index: reference_test.dut.phase_request_cell_index,
    phase_request_target: reference_test.dut.phase_request_target,
    execution_request_valid: reference_test.dut.execution_request_valid,
    execution_request_cell_index: reference_test.dut.execution_request_cell_index,
    execution_request_target: reference_test.dut.execution_request_target,
    execution_target_bank: reference_test.dut.execution_target_bank,
    state_out: reference_test.dut.state_out,
    pending_route_out: reference_test.dut.pending_route_out,
    scheduler_mode_q: reference_test.dut.scheduler_mode_q,
    scheduler_state_q: reference_test.dut.scheduler_state_q,
    ticks_recorded_q: reference_test.dut.ticks_recorded_q,
    scheduler_count_free_q: reference_test.dut.scheduler_count_free_q,
    scheduler_count_balance_q: reference_test.dut.scheduler_count_balance_q,
    scheduler_count_commit_q: reference_test.dut.scheduler_count_commit_q,
    scheduler_count_excite_q: reference_test.dut.scheduler_count_excite_q,
    scheduler_count_neutralize_q: reference_test.dut.scheduler_count_neutralize_q,
    request_accept: reference_test.dut.request_accept,
    request_reject: reference_test.dut.request_reject,
    accepted_cell_mask: reference_test.dut.accepted_cell_mask,
    neutral_routed_cell_mask: reference_test.dut.neutral_routed_cell_mask,
    accepted_change_mask: reference_test.dut.accepted_change_mask,
    accepted_changes: reference_test.dut.accepted_changes,
    capacity_remaining: reference_test.dut.capacity_remaining,
    capacity_exhausted: reference_test.dut.capacity_exhausted,
    switch_load_numerator: reference_test.dut.switch_load_numerator,
    requested_direct_events: reference_test.dut.requested_direct_events,
    prevented_direct_events: reference_test.dut.prevented_direct_events,
    neutral_routed_events: reference_test.dut.neutral_routed_events,
    actual_direct_events: reference_test.dut.actual_direct_events,
    reserved_state_events: reference_test.dut.reserved_state_events,
    queue_overflow_events: reference_test.dut.queue_overflow_events,
    invariant_flags: reference_test.dut.invariant_flags,
    pair_coherence_q30: reference_test.dut.pair_coherence_q30,
    cluster_coherence_q30: reference_test.dut.cluster_coherence_q30,
    global_coherence_q30: reference_test.dut.global_coherence_q30,
    organization_dispersion_q30: reference_test.dut.organization_dispersion_q30,
    normalized_cycle_cost_q16: reference_test.dut.normalized_cycle_cost_q16,
    temperature_proxy_q16: reference_test.dut.temperature_proxy_q16,
    peak_temperature_proxy_q16: reference_test.dut.peak_temperature_proxy_q16,
    thermal_sample_count_q: reference_test.dut.thermal_sample_count_q,
    coherence_capacity_q16: reference_test.dut.coherence_capacity_q16,
    pressure_q16: reference_test.dut.pressure_q16,
    stability_margin_q16: reference_test.dut.stability_margin_q16,
    stable: reference_test.dut.stable
  };

  frp_m32_core_netlist u_m32_netlist (
    .clk(inputs.clk),
    .rst_n(inputs.rst_n),
    .tick_enable(inputs.tick_enable),
    .clear_counters(inputs.clear_counters),
    .scheduler_mode(inputs.scheduler_mode),
    .phase_load_valid(inputs.phase_load_valid),
    .phase_load(inputs.phase_load),
    .frequency_load_q16(inputs.frequency_load_q16),
    .gamma_effective_word(inputs.gamma_effective_word),
    .thermal_node_factor_q30(inputs.thermal_node_factor_q30),
    .auto_target_enable(inputs.auto_target_enable),
    .external_request_valid(inputs.external_request_valid),
    .external_request_cell_index(inputs.external_request_cell_index),
    .external_request_target(inputs.external_request_target),
    .external_target_bank(inputs.external_target_bank),
    .phase_word_q(netlist_outputs.phase_word_q),
    .frequency_current_q16(netlist_outputs.frequency_current_q16),
    .coupling_field_q16(netlist_outputs.coupling_field_q16),
    .phase_projection_q30(netlist_outputs.phase_projection_q30),
    .phase_target_source(netlist_outputs.phase_target_source),
    .registered_target_q(netlist_outputs.registered_target_q),
    .registered_target_valid_q(netlist_outputs.registered_target_valid_q),
    .phase_target_domain_valid(netlist_outputs.phase_target_domain_valid),
    .registered_target_domain_valid(netlist_outputs.registered_target_domain_valid),
    .target_capture_accepted(netlist_outputs.target_capture_accepted),
    .target_capture_rejected(netlist_outputs.target_capture_rejected),
    .accepted_target_capture_events_q(netlist_outputs.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(netlist_outputs.rejected_target_capture_events_q),
    .registered_request_enable(netlist_outputs.registered_request_enable),
    .phase_request_valid(netlist_outputs.phase_request_valid),
    .phase_request_cell_index(netlist_outputs.phase_request_cell_index),
    .phase_request_target(netlist_outputs.phase_request_target),
    .execution_request_valid(netlist_outputs.execution_request_valid),
    .execution_request_cell_index(netlist_outputs.execution_request_cell_index),
    .execution_request_target(netlist_outputs.execution_request_target),
    .execution_target_bank(netlist_outputs.execution_target_bank),
    .state_out(netlist_outputs.state_out),
    .pending_route_out(netlist_outputs.pending_route_out),
    .scheduler_mode_q(netlist_outputs.scheduler_mode_q),
    .scheduler_state_q(netlist_outputs.scheduler_state_q),
    .ticks_recorded_q(netlist_outputs.ticks_recorded_q),
    .scheduler_count_free_q(netlist_outputs.scheduler_count_free_q),
    .scheduler_count_balance_q(netlist_outputs.scheduler_count_balance_q),
    .scheduler_count_commit_q(netlist_outputs.scheduler_count_commit_q),
    .scheduler_count_excite_q(netlist_outputs.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(netlist_outputs.scheduler_count_neutralize_q),
    .request_accept(netlist_outputs.request_accept),
    .request_reject(netlist_outputs.request_reject),
    .accepted_cell_mask(netlist_outputs.accepted_cell_mask),
    .neutral_routed_cell_mask(netlist_outputs.neutral_routed_cell_mask),
    .accepted_change_mask(netlist_outputs.accepted_change_mask),
    .accepted_changes(netlist_outputs.accepted_changes),
    .capacity_remaining(netlist_outputs.capacity_remaining),
    .capacity_exhausted(netlist_outputs.capacity_exhausted),
    .switch_load_numerator(netlist_outputs.switch_load_numerator),
    .requested_direct_events(netlist_outputs.requested_direct_events),
    .prevented_direct_events(netlist_outputs.prevented_direct_events),
    .neutral_routed_events(netlist_outputs.neutral_routed_events),
    .actual_direct_events(netlist_outputs.actual_direct_events),
    .reserved_state_events(netlist_outputs.reserved_state_events),
    .queue_overflow_events(netlist_outputs.queue_overflow_events),
    .invariant_flags(netlist_outputs.invariant_flags),
    .pair_coherence_q30(netlist_outputs.pair_coherence_q30),
    .cluster_coherence_q30(netlist_outputs.cluster_coherence_q30),
    .global_coherence_q30(netlist_outputs.global_coherence_q30),
    .organization_dispersion_q30(netlist_outputs.organization_dispersion_q30),
    .normalized_cycle_cost_q16(netlist_outputs.normalized_cycle_cost_q16),
    .temperature_proxy_q16(netlist_outputs.temperature_proxy_q16),
    .peak_temperature_proxy_q16(netlist_outputs.peak_temperature_proxy_q16),
    .thermal_sample_count_q(netlist_outputs.thermal_sample_count_q),
    .coherence_capacity_q16(netlist_outputs.coherence_capacity_q16),
    .pressure_q16(netlist_outputs.pressure_q16),
    .stability_margin_q16(netlist_outputs.stability_margin_q16),
    .stable(netlist_outputs.stable)
  );

  task automatic compare_settled;
    bit rising_edge, falling_edge, reset_assertion, reset_release;
    inputs_t controls, previous_controls;
    logic [1:0] before_state, after_state, destination;
    rising_edge = !previous_inputs.clk && inputs.clk;
    falling_edge = previous_inputs.clk && !inputs.clk;
    reset_assertion = previous_inputs.rst_n && !inputs.rst_n;
    reset_release = !previous_inputs.rst_n && inputs.rst_n;
    controls = inputs; previous_controls = previous_inputs;
    controls.clk = 0; controls.rst_n = 0;
    previous_controls.clk = 0; previous_controls.rst_n = 0;
    if (reset_assertion) armed = 1;
    if (armed) begin
      if ($isunknown({reference_outputs, netlist_outputs}) ||
          reference_outputs !== netlist_outputs) begin
        mismatch_seen = 1;
        $fatal(1, "M32 mode-handoff post-synthesis mismatch time=%0t step=%0d difference=%h reference=%h netlist=%h",
          $time, reference_test.steps, reference_outputs ^ netlist_outputs,
          reference_outputs, netlist_outputs);
      end
      // Register capture is independent of tick enable; phase advancement
      // still uses the old registered cadence, checked by the RTL oracle.
      if (reset_assertion || (rising_edge && !inputs.rst_n)) begin
        expected_mode = 0; expected_position = 0;
      end else if (rising_edge && inputs.rst_n) begin
        expected_mode = inputs.scheduler_mode;
        if (inputs.tick_enable) expected_position = (expected_position+1)%8;
      end
      if (netlist_outputs.scheduler_mode_q !== expected_mode ||
          netlist_outputs.scheduler_state_q !== cadence(expected_mode, expected_position)) begin
        mismatch_seen = 1;
        $fatal(1, "M32 netlist mode capture or cycle position mismatch");
      end
      comparisons++;
      if (controls !== previous_controls) begin
        input_changes++;
        if (inputs.rst_n && !inputs.clk && !rising_edge && !falling_edge &&
            !reset_assertion && !reset_release) stopped_clock_changes++;
      end
      if (inputs.rst_n && inputs.scheduler_mode !== previous_inputs.scheduler_mode) begin
        mode_input_changes++;
        if (!inputs.clk && !rising_edge && !falling_edge && !reset_release)
          stopped_clock_mode_changes++;
      end
      if (reset_assertion) begin
        reset_assertions++; dynamic_streak = 0;
        if (previous_outputs.pending_route_out != 0) pending_resets++;
      end
      if (reset_release) reset_releases++;
      if (falling_edge) falling_edges++;
      if (rising_edge) begin
        if (!inputs.rst_n) reset_clock_edges++;
        else begin
          mode_capture_edges++;
          if (inputs.scheduler_mode != previous_outputs.scheduler_mode_q) begin
            mode_change_edges++;
            if (inputs.tick_enable) mode_change_ticks++; else mode_change_holds++;
            if (inputs.clear_counters) mode_change_clears++;
            if (inputs.phase_load_valid) mode_change_loads++;
            if (inputs.auto_target_enable) mode_change_automatic++;
            if (previous_outputs.pending_route_out != 0) pending_mode_changes++;
            if (inputs.tick_enable && !inputs.phase_load_valid) begin
              dynamic_mode_changes++;
              if (netlist_outputs.phase_word_q != previous_outputs.phase_word_q)
                handoff_phase_updates++;
            end
            if (!inputs.tick_enable &&
                (netlist_outputs.state_out !== previous_outputs.state_out ||
                 netlist_outputs.pending_route_out !== previous_outputs.pending_route_out ||
                 netlist_outputs.registered_target_q !== previous_outputs.registered_target_q)) begin
              mismatch_seen = 1;
              $fatal(1, "Held M32 netlist mode change lost retained execution or target history");
            end
          end
          if (inputs.phase_load_valid) begin
            phase_load_edges++; dynamic_streak = 0;
          end
          if (inputs.clear_counters) begin
            if (inputs.tick_enable) clear_tick_edges++; else clear_hold_edges++;
          end
          if (inputs.tick_enable) begin
            enabled_ticks++;
            if (inputs.auto_target_enable) automatic_ticks++; else external_ticks++;
            if (previous_outputs.scheduler_state_q > 4) begin
              mismatch_seen = 1;
              $fatal(1, "Invalid M32 netlist scheduler state");
            end
            scheduler_states[previous_outputs.scheduler_state_q] = 1;
            state_hits[previous_outputs.scheduler_state_q]++;
            if (previous_outputs.phase_target_source != previous_outputs.registered_target_q)
              target_lag_samples++;
            if (!inputs.phase_load_valid) begin
              dynamic_ticks++; dynamic_streak++;
              if (dynamic_streak > longest_streak) longest_streak = dynamic_streak;
              if (netlist_outputs.phase_word_q != previous_outputs.phase_word_q) phase_updates++;
              if (netlist_outputs.frequency_current_q16 != previous_outputs.frequency_current_q16)
                frequency_updates++;
              for (int i = 0; i < 8; i++)
                if (previous_outputs.state_out[2*i +: 2] != 0) state_feedback_samples++;
              switch_feedback_samples += $countones(previous_outputs.accepted_change_mask);
            end
            if (!inputs.clear_counters) begin
              if ($signed(netlist_outputs.temperature_proxy_q16) >
                  $signed(previous_outputs.temperature_proxy_q16)) heating_ticks++;
              if ($signed(netlist_outputs.temperature_proxy_q16) <
                  $signed(previous_outputs.temperature_proxy_q16)) cooling_ticks++;
            end
            first_legs += $countones(previous_outputs.neutral_routed_cell_mask);
            first_cells |= previous_outputs.neutral_routed_cell_mask;
            // Observe admission before the edge and retained writeback after it.
            // Opposite polarities require two active-zero legs on separate ticks.
            for (int i = 0; i < 8; i++) begin
              before_state = previous_outputs.state_out[2*i +: 2];
              after_state = netlist_outputs.state_out[2*i +: 2];
              destination = previous_outputs.pending_route_out[2*i +: 2];
              if ((before_state == 2'b11 && after_state == 2'b01) ||
                  (before_state == 2'b01 && after_state == 2'b11)) begin
                mismatch_seen = 1;
                $fatal(1, "M32 netlist performed a direct opposite-polarity write");
              end
              if (previous_outputs.neutral_routed_cell_mask[i] &&
                  (after_state != 0 || netlist_outputs.pending_route_out[2*i +: 2] == 0)) begin
                mismatch_seen = 1;
                $fatal(1, "M32 netlist lost the first active-zero route leg");
              end
              if (destination != 0 && netlist_outputs.pending_route_out[2*i +: 2] == 0) begin
                if (before_state != 0 || after_state != destination) begin
                  mismatch_seen = 1;
                  $fatal(1, "M32 netlist lost a retained route destination");
                end
                second_legs++; second_cells[i] = 1;
              end
            end
          end else hold_edges++;
        end
      end
    end
    previous_inputs = inputs;
    previous_outputs = netlist_outputs;
  endtask

  // Sample once at initialization, then after every external input event.
  // One femtosecond settles zero-delay cells before the reference's 1 ns checks.
  // Compare all bits during reset as well, including the public diagnostic flags.
  initial begin
    if (INPUT_BITS != 1060 || OUTPUT_BITS != 2075)
      $fatal(1, "Incomplete M32 mode-handoff port bundles");
    previous_inputs = '0; previous_inputs.rst_n = 1;
    previous_outputs = '0;
    foreach (state_hits[i]) state_hits[i] = 0;
    #1fs; compare_settled();
    forever begin
      @(inputs);
      #1fs; compare_settled();
    end
  end

  final begin
    if (!armed || mismatch_seen || input_changes == 0 || stopped_clock_changes == 0 ||
        comparisons < 2*reference_test.steps + 4*reference_test.resets ||
        enabled_ticks != 30848 || dynamic_ticks != 30560 || longest_streak != 1024 ||
        phase_updates != 30560 || frequency_updates == 0 || hold_edges != 1918 ||
        falling_edges != 33920 || reset_assertions != 1154 || reset_clock_edges != 1154 ||
        reset_releases != 1154 || pending_resets != 0 ||
        clear_tick_edges != 322 || clear_hold_edges != 382 || phase_load_edges != 1730 ||
        automatic_ticks != 2042 || external_ticks != 28806 ||
        automatic_ticks + external_ticks != enabled_ticks ||
        first_legs != 2586 || second_legs != 2586 ||
        first_cells != 8'hff || second_cells != 8'hff || scheduler_states != 5'b11111 ||
        target_lag_samples != 8491 || state_feedback_samples != 205942 ||
        switch_feedback_samples != 14934 || heating_ticks != 7789 || cooling_ticks != 19590 ||
        state_hits[0] != 16792 || state_hits[1] != 6187 || state_hits[2] != 886 ||
        state_hits[3] != 876 || state_hits[4] != 6107)
      $fatal(1, "Incomplete M32 mode-handoff post-synthesis coverage comparisons=%0d inputs=%0d ticks=%0d dynamic=%0d phase=%0d frequency=%0d holds=%0d falls=%0d resets=%0d/%0d/%0d pending_resets=%0d clears=%0d/%0d loads=%0d routes=%0d/%0d feedback=%0d/%0d thermal=%0d/%0d",
        comparisons, input_changes, enabled_ticks, dynamic_ticks, phase_updates, frequency_updates,
        hold_edges, falling_edges, reset_assertions, reset_clock_edges, reset_releases, pending_resets,
        clear_tick_edges, clear_hold_edges, phase_load_edges, first_legs, second_legs,
        state_feedback_samples, switch_feedback_samples, heating_ticks, cooling_ticks);
    // 768 setup captures, 768 matrix changes and 1346 continuous-stream changes.
    if (mode_capture_edges != 32766 || mode_change_edges != 2882 ||
        mode_change_ticks + mode_change_holds != mode_change_edges ||
        mode_change_holds < 384 || mode_change_clears < 384 || mode_change_loads != 384 ||
        mode_change_automatic < 384 || pending_mode_changes < 768 ||
        dynamic_mode_changes < 960 || handoff_phase_updates != dynamic_mode_changes ||
        mode_input_changes == 0 || stopped_clock_mode_changes < 100)
      $fatal(1, "Incomplete M32 netlist mode-change coverage captures=%0d changes=%0d ticks=%0d holds=%0d clears=%0d loads=%0d automatic=%0d pending=%0d dynamic=%0d phase=%0d input_changes=%0d stopped_changes=%0d",
        mode_capture_edges, mode_change_edges, mode_change_ticks, mode_change_holds,
        mode_change_clears, mode_change_loads, mode_change_automatic, pending_mode_changes,
        dynamic_mode_changes, handoff_phase_updates, mode_input_changes, stopped_clock_mode_changes);
    if (reference_test.profiles != 3 || reference_test.steps != 32766 ||
        reference_test.checks != 103014 || reference_test.live_control_checks != 100 ||
        reference_test.matrix_cases != 1152 || reference_test.stream_ticks != 2048 ||
        reference_test.stream_mode_changes != 1346 ||
        reference_test.changed_modes != 768 || reference_test.unchanged_modes != 384 ||
        reference_test.tick_handoffs != 576 || reference_test.held_handoffs != 576 ||
        reference_test.clear_handoffs != 576 || reference_test.load_handoffs != 576 ||
        reference_test.auto_handoffs != 576 || reference_test.continuous_handoffs != 192 ||
        reference_test.continuous_phase_updates != 192 || reference_test.held_route_checks != 576 ||
        reference_test.drained_route_checks != 1152 || reference_test.load_tick_lags != 288 ||
        reference_test.resets != reset_assertions || reference_test.pending_resets != pending_resets ||
        reference_test.dynamic_ticks != dynamic_ticks || reference_test.longest_streak != longest_streak ||
        reference_test.held_edges != hold_edges || reference_test.loads != phase_load_edges ||
        reference_test.clear_ticks != clear_tick_edges || reference_test.clear_holds != clear_hold_edges ||
        reference_test.automatic_ticks != automatic_ticks || reference_test.external_ticks != external_ticks ||
        reference_test.target_lag_samples != target_lag_samples ||
        reference_test.state_feedback_samples != state_feedback_samples ||
        reference_test.switch_feedback_samples != switch_feedback_samples ||
        reference_test.heating_ticks != heating_ticks || reference_test.cooling_ticks != cooling_ticks ||
        reference_test.first_legs != first_legs || reference_test.second_legs != second_legs ||
        reference_test.first_cells != first_cells || reference_test.second_cells != second_cells)
      $fatal(1, "Incomplete M32 mode-handoff reference qualification");
    foreach (state_hits[i])
      if (state_hits[i] != reference_test.state_hits[i])
        $fatal(1, "M32 mode-handoff scheduler-state counts differ");
    foreach (reference_test.coverage_hits[a,b,c,d])
      if (reference_test.coverage_hits[a][b][c][d] != 1)
        $fatal(1, "Incomplete M32 mode-handoff reference matrix");
    if ($isunknown({reference_outputs, netlist_outputs}) || reference_outputs !== netlist_outputs)
      $fatal(1, "Final M32 mode-handoff output mismatch");
    $display("FRP_M32_MODE_HANDOFF_POST_SYNTHESIS_TB: PASS comparisons=%0d input_bits=%0d output_bits=%0d input_changes=%0d stopped_clock_changes=%0d enabled_ticks=%0d dynamic_ticks=%0d longest_streak=%0d phase_updates=%0d frequency_updates=%0d hold_edges=%0d falling_edges=%0d reset_assertions=%0d reset_clock_edges=%0d reset_releases=%0d pending_resets=%0d clear_tick_edges=%0d clear_hold_edges=%0d phase_load_edges=%0d automatic_ticks=%0d external_ticks=%0d target_lag_samples=%0d state_feedback_samples=%0d switch_feedback_samples=%0d heating_ticks=%0d cooling_ticks=%0d first_legs=%0d second_legs=%0d first_cells=%0d second_cells=%0d scheduler_states=%0d free_ticks=%0d balance_ticks=%0d commit_ticks=%0d excite_ticks=%0d neutralize_ticks=%0d mode_capture_edges=%0d mode_change_edges=%0d mode_change_ticks=%0d mode_change_holds=%0d mode_change_clears=%0d mode_change_loads=%0d mode_change_automatic=%0d pending_mode_changes=%0d dynamic_mode_changes=%0d handoff_phase_updates=%0d mode_input_changes=%0d stopped_clock_mode_changes=%0d reference_profiles=%0d reference_steps=%0d reference_checks=%0d reference_live_control_checks=%0d matrix_cases=%0d stream_ticks=%0d stream_mode_changes=%0d",
      comparisons, INPUT_BITS, OUTPUT_BITS, input_changes, stopped_clock_changes,
      enabled_ticks, dynamic_ticks, longest_streak, phase_updates, frequency_updates,
      hold_edges, falling_edges, reset_assertions, reset_clock_edges, reset_releases, pending_resets,
      clear_tick_edges, clear_hold_edges, phase_load_edges, automatic_ticks, external_ticks,
      target_lag_samples, state_feedback_samples, switch_feedback_samples, heating_ticks, cooling_ticks,
      first_legs, second_legs, first_cells, second_cells, scheduler_states,
      state_hits[0], state_hits[1], state_hits[2], state_hits[3], state_hits[4],
      mode_capture_edges, mode_change_edges, mode_change_ticks, mode_change_holds,
      mode_change_clears, mode_change_loads, mode_change_automatic, pending_mode_changes,
      dynamic_mode_changes, handoff_phase_updates, mode_input_changes, stopped_clock_mode_changes,
      reference_test.profiles, reference_test.steps, reference_test.checks, reference_test.live_control_checks,
      reference_test.matrix_cases, reference_test.stream_ticks, reference_test.stream_mode_changes);
  end
endmodule : frp_m32_mode_handoff_post_synthesis_tb
`endif

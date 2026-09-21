// SPDX-License-Identifier: Apache-2.0
// Complete M32 counter boundaries under the unchanged closed-loop workload.
// Scheduler telemetry wraps modulo 2**COUNTER_BITS; target capture saturates.
// Compare every public output with the independently checked 32-bit reference.
// Only those eight telemetry fields are transformed; execution, phase,
// retained frequency, thermal feedback and the invariant flags remain exact.
// Profiles use 4/5-bit counters: both represent all eight cells and the
// scheduler's complete modulo-eight period. No internal DUT state is accessed.
// This is RTL qualification; it does not compare model v0.9.3.
`ifndef FRP_M32_COUNTER_BOUNDARY_TB_SV
`define FRP_M32_COUNTER_BOUNDARY_TB_SV
`include "frp_m32_closed_loop_tb.sv"

package frp_m32_counter_boundary_tb_pkg;
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

endpackage

module frp_m32_counter_boundary_case #(
  parameter int COUNTER_BITS = 4
) (
  input frp_m32_counter_boundary_tb_pkg::inputs_t inputs,
  input frp_m32_counter_boundary_tb_pkg::outputs_t reference_outputs
);
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m32_counter_boundary_tb_pkg::*;
  localparam int unsigned LIMIT = (1 << COUNTER_BITS)-1;
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
    logic [COUNTER_BITS-1:0] accepted_target_capture_events_q;
    logic [COUNTER_BITS-1:0] rejected_target_capture_events_q;
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
    logic [COUNTER_BITS-1:0] ticks_recorded_q;
    logic [COUNTER_BITS-1:0] scheduler_count_free_q;
    logic [COUNTER_BITS-1:0] scheduler_count_balance_q;
    logic [COUNTER_BITS-1:0] scheduler_count_commit_q;
    logic [COUNTER_BITS-1:0] scheduler_count_excite_q;
    logic [COUNTER_BITS-1:0] scheduler_count_neutralize_q;
    logic [1:0] request_accept;
    logic [1:0] request_reject;
    logic [7:0] accepted_cell_mask;
    logic [7:0] neutral_routed_cell_mask;
    logic [7:0] accepted_change_mask;
    logic [COUNTER_BITS-1:0] accepted_changes;
    logic [COUNTER_BITS-1:0] capacity_remaining;
    logic capacity_exhausted;
    logic [COUNTER_BITS-1:0] switch_load_numerator;
    logic [COUNTER_BITS-1:0] requested_direct_events;
    logic [COUNTER_BITS-1:0] prevented_direct_events;
    logic [COUNTER_BITS-1:0] neutral_routed_events;
    logic [COUNTER_BITS-1:0] actual_direct_events;
    logic [COUNTER_BITS-1:0] reserved_state_events;
    logic [COUNTER_BITS-1:0] queue_overflow_events;
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
  } narrow_outputs_t;


  narrow_outputs_t narrow_outputs;
  wire outputs_t actual;
  outputs_t expected, previous_outputs;
  inputs_t previous_inputs;
  bit armed = 0, mismatch_seen = 0, wrapped_in_epoch = 0;
  int unsigned comparisons = 0, enabled_ticks = 0, held_edges = 0;
  int unsigned resets = 0, clear_ticks = 0, clear_holds = 0;
  int unsigned tick_wraps = 0, scheduler_wraps[5];
  int unsigned capture_limit_entries = 0, saturated_capture_ticks = 0;
  int unsigned saturation_clear_ticks = 0, saturation_clear_holds = 0;
  int unsigned ticks_after_wrap = 0, phase_updates_after_wrap = 0;
  int unsigned frequency_updates_after_wrap = 0, phase_updates_at_saturation = 0;
  int unsigned first_legs_at_saturation = 0, second_legs_at_saturation = 0;
  logic [2:0] wrap_modes = 0, saturation_modes = 0;
  logic [4:0] scheduler_wrap_mask = 0;

  // Width adapters zero-extend unsigned port values; they never truncate
  // the wide reference's per-tick event counts or state and feedback outputs.
  assign actual = '{
    phase_word_q: narrow_outputs.phase_word_q,
    frequency_current_q16: narrow_outputs.frequency_current_q16,
    coupling_field_q16: narrow_outputs.coupling_field_q16,
    phase_projection_q30: narrow_outputs.phase_projection_q30,
    phase_target_source: narrow_outputs.phase_target_source,
    registered_target_q: narrow_outputs.registered_target_q,
    registered_target_valid_q: narrow_outputs.registered_target_valid_q,
    phase_target_domain_valid: narrow_outputs.phase_target_domain_valid,
    registered_target_domain_valid: narrow_outputs.registered_target_domain_valid,
    target_capture_accepted: narrow_outputs.target_capture_accepted,
    target_capture_rejected: narrow_outputs.target_capture_rejected,
    accepted_target_capture_events_q: 32'(narrow_outputs.accepted_target_capture_events_q),
    rejected_target_capture_events_q: 32'(narrow_outputs.rejected_target_capture_events_q),
    registered_request_enable: narrow_outputs.registered_request_enable,
    phase_request_valid: narrow_outputs.phase_request_valid,
    phase_request_cell_index: narrow_outputs.phase_request_cell_index,
    phase_request_target: narrow_outputs.phase_request_target,
    execution_request_valid: narrow_outputs.execution_request_valid,
    execution_request_cell_index: narrow_outputs.execution_request_cell_index,
    execution_request_target: narrow_outputs.execution_request_target,
    execution_target_bank: narrow_outputs.execution_target_bank,
    state_out: narrow_outputs.state_out,
    pending_route_out: narrow_outputs.pending_route_out,
    scheduler_mode_q: narrow_outputs.scheduler_mode_q,
    scheduler_state_q: narrow_outputs.scheduler_state_q,
    ticks_recorded_q: 32'(narrow_outputs.ticks_recorded_q),
    scheduler_count_free_q: 32'(narrow_outputs.scheduler_count_free_q),
    scheduler_count_balance_q: 32'(narrow_outputs.scheduler_count_balance_q),
    scheduler_count_commit_q: 32'(narrow_outputs.scheduler_count_commit_q),
    scheduler_count_excite_q: 32'(narrow_outputs.scheduler_count_excite_q),
    scheduler_count_neutralize_q: 32'(narrow_outputs.scheduler_count_neutralize_q),
    request_accept: narrow_outputs.request_accept,
    request_reject: narrow_outputs.request_reject,
    accepted_cell_mask: narrow_outputs.accepted_cell_mask,
    neutral_routed_cell_mask: narrow_outputs.neutral_routed_cell_mask,
    accepted_change_mask: narrow_outputs.accepted_change_mask,
    accepted_changes: 32'(narrow_outputs.accepted_changes),
    capacity_remaining: 32'(narrow_outputs.capacity_remaining),
    capacity_exhausted: narrow_outputs.capacity_exhausted,
    switch_load_numerator: 32'(narrow_outputs.switch_load_numerator),
    requested_direct_events: 32'(narrow_outputs.requested_direct_events),
    prevented_direct_events: 32'(narrow_outputs.prevented_direct_events),
    neutral_routed_events: 32'(narrow_outputs.neutral_routed_events),
    actual_direct_events: 32'(narrow_outputs.actual_direct_events),
    reserved_state_events: 32'(narrow_outputs.reserved_state_events),
    queue_overflow_events: 32'(narrow_outputs.queue_overflow_events),
    invariant_flags: narrow_outputs.invariant_flags,
    pair_coherence_q30: narrow_outputs.pair_coherence_q30,
    cluster_coherence_q30: narrow_outputs.cluster_coherence_q30,
    global_coherence_q30: narrow_outputs.global_coherence_q30,
    organization_dispersion_q30: narrow_outputs.organization_dispersion_q30,
    normalized_cycle_cost_q16: narrow_outputs.normalized_cycle_cost_q16,
    temperature_proxy_q16: narrow_outputs.temperature_proxy_q16,
    peak_temperature_proxy_q16: narrow_outputs.peak_temperature_proxy_q16,
    thermal_sample_count_q: narrow_outputs.thermal_sample_count_q,
    coherence_capacity_q16: narrow_outputs.coherence_capacity_q16,
    pressure_q16: narrow_outputs.pressure_q16,
    stability_margin_q16: narrow_outputs.stability_margin_q16,
    stable: narrow_outputs.stable
  };

  frp_m32_core #(
    .CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3),
    .COUNTER_BITS(COUNTER_BITS)
  ) dut (
    .clk(inputs.clk),
    .rst_n(inputs.rst_n),
    .tick_enable(inputs.tick_enable),
    .clear_counters(inputs.clear_counters),
    .scheduler_mode(frp_m31_pkg::frp_m31_scheduler_mode_e'(inputs.scheduler_mode)),
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
    .phase_word_q(narrow_outputs.phase_word_q),
    .frequency_current_q16(narrow_outputs.frequency_current_q16),
    .coupling_field_q16(narrow_outputs.coupling_field_q16),
    .phase_projection_q30(narrow_outputs.phase_projection_q30),
    .phase_target_source(narrow_outputs.phase_target_source),
    .registered_target_q(narrow_outputs.registered_target_q),
    .registered_target_valid_q(narrow_outputs.registered_target_valid_q),
    .phase_target_domain_valid(narrow_outputs.phase_target_domain_valid),
    .registered_target_domain_valid(narrow_outputs.registered_target_domain_valid),
    .target_capture_accepted(narrow_outputs.target_capture_accepted),
    .target_capture_rejected(narrow_outputs.target_capture_rejected),
    .accepted_target_capture_events_q(narrow_outputs.accepted_target_capture_events_q),
    .rejected_target_capture_events_q(narrow_outputs.rejected_target_capture_events_q),
    .registered_request_enable(narrow_outputs.registered_request_enable),
    .phase_request_valid(narrow_outputs.phase_request_valid),
    .phase_request_cell_index(narrow_outputs.phase_request_cell_index),
    .phase_request_target(narrow_outputs.phase_request_target),
    .execution_request_valid(narrow_outputs.execution_request_valid),
    .execution_request_cell_index(narrow_outputs.execution_request_cell_index),
    .execution_request_target(narrow_outputs.execution_request_target),
    .execution_target_bank(narrow_outputs.execution_target_bank),
    .state_out(narrow_outputs.state_out),
    .pending_route_out(narrow_outputs.pending_route_out),
    .scheduler_mode_q(narrow_outputs.scheduler_mode_q),
    .scheduler_state_q(narrow_outputs.scheduler_state_q),
    .ticks_recorded_q(narrow_outputs.ticks_recorded_q),
    .scheduler_count_free_q(narrow_outputs.scheduler_count_free_q),
    .scheduler_count_balance_q(narrow_outputs.scheduler_count_balance_q),
    .scheduler_count_commit_q(narrow_outputs.scheduler_count_commit_q),
    .scheduler_count_excite_q(narrow_outputs.scheduler_count_excite_q),
    .scheduler_count_neutralize_q(narrow_outputs.scheduler_count_neutralize_q),
    .request_accept(narrow_outputs.request_accept),
    .request_reject(narrow_outputs.request_reject),
    .accepted_cell_mask(narrow_outputs.accepted_cell_mask),
    .neutral_routed_cell_mask(narrow_outputs.neutral_routed_cell_mask),
    .accepted_change_mask(narrow_outputs.accepted_change_mask),
    .accepted_changes(narrow_outputs.accepted_changes),
    .capacity_remaining(narrow_outputs.capacity_remaining),
    .capacity_exhausted(narrow_outputs.capacity_exhausted),
    .switch_load_numerator(narrow_outputs.switch_load_numerator),
    .requested_direct_events(narrow_outputs.requested_direct_events),
    .prevented_direct_events(narrow_outputs.prevented_direct_events),
    .neutral_routed_events(narrow_outputs.neutral_routed_events),
    .actual_direct_events(narrow_outputs.actual_direct_events),
    .reserved_state_events(narrow_outputs.reserved_state_events),
    .queue_overflow_events(narrow_outputs.queue_overflow_events),
    .invariant_flags(narrow_outputs.invariant_flags),
    .pair_coherence_q30(narrow_outputs.pair_coherence_q30),
    .cluster_coherence_q30(narrow_outputs.cluster_coherence_q30),
    .global_coherence_q30(narrow_outputs.global_coherence_q30),
    .organization_dispersion_q30(narrow_outputs.organization_dispersion_q30),
    .normalized_cycle_cost_q16(narrow_outputs.normalized_cycle_cost_q16),
    .temperature_proxy_q16(narrow_outputs.temperature_proxy_q16),
    .peak_temperature_proxy_q16(narrow_outputs.peak_temperature_proxy_q16),
    .thermal_sample_count_q(narrow_outputs.thermal_sample_count_q),
    .coherence_capacity_q16(narrow_outputs.coherence_capacity_q16),
    .pressure_q16(narrow_outputs.pressure_q16),
    .stability_margin_q16(narrow_outputs.stability_margin_q16),
    .stable(narrow_outputs.stable)
  );

  function automatic logic [31:0] scheduler_count(input outputs_t bank, input int index);
    case (index)
      0: return bank.scheduler_count_free_q;
      1: return bank.scheduler_count_balance_q;
      2: return bank.scheduler_count_commit_q;
      3: return bank.scheduler_count_excite_q;
      4: return bank.scheduler_count_neutralize_q;
      default: return 'x;
    endcase
  endfunction

  task automatic compare_settled;
    bit rising_edge, reset_assertion, capture_saturated;
    logic [1:0] before_state, after_state, destination;
    rising_edge = !previous_inputs.clk && inputs.clk;
    reset_assertion = previous_inputs.rst_n && !inputs.rst_n;
    if (reset_assertion) armed = 1;
    if (armed) begin
      expected = reference_outputs;
      expected.accepted_target_capture_events_q =
        reference_outputs.accepted_target_capture_events_q > LIMIT ? LIMIT :
        reference_outputs.accepted_target_capture_events_q;
      expected.rejected_target_capture_events_q =
        reference_outputs.rejected_target_capture_events_q > LIMIT ? LIMIT :
        reference_outputs.rejected_target_capture_events_q;
      expected.ticks_recorded_q = reference_outputs.ticks_recorded_q & LIMIT;
      expected.scheduler_count_free_q = reference_outputs.scheduler_count_free_q & LIMIT;
      expected.scheduler_count_balance_q = reference_outputs.scheduler_count_balance_q & LIMIT;
      expected.scheduler_count_commit_q = reference_outputs.scheduler_count_commit_q & LIMIT;
      expected.scheduler_count_excite_q = reference_outputs.scheduler_count_excite_q & LIMIT;
      expected.scheduler_count_neutralize_q = reference_outputs.scheduler_count_neutralize_q & LIMIT;

      if ($isunknown({actual, expected}) || actual !== expected) begin
        mismatch_seen = 1;
        if (actual.phase_word_q !== expected.phase_word_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_word_q actual=%h expected=%h",
            COUNTER_BITS, actual.phase_word_q, expected.phase_word_q);
        if (actual.frequency_current_q16 !== expected.frequency_current_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d frequency_current_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.frequency_current_q16, expected.frequency_current_q16);
        if (actual.coupling_field_q16 !== expected.coupling_field_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d coupling_field_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.coupling_field_q16, expected.coupling_field_q16);
        if (actual.phase_projection_q30 !== expected.phase_projection_q30)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_projection_q30 actual=%h expected=%h",
            COUNTER_BITS, actual.phase_projection_q30, expected.phase_projection_q30);
        if (actual.phase_target_source !== expected.phase_target_source)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_target_source actual=%h expected=%h",
            COUNTER_BITS, actual.phase_target_source, expected.phase_target_source);
        if (actual.registered_target_q !== expected.registered_target_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d registered_target_q actual=%h expected=%h",
            COUNTER_BITS, actual.registered_target_q, expected.registered_target_q);
        if (actual.registered_target_valid_q !== expected.registered_target_valid_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d registered_target_valid_q actual=%h expected=%h",
            COUNTER_BITS, actual.registered_target_valid_q, expected.registered_target_valid_q);
        if (actual.phase_target_domain_valid !== expected.phase_target_domain_valid)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_target_domain_valid actual=%h expected=%h",
            COUNTER_BITS, actual.phase_target_domain_valid, expected.phase_target_domain_valid);
        if (actual.registered_target_domain_valid !== expected.registered_target_domain_valid)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d registered_target_domain_valid actual=%h expected=%h",
            COUNTER_BITS, actual.registered_target_domain_valid, expected.registered_target_domain_valid);
        if (actual.target_capture_accepted !== expected.target_capture_accepted)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d target_capture_accepted actual=%h expected=%h",
            COUNTER_BITS, actual.target_capture_accepted, expected.target_capture_accepted);
        if (actual.target_capture_rejected !== expected.target_capture_rejected)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d target_capture_rejected actual=%h expected=%h",
            COUNTER_BITS, actual.target_capture_rejected, expected.target_capture_rejected);
        if (actual.accepted_target_capture_events_q !== expected.accepted_target_capture_events_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d accepted_target_capture_events_q actual=%h expected=%h",
            COUNTER_BITS, actual.accepted_target_capture_events_q, expected.accepted_target_capture_events_q);
        if (actual.rejected_target_capture_events_q !== expected.rejected_target_capture_events_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d rejected_target_capture_events_q actual=%h expected=%h",
            COUNTER_BITS, actual.rejected_target_capture_events_q, expected.rejected_target_capture_events_q);
        if (actual.registered_request_enable !== expected.registered_request_enable)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d registered_request_enable actual=%h expected=%h",
            COUNTER_BITS, actual.registered_request_enable, expected.registered_request_enable);
        if (actual.phase_request_valid !== expected.phase_request_valid)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_request_valid actual=%h expected=%h",
            COUNTER_BITS, actual.phase_request_valid, expected.phase_request_valid);
        if (actual.phase_request_cell_index !== expected.phase_request_cell_index)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_request_cell_index actual=%h expected=%h",
            COUNTER_BITS, actual.phase_request_cell_index, expected.phase_request_cell_index);
        if (actual.phase_request_target !== expected.phase_request_target)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d phase_request_target actual=%h expected=%h",
            COUNTER_BITS, actual.phase_request_target, expected.phase_request_target);
        if (actual.execution_request_valid !== expected.execution_request_valid)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d execution_request_valid actual=%h expected=%h",
            COUNTER_BITS, actual.execution_request_valid, expected.execution_request_valid);
        if (actual.execution_request_cell_index !== expected.execution_request_cell_index)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d execution_request_cell_index actual=%h expected=%h",
            COUNTER_BITS, actual.execution_request_cell_index, expected.execution_request_cell_index);
        if (actual.execution_request_target !== expected.execution_request_target)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d execution_request_target actual=%h expected=%h",
            COUNTER_BITS, actual.execution_request_target, expected.execution_request_target);
        if (actual.execution_target_bank !== expected.execution_target_bank)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d execution_target_bank actual=%h expected=%h",
            COUNTER_BITS, actual.execution_target_bank, expected.execution_target_bank);
        if (actual.state_out !== expected.state_out)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d state_out actual=%h expected=%h",
            COUNTER_BITS, actual.state_out, expected.state_out);
        if (actual.pending_route_out !== expected.pending_route_out)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d pending_route_out actual=%h expected=%h",
            COUNTER_BITS, actual.pending_route_out, expected.pending_route_out);
        if (actual.scheduler_mode_q !== expected.scheduler_mode_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_mode_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_mode_q, expected.scheduler_mode_q);
        if (actual.scheduler_state_q !== expected.scheduler_state_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_state_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_state_q, expected.scheduler_state_q);
        if (actual.ticks_recorded_q !== expected.ticks_recorded_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d ticks_recorded_q actual=%h expected=%h",
            COUNTER_BITS, actual.ticks_recorded_q, expected.ticks_recorded_q);
        if (actual.scheduler_count_free_q !== expected.scheduler_count_free_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_count_free_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_count_free_q, expected.scheduler_count_free_q);
        if (actual.scheduler_count_balance_q !== expected.scheduler_count_balance_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_count_balance_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_count_balance_q, expected.scheduler_count_balance_q);
        if (actual.scheduler_count_commit_q !== expected.scheduler_count_commit_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_count_commit_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_count_commit_q, expected.scheduler_count_commit_q);
        if (actual.scheduler_count_excite_q !== expected.scheduler_count_excite_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_count_excite_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_count_excite_q, expected.scheduler_count_excite_q);
        if (actual.scheduler_count_neutralize_q !== expected.scheduler_count_neutralize_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d scheduler_count_neutralize_q actual=%h expected=%h",
            COUNTER_BITS, actual.scheduler_count_neutralize_q, expected.scheduler_count_neutralize_q);
        if (actual.request_accept !== expected.request_accept)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d request_accept actual=%h expected=%h",
            COUNTER_BITS, actual.request_accept, expected.request_accept);
        if (actual.request_reject !== expected.request_reject)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d request_reject actual=%h expected=%h",
            COUNTER_BITS, actual.request_reject, expected.request_reject);
        if (actual.accepted_cell_mask !== expected.accepted_cell_mask)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d accepted_cell_mask actual=%h expected=%h",
            COUNTER_BITS, actual.accepted_cell_mask, expected.accepted_cell_mask);
        if (actual.neutral_routed_cell_mask !== expected.neutral_routed_cell_mask)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d neutral_routed_cell_mask actual=%h expected=%h",
            COUNTER_BITS, actual.neutral_routed_cell_mask, expected.neutral_routed_cell_mask);
        if (actual.accepted_change_mask !== expected.accepted_change_mask)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d accepted_change_mask actual=%h expected=%h",
            COUNTER_BITS, actual.accepted_change_mask, expected.accepted_change_mask);
        if (actual.accepted_changes !== expected.accepted_changes)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d accepted_changes actual=%h expected=%h",
            COUNTER_BITS, actual.accepted_changes, expected.accepted_changes);
        if (actual.capacity_remaining !== expected.capacity_remaining)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d capacity_remaining actual=%h expected=%h",
            COUNTER_BITS, actual.capacity_remaining, expected.capacity_remaining);
        if (actual.capacity_exhausted !== expected.capacity_exhausted)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d capacity_exhausted actual=%h expected=%h",
            COUNTER_BITS, actual.capacity_exhausted, expected.capacity_exhausted);
        if (actual.switch_load_numerator !== expected.switch_load_numerator)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d switch_load_numerator actual=%h expected=%h",
            COUNTER_BITS, actual.switch_load_numerator, expected.switch_load_numerator);
        if (actual.requested_direct_events !== expected.requested_direct_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d requested_direct_events actual=%h expected=%h",
            COUNTER_BITS, actual.requested_direct_events, expected.requested_direct_events);
        if (actual.prevented_direct_events !== expected.prevented_direct_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d prevented_direct_events actual=%h expected=%h",
            COUNTER_BITS, actual.prevented_direct_events, expected.prevented_direct_events);
        if (actual.neutral_routed_events !== expected.neutral_routed_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d neutral_routed_events actual=%h expected=%h",
            COUNTER_BITS, actual.neutral_routed_events, expected.neutral_routed_events);
        if (actual.actual_direct_events !== expected.actual_direct_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d actual_direct_events actual=%h expected=%h",
            COUNTER_BITS, actual.actual_direct_events, expected.actual_direct_events);
        if (actual.reserved_state_events !== expected.reserved_state_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d reserved_state_events actual=%h expected=%h",
            COUNTER_BITS, actual.reserved_state_events, expected.reserved_state_events);
        if (actual.queue_overflow_events !== expected.queue_overflow_events)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d queue_overflow_events actual=%h expected=%h",
            COUNTER_BITS, actual.queue_overflow_events, expected.queue_overflow_events);
        if (actual.invariant_flags !== expected.invariant_flags)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d invariant_flags actual=%h expected=%h",
            COUNTER_BITS, actual.invariant_flags, expected.invariant_flags);
        if (actual.pair_coherence_q30 !== expected.pair_coherence_q30)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d pair_coherence_q30 actual=%h expected=%h",
            COUNTER_BITS, actual.pair_coherence_q30, expected.pair_coherence_q30);
        if (actual.cluster_coherence_q30 !== expected.cluster_coherence_q30)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d cluster_coherence_q30 actual=%h expected=%h",
            COUNTER_BITS, actual.cluster_coherence_q30, expected.cluster_coherence_q30);
        if (actual.global_coherence_q30 !== expected.global_coherence_q30)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d global_coherence_q30 actual=%h expected=%h",
            COUNTER_BITS, actual.global_coherence_q30, expected.global_coherence_q30);
        if (actual.organization_dispersion_q30 !== expected.organization_dispersion_q30)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d organization_dispersion_q30 actual=%h expected=%h",
            COUNTER_BITS, actual.organization_dispersion_q30, expected.organization_dispersion_q30);
        if (actual.normalized_cycle_cost_q16 !== expected.normalized_cycle_cost_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d normalized_cycle_cost_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.normalized_cycle_cost_q16, expected.normalized_cycle_cost_q16);
        if (actual.temperature_proxy_q16 !== expected.temperature_proxy_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d temperature_proxy_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.temperature_proxy_q16, expected.temperature_proxy_q16);
        if (actual.peak_temperature_proxy_q16 !== expected.peak_temperature_proxy_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d peak_temperature_proxy_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.peak_temperature_proxy_q16, expected.peak_temperature_proxy_q16);
        if (actual.thermal_sample_count_q !== expected.thermal_sample_count_q)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d thermal_sample_count_q actual=%h expected=%h",
            COUNTER_BITS, actual.thermal_sample_count_q, expected.thermal_sample_count_q);
        if (actual.coherence_capacity_q16 !== expected.coherence_capacity_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d coherence_capacity_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.coherence_capacity_q16, expected.coherence_capacity_q16);
        if (actual.pressure_q16 !== expected.pressure_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d pressure_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.pressure_q16, expected.pressure_q16);
        if (actual.stability_margin_q16 !== expected.stability_margin_q16)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d stability_margin_q16 actual=%h expected=%h",
            COUNTER_BITS, actual.stability_margin_q16, expected.stability_margin_q16);
        if (actual.stable !== expected.stable)
          $display("COUNTER_BOUNDARY_FIELD bits=%0d stable actual=%h expected=%h",
            COUNTER_BITS, actual.stable, expected.stable);

        $fatal(1, "M32 counter-boundary mismatch bits=%0d time=%0t comparisons=%0d",
          COUNTER_BITS, $time, comparisons);
      end
      comparisons++;
      if (reset_assertion) begin
        resets++;
        wrapped_in_epoch = 0;
      end
      if (rising_edge && inputs.rst_n) begin
        capture_saturated = previous_outputs.accepted_target_capture_events_q == LIMIT;
        if (inputs.clear_counters) begin
          if (inputs.tick_enable) clear_ticks++; else clear_holds++;
          if (capture_saturated) begin
            if (inputs.tick_enable) saturation_clear_ticks++;
            else saturation_clear_holds++;
          end
          // Capture/thermal clear wins; scheduler clear counts this same tick.
          if (actual.accepted_target_capture_events_q != 0 ||
              actual.rejected_target_capture_events_q != 0 ||
              actual.thermal_sample_count_q != 0 ||
              actual.ticks_recorded_q != 32'(inputs.tick_enable)) begin
            mismatch_seen = 1;
            $fatal(1, "M32 counter-boundary clear priority mismatch bits=%0d", COUNTER_BITS);
          end
        end
        if (inputs.tick_enable) begin
          enabled_ticks++;
          if (!inputs.clear_counters) begin
            if (previous_outputs.ticks_recorded_q == LIMIT) begin
              tick_wraps++;
              wrap_modes[previous_outputs.scheduler_mode_q] = 1;
              wrapped_in_epoch = 1;
            end
            for (int k = 0; k < 5; k++)
              if (previous_outputs.scheduler_state_q == k &&
                  scheduler_count(previous_outputs, k) == LIMIT) begin
                scheduler_wraps[k]++;
                scheduler_wrap_mask[k] = 1;
              end
            if (previous_outputs.accepted_target_capture_events_q == LIMIT-1 &&
                actual.accepted_target_capture_events_q == LIMIT)
              capture_limit_entries++;
            if (capture_saturated) begin
              saturated_capture_ticks++;
              saturation_modes[previous_outputs.scheduler_mode_q] = 1;
              if (!inputs.phase_load_valid && actual.phase_word_q != previous_outputs.phase_word_q)
                phase_updates_at_saturation++;
            end
          end
          if (wrapped_in_epoch) begin
            ticks_after_wrap++;
            if (!inputs.phase_load_valid) begin
              if (actual.phase_word_q != previous_outputs.phase_word_q) phase_updates_after_wrap++;
              if (actual.frequency_current_q16 != previous_outputs.frequency_current_q16)
                frequency_updates_after_wrap++;
            end
          end
          for (int i = 0; i < 8; i++) begin
            before_state = previous_outputs.state_out[2*i +: 2];
            after_state = actual.state_out[2*i +: 2];
            destination = previous_outputs.pending_route_out[2*i +: 2];
            if ((before_state == 1 && after_state == 2) ||
                (before_state == 2 && after_state == 1)) begin
              mismatch_seen = 1;
              $fatal(1, "M32 counter-boundary direct polarity write bits=%0d cell=%0d", COUNTER_BITS, i);
            end
            if (capture_saturated && !inputs.clear_counters) begin
              if (before_state != 0 && after_state == 0 &&
                  actual.pending_route_out[2*i +: 2] != 0) first_legs_at_saturation++;
              if (before_state == 0 && destination != 0 && after_state == destination &&
                  actual.pending_route_out[2*i +: 2] == 0) second_legs_at_saturation++;
            end
          end
        end else held_edges++;
      end
    end
    previous_inputs = inputs;
    previous_outputs = actual;
  endtask

  initial begin
    if (!(COUNTER_BITS inside {4, 5}) || $bits(inputs_t) != 1060 ||
        $bits(outputs_t) != 2075 || $bits(narrow_outputs_t) != 2075-17*(32-COUNTER_BITS))
      $fatal(1, "M32 counter-boundary interface mismatch");
    foreach (scheduler_wraps[k]) scheduler_wraps[k] = 0;
    previous_inputs = '0;
    previous_inputs.rst_n = 1;
    previous_outputs = '0;
    #1fs;
    compare_settled();
    forever begin
      @(inputs);
      #1fs;
      compare_settled();
    end
  end

  task automatic report;
    // FREE/BALANCE/NEUTRALIZE must wrap. The unchanged workload clears
    // before the slower COMMIT/EXCITE counters can wrap at these widths.
    // Rejected capture stays zero because the core generates valid targets.
    if (mismatch_seen || !armed || comparisons == 0 || enabled_ticks != 3104 ||
        held_edges != 158 || resets != 22 || clear_ticks != 54 || clear_holds != 86 ||
        tick_wraps == 0 || scheduler_wrap_mask != 5'b10011 ||
        wrap_modes != 3'b111 || saturation_modes != 3'b111 ||
        capture_limit_entries == 0 || saturated_capture_ticks == 0 ||
        saturation_clear_ticks == 0 || saturation_clear_holds == 0 ||
        ticks_after_wrap == 0 || phase_updates_after_wrap == 0 ||
        frequency_updates_after_wrap == 0 || phase_updates_at_saturation == 0 ||
        first_legs_at_saturation == 0 || second_legs_at_saturation == 0)
      $fatal(1, "M32 counter-boundary incomplete coverage bits=%0d comparisons=%0d wraps=%0d wrap_mask=%0d wrap_modes=%0d saturation_modes=%0d clear_tick=%0d clear_hold=%0d first=%0d second=%0d",
        COUNTER_BITS, comparisons, tick_wraps, scheduler_wrap_mask, wrap_modes,
        saturation_modes, saturation_clear_ticks, saturation_clear_holds,
        first_legs_at_saturation, second_legs_at_saturation);
    $display("FRP_M32_COUNTER_BOUNDARY_PROFILE: PASS counter_bits=%0d comparisons=%0d input_bits=1060 output_ports=59 output_bits=%0d enabled_ticks=%0d held_edges=%0d resets=%0d clear_ticks=%0d clear_holds=%0d tick_wraps=%0d free_wraps=%0d balance_wraps=%0d commit_wraps=%0d excite_wraps=%0d neutralize_wraps=%0d wrap_modes=%0d capture_limit_entries=%0d saturated_capture_ticks=%0d saturation_modes=%0d saturation_clear_ticks=%0d saturation_clear_holds=%0d ticks_after_wrap=%0d phase_updates_after_wrap=%0d frequency_updates_after_wrap=%0d phase_updates_at_saturation=%0d first_legs_at_saturation=%0d second_legs_at_saturation=%0d",
      COUNTER_BITS, comparisons, $bits(narrow_outputs_t), enabled_ticks, held_edges,
      resets, clear_ticks, clear_holds, tick_wraps, scheduler_wraps[0], scheduler_wraps[1],
      scheduler_wraps[2], scheduler_wraps[3], scheduler_wraps[4], wrap_modes,
      capture_limit_entries, saturated_capture_ticks, saturation_modes,
      saturation_clear_ticks, saturation_clear_holds, ticks_after_wrap,
      phase_updates_after_wrap, frequency_updates_after_wrap, phase_updates_at_saturation,
      first_legs_at_saturation, second_legs_at_saturation);
  endtask
endmodule

module frp_m32_counter_boundary_tb;
  timeunit 1ns;
  timeprecision 1fs;
  import frp_m32_counter_boundary_tb_pkg::*;
  frp_m32_closed_loop_tb reference_test();
  wire inputs_t inputs;
  wire outputs_t reference_outputs;

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

  frp_m32_counter_boundary_case #(.COUNTER_BITS(4)) width4(inputs, reference_outputs);
  frp_m32_counter_boundary_case #(.COUNTER_BITS(5)) width5(inputs, reference_outputs);

  final begin
    if (reference_test.profiles != 6 || reference_test.steps != 3262 ||
        reference_test.checks != 10030 || reference_test.live_control_checks != 156 ||
        width4.comparisons != width5.comparisons)
      $fatal(1, "M32 counter-boundary reference workload incomplete");
    width4.report();
    width5.report();
    $display("FRP_M32_COUNTER_BOUNDARY_TB: PASS profiles=2 reference_counter_bits=32 reference_profiles=6 reference_steps=3262 reference_checks=10030 reference_live_control_checks=156");
  end
endmodule
`endif

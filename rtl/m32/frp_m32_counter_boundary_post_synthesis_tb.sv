 // SPDX-License-Identifier: Apache-2.0
// Complete M32 counter-boundary netlists versus the unchanged RTL workload.
// Synthesize frp_m32_core twice: CELLS=8, REQUEST_LANES=2, CELL_INDEX_BITS=3,
// COUNTER_BITS=4/5; rename to frp_m32_core_counter_boundary_4_netlist and
// frp_m32_core_counter_boundary_5_netlist. Keep every public port.
// As in workflow 01, the synthesis view removes only the four initial
// sine-LUT assertions; the RTL reference and the ROM remain unchanged.
// Both netlists receive the original input events. Compare all 59 outputs
// with their matching RTL profiles after zero-delay cells settle (1 fs).
// The included test retains its independently checked 32-bit oracle and
// counter-boundary checks. No internal DUT state is read or forced.
// This qualifies RTL/netlists at these widths; model v0.9.3 is a later step.
`ifndef FRP_M32_COUNTER_BOUNDARY_POST_SYNTHESIS_TB_SV
`define FRP_M32_COUNTER_BOUNDARY_POST_SYNTHESIS_TB_SV
`include "frp_m32_counter_boundary_tb.sv"

module frp_m32_counter_boundary_post_case #(
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
  outputs_t previous_outputs;
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

  // Zero-extend all seventeen narrow public counters for an exact comparison
  // with the matching RTL profile; no result bits are masked or discarded.
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

  generate
    if (COUNTER_BITS == 4) begin : width4
      frp_m32_core_counter_boundary_4_netlist dut (
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
    end else if (COUNTER_BITS == 5) begin : width5
      frp_m32_core_counter_boundary_5_netlist dut (
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
    end
  endgenerate

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

  task automatic mismatch_field(input string name,
    input logic [255:0] actual_value, input logic [255:0] reference_value);
    if (actual_value !== reference_value || $isunknown({actual_value, reference_value}))
      $display("COUNTER_BOUNDARY_POST_FIELD bits=%0d field=%s actual=%h expected=%h",
        COUNTER_BITS, name, actual_value, reference_value);
  endtask

  task automatic compare_settled;
    bit rising_edge, reset_assertion, capture_saturated;
    logic [1:0] before_state, after_state, destination;
    rising_edge = !previous_inputs.clk && inputs.clk;
    reset_assertion = previous_inputs.rst_n && !inputs.rst_n;
    if (reset_assertion) armed = 1;
    if (armed) begin
      if ($isunknown({actual, reference_outputs}) || actual !== reference_outputs) begin
        mismatch_seen = 1;
        mismatch_field("phase_word_q", actual.phase_word_q, reference_outputs.phase_word_q);
        mismatch_field("frequency_current_q16", actual.frequency_current_q16, reference_outputs.frequency_current_q16);
        mismatch_field("coupling_field_q16", actual.coupling_field_q16, reference_outputs.coupling_field_q16);
        mismatch_field("phase_projection_q30", actual.phase_projection_q30, reference_outputs.phase_projection_q30);
        mismatch_field("phase_target_source", actual.phase_target_source, reference_outputs.phase_target_source);
        mismatch_field("registered_target_q", actual.registered_target_q, reference_outputs.registered_target_q);
        mismatch_field("registered_target_valid_q", actual.registered_target_valid_q, reference_outputs.registered_target_valid_q);
        mismatch_field("phase_target_domain_valid", actual.phase_target_domain_valid, reference_outputs.phase_target_domain_valid);
        mismatch_field("registered_target_domain_valid", actual.registered_target_domain_valid, reference_outputs.registered_target_domain_valid);
        mismatch_field("target_capture_accepted", actual.target_capture_accepted, reference_outputs.target_capture_accepted);
        mismatch_field("target_capture_rejected", actual.target_capture_rejected, reference_outputs.target_capture_rejected);
        mismatch_field("accepted_target_capture_events_q", actual.accepted_target_capture_events_q, reference_outputs.accepted_target_capture_events_q);
        mismatch_field("rejected_target_capture_events_q", actual.rejected_target_capture_events_q, reference_outputs.rejected_target_capture_events_q);
        mismatch_field("registered_request_enable", actual.registered_request_enable, reference_outputs.registered_request_enable);
        mismatch_field("phase_request_valid", actual.phase_request_valid, reference_outputs.phase_request_valid);
        mismatch_field("phase_request_cell_index", actual.phase_request_cell_index, reference_outputs.phase_request_cell_index);
        mismatch_field("phase_request_target", actual.phase_request_target, reference_outputs.phase_request_target);
        mismatch_field("execution_request_valid", actual.execution_request_valid, reference_outputs.execution_request_valid);
        mismatch_field("execution_request_cell_index", actual.execution_request_cell_index, reference_outputs.execution_request_cell_index);
        mismatch_field("execution_request_target", actual.execution_request_target, reference_outputs.execution_request_target);
        mismatch_field("execution_target_bank", actual.execution_target_bank, reference_outputs.execution_target_bank);
        mismatch_field("state_out", actual.state_out, reference_outputs.state_out);
        mismatch_field("pending_route_out", actual.pending_route_out, reference_outputs.pending_route_out);
        mismatch_field("scheduler_mode_q", actual.scheduler_mode_q, reference_outputs.scheduler_mode_q);
        mismatch_field("scheduler_state_q", actual.scheduler_state_q, reference_outputs.scheduler_state_q);
        mismatch_field("ticks_recorded_q", actual.ticks_recorded_q, reference_outputs.ticks_recorded_q);
        mismatch_field("scheduler_count_free_q", actual.scheduler_count_free_q, reference_outputs.scheduler_count_free_q);
        mismatch_field("scheduler_count_balance_q", actual.scheduler_count_balance_q, reference_outputs.scheduler_count_balance_q);
        mismatch_field("scheduler_count_commit_q", actual.scheduler_count_commit_q, reference_outputs.scheduler_count_commit_q);
        mismatch_field("scheduler_count_excite_q", actual.scheduler_count_excite_q, reference_outputs.scheduler_count_excite_q);
        mismatch_field("scheduler_count_neutralize_q", actual.scheduler_count_neutralize_q, reference_outputs.scheduler_count_neutralize_q);
        mismatch_field("request_accept", actual.request_accept, reference_outputs.request_accept);
        mismatch_field("request_reject", actual.request_reject, reference_outputs.request_reject);
        mismatch_field("accepted_cell_mask", actual.accepted_cell_mask, reference_outputs.accepted_cell_mask);
        mismatch_field("neutral_routed_cell_mask", actual.neutral_routed_cell_mask, reference_outputs.neutral_routed_cell_mask);
        mismatch_field("accepted_change_mask", actual.accepted_change_mask, reference_outputs.accepted_change_mask);
        mismatch_field("accepted_changes", actual.accepted_changes, reference_outputs.accepted_changes);
        mismatch_field("capacity_remaining", actual.capacity_remaining, reference_outputs.capacity_remaining);
        mismatch_field("capacity_exhausted", actual.capacity_exhausted, reference_outputs.capacity_exhausted);
        mismatch_field("switch_load_numerator", actual.switch_load_numerator, reference_outputs.switch_load_numerator);
        mismatch_field("requested_direct_events", actual.requested_direct_events, reference_outputs.requested_direct_events);
        mismatch_field("prevented_direct_events", actual.prevented_direct_events, reference_outputs.prevented_direct_events);
        mismatch_field("neutral_routed_events", actual.neutral_routed_events, reference_outputs.neutral_routed_events);
        mismatch_field("actual_direct_events", actual.actual_direct_events, reference_outputs.actual_direct_events);
        mismatch_field("reserved_state_events", actual.reserved_state_events, reference_outputs.reserved_state_events);
        mismatch_field("queue_overflow_events", actual.queue_overflow_events, reference_outputs.queue_overflow_events);
        mismatch_field("invariant_flags", actual.invariant_flags, reference_outputs.invariant_flags);
        mismatch_field("pair_coherence_q30", actual.pair_coherence_q30, reference_outputs.pair_coherence_q30);
        mismatch_field("cluster_coherence_q30", actual.cluster_coherence_q30, reference_outputs.cluster_coherence_q30);
        mismatch_field("global_coherence_q30", actual.global_coherence_q30, reference_outputs.global_coherence_q30);
        mismatch_field("organization_dispersion_q30", actual.organization_dispersion_q30, reference_outputs.organization_dispersion_q30);
        mismatch_field("normalized_cycle_cost_q16", actual.normalized_cycle_cost_q16, reference_outputs.normalized_cycle_cost_q16);
        mismatch_field("temperature_proxy_q16", actual.temperature_proxy_q16, reference_outputs.temperature_proxy_q16);
        mismatch_field("peak_temperature_proxy_q16", actual.peak_temperature_proxy_q16, reference_outputs.peak_temperature_proxy_q16);
        mismatch_field("thermal_sample_count_q", actual.thermal_sample_count_q, reference_outputs.thermal_sample_count_q);
        mismatch_field("coherence_capacity_q16", actual.coherence_capacity_q16, reference_outputs.coherence_capacity_q16);
        mismatch_field("pressure_q16", actual.pressure_q16, reference_outputs.pressure_q16);
        mismatch_field("stability_margin_q16", actual.stability_margin_q16, reference_outputs.stability_margin_q16);
        mismatch_field("stable", actual.stable, reference_outputs.stable);

        $fatal(1, "M32 counter-boundary post-synthesis mismatch bits=%0d time=%0t comparisons=%0d",
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
            $fatal(1, "M32 counter-boundary post-synthesis clear priority mismatch bits=%0d", COUNTER_BITS);
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
              $fatal(1, "M32 counter-boundary post-synthesis direct polarity write bits=%0d cell=%0d", COUNTER_BITS, i);
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
      $fatal(1, "M32 counter-boundary post-synthesis interface mismatch");
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
    if (mismatch_seen || !armed || comparisons != 9969 || enabled_ticks != 3104 ||
        held_edges != 158 || resets != 22 || clear_ticks != 54 || clear_holds != 86 ||
        tick_wraps == 0 || scheduler_wrap_mask != 5'b10011 ||
        wrap_modes != 3'b111 || saturation_modes != 3'b111 ||
        capture_limit_entries == 0 || saturated_capture_ticks == 0 ||
        saturation_clear_ticks == 0 || saturation_clear_holds == 0 ||
        ticks_after_wrap == 0 || phase_updates_after_wrap == 0 ||
        frequency_updates_after_wrap == 0 || phase_updates_at_saturation == 0 ||
        first_legs_at_saturation == 0 || second_legs_at_saturation == 0)
      $fatal(1, "M32 counter-boundary post-synthesis incomplete coverage bits=%0d comparisons=%0d wraps=%0d wrap_mask=%0d wrap_modes=%0d saturation_modes=%0d clear_tick=%0d clear_hold=%0d first=%0d second=%0d",
        COUNTER_BITS, comparisons, tick_wraps, scheduler_wrap_mask, wrap_modes,
        saturation_modes, saturation_clear_ticks, saturation_clear_holds,
        first_legs_at_saturation, second_legs_at_saturation);
    $display("FRP_M32_COUNTER_BOUNDARY_POST_SYNTHESIS_PROFILE: PASS counter_bits=%0d comparisons=%0d input_bits=1060 output_ports=59 output_bits=%0d enabled_ticks=%0d held_edges=%0d resets=%0d clear_ticks=%0d clear_holds=%0d tick_wraps=%0d free_wraps=%0d balance_wraps=%0d commit_wraps=%0d excite_wraps=%0d neutralize_wraps=%0d wrap_modes=%0d capture_limit_entries=%0d saturated_capture_ticks=%0d saturation_modes=%0d saturation_clear_ticks=%0d saturation_clear_holds=%0d ticks_after_wrap=%0d phase_updates_after_wrap=%0d frequency_updates_after_wrap=%0d phase_updates_at_saturation=%0d first_legs_at_saturation=%0d second_legs_at_saturation=%0d",
      COUNTER_BITS, comparisons, $bits(narrow_outputs_t), enabled_ticks, held_edges,
      resets, clear_ticks, clear_holds, tick_wraps, scheduler_wraps[0], scheduler_wraps[1],
      scheduler_wraps[2], scheduler_wraps[3], scheduler_wraps[4], wrap_modes,
      capture_limit_entries, saturated_capture_ticks, saturation_modes,
      saturation_clear_ticks, saturation_clear_holds, ticks_after_wrap,
      phase_updates_after_wrap, frequency_updates_after_wrap, phase_updates_at_saturation,
      first_legs_at_saturation, second_legs_at_saturation);
  endtask
endmodule

module frp_m32_counter_boundary_post_synthesis_tb;
  timeunit 1ns;
  timeprecision 1fs;
  frp_m32_counter_boundary_tb reference_test();

  // These testbench bundles contain only the connected public DUT ports.
  frp_m32_counter_boundary_post_case #(.COUNTER_BITS(4)) width4 (
    .inputs(reference_test.inputs),
    .reference_outputs(reference_test.width4.actual)
  );
  frp_m32_counter_boundary_post_case #(.COUNTER_BITS(5)) width5 (
    .inputs(reference_test.inputs),
    .reference_outputs(reference_test.width5.actual)
  );

  final begin
    if (reference_test.reference_test.profiles != 6 ||
        reference_test.reference_test.steps != 3262 ||
        reference_test.reference_test.checks != 10030 ||
        reference_test.reference_test.live_control_checks != 156 ||
        reference_test.width4.mismatch_seen || reference_test.width5.mismatch_seen ||
        width4.comparisons != reference_test.width4.comparisons ||
        width5.comparisons != reference_test.width5.comparisons)
      $fatal(1, "M32 counter-boundary post-synthesis reference workload incomplete");
    width4.report();
    width5.report();
    $display("FRP_M32_COUNTER_BOUNDARY_POST_SYNTHESIS_TB: PASS profiles=2 reference_counter_bits=32 reference_profiles=6 reference_steps=3262 reference_checks=10030 reference_live_control_checks=156");
  end
endmodule
`endif

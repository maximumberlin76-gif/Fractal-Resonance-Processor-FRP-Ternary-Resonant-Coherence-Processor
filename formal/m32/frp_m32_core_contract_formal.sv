// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent eight-cell, two-lane, 32-bit-counter M32 functional contract.
// All 59 public outputs / 2075 bits are compared with independently retained
// reference state. No DUT outputs, internal state or arithmetic helpers feed
// the reference. The input controls are shared; the feedback paths are not.
// Phase equations preserve the M31 contract: Q30 ROM projection, local gamma,
// hierarchical thermal products, wide frequency correction and phase wrap.
// Execution preserves pending-first capacity, active-zero routes and cadence.
// Target capture uses the PRE-EDGE phase target, including simultaneous load.
// Scheduler clear+tick records one tick; capture and thermal clear win over tick.
// Reserved scheduler modes block execution but do not stop phase evolution.
//
// Define FRP_M32_CORE_CONTRACT_NETLIST to select a fresh full-core netlist.
// This file defines proof obligations; its presence is not a proof result.
// Qualification requires reset base, induction, independently checked ROM,
// original-source RTL/netlist replay, reach witnesses and negative controls.
// Only initial sampled reset is assumed. Later input bit patterns are free.
// Reach bits are witnesses, never assumptions or exhaustive coverage claims.
// Scope excludes other parameters, four-state behavior, physical timing,
// endogenous generation of gamma/thermal inputs and v0.9.3 model equivalence.

`ifndef FRP_M32_CORE_CONTRACT_FORMAL_SV
`define FRP_M32_CORE_CONTRACT_FORMAL_SV
`timescale 1ns/1ps
`include "frp_m32_core.sv"

package frp_m32_core_contract_pkg;
  typedef logic signed [63:0] wide_t;

  function automatic wide_t round_pow2(input wide_t value, input int shift);
    wide_t quotient;
    logic [63:0] remainder_value, half_value;
    begin
      if (shift == 0) return value;
      quotient = value >>> shift;
      remainder_value = $unsigned(value) & ((64'd1 << shift) - 1);
      half_value = 64'd1 << (shift - 1);
      if (remainder_value > half_value
          || (remainder_value == half_value && value >= 0))
        quotient = quotient + 64'sd1;
      return quotient;
    end
  endfunction

  function automatic logic signed [31:0] clip_s32(input wide_t value);
    if (value[63:31] == {33{value[31]}}) return value[31:0];
    return value[63] ? 32'sh80000000 : 32'sh7fffffff;
  endfunction

  function automatic logic signed [31:0] multiply_fixed(
    input logic signed [31:0] left, right, input int fractional_bits
  );
    return clip_s32(round_pow2(wide_t'(left) * wide_t'(right), fractional_bits));
  endfunction

  function automatic logic [31:0] phase_increment(input logic signed [31:0] velocity);
    logic signed [79:0] product, quotient;
    begin
      product = 80'(velocity) * 80'sd44798133900177;
      quotient = product >>> 32;
      if (product[31:0] > 32'h80000000
          || (product[31:0] == 32'h80000000 && product >= 0))
        quotient = quotient + 80'sd1;
      return quotient[31:0];
    end
  endfunction

  function automatic logic [31:0] root_u64(input logic [63:0] value);
    logic [65:0] remainder_value, trial;
    logic [31:0] root;
    begin
      remainder_value = 0;
      root = 0;
      for (int digit = 31; digit >= 0; digit--) begin
        remainder_value = (remainder_value << 2) | 66'(value[2*digit +: 2]);
        trial = (66'(root) << 2) | 66'd1;
        if (remainder_value >= trial) begin
          remainder_value = remainder_value - trial;
          root = (root << 1) | 32'd1;
        end else root = root << 1;
      end
      return root;
    end
  endfunction

  function automatic logic signed [31:0] topology(input int left, right);
    case (left ^ right)
      1: return 32'sd516461574;
      2, 3: return 32'sd158959695;
      4, 5, 6, 7: return 32'sd59840215;
      default: return 32'sd0;
    endcase
  endfunction
endpackage

module frp_m32_core_contract_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic clear_counters,
  input logic [1:0] scheduler_mode,
  input logic phase_load_valid,
  input logic [255:0] phase_load,
  input logic [255:0] frequency_load_q16,
  input logic [255:0] gamma_effective_word,
  input logic [255:0] thermal_node_factor_q30,
  input logic auto_target_enable,
  input logic [1:0] external_request_valid,
  input logic [5:0] external_request_cell_index,
  input logic [3:0] external_request_target,
  input logic [15:0] external_target_bank,
  output wire [2074:0] observed_outputs, expected_outputs,
  output logic [58:0] mismatch,
  output logic [23:0] reach
);
  import frp_m32_core_contract_pkg::*;
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
  assign observed_outputs = actual;
  assign expected_outputs = expected;

`ifdef FRP_M32_CORE_CONTRACT_NETLIST
  frp_m32_core_netlist dut (
`else
  frp_m32_core #(.CELLS(8), .REQUEST_LANES(2),
    .CELL_INDEX_BITS(3), .COUNTER_BITS(32)) dut (
`endif
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_pkg::frp_m31_scheduler_mode_e'(scheduler_mode)),
    .phase_load_valid(phase_load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(auto_target_enable),
    .external_request_valid(external_request_valid),
    .external_request_cell_index(external_request_cell_index),
    .external_request_target(external_request_target),
    .external_target_bank(external_target_bank),
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

  typedef struct packed {
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
  } execution_result_t;
  execution_result_t execution_expected;
  logic [15:0] target_ref;
  logic target_valid_ref;
  logic [31:0] captures_ref;
  logic [1:0] auto_valid, selected_valid;
  logic [5:0] auto_index, selected_index;
  logic [3:0] auto_target, selected_target;
  logic [15:0] selected_bank;
  function automatic logic polarized(input logic [1:0] value);
    return value == 1 || value == 3;
  endfunction

  function automatic logic opposite(input logic [1:0] a, b);
    return (a == 1 && b == 3) || (a == 3 && b == 1);
  endfunction

  function automatic logic [3:0] population(input logic [7:0] mask);
    logic [3:0] total;
    total = 0;
    for (int i = 0; i < 8; i++) total += {3'b0, mask[i]};
    return total;
  endfunction

  function automatic logic [2:0] schedule(
    input logic [1:0] mode, input logic [2:0] position
  );
    case (mode)
      0: return 0;
      1: return position == 7 ? 3'd2 : 3'd1;
      2: return position == 0 ? 3'd3 : 3'd4;
      default: return 7;
    endcase
  endfunction

  // Independent retained reference state; no initialization of DUT state.
  logic [15:0] state_ref, pending_ref, next_state, next_pending;
  logic [1:0] mode_ref;
  logic [31:0] index_ref, ticks_ref;
  logic [159:0] counts_ref;
  wire [2:0] phase_ref = schedule(mode_ref, index_ref[2:0]);
  wire commit_phase = phase_ref == 0 || phase_ref == 2 || phase_ref == 3;
  wire neutral_phase = phase_ref == 0 || phase_ref == 1 || phase_ref == 4;

  logic [7:0] pending_candidates, completions, lane_cells;
  logic [1:0] admitted, direct, changing;
  logic [2:0] lane_index [0:1];
  logic [1:0] old_value [0:1], wanted [0:1];
  logic [31:0] used, count_sum;
  logic target_domain, duplicate, allowed;

  always_comb begin
    execution_expected = '0;
    execution_expected.state_out = state_ref;
    execution_expected.pending_route_out = pending_ref;
    execution_expected.scheduler_mode_q = mode_ref;
    execution_expected.scheduler_state_q = phase_ref;
    execution_expected.ticks_recorded_q = ticks_ref;
    execution_expected.scheduler_count_free_q = counts_ref[0*32 +: 32];
    execution_expected.scheduler_count_balance_q = counts_ref[1*32 +: 32];
    execution_expected.scheduler_count_commit_q = counts_ref[2*32 +: 32];
    execution_expected.scheduler_count_excite_q = counts_ref[3*32 +: 32];
    execution_expected.scheduler_count_neutralize_q = counts_ref[4*32 +: 32];
    next_state = state_ref;
    next_pending = pending_ref;
    pending_candidates = 0;
    completions = 0;
    lane_cells = 0;
    admitted = 0;
    direct = 0;
    changing = 0;
    target_domain = 1;
    count_sum = 0;
    for (int i = 0; i < 5; i++) count_sum += counts_ref[32*i +: 32];
    for (int i = 0; i < 8; i++) begin
      if (selected_bank[2*i +: 2] == 2) target_domain = 0;
      pending_candidates[i] = tick_enable && commit_phase
        && state_ref[2*i +: 2] == 0 && polarized(pending_ref[2*i +: 2]);
    end
    // Ranking is independent of the DUT's mutable capacity loop.
    for (int i = 0; i < 8; i++) begin
      completions[i] = pending_candidates[i]
        && population(pending_candidates & (8'hff >> (8-i))) < 2;
      if (completions[i]) begin
        next_state[2*i +: 2] = pending_ref[2*i +: 2];
        next_pending[2*i +: 2] = 0;
      end
    end
    execution_expected.accepted_change_mask = completions;
    used = {28'b0, population(completions)};
    for (int lane = 0; lane < 2; lane++) begin
      lane_index[lane] = selected_index[3*lane +: 3];
      old_value[lane] = state_ref[2*lane_index[lane] +: 2];
      wanted[lane] = selected_target[2*lane +: 2];
      duplicate = lane == 1 && admitted[0] && lane_index[0] == lane_index[1];
      allowed = phase_ref < 5 && old_value[lane] != 2 && wanted[lane] != 2
        && (old_value[lane] == wanted[lane]
          || (old_value[lane] == 0 && commit_phase)
          || (polarized(old_value[lane]) && neutral_phase));
      admitted[lane] = tick_enable && selected_valid[lane] && allowed
        && !duplicate && !polarized(pending_ref[2*lane_index[lane] +: 2]);
      direct[lane] = admitted[lane] && opposite(old_value[lane], wanted[lane]);
      changing[lane] = admitted[lane] && old_value[lane] != wanted[lane];
      if (tick_enable && selected_valid[lane] && wanted[lane] == 2)
        target_domain = 0;
      // Admission before capacity also owns the duplicate-lane decision.
      if (admitted[lane]) begin
        lane_cells[lane_index[lane]] = 1;
        if (!changing[lane] || used < 2) begin
          execution_expected.request_accept[lane] = 1;
          execution_expected.accepted_cell_mask[lane_index[lane]] = 1;
          if (changing[lane]) begin
            execution_expected.accepted_change_mask[lane_index[lane]] = 1;
            used += 1;
            next_state[2*lane_index[lane] +: 2] = direct[lane] ? 2'd0 : wanted[lane];
            if (direct[lane]) begin
              execution_expected.neutral_routed_cell_mask[lane_index[lane]] = 1;
              next_pending[2*lane_index[lane] +: 2] = wanted[lane];
            end
          end
        end
      end
    end
    execution_expected.request_reject = selected_valid & {2{tick_enable}} & ~execution_expected.request_accept;
    execution_expected.accepted_changes = used;
    execution_expected.capacity_remaining = 2 - used;
    execution_expected.capacity_exhausted = used == 2;
    execution_expected.switch_load_numerator = used;
    execution_expected.requested_direct_events = {28'b0, population({6'b0, direct})};
    execution_expected.prevented_direct_events = execution_expected.requested_direct_events;
    execution_expected.neutral_routed_events = execution_expected.requested_direct_events;
    // Canonical reachable state makes direct writes, reserved-state emission
    // and pending overwrite impossible; invalid inputs still affect diagnostics.
    execution_expected.invariant_flags = 10'h3ff;
    execution_expected.invariant_flags[0] = target_domain;
    execution_expected.invariant_flags[1] = mode_ref != 3 && count_sum == ticks_ref;
    execution_expected.invariant_flags[2] = target_domain;
    execution_expected.invariant_flags[4] = phase_ref < 5;
    execution_expected.invariant_flags[5] = phase_ref < 5 && (rst_n || used == 0);
    execution_expected.invariant_flags[6] = phase_ref < 5;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_ref <= 0;
      pending_ref <= 0;
      mode_ref <= 0;
      index_ref <= 0;
      ticks_ref <= 0;
      counts_ref <= 0;
    end else begin
      mode_ref <= scheduler_mode;
      index_ref <= index_ref + {31'b0, tick_enable};
      ticks_ref <= (clear_counters ? 32'd0 : ticks_ref) + {31'b0, tick_enable};
      for (int i = 0; i < 5; i++)
        counts_ref[32*i +: 32] <= (clear_counters ? 32'd0 : counts_ref[32*i +: 32])
          + {31'b0, (tick_enable && phase_ref == i)};
      if (tick_enable) begin
        state_ref <= next_state;
        pending_ref <= next_pending;
      end
    end
  end

  // Reference request selection reads only retained reference banks.
  always_comb begin : reference_adapter
    integer selected;
    logic [1:0] old_symbol, goal;
    logic legal;
    selected = 0; auto_valid = 0; auto_index = 0; auto_target = 0;
    for (int i = 0; i < 8; i++) begin
      old_symbol = state_ref[2*i +: 2]; goal = target_ref[2*i +: 2];
      legal = phase_ref < 5 && old_symbol != 2 && goal != 2
        && (old_symbol == goal || (old_symbol == 0 && commit_phase)
          || (polarized(old_symbol) && neutral_phase));
      if (auto_target_enable && target_valid_ref && selected < 2
          && pending_ref[2*i +: 2] == 0 && old_symbol != goal && legal) begin
        auto_valid[selected] = 1;
        auto_index[3*selected +: 3] = 3'(i);
        auto_target[2*selected +: 2] = goal;
        selected++;
      end
    end
    selected_valid = auto_target_enable ? auto_valid : external_request_valid;
    selected_index = auto_target_enable ? auto_index : external_request_cell_index;
    selected_target = auto_target_enable ? auto_target : external_request_target;
    selected_bank = auto_target_enable ? target_ref : external_target_bank;
  end

  typedef struct packed {
    logic [255:0] phase_word_q;
    logic [255:0] frequency_current_q16;
    logic [255:0] coupling_field_q16;
    logic [255:0] phase_projection_q30;
    logic [15:0] phase_target;
    logic [31:0] pair_coherence_q30;
    logic [31:0] cluster_coherence_q30;
    logic [31:0] global_coherence_q30;
    logic [31:0] organization_dispersion_q30;
  } phase_result_t;
  phase_result_t phase_expected;
  logic [255:0] expected_phase_q, expected_frequency_q;
  logic [255:0] next_phase, next_frequency, increments;
  logic signed [31:0] reference_sine [0:4095];
  initial $readmemh("rtl/m31/frp_m31_sin_q30.mem", reference_sine);

  function automatic logic signed [31:0] order_of_group(
    input logic [255:0] phases, input int first, population, log_population
  );
    wide_t cosine_sum, sine_sum, mean_cosine, mean_sine;
    logic [11:0] address;
    logic [63:0] squared_length;
    logic [31:0] length_value;
    begin
      cosine_sum = 0;
      sine_sum = 0;
      for (int member = 0; member < population; member++) begin
        address = phases[32*(first+member)+20 +: 12];
        sine_sum = sine_sum + wide_t'(reference_sine[address]);
        address = address + 12'd1024;
        cosine_sum = cosine_sum + wide_t'(reference_sine[address]);
      end
      mean_cosine = round_pow2(cosine_sum, log_population);
      mean_sine = round_pow2(sine_sum, log_population);
      squared_length = $unsigned(mean_cosine * mean_cosine)
        + $unsigned(mean_sine * mean_sine);
      length_value = root_u64(squared_length);
      return length_value > 32'd1073741824 ? 32'sd1073741824 : $signed(length_value);
    end
  endfunction

  always_comb begin : independent_equations
    wide_t total, pair_sum, difference, target_frequency, correction;
    logic signed [31:0] thermal_i, thermal_j, pair_factor, weighted_factor;
    logic signed [31:0] projection, frequency, velocity, cluster_a, cluster_b;
    logic signed [31:0] scheduler_push;
    logic [31:0] relative_phase;
    logic [1:0] state_code;
    phase_expected = '0;
    phase_expected.phase_word_q = expected_phase_q;
    phase_expected.frequency_current_q16 = expected_frequency_q;
    next_phase = expected_phase_q;
    next_frequency = expected_frequency_q;
    increments = '0;
    scheduler_push = phase_ref == 3'd2 ? 32'sd655
      : phase_ref == 3'd3 ? 32'sd393 : 32'sd197;

    for (int cell_id = 0; cell_id < 8; cell_id++) begin
      projection = reference_sine[expected_phase_q[32*cell_id+20 +: 12]];
      phase_expected.phase_projection_q30[32*cell_id +: 32] = projection;
      phase_expected.phase_target[2*cell_id +: 2] = projection > 32'sd354334802
        ? 2'b01 : projection < -32'sd354334802 ? 2'b11 : 2'b00;
      thermal_i = $signed(thermal_node_factor_q30[32*cell_id +: 32]);
      total = 0;
      for (int neighbor = 0; neighbor < 8; neighbor++) begin
        if (neighbor != cell_id) begin
          thermal_j = $signed(thermal_node_factor_q30[32*neighbor +: 32]);
          pair_factor = multiply_fixed(thermal_i, thermal_j, 30);
          weighted_factor = multiply_fixed(topology(cell_id, neighbor), pair_factor, 30);
          relative_phase = expected_phase_q[32*neighbor +: 32]
            - expected_phase_q[32*cell_id +: 32]
            - gamma_effective_word[32*cell_id +: 32];
          total = total + wide_t'(multiply_fixed(
            weighted_factor, reference_sine[relative_phase[31:20]], 30));
        end
      end
      phase_expected.coupling_field_q16[32*cell_id +: 32] = multiply_fixed(
        32'sd18350, clip_s32(round_pow2(wide_t'(clip_s32(total)), 14)), 16);

      state_code = state_ref[2*cell_id +: 2];
      target_frequency = 64'sd65536 + (state_code[0] ? 64'sd3932 : 64'sd0)
        + (execution_expected.accepted_change_mask[cell_id] ? 64'sd7864 : 64'sd0);
      frequency = $signed(expected_frequency_q[32*cell_id +: 32]);
      correction = round_pow2((target_frequency - wide_t'(frequency)) * 64'sd19661, 16);
      frequency = clip_s32(wide_t'(frequency) + wide_t'(clip_s32(correction)));
      next_frequency[32*cell_id +: 32] = frequency;
      velocity = multiply_fixed(frequency, 32'sd3932, 16) + scheduler_push
        + $signed(phase_expected.coupling_field_q16[32*cell_id +: 32]);
      increments[32*cell_id +: 32] = phase_increment(velocity);
      next_phase[32*cell_id +: 32] = expected_phase_q[32*cell_id +: 32]
        + increments[32*cell_id +: 32];
    end

    pair_sum = 0;
    for (int pair_id = 0; pair_id < 4; pair_id++)
      pair_sum = pair_sum + wide_t'(order_of_group(expected_phase_q, 2*pair_id, 2, 1));
    cluster_a = order_of_group(expected_phase_q, 0, 4, 2);
    cluster_b = order_of_group(expected_phase_q, 4, 4, 2);
    phase_expected.pair_coherence_q30 = 32'(round_pow2(pair_sum, 2));
    phase_expected.cluster_coherence_q30 = 32'(round_pow2(wide_t'(cluster_a) + wide_t'(cluster_b), 1));
    phase_expected.global_coherence_q30 = order_of_group(expected_phase_q, 0, 8, 3);
    difference = wide_t'(cluster_a) - wide_t'(cluster_b);
    if (difference < 0) difference = -difference;
    phase_expected.organization_dispersion_q30 = 32'(round_pow2(difference, 1));
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int cell_id = 0; cell_id < 8; cell_id++) begin
        expected_phase_q[32*cell_id +: 32] <= 32'(cell_id) << 29;
        expected_frequency_q[32*cell_id +: 32] <= 32'd65536;
      end
    end else if (phase_load_valid) begin
      expected_phase_q <= phase_load;
      expected_frequency_q <= frequency_load_q16;
    end else if (tick_enable) begin
      expected_phase_q <= next_phase;
      expected_frequency_q <= next_frequency;
    end else begin
      expected_phase_q <= expected_phase_q;
      expected_frequency_q <= expected_frequency_q;
    end
  end

  logic signed [31:0] temperature_ref, peak_ref, next_temperature;
  logic signed [31:0] cycle_cost, capacity, pressure, margin;
  logic [31:0] samples_ref;
  always_comb begin : reference_thermal_stability
    integer neutral_count;
    neutral_count = 0;
    for (int i = 0; i < 8; i++)
      if (state_ref[2*i +: 2] == 0) neutral_count++;
    cycle_cost = 32'(execution_expected.accepted_changes * 32'd8192);
    next_temperature = clip_s32(
      wide_t'(multiply_fixed(temperature_ref, 32'sd1020054733, 30))
      + wide_t'(multiply_fixed(cycle_cost, 32'sd10737418, 30)));
    capacity = clip_s32(64'sd53740
      + wide_t'(multiply_fixed(32'sd22282, phase_expected.global_coherence_q30, 30))
      + wide_t'(multiply_fixed(32'sd10486, phase_expected.cluster_coherence_q30, 30))
      + wide_t'(multiply_fixed(32'sd5243, 32'(neutral_count * 64'sd134217728), 30)));
    pressure = clip_s32(wide_t'(temperature_ref) + wide_t'(cycle_cost));
    margin = capacity - pressure;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      target_ref <= 0; target_valid_ref <= 0; captures_ref <= 0;
      temperature_ref <= 0; peak_ref <= 0; samples_ref <= 0;
    end else begin
      if (tick_enable) begin
        target_ref <= phase_expected.phase_target;
        target_valid_ref <= 1;
      end
      if (clear_counters) begin
        captures_ref <= 0;
        temperature_ref <= 0; peak_ref <= 0; samples_ref <= 0;
      end else if (tick_enable) begin
        if (captures_ref != 32'hffffffff) captures_ref <= captures_ref + 32'd1;
        temperature_ref <= next_temperature;
        if (next_temperature > peak_ref) peak_ref <= next_temperature;
        samples_ref <= samples_ref + 32'd1;
      end
    end
  end

  always_comb begin : complete_observation
    expected = '0;
    expected.accepted_cell_mask = execution_expected.accepted_cell_mask;
    expected.accepted_change_mask = execution_expected.accepted_change_mask;
    expected.accepted_changes = execution_expected.accepted_changes;
    expected.accepted_target_capture_events_q = captures_ref;
    expected.actual_direct_events = execution_expected.actual_direct_events;
    expected.capacity_exhausted = execution_expected.capacity_exhausted;
    expected.capacity_remaining = execution_expected.capacity_remaining;
    expected.cluster_coherence_q30 = phase_expected.cluster_coherence_q30;
    expected.coherence_capacity_q16 = capacity;
    expected.coupling_field_q16 = phase_expected.coupling_field_q16;
    expected.execution_request_cell_index = selected_index;
    expected.execution_request_target = selected_target;
    expected.execution_request_valid = selected_valid;
    expected.execution_target_bank = selected_bank;
    expected.frequency_current_q16 = phase_expected.frequency_current_q16;
    expected.global_coherence_q30 = phase_expected.global_coherence_q30;
    expected.invariant_flags = execution_expected.invariant_flags;
    expected.neutral_routed_cell_mask = execution_expected.neutral_routed_cell_mask;
    expected.neutral_routed_events = execution_expected.neutral_routed_events;
    expected.normalized_cycle_cost_q16 = cycle_cost;
    expected.organization_dispersion_q30 = phase_expected.organization_dispersion_q30;
    expected.pair_coherence_q30 = phase_expected.pair_coherence_q30;
    expected.peak_temperature_proxy_q16 = peak_ref;
    expected.pending_route_out = execution_expected.pending_route_out;
    expected.phase_projection_q30 = phase_expected.phase_projection_q30;
    expected.phase_request_cell_index = auto_index;
    expected.phase_request_target = auto_target;
    expected.phase_request_valid = auto_valid;
    expected.phase_target_domain_valid = 1'b1;
    expected.phase_target_source = phase_expected.phase_target;
    expected.phase_word_q = phase_expected.phase_word_q;
    expected.pressure_q16 = pressure;
    expected.prevented_direct_events = execution_expected.prevented_direct_events;
    expected.queue_overflow_events = execution_expected.queue_overflow_events;
    expected.registered_request_enable = auto_target_enable && target_valid_ref;
    expected.registered_target_domain_valid = 1'b1;
    expected.registered_target_q = target_ref;
    expected.registered_target_valid_q = target_valid_ref;
    expected.rejected_target_capture_events_q = 32'd0;
    expected.request_accept = execution_expected.request_accept;
    expected.request_reject = execution_expected.request_reject;
    expected.requested_direct_events = execution_expected.requested_direct_events;
    expected.reserved_state_events = execution_expected.reserved_state_events;
    expected.scheduler_count_balance_q = execution_expected.scheduler_count_balance_q;
    expected.scheduler_count_commit_q = execution_expected.scheduler_count_commit_q;
    expected.scheduler_count_excite_q = execution_expected.scheduler_count_excite_q;
    expected.scheduler_count_free_q = execution_expected.scheduler_count_free_q;
    expected.scheduler_count_neutralize_q = execution_expected.scheduler_count_neutralize_q;
    expected.scheduler_mode_q = execution_expected.scheduler_mode_q;
    expected.scheduler_state_q = execution_expected.scheduler_state_q;
    expected.stability_margin_q16 = margin;
    expected.stable = margin > 0;
    expected.state_out = execution_expected.state_out;
    expected.switch_load_numerator = execution_expected.switch_load_numerator;
    expected.target_capture_accepted = tick_enable;
    expected.target_capture_rejected = 1'b0;
    expected.temperature_proxy_q16 = temperature_ref;
    expected.thermal_sample_count_q = samples_ref;
    expected.ticks_recorded_q = execution_expected.ticks_recorded_q;
  end

  logic history_valid = 0;
  always @(posedge clk) history_valid <= 1;
  always_comb begin
    a_initial_reset: if (!history_valid) assume (!rst_n);
    mismatch[0] = actual.accepted_cell_mask != expected.accepted_cell_mask;
    mismatch[1] = actual.accepted_change_mask != expected.accepted_change_mask;
    mismatch[2] = actual.accepted_changes != expected.accepted_changes;
    mismatch[3] = actual.accepted_target_capture_events_q != expected.accepted_target_capture_events_q;
    mismatch[4] = actual.actual_direct_events != expected.actual_direct_events;
    mismatch[5] = actual.capacity_exhausted != expected.capacity_exhausted;
    mismatch[6] = actual.capacity_remaining != expected.capacity_remaining;
    mismatch[7] = actual.cluster_coherence_q30 != expected.cluster_coherence_q30;
    mismatch[8] = actual.coherence_capacity_q16 != expected.coherence_capacity_q16;
    mismatch[9] = actual.coupling_field_q16 != expected.coupling_field_q16;
    mismatch[10] = actual.execution_request_cell_index != expected.execution_request_cell_index;

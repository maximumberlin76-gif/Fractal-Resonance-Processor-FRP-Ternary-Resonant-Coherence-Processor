// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Independent functional contract for the complete eight-cell phase engine.
// Nine public ports, 1168 output bits, and 512 retained state bits are checked.
// The oracle reads public ports only; it never calls DUT arithmetic helpers.
// Rounding uses floor/remainder; square root uses radix-four restoration,
// independently of the DUT magnitude rounding and trial-square algorithm.
// A separate ROM instance reads the published 4096-word table. Qualification
// must check every word independently against the analytic sine definition;
// matching two copies of a corrupt table is not sufficient evidence.
//
// Define FRP_M31_PHASE_CONTRACT_NETLIST to select a fresh *_netlist DUT.
// Preserve the source RTL and validate the fresh netlist identity. Only the
// four ROM simulation guards may be removed in the private synthesis copy.
// The reference arithmetic, reference ROM and assertions must remain intact.
// The only assumption is initial sampled reset; later resets, signed input
// extremes, reserved state codes and all eight scheduler codes are free.
// Prove reset base AND induction; replay and reach witnesses are not proofs.
//
// Contract: reset > load > tick > hold; load works while tick is disabled.
// Relative phase is theta_j-theta_i-gamma_i modulo 2^32. Thermal products
// round and saturate separately. Coupling sums saturate before Q30-to-Q16
// conversion. The frequency correction uses the full signed difference.
// Velocity wraps to signed 32 bits; phase conversion uses a wide product;
// phase accumulation wraps modulo 2^32. Targets use strict Q30 comparisons
// against +/-354334802 and are not executed cell states. Coherence is clipped
// to Q30 one; dispersion is half the absolute difference of cluster orders.
// This is a discrete fixed-point contract, not physical resonance, complete
// M32 qualification, four-state semantics or Python reference-model equality.

`ifndef FRP_M31_PHASE_INTERFERENCE_CONTRACT_FORMAL_SV
`define FRP_M31_PHASE_INTERFERENCE_CONTRACT_FORMAL_SV
`include "frp_m31_phase_interference.sv"

package frp_m31_phase_contract_pkg;
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

module frp_m31_phase_interference_contract_formal (
  input logic clk,
  input logic rst_n,
  input logic tick_enable,
  input logic load_valid,
  input logic [255:0] phase_load,
  input logic [255:0] frequency_load_q16,
  input logic [255:0] gamma_effective_word,
  input logic [255:0] thermal_node_factor_q30,
  input logic [15:0] retained_state,
  input logic [7:0] switch_activity,
  input logic [2:0] scheduler_state,
  output wire [1167:0] observed_outputs,
  output wire [1167:0] expected_outputs,
  output logic [8:0] mismatch,
  output logic [23:0] reach
);
  import frp_m31_phase_contract_pkg::*;
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
  } observations_t;
  wire observations_t actual;
  observations_t expected;
  logic [255:0] expected_phase_q, expected_frequency_q;
  logic [255:0] next_phase, next_frequency, increments;
  logic signed [31:0] reference_sine [0:4095];
  logic history_valid = 1'b0;
  assign observed_outputs = actual;
  assign expected_outputs = expected;
  initial $readmemh("rtl/m31/frp_m31_sin_q30.mem", reference_sine);

`ifdef FRP_M31_PHASE_CONTRACT_NETLIST
  frp_m31_phase_interference_netlist dut (
`else
  frp_m31_phase_interference #(.CELLS(8)) dut (
`endif
    .clk(clk),
    .rst_n(rst_n),
    .tick_enable(tick_enable),
    .load_valid(load_valid),
    .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .retained_state(retained_state),
    .switch_activity(switch_activity),
    .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
    .phase_word_q(actual.phase_word_q),
    .frequency_current_q16(actual.frequency_current_q16),
    .coupling_field_q16(actual.coupling_field_q16),
    .phase_projection_q30(actual.phase_projection_q30),
    .phase_target(actual.phase_target),
    .pair_coherence_q30(actual.pair_coherence_q30),
    .cluster_coherence_q30(actual.cluster_coherence_q30),
    .global_coherence_q30(actual.global_coherence_q30),
    .organization_dispersion_q30(actual.organization_dispersion_q30)
  );

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
    expected = '0;
    expected.phase_word_q = expected_phase_q;
    expected.frequency_current_q16 = expected_frequency_q;
    next_phase = actual.phase_word_q;
    next_frequency = actual.frequency_current_q16;
    increments = '0;
    scheduler_push = scheduler_state == 3'd2 ? 32'sd655
      : scheduler_state == 3'd3 ? 32'sd393 : 32'sd197;

    for (int cell_id = 0; cell_id < 8; cell_id++) begin
      projection = reference_sine[actual.phase_word_q[32*cell_id+20 +: 12]];
      expected.phase_projection_q30[32*cell_id +: 32] = projection;
      expected.phase_target[2*cell_id +: 2] = projection > 32'sd354334802
        ? 2'b01 : projection < -32'sd354334802 ? 2'b11 : 2'b00;
      thermal_i = $signed(thermal_node_factor_q30[32*cell_id +: 32]);
      total = 0;
      for (int neighbor = 0; neighbor < 8; neighbor++) begin
        if (neighbor != cell_id) begin
          thermal_j = $signed(thermal_node_factor_q30[32*neighbor +: 32]);
          pair_factor = multiply_fixed(thermal_i, thermal_j, 30);
          weighted_factor = multiply_fixed(topology(cell_id, neighbor), pair_factor, 30);
          relative_phase = actual.phase_word_q[32*neighbor +: 32]
            - actual.phase_word_q[32*cell_id +: 32]
            - gamma_effective_word[32*cell_id +: 32];
          total = total + wide_t'(multiply_fixed(
            weighted_factor, reference_sine[relative_phase[31:20]], 30));
        end
      end
      expected.coupling_field_q16[32*cell_id +: 32] = multiply_fixed(
        32'sd18350, clip_s32(round_pow2(wide_t'(clip_s32(total)), 14)), 16);

      state_code = retained_state[2*cell_id +: 2];
      target_frequency = 64'sd65536 + (state_code[0] ? 64'sd3932 : 64'sd0)
        + (switch_activity[cell_id] ? 64'sd7864 : 64'sd0);
      frequency = $signed(actual.frequency_current_q16[32*cell_id +: 32]);
      correction = round_pow2((target_frequency - wide_t'(frequency)) * 64'sd19661, 16);
      frequency = clip_s32(wide_t'(frequency) + wide_t'(clip_s32(correction)));
      next_frequency[32*cell_id +: 32] = frequency;
      velocity = multiply_fixed(frequency, 32'sd3932, 16) + scheduler_push
        + $signed(expected.coupling_field_q16[32*cell_id +: 32]);
      increments[32*cell_id +: 32] = phase_increment(velocity);
      next_phase[32*cell_id +: 32] = actual.phase_word_q[32*cell_id +: 32]
        + increments[32*cell_id +: 32];
    end

    pair_sum = 0;
    for (int pair_id = 0; pair_id < 4; pair_id++)
      pair_sum = pair_sum + wide_t'(order_of_group(actual.phase_word_q, 2*pair_id, 2, 1));
    cluster_a = order_of_group(actual.phase_word_q, 0, 4, 2);
    cluster_b = order_of_group(actual.phase_word_q, 4, 4, 2);
    expected.pair_coherence_q30 = 32'(round_pow2(pair_sum, 2));
    expected.cluster_coherence_q30 = 32'(round_pow2(wide_t'(cluster_a) + wide_t'(cluster_b), 1));
    expected.global_coherence_q30 = order_of_group(actual.phase_word_q, 0, 8, 3);
    difference = wide_t'(cluster_a) - wide_t'(cluster_b);
    if (difference < 0) difference = -difference;
    expected.organization_dispersion_q30 = 32'(round_pow2(difference, 1));
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int cell_id = 0; cell_id < 8; cell_id++) begin
        expected_phase_q[32*cell_id +: 32] <= 32'(cell_id) << 29;
        expected_frequency_q[32*cell_id +: 32] <= 32'd65536;
      end
    end else if (load_valid) begin
      expected_phase_q <= phase_load;
      expected_frequency_q <= frequency_load_q16;
    end else if (tick_enable) begin
      expected_phase_q <= next_phase;
      expected_frequency_q <= next_frequency;
    end else begin
      expected_phase_q <= actual.phase_word_q;
      expected_frequency_q <= actual.frequency_current_q16;
    end
  end

  logic previous_reset, previous_tick, previous_load;
  logic [2:0] previous_schedule;
  logic [255:0] previous_phase_load, previous_frequency_load;
  logic [255:0] previous_phase, previous_frequency, previous_increments;
  wire live_transition = history_valid && previous_reset && rst_n;
  always @(posedge clk) begin
    history_valid <= 1'b1;
    previous_reset <= rst_n;
    previous_tick <= tick_enable;
    previous_load <= load_valid;
    previous_schedule <= scheduler_state;
    previous_phase_load <= phase_load;
    previous_frequency_load <= frequency_load_q16;
    previous_phase <= actual.phase_word_q;
    previous_frequency <= actual.frequency_current_q16;
    previous_increments <= increments;
  end

  always_comb begin
    a_initial_reset: if (!history_valid) assume (!rst_n);
    mismatch[0] = actual.phase_word_q != expected.phase_word_q;
    mismatch[1] = actual.frequency_current_q16 != expected.frequency_current_q16;
    mismatch[2] = actual.coupling_field_q16 != expected.coupling_field_q16;
    mismatch[3] = actual.phase_projection_q30 != expected.phase_projection_q30;
    mismatch[4] = actual.phase_target != expected.phase_target;
    mismatch[5] = actual.pair_coherence_q30 != expected.pair_coherence_q30;
    mismatch[6] = actual.cluster_coherence_q30 != expected.cluster_coherence_q30;
    mismatch[7] = actual.global_coherence_q30 != expected.global_coherence_q30;
    mismatch[8] = actual.organization_dispersion_q30 != expected.organization_dispersion_q30;
    if (history_valid) begin
      a_phase_word_q: assert (!mismatch[0]);
      a_frequency_current_q16: assert (!mismatch[1]);
      a_coupling_field_q16: assert (!mismatch[2]);
      a_phase_projection_q30: assert (!mismatch[3]);
      a_phase_target: assert (!mismatch[4]);
      a_pair_coherence_q30: assert (!mismatch[5]);
      a_cluster_coherence_q30: assert (!mismatch[6]);
      a_global_coherence_q30: assert (!mismatch[7]);
      a_organization_dispersion_q30: assert (!mismatch[8]);
      a_pair_range: assert (actual.pair_coherence_q30 <= 32'd1073741824);
      a_cluster_range: assert (actual.cluster_coherence_q30 <= 32'd1073741824);
      a_global_range: assert (actual.global_coherence_q30 <= 32'd1073741824);
      a_dispersion_range: assert (actual.organization_dispersion_q30 <= 32'd536870912);
    end
  end
  for (genvar cell_id = 0; cell_id < 8; cell_id++) begin : target_domain
    always_comb begin
      if (history_valid)
        a_ternary_target: assert (actual.phase_target[2*cell_id +: 2] != 2'b10);
    end
  end

  // Witness targets exercise behavior; they never constrain inputs or state.
  always_comb begin
    reach = '0;
    if (live_transition) begin
      reach[0] = previous_load && previous_tick
        && actual.phase_word_q == previous_phase_load
        && actual.frequency_current_q16 == previous_frequency_load
        && previous_phase_load != previous_phase;
      reach[1] = previous_load && !previous_tick
        && actual.phase_word_q == previous_phase_load
        && previous_frequency_load != previous_frequency;
      reach[2] = !previous_load && !previous_tick
        && actual.phase_word_q == previous_phase
        && actual.frequency_current_q16 == previous_frequency;
      for (int code = 0; code < 8; code++)
        reach[3+code] = !previous_load && previous_tick
          && previous_schedule == 3'(code) && actual.phase_word_q != previous_phase;
      reach[11] = previous_load && previous_frequency_load[31]
        && actual.frequency_current_q16[31:0] == previous_frequency_load[31:0];
      reach[12] = previous_load && previous_frequency_load[63:0] == 64'h7fffffff80000000;
      reach[21] = !previous_load && previous_tick && !previous_increments[31]
        && actual.phase_word_q[31:0] < previous_phase[31:0];
      reach[22] = !previous_load && previous_tick && previous_increments[31]
        && actual.phase_word_q[31:0] > previous_phase[31:0];
    end
    if (history_valid && rst_n) begin
      reach[13] = thermal_node_factor_q30 == 0 && actual.coupling_field_q16 == 0;
      reach[14] = gamma_effective_word[31:0] == 32'hffffffff && actual.phase_word_q[31:0] != 0;
      reach[15] = thermal_node_factor_q30[63:0] == 64'h0000000040000000
        && actual.coupling_field_q16[31:0] != 0;
      reach[16] = actual.phase_target[5:0] == 6'b001101 && actual.global_coherence_q30 != 0;
      reach[18] = actual.phase_word_q == {8{actual.phase_word_q[31:0]}}
        && actual.global_coherence_q30 == 32'd1073741824;
      reach[19] = actual.global_coherence_q30 == 0 && actual.phase_word_q != 0;
      reach[20] = actual.organization_dispersion_q30 > 32'd268435456;
      reach[23] = thermal_node_factor_q30[63:0] == 64'h7fffffff80000000
        && actual.coupling_field_q16[31:0] != 0;
    end
    reach[17] = history_valid && previous_reset && !rst_n
      && previous_phase != 256'he0000000c0000000a00000008000000060000000400000002000000000000000;
  end
endmodule

`endif

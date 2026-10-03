// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Included dependencies retain their existing licenses.
// FRP M31 clocked phase-step boundaries. Author: Alchimist.
// Build from the repository root with --binary --timing --assert -Irtl/m31
// and --top-module frp_m31_phase_step_boundary_tb.
// All nine public fields are compared before, after and between clock edges.
// The independent oracle uses signed 128-bit arithmetic, analytic sine and
// binary-search integer roots; no DUT helpers, ROM or internal state is read.
// Fixed counts and signatures are predicted by a separate Python integer model.
// Covers both signs of every 16-bit frequency-filter rounding residue,
// signed endpoints, multi-turn phase steps, old-bank coupling, asynchronous
// reset and load/tick/hold priorities. Thermal factors stay in [0, Q30 one].
// Stages 1 and 4 include reserved input encodings as port diagnostics only.
// Phase targets are observations, not executed ternary transitions. This is
// a standalone phase-engine workload, not scheduler-cadence qualification,
// full-core reachability, exhaustive input coverage, physical timing,
// hardware readiness or equivalence to model v0.9.3.

`ifndef FRP_M31_PHASE_STEP_BOUNDARY_TB_SV
`define FRP_M31_PHASE_STEP_BOUNDARY_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_phase_interference.sv"

package frp_m31_phase_step_boundary_tb_pkg;
  typedef logic signed [127:0] wide_t;
  typedef struct packed {
    logic [255:0] phase_bank, frequency_bank, coupling, projection;
    logic [15:0] target;
    logic signed [31:0] pair_order, cluster_order, global_order, dispersion;
  } outputs_t;
endpackage

module frp_m31_phase_step_boundary_tb;
  import frp_m31_phase_step_boundary_tb_pkg::*;
  localparam int unsigned EXPECTED_COUNTS [0:4] = '{170, 1728, 98304, 7692, 5184};
  localparam int unsigned EXPECTED_EVENTS [0:4] = '{37688, 37688, 9, 9, 37684};
  localparam int unsigned EXPECTED_SCHEDULER [0:7] = '{3857, 3858, 3855, 3857, 3854, 168, 168, 168};
  localparam int unsigned EXPECTED_STATE_ACTIVITY [0:3][0:1] = '{
    '{25930, 25932},
    '{25931, 25936},
    '{1344, 1344},
    '{25935, 25928}
  };
  localparam int unsigned EXPECTED_ROUNDING [0:2][0:6] = '{
    '{450, 42162, 385, 38410, 40065, 257, 36551},
    '{214, 62994, 102, 65020, 15046, 1, 14903},
    '{33, 68301, 0, 67633, 11155, 0, 11158}
  };
  localparam logic [63:0] EXPECTED_SIGNATURES [0:4] = '{
    64'hc1c4ee441879b449,
    64'h5a2098207a15f3d9,
    64'hb43edecaecd9441b,
    64'ha6efa8b02a901d66,
    64'h10edd9da06ef2aad
  };
  localparam logic [31:0] PHASE_CASES [0:7] = '{32'h00000000, 32'h00000001, 32'h000fffff, 32'h00100000, 32'h7fffffff, 32'h80000000, 32'hfffffffe, 32'hffffffff};

  logic clk = 0, rst_n = 1, load_valid = 0, tick_enable = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0, thermal_node_factor_q30 = 0;
  logic [15:0] retained_state = 0;
  logic [7:0] switch_activity = 0;
  frp_m31_pkg::frp_m31_scheduler_state_e scheduler_state = frp_m31_pkg::FRP_SCHED_FREE;
  outputs_t outputs, expected;
  logic [255:0] model_phase = 0, model_frequency = 0;
  logic signed [31:0] sine_reference[4096];
  logic [65535:0] residue_seen[2];
  logic [1167:0] output_ones = 0, output_zeros = 0;
  logic [31:0] random_word = 31015;
  logic [63:0] signature = 64'hcbf29ce484222325;
  int unsigned stage = 0, observations = 0, checks = 0;
  int unsigned loads = 0, ticks = 0, holds = 0, reset_updates = 0;
  int unsigned load_over_tick = 0, reset_low = 0, reset_high = 0;
  int unsigned wide_deltas = 0, multi_turn_steps = 0;
  int unsigned positive_wraps = 0, negative_wraps = 0, coupled_cell_ticks = 0;
  int unsigned stage_counts[5], event_counts[5], scheduler_counts[8];
  int unsigned state_activity_counts[4][2], rounding_bins[3][7];
  bit done = 0;
  event sample_request, sample_complete;
  int requested_kind = 0;
  bit sample_busy = 0;

  frp_m31_phase_interference dut (
    .clk, .rst_n, .tick_enable, .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30, .retained_state,
    .switch_activity, .scheduler_state,
    .phase_word_q(outputs.phase_bank), .frequency_current_q16(outputs.frequency_bank),
    .coupling_field_q16(outputs.coupling), .phase_projection_q30(outputs.projection),
    .phase_target(outputs.target), .pair_coherence_q30(outputs.pair_order),
    .cluster_coherence_q30(outputs.cluster_order), .global_coherence_q30(outputs.global_order),
    .organization_dispersion_q30(outputs.dispersion)
  );

  initial begin #10000; $fatal(1, "Phase-step boundary watchdog"); end
  final begin
    if (!done) $fatal(1, "Incomplete phase-step boundary qualification");
  end

  function automatic logic [31:0] next_word;
    random_word = random_word * 32'd1664525 + 32'd1013904223;
    return random_word;
  endfunction

  function automatic wide_t rounded(input wide_t value, denominator);
    wide_t quotient, remainder;
    quotient = value / denominator; remainder = value % denominator;
    if (2 * remainder >= denominator) quotient++;
    if (2 * remainder <= -denominator) quotient--;
    return quotient;
  endfunction

  function automatic wide_t saturate(input wide_t value);
    if (value > 128'sd2147483647) return 128'sd2147483647;
    if (value < -128'sd2147483648) return -128'sd2147483648;
    return value;
  endfunction

  function automatic wide_t scaled(input wide_t value, denominator, input int row);
    wide_t remainder;
    int bin_index;
    remainder = (value < 0 ? -value : value) % denominator;
    bin_index = 0;
    if (remainder != 0) begin
      bin_index = value < 0 ? 4 : 1;
      if (2 * remainder == denominator) bin_index++;
      if (2 * remainder > denominator) bin_index += 2;
    end
    rounding_bins[row][bin_index]++;
    return rounded(value, denominator);
  endfunction

  function automatic wide_t target_for(input int state_value, activity);
    return 128'sd65536 + ((state_value == 1 || state_value == 3) ? 128'sd3932 : 0)
                      + (activity != 0 ? 128'sd7864 : 0);
  endfunction

  function automatic wide_t push_for(input int state_value);
    case (state_value)
      2: return 128'sd655;
      3: return 128'sd393;
      default: return 128'sd197;
    endcase
  endfunction

  function automatic wide_t frequency_case(input int k, input wide_t target_value);
    case (k)
      0: return -128'sd2147483648; 1: return -128'sd2147483647;
      2: return -128'sd65536; 3: return -128'sd32768;
      4: return -128'sd1; 5: return 0; 6: return 1; 7: return 32767;
      8: return 32768; 9: return 65535; 10: return 65536; 11: return 65537;
      12: return 2147483646; 13: return 2147483647;
      14: return target_value-32769; 15: return target_value-32768;
      16: return target_value-32767; 17: return target_value+32767;
      18: return target_value+32768; 19: return target_value+32769;
      20: return target_value-2; 21: return target_value-1;
      22: return target_value+1; 23: return target_value+2;
      default: begin $fatal(1, "Invalid frequency case"); return 0; end
    endcase
  endfunction

  function automatic wide_t coupling_for(input int receiver);
    wide_t total, factor, weight, relative, term;
    int distance, address;
    total = 0;
    if (thermal_node_factor_q30[receiver*32 +: 32] == 0) return 0;
    for (int j = 0; j < 8; j++) begin
      if (j == receiver || thermal_node_factor_q30[j*32 +: 32] == 0) continue;
      distance = receiver ^ j;
      weight = distance == 1 ? 128'sd516461574 : distance < 4 ? 128'sd158959695 : 128'sd59840215;
      factor = saturate(rounded(wide_t'($signed(thermal_node_factor_q30[receiver*32 +: 32]))
                              * wide_t'($signed(thermal_node_factor_q30[j*32 +: 32])), 1073741824));
      factor = saturate(rounded(weight * factor, 1073741824));
      relative = (wide_t'({1'b0, model_phase[j*32 +: 32]})
                 - wide_t'({1'b0, model_phase[receiver*32 +: 32]})
                 - wide_t'({1'b0, gamma_effective_word[receiver*32 +: 32]})) % 128'sd4294967296;
      if (relative < 0) relative += 128'sd4294967296;
      address = int'(relative / 1048576);
      term = saturate(rounded(factor * wide_t'(sine_reference[address]), 1073741824));
      total += term;
    end
    return saturate(rounded(saturate(rounded(saturate(total), 16384)) * 18350, 65536));
  endfunction

  function automatic logic signed [31:0] order_for(input int first, population);
    wide_t x, y, square, lower, upper, midpoint;
    int address;
    x = 0; y = 0;
    for (int i = first; i < first + population; i++) begin
      address = int'(model_phase[i*32 +: 32] >> 20);
      x += wide_t'(sine_reference[(address + 1024) % 4096]);
      y += wide_t'(sine_reference[address]);
    end
    x = rounded(x, wide_t'(population)); y = rounded(y, wide_t'(population));
    square = x*x + y*y; lower = 0; upper = 128'sd4294967296;
    while (upper - lower > 1) begin
      midpoint = (lower + upper) / 2;
      if (midpoint * midpoint <= square) lower = midpoint; else upper = midpoint;
    end
    if (lower * lower > square || (lower + 1) * (lower + 1) <= square)
      $fatal(1, "Invalid phase-step reference root");
    return lower > 128'sd1073741824 ? 32'sd1073741824 : lower[31:0];
  endfunction

  task automatic advance_model;
    logic [255:0] next_phase, next_frequency;
    logic signed [31:0] velocity_word;
    wide_t old_frequency, delta, correction, new_frequency, velocity, step, unwrapped, coupling;
    int state_value, activity, residue;
    for (int i = 0; i < 8; i++) begin
      state_value = int'(retained_state[i*2 +: 2]); activity = int'(switch_activity[i]);
      old_frequency = wide_t'($signed(model_frequency[i*32 +: 32]));
      delta = target_for(state_value, activity) - old_frequency;
      if (delta > 128'sd2147483647 || delta < -128'sd2147483648) wide_deltas++;
      if (stage == 2) begin
        residue = int'(((delta < 0 ? -delta : delta) * 19661) % 65536);
        residue_seen[delta < 0 ? 1 : 0][residue] = 1;
      end
      correction = saturate(scaled(delta * 19661, 65536, 0));
      new_frequency = saturate(old_frequency + correction);
      coupling = coupling_for(i);
      if (coupling != 0) coupled_cell_ticks++;
      velocity = saturate(scaled(new_frequency * 3932, 65536, 1))
                 + push_for(int'(scheduler_state)) + coupling;
      velocity_word = velocity[31:0];
      step = scaled(wide_t'(velocity_word) * 128'sd44798133900177, 128'sd4294967296, 2);
      if (step >= 128'sd4294967296 || step <= -128'sd4294967296) multi_turn_steps++;
      unwrapped = wide_t'({1'b0, model_phase[i*32 +: 32]}) + step;
      if (unwrapped > 128'sd4294967295) positive_wraps++;
      if (unwrapped < 0) negative_wraps++;
      next_phase[i*32 +: 32] = unwrapped[31:0];
      next_frequency[i*32 +: 32] = new_frequency[31:0];
      state_activity_counts[state_value][activity]++;
    end
    // Every receiver uses the same old bank, including its coupling field.
    model_phase = next_phase; model_frequency = next_frequency;
  endtask

  task automatic predict_outputs;
    wide_t pair_sum, first_cluster, second_cluster, difference;
    logic signed [31:0] sine_value;
    expected = '0; expected.phase_bank = model_phase; expected.frequency_bank = model_frequency;
    for (int i = 0; i < 8; i++) begin
      sine_value = sine_reference[model_phase[i*32 +: 32] >> 20];
      expected.projection[i*32 +: 32] = sine_value;
      expected.target[i*2 +: 2] = sine_value > 354334802 ? 2'b01
                               : sine_value < -354334802 ? 2'b11 : 2'b00;
      expected.coupling[i*32 +: 32] = 32'(coupling_for(i));
    end
    pair_sum = 0;
    for (int g = 0; g < 4; g++) pair_sum += wide_t'(order_for(2*g, 2));
    first_cluster = wide_t'(order_for(0, 4)); second_cluster = wide_t'(order_for(4, 4));
    difference = first_cluster - second_cluster;
    expected.pair_order = 32'(rounded(pair_sum, 4));
    expected.cluster_order = 32'(rounded(first_cluster + second_cluster, 2));
    expected.global_order = order_for(0, 8);
    expected.dispersion = 32'(rounded(difference < 0 ? -difference : difference, 2));
  endtask

  task automatic compare_word(input string field_name, input logic [255:0] actual, wanted);
    checks++;
    if ($isunknown({actual, wanted}) || actual !== wanted)
      $fatal(1, "Phase-step mismatch stage=%0d observation=%0d field=%s actual=%h expected=%h",
             stage, observations, field_name, actual, wanted);
  endtask

  task automatic hash_word(input logic [31:0] value);
    signature = (signature ^ {32'b0, value}) * 64'h00000100000001b3;
  endtask

  // Kinds: 0 falling, 1 rising, 2 asynchronous reset, 3 release, 4 input settle.
  task automatic process_event(input int kind);
    if (stage >= 5 || kind < 0 || kind > 4) $fatal(1, "Invalid phase-step event");
    if ((kind == 0 && !clk) || (kind == 1 && clk)
        || (kind == 2 && !rst_n) || (kind == 3 && rst_n))
      $fatal(1, "Phase-step event lacks the required edge");
    for (int i = 0; i < 8; i++)
      if (thermal_node_factor_q30[i*32 +: 32] > 32'd1073741824)
        $fatal(1, "Phase-step thermal factor outside [0, Q30 one]");
    if (kind == 2 || (kind == 1 && !rst_n)) begin
      for (int i = 0; i < 8; i++) begin
        model_phase[i*32 +: 32] = 32'(i) << 29;
        model_frequency[i*32 +: 32] = 32'd65536;
      end
      reset_updates++;
      if (kind == 2) begin if (clk) reset_high++; else reset_low++; end
    end else if (kind == 1 && load_valid) begin
      model_phase = phase_load; model_frequency = frequency_load_q16; loads++;
      if (tick_enable) load_over_tick++;
    end else if (kind == 1 && tick_enable) begin
      advance_model(); ticks++; scheduler_counts[int'(scheduler_state)]++;
    end else if (kind == 1) holds++;
    case (kind)
      0: clk = 0; 1: clk = 1; 2: rst_n = 0; 3: rst_n = 1;
      default: begin end
    endcase
    #1ps;
    predict_outputs();
    compare_word("phase", outputs.phase_bank, expected.phase_bank);
    compare_word("frequency", outputs.frequency_bank, expected.frequency_bank);
    compare_word("coupling", outputs.coupling, expected.coupling);
    compare_word("projection", outputs.projection, expected.projection);
    compare_word("target", 256'(outputs.target), 256'(expected.target));
    compare_word("pair", 256'(outputs.pair_order), 256'(expected.pair_order));
    compare_word("cluster", 256'(outputs.cluster_order), 256'(expected.cluster_order));
    compare_word("global", 256'(outputs.global_order), 256'(expected.global_order));
    compare_word("dispersion", 256'(outputs.dispersion), 256'(expected.dispersion));
    output_ones |= outputs; output_zeros |= ~outputs;
    hash_word(stage); hash_word(32'(kind));
    hash_word({25'b0, clk, rst_n, load_valid, tick_enable, scheduler_state});
    hash_word({8'b0, retained_state, switch_activity});
    for (int i = 0; i < 8; i++) begin
      hash_word(phase_load[i*32 +: 32]); hash_word(frequency_load_q16[i*32 +: 32]);
      hash_word(gamma_effective_word[i*32 +: 32]); hash_word(thermal_node_factor_q30[i*32 +: 32]);
    end
    for (int i = 0; i < 8; i++) begin
      hash_word(outputs.phase_bank[i*32 +: 32]); hash_word(outputs.frequency_bank[i*32 +: 32]);
      hash_word(outputs.coupling[i*32 +: 32]); hash_word(outputs.projection[i*32 +: 32]);
    end
    hash_word({16'b0, outputs.target}); hash_word(outputs.pair_order);
    hash_word(outputs.cluster_order); hash_word(outputs.global_order); hash_word(outputs.dispersion);
    observations++; event_counts[kind]++; stage_counts[stage]++;
  endtask

  // A single sampler avoids duplicating the wide oracle at every driver call.
  initial begin
    forever begin
      @sample_request;
      process_event(requested_kind);
      -> sample_complete;
    end
  end

  task automatic observe(input int kind);
    if (sample_busy) $fatal(1, "Overlapping phase-step observations");
    sample_busy = 1; requested_kind = kind;
    -> sample_request;
    @sample_complete;
    sample_busy = 0;
  endtask

  task automatic cycle(input bit load_request, tick_request);
    if (clk || !rst_n) $fatal(1, "Invalid phase-step cycle entry");
    load_valid = load_request; tick_enable = tick_request;
    observe(4); observe(1); observe(0);
  endtask

  task automatic fill_inputs(input int k);
    for (int i = 0; i < 8; i++) begin
      phase_load[i*32 +: 32] = next_word(); frequency_load_q16[i*32 +: 32] = next_word();
      gamma_effective_word[i*32 +: 32] = next_word();
      thermal_node_factor_q30[i*32 +: 32] = next_word() % 32'd1073741825;
      retained_state[i*2 +: 2] = (k+i)%3 == 0 ? 2'b00 : (k+i)%3 == 1 ? 2'b01 : 2'b11;
      switch_activity[i] = 1'((k+i)%2);
    end
    scheduler_state = frp_m31_pkg::frp_m31_scheduler_state_e'(k%5);
  endtask

  task automatic finish_stage;
    if (stage_counts[stage] != EXPECTED_COUNTS[stage] || signature !== EXPECTED_SIGNATURES[stage])
      $fatal(1, "Phase-step stage mismatch stage=%0d observations=%0d signature=%h",
             stage, stage_counts[stage], signature);
    $display("FRP_M31_PHASE_STEP_BOUNDARY_STAGE: PASS stage=%0d observations=%0d signature=%h",
             stage, stage_counts[stage], signature);
    stage++;
  endtask

  initial begin : qualification
    real sine_value;
    wide_t target_value, old_frequency, next_frequency, velocity, step, landing, delta_value;
    int state_value, activity;
    foreach (stage_counts[k]) stage_counts[k] = 0;
    foreach (event_counts[k]) event_counts[k] = 0;
    foreach (scheduler_counts[k]) scheduler_counts[k] = 0;
    foreach (state_activity_counts[s, a]) state_activity_counts[s][a] = 0;
    foreach (rounding_bins[r, b]) rounding_bins[r][b] = 0;
    residue_seen[0] = 0; residue_seen[1] = 0;
    if ($bits(outputs) != 1168) $fatal(1, "Phase-step output width mismatch");
    for (int k = 0; k < 4096; k++) begin
      sine_value = $sin(6.283185307179586476925286766559 * real'(k) / 4096.0) * 1073741824.0;
      sine_reference[k] = sine_value < 0 ? -$rtoi(-sine_value + 0.5) : $rtoi(sine_value + 0.5);
    end
    sine_reference[0] = 0; sine_reference[1024] = 1073741824;
    sine_reference[2048] = 0; sine_reference[3072] = -1073741824;
    #1ps;
    observe(2); observe(3);

    // Stage 0: reset at both clock levels and reset/load/tick/hold priority.
    for (int k = 0; k < 8; k++) begin
      fill_inputs(2*k); cycle(1, 0); fill_inputs(2*k+1); cycle(1, 1);
      cycle(0, 1); cycle(0, 0);
      load_valid = 1'(k); tick_enable = 1'(k >> 1); observe(4);
      if (k >= 4) observe(1);
      observe(2);
      if (k >= 4) observe(0);
      observe(1); observe(0); observe(3); cycle(0, 0);
    end
    finish_stage();

    // Stage 1: all input encodings and 24 signed-frequency boundary cases.
    // Reserved encodings are port diagnostics, not executable ternary states.
    for (int sc = 0; sc < 8; sc++) for (int s = 0; s < 4; s++)
      for (int a = 0; a < 2; a++) for (int b = 0; b < 3; b++) begin
        scheduler_state = frp_m31_pkg::frp_m31_scheduler_state_e'(sc);
        for (int i = 0; i < 8; i++) begin
          retained_state[i*2 +: 2] = 2'(s); switch_activity[i] = 1'(a);
          phase_load[i*32 +: 32] = PHASE_CASES[(i+b)%8];
          frequency_load_q16[i*32 +: 32] = 32'(frequency_case(8*b+i, target_for(s,a)));
          gamma_effective_word[i*32 +: 32] = 32'(i+1) * 32'h17ab0001;
          thermal_node_factor_q30[i*32 +: 32] = i%3 == 0 ? 0 : i%3 == 1 ? 32'h20000000 : 32'h40000000;
        end
        cycle(1, 1'(b%2)); cycle(0, 1);
        phase_load = ~phase_load; frequency_load_q16 = ~frequency_load_q16; cycle(0, 0);
      end
    finish_stage();

    // Stage 2: complete 16-bit filter-product residues for each delta sign.
    for (int sign_index = 0; sign_index < 2; sign_index++)
      for (int b = 0; b < 8192; b++) begin
        scheduler_state = frp_m31_pkg::frp_m31_scheduler_state_e'(b%5);
        for (int i = 0; i < 8; i++) begin
          state_value = (b+i)%3 == 0 ? 0 : (b+i)%3 == 1 ? 1 : 3; activity = (b+i)%2;
          retained_state[i*2 +: 2] = 2'(state_value); switch_activity[i] = 1'(activity);
          delta_value = 65536 + 8*b + i;
          frequency_load_q16[i*32 +: 32] = 32'(target_for(state_value, activity)
                                             + (sign_index != 0 ? delta_value : -delta_value));
          phase_load[i*32 +: 32] = 32'(8*b+i) * 32'h1f123bb5;
          gamma_effective_word[i*32 +: 32] = 0; thermal_node_factor_q30[i*32 +: 32] = 0;
        end
        cycle(1, 0); cycle(0, 1);
      end
    finish_stage();

    // Stage 3: four 512-tick trajectories with changing coupling and pauses.
    for (int profile = 0; profile < 4; profile++) begin
      fill_inputs(profile); cycle(1, 0);
      for (int k = 0; k < 512; k++) begin
        fill_inputs(k+profile); cycle(0, 1);
        if (k%4 == 0) begin fill_inputs(k+profile+7); cycle(0, 0); end
      end
    end
    finish_stage();

    // Stage 4: first tick lands immediately around selected LUT boundaries;
    // a second tick must consume the newly retained frequency and phase.
    for (int f = 0; f < 24; f++) for (int sc = 0; sc < 8; sc++)
      for (int delta = -1; delta <= 1; delta++) begin
        scheduler_state = frp_m31_pkg::frp_m31_scheduler_state_e'(sc);
        for (int i = 0; i < 8; i++) begin
          state_value = (i+f)%4; activity = i%2;
          retained_state[i*2 +: 2] = 2'(state_value); switch_activity[i] = 1'(activity);
          target_value = target_for(state_value, activity); old_frequency = frequency_case(f, target_value);
          next_frequency = saturate(old_frequency + saturate(rounded((target_value-old_frequency)*19661, 65536)));
          velocity = saturate(rounded(next_frequency*3932, 65536)) + push_for(sc);
          step = rounded(velocity * 128'sd44798133900177, 128'sd4294967296);
          landing = wide_t'((i*512+f*17+sc*31)%4096)*1048576 + wide_t'(delta);
          phase_load[i*32 +: 32] = 32'(landing-step);
          frequency_load_q16[i*32 +: 32] = old_frequency[31:0];
          gamma_effective_word[i*32 +: 32] = 0; thermal_node_factor_q30[i*32 +: 32] = 0;
        end
        cycle(1, 0); cycle(0, 1); cycle(0, 1);
      end
    finish_stage();

    foreach (event_counts[k])
      if (event_counts[k] != EXPECTED_EVENTS[k]) $fatal(1, "Phase-step event coverage mismatch");
    foreach (scheduler_counts[k])
      if (scheduler_counts[k] != EXPECTED_SCHEDULER[k]) $fatal(1, "Phase-step scheduler coverage mismatch");
    foreach (state_activity_counts[s, a])
      if (state_activity_counts[s][a] != EXPECTED_STATE_ACTIVITY[s][a])
        $fatal(1, "Phase-step state/activity coverage mismatch");
    foreach (rounding_bins[r, b])
      if (rounding_bins[r][b] != EXPECTED_ROUNDING[r][b]) $fatal(1, "Phase-step rounding coverage mismatch");
    if (residue_seen[0] !== {65536{1'b1}} || residue_seen[1] !== {65536{1'b1}})
      $fatal(1, "Phase-step filter residue coverage incomplete");
    if (stage != 5 || observations != 113078 || checks != 1017702
        || loads != 17174 || ticks != 19785 || holds != 721
        || reset_updates != 17 || load_over_tick != 73 || reset_low != 5
        || reset_high != 4 || wide_deltas != 512 || multi_turn_steps != 2269
        || positive_wraps != 3248 || negative_wraps != 1283 || coupled_cell_ticks != 17399)
      $fatal(1, "Phase-step boundary totals incomplete");
    if ((output_ones & output_zeros) !==
        {{1040{1'b1}}, 32'h3fffffff, 32'h3fffffff, 32'h3fffffff, 32'h1fffffff}
        || signature !== 64'h10edd9da06ef2aad)
      $fatal(1, "Phase-step bit coverage or signature mismatch");
    for (int row = 0; row < 3; row++)
      $display("FRP_M31_PHASE_STEP_BOUNDARY_ROUND: PASS operation=%0d exact=%0d positive_below=%0d positive_half=%0d positive_above=%0d negative_below=%0d negative_half=%0d negative_above=%0d",
               row, rounding_bins[row][0], rounding_bins[row][1], rounding_bins[row][2],
               rounding_bins[row][3], rounding_bins[row][4], rounding_bins[row][5], rounding_bins[row][6]);
    done = 1;
    $display("FRP_M31_PHASE_STEP_BOUNDARY_TB: PASS stages=%0d observations=%0d checks=%0d loads=%0d ticks=%0d holds=%0d reset_updates=%0d load_over_tick=%0d reset_low=%0d reset_high=%0d wide_deltas=%0d multi_turn_steps=%0d positive_wraps=%0d negative_wraps=%0d coupled_cell_ticks=%0d rising_edges=%0d falling_edges=%0d asynchronous_resets=%0d reset_releases=%0d input_settles=%0d residue_bins=%0d output_bits=%0d output_exercised=%0d signature=%h",
             stage, observations, checks, loads, ticks,
             holds, reset_updates, load_over_tick, reset_low, reset_high,
             wide_deltas, multi_turn_steps, positive_wraps, negative_wraps, coupled_cell_ticks,
             event_counts[1], event_counts[0], event_counts[2], event_counts[3], event_counts[4],
             131072, 1168, $countones(output_ones & output_zeros), signature);
    #1ps;
    $finish;
  end
endmodule : frp_m31_phase_step_boundary_tb
`endif

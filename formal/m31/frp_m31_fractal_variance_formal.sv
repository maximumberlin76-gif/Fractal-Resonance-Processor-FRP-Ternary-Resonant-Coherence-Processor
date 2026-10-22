// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Hierarchical variance contracts for CELLS=8/16/32/64 and every LEVEL.
// PROFILE 0: arbitrary independent coherence values in [0, 2**30].
//   Reference means and squared deviations use balanced reduction trees.
//   Products and accumulation follow the unsigned 64-bit Q60 contract.
// PROFILE 1: every uniform coherence level has zero variance.
// PROFILE 2: balanced populations of adjacent Q30 codes have zero stored
//   integer variance; their half-unit mean rounds upward. All bases are free.
// Domain encoding covers every admissible integer without assumptions.
// Group zero occupies the most significant word of domain_values.
//
// Qualification normalizes frontend aliases, replaces only the
// dut.coherence_value_q30 driver with domain_values, and proves every
// a_binding assertion. Hierarchy/statistics RTL remains byte-identical.
// The private upstream phasor abstraction follows the contract in #97.
// For PROFILE 0, a compositional multiplier reduction is permitted only
// after proving equality of both signed 64-bit operands for every paired
// DUT/reference product. Product widths and signedness must match exactly.
// Each proved pair then receives the same arbitrary 64-bit product value.
// All final assertions must pass jointly; unrelated products remain free.
// PROFILE 2 permits constant square reduction only after proving every
// actual multiplication operand is the expected -1 or 0; the squared
// constants are then 1 or 0. PROFILE 1 retains the actual multipliers.
// Reach targets cover local input domains; singleton levels repeat bins.

`ifndef FRP_M31_FRACTAL_VARIANCE_FORMAL_SV
`define FRP_M31_FRACTAL_VARIANCE_FORMAL_SV
`include "frp_m31_phase_interference.sv"

module frp_m31_fractal_variance_formal #(
  parameter int CELLS = 8,
  parameter int LEVEL = 1,
  parameter int PROFILE = 0
) (
  input logic clk, rst_n,
  input logic [CELLS*32-1:0] phase_load,
  input logic [CELLS*32-1:0] cosine_probe,
  input logic [(CELLS-1)*31-1:0] coherence_probe,
  output wire [(CELLS-1)*32-1:0] domain_values,
  output logic [7:0] reach
);
  localparam int DEPTH = $clog2(CELLS);
  localparam int GROUPS = CELLS-1;
  localparam int COUNT = CELLS >> LEVEL;
  localparam int OFFSET = CELLS - (CELLS >> (LEVEL-1));
  localparam int SHIFT = DEPTH-LEVEL;
  localparam logic [31:0] ONE = 32'h40000000;
  wire [GROUPS*32-1:0] group_coherence_q30;
  wire [DEPTH*32-1:0] level_mean_coherence_q30;
  wire [DEPTH*32-1:0] level_min_coherence_q30;
  wire [DEPTH*32-1:0] level_max_coherence_q30;
  wire [DEPTH*32-1:0] level_dispersion_q30;
  wire signed [31:0] pair_coherence_q30, cluster_coherence_q30;
  wire signed [31:0] global_coherence_q30, organization_dispersion_q30;
  for (genvar g = 0; g < GROUPS; g++) begin : endpoints
    if (PROFILE == 0) begin : arbitrary_values
      assign domain_values[32*(GROUPS-1-g) +: 32] = coherence_probe[31*g+30]
        ? ONE : {2'b00, coherence_probe[31*g +: 30]};
    end else if (PROFILE == 1) begin : uniform_values
      assign domain_values[32*(GROUPS-1-g) +: 32] = coherence_probe[30]
        ? ONE : {2'b00, coherence_probe[0 +: 30]};
    end else begin : adjacent_values
      wire [30:0] adjacent_code = {1'b0, coherence_probe[0 +: 30]} + 31'(g%2);
      assign domain_values[32*(GROUPS-1-g) +: 32] = {1'b0, adjacent_code};
    end
    always_comb begin
      a_binding: assert (dut.coherence_value_q30[g] ==
        domain_values[32*(GROUPS-1-g) +: 32]);
    end
  end

  frp_m31_phase_interference #(.CELLS(CELLS)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(1'b0), .load_valid(1'b1),
    .phase_load(phase_load), .frequency_load_q16(cosine_probe),
    .gamma_effective_word('0), .thermal_node_factor_q30('0),
    .retained_state('0), .switch_activity('0),
    .scheduler_state(frp_m31_pkg::FRP_SCHED_FREE),
    .phase_word_q(), .frequency_current_q16(), .coupling_field_q16(),
    .phase_projection_q30(), .phase_target(),
    .pair_coherence_q30(pair_coherence_q30),
    .cluster_coherence_q30(cluster_coherence_q30),
    .global_coherence_q30(global_coherence_q30),
    .organization_dispersion_q30(organization_dispersion_q30),
    .group_coherence_q30(group_coherence_q30),
    .level_mean_coherence_q30(level_mean_coherence_q30),
    .level_min_coherence_q30(level_min_coherence_q30),
    .level_max_coherence_q30(level_max_coherence_q30),
    .level_dispersion_q30(level_dispersion_q30)
  );

  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Unsupported hierarchy size");
    if (LEVEL < 1 || LEVEL > DEPTH || PROFILE < 0 || PROFILE > 2)
      $fatal(1, "Invalid hierarchy proof profile or level");
  end

  wire [31:0] value [0:COUNT-1];
  wire [63:0] sum_tree [1:2*COUNT-1];
  wire [63:0] total = sum_tree[1];
  wire [63:0] reference_mean = (total + 64'(COUNT/2)) >> SHIFT;
  wire [31:0] actual_mean = level_mean_coherence_q30[32*(LEVEL-1) +: 32];
  wire [63:0] actual_variance = dut.level_variance_q60[LEVEL-1];

  for (genvar g = 0; g < COUNT; g++) begin : reference_terms
    assign value[g] = domain_values[32*(GROUPS-1-OFFSET-g) +: 32];
    assign sum_tree[COUNT+g] = {32'd0, value[g]};
  end
  for (genvar node = 1; node < COUNT; node++) begin : reference_sum
    assign sum_tree[node] = sum_tree[2*node] + sum_tree[2*node+1];
  end

  if (PROFILE == 0) begin : full_domain
    wire [63:0] square_tree [1:2*COUNT-1];
    for (genvar g = 0; g < COUNT; g++) begin : term
      wire signed [63:0] difference = $signed({32'd0, value[g]}) - $signed(reference_mean);
      wire [63:0] square = $unsigned(difference * difference);
      assign square_tree[COUNT+g] = square;
    end
    for (genvar node = 1; node < COUNT; node++) begin : reduction
      assign square_tree[node] = square_tree[2*node] + square_tree[2*node+1];
    end
    wire [63:0] square_sum = square_tree[1];
    wire [63:0] reference_variance = square_sum >> SHIFT;
    always_comb begin
      a_mean: assert (64'(actual_mean) == reference_mean);
      a_variance: assert (actual_variance == reference_variance);
    end
  end else if (PROFILE == 1) begin : uniform
    always_comb begin
      a_mean: assert (actual_mean == value[0]);
      a_zero_variance: assert (actual_variance == 0);
    end
  end else begin : adjacent
    wire [31:0] base_value = {2'b00, coherence_probe[0 +: 30]};
    wire round_up = COUNT > 1;
    always_comb begin
      a_mean: assert (actual_mean == base_value + 32'(round_up));
      a_zero_variance: assert (actual_variance == 0);
    end
  end

  logic all_zero, all_one, all_midpoint, alternating;
  always_comb begin
    all_zero = 1;
    all_one = 1;
    all_midpoint = 1;
    alternating = 1;
    for (int g = 0; g < COUNT; g++) begin
      all_zero &= value[g] == 0;
      all_one &= value[g] == ONE;
      all_midpoint &= value[g] == (ONE >> 1);
      alternating &= value[g] == ((g%2 == 0) ? 0 : ONE);
    end
    reach = 0;
    if (PROFILE == 0) begin
      reach[0] = all_zero;
      reach[1] = all_one;
      reach[2] = all_midpoint;
      reach[3] = alternating;
      reach[4] = value[0] == 1;
      reach[5] = value[0] == ONE-1;
      reach[6] = COUNT == 1 ? value[0] == (ONE >> 1)-1
        : (total & 64'(COUNT-1)) == 64'(COUNT/2);
      reach[7] = COUNT == 1 ? value[0] == (ONE >> 1)+1
        : value[0] == 0 && value[COUNT-1] == ONE;
    end else if (PROFILE == 1) begin
      reach[0] = value[0] == 0;
      reach[1] = value[0] == ONE;
      reach[2] = value[0] == 1;
      reach[3] = value[0] == ONE-1;
      reach[4] = value[0] == (ONE >> 1);
      reach[5] = value[0] == (ONE >> 1)-1;
      reach[6] = value[0] == (ONE >> 1)+1;
      reach[7] = value[0] == 32'h15555555;
    end else begin
      reach[0] = coherence_probe[0 +: 30] == 0;
      reach[1] = coherence_probe[0 +: 30] == 1;
      reach[2] = coherence_probe[0 +: 30] == 2;
      reach[3] = coherence_probe[0 +: 30] == ONE-1;
      reach[4] = coherence_probe[0 +: 30] == ONE-2;
      reach[5] = coherence_probe[0 +: 30] == (ONE >> 1);
      reach[6] = coherence_probe[0 +: 30] == (ONE >> 1)-1;
      reach[7] = coherence_probe[0 +: 30] == 30'h15555555;
    end
  end
endmodule
`endif

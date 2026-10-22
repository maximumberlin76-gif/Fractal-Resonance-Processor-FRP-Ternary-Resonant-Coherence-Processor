// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// Compositional contracts for the existing dyadic hierarchy datapath.
// CELLS: 8/16/32/64. LEVEL: 1..$clog2(CELLS). PROFILE: 0..4.
// PROFILE 0: group membership, signed phasor sums and parent/child sums.
//   Cut dut.sine_q30 and dut.cosine_q30 to arbitrary signed 32-bit words.
// PROFILE 1: magnitude clipping and group coherence range.
//   Cut dut.coherence_magnitude_q30 to arbitrary unsigned 32-bit words.
// PROFILE 2: rounded level means and exact extrema over the full domain.
//   Replace dut.coherence_value_q30 with domain_values. Each probe word
//   maps onto [0, 2**30], covering every integer in that interval.
// PROFILE 3: unsigned variance for every assignment of endpoint values.
//   Replace dut.coherence_value_q30 with endpoint_values, generated from
//   arbitrary endpoint_high bits: each group is independently 0 or 2**30.
//   Compare against the closed-form two-point population variance.
// PROFILE 4: pair/cluster/global summaries, organization and root wiring.
//   Use domain_values and cut dut.level_deviation_q30 to arbitrary words.
// PROFILE 1 establishes the group-value domain used by profiles 2..4.
// Profiles 0, 2 and 3 are required at every level; profiles 1 and 4 once.
// Normalize frontend aliases before replacing drivers. Preserve shared
// DUT/reference consumers. No environmental assumptions are used.
// For PROFILE 3, prove count_valid first, then prove all high_count values
// from 0 through COUNT. Together these cases include every endpoint mask.
// The two encoded buses place group zero in their most significant word.
// Reach bits describe local domains; single-group levels have repeated bins.
// A private proof copy may replace the upstream g_phase_cell block by
// sine_q30[i]=phase_load[32*i+:32] and
// cosine_q30[i]=frequency_load_q16[32*i+:32] before elaboration.
// Preserve g_level, coherence_combinational and root connections verbatim.
// Integer-root radicand and output wiring are checked in PROFILE 4;
// the integer-root recurrence and trigonometric ROM have separate contracts.

`ifndef FRP_M31_FRACTAL_HIERARCHY_FORMAL_SV
`define FRP_M31_FRACTAL_HIERARCHY_FORMAL_SV
`include "frp_m31_phase_interference.sv"

module frp_m31_fractal_hierarchy_formal #(
  parameter int CELLS = 8,
  parameter int LEVEL = 1,
  parameter int PROFILE = 0
) (
  input logic clk, rst_n,
  input logic [CELLS*32-1:0] phase_load,
  input logic [CELLS*32-1:0] cosine_probe,
  input logic [CELLS-2:0] endpoint_high,
  input logic [(CELLS-1)*31-1:0] coherence_probe,
  output wire [(CELLS-1)*32-1:0] endpoint_values,
  output wire [(CELLS-1)*32-1:0] domain_values,
  output logic [7:0] reach
);
  localparam int DEPTH = $clog2(CELLS);
  localparam int GROUPS = CELLS-1;
  localparam int POPULATION = 1 << LEVEL;
  localparam int COUNT = CELLS >> LEVEL;
  localparam int OFFSET = CELLS - (CELLS >> (LEVEL-1));
  localparam int SHIFT = DEPTH-LEVEL;
  localparam logic [31:0] ONE = 32'h40000000;
  typedef logic signed [63:0] signed_wide_t;
  wire [GROUPS*32-1:0] group_coherence_q30;
  wire [DEPTH*32-1:0] level_mean_coherence_q30;
  wire [DEPTH*32-1:0] level_min_coherence_q30;
  wire [DEPTH*32-1:0] level_max_coherence_q30;
  wire [DEPTH*32-1:0] level_dispersion_q30;
  wire signed [31:0] pair_coherence_q30, cluster_coherence_q30;
  wire signed [31:0] global_coherence_q30, organization_dispersion_q30;
  for (genvar g = 0; g < GROUPS; g++) begin : endpoints
    assign endpoint_values[32*(GROUPS-1-g) +: 32] = endpoint_high[g] ? ONE : 32'd0;
    assign domain_values[32*(GROUPS-1-g) +: 32] = coherence_probe[31*g+30]
      ? ONE : {2'b00, coherence_probe[31*g +: 30]};
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
    if (LEVEL < 1 || LEVEL > DEPTH || PROFILE < 0 || PROFILE > 4)
      $fatal(1, "Invalid hierarchy proof profile or level");
  end

  if (PROFILE == 0) begin : membership
    for (genvar g = 0; g < COUNT; g++) begin : block_contract
      signed_wide_t expected_cos, expected_sin;
      always_comb begin
        expected_cos = 0;
        expected_sin = 0;
        for (int member = g*POPULATION; member < (g+1)*POPULATION; member++) begin
          expected_cos += signed_wide_t'(dut.cosine_q30[member]);
          expected_sin += signed_wide_t'(dut.sine_q30[member]);
        end
        a_cos_membership: assert (dut.g_level[LEVEL].g_group[g].sum_cos_q30 == expected_cos);
        a_sin_membership: assert (dut.g_level[LEVEL].g_group[g].sum_sin_q30 == expected_sin);
      end
      if (LEVEL > 1) begin : nested
        always_comb begin
          a_cos_children: assert (dut.g_level[LEVEL].g_group[g].sum_cos_q30 ==
            dut.g_level[LEVEL-1].g_group[2*g].sum_cos_q30 +
            dut.g_level[LEVEL-1].g_group[2*g+1].sum_cos_q30);
          a_sin_children: assert (dut.g_level[LEVEL].g_group[g].sum_sin_q30 ==
            dut.g_level[LEVEL-1].g_group[2*g].sum_sin_q30 +
            dut.g_level[LEVEL-1].g_group[2*g+1].sum_sin_q30);
        end
      end
    end
    always_comb begin
      reach[0] = dut.sine_q30[0] == 32'sh80000000;
      reach[1] = dut.sine_q30[0] == 32'sh7fffffff;
      reach[2] = dut.cosine_q30[0] == 32'sh80000000;
      reach[3] = dut.cosine_q30[0] == 32'sh7fffffff;
      reach[4] = membership.block_contract[0].expected_cos == 0;
      reach[5] = membership.block_contract[0].expected_sin < 0;
      reach[6] = membership.block_contract[0].expected_sin > 0;
      reach[7] = dut.sine_q30[0] == 32'sh80000000 && dut.sine_q30[1] == 32'sh7fffffff;
    end
  end

  if (PROFILE == 1) begin : magnitude_clip
    for (genvar g = 0; g < GROUPS; g++) begin : group_contract
      wire [31:0] raw = dut.coherence_magnitude_q30[g];
      wire [31:0] expected_value = raw <= ONE ? raw : ONE;
      always_comb begin
        a_clip: assert (group_coherence_q30[32*g +: 32] == expected_value);
        a_range: assert (group_coherence_q30[32*g +: 32] <= ONE);
      end
    end
    always_comb begin
      reach[0] = dut.coherence_magnitude_q30[0] == 0;
      reach[1] = dut.coherence_magnitude_q30[0] == ONE-1;
      reach[2] = dut.coherence_magnitude_q30[0] == ONE;
      reach[3] = dut.coherence_magnitude_q30[0] == ONE+1;
      reach[4] = dut.coherence_magnitude_q30[0] == 32'h7fffffff;
      reach[5] = dut.coherence_magnitude_q30[0] == 32'h80000000;
      reach[6] = dut.coherence_magnitude_q30[0] == 32'hffffffff;
      reach[7] = dut.coherence_magnitude_q30[GROUPS-1] == 32'hffffffff;
    end
  end

  if (PROFILE == 2 || PROFILE == 4) begin : group_domain
    for (genvar g = 0; g < GROUPS; g++) begin : value_domain
      always_comb begin
        a_group_binding: assert (dut.coherence_value_q30[g] == domain_values[32*(GROUPS-1-g) +: 32]);
        a_group_domain: assert ($unsigned(dut.coherence_value_q30[g]) <= ONE);
      end
    end
  end

  if (PROFILE == 2 || PROFILE == 3) begin : statistics
    logic [63:0] total, reference_mean;
    logic [31:0] reference_min, reference_max;
    logic [127:0] square_sum, reference_variance;
    logic [5:0] high_count, low_count;
    logic [11:0] mixed_pairs;
    wire count_valid = high_count <= 6'(COUNT);
    logic all_zero, all_one, alternating;
    always_comb begin
      total = 0;
      reference_min = ONE;
      reference_max = 0;
      all_zero = 1;
      all_one = 1;
      alternating = 1;
      high_count = 0;
      for (int g = 0; g < COUNT; g++) begin
        total += 64'($unsigned(dut.coherence_value_q30[OFFSET+g]));
        if ($unsigned(dut.coherence_value_q30[OFFSET+g]) < reference_min)
          reference_min = $unsigned(dut.coherence_value_q30[OFFSET+g]);
        if ($unsigned(dut.coherence_value_q30[OFFSET+g]) > reference_max)
          reference_max = $unsigned(dut.coherence_value_q30[OFFSET+g]);
        all_zero &= dut.coherence_value_q30[OFFSET+g] == 0;
        all_one &= dut.coherence_value_q30[OFFSET+g] == ONE;
        alternating &= dut.coherence_value_q30[OFFSET+g] == ((g%2 == 0) ? 0 : ONE);
        high_count += 6'(endpoint_high[OFFSET+g]);
      end
      reference_mean = (total + 64'(COUNT/2)) >> SHIFT;
      low_count = 6'(COUNT) - high_count;
      mixed_pairs = 12'(high_count) * 12'(low_count);
      reference_variance = 128'(mixed_pairs) << (60-2*SHIFT);
      square_sum = reference_variance << SHIFT;
      reach[0] = all_zero;
      reach[1] = all_one;
      reach[2] = alternating;
      reach[3] = dut.coherence_value_q30[OFFSET] == 1;
      reach[4] = dut.coherence_value_q30[OFFSET] == ONE-1;
      reach[5] = reference_mean == 32'h20000000;
      reach[6] = COUNT == 1 ? all_zero : reference_min < reference_max;
      reach[7] = COUNT == 1 ? all_one : (total & 64'(COUNT-1)) == 64'(COUNT/2);
      if (PROFILE == 3) begin
        reach[3] = high_count == 1;
        reach[4] = low_count == 1;
        reach[5] = high_count == 6'(COUNT/2);
        reach[7] = endpoint_high[OFFSET+COUNT-1];
      end
    end
    if (PROFILE == 2) begin : level_contract
      always_comb begin
        a_mean: assert (level_mean_coherence_q30[32*(LEVEL-1) +: 32] == reference_mean);
        a_minimum: assert (level_min_coherence_q30[32*(LEVEL-1) +: 32] == reference_min);
        a_maximum: assert (level_max_coherence_q30[32*(LEVEL-1) +: 32] == reference_max);
      end
    end else begin : variance_contract
      for (genvar g = 0; g < GROUPS; g++) begin : endpoint_binding
        always_comb a_endpoint: assert (dut.coherence_value_q30[g] == endpoint_values[32*(GROUPS-1-g) +: 32]);
      end
      always_comb begin
        a_population: assert (count_valid);
        a_variance: assert (128'(dut.level_variance_q60[LEVEL-1]) == reference_variance);
        a_unsigned_accumulator: assert (square_sum <= 128'h8000000000000000);
        if (COUNT > 1 && statistics.alternating) begin
          a_extreme_sum: assert (square_sum == (128'(COUNT) << 58));
          a_extreme_variance: assert (dut.level_variance_q60[LEVEL-1] == 64'h0400000000000000);
        end
      end
    end
  end

  if (PROFILE == 4) begin : public_wiring
    logic [31:0] left_cluster, right_cluster;
    logic [32:0] gap;
    always_comb begin
      left_cluster = $unsigned(dut.coherence_value_q30[CELLS/2]);
      right_cluster = $unsigned(dut.coherence_value_q30[CELLS/2+1]);
      gap = left_cluster >= right_cluster ? 33'(left_cluster)-33'(right_cluster)
                                         : 33'(right_cluster)-33'(left_cluster);
      a_pair: assert (pair_coherence_q30 == level_mean_coherence_q30[0 +: 32]);
      a_cluster: assert (cluster_coherence_q30 == level_mean_coherence_q30[32 +: 32]);
      a_global: assert (global_coherence_q30 == group_coherence_q30[32*(GROUPS-1) +: 32]);
      if (CELLS == 8) begin
        a_organization_gap: assert ($unsigned(organization_dispersion_q30) == ((gap >> 1) + 33'(gap[0])));
      end else begin
        a_organization_level: assert (organization_dispersion_q30 == level_dispersion_q30[32 +: 32]);
      end
      reach[0] = left_cluster == 0 && right_cluster == 0;
      reach[1] = left_cluster == ONE && right_cluster == ONE;
      reach[2] = left_cluster == 0 && right_cluster == ONE;
      reach[3] = left_cluster == ONE && right_cluster == 0;
      reach[4] = left_cluster == 0 && right_cluster == 1;
      reach[5] = left_cluster == 1 && right_cluster == 0;
      reach[6] = dut.coherence_value_q30[GROUPS-1] == 0;
      reach[7] = dut.coherence_value_q30[GROUPS-1] == ONE;
    end
    for (genvar level_id = 0; level_id < DEPTH; level_id++) begin : root_connections
      always_comb begin
        a_radicand: assert (dut.g_dispersion[level_id].deviation.radicand == dut.level_variance_q60[level_id]);
        a_deviation: assert (level_dispersion_q30[32*level_id +: 32] == dut.level_deviation_q30[level_id]);
      end
    end
  end
endmodule
`endif

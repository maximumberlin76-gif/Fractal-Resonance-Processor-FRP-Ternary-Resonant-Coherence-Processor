// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This harness is proprietary and is not licensed under Apache-2.0.
// Except as required by applicable law, using, reproducing, modifying, or
// distributing this file requires prior written permission from Maksym Marnov.
// Referenced dependencies retain their existing licenses.
//
// M32 feedback-ingress contracts for every cell in 8/16/32/64-cell cores.
// PROFILE 0 proves signed frequency selection and unsigned lag magnitude.
// PROFILE 1 proves full-bank gamma and thermal source selection.
// Reference arithmetic uses floor quotient/remainder and independent bounds.
// All input bit patterns, including reserved retained-state code 10, are free.
//
// Qualification blackboxes the nine child modules of frp_m32_core and binds
// exactly five child-output buses to the explicit probe inputs below, after
// frontend alias normalization. The core's arithmetic and source muxes remain
// unchanged. Each binding is asserted. Removed child instances and source
// hashes must be recorded; combinational models must have no assumptions.
// A shared signed product may be abstracted only after checking its exact
// DUT/reference bit identity, operand widths and signedness.
// PROFILE 0 is qualified for every SELECTED_CELL; PROFILE 1 once per CELLS.
// Reach targets describe the explicit local interface domain.

`ifndef FRP_M32_FEEDBACK_INGRESS_FORMAL_SV
`define FRP_M32_FEEDBACK_INGRESS_FORMAL_SV
`include "frp_m32_core.sv"

module frp_m32_feedback_ingress_formal #(
  parameter int CELLS = 8,
  parameter int SELECTED_CELL = 0,
  parameter int PROFILE = 0
) (
  input logic clk, rst_n, tick_enable, clear_counters,
  input logic phase_load_valid,
  input logic local_gamma_enable, local_thermal_enable,
  input logic [CELLS*32-1:0] frequency_probe,
  input logic [CELLS*2-1:0] state_probe,
  input logic [CELLS-1:0] switch_probe,
  input logic [CELLS*32-1:0] frequency_load_q16,
  input logic [CELLS*32-1:0] gamma_effective_word,
  input logic [CELLS*32-1:0] thermal_node_factor_q30,
  input logic [CELLS*32-1:0] gamma_candidate_probe,
  input logic [CELLS*32-1:0] thermal_candidate_probe,
  output wire [CELLS*32-1:0] local_frequency_lag_q16,
  output wire [CELLS*32-1:0] phase_gamma_effective_word,
  output wire [CELLS*32-1:0] phase_thermal_node_factor_q30,
  output logic [7:0] reach
);
  frp_m32_core #(.CELLS(CELLS)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters),
    .scheduler_mode(frp_m31_pkg::FRP_MODE_FREE),
    .phase_load_valid(phase_load_valid), .phase_load('0),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(1'b0), .external_request_valid('0),
    .external_request_cell_index('0), .external_request_target('0),
    .external_target_bank('0),
    .local_gamma_enable(local_gamma_enable),
    .gamma_update_valid(1'b0), .gamma_targets_q16('0),
    .local_thermal_enable(local_thermal_enable),
    .local_frequency_lag_q16(local_frequency_lag_q16),
    .phase_gamma_effective_word(phase_gamma_effective_word),
    .phase_thermal_node_factor_q30(phase_thermal_node_factor_q30)
  );

  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Unsupported feedback-ingress size");
    if (SELECTED_CELL < 0 || SELECTED_CELL >= CELLS || PROFILE < 0 || PROFILE > 1)
      $fatal(1, "Invalid feedback-ingress profile");
  end

  always_comb begin
    a_frequency_binding: assert (dut.frequency_current_q16 == frequency_probe);
    a_state_binding: assert (dut.state_out == state_probe);
    a_switch_binding: assert (dut.accepted_change_mask == switch_probe);
    a_gamma_binding: assert (dut.local_next_gamma_effective_word == gamma_candidate_probe);
    a_thermal_binding: assert (dut.local_next_thermal_node_factor_q30 == thermal_candidate_probe);
  end

  if (PROFILE == 0) begin : arithmetic
    localparam int K = SELECTED_CELL;
    wire signed [31:0] current_value = frequency_probe[32*K +: 32];
    wire signed [31:0] load_value = frequency_load_q16[32*K +: 32];
    wire [1:0] retained_code = state_probe[2*K +: 2];
    wire polarized = retained_code == 2'b01 || retained_code == 2'b11;
    wire signed [63:0] target_value = 64'sd65536
      + (polarized ? 64'sd3932 : 64'sd0)
      + (switch_probe[K] ? 64'sd7864 : 64'sd0);
    wire signed [63:0] difference = target_value - 64'(current_value);
    wire signed [63:0] product = difference * 64'sd19661;
    wire signed [63:0] floor_quotient = product >>> 16;
    wire [15:0] remainder_value = product[15:0];
    wire round_up = remainder_value > 16'h8000
      || (remainder_value == 16'h8000 && product >= 0);
    wire signed [63:0] rounded = floor_quotient + (round_up ? 64'sd1 : 64'sd0);
    wire signed [63:0] correction = rounded > 64'sd2147483647 ? 64'sd2147483647
      : rounded < -64'sd2147483648 ? -64'sd2147483648 : rounded;
    wire signed [63:0] updated = 64'(current_value) + correction;
    wire signed [63:0] clipped = updated > 64'sd2147483647 ? 64'sd2147483647
      : updated < -64'sd2147483648 ? -64'sd2147483648 : updated;
    wire signed [63:0] selected = phase_load_valid ? 64'(load_value) : clipped;
    wire signed [63:0] residual = target_value - selected;
    wire [63:0] magnitude = residual < 0 ? $unsigned(-residual) : $unsigned(residual);

    always_comb begin
      a_target: assert (64'(dut.g_local_frequency_lag[K].target_frequency_q16) == target_value);
      a_difference: assert (dut.g_local_frequency_lag[K].difference_q16 == difference);
      a_correction: assert (64'(dut.g_local_frequency_lag[K].correction_q16) == correction);
      a_selected: assert (64'(dut.g_local_frequency_lag[K].selected_frequency_q16) == selected);
      a_magnitude: assert (64'(local_frequency_lag_q16[32*K +: 32]) == magnitude);
      a_unsigned_bound: assert (magnitude <= 64'd2147560980);
      reach = 0;
      reach[0] = phase_load_valid && load_value == target_value;
      reach[1] = phase_load_valid && load_value == 32'sh80000000 && polarized && switch_probe[K];
      reach[2] = phase_load_valid && load_value == 32'sh7fffffff;
      reach[3] = !phase_load_valid && current_value == 32'sh80000000;
      reach[4] = !phase_load_valid && current_value == 32'sh7fffffff;
      reach[5] = !phase_load_valid && product > 0 && remainder_value == 16'h8000;
      reach[6] = !phase_load_valid && product < 0 && remainder_value == 16'h8000;
      reach[7] = retained_code == 2'b10 && switch_probe[K] && !phase_load_valid;
    end
  end else begin : source_selection
    always_comb begin
      a_gamma_mux: assert (phase_gamma_effective_word ==
        (local_gamma_enable ? gamma_candidate_probe : gamma_effective_word));
      a_thermal_mux: assert (phase_thermal_node_factor_q30 ==
        (local_thermal_enable ? thermal_candidate_probe : thermal_node_factor_q30));
      reach = 0;
      reach[0] = !local_gamma_enable && !local_thermal_enable
        && gamma_candidate_probe != gamma_effective_word
        && thermal_candidate_probe != thermal_node_factor_q30;
      reach[1] = local_gamma_enable && !local_thermal_enable
        && gamma_candidate_probe != gamma_effective_word;
      reach[2] = !local_gamma_enable && local_thermal_enable
        && thermal_candidate_probe != thermal_node_factor_q30;
      reach[3] = local_gamma_enable && local_thermal_enable
        && gamma_candidate_probe != gamma_effective_word
        && thermal_candidate_probe != thermal_node_factor_q30;
      reach[4] = local_gamma_enable && local_thermal_enable && !tick_enable;
      reach[5] = local_gamma_enable && local_thermal_enable && phase_load_valid;
      reach[6] = local_gamma_enable && local_thermal_enable && clear_counters;
      reach[7] = !local_gamma_enable && !local_thermal_enable && !rst_n;
    end
  end
endmodule
`endif

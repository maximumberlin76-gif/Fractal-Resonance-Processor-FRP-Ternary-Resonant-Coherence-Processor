// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M32 completed-snapshot boundary and extrema recorder.
// Reference: QuantizedReferenceShadowProcessor.tick in frp_prototype_v1_7_0.py.
// sample_valid accepts one coherent, completed logical-tick snapshot.
// Present the completed values before the sampling rising edge; the producer
// supplies source_tick and the scheduler metadata belonging to that snapshot.
// Use local_stability_margin_q16, local_coherence_capacity_q16 and
// local_pressure_q16 from the local-feedback contour for the reference margin.
// All Q16 fields are signed Q16.16. Values are recorded without recomputation.
// State encoding: 00 = active zero, 01 = 1, 11 = -1; 10 is reserved.
// State and pending banks are copied verbatim as diagnostic context.
// Reset or clear_epoch starts a recording epoch with previous margin Q16(0.60).
// Priority: asynchronous reset, synchronous clear_epoch, accepted sample, hold.
// clear_epoch discards a simultaneous sample. It belongs to recorder control;
// connect it to an explicit epoch restart independently of core counter clears.
// The first positive-to-nonpositive margin crossing is retained for the epoch.
// A first sample at zero or below crosses the positive initial margin.
// Extrema initialize on the first sample; equal values retain the earlier tick.
// Source tick is caller metadata and may wrap or jump without changing order.
// sample_count_q saturates; count_overflow_q marks an additional accepted sample.
// boundary_pulse_q lasts one clock; persistent results have explicit valid bits.

`ifndef FRP_M32_BOUNDARY_RECORDER_SV
`define FRP_M32_BOUNDARY_RECORDER_SV
`timescale 1ns / 1ps

module frp_m32_boundary_recorder #(
  parameter int CELLS = 8,
  parameter int COUNT_BITS = 64
) (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_epoch,
  input  logic sample_valid,
  input  logic [63:0] source_tick,
  input  logic [1:0] scheduler_mode,
  input  logic [2:0] scheduler_state,
  input  logic signed [31:0] coherence_capacity_q16,
  input  logic signed [31:0] pressure_q16,
  input  logic signed [31:0] stability_margin_q16,
  input  logic signed [31:0] mean_heat_q16,
  input  logic signed [31:0] switch_load_q16,
  input  logic [(CELLS*2)-1:0] retained_state,
  input  logic [(CELLS*2)-1:0] pending_route,

  output logic sample_seen_q,
  output logic [COUNT_BITS-1:0] sample_count_q,
  output logic count_overflow_q,
  output logic signed [31:0] previous_margin_q16,
  output logic signed [31:0] minimum_margin_q16,
  output logic [63:0] minimum_margin_tick_q,
  output logic signed [31:0] peak_switch_load_q16,
  output logic [63:0] peak_switch_load_tick_q,

  output logic boundary_valid_q,
  output logic boundary_pulse_q,
  output logic [63:0] boundary_tick_q,
  output logic [1:0] boundary_scheduler_mode_q,
  output logic [2:0] boundary_scheduler_state_q,
  output logic signed [31:0] boundary_previous_margin_q16,
  output logic signed [31:0] boundary_margin_q16,
  output logic signed [31:0] boundary_capacity_q16,
  output logic signed [31:0] boundary_pressure_q16,
  output logic signed [31:0] boundary_mean_heat_q16,
  output logic signed [31:0] boundary_switch_load_q16,
  output logic [(CELLS*2)-1:0] boundary_retained_state_q,
  output logic [(CELLS*2)-1:0] boundary_pending_route_q
);
  localparam logic signed [31:0] INITIAL_MARGIN_Q16 = 32'sd39322;
  localparam logic [COUNT_BITS-1:0] COUNT_MAX = {COUNT_BITS{1'b1}};

  initial begin
    if (CELLS < 1)
      $fatal(1, "FRP M32 boundary recorder requires CELLS >= 1");
    if (COUNT_BITS < 1 || COUNT_BITS > 64)
      $fatal(1, "FRP M32 boundary recorder requires COUNT_BITS in [1,64]");
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sample_seen_q <= 1'b0;
      sample_count_q <= '0;
      count_overflow_q <= 1'b0;
      previous_margin_q16 <= INITIAL_MARGIN_Q16;
      minimum_margin_q16 <= '0;
      minimum_margin_tick_q <= '0;
      peak_switch_load_q16 <= '0;
      peak_switch_load_tick_q <= '0;
      boundary_valid_q <= 1'b0;
      boundary_pulse_q <= 1'b0;
      boundary_tick_q <= '0;
      boundary_scheduler_mode_q <= '0;
      boundary_scheduler_state_q <= '0;
      boundary_previous_margin_q16 <= '0;
      boundary_margin_q16 <= '0;
      boundary_capacity_q16 <= '0;
      boundary_pressure_q16 <= '0;
      boundary_mean_heat_q16 <= '0;
      boundary_switch_load_q16 <= '0;
      boundary_retained_state_q <= '0;
      boundary_pending_route_q <= '0;
    end else if (clear_epoch) begin
      sample_seen_q <= 1'b0;
      sample_count_q <= '0;
      count_overflow_q <= 1'b0;
      previous_margin_q16 <= INITIAL_MARGIN_Q16;
      minimum_margin_q16 <= '0;
      minimum_margin_tick_q <= '0;
      peak_switch_load_q16 <= '0;
      peak_switch_load_tick_q <= '0;
      boundary_valid_q <= 1'b0;
      boundary_pulse_q <= 1'b0;
      boundary_tick_q <= '0;
      boundary_scheduler_mode_q <= '0;
      boundary_scheduler_state_q <= '0;
      boundary_previous_margin_q16 <= '0;
      boundary_margin_q16 <= '0;
      boundary_capacity_q16 <= '0;
      boundary_pressure_q16 <= '0;
      boundary_mean_heat_q16 <= '0;
      boundary_switch_load_q16 <= '0;
      boundary_retained_state_q <= '0;
      boundary_pending_route_q <= '0;
    end else begin
      boundary_pulse_q <= 1'b0;
      if (sample_valid) begin
        sample_seen_q <= 1'b1;
        previous_margin_q16 <= stability_margin_q16;

        if (sample_count_q == COUNT_MAX)
          count_overflow_q <= 1'b1;
        else
          sample_count_q <= sample_count_q + {{(COUNT_BITS-1){1'b0}}, 1'b1};

        if (!sample_seen_q || stability_margin_q16 < minimum_margin_q16) begin
          minimum_margin_q16 <= stability_margin_q16;
          minimum_margin_tick_q <= source_tick;
        end
        if (!sample_seen_q || switch_load_q16 > peak_switch_load_q16) begin
          peak_switch_load_q16 <= switch_load_q16;
          peak_switch_load_tick_q <= source_tick;
        end

        if (!boundary_valid_q && previous_margin_q16 > 32'sd0 &&
            stability_margin_q16 <= 32'sd0) begin
          boundary_valid_q <= 1'b1;
          boundary_pulse_q <= 1'b1;
          boundary_tick_q <= source_tick;
          boundary_scheduler_mode_q <= scheduler_mode;
          boundary_scheduler_state_q <= scheduler_state;
          boundary_previous_margin_q16 <= previous_margin_q16;
          boundary_margin_q16 <= stability_margin_q16;
          boundary_capacity_q16 <= coherence_capacity_q16;
          boundary_pressure_q16 <= pressure_q16;
          boundary_mean_heat_q16 <= mean_heat_q16;
          boundary_switch_load_q16 <= switch_load_q16;
          boundary_retained_state_q <= retained_state;
          boundary_pending_route_q <= pending_route;
        end
      end
    end
  end
endmodule

`endif

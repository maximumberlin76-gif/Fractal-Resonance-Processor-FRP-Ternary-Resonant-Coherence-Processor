// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Same-clock CSR readout of an atomically captured M32 recorder snapshot.
// Connect recorder inputs to the corresponding frp_m32_observed_core outputs.
// All inputs are synchronous to clk; rst_n asserts asynchronously and its
// release is synchronized by the enclosing integration boundary.
// A transaction completes on each rising edge with csr_valid && csr_ready.
// Holding valid across multiple ready edges performs multiple transactions.
// Capture stores the recorder values present immediately before that edge.
// Core ticks and recorder updates proceed independently of snapshot reads.
// Capture replaces the entire previous snapshot; release clears only this copy.
// Signed Q16 values preserve their raw two's-complement representation.
// State banks preserve two bits per cell, cell 0 in the least-significant bits.
// Counter and bank words are zero-extended; low words precede high words.
// Parameters: CELLS in [1,64], RECORDER_COUNT_BITS in [1,64].
//
// Byte address map; full 32-bit aligned transactions:
//   00 WO command: exactly 1 = capture, exactly 2 = release
//   04 RO flags: bit 0 snapshot valid, bit 1 sample seen, bit 2 count overflow,
//         bit 3 boundary valid, bit 4 boundary pulse, bit 5 alignment error
//   08 RO interface ID 46524201 (FR boundary readout, revision 1)
//   0C RO geometry: bits 15:0 CELLS, bits 31:16 RECORDER_COUNT_BITS
//   10/14 RO sample count, low/high 32 bits
//   18 RO previous margin Q16       1C RO minimum margin Q16
//   20/24 RO minimum-margin source tick, low/high 32 bits
//   28 RO peak switch load Q16
//   2C/30 RO peak-switch source tick, low/high 32 bits
//   34/38 RO boundary source tick, low/high 32 bits
//   3C RO boundary scheduler: bits 1:0 mode, bits 4:2 state
//   40 RO boundary previous margin Q16    44 RO boundary margin Q16
//   48 RO boundary capacity Q16           4C RO boundary pressure Q16
//   50 RO boundary mean heat Q16          54 RO boundary switch load Q16
//   58/5C/60/64 RO boundary retained bank, words 0/1/2/3
//   68/6C/70/74 RO boundary pending bank, words 0/1/2/3
// Flags 1..5 and all payload words belong to the same captured snapshot.
// Capture is accepted even when sample-seen or boundary-valid inputs are zero;
// the captured flags identify which recorder results are available.
// Before capture or after release, payload reads complete with csr_error=1.
// Flags, interface ID and geometry remain readable while rst_n is high.
// Unaligned/unmapped accesses, command reads, unsupported commands and writes
// to read-only words complete with an error and preserve the stored snapshot.
// csr_rdata is zero for writes, errors, idle cycles and reset.

`ifndef FRP_M32_BOUNDARY_SNAPSHOT_CSR_SV
`define FRP_M32_BOUNDARY_SNAPSHOT_CSR_SV
`timescale 1ns/1ps

module frp_m32_boundary_snapshot_csr #(
  parameter int CELLS = 8,
  parameter int RECORDER_COUNT_BITS = 64
) (
  input  logic clk,
  input  logic rst_n,
  input  logic csr_valid,
  input  logic csr_write,
  input  logic [7:0] csr_addr,
  input  logic [31:0] csr_wdata,
  output logic csr_ready,
  output logic csr_error,
  output logic [31:0] csr_rdata,

  input logic record_sample_seen_q,
  input logic [RECORDER_COUNT_BITS-1:0] record_sample_count_q,
  input logic record_count_overflow_q,
  input logic signed [31:0] record_previous_margin_q16,
  input logic signed [31:0] record_minimum_margin_q16,
  input logic [63:0] record_minimum_margin_tick_q,
  input logic signed [31:0] record_peak_switch_load_q16,
  input logic [63:0] record_peak_switch_load_tick_q,
  input logic boundary_valid_q,
  input logic boundary_pulse_q,
  input logic [63:0] boundary_tick_q,
  input logic [1:0] boundary_scheduler_mode_q,
  input logic [2:0] boundary_scheduler_state_q,
  input logic signed [31:0] boundary_previous_margin_q16,
  input logic signed [31:0] boundary_margin_q16,
  input logic signed [31:0] boundary_capacity_q16,
  input logic signed [31:0] boundary_pressure_q16,
  input logic signed [31:0] boundary_mean_heat_q16,
  input logic signed [31:0] boundary_switch_load_q16,
  input logic [CELLS*2-1:0] boundary_retained_state_q,
  input logic [CELLS*2-1:0] boundary_pending_route_q,
  input logic record_alignment_error_q
);
  localparam int PAYLOAD_WORDS = 26;
  localparam logic [31:0] INTERFACE_ID = 32'h46524201;
  localparam logic [31:0] GEOMETRY = {16'(RECORDER_COUNT_BITS),16'(CELLS)};

  logic snapshot_valid_q;
  logic [4:0] snapshot_flags_q;
  logic [PAYLOAD_WORDS*32-1:0] snapshot_words_q, capture_words;
  logic [63:0] padded_count;
  logic [127:0] padded_retained, padded_pending;
  logic capture_accept, release_accept;

`ifndef SYNTHESIS
  initial begin
    if (CELLS < 1 || CELLS > 64)
      $fatal(1,"Boundary snapshot CSR requires CELLS in [1,64]");
    if (RECORDER_COUNT_BITS < 1 || RECORDER_COUNT_BITS > 64)
      $fatal(1,"Boundary snapshot CSR requires RECORDER_COUNT_BITS in [1,64]");
  end
`endif

  always_comb begin
    padded_count = {{(64-RECORDER_COUNT_BITS){1'b0}},record_sample_count_q};
    padded_retained = {{(128-CELLS*2){1'b0}},boundary_retained_state_q};
    padded_pending = {{(128-CELLS*2){1'b0}},boundary_pending_route_q};
    capture_words = '0;
    capture_words[0*32+:32] = padded_count[31:0];
    capture_words[1*32+:32] = padded_count[63:32];
    capture_words[2*32+:32] = record_previous_margin_q16;
    capture_words[3*32+:32] = record_minimum_margin_q16;
    capture_words[4*32+:32] = record_minimum_margin_tick_q[31:0];
    capture_words[5*32+:32] = record_minimum_margin_tick_q[63:32];
    capture_words[6*32+:32] = record_peak_switch_load_q16;
    capture_words[7*32+:32] = record_peak_switch_load_tick_q[31:0];
    capture_words[8*32+:32] = record_peak_switch_load_tick_q[63:32];
    capture_words[9*32+:32] = boundary_tick_q[31:0];
    capture_words[10*32+:32] = boundary_tick_q[63:32];
    capture_words[11*32+:32] = {27'd0,boundary_scheduler_state_q,boundary_scheduler_mode_q};
    capture_words[12*32+:32] = boundary_previous_margin_q16;
    capture_words[13*32+:32] = boundary_margin_q16;
    capture_words[14*32+:32] = boundary_capacity_q16;
    capture_words[15*32+:32] = boundary_pressure_q16;
    capture_words[16*32+:32] = boundary_mean_heat_q16;
    capture_words[17*32+:32] = boundary_switch_load_q16;
    capture_words[18*32+:128] = padded_retained;
    capture_words[22*32+:128] = padded_pending;
  end

  always_comb begin
    csr_ready = rst_n;
    csr_error = 1'b0;
    csr_rdata = '0;
    if (rst_n && csr_valid) begin
      if (csr_addr[1:0] != 2'b00) begin
        csr_error = 1'b1;
      end else if (csr_write) begin
        if (csr_addr != 8'h00 || (csr_wdata != 32'd1 && csr_wdata != 32'd2))
          csr_error = 1'b1;
      end else begin
        case (csr_addr)
          8'h04: csr_rdata = {26'd0,snapshot_flags_q,snapshot_valid_q};
          8'h08: csr_rdata = INTERFACE_ID;
          8'h0C: csr_rdata = GEOMETRY;
          default: begin
            if (csr_addr >= 8'h10 && csr_addr <= 8'h74 && snapshot_valid_q)
              csr_rdata = snapshot_words_q[((int'(csr_addr)-16)/4)*32+:32];
            else
              csr_error = 1'b1;
          end
        endcase
      end
    end
    capture_accept = csr_valid && csr_ready && csr_write && !csr_error && csr_wdata==32'd1;
    release_accept = csr_valid && csr_ready && csr_write && !csr_error && csr_wdata==32'd2;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      snapshot_valid_q <= 1'b0;
      snapshot_flags_q <= '0;
      snapshot_words_q <= '0;
    end else if (capture_accept) begin
      snapshot_valid_q <= 1'b1;
      snapshot_flags_q <= {record_alignment_error_q,boundary_pulse_q,boundary_valid_q,
                           record_count_overflow_q,record_sample_seen_q};
      snapshot_words_q <= capture_words;
    end else if (release_accept) begin
      snapshot_valid_q <= 1'b0;
      snapshot_flags_q <= '0;
      snapshot_words_q <= '0;
    end
  end
endmodule
`endif

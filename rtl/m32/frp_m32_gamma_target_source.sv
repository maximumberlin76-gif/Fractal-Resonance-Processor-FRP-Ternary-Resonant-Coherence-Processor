// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Synthesizable gamma target source for the M31/M32 signed Q16.16 interface.
// Restores the 624 words and index from random.Random.getstate()[1].
// Load the checkpoint after Python initialization has consumed its random words.
// Each request generates CELLS targets in ascending lane order, consuming two
// MT19937 words per lane, as random.uniform(-1.0, 1.0) followed by quantize_q16.
// Integer arithmetic preserves the 53-bit random fraction and half-away ties.
// The caller requests a bank at each gamma-update event (Python: tick % 8 == 0).
// request_valid/request_ready and bank_valid/bank_ready use rising-edge handshakes.
// The complete output bank is published atomically and retained under stalls.
// load_begin has priority over all handshakes and aborts an outstanding request.
// It latches checkpoint_index (0..624), clears output validity and starts a new
// sequential 624-word load; load_word is accepted only while load_ready is high.
// An invalid index or an all-zero checkpoint sets load_error until the next
// load_begin or reset. A successful full load raises configured.
// Reset discards the checkpoint. MT memory is initialized by the load protocol.

`ifndef FRP_M32_GAMMA_TARGET_SOURCE_SV
`define FRP_M32_GAMMA_TARGET_SOURCE_SV
`timescale 1ns/1ps

module frp_m32_gamma_target_source #(
  parameter int CELLS = 8
) (
  input  logic clk,
  input  logic rst_n,
  input  logic load_begin,
  input  logic [9:0] checkpoint_index,
  input  logic load_valid,
  input  logic [31:0] load_word,
  output wire load_ready,
  output logic configured,
  output logic load_error,
  input  logic request_valid,
  output wire request_ready,
  output wire busy,
  output logic bank_valid,
  input  logic bank_ready,
  output logic [CELLS*32-1:0] gamma_targets_q16
);
  typedef enum logic [2:0] {UNCONFIGURED, LOADING, IDLE, TWIST, DRAW} state_t;
  state_t state_q;
  logic [31:0] mt [0:623];
  logic [9:0] load_count_q, index_q, twist_q;
  logic [31:0] load_or_q;
  logic [$clog2(CELLS)-1:0] lane_q;
  logic half_q;
  logic [26:0] fraction_high_q;
  logic [CELLS*32-1:0] pending_bank_q;
  logic [9:0] neighbor_index, offset_index;
  logic [31:0] twist_join, twist_value, tempered_word;
  logic [52:0] random_fraction;
  logic signed [53:0] centered_fraction;
  logic [53:0] magnitude, rounded_magnitude;
  logic signed [31:0] target_word;
  logic [CELLS*32-1:0] completed_bank;

  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Gamma target source requires 8, 16, 32 or 64 cells");
  end

  function automatic logic [31:0] temper(input logic [31:0] value);
    logic [31:0] x;
    begin
      x = value ^ (value >> 11);
      x = x ^ ((x << 7) & 32'h9d2c5680);
      x = x ^ ((x << 15) & 32'hefc60000);
      return x ^ (x >> 18);
    end
  endfunction

  assign load_ready = rst_n && !load_begin && state_q == LOADING;
  assign request_ready = rst_n && !load_begin && configured
    && state_q == IDLE && !bank_valid;
  assign busy = state_q == TWIST || state_q == DRAW;

  always_comb begin
    neighbor_index = (twist_q == 10'd623) ? 10'd0 : twist_q + 10'd1;
    offset_index = (twist_q < 10'd227) ? twist_q + 10'd397 : twist_q - 10'd227;
    twist_join = {mt[twist_q][31], mt[neighbor_index][30:0]};
    twist_value = mt[offset_index] ^ (twist_join >> 1)
      ^ (twist_join[0] ? 32'h9908b0df : 32'd0);
    // index 624 denotes a pending twist, never a memory read address.
    tempered_word = temper(mt[(index_q < 10'd624) ? index_q : 10'd0]);
    random_fraction = {fraction_high_q, tempered_word[31:6]};
    centered_fraction = $signed({1'b0, random_fraction}) - 54'sd4503599627370496;
    magnitude = centered_fraction[53] ? $unsigned(-centered_fraction)
      : $unsigned(centered_fraction);
    rounded_magnitude = (magnitude + 54'd34359738368) >> 36;
    target_word = centered_fraction[53] ? -$signed(rounded_magnitude[31:0])
      : $signed(rounded_magnitude[31:0]);
    completed_bank = pending_bank_q;
    completed_bank[lane_q*32 +: 32] = target_word;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q <= UNCONFIGURED;
      configured <= 1'b0;
      load_error <= 1'b0;
      load_count_q <= 10'd0;
      load_or_q <= 32'd0;
      index_q <= 10'd624;
      twist_q <= 10'd0;
      lane_q <= '0;
      half_q <= 1'b0;
      fraction_high_q <= '0;
      pending_bank_q <= '0;
      gamma_targets_q16 <= '0;
      bank_valid <= 1'b0;
    end else if (load_begin) begin
      configured <= 1'b0;
      load_error <= checkpoint_index > 10'd624;
      state_q <= (checkpoint_index <= 10'd624) ? LOADING : UNCONFIGURED;
      index_q <= checkpoint_index;
      load_count_q <= 10'd0;
      load_or_q <= 32'd0;
      twist_q <= 10'd0;
      lane_q <= '0;
      half_q <= 1'b0;
      fraction_high_q <= '0;
      pending_bank_q <= '0;
      gamma_targets_q16 <= '0;
      bank_valid <= 1'b0;
    end else begin
      if (bank_valid && bank_ready) bank_valid <= 1'b0;
      case (state_q)
        LOADING: if (load_valid) begin
          mt[load_count_q] <= load_word;
          load_or_q <= load_or_q | load_word;
          if (load_count_q == 10'd623) begin
            configured <= |(load_or_q | load_word);
            load_error <= !(|(load_or_q | load_word));
            state_q <= (|(load_or_q | load_word)) ? IDLE : UNCONFIGURED;
          end else load_count_q <= load_count_q + 10'd1;
        end
        IDLE: if (request_valid && request_ready) begin
          pending_bank_q <= '0;
          lane_q <= '0;
          half_q <= 1'b0;
          if (index_q == 10'd624) begin
            twist_q <= 10'd0;
            state_q <= TWIST;
          end else state_q <= DRAW;
        end
        TWIST: begin
          // Sequential in-place recurrence also covers the wraparound segment.
          mt[twist_q] <= twist_value;
          if (twist_q == 10'd623) begin
            index_q <= 10'd0;
            state_q <= DRAW;
          end else twist_q <= twist_q + 10'd1;
        end
        DRAW: begin
          index_q <= index_q + 10'd1;
          if (!half_q) begin
            fraction_high_q <= tempered_word[31:5];
            half_q <= 1'b1;
          end else begin
            pending_bank_q <= completed_bank;
            half_q <= 1'b0;
            if (lane_q == $clog2(CELLS)'(CELLS-1)) begin
              gamma_targets_q16 <= completed_bank;
              bank_valid <= 1'b1;
            end else lane_q <= lane_q + 1'b1;
          end
          if (half_q && lane_q == $clog2(CELLS)'(CELLS-1)) begin
            state_q <= IDLE;
          end else if (index_q == 10'd623) begin
            twist_q <= 10'd0;
            state_q <= TWIST;
          end
        end
        default: state_q <= UNCONFIGURED;
      endcase
    end
  end
endmodule
`endif

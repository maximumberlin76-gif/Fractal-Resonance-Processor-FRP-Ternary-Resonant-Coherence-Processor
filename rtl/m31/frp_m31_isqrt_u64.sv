// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This source is proprietary and is not licensed under Apache-2.0.
//
// Exact unsigned 64-bit integer square root, with its exact remainder.
// For every binary radicand n:
//   root = floor(sqrt(n))
//   n = root * root + remainder
//   0 <= remainder <= 2 * root
// These equations use mathematical integers, not truncated SV products.
// In particular, n = 64'hffffffffffffffff produces root = 32'hffffffff
// and remainder = 33'h1fffffffe.
//
// This is a combinational radix-4 digit recurrence: 32 spatial stages,
// no clocks, retained state, division, multiplication, or lookup tables.
// It adds no clock-cycle latency; propagation delay still requires timing
// analysis in the enclosing implementation. Inputs containing X/Z are
// outside the binary arithmetic contract.
//
// After k stages, the processed high 2*k input bits equal q*q + r,
// with 0 <= r <= 2*q and 0 <= q < 2**k. Appending digit d gives
// x = 4*r + d. The next root bit is one exactly when x >= 4*q + 1.
// Then q_next = 2*q + bit and r_next = x - bit*(4*q + 1).
// The invariant uniquely establishes the floor square root at k = 32.
// All trial arithmetic is unsigned and explicitly widened before use.
//
// This reusable datapath does not instantiate or modify the M31/M32 core.

`ifndef FRP_M31_ISQRT_U64_SV
`define FRP_M31_ISQRT_U64_SV

`timescale 1ns / 1ps

module frp_m31_isqrt_u64 (
  input  wire [63:0] radicand,
  output wire [31:0] root,
  output wire [32:0] remainder
);
  wire [31:0] root_stage [0:32];
  wire [32:0] remainder_stage [0:32];

  assign root_stage[0] = 32'd0;
  assign remainder_stage[0] = 33'd0;

  for (genvar stage = 0; stage < 32; stage = stage + 1) begin : g_digit
    wire [34:0] expanded_remainder;
    wire [34:0] trial;
    wire [34:0] next_remainder;
    wire take_bit;

    // Consume the radicand from its most significant two-bit digit.
    assign expanded_remainder = {
      remainder_stage[stage], radicand[63 - 2*stage -: 2]
    };
    assign trial = {1'b0, root_stage[stage], 2'b01};
    assign take_bit = (expanded_remainder >= trial);
    assign next_remainder = take_bit
      ? expanded_remainder - trial : expanded_remainder;

    // Before the last stage q < 2**31; after every stage r <= 2*q.
    // Thus these slices discard only zero high bits for every binary n.
    assign root_stage[stage+1] = {root_stage[stage][30:0], take_bit};
    assign remainder_stage[stage+1] = next_remainder[32:0];
  end

  assign root = root_stage[32];
  assign remainder = remainder_stage[32];
endmodule : frp_m31_isqrt_u64

`endif

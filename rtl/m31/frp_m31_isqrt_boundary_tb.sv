// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Included dependencies retain their existing licenses.
// Exact root and remainder checks with an independent binary-search oracle.
// Exhaustive 16-bit inputs, low/high root intervals, bit boundaries,
// deterministic full-width samples, and input-history independence.
// Final counts and signature are cross-checked with Python math.isqrt.
// Run from the repository root with --binary --timing --assert -Irtl/m31
// and --top-module frp_m31_isqrt_boundary_tb.

`timescale 1ns / 1ps
`include "frp_m31_isqrt_u64.sv"

module frp_m31_isqrt_boundary_tb;
  typedef logic [127:0] wide_t;

  localparam int unsigned EXPECTED [6] =
    '{65536, 262144, 262144, 576, 16384, 768};

  logic [63:0] radicand = 0;
  wire [31:0] root;
  wire [32:0] remainder;

  logic [31:0] root_ones = 0, root_zeros = 0;
  logic [32:0] remainder_ones = 0, remainder_zeros = 0;
  logic [63:0] random_state = 64'h8bd83127cca752ba;
  logic [63:0] signature = 64'hcbf29ce484222325;

  int unsigned counts [6] = '{default:0};
  int unsigned vectors = 0, exact_roots = 0, upper_remainders = 0;
  int unsigned wide_remainders = 0, replay_checks = 0;

  frp_m31_isqrt_u64 dut (.radicand, .root, .remainder);

  initial begin
    #700000;
    $fatal(1, "ISQRT watchdog vectors=%0d", vectors);
  end

  function automatic logic [63:0] next_random();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 7;
    random_state ^= random_state << 17;
    return random_state;
  endfunction

  function automatic logic [31:0] reference_root(input logic [63:0] n);
    wide_t lo, hi, mid;
    lo = 0;
    hi = wide_t'(1) << 32;
    while (hi - lo > 1) begin
      mid = (lo + hi) >> 1;
      if (mid * mid <= wide_t'(n)) lo = mid;
      else hi = mid;
    end
    return lo[31:0];
  endfunction

  task automatic check_value(
    input logic [63:0] n,
    input int unsigned family
  );
    logic [31:0] expected_root;
    wide_t q, r, expected_remainder;

    expected_root = reference_root(n);
    expected_remainder =
      wide_t'(n) - wide_t'(expected_root) * wide_t'(expected_root);

    radicand = n;
    #1;

    if ($isunknown({root, remainder}))
      $fatal(1, "ISQRT unknown output n=%h", n);

    if (root !== expected_root ||
        wide_t'(remainder) !== expected_remainder)
      $fatal(1,
        "ISQRT mismatch family=%0d n=%h root=%h expected=%h rem=%h expected=%h",
        family, n, root, expected_root, remainder, expected_remainder);

    q = wide_t'(root);
    r = wide_t'(remainder);

    if (q*q + r != wide_t'(n) || r > 2*q ||
        q*q > wide_t'(n) || (q+1)*(q+1) <= wide_t'(n))
      $fatal(1, "ISQRT arithmetic invariant n=%h root=%h rem=%h",
             n, root, remainder);

    if (r == 0) exact_roots++;
    if (r == 2*q) upper_remainders++;
    if (remainder[32]) wide_remainders++;

    root_ones |= root;
    root_zeros |= ~root;
    remainder_ones |= remainder;
    remainder_zeros |= ~remainder;

    signature = (signature ^ n) * 64'h100000001b3;
    signature = (signature ^ {32'd0, root}) * 64'h100000001b3;
    signature = (signature ^ {31'd0, remainder}) * 64'h100000001b3;

    vectors++;
    counts[family]++;
  endtask

  task automatic square_edges(
    input logic [31:0] q,
    input int unsigned family
  );
    wide_t square, last;
    square = wide_t'(q) * wide_t'(q);
    last = square + 2*wide_t'(q);

    check_value(q == 0 ? 64'd0 : 64'(square-1), family);
    check_value(64'(square), family);
    check_value(64'(square+1), family);
    check_value(64'(last), family);
  endtask

  initial begin : campaign
    logic [63:0] n;
    logic [64:0] saved;
    wide_t pivot;

    for (int unsigned i = 0; i < 65536; i++)
      check_value(64'(i), 0);

    for (int unsigned i = 0; i < 65536; i++)
      square_edges(32'(i), 1);

    for (int unsigned i = 0; i < 65536; i++)
      square_edges(32'hffff0000 | 32'(i), 2);

    for (int unsigned b = 0; b < 32; b++) begin
      pivot = wide_t'(1) << b;
      square_edges(32'(pivot-1), 3);
      square_edges(32'(pivot), 3);
      square_edges(32'(pivot+1), 3);
    end

    for (int unsigned b = 0; b < 64; b++) begin
      pivot = wide_t'(1) << b;
      check_value(64'(pivot-1), 3);
      check_value(64'(pivot), 3);
      check_value(64'(pivot+1), 3);
    end

    for (int unsigned i = 0; i < 16384; i++) begin
      n = next_random();
      check_value(n, 4);
    end

    for (int unsigned i = 0; i < 256; i++) begin
      n = next_random();
      check_value(n, 5);
      saved = {root, remainder};
      check_value(~n, 5);
      check_value(n, 5);

      if ({root, remainder} !== saved)
        $fatal(1, "ISQRT replay mismatch n=%h", n);

      replay_checks++;
    end

    for (int unsigned f = 0; f < 6; f++) begin
      if (counts[f] != EXPECTED[f])
        $fatal(1, "ISQRT missing family=%0d count=%0d", f, counts[f]);

      $display("FRP_ISQRT_FAMILY family=%0d vectors=%0d", f, counts[f]);
    end

    if (vectors != 607552 || replay_checks != 256 ||
        exact_roots != 131468 || upper_remainders != 262628 ||
        wide_remainders != 135325 || root_ones !== 32'hffffffff ||
        root_zeros !== 32'hffffffff ||
        remainder_ones !== 33'h1ffffffff ||
        remainder_zeros !== 33'h1ffffffff)
      $fatal(1, "ISQRT coverage incomplete");

    if (signature !== 64'h6f1266ced27f03b3)
      $fatal(1, "ISQRT signature mismatch actual=%h", signature);

    $display("FRP_ISQRT_COVERAGE exact=%0d upper=%0d wide=%0d replay=%0d",
             exact_roots, upper_remainders, wide_remainders, replay_checks);

    $display("FRP_ISQRT_PASS vectors=%0d signature=%016h",
             vectors, signature);

    $finish;
  end
endmodule

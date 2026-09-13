// SPDX-License-Identifier: Apache-2.0
// FRP M32 continuous CSR traffic after synthesis.
// Author: Alchimist
//
// The DUT is the generated frp_m32_csr_netlist module. A separate
// frp_m32_csr_top RTL instance receives the same nine-port CSR stimulus.
// Compare ready, error, and read data before and after every transfer or
// idle cycle, and throughout asynchronous reset and synchronized release.
// The independent register/scheduler scoreboard and stimulus are carried
// from frp_m32_csr_stream_tb.sv without changing their transaction sequence.
//
// Coverage: continuous transfers, rejected and inactive commands, both
// request lanes, all eight cells, atomic phase/frequency load, free mode,
// 7/1 and 1/7 scheduling, counter clear, active zero, and both separate-leg polarity
// routes. Three fixed xorshift32 seeds reproduce the mixed traffic.
// Both the scoreboard and the RTL/netlist comparisons must pass.
//
// Use the simulation netlist exported by the existing M32 CSR
// post-synthesis flow, with its matching Yosys simlib.v. The netlist module
// must be named frp_m32_csr_netlist; its sine ROM remains embedded.
// The separate RTL reference reads rtl/m31/frp_m31_sin_q30.mem.
//
// Build from the repository root after placing the exported netlist at
// /tmp/frp_m32_csr_netlist.v and its cell models at /tmp/yosys-simlib.v:
// env verilator -DSIMLIB_NOCONNECT --binary --sv --timing --assert \
//   -Wall -Wno-fatal -CFLAGS "-std=c++20 -O0" --output-split 20000 \
//   -MAKEFLAGS VK_PCH_I_FAST= -MAKEFLAGS VK_PCH_I_SLOW= -j 2 \
//   --top-module frp_m32_csr_stream_post_synthesis_tb \
//   --Mdir /tmp/frp-m32-csr-stream-post-tb \
//   -Irtl/m22 -Irtl/m31 -Irtl/m32 -Ifpga/m32 -Ifpga/m32_csr \
//   -v /tmp/yosys-simlib.v /tmp/frp_m32_csr_netlist.v \
//   fpga/m32_csr/frp_m32_csr_stream_post_synthesis_tb.sv
// /tmp/frp-m32-csr-stream-post-tb/Vfrp_m32_csr_stream_post_synthesis_tb

`ifndef FRP_M32_CSR_STREAM_POST_SYNTHESIS_TB_SV
`define FRP_M32_CSR_STREAM_POST_SYNTHESIS_TB_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_top.sv"

module frp_m32_csr_stream_post_synthesis_tb;
  logic clk = 0;
  logic rst_n_async = 0;
  logic csr_valid = 0, csr_write = 0;
  logic [7:0] csr_addr = 0;
  logic [31:0] csr_wdata = 0, csr_rdata;
  logic csr_ready, csr_error;
  logic reference_ready, reference_error;
  logic [31:0] reference_rdata;
  int unsigned bus_comparisons = 0;
  logic [31:0] sampled, rng;
  logic [31:0] phases[8], frequencies[8], gamma[8], thermal[8];
  int unsigned mode_control, mode_active, lane, selected_cell, auto_enable;
  int unsigned request_cell[2], request_target[2], request_valid[2];
  int unsigned tick_index, ticks, counts[5];
  int unsigned checks = 0, transfers = 0, errors = 0, idle_cycles = 0;
  int unsigned total_ticks = 0, resets = 0, routes = 0;
  int unsigned mode_ticks[3] = '{default:0};
  int unsigned run_length = 0, longest_run = 0;

  always #5 clk = ~clk;
  initial begin
    #2000000;
    $fatal(1, "CSR stream post-synthesis watchdog expired");
  end

  frp_m32_csr_netlist dut (
    .clk(clk), .rst_n_async(rst_n_async),
    .csr_valid(csr_valid), .csr_write(csr_write),
    .csr_addr(csr_addr), .csr_wdata(csr_wdata),
    .csr_ready(csr_ready), .csr_error(csr_error), .csr_rdata(csr_rdata)
  );

  frp_m32_csr_top reference_rtl (
    .clk(clk), .rst_n_async(rst_n_async),
    .csr_valid(csr_valid), .csr_write(csr_write),
    .csr_addr(csr_addr), .csr_wdata(csr_wdata),
    .csr_ready(reference_ready), .csr_error(reference_error),
    .csr_rdata(reference_rdata)
  );

  task automatic compare_bus(input string label);
    if ({csr_ready, csr_error, csr_rdata} !==
        {reference_ready, reference_error, reference_rdata})
      $fatal(1, "%s: netlist=%h RTL=%h transfer=%0d time=%0t",
             label, {csr_ready, csr_error, csr_rdata},
             {reference_ready, reference_error, reference_rdata},
             transfers, $time);
    bus_comparisons++;
  endtask

  task automatic equal_word(input logic [31:0] actual,
                            input logic [31:0] expected, input string label);
    if (actual !== expected)
      $fatal(1, "%s: got=%h expected=%h transfer=%0d time=%0t",
             label, actual, expected, transfers, $time);
    checks++;
  endtask

  // Counter slots: free, balance, commit, excite, neutralize.
  // Use the enabled-tick ordinal, including across counter clears.
  function automatic int unsigned scheduler_slot();
    case (mode_active)
      0: return 0;
      1: return ((tick_index % 8) == 7) ? 2 : 1;
      2: return ((tick_index % 8) == 0) ? 3 : 4;
      default: begin $fatal(1, "Invalid scoreboard mode"); return 0; end
    endcase
  endfunction

  task automatic check_modeled_read(input logic [7:0] address);
    logic [31:0] expected;
    bit known;
    known = 1;
    case (address)
      'h04: expected = mode_control;
      'h08: expected = lane;
      'h0C: expected = request_cell[lane];
      'h10: expected = request_target[lane];
      'h14: expected = request_valid[lane];
      'h18: expected = selected_cell;
      'h20: expected = mode_active;
      'h24: expected = scheduler_slot();
      'h28, 'h98, 'hD0: expected = ticks;
      'h4C: expected = 32'h000003FF;
      'h5C, 'h60, 'h64, 'h9C: expected = 0;
      'h68: expected = auto_enable;
      'h6C: expected = phases[selected_cell];
      'h70: expected = frequencies[selected_cell];
      'h74: expected = gamma[selected_cell];
      'h78: expected = thermal[selected_cell];
      'hA0: expected = counts[0];
      'hA4: expected = counts[1];
      'hA8: expected = counts[2];
      'hAC: expected = counts[3];
      'hB0: expected = counts[4];
      'hFC: expected = 32'h46523201;
      default: begin known = 0; expected = 0; end
    endcase
    if (known)
      equal_word(sampled, expected, $sformatf("CSR %02h", address));
  endtask

  task automatic cycle(input bit write_access, input logic [7:0] address,
                       input logic [31:0] data, input bit reject = 0,
                       input bit valid_access = 1);
    int unsigned slot;
    @(negedge clk);
    csr_valid = valid_access;
    csr_write = write_access;
    csr_addr = address;
    csr_wdata = data;
    #1;
    compare_bus("before transfer");
    equal_word({31'd0, csr_ready}, {31'd0, valid_access}, "ready");
    equal_word({31'd0, csr_error}, {31'd0, valid_access && reject}, "error");
    sampled = csr_rdata;
    if (!valid_access || write_access || reject)
      equal_word(sampled, 0, "unused read data");
    else
      check_modeled_read(address);
    slot = scheduler_slot();
    @(posedge clk);
    #1;
    compare_bus("after transfer");
    // The core samples the previous CSR mode storage on this same edge.
    mode_active = mode_control;
    if (valid_access) begin
      transfers++;
      run_length++;
      if (run_length > longest_run) longest_run = run_length;
    end else begin
      idle_cycles++;
      run_length = 0;
    end
    if (valid_access && reject) errors++;
    if (valid_access && write_access && !reject) begin
      case (address)
        'h00: case (data)
          1: begin
            tick_index++;
            ticks++;
            counts[slot]++;
            mode_ticks[(slot == 0) ? 0 : ((slot <= 2) ? 1 : 2)]++;
            total_ticks++;
            request_valid[0] = 0;
            request_valid[1] = 0;
          end
          2: begin
            ticks = 0;
            foreach (counts[i]) counts[i] = 0;
          end
          4: begin request_valid[0] = 0; request_valid[1] = 0; end
          8: begin end
          default: $fatal(1, "Invalid stimulus command");
        endcase
        'h04: mode_control = data;
        'h08: lane = data;
        'h0C: request_cell[lane] = data;
        'h10: request_target[lane] = data;
        'h14: request_valid[lane] = data;
        'h18: selected_cell = data;
        'h68: auto_enable = data;
        'h6C: phases[selected_cell] = data;
        'h70: frequencies[selected_cell] = data;
        'h74: gamma[selected_cell] = data;
        'h78: thermal[selected_cell] = data;
        default: $fatal(1, "Unexpected successful stimulus write");
      endcase
    end
  endtask

  task automatic wr(input logic [7:0] address, input logic [31:0] data);
    cycle(1, address, data);
  endtask

  task automatic rd(input logic [7:0] address);
    cycle(0, address, 0);
  endtask

  task automatic expect_read(input logic [7:0] address,
                             input logic [31:0] expected);
    rd(address);
    equal_word(sampled, expected, $sformatf("Explicit CSR %02h", address));
  endtask

  task automatic blocked_bus();
    compare_bus("reset blocked");
    equal_word({30'd0, csr_ready, csr_error}, 0, "reset bus response");
    equal_word(csr_rdata, 0, "reset read data");
  endtask

  task automatic reset_with_held_tick();
    @(negedge clk);
    #2; // Assert between clock edges, including after nonzero state.
    rst_n_async = 0;
    csr_valid = 1; csr_write = 1; csr_addr = 0; csr_wdata = 1;
    mode_control = 0; mode_active = 0; lane = 0; selected_cell = 0;
    auto_enable = 0; tick_index = 0; ticks = 0; run_length = 0;
    foreach (counts[i]) counts[i] = 0;
    foreach (request_cell[i]) begin
      request_cell[i] = 0; request_target[i] = 0; request_valid[i] = 0;
    end
    foreach (phases[i]) begin
      phases[i] = 0; frequencies[i] = 0; gamma[i] = 0;
      thermal[i] = 32'h40000000;
    end
    #1; blocked_bus();
    repeat (2) begin @(posedge clk); #1; blocked_bus(); end
    @(negedge clk); rst_n_async = 1;
    #1; blocked_bus();
    @(posedge clk); #1; blocked_bus();
    @(negedge clk); #1; blocked_bus();
    @(posedge clk); #1;
    compare_bus("second release edge");
    equal_word({30'd0, csr_ready, csr_error}, 2, "second release edge");
    equal_word(csr_rdata, 0, "held write response");
    // The continuously held command executes on the next rising edge only.
    wr(0, 1);
    expect_read('h28, 1);
    expect_read('h98, 1);
    resets++;
  endtask

  task automatic audit();
    for (int a = 4; a < 256; a += 4) rd(8'(a));
    for (int l = 0; l < 2; l++) begin
      wr('h08, 32'(l));
      rd('h0C); rd('h10); rd('h14);
    end
    for (int c = 0; c < 8; c++) begin
      wr('h18, 32'(c));
      rd('h6C); rd('h70); rd('h74); rd('h78);
      rd('h34);
      if (!(sampled inside {32'd0, 32'd1, 32'd3}))
        $fatal(1, "Retained state outside -1/0/1");
      rd('h38);
      if (!(sampled inside {32'd0, 32'd1, 32'd3}))
        $fatal(1, "Pending route outside -1/0/1");
      checks += 2;
    end
  endtask

  task automatic stage(input int l, input int c, input logic [31:0] target);
    wr('h08, 32'(l)); wr('h0C, 32'(c));
    wr('h10, target); wr('h14, 1);
  endtask

  task automatic wait_commit_slot();
    repeat (8) begin
      if (scheduler_slot() inside {0, 2, 3}) return;
      wr(0, 1);
    end
    $fatal(1, "No commit-capable slot within one period");
  endtask

  task automatic route_case(input int mode_number, input int c);
    reset_with_held_tick();
    wr('h04, 32'(mode_number)); rd('h20);
    wr('h18, 32'(c));
    wait_commit_slot();
    stage(0, c, 1); wr(0, 1); expect_read('h34, 1);
    for (int direction = 0; direction < 2; direction++) begin
      stage(0, c, (direction == 0) ? 3 : 1);
      wr(0, 1);
      expect_read('h34, 0);
      expect_read('h38, (direction == 0) ? 3 : 1);
      // Counter clear, rejected commands, and idle clocks preserve the
      // active zero and pending polarity without consuming a route leg.
      wr(0, 2);
      repeat (5) begin
        cycle(1, 0, 3, 1);
        cycle(1, 0, 1, 0, 0);
        expect_read('h34, 0);
        expect_read('h38, (direction == 0) ? 3 : 1);
      end
      wait_commit_slot();
      expect_read('h34, 0);
      wr(0, 1);
      expect_read('h34, (direction == 0) ? 3 : 1);
      expect_read('h38, 0);
      rd('h28); rd('h4C); rd('h5C); rd('h60); rd('h64);
      routes++;
    end
  endtask

  function automatic logic [31:0] next_random();
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
  endfunction

  task automatic mixed_stream(input logic [31:0] seed);
    logic [31:0] value;
    reset_with_held_tick();
    rng = seed;
    for (int n = 0; n < 1024; n++) begin
      value = next_random();
      case (value[4:0])
        0, 1, 2, 3, 4, 5: wr(0, 1);
        6: wr(0, 2);
        7: wr(0, 4);
        8: wr(0, 8);
        9: wr('h04, (value >> 8) % 3);
        10: wr('h08, {31'd0, value[8]});
        11: wr('h0C, {29'd0, value[10:8]});
        12: wr('h10, value[8] ? 0 : (value[9] ? 1 : 3));
        13: wr('h14, {31'd0, value[8]});
        14: wr('h18, {29'd0, value[10:8]});
        15: wr('h68, {31'd0, value[8]});
        16: wr('h6C, value);
        17: wr('h70, {16'h0000, value[15:0]});
        18: wr('h74, value);
        19: wr('h78, value & 32'h3FFFFFFF);
        20: cycle(1, 0, 3, 1);
        21: cycle(1, 'h04, 3, 1);
        22: cycle(1, 'h10, 2, 1);
        23: cycle(1, 'hFC, value, 1);
        24: cycle(0, 0, 0, 1);
        25: cycle(1, {value[15:10], 2'b01}, value, 1);
        26: cycle(0, {value[15:10], 2'b10}, 0, 1);
        27: cycle(1, 0, 1, 0, 0);
        default: rd(8'(4 + 4 * ((value >> 8) % 63)));
      endcase
      if ((n % 64) == 63) audit();
    end
    audit();
    $display("CSR_STREAM_POST_SYNTHESIS seed=%08h PASS", seed);
  endtask

  initial begin : run
    logic [31:0] snapshot[64];
    reset_with_held_tick();
    // An uninterrupted 257-command burst crosses repeated scheduler periods.
    for (int m = 0; m < 3; m++) begin
      wr('h04, 32'(m));
      // Deliberately tick immediately: this first tick uses the old mode.
      repeat (257) wr(0, 1);
      audit();
    end
    // All readable words must survive a continuous run of rejected writes,
    // rejected reads, and unasserted valid cycles with tick-looking inputs.
    for (int a = 4; a < 256; a += 4) begin
      rd(8'(a)); snapshot[a/4] = sampled;
    end
    for (int a = 0; a < 256; a++) if ((a % 4) != 0) begin
      cycle(1, 8'(a), 1, 1);
      cycle(0, 8'(a), 0, 1);
    end
    repeat (17) cycle(1, 0, 1, 0, 0);
    for (int a = 4; a < 256; a += 4)
      expect_read(8'(a), snapshot[a/4]);
    // Consecutive selectors/staging writes followed immediately by atomic load.
    for (int c = 0; c < 8; c++) begin
      wr('h18, 32'(c));
      wr('h6C, 32'hFEDCBA98 ^ (32'(c) * 32'h12345678));
      wr('h70, ((c % 2) != 0) ? 32'hFFFF0000 : 32'h00010000);
    end
    wr(0, 8);
    for (int c = 0; c < 8; c++) begin
      wr('h18, 32'(c));
      expect_read('h7C, phases[c]); expect_read('h80, frequencies[c]);
    end
    // Both lanes must be consumed even when automatic requests are selected.
    stage(0, 0, 1); stage(1, 7, 3); wr('h68, 1); wr(0, 1);
    wr('h08, 0); expect_read('h14, 0);
    wr('h08, 1); expect_read('h14, 0);
    for (int m = 1; m <= 2; m++)
      for (int c = 0; c < 8; c++) route_case(m, c);
    mixed_stream(32'h13579BDF);
    mixed_stream(32'h2468ACE1);
    mixed_stream(32'hC001D00D);
    if (routes != 32 || errors < 500 || longest_run < 257 || resets != 20
        || idle_cycles < 100 || mode_ticks[0] < 257
        || mode_ticks[1] < 257 || mode_ticks[2] < 257)
      $fatal(1, "Required CSR stream coverage was not reached");
    if (checks != 37085 || transfers != 12703 || total_ticks != 1742
        || errors != 1212 || routes != 32 || resets != 20
        || longest_run != 1605)
      $fatal(1, "Post-synthesis traffic differs from the qualified RTL stream");
    // Two comparisons per cycle; six blocked-reset observations and one
    // second-release observation per reset. No accepted transfer is skipped.
    if (bus_comparisons != 2 * (transfers + idle_cycles) + 7 * resets)
      $fatal(1, "Incomplete RTL/netlist bus comparison coverage");
    $display("FRP_M32_CSR_STREAM_POST_SYNTHESIS_TB: PASS checks=%0d transfers=%0d ticks=%0d errors=%0d routes=%0d resets=%0d longest_run=%0d bus_comparisons=%0d idle_cycles=%0d",
             checks, transfers, total_ticks, errors, routes, resets,
             longest_run, bus_comparisons, idle_cycles);
    $finish;
  end
endmodule : frp_m32_csr_stream_post_synthesis_tb
`endif

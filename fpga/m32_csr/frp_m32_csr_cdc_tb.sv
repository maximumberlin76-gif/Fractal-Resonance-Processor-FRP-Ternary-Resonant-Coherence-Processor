// SPDX-License-Identifier: Apache-2.0
// FRP M32 dual-clock CSR integration and recovery testbench.
// Author: Alchimist
//
// Run from the repository root with --binary --timing --assert and
// --top-module frp_m32_csr_cdc_tb. Include directories: rtl/m22, rtl/m23,
// rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Clock profiles (half-periods and initial core offset in nanoseconds):
//   +HOST_HALF=5  +CORE_HALF=7  +PHASE=1 (default)
//   +HOST_HALF=3  +CORE_HALF=11 +PHASE=4
//   +HOST_HALF=13 +CORE_HALF=2  +PHASE=3
//
// Host requests use the M23 one-pulse, single-outstanding convention.
// An independent CSR/scheduler model checks host-visible results.
// A core-side monitor checks each delivered payload against the host
// request and captures the response on the core acceptance edge.
// Global counts distinguish completed transfers from reset-aborted work.
// Directed cases cover stopped clocks, rejected/held host pulses, both
// reset-abort stages, and -1/0/1 routes through active zero in 7/1 and 1/7.

`ifndef FRP_M32_CSR_CDC_TB_SV
`define FRP_M32_CSR_CDC_TB_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_cdc_top.sv"

module frp_m32_csr_cdc_tb;
  logic host_clk = 0;
  logic rst_n_async = 0;
  logic csr_valid = 0, csr_write = 0;
  logic [7:0] csr_addr = 0;
  logic [31:0] csr_wdata = 0, csr_rdata;
  logic csr_ready, csr_error;
  logic [31:0] sampled, rng;
  logic [31:0] phases[8], frequencies[8], gamma[8], thermal[8];
  int unsigned mode_control, mode_active, lane, selected_cell, auto_enable;
  int unsigned request_cell[2], request_target[2], request_valid[2];
  int unsigned tick_index, ticks, counts[5];
  int unsigned checks = 0, errors = 0, idle_sequences = 0;
  int unsigned total_ticks = 0, resets = 0, routes = 0;
  int unsigned mode_ticks[3] = '{default:0};
  logic core_clk = 0, host_run = 1, core_run = 1;
  int host_half = 5, core_half = 7, phase_offset = 1;
  logic host_reset_released, core_reset_released, interface_ready;
  logic interface_busy, protocol_error, invalid_before_ready;
  logic invalid_while_busy, invalid_valid_held;
  logic [40:0] expected_payload;
  logic [32:0] response_payload;
  bit expected_valid = 0, response_seen = 0;
  int launches = 0, completions = 0, core_completions = 0, aborts = 0;
  int aborts_after_core = 0, host_responses = 0;
  initial begin
    void'($value$plusargs("HOST_HALF=%d", host_half));
    if (host_half < 2) $fatal(1, "HOST_HALF must be at least 2 ns");
    forever begin #(host_half); if (host_run) host_clk = ~host_clk; end
  end
  initial begin
    void'($value$plusargs("CORE_HALF=%d", core_half));
    void'($value$plusargs("PHASE=%d", phase_offset));
    if (core_half < 2 || phase_offset < 0)
      $fatal(1, "CORE_HALF must be at least 2 ns and PHASE nonnegative");
    #(phase_offset);
    forever begin #(core_half); if (core_run) core_clk = ~core_clk; end
  end
  always @(posedge host_clk) begin
    if (rst_n_async && csr_ready) host_responses++;
  end

  always @(posedge core_clk) begin
    if (rst_n_async && dut.core_csr_valid && dut.core_csr_ready) begin
      if (!expected_valid || response_seen)
        $fatal(1, "Unrequested or repeated core transfer");
      if ({dut.core_csr_write, dut.core_csr_addr, dut.core_csr_wdata}
          !== expected_payload)
        $fatal(1, "CDC changed the accepted request payload");
      response_payload = {dut.core_csr_error, dut.core_csr_rdata};
      response_seen = 1;
      core_completions++;
    end
  end

  initial begin
    #20000000;
    $fatal(1, "CSR CDC watchdog expired");
  end

  frp_m32_csr_cdc_top dut (
    .host_clk(host_clk), .core_clk(core_clk), .rst_n_async(rst_n_async),
    .csr_valid(csr_valid), .csr_write(csr_write),
    .csr_addr(csr_addr), .csr_wdata(csr_wdata),
    .csr_ready(csr_ready), .csr_error(csr_error), .csr_rdata(csr_rdata),
    .host_reset_released(host_reset_released),
    .core_reset_released(core_reset_released), .interface_ready(interface_ready),
    .interface_busy(interface_busy), .protocol_error(protocol_error),
    .invalid_before_ready(invalid_before_ready),
    .invalid_while_busy(invalid_while_busy), .invalid_valid_held(invalid_valid_held)
  );

  task automatic equal_word(input logic [31:0] actual,
                            input logic [31:0] expected, input string label);
    if (actual !== expected)
      $fatal(1, "%s: got=%h expected=%h launch=%0d time=%0t",
             label, actual, expected, launches, $time);
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

  task automatic check_protocol(input logic [2:0] expected);
    equal_word({29'd0, invalid_before_ready, invalid_while_busy,
                invalid_valid_held}, {29'd0, expected}, "protocol flags");
    equal_word({31'd0, protocol_error}, {31'd0, |expected}, "protocol status");
  endtask

  task automatic record_tick();
    int unsigned slot;
    slot = scheduler_slot();
    tick_index++;
    ticks++;
    counts[slot]++;
    mode_ticks[(slot == 0) ? 0 : ((slot <= 2) ? 1 : 2)]++;
    total_ticks++;
    request_valid[0] = 0;
    request_valid[1] = 0;
  endtask

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
    if (!valid_access) begin
      @(negedge host_clk);
      csr_valid = 0; csr_write = write_access;
      csr_addr = address; csr_wdata = data;
      repeat (3) begin
        @(posedge host_clk); #1;
        equal_word({30'd0, csr_ready, interface_busy}, 0, "idle CDC");
      end
    end else begin
      launch(write_access, address, data);
      @(negedge host_clk);
      csr_valid = 0;
      csr_write = !write_access;
      csr_addr = ~address;
      csr_wdata = ~data;
      finish_response(reject);
      if (write_access || reject)
        equal_word(sampled, 0, "unused response data");
      else
        check_modeled_read(address);
    end
    if (!valid_access) idle_sequences++;
    if (valid_access && reject) errors++;
    if (valid_access && write_access && !reject) begin
      case (address)
        'h00: case (data)
          1: record_tick();
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
    // The CDC round trip separates successive target transfers by core clocks.
    mode_active = mode_control;
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
    equal_word({30'd0, csr_ready, csr_error}, 0, "reset bus response");
    equal_word(csr_rdata, 0, "reset read data");
  endtask

  task automatic launch(input bit write_access,
                        input logic [7:0] address, input logic [31:0] data);
    @(negedge host_clk);
    if (!interface_ready || interface_busy || expected_valid)
      $fatal(1, "Test driver attempted an unavailable request");
    expected_payload = {write_access, address, data};
    expected_valid = 1;
    response_seen = 0;
    csr_valid = 1; csr_write = write_access;
    csr_addr = address; csr_wdata = data;
    launches++;
    @(posedge host_clk); #1;
    equal_word({30'd0, interface_busy, csr_ready}, 2, "accepted host pulse");
  endtask

  task automatic finish_response(input bit reject = 0);
    int watchdog;
    watchdog = 0;
    while (!csr_ready) begin
      @(posedge host_clk); #1;
      watchdog++;
      if (watchdog > 1000) $fatal(1, "CDC response timeout");
    end
    if (!expected_valid || !response_seen)
      $fatal(1, "Host response without a corresponding core completion");
    equal_word({31'd0, csr_error}, {31'd0, reject}, "response error");
    equal_word({31'd0, interface_busy}, 0, "completion clears busy");
    if ({csr_error, csr_rdata} !== response_payload)
      $fatal(1, "CDC changed the response payload");
    sampled = csr_rdata;
    expected_valid = 0;
    completions++;
    @(posedge host_clk); #1;
    equal_word({31'd0, csr_ready}, 0, "completion pulse width");
  endtask

  task automatic reset_and_tick();
    @(negedge host_clk); #1;
    if (expected_valid) begin
      aborts++;
      if (response_seen) aborts_after_core++;
    end
    rst_n_async = 0;
    csr_valid = 0; csr_write = 0; csr_addr = 0; csr_wdata = 0;
    expected_valid = 0; response_seen = 0;
    host_run = 1; core_run = 1;
    mode_control = 0; mode_active = 0; lane = 0; selected_cell = 0;
    auto_enable = 0; tick_index = 0; ticks = 0;
    foreach (counts[i]) counts[i] = 0;
    foreach (request_cell[i]) begin
      request_cell[i] = 0; request_target[i] = 0; request_valid[i] = 0;
    end
    foreach (phases[i]) begin
      phases[i] = 0; frequencies[i] = 0; gamma[i] = 0;
      thermal[i] = 32'h40000000;
    end
    #1;
    blocked_bus();
    equal_word({24'd0, interface_ready, interface_busy, protocol_error,
                invalid_before_ready, invalid_while_busy, invalid_valid_held,
                host_reset_released, core_reset_released}, 0, "reset CDC state");
    repeat (3) @(posedge host_clk);
    @(negedge host_clk); #1; rst_n_async = 1;
    while (!interface_ready) begin @(posedge host_clk); #1; end
    repeat (10) begin
      @(posedge host_clk); #1;
      equal_word({30'd0, csr_ready, interface_busy}, 0, "no stale completion");
    end
    expect_read('h28, 0);
    wr(0, 1);
    expect_read('h28, 1);
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
    reset_and_tick();
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

  task automatic mixed_traffic(input logic [31:0] seed);
    logic [31:0] value;
    reset_and_tick();
    rng = seed;
    for (int n = 0; n < 128; n++) begin
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
    $display("CSR_CDC seed=%08h PASS", seed);
  endtask

  initial begin : run
    int core_snapshot;
    reset_and_tick();
    for (int m = 0; m < 3; m++) begin
      wr('h04, 32'(m));
      repeat (17) wr(0, 1);
      audit();
    end
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
    for (int a = 0; a < 256; a++) if ((a % 4) != 0) begin
      cycle(1, 8'(a), 1, 1);
      cycle(0, 8'(a), 0, 1);
    end
    stage(0, 0, 1); stage(1, 7, 3); wr('h68, 1); wr(0, 1);
    wr('h08, 0); expect_read('h14, 0);
    wr('h08, 1); expect_read('h14, 0);
    for (int m = 1; m <= 2; m++) begin
      route_case(m, 0);
      route_case(m, 7);
    end
    mixed_traffic(32'h13579BDF);
    check_protocol(3'b000);

    // Pause the core: input noise and a second pulse must not replace a tick.
    reset_and_tick();
    @(negedge core_clk); core_run = 0;
    launch(1, 0, 1);
    @(negedge host_clk); csr_valid = 0; csr_addr = 'hFC; csr_wdata = 'hBAD00BAD;
    repeat (3) @(posedge host_clk);
    @(negedge host_clk); csr_valid = 1;
    @(posedge host_clk); #1;
    check_protocol(3'b010);
    equal_word({30'd0, interface_busy, csr_ready}, 2, "busy rejection");
    @(negedge host_clk); csr_valid = 0;
    core_run = 1;
    finish_response();
    // This deliberately launched tick bypassed the test driver's CSR model.
    record_tick();
    expect_read('h28, 2);
    check_protocol(3'b010);

    // Keep valid high through completion: the tick must execute exactly once.
    reset_and_tick();
    launch(1, 0, 1);
    finish_response();
    repeat (12) begin
      @(posedge host_clk); #1;
      if (csr_ready || interface_busy) $fatal(1, "Held valid repeated a command");
    end
    check_protocol(3'b011);
    @(negedge host_clk); csr_valid = 0;
    @(posedge host_clk); #1;
    record_tick();
    expect_read('h28, 2);
    check_protocol(3'b011);

    // Pause the host after launch: the core response must remain available.
    reset_and_tick();
    launch(0, 'hFC, 0);
    @(negedge host_clk); csr_valid = 0; host_run = 0;
    repeat (15) @(posedge core_clk);
    #1;
    if (!response_seen || !interface_busy || csr_ready)
      $fatal(1, "Stopped host lost its pending response");
    host_run = 1;
    finish_response();
    equal_word(sampled, 32'h46523201, "retained interface ID response");

    // Abort once before core delivery and once with a response waiting.
    reset_and_tick();
    @(negedge core_clk); core_run = 0;
    core_snapshot = core_completions;
    launch(1, 0, 1);
    @(negedge host_clk); csr_valid = 0;
    reset_and_tick();
    if (core_completions != core_snapshot + 3)
      $fatal(1, "Aborted undelivered command reached the core");
    launch(1, 0, 1);
    @(negedge host_clk); csr_valid = 0; host_run = 0;
    repeat (15) @(posedge core_clk);
    #1;
    if (!response_seen) $fatal(1, "Response-abort scenario was not reached");
    // Assert reset before restoring host clocks, then use normal recovery.
    rst_n_async = 0;
    host_run = 1;
    reset_and_tick();

    // Host requests before core release must be discarded, never queued.
    @(negedge core_clk); core_run = 0;
    @(negedge host_clk); #1; rst_n_async = 0;
    resets++;
    repeat (3) @(posedge host_clk);
    @(negedge host_clk); rst_n_async = 1;
    while (!host_reset_released) begin @(posedge host_clk); #1; end
    @(negedge host_clk); csr_valid = 1; csr_write = 1; csr_addr = 0; csr_wdata = 1;
    @(posedge host_clk); #1;
    check_protocol(3'b100);
    equal_word({30'd0, interface_busy, interface_ready}, 0, "early rejection");
    @(negedge host_clk); csr_valid = 0; core_run = 1;
    while (!interface_ready) begin @(posedge host_clk); #1; end
    repeat (12) begin
      @(posedge host_clk); #1;
      if (csr_ready || interface_busy) $fatal(1, "Early request was replayed");
    end
    launch(0, 'h28, 0);
    @(negedge host_clk); csr_valid = 0;
    finish_response();
    equal_word(sampled, 0, "no tick from rejected early request");
    check_protocol(3'b100);
    reset_and_tick();
    check_protocol(3'b000);
    if (launches != completions + aborts
        || core_completions != completions + aborts_after_core
        || host_responses != completions || aborts != 2
        || aborts_after_core != 1 || routes != 8 || errors < 384
        || idle_sequences < 40 || mode_ticks[0] < 17
        || mode_ticks[1] < 17 || mode_ticks[2] < 17)
      $fatal(1, "CDC transaction accounting or required coverage mismatch");
    $display("FRP_M32_CSR_CDC_TB: PASS host_half=%0d core_half=%0d phase=%0d checks=%0d launches=%0d completions=%0d core_completions=%0d host_responses=%0d aborts=%0d aborts_after_core=%0d ticks=%0d errors=%0d routes=%0d resets=%0d",
       host_half, core_half, phase_offset, checks, launches, completions,
       core_completions, host_responses, aborts, aborts_after_core,
       total_ticks, errors, routes, resets);
    $finish;
  end
endmodule : frp_m32_csr_cdc_tb
`endif

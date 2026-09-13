// SPDX-License-Identifier: Apache-2.0
// FRP M32 ready/valid CSR CDC integration testbench.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert and
// --top-module frp_m32_csr_cdc_stream_tb. Include directories: rtl/m22,
// rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Clock profiles HOST_HALF/CORE_HALF/PHASE: 5/7/1, 3/11/4, 13/2/3 ns.
//
// An independent scoreboard checks accepted payloads at the core boundary
// and expected CSR data/errors at both core completion and host consumption.
// Requests held before readiness, continuous valid traffic, response stalls,
// simultaneous response/request transfers, and stopped clocks are exercised.
// Four reset aborts cover pre-issue, in-flight, executed, and buffered-response
// stages. No stale response or repeated command may cross a reset epoch.
//
// Directed routes use both lanes and cells 0 and 7 under schedules 7/1 and
// 1/7. Both opposite-polarity routes retain active zero and pending polarity
// between separate ticks. The canonical kernel remains -1/0/1.
//
// Each profile requires 427 accepts, 426 CDC pulses, 425 core completions,
// 423 consumed responses, 4 reset aborts (2 after execution), 127 simultaneous
// transfers, 41 intentionally rejected CSR accesses, 8 routes and 10 reset
// epochs after startup. The 128-request stream uses seed 13579bdf.
// Clock-dependent stall/check counts are reported for deterministic replay.

`ifndef FRP_M32_CSR_CDC_STREAM_TB_SV
`define FRP_M32_CSR_CDC_STREAM_TB_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_cdc_stream_top.sv"

module frp_m32_csr_cdc_stream_tb;
  logic host_clk = 0, core_clk = 0, rst_n_async = 0;
  bit host_run = 1, core_run = 0, auto_consume = 0;
  int host_half = 5, core_half = 7, phase_offset = 1, auto_cycle = 0;
  logic req_valid = 0, req_ready, req_write = 0;
  logic [7:0] req_addr = 0;
  logic [31:0] req_wdata = 0;
  logic rsp_valid, rsp_ready = 0, rsp_error;
  logic [31:0] rsp_rdata;
  logic host_reset_released, core_reset_released, interface_ready, interface_busy;
  logic protocol_error, invalid_before_ready, invalid_while_busy, invalid_valid_held;
  logic [32:0] driven_response = 0, expected_response, held_response;
  logic [40:0] expected_request, held_request;
  bit pending = 0, core_seen = 0, stalled_response = 0, stalled_request = 0;
  bit previous_bridge_valid = 0;
  int accepted = 0, completed = 0, core_completed = 0, aborted = 0;
  int aborted_after_core = 0, simultaneous = 0, backpressure_edges = 0;
  int request_wait_edges = 0, routes = 0, resets = 0, checks = 0;
  int rejected = 0, pulses = 0, mode_active = 0, tick_index = 0, ticks = 0;
  int counts[5] = '{default:0};
  logic [31:0] rng = 32'h13579bdf, last_gamma = 0;

  frp_m32_csr_cdc_stream_top dut (.*);

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
  initial begin #5000000; $fatal(1, "Stream watchdog"); end

  always @(negedge host_clk) begin
    if (auto_consume) begin
      #1ps;
      auto_cycle++;
      rsp_ready = ((auto_cycle % 19) >= 11);
    end
  end

  task automatic equal_word(input logic [31:0] got, want, input string label);
    if (got !== want)
      $fatal(1, "%s got=%h want=%h accepted=%0d time=%0t", label, got, want, accepted, $time);
    checks++;
  endtask

  always @(posedge host_clk) begin
    if (!rst_n_async || !host_reset_released) begin
      if (req_ready || rsp_valid || interface_busy)
        $fatal(1, "Stream handshake during reset");
    end else begin
      if (protocol_error || invalid_before_ready || invalid_while_busy || invalid_valid_held)
        $fatal(1, "Adapter violated the CDC pulse protocol");
      if (stalled_response && (!rsp_valid || {rsp_error,rsp_rdata} !== held_response))
        $fatal(1, "Response changed under backpressure");
      if (stalled_request && (!req_valid || {req_write,req_addr,req_wdata} !== held_request))
        $fatal(1, "Stimulus changed an unaccepted request");
      if (rsp_valid) begin
        if (!pending || !core_seen || {rsp_error,rsp_rdata} !== expected_response)
          $fatal(1, "Incorrect, unrequested or repeated response got=%h expected=%h",
                 {rsp_error,rsp_rdata}, expected_response);
        checks++;
        if (rsp_ready) begin
          completed++;
          if (rsp_error) rejected++;
          pending = 0;
          core_seen = 0;
        end else begin
          if (req_ready) $fatal(1, "Accepted a request over a stalled response");
          backpressure_edges++;
        end
      end
      if (req_valid && req_ready) begin
        if (pending) $fatal(1, "Multiple outstanding requests");
        if (rsp_valid && rsp_ready) simultaneous++;
        expected_request = {req_write,req_addr,req_wdata};
        expected_response = driven_response;
        pending = 1;
        accepted++;
      end
      if (dut.bridge_valid) begin
        if (previous_bridge_valid || dut.bridge_busy || !interface_ready)
          $fatal(1, "Invalid CDC request pulse");
        pulses++;
      end
      previous_bridge_valid = dut.bridge_valid;
      stalled_response = rsp_valid && !rsp_ready;
      held_response = {rsp_error,rsp_rdata};
      stalled_request = req_valid && !req_ready;
      held_request = {req_write,req_addr,req_wdata};
      if (stalled_request) request_wait_edges++;
    end
  end

  always @(posedge core_clk) begin
    if (rst_n_async && dut.u_cdc.core_csr_valid && dut.u_cdc.core_csr_ready) begin
      if (!pending || core_seen) $fatal(1, "Unrequested or repeated core transfer");
      if ({dut.u_cdc.core_csr_write,dut.u_cdc.core_csr_addr,dut.u_cdc.core_csr_wdata}
          !== expected_request) $fatal(1, "Accepted request payload changed");
      if ({dut.u_cdc.core_csr_error,dut.u_cdc.core_csr_rdata} !== expected_response)
        $fatal(1, "Core response differs from independent expectation addr=%h got=%h expected=%h",
               dut.u_cdc.core_csr_addr,
               {dut.u_cdc.core_csr_error,dut.u_cdc.core_csr_rdata}, expected_response);
      core_seen = 1;
      core_completed++;
    end
  end

  task automatic reset_epoch();
    #1ps;
    if (pending) aborted++;
    if (core_seen) aborted_after_core++;
    rst_n_async = 0;
    req_valid = 0; rsp_ready = 0; auto_consume = 0;
    pending = 0; core_seen = 0;
    stalled_response = 0; stalled_request = 0; previous_bridge_valid = 0;
    host_run = 1; core_run = 1;
    mode_active = 0; tick_index = 0; ticks = 0;
    foreach (counts[i]) counts[i] = 0;
    repeat (4) @(posedge host_clk);
    @(negedge host_clk); #1ps; rst_n_async = 1;
    while (!interface_ready) begin @(negedge host_clk); #1ps; end
    repeat (12) begin
      @(posedge host_clk); #1ps;
      equal_word({30'd0,rsp_valid,interface_busy}, 0, "No stale response after reset");
    end
    resets++;
  endtask

  task automatic send(input bit write_access, input logic [7:0] address,
                      input logic [31:0] data, expected_data = 0, input bit error = 0);
    @(negedge host_clk); #2ps;
    req_valid = 1; req_write = write_access; req_addr = address; req_wdata = data;
    driven_response = {error,expected_data};
    do @(posedge host_clk); while (!req_ready);
    #1ps;
    @(negedge host_clk); #2ps;
    req_valid = 0;
    req_write = !write_access; req_addr = ~address; req_wdata = ~data;
  endtask

  task automatic wait_response();
    while (!rsp_valid) begin @(negedge host_clk); #2ps; end
  endtask

  task automatic consume(input int stall = 3);
    wait_response();
    repeat (stall) begin @(posedge host_clk); #1ps; end
    @(negedge host_clk); #2ps; rsp_ready = 1;
    @(posedge host_clk); #1ps;
    @(negedge host_clk); #2ps; rsp_ready = 0;
  endtask

  function automatic int slot();
    if (mode_active == 1) return ((tick_index % 8) == 7) ? 2 : 1;
    if (mode_active == 2) return ((tick_index % 8) == 0) ? 3 : 4;
    return 0;
  endfunction

  task automatic wr(input logic [7:0] a, input logic [31:0] d);
    send(1,a,d); consume();
    if (a == 4 && int'(d) != mode_active) begin mode_active = int'(d); tick_index = 0; end
    if (a == 0 && d == 1) begin counts[slot()]++; tick_index++; ticks++; end
    if (a == 0 && d == 2) begin ticks = 0; foreach(counts[i]) counts[i] = 0; end
  endtask
  task automatic rd(input logic [7:0] a, input logic [31:0] d);
    send(0,a,0,d); consume();
  endtask
  task automatic stage(input int lane, cell_index, input logic [31:0] target);
    wr('h08,32'(lane)); wr('h0C,32'(cell_index)); wr('h10,target); wr('h14,1);
  endtask
  task automatic wait_commit_slot();
    while (!(slot() inside {0,2,3})) wr(0,1);
    rd('h24,32'(slot()));
  endtask

  task automatic route_case(input int mode_number, lane, cell_index);
    reset_epoch();
    wr('h04,32'(mode_number)); rd('h20,32'(mode_number));
    wr('h18,32'(cell_index));
    wait_commit_slot(); stage(lane,cell_index,1); wr(0,1); rd('h34,1);
    for (int direction = 0; direction < 2; direction++) begin
      stage(lane,cell_index,(direction == 0) ? 3 : 1); wr(0,1);
      rd('h34,0); rd('h38,(direction == 0) ? 3 : 1);
      wr(0,2);
      send(1,0,3,0,1); consume(17);
      rd('h34,0); rd('h38,(direction == 0) ? 3 : 1);
      wait_commit_slot(); rd('h34,0); wr(0,1);
      rd('h34,(direction == 0) ? 3 : 1); rd('h38,0);
      rd('h4C,'h3FF); rd('h5C,0); rd('h60,0); rd('h64,0);
      routes++;
    end
    for (int n = 0; n < 5; n++) rd(8'('hA0 + 4*n),32'(counts[n]));
  endtask

  initial begin : scenarios
    int before_count;
    // A request may remain valid throughout reset release and a stopped core.
    repeat (4) @(posedge host_clk);
    @(negedge host_clk); #2ps;
    rst_n_async = 1; req_valid = 1; req_addr = 'hFC;
    driven_response = {1'b0,32'h46523201};
    repeat (20) begin @(posedge host_clk); #1ps; equal_word({31'd0,req_ready},0,"Early request waits"); end
    core_run = 1;
    do @(posedge host_clk); while (!req_ready);
    #1ps;
    @(negedge host_clk); #2ps; req_valid = 0;
    consume(25);
    equal_word(32'(accepted),1,"Held startup request accepted once");
    reset_epoch();

    // Continuous valid traffic and changing response readiness.
    auto_consume = 1;
    for (int n = 0; n < 128; n++) begin
      @(negedge host_clk); #2ps;
      rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5;
      req_valid = 1; req_write = 0; req_addr = 'hFC; req_wdata = 0;
      driven_response = {1'b0,32'h46523201};
      case (n % 8)
        0: begin req_write=1; req_addr='h74; req_wdata=rng; last_gamma=rng; driven_response=0; end
        1: begin req_addr='h74; driven_response={1'b0,last_gamma}; end
        2: begin req_write=1; req_addr=0; req_wdata=1; driven_response=0; ticks++; end
        3: begin req_addr='h28; driven_response={1'b0,32'(ticks)}; end
        4: begin end
        5: begin req_write=1; req_addr=4; req_wdata=3; driven_response={1'b1,32'd0}; end
        6: begin req_addr=1; driven_response={1'b1,32'd0}; end
        7: begin req_addr='h5C; driven_response=0; end
      endcase
      do @(posedge host_clk); while (!req_ready);
      #1ps;
    end
    @(negedge host_clk); #2ps; req_valid=0;
    while (pending) begin @(negedge host_clk); #2ps; end
    auto_consume=0; rsp_ready=0;
    if (simultaneous < 127) $fatal(1,"Missing same-edge response/request transfers");
    rd('h28,16);
    rd('hFC,'h46523201);
    send(1,'hFC,'hFFFFFFFF,0,1); consume(13);
    rd('hFC,'h46523201);

    // Clock stops retain accepted requests and completed responses.
    reset_epoch();
    @(negedge core_clk); #1ps; core_run=0;
    send(1,0,1);
    repeat(20) begin @(posedge host_clk); #1ps; equal_word({31'd0,rsp_valid},0,"Stopped core waits"); end
    core_run=1; wait_response();
    @(negedge core_clk); #1ps; core_run=0;
    consume(9);
    equal_word({31'd0,pending},0,"Held response consumed with core stopped");
    core_run=1; rd('h28,1);
    send(1,0,1);
    // Allow the ISSUE edge before stopping the host clock.
    @(negedge host_clk); #2ps;
    before_count=completed;
    host_run=0;
    repeat(25) @(posedge core_clk);
    #1ps;
    if (!core_seen) $fatal(1,"Core did not complete with the host clock stopped");
    equal_word(32'(completed),32'(before_count),"Stopped host retains response");
    host_run=1; consume(); rd('h28,2);

    // Reset before issue, in flight, after execution, and with a held response.
    before_count=pulses;
    send(1,0,1);
    if (!pending || core_seen || dut.bridge_busy || pulses != before_count)
      $fatal(1,"Reset-before-issue scenario reached the CDC bridge");
    reset_epoch(); rd('h28,0);
    @(negedge core_clk); #1ps; core_run=0;
    send(1,0,1); repeat(5) @(negedge host_clk); #2ps;
    if (!pending || !dut.bridge_busy || core_seen)
      $fatal(1,"Reset-in-flight scenario did not retain its request");
    reset_epoch(); rd('h28,0);
    send(1,0,1);
    while (!core_seen) begin @(posedge core_clk); #1ps; end
    if (rsp_valid) $fatal(1,"Reset-after-execution scenario reached response too late");
    reset_epoch(); rd('h28,0);
    send(0,'hFC,0,'h46523201); wait_response();
    if (!pending || !core_seen) $fatal(1,"Reset-with-response scenario incomplete");
    reset_epoch(); rd('hFC,'h46523201);

    for (int mode_number=1; mode_number<=2; mode_number++) begin
      route_case(mode_number,0,0);
      route_case(mode_number,1,7);
    end
    repeat (32) begin
      @(posedge host_clk); #1ps;
      equal_word({30'd0,rsp_valid,interface_busy},0,"Idle stream stays empty");
    end
    if (pending || core_seen || accepted != completed+aborted
        || core_completed != completed+aborted_after_core)
      $fatal(1,"Transaction conservation failed");
    if (accepted != 427 || completed != 423 || core_completed != 425
        || aborted != 4 || aborted_after_core != 2 || pulses != 426
        || simultaneous != 127 || rejected != 41 || routes != 8 || resets != 10
        || backpressure_edges < 100 || request_wait_edges < 100)
      $fatal(1,"Required stream scenarios incomplete");
    $display("FRP_M32_CSR_CDC_STREAM_TB: PASS host_half=%0d core_half=%0d phase=%0d checks=%0d accepted=%0d completed=%0d core_completed=%0d aborted=%0d aborted_after_core=%0d simultaneous=%0d stalled_responses=%0d stalled_requests=%0d pulses=%0d rejected=%0d routes=%0d resets=%0d",
             host_half,core_half,phase_offset,checks,accepted,completed,core_completed,
             aborted,aborted_after_core,simultaneous,backpressure_edges,request_wait_edges,
             pulses,rejected,routes,resets);
    $finish;
  end
endmodule : frp_m32_csr_cdc_stream_tb
`endif

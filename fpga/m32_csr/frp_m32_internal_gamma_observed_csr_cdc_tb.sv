// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Dual-clock internal-gamma control/snapshot CSR integration testbench.
// Parameters: CELLS=8/16/32/64; COUNT_BITS=1..64.
// Plusargs: +seed=76 +HOST_HALF=5 +CORE_HALF=7 +PHASE=1 +FULL=1.
// Half periods and initial core phase are in ns; half periods must be >=2.
// FULL=0 exercises transport without loading gamma; FULL=1 adds 624 checkpoint
// words, 24 accepted ticks in three scheduling modes and frozen snapshot reads.
// Independent scoreboards check 42 request bits, 33 response bits, one completion
// per request, and snapshot decoding from recorder outputs captured at the core
// accepting edge. All 256 snapshot byte addresses are read and written.
// Exercise stopped clocks, held/busy/early requests and reset before delivery
// and after core completion. Deterministic seed controls data and request gaps.
// PASS reports scenario counters and a signature for identical-run comparison.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root so the sine LUT path resolves.
// Simulation checks digital behavior; it does not measure analog metastability
// or replace physical CDC constraints and implementation timing analysis.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_TB_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_top.sv"
module frp_m32_internal_gamma_observed_csr_cdc_tb #(parameter int CELLS=8, COUNT_BITS=64);
  logic host_clk=0,core_clk=0,rst_n_async=0;
  logic host_run=1,core_run=1;
  int host_half=5,core_half=7,phase_offset=1;
  logic csr_valid=0,csr_write=0;
  logic [8:0] csr_addr=0;
  logic [31:0] csr_wdata=0,csr_rdata,sampled;
  logic csr_ready,csr_error,host_reset_released,core_reset_released;
  logic interface_ready,interface_busy,protocol_error;
  logic invalid_before_ready,invalid_while_busy,invalid_valid_held;
  logic [41:0] expected_payload;
  logic [32:0] response_payload;
  bit expected_valid=0,response_seen=0;
  int launches=0,completions=0,core_completions=0,host_responses=0;
  int aborts=0,aborts_after_core=0,checks=0,stalled=0,ticks=0,resets=0;
  localparam logic [COUNT_BITS-1:0] COUNT_MAX='1;
  int full_run=1;
  int unsigned seed=76,random_state;
  logic [63:0] signature=64'hcbf29ce484222325;
  logic [32:0] previous_host_response=0;
  bit previous_host_ready=0;
  bit [255:0] snapshot_reads=0,snapshot_writes=0;
  bit [2:0] modes_seen=0;
  int captures=0,releases=0,errors=0,frozen_reads=0;
  function automatic logic [31:0] random_word();
    random_state=random_state^(random_state<<13);
    random_state=random_state^(random_state>>17);
    random_state=random_state^(random_state<<5);
    return random_state;
  endfunction
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
  frp_m32_internal_gamma_observed_csr_cdc_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) dut(.*);
  typedef struct packed {
    logic seen;
    logic [COUNT_BITS-1:0] count;
    logic overflow;
    logic [31:0] previous_margin, minimum_margin;
    logic [63:0] minimum_tick;
    logic [31:0] peak_switch;
    logic [63:0] peak_tick;
    logic boundary_valid, boundary_pulse;
    logic [63:0] boundary_tick;
    logic [1:0] mode;
    logic [2:0] state;
    logic [31:0] boundary_previous, boundary_margin, capacity, pressure;
    logic [31:0] heat, switches;
    logic [CELLS*2-1:0] retained, pending;
    logic alignment_error;
  } sample_t;
  sample_t live, held = '0;
  bit held_valid = 0;

  assign live.seen=dut.u_csr.u_core.record_sample_seen_q;
  assign live.count=dut.u_csr.u_core.record_sample_count_q;
  assign live.overflow=dut.u_csr.u_core.record_count_overflow_q;
  assign live.previous_margin=dut.u_csr.u_core.record_previous_margin_q16;
  assign live.minimum_margin=dut.u_csr.u_core.record_minimum_margin_q16;
  assign live.minimum_tick=dut.u_csr.u_core.record_minimum_margin_tick_q;
  assign live.peak_switch=dut.u_csr.u_core.record_peak_switch_load_q16;
  assign live.peak_tick=dut.u_csr.u_core.record_peak_switch_load_tick_q;
  assign live.boundary_valid=dut.u_csr.u_core.boundary_valid_q;
  assign live.boundary_pulse=dut.u_csr.u_core.boundary_pulse_q;
  assign live.boundary_tick=dut.u_csr.u_core.boundary_tick_q;
  assign live.mode=dut.u_csr.u_core.boundary_scheduler_mode_q;
  assign live.state=dut.u_csr.u_core.boundary_scheduler_state_q;
  assign live.boundary_previous=dut.u_csr.u_core.boundary_previous_margin_q16;
  assign live.boundary_margin=dut.u_csr.u_core.boundary_margin_q16;
  assign live.capacity=dut.u_csr.u_core.boundary_capacity_q16;
  assign live.pressure=dut.u_csr.u_core.boundary_pressure_q16;
  assign live.heat=dut.u_csr.u_core.boundary_mean_heat_q16;
  assign live.switches=dut.u_csr.u_core.boundary_switch_load_q16;
  assign live.retained=dut.u_csr.u_core.boundary_retained_state_q;
  assign live.pending=dut.u_csr.u_core.boundary_pending_route_q;
  assign live.alignment_error=dut.u_csr.u_core.record_alignment_error_q;

  function automatic logic [32:0] expected_snapshot();
    logic error;
    logic [31:0] data;
    logic [63:0] count64;
    logic [127:0] retained128, pending128;
    error = 0;
    data = 0;
    count64 = 64'(held.count);
    retained128 = 128'(held.retained);
    pending128 = 128'(held.pending);
    if (dut.core_csr_valid) begin
      if (dut.core_csr_addr[7:0]%4 != 0) error = 1;
      else if (dut.core_csr_write)
        error = !(dut.core_csr_addr[7:0]==0 && (dut.core_csr_wdata==1 || dut.core_csr_wdata==2));
      else begin
        case (dut.core_csr_addr[7:0])
          8'h04: data = {26'd0,held.alignment_error,held.boundary_pulse,
                         held.boundary_valid,held.overflow,held.seen,held_valid};
          8'h08: data = 32'h46524201;
          8'h0c: data = (32'(COUNT_BITS)<<16) | 32'(CELLS);
          default: begin
            if (!held_valid) error = 1;
            else case (dut.core_csr_addr[7:0])
              8'h10: data = count64[31:0];
              8'h14: data = count64[63:32];
              8'h18: data = held.previous_margin;
              8'h1c: data = held.minimum_margin;
              8'h20: data = held.minimum_tick[31:0];
              8'h24: data = held.minimum_tick[63:32];
              8'h28: data = held.peak_switch;
              8'h2c: data = held.peak_tick[31:0];
              8'h30: data = held.peak_tick[63:32];
              8'h34: data = held.boundary_tick[31:0];
              8'h38: data = held.boundary_tick[63:32];
              8'h3c: data = {27'd0,held.state,held.mode};
              8'h40: data = held.boundary_previous;
              8'h44: data = held.boundary_margin;
              8'h48: data = held.capacity;
              8'h4c: data = held.pressure;
              8'h50: data = held.heat;
              8'h54: data = held.switches;
              8'h58: data = retained128[31:0];
              8'h5c: data = retained128[63:32];
              8'h60: data = retained128[95:64];
              8'h64: data = retained128[127:96];
              8'h68: data = pending128[31:0];
              8'h6c: data = pending128[63:32];
              8'h70: data = pending128[95:64];
              8'h74: data = pending128[127:96];
              default: error = 1;
            endcase
          end
        endcase
      end
    end
    return {error,data};
  endfunction

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
    #1;
    if (!rst_n_async) begin
      previous_host_response=0;previous_host_ready=0;
    end else begin
      if (csr_ready && previous_host_ready) $fatal(1,"HOST_PULSE_WIDTH");
      if (!csr_ready && {csr_error,csr_rdata}!==previous_host_response)
        $fatal(1,"HOST_RESPONSE_NOT_HELD");
      previous_host_response={csr_error,csr_rdata};
      previous_host_ready=csr_ready;
    end
  end

  always @(posedge core_clk or negedge rst_n_async) begin
    if (!rst_n_async) begin held='0;held_valid=0;end
    else begin
    if(dut.core_csr_valid)begin
      if(!expected_valid || response_seen)$fatal(1,"UNREQUESTED_TRANSFER");
      if({dut.core_csr_write,dut.core_csr_addr,dut.core_csr_wdata}!==expected_payload)
        $fatal(1,"CORE_PAYLOAD");
      if(dut.core_csr_ready)begin
        response_payload={dut.core_csr_error,dut.core_csr_rdata};
        if(dut.core_csr_addr[8])begin
          if(response_payload!==expected_snapshot())$fatal(1,"SNAPSHOT_MODEL");
          if(dut.core_csr_write)snapshot_writes[dut.core_csr_addr[7:0]]=1;
          else snapshot_reads[dut.core_csr_addr[7:0]]=1;
          if(dut.core_csr_write&&!dut.core_csr_error)begin
            if(dut.core_csr_wdata==1)begin held=live;held_valid=1;captures++;end
            else begin held='0;held_valid=0;releases++;end
          end
        end
        response_seen=1;core_completions++;
      end else stalled++;
    end
    if(dut.u_csr.tick_accepted)ticks++;
    end
  end
  task automatic equal_word(input logic[31:0] actual,expected,input string label);
    if(actual!==expected)$fatal(1,"%s got=%h expected=%h time=%t",label,actual,expected,$time);
    checks++;mix({expected,actual});
  endtask
  task automatic check_protocol(input logic[2:0] expected);
    equal_word({29'd0,invalid_before_ready,invalid_while_busy,invalid_valid_held},
               {29'd0,expected},"PROTOCOL_FLAGS");
    equal_word({31'd0,protocol_error},{31'd0,|expected},"PROTOCOL_OR");
  endtask
  task automatic launch(input bit write_access,
                        input logic [8:0] address, input logic [31:0] data);
    @(negedge host_clk);
    if (!interface_ready || interface_busy || expected_valid)
      $fatal(1, "Test driver attempted an unavailable request");
    expected_payload = {write_access, address, data};
    expected_valid = 1;
    response_seen = 0;
    csr_valid = 1; csr_write = write_access;
    csr_addr = address; csr_wdata = data;
    launches++;mix({22'd0,expected_payload});
    @(posedge host_clk); #1;
    equal_word({30'd0, interface_busy, csr_ready}, 2, "accepted host pulse");
  endtask

  task automatic finish_response(input bit reject = 0);
    int watchdog;
    watchdog = 0;
    while (!csr_ready) begin
      @(posedge host_clk); #1;
      watchdog++;
      if (watchdog > 20000) $fatal(1, "CDC response timeout");
    end
    if (!expected_valid || !response_seen)
      $fatal(1, "Host response without a corresponding core completion");
    equal_word({31'd0, csr_error}, {31'd0, reject}, "response error");
    equal_word({31'd0, interface_busy}, 0, "completion clears busy");
    if ({csr_error, csr_rdata} !== response_payload)
      $fatal(1, "CDC changed the response payload");
    sampled = csr_rdata;
    mix({31'd0,response_payload});
    if(csr_error)errors++;
    expected_valid = 0;
    completions++;
    @(posedge host_clk); #1;
    equal_word({31'd0, csr_ready}, 0, "completion pulse width");
  endtask

  task automatic transfer(input bit wr,input logic[8:0] address,
                          input logic[31:0] data,input bit error_expected=0);
    repeat(int'(random_word()&3))@(negedge host_clk);
    launch(wr,address,data);
    @(negedge host_clk);csr_valid=0;csr_write=!wr;csr_addr=~address;csr_wdata=~data;
    finish_response(error_expected);
    if(wr||error_expected)equal_word(sampled,0,"UNUSED_DATA");
  endtask
  task automatic expect_read(input logic[8:0] address,input logic[31:0] expected);
    transfer(0,address,0);equal_word(sampled,expected,"READ_EXPECT");
  endtask
  task automatic reset_dut();
    if(expected_valid)begin aborts++;if(response_seen)aborts_after_core++;end
    rst_n_async=0;csr_valid=0;expected_valid=0;response_seen=0;
    host_run=1;core_run=1;#1;
    equal_word({24'd0,interface_ready,interface_busy,protocol_error,
      invalid_before_ready,invalid_while_busy,invalid_valid_held,
      host_reset_released,core_reset_released},0,"RESET_FLAGS");
    equal_word({30'd0,csr_ready,csr_error},0,"RESET_RESPONSE");
    equal_word(csr_rdata,0,"RESET_DATA");
    repeat(3)@(posedge host_clk);
    @(negedge host_clk);#1;rst_n_async=1;
    while(!interface_ready)begin @(posedge host_clk);#1;end
    repeat(12)begin @(posedge host_clk);#1;
      if(csr_ready||interface_busy)$fatal(1,"STALE_RESPONSE");
    end
    expect_read(9'h0fc,32'h46524701);
    expect_read(9'h108,32'h46524201);
    expect_read(9'h10c,(32'(COUNT_BITS)<<16)|32'(CELLS));
    expect_read(9'h104,0);check_protocol(0);resets++;
  endtask
  initial begin
    void'($value$plusargs("FULL=%d",full_run));
    void'($value$plusargs("seed=%d",seed));
    if (!(CELLS==8 || CELLS==16 || CELLS==32 || CELLS==64) ||
        COUNT_BITS<1 || COUNT_BITS>64 || !(full_run==0 || full_run==1))
      $fatal(1,"INVALID_TEST_PROFILE");
    random_state=seed^32'h6d2b79f5;
    if(random_state==0)random_state=1;
    mix({32'd0,seed});
    reset_dut();
    transfer(1,9'h100,1);
    for(int a=0;a<256;a++)begin
      transfer(0,9'(256+a),0,!(a>=4&&a<=116&&a%4==0));
      if(a==4)equal_word(sampled,1,"SNAPSHOT_VALID");
      if(a==8)equal_word(sampled,32'h46524201,"SNAPSHOT_ID");
      if(a==12)equal_word(sampled,(32'(COUNT_BITS)<<16)|32'(CELLS),"GEOMETRY");
      if(a>=16&&a<=116&&a%4==0)equal_word(sampled,a==24?39322:0,"RESET_PAYLOAD");
    end
    for(int a=0;a<256;a++)begin
      // 0xffffffff is also an invalid command at the command address.
      transfer(1,9'(256+a),32'hffffffff,1);
    end
    expect_read(9'h104,1);
    for(int page=0;page<5;page++)begin
      transfer(1,0,32'h100+32'(page>=3?page+1:page));
      expect_read(9'h108,32'h46524201);
      expect_read(9'h0fc,32'h46524701+32'(page));
    end
    transfer(1,9'h100,2);transfer(0,9'h110,0,1);
    transfer(1,0,32'h100);
    if(full_run!=0)begin
      transfer(1,9'h100,1);
      transfer(1,0,32'h105);transfer(1,9'h06c,624);transfer(1,0,32'h400);
      for(int w=0;w<624;w++)transfer(1,9'h070,random_word()|32'h80000000);
      expect_read(9'h074,624);transfer(1,0,32'h100);
      for(int mode=0;mode<3;mode++)begin
        transfer(1,9'h004,32'(mode));modes_seen[mode]=1;
        repeat(8)transfer(1,0,1);
      end
      for(int w=0;w<26;w++)begin
        expect_read(9'(9'h110+4*w),w==2?39322:0);frozen_reads++;
      end
      transfer(1,9'h100,1);
      for(int w=0;w<26;w++)transfer(0,9'(9'h110+4*w),0);
      expect_read(9'h110,64'(COUNT_MAX)<24?32'(COUNT_MAX):24);
      expect_read(9'h114,0);
      transfer(1,0,2);expect_read(9'h110,64'(COUNT_MAX)<24?32'(COUNT_MAX):24);
      equal_word(32'(ticks),24,"TICK_COUNT");
      if(stalled==0)$fatal(1,"NO_GAMMA_WAIT");
    end
    check_protocol(0);
    reset_dut();
    // Busy rejection with the core clock stopped and all host payload bits changed.
    @(negedge core_clk);core_run=0;
    launch(1,9'h100,1);
    @(negedge host_clk);csr_valid=0;csr_write=1;csr_addr=0;csr_wdata=1;
    repeat(3)@(posedge host_clk);
    @(negedge host_clk);csr_valid=1;
    @(posedge host_clk);#1;check_protocol(3'b010);
    @(negedge host_clk);csr_valid=0;core_run=1;
    finish_response();expect_read(9'h104,1);check_protocol(3'b010);
    reset_dut();
    // Held valid must not repeat a write or alter the snapshot.
    launch(1,9'h100,1);finish_response();
    repeat(12)begin @(posedge host_clk);#1;
      if(csr_ready||interface_busy)$fatal(1,"HELD_VALID_REPLAY");
    end
    check_protocol(3'b011);
    @(negedge host_clk);csr_valid=0;
    @(posedge host_clk);#1;expect_read(9'h104,1);
    reset_dut();
    // A stopped host retains the core response until the host resumes.
    launch(0,9'h108,0);
    @(negedge host_clk);csr_valid=0;host_run=0;
    repeat(15)@(posedge core_clk);#1;
    if(!response_seen||!interface_busy||csr_ready)$fatal(1,"STOPPED_HOST_RESPONSE");
    host_run=1;finish_response();equal_word(sampled,32'h46524201,"HELD_RESPONSE");
    reset_dut();
    // Reset before delivery, then reset after completion in the core domain.
    @(negedge core_clk);core_run=0;
    launch(1,9'h100,1);
    @(negedge host_clk);csr_valid=0;reset_dut();
    launch(1,9'h100,1);
    @(negedge host_clk);csr_valid=0;host_run=0;
    repeat(15)@(posedge core_clk);#1;
    if(!response_seen)$fatal(1,"ABORT_SCENARIO");
    reset_dut();
    // Before-ready pulses are rejected, not replayed after the core clock starts.
    @(negedge core_clk);core_run=0;
    @(negedge host_clk);#1;rst_n_async=0;
    repeat(3)@(posedge host_clk);
    @(negedge host_clk);rst_n_async=1;
    while(!host_reset_released)begin @(posedge host_clk);#1;end
    @(negedge host_clk);csr_valid=1;csr_write=1;csr_addr=9'h100;csr_wdata=1;
    @(posedge host_clk);#1;check_protocol(3'b100);
    if(interface_busy||interface_ready)$fatal(1,"EARLY_ACCEPT");
    @(negedge host_clk);csr_valid=0;core_run=1;
    while(!interface_ready)begin @(posedge host_clk);#1;end
    repeat(12)begin @(posedge host_clk);#1;
      if(csr_ready||interface_busy)$fatal(1,"EARLY_REPLAY");
    end
    expect_read(9'h104,0);check_protocol(3'b100);
    reset_dut();
    if(launches!=completions+aborts || core_completions!=completions+aborts_after_core ||
       host_responses!=completions || aborts!=2 || aborts_after_core!=1)
      $fatal(1,"ACCOUNTING");
    if(snapshot_reads!=='1 || snapshot_writes!=='1 || resets!=8 ||
       (full_run && (modes_seen!=3'b111 || frozen_reads!=26 || ticks!=24 || stalled==0)) ||
       (!full_run && (ticks!=0 || frozen_reads!=0)))$fatal(1,"SCENARIO_COVERAGE");
    $display("PASS HOST_CDC cells=%0d bits=%0d full=%0d host_half=%0d core_half=%0d phase=%0d checks=%0d launches=%0d completions=%0d core_completions=%0d aborts=%0d aborts_after_core=%0d ticks=%0d stalls=%0d resets=%0d seed=%0d captures=%0d releases=%0d errors=%0d frozen=%0d signature=%016h",
      CELLS,COUNT_BITS,full_run,host_half,core_half,phase_offset,checks,launches,completions,core_completions,aborts,aborts_after_core,ticks,stalled,resets,seed,captures,releases,errors,frozen_reads,signature);
    $finish;
  end
  initial begin #20000000;$fatal(1,"WATCHDOG");end
endmodule : frp_m32_internal_gamma_observed_csr_cdc_tb
`endif

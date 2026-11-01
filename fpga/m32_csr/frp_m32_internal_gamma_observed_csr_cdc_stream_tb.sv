// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Internal-gamma CDC stream transport, snapshot decoding and core integration.
// CELLS=8/16/32/64; COUNT_BITS=1..64; +seed=76.
// Timing: +HOST_HALF=5 +CORE_HALF=7 +PHASE=1 (ns, half periods >=2).
// Check all 42 accepted request bits and all 33 returned response bits.
// Independently decode every snapshot byte address from recorder outputs
// sampled at the accepted capture edge; exercise all 256 reads and writes.
// Walk every write-data bit and its complement, retain errors under stalls,
// and issue 64 consecutive requests including identical adjacent payloads.
// Load all 624 checkpoint words, execute 24 ticks in free/7/1/1/7 modes,
// and verify frozen snapshot contents through gamma loading and core activity.
// Stop each clock, replace a consumed response on the same host edge, and
// reset before core delivery and with an unconsumed response and stopped clocks.
// Deterministic request/response signature excludes clock-dependent counters.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root to resolve the sine LUT.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_STREAM_TB_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_STREAM_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_stream_top.sv"
module frp_m32_internal_gamma_observed_csr_cdc_stream_tb #(parameter int CELLS=8, COUNT_BITS=64);
  logic host_clk=0,core_clk=0,rst_n_async=1,host_run=1,core_run=1;
  int host_half=5,core_half=7,phase=1;
  logic req_valid=0,req_write=0,rsp_ready=0;
  logic [8:0] req_addr=0;
  logic [31:0] req_wdata=0;
  wire req_ready,rsp_valid,rsp_error;
  wire [31:0] rsp_rdata;
  wire host_reset_released,core_reset_released,interface_ready,interface_busy;
  wire protocol_error,invalid_before_ready,invalid_while_busy,invalid_valid_held;
  logic [41:0] expected_request;
  logic [32:0] expected_response,held_response;
  bit outstanding=0,core_seen=0,was_stalled=0;
  int requests=0,responses=0,core_responses=0,aborts=0,aborts_after_core=0;
  int checks=0,stalls=0,simultaneous=0,ticks=0,errors=0;
  logic [31:0] sampled;
  int unsigned seed=76,rng;
  int forwarded=0,captures=0,releases=0,frozen_reads=0,walking_words=0,burst_responses=0;
  int resets=0;
  bit [255:0] snapshot_reads=0,snapshot_writes=0;
  bit [31:0] write_ones=0,write_zeros=0;
  bit [2:0] modes_seen=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  function automatic logic [31:0] scramble(input logic [31:0] value);
    logic [31:0] x;
    x=value^(value<<13);x=x^(x>>17);return x^(x<<5);
  endfunction
  function automatic logic [31:0] random_word();
    rng=scramble(rng);return rng;
  endfunction
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
  frp_m32_internal_gamma_observed_csr_cdc_stream_top #(
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

  assign live.seen=dut.u_cdc.u_csr.u_core.record_sample_seen_q;
  assign live.count=dut.u_cdc.u_csr.u_core.record_sample_count_q;
  assign live.overflow=dut.u_cdc.u_csr.u_core.record_count_overflow_q;
  assign live.previous_margin=dut.u_cdc.u_csr.u_core.record_previous_margin_q16;
  assign live.minimum_margin=dut.u_cdc.u_csr.u_core.record_minimum_margin_q16;
  assign live.minimum_tick=dut.u_cdc.u_csr.u_core.record_minimum_margin_tick_q;
  assign live.peak_switch=dut.u_cdc.u_csr.u_core.record_peak_switch_load_q16;
  assign live.peak_tick=dut.u_cdc.u_csr.u_core.record_peak_switch_load_tick_q;
  assign live.boundary_valid=dut.u_cdc.u_csr.u_core.boundary_valid_q;
  assign live.boundary_pulse=dut.u_cdc.u_csr.u_core.boundary_pulse_q;
  assign live.boundary_tick=dut.u_cdc.u_csr.u_core.boundary_tick_q;
  assign live.mode=dut.u_cdc.u_csr.u_core.boundary_scheduler_mode_q;
  assign live.state=dut.u_cdc.u_csr.u_core.boundary_scheduler_state_q;
  assign live.boundary_previous=dut.u_cdc.u_csr.u_core.boundary_previous_margin_q16;
  assign live.boundary_margin=dut.u_cdc.u_csr.u_core.boundary_margin_q16;
  assign live.capacity=dut.u_cdc.u_csr.u_core.boundary_capacity_q16;
  assign live.pressure=dut.u_cdc.u_csr.u_core.boundary_pressure_q16;
  assign live.heat=dut.u_cdc.u_csr.u_core.boundary_mean_heat_q16;
  assign live.switches=dut.u_cdc.u_csr.u_core.boundary_switch_load_q16;
  assign live.retained=dut.u_cdc.u_csr.u_core.boundary_retained_state_q;
  assign live.pending=dut.u_cdc.u_csr.u_core.boundary_pending_route_q;
  assign live.alignment_error=dut.u_cdc.u_csr.u_core.record_alignment_error_q;

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
    if (dut.u_cdc.core_csr_valid) begin
      if (dut.u_cdc.core_csr_addr[7:0]%4 != 0) error = 1;
      else if (dut.u_cdc.core_csr_write)
        error = !(dut.u_cdc.core_csr_addr[7:0]==0 && (dut.u_cdc.core_csr_wdata==1 || dut.u_cdc.core_csr_wdata==2));
      else begin
        case (dut.u_cdc.core_csr_addr[7:0])
          8'h04: data = {26'd0,held.alignment_error,held.boundary_pulse,
                         held.boundary_valid,held.overflow,held.seen,held_valid};
          8'h08: data = 32'h46524201;
          8'h0c: data = (32'(COUNT_BITS)<<16) | 32'(CELLS);
          default: begin
            if (!held_valid) error = 1;
            else case (dut.u_cdc.core_csr_addr[7:0])
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
    void'($value$plusargs("HOST_HALF=%d",host_half));
    if(host_half<2)$fatal(1,"HOST_HALF_RANGE");
    forever begin #(host_half);if(host_run)host_clk=~host_clk;end
  end
  initial begin
    void'($value$plusargs("CORE_HALF=%d",core_half));
    void'($value$plusargs("PHASE=%d",phase));
    if(core_half<2||phase<0)$fatal(1,"CORE_CLOCK_RANGE");
    #(phase);forever begin #(core_half);if(core_run)core_clk=~core_clk;end
  end
  task automatic require(input logic ok,input string label);
    if(ok!==1'b1)$fatal(1,"%s t=%t req=%0d rsp=%0d",label,$time,requests,responses);
    checks++;
  endtask
  always @(negedge rst_n_async)begin
    if(outstanding)begin aborts++;if(core_seen)aborts_after_core++;end
    outstanding=0;core_seen=0;was_stalled=0;held='0;held_valid=0;
  end
  always @(posedge host_clk)if(rst_n_async&&host_reset_released)begin
    if(was_stalled)require(rsp_valid&&{rsp_error,rsp_rdata}===held_response,"HELD_RESPONSE");
    was_stalled=rsp_valid&&!rsp_ready;held_response={rsp_error,rsp_rdata};
    if(was_stalled)stalls++;
    if(rsp_valid&&rsp_ready)begin
      require(outstanding&&core_seen,"UNEXPECTED_RESPONSE");
      require({rsp_error,rsp_rdata}===expected_response,"RESPONSE_PAYLOAD");
      mix({31'd0,rsp_error,rsp_rdata});
      outstanding=0;responses++;if(rsp_error)errors++;
      if(req_valid&&req_ready)simultaneous++;
    end
    if(req_valid&&req_ready)begin
      require(!outstanding,"OVERLAPPING_REQUEST");
      outstanding=1;core_seen=0;expected_request={req_write,req_addr,req_wdata};requests++;
      mix({22'd0,expected_request});
      if(req_write)begin write_ones|=req_wdata;write_zeros|=~req_wdata;end
    end
    if(dut.bridge_valid)begin
      require(outstanding&&{dut.request_write_q,dut.request_addr_q,dut.request_wdata_q}
              ===expected_request,"CDC_ISSUE_PAYLOAD");
      forwarded++;
    end
    #1;
    require(!protocol_error&&!invalid_before_ready&&!invalid_while_busy&&!invalid_valid_held,
            "PROTOCOL_FLAGS");
  end
  always @(posedge core_clk)if(rst_n_async)begin
    if(dut.u_cdc.core_csr_valid)begin
      require(outstanding&&!core_seen,"UNREQUESTED_CORE_TRANSFER");
      require({dut.u_cdc.core_csr_write,dut.u_cdc.core_csr_addr,dut.u_cdc.core_csr_wdata}
              ===expected_request,"REQUEST_PAYLOAD");
      if(dut.u_cdc.core_csr_ready)begin
        expected_response={dut.u_cdc.core_csr_error,dut.u_cdc.core_csr_rdata};
        if(dut.u_cdc.core_csr_addr[8])begin
          require(expected_response===expected_snapshot(),"SNAPSHOT_MODEL");
          if(dut.u_cdc.core_csr_write)snapshot_writes[dut.u_cdc.core_csr_addr[7:0]]=1;
          else snapshot_reads[dut.u_cdc.core_csr_addr[7:0]]=1;
          if(dut.u_cdc.core_csr_write&&!dut.u_cdc.core_csr_error)begin
            if(dut.u_cdc.core_csr_wdata==1)begin held=live;held_valid=1;captures++;end
            else begin held='0;held_valid=0;releases++;end
          end
        end
        core_seen=1;core_responses++;
      end
    end
    if(dut.u_cdc.u_csr.tick_accepted)ticks++;
  end
  task automatic send(input bit wr,input logic[8:0] address,input logic[31:0] data);
    @(negedge host_clk);req_valid=1;req_write=wr;req_addr=address;req_wdata=data;
    do @(posedge host_clk);while(!req_ready);
    @(negedge host_clk);req_valid=0;req_write=!wr;req_addr=~address;req_wdata=~data;
  endtask
  task automatic await_response();
    int watchdog;watchdog=0;
    while(!rsp_valid)begin
      @(negedge host_clk);watchdog++;
      if(watchdog>20000)$fatal(1,"RESPONSE_TIMEOUT");
    end
  endtask
  task automatic collect(input bit reject=0,input int hold_cycles=3);
    await_response();sampled=rsp_rdata;
    require(rsp_error==reject,"RESPONSE_ERROR");
    require(interface_busy,"RESPONSE_OWNS_TRANSACTION");
    repeat(hold_cycles)begin
      @(negedge host_clk);require(!req_ready,"READY_DURING_STALL");
    end
    rsp_ready=1;@(posedge host_clk);@(negedge host_clk);rsp_ready=0;
    require(!rsp_valid&&!interface_busy,"RESPONSE_CONSUMED");
  endtask
  task automatic transfer(input bit wr,input logic[8:0] address,
                           input logic[31:0] data,input bit reject=0);
    repeat(int'(random_word()%4))@(negedge host_clk);
    send(wr,address,data);collect(reject,1+int'(random_word()%9));
    if(wr||reject)require(sampled==0,"WRITE_ERROR_DATA");
  endtask
  task automatic read_expect(input logic[8:0] address,input logic[31:0] value);
    transfer(0,address,0);require(sampled===value,"READ_EXPECT");
  endtask
  task automatic reset_dut();
    rst_n_async=0;req_valid=0;rsp_ready=0;#1;
    require(!req_ready&&!rsp_valid&&!interface_busy&&!interface_ready&&
            !host_reset_released&&!core_reset_released&&!protocol_error,"RESET_FLAGS");
    require(rsp_rdata==0&&!rsp_error,"RESET_RESPONSE");
    host_run=1;core_run=1;repeat(3)@(negedge host_clk);
    rst_n_async=1;while(!interface_ready)@(negedge host_clk);
    repeat(12)begin @(negedge host_clk);require(!rsp_valid&&!interface_busy,"RESET_NO_REPLAY");end
    read_expect(9'h0fc,32'h46524701);
    read_expect(9'h108,32'h46524201);
    read_expect(9'h10c,(32'(COUNT_BITS)<<16)|32'(CELLS));
    read_expect(9'h104,0);resets++;
  endtask
  initial begin
    void'($value$plusargs("seed=%d",seed));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64)||COUNT_BITS<1||COUNT_BITS>64)
      $fatal(1,"TEST_PROFILE_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;
    reset_dut();
    // Exhaustive snapshot decode and retained CSR error responses.
    transfer(1,9'h100,1);read_expect(9'h104,1);
    for(int a=0;a<256;a++)begin
      transfer(0,9'(256+a),0,!(a>=4&&a<=116&&a%4==0));
      if(a>=16&&a<=116&&a%4==0)require(sampled==(a==24?39322:0),"INITIAL_SNAPSHOT");
    end
    for(int a=0;a<256;a++)transfer(1,9'(256+a),random_word()|32'h80000000,1);
    for(int bit_id=0;bit_id<32;bit_id++)begin
      transfer(1,9'h1fc,32'd1<<bit_id,1);walking_words++;
      transfer(1,9'h1fc,~(32'd1<<bit_id),1);walking_words++;
    end
    read_expect(9'h108,32'h46524201);
    // Keep valid high; adjacent pairs have identical address/data payloads.
    // Consumer stalls are predeclared by transaction index, independent of clocks.
    fork
      begin : burst_producer
        @(negedge host_clk);
        for(int n=0;n<64;n++)begin
          req_valid=1;req_write=0;req_addr=((n/2)%2)?9'h108:9'h0fc;
          req_wdata=scramble(seed^32'(n/2));
          do @(posedge host_clk);while(!req_ready);
          @(negedge host_clk);
        end
        req_valid=0;
      end
      begin : burst_consumer
        for(int n=0;n<64;n++)begin
          await_response();
          require(!rsp_error&&rsp_rdata==(((n/2)%2)?32'h46524201:32'h46524701),
                  "BURST_RESPONSE_ORDER");
          repeat(1+int'(scramble(seed^32'(n))%11))begin
            @(negedge host_clk);require(!req_ready,"BURST_BACKPRESSURE");
          end
          rsp_ready=1;@(posedge host_clk);@(negedge host_clk);rsp_ready=0;
          require(!rsp_valid,"BURST_RESPONSE_CONSUMED");burst_responses++;
        end
      end
    join
    require(!outstanding&&!interface_busy&&simultaneous==63,"BURST_LEDGER");
    // A response can be consumed with the core stopped; its replacement waits.
    send(0,9'h108,0);await_response();
    @(negedge core_clk);core_run=0;
    @(negedge host_clk);req_valid=1;req_write=0;req_addr=9'h0fc;req_wdata=32'hdeadbeef;
    repeat(9)begin @(negedge host_clk);require(!req_ready&&rsp_valid,"STALLED_REPLACEMENT");end
    rsp_ready=1;#1;require(req_ready,"REPLACEMENT_READY");
    @(posedge host_clk);@(negedge host_clk);req_valid=0;rsp_ready=0;
    repeat(10)begin @(negedge host_clk);require(interface_busy&&!rsp_valid,"STOPPED_CORE");end
    core_run=1;collect();require(sampled==32'h46524701,"REPLACEMENT_RESULT");
    // Complete a request in the core while the host clock is stopped.
    send(0,9'h108,0);repeat(2)@(posedge host_clk);
    @(negedge host_clk);host_run=0;
    repeat(20)@(posedge core_clk);#1;require(core_seen&&!rsp_valid,"STOPPED_HOST");
    host_run=1;collect();require(sampled==32'h46524201,"RESUMED_RESPONSE");
    // Frozen snapshot survives checkpoint loading and ticks in all three modes.
    transfer(1,0,32'h105);transfer(1,9'h06c,0);transfer(1,0,32'h400);
    for(int w=0;w<624;w++)transfer(1,9'h070,random_word()|32'h80000000);
    read_expect(9'h074,624);transfer(1,0,32'h100);
    for(int mode=0;mode<3;mode++)begin
      transfer(1,9'h004,32'(mode));modes_seen[mode]=1;repeat(8)transfer(1,0,1);
    end
    require(ticks==24,"TICK_COUNT");
    for(int w=0;w<26;w++)begin
      read_expect(9'(9'h110+4*w),w==2?39322:0);frozen_reads++;
    end
    transfer(1,9'h100,1);
    read_expect(9'h110,COUNT_BITS<5?32'((64'd1<<COUNT_BITS)-1):24);
    for(int w=0;w<26;w++)transfer(0,9'(9'h110+4*w),0);
    transfer(1,0,2);
    read_expect(9'h110,COUNT_BITS<5?32'((64'd1<<COUNT_BITS)-1):24);
    transfer(1,9'h100,2);transfer(0,9'h110,0,1);
    // Reset discards a request before core delivery.
    @(negedge core_clk);core_run=0;
    send(1,9'h100,1);repeat(4)@(negedge host_clk);reset_dut();
    // Reset also discards an unconsumed completed response with both clocks stopped.
    send(0,9'h108,0);await_response();
    @(negedge core_clk);core_run=0;
    @(negedge host_clk);host_run=0;#2;reset_dut();
    require(requests==responses+aborts&&core_responses==responses+aborts_after_core&&
            forwarded==requests&&!outstanding&&!rsp_valid&&!interface_busy,"LEDGER");
    require(requests==1374&&responses==1372&&core_responses==1373, "TRANSACTION_TOTALS");
    require(aborts==2&&aborts_after_core==1&&simultaneous==64&&stalls>0&&errors==548,
            "SCENARIO_COUNTS");
    require(snapshot_reads==='1&&snapshot_writes==='1&&write_ones==='1&&write_zeros==='1,
            "ADDRESS_DATA_COVERAGE");
    require(captures==2&&releases==1&&resets==3&&modes_seen==7&&
            frozen_reads==26&&walking_words==64&&burst_responses==64,"INTEGRATION_COVERAGE");
    $display("PASS HOST_CDC_STREAM cells=%0d bits=%0d seed=%0d host_half=%0d core_half=%0d phase=%0d checks=%0d requests=%0d forwarded=%0d responses=%0d core_responses=%0d aborts=%0d aborts_after_core=%0d ticks=%0d simultaneous=%0d stalls=%0d errors=%0d snapshot_reads=%0d snapshot_writes=%0d captures=%0d releases=%0d resets=%0d modes=%0d frozen=%0d walking_words=%0d burst_responses=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,host_half,core_half,phase,checks,requests,forwarded,responses,
      core_responses,aborts,aborts_after_core,ticks,simultaneous,stalls,errors,
      $countones(snapshot_reads),$countones(snapshot_writes),captures,releases,resets,
      modes_seen,frozen_reads,walking_words,burst_responses,signature);
    $finish;
  end
  initial begin #20000000;$fatal(1,"WATCHDOG");end
endmodule
`endif

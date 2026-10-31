// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Pending gamma requests across asynchronous host/core clock interruptions.
// Parameters: CELLS=8/16/32/64, COUNT_BITS=1..64.
// Plusargs: +seed=76 +ROUNDS=3 +HOST_HALF=5 +CORE_HALF=7 +PHASE=1.
// Each round loads three independent 624-word MT checkpoints and exercises:
// reset with both clocks stopped during target backpressure; stopped core
// during target backpressure; stopped host until the core completes its tick.
// The request scoreboard checks all 42 bits on every core request edge.
// The response scoreboard checks all 33 bits against the accepting core edge.
// Counts distinguish accepted host requests, core completions, host completions,
// reset-aborted requests and accepted computation ticks. Modes rotate per round.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root to resolve rtl/m31/frp_m31_sin_q30.mem.

`ifndef FRP_M32_INTERNAL_GAMMA_CDC_INTERRUPTION_TB_SV
`define FRP_M32_INTERNAL_GAMMA_CDC_INTERRUPTION_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_top.sv"

module frp_m32_internal_gamma_cdc_interruption_tb #(
  parameter int CELLS=8,
  parameter int COUNT_BITS=64
);
  logic host_clk=0,core_clk=0,rst_n_async=0;
  bit host_run=1,core_run=1;
  int host_half=5,core_half=7,phase_offset=1,rounds=3;
  int unsigned seed=76,rng;
  logic csr_valid=0,csr_write=0;
  logic [8:0] csr_addr=0;
  logic [31:0] csr_wdata=0,csr_rdata,sampled;
  logic csr_ready,csr_error,host_reset_released,core_reset_released;
  logic interface_ready,interface_busy,protocol_error;
  logic invalid_before_ready,invalid_while_busy,invalid_valid_held;
  logic [41:0] request_expected;
  logic [32:0] response_expected;
  bit pending=0,core_done=0;
  int launches=0,completions=0,core_completions=0,host_pulses=0;
  int aborted=0,ticks=0,wait_edges=0,checks=0,checkpoints=0;
  int reset_waits=0,core_stops=0,host_stops=0,resets=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  logic [32:0] last_host_response=0;
  bit last_host_ready=0;
  bit [2:0] reset_modes=0,core_stop_modes=0,host_stop_modes=0;

  frp_m32_internal_gamma_observed_csr_cdc_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)
  ) dut(.*);

  initial begin
    void'($value$plusargs("HOST_HALF=%d",host_half));
    if(host_half<2)$fatal(1,"HOST_HALF_RANGE");
    forever begin #(host_half);if(host_run)host_clk=~host_clk;end
  end
  initial begin
    void'($value$plusargs("CORE_HALF=%d",core_half));
    void'($value$plusargs("PHASE=%d",phase_offset));
    if(core_half<2||phase_offset<0)$fatal(1,"CORE_CLOCK_RANGE");
    #(phase_offset);
    forever begin #(core_half);if(core_run)core_clk=~core_clk;end
  end

  function automatic logic [31:0] random_word();
    rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
    return rng;
  endfunction
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
  task automatic equal_word(input logic [31:0] actual,expected,input string label);
    if(actual!==expected)$fatal(1,"%s actual=%h expected=%h time=%t",label,actual,expected,$time);
    checks++;mix({expected,actual});
  endtask
  task automatic protocol_clear();
    equal_word({28'd0,protocol_error,invalid_before_ready,invalid_while_busy,invalid_valid_held},
               0,"PROTOCOL_FLAGS");
  endtask

  always @(posedge core_clk) begin
    if(rst_n_async)begin
      if(dut.core_csr_valid)begin
        if(!pending||core_done)$fatal(1,"UNREQUESTED_CORE_TRANSFER");
        if({dut.core_csr_write,dut.core_csr_addr,dut.core_csr_wdata}!==request_expected)
          $fatal(1,"CORE_PAYLOAD");
        if(dut.core_csr_ready)begin
          response_expected={dut.core_csr_error,dut.core_csr_rdata};
          core_done=1;core_completions++;
        end else wait_edges++;
      end
      if(dut.u_csr.tick_accepted)ticks++;
    end
  end
  always @(posedge host_clk or negedge rst_n_async) begin
    if(!rst_n_async)begin last_host_response=0;last_host_ready=0;end
    else begin
      if(csr_ready)host_pulses++;
      #1;
      if(rst_n_async)begin
        if(csr_ready&&last_host_ready)$fatal(1,"REPEATED_HOST_RESPONSE");
        if(!csr_ready&&{csr_error,csr_rdata}!==last_host_response)
          $fatal(1,"RESPONSE_NOT_RETAINED");
        if(csr_ready&&!core_done)$fatal(1,"RESPONSE_BEFORE_CORE_COMPLETION");
        last_host_response={csr_error,csr_rdata};last_host_ready=csr_ready;
      end
    end
  end

  task automatic disturb_inputs();
    csr_write=~csr_write;csr_addr=~csr_addr;csr_wdata=random_word();
  endtask
  task automatic launch(input bit wr,input logic [8:0] address,input logic [31:0] data);
    @(negedge host_clk);
    if(!interface_ready||interface_busy||pending)$fatal(1,"DRIVER_NOT_IDLE");
    request_expected={wr,address,data};pending=1;core_done=0;
    csr_valid=1;csr_write=wr;csr_addr=address;csr_wdata=data;
    launches++;mix({22'd0,request_expected});
    @(posedge host_clk);#1;
    equal_word({30'd0,interface_busy,csr_ready},2,"HOST_ACCEPT");
    @(negedge host_clk);csr_valid=0;disturb_inputs();
  endtask
  task automatic finish_response();
    int watchdog;
    watchdog=0;
    while(!csr_ready)begin
      @(posedge host_clk);#1;watchdog++;
      if(watchdog>30000)$fatal(1,"HOST_RESPONSE_TIMEOUT");
    end
    if(!pending||!core_done)$fatal(1,"MISSING_CORE_COMPLETION");
    if({csr_error,csr_rdata}!==response_expected)$fatal(1,"RESPONSE_PAYLOAD");
    equal_word({30'd0,interface_busy,csr_error},0,"RESPONSE_STATUS");
    sampled=csr_rdata;mix({31'd0,response_expected});
    pending=0;completions++;
    @(posedge host_clk);#1;
    equal_word({31'd0,csr_ready},0,"HOST_RESPONSE_PULSE");
    protocol_clear();
  endtask
  task automatic transfer(input bit wr,input logic [8:0] address,input logic [31:0] data);
    repeat(int'(random_word()&1))@(negedge host_clk);
    launch(wr,address,data);finish_response();
    if(wr)equal_word(sampled,0,"WRITE_RESPONSE");
  endtask
  task automatic expect_read(input logic [8:0] address,input logic [31:0] expected);
    transfer(0,address,0);equal_word(sampled,expected,"READ_VALUE");
  endtask

  task automatic reset_and_recover();
    if(pending)begin
      if(core_done)$fatal(1,"RESET_EXPECTED_DURING_WAIT");
      aborted++;
    end
    rst_n_async=0;csr_valid=0;pending=0;core_done=0;
    // Check asynchronous assertion before restarting either stopped clock.
    #2;
    equal_word({24'd0,interface_ready,interface_busy,csr_ready,csr_error,
      host_reset_released,core_reset_released,protocol_error,invalid_valid_held},0,"ASYNC_RESET");
    equal_word(csr_rdata,0,"RESET_DATA");protocol_clear();
    host_run=1;core_run=1;
    repeat(4)@(negedge host_clk);
    rst_n_async=1;
    while(!interface_ready)begin @(posedge host_clk);#1;end
    repeat(12)begin
      @(posedge host_clk);#1;
      if(csr_ready||interface_busy)$fatal(1,"STALE_AFTER_RESET");
    end
    expect_read(9'h0fc,32'h46524701);
    expect_read(9'h108,32'h46524201);
    expect_read(9'h10c,(32'(COUNT_BITS)<<16)|32'(CELLS));
    expect_read(9'h104,0);
    transfer(1,9'h100,1);
    expect_read(9'h110,0);expect_read(9'h114,0);
    expect_read(9'h118,39322);
    resets++;
  endtask
  task automatic configure(input int mode);
    transfer(1,0,32'h100);transfer(1,9'h004,32'(mode));
    transfer(1,0,32'h105);transfer(1,9'h06c,624);transfer(1,0,32'h400);
    for(int w=0;w<624;w++)transfer(1,9'h070,random_word()|32'h80000000);
    expect_read(9'h074,624);transfer(1,0,32'h100);checkpoints++;
  endtask
  task automatic wait_for_gamma();
    int watchdog;
    watchdog=0;
    while(!(dut.core_csr_valid&&!dut.core_csr_ready))begin
      @(negedge core_clk);watchdog++;
      if(core_done||csr_ready||watchdog>1000)$fatal(1,"GAMMA_WAIT_NOT_REACHED");
    end
    if(!dut.u_csr.gamma_source_busy||!pending||!interface_busy||core_done)
      $fatal(1,"GAMMA_WAIT_PRECONDITION");
    @(negedge core_clk);
    if(dut.core_csr_ready||core_done)$fatal(1,"GAMMA_WAIT_ENDED_EARLY");
  endtask
  task automatic pending_unchanged(input int tick_before);
    equal_word(32'(ticks),32'(tick_before),"NO_TICK_WHILE_STOPPED");
    if(!pending||core_done||!interface_busy||csr_ready||!dut.core_csr_valid||dut.core_csr_ready)
      $fatal(1,"PENDING_NOT_RETAINED");
    if(dut.held_request_debug!==request_expected)$fatal(1,"HELD_REQUEST_CHANGED");
    protocol_clear();
  endtask
  task automatic expect_one_sample();
    // Allow the recorder's accepted-tick/stability pipeline to settle.
    repeat(8)@(negedge core_clk);
    transfer(1,9'h100,1);
    expect_read(9'h110,1);expect_read(9'h114,0);
    transfer(0,9'h104,0);
    equal_word(sampled&32'h27,3,"RECORDER_FLAGS");
  endtask

  initial begin : stimulus
    int tick_before,completion_before,mode,pause_length;
    logic [32:0] frozen_response;
    void'($value$plusargs("seed=%d",seed));
    void'($value$plusargs("ROUNDS=%d",rounds));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64)||
       COUNT_BITS<1||COUNT_BITS>64||rounds<1||rounds>16)$fatal(1,"PROFILE_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;mix({32'd0,seed});
    reset_and_recover();
    for(int round_id=0;round_id<rounds;round_id++)begin
      for(int scenario=0;scenario<3;scenario++)begin
        mode=(round_id+scenario)%3;
        configure(mode);
        tick_before=ticks;completion_before=core_completions;
        launch(1,0,1);wait_for_gamma();
        pause_length=24+int'(random_word()%41);
        if(scenario==0)begin
          core_run=0;
          @(negedge host_clk);host_run=0;
          #(host_half*pause_length);
          pending_unchanged(tick_before);
          reset_waits++;reset_modes[mode]=1;
          reset_and_recover();
          equal_word(32'(ticks),32'(tick_before),"RESET_CANCELS_WAITING_TICK");
          equal_word(32'(core_completions),32'(completion_before+8),"RESET_RECOVERY_TRANSFERS");
        end else if(scenario==1)begin
          core_run=0;
          repeat(pause_length)begin
            @(negedge host_clk);disturb_inputs();pending_unchanged(tick_before);
          end
          core_run=1;finish_response();
          equal_word(32'(ticks),32'(tick_before+1),"CORE_RESUME_ONE_TICK");
          expect_one_sample();core_stops++;core_stop_modes[mode]=1;
          reset_and_recover();
        end else begin
          @(negedge host_clk);host_run=0;
          begin : await_core
            int watchdog;
            watchdog=0;
            while(!core_done)begin
              @(negedge core_clk);watchdog++;
              if(watchdog>10000)$fatal(1,"STOPPED_HOST_CORE_TIMEOUT");
            end
          end
          frozen_response=dut.held_response_debug;
          repeat(pause_length)begin
            @(negedge core_clk);
            if(csr_ready||!interface_busy||dut.held_response_debug!==frozen_response)
              $fatal(1,"STOPPED_HOST_RESPONSE_CHANGED");
          end
          equal_word(32'(ticks),32'(tick_before+1),"HOST_STOP_ONE_TICK");
          host_run=1;finish_response();expect_one_sample();
          host_stops++;host_stop_modes[mode]=1;reset_and_recover();
        end
      end
    end
    if(launches!=completions+aborted||core_completions!=completions||host_pulses!=completions)
      $fatal(1,"TRANSACTION_ACCOUNTING");
    if(aborted!=rounds||reset_waits!=rounds||core_stops!=rounds||host_stops!=rounds||
       checkpoints!=3*rounds||ticks!=2*rounds||resets!=1+3*rounds||wait_edges==0)
      $fatal(1,"SCENARIO_ACCOUNTING");
    if(rounds>=3&&(reset_modes!=3'b111||core_stop_modes!=3'b111||host_stop_modes!=3'b111))
      $fatal(1,"MODE_COVERAGE");
    $display("PASS GAMMA_CDC_INTERRUPTION cells=%0d bits=%0d seed=%0d rounds=%0d host_half=%0d core_half=%0d phase=%0d checks=%0d launches=%0d completions=%0d core_completions=%0d aborted=%0d ticks=%0d checkpoints=%0d reset_waits=%0d core_stops=%0d host_stops=%0d resets=%0d wait_edges=%0d reset_modes=%0h core_modes=%0h host_modes=%0h signature=%016h",
      CELLS,COUNT_BITS,seed,rounds,host_half,core_half,phase_offset,checks,launches,completions,
      core_completions,aborted,ticks,checkpoints,reset_waits,core_stops,host_stops,resets,wait_edges,
      reset_modes,core_stop_modes,host_stop_modes,signature);
    $finish;
  end
  initial begin #50000000;$fatal(1,"WATCHDOG");end
endmodule : frp_m32_internal_gamma_cdc_interruption_tb
`endif

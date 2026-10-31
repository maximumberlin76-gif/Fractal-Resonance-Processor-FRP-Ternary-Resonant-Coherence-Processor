// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Gamma checkpoint validation, restart and recovery through the nine-bit CDC CSR.
// Parameters: CELLS=8/16/32/64, COUNT_BITS=1..64.
// Plusargs: +seed=76 +HOST_HALF=5 +CORE_HALF=7 +PHASE=1.
// Exercise invalid gamma-page reads/writes, rejected indices, incomplete loads,
// all-zero rejection, a nonzero final word, restart during MT twist, staged-index
// isolation, extra-word rejection, cadence preservation and frozen snapshots.
// Reference checkpoints use index 0: zero words yield -65536 in Q16.16;
// first word 0x80000000 followed by zeros yields first target 4128, then -65536.
// These values follow CPython random.Random.setstate/uniform and half-away
// Q16.16 quantization; checks inspect the bank presented at gamma acceptance.
// Request/response scoreboards also check every transferred payload and count.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root for rtl/m31/frp_m31_sin_q30.mem.

`ifndef FRP_M32_GAMMA_CHECKPOINT_CDC_TB_SV
`define FRP_M32_GAMMA_CHECKPOINT_CDC_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_top.sv"

module frp_m32_gamma_checkpoint_cdc_tb #(
  parameter int CELLS=8,
  parameter int COUNT_BITS=64
);
  logic host_clk=0,core_clk=0,rst_n_async=0;
  bit host_run=1,core_run=1;
  int host_half=5,core_half=7,phase_offset=1;
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
  int ticks=0,epoch_ticks=0,updates=0,wait_edges=0,checks=0,resets=0;
  int errors=0,begins=0,words=0,partial_words=0,busy_aborts=0;
  int oracle_profile=0,bank_checks=0,frozen_reads=0;
  logic [31:0] frozen [0:26];
  localparam logic [COUNT_BITS-1:0] COUNT_MAX='1;
  bit [2:0] modes_seen=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  logic [32:0] last_host_response=0;
  bit last_host_ready=0;

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
      if(dut.u_csr.gamma_update_accepted!==
         (dut.u_csr.tick_accepted&&(epoch_ticks%8==0)))$fatal(1,"GAMMA_CADENCE");
      if(dut.u_csr.gamma_update_accepted)begin
        if(oracle_profile==0)$fatal(1,"UPDATE_WITHOUT_VALID_CHECKPOINT");
        for(int cell_id=0;cell_id<CELLS;cell_id++)
          if(dut.u_csr.u_core.source_targets_q16[cell_id*32+:32]!==
             (oracle_profile==2&&cell_id==0?32'd4128:32'hffff0000))
            $fatal(1,"GAMMA_TARGET_ORACLE");
        updates++;
      end
      if(dut.u_csr.tick_accepted)begin ticks++;epoch_ticks++;end
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
  task automatic finish_response(input bit reject=0);
    int watchdog;
    watchdog=0;
    while(!csr_ready)begin
      @(posedge host_clk);#1;watchdog++;
      if(watchdog>30000)$fatal(1,"HOST_RESPONSE_TIMEOUT");
    end
    if(!pending||!core_done)$fatal(1,"MISSING_CORE_COMPLETION");
    if({csr_error,csr_rdata}!==response_expected)$fatal(1,"RESPONSE_PAYLOAD");
    equal_word({30'd0,interface_busy,csr_error},{31'd0,reject},"RESPONSE_STATUS");
    if(csr_error)errors++;
    sampled=csr_rdata;mix({31'd0,response_expected});
    pending=0;completions++;
    @(posedge host_clk);#1;
    equal_word({31'd0,csr_ready},0,"HOST_RESPONSE_PULSE");
    protocol_clear();
  endtask
  task automatic transfer(input bit wr,input logic [8:0] address,input logic [31:0] data,input bit reject=0);
    repeat(int'(random_word()&1))@(negedge host_clk);
    launch(wr,address,data);finish_response(reject);
    if(wr||reject)equal_word(sampled,0,"WRITE_RESPONSE");
  endtask
  task automatic expect_read(input logic [8:0] address,input logic [31:0] expected);
    transfer(0,address,0);equal_word(sampled,expected,"READ_VALUE");
  endtask

  task automatic reset_and_recover();
    if(pending)$fatal(1,"RESET_DRIVER_PENDING");
    epoch_ticks=0;oracle_profile=0;
    rst_n_async=0;csr_valid=0;pending=0;core_done=0;
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
  task automatic status(input logic [31:0] mask,expected);
    transfer(0,9'h068,0);equal_word(sampled&mask,expected,"GAMMA_STATUS");
  endtask
  task automatic begin_load();
    transfer(1,0,32'h400);begins++;
    expect_read(9'h074,0);status(32'h47,5);
  endtask
  task automatic load_word(input logic [31:0] value);
    transfer(1,9'h070,value);words++;
  endtask
  task automatic await_bank(input int profile);
    int watchdog;
    watchdog=0;
    while(!dut.u_csr.gamma_bank_valid)begin
      @(negedge core_clk);watchdog++;
      if(watchdog>2000)$fatal(1,"BANK_TIMEOUT");
    end
    for(int cell_id=0;cell_id<CELLS;cell_id++)begin
      equal_word(dut.u_csr.u_core.source_targets_q16[cell_id*32+:32],
                 profile==2&&cell_id==0?32'd4128:32'hffff0000,"BANK_ORACLE");
      bank_checks++;
    end
  endtask
  task automatic run_ticks(input int count);
    for(int t=0;t<count;t++)begin
      transfer(1,9'h004,32'(t%3));modes_seen[t%3]=1;
      transfer(1,0,1);
    end
  endtask
  task automatic capture_frozen();
    transfer(1,9'h100,1);
    transfer(0,9'h104,0);frozen[26]=sampled;
    for(int w=0;w<26;w++)begin
      transfer(0,9'(9'h110+4*w),0);frozen[w]=sampled;
    end
  endtask
  task automatic check_frozen();
    expect_read(9'h104,frozen[26]);
    for(int w=0;w<26;w++)begin
      expect_read(9'(9'h110+4*w),frozen[w]);frozen_reads++;
    end
  endtask

  initial begin : stimulus
    void'($value$plusargs("seed=%d",seed));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64)||COUNT_BITS<1||COUNT_BITS>64)
      $fatal(1,"PROFILE_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;mix({32'd0,seed});
    reset_and_recover();
    transfer(1,0,32'h105);
    expect_read(9'h0fc,32'h46524705);expect_read(9'h078,624);expect_read(9'h07c,8);
    status(32'h747,1);transfer(1,0,1,1);
    // All gamma-page byte addresses; no valid checkpoint is loaded yet.
    for(int a=104;a<256;a++)begin
      transfer(0,9'(a),0,!(a==104||a==108||a==116||a==120||a==124||a==252));
      transfer(1,9'(a),32'hffffffff,1);
    end
    transfer(1,9'h06c,0);
    for(int n=0;n<4;n++)begin
      case(n)
        0:transfer(1,9'h06c,625,1);
        1:transfer(1,9'h06c,1023,1);
        2:transfer(1,9'h06c,1024,1);
        3:transfer(1,9'h06c,32'hffffffff,1);
      endcase
      expect_read(9'h06c,0);
    end
    begin_load();
    for(int w=0;w<624;w++)load_word(0);
    expect_read(9'h074,624);status(32'h47,65);
    transfer(1,9'h070,1,1);transfer(1,0,1,1);
    equal_word(32'(ticks),0,"ZERO_CHECKPOINT_BLOCKS_TICKS");
    // Restart a partial load, then abort a newly started twist.
    transfer(1,9'h06c,624);begin_load();
    for(int w=0;w<17;w++)begin load_word(random_word());partial_words++;end
    expect_read(9'h074,17);status(32'h47,5);transfer(1,0,1,1);
    begin_load();
    for(int w=0;w<624;w++)begin
      load_word(w==623?1:0);
      if(w==127)transfer(1,9'h06c,0);
    end
    if(!dut.u_csr.gamma_source_busy)$fatal(1,"TWIST_ABORT_PRECONDITION");
    begin_load();busy_aborts++;status(32'h5f,5);
    transfer(1,0,1,1);equal_word(32'(ticks),0,"ABORTED_PREFETCH_NO_TICK");
    // Staging 624 during this load must leave its latched index at zero.
    for(int w=0;w<624;w++)begin
      load_word(w==623?1:0);
      if(w==127)transfer(1,9'h06c,624);
      if(w==622)begin
        expect_read(9'h074,623);status(32'h47,5);transfer(1,0,1,1);
      end
    end
    oracle_profile=1;await_bank(1);expect_read(9'h074,624);status(32'h47,3);
    transfer(1,9'h070,32'hdeadbeef,1);expect_read(9'h074,624);
    run_ticks(9);
    equal_word(32'(ticks),9,"INITIAL_TICKS");equal_word(32'(updates),2,"INITIAL_UPDATES");
    capture_frozen();
    equal_word(frozen[0],64'(COUNT_MAX)<9?32'(COUNT_MAX):9,"RECORDER_COUNT");
    transfer(1,0,2);status(32'h700,32'h100);check_frozen();
    // Reload preserves cadence and held recorder data while replacing the bank.
    transfer(1,9'h06c,0);begin_load();status(32'h700,32'h100);check_frozen();
    for(int w=0;w<624;w++)load_word(w==0?32'h80000000:0);
    oracle_profile=2;await_bank(2);status(32'h747,32'h103);check_frozen();
    transfer(1,9'h070,0,1);expect_read(9'h074,624);
    run_ticks(8);
    equal_word(32'(ticks),17,"TOTAL_TICKS");equal_word(32'(updates),3,"RELOAD_CADENCE");
    check_frozen();capture_frozen();
    equal_word(frozen[0],64'(COUNT_MAX)<17?32'(COUNT_MAX):17,"RECORDER_RETAINED");
    // Reset an incomplete replacement and require a fresh checkpoint afterward.
    begin_load();
    for(int w=0;w<9;w++)begin load_word(random_word());partial_words++;end
    reset_and_recover();transfer(1,0,32'h105);
    expect_read(9'h074,0);expect_read(9'h06c,624);status(32'h747,1);
    transfer(1,9'h070,1,1);transfer(1,0,1,1);protocol_clear();
    if(launches!=completions||core_completions!=completions||host_pulses!=completions)
      $fatal(1,"TRANSACTION_ACCOUNTING");
    if(ticks!=17||updates!=3||begins!=6||words!=2522||partial_words!=26||
       busy_aborts!=1||bank_checks!=2*CELLS||frozen_reads!=104||modes_seen!=3'b111||resets!=2)
      $fatal(1,"SCENARIO_ACCOUNTING");
    $display("PASS GAMMA_CHECKPOINT_CDC cells=%0d bits=%0d seed=%0d host_half=%0d core_half=%0d phase=%0d checks=%0d launches=%0d completions=%0d errors=%0d ticks=%0d updates=%0d begins=%0d words=%0d partial_words=%0d busy_aborts=%0d bank_checks=%0d frozen=%0d resets=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,host_half,core_half,phase_offset,checks,launches,completions,errors,
      ticks,updates,begins,words,partial_words,busy_aborts,bank_checks,frozen_reads,resets,signature);
    $finish;
  end
  initial begin #50000000;$fatal(1,"WATCHDOG");end
endmodule : frp_m32_gamma_checkpoint_cdc_tb
`endif

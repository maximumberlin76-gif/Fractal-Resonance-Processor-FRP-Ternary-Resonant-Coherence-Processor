// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Reset and clock-interruption qualification of the real gamma CDC stream top.
// Eight transaction cut points, held-valid boot with either clock stopped,
// and cancellation/resumption of a tick waiting for a checkpoint-derived bank.
// Public handshakes drive a 42-bit request / 33-bit response ledger; hierarchy
// is read-only and is used to identify transport stages and accepted ticks.
// CELLS=8/16/32/64; COUNT_BITS=1..64; +seed=76 +ROUNDS=3 (1..16).
// +HOST_HALF=5 +CORE_HALF=7 +PHASE=1 (ns; half periods >=2, phase >=0).
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root to resolve the sine LUT.
`ifndef FRP_M32_INTERNAL_GAMMA_CDC_STREAM_INTERRUPTION_TB_SV
`define FRP_M32_INTERNAL_GAMMA_CDC_STREAM_INTERRUPTION_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_stream_top.sv"
module frp_m32_internal_gamma_cdc_stream_interruption_tb #(parameter int CELLS=8, COUNT_BITS=64);
  logic host_clk=0,core_clk=0,rst_n_async=1,host_run=1,core_run=1;
  int host_half=5,core_half=7,phase=1,rounds=3;
  logic req_valid=0,req_write=0,rsp_ready=0;
  logic [8:0] req_addr=0;
  logic [31:0] req_wdata=0;
  wire req_ready,rsp_valid,rsp_error;
  wire [31:0] rsp_rdata;
  wire host_reset_released,core_reset_released,interface_ready,interface_busy;
  wire protocol_error,invalid_before_ready,invalid_while_busy,invalid_valid_held;
  logic [41:0] expected_request='0;
  logic [32:0] expected_response='0,held_response='0;
  bit outstanding=0,issued=0,core_seen=0,published_seen=0,was_stalled=0;
  int requests=0,forwarded=0,core_responses=0,published=0,responses=0;
  int aborts=0,abort_issued=0,abort_core=0,dropped=0,resets=0;
  int checks=0,stalls=0,simultaneous=0,ticks=0,errors=0;
  int cuts[8]='{default:0};
  int early_offers=0,gamma_waits=0,checkpoint_words=0;
  int unsigned seed=76,rng;
  logic [31:0] sampled;
  logic [63:0] signature=64'hcbf29ce484222325;
  frp_m32_internal_gamma_observed_csr_cdc_stream_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) dut(.*);
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
  function automatic logic [31:0] random_word();
    rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);return rng;
  endfunction
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
  task automatic require(input logic ok,input string label);
    if(ok!==1'b1)$fatal(1,"%s t=%t req=%0d rsp=%0d",label,$time,requests,responses);
    checks++;
  endtask
  always @(negedge rst_n_async)begin
    resets++;
    if(outstanding)begin
      aborts++;if(issued)abort_issued++;if(core_seen)abort_core++;
      if(published_seen)dropped++;
    end
    outstanding=0;issued=0;core_seen=0;published_seen=0;was_stalled=0;
  end
  always @(posedge host_clk)if(rst_n_async&&host_reset_released)begin : host_monitor
    bit had_response;
    had_response=rsp_valid;
    if(was_stalled)require(rsp_valid&&{rsp_error,rsp_rdata}===held_response,"HELD_RESPONSE");
    was_stalled=rsp_valid&&!rsp_ready;held_response={rsp_error,rsp_rdata};
    if(was_stalled)stalls++;
    if(rsp_valid)begin
      require(outstanding&&core_seen&&published_seen,"UNEXPECTED_RESPONSE");
      require({rsp_error,rsp_rdata}===expected_response,"RESPONSE_PAYLOAD");
    end
    if(rsp_valid&&rsp_ready)begin
      mix({31'd0,rsp_error,rsp_rdata});responses++;if(rsp_error)errors++;
      outstanding=0;issued=0;core_seen=0;published_seen=0;
      if(req_valid&&req_ready)simultaneous++;
    end
    if(req_valid&&req_ready)begin
      require(!outstanding,"OVERLAPPING_REQUEST");
      outstanding=1;issued=0;core_seen=0;published_seen=0;
      expected_request={req_write,req_addr,req_wdata};requests++;
      mix({22'd0,expected_request});
    end
    if(dut.bridge_valid)begin
      require(outstanding&&!issued&&{dut.request_write_q,dut.request_addr_q,dut.request_wdata_q}
              ===expected_request,"CDC_ISSUE_PAYLOAD");
      issued=1;forwarded++;
    end
    #1;
    if(rst_n_async&&host_reset_released)begin
      require(!protocol_error&&!invalid_before_ready&&!invalid_while_busy&&!invalid_valid_held,
              "PROTOCOL_FLAGS");
      if(!had_response&&rsp_valid)begin
        require(outstanding&&core_seen&&!published_seen,"UNEXPECTED_PUBLICATION");
        require({rsp_error,rsp_rdata}===expected_response,"PUBLICATION_PAYLOAD");
        published_seen=1;published++;
      end
    end
  end
  always @(posedge core_clk)if(rst_n_async)begin
    if(dut.u_cdc.core_csr_valid)begin
      require(outstanding&&issued&&!core_seen,"UNREQUESTED_CORE_TRANSFER");
      require({dut.u_cdc.core_csr_write,dut.u_cdc.core_csr_addr,dut.u_cdc.core_csr_wdata}
              ===expected_request,"REQUEST_PAYLOAD");
      if(dut.u_cdc.core_csr_ready)begin
        expected_response={dut.u_cdc.core_csr_error,dut.u_cdc.core_csr_rdata};
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
  task automatic collect(input bit reject=0);
    await_response();sampled=rsp_rdata;require(rsp_error==reject,"RESPONSE_ERROR");
    repeat(1+int'(random_word()%5))begin
      @(negedge host_clk);require(!req_ready&&interface_busy,"READY_DURING_STALL");
    end
    rsp_ready=1;@(posedge host_clk);@(negedge host_clk);rsp_ready=0;
    require(!rsp_valid&&!interface_busy,"RESPONSE_CONSUMED");
  endtask
  task automatic transfer(input bit wr,input logic[8:0] address,
                          input logic[31:0] data,input bit reject=0);
    send(wr,address,data);collect(reject);
    if(wr||reject)require(sampled==0,"WRITE_ERROR_DATA");
  endtask
  task automatic read_expect(input logic[8:0] address,input logic[31:0] value);
    transfer(0,address,0);require(sampled===value,"READ_EXPECT");
  endtask
  task automatic assert_reset();
    rst_n_async=0;req_valid=0;rsp_ready=0;#1;
    require(!req_ready&&!rsp_valid&&!interface_busy&&!interface_ready&&
            !host_reset_released&&!core_reset_released&&!protocol_error&&
            !invalid_before_ready&&!invalid_while_busy&&!invalid_valid_held,"ASYNC_RESET_FLAGS");
    require(rsp_rdata==0&&!rsp_error&&!dut.u_cdc.core_csr_valid,"ASYNC_RESET_PAYLOAD");
  endtask
  task automatic check_recovery();
    while(!interface_ready)@(negedge host_clk);
    repeat(12)begin
      @(negedge host_clk);
      require(req_ready&&!rsp_valid&&!interface_busy&&!dut.u_cdc.core_csr_valid,"STALE_AFTER_RESET");
    end
    read_expect(9'h0fc,32'h46524701);
    read_expect(9'h108,32'h46524201);
    read_expect(9'h10c,(32'(COUNT_BITS)<<16)|32'(CELLS));
    read_expect(9'h104,0);
  endtask
  task automatic reset_recover();
    assert_reset();host_run=1;core_run=1;
    repeat(3)@(negedge host_clk);rst_n_async=1;check_recovery();
  endtask
  task automatic await_issue();
    while(!issued)@(negedge host_clk);
  endtask
  task automatic stop_host_after_issue();
    await_issue();host_run=0;
  endtask
  task automatic cut_transaction(input int stage);
    int before_requests;
    case(stage)
      0:begin
        send(1,9'h100,1);require(outstanding&&!issued,"CUT_BEFORE_ISSUE");
      end
      1:begin
        @(negedge core_clk);core_run=0;send(1,9'h100,1);await_issue();
        require(issued&&!core_seen&&!dut.u_cdc.core_csr_valid,"CUT_BEFORE_DELIVERY");
      end
      2:begin
        @(negedge core_clk);core_run=0;send(1,9'h100,1);stop_host_after_issue();
        core_run=1;
        while(!dut.u_cdc.core_csr_valid)@(negedge core_clk);
        core_run=0;require(!core_seen,"CUT_BEFORE_TARGET_ACCEPT");
      end
      3:begin
        @(negedge core_clk);core_run=0;send(1,9'h100,1);stop_host_after_issue();
        core_run=1;
        while(!core_seen)@(negedge core_clk);
        require(!rsp_valid&&core_seen,"CUT_CORE_RESPONSE");
      end
      4:begin
        send(1,9'h100,1);
        while(!dut.bridge_done)@(negedge host_clk);
        require(core_seen&&!rsp_valid&&!published_seen,"CUT_BRIDGE_DONE");
      end
      5:begin
        send(0,9'h108,0);await_response();
        @(negedge host_clk);host_run=0;@(negedge core_clk);core_run=0;
        require(published_seen&&!rsp_error&&rsp_rdata==32'h46524201,"CUT_BUFFERED_SUCCESS");
      end
      6:begin
        send(0,9'h1ff,0);await_response();before_requests=requests;
        require(published_seen&&rsp_error&&rsp_rdata==0,"CUT_BUFFERED_ERROR");
        req_valid=1;req_write=1;req_addr=9'h100;req_wdata=1;
        repeat(7)begin
          @(negedge host_clk);
          require(!req_ready&&requests==before_requests&&rsp_valid,"UNACCEPTED_OFFER");
        end
      end
      7:begin
        send(0,9'h108,0);await_response();before_requests=requests;
        req_valid=1;req_write=1;req_addr=9'h100;req_wdata=1;rsp_ready=1;
        @(posedge host_clk);require(req_ready&&rsp_valid,"REPLACEMENT_HANDSHAKE");
        @(negedge host_clk);req_valid=0;rsp_ready=0;
        require(requests==before_requests+1&&outstanding&&!issued&&!rsp_valid,"CUT_REPLACEMENT");
      end
      default:$fatal(1,"CUT_RANGE");
    endcase
    cuts[stage]++;reset_recover();
  endtask
  task automatic early_offer(input bit stop_core);
    int before_requests;
    assert_reset();host_run=1;core_run=1;
    repeat(3)@(negedge host_clk);
    if(stop_core)begin @(negedge core_clk);core_run=0;end
    else begin @(negedge host_clk);host_run=0;end
    req_valid=1;req_write=0;req_addr=9'h108;req_wdata=0;
    before_requests=requests;rst_n_async=1;
    if(stop_core)repeat(8)@(negedge host_clk);
    else repeat(8)@(negedge core_clk);
    require(!req_ready&&!interface_ready&&!rsp_valid&&requests==before_requests,"EARLY_OFFER_BLOCKED");
    host_run=1;core_run=1;
    do @(posedge host_clk);while(!req_ready);
    @(negedge host_clk);req_valid=0;
    require(requests==before_requests+1,"EARLY_OFFER_ONCE");
    collect();require(sampled==32'h46524201,"EARLY_OFFER_DATA");
    early_offers++;check_recovery();
  endtask
  task automatic load_checkpoint();
    transfer(1,0,32'h105);transfer(1,9'h06c,624);transfer(1,0,32'h400);
    for(int word_index=0;word_index<624;word_index++)begin
      transfer(1,9'h070,random_word()|32'h80000000);checkpoint_words++;
    end
    read_expect(9'h074,624);transfer(1,0,32'h100);
  endtask
  task automatic gamma_interruption(input bit resume_tick);
    int before_ticks,before_requests;
    load_checkpoint();before_ticks=ticks;send(1,0,1);
    while(!dut.u_cdc.core_csr_valid)@(negedge core_clk);
    require(!dut.u_cdc.core_csr_ready&&!core_seen,"GAMMA_WAIT_REACHED");
    core_run=0;gamma_waits++;
    repeat(9)begin
      @(negedge host_clk);
      require(interface_busy&&!req_ready&&!rsp_valid&&ticks==before_ticks,"GAMMA_CLOCK_STOP");
      require(dut.u_cdc.core_csr_valid&&
              {dut.u_cdc.core_csr_write,dut.u_cdc.core_csr_addr,dut.u_cdc.core_csr_wdata}
              ==={1'b1,9'd0,32'd1},"GAMMA_PENDING_PAYLOAD");
    end
    if(resume_tick)begin
      core_run=1;await_response();require(ticks==before_ticks+1&&!rsp_error,"GAMMA_RESUME_ONCE");
      before_requests=requests;req_valid=1;req_write=1;req_addr=0;req_wdata=1;
      repeat(9)begin
        @(negedge host_clk);
        require(!req_ready&&requests==before_requests&&ticks==before_ticks+1,"GAMMA_NO_REPLAY");
      end
    end else require(ticks==before_ticks,"GAMMA_CANCEL_BEFORE_TICK");
    @(negedge host_clk);host_run=0;
    if(core_run)begin @(negedge core_clk);core_run=0;end
    reset_recover();transfer(1,0,1,1);
    require(ticks==before_ticks+int'(resume_tick),"RESET_DISCARDS_GAMMA_BANK");
  endtask
  initial begin
    void'($value$plusargs("seed=%d",seed));void'($value$plusargs("ROUNDS=%d",rounds));
    if(rounds<1||rounds>16)$fatal(1,"ROUNDS_RANGE");
    rng=seed^32'h9e3779b9;if(rng==0)rng=1;
    #2;reset_recover();
    for(int round_index=0;round_index<rounds;round_index++)
      for(int stage=0;stage<8;stage++)cut_transaction(stage);
    early_offer(1);early_offer(0);gamma_interruption(0);gamma_interruption(1);
    repeat(12)@(negedge host_clk);
    require(!outstanding&&!rsp_valid&&!interface_busy&&!dut.u_cdc.core_csr_valid,"FINAL_IDLE");
    require(requests==responses+aborts&&forwarded==responses+abort_issued&&
            core_responses==responses+abort_core&&published==responses+dropped,"TRANSACTION_LEDGER");
    for(int stage=0;stage<8;stage++)require(cuts[stage]==rounds,"CUT_COVERAGE");
    require(aborts==8*rounds+2&&abort_issued==6*rounds+2&&abort_core==4*rounds+1&&
            dropped==2*rounds+1&&simultaneous==rounds,"ABORT_COVERAGE");
    require(resets==8*rounds+5&&early_offers==2&&gamma_waits==2&&
            checkpoint_words==1248&&ticks==1&&errors==2&&stalls>0,"RECOVERY_COVERAGE");
    $display("PASS STREAM_RECOVERY cells=%0d bits=%0d seed=%0d host_half=%0d core_half=%0d phase=%0d rounds=%0d checks=%0d requests=%0d forwarded=%0d core_responses=%0d published=%0d responses=%0d aborts=%0d abort_issued=%0d abort_core=%0d dropped=%0d resets=%0d simultaneous=%0d stalls=%0d ticks=%0d errors=%0d cuts=%0d early_offers=%0d gamma_waits=%0d checkpoint_words=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,host_half,core_half,phase,rounds,checks,requests,forwarded,
      core_responses,published,responses,aborts,abort_issued,abort_core,dropped,resets,
      simultaneous,stalls,ticks,errors,8*rounds,early_offers,gamma_waits,checkpoint_words,signature);
    $finish;
  end
  initial begin #200000000;$fatal(1,"GLOBAL_TIMEOUT");end
endmodule
`endif

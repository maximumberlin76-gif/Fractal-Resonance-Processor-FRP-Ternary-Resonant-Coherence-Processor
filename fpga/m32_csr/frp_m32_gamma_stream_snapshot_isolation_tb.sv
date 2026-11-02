// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Snapshot isolation through the complete internal-gamma CDC stream adapter.
// A continuous producer presents capture/release commands behind stalled reads.
// The scoreboard samples recorder outputs at each accepted capture edge and
// independently decodes all 26 words, flags, identity and geometry at read edges.
// Read every snapshot in a seeded permutation; interleave core ticks and counter
// clears between frozen reads; replace, release and reset captured generations.
// Verify accepted request order, response ownership, payload/error stability,
// all three modes, saturation and end-to-end deterministic response signatures.
// CELLS=8/16/32/64, COUNT_BITS=1..64; +seed=76, +MAX_STALL=9 (1..31).
// +HOST_HALF=5 +CORE_HALF=7 +PHASE=1; half periods >=2, phase >=0 (ns).
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root to resolve the sine LUT.
`ifndef FRP_M32_GAMMA_STREAM_SNAPSHOT_ISOLATION_TB_SV
`define FRP_M32_GAMMA_STREAM_SNAPSHOT_ISOLATION_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_stream_top.sv"
module frp_m32_gamma_stream_snapshot_isolation_tb #(parameter int CELLS=8,COUNT_BITS=64);
  logic host_clk=0,core_clk=0,rst_n_async=1;
  int host_half=5,core_half=7,phase=1,max_stall=9;
  logic req_valid=0,req_write=0,rsp_ready=0;
  logic [8:0] req_addr=0;
  logic [31:0] req_wdata=0;
  wire req_ready,rsp_valid,rsp_error;
  wire [31:0] rsp_rdata;
  wire host_reset_released,core_reset_released,interface_ready,interface_busy;
  wire protocol_error,invalid_before_ready,invalid_while_busy,invalid_valid_held;
  frp_m32_internal_gamma_observed_csr_cdc_stream_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) dut(.*);
  typedef struct packed {
    bit wr;
    logic [8:0] address;
    logic [31:0] data;
    bit reject;
  } command_t;
  command_t commands[$];
  logic [41:0] expected_request;
  logic [32:0] expected_response,stalled_response;
  logic [41:0] waiting_request;
  bit outstanding=0,core_seen=0,was_stalled=0,producer_waiting=0;
  int unsigned seed=76,rng;
  int checks=0,requests=0,responses=0,forwarded=0,errors=0,simultaneous=0;
  int captures=0,releases=0,resets=0,ticks=0,epoch_ticks=0,stalls=0;
  int frozen_reads=0,empty_reads=0,invalid_writes=0,changed_captures=0;
  int stalled_capture=0,stalled_release=0,words=0,capture_tick=0,interleaved_reads=0;
  bit [2:0] modes=0;
  bit [4:0] states=0;
  bit [25:0] read_masks[12]='{default:'0};
  logic [63:0] signature=64'hcbf29ce484222325;
  initial begin
    void'($value$plusargs("HOST_HALF=%d",host_half));
    if(host_half<2)$fatal(1,"HOST_HALF_RANGE");
    forever #(host_half)host_clk=~host_clk;
  end
  initial begin
    void'($value$plusargs("CORE_HALF=%d",core_half));
    void'($value$plusargs("PHASE=%d",phase));
    if(core_half<2||phase<0)$fatal(1,"CORE_CLOCK_RANGE");
    #(phase);forever #(core_half)core_clk=~core_clk;
  end
  function automatic logic [31:0] random_word();
    rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);return rng;
  endfunction
  task automatic require(input logic ok,input string label);
    if(ok!==1'b1)$fatal(1,"%s requests=%0d responses=%0d time=%t",label,requests,responses,$time);
    checks++;
  endtask
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
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

  always @(negedge rst_n_async)begin
    held='0;held_valid=0;epoch_ticks=0;capture_tick=0;
    outstanding=0;core_seen=0;was_stalled=0;producer_waiting=0;
  end
  always @(posedge host_clk)if(rst_n_async&&host_reset_released)begin
    if(was_stalled)require(rsp_valid&&{rsp_error,rsp_rdata}===stalled_response,"RESPONSE_STABILITY");
    if(producer_waiting)require(req_valid&&{req_write,req_addr,req_wdata}===waiting_request,"PRODUCER_STABILITY");
    was_stalled=rsp_valid&&!rsp_ready;stalled_response={rsp_error,rsp_rdata};
    producer_waiting=req_valid&&!req_ready;waiting_request={req_write,req_addr,req_wdata};
    if(was_stalled)begin
      stalls++;require(!req_ready&&interface_busy,"BACKPRESSURE_OWNERSHIP");
      if(req_valid&&req_write&&req_addr==9'h100)begin
        if(req_wdata==1)stalled_capture++;
        if(req_wdata==2)stalled_release++;
      end
    end
    if(rsp_valid&&rsp_ready)begin
      require(outstanding&&core_seen,"RESPONSE_OWNER");
      require({rsp_error,rsp_rdata}===expected_response,"HOST_RESPONSE_MODEL");
      mix({31'd0,rsp_error,rsp_rdata});responses++;
      if(rsp_error)errors++;
      outstanding=0;if(req_valid&&req_ready)simultaneous++;
    end
    if(req_valid&&req_ready)begin
      require(!outstanding,"REQUEST_OWNER");
      outstanding=1;core_seen=0;expected_request={req_write,req_addr,req_wdata};
      requests++;mix({22'd0,expected_request});
    end
    require(!protocol_error&&!invalid_before_ready&&!invalid_while_busy&&!invalid_valid_held,"PROTOCOL_FLAGS");
  end
  always @(posedge core_clk)if(rst_n_async)begin
    if(dut.u_cdc.core_csr_valid)begin
      require(outstanding&&!core_seen,"CORE_REQUEST_OWNER");
      require({dut.u_cdc.core_csr_write,dut.u_cdc.core_csr_addr,dut.u_cdc.core_csr_wdata}
              ===expected_request,"CORE_REQUEST_ORDER");
      if(dut.u_cdc.core_csr_ready)begin
        expected_response={dut.u_cdc.core_csr_error,dut.u_cdc.core_csr_rdata};
        if(dut.u_cdc.core_csr_addr[8])begin
          require(expected_response===expected_snapshot(),"SNAPSHOT_ISOLATION");
          if(dut.u_cdc.core_csr_write)begin
            if(dut.u_cdc.core_csr_error)invalid_writes++;
            else if(dut.u_cdc.core_csr_wdata==1)begin
              require(live.count==COUNT_BITS'(COUNT_BITS<6&&epoch_ticks>((64'd1<<COUNT_BITS)-1)?
                      ((64'd1<<COUNT_BITS)-1):epoch_ticks),"CAPTURE_COUNT");
              require(live.overflow==(COUNT_BITS<6&&epoch_ticks>((64'd1<<COUNT_BITS)-1)),"CAPTURE_OVERFLOW");
              require(live.seen==(epoch_ticks!=0)&&!live.alignment_error,"RECORDER_FLAGS");
              if(held_valid&&held!==live)changed_captures++;
              held=live;held_valid=1;captures++;capture_tick=epoch_ticks;
            end else begin held='0;held_valid=0;releases++;end
          end else if(dut.u_cdc.core_csr_addr>=9'h110&&dut.u_cdc.core_csr_addr<=9'h174&&
                      dut.u_cdc.core_csr_addr[1:0]==0)begin
            if(held_valid)begin
              frozen_reads++;read_masks[captures][(int'(dut.u_cdc.core_csr_addr)-272)/4]=1;
              if(epoch_ticks>capture_tick)interleaved_reads++;
            end else empty_reads++;
          end
        end
        forwarded++;core_seen=1;
      end
    end
    if(dut.u_cdc.u_csr.tick_accepted)begin
      ticks++;epoch_ticks++;
      modes[int'(dut.u_cdc.u_csr.scheduler_mode_q)]=1;
      states[int'(dut.u_cdc.u_csr.scheduler_state_q)]=1;
    end
  end
  task automatic add(input bit wr,input logic[8:0] address,input logic[31:0] data=0,input bit reject=0);
    command_t item;item='{wr,address,data,reject};commands.push_back(item);
  endtask
  task automatic scan(input bit reject=0);
    int rotation;rotation=int'(random_word()%26);
    add(0,9'h104);add(0,9'h108);add(0,9'h10c);
    for(int w=0;w<26;w++)add(0,9'(272+4*((rotation+5*w)%26)),0,reject);
  endtask
  task automatic tick_program(input int n);
    for(int lane=0;lane<2;lane++)begin
      add(1,9'h008,32'(lane));add(1,9'h00c,32'(n%CELLS));
      add(1,9'h010,32'((n+lane)%3==0?0:((n+lane)%3==1?1:3)));add(1,9'h014,1);
    end
    add(1,0,1);
  endtask
  task automatic execute();
    // One timed producer and one timed consumer execute the generated program.
    // The next request is offered before the current response is consumed.
    fork
      begin : producer
        @(negedge host_clk);
        for(int n=0;n<commands.size();n++)begin
          req_valid=1;req_write=commands[n].wr;req_addr=commands[n].address;req_wdata=commands[n].data;
          do @(posedge host_clk);while(!req_ready);
          @(negedge host_clk);
        end
        req_valid=0;req_write=0;req_addr=0;req_wdata=0;
      end
      begin : consumer
        int watchdog,hold_cycles;
        for(int n=0;n<commands.size();n++)begin
          watchdog=0;
          while(!rsp_valid)begin
            @(negedge host_clk);watchdog++;
            if(watchdog>20000)$fatal(1,"RESPONSE_TIMEOUT");
          end
          require(rsp_error==commands[n].reject,"EXPECTED_ERROR");
          if(commands[n].wr||commands[n].reject)require(rsp_rdata==0,"WRITE_ERROR_DATA");
          hold_cycles=1+int'(random_word()%32)%max_stall;
          repeat(hold_cycles)@(negedge host_clk);
          rsp_ready=1;@(posedge host_clk);@(negedge host_clk);rsp_ready=0;
          require(!rsp_valid,"RESPONSE_CONSUMED");
        end
      end
    join
    require(!outstanding&&!interface_busy&&requests==responses&&requests==forwarded,"DRAINED_LEDGER");
    commands.delete();
  endtask
  task automatic reset_dut();
    @(negedge host_clk);rst_n_async=0;req_valid=0;rsp_ready=0;resets++;
    #1;require(!req_ready&&!rsp_valid&&!interface_ready&&rsp_rdata==0&&!rsp_error,"ASYNC_RESET");
    repeat(4)@(negedge core_clk);rst_n_async=1;
    while(!interface_ready)@(negedge host_clk);
    repeat(4)@(negedge host_clk);
    require(!rsp_valid&&!interface_busy,"NO_RESET_REPLAY");
  endtask
  initial begin
    void'($value$plusargs("seed=%d",seed));void'($value$plusargs("MAX_STALL=%d",max_stall));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64)||COUNT_BITS<1||COUNT_BITS>64||max_stall<1||max_stall>31)
      $fatal(1,"TEST_PROFILE_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;
    reset_dut();scan(1);add(1,9'h100,1);scan();
    add(1,0,32'h105);add(1,9'h06c,0);add(1,0,32'h400);
    for(int w=0;w<624;w++)begin add(1,9'h070,random_word()|32'h80000000);words++;end
    add(1,0,32'h100);
    for(int mode=0;mode<3;mode++)begin
      add(1,9'h004,32'(mode));
      for(int n=0;n<8;n++)tick_program(15*mode+n);
      add(1,9'h100,1);add(0,9'h104);
      for(int w=0;w<26;w++)begin
        add(0,9'(272+4*((5*w+mode)%26)));
        if(w%4==0)tick_program(15*mode+8+w/4);
        if(w==12)add(1,0,2);
        if(w%8==0)add(1,9'h100,32'h80000001,1);
      end
      add(1,9'h100,1);scan();
      add(1,9'h110,random_word(),1);add(1,9'h101,1,1);scan();
      add(1,9'h100,2);scan(1);add(1,9'h100,1);scan();
    end
    add(1,9'h100,2);scan(1);execute();
    require(ticks==45&&epoch_ticks==45&&modes==7&&states==31,"TICK_COVERAGE");
    reset_dut();scan(1);add(1,9'h100,1);scan();execute();
    require(captures==11&&releases==4&&resets==2&&words==624&&epoch_ticks==0,"GENERATION_COVERAGE");
    for(int n=1;n<=11;n++)require(read_masks[n]=='1,"GENERATION_WORD_COVERAGE");
    require(frozen_reads==364&&empty_reads==156&&invalid_writes==18&&errors==174&&
            interleaved_reads==75&&changed_captures>0,"ISOLATION_COVERAGE");
    require(simultaneous==requests-2&&stalls>0&&stalled_capture>0&&stalled_release>0,"HANDOFF_COVERAGE");
    $display("PASS STREAM_SNAPSHOT_ISOLATION cells=%0d bits=%0d seed=%0d host_half=%0d core_half=%0d phase=%0d max_stall=%0d checks=%0d requests=%0d responses=%0d forwarded=%0d errors=%0d simultaneous=%0d stalls=%0d captures=%0d releases=%0d resets=%0d ticks=%0d modes=%0d states=%0d frozen_reads=%0d empty_reads=%0d invalid_writes=%0d interleaved_reads=%0d changed_captures=%0d stalled_capture=%0d stalled_release=%0d words=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,host_half,core_half,phase,max_stall,checks,requests,responses,forwarded,errors,
      simultaneous,stalls,captures,releases,resets,ticks,modes,states,frozen_reads,empty_reads,invalid_writes,
      interleaved_reads,changed_captures,stalled_capture,stalled_release,words,signature);
    $finish;
  end
  initial begin #100000000;$fatal(1,"GLOBAL_TIMEOUT");end
endmodule
`endif

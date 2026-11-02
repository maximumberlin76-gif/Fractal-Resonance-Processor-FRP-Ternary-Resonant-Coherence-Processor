// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Transaction-order equivalence: CDC stream versus direct synchronous CSR.
// Independent bus drivers execute the same program at different physical times.
// Compare complete responses and settled architectural state after each transfer.
// Exercise manual/automatic requests, free/7:1/1:7 modes, checkpoint reload,
// staged phase/frequency loading, frozen snapshots and every control-page byte.
// Program/read every request lane; read every cell, group, level and bank window.
// Gamma status is read after both autonomous prefetch engines become idle.
// The reference uses the same CSR/core implementation without the CDC adapter.
// CELLS=8/16/32/64; COUNT_BITS=1..64; +seed=76 +MAX_STALL=9 (0..31).
// +HOST_HALF=5 +CORE_HALF=7 +PHASE=1; half periods >=2, phase >=0 (ns).
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root to resolve the sine LUT.
`ifndef FRP_M32_GAMMA_STREAM_EQUIVALENCE_TB_SV
`define FRP_M32_GAMMA_STREAM_EQUIVALENCE_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_stream_top.sv"
module frp_m32_gamma_stream_equivalence_tb #(parameter int CELLS=8, COUNT_BITS=64);
  localparam int LANES=frp_m31_pkg::frp_calc_request_lanes(CELLS);
  logic host_clk=0,core_clk=0,rst_n_async=1;
  int host_half=5,core_half=7,phase=1,max_stall=9;
  logic req_valid=0,req_write=0,rsp_ready=0;
  logic [8:0] req_addr=0;
  logic [31:0] req_wdata=0;
  wire req_ready,rsp_valid,rsp_error;
  wire [31:0] rsp_rdata;
  wire host_reset_released,core_reset_released,interface_ready,interface_busy;
  wire protocol_error,invalid_before_ready,invalid_while_busy,invalid_valid_held;
  logic ref_valid=0,ref_write=0;
  logic [8:0] ref_addr=0;
  logic [31:0] ref_wdata=0;
  wire ref_ready,ref_error;
  wire [31:0] ref_rdata;
  logic [31:0] sampled;
  int unsigned seed=76,rng;
  int checks=0,transactions=0,host_requests=0,backend_requests=0,reference_requests=0,consumed=0;
  int ticks=0,ref_ticks=0,errors=0,held_cycles=0,checkpoints=0,words=0;
  int captures=0,frozen_reads=0,page_reads=0,cell_reads=0,window_reads=0,group_reads=0,level_reads=0;
  int manual_ticks=0,auto_ticks=0,resets=0,lane_programs=0;
  bit [2:0] modes=0;
  bit [4:0] states=0,pages=0;
  bit [255:0] address_seen[5]='{default:'0};
  logic [31:0] frozen[26];
  logic [CELLS*2-1:0] previous_state='0;
  logic [63:0] signature=64'hcbf29ce484222325;
  frp_m32_internal_gamma_observed_csr_cdc_stream_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) dut(.*);
  frp_m32_internal_gamma_observed_csr_top #(
    .CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) reference (
    .clk(core_clk),.rst_n_async(rst_n_async),.csr_valid(ref_valid),.csr_write(ref_write),
    .csr_addr(ref_addr),.csr_wdata(ref_wdata),.csr_ready(ref_ready),
    .csr_error(ref_error),.csr_rdata(ref_rdata));
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
    if(ok!==1'b1)$fatal(1,"%s transaction=%0d time=%t",label,transactions,$time);
    checks++;
  endtask
  task automatic mix(input logic [63:0] value);
    signature=(signature^value)*64'h100000001b3;
  endtask
  always @(posedge host_clk)if(rst_n_async&&host_reset_released)begin
    if(req_valid&&req_ready)host_requests++;
    if(rsp_valid&&rsp_ready)consumed++;
    require(!protocol_error&&!invalid_before_ready&&!invalid_while_busy&&!invalid_valid_held,"PROTOCOL_FLAGS");
  end
  always @(posedge core_clk)if(rst_n_async)begin
    if(ref_valid&&ref_ready)reference_requests++;
    if(dut.u_cdc.core_csr_valid&&dut.u_cdc.core_csr_ready)backend_requests++;
    if(reference.tick_accepted)ref_ticks++;
    if(dut.u_cdc.u_csr.tick_accepted)begin
      ticks++;modes[int'(dut.u_cdc.u_csr.scheduler_mode_q)]=1;
      states[int'(dut.u_cdc.u_csr.scheduler_state_q)]=1;
      if(dut.u_cdc.u_csr.auto_enable_q)auto_ticks++;else manual_ticks++;
    end
  end
`define FRP_STREAM_EQ(signal) \
    require(dut.u_cdc.u_csr.signal===reference.signal,{"STATE_EQUIVALENCE:",`"signal`"});
  task automatic compare_state();
    // Registered architectural outputs and staging storage, after pipeline retirement.
    `FRP_STREAM_EQ(phase_word_q)
    `FRP_STREAM_EQ(frequency_current_q16)
    `FRP_STREAM_EQ(registered_target_q)
    `FRP_STREAM_EQ(registered_target_valid_q)
    `FRP_STREAM_EQ(accepted_target_capture_events_q)
    `FRP_STREAM_EQ(rejected_target_capture_events_q)
    `FRP_STREAM_EQ(state_out)
    `FRP_STREAM_EQ(pending_route_out)
    `FRP_STREAM_EQ(scheduler_mode_q)
    `FRP_STREAM_EQ(scheduler_state_q)
    `FRP_STREAM_EQ(ticks_recorded_q)
    `FRP_STREAM_EQ(scheduler_count_free_q)
    `FRP_STREAM_EQ(scheduler_count_balance_q)
    `FRP_STREAM_EQ(scheduler_count_commit_q)
    `FRP_STREAM_EQ(scheduler_count_excite_q)
    `FRP_STREAM_EQ(scheduler_count_neutralize_q)
    `FRP_STREAM_EQ(temperature_proxy_q16)
    `FRP_STREAM_EQ(peak_temperature_proxy_q16)
    `FRP_STREAM_EQ(thermal_sample_count_q)
    `FRP_STREAM_EQ(local_heat_q16)
    `FRP_STREAM_EQ(local_heat_peak_q16)
    `FRP_STREAM_EQ(local_gamma_noise_target_q16)
    `FRP_STREAM_EQ(local_gamma_noise_state_q16)
    `FRP_STREAM_EQ(local_gamma_drift_word)
    `FRP_STREAM_EQ(local_previous_margin_q16)
    `FRP_STREAM_EQ(local_stability_valid_q)
    `FRP_STREAM_EQ(local_stability_sample_count_q)
    `FRP_STREAM_EQ(local_stability_raw_coherence_q30)
    `FRP_STREAM_EQ(local_stability_cluster_coherence_q30)
    `FRP_STREAM_EQ(local_stability_mean_heat_q16)
    `FRP_STREAM_EQ(local_stability_mean_overload_q16)
    `FRP_STREAM_EQ(local_stability_mean_lag_q16)
    `FRP_STREAM_EQ(local_stability_neutral_fraction_q30)
    `FRP_STREAM_EQ(local_stability_compression_arg_q16)
    `FRP_STREAM_EQ(local_stability_switch_load_q16)
    `FRP_STREAM_EQ(gamma_tick_phase_q)
    `FRP_STREAM_EQ(gamma_configured)
    `FRP_STREAM_EQ(gamma_load_error)
    `FRP_STREAM_EQ(checkpoint_index_q)
    `FRP_STREAM_EQ(checkpoint_words_q)
    `FRP_STREAM_EQ(phase_load_q)
    `FRP_STREAM_EQ(frequency_load_q)
    `FRP_STREAM_EQ(request_cells_q)
    `FRP_STREAM_EQ(request_targets_q)
    `FRP_STREAM_EQ(request_valid_q)
    `FRP_STREAM_EQ(last_tick_q)
    require(ticks==ref_ticks,"TICK_ACCOUNTING");
    require(!dut.u_cdc.u_csr.last_tick_q.actual_direct&&
            !dut.u_cdc.u_csr.last_tick_q.reserved_state&&
            !dut.u_cdc.u_csr.last_tick_q.queue_overflow,"EXECUTION_INVARIANTS");
    for(int cell_index=0;cell_index<CELLS;cell_index++)begin
      require(dut.u_cdc.u_csr.state_out[cell_index*2+:2]!=2'b10,"RESERVED_STATE");
      require(!((previous_state[cell_index*2+:2]==2'b01&&dut.u_cdc.u_csr.state_out[cell_index*2+:2]==2'b11)||
                (previous_state[cell_index*2+:2]==2'b11&&dut.u_cdc.u_csr.state_out[cell_index*2+:2]==2'b01)),"DIRECT_TRANSITION");
      require(dut.u_cdc.u_csr.pending_route_out[cell_index*2+:2]==0||
              dut.u_cdc.u_csr.state_out[cell_index*2+:2]==0,"PENDING_REQUIRES_ACTIVE_ZERO");
    end
    previous_state=dut.u_cdc.u_csr.state_out;
  endtask
`undef FRP_STREAM_EQ
  task automatic stream_transfer(input bit wr,input logic[8:0] address,input logic[31:0] data,
                                 input int gap,hold_cycles,output logic[32:0] response);
    int watchdog;
    repeat(gap)@(negedge host_clk);
    @(negedge host_clk);req_valid=1;req_write=wr;req_addr=address;req_wdata=data;
    do @(posedge host_clk);while(!req_ready);
    @(negedge host_clk);req_valid=0;req_addr=~address;req_wdata=~data;req_write=!wr;
    watchdog=0;
    while(!rsp_valid)begin
      @(negedge host_clk);watchdog++;
      if(watchdog>20000)$fatal(1,"STREAM_TIMEOUT");
    end
    response={rsp_error,rsp_rdata};
    repeat(hold_cycles)begin
      @(negedge host_clk);held_cycles++;
      require(rsp_valid&&{rsp_error,rsp_rdata}===response&&!req_ready,"STALLED_RESPONSE");
    end
    rsp_ready=1;@(posedge host_clk);@(negedge host_clk);rsp_ready=0;
    require(!rsp_valid&&!interface_busy,"CONSUMED_RESPONSE");
  endtask
  task automatic direct_transfer(input bit wr,input logic[8:0] address,input logic[31:0] data,
                                 input int gap,output logic[32:0] response);
    int watchdog;
    repeat(gap)@(negedge core_clk);
    @(negedge core_clk);ref_valid=1;ref_write=wr;ref_addr=address;ref_wdata=data;watchdog=0;
    do begin
      @(posedge core_clk);watchdog++;
      if(watchdog>20000)$fatal(1,"REFERENCE_TIMEOUT");
    end while(!ref_ready);
    response={ref_error,ref_rdata};
    @(negedge core_clk);ref_valid=0;ref_addr=~address;ref_wdata=~data;ref_write=!wr;
  endtask
  task automatic transfer(input bit wr,input logic[8:0] address,input logic[31:0] data,input bit reject=0);
    logic [32:0] actual,expected;
    int host_gap,ref_gap,hold_cycles;
    host_gap=int'(random_word()%4);ref_gap=int'(random_word()%7);
    hold_cycles=int'(random_word()%32)%(max_stall+1);
    fork
      stream_transfer(wr,address,data,host_gap,hold_cycles,actual);
      direct_transfer(wr,address,data,ref_gap,expected);
    join
    require(actual===expected,"RESPONSE_EQUIVALENCE");
    require(actual[32]==reject,"EXPECTED_ERROR");sampled=actual[31:0];
    if(wr||reject)require(sampled==0,"WRITE_ERROR_DATA");
    if(reject)errors++;
    transactions++;mix({22'd0,wr,address,data});mix({31'd0,actual});
    require(host_requests==transactions&&backend_requests==transactions&&
            reference_requests==transactions&&consumed==transactions,"TRANSFER_LEDGER");
    repeat(3)@(negedge core_clk);compare_state();
  endtask
  task automatic read_expect(input logic[8:0] address,input logic[31:0] value);
    transfer(0,address,0);require(sampled===value,"READ_EXPECT");
  endtask
  task automatic settle_gamma();
    int watchdog;watchdog=0;
    while(dut.u_cdc.u_csr.gamma_source_busy||reference.gamma_source_busy)begin
      @(negedge core_clk);watchdog++;
      if(watchdog>5000)$fatal(1,"GAMMA_SETTLE_TIMEOUT");
    end
    repeat(3)@(negedge core_clk);
  endtask
  task automatic checkpoint(input int index_value);
    transfer(1,0,32'h105);transfer(1,9'h06c,32'(index_value));transfer(1,0,32'h400);
    for(int w=0;w<624;w++)begin transfer(1,9'h070,random_word()|32'h80000000);words++;end
    read_expect(9'h074,624);checkpoints++;transfer(1,0,32'h100);
  endtask
  task automatic snapshot(input bit capture_new);
    if(capture_new)begin transfer(1,9'h100,1);captures++;end
    for(int w=0;w<26;w++)begin
      transfer(0,9'(9'h110+4*w),0);
      if(capture_new)frozen[w]=sampled;
      else begin require(sampled===frozen[w],"FROZEN_SNAPSHOT");frozen_reads++;end
    end
  endtask
  function automatic bit read_error(input int page_number,address);
    if(address%4!=0||address==0)return 1;
    case(page_number)
      1:return address==108||(address>=200&&address<252);
      2:return address==248;
      3:return address>=224&&address<252;
      4:return address>=104&&!(address==104||address==108||address==116||address==120||address==124||address==252);
      default:return 0;
    endcase
  endfunction
  task automatic read_pages();
    settle_gamma();
    for(int page_number=0;page_number<5;page_number++)begin
      transfer(1,0,32'h100+32'(page_number>=3?page_number+1:page_number));
      read_expect(9'h0fc,32'h46524701+32'(page_number));pages[page_number]=1;
      for(int address=0;address<256;address++)begin
        transfer(0,9'(address),0,read_error(page_number,address));
        page_reads++;address_seen[page_number][address]=1;
      end
    end
    transfer(1,0,32'h100);
  endtask
  task automatic read_geometry();
    int windows;
    transfer(1,0,32'h104);read_expect(9'h068,32'(CELLS));
    transfer(0,9'h0d0,0);windows=int'(sampled);
    for(int window_index=0;window_index<windows;window_index++)begin
      transfer(1,9'h080,32'(window_index));
      for(int address=172;address<=196;address+=4)begin transfer(0,9'(address),0);window_reads++;end
    end
    for(int group_index=0;group_index<CELLS-1;group_index++)begin
      transfer(1,9'h084,32'(group_index));transfer(0,9'h088,0);group_reads++;
    end
    for(int level_index=0;level_index<$clog2(CELLS);level_index++)begin
      transfer(1,9'h08c,32'(level_index));
      for(int address=144;address<=156;address+=4)begin transfer(0,9'(address),0);level_reads++;end
    end
    transfer(1,9'h080,32'(windows),1);transfer(1,9'h084,32'(CELLS-1),1);
    transfer(1,9'h08c,32'($clog2(CELLS)),1);
    for(int page_number=0;page_number<2;page_number++)begin
      transfer(1,0,32'h100+32'(page_number));
      for(int cell_index=0;cell_index<CELLS;cell_index++)begin
        transfer(1,9'h018,32'(cell_index));
        for(int address=112;address<=160;address+=4)begin transfer(0,9'(address),0);cell_reads++;end
        transfer(0,9'h034,0);transfer(0,9'h038,0);cell_reads+=2;
      end
    end
    transfer(1,0,32'h100);
  endtask
  task automatic reset_both();
    @(negedge host_clk);rst_n_async=0;req_valid=0;ref_valid=0;rsp_ready=0;resets++;
    #1;require(!req_ready&&!rsp_valid&&!ref_ready&&!interface_ready,"RESET_BUS");
    repeat(4)@(negedge core_clk);rst_n_async=1;
    while(!interface_ready)@(negedge host_clk);
    repeat(3)@(negedge core_clk);previous_state='0;compare_state();
    read_expect(9'h104,0);read_expect(9'h0fc,32'h46524701);
  endtask
  initial begin
    void'($value$plusargs("seed=%d",seed));void'($value$plusargs("MAX_STALL=%d",max_stall));
    if(max_stall<0||max_stall>31)$fatal(1,"MAX_STALL_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;
    reset_both();checkpoint(624);
    for(int cell_index=0;cell_index<CELLS;cell_index++)begin
      transfer(1,9'h018,32'(cell_index));transfer(1,9'h06c,random_word());
      transfer(1,9'h070,32'(cell_index%2==0?1048576:-1048576));
    end
    transfer(1,0,8);
    for(int lane=0;lane<LANES;lane++)begin
      transfer(1,9'h008,32'(lane));transfer(1,9'h00c,32'(lane));
      transfer(1,9'h010,32'(lane%3==0?0:(lane%3==1?1:3)));transfer(1,9'h014,1);
      read_expect(9'h008,32'(lane));read_expect(9'h00c,32'(lane));
      read_expect(9'h010,32'(lane%3==0?0:(lane%3==1?1:3)));read_expect(9'h014,1);
      lane_programs++;
    end
    for(int mode=0;mode<3;mode++)begin
      transfer(1,9'h004,32'(mode));read_expect(9'h020,32'(mode));
      for(int step_index=0;step_index<16;step_index++)begin
        transfer(1,9'h068,32'(step_index%2));
        for(int lane=0;lane<2;lane++)begin
          transfer(1,9'h008,32'(lane));transfer(1,9'h00c,32'((mode+step_index)%CELLS));
          transfer(1,9'h010,32'((step_index+lane)%3==0?0:((step_index+lane)%3==1?1:3)));
          transfer(1,9'h014,1);
        end
        transfer(1,0,1);
        if(mode==1&&step_index==7)begin snapshot(1);checkpoint(0);snapshot(0);end
      end
      snapshot(1);transfer(1,0,2);snapshot(0);
    end
    require(ticks==48&&ref_ticks==48&&manual_ticks==24&&auto_ticks==24&&modes==7&&states==31,"TICK_COVERAGE");
    read_pages();read_geometry();snapshot(0);
    transfer(1,9'h100,2);transfer(0,9'h110,0,1);
    transfer(1,9'h010,2,1);transfer(1,9'h004,3,1);transfer(1,9'h018,32'(CELLS),1);
    transfer(1,9'h008,32'(LANES),1);
    require(lane_programs==LANES&&checkpoints==2&&words==1248&&captures==4&&frozen_reads==130&&pages==31&&
            page_reads==1280&&cell_reads==30*CELLS&&group_reads==CELLS-1&&
            level_reads==4*$clog2(CELLS),"SCENARIO_COVERAGE");
    for(int p=0;p<5;p++)require(address_seen[p]=='1,"PAGE_ADDRESS_COVERAGE");
    require(dut.u_cdc.u_csr.u_core.record_sample_count_q==COUNT_BITS'(COUNT_BITS<6?(2**COUNT_BITS-1):48)&&
            dut.u_cdc.u_csr.u_core.record_count_overflow_q==(COUNT_BITS<6),"RECORDER_COUNT");
    reset_both();transfer(1,0,1,1);
    require(ticks==48&&ref_ticks==48&&resets==2&&!rsp_valid&&!ref_valid&&
            (max_stall==0?held_cycles==0:held_cycles>0),"FINAL_COVERAGE");
    $display("PASS GAMMA_STREAM_EQ cells=%0d bits=%0d seed=%0d host_half=%0d core_half=%0d phase=%0d max_stall=%0d checks=%0d transactions=%0d ticks=%0d manual_ticks=%0d auto_ticks=%0d modes=%0d states=%0d errors=%0d held_cycles=%0d checkpoints=%0d words=%0d captures=%0d frozen_reads=%0d page_reads=%0d cell_reads=%0d window_reads=%0d group_reads=%0d level_reads=%0d lane_programs=%0d resets=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,host_half,core_half,phase,max_stall,checks,transactions,ticks,manual_ticks,auto_ticks,
      modes,states,errors,held_cycles,checkpoints,words,captures,frozen_reads,page_reads,cell_reads,
      window_reads,group_reads,level_reads,lane_programs,resets,signature);
    $finish;
  end
  initial begin #200000000;$fatal(1,"GLOBAL_TIMEOUT");end
endmodule
`endif

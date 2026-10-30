// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Unified internal-gamma control/snapshot CSR integration qualification.
// Profiles: CELLS=8/16/32/64; COUNT_BITS=3/64; +seed=<unsigned>.
// Compare the original control bus and all 114 common core outputs before and
// after each edge against frp_m32_internal_gamma_csr_top. Snapshot transactions
// are presented to the reference as idle cycles on the same physical clock.
// The snapshot scoreboard captures public recorder outputs before the accepting
// edge and independently decodes all 26 payload words without reading CSR state.
// Exercise all 256 snapshot byte addresses for reads and invalid writes,
// free/7:1/1:7 scheduling, gamma waits, two synthetic 624-word checkpoints,
// counter clear, held captures, reset release, saturation and withdrawn ticks.
// Signature covers checked bus responses and public recorder trajectories.
// Include paths: rtl/m22, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Simulator flags: --binary --timing --assert --unroll-count 1
// --output-split-cfuncs 0 --top-module frp_m32_internal_gamma_observed_csr_top_tb.
// The event-driven monitor keeps timed stimulus separate from output checks.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_TOP_TB_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_TOP_TB_SV
`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_top.sv"
`include "frp_m32_internal_gamma_csr_top.sv"
module frp_m32_internal_gamma_observed_csr_top_tb #(
  parameter int CELLS=8,
  parameter int COUNT_BITS=64
);
  localparam logic [COUNT_BITS-1:0] COUNT_MAX='1;
  int unsigned seed=76;
  logic [63:0] signature=64'hcbf29ce484222325;
  bit [2:0] modes_seen=0;
  bit [4:0] states_seen=0;
  bit [25:0] payload_reads=0;
  int withdrawn=0;
  logic clk=0,rst_n_async=1,csr_valid=0,csr_write=0;
  logic [8:0] csr_addr=0;
  wire [7:0] local_addr=csr_addr[7:0];
  logic [31:0] csr_wdata=0;
  wire csr_ready,csr_error,ref_ready,ref_error;
  wire [31:0] csr_rdata,ref_data;
  int release_edges=0, cycles=0,checks=0,captures=0,stalls=0,errors=0;
  int accepted=0,recorded=0,frozen=0;
  bit [1:0] pending=0;
  bit fired,failed;
  frp_m32_internal_gamma_observed_csr_top #(.CELLS(CELLS),.RECORDER_COUNT_BITS(COUNT_BITS)) dut (.*);
  frp_m32_internal_gamma_csr_top #(.CELLS(CELLS)) golden (
    .clk(clk),.rst_n_async(rst_n_async),.csr_valid(csr_valid&&!csr_addr[8]),
    .csr_write(csr_write),.csr_addr(csr_addr[7:0]),.csr_wdata(csr_wdata),
    .csr_ready(ref_ready),.csr_error(ref_error),.csr_rdata(ref_data));
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

  assign live.seen=dut.u_core.record_sample_seen_q;
  assign live.count=dut.u_core.record_sample_count_q;
  assign live.overflow=dut.u_core.record_count_overflow_q;
  assign live.previous_margin=dut.u_core.record_previous_margin_q16;
  assign live.minimum_margin=dut.u_core.record_minimum_margin_q16;
  assign live.minimum_tick=dut.u_core.record_minimum_margin_tick_q;
  assign live.peak_switch=dut.u_core.record_peak_switch_load_q16;
  assign live.peak_tick=dut.u_core.record_peak_switch_load_tick_q;
  assign live.boundary_valid=dut.u_core.boundary_valid_q;
  assign live.boundary_pulse=dut.u_core.boundary_pulse_q;
  assign live.boundary_tick=dut.u_core.boundary_tick_q;
  assign live.mode=dut.u_core.boundary_scheduler_mode_q;
  assign live.state=dut.u_core.boundary_scheduler_state_q;
  assign live.boundary_previous=dut.u_core.boundary_previous_margin_q16;
  assign live.boundary_margin=dut.u_core.boundary_margin_q16;
  assign live.capacity=dut.u_core.boundary_capacity_q16;
  assign live.pressure=dut.u_core.boundary_pressure_q16;
  assign live.heat=dut.u_core.boundary_mean_heat_q16;
  assign live.switches=dut.u_core.boundary_switch_load_q16;
  assign live.retained=dut.u_core.boundary_retained_state_q;
  assign live.pending=dut.u_core.boundary_pending_route_q;
  assign live.alignment_error=dut.u_core.record_alignment_error_q;
  localparam int SOURCE_WORDS=($bits(sample_t)+31)/32;

  function automatic logic [33:0] expected_bus();
    logic error;
    logic [31:0] data;
    logic [63:0] count64;
    logic [127:0] retained128, pending128;
    error = 0;
    data = 0;
    count64 = 64'(held.count);
    retained128 = 128'(held.retained);
    pending128 = 128'(held.pending);
    if (!rst_n_async || release_edges<2 || !csr_valid) return 34'd0;
    if (csr_valid) begin
      if (local_addr%4 != 0) error = 1;
      else if (csr_write)
        error = !(local_addr==0 && (csr_wdata==1 || csr_wdata==2));
      else begin
        case (local_addr)
          8'h04: data = {26'd0,held.alignment_error,held.boundary_pulse,
                         held.boundary_valid,held.overflow,held.seen,held_valid};
          8'h08: data = 32'h46524201;
          8'h0c: data = (32'(COUNT_BITS)<<16) | 32'(CELLS);
          default: begin
            if (!held_valid) error = 1;
            else case (local_addr)
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
    return {1'b1,error,data};
  endfunction

`define FRP_M32_HOST_COMPARE(signal) \
    if (dut.signal !== golden.signal) \
      $fatal(1,"CORE_OUTPUTS cycle=%0d signal=%s",cycles,`"signal`");

  event check_event;
  always @(check_event) compare();
  task automatic compare();
    logic [33:0] expected;
    logic [SOURCE_WORDS*32-1:0] hash_data;
    if (dut.core_ready !== (rst_n_async && release_edges>=2))
      $fatal(1,"RESET_RELEASE cycle=%0d",cycles);
    `FRP_M32_HOST_COMPARE(phase_word_q)
    `FRP_M32_HOST_COMPARE(frequency_current_q16)
    `FRP_M32_HOST_COMPARE(coupling_field_q16)
    `FRP_M32_HOST_COMPARE(phase_projection_q30)
    `FRP_M32_HOST_COMPARE(phase_target_source)
    `FRP_M32_HOST_COMPARE(registered_target_q)
    `FRP_M32_HOST_COMPARE(registered_target_valid_q)
    `FRP_M32_HOST_COMPARE(phase_target_domain_valid)
    `FRP_M32_HOST_COMPARE(registered_target_domain_valid)
    `FRP_M32_HOST_COMPARE(tick_result.capture_accepted)
    `FRP_M32_HOST_COMPARE(tick_result.capture_rejected)
    `FRP_M32_HOST_COMPARE(accepted_target_capture_events_q)
    `FRP_M32_HOST_COMPARE(rejected_target_capture_events_q)
    `FRP_M32_HOST_COMPARE(registered_request_enable)
    `FRP_M32_HOST_COMPARE(phase_request_valid)
    `FRP_M32_HOST_COMPARE(phase_request_cell_index)
    `FRP_M32_HOST_COMPARE(phase_request_target)
    `FRP_M32_HOST_COMPARE(execution_request_valid)
    `FRP_M32_HOST_COMPARE(execution_request_cell_index)
    `FRP_M32_HOST_COMPARE(execution_request_target)
    `FRP_M32_HOST_COMPARE(tick_result.execution_target_bank)
    `FRP_M32_HOST_COMPARE(state_out)
    `FRP_M32_HOST_COMPARE(pending_route_out)
    `FRP_M32_HOST_COMPARE(scheduler_mode_q)
    `FRP_M32_HOST_COMPARE(scheduler_state_q)
    `FRP_M32_HOST_COMPARE(ticks_recorded_q)
    `FRP_M32_HOST_COMPARE(scheduler_count_free_q)
    `FRP_M32_HOST_COMPARE(scheduler_count_balance_q)
    `FRP_M32_HOST_COMPARE(scheduler_count_commit_q)
    `FRP_M32_HOST_COMPARE(scheduler_count_excite_q)
    `FRP_M32_HOST_COMPARE(scheduler_count_neutralize_q)
    `FRP_M32_HOST_COMPARE(tick_result.request_accept)
    `FRP_M32_HOST_COMPARE(tick_result.request_reject)
    `FRP_M32_HOST_COMPARE(tick_result.accepted_cells)
    `FRP_M32_HOST_COMPARE(tick_result.neutral_cells)
    `FRP_M32_HOST_COMPARE(tick_result.changed_cells)
    `FRP_M32_HOST_COMPARE(tick_result.accepted_changes)
    `FRP_M32_HOST_COMPARE(tick_result.capacity_remaining)
    `FRP_M32_HOST_COMPARE(tick_result.capacity_exhausted)
    `FRP_M32_HOST_COMPARE(tick_result.switch_load)
    `FRP_M32_HOST_COMPARE(tick_result.requested_direct)
    `FRP_M32_HOST_COMPARE(tick_result.prevented_direct)
    `FRP_M32_HOST_COMPARE(tick_result.neutral_routed)
    `FRP_M32_HOST_COMPARE(tick_result.actual_direct)
    `FRP_M32_HOST_COMPARE(tick_result.reserved_state)
    `FRP_M32_HOST_COMPARE(tick_result.queue_overflow)
    `FRP_M32_HOST_COMPARE(tick_result.invariant_flags)
    `FRP_M32_HOST_COMPARE(pair_coherence_q30)
    `FRP_M32_HOST_COMPARE(cluster_coherence_q30)
    `FRP_M32_HOST_COMPARE(global_coherence_q30)
    `FRP_M32_HOST_COMPARE(organization_dispersion_q30)
    `FRP_M32_HOST_COMPARE(tick_result.cycle_cost)
    `FRP_M32_HOST_COMPARE(temperature_proxy_q16)
    `FRP_M32_HOST_COMPARE(peak_temperature_proxy_q16)
    `FRP_M32_HOST_COMPARE(thermal_sample_count_q)
    `FRP_M32_HOST_COMPARE(coherence_capacity_q16)
    `FRP_M32_HOST_COMPARE(pressure_q16)
    `FRP_M32_HOST_COMPARE(stability_margin_q16)
    `FRP_M32_HOST_COMPARE(stable)
    `FRP_M32_HOST_COMPARE(local_heat_q16)
    `FRP_M32_HOST_COMPARE(local_heat_peak_q16)
    `FRP_M32_HOST_COMPARE(local_generated_power_q16)
    `FRP_M32_HOST_COMPARE(local_thermal_dissipation_q16)
    `FRP_M32_HOST_COMPARE(local_thermal_diffusion_q16)
    `FRP_M32_HOST_COMPARE(local_thermal_overload_q16)
    `FRP_M32_HOST_COMPARE(local_next_heat_q16)
    `FRP_M32_HOST_COMPARE(local_next_overload_q16)
    `FRP_M32_HOST_COMPARE(local_frequency_lag_q16)
    `FRP_M32_HOST_COMPARE(local_mean_heat_q16)
    `FRP_M32_HOST_COMPARE(local_mean_heat_peak_q16)
    `FRP_M32_HOST_COMPARE(local_maximum_heat_peak_q16)
    `FRP_M32_HOST_COMPARE(local_gamma_noise_target_q16)
    `FRP_M32_HOST_COMPARE(local_gamma_noise_state_q16)
    `FRP_M32_HOST_COMPARE(local_gamma_drift_word)
    `FRP_M32_HOST_COMPARE(local_gamma_effective_word)
    `FRP_M32_HOST_COMPARE(local_next_gamma_drift_word)
    `FRP_M32_HOST_COMPARE(local_next_gamma_effective_word)
    `FRP_M32_HOST_COMPARE(phase_gamma_effective_word)
    `FRP_M32_HOST_COMPARE(local_thermal_node_factor_q30)
    `FRP_M32_HOST_COMPARE(local_next_thermal_node_factor_q30)
    `FRP_M32_HOST_COMPARE(phase_thermal_node_factor_q30)
    `FRP_M32_HOST_COMPARE(group_coherence_q30)
    `FRP_M32_HOST_COMPARE(level_mean_coherence_q30)
    `FRP_M32_HOST_COMPARE(level_min_coherence_q30)
    `FRP_M32_HOST_COMPARE(level_max_coherence_q30)
    `FRP_M32_HOST_COMPARE(level_dispersion_q30)
    `FRP_M32_HOST_COMPARE(local_coherence_compression_q30)
    `FRP_M32_HOST_COMPARE(local_effective_coherence_q30)
    `FRP_M32_HOST_COMPARE(local_coherence_capacity_q16)
    `FRP_M32_HOST_COMPARE(local_pressure_q16)
    `FRP_M32_HOST_COMPARE(local_stability_margin_q16)
    `FRP_M32_HOST_COMPARE(local_stable)
    `FRP_M32_HOST_COMPARE(local_previous_margin_q16)
    `FRP_M32_HOST_COMPARE(local_stability_valid_q)
    `FRP_M32_HOST_COMPARE(local_stability_sample_count_q)
    `FRP_M32_HOST_COMPARE(local_stability_raw_coherence_q30)
    `FRP_M32_HOST_COMPARE(local_stability_cluster_coherence_q30)
    `FRP_M32_HOST_COMPARE(local_stability_mean_heat_q16)
    `FRP_M32_HOST_COMPARE(local_stability_mean_overload_q16)
    `FRP_M32_HOST_COMPARE(local_stability_mean_lag_q16)
    `FRP_M32_HOST_COMPARE(local_stability_neutral_fraction_q30)
    `FRP_M32_HOST_COMPARE(local_stability_compression_arg_q16)
    `FRP_M32_HOST_COMPARE(local_stability_switch_load_q16)
    `FRP_M32_HOST_COMPARE(checkpoint_load_ready)
    `FRP_M32_HOST_COMPARE(gamma_configured)
    `FRP_M32_HOST_COMPARE(gamma_load_error)
    `FRP_M32_HOST_COMPARE(gamma_source_busy)
    `FRP_M32_HOST_COMPARE(gamma_bank_valid)
    `FRP_M32_HOST_COMPARE(tick_ready)
    `FRP_M32_HOST_COMPARE(tick_accepted)
    `FRP_M32_HOST_COMPARE(phase_load_ready)
    `FRP_M32_HOST_COMPARE(phase_load_accepted)
    `FRP_M32_HOST_COMPARE(gamma_update_accepted)
    `FRP_M32_HOST_COMPARE(gamma_tick_phase_q)
    expected=csr_addr[8] ? expected_bus() : {ref_ready,ref_error,ref_data};
    if ({csr_ready,csr_error,csr_rdata} !== expected)
      $fatal(1,"HOST_BUS cycle=%0d address=%h got=%h expected=%h",cycles,csr_addr,{csr_ready,csr_error,csr_rdata},expected);
    if (live.alignment_error || dut.tick_result.actual_direct || dut.tick_result.reserved_state || dut.tick_result.queue_overflow)
      $fatal(1,"INVARIANT");
    if (live.count !== COUNT_BITS'(64'(recorded)>64'(COUNT_MAX) ? 64'(COUNT_MAX) : 64'(recorded)) ||
        live.overflow !== (64'(recorded)>64'(COUNT_MAX)) ||
        live.seen !== (recorded!=0))
      $fatal(1,"RECORD_COUNT expected=%0d got=%0d",recorded,live.count);
    signature=(signature^{19'd0,csr_valid,csr_write,csr_addr,
                           csr_ready,csr_error,csr_rdata})*64'h100000001b3;
    hash_data='0;
    hash_data[$bits(sample_t)-1:0]=live;
    for (int w=0;w<SOURCE_WORDS;w++)
      signature=(signature^{32'd0,hash_data[w*32+:32]})*64'h100000001b3;
    checks++;
  endtask
`undef FRP_M32_HOST_COMPARE

  task automatic step(input bit valid, wr,input logic[8:0] address,input logic[31:0] data);
    clk=0;csr_valid=valid;csr_write=wr;csr_addr=address;csr_wdata=data;#2;
    -> check_event; #1;
    fired=csr_valid&&csr_ready;failed=csr_error;
    if (fired&&csr_addr==9'h100&&csr_write&&!csr_error) begin
      if(csr_wdata==1) begin held=live;held_valid=1;captures++;end
      else begin held='0;held_valid=0;end
    end
    if (fired&&csr_addr[8]&&!csr_write&&!csr_error&&held_valid&&held!==live) frozen++;
    if(csr_valid&&!csr_ready&&rst_n_async&&release_edges>=2) stalls++;
    if(csr_error)errors++;
    if(fired&&csr_addr[8]&&!csr_write&&!csr_error&&
       local_addr>=8'h10&&local_addr<=8'h74)
      payload_reads[(int'(local_addr)-16)/4]=1;
    if(dut.tick_accepted)begin
      modes_seen[int'(dut.scheduler_mode_q)]=1;
      states_seen[int'(dut.scheduler_state_q)]=1;
    end
    if (rst_n_async&&release_edges>=2) begin
      recorded+=int'(pending[1]);
      pending={pending[0],dut.tick_accepted};
      accepted+=int'(dut.tick_accepted);
    end
    clk=1;
    if(rst_n_async&&release_edges<2)release_edges++;
    #2; -> check_event; #1;clk=0;#1;cycles++;
  endtask
  task automatic transfer(input bit wr,input logic[8:0] address,input logic[31:0] data,input bit error_expected=0);
    int limit=0;
    do begin
      step(1,wr,address,data);limit++;
      if(limit>5000)$fatal(1,"HOST_TIMEOUT address=%h",address);
    end while(!fired);
    if(failed!==error_expected)$fatal(1,"HOST_ERROR address=%h",address);
  endtask
  task automatic read_snapshot();
    for(int a=4;a<=116;a+=4) transfer(0,9'(256+a),0);
  endtask
  task automatic load_checkpoint(input int unsigned salt);
    transfer(1,0,32'h105);
    transfer(1,9'h06c,624);
    transfer(1,0,32'h400);
    for(int w=0;w<624;w++)begin
      transfer(1,9'h070,32'h80000000^(32'(w)*32'h9e3779b9)^32'(salt));
      if(w%64==0)begin transfer(1,9'h100,1);read_snapshot();end
    end
    transfer(0,9'h074,0);
    if(csr_rdata!=624)$fatal(1,"LOAD_WORD_COUNT");
    transfer(1,0,32'h100);
  endtask
  task automatic withdraw_tick();
    int saved_ticks,limit;
    saved_ticks=accepted;
    // The restored bank is still being prepared; offer one tick then withdraw.
    step(1,1,0,1);
    if(fired || failed)$fatal(1,"WITHDRAW_PRECONDITION");
    limit=0;
    while(!dut.tick_ready)begin
      transfer(0,9'h108,0);
      limit++;
      if(limit>5000)$fatal(1,"WITHDRAW_PREFETCH_TIMEOUT");
    end
    repeat(3)step(0,0,0,0);
    if(accepted!=saved_ticks)$fatal(1,"WITHDRAWN_TICK_EXECUTED");
    read_snapshot();
    withdrawn++;
  endtask

  initial begin
    if((CELLS!=8&&CELLS!=16&&CELLS!=32&&CELLS!=64)||
       (COUNT_BITS!=3&&COUNT_BITS!=64))
      $fatal(1,"Profiles: CELLS=8/16/32/64; COUNT_BITS=3/64");
    if($value$plusargs("seed=%d",seed))begin end
    // Controls before release are discarded; a held capture begins after release.
    rst_n_async=0;held='0;held_valid=0;#1;
    step(1,1,9'h100,1);
    rst_n_async=1;
    step(1,1,9'h100,1);
    step(1,1,9'h100,1);
    if(held_valid)$fatal(1,"EARLY_CAPTURE");
    step(1,1,9'h100,1);read_snapshot();
    transfer(1,9'h100,2);
    transfer(0,9'h110,0,1);
    transfer(1,9'h100,3,1);
    transfer(1,0,1,1);
    transfer(1,9'h004,3,1);
    transfer(1,9'h010,2,1);
    // Exercise every bank-1 byte address before configuration.
    transfer(1,9'h100,1);
    for(int a=0;a<256;a++)
      transfer(0,9'(256+a),0,!(a>=4&&a<=116&&a%4==0));
    for(int a=0;a<256;a++)transfer(1,9'(256+a),3,1);
    load_checkpoint(seed);
    for(int mode=0;mode<3;mode++)begin
      transfer(1,9'h004,32'(mode));
      step(0,0,0,0);
      for(int c=0;c<CELLS;c++)begin
        transfer(1,9'h018,32'(c));
        transfer(1,9'h06c,32'(c)*32'h11111111);
        transfer(1,9'h070,1048576);
      end
      transfer(1,0,8);
      // Direct host requests and rapid accepted ticks across gamma-bank waits.
      transfer(1,9'h008,0);transfer(1,9'h00c,0);
      transfer(1,9'h010,1);transfer(1,9'h014,1);
      for(int k=0;k<24;k++)begin
        transfer(1,0,1);
        if(k%8==0)begin
          transfer(1,9'h100,1);
          transfer(0,9'h110,0);
          transfer(0,9'h118,0);
        end
      end
      repeat(3)step(0,0,0,0);
      transfer(1,9'h100,1);read_snapshot();
      transfer(1,0,2);read_snapshot();
      // Bank selection does not modify any original telemetry page.
      for(int page=0;page<5;page++)begin
        transfer(1,0,32'h100+32'(page>=3?page+1:page));
        transfer(1,9'h100,1);
        transfer(0,9'h0fc,0);
        read_snapshot();
      end
      transfer(1,0,32'h100);
    end
    load_checkpoint(seed ^ 32'd1);read_snapshot();
    withdraw_tick();
    // An incomplete new checkpoint rejects a tick; the snapshot stays readable.
    transfer(1,0,32'h400);
    transfer(1,0,1,1);
    transfer(1,9'h100,1);read_snapshot();
    if(accepted!=recorded || pending!=0 || stalls==0 || captures==0 || frozen==0 || errors==0 ||
       (COUNT_BITS==3 ? !live.overflow : live.overflow) ||
       modes_seen!==3'b111 || states_seen!==5'b11111 || payload_reads!=='1 || withdrawn!=1)
      $fatal(1,"HOST_COVERAGE accepted=%0d recorded=%0d stalls=%0d frozen=%0d",accepted,recorded,stalls,frozen);
    // Reset must asynchronously cancel both bus banks and clear retained history.
    rst_n_async=0;release_edges=0;pending=0;recorded=0;held='0;held_valid=0;#1;
    step(1,1,9'h100,1);
    rst_n_async=1;repeat(2)step(0,0,0,0);
    transfer(0,9'h104,0);
    if(csr_rdata!=0)$fatal(1,"RESET_SNAPSHOT");
    transfer(1,0,1,1);
    if(checks!=2*cycles)$fatal(1,"CHECK_ACCOUNTING");
    $display("PASS INTERNAL_GAMMA_HOST_CSR cells=%0d count_bits=%0d seed=%0d outputs=114 checks=%0d cycles=%0d ticks=%0d stalls=%0d captures=%0d frozen=%0d errors=%0d withdrawn=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,checks,cycles,accepted,stalls,captures,frozen,errors,withdrawn,signature);
    $finish;
  end
  initial begin #1000000;$fatal(1,"WATCHDOG");end
endmodule
`endif

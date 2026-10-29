// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Atomic boundary-snapshot CSR qualification, 18 configurations.
// CELLS = 1/8/9/16/32/64; RECORDER_COUNT_BITS = 1/3/64.
// The scoreboard retains named source fields on an accepted capture command.
// Read expectations are decoded independently from that retained record.
// Check responses before/after each edge and after changing live source fields.
// Exercise every byte address, all captured flag combinations, walking counter
// and bank bits, command priority, idle requests and reset at both clock levels.
// Raw diagnostic field patterns retain all two-bit state encodings verbatim.
// Deterministic xorshift stimulus accepts +seed=<unsigned integer>.
// Build with Verilator --binary --timing --assert -Irtl/m32
// --top-module frp_m32_boundary_snapshot_csr_tb.

`ifndef FRP_M32_BOUNDARY_SNAPSHOT_CSR_TB_SV
`define FRP_M32_BOUNDARY_SNAPSHOT_CSR_TB_SV
`timescale 1ns/1ps
`include "frp_m32_boundary_snapshot_csr.sv"

module frp_m32_boundary_snapshot_csr_case #(
  parameter int CELLS = 8,
  parameter int COUNT_BITS = 64
) (output bit done = 0);
  logic clk = 0, rst_n = 1;
  logic csr_valid = 0, csr_write = 0;
  logic [7:0] csr_addr = 0;
  logic [31:0] csr_wdata = 0;
  logic csr_ready, csr_error;
  logic [31:0] csr_rdata;

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
  sample_t live = '0, held = '0;
  bit held_valid = 0;

  frp_m32_boundary_snapshot_csr #(
    .CELLS(CELLS), .RECORDER_COUNT_BITS(COUNT_BITS)
  ) dut (
    .clk(clk), .rst_n(rst_n), .csr_valid(csr_valid), .csr_write(csr_write),
    .csr_addr(csr_addr), .csr_wdata(csr_wdata), .csr_ready(csr_ready),
    .csr_error(csr_error), .csr_rdata(csr_rdata),
    .record_sample_seen_q(live.seen), .record_sample_count_q(live.count),
    .record_count_overflow_q(live.overflow),
    .record_previous_margin_q16(live.previous_margin),
    .record_minimum_margin_q16(live.minimum_margin),
    .record_minimum_margin_tick_q(live.minimum_tick),
    .record_peak_switch_load_q16(live.peak_switch),
    .record_peak_switch_load_tick_q(live.peak_tick),
    .boundary_valid_q(live.boundary_valid), .boundary_pulse_q(live.boundary_pulse),
    .boundary_tick_q(live.boundary_tick), .boundary_scheduler_mode_q(live.mode),
    .boundary_scheduler_state_q(live.state),
    .boundary_previous_margin_q16(live.boundary_previous),
    .boundary_margin_q16(live.boundary_margin), .boundary_capacity_q16(live.capacity),
    .boundary_pressure_q16(live.pressure), .boundary_mean_heat_q16(live.heat),
    .boundary_switch_load_q16(live.switches),
    .boundary_retained_state_q(live.retained), .boundary_pending_route_q(live.pending),
    .record_alignment_error_q(live.alignment_error)
  );

  int unsigned seed = 76, random_state;
  int cycles = 0, comparisons = 0, captures = 0, replacements = 0;
  int releases = 0, errors = 0, idle_cycles = 0, resets = 0;
  bit [255:0] read_addresses = '0, write_addresses = '0;
  bit [25:0] payload_reads = '0;
  bit [31:0] flag_patterns = '0;
  bit [1:0] reset_levels = '0;
  logic [63:0] signature = 64'hcbf29ce484222325;
  localparam int SOURCE_WORDS = ($bits(sample_t)+31)/32;

  function automatic int unsigned next_random();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 17;
    random_state ^= random_state << 5;
    return random_state;
  endfunction

  task automatic change_source();
    logic [SOURCE_WORDS*32-1:0] raw;
    for (int w=0; w<SOURCE_WORDS; w++) raw[w*32+:32] = next_random();
    live = raw[$bits(sample_t)-1:0];
  endtask

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
    if (!rst_n) return 34'd0;
    if (csr_valid) begin
      if (csr_addr%4 != 0) error = 1;
      else if (csr_write)
        error = !(csr_addr==0 && (csr_wdata==1 || csr_wdata==2));
      else begin
        case (csr_addr)
          8'h04: data = {26'd0,held.alignment_error,held.boundary_pulse,
                         held.boundary_valid,held.overflow,held.seen,held_valid};
          8'h08: data = 32'h46524201;
          8'h0c: data = (32'(COUNT_BITS)<<16) | 32'(CELLS);
          default: begin
            if (!held_valid) error = 1;
            else case (csr_addr)
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

  task automatic compare(input int phase);
    logic [33:0] expected;
    expected = expected_bus();
    if ($isunknown({csr_ready,csr_error,csr_rdata}) ||
        {csr_ready,csr_error,csr_rdata} !== expected)
      $fatal(1,"SNAPSHOT_CSR cells=%0d bits=%0d cycle=%0d phase=%0d addr=%h got=%h expected=%h",
             CELLS,COUNT_BITS,cycles,phase,csr_addr,{csr_ready,csr_error,csr_rdata},expected);
    signature = (signature ^ {20'd0,csr_valid,csr_write,csr_addr,
                               csr_ready,csr_error,csr_rdata}) * 64'h100000001b3;
    comparisons++;
  endtask

  task automatic transfer(input bit valid, input bit write_enable,
                          input logic [7:0] address, input logic [31:0] data);
    logic [33:0] response;
    clk = 0;
    csr_valid = valid;
    csr_write = write_enable;
    csr_addr = address;
    csr_wdata = data;
    #2;
    compare(0);
    response = expected_bus();
    if (!valid) idle_cycles++;
    else begin
      if (write_enable) write_addresses[address] = 1;
      else read_addresses[address] = 1;
      if (response[32]) errors++;
      else if (write_enable) begin
        if (data==1) begin
          if (held_valid) replacements++;
          held = live;
          held_valid = 1;
          captures++;
          flag_patterns[{live.alignment_error,live.boundary_pulse,
                         live.boundary_valid,live.overflow,live.seen}] = 1;
        end else begin
          held = '0;
          held_valid = 0;
          releases++;
        end
      end else if (address>=8'h10 && address<=8'h74)
        payload_reads[(int'(address)-16)/4] = 1;
    end
    clk = 1;
    #2;
    compare(1);
    change_source();
    #2;
    compare(2);
    clk = 0;
    cycles++;
  endtask

  task automatic read_snapshot();
    transfer(1,0,8'h04,0);
    transfer(1,0,8'h08,0);
    transfer(1,0,8'h0c,0);
    for (int address=16; address<=116; address+=4)
      transfer(1,0,8'(address),0);
  endtask

  task automatic reset_async(input bit clock_level);
    csr_valid = 0;
    clk = clock_level;
    rst_n = 1;
    #1;
    rst_n = 0;
    held = '0;
    held_valid = 0;
    csr_valid = 1;
    csr_write = 1;
    csr_addr = 0;
    csr_wdata = 1;
    #1;
    compare(3);
    clk = 0;
    #1;
    clk = 1;
    #1;
    compare(4);
    clk = 0;
    csr_valid = 0;
    rst_n = 1;
    #1;
    compare(5);
    resets++;
    reset_levels[clock_level] = 1;
  endtask

  initial begin
    void'($value$plusargs("seed=%d",seed));
    random_state = seed ^ (32'(CELLS)<<16) ^ 32'(COUNT_BITS);
    if (random_state==0) random_state = 32'h6d2b79f5;
    reset_async(0);
    read_snapshot();
    for (int flags=0; flags<32; flags++) begin
      change_source();
      {live.alignment_error,live.boundary_pulse,live.boundary_valid,
       live.overflow,live.seen} = 5'(flags);
      transfer(1,1,0,1);
      read_snapshot();
    end
    live = '0;
    transfer(1,1,0,1);
    read_snapshot();
    live = '1;
    transfer(1,1,0,1);
    read_snapshot();

    for (int bit_index=0; bit_index<CELLS*2; bit_index++) begin
      live = '0;
      live.retained[bit_index] = 1;
      live.pending = ~live.retained;
      transfer(1,1,0,1);
      for (int address=88; address<=116; address+=4)
        transfer(1,0,8'(address),0);
    end
    for (int bit_index=0; bit_index<COUNT_BITS; bit_index++) begin
      change_source();
      live.count = '0;
      live.count[bit_index] = 1;
      transfer(1,1,0,1);
      transfer(1,0,8'h10,0);
      transfer(1,0,8'h14,0);
    end

    // Every byte address sees a read and each command value 0, 1 and 2.
    for (int address=0; address<256; address++) begin
      transfer(1,0,8'(address),0);
      for (int command=0; command<3; command++)
        transfer(1,1,8'(address),32'(command));
      // Keep a populated copy while probing the remaining invalid writes.
      if (address==0) transfer(1,1,0,1);
    end
    read_snapshot();
    transfer(1,1,0,32'd3);
    transfer(1,1,0,32'd4);
    transfer(1,1,0,32'hffffffff);
    transfer(1,1,0,32'h80000001);
    transfer(1,1,0,32'h80000002);
    read_snapshot();
    for (int k=0; k<8; k++) transfer(1,1,0,1);
    read_snapshot();
    transfer(0,1,0,1);
    transfer(0,1,0,2);
    read_snapshot();
    transfer(1,1,0,2);
    read_snapshot();
    transfer(1,1,0,1);
    read_snapshot();
    reset_async(1);
    read_snapshot();

    for (int k=0; k<1500; k++) begin
      int unsigned choice, random_data;
      logic [7:0] address;
      bit valid, write_enable;
      if (k%127==0) reset_async(1'(k/127));
      choice = next_random()%10;
      if (choice<3) transfer(1,1,0,choice<2 ? 1 : 2);
      else begin
        valid = next_random()%5!=0;
        write_enable = 1'(next_random());
        address = 8'(next_random());
        random_data = next_random();
        transfer(valid,write_enable,address,random_data);
      end
      if (k%31==0) read_snapshot();
    end
    transfer(1,1,0,1);
    read_snapshot();
    transfer(1,1,0,2);
    read_snapshot();

    if (read_addresses!=='1 || write_addresses!=='1 || payload_reads!=='1 ||
        flag_patterns!=='1 || reset_levels!==2'b11 || captures==0 ||
        replacements==0 || releases==0 || errors==0 || idle_cycles==0)
      $fatal(1,"Snapshot CSR scenario coverage cells=%0d bits=%0d",CELLS,COUNT_BITS);
    if (comparisons!=3*(cycles+resets))
      $fatal(1,"Snapshot CSR comparison accounting");
    $display("PASS SNAPSHOT_CSR cells=%0d count_bits=%0d seed=%0d cycles=%0d comparisons=%0d captures=%0d replacements=%0d releases=%0d errors=%0d idle=%0d resets=%0d signature=%016h",
             CELLS,COUNT_BITS,seed,cycles,comparisons,captures,replacements,
             releases,errors,idle_cycles,resets,signature);
    done = 1;
  end
endmodule

module frp_m32_boundary_snapshot_csr_tb;
  wire [17:0] done;
  for (genvar s=0; s<6; s++) begin : sizes
    localparam int N = s==0 ? 1 : s==1 ? 8 : s==2 ? 9 : s==3 ? 16 : s==4 ? 32 : 64;
    for (genvar b=0; b<3; b++) begin : widths
      localparam int B = b==0 ? 1 : b==1 ? 3 : 64;
      frp_m32_boundary_snapshot_csr_case #(.CELLS(N),.COUNT_BITS(B)) test_case (
        .done(done[s*3+b])
      );
    end
  end
  initial begin
    wait (&done);
    $display("PASS SNAPSHOT_CSR_MATRIX configurations=18");
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1,"Snapshot CSR watchdog");
  end
endmodule
`endif

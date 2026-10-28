// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Completed-snapshot recorder qualification: 18 simultaneous configurations.
// CELLS = 1/8/9/16/32/64; COUNT_BITS = 1/3/64.
// Reconstruct all expected outputs from the accepted-snapshot history.
// Exercise asynchronous reset, synchronous clear, hold and clear/sample priority.
// Check first crossing, sticky snapshots, extrema ties and signed endpoints.
// Source tags include duplicates, jumps and wraparound.
// Raw two-bit bank patterns exercise verbatim diagnostic capture.
// Small counters exercise saturation while snapshot recording continues.
// Deterministic xorshift stimulus accepts +seed=<unsigned integer>.
// Build with Verilator --binary --timing --assert -Irtl/m32
// --top-module frp_m32_boundary_recorder_tb.

`ifndef FRP_M32_BOUNDARY_RECORDER_TB_SV
`define FRP_M32_BOUNDARY_RECORDER_TB_SV
`timescale 1ns/1ps
`include "frp_m32_boundary_recorder.sv"

module frp_m32_boundary_recorder_case #(
  parameter int CELLS = 8,
  parameter int COUNT_BITS = 64
) (output bit done = 0);
  localparam longint unsigned COUNT_MAX = 64'hffffffffffffffff >> (64-COUNT_BITS);
  logic clk = 0, rst_n = 1, clear_epoch = 0, sample_valid = 0;

  typedef struct packed {
    logic [63:0] tag;
    logic [1:0] mode;
    logic [2:0] state;
    logic signed [31:0] capacity, pressure, margin, heat, switches;
    logic [2*CELLS-1:0] bank, pending;
  } sample_t;
  sample_t stimulus = '0;
  sample_t history[$];

  typedef struct packed {
    logic sample_seen_q;
    logic [COUNT_BITS-1:0] sample_count_q;
    logic count_overflow_q;
    logic signed [31:0] previous_margin_q16, minimum_margin_q16;
    logic [63:0] minimum_margin_tick_q;
    logic signed [31:0] peak_switch_load_q16;
    logic [63:0] peak_switch_load_tick_q;
    logic boundary_valid_q, boundary_pulse_q;
    logic [63:0] boundary_tick_q;
    logic [1:0] boundary_scheduler_mode_q;
    logic [2:0] boundary_scheduler_state_q;
    logic signed [31:0] boundary_previous_margin_q16, boundary_margin_q16;
    logic signed [31:0] boundary_capacity_q16, boundary_pressure_q16;
    logic signed [31:0] boundary_mean_heat_q16, boundary_switch_load_q16;
    logic [2*CELLS-1:0] boundary_retained_state_q, boundary_pending_route_q;
  } result_t;
  result_t actual, expected;

  frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(COUNT_BITS)) dut (
    .clk(clk), .rst_n(rst_n), .clear_epoch(clear_epoch), .sample_valid(sample_valid),
    .source_tick(stimulus.tag), .scheduler_mode(stimulus.mode),
    .scheduler_state(stimulus.state), .coherence_capacity_q16(stimulus.capacity),
    .pressure_q16(stimulus.pressure), .stability_margin_q16(stimulus.margin),
    .mean_heat_q16(stimulus.heat), .switch_load_q16(stimulus.switches),
    .retained_state(stimulus.bank), .pending_route(stimulus.pending),
    .sample_seen_q(actual.sample_seen_q),
    .sample_count_q(actual.sample_count_q),
    .count_overflow_q(actual.count_overflow_q),
    .previous_margin_q16(actual.previous_margin_q16),
    .minimum_margin_q16(actual.minimum_margin_q16),
    .minimum_margin_tick_q(actual.minimum_margin_tick_q),
    .peak_switch_load_q16(actual.peak_switch_load_q16),
    .peak_switch_load_tick_q(actual.peak_switch_load_tick_q),
    .boundary_valid_q(actual.boundary_valid_q),
    .boundary_pulse_q(actual.boundary_pulse_q),
    .boundary_tick_q(actual.boundary_tick_q),
    .boundary_scheduler_mode_q(actual.boundary_scheduler_mode_q),
    .boundary_scheduler_state_q(actual.boundary_scheduler_state_q),
    .boundary_previous_margin_q16(actual.boundary_previous_margin_q16),
    .boundary_margin_q16(actual.boundary_margin_q16),
    .boundary_capacity_q16(actual.boundary_capacity_q16),
    .boundary_pressure_q16(actual.boundary_pressure_q16),
    .boundary_mean_heat_q16(actual.boundary_mean_heat_q16),
    .boundary_switch_load_q16(actual.boundary_switch_load_q16),
    .boundary_retained_state_q(actual.boundary_retained_state_q),
    .boundary_pending_route_q(actual.boundary_pending_route_q)
  );

  int unsigned seed = 76, random_state;
  int checks = 0, accepted = 0, resets = 0, clears = 0, holds = 0;
  int collisions = 0, crossings = 0, min_ties = 0, peak_ties = 0;
  int overflow_samples = 0, post_overflow_crossings = 0;
  bit [14:0] mode_state_seen = '0;
  bit [3:0] bank_codes_seen = '0, pending_codes_seen = '0;
  logic [63:0] signature = 64'hcbf29ce484222325;
  localparam int HASH_WORDS = ($bits(result_t)+31)/32;

  function automatic int unsigned next_random();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 17;
    random_state ^= random_state << 5;
    return random_state;
  endfunction

  task automatic random_snapshot();
    logic [31:0] high_tag, low_tag;
    high_tag = next_random();
    low_tag = next_random();
    stimulus.tag = {high_tag,low_tag};
    stimulus.mode = 2'(next_random()%3);
    stimulus.state = 3'(next_random()%5);
    stimulus.capacity = next_random();
    stimulus.pressure = next_random();
    stimulus.margin = next_random();
    stimulus.heat = next_random();
    stimulus.switches = next_random();
    for (int c=0; c<CELLS; c++) begin
      stimulus.bank[c*2+:2] = 2'(next_random());
      stimulus.pending[c*2+:2] = 2'(next_random());
    end
  endtask

  // Batch reference: scan accepted samples in arrival order on every check.
  task automatic reconstruct(input bit new_sample);
    int first_cross;
    int signed previous;
    longint unsigned count;
    sample_t item;
    expected = '0;
    expected.previous_margin_q16 = 39322;
    count = 64'(history.size());
    expected.sample_seen_q = (count != 0);
    expected.sample_count_q = COUNT_BITS'(count > COUNT_MAX ? COUNT_MAX : count);
    expected.count_overflow_q = (count > COUNT_MAX);
    first_cross = -1;
    previous = 39322;
    for (int i=0; i<history.size(); i++) begin
      item = history[i];
      if (i==0 || item.margin < expected.minimum_margin_q16) begin
        expected.minimum_margin_q16 = item.margin;
        expected.minimum_margin_tick_q = item.tag;
      end
      if (i==0 || item.switches > expected.peak_switch_load_q16) begin
        expected.peak_switch_load_q16 = item.switches;
        expected.peak_switch_load_tick_q = item.tag;
      end
      if (first_cross < 0 && previous > 0 && item.margin <= 0) begin
        first_cross = i;
        expected.boundary_valid_q = 1;
        expected.boundary_tick_q = item.tag;
        expected.boundary_scheduler_mode_q = item.mode;
        expected.boundary_scheduler_state_q = item.state;
        expected.boundary_previous_margin_q16 = previous;
        expected.boundary_margin_q16 = item.margin;
        expected.boundary_capacity_q16 = item.capacity;
        expected.boundary_pressure_q16 = item.pressure;
        expected.boundary_mean_heat_q16 = item.heat;
        expected.boundary_switch_load_q16 = item.switches;
        expected.boundary_retained_state_q = item.bank;
        expected.boundary_pending_route_q = item.pending;
      end
      previous = item.margin;
    end
    expected.previous_margin_q16 = previous;
    expected.boundary_pulse_q = new_sample && first_cross >= 0 &&
                                first_cross == history.size()-1;
  endtask

  task automatic compare();
    logic [HASH_WORDS*32-1:0] words;
    if ($isunknown({actual,expected}) || actual !== expected) begin
      $display("actual=%h expected=%h",actual,expected);
      $fatal(1,"RECORDER cells=%0d bits=%0d check=%0d history=%0d",
             CELLS,COUNT_BITS,checks,history.size());
    end
    words = '0;
    words[$bits(result_t)-1:0] = actual;
    for (int w=0; w<HASH_WORDS; w++)
      signature = (signature ^ {32'b0,words[w*32+:32]}) * 64'h100000001b3;
    checks++;
  endtask

  task automatic step(input bit valid, input bit clear_now);
    sample_valid = valid;
    clear_epoch = clear_now;
    clk = 0;
    #2;
    if (clear_now) begin
      history.delete();
      clears++;
      if (valid) collisions++;
    end else if (valid) begin
      if (history.size()!=0) begin
        if (stimulus.margin == expected.minimum_margin_q16) min_ties++;
        if (stimulus.switches == expected.peak_switch_load_q16) peak_ties++;
      end
      history.push_back(stimulus);
      accepted++;
    end else holds++;
    reconstruct(valid && !clear_now);
    if (valid && !clear_now && expected.count_overflow_q) overflow_samples++;
    if (expected.boundary_pulse_q) begin
      crossings++;
      if (expected.count_overflow_q) post_overflow_crossings++;
      mode_state_seen[int'(stimulus.mode)*5+int'(stimulus.state)] = 1;
      for (int c=0; c<CELLS; c++) begin
        bank_codes_seen[stimulus.bank[c*2+:2]] = 1;
        pending_codes_seen[stimulus.pending[c*2+:2]] = 1;
      end
    end
    clk = 1;
    #2;
    compare();
    clk = 0;
    #2;
  endtask

  task automatic reset_async();
    clk = 0;
    rst_n = 1;
    #1;
    rst_n = 0;
    history.delete();
    reconstruct(0);
    #1;
    compare();
    // Hold reset across a rising edge with sample and clear asserted.
    sample_valid = 1;
    clear_epoch = 1;
    clk = 1;
    #2;
    compare();
    clk = 0;
    sample_valid = 0;
    clear_epoch = 0;
    rst_n = 1;
    #2;
    resets++;
  endtask

  initial begin
    void'($value$plusargs("seed=%d",seed));
    random_state = seed ^ (32'(CELLS)<<16) ^ 32'(COUNT_BITS);
    if (random_state==0) random_state = 32'h6d2b79f5;
    reset_async();
    step(0,0);

    // Every scheduler metadata pair captures all raw two-bit bank codes.
    for (int mode=0; mode<3; mode++)
      for (int state=0; state<5; state++)
        for (int code=0; code<4; code++) begin
          random_snapshot();
          step(1,1);
          stimulus.mode = 2'(mode);
          stimulus.state = 3'(state);
          for (int c=0; c<CELLS; c++) begin
            stimulus.bank[c*2+:2] = 2'((code+c)%4);
            stimulus.pending[c*2+:2] = 2'((3-code+c)%4);
          end
          stimulus.tag = 64'hffffffffffffffff;
          stimulus.margin = 32'sh7fffffff;
          stimulus.switches = 32'sh80000000;
          step(1,0);
          stimulus.tag = 0;
          stimulus.margin = code[0] ? -1 : 0;
          stimulus.switches = 32'sh7fffffff;
          step(1,0);
          // Equal extrema retain the first tag, including after saturation.
          stimulus.tag = 123456789;
          step(1,0);
          random_snapshot();
          step(0,0);
          stimulus.margin = 1;
          step(1,0);
          stimulus.margin = 32'sh80000000;
          step(1,0);
          step(1,0);
          step(0,0);
        end

    // First samples at signed endpoints and around zero.
    for (int k=0; k<5; k++) begin
      random_snapshot();
      step(0,1);
      case (k)
        0: stimulus.margin = 32'sh80000000;
        1: stimulus.margin = -1;
        2: stimulus.margin = 0;
        3: stimulus.margin = 1;
        4: stimulus.margin = 32'sh7fffffff;
      endcase
      step(1,0);
      random_snapshot();
      step(0,0);
      reset_async();
    end

    // Reach small-counter saturation before the first boundary crossing.
    step(1,1);
    for (int k=0; k<16; k++) begin
      random_snapshot();
      stimulus.margin = 100-k;
      stimulus.switches = k;
      step(1,0);
    end
    stimulus.margin = 0;
    stimulus.switches = 32'sh7fffffff;
    step(1,0);
    stimulus.margin = 32'sh80000000;
    step(1,0);
    step(0,0);
    reset_async();

    for (int k=0; k<4096; k++) begin
      random_snapshot();
      if (k%17==0 && history.size()!=0) begin
        stimulus.margin = expected.minimum_margin_q16;
        stimulus.switches = expected.peak_switch_load_q16;
      end
      if (k%29==0) stimulus.margin = 0;
      step(k%7!=0, k%53==0);
      if (k%257==256) reset_async();
    end
    step(0,0);
    reset_async();
    random_snapshot();
    stimulus.margin = -1;
    step(1,0);
    step(0,0);

    if (mode_state_seen!==15'h7fff || bank_codes_seen!==4'hf ||
        pending_codes_seen!==4'hf || min_ties==0 || peak_ties==0 ||
        collisions==0 || holds==0 || crossings<60 || resets<20)
      $fatal(1,"Recorder scenario coverage cells=%0d bits=%0d",CELLS,COUNT_BITS);
    if (COUNT_BITS<64 && (overflow_samples==0 || post_overflow_crossings==0))
      $fatal(1,"Recorder saturation coverage cells=%0d bits=%0d",CELLS,COUNT_BITS);
    if (COUNT_BITS==64 && overflow_samples!=0)
      $fatal(1,"Unexpected 64-bit count overflow");
    $display("PASS BOUNDARY_RECORDER cells=%0d count_bits=%0d seed=%0d checks=%0d accepted=%0d resets=%0d clears=%0d holds=%0d collisions=%0d crossings=%0d min_ties=%0d peak_ties=%0d overflow_samples=%0d post_overflow_crossings=%0d signature=%016h",
      CELLS,COUNT_BITS,seed,checks,accepted,resets,clears,holds,collisions,crossings,
      min_ties,peak_ties,overflow_samples,post_overflow_crossings,signature);
    done = 1;
  end
endmodule

module frp_m32_boundary_recorder_tb;
  wire [17:0] done;
  for (genvar s=0; s<6; s++) begin : sizes
    localparam int N = s==0 ? 1 : s==1 ? 8 : s==2 ? 9 : s==3 ? 16 : s==4 ? 32 : 64;
    for (genvar b=0; b<3; b++) begin : widths
      localparam int B = b==0 ? 1 : b==1 ? 3 : 64;
      frp_m32_boundary_recorder_case #(.CELLS(N),.COUNT_BITS(B)) test_case (
        .done(done[s*3+b])
      );
    end
  end
  initial begin
    wait (&done);
    $display("PASS BOUNDARY_RECORDER_MATRIX configurations=18");
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1,"Boundary recorder watchdog");
  end
endmodule
`endif

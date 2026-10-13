 // Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
 // Reference equations: QuantizedReferenceShadowProcessor.update_global_stability
 // and EXP_NEG_Q30 in frp_prototype_v1_7_0.py.
 // Integer reference arithmetic uses division and signed half-away rounding.
 // The exponential oracle is generated from exp(-8 * index / 4095).
 // Checks cover combinational results, committed history and asynchronous reset.
 // Each checker runs independently for CELLS=8, 16 or 32; zero is encoded as 00.
 // Compile top frp_m31_global_stability_tb with timing/assertions and -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_global_stability.sv"

module frp_m31_global_stability_checker #(
  parameter int CELLS = 8
) (
  output logic done = 0
);
  typedef logic signed [31:0] word_t;
  typedef struct packed {
    word_t heat, overload, lag, neutral, argument;
    word_t compression, effective, capacity, pressure, margin;
    logic stable;
  } reference_t;

  localparam word_t MAX32 = 32'sh7fffffff;
  localparam word_t MIN32 = 32'sh80000000;
  localparam word_t ONE30 = 32'sd1073741824;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 1, tick_enable = 0;
  logic [CELLS*2-1:0] retained_state = '0;
  logic [CELLS*32-1:0] heat_q16 = '0;
  logic [CELLS*32-1:0] thermal_overload_q16 = '0;
  logic [CELLS*32-1:0] frequency_lag_q16 = '0;
  word_t raw_phase_coherence_q30 = 0, cluster_coherence_q30 = 0;
  word_t switch_load_q16 = 0;
  word_t mean_heat_q16, mean_thermal_overload_q16, mean_frequency_lag_q16;
  word_t neutral_fraction_q30, compression_arg_q16;
  word_t next_coherence_compression_q30, next_effective_coherence_q30;
  word_t next_coherence_capacity_q16, next_pressure_q16, next_stability_margin_q16;
  logic next_stable;
  word_t coherence_compression_q30, effective_coherence_q30;
  word_t coherence_capacity_q16, pressure_q16, stability_margin_q16;
  logic stable;
  word_t previous_margin_q16;
  frp_m31_global_stability #(.CELLS(CELLS)) dut(.*);

  word_t exponential [0:4095];
  reference_t committed;
  word_t history;
  int steps = 0, checks = 0, commits = 0, holds = 0, resets = 0;
  int rom_checks = 0, random_cases = 0, sweep_cases = 0;
  int half_cases = 0, neutral_cases = 0, threshold_cases = 0;
  int clipped_cases = 0, argument_saturated = 0;
  int pressure_high = 0, pressure_low = 0, margin_high = 0, margin_low = 0;
  int stable_cases = 0, unstable_cases = 0;
  bit [4095:0] address_seen = '0;
  bit [CELLS:0] neutral_seen = '0;
  int unsigned random_state = 32'h71c09e5d;

  function automatic word_t saturate(input longint signed value);
    if (value > 64'sd2147483647) return MAX32;
    if (value < -64'sd2147483648) return MIN32;
    return word_t'(value);
  endfunction

  function automatic longint signed rounded_divide(
    input longint signed value, input longint signed denominator
  );
    if (value < 0) return -((-value + denominator/2)/denominator);
    return (value + denominator/2)/denominator;
  endfunction

  function automatic word_t multiply(
    input word_t left, input word_t right, input int fraction
  );
    longint signed product;
    product = longint'(left) * longint'(right);
    return saturate(rounded_divide(product,64'sd1 << fraction));
  endfunction

  function automatic int exp_address(input word_t argument);
    longint signed clipped;
    clipped = argument;
    if (clipped < 0) clipped = 0;
    if (clipped > 524288) clipped = 524288;
    return int'(rounded_divide(clipped*4095,524288));
  endfunction

  function automatic reference_t expected();
    reference_t r;
    longint signed hs, os, ls, zeros, deficit, capacity;
    word_t thermal_square, margin_square;
    hs=0; os=0; ls=0; zeros=0;
    for (int c=0;c<CELLS;c++) begin
      hs += longint'($signed(heat_q16[c*32+:32]));
      os += longint'($signed(thermal_overload_q16[c*32+:32]));
      ls += longint'($signed(frequency_lag_q16[c*32+:32]));
      if (retained_state[c*2+:2] == 2'b00) zeros++;
    end
    r.heat = saturate(rounded_divide(hs,CELLS));
    r.overload = saturate(rounded_divide(os,CELLS));
    r.lag = saturate(rounded_divide(ls,CELLS));
    r.neutral = saturate(rounded_divide(zeros*1073741824,CELLS));
    deficit = 64'sd16384-longint'(history);
    if (deficit < 0) deficit=0;
    margin_square = saturate(rounded_divide(deficit*deficit,65536));
    thermal_square = multiply(r.overload,r.overload,16);
    r.argument = saturate(longint'(multiply(196608,thermal_square,16))
                         +longint'(multiply(98304,margin_square,16)));
    r.compression = exponential[exp_address(r.argument)];
    r.effective = multiply(raw_phase_coherence_q30,r.compression,30);
    capacity = 53740;
    capacity += longint'(multiply(22282,r.effective,30));
    capacity += longint'(multiply(10486,cluster_coherence_q30,30));
    capacity += longint'(multiply(5243,r.neutral,30));
    capacity -= longint'(multiply(6554,r.lag,16));
    r.capacity = saturate(capacity);
    r.pressure = saturate(longint'(r.heat)+longint'(switch_load_q16));
    r.margin = saturate(longint'(r.capacity)-longint'(r.pressure));
    r.stable = r.margin > 0;
    return r;
  endfunction

  task automatic equal_word(input string field, input word_t actual, wanted);
    checks++;
    if (actual !== wanted)
      $fatal(1,"cells=%0d step=%0d %s actual=%0d expected=%0d history=%0d",
             CELLS,steps,field,actual,wanted,history);
  endtask

  task automatic check_next(input reference_t r);
    equal_word("mean_heat",mean_heat_q16,r.heat);
    equal_word("mean_overload",mean_thermal_overload_q16,r.overload);
    equal_word("mean_lag",mean_frequency_lag_q16,r.lag);
    equal_word("neutral_fraction",neutral_fraction_q30,r.neutral);
    equal_word("compression_argument",compression_arg_q16,r.argument);
    equal_word("next_compression",next_coherence_compression_q30,r.compression);
    equal_word("next_effective",next_effective_coherence_q30,r.effective);
    equal_word("next_capacity",next_coherence_capacity_q16,r.capacity);
    equal_word("next_pressure",next_pressure_q16,r.pressure);
    equal_word("next_margin",next_stability_margin_q16,r.margin);
    equal_word("next_stable",{31'b0,next_stable},{31'b0,r.stable});
  endtask

  task automatic check_registered();
    equal_word("compression",coherence_compression_q30,committed.compression);
    equal_word("effective",effective_coherence_q30,committed.effective);
    equal_word("capacity",coherence_capacity_q16,committed.capacity);
    equal_word("pressure",pressure_q16,committed.pressure);
    equal_word("margin",stability_margin_q16,committed.margin);
    equal_word("stable",{31'b0,stable},{31'b0,committed.stable});
    equal_word("previous_margin",previous_margin_q16,history);
  endtask

  task automatic clear_inputs();
    retained_state='0; heat_q16='0; thermal_overload_q16='0;
    frequency_lag_q16='0; raw_phase_coherence_q30=0;
    cluster_coherence_q30=0; switch_load_q16=0;
  endtask

  task automatic fill(input word_t heat, overload, lag);
    for (int c=0;c<CELLS;c++) begin
      heat_q16[c*32+:32]=heat;
      thermal_overload_q16[c*32+:32]=overload;
      frequency_lag_q16[c*32+:32]=lag;
    end
  endtask

  task automatic reset_model();
    committed='0;
    committed.compression=ONE30; committed.capacity=65536;
    committed.pressure=3277; committed.margin=62259; committed.stable=1;
    history=39322;
  endtask

  task automatic reset_dut();
    @(negedge clk); tick_enable=1;
    #2; rst_n=0; reset_model();
    #1; check_registered();
    @(posedge clk); #1; check_registered();
    @(negedge clk); rst_n=1; tick_enable=0;
    #1; check_next(expected());
    resets++;
  endtask

  task automatic sample(input bit commit_sample);
    reference_t before_edge;
    int zero_count;
    @(negedge clk); tick_enable=commit_sample;
    #1; before_edge=expected(); check_next(before_edge);
    address_seen[exp_address(before_edge.argument)]=1;
    zero_count=0;
    for (int c=0;c<CELLS;c++)
      if (retained_state[c*2+:2] == 0) zero_count++;
    neutral_seen[zero_count]=1;
    if (before_edge.argument > 524288) clipped_cases++;
    if (before_edge.argument == MAX32) argument_saturated++;
    if (before_edge.pressure == MAX32) pressure_high++;
    if (before_edge.pressure == MIN32) pressure_low++;
    if (before_edge.margin == MAX32) margin_high++;
    if (before_edge.margin == MIN32) margin_low++;
    if (before_edge.stable) stable_cases++; else unstable_cases++;
    @(posedge clk);
    if (commit_sample) begin
      committed=before_edge; history=before_edge.margin; commits++;
    end else holds++;
    #1; check_registered(); check_next(expected());
    steps++;
  endtask

  function automatic int unsigned random_word();
    random_state ^= random_state << 13;
    random_state ^= random_state >> 17;
    random_state ^= random_state << 5;
    return random_state;
  endfunction

  task automatic random_inputs(input bit full_range);
    int unsigned u;
    for (int c=0;c<CELLS;c++) begin
      u=random_word()%3;
      retained_state[c*2+:2]=(u==0)?2'b00:((u==1)?2'b01:2'b11);
      heat_q16[c*32+:32]=full_range?random_word():(random_word()%262145);
      thermal_overload_q16[c*32+:32]=full_range?random_word():(random_word()%131073);
      frequency_lag_q16[c*32+:32]=full_range?random_word():(random_word()%131073);
    end
    raw_phase_coherence_q30=word_t'(full_range?random_word():(random_word()%1073741825));
    cluster_coherence_q30=word_t'(full_range?random_word():(random_word()%1073741825));
    switch_load_q16=word_t'(full_range?random_word():(random_word()%65537));
  endtask

  initial begin : regression
    reference_t r;
    real value;
    word_t wanted, held_margin;
    if (!(CELLS inside {8,16,32})) $fatal(1,"Unsupported CELLS");
    for (int index=0;index<4096;index++) begin
      value=$exp(-(8.0*real'(index)/4095.0))*1073741824.0;
      exponential[index]=word_t'($rtoi($floor(value+0.5)));
    end
    #1;
    for (int index=0;index<4096;index++) begin
      equal_word($sformatf("exp_rom[%0d]",index),word_t'(dut.exp_rom[index]),exponential[index]);
      rom_checks++;
    end
    reset_dut(); clear_inputs();

    // Every possible active-zero population, with +1 and -1 in other cells.
    for (int zeros=0;zeros<=CELLS;zeros++) begin
      for (int c=0;c<CELLS;c++)
        retained_state[c*2+:2]=(c<zeros)?2'b00:((c%2)?2'b01:2'b11);
      raw_phase_coherence_q30=ONE30; cluster_coherence_q30=ONE30;
      sample(1); neutral_cases++;
    end

    // Signed mean rounding immediately below, at and above every selected tie.
    for (int sign_index=0;sign_index<2;sign_index++) begin
      for (int integer_part=0;integer_part<8;integer_part++) begin
        for (int offset=-1;offset<=1;offset++) begin
          clear_inputs();
          wanted=word_t'(integer_part*CELLS+CELLS/2+offset);
          if (sign_index) wanted=-wanted;
          heat_q16[0+:32]=wanted;
          thermal_overload_q16[0+:32]=wanted;
          frequency_lag_q16[0+:32]=wanted;
          sample(1); half_cases++;
        end
      end
    end

    // Reach selected history values through committed pressure, then hold.
    for (int boundary=0;boundary<2;boundary++) begin
      for (int offset=-1;offset<=1;offset++) begin
        clear_inputs(); reset_dut();
        r=expected(); wanted=word_t'((boundary?16384:0)+offset);
        switch_load_q16=word_t'(longint'(r.capacity)-longint'(wanted));
        sample(1); equal_word("directed_history",history,wanted);
        sample(0); threshold_cases++;
      end
    end

    // INT32_MIN history requires a signed difference wider than 32 bits.
    clear_inputs(); fill(MAX32,MAX32,MAX32); switch_load_q16=MAX32;
    sample(1); equal_word("minimum_history",history,MIN32);
    sample(0);
    fill(MIN32,MIN32,MIN32); switch_load_q16=MIN32;
    sample(1); equal_word("maximum_history",history,MAX32);
    sample(0);

    // Sweep thermal overload with fixed reset history: all ROM addresses
    // must be reached through the public input-to-address calculation.
    clear_inputs(); reset_dut(); raw_phase_coherence_q30=ONE30;
    held_margin=history;
    for (int overload=0;overload<=110000;overload++) begin
      fill(0,word_t'(overload),0);
      sample(0); sweep_cases++;
    end
    equal_word("sweep_history_retained",history,held_margin);
    if (address_seen !== {4096{1'b1}}) $fatal(1,"Missing exponential address");

    // Deterministic operational-range and signed full-range sequences.
    for (int range_mode=0;range_mode<2;range_mode++) begin
      for (int iteration=0;iteration<4096;iteration++) begin
        random_inputs(range_mode!=0);
        if (iteration%257==0) reset_dut();
        sample((iteration%11)!=0); random_cases++;
      end
    end
    clear_inputs(); reset_dut(); sample(0); sample(1);
    if (neutral_seen !== {(CELLS+1){1'b1}}) $fatal(1,"Missing zero population");
    if (rom_checks!=4096 || sweep_cases!=110001 || random_cases!=8192)
      $fatal(1,"Incomplete vector counts");
    if (half_cases!=48 || neutral_cases!=CELLS+1 || threshold_cases!=6)
      $fatal(1,"Incomplete directed counts");
    if (commits+holds!=steps || resets!=41) $fatal(1,"Incomplete sequencing");
    if (!(clipped_cases && argument_saturated && pressure_high && pressure_low
          && margin_high && margin_low && stable_cases && unstable_cases))
      $fatal(1,"Missing arithmetic branch");
    $display("PASS GLOBAL_STABILITY cells=%0d steps=%0d checks=%0d commits=%0d holds=%0d resets=%0d rom_words=%0d rom_addresses=%0d sweep=%0d random=%0d half_cases=%0d neutral_cases=%0d thresholds=%0d",
      CELLS,steps,checks,commits,holds,resets,rom_checks,$countones(address_seen),
      sweep_cases,random_cases,half_cases,neutral_cases,threshold_cases);
    done=1;
  end
endmodule

module frp_m31_global_stability_tb;
  wire done8, done16, done32;
  frp_m31_global_stability_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_global_stability_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_global_stability_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS GLOBAL_STABILITY_ALL cells=8,16,32");
    $finish;
  end
  initial begin
    #2000000;
    $fatal(1,"Global stability regression timeout");
  end
endmodule

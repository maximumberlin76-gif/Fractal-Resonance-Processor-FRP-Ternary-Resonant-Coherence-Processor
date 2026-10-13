// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Reference: quantized_level_weights, thermal_weighted_sum_q16 and
// QuantizedReferenceShadowProcessor.update_local_thermal_field in
// frp_prototype_v1_7_0.py, with the default thermal parameters.
// The checker generates its own dyadic weights at exponent 1.20 and keeps
// its own heat/history arrays. Expected values use integer division with
// half-away rounding; each neighbor contribution is rounded separately.
// Frequency lag exercises the complete unsigned 32-bit Q16.16 interface.
// Compile top frp_m31_local_thermal_field_tb with timing and -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_local_thermal_field.sv"

module frp_m31_local_thermal_checker #(
  parameter int CELLS=8
) (
  output logic done=0
);
  typedef logic signed [31:0] word_t;
  typedef struct packed {
    word_t heat, peak, power, dissipation, diffusion, overload;
  } thermal_t;
  localparam int DEPTH=$clog2(CELLS);
  localparam word_t AMBIENT=3277, SOFT_LIMIT=14418;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=1, tick_enable=0;
  logic [CELLS-1:0] switch_activity='0;
  logic [CELLS*32-1:0] frequency_lag_q16='0;
  wire [CELLS*32-1:0] heat_q16, local_heat_peak_q16, generated_power_q16;
  wire [CELLS*32-1:0] thermal_dissipation_q16, thermal_diffusion_q16;
  wire [CELLS*32-1:0] thermal_overload_q16, next_heat_q16, next_overload_q16;
  word_t mean_heat_q16, mean_heat_peak_q16, maximum_local_heat_q16;
  frp_m31_local_thermal_field #(.CELLS(CELLS)) dut(.*);

  thermal_t retained [0:CELLS-1];
  thermal_t candidate [0:CELLS-1];
  word_t weights [1:DEPTH];
  word_t mean_peak=AMBIENT;
  bit [CELLS*CELLS-1:0] pair_seen='0;
  int steps=0, checks=0, commits=0, holds=0, resets=0;
  int hot_sources=0, lag_cases=0, random_cases=0;
  int threshold_cases=0, mean_ties=0, dissipation_ties=0;
  int heating=0, cooling=0, positive_diffusion=0, negative_diffusion=0;
  int overload_samples=0, high_lag_samples=0, retained_peaks=0;
  int unsigned random_state=32'h73ac51e9;

  function automatic word_t saturate(input longint signed value);
    /*verilator no_inline_task*/
    if (value>64'sd2147483647) return 32'sh7fffffff;
    if (value< -64'sd2147483648) return 32'sh80000000;
    return word_t'(value);
  endfunction

  function automatic longint signed rounded_divide(
    input longint signed value, denominator
  );
    /*verilator no_inline_task*/
    if (value<0) return -((-value+denominator/2)/denominator);
    return (value+denominator/2)/denominator;
  endfunction

  function automatic word_t scaled_product(
    input longint signed left, right, denominator
  );
    /*verilator no_inline_task*/
    return saturate(rounded_divide(left*right,denominator));
  endfunction

  function automatic int distance(input int left_index, right_index);
    /*verilator no_inline_task*/
    int differing, depth;
    differing=left_index^right_index; depth=0;
    while (differing!=0) begin
      differing= differing/2; depth++;
    end
    return depth;
  endfunction

  function automatic logic [31:0] lag_for_power(input int power);
    /*verilator no_inline_task*/
    return 32'(rounded_divide(64'(power)*65536,1180));
  endfunction

  task automatic build_weights();
    real normalizer, pair_weight;
    longint signed sum;
    normalizer=0.0;
    for (int d=1;d<=DEPTH;d++) normalizer+=1.0/$pow(real'(d),1.20);
    sum=0;
    for (int d=1;d<=DEPTH;d++) begin
      pair_weight=1.0/(real'(1<<(d-1))*$pow(real'(d),1.20)*normalizer);
      weights[d]=word_t'($rtoi($floor(pair_weight*1073741824.0+0.5)));
      sum+=longint'(weights[d])*(1<<(d-1));
    end
    weights[1]=word_t'(longint'(weights[1])+1073741824-sum);
    for (int c=0;c<CELLS;c++) begin
      sum=0;
      for (int j=0;j<CELLS;j++)
        if (c!=j) sum+=longint'(weights[distance(c,j)]);
      if (sum!=1073741824) $fatal(1,"Reference weight closure cells=%0d",CELLS);
    end
  endtask

  task automatic calculate();
    longint signed weighted, difference, lag, power, heat;
    word_t contribution;
    for (int c=0;c<CELLS;c++) begin
      weighted=0;
      for (int j=0;j<CELLS;j++) begin
        if (c!=j) begin
          difference=longint'(retained[j].heat)-longint'(retained[c].heat);
          contribution=scaled_product(difference,longint'(weights[distance(c,j)]),1073741824);
          weighted+=longint'(contribution);
        end
      end
      candidate[c].diffusion=scaled_product(2294,longint'(saturate(weighted)),65536);
      lag=longint'({32'b0,frequency_lag_q16[c*32+:32]});
      power=118+longint'(scaled_product(1180,lag,65536));
      if (switch_activity[c]) power+=3408;
      candidate[c].power=saturate(power);
      candidate[c].dissipation=word_t'(rounded_divide(longint'(retained[c].heat)-3277,14));
      heat=longint'(retained[c].heat)+longint'(candidate[c].power)
           -longint'(candidate[c].dissipation)+longint'(candidate[c].diffusion);
      candidate[c].heat=saturate(heat);
      if (candidate[c].heat<AMBIENT) candidate[c].heat=AMBIENT;
      candidate[c].overload=(candidate[c].heat>SOFT_LIMIT)?candidate[c].heat-SOFT_LIMIT:0;
      candidate[c].peak=(candidate[c].heat>retained[c].peak)?candidate[c].heat:retained[c].peak;
    end
  endtask

  task automatic equal_word(input string field, input int cell_index,
                            input word_t actual, wanted);
    checks++;
    if (actual!==wanted)
      $fatal(1,"cells=%0d step=%0d cell=%0d %s actual=%0d expected=%0d",
             CELLS,steps,cell_index,field,actual,wanted);
  endtask

  task automatic check_candidate();
    for (int c=0;c<CELLS;c++) begin
      equal_word("next_heat",c,word_t'(next_heat_q16[c*32+:32]),candidate[c].heat);
      equal_word("next_overload",c,word_t'(next_overload_q16[c*32+:32]),candidate[c].overload);
    end
  endtask

  task automatic check_retained();
    longint signed sum;
    word_t maximum;
    sum=0; maximum=AMBIENT;
    for (int c=0;c<CELLS;c++) begin
      equal_word("heat",c,word_t'(heat_q16[c*32+:32]),retained[c].heat);
      equal_word("peak",c,word_t'(local_heat_peak_q16[c*32+:32]),retained[c].peak);
      equal_word("power",c,word_t'(generated_power_q16[c*32+:32]),retained[c].power);
      equal_word("dissipation",c,word_t'(thermal_dissipation_q16[c*32+:32]),retained[c].dissipation);
      equal_word("diffusion",c,word_t'(thermal_diffusion_q16[c*32+:32]),retained[c].diffusion);
      equal_word("overload",c,word_t'(thermal_overload_q16[c*32+:32]),retained[c].overload);
      sum+=longint'(retained[c].heat);
      if (retained[c].peak>maximum) maximum=retained[c].peak;
    end
    equal_word("mean_heat",-1,mean_heat_q16,word_t'(rounded_divide(sum,64'(CELLS))));
    equal_word("mean_peak",-1,mean_heat_peak_q16,mean_peak);
    equal_word("historical_maximum",-1,maximum_local_heat_q16,maximum);
  endtask

  task automatic reset_model();
    for (int c=0;c<CELLS;c++) begin
      retained[c]='0;
      retained[c].heat=AMBIENT; retained[c].peak=AMBIENT;
    end
    mean_peak=AMBIENT;
  endtask

  task automatic clear_inputs();
    switch_activity='0; frequency_lag_q16='0;
  endtask

  task automatic reset_dut();
    @(negedge clk); tick_enable=1;
    #2; rst_n=0; reset_model();
    #1; check_retained();
    @(posedge clk); #1; check_retained();
    @(negedge clk); rst_n=1; tick_enable=0;
    #1; calculate(); check_candidate();
    resets++;
  endtask

  task automatic sample(input bit commit_sample);
    longint signed sum;
    word_t mean;
    @(negedge clk); tick_enable=commit_sample;
    #1; calculate(); check_candidate(); check_retained();
    for (int c=0;c<CELLS;c++) begin
      if (frequency_lag_q16[c*32+31]) high_lag_samples++;
      if (commit_sample) begin
        if (candidate[c].heat>retained[c].heat) heating++;
        if (candidate[c].heat<retained[c].heat) cooling++;
        if (candidate[c].diffusion>0) positive_diffusion++;
        if (candidate[c].diffusion<0) negative_diffusion++;
        if (candidate[c].overload>0) overload_samples++;
        if (candidate[c].heat<retained[c].peak) retained_peaks++;
      end
    end
    @(posedge clk);
    if (commit_sample) begin
      sum=0;
      for (int c=0;c<CELLS;c++) begin
        retained[c]=candidate[c]; sum+=longint'(candidate[c].heat);
      end
      mean=word_t'(rounded_divide(sum,64'(CELLS)));
      if (mean>mean_peak) mean_peak=mean;
      commits++;
    end else holds++;
    #1; check_retained(); calculate(); check_candidate();
    steps++;
  endtask

  function automatic int unsigned random_word();
    random_state^=random_state<<13;
    random_state^=random_state>>17;
    random_state^=random_state<<5;
    return random_state;
  endfunction

  function automatic logic [31:0] lag_boundary(input int index);
    case (index)
      0:return 0; 1:return 1; 2:return 27; 3:return 28;
      4:return 32767; 5:return 32768; 6:return 65535;
      7:return 65536; 8:return 65537; 9:return 32'h7fffffff;
      10:return 32'h80000000; 11:return 32'h80000001;
      12:return 32'hfffffffe; default:return 32'hffffffff;
    endcase
  endfunction

  initial begin : regression
    word_t target, excess;
    int population;
    if (!(CELLS inside {8,16,32})) $fatal(1,"Unsupported CELLS");
    build_weights(); reset_dut();

    // Uniform heat retains zero diffusion during heating and cooling.
    for (int stage=0;stage<3;stage++) begin
      switch_activity=(stage==1)?'1:'0;
      repeat(256) begin
        sample(1);
        for (int c=0;c<CELLS;c++)
          equal_word("uniform_diffusion",c,word_t'(thermal_diffusion_q16[c*32+:32]),0);
      end
    end

    // Reach each overload threshold through unsigned lag power from reset.
    for (int delta=-1;delta<=1;delta++) begin
      clear_inputs(); reset_dut(); target=SOFT_LIMIT+delta;
      for (int c=0;c<CELLS;c++)
        frequency_lag_q16[c*32+:32]=lag_for_power(int'(target)-3277-118);
      sample(1);
      for (int c=0;c<CELLS;c++) begin
        equal_word("soft_limit_heat",c,word_t'(heat_q16[c*32+:32]),target);
        equal_word("soft_limit_overload",c,word_t'(thermal_overload_q16[c*32+:32]),(delta>0)?1:0);
      end
      threshold_cases++;
    end

    // Mean ties use a one-unit heat difference in selected cells.
    for (int delta=-1;delta<=1;delta++) begin
      clear_inputs(); reset_dut(); population=CELLS/2+delta;
      for (int c=0;c<population;c++) frequency_lag_q16[c*32+:32]=lag_for_power(1);
      sample(1);
      equal_word("mean_half_boundary",-1,mean_heat_q16,word_t'(3395+((delta<0)?0:1)));
      mean_ties++;
    end

    // Dissipation ties are reached through ordinary input transactions.
    for (int k=9;k<=11;k++) begin
      for (int delta=-1;delta<=1;delta++) begin
        clear_inputs(); reset_dut(); excess=word_t'(14*k+7+delta);
        for (int c=0;c<CELLS;c++) frequency_lag_q16[c*32+:32]=lag_for_power(int'(excess)-118);
        sample(1); clear_inputs(); sample(1);
        for (int c=0;c<CELLS;c++)
          equal_word("dissipation_half_boundary",c,word_t'(thermal_dissipation_q16[c*32+:32]),word_t'(k+((delta<0)?0:1)));
        dissipation_ties++;
      end
    end

    // Every source heats alone, then diffuses to every other cell.
    for (int source=0;source<CELLS;source++) begin
      clear_inputs(); reset_dut();
      frequency_lag_q16[source*32+:32]=32'h40000000;
      switch_activity[source]=1;
      sample(1); clear_inputs(); sample(1);
      for (int destination=0;destination<CELLS;destination++) begin
        if (destination!=source) begin
          if (word_t'(thermal_diffusion_q16[destination*32+:32])<=0)
            $fatal(1,"Missing diffusion cells=%0d source=%0d destination=%0d",CELLS,source,destination);
          pair_seen[source*CELLS+destination]=1;
        end else if (word_t'(thermal_diffusion_q16[destination*32+:32])>=0)
          $fatal(1,"Hot source did not lose heat by diffusion");
      end
      repeat(32) sample(1);
      hot_sources++;
    end

    // Walking switch masks and lag words crossing the unsigned sign boundary.
    for (int boundary=0;boundary<14;boundary++) begin
      for (int c=0;c<CELLS;c++) begin
        clear_inputs(); switch_activity[c]=1;
        frequency_lag_q16[c*32+:32]=lag_boundary(boundary);
        sample(1); lag_cases++;
        switch_activity=~switch_activity;
        frequency_lag_q16=~frequency_lag_q16;
        sample(0);
      end
    end

    // Deterministic operational-range and complete unsigned-range lag inputs.
    for (int range_mode=0;range_mode<2;range_mode++) begin
      for (int iteration=0;iteration<2048;iteration++) begin
        for (int c=0;c<CELLS;c++) begin
          switch_activity[c]=1'(random_word());
          frequency_lag_q16[c*32+:32]=range_mode?random_word():(random_word()%262145);
        end
        if (iteration%257==0) reset_dut();
        sample((iteration%7)!=0); random_cases++;
      end
    end
    clear_inputs(); reset_dut(); sample(0); sample(1);
    if (hot_sources!=CELLS || $countones(pair_seen)!=CELLS*(CELLS-1))
      $fatal(1,"Incomplete directed diffusion pairs");
    if (lag_cases!=14*CELLS || random_cases!=4096 || threshold_cases!=3
        || mean_ties!=3 || dissipation_ties!=9) $fatal(1,"Incomplete vectors");
    if (steps!=commits+holds || resets!=CELLS+33) $fatal(1,"Incomplete sequencing");
    if (!(heating>0 && cooling>0 && positive_diffusion>0 && negative_diffusion>0
          && overload_samples>0 && high_lag_samples>0 && retained_peaks>0))
      $fatal(1,"Missing thermal event");
    $display("PASS LOCAL_THERMAL cells=%0d steps=%0d checks=%0d commits=%0d holds=%0d resets=%0d diffusion_pairs=%0d lag_cases=%0d random=%0d thresholds=%0d mean_ties=%0d dissipation_ties=%0d",
      CELLS,steps,checks,commits,holds,resets,$countones(pair_seen),lag_cases,
      random_cases,threshold_cases,mean_ties,dissipation_ties);
    done=1;
  end
endmodule

module frp_m31_local_thermal_field_tb;
  wire done8,done16,done32;
  frp_m31_local_thermal_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_local_thermal_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_local_thermal_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS LOCAL_THERMAL_ALL cells=8,16,32");
    $finish;
  end
  initial begin
    #200000;
    $fatal(1,"Local thermal regression timeout");
  end
endmodule

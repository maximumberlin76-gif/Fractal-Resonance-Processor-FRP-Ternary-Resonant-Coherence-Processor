// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Reference: QuantizedReferenceShadowProcessor.update_local_gamma_drift
// in frp_prototype_v1_7_0.py, with the default correlation and gain.
// Independent retained state; expected values use signed integer division.
// Phase conversion splits the constant into quotient and remainder so that
// the reference needs no product wider than 64 bits or DUT package helpers.
// Signed interface stress includes negative overload words. Physical-range
// vectors use nonnegative overload. No internal DUT state is read or forced.
// Compile top frp_m31_local_gamma_drift_tb with timing and -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"

module frp_m31_local_gamma_checker #(parameter int CELLS=8)(
  output logic done=0
);
  typedef logic signed [31:0] word_t;
  typedef struct packed { word_t target, noise, drift, effective; } state_t;
  localparam word_t NOMINAL=644245094;
  logic clk=0, rst_n=1, tick_enable=0, gamma_update_valid=0;
  logic [CELLS*32-1:0] gamma_targets_q16='0, thermal_overload_q16='0;
  wire [CELLS*32-1:0] gamma_noise_target_q16, gamma_noise_state_q16;
  wire [CELLS*32-1:0] gamma_drift_word, gamma_effective_word;
  wire [CELLS*32-1:0] next_gamma_drift_word, next_gamma_effective_word;
  frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut(.*);
  state_t retained[0:CELLS-1], candidate[0:CELLS-1];
  longint signed delta[0:CELLS-1], gain_product[0:CELLS-1];
  longint signed drift_product[0:CELLS-1], phase_full[0:CELLS-1];
  int steps=0, checks=0, commits=0, holds=0, resets=0;
  int target_sweep=0, overload_sweep=0, random_cases=0, isolated_cells=0;
  int wide_positive=0, wide_negative=0, saturated_positive=0, saturated_negative=0;
  int phase_positive_wrap=0, phase_negative_wrap=0, effective_wrap=0;
  int correlation_ties=0, gain_ties=0, drift_ties=0;
  int held_valid=0, retained_target_ticks=0;
  bit [3:0] controls_seen='0;
  int unsigned random_state=32'h75a19c3d;

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

  function automatic longint signed phase_conversion(input word_t radians);
    /*verilator no_inline_task*/
    longint signed magnitude, converted;
    magnitude=longint'(radians);
    if (magnitude<0) magnitude=-magnitude;
    // 44798133900177 = 10430 * 4294967296 + 1625002897.
    converted=magnitude*64'sd10430
      +(magnitude*64'sd1625002897+64'sd2147483648)/64'sd4294967296;
    return (radians<0)?-converted:converted;
  endfunction

  function automatic int unsigned random_word();
    random_state^=random_state<<13;
    random_state^=random_state>>17;
    random_state^=random_state<<5;
    return random_state;
  endfunction

  function automatic word_t boundary(input int index);
    case(index)
      0:return 32'sh80000000; 1:return -2147483647;
      2:return -65537; 3:return -65536; 4:return -32768;
      5:return -16384; 6:return -4; 7:return -3; 8:return -1;
      9:return 0; 10:return 1; 11:return 3; 12:return 4;
      13:return 16384; 14:return 32768; 15:return 65536;
      16:return 65537; 17:return 2147483646;
      default:return 2147483647;
    endcase
  endfunction

  task automatic model_candidate();
    longint signed increment, sum;
    word_t gain, radians;
    for (int c=0;c<CELLS;c++) begin
      candidate[c].target=gamma_update_valid
        ?word_t'(gamma_targets_q16[c*32+:32]):retained[c].target;
      delta[c]=longint'(candidate[c].target)-longint'(retained[c].noise);
      increment=longint'(saturate(rounded_divide(delta[c]*9830,65536)));
      sum=longint'(retained[c].noise)+increment;
      candidate[c].noise=saturate(sum);
      gain_product[c]=64'sd5243*longint'(word_t'(thermal_overload_q16[c*32+:32]));
      gain=saturate(rounded_divide(gain_product[c],65536));
      drift_product[c]=longint'(gain)*longint'(candidate[c].noise);
      radians=saturate(rounded_divide(drift_product[c],65536));
      phase_full[c]=phase_conversion(radians);
      candidate[c].drift=word_t'(phase_full[c]);
      candidate[c].effective=word_t'(longint'(NOMINAL)+longint'(candidate[c].drift));
    end
  endtask

  task automatic equal_word(input string label, input int cell_index,
                            input word_t actual, expected);
    checks++;
    if (actual!==expected)
      $fatal(1,"GAMMA cells=%0d step=%0d cell=%0d %s got=%0d expected=%0d",
        CELLS,steps,cell_index,label,actual,expected);
  endtask

  task automatic check_ports();
    for (int c=0;c<CELLS;c++) begin
      equal_word("target",c,word_t'(gamma_noise_target_q16[c*32+:32]),retained[c].target);
      equal_word("noise",c,word_t'(gamma_noise_state_q16[c*32+:32]),retained[c].noise);
      equal_word("drift",c,word_t'(gamma_drift_word[c*32+:32]),retained[c].drift);
      equal_word("effective",c,word_t'(gamma_effective_word[c*32+:32]),retained[c].effective);
      equal_word("next_drift",c,word_t'(next_gamma_drift_word[c*32+:32]),candidate[c].drift);
      equal_word("next_effective",c,word_t'(next_gamma_effective_word[c*32+:32]),candidate[c].effective);
    end
  endtask

  task automatic record_commit();
    longint signed value;
    for (int c=0;c<CELLS;c++) begin
      if (delta[c]>2147483647) wide_positive++;
      if (delta[c]< -64'sd2147483648) wide_negative++;
      value=rounded_divide(drift_product[c],65536);
      if (value>2147483647) saturated_positive++;
      if (value< -64'sd2147483648) saturated_negative++;
      if (phase_full[c]>2147483647) phase_positive_wrap++;
      if (phase_full[c]< -64'sd2147483648) phase_negative_wrap++;
      if (longint'(NOMINAL)+longint'(candidate[c].drift)>2147483647) effective_wrap++;
      if ((delta[c]*9830)%65536 inside {64'sd32768,-64'sd32768}) correlation_ties++;
      if (gain_product[c]%65536 inside {64'sd32768,-64'sd32768}) gain_ties++;
      if (drift_product[c]%65536 inside {64'sd32768,-64'sd32768}) drift_ties++;
    end
  endtask

  task automatic sample(input bit enable);
    clk=0; tick_enable=enable;
    model_candidate(); #1; check_ports();
    controls_seen[{enable,gamma_update_valid}]=1;
    if (enable) begin
      record_commit(); commits++;
      if (!gamma_update_valid) retained_target_ticks++;
    end else begin
      holds++;
      if (gamma_update_valid) held_valid++;
    end
    #1; clk=1;
    if (enable) for (int c=0;c<CELLS;c++) retained[c]=candidate[c];
    #1; model_candidate(); check_ports();
    #1; clk=0; #1; steps++;
  endtask

  task automatic reset_dut();
    // Assert reset between edges, then retain reset across a rising edge.
    clk=0; rst_n=0;
    for (int c=0;c<CELLS;c++)
      retained[c]='{target:0,noise:0,drift:0,effective:NOMINAL};
    model_candidate(); #1; check_ports();
    clk=1; #1; check_ports();
    clk=0; rst_n=1; #1; check_ports(); resets++;
  endtask

  task automatic uniform_inputs(input word_t target, overload, input bit valid);
    gamma_update_valid=valid;
    for (int c=0;c<CELLS;c++) begin
      gamma_targets_q16[c*32+:32]=target;
      thermal_overload_q16[c*32+:32]=overload;
    end
  endtask

  initial begin : regression
    word_t expected;
    uniform_inputs(0,0,0); reset_dut(); sample(0); sample(1);

    // Small targets exercise the quantized correlation deadband, both signs.
    for (int target=-4;target<=4;target++) begin
      uniform_inputs(word_t'(target),65536,1); reset_dut(); sample(1);
      expected=(target==4)?1:((target== -4)?-1:0);
      for (int c=0;c<CELLS;c++)
        equal_word("first_small_noise",c,word_t'(gamma_noise_state_q16[c*32+:32]),expected);
    end

    // Exact correlation half ties and neighbors, with explicit expected noise.
    for (int sign_value=-1;sign_value<=1;sign_value+=2) begin
      for (int offset=-1;offset<=1;offset++) begin
        uniform_inputs(word_t'(sign_value*(16384+offset)),32768,1);
        reset_dut(); sample(1);
        expected=word_t'(sign_value*((offset<0)?2457:2458));
        for (int c=0;c<CELLS;c++)
          equal_word("correlation_half",c,word_t'(gamma_noise_state_q16[c*32+:32]),expected);
      end
    end

    // Noise 32768 and gain +/-1 produce positive and negative drift half ties.
    for (int sign_value=-1;sign_value<=1;sign_value+=2) begin
      uniform_inputs(218462,word_t'(sign_value*13),1); reset_dut(); sample(1);
      for (int c=0;c<CELLS;c++) begin
        equal_word("half_noise",c,word_t'(gamma_noise_state_q16[c*32+:32]),32768);
        equal_word("drift_half",c,word_t'(gamma_drift_word[c*32+:32]),word_t'(sign_value*10430));
      end
    end

    // Each cell is driven alone; all other cells retain nominal gamma.
    for (int selected=0;selected<CELLS;selected++) begin
      uniform_inputs(0,65536,1); reset_dut();
      gamma_targets_q16[selected*32+:32]=65536; sample(1);
      for (int c=0;c<CELLS;c++) begin
        equal_word("isolated_noise",c,word_t'(gamma_noise_state_q16[c*32+:32]),(c==selected)?9830:0);
        if (c!=selected)
          equal_word("isolated_nominal",c,word_t'(gamma_effective_word[c*32+:32]),NOMINAL);
      end
      // A valid target on a held clock must not replace the retained target.
      gamma_targets_q16=~gamma_targets_q16; sample(0);
      gamma_update_valid=0; sample(1); isolated_cells++;
    end

    // Every pair of signed boundary words, including saturating drift products.
    for (int a=0;a<19;a++) begin
      for (int b=0;b<19;b++) begin
        uniform_inputs(boundary(a),boundary(b),1); reset_dut(); sample(1);
        gamma_targets_q16=~gamma_targets_q16; gamma_update_valid=0; sample(1);
      end
    end

    // Converge near both signed limits, then reverse the target in one tick.
    for (int sign_index=0;sign_index<2;sign_index++) begin
      uniform_inputs((sign_index==0)?32'sh7fffffff:32'sh80000000,65536,1);
      reset_dut(); repeat(160) sample(1);
      gamma_targets_q16=~gamma_targets_q16; sample(1);
      // With zero overload, retained noise still evolves but gamma is nominal.
      thermal_overload_q16='0; gamma_update_valid=0;
      repeat(32) begin
        sample(1);
        for (int c=0;c<CELLS;c++)
          equal_word("zero_overload",c,word_t'(gamma_effective_word[c*32+:32]),NOMINAL);
      end
    end

    // Exhaustive signed 16-bit inputs from reset, packed across independent cells.
    for (int base=-32768;base<32768;base+=CELLS) begin
      uniform_inputs(0,65536,1);
      for (int c=0;c<CELLS;c++) gamma_targets_q16[c*32+:32]=word_t'(base+c);
      reset_dut(); sample(1); target_sweep+=CELLS;
    end
    for (int base=-32768;base<32768;base+=CELLS) begin
      uniform_inputs(218462,0,1);
      for (int c=0;c<CELLS;c++) thermal_overload_q16[c*32+:32]=word_t'(base+c);
      reset_dut(); sample(1); overload_sweep+=CELLS;
    end

    // Fixed-seed physical-range and complete signed-interface histories.
    for (int range_mode=0;range_mode<2;range_mode++) begin
      for (int iteration=0;iteration<4096;iteration++) begin
        gamma_update_valid=1'(random_word());
        for (int c=0;c<CELLS;c++) begin
          gamma_targets_q16[c*32+:32]=(range_mode==0)
            ?word_t'(longint'(random_word()%131073)-65536):word_t'(random_word());
          thermal_overload_q16[c*32+:32]=(range_mode==0)
            ?word_t'(random_word()%262145):word_t'(random_word());
        end
        if (iteration%257==0) reset_dut();
        sample((iteration%5)!=0); random_cases++;
      end
    end
    // Reset takes priority even with valid targets and tick enabled.
    uniform_inputs(32'sh80000000,32'sh7fffffff,1); tick_enable=1;
    reset_dut(); sample(0); sample(1);
    if (controls_seen!=4'b1111 || steps!=commits+holds
        || target_sweep!=65536 || overload_sweep!=65536
        || random_cases!=8192 || isolated_cells!=CELLS)
      $fatal(1,"Incomplete gamma sequence coverage");
    if (!(wide_positive>0 && wide_negative>0 && saturated_positive>0
          && saturated_negative>0 && phase_positive_wrap>0
          && phase_negative_wrap>0 && effective_wrap>0
          && correlation_ties>0 && gain_ties>0 && drift_ties>0
          && held_valid>0 && retained_target_ticks>0))
      $fatal(1,"Missing gamma arithmetic or retention event");
    $display("PASS LOCAL_GAMMA cells=%0d steps=%0d checks=%0d commits=%0d holds=%0d resets=%0d target_sweep=%0d overload_sweep=%0d random=%0d isolated=%0d",
      CELLS,steps,checks,commits,holds,resets,target_sweep,overload_sweep,random_cases,isolated_cells);
    $display("GAMMA_EVENTS cells=%0d wide_pos=%0d wide_neg=%0d sat_pos=%0d sat_neg=%0d phase_pos=%0d phase_neg=%0d effective_wrap=%0d correlation_ties=%0d gain_ties=%0d drift_ties=%0d held_valid=%0d retained_ticks=%0d",
      CELLS,wide_positive,wide_negative,saturated_positive,saturated_negative,
      phase_positive_wrap,phase_negative_wrap,effective_wrap,correlation_ties,
      gain_ties,drift_ties,held_valid,retained_target_ticks);
    done=1;
  end
endmodule

module frp_m31_local_gamma_drift_tb;
  wire done8,done16,done32;
  frp_m31_local_gamma_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_local_gamma_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_local_gamma_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS LOCAL_GAMMA_ALL cells=8,16,32");
    $finish;
  end
  initial begin
    #300000;
    $fatal(1,"Local gamma regression timeout");
  end
endmodule

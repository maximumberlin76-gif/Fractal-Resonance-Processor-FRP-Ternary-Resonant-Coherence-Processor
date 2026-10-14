// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Retained-frequency and phase-step regression for 8, 16 and 32 cells.
// Reference: frp_prototype_v1_7_0.py quantized frequency/phase recurrence.
// Expected frequency, phase and scheduler history are maintained separately.
// Thermal factors are zero to isolate frequency-driven phase evolution.
// The real scheduler supplies free, 7/1 and 1/7 states; the oracle decodes
// their cadence independently. Ternary inputs use 00=0, 01=+1, 11=-1.
// Compile top frp_m31_frequency_multicell_tb with timing and -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"
`include "frp_m31_scheduler.sv"

module frp_m31_frequency_checker #(parameter int CELLS=8)(output logic done=0);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  logic clk=0, rst_n=1, tick_enable=0, load_valid=0;
  logic [CELLS*32-1:0] phase_load='0, frequency_load_q16='0, gamma_effective_word='0;
  logic [CELLS*2-1:0] retained_state='0;
  logic [CELLS-1:0] switch_activity='0;
  wire [CELLS*32-1:0] phase_word_q, frequency_current_q16, coupling_field_q16;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state;
  wire [31:0] tick_index_q;
  wire [2:0] period_index_q;
  frp_m31_scheduler #(.COUNTER_BITS(32)) scheduler(
    .clk, .rst_n, .tick_enable, .clear_counters(1'b0), .scheduler_mode,
    .scheduler_mode_q, .scheduler_state_q(scheduler_state), .tick_index_q,
    .period_index_q, .ticks_recorded_q(), .scheduler_count_free_q(),
    .scheduler_count_balance_q(), .scheduler_count_commit_q(),
    .scheduler_count_excite_q(), .scheduler_count_neutralize_q(),
    .free_enable(), .balance_enable(), .commit_enable(), .excite_enable(),
    .neutralize_enable(), .scheduler_mode_reserved(), .scheduler_state_reserved(),
    .scheduler_valid(), .scheduler_counts_valid()
  );
  frp_m31_phase_interference #(.CELLS(CELLS)) dut(
    .clk, .rst_n, .tick_enable, .load_valid, .phase_load, .frequency_load_q16,
    .gamma_effective_word, .thermal_node_factor_q30({(CELLS*32){1'b0}}),
    .retained_state, .switch_activity, .scheduler_state, .phase_word_q,
    .frequency_current_q16, .coupling_field_q16, .phase_projection_q30(),
    .phase_target(), .pair_coherence_q30(), .cluster_coherence_q30(),
    .global_coherence_q30(), .organization_dispersion_q30(), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(),
    .level_max_coherence_q30(), .level_dispersion_q30()
  );
  word_t frequency[0:CELLS-1];
  logic [31:0] phase[0:CELLS-1];
  logic [31:0] model_tick=0;
  int model_mode=0;
  bit [29:0] cross_seen='0;
  int state_ticks[0:4];
  int steps=0, checks=0, updates=0, loads=0, holds=0, resets=0;
  int load_over_tick=0, mode_changes=0, residue_words=0, random_cases=0;
  int half_positive=0, half_negative=0, wide_delta=0, zero_adapts=0;
  int positive_steps=0, negative_steps=0, phase_wraps=0, convergence=0;
  int unsigned random_state=32'h79d413a7;

  function automatic longint signed rounded_divide(input longint signed value, denominator);
    /*verilator no_inline_task*/
    if (value<0) return -((-value+denominator/2)/denominator);
    return (value+denominator/2)/denominator;
  endfunction

  function automatic word_t saturate(input longint signed value);
    /*verilator no_inline_task*/
    if (value>2147483647) return 32'sh7fffffff;
    if (value< -64'sd2147483648) return 32'sh80000000;
    return word_t'(value);
  endfunction

  function automatic longint signed phase_step(input word_t velocity);
    /*verilator no_inline_task*/
    longint signed magnitude, converted;
    magnitude=longint'(velocity);
    if (magnitude<0) magnitude=-magnitude;
    converted=magnitude*64'sd10430+(magnitude*64'sd1625002897+64'sd2147483648)/64'sd4294967296;
    return (velocity<0)?-converted:converted;
  endfunction

  function automatic int decode(input int mode, input logic [31:0] tick);
    case(mode)
      1:return (tick%8==7)?2:1;
      2:return (tick%8==0)?3:4;
      default:return 0;
    endcase
  endfunction

  function automatic word_t target_frequency(input logic [1:0] state, input bit activity);
    return word_t'(65536+((state==1 || state==3)?3932:0)+(activity?7864:0));
  endfunction

  function automatic int unsigned random_word();
    random_state^=random_state<<13;
    random_state^=random_state>>17;
    random_state^=random_state<<5;
    return random_state;
  endfunction

  function automatic word_t boundary(input int index, input word_t target);
    case(index)
      0:return 32'sh80000000; 1:return -2147483647;
      2:return 2147483647; 3:return 2147483646;
      4:return -65536; 5:return 0;
      6:return target-32769; 7:return target-32768; 8:return target-32767;
      9:return target+32767; 10:return target+32768; 11:return target+32769;
      12:return target-2; 13:return target-1;
      14:return target; 15:return target+1;
      default:return target+2;
    endcase
  endfunction

  task automatic equal_word(input string label, input int cell_index,
                            input logic [31:0] actual, expected);
    checks++;
    if (actual!==expected)
      $fatal(1,"FREQUENCY cells=%0d step=%0d cell=%0d %s got=%h expected=%h",
        CELLS,steps,cell_index,label,actual,expected);
  endtask

  task automatic check_ports();
    for (int c=0;c<CELLS;c++) begin
      equal_word("frequency",c,frequency_current_q16[c*32+:32],frequency[c]);
      equal_word("phase",c,phase_word_q[c*32+:32],phase[c]);
      equal_word("isolated_coupling",c,coupling_field_q16[c*32+:32],0);
    end
    equal_word("scheduler_mode",-1,32'(scheduler_mode_q),32'(model_mode));
    equal_word("scheduler_state",-1,32'(scheduler_state),32'(decode(model_mode,model_tick)));
    equal_word("scheduler_tick",-1,tick_index_q,model_tick);
    equal_word("scheduler_period",-1,32'(period_index_q),model_tick%8);
  endtask

  task automatic advance_model();
    int state, state_index;
    word_t target, next_frequency, velocity;
    longint signed delta, increment, step_word, phase_sum;
    logic [1:0] ternary;
    state=decode(model_mode,model_tick);
    if (load_valid) begin
      for (int c=0;c<CELLS;c++) begin
        frequency[c]=word_t'(frequency_load_q16[c*32+:32]);
        phase[c]=phase_load[c*32+:32];
      end
      loads++;
      if (tick_enable) load_over_tick++;
    end else if (tick_enable) begin
      state_ticks[state]++;
      for (int c=0;c<CELLS;c++) begin
        ternary=retained_state[c*2+:2];
        if (ternary==2) $fatal(1,"Reserved ternary stimulus");
        state_index=(ternary==0)?0:((ternary==1)?1:2);
        cross_seen[state*6+state_index*2+int'(switch_activity[c])]=1;
        target=target_frequency(ternary,switch_activity[c]);
        delta=longint'(target)-longint'(frequency[c]);
        if (delta>2147483647) wide_delta++;
        if ((delta*19661)%65536==32768) half_positive++;
        if ((delta*19661)%65536== -32768) half_negative++;
        increment=longint'(saturate(rounded_divide(delta*19661,65536)));
        next_frequency=saturate(longint'(frequency[c])+increment);
        if (ternary==0 && next_frequency!=frequency[c]) zero_adapts++;
        velocity=word_t'(longint'(saturate(rounded_divide(longint'(next_frequency)*3932,65536)))
          +((state==2)?655:((state==3)?393:197)));
        step_word=phase_step(velocity);
        if (step_word>0) positive_steps++;
        if (step_word<0) negative_steps++;
        phase_sum=longint'({1'b0,phase[c]})+step_word;
        if (phase_sum<0 || phase_sum>=64'sd4294967296) phase_wraps++;
        frequency[c]=next_frequency;
        phase[c]=32'(phase_sum);
      end
      updates++;
    end else holds++;
    if (tick_enable) model_tick++;
    if (model_mode!=int'(scheduler_mode)) mode_changes++;
    model_mode=int'(scheduler_mode);
  endtask

  task automatic sample(input bit enable, load);
    clk=0; tick_enable=enable; load_valid=load;
    #1; check_ports();
    advance_model(); #1; clk=1;
    #1; check_ports(); #1; clk=0; #1; steps++;
  endtask

  task automatic reset_dut();
    clk=0; rst_n=0; model_mode=0; model_tick=0;
    for (int c=0;c<CELLS;c++) begin
      frequency[c]=65536;
      phase[c]=32'(longint'(c)*(64'sd4294967296/CELLS));
    end
    #1; check_ports(); clk=1; #1; check_ports();
    clk=0; rst_n=1; #1; check_ports(); resets++;
  endtask

  task automatic random_inputs();
    logic [1:0] previous, desired;
    int selection;
    for (int c=0;c<CELLS;c++) begin
      previous=retained_state[c*2+:2];
      selection=int'(random_word()%3);
      desired=(selection==0)?2'b00:((selection==1)?2'b01:2'b11);
      if (previous!=0 && desired!=0 && previous!=desired) desired=0;
      retained_state[c*2+:2]=desired;
      switch_activity[c]=(desired!=previous);
      frequency_load_q16[c*32+:32]=random_word();
      phase_load[c*32+:32]=random_word();
      gamma_effective_word[c*32+:32]=random_word();
    end
  endtask

  initial begin : regression
    word_t target;
    longint signed error;
    int expected_count;
    int before_counts[0:4];
    for (int s=0;s<5;s++) state_ticks[s]=0;
    #1; reset_dut(); sample(0,0);
    // Three complete scheduler profiles, 16 periods each, without loads.
    for (int mode=0;mode<3;mode++) begin
      scheduler_mode=frp_m31_scheduler_mode_e'(mode); reset_dut(); sample(0,0);
      for (int s=0;s<5;s++) before_counts[s]=state_ticks[s];
      repeat(128) begin random_inputs(); sample(1,0); end
      for (int s=0;s<5;s++) begin
        expected_count=0;
        if (mode==0 && s==0) expected_count=128;
        if (mode==1) expected_count=(s==1)?112:((s==2)?16:0);
        if (mode==2) expected_count=(s==3)?16:((s==4)?112:0);
        equal_word("cadence_count",s,32'(state_ticks[s]-before_counts[s]),32'(expected_count));
      end
    end

    // Every state/activity pair at signed endpoints and rounding boundaries.
    for (int mode=0;mode<3;mode++) begin
      scheduler_mode=frp_m31_scheduler_mode_e'(mode);
      for (int profile=0;profile<6;profile++) begin
        retained_state='0; sample(0,0);
        for (int c=0;c<CELLS;c++) begin
          retained_state[c*2+:2]=(profile/2==0)?2'b00:((profile/2==1)?2'b01:2'b11);
          switch_activity[c]=1'(profile%2);
        end
        for (int edge_index=0;edge_index<17;edge_index++) begin
          for (int c=0;c<CELLS;c++) begin
            target=target_frequency(retained_state[c*2+:2],switch_activity[c]);
            frequency_load_q16[c*32+:32]=boundary((edge_index+c)%17,target);
            phase_load[c*32+:32]=random_word();
          end
          sample(1,1);
          frequency_load_q16=~frequency_load_q16; phase_load=~phase_load;
          sample(0,0); repeat(8) sample(1,0);
        end
        // Both signed endpoints converge to within one Q16 word of target.
        for (int endpoint=0;endpoint<2;endpoint++) begin
          frequency_load_q16=(endpoint==0)?{CELLS{32'h80000000}}:{CELLS{32'h7fffffff}};
          sample(0,1); repeat(160) sample(1,0);
          for (int c=0;c<CELLS;c++) begin
            target=target_frequency(retained_state[c*2+:2],switch_activity[c]);
            error=longint'(word_t'(frequency_current_q16[c*32+:32]))-longint'(target);
            if (error< -1 || error>1) $fatal(1,"Frequency convergence failed");
          end
          convergence++;
        end
      end
    end

    // Each signed 16-bit delta occurs once; 19661 is odd, so all 65536
    // product residues are represented before half-away rounding.
    for (int base=-32768;base<32768;base+=CELLS) begin
      scheduler_mode=frp_m31_scheduler_mode_e'((base+32768)/512%3);
      for (int c=0;c<CELLS;c++) begin
        retained_state[c*2+:2]=(c%3==0)?2'b00:((c%3==1)?2'b01:2'b11);
        switch_activity[c]=1'(c%2);
        target=target_frequency(retained_state[c*2+:2],switch_activity[c]);
        frequency_load_q16[c*32+:32]=word_t'(longint'(target)-longint'(base+c));
        phase_load[c*32+:32]=random_word();
      end
      sample(0,1); sample(1,0); residue_words+=CELLS;
    end

    for (int iteration=0;iteration<8192;iteration++) begin
      random_inputs(); scheduler_mode=frp_m31_scheduler_mode_e'((iteration/41)%3);
      if (iteration%1021==0) reset_dut();
      sample((iteration%7)!=0,(iteration%97)==0); random_cases++;
    end
    tick_enable=1; load_valid=1; reset_dut(); sample(0,0); sample(1,1); sample(1,0);
    if (cross_seen!=30'h3fffffff || residue_words!=65536 || random_cases!=8192
        || convergence!=36 || steps!=updates+loads+holds || resets!=14)
      $fatal(1,"Incomplete frequency sequence coverage");
    if (!(half_positive>0 && half_negative>0 && wide_delta>0 && zero_adapts>0
          && positive_steps>0 && negative_steps>0 && phase_wraps>0
          && load_over_tick>0 && mode_changes>0)) $fatal(1,"Missing frequency event");
    $display("PASS FREQUENCY_MULTICELL cells=%0d steps=%0d checks=%0d updates=%0d loads=%0d holds=%0d resets=%0d residues=%0d random=%0d convergence=%0d cross=%0d",
      CELLS,steps,checks,updates,loads,holds,resets,residue_words,random_cases,convergence,$countones(cross_seen));
    $display("FREQUENCY_EVENTS cells=%0d half_pos=%0d half_neg=%0d wide_delta=%0d zero_adapts=%0d positive=%0d negative=%0d wraps=%0d load_over_tick=%0d mode_changes=%0d",
      CELLS,half_positive,half_negative,wide_delta,zero_adapts,positive_steps,negative_steps,phase_wraps,load_over_tick,mode_changes);
    done=1;
  end
endmodule

module frp_m31_frequency_multicell_tb;
  wire done8,done16,done32;
  frp_m31_frequency_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_frequency_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_frequency_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS FREQUENCY_MULTICELL_ALL cells=8,16,32");
    $finish;
  end
  initial begin #1000000; $fatal(1,"Frequency regression timeout"); end
endmodule

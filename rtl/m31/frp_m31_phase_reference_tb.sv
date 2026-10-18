// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// This testbench is proprietary and is not licensed under Apache-2.0.
// Included dependencies retain their existing licenses.
// Paired phase trajectories under common phase-reference offsets.
// Relative coupling and frequency must agree for every tested offset.
// Quarter-turn offsets also preserve all multiscale coherence outputs.
// Retained ternary state, activity, gamma and thermal factors are shared inputs.
// Absolute phase projections and boundary targets are checked separately.
// The recurrence oracle uses independent integer arithmetic and the sampled
// coupling output; coupling itself is checked by the paired relation.
// Compile from the repository root with --binary --timing --assert -Irtl/m31
// --top-module frp_m31_phase_reference_tb -GCELLS=8 (or 16, 32, 64).

`timescale 1ns/1ps
`include "frp_m31_phase_interference.sv"

module frp_m31_phase_reference_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  typedef logic signed [31:0] word_t;
  typedef logic signed [127:0] wide_t;
  typedef logic [32*CELLS-1:0] bank_t;
  localparam int DEPTH=$clog2(CELLS);
  localparam logic [31:0] OFFSETS[8]='{
    32'h00000001,32'h000fffff,32'h00100000,32'h3fffffff,
    32'h40000000,32'h80000000,32'hc0000000,32'hffffffff
  };
  typedef struct packed {
    logic [31:0] pair_order, cluster_order, global_order, organization;
    logic [32*(CELLS-1)-1:0] groups;
    logic [32*DEPTH-1:0] means, minima, maxima, dispersions;
  } orders_t;

  logic clk=0, rst_n=1, tick_enable=0, load_valid=0;
  bank_t phase_load[2], frequency_load='0, gamma_input='0, thermal_factor='0;
  bank_t phase[2], frequency[2], coupling[2], projection[2];
  logic [2*CELLS-1:0] retained='0, target[2];
  logic [CELLS-1:0] activity='0;
  orders_t orders[2];
  frp_m31_scheduler_state_e scheduler_state=FRP_SCHED_FREE;
  logic [31:0] model_phase[2][CELLS];
  word_t model_frequency[CELLS], sine_reference[4096];
  logic [31:0] offset_word=0;
  bit relation_active=0;
  int mode_id=0, offset_id=0, step_id=0;
  int cases=0, edges=0, updates=0, loads=0, holds=0, load_ticks=0;
  int cadence[5]='{default:0};
  longint unsigned checks=0, moving=0, wraps=0, positive=0, negative=0;
  longint unsigned changed_targets=0, quarter_checks=0, isolated=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  for(genvar b=0;b<2;b++) begin : g_bank
    frp_m31_phase_interference #(.CELLS(CELLS)) dut (
      .clk, .rst_n, .tick_enable, .load_valid,
      .phase_load(phase_load[b]), .frequency_load_q16(frequency_load),
      .gamma_effective_word(gamma_input), .thermal_node_factor_q30(thermal_factor),
      .retained_state(retained), .switch_activity(activity), .scheduler_state,
      .phase_word_q(phase[b]), .frequency_current_q16(frequency[b]),
      .coupling_field_q16(coupling[b]), .phase_projection_q30(projection[b]),
      .phase_target(target[b]), .pair_coherence_q30(orders[b].pair_order),
      .cluster_coherence_q30(orders[b].cluster_order),
      .global_coherence_q30(orders[b].global_order),
      .organization_dispersion_q30(orders[b].organization),
      .group_coherence_q30(orders[b].groups),
      .level_mean_coherence_q30(orders[b].means),
      .level_min_coherence_q30(orders[b].minima),
      .level_max_coherence_q30(orders[b].maxima),
      .level_dispersion_q30(orders[b].dispersions)
    );
  end

  function automatic wide_t rounded(input wide_t value, divisor);
    /*verilator no_inline_task*/
    if(value<0) return -((-value+divisor/2)/divisor);
    return (value+divisor/2)/divisor;
  endfunction

  function automatic word_t saturated(input wide_t value);
    if(value>2147483647) return 32'sh7fffffff;
    if(value< -128'sd2147483648) return 32'sh80000000;
    return word_t'(value);
  endfunction

  function automatic logic [31:0] stimulus(input int c,t,salt);
    logic [31:0] x;
    x=32'h9e3779b9 ^ (32'(c+1)*32'h85ebca6b)
      ^ (32'(t+1)*32'hc2b2ae35) ^ (32'(salt+1)*32'h27d4eb2d);
    x^=x<<13; x^=x>>17; x^=x<<5;
    return x;
  endfunction

  task automatic equal_word(input string label, input int lane,
                            input logic [31:0] actual, expected);
    checks++;
    if(actual!==expected)
      $fatal(1,"PHASE_REFERENCE cells=%0d mode=%0d offset=%h step=%0d lane=%0d %s got=%h expected=%h",
             CELLS,mode_id,offset_word,step_id,lane,label,actual,expected);
    signature=(signature^{32'd0,actual})*64'h100000001b3;
  endtask

  task automatic inspect();
    word_t sine_value;
    logic [1:0] wanted_target;
    for(int c=0;c<CELLS;c++) begin
      for(int b=0;b<2;b++) begin
        equal_word("phase",c,phase[b][32*c+:32],model_phase[b][c]);
        equal_word("frequency",c,frequency[b][32*c+:32],model_frequency[c]);
        sine_value=sine_reference[model_phase[b][c]>>20];
        wanted_target=sine_value>354334802 ? 2'b01
          : (sine_value< -354334802 ? 2'b11 : 2'b00);
        equal_word("projection",c,projection[b][32*c+:32],sine_value);
        equal_word("target",c,{30'd0,target[b][2*c+:2]},{30'd0,wanted_target});
      end
      if(relation_active) begin
        equal_word("offset",c,phase[1][32*c+:32],phase[0][32*c+:32]+offset_word);
        equal_word("relative_coupling",c,coupling[1][32*c+:32],coupling[0][32*c+:32]);
        if(target[0][2*c+:2]!=target[1][2*c+:2]) changed_targets++;
      end
      if(thermal_factor[32*c+:32]==0) begin
        equal_word("isolated_coupling_0",c,coupling[0][32*c+:32],0);
        equal_word("isolated_coupling_1",c,coupling[1][32*c+:32],0);
        isolated++;
      end
      if($signed(coupling[0][32*c+:32])>0) positive++;
      if($signed(coupling[0][32*c+:32])<0) negative++;
    end
    if(relation_active && offset_word[29:0]==0) begin
      checks++;
      if(orders[0]!==orders[1])
        $fatal(1,"PHASE_REFERENCE multiscale rotation cells=%0d mode=%0d offset=%h step=%0d",
               CELLS,mode_id,offset_word,step_id);
      quarter_checks++;
    end
  endtask

  task automatic drive_inputs(input int t);
    logic [31:0] x;
    for(int c=0;c<CELLS;c++) begin
      x=stimulus(c,t,mode_id*8+offset_id);
      phase_load[0][32*c+:32]=x;
      phase_load[1][32*c+:32]=x+offset_word;
      case(c%4)
        0:frequency_load[32*c+:32]=32'h80000000;
        1:frequency_load[32*c+:32]=32'h7fffffff;
        2:frequency_load[32*c+:32]=0;
        default:frequency_load[32*c+:32]=65536;
      endcase
      gamma_input[32*c+:32]=stimulus(c,t,91);
      case((c+t/16)%4)
        0:thermal_factor[32*c+:32]=0;
        1:thermal_factor[32*c+:32]=32'h10000000;
        2:thermal_factor[32*c+:32]=32'h20000000;
        default:thermal_factor[32*c+:32]=32'h40000000;
      endcase
      case((c+t)%3)
        0:retained[2*c+:2]=2'b00;
        1:retained[2*c+:2]=2'b01;
        default:retained[2*c+:2]=2'b11;
      endcase
      activity[c]=1'((c+t)%2);
    end
    case(mode_id)
      0:scheduler_state=FRP_SCHED_FREE;
      1:scheduler_state=(t%8==7)?FRP_SCHED_COMMIT:FRP_SCHED_BALANCE;
      default:scheduler_state=(t%8==0)?FRP_SCHED_EXCITE:FRP_SCHED_NEUTRALIZE;
    endcase
  endtask

  task automatic sample(input bit enable, reload);
    wide_t wanted, delta, phase_increment;
    word_t increment, velocity, push_value;
    logic [31:0] old_phase;
    clk=0; tick_enable=enable; load_valid=reload;
    #1; inspect();
    if(reload) begin
      for(int c=0;c<CELLS;c++) begin
        model_frequency[c]=word_t'(frequency_load[32*c+:32]);
        for(int b=0;b<2;b++) model_phase[b][c]=phase_load[b][32*c+:32];
      end
      relation_active=1; loads++;
      if(enable) load_ticks++;
    end else if(enable) begin
      push_value=scheduler_state==FRP_SCHED_COMMIT ? 655
        : (scheduler_state==FRP_SCHED_EXCITE ? 393 : 197);
      for(int c=0;c<CELLS;c++) begin
        wanted=65536+(retained[2*c+:2]!=0?3932:0)+(activity[c]?7864:0);
        delta=wanted-wide_t'(model_frequency[c]);
        increment=saturated(rounded(delta*19661,65536));
        model_frequency[c]=saturated(wide_t'(model_frequency[c])+wide_t'(increment));
        velocity=word_t'(saturated(rounded(wide_t'(model_frequency[c])*3932,65536))
          +push_value+word_t'(coupling[0][32*c+:32]));
        phase_increment=rounded(wide_t'(velocity)*128'sd44798133900177,128'sd4294967296);
        for(int b=0;b<2;b++) begin
          old_phase=model_phase[b][c];
          model_phase[b][c]+=32'(phase_increment);
          if(model_phase[b][c]!=old_phase) moving++;
          if(phase_increment>0 && model_phase[b][c]<old_phase) wraps++;
        end
      end
      updates++; cadence[int'(scheduler_state)]++;
    end else holds++;
    clk=1; #1; inspect(); clk=0; #1; edges++;
  endtask

  task automatic reset_pair();
    clk=0; tick_enable=0; load_valid=0; relation_active=0;
    rst_n=0;
    for(int c=0;c<CELLS;c++) begin
      model_frequency[c]=65536;
      for(int b=0;b<2;b++) model_phase[b][c]=32'(c)*(32'hffffffff/CELLS+1);
    end
    #1; inspect(); clk=1; #1; inspect();
    clk=0; rst_n=1; #1; inspect();
  endtask

  initial begin : campaign
    real value;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    phase_load[0]='0; phase_load[1]='0;
    for(int a=0;a<4096;a++) begin
      value=$sin(6.283185307179586476925286766559*real'(a)/4096.0)*1073741824.0;
      sine_reference[a]=$rtoi(value<0.0?value-0.5:value+0.5);
    end
    for(mode_id=0;mode_id<3;mode_id++) begin
      for(offset_id=0;offset_id<8;offset_id++) begin
        offset_word=OFFSETS[offset_id]; step_id=0;
        drive_inputs(0); reset_pair();
        for(step_id=0;step_id<256;step_id++) begin
          drive_inputs(step_id);
          if(step_id%64==0) sample(step_id%128==0,1);
          if(step_id%7==0) sample(0,0);
          sample(1,0);
        end
        cases++;
        $display("PHASE_REFERENCE_PROFILE cells=%0d mode=%0d offset=%08h updates=256 loads=4 holds=37",
                 CELLS,mode_id,offset_word);
      end
    end
    if(cases!=24 || edges!=7128 || updates!=6144 || loads!=96 || holds!=888 || load_ticks!=48
        || cadence[0]!=2048 || cadence[1]!=1792 || cadence[2]!=256
        || cadence[3]!=256 || cadence[4]!=1792 || moving==0 || wraps==0
        || positive==0 || negative==0 || changed_targets==0 || isolated==0 || quarter_checks!=5337)
      $fatal(1,"PHASE_REFERENCE coverage incomplete quarter=%0d",quarter_checks);
    $display("FRP_PHASE_REFERENCE_PASS cells=%0d cases=%0d edges=%0d updates=%0d loads=%0d holds=%0d checks=%0d quarter=%0d moving=%0d wraps=%0d positive=%0d negative=%0d target_changes=%0d isolated=%0d signature=%016h",
             CELLS,cases,edges,updates,loads,holds,checks,quarter_checks,moving,wraps,
             positive,negative,changed_targets,isolated,signature);
    $finish;
  end
  initial begin #30000; $fatal(1,"PHASE_REFERENCE watchdog"); end
endmodule

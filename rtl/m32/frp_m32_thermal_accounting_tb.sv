// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Q16 thermal accounting over the complete M32 cross-feedback workload.
// Public DUT ports only; independent heat, telemetry and peak history.
// Rounded diffusion, saturation, ambient clipping and reset removal are
// included explicitly in the cumulative discrete thermal balance.
// CELLS=8/16/32/64; run from repository root with +CASE=0.
`timescale 1ns/1ps
`include "frp_m32_cross_feedback_tb.sv"

module frp_m32_thermal_accounting_tb #(parameter int CELLS=8);
  localparam longint Q16=65536, Q30=1073741824, AMBIENT=3277;
  frp_m32_cross_feedback_tb #(.CELLS(CELLS)) stimulus();

  longint heat[CELLS], peak[CELLS], power[CELLS], dissipation[CELLS];
  longint diffusion[CELLS], overload[CELLS];
  longint mean_peak=AMBIENT;
  longint sum_power=0, sum_dissipation=0, sum_diffusion=0;
  longint sum_clipping=0, reset_removed=0;
  longint unsigned checks=0, samples=0, commits=0, holds=0;
  longint unsigned reset_samples=0, hot_resets=0, clear_ticks=0, clear_holds=0;
  longint unsigned loads=0, residual_ticks=0, peak_updates=0;
  longint unsigned positive_diffusion=0, negative_diffusion=0;
  longint unsigned active_zero_power=0;
  longint unsigned heating[CELLS], cooling[CELLS], peak_hits[CELLS];
  longint unsigned source_hits[3][4][2];
  logic [63:0] signature=64'hcbf29ce484222325;
  bit initialized=0, failed=0;

  function automatic longint rounded(input longint value, divisor);
    /*verilator no_inline_task*/
    return value<0 ? -((-value+divisor/2)/divisor) : (value+divisor/2)/divisor;
  endfunction

  function automatic longint clipped(input longint value);
    return value>2147483647 ? 2147483647 :
      (value< -64'sd2147483648 ? -64'sd2147483648 : value);
  endfunction

  function automatic longint product(input longint a,b,scale);
    /*verilator no_inline_task*/
    return clipped(rounded(a*b,scale));
  endfunction

  function automatic longint weight(input int left_cell,right_cell);
    int span,level;
    if(left_cell==right_cell) return 0;
    span=2; level=0;
    while(left_cell/span!=right_cell/span) begin span*=2; level++; end
    case(CELLS)
      8: case(level)
        0:return 630553580; 1:return 137232194; 2:return 42180964;
        default:return -1;
      endcase
      16: case(level)
        0:return 567420738; 1:return 123492111;
        2:return 37957684; 3:return 13438266;
        default:return -1;
      endcase
      32: case(level)
        0:return 527047716; 1:return 114705422; 2:return 35256926;
        3:return 12482109; 4:return 4774918;
        default:return -1;
      endcase
      64: case(level)
        0:return 498545852; 1:return 108502338; 2:return 33350288;
        3:return 11807096; 4:return 4516698; 5:return 1814569;
        default:return -1;
      endcase
      default:return -1;
    endcase
  endfunction

  task automatic check(input bit condition, input string label_text);
    checks++;
    if(!condition) begin
      failed=1;
      $fatal(1,"THERMAL_ACCOUNTING cells=%0d sample=%0d %s",CELLS,samples,label_text);
    end
  endtask

  task automatic equal(input string label_text, input longint got,expected);
    checks++;
    if(got!==expected) begin
      failed=1;
      $fatal(1,"THERMAL_ACCOUNTING cells=%0d sample=%0d %s got=%0d expected=%0d",
        CELLS,samples,label_text,got,expected);
    end
    signature=(signature^64'(got))*64'h100000001b3;
  endtask

  task automatic observe_retained;
    longint total,maximum;
    total=0; maximum=AMBIENT;
    for(int c=0;c<CELLS;c++) begin
      equal("heat",$signed(stimulus.dut.local_heat_q16[32*c+:32]),heat[c]);
      equal("cell peak",$signed(stimulus.dut.local_heat_peak_q16[32*c+:32]),peak[c]);
      equal("power",$signed(stimulus.dut.local_generated_power_q16[32*c+:32]),power[c]);
      equal("dissipation",$signed(stimulus.dut.local_thermal_dissipation_q16[32*c+:32]),dissipation[c]);
      equal("diffusion",$signed(stimulus.dut.local_thermal_diffusion_q16[32*c+:32]),diffusion[c]);
      equal("overload",$signed(stimulus.dut.local_thermal_overload_q16[32*c+:32]),overload[c]);
      check(heat[c]>=AMBIENT && peak[c]>=heat[c],"ambient and peak bounds");
      total+=heat[c];
      if(peak[c]>maximum) maximum=peak[c];
    end
    equal("mean heat",$signed(stimulus.dut.local_mean_heat_q16),rounded(total,CELLS));
    equal("mean peak",$signed(stimulus.dut.local_mean_heat_peak_q16),mean_peak);
    equal("maximum cell peak",$signed(stimulus.dut.local_maximum_heat_peak_q16),maximum);
    equal("cumulative balance",total-AMBIENT*CELLS,
      sum_power-sum_dissipation+sum_diffusion+sum_clipping-reset_removed);
  endtask

  initial begin : setup
    int selected_case;
    longint row_sum;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    selected_case=0;
    if($value$plusargs("CASE=%d",selected_case)) begin end
    if(selected_case!=0) $fatal(1,"Thermal accounting requires CASE=0");
    for(int c=0;c<CELLS;c++) begin
      heating[c]=0; cooling[c]=0; peak_hits[c]=0; row_sum=0;
      for(int j=0;j<CELLS;j++) begin
        check(weight(c,j)>=0,"thermal weight domain");
        equal("symmetric weights",weight(c,j),weight(j,c));
        row_sum+=weight(c,j);
      end
      equal("normalized thermal row",row_sum,Q30);
    end
    foreach(source_hits[m,s,a]) source_hits[m][s][a]=0;
  end

  // Sample inputs before nonblocking updates; inspect outputs one ns later.
  // The included workload leaves at least two ns before its next mutation.
  always @(posedge stimulus.clk or negedge stimulus.rst_n) begin : accounting
    longint next_heat[CELLS], next_power[CELLS], next_dissipation[CELLS];
    longint next_diffusion[CELLS], next_overload[CELLS], correction[CELLS];
    longint weighted,total_weighted,total_diffusion,total_next,raw,lag_value,term;
    bit enabled,unclipped;
    int mode,sources,automatic_source;
    samples++;
    if(!stimulus.rst_n) begin
      raw=0;
      if(initialized) for(int c=0;c<CELLS;c++) raw+=heat[c]-AMBIENT;
      reset_removed+=raw;
      if(raw>0) hot_resets++;
      reset_samples++;
      for(int c=0;c<CELLS;c++) begin
        heat[c]=AMBIENT; peak[c]=AMBIENT;
        power[c]=0; dissipation[c]=0; diffusion[c]=0; overload[c]=0;
      end
      mean_peak=AMBIENT; initialized=1;
      #1; observe_retained();
    end else begin
      check(initialized,"initial reset observed");
      observe_retained();
      enabled=stimulus.tick_enable;
      mode=int'(stimulus.registered_mode);
      sources=2*int'(stimulus.local_thermal_enable)+int'(stimulus.local_gamma_enable);
      automatic_source=int'(stimulus.auto_target_enable);
      check(mode>=0 && mode<3,"scheduler mode domain");
      total_weighted=0; total_diffusion=0; total_next=0; unclipped=1;
      for(int c=0;c<CELLS;c++) begin
        weighted=0;
        for(int j=0;j<CELLS;j++) if(j!=c) begin
          term=rounded((heat[j]-heat[c])*weight(c,j),Q30);
          if(term!=clipped(term)) unclipped=0;
          weighted+=clipped(term);
        end
        total_weighted+=weighted;
        if(weighted!=clipped(weighted)) unclipped=0;
        next_diffusion[c]=product(2294,clipped(weighted),Q16);
        lag_value=longint'({1'b0,stimulus.dut.local_frequency_lag_q16[32*c+:32]});
        next_power[c]=clipped(118+(stimulus.changes[c]?3408:0)+product(lag_value,1180,Q16));
        next_dissipation[c]=rounded(heat[c]-AMBIENT,14);
        raw=heat[c]+next_power[c]-next_dissipation[c]+next_diffusion[c];
        next_heat[c]=clipped(raw);
        if(next_heat[c]<AMBIENT) next_heat[c]=AMBIENT;
        correction[c]=next_heat[c]-raw;
        next_overload[c]=next_heat[c]>14418 ? next_heat[c]-14418 : 0;
        equal("candidate heat",$signed(stimulus.dut.local_next_heat_q16[32*c+:32]),next_heat[c]);
        equal("candidate overload",$signed(stimulus.dut.local_next_overload_q16[32*c+:32]),next_overload[c]);
        total_diffusion+=next_diffusion[c]; total_next+=next_heat[c];
      end
      if(unclipped) begin
        equal("pairwise diffusion cancellation",total_weighted,0);
        check(2*(total_diffusion<0?-total_diffusion:total_diffusion)<=CELLS,
              "diffusion gain rounding residual bound");
      end
      if(enabled) begin
        commits++; source_hits[mode][sources][automatic_source]++;
        if(stimulus.clear_counters) clear_ticks++;
        if(stimulus.phase_load_valid) loads++;
        if(total_diffusion!=0) residual_ticks++;
        for(int c=0;c<CELLS;c++) begin
          if(next_heat[c]>heat[c]) heating[c]++;
          if(next_heat[c]<heat[c]) cooling[c]++;
          if(next_diffusion[c]>0) positive_diffusion++;
          if(next_diffusion[c]<0) negative_diffusion++;
          if(stimulus.state[2*c+:2]==0 && next_power[c]>118) active_zero_power++;
          sum_power+=next_power[c]; sum_dissipation+=next_dissipation[c];
          sum_diffusion+=next_diffusion[c]; sum_clipping+=correction[c];
          heat[c]=next_heat[c]; power[c]=next_power[c];
          dissipation[c]=next_dissipation[c]; diffusion[c]=next_diffusion[c];
          overload[c]=next_overload[c];
          if(heat[c]>peak[c]) begin peak[c]=heat[c]; peak_hits[c]++; peak_updates++; end
        end
        raw=rounded(total_next,CELLS);
        if(raw>mean_peak) mean_peak=raw;
      end else begin
        holds++;
        if(stimulus.clear_counters) clear_holds++;
      end
      #1; observe_retained();
    end
  end

  final begin
    if(failed || !initialized || stimulus.source_cases!=384 ||
       stimulus.reset_cases!=96 || stimulus.stream_ticks!=6144)
      $fatal(1,"Thermal accounting workload did not finish");
    if(commits==0 || holds==0 || hot_resets<96 || clear_ticks==0 || clear_holds==0 ||
       loads==0 || residual_ticks==0 || positive_diffusion==0 || negative_diffusion==0 ||
       active_zero_power==0 || peak_updates==0)
      $fatal(1,"Thermal accounting stress coverage incomplete");
    for(int c=0;c<CELLS;c++)
      if(heating[c]==0 || cooling[c]==0 || peak_hits[c]==0)
        $fatal(1,"Thermal accounting cell coverage missing cell=%0d",c);
    for(int m=0;m<3;m++) for(int s=0;s<4;s++) for(int a=0;a<2;a++) begin
      if(source_hits[m][s][a]==0) $fatal(1,"Thermal source cross missing mode=%0d sources=%0d auto=%0d",m,s,a);
      $display("THERMAL_MODE cells=%0d mode=%0d sources=%0d auto=%0d commits=%0d",CELLS,m,s,a,source_hits[m][s][a]);
    end
    $display("THERMAL_BALANCE cells=%0d power=%0d dissipation=%0d diffusion=%0d clipping=%0d reset_removed=%0d retained_excess=%0d",
      CELLS,sum_power,sum_dissipation,sum_diffusion,sum_clipping,reset_removed,
      sum_power-sum_dissipation+sum_diffusion+sum_clipping-reset_removed);
    $display("PASS THERMAL_ACCOUNTING cells=%0d samples=%0d checks=%0d commits=%0d holds=%0d reset_samples=%0d hot_resets=%0d clear_ticks=%0d clear_holds=%0d loads=%0d residual_ticks=%0d positive_diffusion=%0d negative_diffusion=%0d active_zero_power=%0d peak_updates=%0d signature=%016h",
      CELLS,samples,checks,commits,holds,reset_samples,hot_resets,clear_ticks,clear_holds,
      loads,residual_ticks,positive_diffusion,negative_diffusion,active_zero_power,peak_updates,signature);
  end
endmodule

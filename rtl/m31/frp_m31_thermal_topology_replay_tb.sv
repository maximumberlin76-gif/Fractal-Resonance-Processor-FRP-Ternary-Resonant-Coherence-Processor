// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Thermal dyadic automorphisms, pause independence and reset-history replay.
// Two unchanged thermal fields receive the same logical input sequence with
// different commit times. The second field uses a tree-preserving permutation.
// Also checks unsigned lag power, dissipation, per-cell balance and the bound
// on net diffusion caused by final Q16 rounding. No DUT internals are accessed.
// Build: --binary --timing --assert -Irtl/m31
// --top-module frp_m31_thermal_topology_replay_tb -GCELLS=8 (16/32/64).
// Runtime: +SEED=76. This is a thermal-field test, not a full-core qualification.
`timescale 1ns/1ps
`include "frp_m31_local_thermal_field.sv"

module frp_m31_thermal_topology_replay_tb #(
  parameter int CELLS=8
);
  localparam int DEPTH=$clog2(CELLS), MAPS=2*CELLS-2, STEPS=64;
  typedef logic signed [31:0] word_t;
  typedef logic [CELLS*192+95:0] retained_t;
  logic clk=0, rst_n=1;
  logic [1:0] enable='0;
  logic [CELLS-1:0] switches[2];
  logic [CELLS*32-1:0] lag[2];
  wire [CELLS*32-1:0] words[2][8];
  wire signed [31:0] means[2], mean_peaks[2], maxima[2];
  logic [CELLS*256+95:0] golden[STEPS];
  int permutation[CELLS];
  int unsigned seed=76;
  int map_id=0, pass_id=0, step_id=0;
  int checks=0, commits=0, holds=0, resets=0, replays=0;
  int positive_flux=0, negative_flux=0, cooling=0, peak_history=0;
  int unsigned_lags=0, changed_candidates=0, rounding_residuals=0;
  logic [63:0] signature=64'hcbf29ce484222325;

  for (genvar d=0;d<2;d++) begin : g_field
    frp_m31_local_thermal_field #(.CELLS(CELLS)) dut (
      .clk, .rst_n, .tick_enable(enable[d]), .switch_activity(switches[d]),
      .frequency_lag_q16(lag[d]), .heat_q16(words[d][0]),
      .local_heat_peak_q16(words[d][1]), .generated_power_q16(words[d][2]),
      .thermal_dissipation_q16(words[d][3]), .thermal_diffusion_q16(words[d][4]),
      .thermal_overload_q16(words[d][5]), .next_heat_q16(words[d][6]),
      .next_overload_q16(words[d][7]), .mean_heat_q16(means[d]),
      .mean_heat_peak_q16(mean_peaks[d]), .maximum_local_heat_q16(maxima[d])
    );
  end

  function automatic logic [31:0] mix(input logic [31:0] x);
    x^=x<<13; x^=x>>17; x^=x<<5;
    return x;
  endfunction

  function automatic retained_t retained(input int d);
    return {words[d][0],words[d][1],words[d][2],words[d][3],words[d][4],
            words[d][5],means[d],mean_peaks[d],maxima[d]};
  endfunction

  function automatic longint signed rounded(input longint signed x, divisor);
    longint signed q, r;
    q=x/divisor; r=x%divisor;
    if (2*r>=divisor) q++;
    if (2*r<=-divisor) q--;
    return q;
  endfunction

  function automatic int distance(input int a,b);
    int level;
    level=0;
    while (a!=b) begin a/=2; b/=2; level++; end
    return level;
  endfunction

  task automatic eq(input string label, input longint signed got,want);
    checks++;
    if (got!==want)
      $fatal(1,"THERMAL_TOPOLOGY %s cells=%0d map=%0d pass=%0d step=%0d got=%0d want=%0d",
        label,CELLS,map_id,pass_id,step_id,got,want);
  endtask

  task automatic make_map();
    int node, span, base;
    bit [CELLS-1:0] seen;
    seen='0; node=map_id-CELLS; span=2;
    if (map_id>=CELLS) begin
      while (node>=CELLS/span) begin node-=CELLS/span; span*=2; end
    end
    base=node*span;
    for (int c=0;c<CELLS;c++) begin
      if (map_id<CELLS) permutation[c]=c^map_id;
      else permutation[c]=(c>=base && c<base+span)?c^(span/2):c;
      if (permutation[c]<0 || permutation[c]>=CELLS || seen[permutation[c]])
        $fatal(1,"Invalid permutation");
      seen[permutation[c]]=1;
    end
    for (int c=0;c<CELLS;c++)
      for (int j=0;j<CELLS;j++)
        eq("dyadic_distance",distance(c,j),distance(permutation[c],permutation[j]));
  endtask

  task automatic stimulus();
    logic [31:0] value;
    for (int c=0;c<CELLS;c++) begin
      value=mix(seed^32'h9e3779b9^(32'(step_id+1)*32'h85ebca6b)
                ^(32'(c+1)*32'hc2b2ae35));
      switches[0][c]=value[0];
      case (step_id/8)
        0: lag[0][c*32+:32]=32'hffffffff;
        1,2: lag[0][c*32+:32]=(c==(step_id-8)%CELLS)?32'hffffffff:0;
        3: lag[0][c*32+:32]=value;
        default: begin lag[0][c*32+:32]=0; switches[0][c]=0; end
      endcase
      lag[1][permutation[c]*32+:32]=lag[0][c*32+:32];
      switches[1][permutation[c]]=switches[0][c];
    end
  endtask

  task automatic pulse(input logic [1:0] enables);
    enable=enables; #1; clk=1; #1; clk=0; #1; enable=0;
  endtask

  task automatic pause_noise();
    retained_t before0,before1;
    logic [CELLS*32-1:0] candidate;
    before0=retained(0); before1=retained(1); candidate=words[1][6];
    for (int d=0;d<2;d++) begin lag[d]=~lag[d]; switches[d]=~switches[d]; end
    #1;
    if (candidate!==words[1][6]) changed_candidates++;
    pulse(0);
    if (retained(0)!==before0 || retained(1)!==before1)
      $fatal(1,"THERMAL_TOPOLOGY HOLD changed retained state");
    checks+=2; holds++; stimulus(); #1;
  endtask

  task automatic symmetry();
    for (int f=0;f<8;f++)
      for (int c=0;c<CELLS;c++)
        eq("mapped_port",longint'(word_t'(words[1][f][permutation[c]*32+:32])),
                         longint'(word_t'(words[0][f][c*32+:32])));
    eq("mapped_mean",means[1],means[0]);
    eq("mapped_mean_peak",mean_peaks[1],mean_peaks[0]);
    eq("mapped_maximum",maxima[1],maxima[0]);
  endtask

  task automatic reset_fields();
    // Reset with tick asserted and nonzero inputs, including dirty peak history.
    enable=3; rst_n=0; #1;
    for (int sample_id=0;sample_id<2;sample_id++) begin
      for (int d=0;d<2;d++) begin
        for (int f=0;f<6;f++)
          for (int c=0;c<CELLS;c++)
            eq("async_reset",longint'(word_t'(words[d][f][c*32+:32])),f<2?3277:0);
        eq("reset_mean",means[d],3277); eq("reset_mean_peak",mean_peaks[d],3277);
        eq("reset_maximum",maxima[d],3277);
      end
      if (sample_id==0) pulse(3);
    end
    rst_n=1; #1; symmetry(); resets++;
  endtask

  task automatic advance_reference();
    word_t old_heat[CELLS],old_peak[CELLS];
    word_t old_mean_peak;
    retained_t held;
    longint signed power,diss,heat,flux,total_flux,total_heat,largest,peak;
    longint signed low,high;
    old_mean_peak=mean_peaks[0]; held=retained(1); low=2147483647; high=0;
    for (int c=0;c<CELLS;c++) begin
      old_heat[c]=word_t'(words[0][0][c*32+:32]);
      old_peak[c]=word_t'(words[0][1][c*32+:32]);
      if (old_heat[c]<low) low=old_heat[c];
      if (old_heat[c]>high) high=old_heat[c];
    end
    // Nonnegative normalized weights imply no weighted-sum saturation here.
    if (high-low>2147483647-CELLS) $fatal(1,"Diffusion bound domain exceeded");
    pulse(1);
    if (retained(1)!==held) $fatal(1,"THERMAL_TOPOLOGY disabled peer changed");
    checks++; total_flux=0; total_heat=0; largest=0;
    for (int c=0;c<CELLS;c++) begin
      power=118+rounded(longint'({32'b0,lag[0][c*32+:32]})*1180,65536)
            +(switches[0][c]?3408:0);
      diss=rounded(longint'(old_heat[c])-3277,14);
      flux=longint'(word_t'(words[0][4][c*32+:32]));
      heat=longint'(old_heat[c])+power-diss+flux;
      if (heat>2147483647) heat=2147483647;
      if (heat<3277) heat=3277;
      peak=(heat>old_peak[c])?heat:longint'(old_peak[c]);
      eq("power",longint'(word_t'(words[0][2][c*32+:32])),power);
      eq("dissipation",longint'(word_t'(words[0][3][c*32+:32])),diss);
      eq("balance",longint'(word_t'(words[0][0][c*32+:32])),heat);
      eq("overload",longint'(word_t'(words[0][5][c*32+:32])),heat>14418?heat-14418:0);
      eq("peak",longint'(word_t'(words[0][1][c*32+:32])),peak);
      total_flux+=flux; total_heat+=heat;
      if (peak>largest) largest=peak;
      if (flux>0) positive_flux++;
      if (flux<0) negative_flux++;
      if (heat<old_heat[c]) cooling++;
      if (peak>heat) peak_history++;
      if (lag[0][c*32+31]) unsigned_lags++;
    end
    // Pairwise rounded weighted differences cancel; only the final per-cell
    // multiplication by 2294/65536 can leave at most CELLS/2 raw Q16 units.
    if (2*total_flux>CELLS || 2*total_flux< -CELLS)
      $fatal(1,"THERMAL_TOPOLOGY diffusion residual=%0d",total_flux);
    checks++;
    if (total_flux!=0) rounding_residuals++;
    heat=rounded(total_heat,CELLS);
    eq("mean",means[0],heat); eq("maximum",maxima[0],largest);
    eq("mean_peak",mean_peaks[0],heat>old_mean_peak?heat:longint'(old_mean_peak));
  endtask

  initial begin : run
    retained_t held;
    logic [CELLS*256+95:0] record_value;
    if (!(CELLS inside {8,16,32,64})) $fatal(1,"Unsupported CELLS");
    if ($value$plusargs("SEED=%d",seed)) begin end
    for (int d=0;d<2;d++) begin lag[d]='0; switches[d]='0; end
    #1;
    for (map_id=0;map_id<MAPS;map_id++) begin
      make_map();
      for (pass_id=0;pass_id<2;pass_id++) begin
        step_id=0; stimulus(); reset_fields();
        for (step_id=0;step_id<STEPS;step_id++) begin
          stimulus(); #1; symmetry();
          repeat((step_id+pass_id)%3) pause_noise();
          advance_reference();
          repeat(1+(step_id+map_id+pass_id)%3) pause_noise();
          held=retained(0); pulse(2);
          if (retained(0)!==held) $fatal(1,"THERMAL_TOPOLOGY reference hold failed");
          checks++; commits+=2; symmetry();
          record_value={retained(0),words[0][6],words[0][7]};
          if (map_id==0 && pass_id==0) golden[step_id]=record_value;
          else begin
            if (record_value!==golden[step_id])
              $fatal(1,"THERMAL_TOPOLOGY reset/pause replay mismatch");
            checks++; replays++;
          end
          for (int f=0;f<8;f++)
            for (int c=0;c<CELLS;c++)
              signature=(signature^{32'b0,words[0][f][c*32+:32]})*64'h100000001b3;
        end
      end
    end
    eq("commit_count",commits,MAPS*2*STEPS*2);
    eq("reset_count",resets,MAPS*2);
    eq("replay_count",replays,(MAPS*2-1)*STEPS);
    if (!(positive_flux>0 && negative_flux>0 && cooling>0 && peak_history>0
          && unsigned_lags>0 && changed_candidates>0 && rounding_residuals>0))
      $fatal(1,"THERMAL_TOPOLOGY missing required event");
    $display("PASS THERMAL_TOPOLOGY cells=%0d seed=%0d maps=%0d steps=%0d commits=%0d holds=%0d resets=%0d replays=%0d checks=%0d positive_flux=%0d negative_flux=%0d cooling=%0d peak_history=%0d unsigned_lags=%0d changed_candidates=%0d rounding_residuals=%0d signature=%h",
      CELLS,seed,MAPS,STEPS,commits,holds,resets,replays,checks,positive_flux,
      negative_flux,cooling,peak_history,unsigned_lags,changed_candidates,
      rounding_residuals,signature);
    $finish;
  end
  initial begin #10000000; $fatal(1,"THERMAL_TOPOLOGY watchdog"); end
endmodule

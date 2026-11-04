// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Fixed-target convergence and two-sided hysteresis of the Q16.16 noise state.
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"

module frp_m31_gamma_settling_tb #(parameter int CELLS=9);
  typedef logic signed [31:0] word_t;
  typedef logic [32*CELLS-1:0] bank_t;
  logic clk=0, rst_n=0, enable=0, valid=0;
  bank_t bus='0, heat='0, targets, noise, goal, anchor, first_visit;
  int unsigned seed;
  int unsigned phases /* verilator public_flat_rw */ = 0;
  int unsigned longest /* verilator public_flat_rw */ = 0;
  logic [6:0] bands /* verilator public_flat_rw */ = 0;
  logic [63:0] signature /* verilator public_flat_rw */ = 64'hcbf29ce484222325;

  frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut (
    .clk(clk),.rst_n(rst_n),.tick_enable(enable),.gamma_update_valid(valid),
    .gamma_targets_q16(bus),.thermal_overload_q16(heat),
    .gamma_noise_target_q16(targets),.gamma_noise_state_q16(noise),
    .gamma_drift_word(),.gamma_effective_word(),
    .next_gamma_drift_word(),.next_gamma_effective_word()
  );

  function automatic longint signed val(input bank_t b,input int j);
    return longint'(word_t'(b[32*j+:32]));
  endfunction

  function automatic longint signed mag(input longint signed x);
    return x<0 ? -x : x;
  endfunction

  task automatic pulse();
    #1; clk=1; #1; clk=0; #1;
  endtask

  task automatic settle();
    bank_t terminal, prior, prior_target;
    int active_ticks, dwell;
    bit loaded;
    longint signed g,e,r,delta,slack;
    // Rounding has zero increment at distances 0..3; larger distances
    // converge to the boundary on the side from which the target is entered.
    terminal=noise;
    for (int j=0;j<CELLS;j++) begin
      g=val(goal,j); e=g-val(noise,j);
      if (mag(e)>3) terminal[32*j+:32]=word_t'(g-(e<0 ? -3 : 3));
    end
    active_ticks=0; dwell=0; loaded=0;
    for (int wall=0;wall<240 && dwell<6;wall++) begin
      prior=noise; prior_target=targets;
      enable=((wall+int'(seed%7))%7)!=0;
      valid=!loaded || !enable;
      bus=(enable && valid)?goal:~goal;
      heat=~heat;
      pulse();
      if (!enable) begin
        if (noise!==prior || targets!==prior_target)
          $fatal(1,"GAMMA pause phase=%0d wall=%0d",phases,wall);
      end else begin
        loaded=1; active_ticks++;
        if (targets!==goal) $fatal(1,"GAMMA target phase=%0d",phases);
        for (int j=0;j<CELLS;j++) begin
          e=val(goal,j)-val(prior,j);
          r=val(goal,j)-val(noise,j);
          delta=e-r;
          // Nearest integer, with an exact half rounded away from zero.
          slack=mag(delta)*65536-mag(e)*9830;
          if (slack<=-32768 || slack>32768 ||
              (e>0 && (r<0 || r>e)) || (e<0 && (r>0 || r<e)) ||
              (mag(e)>3 && mag(r)>=mag(e)) || (mag(e)<=3 && r!=e))
            $fatal(1,"GAMMA contraction phase=%0d lane=%0d before=%0d after=%0d",
                   phases,j,e,r);
        end
        dwell=(noise===terminal)?dwell+1:0;
      end
    end
    if (dwell!=6 || noise!==terminal) $fatal(1,"GAMMA settling timeout phase=%0d",phases);
    if (active_ticks-5>longest) longest=active_ticks-5;
    for (int j=0;j<CELLS;j++) begin
      r=val(goal,j)-val(noise,j);
      if (mag(r)>3) $fatal(1,"GAMMA terminal residual");
      bands[int'(r)+3]=1;
      signature=(signature ^ {goal[32*j+:32],noise[32*j+:32]})*64'h100000001b3;
    end
    phases++;
  endtask

  initial begin
    if (CELLS<1) $fatal(1,"CELLS must be positive");
    if (!$value$plusargs("SEED=%d",seed)) seed=0;
    pulse(); rst_n=1;
    if ({noise,targets}!=='0) $fatal(1,"GAMMA reset");
    for (int j=0;j<CELLS;j++) begin
      anchor[32*j+:32]=word_t'((j*997+int'(seed%997))%65521-32760);
      goal[32*j+:32]=(j%2==0)?32'h80000000:32'h7fffffff;
    end
    settle(); goal=anchor; settle(); first_visit=noise;
    for (int j=0;j<CELLS;j++)
      goal[32*j+:32]=(j%2==0)?32'h7fffffff:32'h80000000;
    settle(); goal=anchor; settle();
    for (int j=0;j<CELLS;j++) begin
      if (val(first_visit,j)-val(anchor,j)!=(j%2==0?-3:3) ||
          val(noise,j)-val(first_visit,j)!=(j%2==0?6:-6))
        $fatal(1,"GAMMA two-sided endpoint lane=%0d",j);
    end
    for (int offset=-4;offset<=4;offset++) begin
      for (int j=0;j<CELLS;j++)
        goal[32*j+:32]=word_t'(val(noise,j)+longint'(offset));
      settle();
    end
    if (phases!=13 || bands!==7'h7f) $fatal(1,"GAMMA coverage");
    $display("PASS GAMMA_SETTLING cells=%0d seed=%0d phases=%0d residual_bins=7 longest=%0d signature=%016h",
             CELLS,seed,phases,longest,signature);
    $finish;
  end
endmodule

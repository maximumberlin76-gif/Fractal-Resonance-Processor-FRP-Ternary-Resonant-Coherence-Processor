// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Noise and thermal sign transformations, cell permutation, and clocked commit.
// Targets and overloads stay within +/-4 in Q16.16, without saturation.
`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift.sv"

module frp_m31_gamma_symmetry_tb #(parameter int CELLS=9);
  typedef logic [32*CELLS-1:0] bank_t;
  typedef logic [31:0] word_t;
  localparam word_t NOMINAL=32'd644245094;
  logic clk=0, rst_n=0, enable=0, valid=0;
  bank_t target[4], heat[4];
  wire [32*CELLS-1:0] tq[4], nq[4], dq[4], eq[4], dn[4], en[4];
  int unsigned seed;
  int unsigned steps /* verilator public_flat_rw */ = 0;
  int unsigned paused /* verilator public_flat_rw */ = 0;
  int unsigned positive /* verilator public_flat_rw */ = 0;
  int unsigned negative /* verilator public_flat_rw */ = 0;
  logic [63:0] signature /* verilator public_flat_rw */ = 64'hcbf29ce484222325;

  for (genvar k=0;k<4;k++) begin: g
    frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut (
      .clk(clk),.rst_n(rst_n),.tick_enable(enable),.gamma_update_valid(valid),
      .gamma_targets_q16(target[k]),.thermal_overload_q16(heat[k]),
      .gamma_noise_target_q16(tq[k]),.gamma_noise_state_q16(nq[k]),
      .gamma_drift_word(dq[k]),.gamma_effective_word(eq[k]),
      .next_gamma_drift_word(dn[k]),.next_gamma_effective_word(en[k])
    );
  end

  function automatic int slot(input int j);
    return (CELLS-1-j+int'(seed%CELLS))%CELLS;
  endfunction

  task automatic transforms();
    for (int j=0;j<CELLS;j++) begin
      for (int k=1;k<4;k++) begin
        // 1: reverse noise; 2: reverse overload; 3: reverse both.
        target[k][32*slot(j)+:32]=(k==1 || k==3)?
          -target[0][32*j+:32]:target[0][32*j+:32];
        heat[k][32*slot(j)+:32]=(k==2 || k==3)?
          -heat[0][32*j+:32]:heat[0][32*j+:32];
      end
    end
  endtask

  task automatic relations();
    word_t t,n,d,c;
    for (int j=0;j<CELLS;j++) begin
      if (eq[0][32*j+:32] !== word_t'(NOMINAL+dq[0][32*j+:32]) ||
          en[0][32*j+:32] !== word_t'(NOMINAL+dn[0][32*j+:32]))
        $fatal(1,"GAMMA nominal step=%0d lane=%0d",steps,j);
      for (int k=1;k<4;k++) begin
        t=tq[0][32*j+:32]; n=nq[0][32*j+:32];
        d=dq[0][32*j+:32]; c=dn[0][32*j+:32];
        if (k==1 || k==3) begin t=-t; n=-n; end
        if (k==1 || k==2) begin d=-d; c=-c; end
        if (tq[k][32*slot(j)+:32] !== t || nq[k][32*slot(j)+:32] !== n ||
            dq[k][32*slot(j)+:32] !== d || dn[k][32*slot(j)+:32] !== c ||
            eq[k][32*slot(j)+:32] !== word_t'(NOMINAL+d) ||
            en[k][32*slot(j)+:32] !== word_t'(NOMINAL+c))
          $fatal(1,"GAMMA symmetry step=%0d transform=%0d lane=%0d",steps,k,j);
      end
    end
  endtask

  task automatic sample();
    bank_t old_t[4],old_n[4],old_d[4],old_e[4],candidate_d[4],candidate_e[4];
    transforms(); #1; relations();
    for (int k=0;k<4;k++) begin
      old_t[k]=tq[k]; old_n[k]=nq[k]; old_d[k]=dq[k]; old_e[k]=eq[k];
      candidate_d[k]=dn[k]; candidate_e[k]=en[k];
    end
    clk=1; #1;
    for (int k=0;k<4;k++) begin
      if (!enable) begin
        if ({tq[k],nq[k],dq[k],eq[k]} !== {old_t[k],old_n[k],old_d[k],old_e[k]})
          $fatal(1,"GAMMA hold step=%0d transform=%0d",steps,k);
      end else if (dq[k]!==candidate_d[k] || eq[k]!==candidate_e[k] ||
                   tq[k] !== (valid?target[k]:old_t[k]))
        $fatal(1,"GAMMA commit step=%0d transform=%0d",steps,k);
    end
    relations();
    for (int j=0;j<CELLS;j++) begin
      if ($signed(dq[0][32*j+:32])>0) positive++;
      if ($signed(dq[0][32*j+:32])<0) negative++;
      signature=(signature^{nq[0][32*j+:32],dq[0][32*j+:32]})*64'h100000001b3;
    end
    if (!enable) paused++;
    steps++; clk=0; #1;
  endtask

  task automatic reset_all();
    rst_n=0; #1; clk=1; #1; clk=0;
    for (int k=0;k<4;k++)
      for (int j=0;j<CELLS;j++)
        if ({tq[k][32*j+:32],nq[k][32*j+:32],dq[k][32*j+:32]} !== '0 ||
            eq[k][32*j+:32] !== NOMINAL) $fatal(1,"GAMMA reset");
    rst_n=1; #1;
  endtask

  initial begin
    if (CELLS<1) $fatal(1,"CELLS must be positive");
    if (!$value$plusargs("SEED=%d",seed)) seed=0;
    for (int k=0;k<4;k++) begin target[k]='0; heat[k]='0; end
    reset_all();
    // Independent exact half-tie anchor: noise=32768, thermal gain=1,
    // rounded drift=1 Q16.16 unit, converted phase word=10430.
    for (int j=0;j<CELLS;j++) begin
      target[0][32*j+:32]=218462; heat[0][32*j+:32]=13;
    end
    enable=1; valid=1; sample();
    for (int j=0;j<CELLS;j++)
      if (nq[0][32*j+:32]!==32'd32768 || dq[0][32*j+:32]!==32'd10430)
        $fatal(1,"GAMMA anchor lane=%0d",j);
    for (int i=0;i<512;i++) begin
      if (i==256) reset_all();
      for (int j=0;j<CELLS;j++) begin
        target[0][32*j+:32]=word_t'(((i*8191+j*997+int'(seed%4096))%524289)-262144);
        heat[0][32*j+:32]=word_t'(((i*32771+j*3571+int'(seed%8192))%524289)-262144);
      end
      enable=(i%7)!=0; valid=(i%5)!=0; sample();
    end
    if (steps!=513 || paused!=74 || positive==0 || negative==0)
      $fatal(1,"GAMMA symmetry coverage");
    $display("PASS GAMMA_SYMMETRY cells=%0d seed=%0d steps=%0d paused=%0d positive=%0d negative=%0d signature=%016h",
             CELLS,seed,steps,paused,positive,negative,signature);
    $finish;
  end
endmodule

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Parameterized execution of the independent gamma and attenuation regressions.
// Each checker retains its original stimuli, oracle, event gates and accounting.
// Gamma: signed 16-bit target and overload sweeps, wide differences, saturation,
// phase wrapping, rounding ties, isolated lanes, reset and retained histories.
// Attenuation: all 4096 ROM addresses in every lane, both boundary directions,
// dense overload sweep, signed extremes, isolated lanes, reset and held outputs.
// Compile this top explicitly; the included legacy tops remain uninstantiated.
// Example: --top-module frp_m31_feedback_scaling_tb -GCELLS=64 -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_local_gamma_drift_tb.sv"
`include "frp_m31_local_thermal_attenuation_tb.sv"

module frp_m31_feedback_scaling_tb #(parameter int CELLS = 64);
  wire gamma_done, attenuation_done;

  frp_m31_local_gamma_checker #(.CELLS(CELLS)) gamma_check (
    .done(gamma_done)
  );
  frp_m31_attenuation_checker #(.CELLS(CELLS)) attenuation_check (
    .done(attenuation_done)
  );

  initial begin
    if (!(CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64))
      $fatal(1, "Feedback scaling requires 8, 16, 32 or 64 cells");
    wait (gamma_done === 1'b1 && attenuation_done === 1'b1);
    $display("PASS FEEDBACK_SCALING cells=%0d suites=2", CELLS);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "Feedback scaling timeout cells=%0d gamma=%b attenuation=%b",
           CELLS, gamma_done, attenuation_done);
  end
endmodule

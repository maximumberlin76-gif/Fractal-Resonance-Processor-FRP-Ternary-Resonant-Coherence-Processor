// SPDX-License-Identifier: Apache-2.0
// FRP M32 CSR CDC generated-netlist comparison against the qualified RTL.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert,
// -DSIMLIB_NOCONNECT and --top-module frp_m32_csr_cdc_post_synthesis_tb.
// Include directories: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32,
// fpga/m32_csr. Supply the Yosys simlib and the generated Verilog module
// frp_m32_csr_cdc_netlist as additional compilation inputs.
// Export the complete frp_m32_csr_cdc_top after synthesis, with $shiftx
// cells lowered through techmap before writing the simulation netlist.
//
// The existing CDC testbench supplies the clocks, reset and host requests,
// checks CSR semantics, and terminates the run. Both implementations receive
// exactly those same inputs. No generated-netlist internal names are used.
// Compare all 42 external output bits after either clock changes or reset
// changes; this includes retained response data outside completion pulses.
// The 1 ps sampling offset allows zero-delay logic to settle before checking.
// Startup and end-of-run output comparisons are also required.
//
// The inherited profiles are HOST_HALF/CORE_HALF/PHASE = 5/7/1, 3/11/4,
// and 13/2/3 ns. Each includes stopped clocks, invalid and held host pulses,
// reset-aborted requests/responses, and -1/0/1 routes through active zero
// under both schedules 7/1 and 1/7. A successful run emits the inherited
// CSR_CDC and FRP_M32_CSR_CDC_TB records, then the post-synthesis PASS record.

`ifndef FRP_M32_CSR_CDC_POST_SYNTHESIS_TB_SV
`define FRP_M32_CSR_CDC_POST_SYNTHESIS_TB_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_cdc_tb.sv"

module frp_m32_csr_cdc_post_synthesis_tb;
  logic net_csr_ready, net_csr_error;
  logic [31:0] net_csr_rdata;
  logic net_host_reset_released, net_core_reset_released;
  logic net_interface_ready, net_interface_busy, net_protocol_error;
  logic net_invalid_before_ready, net_invalid_while_busy, net_invalid_valid_held;
  logic [41:0] rtl_outputs, net_outputs;
  int unsigned comparisons = 0, net_host_responses = 0;
  bit comparison_failed = 0;

  frp_m32_csr_cdc_tb rtl_test();

  frp_m32_csr_cdc_netlist dut (
    .host_clk(rtl_test.host_clk),
    .core_clk(rtl_test.core_clk),
    .rst_n_async(rtl_test.rst_n_async),
    .csr_valid(rtl_test.csr_valid),
    .csr_write(rtl_test.csr_write),
    .csr_addr(rtl_test.csr_addr),
    .csr_wdata(rtl_test.csr_wdata),
    .csr_ready(net_csr_ready),
    .csr_error(net_csr_error),
    .csr_rdata(net_csr_rdata),
    .host_reset_released(net_host_reset_released),
    .core_reset_released(net_core_reset_released),
    .interface_ready(net_interface_ready),
    .interface_busy(net_interface_busy),
    .protocol_error(net_protocol_error),
    .invalid_before_ready(net_invalid_before_ready),
    .invalid_while_busy(net_invalid_while_busy),
    .invalid_valid_held(net_invalid_valid_held)
  );

  assign rtl_outputs = {
    rtl_test.csr_ready, rtl_test.csr_error, rtl_test.csr_rdata,
    rtl_test.host_reset_released, rtl_test.core_reset_released,
    rtl_test.interface_ready, rtl_test.interface_busy, rtl_test.protocol_error,
    rtl_test.invalid_before_ready, rtl_test.invalid_while_busy,
    rtl_test.invalid_valid_held
  };

  assign net_outputs = {
    net_csr_ready, net_csr_error, net_csr_rdata,
    net_host_reset_released, net_core_reset_released,
    net_interface_ready, net_interface_busy, net_protocol_error,
    net_invalid_before_ready, net_invalid_while_busy, net_invalid_valid_held
  };

  task automatic compare_outputs(input string label);
    if (net_outputs !== rtl_outputs) begin
      comparison_failed = 1;
      $fatal(1, "CDC post-synthesis %s: netlist=%h RTL=%h time=%0t",
             label, net_outputs, rtl_outputs, $time);
    end
    comparisons++;
  endtask

  initial begin
    #1ps;
    compare_outputs("startup");
  end

  always @(rtl_test.host_clk or rtl_test.core_clk or rtl_test.rst_n_async) begin
    #1ps;
    compare_outputs("clock/reset edge");
  end

  always @(posedge rtl_test.host_clk) begin
    if (rtl_test.rst_n_async && net_csr_ready)
      net_host_responses++;
  end

  final begin
    if (!comparison_failed) begin
      compare_outputs("final");
      if (rtl_test.checks != 9117 || rtl_test.launches != 1802
          || rtl_test.completions != 1800 || rtl_test.core_completions != 1801
          || rtl_test.host_responses != 1800 || rtl_test.aborts != 2
          || rtl_test.aborts_after_core != 1 || rtl_test.total_ticks != 177
          || rtl_test.errors != 460 || rtl_test.routes != 8 || rtl_test.resets != 14)
        $fatal(1, "CDC post-synthesis reference scenarios did not complete");
      if (net_host_responses != 1800 || comparisons < 2 * net_host_responses)
        $fatal(1, "CDC post-synthesis response count or comparison coverage failed");
      $display("FRP_M32_CSR_CDC_POST_SYNTHESIS_TB: PASS host_half=%0d core_half=%0d phase=%0d comparisons=%0d output_bits=42 host_responses=%0d",
               rtl_test.host_half, rtl_test.core_half, rtl_test.phase_offset,
               comparisons, net_host_responses);
    end
  end
endmodule : frp_m32_csr_cdc_post_synthesis_tb
`endif

// SPDX-License-Identifier: Apache-2.0
// FRP M32 ready/valid CSR CDC netlist comparison against the qualified RTL.
// Author: Alchimist
//
// Build from the repository root with --binary --timing --assert,
// -DSIMLIB_NOCONNECT and --top-module frp_m32_csr_cdc_stream_post_synthesis_tb.
// Include directories: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32,
// fpga/m32_csr. Supply the Yosys simlib and the generated Verilog module
// frp_m32_csr_cdc_stream_netlist as additional compilation inputs.
// Export the complete frp_m32_csr_cdc_stream_top after synthesis, with
// $shiftx cells lowered through techmap before writing the simulation netlist.
//
// The existing stream testbench owns the clocks, reset, requests, response
// readiness and independent CSR scoreboard. Both implementations receive
// exactly the same inputs. No generated-netlist internal names are used.
// Compare all 43 external output bits before each host sampling edge and
// after input changes settle, including retained data outside rsp_valid.
// The 10 ps settling offset accommodates the reference driver's 1-3 ps
// offsets without sampling intermediate zero-delay combinational results.
// Startup and end-of-run output comparisons are also required.
//
// Clock profiles HOST_HALF/CORE_HALF/PHASE: 5/7/1, 3/11/4, 13/2/3 ns.
// Each covers backpressure, continuous valid traffic, simultaneous transfers,
// stopped clocks, four reset abort stages, and routes through active zero
// under both schedules 7/1 and 1/7. The kernel remains -1/0/1.
// Netlist transfer counters are cumulative across reset: 427 accepted
// requests, 423 consumed responses and 127 simultaneous transfers.

`ifndef FRP_M32_CSR_CDC_STREAM_POST_SYNTHESIS_TB_SV
`define FRP_M32_CSR_CDC_STREAM_POST_SYNTHESIS_TB_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_cdc_stream_tb.sv"

module frp_m32_csr_cdc_stream_post_synthesis_tb;
  logic net_req_ready, net_rsp_valid, net_rsp_error;
  logic [31:0] net_rsp_rdata;
  logic net_host_reset_released, net_core_reset_released;
  logic net_interface_ready, net_interface_busy, net_protocol_error;
  logic net_invalid_before_ready, net_invalid_while_busy, net_invalid_valid_held;
  logic [42:0] rtl_outputs, net_outputs;
  int unsigned comparisons = 0, net_accepted = 0, net_completed = 0;
  int unsigned net_simultaneous = 0;
  bit comparison_failed = 0;

  frp_m32_csr_cdc_stream_tb rtl_test();

  frp_m32_csr_cdc_stream_netlist dut (
    .host_clk(rtl_test.host_clk),
    .core_clk(rtl_test.core_clk),
    .rst_n_async(rtl_test.rst_n_async),
    .req_valid(rtl_test.req_valid),
    .req_ready(net_req_ready),
    .req_write(rtl_test.req_write),
    .req_addr(rtl_test.req_addr),
    .req_wdata(rtl_test.req_wdata),
    .rsp_valid(net_rsp_valid),
    .rsp_ready(rtl_test.rsp_ready),
    .rsp_error(net_rsp_error),
    .rsp_rdata(net_rsp_rdata),
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
    rtl_test.req_ready, rtl_test.rsp_valid, rtl_test.rsp_error, rtl_test.rsp_rdata,
    rtl_test.host_reset_released, rtl_test.core_reset_released,
    rtl_test.interface_ready, rtl_test.interface_busy, rtl_test.protocol_error,
    rtl_test.invalid_before_ready, rtl_test.invalid_while_busy,
    rtl_test.invalid_valid_held
  };

  assign net_outputs = {
    net_req_ready, net_rsp_valid, net_rsp_error, net_rsp_rdata,
    net_host_reset_released, net_core_reset_released,
    net_interface_ready, net_interface_busy, net_protocol_error,
    net_invalid_before_ready, net_invalid_while_busy, net_invalid_valid_held
  };

  task automatic compare_outputs(input string label);
    if (net_outputs !== rtl_outputs) begin
      comparison_failed = 1;
      $fatal(1, "CDC stream post-synthesis %s: netlist=%h RTL=%h time=%0t",
             label, net_outputs, rtl_outputs, $time);
    end
    comparisons++;
  endtask

  initial begin
    #10ps;
    compare_outputs("startup");
  end

  always @(rtl_test.host_clk or rtl_test.core_clk or rtl_test.rst_n_async
           or rtl_test.req_valid or rtl_test.req_write or rtl_test.req_addr
           or rtl_test.req_wdata or rtl_test.rsp_ready) begin
    #10ps;
    compare_outputs("inputs settled");
  end

  always @(posedge rtl_test.host_clk) begin
    // Compare the values sampled for transfers before sequential updates.
    compare_outputs("host sampling edge");
    if (rtl_test.rst_n_async) begin
      if (rtl_test.req_valid && net_req_ready) net_accepted++;
      if (net_rsp_valid && rtl_test.rsp_ready) net_completed++;
      if (rtl_test.req_valid && net_req_ready
          && net_rsp_valid && rtl_test.rsp_ready) net_simultaneous++;
    end
  end

  final begin
    if (!comparison_failed) begin
      compare_outputs("final");
      if (rtl_test.pending || rtl_test.core_seen
          || rtl_test.accepted != 427 || rtl_test.completed != 423
          || rtl_test.core_completed != 425 || rtl_test.aborted != 4
          || rtl_test.aborted_after_core != 2 || rtl_test.pulses != 426
          || rtl_test.simultaneous != 127 || rtl_test.rejected != 41
          || rtl_test.routes != 8 || rtl_test.resets != 10
          || rtl_test.backpressure_edges < 100 || rtl_test.request_wait_edges < 100)
        $fatal(1, "CDC stream post-synthesis reference scenarios did not complete");
      if (net_accepted != 427 || net_completed != 423 || net_simultaneous != 127
          || comparisons < 2 * net_accepted)
        $fatal(1, "CDC stream post-synthesis transfer count or comparison coverage failed");
      $display("FRP_M32_CSR_CDC_STREAM_POST_SYNTHESIS_TB: PASS host_half=%0d core_half=%0d phase=%0d comparisons=%0d output_bits=43 accepted=%0d completed=%0d simultaneous=%0d",
               rtl_test.host_half, rtl_test.core_half, rtl_test.phase_offset,
               comparisons, net_accepted, net_completed, net_simultaneous);
    end
  end
endmodule : frp_m32_csr_cdc_stream_post_synthesis_tb
`endif

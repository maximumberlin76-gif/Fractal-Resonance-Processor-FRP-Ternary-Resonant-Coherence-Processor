// SPDX-License-Identifier: Apache-2.0
// FRP M32 dual-clock CSR integration using the existing M23 CDC bridge.
// Author: Alchimist
//
// Fixed target profile: eight cells, two request lanes, 32-bit CSR words.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// The complete M32 register map and command meanings are unchanged.
// The M32 core retains -1/0/1, active zero, and schedules 7/1 and 1/7.
//
// Host protocol is the M23 single-outstanding pulse convention:
//   - Sample interface_ready and interface_busy on host_clk.
//   - Issue csr_valid for ONE host clock when ready and not busy.
//   - Supply csr_write, csr_addr and csr_wdata on that request edge.
//   - Deassert csr_valid; the bridge retains the complete request payload.
//   - Sample csr_error and csr_rdata when csr_ready pulses on host_clk.
//   - A new request may start once interface_busy is low again.
// csr_ready reports completion; it is not permission to issue a request.
// Response data/error retain the last response between completion pulses.
//
// Requests before readiness or while busy are discarded and set the
// corresponding sticky protocol flag. Holding csr_valid across host edges
// sets invalid_valid_held and cannot repeat a command. A held request must
// return low before a later request can be accepted. Protocol flags clear
// only on reset; rejected CSR addresses/payloads instead return csr_error.
//
// Assert the common rst_n_async low at startup. Each bridge clock domain
// releases reset through its own two-stage synchronizer. core_reset_released
// also drives the M32 target's existing asynchronous-reset input; the target
// retains its own two-stage reset release. A core-side request stays valid
// until the target actually acknowledges it, then is removed on that edge.
// interface_ready is host-domain bridge readiness, not target telemetry.
// Reset discards outstanding requests/responses and resets the M32 target.
// A stopped clock stalls progress without changing the held transaction.

`ifndef FRP_M32_CSR_CDC_TOP_SV
`define FRP_M32_CSR_CDC_TOP_SV

`timescale 1ns / 1ps

`include "frp_m23_reset_release_sync.sv"
`include "frp_m23_csr_cdc_bridge.sv"
`include "frp_m32_csr_top.sv"
`ifndef SYNTHESIS
`include "frp_m23_interface_protocol_assertions.sv"
`endif

module frp_m32_csr_cdc_top #(
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input  logic        host_clk,
  input  logic        core_clk,
  input  logic        rst_n_async,
  input  logic        csr_valid,
  input  logic        csr_write,
  input  logic [7:0]  csr_addr,
  input  logic [31:0] csr_wdata,
  output logic        csr_ready,
  output logic        csr_error,
  output logic [31:0] csr_rdata,
  output logic        host_reset_released,
  output logic        core_reset_released,
  output logic        interface_ready,
  output logic        interface_busy,
  output logic        protocol_error,
  output logic        invalid_before_ready,
  output logic        invalid_while_busy,
  output logic        invalid_valid_held
);

  (* ASYNC_REG = "TRUE" *) logic [1:0] core_release_host_sync_q;
  logic core_csr_valid, core_csr_write, core_csr_ready, core_csr_error;
  logic [7:0] core_csr_addr;
  logic [31:0] core_csr_wdata, core_csr_rdata;
  logic request_toggle_debug, response_toggle_debug;
  logic [40:0] held_request_debug;
  logic [32:0] held_response_debug;

  frp_m23_reset_release_sync host_reset_sync (
    .clk(host_clk),
    .rst_n_async(rst_n_async),
    .rst_n_sync(host_reset_released)
  );

  frp_m23_reset_release_sync core_reset_sync (
    .clk(core_clk),
    .rst_n_async(rst_n_async),
    .rst_n_sync(core_reset_released)
  );

  always_ff @(posedge host_clk or negedge host_reset_released) begin
    if (!host_reset_released)
      core_release_host_sync_q <= 2'b00;
    else
      core_release_host_sync_q <= {
        core_release_host_sync_q[0], core_reset_released
      };
  end

  assign interface_ready = host_reset_released && core_release_host_sync_q[1];

  frp_m23_csr_cdc_bridge cdc_bridge (
    .host_clk(host_clk),
    .host_rst_n(host_reset_released),
    .host_ready(interface_ready),
    .host_csr_valid(csr_valid),
    .host_csr_write(csr_write),
    .host_csr_addr(csr_addr),
    .host_csr_wdata(csr_wdata),
    .host_csr_ready(csr_ready),
    .host_csr_error(csr_error),
    .host_csr_rdata(csr_rdata),
    .host_busy(interface_busy),
    .invalid_before_ready(invalid_before_ready),
    .invalid_while_busy(invalid_while_busy),
    .invalid_valid_held(invalid_valid_held),
    .protocol_error(protocol_error),
    .core_clk(core_clk),
    .core_rst_n(core_reset_released),
    .core_ready(core_reset_released),
    .core_csr_valid(core_csr_valid),
    .core_csr_write(core_csr_write),
    .core_csr_addr(core_csr_addr),
    .core_csr_wdata(core_csr_wdata),
    .core_csr_ready(core_csr_ready),
    .core_csr_error(core_csr_error),
    .core_csr_rdata(core_csr_rdata),
    .request_toggle_debug(request_toggle_debug),
    .response_toggle_debug(response_toggle_debug),
    .held_request_debug(held_request_debug),
    .held_response_debug(held_response_debug)
  );

  frp_m32_csr_top #(
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_csr (
    .clk(core_clk),
    .rst_n_async(core_reset_released),
    .csr_valid(core_csr_valid),
    .csr_write(core_csr_write),
    .csr_addr(core_csr_addr),
    .csr_wdata(core_csr_wdata),
    .csr_ready(core_csr_ready),
    .csr_error(core_csr_error),
    .csr_rdata(core_csr_rdata)
  );

`ifndef SYNTHESIS
  frp_m23_interface_protocol_assertions protocol_assertions (
    .host_clk(host_clk),
    .core_clk(core_clk),
    .rst_n_async(rst_n_async),
    .host_reset_released(host_reset_released),
    .core_reset_released(core_reset_released),
    .core_ready_core(core_reset_released),
    .host_ready(interface_ready),
    .host_csr_valid(csr_valid),
    .host_csr_ready(csr_ready),
    .host_busy(interface_busy),
    .core_csr_valid(core_csr_valid),
    .core_csr_ready(core_csr_ready),
    .request_toggle(request_toggle_debug),
    .response_toggle(response_toggle_debug),
    .held_request(held_request_debug),
    .held_response(held_response_debug)
  );
`endif

endmodule : frp_m32_csr_cdc_top

`endif

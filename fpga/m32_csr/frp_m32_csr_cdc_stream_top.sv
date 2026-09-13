// SPDX-License-Identifier: Apache-2.0
// FRP M32 ready/valid request and response streams over the M32 CDC top.
// Author: Alchimist
//
// Fixed profile: eight cells, two request lanes, 32-bit CSR words.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// The existing CDC top supplies the complete M32 register map and core:
// -1/0/1, active zero, and the two schedules 7/1 and 1/7.
//
// Both stream interfaces are synchronous to host_clk:
//   - A request is accepted on an edge with req_valid && req_ready.
//   - Hold req_valid and its write/address/data payload until acceptance.
//   - After acceptance, the payload is stored and issued as one CDC pulse.
//   - A response is consumed on an edge with rsp_valid && rsp_ready.
//   - rsp_valid, rsp_error and rsp_rdata stay stable while rsp_ready is low.
// A high req_valid on a later ready edge denotes another request, including
// when the payload is identical. No request is accepted while a response
// is stalled. The previous response and a new request may transfer together
// on the same host edge; req_ready is the request acceptance condition.
//
// Exactly one transaction is outstanding, including a buffered response.
// interface_busy covers request issue, CDC execution and response retention;
// it can coexist with req_ready when a response is being consumed.
// interface_ready retains the CDC top's synchronized reset-readiness meaning.
// CSR errors are returned in rsp_error and do not block later requests.
// The protocol flags report the internal CDC pulse interface.
//
// Assert the common rst_n_async low at startup. The adapter uses the CDC
// host-domain synchronized reset release. Reset flushes the accepted request
// and buffered response and resets the underlying core. No aborted response
// is emitted after reset. A request held across reset is accepted only when
// req_ready returns; the producer controls whether it should be retried.
// Stopped clocks stall progress. A retained response needs only host_clk
// for consumption. Response data/error clear on reset and otherwise retain
// the last captured response until the next CDC completion.

`ifndef FRP_M32_CSR_CDC_STREAM_TOP_SV
`define FRP_M32_CSR_CDC_STREAM_TOP_SV
`timescale 1ns / 1ps
`include "frp_m32_csr_cdc_top.sv"

module frp_m32_csr_cdc_stream_top #(
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input  logic        host_clk,
  input  logic        core_clk,
  input  logic        rst_n_async,
  input  logic        req_valid,
  output logic        req_ready,
  input  logic        req_write,
  input  logic [7:0]  req_addr,
  input  logic [31:0] req_wdata,
  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic        rsp_error,
  output logic [31:0] rsp_rdata,
  output logic        host_reset_released,
  output logic        core_reset_released,
  output logic        interface_ready,
  output logic        interface_busy,
  output logic        protocol_error,
  output logic        invalid_before_ready,
  output logic        invalid_while_busy,
  output logic        invalid_valid_held
);
  typedef enum logic [1:0] {
    IDLE, ISSUE, WAIT_RESPONSE, HOLD_RESPONSE
  } state_t;
  state_t state_q;
  logic request_write_q;
  logic [7:0] request_addr_q;
  logic [31:0] request_wdata_q;
  logic bridge_valid, bridge_busy, bridge_done, bridge_error;
  logic [31:0] bridge_rdata;

  assign req_ready = rst_n_async && interface_ready && !bridge_busy
    && ((state_q == IDLE) || ((state_q == HOLD_RESPONSE) && rsp_ready));
  assign rsp_valid = rst_n_async && host_reset_released
    && (state_q == HOLD_RESPONSE);
  assign interface_busy = rst_n_async && host_reset_released && (state_q != IDLE);
  assign bridge_valid = rst_n_async && interface_ready && !bridge_busy
    && (state_q == ISSUE);

  always_ff @(posedge host_clk or negedge host_reset_released) begin
    if (!host_reset_released) begin
      state_q <= IDLE;
      request_write_q <= 1'b0;
      request_addr_q <= '0;
      request_wdata_q <= '0;
      rsp_error <= 1'b0;
      rsp_rdata <= '0;
    end else begin
      case (state_q)
        IDLE: begin end
        ISSUE: begin
          if (bridge_valid)
            state_q <= WAIT_RESPONSE;
        end
        WAIT_RESPONSE: begin
          if (bridge_done) begin
            rsp_error <= bridge_error;
            rsp_rdata <= bridge_rdata;
            state_q <= HOLD_RESPONSE;
          end
        end
        HOLD_RESPONSE: begin
          if (rsp_ready)
            state_q <= IDLE;
        end
        default: state_q <= IDLE;
      endcase

      // A simultaneous response consumption and request acceptance replaces
      // the completed transaction without reusing its response or payload.
      if (req_valid && req_ready) begin
        request_write_q <= req_write;
        request_addr_q <= req_addr;
        request_wdata_q <= req_wdata;
        state_q <= ISSUE;
      end
    end
  end

  frp_m32_csr_cdc_top #(
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_cdc (
    .host_clk(host_clk),
    .core_clk(core_clk),
    .rst_n_async(rst_n_async),
    .csr_valid(bridge_valid),
    .csr_write(request_write_q),
    .csr_addr(request_addr_q),
    .csr_wdata(request_wdata_q),
    .csr_ready(bridge_done),
    .csr_error(bridge_error),
    .csr_rdata(bridge_rdata),
    .host_reset_released(host_reset_released),
    .core_reset_released(core_reset_released),
    .interface_ready(interface_ready),
    .interface_busy(bridge_busy),
    .protocol_error(protocol_error),
    .invalid_before_ready(invalid_before_ready),
    .invalid_while_busy(invalid_while_busy),
    .invalid_valid_held(invalid_valid_held)
  );
endmodule : frp_m32_csr_cdc_stream_top
`endif

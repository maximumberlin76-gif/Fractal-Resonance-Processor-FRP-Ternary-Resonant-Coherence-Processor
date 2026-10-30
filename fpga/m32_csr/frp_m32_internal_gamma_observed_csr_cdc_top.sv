// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Dual-clock host interface for internal gamma control and snapshot CSR.
// Profiles: CELLS=8/16/32/64; RECORDER_COUNT_BITS=1..64.
// Include paths: rtl/m22, rtl/m23, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
//
// The nine-bit byte address crosses as part of the held request payload:
//   0x000..0x0ff: original control and paged telemetry registers.
//   0x100..0x1ff: snapshot capture/release, flags, identity and payload.
// The target retains the original register definitions and all core behavior.
//
// Host protocol: one-cycle request pulse, one outstanding transaction.
// - Sample interface_ready and interface_busy on host_clk.
// - Assert csr_valid for one host edge when ready and not busy.
// - Supply csr_write, csr_addr and csr_wdata on that edge, then deassert valid.
// - The bridge retains all 42 request bits through target stalls.
// - csr_ready pulses on host_clk when the response is available.
// - Sample csr_error and csr_rdata with csr_ready; they retain the last response.
// csr_ready denotes completion, not permission to issue another request.
//
// Early requests and requests while busy are discarded and set sticky flags.
// Holding csr_valid high sets invalid_valid_held and cannot repeat a command;
// valid must return low before another request can be accepted.
// CSR decode errors return csr_error and do not set protocol flags.
// Accepted host requests cannot be withdrawn by changing host inputs.
// A blocked gamma tick remains valid at the target until completion or reset.
//
// Assert the common rst_n_async low at startup. Both domains release reset
// through separate two-stage synchronizers. The CSR target additionally keeps
// its existing two-stage reset release. interface_ready describes bridge
// readiness; a core-side request is held until the target acknowledges it.
// Reset flushes both request and response state and resets the target.
// Stopping either clock stalls progress while the bundled payload stays held.
//
// Request and response toggles use two-stage synchronizers. Their bundled
// payloads are held across the round trip; only the synchronized toggle enables
// destination capture. Implementation timing constraints must preserve payload
// settling before that capture and recognize the ASYNC_REG synchronizer chains.

`ifndef FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_TOP_SV
`define FRP_M32_INTERNAL_GAMMA_OBSERVED_CSR_CDC_TOP_SV

`timescale 1ns / 1ps

`include "frp_m23_reset_release_sync.sv"
`include "frp_m32_internal_gamma_observed_csr_top.sv"

module frp_m32_internal_gamma_observed_csr_cdc_top #(
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem",
  parameter int CELLS = 8,
  parameter int RECORDER_COUNT_BITS = 64
) (
  input  logic        host_clk,
  input  logic        core_clk,
  input  logic        rst_n_async,
  input  logic        csr_valid,
  input  logic        csr_write,
  input  logic [8:0]  csr_addr,
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
  logic [8:0] core_csr_addr;
  logic [31:0] core_csr_wdata, core_csr_rdata;
  logic request_toggle_debug, response_toggle_debug;
  logic [41:0] held_request_debug;
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

  // One outstanding transaction; bundled payloads remain held until completion.
  generate begin : cdc_bridge
    logic request_toggle_host_q;
    logic request_valid_previous_q;
    logic request_write_hold_q;
    logic [8:0] request_addr_hold_q;
    logic [31:0] request_wdata_hold_q;

    (* ASYNC_REG = "TRUE" *) logic [1:0] request_toggle_core_sync_q;
    logic request_toggle_core_seen_q;
    logic response_toggle_core_q;
    logic response_error_hold_q;
    logic [31:0] response_rdata_hold_q;

    (* ASYNC_REG = "TRUE" *) logic [1:0] response_toggle_host_sync_q;
    logic response_toggle_host_seen_q;

    always_ff @(posedge host_clk or negedge host_reset_released) begin
      if (!host_reset_released) begin
        request_toggle_host_q <= 1'b0;
        request_valid_previous_q <= 1'b0;
        request_write_hold_q <= 1'b0;
        request_addr_hold_q <= '0;
        request_wdata_hold_q <= '0;
        response_toggle_host_sync_q <= 2'b00;
        response_toggle_host_seen_q <= 1'b0;
        csr_ready <= 1'b0;
        csr_error <= 1'b0;
        csr_rdata <= '0;
        interface_busy <= 1'b0;
        invalid_before_ready <= 1'b0;
        invalid_while_busy <= 1'b0;
        invalid_valid_held <= 1'b0;
      end else begin
        response_toggle_host_sync_q <= {
          response_toggle_host_sync_q[0], response_toggle_core_q
        };
        csr_ready <= 1'b0;
        request_valid_previous_q <= csr_valid;

        if (csr_valid && request_valid_previous_q) begin
          invalid_valid_held <= 1'b1;
        end

        if (csr_valid) begin
          if (!interface_ready) begin
            invalid_before_ready <= 1'b1;
          end else if (interface_busy) begin
            invalid_while_busy <= 1'b1;
          end else if (!request_valid_previous_q) begin
            request_write_hold_q <= csr_write;
            request_addr_hold_q <= csr_addr;
            request_wdata_hold_q <= csr_wdata;
            request_toggle_host_q <= ~request_toggle_host_q;
            interface_busy <= 1'b1;
          end
        end

        if (response_toggle_host_sync_q[1] != response_toggle_host_seen_q) begin
          response_toggle_host_seen_q <= response_toggle_host_sync_q[1];
          csr_ready <= 1'b1;
          csr_error <= response_error_hold_q;
          csr_rdata <= response_rdata_hold_q;
          interface_busy <= 1'b0;
        end
      end
    end

    always_ff @(posedge core_clk or negedge core_reset_released) begin
      if (!core_reset_released) begin
        request_toggle_core_sync_q <= 2'b00;
        request_toggle_core_seen_q <= 1'b0;
        response_toggle_core_q <= 1'b0;
        response_error_hold_q <= 1'b0;
        response_rdata_hold_q <= '0;
        core_csr_valid <= 1'b0;
        core_csr_write <= 1'b0;
        core_csr_addr <= '0;
        core_csr_wdata <= '0;
      end else begin
        request_toggle_core_sync_q <= {
          request_toggle_core_sync_q[0], request_toggle_host_q
        };

        if (
          !core_csr_valid
          && core_reset_released
          && (request_toggle_core_sync_q[1] != request_toggle_core_seen_q)
        ) begin
          request_toggle_core_seen_q <= request_toggle_core_sync_q[1];
          core_csr_write <= request_write_hold_q;
          core_csr_addr <= request_addr_hold_q;
          core_csr_wdata <= request_wdata_hold_q;
          core_csr_valid <= 1'b1;
        end

        if (core_csr_valid && core_csr_ready) begin
          response_error_hold_q <= core_csr_error;
          response_rdata_hold_q <= core_csr_rdata;
          response_toggle_core_q <= ~response_toggle_core_q;
          core_csr_valid <= 1'b0;
        end
      end
    end

    assign protocol_error =
      invalid_before_ready || invalid_while_busy || invalid_valid_held;
    assign request_toggle_debug = request_toggle_host_q;
    assign response_toggle_debug = response_toggle_core_q;
    assign held_request_debug = {
      request_write_hold_q, request_addr_hold_q, request_wdata_hold_q
    };
    assign held_response_debug = {response_error_hold_q, response_rdata_hold_q};
  end endgenerate

  frp_m32_internal_gamma_observed_csr_top #(
    .SIN_LUT_FILE(SIN_LUT_FILE),
    .CELLS(CELLS),
    .RECORDER_COUNT_BITS(RECORDER_COUNT_BITS)
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
  generate begin : protocol_checks
    logic host_reset_released_q;
    logic core_reset_released_q;
    logic request_toggle_q;
    logic response_toggle_q;
    logic [41:0] held_request_q;
    logic [32:0] held_response_q;
    logic core_waiting_q;
    logic [41:0] core_payload_q;

    always_ff @(posedge host_clk or negedge rst_n_async) begin
      if (!rst_n_async) begin
        host_reset_released_q <= 1'b0;
        request_toggle_q <= 1'b0;
        held_request_q <= '0;
      end else begin
        assert (host_reset_released || !host_reset_released_q)
          else $error("M32_IG_CDC_A01_HOST_RESET_MONOTONIC");
        assert (!interface_ready || host_reset_released)
          else $error("M32_IG_CDC_A03_HOST_READY_AFTER_HOST_RESET");
        assert (!csr_ready || !interface_busy)
          else $error("M32_IG_CDC_A06_RESPONSE_CLEARS_BUSY");
        assert (!((request_toggle_debug != request_toggle_q) && !interface_ready))
          else $error("M32_IG_CDC_A07_REQUEST_REQUIRES_READY");
        if (interface_busy && !(request_toggle_debug != request_toggle_q)) begin
          assert (held_request_debug == held_request_q)
            else $error("M32_IG_CDC_A08_REQUEST_PAYLOAD_STABLE");
        end
        assert (!csr_ready || interface_ready)
          else $error("M32_IG_CDC_A12_HOST_RESPONSE_AFTER_READY");
        host_reset_released_q <= host_reset_released;
        request_toggle_q <= request_toggle_debug;
        held_request_q <= held_request_debug;
      end
    end

    always_ff @(posedge core_clk or negedge rst_n_async) begin
      if (!rst_n_async) begin
        core_reset_released_q <= 1'b0;
        response_toggle_q <= 1'b0;
        held_response_q <= '0;
        core_waiting_q <= 1'b0;
        core_payload_q <= '0;
      end else begin
        assert (core_reset_released || !core_reset_released_q)
          else $error("M32_IG_CDC_A02_CORE_RESET_MONOTONIC");
        assert (!core_csr_valid || core_reset_released)
          else $error("M32_IG_CDC_A05_CORE_REQUEST_AFTER_READY");
        assert (!core_csr_ready || core_csr_valid)
          else $error("M32_IG_CDC_A09_CORE_RESPONSE_REQUIRES_REQUEST");
        if (response_toggle_debug == response_toggle_q) begin
          assert (held_response_debug == held_response_q)
            else $error("M32_IG_CDC_A10_RESPONSE_PAYLOAD_STABLE");
        end
        assert (!((response_toggle_debug != response_toggle_q) && !core_reset_released))
          else $error("M32_IG_CDC_A11_RESPONSE_TOGGLE_AFTER_CORE_READY");
        if (core_waiting_q) begin
          assert (core_csr_valid &&
                  {core_csr_write, core_csr_addr, core_csr_wdata} == core_payload_q)
            else $error("M32_IG_CDC_A13_CORE_REQUEST_STABLE_WHILE_WAITING");
        end
        core_waiting_q <= core_csr_valid && !core_csr_ready;
        core_payload_q <= {core_csr_write, core_csr_addr, core_csr_wdata};
        core_reset_released_q <= core_reset_released;
        response_toggle_q <= response_toggle_debug;
        held_response_q <= held_response_debug;
      end
    end
  end endgenerate
`endif

endmodule : frp_m32_internal_gamma_observed_csr_cdc_top

`endif

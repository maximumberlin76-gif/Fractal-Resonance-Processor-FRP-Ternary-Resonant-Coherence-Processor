// SPDX-License-Identifier: Apache-2.0
// FRP M32 same-clock, full-word CSR integration over the qualified FPGA top.
//
// Fixed profile: eight cells, two request lanes, 32-bit counters.
// Include paths: rtl/m22, rtl/m31, rtl/m32, fpga/m32.
// All bus inputs must be synchronous to clk. This is the M22 valid/ready
// transaction convention, not an AXI, APB, Wishbone, or CDC implementation.
// A transfer completes at each rising edge with csr_valid && csr_ready.
// Holding valid across multiple ready edges performs multiple transfers.
// Errors complete the transfer without changing registers or advancing FRP.
// Read data is zero on writes, errors, idle cycles, and during reset release.
// Assert rst_n_async at startup; transfers wait for the FPGA reset synchronizer.
//
// Addresses 00..64 retain the M22 register map and full-word access rules.
// CONTROL (00, write only) accepts EXACTLY one command, not a bitmask:
//   1 = one tick; 2 = clear counters/results; 4 = clear staged requests;
//   8 = load all eight staged phase/frequency pairs, without a tick.
// Mode (04): 0 = free, 1 = 7/1, 2 = 1/7; 3 is rejected.
// A mode write updates CSR storage on its accepted edge. The core registers
// that mode on the next rising edge, including while ticks are paused.
// Before ticking in the new mode, allow one idle clock or read MODE_ACTIVE
// (20). A tick immediately after the write uses the previous scheduler state.
// Lane selector (08) accepts 0..1; cell selectors (0C,18) accept 0..7.
// Target (10): 0 = active zero, 1 = +1, 3 = -1; 2 is rejected.
// Request valid (14) and automatic target enable (68) accept only 0 or 1.
// Requests are one-shot: every tick clears BOTH staged valid bits, including
// ticks in automatic mode. Clear/load commands do not execute requests.
// Duplicate-cell arbitration remains in the core. As in M22, the target bank
// is built in lane order; the higher lane supplies a duplicate bank entry.
//
// Extension map (hex byte addresses; aligned 32-bit accesses only):
//   68 RW automatic target enable (reset 0)
//   6C RW staged phase word for selected cell (selector at 18)
//   70 RW staged signed frequency Q16 for selected cell
//   74 RW live gamma word for selected cell
//   78 RW live thermal factor Q30 for selected cell (reset 40000000)
//   7C RO current phase word       80 RO current signed frequency Q16
//   84 RO signed coupling Q16     88 RO signed phase projection Q30
//   8C RO source target           90 RO registered target
//   94 RO target status: bits 0..3 = registered valid, source domain valid,
//         registered domain valid, registered request enable (live);
//         bits 4..5 = capture accepted/rejected on the last tick
//   98 RO accepted captures       9C RO rejected captures
//   A0 RO free ticks              A4 RO balance ticks
//   A8 RO commit ticks            AC RO excite ticks
//   B0 RO neutralize ticks        B4 RO pair coherence Q30
//   B8 RO cluster coherence Q30   BC RO global coherence Q30
//   C0 RO dispersion Q30          C4 RO last-tick cycle cost Q16
//   C8 RO temperature proxy Q16   CC RO peak temperature proxy Q16
//   D0 RO thermal sample count    D4 RO coherence capacity Q16
//   D8 RO pressure Q16            DC RO stability margin Q16
//   E0 RO stable                  E4 RO last-tick accepted cell mask
//   E8 RO last-tick neutral mask  EC RO last-tick changed cell mask
//   F0 RO last-tick phase requests, F4 RO last-tick execution requests:
//         [1:0] valid, [4:2]/[7:5] cell indexes, [9:8]/[11:10] targets
//   F8 RO last-tick execution target bank, two bits per ascending cell
//   FC RO interface ID 46523201 (FR, M32, register-map revision 1)
// Unlisted high bits in narrow registers read as zero.
//
// Phase/frequency staging does not affect the core until command 8 loads the
// entire bank. Gamma/thermal writes take effect immediately; configure the
// complete bank before ticking. Reads of per-cell data use selector 18.
// Signed Q-format registers preserve the core's raw two's-complement bits.
// State, scheduler counters, and phase/thermal telemetry are live post-edge
// values. Event results and invariant flags describe the last executed tick;
// they remain readable after requests are consumed and until tick/clear/reset.
// No autonomous ticks occur. Finish a read sequence before issuing a command
// or changing configuration if a consistent multi-register view is required.
// Counter clear retains phases, registered targets, state, and pending routes.
// The underlying core alone implements both tick-separated routes through 0.

`ifndef FRP_M32_CSR_TOP_SV
`define FRP_M32_CSR_TOP_SV

`timescale 1ns / 1ps

`include "frp_m22_csr_pkg.sv"
`include "frp_m32_fpga_top.sv"

module frp_m32_csr_top #(
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem"
) (
  input  logic clk,
  input  logic rst_n_async,
  input  logic csr_valid,
  input  logic csr_write,
  input  logic [7:0] csr_addr,
  input  logic [31:0] csr_wdata,
  output logic csr_ready,
  output logic csr_error,
  output logic [31:0] csr_rdata
);
  import frp_m22_csr_pkg::*;
  import frp_m31_pkg::*;

  localparam logic [7:0] ADDR_AUTO = 8'h68;
  localparam logic [7:0] ADDR_PHASE_LOAD = 8'h6C;
  localparam logic [7:0] ADDR_FREQUENCY_LOAD = 8'h70;
  localparam logic [7:0] ADDR_GAMMA = 8'h74;
  localparam logic [7:0] ADDR_THERMAL_FACTOR = 8'h78;
  localparam logic [31:0] COMMAND_LOAD = 32'd8;

  logic core_ready;
  logic accepted_write, tick_pulse, clear_pulse, load_pulse;
  logic payload_valid, address_writable;
  frp_m31_scheduler_mode_e mode_control_q;
  logic lane_select_q, auto_enable_q;
  logic [2:0] cell_select_q;
  logic [5:0] request_cells_q;
  logic [3:0] request_targets_q;
  logic [1:0] request_valid_q;
  logic [15:0] target_bank;
  logic [255:0] phase_load_q, frequency_load_q, gamma_q, thermal_factor_q;

  logic [255:0] phase_word_q, frequency_current_q16;
  logic [255:0] coupling_field_q16, phase_projection_q30;
  logic [15:0] phase_target_source, registered_target_q;
  logic registered_target_valid_q, phase_target_domain_valid;
  logic registered_target_domain_valid, registered_request_enable;
  logic [31:0] accepted_target_capture_events_q;
  logic [31:0] rejected_target_capture_events_q;
  logic [1:0] phase_request_valid, execution_request_valid;
  logic [5:0] phase_request_cell_index, execution_request_cell_index;
  logic [3:0] phase_request_target, execution_request_target;
  logic [15:0] state_out, pending_route_out;
  frp_m31_scheduler_mode_e scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q;
  logic [31:0] scheduler_count_balance_q, scheduler_count_commit_q;
  logic [31:0] scheduler_count_excite_q, scheduler_count_neutralize_q;
  logic signed [31:0] pair_coherence_q30, cluster_coherence_q30;
  logic signed [31:0] global_coherence_q30, organization_dispersion_q30;
  logic signed [31:0] temperature_proxy_q16, peak_temperature_proxy_q16;
  logic signed [31:0] coherence_capacity_q16, pressure_q16;
  logic signed [31:0] stability_margin_q16;
  logic [31:0] thermal_sample_count_q;
  logic stable;

  typedef struct packed {
    logic [1:0] request_accept, request_reject;
    logic [7:0] accepted_cells, neutral_cells, changed_cells;
    logic [31:0] accepted_changes, capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load, requested_direct, prevented_direct;
    logic [31:0] neutral_routed, actual_direct, reserved_state, queue_overflow;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;
    logic capture_accepted, capture_rejected;
    logic signed [31:0] cycle_cost;
    logic [11:0] phase_requests, execution_requests;
    logic [15:0] execution_target_bank;
  } tick_result_t;
  tick_result_t tick_result, last_tick_q;

  assign tick_result.phase_requests =
    {phase_request_target, phase_request_cell_index, phase_request_valid};
  assign tick_result.execution_requests =
    {execution_request_target, execution_request_cell_index,
     execution_request_valid};

  always_comb begin
    target_bank = '0;
    for (int lane = 0; lane < 2; lane++) begin
      if (request_valid_q[lane])
        target_bank[int'(request_cells_q[lane*3 +: 3])*2 +: 2] =
          request_targets_q[lane*2 +: 2];
    end
  end

  always_comb begin
    address_writable = frp_m22_is_writable_address(csr_addr)
      || (csr_addr >= ADDR_AUTO && csr_addr <= ADDR_THERMAL_FACTOR);
    payload_valid = 1'b0;
    case (csr_addr)
      FRP_M22_ADDR_CONTROL:
        payload_valid = (csr_wdata == FRP_M22_CONTROL_TICK)
          || (csr_wdata == FRP_M22_CONTROL_CLEAR_COUNTERS)
          || (csr_wdata == FRP_M22_CONTROL_CLEAR_REQUESTS)
          || (csr_wdata == COMMAND_LOAD);
      FRP_M22_ADDR_SCHEDULER_MODE:
        payload_valid = (csr_wdata <= 32'd2);
      FRP_M22_ADDR_REQUEST_LANE_SELECT:
        payload_valid = (csr_wdata <= 32'd1);
      FRP_M22_ADDR_REQUEST_CELL_INDEX, FRP_M22_ADDR_OBSERVE_CELL_INDEX:
        payload_valid = (csr_wdata <= 32'd7);
      FRP_M22_ADDR_REQUEST_TARGET:
        payload_valid = (csr_wdata == 32'd0) || (csr_wdata == 32'd1)
          || (csr_wdata == 32'd3);
      FRP_M22_ADDR_REQUEST_VALID, ADDR_AUTO:
        payload_valid = (csr_wdata <= 32'd1);
      ADDR_PHASE_LOAD, ADDR_FREQUENCY_LOAD, ADDR_GAMMA, ADDR_THERMAL_FACTOR:
        payload_valid = 1'b1;
      default: payload_valid = 1'b0;
    endcase

    csr_ready = rst_n_async && core_ready && csr_valid;
    csr_error = 1'b0;
    if (csr_ready) begin
      if (!frp_m22_is_word_aligned(csr_addr))
        csr_error = 1'b1;
      else if (csr_write)
        csr_error = !address_writable || !payload_valid;
      else
        csr_error = (csr_addr == FRP_M22_ADDR_CONTROL);
    end
  end

  assign accepted_write = csr_ready && csr_write && !csr_error;
  assign tick_pulse = accepted_write && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == FRP_M22_CONTROL_TICK);
  assign clear_pulse = accepted_write && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == FRP_M22_CONTROL_CLEAR_COUNTERS);
  assign load_pulse = accepted_write && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == COMMAND_LOAD);

  // core_ready is the existing two-stage synchronized reset release.
  always_ff @(posedge clk or negedge core_ready) begin
    if (!core_ready) begin
      mode_control_q <= FRP_MODE_FREE;
      lane_select_q <= 1'b0;
      cell_select_q <= '0;
      auto_enable_q <= 1'b0;
      request_cells_q <= '0;
      request_targets_q <= '0;
      request_valid_q <= '0;
      phase_load_q <= '0;
      frequency_load_q <= '0;
      gamma_q <= '0;
      thermal_factor_q <= {8{32'h40000000}};
      last_tick_q <= '0;
      last_tick_q.invariant_flags <= '1;
    end else begin
      if (tick_pulse) begin
        last_tick_q <= tick_result;
        request_valid_q <= '0;
      end
      if (clear_pulse) begin
        last_tick_q <= '0;
        last_tick_q.invariant_flags <= '1;
      end
      if (accepted_write) begin
        case (csr_addr)
          FRP_M22_ADDR_CONTROL:
            if (csr_wdata == FRP_M22_CONTROL_CLEAR_REQUESTS)
              request_valid_q <= '0;
          FRP_M22_ADDR_SCHEDULER_MODE:
            mode_control_q <= frp_m31_scheduler_mode_e'(csr_wdata[1:0]);
          FRP_M22_ADDR_REQUEST_LANE_SELECT:
            lane_select_q <= csr_wdata[0];
          FRP_M22_ADDR_REQUEST_CELL_INDEX:
            request_cells_q[int'(lane_select_q)*3 +: 3] <= csr_wdata[2:0];
          FRP_M22_ADDR_REQUEST_TARGET:
            request_targets_q[int'(lane_select_q)*2 +: 2] <= csr_wdata[1:0];
          FRP_M22_ADDR_REQUEST_VALID:
            request_valid_q[lane_select_q] <= csr_wdata[0];
          FRP_M22_ADDR_OBSERVE_CELL_INDEX:
            cell_select_q <= csr_wdata[2:0];
          ADDR_AUTO: auto_enable_q <= csr_wdata[0];
          ADDR_PHASE_LOAD:
            phase_load_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
          ADDR_FREQUENCY_LOAD:
            frequency_load_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
          ADDR_GAMMA:
            gamma_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
          ADDR_THERMAL_FACTOR:
            thermal_factor_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
          default: begin end
        endcase
      end
    end
  end

  always_comb begin
    csr_rdata = '0;
    if (csr_ready && !csr_write && !csr_error) begin
      case (csr_addr)
        FRP_M22_ADDR_SCHEDULER_MODE: csr_rdata = {30'd0, mode_control_q};
        FRP_M22_ADDR_REQUEST_LANE_SELECT: csr_rdata[0] = lane_select_q;
        FRP_M22_ADDR_REQUEST_CELL_INDEX:
          csr_rdata[2:0] = request_cells_q[int'(lane_select_q)*3 +: 3];
        FRP_M22_ADDR_REQUEST_TARGET:
          csr_rdata[1:0] = request_targets_q[int'(lane_select_q)*2 +: 2];
        FRP_M22_ADDR_REQUEST_VALID:
          csr_rdata[0] = request_valid_q[lane_select_q];
        FRP_M22_ADDR_OBSERVE_CELL_INDEX: csr_rdata[2:0] = cell_select_q;
        FRP_M22_ADDR_STATUS: begin
          csr_rdata[FRP_M22_STATUS_READY] = core_ready;
          csr_rdata[FRP_M22_STATUS_CAPACITY_EXHAUSTED] =
            last_tick_q.capacity_exhausted;
          csr_rdata[FRP_M22_STATUS_REQUEST_ACCEPTED] =
            |last_tick_q.request_accept;
          csr_rdata[FRP_M22_STATUS_REQUEST_REJECTED] =
            |last_tick_q.request_reject;
          csr_rdata[FRP_M22_STATUS_PENDING_ACTIVE] = |pending_route_out;
          csr_rdata[FRP_M22_STATUS_INVARIANT_FAILURE] =
            !(&last_tick_q.invariant_flags);
          csr_rdata[FRP_M22_STATUS_ACTUAL_DIRECT_NONZERO] =
            |last_tick_q.actual_direct;
          csr_rdata[FRP_M22_STATUS_RESERVED_STATE_NONZERO] =
            |last_tick_q.reserved_state;
          csr_rdata[FRP_M22_STATUS_QUEUE_OVERFLOW_NONZERO] =
            |last_tick_q.queue_overflow;
        end
        FRP_M22_ADDR_SCHEDULER_MODE_ACTIVE:
          csr_rdata[1:0] = scheduler_mode_q;
        FRP_M22_ADDR_SCHEDULER_STATE: csr_rdata[2:0] = scheduler_state_q;
        FRP_M22_ADDR_TICKS_RECORDED: csr_rdata = ticks_recorded_q;
        FRP_M22_ADDR_REQUEST_ACCEPT: csr_rdata[1:0] = last_tick_q.request_accept;
        FRP_M22_ADDR_REQUEST_REJECT: csr_rdata[1:0] = last_tick_q.request_reject;
        FRP_M22_ADDR_RETAINED_STATE:
          csr_rdata[1:0] = state_out[int'(cell_select_q)*2 +: 2];
        FRP_M22_ADDR_PENDING_ROUTE:
          csr_rdata[1:0] = pending_route_out[int'(cell_select_q)*2 +: 2];
        FRP_M22_ADDR_ACCEPTED_CHANGES: csr_rdata = last_tick_q.accepted_changes;
        FRP_M22_ADDR_CAPACITY_REMAINING:
          csr_rdata = last_tick_q.capacity_remaining;
        FRP_M22_ADDR_CAPACITY_EXHAUSTED:
          csr_rdata[0] = last_tick_q.capacity_exhausted;
        FRP_M22_ADDR_SWITCH_LOAD_NUMERATOR: csr_rdata = last_tick_q.switch_load;
        FRP_M22_ADDR_INVARIANT_FLAGS:
          csr_rdata[FRP_M31_INVARIANT_FLAGS-1:0] = last_tick_q.invariant_flags;
        FRP_M22_ADDR_REQUESTED_DIRECT_EVENTS:
          csr_rdata = last_tick_q.requested_direct;
        FRP_M22_ADDR_PREVENTED_DIRECT_EVENTS:
          csr_rdata = last_tick_q.prevented_direct;
        FRP_M22_ADDR_NEUTRAL_ROUTED_EVENTS: csr_rdata = last_tick_q.neutral_routed;
        FRP_M22_ADDR_ACTUAL_DIRECT_EVENTS: csr_rdata = last_tick_q.actual_direct;
        FRP_M22_ADDR_RESERVED_STATE_EVENTS: csr_rdata = last_tick_q.reserved_state;
        FRP_M22_ADDR_QUEUE_OVERFLOW_EVENTS: csr_rdata = last_tick_q.queue_overflow;
        ADDR_AUTO: csr_rdata[0] = auto_enable_q;
        ADDR_PHASE_LOAD:
          csr_rdata = phase_load_q[int'(cell_select_q)*32 +: 32];
        ADDR_FREQUENCY_LOAD:
          csr_rdata = frequency_load_q[int'(cell_select_q)*32 +: 32];
        ADDR_GAMMA: csr_rdata = gamma_q[int'(cell_select_q)*32 +: 32];
        ADDR_THERMAL_FACTOR:
          csr_rdata = thermal_factor_q[int'(cell_select_q)*32 +: 32];
        8'h7C: csr_rdata = phase_word_q[int'(cell_select_q)*32 +: 32];
        8'h80: csr_rdata = frequency_current_q16[int'(cell_select_q)*32 +: 32];
        8'h84: csr_rdata = coupling_field_q16[int'(cell_select_q)*32 +: 32];
        8'h88: csr_rdata = phase_projection_q30[int'(cell_select_q)*32 +: 32];
        8'h8C: csr_rdata[1:0] = phase_target_source[int'(cell_select_q)*2 +: 2];
        8'h90: csr_rdata[1:0] = registered_target_q[int'(cell_select_q)*2 +: 2];
        8'h94: csr_rdata[5:0] = {last_tick_q.capture_rejected,
          last_tick_q.capture_accepted, registered_request_enable,
          registered_target_domain_valid, phase_target_domain_valid,
          registered_target_valid_q};
        8'h98: csr_rdata = accepted_target_capture_events_q;
        8'h9C: csr_rdata = rejected_target_capture_events_q;
        8'hA0: csr_rdata = scheduler_count_free_q;
        8'hA4: csr_rdata = scheduler_count_balance_q;
        8'hA8: csr_rdata = scheduler_count_commit_q;
        8'hAC: csr_rdata = scheduler_count_excite_q;
        8'hB0: csr_rdata = scheduler_count_neutralize_q;
        8'hB4: csr_rdata = pair_coherence_q30;
        8'hB8: csr_rdata = cluster_coherence_q30;
        8'hBC: csr_rdata = global_coherence_q30;
        8'hC0: csr_rdata = organization_dispersion_q30;
        8'hC4: csr_rdata = last_tick_q.cycle_cost;
        8'hC8: csr_rdata = temperature_proxy_q16;
        8'hCC: csr_rdata = peak_temperature_proxy_q16;
        8'hD0: csr_rdata = thermal_sample_count_q;
        8'hD4: csr_rdata = coherence_capacity_q16;
        8'hD8: csr_rdata = pressure_q16;
        8'hDC: csr_rdata = stability_margin_q16;
        8'hE0: csr_rdata[0] = stable;
        8'hE4: csr_rdata[7:0] = last_tick_q.accepted_cells;
        8'hE8: csr_rdata[7:0] = last_tick_q.neutral_cells;
        8'hEC: csr_rdata[7:0] = last_tick_q.changed_cells;
        8'hF0: csr_rdata[11:0] = last_tick_q.phase_requests;
        8'hF4: csr_rdata[11:0] = last_tick_q.execution_requests;
        8'hF8: csr_rdata[15:0] = last_tick_q.execution_target_bank;
        8'hFC: csr_rdata = 32'h46523201;
        default: csr_rdata = '0;
      endcase
    end
  end

  frp_m32_fpga_top #(
    .CELLS(8), .REQUEST_LANES(2), .CELL_INDEX_BITS(3), .COUNTER_BITS(32),
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_fpga (
    .clk(clk), .rst_n_async(rst_n_async), .core_ready(core_ready),
    .tick_enable(tick_pulse), .clear_counters(clear_pulse),
    .scheduler_mode(mode_control_q), .phase_load_valid(load_pulse),
    .phase_load(phase_load_q), .frequency_load_q16(frequency_load_q),
    .gamma_effective_word(gamma_q), .thermal_node_factor_q30(thermal_factor_q),
    .auto_target_enable(auto_enable_q), .external_request_valid(request_valid_q),
    .external_request_cell_index(request_cells_q),
    .external_request_target(request_targets_q), .external_target_bank(target_bank),
    .phase_word_q(phase_word_q), .frequency_current_q16(frequency_current_q16),
    .coupling_field_q16(coupling_field_q16), .phase_projection_q30(phase_projection_q30),
    .phase_target_source(phase_target_source), .registered_target_q(registered_target_q),
    .registered_target_valid_q(registered_target_valid_q),
    .phase_target_domain_valid(phase_target_domain_valid),
    .registered_target_domain_valid(registered_target_domain_valid),
    .target_capture_accepted(tick_result.capture_accepted),
    .target_capture_rejected(tick_result.capture_rejected),
    .accepted_target_capture_events_q(accepted_target_capture_events_q),
    .rejected_target_capture_events_q(rejected_target_capture_events_q),
    .registered_request_enable(registered_request_enable),
    .phase_request_valid(phase_request_valid),
    .phase_request_cell_index(phase_request_cell_index),
    .phase_request_target(phase_request_target),
    .execution_request_valid(execution_request_valid),
    .execution_request_cell_index(execution_request_cell_index),
    .execution_request_target(execution_request_target),
    .execution_target_bank(tick_result.execution_target_bank),
    .state_out(state_out), .pending_route_out(pending_route_out),
    .scheduler_mode_q(scheduler_mode_q), .scheduler_state_q(scheduler_state_q),
    .ticks_recorded_q(ticks_recorded_q), .scheduler_count_free_q(scheduler_count_free_q),
    .scheduler_count_balance_q(scheduler_count_balance_q),
    .scheduler_count_commit_q(scheduler_count_commit_q),
    .scheduler_count_excite_q(scheduler_count_excite_q),
    .scheduler_count_neutralize_q(scheduler_count_neutralize_q),
    .request_accept(tick_result.request_accept), .request_reject(tick_result.request_reject),
    .accepted_cell_mask(tick_result.accepted_cells),
    .neutral_routed_cell_mask(tick_result.neutral_cells),
    .accepted_change_mask(tick_result.changed_cells),
    .accepted_changes(tick_result.accepted_changes),
    .capacity_remaining(tick_result.capacity_remaining),
    .capacity_exhausted(tick_result.capacity_exhausted),
    .switch_load_numerator(tick_result.switch_load),
    .requested_direct_events(tick_result.requested_direct),
    .prevented_direct_events(tick_result.prevented_direct),
    .neutral_routed_events(tick_result.neutral_routed),
    .actual_direct_events(tick_result.actual_direct),
    .reserved_state_events(tick_result.reserved_state),
    .queue_overflow_events(tick_result.queue_overflow),
    .invariant_flags(tick_result.invariant_flags),
    .pair_coherence_q30(pair_coherence_q30), .cluster_coherence_q30(cluster_coherence_q30),
    .global_coherence_q30(global_coherence_q30),
    .organization_dispersion_q30(organization_dispersion_q30),
    .normalized_cycle_cost_q16(tick_result.cycle_cost),
    .temperature_proxy_q16(temperature_proxy_q16),
    .peak_temperature_proxy_q16(peak_temperature_proxy_q16),
    .thermal_sample_count_q(thermal_sample_count_q),
    .coherence_capacity_q16(coherence_capacity_q16), .pressure_q16(pressure_q16),
    .stability_margin_q16(stability_margin_q16), .stable(stable)
  );
endmodule : frp_m32_csr_top

`endif

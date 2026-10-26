// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 internal-gamma CSR boundary: 8/16/32/64 cells, 32-bit counters.
// Include paths: rtl/m22, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// The M22 same-clock bus completes a transfer on csr_valid && csr_ready.
// Hold valid/address/write/data until completion. Each ready edge is a transfer;
// a continuously held command can execute repeatedly. Reset cancels a wait.
// Reads return zero during idle, writes, waits, reset and error completions.
// Errors complete without changing CSR storage or accepting a core command.
// Assert rst_n_async at startup; all other inputs are synchronous to clk.
//
// Common addresses 00..64 use frp_m22_csr_pkg. CONTROL (00, WO) accepts exactly:
//   00000001 tick; 00000002 clear counters/results; 00000004 clear requests;
//   00000008 load staged phase/frequency banks without ticking;
//   00000100 base page; 00000101 local page; 00000102 stability page;
//   00000104 scalable page; 00000105 gamma-checkpoint page;
//   00000400 begin/restart checkpoint loading using the staged index.
// Other commands, including 00000200, complete with an error.
// A tick before configuration completes with an error. Once configured, a tick
// waits for tick_ready and executes on the SAME edge as its bus completion.
// Waiting preserves staged requests and last-tick results. Requests clear only
// on an accepted tick, including automatic mode. No autonomous ticks occur.
// A command withdrawn before completion is not queued or executed later.
//
// Common RW words: 04 mode (0 free, 1 7/1, 2 1/7); 08 request lane;
// 0C request cell; 10 target (0 active zero, 1 positive, 3 negative); 14 valid;
// 18 observed cell. Out-of-range selectors and target code 2 are errors.
// Mode takes effect in the core on the edge after its CSR write: allow an idle
// clock or read active mode (20) before ticking. 1C status bit 0 is reset-ready.
// Common RO words 20..64 retain the M22 meanings. Per-cell reads use selector 18.
// Duplicate target-bank entries are assigned in lane order, higher lane last;
// request arbitration and active-zero routes are implemented by the core.
//
// Base page, hexadecimal aligned word addresses; unspecified access is RO:
//   68 RW automatic targets (0/1); 6C RW staged phase; 70 RW staged frequency;
//   74 selected phase gamma; 78 selected phase attenuation;
//   7C phase; 80 frequency; 84 coupling Q16; 88 projection Q30;
//   8C phase target; 90 registered target;
//   94 bits 0..5: registered-valid, phase-domain-valid, registered-domain-valid,
//      registered-request-enable, last capture accepted, last capture rejected;
//   98/9C accepted/rejected capture counts; A0/A4/A8/AC/B0 scheduler counts;
//   B4/B8/BC pair/cluster/global coherence Q30; C0 dispersion Q30;
//   C4 last cycle cost Q16; C8/CC temperature/peak Q16; D0 thermal sample count;
//   D4 capacity Q16; D8 pressure Q16; DC margin Q16; E0 stable;
//   E4/E8/EC last accepted/neutral/changed cell-mask windows;
//   F0/F4 last phase/execution request windows; F8 execution target-bank window;
//   FC ID 46524701. Requests pack {targets,indexes,valid}, lane 0 first per field.
// Phase/frequency staging becomes active only through command 8.
//
// Local page (RO): 68 = 3 (local gamma and attenuation enabled); 6C reserved;
//   70 target Q16; 74 noise state Q16; 78 drift; 7C local effective gamma;
//   80 selected phase gamma; 84/88 heat/peak Q16; 8C generated power Q16;
//   90/94 dissipation/diffusion Q16; 98 overload Q16; 9C attenuation Q30;
//   A0 frequency lag Q16; A4/A8/AC mean heat/peak mean/maximum peak Q16;
//   B0/B4 next heat/overload; B8/BC next drift/effective gamma;
//   C0/C4 next/selected attenuation Q30; C8..F8 reserved; FC ID 46524702.
//
// Stability page (RO): 68 compression Q30; 6C effective coherence Q30;
//   70 capacity Q16; 74 pressure Q16; 78 margin Q16; 7C stable;
//   80 previous margin; 84 sample-valid; 88 sample count;
//   8C/90 sampled raw/cluster coherence; 94/98/9C sampled heat/overload/lag;
//   A0 sampled active-zero fraction Q30; A4 compression argument Q16;
//   A8 sampled switch load Q16; AC..C4 first seven group coherences;
//   C8..D0 first three level means; D4..DC minima; E0..E8 maxima;
//   EC..F4 dispersions; F8 reserved; FC ID 46524703.
// Stability samples retire one edge after a tick, including during bus waits.
// Read after that edge for the completed sample; live candidates remain live.
//
// Scalable page: 68 cells; 6C lanes; 70 cell-index bits; 74 counter bits;
//   78 levels; 7C groups; 80 RW window index; 84 RW group index;
//   88 selected group coherence; 8C RW level index; 90/94/98/9C level
//   mean/minimum/maximum/dispersion; A0 group size; A4 request-record bits;
//   A8 state-bank bits; AC/B0/B4/B8/BC execution/state/pending/registered/phase
//   target windows; C0/C4 phase/execution request windows; C8 cell selector;
//   CC lane selector; D0 window count; D4 state-bank words; D8 request words;
//   DC cell-mask words; E0..F8 reserved; FC ID 46524704.
// Window index accepts 0..D0-1 (1/1/2/5 windows for 8/16/32/64 cells).
// Narrow banks are zero-extended. The same selector controls base E4..F8.
// Group index accepts 0..CELLS-2; level index accepts 0..clog2(CELLS)-1.
//
// Gamma-checkpoint page: 68 RO status: bits 0..6 = reset-ready, configured,
//   word-ready, source-busy, bank-valid, tick-ready, load-error; bits 10:8 cadence;
//   6C RW staged checkpoint index (0..624, reset 624); 70 WO checkpoint word;
//   74 RO words accepted since begin (0..624); 78 RO 624; 7C RO 8;
//   80..F8 reserved; FC RO ID 46524705. Reading 70 is an error.
// Write index, issue command 400, then write exactly 624 words at 70 in the
// order from Python random.Random.getstate()[1], taken after FRP initialization.
// Word writes outside an active load are errors. An all-zero completed load
// sets load-error and keeps configured low; a new begin clears the error.
// Begin aborts prefetch, retains core histories/cadence and restarts word count.
// Index writes during a load stage the next begin and do not alter that load.
// Gamma updates on accepted logical ticks 0,8,16,...; counter clear retains
// cadence, checkpoint, selectors, staged data, and local histories. Reset clears
// configuration, cadence and histories and restores the base page.
// Complete telemetry reads before another tick/load for a consistent bank view.

`ifndef FRP_M32_INTERNAL_GAMMA_CSR_TOP_SV
`define FRP_M32_INTERNAL_GAMMA_CSR_TOP_SV

`timescale 1ns / 1ps

`include "frp_m22_csr_pkg.sv"
`include "frp_m32_internal_gamma_fpga_top.sv"

module frp_m32_internal_gamma_csr_top #(
  parameter string SIN_LUT_FILE = "rtl/m31/frp_m31_sin_q30.mem",
  parameter int CELLS = 8
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

  localparam int REQUEST_LANES = frp_calc_request_lanes(CELLS);
  localparam int CELL_INDEX_BITS = $clog2(CELLS);
  localparam int LANE_INDEX_BITS = $clog2(REQUEST_LANES);
  localparam int LEVELS = $clog2(CELLS);
  localparam int REQUEST_BITS = REQUEST_LANES*(CELL_INDEX_BITS+3);
  localparam int BANK_WORDS = (CELLS*2+31)/32;
  localparam int REQUEST_WORDS = (REQUEST_BITS+31)/32;
  localparam int WINDOW_WORDS = (REQUEST_WORDS > BANK_WORDS) ? REQUEST_WORDS : BANK_WORDS;
  localparam int WINDOW_BITS = WINDOW_WORDS*32;
  localparam int WORD_INDEX_BITS = (WINDOW_WORDS <= 1) ? 1 : $clog2(WINDOW_WORDS);

`ifndef SYNTHESIS
  initial begin
    if ((CELLS != 8) && (CELLS != 16) && (CELLS != 32) && (CELLS != 64))
      $fatal(1, "Internal-gamma CSR requires 8, 16, 32 or 64 cells");
  end
`endif

  localparam logic [7:0] ADDR_AUTO = 8'h68;
  localparam logic [7:0] ADDR_PHASE_LOAD = 8'h6C;
  localparam logic [7:0] ADDR_FREQUENCY_LOAD = 8'h70;
  localparam logic [7:0] ADDR_GAMMA = 8'h74;
  localparam logic [7:0] ADDR_THERMAL_FACTOR = 8'h78;
  localparam logic [31:0] COMMAND_LOAD = 32'd8;
  localparam logic [31:0] COMMAND_BASE_PAGE = 32'h00000100;
  localparam logic [31:0] COMMAND_LOCAL_PAGE = 32'h00000101;
  localparam logic [31:0] COMMAND_STABILITY_PAGE = 32'h00000102;
  localparam logic [31:0] COMMAND_SCALE_PAGE = 32'h00000104;
  localparam logic [31:0] COMMAND_GAMMA_PAGE = 32'h00000105;
  localparam logic [31:0] COMMAND_CHECKPOINT_BEGIN = 32'h00000400;

  logic local_page_q;
  logic stability_page_q;
  logic scale_page_q;
  logic gamma_page_q;
  logic [WORD_INDEX_BITS-1:0] telemetry_word_q;
  logic [CELL_INDEX_BITS-1:0] group_select_q;
  logic [2:0] level_select_q;
  logic [9:0] checkpoint_index_q, checkpoint_words_q;
  wire checkpoint_load_ready, checkpoint_begin_ready;
  wire checkpoint_begin_accepted, checkpoint_word_accepted;
  wire gamma_configured, gamma_load_error, gamma_source_busy, gamma_bank_valid;
  wire tick_ready, tick_accepted, phase_load_ready, phase_load_accepted;
  wire gamma_update_accepted;
  wire [2:0] gamma_tick_phase_q;
  wire tick_intent, checkpoint_begin_pulse, checkpoint_word_pulse;
  logic access_error;

  logic core_ready;
  logic accepted_write, tick_pulse, clear_pulse, load_pulse;
  logic payload_valid, address_writable;
  frp_m31_scheduler_mode_e mode_control_q;
  logic [LANE_INDEX_BITS-1:0] lane_select_q;
  logic auto_enable_q;
  logic [CELL_INDEX_BITS-1:0] cell_select_q;
  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] request_cells_q;
  logic [(REQUEST_LANES*2)-1:0] request_targets_q;
  logic [REQUEST_LANES-1:0] request_valid_q;
  logic [(CELLS*2)-1:0] target_bank;
  logic [(CELLS*32)-1:0] phase_load_q, frequency_load_q;

  logic [(CELLS*32)-1:0] phase_word_q, frequency_current_q16;
  logic [(CELLS*32)-1:0] coupling_field_q16, phase_projection_q30;
  logic [(CELLS*2)-1:0] phase_target_source, registered_target_q;
  logic registered_target_valid_q, phase_target_domain_valid;
  logic registered_target_domain_valid, registered_request_enable;
  logic [31:0] accepted_target_capture_events_q;
  logic [31:0] rejected_target_capture_events_q;
  logic [REQUEST_LANES-1:0] phase_request_valid, execution_request_valid;
  logic [(REQUEST_LANES*CELL_INDEX_BITS)-1:0] phase_request_cell_index, execution_request_cell_index;
  logic [(REQUEST_LANES*2)-1:0] phase_request_target, execution_request_target;
  logic [(CELLS*2)-1:0] state_out, pending_route_out;
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
  logic [(CELLS*32)-1:0] local_heat_q16;
  logic [(CELLS*32)-1:0] local_heat_peak_q16;
  logic [(CELLS*32)-1:0] local_generated_power_q16;
  logic [(CELLS*32)-1:0] local_thermal_dissipation_q16;
  logic [(CELLS*32)-1:0] local_thermal_diffusion_q16;
  logic [(CELLS*32)-1:0] local_thermal_overload_q16;
  logic [(CELLS*32)-1:0] local_next_heat_q16;
  logic [(CELLS*32)-1:0] local_next_overload_q16;
  logic [(CELLS*32)-1:0] local_frequency_lag_q16;
  logic [(CELLS*32)-1:0] local_gamma_noise_target_q16;
  logic [(CELLS*32)-1:0] local_gamma_noise_state_q16;
  logic [(CELLS*32)-1:0] local_gamma_drift_word;
  logic [(CELLS*32)-1:0] local_gamma_effective_word;
  logic [(CELLS*32)-1:0] local_next_gamma_drift_word;
  logic [(CELLS*32)-1:0] local_next_gamma_effective_word;
  logic [(CELLS*32)-1:0] phase_gamma_effective_word;
  logic [(CELLS*32)-1:0] local_thermal_node_factor_q30;
  logic [(CELLS*32)-1:0] local_next_thermal_node_factor_q30;
  logic [(CELLS*32)-1:0] phase_thermal_node_factor_q30;
  logic signed [31:0] local_mean_heat_q16;
  logic signed [31:0] local_mean_heat_peak_q16;
  logic signed [31:0] local_maximum_heat_peak_q16;


  logic [((CELLS-1)*32)-1:0] group_coherence_q30;
  logic [(LEVELS*32)-1:0] level_mean_coherence_q30;
  logic [(LEVELS*32)-1:0] level_min_coherence_q30;
  logic [(LEVELS*32)-1:0] level_max_coherence_q30;
  logic [(LEVELS*32)-1:0] level_dispersion_q30;
  logic signed [31:0] local_coherence_compression_q30;
  logic signed [31:0] local_effective_coherence_q30;
  logic signed [31:0] local_coherence_capacity_q16;
  logic signed [31:0] local_pressure_q16;
  logic signed [31:0] local_stability_margin_q16;
  logic local_stable;
  logic signed [31:0] local_previous_margin_q16;
  logic local_stability_valid_q;
  logic [31:0] local_stability_sample_count_q;
  logic signed [31:0] local_stability_raw_coherence_q30;
  logic signed [31:0] local_stability_cluster_coherence_q30;
  logic signed [31:0] local_stability_mean_heat_q16;
  logic signed [31:0] local_stability_mean_overload_q16;
  logic signed [31:0] local_stability_mean_lag_q16;
  logic signed [31:0] local_stability_neutral_fraction_q30;
  logic signed [31:0] local_stability_compression_arg_q16;
  logic signed [31:0] local_stability_switch_load_q16;

  typedef struct packed {
    logic [REQUEST_LANES-1:0] request_accept, request_reject;
    logic [CELLS-1:0] accepted_cells, neutral_cells, changed_cells;
    logic [31:0] accepted_changes, capacity_remaining;
    logic capacity_exhausted;
    logic [31:0] switch_load, requested_direct, prevented_direct;
    logic [31:0] neutral_routed, actual_direct, reserved_state, queue_overflow;
    logic [FRP_M31_INVARIANT_FLAGS-1:0] invariant_flags;
    logic capture_accepted, capture_rejected;
    logic signed [31:0] cycle_cost;
    logic [REQUEST_BITS-1:0] phase_requests, execution_requests;
    logic [(CELLS*2)-1:0] execution_target_bank;
  } tick_result_t;
  tick_result_t tick_result, last_tick_q;

  assign tick_result.phase_requests =
    {phase_request_target, phase_request_cell_index, phase_request_valid};
  assign tick_result.execution_requests =
    {execution_request_target, execution_request_cell_index,
     execution_request_valid};

  function automatic logic [31:0] telemetry_word(input logic [WINDOW_BITS-1:0] bank);
    telemetry_word = bank[int'(telemetry_word_q)*32 +: 32];
  endfunction

  always_comb begin
    target_bank = '0;
    for (int lane = 0; lane < REQUEST_LANES; lane++) begin
      if (request_valid_q[lane])
        target_bank[int'(request_cells_q[lane*CELL_INDEX_BITS +: CELL_INDEX_BITS])*2 +: 2] =
          request_targets_q[lane*2 +: 2];
    end
  end

  always_comb begin
    address_writable = frp_m22_is_writable_address(csr_addr);
    payload_valid = 1'b0;
    if (csr_addr >= ADDR_AUTO) begin
      if (gamma_page_q) begin
        address_writable = (csr_addr == 8'h6C) || (csr_addr == 8'h70);
        case (csr_addr)
          8'h6C: payload_valid = (csr_wdata <= 32'd624);
          8'h70: payload_valid = checkpoint_load_ready;
          default: payload_valid = 1'b0;
        endcase
      end else if (scale_page_q) begin
        address_writable = (csr_addr == 8'h80) || (csr_addr == 8'h84) || (csr_addr == 8'h8C);
        case (csr_addr)
          8'h80: payload_valid = (csr_wdata < 32'(WINDOW_WORDS));
          8'h84: payload_valid = (csr_wdata < 32'(CELLS-1));
          8'h8C: payload_valid = (csr_wdata < 32'(LEVELS));
          default: payload_valid = 1'b0;
        endcase
      end else if (stability_page_q || local_page_q) begin
        address_writable = 1'b0;
      end else begin
        address_writable = (csr_addr == ADDR_AUTO) || (csr_addr == ADDR_PHASE_LOAD)
          || (csr_addr == ADDR_FREQUENCY_LOAD);
        case (csr_addr)
          ADDR_AUTO: payload_valid = (csr_wdata <= 32'd1);
          ADDR_PHASE_LOAD, ADDR_FREQUENCY_LOAD: payload_valid = 1'b1;
          default: payload_valid = 1'b0;
        endcase
      end
    end else begin
      case (csr_addr)
        FRP_M22_ADDR_CONTROL:
          payload_valid = ((csr_wdata == FRP_M22_CONTROL_TICK) && gamma_configured)
            || (csr_wdata == FRP_M22_CONTROL_CLEAR_COUNTERS)
            || (csr_wdata == FRP_M22_CONTROL_CLEAR_REQUESTS)
            || (csr_wdata == COMMAND_LOAD)
            || (csr_wdata == COMMAND_BASE_PAGE)
            || (csr_wdata == COMMAND_LOCAL_PAGE)
            || (csr_wdata == COMMAND_STABILITY_PAGE)
            || (csr_wdata == COMMAND_SCALE_PAGE)
            || (csr_wdata == COMMAND_GAMMA_PAGE)
            || (csr_wdata == COMMAND_CHECKPOINT_BEGIN);
        FRP_M22_ADDR_SCHEDULER_MODE:
          payload_valid = (csr_wdata <= 32'd2);
        FRP_M22_ADDR_REQUEST_LANE_SELECT:
          payload_valid = (csr_wdata < 32'(REQUEST_LANES));
        FRP_M22_ADDR_REQUEST_CELL_INDEX, FRP_M22_ADDR_OBSERVE_CELL_INDEX:
          payload_valid = (csr_wdata < 32'(CELLS));
        FRP_M22_ADDR_REQUEST_TARGET:
          payload_valid = (csr_wdata == 32'd0) || (csr_wdata == 32'd1)
            || (csr_wdata == 32'd3);
        FRP_M22_ADDR_REQUEST_VALID:
          payload_valid = (csr_wdata <= 32'd1);
        default: payload_valid = 1'b0;
      endcase
    end

    access_error = !frp_m22_is_word_aligned(csr_addr);
    if (csr_write)
      access_error = access_error || !address_writable || !payload_valid;
    else
      access_error = access_error || (csr_addr == FRP_M22_ADDR_CONTROL)
        || (gamma_page_q && (csr_addr >= ADDR_AUTO)
          && !((csr_addr == 8'h68) || (csr_addr == 8'h6C)
            || (csr_addr == 8'h74) || (csr_addr == 8'h78)
            || (csr_addr == 8'h7C) || (csr_addr == 8'hFC)))
        || (local_page_q && ((csr_addr == 8'h6C)
          || ((csr_addr >= 8'hC8) && (csr_addr < 8'hFC))))
        || (stability_page_q && (csr_addr == 8'hF8))
        || (scale_page_q && (csr_addr >= 8'hE0) && (csr_addr < 8'hFC));

    csr_ready = rst_n_async && core_ready && csr_valid;
    if (!access_error && tick_intent)
      csr_ready = csr_ready && tick_ready;
    csr_error = csr_ready && access_error;
  end

  // Present valid independently of ready; the bus and core accept on one edge.
  assign tick_intent = rst_n_async && core_ready && csr_valid && csr_write
    && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == FRP_M22_CONTROL_TICK) && gamma_configured;
  assign accepted_write = csr_ready && csr_write && !csr_error;
  assign tick_pulse = tick_accepted;
  assign clear_pulse = accepted_write && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == FRP_M22_CONTROL_CLEAR_COUNTERS);
  assign load_pulse = accepted_write && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == COMMAND_LOAD);
  assign checkpoint_begin_pulse = rst_n_async && core_ready && csr_valid && csr_write
    && (csr_addr == FRP_M22_ADDR_CONTROL)
    && (csr_wdata == COMMAND_CHECKPOINT_BEGIN);
  assign checkpoint_word_pulse = accepted_write && gamma_page_q && (csr_addr == 8'h70);

  // core_ready is the existing two-stage synchronized reset release.
  always_ff @(posedge clk or negedge core_ready) begin
    if (!core_ready) begin
      mode_control_q <= FRP_MODE_FREE;
      lane_select_q <= '0;
      cell_select_q <= '0;
      auto_enable_q <= 1'b0;
      local_page_q <= 1'b0;
      stability_page_q <= 1'b0;
      scale_page_q <= 1'b0;
      gamma_page_q <= 1'b0;
      telemetry_word_q <= '0;
      group_select_q <= '0;
      level_select_q <= '0;
      checkpoint_index_q <= 10'd624;
      checkpoint_words_q <= '0;
      request_cells_q <= '0;
      request_targets_q <= '0;
      request_valid_q <= '0;
      phase_load_q <= '0;
      frequency_load_q <= '0;
      last_tick_q <= '0;
      last_tick_q.invariant_flags <= '1;
    end else begin
      if (checkpoint_begin_accepted)
        checkpoint_words_q <= 10'd0;
      else if (checkpoint_word_accepted)
        checkpoint_words_q <= checkpoint_words_q + 10'd1;
      if (tick_pulse) begin
        last_tick_q <= tick_result;
        request_valid_q <= '0;
      end
      if (clear_pulse) begin
        last_tick_q <= '0;
        last_tick_q.invariant_flags <= '1;
      end
      if (accepted_write) begin
        if (gamma_page_q && (csr_addr >= ADDR_AUTO)) begin
          if (csr_addr == 8'h6C)
            checkpoint_index_q <= csr_wdata[9:0];
        end else if (scale_page_q && (csr_addr >= ADDR_AUTO)) begin
          case (csr_addr)
            8'h80: telemetry_word_q <= csr_wdata[WORD_INDEX_BITS-1:0];
            8'h84: group_select_q <= csr_wdata[CELL_INDEX_BITS-1:0];
            8'h8C: level_select_q <= csr_wdata[2:0];
            default: begin end
          endcase
        end else begin
          case (csr_addr)
            FRP_M22_ADDR_CONTROL: begin
              if (csr_wdata == FRP_M22_CONTROL_CLEAR_REQUESTS)
                request_valid_q <= '0;
              if ((csr_wdata == COMMAND_BASE_PAGE)
                  || (csr_wdata == COMMAND_LOCAL_PAGE)
                  || (csr_wdata == COMMAND_STABILITY_PAGE)
                  || (csr_wdata == COMMAND_SCALE_PAGE)
                  || (csr_wdata == COMMAND_GAMMA_PAGE)) begin
                local_page_q <= (csr_wdata == COMMAND_LOCAL_PAGE);
                stability_page_q <= (csr_wdata == COMMAND_STABILITY_PAGE);
                scale_page_q <= (csr_wdata == COMMAND_SCALE_PAGE);
                gamma_page_q <= (csr_wdata == COMMAND_GAMMA_PAGE);
              end
            end
            FRP_M22_ADDR_SCHEDULER_MODE:
              mode_control_q <= frp_m31_scheduler_mode_e'(csr_wdata[1:0]);
            FRP_M22_ADDR_REQUEST_LANE_SELECT:
              lane_select_q <= csr_wdata[LANE_INDEX_BITS-1:0];
            FRP_M22_ADDR_REQUEST_CELL_INDEX:
              request_cells_q[int'(lane_select_q)*CELL_INDEX_BITS +: CELL_INDEX_BITS] <= csr_wdata[CELL_INDEX_BITS-1:0];
            FRP_M22_ADDR_REQUEST_TARGET:
              request_targets_q[int'(lane_select_q)*2 +: 2] <= csr_wdata[1:0];
            FRP_M22_ADDR_REQUEST_VALID:
              request_valid_q[lane_select_q] <= csr_wdata[0];
            FRP_M22_ADDR_OBSERVE_CELL_INDEX:
              cell_select_q <= csr_wdata[CELL_INDEX_BITS-1:0];
            ADDR_AUTO: auto_enable_q <= csr_wdata[0];
            ADDR_PHASE_LOAD:
              phase_load_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
            ADDR_FREQUENCY_LOAD:
              frequency_load_q[int'(cell_select_q)*32 +: 32] <= csr_wdata;
            default: begin end
          endcase
        end
      end
    end
  end

  always_comb begin
    csr_rdata = '0;
    if (csr_ready && !csr_write && !csr_error) begin
      if (gamma_page_q && (csr_addr >= ADDR_AUTO)) begin
        case (csr_addr)
          8'h68: begin
            csr_rdata[0] = core_ready;
            csr_rdata[1] = gamma_configured;
            csr_rdata[2] = checkpoint_load_ready;
            csr_rdata[3] = gamma_source_busy;
            csr_rdata[4] = gamma_bank_valid;
            csr_rdata[5] = tick_ready;
            csr_rdata[6] = gamma_load_error;
            csr_rdata[10:8] = gamma_tick_phase_q;
          end
          8'h6C: csr_rdata[9:0] = checkpoint_index_q;
          8'h74: csr_rdata[9:0] = checkpoint_words_q;
          8'h78: csr_rdata = 32'd624;
          8'h7C: csr_rdata = 32'd8;
          8'hFC: csr_rdata = 32'h46524705;
          default: csr_rdata = '0;
        endcase
      end else if (scale_page_q && (csr_addr >= ADDR_AUTO)) begin
        case (csr_addr)
          8'h68: csr_rdata = 32'(CELLS);
          8'h6C: csr_rdata = 32'(REQUEST_LANES);
          8'h70: csr_rdata = 32'(CELL_INDEX_BITS);
          8'h74: csr_rdata = 32'd32;
          8'h78: csr_rdata = 32'(LEVELS);
          8'h7C: csr_rdata = 32'(CELLS-1);
          8'h80: csr_rdata[WORD_INDEX_BITS-1:0] = telemetry_word_q;
          8'h84: csr_rdata[CELL_INDEX_BITS-1:0] = group_select_q;
          8'h88: csr_rdata = group_coherence_q30[int'(group_select_q)*32 +: 32];
          8'h8C: csr_rdata[2:0] = level_select_q;
          8'h90: csr_rdata = level_mean_coherence_q30[int'(level_select_q)*32 +: 32];
          8'h94: csr_rdata = level_min_coherence_q30[int'(level_select_q)*32 +: 32];
          8'h98: csr_rdata = level_max_coherence_q30[int'(level_select_q)*32 +: 32];
          8'h9C: csr_rdata = level_dispersion_q30[int'(level_select_q)*32 +: 32];
          8'hA0: csr_rdata = 32'd2 << level_select_q;
          8'hA4: csr_rdata = 32'(REQUEST_BITS);
          8'hA8: csr_rdata = 32'(CELLS*2);
          8'hAC: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.execution_target_bank));
          8'hB0: csr_rdata = telemetry_word(WINDOW_BITS'(state_out));
          8'hB4: csr_rdata = telemetry_word(WINDOW_BITS'(pending_route_out));
          8'hB8: csr_rdata = telemetry_word(WINDOW_BITS'(registered_target_q));
          8'hBC: csr_rdata = telemetry_word(WINDOW_BITS'(phase_target_source));
          8'hC0: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.phase_requests));
          8'hC4: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.execution_requests));
          8'hC8: csr_rdata[CELL_INDEX_BITS-1:0] = cell_select_q;
          8'hCC: csr_rdata[LANE_INDEX_BITS-1:0] = lane_select_q;
          8'hD0: csr_rdata = 32'(WINDOW_WORDS);
          8'hD4: csr_rdata = 32'(BANK_WORDS);
          8'hD8: csr_rdata = 32'(REQUEST_WORDS);
          8'hDC: csr_rdata = 32'((CELLS+31)/32);
          8'hFC: csr_rdata = 32'h46524704;
          default: csr_rdata = '0;
        endcase
      end else if (stability_page_q && (csr_addr >= ADDR_AUTO)) begin
        case (csr_addr)
          8'h68: csr_rdata = local_coherence_compression_q30;
          8'h6C: csr_rdata = local_effective_coherence_q30;
          8'h70: csr_rdata = local_coherence_capacity_q16;
          8'h74: csr_rdata = local_pressure_q16;
          8'h78: csr_rdata = local_stability_margin_q16;
          8'h7C: csr_rdata[0] = local_stable;
          8'h80: csr_rdata = local_previous_margin_q16;
          8'h84: csr_rdata[0] = local_stability_valid_q;
          8'h88: csr_rdata = local_stability_sample_count_q;
          8'h8C: csr_rdata = local_stability_raw_coherence_q30;
          8'h90: csr_rdata = local_stability_cluster_coherence_q30;
          8'h94: csr_rdata = local_stability_mean_heat_q16;
          8'h98: csr_rdata = local_stability_mean_overload_q16;
          8'h9C: csr_rdata = local_stability_mean_lag_q16;
          8'hA0: csr_rdata = local_stability_neutral_fraction_q30;
          8'hA4: csr_rdata = local_stability_compression_arg_q16;
          8'hA8: csr_rdata = local_stability_switch_load_q16;
          8'hAC: csr_rdata = group_coherence_q30[0 +: 32];
          8'hB0: csr_rdata = group_coherence_q30[32 +: 32];
          8'hB4: csr_rdata = group_coherence_q30[64 +: 32];
          8'hB8: csr_rdata = group_coherence_q30[96 +: 32];
          8'hBC: csr_rdata = group_coherence_q30[128 +: 32];
          8'hC0: csr_rdata = group_coherence_q30[160 +: 32];
          8'hC4: csr_rdata = group_coherence_q30[192 +: 32];
          8'hC8: csr_rdata = level_mean_coherence_q30[0 +: 32];
          8'hCC: csr_rdata = level_mean_coherence_q30[32 +: 32];
          8'hD0: csr_rdata = level_mean_coherence_q30[64 +: 32];
          8'hD4: csr_rdata = level_min_coherence_q30[0 +: 32];
          8'hD8: csr_rdata = level_min_coherence_q30[32 +: 32];
          8'hDC: csr_rdata = level_min_coherence_q30[64 +: 32];
          8'hE0: csr_rdata = level_max_coherence_q30[0 +: 32];
          8'hE4: csr_rdata = level_max_coherence_q30[32 +: 32];
          8'hE8: csr_rdata = level_max_coherence_q30[64 +: 32];
          8'hEC: csr_rdata = level_dispersion_q30[0 +: 32];
          8'hF0: csr_rdata = level_dispersion_q30[32 +: 32];
          8'hF4: csr_rdata = level_dispersion_q30[64 +: 32];
          8'hFC: csr_rdata = 32'h46524703;
          default: csr_rdata = '0;
        endcase
      end else if (local_page_q && (csr_addr >= ADDR_AUTO)) begin
        case (csr_addr)
          ADDR_AUTO: csr_rdata = 32'd3;
          8'h70: csr_rdata = local_gamma_noise_target_q16[int'(cell_select_q)*32 +: 32];
          8'h74: csr_rdata = local_gamma_noise_state_q16[int'(cell_select_q)*32 +: 32];
          8'h78: csr_rdata = local_gamma_drift_word[int'(cell_select_q)*32 +: 32];
          8'h7C: csr_rdata = local_gamma_effective_word[int'(cell_select_q)*32 +: 32];
          8'h80: csr_rdata = phase_gamma_effective_word[int'(cell_select_q)*32 +: 32];
          8'h84: csr_rdata = local_heat_q16[int'(cell_select_q)*32 +: 32];
          8'h88: csr_rdata = local_heat_peak_q16[int'(cell_select_q)*32 +: 32];
          8'h8C: csr_rdata = local_generated_power_q16[int'(cell_select_q)*32 +: 32];
          8'h90: csr_rdata = local_thermal_dissipation_q16[int'(cell_select_q)*32 +: 32];
          8'h94: csr_rdata = local_thermal_diffusion_q16[int'(cell_select_q)*32 +: 32];
          8'h98: csr_rdata = local_thermal_overload_q16[int'(cell_select_q)*32 +: 32];
          8'h9C: csr_rdata = local_thermal_node_factor_q30[int'(cell_select_q)*32 +: 32];
          8'hA0: csr_rdata = local_frequency_lag_q16[int'(cell_select_q)*32 +: 32];
          8'hA4: csr_rdata = local_mean_heat_q16;
          8'hA8: csr_rdata = local_mean_heat_peak_q16;
          8'hAC: csr_rdata = local_maximum_heat_peak_q16;
          8'hB0: csr_rdata = local_next_heat_q16[int'(cell_select_q)*32 +: 32];
          8'hB4: csr_rdata = local_next_overload_q16[int'(cell_select_q)*32 +: 32];
          8'hB8: csr_rdata = local_next_gamma_drift_word[int'(cell_select_q)*32 +: 32];
          8'hBC: csr_rdata = local_next_gamma_effective_word[int'(cell_select_q)*32 +: 32];
          8'hC0: csr_rdata = local_next_thermal_node_factor_q30[int'(cell_select_q)*32 +: 32];
          8'hC4: csr_rdata = phase_thermal_node_factor_q30[int'(cell_select_q)*32 +: 32];
          8'hFC: csr_rdata = 32'h46524702;
          default: csr_rdata = '0;
        endcase
      end else begin
        case (csr_addr)
          FRP_M22_ADDR_SCHEDULER_MODE: csr_rdata = {30'd0, mode_control_q};
          FRP_M22_ADDR_REQUEST_LANE_SELECT: csr_rdata[LANE_INDEX_BITS-1:0] = lane_select_q;
          FRP_M22_ADDR_REQUEST_CELL_INDEX:
            csr_rdata[CELL_INDEX_BITS-1:0] = request_cells_q[int'(lane_select_q)*CELL_INDEX_BITS +: CELL_INDEX_BITS];
          FRP_M22_ADDR_REQUEST_TARGET:
            csr_rdata[1:0] = request_targets_q[int'(lane_select_q)*2 +: 2];
          FRP_M22_ADDR_REQUEST_VALID:
            csr_rdata[0] = request_valid_q[lane_select_q];
          FRP_M22_ADDR_OBSERVE_CELL_INDEX: csr_rdata[CELL_INDEX_BITS-1:0] = cell_select_q;
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
          FRP_M22_ADDR_REQUEST_ACCEPT: csr_rdata[REQUEST_LANES-1:0] = last_tick_q.request_accept;
          FRP_M22_ADDR_REQUEST_REJECT: csr_rdata[REQUEST_LANES-1:0] = last_tick_q.request_reject;
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
          ADDR_GAMMA: csr_rdata = phase_gamma_effective_word[int'(cell_select_q)*32 +: 32];
          ADDR_THERMAL_FACTOR:
            csr_rdata = phase_thermal_node_factor_q30[int'(cell_select_q)*32 +: 32];
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
          8'hE4: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.accepted_cells));
          8'hE8: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.neutral_cells));
          8'hEC: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.changed_cells));
          8'hF0: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.phase_requests));
          8'hF4: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.execution_requests));
          8'hF8: csr_rdata = telemetry_word(WINDOW_BITS'(last_tick_q.execution_target_bank));
          8'hFC: csr_rdata = 32'h46524701;
          default: csr_rdata = '0;
        endcase
      end
    end
  end

  frp_m32_internal_gamma_fpga_top #(
    .CELLS(CELLS), .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS), .COUNTER_BITS(32),
    .SIN_LUT_FILE(SIN_LUT_FILE)
  ) u_fpga (
    .clk(clk), .rst_n_async(rst_n_async), .core_ready(core_ready),
    .tick_valid(tick_intent), .clear_counters(clear_pulse),
    .scheduler_mode(mode_control_q), .phase_load_valid(load_pulse),
    .phase_load(phase_load_q), .frequency_load_q16(frequency_load_q),
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
    .stability_margin_q16(stability_margin_q16), .stable(stable),
    .local_heat_q16(local_heat_q16),
    .local_heat_peak_q16(local_heat_peak_q16),
    .local_generated_power_q16(local_generated_power_q16),
    .local_thermal_dissipation_q16(local_thermal_dissipation_q16),
    .local_thermal_diffusion_q16(local_thermal_diffusion_q16),
    .local_thermal_overload_q16(local_thermal_overload_q16),
    .local_next_heat_q16(local_next_heat_q16),
    .local_next_overload_q16(local_next_overload_q16),
    .local_frequency_lag_q16(local_frequency_lag_q16),
    .local_gamma_noise_target_q16(local_gamma_noise_target_q16),
    .local_gamma_noise_state_q16(local_gamma_noise_state_q16),
    .local_gamma_drift_word(local_gamma_drift_word),
    .local_gamma_effective_word(local_gamma_effective_word),
    .local_next_gamma_drift_word(local_next_gamma_drift_word),
    .local_next_gamma_effective_word(local_next_gamma_effective_word),
    .phase_gamma_effective_word(phase_gamma_effective_word),
    .local_thermal_node_factor_q30(local_thermal_node_factor_q30),
    .local_next_thermal_node_factor_q30(local_next_thermal_node_factor_q30),
    .phase_thermal_node_factor_q30(phase_thermal_node_factor_q30),
    .local_mean_heat_q16(local_mean_heat_q16),
    .local_mean_heat_peak_q16(local_mean_heat_peak_q16),
    .local_maximum_heat_peak_q16(local_maximum_heat_peak_q16),
    .checkpoint_load_begin(checkpoint_begin_pulse),
    .checkpoint_index(checkpoint_index_q),
    .checkpoint_load_valid(checkpoint_word_pulse),
    .checkpoint_load_word(csr_wdata),
    .checkpoint_load_ready(checkpoint_load_ready),
    .checkpoint_begin_ready(checkpoint_begin_ready),
    .checkpoint_begin_accepted(checkpoint_begin_accepted),
    .checkpoint_word_accepted(checkpoint_word_accepted),
    .gamma_configured(gamma_configured), .gamma_load_error(gamma_load_error),
    .gamma_source_busy(gamma_source_busy), .gamma_bank_valid(gamma_bank_valid),
    .tick_ready(tick_ready), .tick_accepted(tick_accepted),
    .phase_load_ready(phase_load_ready), .phase_load_accepted(phase_load_accepted),
    .gamma_update_accepted(gamma_update_accepted), .gamma_tick_phase_q(gamma_tick_phase_q),
    .local_coherence_compression_q30(local_coherence_compression_q30),
    .local_effective_coherence_q30(local_effective_coherence_q30),
    .local_coherence_capacity_q16(local_coherence_capacity_q16),
    .local_pressure_q16(local_pressure_q16),
    .local_stability_margin_q16(local_stability_margin_q16),
    .local_stable(local_stable),
    .local_previous_margin_q16(local_previous_margin_q16),
    .local_stability_valid_q(local_stability_valid_q),
    .local_stability_sample_count_q(local_stability_sample_count_q),
    .local_stability_raw_coherence_q30(local_stability_raw_coherence_q30),
    .local_stability_cluster_coherence_q30(local_stability_cluster_coherence_q30),
    .local_stability_mean_heat_q16(local_stability_mean_heat_q16),
    .local_stability_mean_overload_q16(local_stability_mean_overload_q16),
    .local_stability_mean_lag_q16(local_stability_mean_lag_q16),
    .local_stability_neutral_fraction_q30(local_stability_neutral_fraction_q30),
    .local_stability_compression_arg_q16(local_stability_compression_arg_q16),
    .local_stability_switch_load_q16(local_stability_switch_load_q16),
    .group_coherence_q30(group_coherence_q30),
    .level_mean_coherence_q30(level_mean_coherence_q30),
    .level_min_coherence_q30(level_min_coherence_q30),
    .level_max_coherence_q30(level_max_coherence_q30),
    .level_dispersion_q30(level_dispersion_q30)
  );
endmodule : frp_m32_internal_gamma_csr_top

`endif

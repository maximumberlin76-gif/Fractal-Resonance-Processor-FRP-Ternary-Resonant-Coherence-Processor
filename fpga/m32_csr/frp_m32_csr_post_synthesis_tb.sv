// SPDX-License-Identifier: Apache-2.0
// FRP M32 CSR post-synthesis integration testbench.
//
// Fixed profile: eight cells, two request lanes, 32-bit words/counters.
// The stimulus drives an independent M32 reference core and reset model.
// All 59 preserved core output wires in the flattened CSR netlist are
// compared after each rising clock edge. Hierarchical observations are read-only.
// The DUT must be the generated frp_m32_csr_netlist module; the reference is RTL.
// The DUT ROM is embedded in the netlist; the reference reads the canonical LUT.
// Expected responses are independent of DUT ready/error decisions.
//
// Coverage:
// - reset qualification and discarded commands before reset release;
// - all unaligned addresses, read-only writes, and invalid command payloads;
// - one-shot requests, both request lanes, and duplicate-cell arbitration;
// - -1/0/1, active zero, and both tick-separated opposite routes;
// - pending-route retention during pauses and counter clear;
// - complete phase/frequency staging and atomic eight-cell load;
// - per-cell gamma/thermal words and automatic registered-target requests;
// - free, 7/1, and 1/7 scheduler counts after explicit mode configuration;
// - the existing one-clock mode-registration delay and consecutive transfers;
// - live telemetry, last-tick snapshots, and asynchronous reset recovery.
//
// A shared monitor and scan process keep repeated checks out of the expanded
// stimulus code. Every failed comparison terminates with $fatal; timeout is
// fatal. The PASS marker is printed only after the complete scenario sequence.
// 'checks' counts full 59-output comparisons plus explicit CSR read checks.
// 'ticks' and 'rejected_transfers' count stimulus over all reset epochs.
//
// Export a simulation copy of the qualified CSR synthesis JSON with
// yowasp-yosys 0.68.0.0.post1208 (Yosys 0.68):
//   read_json netlist-run-1.json
//   techmap -map +/techmap.v t:$shiftx
//   opt_clean
//   check -assert
//   select -assert-none t:$shiftx t:$connect
//   rename frp_m32_csr_top frp_m32_csr_netlist
//   write_verilog -noattr /tmp/frp_m32_csr_netlist.v
// Mapping $shiftx gives explicit selection logic for signed indices. Keep the
// original synthesis JSON unchanged and use simlib.v from the same Yosys package.
// Preserve all nine CSR ports, ROM parameters/initialization, and the 59 observed
// u_fpga.* wire names and widths when exporting the simulation copy.
//
// Build from the repository root with Verilator 5.020; place that simlib.v at
// /tmp/yosys-simlib.v and the generated Verilog at the export path above:
// env verilator -DSIMLIB_NOCONNECT --binary --sv --timing --assert \
//   -Wall -Wno-fatal -CFLAGS "-std=c++20 -O0" --output-split 20000 \
//   -MAKEFLAGS VK_PCH_I_FAST= -MAKEFLAGS VK_PCH_I_SLOW= -j 2 \
//   --top-module frp_m32_csr_post_synthesis_tb --Mdir /tmp/frp-m32-csr-post-tb \
//   -Irtl/m31 -Irtl/m32 -v /tmp/yosys-simlib.v \
//   /tmp/frp_m32_csr_netlist.v fpga/m32_csr/frp_m32_csr_post_synthesis_tb.sv
// /tmp/frp-m32-csr-post-tb/Vfrp_m32_csr_post_synthesis_tb

`ifndef FRP_M32_CSR_POST_SYNTHESIS_TB_SV
`define FRP_M32_CSR_POST_SYNTHESIS_TB_SV

`timescale 1ns / 1ps
`include "frp_m32_core.sv"
module frp_m32_csr_post_synthesis_tb;
  import frp_m31_pkg::*;
  localparam int CELLS = 8, REQUEST_LANES = 2, CELL_INDEX_BITS = 3, COUNTER_BITS = 32;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n_async = 1, csr_valid = 0, csr_write = 0;
  logic [7:0] csr_addr = 0;
  logic [31:0] csr_wdata = 0, csr_rdata;
  logic csr_ready, csr_error;
  logic [1:0] reset_model = 0;
  always @(posedge clk or negedge rst_n_async)
    if (!rst_n_async) reset_model <= 0;
    else reset_model <= {reset_model[0], 1'b1};
  logic ref_tick = 0, ref_clear = 0, ref_load = 0, ref_auto = 0;
  frp_m31_scheduler_mode_e ref_mode = FRP_MODE_FREE;
  logic [255:0] phases = 0, frequencies = 0, gamma = 0, thermal = {8{32'h40000000}};
  logic [5:0] cells = 0;
  logic [3:0] targets = 0;
  logic [1:0] valid = 0;
  logic [15:0] bank;
  int lane = 0, cell_index = 0, checks = 0, ticks = 0, errors = 0;
  logic [31:0] sampled, saved[256];
  logic [31:0] phase_pattern[8], frequency_pattern[8];
  logic [255:0] before_staging_phase, before_staging_frequency;
  always_comb begin
    bank = 0;
    if (valid[0]) bank[int'(cells[2:0])*2 +: 2] = targets[1:0];
    if (valid[1]) bank[int'(cells[5:3])*2 +: 2] = targets[3:2];
  end
  frp_m32_csr_netlist dut (
    .clk(clk), .rst_n_async(rst_n_async),
    .csr_valid(csr_valid), .csr_write(csr_write),
    .csr_addr(csr_addr), .csr_wdata(csr_wdata),
    .csr_ready(csr_ready), .csr_error(csr_error), .csr_rdata(csr_rdata)
  );
  logic [(CELLS*32)-1:0] ref_phase_word_q;
  logic [(CELLS*32)-1:0] ref_frequency_current_q16;
  logic [(CELLS*32)-1:0] ref_coupling_field_q16;
  logic [(CELLS*32)-1:0] ref_phase_projection_q30;
  logic [15:0] ref_phase_target_source;
  logic [15:0] ref_registered_target_q;
  logic ref_registered_target_valid_q;
  logic ref_phase_target_domain_valid;
  logic ref_registered_target_domain_valid;
  logic ref_target_capture_accepted;
  logic ref_target_capture_rejected;
  logic [COUNTER_BITS-1:0] ref_accepted_target_capture_events_q;
  logic [COUNTER_BITS-1:0] ref_rejected_target_capture_events_q;
  logic ref_registered_request_enable;
  logic [REQUEST_LANES-1:0] ref_phase_request_valid;
  logic [5:0] ref_phase_request_cell_index;
  logic [3:0] ref_phase_request_target;
  logic [REQUEST_LANES-1:0] ref_execution_request_valid;
  logic [5:0] ref_execution_request_cell_index;
  logic [3:0] ref_execution_request_target;
  logic [15:0] ref_execution_target_bank;
  logic [15:0] ref_state_out;
  logic [15:0] ref_pending_route_out;
  frp_m31_scheduler_mode_e ref_scheduler_mode_q;
  frp_m31_scheduler_state_e ref_scheduler_state_q;
  logic [COUNTER_BITS-1:0] ref_ticks_recorded_q;
  logic [COUNTER_BITS-1:0] ref_scheduler_count_free_q;
  logic [COUNTER_BITS-1:0] ref_scheduler_count_balance_q;
  logic [COUNTER_BITS-1:0] ref_scheduler_count_commit_q;
  logic [COUNTER_BITS-1:0] ref_scheduler_count_excite_q;
  logic [COUNTER_BITS-1:0] ref_scheduler_count_neutralize_q;
  logic [REQUEST_LANES-1:0] ref_request_accept;
  logic [REQUEST_LANES-1:0] ref_request_reject;
  logic [CELLS-1:0] ref_accepted_cell_mask;
  logic [CELLS-1:0] ref_neutral_routed_cell_mask;
  logic [CELLS-1:0] ref_accepted_change_mask;
  logic [COUNTER_BITS-1:0] ref_accepted_changes;
  logic [COUNTER_BITS-1:0] ref_capacity_remaining;
  logic ref_capacity_exhausted;
  logic [COUNTER_BITS-1:0] ref_switch_load_numerator;
  logic [COUNTER_BITS-1:0] ref_requested_direct_events;
  logic [COUNTER_BITS-1:0] ref_prevented_direct_events;
  logic [COUNTER_BITS-1:0] ref_neutral_routed_events;
  logic [COUNTER_BITS-1:0] ref_actual_direct_events;
  logic [COUNTER_BITS-1:0] ref_reserved_state_events;
  logic [COUNTER_BITS-1:0] ref_queue_overflow_events;
  logic [FRP_M31_INVARIANT_FLAGS-1:0] ref_invariant_flags;
  logic signed [31:0] ref_pair_coherence_q30;
  logic signed [31:0] ref_cluster_coherence_q30;
  logic signed [31:0] ref_global_coherence_q30;
  logic signed [31:0] ref_organization_dispersion_q30;
  logic signed [31:0] ref_normalized_cycle_cost_q16;
  logic signed [31:0] ref_temperature_proxy_q16;
  logic signed [31:0] ref_peak_temperature_proxy_q16;
  logic [31:0] ref_thermal_sample_count_q;
  logic signed [31:0] ref_coherence_capacity_q16;
  logic signed [31:0] ref_pressure_q16;
  logic signed [31:0] ref_stability_margin_q16;
  logic ref_stable;
  frp_m32_core #(
    .CELLS(CELLS), .REQUEST_LANES(REQUEST_LANES),
    .CELL_INDEX_BITS(CELL_INDEX_BITS), .COUNTER_BITS(COUNTER_BITS)
  ) reference_core (
    .clk(clk), .rst_n(reset_model[1]),
    .tick_enable(ref_tick), .clear_counters(ref_clear), .scheduler_mode(ref_mode),
    .phase_load_valid(ref_load), .phase_load(phases), .frequency_load_q16(frequencies),
    .gamma_effective_word(gamma), .thermal_node_factor_q30(thermal),
    .auto_target_enable(ref_auto), .external_request_valid(valid),
    .external_request_cell_index(cells), .external_request_target(targets),
    .external_target_bank(bank),
    .phase_word_q(ref_phase_word_q),
    .frequency_current_q16(ref_frequency_current_q16),
    .coupling_field_q16(ref_coupling_field_q16),
    .phase_projection_q30(ref_phase_projection_q30),
    .phase_target_source(ref_phase_target_source),
    .registered_target_q(ref_registered_target_q),
    .registered_target_valid_q(ref_registered_target_valid_q),
    .phase_target_domain_valid(ref_phase_target_domain_valid),
    .registered_target_domain_valid(ref_registered_target_domain_valid),
    .target_capture_accepted(ref_target_capture_accepted),
    .target_capture_rejected(ref_target_capture_rejected),
    .accepted_target_capture_events_q(ref_accepted_target_capture_events_q),
    .rejected_target_capture_events_q(ref_rejected_target_capture_events_q),
    .registered_request_enable(ref_registered_request_enable),
    .phase_request_valid(ref_phase_request_valid),
    .phase_request_cell_index(ref_phase_request_cell_index),
    .phase_request_target(ref_phase_request_target),
    .execution_request_valid(ref_execution_request_valid),
    .execution_request_cell_index(ref_execution_request_cell_index),
    .execution_request_target(ref_execution_request_target),
    .execution_target_bank(ref_execution_target_bank),
    .state_out(ref_state_out),
    .pending_route_out(ref_pending_route_out),
    .scheduler_mode_q(ref_scheduler_mode_q),
    .scheduler_state_q(ref_scheduler_state_q),
    .ticks_recorded_q(ref_ticks_recorded_q),
    .scheduler_count_free_q(ref_scheduler_count_free_q),
    .scheduler_count_balance_q(ref_scheduler_count_balance_q),
    .scheduler_count_commit_q(ref_scheduler_count_commit_q),
    .scheduler_count_excite_q(ref_scheduler_count_excite_q),
    .scheduler_count_neutralize_q(ref_scheduler_count_neutralize_q),
    .request_accept(ref_request_accept),
    .request_reject(ref_request_reject),
    .accepted_cell_mask(ref_accepted_cell_mask),
    .neutral_routed_cell_mask(ref_neutral_routed_cell_mask),
    .accepted_change_mask(ref_accepted_change_mask),
    .accepted_changes(ref_accepted_changes),
    .capacity_remaining(ref_capacity_remaining),
    .capacity_exhausted(ref_capacity_exhausted),
    .switch_load_numerator(ref_switch_load_numerator),
    .requested_direct_events(ref_requested_direct_events),
    .prevented_direct_events(ref_prevented_direct_events),
    .neutral_routed_events(ref_neutral_routed_events),
    .actual_direct_events(ref_actual_direct_events),
    .reserved_state_events(ref_reserved_state_events),
    .queue_overflow_events(ref_queue_overflow_events),
    .invariant_flags(ref_invariant_flags),
    .pair_coherence_q30(ref_pair_coherence_q30),
    .cluster_coherence_q30(ref_cluster_coherence_q30),
    .global_coherence_q30(ref_global_coherence_q30),
    .organization_dispersion_q30(ref_organization_dispersion_q30),
    .normalized_cycle_cost_q16(ref_normalized_cycle_cost_q16),
    .temperature_proxy_q16(ref_temperature_proxy_q16),
    .peak_temperature_proxy_q16(ref_peak_temperature_proxy_q16),
    .thermal_sample_count_q(ref_thermal_sample_count_q),
    .coherence_capacity_q16(ref_coherence_capacity_q16),
    .pressure_q16(ref_pressure_q16),
    .stability_margin_q16(ref_stability_margin_q16),
    .stable(ref_stable)
  );

  task automatic check_core;
    if (dut.\u_fpga.phase_word_q !== ref_phase_word_q)
      $fatal(1, "core mismatch: phase_word_q");
    if (dut.\u_fpga.frequency_current_q16 !== ref_frequency_current_q16)
      $fatal(1, "core mismatch: frequency_current_q16");
    if (dut.\u_fpga.coupling_field_q16 !== ref_coupling_field_q16)
      $fatal(1, "core mismatch: coupling_field_q16");
    if (dut.\u_fpga.phase_projection_q30 !== ref_phase_projection_q30)
      $fatal(1, "core mismatch: phase_projection_q30");
    if (dut.\u_fpga.phase_target_source !== ref_phase_target_source)
      $fatal(1, "core mismatch: phase_target_source");
    if (dut.\u_fpga.registered_target_q !== ref_registered_target_q)
      $fatal(1, "core mismatch: registered_target_q");
    if (dut.\u_fpga.registered_target_valid_q !== ref_registered_target_valid_q)
      $fatal(1, "core mismatch: registered_target_valid_q");
    if (dut.\u_fpga.phase_target_domain_valid !== ref_phase_target_domain_valid)
      $fatal(1, "core mismatch: phase_target_domain_valid");
    if (dut.\u_fpga.registered_target_domain_valid !== ref_registered_target_domain_valid)
      $fatal(1, "core mismatch: registered_target_domain_valid");
    if (dut.\u_fpga.target_capture_accepted !== ref_target_capture_accepted)
      $fatal(1, "core mismatch: target_capture_accepted");
    if (dut.\u_fpga.target_capture_rejected !== ref_target_capture_rejected)
      $fatal(1, "core mismatch: target_capture_rejected");
    if (dut.\u_fpga.accepted_target_capture_events_q !== ref_accepted_target_capture_events_q)
      $fatal(1, "core mismatch: accepted_target_capture_events_q");
    if (dut.\u_fpga.rejected_target_capture_events_q !== ref_rejected_target_capture_events_q)
      $fatal(1, "core mismatch: rejected_target_capture_events_q");
    if (dut.\u_fpga.registered_request_enable !== ref_registered_request_enable)
      $fatal(1, "core mismatch: registered_request_enable");
    if (dut.\u_fpga.phase_request_valid !== ref_phase_request_valid)
      $fatal(1, "core mismatch: phase_request_valid");
    if (dut.\u_fpga.phase_request_cell_index !== ref_phase_request_cell_index)
      $fatal(1, "core mismatch: phase_request_cell_index");
    if (dut.\u_fpga.phase_request_target !== ref_phase_request_target)
      $fatal(1, "core mismatch: phase_request_target");
    if (dut.\u_fpga.execution_request_valid !== ref_execution_request_valid)
      $fatal(1, "core mismatch: execution_request_valid");
    if (dut.\u_fpga.execution_request_cell_index !== ref_execution_request_cell_index)
      $fatal(1, "core mismatch: execution_request_cell_index");
    if (dut.\u_fpga.execution_request_target !== ref_execution_request_target)
      $fatal(1, "core mismatch: execution_request_target");
    if (dut.\u_fpga.execution_target_bank !== ref_execution_target_bank)
      $fatal(1, "core mismatch: execution_target_bank");
    if (dut.\u_fpga.state_out !== ref_state_out)
      $fatal(1, "core mismatch: state_out");
    if (dut.\u_fpga.pending_route_out !== ref_pending_route_out)
      $fatal(1, "core mismatch: pending_route_out");
    if (dut.\u_fpga.scheduler_mode_q !== ref_scheduler_mode_q)
      $fatal(1, "core mismatch: scheduler_mode_q");
    if (dut.\u_fpga.scheduler_state_q !== ref_scheduler_state_q)
      $fatal(1, "core mismatch: scheduler_state_q");
    if (dut.\u_fpga.ticks_recorded_q !== ref_ticks_recorded_q)
      $fatal(1, "core mismatch: ticks_recorded_q");
    if (dut.\u_fpga.scheduler_count_free_q !== ref_scheduler_count_free_q)
      $fatal(1, "core mismatch: scheduler_count_free_q");
    if (dut.\u_fpga.scheduler_count_balance_q !== ref_scheduler_count_balance_q)
      $fatal(1, "core mismatch: scheduler_count_balance_q");
    if (dut.\u_fpga.scheduler_count_commit_q !== ref_scheduler_count_commit_q)
      $fatal(1, "core mismatch: scheduler_count_commit_q");
    if (dut.\u_fpga.scheduler_count_excite_q !== ref_scheduler_count_excite_q)
      $fatal(1, "core mismatch: scheduler_count_excite_q");
    if (dut.\u_fpga.scheduler_count_neutralize_q !== ref_scheduler_count_neutralize_q)
      $fatal(1, "core mismatch: scheduler_count_neutralize_q");
    if (dut.\u_fpga.request_accept !== ref_request_accept)
      $fatal(1, "core mismatch: request_accept");
    if (dut.\u_fpga.request_reject !== ref_request_reject)
      $fatal(1, "core mismatch: request_reject");
    if (dut.\u_fpga.accepted_cell_mask !== ref_accepted_cell_mask)
      $fatal(1, "core mismatch: accepted_cell_mask");
    if (dut.\u_fpga.neutral_routed_cell_mask !== ref_neutral_routed_cell_mask)
      $fatal(1, "core mismatch: neutral_routed_cell_mask");
    if (dut.\u_fpga.accepted_change_mask !== ref_accepted_change_mask)
      $fatal(1, "core mismatch: accepted_change_mask");
    if (dut.\u_fpga.accepted_changes !== ref_accepted_changes)
      $fatal(1, "core mismatch: accepted_changes");
    if (dut.\u_fpga.capacity_remaining !== ref_capacity_remaining)
      $fatal(1, "core mismatch: capacity_remaining");
    if (dut.\u_fpga.capacity_exhausted !== ref_capacity_exhausted)
      $fatal(1, "core mismatch: capacity_exhausted");
    if (dut.\u_fpga.switch_load_numerator !== ref_switch_load_numerator)
      $fatal(1, "core mismatch: switch_load_numerator");
    if (dut.\u_fpga.requested_direct_events !== ref_requested_direct_events)
      $fatal(1, "core mismatch: requested_direct_events");
    if (dut.\u_fpga.prevented_direct_events !== ref_prevented_direct_events)
      $fatal(1, "core mismatch: prevented_direct_events");
    if (dut.\u_fpga.neutral_routed_events !== ref_neutral_routed_events)
      $fatal(1, "core mismatch: neutral_routed_events");
    if (dut.\u_fpga.actual_direct_events !== ref_actual_direct_events)
      $fatal(1, "core mismatch: actual_direct_events");
    if (dut.\u_fpga.reserved_state_events !== ref_reserved_state_events)
      $fatal(1, "core mismatch: reserved_state_events");
    if (dut.\u_fpga.queue_overflow_events !== ref_queue_overflow_events)
      $fatal(1, "core mismatch: queue_overflow_events");
    if (dut.\u_fpga.invariant_flags !== ref_invariant_flags)
      $fatal(1, "core mismatch: invariant_flags");
    if (dut.\u_fpga.pair_coherence_q30 !== ref_pair_coherence_q30)
      $fatal(1, "core mismatch: pair_coherence_q30");
    if (dut.\u_fpga.cluster_coherence_q30 !== ref_cluster_coherence_q30)
      $fatal(1, "core mismatch: cluster_coherence_q30");
    if (dut.\u_fpga.global_coherence_q30 !== ref_global_coherence_q30)
      $fatal(1, "core mismatch: global_coherence_q30");
    if (dut.\u_fpga.organization_dispersion_q30 !== ref_organization_dispersion_q30)
      $fatal(1, "core mismatch: organization_dispersion_q30");
    if (dut.\u_fpga.normalized_cycle_cost_q16 !== ref_normalized_cycle_cost_q16)
      $fatal(1, "core mismatch: normalized_cycle_cost_q16");
    if (dut.\u_fpga.temperature_proxy_q16 !== ref_temperature_proxy_q16)
      $fatal(1, "core mismatch: temperature_proxy_q16");
    if (dut.\u_fpga.peak_temperature_proxy_q16 !== ref_peak_temperature_proxy_q16)
      $fatal(1, "core mismatch: peak_temperature_proxy_q16");
    if (dut.\u_fpga.thermal_sample_count_q !== ref_thermal_sample_count_q)
      $fatal(1, "core mismatch: thermal_sample_count_q");
    if (dut.\u_fpga.coherence_capacity_q16 !== ref_coherence_capacity_q16)
      $fatal(1, "core mismatch: coherence_capacity_q16");
    if (dut.\u_fpga.pressure_q16 !== ref_pressure_q16)
      $fatal(1, "core mismatch: pressure_q16");
    if (dut.\u_fpga.stability_margin_q16 !== ref_stability_margin_q16)
      $fatal(1, "core mismatch: stability_margin_q16");
    if (dut.\u_fpga.stable !== ref_stable)
      $fatal(1, "core mismatch: stable");
    checks++;
  endtask

  task automatic save_events;
    saved[8'h2c] = 32'(ref_request_accept);
    saved[8'h30] = 32'(ref_request_reject);
    saved[8'h3c] = 32'(ref_accepted_changes);
    saved[8'h40] = 32'(ref_capacity_remaining);
    saved[8'h44] = 32'(ref_capacity_exhausted);
    saved[8'h48] = 32'(ref_switch_load_numerator);
    saved[8'h4c] = 32'(ref_invariant_flags);
    saved[8'h50] = 32'(ref_requested_direct_events);
    saved[8'h54] = 32'(ref_prevented_direct_events);
    saved[8'h58] = 32'(ref_neutral_routed_events);
    saved[8'h5c] = 32'(ref_actual_direct_events);
    saved[8'h60] = 32'(ref_reserved_state_events);
    saved[8'h64] = 32'(ref_queue_overflow_events);
    saved[8'hc4] = 32'(ref_normalized_cycle_cost_q16);
    saved[8'he4] = 32'(ref_accepted_cell_mask);
    saved[8'he8] = 32'(ref_neutral_routed_cell_mask);
    saved[8'hec] = 32'(ref_accepted_change_mask);
    saved[8'hf0] = 32'({ref_phase_request_target, ref_phase_request_cell_index, ref_phase_request_valid});
    saved[8'hf4] = 32'({ref_execution_request_target, ref_execution_request_cell_index, ref_execution_request_valid});
    saved[8'hf8] = 32'(ref_execution_target_bank);
    saved[8'h94] = 32'({ref_target_capture_rejected, ref_target_capture_accepted});
  endtask

  task automatic clear_events;
    for (int i = 0; i<256; i++) saved[i] = 0;
    saved['h4c] = 32'h3ff;
  endtask

  task automatic transfer(input bit wr, input logic [7:0] addr,
                          input logic [31:0] data, input bit expect_error = 0);
    @(negedge clk);
    csr_valid = 1; csr_write = wr; csr_addr = addr; csr_wdata = data;
    ref_tick = wr && !expect_error && addr == 0 && data == 1;
    ref_clear = wr && !expect_error && addr == 0 && data == 2;
    ref_load = wr && !expect_error && addr == 0 && data == 8;
    #1;
    if (!csr_ready || csr_error !== expect_error)
      $fatal(1,"transfer wr=%0d addr=%h data=%h expected_error=%0d ready=%0d error=%0d",
             wr, addr, data, expect_error, csr_ready, csr_error);
    if ((wr || expect_error) && csr_rdata !== 0) $fatal(1,"nonzero unused read data");
    sampled = csr_rdata;
    if (ref_tick) save_events();
    @(posedge clk); #1;
    if (wr && !expect_error) begin
      case (addr)
        'h00: begin
          if (data == 1) begin valid = 0; ticks++; end
          if (data == 2) clear_events();
          if (data == 4) valid = 0;
        end
        'h04: ref_mode = frp_m31_scheduler_mode_e'(data[1:0]);
        'h08: lane = int'(data);
        'h0c: cells[lane*3 +: 3] = data[2:0];
        'h10: targets[lane*2 +: 2] = data[1:0];
        'h14: valid[lane] = data[0];
        'h18: cell_index = int'(data);
        'h68: ref_auto = data[0];
        'h6c: phases[cell_index*32 +: 32] = data;
        'h70: frequencies[cell_index*32 +: 32] = data;
        'h74: gamma[cell_index*32 +: 32] = data;
        'h78: thermal[cell_index*32 +: 32] = data;
        default: $fatal(1,"unexpected successful write");
      endcase
    end
    if (expect_error) errors++;
    #1;
    @(negedge clk);
    csr_valid = 0; ref_tick = 0; ref_clear = 0; ref_load = 0;
    #1;
    if (csr_ready || csr_error || csr_rdata !== 0) $fatal(1,"idle response not zero");

  endtask

  task automatic wr(input logic [7:0] a, input logic [31:0] d);
    transfer(1, a, d);
  endtask

  task automatic expect_read(input logic [7:0] a, input logic [31:0] d);
    transfer(0, a, 0);
    if (sampled !== d) $fatal(1,"read addr=%h actual=%h expected=%h", a, sampled, d);
    checks++;
  endtask

  task automatic inspect;
    expect_read(8'h20, 32'(ref_scheduler_mode_q));
    expect_read(8'h24, 32'(ref_scheduler_state_q));
    expect_read(8'h28, 32'(ref_ticks_recorded_q));
    expect_read(8'h98, 32'(ref_accepted_target_capture_events_q));
    expect_read(8'h9c, 32'(ref_rejected_target_capture_events_q));
    expect_read(8'ha0, 32'(ref_scheduler_count_free_q));
    expect_read(8'ha4, 32'(ref_scheduler_count_balance_q));
    expect_read(8'ha8, 32'(ref_scheduler_count_commit_q));
    expect_read(8'hac, 32'(ref_scheduler_count_excite_q));
    expect_read(8'hb0, 32'(ref_scheduler_count_neutralize_q));
    expect_read(8'hb4, 32'(ref_pair_coherence_q30));
    expect_read(8'hb8, 32'(ref_cluster_coherence_q30));
    expect_read(8'hbc, 32'(ref_global_coherence_q30));
    expect_read(8'hc0, 32'(ref_organization_dispersion_q30));
    expect_read(8'hc8, 32'(ref_temperature_proxy_q16));
    expect_read(8'hcc, 32'(ref_peak_temperature_proxy_q16));
    expect_read(8'hd0, 32'(ref_thermal_sample_count_q));
    expect_read(8'hd4, 32'(ref_coherence_capacity_q16));
    expect_read(8'hd8, 32'(ref_pressure_q16));
    expect_read(8'hdc, 32'(ref_stability_margin_q16));
    expect_read(8'he0, 32'(ref_stable));
    expect_read(8'h2c, saved[8'h2c]);
    expect_read(8'h30, saved[8'h30]);
    expect_read(8'h3c, saved[8'h3c]);
    expect_read(8'h40, saved[8'h40]);
    expect_read(8'h44, saved[8'h44]);
    expect_read(8'h48, saved[8'h48]);
    expect_read(8'h4c, saved[8'h4c]);
    expect_read(8'h50, saved[8'h50]);
    expect_read(8'h54, saved[8'h54]);
    expect_read(8'h58, saved[8'h58]);
    expect_read(8'h5c, saved[8'h5c]);
    expect_read(8'h60, saved[8'h60]);
    expect_read(8'h64, saved[8'h64]);
    expect_read(8'hc4, saved[8'hc4]);
    expect_read(8'he4, saved[8'he4]);
    expect_read(8'he8, saved[8'he8]);
    expect_read(8'hec, saved[8'hec]);
    expect_read(8'hf0, saved[8'hf0]);
    expect_read(8'hf4, saved[8'hf4]);
    expect_read(8'hf8, saved[8'hf8]);
    expect_read('h94, {26'd0, saved['h94][1:0], ref_registered_request_enable,
      ref_registered_target_domain_valid, ref_phase_target_domain_valid,
      ref_registered_target_valid_q});
    for (int i = 0; i<8; i++) begin
      wr('h18, 32'(i));
      expect_read('h34, {30'd0, ref_state_out[i*2 +: 2]});
      expect_read('h38, {30'd0, ref_pending_route_out[i*2 +: 2]});
      expect_read('h6c, phases[i*32 +: 32]);
      expect_read('h70, frequencies[i*32 +: 32]);
      expect_read('h74, gamma[i*32 +: 32]);
      expect_read('h78, thermal[i*32 +: 32]);
      expect_read('h7c, ref_phase_word_q[i*32 +: 32]);
      expect_read('h80, ref_frequency_current_q16[i*32 +: 32]);
      expect_read('h84, ref_coupling_field_q16[i*32 +: 32]);
      expect_read('h88, ref_phase_projection_q30[i*32 +: 32]);
      expect_read('h8c, {30'd0, ref_phase_target_source[i*2 +: 2]});
      expect_read('h90, {30'd0, ref_registered_target_q[i*2 +: 2]});
    end
  endtask

  task automatic reset_all;
    @(negedge clk); rst_n_async = 0; csr_valid = 1; csr_write = 1; csr_addr = 0; csr_wdata = 1;
    ref_tick = 0; ref_clear = 0; ref_load = 0; ref_mode = FRP_MODE_FREE; ref_auto = 0;
    phases = 0; frequencies = 0; gamma = 0; thermal = {8{32'h40000000}};
    cells = 0; targets = 0; valid = 0; lane = 0; cell_index = 0; clear_events();
    #1;
    if (csr_ready || csr_error || csr_rdata !== 0) $fatal(1,"reset response");
    @(posedge clk); #1;
    @(negedge clk); rst_n_async = 1;
    @(posedge clk); #1;
    if (csr_ready) $fatal(1,"early reset release");
    // Drop an unacknowledged tick before readiness. It must never execute.
    @(negedge clk); csr_valid = 0;
    @(posedge clk); #1;

    expect_read('h28, 0); expect_read('hfc, 32'h46523201);
    expect_read('h1c, 1); expect_read('h4c, 32'h3ff);
  endtask

  task automatic stage(input int l, input int c, input logic [31:0] t);
    wr('h08, 32'(l)); wr('h0c, 32'(c)); wr('h10, t); wr('h14, 1);
  endtask

  event inspect_request, inspect_complete;
  always @(posedge clk) begin #3; check_core(); end

  initial forever begin
    @inspect_request;
    inspect();
    ->inspect_complete;
  end

  initial begin
    clear_events();
    reset_all();
    ->inspect_request;
    @inspect_complete;
    // Every unaligned address must complete with an error and no side effect.
    for (int a = 0; a<256; a++) if ((a%4)!=0) begin
      transfer(1, 8'(a), 32'hffffffff, 1);
      transfer(0, 8'(a), 0, 1);
    end
    // Read-only words reject writes; CONTROL rejects reads and mixed commands.
    for (int a = 'h1c; a<256; a+=4)
      if (a<'h68 || a>'h78) transfer(1, 8'(a), 32'hdeadbeef, 1);
    transfer(0, 0, 0, 1);
    transfer(1, 0, 0, 1); transfer(1, 0, 3, 1); transfer(1, 0, 16, 1);
    transfer(1, 'h04, 3, 1); transfer(1, 'h04, 32'h80000001, 1);
    transfer(1, 'h08, 2, 1); transfer(1, 'h0c, 8, 1); transfer(1, 'h18, 8, 1);
    transfer(1, 'h10, 2, 1); transfer(1, 'h10, 32'hffffffff, 1);
    transfer(1, 'h14, 2, 1); transfer(1, 'h68, 2, 1);
    expect_read('h28, 0); expect_read('h04, 0); expect_read('h08, 0);
    // One-shot external requests and both opposite routes with paused ticks.
    stage(0, 0, 1); wr(0, 1);
    wr('h18, 0); expect_read('h34, 1); expect_read('h14, 0);
    expect_read('h2c, 1); expect_read('h5c, 0);
    stage(0, 0, 3); wr(0, 1);
    expect_read('h34, 0); expect_read('h38, 3);
    expect_read('h54, 1); expect_read('h5c, 0); expect_read('h58, 1);
    ->inspect_request;
    @inspect_complete;
    wr('h18, 0); wr(0, 2); expect_read('h34, 0); expect_read('h38, 3); expect_read('h28, 0);
    wr(0, 1); expect_read('h34, 3); expect_read('h38, 0);
    stage(0, 0, 1); wr(0, 1);
    expect_read('h34, 0); expect_read('h38, 1);
    repeat (4) expect_read('h34, 0);
    wr(0, 1); expect_read('h34, 1); expect_read('h38, 0);
    expect_read('h5c, 0); expect_read('h60, 0); expect_read('h64, 0);
    // Clear requests cannot cause a tick. Both lanes are independently staged.
    stage(0, 3, 1); stage(1, 7, 3); wr(0, 4);
    expect_read('h14, 0); wr('h08, 0); expect_read('h14, 0);
    stage(0, 3, 1); stage(1, 7, 3); wr(0, 1);
    expect_read('h2c, 3); expect_read('h30, 0);
    wr('h18, 3); expect_read('h34, 1); wr('h18, 7); expect_read('h34, 3);
    ->inspect_request;
    @inspect_complete;
    // A duplicate second lane is rejected by the core without direct execution.
    stage(0, 1, 1); stage(1, 1, 3); wr(0, 1);
    expect_read('h2c, 1); expect_read('h30, 2); expect_read('h5c, 0);
    // Atomic load uses all cells, including signed frequencies and wraparound.
    before_staging_phase = ref_phase_word_q;
    before_staging_frequency = ref_frequency_current_q16;
    for (int i = 0; i<8; i++) begin
      phase_pattern[i] = 32'h12345678+32'(i)*32'h20000000;
      frequency_pattern[i] = (i%2 == 0)?32'h00010000:32'hffff0000;
      wr('h18, 32'(i)); wr('h6c, phase_pattern[i]); wr('h70, frequency_pattern[i]);
    end
    for (int i = 0; i<8; i++) begin
      wr('h18, 32'(i)); expect_read('h7c, before_staging_phase[i*32 +: 32]);
      expect_read('h80, before_staging_frequency[i*32 +: 32]);
    end
    wr(0, 8);
    for (int i = 0; i<8; i++) begin
      wr('h18, 32'(i)); expect_read('h7c, phase_pattern[i]);
      expect_read('h80, frequency_pattern[i]);
    end
    ->inspect_request;
    @inspect_complete;
    wr('h68, 1); wr(0, 1);
    ->inspect_request;
    @inspect_complete;
    wr(0, 1);
    ->inspect_request;
    @inspect_complete;
    // Distinct gamma/factor words check every configuration slice and passthrough.
    for (int i = 0; i<8; i++) begin
      wr('h18, 32'(i)); wr('h74, 32'(i)*32'h00004000);
      wr('h78, 32'h40000000-32'(i)*32'h00100000);
    end
    wr(0, 1);
    ->inspect_request;
    @inspect_complete;
    // Here the mode is configured during idle clocks before the first tick.
    for (int m = 0; m<3; m++) begin
      reset_all(); wr('h04, 32'(m)); wr('h68, 1);
      for (int t = 0; t<97; t++) wr(0, 1);
      expect_read('h28, 97); expect_read('h98, 97);
      expect_read('hA0, (m == 0)?97:0);
      expect_read('hA4, (m == 1)?85:0); expect_read('hA8, (m == 1)?12:0);
      expect_read('hAC, (m == 2)?13:0); expect_read('hB0, (m == 2)?84:0);
      expect_read('h5c, 0); expect_read('h60, 0); expect_read('h64, 0);
      ->inspect_request;
      @inspect_complete;
    end
    // With no idle clock, the tick immediately after a mode write uses the
    // previous scheduler state, as specified by the underlying M31 scheduler.
    reset_all();
    @(negedge clk); csr_valid = 1; csr_write = 1; csr_addr = 'h04; csr_wdata = 1;
    @(posedge clk); #1; ref_mode = FRP_MODE_7_1;
    @(negedge clk); csr_addr = 0; csr_wdata = 1; ref_tick = 1;
    #1; save_events();
    @(posedge clk); #1; ticks++;
    @(negedge clk); csr_valid = 0; ref_tick = 0;
    expect_read('h28, 1); expect_read('hA0, 1); expect_read('hA4, 0);
    wr(0, 1); expect_read('h28, 2); expect_read('hA0, 1); expect_read('hA4, 1);
    // Consecutive ready edges are consecutive transfers, not an implicit pulse stretcher.
    reset_all();
    @(negedge clk); csr_valid = 1; csr_write = 1; csr_addr = 0; csr_wdata = 1; ref_tick = 1;
    repeat (3) begin
      #1; save_events(); @(posedge clk); #1;  ticks++;
      @(negedge clk);
    end
    csr_valid = 0; ref_tick = 0;
    expect_read('h28, 3); expect_read('h98, 3);
    // Asynchronous reset also cancels staged state and previously captured results.
    stage(1, 7, 3); wr('h68, 1); reset_all();
    ->inspect_request;
    @inspect_complete;
    $display("FRP_M32_CSR_POST_SYNTHESIS_TB: PASS checks=%0d ticks=%0d rejected_transfers=%0d core_outputs=59", checks, ticks, errors);
    $finish;
  end

  initial begin #2000000; $fatal(1,"timeout"); end
endmodule : frp_m32_csr_post_synthesis_tb

`endif

`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_cdc_stream_top.sv"

module frp_m32_release_branch_tb #(parameter int CELLS = 64);
  bit host_clk, core_clk, rst_n, request, sample;
  logic ready, response;
  logic signed [31:0] margin;
  int unsigned address;
  always #5 host_clk = !host_clk;
  always #3 core_clk = !core_clk;

  frp_m32_internal_gamma_observed_csr_cdc_stream_top #(.CELLS(CELLS)) dut (
    .host_clk(host_clk), .core_clk(core_clk), .rst_n_async(rst_n),
    .req_valid(request), .req_ready(ready), .req_write(1'b0),
    .req_addr(9'h0fc), .req_wdata('0), .rsp_ready(1'b1), .rsp_valid(response)
  );
  frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(2)) rec (
    .clk(core_clk), .rst_n(rst_n), .clear_epoch(1'b0), .sample_valid(sample),
    .source_tick(64'd37), .scheduler_mode('0), .scheduler_state('0),
    .coherence_capacity_q16('0), .pressure_q16('0), .stability_margin_q16(margin),
    .mean_heat_q16('0), .switch_load_q16('0), .retained_state('0), .pending_route('0)
  );

  `define OBS dut.u_cdc.u_csr.u_core.u_core.u_observed_core
  `define PHASE `OBS.u_core.u_phase_interference
  `define THERMAL `OBS.u_core.u_local_thermal_field
  `define STABILITY `OBS.u_core.u_local_global_stability

  initial begin
    repeat (4) @(negedge host_clk);
    rst_n = 1;
    wait (ready);
    @(negedge core_clk);
    margin = 10;
    sample = 1;
    repeat (3) @(negedge core_clk);
    if (rec.sample_count_q !== 3 || rec.count_overflow_q || rec.boundary_valid_q)
      $fatal(1, "recorder before crossing");
    margin = 0;
    @(negedge core_clk);
    if (rec.sample_count_q !== 3 || !rec.count_overflow_q || !rec.boundary_pulse_q ||
        rec.boundary_tick_q !== 37 || rec.boundary_previous_margin_q16 !== 10)
      $fatal(1, "crossing at saturation");
    sample = 0;

    for (address = 0; address < CELLS; address++) begin
      if (`PHASE.phase_weight_q30(address, address) !== 0 ||
          `THERMAL.thermal_weight_q30(address, address) !== 0)
        $fatal(1, "self weight at %0d", address);
      if (`PHASE.phase_weight_q30(address, address ^ 1) <= 0 ||
          `THERMAL.thermal_weight_q30(address, address ^ 1) <= 0)
        $fatal(1, "neighbor weight at %0d", address);
    end

    // Inject a negative compression argument and an above-unity magnitude.
    force `STABILITY.compression_arg_q16 = -32'sd1;
    force `PHASE.g_coherence[0].magnitude.radicand = 64'h4000000000000000;
    #1;
    if (`STABILITY.rom_address !== 0 || `PHASE.group_coherence_q30[31:0] !== 32'h40000000)
      $fatal(1, "numerical clamps");
    release `STABILITY.compression_arg_q16;
    release `PHASE.g_coherence[0].magnitude.radicand;

    // Delay one valid indication and check the sticky monitor output.
    @(negedge core_clk);
    if (`OBS.record_alignment_error_q) $fatal(1, "alignment before injection");
    force `OBS.local_stability_valid_q = 1'b1;
    @(negedge core_clk);
    release `OBS.local_stability_valid_q;
    @(negedge core_clk);
    if (!`OBS.record_alignment_error_q || `OBS.record_sample_valid)
      $fatal(1, "alignment fault capture");

    // Suppress the bridge issue pulse after accepting a host request.
    @(negedge host_clk);
    request = 1;
    @(negedge host_clk);
    request = 0;
    force dut.bridge_valid = 1'b0;
    repeat (2) @(negedge host_clk);
    if (dut.state_q !== 2'd1 || dut.bridge_valid || response)
      $fatal(1, "stalled ISSUE");
    release dut.bridge_valid;
    wait (response);
    if (dut.rsp_error || dut.rsp_rdata !== 32'h46524701) $fatal(1, "read after stall");
    $display("PASS RELEASE_BRANCH cells=%0d", CELLS);
    $finish;
  end

  initial #20000 $fatal(1, "timeout ready=%b state=%d busy=%b valid=%b done=%b",
                        ready, dut.state_q, dut.bridge_busy, dut.bridge_valid, dut.bridge_done);
  `undef OBS
  `undef PHASE
  `undef THERMAL
  `undef STABILITY
endmodule

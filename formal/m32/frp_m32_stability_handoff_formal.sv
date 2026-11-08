// SPDX-License-Identifier: Apache-2.0
// M32 producer, observer and recorder share the real tick, valid and reset paths.
`include "frp_m32_observed_core.sv"

module frp_m32_stability_handoff_formal #(
    parameter int CELLS = 64,
    parameter int COUNT_BITS = 64
) (
    input logic clk, rst_n, tick_enable, phase_load_valid, clear_counters,
    output logic [5:0] reach
);
    frp_m32_observed_core #(.CELLS(CELLS), .RECORDER_COUNT_BITS(COUNT_BITS)) dut (
        .clk, .rst_n, .tick_enable, .phase_load_valid, .clear_counters,
        .scheduler_mode(frp_m31_pkg::FRP_MODE_FREE), .phase_load('0),
        .frequency_load_q16('0), .gamma_effective_word('0), .thermal_node_factor_q30('0),
        .auto_target_enable(1'b0), .external_request_valid('0),
        .external_request_cell_index('0), .external_request_target('0), .external_target_bank('0)
    );

    logic started = 0;
    always_ff @(posedge clk) started <= 1;
    always_comb if (!started) assume (!rst_n);

    logic [1:0] due;
    logic [31:0] completed, switch_at_issue;
    logic [COUNT_BITS-1:0] recorded;
    logic signed [31:0] last_margin;
    logic [255:0] result;
    wire [255:0] commit_data = {
        dut.global_coherence_q30, dut.cluster_coherence_q30,
        dut.u_core.stability_mean_heat_d, dut.u_core.stability_mean_overload_d,
        dut.u_core.stability_mean_lag_d, dut.u_core.stability_neutral_fraction_d,
        dut.u_core.stability_compression_arg_d, switch_at_issue
    };
    wire [255:0] registered_data = {
        dut.local_stability_raw_coherence_q30, dut.local_stability_cluster_coherence_q30,
        dut.local_stability_mean_heat_q16, dut.local_stability_mean_overload_q16,
        dut.local_stability_mean_lag_q16, dut.local_stability_neutral_fraction_q30,
        dut.local_stability_compression_arg_q16, dut.local_stability_switch_load_q16
    };

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            due <= 0;
            completed <= 0;
            switch_at_issue <= 0;
            recorded <= 0;
            last_margin <= 32'sd39322;
            result <= {64'd0, 32'd3277, 64'd0, 32'd1073741824, 64'd0};
        end else begin
            due <= {due[0], tick_enable};
            if (tick_enable) switch_at_issue <= dut.normalized_cycle_cost_q16;
            if (due[0]) begin
                completed <= completed + 32'd1;
                result <= commit_data;
            end
            if (due[1]) begin
                if (!(&recorded)) recorded <= recorded + 1'b1;
                last_margin <= dut.local_stability_margin_q16;
            end
        end
    end

    always_comb if (started) begin
        a_pending: assert (dut.u_core.local_stability_pending_q == due[0]);
        a_result_valid: assert (dut.local_stability_valid_q == due[1]);
        a_due: assert ({dut.result_pending_q, dut.tick_pending_q} == due);
        a_aligned: assert (!dut.record_alignment_error_q);
        a_accept: assert (dut.u_recorder.sample_valid == due[1]);
        a_completed: assert (dut.local_stability_sample_count_q == completed);
        a_switch: assert (dut.u_core.local_stability_switch_snapshot_q16 == switch_at_issue);
        a_payload: assert (registered_data == result);
        a_recorder_inputs: assert ({dut.u_recorder.mean_heat_q16, dut.u_recorder.switch_load_q16}
                                   == {result[191:160], result[31:0]});
        a_recorded: assert (dut.record_sample_count_q == recorded);
        a_margin: assert (dut.record_previous_margin_q16 == last_margin);
    end

    // Track a reset immediately following two issued ticks still in flight.
    logic issued_pair = 0, flushed_pair = 0;
    always_ff @(posedge clk) begin
        issued_pair <= rst_n && tick_enable && due[0];
        if (!rst_n) flushed_pair <= issued_pair;
    end

    always_comb begin
        reach = 0;
        if (started && rst_n) begin
            reach[0] = due == 2'b11 && tick_enable && result[31:0] != switch_at_issue;
            reach[1] = due == 2'b10 && !tick_enable && clear_counters && phase_load_valid;
            reach[2] = due == 0 && !tick_enable && phase_load_valid && recorded != 0;
            reach[3] = flushed_pair && recorded == 1 && completed == 1 && due == 0;
            reach[4] = dut.boundary_pulse_q && dut.boundary_tick_q != 0 && !tick_enable;
            reach[5] = dut.record_count_overflow_q && (&recorded) && due[1];
        end
    end
endmodule

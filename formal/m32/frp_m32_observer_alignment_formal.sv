// SPDX-License-Identifier: Apache-2.0
// Cut only frp_m32_core outputs. Keep the observer pipeline and recorder as RTL.
`include "frp_m32_observed_core.sv"

module frp_m32_observer_alignment_formal #(
    parameter int CELLS = 64,
    parameter int COUNT_BITS = 64
) (
    input logic clk, rst_n, tick_enable, clear_counters,
    output logic [5:0] reach
);
    frp_m32_observed_core #(.CELLS(CELLS), .RECORDER_COUNT_BITS(COUNT_BITS)) dut (
        .clk, .rst_n, .tick_enable, .clear_counters,
        .scheduler_mode(frp_m31_pkg::FRP_MODE_FREE), .phase_load_valid(1'b0),
        .phase_load('0), .frequency_load_q16('0), .gamma_effective_word('0),
        .thermal_node_factor_q30('0), .auto_target_enable(1'b0),
        .external_request_valid('0), .external_request_cell_index('0),
        .external_request_target('0), .external_target_bank('0)
    );

    logic started = 0;
    always_ff @(posedge clk) started <= 1;
    always_comb if (!started) assume (!rst_n);

    logic [1:0] due;
    logic [63:0] issued, issue_tag, result_tag;
    logic [4:0] issue_sched, result_sched;
    logic [2*CELLS-1:0] retained, pending;
    logic fault, seen;
    logic [COUNT_BITS-1:0] count;
    logic signed [31:0] last_margin;

    wire valid = dut.local_stability_valid_q;
    wire accept = due[1] && valid && !fault;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            due <= 0;
            issued <= 0;
            issue_tag <= 0;
            result_tag <= 0;
            issue_sched <= 0;
            result_sched <= 0;
            retained <= 0;
            pending <= 0;
            fault <= 0;
            seen <= 0;
            count <= 0;
            last_margin <= 32'sd39322;
        end else begin
            due <= {due[0], tick_enable};
            if (tick_enable) begin
                issue_tag <= issued;
                issued <= issued + 64'd1;
                issue_sched <= {dut.scheduler_mode_q, dut.scheduler_state_q};
            end
            if (due[0]) begin
                result_tag <= issue_tag;
                result_sched <= issue_sched;
                retained <= dut.state_out;
                pending <= dut.pending_route_out;
            end
            if (due[1] != valid) fault <= 1;
            if (accept) begin
                seen <= 1;
                if (!(&count)) count <= count + 1'b1;
                last_margin <= dut.local_stability_margin_q16;
            end
        end
    end

    // Retain all diagnostic fields across a rejected sample, including the first mismatch.
    localparam int DIAG_BITS = 2 + 3*64 + 5 + 8*32 + 4*CELLS;
    wire [DIAG_BITS-1:0] diagnostic = {
        dut.record_count_overflow_q, dut.boundary_valid_q,
        dut.record_minimum_margin_tick_q, dut.record_peak_switch_load_tick_q, dut.boundary_tick_q,
        dut.boundary_scheduler_mode_q, dut.boundary_scheduler_state_q,
        dut.record_minimum_margin_q16, dut.record_peak_switch_load_q16,
        dut.boundary_previous_margin_q16, dut.boundary_margin_q16, dut.boundary_capacity_q16,
        dut.boundary_pressure_q16, dut.boundary_mean_heat_q16, dut.boundary_switch_load_q16,
        dut.boundary_retained_state_q, dut.boundary_pending_route_q
    };
    logic held;
    logic [DIAG_BITS-1:0] saved;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            held <= 0;
            saved <= '0;
        end else begin
            held <= !accept;
            saved <= diagnostic;
        end
    end

    always_comb if (started) begin
        if (held) a_hold: assert (diagnostic == saved && !dut.boundary_pulse_q);
        a_due: assert ({dut.result_pending_q, dut.tick_pending_q} == due);
        a_tag_counter: assert (dut.next_tick_q == issued);
        a_issue: assert ({dut.tick_tag_q, dut.tick_mode_q, dut.tick_state_q}
                         == {issue_tag, issue_sched});
        a_recorder_tag: assert (dut.u_recorder.source_tick == result_tag);
        a_recorder_scheduler: assert ({dut.u_recorder.scheduler_mode,
                                       dut.u_recorder.scheduler_state} == result_sched);
        a_recorder_banks: assert ({dut.u_recorder.retained_state, dut.u_recorder.pending_route}
                                  == {retained, pending});
        a_fault: assert (dut.record_alignment_error_q == fault);
        a_accept: assert (dut.u_recorder.sample_valid == accept);
        a_epoch: assert (!dut.u_recorder.clear_epoch);
        a_history: assert ({dut.record_sample_seen_q, dut.record_sample_count_q,
                            dut.record_previous_margin_q16} == {seen, count, last_margin});
    end

    // Remember a sampled fault across reset for the restart witness.
    logic ever_fault = 0;
    always_ff @(posedge clk)
        if (started && rst_n && fault) ever_fault <= 1;

    localparam int LAST = 2*(CELLS-1);
    always_comb begin
        reach = '0;
        if (started && rst_n) begin
            reach[0] = seen && !fault && due[1] && !valid;
            reach[1] = seen && !fault && !due[1] && valid;
            reach[2] = fault && seen && due[1] && valid && clear_counters && !dut.u_recorder.sample_valid;
            reach[3] = ever_fault && !fault && seen && count == 1 && dut.record_sample_count_q == 1;
            reach[4] = accept && pending[LAST+:2] == 2'b11 && retained[LAST+:2] == 2'b00
                       && dut.pending_route_out[LAST+:2] == 2'b00;
            reach[5] = accept && (&due) && !tick_enable && clear_counters;
        end
    end
endmodule

// SPDX-License-Identifier: Apache-2.0
// Sampled-edge contract for epoch counting and the first margin crossing.
`include "frp_m32_boundary_recorder.sv"

module frp_m32_recorder_saturation_formal #(
    parameter int CELLS = 64,
    parameter int COUNT_BITS = 64
) (
    input logic clk, rst_n, clear_epoch, sample_valid,
    input logic [63:0] source_tick,
    input logic [1:0] scheduler_mode,
    input logic [2:0] scheduler_state,
    input logic signed [31:0] coherence_capacity_q16, pressure_q16,
    input logic signed [31:0] stability_margin_q16, mean_heat_q16, switch_load_q16,
    input logic [2*CELLS-1:0] retained_state, pending_route,
    output logic [7:0] reach
);
    typedef struct packed {
        logic [63:0] tick;
        logic [1:0] mode;
        logic [2:0] phase;
        logic signed [31:0] previous_margin, margin, capacity, pressure, heat, load;
        logic [2*CELLS-1:0] retained, pending;
    } frame_t;

    wire [COUNT_BITS-1:0] count_q;
    wire overflow_q, seen_q, valid_q, pulse_q;
    wire signed [31:0] previous_q;
    wire frame_t frame_q;

    frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(COUNT_BITS)) dut (
        .clk, .rst_n, .clear_epoch, .sample_valid, .source_tick,
        .scheduler_mode, .scheduler_state, .coherence_capacity_q16, .pressure_q16,
        .stability_margin_q16, .mean_heat_q16, .switch_load_q16, .retained_state,
        .pending_route, .sample_count_q(count_q), .count_overflow_q(overflow_q),
        .sample_seen_q(seen_q), .previous_margin_q16(previous_q),
        .boundary_valid_q(valid_q), .boundary_pulse_q(pulse_q),
        .boundary_tick_q(frame_q.tick), .boundary_scheduler_mode_q(frame_q.mode),
        .boundary_scheduler_state_q(frame_q.phase),
        .boundary_previous_margin_q16(frame_q.previous_margin),
        .boundary_margin_q16(frame_q.margin), .boundary_capacity_q16(frame_q.capacity),
        .boundary_pressure_q16(frame_q.pressure), .boundary_mean_heat_q16(frame_q.heat),
        .boundary_switch_load_q16(frame_q.load), .boundary_retained_state_q(frame_q.retained),
        .boundary_pending_route_q(frame_q.pending)
    );

    logic sampled = 0;
    always @(posedge clk) sampled <= 1;
    always_comb if (!sampled) a_initial_reset: assume (!rst_n);

    logic [COUNT_BITS-1:0] ref_count;
    logic ref_overflow, ref_seen, ref_valid, ref_pulse;
    logic signed [31:0] ref_previous;
    frame_t ref_frame;
    wire [COUNT_BITS:0] sum = {1'b0, ref_count} + {{COUNT_BITS{1'b0}}, sample_valid};
    wire carry = sum[COUNT_BITS];
    wire crossing = ref_previous > 0 && stability_margin_q16 <= 0;
    wire capture = sample_valid && crossing && !ref_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ref_count <= '0;
            ref_overflow <= 0;
            ref_seen <= 0;
            ref_previous <= 32'sd39322;
            ref_valid <= 0;
            ref_pulse <= 0;
            ref_frame <= '0;
        end else if (clear_epoch) begin
            ref_count <= '0;
            ref_overflow <= 0;
            ref_seen <= 0;
            ref_previous <= 32'sd39322;
            ref_valid <= 0;
            ref_pulse <= 0;
            ref_frame <= '0;
        end else begin
            ref_count <= carry ? '1 : sum[COUNT_BITS-1:0];
            ref_overflow <= ref_overflow || carry;
            ref_seen <= ref_seen || sample_valid;
            if (sample_valid) ref_previous <= stability_margin_q16;
            ref_valid <= ref_valid || capture;
            ref_pulse <= capture;
            if (capture)
                ref_frame <= {source_tick, scheduler_mode, scheduler_state, ref_previous,
                    stability_margin_q16, coherence_capacity_q16, pressure_q16,
                    mean_heat_q16, switch_load_q16, retained_state, pending_route};
        end
    end

    always_comb begin
        a_profile: assert ((CELLS inside {8,9,16,32,64}) && COUNT_BITS >= 1 && COUNT_BITS <= 64);
        if (sampled) begin
            a_count: assert (count_q == ref_count);
            a_overflow: assert (overflow_q == ref_overflow);
            a_overflow_at_limit: assert (!overflow_q || (&count_q));
            a_seen: assert (seen_q == ref_seen);
            a_previous: assert (previous_q == ref_previous);
            a_valid: assert (valid_q == ref_valid);
            a_pulse: assert (pulse_q == ref_pulse);
            a_frame: assert (frame_q == ref_frame);
        end
    end

    // Pre-edge events. Small counters allow short reset-origin witnesses.
    always_comb begin
        reach = '0;
        if (sampled && rst_n) begin
            reach[0] = !clear_epoch && sample_valid && !(&count_q) && (&sum[COUNT_BITS-1:0]);
            reach[1] = !clear_epoch && !sample_valid && (&count_q) && !overflow_q;
            reach[2] = !clear_epoch && capture && carry && !overflow_q;
            reach[3] = !clear_epoch && capture && overflow_q;
            reach[4] = clear_epoch && sample_valid && overflow_q;
            reach[5] = !clear_epoch && valid_q && crossing && sample_valid;
            reach[6] = !clear_epoch && !seen_q && capture && stability_margin_q16 == 0;
            reach[7] = !clear_epoch && !sample_valid && pulse_q;
        end
    end
endmodule

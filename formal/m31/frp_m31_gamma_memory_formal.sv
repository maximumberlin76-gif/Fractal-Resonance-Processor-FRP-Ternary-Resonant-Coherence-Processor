// Copyright (c) 2026 Maksym Marnov. All rights reserved.
// Proprietary. No license is granted by this file.
// Target retention and correlated-noise memory in local gamma drift.
// Qualify CELLS=8/16/32/64 and every PROBE_CELL in each configuration.
// The observed cone contains the target and noise registers and their logic.
// Other gamma outputs may be removed by ordinary unused-cone optimization.
// Keep the observed cone intact, with the original full-width input buses.
// Only initial sampled reset is assumed; later inputs are unrestricted.
// A valid target is captured only on an enabled tick and affects that tick.
// Without a valid update, correlation continues toward the retained target.
// The independent oracle uses floor/remainder rounding, nearest with ties
// away from zero, and the exact Q16 coefficient 9830/65536.
// Progress is measured against the target selected for that update.
// Errors of at most three Q16 integer units produce a zero correction.
// Formal time is sampled rising edges after async2sync.

`ifndef FRP_M31_GAMMA_MEMORY_FORMAL_SV
`define FRP_M31_GAMMA_MEMORY_FORMAL_SV
`include "frp_m31_local_gamma_drift.sv"

module frp_m31_gamma_memory_formal #(
    parameter int CELLS = 8,
    parameter int PROBE_CELL = 0
) (
    input logic clk, rst_n, tick_enable, gamma_update_valid,
    input logic [32*CELLS-1:0] gamma_targets_q16,
    input logic [32*CELLS-1:0] thermal_overload_q16,
    output wire signed [31:0] target_now,
    output wire signed [31:0] noise_now,
    output wire signed [31:0] selected_target,
    output wire signed [31:0] expected_noise_next,
    output logic [15:0] reach
);
    typedef logic signed [63:0] wide_t;

    initial begin
        a_supported_size: assert (
            CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64
        );
        a_valid_probe: assert (PROBE_CELL >= 0 && PROBE_CELL < CELLS);
    end

    wire [32*CELLS-1:0] target_bank, noise_bank;
    frp_m31_local_gamma_drift #(.CELLS(CELLS)) dut (
        .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
        .gamma_update_valid(gamma_update_valid),
        .gamma_targets_q16(gamma_targets_q16),
        .thermal_overload_q16(thermal_overload_q16),
        .gamma_noise_target_q16(target_bank),
        .gamma_noise_state_q16(noise_bank)
    );

    wire signed [31:0] requested_target = gamma_targets_q16[32*PROBE_CELL +: 32];
    assign target_now = target_bank[32*PROBE_CELL +: 32];
    assign noise_now = noise_bank[32*PROBE_CELL +: 32];
    assign selected_target = gamma_update_valid ? requested_target : target_now;

    function automatic wide_t round_q16(input wide_t value);
        wide_t quotient;
        begin
            quotient = value >>> 16;
            if (value[15:0] > 16'h8000
                || (value[15:0] == 16'h8000 && value >= 0))
                quotient = quotient + 64'sd1;
            return quotient;
        end
    endfunction

    function automatic wide_t magnitude(input wide_t value);
        return value < 0 ? -value : value;
    endfunction

    wire signed [63:0] delta_now = wide_t'(selected_target) - wide_t'(noise_now);
    wire signed [63:0] product_now = delta_now * 64'sd9830;
    wire signed [63:0] correction_now = round_q16(product_now);
    wire signed [63:0] next_wide = wide_t'(noise_now) + correction_now;
    assign expected_noise_next = next_wide[31:0];

    logic history_valid = 1'b0;
    logic previous_reset, previous_tick, previous_valid, previous_tie;
    logic signed [31:0] previous_target, previous_noise, previous_request;
    logic signed [31:0] previous_selected, previous_expected;
    logic signed [63:0] previous_delta;

    always @(posedge clk) begin
        history_valid <= 1'b1;
        previous_reset <= rst_n;
        previous_tick <= tick_enable;
        previous_valid <= gamma_update_valid;
        previous_tie <= product_now[15:0] == 16'h8000;
        previous_target <= target_now;
        previous_noise <= noise_now;
        previous_request <= requested_target;
        previous_selected <= selected_target;
        previous_expected <= expected_noise_next;
        previous_delta <= delta_now;
    end

    wire live = history_valid && rst_n && previous_reset;
    wire updated = live && previous_tick;
    wire signed [63:0] error_before =
        wide_t'(previous_noise) - wide_t'(previous_selected);
    wire signed [63:0] error_after =
        wide_t'(noise_now) - wide_t'(previous_selected);

    always_comb begin
        if (!history_valid) a_initial_reset: assume (!rst_n);

        a_correction_range: assert (
            correction_now >= -64'sd2147483648 && correction_now <= 64'sd2147483647
        );
        a_sum_range: assert (
            next_wide >= -64'sd2147483648 && next_wide <= 64'sd2147483647
        );

        if (history_valid && (!rst_n || !previous_reset)) begin
            a_reset_target: assert (target_now == 32'sd0);
            a_reset_noise: assert (noise_now == 32'sd0);
        end
        if (live) begin
            if (!previous_tick) begin
                a_pause_target: assert (target_now == previous_target);
                a_pause_noise: assert (noise_now == previous_noise);
            end else begin
                a_target_capture: assert (target_now == previous_selected);
                a_noise_recurrence: assert (noise_now == previous_expected);
                a_no_overshoot: assert (
                    (error_before >= 0 && error_after >= 0 && error_after <= error_before)
                    || (error_before <= 0 && error_after <= 0 && error_after >= error_before)
                );
                if (magnitude(error_before) >= 64'sd4)
                    a_strict_progress: assert (magnitude(error_after) < magnitude(error_before));
                else
                    a_quantized_hold: assert (noise_now == previous_noise);
            end
        end

        reach = '0;
        if (live) begin
            reach[0] = previous_tick && previous_valid
                && previous_request != previous_target && target_now == previous_request
                && noise_now != previous_noise;
            reach[1] = !previous_tick && previous_valid
                && previous_request != previous_target
                && target_now == previous_target && noise_now == previous_noise;
            reach[2] = previous_tick && !previous_valid && previous_target != 0
                && previous_request != previous_target
                && target_now == previous_target && noise_now != previous_noise;
            reach[3] = !previous_tick && !previous_valid && previous_noise != 0
                && target_now == previous_target && noise_now == previous_noise;
        end
        if (updated) begin
            reach[4] = previous_delta > 64'sd2147483647 && noise_now > previous_noise;
            reach[5] = previous_delta < -64'sd2147483648 && noise_now < previous_noise;
            reach[6] = previous_valid && previous_request == 32'sh7fffffff
                && target_now == previous_request && noise_now > previous_noise;
            reach[7] = previous_valid && previous_request == 32'sh80000000
                && target_now == previous_request && noise_now < previous_noise;
            reach[8] = previous_tie && previous_delta > 0 && noise_now > previous_noise;
            reach[9] = previous_tie && previous_delta < 0 && noise_now < previous_noise;
            reach[10] = previous_delta == 64'sd3 && noise_now == previous_noise;
            reach[11] = previous_delta == -64'sd3 && noise_now == previous_noise;
            reach[12] = previous_delta == 64'sd4
                && wide_t'(noise_now) == wide_t'(previous_noise) + 64'sd1;
            reach[13] = previous_delta == -64'sd4
                && wide_t'(noise_now) == wide_t'(previous_noise) - 64'sd1;
            reach[15] = previous_valid && previous_selected == previous_noise
                && previous_noise != 0 && target_now == previous_noise
                && noise_now == previous_noise;
        end
        reach[14] = history_valid && previous_reset && !rst_n
            && previous_noise != 0 && target_now == 0 && noise_now == 0;
    end
endmodule

`endif

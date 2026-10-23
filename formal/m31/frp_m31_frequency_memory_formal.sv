// Copyright (c) 2026 Maksym Marnov. All rights reserved.
// Proprietary. No license is granted by this file.
// Retained-frequency contract for the M31 phase engine.
// Qualify CELLS=8/16/32/64 and every PROBE_CELL in each configuration.
// The probe is an elaboration parameter, never an assumption on cell data.
// All DUT inputs remain free except for the initial sampled reset.
// Unobserved phase/coherence logic may be removed by ordinary cone reduction;
// no frequency register, arithmetic, input or control boundary may be cut.
// A private formal copy may omit the four sine-ROM simulation $fatal checks;
// retain $readmemh, parameter validation and all functional RTL unchanged.
// The oracle uses public outputs and independent floor/remainder rounding.
// Q16 correction coefficient: 19661/65536; nearest, ties away from zero.
// Progress is relative to the target sampled on that particular update.
// A changing target does not imply convergence to one fixed frequency.
// Errors of one Q16 integer unit are quantized fixed points.
// Formal time is sampled rising edges; prepare with async2sync.
// This contract does not establish phase evolution or physical reset timing.

`ifndef FRP_M31_FREQUENCY_MEMORY_FORMAL_SV
`define FRP_M31_FREQUENCY_MEMORY_FORMAL_SV
`include "frp_m31_phase_interference.sv"

module frp_m31_frequency_memory_formal #(
    parameter int CELLS = 8,
    parameter int PROBE_CELL = 0
) (
    input logic clk, rst_n, tick_enable, load_valid,
    input logic [32*CELLS-1:0] phase_load, frequency_load_q16,
    input logic [32*CELLS-1:0] gamma_effective_word,
    input logic [32*CELLS-1:0] thermal_node_factor_q30,
    input logic [2*CELLS-1:0] retained_state,
    input logic [CELLS-1:0] switch_activity,
    input logic [2:0] scheduler_state,
    output wire signed [31:0] frequency_now,
    output wire signed [31:0] target_now,
    output wire signed [31:0] expected_next,
    output logic [15:0] reach
);
    typedef logic signed [63:0] wide_t;

    initial begin
        a_supported_size: assert (
            CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64
        );
        a_valid_probe: assert (PROBE_CELL >= 0 && PROBE_CELL < CELLS);
    end

    wire [32*CELLS-1:0] frequency_bank;
    frp_m31_phase_interference #(.CELLS(CELLS)) dut (
        .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
        .load_valid(load_valid), .phase_load(phase_load),
        .frequency_load_q16(frequency_load_q16),
        .gamma_effective_word(gamma_effective_word),
        .thermal_node_factor_q30(thermal_node_factor_q30),
        .retained_state(retained_state), .switch_activity(switch_activity),
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_state)),
        .frequency_current_q16(frequency_bank)
    );

    wire [1:0] state_now = retained_state[2*PROBE_CELL +: 2];
    wire activity_now = switch_activity[PROBE_CELL];
    wire signed [31:0] load_now = frequency_load_q16[32*PROBE_CELL +: 32];
    assign frequency_now = frequency_bank[32*PROBE_CELL +: 32];
    assign target_now = 32'sd65536
        + ((state_now == 2'b01 || state_now == 2'b11) ? 32'sd3932 : 32'sd0)
        + (activity_now ? 32'sd7864 : 32'sd0);

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

    wire signed [63:0] delta_now = wide_t'(target_now) - wide_t'(frequency_now);
    wire signed [63:0] product_now = delta_now * 64'sd19661;
    wire signed [63:0] correction_now = round_q16(product_now);
    wire signed [63:0] next_wide = wide_t'(frequency_now) + correction_now;
    assign expected_next = next_wide[31:0];

    logic history_valid = 1'b0;
    logic previous_reset, previous_tick, previous_load, previous_activity;
    logic [1:0] previous_state;
    logic signed [31:0] previous_frequency, previous_target;
    logic signed [31:0] previous_load_value, previous_expected;
    logic previous_tie;
    logic signed [63:0] previous_delta;

    always @(posedge clk) begin
        history_valid <= 1'b1;
        previous_reset <= rst_n;
        previous_tick <= tick_enable;
        previous_load <= load_valid;
        previous_activity <= activity_now;
        previous_state <= state_now;
        previous_frequency <= frequency_now;
        previous_target <= target_now;
        previous_load_value <= load_now;
        previous_expected <= expected_next;
        previous_tie <= product_now[15:0] == 16'h8000;
        previous_delta <= delta_now;
    end

    wire live = history_valid && rst_n && previous_reset;
    wire updated = live && !previous_load && previous_tick;
    wire signed [63:0] error_before =
        wide_t'(previous_frequency) - wide_t'(previous_target);
    wire signed [63:0] error_after =
        wide_t'(frequency_now) - wide_t'(previous_target);

    always_comb begin
        if (!history_valid) a_initial_reset: assume (!rst_n);

        // With a signed 32-bit frequency and these four target values,
        // neither correction nor sum needs saturation. Check this explicitly.
        a_correction_range: assert (
            correction_now >= -64'sd2147483648 && correction_now <= 64'sd2147483647
        );
        a_sum_range: assert (
            next_wide >= -64'sd2147483648 && next_wide <= 64'sd2147483647
        );

        if (history_valid && (!rst_n || !previous_reset))
            a_reset: assert (frequency_now == 32'sd65536);
        if (live) begin
            if (previous_load)
                a_load_priority: assert (frequency_now == previous_load_value);
            else if (!previous_tick)
                a_pause: assert (frequency_now == previous_frequency);
            else begin
                a_recurrence: assert (frequency_now == previous_expected);
                a_no_overshoot: assert (
                    (error_before >= 0 && error_after >= 0 && error_after <= error_before)
                    || (error_before <= 0 && error_after <= 0 && error_after >= error_before)
                );
                if (magnitude(error_before) >= 64'sd2)
                    a_strict_progress: assert (magnitude(error_after) < magnitude(error_before));
                else
                    a_quantized_hold: assert (frequency_now == previous_frequency);
            end
        end

        reach = '0;
        if (live) begin
            reach[0] = previous_load && previous_tick
                && previous_load_value != previous_frequency
                && frequency_now == previous_load_value;
            reach[1] = previous_load && !previous_tick
                && previous_load_value != previous_frequency
                && frequency_now == previous_load_value;
            reach[2] = !previous_load && !previous_tick
                && frequency_now == previous_frequency && frequency_now != 32'sd65536;
        end
        if (updated) begin
            reach[3] = previous_frequency == 32'sh80000000 && error_after > error_before;
            reach[4] = previous_frequency == 32'sh7fffffff && error_after < error_before;
            reach[5] = previous_state == 2'b00 && !previous_activity
                && frequency_now != previous_frequency;
            reach[6] = previous_state == 2'b10 && previous_activity
                && frequency_now != previous_frequency;
            reach[7] = magnitude(error_before) == 64'sd1 && frequency_now == previous_frequency;
            reach[8] = previous_tie && previous_delta > 0 && frequency_now > previous_frequency;
            reach[9] = previous_tie && previous_delta < 0 && frequency_now < previous_frequency;
            reach[12] = previous_state == 2'b01 && previous_activity
                && frequency_now != previous_frequency;
            reach[13] = previous_state == 2'b11 && previous_activity
                && frequency_now != previous_frequency;
            reach[14] = previous_state == 2'b01 && !previous_activity
                && frequency_now != previous_frequency;
            reach[15] = previous_state == 2'b11 && !previous_activity
                && frequency_now != previous_frequency;
        end
        reach[10] = history_valid && previous_reset && !rst_n
            && previous_frequency != 32'sd65536 && frequency_now == 32'sd65536;
        reach[11] = history_valid && !rst_n && load_valid && tick_enable
            && load_now != 32'sd65536 && frequency_now == 32'sd65536;
    end
endmodule

`endif

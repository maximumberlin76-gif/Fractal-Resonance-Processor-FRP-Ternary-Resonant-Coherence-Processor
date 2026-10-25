// Copyright (c) 2026 Maksym Marnov. All rights reserved.
// Proprietary. No license is granted by this file.
// Generated-power arithmetic and retention in the native local thermal field.
// Qualify CELLS=8/16/32/64 and every PROBE_CELL in each configuration.
// Frequency lag is an unsigned 32-bit Q16.16 word, including its upper half.
// Power = 118 + round(lag * 1180 / 65536) + 3408 * switch_activity.
// Rounding is nearest with half cases upward for this nonnegative product.
// The independent oracle uses quotient/remainder arithmetic and literal
// coefficients. Its maximum result is 77336006, within signed 32-bit range.
// Reset clears the power register; tick commits; pause retains the last value.
// Only initial sampled reset is assumed. All later input words and controls
// remain free, including simultaneous reset, tick and switching activity.
// Keep the selected power register and its complete input cone intact.
// Ordinary optimization may remove unobserved heat, diffusion and peak cones.
// Formal time is sampled rising edges after async2sync.

`ifndef FRP_M31_THERMAL_POWER_FORMAL_SV
`define FRP_M31_THERMAL_POWER_FORMAL_SV
`include "frp_m31_local_thermal_field.sv"

module frp_m31_thermal_power_formal #(
    parameter int CELLS = 8,
    parameter int PROBE_CELL = 0
) (
    input logic clk, rst_n, tick_enable,
    input logic [CELLS-1:0] switch_activity,
    input logic [32*CELLS-1:0] frequency_lag_q16,
    output wire signed [31:0] power_now,
    output wire [31:0] expected_power_next,
    output logic [15:0] reach
);
    initial begin
        a_supported_size: assert (
            CELLS == 8 || CELLS == 16 || CELLS == 32 || CELLS == 64
        );
        a_valid_probe: assert (PROBE_CELL >= 0 && PROBE_CELL < CELLS);
    end

    wire [32*CELLS-1:0] power_bank;
    frp_m31_local_thermal_field #(.CELLS(CELLS)) dut (
        .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
        .switch_activity(switch_activity),
        .frequency_lag_q16(frequency_lag_q16),
        .generated_power_q16(power_bank)
    );

    wire [31:0] lag_now = frequency_lag_q16[32*PROBE_CELL +: 32];
    wire switch_now = switch_activity[PROBE_CELL];
    assign power_now = power_bank[32*PROBE_CELL +: 32];

    wire [63:0] product_now = {32'd0, lag_now} * 64'd1180;
    wire [63:0] quotient_now = product_now >> 16;
    wire [63:0] rounded_now = quotient_now
        + ((product_now[15:0] >= 16'h8000) ? 64'd1 : 64'd0);
    wire [63:0] expected_wide = 64'd118 + rounded_now
        + (switch_now ? 64'd3408 : 64'd0);
    assign expected_power_next = expected_wide[31:0];

    logic history_valid = 1'b0;
    logic previous_reset, previous_tick, previous_switch;
    logic [31:0] previous_lag, previous_expected;
    logic signed [31:0] previous_power;
    logic [15:0] previous_remainder;
    logic sampled_since_reset = 1'b0;

    always @(posedge clk) begin
        history_valid <= 1'b1;
        previous_reset <= rst_n;
        previous_tick <= tick_enable;
        previous_switch <= switch_now;
        previous_lag <= lag_now;
        previous_expected <= expected_power_next;
        previous_power <= power_now;
        previous_remainder <= product_now[15:0];
        if (!rst_n)
            sampled_since_reset <= 1'b0;
        else if (tick_enable)
            sampled_since_reset <= 1'b1;
    end

    wire live = history_valid && rst_n && previous_reset;
    wire updated = live && previous_tick;

    always_comb begin
        if (!history_valid) a_initial_reset: assume (!rst_n);

        a_oracle_range: assert (
            expected_wide >= 64'd118 && expected_wide <= 64'd77336006
        );
        if (history_valid) begin
            if (!rst_n || !previous_reset) begin
                a_reset: assert (power_now == 32'sd0);
            end else begin
                if (previous_tick)
                    a_commit: assert (power_now == $signed(previous_expected));
                else
                    a_pause: assert (power_now == previous_power);

                if (sampled_since_reset)
                    a_retained_range: assert (
                        power_now >= 32'sd118 && power_now <= 32'sd77336006
                    );
                else
                    a_initial_hold: assert (power_now == 32'sd0);
            end
        end

        reach = '0;
        if (updated) begin
            reach[0] = previous_lag == 32'd0 && !previous_switch
                && power_now == 32'sd118;
            reach[1] = previous_lag == 32'd0 && previous_switch
                && power_now == 32'sd3526;
            reach[2] = previous_lag == 32'h7fffffff && !previous_switch
                && power_now == 32'sd38666358;
            reach[3] = previous_lag == 32'h80000000 && !previous_switch
                && power_now == 32'sd38666358;
            reach[4] = previous_lag == 32'hffffffff && !previous_switch
                && power_now == 32'sd77332598;
            reach[5] = previous_lag == 32'hffffffff && previous_switch
                && power_now == 32'sd77336006;
            reach[6] = previous_remainder == 16'h8000
                && power_now == $signed(previous_expected);
            reach[7] = previous_remainder == 16'h7ffc
                && power_now == $signed(previous_expected);
            reach[8] = previous_remainder == 16'h8004
                && power_now == $signed(previous_expected);
            reach[9] = previous_lag == 32'd27 && !previous_switch
                && power_now == 32'sd118;
            reach[10] = previous_lag == 32'd28 && !previous_switch
                && power_now == 32'sd119;
            reach[11] = previous_power > power_now && power_now == 32'sd118;
            reach[12] = previous_power < power_now && previous_power != 32'sd0;
        end
        if (live) begin
            reach[13] = !previous_tick && previous_power != 32'sd0
                && previous_expected != $unsigned(previous_power)
                && power_now == previous_power;
            reach[15] = !sampled_since_reset && !previous_tick
                && previous_lag == 32'hffffffff && previous_switch
                && power_now == 32'sd0;
        end
        reach[14] = history_valid && previous_reset && !rst_n
            && tick_enable && switch_now && previous_power != 32'sd0
            && power_now == 32'sd0;
    end
endmodule

`endif

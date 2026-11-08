// SPDX-License-Identifier: Apache-2.0
// Same-clock CSR contract for the 26-word M32 boundary snapshot.
`include "frp_m32_boundary_snapshot_csr.sv"

module frp_m32_snapshot_csr_formal #(
    parameter int CELLS = 64,
    parameter int COUNT_BITS = 64
) (
    input logic clk, rst_n, csr_valid, csr_write,
    input logic [7:0] csr_addr,
    input logic [31:0] csr_wdata,
    input logic [4:0] flags,
    input logic [COUNT_BITS-1:0] count,
    input logic [31:0] previous_margin, minimum_margin, peak_load,
    input logic [63:0] minimum_tick, peak_tick, boundary_tick,
    input logic [1:0] mode,
    input logic [2:0] phase,
    input logic [31:0] boundary_previous, margin, capacity, pressure, heat, load_word,
    input logic [2*CELLS-1:0] retained, pending,
    output wire csr_ready, csr_error,
    output wire [31:0] csr_rdata,
    output logic [7:0] reach
);
    frp_m32_boundary_snapshot_csr #(.CELLS(CELLS), .RECORDER_COUNT_BITS(COUNT_BITS)) dut (
        .clk, .rst_n, .csr_valid, .csr_write, .csr_addr, .csr_wdata,
        .csr_ready, .csr_error, .csr_rdata,
        .record_sample_seen_q(flags[0]), .record_count_overflow_q(flags[1]),
        .boundary_valid_q(flags[2]), .boundary_pulse_q(flags[3]),
        .record_alignment_error_q(flags[4]), .record_sample_count_q(count),
        .record_previous_margin_q16(previous_margin), .record_minimum_margin_q16(minimum_margin),
        .record_minimum_margin_tick_q(minimum_tick), .record_peak_switch_load_q16(peak_load),
        .record_peak_switch_load_tick_q(peak_tick), .boundary_tick_q(boundary_tick),
        .boundary_scheduler_mode_q(mode), .boundary_scheduler_state_q(phase),
        .boundary_previous_margin_q16(boundary_previous), .boundary_margin_q16(margin),
        .boundary_capacity_q16(capacity), .boundary_pressure_q16(pressure),
        .boundary_mean_heat_q16(heat), .boundary_switch_load_q16(load_word),
        .boundary_retained_state_q(retained), .boundary_pending_route_q(pending)
    );

    // Concatenation follows descending byte addresses 0x74 through 0x10.
    typedef logic [26*32-1:0] image_t;
    wire image_t live_image = {
        128'(pending), 128'(retained), load_word, heat, pressure, capacity,
        margin, boundary_previous, 27'b0, phase, mode, boundary_tick,
        peak_tick, peak_load, minimum_tick, minimum_margin, previous_margin, 64'(count)
    };
    wire active = rst_n && csr_valid;
    wire command = active && csr_write && csr_addr == 0;
    wire capture = command && csr_wdata == 1;
    wire release_cmd = command && csr_wdata == 2;
    image_t saved_image;
    logic [5:0] saved_status;
    logic released;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            saved_image <= '0;
            saved_status <= '0;
            released <= 0;
        end else if (capture) begin
            saved_image <= live_image;
            saved_status <= {flags, 1'b1};
            released <= 0;
        end else if (release_cmd) begin
            saved_image <= '0;
            saved_status <= '0;
            released <= released || saved_status[0];
        end
    end

    wire payload_addr = csr_addr[1:0] == 0 && csr_addr >= 8'h10 && csr_addr <= 8'h74;
    wire payload_read = active && !csr_write && payload_addr;
    wire readable = csr_addr == 8'h04 || csr_addr == 8'h08 || csr_addr == 8'h0c ||
        (payload_addr && saved_status[0]);
    wire expected_error = active && (csr_write ? !(capture || release_cmd) : !readable);

    logic [31:0] expected_data;
    always_comb begin
        expected_data = 0;
        if (active && !csr_write) begin
            case (csr_addr)
                8'h04: expected_data = {26'd0, saved_status};
                8'h08: expected_data = 32'h46524201;
                8'h0c: expected_data = {16'(COUNT_BITS), 16'(CELLS)};
                default: if (saved_status[0])
                    for (int w=0; w<26; w++)
                        if (csr_addr == 8'(16 + 4*w))
                            expected_data = saved_image[32*w+:32];
            endcase
        end
    end

    logic sampled = 0;
    always @(posedge clk) sampled <= 1;
    always_comb if (!sampled) a_initial_reset: assume (!rst_n);
    always_comb if (sampled) begin
        a_storage: assert (dut.snapshot_words_q == saved_image);
        a_flags: assert ({dut.snapshot_flags_q, dut.snapshot_valid_q} == saved_status);
        a_ready: assert (csr_ready == rst_n);
        a_error: assert (csr_error == expected_error);
        a_data: assert (csr_rdata == expected_data);
    end

    always_comb begin
        reach = '0;
        if (sampled && rst_n) begin
            reach[0] = capture && !saved_status[0];
            reach[1] = capture && saved_status[0] && saved_image != live_image;
            reach[2] = payload_read && saved_status[0] && csr_addr == 8'h10 &&
                live_image[31:0] != csr_rdata;
            reach[3] = payload_read && saved_status[0] && csr_addr == 8'h74 &&
                (CELLS == 64 ? csr_rdata[31:30] == 2'b11 : csr_rdata == 0);
            reach[4] = release_cmd && saved_status[0];
            reach[5] = released && payload_read && csr_error;
            reach[6] = active && !csr_write && saved_status[0] && csr_addr[1:0] != 0 && csr_error;
            reach[7] = command && saved_status[0] && !capture && !release_cmd && csr_error;
        end
    end
endmodule

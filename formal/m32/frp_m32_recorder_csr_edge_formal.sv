// SPDX-License-Identifier: Apache-2.0
// Same-edge recorder updates and host captures. The observed core ties clear_epoch low.
`include "frp_m32_recorder_saturation_formal.sv"
`include "frp_m32_snapshot_csr_formal.sv"

module frp_m32_recorder_csr_edge_formal #(
    parameter int CELLS = 64, COUNT_BITS = 64,
    parameter bit ENABLE_EPOCH_CLEAR = 0
) (
    input logic clk, rst_n, clear_epoch, sample_valid, alignment_error,
    input logic [63:0] source_tick,
    input logic [1:0] scheduler_mode,
    input logic [2:0] scheduler_state,
    input logic signed [31:0] coherence_capacity_q16, pressure_q16, stability_margin_q16,
    input logic signed [31:0] mean_heat_q16, switch_load_q16,
    input logic [2*CELLS-1:0] retained_state, pending_route,
    input logic csr_valid, csr_write,
    input logic [7:0] csr_addr,
    input logic [31:0] csr_wdata,
    output wire csr_ready, csr_error,
    output wire [31:0] csr_rdata,
    output logic [7:0] reach
);
    wire clear = ENABLE_EPOCH_CLEAR && clear_epoch;
    frp_m32_recorder_saturation_formal #(.CELLS(CELLS), .COUNT_BITS(COUNT_BITS)) rec (
        .clk, .rst_n, .clear_epoch(clear), .sample_valid, .source_tick,
        .scheduler_mode, .scheduler_state, .coherence_capacity_q16, .pressure_q16,
        .stability_margin_q16, .mean_heat_q16, .switch_load_q16, .retained_state,
        .pending_route, .reach()
    );

    frp_m32_snapshot_csr_formal #(.CELLS(CELLS), .COUNT_BITS(COUNT_BITS)) bus (
        .clk, .rst_n, .csr_valid, .csr_write, .csr_addr, .csr_wdata, .csr_ready,
        .csr_error, .csr_rdata, .reach(),
        .flags({alignment_error, rec.pulse_q, rec.valid_q, rec.overflow_q, rec.seen_q}),
        .count(rec.count_q), .previous_margin(rec.previous_q),
        .minimum_margin(rec.dut.minimum_margin_q16), .minimum_tick(rec.dut.minimum_margin_tick_q),
        .peak_load(rec.dut.peak_switch_load_q16), .peak_tick(rec.dut.peak_switch_load_tick_q),
        .boundary_tick(rec.frame_q.tick), .mode(rec.frame_q.mode), .phase(rec.frame_q.phase),
        .boundary_previous(rec.frame_q.previous_margin), .margin(rec.frame_q.margin),
        .capacity(rec.frame_q.capacity), .pressure(rec.frame_q.pressure), .heat(rec.frame_q.heat),
        .load_word(rec.frame_q.load), .retained(rec.frame_q.retained), .pending(rec.frame_q.pending)
    );

    // Extrema belong to accepted samples. Equal extrema retain their original tags.
    logic signed [31:0] low_margin, high_load;
    logic [63:0] low_tick, high_tick;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {low_margin, high_load, low_tick, high_tick} <= '0;
        end else if (clear) begin
            {low_margin, high_load, low_tick, high_tick} <= '0;
        end else if (sample_valid) begin
            if (!rec.ref_seen || stability_margin_q16 < low_margin)
                {low_margin, low_tick} <= {stability_margin_q16, source_tick};
            if (!rec.ref_seen || switch_load_q16 > high_load)
                {high_load, high_tick} <= {switch_load_q16, source_tick};
        end
    end

    // The host samples the reference recorder as it stood before this edge.
    wire [26*32-1:0] before_edge = {
        128'(rec.ref_frame.pending), 128'(rec.ref_frame.retained),
        rec.ref_frame.load, rec.ref_frame.heat, rec.ref_frame.pressure, rec.ref_frame.capacity,
        rec.ref_frame.margin, rec.ref_frame.previous_margin, 27'b0,
        rec.ref_frame.phase, rec.ref_frame.mode, rec.ref_frame.tick,
        high_tick, high_load, low_tick, low_margin, rec.ref_previous, 64'(rec.ref_count)
    };
    wire command = csr_valid && csr_write && csr_addr == 0;
    wire take = command && csr_wdata == 1;
    wire drop = command && csr_wdata == 2;
    logic [26*32-1:0] host_image;
    logic [5:0] host_flags;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            host_image <= '0;
            host_flags <= '0;
        end else if (take) begin
            host_image <= before_edge;
            host_flags <= {alignment_error, rec.ref_pulse, rec.ref_valid,
                           rec.ref_overflow, rec.ref_seen, 1'b1};
        end else if (drop) begin
            host_image <= '0;
            host_flags <= '0;
        end
    end

    always_comb if (rec.sampled) begin
        a_extrema: assert ({rec.dut.minimum_margin_q16, rec.dut.peak_switch_load_q16,
                            rec.dut.minimum_margin_tick_q, rec.dut.peak_switch_load_tick_q}
                           == {low_margin, high_load, low_tick, high_tick});
        a_host_image: assert (bus.dut.snapshot_words_q == host_image);
        a_host_flags: assert ({bus.dut.snapshot_flags_q, bus.dut.snapshot_valid_q} == host_flags);
    end

    wire first_cross = !clear && rec.capture;
    logic crossed, cleared, recaptured_cross, recaptured_clear, released_cross, overflow_cross;
    logic held_clear;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            held_clear <= 0;
            {crossed, cleared, recaptured_cross, recaptured_clear, released_cross, overflow_cross} <= '0;
        end else begin
            held_clear <= clear && sample_valid && !take && !drop && host_flags[3] && rec.ref_valid;
            crossed <= take && first_cross;
            cleared <= take && clear && rec.ref_valid;
            recaptured_cross <= take && crossed;
            recaptured_clear <= take && cleared;
            released_cross <= drop && first_cross && host_flags[0];
            overflow_cross <= take && first_cross && rec.carry && !rec.ref_overflow;
        end
    end

    wire flags_read = csr_valid && !csr_write && csr_addr == 8'h04 && !csr_error;
    localparam int LAST_BIT = 2*(CELLS-1);
    always_comb begin
        reach = '0;
        if (rec.sampled && rst_n) begin
            reach[0] = crossed && flags_read && !csr_rdata[3] && csr_rdata[0] && rec.valid_q;
            reach[1] = recaptured_cross && flags_read && (&csr_rdata[4:3]);
            reach[2] = cleared && flags_read && csr_rdata[3] && !rec.valid_q;
            reach[3] = recaptured_clear && flags_read && csr_rdata[4:0] == 5'b00001;
            reach[4] = released_cross && csr_valid && !csr_write && csr_addr == 8'h10 && csr_error;
            reach[5] = overflow_cross && flags_read && !csr_rdata[2] && rec.overflow_q;
            reach[6] = csr_valid && !csr_write && !csr_error &&
                csr_addr == 8'(8'h68 + 4*(LAST_BIT/32)) &&
                csr_rdata[LAST_BIT%32+:2] == 2'b11 && pending_route[LAST_BIT+:2] == 0;
            reach[7] = held_clear && flags_read && csr_rdata[3] && !rec.valid_q;
        end
    end
endmodule

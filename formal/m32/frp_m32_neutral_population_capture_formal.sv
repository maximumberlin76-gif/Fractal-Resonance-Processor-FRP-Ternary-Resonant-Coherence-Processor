// SPDX-License-Identifier: Apache-2.0
// Fixed load at the half-neutral threshold; arbitrary locations and polarities.
`include "frp_m31_global_stability.sv"
`include "frp_m32_boundary_recorder.sv"

module frp_m32_neutral_population_capture_formal #(parameter int CELLS = 64) (
    input logic clk, rst_n, tick_enable,
    input logic [CELLS-1:0] neutral_mask, negative,
    input logic [63:0] tick_tag,
    output logic [5:0] reach
);
    localparam int HALF = CELLS/2;
    localparam int BASE = 53740;
    localparam int GAIN = 5243;
    localparam int LOAD = BASE + (GAIN+1)/2;

    wire [2*CELLS-1:0] bank;
    for (genvar i=0; i<CELLS; i++) begin : lanes
        assign bank[2*i+:2] = neutral_mask[i] ? 2'b00 : {negative[i], 1'b1};
    end

    logic [$clog2(CELLS):0] population;
    always_comb begin
        population = '0;
        for (int i=0; i<CELLS; i++) population += neutral_mask[i];
    end
    // Divide the gain into quotient and remainder, then round the total once.
    wire [31:0] increment = (GAIN/CELLS)*population
                           + ((GAIN%CELLS)*population + HALF)/CELLS;
    wire signed [31:0] capacity = BASE + increment;
    wire signed [31:0] margin = capacity - LOAD;

    wire signed [31:0] live_capacity, live_pressure, live_margin;
    wire live_stable;
    frp_m31_global_stability #(.CELLS(CELLS)) stability (
        .clk, .rst_n, .tick_enable, .retained_state(bank), .switch_load_q16(LOAD),
        .raw_phase_coherence_q30('0), .cluster_coherence_q30('0),
        .heat_q16('0), .thermal_overload_q16('0), .frequency_lag_q16('0),
        .coherence_capacity_q16(live_capacity), .pressure_q16(live_pressure),
        .stability_margin_q16(live_margin), .stable(live_stable)
    );

    logic valid;
    logic [63:0] sample_tag;
    logic [2*CELLS-1:0] sample_bank;
    logic [$clog2(CELLS):0] sample_count;
    logic signed [31:0] sample_capacity, sample_margin, sample_pressure;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 0;
            sample_tag <= 0;
            sample_bank <= 0;
            sample_count <= 0;
            sample_capacity <= 65536;
            sample_margin <= 62259;
            sample_pressure <= 3277;
        end else begin
            valid <= tick_enable;
            if (tick_enable) begin
                sample_tag <= tick_tag;
                sample_bank <= bank;
                sample_count <= population;
                sample_capacity <= capacity;
                sample_margin <= margin;
                sample_pressure <= LOAD;
            end
        end
    end

    frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(64)) recorder (
        .clk, .rst_n, .clear_epoch(1'b0), .sample_valid(valid), .source_tick(sample_tag),
        .scheduler_mode('0), .scheduler_state('0), .coherence_capacity_q16(live_capacity),
        .pressure_q16(live_pressure), .stability_margin_q16(live_margin),
        .mean_heat_q16('0), .switch_load_q16(LOAD), .retained_state(sample_bank), .pending_route('0)
    );

    logic above, taken, pulse;
    logic signed [31:0] previous;
    wire cross_now = valid && above && sample_count <= HALF;
    typedef struct packed {
        logic [63:0] tag;
        logic signed [31:0] before_margin, after_margin;
        logic [2*CELLS-1:0] retained;
    } frame_t;
    frame_t frame;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            above <= 1;
            taken <= 0;
            pulse <= 0;
            previous <= 39322;
            frame <= '0;
        end else begin
            pulse <= !taken && cross_now;
            if (valid) begin
                above <= sample_count > HALF;
                previous <= sample_margin;
            end
            if (!taken && cross_now) begin
                taken <= 1;
                frame <= {sample_tag, previous, sample_margin, sample_bank};
            end
        end
    end

    logic started = 0;
    always_ff @(posedge clk) started <= 1;
    always_comb if (!started) assume (!rst_n);
    always_comb if (started) begin
        a_fraction: assert (stability.neutral_fraction_q30 == population*(32'd1073741824/CELLS));
        a_capacity: assert (stability.next_coherence_capacity_q16 == capacity);
        a_threshold: assert (stability.next_stability_margin_q16 == margin &&
                             stability.next_stable == (population > HALF));
        a_commit: assert ({live_capacity, live_margin, live_pressure, live_stable}
                         == {sample_capacity, sample_margin, sample_pressure, (sample_margin > 0)});
        a_sign: assert (above == (previous > 0));
        a_history: assert (recorder.previous_margin_q16 == previous);
        a_flags: assert ({recorder.boundary_valid_q, recorder.boundary_pulse_q} == {taken, pulse});
        a_frame: assert ({recorder.boundary_tick_q, recorder.boundary_previous_margin_q16,
                          recorder.boundary_margin_q16, recorder.boundary_retained_state_q} == frame);
    end

    always_comb begin
        reach = 0;
        if (started && rst_n) begin
            reach[0] = pulse && frame.after_margin == 0 && frame.before_margin > 0 &&
                       frame.before_margin < 39322 && frame.retained[2*CELLS-1-:2] == 0;
            reach[1] = valid && tick_enable && sample_count == CELLS && population == 0;
            reach[2] = valid && tick_enable && sample_count == HALF && population == HALF &&
                       sample_bank[2*CELLS-1-:2] == 0 && bank[2*CELLS-1-:2] != 0;
            reach[3] = !tick_enable && !valid && sample_count > HALF && population < HALF;
            reach[4] = taken && cross_now && sample_tag != frame.tag;
            reach[5] = pulse && frame.before_margin == BASE+GAIN-LOAD && frame.after_margin == BASE-LOAD;
        end
    end
endmodule

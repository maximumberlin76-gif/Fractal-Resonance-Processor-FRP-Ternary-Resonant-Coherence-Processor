// SPDX-License-Identifier: Apache-2.0
// One selected lane may be active zero. All other lanes independently take +1 or -1.
// One committed M31 result is presented to the M32 recorder on the following edge.
`include "frp_m31_global_stability.sv"
`include "frp_m32_boundary_recorder.sv"

module frp_m32_neutral_threshold_capture_formal #(parameter int CELLS = 64) (
    input logic clk, rst_n, tick_enable, neutral, upper_threshold,
    input logic [$clog2(CELLS)-1:0] lane,
    input logic [CELLS-1:0] negative,
    input logic [1:0] load_offset,
    input logic [63:0] tick_tag,
    output logic [5:0] reach
);
    localparam int BASE = 53740;
    localparam int NEUTRAL_STEP = (5243 + CELLS/2) / CELLS;
    wire signed [31:0] offset = load_offset == 1 ? -32'sd1 :
                                load_offset == 2 ? 32'sd1 : 32'sd0;
    wire signed [31:0] load_word = BASE + (upper_threshold ? NEUTRAL_STEP : 0) + offset;
    wire signed [31:0] capacity = BASE + (neutral ? NEUTRAL_STEP : 0);
    wire signed [31:0] margin = capacity - load_word;
    wire [2*CELLS-1:0] bank;
    for (genvar i=0; i<CELLS; i++) begin : lanes
        assign bank[2*i+:2] = (neutral && lane == i) ? 2'b00 : {negative[i], 1'b1};
    end

    wire signed [31:0] live_capacity, live_pressure, live_margin;
    wire live_stable;
    frp_m31_global_stability #(.CELLS(CELLS)) stability (
        .clk, .rst_n, .tick_enable, .retained_state(bank),
        .raw_phase_coherence_q30('0), .cluster_coherence_q30('0), .heat_q16('0),
        .thermal_overload_q16('0), .frequency_lag_q16('0), .switch_load_q16(load_word),
        .coherence_capacity_q16(live_capacity), .pressure_q16(live_pressure),
        .stability_margin_q16(live_margin), .stable(live_stable)
    );

    logic valid;
    logic [2*CELLS-1:0] sample_bank;
    logic [63:0] sample_tag;
    logic signed [31:0] sample_capacity, sample_load, sample_margin;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 0;
            sample_bank <= 0;
            sample_tag <= 0;
            sample_capacity <= 65536;
            sample_load <= 3277;
            sample_margin <= 62259;
        end else begin
            valid <= tick_enable;
            if (tick_enable) begin
                sample_bank <= bank;
                sample_tag <= tick_tag;
                sample_capacity <= capacity;
                sample_load <= load_word;
                sample_margin <= margin;
            end
        end
    end

    frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(64)) recorder (
        .clk, .rst_n, .clear_epoch(1'b0), .sample_valid(valid), .source_tick(sample_tag),
        .scheduler_mode('0), .scheduler_state('0), .coherence_capacity_q16(live_capacity),
        .pressure_q16(live_pressure), .stability_margin_q16(live_margin), .mean_heat_q16('0),
        .switch_load_q16(sample_load), .retained_state(sample_bank), .pending_route('0)
    );

    typedef struct packed {
        logic [63:0] tag;
        logic signed [31:0] previous_margin, margin, capacity, pressure;
        logic [2*CELLS-1:0] retained;
    } frame_t;
    frame_t first_frame;
    wire frame_t observed = {recorder.boundary_tick_q, recorder.boundary_previous_margin_q16,
        recorder.boundary_margin_q16, recorder.boundary_capacity_q16,
        recorder.boundary_pressure_q16, recorder.boundary_retained_state_q};
    logic taken, pulse;
    logic signed [31:0] previous;
    wire crossing = valid && previous > 0 && sample_margin <= 0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            taken <= 0;
            pulse <= 0;
            previous <= 39322;
            first_frame <= '0;
        end else begin
            pulse <= !taken && crossing;
            if (valid) previous <= sample_margin;
            if (!taken && crossing) begin
                taken <= 1;
                first_frame <= {sample_tag, previous, sample_margin,
                                sample_capacity, sample_load, sample_bank};
            end
        end
    end

    logic started = 0;
    always_ff @(posedge clk) started <= 1;
    always_comb if (!started) assume (!rst_n);
    always_comb if (started) begin
        a_fraction: assert (stability.neutral_fraction_q30 == (neutral ? (32'sd1073741824 / CELLS) : 0));
        a_next: assert ({stability.next_coherence_capacity_q16, stability.next_pressure_q16,
                         stability.next_stability_margin_q16} == {capacity, load_word, margin});
        a_strict_zero: assert (stability.next_stable == (margin > 0));
        a_commit_hold: assert ({live_capacity, live_pressure, live_margin, live_stable}
                               == {sample_capacity, sample_load, sample_margin, (sample_margin > 0)});
        a_previous: assert (recorder.previous_margin_q16 == previous);
        a_flags: assert ({recorder.boundary_valid_q, recorder.boundary_pulse_q} == {taken, pulse});
        a_first_frame: assert (observed == first_frame &&
                               recorder.boundary_switch_load_q16 == first_frame.pressure);
    end

    localparam int LAST = 2*(CELLS-1);
    logic remove_last, captured_removal;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            remove_last <= 0;
            captured_removal <= 0;
        end else begin
            remove_last <= !taken && valid && tick_enable && sample_bank[LAST+:2] == 0
                           && !neutral && sample_load == load_word && sample_margin > 0 && margin == 0;
            captured_removal <= remove_last && crossing && !taken;
        end
    end
    always_comb begin
        reach = 0;
        if (started && rst_n) begin
            reach[0] = captured_removal && pulse && first_frame.margin == 0
                       && first_frame.previous_margin == NEUTRAL_STEP;
            reach[1] = pulse && first_frame.margin == 0 && first_frame.retained[LAST+:2] == 0
                       && bank[LAST+:2] != 0;
            reach[2] = !taken && crossing && sample_margin == -1 && !tick_enable;
            reach[3] = taken && valid && previous == 0 && sample_margin < 0 && !pulse;
            reach[4] = taken && crossing && first_frame.tag != sample_tag;
            reach[5] = !valid && !tick_enable && live_stable && margin < 0
                       && sample_bank[LAST+:2] == 0 && sample_capacity == BASE + NEUTRAL_STEP;
        end
    end
endmodule

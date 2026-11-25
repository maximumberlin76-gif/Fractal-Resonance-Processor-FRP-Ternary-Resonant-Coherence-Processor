// SPDX-License-Identifier: Apache-2.0
`ifndef FRP_M32_RECORDER_PARTITION_NETLIST
`include "frp_m32_boundary_recorder.sv"
`endif

module frp_m32_recorder_epoch_partition_formal #(
    parameter int CELLS = 8,
    parameter int COUNT_BITS = 3
) (
    input logic clk, rst_n, clear_epoch, sample_valid, split,
    input logic [63:0] source_tick,
    input logic [1:0] scheduler_mode,
    input logic [2:0] scheduler_state,
    input logic signed [31:0] coherence_capacity_q16, pressure_q16,
                              stability_margin_q16, mean_heat_q16, switch_load_q16,
    input logic [2*CELLS-1:0] retained_state, pending_route,
    output logic [9:0] reach
);
    typedef struct packed {
        logic [63:0] tick;
        logic [1:0] mode;
        logic [2:0] phase;
        logic [31:0] margin, capacity, pressure, heat, load_word;
        logic [2*CELLS-1:0] retained, pending;
    } frame_t;
    typedef struct packed {
        logic seen, overflow, valid, pulse;
        logic [COUNT_BITS-1:0] count;
        logic signed [31:0] last_margin, low, high, before_cross;
        logic [63:0] low_tick, high_tick;
        frame_t frame;
    } observation_t;
    localparam logic signed [31:0] INITIAL_MARGIN = 32'sd39322;
    localparam observation_t EMPTY = '{last_margin:INITIAL_MARGIN, default:'0};

    // A split coincident with an accepted sample sends that sample to the suffix.
    logic in_suffix, first_suffix_cross;
    wire to_suffix = in_suffix || split;
    wire [2:0] take = {sample_valid && to_suffix,
                       sample_valid && !to_suffix, sample_valid};
    observation_t obs [3];
    wire observation_t whole = obs[0], prefix = obs[1], suffix = obs[2];
    for (genvar i = 0; i < 3; i++) begin : segment
`ifdef FRP_M32_RECORDER_PARTITION_NETLIST
        frp_m32_boundary_recorder dut (
`else
        frp_m32_boundary_recorder #(.CELLS(CELLS), .COUNT_BITS(COUNT_BITS)) dut (
`endif
            .clk, .rst_n, .clear_epoch, .sample_valid(take[i]), .source_tick,
            .scheduler_mode, .scheduler_state,
            .coherence_capacity_q16(coherence_capacity_q16), .pressure_q16(pressure_q16),
            .stability_margin_q16(stability_margin_q16), .mean_heat_q16(mean_heat_q16),
            .switch_load_q16(switch_load_q16),
            .retained_state, .pending_route,
            .sample_seen_q(obs[i].seen), .sample_count_q(obs[i].count),
            .count_overflow_q(obs[i].overflow), .previous_margin_q16(obs[i].last_margin),
            .minimum_margin_q16(obs[i].low), .minimum_margin_tick_q(obs[i].low_tick),
            .peak_switch_load_q16(obs[i].high), .peak_switch_load_tick_q(obs[i].high_tick),
            .boundary_valid_q(obs[i].valid), .boundary_pulse_q(obs[i].pulse),
            .boundary_tick_q(obs[i].frame.tick), .boundary_scheduler_mode_q(obs[i].frame.mode),
            .boundary_scheduler_state_q(obs[i].frame.phase),
            .boundary_previous_margin_q16(obs[i].before_cross),
            .boundary_margin_q16(obs[i].frame.margin), .boundary_capacity_q16(obs[i].frame.capacity),
            .boundary_pressure_q16(obs[i].frame.pressure),
            .boundary_mean_heat_q16(obs[i].frame.heat), .boundary_switch_load_q16(obs[i].frame.load_word),
            .boundary_retained_state_q(obs[i].frame.retained), .boundary_pending_route_q(obs[i].frame.pending)
        );
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_suffix <= 0;
            first_suffix_cross <= 0;
        end else if (clear_epoch) begin
            in_suffix <= 0;
            first_suffix_cross <= 0;
        end else begin
            in_suffix <= to_suffix;
            if (take[2] && !suffix.seen)
                first_suffix_cross <= (stability_margin_q16 <= 0);
        end
    end

    // Equal extrema belong to the earlier segment, regardless of source_tick.
    wire use_low = prefix.seen && (!suffix.seen || prefix.low <= suffix.low);
    wire use_high = prefix.seen && (!suffix.seen || prefix.high >= suffix.high);
    wire [COUNT_BITS:0] total = {1'b0, prefix.count} + {1'b0, suffix.count};
    wire carry = total[COUNT_BITS];
    // On a first-suffix crossing, restore the last positive margin of the prefix.
    wire bridge = !prefix.valid && prefix.seen && first_suffix_cross;
    wire signed [31:0] before_cross = prefix.valid ? prefix.before_cross :
                                     bridge ? prefix.last_margin : suffix.before_cross;
    logic sampled = 0;
    always_ff @(posedge clk) sampled <= 1;
    always_comb if (!sampled) assume (!rst_n);

    for (genvar i = 0; i < 3; i++) begin : invariants
        always_comb if (sampled) begin
            a_empty: assert (obs[i].seen || obs[i] == EMPTY);
            a_positive: assert (obs[i].valid || obs[i].last_margin > 0);
            a_overflow: assert (!obs[i].overflow || (&obs[i].count));
        end
    end
    always_comb if (sampled) begin
        a_split: assert (in_suffix || !suffix.seen);
        a_first: assert (!first_suffix_cross || suffix.valid);
        a_seen: assert (whole.seen == (prefix.seen || suffix.seen));
        a_count: assert (whole.count == (carry ? {COUNT_BITS{1'b1}} : total[COUNT_BITS-1:0]));
        a_carry: assert (whole.overflow == (prefix.overflow || suffix.overflow || carry));
        a_last: assert (whole.last_margin == (suffix.seen ? suffix.last_margin : prefix.last_margin));
        a_min: assert ({whole.low, whole.low_tick} ==
                       (use_low ? {prefix.low, prefix.low_tick} : {suffix.low, suffix.low_tick}));
        a_max: assert ({whole.high, whole.high_tick} ==
                       (use_high ? {prefix.high, prefix.high_tick} : {suffix.high, suffix.high_tick}));
        a_valid: assert (whole.valid == (prefix.valid || suffix.valid));
        a_pulse: assert (whole.pulse == (prefix.pulse || (!prefix.valid && suffix.pulse)));
        a_frame: assert (whole.frame == (prefix.valid ? prefix.frame : suffix.frame));
        a_previous_cross: assert (whole.before_cross == before_cross);
    end

    wire both = prefix.seen && suffix.seen;
    always_comb begin
        reach = '0;
        if (sampled && rst_n) begin
            reach[0] = bridge && suffix.pulse && prefix.last_margin != INITIAL_MARGIN;
            reach[1] = prefix.valid && suffix.pulse && prefix.frame != suffix.frame;
            reach[2] = both && prefix.low == suffix.low && prefix.low_tick > suffix.low_tick;
            reach[3] = both && prefix.high == suffix.high && prefix.high_tick > suffix.high_tick;
            reach[4] = both && prefix.low < suffix.low && prefix.high < suffix.high;
            reach[5] = both && suffix.low < prefix.low && suffix.high < prefix.high;
            reach[6] = both && clear_epoch && sample_valid && split;
            reach[7] = in_suffix && !prefix.seen && suffix.pulse;
            reach[8] = !first_suffix_cross && !prefix.valid && suffix.pulse && both;
            if (COUNT_BITS <= 3)
                reach[9] = both && carry && !prefix.overflow && !suffix.overflow;
            else
                reach[9] = both && prefix.low == 32'sh80000000 && suffix.high == 32'sh7fffffff;
        end
    end
    for (genvar k = 0; k < 10; k++) begin : witnesses
        always_comb cover (reach[k]);
    end
endmodule

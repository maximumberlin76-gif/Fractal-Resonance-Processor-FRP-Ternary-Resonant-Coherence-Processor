// Atomic capture, whole-bank rejection, reset and saturating event counts.
// Sampled rising edges; only the initial reset is constrained.
`timescale 1ns/1ps
`include "frp_m32_registered_target_boundary.sv"

module frp_m32_target_bank_atomicity_formal #(
    parameter int CELLS = 8,
    parameter int COUNTER_BITS = 32
) (
    input logic clk, rst_n, tick_enable, clear_counters, phase_target_valid,
    input logic [2*CELLS-1:0] phase_target,
    output logic [15:0] reach
);
    typedef logic [2*CELLS-1:0] bank_t;
    typedef logic [COUNTER_BITS-1:0] count_t;
    localparam count_t LIMIT = '1;
    localparam logic [CELLS-1:0] FIRST = 1;
    localparam logic [CELLS-1:0] LAST = FIRST << (CELLS-1);

    wire bank_t stored;
    wire stored_valid, input_legal, stored_legal, accepted, rejected;
    wire count_t accepts, rejects;

    frp_m32_registered_target_boundary #(.CELLS(CELLS), .COUNTER_BITS(COUNTER_BITS)) dut (
        .clk, .rst_n, .tick_enable, .clear_counters, .phase_target_valid, .phase_target,
        .registered_target_q(stored), .registered_target_valid_q(stored_valid),
        .phase_target_domain_valid(input_legal), .registered_target_domain_valid(stored_legal),
        .capture_accepted(accepted), .capture_rejected(rejected),
        .accepted_capture_events_q(accepts), .rejected_capture_events_q(rejects)
    );

    // NEG=11, active neutral=00, POS=01. Only the code 10 vetoes a bank.
    function automatic logic [CELLS-1:0] reserved(input bank_t bank);
        for (int i = 0; i < CELLS; i++)
            reserved[i] = bank[2*i+1] & ~bank[2*i];
    endfunction

    wire [CELLS-1:0] bad = reserved(phase_target);
    wire offered = tick_enable && phase_target_valid;
    wire take = offered && bad == '0;
    wire veto = offered && bad != '0;

    function automatic count_t next_count(input count_t current, input logic event_in);
        logic [COUNTER_BITS:0] sum;
        sum = {1'b0, current} + {{COUNTER_BITS{1'b0}}, event_in};
        return sum[COUNTER_BITS] ? LIMIT : sum[COUNTER_BITS-1:0];
    endfunction

    logic started = 1'b0;
    always @(posedge clk) started <= 1'b1;
    always_comb if (!started) assume (!rst_n);

    bank_t expected_bank;
    count_t expected_accepts, expected_rejects;
    logic expected_valid;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            expected_bank <= '0;
            expected_valid <= 1'b0;
            expected_accepts <= '0;
            expected_rejects <= '0;
        end else begin
            if (take) expected_bank <= phase_target;
            expected_valid <= expected_valid || take;
            expected_accepts <= clear_counters ? '0 : next_count(accepts, take);
            expected_rejects <= clear_counters ? '0 : next_count(rejects, veto);
        end
    end

    always_comb begin
        a_input_domain: assert (input_legal == (bad == '0));
        a_stored_domain: assert (stored_legal == (reserved(stored) == '0));
        a_accept: assert (accepted == take);
        a_reject: assert (rejected == veto);
        if (started) begin
            a_atomic_bank: assert (stored == expected_bank);
            a_valid: assert (stored_valid == expected_valid);
            a_legal_bank: assert (stored_legal);
            a_accept_count: assert (accepts == expected_accepts);
            a_reject_count: assert (rejects == expected_rejects);
        end
    end

    // Sample completed events. Witnesses describe the resulting register state.
    logic was_take, was_veto, was_clear, was_pause, was_invalid;
    logic prior_veto, was_valid, was_live;
    bank_t prior_bank, prior_input;
    logic [CELLS-1:0] prior_bad;
    count_t prior_accepts, prior_rejects;
    always_ff @(posedge clk) begin
        was_live <= rst_n;
        was_take <= rst_n && take;
        was_veto <= rst_n && veto;
        prior_veto <= was_veto;
        was_clear <= clear_counters;
        was_pause <= !tick_enable && phase_target_valid;
        was_invalid <= tick_enable && !phase_target_valid;
        was_valid <= stored_valid;
        prior_bank <= stored;
        prior_input <= phase_target;
        prior_bad <= bad;
        prior_accepts <= accepts;
        prior_rejects <= rejects;
    end

    wire live = started && was_live && rst_n;
    wire held = stored == prior_bank && stored_valid == was_valid;
    wire changed = stored != prior_bank;
    wire captured = stored_valid && stored == prior_input;
    wire rejected_change = was_veto && was_valid && held && prior_input != prior_bank;

    // A legal middle lane requests a change while a different lane vetoes it.
    localparam int MIDDLE = CELLS / 2;
    wire middle_change = prior_input[2*MIDDLE +: 2] != prior_bank[2*MIDDLE +: 2];

    always_comb begin
        reach = '0;
        if (live) begin
            reach[0] = was_take && !was_valid && captured && stored == '0;
            reach[1] = was_take && was_valid && captured && changed
                       && stored[1:0] == 2'b11 && stored[2*CELLS-1 -: 2] == 2'b01;
            reach[2] = rejected_change && middle_change && prior_bad == FIRST;
            reach[3] = rejected_change && middle_change && prior_bad == LAST;
            reach[4] = rejected_change && middle_change && prior_bad == (FIRST | LAST);
            reach[5] = was_take && prior_veto && captured && changed;
            reach[6] = was_veto && prior_veto && was_valid && held;
            reach[7] = was_pause && was_valid && held && prior_input != prior_bank;
            reach[8] = was_invalid && was_valid && held && prior_input != prior_bank;
            reach[9] = was_clear && was_take && captured && changed
                       && prior_accepts != 0 && accepts == 0 && rejects == 0;
            reach[10] = was_clear && rejected_change && prior_rejects != 0
                        && accepts == 0 && rejects == 0;
            reach[11] = was_take && captured && changed && stored == '0;
            if (COUNTER_BITS <= 3) begin
                reach[12] = !was_clear && was_take && prior_accepts == LIMIT
                            && accepts == LIMIT && changed;
                reach[13] = !was_clear && rejected_change && prior_rejects == LIMIT
                            && rejects == LIMIT;
                reach[14] = was_clear && prior_accepts == LIMIT && prior_rejects == LIMIT
                            && accepts == 0 && rejects == 0 && was_valid;
            end
        end
        reach[15] = started && was_live && !rst_n && was_valid &&
                    !stored_valid && stored == '0 && accepts == 0 && rejects == 0;
    end
    for (genvar i = 0; i < 16; i++) begin : g_witness
        if (i < 12 || i == 15 || COUNTER_BITS <= 3) begin : g_enabled
            always_comb c_event: cover (reach[i]);
        end
    end
endmodule

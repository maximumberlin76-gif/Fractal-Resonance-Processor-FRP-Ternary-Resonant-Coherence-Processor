// M31 retained-state writeback, sampled on rising edges.
// The initial reset establishes active neutral in every cell.
`timescale 1ns/1ps
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_WRITEBACK_MATRIX_NETLIST
`include "frp_m31_state_update.sv"
`endif

module frp_m31_writeback_transition_matrix_formal #(
    parameter int CELLS = 8
) (
    input logic clk, rst_n, tick_enable,
    input logic [2:0] scheduler_code,
    input logic [2*CELLS-1:0] candidate,
    input logic [CELLS-1:0] capacity, accepted, neutral_route, completion,
    input logic [CELLS-1:0] reserved_fault, direct_fault,
    output logic [17:0] reach
);
    localparam logic [1:0] ZERO = 2'b00, POS = 2'b01, NEG = 2'b11, BAD = 2'b10;
    localparam int LAST = CELLS-1, MID = CELLS/2;
    typedef logic [2*CELLS-1:0] bank_t;
    wire bank_t stored, preview, visible;
    wire [CELLS-1:0] writes, holds, resets, reserved_mask;

`ifdef FRP_M31_WRITEBACK_MATRIX_NETLIST
    frp_m31_writeback_matrix_netlist dut (
`else
    frp_m31_state_update #(.CELLS(CELLS), .STATE_BITS(2), .COUNTER_BITS(32)) dut (
`endif
        .clk, .rst_n, .tick_enable,
        .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_code)),
        .state_candidate_d(candidate), .capacity_accept_mask(capacity),
        .accepted_change_candidate_mask(accepted), .neutral_routed_mask(neutral_route),
        .pending_completion_mask(completion), .reserved_transition_mask(reserved_fault),
        .actual_direct_mask(direct_fault), .state_q(stored), .state_d(preview),
        .state_out(visible), .state_write_enable_mask(writes), .state_hold_mask(holds),
        .state_reset_mask(resets), .state_reserved_mask(reserved_mask)
    );

    wire may_release = scheduler_code == 0 || scheduler_code == 2 || scheduler_code == 3;
    wire may_neutralize = scheduler_code == 0 || scheduler_code == 1 || scheduler_code == 4;
    wire [CELLS-1:0] eligible, reserved_input, illegal_state, direct_step;
    wire bank_t expected;
    for (genvar i = 0; i < CELLS; i++) begin : g_oracle
        wire [1:0] q = stored[2*i +: 2];
        wire [1:0] target = candidate[2*i +: 2];
        wire leave_zero = q == ZERO && target[0] && may_release && !neutral_route[i];
        wire enter_zero = q[0] && target == ZERO && may_neutralize && !completion[i];
        assign eligible[i] = rst_n && tick_enable && capacity[i] && accepted[i]
                             && !reserved_fault[i] && !direct_fault[i] && (leave_zero || enter_zero);
        assign expected[2*i +: 2] = !rst_n ? ZERO : (eligible[i] ? target : q);
        assign reserved_input[i] = rst_n && (q == BAD || target == BAD || reserved_fault[i]);
        assign illegal_state[i] = q == BAD;
        wire [1:0] next_q = preview[2*i +: 2];
        assign direct_step[i] = q[0] && next_q[0] && q != next_q;
    end

    logic started = 1'b0;
    bank_t sampled_expected;
    always @(posedge clk) started <= 1'b1;
    always_comb if (!started) assume (!rst_n);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sampled_expected <= '0;
        else sampled_expected <= expected;
    end

    always_comb begin
        a_preview: assert (preview == expected);
        a_writes: assert (writes == eligible);
        a_holds: assert (holds == ({CELLS{rst_n}} & ~eligible));
        a_resets: assert (resets == {CELLS{!rst_n}});
        a_reserved: assert (reserved_mask == reserved_input);
        a_no_direct: assert (direct_step == '0);
        a_visible: assert (visible == stored);
        if (started) begin
            a_register: assert (stored == sampled_expected);
            a_domain: assert (illegal_state == '0);
        end
    end

    wire [1:0] q_last = stored[2*LAST +: 2];
    wire [1:0] t_last = candidate[2*LAST +: 2];
    logic [1:0] departed;
    logic paused_at_zero, completed_pos, completed_neg;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            departed <= ZERO;
            paused_at_zero <= 0;
            completed_pos <= 0;
            completed_neg <= 0;
        end else begin
            completed_pos <= paused_at_zero && departed == NEG && q_last == ZERO
                             && completion[LAST] && writes[LAST] && t_last == POS;
            completed_neg <= paused_at_zero && departed == POS && q_last == ZERO
                             && completion[LAST] && writes[LAST] && t_last == NEG;
            if (writes[LAST]) begin
                departed <= neutral_route[LAST] && t_last == ZERO ? q_last : ZERO;
                paused_at_zero <= 0;
            end else if (!tick_enable && departed[0] && q_last == ZERO)
                paused_at_zero <= 1;
        end
    end

    wire live = started && rst_n;
    wire route_tag = neutral_route[LAST] || completion[LAST];
    wire grants = capacity[LAST] && accepted[LAST];
    wire clean = !reserved_fault[LAST] && !direct_fault[LAST];
    wire release_case = q_last == ZERO && t_last[0] && may_release;
    wire blocked = tick_enable && !writes[LAST] && holds[LAST];

    always_comb begin
        reach = '0;
        if (live) begin
            reach[0] = completed_pos && q_last == POS;
            reach[1] = completed_neg && q_last == NEG;
            reach[2] = blocked && clean && grants && !route_tag && scheduler_code == 0
                       && q_last == NEG && t_last == POS;
            reach[3] = blocked && clean && grants && !route_tag && scheduler_code == 0
                       && q_last == POS && t_last == NEG;
            reach[4] = blocked && clean && grants && !route_tag && t_last == BAD
                       && reserved_mask[LAST] && writes[0];
            reach[5] = blocked && clean && grants && neutral_route[LAST] && completion[LAST]
                       && release_case && writes[0];
            reach[6] = blocked && clean && !route_tag && !capacity[LAST] && accepted[LAST]
                       && release_case && writes[0];
            reach[7] = blocked && clean && !route_tag && capacity[LAST] && !accepted[LAST]
                       && release_case && writes[0];
            reach[8] = blocked && grants && !route_tag && release_case && reserved_fault[LAST]
                       && !direct_fault[LAST] && reserved_mask[LAST] && writes[0];
            reach[9] = blocked && grants && !route_tag && release_case && direct_fault[LAST]
                       && !reserved_fault[LAST] && !reserved_mask[LAST] && writes[0];
            reach[10] = scheduler_code == 1 && writes[LAST] && neutral_route[LAST];
            reach[11] = scheduler_code == 4 && writes[LAST] && neutral_route[LAST];
            reach[12] = scheduler_code == 2 && writes[LAST] && completion[LAST];
            reach[13] = scheduler_code == 3 && writes[LAST] && completion[LAST];
            reach[14] = scheduler_code >= 5 && blocked && clean && grants && !route_tag
                        && q_last == ZERO && t_last[0] && writes == '0;
            reach[15] = !tick_enable && q_last[0] && t_last == ZERO && clean && grants
                        && may_neutralize && !route_tag && preview == stored;
            reach[16] = scheduler_code == 0 && writes[0] && completion[0]
                        && writes[MID] && neutral_route[MID] && holds[LAST] && t_last == BAD;
            reach[17] = writes[LAST] && !route_tag && q_last == ZERO && t_last == NEG;
        end
    end
    for (genvar bit_id = 0; bit_id < 18; bit_id++) begin : g_cover
        always_comb c_reach: cover (reach[bit_id]);
    end
endmodule

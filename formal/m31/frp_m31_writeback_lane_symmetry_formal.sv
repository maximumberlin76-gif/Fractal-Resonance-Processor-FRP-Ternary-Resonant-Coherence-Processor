// Relational check of M31 writeback at rising-edge samples after initial reset.
// Metadata planes from low to high: capacity, accepted, neutral route,
// pending completion, reserved fault, direct fault. Cover scenarios use CELLS >= 3.
`timescale 1ns/1ps
`include "frp_m31_pkg.sv"
`ifndef FRP_M31_LANE_SYMMETRY_NETLIST
`include "frp_m31_state_update.sv"
`endif

module frp_m31_writeback_lane_symmetry_formal #(
    parameter int CELLS = 8
) (
    input logic clk, rst_n, tick_enable,
    input logic [2:0] scheduler_code,
    input logic [CELLS-1:0] select_cells, select_reverse,
    input logic [2*CELLS-1:0] candidate_a, free_candidate_b,
    input logic [6*CELLS-1:0] meta_a, free_meta_b,
    output logic [11:0] reach
);
    typedef logic [CELLS-1:0] mask_t;
    typedef logic [2*CELLS-1:0] bank_t;
    localparam int LAST = CELLS-1, MID = CELLS/2;
    localparam logic [1:0] ZERO = 2'b00, POS = 2'b01, NEG = 2'b11, BAD = 2'b10;

    logic ready = 1'b0;
    mask_t watched, reverse_sign;
    always @(posedge clk) begin
        if (!ready) begin
            watched <= select_cells;
            reverse_sign <= select_reverse;
        end
        ready <= 1'b1;
    end
    always_comb if (!ready) assume (!rst_n);

    function automatic bank_t reflect(input bank_t word, input mask_t reverse_mask);
        bank_t result;
        result = word;
        for (int i = 0; i < CELLS; i++)
            if (reverse_mask[i] && word[2*i])
                result[2*i+1] = ~word[2*i+1];
        return result;
    endfunction

    wire bank_t watched_bits;
    for (genvar i = 0; i < CELLS; i++) begin : g_mask
        assign watched_bits[2*i +: 2] = {2{watched[i]}};
    end
    wire bank_t candidate_b = (reflect(candidate_a, reverse_sign) & watched_bits)
                              | (free_candidate_b & ~watched_bits);
    wire [6*CELLS-1:0] meta_b = (meta_a & {6{watched}}) | (free_meta_b & ~{6{watched}});

    wire bank_t stored[2], preview[2], visible[2];
    wire mask_t writes[2], holds[2], resets[2], reserved[2];
    for (genvar side = 0; side < 2; side++) begin : g_bank
        wire bank_t target = side == 0 ? candidate_a : candidate_b;
        wire [6*CELLS-1:0] m = side == 0 ? meta_a : meta_b;
`ifdef FRP_M31_LANE_SYMMETRY_NETLIST
        frp_m31_lane_symmetry_netlist dut (
`else
        frp_m31_state_update #(.CELLS(CELLS), .STATE_BITS(2), .COUNTER_BITS(32)) dut (
`endif
            .clk, .rst_n, .tick_enable,
            .scheduler_state(frp_m31_pkg::frp_m31_scheduler_state_e'(scheduler_code)),
            .state_candidate_d(target), .capacity_accept_mask(m[0*CELLS +: CELLS]),
            .accepted_change_candidate_mask(m[1*CELLS +: CELLS]),
            .neutral_routed_mask(m[2*CELLS +: CELLS]),
            .pending_completion_mask(m[3*CELLS +: CELLS]),
            .reserved_transition_mask(m[4*CELLS +: CELLS]),
            .actual_direct_mask(m[5*CELLS +: CELLS]),
            .state_q(stored[side]), .state_d(preview[side]), .state_out(visible[side]),
            .state_write_enable_mask(writes[side]), .state_hold_mask(holds[side]),
            .state_reset_mask(resets[side]), .state_reserved_mask(reserved[side])
        );
    end

    always_comb if (ready) begin
        a_stored:   assert (((reflect(stored[0], reverse_sign) ^ stored[1]) & watched_bits) == '0);
        a_preview:  assert (((reflect(preview[0], reverse_sign) ^ preview[1]) & watched_bits) == '0);
        a_visible:  assert (((reflect(visible[0], reverse_sign) ^ visible[1]) & watched_bits) == '0);
        a_write:    assert (((writes[0] ^ writes[1]) & watched) == '0);
        a_hold:     assert (((holds[0] ^ holds[1]) & watched) == '0);
        a_reset:    assert (((resets[0] ^ resets[1]) & watched) == '0);
        a_reserved: assert (((reserved[0] ^ reserved[1]) & watched) == '0);
    end

    wire mixed = ready && watched[0] && !reverse_sign[0]
                 && watched[LAST] && reverse_sign[LAST] && !watched[MID];
    wire live = mixed && rst_n;
    wire [1:0] qa = stored[0][2*LAST +: 2], qb = stored[1][2*LAST +: 2];
    wire [1:0] da = preview[0][2*LAST +: 2], db = preview[1][2*LAST +: 2];
    wire [1:0] target = candidate_a[2*LAST +: 2];
    wire both_write = writes[0][LAST] && writes[1][LAST];
    wire both_hold = holds[0][LAST] && holds[1][LAST];
    wire middle_diff = stored[0][2*MID +: 2] != stored[1][2*MID +: 2];
    wire middle_write_diff = writes[0][MID] != writes[1][MID];
    wire route = meta_a[2*CELLS+LAST], complete = meta_a[3*CELLS+LAST];
    logic previously_split = 1'b0;
    always @(posedge clk)
        previously_split <= live && middle_diff && qa == POS && qb == NEG;

    always_comb begin
        reach = '0;
        reach[0] = live && both_write && da == POS && db == NEG && middle_write_diff;
        reach[1] = live && both_write && da == NEG && db == POS && middle_write_diff;
        reach[2] = live && route && both_write && qa == POS && qb == NEG && da == ZERO && db == ZERO;
        reach[3] = live && complete && both_write && qa == ZERO && qb == ZERO && da == NEG && db == POS;
        reach[4] = live && !tick_enable && middle_diff && qa == NEG && qb == POS && both_hold;
        reach[5] = live && tick_enable && qa == NEG && qb == POS && target == POS
                   && scheduler_code == 0 && meta_a[LAST] && meta_a[CELLS+LAST]
                   && !route && !complete && !meta_a[4*CELLS+LAST] && !meta_a[5*CELLS+LAST]
                   && both_hold && middle_write_diff;
        reach[6] = live && tick_enable && route && complete && qa == ZERO && target == POS
                   && scheduler_code == 0 && meta_a[LAST] && meta_a[CELLS+LAST]
                   && !meta_a[4*CELLS+LAST] && !meta_a[5*CELLS+LAST] && both_hold;
        reach[7] = live && tick_enable && target == BAD && !meta_a[4*CELLS+LAST]
                   && reserved[0][LAST] && reserved[1][LAST] && both_hold && middle_write_diff;
        reach[8] = mixed && !rst_n && previously_split && stored[0] == '0 && stored[1] == '0
                   && resets[0] == '1 && resets[1] == '1;
        reach[9] = live && both_write && da == POS && db == NEG && writes[0][0] && writes[1][0]
                   && preview[0][1:0] == NEG && preview[1][1:0] == NEG && middle_write_diff;
        reach[10] = live && qa == ZERO && qb == ZERO && middle_diff && both_hold
                    && stored[0][1:0] == POS && stored[1][1:0] == POS;
        reach[11] = ready && rst_n && watched == '1 && reverse_sign == '1
                    && qa == NEG && qb == POS && stored[0][1:0] == POS && stored[1][1:0] == NEG;
    end
    for (genvar c = 0; c < 12; c++) begin : g_cover
        always_comb c_reach: cover (reach[c]);
    end
endmodule

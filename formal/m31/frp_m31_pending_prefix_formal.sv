// SPDX-License-Identifier: Apache-2.0
// Verify occupancy and saved destinations at the public M31 execution boundary.
// Reference grants consume available slots in ascending address order.
// The second top proves the address-prefix arithmetic independently.
`include "frp_m31_execution_core.sv"

module frp_m31_pending_prefix_formal #(
    parameter int CELLS = 16,
    parameter int LANES = 4,
    localparam int IW = $clog2(CELLS)
) (
    input logic clk, rst_n, tick_enable, clear_counters,
    input logic [1:0] scheduler_mode,
    input logic [LANES-1:0] request_valid,
    input logic [IW*LANES-1:0] request_cell_index,
    input logic [2*LANES-1:0] request_target,
    input logic [2*CELLS-1:0] target_q,
    output wire [CELLS-1:0] born, grant, waiting
);
    import frp_m31_pkg::*;
    wire [2*CELLS-1:0] state_q, pending_q;
    frp_m31_scheduler_state_e phase;
    frp_m31_execution_core #(
        .CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(IW)
    ) dut (
        .clk, .rst_n, .tick_enable, .clear_counters,
        .scheduler_mode(frp_m31_scheduler_mode_e'(scheduler_mode)),
        .request_valid, .request_cell_index, .request_target, .target_q,
        .state_out(state_q), .pending_route_out(pending_q),
        .neutral_routed_cell_mask(born), .scheduler_state_q(phase)
    );

    initial begin
        a_profile: assert (CELLS >= 2 && CELLS <= 64 && LANES >= 1 && LANES <= CELLS);
    end

    wire service = tick_enable && (phase == FRP_SCHED_FREE ||
        phase == FRP_SCHED_COMMIT || phase == FRP_SCHED_EXCITE);
    wire [LANES-1:0] slots [0:CELLS];
    assign slots[0] = {LANES{service}};

    logic sampled = 0;
    always @(posedge clk) sampled <= 1;
    always_comb if (!sampled) a_reset: assume (!rst_n);

    for (genvar i=0; i<CELLS; i++) begin : cell_rule
        wire [1:0] p = pending_q[2*i+:2], s = state_q[2*i+:2];
        assign waiting[i] = p[0];
        assign grant[i] = waiting[i] && slots[i][0];
        assign slots[i+1] = waiting[i] ? (slots[i] >> 1) : slots[i];

        logic checked, expect_pending, check_target, was_granted;
        logic [1:0] destination;
        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                checked <= 0;
                expect_pending <= 0;
                check_target <= 0;
                was_granted <= 0;
                destination <= 0;
            end else begin
                checked <= 1;
                expect_pending <= (waiting[i] && !grant[i]) || born[i];
                check_target <= waiting[i];
                was_granted <= grant[i];
                destination <= p;
            end
        end

        always_comb if (sampled && rst_n) begin
            a_domain: assert (s != 2'b10 && p != 2'b10 && (!waiting[i] || s == 0));
            a_disjoint: assert (!(waiting[i] && born[i]));
            if (checked) begin
                a_occupancy: assert (waiting[i] == expect_pending);
                if (check_target && was_granted)
                    a_release: assert (s == destination && p == 0);
                if (check_target && !was_granted)
                    a_retain: assert (p == destination && s == 0);
            end
        end
    end
endmodule

// Extend an address prefix by one cell. Width includes the sum of two counts.
module frp_m31_pending_prefix_arithmetic_formal #(
    parameter int CELLS = 16,
    parameter int LANES = 4,
    localparam int WIDTH = $clog2(2*CELLS + 1)
) (
    input logic [WIDTH-1:0] pending_before, births_before,
    input logic service, occupied, birth
);
    typedef logic [WIDTH-1:0] count_t;
    localparam count_t LIMIT = count_t'(LANES);
    localparam logic [LANES-1:0] FULL = '1;

    function automatic count_t removed(input count_t pending, input logic enabled);
        return enabled ? ((pending < LIMIT) ? pending : LIMIT) : '0;
    endfunction

    wire [LANES-1:0] slots = service ? FULL >> pending_before : '0;
    wire [LANES-1:0] slots_after = occupied ? slots >> 1 : slots;
    wire next_occupied = (occupied && !slots[0]) || birth;
    wire [WIDTH-1:0] pending_after = pending_before + count_t'(occupied);
    wire [WIDTH-1:0] births_after = births_before + count_t'(birth);
    wire [WIDTH-1:0] old_prefix_next =
        pending_before - removed(pending_before, service) + births_before;

    initial begin
        a_profile: assert (CELLS >= 2 && CELLS <= 64 && LANES >= 1 && LANES <= CELLS);
    end

    // A pending cell cannot also be a new route on this edge (a_disjoint).
    // Each shorter prefix therefore has at most one pending or birth per cell.
    always_comb begin
        if (pending_before == 0 && births_before == 0) begin
            a_empty: assert (old_prefix_next == 0);
            a_initial_slots: assert (slots == (service ? FULL : '0));
        end
        if (pending_before < CELLS && births_before < CELLS &&
            pending_before + births_before < CELLS && !(occupied && birth)) begin
            a_slot: assert (slots[0] == (service && pending_before < LIMIT));
            a_shift: assert (slots_after == (service ? FULL >> pending_after : '0));
            a_sum: assert (old_prefix_next + count_t'(next_occupied) ==
                pending_after - removed(pending_after, service) + births_after);
        end
    end
endmodule

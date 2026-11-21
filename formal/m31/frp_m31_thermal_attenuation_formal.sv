// Formal contract for the M31 thermal attenuator instantiated by M32.
// PROBE_LANE = -1 enables every lane. A fixed index selects a proof partition.
`include "frp_m31_local_thermal_attenuation.sv"

module frp_m31_thermal_attenuation_formal #(
    parameter int CELLS = 8,
    parameter int PROBE_LANE = -1
) (
    input logic clk, rst_n, tick_enable,
    input logic [32*CELLS-1:0] thermal_overload_q16,
    input logic [11:0] rom_probe
);
    localparam logic [31:0] UNITY_Q30 = 32'd1073741824;
    localparam logic [31:0] FLOOR_Q30 = 32'd360200;
    typedef logic [4095:0][31:0] rom_image_t;

    // round(2^62 * exp(-8/4095)). Each Q62 step and Q30 output
    // is rounded separately. Index zero represents exp(0).
    function automatic rom_image_t reference_table();
        logic [63:0] value_q62;
        logic [127:0] product;
        value_q62 = 64'd1 << 62;
        for (int i = 0; i < 4096; i++) begin
            reference_table[i] = 32'((value_q62 + (64'd1 << 31)) >> 32);
            product = value_q62 * 64'h3fe005ff8aab559c;
            value_q62 = 64'((product + (128'd1 << 61)) >> 62);
        end
    endfunction
    localparam rom_image_t EXPECTED_ROM = reference_table();

    // The first positive overload that rounds to the upper clip is 419430.
    function automatic logic [31:0] reference_clip(input logic signed [31:0] load);
        if (load <= 0) return 32'd0;
        if (load >= 32'sd419430) return 32'd524288;
        return (32'd5 * $unsigned(load) + 32'd2) >> 2;
    endfunction

    wire [32*CELLS-1:0] factor_bank, preview_bank;
    frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) dut (
        .clk, .rst_n, .tick_enable, .thermal_overload_q16,
        .thermal_node_factor_q30(factor_bank),
        .next_thermal_node_factor_q30(preview_bank)
    );

    if (CELLS < 1 || PROBE_LANE < -1 || PROBE_LANE >= CELLS) begin : g_invalid
        initial $fatal(1, "Invalid CELLS or PROBE_LANE");
    end

    // rom_probe is a free input over every address, including page seams.
    always @(posedge clk) begin
        a_rom_word: assert (dut.exp_rom[rom_probe] == EXPECTED_ROM[rom_probe]);
        if (rom_probe != 12'hfff)
            a_rom_descends: assert (dut.exp_rom[rom_probe] >
                                    dut.exp_rom[rom_probe + 12'd1]);
    end

    typedef enum logic [1:0] {RESET, HOLD, COMMIT} event_t;
    for (genvar i = 0; i < CELLS; i++) begin : g_lane
        if (PROBE_LANE == -1 || PROBE_LANE == i) begin : g_check
            wire signed [31:0] load = thermal_overload_q16[32*i +: 32];
            wire [31:0] factor = factor_bank[32*i +: 32];
            wire [31:0] preview = preview_bank[32*i +: 32];
            wire [11:0] address = dut.g_cell[i].rom_address;
            wire [31:0] clipped = reference_clip(load);

            // The chosen bin contains 4095*clipped + half a bin.
            wire [31:0] weighted = (clipped << 12) - clipped + 32'd262144;
            wire [31:0] lower = {1'b0, address, 19'b0};

            logic sampled = 1'b0;
            event_t last_event;
            logic [31:0] old_factor, old_preview;
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    sampled <= 1'b1;
                    last_event <= RESET;
                    old_factor <= '0;
                    old_preview <= '0;
                end else begin
                    sampled <= 1'b1;
                    last_event <= tick_enable ? COMMIT : HOLD;
                    old_factor <= factor;
                    old_preview <= preview;
                end
            end

            always @(posedge clk) begin
                a_clip: assert (dut.g_cell[i].clipped_arg_q16 == clipped);
                a_bin: assert (weighted >= lower && weighted - lower < 32'd524288);
                a_lookup: assert (preview == dut.exp_rom[address]);
                a_range: assert (preview >= FLOOR_Q30 && preview <= UNITY_Q30);
                if (sampled) begin
                    case (last_event)
                        RESET:  a_reset:  assert (factor == UNITY_Q30);
                        HOLD:   a_hold:   assert (factor == old_factor);
                        COMMIT: a_commit: assert (factor == old_preview);
                        default: a_event: assert (1'b0);
                    endcase
                end

                c_min: cover (load == 32'sh80000000 && preview == UNITY_Q30);
                c_max: cover (load == 32'sh7fffffff && preview == FLOOR_Q30);
                c_half: cover (load == 32'sd2 && clipped == 32'd3);
                c_clip_edge: cover (load == 32'sd419429 && clipped == 32'd524286);
                c_upper_clip: cover (load == 32'sd419430 && clipped == 32'd524288);
                c_hold_change: cover (rst_n && sampled && last_event == HOLD &&
                                      factor == old_factor && preview != factor);
                c_commit_change: cover (rst_n && sampled && last_event == COMMIT &&
                                        factor == old_preview && factor != old_factor);
                c_reset_release: cover (rst_n && tick_enable && sampled &&
                                        last_event == RESET && preview != factor);
            end
        end
    end
endmodule

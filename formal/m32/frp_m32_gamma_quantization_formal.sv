`timescale 1ns/1ps

module frp_m32_gamma_quantization_formal #(
  parameter int CELLS = 8
) (
  input logic [26:0]           high27,
  input logic [31:0]           second_word,
  input logic [$clog2(CELLS)-1:0] lane,
  input logic [32*CELLS-1:0]   pending,
  input logic [52:0]           fraction,
  input logic signed [31:0]    target,
  input logic [32*CELLS-1:0]   completed,
  output wire [9:0]            reach
);
  localparam logic [52:0] MID  = 53'd1 << 52;
  localparam logic [35:0] HALF = 36'd1 << 35;
  localparam logic [52:0] HALF53 = {17'd0, HALF};

  // Floor and remainder of (raw - 2^52) / 2^36.
  // At an exact half, increment the floor only on the positive side.
  wire [52:0] raw = {high27, second_word[31:6]};
  wire [35:0] residue = raw[35:0];
  wire signed [31:0] floor_q16 =
      $signed({15'd0, raw[52:36]}) - 32'sd65536;
  wire round_up = (residue > HALF) || ((residue == HALF) && raw[52]);
  wire signed [31:0] expected = floor_q16 + (round_up ? 32'sd1 : 32'sd0);

  always_comb begin
    assert (fraction == raw);
    assert (target == expected);
    assert (target >= -32'sd65536 && target <= 32'sd65536);
    assert ((target == 0) == (raw > MID - HALF53 && raw < MID + HALF53));
    if (residue == HALF && !raw[52]) assert (target == floor_q16);
    if (residue == HALF &&  raw[52]) assert (target == floor_q16 + 32'sd1);
  end

  for (genvar i = 0; i < CELLS; i++) begin : check_lane
    wire [31:0] old_word = pending[32*i +: 32];
    wire [31:0] new_word = completed[32*i +: 32];
    always_comb begin
      if (lane == i) assert (new_word == target);
      else           assert (new_word == old_word);
    end
  end

  // Witnesses include both central ties and the immediately adjacent zeroes.
  assign reach[0] = raw == '0 && target == -32'sd65536;
  assign reach[1] = (&raw) && target == 32'sd65536;
  assign reach[2] = raw == MID - HALF53 && target == -32'sd1;
  assign reach[3] = raw == MID - HALF53 + 53'd1 && target == 0;
  assign reach[4] = raw == MID && target == 0;
  assign reach[5] = raw == MID + HALF53 - 53'd1 && target == 0;
  assign reach[6] = raw == MID + HALF53 && target == 32'sd1;
  assign reach[7] = lane == 0 && pending[31:0] != completed[31:0];
  assign reach[8] = lane == CELLS-1 &&
                    pending[32*(CELLS-1) +: 32] != completed[32*(CELLS-1) +: 32];
  assign reach[9] = lane == CELLS/2 && pending == completed && target != 0;

  for (genvar k = 0; k < 10; k++) begin : cover_witness
    always_comb cover (reach[k]);
  end
endmodule

bind frp_m32_gamma_target_source frp_m32_gamma_quantization_formal #(
  .CELLS($bits(completed_bank) / 32)
) gamma_quantization_check (
  .high27(fraction_high_q),
  .second_word(tempered_word),
  .lane(lane_q),
  .pending(pending_bank_q),
  .fraction(random_fraction),
  .target(target_word),
  .completed(completed_bank),
  .reach()
);

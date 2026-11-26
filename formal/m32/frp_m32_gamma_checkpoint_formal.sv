`timescale 1ns/1ps

module frp_m32_gamma_checkpoint_formal (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        load_begin,
  input  logic [9:0]  checkpoint_index,
  input  logic        load_valid,
  input  logic [31:0] load_word,
  input  logic        load_ready, configured, load_error,
  input  logic        request_ready, busy, bank_valid,
  input  logic        loading, idle, unconfigured,
  input  logic [9:0]  load_count, draw_index,
  input  logic [31:0] accepted_or,
  output wire [15:0]  reach
);
  localparam logic [9:0] WORDS = 10'd624;

  // Reference counts outstanding words and records whether any accepted bit was set.
  logic [9:0] remaining, saved_index;
  logic seen_nonzero, expect_configured, expect_error, just_configured;
  wire active = remaining != 0;
  wire accepting = rst_n && !load_begin && active && load_valid;
  wire last = remaining == 10'd1;
  wire usable = seen_nonzero || (|load_word);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      remaining         <= '0;
      saved_index       <= '0;
      seen_nonzero      <= 1'b0;
      expect_configured <= 1'b0;
      expect_error      <= 1'b0;
      just_configured   <= 1'b0;
    end else if (load_begin) begin
      remaining         <= (checkpoint_index <= WORDS) ? WORDS : 10'd0;
      saved_index       <= checkpoint_index;
      seen_nonzero      <= 1'b0;
      expect_configured <= 1'b0;
      expect_error      <= checkpoint_index > WORDS;
      just_configured   <= 1'b0;
    end else begin
      just_configured <= accepting && last && usable;
      if (accepting) begin
        remaining    <= remaining - 10'd1;
        seen_nonzero <= usable;
        if (last) begin
          expect_configured <= usable;
          expect_error      <= !usable;
        end
      end
    end
  end

  logic reset_sampled;
  always_ff @(posedge clk) reset_sampled <= !rst_n;

  always @(posedge clk) begin
    assert (remaining <= WORDS);
    assert (loading == active);
    assert (load_ready == (rst_n && !load_begin && active));
    assert (configured == expect_configured);
    assert (load_error == expect_error);
    assert (unconfigured == (!active && !expect_configured));
    if (!rst_n || load_begin) assert (!request_ready && !load_ready);
    if (unconfigured) assert (!busy && !bank_valid && !request_ready);
    if (reset_sampled) assert (unconfigured && !configured && !load_error);
    if (active) begin
      assert (!configured && !load_error && !bank_valid && !busy && !request_ready);
      assert ({1'b0, load_count} + {1'b0, remaining} == 11'd624);
      assert ((|accepted_or) == seen_nonzero);
      assert (draw_index == saved_index && saved_index <= WORDS);
    end
    if (just_configured) begin
      assert (idle && configured && !bank_valid && !busy);
      assert (draw_index == saved_index);
    end
  end

  // Sample pre-edge inputs for acceptance and post-edge flags for completion.
  assign reach[0]  = rst_n && load_begin && checkpoint_index == WORDS;
  assign reach[1]  = rst_n && load_begin && checkpoint_index == WORDS + 10'd1;
  assign reach[2]  = rst_n && load_begin && checkpoint_index == 10'd1023;
  assign reach[3]  = rst_n && active && !load_begin && !load_valid && remaining == 10'd312;
  assign reach[4]  = accepting && last && !seen_nonzero && load_word == 0;
  assign reach[5]  = accepting && last && !seen_nonzero && load_word != 0;
  assign reach[6]  = accepting && last && seen_nonzero && load_word == 0;
  assign reach[7]  = rst_n && load_begin && active && last && load_valid;
  assign reach[8]  = rst_n && load_begin && busy && checkpoint_index <= WORDS;
  assign reach[9]  = rst_n && load_begin && expect_error && checkpoint_index == 0;
  assign reach[10] = rst_n && just_configured && saved_index == WORDS;
  assign reach[11] = rst_n && just_configured && saved_index == 0;
  assign reach[12] = rst_n && load_begin && bank_valid && checkpoint_index <= WORDS;
  assign reach[13] = rst_n && load_begin && busy && checkpoint_index > WORDS;
  assign reach[14] = accepting && remaining == WORDS && load_word != 0;
  assign reach[15] = rst_n && active && last && !load_begin && !load_valid;

  for (genvar k = 0; k < $bits(reach); k++) begin : checkpoint_witness
    always_comb cover (reach[k]);
  end
endmodule

bind frp_m32_gamma_target_source frp_m32_gamma_checkpoint_formal checkpoint_check (
  .clk, .rst_n, .load_begin, .checkpoint_index, .load_valid, .load_word,
  .load_ready, .configured, .load_error, .request_ready, .busy, .bank_valid,
  .loading(state_q == LOADING),
  .idle(state_q == IDLE),
  .unconfigured(state_q == UNCONFIGURED),
  .load_count(load_count_q), .draw_index(index_q), .accepted_or(load_or_q),
  .reach()
);

`timescale 1ns/1ps
`include "frp_m32_boundary_snapshot_csr.sv"

module frp_m32_snapshot_packing_tb;
  localparam logic [1:0] POS = 2'b01, NEG = 2'b11;
  logic clk, rst_n, valid, wr;
  logic [7:0] addr;
  logic [31:0] wdata;
  logic [127:0] retained, pending;
  logic [63:0] sample_count;
  wire [64:1] ready, error;
  wire [31:0] rdata [1:64];
  int comparisons, bus_checks;

  for (genvar n = 1; n <= 64; n++) begin : widths
    frp_m32_boundary_snapshot_csr #(.CELLS(n), .RECORDER_COUNT_BITS(n)) dut (
      .clk(clk), .rst_n(rst_n), .csr_valid(valid), .csr_write(wr),
      .csr_addr(addr), .csr_wdata(wdata), .csr_ready(ready[n]),
      .csr_error(error[n]), .csr_rdata(rdata[n]),
      .record_sample_seen_q(1'b1), .record_sample_count_q(sample_count[n-1:0]),
      .record_count_overflow_q('0), .record_previous_margin_q16('0),
      .record_minimum_margin_q16('0), .record_minimum_margin_tick_q('0),
      .record_peak_switch_load_q16('0), .record_peak_switch_load_tick_q('0),
      .boundary_valid_q(1'b1), .boundary_pulse_q('0), .boundary_tick_q('0),
      .boundary_scheduler_mode_q('0), .boundary_scheduler_state_q('0),
      .boundary_previous_margin_q16('0), .boundary_margin_q16('0),
      .boundary_capacity_q16('0), .boundary_pressure_q16('0),
      .boundary_mean_heat_q16('0), .boundary_switch_load_q16('0),
      .boundary_retained_state_q(retained[2*n-1:0]),
      .boundary_pending_route_q(pending[2*n-1:0]), .record_alignment_error_q('0)
    );
  end

  task automatic tick();
    #1; clk = 1; #1; clk = 0;
  endtask

  task automatic capture();
    wr = 1; addr = 0; wdata = 1;
    #1;
    if (ready !== '1 || error !== '0) $fatal(1, "Capture rejected");
    tick();
    wr = 0; wdata = 0;
    retained = '0; pending = '0; sample_count = '0;
  endtask

  // Each read carries one marker. Bits outside that instance's width read zero.
  task automatic check_word(input logic [7:0] address, input int marker,
                            input logic [31:0] expected_word);
    logic [31:0] expected;
    addr = address;
    #1;
    for (int n = 1; n <= 64; n++) begin
      expected = marker < n ? expected_word : '0;
      if (ready[n] !== 1'b1 || error[n] !== 1'b0 || rdata[n] !== expected)
        $fatal(1, "width=%0d marker=%0d addr=%h expected=%h got=%h ready=%b error=%b",
               n, marker, addr, expected, rdata[n], ready[n], error[n]);
      comparisons++;
    end
    tick();
  endtask

  task automatic check_bank(input logic [7:0] base, input int lane, input logic [1:0] code);
    logic [31:0] word_value;
    for (int w = 0; w < 4; w++) begin
      word_value = '0;
      if (w == lane / 16) word_value[2*(lane % 16) +: 2] = code;
      check_word(base + 8'(4*w), lane, word_value);
    end
  endtask

  task automatic transfer(input bit write_op, input logic [7:0] address,
                          input logic [31:0] data, input bit expect_error,
                          input logic [31:0] expect_data);
    logic [31:0] expected;
    wr = write_op; addr = address; wdata = data;
    #1;
    for (int n = 1; n <= 64; n++) begin
      expected = expect_data;
      if (!write_op && address == 8'h0c) expected = {16'(n), 16'(n)};
      if (ready[n] !== 1'b1 || error[n] !== expect_error || rdata[n] !== expected)
        $fatal(1, "CSR width=%0d write=%b addr=%h wdata=%h ready=%b error=%b/%b data=%h/%h",
               n, wr, addr, wdata, ready[n], error[n], expect_error, rdata[n], expected);
      bus_checks++;
    end
    tick();
  endtask

  // Read every byte address after a rejected write. The captured counter is 1.
  task automatic check_map(input bit occupied);
    bit readable;
    logic [31:0] value, command;
    for (int a = 0; a < 256; a++) begin
      command = a == 0 ? 32'd3 : (a[2] ? 32'd1 : 32'd2);
      transfer(1, 8'(a), command, 1, '0);
      readable = (a == 4 || a == 8 || a == 12) ||
                 (occupied && a >= 16 && a <= 116 && a % 4 == 0);
      case (a)
        4:  value = occupied ? 32'h0b : 0;
        8:  value = 32'h46524201;
        16: value = occupied ? 32'd1 : 0;
        default: value = 0;
      endcase
      transfer(0, 8'(a), '0, !readable, value);
    end
    transfer(0, 8'h10, '0, !occupied, occupied ? 32'd1 : 0);
  endtask

  initial begin
    int retained_lane;
    logic [1:0] retained_code, pending_code;
    clk = 0; rst_n = 0; valid = 0; wr = 0; addr = 0; wdata = 0;
    retained = '0; pending = '0; sample_count = '0; comparisons = 0;
    tick();
    rst_n = 1; valid = 1;
    bus_checks = 0;
    check_map(0);
    sample_count = 1;
    transfer(1, 8'h00, 1, 0, 0);
    sample_count = 0;
    check_map(1);
    transfer(1, 8'h00, 2, 0, 0);
    check_map(0);
    if (bus_checks != 98624) $fatal(1, "Incomplete CSR matrix: %0d", bus_checks);
    $display("CSR_MAP widths=64 addresses=256 phases=3 comparisons=%0d", bus_checks);

    for (int lane = 0; lane < 64; lane++) begin
      retained_lane = (lane + 17) % 64;
      for (int sign_id = 0; sign_id < 2; sign_id++) begin
        pending_code = sign_id == 0 ? NEG : POS;
        retained_code = sign_id == 0 ? POS : NEG;
        retained[2*retained_lane +: 2] = retained_code;
        pending[2*lane +: 2] = pending_code;
        sample_count[lane] = 1;
        capture();
        check_bank(8'h58, retained_lane, retained_code);
        check_bank(8'h68, lane, pending_code);
        check_word(8'h10, lane, lane < 32 ? (32'd1 << (lane % 32)) : '0);
        check_word(8'h14, lane, lane >= 32 ? (32'd1 << (lane % 32)) : '0);
      end
    end
    if (comparisons != 81920) $fatal(1, "Incomplete matrix: %0d", comparisons);
    $display("PASS M32_SNAPSHOT_PACKING widths=64 frames=128 comparisons=%0d", comparisons);
    $finish;
  end
endmodule

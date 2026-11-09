`timescale 1ns/1ps
`include "frp_m32_internal_gamma_observed_csr_top.sv"

module frp_m32_host_request_clear_tb #(parameter int CELLS = 8);
  import frp_m22_csr_pkg::*;
  logic clk = 0, rst_n_async = 1, csr_valid = 0, csr_write = 0;
  logic [8:0] csr_addr = '0;
  logic [31:0] csr_wdata = '0;
  wire csr_ready, csr_error;
  wire [31:0] csr_rdata;
  logic [2*CELLS-1:0] expected_bank = '0;
  int transactions = 0;
  frp_m32_internal_gamma_observed_csr_top #(.CELLS(CELLS)) dut (.*);

  task automatic clock_edge;
    #1; clk = 1; #1; clk = 0; #1;
  endtask
  task automatic access(input bit write_op, input logic [7:0] addr,
                        input logic [31:0] value);
    csr_valid = 1; csr_write = write_op; csr_addr = {1'b0,addr}; csr_wdata = value;
    #1;
    if ({csr_ready,csr_error} !== 2'b10 || (!write_op && csr_rdata !== value))
      $fatal(1, "CSR access addr=%h write=%b want=%h read=%h", addr, write_op, value, csr_rdata);
    clock_edge();
    csr_valid = 0; #1;
    transactions++;
  endtask
  task automatic stage(input int lane, input int address, input logic [1:0] target);
    access(1, FRP_M22_ADDR_REQUEST_LANE_SELECT, lane);
    access(1, FRP_M22_ADDR_REQUEST_CELL_INDEX, address);
    access(1, FRP_M22_ADDR_REQUEST_TARGET, {30'b0,target});
    access(1, FRP_M22_ADDR_REQUEST_VALID, 1);
    expected_bank[2*address+:2] = target;
    if (dut.target_bank !== expected_bank) $fatal(1, "Target bank mapping lane=%0d",lane);
  endtask

  initial begin
    #1; rst_n_async = 0; clock_edge(); rst_n_async = 1;
    repeat (3) clock_edge();
    stage(0, 0, 2'b01);
    stage(1, CELLS-1, 2'b11);
    // Clear both lanes with one host operation, then check each public register.
    access(1, FRP_M22_ADDR_CONTROL, FRP_M22_CONTROL_CLEAR_REQUESTS);
    if (dut.target_bank !== '0) $fatal(1, "Clear left a live target");
    expected_bank = '0;
    for (int lane = 0; lane < 2; lane++) begin
      access(1, FRP_M22_ADDR_REQUEST_LANE_SELECT, lane);
      access(0, FRP_M22_ADDR_REQUEST_VALID, 0);
      access(0, FRP_M22_ADDR_REQUEST_CELL_INDEX, lane == 0 ? 0 : CELLS-1);
      access(0, FRP_M22_ADDR_REQUEST_TARGET, lane == 0 ? 1 : 3);
    end
    stage(0, CELLS-1, 2'b01);
    access(0, FRP_M22_ADDR_REQUEST_VALID, 1);
    $display("PASS HOST_REQUEST_CLEAR cells=%0d transactions=%0d", CELLS, transactions);
    $finish;
  end
endmodule

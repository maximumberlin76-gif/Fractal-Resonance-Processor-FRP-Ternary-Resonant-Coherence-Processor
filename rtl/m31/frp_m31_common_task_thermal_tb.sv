// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Historical v0.9.3 common-task thermal comparison and M31 execution correlation.
// Source SHA256: 48361714bb815f362a30a5a884a0fb782cb97349e9a18f9b607af7bf54c02e52
// Fixtures: N=8/16/32/64, seeds=0..4; neg/add/sub/compare/consensus.
// NumPy default_rng(seed*1000003 + N*101 + len(op)); probabilities .35/.30/.35.
// Architecture IDs: 0=binary forced, 1=direct ternary, 2=distributed neutral reference,
// 3=integrated M31 retained execution under free, 7/1 and 1/7 scheduling.
// M31 is scored from public retained-state transitions using the distributed heat rule.
// Relative-phase computation is qualified by the phase and closed-loop regressions.
// Fixtures specify common boundary tasks; encoded-bit toggles belong only to row 0.
`timescale 1ns/1ps
`include "frp_m31_execution_core.sv"
module frp_m31_common_task_thermal_tb #(
  parameter int CELLS=8,
  localparam int LANES=CELLS/4,
  localparam int INDEX_BITS=$clog2(CELLS)
);
  import frp_m31_pkg::*;
  bit clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE, scheduler_mode_q;
  frp_m31_scheduler_state_e scheduler_state_q;
  logic [LANES-1:0] request_valid = 0, request_accept, request_reject;
  logic [LANES*INDEX_BITS-1:0] request_cell_index = 0;
  logic [LANES*2-1:0] request_target = 0;
  logic [CELLS*2-1:0] target_q = 0, state_out, pending_route_out;
  logic [CELLS-1:0] accepted_cell_mask, neutral_routed_cell_mask, accepted_change_mask;
  logic [31:0] ticks_recorded_q, scheduler_count_free_q, scheduler_count_balance_q;
  logic [31:0] scheduler_count_commit_q, scheduler_count_excite_q;
  logic [31:0] scheduler_count_neutralize_q, accepted_changes, capacity_remaining;
  logic [31:0] switch_load_numerator, requested_direct_events, prevented_direct_events;
  logic [31:0] neutral_routed_events, actual_direct_events, reserved_state_events;
  logic [31:0] queue_overflow_events;
  logic capacity_exhausted;
  logic [9:0] invariant_flags;
  int a[CELLS],b[CELLS],goal[CELLS],state_ref[CELLS],pending_ref[CELLS];
  int mode_ref=0,position_ref=0,cases=0,cycles=0,checks=0,rtl_heat=0;
  int peak_heat[4],peak_switch[4],direct_total[4],neutral_total[4],samples[4];
  int completed_routes=0,prevented_total=0,coverage[5][3];
  int mode_peak_heat[3],mode_samples[3];
  logic [63:0] signature=64'hcbf29ce484222325;
  frp_m31_execution_core #(
    .CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(INDEX_BITS)
  ) dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .scheduler_mode,
    .request_valid, .request_cell_index, .request_target, .target_q,
    .state_out, .pending_route_out, .scheduler_mode_q, .scheduler_state_q,
    .ticks_recorded_q, .scheduler_count_free_q, .scheduler_count_balance_q,
    .scheduler_count_commit_q, .scheduler_count_excite_q, .scheduler_count_neutralize_q,
    .request_accept, .request_reject, .accepted_cell_mask, .neutral_routed_cell_mask,
    .accepted_change_mask, .accepted_changes, .capacity_remaining, .capacity_exhausted,
    .switch_load_numerator, .requested_direct_events, .prevented_direct_events,
    .neutral_routed_events, .actual_direct_events, .reserved_state_events,
    .queue_overflow_events, .invariant_flags
  );

  function automatic logic [383:0] vectors(input int index);
    case(index)
      0: vectors = {128'h00000000000000000000000000003c71, 128'h00000000000000000000000000000000, 128'h000000000000000000000000000014d3};
      1: vectors = {128'h00000000000000000000000000003c71, 128'h000000000000000000000000000051c4, 128'h00000000000000000000000000004d35};
      2: vectors = {128'h00000000000000000000000000003c71, 128'h000000000000000000000000000051c4, 128'h00000000000000000000000000005cfd};
      3: vectors = {128'h00000000000000000000000000003154, 128'h00000000000000000000000000005415, 128'h00000000000000000000000000000003};
      4: vectors = {128'h000000000000000000000000000014c7, 128'h00000000000000000000000000004c04, 128'h000000000000000000000000000050c7};
      5: vectors = {128'h000000000000000000000000000017c5, 128'h00000000000000000000000000000000, 128'h00000000000000000000000000003d4f};
      6: vectors = {128'h000000000000000000000000000017c5, 128'h00000000000000000000000000001dcf, 128'h00000000000000000000000000007340};
      7: vectors = {128'h000000000000000000000000000017c5, 128'h00000000000000000000000000001dcf, 128'h00000000000000000000000000000513};
      8: vectors = {128'h00000000000000000000000000000fc0, 128'h000000000000000000000000000004dc, 128'h00000000000000000000000000000003};
      9: vectors = {128'h0000000000000000000000000000c7df, 128'h0000000000000000000000000000df5c, 128'h0000000000000000000000000000d31f};
      10: vectors = {128'h0000000000000000000000000000157d, 128'h00000000000000000000000000000000, 128'h00000000000000000000000000003fd7};
      11: vectors = {128'h0000000000000000000000000000157d, 128'h0000000000000000000000000000014c, 128'h00000000000000000000000000007f55};
      12: vectors = {128'h0000000000000000000000000000157d, 128'h0000000000000000000000000000014c, 128'h00000000000000000000000000001431};
      13: vectors = {128'h0000000000000000000000000000d3cf, 128'h0000000000000000000000000000f5f3, 128'h00000000000000000000000000000001};
      14: vectors = {128'h00000000000000000000000000000504, 128'h00000000000000000000000000000454, 128'h00000000000000000000000000000554};
      15: vectors = {128'h00000000000000000000000000007f51, 128'h00000000000000000000000000000000, 128'h0000000000000000000000000000d5f3};
      16: vectors = {128'h00000000000000000000000000007f51, 128'h000000000000000000000000000043d7, 128'h00000000000000000000000000005574};
      17: vectors = {128'h00000000000000000000000000007f51, 128'h000000000000000000000000000043d7, 128'h00000000000000000000000000003dc3};
      18: vectors = {128'h000000000000000000000000000051f4, 128'h0000000000000000000000000000c7f3, 128'h00000000000000000000000000000001};
      19: vectors = {128'h00000000000000000000000000001c75, 128'h0000000000000000000000000000c557, 128'h0000000000000000000000000000d144};
      20: vectors = {128'h0000000000000000000000000000ffd7, 128'h00000000000000000000000000000000, 128'h0000000000000000000000000000557d};
      21: vectors = {128'h0000000000000000000000000000ffd7, 128'h0000000000000000000000000000f533, 128'h000000000000000000000000000010c1};
      22: vectors = {128'h0000000000000000000000000000ffd7, 128'h0000000000000000000000000000f533, 128'h00000000000000000000000000003134};
      23: vectors = {128'h00000000000000000000000000007dc3, 128'h0000000000000000000000000000710d, 128'h00000000000000000000000000000003};
      24: vectors = {128'h00000000000000000000000000000c4f, 128'h00000000000000000000000000004cd1, 128'h00000000000000000000000000004c1c};
      25: vectors = {128'h000000000000000000000000f73c50fd, 128'h00000000000000000000000000000000, 128'h0000000000000000000000005d14f057};
      26: vectors = {128'h000000000000000000000000f73c50fd, 128'h0000000000000000000000004f031073, 128'h0000000000000000000000003d3cf0dc};
      27: vectors = {128'h000000000000000000000000f73c50fd, 128'h0000000000000000000000004f031073, 128'h0000000000000000000000004c3d4343};
      28: vectors = {128'h000000000000000000000000130fc4fd, 128'h000000000000000000000000373f55cf, 128'h00000000000000000000000000000001};
      29: vectors = {128'h0000000000000000000000004333c405, 128'h00000000000000000000000077734741, 128'h00000000000000000000000077730745};
      30: vectors = {128'h00000000000000000000000034d01f14, 128'h00000000000000000000000000000000, 128'h0000000000000000000000001c70353c};
      31: vectors = {128'h00000000000000000000000034d01f14, 128'h000000000000000000000000dd0cd5f5, 128'h000000000000000000000000c1dc30dd};
      32: vectors = {128'h00000000000000000000000034d01f14, 128'h000000000000000000000000dd0cd5f5, 128'h0000000000000000000000007fd477f3};
      33: vectors = {128'h0000000000000000000000007d44ff57, 128'h000000000000000000000000570057f3, 128'h00000000000000000000000000000003};
      34: vectors = {128'h00000000000000000000000011071430, 128'h00000000000000000000000055fcf14f, 128'h00000000000000000000000055f3c57f};
      35: vectors = {128'h000000000000000000000000f0dfc304, 128'h00000000000000000000000000000000, 128'h0000000000000000000000005075410c};
      36: vectors = {128'h000000000000000000000000f0dfc304, 128'h000000000000000000000000f174f7ff, 128'h000000000000000000000000110d71f3};
      37: vectors = {128'h000000000000000000000000f0dfc304, 128'h000000000000000000000000f174f7ff, 128'h0000000000000000000000000d571dfd};
      38: vectors = {128'h00000000000000000000000077774035, 128'h000000000000000000000000f0c753d1, 128'h00000000000000000000000000000001};
      39: vectors = {128'h0000000000000000000000003ccfd511, 128'h00000000000000000000000011141ff4, 128'h0000000000000000000000000dd3d0c5};
      40: vectors = {128'h00000000000000000000000050431535, 128'h00000000000000000000000000000000, 128'h000000000000000000000000f0c13f1f};
      41: vectors = {128'h00000000000000000000000050431535, 128'h000000000000000000000000577540d3, 128'h00000000000000000000000034f455c4};
      42: vectors = {128'h00000000000000000000000050431535, 128'h000000000000000000000000577540d3, 128'h0000000000000000000000000d05d57f};
      43: vectors = {128'h00000000000000000000000043fc51df, 128'h0000000000000000000000005cdddd75, 128'h00000000000000000000000000000003};
      44: vectors = {128'h00000000000000000000000005ccdd0d, 128'h0000000000000000000000004f0f577c, 128'h00000000000000000000000040cf107d};
      45: vectors = {128'h000000000000000000000000fc5f71f7, 128'h00000000000000000000000000000000, 128'h00000000000000000000000054f5d35d};
      46: vectors = {128'h000000000000000000000000fc5f71f7, 128'h000000000000000000000000c15dd43c, 128'h00000000000000000000000073d40453};
      47: vectors = {128'h000000000000000000000000fc5f71f7, 128'h000000000000000000000000c15dd43c, 128'h0000000000000000000000003f0d5ddf};
      48: vectors = {128'h0000000000000000000000005445cfd4, 128'h000000000000000000000000173d4f11, 128'h00000000000000000000000000000001};
      49: vectors = {128'h00000000000000000000000014d1f745, 128'h000000000000000000000000517cc030, 128'h000000000000000000000000550df775};
      50: vectors = {128'h00000000000000003043347341f34c17, 128'h00000000000000000000000000000000, 128'h000000000000000010c11cd1c351c43d};
      51: vectors = {128'h00000000000000003043347341f34c17, 128'h00000000000000000107f5d47d3c3cf7, 128'h00000000000000003141fd04fd5f14c5};
      52: vectors = {128'h00000000000000003043347341f34c17, 128'h00000000000000000107f5d47d3c3cf7, 128'h0000000000000000334c435f14c751f0};
      53: vectors = {128'h00000000000000001f17cf14fcc444c5, 128'h00000000000000001ccdffc53d155f74, 128'h00000000000000000000000000000003};
      54: vectors = {128'h000000000000000051c707cccdd4c714, 128'h00000000000000007fd035545035f7c5, 128'h00000000000000004cd734101dc5f7d5};
      55: vectors = {128'h0000000000000000445347f753ff1df7, 128'h00000000000000000000000000000000, 128'h0000000000000000ccf1cd5df155375d};
      56: vectors = {128'h0000000000000000445347f753ff1df7, 128'h0000000000000000c50c5cf0f7c07113, 128'h00000000000000001d5cdd17007f43c1};
      57: vectors = {128'h0000000000000000445347f753ff1df7, 128'h0000000000000000c50c5cf0f7c07113, 128'h0000000000000000c3570f043c3f3f54};
      58: vectors = {128'h0000000000000000d53ff7375d74c51f, 128'h0000000000000000071735f7cddff17c, 128'h00000000000000000000000000000003};
      59: vectors = {128'h00000000000000001d47405140430ff7, 128'h00000000000000000cd15d5015450c57, 128'h00000000000000001d145d5155440f07};
      60: vectors = {128'h0000000000000000cd7fc355cd45d44c, 128'h00000000000000000000000000000000, 128'h000000000000000047d541ff47cf7cc4};
      61: vectors = {128'h0000000000000000cd7fc355cd45d44c, 128'h00000000000000003dc131311df04d77, 128'h0000000000000000ff3cf05fdf3517f3};
      62: vectors = {128'h0000000000000000cd7fc355cd45d44c, 128'h00000000000000003dc131311df04d77, 128'h0000000000000000d055d3f4f1d5ff05};
      63: vectors = {128'h00000000000000007dcdf3d10c7f735d, 128'h0000000000000000c40f443d43d5f507, 128'h00000000000000000000000000000001};
      64: vectors = {128'h00000000000000004f3733735d5c1d7c, 128'h00000000000000004d3cd1d147c0cd17, 128'h00000000000000004c33c000501cdd43};
      65: vectors = {128'h0000000000000000c1301c0f1ddf7f43, 128'h00000000000000000000000000000000, 128'h0000000000000000431034053775d5c1};
      66: vectors = {128'h0000000000000000c1301c0f1ddf7f43, 128'h000000000000000047c1c5fc504554ff, 128'h000000000000000004f1d054fd11c3d5};
      67: vectors = {128'h0000000000000000c1301c0f1ddf7f43, 128'h000000000000000047c1c5fc504554ff, 128'h000000000000000043734753cc41c4d4};
      68: vectors = {128'h00000000000000001541dd35f35dd031, 128'h00000000000000003d31c3d51dc4c337, 128'h00000000000000000000000000000001};
      69: vectors = {128'h0000000000000000754c4ddc070754d1, 128'h000000000000000037cf755f4cff705c, 128'h0000000000000000740f711f43f3441d};
      70: vectors = {128'h00000000000000000dffc7f1dd570c0f, 128'h00000000000000000000000000000000, 128'h000000000000000007554d5377fd0405};
      71: vectors = {128'h00000000000000000dffc7f1dd570c0f, 128'h0000000000000000dfc4fccd01155714, 128'h0000000000000000c77d7d73d0cc5313};
      72: vectors = {128'h00000000000000000dffc7f1dd570c0f, 128'h0000000000000000dfc4fccd01155714, 128'h000000000000000077d77f34dc4c55d7};
      73: vectors = {128'h0000000000000000f3054477f134dd3c, 128'h0000000000000000330730fdd1f13034, 128'h00000000000000000000000000000003};
      74: vectors = {128'h0000000000000000dc47df47c3715071, 128'h0000000000000000400304d347d1d7f1, 128'h00000000000000001c47d31707011731};
      75: vectors = {128'h17f557f5dcf51fcf0c77d3c3117f047d, 128'h00000000000000000000000000000000, 128'h3d5ffd5f745f354504dd714133d50cd7};
      76: vectors = {128'h17f557f5dcf51fcf0c77d3c3117f047d, 128'h15f5d31075441dd41d43dfd345cf4c4d, 128'h4f7371c5010d17531ff05453ffd141ff};
      77: vectors = {128'h17f557f5dcf51fcf0c77d3c3117f047d, 128'h15f5d31075441dd41d43dfd345cf4c4d, 128'h0d01c75451710dd733340430ddf0dc30};
      78: vectors = {128'h4ff44434c3fdcc5df777401501fd1f75, 128'h4f55703df17777f1511f7dff3df5d34f, 128'h00000000000000000000000000000003};
      79: vectors = {128'hf445733ff735c33047410dc351574347, 128'hc4d4010fcd5cc37503714f01304ccdf5, 128'hf415703ff041c37547714cc041530c34};
      80: vectors = {128'hd3007c104dfdcf3dc04f05ddd4013751, 128'h00000000000000000000000000000000, 128'h7100d430c757451740c50f777c031df3};
      81: vectors = {128'hd3007c104dfdcf3dc04f05ddd4013751, 128'h17d0315f4fd5f34c715d5577475331c1, 128'h31d013fcf741151537c5f3007f50d417};
      82: vectors = {128'hd3007c104dfdcf3dc04f05ddd4013751, 128'h17d0315f4fd5f34c715d5577475331c1, 128'hcc704fc507c41cf0533df35551f707d0};
      83: vectors = {128'h073f107dff433557fdf0dc05c351517f, 128'h11445cf5717d05d5f55f7f17cd775fd7, 128'h00000000000000000000000000000003};
      84: vectors = {128'hdd1545075771c7cff3743f75cdc0471c, 128'hdf1f1dc5f5fdc7c135d573711115d1d4, 128'hdc1051c4043dc7ccf4057f75ddd514d0};
      85: vectors = {128'hd3c1fc4fd745f5c0010f4d37d7170077, 128'h00000000000000000000000000000000, 128'h714354c57dcf5f400305c71d7d3d00dd};
      86: vectors = {128'hd3c1fc4fd745f5c0010f4d37d7170077, 128'h7c0c55f10fcdc440fd3700f45434f41f, 128'h0fcd013cdd014d00f33d4dff4f1ff44d};
      87: vectors = {128'hd3c1fc4fd745f5c0010f4d37d7170077, 128'h7c0c55f10fcdc440fd3700f45434f41f, 128'hf7c404c53ddc304054044d4d43735c7c};
      88: vectors = {128'hfcf7d0777375334f115543773540f3c4, 128'hd3f34d7d05fdff10f3cdd33d07431ddd, 128'h00000000000000000000000000000003};
      89: vectors = {128'hf3541500540dd775f751c31cff51c1c1, 128'h0ccfdcf53df5d7ddf5150c457d77c141, 128'hff13d1f541f1d701f455cf513c44c101};
      90: vectors = {128'h7c300443cdc335f7000f157f54f04d3d, 128'h00000000000000000000000000000000, 128'hd4100cc147411f5d00053fd5fc50c717};
      91: vectors = {128'h7c300443cdc335f7000f157f54f04d3d, 128'h5fccd070c3c0f07c31157ddf33f04c3f, 128'hf7fcd5fd4f4d55d3311047314111f5c4};
      92: vectors = {128'h7c300443cdc335f7000f157f54f04d3d, 128'h5fccd070c3c0f07c31157ddf33f04c3f, 128'hd17474130303445f13d10c51f5000107};
      93: vectors = {128'hc430ff571ddc01f755135cc10011fd33, 128'h3dddd03f54357c57df03f5440dd17f11, 128'h00000000000000000000000000000003};
      94: vectors = {128'hfd4f3511533351f7ff75cf5f4c100737, 128'h17dcd51134f5dd5544d44dcd51ffc150, 128'hc01fc51147f41d0433050c1c5dcfc447};
      95: vectors = {128'h14dd11d5f1410c0cdc4171c001d17dcd, 128'h00000000000000000000000000000000, 128'h3c77337f53c3040474c3d3400373d747};
      96: vectors = {128'h14dd11d5f1410c0cdc4171c001d17dcd, 128'hc1dd1004c31dc373c7f735ffff4d10d5, 128'hd5ff713c7053cf155334157ffc134c57};
      97: vectors = {128'h14dd11d5f1410c0cdc4171c001d17dcd, 128'hc1dd1004c31dc373c7f735ffff4d10d5, 128'h570001d137744ddd1fd34c1555541dd4};
      98: vectors = {128'h3375df0dd717f40144fcdcf0ccc47415, 128'h01c7d4357ffc777c4dcd174d10075375, 128'h00000000000000000000000000000003};
      99: vectors = {128'hc5d4504f3d0f5dd13df11c735f0cf4c0, 128'hd054cc117d4775f710c775f5c30c4f53, 128'hd5141c5c7d4341c40df441341f0c3313};
      default: $fatal(1,"Unknown historical fixture");
    endcase
  endfunction
  function automatic logic [1:0] enc(input int v);
    case(v) -1: return 2'b11; 0: return 2'b00; 1: return 2'b01;
      default: return 2'b10; endcase
  endfunction
  function automatic int dec(input logic [1:0] v);
    case(v) 2'b11: return -1; 2'b00: return 0; 2'b01: return 1;
      default: $fatal(1,"Reserved trit in fixture"); endcase
    return 0;
  endfunction
  function automatic int sched(input int m,p);
    case(m) 0:return 0; 1:return p==7 ? 2:1; 2:return p==0 ? 3:4;
      default:return 7; endcase
  endfunction
  function automatic bit eligible(input int s,a,b);
    if(a==b) return 0;
    case(s) 0:return 1; 1,4:return a!=0; 2,3:return a==0;
      default:return 0; endcase
  endfunction
  task automatic eq(input logic [63:0] got, expected, input string label_text);
    checks++;
    if(got !== expected)
      $fatal(1,"N=%0d case=%0d cycle=%0d %s got=%h expected=%h",
        CELLS,cases,cycles,label_text,got,expected);
    signature=(signature ^ expected)*64'h100000001b3;
  endtask

  // Goal generation belongs to the common command fixture.
  // The retained execution path is evaluated separately on the DUT.
  task automatic decode_task(input int index, op);
    logic [383:0] row;
    int carry,v,cmp;
    row=vectors(index); carry=0; cmp=0;
    for(int c=CELLS-1;c>=0;c--)
      if(cmp==0 && dec(row[256+2*c+:2])!=dec(row[128+2*c+:2]))
        cmp=dec(row[256+2*c+:2])>dec(row[128+2*c+:2]) ? 1:-1;
    for(int c=0;c<CELLS;c++) begin
      a[c]=dec(row[256+2*c+:2]); b[c]=dec(row[128+2*c+:2]);
      case(op)
        0:v=-a[c];
        1,2:begin
          v=a[c]+(op==1 ? b[c]:-b[c])+carry; carry=0;
          if(v>1) begin v-=3; carry=1; end
          if(v< -1) begin v+=3; carry=-1; end
        end
        3:v=c==0 ? cmp:0;
        4:v=a[c]==b[c] ? a[c] : a[c]==0 ? b[c] : b[c]==0 ? a[c]:0;
        default:v=0;
      endcase
      goal[c]=v;
      eq(64'(enc(v)),64'(row[2*c+:2]),"historical command goal");
    end
  endtask

  // Historical heat is represented exactly in units of 1/(2000*CELLS).
  // Switching/active/conflict/cooling coefficients: .020/.001/.030/.010/.003.
  task automatic record_metrics(input int arch, heat, switching, direct, neutral);
    if(heat>peak_heat[arch]) peak_heat[arch]=heat;
    if(switching>peak_switch[arch]) peak_switch[arch]=switching;
    direct_total[arch]+=direct; neutral_total[arch]+=neutral;
    samples[arch]++;
  endtask
  task automatic references;
    int state[CELLS],next_value[CELLS];
    int changes,opposites,active,toggles,heat,used,neutral,zero_count;
    changes=0; opposites=0; active=0; toggles=0;
    for(int c=0;c<CELLS;c++) begin
      state[c]=a[c];
      if(a[c]!=goal[c]) changes++;
      if(a[c]*goal[c]==-1) opposites++;
      if(goal[c]!=0) active++;
      // Binary reference uses the historical two-rail physical encoding.
      if((a[c]==-1)!=(goal[c]==-1)) toggles++;
      if((a[c]==1)!=(goal[c]==1)) toggles++;
    end
    record_metrics(0,20*toggles+60*opposites+2*active,toggles,opposites,0);
    record_metrics(1,40*changes+60*opposites+2*active,2*changes,opposites,0);
    heat=0;
    for(int phase=0;phase<2;phase++) begin
      for(int pass=0;pass<CELLS;pass++) begin
        used=0; neutral=0;
        foreach(state[c]) begin
          next_value[c]=state[c];
          if(used<LANES && ((phase==0 && state[c]!=0 && state[c]!=goal[c]) ||
                           (phase==1 && state[c]==0 && goal[c]!=0))) begin
            next_value[c]=phase==0 ? 0:goal[c]; used++;
            if(state[c]*goal[c]==-1) neutral++;
          end
        end
        if(used==0) break;
        active=0; zero_count=0;
        foreach(state[c]) begin
          if(state[c]*next_value[c]==-1) $fatal(1,"Direct transition in neutral reference");
          state[c]=next_value[c];
          if(state[c]!=0) active++; else zero_count++;
        end
        heat+=40*used+2*active-20*zero_count-6*CELLS;
        if(heat<0) heat=0;
        record_metrics(2,heat,2*used,0,neutral);
      end
    end
    foreach(state[c]) eq(64'(enc(state[c])),64'(enc(goal[c])),"neutral reference result");
  endtask

  task automatic registers;
    foreach(state_ref[c]) begin
      eq(64'(state_out[2*c+:2]),64'(enc(state_ref[c])),"RTL retained state");
      eq(64'(pending_route_out[2*c+:2]),64'(enc(pending_ref[c])),"RTL pending route");
    end
    eq(64'(scheduler_mode_q),64'(mode_ref),"scheduler mode");
    eq(64'(scheduler_state_q),64'(sched(mode_ref,position_ref)),"scheduler state");
  endtask
  function automatic bit finished;
    foreach(state_ref[c]) if(state_ref[c]!=goal[c] || pending_ref[c]!=0) return 0;
    return 1;
  endfunction
  task automatic cycle(input bit measure);
    int next_state[CELLS],next_pending[CELLS],selected[LANES];
    int s,count,used,c,opposites,committed_neutral,active,zero_count,changes;
    bit releasing;
    logic [LANES-1:0] ra,rr;
    logic [CELLS-1:0] writes,accepted,neutral;
    logic [CELLS*2-1:0] before_state;
    s=sched(mode_ref,position_ref); releasing=s==0 || s==2 || s==3;
    count=0; used=0; opposites=0; committed_neutral=0;
    request_valid='0; request_cell_index='0; request_target='0; target_q='0;
    ra='0; rr='0; writes='0; accepted='0; neutral='0;
    foreach(state_ref[k]) begin
      next_state[k]=state_ref[k]; next_pending[k]=pending_ref[k];
      target_q[2*k+:2]=enc(goal[k]);
      if(tick_enable && pending_ref[k]==0 && eligible(s,state_ref[k],goal[k]) && count<LANES) begin
        request_valid[count]=1; request_cell_index[count*INDEX_BITS+:INDEX_BITS]=INDEX_BITS'(k);
        request_target[count*2+:2]=enc(goal[k]); selected[count]=k; count++;
      end
    end
    if(tick_enable) begin
      foreach(state_ref[k])
        if(pending_ref[k]!=0 && releasing && used<LANES) begin
          eq(64'(enc(state_ref[k])),0,"completion begins at zero");
          next_state[k]=pending_ref[k]; next_pending[k]=0; writes[k]=1; used++;
          if(measure) completed_routes++;
        end
      for(int lane=0;lane<count;lane++) begin
        c=selected[lane];
        if(state_ref[c]*goal[c]==-1) opposites++;
        if(used<LANES) begin
          ra[lane]=1; accepted[c]=1; writes[c]=1; used++;
          if(state_ref[c]*goal[c]==-1) begin
            next_state[c]=0; next_pending[c]=goal[c]; neutral[c]=1; committed_neutral++;
          end else next_state[c]=goal[c];
        end else rr[lane]=1;
      end
    end
    #1; registers(); before_state=state_out;
    eq(64'(request_accept),64'(ra),"request accept");
    eq(64'(request_reject),64'(rr),"request reject");
    eq(64'(accepted_cell_mask),64'(accepted),"accepted cells");
    eq(64'(neutral_routed_cell_mask),64'(neutral),"committed neutral routes");
    eq(64'(accepted_change_mask),64'(writes),"write mask");
    eq(64'(accepted_changes),64'(used),"capacity used");
    eq(64'(capacity_remaining),64'(LANES-used),"capacity remaining");
    eq(64'(switch_load_numerator),64'(used),"logical switching load");
    eq(64'(requested_direct_events),64'(opposites),"requested opposite polarity");
    eq(64'(prevented_direct_events),64'(opposites),"prevented direct candidates");
    eq(64'(actual_direct_events),0,"actual direct transitions");
    eq(64'(invariant_flags),1023,"execution invariants");
    if(tick_enable) position_ref=(position_ref+1)%8;
    mode_ref=int'(scheduler_mode);
    foreach(state_ref[k]) begin state_ref[k]=next_state[k]; pending_ref[k]=next_pending[k]; end
    clk=1; #1; registers();
    changes=0; active=0; zero_count=0;
    foreach(state_ref[k]) begin
      if(before_state[2*k+:2]!=state_out[2*k+:2]) changes++;
      if(dec(before_state[2*k+:2])*dec(state_out[2*k+:2])==-1)
        $fatal(1,"Direct reversal in actual RTL output");
      if(state_out[2*k+:2]==0) zero_count++; else active++;
    end
    eq(64'(changes),64'(used),"observed logical changes");
    if(measure) begin
      // Apply the historical distributed-transition heat rule to observed RTL states.
      rtl_heat+=40*changes+2*active-20*zero_count-6*CELLS;
      if(rtl_heat<0) rtl_heat=0;
      record_metrics(3,rtl_heat,2*changes,0,committed_neutral);
      if(rtl_heat>mode_peak_heat[mode_ref]) mode_peak_heat[mode_ref]=rtl_heat;
      mode_samples[mode_ref]++;
      prevented_total+=opposites;
    end
    clk=0; #1; cycles++;
  endtask
  task automatic prepare(input int mode);
    rst_n=0; tick_enable=0; request_valid='0; scheduler_mode=FRP_MODE_FREE;
    #1; clk=1; #1; clk=0; #1;
    foreach(state_ref[c]) begin state_ref[c]=0; pending_ref[c]=0; goal[c]=a[c]; end
    mode_ref=0; position_ref=0; rst_n=1; #1;
    tick_enable=1;
    repeat(4) cycle(0);
    foreach(state_ref[c]) eq(64'(enc(state_ref[c])),64'(enc(a[c])),"common initial state");
    // Complete one scheduler period before selecting the measured profile.
    while(position_ref!=0) cycle(0);
    tick_enable=0; scheduler_mode=frp_m31_scheduler_mode_e'(mode); cycle(0);
    rtl_heat=0; tick_enable=1;
  endtask
  initial begin : run
    int size_index,limit,expected_direct,expected_heat,expected_neutral_heat;
    int expected_binary_switch,expected_ternary_switch,saved_goal[CELLS];
    case(CELLS)
      8: begin size_index=0; expected_direct=168; expected_heat=816;
        expected_neutral_heat=52; expected_binary_switch=16; expected_ternary_switch=16; end
      16:begin size_index=1; expected_direct=273; expected_heat=1428;
        expected_neutral_heat=52; expected_binary_switch=28; expected_ternary_switch=28; end
      32:begin size_index=2; expected_direct=552; expected_heat=2652;
        expected_neutral_heat=38; expected_binary_switch=52; expected_ternary_switch=52; end
      64:begin size_index=3; expected_direct=1059; expected_heat=4998;
        expected_neutral_heat=32; expected_binary_switch=98; expected_ternary_switch=106; end
      default:$fatal(1,"CELLS must be 8,16,32,64");
    endcase
    for(int seed=0;seed<5;seed++)
      for(int op=0;op<5;op++)
        for(int mode=0;mode<3;mode++) begin
          cases++; decode_task(size_index*25+seed*5+op,op); references();
          foreach(goal[c]) saved_goal[c]=goal[c];
          prepare(mode);
          foreach(goal[c]) goal[c]=saved_goal[c];
          limit=0;
          // One observation tick also covers a task whose goal already matches.
          do begin cycle(1); limit++; end while(!finished() && limit<128);
          if(!finished()) $fatal(1,"Task did not complete in scheduler bound");
          foreach(goal[c]) eq(64'(state_out[2*c+:2]),64'(enc(goal[c])),"common task result");
          coverage[op][mode]++;
        end
    foreach(coverage[o,m]) eq(64'(coverage[o][m]),5,"operation/mode/seed coverage");
    eq(64'(cases),75,"case count per size");
    for(int arch=0;arch<2;arch++) begin
      eq(64'(direct_total[arch]),64'(expected_direct),"historical direct count");
      eq(64'(peak_heat[arch]),64'(expected_heat),"historical peak heat");
    end
    eq(64'(peak_switch[0]),64'(expected_binary_switch),"binary rail switching");
    eq(64'(peak_switch[1]),64'(expected_ternary_switch),"direct trit switching");
    eq(64'(peak_switch[2]),64'(2*LANES),"distributed switching cap");
    eq(64'(peak_heat[2]),64'(expected_neutral_heat),"historical neutral heat");
    eq(64'(neutral_total[2]),64'(expected_direct),"reference neutralization count");
    eq(64'(neutral_total[3]),64'(expected_direct),"RTL committed neutralizations");
    eq(64'(completed_routes),64'(expected_direct),"RTL completed neutral routes");
    eq(64'(direct_total[3]),0,"RTL direct transitions");
    if(peak_switch[3]>2*LANES) $fatal(1,"RTL transition capacity exceeded");
    for(int arch=0;arch<4;arch++)
      $display("THERMAL_COMPARE cells=%0d arch=%0d cases=%0d match=1 heat_peak=%.9f switch_peak=%.9f direct=%0d neutralized=%0d samples=%0d",
        CELLS,arch,cases,real'(peak_heat[arch])/(2000*CELLS),real'(peak_switch[arch])/(2*CELLS),
        direct_total[arch],neutral_total[arch],samples[arch]);
    for(int mode=0;mode<3;mode++)
      $display("RTL_THERMAL_MODE cells=%0d mode=%0d cases=25 heat_peak=%.9f samples=%0d",
        CELLS,mode,real'(mode_peak_heat[mode])/(2000*CELLS),mode_samples[mode]);
    $display("PASS THERMAL_TASK cells=%0d cases=%0d checks=%0d cycles=%0d completed_routes=%0d prevented_candidates=%0d signature=%016h",
      CELLS,cases,checks,cycles,completed_routes,prevented_total,signature);
    $finish;
  end
  initial begin #10000000; $fatal(1,"Thermal task watchdog expired"); end
endmodule

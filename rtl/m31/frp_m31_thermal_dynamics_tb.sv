// SPDX-License-Identifier: Apache-2.0
// FRP M31 exact thermal accumulation and stability-boundary regression.

`ifndef FRP_M31_THERMAL_DYNAMICS_TB_SV
`define FRP_M31_THERMAL_DYNAMICS_TB_SV
`timescale 1ns / 1ps
`include "frp_m31_thermal_proxy.sv"
`include "frp_m31_stability.sv"

module frp_m31_thermal_dynamics_tb;
  // Independent offline integer oracle: Q30 decay=1020054733, gain=10737418;
  // round each product to nearest, with half cases away from zero.
  // GOLD packs {nonnegative Q16 cost, next temperature, next peak}.
  // Workload 0 exercises rounding and normalized activity; workload 1
  // exercises the positive Q16 interface range and pressure saturation.
  localparam logic [95:0] GOLD [0:63] = '{
    96'h000000000000000000000000,
    96'h000000310000000000000000,
    96'h000000320000000000000000,
    96'h000000330000000100000001,
    96'h000000630000000200000002,
    96'h000000640000000300000003,
    96'h000000650000000400000004,
    96'h000000950000000500000005,
    96'h000000960000000600000006,
    96'h000000970000000800000008,
    96'h000020000000005a0000005a,
    96'h00004000000000fa000000fa,
    96'h00006000000001e4000001e4,
    96'h000080000000031400000314,
    96'h0000a0000000048700000487,
    96'h0000c0000000063900000639,
    96'h0000e0000000082600000826,
    96'h0001000000000a4d00000a4d,
    96'h00000000000009c900000a4d,
    96'h0001000000000bdb00000bdb,
    96'h0000000000000b4300000bdb,
    96'h0000800000000bfb00000bfb,
    96'h0000000000000b6200000bfb,
    96'h0000400000000b7400000bfb,
    96'h0000000100000ae100000bfb,
    96'h0000000200000a5600000bfb,
    96'h00000003000009d200000bfb,
    96'h000000040000095400000bfb,
    96'h0000ffff00000b6c00000bfb,
    96'h0001000000000d6900000d69,
    96'h0001000100000f4c00000f4c,
    96'h0000000000000e8800000f4c,
    96'h7fffffff0147ae140147ae14,
    96'h7ffffffe027ef9da027ef9da,
    96'h7fff000003a6b27b03a6b27b,
    96'h40000000041bcd65041bcd65,
    96'h1000000004102c16041bcd65,
    96'h0000000003dc29e2041bcd65,
    96'h7fffffff04f26f7804f26f78,
    96'h0000000004b31d1804f26f78,
    96'h7fffffff05bea35105bea351,
    96'h7fffffff06bcc93b06bcc93b,
    96'h7fffffff07ae3a0c07ae3a0c,
    96'h7fffffff0893986c0893986c,
    96'h7fffffff096d7ee1096d7ee1,
    96'h7fffffff0a3c80370a3c8037,
    96'h7fffffff0b0127e20b0127e2,
    96'h7fffffff0bbbfa5e0bbbfa5e,
    96'h7fffffff0c6d75870c6d7587,
    96'h7fffffff0d1610ee0d1610ee,
    96'h7fffffff0db63e290db63e29,
    96'h7fffffff0e4e69210e4e6921,
    96'h7fffffff0edef85a0edef85a,
    96'h7fffffff0f684d360f684d36,
    96'h7fffffff0feac43b0feac43b,
    96'h7fffffff1066b54c1066b54c,
    96'h000000000f94c5d51066b54c,
    96'h000000010ecd558a1066b54c,
    96'h000100000e0fe09f1066b54c,
    96'h7fffffff0ea390451066b54c,
    96'h7fffff000f2fdd861066b54c,
    96'h000000000e6d78d91066b54c,
    96'h000000000db4cc681066b54c,
    96'h000000000d055bc91066b54c
  };
  // 128 zero-cost updates after each workload, in workload order.
  localparam logic [31:0] COOLING [0:255] = '{
    32'h00000dce, 32'h00000d1d, 32'h00000c75, 32'h00000bd6,
    32'h00000b3f, 32'h00000aaf, 32'h00000a26, 32'h000009a4,
    32'h00000929, 32'h000008b4, 32'h00000845, 32'h000007db,
    32'h00000776, 32'h00000717, 32'h000006bc, 32'h00000666,
    32'h00000614, 32'h000005c6, 32'h0000057c, 32'h00000536,
    32'h000004f3, 32'h000004b4, 32'h00000478, 32'h0000043f,
    32'h00000409, 32'h000003d5, 32'h000003a4, 32'h00000375,
    32'h00000349, 32'h0000031f, 32'h000002f7, 32'h000002d1,
    32'h000002ad, 32'h0000028b, 32'h0000026a, 32'h0000024b,
    32'h0000022e, 32'h00000212, 32'h000001f8, 32'h000001df,
    32'h000001c7, 32'h000001b0, 32'h0000019a, 32'h00000186,
    32'h00000173, 32'h00000160, 32'h0000014e, 32'h0000013d,
    32'h0000012d, 32'h0000011e, 32'h00000110, 32'h00000102,
    32'h000000f5, 32'h000000e9, 32'h000000dd, 32'h000000d2,
    32'h000000c8, 32'h000000be, 32'h000000b5, 32'h000000ac,
    32'h000000a3, 32'h0000009b, 32'h00000093, 32'h0000008c,
    32'h00000085, 32'h0000007e, 32'h00000078, 32'h00000072,
    32'h0000006c, 32'h00000067, 32'h00000062, 32'h0000005d,
    32'h00000058, 32'h00000054, 32'h00000050, 32'h0000004c,
    32'h00000048, 32'h00000044, 32'h00000041, 32'h0000003e,
    32'h0000003b, 32'h00000038, 32'h00000035, 32'h00000032,
    32'h00000030, 32'h0000002e, 32'h0000002c, 32'h0000002a,
    32'h00000028, 32'h00000026, 32'h00000024, 32'h00000022,
    32'h00000020, 32'h0000001e, 32'h0000001d, 32'h0000001c,
    32'h0000001b, 32'h0000001a, 32'h00000019, 32'h00000018,
    32'h00000017, 32'h00000016, 32'h00000015, 32'h00000014,
    32'h00000013, 32'h00000012, 32'h00000011, 32'h00000010,
    32'h0000000f, 32'h0000000e, 32'h0000000d, 32'h0000000c,
    32'h0000000b, 32'h0000000a, 32'h0000000a, 32'h0000000a,
    32'h0000000a, 32'h0000000a, 32'h0000000a, 32'h0000000a,
    32'h0000000a, 32'h0000000a, 32'h0000000a, 32'h0000000a,
    32'h0000000a, 32'h0000000a, 32'h0000000a, 32'h0000000a,
    32'h0c5eb0cc, 32'h0bc05b28, 32'h0b29f033, 32'h0a9b0a97,
    32'h0a134a0f, 32'h09925328, 32'h0917cf00, 32'h08a36b0d,
    32'h0834d8e6, 32'h07cbce0e, 32'h076803c1, 32'h070936c4,
    32'h06af273a, 32'h06599877, 32'h060850d7, 32'h05bb1999,
    32'h0571beb8, 32'h052c0ec8, 32'h04e9dad8, 32'h04aaf64d,
    32'h046f36c9, 32'h0436740c, 32'h040087d8, 32'h03cd4dda,
    32'h039ca38f, 32'h036e682e, 32'h03427c92, 32'h0318c324,
    32'h02f11fc9, 32'h02cb77cc, 32'h02a7b1cf, 32'h0285b5b8,
    32'h02656ca2, 32'h0246c0cd, 32'h02299d90, 32'h020def49,
    32'h01f3a352, 32'h01daa7f4, 32'h01c2ec5b, 32'h01ac608a,
    32'h0196f550, 32'h01829c3f, 32'h016f47a2, 32'h015cea74,
    32'h014b7855, 32'h013ae584, 32'h012b26d7, 32'h011c31b3,
    32'h010dfc04, 32'h01007c37, 32'h00f3a934, 32'h00e77a58,
    32'h00dbe76d, 32'h00d0e8a8, 32'h00c676a0, 32'h00bc8a4b,
    32'h00b31cfa, 32'h00aa2854, 32'h00a1a650, 32'h00999132,
    32'h0091e389, 32'h008a9829, 32'h0083aa27, 32'h007d14d8,
    32'h0076d3cd, 32'h0070e2d0, 32'h006b3ddf, 32'h0065e12d,
    32'h0060c91e, 32'h005bf243, 32'h00575959, 32'h0052fb48,
    32'h004ed51e, 32'h004ae410, 32'h00472576, 32'h004396ca,
    32'h004035a6, 32'h003cffc4, 32'h0039f2fa, 32'h00370d3a,
    32'h00344c91, 32'h0031af23, 32'h002f332e, 32'h002cd705,
    32'h002a9912, 32'h002877d1, 32'h002671d3, 32'h002485bc,
    32'h0022b23f, 32'h0020f622, 32'h001f503a, 32'h001dbf6a,
    32'h001c42a5, 32'h001ad8ea, 32'h00198145, 32'h00183ace,
    32'h001704aa, 32'h0015de08, 32'h0014c621, 32'h0013bc39,
    32'h0012bf9d, 32'h0011cfa2, 32'h0010eba7, 32'h00101312,
    32'h000f4551, 32'h000e81da, 32'h000dc829, 32'h000d17c1,
    32'h000c702b, 32'h000bd0f6, 32'h000b39b7, 32'h000aaa07,
    32'h000a2187, 32'h00099fda, 32'h000924a9, 32'h0008afa1,
    32'h00084073, 32'h0007d6d4, 32'h0007727d, 32'h0007132a,
    32'h0006b89b, 32'h00066293, 32'h000610d8, 32'h0005c334,
    32'h00057971, 32'h0005335f, 32'h0004f0cd, 32'h0004b190
  };
  localparam logic [31:0] GLOBAL_R [0:3] = '{
    32'h00000000, 32'h40000000, 32'h20000000, 32'h10000000
  };
  localparam logic [31:0] CLUSTER_R [0:3] = '{
    32'h00000000, 32'h40000000, 32'h10000000, 32'h30000000
  };
  // Four coherence pairs, each with zero through eight active-zero cells.
  localparam logic signed [31:0] CAPACITY [0:35] = '{
    32'h0000d1ec, 32'h0000d47b, 32'h0000d70b, 32'h0000d99a, 32'h0000dc2a, 32'h0000deb9,
    32'h0000e148, 32'h0000e3d8, 32'h0000e667, 32'h000151ec, 32'h0001547b, 32'h0001570b,
    32'h0001599a, 32'h00015c2a, 32'h00015eb9, 32'h00016148, 32'h000163d8, 32'h00016667,
    32'h000107af, 32'h00010a3e, 32'h00010cce, 32'h00010f5d, 32'h000111ed, 32'h0001147c,
    32'h0001170b, 32'h0001199b, 32'h00011c2a, 32'h00010668, 32'h000108f7, 32'h00010b87,
    32'h00010e16, 32'h000110a6, 32'h00011335, 32'h000115c4, 32'h00011854, 32'h00011ae3
  };

  logic clk = 0, rst_n = 1, tick_enable = 0, clear = 0;
  logic signed [31:0] normalized_cycle_cost_q16 = 0;
  logic signed [31:0] temperature_proxy_q16, peak_temperature_proxy_q16;
  logic [31:0] sample_count_q;
  logic [15:0] retained_state = 0;
  logic signed [31:0] global_coherence_q30 = 0, cluster_coherence_q30 = 0;
  logic signed [31:0] coherence_capacity_q16, pressure_q16, stability_margin_q16;
  logic stable;
  int unsigned profiles = 0, vectors = 0, cooling_ticks = 0, warmup_ticks = 0;
  int unsigned updates = 0, hold_edges = 0, clears = 0, resets = 0;
  int unsigned capacity_cases = 0, boundary_cases = 0, saturation_cases = 0;

  always #5 clk = ~clk;

  frp_m31_thermal_proxy u_thermal (
    .clk, .rst_n, .tick_enable, .clear, .normalized_cycle_cost_q16,
    .temperature_proxy_q16, .peak_temperature_proxy_q16, .sample_count_q
  );
  frp_m31_stability #(.CELLS(8)) u_stability (
    .retained_state, .global_coherence_q30, .cluster_coherence_q30,
    .temperature_proxy_q16, .switch_load_q16(normalized_cycle_cost_q16),
    .coherence_capacity_q16, .pressure_q16, .stability_margin_q16, .stable
  );

  task automatic check_thermal(input logic [31:0] expected_temperature,
      input logic [31:0] expected_peak, input int unsigned expected_samples);
    if ({temperature_proxy_q16, peak_temperature_proxy_q16, sample_count_q}
        !== {expected_temperature, expected_peak, 32'(expected_samples)})
      $fatal(1, "Thermal mismatch updates=%0d samples=%0d actual=%h expected=%h",
             updates, expected_samples,
             {temperature_proxy_q16, peak_temperature_proxy_q16, sample_count_q},
             {expected_temperature, expected_peak, 32'(expected_samples)});
  endtask

  task automatic check_stability(input logic signed [31:0] expected_capacity,
      input logic signed [31:0] expected_temperature);
    longint signed mathematical_pressure;
    logic signed [31:0] expected_pressure, expected_margin;
    mathematical_pressure = longint'(expected_temperature)
                          + longint'(normalized_cycle_cost_q16);
    expected_pressure = mathematical_pressure > 2147483647
                      ? 32'sh7fffffff : 32'(mathematical_pressure);
    expected_margin = expected_capacity - expected_pressure;
    if (coherence_capacity_q16 !== expected_capacity
        || pressure_q16 !== expected_pressure
        || stability_margin_q16 !== expected_margin
        || stable !== (expected_margin > 0))
      $fatal(1, "Stability mismatch capacity=%0d pressure=%0d margin=%0d stable=%b expected=%0d/%0d/%0d/%b",
             coherence_capacity_q16, pressure_q16, stability_margin_q16, stable,
             expected_capacity, expected_pressure, expected_margin, expected_margin > 0);
    if (mathematical_pressure > 2147483647) saturation_cases++;
  endtask

  task automatic reset_proxy;
    @(negedge clk);
    rst_n = 0; tick_enable = 1; clear = 1;
    normalized_cycle_cost_q16 = 32'sh7fffffff;
    #1ps;
    check_thermal(0, 0, 0);
    resets++;
    @(negedge clk);
    rst_n = 1; tick_enable = 0; clear = 0;
    normalized_cycle_cost_q16 = 0;
  endtask

  task automatic clear_proxy(input bit enabled_tick);
    @(negedge clk);
    tick_enable = enabled_tick; clear = 1;
    normalized_cycle_cost_q16 = 32'sh7fffffff;
    @(posedge clk); #1ps;
    check_thermal(0, 0, 0);
    clears++;
    @(negedge clk);
    tick_enable = 0; clear = 0; normalized_cycle_cost_q16 = 0;
  endtask

  task automatic run_sample(input logic [31:0] cost,
      input logic [31:0] expected_temperature, input logic [31:0] expected_peak,
      input int unsigned expected_samples, input bit check_hold);
    @(negedge clk);
    tick_enable = 1; normalized_cycle_cost_q16 = cost;
    @(posedge clk); #1ps;
    check_thermal(expected_temperature, expected_peak, expected_samples);
    check_stability(32'sd58983, expected_temperature);
    updates++;
    @(negedge clk); tick_enable = 0;
    if (check_hold) begin
      normalized_cycle_cost_q16 = normalized_cycle_cost_q16 ^ 32'sh7fffffff;
      repeat (2) begin
        @(posedge clk); #1ps;
        check_thermal(expected_temperature, expected_peak, expected_samples);
        hold_edges++;
      end
    end
  endtask

  initial begin : qualification
    int index;
    logic [31:0] final_peak;
    reset_proxy();
    for (int pair_index = 0; pair_index < 4; pair_index++) begin
      global_coherence_q30 = GLOBAL_R[pair_index];
      cluster_coherence_q30 = CLUSTER_R[pair_index];
      for (int zeros = 0; zeros <= 8; zeros++) begin
        // Nonzero observer inputs alternate -1 and 1; zero remains active.
        for (int cell_index = 0; cell_index < 8; cell_index++)
          retained_state[cell_index*2 +: 2] = cell_index < zeros
            ? 2'b00 : (cell_index % 2 == 0 ? 2'b11 : 2'b01);
        index = pair_index * 9 + zeros;
        for (int offset = -1; offset <= 1; offset++) begin
          normalized_cycle_cost_q16 = CAPACITY[index] + offset;
          #1ps;
          check_thermal(0, 0, 0);
          check_stability(CAPACITY[index], 0);
          boundary_cases++;
        end
        capacity_cases++;
      end
    end
    retained_state = 0; global_coherence_q30 = 0; cluster_coherence_q30 = 0;
    normalized_cycle_cost_q16 = 0;

    for (int workload = 0; workload < 2; workload++) begin
      for (int step_index = 0; step_index < 32; step_index++) begin
        index = workload * 32 + step_index;
        run_sample(GOLD[index][95:64], GOLD[index][63:32], GOLD[index][31:0],
                   step_index + 1, 1);
        vectors++;
      end
      final_peak = GOLD[workload * 32 + 31][31:0];
      for (int step_index = 0; step_index < 128; step_index++) begin
        run_sample(0, COOLING[workload * 128 + step_index], final_peak,
                   33 + step_index, 0);
        cooling_ticks++;
      end
      profiles++;
      $display("FRP_M31_THERMAL_DYNAMICS_PROFILE: PASS workload=%0d samples=%0d temperature=%h peak=%h",
               workload, sample_count_q, temperature_proxy_q16, peak_temperature_proxy_q16);

      clear_proxy(0);
      run_sample(32'd65536, 32'd655, 32'd655, 1, 0);
      warmup_ticks++;
      clear_proxy(1);
      run_sample(32'd65536, 32'd655, 32'd655, 1, 0);
      warmup_ticks++;
      reset_proxy();
    end
    if (profiles != 2 || vectors != 64 || cooling_ticks != 256 || warmup_ticks != 4
        || updates != 324 || hold_edges != 128 || clears != 4 || resets != 3
        || capacity_cases != 36 || boundary_cases != 108 || saturation_cases != 22)
      $fatal(1, "Thermal dynamics scenarios incomplete");
    $display("FRP_M31_THERMAL_DYNAMICS_TB: PASS profiles=%0d vectors=%0d cooling_ticks=%0d warmup_ticks=%0d updates=%0d hold_edges=%0d clears=%0d resets=%0d capacity_cases=%0d boundary_cases=%0d saturation_cases=%0d",
             profiles, vectors, cooling_ticks, warmup_ticks, updates, hold_edges, clears,
             resets, capacity_cases, boundary_cases, saturation_cases);
    $finish;
  end
endmodule : frp_m31_thermal_dynamics_tb
`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Reference: EXP_NEG_Q30, exp_neg_q30 and update_thermal_node_factors
// in frp_prototype_v1_7_0.py, using the default thermal coupling gain.
// The reference generates its own exponential table and calculates the
// rounded 5/4 overload scale, clipping and address using integer division.
// Every ROM address is observed through both public factor ports in every
// cell. Input histories cover holds, commits and asynchronous reset.
// Signed stress includes negative overload; the dense sweep is nonnegative.
// Compile top frp_m31_local_thermal_attenuation_tb with timing and -Irtl/m31.

`timescale 1ns/1ps
`include "frp_m31_local_thermal_attenuation.sv"

module frp_m31_attenuation_checker #(parameter int CELLS=8)(
  output logic done=0
);
  typedef logic signed [31:0] word_t;
  localparam word_t UNITY=1073741824, FLOOR_FACTOR=360200;
  logic clk=0, rst_n=1, tick_enable=0;
  logic [CELLS*32-1:0] thermal_overload_q16='0;
  wire [CELLS*32-1:0] thermal_node_factor_q30;
  wire [CELLS*32-1:0] next_thermal_node_factor_q30;
  frp_m31_local_thermal_attenuation #(.CELLS(CELLS)) dut(.*);
  word_t reference_rom[0:4095];
  word_t retained[0:CELLS-1], candidate[0:CELLS-1];
  int address[0:CELLS-1];
  bit [4095:0] visited[0:CELLS-1];
  int steps=0, checks=0, commits=0, holds=0, resets=0;
  int boundary_cases=0, dense_words=0, random_cases=0, isolated_cells=0;
  int negative_inputs=0, upper_clips=0, positive_saturations=0, negative_saturations=0;
  int positive_half_ties=0, negative_half_ties=0, rising_factors=0, falling_factors=0;
  int changed_while_held=0, reset_with_tick=0, rom_cell_pairs=0;
  int unsigned random_state=32'h77b24e19;

  function automatic longint signed scaled_overload(input word_t overload);
    /*verilator no_inline_task*/
    longint signed numerator;
    numerator=longint'(overload)*5;
    if (numerator<0) return -((-numerator+2)/4);
    return (numerator+2)/4;
  endfunction

  function automatic int lookup_address(input word_t overload);
    /*verilator no_inline_task*/
    longint signed scaled;
    scaled=scaled_overload(overload);
    if (scaled>2147483647) scaled=2147483647;
    if (scaled< -64'sd2147483648) scaled=-64'sd2147483648;
    if (scaled<0) scaled=0;
    if (scaled>524288) scaled=524288;
    return int'((scaled*4095+262144)/524288);
  endfunction

  function automatic word_t first_input(input int index);
    /*verilator no_inline_task*/
    longint signed minimum_argument;
    if (index==0) return 0;
    // First argument whose rounded lookup index is at least index.
    minimum_argument=(longint'(index)*524288-262144+4094)/4095;
    // First nonnegative overload whose rounded 5/4 scale reaches it.
    return word_t'((4*minimum_argument-2+4)/5);
  endfunction

  function automatic int unsigned random_word();
    random_state^=random_state<<13;
    random_state^=random_state>>17;
    random_state^=random_state<<5;
    return random_state;
  endfunction

  function automatic word_t boundary(input int index);
    case(index)
      0:return 32'sh80000000; 1:return -2147483647;
      2:return -1717986919; 3:return -1717986918; 4:return -1717986917;
      5:return -65536; 6:return -6; 7:return -2; 8:return -1;
      9:return 0; 10:return 1; 11:return 2; 12:return 6;
      13:return 419378; 14:return 419379;
      15:return 419429; 16:return 419430; 17:return 419431;
      18:return 1717986917; 19:return 1717986918; 20:return 1717986919;
      21:return 2147483646; default:return 2147483647;
    endcase
  endfunction

  task automatic model_candidate();
    for (int c=0;c<CELLS;c++) begin
      address[c]=lookup_address(word_t'(thermal_overload_q16[c*32+:32]));
      candidate[c]=reference_rom[address[c]];
    end
  endtask

  task automatic equal_word(input string label, input int cell_index,
                            input word_t actual, expected);
    checks++;
    if (actual!==expected)
      $fatal(1,"ATTENUATION cells=%0d step=%0d cell=%0d %s got=%0d expected=%0d",
        CELLS,steps,cell_index,label,actual,expected);
  endtask

  task automatic check_ports();
    for (int c=0;c<CELLS;c++) begin
      equal_word("retained_factor",c,word_t'(thermal_node_factor_q30[c*32+:32]),retained[c]);
      equal_word("candidate_factor",c,word_t'(next_thermal_node_factor_q30[c*32+:32]),candidate[c]);
    end
  endtask

  task automatic sample(input bit enable);
    word_t overload;
    longint signed scaled;
    clk=0; tick_enable=enable;
    model_candidate(); #1; check_ports();
    for (int c=0;c<CELLS;c++) begin
      overload=word_t'(thermal_overload_q16[c*32+:32]);
      scaled=scaled_overload(overload);
      if (enable) begin
        if (overload<0) negative_inputs++;
        if (scaled>524288) upper_clips++;
        if (scaled>2147483647) positive_saturations++;
        if (scaled< -64'sd2147483648) negative_saturations++;
        if (overload>0 && overload%4==2) positive_half_ties++;
        if (overload<0 && overload%4== -2) negative_half_ties++;
        if (candidate[c]>retained[c]) rising_factors++;
        if (candidate[c]<retained[c]) falling_factors++;
      end else if (candidate[c]!=retained[c]) changed_while_held++;
    end
    #1; clk=1;
    if (enable) begin
      for (int c=0;c<CELLS;c++) retained[c]=candidate[c];
      commits++;
    end else holds++;
    #1; check_ports();
    if (enable)
      for (int c=0;c<CELLS;c++) visited[c][address[c]]=1;
    #1; clk=0; #1; steps++;
  endtask

  task automatic reset_dut();
    // Keep the input candidate live while clearing the retained factor.
    clk=0; rst_n=0;
    for (int c=0;c<CELLS;c++) retained[c]=UNITY;
    model_candidate(); #1; check_ports();
    clk=1; #1; check_ports();
    clk=0; rst_n=1; #1; check_ports();
    if (tick_enable) reset_with_tick++;
    resets++;
  endtask

  task automatic uniform_input(input word_t overload);
    for (int c=0;c<CELLS;c++) thermal_overload_q16[c*32+:32]=overload;
  endtask

  initial begin : regression
    real value;
    word_t edge_input;
    int index, expected_index;
    // This table is generated from the analytic expression, independently
    // of the DUT's fourth-difference ROM encoding and page seeds.
    for (int a=0;a<4096;a++) begin
      value=$exp(-8.0*real'(a)/4095.0)*1073741824.0;
      reference_rom[a]=word_t'($rtoi(value+0.5));
      if (a>0 && reference_rom[a]>=reference_rom[a-1])
        $fatal(1,"Reference exponential table must decrease");
    end
    if (reference_rom[0]!=UNITY || reference_rom[4095]!=FLOOR_FACTOR)
      $fatal(1,"Unexpected reference endpoints");
    for (int c=0;c<CELLS;c++) visited[c]='0;
    #1; reset_dut(); sample(0); sample(1);

    // Distinct addresses in adjacent cells; every cell visits all 4096.
    for (int a=0;a<4096;a++) begin
      for (int c=0;c<CELLS;c++)
        thermal_overload_q16[c*32+:32]=first_input((a+127*c)%4096);
      sample(1);
      if (a%64==0) begin
        thermal_overload_q16=~thermal_overload_q16;
        sample(0);
      end
    end

    // Exercise both traversal directions at every lookup transition.
    for (int direction=0;direction<2;direction++) begin
      for (int edge_index=1;edge_index<4096;edge_index++) begin
        index=(direction==0)?edge_index:4096-edge_index;
        edge_input=first_input(index);
        if (lookup_address(edge_input-1)!=index-1 || lookup_address(edge_input)!=index)
          $fatal(1,"Reference inverse boundary failed at %0d",index);
        for (int visit=0;visit<3;visit++) begin
          uniform_input(edge_input+word_t'((direction==0)?visit-1:1-visit));
          sample(1);
          expected_index=(((direction==0)?visit-1:1-visit)<0)?index-1:index;
          for (int c=0;c<CELLS;c++)
            equal_word("lookup_transition",c,word_t'(thermal_node_factor_q30[c*32+:32]),reference_rom[expected_index]);
          boundary_cases++;
        end
      end
    end

    // Every nonnegative overload word up to and beyond exponent clipping.
    // Packing different words per cell also exercises lane order and widths.
    for (int base=0;base<419456;base+=CELLS) begin
      for (int c=0;c<CELLS;c++) thermal_overload_q16[c*32+:32]=word_t'(base+c);
      if ((base/CELLS)%11==0) sample(0);
      sample(1); dense_words+=CELLS;
    end

    // Isolated hot cells retain the floor; all other cells retain unity.
    for (int selected=0;selected<CELLS;selected++) begin
      uniform_input(0); reset_dut();
      thermal_overload_q16[selected*32+:32]=32'h7fffffff; sample(1);
      for (int c=0;c<CELLS;c++)
        equal_word("isolated_hot_cell",c,word_t'(thermal_node_factor_q30[c*32+:32]),
          (c==selected)?FLOOR_FACTOR:UNITY);
      thermal_overload_q16=~thermal_overload_q16; sample(0); sample(1);
      isolated_cells++;
    end

    // Scale saturation, exponent clipping and signed half-away boundaries.
    for (int a=0;a<23;a++) begin
      for (int c=0;c<CELLS;c++) thermal_overload_q16[c*32+:32]=boundary((a+c)%23);
      sample(0); sample(1); reset_dut(); sample(0); sample(1);
    end

    // Fixed-seed nonnegative and full signed interface input histories.
    for (int range_mode=0;range_mode<2;range_mode++) begin
      for (int iteration=0;iteration<4096;iteration++) begin
        for (int c=0;c<CELLS;c++)
          thermal_overload_q16[c*32+:32]=(range_mode==0)
            ?word_t'(random_word()%524289):word_t'(random_word());
        if (iteration%257==0) reset_dut();
        sample((iteration%7)!=0); random_cases++;
      end
    end
    uniform_input(32'sh7fffffff); tick_enable=1; reset_dut(); sample(0); sample(1);
    uniform_input(32'sh80000000); sample(0); sample(1);
    for (int c=0;c<CELLS;c++) begin
      if ($countones(visited[c])!=4096)
        $fatal(1,"Incomplete ROM output coverage cells=%0d cell=%0d",CELLS,c);
      rom_cell_pairs+=$countones(visited[c]);
    end
    if (steps!=commits+holds || boundary_cases!=24570 || dense_words!=419456
        || random_cases!=8192 || isolated_cells!=CELLS || resets!=CELLS+57)
      $fatal(1,"Incomplete attenuation sequence coverage");
    if (!(negative_inputs>0 && upper_clips>0 && positive_saturations>0
          && negative_saturations>0 && positive_half_ties>0 && negative_half_ties>0
          && rising_factors>0 && falling_factors>0 && changed_while_held>0
          && reset_with_tick>0)) $fatal(1,"Missing attenuation event");
    $display("PASS LOCAL_ATTENUATION cells=%0d steps=%0d checks=%0d commits=%0d holds=%0d resets=%0d rom_cell_pairs=%0d boundaries=%0d dense_words=%0d random=%0d isolated=%0d",
      CELLS,steps,checks,commits,holds,resets,rom_cell_pairs,boundary_cases,dense_words,random_cases,isolated_cells);
    $display("ATTENUATION_EVENTS cells=%0d negative=%0d clipped=%0d sat_pos=%0d sat_neg=%0d half_pos=%0d half_neg=%0d rising=%0d falling=%0d changed_hold=%0d reset_tick=%0d",
      CELLS,negative_inputs,upper_clips,positive_saturations,negative_saturations,
      positive_half_ties,negative_half_ties,rising_factors,falling_factors,changed_while_held,reset_with_tick);
    done=1;
  end
endmodule

module frp_m31_local_thermal_attenuation_tb;
  wire done8,done16,done32;
  frp_m31_attenuation_checker #(.CELLS(8)) cells8(.done(done8));
  frp_m31_attenuation_checker #(.CELLS(16)) cells16(.done(done16));
  frp_m31_attenuation_checker #(.CELLS(32)) cells32(.done(done32));
  initial begin
    wait(done8 && done16 && done32);
    $display("PASS LOCAL_ATTENUATION_ALL cells=8,16,32");
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1,"Local attenuation regression timeout");
  end
endmodule

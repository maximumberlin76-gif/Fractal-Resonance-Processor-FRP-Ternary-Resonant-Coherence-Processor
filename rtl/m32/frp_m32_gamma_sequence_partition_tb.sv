// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Exhaustive checkpoint-index and bank-partition sequence equivalence.
// CELLS=8/16/32/64; +seed=76. No external vectors or DUT internals are used.
// For every valid index 0..624, restore identical 624-word checkpoints into
// an eight-lane source and a CELLS-lane source. Consume 1024 targets from each
// under independent request gaps and response stalls, alternating the fast side.
// Compare every target with a sequential MT19937/real-valued Q16.16 oracle,
// then compare the two flattened streams word for word. The reference twists
// a complete state in three software-style segments, independently of RTL cycles.
// Exercise repeated twists, twists between fraction halves, atomic publication,
// held banks, ignored load offers and changing unlatched checkpoint-index inputs.
// Build: Verilator --binary --timing --assert -Irtl/m32
// --top-module frp_m32_gamma_sequence_partition_tb.

`ifndef FRP_M32_GAMMA_SEQUENCE_PARTITION_TB_SV
`define FRP_M32_GAMMA_SEQUENCE_PARTITION_TB_SV
`timescale 1ns/1ps
`include "frp_m32_gamma_target_source.sv"

module frp_m32_gamma_sequence_partition_tb #(
  parameter int CELLS=8
);
  localparam int TARGETS=1024;
  logic clk=0,rst_n=1;
  logic [1:0] load_begin=0,load_valid=0,request_valid=0,bank_ready=0;
  logic [9:0] checkpoint_index[0:1];
  logic [31:0] load_word[0:1];
  wire [1:0] load_ready,configured,load_error,request_ready,busy,bank_valid;
  wire [255:0] small_bank;
  wire [CELLS*32-1:0] wide_bank;
  logic [31:0] image[0:623],model_state[0:623],expected[0:TARGETS-1];
  logic [31:0] observed[0:1][0:TARGETS-1];
  int issued[0:1],produced[0:1],received[0:1],hold_left[0:1];
  int request_total[0:1],publish_total[0:1],consume_total[0:1];
  int word_total[0:1],target_total[0:1],stall_cycles[0:1],request_gaps[0:1];
  bit [1:0] in_flight=0;
  int unsigned seed=76,rng;
  int model_index=0,model_twists=0,split_twists=0;
  int cases=0,cycles=0,checks=0,cross_checks=0;
  logic [63:0] oracle_signature=64'hcbf29ce484222325;
  logic [63:0] stream_signature[0:1];

  frp_m32_gamma_target_source #(.CELLS(8)) u_small (
    .clk(clk),.rst_n(rst_n),.load_begin(load_begin[0]),
    .checkpoint_index(checkpoint_index[0]),.load_valid(load_valid[0]),
    .load_word(load_word[0]),.load_ready(load_ready[0]),.configured(configured[0]),
    .load_error(load_error[0]),.request_valid(request_valid[0]),
    .request_ready(request_ready[0]),.busy(busy[0]),.bank_valid(bank_valid[0]),
    .bank_ready(bank_ready[0]),.gamma_targets_q16(small_bank)
  );
  frp_m32_gamma_target_source #(.CELLS(CELLS)) wide (
    .clk(clk),.rst_n(rst_n),.load_begin(load_begin[1]),
    .checkpoint_index(checkpoint_index[1]),.load_valid(load_valid[1]),
    .load_word(load_word[1]),.load_ready(load_ready[1]),.configured(configured[1]),
    .load_error(load_error[1]),.request_valid(request_valid[1]),
    .request_ready(request_ready[1]),.busy(busy[1]),.bank_valid(bank_valid[1]),
    .bank_ready(bank_ready[1]),.gamma_targets_q16(wide_bank)
  );

  function automatic int lanes(input int channel);
    return channel==0?8:CELLS;
  endfunction
  function automatic logic [31:0] scramble(input logic [31:0] value);
    logic [31:0] x;
    x=value^(value<<13);x=x^(x>>17);return x^(x<<5);
  endfunction
  function automatic logic [31:0] random_word();
    rng=scramble(rng);return rng;
  endfunction
  function automatic logic [63:0] mix(input logic [63:0] hash,input logic [31:0] value);
    return (hash^{32'd0,value})*64'h100000001b3;
  endfunction
  task automatic require(input logic condition,input string label);
    if(condition!==1'b1)$fatal(1,"%s index=%0d cycle=%0d",label,cases,cycles);
    checks++;
  endtask
  task automatic cycle();
    #2;clk=1;#1;clk=0;#2;cycles++;
  endtask

  function automatic void twist_reference();
    logic [31:0] joined;
    for(int k=0;k<227;k++)begin
      joined=(model_state[k]&32'h80000000)|(model_state[k+1]&32'h7fffffff);
      model_state[k]=model_state[k+397]^(joined>>1)^((joined&1)!=0?32'h9908b0df:0);
    end
    for(int k=227;k<623;k++)begin
      joined=(model_state[k]&32'h80000000)|(model_state[k+1]&32'h7fffffff);
      model_state[k]=model_state[k-227]^(joined>>1)^((joined&1)!=0?32'h9908b0df:0);
    end
    joined=(model_state[623]&32'h80000000)|(model_state[0]&32'h7fffffff);
    model_state[623]=model_state[396]^(joined>>1)^((joined&1)!=0?32'h9908b0df:0);
    model_index=0;model_twists++;
  endfunction
  function automatic logic [31:0] next_reference_word(input bit second_half);
    logic [31:0] value;
    if(model_index==624)begin
      twist_reference();
      if(second_half)split_twists++;
    end
    value=model_state[model_index];model_index++;
    value=value^(value>>11);
    value=value^((value<<7)&32'h9d2c5680);
    value=value^((value<<15)&32'hefc60000);
    return value^(value>>18);
  endfunction
  function automatic logic [31:0] next_reference_target();
    logic [31:0] high_word,low_word;
    real fraction,scaled;
    high_word=next_reference_word(0);low_word=next_reference_word(1);
    fraction=($itor(high_word>>5)*67108864.0+$itor(low_word>>6))/9007199254740992.0;
    scaled=(2.0*fraction-1.0)*65536.0;
    return 32'($rtoi(scaled<0.0?scaled-0.5:scaled+0.5));
  endfunction
  task automatic prepare_reference(input int index_value);
    for(int w=0;w<624;w++)
      image[w]=scramble(seed^32'ha341316c^(32'(index_value)*32'h9e3779b9)^
                        (32'(w)*32'h85ebca6b));
    image[0]=image[0]|32'h80000000;
    for(int w=0;w<624;w++)model_state[w]=image[w];
    model_index=index_value;oracle_signature=mix(oracle_signature,32'(index_value));
    for(int k=0;k<TARGETS;k++)begin
      expected[k]=next_reference_target();
      oracle_signature=mix(oracle_signature,expected[k]);
    end
    for(int c=0;c<2;c++)stream_signature[c]=mix(stream_signature[c],32'(index_value));
  endtask

  task automatic load_checkpoint(input int index_value);
    int loaded[0:1];
    bit [1:0] accepted;
    int watchdog;
    load_begin=2'b11;load_valid=0;request_valid=0;bank_ready=0;
    for(int c=0;c<2;c++)begin checkpoint_index[c]=10'(index_value);loaded[c]=0;end
    #1;require(load_ready==0&&request_ready==0,"BEGIN_PRIORITY");
    cycle();load_begin=0;#1;
    require(configured==0&&load_error==0&&busy==0&&bank_valid==0&&load_ready==3,
            "BEGIN_STATUS");
    require(small_bank==='0&&wide_bank==='0,"BEGIN_DATA");
    watchdog=0;
    while(loaded[0]<624||loaded[1]<624)begin
      for(int c=0;c<2;c++)begin
        load_valid[c]=(loaded[c]<624)&&((c==index_value%2)||(random_word()%4!=0));
        load_word[c]=load_valid[c]?image[loaded[c]]:random_word();
        checkpoint_index[c]=10'(random_word());
      end
      #1;accepted=load_valid&load_ready;cycle();
      for(int c=0;c<2;c++)begin
        if(accepted[c])begin loaded[c]++;word_total[c]++;end
        require(!busy[c]&&!bank_valid[c]&&!load_error[c],"LOAD_SIDE_EFFECT");
        require(configured[c]==(loaded[c]==624)&&load_ready[c]==(loaded[c]<624)&&
                request_ready[c]==(loaded[c]==624),"LOAD_PROGRESS");
      end
      watchdog++;if(watchdog>4000)$fatal(1,"LOAD_TIMEOUT");
    end
    load_valid=0;
  endtask

  task automatic traffic_step(input int fast_channel);
    bit [1:0] accept_request,accept_bank,old_valid,old_busy;
    logic [2047:0] saved[0:1],current_bank[0:1];
    logic [31:0] value;
    for(int c=0;c<2;c++)begin
      request_valid[c]=(issued[c]<TARGETS/lanes(c))&&
                       ((c==fast_channel)||(random_word()%4!=0));
      bank_ready[c]=(c==fast_channel)||((hold_left[c]==0)&&(random_word()%3!=0));
      if(bank_valid[c]&&hold_left[c]>0)hold_left[c]--;
      load_valid[c]=1;load_word[c]=random_word();checkpoint_index[c]=10'(random_word());
    end
    #1;
    accept_request=request_valid&request_ready;accept_bank=bank_valid&bank_ready;
    old_valid=bank_valid;old_busy=busy;saved[0]=2048'(small_bank);saved[1]=2048'(wide_bank);
    for(int c=0;c<2;c++)begin
      if(accept_request[c])begin
        require(!in_flight[c]&&issued[c]<TARGETS/lanes(c),"EXTRA_REQUEST");
        issued[c]++;request_total[c]++;in_flight[c]=1;
      end
      if(request_ready[c]&&!request_valid[c]&&issued[c]<TARGETS/lanes(c))request_gaps[c]++;
      if(old_valid[c]&&!bank_ready[c])stall_cycles[c]++;
    end
    cycle();current_bank[0]=2048'(small_bank);current_bank[1]=2048'(wide_bank);
    for(int c=0;c<2;c++)begin
      require(configured[c]&&!load_error[c]&&!load_ready[c],"TRAFFIC_CONFIGURATION");
      if(!old_valid[c]&&bank_valid[c])begin
        require(in_flight[c]&&!busy[c]&&!request_ready[c],"PUBLICATION_ACCOUNTING");
        in_flight[c]=0;produced[c]++;publish_total[c]++;
        hold_left[c]=c==fast_channel?0:((produced[c]%8==0?31:0)+int'(random_word()%9));
      end
      if(old_valid[c]&&!accept_bank[c])
        require(bank_valid[c]&&current_bank[c]===saved[c],"STALLED_BANK_CHANGED");
      if(!bank_valid[c])require(current_bank[c]===saved[c],"PARTIAL_PUBLICATION");
      if(old_busy[c]&&!bank_valid[c])require(!request_ready[c],"READY_DURING_WORK");
      if(accept_bank[c])begin
        require(received[c]+lanes(c)<=TARGETS,"EXTRA_BANK");
        for(int lane=0;lane<lanes(c);lane++)begin
          value=saved[c][32*lane+:32];
          if(value!==expected[received[c]])
            $fatal(1,"BANK_ORACLE channel=%0d index=%0d target=%0d got=%h expected=%h",
                   c,cases,received[c],value,expected[received[c]]);
          checks++;observed[c][received[c]]=value;
          stream_signature[c]=mix(stream_signature[c],value);
          received[c]++;target_total[c]++;
        end
        consume_total[c]++;
      end
    end
  endtask

  initial begin : stimulus
    int watchdog;
    void'($value$plusargs("seed=%d",seed));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64))$fatal(1,"CELLS_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;
    for(int c=0;c<2;c++)begin
      checkpoint_index[c]=0;load_word[c]=0;request_total[c]=0;publish_total[c]=0;
      consume_total[c]=0;word_total[c]=0;target_total[c]=0;stall_cycles[c]=0;
      request_gaps[c]=0;stream_signature[c]=64'hcbf29ce484222325;
    end
    rst_n=0;#1;
    require(configured==0&&busy==0&&bank_valid==0&&request_ready==0&&load_ready==0,
            "ASYNC_RESET_STATUS");
    require(small_bank==='0&&wide_bank==='0,"ASYNC_RESET_DATA");
    cycle();rst_n=1;cycle();
    for(int index_value=0;index_value<=624;index_value++)begin
      prepare_reference(index_value);load_checkpoint(index_value);
      for(int c=0;c<2;c++)begin issued[c]=0;produced[c]=0;received[c]=0;hold_left[c]=0;end
      in_flight=0;watchdog=0;
      while(received[0]<TARGETS||received[1]<TARGETS)begin
        traffic_step(index_value%2);watchdog++;
        if(watchdog>100000)$fatal(1,"TRAFFIC_TIMEOUT");
      end
      request_valid=0;load_valid=0;bank_ready=0;
      require(!in_flight&&bank_valid==0&&busy==0,"END_OF_STREAM");
      for(int c=0;c<2;c++)
        require(issued[c]==TARGETS/lanes(c)&&produced[c]==issued[c],"CASE_BANK_COUNTS");
      for(int k=0;k<TARGETS;k++)begin
        require(observed[0][k]===observed[1][k],"BANK_PARTITION_EQUIVALENCE");cross_checks++;
      end
      cases++;
    end
    require(cases==625&&cross_checks==625*TARGETS&&model_twists==2051&&split_twists==1024,
            "REFERENCE_COVERAGE");
    for(int c=0;c<2;c++)begin
      require(target_total[c]==625*TARGETS&&word_total[c]==625*624,"WORD_ACCOUNTING");
      require(request_total[c]==625*TARGETS/lanes(c)&&publish_total[c]==request_total[c]&&
              consume_total[c]==request_total[c],"BANK_ACCOUNTING");
      require(stall_cycles[c]>0&&request_gaps[c]>0,"TIMING_COVERAGE");
      require(stream_signature[c]===oracle_signature,"STREAM_SIGNATURE");
    end
    $display("PASS GAMMA_SEQUENCE_PARTITION cells=%0d seed=%0d indices=%0d targets_per_source=%0d small_banks=%0d wide_banks=%0d words_per_source=%0d model_twists=%0d split_twists=%0d cross_checks=%0d small_stalls=%0d wide_stalls=%0d small_gaps=%0d wide_gaps=%0d checks=%0d cycles=%0d oracle_signature=%016h small_signature=%016h wide_signature=%016h",
      CELLS,seed,cases,target_total[0],consume_total[0],consume_total[1],word_total[0],
      model_twists,split_twists,cross_checks,stall_cycles[0],stall_cycles[1],
      request_gaps[0],request_gaps[1],checks,cycles,oracle_signature,
      stream_signature[0],stream_signature[1]);
    $finish;
  end
  initial begin #500000000;$fatal(1,"WATCHDOG");end
endmodule : frp_m32_gamma_sequence_partition_tb
`endif

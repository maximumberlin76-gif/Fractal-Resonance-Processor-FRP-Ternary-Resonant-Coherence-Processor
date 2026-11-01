// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Gamma-source arbitration and cancellation at every TWIST/DRAW edge.
// CELLS=8/16/32/64; +seed=76. No external vector files are required.
// Sweep checkpoint indices 624 and 623, including a twist between the two
// words of a 53-bit draw. Restart before every work edge, including the final
// publication edge; independently restore and verify two complete banks.
// Also exercise reset cut points, held-bank cancellation, all invalid indices,
// partial-load replacement, final-load/request collisions and all-zero recovery.
// The bank oracle tempers the supplied checkpoint words and uses real-valued
// uniform(-1,1) plus half-away Q16.16 conversion for the index-zero recovery.
// No internal DUT state or memory is used by the scoreboard.
// Build: Verilator --binary --timing --assert -Irtl/m32
// --top-module frp_m32_gamma_source_arbitration_tb.

`ifndef FRP_M32_GAMMA_SOURCE_ARBITRATION_TB_SV
`define FRP_M32_GAMMA_SOURCE_ARBITRATION_TB_SV
`timescale 1ns/1ps
`include "frp_m32_gamma_target_source.sv"

module frp_m32_gamma_source_arbitration_tb #(
  parameter int CELLS=8
);
  logic clk=0,rst_n=1,load_begin=0,load_valid=0,request_valid=0,bank_ready=0;
  logic [9:0] checkpoint_index=0;
  logic [31:0] load_word=0;
  wire load_ready,configured,load_error,request_ready,busy,bank_valid;
  wire [CELLS*32-1:0] gamma_targets_q16;
  logic [31:0] image_a[0:623],image_b[0:623];
  logic [31:0] expected[0:2*CELLS-1];
  int unsigned seed=76,rng;
  int cycles=0,checks=0,requests=0,published=0,consumed=0;
  int cancelled_requests=0,dropped_banks=0,begins=0,words=0,resets=0;
  int sweeps=0,twist_cuts=0,draw_cuts=0,reset_cuts=0,partial_restarts=0;
  int invalid_indices=0,checked_targets=0,idle_collisions=0;
  int loading_collisions=0,final_word_collisions=0,held_cycles=0;
  bit in_flight=0;
  logic [63:0] signature=64'hcbf29ce484222325;
  logic [63:0] oracle_signature=64'hcbf29ce484222325;
  localparam int WORK_EDGES=624+2*CELLS;

  frp_m32_gamma_target_source #(.CELLS(CELLS)) dut(.*);

  function automatic logic [31:0] scramble(input logic [31:0] value);
    logic [31:0] x;
    x=value^(value<<13);x=x^(x>>17);return x^(x<<5);
  endfunction
  function automatic logic [31:0] random_word();
    rng=scramble(rng);return rng;
  endfunction
  function automatic logic [31:0] temper_reference(input logic [31:0] value);
    logic [31:0] x;
    x=value^(value>>11);
    x=x^((x<<7)&32'h9d2c5680);
    x=x^((x<<15)&32'hefc60000);
    return x^(x>>18);
  endfunction
  function automatic logic [31:0] target_reference(input int sample_id);
    logic [31:0] high_word,low_word;
    real fraction,scaled;
    high_word=temper_reference(image_b[2*sample_id]);
    low_word=temper_reference(image_b[2*sample_id+1]);
    fraction=($itor(high_word>>5)*67108864.0+$itor(low_word>>6))/9007199254740992.0;
    scaled=(2.0*fraction-1.0)*65536.0;
    return 32'($rtoi(scaled<0.0?scaled-0.5:scaled+0.5));
  endfunction
  task automatic require(input logic condition,input string label);
    if(condition!==1'b1)$fatal(1,"%s cycle=%0d sweeps=%0d time=%t",label,cycles,sweeps,$time);
    checks++;
  endtask
  task automatic equal_word(input logic [31:0] actual,wanted,input string label);
    if(actual!==wanted)$fatal(1,"%s actual=%h expected=%h cycle=%0d",label,actual,wanted,cycles);
    checks++;signature=(signature^{wanted,actual})*64'h100000001b3;
  endtask

  task automatic cycle();
    bit accept_request,accept_word,accept_bank,was_valid,was_busy;
    logic [CELLS*32-1:0] saved;
    #2;
    accept_request=rst_n&&!load_begin&&request_valid&&request_ready;
    accept_word=rst_n&&!load_begin&&load_valid&&load_ready;
    accept_bank=rst_n&&!load_begin&&bank_valid&&bank_ready;
    was_valid=bank_valid;was_busy=busy;saved=gamma_targets_q16;
    if(accept_request)begin
      require(!in_flight,"DUPLICATE_REQUEST");in_flight=1;requests++;
    end
    if(accept_word)words++;
    if(accept_bank)consumed++;
    clk=1;#1;
    if(rst_n&&!load_begin)begin
      if(!was_valid&&bank_valid)begin
        require(in_flight,"UNREQUESTED_PUBLICATION");in_flight=0;published++;
        require(configured&&!busy&&!request_ready,"PUBLISH_STATUS");
      end
      if(was_valid&&!accept_bank)begin
        require(bank_valid&&gamma_targets_q16===saved,"HELD_BANK_CHANGED");held_cycles++;
      end
      if(!bank_valid)require(gamma_targets_q16===saved,"PARTIAL_BANK_PUBLICATION");
      if(was_busy&&!bank_valid)require(!request_ready,"REQUEST_READY_WHILE_BUSY");
      require(!(load_error&&configured),"ERROR_CONFIGURATION_CONFLICT");
    end
    clk=0;#2;cycles++;
  endtask
  task automatic cancel_accounting();
    if(in_flight)begin cancelled_requests++;in_flight=0;end
    if(bank_valid)dropped_banks++;
  endtask
  task automatic reset_source();
    cancel_accounting();rst_n=0;#1;
    require(!configured&&!load_error&&!busy&&!bank_valid&&!load_ready&&!request_ready,
            "ASYNC_RESET_STATUS");
    require(gamma_targets_q16==='0,"ASYNC_RESET_DATA");
    load_begin=0;load_valid=0;request_valid=0;bank_ready=0;
    cycle();rst_n=1;cycle();resets++;
    require(!configured&&!busy&&!bank_valid&&!request_ready,"RESET_RELEASE");
  endtask
  task automatic begin_image(input int index_value);
    if(request_ready)idle_collisions++;
    if(load_ready)loading_collisions++;
    cancel_accounting();
    checkpoint_index=10'(index_value);load_begin=1;
    load_valid=1;load_word=32'hdeadc0de;request_valid=1;bank_ready=1;
    #1;require(!load_ready&&!request_ready,"BEGIN_HANDSHAKE_PRIORITY");
    cycle();load_begin=0;load_valid=0;request_valid=0;bank_ready=0;#1;
    require(!configured&&!bank_valid&&!busy&&gamma_targets_q16==='0,"BEGIN_CLEARS_WORK");
    require(load_error==(index_value>624)&&load_ready==(index_value<=624),"BEGIN_INDEX_STATUS");
    begins++;
  endtask
  task automatic feed_words(input int image_id,input int count);
    for(int w=0;w<count;w++)begin
      require(load_ready&&!configured&&!request_ready,"LOAD_PRECONDITION");
      load_word=image_id==0?image_a[w]:(image_id==1?image_b[w]:32'd0);
      load_valid=1;request_valid=(w==623);bank_ready=(w%2==0);
      checkpoint_index=10'(random_word()%625);
      cycle();
      if(w==623)begin
        final_word_collisions++;
        require(!busy&&!bank_valid,"FINAL_WORD_MUST_NOT_ACCEPT_REQUEST");
      end else require(!configured&&!bank_valid&&!busy,"EARLY_CONFIGURATION");
      load_valid=0;request_valid=0;bank_ready=0;
      if(w<count-1&&w%31==0)begin
        load_word=random_word();request_valid=1;cycle();request_valid=0;
        require(load_ready&&!configured&&!busy,"LOAD_GAP");
      end
    end
    if(count==624)begin
      require(configured==(image_id!=2)&&load_error==(image_id==2)&&!load_ready,
              "COMPLETE_LOAD_STATUS");
      require(request_ready==(image_id!=2),"COMPLETE_LOAD_READY");
    end
  endtask
  task automatic load_image(input int index_value,input int image_id);
    begin_image(index_value);feed_words(image_id,624);
  endtask
  task automatic start_request();
    require(request_ready&&!bank_valid&&!busy,"REQUEST_PRECONDITION");
    request_valid=1;cycle();request_valid=0;
    require(busy&&!bank_valid&&!request_ready,"REQUEST_ACCEPTANCE");
  endtask
  task automatic poison_inputs();
    // These offers cannot load a word or start another request during work.
    load_valid=1;load_word=random_word();checkpoint_index=10'(random_word());
    request_valid=1;bank_ready=0;
  endtask
  task automatic advance_work(input int count);
    for(int k=0;k<count;k++)begin
      poison_inputs();cycle();
    end
    load_valid=0;request_valid=0;
  endtask
  task automatic await_bank();
    int watchdog;
    watchdog=0;
    while(!bank_valid)begin
      poison_inputs();cycle();watchdog++;
      if(watchdog>2000)$fatal(1,"BANK_TIMEOUT");
    end
    load_valid=0;request_valid=0;
  endtask
  task automatic check_bank(input int bank_id);
    require(bank_valid&&!busy&&!request_ready,"BANK_STATUS");
    for(int lane=0;lane<CELLS;lane++)begin
      equal_word(gamma_targets_q16[32*lane+:32],expected[bank_id*CELLS+lane],"BANK_ORACLE");
      checked_targets++;
    end
  endtask
  task automatic recover_two_banks();
    int before_requests,pause_length;
    start_request();
    for(int bank_id=0;bank_id<2;bank_id++)begin
      await_bank();check_bank(bank_id);
      pause_length=3+int'(random_word()%5);
      repeat(pause_length)begin poison_inputs();cycle();end
      before_requests=requests;
      request_valid=1;bank_ready=1;cycle();bank_ready=0;load_valid=0;
      require(!bank_valid&&!busy&&request_ready,"CONSUME_STATUS");
      require(requests==before_requests,"CONSUME_MUST_NOT_REISSUE");
      if(bank_id==0)begin
        cycle();request_valid=0;
        require(requests==before_requests+1&&busy&&!bank_valid,"HELD_REQUEST_NEXT_EDGE");
      end else request_valid=0;
    end
  endtask

  initial begin : stimulus
    int index_value,cut,partial_count;
    void'($value$plusargs("seed=%d",seed));
    if(!(CELLS==8||CELLS==16||CELLS==32||CELLS==64))$fatal(1,"CELLS_RANGE");
    rng=seed^32'h6d2b79f5;if(rng==0)rng=1;
    for(int w=0;w<624;w++)begin
      image_a[w]=scramble(seed^32'h13579bdf^(32'(w)*32'h9e3779b9));
      image_b[w]=scramble(seed^32'h2468ace1^(32'(w)*32'h85ebca6b));
    end
    image_a[0]=image_a[0]|32'h80000000;image_b[0]=image_b[0]|32'h80000000;
    for(int k=0;k<2*CELLS;k++)begin
      expected[k]=target_reference(k);
      oracle_signature=(oracle_signature^{32'd0,expected[k]})*64'h100000001b3;
    end
    reset_source();
    // Index 623 starts with DRAW, crosses TWIST between fraction halves,
    // then resumes DRAW. Index 624 starts with a complete TWIST.
    for(int origin=0;origin<2;origin++)begin
      index_value=origin==0?624:623;
      for(cut=0;cut<WORK_EDGES;cut++)begin
        load_image(index_value,0);start_request();advance_work(cut);
        require(busy&&!bank_valid&&in_flight,"ABORT_CUT_PRECONDITION");
        if((origin==0&&cut<624)||(origin==1&&cut>=1&&cut<=624))twist_cuts++;
        else draw_cuts++;
        begin_image(0);feed_words(1,624);recover_two_banks();sweeps++;
      end
    end
    // Asynchronous reset before the first, boundary and final work edges.
    for(int origin=0;origin<2;origin++)begin
      for(int position=0;position<5;position++)begin
        case(position)
          0:cut=0;
          1:cut=1;
          2:cut=623;
          3:cut=624;
          default:cut=WORK_EDGES-1;
        endcase
        load_image(origin==0?624:623,0);start_request();advance_work(cut);
        require(busy&&!bank_valid&&in_flight,"RESET_CUT_PRECONDITION");
        reset_source();load_image(0,1);recover_two_banks();reset_cuts++;
      end
    end
    for(int position=0;position<4;position++)begin
      case(position)
        0:partial_count=0;
        1:partial_count=1;
        2:partial_count=311;
        default:partial_count=623;
      endcase
      begin_image(624);feed_words(0,partial_count);
      require(load_ready&&!configured,"PARTIAL_RESTART_PRECONDITION");
      begin_image(0);feed_words(1,624);recover_two_banks();partial_restarts++;
    end
    for(int invalid_index=625;invalid_index<1024;invalid_index++)begin
      begin_image(invalid_index);load_valid=1;request_valid=1;bank_ready=1;
      cycle();load_valid=0;request_valid=0;bank_ready=0;
      require(load_error&&!configured&&!busy&&!bank_valid&&!request_ready&&!load_ready,
              "INVALID_INDEX_RETENTION");invalid_indices++;
    end
    load_image(0,1);recover_two_banks();
    load_image(0,2);request_valid=1;repeat(3)cycle();request_valid=0;
    require(load_error&&!configured&&!busy&&!bank_valid,"ALL_ZERO_REJECTION");
    load_image(0,1);recover_two_banks();
    // A ready consumer and held request cannot rescue a bank cancelled by
    // load_begin or reset; the replacement starts from its own checkpoint.
    for(int action_id=0;action_id<2;action_id++)begin
      load_image(0,1);start_request();await_bank();check_bank(0);
      request_valid=1;bank_ready=1;
      if(action_id==0)begin_image(0);
      else begin reset_source();begin_image(0);end
      feed_words(1,624);recover_two_banks();
    end
    require(sweeps==2*WORK_EDGES&&twist_cuts==1248&&draw_cuts==4*CELLS,
            "SWEEP_ACCOUNTING");
    require(reset_cuts==10&&partial_restarts==4&&invalid_indices==399&&resets==12,
            "RECOVERY_ACCOUNTING");
    require(requests==3*sweeps+48&&published==2*sweeps+38&&consumed==2*sweeps+36&&
            cancelled_requests==sweeps+10&&dropped_banks==2,"TRANSACTION_TOTALS");
    require(requests==published+cancelled_requests&&published==consumed+dropped_banks&&
            !in_flight&&!bank_valid&&!busy,"TRANSACTION_LEDGER");
    require(begins==2*sweeps+434&&words==1248*sweeps+20279,"LOAD_ACCOUNTING");
    require(checked_targets==CELLS*published&&idle_collisions>0&&loading_collisions==4&&
            final_word_collisions==2*sweeps+31&&held_cycles>0,"COLLISION_ACCOUNTING");
    $display("PASS GAMMA_SOURCE_ARBITRATION cells=%0d seed=%0d sweeps=%0d twist_cuts=%0d draw_cuts=%0d reset_cuts=%0d partial_restarts=%0d invalid_indices=%0d requests=%0d published=%0d consumed=%0d cancelled=%0d dropped=%0d begins=%0d words=%0d resets=%0d targets=%0d idle_collisions=%0d loading_collisions=%0d final_word_collisions=%0d held_cycles=%0d checks=%0d cycles=%0d oracle_signature=%016h signature=%016h",
      CELLS,seed,sweeps,twist_cuts,draw_cuts,reset_cuts,partial_restarts,invalid_indices,
      requests,published,consumed,cancelled_requests,dropped_banks,begins,words,resets,
      checked_targets,idle_collisions,loading_collisions,final_word_collisions,held_cycles,
      checks,cycles,oracle_signature,signature);
    $finish;
  end
  initial begin #500000000;$fatal(1,"WATCHDOG");end
endmodule : frp_m32_gamma_source_arbitration_tb
`endif

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// FRP M32 CSR regression for CELLS=8, 16 or 32.
// Includes 24 scheduler/source/automatic-target profiles per cell count,
// directed active-zero routes, per-cell loads and telemetry, dyadic coherence,
// packed request windows, reset timing and a bus-write reference model.
// The reference model uses accepted bus transactions and its own register arrays.
// The telemetry checks compare CSR words with the corresponding core outputs.
// Compile with SystemVerilog timing and assertions enabled, the selected CELLS
// parameter, and include paths rtl/m22, rtl/m31, rtl/m32, fpga/m32, fpga/m32_csr.
// Run from the repository root so the phase sine ROM path resolves.

`timescale 1ns/1ps
`include "frp_m32_csr_top.sv"
module frp_m32_csr_multicell_tb #(parameter int CELLS=8);
 localparam int LANES=CELLS/4, IDX=$clog2(CELLS), LEVELS=$clog2(CELLS), WORDS=(CELLS*2+31)/32;
 logic [63:0] saved_phase=0,saved_exec=0,saved_target=0;
 int scale_reads=0, cell_reads=0, route_samples=0;
 logic clk=0; always #5 clk=~clk;
 logic rst_n_async=1,csr_valid=0,csr_write=0;
 logic [7:0] csr_addr=0;
 logic [31:0] csr_wdata=0,csr_rdata;
 logic csr_ready,csr_error;
 frp_m32_csr_top #(.CELLS(CELLS)) dut(.*);
 int reads=0,errors=0,ticks=0,commits=0,profiles=0,checks=0;
 int count_model=0;
 bit pending=0, valid_model=0;
 logic [1:0] reset_model=0;
 always @(posedge clk or negedge rst_n_async) begin
   if (!rst_n_async) reset_model <= 0;
   else reset_model <= {reset_model[0],1'b1};
 end
 always @(posedge clk) begin
   if (!reset_model[1]) begin count_model=0;pending=0;valid_model=0;end
   else begin
     valid_model=pending;
     if(pending) begin count_model++;commits++;end
     pending=csr_valid && csr_write && csr_addr==0 && (csr_wdata==1 || csr_wdata==512);
   end
   if(!reset_model[1] || (csr_valid && csr_write && csr_addr==0 && csr_wdata==2)) begin
     saved_phase=0;saved_exec=0;saved_target=0;
   end else if(pending) begin
     saved_phase=64'({dut.u_fpga.u_m32_core.phase_request_target,dut.u_fpga.u_m32_core.phase_request_cell_index,dut.u_fpga.u_m32_core.phase_request_valid});
     saved_exec=64'({dut.u_fpga.u_m32_core.execution_request_target,dut.u_fpga.u_m32_core.execution_request_cell_index,dut.u_fpga.u_m32_core.execution_request_valid});
     saved_target=64'(dut.u_fpga.u_m32_core.execution_target_bank);
   end
   #1;
   if(dut.local_stability_sample_count_q!==32'(count_model))
     $fatal(1,"count got=%0d exp=%0d",dut.local_stability_sample_count_q,count_model);
   if(dut.u_fpga.actual_direct_events!=0 || dut.u_fpga.reserved_state_events!=0)
     $fatal(1,"state invariant");
   if(dut.local_stability_valid_q !== valid_model) $fatal(1,"sample-valid timing");
   if((dut.local_page_q && dut.stability_page_q) || (dut.scale_page_q && (dut.local_page_q || dut.stability_page_q))) $fatal(1,"page exclusivity");
   checks++;
 end
 task automatic transfer(input bit w,input int a,input logic[31:0] data,input bit err);
   @(negedge clk);csr_valid=1;csr_write=w;csr_addr=8'(a);csr_wdata=data;
   #1;
   if(!csr_ready || csr_error!==err) $fatal(1,"bus a=%h w=%b err=%b expected=%b",a,w,csr_error,err);
   if((w||err) && csr_rdata!==0) $fatal(1,"nonzero error/write data");
   if(err) errors++;
   @(posedge clk);#2;
   csr_valid=0;
 endtask
 task automatic wr(input int a,input logic[31:0] d);transfer(1,a,d,0);endtask
 task automatic rd(input int a,input logic[31:0] expected);
   @(negedge clk);csr_valid=1;csr_write=0;csr_addr=8'(a);csr_wdata=0;#1;
   if(!csr_ready || csr_error || csr_rdata!==expected)
     $fatal(1,"read a=%h got=%h expected=%h error=%b",a,csr_rdata,expected,csr_error);
   reads++;@(posedge clk);#2;csr_valid=0;
 endtask
 function automatic logic[31:0] expected(input int a);
   case(a)
      'h68: expected=32'(dut.u_fpga.u_m32_core.local_coherence_compression_q30);
      'h6c: expected=32'(dut.u_fpga.u_m32_core.local_effective_coherence_q30);
      'h70: expected=32'(dut.u_fpga.u_m32_core.local_coherence_capacity_q16);
      'h74: expected=32'(dut.u_fpga.u_m32_core.local_pressure_q16);
      'h78: expected=32'(dut.u_fpga.u_m32_core.local_stability_margin_q16);
      'h7c: expected=32'(dut.u_fpga.u_m32_core.local_stable);
      'h80: expected=32'(dut.u_fpga.u_m32_core.local_previous_margin_q16);
      'h84: expected=32'(dut.u_fpga.u_m32_core.local_stability_valid_q);
      'h88: expected=32'(dut.u_fpga.u_m32_core.local_stability_sample_count_q);
      'h8c: expected=32'(dut.u_fpga.u_m32_core.local_stability_raw_coherence_q30);
      'h90: expected=32'(dut.u_fpga.u_m32_core.local_stability_cluster_coherence_q30);
      'h94: expected=32'(dut.u_fpga.u_m32_core.local_stability_mean_heat_q16);
      'h98: expected=32'(dut.u_fpga.u_m32_core.local_stability_mean_overload_q16);
      'h9c: expected=32'(dut.u_fpga.u_m32_core.local_stability_mean_lag_q16);
      'ha0: expected=32'(dut.u_fpga.u_m32_core.local_stability_neutral_fraction_q30);
      'ha4: expected=32'(dut.u_fpga.u_m32_core.local_stability_compression_arg_q16);
      'ha8: expected=32'(dut.u_fpga.u_m32_core.local_stability_switch_load_q16);
      'hac: expected=dut.u_fpga.u_m32_core.group_coherence_q30[0 +: 32];
      'hb0: expected=dut.u_fpga.u_m32_core.group_coherence_q30[32 +: 32];
      'hb4: expected=dut.u_fpga.u_m32_core.group_coherence_q30[64 +: 32];
      'hb8: expected=dut.u_fpga.u_m32_core.group_coherence_q30[96 +: 32];
      'hbc: expected=dut.u_fpga.u_m32_core.group_coherence_q30[128 +: 32];
      'hc0: expected=dut.u_fpga.u_m32_core.group_coherence_q30[160 +: 32];
      'hc4: expected=dut.u_fpga.u_m32_core.group_coherence_q30[192 +: 32];
      'hc8: expected=dut.u_fpga.u_m32_core.level_mean_coherence_q30[0 +: 32];
      'hcc: expected=dut.u_fpga.u_m32_core.level_mean_coherence_q30[32 +: 32];
      'hd0: expected=dut.u_fpga.u_m32_core.level_mean_coherence_q30[64 +: 32];
      'hd4: expected=dut.u_fpga.u_m32_core.level_min_coherence_q30[0 +: 32];
      'hd8: expected=dut.u_fpga.u_m32_core.level_min_coherence_q30[32 +: 32];
      'hdc: expected=dut.u_fpga.u_m32_core.level_min_coherence_q30[64 +: 32];
      'he0: expected=dut.u_fpga.u_m32_core.level_max_coherence_q30[0 +: 32];
      'he4: expected=dut.u_fpga.u_m32_core.level_max_coherence_q30[32 +: 32];
      'he8: expected=dut.u_fpga.u_m32_core.level_max_coherence_q30[64 +: 32];
      'hec: expected=dut.u_fpga.u_m32_core.level_dispersion_q30[0 +: 32];
      'hf0: expected=dut.u_fpga.u_m32_core.level_dispersion_q30[32 +: 32];
      'hf4: expected=dut.u_fpga.u_m32_core.level_dispersion_q30[64 +: 32];

      'hfc:expected='h46523203;
      default:expected=0;
   endcase
 endfunction
 task automatic inspect_scale;
   logic[63:0] full;
   logic[31:0] old_ticks;
   old_ticks=dut.ticks_recorded_q;
   wr(0,260);rd('hfc,'h46523204);
   rd('h68,32'(CELLS));rd('h6c,32'(LANES));rd('h70,32'(IDX));rd('h74,32);
   rd('h78,32'(LEVELS));rd('h7c,32'(CELLS-1));rd('ha4,32'(LANES*(IDX+3)));rd('ha8,32'(CELLS*2));
   for(int g=0;g<CELLS-1;g++) begin
     wr('h84,32'(g));rd('h84,32'(g));rd('h88,dut.u_fpga.u_m32_core.group_coherence_q30[g*32 +:32]);scale_reads++;
   end
   for(int l=0;l<LEVELS;l++) begin
     wr('h8c,32'(l));rd('h8c,32'(l));rd('ha0,32'(2<<l));
     rd('h90,dut.u_fpga.u_m32_core.level_mean_coherence_q30[l*32 +:32]);
     rd('h94,dut.u_fpga.u_m32_core.level_min_coherence_q30[l*32 +:32]);
     rd('h98,dut.u_fpga.u_m32_core.level_max_coherence_q30[l*32 +:32]);
     rd('h9c,dut.u_fpga.u_m32_core.level_dispersion_q30[l*32 +:32]);scale_reads+=4;
   end
   for(int w=0;w<WORDS;w++) begin
     wr('h80,32'(w));rd('h80,32'(w));
     full=64'(dut.u_fpga.u_m32_core.state_out);rd('hb0,full[w*32+:32]);
     full=64'(dut.u_fpga.u_m32_core.pending_route_out);rd('hb4,full[w*32+:32]);
     full=64'(dut.u_fpga.u_m32_core.registered_target_q);rd('hb8,full[w*32+:32]);
     full=64'(dut.u_fpga.u_m32_core.phase_target_source);rd('hbc,full[w*32+:32]);
     rd('hac,saved_target[w*32+:32]);rd('hc0,saved_phase[w*32+:32]);rd('hc4,saved_exec[w*32+:32]);scale_reads+=7;
     wr(0,256);rd('hf0,saved_phase[w*32+:32]);rd('hf4,saved_exec[w*32+:32]);rd('hf8,saved_target[w*32+:32]);
     wr(0,260);
   end
   transfer(1,'h80,32'(WORDS),1);rd('h80,32'(WORDS-1));
   transfer(1,'h84,32'(CELLS-1),1);rd('h84,32'(CELLS-2));
   transfer(1,'h8c,32'(LEVELS),1);rd('h8c,32'(LEVELS-1));
   wr('h80,0);rd('h28,old_ticks);
   wr(0,258);
 endtask
 task automatic routes;
   reset();
   for(int batch=0;batch<4;batch++) begin
     for(int step_index=0;step_index<5;step_index++) begin
       for(int lane=0;lane<LANES;lane++) begin
         wr(8,32'(lane));wr(12,32'(batch*LANES+lane));wr(16,(step_index<1 || step_index>2)?1:3);wr(20,1);
         rd(8,32'(lane));rd(12,32'(batch*LANES+lane));
       end
       wr(0,1);ticks++;
       repeat(2) @(negedge clk);
       for(int lane=0;lane<LANES;lane++) begin
         wr('h18,32'(batch*LANES+lane));
         rd('h34,(step_index==0 || step_index==4)?1:((step_index==2)?3:0));
         rd('h38,(step_index==1)?3:((step_index==3)?1:0));route_samples++;
       end
       inspect_scale();
       wr(0,256);
     end
   end
 endtask

 task automatic inspect_cells;
   for(int c=0;c<CELLS;c++) begin
     wr(0,256);wr(24,32'(c));
     rd('h7c,dut.u_fpga.u_m32_core.phase_word_q[c*32+:32]);
     rd('h80,dut.u_fpga.u_m32_core.frequency_current_q16[c*32+:32]);
     rd('h84,dut.u_fpga.u_m32_core.coupling_field_q16[c*32+:32]);
     rd('h88,dut.u_fpga.u_m32_core.phase_projection_q30[c*32+:32]);
     rd('h8c,32'(dut.u_fpga.u_m32_core.phase_target_source[c*2+:2]));
     rd('h90,32'(dut.u_fpga.u_m32_core.registered_target_q[c*2+:2]));
     wr(0,257);
     rd('h6c,32'(c*1333-5000));rd('h70,32'(c*1333-5000));
     rd('h70,dut.u_fpga.u_m32_core.local_gamma_noise_target_q16[c*32+:32]);
     rd('h74,dut.u_fpga.u_m32_core.local_gamma_noise_state_q16[c*32+:32]);
     rd('h78,dut.u_fpga.u_m32_core.local_gamma_drift_word[c*32+:32]);
     rd('h7c,dut.u_fpga.u_m32_core.local_gamma_effective_word[c*32+:32]);
     rd('h80,dut.u_fpga.u_m32_core.phase_gamma_effective_word[c*32+:32]);
     rd('h84,dut.u_fpga.u_m32_core.local_heat_q16[c*32+:32]);
     rd('h88,dut.u_fpga.u_m32_core.local_heat_peak_q16[c*32+:32]);
     rd('h8c,dut.u_fpga.u_m32_core.local_generated_power_q16[c*32+:32]);
     rd('h90,dut.u_fpga.u_m32_core.local_thermal_dissipation_q16[c*32+:32]);
     rd('h94,dut.u_fpga.u_m32_core.local_thermal_diffusion_q16[c*32+:32]);
     rd('h98,dut.u_fpga.u_m32_core.local_thermal_overload_q16[c*32+:32]);
     rd('h9c,dut.u_fpga.u_m32_core.local_thermal_node_factor_q30[c*32+:32]);
     rd('ha0,dut.u_fpga.u_m32_core.local_frequency_lag_q16[c*32+:32]);
     rd('hb0,dut.u_fpga.u_m32_core.local_next_heat_q16[c*32+:32]);
     rd('hb4,dut.u_fpga.u_m32_core.local_next_overload_q16[c*32+:32]);
     rd('hb8,dut.u_fpga.u_m32_core.local_next_gamma_drift_word[c*32+:32]);
     rd('hbc,dut.u_fpga.u_m32_core.local_next_gamma_effective_word[c*32+:32]);
     rd('hc0,dut.u_fpga.u_m32_core.local_next_thermal_node_factor_q30[c*32+:32]);
     rd('hc4,dut.u_fpga.u_m32_core.phase_thermal_node_factor_q30[c*32+:32]);
     cell_reads+=27;
   end
   wr(0,258);
 endtask
 task automatic scan;
   inspect_scale();
   wr(0,258);
   for(int a='h68;a<='hf4;a+=4) rd(a,expected(a));
   rd('hfc,'h46523203);
 endtask
 task automatic reset;
   @(negedge clk);rst_n_async=0;csr_valid=1;csr_write=1;csr_addr=0;csr_wdata=1;
   #1;if(csr_ready || csr_error || csr_rdata!=0) $fatal(1,"reset bus");
   @(negedge clk);rst_n_async=1;
   #1;if(csr_ready) $fatal(1,"early release");
   @(negedge clk);csr_valid=0;
   repeat(3) @(negedge clk);
   rd('hfc,'h46523201);
 endtask
  logic [31:0] model_phase [CELLS];
  logic [31:0] model_frequency [CELLS];
  logic [31:0] model_gamma [CELLS];
  logic [31:0] model_thermal [CELLS];
  logic [31:0] model_gamma_target [CELLS];
  int model_req_cell [LANES];
  int model_req_target [LANES];
  int model_req_valid [LANES];
  int model_page,model_lane,model_cell,model_mode,model_auto;
  int model_sources,model_word,model_group,model_level;
  int model_writes=0,model_rejected=0,model_audits=0,model_reads=0;
  int random_writes=0,random_ticks=0;
  logic [31:0] random_state=32'h69c5a13d;

  function automatic logic [31:0] next_random;
    logic [31:0] x;
    x=random_state;
    x=x^(x<<13);x=x^(x>>17);x=x^(x<<5);
    random_state=x;
    return x;
  endfunction

  task automatic initialize_model;
    model_page=0;model_lane=0;model_cell=0;model_mode=0;model_auto=0;
    model_sources=0;model_word=0;model_group=0;model_level=0;
    for(int c=0;c<CELLS;c++) begin
      model_phase[c]=0;model_frequency[c]=0;model_gamma[c]=0;
      model_thermal[c]=32'h40000000;model_gamma_target[c]=0;
    end
    for(int l=0;l<LANES;l++) begin
      model_req_cell[l]=0;model_req_target[l]=0;model_req_valid[l]=0;
    end
  endtask

  // The model records accepted bus writes; it does not read DUT storage.
  task automatic model_write(input int a,input logic [31:0] d);
    bit valid_payload;
    valid_payload=0;
    if((a&3)==0) begin
      case(a)
        0: valid_payload=(d==1 || d==2 || d==4 || d==8 || d==512
                          || d==256 || d==257 || d==258 || d==260);
        4: valid_payload=(d<=2);
        8: valid_payload=(d<32'(LANES));
        12,24: valid_payload=(d<32'(CELLS));
        16: valid_payload=(d==0 || d==1 || d==3);
        20: valid_payload=(d<=1);
        default: begin
          case(model_page)
            0: begin
              if(a=='h68) valid_payload=(d<=1);
              if(a=='h6c || a=='h70 || a=='h74 || a=='h78) valid_payload=1;
            end
            1: begin
              if(a=='h68) valid_payload=(d<=3);
              if(a=='h6c) valid_payload=1;
            end
            4: begin
              if(a=='h80) valid_payload=(d<32'(WORDS));
              if(a=='h84) valid_payload=(d<32'(CELLS-1));
              if(a=='h8c) valid_payload=(d<32'(LEVELS));
            end
            default: begin end
          endcase
        end
      endcase
    end
    transfer(1,a,d,!valid_payload);
    model_writes++;
    if(!valid_payload) model_rejected++;
    else begin
      case(a)
        0: begin
          if(d==1 || d==512) begin ticks++;random_ticks++;end
          if(d==1 || d==4 || d==512)
            for(int l=0;l<LANES;l++) model_req_valid[l]=0;
          case(d)
            256: model_page=0;
            257: model_page=1;
            258: model_page=2;
            260: model_page=4;
            default: begin end
          endcase
        end
        4: model_mode=int'(d);
        8: model_lane=int'(d);
        12: model_req_cell[model_lane]=int'(d);
        16: model_req_target[model_lane]=int'(d);
        20: model_req_valid[model_lane]=int'(d);
        24: model_cell=int'(d);
        default: begin
          case(model_page)
            0: begin
              case(a)
                'h68: model_auto=int'(d);
                'h6c: model_phase[model_cell]=d;
                'h70: model_frequency[model_cell]=d;
                'h74: model_gamma[model_cell]=d;
                'h78: model_thermal[model_cell]=d;
                default: begin end
              endcase
            end
            1: begin
              if(a=='h68) model_sources=int'(d);
              if(a=='h6c) model_gamma_target[model_cell]=d;
            end
            4: begin
              if(a=='h80) model_word=int'(d);
              if(a=='h84) model_group=int'(d);
              if(a=='h8c) model_level=int'(d);
            end
            default: begin end
          endcase
        end
      endcase
    end
  endtask

  task automatic model_read(input int a,input logic [31:0] value);
    rd(a,value);model_reads++;
  endtask

  task automatic audit_model;
    int saved_page,saved_cell,saved_lane;
    saved_page=model_page;saved_cell=model_cell;saved_lane=model_lane;
    model_read('hfc,32'h46523201+32'(model_page==4?3:model_page));
    model_read(4,32'(model_mode));
    model_read(8,32'(model_lane));model_read(24,32'(model_cell));
    for(int l=0;l<LANES;l++) begin
      model_write(8,32'(l));
      model_read(12,32'(model_req_cell[l]));
      model_read(16,32'(model_req_target[l]));
      model_read(20,32'(model_req_valid[l]));
    end
    model_write(0,256);model_read('h68,32'(model_auto));
    for(int c=0;c<CELLS;c++) begin
      model_write(24,32'(c));
      model_read('h6c,model_phase[c]);model_read('h70,model_frequency[c]);
      model_read('h74,model_gamma[c]);model_read('h78,model_thermal[c]);
    end
    model_write(0,257);model_read('h68,32'(model_sources));
    for(int c=CELLS-1;c>=0;c--) begin
      model_write(24,32'(c));model_read('h6c,model_gamma_target[c]);
    end
    model_write(0,260);
    model_read('h80,32'(model_word));model_read('h84,32'(model_group));
    model_read('h8c,32'(model_level));
    model_read('hc8,32'(model_cell));model_read('hcc,32'(model_lane));
    model_write(24,32'(saved_cell));model_write(8,32'(saved_lane));
    model_write(0,32'(256+saved_page));model_audits++;
  endtask

  task automatic randomized_registers;
    logic [31:0] r,d;
    int address;
    reset();initialize_model();audit_model();
    // Unique patterns expose aliasing between cell and lane indices.
    for(int c=0;c<CELLS;c++) begin
      model_write(24,32'(c));
      model_write('h6c,32'h80000001^(32'(c)*32'h01010101));
      model_write('h70,32'hffff0000+32'(c));
      model_write('h74,32'h26666666^(32'(c)*32'h00100101));
      model_write('h78,32'h40000000-32'(c*1024));
    end
    for(int l=0;l<LANES;l++) begin
      model_write(8,32'(l));model_write(12,32'(CELLS-1-l));
      model_write(16,(l%2)?3:1);model_write(20,1);
    end
    model_write(0,257);
    for(int c=0;c<CELLS;c++) begin
      model_write(24,32'(c));model_write('h6c,32'(c*1777-23456));
    end
    audit_model();
    for(int c=0;c<CELLS;c++) begin
      model_write(0,256);model_write(24,32'(c));
      model_write(24,32'(CELLS+c));
      model_write('h6c,32'h12340000+32'(c));
    end
    for(int l=0;l<LANES;l++) begin
      model_write(8,32'(l));model_write(8,32'(LANES+l));
      model_write(16,(l%2)?1:3);model_write(16,2);
    end
    audit_model();
    for(int i=0;i<2048;i++) begin
      r=next_random();d=next_random();address=0;
      case(r%24)
        0: begin
          address=0;
          case(d%4)
            0:d=256;1:d=257;2:d=258;3:d=260;
          endcase
        end
        1: begin
          address=0;
          case(d%5)
            0:d=1;1:d=2;2:d=4;3:d=8;4:d=512;
          endcase
        end
        2: begin address=4;d=d%4;end
        3: begin address=8;d=d%(LANES+2);end
        4: begin address=12;d=d%(CELLS+2);end
        5: begin address=16;d=d%4;end
        6: begin address=20;d=d%3;end
        7: begin address=24;d=d%(CELLS+2);end
        8: address='h6c;
        9: address='h70;
        10: address='h74;
        11: address='h78;
        12: begin address='h68;d=d%5;end
        13: begin address='h80;d=d%3;end
        14: begin address='h84;d=d%(CELLS+1);end
        15: begin address='h8c;d=d%(LEVELS+1);end
        16: address='hfc;
        17: address=int'((r>>8)&255)|1;
        18: begin address=0;d=d|32'h80000000;end
        19: begin address=24;d=32'hffffffff;end
        20: begin address=8;d=32'hffffffff;end
        21: begin address=4;d=3;end
        22: begin address=16;d=2;end
        23: address=int'((r>>8)&252);
      endcase
      model_write(address,d);random_writes++;
      if((i%32)==31) audit_model();
    end
    reset();initialize_model();audit_model();
  endtask

 logic [(CELLS*64)-1:0] retained;
 logic [31:0] margin_saved,count_saved;
 initial begin
   routes();reset();
   wr(0,260);
   for(int a=0;a<256;a++) begin
     if(a%4!=0) begin transfer(0,a,0,1);transfer(1,a,0,1);end
     else if(a>=104) begin
       if(a!='h80 && a!='h84 && a!='h8c) transfer(1,a,0,1);
       if(a>='hd0 && a<'hfc) transfer(0,a,0,1);
     end
   end
   transfer(1,8,32'(LANES),1);transfer(1,12,32'(CELLS),1);transfer(1,24,32'(CELLS),1);
   transfer(1,'h80,'hffffffff,1);transfer(1,'h84,'hffffffff,1);transfer(1,'h8c,'hffffffff,1);
   for(int page=0;page<3;page++) begin
     wr(0,256+page);
     rd('hfc,'h46523201+page);
     for(int a=0;a<256;a++) begin
       if(a%4!=0) begin transfer(0,a,0,1);transfer(1,a,'hdeadbeef,1);end
       else if(a>=104) begin
         if(page==2 || (page==1 && a>=112) || (page==0 && a>=124))
           transfer(1,a,'hdeadbeef,1);
         if((page==1 && a>=200 && a<252) || (page==2 && a==248))
           transfer(0,a,0,1);
       end
     end
     transfer(0,0,0,1);
     transfer(1,0,259,1);
     transfer(1,0,'h80000102,1);
     transfer(1,0,3,1);
   end
   for(int mode=0;mode<3;mode++)
   for(int sources=0;sources<4;sources++)
   for(int auto_mode=0;auto_mode<2;auto_mode++) begin
     reset();profiles++;
     wr(4,32'(mode));
     wr('h68,32'(auto_mode));
     for(int c=0;c<CELLS;c++) begin
       wr('h18,32'(c));
       wr('h6c,32'(c)*32'h20000000+32'(sources)*32'h073abcd1);
       wr('h70,65536+32'(c*1000-3500));
       wr('h74,32'h26666666+32'(c*12345));
       wr('h78,32'h40000000-32'(c*65536));
       rd('h6c,32'(c)*32'h20000000+32'(sources)*32'h073abcd1);
       rd('h70,65536+32'(c*1000-3500));
       rd('h74,32'h26666666+32'(c*12345));
       rd('h78,32'h40000000-32'(c*65536));
     end
     wr(0,8);
     for(int c=0;c<CELLS;c++) begin
       wr('h18,32'(c));
       rd('h7c,32'(c)*32'h20000000+32'(sources)*32'h073abcd1);
       rd('h80,65536+32'(c*1000-3500));
     end
     wr(0,257);wr('h68,32'(sources));
     for(int c=0;c<CELLS;c++) begin wr('h18,32'(c));wr('h6c,32'(c*1333-5000));end
     wr(0,258);
     rd('h88,0);
     for(int t=0;t<96;t++) begin
       for(int lane=0;lane<LANES;lane++) begin
         wr(8,32'(lane));wr(12,32'((t+lane*3)%CELLS));
         wr(16,(t%3==0)?0:((t%3==1)?1:3));wr(20,1);
       end
       wr(0,(t%7==0)?512:1);ticks++;
       if(t%8==0) begin
         // A held-valid burst causes one accepted tick per rising edge.
         @(negedge clk);csr_valid=1;csr_write=1;csr_addr=0;csr_wdata=1;
         repeat(3) begin @(posedge clk);#2;ticks++;end
         csr_valid=0;
       end
       repeat(2) @(negedge clk);
       if(t%8==0) scan();
       if(t%13==0) begin
         margin_saved=dut.local_previous_margin_q16;
         count_saved=dut.local_stability_sample_count_q;
         wr(0,2);rd('h88,count_saved);rd('h80,margin_saved);
         wr(0,4);rd('h88,count_saved);
       end
     end
     scan();inspect_cells();
     count_saved=dut.local_stability_sample_count_q;
     margin_saved=dut.local_previous_margin_q16;
     retained={dut.gamma_targets_q,dut.phase_load_q};
     for(int a=104;a<256;a+=4) transfer(1,a,32'(a),1);
     if(retained!=={dut.gamma_targets_q,dut.phase_load_q}) $fatal(1,"RO write mutated staging");
     rd('h88,count_saved);rd('h80,margin_saved);
     wr(0,257);rd('h68,32'(sources));rd('hfc,'h46523202);
     wr(0,256);rd('h68,32'(auto_mode));rd('hfc,'h46523201);
     wr(0,258);rd('h88,count_saved);
     wr(0,8);repeat(2) @(negedge clk);rd('h88,count_saved);
   end
   randomized_registers();
   reset();
   wr(0,260);rd('h80,0);rd('h84,0);rd('h8c,0);
   scan();rd('h88,0);
   if(ticks!=commits) $fatal(1,"tick/commit mismatch %0d/%0d",ticks,commits);
   if(route_samples!=CELLS*5 || cell_reads!=CELLS*24*27) $fatal(1,"coverage count");
   if(random_writes!=2048 || model_audits!=68 || model_rejected==0 || random_ticks==0) $fatal(1,"register model coverage");
   $display("PASS CSR cells=%0d profiles=%0d ticks=%0d commits=%0d reads=%0d scale_reads=%0d rejected=%0d cycles=%0d cell_reads=%0d route_samples=%0d random_writes=%0d random_ticks=%0d model_writes=%0d model_reads=%0d model_rejected=%0d model_audits=%0d",CELLS,profiles,ticks,commits,reads,scale_reads,errors,checks,cell_reads,route_samples,random_writes,random_ticks,model_writes,model_reads,model_rejected,model_audits);
   $finish;
 end
 initial begin #10000000;$fatal(1,"timeout");end
endmodule

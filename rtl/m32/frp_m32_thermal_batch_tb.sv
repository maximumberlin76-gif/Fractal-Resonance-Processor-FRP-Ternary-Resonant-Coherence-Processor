// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// M32 thermal/gamma integration regression: 96 profiles in one simulation.
// Reference equations: frp_prototype_v1_7_0.py, default eight-cell parameters.
// Phase equations: rtl/m31/frp_m31_fixed_point_pkg.sv and M31 phase contract.
// Integer reference arithmetic below does not call DUT arithmetic functions.
// Attenuation checks cover selection, bounds and state updates, not ROM values.
// Build once from the repository root (Verilator):
// Command: verilator-cli --binary --timing --assert -Wno-fatal -j 2 \
//   -MAKEFLAGS VK_PCH_I_FAST= -MAKEFLAGS VK_PCH_I_SLOW= \
//   --top-module frp_m32_thermal_batch_tb -Irtl/m31 -Irtl/m32 \
//   rtl/m32/frp_m32_thermal_batch_tb.sv
// Run: ./obj_dir/Vfrp_m32_thermal_batch_tb +CYCLES=4096
// Optional +CYCLES=N (512..65536) applies to each of the 96 profiles.

`timescale 1ns / 1ps
`include "frp_m32_core.sv"

module frp_m32_thermal_batch_tb;
  import frp_m31_pkg::*;
  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  frp_m31_scheduler_mode_e scheduler_mode = FRP_MODE_FREE;
  logic phase_load_valid = 0, auto_target_enable = 0;
  logic local_gamma_enable = 0, local_thermal_enable = 0;
  logic gamma_update_valid = 0;
  logic [255:0] phase_load = 0, frequency_load_q16 = 0;
  logic [255:0] gamma_effective_word = 0, thermal_node_factor_q30 = 0;
  logic [255:0] gamma_targets_q16 = 0;
  logic [1:0] external_request_valid = 0;
  logic [5:0] external_request_cell_index = 0;
  logic [3:0] external_request_target = 0;
  logic [15:0] external_target_bank = 0;
  logic [15:0] state_out;
  logic [255:0] phase_word_q, frequency_current_q16;
  logic [7:0] accepted_change_mask;
  frp_m32_core dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters), .scheduler_mode(scheduler_mode),
    .phase_load_valid(phase_load_valid), .phase_load(phase_load),
    .frequency_load_q16(frequency_load_q16),
    .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30),
    .auto_target_enable(auto_target_enable),
    .external_request_valid(external_request_valid),
    .external_request_cell_index(external_request_cell_index),
    .external_request_target(external_request_target),
    .external_target_bank(external_target_bank),
    .local_gamma_enable(local_gamma_enable),
    .local_thermal_enable(local_thermal_enable),
    .gamma_update_valid(gamma_update_valid), .gamma_targets_q16(gamma_targets_q16),
    .state_out(state_out), .accepted_change_mask(accepted_change_mask),
    .phase_word_q(phase_word_q), .frequency_current_q16(frequency_current_q16)
  );

  longint signed heat[8], peak[8], power_q[8], loss_q[8], diffusion_q[8];
  longint signed overload_q[8], target_q[8], noise_q[8], drift_q[8];
  longint signed effective_q[8], factor_q[8], mean_peak;
  int cycles = 512, profile = 0, cycle_index = 0;
  logic [31:0] rng;
  logic signed [31:0] reference_sine[4096];
  int period = 0, expected_schedule = 0;
  longint unsigned checks = 0, total_cycles = 0;
  longint unsigned state_visits[3] = '{default:0};
  longint unsigned zero_entries = 0, zero_exits = 0;
  longint unsigned coverage[96][8] = '{default:'{default:0}};

  function automatic logic [31:0] random_word();
    rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5;
    return rng;
  endfunction
  function automatic longint signed clip(input longint signed x);
    if (x > 64'sd2147483647) return 64'sd2147483647;
    if (x < -64'sd2147483648) return -64'sd2147483648;
    return x;
  endfunction
  function automatic longint signed rounded(input longint signed x, input int n);
    longint signed divisor;
    divisor = 64'sd1 << n;
    return x < 0 ? -((-x + divisor/2)/divisor) : (x + divisor/2)/divisor;
  endfunction
  function automatic longint signed qmul(input longint signed a, b);
    return clip(rounded(a*b,16));
  endfunction
  function automatic logic [31:0] phase_convert(input longint signed x);
    logic signed [95:0] product, magnitude;
    product = 96'(x) * 96'sd44798133900177;
    magnitude = (product < 0) ? -product : product;
    magnitude = (magnitude + 96'sd2147483648) / 96'sd4294967296;
    return product < 0 ? -magnitude[31:0] : magnitude[31:0];
  endfunction
  function automatic longint signed sine(input logic [31:0] phase);
    return 64'($signed(reference_sine[phase[31:20]]));
  endfunction
  function automatic longint signed coherence(input logic [255:0] phases,
                                               input int first, count, shift);
    longint signed sc, ss;
    longint unsigned square, low, high, middle;
    sc=0; ss=0;
    for (int i=first; i<first+count; i++) begin
      sc+=sine(phases[i*32 +: 32]+32'h40000000);
      ss+=sine(phases[i*32 +: 32]);
    end
    sc=rounded(sc,shift); ss=rounded(ss,shift); square=64'(sc*sc+ss*ss);
    low=0; high=64'd2147483648;
    while (low+1<high) begin
      middle=(low+high)/2;
      if (middle*middle<=square) low=middle; else high=middle;
    end
    return 64'(low);
  endfunction
  task automatic eq(input logic [31:0] actual, expected, input string label, input int lane);
    if (actual !== expected)
      $fatal(1,"%s profile=%0d cycle=%0d lane=%0d got=%h expected=%h",
             label,profile,cycle_index,lane,actual,expected);
    checks++;
  endtask
  task automatic require_true(input bit condition, input string label);
    if (!condition) $fatal(1,"%s profile=%0d cycle=%0d",label,profile,cycle_index);
    checks++;
  endtask
  task automatic reset_model();
    mean_peak = 3277; period=0; expected_schedule=0;
    for (int i=0; i<8; i++) begin
      heat[i]=3277; peak[i]=3277; power_q[i]=0; loss_q[i]=0;
      diffusion_q[i]=0; overload_q[i]=0; target_q[i]=0; noise_q[i]=0;
      drift_q[i]=0; effective_q[i]=644245094; factor_q[i]=1073741824;
    end
  endtask

  task automatic sample_cycle();
    longint signed nh[8], np[8], nl[8], nd[8], no[8], nt[8], nn[8];
    longint signed ng[8], ne[8], nf[8], selected_frequency[8];
    longint signed sum, weight, difference, target_frequency, lag, maximum;
    longint signed gamma_selected[8], factors_selected[8], field, term, push;
    longint signed pair_sum, cluster_a, cluster_b, velocity;
    logic [31:0] next_phase[8], relative_phase;
    logic [15:0] previous_state;
    logic [255:0] previous_phase, previous_frequency;
    #1;
    if (!rst_n) reset_model();
    previous_state=state_out; previous_phase=phase_word_q;
    previous_frequency=frequency_current_q16;
    for (int i=0; i<8; i++) begin
      target_frequency=65536;
      if (state_out[i*2 +: 2] == FRP_STATE_NEG || state_out[i*2 +: 2] == FRP_STATE_POS)
        target_frequency+=3932;
      if (accepted_change_mask[i]) target_frequency+=7864;
      selected_frequency[i]=$signed(frequency_current_q16[i*32 +: 32]);
      selected_frequency[i]=clip(selected_frequency[i] +
        clip(rounded((target_frequency-selected_frequency[i])*19661,16)));
      if (phase_load_valid) selected_frequency[i]=$signed(frequency_load_q16[i*32 +: 32]);
      lag=target_frequency-selected_frequency[i]; if (lag<0) lag=-lag;
      eq(dut.local_frequency_lag_q16[i*32 +: 32],32'(lag),"frequency lag",i);
      sum=0;
      for (int j=0; j<8; j++) if (i!=j) begin
        weight=((i^j)<2)?630553580:(((i^j)<4)?137232194:42180964);
        sum+=clip(rounded((heat[j]-heat[i])*weight,30));
      end
      nd[i]=qmul(2294,clip(sum));
      np[i]=clip(118+clip(rounded(lag*1180,16))+(accepted_change_mask[i]?3408:0));
      difference=heat[i]-3277;
      nl[i]=difference<0 ? -((-difference+7)/14) : (difference+7)/14;
      nh[i]=clip(heat[i]+np[i]-nl[i]+nd[i]); if (nh[i]<3277) nh[i]=3277;
      no[i]=nh[i]>14418 ? nh[i]-14418 : 0;
      nt[i]=gamma_update_valid ? $signed(gamma_targets_q16[i*32 +: 32]) : target_q[i];
      nn[i]=clip(noise_q[i]+clip(rounded((nt[i]-noise_q[i])*9830,16)));
      ng[i]=$signed(phase_convert(qmul(qmul(5243,no[i]),nn[i])));
      ne[i]=$signed(32'(644245094+ng[i]));
      nf[i]=$unsigned(dut.local_next_thermal_node_factor_q30[i*32 +: 32]);
      eq(dut.local_next_heat_q16[i*32 +: 32],32'(nh[i]),"next heat",i);
      eq(dut.local_next_overload_q16[i*32 +: 32],32'(no[i]),"next overload",i);
      eq(dut.local_next_gamma_drift_word[i*32 +: 32],32'(ng[i]),"next drift",i);
      eq(dut.local_next_gamma_effective_word[i*32 +: 32],32'(ne[i]),"next gamma",i);
      eq(dut.phase_gamma_effective_word[i*32 +: 32],
         local_gamma_enable?32'(ne[i]):gamma_effective_word[i*32 +: 32],"gamma source",i);
      eq(dut.phase_thermal_node_factor_q30[i*32 +: 32],
         local_thermal_enable?32'(nf[i]):thermal_node_factor_q30[i*32 +: 32],"factor source",i);
      require_true(nf[i]>=0 && nf[i]<=1073741824,"attenuation bounds");
      if (no[i]==0) eq(32'(nf[i]),1073741824,"zero overload attenuation",i);
    end
    eq(32'(dut.scheduler_state_q),32'(expected_schedule),"scheduler cadence",-1);
    pair_sum=0;
    for (int i=0; i<4; i++) pair_sum+=coherence(previous_phase,2*i,2,1);
    cluster_a=coherence(previous_phase,0,4,2); cluster_b=coherence(previous_phase,4,4,2);
    eq(dut.pair_coherence_q30,32'(rounded(pair_sum,2)),"pair coherence",-1);
    eq(dut.cluster_coherence_q30,32'(rounded(cluster_a+cluster_b,1)),"cluster coherence",-1);
    eq(dut.global_coherence_q30,32'(coherence(previous_phase,0,8,3)),"global coherence",-1);
    difference=cluster_a-cluster_b; if (difference<0) difference=-difference;
    eq(dut.organization_dispersion_q30,32'(rounded(difference,1)),"dispersion",-1);
    for (int i=0; i<8; i++) begin
      gamma_selected[i]=local_gamma_enable?ne[i]:64'($signed(gamma_effective_word[i*32 +: 32]));
      factors_selected[i]=local_thermal_enable?nf[i]:64'($signed(thermal_node_factor_q30[i*32 +: 32]));
    end
    for (int i=0; i<8; i++) begin
      sum=0;
      for (int j=0; j<8; j++) if (i!=j) begin
        weight=((i^j)<2)?516461574:(((i^j)<4)?158959695:59840215);
        term=clip(rounded(factors_selected[i]*factors_selected[j],30));
        term=clip(rounded(term*weight,30));
        relative_phase=previous_phase[j*32 +: 32]-previous_phase[i*32 +: 32]-32'(gamma_selected[i]);
        sum+=clip(rounded(term*sine(relative_phase),30));
      end
      field=qmul(18350,clip(rounded(clip(sum),14)));
      eq(dut.coupling_field_q16[i*32 +: 32],32'(field),"relative phase coupling",i);
      term=sine(previous_phase[i*32 +: 32]);
      eq(dut.phase_projection_q30[i*32 +: 32],32'(term),"phase projection",i);
      eq(32'(dut.phase_target_source[i*2 +: 2]),
         term>354334802?32'(FRP_STATE_POS):(term < -354334802?32'(FRP_STATE_NEG):32'(FRP_STATE_ZERO)),"resonant target",i);
      push=expected_schedule==2?655:(expected_schedule==3?393:197);
      velocity=64'($signed(32'(qmul(3932,selected_frequency[i])+push+field)));
      next_phase[i]=previous_phase[i*32 +: 32]+phase_convert(velocity);
    end
    if (rst_n) begin
      if (tick_enable) period=(period+1)%8;
      case (scheduler_mode)
        FRP_MODE_FREE: expected_schedule=0;
        FRP_MODE_7_1: expected_schedule=(period==7)?2:1;
        FRP_MODE_1_7: expected_schedule=(period==0)?3:4;
        default: $fatal(1,"Unexpected batch mode");
      endcase
    end
    if (rst_n && tick_enable) begin
      sum=0;
      for (int i=0; i<8; i++) begin
        heat[i]=nh[i]; if (nh[i]>peak[i]) peak[i]=nh[i];
        power_q[i]=np[i]; loss_q[i]=nl[i]; diffusion_q[i]=nd[i]; overload_q[i]=no[i];
        target_q[i]=nt[i]; noise_q[i]=nn[i]; drift_q[i]=ng[i];
        effective_q[i]=ne[i]; factor_q[i]=nf[i]; sum+=nh[i];
      end
      if (rounded(sum,3)>mean_peak) mean_peak=rounded(sum,3);
    end
    clk=1; #1;
    sum=0; maximum=3277;
    for (int i=0; i<8; i++) begin
      eq(dut.local_heat_q16[i*32 +: 32],32'(heat[i]),"heat",i);
      eq(dut.local_heat_peak_q16[i*32 +: 32],32'(peak[i]),"heat peak",i);
      eq(dut.local_generated_power_q16[i*32 +: 32],32'(power_q[i]),"power",i);
      eq(dut.local_thermal_dissipation_q16[i*32 +: 32],32'(loss_q[i]),"dissipation",i);
      eq(dut.local_thermal_diffusion_q16[i*32 +: 32],32'(diffusion_q[i]),"diffusion",i);
      eq(dut.local_thermal_overload_q16[i*32 +: 32],32'(overload_q[i]),"overload",i);
      eq(dut.local_gamma_noise_target_q16[i*32 +: 32],32'(target_q[i]),"retained target",i);
      eq(dut.local_gamma_noise_state_q16[i*32 +: 32],32'(noise_q[i]),"noise",i);
      eq(dut.local_gamma_drift_word[i*32 +: 32],32'(drift_q[i]),"drift",i);
      eq(dut.local_gamma_effective_word[i*32 +: 32],32'(effective_q[i]),"gamma",i);
      eq(dut.local_thermal_node_factor_q30[i*32 +: 32],32'(factor_q[i]),"factor commit/hold",i);
      sum+=heat[i]; if (peak[i]>maximum) maximum=peak[i];
      require_true(state_out[i*2 +: 2]!=FRP_STATE_RESERVED,"ternary domain");
      if (rst_n) begin
        require_true(!((previous_state[i*2 +: 2]==FRP_STATE_NEG && state_out[i*2 +: 2]==FRP_STATE_POS) ||
                       (previous_state[i*2 +: 2]==FRP_STATE_POS && state_out[i*2 +: 2]==FRP_STATE_NEG)),"direct polarity change");
        if (state_out[i*2 +: 2]==FRP_STATE_ZERO) state_visits[1]++;
        else if (state_out[i*2 +: 2]==FRP_STATE_NEG) state_visits[0]++;
        else state_visits[2]++;
        if (previous_state[i*2 +: 2]!=FRP_STATE_ZERO && state_out[i*2 +: 2]==FRP_STATE_ZERO) zero_entries++;
        if (previous_state[i*2 +: 2]==FRP_STATE_ZERO && state_out[i*2 +: 2]!=FRP_STATE_ZERO) zero_exits++;
        if (phase_load_valid) begin
          eq(phase_word_q[i*32 +: 32],phase_load[i*32 +: 32],"phase load",i);
          eq(frequency_current_q16[i*32 +: 32],frequency_load_q16[i*32 +: 32],"frequency load",i);
        end else if (!tick_enable) begin
          eq(phase_word_q[i*32 +: 32],previous_phase[i*32 +: 32],"phase hold",i);
          eq(frequency_current_q16[i*32 +: 32],previous_frequency[i*32 +: 32],"frequency hold",i);
        end else begin
          eq(frequency_current_q16[i*32 +: 32],32'(selected_frequency[i]),"frequency step",i);
          eq(phase_word_q[i*32 +: 32],next_phase[i],"phase step",i);
        end
      end
    end
    eq(dut.local_mean_heat_q16,32'(rounded(sum,3)),"mean heat",-1);
    eq(dut.local_mean_heat_peak_q16,32'(mean_peak),"mean heat peak",-1);
    eq(dut.local_maximum_heat_peak_q16,32'(maximum),"maximum heat peak",-1);
    if (!rst_n) coverage[profile][0]++;
    else begin
      coverage[profile][tick_enable?1:2]++;
      if (tick_enable && gamma_update_valid) coverage[profile][3]++;
      if (tick_enable && clear_counters) coverage[profile][4]++;
      if (phase_load_valid) coverage[profile][5]++;
      if (tick_enable && !gamma_update_valid) coverage[profile][6]++;
      for (int i=0; i<8; i++) if (tick_enable && no[i]>0) coverage[profile][7]++;
    end
    total_cycles++; clk=0; #1;
  endtask

  initial begin
    $readmemh("rtl/m31/frp_m31_sin_q30.mem",reference_sine);
    #1;
    void'($value$plusargs("CYCLES=%d",cycles));
    if (cycles<512 || cycles>65536) $fatal(1,"CYCLES must be 512..65536");
    for (int mode=0; mode<3; mode++)
      for (int sources=0; sources<4; sources++)
        for (int automatic_targets=0; automatic_targets<2; automatic_targets++)
          for (int seed=0; seed<4; seed++) begin
            rng=32'h13579bdf ^ (32'h9e3779b9*32'(seed+1));
            for (cycle_index=0; cycle_index<cycles; cycle_index++) begin
              rst_n=(cycle_index!=0 && cycle_index!=257);
              tick_enable=(cycle_index%9!=3);
              clear_counters=(cycle_index%31==7);
              phase_load_valid=(cycle_index%19==1);
              scheduler_mode=frp_m31_scheduler_mode_e'(mode);
              local_gamma_enable=sources[0]; local_thermal_enable=sources[1];
              auto_target_enable=1'(automatic_targets);
              gamma_update_valid=(cycle_index%5==0);
              external_request_valid=2'(random_word());
              external_request_cell_index=6'(random_word());
              external_request_target=4'(random_word());
              external_target_bank=16'(random_word());
              for (int i=0; i<8; i++) begin
                phase_load[i*32 +: 32]=random_word();
                frequency_load_q16[i*32 +: 32]=random_word();
                gamma_targets_q16[i*32 +: 32]=random_word();
                if (cycle_index<128) begin
                  frequency_load_q16[i*32 +: 32]=60000+(random_word()%30001);
                  gamma_targets_q16[i*32 +: 32]=(random_word()%131073)-65536;
                end
                gamma_effective_word[i*32 +: 32]=random_word();
                thermal_node_factor_q30[i*32 +: 32]=random_word() & 32'h3fffffff;
              end
              sample_cycle();
            end
            for (int k=0; k<8; k++) require_true(coverage[profile][k]>0,"profile coverage");
            $display("PROFILE %0d mode=%0d sources=%0d auto=%0d seed=%0d cycles=%0d",
                     profile,mode,sources,automatic_targets,seed,cycles);
            profile++;
          end
    require_true(profile==96,"profile count");
    for (int k=0; k<3; k++) require_true(state_visits[k]>0,"ternary visits");
    require_true(zero_entries>0 && zero_exits>0,"active zero transitions");
    $display("PASS profiles=%0d cycles=%0d checks=%0d visits_neg=%0d visits_zero=%0d visits_pos=%0d zero_entries=%0d zero_exits=%0d",
             profile,total_cycles,checks,state_visits[0],state_visits[1],state_visits[2],zero_entries,zero_exits);
    $finish;
  end
  initial begin #30000000; $fatal(1,"Batch watchdog"); end
endmodule

// Copyright (c) 2026 Maksym Marnov (Alchimist). All rights reserved.
// Retained-route service under continuing external and automatic requests.
// Public-port oracle models lane arbitration, active-zero storage and cadence.
// Each route has an ID, destination, initial predecessors and later arrivals.
// While a route waits, every service opportunity consumes LANES predecessors.
// A bounded-refill profile admits at most LANES-1 lower-index replacements
// between service opportunities. A full-refill profile records deferral and
// then changes the request destinations while keeping the request lanes valid.
// CELLS=8/16/32/64; run from the repository root for the phase sine ROM.
`timescale 1ns/1ps
`include "frp_m32_core.sv"

module frp_m32_route_under_load_tb #(parameter int CELLS=8);
  import frp_m31_pkg::*;
  localparam int LANES=CELLS/4, IB=$clog2(CELLS);
  localparam int REFILL_BOUND=CELLS-LANES+1;
  logic clk=0, rst_n=1, tick_enable=0, clear_counters=0;
  logic phase_load_valid=0, auto_target_enable=0;
  logic local_gamma_enable=1, local_thermal_enable=1, gamma_update_valid=0;
  logic [CELLS*32-1:0] phase_load=0, frequency_load_q16=0;
  logic [CELLS*32-1:0] gamma_effective_word=0, gamma_targets_q16=0;
  logic [CELLS*32-1:0] thermal_node_factor_q30={CELLS{32'h40000000}};
  logic [LANES-1:0] external_request_valid=0;
  logic [LANES*IB-1:0] external_request_cell_index=0;
  logic [LANES*2-1:0] external_request_target=0;
  logic [CELLS*2-1:0] external_target_bank=0;
  frp_m31_scheduler_mode_e scheduler_mode=FRP_MODE_FREE, mode_q;
  frp_m31_scheduler_state_e cadence_q;
  wire [CELLS*32-1:0] phase, frequency;
  wire [CELLS*2-1:0] state, pending, captured_target;
  wire captured_valid;
  wire [LANES-1:0] accepted, rejected;
  wire [CELLS-1:0] change_mask;
  wire [31:0] capacity_left, direct_events, overflow_events, reserved_events;
  wire [31:0] recorded_ticks, recorded_counts[5];
  wire capacity_full;
  wire [9:0] invariants;

  frp_m32_core #(.CELLS(CELLS)) dut (
    .clk(clk), .rst_n(rst_n), .tick_enable(tick_enable),
    .clear_counters(clear_counters), .scheduler_mode(scheduler_mode), .phase_load_valid(phase_load_valid),
    .phase_load(phase_load), .frequency_load_q16(frequency_load_q16), .gamma_effective_word(gamma_effective_word),
    .thermal_node_factor_q30(thermal_node_factor_q30), .auto_target_enable(auto_target_enable), .external_request_valid(external_request_valid),
    .external_request_cell_index(external_request_cell_index), .external_request_target(external_request_target), .external_target_bank(external_target_bank),
    .local_gamma_enable(local_gamma_enable), .gamma_update_valid(gamma_update_valid), .gamma_targets_q16(gamma_targets_q16),
    .local_thermal_enable(local_thermal_enable), .phase_word_q(phase), .frequency_current_q16(frequency),
    .coupling_field_q16(), .phase_projection_q30(), .phase_target_source(),
    .registered_target_q(captured_target), .registered_target_valid_q(captured_valid), .state_out(state),
    .pending_route_out(pending), .scheduler_mode_q(mode_q), .scheduler_state_q(cadence_q),
    .accepted_changes(), .switch_load_numerator(), .actual_direct_events(direct_events),
    .invariant_flags(invariants), .local_mean_heat_q16(), .stability_margin_q16(),
    .local_stability_margin_q16(), .phase_target_domain_valid(), .registered_target_domain_valid(),
    .target_capture_accepted(), .target_capture_rejected(), .accepted_target_capture_events_q(),
    .rejected_target_capture_events_q(), .registered_request_enable(), .phase_request_valid(),
    .phase_request_cell_index(), .phase_request_target(), .execution_request_valid(),
    .execution_request_cell_index(), .execution_request_target(), .execution_target_bank(),
    .ticks_recorded_q(recorded_ticks), .scheduler_count_free_q(recorded_counts[0]), .scheduler_count_balance_q(recorded_counts[1]),
    .scheduler_count_commit_q(recorded_counts[2]), .scheduler_count_excite_q(recorded_counts[3]), .scheduler_count_neutralize_q(recorded_counts[4]),
    .request_accept(accepted), .request_reject(rejected), .accepted_cell_mask(),
    .neutral_routed_cell_mask(), .accepted_change_mask(change_mask), .capacity_remaining(capacity_left),
    .capacity_exhausted(capacity_full), .requested_direct_events(), .prevented_direct_events(),
    .neutral_routed_events(), .reserved_state_events(reserved_events), .queue_overflow_events(overflow_events),
    .pair_coherence_q30(), .cluster_coherence_q30(), .global_coherence_q30(),
    .organization_dispersion_q30(), .normalized_cycle_cost_q16(), .temperature_proxy_q16(),
    .peak_temperature_proxy_q16(), .thermal_sample_count_q(), .coherence_capacity_q16(),
    .pressure_q16(), .stable(), .local_heat_q16(),
    .local_heat_peak_q16(), .local_generated_power_q16(), .local_thermal_dissipation_q16(),
    .local_thermal_diffusion_q16(), .local_thermal_overload_q16(), .local_next_heat_q16(),
    .local_next_overload_q16(), .local_frequency_lag_q16(), .local_mean_heat_peak_q16(),
    .local_maximum_heat_peak_q16(), .local_gamma_noise_target_q16(), .local_gamma_noise_state_q16(),
    .local_gamma_drift_word(), .local_gamma_effective_word(), .local_next_gamma_drift_word(),
    .local_next_gamma_effective_word(), .phase_gamma_effective_word(), .local_thermal_node_factor_q30(),
    .local_next_thermal_node_factor_q30(), .phase_thermal_node_factor_q30(), .group_coherence_q30(),
    .level_mean_coherence_q30(), .level_min_coherence_q30(), .level_max_coherence_q30(),
    .level_dispersion_q30(), .local_coherence_compression_q30(), .local_effective_coherence_q30(),
    .local_coherence_capacity_q16(), .local_pressure_q16(), .local_stable(),
    .local_previous_margin_q16(), .local_stability_valid_q(), .local_stability_sample_count_q(),
    .local_stability_raw_coherence_q30(), .local_stability_cluster_coherence_q30(), .local_stability_mean_heat_q16(),
    .local_stability_mean_overload_q16(), .local_stability_mean_lag_q16(), .local_stability_neutral_fraction_q30(),
    .local_stability_compression_arg_q16(), .local_stability_switch_load_q16()
  );

  int model_state[CELLS], destination[CELLS], target[CELLS];
  int service_age[CELLS], initial_ahead[CELLS], arrivals[CELLS];
  int wall_age[CELLS], enabled_age[CELLS];
  longint unsigned route_id[CELLS], cohort[CELLS];
  longint unsigned made_cell[CELLS], done_cell[CELLS];
  int sine_table[4096];
  int model_mode=0, position=0, model_ticks=0, model_counts[5];
  bit target_valid=0;
  int test_mode=0, profile=0, cycles=0, checked_edges=0;
  longint unsigned checks=0, made=0, done=0, service_edges=0;
  longint unsigned loaded_edges=0, conflict_lanes=0, duplicate_lanes=0;
  longint unsigned capacity_waits=0, paused_routes=0, cadence_waits=0;
  longint unsigned lower_arrivals=0, automatic_edges=0, clear_edges=0;
  longint unsigned signature=64'hcbf29ce484222325;
  int max_service_age=0, max_wall_age=0, max_pending=0;
  int completed_loaded[3], direction_hits[3][2], source_hits[3][4][2];
  int cadence_hits[5], fair_cases=0, refill_cases=0, stream_cases=0;
  bit checking_load=0;

  task automatic eq(input string label_text, input longint got,want);
    checks++;
    if(got!=want)
      $fatal(1,"ROUTE_LOAD cells=%0d mode=%0d profile=%0d cycle=%0d %s got=%0d expected=%0d",
        CELLS,test_mode,profile,cycles,label_text,got,want);
    signature=(signature^64'(got))*64'h100000001b3;
  endtask
  task automatic require(input bit condition, input string label_text);
    eq(label_text,condition,1);
  endtask
  function automatic logic [1:0] code(input int value);
    return value<0?2'b11:value>0?2'b01:2'b00;
  endfunction
  function automatic int value(input logic [1:0] bits);
    case(bits)
      2'b00:return 0;
      2'b01:return 1;
      2'b11:return -1;
      default:begin $fatal(1,"Reserved request symbol"); return 0; end
    endcase
  endfunction
  function automatic int cadence;
    case(model_mode)
      0:return 0;
      1:return position==7?2:1;
      2:return position==0?3:4;
      default:begin $fatal(1,"Invalid reference mode"); return 0; end
    endcase
  endfunction
  function automatic bit allowed(input int old_value, goal);
    logic [8:0] table_bits;
    case(cadence())
      0:table_bits=9'b111111111;
      1,4:table_bits=9'b111010111;
      2,3:table_bits=9'b100111001;
      default:table_bits=0;
    endcase
    return table_bits[3*(old_value+1)+goal+1];
  endfunction
  function automatic int outstanding;
    int count=0;
    for(int i=0;i<CELLS;i++) if(destination[i]!=0) count++;
    return count;
  endfunction
  function automatic bit cohort_live;
    bit found=0;
    for(int i=0;i<CELLS;i++) if(cohort[i]!=0 && route_id[i]==cohort[i]) found=1;
    return found;
  endfunction

  int ns[CELLS], np[CELLS], indexes[LANES], goals[LANES];
  bit valid[LANES], claimed[CELLS], creating[CELLS], completing[CELLS];
  logic [LANES-1:0] accept_ref, reject_ref;
  logic [CELLS-1:0] writes;
  logic [CELLS*32-1:0] old_phase, old_frequency;
  int used,k,ci,goal,old_cadence,rank,served,alive,lower;
  bit service;

  task automatic prepare_edge(input bit enabled);
    eq("registered mode before edge",mode_q,model_mode);
    eq("cadence before edge",cadence_q,cadence());
    old_cadence=cadence(); service=enabled && (old_cadence==0 || old_cadence==2 || old_cadence==3);
    old_phase=phase; old_frequency=frequency;
    for(int i=0;i<CELLS;i++) begin
      ns[i]=model_state[i]; np[i]=destination[i];
      claimed[i]=0; creating[i]=0; completing[i]=0;
    end
    for(int lane=0;lane<LANES;lane++) begin
      valid[lane]=external_request_valid[lane];
      indexes[lane]=int'(external_request_cell_index[IB*lane+:IB]);
      goals[lane]=value(external_request_target[2*lane+:2]);
    end
    if(auto_target_enable) begin
      for(int lane=0;lane<LANES;lane++) valid[lane]=0;
      k=0;
      for(int i=0;i<CELLS;i++)
        if(target_valid && k<LANES && destination[i]==0 &&
           model_state[i]!=target[i] && allowed(model_state[i],target[i])) begin
          valid[k]=1; indexes[k]=i; goals[k]=target[i]; k++;
        end
    end
    used=0; served=0; rank=0; writes=0; accept_ref=0; reject_ref=0;
    for(int i=0;i<CELLS;i++) if(destination[i]!=0) begin
      rank++;
      if(service && rank<=LANES) begin
        ns[i]=destination[i]; np[i]=0; writes[i]=1;
        completing[i]=1; used++; served++;
      end
    end
    if(enabled) for(int lane=0;lane<LANES;lane++) if(valid[lane]) begin
      ci=indexes[lane]; goal=goals[lane]; reject_ref[lane]=1;
      require(ci>=0 && ci<CELLS,"request index domain");
      if(destination[ci]!=0 && goal!=destination[ci]) conflict_lanes++;
      if(claimed[ci]) duplicate_lanes++;
      if(!claimed[ci] && destination[ci]==0 && allowed(model_state[ci],goal)) begin
        claimed[ci]=1;
        if(model_state[ci]==goal || used<LANES) begin
          accept_ref[lane]=1; reject_ref[lane]=0;
        end
        if(model_state[ci]!=goal && used<LANES) begin
          used++; writes[ci]=1;
          if(model_state[ci]*goal==-1) begin ns[ci]=0; np[ci]=goal; creating[ci]=1; end
          else ns[ci]=goal;
        end
      end
    end
    eq("lane acceptance",accepted,accept_ref); eq("lane rejection",rejected,reject_ref);
    eq("transition write mask",change_mask,writes);
    eq("capacity remaining",capacity_left,LANES-used);
    eq("capacity exhausted",capacity_full,used==LANES);
    if(checking_load) begin
      require(external_request_valid=='1,"continuous offered request lanes");
      loaded_edges++;
      if(enabled) source_hits[test_mode][2*int'(local_thermal_enable)+int'(local_gamma_enable)][int'(auto_target_enable)]++;
    end
    if(service) service_edges++;
    if(enabled) begin
      cadence_hits[old_cadence]++;
      if(auto_target_enable) automatic_edges++;
    end
    if(clear_counters) begin
      model_ticks=0; foreach(model_counts[i]) model_counts[i]=0;
      if(outstanding()>0) clear_edges++;
    end
    if(enabled) begin
      model_ticks++; model_counts[old_cadence]++; position=(position+1)%8;
      for(int i=0;i<CELLS;i++) begin
        goal=sine_table[phase[32*i+:32]>>20];
        target[i]=goal>354334802?1:goal< -354334802?-1:0;
      end
      target_valid=1;
    end
    model_mode=int'(scheduler_mode);
  endtask

  task automatic check_edge(input bit enabled);
    cycles++;
    eq("registered mode after edge",mode_q,model_mode);
    eq("cadence after edge",cadence_q,cadence());
    eq("tick count",recorded_ticks,model_ticks);
    foreach(model_counts[i]) eq("cadence count",recorded_counts[i],model_counts[i]);
    eq("captured target valid",captured_valid,target_valid);
    for(int i=0;i<CELLS;i++) begin
      eq("ternary state",state[2*i+:2],code(ns[i]));
      eq("retained destination",pending[2*i+:2],code(np[i]));
      eq("captured phase target",captured_target[2*i+:2],code(target[i]));
      require(model_state[i]*ns[i]!=-1,"opposite polarities pass through zero");
      if(destination[i]!=0) begin
        require(model_state[i]==0,"live route starts from active zero");
        wall_age[i]++; if(enabled) enabled_age[i]++;
        if(service) service_age[i]++;
        else if(enabled) cadence_waits++;
        else paused_routes++;
        if(wall_age[i]>max_wall_age) max_wall_age=wall_age[i];
        if(service_age[i]>max_service_age) max_service_age=service_age[i];
        if(completing[i]) begin
          require(service,"route completion has a service opportunity");
          require(service_age[i]<=(initial_ahead[i]+arrivals[i])/LANES+1,
                  "completion bound includes lower-index arrivals");
          eq("original route destination",ns[i],destination[i]);
          signature=(signature^route_id[i])*64'h100000001b3;
          done++; done_cell[i]++; route_id[i]=0;
          if(checking_load) completed_loaded[test_mode]++;
        end else begin
          eq("held route polarity",np[i],destination[i]);
          require(service_age[i]*LANES<=initial_ahead[i]+arrivals[i],
                  "every deferred service consumes lower-index predecessors");
          if(service) capacity_waits++;
        end
      end
      if(!enabled && !phase_load_valid) begin
        eq("paused phase",phase[32*i+:32],old_phase[32*i+:32]);
        eq("paused frequency",frequency[32*i+:32],old_frequency[32*i+:32]);
      end
    end
    // New routes on this edge can precede an older route on later edges.
    for(int i=0;i<CELLS;i++) begin
      lower=0;
      for(int j=0;j<i;j++) if(creating[j]) lower++;
      if(destination[i]!=0 && !completing[i]) begin
        arrivals[i]+=lower; lower_arrivals+=64'(lower);
      end
      if(creating[i]) begin
        made++; made_cell[i]++; route_id[i]=made;
        initial_ahead[i]=0;
        for(int j=0;j<i;j++) if(np[j]!=0) initial_ahead[i]++;
        service_age[i]=0; wall_age[i]=0; enabled_age[i]=0; arrivals[i]=0;
        direction_hits[test_mode][np[i]>0]++;
        signature=(signature^route_id[i])*64'h100000001b3;
      end
      model_state[i]=ns[i]; destination[i]=np[i];
      if(np[i]!=0) eq("active-zero ownership",ns[i],0);
      eq("cell route conservation",made_cell[i],done_cell[i]+64'(np[i]!=0));
      eq("route ID occupancy",route_id[i]!=0,np[i]!=0);
    end
    alive=outstanding(); if(alive>max_pending) max_pending=alive;
    eq("global route conservation",made,done+64'(alive));
    eq("direct transitions",direct_events,0); eq("queue overflow",overflow_events,0);
    eq("reserved states",reserved_events,0); eq("execution invariants",invariants,1023);
    checked_edges++;
  endtask

  event prepare_request, check_request;
  bit edge_prepared=0, edge_checked=0;
  always @(prepare_request) begin
    prepare_edge(tick_enable);
    edge_prepared=1;
  end
  always @(check_request) begin
    check_edge(tick_enable);
    edge_checked=1;
  end

  task automatic step(input bit enabled);
    tick_enable=enabled; #2;
    edge_prepared=0; ->prepare_request; wait(edge_prepared);
    clk=1; #2;
    edge_checked=0; ->check_request; wait(edge_checked);
    clk=0; #1;
  endtask

  task automatic lane(input int lane_index, cell_index, goal);
    external_request_valid[lane_index]=1;
    external_request_cell_index[IB*lane_index+:IB]=IB'(cell_index);
    external_request_target[2*lane_index+:2]=code(goal);
    external_target_bank[2*cell_index+:2]=code(goal);
  endtask
  task automatic refresh(input int t);
    local_gamma_enable=t[0]; local_thermal_enable=t[1];
    gamma_update_valid=t%5==0; clear_counters=t%17==0;
    phase_load_valid=t%127==0;
    for(int i=0;i<CELLS;i++) begin
      gamma_targets_q16[32*i+:32]=32'((i%2==0?1:-1)*(32768+31*t));
      gamma_effective_word[32*i+:32]=32'h26666666+32'(i+t)*32'h00123457;
      thermal_node_factor_q30[32*i+:32]=32'h10000000+32'(i%4)*32'h08000000;
      phase_load[32*i+:32]=32'(i+t)*32'h19765431;
      frequency_load_q16[32*i+:32]=32'(65536+257*i);
    end
  endtask
  task automatic seed_all(input int mode, kind);
    require(outstanding()==0,"preceding profile has no live routes");
    test_mode=mode; profile=kind; checking_load=0;
    tick_enable=0; clear_counters=0; phase_load_valid=0; auto_target_enable=0;
    gamma_update_valid=0; external_request_valid=0; scheduler_mode=FRP_MODE_FREE;
    rst_n=0; #2; clk=1; #2; clk=0; rst_n=1; #2;
    model_mode=0; position=0; model_ticks=0; target_valid=0;
    foreach(model_counts[i]) model_counts[i]=0;
    for(int i=0;i<CELLS;i++) begin
      model_state[i]=0; destination[i]=0; target[i]=0; route_id[i]=0; cohort[i]=0;
      eq("reset state",state[2*i+:2],0); eq("reset pending",pending[2*i+:2],0);
    end
    for(int block_index=0;block_index<4;block_index++) begin
      for(int j=0;j<LANES;j++) lane(j,block_index*LANES+j,j%2==0?1:-1);
      step(1);
    end
    external_request_valid=0; repeat(4) step(1);
    scheduler_mode=FRP_MODE_7_1; step(0);
    for(int block_index=0;block_index<4;block_index++) begin
      for(int j=0;j<LANES;j++) lane(j,block_index*LANES+j,-model_state[block_index*LANES+j]);
      step(1);
    end
    eq("seeded route population",outstanding(),CELLS);
    for(int i=0;i<CELLS;i++) cohort[i]=route_id[i];
    external_request_valid=0;
    scheduler_mode=frp_m31_scheduler_mode_e'(mode); step(0);
    checking_load=1;
  endtask
  task automatic finish_profile;
    checking_load=0; external_request_valid=0; auto_target_enable=0;
    phase_load_valid=0; gamma_update_valid=0; clear_counters=0;
    repeat(32) step(1);
    eq("profile cleanup",outstanding(),0);
    step(0); step(0);
  endtask
  task automatic lower_traffic(input int count);
    int ci,goal;
    for(int j=0;j<LANES;j++) begin
      ci=j%count;
      goal=destination[ci]!=0?-destination[ci]:model_state[ci]!=0?-model_state[ci]:1;
      lane(j,ci,goal);
    end
  endtask

  task automatic bounded_refill(input int mode);
    int t, opportunities, births, previous_made;
    seed_all(mode,0); t=0; opportunities=0; births=0;
    while(cohort_live()) begin
      require(t<8*(REFILL_BOUND+2),"bounded-refill wall limit");
      refresh(t); lower_traffic(LANES-1); previous_made=int'(made);
      if(t%11==0) step(0);
      if(cadence()==0 || cadence()==2 || cadence()==3) begin
        require(births<=LANES-1,"bounded lower-index refill quota");
        births=0; opportunities++;
      end
      step(1); births+=int'(made)-previous_made; t++;
      require(opportunities<=REFILL_BOUND,"cohort completes with continuing bounded refill");
    end
    fair_cases++;
    $display("BOUNDED_REFILL cells=%0d mode=%0d opportunities=%0d bound=%0d enabled_ticks=%0d",
      CELLS,mode,opportunities,REFILL_BOUND,t);
    finish_profile();
  endtask

  task automatic full_refill(input int mode);
    int t,opportunities,release_services,ci;
    longint unsigned watched;
    seed_all(mode,1); watched=cohort[CELLS-1]; t=0; opportunities=0;
    while(opportunities<12) begin
      refresh(t); lower_traffic(LANES);
      if(t%11==0) step(0);
      if(cadence()==0 || cadence()==2 || cadence()==3) opportunities++;
      step(1); t++;
      require(t<=104,"full-refill service window");
    end
    if(mode==0) require(route_id[CELLS-1]!=watched,"FREE services initial high-index route");
    else begin
      eq("high-index route retains its ID",route_id[CELLS-1],watched);
      eq("high-index route service age",service_age[CELLS-1],12);
      eq("high-index destination retained",pending[2*(CELLS-1)+:2],code(destination[CELLS-1]));
    end
    release_services=0;
    while(route_id[CELLS-1]==watched) begin
      refresh(t); ci=CELLS-1;
      for(int j=0;j<LANES;j++) lane(j,ci,-destination[ci]);
      if(t%11==0) step(0);
      if(cadence()==0 || cadence()==2 || cadence()==3) release_services++;
      step(1); t++;
      require(release_services<=4,"release completes with conflicting requests still offered");
      require(t<=144,"release wall limit");
    end
    refill_cases++;
    $display("FULL_REFILL cells=%0d mode=%0d service_window=12 retained=%0d release_services=%0d",
      CELLS,mode,mode!=0,release_services);
    finish_profile();
  endtask

  task automatic mixed_stream(input int mode);
    int ci,goal;
    seed_all(mode,2);
    for(int t=0;t<1024;t++) begin
      refresh(t); auto_target_enable=(t%64)>=32;
      for(int j=0;j<LANES;j++) begin
        ci=(t*LANES+j)%CELLS;
        if(t%5==0) ci=t%CELLS;
        goal=destination[ci]!=0?-destination[ci]:model_state[ci]!=0?-model_state[ci]:((t+j)%2==0?1:-1);
        lane(j,ci,goal);
      end
      if(t%11==0) step(0);
      step(1);
    end
    stream_cases++;
    $display("MIXED_STREAM cells=%0d mode=%0d enabled_ticks=1024",CELLS,mode);
    finish_profile();
  endtask

  initial begin
    real sample;
    if(!(CELLS inside {8,16,32,64})) $fatal(1,"Supported CELLS: 8,16,32,64");
    for(int i=0;i<4096;i++) begin
      sample=$sin(6.283185307179586476925286766559*i/4096.0)*1073741824.0;
      sine_table[i]=$rtoi(sample<0?sample-0.5:sample+0.5);
    end
    for(int m=0;m<3;m++) begin bounded_refill(m); full_refill(m); mixed_stream(m); end
    eq("bounded-refill cases",fair_cases,3); eq("full-refill cases",refill_cases,3);
    eq("mixed-stream cases",stream_cases,3); eq("final route conservation",made,done);
    eq("all-cell backlog reached",max_pending,CELLS); eq("checked edges",checked_edges,cycles);
    for(int i=0;i<CELLS;i++) require(made_cell[i]>0 && made_cell[i]==done_cell[i],"per-cell completed routes");
    foreach(completed_loaded[m]) require(completed_loaded[m]>0,"completion under continuing load");
    foreach(direction_hits[m,d]) require(direction_hits[m][d]>0,"both route polarities per mode");
    foreach(source_hits[m,s,a]) require(source_hits[m][s][a]>0,"feedback and request-source coverage");
    foreach(cadence_hits[c]) require(cadence_hits[c]>0,"all scheduler cadences");
    require(conflict_lanes>0 && duplicate_lanes>0 && capacity_waits>0 &&
            paused_routes>0 && cadence_waits>0 && lower_arrivals>0 &&
            automatic_edges>0 && clear_edges>0,"load interaction coverage");
    $display("PASS ROUTE_UNDER_LOAD cells=%0d cycles=%0d checks=%0d created=%0d completed=%0d loaded_edges=%0d service_edges=%0d conflicts=%0d duplicates=%0d capacity_waits=%0d paused_routes=%0d cadence_waits=%0d lower_arrivals=%0d max_service_age=%0d max_wall_age=%0d signature=%016h",
      CELLS,cycles,checks,made,done,loaded_edges,service_edges,conflict_lanes,duplicate_lanes,
      capacity_waits,paused_routes,cadence_waits,lower_arrivals,max_service_age,max_wall_age,signature);
    $finish;
  end
  initial begin #1000000; $fatal(1,"Route-under-load timeout"); end
endmodule

// SPDX-License-Identifier: Apache-2.0
// Registered target/request integration, with an independent state scoreboard.
// Request targets are destinations, not executed states; opposite execution
// remains a downstream -1 -> 0 -> 1 or 1 -> 0 -> -1 route on separate ticks.
`timescale 1ns/1ps
`include "frp_m32_registered_target_request_path.sv"

module frp_m32_registered_request_case #(
  parameter int CELLS = 8,
  parameter int LANES = 2,
  parameter int COUNTER_BITS = 32,
  parameter int INDEX_BITS = (CELLS <= 1) ? 1 : $clog2(CELLS)
) (output bit done);
  import frp_m31_pkg::*;
  localparam int WORD_BITS = 2*CELLS;
  localparam int OUTPUT_BITS = WORD_BITS + 6 + 2*COUNTER_BITS + LANES*(INDEX_BITS+3);
  localparam int MATRIX_CASES = 18432*CELLS;
  localparam int MASK_CASES = 10*(1 << CELLS);
  localparam int PRESSURE = (COUNTER_BITS <= 8) ? (1 << COUNTER_BITS)+3 : 260;
  localparam longint unsigned MAX_COUNT = (64'd1 << COUNTER_BITS)-1;
  localparam int EXPECTED_CHECKS = 5185 + 6*(MATRIX_CASES+MASK_CASES+PRESSURE);

  logic clk = 0, rst_n = 1, tick_enable = 0, clear_counters = 0;
  logic phase_target_valid = 0, auto_target_enable = 0;
  logic [WORD_BITS-1:0] phase_target_source = 0, retained_state = 0, pending_route = 0;
  frp_m31_scheduler_state_e scheduler_state = FRP_SCHED_FREE;
  logic [WORD_BITS-1:0] registered_target_q;
  logic registered_target_valid_q, phase_target_domain_valid, registered_target_domain_valid;
  logic capture_accepted, capture_rejected, registered_request_enable;
  logic [COUNTER_BITS-1:0] accepted_capture_events_q, rejected_capture_events_q;
  logic [LANES-1:0] phase_request_valid;
  logic [LANES*INDEX_BITS-1:0] phase_request_cell_index;
  logic [2*LANES-1:0] phase_request_target;

  logic [WORD_BITS-1:0] saved_target = 0;
  bit saved_valid = 0;
  longint unsigned accepted_total = 0, rejected_total = 0;
  int matrix_cases = 0, mask_cases = 0, reset_cases = 0, resets = 0;
  int observations = 0, steps = 0, pressure_events = 0, scheduler_samples = 0;
  int empty_outputs = 0, one_request_outputs = 0, two_request_outputs = 0;
  int accepted_saturation_holds = 0, rejected_saturation_holds = 0;
  logic [CELLS-1:0] lane0_cells = 0, lane1_cells = 0;

  frp_m32_registered_target_request_path #(
    .CELLS(CELLS), .REQUEST_LANES(LANES), .CELL_INDEX_BITS(INDEX_BITS),
    .COUNTER_BITS(COUNTER_BITS)
  ) dut (
    .clk, .rst_n, .tick_enable, .clear_counters, .phase_target_valid,
    .phase_target_source, .auto_target_enable, .retained_state, .pending_route,
    .scheduler_state, .registered_target_q, .registered_target_valid_q,
    .phase_target_domain_valid, .registered_target_domain_valid,
    .capture_accepted, .capture_rejected, .accepted_capture_events_q,
    .rejected_capture_events_q, .registered_request_enable,
    .phase_request_valid, .phase_request_cell_index, .phase_request_target
  );

  function automatic logic [1:0] symbol(input int value);
    case (value)
      -1: return 2'b11;
       0: return 2'b00;
       1: return 2'b01;
      default: begin $fatal(1, "Invalid test symbol %0d", value); return 2'b10; end
    endcase
  endfunction

  function automatic bit canonical(input logic [WORD_BITS-1:0] word_value);
    for (int i = 0; i < CELLS; i++)
      if (word_value[2*i +: 2] == 2'b10) return 0;
    return 1;
  endfunction

  // Literal transition table, independent of DUT package helper functions.
  // Pending inputs in this test are canonical; any pending polarity owns its cell.
  function automatic bit eligible(
      input logic [1:0] old_value, goal, pending, input int sched);
    if (pending != 2'b00) return 0;
    case ({old_value, goal})
      4'b1100, 4'b0100, 4'b1101, 4'b0111:
        return sched == 0 || sched == 1 || sched == 4;
      4'b0001, 4'b0011:
        return sched == 0 || sched == 2 || sched == 3;
      default: return 0;
    endcase
  endfunction

  task automatic observe;
    logic [CELLS-1:0] candidates;
    logic [LANES-1:0] expected_valid;
    logic [LANES*INDEX_BITS-1:0] expected_index;
    logic [2*LANES-1:0] expected_target;
    logic [COUNTER_BITS-1:0] expected_accepts, expected_rejects;
    logic [OUTPUT_BITS-1:0] actual, expected;
    bit source_ok, accept_now, reject_now, request_gate;
    int rank, selected;
    #1;
    source_ok = canonical(phase_target_source);
    accept_now = tick_enable && phase_target_valid && source_ok;
    reject_now = tick_enable && phase_target_valid && !source_ok;
    request_gate = auto_target_enable && saved_valid;
    candidates = 0; expected_valid = 0; expected_index = 0; expected_target = 0;
    for (int i = 0; i < CELLS; i++)
      candidates[i] = eligible(retained_state[2*i +: 2], saved_target[2*i +: 2],
                               pending_route[2*i +: 2], int'(scheduler_state));
    // Rank each eligible cell by the number of smaller eligible indices.
    // This does not reuse the adapter's bounded append or transition helpers.
    for (int i = 0; i < CELLS; i++) begin
      rank = 0;
      for (int j = 0; j < i; j++) if (candidates[j]) rank++;
      if (request_gate && candidates[i] && rank < LANES) begin
        expected_valid[rank] = 1;
        expected_index[rank*INDEX_BITS +: INDEX_BITS] = INDEX_BITS'(i);
        expected_target[2*rank +: 2] = saved_target[2*i +: 2];
        if (rank == 0) lane0_cells[i] = 1;
        if (rank == 1) lane1_cells[i] = 1;
      end
    end
    expected_accepts = COUNTER_BITS'((accepted_total > MAX_COUNT) ? MAX_COUNT : accepted_total);
    expected_rejects = COUNTER_BITS'((rejected_total > MAX_COUNT) ? MAX_COUNT : rejected_total);
    actual = {registered_target_q, registered_target_valid_q, phase_target_domain_valid,
      registered_target_domain_valid, capture_accepted, capture_rejected,
      accepted_capture_events_q, rejected_capture_events_q, registered_request_enable,
      phase_request_valid, phase_request_cell_index, phase_request_target};
    expected = {saved_target, saved_valid, source_ok, 1'b1, accept_now, reject_now,
      expected_accepts, expected_rejects, request_gate,
      expected_valid, expected_index, expected_target};
    if (actual !== expected) begin
      $display("Request path inputs: cells=%0d bits=%0d reset_n=%b tick=%b clear=%b offered=%b auto=%b sched=%0d source=%h retained=%h pending=%h saved=%h history=%b",
        CELLS, COUNTER_BITS, rst_n, tick_enable, clear_counters, phase_target_valid,
        auto_target_enable, scheduler_state, phase_target_source, retained_state,
        pending_route, saved_target, saved_valid);
      $fatal(1, "Registered request mismatch check=%0d actual=%h expected=%h",
        observations, actual, expected);
    end
    observations++;
    selected = $countones(expected_valid);
    case (selected)
      0: empty_outputs++;
      1: one_request_outputs++;
      2: two_request_outputs++;
      default: $fatal(1, "Unsupported lane count in this regression");
    endcase
  endtask

  task automatic step;
    observe();
    clk = 1;
    if (tick_enable && phase_target_valid && canonical(phase_target_source)) begin
      saved_target = phase_target_source;
      saved_valid = 1;
    end
    if (clear_counters) begin accepted_total = 0; rejected_total = 0; end
    else if (tick_enable && phase_target_valid) begin
      if (canonical(phase_target_source)) accepted_total++;
      else rejected_total++;
    end
    observe();
    clk = 0;
    observe();
    steps++;
  endtask

  task automatic reset_and_check;
    rst_n = 0;
    saved_target = 0; saved_valid = 0; accepted_total = 0; rejected_total = 0;
    observe();
    clk = 1; observe();
    clk = 0; observe();
    rst_n = 1; observe();
    resets++;
  endtask

  initial begin : regression
    logic [WORD_BITS-1:0] goal;
    logic [1:0] polarity;
    done = 0;
    reset_and_check();

    // Reset destroys capture history under every control combination, including
    // a valid active-zero source. Capture flags remain combinational in reset.
    for (int sched = 0; sched < 8; sched++)
      for (int code = 0; code < 4; code++)
        for (int controls = 0; controls < 16; controls++) begin
          tick_enable = 1; phase_target_valid = 1; clear_counters = 0;
          auto_target_enable = 1; phase_target_source = {CELLS{2'b01}};
          retained_state = 0; pending_route = 0; scheduler_state = FRP_SCHED_FREE;
          step();
          phase_target_source = {CELLS{2'(code)}};
          retained_state = {CELLS{2'b11}};
          phase_target_valid = controls[0]; tick_enable = controls[1];
          clear_counters = controls[2]; auto_target_enable = controls[3];
          scheduler_state = frp_m31_scheduler_state_e'(sched);
          reset_and_check();
          step();
          reset_cases++;
        end

    // Every cell, three saved symbols, four source and retained symbols, three
    // pending symbols, eight scheduler codes and all sixteen control settings.
    // Each case first captures a known old word, then checks before/after the
    // candidate capture and on the falling edge; invalid sources reject atomically.
    for (int cell_index = 0; cell_index < CELLS; cell_index++)
      for (int prior = -1; prior <= 1; prior++)
        for (int source = 0; source < 4; source++)
          for (int retained = 0; retained < 4; retained++)
            for (int pending = -1; pending <= 1; pending++)
              for (int sched = 0; sched < 8; sched++)
                for (int controls = 0; controls < 16; controls++) begin
                  phase_target_source = 0;
                  phase_target_source[2*cell_index +: 2] = symbol(prior);
                  tick_enable = 1; phase_target_valid = 1;
                  clear_counters = 1; auto_target_enable = 0;
                  step();
                  phase_target_source = 0; retained_state = 0; pending_route = 0;
                  phase_target_source[2*cell_index +: 2] = 2'(source);
                  retained_state[2*cell_index +: 2] = 2'(retained);
                  pending_route[2*cell_index +: 2] = symbol(pending);
                  scheduler_state = frp_m31_scheduler_state_e'(sched);
                  phase_target_valid = controls[0]; tick_enable = controls[1];
                  clear_counters = controls[2]; auto_target_enable = controls[3];
                  step();
                  matrix_cases++;
                end

    // All candidate masks, five valid scheduler states and two polarity layouts.
    // Source validity, source-domain validity and tick_enable cannot gate an
    // already registered request; auto enable alone can suppress and restore it.
    for (int sched = 0; sched < 5; sched++)
      for (int sign = 0; sign < 2; sign++)
        for (int mask = 0; mask < (1 << CELLS); mask++) begin
          goal = 0; retained_state = 0; pending_route = 0;
          scheduler_state = frp_m31_scheduler_state_e'(sched);
          for (int i = 0; i < CELLS; i++) begin
            polarity = ((i+sign) % 2 == 0) ? 2'b01 : 2'b11;
            if (sched == 2 || sched == 3) goal[2*i +: 2] = polarity;
            else begin
              retained_state[2*i +: 2] = polarity;
              goal[2*i +: 2] = ((i+sign) % 3 == 0) ? 2'b00 : (polarity ^ 2'b10);
            end
            if (!mask[i])
              case ((i+mask+sign) % 4)
                0: retained_state[2*i +: 2] = goal[2*i +: 2];
                1: pending_route[2*i +: 2] = polarity;
                2: retained_state[2*i +: 2] = 2'b10;
                3: begin
                  if (sched == 1 || sched == 4) begin
                    retained_state[2*i +: 2] = 0; goal[2*i +: 2] = polarity;
                  end else if (sched == 2 || sched == 3) begin
                    retained_state[2*i +: 2] = polarity; goal[2*i +: 2] = 0;
                  end else pending_route[2*i +: 2] = polarity ^ 2'b10;
                end
                default: $fatal(1, "Invalid blocker");
              endcase
            if (eligible(retained_state[2*i +: 2], goal[2*i +: 2],
                         pending_route[2*i +: 2], sched) != mask[i])
              $fatal(1, "Invalid candidate-mask stimulus mask=%0d cell=%0d", mask, i);
          end
          phase_target_source = goal;
          tick_enable = 1; phase_target_valid = 1; clear_counters = 1; auto_target_enable = 1;
          step();
          tick_enable = 0; phase_target_valid = 0; clear_counters = 0;
          phase_target_source = {CELLS{2'b10}};
          observe();
          auto_target_enable = 0; observe();
          auto_target_enable = 1; observe();
          mask_cases++;
        end

    // Natural saturation in the small counters; ordinary counting in 32 bits.
    // Capture history and requests survive saturation and counter clears.
    reset_and_check();
    retained_state = 0; pending_route = 0; scheduler_state = FRP_SCHED_FREE;
    tick_enable = 1; phase_target_valid = 1; auto_target_enable = 1; clear_counters = 0;
    for (int event_index = 0; event_index < PRESSURE; event_index++) begin
      phase_target_source = (event_index % 2 == 0) ? {CELLS{2'b01}} : {CELLS{2'b11}};
      if (accepted_total >= MAX_COUNT) accepted_saturation_holds++;
      step(); pressure_events++;
      phase_target_source[WORD_BITS-1 -: 2] = 2'b10;
      if (rejected_total >= MAX_COUNT) rejected_saturation_holds++;
      step(); pressure_events++;
    end
    phase_target_source = 0; retained_state = {CELLS{2'b11}}; clear_counters = 1;
    step();
    tick_enable = 0; phase_target_source = {CELLS{2'b10}};
    step();

    // Literal 7/1 and 1/7 scheduler-state inputs; the scheduler itself is
    // qualified separately. Live downstream inputs act on the saved target.
    phase_target_source = {CELLS{2'b01}};
    tick_enable = 1; phase_target_valid = 1; clear_counters = 1;
    step();
    phase_target_valid = 0; clear_counters = 0;
    for (int mode = 0; mode < 2; mode++)
      for (int position = 0; position < 8; position++) begin
        scheduler_state = frp_m31_scheduler_state_e'(
          (mode == 0) ? ((position == 7) ? 2 : 1) : ((position == 0) ? 3 : 4));
        phase_target_source = (position % 2 == 0) ? {CELLS{2'b11}} : {CELLS{2'b10}};
        retained_state = (position % 3 == 0) ? '0 : {CELLS{2'b11}};
        pending_route = 0;
        if (position % 2 == 0) pending_route[2*(position % CELLS) +: 2] = 2'b11;
        step(); scheduler_samples++;
      end

    if (matrix_cases != MATRIX_CASES || mask_cases != MASK_CASES || reset_cases != 512 ||
        resets != 514 || pressure_events != 2*PRESSURE || scheduler_samples != 16 ||
        steps != 1043+2*MATRIX_CASES+MASK_CASES+2*PRESSURE || observations != EXPECTED_CHECKS ||
        accepted_saturation_holds != ((COUNTER_BITS <= 8) ? 4 : 0) ||
        rejected_saturation_holds != ((COUNTER_BITS <= 8) ? 4 : 0) || lane0_cells !== {CELLS{1'b1}} ||
        lane1_cells !== ((LANES == 1) ? CELLS'(0) : ({CELLS{1'b1}} ^ CELLS'(1))) ||
        empty_outputs+one_request_outputs+two_request_outputs != observations ||
        empty_outputs == 0 || one_request_outputs == 0 || (LANES == 2 && two_request_outputs == 0))
      $fatal(1, "Incomplete registered request coverage cells=%0d bits=%0d checks=%0d steps=%0d",
        CELLS, COUNTER_BITS, observations, steps);
    done = 1;
  end
endmodule

module frp_m32_registered_request_tb;
  wire done_single, done_small, done_wide;
  frp_m32_registered_request_case #(.CELLS(1), .LANES(1), .COUNTER_BITS(1)) single_cell(done_single);
  frp_m32_registered_request_case #(.COUNTER_BITS(3)) small_counter(done_small);
  frp_m32_registered_request_case #(.COUNTER_BITS(32)) wide_counter(done_wide);

  `define FRP_REQUEST_PROFILE(test_case) \
    $display("FRP_M32_REGISTERED_REQUEST_PROFILE: PASS cells=%0d lanes=%0d counter_bits=%0d output_bits=%0d matrix_cases=%0d mask_cases=%0d reset_cases=%0d resets=%0d pressure_events=%0d scheduler_samples=%0d steps=%0d observations=%0d empty_outputs=%0d one_request_outputs=%0d two_request_outputs=%0d accepted_saturation_holds=%0d rejected_saturation_holds=%0d lane0_cells=%0d lane1_cells=%0d", \
      test_case.CELLS, test_case.LANES, test_case.COUNTER_BITS, test_case.OUTPUT_BITS, \
      test_case.matrix_cases, test_case.mask_cases, test_case.reset_cases, test_case.resets, \
      test_case.pressure_events, test_case.scheduler_samples, test_case.steps, test_case.observations, \
      test_case.empty_outputs, test_case.one_request_outputs, test_case.two_request_outputs, \
      test_case.accepted_saturation_holds, test_case.rejected_saturation_holds, \
      test_case.lane0_cells, test_case.lane1_cells);

  initial begin
    wait (done_single && done_small && done_wide);
    `FRP_REQUEST_PROFILE(single_cell)
    `FRP_REQUEST_PROFILE(small_counter)
    `FRP_REQUEST_PROFILE(wide_counter)
    if (single_cell.observations+small_counter.observations+wide_counter.observations != 1928115)
      $fatal(1, "Incomplete registered request aggregate");
    $display("FRP_M32_REGISTERED_REQUEST_TB: PASS profiles=3 matrix_cases=313344 mask_cases=5140 reset_cases=1536 resets=1542 pressure_events=552 scheduler_samples=48 observations=1928115");
    $finish;
  end
  `undef FRP_REQUEST_PROFILE

  initial begin
    #2000000;
    $fatal(1, "FRP M32 registered request watchdog expired");
  end
endmodule

# Changelog — Fractal Resonance Processor (FRP)

All notable changes to the Fractal Resonance Processor (FRP) project are documented in this file.

## v0.9.9 — M7 FPGA Synthesis Package and Timing Constraint Scaffold

FRP v0.9.9 establishes the M7 FPGA Synthesis Package and Timing Constraint Scaffold layer.

This release extends the M6 formal verification hooks and equivalence scaffold layer into FPGA-oriented synthesis metadata, timing constraint preparation, resource estimate mapping, and implementation handoff scaffold generation.

### Added

- Added `frp_prototype_v0_9_9.py`.

- Added M7 milestone documentation:

  `docs/m7_fpga_synthesis_timing.md`

- Added M7 GitHub Actions workflow:

  `.github/workflows/frp-m7-fpga-synthesis.yml`

- Added M7 test report:

  `TEST_REPORT_v0_9_9.md`

- Added M7 release notes:

  `RELEASE_NOTES_v0_9_9.md`

### M7 Export Layers

FRP v0.9.9 defines the following M7 export layers:

- `fpga_synthesis_manifest`;

- `timing_constraint_profile`;

- `resource_estimate_map`;

- `implementation_handoff_scaffold`.

### M7 Export Commands

FPGA synthesis manifest export:

`python frp_prototype_v0_9_9.py --export-fpga-synthesis-manifest`

Timing constraint profile export:

`python frp_prototype_v0_9_9.py --export-timing-constraint-profile`

Resource estimate map export:

`python frp_prototype_v0_9_9.py --export-resource-estimate-map`

Implementation handoff scaffold export:

`python frp_prototype_v0_9_9.py --export-implementation-handoff`

Benchmark matrix export:

`python frp_prototype_v0_9_9.py --export-benchmark-matrix`

### Structured Output Schema

`frp.structured_output.v0.9.9`

### M7 Export Schemas

`frp.m7.fpga_synthesis_manifest.v0.9.9`

`frp.m7.timing_constraint_profile.v0.9.9`

`frp.m7.resource_estimate_map.v0.9.9`

`frp.m7.implementation_handoff_scaffold.v0.9.9`

### Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M7 FPGA Synthesis and Timing Scaffold.

### FPGA Synthesis Manifest

Validated FPGA synthesis manifest targets:

- top module name;

- clock domain definition;

- reset domain definition;

- RTL signal groups;

- assertion groups;

- formal property groups;

- equivalence trace groups;

- synthesis source groups;

- generated artifact references.

Validated top module:

`frp_top_v0_9_9`

### Timing Constraint Profile

Validated timing constraint targets:

- `T_PRIMARY_CLOCK_PERIOD`;

- `T_RESET_RELEASE_WINDOW`;

- `T_BOUNDED_STEP_COUNTER`;

- `T_SCHEDULER_STATE`;

- `T_PHASE_TELEMETRY_Q16`;

- `T_STABILITY_TELEMETRY_Q16`;

- `T_TRANSITION_COUNTERS`;

- `T_EQUIVALENCE_TRACE_SAMPLING`.

### Resource Estimate Map

Validated resource estimate categories:

- `R_TERNARY_CELL_STATE_REGISTERS`;

- `R_PHASE_Q16_REGISTERS`;

- `R_SCHEDULER_REGISTERS`;

- `R_TRANSITION_COUNTER_REGISTERS`;

- `R_STABILITY_TELEMETRY_REGISTERS`;

- `R_PHASE_ORDER_TELEMETRY_REGISTERS`;

- `R_ASSERTION_COMPARISON_LOGIC`;

- `R_EQUIVALENCE_TRACE_COMPARISON_LOGIC`;

- `R_BOUNDED_STEP_COUNTER_LOGIC`;

- `R_FORMAL_HARNESS_SUPPORT_LOGIC`.

### Preserved Candidate Invariants

FRP v0.9.9 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

`neutralized_conflicts tracked`

### Technical Position

`FRP v0.9.9 extends the M6 formal verification hooks and equivalence scaffold layer into FPGA synthesis manifest export, timing constraint profile export, resource estimate map export, and implementation handoff scaffold generation.`

## v0.9.8 — M6 Formal Verification Hooks and Equivalence Scaffold

FRP v0.9.8 establishes the M6 Formal Verification Hooks and Equivalence Scaffold layer.

This release extends the M5 RTL interface contract and assertion harness layer into formal property records, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.

### Added

- Added `frp_prototype_v0_9_8.py`.

- Added M6 milestone documentation:

  `docs/m6_formal_verification_equivalence.md`

- Added M6 GitHub Actions workflow:

  `.github/workflows/frp-m6-formal-verification.yml`

- Added M6 test report:

  `TEST_REPORT_v0_9_8.md`

- Added M6 release notes:

  `RELEASE_NOTES_v0_9_8.md`

### M6 Export Layers

FRP v0.9.8 defines the following M6 export layers:

- `formal_property_set`;

- `equivalence_trace_map`;

- `bounded_verification_config`;

- `formal_harness_scaffold`.

### M6 Export Commands

Formal property set export:

`python frp_prototype_v0_9_8.py --export-formal-property-set`

Equivalence trace map export:

`python frp_prototype_v0_9_8.py --export-equivalence-trace-map`

Bounded verification config export:

`python frp_prototype_v0_9_8.py --export-bounded-verification-config`

Formal harness scaffold export:

`python frp_prototype_v0_9_8.py --export-formal-harness`

Benchmark matrix export:

`python frp_prototype_v0_9_8.py --export-benchmark-matrix`

### Structured Output Schema

`frp.structured_output.v0.9.8`

### M6 Export Schemas

`frp.m6.formal_property_set.v0.9.8`

`frp.m6.equivalence_trace_map.v0.9.8`

`frp.m6.bounded_verification_config.v0.9.8`

`frp.m6.formal_harness_scaffold.v0.9.8`

### Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M6 Formal Verification and Equivalence Scaffold.

### Formal Property Targets

Validated formal property targets:

- `P_DIRECT_EVENTS_ZERO`;

- `P_MATCH_EQUALS_ONE`;

- `P_C_MINUS_P_POSITIVE`;

- `P_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION`;

- `P_TICKS_RECORDED_EQUALS_STEPS`;

- `P_SCHEDULER_COUNTS_SUM_EQUALS_STEPS`;

- `P_NEUTRAL_ROUTED_TRANSITION_PATH`.

### Equivalence Trace Mapping

Validated equivalence trace mappings:

- `cell_state` to `frp_cell_state`;

- `phase_q16` to `frp_phase_q16`;

- `scheduler_state` to `frp_scheduler_state`;

- `switch_load_q16` to `frp_switch_load_q16`;

- `heat_q16` to `frp_heat_q16`;

- `C_minus_P_q16` to `frp_C_minus_P_q16`;

- `phase_order_R_q16` to `frp_phase_order_R_q16`;

- `actual_direct_events` to `frp_actual_direct_events`;

- `prevented_direct_events` to `frp_prevented_direct_events`;

- `neutralized_conflicts` to `frp_neutralized_conflicts`.

### Preserved Candidate Invariants

FRP v0.9.8 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

`neutral-routed transition path is preserved`

### Technical Position

`FRP v0.9.8 extends the M5 RTL interface contract and assertion harness layer into formal property export, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.`

## v0.9.7 — M5 RTL Interface Contract and Assertion Harness

FRP v0.9.7 establishes the M5 RTL Interface Contract and Assertion Harness layer.

This release extends the M4 HDL trace and testbench scaffold layer into RTL-facing signal contract definition, deterministic interface records, assertion target mapping, RTL signal binding, and machine-readable assertion harness preparation.

### Added

- Added `frp_prototype_v0_9_7.py`.

- Added M5 milestone documentation:

  `docs/m5_rtl_interface_assertion_harness.md`

- Added M5 GitHub Actions workflow:

  `.github/workflows/frp-m5-rtl-assertion-harness.yml`

- Added M5 test report:

  `TEST_REPORT_v0_9_7.md`

- Added M5 release notes:

  `RELEASE_NOTES_v0_9_7.md`

### M5 Export Layers

FRP v0.9.7 defines the following M5 export layers:

- `rtl_interface_contract`;

- `assertion_manifest`;

- `rtl_signal_binding`;

- `assertion_harness_scaffold`.

### M5 Export Commands

RTL interface contract export:

`python frp_prototype_v0_9_7.py --export-rtl-interface-contract`

Assertion manifest export:

`python frp_prototype_v0_9_7.py --export-assertion-manifest`

RTL signal binding export:

`python frp_prototype_v0_9_7.py --export-rtl-signal-binding`

Assertion harness scaffold export:

`python frp_prototype_v0_9_7.py --export-assertion-harness`

Benchmark matrix export:

`python frp_prototype_v0_9_7.py --export-benchmark-matrix`

### Structured Output Schema

`frp.structured_output.v0.9.7`

### M5 Export Schemas

`frp.m5.rtl_interface_contract.v0.9.7`

`frp.m5.assertion_manifest.v0.9.7`

`frp.m5.rtl_signal_binding.v0.9.7`

`frp.m5.assertion_harness_scaffold.v0.9.7`

### Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M5 RTL Interface and Assertion Harness.

### Preserved Candidate Invariants

FRP v0.9.7 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

### Technical Position

`FRP v0.9.7 extends the M4 HDL trace and testbench scaffold layer into RTL interface contract definition, assertion manifest export, RTL signal binding, and assertion harness scaffold generation.`

## v0.9.6 — M4 HDL Trace Export and Testbench Scaffold

FRP v0.9.6 establishes the M4 HDL Trace Export and Testbench Scaffold layer.

This release extends the M3 benchmark and hardware-facing signal mapping layer into HDL-oriented trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

### Added

- Added `frp_prototype_v0_9_6.py`.

- Added M4 milestone documentation:

  `docs/m4_hdl_trace_testbench.md`

- Added M4 GitHub Actions workflow:

  `.github/workflows/frp-m4-hdl-trace.yml`

- Added M4 test report:

  `TEST_REPORT_v0_9_6.md`

- Added M4 release notes:

  `RELEASE_NOTES_v0_9_6.md`

### M4 Export Layers

FRP v0.9.6 defines the following M4 export layers:

- `hdl_trace`;

- `vcd_trace`;

- `signal_fixture`;

- `verilog_testbench_scaffold`.

### M4 Export Commands

HDL trace export:

`python frp_prototype_v0_9_6.py --export-hdl-trace`

VCD-style trace export:

`python frp_prototype_v0_9_6.py --export-vcd-trace`

Signal fixture export:

`python frp_prototype_v0_9_6.py --export-signal-fixture`

Verilog testbench scaffold export:

`python frp_prototype_v0_9_6.py --export-verilog-testbench`

Benchmark matrix export:

`python frp_prototype_v0_9_6.py --export-benchmark-matrix`

### Structured Output Schema

`frp.structured_output.v0.9.6`

### M4 Export Schemas

`frp.m4.hdl_trace.v0.9.6`

`frp.m4.vcd_trace.v0.9.6`

`frp.m4.signal_fixture.v0.9.6`

`frp.m4.verilog_testbench_scaffold.v0.9.6`

### Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M4 HDL Trace and Testbench.

### Preserved Candidate Invariants

FRP v0.9.6 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

### Technical Position

`FRP v0.9.6 extends the M3 benchmark and hardware-facing signal mapping layer into HDL trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.`

## v0.9.5 — M3 Benchmark Export and Hardware Signal Mapping

FRP v0.9.5 establishes the M3 Benchmark Export and Hardware Signal Mapping layer.

This release extends the v0.9.4 structured-output layer into benchmark export, hardware-facing signal mapping, FPGA register-map drafting, and testbench comparison preparation.

### Added

- Added `frp_prototype_v0_9_5.py`.

- Added benchmark matrix export:

  `python frp_prototype_v0_9_5.py --export-benchmark-matrix`

- Added hardware-facing signal map export:

  `python frp_prototype_v0_9_5.py --export-signal-map`

- Added FPGA register map draft export:

  `python frp_prototype_v0_9_5.py --export-register-map`

- Added testbench vector export:

  `python frp_prototype_v0_9_5.py --export-testbench-vector`

- Added M3 benchmark matrix documentation:

  `docs/benchmark_matrix.md`

- Added M3 hardware signal mapping documentation:

  `docs/hardware_signal_mapping.md`

- Added M3 FPGA register map draft documentation:

  `docs/fpga_register_map_draft.md`

- Added M3 testbench comparison plan:

  `docs/testbench_comparison_plan.md`

- Added M3 validation targets:

  `docs/m3_validation_targets.md`

- Added GitHub Actions workflow:

  `.github/workflows/frp-m3-benchmark-signal-map.yml`

- Added release notes:

  `RELEASE_NOTES_v0_9_5.md`

- Added test report:

  `TEST_REPORT_v0_9_5.md`

### Structured Output

The structured-output schema was advanced to:

`frp.structured_output.v0.9.5`

The following execution modes remain supported:

- `--mode demo`;

- `--mode self-test`;

- `--mode benchmark`.

The following output modes remain supported:

- `--output text`;

- `--output json`.

Optional telemetry export remains supported:

`--include-telemetry`

### M3 Export Schemas

FRP v0.9.5 defines the following M3 export schemas:

`frp.m3.benchmark_matrix.v0.9.5`

`frp.m3.hardware_signal_map.v0.9.5`

`frp.m3.fpga_register_map_draft.v0.9.5`

`frp.m3.testbench_vector.v0.9.5`

### Preserved Candidate Invariants

FRP v0.9.5 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

### Validation

Validated GitHub Actions workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M3 Benchmark and Signal Map.

Observed validation status:

`PASS`

### Technical Position

`FRP v0.9.5 extends the structured-output layer into benchmark export and hardware-facing signal mapping. The release defines machine-readable benchmark matrices, signal-map fields, register-map draft structures, and testbench comparison vectors for future FPGA, ASIC, and external architecture comparison workflows.`

## v0.9.4 — Structured Output and Machine-Readable Validation

Release title:

    Fractal Resonance Processor (FRP) v0.9.4 — Structured Output and Machine-Readable Validation

Milestone:

    M2 — Structured Output

Main prototype file:

    frp_prototype_v0_9_4.py

Schema marker:

    frp.structured_output.v0.9.4

### Added

- Added `frp_prototype_v0_9_4.py`.
- Added structured JSON output support.
- Added `--output text`.
- Added `--output json`.
- Added `--include-telemetry`.
- Added shared JSON envelope for structured output.
- Added schema marker:

        frp.structured_output.v0.9.4

- Added machine-readable output for demo mode.
- Added machine-readable output for self-test mode.
- Added machine-readable output for benchmark mode.
- Added optional telemetry export in JSON output.
- Added structured self-test JSON result.
- Added structured benchmark JSON result.
- Added structured demo execution log.
- Added structured telemetry path for future hardware-facing signal mapping.
- Added `TEST_REPORT_v0_9_4.md`.
- Added `RELEASE_NOTES_v0_9_4.md`.
- Added GitHub Actions workflow:

        .github/workflows/frp-structured-output.yml

- Added dedicated CI validation for structured output.
- Added JSON self-test validation.
- Added JSON benchmark validation.
- Added JSON demo validation.
- Added JSON telemetry validation.
- Added schema marker validation in CI.
- Added version marker validation in CI.

### Updated

- Updated `docs/output_schema.md` for v0.9.4 structured output.
- Updated `USAGE.md` for JSON output commands.
- Updated `REPRODUCIBILITY.md` for JSON reproducibility commands.
- Updated `CI.md` for structured-output validation.
- Updated release-facing documentation for the M2 Structured Output milestone.

### Preserved

FRP v0.9.4 preserves the v0.9.3 processor logic.

The following core logic remains aligned with the v0.9.3 reference model:

- balanced ternary states `-1`, `0`, `1`
- neutral transition routing
- direct polarity transition safety
- distributed ternary commit
- transition fraction control
- scheduler modes `free`, `7/1`, and `1/7`
- Kuramoto-Sakaguchi resonant phase coupling
- nonlinear cubic saturation
- nonlinear compression
- logic delay buffers
- coupling delay buffers
- per-tick telemetry inside the model
- processor instruction execution
- self-test mode
- benchmark mode

### Validation

Validated through GitHub Actions workflow:

    FRP Structured Output

Observed status:

    PASS

Validated stages:

- Python syntax validation
- dependency installation
- text self-test
- text benchmark
- JSON self-test
- JSON benchmark
- JSON demo
- JSON telemetry demo
- schema marker validation
- version marker validation
- direct transition safety validation
- positive C_minus_P stability validation
- benchmark architecture label validation
- telemetry field validation

Existing workflows remained compatible:

    FRP Self Test
    FRP Benchmark Smoke Test

Observed status:

    PASS

### Benchmark-Supported Technical Position

The benchmark-supported technical position remains:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

In v0.9.4 this position is also emitted through structured benchmark JSON output.

### Role of This Release

FRP v0.9.4 establishes the M2 structured output layer.

This release prepares the project for:

- automated validation
- structured result inspection
- benchmark export
- telemetry export
- CI-based JSON validation
- hardware-facing signal mapping
- future FPGA register mapping
- future testbench comparison

## v0.9.3 — Ternary Resonant Coherence Processor

Release title:

    Fractal Resonance Processor (FRP) v0.9.3 — Ternary Resonant Coherence Processor

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Test report:

    TEST_REPORT_v0_9_3.md

DOI:

    10.5281/zenodo.21112439

### Added

- Added executable FRP Python reference prototype.
- Added balanced ternary processor model.
- Added ternary states:

        -1
        0
        1

- Added neutral transition routing.
- Added direct polarity transition safety.
- Added distributed ternary commit.
- Added transition fraction control.
- Added scheduler modes:

        free
        7/1
        1/7

- Added Kuramoto-Sakaguchi resonant phase coupling.
- Added nonlinear cubic saturation.
- Added nonlinear compression.
- Added logic delay buffers.
- Added coupling delay buffers.
- Added per-tick telemetry inside the model.
- Added processor instruction layer.
- Added register file behavior.
- Added demo mode.
- Added self-test mode.
- Added benchmark mode.
- Added benchmark comparison across four architecture profiles:

        binary_style_forced_switch
        direct_ternary_commit
        distributed_neutral_ternary
        frp_distributed_resonant

- Added release-facing documentation.
- Added reproducibility documentation.
- Added CI documentation.
- Added hardware-facing documentation pathway.
- Added FPGA mapping study documentation.
- Added ASIC mapping study documentation.
- Added physical validation planning documentation.

### Validation

Standard self-test command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Observed standard self-test result:

    runs: 300
    C_minus_P_min: 0.14475
    heat_peak: 0.10700
    switch_load_peak: 0.25
    actual_direct_events: 0
    prevented_direct_events: 3820
    neutralized_conflicts: 2392
    failures: 0
    result: PASS

Heavy self-test command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Observed heavy self-test result:

    runs: 600
    C_minus_P_min: 0.14475
    heat_peak: 0.10700
    switch_load_peak: 0.25
    actual_direct_events: 0
    prevented_direct_events: 7913
    neutralized_conflicts: 4921
    failures: 0
    result: PASS

Benchmark command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark architecture results:

    binary_style_forced_switch:
    match = 1.000
    C-P_min = -0.551000
    heat_peak = 0.051000
    switch_peak = 1.000000
    actual_direct = 2052
    prevented_direct = 0
    neutralized = 0

    direct_ternary_commit:
    match = 1.000
    C-P_min = -0.551000
    heat_peak = 0.051000
    switch_peak = 1.000000
    actual_direct = 2052
    prevented_direct = 0
    neutralized = 0

    distributed_neutral_ternary:
    match = 1.000
    C-P_min = 0.174750
    heat_peak = 0.003250
    switch_peak = 0.250000
    actual_direct = 0
    prevented_direct = 0
    neutralized = 2052

    frp_distributed_resonant:
    match = 1.000
    C-P_min = 0.144750
    heat_peak = 0.107000
    switch_peak = 0.250000
    actual_direct = 0
    prevented = 3820
    neutralized = 2392

### Benchmark-Supported Technical Position

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

### Role of This Release

FRP v0.9.3 established the executable software reference model and public documentation basis for the Fractal Resonance Processor architecture.

It provided the first release-facing validation layer for:

- ternary resonant coherence processing
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase dynamics
- benchmark comparison
- reproducibility
- CI verification
- hardware-facing documentation pathway

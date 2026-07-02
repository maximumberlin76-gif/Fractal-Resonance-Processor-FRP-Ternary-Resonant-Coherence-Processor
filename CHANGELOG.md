# Changelog — Fractal Resonance Processor (FRP)

All notable changes to the Fractal Resonance Processor (FRP) project are documented in this file.

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

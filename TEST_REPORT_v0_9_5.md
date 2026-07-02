# FRP v0.9.5 Test Report

## Fractal Resonance Processor

## M3 — Benchmark Export and Hardware Signal Mapping

Main prototype:

`frp_prototype_v0_9_5.py`

Milestone:

`M3 — Benchmark Export and Hardware Signal Mapping`

Structured-output schema:

`frp.structured_output.v0.9.5`

M3 export schemas:

`frp.m3.benchmark_matrix.v0.9.5`

`frp.m3.hardware_signal_map.v0.9.5`

`frp.m3.fpga_register_map_draft.v0.9.5`

`frp.m3.testbench_vector.v0.9.5`

## Test Objective

This test report documents the validation status of FRP v0.9.5.

The objective of the M3 validation layer is to confirm that the executable software reference prototype supports:

- structured demo execution;

- structured self-test execution;

- structured benchmark execution;

- benchmark matrix export;

- hardware-facing signal map export;

- FPGA register map draft export;

- testbench vector export;

- schema marker validation;

- candidate invariant validation;

- documentation schema marker validation;

- GitHub Actions continuous integration validation.

## Validated Files

The M3 validation workflow covers the following files:

`frp_prototype_v0_9_5.py`

`docs/benchmark_matrix.md`

`docs/hardware_signal_mapping.md`

`docs/fpga_register_map_draft.md`

`docs/testbench_comparison_plan.md`

`docs/m3_validation_targets.md`

`.github/workflows/frp-m3-benchmark-signal-map.yml`

## GitHub Actions Workflow

Workflow name:

`FRP M3 Benchmark and Signal Map`

Workflow file:

`.github/workflows/frp-m3-benchmark-signal-map.yml`

Observed status:

`PASS`

## Additional Workflows Observed

The repository also reported successful status for:

- `FRP Self Test`;

- `FRP Benchmark Smoke Test`;

- `FRP Structured Output`;

- `FRP M3 Benchmark and Signal Map`.

Observed status:

`PASS`

## Python Syntax Validation

Validation command:

`python -m py_compile frp_prototype_v0_9_5.py`

Expected result:

`PASS`

Observed result:

`PASS`

## Text Self-Test Validation

Validation command:

`python frp_prototype_v0_9_5.py --mode self-test --output text`

Expected result:

`PASS`

Observed result:

`PASS`

## Structured JSON Demo Validation

Validation command:

`python frp_prototype_v0_9_5.py --mode demo --output json --include-telemetry`

Required schema:

`frp.structured_output.v0.9.5`

Required kind:

`demo`

Required validation target:

`ticks_recorded = steps`

Observed result:

`PASS`

## Structured JSON Self-Test Validation

Validation command:

`python frp_prototype_v0_9_5.py --mode self-test --output json`

Required schema:

`frp.structured_output.v0.9.5`

Required kind:

`self_test`

Required status:

`PASS`

Required check status:

`all checks pass`

Observed result:

`PASS`

## Structured JSON Benchmark Validation

Validation command:

`python frp_prototype_v0_9_5.py --mode benchmark --output json`

Required schema:

`frp.structured_output.v0.9.5`

Required kind:

`benchmark`

Required architecture profile count:

`4`

Architecture profiles:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

Observed result:

`PASS`

## Benchmark Matrix Export Validation

Validation command:

`python frp_prototype_v0_9_5.py --export-benchmark-matrix`

Required schema:

`frp.m3.benchmark_matrix.v0.9.5`

Required kind:

`benchmark_matrix`

Required fields:

- `schema`;

- `kind`;

- `version`;

- `milestone`;

- `purpose`;

- `columns`;

- `rows`;

- `candidate_invariants`.

Required architecture row count:

`4`

Observed result:

`PASS`

## Hardware Signal Map Export Validation

Validation command:

`python frp_prototype_v0_9_5.py --export-signal-map`

Required schema:

`frp.m3.hardware_signal_map.v0.9.5`

Required kind:

`hardware_signal_map`

Required fields:

- `schema`;

- `kind`;

- `version`;

- `milestone`;

- `purpose`;

- `signals`;

- `mapping_notes`.

Required signal names include:

`cell_state[i]`

`phase[i]`

`scheduler_mode`

`transition_fraction`

`gamma`

`actual_direct_events`

`prevented_direct_events`

`switch_load`

`heat`

`C_minus_P`

`phase_order_R`

Observed result:

`PASS`

## FPGA Register Map Draft Export Validation

Validation command:

`python frp_prototype_v0_9_5.py --export-register-map`

Required schema:

`frp.m3.fpga_register_map_draft.v0.9.5`

Required kind:

`fpga_register_map_draft`

Required data width:

`32`

Required register names include:

`FRP_VERSION`

`CONTROL`

`SCHEDULER_MODE`

`TRANSITION_FRACTION_Q16`

`GAMMA_Q16`

`CELL_COUNT`

`STEP_COUNT`

`STATUS`

`ACTUAL_DIRECT_EVENTS`

`PREVENTED_DIRECT_EVENTS`

`NEUTRALIZED_CONFLICTS`

`SWITCH_LOAD_PEAK_Q16`

`HEAT_PEAK_Q16`

`C_MINUS_P_MIN_Q16`

`PHASE_ORDER_R_Q16`

`TELEMETRY_READ_INDEX`

Observed result:

`PASS`

## Testbench Vector Export Validation

Validation command:

`python frp_prototype_v0_9_5.py --export-testbench-vector`

Required schema:

`frp.m3.testbench_vector.v0.9.5`

Required kind:

`testbench_vector`

Required fields:

- `schema`;

- `kind`;

- `version`;

- `milestone`;

- `purpose`;

- `input_config`;

- `expected_invariants`;

- `summary`;

- `scheduler_counts`;

- `sample_ticks`.

Observed result:

`PASS`

## Candidate Invariant Validation

The M3 validation workflow checks the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

Observed result:

`PASS`

## Transition Safety Validation

Direct polarity jumps are defined as:

`-1 ↔ 1`

Neutral-routed transition paths are:

`-1 → 0 → 1`

`1 → 0 → -1`

For the primary FRP distributed resonant profile, the required transition safety target is:

`actual_direct_events = 0`

Observed result:

`PASS`

## Distributed Commit Validation

Current default transition fraction:

`transition_fraction = 0.25`

Required target:

`switch_load_peak <= transition_fraction`

Observed result:

`PASS`

## Operational Stability Validation

FRP tracks operational stability through:

`C(t) > P(t)`

In the current software reference model:

`P(t) = heat + switch_load`

The exported stability margin is:

`C_minus_P = C(t) - P(t)`

Required target:

`C_minus_P_min > 0`

Observed result:

`PASS`

## Resonant Phase Validation

The resonant phase layer is based on Kuramoto-Sakaguchi phase coupling.

Current default phase shift:

`gamma = 0.30 pi`

Required phase-order field:

`phase_order_R`

Required range:

`0 <= phase_order_R <= 1`

Observed result:

`PASS`

## Documentation Validation

The workflow validates the presence of the following documentation files:

`docs/benchmark_matrix.md`

`docs/hardware_signal_mapping.md`

`docs/fpga_register_map_draft.md`

`docs/testbench_comparison_plan.md`

`docs/m3_validation_targets.md`

The workflow also checks M3 schema markers inside the documentation files.

Observed result:

`PASS`

## Benchmark-Supported Technical Position

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

## M3 Technical Position

`FRP v0.9.5 extends the structured-output layer into benchmark export and hardware-facing signal mapping. The release defines machine-readable benchmark matrices, signal-map fields, register-map draft structures, and testbench comparison vectors for future FPGA, ASIC, and external architecture comparison workflows.`

## Final Test Status

Final observed status:

`PASS`

FRP v0.9.5 M3 validation is complete for the current software reference prototype, documentation set, structured export layer, and GitHub Actions workflow.

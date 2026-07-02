# FRP M3 Validation Targets

## Fractal Resonance Processor v0.9.5

Milestone: M3 — Benchmark Export and Hardware Signal Mapping

Prototype:

`frp_prototype_v0_9_5.py`

## Purpose

This document defines the validation targets for FRP v0.9.5.

FRP v0.9.5 extends the v0.9.4 structured-output layer into M3 benchmark export and hardware-facing signal mapping.

The validation targets define what must remain true across the executable prototype, benchmark matrix export, hardware signal map, FPGA register map draft, and testbench vector export.

## M3 Validation Scope

The M3 validation scope covers:

- Python syntax validity;

- executable demo mode;

- executable self-test mode;

- executable benchmark mode;

- structured JSON output;

- benchmark matrix export;

- hardware signal map export;

- FPGA register map draft export;

- testbench vector export;

- schema markers;

- candidate invariant markers;

- transition safety fields;

- stability fields;

- scheduler accounting fields;

- hardware-facing mapping fields.

## Prototype File

Main prototype file:

`frp_prototype_v0_9_5.py`

The prototype must remain dependency-free and executable with Python standard library only.

## Structured Output Schema

Current structured-output schema marker:

`frp.structured_output.v0.9.5`

The schema marker must appear in JSON output for:

- demo;

- self-test;

- benchmark.

## M3 Export Schemas

The M3 export schemas are:

`frp.m3.benchmark_matrix.v0.9.5`

`frp.m3.hardware_signal_map.v0.9.5`

`frp.m3.fpga_register_map_draft.v0.9.5`

`frp.m3.testbench_vector.v0.9.5`

Each M3 export mode must produce valid JSON.

## Required CLI Modes

The prototype must support the following execution modes:

`--mode demo`

`--mode self-test`

`--mode benchmark`

The prototype must support the following output modes:

`--output text`

`--output json`

The prototype must support optional telemetry export:

`--include-telemetry`

## Required M3 Export Flags

The prototype must support the following M3 export flags:

`--export-benchmark-matrix`

`--export-signal-map`

`--export-register-map`

`--export-testbench-vector`

Only one M3 export flag should be used at a time.

## Architecture Profiles

The benchmark layer must preserve the following architecture profiles:

`binary_style_forced_switch`

`direct_ternary_commit`

`distributed_neutral_ternary`

`frp_distributed_resonant`

The FRP distributed resonant profile is the primary M3 reference profile.

## Scheduler Modes

The prototype must preserve the following scheduler modes:

`free`

`7/1`

`1/7`

Scheduler counts must remain visible in structured output.

Candidate scheduler invariant:

`scheduler counts match selected cycle mode`

## Balanced Ternary State Set

The processor state set must remain:

`{-1, 0, 1}`

The neutral state `0` must remain active.

It must not be treated as an empty or passive null state.

The neutral state acts as:

- transition buffer;

- conflict neutralizer;

- damping state;

- switching-load regulator;

- phase-stabilizing bridge;

- balancing state.

## Neutral Transition Routing Target

Direct polarity jumps are defined as:

`-1 ↔ 1`

Neutral-routed transition paths are:

`-1 → 0 → 1`

`1 → 0 → -1`

The validation target is not only the final ternary vector.

The transition path is part of the validation target.

## Candidate Invariants

The M3 candidate invariant markers are:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Transition Safety Validation

The transition safety fields must remain present in structured output and M3 exports:

`actual_direct_events`

`prevented_direct_events`

`neutralized_conflicts`

For the FRP distributed resonant profile, the required target is:

`actual_direct_events = 0`

This confirms that direct `-1 ↔ 1` jumps are not occurring in the tested operational domain.

## Distributed Commit Validation

The current default transition fraction is:

`transition_fraction = 0.25`

The distributed commit validation target is:

`switch_load_peak <= transition_fraction`

This confirms that the processor preserves bounded commit behavior.

## Operational Stability Validation

FRP tracks operational stability through:

`C(t) > P(t)`

In the current software reference model:

`P(t) = heat + switch_load`

The exported stability margin is:

`C_minus_P = C(t) - P(t)`

The validation target is:

`C_minus_P_min > 0`

## Resonant Phase Validation

The FRP resonant layer uses Kuramoto-Sakaguchi phase coupling.

Current default phase shift:

`gamma = 0.30 pi`

The phase-order telemetry field is:

`phase_order_R`

Expected range:

`0 <= phase_order_R <= 1`

This field must remain available for resonant coherence comparison.

## Telemetry Completeness Validation

The telemetry completeness target is:

`ticks_recorded = steps`

When telemetry is included, the telemetry list must contain per-tick records with the following fields:

- `tick`;

- `scheduler_mode`;

- `scheduler_phase`;

- `changed_cells`;

- `active_count`;

- `positive_count`;

- `negative_count`;

- `neutral_count`;

- `actual_direct_events`;

- `prevented_direct_events`;

- `neutralized_conflicts`;

- `switch_load`;

- `heat`;

- `C`;

- `P`;

- `C_minus_P`;

- `phase_order_R`.

## Benchmark Matrix Validation

The benchmark matrix export must contain:

`schema`

`kind`

`version`

`milestone`

`purpose`

`columns`

`rows`

`candidate_invariants`

The benchmark matrix schema must be:

`frp.m3.benchmark_matrix.v0.9.5`

The output kind must be:

`benchmark_matrix`

## Hardware Signal Map Validation

The hardware signal map export must contain:

`schema`

`kind`

`version`

`milestone`

`purpose`

`signals`

`mapping_notes`

The hardware signal map schema must be:

`frp.m3.hardware_signal_map.v0.9.5`

The output kind must be:

`hardware_signal_map`

The signal map must include fields for:

- ternary cell state;

- resonant phase;

- scheduler mode;

- transition fraction;

- gamma;

- transition safety counters;

- switch load;

- heat;

- `C_minus_P`;

- `phase_order_R`.

## FPGA Register Map Draft Validation

The FPGA register map draft export must contain:

`schema`

`kind`

`version`

`milestone`

`purpose`

`data_width`

`endianness`

`registers`

`status`

`non_goals`

The FPGA register map draft schema must be:

`frp.m3.fpga_register_map_draft.v0.9.5`

The output kind must be:

`fpga_register_map_draft`

The register map must include:

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

## Testbench Vector Validation

The testbench vector export must contain:

`schema`

`kind`

`version`

`milestone`

`purpose`

`input_config`

`expected_invariants`

`summary`

`scheduler_counts`

`sample_ticks`

The testbench vector schema must be:

`frp.m3.testbench_vector.v0.9.5`

The output kind must be:

`testbench_vector`

## Expected Validation Result

The expected validation status for the primary FRP distributed resonant profile is:

`PASS`

The expected self-test status is:

`PASS`

## M3 Validation Role

The M3 validation targets connect:

- executable software reference model;

- structured JSON output;

- benchmark matrix export;

- hardware-facing signal map;

- FPGA register map draft;

- testbench vector export;

- CI validation;

- future release notes and Zenodo packaging.

These targets define the minimum validation surface for FRP v0.9.5.

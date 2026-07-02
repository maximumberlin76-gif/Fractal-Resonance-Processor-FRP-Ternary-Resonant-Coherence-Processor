# FRP v0.9.5 Release Notes

## Fractal Resonance Processor

## M3 — Benchmark Export and Hardware Signal Mapping

FRP v0.9.5 establishes the M3 Benchmark Export and Hardware Signal Mapping layer of the Fractal Resonance Processor software reference model.

This release extends the v0.9.4 structured-output layer into machine-readable benchmark export, hardware-facing signal mapping, FPGA register-map drafting, and testbench comparison preparation.

The main prototype file for this release is:

`frp_prototype_v0_9_5.py`

## Release Role

FRP v0.9.5 moves the project from structured JSON output toward hardware-facing validation surfaces.

The release defines four M3 export layers:

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

These layers provide a structured bridge between the executable Python reference prototype, benchmark comparison, signal-level interpretation, register-map drafting, and future FPGA or ASIC testbench comparison workflows.

## Main Additions

### M3 Prototype

Added:

`frp_prototype_v0_9_5.py`

The prototype extends v0.9.4 with:

- benchmark matrix export;

- hardware-facing signal map export;

- FPGA register map draft export;

- testbench vector export;

- structured schema markers for all M3 export layers;

- validation-compatible JSON outputs;

- scheduler accounting;

- transition safety counters;

- stability margin tracking;

- resonant phase-order telemetry;

- hardware-facing field definitions.

## New M3 Export Commands

### Benchmark Matrix Export

`python frp_prototype_v0_9_5.py --export-benchmark-matrix`

Schema:

`frp.m3.benchmark_matrix.v0.9.5`

Output kind:

`benchmark_matrix`

### Hardware Signal Map Export

`python frp_prototype_v0_9_5.py --export-signal-map`

Schema:

`frp.m3.hardware_signal_map.v0.9.5`

Output kind:

`hardware_signal_map`

### FPGA Register Map Draft Export

`python frp_prototype_v0_9_5.py --export-register-map`

Schema:

`frp.m3.fpga_register_map_draft.v0.9.5`

Output kind:

`fpga_register_map_draft`

### Testbench Vector Export

`python frp_prototype_v0_9_5.py --export-testbench-vector`

Schema:

`frp.m3.testbench_vector.v0.9.5`

Output kind:

`testbench_vector`

## Preserved Structured Output Layer

FRP v0.9.5 preserves the structured-output execution modes introduced in v0.9.4.

Supported execution modes:

`--mode demo`

`--mode self-test`

`--mode benchmark`

Supported output modes:

`--output text`

`--output json`

Optional telemetry export:

`--include-telemetry`

Current structured-output schema:

`frp.structured_output.v0.9.5`

## Architecture Profiles

The benchmark layer preserves the four architecture profiles:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

The primary M3 reference profile is:

`frp_distributed_resonant`

## Core FRP Logic Preserved

FRP remains based on the balanced ternary state set:

`{-1, 0, 1}`

The neutral state `0` remains active.

It acts as:

- transition buffer;

- conflict neutralizer;

- damping state;

- switching-load regulator;

- phase-stabilizing bridge;

- balancing state.

Direct polarity jumps are distinguished from neutral-routed transitions.

Direct polarity jump:

`-1 ↔ 1`

Neutral-routed transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

The transition path remains part of the validation target.

A final ternary output vector alone is not sufficient.

## Resonant Phase Layer

The FRP resonant layer remains based on Kuramoto-Sakaguchi phase coupling.

Current default phase shift:

`gamma = 0.30 pi`

The M3 prototype exports the phase-order telemetry field:

`phase_order_R`

Expected range:

`0 <= phase_order_R <= 1`

This field provides a compact marker for resonant coherence comparison.

## Distributed Commit Logic

The M3 prototype preserves distributed ternary commit behavior.

Current default transition fraction:

`transition_fraction = 0.25`

Candidate invariant marker:

`switch_load_peak <= transition_fraction`

## Operational Stability Tracking

FRP tracks operational stability through:

`C(t) > P(t)`

In the current software reference model:

`P(t) = heat + switch_load`

The exported stability margin is:

`C_minus_P = C(t) - P(t)`

Stable operation requires:

`C_minus_P > 0`

Candidate invariant marker:

`C_minus_P_min > 0`

## Candidate Invariants

FRP v0.9.5 tracks the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Documentation Added

Added M3 documentation files:

`docs/benchmark_matrix.md`

`docs/hardware_signal_mapping.md`

`docs/fpga_register_map_draft.md`

`docs/testbench_comparison_plan.md`

`docs/m3_validation_targets.md`

## CI Workflow Added

Added GitHub Actions workflow:

`.github/workflows/frp-m3-benchmark-signal-map.yml`

Workflow name:

`FRP M3 Benchmark and Signal Map`

The workflow validates:

- Python syntax compilation;

- text self-test execution;

- JSON demo output;

- JSON self-test output;

- JSON benchmark output;

- benchmark matrix export;

- hardware signal map export;

- FPGA register map draft export;

- testbench vector export;

- structured schema markers;

- candidate invariants;

- M3 documentation schema markers.

## Validation Status

Observed GitHub Actions status:

`PASS`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M3 Benchmark and Signal Map.

## Benchmark-Supported Technical Position

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

## M3 Technical Position

`FRP v0.9.5 extends the structured-output layer into benchmark export and hardware-facing signal mapping. The release defines machine-readable benchmark matrices, signal-map fields, register-map draft structures, and testbench comparison vectors for future FPGA, ASIC, and external architecture comparison workflows.`

## Release Summary

FRP v0.9.5 establishes the M3 layer required before expanded external benchmark comparison, hardware-facing interface discussion, FPGA register-level mapping, and future implementation-oriented testbench validation.

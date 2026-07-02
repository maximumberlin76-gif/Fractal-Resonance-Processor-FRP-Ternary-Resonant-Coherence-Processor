# FRP M3 Benchmark Matrix

## Fractal Resonance Processor v0.9.5

**Milestone:** M3 — Benchmark Export and Hardware Signal Mapping  
**Prototype:** `frp_prototype_v0_9_5.py`  
**Schema:** `frp.m3.benchmark_matrix.v0.9.5`

## Purpose

This document defines the benchmark matrix layer for FRP v0.9.5.

The M3 benchmark matrix extends the v0.9.4 structured-output layer into a machine-readable comparison surface for architecture profiles, transition safety, operational stability, switching load, heat/load proxy, and validation status.

The benchmark matrix is intended to support:

- architecture comparison;

- structured benchmark export;

- machine-readable validation;

- regression testing;

- hardware-facing signal analysis;

- future FPGA and ASIC testbench comparison workflows.

## Architecture Profiles

FRP v0.9.5 compares four architecture profiles:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

## Benchmark Matrix Export Command

The benchmark matrix can be exported with:

`python frp_prototype_v0_9_5.py --export-benchmark-matrix`

The export is JSON by default for the M3 export mode.

## Matrix Schema

Current schema marker:

`frp.m3.benchmark_matrix.v0.9.5`

Current output kind:

`benchmark_matrix`

## Matrix Columns

The benchmark matrix contains the following columns:

- `architecture`;

- `match`;

- `actual_direct_events`;

- `prevented_direct_events`;

- `neutralized_conflicts`;

- `switch_load_peak`;

- `heat_peak`;

- `C_minus_P_min`;

- `validation_status`.

## Column Definitions

### architecture

The architecture profile being tested.

Expected values:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

### match

Target-output match score.

Candidate invariant marker:

`match = 1.000`

### actual_direct_events

Number of actual direct polarity jumps between opposite active ternary states.

Direct polarity jump:

`-1 ↔ 1`

For distributed neutral and FRP resonant profiles, the expected value is:

`actual_direct_events = 0`

### prevented_direct_events

Number of direct polarity jumps prevented by routing through the neutral state.

Neutral-routed transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

### neutralized_conflicts

Number of polarity conflicts neutralized by the processor.

This field tracks the operational role of the neutral state `0` as an active transition, damping, balancing, and stabilization state.

### switch_load_peak

Peak switching load observed during the benchmark run.

Candidate invariant marker:

`switch_load_peak <= transition_fraction`

Current default transition fraction:

`transition_fraction = 0.25`

### heat_peak

Peak heat/load proxy observed during the benchmark run.

In the current software reference model, heat is part of destabilizing load.

### C_minus_P_min

Minimum observed operational stability margin.

FRP tracks:

`C_minus_P = C(t) - P(t)`

Stable operation requires:

`C_minus_P > 0`

### validation_status

Validation status for the architecture profile.

Expected value for validated runs:

`PASS`

## Candidate Invariants

The benchmark matrix tracks the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Benchmark-Supported Technical Position

The benchmark-supported technical position of FRP v0.9.5 is:

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

## M3 Role

The benchmark matrix is the first M3 export layer.

It connects the executable FRP prototype to:

- benchmark comparison;

- structured validation;

- signal mapping;

- register-map drafting;

- testbench vector generation;

- hardware-facing workflow preparation.

## Expected M3 Export Layers

FRP v0.9.5 defines four M3 export layers:

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

This document covers the benchmark matrix layer.

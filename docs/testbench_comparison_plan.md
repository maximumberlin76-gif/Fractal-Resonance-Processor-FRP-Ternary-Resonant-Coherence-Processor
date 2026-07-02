# FRP M3 Testbench Comparison Plan

## Fractal Resonance Processor v0.9.5

Milestone: M3 — Benchmark Export and Hardware Signal Mapping

Prototype:

`frp_prototype_v0_9_5.py`

Schema:

`frp.m3.testbench_vector.v0.9.5`

## Purpose

This document defines the testbench comparison plan for FRP v0.9.5.

The M3 testbench comparison layer connects the executable FRP software reference model to structured benchmark export, hardware-facing signal mapping, register-map drafting, and future FPGA or ASIC comparison workflows.

The goal is to define a stable comparison surface where FRP telemetry, candidate invariants, architecture profiles, and exported vectors can be checked against future implementations.

## M3 Export Command

The reference testbench vector can be exported with:

`python frp_prototype_v0_9_5.py --export-testbench-vector`

The export is JSON by default for this M3 export mode.

## Testbench Vector Schema

Current schema marker:

`frp.m3.testbench_vector.v0.9.5`

Current output kind:

`testbench_vector`

## Testbench Comparison Scope

The M3 testbench comparison plan covers:

- input configuration;

- architecture profile;

- scheduler mode;

- transition fraction;

- Sakaguchi phase shift;

- balanced ternary state transitions;

- neutral transition routing;

- direct transition safety counters;

- switching load telemetry;

- heat/load proxy telemetry;

- operational stability margin;

- resonant phase-order telemetry;

- scheduler accounting;

- sample per-tick telemetry;

- candidate invariant verification.

## Reference Architecture Profile

The primary reference profile for M3 testbench comparison is:

`frp_distributed_resonant`

This profile combines:

- balanced ternary state logic;

- active neutral transition routing;

- distributed commit behavior;

- Kuramoto-Sakaguchi resonant phase coupling;

- scheduler-controlled transition behavior;

- nonlinear operational load tracking;

- telemetry export;

- operational stability monitoring.

## Reference Configuration

Default M3 reference configuration:

`architecture = frp_distributed_resonant`

`cells = 32`

`steps = 64`

`seed = 76`

`scheduler = free`

`transition_fraction = 0.25`

`gamma = 0.30 pi`

## Input Configuration Fields

The testbench vector exports the following input configuration fields:

- `architecture`;

- `cells`;

- `steps`;

- `seed`;

- `scheduler`;

- `transition_fraction`;

- `gamma`.

These fields define the simulation boundary for a comparable reference run.

## Expected Invariants

The M3 testbench vector exposes the following expected invariants:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Transition Safety Target

FRP distinguishes direct polarity jumps from neutral-routed transitions.

Direct polarity jump:

`-1 ↔ 1`

Neutral-routed transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

The testbench comparison must preserve this distinction.

A final output vector alone is not sufficient.

The transition path is part of the validation target.

## Stability Target

FRP tracks operational stability through:

`C(t) > P(t)`

In the current software reference model:

`P(t) = heat + switch_load`

The exported stability margin is:

`C_minus_P = C(t) - P(t)`

Stable operation requires:

`C_minus_P > 0`

The testbench comparison must check the exported minimum stability margin:

`C_minus_P_min > 0`

## Switching Load Target

FRP uses distributed commit behavior.

The current default transition fraction is:

`transition_fraction = 0.25`

The testbench comparison must check:

`switch_load_peak <= transition_fraction`

This confirms that the distributed commit limit remains visible in exported telemetry.

## Resonant Phase Target

The FRP resonant layer uses Kuramoto-Sakaguchi phase coupling.

Current default phase shift:

`gamma = 0.30 pi`

The testbench comparison uses the exported phase-order marker:

`phase_order_R`

Expected range:

`0 <= phase_order_R <= 1`

The phase-order field provides a compact comparison marker for resonant coherence behavior.

## Scheduler Accounting Target

FRP v0.9.5 supports three scheduler modes:

`free`

`7/1`

`1/7`

The testbench comparison must verify that scheduler counts match the selected cycle mode and the configured number of steps.

General invariant:

`ticks_recorded = steps`

Scheduler accounting invariant:

`scheduler counts match selected cycle mode`

## Sample Tick Fields

The M3 testbench vector exports sample per-tick telemetry.

Sample tick fields include:

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

These fields provide the minimum comparison surface for future testbench validation.

## Comparison Procedure

A future testbench should follow this procedure:

1. Load the exported M3 testbench vector.

2. Apply the same input configuration.

3. Run the implementation for the configured number of ticks.

4. Export matching summary and telemetry fields.

5. Compare transition-safety counters.

6. Compare switching-load limits.

7. Compare stability-margin signs.

8. Compare scheduler accounting.

9. Compare resonant phase-order range.

10. Confirm candidate invariant status.

## Architecture Comparison Procedure

The benchmark matrix should be used together with the testbench vector.

Reference architecture profiles:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

The testbench vector focuses on the FRP distributed resonant profile.

The benchmark matrix provides broader architecture comparison.

Together they define the M3 comparison surface.

## Hardware-Facing Role

The testbench comparison plan connects:

- executable software reference model;

- structured JSON export;

- benchmark matrix;

- hardware signal map;

- FPGA register map draft;

- future external implementation comparison.

This layer prepares FRP for structured validation beyond the Python reference prototype.

## M3 Export Layers

FRP v0.9.5 defines four M3 export layers:

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

This document covers the testbench comparison layer.

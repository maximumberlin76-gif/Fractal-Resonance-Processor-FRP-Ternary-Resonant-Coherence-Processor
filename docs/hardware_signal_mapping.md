# FRP M3 Hardware Signal Mapping

## Fractal Resonance Processor v0.9.5

Milestone: M3 — Benchmark Export and Hardware Signal Mapping

Prototype:

`frp_prototype_v0_9_5.py`

Schema:

`frp.m3.hardware_signal_map.v0.9.5`

## Purpose

This document defines the hardware-facing signal mapping layer for FRP v0.9.5.

The M3 signal map translates the executable FRP software reference model into a structured signal interface for future FPGA, ASIC, external testbench, and hardware-facing comparison workflows.

The signal map is not a final HDL implementation.

It is a draft interface layer that identifies which FRP states, control parameters, telemetry counters, stability markers, and resonant coherence variables should be exposed for future hardware translation.

## M3 Export Command

The hardware signal map can be exported with:

`python frp_prototype_v0_9_5.py --export-signal-map`

The export is JSON by default for this M3 export mode.

## Signal Map Schema

Current schema marker:

`frp.m3.hardware_signal_map.v0.9.5`

Current output kind:

`hardware_signal_map`

## Core Signal Domains

FRP v0.9.5 exposes the following signal domains:

- ternary state domain;

- resonant phase domain;

- scheduler control domain;

- distributed commit control domain;

- transition safety domain;

- operational load domain;

- operational stability domain;

- resonant coherence domain;

- telemetry output domain;

- hardware interface draft domain.

## Balanced Ternary State Signals

### cell_state[i]

Signal:

`cell_state[i]`

Domain:

`ternary_state`

Type:

`signed integer`

Range:

`{-1, 0, 1}`

Direction:

`internal_state`

Hardware role:

`ternary cell state register`

Description:

`cell_state[i]` represents the balanced ternary state of processor cell `i`.

The state values are:

`-1`

`0`

`1`

The neutral state `0` is active. It is not treated as an empty or passive null value.

In FRP, `0` acts as a transition buffer, conflict neutralizer, damping state, switching-load regulator, and phase-stabilizing bridge between opposite active polarity states.

## Neutral Transition Routing Signals

Direct polarity switching is not treated as the desired transition path in the FRP reference model.

Direct polarity jump:

`-1 ↔ 1`

Neutral-routed transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

The signal map therefore exposes transition-safety counters as explicit telemetry outputs.

### actual_direct_events

Signal:

`actual_direct_events`

Domain:

`transition_safety`

Type:

`unsigned counter`

Range:

`>= 0`

Direction:

`telemetry_output`

Hardware role:

`direct polarity jump safety counter`

Description:

Counts actual direct polarity jumps between `-1` and `1`.

Candidate invariant for FRP distributed resonant operation:

`actual_direct_events = 0`

### prevented_direct_events

Signal:

`prevented_direct_events`

Domain:

`transition_safety`

Type:

`unsigned counter`

Range:

`>= 0`

Direction:

`telemetry_output`

Hardware role:

`neutral-route prevention counter`

Description:

Counts polarity conflicts that were prevented from becoming direct `-1 ↔ 1` jumps and were routed through the neutral state.

### neutralized_conflicts

Signal:

`neutralized_conflicts`

Domain:

`transition_safety`

Type:

`unsigned counter`

Range:

`>= 0`

Direction:

`telemetry_output`

Hardware role:

`neutral conflict counter`

Description:

Counts conflicts neutralized by the active neutral state `0`.

## Resonant Phase Signals

### phase[i]

Signal:

`phase[i]`

Domain:

`resonant_phase`

Type:

`fixed or floating point`

Range:

`0 <= phase < 2*pi`

Direction:

`internal_state`

Hardware role:

`oscillator phase accumulator`

Description:

`phase[i]` represents the resonant phase of processor cell `i`.

The current FRP reference model uses a Kuramoto-Sakaguchi phase-coupling layer.

Each cell has an oscillator phase. The phase field evolves through coupled oscillator dynamics.

### gamma

Signal:

`gamma`

Domain:

`phase_coupling`

Type:

`fixed or floating point`

Range:

`0 <= gamma <= pi`

Direction:

`control_input`

Hardware role:

`Sakaguchi phase-shift parameter`

Description:

`gamma` is the Sakaguchi phase shift used in the resonant coupling layer.

Current default value:

`gamma = 0.30 pi`

This parameter introduces asymmetric phase coupling and separates FRP from a purely logical ternary transition model.

### phase_order_R

Signal:

`phase_order_R`

Domain:

`resonant_coherence`

Type:

`fixed point`

Range:

`0 <= R <= 1`

Direction:

`telemetry_output`

Hardware role:

`phase coherence estimator`

Description:

`phase_order_R` is a Kuramoto-style phase order parameter for the resonant layer.

It provides a compact telemetry marker for phase coherence in the processor field.

## Scheduler Control Signals

### scheduler_mode

Signal:

`scheduler_mode`

Domain:

`scheduler_control`

Type:

`enum`

Range:

`free | 7/1 | 1/7`

Direction:

`control_input`

Hardware role:

`cycle controller mode select`

Description:

`scheduler_mode` controls the scheduler cycle used by the processor.

Supported modes:

`free`

`7/1`

`1/7`

The `7/1` mode separates preparation from commitment.

The `1/7` mode separates excitation from recovery, damping, and stabilization.

## Distributed Commit Control Signals

### transition_fraction

Signal:

`transition_fraction`

Domain:

`commit_control`

Type:

`fixed point`

Range:

`0 < transition_fraction <= 1`

Direction:

`control_input`

Hardware role:

`distributed commit limiter`

Description:

`transition_fraction` defines the maximum fraction of cells allowed to commit a state transition during one tick.

Current default value:

`transition_fraction = 0.25`

Candidate invariant marker:

`switch_load_peak <= transition_fraction`

## Operational Load Signals

### switch_load

Signal:

`switch_load`

Domain:

`operational_load`

Type:

`fixed point`

Range:

`0 <= switch_load <= 1`

Direction:

`telemetry_output`

Hardware role:

`switching load estimator`

Description:

`switch_load` measures the per-tick fraction of cells changing state.

It is part of the destabilizing load term used in operational stability tracking.

### heat

Signal:

`heat`

Domain:

`operational_load`

Type:

`fixed point`

Range:

`>= 0`

Direction:

`telemetry_output`

Hardware role:

`thermal and load proxy`

Description:

`heat` is the current software reference-model heat/load proxy.

In the current model, destabilizing load is represented as:

`P(t) = heat + switch_load`

## Operational Stability Signals

### C_minus_P

Signal:

`C_minus_P`

Domain:

`operational_stability`

Type:

`signed fixed point`

Range:

`signed`

Direction:

`telemetry_output`

Hardware role:

`stability margin monitor`

Description:

`C_minus_P` tracks the operational stability margin:

`C_minus_P = C(t) - P(t)`

Stable operation requires:

`C_minus_P > 0`

Candidate invariant marker:

`C_minus_P_min > 0`

## Telemetry Completeness Signals

### ticks_recorded

Signal:

`ticks_recorded`

Domain:

`telemetry_output`

Type:

`unsigned counter`

Range:

`>= 0`

Direction:

`telemetry_output`

Hardware role:

`telemetry completeness counter`

Description:

`ticks_recorded` counts recorded processor ticks.

Candidate invariant marker:

`ticks_recorded = steps`

## Hardware Mapping Notes

The M3 signal map has the following interpretation:

- it identifies software reference-model fields that can be mapped into future hardware-facing signals;

- it separates control inputs from internal state and telemetry outputs;

- it preserves the active role of the neutral state `0`;

- it exposes direct transition safety as explicit counters;

- it exposes `C_minus_P` as the primary stability margin;

- it exposes `phase_order_R` as the resonant coherence marker;

- it prepares the next layer: FPGA register map drafting.

## Non-Goals

This document is not HDL.

This document is not a timing-closed FPGA implementation.

This document is not a final ASIC specification.

This document is not a silicon tapeout register specification.

This document defines the hardware-facing signal layer required before those stages.

## M3 Role

The hardware signal map is the second M3 export layer.

It connects:

- executable software reference model;

- structured JSON output;

- benchmark matrix export;

- signal-level hardware interpretation;

- FPGA register map draft;

- future external testbench comparison.

## Related M3 Export Layers

FRP v0.9.5 defines four M3 export layers:

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

This document covers the hardware signal mapping layer.

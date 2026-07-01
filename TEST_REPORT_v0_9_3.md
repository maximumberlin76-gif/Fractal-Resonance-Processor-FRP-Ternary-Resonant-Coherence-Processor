# FRP Prototype Test Report v0.9.3-mobile

## Project

FRP — Fractal Resonance Processor

Version: v0.9.3-mobile  
Status: candidate prototype  
Type: single-file Python simulation prototype  
Main file: frp_prototype_v0_9_3_mobile.py  
License: Apache-2.0

## Scope

This report documents the test status of the FRP v0.9.3-mobile candidate prototype.

The prototype implements a ternary resonant coherence processor simulation based on:

- balanced ternary states: -1, 0, 1
- neutral 0 transition logic
- forbidden direct -1 ↔ 1 transition
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- per-tick telemetry
- scheduler modes: free, 7/1, 1/7
- register file
- processor instruction layer
- self-test mode
- benchmark mode

This is a Python simulation prototype. It is not a hardware implementation.

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic. They are not representative operational workloads.

Default operational parameter:

    transition_fraction = 0.25

This parameter limits the maximum distributed state transition load per tick.

## Core Safety Invariants

The v0.9.3-mobile candidate is tested against the following invariants:

| Invariant | Required Condition |
|---|---|
| Target match | match = 1.000 |
| Direct transition safety | actual_direct_events = 0 |
| Stability margin | C_minus_P_min > 0 |
| Distributed transition load | switch_load_peak <= transition_fraction |
| Telemetry | ticks_recorded = steps |
| Scheduler | scheduler counts match selected cycle mode |

Per-tick telemetry is mandatory. Telemetry skipping is not allowed in the v0.9.3 candidate because it may hide transient instability.

## Default Parameters

| Parameter | Value |
|---|---:|
| dt | 5e-3 |
| k_global | 0.6 |
| sigma | 0.03 |
| gamma | 0.30π |
| state_tau | 0.33 |
| logic_tau | 0.20 |
| phase_kick | 0.15 |
| neutral_min_hold | 2 |
| max_hold | 120 |
| refractory | 20 |
| heat_limit | 1.50 |
| saturation_beta | 0.75 |
| compression_gain | 1.20 |
| delay_ticks | 3 |
| transition_fraction | 0.25 |
| telemetry_every | 1 |

## Test Commands

Run demo:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Run heavy self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Run benchmark:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

## Standard Self-Test

### Matrix

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..4 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| runs | 300 |
| steps | 128 |

### Result

| Metric | Value |
|---|---:|
| runs | 300 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 3820 |
| neutralized_conflicts | 2392 |
| failures | 0 |
| result | PASS |

### Interpretation

The prototype completed all tested operations with exact target match.

No actual direct -1 ↔ 1 transition occurred.

The minimum C-P remained positive.

The distributed transition cap held switch_load_peak at 0.25.

## Heavy Self-Test

### Matrix

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..9 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| runs | 600 |
| steps | 256 |

### Result

| Metric | Value |
|---|---:|
| runs | 600 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 7913 |
| neutralized_conflicts | 4921 |
| failures | 0 |
| result | PASS |

### Interpretation

The longer run preserved the same minimum stability margin.

No actual direct -1 ↔ 1 transition occurred.

The candidate remained stable under the tested seed expansion and doubled step count.

## Benchmark

### Matrix

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..4 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| steps | 128 |

### Compared Architectures

| Architecture | Description |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | Direct ternary state commit baseline |
| distributed_neutral_ternary | Distributed neutral ternary transition baseline |
| binary_style_forced_switch | Binary-style forced switching baseline |

### Result

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Benchmark Interpretation

The direct ternary and binary-style forced switching baselines reach the target result, but they allow actual direct -1 ↔ 1 transitions and reach switch_load_peak = 1.000000.

The distributed neutral ternary baseline prevents actual direct transitions and keeps switch_load_peak = 0.25. It is colder than FRP in this simulation because it does not include the Kuramoto-Sakaguchi resonant phase layer, nonlinear saturation, compression, delay dynamics, or resonant phase evolution.

The FRP distributed resonant mode preserves:

- match = 1.000
- actual_direct_events = 0
- C_minus_P_min > 0
- switch_load_peak = 0.25

## Correct Technical Claim

The current prototype supports the following claim:

> FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The following claim is not supported by the current benchmark:

> FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## Scheduler Validation

The scheduler is counted by internal tick.

Expected cycle behavior:

| Mode | Behavior |
|---|---|
| free | every tick = commit |
| 7/1 | ticks 0..6 = balance, tick 7 = commit |
| 1/7 | tick 0 = excite, ticks 1..7 = neutralize |

The v0.9.3 candidate validates scheduler counts directly against the number of internal steps.

## Corrections Introduced in v0.9.3

Version v0.9.3-mobile introduced the following corrections:

1. Fixed zero/mov syntax break.
2. Enforced telemetry_every = 1.
3. Restored strict per-tick telemetry.
4. Scheduler counts are computed by internal ticks.
5. Delay buffers advance once per tick, not inside each RK2 call.
6. actual_direct_events, prevented_direct_events, and neutralized_conflicts are separated.
7. Benchmark report distinguishes actual_direct, prevented_direct, and neutralized events.

## Candidate Decision

v0.9.3-mobile status:

    PASS as candidate prototype

This version is suitable for repository packaging as a working simulation prototype.

It is not a hardware claim.

## Limitations

1. This is a Python simulation prototype, not a hardware implementation.
2. Heat is a model variable, not a physical temperature measurement.
3. Switching load is a simulated transition-load metric, not measured electrical switching energy.
4. Kuramoto-Sakaguchi phase dynamics are simulated numerically.
5. Hardware-level thermal, electrical, timing, fabrication, and performance claims are not established.
6. Current claims are limited to the tested simulation domain.
7. The benchmark does not prove that FRP is always colder than all neutral transition baselines.

## Release Recommendation

Recommended repository version:

    v0.9.3-mobile-candidate

Recommended repository files:

- README.md
- LICENSE
- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md

## Final Technical Summary

FRP v0.9.3-mobile demonstrates a working single-file candidate prototype of a ternary resonant coherence processor simulation.

Within the tested operational domain N >= 8, the prototype:

- executes balanced ternary ALU operations
- preserves exact target match
- prevents actual direct -1 ↔ 1 transitions
- routes conflicting transitions through neutral 0
- keeps C-P positive in tested runs
- limits switch_load_peak according to transition_fraction
- validates scheduler behavior for free, 7/1, and 1/7 modes
- provides per-tick telemetry suitable for further verification

The current candidate is ready for repository packaging after source freeze and documentation alignment.

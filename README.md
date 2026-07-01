# Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Python Simulation Prototype**

Version: v0.9.3-mobile  
Status: candidate prototype  
Type: single-file Python simulation prototype  
License: Apache-2.0

## Overview

Fractal Resonance Processor (FRP) is a nonlinear dynamic computing architecture based on balanced ternary states, selective resonance, phase convergence, coherence retention, and dynamic stability in open dissipative systems.

FRP treats computation not as forced binary state enumeration, but as a dynamic process of resonance selection, ternary neutral balancing, phase convergence, coherence accumulation, distributed state transition, and stable mode retention.

The current repository contains a working Python simulation prototype. It is not a hardware implementation.

## Current Prototype

Main prototype file: `frp_prototype_v0_9_3_mobile.py`

Current test report: `TEST_REPORT_v0_9_3.md`

The prototype implements:

- balanced ternary states: `-1`, `0`, `1`
- neutral `0` as balancing, damping, and transition state
- forbidden direct `-1 ↔ 1` transition
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- per-tick telemetry
- scheduler modes: `free`, `7/1`, `1/7`
- register file
- processor instruction layer
- self-test mode
- benchmark mode

## Core Ternary Principle

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | neutral balancing state |
| `1` | positive / excitatory / phase-supporting / constructive potential |

The direct transition `-1 ↔ 1` is forbidden in the FRP operational model.

A conflicting transition must pass through the neutral state:

- `-1 → 0 → 1`
- `1 → 0 → -1`

The neutral state `0` is not treated as absence. It acts as:

- logical neutral
- phase damper
- transition buffer
- conflict neutralizer
- switching-load guard

## Dynamic Stability Principle

The core stability condition is:

`C(t) > P(t)`

where:

- `C(t)` = operational coherence
- `P(t)` = heat + switch_load

In the current prototype, stable execution requires:

`C_minus_P = C(t) - P(t) > 0`

The prototype tracks this condition per tick.

## Operational Domain

The tested operational domain is:

`N >= 8`

Smaller values such as `N = 2` or `N = 3` may be used only as micro-tests of ternary logic. They are not representative operational workloads.

Default operational parameter:

`transition_fraction = 0.25`

This limits the maximum distributed state transition load per tick.

## Scheduler Modes

FRP currently supports three scheduler modes:

| Mode | Tick Behavior |
|---|---|
| `free` | every tick = commit |
| `7/1` | ticks `0..6` = balance, tick `7` = commit |
| `1/7` | tick `0` = excite, ticks `1..7` = neutralize |

The scheduler is validated by internal tick counts.

## Per-Tick Telemetry

Per-tick telemetry is mandatory in the v0.9.3 candidate.

The prototype records:

- `tick`
- `phase`
- `R`
- `phi`
- `neutral`
- `positive`
- `negative`
- `heat`
- `thermal_scale`
- `switch_load`
- `actual_direct_events_delta`
- `prevented_direct_events_delta`
- `neutralized_conflicts_delta`
- `logical_match`
- `transition_debt`
- `direct_conflict_fraction`
- `C`
- `P`
- `C_minus_P`

Skipping telemetry ticks is not allowed in the release candidate because it may hide transient instability.

## Processor Layer

The current processor layer includes:

- register file
- instruction execution
- demo program
- self-test mode
- benchmark mode

Supported instructions:

- `load`
- `rand`
- `zero`
- `mov`
- `neg`
- `add`
- `sub`
- `compare`
- `consensus`
- `halt`

Balanced ternary ALU operations:

- `neg`
- `add`
- `sub`
- `compare`
- `consensus`

## Quick Start

Run demo:

`python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1`

Run standard self-test:

`python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5`

Run heavy self-test:

`python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10`

Run benchmark:

`python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5`

## Test Status

Current candidate result:

`v0.9.3-mobile: PASS as candidate prototype`

### Standard Self-Test

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..4 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| runs | 300 |
| steps | 128 |

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

### Heavy Self-Test

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..9 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| runs | 600 |
| steps | 256 |

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

## Benchmark Summary

Benchmark architectures:

- `frp_distributed_resonant`
- `direct_ternary_commit`
- `distributed_neutral_ternary`
- `binary_style_forced_switch`

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Benchmark Interpretation

The direct ternary and binary-style forced switching baselines reach the target result, but they allow actual direct `-1 ↔ 1` transitions and reach `switch_load_peak = 1.000000`.

The distributed neutral ternary baseline prevents actual direct transitions and keeps `switch_load_peak = 0.25`. It is colder than FRP in this simulation because it does not include the Kuramoto-Sakaguchi resonant phase layer, nonlinear saturation, compression, delay dynamics, or resonant phase evolution.

FRP distributed resonant mode preserves:

- `match = 1.000`
- `actual_direct_events = 0`
- `C_minus_P_min > 0`
- `switch_load_peak = 0.25`

## Correct Technical Claim

The current prototype supports the following claim:

> FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct `-1 ↔ 1` transitions in the tested operational domain.

The following claim is not supported by the current benchmark:

> FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## Historical Context

Balanced ternary computing has historical precedent in ternary digital computer research, including Setun.

FRP is not presented as the first ternary computer.

| System | Description |
|---|---|
| Setun | ternary digital computer |
| FRP | ternary resonant coherence processor simulation architecture |

FRP combines ternary logic with resonance-driven phase dynamics, distributed neutral transitions, per-tick operational coherence, and dynamic stability tracking.

## Repository Structure

Recommended structure:

- `README.md`
- `LICENSE`
- `frp_prototype_v0_9_3_mobile.py`
- `TEST_REPORT_v0_9_3.md`
- `docs/architecture.md`
- `docs/benchmark_interpretation.md`
- `docs/limitations.md`

## Limitations

1. This is a Python simulation prototype, not a hardware implementation.
2. Heat is a model variable, not a physical temperature measurement.
3. Switching load is a simulated transition-load metric, not measured electrical switching energy.
4. Kuramoto-Sakaguchi phase dynamics are simulated numerically.
5. Hardware-level thermal, electrical, timing, fabrication, and performance claims are not established.
6. Current claims are limited to the tested simulation domain.

## Current Development State

FRP v0.9.3-mobile is a working candidate prototype suitable for repository packaging.

The next engineering steps are:

1. freeze v0.9.3-mobile source
2. publish `TEST_REPORT_v0_9_3.md`
3. add architecture documentation
4. add benchmark interpretation
5. add limitations document
6. prepare next development branch after candidate freeze

## License

Apache-2.0

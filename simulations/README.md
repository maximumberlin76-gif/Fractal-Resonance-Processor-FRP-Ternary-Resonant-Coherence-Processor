# Simulation Layer

This directory contains simulation scenarios and numerical models related to the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## Simulation Scope

The simulation layer is used to explore and verify dynamic behavior related to:

- balanced ternary state transition
- neutral conflict routing
- forbidden direct -1 ↔ 1 transition
- distributed ternary commit
- Kuramoto-Sakaguchi phase dynamics
- nonlinear saturation
- compression
- delay-buffer behavior
- scheduler modes
- operational coherence
- stability margin C_minus_P
- benchmark comparison against baseline transition models

## Current Active Simulation

The active simulation prototype is:

    ../frp_prototype_v0_9_3_mobile.py

The active verified candidate is:

    v0.9.3-mobile

The current candidate includes three execution modes:

| Mode | Purpose |
|---|---|
| demo | run a processor demo program |
| test | run self-test verification |
| bench | run benchmark comparison |

## Simulation Commands

Run demo:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run standard self-test:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Run heavy self-test:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Run benchmark:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

## Simulation Model

The current FRP simulation combines:

- balanced ternary logic
- target-oriented ALU operation generation
- resonant phase evolution
- neutral transition control
- distributed commit
- per-tick stability telemetry

The simulation does not model a physical chip.

It models the dynamic behavior of a ternary resonant coherence processor architecture.

## Balanced Ternary State Model

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The state 0 is an active transition state.

It is used for:

- conflict neutralization
- transition buffering
- phase damping
- refractory behavior
- switching-load control

## Direct Transition Rule

The FRP simulation forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The active candidate requires:

    actual_direct_events = 0

## Resonant Phase Dynamics

The simulation uses Kuramoto-Sakaguchi type phase dynamics.

Default phase lag:

    gamma = 0.30π

The phase lag represents asymmetric coupling, delay, dissipation, or nonlinear phase shift inside the simulation model.

The resonant phase layer does not replace ternary logic.

It provides dynamic phase evolution around ternary transition control.

## Operational Stability

The core stability condition is:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| C(t) | operational coherence |
| P(t) | destabilizing load |
| C_minus_P | C(t) - P(t) |

In the current simulation:

    P(t) = heat + switch_load

The required candidate condition is:

    C_minus_P_min > 0

## Per-Tick Telemetry

Per-tick telemetry is mandatory in v0.9.3-mobile.

The simulation records:

- tick
- scheduler phase
- Kuramoto order parameter R
- mean phase phi
- neutral fraction
- positive fraction
- negative fraction
- heat
- thermal_scale
- switch_load
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- logical_match
- transition_debt
- direct_conflict_fraction
- C
- P
- C_minus_P

Telemetry skipping is not allowed in the candidate version because it may hide transient instability.

## Benchmark Models

The benchmark compares the FRP simulation against baseline transition models:

| Architecture | Purpose |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

The current benchmark supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The current benchmark does not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

## Current Verified Results

Standard self-test:

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

Heavy self-test:

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

Benchmark FRP mode:

| Metric | Value |
|---|---:|
| match | 1.000 |
| C-P_min | 0.144750 |
| heat_peak | 0.107000 |
| switch_peak | 0.250000 |
| actual_direct | 0 |
| prevented_direct | 3820 |
| neutralized | 2392 |

## Legacy Simulation Files

This directory may contain older simulation files created before the current FRP v0.9.3-mobile candidate.

Older files may use the previous project name:

    FPR

The current project name is:

    FRP — Fractal Resonance Processor

Legacy simulation files should be reviewed before deletion or replacement.

Recommended handling:

| Legacy Condition | Action |
|---|---|
| still technically useful | update terminology and mark as legacy or background |
| partially outdated | rewrite or move to legacy |
| conflicting with v0.9.3-mobile | replace or remove |
| old Kuramoto-only experiment | keep only as preliminary background |

## Simulation Boundary

The simulation layer does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all transition baselines

All simulation claims are limited to the tested Python simulation domain.

## Current Status

The simulation layer should now be aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ../verification/README.md
- ../verification/coherence_metrics.md

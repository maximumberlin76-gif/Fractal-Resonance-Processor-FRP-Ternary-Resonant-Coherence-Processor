# Resonance-Based Computation

This document describes the computational interpretation used within the Fractal Resonance Processor (FRP) framework.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Computational Perspective

Within the FRP framework, computation is not treated as isolated symbolic state manipulation.

Computation is interpreted as a dynamic process of:

- balanced ternary transformation
- resonance selection
- phase evolution
- coherence accumulation
- neutral conflict routing
- distributed commit
- stable mode retention

The current prototype combines a balanced ternary logic layer with a resonant phase-evolution layer.

The ternary logic layer defines the target state.

The resonant phase layer controls the dynamic transition toward that target.

## 2. Balanced Ternary Computation

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The neutral state 0 is an active computational state.

It is used for:

- transition buffering
- conflict neutralization
- damping
- refractory behavior
- switching-load control

In FRP, the neutral state is not equivalent to absence or empty value.

## 3. Forbidden Direct Transition

The FRP operational model forbids direct transitions between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

This means that conflicting polarity transitions must pass through the neutral state.

The current prototype tracks:

- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

The required safety condition is:

    actual_direct_events = 0

## 4. Resonance Selection

FRP treats resonance not only as amplification.

It treats resonance as selective support of dynamically compatible transition modes.

Compatible phase structures support convergence toward the target state.

Incompatible or conflicting structures are routed toward neutralization, damping, or suppression.

In the current prototype, resonance selection is represented through:

- Kuramoto-Sakaguchi phase coupling
- phase lag gamma
- nonlinear saturation
- compression
- independent delay buffers
- distributed commit

## 5. Phase Evolution Layer

The phase layer does not replace ternary logic.

It provides a dynamic resonant environment around ternary transition control.

The current prototype uses Kuramoto-Sakaguchi type dynamics.

Default phase lag:

    gamma = 0.30π

The phase lag represents asymmetric coupling, delay, dissipation, or nonlinear phase shift.

This layer allows the system to evolve through phase dynamics instead of immediate forced switching.

## 6. Target-Oriented Computation

In the current implementation, an operation first generates a balanced ternary target state.

Supported ALU operations:

| Operation | Description |
|---|---|
| neg | ternary negation |
| add | balanced ternary addition |
| sub | balanced ternary subtraction |
| compare | ternary comparison |
| consensus | neutral conflict-resolving consensus |

After the target is generated, the FRP core performs dynamic transition toward that target using resonance, neutral routing, and distributed commit.

## 7. Coherent Computational State

A coherent computational state in FRP is not only a correct final vector.

It is a retained target state reached without violating transition safety and stability constraints.

The current prototype evaluates this through:

- logical_match
- transition_debt
- direct_conflict_fraction
- heat
- switch_load
- C_minus_P

The required final condition is:

    match = 1.000

The required stability condition is:

    C_minus_P_min > 0

## 8. Dynamic Stability

Stable resonance-based computation requires operational coherence to exceed destabilizing load.

The core stability condition is:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| C(t) | operational coherence |
| P(t) | destabilizing load |
| C_minus_P | C(t) - P(t) |

In the current prototype:

    P(t) = heat + switch_load

The prototype tracks C_minus_P per tick.

## 9. Distributed Commit

FRP does not force the whole state vector to switch at once by default.

The distributed commit layer limits the number of state changes per tick.

Default parameter:

    transition_fraction = 0.25

This means that no more than 25 percent of the state vector may change during one tick under default settings.

The purpose of distributed commit is to reduce abrupt global transitions and maintain operational stability.

## 10. Nonlinear Transition Channel

FRP applies nonlinear shaping before state transition.

The nonlinear channel includes:

- cubic saturation
- compression

Cubic saturation:

    x / (1 + beta * abs(x)^3)

Compression:

    tanh(gain * x)

Default parameters:

| Parameter | Value |
|---|---:|
| saturation_beta | 0.75 |
| compression_gain | 1.20 |

The purpose of this layer is to limit excessive transition amplitude while preserving dynamic response.

## 11. Delay Model

The current prototype uses independent delay buffers for:

- logic delay
- coupling delay

The buffers advance once per internal tick.

This is required because the phase integration uses RK2 and evaluates the phase derivative more than once per tick.

Delay buffers must not advance inside each derivative evaluation.

## 12. Scheduler Modes

FRP supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

The scheduler defines the temporal structure of state transition.

Scheduler counts are validated against internal tick count.

## 13. Per-Tick Telemetry

Per-tick telemetry is mandatory in v0.9.3-mobile.

The prototype records:

- tick
- scheduler phase
- Kuramoto order parameter R
- heat
- switch_load
- logical_match
- transition_debt
- direct_conflict_fraction
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- C
- P
- C_minus_P

Telemetry skipping is not allowed in the candidate version because it may hide transient instability.

## 14. Baseline Comparison

The current prototype includes comparison against three baseline transition models:

| Baseline | Purpose |
|---|---|
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

The benchmark shows that direct and binary-style forced switching baselines may reach the target state but allow direct -1 ↔ 1 transitions.

The distributed neutral ternary baseline prevents direct transitions and is colder in the current simulation because it does not include the resonant phase layer.

## 15. Supported Technical Claim

The current prototype supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The current prototype does not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## 16. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 17. Candidate Invariants

The v0.9.3-mobile candidate is tested against the following invariants:

| Invariant | Required Condition |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## 18. Simulation Boundary

The current FRP implementation is a Python simulation prototype.

It does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- universal superiority over all ternary transition baselines

All current claims are limited to the tested simulation domain.

## Current Status

FRP v0.9.3-mobile is a working candidate prototype.

This document is aligned with:

- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- docs/architecture.md
- docs/core_principles.md

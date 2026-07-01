# Core Principles

This document describes the foundational operating principles of the Fractal Resonance Processor (FRP) framework.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Balanced Ternary State Space

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The state 0 is not treated as absence.

It is an active operational state used for:

- neutral balancing
- transition buffering
- phase damping
- conflict neutralization
- refractory behavior
- switching-load control

## 2. Forbidden Direct Transition

In the FRP operational model, direct transition between -1 and 1 is forbidden.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

This principle is central to the current prototype.

The candidate tracks:

- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

The required safety condition is:

    actual_direct_events = 0

## 3. Selective Resonance

FRP treats resonance not only as amplification.

It treats resonance as selective support of dynamically compatible modes.

Compatible phase structures support coherence accumulation and stable transition.

Incompatible phase structures are routed toward neutralization, damping, or suppression.

In the current prototype, this principle is represented through:

- Kuramoto-Sakaguchi phase coupling
- phase lag gamma
- nonlinear saturation
- compression
- independent delay buffers
- distributed commit

## 4. Phase Evolution

FRP does not treat computation as static symbolic state enumeration.

Computation is interpreted as a dynamic phase-evolution process around a balanced ternary target state.

The phase layer does not replace ternary logic.

Instead, it provides a resonant dynamic layer around ternary transition control.

The current prototype uses Kuramoto-Sakaguchi type dynamics with phase lag:

    gamma = 0.30π

The phase lag represents asymmetric coupling, delay, dissipation, or nonlinear phase shift.

## 5. Coherence Accumulation

FRP treats coherence as an operational dynamic property.

In target execution mode, coherence is evaluated through:

- logical match
- transition debt
- direct conflict fraction
- heat fraction
- refractory fraction

The goal is not only to reach a target state, but to retain the target state under controlled transition load.

## 6. Dynamic Stability Principle

Stable operation requires coherence to exceed destabilizing load.

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

Stable execution requires:

    C_minus_P > 0

The prototype tracks this value per tick.

## 7. Dissipative Stability Balancing

FRP operates as a simulated open dissipative dynamic system.

The prototype includes a model of destabilizing load through:

- simulated heat
- switching load
- direct conflict fraction
- transition debt
- refractory state

The purpose of the stability layer is to detect whether a transition process remains inside a dynamically stable operational domain.

## 8. Distributed Commit

FRP does not allow the entire ternary state vector to switch at once by default.

Instead, it limits the number of state changes per tick.

Default parameter:

    transition_fraction = 0.25

This means that no more than 25 percent of the ternary state vector may change during one tick under default settings.

The purpose of distributed commit is to reduce abrupt global switching and maintain operational stability.

## 9. Nonlinear Transition Channel

Before ternary quantization and state transition, FRP applies nonlinear shaping.

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

The purpose of this channel is to limit excessive transition amplitude while preserving dynamic response.

## 10. Independent Delay Buffers

The current prototype uses independent delay buffers for:

- logic delay
- coupling delay

Delay buffers advance once per internal tick.

This is required because the phase integration uses RK2 and evaluates the phase derivative more than once per tick.

Delay buffers must not advance inside each derivative evaluation.

## 11. Scheduler Principle

FRP supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Scheduler counts are validated by internal tick count.

The scheduler is part of the operational stability model.

## 12. Per-Tick Telemetry

Per-tick telemetry is mandatory in the current candidate.

Telemetry records:

- C
- P
- C_minus_P
- heat
- switch_load
- logical_match
- transition_debt
- direct_conflict_fraction
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- scheduler phase
- Kuramoto order parameter R

Telemetry skipping is not allowed in v0.9.3-mobile because it may hide transient instability.

## 13. Resonance-Based Computation

Within the FRP framework, computation is treated as:

- balanced ternary transformation
- resonance selection
- phase evolution
- coherence accumulation
- neutral conflict routing
- distributed commit
- stable mode retention

This differs from conventional static state-processing models by emphasizing dynamic transition safety and operational coherence.

## 14. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 15. Current Candidate Invariants

The v0.9.3-mobile candidate is tested against the following invariants:

| Invariant | Required Condition |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## 16. Claim Boundary

The current FRP prototype supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The current prototype does not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## 17. Simulation Boundary

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

The core principles in this document are aligned with:

- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- docs/architecture.md

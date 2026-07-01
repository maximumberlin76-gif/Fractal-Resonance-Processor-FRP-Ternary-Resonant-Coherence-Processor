# Model Layer

This directory contains mathematical and dynamic interaction models used within the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## Model Scope

The model layer describes the conceptual and mathematical components used by the current FRP simulation prototype.

The current model scope includes:

- balanced ternary state model
- neutral transition model
- forbidden direct -1 ↔ 1 transition rule
- distributed commit model
- Kuramoto-Sakaguchi phase interaction model
- nonlinear saturation model
- compression model
- independent delay-buffer model
- operational coherence model
- C_minus_P stability model
- scheduler model
- benchmark baseline models

## Current Active Model

The active model is implemented in:

    ../frp_prototype_v0_9_3_mobile.py

The active candidate is:

    v0.9.3-mobile

Older model files may still use the previous project name:

    FPR

The current project name is:

    FRP — Fractal Resonance Processor

Legacy model files should be reviewed before deletion or replacement.

## 1. Balanced Ternary State Model

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The neutral state 0 is active.

It is used for:

- transition buffering
- conflict neutralization
- damping
- refractory behavior
- switching-load control

## 2. Forbidden Direct Transition Model

The FRP operational model forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The current prototype tracks:

- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

The required candidate condition is:

    actual_direct_events = 0

## 3. Kuramoto-Sakaguchi Phase Model

The current FRP prototype uses Kuramoto-Sakaguchi type phase dynamics.

The phase layer models coupled oscillator behavior with phase lag.

Default phase lag:

    gamma = 0.30π

The phase lag represents asymmetric coupling, delay, dissipation, or nonlinear phase shift inside the simulation model.

The phase layer does not replace ternary logic.

It provides a resonant phase-evolution layer around balanced ternary transition control.

## 4. Nonlinear Transition Model

Before state transition, the prototype applies nonlinear shaping.

The nonlinear transition model includes:

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

The purpose of this model is to limit excessive transition amplitude while preserving dynamic response.

## 5. Delay-Buffer Model

The current prototype uses independent delay buffers for:

- logic delay
- coupling delay

Delay buffers advance once per internal tick.

This is required because the phase integration uses RK2 and evaluates the phase derivative more than once per tick.

Delay buffers must not advance inside each derivative evaluation.

## 6. Distributed Commit Model

The distributed commit model limits how many nodes may change state during one tick.

Default parameter:

    transition_fraction = 0.25

This means that no more than 25 percent of the ternary state vector may change during one tick under default settings.

The purpose of distributed commit is to reduce abrupt global switching and maintain operational stability.

## 7. Operational Coherence Model

In target execution mode, FRP evaluates coherence using operational metrics rather than only global phase order.

The current model uses:

- logical match
- transition debt
- direct conflict fraction
- hot node fraction
- refractory fraction

Conceptual form:

    C = 1.0
    C -= 0.50 * direct_conflict_fraction
    C -= 0.20 * transition_debt
    C -= 0.10 * hot_fraction
    C -= 0.10 * refractory_fraction
    C = clamp(C, 0.0, 1.0)

This makes coherence target-sensitive.

A distributed ternary target may be operationally correct even if the global Kuramoto order parameter R is not maximal.

## 8. Stability Model

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

The required candidate condition is:

    C_minus_P_min > 0

This is a simulation-level operational stability criterion.

It is not a universal physical law.

## 9. Heat and Switching Load Model

The current prototype tracks simulated heat and switching load.

Switching load:

    switch_load = switched_nodes / total_nodes

Heat increases with:

- switching activity
- active non-zero states
- conflict pressure

Heat decreases through:

- neutral state cooling
- passive cooling

Important boundary:

    heat is not physical temperature

The heat metric is a simulation variable.

It is not measured electrical heat or measured chip temperature.

## 10. Scheduler Model

FRP supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Scheduler counts are validated by internal tick count.

The scheduler is part of the operational stability model.

## 11. Baseline Models

The current prototype includes baseline models for comparison.

| Baseline | Purpose |
|---|---|
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

These baselines are simulation comparison models.

They are not hardware implementations.

## 12. Current Benchmark Model Result

Current benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 13. Supported Model Claim

The current model supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The current model does not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## 14. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 15. Legacy Model Files

This directory may contain older model files created before the current FRP v0.9.3-mobile candidate.

Older files may describe:

- Kuramoto-type synchronization
- coherence accumulation
- resonance interaction logic
- dissipative stability balancing
- dynamic convergence behavior

These concepts may remain useful as background, but they must be aligned with the current prototype before being treated as active model documentation.

Recommended handling:

| Legacy Condition | Action |
|---|---|
| still technically useful | update terminology and mark as legacy/background |
| partially outdated | rewrite or move to legacy |
| conflicting with v0.9.3-mobile | replace or remove |
| old Kuramoto-only model | keep only as preliminary background |

## 16. Simulation Boundary

The model layer describes simulation models.

It does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all transition models

All model claims are limited to the tested Python simulation domain.

## Current Status

The model layer should remain aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ../verification/README.md
- ../verification/coherence_metrics.md
- ../simulations/README.md

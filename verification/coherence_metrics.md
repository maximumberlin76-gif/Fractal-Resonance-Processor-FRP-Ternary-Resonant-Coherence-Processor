# Coherence Metrics

This document defines the coherence and stability metrics used in the Fractal Resonance Processor (FRP) v0.9.3-mobile candidate prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Purpose

The purpose of the coherence metrics layer is to verify whether a ternary resonant computation remains inside the tested operational stability domain.

The metrics are used to track:

- target match
- transition debt
- direct transition safety
- neutral conflict routing
- simulated heat
- switching load
- operational coherence
- destabilizing load
- stability margin
- scheduler correctness
- per-tick telemetry integrity

## 2. Operational Stability Condition

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

A computation is considered stable in the tested simulation domain only if:

    C_minus_P_min > 0

## 3. Operational Coherence C(t)

In target execution mode, operational coherence is computed from the execution state rather than only from global phase order.

The current prototype evaluates coherence using:

- logical match
- transition debt
- direct conflict fraction
- hot node fraction
- refractory fraction

The conceptual form is:

    C = 1.0
    C -= 0.50 * direct_conflict_fraction
    C -= 0.20 * transition_debt
    C -= 0.10 * hot_fraction
    C -= 0.10 * refractory_fraction
    C = clamp(C, 0.0, 1.0)

This makes coherence target-sensitive.

A distributed ternary pattern may have low global phase order while still being operationally correct if it matches the target state and remains transition-safe.

## 4. Destabilizing Load P(t)

The destabilizing load is modeled as:

    P(t) = heat + switch_load

where:

| Metric | Meaning |
|---|---|
| heat | simulated heat variable accumulated from switching, active states, and conflict pressure |
| switch_load | fraction of nodes that changed state during the tick |

This is a simulation metric.

It is not a physical temperature measurement and not a measured electrical energy value.

## 5. Stability Margin C_minus_P

The main stability margin is:

    C_minus_P = C(t) - P(t)

The required condition is:

    C_minus_P_min > 0

This means that the minimum stability margin over the whole execution must remain positive.

The candidate test report records:

| Test | C_minus_P_min |
|---|---:|
| standard self-test | 0.14475 |
| heavy self-test | 0.14475 |
| benchmark FRP mode | 0.144750 |

## 6. Target Match

Target match measures the fraction of output nodes equal to the target state.

    match = matching_nodes / total_nodes

Required candidate condition:

    match = 1.000

The current prototype checks this after each ALU operation.

Supported ALU operations:

- neg
- add
- sub
- compare
- consensus

## 7. Transition Debt

Transition debt measures the fraction of nodes that have not yet reached the target state.

    transition_debt = non_matching_nodes / total_nodes

A high transition debt means that the system is still converging.

A final transition debt of zero corresponds to:

    match = 1.000

## 8. Direct Conflict Fraction

Direct conflict fraction measures the fraction of nodes currently in direct polarity conflict with the target.

A direct conflict occurs when the current state and target state are opposite non-zero ternary values:

    current * target = -1

Example conflicts:

    current = -1, target = 1
    current = 1, target = -1

The direct conflict fraction contributes negatively to C(t).

## 9. Direct Transition Safety Metrics

FRP forbids actual direct transitions between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The current prototype distinguishes three event types:

| Metric | Meaning |
|---|---|
| actual_direct_events | actual direct -1 ↔ 1 transitions that occurred |
| prevented_direct_events | direct transition attempts blocked by the model |
| neutralized_conflicts | conflicts routed through neutral 0 |

Required candidate condition:

    actual_direct_events = 0

The current test report records:

| Test | actual_direct_events | prevented_direct_events | neutralized_conflicts |
|---|---:|---:|---:|
| standard self-test | 0 | 3820 | 2392 |
| heavy self-test | 0 | 7913 | 4921 |
| benchmark FRP mode | 0 | 3820 | 2392 |

## 10. Neutral State Metrics

The neutral state 0 is an active operational state.

It is used for:

- transition buffering
- phase damping
- conflict neutralization
- refractory behavior
- switching-load control

Telemetry records:

| Metric | Meaning |
|---|---|
| neutral | fraction of nodes in state 0 |
| positive | fraction of nodes in state 1 |
| negative | fraction of nodes in state -1 |

Neutralization is not treated as computational failure.

In FRP, neutralization is part of the safe transition process.

## 11. Switching Load

Switching load measures the fraction of nodes that changed state during one tick.

    switch_load = switched_nodes / total_nodes

The distributed commit layer limits the maximum transition load.

Default transition cap:

    transition_fraction = 0.25

Required candidate condition:

    switch_load_peak <= transition_fraction

The current test report records:

| Test | switch_load_peak |
|---|---:|
| standard self-test | 0.25 |
| heavy self-test | 0.25 |
| benchmark FRP mode | 0.250000 |

## 12. Heat Metric

Heat is a simulated model variable.

It increases with:

- switching activity
- active non-zero states
- conflict pressure

It decreases through:

- neutral state cooling
- passive cooling

The current prototype records:

| Metric | Meaning |
|---|---|
| heat | current simulated heat value |
| heat_peak | maximum simulated heat value during execution |
| heat_avg | average simulated heat value during execution |
| thermal_scale | heat-dependent scaling factor |

Important boundary:

    heat is not physical temperature

The current benchmark does not prove physical thermal efficiency.

## 13. Kuramoto Order Parameter R

The prototype also records the Kuramoto order parameter:

    R

R measures global phase order.

However, in FRP v0.9.3-mobile, R alone is not sufficient to determine computational correctness.

Reason:

A valid distributed ternary target may intentionally contain mixed -1, 0, and 1 states.

Such a distributed state can be operationally correct even if global phase order is not maximal.

Therefore, target-mode coherence is evaluated through operational coherence, not only R.

## 14. Scheduler Metrics

The scheduler controls temporal execution phases.

Supported modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

The prototype tracks:

| Metric | Meaning |
|---|---|
| commits | number of commit ticks |
| excites | number of excite ticks |
| balances | number of balance ticks |
| neutralizes | number of neutralize ticks |

Scheduler counts are validated by internal tick count.

They are not inferred from telemetry row count.

## 15. Per-Tick Telemetry

Per-tick telemetry is mandatory in v0.9.3-mobile.

The prototype records one telemetry row per internal tick.

Required condition:

    ticks_recorded = steps

Telemetry fields include:

- tick
- phase
- R
- phi
- neutral
- positive
- negative
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

Telemetry skipping is not allowed because it may hide transient instability.

## 16. Benchmark Metrics

The benchmark compares FRP against baseline transition models.

Compared architectures:

| Architecture | Purpose |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

Current benchmark result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 17. Supported Metric-Based Claim

The current metrics support the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The metrics do not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## 18. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 19. Candidate Verification Summary

The v0.9.3-mobile candidate is verified against the following metric conditions:

| Metric | Required Condition |
|---|---|
| match | 1.000 |
| actual_direct_events | 0 |
| C_minus_P_min | > 0 |
| switch_load_peak | <= transition_fraction |
| ticks_recorded | steps |
| scheduler counts | match selected cycle mode |

Current result:

    PASS as candidate prototype

## 20. Simulation Boundary

The coherence metrics in this document are simulation metrics.

They do not establish:

- physical thermal efficiency
- measured electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- universal superiority over all ternary transition baselines

All current metric claims are limited to the tested Python simulation domain.

## Current Status

The coherence metrics in this file are aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/core_principles.md
- ../docs/resonance_computation.md
- ./README.md

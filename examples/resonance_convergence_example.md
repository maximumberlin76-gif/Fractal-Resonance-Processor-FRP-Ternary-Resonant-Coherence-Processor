# Resonance Convergence Example

This example describes a simplified resonance-driven convergence scenario for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Example Purpose

This example illustrates how resonance-driven phase evolution can support convergence toward a stable ternary target state.

The example focuses on:

- phase evolution
- selective resonance support
- neutral transition routing
- coherence accumulation
- distributed commit
- C_minus_P stability tracking
- retained ternary output

## 2. Initial State

The system begins with a partially unstable transition condition.

The state may include:

- mixed ternary values
- incomplete target match
- transition debt
- phase dispersion
- potential direct conflicts
- simulated switching load

Initial phase order may be moderate rather than fully coherent.

Example background value:

    R ≈ 0.45

In FRP, the Kuramoto order parameter R is useful as a phase-order indicator, but it is not sufficient by itself to determine computational correctness.

## 3. Target State

FRP execution is target-oriented.

A balanced ternary operation first defines a target state.

Supported operations include:

- neg
- add
- sub
- compare
- consensus

The dynamic convergence process then moves the current ternary state toward the target state.

Required final condition:

    match = 1.000

## 4. Resonance Interaction

The resonant phase layer supports the transition process through Kuramoto-Sakaguchi type phase dynamics.

Default phase lag:

    gamma = 0.30π

The phase lag represents asymmetric coupling, delay, dissipation, or nonlinear phase shift inside the simulation.

The resonance layer does not replace ternary logic.

It acts as a dynamic phase-support layer around neutral transition control.

## 5. Neutral Transition Routing

FRP forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

If a node is in direct polarity conflict with the target, the transition must pass through neutral 0.

Required condition:

    actual_direct_events = 0

## 6. Distributed Commit

FRP does not force the entire ternary vector to switch at once by default.

Default transition cap:

    transition_fraction = 0.25

This means that no more than 25 percent of the ternary state vector may change during one tick under default settings.

Required condition:

    switch_load_peak <= transition_fraction

## 7. Dynamic Evolution

During convergence, the system evolves through repeated internal ticks.

The prototype tracks:

- logical_match
- transition_debt
- direct_conflict_fraction
- heat
- switch_load
- C
- P
- C_minus_P
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

As the target state is approached:

- logical_match increases
- transition_debt decreases
- direct conflicts are routed through neutral 0
- switch_load remains bounded
- C_minus_P must remain positive

## 8. Stability Condition

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

Required condition:

    C_minus_P_min > 0

## 9. Stable Retention

After convergence, the output is considered valid only if it satisfies the candidate invariants:

| Invariant | Required Condition |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

A correct output is therefore not only a final vector.

It is a retained ternary state reached through safe distributed transition.

## 10. Example Command

Run a demonstration using the current prototype:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run the standard verification test:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Run the benchmark:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

## 11. Expected Standard Test Summary

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

## 12. Interpretation

This example demonstrates the current FRP interpretation of resonance-based computation:

- computation is target-oriented balanced ternary transition
- resonance supports dynamic phase evolution
- neutral 0 routes conflicting transitions
- distributed commit limits abrupt switching
- operational coherence is tracked through target-sensitive metrics
- stable output requires positive C_minus_P during execution

## 13. Boundary

This example is a simulation-level demonstration.

It does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption

All claims are limited to the current Python simulation prototype.

## Current Status

This example is aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ./README.md

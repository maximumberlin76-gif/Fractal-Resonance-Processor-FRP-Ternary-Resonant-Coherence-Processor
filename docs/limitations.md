# Limitations

This document defines the current limitations and claim boundaries for the Fractal Resonance Processor (FRP) v0.9.3-mobile candidate prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Scope of the Current Prototype

The current FRP v0.9.3-mobile implementation is a single-file Python simulation prototype.

It demonstrates:

- balanced ternary state processing
- neutral transition routing
- forbidden direct -1 ↔ 1 transition enforcement
- distributed ternary commit
- Kuramoto-Sakaguchi resonant phase dynamics
- nonlinear saturation
- compression
- independent logic and coupling delay buffers
- scheduler modes: free, 7/1, 1/7
- per-tick telemetry
- self-test and benchmark execution

The prototype is suitable for simulation-level verification.

It is not suitable as evidence of physical hardware performance.

## 2. Simulation Boundary

All current results are simulation results.

The prototype does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- transistor-level implementation
- chip-level timing behavior
- measured physical power consumption
- measured physical heat dissipation
- universal superiority over all ternary or binary architectures

Any hardware-level claim would require separate physical implementation, instrumentation, measurement, and reproducible hardware testing.

## 3. Heat Metric Boundary

The heat metric in the current prototype is a simulated model variable.

It is not:

- physical temperature
- measured electrical heat
- measured chip thermal output
- measured power dissipation
- measured energy consumption

The heat metric is useful only for internal comparison inside the current simulation model.

It must not be presented as a measured physical value.

## 4. Switching Load Boundary

Switching load is a simulated transition-load metric.

It measures the fraction of nodes that changed state during one internal tick.

In the current prototype:

    switch_load = switched_nodes / total_nodes

This is not the same as measured electrical switching energy.

The current prototype can show that distributed commit limits simulated state transition load.

It cannot prove physical switching-energy reduction without hardware-level measurement.

## 5. C_minus_P Boundary

The stability margin is defined as:

    C_minus_P = C(t) - P(t)

where:

    P(t) = heat + switch_load

This is an operational simulation metric.

It is not a universal physical law.

It is valid only inside the current model assumptions and tested simulation domain.

The current candidate requires:

    C_minus_P_min > 0

This means that the simulated operational coherence remains above the simulated destabilizing load during the tested runs.

## 6. Kuramoto-Sakaguchi Model Boundary

The current prototype uses Kuramoto-Sakaguchi type phase dynamics.

This is a numerical model of coupled oscillator behavior with phase lag.

The phase lag gamma represents asymmetric coupling, delay, dissipation, or nonlinear phase shift inside the simulation.

Default value:

    gamma = 0.30π

This does not prove that a physical processor would necessarily behave according to the same numerical dynamics.

Hardware implementation would require a separate physical design and validation process.

## 7. Neutral Transition Boundary

FRP forbids direct transitions between -1 and 1 in the operational model.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The current prototype verifies:

    actual_direct_events = 0

within the tested simulation domain.

This does not automatically prove that every future implementation will preserve this property.

Any future implementation must independently verify the same invariant.

## 8. Operational Domain Boundary

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

Current test matrices include:

| Test | N Values | Seeds | Steps |
|---|---|---:|---:|
| standard self-test | 8, 16, 32, 64 | 0..4 | 128 |
| heavy self-test | 8, 16, 32, 64 | 0..9 | 256 |
| benchmark | 8, 16, 32, 64 | 0..4 | 128 |

Claims should remain limited to these tested conditions unless additional tests are added.

## 9. Benchmark Boundary

The current benchmark compares:

| Architecture | Purpose |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

The benchmark supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The benchmark does not support the following claim:

    FRP is always colder than distributed neutral ternary switching.

The distributed neutral baseline is colder in the current simulation because it does not include the resonant phase layer.

## 10. Performance Claim Boundary

The current prototype does not establish:

- computational speed advantage
- physical power efficiency
- hardware cooling advantage
- lower transistor switching energy
- lower fabrication cost
- better real-world processor performance
- superiority over existing CPU, GPU, TPU, neuromorphic, or ternary hardware systems

The current prototype establishes only simulation-level behavior under the tested model.

## 11. Hardware Claim Boundary

The current repository should not claim that FRP is already:

- a physical processor
- a chip design
- a working hardware architecture
- a fabricated ternary processor
- an electrical circuit implementation
- a production-ready computing device

The correct description is:

    Python simulation prototype of a ternary resonant coherence processor architecture.

## 12. Mathematical Boundary

The current equations and metrics are operational definitions for the simulation.

They are not presented as complete physical laws.

The condition:

    C(t) > P(t)

is used as a stability criterion inside the FRP simulation model.

The definition:

    P(t) = heat + switch_load

is a model-specific operational definition.

These expressions should not be treated as universal equations outside the current framework without additional derivation and validation.

## 13. Telemetry Boundary

Per-tick telemetry is mandatory in v0.9.3-mobile.

Required condition:

    ticks_recorded = steps

Telemetry records the internal simulation state.

It does not represent external hardware instrumentation.

Telemetry fields such as heat, switch_load, C, P, and C_minus_P should be interpreted as simulation variables.

## 14. Reproducibility Boundary

The current tests are reproducible under the provided Python implementation and default parameters.

However, results may depend on:

- Python version
- NumPy version
- random seed handling
- floating-point behavior
- parameter changes
- execution environment

Future releases should record environment metadata if stricter reproducibility is required.

## 15. Terminology Boundary

The current project name is:

    FRP — Fractal Resonance Processor

Older repository documents may still contain the previous name:

    FPR

Those older references should be treated as legacy terminology and updated where technically appropriate.

Current active terminology:

| Term | Correct Use |
|---|---|
| FRP | Fractal Resonance Processor |
| FPR | legacy naming error or older repository terminology |
| balanced ternary | state system using -1, 0, 1 |
| neutral 0 | active transition and damping state |
| actual_direct_events | direct -1 ↔ 1 transitions that occurred |
| prevented_direct_events | direct transition attempts blocked by the model |
| neutralized_conflicts | conflicts routed through neutral 0 |

## 16. Setun Historical Boundary

Balanced ternary computing has historical precedent, including Setun.

FRP is not presented as the first ternary computer.

The correct distinction is:

| System | Description |
|---|---|
| Setun | historical ternary digital computer |
| FRP | ternary resonant coherence processor simulation architecture |

FRP combines balanced ternary logic with resonant phase dynamics, neutral transition routing, distributed commit, per-tick telemetry, and operational stability tracking.

## 17. Security Boundary

The current public repository contains only the public simulation and documentation layer.

It should not include:

- private frequency maps
- closed synthesis parameters
- private resonance anchors
- locked project bodies
- non-public operational parameters
- private identity or access-control material

Public documentation should remain limited to simulation architecture and reproducible public test results.

## 18. Current Candidate Status

FRP v0.9.3-mobile status:

    PASS as candidate prototype

This means:

- the simulation prototype passes the documented tests
- target match is preserved
- actual direct -1 ↔ 1 transitions are prevented in tested runs
- C_minus_P remains positive in tested runs
- switch_load_peak remains bounded by transition_fraction
- scheduler counts match expected behavior
- telemetry is recorded per tick

It does not mean:

- hardware has been built
- physical efficiency has been measured
- chip-level performance has been proven
- real-world processor superiority has been established

## 19. Allowed Summary Claim

The safest current summary claim is:

    FRP v0.9.3-mobile is a working Python simulation candidate prototype of a ternary resonant coherence processor architecture. In the tested operational domain N >= 8, it preserves exact target match, prevents actual direct -1 ↔ 1 transitions, keeps C_minus_P positive, limits switch_load_peak according to transition_fraction, and records per-tick telemetry.

## 20. Disallowed Summary Claims

The current repository should not claim:

- FRP is a finished hardware processor.
- FRP proves physical thermal efficiency.
- FRP proves lower electrical switching energy.
- FRP is always colder than distributed neutral ternary switching.
- FRP outperforms all conventional processors.
- FRP is the first ternary computer.
- FRP has been fabricated or hardware-validated.

## Current Status

This limitations document is aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ./architecture.md
- ./benchmark_interpretation.md
- ./core_principles.md
- ./resonance_computation.md
- ../verification/README.md
- ../verification/coherence_metrics.md

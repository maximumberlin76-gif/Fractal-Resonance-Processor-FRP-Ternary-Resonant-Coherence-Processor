# Benchmark Interpretation

This document explains how to interpret the benchmark results for the Fractal Resonance Processor (FRP) v0.9.3-mobile candidate prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Benchmark Purpose

The benchmark is designed to compare the current FRP transition model against simpler baseline transition models.

The purpose is not to prove hardware performance.

The purpose is to verify whether the FRP simulation prototype preserves the following properties:

- exact target match
- zero actual direct -1 ↔ 1 transitions
- positive C_minus_P stability margin
- bounded switch_load_peak
- explicit prevention of direct transition attempts
- neutral conflict routing
- per-tick telemetry consistency

## 2. Compared Architectures

The benchmark compares four transition models:

| Architecture | Description |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

## 3. Benchmark Command

The benchmark command for the current candidate is:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark matrix:

| Parameter | Value |
|---|---|
| N | 8, 16, 32, 64 |
| seeds | 0..4 |
| cycle modes | free, 7/1, 1/7 |
| operations | neg, add, sub, compare, consensus |
| steps | 128 |

## 4. Benchmark Result

Current benchmark result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 5. Metric Definitions

| Metric | Meaning |
|---|---|
| Match | fraction of output nodes matching the target |
| C-P_min | minimum stability margin during execution |
| Heat Peak | maximum simulated heat value |
| Switch Peak | maximum fraction of nodes switched during one tick |
| Actual Direct | actual direct -1 ↔ 1 transitions |
| Prevented Direct | direct transition attempts blocked by the model |
| Neutralized | conflicts routed through neutral 0 |

## 6. FRP Benchmark Interpretation

The FRP mode is:

    frp_distributed_resonant

It includes:

- balanced ternary target generation
- forbidden direct -1 ↔ 1 transition
- neutral conflict routing
- distributed commit
- Kuramoto-Sakaguchi resonant phase layer
- cubic saturation
- nonlinear compression
- independent delay buffers
- scheduler modes
- per-tick telemetry

Current FRP benchmark result:

| Metric | Value |
|---|---:|
| match | 1.000 |
| C-P_min | 0.144750 |
| heat_peak | 0.107000 |
| switch_peak | 0.250000 |
| actual_direct | 0 |
| prevented_direct | 3820 |
| neutralized | 2392 |

Interpretation:

FRP reaches exact target match while preserving zero actual direct -1 ↔ 1 transitions.

FRP keeps the stability margin positive:

    C-P_min = 0.144750

FRP keeps the transition load bounded:

    switch_peak = 0.250000

This matches the default transition cap:

    transition_fraction = 0.25

## 7. Direct Ternary Commit Baseline

The direct ternary commit baseline performs direct state replacement without neutral routing.

Current result:

| Metric | Value |
|---|---:|
| match | 1.000 |
| C-P_min | -0.551000 |
| heat_peak | 0.051000 |
| switch_peak | 1.000000 |
| actual_direct | 2052 |
| prevented_direct | 0 |
| neutralized | 0 |

Interpretation:

The direct ternary commit baseline reaches the target state, but it allows actual direct -1 ↔ 1 transitions.

It also reaches:

    switch_peak = 1.000000

This means the entire vector may switch at once.

The negative C-P_min indicates that this transition model leaves the tested operational stability domain.

## 8. Binary-Style Forced Switching Baseline

The binary-style forced switching baseline uses a rail-style forced switching comparison.

Current result:

| Metric | Value |
|---|---:|
| match | 1.000 |
| C-P_min | -0.551000 |
| heat_peak | 0.051000 |
| switch_peak | 1.000000 |
| actual_direct | 2052 |
| prevented_direct | 0 |
| neutralized | 0 |

Interpretation:

The binary-style forced switching baseline reaches the target state, but it allows direct polarity switching and full-load switching.

It is useful as a contrast model for forced transition behavior.

It does not preserve the FRP direct-transition safety invariant.

## 9. Distributed Neutral Ternary Baseline

The distributed neutral ternary baseline routes conflicting transitions through neutral 0, but it does not include the resonant phase layer.

Current result:

| Metric | Value |
|---|---:|
| match | 1.000 |
| C-P_min | 0.174750 |
| heat_peak | 0.003250 |
| switch_peak | 0.250000 |
| actual_direct | 0 |
| prevented_direct | 0 |
| neutralized | 2052 |

Interpretation:

The distributed neutral baseline prevents actual direct -1 ↔ 1 transitions and keeps switch_peak at 0.25.

It is colder than FRP in the current simulation because it does not include:

- Kuramoto-Sakaguchi resonant phase evolution
- nonlinear saturation
- compression
- coupling delay dynamics
- phase-layer interaction
- resonant transition overhead

This baseline is therefore not an inferior model in every metric.

It is a simpler neutral transition baseline without resonant phase dynamics.

## 10. Why FRP Is Not Always Colder

The current benchmark does not support the claim that FRP is always colder than distributed neutral ternary switching.

The distributed neutral ternary baseline has:

    heat_peak = 0.003250

The FRP distributed resonant mode has:

    heat_peak = 0.107000

This happens because FRP includes a resonant phase layer and dynamic coupling process.

The distributed neutral baseline performs a simpler transition without that resonant layer.

Therefore, the correct interpretation is:

    FRP adds resonant phase dynamics on top of safe distributed neutral transition logic.

The incorrect interpretation is:

    FRP is always colder than every neutral transition baseline.

## 11. Supported Technical Claim

The benchmark supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

This claim is supported because FRP shows:

- match = 1.000
- actual_direct = 0
- C-P_min > 0
- switch_peak = 0.25
- prevented direct transition attempts are recorded
- neutralized conflicts are recorded

## 12. Unsupported Technical Claims

The benchmark does not support the following claims:

- FRP is always colder than distributed neutral ternary switching.
- FRP proves hardware thermal efficiency.
- FRP proves physical electrical switching energy reduction.
- FRP proves fabrication-level performance.
- FRP proves universal superiority over all ternary transition models.
- FRP proves hardware timing behavior.

These claims would require hardware-level measurement or additional model-specific evidence.

## 13. Direct Transition Safety Comparison

Direct transition safety is the strongest verified difference between FRP and direct switching baselines.

| Architecture | Actual Direct Events | Safety Interpretation |
|---|---:|---|
| binary_style_forced_switch | 2052 | direct transitions occur |
| direct_ternary_commit | 2052 | direct transitions occur |
| distributed_neutral_ternary | 0 | direct transitions avoided |
| frp_distributed_resonant | 0 | direct transitions avoided |

FRP preserves the safety condition:

    actual_direct_events = 0

## 14. Stability Margin Comparison

| Architecture | C-P_min | Interpretation |
|---|---:|---|
| binary_style_forced_switch | -0.551000 | unstable under current metric |
| direct_ternary_commit | -0.551000 | unstable under current metric |
| distributed_neutral_ternary | 0.174750 | stable under current metric |
| frp_distributed_resonant | 0.144750 | stable under current metric |

Both distributed neutral ternary and FRP remain positive.

The direct and binary-style baselines go negative.

This indicates that distributed transition control is essential for the tested stability model.

## 15. Switching Load Comparison

| Architecture | Switch Peak | Interpretation |
|---|---:|---|
| binary_style_forced_switch | 1.000000 | full-load switching possible |
| direct_ternary_commit | 1.000000 | full-load switching possible |
| distributed_neutral_ternary | 0.250000 | bounded distributed switching |
| frp_distributed_resonant | 0.250000 | bounded distributed switching |

FRP preserves the default transition cap:

    transition_fraction = 0.25

## 16. Heat Metric Boundary

Heat in the benchmark is a simulated model variable.

It is not:

- physical temperature
- measured electrical power
- measured chip thermal output
- fabrication-level heat dissipation
- hardware energy consumption

The heat metric is useful for comparing behavior inside the simulation model only.

It must not be presented as a hardware measurement.

## 17. Benchmark Conclusion

The benchmark shows that FRP v0.9.3-mobile satisfies the main candidate verification conditions:

| Condition | Result |
|---|---|
| target match | PASS |
| actual direct transitions | PASS |
| positive C-P margin | PASS |
| bounded switch load | PASS |
| per-tick telemetry | PASS |
| scheduler validation | PASS |

FRP is therefore valid as a working Python simulation candidate prototype in the tested operational domain.

## 18. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 19. Relation to Test Report

This document interprets the benchmark section of:

    ../TEST_REPORT_v0_9_3.md

The test report is the source of the recorded benchmark values.

This document explains how those values should and should not be interpreted.

## 20. Simulation Boundary

The benchmark validates a Python simulation prototype.

It does not validate:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- universal superiority over all ternary transition baselines

All benchmark claims are limited to the tested simulation domain.

## Current Status

The benchmark interpretation in this file is aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ./architecture.md
- ./core_principles.md
- ./resonance_computation.md

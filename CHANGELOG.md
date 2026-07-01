# Changelog

## v0.9.3-mobile — FRP Candidate Prototype

Current candidate release of the Fractal Resonance Processor (FRP) project.

This version introduces the working single-file Python simulation prototype:

    frp_prototype_v0_9_3_mobile.py

Current status:

    PASS as candidate prototype

Included:

- balanced ternary states: -1, 0, 1
- neutral 0 as active transition, damping, and balancing state
- forbidden direct -1 ↔ 1 transition
- neutral transition routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- scheduler modes: free, 7/1, and 1/7
- per-tick telemetry
- operational coherence tracking
- C_minus_P stability tracking
- processor register layer
- supported instructions: load, rand, zero, mov, neg, add, sub, compare, consensus, halt
- self-test mode
- benchmark mode
- test report: TEST_REPORT_v0_9_3.md

Verified candidate invariants:

| Invariant | Result |
|---|---|
| target match | PASS |
| actual direct -1 ↔ 1 transitions | PASS |
| positive C_minus_P margin | PASS |
| bounded switch_load_peak | PASS |
| per-tick telemetry | PASS |
| scheduler validation | PASS |

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

Benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

Supported claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

Unsupported claim:

    FRP is always colder than distributed neutral ternary switching.

Notes:

- The current repository name and active project terminology are FRP — Fractal Resonance Processor.
- Earlier repository history used the FPR spelling.
- The active spelling is FRP.
- Current results are simulation results, not hardware measurements.

## v0.1.0 — Foundational Public Layer

Initial public release of the framework under earlier repository terminology.

Included:

- core README structure
- public architecture description
- nonlinear phase synchronization model
- Kuramoto-type simulation result
- repository layer structure
- Apache License 2.0
- public-only safety boundary

This version is retained as historical repository background.

The current active project name is:

    FRP — Fractal Resonance Processor

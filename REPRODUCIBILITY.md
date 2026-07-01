# Reproducibility

This document defines how to reproduce the current reported results for the Fractal Resonance Processor (FRP) simulation prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Dependency file:

    requirements.txt

Test report:

    TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Reproducibility Scope

This document covers reproducibility for:

- standard self-test
- heavy self-test
- benchmark comparison
- candidate invariants
- simulation-level numerical summaries

All results are limited to the documented Python simulation domain.

## 2. Required Environment

Required:

- Python 3.10 or newer
- pip
- numpy

Install dependencies from the repository root:

    pip install -r requirements.txt

Current external dependency:

    numpy>=1.26.0

## 3. Prototype File

All reproducibility commands use:

    frp_prototype_v0_9_3_mobile.py

Run commands from the repository root.

If `python3` is not available, use `python` instead.

## 4. Standard Self-Test Command

Run:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

Expected standard summary:

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

## 5. Heavy Self-Test Command

Run:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Expected heavy summary:

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

## 6. Benchmark Command

Run:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 7. Candidate Invariants

The current candidate must satisfy the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy direct-transition safety, distributed switching, telemetry, and stability conditions.

## 8. Direct Transition Safety

FRP forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The required invariant is:

    actual_direct_events = 0

This invariant must hold across the tested operational domain.

## 9. Distributed Commit Boundary

The default transition cap is:

    transition_fraction = 0.25

The required condition is:

    switch_load_peak <= transition_fraction

This prevents full-vector forced switching under default settings.

## 10. Stability Boundary

The prototype tracks:

    C_minus_P = C - P

where:

| Symbol | Meaning |
|---|---|
| C | operational coherence |
| P | destabilizing load |
| C_minus_P | stability margin |

In the current prototype:

    P = heat + switch_load

The required condition is:

    C_minus_P_min > 0

## 11. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 12. Determinism and Seeds

The standard test and benchmark use explicit seed counts.

Standard self-test:

    --seeds 5

Heavy self-test:

    --seeds 10

Benchmark:

    --seeds 5

The reported summaries are tied to the current prototype implementation, the specified command parameters, and the current dependency boundary.

## 13. Supported Claim

The current supported claim is:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

## 14. Unsupported Claims

The current prototype does not support the claim:

    FRP is always colder than distributed neutral ternary switching.

The current prototype also does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all transition baselines

## 15. Simulation Boundary

All current results are simulation results.

They are produced by the Python model.

They are not hardware measurements.

The current prototype should be described as:

    Python simulation prototype

It should not be described as:

- fabricated hardware processor
- production-ready computing device
- hardware-validated chip architecture
- measured thermal processor
- measured electrical switching-energy device

## 16. Related Files

This reproducibility guide is aligned with:

- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- README.md
- INSTALL.md
- USAGE.md
- requirements.txt
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- verification/README.md
- verification/coherence_metrics.md

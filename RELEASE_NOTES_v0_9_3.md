# Release Notes — FRP v0.9.3-mobile

## Release Type

Candidate release.

This release documents the current public candidate state of the Fractal Resonance Processor (FRP) simulation prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Test report:

    TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Release Summary

FRP v0.9.3-mobile introduces a working single-file Python simulation prototype for a ternary resonant coherence processor architecture.

The prototype combines:

- balanced ternary states
- active neutral transition routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- scheduler modes
- per-tick telemetry
- C_minus_P stability tracking
- self-test verification
- benchmark comparison

## 2. Core State Model

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The neutral state 0 is active.

It is used for:

- transition routing
- damping
- conflict neutralization
- safe polarity change
- distributed state update

## 3. Direct Transition Safety

FRP forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The required invariant is:

    actual_direct_events = 0

## 4. Distributed Commit

The default transition cap is:

    transition_fraction = 0.25

This means that no more than 25 percent of the ternary state vector may change during one tick under default settings.

Required condition:

    switch_load_peak <= transition_fraction

## 5. Resonant Phase Layer

The current prototype adds a Kuramoto-Sakaguchi resonant phase layer around the neutral ternary transition logic.

Default phase lag:

    gamma = 0.30π

The phase layer supports dynamic phase evolution.

It does not replace ternary logic.

## 6. Scheduler Modes

The prototype supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

## 7. Supported Instructions

The current processor layer supports:

- load
- rand
- zero
- mov
- neg
- add
- sub
- compare
- consensus
- halt

## 8. Candidate Invariants

The current candidate must satisfy:

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

## 9. Standard Self-Test

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

Observed candidate summary:

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

## 10. Heavy Self-Test

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Observed candidate summary:

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

## 11. Benchmark

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 12. Benchmark Interpretation

The benchmark supports the following interpretation:

- direct ternary commit reaches target match but produces actual direct -1 ↔ 1 transitions
- binary-style forced switching also produces actual direct transitions and full switch load
- distributed neutral ternary switching eliminates actual direct transitions and reduces switching load
- FRP distributed resonant switching preserves zero actual direct transitions while adding the resonant phase layer
- FRP is not the lowest-heat model in this benchmark
- FRP remains inside the positive C_minus_P stability domain under the tested settings

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

## 15. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 16. Simulation Boundary

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

## 17. Known Boundaries

Current boundaries:

- no hardware implementation
- no chip fabrication result
- no physical thermal measurement
- no physical electrical energy measurement
- no production runtime environment
- no external package interface
- no automated CI workflow yet
- no Zenodo DOI yet

## 18. Files Added or Aligned for This Candidate

Core files:

- README.md
- CHANGELOG.md
- LICENSE
- NOTICE
- CITATION.cff
- SECURITY.md
- requirements.txt
- .gitignore
- INSTALL.md
- USAGE.md
- REPRODUCIBILITY.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- TEST_REPORT_v0_9_3.md
- frp_prototype_v0_9_3_mobile.py

Documentation files:

- docs/README.md
- docs/core_principles.md
- docs/resonance_computation.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md

Verification files:

- verification/README.md
- verification/coherence_metrics.md

Simulation and model files:

- simulations/README.md
- simulations/initial_kuramoto_result.md
- models/README.md
- models/kuramoto_frp_background_model.md

Example files:

- examples/README.md
- examples/resonance_convergence_example.md

## 19. Next Development Steps

Recommended next steps:

- add ROADMAP.md
- add GitHub Actions CI workflow
- add automated standard self-test job
- add automated benchmark smoke test
- add structured JSON output option
- add additional benchmark seeds
- add versioned test reports for future candidates
- prepare archival release metadata
- create Zenodo release after repository stabilization

## 20. Current Status

FRP v0.9.3-mobile is a public candidate simulation prototype.

The release is suitable for repository-level review, reproducibility testing, documentation inspection, and future archival preparation.

It is not a hardware release.

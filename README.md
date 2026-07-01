# Fractal Resonance Processor (FRP)

[![FRP Self Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml)

[![FRP Benchmark Smoke Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml)

**Ternary Resonant Coherence Processor — Python Simulation Prototype**

Current candidate version:

    v0.9.3-mobile

Current status:

    candidate prototype

Current implementation type:

    single-file Python simulation prototype

Current license:

    Apache-2.0

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

## Overview

Fractal Resonance Processor (FRP) is a nonlinear dynamic computing architecture based on balanced ternary states, neutral transition routing, distributed state transition, resonant phase dynamics, operational coherence tracking, and stability-bound execution.

FRP treats computation not as forced binary state enumeration, but as a dynamic process of target-oriented ternary transition, neutral conflict routing, resonance-supported phase evolution, distributed commit, and retained coherent output.

The current repository contains a working Python simulation prototype.

The current public candidate is designed for repository-level review, reproducibility testing, documentation inspection, continuous integration verification, and future archival preparation.

## Current Prototype

The active prototype file is:

    frp_prototype_v0_9_3_mobile.py

The active test report file is:

    TEST_REPORT_v0_9_3.md

The active candidate version is:

    v0.9.3-mobile

The prototype implements:

- balanced ternary states: `-1`, `0`, `1`
- neutral `0` as active balancing, damping, and transition state
- forbidden direct `-1 ↔ 1` transition
- neutral transition routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- scheduler modes: `free`, `7/1`, `1/7`
- per-tick telemetry
- register file
- processor instruction layer
- demonstration mode
- self-test mode
- benchmark mode
- command-line interface

## Installation

Install dependencies from the repository root:

    pip install -r requirements.txt

The current external Python dependency is:

    numpy>=1.26.0

Python standard-library modules are not listed in `requirements.txt`.

For detailed installation instructions, see:

    INSTALL.md

## Quick Start

Run a demonstration:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run the standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Run the heavier self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Run the benchmark:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

For detailed usage instructions, see:

    USAGE.md

For reproducibility instructions, see:

    REPRODUCIBILITY.md

## Core Ternary Principle

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | neutral balancing / damping / transition state |
| `1` | positive / excitatory / phase-supporting / constructive potential |

The direct transition between `-1` and `1` is forbidden.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The neutral state `0` is not treated as absence.

It acts as:

- logical neutral state
- phase damper
- transition buffer
- conflict neutralizer
- switching-load guard
- safe polarity transition state

## Dynamic Stability Principle

The core stability condition is:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| `C(t)` | operational coherence |
| `P(t)` | destabilizing load |

In the current prototype:

    P(t) = heat + switch_load

Stable execution requires:

    C_minus_P = C(t) - P(t) > 0

The prototype tracks this condition during execution.

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as `N = 2` or `N = 3` may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

Default transition cap:

    transition_fraction = 0.25

This limits the maximum distributed state transition load per tick under default settings.

## Scheduler Modes

FRP currently supports three scheduler modes:

| Mode | Tick Behavior |
|---|---|
| `free` | every tick is commit |
| `7/1` | ticks `0..6` are balance, tick `7` is commit |
| `1/7` | tick `0` is excite, ticks `1..7` are neutralize |

The scheduler is validated by internal tick counts.

## Processor Layer

The current processor layer includes:

- register file
- instruction execution
- demonstration program
- self-test mode
- benchmark mode

Supported instructions:

- `load`
- `rand`
- `zero`
- `mov`
- `neg`
- `add`
- `sub`
- `compare`
- `consensus`
- `halt`

Balanced ternary arithmetic and logical operations:

- `neg`
- `add`
- `sub`
- `compare`
- `consensus`

## Per-Tick Telemetry

Per-tick telemetry is mandatory in the current candidate.

The prototype records:

- `tick`
- `phase`
- `R`
- `phi`
- `neutral`
- `positive`
- `negative`
- `heat`
- `thermal_scale`
- `switch_load`
- `actual_direct_events_delta`
- `prevented_direct_events_delta`
- `neutralized_conflicts_delta`
- `logical_match`
- `transition_debt`
- `direct_conflict_fraction`
- `C`
- `P`
- `C_minus_P`

Skipping telemetry ticks is not allowed in the current candidate because it may hide transient instability.

## Candidate Invariants

The current candidate must satisfy the following invariants:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy safety, stability, telemetry, scheduler, and distributed transition conditions.

## Test Status

Current candidate result:

    v0.9.3-mobile: PASS as candidate prototype

### Standard Self-Test

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

### Heavy Self-Test

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

## Benchmark Summary

Benchmark command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark architectures:

- `frp_distributed_resonant`
- `direct_ternary_commit`
- `distributed_neutral_ternary`
- `binary_style_forced_switch`

Benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Benchmark Interpretation

The direct ternary and binary-style forced switching baselines reach the target result, but they allow actual direct `-1 ↔ 1` transitions and reach full switch load.

The distributed neutral ternary baseline prevents actual direct transitions and keeps `switch_load_peak = 0.25`.

The FRP distributed resonant mode preserves:

- `match = 1.000`
- `actual_direct_events = 0`
- `C_minus_P_min > 0`
- `switch_load_peak = 0.25`

The distributed neutral ternary baseline is colder in the current benchmark because it does not include the Kuramoto-Sakaguchi resonant phase layer, nonlinear saturation, compression, delay dynamics, or resonant phase evolution.

## Supported Technical Claim

The current prototype supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The following claim is not supported by the current benchmark:

    FRP is always colder than distributed neutral ternary switching.

The current benchmark does not support universal superiority over all neutral transition baselines.

## Historical Context

Balanced ternary computing has historical precedent in ternary digital computer research, including Setun.

FRP is not presented as the first ternary computer.

| System | Description |
|---|---|
| Setun | ternary digital computer |
| FRP | ternary resonant coherence processor simulation architecture |

FRP combines ternary logic with resonance-driven phase dynamics, distributed neutral transitions, per-tick operational coherence, and dynamic stability tracking.

## Repository Navigation

### Core Files

| File | Purpose |
|---|---|
| README.md | main public project overview |
| frp_prototype_v0_9_3_mobile.py | current single-file Python simulation prototype |
| TEST_REPORT_v0_9_3.md | current candidate test report |
| CHANGELOG.md | version history |
| RELEASE_NOTES_v0_9_3.md | release notes for v0.9.3-mobile |
| RELEASE_CHECKLIST_v0_9_3.md | release readiness checklist |
| PROJECT_STRUCTURE.md | repository structure guide |
| INSTALL.md | installation guide |
| USAGE.md | usage guide |
| REPRODUCIBILITY.md | reproducibility guide |
| CI.md | continuous integration documentation |
| requirements.txt | Python dependency list |
| CITATION.cff | citation metadata |
| LICENSE | Apache-2.0 license text |
| NOTICE | project notice |
| SECURITY.md | security policy |
| CONTRIBUTING.md | contribution guide |
| CODE_OF_CONDUCT.md | code of conduct |

### Documentation

| File | Purpose |
|---|---|
| docs/README.md | documentation layer index |
| docs/core_principles.md | core FRP principles |
| docs/resonance_computation.md | resonance computation explanation |
| docs/architecture.md | FRP v0.9.3-mobile architecture |
| docs/benchmark_interpretation.md | benchmark interpretation and claim boundary |
| docs/limitations.md | simulation limitations and claim boundaries |
| docs/output_schema.md | console output fields, test markers, benchmark markers, CI checks, and future JSON output direction |

### Verification

| File | Purpose |
|---|---|
| verification/README.md | verification layer overview |
| verification/coherence_metrics.md | operational coherence and metric definitions |

### Examples

| File | Purpose |
|---|---|
| examples/README.md | examples overview |
| examples/resonance_convergence_example.md | resonance convergence example |

### Models and Simulations

| File | Purpose |
|---|---|
| models/README.md | model layer overview |
| models/kuramoto_frp_background_model.md | background Kuramoto-type model context |
| simulations/README.md | simulation layer overview |
| simulations/initial_kuramoto_result.md | preliminary Kuramoto background result |

### Continuous Integration

| File | Purpose |
|---|---|
| .github/workflows/frp-self-test.yml | automated standard FRP self-test |
| .github/workflows/frp-benchmark-smoke.yml | automated benchmark smoke test |

## Continuous Integration

The repository currently has two GitHub Actions workflows:

| Workflow | Purpose | Status |
|---|---|---|
| FRP Self Test | runs the standard FRP self-test | passing |
| FRP Benchmark Smoke Test | runs the benchmark smoke test | passing |

The self-test workflow runs:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

The benchmark smoke test workflow runs:

    python frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

For detailed continuous integration documentation, see:

    CI.md

## Limitations

1. This is a Python simulation prototype, not a hardware implementation.
2. Heat is a model variable, not a physical temperature measurement.
3. Switching load is a simulated transition-load metric, not measured electrical switching energy.
4. Kuramoto-Sakaguchi phase dynamics are simulated numerically.
5. Hardware-level thermal, electrical, timing, fabrication, and performance claims are not established.
6. Current claims are limited to the tested simulation domain.

For the full limitations document, see:

    docs/limitations.md

## Current Development State

FRP v0.9.3-mobile is a public candidate Python simulation prototype.

Current repository state:

- source prototype is present
- standard self-test is documented
- heavy self-test is documented
- benchmark output is documented
- continuous integration workflows are active
- README badges are passing
- installation guide is present
- usage guide is present
- reproducibility guide is present
- release notes are present
- release checklist is present
- project structure guide is present
- citation metadata is present
- Apache-2.0 license is present
- security policy is present
- contribution guide is present
- code of conduct is present

Current automated checks:

- FRP Self Test: passing
- FRP Benchmark Smoke Test: passing

Next engineering steps:

1. keep v0.9.3-mobile source frozen unless a new candidate version is opened
2. prepare archival release metadata
3. create GitHub release tag after final review
4. create Zenodo archival release after repository stabilization
5. add DOI to CITATION.cff after DOI assignment
6. update README with DOI badge after DOI assignment

FRP v0.9.3-mobile is suitable for repository-level review, reproducibility testing, continuous integration verification, documentation inspection, and future archival preparation.

## License

Apache License 2.0.

See the full license text in:

    LICENSE

## Citation

Citation metadata is available in:

    CITATION.cff

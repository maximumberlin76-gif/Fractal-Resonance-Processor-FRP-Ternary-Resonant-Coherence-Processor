# Fractal Resonance Processor (FRP)

[![FRP Self Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml)

[![FRP Benchmark Smoke Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml)

**Ternary Resonant Coherence Processor**

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

## 1. Overview

Fractal Resonance Processor (FRP) is a ternary resonant coherence processor architecture.

FRP is based on:

- balanced ternary states
- neutral transition routing
- distributed commit behavior
- resonant phase dynamics
- operational coherence tracking
- stability-bound execution
- per-tick telemetry
- reproducible benchmark execution
- staged hardware-facing documentation pathway

FRP treats computation as a dynamic process of target-oriented ternary transition, neutral conflict routing, resonance-supported phase evolution, distributed commit, and retained coherent output.

The current repository establishes the public software validation layer of the FRP architecture.

This layer provides the executable reference model for hardware-facing specification, FPGA mapping study, ASIC mapping study, physical validation planning, and partner or funding preparation.

## 2. Current Repository Position

FRP v0.9.3-mobile currently provides:

- executable Python source code
- balanced ternary state logic
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- processor instruction layer
- self-test mode
- benchmark mode
- reproducibility commands
- benchmark output
- GitHub Actions CI verification
- documentation package
- release checklist
- roadmap
- milestone structure
- funding brief
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- citation metadata
- Apache-2.0 license

The current software layer has been executed and verified on general-purpose computing infrastructure through Python execution, reproducibility commands, benchmark execution, and automated CI workflows.

## 3. Engineering Trajectory

The FRP development trajectory is organized as:

    software validation
    → architecture stabilization
    → archival release
    → structured output
    → expanded benchmark layer
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning
    → partner and funding package
    → stable public software architecture release

The current repository package establishes the first validated public software foundation for this trajectory.

## 4. Current Prototype

The active prototype file is:

    frp_prototype_v0_9_3_mobile.py

The active test report file is:

    TEST_REPORT_v0_9_3.md

The active candidate version is:

    v0.9.3-mobile

The prototype implements:

- balanced ternary states: `-1`, `0`, `1`
- neutral `0` as active balancing, damping, and transition state
- direct polarity transition safety
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

## 5. Installation

Install dependencies from the repository root:

    pip install -r requirements.txt

The current external Python dependency is:

    numpy>=1.26.0

For detailed installation instructions, see:

    INSTALL.md

## 6. Quick Start

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

## 7. Core Ternary Principle

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | neutral balancing / damping / transition state |
| `1` | positive / excitatory / phase-supporting / constructive potential |

The direct polarity transition is routed through the neutral state.

Reference transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The neutral state `0` acts as:

- logical neutral state
- phase damper
- transition buffer
- conflict neutralizer
- switching-load guard
- polarity bridge
- scheduling control point

## 8. Dynamic Stability Principle

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

## 9. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as `N = 2` or `N = 3` may be used as micro-tests of ternary logic.

Default transition cap:

    transition_fraction = 0.25

This limits the maximum distributed state transition load per tick under default settings.

## 10. Scheduler Modes

FRP currently supports three scheduler modes:

| Mode | Tick Behavior |
|---|---|
| `free` | every tick is commit |
| `7/1` | ticks `0..6` are balance, tick `7` is commit |
| `1/7` | tick `0` is excite, ticks `1..7` are neutralize |

The scheduler is validated by internal tick counts.

## 11. Processor Layer

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

## 12. Per-Tick Telemetry

Per-tick telemetry is part of the current candidate.

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

Telemetry supports:

- execution inspection
- candidate invariant verification
- benchmark interpretation
- output schema documentation
- future structured output
- hardware-facing telemetry mapping
- physical validation planning

## 13. Candidate Invariants

The current candidate is organized around the following invariants:

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

## 14. Test Status

Current candidate result:

    v0.9.3-mobile: PASS

### 14.1 Standard Self-Test

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

### 14.2 Heavy Self-Test

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

## 15. Benchmark Summary

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

## 16. Benchmark-Supported Technical Position

The current benchmark supports the following technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

Current benchmark interpretation:

- FRP distributed resonant mode preserves `match = 1.000`
- FRP distributed resonant mode preserves `actual_direct_events = 0`
- FRP distributed resonant mode preserves `C_minus_P_min > 0`
- FRP distributed resonant mode preserves `switch_load_peak = 0.25`
- distributed_neutral_ternary has `heat_peak = 0.003250` in the current benchmark table
- frp_distributed_resonant has `heat_peak = 0.107000` in the current benchmark table
- FRP includes the Kuramoto-Sakaguchi resonant phase layer
- FRP includes nonlinear saturation
- FRP includes compression dynamics
- FRP includes delay dynamics
- FRP includes resonant phase evolution

For detailed benchmark interpretation, see:

    docs/benchmark_interpretation.md

## 17. General-Purpose Hardware Execution

The FRP software layer has been executed and verified on general-purpose computing infrastructure.

Validated through:

- local Python execution path
- reproducibility commands
- benchmark execution
- GitHub Actions workflow execution
- CI status verification

Engineering role:

    establish an executable software reference model for hardware-facing specification and implementation-layer work

## 18. Hardware-Facing Development Path

The current hardware-facing development path is organized as:

    software validation
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning

Current hardware-facing documents:

| File | Role |
|---|---|
| docs/hardware_pathway.md | defines the path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| docs/implementation_layers.md | defines the staged layer structure of FRP |
| docs/fpga_mapping_study.md | defines the FPGA-oriented mapping study |
| docs/asic_mapping_study.md | defines the ASIC-oriented mapping study |
| docs/physical_validation_plan.md | defines the physical validation planning structure |

## 19. Funding and Partner Package

Current funding and partner document:

    funding_brief.md

The funding brief provides:

- executive summary
- current validated asset list
- software validation evidence
- benchmark summary
- general-purpose hardware execution summary
- hardware-facing development path
- funding objective
- proposed funding milestones
- resource needs
- partner profile
- technical value proposition
- review package structure
- funding-facing technical message

Core funding-facing technical message:

    FRP has a validated public software reference layer, reproducibility commands, benchmark output, CI verification, and a documented pathway toward FPGA mapping, ASIC mapping, chip-oriented implementation research, and physical validation planning.

## 20. Project Milestones

Current milestone document:

    MILESTONES.md

The milestone structure defines:

| Milestone | Name | Primary Output |
|---|---|---|
| M0 | Repository Stabilization | stable v0.9.3-mobile repository package |
| M1 | Archival Release and DOI | GitHub release, Zenodo archive, DOI |
| M2 | Structured Output | JSON and machine-readable summaries |
| M3 | Extended Benchmark Layer | expanded benchmark profiles and exports |
| M4 | FPGA Mapping Package | FPGA-oriented implementation package |
| M5 | ASIC Mapping Package | chip-oriented implementation research package |
| M6 | Physical Validation Protocol | measurement and validation protocol package |
| M7 | Funding and Partner Package | review package for partners, labs, grants, and investors |
| M8 | v1.0.0 Public Software Architecture Release | stable public software architecture release |

## 21. Repository Navigation

### 21.1 Core Root Files

| File | Purpose |
|---|---|
| README.md | main public project overview |
| frp_prototype_v0_9_3_mobile.py | current executable Python prototype |
| TEST_REPORT_v0_9_3.md | current candidate test report |
| CHANGELOG.md | version history |
| RELEASE_NOTES_v0_9_3.md | release notes for v0.9.3-mobile |
| RELEASE_CHECKLIST_v0_9_3.md | release readiness checklist |
| ROADMAP.md | staged project roadmap |
| MILESTONES.md | staged project milestones |
| funding_brief.md | partner and funding-facing technical brief |
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

### 21.2 Documentation Files

| File | Purpose |
|---|---|
| docs/README.md | documentation layer index |
| docs/core_principles.md | core FRP principles |
| docs/resonance_computation.md | resonance computation explanation |
| docs/architecture.md | FRP v0.9.3-mobile architecture |
| docs/benchmark_interpretation.md | benchmark interpretation and evidence scope |
| docs/limitations.md | current simulation evidence boundaries and scope notes |
| docs/output_schema.md | console output fields, test markers, benchmark markers, CI checks, and future JSON output direction |
| docs/hardware_pathway.md | hardware-facing development pathway |
| docs/implementation_layers.md | staged implementation layer structure |
| docs/fpga_mapping_study.md | FPGA-oriented mapping study |
| docs/asic_mapping_study.md | ASIC-oriented mapping study |
| docs/physical_validation_plan.md | physical validation planning structure |

### 21.3 Verification Files

| File | Purpose |
|---|---|
| verification/README.md | verification layer overview |
| verification/coherence_metrics.md | operational coherence and metric definitions |

### 21.4 Examples

| File | Purpose |
|---|---|
| examples/README.md | examples overview |
| examples/resonance_convergence_example.md | resonance convergence example |

### 21.5 Models and Simulations

| File | Purpose |
|---|---|
| models/README.md | model layer overview |
| models/kuramoto_frp_background_model.md | background Kuramoto-type model context |
| simulations/README.md | simulation layer overview |
| simulations/initial_kuramoto_result.md | preliminary Kuramoto background result |

### 21.6 Continuous Integration

| File | Purpose |
|---|---|
| .github/workflows/frp-self-test.yml | automated standard FRP self-test |
| .github/workflows/frp-benchmark-smoke.yml | automated benchmark smoke test |

## 22. Continuous Integration

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

## 23. Release Readiness

Current release readiness files:

- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- ROADMAP.md
- MILESTONES.md
- funding_brief.md
- PROJECT_STRUCTURE.md

Current readiness state:

- prototype present
- tests documented
- benchmark documented
- CI passing
- installation documented
- usage documented
- reproducibility documented
- release scope documented
- engineering trajectory documented
- hardware pathway documented
- implementation layers documented
- FPGA mapping study documented
- ASIC mapping study documented
- physical validation plan documented
- funding brief documented
- milestones documented
- citation metadata present
- license present
- notice present
- security policy present
- contribution guide present
- code of conduct present
- output schema documented

## 24. Archival Path

Recommended archival sequence:

1. final repository stabilization
2. confirm CI passing
3. confirm release checklist
4. create GitHub release tag
5. create Zenodo archival release
6. obtain DOI
7. update CITATION.cff
8. update README with DOI badge
9. update release notes and changelog
10. prepare partner and funding package for external review

## 25. License

Apache License 2.0.

See the full license text in:

    LICENSE

## 26. Citation

Citation metadata is available in:

    CITATION.cff

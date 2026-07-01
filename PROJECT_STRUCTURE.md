# Project Structure

This document describes the public repository structure of the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

## 1. Repository Root

The repository root contains the main project files, public metadata, installation instructions, usage instructions, reproducibility documentation, release notes, release checklist, continuous integration documentation, and the current Python prototype.

| File | Purpose |
|---|---|
| README.md | main public project overview |
| frp_prototype_v0_9_3_mobile.py | current single-file Python simulation prototype |
| TEST_REPORT_v0_9_3.md | current candidate test report |
| CHANGELOG.md | version history and release chronology |
| RELEASE_NOTES_v0_9_3.md | release notes for the current candidate |
| RELEASE_CHECKLIST_v0_9_3.md | release readiness checklist for the current candidate |
| PROJECT_STRUCTURE.md | repository structure guide |
| INSTALL.md | installation instructions |
| USAGE.md | usage guide and command reference |
| REPRODUCIBILITY.md | reproducibility instructions for reported results |
| CI.md | continuous integration documentation |
| requirements.txt | Python dependency list |
| .gitignore | ignored local development files |
| LICENSE | Apache License 2.0 text |
| NOTICE | project notice and license summary |
| CITATION.cff | citation metadata |
| SECURITY.md | public security policy |
| CONTRIBUTING.md | contribution guide |
| CODE_OF_CONDUCT.md | participation and conduct policy |

## 2. Core Prototype

Current prototype:

    frp_prototype_v0_9_3_mobile.py

This file contains the current FRP v0.9.3-mobile Python simulation prototype.

It includes:

- balanced ternary state functions
- ternary arithmetic operations
- FRP core dynamics
- Kuramoto-Sakaguchi phase coupling
- nonlinear saturation and compression
- delay buffer logic
- telemetry tracking
- processor instruction layer
- demonstration mode
- standard self-test mode
- benchmark mode
- command-line interface

The prototype is currently single-file for mobile editing and direct reproducibility.

## 3. Documentation Directory

Directory:

    docs/

The `docs/` directory contains the public technical documentation layer.

| File | Purpose |
|---|---|
| docs/README.md | documentation index |
| docs/core_principles.md | core FRP principles |
| docs/resonance_computation.md | resonance computation explanation |
| docs/architecture.md | current architecture description |
| docs/benchmark_interpretation.md | benchmark interpretation and claim boundary |
| docs/limitations.md | limitations and simulation-only boundary |
| docs/output_schema.md | console output fields, test output markers, benchmark output markers, CI output checks, and future JSON output direction |

The documentation layer should remain aligned with the current prototype, test report, release notes, release checklist, CI documentation, and reproducibility documentation.

## 4. Verification Directory

Directory:

    verification/

The `verification/` directory contains verification-oriented documentation.

| File | Purpose |
|---|---|
| verification/README.md | verification layer overview |
| verification/coherence_metrics.md | operational coherence and metric definitions |

The verification layer documents how the prototype interprets:

- C
- P
- C_minus_P
- heat
- switch_load
- transition_debt
- direct transition safety
- neutralized conflicts
- benchmark metrics

## 5. Simulations Directory

Directory:

    simulations/

The `simulations/` directory contains simulation-related background material.

| File | Purpose |
|---|---|
| simulations/README.md | simulation layer overview |
| simulations/initial_kuramoto_result.md | preliminary Kuramoto background result |

Simulation files should be treated as public background or supporting simulation notes.

They should not override the current prototype test report.

## 6. Models Directory

Directory:

    models/

The `models/` directory contains conceptual or background model documentation.

| File | Purpose |
|---|---|
| models/README.md | model layer overview |
| models/kuramoto_frp_background_model.md | background Kuramoto-type model context |

Model files should be clearly distinguished from the current executable prototype.

## 7. Examples Directory

Directory:

    examples/

The `examples/` directory contains public example scenarios for running or interpreting the current prototype.

| File | Purpose |
|---|---|
| examples/README.md | examples overview |
| examples/resonance_convergence_example.md | resonance convergence example aligned with v0.9.3-mobile |

Examples should remain simulation-level and must not introduce hardware claims.

## 8. GitHub Actions Directory

Directory:

    .github/workflows/

The `.github/workflows/` directory contains CI workflow files.

| File | Purpose |
|---|---|
| .github/workflows/frp-self-test.yml | runs the standard FRP self-test |
| .github/workflows/frp-benchmark-smoke.yml | runs benchmark smoke test |

Current CI checks:

- install dependencies from requirements.txt
- run standard self-test
- verify result=PASS
- run benchmark smoke test
- verify all benchmark architecture labels are present

## 9. Test and Reproducibility Files

The current reproducibility chain is:

| File | Role |
|---|---|
| TEST_REPORT_v0_9_3.md | fixed reported candidate result |
| REPRODUCIBILITY.md | commands to reproduce the reported result |
| USAGE.md | practical command guide |
| INSTALL.md | setup and dependency installation |
| CI.md | automated execution through GitHub Actions |

These files should be updated together when the prototype behavior changes.

## 10. Release and Metadata Files

Release and metadata files:

| File | Purpose |
|---|---|
| CHANGELOG.md | historical version record |
| RELEASE_NOTES_v0_9_3.md | current candidate release description |
| RELEASE_CHECKLIST_v0_9_3.md | current candidate release readiness checklist |
| CITATION.cff | citation metadata |
| LICENSE | Apache-2.0 full license text |
| NOTICE | project notice |
| SECURITY.md | security and public boundary |
| CONTRIBUTING.md | contribution rules |
| CODE_OF_CONDUCT.md | conduct rules |

These files define the public repository identity, release boundary, and candidate readiness state.

## 11. Current Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

Any future structural change must preserve these invariants or update the version, test report, release notes, release checklist, and reproducibility documentation.

## 12. Naming Discipline

The active project name is:

    FRP — Fractal Resonance Processor

The active prototype version is:

    v0.9.3-mobile

The active prototype file is:

    frp_prototype_v0_9_3_mobile.py

The active test report is:

    TEST_REPORT_v0_9_3.md

Current documentation should use FRP consistently.

## 13. Simulation Boundary

The repository describes a Python simulation prototype.

It does not contain:

- hardware implementation
- chip layout
- fabrication package
- physical thermal measurement
- physical electrical switching-energy measurement
- production deployment system

All current claims remain limited to the documented Python simulation domain.

## 14. Update Rule

When changing the prototype, check whether the following files also need updates:

- README.md
- TEST_REPORT_v0_9_3.md
- REPRODUCIBILITY.md
- USAGE.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- CHANGELOG.md
- CI.md
- PROJECT_STRUCTURE.md
- docs/README.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- docs/output_schema.md
- verification/coherence_metrics.md

Documentation must stay aligned with executable behavior.

## 15. Current Status

The repository structure is aligned with the FRP v0.9.3-mobile candidate prototype.

Current repository packaging includes:

- root README
- prototype source file
- test report
- release notes
- release checklist
- project structure guide
- installation guide
- usage guide
- reproducibility guide
- CI documentation
- output schema documentation
- GitHub Actions self-test workflow
- GitHub Actions benchmark smoke test workflow
- citation metadata
- Apache-2.0 license
- notice file
- security policy
- contribution guide
- code of conduct

The next practical development step is archival preparation after final review.

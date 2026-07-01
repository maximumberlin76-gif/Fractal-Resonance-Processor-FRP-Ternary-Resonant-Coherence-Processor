# Project Structure

This document describes the public repository structure of the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

## 1. Repository Root

The repository root contains the main project files, public metadata, installation instructions, usage instructions, reproducibility documentation, release documentation, roadmap, project structure guide, continuous integration documentation, and the current Python prototype.

| File | Purpose |
|---|---|
| README.md | main public project overview |
| frp_prototype_v0_9_3_mobile.py | current executable Python prototype |
| TEST_REPORT_v0_9_3.md | current candidate test report |
| CHANGELOG.md | version history and release chronology |
| RELEASE_NOTES_v0_9_3.md | release notes for the current candidate |
| RELEASE_CHECKLIST_v0_9_3.md | release readiness checklist for the current candidate |
| ROADMAP.md | staged project roadmap from software validation toward hardware-facing development |
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

This file contains the current FRP v0.9.3-mobile Python execution model.

It includes:

- balanced ternary state functions
- ternary arithmetic operations
- FRP core dynamics
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi phase coupling
- nonlinear saturation and compression
- delay buffer logic
- scheduler modes
- per-tick telemetry tracking
- register file
- processor instruction layer
- demonstration mode
- standard self-test mode
- benchmark mode
- command-line interface

The prototype currently serves as the executable reference model for the public software validation layer.

## 3. Documentation Directory

Directory:

    docs/

The `docs/` directory contains the public technical documentation layer.

| File | Purpose |
|---|---|
| docs/README.md | documentation layer index |
| docs/core_principles.md | core FRP principles |
| docs/resonance_computation.md | resonance computation explanation |
| docs/architecture.md | current FRP v0.9.3-mobile architecture description |
| docs/benchmark_interpretation.md | benchmark interpretation and evidence scope |
| docs/limitations.md | current simulation evidence boundaries and scope notes |
| docs/output_schema.md | console output fields, test output markers, benchmark output markers, CI output checks, and future JSON output direction |
| docs/hardware_pathway.md | path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| docs/implementation_layers.md | staged implementation structure from conceptual architecture through software execution, validation, CI, documentation, hardware-facing specification, FPGA/ASIC studies, physical validation, and funding preparation |

The documentation layer should remain aligned with the current prototype, test report, release notes, release checklist, roadmap, CI documentation, and reproducibility documentation.

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
- thermal_scale
- switch_load
- transition_debt
- direct transition safety
- prevented direct transitions
- neutralized conflicts
- logical match
- direct conflict fraction
- scheduler counts
- telemetry completeness

## 5. Simulations Directory

Directory:

    simulations/

The `simulations/` directory contains simulation-related background material.

| File | Purpose |
|---|---|
| simulations/README.md | simulation layer overview |
| simulations/initial_kuramoto_result.md | preliminary Kuramoto background result |

Simulation files provide background and supporting simulation notes.

The current candidate result remains anchored in:

    TEST_REPORT_v0_9_3.md

## 6. Models Directory

Directory:

    models/

The `models/` directory contains conceptual and background model documentation.

| File | Purpose |
|---|---|
| models/README.md | model layer overview |
| models/kuramoto_frp_background_model.md | background Kuramoto-type model context |

Model files support the conceptual and mathematical background of the current software validation layer.

## 7. Examples Directory

Directory:

    examples/

The `examples/` directory contains public example scenarios for running or interpreting the current prototype.

| File | Purpose |
|---|---|
| examples/README.md | examples overview |
| examples/resonance_convergence_example.md | resonance convergence example aligned with v0.9.3-mobile |

Examples support practical repository review and command-level interpretation.

## 8. GitHub Actions Directory

Directory:

    .github/workflows/

The `.github/workflows/` directory contains CI workflow files.

| File | Purpose |
|---|---|
| .github/workflows/frp-self-test.yml | runs the standard FRP self-test |
| .github/workflows/frp-benchmark-smoke.yml | runs the benchmark smoke test |

Current CI checks:

- install dependencies from requirements.txt
- run standard self-test
- verify result=PASS
- run benchmark smoke test
- verify all benchmark architecture labels are present

Current CI role:

    automated verification of the public software validation layer on general-purpose computing infrastructure

## 9. Test and Reproducibility Files

The current reproducibility chain is:

| File | Role |
|---|---|
| TEST_REPORT_v0_9_3.md | fixed reported candidate result |
| REPRODUCIBILITY.md | commands to reproduce the reported result |
| USAGE.md | practical command guide |
| INSTALL.md | setup and dependency installation |
| CI.md | automated execution through GitHub Actions |

These files define the current reproducible execution path.

Current execution chain:

    install dependencies
    → run standard self-test
    → run heavy self-test
    → run benchmark
    → verify CI workflows
    → inspect documented candidate result

## 10. Release and Metadata Files

Release and metadata files:

| File | Purpose |
|---|---|
| CHANGELOG.md | historical version record |
| RELEASE_NOTES_v0_9_3.md | current candidate release description |
| RELEASE_CHECKLIST_v0_9_3.md | current candidate release readiness checklist |
| ROADMAP.md | staged development roadmap |
| CITATION.cff | citation metadata |
| LICENSE | Apache-2.0 full license text |
| NOTICE | project notice |
| SECURITY.md | security and public boundary |
| CONTRIBUTING.md | contribution rules |
| CODE_OF_CONDUCT.md | conduct rules |

These files define the public repository identity, release boundary, citation path, and candidate readiness state.

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

These invariants connect:

- executable software behavior
- test report
- benchmark interpretation
- verification metrics
- CI verification
- release checklist
- future hardware-facing specification work

Any future structural change should preserve these invariants or update the version, test report, release notes, release checklist, reproducibility documentation, and roadmap.

## 12. Software Validation Layer

The current software validation layer includes:

- executable Python prototype
- command-line interface
- demonstration mode
- standard self-test mode
- heavy self-test command profile
- benchmark mode
- reproducibility guide
- CI workflows
- test report
- output schema documentation
- verification metrics

Current role:

    establish executable FRP behavior and documented candidate results

## 13. Hardware-Facing Documentation Pathway

The current repository initiates the hardware-facing documentation pathway through:

| File | Role |
|---|---|
| docs/hardware_pathway.md | defines the path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| docs/implementation_layers.md | defines the staged layer structure from conceptual architecture through software execution, validation, CI, documentation, hardware-facing specification, FPGA/ASIC mapping, physical validation, and funding preparation |
| ROADMAP.md | places the hardware-facing pathway into the staged project roadmap |

The current hardware-facing documentation path connects the validated software layer with future implementation-layer work.

## 14. Engineering Trajectory

The project engineering trajectory is:

    software validation
    → architecture stabilization
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning
    → partner and funding package

Current repository position:

    public software validation package with initiated hardware-facing documentation pathway

## 15. Naming Discipline

The active project name is:

    FRP — Fractal Resonance Processor

The active prototype version is:

    v0.9.3-mobile

The active prototype file is:

    frp_prototype_v0_9_3_mobile.py

The active test report is:

    TEST_REPORT_v0_9_3.md

Current documentation should use FRP consistently.

## 16. Documentation Update Rule

When changing the prototype, benchmark output, release package, or engineering trajectory, review whether the following files also need updates:

- README.md
- TEST_REPORT_v0_9_3.md
- REPRODUCIBILITY.md
- USAGE.md
- CI.md
- PROJECT_STRUCTURE.md
- ROADMAP.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- CHANGELOG.md
- docs/README.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/output_schema.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- verification/coherence_metrics.md

Documentation must stay aligned with executable behavior, benchmark output, CI status, release readiness, and the current engineering path.

## 17. Current Repository Packaging

The current repository packaging includes:

- root README
- executable prototype source file
- test report
- changelog
- release notes
- release checklist
- roadmap
- project structure guide
- installation guide
- usage guide
- reproducibility guide
- CI documentation
- output schema documentation
- hardware pathway documentation
- implementation layer documentation
- GitHub Actions self-test workflow
- GitHub Actions benchmark smoke-test workflow
- documentation layer
- verification layer
- examples layer
- simulations layer
- models layer
- citation metadata
- Apache-2.0 license
- notice file
- security policy
- contribution guide
- code of conduct

## 18. Current Status

The repository structure is aligned with the FRP v0.9.3-mobile candidate.

The current repository establishes the public software validation layer and the initial hardware-facing documentation pathway.

The structure now supports:

- repository-level review
- reproducibility testing
- benchmark inspection
- CI verification
- documentation inspection
- archival release preparation
- hardware-facing specification planning
- FPGA and ASIC mapping study preparation
- physical validation planning
- funding and partner preparation

# Release Notes — FRP v0.9.3-mobile

Release candidate:

    v0.9.3-mobile

Project:

    FRP — Fractal Resonance Processor

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Test report:

    TEST_REPORT_v0_9_3.md

Current public release scope:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, hardware-facing documentation pathway, milestone structure, and funding brief

Engineering trajectory:

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

## 1. Release Summary

FRP v0.9.3-mobile establishes the public software validation package for the Fractal Resonance Processor architecture.

This release candidate provides:

- executable Python prototype
- balanced ternary state logic
- neutral transition routing
- direct polarity transition safety
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- processor instruction layer
- demonstration mode
- self-test mode
- benchmark mode
- reproducibility commands
- benchmark output
- automated GitHub Actions verification
- documentation package
- release checklist
- project roadmap
- milestone structure
- funding brief
- hardware pathway documentation
- implementation layers documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- citation metadata
- Apache-2.0 license

The current software layer has been executed and verified on general-purpose computing infrastructure through Python execution, reproducibility commands, benchmark execution, and CI workflows.

## 2. Main Prototype

Primary executable prototype:

    frp_prototype_v0_9_3_mobile.py

The prototype implements:

- balanced ternary states: `-1`, `0`, `1`
- neutral `0` as active balancing, damping, and transition state
- direct polarity transition safety
- transition routing through neutral state
- distributed commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- scheduler modes: `free`, `7/1`, `1/7`
- per-tick telemetry
- register file
- processor instruction layer
- command-line interface

Supported execution modes:

- `demo`
- `test`
- `bench`

## 3. Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants define the behavioral baseline for the v0.9.3-mobile software validation package.

## 4. Standard Self-Test Result

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

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

Status:

    complete

## 5. Heavy Self-Test Result

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

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

Status:

    complete

## 6. Benchmark Result

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

Status:

    complete

## 7. Benchmark-Supported Technical Position

The v0.9.3-mobile benchmark supports the following technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

Current benchmark interpretation:

- FRP distributed resonant mode preserves match = 1.000
- FRP distributed resonant mode preserves actual_direct_events = 0
- FRP distributed resonant mode preserves C_minus_P_min > 0
- FRP distributed resonant mode preserves switch_load_peak = 0.25
- distributed_neutral_ternary has heat_peak = 0.003250 in the current benchmark table
- frp_distributed_resonant has heat_peak = 0.107000 in the current benchmark table
- FRP includes the Kuramoto-Sakaguchi resonant phase layer
- FRP includes nonlinear saturation
- FRP includes compression dynamics
- FRP includes delay dynamics
- FRP includes resonant phase evolution

The current benchmark evidence separates safe distributed neutral ternary transition behavior from the FRP distributed resonant mode, which includes the additional resonant phase layer and nonlinear dynamics.

## 8. Continuous Integration

This release candidate includes two GitHub Actions workflows.

| Workflow | File | Current Role |
|---|---|---|
| FRP Self Test | .github/workflows/frp-self-test.yml | runs standard self-test and verifies PASS result |
| FRP Benchmark Smoke Test | .github/workflows/frp-benchmark-smoke.yml | runs benchmark smoke test and verifies benchmark architecture labels |

Current CI coverage:

- dependency installation from `requirements.txt`
- standard self-test execution
- `result=PASS` verification
- benchmark command execution
- benchmark architecture label verification

Current CI status:

    passing

## 9. General-Purpose Hardware Execution

The FRP software layer has been executed and verified on general-purpose computing infrastructure.

Validated through:

- local Python execution path
- reproducibility commands
- benchmark execution
- GitHub Actions workflow execution
- CI status verification

Engineering role:

    establish an executable software reference model for hardware-facing specification and implementation-layer research

## 10. Software Validation Package

The v0.9.3-mobile release candidate establishes the current public software validation package.

Current validated package includes:

- executable prototype source
- documented candidate invariants
- standard self-test
- heavy self-test
- benchmark execution
- reproducibility commands
- output schema documentation
- CI workflow verification
- release checklist
- release notes
- roadmap
- milestone structure
- funding brief
- project structure guide
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan

Current role:

    provide the executable reference model for the FRP architecture

## 11. Hardware-Facing Documentation Pathway

This release candidate includes the current hardware-facing documentation pathway.

Current hardware-facing documents:

| File | Role |
|---|---|
| docs/hardware_pathway.md | defines the path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| docs/implementation_layers.md | defines the staged layer structure from conceptual architecture through software execution, validation, CI, documentation, hardware-facing specification, FPGA/ASIC studies, physical validation, and funding preparation |
| docs/fpga_mapping_study.md | defines the FPGA-oriented mapping study from the validated software reference model toward programmable-hardware implementation planning |
| docs/asic_mapping_study.md | defines the ASIC-oriented mapping study from the validated software reference model toward chip-oriented implementation research |
| docs/physical_validation_plan.md | defines the physical validation planning structure for measurement, benchmark repeatability, telemetry comparison, and comparison against the Python reference model |
| ROADMAP.md | places the hardware-facing pathway into the staged project roadmap |
| MILESTONES.md | converts the pathway into project milestones and acceptance criteria |
| funding_brief.md | translates the pathway into partner and funding-facing language |

The current hardware-facing documentation pathway connects the validated software layer with future implementation-layer work.

## 12. Milestone Structure

This release candidate includes a project milestone structure.

Milestone document:

    MILESTONES.md

Current milestones:

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

Current role:

    provide project-level milestone structure for repository management, funding planning, engineering coordination, and GitHub milestone creation

## 13. Funding and Partner Brief

This release candidate includes a partner and funding-facing technical brief.

Funding brief file:

    funding_brief.md

The funding brief provides:

- executive summary
- current validated asset list
- software validation evidence
- candidate invariants
- self-test and benchmark summaries
- general-purpose hardware execution
- hardware-facing development path
- funding objective
- proposed funding milestones
- resource needs
- partner profile
- technical value proposition
- review package structure
- funding-facing technical message

Current role:

    support engineering partner review, laboratory collaboration discussion, grant preparation, investor-facing technical evaluation, and milestone-based resource planning

## 14. Files Added or Aligned

### 14.1 Root Files

| File | Status |
|---|---|
| README.md | aligned |
| frp_prototype_v0_9_3_mobile.py | present |
| TEST_REPORT_v0_9_3.md | present |
| CHANGELOG.md | aligned |
| RELEASE_NOTES_v0_9_3.md | aligned |
| RELEASE_CHECKLIST_v0_9_3.md | aligned |
| ROADMAP.md | aligned |
| MILESTONES.md | present |
| funding_brief.md | present |
| PROJECT_STRUCTURE.md | aligned |
| INSTALL.md | present |
| USAGE.md | present |
| REPRODUCIBILITY.md | present |
| CI.md | present |
| requirements.txt | present |
| .gitignore | present |
| LICENSE | present |
| NOTICE | present |
| CITATION.cff | present |
| SECURITY.md | present |
| CONTRIBUTING.md | present |
| CODE_OF_CONDUCT.md | present |

### 14.2 Documentation Files

| File | Status |
|---|---|
| docs/README.md | aligned |
| docs/core_principles.md | present |
| docs/resonance_computation.md | present |
| docs/architecture.md | present |
| docs/benchmark_interpretation.md | present |
| docs/limitations.md | present |
| docs/output_schema.md | present |
| docs/hardware_pathway.md | present |
| docs/implementation_layers.md | present |
| docs/fpga_mapping_study.md | present |
| docs/asic_mapping_study.md | present |
| docs/physical_validation_plan.md | present |

### 14.3 Verification Files

| File | Status |
|---|---|
| verification/README.md | present |
| verification/coherence_metrics.md | present |

### 14.4 Example, Model, and Simulation Files

| File | Status |
|---|---|
| examples/README.md | present |
| examples/resonance_convergence_example.md | present |
| models/README.md | present |
| models/kuramoto_frp_background_model.md | present |
| simulations/README.md | present |
| simulations/initial_kuramoto_result.md | present |

### 14.5 CI Files

| File | Status |
|---|---|
| .github/workflows/frp-self-test.yml | present |
| .github/workflows/frp-benchmark-smoke.yml | present |

## 15. Documentation Growth in This Candidate

This candidate includes a documentation path from current software validation toward hardware-facing development and milestone-based project planning.

Documentation layers now include:

- core principles
- resonance computation
- current architecture
- benchmark interpretation
- output schema
- hardware pathway
- implementation layers
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- roadmap
- milestones
- funding brief
- release checklist
- project structure

The documentation package supports:

- repository-level review
- reproducibility testing
- benchmark inspection
- CI verification
- archival release preparation
- hardware-facing specification planning
- FPGA mapping study preparation
- ASIC mapping study preparation
- physical validation planning
- milestone tracking
- funding and partner preparation

## 16. Current Engineering Trajectory

The current engineering trajectory is:

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

The current repository position is:

    public software validation package with hardware-facing documentation pathway, milestone structure, and funding brief

## 17. Release Readiness

The v0.9.3-mobile candidate is ready as a public software validation package.

Current readiness state:

| Category | Status |
|---|---|
| prototype present | complete |
| tests documented | complete |
| benchmark documented | complete |
| CI passing | complete |
| installation documented | complete |
| usage documented | complete |
| reproducibility documented | complete |
| release scope documented | complete |
| engineering trajectory documented | complete |
| hardware pathway documented | complete |
| implementation layers documented | complete |
| FPGA mapping study documented | complete |
| ASIC mapping study documented | complete |
| physical validation plan documented | complete |
| funding brief documented | complete |
| milestones documented | complete |
| release notes present | complete |
| changelog present | complete |
| roadmap present | complete |
| project structure documented | complete |
| citation metadata present | complete |
| license present | complete |
| notice present | complete |
| security policy present | complete |
| contribution guide present | complete |
| code of conduct present | complete |
| output schema documented | complete |

## 18. Review Package

Current review package includes:

- README.md
- funding_brief.md
- MILESTONES.md
- ROADMAP.md
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- PROJECT_STRUCTURE.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- docs/physical_validation_plan.md
- docs/benchmark_interpretation.md
- docs/output_schema.md
- REPRODUCIBILITY.md
- CI.md
- CITATION.cff
- LICENSE

Review package role:

    support repository-level review, technical partner review, laboratory collaboration discussion, grant preparation, investor-facing technical evaluation, and milestone-based resource planning

## 19. Remaining Before Archival Release

Before creating an archival release or Zenodo DOI:

- confirm all CI workflows are passing
- confirm README badges are passing
- confirm repository file names are final
- confirm release notes are final
- confirm CITATION.cff is accurate
- create GitHub release tag
- create Zenodo archival release
- add DOI to CITATION.cff after DOI assignment
- update README with DOI badge after DOI assignment

## 20. Recommended Next Development Target

Recommended next development target:

    v0.9.4 — structured output and extended reproducibility

Candidate v0.9.4 focus:

- structured JSON output option
- machine-readable test summary
- machine-readable benchmark summary
- reproducibility profiles
- expanded seed configuration
- benchmark export files
- telemetry export mode
- updated output schema documentation
- updated CI validation

## 21. Current Status

FRP v0.9.3-mobile establishes the public software validation layer, hardware-facing documentation pathway, milestone structure, and funding brief.

The current repository package is suitable for:

- repository-level review
- reproducibility testing
- benchmark verification
- continuous integration verification
- documentation inspection
- release preparation
- archival packaging
- hardware-facing specification planning
- FPGA and ASIC mapping study preparation
- physical validation planning
- implementation-layer research planning
- milestone tracking
- funding and partner preparation

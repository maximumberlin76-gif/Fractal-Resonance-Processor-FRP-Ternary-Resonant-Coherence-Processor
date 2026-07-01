# Roadmap — Fractal Resonance Processor (FRP)

This roadmap defines the staged development path for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, hardware-facing documentation pathway, milestone structure, and funding brief

## 1. Purpose

The purpose of this roadmap is to define the staged engineering trajectory of FRP from the current validated software reference model toward structured output, expanded benchmarks, hardware-facing specification, FPGA mapping, ASIC mapping, physical validation planning, funding preparation, and stable public software architecture release.

The roadmap connects:

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

## 2. Current Foundation

FRP v0.9.3-mobile establishes the current public software validation layer.

Current validated foundation:

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
- GitHub Actions CI workflows
- documentation package
- release checklist
- release notes
- project structure guide
- milestone structure
- funding brief
- hardware pathway document
- implementation layers document
- FPGA mapping study document
- ASIC mapping study document
- physical validation plan
- citation metadata
- Apache-2.0 license

Current candidate result:

    PASS

## 3. Current Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants define the current behavioral baseline and provide the reference point for future software, benchmark, hardware-facing, FPGA, ASIC, and physical validation stages.

## 4. Current Validation Evidence

Standard self-test command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Standard self-test result:

    PASS

Heavy self-test command:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Heavy self-test result:

    PASS

Benchmark command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

## 5. Current Repository Position

Current repository position:

    public software validation package with hardware-facing documentation pathway, milestone structure, and funding brief

The current software layer has been executed and verified on general-purpose computing infrastructure.

Validated through:

- local Python execution path
- reproducibility commands
- benchmark execution
- GitHub Actions workflow execution
- CI status verification

Engineering role:

    establish an executable software reference model for hardware-facing specification and implementation-layer work

## 6. Roadmap Overview

| Stage | Target | Primary Output |
|---|---|---|
| Stage 0 | v0.9.3-mobile | repository stabilization and public software validation package |
| Stage 1 | archival release | GitHub release, Zenodo archive, DOI |
| Stage 2 | v0.9.4 | structured output and machine-readable summaries |
| Stage 3 | v0.9.5 | expanded benchmark layer |
| Stage 4 | FPGA mapping package | programmable-hardware mapping package |
| Stage 5 | ASIC mapping package | chip-oriented implementation research package |
| Stage 6 | physical validation protocol | measurement and validation planning package |
| Stage 7 | funding and partner package | review package for partners, labs, grants, and investors |
| Stage 8 | v1.0.0 | stable public software architecture release |

## 7. Stage 0 — v0.9.3-mobile Repository Stabilization

Current status:

    active candidate package

Objective:

    stabilize the current public software validation package and align all repository navigation, release, milestone, and funding documents

Primary outputs:

- executable prototype
- test report
- benchmark output
- CI workflows
- release notes
- release checklist
- roadmap
- milestones
- funding brief
- project structure guide
- documentation index
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan

Acceptance criteria:

- standard self-test documented
- heavy self-test documented
- benchmark documented
- CI workflows passing
- README badges passing
- release checklist complete
- release notes aligned
- roadmap aligned
- milestones aligned
- funding brief present
- project structure aligned
- docs index aligned
- repository ready for archival release preparation

Related files:

- README.md
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- ROADMAP.md
- MILESTONES.md
- funding_brief.md
- PROJECT_STRUCTURE.md
- docs/README.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- docs/physical_validation_plan.md

## 8. Stage 1 — Archival Release and DOI

Target:

    archival release of v0.9.3-mobile

Objective:

    create a citable archival release of the current FRP software validation package

Planned outputs:

- GitHub release tag
- GitHub release description
- Zenodo archival release
- DOI assignment
- updated CITATION.cff
- README DOI badge
- updated changelog
- updated release notes
- archival metadata review

Acceptance criteria:

- GitHub release created
- Zenodo record created
- DOI assigned
- CITATION.cff updated
- README DOI badge added
- changelog updated
- release notes aligned with archival record

Related files:

- CITATION.cff
- README.md
- CHANGELOG.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md

Project value:

    makes the FRP software validation package citable, archive-ready, and externally referenceable

## 9. Stage 2 — v0.9.4 Structured Output

Target candidate:

    v0.9.4

Objective:

    add machine-readable output for tests, benchmarks, reproducibility workflows, and external inspection

Planned outputs:

- JSON output mode
- machine-readable self-test summary
- machine-readable heavy self-test summary
- machine-readable benchmark summary
- structured telemetry export option
- optional CSV output
- updated output schema documentation
- updated usage guide
- updated reproducibility guide
- updated CI validation for structured output

Candidate command direction:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Acceptance criteria:

- test mode produces structured summary
- benchmark mode produces structured summary
- JSON fields match docs/output_schema.md
- CI validates structured output markers
- reproducibility guide includes structured output commands
- test report updated for v0.9.4

Related files:

- docs/output_schema.md
- USAGE.md
- REPRODUCIBILITY.md
- CI.md
- TEST_REPORT
- RELEASE_NOTES
- CHANGELOG

Project value:

    improves automated inspection, benchmark reproducibility, partner review, and integration readiness

## 10. Stage 3 — v0.9.5 Extended Benchmark Layer

Target candidate:

    v0.9.5

Objective:

    expand the benchmark layer for stronger comparative analysis and reproducibility

Planned outputs:

- additional benchmark seeds
- additional vector sizes
- additional scheduler profiles
- expanded transition metrics
- transition debt summaries
- direct conflict fraction summaries
- heat trajectory summaries
- switch-load trajectory summaries
- coherence trajectory summaries
- benchmark export files
- benchmark profile guide
- updated benchmark interpretation

Candidate benchmark dimensions:

- seed count
- vector size
- step count
- scheduler mode
- transition fraction
- delay depth
- gamma parameter
- coupling strength
- damping strength
- compression profile

Acceptance criteria:

- benchmark profiles reproducible through documented commands
- benchmark exports generated consistently
- benchmark interpretation aligned with expanded output
- CI runs benchmark smoke validation
- documentation reflects expanded benchmark layer
- release notes include benchmark expansion

Related files:

- docs/benchmark_interpretation.md
- docs/output_schema.md
- REPRODUCIBILITY.md
- USAGE.md
- CI.md
- TEST_REPORT
- RELEASE_NOTES
- CHANGELOG

Project value:

    strengthens comparative evidence and supports technical review by partners, labs, and funding reviewers

## 11. Stage 4 — FPGA Mapping Package

Target:

    FPGA-oriented implementation package

Objective:

    translate the validated FRP software reference behavior into programmable-hardware implementation planning

Current foundation:

- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- software reference model
- candidate invariants
- benchmark output

Planned outputs:

- FPGA state encoding proposal
- neutral transition controller proposal
- distributed commit scheduler proposal
- register file mapping proposal
- delay buffer mapping proposal
- phase approximation proposal
- nonlinear block approximation proposal
- telemetry register proposal
- FPGA testbench plan
- Python-reference comparison plan
- FPGA prototype planning structure

Acceptance criteria:

- FPGA mapping references current software behavior
- candidate invariants mapped to FPGA validation criteria
- telemetry mapping defined
- testbench comparison structure defined
- FPGA package documented
- partner review package includes FPGA mapping summary

Related files:

- docs/fpga_mapping_study.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/physical_validation_plan.md
- MILESTONES.md
- funding_brief.md

Project value:

    creates the first programmable-hardware bridge from the software validation layer toward implementation-layer research

## 12. Stage 5 — ASIC Mapping Package

Target:

    ASIC-oriented implementation research package

Objective:

    translate the validated FRP software reference behavior into chip-oriented architectural study

Current foundation:

- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- software reference model
- candidate invariants
- benchmark output

Planned outputs:

- ternary state representation proposal
- neutral routing cell proposal
- local transition controller proposal
- distributed commit timing proposal
- scheduler control proposal
- state storage proposal
- phase approximation proposal
- nonlinear response proposal
- coherence and load tracking proposal
- telemetry and test interface proposal
- ASIC testbench plan
- Python-reference comparison plan
- chip-oriented implementation research structure

Acceptance criteria:

- ASIC mapping references current software behavior
- candidate invariants mapped to ASIC validation criteria
- neutral routing cell structure defined
- distributed commit timing structure defined
- telemetry and test interface defined
- chip-oriented implementation research package documented

Related files:

- docs/asic_mapping_study.md
- docs/fpga_mapping_study.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/physical_validation_plan.md
- MILESTONES.md
- funding_brief.md

Project value:

    establishes a chip-oriented implementation research path grounded in the validated software reference layer

## 13. Stage 6 — Physical Validation Protocol

Target:

    physical validation protocol package

Objective:

    define how future physical FRP implementations can be measured and compared against the software reference model

Current foundation:

- docs/physical_validation_plan.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- software reference model
- benchmark output
- candidate invariants

Planned outputs:

- physical validation protocol
- measurement setup structure
- logical correctness test plan
- direct transition safety test plan
- neutral routing test plan
- distributed commit test plan
- scheduler validation plan
- telemetry consistency plan
- timing measurement plan
- switching activity measurement plan
- energy measurement plan
- thermal measurement plan
- benchmark repeatability plan
- Python-reference comparison report structure

Acceptance criteria:

- validation categories defined
- measurement protocol structure defined
- benchmark repeatability structure defined
- reference comparison structure defined
- validation deliverables listed
- partner and lab review path documented

Related files:

- docs/physical_validation_plan.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- MILESTONES.md
- funding_brief.md

Project value:

    prepares FRP for measurable physical implementation review and laboratory collaboration

## 14. Stage 7 — Funding and Partner Package

Target:

    partner and funding review package

Objective:

    prepare FRP for engineering partner review, laboratory collaboration, grant review, or investor-facing technical evaluation

Current foundation:

- funding_brief.md
- MILESTONES.md
- ROADMAP.md
- README.md
- TEST_REPORT_v0_9_3.md
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan

Planned outputs:

- executive summary
- validated asset list
- software validation evidence summary
- benchmark evidence summary
- CI verification summary
- hardware-facing pathway summary
- FPGA mapping summary
- ASIC mapping summary
- physical validation summary
- funding milestone table
- resource needs table
- partner profile
- review package checklist
- presentation-ready technical summary

Acceptance criteria:

- funding brief complete
- milestones complete
- review package file list complete
- project value proposition clear
- engineering trajectory clear
- technical assets documented
- resource needs documented
- partner review pathway documented

Related files:

- funding_brief.md
- MILESTONES.md
- README.md
- ROADMAP.md
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- docs/physical_validation_plan.md

Project value:

    creates a coherent package for funding, partnerships, laboratory collaboration, and technical due diligence

## 15. Stage 8 — v1.0.0 Public Software Architecture Release

Target candidate:

    v1.0.0

Objective:

    establish the first stable public software architecture release of FRP

Planned foundation:

- stabilized v0.9.3-mobile package
- structured output layer
- expanded benchmark layer
- hardware-facing documentation pathway
- milestone structure
- funding package
- archival release metadata

Candidate requirements:

- stable source layout
- stable command interface
- stable output schema
- stable benchmark profile
- stable documentation layer
- stable release checklist
- stable citation metadata
- stable roadmap
- stable milestone structure
- GitHub release tag
- archival release package

Acceptance criteria:

- v1.0.0 candidate source finalized
- test report finalized
- benchmark report finalized
- documentation package finalized
- release notes finalized
- release checklist finalized
- citation metadata finalized
- GitHub release created
- archival package created

Related files:

- README.md
- ROADMAP.md
- MILESTONES.md
- TEST_REPORT
- RELEASE_NOTES
- RELEASE_CHECKLIST
- CITATION.cff
- docs/README.md
- docs/output_schema.md
- docs/benchmark_interpretation.md
- docs/hardware_pathway.md
- docs/implementation_layers.md

Project value:

    establishes a stable public software architecture release ready for citation, review, and staged implementation-layer development

## 16. Milestone Mapping

| Roadmap Stage | Project Milestone |
|---|---|
| Stage 0 — v0.9.3-mobile Repository Stabilization | M0 |
| Stage 1 — Archival Release and DOI | M1 |
| Stage 2 — v0.9.4 Structured Output | M2 |
| Stage 3 — v0.9.5 Extended Benchmark Layer | M3 |
| Stage 4 — FPGA Mapping Package | M4 |
| Stage 5 — ASIC Mapping Package | M5 |
| Stage 6 — Physical Validation Protocol | M6 |
| Stage 7 — Funding and Partner Package | M7 |
| Stage 8 — v1.0.0 Public Software Architecture Release | M8 |

Milestone document:

    MILESTONES.md

## 17. Review Package Path

Current review package files:

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

## 18. Release and Archival Path

Recommended archival sequence:

1. complete repository synchronization
2. confirm CI workflows passing
3. confirm README badges passing
4. confirm release checklist
5. confirm release notes
6. confirm CITATION.cff metadata
7. create GitHub release tag
8. create Zenodo archival release
9. obtain DOI
10. update CITATION.cff with DOI
11. update README with DOI badge
12. update CHANGELOG with DOI reference
13. prepare partner and funding package for external review

## 19. Documentation Alignment Rule

When a roadmap stage changes, review whether the following files require updates:

- README.md
- ROADMAP.md
- MILESTONES.md
- funding_brief.md
- PROJECT_STRUCTURE.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- CHANGELOG.md
- docs/README.md
- docs/output_schema.md
- docs/benchmark_interpretation.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- docs/physical_validation_plan.md
- REPRODUCIBILITY.md
- USAGE.md
- CI.md

Documentation should remain aligned with executable behavior, benchmark output, CI status, release readiness, milestones, funding structure, and current engineering trajectory.

## 20. Current Status

FRP v0.9.3-mobile currently establishes:

- public software validation layer
- reproducibility and benchmark layer
- CI verification layer
- documentation layer
- hardware-facing documentation pathway
- FPGA mapping study path
- ASIC mapping study path
- physical validation planning structure
- milestone structure
- funding and partner-facing brief

Current repository role:

    provide a validated public software reference package for staged engineering development, archival release preparation, hardware-facing specification planning, partner review, and funding preparation

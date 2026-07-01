# Milestones — Fractal Resonance Processor (FRP)

This document defines the staged project milestones for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

## 1. Purpose

The purpose of this document is to organize FRP development into concrete engineering milestones.

The milestone structure connects:

    software validation
    → archival release
    → structured output
    → expanded benchmark layer
    → FPGA mapping package
    → ASIC mapping package
    → physical validation protocol
    → funding and partner package
    → public software architecture release

Each milestone defines:

- objective
- current foundation
- deliverables
- acceptance criteria
- related files
- project value

This document can also be used as the basis for GitHub Milestones and project tracking.

## 2. Current Foundation

FRP v0.9.3-mobile establishes the public software validation layer.

Current validated assets:

- executable Python prototype
- balanced ternary state logic
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- standard self-test
- heavy self-test
- benchmark execution
- reproducibility commands
- GitHub Actions CI workflows
- documentation package
- hardware pathway document
- implementation layers document
- FPGA mapping study document
- ASIC mapping study document
- physical validation plan
- funding brief
- release checklist
- roadmap
- citation metadata
- Apache-2.0 license

Current candidate result:

    PASS

## 3. Milestone Overview

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

## 4. M0 — Repository Stabilization

Milestone ID:

    M0

Milestone name:

    Repository Stabilization

Objective:

    stabilize the current v0.9.3-mobile repository package before archival release

Current foundation:

- README.md
- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- ROADMAP.md
- PROJECT_STRUCTURE.md
- funding_brief.md
- documentation layer
- CI workflows

Deliverables:

- final README alignment
- final release notes alignment
- final release checklist alignment
- final project structure alignment
- final roadmap alignment
- final documentation index alignment
- confirmation of CI workflow status
- confirmation of README badge status
- final repository file name review

Acceptance criteria:

- both CI workflows passing
- README badges passing
- release checklist complete
- project structure reflects current file tree
- release notes reflect current repository package
- roadmap reflects current engineering trajectory
- documentation index includes current documentation files
- funding brief included in root package
- repository ready for release tagging

Related files:

- README.md
- PROJECT_STRUCTURE.md
- ROADMAP.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- docs/README.md
- funding_brief.md

Project value:

    establishes a clean public repository base for archival release and external review

## 5. M1 — Archival Release and DOI

Milestone ID:

    M1

Milestone name:

    Archival Release and DOI

Objective:

    create a citable archival release of FRP v0.9.3-mobile

Current foundation:

- stable repository package
- release notes
- release checklist
- citation metadata
- Apache-2.0 license
- Zenodo-ready repository structure

Deliverables:

- GitHub release tag
- GitHub release description
- Zenodo archival release
- DOI assignment
- updated CITATION.cff
- README DOI badge
- release record update
- archival metadata review

Acceptance criteria:

- GitHub release created
- Zenodo record created
- DOI assigned
- CITATION.cff updated
- README updated with DOI badge
- release notes aligned with archival release
- changelog updated with DOI reference

Related files:

- CITATION.cff
- README.md
- CHANGELOG.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md

Project value:

    makes the FRP software validation package citable, archive-ready, and externally referenceable

## 6. M2 — Structured Output

Milestone ID:

    M2

Milestone name:

    Structured Output

Target candidate:

    v0.9.4

Objective:

    add machine-readable output for testing, benchmark inspection, reproducibility, and external tooling

Current foundation:

- console output
- test report
- output schema documentation
- benchmark mode
- self-test mode
- CI workflow verification

Deliverables:

- JSON output mode
- machine-readable self-test summary
- machine-readable heavy self-test summary
- machine-readable benchmark summary
- structured telemetry export option
- optional CSV output
- updated output schema documentation
- updated usage documentation
- updated reproducibility documentation
- updated CI validation for structured output

Acceptance criteria:

- standard self-test produces structured summary
- benchmark mode produces structured summary
- JSON output fields match docs/output_schema.md
- CI validates structured output
- reproducibility commands updated
- test report updated for v0.9.4 candidate

Related files:

- frp_prototype_v0_9_3_mobile.py or next candidate prototype file
- docs/output_schema.md
- USAGE.md
- REPRODUCIBILITY.md
- CI.md
- TEST_REPORT
- RELEASE_NOTES
- CHANGELOG

Project value:

    improves external review, automated validation, benchmark reproducibility, and integration readiness

## 7. M3 — Extended Benchmark Layer

Milestone ID:

    M3

Milestone name:

    Extended Benchmark Layer

Target candidate:

    v0.9.5

Objective:

    expand the benchmark layer for stronger comparative analysis and reproducibility

Current foundation:

- current benchmark command
- benchmark summary table
- benchmark interpretation document
- candidate invariants
- CI benchmark smoke test

Deliverables:

- additional benchmark seeds
- additional vector sizes
- additional scheduler profiles
- extended distributed-neutral comparison
- transition debt summaries
- direct conflict fraction summaries
- heat trajectory summaries
- switch-load trajectory summaries
- coherence trajectory summaries
- benchmark export files
- benchmark profile guide
- updated benchmark interpretation

Acceptance criteria:

- benchmark profiles reproducible through documented commands
- benchmark exports generated consistently
- benchmark interpretation aligned with output
- CI runs benchmark smoke validation
- documentation reflects expanded benchmark layer
- release notes include benchmark expansion

Related files:

- frp prototype file
- TEST_REPORT
- docs/benchmark_interpretation.md
- docs/output_schema.md
- REPRODUCIBILITY.md
- USAGE.md
- CI.md
- RELEASE_NOTES
- CHANGELOG

Project value:

    strengthens comparative evidence and supports technical review by partners, labs, and funding reviewers

## 8. M4 — FPGA Mapping Package

Milestone ID:

    M4

Milestone name:

    FPGA Mapping Package

Objective:

    convert the validated FRP software reference behavior into an FPGA-oriented implementation package

Current foundation:

- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- software reference model
- candidate invariants
- benchmark output

Deliverables:

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
- FPGA deliverables documented
- partner review package includes FPGA mapping summary

Related files:

- docs/fpga_mapping_study.md
- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/physical_validation_plan.md
- funding_brief.md
- ROADMAP.md

Project value:

    creates the first programmable-hardware bridge from the software validation layer toward implementation-layer research

## 9. M5 — ASIC Mapping Package

Milestone ID:

    M5

Milestone name:

    ASIC Mapping Package

Objective:

    convert the validated FRP software reference behavior into chip-oriented architectural study

Current foundation:

- docs/hardware_pathway.md
- docs/implementation_layers.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- software reference model
- candidate invariants
- benchmark output

Deliverables:

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

- ASIC mapping references software behavior
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
- funding_brief.md
- ROADMAP.md

Project value:

    establishes a chip-oriented implementation research path grounded in the validated software reference layer

## 10. M6 — Physical Validation Protocol

Milestone ID:

    M6

Milestone name:

    Physical Validation Protocol

Objective:

    define how future physical FRP implementations can be measured and compared against the software reference model

Current foundation:

- docs/physical_validation_plan.md
- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- software reference model
- benchmark output
- candidate invariants

Deliverables:

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
- funding_brief.md

Project value:

    prepares FRP for measurable physical implementation review and laboratory collaboration

## 11. M7 — Funding and Partner Package

Milestone ID:

    M7

Milestone name:

    Funding and Partner Package

Objective:

    prepare FRP for engineering partner review, laboratory collaboration, grant review, or investor-facing technical evaluation

Current foundation:

- funding_brief.md
- README.md
- TEST_REPORT_v0_9_3.md
- ROADMAP.md
- MILESTONES.md
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan

Deliverables:

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

Acceptance criteria:

- funding brief complete
- milestones complete
- review package file list complete
- project value proposition clear
- engineering trajectory clear
- technical assets documented
- next resource needs documented

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

## 12. M8 — v1.0.0 Public Software Architecture Release

Milestone ID:

    M8

Milestone name:

    v1.0.0 Public Software Architecture Release

Objective:

    establish the first stable public software architecture release of FRP

Current foundation:

- v0.9.3-mobile software validation package
- planned structured output layer
- planned extended benchmark layer
- hardware-facing documentation pathway
- milestones and funding package

Candidate requirements:

- stable source layout
- stable command interface
- stable output schema
- stable benchmark profile
- stable documentation layer
- stable release checklist
- DOI-ready metadata
- complete citation metadata
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

## 13. Suggested GitHub Milestones

Suggested GitHub milestone names:

| GitHub Milestone | Related Project Milestone |
|---|---|
| v0.9.3 Repository Stabilization | M0 |
| v0.9.3 Archival Release and DOI | M1 |
| v0.9.4 Structured Output | M2 |
| v0.9.5 Extended Benchmark Layer | M3 |
| FPGA Mapping Package | M4 |
| ASIC Mapping Package | M5 |
| Physical Validation Protocol | M6 |
| Funding and Partner Package | M7 |
| v1.0.0 Public Software Architecture Release | M8 |

## 14. Suggested Issue Groups

Suggested issue groups:

| Issue Group | Purpose |
|---|---|
| repository-stabilization | final repository alignment |
| archival-release | release tag, Zenodo, DOI, citation metadata |
| structured-output | JSON, CSV, machine-readable summaries |
| benchmark-expansion | benchmark profiles, exports, interpretation |
| fpga-mapping | FPGA encoding, controller, scheduler, testbench |
| asic-mapping | ASIC cells, timing, telemetry, test interface |
| physical-validation | measurement protocol and validation categories |
| funding-package | partner brief, funding milestones, resource needs |
| v1-release | stable public software architecture release |

## 15. Milestone Tracking Rule

Each milestone should include:

- objective
- deliverables
- acceptance criteria
- related files
- current status
- assigned issues
- completion evidence

Each milestone should preserve traceability to the current software reference model and candidate invariants.

## 16. Current Status

The FRP milestone structure defines the staged engineering program from the current v0.9.3-mobile software validation package toward archival release, structured output, expanded benchmarks, FPGA mapping, ASIC mapping, physical validation, partner preparation, and v1.0.0 public software architecture release.

This document provides the project-level milestone framework for repository management, funding planning, engineering coordination, and GitHub milestone creation.

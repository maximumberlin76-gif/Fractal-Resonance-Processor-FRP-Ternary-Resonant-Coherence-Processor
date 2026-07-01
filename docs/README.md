# Documentation Layer — Fractal Resonance Processor (FRP)

This directory contains the public documentation layer for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## 1. Purpose

The purpose of this documentation layer is to make the current FRP repository reviewable, reproducible, inspectable, citable, and ready for staged engineering development.

The documentation layer explains:

- FRP core principles
- current architecture
- resonance computation
- benchmark interpretation
- output schema
- verification metrics
- repository structure
- release readiness
- roadmap structure
- milestone structure
- hardware-facing pathway
- implementation-layer structure
- FPGA mapping study
- ASIC mapping study
- physical validation planning
- funding and partner preparation

The current documentation package supports the transition from software validation toward hardware-facing specification, FPGA mapping, ASIC mapping, chip-oriented implementation research, physical validation planning, and partner or funding preparation.

## 2. Current Documentation Position

FRP v0.9.3-mobile establishes the public software validation layer of the project.

The current repository provides:

- executable Python source code
- reproducibility commands
- benchmark output
- automated CI workflows
- technical documentation
- release checklist
- roadmap
- milestones
- funding brief
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- citation metadata
- Apache-2.0 license

The current software layer has been executed and verified on general-purpose computing infrastructure.

This software validation layer provides the executable reference model for the next engineering layers.

## 3. Documentation Files

| File | Purpose |
|---|---|
| README.md | documentation layer index |
| core_principles.md | core FRP principles |
| resonance_computation.md | resonance computation explanation |
| architecture.md | FRP v0.9.3-mobile architecture |
| benchmark_interpretation.md | benchmark interpretation and evidence scope |
| limitations.md | current simulation evidence boundaries and scope notes |
| output_schema.md | console output fields, test markers, benchmark markers, CI checks, and future JSON output direction |
| hardware_pathway.md | path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| implementation_layers.md | layered structure from conceptual architecture through software execution, validation, CI, documentation, hardware-facing specification, FPGA/ASIC studies, physical validation, and funding preparation |
| fpga_mapping_study.md | FPGA-oriented mapping study from the validated software reference model toward programmable-hardware implementation planning |
| asic_mapping_study.md | ASIC-oriented mapping study from the validated software reference model toward chip-oriented implementation research |
| physical_validation_plan.md | physical validation planning structure for future measurement, benchmark repeatability, and comparison against the Python reference model |

## 4. Related Root Files

| File | Purpose |
|---|---|
| ../README.md | main public project overview |
| ../frp_prototype_v0_9_3_mobile.py | current executable Python prototype |
| ../TEST_REPORT_v0_9_3.md | current candidate test report |
| ../INSTALL.md | installation guide |
| ../USAGE.md | usage guide |
| ../REPRODUCIBILITY.md | reproducibility guide |
| ../CI.md | continuous integration documentation |
| ../PROJECT_STRUCTURE.md | repository structure guide |
| ../ROADMAP.md | staged project roadmap |
| ../MILESTONES.md | staged project milestones |
| ../funding_brief.md | partner and funding-facing technical brief |
| ../RELEASE_NOTES_v0_9_3.md | release notes for v0.9.3-mobile |
| ../RELEASE_CHECKLIST_v0_9_3.md | release readiness checklist |
| ../CHANGELOG.md | version history |
| ../CITATION.cff | citation metadata |
| ../LICENSE | Apache-2.0 license text |
| ../NOTICE | project notice |

## 5. Documentation Layer Structure

The current documentation layer is organized into the following groups.

### 5.1 Core Architecture Documents

| File | Role |
|---|---|
| core_principles.md | defines FRP state logic, neutral routing, distributed transition, coherence, and stability principles |
| resonance_computation.md | explains the resonance computation layer and phase-dynamic behavior |
| architecture.md | describes the current v0.9.3-mobile architecture |

### 5.2 Validation and Output Documents

| File | Role |
|---|---|
| benchmark_interpretation.md | explains benchmark behavior, comparative table interpretation, and evidence scope |
| limitations.md | documents the current simulation evidence scope and validation boundary |
| output_schema.md | defines output fields, test markers, benchmark markers, CI checks, and future structured-output direction |

### 5.3 Hardware-Facing Development Documents

| File | Role |
|---|---|
| hardware_pathway.md | defines the path from validated software behavior toward hardware-facing specification and implementation-layer work |
| implementation_layers.md | defines the staged implementation structure of FRP across software, validation, hardware-facing, FPGA, ASIC, physical validation, and funding layers |
| fpga_mapping_study.md | defines the FPGA-oriented mapping study |
| asic_mapping_study.md | defines the ASIC-oriented mapping study |
| physical_validation_plan.md | defines the physical validation planning structure |

### 5.4 Project Program Documents

| File | Role |
|---|---|
| ../ROADMAP.md | defines the staged development trajectory |
| ../MILESTONES.md | defines engineering milestones, deliverables, acceptance criteria, and suggested GitHub milestones |
| ../funding_brief.md | defines the partner and funding-facing technical brief |
| ../RELEASE_CHECKLIST_v0_9_3.md | defines the release readiness state |
| ../RELEASE_NOTES_v0_9_3.md | defines the current release candidate package |

## 6. Current Software Validation Layer

The current software validation layer includes:

- balanced ternary states: -1, 0, 1
- neutral transition routing
- direct polarity transition safety
- distributed commit
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay buffers
- scheduler modes
- per-tick telemetry
- register file
- processor instruction layer
- demonstration mode
- self-test mode
- benchmark mode
- command-line interface

Current validated execution path:

    Python source execution
    → reproducibility commands
    → benchmark execution
    → CI workflow execution
    → documented candidate result

## 7. Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants connect the executable software layer with verification, benchmark interpretation, CI, release readiness, hardware-facing mapping, and future implementation-layer work.

## 8. Engineering Trajectory

The FRP documentation layer follows the project engineering trajectory:

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

The current documentation package records the software validation layer and initiates the hardware-facing documentation path.

## 9. Hardware-Facing Documentation Path

The hardware-facing documentation path is currently represented by:

| File | Current Role |
|---|---|
| hardware_pathway.md | defines how the software validation layer supports hardware-facing specification and implementation-layer work |
| implementation_layers.md | defines the staged layer structure from software execution through hardware-facing, FPGA, ASIC, physical validation, and funding preparation |
| fpga_mapping_study.md | defines programmable-hardware mapping from the Python reference model toward FPGA-oriented implementation planning |
| asic_mapping_study.md | defines chip-oriented mapping from the Python reference model toward ASIC-level architectural study |
| physical_validation_plan.md | defines measurement, benchmark repeatability, telemetry comparison, and validation planning for future physical implementation stages |

## 10. Funding and Partner Documentation Path

The funding and partner documentation path is currently represented by:

| File | Current Role |
|---|---|
| ../funding_brief.md | translates the current software validation package and hardware-facing documentation pathway into a partner and funding-facing technical brief |
| ../MILESTONES.md | defines staged engineering milestones, deliverables, acceptance criteria, and project value |
| ../ROADMAP.md | defines the staged project trajectory and current engineering direction |

The funding and partner path connects current validated assets with implementation-layer milestones, resource planning, partner review, and funding-oriented technical presentation.

## 11. Release and Archival Documentation Path

The release and archival documentation path is represented by:

| File | Current Role |
|---|---|
| ../RELEASE_NOTES_v0_9_3.md | describes the v0.9.3-mobile release candidate package |
| ../RELEASE_CHECKLIST_v0_9_3.md | defines release readiness state |
| ../CHANGELOG.md | records version history |
| ../CITATION.cff | provides citation metadata |
| ../LICENSE | provides Apache-2.0 license text |
| ../NOTICE | provides project notice |
| ../README.md | provides the main public overview |

Current archival path:

    repository stabilization
    → GitHub release tag
    → Zenodo archival release
    → DOI assignment
    → CITATION.cff update
    → README DOI badge update

## 12. Documentation Update Rule

When the prototype, benchmark, release package, milestone structure, funding package, or engineering trajectory changes, review the following files:

- ../README.md
- ../TEST_REPORT_v0_9_3.md
- ../REPRODUCIBILITY.md
- ../USAGE.md
- ../CI.md
- ../PROJECT_STRUCTURE.md
- ../ROADMAP.md
- ../MILESTONES.md
- ../funding_brief.md
- ../RELEASE_NOTES_v0_9_3.md
- ../RELEASE_CHECKLIST_v0_9_3.md
- README.md
- architecture.md
- benchmark_interpretation.md
- output_schema.md
- hardware_pathway.md
- implementation_layers.md
- fpga_mapping_study.md
- asic_mapping_study.md
- physical_validation_plan.md
- ../verification/coherence_metrics.md

Documentation should remain aligned with executable behavior, benchmark output, CI status, release readiness, milestones, funding structure, and the current engineering path.

## 13. Current Documentation Status

The documentation layer currently includes:

- core FRP principles
- resonance computation explanation
- current architecture description
- benchmark interpretation
- simulation evidence scope notes
- output schema
- hardware pathway
- implementation layers
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- project roadmap reference
- milestone structure reference
- funding brief reference

Current status:

    active and aligned with FRP v0.9.3-mobile

Current documentation role:

    support repository review, reproducibility testing, benchmark inspection, CI verification, archival preparation, hardware-facing planning, FPGA and ASIC mapping study preparation, physical validation planning, milestone tracking, and funding or partner preparation

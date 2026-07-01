# Roadmap — Fractal Resonance Processor (FRP)

This roadmap describes the staged development path of the Fractal Resonance Processor (FRP) project after the v0.9.3-mobile candidate.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

## 1. Current Project Position

FRP v0.9.3-mobile establishes the public software validation layer of the Fractal Resonance Processor architecture.

The current repository provides:

- executable Python source code
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
- benchmark mode
- reproducibility commands
- GitHub Actions CI workflows
- documentation package
- release checklist
- project structure guide
- output schema documentation
- hardware pathway documentation
- implementation layers documentation
- citation metadata
- Apache-2.0 license

The current software layer has been executed and verified on general-purpose computing infrastructure through Python execution, benchmark runs, reproducibility commands, and automated CI workflows.

## 2. Engineering Trajectory

The FRP development trajectory is organized as:

    software validation
    → architecture stabilization
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning
    → partner and funding package

This roadmap treats the current software layer as the executable foundation for later hardware-facing and implementation-layer work.

## 3. v0.9.3-mobile — Current Candidate

Status:

    complete as public candidate software validation package

Purpose:

    establish a reproducible public software validation layer for FRP

Completed components:

- root README
- current Python prototype
- standard self-test
- heavy self-test
- benchmark execution
- test report
- installation guide
- usage guide
- reproducibility guide
- continuous integration documentation
- project structure guide
- release notes
- release checklist
- output schema documentation
- documentation layer
- verification layer
- example layer
- model and simulation background layer
- hardware pathway documentation
- implementation layers documentation
- Apache-2.0 license
- citation metadata
- notice file
- security policy
- contribution guide
- code of conduct
- GitHub Actions self-test workflow
- GitHub Actions benchmark smoke-test workflow

Current validated execution layer:

- local Python execution path
- reproducibility commands
- benchmark execution
- CI execution on general-purpose computing infrastructure

Current candidate result:

    PASS

## 4. Immediate Repository Stabilization

The next repository-level work is final stabilization before archival release.

Tasks:

- confirm both GitHub Actions workflows are passing
- confirm README badges are passing
- confirm repository file names are final
- confirm release notes are aligned with current repository state
- confirm release checklist is aligned with current repository state
- confirm CITATION.cff is accurate
- confirm PROJECT_STRUCTURE.md is aligned with current file tree
- confirm docs/README.md includes current documentation files
- confirm docs/hardware_pathway.md is linked from documentation indexes
- confirm docs/implementation_layers.md is linked from documentation indexes
- confirm documentation files are internally consistent
- confirm benchmark interpretation matches TEST_REPORT_v0_9_3.md
- confirm ROADMAP.md reflects the current engineering trajectory

Expected output:

    repository ready for GitHub release tag and archival packaging

## 5. v0.9.4 Target — Structured Output and Extended Reproducibility

Purpose:

    improve machine-readable output, reproducibility depth, and benchmark inspection

Candidate features:

- structured JSON output option
- machine-readable test summary
- machine-readable benchmark summary
- reproducibility profiles
- extended seed configuration
- expanded benchmark table export
- telemetry export mode
- optional CSV output
- stronger command-line output consistency
- documentation update for structured outputs

Expected files:

- updated prototype file or new candidate prototype file
- updated TEST_REPORT
- updated REPRODUCIBILITY.md
- updated USAGE.md
- updated docs/output_schema.md
- updated RELEASE_NOTES
- updated CHANGELOG

Expected validation:

- standard self-test passing
- heavy self-test passing
- benchmark smoke test passing
- JSON output validation
- CI workflow update

## 6. v0.9.5 Target — Expanded Benchmark Layer

Purpose:

    strengthen comparative analysis and benchmark reproducibility

Candidate features:

- additional benchmark seeds
- additional vector sizes
- additional scheduler comparisons
- extended distributed-neutral baseline comparison
- transition debt analysis
- direct conflict fraction analysis
- heat and switch-load trajectory summaries
- coherence trajectory summaries
- benchmark export files
- benchmark interpretation update

Expected validation:

- benchmark execution across multiple profiles
- stable target match
- stable direct transition safety
- documented C_minus_P behavior
- documented transition load behavior
- updated benchmark interpretation

## 7. v1.0.0 Target — Public Software Architecture Release

Purpose:

    establish the first stable public software architecture release of FRP

Candidate requirements:

- stable source layout
- stable command interface
- stable output schema
- stable benchmark profile
- stable documentation layer
- stable hardware-facing documentation pathway
- stable release checklist
- DOI-ready repository metadata
- complete citation metadata
- GitHub release tag
- archival release package

Expected public status:

    stable software validation release

Expected archival status:

    DOI-ready release package

## 8. Hardware-Facing Specification Layer

Purpose:

    translate the validated FRP software layer into hardware-facing architectural terms

Current foundation documents:

- docs/hardware_pathway.md
- docs/implementation_layers.md

Candidate future documents:

- docs/fpga_mapping_study.md
- docs/asic_mapping_study.md
- docs/physical_validation_plan.md
- docs/telemetry_mapping.md
- docs/benchmark_to_hardware_translation.md

Core topics:

- ternary state representation
- neutral transition routing in hardware-facing form
- distributed commit timing
- transition fraction as hardware scheduling constraint
- resonant phase layer mapping
- delay buffer mapping
- telemetry mapping
- C_minus_P metric translation
- switching-load interpretation
- benchmark-to-hardware translation assumptions
- physical validation requirements

Expected output:

    hardware-facing specification package

## 9. FPGA Mapping Study

Purpose:

    explore how FRP logic can be mapped into programmable hardware architecture

Candidate topics:

- ternary state encoding
- neutral routing logic
- distributed commit controller
- scheduler implementation
- register file representation
- phase layer approximation
- delay buffer implementation
- telemetry counters
- benchmark harness
- validation strategy on FPGA development boards

Expected output:

    FPGA mapping study document and prototype planning notes

## 10. ASIC Mapping Study

Purpose:

    explore chip-oriented implementation research for FRP architecture

Candidate topics:

- ternary logic cell representation
- transition-safe state machinery
- neutral routing gates
- distributed commit timing network
- resonant phase approximation
- local coherence tracking
- switching-load monitoring
- test harness design
- physical measurement planning
- fabrication-facing abstraction layer

Expected output:

    ASIC mapping study document and chip-oriented research plan

## 11. Physical Validation Planning

Purpose:

    define how future physical implementations can be evaluated

Candidate validation categories:

- logical correctness
- transition safety
- switching activity
- energy behavior
- thermal behavior
- timing behavior
- stability behavior
- noise response
- scheduler behavior
- benchmark repeatability
- telemetry consistency
- comparison against the software reference model

Expected output:

    physical validation protocol draft

## 12. Funding and Partner Package

Purpose:

    prepare the project for financing, engineering partnership, grant review, or laboratory collaboration

Candidate package:

- executive summary
- technical overview
- current validated assets
- software validation evidence
- CI evidence
- benchmark summary
- development trajectory
- hardware-facing pathway
- implementation layer structure
- required next resources
- engineering milestones
- risk and validation plan
- IP and licensing summary
- archival DOI reference after release

Core message:

    FRP already has a validated public software layer and a defined pathway toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning.

## 13. Documentation Growth Plan

Current hardware-facing documentation foundation:

- docs/hardware_pathway.md
- docs/implementation_layers.md

Future documentation may include:

- FPGA mapping study
- ASIC mapping study
- physical validation plan
- funding brief
- architecture diagrams
- benchmark profile guide
- structured output guide
- telemetry interpretation guide
- release process guide
- partner technical brief

Documentation rule:

    each document must describe the confirmed layer it belongs to and its relation to the next engineering layer

## 14. Release Process

Recommended release sequence:

1. stabilize current repository
2. confirm CI passing
3. confirm release checklist
4. create GitHub release tag
5. create Zenodo archival release
6. obtain DOI
7. update CITATION.cff
8. update README with DOI badge
9. prepare partner and funding package
10. open next development candidate

## 15. Current Priority

Current priority:

    final repository stabilization before archival release

Current synchronization files:

1. docs/README.md
2. PROJECT_STRUCTURE.md
3. RELEASE_CHECKLIST_v0_9_3.md
4. RELEASE_NOTES_v0_9_3.md
5. ROADMAP.md

Next engineering documents:

1. docs/fpga_mapping_study.md
2. docs/asic_mapping_study.md
3. docs/physical_validation_plan.md
4. funding_brief.md

## 16. Roadmap Status

FRP v0.9.3-mobile is ready as a public candidate software validation package with an initiated hardware-facing documentation pathway.

The project is positioned for:

- archival release preparation
- DOI registration
- expanded reproducibility work
- structured output development
- hardware-facing specification
- FPGA and ASIC mapping studies
- physical validation planning
- partner and funding preparation

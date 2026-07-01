# Funding Brief — Fractal Resonance Processor (FRP)

This document defines the funding and partner-facing brief for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Current test report:

    TEST_REPORT_v0_9_3.md

## 1. Executive Summary

Fractal Resonance Processor (FRP) is a ternary resonant coherence processor architecture.

The current public repository establishes a validated software reference layer for FRP.

This layer includes:

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
- reproducibility commands
- benchmark output
- automated CI verification
- hardware-facing documentation pathway

The current software layer has been executed and verified on general-purpose computing infrastructure.

This creates an engineering foundation for:

- hardware-facing specification
- FPGA mapping study
- ASIC mapping study
- chip-oriented implementation research
- physical validation planning
- laboratory collaboration
- engineering partnership
- grant or investor-facing technical review

## 2. Project Position

FRP v0.9.3-mobile establishes the public software validation package of the Fractal Resonance Processor architecture.

The current project position is:

    validated software reference model
    → documented hardware-facing pathway
    → FPGA and ASIC mapping study preparation
    → physical validation planning
    → partner and funding preparation

The current repository provides a reproducible technical basis for staged engineering development.

## 3. Current Validated Assets

Current validated assets include:

| Asset | Status |
|---|---|
| executable Python prototype | complete |
| standard self-test | complete |
| heavy self-test | complete |
| benchmark mode | complete |
| test report | complete |
| reproducibility guide | complete |
| usage guide | complete |
| installation guide | complete |
| output schema documentation | complete |
| CI self-test workflow | passing |
| CI benchmark smoke-test workflow | passing |
| hardware pathway document | complete |
| implementation layers document | complete |
| FPGA mapping study document | complete |
| ASIC mapping study document | complete |
| physical validation plan | complete |
| release checklist | complete |
| roadmap | complete |
| citation metadata | complete |
| Apache-2.0 license | complete |

## 4. Software Validation Evidence

The current reference model is:

    frp_prototype_v0_9_3_mobile.py

The current test report is:

    TEST_REPORT_v0_9_3.md

The software validation layer includes:

- Python source execution
- reproducibility commands
- standard self-test
- heavy self-test
- benchmark execution
- GitHub Actions workflow execution
- documented candidate invariants
- public repository documentation

The current candidate result is:

    PASS

## 5. Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants provide the first engineering bridge from software validation toward hardware-facing specification and physical validation planning.

## 6. Standard Self-Test Summary

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

## 7. Heavy Self-Test Summary

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

## 8. Benchmark Summary

Command:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

Benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

## 9. General-Purpose Hardware Execution

The FRP software layer has been executed and verified on general-purpose computing infrastructure.

Validated through:

- local Python execution path
- reproducibility commands
- benchmark execution
- GitHub Actions workflow execution
- CI status verification

Engineering meaning:

    The current software validation layer provides an executable reference model for hardware-facing specification and implementation-layer work.

## 10. Hardware-Facing Development Path

The FRP hardware-facing development path is organized as:

    software validation
    → architecture stabilization
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning
    → partner and funding package

Current hardware-facing documents:

| File | Role |
|---|---|
| docs/hardware_pathway.md | defines the path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| docs/implementation_layers.md | defines the staged layer structure of FRP |
| docs/fpga_mapping_study.md | defines the FPGA-oriented mapping study |
| docs/asic_mapping_study.md | defines the ASIC-oriented mapping study |
| docs/physical_validation_plan.md | defines the physical validation planning structure |

## 11. Funding Objective

The funding objective is to move FRP from validated software reference model toward implementation-layer research.

Funding can support:

- structured software output expansion
- extended benchmark profiles
- FPGA mapping work
- ASIC mapping work
- physical validation protocol development
- measurement planning
- partner review package preparation
- archival release preparation
- technical diagrams and implementation documentation
- engineering collaboration

## 12. Proposed Funding Milestones

### Milestone 1 — Repository and Archival Stabilization

Objective:

    prepare the public repository for archival release and DOI registration

Deliverables:

- final repository review
- GitHub release tag
- Zenodo archival release
- DOI assignment
- updated CITATION.cff
- README DOI badge
- release documentation finalization

### Milestone 2 — Structured Output and Extended Reproducibility

Objective:

    improve machine-readable verification and benchmark inspection

Deliverables:

- JSON output mode
- machine-readable self-test summary
- machine-readable benchmark summary
- telemetry export profile
- expanded reproducibility profiles
- updated output schema documentation
- updated CI workflow validation

### Milestone 3 — FPGA-Oriented Implementation Study

Objective:

    translate the software reference behavior into FPGA-oriented implementation planning

Deliverables:

- ternary state encoding proposal
- neutral transition controller proposal
- distributed commit scheduler proposal
- delay buffer mapping proposal
- phase approximation proposal
- telemetry register proposal
- FPGA testbench plan
- Python-reference comparison plan

### Milestone 4 — ASIC-Oriented Implementation Study

Objective:

    translate the software reference behavior into chip-oriented architectural study

Deliverables:

- ternary state representation proposal
- neutral routing cell proposal
- local transition controller proposal
- distributed commit timing proposal
- scheduler control proposal
- state storage proposal
- nonlinear response block proposal
- telemetry and test interface proposal
- ASIC testbench plan

### Milestone 5 — Physical Validation Protocol

Objective:

    define how future physical implementations can be measured and compared against the software reference model

Deliverables:

- validation protocol
- measurement setup structure
- benchmark repeatability plan
- timing measurement plan
- energy measurement plan
- thermal measurement plan
- telemetry comparison plan
- Python-reference comparison report structure

### Milestone 6 — Partner and Laboratory Package

Objective:

    prepare FRP for engineering partner review, laboratory collaboration, grant review, or investor-facing technical evaluation

Deliverables:

- executive summary
- technical overview
- current validated asset list
- benchmark evidence summary
- hardware-facing pathway summary
- FPGA and ASIC study summary
- physical validation plan summary
- resource request outline
- project timeline
- partner collaboration model

## 13. Resource Needs

Potential resource categories:

| Resource Category | Purpose |
|---|---|
| software engineering | structured output, reproducibility profiles, benchmark expansion |
| FPGA engineering | FPGA mapping, testbench planning, prototype study |
| ASIC architecture | chip-oriented mapping, cell abstraction, timing structure |
| measurement engineering | physical validation protocol, timing, energy, thermal measurement planning |
| documentation engineering | diagrams, technical briefs, release packaging |
| research collaboration | independent review, laboratory validation planning |
| legal and IP support | licensing review, patent strategy, collaboration agreements |
| archival support | DOI release, citation metadata, public research packaging |

## 14. Partner Profile

Relevant partner types:

- FPGA development teams
- ASIC architecture teams
- semiconductor research groups
- university laboratories
- applied computing research labs
- grant programs
- early-stage hardware incubators
- scientific computing partners
- technical investors
- prototype engineering partners

Partner review should focus on:

- validated software reference behavior
- reproducibility and CI evidence
- ternary transition logic
- neutral routing behavior
- distributed commit behavior
- benchmark output
- hardware-facing pathway
- implementation-layer roadmap
- physical validation plan

## 15. Technical Value Proposition

FRP provides:

- balanced ternary computation model
- neutral-state transition routing
- distributed transition commit
- resonant phase dynamics
- nonlinear saturation and compression
- operational coherence tracking
- benchmarkable software reference layer
- CI-verified reproducibility path
- documented FPGA and ASIC mapping path
- structured physical validation plan

The project value is based on a staged engineering path from executable software behavior toward implementation-layer research.

## 16. Review Package

A partner or funding review package should include:

- README.md
- funding_brief.md
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- RELEASE_CHECKLIST_v0_9_3.md
- ROADMAP.md
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

## 17. Funding-Facing Technical Message

Core message:

    FRP has a validated public software reference layer, reproducibility commands, benchmark output, CI verification, and a documented pathway toward FPGA mapping, ASIC mapping, chip-oriented implementation research, and physical validation planning.

Engineering message:

    The current repository package provides the executable reference model and documentation structure required for staged implementation-layer development.

Partner message:

    FRP is ready for technical review, engineering collaboration, FPGA/ASIC mapping discussion, physical validation planning, and funding-oriented milestone definition.

## 18. Current Status

FRP v0.9.3-mobile is ready as a public candidate software validation package.

The current funding brief provides:

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

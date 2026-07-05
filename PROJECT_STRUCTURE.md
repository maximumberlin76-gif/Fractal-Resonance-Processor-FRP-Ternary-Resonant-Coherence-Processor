# Project Structure — Fractal Resonance Processor (FRP)

This document describes the current public repository structure of the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current validation status:

`PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Repository Role

The repository preserves the complete published FRP architecture progression from the original executable balanced ternary reference layer through the current M15 implementation-mapping and qualification-closure layer.

The primary architecture chain is:

`balanced ternary computational kernel`

↓

`structured executable validation`

↓

`benchmark export and hardware signal mapping`

↓

`HDL trace and testbench preparation`

↓

`RTL interface and assertion contracts`

↓

`formal verification and equivalence scaffolds`

↓

`FPGA synthesis and timing structures`

↓

`production release and stable interface freeze`

↓

`silicon and heterogeneous implementation architecture`

↓

`silicon production and tapeout readiness`

↓

`production integration and external implementation handoff`

↓

`external feedback and production iteration`

↓

`production scaling and implementation stabilization`

↓

`physical implementation correlation and production qualification`

↓

`fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

↓

`cycle-exact integer reference traces`

↓

`RTL comparison-vector generation`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation`

↓

`qualification closure`

The comparative architecture benchmark suite remains a supporting validation contour.

It does not replace or redefine the FRP architecture chain.

## 2. Repository Root

The repository root contains:

- the current executable FRP reference file;
- historical executable reference files;
- current and historical validation records;
- release notes;
- validation indices;
- project-level documentation;
- reproducibility documentation;
- continuous integration documentation;
- citation and licensing metadata.

Current primary files:

| File | Purpose |
|---|---|
| `README.md` | main public project overview and current architecture layer |
| `frp_prototype_v1_7_0.py` | current FRP v1.7.0 executable reference file |
| `TEST_REPORT_v1_7_0.md` | current M15 validation record |
| `FRP_VALIDATION_INDEX_v1_7_0.md` | current M15 validation index |
| `RELEASE_NOTES_v1_7_0.md` | current release notes |
| `ROADMAP.md` | architecture progression through M15 and next planned M16 layer |
| `MILESTONES.md` | milestone chain from M0 through current M15 and planned M16 |
| `PROJECT_STRUCTURE.md` | repository structure guide |
| `CHANGELOG.md` | version history and release chronology |
| `INSTALL.md` | installation instructions |
| `USAGE.md` | usage and command reference |
| `REPRODUCIBILITY.md` | reproducibility instructions |
| `CI.md` | continuous integration documentation |
| `requirements.txt` | Python dependency list |
| `funding_brief.md` | partner and funding-facing technical brief |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | project notice |
| `SECURITY.md` | security policy |
| `CONTRIBUTING.md` | contribution guide |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `.gitignore` | ignored local files |

## 3. Current Executable Reference Layer

Current executable reference file:

`frp_prototype_v1_7_0.py`

Current architecture layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current executable reference preserves the validated FRP computational kernel and extends the M14 floating semantic reference into deterministic hardware-facing representation and correlation layers.

The M15 bridge is:

`M14 floating semantic reference`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation mapping`

↓

`qualification closure`

## 4. Preserved Computational Kernel

The current FRP reference architecture preserves the balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Mandatory opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Core invariant:

`actual_direct_events = 0`

Preserved scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Preserved transition control includes:

- transition-fraction control;
- deterministic request-lane ordering;
- bounded pending-neutral-route handling;
- reserved-state rejection.

## 5. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Validated invariant:

`reserved_state_events = 0`

## 6. Current M15 Artifact Layers

The current M15 executable reference defines ten implementation-mapping and qualification layers:

1. `fixed_point_interface_profile`;
2. `balanced_ternary_hardware_encoding_map`;
3. `quantized_reference_shadow_model`;
4. `cycle_exact_reference_trace`;
5. `rtl_comparison_vector_package`;
6. `systemverilog_testbench_interface_map`;
7. `synthesizable_rtl_reference_core`;
8. `rtl_assertion_correlation_harness`;
9. `reference_rtl_equivalence_report`;
10. `qualification_closure_manifest`.

These layers define the current published implementation-mapping boundary of the repository.

## 7. Executable Version Chain

The repository preserves the complete executable version chain.

| File | Architecture layer |
|---|---|
| `frp_prototype_v0_9_3_mobile.py` | original stabilized executable reference layer |
| `frp_prototype_v0_9_4.py` | structured output and machine-readable validation |
| `frp_prototype_v0_9_5.py` | benchmark export and hardware signal mapping |
| `frp_prototype_v0_9_6.py` | HDL trace export and testbench scaffold |
| `frp_prototype_v0_9_7.py` | RTL interface contract and assertion harness |
| `frp_prototype_v0_9_8.py` | formal verification hooks and equivalence scaffold |
| `frp_prototype_v0_9_9.py` | FPGA synthesis and timing constraint scaffold |
| `frp_prototype_v1_0_0.py` | production release and stable interface freeze |
| `frp_prototype_v1_1_0.py` | silicon and heterogeneous implementation architecture |
| `frp_prototype_v1_2_0.py` | silicon production and tapeout readiness |
| `frp_prototype_v1_3_0.py` | production integration and external implementation handoff |
| `frp_prototype_v1_4_0.py` | external implementation feedback and production iteration |
| `frp_prototype_v1_5_0.py` | production scaling and implementation stabilization |
| `frp_prototype_v1_6_0.py` | physical implementation correlation and production qualification |
| `frp_prototype_v1_7_0.py` | implementation mapping, domain interface, and qualification closure |

Historical executable files remain release-specific architecture records.

The current executable reference is:

`frp_prototype_v1_7_0.py`

## 8. Validation Record Chain

The repository preserves release-specific test reports from the initial validated layer through the current M15 release.

Test reports:

- `TEST_REPORT_v0_9_3.md`;
- `TEST_REPORT_v0_9_4.md`;
- `TEST_REPORT_v0_9_5.md`;
- `TEST_REPORT_v0_9_6.md`;
- `TEST_REPORT_v0_9_7.md`;
- `TEST_REPORT_v0_9_8.md`;
- `TEST_REPORT_v0_9_9.md`;
- `TEST_REPORT_v1_0_0.md`;
- `TEST_REPORT_v1_1_0.md`;
- `TEST_REPORT_v1_2_0.md`;
- `TEST_REPORT_v1_3_0.md`;
- `TEST_REPORT_v1_4_0.md`;
- `TEST_REPORT_v1_5_0.md`;
- `TEST_REPORT_v1_6_0.md`;
- `TEST_REPORT_v1_7_0.md`.

Current validation record:

`TEST_REPORT_v1_7_0.md`

Current validation status:

`PASS`

Current validated self-test check count:

`41/41`

## 9. Validation Index Chain

Validation indices are preserved for the architecture layers from M7 through M15.

Files:

- `FRP_VALIDATION_INDEX_v0_9_9.md`;
- `FRP_VALIDATION_INDEX_v1_0_0.md`;
- `FRP_VALIDATION_INDEX_v1_1_0.md`;
- `FRP_VALIDATION_INDEX_v1_2_0.md`;
- `FRP_VALIDATION_INDEX_v1_3_0.md`;
- `FRP_VALIDATION_INDEX_v1_4_0.md`;
- `FRP_VALIDATION_INDEX_v1_5_0.md`;
- `FRP_VALIDATION_INDEX_v1_6_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Historical validation indices remain release-specific records and are not current-state documents.

## 10. Release Record Chain

The repository preserves release notes for every published architecture layer.

Files:

- `RELEASE_NOTES_v0_9_3.md`;
- `RELEASE_NOTES_v0_9_4.md`;
- `RELEASE_NOTES_v0_9_5.md`;
- `RELEASE_NOTES_v0_9_6.md`;
- `RELEASE_NOTES_v0_9_7.md`;
- `RELEASE_NOTES_v0_9_8.md`;
- `RELEASE_NOTES_v0_9_9.md`;
- `RELEASE_NOTES_v1_0_0.md`;
- `RELEASE_NOTES_v1_1_0.md`;
- `RELEASE_NOTES_v1_2_0.md`;
- `RELEASE_NOTES_v1_3_0.md`;
- `RELEASE_NOTES_v1_4_0.md`;
- `RELEASE_NOTES_v1_5_0.md`;
- `RELEASE_NOTES_v1_6_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Historical release records remain preserved as historical source records.

The repository also preserves:

- `RELEASE_CHECKLIST_v0_9_3.md`;
- `FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md`.

## 11. Documentation Directory

Directory:

`docs/`

The `docs/` directory contains the public technical documentation layer.

### Core documentation

| File | Purpose |
|---|---|
| `docs/README.md` | documentation directory index |
| `docs/core_principles.md` | core FRP principles |
| `docs/resonance_computation.md` | resonance computation layer |
| `docs/architecture.md` | architecture documentation |
| `docs/benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `docs/limitations.md` | documented validation and evidence boundaries |
| `docs/output_schema.md` | output and machine-readable validation structure |

### Hardware-facing pathway documentation

| File | Purpose |
|---|---|
| `docs/hardware_pathway.md` | hardware-facing development pathway |
| `docs/implementation_layers.md` | staged implementation layers |
| `docs/fpga_mapping_study.md` | FPGA-oriented mapping study |
| `docs/asic_mapping_study.md` | ASIC-oriented mapping study |
| `docs/physical_validation_plan.md` | physical validation planning |

### M3 documentation

| File | Purpose |
|---|---|
| `docs/m3_validation_targets.md` | M3 validation targets |
| `docs/benchmark_matrix.md` | benchmark export structure |
| `docs/hardware_signal_mapping.md` | hardware-facing signal mapping |
| `docs/fpga_register_map_draft.md` | FPGA register-map draft |
| `docs/testbench_comparison_plan.md` | testbench comparison plan |

### M4 through M15 architecture documents

| File | Architecture layer |
|---|---|
| `docs/m4_hdl_trace_testbench.md` | M4 HDL Trace Export and Testbench Scaffold |
| `docs/m5_rtl_interface_assertion_harness.md` | M5 RTL Interface Contract and Assertion Harness |
| `docs/m6_formal_verification_equivalence.md` | M6 Formal Verification Hooks and Equivalence Scaffold |
| `docs/m7_fpga_synthesis_timing.md` | M7 FPGA Synthesis Package and Timing Constraint Scaffold |
| `docs/m8_production_release_package.md` | M8 Production Release Package and Stable Interface Freeze |
| `docs/m9_silicon_heterogeneous_architecture.md` | M9 Silicon and Heterogeneous Implementation Architecture |
| `docs/m10_silicon_production_tapeout_readiness.md` | M10 Silicon Production and Tapeout Readiness Package |
| `docs/m11_production_integration_external_handoff.md` | M11 Production Integration and External Implementation Handoff |
| `docs/m12_external_implementation_feedback_iteration.md` | M12 External Implementation Feedback and Production Iteration Loop |
| `docs/m13_production_scaling_implementation_stabilization.md` | M13 Production Scaling and Implementation Stabilization Package |
| `docs/m14_physical_implementation_correlation_production_qualification.md` | M14 Physical Implementation Correlation and Production Qualification Package |
| `docs/m15_implementation_mapping_domain_interface_qualification_closure.md` | current M15 Implementation Mapping, Domain Interface, and Qualification Closure Package |

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

The repository also preserves the root-level M5 companion document:

`m5_rtl_interface_assertion_harness.md`

## 12. Verification Directory

Directory:

`verification/`

Files:

| File | Purpose |
|---|---|
| `verification/README.md` | verification layer overview |
| `verification/coherence_metrics.md` | coherence and operational metric definitions |

The verification layer documents the interpretation of FRP execution and stability telemetry.

## 13. Examples Directory

Directory:

`examples/`

Files:

| File | Purpose |
|---|---|
| `examples/README.md` | examples overview |
| `examples/resonance_convergence_example.md` | resonance-convergence example |

The examples layer provides practical interpretation material for repository review.

## 14. Simulations Directory

Directory:

`simulations/`

Files:

| File | Purpose |
|---|---|
| `simulations/README.md` | simulation layer overview |
| `simulations/initial_kuramoto_result.md` | preliminary Kuramoto background result |

Simulation files remain supporting background material.

They do not replace the current executable reference, release-specific test reports, or validation indices.

## 15. Models Directory

Directory:

`models/`

Files:

| File | Purpose |
|---|---|
| `models/README.md` | model layer overview |
| `models/kuramoto_frp_background_model.md` | Kuramoto-type background model context |

Model files provide conceptual and mathematical background.

They remain distinct from the current executable FRP architecture layer.

## 16. Comparative Architecture Benchmark Directory

Directory:

`benchmarks/architecture_comparison/`

The comparative architecture benchmark suite is a supporting validation contour aligned with:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The suite compares:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The comparison uses:

`one deterministic semantic workload`

↓

`architecture-specific execution`

↓

`raw architecture event counters`

↓

`one common normalized cost model`

↓

`one common thermal proxy model`

↓

`machine-readable comparison matrix`

The benchmark suite is additive.

It does not modify the validated M15 computational kernel, M15 schemas, M15 qualification workflow, or M15 release boundary.

### Benchmark execution files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/run_architecture_comparison.py` | canonical comparative architecture benchmark runner |
| `benchmarks/architecture_comparison/run_hardware_sensitivity_comparison.py` | hardware-informed sensitivity comparison runner |
| `benchmarks/architecture_comparison/validate_hardware_sensitivity_profile.py` | hardware-sensitivity profile validator |

### Architecture reference files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/binary_synchronous_reference.py` | binary synchronous reference |
| `benchmarks/architecture_comparison/binary_clock_gated_reference.py` | binary clock-gated reference |
| `benchmarks/architecture_comparison/direct_ternary_reference.py` | direct ternary reference |
| `benchmarks/architecture_comparison/frp_v1_7_0_adapter.py` | FRP v1.7.0 benchmark adapter |

### Shared benchmark model files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/common_workload.py` | shared deterministic workload |
| `benchmarks/architecture_comparison/common_cost_model.py` | common normalized cost model |
| `benchmarks/architecture_comparison/common_thermal_model.py` | common thermal proxy model |

### Benchmark profiles

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/profiles/workload_profile_v1.json` | deterministic workload profile |
| `benchmarks/architecture_comparison/profiles/normalized_cost_profile_v1.json` | normalized cost profile |
| `benchmarks/architecture_comparison/profiles/thermal_proxy_profile_v1.json` | common thermal proxy profile |
| `benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json` | hardware-sensitivity cost profile |

### Calibration and coefficient provenance

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md` | hardware-cost calibration layer |
| `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md` | coefficient provenance map |

### Machine-readable comparison results

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/results/reference_comparison_seed_76.json` | canonical comparative architecture result |
| `benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json` | hardware-sensitivity comparison result |

The comparative benchmark suite does not define the project roadmap or milestone chain.

## 17. GitHub Actions Directory

Directory:

`.github/workflows/`

The repository contains CI workflows for the core executable reference, structured output, architecture milestones, and supporting comparative benchmark qualification.

### Core validation workflows

| Workflow | Purpose |
|---|---|
| `frp-self-test.yml` | standard FRP self-test |
| `frp-benchmark-smoke.yml` | benchmark smoke test |
| `frp-structured-output.yml` | structured output validation |

### Architecture milestone workflows

| Workflow | Architecture layer |
|---|---|
| `frp-m3-benchmark-signal-map.yml` | M3 Benchmark Export and Hardware Signal Mapping |
| `frp-m4-hdl-trace.yml` | M4 HDL Trace and Testbench |
| `frp-m5-rtl-assertion-harness.yml` | M5 RTL Interface and Assertion Harness |
| `frp-m6-formal-verification.yml` | M6 Formal Verification and Equivalence |
| `frp-m7-fpga-synthesis.yml` | M7 FPGA Synthesis and Timing |
| `frp-m8-production-release.yml` | M8 Production Release Package |
| `frp-m9-silicon-architecture.yml` | M9 Silicon and Heterogeneous Architecture |
| `frp-m10-silicon-production-tapeout.yml` | M10 Silicon Production and Tapeout Readiness |
| `frp-m11-production-integration-handoff.yml` | M11 Production Integration and External Handoff |
| `frp-m12-feedback-iteration.yml` | M12 External Implementation Feedback and Production Iteration |
| `frp-m13-production-scaling-stabilization.yml` | M13 Production Scaling and Implementation Stabilization |
| `frp-m14-physical-implementation-qualification.yml` | M14 Physical Implementation Correlation and Production Qualification |
| `frp-m15-implementation-mapping-qualification.yml` | current M15 Implementation Mapping and Qualification Closure |

### Comparative benchmark workflows

| Workflow | Purpose |
|---|---|
| `frp-architecture-comparison.yml` | canonical comparative architecture benchmark qualification |
| `frp-hardware-sensitivity-comparison.yml` | hardware-sensitivity comparison qualification |
| `frp-hardware-sensitivity-profile.yml` | hardware-sensitivity profile qualification |

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## 18. Current Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`5fd9a4f`

Validated workflow stack:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Current validation result:

`PASS`

Current M15 self-test check count:

`41/41`

Primary validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

## 19. Architecture Milestone Chain

The repository structure preserves the following architecture progression:

| Milestone | Version | Architecture layer | Status |
|---|---|---|---|
| M0 | v0.9.3-mobile | Repository Stabilization | Completed |
| M1 | v0.9.3 | Archival Release and DOI | Completed |
| M2 | v0.9.4 | Structured Output and Machine-Readable Validation | Completed |
| M3 | v0.9.5 | Benchmark Export and Hardware Signal Mapping | Completed |
| M4 | v0.9.6 | HDL Trace Export and Testbench Scaffold | Completed |
| M5 | v0.9.7 | RTL Interface Contract and Assertion Harness | Completed |
| M6 | v0.9.8 | Formal Verification Hooks and Equivalence Scaffold | Completed |
| M7 | v0.9.9 | FPGA Synthesis Package and Timing Constraint Scaffold | Completed |
| M8 | v1.0.0 | Production Release Package and Stable Interface Freeze | Completed |
| M9 | v1.1.0 | Silicon and Heterogeneous Implementation Architecture | Completed |
| M10 | v1.2.0 | Silicon Production and Tapeout Readiness Package | Completed |
| M11 | v1.3.0 | Production Integration and External Implementation Handoff | Completed |
| M12 | v1.4.0 | External Implementation Feedback and Production Iteration Loop | Completed |
| M13 | v1.5.0 | Production Scaling and Implementation Stabilization Package | Completed |
| M14 | v1.6.0 | Physical Implementation Correlation and Production Qualification Package | Completed |
| M15 | v1.7.0 | Implementation Mapping, Domain Interface, and Qualification Closure Package | Current validated layer |
| M16 | v1.8.0 | RTL Core Realization and Execution Semantics Package | Next planned layer |

Project-level architecture tracking is maintained in:

- `ROADMAP.md`;
- `MILESTONES.md`.

## 20. Reproducibility Layer

The current reproducibility chain is:

`INSTALL.md`

↓

`USAGE.md`

↓

`REPRODUCIBILITY.md`

↓

`CI.md`

↓

`current executable reference`

↓

`current test report`

↓

`current validation index`

The current executable reference is:

`frp_prototype_v1_7_0.py`

The current validation records are:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

Historical release-specific records remain preserved for architecture traceability.

## 21. Release and Metadata Layer

Release and repository metadata files include:

| File | Purpose |
|---|---|
| `CHANGELOG.md` | version chronology |
| `ROADMAP.md` | architecture progression |
| `MILESTONES.md` | milestone structure |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | project notice |
| `SECURITY.md` | security policy |
| `CONTRIBUTING.md` | contribution guide |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `funding_brief.md` | partner and funding-facing technical brief |

Historical test reports, release notes, validation indices, and release manifests are preserved as release-specific records.

## 22. Repository Naming Discipline

Active project name:

`FRP — Fractal Resonance Processor`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Historical files must retain their historical version identity.

They must not be rewritten as current-state files.

## 23. Repository Alignment Rule

When the current architecture layer changes, review the following files for version, milestone, validation, path, and architecture-boundary alignment:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CHANGELOG.md`;
- `CI.md`;
- `REPRODUCIBILITY.md`;
- `USAGE.md`;
- current `TEST_REPORT`;
- current `RELEASE_NOTES`;
- current `FRP_VALIDATION_INDEX`;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

Historical release records must remain historical.

The comparative architecture benchmark suite must remain a supporting validation contour and must not replace the FRP architecture progression.

## 24. Current Repository Structure

The current public repository contains:

- the complete executable FRP version chain from v0.9.3-mobile through v1.7.0;
- the current FRP v1.7.0 M15 executable reference;
- release-specific test reports;
- release-specific release notes;
- validation indices through M15;
- M3 through M15 architecture documentation;
- structured output validation;
- hardware-facing signal mapping;
- HDL and testbench preparation;
- RTL interface and assertion layers;
- formal verification and equivalence scaffolds;
- FPGA synthesis and timing structures;
- stable production release packaging;
- silicon and heterogeneous implementation architecture;
- tapeout-readiness structures;
- external implementation handoff structures;
- production iteration and stabilization layers;
- physical implementation correlation and qualification;
- fixed-point implementation mapping;
- balanced ternary hardware encoding;
- quantized hardware shadow execution;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- qualification closure;
- reproducibility documentation;
- GitHub Actions validation;
- comparative architecture benchmark support;
- hardware-sensitivity qualification;
- documentation, verification, examples, simulations, and model layers;
- citation and licensing metadata.

## 25. Current Status

The repository is aligned with:

`FRP v1.7.0`

Current architecture layer:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current validation status:

`PASS`

Current repository role:

`preserve and extend the validated Fractal Resonance Processor reference architecture from the balanced ternary computational kernel through deterministic hardware-facing implementation mapping, cycle-exact reference execution, RTL correlation, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

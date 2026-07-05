# Roadmap — Fractal Resonance Processor (FRP)

This roadmap defines the staged architecture progression of the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current validation status:

`PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Purpose

The purpose of this roadmap is to preserve the actual FRP architecture trajectory from the executable balanced ternary reference layer through implementation mapping, domain interfaces, deterministic quantized execution, RTL correlation, and qualification closure.

The primary project path is:

`balanced ternary computational kernel`

↓

`structured executable validation`

↓

`hardware-facing signal and trace layers`

↓

`RTL, formal, and FPGA-facing contracts`

↓

`production release and stable interface freeze`

↓

`silicon and heterogeneous implementation architecture`

↓

`tapeout, production integration, and external implementation handoff`

↓

`production iteration and stabilization`

↓

`physical implementation correlation and qualification`

↓

`fixed-point implementation mapping and qualification closure`

↓

`RTL core realization and execution semantics`

Comparative benchmark work remains a supporting validation contour. It does not replace or redefine the FRP architecture progression.

## 2. Current Architecture Layer

FRP v1.7.0 establishes the M15 Implementation Mapping, Domain Interface, and Qualification Closure Package layer of the Fractal Resonance Processor reference architecture.

The current M15 bridge is:

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

## 3. Preserved Computational Kernel

FRP v1.7.0 preserves the validated balanced ternary computational kernel.

State domain:

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

Preserved scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Preserved transition control:

- transition-fraction control;
- deterministic request-lane ordering;
- bounded pending-neutral-route queue handling;
- reserved-state rejection.

Core validated invariant:

`actual_direct_events = 0`

## 4. Current M15 Artifact Layers

FRP v1.7.0 defines ten M15 artifact layers:

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

These layers define the current implementation-mapping and qualification-closure boundary of the published FRP reference architecture.

## 5. Current Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validated environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`5fd9a4f`

Validated workflow stack:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Validated M15 self-test check count:

`41`

All internal M15 self-test checks:

`True`

Validation result:

`PASS`

Primary validation records:

- `TEST_REPORT_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## 6. Completed Architecture Progression

| Milestone | Version | Architecture layer | Status |
|---|---|---|---|
| M0 | v0.9.3-mobile | Repository stabilization | Completed |
| M1 | v0.9.3 release path | Archival release and DOI | Completed |
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

Historical release notes, test reports, and validation indices remain the release-specific source records for each completed layer.

## 7. Architecture Progression Through M15

The validated FRP architecture progression now includes:

`production reference prototype`

↓

`stable production release package`

↓

`stable interface freeze`

↓

`silicon interface model`

↓

`heterogeneous implementation map`

↓

`compute fabric mapping`

↓

`memory/register interface map`

↓

`clock/reset domain map`

↓

`signal pipeline architecture`

↓

`accelerator integration profile`

↓

`FPGA-to-silicon migration path`

↓

`silicon production readiness manifest`

↓

`tapeout readiness checklist`

↓

`production integration and external implementation handoff`

↓

`external implementation feedback and production iteration`

↓

`production scaling and implementation stabilization`

↓

`hierarchical ultrametric topology model`

↓

`multiscale phase-coherence map`

↓

`cluster-local thermal field`

↓

`physical-domain correlation package`

↓

`fixed-point interface profile`

↓

`balanced ternary hardware encoding map`

↓

`quantized reference shadow model`

↓

`cycle-exact reference trace`

↓

`RTL comparison vector package`

↓

`SystemVerilog testbench interface map`

↓

`synthesizable RTL reference-core map`

↓

`RTL assertion correlation harness`

↓

`reference RTL equivalence report`

↓

`qualification closure manifest`

## 8. Comparative Benchmark Role

The comparative architecture benchmark suite is a supporting validation layer.

Its role is to provide reproducible comparison profiles and sensitivity analysis without replacing the FRP architecture chain.

Current benchmark contours remain separated:

- the original v0.9.3 thermal benchmark;
- the current comparative architecture benchmark suite;
- the hardware-informed sensitivity qualification layer.

The comparative benchmark layer is not an architecture milestone and does not alter the M0–M16 release progression.

Related repository paths:

- `benchmarks/architecture_comparison/`;
- `.github/workflows/frp-architecture-comparison.yml`;
- `.github/workflows/frp-hardware-sensitivity-comparison.yml`;
- `.github/workflows/frp-hardware-sensitivity-profile.yml`.

## 9. Current M15 Release Files

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current executable reference file:

`frp_prototype_v1_7_0.py`

Current validation workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current release-facing records:

- `TEST_REPORT_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## 10. Next Architecture Layer

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

The current repository defines this as the next architecture boundary after M15 qualification closure.

## 11. Repository Alignment Rule

When the current architecture layer changes, review the following files for version, milestone, validation, and architecture-boundary alignment:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CHANGELOG.md`;
- `CI.md`;
- `REPRODUCIBILITY.md`;
- current `TEST_REPORT`;
- current `RELEASE_NOTES`;
- current `FRP_VALIDATION_INDEX`;
- current architecture document;
- current milestone workflow.

Historical release records must remain historical and must not be rewritten as current-state documents.

## 12. Current Status

FRP v1.7.0 currently establishes:

- the M15 implementation-mapping layer;
- deterministic hardware-facing numeric representations;
- balanced ternary hardware encoding;
- stateful quantized hardware shadow execution;
- cycle-exact reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation mapping;
- floating semantic reference-to-quantized shadow correlation;
- exact deterministic quantized shadow replay;
- qualification closure.

Current repository role:

`preserve and extend the validated Fractal Resonance Processor reference architecture from the balanced ternary computational kernel through implementation mapping, deterministic hardware-facing execution, RTL correlation, and qualification closure`

Next architecture target:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

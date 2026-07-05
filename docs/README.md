# Documentation Layer — Fractal Resonance Processor (FRP)

This directory contains the public technical documentation layer of the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`../frp_prototype_v1_7_0.py`

Current test report:

`../TEST_REPORT_v1_7_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`../RELEASE_NOTES_v1_7_0.md`

Current validation status:

`PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Purpose

The documentation layer preserves the published FRP architecture progression and provides the technical reference surface for:

- computational principles;
- architecture interpretation;
- executable validation;
- structured machine-readable output;
- benchmark interpretation;
- hardware-facing signal mapping;
- HDL and testbench preparation;
- RTL interface definition;
- assertion and equivalence contracts;
- FPGA implementation mapping;
- silicon and heterogeneous implementation architecture;
- tapeout-readiness structure;
- production integration and implementation handoff;
- production scaling and stabilization;
- physical implementation correlation;
- fixed-point implementation mapping;
- quantized hardware shadow execution;
- cycle-exact integer reference traces;
- RTL comparison vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- qualification closure;
- reproducibility;
- release and validation traceability.

The documentation directory contains both current architecture documents and historical version-specific documents.

Historical documents preserve the architecture layer to which they belong.

They are not rewritten as current-state documents.

## 2. Current Documentation Position

The current published architecture layer is:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

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

The current primary architecture document is:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

The current executable reference is:

`../frp_prototype_v1_7_0.py`

The current validation records are:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

## 3. Preserved Computational Kernel

The current FRP architecture preserves the validated balanced ternary computational kernel.

Balanced ternary state domain:

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

Core validated invariant:

`actual_direct_events = 0`

Preserved scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Preserved execution controls include:

- transition-fraction control;
- deterministic request-lane ordering;
- bounded pending-neutral-route handling;
- reserved-state rejection.

## 4. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Validated invariant:

`reserved_state_events = 0`

## 5. Current M15 Documentation Boundary

FRP v1.7.0 defines ten M15 implementation-mapping and qualification layers:

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

Primary M15 documentation:

| File | Purpose |
|---|---|
| `m15_implementation_mapping_domain_interface_qualification_closure.md` | current M15 architecture, implementation-mapping, interface, correlation, and qualification-closure document |

Related current root records:

| File | Purpose |
|---|---|
| `../frp_prototype_v1_7_0.py` | current executable reference |
| `../TEST_REPORT_v1_7_0.md` | current M15 validation record |
| `../FRP_VALIDATION_INDEX_v1_7_0.md` | current M15 validation index |
| `../RELEASE_NOTES_v1_7_0.md` | current release notes |
| `../README.md` | main public project overview |

## 6. Documentation Directory Map

### 6.1 Core and Foundation Documents

| File | Role |
|---|---|
| `core_principles.md` | foundational FRP operating principles |
| `resonance_computation.md` | resonance-based computation interpretation |
| `architecture.md` | original architecture-layer record |
| `limitations.md` | version-specific evidence and scope boundaries |
| `benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `output_schema.md` | structured-output and machine-readable validation schema layer |

These documents preserve their original version-specific context where applicable.

The current architecture state is defined by the current executable reference, current M15 architecture document, current test report, current validation index, and current release notes.

### 6.2 Hardware-Facing Pathway Documents

| File | Role |
|---|---|
| `hardware_pathway.md` | early hardware-facing development pathway |
| `implementation_layers.md` | staged implementation-layer structure |
| `fpga_mapping_study.md` | FPGA-oriented mapping study |
| `asic_mapping_study.md` | ASIC-oriented mapping study |
| `physical_validation_plan.md` | physical validation planning structure |

These documents preserve the early hardware-facing planning layer from which the later milestone chain developed.

### 6.3 M3 — Benchmark Export and Hardware Signal Mapping

| File | Role |
|---|---|
| `m3_validation_targets.md` | M3 validation targets |
| `benchmark_matrix.md` | structured benchmark export |
| `hardware_signal_mapping.md` | hardware-facing signal mapping |
| `fpga_register_map_draft.md` | FPGA register-map draft |
| `testbench_comparison_plan.md` | testbench comparison plan |

Version:

`FRP v0.9.5`

Status:

`Completed`

### 6.4 M4 — HDL Trace Export and Testbench Scaffold

Primary document:

`m4_hdl_trace_testbench.md`

Version:

`FRP v0.9.6`

Architecture layer:

`HDL Trace Export and Testbench Scaffold`

Status:

`Completed`

### 6.5 M5 — RTL Interface Contract and Assertion Harness

Primary document:

`m5_rtl_interface_assertion_harness.md`

Version:

`FRP v0.9.7`

Architecture layer:

`RTL Interface Contract and Assertion Harness`

Status:

`Completed`

### 6.6 M6 — Formal Verification Hooks and Equivalence Scaffold

Primary document:

`m6_formal_verification_equivalence.md`

Version:

`FRP v0.9.8`

Architecture layer:

`Formal Verification Hooks and Equivalence Scaffold`

Status:

`Completed`

### 6.7 M7 — FPGA Synthesis Package and Timing Constraint Scaffold

Primary document:

`m7_fpga_synthesis_timing.md`

Version:

`FRP v0.9.9`

Architecture layer:

`FPGA Synthesis Package and Timing Constraint Scaffold`

Status:

`Completed`

### 6.8 M8 — Production Release Package and Stable Interface Freeze

Primary document:

`m8_production_release_package.md`

Version:

`FRP v1.0.0`

Architecture layer:

`Production Release Package and Stable Interface Freeze`

Status:

`Completed`

### 6.9 M9 — Silicon and Heterogeneous Implementation Architecture

Primary document:

`m9_silicon_heterogeneous_architecture.md`

Version:

`FRP v1.1.0`

Architecture layer:

`Silicon and Heterogeneous Implementation Architecture`

Status:

`Completed`

### 6.10 M10 — Silicon Production and Tapeout Readiness Package

Primary document:

`m10_silicon_production_tapeout_readiness.md`

Version:

`FRP v1.2.0`

Architecture layer:

`Silicon Production and Tapeout Readiness Package`

Status:

`Completed`

### 6.11 M11 — Production Integration and External Implementation Handoff

Primary document:

`m11_production_integration_external_handoff.md`

Version:

`FRP v1.3.0`

Architecture layer:

`Production Integration and External Implementation Handoff`

Status:

`Completed`

### 6.12 M12 — External Implementation Feedback and Production Iteration Loop

Primary document:

`m12_external_implementation_feedback_iteration.md`

Version:

`FRP v1.4.0`

Architecture layer:

`External Implementation Feedback and Production Iteration Loop`

Status:

`Completed`

### 6.13 M13 — Production Scaling and Implementation Stabilization Package

Primary document:

`m13_production_scaling_implementation_stabilization.md`

Version:

`FRP v1.5.0`

Architecture layer:

`Production Scaling and Implementation Stabilization Package`

Status:

`Completed`

### 6.14 M14 — Physical Implementation Correlation and Production Qualification Package

Primary document:

`m14_physical_implementation_correlation_production_qualification.md`

Version:

`FRP v1.6.0`

Architecture layer:

`Physical Implementation Correlation and Production Qualification Package`

Status:

`Completed`

### 6.15 M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package

Primary document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Version:

`FRP v1.7.0`

Architecture layer:

`Implementation Mapping, Domain Interface, and Qualification Closure Package`

Status:

`Current validated layer`

## 7. Architecture Progression

The documentation layer preserves the following architecture chain:

`balanced ternary computational kernel`

↓

`structured machine-readable validation`

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

`external implementation feedback and production iteration`

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

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation`

↓

`qualification closure`

## 8. Related Root Documentation

| File | Purpose |
|---|---|
| `../README.md` | main public project overview |
| `../ROADMAP.md` | architecture progression through the current layer and next planned layer |
| `../MILESTONES.md` | milestone chain |
| `../PROJECT_STRUCTURE.md` | repository structure |
| `../CHANGELOG.md` | version and release chronology |
| `../INSTALL.md` | installation instructions |
| `../USAGE.md` | usage and command reference |
| `../REPRODUCIBILITY.md` | reproducibility instructions |
| `../CI.md` | continuous integration documentation |
| `../funding_brief.md` | partner and funding-facing technical brief |
| `../CITATION.cff` | citation metadata |
| `../LICENSE` | Apache License 2.0 |
| `../NOTICE` | project notice |

## 9. Release and Validation Record Chain

The repository preserves release-specific validation records for the complete executable architecture progression.

Current records:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

Historical records remain preserved for their corresponding release layers.

Historical test reports:

- `../TEST_REPORT_v0_9_3.md`;
- `../TEST_REPORT_v0_9_4.md`;
- `../TEST_REPORT_v0_9_5.md`;
- `../TEST_REPORT_v0_9_6.md`;
- `../TEST_REPORT_v0_9_7.md`;
- `../TEST_REPORT_v0_9_8.md`;
- `../TEST_REPORT_v0_9_9.md`;
- `../TEST_REPORT_v1_0_0.md`;
- `../TEST_REPORT_v1_1_0.md`;
- `../TEST_REPORT_v1_2_0.md`;
- `../TEST_REPORT_v1_3_0.md`;
- `../TEST_REPORT_v1_4_0.md`;
- `../TEST_REPORT_v1_5_0.md`;
- `../TEST_REPORT_v1_6_0.md`;
- `../TEST_REPORT_v1_7_0.md`.

Historical release notes:

- `../RELEASE_NOTES_v0_9_3.md`;
- `../RELEASE_NOTES_v0_9_4.md`;
- `../RELEASE_NOTES_v0_9_5.md`;
- `../RELEASE_NOTES_v0_9_6.md`;
- `../RELEASE_NOTES_v0_9_7.md`;
- `../RELEASE_NOTES_v0_9_8.md`;
- `../RELEASE_NOTES_v0_9_9.md`;
- `../RELEASE_NOTES_v1_0_0.md`;
- `../RELEASE_NOTES_v1_1_0.md`;
- `../RELEASE_NOTES_v1_2_0.md`;
- `../RELEASE_NOTES_v1_3_0.md`;
- `../RELEASE_NOTES_v1_4_0.md`;
- `../RELEASE_NOTES_v1_5_0.md`;
- `../RELEASE_NOTES_v1_6_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

Validation indices are preserved from M7 through M15.

Current validation index:

`../FRP_VALIDATION_INDEX_v1_7_0.md`

## 10. Comparative Benchmark Support

The comparative architecture benchmark suite is a supporting validation contour.

It does not replace the FRP architecture chain.

Directory:

`../benchmarks/architecture_comparison/`

Compared architecture references:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Supporting benchmark structure:

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

Primary benchmark files:

- `../benchmarks/architecture_comparison/run_architecture_comparison.py`;
- `../benchmarks/architecture_comparison/run_hardware_sensitivity_comparison.py`;
- `../benchmarks/architecture_comparison/common_workload.py`;
- `../benchmarks/architecture_comparison/common_cost_model.py`;
- `../benchmarks/architecture_comparison/common_thermal_model.py`;
- `../benchmarks/architecture_comparison/frp_v1_7_0_adapter.py`.

Machine-readable result files:

- `../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`;
- `../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`.

The comparative benchmark layer remains additive and separate from the primary FRP milestone progression.

## 11. Continuous Integration Documentation Path

Current core validation workflows:

- `../.github/workflows/frp-self-test.yml`;
- `../.github/workflows/frp-benchmark-smoke.yml`;
- `../.github/workflows/frp-structured-output.yml`.

Current milestone workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

The repository also preserves milestone workflows for M3 through M14.

Supporting comparative benchmark workflows:

- `../.github/workflows/frp-architecture-comparison.yml`;
- `../.github/workflows/frp-hardware-sensitivity-comparison.yml`;
- `../.github/workflows/frp-hardware-sensitivity-profile.yml`.

## 12. Documentation Traceability Rule

The documentation layer must preserve traceability between:

`architecture layer`

↓

`executable reference`

↓

`machine-readable artifacts`

↓

`test report`

↓

`validation index`

↓

`release notes`

↓

`workflow validation`

When the current architecture layer changes, review:

- `../README.md`;
- `../ROADMAP.md`;
- `../MILESTONES.md`;
- `../PROJECT_STRUCTURE.md`;
- `../CHANGELOG.md`;
- `../CI.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- current executable reference;
- current test report;
- current release notes;
- current validation index;
- current architecture document;
- current milestone workflow;
- `README.md`.

Historical release records must remain historical.

Version-specific foundation documents must not be silently rewritten as current-state records.

The comparative benchmark suite must remain a supporting validation contour and must not replace the FRP architecture progression.

## 13. Current Documentation Status

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current architecture document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`../TEST_REPORT_v1_7_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`../RELEASE_NOTES_v1_7_0.md`

Current validation result:

`PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Current documentation role:

`preserve the complete published FRP technical documentation chain from the foundational balanced ternary architecture through deterministic hardware-facing implementation mapping, cycle-exact reference execution, RTL correlation, and qualification closure`

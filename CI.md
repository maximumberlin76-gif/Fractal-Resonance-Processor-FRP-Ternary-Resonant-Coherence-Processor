# CI — Fractal Resonance Processor (FRP)

This document defines the Continuous Integration validation structure of the Fractal Resonance Processor (FRP) repository.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current release validation status:

`PASS`

Current release validation record:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

## 1. Purpose

The FRP Continuous Integration layer preserves validation traceability across the complete published architecture progression.

The repository CI structure contains:

- foundational executable validation;
- foundational benchmark smoke validation;
- structured machine-readable output validation;
- release-specific architecture milestone validation;
- current M15 implementation-mapping qualification;
- comparative architecture benchmark qualification;
- hardware-sensitivity profile qualification;
- hardware-sensitivity comparison qualification.

The current release-validation boundary is:

`FRP v1.7.0`

↓

`M15 implementation mapping`

↓

`fixed-point interface validation`

↓

`balanced ternary hardware encoding validation`

↓

`quantized hardware shadow validation`

↓

`cycle-exact reference-trace validation`

↓

`RTL comparison-vector validation`

↓

`SystemVerilog interface validation`

↓

`RTL assertion correlation`

↓

`reference RTL equivalence validation`

↓

`qualification closure`

Historical workflows remain bound to the release-specific executable files they were created to validate.

They are not rewritten as current-release workflows.

## 2. CI Layering Rule

The repository contains three distinct CI roles.

### 2.1 Foundational validation

These workflows preserve the original executable, benchmark, and structured-output validation layers:

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

They remain attached to their historical executable references.

### 2.2 Architecture milestone validation

These workflows preserve the architecture progression from M3 through the current M15 layer.

Each milestone workflow validates its own release-specific executable reference and architecture package.

### 2.3 Supporting comparative validation

These workflows validate the separate comparative architecture benchmark and hardware-sensitivity layers.

They are supporting validation contours.

They do not define or replace the primary FRP architecture progression.

## 3. Workflow Inventory

The repository contains 19 GitHub Actions workflows.

### Foundational workflows

| Workflow file | Workflow name | Validation role |
|---|---|---|
| `.github/workflows/frp-self-test.yml` | FRP Self Test | foundational executable self-test |
| `.github/workflows/frp-benchmark-smoke.yml` | FRP Benchmark Smoke Test | foundational benchmark smoke validation |
| `.github/workflows/frp-structured-output.yml` | FRP Structured Output | M2 structured-output validation |

### Architecture milestone workflows

| Workflow file | Architecture layer |
|---|---|
| `.github/workflows/frp-m3-benchmark-signal-map.yml` | M3 Benchmark Export and Hardware Signal Mapping |
| `.github/workflows/frp-m4-hdl-trace.yml` | M4 HDL Trace Export and Testbench Scaffold |
| `.github/workflows/frp-m5-rtl-assertion-harness.yml` | M5 RTL Interface Contract and Assertion Harness |
| `.github/workflows/frp-m6-formal-verification.yml` | M6 Formal Verification Hooks and Equivalence Scaffold |
| `.github/workflows/frp-m7-fpga-synthesis.yml` | M7 FPGA Synthesis Package and Timing Constraint Scaffold |
| `.github/workflows/frp-m8-production-release.yml` | M8 Production Release Package and Stable Interface Freeze |
| `.github/workflows/frp-m9-silicon-architecture.yml` | M9 Silicon and Heterogeneous Implementation Architecture |
| `.github/workflows/frp-m10-silicon-production-tapeout.yml` | M10 Silicon Production and Tapeout Readiness Package |
| `.github/workflows/frp-m11-production-integration-handoff.yml` | M11 Production Integration and External Implementation Handoff |
| `.github/workflows/frp-m12-feedback-iteration.yml` | M12 External Implementation Feedback and Production Iteration Loop |
| `.github/workflows/frp-m13-production-scaling-stabilization.yml` | M13 Production Scaling and Implementation Stabilization Package |
| `.github/workflows/frp-m14-physical-implementation-qualification.yml` | M14 Physical Implementation Correlation and Production Qualification Package |
| `.github/workflows/frp-m15-implementation-mapping-qualification.yml` | current M15 Implementation Mapping and Qualification Closure |

### Supporting comparative workflows

| Workflow file | Validation role |
|---|---|
| `.github/workflows/frp-architecture-comparison.yml` | comparative architecture benchmark qualification |
| `.github/workflows/frp-hardware-sensitivity-comparison.yml` | hardware-sensitivity comparison qualification |
| `.github/workflows/frp-hardware-sensitivity-profile.yml` | hardware-sensitivity profile qualification |

## 4. Current M15 Qualification Workflow

Current primary release workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Job name:

`M15 implementation mapping qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

Permissions:

`contents: read`

The workflow is triggered by changes to:

- `frp_prototype_v1_7_0.py`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `rtl/m15/**`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

The workflow supports:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

## 5. M15 Compile Gate

The first executable gate is:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

This verifies Python syntax before generation of the M15 qualification package.

## 6. M15 Structured Output Generation

The workflow generates the current structured-output artifact with:

    python frp_prototype_v1_7_0.py --mode demo --output json

Output:

`artifacts/m15/structured-output.json`

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The structured-output validation requires:

- `cells = 16`;
- `hierarchy_depth = 4`;
- `request_lanes = 4`;
- `ticks_recorded = 64`;
- scheduler `7/1`;
- scheduler count `balance = 56`;
- scheduler count `commit = 8`;
- valid scheduler counts;
- balanced ternary state-domain validation;
- zero reserved-state events;
- zero actual direct events;
- zero queue-overflow events;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 7. M15 Self-Test Matrix

The M15 workflow runs four self-test variants.

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Required result for every self-test:

- schema equals `frp.structured_output.v1.7.0`;
- version equals `1.7.0`;
- status equals `PASS`;
- check count equals `41`;
- all 41 checks equal `True`.

Current validated M15 self-test result:

`41/41 PASS`

## 8. M15 Artifact Package

The current workflow generates ten primary M15 artifact layers.

### 8.1 Fixed-point interface profile

Command:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Schema:

`frp.m15.fixed_point_interface_profile.v1.7.0`

Output:

`artifacts/m15/fixed-point-interface-profile.json`

### 8.2 Balanced ternary hardware encoding map

Command:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Schema:

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

Output:

`artifacts/m15/balanced-ternary-hardware-encoding-map.json`

### 8.3 Quantized reference shadow model

Command:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Schema:

`frp.m15.quantized_reference_shadow_model.v1.7.0`

Output:

`artifacts/m15/quantized-reference-shadow-model.json`

### 8.4 Cycle-exact reference trace

Command:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Schema:

`frp.m15.cycle_exact_reference_trace.v1.7.0`

Output:

`artifacts/m15/cycle-exact-reference-trace.json`

### 8.5 RTL comparison vector package

Command:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

Output:

`artifacts/m15/rtl-comparison-vector-package.json`

### 8.6 SystemVerilog testbench interface map

Command:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Schema:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

Output:

`artifacts/m15/systemverilog-testbench-interface-map.json`

### 8.7 Synthesizable RTL reference core

Command:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Schema:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

Output:

`artifacts/m15/synthesizable-rtl-reference-core.json`

### 8.8 RTL assertion correlation harness

Command:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Schema:

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

Output:

`artifacts/m15/rtl-assertion-correlation-harness.json`

### 8.9 Reference RTL equivalence report

Command:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Schema:

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

Output:

`artifacts/m15/reference-rtl-equivalence-report.json`

### 8.10 Qualification closure manifest

Command:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Schema:

`frp.m15.qualification_closure_manifest.v1.7.0`

Output:

`artifacts/m15/qualification-closure-manifest.json`

## 9. Additional M15 Qualification Outputs

The M15 workflow also generates:

- benchmark matrix;
- 8-cell scaling output;
- 16-cell scaling output;
- 32-cell scaling output;
- deterministic vector package A;
- deterministic vector package B.

Benchmark matrix command:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

Output:

`artifacts/m15/benchmark-matrix.json`

Scaling commands:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Outputs:

- `artifacts/m15/scaling-8.json`;
- `artifacts/m15/scaling-16.json`;
- `artifacts/m15/scaling-32.json`.

## 10. Preserved Computational Kernel Invariants

The current M15 workflow validates preservation of the FRP computational kernel.

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Mandatory opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariants include:

- `balanced_ternary_state_domain = True`;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

Validated scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

## 11. M15 Fixed-Point Contract

The current workflow validates the following fixed-point representations.

General scalar:

`S32Q16`

Normalized coefficient:

`S32Q30`

Phase representation:

`PHASE_U32`

Gamma representation:

`GAMMA_S32`

Trigonometric table entries:

`4096`

Required exactness markers:

- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

## 12. M15 Balanced Ternary Hardware Encoding

The current workflow validates the canonical two-bit balanced ternary hardware encoding.

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Integer encoding map:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

The request interface validates:

- `request_lanes = 4`;
- `cell_id_width = 4`.

Validated invariant:

`reserved_state_events = 0`

## 13. Quantized Shadow Validation

The quantized reference shadow model is required to preserve:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- valid scheduler counts;
- 64 recorded ticks;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

The quantized shadow is part of the deterministic hardware-facing comparison domain.

## 14. Cycle-Exact Trace Validation

The current workflow validates:

- exactly 64 trace rows;
- zero actual direct events;
- zero reserved-state events;
- per-tick gamma-noise target vectors for all 16 cells.

The cycle-exact trace remains the integer reference path between the quantized shadow model and deterministic RTL comparison vectors.

## 15. Deterministic RTL Vector Qualification

The M15 workflow generates two independent RTL comparison-vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

Both packages are generated from the same deterministic reference configuration.

The workflow compares them with:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required result:

`no differences`

The vector-package manifest requires ten files:

- `frp_m15_kernel_vectors.vec`;
- `frp_m15_pending_routes.trace`;
- `frp_m15_scheduler_free_vectors.vec`;
- `frp_m15_scheduler_7_1_vectors.vec`;
- `frp_m15_scheduler_1_7_vectors.vec`;
- `frp_m15_full_correlation_vectors.vec`;
- `frp_m15_cell_trace.vec`;
- `frp_m15_reference_preload.json`;
- `frp_m15_trig_lut_q30.vec`;
- `frp_m15_sha256_manifest.json`.

The SHA-256 manifest validates the nine non-manifest vector files.

The workflow also requires byte-identical equality between corresponding files in both independently generated vector directories.

## 16. SystemVerilog Interface Contract

The current workflow validates these M15 interface parameters:

| Parameter | Value |
|---|---|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The verification stimulus interface includes:

`gamma_noise_target_q`

## 17. Synthesizable RTL Reference-Core Contract

The current workflow validates:

- 26 exact tick-execution stages;
- `actual_direct_events = 0`;
- tick-separated neutral routing;
- scheduler modes `free`, `7/1`, and `1/7`.

The synthesizable RTL reference core remains part of the M15 reference architecture and qualification package.

## 18. RTL Assertion Correlation Contract

The M15 RTL assertion correlation harness validates:

- assertion count `13`;
- exact integer comparison rule.

Exact comparison rule:

`actual integer field == expected integer field`

The assertion layer connects the deterministic reference-vector domain to RTL-facing comparison behavior.

## 19. Reference RTL Equivalence Validation

The current M15 workflow validates two distinct correlation levels.

### Floating reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Required maximum error bounds:

- phase error `<= 0.02`;
- frequency error `<= 0.0001`;
- heat error `<= 0.001`;
- gamma error `<= 0.000001`;
- coherence error `<= 0.01`;
- `C` error `<= 0.01`;
- `P` error `<= 0.001`;
- `C_minus_P` error `<= 0.01`.

### Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 20. Qualification Closure

The qualification closure manifest requires:

- status `PASS`;
- all closure checks equal `True`;
- exactly ten M15 artifact layers.

The qualification closure manifest defines the current M15 release-validation endpoint.

## 21. M15 Scaling Checks

The current M15 workflow validates bounded execution at:

- 8 cells;
- 16 cells;
- 32 cells.

Expected scaling structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---|---|---|
| 8 | 3 | 2 | 16 bits |
| 16 | 4 | 4 | 32 bits |
| 32 | 5 | 8 | 64 bits |

Every scaling output must preserve:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- valid scheduler counts;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 22. M15 Benchmark Matrix Validation

The M15 workflow generates:

`artifacts/m15/benchmark-matrix.json`

Expected schema:

`frp.m3.benchmark_matrix.v1.7.0`

Expected row count:

`5`

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

This benchmark matrix belongs to the M15 qualification package.

It does not replace the primary architecture-validation role of the M15 workflow.

## 23. M15 Architecture Document Contract

The current workflow validates:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Required architecture markers include:

- `M14 floating semantic reference`;
- `M15 quantized hardware shadow model`;
- `cycle-exact integer golden trace`;
- `synthesizable RTL reference core`;
- `exact quantized shadow ↔ RTL equivalence`;
- `actual_direct_events = 0`;
- both mandatory neutral routes;
- scheduler modes `free`, `7/1`, and `1/7`;
- `S32Q16`;
- `S32Q30`;
- `PHASE_U32`;
- `GAMMA_S32`;
- `GAMMA_NOISE_TARGETS_Q`;
- `quantized_reference_shadow_model`;
- `rtl_comparison_vector_package`;
- `reference_rtl_equivalence_report`;
- `qualification_closure_manifest`;
- planned M16 architecture boundary.

The workflow also validates the primary vector-row field order.

Required ordering:

`GAMMA_UPDATE_VALID`

before

`GAMMA_NOISE_TARGETS_Q`

before

`STATES_PACKED`

## 24. M15 Artifact Upload

The workflow uploads:

`artifacts/m15`

Artifact name:

`frp-v1.7.0-m15-qualification-artifacts`

Missing artifact output is treated as an error.

## 25. Foundational FRP Self-Test Workflow

Workflow:

`.github/workflows/frp-self-test.yml`

Workflow name:

`FRP Self Test`

Job name:

`Run FRP v0.9.3 self-test`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_3_mobile.py`

Command:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Required output marker:

`result=PASS`

This is a foundational historical validation workflow.

It is not the current M15 release qualification workflow.

## 26. Foundational Benchmark Smoke Workflow

Workflow:

`.github/workflows/frp-benchmark-smoke.yml`

Workflow name:

`FRP Benchmark Smoke Test`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_3_mobile.py`

Command:

    python frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Required architecture markers:

- `frp_distributed_resonant`;
- `distributed_neutral_ternary`;
- `direct_ternary_commit`;
- `binary_style_forced_switch`.

This workflow remains a foundational historical benchmark check.

It is not the current M15 qualification workflow.

## 27. Structured Output Workflow

Workflow:

`.github/workflows/frp-structured-output.yml`

Workflow name:

`FRP Structured Output`

Job name:

`Validate FRP v0.9.4 structured output`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_4.py`

Structured-output schema:

`frp.structured_output.v0.9.4`

The workflow validates:

- Python compilation;
- text self-test;
- text benchmark;
- JSON self-test;
- JSON benchmark;
- JSON demo;
- JSON telemetry output;
- schema markers;
- project marker;
- version markers;
- self-test PASS state;
- zero failures;
- direct-transition safety;
- positive stability margin;
- benchmark architecture labels;
- telemetry structure.

This workflow preserves the M2 structured-output validation layer.

It is not rewritten as the M15 workflow.

## 28. Architecture Milestone Workflow Chain

The release-specific architecture workflow chain is:

| Milestone | Executable reference | Workflow |
|---|---|---|
| M3 | `frp_prototype_v0_9_5.py` | `frp-m3-benchmark-signal-map.yml` |
| M4 | `frp_prototype_v0_9_6.py` | `frp-m4-hdl-trace.yml` |
| M5 | `frp_prototype_v0_9_7.py` | `frp-m5-rtl-assertion-harness.yml` |
| M6 | `frp_prototype_v0_9_8.py` | `frp-m6-formal-verification.yml` |
| M7 | `frp_prototype_v0_9_9.py` | `frp-m7-fpga-synthesis.yml` |
| M8 | `frp_prototype_v1_0_0.py` | `frp-m8-production-release.yml` |
| M9 | `frp_prototype_v1_1_0.py` | `frp-m9-silicon-architecture.yml` |
| M10 | `frp_prototype_v1_2_0.py` | `frp-m10-silicon-production-tapeout.yml` |
| M11 | `frp_prototype_v1_3_0.py` | `frp-m11-production-integration-handoff.yml` |
| M12 | `frp_prototype_v1_4_0.py` | `frp-m12-feedback-iteration.yml` |
| M13 | `frp_prototype_v1_5_0.py` | `frp-m13-production-scaling-stabilization.yml` |
| M14 | `frp_prototype_v1_6_0.py` | `frp-m14-physical-implementation-qualification.yml` |
| M15 | `frp_prototype_v1_7_0.py` | `frp-m15-implementation-mapping-qualification.yml` |

Each workflow preserves its own release-specific validation boundary.

The current architecture endpoint is:

`M15 / FRP v1.7.0`

## 29. Comparative Architecture Benchmark Workflow

Workflow:

`.github/workflows/frp-architecture-comparison.yml`

Workflow name:

`FRP Comparative Architecture Benchmark`

Job name:

`Comparative Architecture Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

The suite compares:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The workflow validates the separate benchmark package under:

`benchmarks/architecture_comparison/`

Validation layers include:

- Python compilation;
- deterministic workload validation;
- normalized cost-model validation;
- thermal proxy-model validation;
- architecture reference self-tests;
- FRP adapter self-test;
- canonical comparison generation;
- deterministic repeat generation;
- machine-readable result validation;
- artifact handling.

The comparative benchmark workflow does not define the FRP architecture milestone chain.

## 30. Hardware-Sensitivity Profile Workflow

Workflow:

`.github/workflows/frp-hardware-sensitivity-profile.yml`

Workflow name:

`FRP Hardware Sensitivity Profile Qualification`

Job name:

`Hardware Sensitivity Profile Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`15 minutes`

The workflow validates:

- hardware-cost calibration references;
- coefficient provenance;
- hardware-sensitivity cost profile structure;
- coefficient constraints;
- scenario ordering;
- profile SHA-256;
- validator self-tests;
- deterministic byte-identical repeat validation.

The profile layer remains separate from the primary M15 architecture workflow.

## 31. Hardware-Sensitivity Comparison Workflow

Workflow:

`.github/workflows/frp-hardware-sensitivity-comparison.yml`

Workflow name:

`FRP Hardware Sensitivity Comparison`

The workflow validates the hardware-informed sensitivity comparison layer under:

`benchmarks/architecture_comparison/`

Its role is to preserve:

- hardware-sensitivity runner self-tests;
- deterministic comparison generation;
- machine-readable sensitivity outputs;
- qualification status;
- raw trace integrity;
- profile binding;
- result reproducibility.

This workflow remains a supporting validation contour.

It does not redefine the FRP architecture progression.

## 32. Dependency Handling

The foundational workflows:

- `frp-self-test.yml`;
- `frp-benchmark-smoke.yml`;
- `frp-structured-output.yml`;

install dependencies with:

    python -m pip install --upgrade pip

    pip install -r requirements.txt

The current M15 workflow uses Python 3.12 and executes the current reference and M15 artifact-generation path directly.

Dependency behavior is therefore workflow-specific.

## 33. Minimal Current M15 Validation Commands

Compile:

    python -m py_compile frp_prototype_v1_7_0.py

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## 34. Current Release Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Release-record validated commit:

`5fd9a4f`

Validated workflow stack recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Recorded validation result:

`PASS`

Recorded M15 self-test result:

`41/41 PASS`

Primary release-validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

The validated commit and workflow-run numbers belong to the published v1.7.0 validation record.

They are historical release evidence and are not used as a statement about later documentation-only commits.

## 35. CI Traceability Rule

Every release-specific architecture layer must preserve traceability between:

`executable reference`

↓

`workflow`

↓

`generated artifacts`

↓

`schema validation`

↓

`kernel invariants`

↓

`test report`

↓

`validation index`

↓

`release notes`

Historical workflows must remain bound to their historical release-specific executable files.

The current release workflow must remain bound to the current executable reference and current architecture document.

Supporting comparative benchmark workflows must remain separate from the primary architecture milestone chain.

## 36. Repository Alignment Rule

When the current architecture layer changes, review:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CI.md`;
- `REPRODUCIBILITY.md`;
- `USAGE.md`;
- current executable reference;
- current test report;
- current validation index;
- current release notes;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

Historical release-specific workflows must not be silently redirected to a newer executable.

A new architecture layer should preserve the existing release-validation history and add its own explicit validation boundary.

Supporting comparative benchmark workflows must remain secondary to the FRP architecture progression.

## 37. Current Status

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation result:

`PASS`

Current validated M15 self-test count:

`41/41`

Current CI role:

`preserve the complete FRP validation chain from the foundational executable and structured-output layers through release-specific architecture milestone validation, deterministic M15 hardware-facing qualification, and supporting comparative validation contours`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

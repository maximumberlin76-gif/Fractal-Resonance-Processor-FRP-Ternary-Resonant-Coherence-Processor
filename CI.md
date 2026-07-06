# CI — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the Continuous Integration validation structure of the Fractal Resonance Processor (FRP) repository.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Purpose

The FRP Continuous Integration layer preserves validation traceability across the complete published processor architecture progression.

The CI structure validates:

- the resonant phase-coherence computational core;
- the balanced ternary state and retained-result domain;
- structured machine-readable execution;
- release-specific architecture milestones;
- deterministic M15 implementation mapping;
- stateful quantized hardware-shadow execution;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized reference correlation;
- exact quantized deterministic replay;
- qualification closure;
- comparative architecture benchmark integrity;
- hardware-sensitivity profile qualification;
- hardware-sensitivity comparison qualification.

The current validated processor chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric Sakaguchi phase lag gamma`

↓

`hierarchical fractal coupling`

↓

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`stateful delay dynamics`

↓

`local thermal-phase interaction`

↓

`local correlated gamma drift`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed ternary commit`

↓

`mandatory tick-separated routing through active neutral state 0`

↓

`retained coherent ternary state`

↓

`structured machine-readable validation`

↓

`fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`floating-to-quantized reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

## 2. Processor Computational Subject Under CI

The current FRP architecture contains two connected computational domains.

### 2.1 Resonant dynamic domain

The resonant dynamic domain contains:

- cell phase;
- base frequency;
- target frequency;
- current frequency;
- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- scheduler-dependent phase contribution;
- delayed frequency response;
- distributed thermal state;
- thermal coupling-factor evolution;
- local correlated gamma drift;
- phase evolution;
- global Kuramoto order parameter `R`;
- pair-domain phase coherence;
- cluster phase coherence;
- supercluster phase coherence;
- global phase coherence;
- nonlinear coherence compression;
- dynamic stability evaluation.

### 2.2 Balanced ternary state and retained-result domain

The balanced ternary domain contains:

- states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- transition requests;
- distributed commit;
- transition-fraction limits;
- request lanes;
- pending neutral routes;
- mandatory tick separation;
- scheduler-controlled execution;
- retained ternary state.

The resonant dynamic domain drives the evolving computation.

The balanced ternary domain provides the state, target, transition, and retained-result layer.

### 2.3 Current tick execution chain

The current executable preserves the following operational sequence:

`scheduler-state selection`

↓

`pending neutral-route processing`

↓

`transition-request processing`

↓

`phase-derived ternary target processing`

↓

`distributed transition-limit enforcement`

↓

`frequency-target formation`

↓

`stateful delayed frequency response`

↓

`local generated power`

↓

`distributed thermal update`

↓

`local thermal overload`

↓

`correlated gamma-noise update`

↓

`local effective Sakaguchi phase lag`

↓

`thermal coupling-factor update`

↓

`hierarchical Kuramoto-Sakaguchi coupling field`

↓

`phase velocity`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`nonlinear coherence compression`

↓

`C(t), P(t), and C(t) - P(t)`

↓

`structured telemetry and trace capture`

Across successive ticks:

`evolved phase field`

↓

`next phase-derived ternary target`

↓

`distributed transition`

↓

`active neutral routing`

↓

`retained coherent ternary state`

## 3. Core Dynamic Relations Preserved by the CI Chain

### 3.1 Kuramoto-Sakaguchi phase interaction

The current phase interaction uses:

`sin(phase_j - phase_i - gamma_effective_i)`

The interaction combines:

- hierarchical coupling weights;
- local thermal coupling factors;
- nominal coupling strength;
- local effective gamma.

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

### 3.2 Phase evolution

The current floating reference phase velocity combines:

`0.060 × current frequency`

+

`scheduler push`

+

`coupling field`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

### 3.3 Kuramoto order parameter R

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation supports hierarchical coherence evaluation.

### 3.4 Multiscale phase coherence

Current coherence domains include:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

### 3.5 Stateful delay dynamics

Current default delay coefficient:

`delay_alpha = 0.30`

The delayed response is:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

### 3.6 Local thermal-phase interaction

Each cell tracks:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The thermal field feeds into:

- effective resonant coupling;
- local gamma drift;
- nonlinear coherence compression.

### 3.7 Local correlated gamma drift

The current processor tracks:

- nominal gamma;
- deterministic gamma-noise targets;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

The M15 verification path maps this domain through:

- `GAMMA_S32`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`;
- deterministic cycle-exact gamma stimulus;
- floating-to-quantized gamma correlation.

### 3.8 Nonlinear coherence compression and dynamic stability

The current processor applies:

`effective coherence = raw phase coherence × coherence compression`

The dynamic stability layer tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing load:

`P(t) = heat + switch_load`

Required validated condition:

`C_minus_P_min > 0.0`

## 4. Balanced Ternary State and Retained-Result Validation

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current phase-derived ternary target mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

Mandatory opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Core validated invariants:

`balanced_ternary_state_domain = True`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Preserved scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current default transition fraction:

`0.25`

Current default 16-cell request-lane count:

`4`

Current validated relation:

`switch_load_peak <= transition_fraction`

## 5. Root README Active Validation Badge Chain

The root `README.md` exposes 18 active GitHub Actions validation badges.

Current badge-visible passing chain:

| Validation workflow | Status |
|---|---|
| `FRP M15 Implementation Mapping and Qualification Closure` | `passing` |
| `FRP Hardware Sensitivity Profile Qualification` | `passing` |
| `FRP Hardware Sensitivity Comparison` | `passing` |
| `FRP M14 Physical Implementation Correlation and Production Qualification` | `passing` |
| `FRP M13 Production Scaling and Implementation Stabilization` | `passing` |
| `FRP M12 External Implementation Feedback and Production Iteration` | `passing` |
| `FRP M11 Production Integration and External Handoff` | `passing` |
| `FRP M10 Silicon Production and Tapeout Readiness` | `passing` |
| `FRP M9 Silicon and Heterogeneous Architecture` | `passing` |
| `FRP M8 Production Release Package` | `passing` |
| `FRP M7 FPGA Synthesis and Timing Scaffold` | `passing` |
| `FRP M6 Formal Verification and Equivalence Scaffold` | `passing` |
| `FRP M5 RTL Interface and Assertion Harness` | `passing` |
| `FRP M4 HDL Trace and Testbench` | `passing` |
| `FRP M3 Benchmark and Signal Map` | `passing` |
| `FRP Self Test` | `passing` |
| `FRP Benchmark Smoke Test` | `passing` |
| `FRP Structured Output` | `passing` |

The repository contains 19 workflow files in total.

The Comparative Architecture Benchmark workflow completes the 19-file workflow inventory.

## 6. CI Validation Roles

The repository CI structure contains three connected validation roles.

### 6.1 Foundational validation

These workflows preserve the foundational executable, resonant benchmark, and structured-output layers:

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

Each workflow retains its release-specific executable binding.

### 6.2 Architecture milestone validation

These workflows preserve the architecture progression from M3 through the current M15 layer.

Each milestone workflow validates its release-specific executable reference and architecture package.

### 6.3 Supporting comparative validation

These workflows extend the validation surface through:

- comparative architecture benchmark qualification;
- hardware-sensitivity profile qualification;
- hardware-sensitivity comparison qualification.

The primary architecture progression remains represented by the M3-M15 milestone chain.

## 7. Workflow Inventory

The repository contains 19 GitHub Actions workflow files.

### 7.1 Foundational workflows

| Workflow file | Workflow name | Validation role |
|---|---|---|
| `.github/workflows/frp-self-test.yml` | `FRP Self Test` | foundational executable self-test |
| `.github/workflows/frp-benchmark-smoke.yml` | `FRP Benchmark Smoke Test` | foundational resonant benchmark smoke validation |
| `.github/workflows/frp-structured-output.yml` | `FRP Structured Output` | M2 structured-output validation |

### 7.2 Architecture milestone workflows

| Workflow file | Workflow name |
|---|---|
| `.github/workflows/frp-m3-benchmark-signal-map.yml` | `FRP M3 Benchmark and Signal Map` |
| `.github/workflows/frp-m4-hdl-trace.yml` | `FRP M4 HDL Trace and Testbench` |
| `.github/workflows/frp-m5-rtl-assertion-harness.yml` | `FRP M5 RTL Interface and Assertion Harness` |
| `.github/workflows/frp-m6-formal-verification.yml` | `FRP M6 Formal Verification and Equivalence Scaffold` |
| `.github/workflows/frp-m7-fpga-synthesis.yml` | `FRP M7 FPGA Synthesis and Timing Scaffold` |
| `.github/workflows/frp-m8-production-release.yml` | `FRP M8 Production Release Package` |
| `.github/workflows/frp-m9-silicon-architecture.yml` | `FRP M9 Silicon and Heterogeneous Architecture` |
| `.github/workflows/frp-m10-silicon-production-tapeout.yml` | `FRP M10 Silicon Production and Tapeout Readiness` |
| `.github/workflows/frp-m11-production-integration-handoff.yml` | `FRP M11 Production Integration and External Handoff` |
| `.github/workflows/frp-m12-feedback-iteration.yml` | `FRP M12 External Implementation Feedback and Production Iteration` |
| `.github/workflows/frp-m13-production-scaling-stabilization.yml` | `FRP M13 Production Scaling and Implementation Stabilization` |
| `.github/workflows/frp-m14-physical-implementation-qualification.yml` | `FRP M14 Physical Implementation Correlation and Production Qualification` |
| `.github/workflows/frp-m15-implementation-mapping-qualification.yml` | `FRP M15 Implementation Mapping and Qualification Closure` |

### 7.3 Supporting comparative workflows

| Workflow file | Workflow name |
|---|---|
| `.github/workflows/frp-architecture-comparison.yml` | `FRP Comparative Architecture Benchmark` |
| `.github/workflows/frp-hardware-sensitivity-comparison.yml` | `FRP Hardware Sensitivity Comparison` |
| `.github/workflows/frp-hardware-sensitivity-profile.yml` | `FRP Hardware Sensitivity Profile Qualification` |

## 8. Current M15 Qualification Workflow

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

The workflow responds to:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

Path-scoped source inputs:

- `frp_prototype_v1_7_0.py`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `rtl/m15/**`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

## 9. M15 Workflow Step Sequence

The current M15 workflow executes nine named stages:

1. `Checkout repository`;
2. `Set up Python`;
3. `Compile FRP v1.7.0 reference file`;
4. `Generate M15 qualification outputs`;
5. `Compare deterministic vector packages`;
6. `Validate M15 schemas, kernel invariants, fixed-point contract, and equivalence`;
7. `Validate deterministic vector package integrity`;
8. `Validate M15 architecture document contract`;
9. `Upload M15 qualification artifacts`.

The execution chain is:

`source checkout`

↓

`Python 3.12 environment`

↓

`compile gate`

↓

`structured execution and self-test generation`

↓

`ten M15 artifact exports`

↓

`benchmark matrix and scaling outputs`

↓

`independent deterministic vector generation`

↓

`byte-identical vector comparison`

↓

`schema and invariant validation`

↓

`vector SHA-256 integrity validation`

↓

`architecture-document contract validation`

↓

`qualification artifact upload`

## 10. M15 Compile Gate

The first executable gate is:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

## 11. M15 Structured Output Generation

The workflow generates:

    python frp_prototype_v1_7_0.py --mode demo --output json

Output:

`artifacts/m15/structured-output.json`

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The workflow validates:

- `cells = 16`;
- `hierarchy_depth = 4`;
- `request_lanes = 4`;
- `ticks_recorded = 64`;
- scheduler `7/1`;
- scheduler counts `balance = 56` and `commit = 8`;
- `scheduler_counts_valid = True`;
- `balanced_ternary_state_domain = True`;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

## 12. M15 Self-Test Matrix

The current workflow runs four self-test variants.

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Required result for every self-test:

- schema `frp.structured_output.v1.7.0`;
- version `1.7.0`;
- status `PASS`;
- check count `41`;
- all 41 checks `True`.

Current validated result:

`41/41 PASS`

## 13. Exact Current 41-Check Coverage

The current self-test package contains exactly these 41 checks:

1. `1_7_scheduler_pass`;
2. `7_1_scheduler_pass`;
3. `all_export_schemas_exact`;
4. `artifact_layer_count_10`;
5. `encoding_pass`;
6. `exact_reference_cell_trace_replay_match`;
7. `exact_reference_vector_replay_match`;
8. `exact_shadow_counter_match`;
9. `exact_shadow_pending_route_match`;
10. `exact_shadow_scheduler_match`;
11. `exact_shadow_state_match`;
12. `export_schema_count_10`;
13. `fixed_point_boundary_pass`;
14. `fixed_point_thermal_sum_exact`;
15. `fixed_point_topology_sum_exact`;
16. `free_scheduler_pass`;
17. `qualification_closure_pass`;
18. `queue_exhaustion_detection_pass`;
19. `request_lane_order_pass`;
20. `route_minus_to_plus_pass`;
21. `route_plus_to_minus_pass`;
22. `scale_16_pass`;
23. `scale_32_pass`;
24. `scale_8_pass`;
25. `semantic_C_minus_P_sign_match`;
26. `semantic_boundary_order_match`;
27. `semantic_neutral_route_sequence_match`;
28. `semantic_scheduler_sequence_match`;
29. `semantic_state_sequence_match`;
30. `shadow_actual_direct_events_zero`;
31. `shadow_balanced_ternary_domain`;
32. `shadow_queue_overflow_events_zero`;
33. `shadow_reserved_state_events_zero`;
34. `shadow_scheduler_counts_valid`;
35. `shadow_switch_load_within_transition_fraction`;
36. `shadow_ticks_recorded_equals_steps`;
37. `topology_16_pass`;
38. `topology_32_pass`;
39. `topology_8_pass`;
40. `trig_lut_pass`;
41. `vector_determinism_pass`.

The check set covers:

- scheduler behavior;
- both opposite-polarity active-neutral routes;
- pending-route behavior;
- request-lane ordering;
- balanced ternary encoding;
- fixed-point boundaries;
- topology scaling;
- execution scaling;
- semantic sequence preservation;
- dynamic stability-sign preservation;
- quantized shadow invariants;
- exact replay;
- deterministic vector generation;
- all ten M15 export schemas;
- qualification closure.

## 14. M15 Artifact Package

The workflow generates ten primary M15 artifact layers.

### 14.1 Fixed-point interface profile

Command:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Schema:

`frp.m15.fixed_point_interface_profile.v1.7.0`

Output:

`artifacts/m15/fixed-point-interface-profile.json`

### 14.2 Balanced ternary hardware encoding map

Command:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Schema:

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

Output:

`artifacts/m15/balanced-ternary-hardware-encoding-map.json`

### 14.3 Quantized reference shadow model

Command:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Schema:

`frp.m15.quantized_reference_shadow_model.v1.7.0`

Output:

`artifacts/m15/quantized-reference-shadow-model.json`

### 14.4 Cycle-exact reference trace

Command:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Schema:

`frp.m15.cycle_exact_reference_trace.v1.7.0`

Output:

`artifacts/m15/cycle-exact-reference-trace.json`

### 14.5 RTL comparison vector package

Command:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

Output:

`artifacts/m15/rtl-comparison-vector-package.json`

### 14.6 SystemVerilog testbench interface map

Command:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Schema:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

Output:

`artifacts/m15/systemverilog-testbench-interface-map.json`

### 14.7 Synthesizable RTL reference core

Command:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Schema:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

Output:

`artifacts/m15/synthesizable-rtl-reference-core.json`

### 14.8 RTL assertion correlation harness

Command:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Schema:

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

Output:

`artifacts/m15/rtl-assertion-correlation-harness.json`

### 14.9 Reference RTL equivalence report

Command:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Schema:

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

Output:

`artifacts/m15/reference-rtl-equivalence-report.json`

### 14.10 Qualification closure manifest

Command:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Schema:

`frp.m15.qualification_closure_manifest.v1.7.0`

Output:

`artifacts/m15/qualification-closure-manifest.json`

## 15. Stable M15 Schema Set

| Artifact | Required schema |
|---|---|
| fixed-point interface profile | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| balanced ternary hardware encoding map | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| quantized reference shadow model | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| cycle-exact reference trace | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| RTL comparison vector package | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| SystemVerilog testbench interface map | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| synthesizable RTL reference core | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| RTL assertion correlation harness | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| reference RTL equivalence report | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| qualification closure manifest | `frp.m15.qualification_closure_manifest.v1.7.0` |

Every artifact carries:

- version `1.7.0`;
- milestone `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`.

## 16. Additional M15 Qualification Outputs

The workflow also generates:

- benchmark matrix;
- 8-cell scaling output;
- 16-cell scaling output;
- 32-cell scaling output;
- deterministic vector package A;
- deterministic vector package B.

Benchmark output:

`artifacts/m15/benchmark-matrix.json`

Scaling outputs:

- `artifacts/m15/scaling-8.json`;
- `artifacts/m15/scaling-16.json`;
- `artifacts/m15/scaling-32.json`.

Vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

## 17. M15 Fixed-Point Contract

The workflow validates the following hardware-facing numeric representations.

General dynamic scalar:

`S32Q16`

Normalized coefficient:

`S32Q30`

Phase representation:

`PHASE_U32`

Sakaguchi gamma representation:

`GAMMA_S32`

Trigonometric table entries:

`4096`

Required exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The fixed-point mapping covers:

- phase;
- frequency;
- gamma;
- coherence;
- hierarchy weights;
- thermal weights;
- dynamic stability values;
- ternary transition execution.

## 18. M15 Balanced Ternary Hardware Encoding

Canonical two-bit encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Validated request interface:

`request_lanes = 4`

`cell_id_width = 4`

Validated reserved-state condition:

`reserved_state_events = 0`

## 19. Quantized Shadow Validation

The quantized reference shadow model preserves stateful processor domains including:

- ternary state;
- scheduler state;
- pending neutral routes;
- phase;
- frequency;
- gamma;
- local thermal state;
- coherence;
- dynamic stability;
- event counters.

The workflow validates:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- `balanced_ternary_state_domain = True`;
- `scheduler_counts_valid = True`;
- `ticks_recorded = 64`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

## 20. Cycle-Exact Trace Validation

The workflow validates:

- exactly `64` trace rows;
- `actual_direct_events = 0` in the trace summary;
- `16` gamma-noise target values in every trace row;
- `reserved_state_events = 0` in every trace row;
- `actual_direct_events = 0` in every trace row.

The cycle-exact trace carries fields including:

- scheduler mode and scheduler state;
- request-lane input vectors;
- packed ternary states;
- gamma-noise update validity;
- gamma-noise target vectors;
- switch load;
- global heat;
- global phase coherence;
- `C_q16`;
- `P_q16`;
- `C_minus_P_q16`;
- active-neutral route counters;
- pending-route count;
- direct-event counters;
- reserved-state counters;
- queue-overflow counters.

## 21. Deterministic RTL Vector Qualification

The workflow generates two independent vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

The comparison command is:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required qualification result:

`byte-identical equality`

The vector package contains exactly ten files:

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

The exported package also provides a 64-character deterministic package digest.

## 22. Deterministic Vector Integrity

The workflow validates each generated vector directory independently.

Required package conditions:

- exactly ten files;
- presence of `frp_m15_sha256_manifest.json`;
- exact SHA-256 equality for every manifest-bound vector file;
- byte-identical equality between corresponding files in package A and package B.

The SHA-256 manifest binds the generated vector package to exact content.

## 23. SystemVerilog Interface Contract

The workflow validates these M15 interface parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The verification stimulus interface includes:

`gamma_noise_target_q`

This input carries deterministic gamma-noise targets into the RTL-facing verification path.

## 24. Synthesizable RTL Reference-Core Contract

The current export defines exactly 26 tick-execution stages:

1. `resolve scheduler state`;
2. `clear current-tick switch-change counters`;
3. `clear current-tick per-cell switch activity`;
4. `process ready pending neutral routes`;
5. `process external request lanes in ascending order`;
6. `process phase-derived targets when enabled`;
7. `calculate switch load`;
8. `update frequency targets`;
9. `update lagged frequencies`;
10. `calculate local generated power`;
11. `calculate local thermal dissipation`;
12. `calculate hierarchical thermal diffusion`;
13. `update local heat`;
14. `calculate local thermal overload`;
15. `update gamma-noise correlation states`;
16. `update local gamma-effective values`;
17. `update thermal node factors`;
18. `calculate hierarchical phase-coupling field`;
19. `update phase velocities`;
20. `update wrapped phase words`;
21. `calculate multiscale phase coherence`;
22. `calculate C(t)`;
23. `calculate P(t)`;
24. `calculate C_minus_P`;
25. `detect first stability crossing`;
26. `capture post-tick outputs`.

Validated kernel requirements:

- balanced ternary states `{-1, 0, 1}`;
- reserved state code `2'b10`;
- `actual_direct_events = 0`;
- tick-separated neutral routing `True`;
- scheduler modes `free`, `7/1`, and `1/7`.

The planned RTL file map contains:

- `rtl/m15/frp_m15_types_pkg.sv`;
- `rtl/m15/frp_m15_fixed_point_pkg.sv`;
- `rtl/m15/frp_m15_trig_lut_pkg.sv`;
- `rtl/m15/frp_m15_scheduler.sv`;
- `rtl/m15/frp_m15_transition_core.sv`;
- `rtl/m15/frp_m15_neutral_route_queue.sv`;
- `rtl/m15/frp_m15_delay_dynamics.sv`;
- `rtl/m15/frp_m15_thermal_field.sv`;
- `rtl/m15/frp_m15_gamma_drift.sv`;
- `rtl/m15/frp_m15_hierarchical_coupling.sv`;
- `rtl/m15/frp_m15_multiscale_coherence.sv`;
- `rtl/m15/frp_m15_stability_telemetry.sv`;
- `rtl/m15/frp_m15_top.sv`.

## 25. RTL Assertion Correlation Contract

The current M15 assertion harness contains exactly 13 assertions:

1. `valid balanced ternary encoding`;
2. `reserved-state exclusion`;
3. `direct polarity transition exclusion`;
4. `active neutral route insertion`;
5. `target application after ready tick`;
6. `actual_direct_events = 0`;
7. `transition-limit enforcement`;
8. `scheduler sequence`;
9. `scheduler count consistency`;
10. `phase topology fixed-point normalization`;
11. `thermal topology fixed-point normalization`;
12. `deterministic trace tick count`;
13. `exact cycle-output match`.

Exact comparison rule:

`actual integer field == expected integer field`

Scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

## 26. Reference RTL Equivalence Validation

The current M15 workflow validates two correlation levels.

### 26.1 Floating semantic reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Required maximum error bounds:

| Field | Maximum error |
|---|---:|
| phase | `0.02` |
| frequency | `0.0001` |
| heat | `0.001` |
| gamma | `0.000001` |
| coherence | `0.01` |
| `C` | `0.01` |
| `P` | `0.001` |
| `C_minus_P` | `0.01` |

These bounds preserve correlation across:

- phase;
- frequency;
- thermal state;
- gamma;
- coherence;
- dynamic stability;
- scheduler sequence;
- ternary state sequence;
- active-neutral route sequence.

### 26.2 Exact quantized shadow deterministic replay

Required exact replay matches:

- `shadow_replay_state_match = 1.0`;
- `shadow_replay_scheduler_match = 1.0`;
- `shadow_replay_pending_route_match = 1.0`;
- `shadow_replay_counter_match = 1.0`;
- `shadow_replay_trace_match = 1.0`;
- `shadow_replay_cell_trace_match = 1.0`.

## 27. Qualification Closure

The qualification closure manifest requires:

- status `PASS`;
- all closure checks `True`;
- exactly ten M15 artifact layers.

The closure chain is:

`M14 floating semantic reference`

↓

`hardware-facing numeric mapping`

↓

`stateful quantized hardware shadow`

↓

`cycle-exact integer reference`

↓

`deterministic RTL vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure PASS`

## 28. M15 Scaling Checks

The current workflow validates execution at:

- `8` cells;
- `16` cells;
- `32` cells.

Expected scaling structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Every scaling output preserves:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- `balanced_ternary_state_domain = True`;
- `scheduler_counts_valid = True`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

Scaling also extends:

- hierarchy depth;
- shell structure;
- phase-coupling topology;
- thermal topology;
- multiscale coherence domains;
- request-lane count;
- packed ternary state width.

## 29. M15 Benchmark Matrix Validation

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

The benchmark matrix records the current M15 implementation-mapping and qualification progression.

## 30. M15 Architecture Document Contract

The current workflow validates:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Required architecture markers include:

- `M14 floating semantic reference`;
- `M15 quantized hardware shadow model`;
- `cycle-exact integer golden trace`;
- `synthesizable RTL reference core`;
- `exact quantized shadow ↔ RTL equivalence`;
- `actual_direct_events = 0`;
- both active-neutral routes;
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

The workflow also validates primary vector-row field ordering:

`GAMMA_UPDATE_VALID`

before

`GAMMA_NOISE_TARGETS_Q`

before

`STATES_PACKED`

## 31. M15 Artifact Upload

The workflow uploads:

`artifacts/m15`

Artifact name:

`frp-v1.7.0-m15-qualification-artifacts`

Upload action:

`actions/upload-artifact@v4`

Artifact-directory requirement:

`if-no-files-found: error`

## 32. Foundational FRP Self-Test Workflow

Workflow:

`.github/workflows/frp-self-test.yml`

Workflow name:

`FRP Self Test`

Job name:

`Run FRP v0.9.3 self-test`

Execution environment:

`ubuntu-latest`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_3_mobile.py`

Command:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Required output marker:

`result=PASS`

This workflow preserves the foundational v0.9.3 executable self-test layer.

## 33. Foundational Resonant Benchmark Smoke Workflow

Workflow:

`.github/workflows/frp-benchmark-smoke.yml`

Workflow name:

`FRP Benchmark Smoke Test`

Job name:

`Run FRP benchmark smoke test`

Execution environment:

`ubuntu-latest`

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

The workflow preserves the foundational resonant benchmark comparison layer.

The architecture marker:

`frp_distributed_resonant`

preserves the connection between resonant phase computation and distributed active-neutral ternary routing.

## 34. Structured Output Workflow

Workflow:

`.github/workflows/frp-structured-output.yml`

Workflow name:

`FRP Structured Output`

Job name:

`Validate FRP v0.9.4 structured output`

Execution environment:

`ubuntu-latest`

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
- schema identity;
- repository identity;
- version identity;
- self-test `PASS` state;
- `failures = 0`;
- `actual_direct_events = 0`;
- `C_minus_P_min > 0.0`;
- benchmark architecture labels;
- telemetry structure.

Historical telemetry fields include:

- `tick`;
- `phase`;
- `R`;
- `phi`;
- `C`;
- `P`;
- `C_minus_P`.

This workflow preserves the M2 structured-output and phase-coherence telemetry layer.

## 35. Architecture Milestone Workflow Chain

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

Each workflow preserves its release-specific validation boundary.

Current architecture endpoint:

`M15 / FRP v1.7.0`

## 36. Complete Architecture Progression Preserved by CI

The milestone workflow chain preserves:

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

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

The resonant phase-coherence computational core remains continuous through this architecture progression.

## 37. Comparative Architecture Benchmark Workflow

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

The workflow validates:

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

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

The Comparative Architecture Benchmark workflow provides the architecture-level comparison validation contour.

## 38. Hardware-Sensitivity Profile Workflow

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
- hardware-sensitivity cost-profile structure;
- coefficient constraints;
- scenario ordering;
- profile SHA-256;
- validator self-tests;
- deterministic byte-identical repeat validation.

The profile workflow provides hardware-informed coefficient and scenario qualification.

## 39. Hardware-Sensitivity Comparison Workflow

Workflow:

`.github/workflows/frp-hardware-sensitivity-comparison.yml`

Workflow name:

`FRP Hardware Sensitivity Comparison`

Job name:

`Hardware Sensitivity Comparison Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

The workflow validates the hardware-informed sensitivity comparison layer under:

`benchmarks/architecture_comparison/`

Its validation surface includes:

- hardware-sensitivity runner self-tests;
- deterministic comparison generation;
- machine-readable sensitivity outputs;
- qualification status;
- raw trace integrity;
- profile binding;
- result reproducibility.

The hardware-sensitivity comparison workflow extends the supporting comparative validation surface.

## 40. Dependency Handling

The foundational workflows:

- `frp-self-test.yml`;
- `frp-benchmark-smoke.yml`;
- `frp-structured-output.yml`;

install dependencies with:

    python -m pip install --upgrade pip
    pip install -r requirements.txt

Current declared external dependency:

`numpy>=1.26.0`

The current M15 workflow uses Python `3.12` and executes the current reference and M15 artifact-generation path directly.

Workflow-specific dependency handling remains preserved in each workflow file.

## 41. Minimal Current M15 Validation Commands

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

Qualification closure:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Required current results:

`Python compilation PASS`

`all self-test profiles 41/41 PASS`

`qualification closure PASS`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## 42. Full Local M15 CI Reproduction Sequence

Create qualification directories:

    mkdir -p artifacts/m15/vectors_a artifacts/m15/vectors_b

Generate structured output:

    python frp_prototype_v1_7_0.py --mode demo --output json > artifacts/m15/structured-output.json

Generate the four self-test outputs:

    python frp_prototype_v1_7_0.py --mode self-test --output json > artifacts/m15/self-test.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json > artifacts/m15/self-test-free.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json > artifacts/m15/self-test-7-1.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json > artifacts/m15/self-test-1-7.json

Generate the ten M15 exports:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile > artifacts/m15/fixed-point-interface-profile.json

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map > artifacts/m15/balanced-ternary-hardware-encoding-map.json

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model > artifacts/m15/quantized-reference-shadow-model.json

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace > artifacts/m15/cycle-exact-reference-trace.json

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package > artifacts/m15/rtl-comparison-vector-package.json

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map > artifacts/m15/systemverilog-testbench-interface-map.json

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core > artifacts/m15/synthesizable-rtl-reference-core.json

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness > artifacts/m15/rtl-assertion-correlation-harness.json

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report > artifacts/m15/reference-rtl-equivalence-report.json

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > artifacts/m15/qualification-closure-manifest.json

Generate benchmark matrix:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix > artifacts/m15/benchmark-matrix.json

Generate scaling outputs:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json > artifacts/m15/scaling-8.json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json > artifacts/m15/scaling-16.json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json > artifacts/m15/scaling-32.json

Generate independent vector packages:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_a > artifacts/m15/vector-package-a.json

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_b > artifacts/m15/vector-package-b.json

Compare vector directories:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required qualification result:

`byte-identical equality`

## 43. Current Release Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Release-record validated commit:

`5fd9a4f`

Validated workflow stack recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Recorded validation result:

`PASS`

Recorded M15 self-test result:

`41/41 PASS`

Primary release-validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

The release-record commit and workflow-run identifiers preserve the published v1.7.0 validation evidence.

## 44. CI Traceability Rule

Every release-specific architecture layer preserves traceability between:

`processor computational mechanism`

↓

`executable reference`

↓

`GitHub Actions workflow`

↓

`Run Job execution`

↓

`generated artifacts`

↓

`schema validation`

↓

`phase, frequency, gamma, thermal, coherence, state, route, and stability correlation`

↓

`test report`

↓

`validation index`

↓

`release notes`

Historical workflows retain their release-specific executable bindings.

The current M15 workflow retains the current executable, architecture document, RTL mapping path, and qualification package bindings.

Supporting comparative workflows retain their benchmark and hardware-sensitivity package bindings.

## 45. Repository Alignment Rule

When the current architecture layer changes, review:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CHANGELOG.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `CONTRIBUTING.md`;
- current executable reference;
- current test report;
- current validation index;
- current release notes;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

The alignment review checks:

- current version;
- current milestone;
- current executable filename;
- current workflow path;
- active root README validation badges;
- current schemas;
- complete resonant computational core;
- balanced ternary state and retained-result domain;
- current GitHub Actions Run Job state;
- current test report;
- current validation index;
- current release notes;
- release-specific architecture traceability.

## 46. Current CI Technical Chain

The complete current CI chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric local phase lag gamma`

↓

`hierarchical fractal phase interaction`

↓

`stateful delay dynamics`

↓

`distributed local thermal field`

↓

`thermal coupling-factor evolution`

↓

`local correlated gamma drift`

↓

`phase velocity`

↓

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed transition limit`

↓

`mandatory active-neutral routing`

↓

`retained coherent ternary state`

↓

`structured machine-readable execution`

↓

`41-check self-test matrix`

↓

`fixed-point implementation profile`

↓

`balanced ternary hardware encoding`

↓

`stateful quantized hardware shadow`

↓

`cycle-exact integer golden trace`

↓

`independent deterministic RTL vector packages`

↓

`SHA-256 package integrity`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`floating-to-quantized reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

↓

`GitHub Actions artifact preservation`

## 47. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with asymmetric phase lag, hierarchical fractal coupling, phase evolution, resonance selection, Kuramoto order parameter R, multiscale phase coherence, stateful delay dynamics, local thermal-phase interaction, local correlated gamma drift, nonlinear coherence compression, dynamic stability evaluation, phase-derived ternary targets, distributed commit, mandatory active-neutral routing, and retained coherent ternary state`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current root README validation badges:

`18 passing`

Current repository workflow files:

`19`

Current validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current CI role:

`preserve the complete FRP validation chain from Kuramoto-Sakaguchi resonant phase computation, hierarchical fractal phase interaction, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained coherent state through deterministic M15 fixed-point implementation mapping, cycle-exact execution, RTL correlation, reference equivalence, qualification closure, and supporting comparative validation contours`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

# Documentation Layer — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This directory contains the public technical documentation layer of the Fractal Resonance Processor (FRP).

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`../frp_prototype_v1_7_0.py`

Current primary architecture document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`../TEST_REPORT_v1_7_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`../RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Purpose

The documentation layer preserves the complete published FRP architecture progression and provides the technical reference surface for:

- balanced ternary state and retained-result semantics;
- Kuramoto-Sakaguchi resonant phase coupling;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- phase evolution;
- resonance selection;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- distributed thermal-state tracking;
- thermal-phase interaction;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability `C(t) - P(t)`;
- phase-derived ternary target formation;
- distributed commit;
- active neutral routing;
- retained coherent ternary state;
- executable validation;
- structured machine-readable output;
- benchmark interpretation;
- hardware-facing signal mapping;
- HDL and testbench preparation;
- RTL interface definition;
- assertion and equivalence contracts;
- FPGA implementation mapping;
- production release and stable interface structures;
- silicon and heterogeneous implementation architecture;
- tapeout-readiness structure;
- production integration and implementation handoff;
- production scaling and stabilization;
- physical implementation correlation;
- fixed-point implementation mapping;
- quantized hardware shadow execution;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- reference equivalence;
- qualification closure;
- reproducibility;
- release and validation traceability.

The documentation directory preserves current architecture documents together with historical version-specific documents.

Historical documents retain the architecture layer to which they belong.

## 2. Current Documentation Position

The current published architecture layer is:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current processor chain begins with the resonant computational mechanism:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric phase lag gamma`

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

The current M15 implementation-mapping and qualification bridge is:

`M14 floating semantic reference`

↓

`hardware-facing numeric types`

↓

`balanced ternary hardware encoding`

↓

`deterministic fixed-point arithmetic`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`verification preload and deterministic stimulus`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation mapping`

↓

`floating semantic reference correlation`

↓

`exact quantized deterministic replay`

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

## 3. Complete Computational Core

The FRP computational core contains two connected domains.

### 3.1 Resonant dynamic domain

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

### 3.2 Balanced ternary state and retained-result domain

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

### 3.3 Tick-by-tick execution chain

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

## 4. Resonant Phase, Coherence, Delay, and Thermal Layers

### 4.1 Kuramoto-Sakaguchi phase interaction

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

### 4.2 Phase evolution

The current floating reference phase velocity combines:

`0.060 × current frequency`

+

`scheduler push`

+

`coupling field`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

### 4.3 Kuramoto order parameter R

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation is evaluated across hierarchical coherence domains.

### 4.4 Multiscale phase coherence

Current coherence domains include:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Current outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

### 4.5 Stateful delay dynamics

Current default delay coefficient:

`delay_alpha = 0.30`

Each cell preserves:

- base frequency;
- frequency target;
- current frequency.

The delayed response is:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

### 4.6 Local thermal-phase interaction

Each cell tracks:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The thermal field feeds back into:

- effective resonant coupling;
- local gamma drift;
- nonlinear coherence compression.

Required fixed-point thermal marker:

`fixed_point_thermal_sum_exact = True`

### 4.7 Local correlated gamma drift

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

### 4.8 Nonlinear coherence compression and dynamic stability

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

## 5. Balanced Ternary State and Retained-Result Layer

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

The active neutral state provides:

- balancing;
- damping;
- transition;
- stabilization;
- conflict neutralization;
- switching-load control.

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

## 6. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

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

Validated invariant:

`reserved_state_events = 0`

## 7. Current M15 Documentation Boundary

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
| `m15_implementation_mapping_domain_interface_qualification_closure.md` | current M15 architecture, implementation mapping, interface correlation, reference equivalence, and qualification closure |

Related current root records:

| File | Purpose |
|---|---|
| `../frp_prototype_v1_7_0.py` | current executable reference |
| `../TEST_REPORT_v1_7_0.md` | current M15 validation record |
| `../FRP_VALIDATION_INDEX_v1_7_0.md` | current M15 validation index |
| `../RELEASE_NOTES_v1_7_0.md` | current release notes |
| `../README.md` | main public processor overview and active validation badges |

Current primary numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Required exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 8. Documentation Directory Map

The `docs/` directory contains 29 Markdown documentation files.

### 8.1 Core and Foundation Documents

| File | Role |
|---|---|
| `core_principles.md` | foundational FRP operating principles |
| `resonance_computation.md` | resonance-based computation interpretation |
| `architecture.md` | original architecture-layer record |
| `limitations.md` | version-specific evidence and scope record |
| `benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `output_schema.md` | structured-output and machine-readable validation schema layer |

These documents preserve their original version-specific context where applicable.

The current architecture state is defined by the current executable reference, current M15 architecture document, current test report, current validation index, and current release notes.

### 8.2 Hardware-Facing Pathway Documents

| File | Role |
|---|---|
| `hardware_pathway.md` | early hardware-facing development pathway |
| `implementation_layers.md` | staged implementation-layer structure |
| `fpga_mapping_study.md` | FPGA-oriented mapping study |
| `asic_mapping_study.md` | ASIC-oriented mapping study |
| `physical_validation_plan.md` | physical validation planning structure |

These documents preserve the early hardware-facing pathway from which the later milestone chain developed.

### 8.3 M3 — Benchmark Export and Hardware Signal Mapping

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

### 8.4 M4 — HDL Trace Export and Testbench Scaffold

Primary document:

`m4_hdl_trace_testbench.md`

Version:

`FRP v0.9.6`

Architecture layer:

`HDL Trace Export and Testbench Scaffold`

Status:

`Completed`

### 8.5 M5 — RTL Interface Contract and Assertion Harness

Primary document:

`m5_rtl_interface_assertion_harness.md`

Version:

`FRP v0.9.7`

Architecture layer:

`RTL Interface Contract and Assertion Harness`

Status:

`Completed`

### 8.6 M6 — Formal Verification Hooks and Equivalence Scaffold

Primary document:

`m6_formal_verification_equivalence.md`

Version:

`FRP v0.9.8`

Architecture layer:

`Formal Verification Hooks and Equivalence Scaffold`

Status:

`Completed`

### 8.7 M7 — FPGA Synthesis Package and Timing Constraint Scaffold

Primary document:

`m7_fpga_synthesis_timing.md`

Version:

`FRP v0.9.9`

Architecture layer:

`FPGA Synthesis Package and Timing Constraint Scaffold`

Status:

`Completed`

### 8.8 M8 — Production Release Package and Stable Interface Freeze

Primary document:

`m8_production_release_package.md`

Version:

`FRP v1.0.0`

Architecture layer:

`Production Release Package and Stable Interface Freeze`

Status:

`Completed`

### 8.9 M9 — Silicon and Heterogeneous Implementation Architecture

Primary document:

`m9_silicon_heterogeneous_architecture.md`

Version:

`FRP v1.1.0`

Architecture layer:

`Silicon and Heterogeneous Implementation Architecture`

Status:

`Completed`

### 8.10 M10 — Silicon Production and Tapeout Readiness Package

Primary document:

`m10_silicon_production_tapeout_readiness.md`

Version:

`FRP v1.2.0`

Architecture layer:

`Silicon Production and Tapeout Readiness Package`

Status:

`Completed`

### 8.11 M11 — Production Integration and External Implementation Handoff

Primary document:

`m11_production_integration_external_handoff.md`

Version:

`FRP v1.3.0`

Architecture layer:

`Production Integration and External Implementation Handoff`

Status:

`Completed`

### 8.12 M12 — External Implementation Feedback and Production Iteration Loop

Primary document:

`m12_external_implementation_feedback_iteration.md`

Version:

`FRP v1.4.0`

Architecture layer:

`External Implementation Feedback and Production Iteration Loop`

Status:

`Completed`

### 8.13 M13 — Production Scaling and Implementation Stabilization Package

Primary document:

`m13_production_scaling_implementation_stabilization.md`

Version:

`FRP v1.5.0`

Architecture layer:

`Production Scaling and Implementation Stabilization Package`

Status:

`Completed`

### 8.14 M14 — Physical Implementation Correlation and Production Qualification Package

Primary document:

`m14_physical_implementation_correlation_production_qualification.md`

Version:

`FRP v1.6.0`

Architecture layer:

`Physical Implementation Correlation and Production Qualification Package`

Status:

`Completed`

### 8.15 M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package

Primary document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Version:

`FRP v1.7.0`

Architecture layer:

`Implementation Mapping, Domain Interface, and Qualification Closure Package`

Status:

`Current validated layer`

## 9. Architecture Progression

The documentation layer preserves the following complete architecture chain:

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric phase lag gamma`

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

`phase-derived balanced ternary target`

↓

`distributed transition limit`

↓

`mandatory active-neutral routing`

↓

`retained coherent ternary state`

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

`balanced ternary hardware encoding`

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

## 10. Related Root Documentation

| File | Purpose |
|---|---|
| `../README.md` | main public processor overview and active validation badges |
| `../ROADMAP.md` | architecture progression through the current layer and next planned layer |
| `../MILESTONES.md` | milestone chain |
| `../PROJECT_STRUCTURE.md` | repository structure |
| `../CHANGELOG.md` | version and release chronology |
| `../INSTALL.md` | installation and first-run path |
| `../USAGE.md` | usage, command, export, and validation reference |
| `../REPRODUCIBILITY.md` | computational and M15 reproducibility instructions |
| `../CI.md` | Continuous Integration and qualification documentation |
| `../CONTRIBUTING.md` | contribution and validation guide |
| `../funding_brief.md` | partner and funding-facing technical brief |
| `../CITATION.cff` | citation metadata |
| `../LICENSE` | Apache License 2.0 |
| `../NOTICE` | repository notice |

## 11. Release and Validation Record Chain

The repository preserves release-specific validation records for the complete executable architecture progression.

Current records:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

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

## 12. GitHub Actions Validation Chain

The root `README.md` exposes active GitHub Actions validation badges for the published FRP workflow chain.

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

Current M15 published validation record:

`PASS`

Validated M15 self-test check count:

`41`

Validated M15 self-test result:

`41/41 PASS`

Current M15 workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

The repository also preserves:

- milestone workflows for M3 through M14;
- `../.github/workflows/frp-architecture-comparison.yml`;
- `../.github/workflows/frp-hardware-sensitivity-comparison.yml`;
- `../.github/workflows/frp-hardware-sensitivity-profile.yml`.

## 13. Comparative Benchmark Support

The comparative architecture benchmark suite serves as a supporting validation contour.

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

Current qualification policy:

`integrity_only_no_winner_assertions`

Current required winner assertions:

`[]`

The comparative benchmark layer extends the repository validation surface with deterministic architecture-level comparison and hardware-sensitivity analysis.

## 14. Documentation Traceability Rule

The documentation layer preserves traceability between:

`processor computational mechanism`

↓

`architecture layer`

↓

`executable reference`

↓

`machine-readable artifacts`

↓

`GitHub Actions workflow`

↓

`Run Job result`

↓

`test report`

↓

`validation index`

↓

`release notes`

Current architecture updates require review of:

- `../README.md`;
- `../ROADMAP.md`;
- `../MILESTONES.md`;
- `../PROJECT_STRUCTURE.md`;
- `../CHANGELOG.md`;
- `../INSTALL.md`;
- `../USAGE.md`;
- `../REPRODUCIBILITY.md`;
- `../CI.md`;
- `../CONTRIBUTING.md`;
- current executable reference;
- current test report;
- current release notes;
- current validation index;
- current architecture document;
- current milestone workflow;
- `README.md`.

Historical release records preserve their release-specific architecture state.

Foundation documents preserve their version-specific architecture context.

The comparative benchmark suite preserves its supporting validation role.

## 15. Current Documentation Status

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

`../frp_prototype_v1_7_0.py`

Current architecture document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current primary qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current documentation role:

`preserve the complete published FRP technical documentation chain from Kuramoto-Sakaguchi resonant phase coupling, hierarchical fractal phase interaction, phase evolution, resonance selection, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained coherent state through structured validation, hardware-facing implementation mapping, cycle-exact execution, RTL correlation, reference equivalence, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

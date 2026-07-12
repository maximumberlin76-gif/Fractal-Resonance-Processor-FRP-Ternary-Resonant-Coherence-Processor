# Repository Structure — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document describes the current public repository structure of the Fractal Resonance Processor (FRP).

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

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Repository Role

The repository preserves the complete published FRP architecture progression.

The progression begins with the resonant phase-coherence computational mechanism and the balanced ternary state and retained-result domain.

It continues through structured executable validation, hardware-facing signal mapping, HDL and RTL preparation, FPGA and silicon implementation layers, production qualification, deterministic fixed-point implementation mapping, cycle-exact reference execution, RTL correlation, reference equivalence, and qualification closure.

The primary architecture chain is:

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

`floating-to-quantized reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

The Comparative Architecture Benchmark Suite adds a supporting deterministic comparison and hardware-sensitivity validation contour alongside the primary architecture progression.

## 2. Complete Computational Core

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

### 2.3 Tick-by-tick execution chain

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

## 3. Resonant Phase and Coherence Architecture

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

The same phase-order relation is evaluated across hierarchical coherence domains.

### 3.4 Multiscale phase coherence

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

## 4. Delay, Thermal, Gamma, and Stability Architecture

### 4.1 Stateful delay dynamics

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

### 4.2 Local thermal-phase interaction

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

Required fixed-point thermal marker:

`fixed_point_thermal_sum_exact = True`

### 4.3 Local correlated gamma drift

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

### 4.4 Nonlinear coherence compression and dynamic stability

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

## 5. Balanced Ternary State and Retained-Result Architecture

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

## 6. Current Executable Reference Layer

Current executable reference file:

`frp_prototype_v1_7_0.py`

Current architecture layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current executable preserves the complete resonant phase-coherence computational mechanism and balanced ternary state-retention mechanism.

It extends the M14 floating semantic reference into deterministic hardware-facing representation and qualification layers.

The M15 bridge is:

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

### M16 RTL Core Realization Layer

Path:

`rtl/m16/`

Purpose:

Concrete SystemVerilog RTL realization layer for the FRP v1.8.0 M16 execution boundary.

The M16 RTL layer preserves the M15-qualified retained-state execution contract and exposes the processor boundary as explicit RTL artifacts.

Primary preserved invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Primary execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`


### M16 RTL Files

| Path | Purpose |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | constants, encodings, helper functions, scheduler decoding, transition classification |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` scheduler-state realization |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | pending-route register layer |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | transition-capacity enforcement |
| `rtl/m16/frp_m16_state_update.sv` | retained-state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL core |
| `rtl/m16/frp_m16_assertions.sv` | assertion binding layer |
| `rtl/m16/frp_m16_tb.sv` | deterministic RTL smoke testbench |

### M16 RTL Documentation

| Path | Purpose |
|---|---|
| `rtl/m16/README.md` | M16 RTL layer overview |
| `rtl/m16/ARTIFACTS.md` | RTL artifact manifest |
| `rtl/m16/SIMULATION.md` | simulator execution instructions |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | simulation transcript template |
| `rtl/m16/CLOSURE.md` | RTL closure report |

### M16 Closure Status

Current M16 status:

`RTL artifact boundary complete`

Current final qualification status:

`pending external simulator execution`

Required final M16 qualification result:

`PASS`

## 7. Balanced Ternary Hardware Encoding

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

## 8. Current M15 Artifact Layers

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

## 9. Repository Root

The repository root contains:

- the current executable FRP reference file;
- the complete historical executable reference chain;
- current and historical validation records;
- current and historical release notes;
- validation indices;
- architecture tracking documents;
- installation and usage documentation;
- reproducibility documentation;
- Continuous Integration documentation;
- contribution and security policies;
- citation and licensing metadata.

Current primary files:

| File | Purpose |
|---|---|
| `README.md` | main public processor overview, current architecture layer, and active validation badges |
| `frp_prototype_v1_7_0.py` | current FRP v1.7.0 executable reference |
| `TEST_REPORT_v1_7_0.md` | current M15 validation record |
| `FRP_VALIDATION_INDEX_v1_7_0.md` | current M15 validation index |
| `RELEASE_NOTES_v1_7_0.md` | current release notes |
| `ROADMAP.md` | architecture progression through M15 and next planned M16 layer |
| `MILESTONES.md` | milestone chain from M0 through current M15 and planned M16 |
| `PROJECT_STRUCTURE.md` | repository structure guide |
| `CHANGELOG.md` | version history and release chronology |
| `INSTALL.md` | installation and first-run path |
| `USAGE.md` | execution, command, export, and validation reference |
| `REPRODUCIBILITY.md` | computational and M15 reproducibility path |
| `CI.md` | Continuous Integration and qualification documentation |
| `CONTRIBUTING.md` | contribution and validation guide |
| `SECURITY.md` | security policy |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `funding_brief.md` | partner and funding-facing technical brief |
| `requirements.txt` | Python dependency list |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | repository notice |
| `.gitignore` | ignored local files |

## 10. Executable Version Chain

The repository preserves the complete executable architecture chain.

| File | Architecture layer |
|---|---|
| `frp_prototype_v0_9_3_mobile.py` | original stabilized executable resonant reference layer |
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

Each executable file preserves its release-specific architecture state.

Current executable reference:

`frp_prototype_v1_7_0.py`

## 11. Validation Record Chain

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

Current validated M15 self-test result:

`41/41 PASS`

## 12. Validation Index Chain

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

Each validation index preserves its release-specific qualification record.

## 13. Release Record Chain

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

The repository also preserves:

- `RELEASE_CHECKLIST_v0_9_3.md`;
- `FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md`.

## 14. Documentation Directory

Directory:

`docs/`

The `docs/` directory contains the public technical documentation layer.

### Core documentation

| File | Purpose |
|---|---|
| `docs/README.md` | documentation architecture index |
| `docs/core_principles.md` | foundational FRP operating principles |
| `docs/resonance_computation.md` | resonance-based computational interpretation |
| `docs/architecture.md` | architecture documentation |
| `docs/benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `docs/limitations.md` | version-specific evidence and scope record |
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

## 15. Verification Directory

Directory:

`verification/`

Files:

| File | Purpose |
|---|---|
| `verification/README.md` | verification layer overview |
| `verification/coherence_metrics.md` | coherence and operational metric definitions |

The verification layer documents:

- phase coherence;
- operational coherence;
- dynamic stability;
- execution telemetry.

## 16. Examples Directory

Directory:

`examples/`

Files:

| File | Purpose |
|---|---|
| `examples/README.md` | examples overview |
| `examples/resonance_convergence_example.md` | resonance-convergence example |

The examples layer provides practical interpretation material for repository review.

## 17. Simulations Directory

Directory:

`simulations/`

Files:

| File | Purpose |
|---|---|
| `simulations/README.md` | simulation background index |
| `simulations/initial_kuramoto_result.md` | preliminary Kuramoto background result |

The simulation directory preserves supporting historical background material for the processor architecture.

Current release qualification is recorded through the executable reference, GitHub Actions workflows, test reports, validation indices, release notes, and M15 qualification artifacts.

## 18. Models Directory

Directory:

`models/`

Files:

| File | Purpose |
|---|---|
| `models/README.md` | model background index |
| `models/kuramoto_frp_background_model.md` | Kuramoto-type background model context |

The model directory preserves conceptual and mathematical background for the resonant phase layer.

The current executable implementation is:

`frp_prototype_v1_7_0.py`

## 19. Comparative Architecture Benchmark Directory

Directory:

`benchmarks/architecture_comparison/`

The Comparative Architecture Benchmark Suite provides a supporting validation contour aligned with:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The suite compares:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The comparison chain is:

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

The suite extends the repository validation surface with deterministic architecture-level comparison and hardware-sensitivity analysis.

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
| `benchmarks/architecture_comparison/common_workload.py` | shared deterministic semantic workload |
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

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 20. GitHub Actions Directory

Directory:

`.github/workflows/`

The repository contains 19 GitHub Actions workflow files.

The workflow structure covers:

- foundational executable validation;
- foundational resonant benchmark validation;
- structured output validation;
- architecture milestone qualification from M3 through M15;
- comparative architecture qualification;
- hardware-sensitivity comparison qualification;
- hardware-sensitivity profile qualification.

### Foundational validation workflows

| Workflow | Purpose |
|---|---|
| `frp-self-test.yml` | standard FRP self-test |
| `frp-benchmark-smoke.yml` | resonant benchmark smoke test |
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

### Supporting comparative workflows

| Workflow | Purpose |
|---|---|
| `frp-architecture-comparison.yml` | comparative architecture benchmark qualification |
| `frp-hardware-sensitivity-comparison.yml` | hardware-sensitivity comparison qualification |
| `frp-hardware-sensitivity-profile.yml` | hardware-sensitivity profile qualification |

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## 21. Root README Validation Badge Chain

The root `README.md` exposes active validation badges for the published FRP workflow chain.

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

The badge chain connects the repository structure to the active GitHub Actions validation state recorded in the root README.

## 22. Current M15 Validation Evidence

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

Current validation result:

`PASS`

Current M15 self-test result:

`41/41 PASS`

Primary validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

The release-record commit and workflow-run identifiers preserve the published v1.7.0 validation evidence.

## 23. Architecture Milestone Chain

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

Architecture tracking is maintained in:

- `ROADMAP.md`;
- `MILESTONES.md`.

## 24. Reproducibility Layer

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

`current GitHub Actions workflow`

↓

`Run Job result`

↓

`current test report`

↓

`current validation index`

↓

`current release notes`

The current executable reference is:

`frp_prototype_v1_7_0.py`

Current validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

## 25. Release and Metadata Layer

Release and repository metadata files include:

| File | Purpose |
|---|---|
| `CHANGELOG.md` | version chronology |
| `ROADMAP.md` | architecture progression |
| `MILESTONES.md` | milestone structure |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | repository notice |
| `SECURITY.md` | security policy |
| `CONTRIBUTING.md` | contribution and validation guide |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `funding_brief.md` | partner and funding-facing technical brief |

Release-specific test reports, release notes, validation indices, and release manifests preserve architecture traceability.

## 26. Repository Naming Discipline

Processor name:

`FRP — Fractal Resonance Processor`

Processor class:

`Ternary Resonant Coherence Processor`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

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

Each release-specific file retains its release-specific version identity.

## 27. Repository Alignment Rule

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
- current `TEST_REPORT`;
- current `RELEASE_NOTES`;
- current `FRP_VALIDATION_INDEX`;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

The alignment review checks:

- current version;
- current milestone;
- current executable filename;
- current validation result;
- current schemas;
- current workflow path;
- complete computational core;
- active GitHub Actions badge chain;
- release-specific architecture traceability.

## 28. Current Public Repository Structure

The current public repository contains:

- the complete executable FRP version chain from v0.9.3-mobile through v1.7.0;
- the current FRP v1.7.0 M15 executable reference;
- Kuramoto-Sakaguchi resonant phase coupling;
- asymmetric phase lag gamma;
- hierarchical fractal phase interaction;
- phase evolution;
- resonance selection;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- distributed local thermal dynamics;
- thermal coupling-factor evolution;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation;
- phase-derived balanced ternary target formation;
- balanced ternary state domain `{-1, 0, 1}`;
- active neutral state `0`;
- mandatory tick-separated neutral routing;
- distributed commit;
- retained coherent ternary state;
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
- production release and stable interface structures;
- silicon and heterogeneous implementation architecture;
- tapeout-readiness structures;
- external implementation handoff structures;
- production iteration and stabilization layers;
- physical implementation correlation and qualification;
- fixed-point implementation mapping;
- balanced ternary hardware encoding;
- stateful quantized hardware shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized reference correlation;
- exact quantized deterministic replay;
- qualification closure;
- reproducibility documentation;
- 19 GitHub Actions workflow files;
- 18 active validation badges in the root README;
- Comparative Architecture Benchmark Suite support;
- hardware-sensitivity qualification;
- documentation, verification, examples, simulations, and model layers;
- citation and licensing metadata.

## 29. Current Status

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

Current validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current repository role:

`preserve the complete published Fractal Resonance Processor architecture from Kuramoto-Sakaguchi resonant phase evolution, hierarchical fractal coupling, resonance selection, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained coherent state through structured validation, hardware-facing implementation mapping, cycle-exact execution, RTL correlation, reference equivalence, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

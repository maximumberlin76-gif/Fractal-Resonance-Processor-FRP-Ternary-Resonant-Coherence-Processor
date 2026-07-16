# Roadmap — Fractal Resonance Processor (FRP)

This roadmap defines the staged architecture progression of the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current Python executable semantic reference:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current validation status:

`PASS`

Qualified semantic and implementation-mapping foundation:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## 1. Purpose

The purpose of this roadmap is to preserve the FRP architecture trajectory from the executable balanced ternary reference layer through implementation mapping, domain interfaces, deterministic quantized execution, RTL correlation, qualification closure, executable SystemVerilog RTL realization, and target-independent FPGA preparation.

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

`SystemVerilog RTL core realization and execution semantics`

↓

`target-independent FPGA integration and preparation qualification`

Comparative benchmark work remains a supporting validation contour. It does not replace or redefine the FRP architecture progression.

## 2. Current Architecture Layer

FRP v1.8.0 establishes the M16 RTL Core Realization and Execution Semantics Package layer of the Fractal Resonance Processor architecture.

M16 realizes the qualified M15 semantic and implementation-mapping boundary as:

`M15-qualified Python executable semantic reference`

↓

`M15 fixed-point and balanced ternary implementation map`

↓

`M16 SystemVerilog package and module realization`

↓

`temporal scheduler execution`

↓

`deterministic request-lane arbitration`

↓

`retained pending-route execution`

↓

`active-neutral transition routing`

↓

`distributed transition-capacity enforcement`

↓

`retained-state writeback`

↓

`SystemVerilog assertion execution`

↓

`executable RTL architectural simulation`

↓

`target-independent FPGA integration top`

↓

`asynchronous external reset assertion and two-stage synchronous reset release`

↓

`core-ready execution-input gating`

↓

`executable FPGA integration simulation`

M16 does not rename the Python executable semantic reference.

The retained semantic reference is:

`frp_prototype_v1_7_0.py`

## 3. Preserved Computational Kernel

FRP v1.8.0 retains the M15-qualified computational kernel.

Resonant phase model:

`Kuramoto-Sakaguchi resonant phase dynamics`

Preserved resonant and structural quantities include:

- oscillator phase;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- phase evolution;
- resonance selection;
- Kuramoto order parameter `R(t)`;
- multiscale phase coherence;
- endogenous structural coherence `C(t)`;
- operational pressure `P(t)`;
- state-dependent delay dynamics;
- distributed local thermal dynamics;
- thermal coupling-factor evolution;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation;
- phase-derived balanced ternary target formation.

Phase synchronization and phase coherence are not interchangeable.

`R(t)` is not identical to general endogenous structural coherence `C(t)`.

FRP operational `C(t)` and `P(t)` are processor-specific quantities.

Operational stability relation:

`C(t) > P(t)`

Thermal state participates in endogenous processor feedback.

Balanced ternary state and retained-result domain:

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

Additional retained invariants:

`reserved_state_events = 0`

`queue_overflow_events = 0`

## 4. Qualified M15 Foundation

FRP v1.7.0 defines the qualified M15 semantic and implementation-mapping foundation retained by M16.

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

M15 defines ten artifact layers:

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

M15 qualification result:

`41/41 PASS`

M15 deterministic qualification records:

| Qualification record | Result |
|---|---:|
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

M15 release-record validated commit:

`5fd9a4f`

M15 validated workflow stack recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

M15 validation records:

- `TEST_REPORT_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## 5. Current M16 RTL and FPGA Preparation Layers

M16 RTL source boundary:

1. `rtl/m16/frp_m16_pkg.sv`;
2. `rtl/m16/frp_m16_scheduler.sv`;
3. `rtl/m16/frp_m16_request_lanes.sv`;
4. `rtl/m16/frp_m16_pending_routes.sv`;
5. `rtl/m16/frp_m16_active_neutral.sv`;
6. `rtl/m16/frp_m16_capacity_guard.sv`;
7. `rtl/m16/frp_m16_state_update.sv`;
8. `rtl/m16/frp_m16_core.sv`;
9. `rtl/m16/frp_m16_assertions.sv`;
10. `rtl/m16/frp_m16_tb.sv`.

M16 RTL documentation boundary:

- `rtl/m16/README.md`;
- `rtl/m16/ARTIFACTS.md`;
- `rtl/m16/SIMULATION.md`;
- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`.

M16 RTL execution domains:

- scheduler modes `free`, `7/1`, and `1/7`;
- deterministic request-lane arbitration;
- retained pending-route eligibility;
- active-neutral first-leg execution;
- pending-route completion from state `0`;
- distributed transition-capacity enforcement;
- retained-state writeback;
- counter clearing with retained state preserved;
- SystemVerilog assertion execution;
- ten integrated invariant flags.

M16 FPGA preparation boundary:

- `fpga/m16/frp_m16_fpga_top.sv`;
- `fpga/m16/frp_m16_fpga_tb.sv`;
- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`.

M16 FPGA preparation domains:

- target-independent FPGA integration top;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick, counter-clear, and request-valid gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten integrated invariant flags.

M16 integrated invariant set:

1. `FRP_INV_STATE_DOMAIN_VALID`;
2. `FRP_INV_SCHEDULER_COUNTS_VALID`;
3. `FRP_INV_REQUEST_LANE_ORDER_VALID`;
4. `FRP_INV_PENDING_POLARITY_VALID`;
5. `FRP_INV_ACTIVE_NEUTRAL_VALID`;
6. `FRP_INV_TRANSITION_CAPACITY_VALID`;
7. `FRP_INV_STATE_UPDATE_VALID`;
8. `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
9. `FRP_INV_NO_RESERVED_STATE`;
10. `FRP_INV_NO_QUEUE_OVERFLOW`.

Integrated invariant vector:

`1111111111`

## 6. Current Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Validation environment:

- `GitHub Actions`;
- Verilator SystemVerilog parsing and elaboration;
- executable compiled RTL testbench;
- executable compiled FPGA integration testbench;
- SystemVerilog assertion execution.

M16 RTL qualification records:

| Qualification record | Workflow run | Qualified commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| Initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| Qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

M16 FPGA preparation qualification records:

| Qualification record | Workflow run | Qualified commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| Initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| Qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

M16 RTL terminal execution records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

M16 FPGA preparation terminal execution records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

Current validation result:

`PASS`

Current validation records:

- `TEST_REPORT_v1_8_0.md`;
- `RELEASE_NOTES_v1_8_0.md`;
- `FRP_VALIDATION_INDEX_v1_8_0.md`.

## 7. Completed Architecture Progression

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
| M15 | v1.7.0 | Implementation Mapping, Domain Interface, and Qualification Closure Package | Qualified semantic and implementation-mapping foundation |
| M16 | v1.8.0 | RTL Core Realization and Execution Semantics Package | Current RTL execution and FPGA preparation layer |

Historical release notes, test reports, and validation indices remain the release-specific source records for each completed layer.

## 8. Architecture Progression Through M16

The FRP architecture progression includes:

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

↓

`SystemVerilog RTL package and scheduler realization`

↓

`request-lane, pending-route, active-neutral, capacity, and state-update realization`

↓

`integrated RTL core and assertion boundary`

↓

`deterministic RTL testbench execution`

↓

`target-independent FPGA integration top`

↓

`FPGA reset synchronization and core-ready gating`

↓

`deterministic FPGA integration testbench execution`

## 9. Comparative Benchmark Role

The comparative architecture benchmark suite is a supporting validation layer.

Its role is to provide reproducible comparison profiles and sensitivity analysis without replacing the FRP architecture chain.

Benchmark contours remain separated:

- the original v0.9.3 transition and thermal benchmark;
- the v0.9.4 text and structured JSON benchmark;
- the v0.9.5–v1.3.0 M3 benchmark matrices;
- the v1.4.0 transition-pressure and feedback-stress matrix;
- the v1.5.0 thermal-survival and stability-boundary matrix;
- the v1.6.0 hierarchical scaling, acceleration, and hotspot-containment matrix;
- the v1.7.0 M15 implementation-mapping matrix;
- the Comparative Architecture Benchmark Suite;
- the Hardware-Informed Sensitivity Qualification;
- M16 RTL qualification;
- M16 FPGA preparation qualification.

The comparative benchmark layer is not an architecture milestone and does not alter the M0–M16 release progression.

Comparative benchmark schema:

`frp.benchmark.architecture_comparison.v1`

Canonical comparative result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Hardware-sensitivity schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical hardware-sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

Related repository paths:

- `benchmarks/architecture_comparison/`;
- `.github/workflows/frp-architecture-comparison.yml`;
- `.github/workflows/frp-hardware-sensitivity-comparison.yml`;
- `.github/workflows/frp-hardware-sensitivity-profile.yml`.

## 10. Current M16 Release Files

Current architecture document:

`docs/m16_rtl_core_realization_execution_semantics.md`

Qualified M15 foundation document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current Python executable semantic reference:

`frp_prototype_v1_7_0.py`

Current foundation documents:

- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`.

Current RTL qualification workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current FPGA preparation qualification workflow:

`.github/workflows/frp-m16-fpga-preparation.yml`

Current M16 canonical-domain and repository-maintenance workflows:

- `.github/workflows/frp-m16-canonical-core-domain.yml`;
- `.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

Inherited M15 qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current release-facing records:

- `TEST_REPORT_v1_8_0.md`;
- `RELEASE_NOTES_v1_8_0.md`;
- `FRP_VALIDATION_INDEX_v1_8_0.md`.

Current M16 qualification documents:

- `docs/m16_rtl_core_interface_contract.md`;
- `docs/m16_scheduler_state_rtl_realization.md`;
- `docs/m16_request_lane_arbitration_module.md`;
- `docs/m16_pending_route_register_module.md`;
- `docs/m16_active_neutral_transition_module.md`;
- `docs/m16_transition_capacity_guard_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_balanced_ternary_state_register_map.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_external_simulator_execution_plan.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`;
- `docs/m16_rtl_artifact_boundary_qualification.md`;
- `docs/m16_artifact_boundary_test_stability_policy.md`;
- `docs/m16_qualification_manifest.md`;
- `docs/m16_qualification_index.md`;
- `docs/m16_public_status_snapshot.md`.

## 11. Repository Alignment Rule

When the current architecture layer changes, review the following files for version, milestone, validation, and architecture-boundary alignment:

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
- `docs/README.md`;
- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`;
- current Python executable semantic reference;
- current `TEST_REPORT`;
- current `RELEASE_NOTES`;
- current `FRP_VALIDATION_INDEX`;
- current architecture document;
- current qualification workflows;
- `rtl/m16/`;
- `fpga/m16/`;
- `tests/`.

The alignment review checks:

- current version;
- current milestone;
- current Python executable semantic-reference filename;
- current validation result;
- current structured-output and benchmark-matrix schemas;
- current workflow paths;
- complete computational kernel;
- M15 semantic and implementation-mapping foundation;
- M16 RTL and FPGA preparation boundaries;
- release-specific architecture traceability.

Historical release records must remain historical and must not be rewritten as current-state documents.

## 12. Current Status

FRP v1.8.0 currently records:

- the qualified M15 semantic and implementation-mapping foundation;
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
- M15 qualification closure;
- ten M16 SystemVerilog RTL source files;
- five M16 RTL documentation artifacts;
- scheduler execution in `free`, `7/1`, and `1/7` modes;
- deterministic request-lane arbitration;
- retained pending-route execution;
- active-neutral transition routing;
- distributed transition-capacity enforcement;
- retained-state writeback;
- executable RTL architectural simulation;
- SystemVerilog assertion execution;
- ten integrated invariant flags;
- target-independent FPGA integration top;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating before readiness;
- scheduler and request-interface propagation;
- retained pending-route completion;
- M16 RTL qualification closure;
- M16 FPGA preparation qualification closure.

Current Python executable semantic reference:

`frp_prototype_v1_7_0.py`

Current M16 RTL qualification record:

| Record | Value |
|---|---|
| Workflow | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Artifact count | `1` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification record:

| Record | Value |
|---|---|
| Workflow | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Artifact count | `1` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current repository role:

`preserve the complete published Fractal Resonance Processor architecture from the balanced ternary computational kernel through structured validation, hardware-facing implementation mapping, deterministic quantized execution, RTL correlation, M15 qualification closure, M16 SystemVerilog RTL execution, and target-independent FPGA preparation`


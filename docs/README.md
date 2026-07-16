# Documentation Layer — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This directory contains the public technical documentation layer of the Fractal Resonance Processor (FRP).

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Main executable semantic reference file:

`../frp_prototype_v1_7_0.py`

Current primary architecture document:

`m16_rtl_core_realization_execution_semantics.md`

Inherited M15 semantic and implementation-mapping document:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`../TEST_REPORT_v1_8_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`../RELEASE_NOTES_v1_8_0.md`

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Current validation status:

`PASS`

Inherited validated M15 self-test result:

`41/41 PASS`

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## M16 RTL Core Realization Documents

The M16 RTL layer realizes the M15-qualified retained-state execution semantics as an executable SystemVerilog RTL core.

The qualified M16 RTL source boundary is:

`rtl/m16/`

M16 RTL documentation:

| Path | Purpose |
|---|---|
| `rtl/m16/README.md` | RTL architecture and execution semantics |
| `rtl/m16/ARTIFACTS.md` | RTL artifact manifest |
| `rtl/m16/SIMULATION.md` | Verilator build and execution procedure |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | executable RTL qualification record |
| `rtl/m16/CLOSURE.md` | M16 RTL closure record |

M16 RTL source artifacts:

| Path | Purpose |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | constants, encodings, types, and helper functions |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-route register layer |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity enforcement |
| `rtl/m16/frp_m16_state_update.sv` | retained balanced ternary writeback |
| `rtl/m16/frp_m16_core.sv` | integrated RTL execution core |
| `rtl/m16/frp_m16_assertions.sv` | architectural and temporal assertion layer |
| `rtl/m16/frp_m16_tb.sv` | deterministic executable RTL testbench |

Qualified M16 RTL execution domains:

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

Current M16 RTL qualification record:

| Record | Value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Artifact count | `1` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Qualified M16 RTL terminal records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

## M16 FPGA Preparation Documents

The M16 FPGA preparation layer exposes the qualified M16 RTL execution core through a target-independent FPGA integration boundary.

The qualified M16 FPGA preparation source boundary is:

`fpga/m16/`

M16 FPGA preparation artifacts:

| Path | Purpose |
|---|---|
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation qualification record |
| `fpga/m16/CLOSURE.md` | FPGA preparation closure record |

Qualified M16 FPGA preparation domains:

- FPGA integration-top elaboration;
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

Current M16 FPGA preparation qualification record:

| Record | Value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Artifact count | `1` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

Qualified M16 FPGA preparation terminal records:

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

## M16 Qualification and Public Status Records

Current M16 qualification records are located in:

- `m16_rtl_artifact_boundary_qualification.md`;
- `m16_qualification_manifest.md`;
- `m16_qualification_index.md`;
- `m16_public_status_snapshot.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

Current release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Inherited semantic and implementation-mapping foundation:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current M16 RTL result:

`SUCCESS`

Current M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation result:

`SUCCESS`

Current M16 FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

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
- quantized hardware-shadow execution;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- reference equivalence;
- M15 qualification closure;
- executable SystemVerilog scheduler semantics;
- deterministic RTL request-lane arbitration;
- retained pending-route execution;
- active-neutral RTL routing;
- distributed RTL transition-capacity enforcement;
- retained balanced ternary RTL writeback;
- executable architectural RTL simulation;
- integrated SystemVerilog assertions;
- ten integrated invariant flags;
- target-independent FPGA integration;
- asynchronous reset assertion;
- two-stage synchronous reset release;
- `core_ready` execution gating;
- executable FPGA integration simulation;
- M16 RTL execution qualification closure;
- M16 FPGA preparation qualification closure;
- reproducibility;
- release and validation traceability.

The documentation directory preserves current architecture documents together with historical version-specific documents.

Historical documents retain the architecture layer to which they belong.

## 2. Current Documentation Position

The current published architecture layer is:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

M15 remains the qualified semantic and implementation-mapping foundation of M16.

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

The inherited M15 implementation-mapping and qualification bridge is:

`M14 floating semantic reference`

↓

`hardware-facing numeric types`

↓

`balanced ternary hardware encoding`

↓

`deterministic fixed-point arithmetic`

↓

`M15 stateful quantized hardware shadow model`

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

`M15 qualification closure`

The current M16 execution bridge is:

`M15 qualification closure`

↓

`integrated SystemVerilog scheduler execution`

↓

`deterministic request-lane arbitration`

↓

`retained pending-route eligibility`

↓

`active-neutral first-leg execution`

↓

`pending-route completion from state 0`

↓

`distributed transition-capacity enforcement`

↓

`retained balanced ternary state writeback`

↓

`architectural and temporal assertion execution`

↓

`ten integrated invariant flags`

↓

`executable architectural RTL testbench`

↓

`M16 RTL execution qualification closure`

↓

`target-independent FPGA integration top`

↓

`asynchronous external reset assertion`

↓

`two-stage synchronous reset release`

↓

`core_ready and execution-input gating`

↓

`executable FPGA integration testbench`

↓

`M16 FPGA preparation qualification closure`

The current primary architecture document is:

`m16_rtl_core_realization_execution_semantics.md`

The inherited M15 semantic and implementation-mapping document is:

`m15_implementation_mapping_domain_interface_qualification_closure.md`

The current executable semantic reference is:

`../frp_prototype_v1_7_0.py`

The current validation records are:

- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`.

The inherited M15 validation records are:

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

The executable semantic reference preserves the following operational sequence:

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

Across successive semantic-reference ticks:

`evolved phase field`

↓

`next phase-derived ternary target`

↓

`distributed transition`

↓

`active neutral routing`

↓

`retained coherent ternary state`

The M16 RTL execution chain preserves the retained-state execution boundary as:

`scheduler execution`

↓

`pending-route eligibility`

↓

`request-lane arbitration`

↓

`active-neutral transition generation`

↓

`transition-capacity admission`

↓

`retained-state writeback`

↓

`counter and telemetry update`

↓

`integrated invariant evaluation`

The M16 FPGA preparation boundary adds:

`asynchronous external reset assertion`

↓

`two-stage synchronous reset release`

↓

`core_ready generation`

↓

`execution-input gating before readiness`

↓

`qualified M16 RTL execution`

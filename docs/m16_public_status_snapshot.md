# FRP M16 Public Status Snapshot

## Status

`PUBLIC STATUS SYNCHRONIZED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`Fractal Resonance Processor (FRP)`

`Ternary Fractal Resonant Coherence Processor`

## Purpose

This document records the current public-facing FRP v1.8.0 M16 release, qualification, and closure status.

## Current Public Status

| Record | Value |
|---|---|
| Current version | `FRP v1.8.0` |
| Current milestone | `M16 — RTL Core Realization and Execution Semantics Package` |
| Current validation result | `PASS` |
| Python executable semantic reference | `frp_prototype_v1_7_0.py` |
| Structured-output schema | `frp.structured_output.v1.7.0` |
| Benchmark-matrix schema | `frp.m3.benchmark_matrix.v1.7.0` |
| Inherited M15 qualification | `41 / 41 PASS` |
| M16 RTL result | `SUCCESS` |
| M16 RTL status | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation result | `SUCCESS` |
| M16 FPGA preparation status | `M16 FPGA PREPARATION LAYER CLOSED` |

M15 remains the qualified semantic and implementation-mapping foundation of M16.

M16 is the current RTL execution and FPGA preparation layer.

## README Public Status Surface

The root `README.md` displays:

- version `v1.8.0`;
- Python `3.11+`;
- Apache License 2.0;
- `FRP M16 RTL Artifact Boundary` workflow status;
- `FRP M16 FPGA Preparation` workflow status;
- the FRP v1.8.0 M16 architecture image.

Architecture image:

`docs/frp_v1_8_0_m16_architecture-1.gif`

## M15 Qualification Foundation

Inherited M15 release:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Inherited M15 qualification records:

| Qualification record | Result |
|---|---:|
| M15 self-test suite | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

## M16 RTL Execution Status

Qualified RTL source boundary:

`rtl/m16/`

Qualified RTL boundary:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

M16 RTL qualification records:

| Qualification record | Workflow run | Qualified commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---|---:|---|
| Initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | — | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| Qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `52s` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

Current RTL workflow:

`FRP M16 RTL Artifact Boundary`

Current RTL workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Qualified RTL execution domains:

- Verilator parsing;
- module elaboration;
- executable testbench generation;
- architectural simulation;
- assertion execution;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- scheduler execution;
- deterministic request-lane arbitration;
- active-neutral routing;
- pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten integrated invariant flags;
- terminal zero-event validation;
- repository-integrity validation;
- qualification artifact generation.

Qualified RTL terminal records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

Current RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

## M16 FPGA Preparation Status

Qualified FPGA preparation boundary:

`fpga/m16/`

Qualified FPGA preparation artifact boundary:

`2 SystemVerilog artifacts + 2 documentation artifacts`

M16 FPGA preparation qualification records:

| Qualification record | Workflow run | Qualified commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---|---:|---|
| Initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1m 7s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| Qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `36s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

Current FPGA preparation workflow:

`FRP M16 FPGA Preparation`

Current FPGA preparation workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

Qualified FPGA preparation domains:

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
- ten integrated invariant flags;
- terminal zero-event validation;
- repository-integrity validation;
- qualification artifact generation.

Qualified FPGA preparation terminal records:

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

Current FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## Canonical Balanced Ternary State

Retained processor-state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Canonical hardware encoding:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

Opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Qualified zero-event records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Foundation Documents

Mathematical foundation:

`docs/mathematical_foundation.md`

Physical foundation:

`docs/physical_foundation.md`

## Current Release Records

Current test report:

`TEST_REPORT_v1_8_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`RELEASE_NOTES_v1_8_0.md`

Current release checklist:

`RELEASE_CHECKLIST_v1_8_0.md`

Current documentation index:

`docs/README.md`

Current M16 architecture document:

`docs/m16_rtl_core_realization_execution_semantics.md`

Current RTL qualification records:

- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`.

Current FPGA preparation qualification records:

- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`.

## DOI Status

DOI:

`10.5281/zenodo.21183966`

DOI URL:

`https://doi.org/10.5281/zenodo.21183966`

DOI status:

`active`

## Current Public Result

| Boundary | Result |
|---|---|
| FRP v1.8.0 release | `PASS` |
| M15 inherited qualification | `41 / 41 PASS` |
| M16 RTL execution qualification | `SUCCESS` |
| M16 RTL closure | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation qualification | `SUCCESS` |
| M16 FPGA preparation closure | `M16 FPGA PREPARATION LAYER CLOSED` |
| DOI public reference | `active` |
| Public status snapshot | `PUBLIC STATUS SYNCHRONIZED` |

## Author

Maksym Marnov

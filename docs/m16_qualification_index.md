# FRP M16 Qualification Index

## Status

`FRP v1.8.0 / M16 — PASS`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the qualification index for the M16 layer of the:

`Ternary Fractal Resonant Coherence Processor`

The index connects:

- the qualified M15 semantic and implementation-mapping foundation;
- the M16 RTL artifact boundary;
- the M16 executable architectural simulation boundary;
- the M16 assertion boundary;
- the M16 FPGA preparation artifact boundary;
- the M16 FPGA integration simulation boundary;
- the retained-state execution semantics;
- the integrated invariant records;
- the qualification workflows;
- the qualification evidence artifacts;
- the RTL and FPGA closure records.

M16 does not introduce a new Python semantic reference.

The executable Python semantic reference remains:

`frp_prototype_v1_7_0.py`

The structured-output schema remains:

`frp.structured_output.v1.7.0`

The M3 benchmark-matrix schema remains:

`frp.m3.benchmark_matrix.v1.7.0`

M16 realizes the M15-qualified retained-state execution contract as concrete RTL artifacts under:

`rtl/m16/`

The target-independent FPGA preparation boundary is located under:

`fpga/m16/`

## Current M16 Qualification State

| Qualification boundary | Current record |
|---|---|
| M15 semantic and implementation-mapping foundation | `M15 41/41 PASS` |
| M16 RTL execution layer | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation layer | `M16 FPGA PREPARATION LAYER CLOSED` |
| M16 RTL workflow result | `SUCCESS` |
| M16 FPGA preparation workflow result | `SUCCESS` |
| Current release qualification | `FRP v1.8.0 / M16 — PASS` |

Current synchronized RTL workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `52s` |
| Qualification artifact count | `1` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Current synchronized FPGA preparation workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `36s` |
| Qualification artifact count | `1` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

## M16 Qualification Documents

| Path | Indexed purpose |
|---|---|
| `docs/m16_rtl_core_realization_execution_semantics.md` | M16 RTL scope and execution semantics |
| `docs/m16_rtl_core_interface_contract.md` | M16 RTL interface contract |
| `docs/m16_balanced_ternary_state_register_map.md` | balanced ternary state-register map |
| `docs/m16_scheduler_state_rtl_realization.md` | scheduler-state RTL realization |
| `docs/m16_request_lane_arbitration_module.md` | request-lane arbitration semantics |
| `docs/m16_pending_route_register_module.md` | retained pending-route semantics |
| `docs/m16_active_neutral_transition_module.md` | active-neutral transition semantics |
| `docs/m16_transition_capacity_guard_module.md` | transition-capacity guard semantics |
| `docs/m16_retained_state_update_module.md` | retained-state update semantics |
| `docs/m16_invariant_assertion_set.md` | M16 invariant assertion set |
| `docs/m16_m15_vector_replay_compatibility_report.md` | M15-to-M16 compatibility record |
| `docs/m16_qualification_manifest.md` | M16 qualification manifest |
| `docs/m16_rtl_artifact_boundary_qualification.md` | M16 RTL artifact-boundary qualification record |
| `docs/m16_external_simulator_execution_plan.md` | Verilator execution-plan record |
| `docs/m16_artifact_boundary_test_stability_policy.md` | stable repository-fact test policy |
| `docs/m16_qualification_index.md` | current M16 qualification index |

## M16 RTL Artifact Boundary

Primary RTL directory:

`rtl/m16/`

Qualified RTL source artifacts:

| Path | Status |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | present |
| `rtl/m16/frp_m16_scheduler.sv` | present |
| `rtl/m16/frp_m16_request_lanes.sv` | present |
| `rtl/m16/frp_m16_pending_routes.sv` | present |
| `rtl/m16/frp_m16_active_neutral.sv` | present |
| `rtl/m16/frp_m16_capacity_guard.sv` | present |
| `rtl/m16/frp_m16_state_update.sv` | present |
| `rtl/m16/frp_m16_core.sv` | present |
| `rtl/m16/frp_m16_assertions.sv` | present |
| `rtl/m16/frp_m16_tb.sv` | present |

RTL source artifact count:

`10`

RTL source artifact inventory result:

`PASS`

Qualified RTL documentation artifacts:

| Path | Indexed purpose | Status |
|---|---|---|
| `rtl/m16/README.md` | RTL directory and module index | present |
| `rtl/m16/ARTIFACTS.md` | RTL artifact and interface record | present |
| `rtl/m16/SIMULATION.md` | executable simulation instructions | present |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | qualified simulation transcript | present |
| `rtl/m16/CLOSURE.md` | RTL execution closure record | present |

RTL documentation artifact count:

`5`

RTL documentation artifact inventory result:

`PASS`

## M16 FPGA Preparation Artifact Boundary

Primary FPGA preparation directory:

`fpga/m16/`

Qualified FPGA preparation SystemVerilog artifacts:

| Path | Indexed purpose | Status |
|---|---|---|
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration top | present |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration testbench | present |

FPGA preparation SystemVerilog artifact count:

`2`

Qualified FPGA preparation documentation artifacts:

| Path | Indexed purpose | Status |
|---|---|---|
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA integration simulation transcript | present |
| `fpga/m16/CLOSURE.md` | FPGA preparation closure record | present |

FPGA preparation documentation artifact count:

`2`

FPGA preparation artifact inventory result:

`PASS`

Qualified RTL dependencies used by the FPGA preparation workflow:

`9`

FPGA synthesis top:

`frp_m16_fpga_top`

FPGA simulation top:

`frp_m16_fpga_tb`

## M16 RTL Qualification Record

Initial qualified RTL workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification artifact count | `1` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Synchronized RTL workflow record:

| Field | Recorded value |
|---|---|
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `52s` |
| Qualification artifact count | `1` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

The qualified RTL execution boundary records:

| Qualification item | Result |
|---|---|
| exact SystemVerilog artifact inventory | `PASS` |
| RTL documentation inventory | `PASS` |
| obsolete workflow absence | `PASS` |
| SystemVerilog parsing | `PASS` |
| module elaboration | `PASS` |
| combinational latch validation | `PASS` |
| executable testbench generation | `PASS` |
| architectural simulation | `PASS` |
| assertion execution | `PASS` |
| `free` scheduler execution | `PASS` |
| `7/1` scheduler execution | `PASS` |
| `1/7` scheduler execution | `PASS` |
| request-lane arbitration | `PASS` |
| active-neutral routing | `PASS` |
| retained pending polarity | `PASS` |
| pending-route completion | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariant validation | `PASS` |
| repository-integrity validation | `PASS` |
| qualification evidence generation | `PASS` |

Qualified RTL terminal record:

| Field | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| integrated invariant flags | `1111111111` |

RTL qualification completion marker:

`FRP M16 deterministic RTL testbench completed.`

RTL qualification result:

`PASS`

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## M16 FPGA Preparation Qualification Record

Initial qualified FPGA preparation workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#1` |
| Qualified repository commit | `326b69e` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `1m 7s` |
| Qualification artifact count | `1` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

Synchronized FPGA preparation workflow record:

| Field | Recorded value |
|---|---|
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `36s` |
| Qualification artifact count | `1` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

The qualified FPGA preparation boundary records:

| Qualification item | Result |
|---|---|
| FPGA SystemVerilog artifact inventory | `PASS` |
| qualified RTL dependency inventory | `PASS` |
| FPGA integration-top parsing | `PASS` |
| FPGA integration-top elaboration | `PASS` |
| executable FPGA testbench generation | `PASS` |
| FPGA integration testbench execution | `PASS` |
| latch-diagnostic rejection | `PASS` |
| multidriven-diagnostic rejection | `PASS` |
| asynchronous external reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| tick gating before `core_ready` | `PASS` |
| counter-clear gating before `core_ready` | `PASS` |
| request-valid gating before `core_ready` | `PASS` |
| scheduler propagation | `PASS` |
| request-interface propagation | `PASS` |
| active-neutral first-leg execution | `PASS` |
| retained pending-route completion | `PASS` |
| all ten invariant flags | `PASS` |
| repository-integrity validation | `PASS` |
| qualification evidence generation | `PASS` |

Qualified FPGA preparation terminal record:

| Field | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| reset release stages | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

FPGA integration completion marker:

`FRP M16 FPGA integration testbench completed.`

FPGA preparation qualification result:

`PASS`

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## M16 Test and Workflow Boundary

Repository artifact-manifest test:

`tests/test_m16_rtl_artifact_manifest.py`

The test validates:

- the exact ten-file M16 RTL SystemVerilog artifact set;
- the five required RTL documentation artifacts;
- nonempty RTL and documentation artifacts;
- canonical balanced ternary package symbols;
- scheduler execution modes;
- scheduler sequence implementation;
- deterministic request-lane order;
- retained pending polarity;
- active-neutral routing;
- transition-capacity admission;
- retained-state update semantics;
- integrated invariant outputs;
- simulation command records;
- zero-event invariant records.

M16 RTL qualification workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow trigger:

`workflow_dispatch`

RTL testbench build command:

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_tb \
      -Irtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      rtl/m16/frp_m16_tb.sv

RTL testbench execution command:

    /tmp/frp_m16_obj/Vfrp_m16_tb

M16 FPGA preparation workflow:

`.github/workflows/frp-m16-fpga-preparation.yml`

Workflow trigger:

`workflow_dispatch`

FPGA integration-top elaboration command:

    verilator \
      --sv \
      --lint-only \
      --top-module frp_m16_fpga_top \
      -Irtl/m16 \
      -Ifpga/m16 \
      fpga/m16/frp_m16_fpga_top.sv

FPGA integration testbench build command:

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_fpga_tb \
      -Irtl/m16 \
      -Ifpga/m16 \
      --Mdir /tmp/frp_m16_fpga_obj \
      fpga/m16/frp_m16_fpga_tb.sv

FPGA integration testbench execution command:

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

The workflows generate qualification evidence under isolated `/tmp` paths.

Repository-local simulator build directories are absent after qualification execution.

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## Test Stability Policy

The M16 test stability policy is defined in:

`docs/m16_artifact_boundary_test_stability_policy.md`

The policy applies to:

`tests/test_m16_rtl_artifact_manifest.py`

The test boundary validates stable repository and architectural facts.

Stable test targets include:

- required directory existence;
- exact required file inventories;
- nonempty required artifacts;
- canonical package symbols;
- canonical balanced ternary encodings;
- scheduler modes and scheduler-state symbols;
- RTL module declarations;
- request-lane ordering terms;
- active-neutral routing terms;
- retained pending-route terms;
- transition-capacity relations;
- retained-state update terms;
- assertion invariant terms;
- simulator command records;
- completion markers;
- zero-event invariant declarations.

The tests do not depend on exact values for:

- GitHub Actions workflow run numbers;
- commit hashes;
- live workflow status;
- workflow timestamps;
- workflow durations;
- user-interface status text;
- temporary development-status phrases.

## Preserved Execution Chain

The closed M16 retained-state execution chain is:

`phase-derived balanced ternary target`

→ `temporal scheduler state`

→ `pending-route completion priority`

→ `deterministic request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `distributed transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry`

→ `integrated invariant evaluation`

Execution-chain qualification result:

`PASS`

## Preserved Zero-Event Invariants

The M16 RTL execution boundary records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The M16 FPGA preparation boundary records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

| Invariant record | RTL result | FPGA preparation result |
|---|---:|---:|
| `actual_direct_events` | `0` | `0` |
| `reserved_state_events` | `0` | `0` |
| `queue_overflow_events` | `0` | `0` |

Zero-event invariant result:

`PASS`

## Canonical Balanced Ternary Encoding

M16 preserves the canonical balanced ternary processor-state domain:

`{-1, 0, 1}`

Canonical hardware encoding:

| Ternary state | Encoding | State classification |
|---:|---|---|
| `-1` | `2'b11` | valid negative state |
| `0` | `2'b00` | valid active neutral state |
| `1` | `2'b01` | valid positive state |
| reserved | `2'b10` | invalid processor state |

Package symbols:

| Symbol | Encoding |
|---|---|
| `FRP_TERN_NEG` | `2'b11` |
| `FRP_TERN_ZERO` | `2'b00` |
| `FRP_TERN_POS` | `2'b01` |
| `FRP_TERN_RESERVED` | `2'b10` |
| `FRP_ACTIVE_NEUTRAL` | `FRP_TERN_ZERO` |

Required retained-state invariant:

`state_out ∈ {-1, 0, 1}`

Required pending-route invariant:

`pending_route_out ∈ {-1, 0, 1}`

Required reserved-state counter:

`reserved_state_events = 0`

Balanced ternary encoding result:

`PASS`

## Scheduler Qualification Boundary

M16 preserves three scheduler execution modes:

| Mode | Execution sequence |
|---|---|
| `free` | every enabled tick is free and commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Qualified scheduler profiles:

| Mode | Qualified tick count | Qualified scheduler-state counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Required scheduler-count relation:

`sum(scheduler_state_counts) = ticks_recorded`

The scheduler counter-clear path preserves:

- retained balanced ternary state;
- retained pending-route state;
- scheduler mode;
- scheduler execution position.

Scheduler qualification result:

`PASS`

## Transition-Capacity Qualification Boundary

M16 preserves the inherited transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Validated inherited profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Qualified M16 RTL profile:

| Parameter | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Required admission relation:

`accepted_changes <= REQUEST_LANES`

Required capacity-remaining relation:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required capacity-exhausted relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

Required switch-load relation:

`switch_load_numerator = accepted_changes`

Admission order:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit requests in ascending request-lane order.

Same-state retention consumes no transition capacity.

Each accepted state-changing route leg consumes transition capacity on its execution tick.

Transition-capacity qualification result:

`PASS`

## Active-Neutral Qualification Boundary

Active neutral state `0` is an executable balancing, damping, transition, and stabilization state.

Forbidden direct retained-state transitions:

`-1 → 1`

`1 → -1`

Required routed retained-state transitions:

`-1 → 0 → 1`

`1 → 0 → -1`

Each route leg is executed on a separate eligible tick.

Required direct-transition counter:

`actual_direct_events = 0`

Active-neutral routing result:

`PASS`

## Pending-Route Qualification Boundary

Opposite-polarity requests create retained pending routes.

For the request:

`1 → -1`

the first eligible route leg executes:

`1 → 0`

and stores:

`pending_route = -1`

A later eligible tick completes:

`0 → -1`

For the request:

`-1 → 1`

the first eligible route leg executes:

`-1 → 0`

and stores:

`pending_route = 1`

A later eligible tick completes:

`0 → 1`

The retained pending-route boundary records:

- one pending-route slot per processor cell;
- exact requested polarity retention;
- pending-route ownership of its cell;
- pending-route priority over new same-cell requests;
- pending-route stability across scheduler-ineligible ticks;
- pending-route stability across transition-capacity deferral;
- completion only from retained active neutral state `0`;
- clearing after accepted completion writeback.

Required queue-overflow counter:

`queue_overflow_events = 0`

Pending-route qualification result:

`PASS`

## Retained-State Writeback Boundary

The retained-state register commits only transitions admitted by the transition-capacity guard.

The writeback boundary records:

- canonical balanced ternary output;
- same-state retention;
- active-neutral first-leg writeback;
- pending-route completion writeback;
- capacity-mask correlation;
- zero direct opposite-polarity writeback;
- zero reserved-state output.

Required retained-state domain:

`state_out ∈ {-1, 0, 1}`

Required direct-transition counter:

`actual_direct_events = 0`

Required reserved-state counter:

`reserved_state_events = 0`

Retained-state writeback qualification result:

`PASS`

## Integrated Invariant Set

The M16 core exposes ten integrated invariant flags.

| Index | Invariant flag |
|---:|---|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` |
| `8` | `FRP_INV_NO_RESERVED_STATE` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` |

Integrated invariant-vector width:

`FRP_M16_INVARIANT_FLAGS = 10`

Qualified RTL invariant vector:

`1111111111`

Qualified FPGA preparation invariant vector:

`1111111111`

| Invariant flag | RTL result | FPGA preparation result |
|---|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | `PASS` | `PASS` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` | `PASS` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` | `PASS` |
| `FRP_INV_PENDING_POLARITY_VALID` | `PASS` | `PASS` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` | `PASS` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID` | `PASS` | `PASS` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` | `PASS` |
| `FRP_INV_NO_RESERVED_STATE` | `PASS` | `PASS` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` | `PASS` |

Integrated invariant qualification result:

`PASS`

## M15 Inherited Qualification Base

M16 inherits the qualified M15 semantic and implementation-mapping foundation.

M15 workflow:

`FRP M15 Implementation Mapping and Qualification Closure`

M15 workflow file:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

M15 qualified workflow record:

`FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`

M15 qualification evidence:

| Qualification record | Result |
|---|---:|
| self-test assertions | `41 / 41 PASS` |
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

M15 established:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- semantic and implementation-mapping qualification closure.

M15 inherited qualification result:

`PASS`

## M15 to M16 Compatibility Chain

The indexed compatibility chain is:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M15 SystemVerilog interface mapping`

→ `M16 temporal scheduler`

→ `M16 request-lane arbitration`

→ `M16 active-neutral routing`

→ `M16 retained pending polarity`

→ `M16 transition-capacity admission`

→ `M16 retained-state writeback`

→ `M16 assertion layer`

→ `M16 executable RTL qualification`

The M15 semantic reference remains:

`frp_prototype_v1_7_0.py`

The M16 RTL implementation boundary is:

`rtl/m16/frp_m16_core.sv`

The M16 RTL assertion boundary is:

`rtl/m16/frp_m16_assertions.sv`

The M16 executable RTL testbench is:

`rtl/m16/frp_m16_tb.sv`

The M16 FPGA integration boundary is:

`fpga/m16/frp_m16_fpga_top.sv`

M15-to-M16 compatibility record:

`PASS`

## External Simulator Boundary

Simulation instructions are defined in:

`rtl/m16/SIMULATION.md`

The qualified RTL simulation transcript is defined in:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

The simulator execution-plan record is defined in:

`docs/m16_external_simulator_execution_plan.md`

Qualified simulator:

`Verilator`

Qualified RTL testbench build command:

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_tb \
      -Irtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      rtl/m16/frp_m16_tb.sv

Qualified RTL testbench execution command:

    /tmp/frp_m16_obj/Vfrp_m16_tb

Required completion marker:

`FRP M16 deterministic RTL testbench completed.`

Qualified terminal counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Qualified integrated invariant vector:

`1111111111`

External simulator workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

External simulator boundary result:

`PASS`

## FPGA Integration Boundary

The M16 FPGA integration boundary is target-independent.

FPGA integration top:

`fpga/m16/frp_m16_fpga_top.sv`

FPGA integration testbench:

`fpga/m16/frp_m16_fpga_tb.sv`

The FPGA integration boundary records:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input blocking before `core_ready`;
- tick propagation after `core_ready`;
- counter-clear propagation after `core_ready`;
- request-valid propagation after `core_ready`;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten integrated invariant flags;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events.

Qualified execution-input gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Qualified FPGA integration completion marker:

`FRP M16 FPGA integration testbench completed.`

FPGA preparation workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

FPGA integration qualification result:

`PASS`

## Qualification Evidence Index

M16 RTL qualification evidence artifact:

`frp-m16-rtl-qualification-${{ github.run_number }}`

The RTL qualification evidence artifact contains:

- toolchain record;
- SystemVerilog source hashes;
- Verilator build log;
- architectural execution log;
- qualification result record.

M16 FPGA preparation qualification evidence artifact:

`frp-m16-fpga-preparation-${{ github.run_number }}`

The FPGA preparation qualification evidence artifact contains:

- toolchain record;
- RTL and FPGA source hashes;
- FPGA integration-top lint log;
- FPGA integration-testbench build log;
- FPGA integration-testbench execution log;
- FPGA preparation qualification record.

Workflow evidence retention:

`30 days`

RTL qualification evidence result:

`PASS`

FPGA preparation qualification evidence result:

`PASS`

## Current Qualification Result

| Qualification boundary | Result |
|---|---|
| M15 semantic and implementation-mapping foundation | `41 / 41 PASS` |
| M15 deterministic vector regeneration | `10 / 10 byte-identical` |
| M15 semantic correlation | `5 / 5 = 1.0` |
| M15 deterministic replay | `6 / 6 = 1.0` |
| M16 RTL source artifact inventory | `PASS` |
| M16 RTL documentation artifact inventory | `PASS` |
| M16 SystemVerilog parsing and elaboration | `PASS` |
| M16 executable RTL testbench | `PASS` |
| M16 architectural simulation | `PASS` |
| M16 assertion execution | `PASS` |
| M16 scheduler execution | `PASS` |
| M16 request-lane arbitration | `PASS` |
| M16 active-neutral routing | `PASS` |
| M16 retained pending polarity | `PASS` |
| M16 transition-capacity enforcement | `PASS` |
| M16 retained-state writeback | `PASS` |
| M16 integrated invariant set | `PASS` |
| M16 RTL zero-event counters | `PASS` |
| M16 RTL repository integrity | `PASS` |
| M16 RTL qualification evidence | `PASS` |
| M16 RTL execution layer | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation artifact inventory | `PASS` |
| M16 FPGA integration-top elaboration | `PASS` |
| M16 FPGA integration-testbench execution | `PASS` |
| M16 reset and `core_ready` boundary | `PASS` |
| M16 FPGA execution-input gating | `PASS` |
| M16 FPGA scheduler and request propagation | `PASS` |
| M16 FPGA active-neutral route execution | `PASS` |
| M16 FPGA pending-route completion | `PASS` |
| M16 FPGA integrated invariant set | `PASS` |
| M16 FPGA zero-event counters | `PASS` |
| M16 FPGA repository integrity | `PASS` |
| M16 FPGA qualification evidence | `PASS` |
| M16 FPGA preparation layer | `M16 FPGA PREPARATION LAYER CLOSED` |

## Qualification Closure

Current release:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`frp_prototype_v1_7_0.py`

Current inherited semantic and implementation-mapping foundation:

`M15 41/41 PASS`

Current RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current qualification state:

`FRP v1.8.0 / M16 — PASS`

## Author

Maksym Marnov

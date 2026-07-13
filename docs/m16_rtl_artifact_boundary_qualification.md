# FRP M16 RTL Artifact Boundary Qualification

## Status

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document records the M16 RTL artifact-boundary qualification result for the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL artifact boundary realizes the M15-qualified retained-state execution contract as concrete SystemVerilog RTL artifacts under:

`rtl/m16/`

M16 does not introduce a new processor model.

M16 preserves the M15-qualified execution semantics and exposes them through:

- RTL source artifacts;
- RTL documentation artifacts;
- assertion layer;
- deterministic smoke testbench;
- artifact-boundary workflow;
- artifact-boundary pytest validation;
- public status snapshot;
- test stability policy;
- qualification manifest;
- qualification index;
- RTL closure report.

## Qualification Result

Current M16 RTL artifact-boundary qualification result:

`PASS`

Current M16 artifact-boundary closure result:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Current simulator closure result:

`SIMULATOR CLOSURE PENDING`

Current external simulator status:

`pending external simulator execution`

Current simulator transcript status:

`pending simulator transcript capture`

## Qualified Workflow

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow result:

`PASS`

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

Workflow validation command:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

Artifact-boundary test result:

`PASS`

## Qualified RTL Source Boundary

Primary RTL source directory:

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

RTL source artifact inventory result:

`PASS`

## Qualified RTL Documentation Boundary

Qualified RTL documentation artifacts:

| Path | Status |
|---|---|
| `rtl/m16/README.md` | present |
| `rtl/m16/ARTIFACTS.md` | present |
| `rtl/m16/SIMULATION.md` | present |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | present |
| `rtl/m16/CLOSURE.md` | ARTIFACT-BOUNDARY CLOSURE COMPLETE |

RTL documentation artifact inventory result:

`PASS`

## RTL Closure Report

The M16 RTL closure report is defined in:

`rtl/m16/CLOSURE.md`

Current RTL closure status:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Current simulator closure status:

`SIMULATOR CLOSURE PENDING`

The closure report records:

- M16 RTL source artifact inventory `PASS`;
- M16 RTL documentation artifact inventory `PASS`;
- M16 documentation artifact inventory `PASS`;
- M16 repository exposure `PASS`;
- M16 artifact-boundary workflow `PASS`;
- M16 artifact-boundary tests `PASS`;
- M16 public status snapshot `PUBLIC STATUS SYNCHRONIZED`;
- M16 test stability policy `ACTIVE`;
- M15 inherited qualification `M15 41/41 PASS`;
- M16 artifact-boundary closure `ARTIFACT-BOUNDARY CLOSURE COMPLETE`;
- M16 external simulator execution `pending`;
- M16 simulator transcript capture `pending`;
- M16 final simulator closure `SIMULATOR CLOSURE PENDING`.

## Qualified Documentation Boundary

Qualified M16 documentation artifacts:

| Path | Status |
|---|---|
| `docs/m16_rtl_core_realization_execution_semantics.md` | implemented |
| `docs/m16_rtl_core_interface_contract.md` | implemented |
| `docs/m16_balanced_ternary_state_register_map.md` | implemented |
| `docs/m16_scheduler_state_rtl_realization.md` | implemented |
| `docs/m16_request_lane_arbitration_module.md` | implemented |
| `docs/m16_pending_route_register_module.md` | implemented |
| `docs/m16_active_neutral_transition_module.md` | implemented |
| `docs/m16_transition_capacity_guard_module.md` | implemented |
| `docs/m16_retained_state_update_module.md` | implemented |
| `docs/m16_invariant_assertion_set.md` | implemented |
| `docs/m16_m15_vector_replay_compatibility_report.md` | implemented |
| `docs/m16_qualification_manifest.md` | ACTIVE |
| `docs/m16_rtl_artifact_boundary_qualification.md` | current file |
| `docs/m16_qualification_index.md` | ACTIVE |
| `docs/m16_external_simulator_execution_plan.md` | PLANNED |
| `docs/m16_artifact_boundary_test_stability_policy.md` | ACTIVE |
| `docs/m16_public_status_snapshot.md` | PUBLIC STATUS SYNCHRONIZED |

M16 documentation artifact inventory result:

`PASS`

## Public Status Snapshot

The current public-facing M16 status is recorded in:

`docs/m16_public_status_snapshot.md`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

The public status snapshot synchronizes:

- README badge panel status;
- GitHub About / Description status;
- M15 `41 / 41 PASS` qualification evidence;
- M16 RTL artifact-boundary `PASS`;
- `rtl/m16/` source artifact presence;
- external simulator pending boundary;
- FPGA / synthesis preparation position;
- DOI public reference.

Public status snapshot result:

`PUBLIC STATUS SYNCHRONIZED`

## Artifact-Boundary Test Stability Policy

The M16 artifact-boundary test stability policy is defined in:

`docs/m16_artifact_boundary_test_stability_policy.md`

Current policy status:

`ACTIVE`

The test stability policy requires tests to validate stable semantic repository facts.

The artifact-boundary tests must not depend on:

- GitHub Actions run numbers;
- current commit hashes;
- workflow timestamps;
- workflow duration;
- UI-only status text;
- old failed workflow runs.

Stable validation targets include:

- required file existence;
- canonical package symbols;
- RTL module references;
- assertion invariant terms;
- simulator command boundary;
- zero-event invariant declarations;
- repository documentation exposure;
- artifact-boundary status terms;
- external simulator pending status;
- M15 inherited package digest.

Test stability policy result:

`ACTIVE`

## M16 Qualification Manifest

The M16 qualification manifest is defined in:

`docs/m16_qualification_manifest.md`

Current manifest status:

`ACTIVE`

Current manifest artifact-boundary result:

`PASS`

Current manifest closure result:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Current manifest simulator closure result:

`SIMULATOR CLOSURE PENDING`

## M16 Qualification Index

The M16 qualification index is defined in:

`docs/m16_qualification_index.md`

Current index status:

`ACTIVE`

Current index artifact-boundary result:

`PASS`

Current index closure result:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Current index simulator closure result:

`SIMULATOR CLOSURE PENDING`

## Preserved Execution Chain

M16 preserves the retained-state execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Execution-chain artifact-boundary result:

`PASS`

## Canonical Balanced Ternary Encoding

M16 preserves the canonical balanced ternary encoding:

| Ternary state | Encoding | Status |
|---|---|---|
| `-1` | `2'b11` | valid |
| `0` | `2'b00` | valid active neutral |
| `+1` | `2'b01` | valid |
| reserved | `2'b10` | invalid |

Required invariant:

`reserved_state_events = 0`

Balanced ternary encoding result:

`PASS`

## Active-Neutral Transition Boundary

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed transitions:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

Active-neutral transition result:

`PASS`

## Pending-Route Boundary

Opposite-polarity requests must create retained pending routes.

For:

`+1 → -1`

M16 executes:

`+1 → 0`

and stores:

`pending_route = -1`

A later eligible tick completes:

`0 → -1`

For:

`-1 → +1`

M16 executes:

`-1 → 0`

and stores:

`pending_route = +1`

A later eligible tick completes:

`0 → +1`

Required invariant:

`queue_overflow_events = 0`

Pending-route result:

`PASS`

## Transition-Capacity Boundary

M16 preserves the inherited transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Validated inherited profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load relation:

`switch_load_numerator = accepted_changes`

Transition-capacity result:

`PASS`

## Scheduler Boundary

M16 preserves three scheduler execution modes:

| Mode | Meaning |
|---|---|
| `free` | every enabled tick is free / commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Required inherited scheduler profiles:

| Mode | Required profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Scheduler result:

`PASS`

## Zero-Event Invariant Boundary

The M16 RTL artifact-boundary qualification preserves the following invariant targets:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Zero-event invariant artifact-boundary result:

`PASS`

These are artifact-boundary invariants and external simulator closure targets.

## Assertion Boundary

Assertion layer:

`rtl/m16/frp_m16_assertions.sv`

Required assertion terms:

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS`

`FRP_INV_NO_RESERVED_STATE`

`FRP_INV_NO_QUEUE_OVERFLOW`

Assertion artifact-boundary result:

`PASS`

Runtime assertion execution remains part of the external simulator closure boundary.

## Deterministic Testbench Boundary

Deterministic smoke testbench:

`rtl/m16/frp_m16_tb.sv`

Required completion marker:

`FRP M16 deterministic RTL testbench completed.`

The testbench artifact is present and indexed.

Testbench artifact-boundary result:

`PASS`

Runtime testbench execution remains part of the external simulator closure boundary.

## External Simulator Boundary

Simulation instructions are defined in:

`rtl/m16/SIMULATION.md`

Transcript template is defined in:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

Execution plan is defined in:

`docs/m16_external_simulator_execution_plan.md`

Required command shape:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Required run command:

    ./obj_dir/Vfrp_m16_tb

Required completion marker:

    FRP M16 deterministic RTL testbench completed.

Required final counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current external simulator status:

`pending external simulator execution`

Current simulator transcript status:

`pending simulator transcript capture`

Current simulator closure status:

`SIMULATOR CLOSURE PENDING`

External simulator boundary result:

`SIMULATOR CLOSURE PENDING`

## M15 Inherited Qualification Base

M16 inherits the M15 qualification boundary.

Current inherited status:

`M15 41/41 PASS`

M15 established:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vector package;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

M15 inherited qualification result:

`PASS`

## M15 to M16 Compatibility Chain

Compatibility chain:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 simulation transcript`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

Compatibility-chain artifact-boundary result:

`PASS`

Runtime replay confirmation remains part of the external simulator closure boundary.

## Current Qualification Table

| Boundary | Result |
|---|---|
| M16 RTL source artifact inventory | PASS |
| M16 RTL documentation artifact inventory | PASS |
| M16 documentation artifact inventory | PASS |
| M16 repository exposure | PASS |
| M16 artifact-boundary workflow | PASS |
| M16 artifact-boundary tests | PASS |
| M16 public status snapshot | PUBLIC STATUS SYNCHRONIZED |
| M16 test stability policy | ACTIVE |
| M16 qualification manifest | ACTIVE |
| M16 qualification index | ACTIVE |
| M16 RTL closure report | ARTIFACT-BOUNDARY CLOSURE COMPLETE |
| M15 inherited qualification | M15 41/41 PASS |
| M16 artifact-boundary qualification | PASS |
| M16 artifact-boundary closure | ARTIFACT-BOUNDARY CLOSURE COMPLETE |
| M16 external simulator execution | pending |
| M16 simulator transcript capture | pending |
| M16 simulator closure | SIMULATOR CLOSURE PENDING |

## Qualification Statement

The M16 RTL artifact boundary is qualified at the repository artifact level.

The repository contains the required M16 RTL source artifacts, RTL documentation artifacts, M16 documentation artifacts, workflow path filters, pytest validation boundary, public status snapshot, test stability policy, qualification manifest, qualification index, and RTL closure report.

The current qualification state is:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

The remaining simulator state is:

`SIMULATOR CLOSURE PENDING`

No final simulator qualification is claimed until an external simulator run is executed and the simulator transcript is captured.

## Next Qualification Step

Next qualification step:

`external simulator execution`

Required follow-up files after simulator execution:

- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`;
- `docs/m16_qualification_manifest.md`;
- `docs/m16_qualification_index.md`;
- final M16 simulator closure document.

## Author

Maksym Marnov

# FRP M16 Qualification Index

## Status

`ACTIVE`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the qualification index for the M16 layer of the:

`Ternary Fractal Resonant Coherence Processor`

The index connects the M16 RTL artifact boundary, documentation boundary, retained-state execution semantics, zero-event invariants, M15 inherited qualification base, public status snapshot, artifact-boundary test stability policy, RTL closure report, and remaining external simulator transcript boundary.

M16 does not introduce a new processor model.

M16 realizes the M15-qualified retained-state execution contract as concrete RTL artifacts under:

`rtl/m16/`

## Current M16 Qualification State

Current M16 artifact-boundary qualification result:

`PASS`

Current M16 artifact-boundary closure result:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Current workflow result:

`PASS`

Current artifact-boundary test result:

`PASS`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

Current test stability policy:

`ACTIVE`

Current external simulator transcript status:

`pending external simulator execution`

Current simulator closure status:

`SIMULATOR CLOSURE PENDING`

Current final M16 closure status:

`pending simulator transcript capture`

## M16 Qualification Documents

| Path | Purpose | Status |
|---|---|---|
| `docs/m16_rtl_core_realization_execution_semantics.md` | M16 RTL scope and execution semantics | implemented |
| `docs/m16_rtl_core_interface_contract.md` | M16 RTL interface contract | implemented |
| `docs/m16_balanced_ternary_state_register_map.md` | balanced ternary state-register map | implemented |
| `docs/m16_scheduler_state_rtl_realization.md` | scheduler-state RTL realization | implemented |
| `docs/m16_request_lane_arbitration_module.md` | request-lane arbitration module semantics | implemented |
| `docs/m16_pending_route_register_module.md` | pending-route register semantics | implemented |
| `docs/m16_active_neutral_transition_module.md` | active-neutral transition semantics | implemented |
| `docs/m16_transition_capacity_guard_module.md` | transition-capacity guard semantics | implemented |
| `docs/m16_retained_state_update_module.md` | retained-state update semantics | implemented |
| `docs/m16_invariant_assertion_set.md` | M16 invariant assertion set | implemented |
| `docs/m16_m15_vector_replay_compatibility_report.md` | M15 vector replay compatibility boundary | implemented |
| `docs/m16_qualification_manifest.md` | M16 qualification manifest | ACTIVE |
| `docs/m16_rtl_artifact_boundary_qualification.md` | M16 RTL artifact-boundary PASS report | PASS |
| `docs/m16_external_simulator_execution_plan.md` | external simulator execution plan | PLANNED |
| `docs/m16_artifact_boundary_test_stability_policy.md` | artifact-boundary test stability policy | ACTIVE |
| `docs/m16_public_status_snapshot.md` | public-facing M16 status snapshot | PUBLIC STATUS SYNCHRONIZED |
| `docs/m16_qualification_index.md` | current M16 qualification index | current file |

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

RTL source artifact inventory result:

`PASS`

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

The current M16 RTL closure report is defined in:

`rtl/m16/CLOSURE.md`

Current RTL closure status:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Current simulator closure status:

`SIMULATOR CLOSURE PENDING`

The RTL closure report records:

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

## M16 Test and Workflow Boundary

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

Qualified workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Workflow result:

`PASS`

Artifact-boundary test result:

`PASS`

The workflow validates the M16 RTL artifact boundary through:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

The workflow path filters include:

- `rtl/m16/**`;
- `tests/test_m16_rtl_artifact_manifest.py`;
- repository exposure files;
- M16 qualification documents;
- M16 external simulator execution plan;
- M16 artifact-boundary test stability policy;
- M16 public status snapshot.

## Test Stability Policy

The M16 test stability policy is defined in:

`docs/m16_artifact_boundary_test_stability_policy.md`

Current policy result:

`ACTIVE`

The policy requires tests to validate stable semantic repository facts.

Tests must not require exact values for:

- GitHub Actions run numbers;
- current commit hashes;
- workflow timestamps;
- workflow duration;
- UI-only status text;
- old failed workflow runs.

Stable test targets include:

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

## Public Status Snapshot

The current public-facing M16 status is recorded in:

`docs/m16_public_status_snapshot.md`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

The public snapshot synchronizes:

- README badge panel status;
- GitHub About / Description status;
- M15 `41 / 41 PASS` qualification evidence;
- M16 RTL artifact-boundary `PASS`;
- `rtl/m16/` source artifact presence;
- external simulator pending boundary;
- FPGA / synthesis preparation position;
- DOI public reference.

## Preserved Execution Chain

M16 preserves the retained-state execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

## Preserved Zero-Event Invariants

The M16 qualification boundary preserves:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

These are artifact-boundary invariants and simulation-closure targets.

Zero-event invariant artifact-boundary result:

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

## Scheduler Qualification Boundary

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

Scheduler artifact-boundary result:

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

Required invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load relation:

`switch_load_numerator = accepted_changes`

Transition-capacity artifact-boundary result:

`PASS`

## Active-Neutral Qualification Boundary

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed transitions:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

Active-neutral artifact-boundary result:

`PASS`

## Pending-Route Qualification Boundary

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

Pending-route artifact-boundary result:

`PASS`

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

M15 inheritance result:

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

Current simulator closure status:

`SIMULATOR CLOSURE PENDING`

External simulator boundary result:

`SIMULATOR CLOSURE PENDING`

## Current Qualification Result

| Boundary | Result |
|---|---|
| M16 documentation package | implemented |
| M16 RTL source artifact inventory | PASS |
| M16 RTL documentation artifact inventory | PASS |
| M16 repository exposure | PASS |
| M16 artifact-boundary workflow | PASS |
| M16 artifact-boundary tests | PASS |
| M16 test stability policy | ACTIVE |
| M16 public status snapshot | PUBLIC STATUS SYNCHRONIZED |
| M16 RTL closure report | ARTIFACT-BOUNDARY CLOSURE COMPLETE |
| M15 inherited qualification | M15 41/41 PASS |
| M16 external simulator execution | pending |
| M16 simulator transcript capture | pending |
| M16 final simulator closure | SIMULATOR CLOSURE PENDING |

## Closure Direction

M16 final simulator closure requires:

- artifact-boundary workflow PASS;
- external simulator execution;
- simulator transcript capture;
- assertion-layer PASS;
- final zero-event counter confirmation;
- simulation transcript update;
- closure report update;
- final M16 qualification closure document.

Current artifact state:

`ARTIFACT-BOUNDARY CLOSURE COMPLETE`

Remaining simulator state:

`SIMULATOR CLOSURE PENDING`

## Author

Maksym Marnov

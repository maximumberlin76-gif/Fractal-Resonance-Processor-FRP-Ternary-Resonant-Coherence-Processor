# FRP M16 Qualification Manifest

## Status

`ACTIVE`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This manifest records the qualification state of the M16 layer of the:

`Ternary Fractal Resonant Coherence Processor`

M16 realizes the M15-qualified retained-state execution contract as concrete RTL artifacts under:

`rtl/m16/`

M16 does not introduce a new processor model.

M16 preserves the M15-qualified execution semantics and exposes the retained-state execution boundary as SystemVerilog RTL modules, assertion layer, deterministic smoke testbench, artifact-boundary workflow, qualification documentation, public status snapshot, and test stability policy.

## Current Qualification Result

Current M16 RTL artifact-boundary result:

`PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

Current test stability policy:

`ACTIVE`

Current external simulator result:

`pending external simulator execution`

Current final M16 closure result:

`pending simulator transcript capture`

## M16 Qualification Documents

| Path | Purpose | Status |
|---|---|---|
| `docs/m16_rtl_core_realization_execution_semantics.md` | RTL scope and retained-state execution semantics | implemented |
| `docs/m16_rtl_core_interface_contract.md` | RTL core interface contract | implemented |
| `docs/m16_balanced_ternary_state_register_map.md` | balanced ternary state-register map | implemented |
| `docs/m16_scheduler_state_rtl_realization.md` | scheduler-state RTL realization | implemented |
| `docs/m16_request_lane_arbitration_module.md` | request-lane arbitration module | implemented |
| `docs/m16_pending_route_register_module.md` | pending-route register module | implemented |
| `docs/m16_active_neutral_transition_module.md` | active-neutral transition module | implemented |
| `docs/m16_transition_capacity_guard_module.md` | transition-capacity guard module | implemented |
| `docs/m16_retained_state_update_module.md` | retained-state update module | implemented |
| `docs/m16_invariant_assertion_set.md` | invariant assertion set | implemented |
| `docs/m16_m15_vector_replay_compatibility_report.md` | M15 replay compatibility boundary | implemented |
| `docs/m16_rtl_artifact_boundary_qualification.md` | RTL artifact-boundary PASS report | PASS |
| `docs/m16_external_simulator_execution_plan.md` | external simulator execution plan | PLANNED |
| `docs/m16_artifact_boundary_test_stability_policy.md` | artifact-boundary test stability policy | ACTIVE |
| `docs/m16_public_status_snapshot.md` | public-facing M16 status snapshot | PUBLIC STATUS SYNCHRONIZED |
| `docs/m16_qualification_index.md` | M16 qualification index | ACTIVE |
| `docs/m16_qualification_manifest.md` | current manifest | current file |

## M16 RTL Directory

Primary RTL directory:

`rtl/m16/`

Directory status:

`implemented`

Artifact-boundary status:

`PASS`

## Qualified RTL Source Artifacts

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

## Qualified RTL Documentation Artifacts

| Path | Status |
|---|---|
| `rtl/m16/README.md` | present |
| `rtl/m16/ARTIFACTS.md` | present |
| `rtl/m16/SIMULATION.md` | present |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | present |
| `rtl/m16/CLOSURE.md` | present |

## Qualified Test Boundary

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

The test verifies:

- `rtl/m16/` directory existence;
- required RTL source artifact existence;
- required RTL documentation artifact existence;
- canonical balanced ternary package symbols;
- integrated core module references;
- assertion-layer zero-event invariants;
- deterministic RTL smoke-testbench scope;
- simulation instruction boundary;
- simulation transcript placeholder boundary;
- closure document status;
- root README exposure;
- project-structure exposure;
- documentation README exposure;
- architecture document exposure;
- external simulator execution plan;
- public status snapshot exposure;
- stable semantic status terms.

## Artifact-Boundary Test Stability Policy

The test stability policy is defined in:

`docs/m16_artifact_boundary_test_stability_policy.md`

Policy status:

`ACTIVE`

The policy requires tests to validate stable semantic repository facts.

Tests must not pin unstable live GitHub metadata such as:

- exact workflow run numbers;
- current commit hashes;
- workflow timestamps;
- workflow duration;
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

## Qualified Workflow Boundary

Qualified workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Workflow result:

`PASS`

The workflow validates the M16 RTL artifact boundary through:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

Workflow path filters include:

- `rtl/m16/**`;
- `tests/test_m16_rtl_artifact_manifest.py`;
- root README;
- project structure;
- documentation README;
- architecture document;
- M16 qualification documents;
- M16 external simulator execution plan;
- M16 artifact-boundary test stability policy;
- M16 public status snapshot.

## Public Status Snapshot

The public status snapshot is defined in:

`docs/m16_public_status_snapshot.md`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

The snapshot synchronizes:

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

The M16 artifact-boundary qualification preserves the required zero-event invariant declarations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

These are both artifact-boundary invariants and simulator-closure targets.

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

## Active-Neutral Qualification Boundary

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed transitions:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

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

## M15 Inherited Qualification Base

M16 inherits the M15 qualification boundary.

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

`703dd4b56f4b342

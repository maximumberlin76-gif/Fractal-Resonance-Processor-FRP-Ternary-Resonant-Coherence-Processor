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

M16 preserves the M15-qualified execution semantics and exposes the retained-state execution boundary as SystemVerilog RTL modules, assertion layer, deterministic smoke testbench, artifact-boundary workflow, and qualification documentation.

## Current Qualification Result

Current M16 RTL artifact-boundary result:

`PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Passing workflow run:

`FRP M16 RTL Artifact Boundary #4`

Passing commit:

`762e847`

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
| `docs/m16_qualification_index.md` | M16 qualification index | implemented |
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
- architecture document exposure.

## Qualified Workflow Boundary

Qualified workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Workflow result:

`PASS`

Passing run:

`FRP M16 RTL Artifact Boundary #4`

Passing commit:

`762e847`

The workflow validates the M16 RTL artifact boundary through:

`python -m pytest tests/test_m16_rtl_artifact_manifest.py -q`

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

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

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

## Corrective Qualification Event

The initial M16 artifact-boundary workflow exposed a missing required RTL source artifact:

`rtl/m16/frp_m16_pending_routes.sv`

The missing pending-route RTL source artifact was added.

After the correction, the dedicated M16 artifact-boundary workflow passed.

Corrected result:

`FRP M16 RTL Artifact Boundary #4 — PASS`

Corrected commit:

`762e847`

## Current Qualification Table

| Boundary | Result |
|---|---|
| M16 documentation package | implemented |
| M16 RTL source artifact inventory | PASS |
| M16 RTL documentation artifact inventory | PASS |
| M16 repository exposure | PASS |
| M16 artifact-boundary workflow | PASS |
| M16 external simulator execution | pending |
| M16 simulator transcript capture | pending |
| M16 final closure | pending |

## External Simulator Boundary

Simulation instructions are defined in:

`rtl/m16/SIMULATION.md`

Transcript template is defined in:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

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

Current status:

`pending external simulator execution`

## Final M16 Closure Requirements

M16 final closure requires:

- artifact-boundary workflow PASS;
- external simulator execution;
- simulator transcript capture;
- assertion-layer PASS;
- final zero-event counter confirmation;
- simulation transcript update;
- closure report update;
- final M16 qualification closure document.

Current state:

`artifact-boundary PASS`

Remaining state:

`external simulator transcript pending`

## Manifest Result

Current M16 manifest result:

`ACTIVE`

Current M16 artifact-boundary result:

`PASS`

Current final M16 simulator result:

`pending external simulator execution`

## Author

Maksym Marnov

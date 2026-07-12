# FRP M16 RTL Closure Report

## Status

`ARTIFACT-BOUNDARY PASS`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document records the M16 RTL closure boundary for the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL layer realizes the M15-qualified retained-state execution contract as concrete SystemVerilog artifacts under:

`rtl/m16/`

M16 does not introduce a new processor model.

M16 preserves the M15-qualified execution semantics and exposes the retained-state execution boundary as RTL modules, assertion layer, deterministic smoke testbench, artifact-boundary workflow, and qualification documentation.

## Current Closure Result

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

## Closure Boundary

The M16 RTL closure boundary covers:

- RTL artifact inventory;
- canonical balanced ternary encoding;
- scheduler execution semantics;
- request-lane arbitration;
- active-neutral transition law;
- pending-route retention and completion;
- transition-capacity enforcement;
- retained-state writeback;
- assertion binding layer;
- deterministic RTL smoke testbench;
- simulation instruction boundary;
- simulation transcript boundary;
- artifact-boundary workflow;
- artifact-boundary qualification report;
- M16 qualification index;
- M16 qualification manifest;
- M15 compatibility position;
- external FPGA review boundary.

Required global closure invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Preserved Processor Identity

The RTL closure preserves the FRP execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

The upstream resonant computation layer remains inherited from the M15-qualified reference chain.

The M16 RTL core realizes the retained-state execution boundary.

## M15 Inherited Qualification Base

M16 starts from the M15 qualification boundary.

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

## M16 RTL Artifact Inventory

Current RTL artifact set:

| Artifact | Path | Status |
|---|---|---|
| package constants and encodings | `rtl/m16/frp_m16_pkg.sv` | present |
| scheduler RTL module | `rtl/m16/frp_m16_scheduler.sv` | present |
| request-lane RTL module | `rtl/m16/frp_m16_request_lanes.sv` | present |
| pending-route RTL module | `rtl/m16/frp_m16_pending_routes.sv` | present |
| active-neutral RTL module | `rtl/m16/frp_m16_active_neutral.sv` | present |
| transition-capacity RTL module | `rtl/m16/frp_m16_capacity_guard.sv` | present |
| retained-state update RTL module | `rtl/m16/frp_m16_state_update.sv` | present |
| integrated RTL core | `rtl/m16/frp_m16_core.sv` | present |
| assertion binding layer | `rtl/m16/frp_m16_assertions.sv` | present |
| deterministic RTL smoke testbench | `rtl/m16/frp_m16_tb.sv` | present |
| RTL layer README | `rtl/m16/README.md` | present |
| RTL artifact manifest | `rtl/m16/ARTIFACTS.md` | present |
| simulation instructions | `rtl/m16/SIMULATION.md` | present |
| simulation transcript template | `rtl/m16/SIMULATION_TRANSCRIPT.md` | present |
| RTL closure report | `rtl/m16/CLOSURE.md` | current file |

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
| `docs/m16_qualification_manifest.md` | M16 qualification manifest | ACTIVE |

## Qualified Test Boundary

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

The test validates:

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

Workflow validation command:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

## Canonical Encoding Closure

M16 preserves the canonical balanced ternary encoding:

| Ternary state | Encoding | Closure status |
|---|---|---|
| `-1` | `2'b11` | preserved |
| `0` | `2'b00` | preserved as active neutral |
| `+1` | `2'b01` | preserved |
| reserved | `2'b10` | forbidden |

Required closure invariant:

`reserved_state_events = 0`

Required output-domain invariant:

`state_out` contains no `2'b10`

## Scheduler Closure

M16 preserves three processor execution modes:

- `free`;
- `7/1`;
- `1/7`.

Required inherited scheduler profiles:

| Mode | Required profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Required scheduler closure relation:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

## Request-Lane Closure

M16 preserves deterministic request-lane arbitration.

Required closure properties:

- ascending lane order;
- valid cell-index checking;
- valid ternary target checking;
- duplicate-cell rejection;
- scheduler eligibility gating;
- pending-route priority protection;
- transition-capacity compatibility;
- active-neutral routing classification.

Required request-lane closure invariant:

`request_accept & request_reject = 0`

## Active-Neutral Closure

M16 preserves active-neutral routing.

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required closure invariant:

`actual_direct_events = 0`

## Pending-Route Closure

M16 preserves retained pending-route semantics.

Required pending-route behavior:

- opposite-polarity requests create pending routes;
- pending routes preserve requested target polarity;
- pending routes complete only from active neutral `0`;
- pending routes are not overwritten before completion;
- pending completion clears the pending route;
- capacity rejection does not clear pending routes.

Required closure invariant:

`queue_overflow_events = 0`

## Transition-Capacity Closure

M16 preserves the M15 transition-capacity boundary:

`transition_fraction = 0.25`

Required relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Validated inherited profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required closure invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load relation:

`switch_load_numerator = accepted_changes`

## Retained-State Update Closure

M16 preserves retained-state writeback semantics.

Required retained-state properties:

- reset initializes retained state to active neutral `0`;
- tick-disabled cycles preserve retained state;
- state-changing writeback requires capacity approval;
- same-state retention does not consume capacity;
- active-neutral routed writeback terminates in `0`;
- pending-route completion starts from `0`;
- reserved output state is forbidden;
- direct opposite-polarity writeback is forbidden.

Required retained-state closure invariant:

`state_update_valid = True`

## Assertion Closure

The assertion binding layer covers:

- state-domain validity;
- pending-route-domain validity;
- scheduler validity;
- scheduler counter consistency;
- request accept/reject separation;
- accepted-change capacity boundary;
- capacity remaining relation;
- capacity exhaustion relation;
- switch-load numerator relation;
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events;
- invariant-flag validity;
- tick-disabled hold behavior.

Required assertion closure result:

`PASS`

Current assertion source-artifact boundary result:

`PASS`

Current external simulator assertion result:

`pending external simulator execution`

## Simulation Closure

Simulation instructions are defined in:

`rtl/m16/SIMULATION.md`

Transcript format is defined in:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

Required simulator command shape:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Required run command:

    ./obj_dir/Vfrp_m16_tb

Required completion marker:

    FRP M16 deterministic RTL testbench completed.

Required final zero-event counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current simulation transcript status:

`pending external simulator execution`

## Corrective Qualification Event

The initial M16 artifact-boundary workflow exposed a missing required RTL source artifact:

`rtl/m16/frp_m16_pending_routes.sv`

The missing pending-route RTL source artifact was added.

After the correction, the dedicated M16 artifact-boundary workflow passed.

Corrected result:

`FRP M16 RTL Artifact Boundary #4 — PASS`

Corrected commit:

`762e847`

## Current Closure Status

| Closure group | Status |
|---|---|
| RTL artifact inventory | PASS |
| package constants and encodings | present |
| scheduler RTL module | present |
| request-lane RTL module | present |
| pending-route RTL module | present |
| active-neutral RTL module | present |
| transition-capacity RTL module | present |
| retained-state update RTL module | present |
| integrated RTL core | present |
| assertion binding layer | present |
| deterministic RTL smoke testbench | present |
| RTL README | present |
| artifact manifest | present |
| simulation instructions | present |
| transcript template | present |
| closure report | current file |
| artifact-boundary workflow | PASS |
| artifact-boundary qualification report | PASS |
| M16 qualification index | implemented |
| M16 qualification manifest | ACTIVE |
| external simulator execution | pending |
| simulator transcript capture | pending |
| CI simulator workflow | pending |
| deterministic replay adapter | pending |
| FPGA synthesis report | pending |
| timing report | pending |
| resource utilization report | pending |

## M15 Compatibility Closure

M16 closure requires preservation of the M15 deterministic retained-state boundary.

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

## External FPGA Review Boundary

The architecture, semantics, RTL module set, and closure invariants are defined inside this repository.

External FPGA or circuit-level review may evaluate:

- synthesis feasibility;
- LUT utilization;
- FF utilization;
- BRAM usage;
- DSP usage;
- timing closure;
- reset strategy;
- clock strategy;
- constraints;
- target FPGA class.

External review must not redefine FRP processor semantics.

## Closure Failure Classification

Any M16 closure failure must map to a defined boundary.

| Failure category | Boundary |
|---|---|
| `package_failure` | constants, encodings, helper functions |
| `scheduler_failure` | scheduler state, profile, or counters |
| `request_lane_failure` | arbitration acceptance or rejection |
| `pending_route_failure` | pending-route creation, retention, or completion |
| `active_neutral_failure` | active-neutral transition law |
| `capacity_failure` | transition-capacity boundary |
| `state_update_failure` | retained-state writeback |
| `assertion_failure` | assertion binding layer |
| `simulation_failure` | deterministic RTL smoke testbench |
| `counter_failure` | zero-event qualification counters |
| `replay_failure` | M15 vector replay boundary |
| `synthesis_failure` | future FPGA synthesis boundary |
| `timing_failure` | future timing closure boundary |

Unclassified closure failure is not allowed.

## Required Final M16 Closure Conditions

M16 final closure is valid only when:

- artifact-boundary workflow remains PASS;
- canonical balanced ternary encoding is preserved;
- reserved state `2'b10` is never emitted;
- reset initializes retained state to active neutral `0`;
- scheduler profiles are preserved;
- request lanes remain deterministic;
- accepted changes never exceed `REQUEST_LANES`;
- switch-load numerator equals accepted changes;
- opposite-polarity transitions pass through `0`;
- direct opposite-polarity execution remains zero;
- pending routes preserve target polarity;
- pending routes complete only from `0`;
- queue-overflow events remain zero;
- assertion layer passes under simulator execution;
- deterministic RTL smoke simulation passes;
- simulation transcript is captured;
- M15 compatibility boundary remains preserved.

## Closure Result

Current M16 RTL artifact-boundary closure result:

`PASS`

Current M16 external simulator result:

`pending external simulator execution`

Current M16 final qualification result:

`pending simulator transcript capture`

## Next Step

The next repository-level step should expose the artifact-boundary PASS status from:

- `rtl/m16/README.md`;
- `rtl/m16/ARTIFACTS.md`;
- `docs/README.md`.

## Author

Maksym Marnov

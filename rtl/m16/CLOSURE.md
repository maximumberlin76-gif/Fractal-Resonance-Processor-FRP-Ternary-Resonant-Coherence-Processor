# FRP M16 RTL Closure Report

## Status

Initial RTL closure report.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the M16 RTL closure boundary for the:

`Ternary Fractal Resonant Coherence Processor`

The closure report records the current RTL artifact state, preserved M15 execution semantics, required simulation evidence, assertion boundary, and remaining qualification steps for the M16 RTL core realization layer.

M16 does not introduce a new processor model.

M16 realizes the M15-qualified retained-state execution contract in concrete RTL artifact form.

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
- simulation transcript boundary;
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
| package constants and encodings | `rtl/m16/frp_m16_pkg.sv` | implemented |
| scheduler RTL module | `rtl/m16/frp_m16_scheduler.sv` | implemented |
| request-lane RTL module | `rtl/m16/frp_m16_request_lanes.sv` | implemented |
| pending-route RTL module | `rtl/m16/frp_m16_pending_routes.sv` | implemented |
| active-neutral RTL module | `rtl/m16/frp_m16_active_neutral.sv` | implemented |
| transition-capacity RTL module | `rtl/m16/frp_m16_capacity_guard.sv` | implemented |
| retained-state update RTL module | `rtl/m16/frp_m16_state_update.sv` | implemented |
| integrated RTL core | `rtl/m16/frp_m16_core.sv` | implemented |
| assertion binding layer | `rtl/m16/frp_m16_assertions.sv` | implemented |
| deterministic RTL smoke testbench | `rtl/m16/frp_m16_tb.sv` | implemented |
| RTL layer README | `rtl/m16/README.md` | implemented |
| RTL artifact manifest | `rtl/m16/ARTIFACTS.md` | implemented |
| simulation instructions | `rtl/m16/SIMULATION.md` | implemented |
| simulation transcript template | `rtl/m16/SIMULATION_TRANSCRIPT.md` | implemented |
| RTL closure report | `rtl/m16/CLOSURE.md` | current file |

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

## Current Closure Status

| Closure group | Status |
|---|---|
| RTL artifact inventory | complete |
| package constants and encodings | implemented |
| scheduler RTL module | implemented |
| request-lane RTL module | implemented |
| pending-route RTL module | implemented |
| active-neutral RTL module | implemented |
| transition-capacity RTL module | implemented |
| retained-state update RTL module | implemented |
| integrated RTL core | implemented |
| assertion binding layer | implemented |
| deterministic RTL smoke testbench | implemented |
| RTL README | implemented |
| artifact manifest | implemented |
| simulation instructions | implemented |
| transcript template | implemented |
| closure report | current file |
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

M16 RTL closure is valid only when:

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
- assertion layer passes;
- deterministic RTL smoke simulation passes;
- simulation transcript is captured;
- M15 compatibility boundary remains preserved.

## Closure Result

Current M16 RTL closure result:

`documentation and RTL artifact boundary complete`

Current M16 final qualification result:

`pending external simulator execution`

Required final M16 qualification result:

`PASS`

## Next Step

The next repository-level step should expose the M16 RTL layer from the main documentation index.

Recommended next file:

`PROJECT_STRUCTURE.md`

Update only the RTL/M16 documentation references and preserve all existing structure.

## Author

Maksym Marnov

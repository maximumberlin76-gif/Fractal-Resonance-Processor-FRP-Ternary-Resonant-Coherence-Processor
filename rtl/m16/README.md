# FRP M16 RTL Core Realization Layer

## Status

`ARTIFACT-BOUNDARY PASS`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This directory contains the M16 RTL artifact layer for the:

`Ternary Fractal Resonant Coherence Processor`

M16 realizes the M15-qualified retained-state execution contract as concrete SystemVerilog RTL artifacts.

M16 does not introduce a new processor model.

M16 preserves the M15 execution semantics and exposes the retained-state execution boundary as RTL modules, assertion layer, deterministic smoke testbench, simulator instructions, transcript template, and closure surface.

## Current Qualification Status

Current RTL artifact-boundary status:

`ARTIFACT-BOUNDARY PASS`

Current M16 qualification status:

`M16 artifact-boundary PASS`

M16 artifact-boundary status:

`M16 artifact-boundary PASS`

M15 inherited qualification status:

`M15 41/41 PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

External simulator status:

`pending external simulator execution`

Final simulator qualification status:

`pending external simulator execution`

## M15 Inherited Qualification Status

M15 remains the inherited qualification base for the M16 RTL artifact layer.

M15 inherited qualification status:

`M15 41/41 PASS`

M15 validated package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

M16 does not replace the M15 qualification boundary.

M16 realizes the M15-qualified retained-state execution contract as RTL artifacts.

## RTL Source Artifacts

| Path | Purpose | Status |
|---|---|---|
| `frp_m16_pkg.sv` | canonical package, enums, constants, helper functions | present |
| `frp_m16_scheduler.sv` | scheduler-state realization | present |
| `frp_m16_request_lanes.sv` | request-lane calculation and arbitration boundary | present |
| `frp_m16_pending_routes.sv` | pending-route register module | present |
| `frp_m16_active_neutral.sv` | active-neutral transition routing | present |
| `frp_m16_capacity_guard.sv` | transition-capacity guard | present |
| `frp_m16_state_update.sv` | retained-state update module | present |
| `frp_m16_core.sv` | integrated M16 RTL core | present |
| `frp_m16_assertions.sv` | assertion layer for invariant preservation | present |
| `frp_m16_tb.sv` | deterministic smoke testbench | present |

## RTL Documentation Artifacts

| Path | Purpose | Status |
|---|---|---|
| `README.md` | current RTL layer overview | present |
| `ARTIFACTS.md` | RTL artifact manifest | present |
| `SIMULATION.md` | external simulator execution instructions | present |
| `SIMULATION_TRANSCRIPT.md` | simulator transcript placeholder | present |
| `CLOSURE.md` | current M16 RTL closure surface | present |

## Preserved Execution Chain

M16 preserves the retained-state execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

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

## Active-Neutral Transition Rule

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed transitions:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

## Pending-Route Boundary

Opposite-polarity requests are routed through active neutral state `0`.

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

## Zero-Event Invariants

The M16 RTL artifact boundary preserves the following invariant targets:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

These are artifact-boundary invariants and external simulator closure targets.

## Assertion Boundary

The assertion layer is defined in:

`frp_m16_assertions.sv`

The assertion layer preserves:

- no actual direct opposite-polarity transition;
- no reserved ternary state;
- no pending-route queue overflow.

Required assertion terms:

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS`

`FRP_INV_NO_RESERVED_STATE`

`FRP_INV_NO_QUEUE_OVERFLOW`

## Deterministic Testbench Boundary

The deterministic smoke testbench is defined in:

`frp_m16_tb.sv`

The testbench covers:

- `FRP_MODE_FREE`;
- `FRP_MODE_7_1`;
- `FRP_MODE_1_7`;
- active-neutral routing;
- pending-route completion;
- zero-event invariant counters.

Required completion marker:

`FRP M16 deterministic RTL testbench completed.`

## External Simulator Boundary

Current external simulator status:

`pending external simulator execution`

Simulation instructions:

`SIMULATION.md`

Transcript template:

`SIMULATION_TRANSCRIPT.md`

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

## Current Result

Current RTL source artifact inventory:

`PASS`

Current RTL documentation artifact inventory:

`PASS`

Current M16 artifact-boundary workflow:

`PASS`

Current M16 artifact-boundary status:

`M16 artifact-boundary PASS`

Current M15 inherited qualification status:

`M15 41/41 PASS`

Current public status:

`PUBLIC STATUS SYNCHRONIZED`

Current external simulator status:

`pending external simulator execution`

## Remaining Boundary

Remaining state:

`external simulator transcript pending`

Final M16 closure requires:

- external simulator execution;
- simulator transcript capture;
- assertion-layer PASS;
- final zero-event counter confirmation;
- simulation transcript update;
- closure report update;
- final M16 qualification closure document.

## Author

Maksym Marnov

# FRP M16 RTL Core Realization Layer

## Status

`ARTIFACT-BOUNDARY PASS`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This directory contains the first concrete SystemVerilog RTL realization layer for the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL layer preserves the M15-qualified retained-state execution semantics and exposes the processor boundary as explicit RTL artifacts.

M16 does not introduce a new processor model.

M16 realizes the already-qualified M15 execution contract in RTL module form.

## Current Qualification Result

Current M16 RTL artifact-boundary result:

`PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Passing workflow run:

`FRP M16 RTL Artifact Boundary #8`

Passing commit:

`12a3431`

Current external simulator result:

`pending external simulator execution`

Current final M16 closure result:

`pending simulator transcript capture`

## Preserved Processor Identity

The M16 RTL layer preserves the FRP execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Required global invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Canonical Balanced Ternary Encoding

The M16 RTL layer preserves the canonical two-bit ternary encoding:

| Ternary state | Encoding | Meaning |
|---|---|---|
| `-1` | `2'b11` | negative retained polarity |
| `0` | `2'b00` | active neutral state |
| `+1` | `2'b01` | positive retained polarity |
| reserved | `2'b10` | invalid state |

The reserved encoding is forbidden in qualified execution.

Required invariant:

`reserved_state_events = 0`

## RTL Artifact Set

Current M16 RTL artifacts:

| Artifact | Purpose | Status |
|---|---|---|
| `frp_m16_pkg.sv` | canonical constants, encodings, helper functions, scheduler decoding, transition classification, request-lane calculation | present |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` scheduler-state realization | present |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration | present |
| `frp_m16_pending_routes.sv` | retained pending-route register layer | present |
| `frp_m16_active_neutral.sv` | legal active-neutral transition generation | present |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement | present |
| `frp_m16_state_update.sv` | retained-state writeback | present |
| `frp_m16_core.sv` | integrated M16 RTL core | present |
| `frp_m16_assertions.sv` | assertion binding layer | present |
| `frp_m16_tb.sv` | deterministic RTL smoke testbench | present |

## M16 RTL Documentation

Current M16 RTL documentation artifacts:

| Artifact | Purpose | Status |
|---|---|---|
| `README.md` | RTL layer overview | current file |
| `ARTIFACTS.md` | RTL artifact manifest | present |
| `SIMULATION.md` | simulator execution instructions | present |
| `SIMULATION_TRANSCRIPT.md` | simulation transcript template | present |
| `CLOSURE.md` | RTL closure report | present |

## Include Order

Recommended compilation include order:

    frp_m16_pkg.sv
    frp_m16_scheduler.sv
    frp_m16_request_lanes.sv
    frp_m16_pending_routes.sv
    frp_m16_active_neutral.sv
    frp_m16_capacity_guard.sv
    frp_m16_state_update.sv
    frp_m16_core.sv
    frp_m16_assertions.sv
    frp_m16_tb.sv

The package must be available before all dependent modules.

The integrated core includes the required submodules.

The testbench includes the integrated core and assertion layer.

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

`FRP M16 RTL Artifact Boundary #8`

Passing commit:

`12a3431`

Workflow validation command:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

## Scheduler Semantics

M16 preserves three explicit processor execution modes:

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

## Transition-Capacity Boundary

M16 preserves the inherited M15 transition boundary:

`transition_fraction = 0.25`

Required relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Validated inherited profiles:

| Cells | Request lanes | Packed state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

Required capacity invariant:

`accepted_changes <= REQUEST_LANES`

Switch-load numerator:

`switch_load_numerator = accepted_changes`

Switch-load relation:

`switch_load = accepted_changes / CELLS`

Required bound:

`switch_load_peak <= transition_fraction`

## Active-Neutral Routing

M16 preserves mandatory active-neutral routing.

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required direct-transition invariant:

`actual_direct_events = 0`

## Pending-Route Semantics

An accepted opposite-polarity request creates a retained pending route.

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

Required pending-route invariants:

`pending routes preserve requested target polarity`

`pending completion starts from 0`

`queue_overflow_events = 0`

## Testbench Coverage

The current deterministic smoke testbench exercises:

- reset-to-neutral initialization;
- free scheduler mode;
- `7/1` scheduler mode;
- `1/7` scheduler mode;
- neutral release `0 → +1`;
- neutralization `+1 → 0`;
- opposite-polarity request `+1 → -1`;
- active-neutral route `+1 → 0`;
- retained pending route to `-1`;
- pending completion `0 → -1`;
- invariant flags;
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events.

## Assertion Boundary

The assertion layer checks:

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

## Current Qualification Status

Current RTL artifact status:

| Layer | Status |
|---|---|
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
| artifact-boundary workflow | PASS |
| artifact-boundary qualification report | PASS |
| M16 qualification index | implemented |
| M16 qualification manifest | ACTIVE |
| external simulator transcript | pending |
| FPGA synthesis report | pending |
| timing report | pending |
| resource utilization report | pending |

## M15 Compatibility Boundary

The M16 RTL layer is designed to replay the M15 deterministic execution contract at the retained-state boundary.

Required compatibility chain:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

## External FPGA Review Position

The architecture, execution semantics, RTL boundary, and core module structure are defined inside this repository.

External FPGA or circuit-level review may evaluate:

- synthesis feasibility;
- LUT / FF / BRAM / DSP utilization;
- timing closure;
- reset and clock strategy;
- interface constraints;
- board-level integration;
- target FPGA class.

External review must not redefine the FRP processor semantics.

## Corrective Qualification Event

The M16 artifact-boundary workflow exposed a missing required RTL source artifact:

`rtl/m16/frp_m16_pending_routes.sv`

The missing pending-route RTL source artifact was added.

After correction, the M16 artifact-boundary workflow passed.

Corrected current result:

`FRP M16 RTL Artifact Boundary #8 — PASS`

Corrected commit:

`12a3431`

## Closure Direction

M16 final closure requires:

1. artifact-boundary workflow PASS;
2. external simulator execution;
3. simulator transcript capture;
4. assertion-layer PASS under simulator execution;
5. final zero-event counter confirmation;
6. simulation transcript update;
7. closure report update;
8. final M16 qualification closure document.

Current state:

`artifact-boundary PASS`

Remaining state:

`external simulator transcript pending`

## Author

Maksym Marnov

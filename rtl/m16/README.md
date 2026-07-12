# FRP M16 RTL Core Realization Layer

## Status

Initial RTL artifact layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This directory contains the first concrete RTL-oriented realization layer for the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL layer preserves the M15-qualified retained-state execution semantics and moves the processor boundary from documented RTL mapping into explicit SystemVerilog artifacts.

M16 does not introduce a new processor model.

M16 realizes the already-qualified M15 execution contract in RTL module form.

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

| Artifact | Purpose |
|---|---|
| `frp_m16_pkg.sv` | canonical constants, encodings, helper functions, scheduler decoding, transition classification, request-lane calculation |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` scheduler-state realization |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-route register layer |
| `frp_m16_active_neutral.sv` | legal active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement |
| `frp_m16_state_update.sv` | retained-state writeback |
| `frp_m16_core.sv` | integrated M16 RTL core |
| `frp_m16_assertions.sv` | assertion binding layer |
| `frp_m16_tb.sv` | deterministic RTL smoke testbench |

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

## Closure Direction

The next M16 steps should generate:

1. RTL artifact manifest;
2. simulation instruction document;
3. optional simulator smoke workflow;
4. M16 replay adapter;
5. M16 deterministic simulation transcript;
6. M16 closure report.

M16 closes only when concrete RTL artifacts preserve the M15-qualified execution contract and produce a deterministic PASS boundary.

## Author

Maksym Marnov

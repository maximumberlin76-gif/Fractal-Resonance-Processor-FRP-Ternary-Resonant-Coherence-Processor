# FRP M16 RTL Artifact Manifest

## Status

Initial RTL artifact manifest.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This manifest records the concrete RTL artifacts introduced for the M16 RTL core realization layer of the:

`Ternary Fractal Resonant Coherence Processor`

The manifest defines the artifact inventory, semantic role, integration position, and qualification status of each SystemVerilog file in `rtl/m16`.

M16 does not introduce a new processor model.

M16 realizes the M15-qualified retained-state execution contract in RTL artifact form.

## Preserved Execution Contract

The M16 RTL artifact set preserves the retained-state execution chain:

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

## Canonical Encoding

The artifact set preserves the canonical M15 balanced ternary encoding:

| Ternary state | Encoding | Status |
|---|---|---|
| `-1` | `2'b11` | valid |
| `0` | `2'b00` | valid active neutral |
| `+1` | `2'b01` | valid |
| reserved | `2'b10` | invalid |

Required invariant:

`reserved_state_events = 0`

## Artifact Inventory

| File | Artifact role | Status |
|---|---|---|
| `frp_m16_pkg.sv` | constants, encodings, helper functions, scheduler decoding, transition classification, capacity calculation | implemented |
| `frp_m16_scheduler.sv` | scheduler-state realization for `free`, `7/1`, and `1/7` execution modes | implemented |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration | implemented |
| `frp_m16_pending_routes.sv` | pending-route register layer | implemented |
| `frp_m16_active_neutral.sv` | active-neutral transition generation | implemented |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement | implemented |
| `frp_m16_state_update.sv` | retained-state writeback | implemented |
| `frp_m16_core.sv` | integrated M16 RTL core | implemented |
| `frp_m16_assertions.sv` | assertion binding layer | implemented |
| `frp_m16_tb.sv` | deterministic smoke testbench | implemented |
| `README.md` | RTL layer documentation | implemented |
| `ARTIFACTS.md` | current artifact manifest | current file |

## Artifact Dependency Order

Recommended compile and dependency order:

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

The package file must be visible before all dependent modules.

The integrated core imports and connects the module boundary.

The testbench instantiates the integrated core and assertion layer.

## Package Artifact

File:

`frp_m16_pkg.sv`

Role:

Defines the shared RTL constants and semantic encodings used across M16.

Includes:

- `FRP_M16_STATE_BITS`;
- `FRP_M16_SCHED_MODE_BITS`;
- `FRP_M16_SCHED_BITS`;
- `FRP_M16_COUNTER_BITS`;
- balanced ternary state encoding;
- scheduler mode encoding;
- scheduler state encoding;
- transition class encoding;
- request rejection reason encoding;
- invariant flag indexes;
- ternary-domain helper functions;
- transition-classification helper;
- scheduler decoding helpers;
- request-lane capacity calculation.

Required package invariant:

`FRP_M16_REQUEST_LANES_8_CELLS = 2`

`FRP_M16_REQUEST_LANES_16_CELLS = 4`

`FRP_M16_REQUEST_LANES_32_CELLS = 8`

## Scheduler Artifact

File:

`frp_m16_scheduler.sv`

Role:

Implements the M16 scheduler-state realization.

Preserved modes:

- `free`;
- `7/1`;
- `1/7`.

Required profiles:

| Mode | Required profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Required scheduler invariant:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

## Request-Lane Artifact

File:

`frp_m16_request_lanes.sv`

Role:

Implements deterministic request-lane arbitration.

Preserved properties:

- ascending lane order;
- valid cell-index checking;
- valid target-domain checking;
- duplicate-cell rejection;
- scheduler eligibility gating;
- pending-route priority protection;
- active-neutral routing classification;
- transition-capacity compatibility.

Required request-lane invariant:

`request_accept & request_reject = 0`

## Pending-Route Artifact

File:

`frp_m16_pending_routes.sv`

Role:

Implements retained pending-route state for opposite-polarity transitions.

Preserved sequence:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required pending-route invariants:

`pending routes preserve requested target polarity`

`pending completion starts from 0`

`queue_overflow_events = 0`

## Active-Neutral Artifact

File:

`frp_m16_active_neutral.sv`

Role:

Implements legal retained-state transition generation.

Allowed transitions:

`0 → +1`

`0 → -1`

`+1 → 0`

`-1 → 0`

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required active-neutral invariant:

`actual_direct_events = 0`

## Capacity-Guard Artifact

File:

`frp_m16_capacity_guard.sv`

Role:

Implements the transition-capacity boundary.

Preserved relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Required capacity invariant:

`accepted_changes <= REQUEST_LANES`

Switch-load numerator:

`switch_load_numerator = accepted_changes`

## State-Update Artifact

File:

`frp_m16_state_update.sv`

Role:

Implements final retained-state writeback.

Preserved writeback rules:

- reset initializes retained state to `0`;
- tick-disabled cycles preserve retained state;
- state-changing writeback requires capacity approval;
- same-state retention does not consume capacity;
- active-neutral routed writeback terminates in `0`;
- pending-route completion starts from `0`;
- reserved state output is forbidden;
- direct opposite-polarity writeback is forbidden.

Required state-update invariant:

`state_out` contains no `2'b10`

## Integrated Core Artifact

File:

`frp_m16_core.sv`

Role:

Integrates the M16 RTL execution modules into one core boundary.

Integrated modules:

- scheduler;
- request-lane arbitration;
- active-neutral transition;
- transition-capacity guard;
- pending-route register layer;
- retained-state update layer.

Core outputs include:

- retained state;
- pending-route state;
- scheduler counters;
- request accept/reject masks;
- accepted-change mask;
- accepted-change count;
- capacity remaining;
- capacity exhausted;
- switch-load numerator;
- event counters;
- invariant flags.

Required core invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Assertion Artifact

File:

`frp_m16_assertions.sv`

Role:

Defines assertion checks for the integrated RTL boundary.

Assertion coverage includes:

- state-domain validity;
- pending-route-domain validity;
- scheduler validity;
- scheduler counter consistency;
- request accept/reject separation;
- accepted-change capacity boundary;
- capacity remaining relation;
- capacity exhaustion relation;
- switch-load numerator relation;
- event-counter invariants;
- invariant-flag validity;
- tick-disabled hold behavior.

Required assertion result:

`PASS`

## Testbench Artifact

File:

`frp_m16_tb.sv`

Role:

Provides the first deterministic RTL smoke testbench.

Current testbench exercises:

- reset-to-neutral initialization;
- free scheduler mode;
- `7/1` scheduler smoke profile;
- `1/7` scheduler smoke profile;
- neutral release `0 → +1`;
- neutralization `+1 → 0`;
- opposite-polarity request `+1 → -1`;
- active-neutral route `+1 → 0`;
- retained pending route to `-1`;
- pending completion `0 → -1`;
- invariant flag checks.

Required final testbench counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Documentation Artifact

File:

`README.md`

Role:

Documents the RTL layer, artifact set, compile order, scheduler semantics, ternary encoding, transition-capacity boundary, active-neutral routing, pending-route behavior, assertion boundary, M15 compatibility position, and external FPGA review boundary.

## Manifest Artifact

File:

`ARTIFACTS.md`

Role:

Records the current artifact set and defines the M16 RTL artifact inventory for qualification tracking.

## Current Qualification Status

| Qualification group | Status |
|---|---|
| RTL artifact inventory | documented |
| package artifact | implemented |
| scheduler artifact | implemented |
| request-lane artifact | implemented |
| pending-route artifact | implemented |
| active-neutral artifact | implemented |
| capacity-guard artifact | implemented |
| state-update artifact | implemented |
| integrated core artifact | implemented |
| assertion artifact | implemented |
| testbench artifact | implemented |
| simulator execution transcript | pending |
| deterministic replay adapter | pending |
| M16 closure report | pending |
| FPGA synthesis report | pending |

## M15 Compatibility Position

The M16 RTL artifact set is designed to preserve the M15 deterministic retained-state boundary.

Compatibility chain:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

## External Review Boundary

The M16 RTL artifact set defines the architecture and execution semantics internally.

An external FPGA or circuit-level reviewer may evaluate:

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

External review must not redefine the FRP processor semantics.

## Manifest Closure Criteria

This artifact manifest is valid when:

- all implemented RTL files are listed;
- every artifact has a defined role;
- compile order is explicit;
- preserved invariants are stated;
- M15 compatibility boundary is stated;
- pending qualification artifacts are identified;
- external review boundary is constrained.

## Next Step

The next file should define the simulator execution instructions:

`rtl/m16/SIMULATION.md`

## Author

Maksym Marnov

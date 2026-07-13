# FRP M16 RTL Closure

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Closure Status

`M16 RTL EXECUTION LAYER CLOSED`

The M16 RTL execution layer realizes the retained balanced ternary processor architecture as an integrated SystemVerilog boundary.

The closed boundary includes:

- canonical balanced ternary retained state
- active neutral state `0`
- `free`, `7/1`, and `1/7` temporal execution
- deterministic request-lane arbitration
- retained pending-route polarity
- tick-separated opposite-polarity routing
- distributed transition-capacity enforcement
- retained-state writeback
- architectural event telemetry
- integrated invariant flags
- temporal and structural assertions
- deterministic executable qualification

## Closure Boundary

The M16 RTL closure covers:

`rtl/m16/`

The directory contains ten SystemVerilog artifacts and five RTL documentation artifacts.

### SystemVerilog Artifacts

| File | Function |
|---|---|
| `frp_m16_pkg.sv` | canonical ternary encodings, scheduler modes, transition classes, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` tick-by-tick execution |
| `frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-polarity creation, retention, completion, and clearing |
| `frp_m16_active_neutral.sv` | active-neutral transition classification and candidate generation |
| `frp_m16_capacity_guard.sv` | distributed per-tick transition-capacity admission |
| `frp_m16_state_update.sv` | capacity-approved retained-state writeback |
| `frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | architectural, temporal, domain, routing, capacity, and writeback assertions |
| `frp_m16_tb.sv` | deterministic executable architectural testbench |

### RTL Documentation Artifacts

| File | Function |
|---|---|
| `README.md` | RTL architecture and execution semantics |
| `ARTIFACTS.md` | RTL artifact manifest |
| `SIMULATION.md` | build and execution procedure |
| `SIMULATION_TRANSCRIPT.md` | executable qualification record |
| `CLOSURE.md` | M16 RTL closure record |

Artifact inventory:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

Artifact inventory result:

`PASS`

## Integrated Execution Chain

The closed M16 execution chain is:

`phase-derived ternary target`

→ `temporal scheduler state`

→ `pending-route completion priority`

→ `deterministic request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `distributed transition-capacity guard`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry and invariants`

Execution-chain result:

`PASS`

## Balanced Ternary State Closure

The retained processor-state domain is:

`{-1, 0, +1}`

Canonical hardware encoding:

| Ternary state | Encoding | Function |
|---|---|---|
| `-1` | `2'b11` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | `2'b00` | active neutral balancing / damping / transition / stabilization state |
| `+1` | `2'b01` | positive / excitatory / phase-supporting / constructive potential |
| reserved | `2'b10` | invalid processor-state encoding |

The state `0` is an active processor state.

It performs:

- logical neutrality
- phase damping
- balancing
- transition buffering
- conflict neutralization
- polarity bridging
- switching-load distribution
- temporal execution control
- retained-state stabilization

The canonical encoding is applied to:

- retained processor state
- phase-derived target
- request target
- transition candidate
- pending-route target
- retained-state output

Balanced ternary state result:

`PASS`

Reserved encoding relation:

`reserved_state_events = 0`

## Temporal Execution Closure

FRP preserves three processor execution modes:

- `free`
- `7/1`
- `1/7`

These modes define the tick-by-tick transition eligibility of the retained balanced ternary processor state.

### Free Mode

Every enabled tick is:

`free`

The `free` scheduler state is:

- commit-capable
- neutralize-capable

It executes:

- same-state retention
- `0 → -1`
- `0 → +1`
- `-1 → 0`
- `+1 → 0`
- opposite-polarity first-leg routing
- pending-route completion from `0`

Qualified scheduler relation:

`16 ticks → free = 16`

Result:

`PASS`

### 7/1 Mode

The repeating eight-tick sequence is:

| Period index | Scheduler state |
|---:|---|
| `0` | `balance` |
| `1` | `balance` |
| `2` | `balance` |
| `3` | `balance` |
| `4` | `balance` |
| `5` | `balance` |
| `6` | `balance` |
| `7` | `commit` |

A `balance` tick executes:

- same-state retention
- `-1 → 0`
- `+1 → 0`
- opposite-polarity first-leg routing

A `commit` tick executes:

- same-state retention
- `0 → -1`
- `0 → +1`
- pending-route completion from active neutral `0`

Qualified scheduler relations:

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

Result:

`PASS`

### 1/7 Mode

The repeating eight-tick sequence is:

| Period index | Scheduler state |
|---:|---|
| `0` | `excite` |
| `1` | `neutralize` |
| `2` | `neutralize` |
| `3` | `neutralize` |
| `4` | `neutralize` |
| `5` | `neutralize` |
| `6` | `neutralize` |
| `7` | `neutralize` |

An `excite` tick executes:

- same-state retention
- `0 → -1`
- `0 → +1`
- pending-route completion from active neutral `0`

A `neutralize` tick executes:

- same-state retention
- `-1 → 0`
- `+1 → 0`
- opposite-polarity first-leg routing

Qualified scheduler relation:

`16 ticks → excite = 2, neutralize = 14`

Result:

`PASS`

### Scheduler Counter Relation

The scheduler counter bank satisfies:

`sum(scheduler_counts) = ticks_recorded`

Scheduler counter clearing preserves:

- retained balanced ternary state
- retained pending-route state
- scheduler mode
- scheduler tick position

Scheduler closure result:

`PASS`

## Active-Neutral Routing Closure

Direct opposite-polarity transitions are excluded:

`-1 → +1`

`+1 → -1`

The implemented routes are:

`-1 → 0 → +1`

`+1 → 0 → -1`

For an opposite-polarity request:

`state_i × target_i = -1`

the first eligible neutralize-capable tick performs:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick performs:

`0 → pending_route_i`

The two route legs execute on separate eligible ticks.

Active-neutral routing relations:

| Relation | Result |
|---|---|
| `-1 → 0 → +1` executed | `PASS` |
| `+1 → 0 → -1` executed | `PASS` |
| active neutral `0` retained between route legs | `PASS` |
| requested opposite polarity retained | `PASS` |
| direct opposite-polarity writeback absent | `PASS` |

Direct-transition relation:

`actual_direct_events = 0`

Active-neutral routing result:

`PASS`

## Pending-Route Closure

Each retained processor cell contains one pending-route slot.

The pending-route slot:

- stores the exact requested opposite polarity
- owns the cell until completion
- has priority over a new same-cell request
- remains stable across scheduler-ineligible ticks
- remains stable across transition-capacity deferral
- completes only from retained active neutral state `0`
- clears only after accepted completion writeback
- cannot be overwritten by another route

For:

`+1 → -1`

the execution relation is:

`+1 → 0`

`pending_route = -1`

`0 → -1`

For:

`-1 → +1`

the execution relation is:

`-1 → 0`

`pending_route = +1`

`0 → +1`

Pending-route relations:

| Relation | Result |
|---|---|
| exact target polarity retained | `PASS` |
| same-cell overwrite prevented | `PASS` |
| scheduler deferral preserved route | `PASS` |
| capacity deferral preserved route | `PASS` |
| completion occurred only from `0` | `PASS` |
| accepted completion cleared route | `PASS` |
| pending-route overflow absent | `PASS` |

Queue-overflow relation:

`queue_overflow_events = 0`

Pending-route closure result:

`PASS`

## Request-Lane Arbitration Closure

Request lanes are processed in deterministic ascending order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

The request boundary enforces:

- canonical target encoding
- valid cell index
- one accepted explicit request per cell per tick
- earlier accepted-lane ownership
- retained pending-route ownership
- scheduler transition eligibility
- separation of accepted and rejected lanes

Request-lane arbitration result:

`PASS`

## Transition-Capacity Closure

The distributed transition fraction is:

`0.25`

The maximum number of retained-state changes per tick is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified parameter profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Capacity priority is:

1. pending-route completion candidates in ascending cell order
2. accepted explicit requests in ascending lane order

Same-state retention consumes no capacity.

Each state-changing route leg consumes capacity on its own tick.

Capacity relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

Transition-capacity result:

`PASS`

## Retained-State Writeback Closure

The retained-state register commits only transitions admitted by the capacity guard.

The writeback boundary preserves:

- canonical ternary output
- accepted-change correlation
- same-state retention
- active-neutral first-leg writeback
- pending-route completion writeback
- capacity-mask correlation
- zero direct opposite-polarity writeback
- zero reserved-state output

Retained-state writeback result:

`PASS`

## Assertion Closure

Assertion artifact:

`rtl/m16/frp_m16_assertions.sv`

The assertion layer verifies:

- canonical retained-state encoding
- canonical pending-route encoding
- reset to active neutral `0`
- disabled-tick state retention
- disabled-tick pending-route retention
- state-change authorization
- direct opposite-polarity exclusion
- active-neutral first-leg execution
- retained pending polarity
- pending-route deferral
- completion only from active neutral `0`
- scheduler mode and scheduler state
- scheduler-state counter relation
- request acceptance and rejection separation
- transition-capacity relations
- retained-state writeback
- integrated invariant flags

Assertion execution result:

`PASS`

## Integrated Invariant Closure

| Invariant | Result |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | `PASS` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` |
| `FRP_INV_PENDING_POLARITY_VALID` | `PASS` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID` | `PASS` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` |
| `FRP_INV_NO_RESERVED_STATE` | `PASS` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` |

Integrated invariant result:

`PASS`

## Executable Qualification Closure

Simulation entry:

`rtl/m16/frp_m16_tb.sv`

Top-level simulation module:

`frp_m16_tb`

Top-level synthesis boundary:

`frp_m16_core`

Qualification workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Artifact validation test:

`tests/test_m16_rtl_artifact_manifest.py`

Executable qualification covered:

- exact RTL artifact inventory
- SystemVerilog compilation
- module elaboration
- executable testbench generation
- assertion execution
- `free` scheduler sequence
- `7/1` scheduler sequence
- `1/7` scheduler sequence
- active-neutral route execution
- retained pending polarity
- pending-route completion
- transition-capacity saturation
- retained-state writeback
- terminal event counters
- repository integrity

Qualification results:

| Boundary | Result |
|---|---|
| RTL artifact inventory | `PASS` |
| RTL documentation inventory | `PASS` |
| SystemVerilog compilation | `PASS` |
| module elaboration | `PASS` |
| executable testbench | `PASS` |
| assertion execution | `PASS` |
| `free` execution | `PASS` |
| `7/1` execution | `PASS` |
| `1/7` execution | `PASS` |
| active-neutral routing | `PASS` |
| retained pending polarity | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariants | `PASS` |
| repository integrity | `PASS` |

Terminal output:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

Executable qualification result:

`PASS`

## Zero-Event Closure

| Architectural counter | Final value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Zero-event closure result:

`PASS`

## M15 to M16 Inheritance Closure

M16 inherits the M15 qualification boundary:

`M15 41 / 41 PASS`

The execution inheritance chain is:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 temporal scheduler`

→ `M16 request-lane arbitration`

→ `M16 active-neutral routing`

→ `M16 transition-capacity guard`

→ `M16 retained-state writeback`

→ `M16 assertion layer`

→ `M16 executable qualification`

The M16 RTL layer realizes the inherited retained-state execution architecture as a concrete SystemVerilog processor boundary.

M15 to M16 inheritance result:

`PASS`

## FPGA Preparation Boundary

The synthesis boundary for the FPGA preparation layer is:

`frp_m16_core`

The FPGA preparation layer inherits:

- canonical balanced ternary encoding
- active neutral state `0`
- `free`, `7/1`, and `1/7` temporal execution
- pending-route completion priority
- deterministic request-lane order
- distributed transition capacity
- retained-state writeback
- architectural telemetry
- integrated invariant outputs

The FPGA preparation layer preserves the M16 RTL execution semantics.

## Closure Statement

The M16 RTL execution layer is closed.

The closure includes:

- complete SystemVerilog source boundary
- complete RTL documentation boundary
- canonical balanced ternary state encoding
- active neutral state execution
- tick-separated opposite-polarity routing
- retained pending polarity
- exact `free`, `7/1`, and `1/7` temporal execution
- deterministic request arbitration
- distributed transition capacity
- retained-state writeback
- assertion execution
- executable architectural qualification
- integrated invariant qualification
- zero direct-transition events
- zero reserved-state events
- zero pending-route overflow events

Final closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## Author

Maksym Marnov

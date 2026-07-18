# FRP M16 RTL Artifact Manifest

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Artifact Boundary

The M16 RTL artifact boundary contains the SystemVerilog realization of the retained balanced ternary execution architecture.

The artifact set implements:

- canonical balanced ternary retained state;
- active neutral state `0`;
- `free`, `7/1`, and `1/7` temporal execution;
- deterministic request-lane arbitration;
- retained pending-route polarity;
- mandatory tick-separated opposite-polarity routing;
- distributed transition-capacity enforcement;
- retained-state writeback;
- architectural telemetry;
- temporal and structural assertions;
- deterministic executable qualification.

## Directory Inventory

The `rtl/m16/` directory contains:

- ten SystemVerilog artifacts;
- five RTL documentation artifacts.

### SystemVerilog Artifacts

| File | Module or package | Architectural function |
|---|---|---|
| `frp_m16_pkg.sv` | `frp_m16_pkg` | canonical encodings, scheduler states, transition classes, invariant indexes, capacity parameters, and shared semantic functions |
| `frp_m16_scheduler.sv` | `frp_m16_scheduler` | potakt execution of `free`, `7/1`, and `1/7` scheduler modes |
| `frp_m16_request_lanes.sv` | `frp_m16_request_lanes` | deterministic ascending request-lane arbitration |
| `frp_m16_pending_routes.sv` | `frp_m16_pending_routes` | retained pending-polarity storage, deferral, completion, and clearing |
| `frp_m16_active_neutral.sv` | `frp_m16_active_neutral` | balanced ternary transition classification and active-neutral candidate generation |
| `frp_m16_capacity_guard.sv` | `frp_m16_capacity_guard` | per-tick distributed transition-capacity admission |
| `frp_m16_state_update.sv` | `frp_m16_state_update` | capacity-approved retained-state writeback |
| `frp_m16_core.sv` | `frp_m16_core` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | `frp_m16_assertions` | temporal, routing, domain, capacity, and writeback assertions |
| `frp_m16_tb.sv` | `frp_m16_tb` | deterministic executable architectural testbench |

### RTL Documentation Artifacts

| File | Function |
|---|---|
| `README.md` | M16 RTL architecture, execution semantics, module structure, and interface |
| `ARTIFACTS.md` | exact SystemVerilog and RTL documentation manifest |
| `SIMULATION.md` | simulator build, execution, and result-validation procedure |
| `SIMULATION_TRANSCRIPT.md` | simulator command and execution-result record |
| `CLOSURE.md` | complete M16 RTL closure record |

## Architectural State Domain

The retained processor-state domain is:

`{-1, 0, 1}`

Canonical encoding:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

The same encoding is used by:

- retained processor state;
- phase-derived target state;
- request target;
- transition candidate;
- pending-route target;
- retained-state output.

The state `0` is the active neutral processor state.

Its architectural functions include:

- balancing;
- phase damping;
- transition buffering;
- conflict neutralization;
- polarity bridging;
- switching-load distribution;
- temporal separation;
- retained-state stabilization.

## Temporal Execution Artifacts

### Free Mode

Every enabled processor tick is:

`FRP_SCHED_FREE`

The free state is:

- commit-capable;
- neutralize-capable.

It admits:

- same-state retention;
- `0 → -1`;
- `0 → 1`;
- `-1 → 0`;
- `1 → 0`;
- opposite-polarity first-leg routing;
- pending-route completion.

### 7/1 Mode

The repeating scheduler sequence is:

`balance, balance, balance, balance, balance, balance, balance, commit`

Period mapping:

| Period index | State |
|---:|---|
| `0` | `FRP_SCHED_BALANCE` |
| `1` | `FRP_SCHED_BALANCE` |
| `2` | `FRP_SCHED_BALANCE` |
| `3` | `FRP_SCHED_BALANCE` |
| `4` | `FRP_SCHED_BALANCE` |
| `5` | `FRP_SCHED_BALANCE` |
| `6` | `FRP_SCHED_BALANCE` |
| `7` | `FRP_SCHED_COMMIT` |

Balance ticks admit:

- same-state retention;
- `-1 → 0`;
- `1 → 0`;
- opposite-polarity first-leg routing.

Commit ticks admit:

- same-state retention;
- `0 → -1`;
- `0 → 1`;
- pending-route completion.

Required scheduler relations:

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

### 1/7 Mode

The repeating scheduler sequence is:

`excite, neutralize, neutralize, neutralize, neutralize, neutralize, neutralize, neutralize`

Period mapping:

| Period index | State |
|---:|---|
| `0` | `FRP_SCHED_EXCITE` |
| `1` | `FRP_SCHED_NEUTRALIZE` |
| `2` | `FRP_SCHED_NEUTRALIZE` |
| `3` | `FRP_SCHED_NEUTRALIZE` |
| `4` | `FRP_SCHED_NEUTRALIZE` |
| `5` | `FRP_SCHED_NEUTRALIZE` |
| `6` | `FRP_SCHED_NEUTRALIZE` |
| `7` | `FRP_SCHED_NEUTRALIZE` |

Excite ticks admit:

- same-state retention;
- `0 → -1`;
- `0 → 1`;
- pending-route completion.

Neutralize ticks admit:

- same-state retention;
- `-1 → 0`;
- `1 → 0`;
- opposite-polarity first-leg routing.

Required scheduler relation:

`16 ticks → excite = 2, neutralize = 14`

## Active-Neutral Routing Artifacts

Direct opposite-polarity execution is excluded from the retained-state boundary:

`-1 → 1`

`1 → -1`

The implemented routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

The first eligible neutralize-capable tick performs:

`nonzero state → active neutral 0`

The requested opposite polarity is stored in:

`pending_route`

A later commit-capable tick performs:

`active neutral 0 → pending_route`

The two route legs are separate state changes on separate eligible ticks.

Each leg independently consumes transition capacity.

## Pending-Route Artifact Contract

Each cell contains one retained pending-route slot.

The slot values use the canonical balanced ternary encoding:

| Pending value | Meaning |
|---|---|
| `0` | no retained pending polarity |
| `-1` | retained negative completion target |
| `1` | retained positive completion target |
| reserved | invalid route encoding |

Pending-route ownership provides:

- completion priority over new same-cell requests;
- exact target-polarity retention;
- stability across scheduler-ineligible ticks;
- stability across transition-capacity deferral;
- completion only from retained active neutral `0`;
- clearing only after accepted completion writeback;
- one retained route per cell.

## Transition-Capacity Artifacts

The distributed transition fraction is:

`0.25`

The per-tick transition boundary is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified parameter relations:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Capacity is consumed by:

- `0 → -1`;
- `0 → 1`;
- `-1 → 0`;
- `1 → 0`;
- opposite-polarity first-leg execution;
- pending-route completion.

Same-state retention consumes no transition capacity.

Capacity priority is:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit requests in ascending lane order.

Capacity relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

## Package Artifact

### File

`frp_m16_pkg.sv`

### Definitions

The package defines:

- state widths;
- scheduler-mode widths;
- scheduler-state widths;
- transition-class widths;
- counter widths;
- default cell count;
- transition-fraction constants;
- canonical ternary encoding;
- scheduler mode encoding;
- scheduler state encoding;
- transition-class encoding;
- request-rejection encoding;
- invariant flag indexes;
- request-lane capacity calculation.

### Shared Functions

The package provides functions for:

- canonical ternary-domain checking;
- reserved-state detection;
- zero-state detection;
- nonzero-state detection;
- positive-state detection;
- negative-state detection;
- opposite-polarity detection;
- legal state-change detection;
- pending-route detection;
- transition classification;
- transition target selection;
- transition-capacity classification;
- scheduler-mode validation;
- scheduler-state validation;
- scheduler-state decoding;
- commit-capability detection;
- neutralize-capability detection;
- scheduler transition eligibility;
- request-lane count calculation;
- cell-index width calculation;
- packed-state width calculation.

## Scheduler Artifact

### File

`frp_m16_scheduler.sv`

### Inputs

- clock;
- active-low reset;
- tick enable;
- counter clear;
- scheduler mode.

### Outputs

- registered scheduler mode;
- registered scheduler state;
- tick index;
- period index;
- total recorded ticks;
- free count;
- balance count;
- commit count;
- excite count;
- neutralize count;
- state-specific enables;
- scheduler validity;
- scheduler-counter validity.

### Counter Invariant

`scheduler_count_free`

`+ scheduler_count_balance`

`+ scheduler_count_commit`

`+ scheduler_count_excite`

`+ scheduler_count_neutralize`

`= ticks_recorded`

## Request-Lane Artifact

### File

`frp_m16_request_lanes.sv`

### Arbitration Order

Requests are examined in ascending lane order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

### Rejection Classes

A request may be rejected for:

- invalid cell index;
- reserved target encoding;
- duplicate cell ownership;
- scheduler ineligibility;
- transition-capacity rejection;
- retained pending-route ownership;
- disabled tick.

### Outputs

The module provides:

- accepted-lane mask;
- rejected-lane mask;
- rejection-class masks;
- neutralized-request mask;
- accepted-cell mask;
- rejected-cell mask;
- neutral-routed-cell mask;
- requested-direct-cell mask;
- lane-event telemetry;
- arbitration invariant signals.

## Pending-Route Artifact

### File

`frp_m16_pending_routes.sv`

### Register Operations

The module performs:

- pending-route creation;
- pending-route retention;
- pending-route deferral;
- pending-route completion;
- pending-route clearing;
- overwrite prevention;
- reserved-state detection;
- queue-overflow detection.

A new pending route is created only when the corresponding opposite-polarity first leg receives transition capacity.

A pending route is cleared only when the corresponding completion leg receives transition capacity.

## Active-Neutral Artifact

### File

`frp_m16_active_neutral.sv`

### Transition Classes

The module generates candidates for:

- same-state retention;
- zero-to-nonzero transition;
- nonzero-to-zero transition;
- opposite-polarity first leg;
- pending-route completion.

### Outputs

The module provides:

- packed state candidate;
- transition-valid mask;
- same-state mask;
- zero-to-nonzero mask;
- nonzero-to-zero mask;
- opposite-polarity mask;
- neutral-routed mask;
- pending-completion mask;
- actual-direct mask;
- reserved-transition mask;
- accepted-change candidate mask;
- transition event telemetry;
- transition invariant signals.

## Capacity-Guard Artifact

### File

`frp_m16_capacity_guard.sv`

### Function

The module selects the bounded subset of state-changing candidates admitted for the current tick.

It provides:

- capacity-approved request lanes;
- capacity-rejected request lanes;
- capacity-accepted cell mask;
- capacity-rejected cell mask;
- accepted-change mask;
- accepted-change count;
- remaining capacity;
- capacity-exhausted signal;
- switch-load numerator;
- capacity telemetry;
- capacity invariant signals.

## Retained-State Artifact

### File

`frp_m16_state_update.sv`

### Function

The module commits capacity-approved transition candidates into retained balanced ternary state.

It provides:

- registered retained state;
- combinational next state;
- public state output;
- state-write mask;
- state-hold mask;
- reset mask;
- reserved-state mask;
- accepted-change count;
- switch-load numerator;
- writeback telemetry;
- state-update invariant signals.

## Integrated Core Artifact

### File

`frp_m16_core.sv`

### Module Hierarchy

The integrated core instantiates:

- `frp_m16_scheduler`;
- `frp_m16_request_lanes`;
- `frp_m16_active_neutral`;
- `frp_m16_capacity_guard`;
- `frp_m16_pending_routes`;
- `frp_m16_state_update`.

### Architectural Tick Flow

For each enabled tick:

1. decode scheduler state;
2. identify eligible pending completions;
3. arbitrate explicit request lanes;
4. classify accepted transitions;
5. generate active-neutral candidates;
6. apply pending-completion priority;
7. apply transition capacity;
8. commit retained-state changes;
9. create or clear pending routes;
10. update telemetry and invariant flags.

### Public Event Sources

The integrated boundary exposes one architectural source for:

- requested direct events;
- prevented direct events;
- neutral-routed events;
- actual direct events;
- reserved-state events;
- queue-overflow events.

## Assertion Artifact

### File

`frp_m16_assertions.sv`

### Assertion Domains

The assertion layer checks:

- reset state;
- canonical retained-state domain;
- canonical pending-route domain;
- disabled-tick retention;
- state-change authorization;
- direct opposite-polarity exclusion;
- active-neutral first-leg execution;
- exact pending-polarity retention;
- pending-route deferral;
- completion only from active neutral `0`;
- scheduler-mode validity;
- scheduler-state validity;
- scheduler-counter relations;
- request accept/reject separation;
- transition-capacity relations;
- switch-load relation;
- zero-event invariants;
- integrated invariant flags.

## Testbench Artifact

### File

`frp_m16_tb.sv`

### Execution Domains

The deterministic testbench executes:

- reset to active neutral state;
- `free` execution;
- `7/1` execution;
- `1/7` execution;
- `0 → 1`;
- `1 → 0 → -1`;
- `-1 → 0 → 1`;
- pending-route retention;
- pending-route completion;
- transition-capacity saturation;
- counter clearing with retained state preserved.

### Scheduler Sequences

The testbench verifies:

`free: 16 free ticks`

`7/1: 56 balance ticks + 8 commit ticks`

`1/7: 2 excite ticks + 14 neutralize ticks`

### Terminal Invariants

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Include and Elaboration Graph

Simulation entry artifact:

`frp_m16_tb.sv`

The testbench includes:

- `frp_m16_pkg.sv`;
- `frp_m16_core.sv`;
- `frp_m16_assertions.sv`.

The integrated core includes:

- `frp_m16_pkg.sv`;
- `frp_m16_scheduler.sv`;
- `frp_m16_request_lanes.sv`;
- `frp_m16_pending_routes.sv`;
- `frp_m16_active_neutral.sv`;
- `frp_m16_capacity_guard.sv`;
- `frp_m16_state_update.sv`.

All SystemVerilog artifacts use include guards.

Top-level simulation module:

`frp_m16_tb`

Top-level synthesis boundary:

`frp_m16_core`

## Semantic Dependency Order

The semantic dependency order is:

`frp_m16_pkg.sv`

→ `frp_m16_scheduler.sv`

→ `frp_m16_request_lanes.sv`

→ `frp_m16_active_neutral.sv`

→ `frp_m16_capacity_guard.sv`

→ `frp_m16_pending_routes.sv`

→ `frp_m16_state_update.sv`

→ `frp_m16_core.sv`

→ `frp_m16_assertions.sv`

→ `frp_m16_tb.sv`

Pending-route completion identification precedes explicit request admission inside the integrated tick relation.

Pending-route register modification follows capacity admission.

## Integrated Invariant Set

| Index | Invariant |
|---:|---|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` |
| `8` | `FRP_INV_NO_RESERVED_STATE` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` |

## M15 to M16 Artifact Mapping

| M15 execution element | M16 RTL artifact |
|---|---|
| balanced ternary retained state | `frp_m16_pkg.sv`, `frp_m16_state_update.sv` |
| scheduler mode and scheduler state | `frp_m16_scheduler.sv` |
| deterministic transition requests | `frp_m16_request_lanes.sv` |
| active neutral polarity routing | `frp_m16_active_neutral.sv` |
| retained opposite target | `frp_m16_pending_routes.sv` |
| distributed transition fraction | `frp_m16_capacity_guard.sv` |
| integrated retained-state tick | `frp_m16_core.sv` |
| execution invariants | `frp_m16_assertions.sv` |
| deterministic execution sequence | `frp_m16_tb.sv` |

## Author

Maksym Marnov

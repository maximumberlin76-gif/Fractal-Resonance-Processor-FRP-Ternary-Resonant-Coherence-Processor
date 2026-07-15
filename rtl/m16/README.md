# FRP M16 RTL Core Realization Layer

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## RTL Boundary

The M16 layer implements the retained balanced ternary execution boundary of FRP in SystemVerilog.

The RTL boundary receives phase-derived ternary targets and explicit transition requests, applies the temporal execution architecture, routes opposite-polarity transitions through the active neutral state, enforces distributed transition capacity, retains pending polarity, and commits the resulting balanced ternary processor state.

Execution chain:

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

## Balanced Ternary State Domain

The retained processor-state domain is:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | active neutral balancing / damping / transition / stabilization state |
| `+1` | positive / excitatory / phase-supporting / constructive potential |

The neutral state `0` is an active processor state. It provides logical neutrality, phase damping, balancing, transition buffering, conflict neutralization, polarity bridging, switching-load distribution, temporal scheduling control, and retained-state stabilization.

## Canonical Hardware Encoding

| Ternary state | Two-bit encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The processor-state, target, transition-candidate, and pending-route domains use the same canonical encoding.

`reserved_state_events = 0`

## Active-Neutral Polarity Routing

Direct opposite-polarity transitions are forbidden:

`-1 → +1`

`+1 → -1`

Every opposite-polarity transition is separated across eligible processor ticks:

`-1 → 0 → +1`

`+1 → 0 → -1`

For:

`state_i × target_i = -1`

the first eligible neutralization tick performs:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick performs:

`0 → pending_route_i`

`actual_direct_events = 0`

## Pending-Route State

Each cell contains one retained pending-route slot. The slot stores the exact requested opposite polarity during the active-neutral interval.

A retained pending route:

- owns its cell until completion;
- has priority over a new request for the same cell;
- retains its polarity across scheduler-ineligible ticks and capacity deferral;
- completes only from retained state `0`;
- clears only after the corresponding `0 → pending polarity` state writeback;
- cannot be overwritten by another route.

For `+1 → -1`:

`+1 → 0`, retain `pending_route = -1`, wait through ineligible ticks, commit `0 → -1`, clear the pending slot.

For `-1 → +1`:

`-1 → 0`, retain `pending_route = +1`, wait through ineligible ticks, commit `0 → +1`, clear the pending slot.

`queue_overflow_events = 0`

## Temporal Execution Architecture

FRP uses three processor execution modes:

- `free`;
- `7/1`;
- `1/7`.

The scheduler state determines which transition classes execute on each tick.

### Free Mode

Every enabled tick is `free`.

The `free` state is commit-capable and neutralize-capable. It executes same-state retention, `0 → ±1`, `±1 → 0`, the first leg of an opposite-polarity route, and pending-route completion from `0`.

`scheduler_state(tick) = free`

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

`scheduler_state(tick) = commit`, when `(tick + 1) mod 8 = 0`

`scheduler_state(tick) = balance`, otherwise.

A `balance` tick is neutralize-capable. It executes same-state retention, `±1 → 0`, and the first leg of an opposite-polarity route.

A `commit` tick is commit-capable. It executes same-state retention, `0 → ±1`, and pending-route completion from active neutral `0`.

An opposite-polarity route initiated during a balance tick remains retained until the next commit tick.

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

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

`scheduler_state(tick) = excite`, when `tick mod 8 = 0`

`scheduler_state(tick) = neutralize`, otherwise.

An `excite` tick is commit-capable. It executes same-state retention, `0 → ±1`, and pending-route completion from active neutral `0`.

A `neutralize` tick is neutralize-capable. It executes same-state retention, `±1 → 0`, and the first leg of an opposite-polarity route.

An opposite-polarity route initiated during a neutralize tick remains retained until the next excite tick.

`16 ticks → excite = 2, neutralize = 14`

### Scheduler Counter Relation

`sum(scheduler_counts) = ticks_recorded`

The scheduler counter-clear input clears the scheduler event counters while retained ternary state, retained pending routes, scheduler mode, and scheduler tick position continue through the execution sequence.

## Transition Classes

The transition classifier distinguishes:

- same-state retention;
- zero-to-nonzero transition;
- nonzero-to-zero transition;
- opposite-polarity request;
- pending-route completion;
- reserved operand;
- invalid transition.

| Transition class | Commit-capable state | Neutralize-capable state |
|---|---:|---:|
| same state | yes | yes |
| `0 → ±1` | yes | no |
| `±1 → 0` | no | yes |
| opposite-polarity first leg `±1 → 0` | no | yes |
| pending completion `0 → pending` | yes | no |

The `free` scheduler state belongs to both capability classes.

## Request-Lane Arbitration

The request-lane boundary accepts request-valid bits, cell indexes, balanced ternary targets, retained cell state, retained pending-route state, and scheduler state.

Request lanes are processed in ascending lane order.

For each tick:

1. invalid cell indexes are rejected;
2. reserved target encodings are rejected;
3. an earlier accepted lane owns its cell for that tick;
4. a retained pending route owns its cell;
5. scheduler-ineligible transitions are rejected;
6. eligible lanes become transition candidates.

One cell receives at most one explicit request acceptance per tick.

## Distributed Transition Capacity

`transition_fraction = 0.25`

`max_changes = max(1, round(CELLS × transition_fraction))`

`REQUEST_LANES = max_changes`

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Capacity is consumed by an actual retained-state change. Same-state retention consumes no capacity.

The two legs of an opposite-polarity route consume capacity on separate ticks:

- first leg: `±1 → 0`;
- completion leg: `0 → pending polarity`.

Capacity order:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit request lanes in ascending lane order.

A capacity-deferred route retains its state and pending polarity.

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

`switch_load = switch_load_numerator / CELLS`

## Retained-State Tick Order

For every enabled RTL tick:

1. register the selected scheduler mode;
2. determine the scheduler state for the current period index;
3. identify pending-route completion candidates;
4. arbitrate explicit requests in ascending lane order;
5. classify each accepted transition;
6. generate active-neutral state candidates;
7. retain opposite-polarity targets for first-leg candidates;
8. place pending completions before explicit requests in the capacity order;
9. admit state changes up to `REQUEST_LANES`;
10. commit the admitted retained-state changes;
11. create pending routes for admitted opposite-polarity first legs;
12. clear pending routes for admitted completion legs;
13. retain every deferred state and route;
14. update scheduler counters and architectural telemetry.

The state produced by tick `N` is the retained input state of tick `N + 1`.

## Reset State

Reset establishes:

- every retained ternary cell in active neutral state `0`;
- every pending-route slot at `0`;
- scheduler mode `free`;
- scheduler state `free`;
- scheduler tick and event counters at zero.

## Core Parameters

| Parameter | Meaning |
|---|---|
| `CELLS` | number of retained balanced ternary cells |
| `STATE_BITS` | packed width of one ternary state; canonical value `2` |
| `REQUEST_LANES` | maximum state-changing requests admitted per tick |
| `CELL_INDEX_BITS` | packed cell-index width |
| `COUNTER_BITS` | telemetry counter width |

## Core Interface

Inputs:

- `clk`, `rst_n`, `tick_enable`, `clear_counters`;
- scheduler mode;
- request-valid lanes, cell indexes, and ternary targets;
- phase-derived packed target state.

Outputs:

- retained balanced ternary state and retained pending-route state;
- scheduler mode, scheduler state, tick count, and state counters;
- request acceptance and rejection;
- accepted-cell, neutral-routed-cell, and accepted-change masks;
- accepted-change count, remaining capacity, capacity exhaustion, and switch-load numerator;
- requested, prevented, neutral-routed, actual-direct, reserved-state, and queue-overflow event counts;
- integrated invariant flags.

## Integrated Invariants

| Invariant | Meaning |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | retained state, target, candidate, and pending-route values remain in the canonical ternary domain |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | scheduler states and counters correspond to executed ticks |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | request arbitration preserves ascending lane order and one accepted request per cell |
| `FRP_INV_PENDING_POLARITY_VALID` | pending polarity remains retained until eligible completion |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | every opposite-polarity transition is separated through active neutral `0` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | committed state changes remain inside the per-tick transition boundary |
| `FRP_INV_STATE_UPDATE_VALID` | retained-state writeback matches admitted transition candidates |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | no direct opposite-polarity transition reaches retained state |
| `FRP_INV_NO_RESERVED_STATE` | reserved ternary encoding never reaches the retained processor boundary |
| `FRP_INV_NO_QUEUE_OVERFLOW` | retained pending-route storage is never overwritten |

## SystemVerilog Modules

| File | Function |
|---|---|
| `frp_m16_pkg.sv` | canonical encodings, scheduler states, transition classes, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution and scheduler counters |
| `frp_m16_request_lanes.sv` | deterministic request arbitration and pending-cell ownership |
| `frp_m16_pending_routes.sv` | retained opposite-polarity target storage and completion clearing |
| `frp_m16_active_neutral.sv` | active-neutral transition-candidate generation |
| `frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `frp_m16_state_update.sv` | capacity-approved retained-state writeback |
| `frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | temporal, domain, routing, capacity, and writeback assertions |
| `frp_m16_tb.sv` | deterministic executable architecture testbench |

## RTL Documentation

| File | Function |
|---|---|
| `README.md` | M16 RTL architecture and directory interface |
| `ARTIFACTS.md` | RTL source and documentation manifest |
| `SIMULATION.md` | simulator build and execution commands |
| `SIMULATION_TRANSCRIPT.md` | simulator execution transcript |
| `CLOSURE.md` | M16 RTL closure record |

## Assertion Layer

The assertion layer checks:

- canonical ternary state and pending-route encodings;
- reset to active neutral state;
- retained state and route stability while ticks are disabled;
- state changes only through accepted-change masks;
- absence of direct opposite-polarity writeback;
- first-leg routing to active neutral `0`;
- retention of the exact opposite pending polarity;
- completion only from active neutral `0`;
- pending-route stability during deferral;
- scheduler mode, scheduler state, and counter relations;
- request acceptance and rejection separation;
- transition-capacity and switch-load relations;
- zero direct, reserved-state, and queue-overflow events;
- all integrated invariant flags.

## Deterministic Testbench

The executable testbench covers:

- `free`: every tick in `free`, both opposite-polarity routes, pending-route creation and completion, two-lane capacity saturation, and counter clearing with retained state preserved;
- `7/1`: seven balance ticks followed by one commit tick, first-leg routing on balance, pending retention through balance, completion on commit, and `56 balance + 8 commit` across `64` ticks;
- `1/7`: one excite tick followed by seven neutralize ticks, first-leg routing on neutralize, pending retention through neutralize, completion on excite, and `2 excite + 14 neutralize` across `16` ticks.

Terminal execution counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## M15 to M16 Execution Mapping

`phase-coherence dynamics`

→ `phase-derived balanced ternary target`

→ `stateful quantized retained-state execution`

→ `cycle-exact integer trace`

→ `deterministic RTL comparison vectors`

→ `M16 SystemVerilog scheduler, routing, capacity, and writeback`

→ `retained balanced ternary state`

## Author

Maksym Marnov

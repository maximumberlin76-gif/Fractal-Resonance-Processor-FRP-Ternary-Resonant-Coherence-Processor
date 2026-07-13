# FRP M16 RTL Simulation Transcript

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Simulation Boundary

Simulation source:

`rtl/m16/frp_m16_tb.sv`

Top-level simulation module:

`frp_m16_tb`

SystemVerilog include path:

`rtl/m16`

Build directory:

`/tmp/frp_m16_obj`

Build log:

`/tmp/frp_m16_build.log`

Execution log:

`/tmp/frp_m16_execution.log`

## Build Command

`verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log`

## Execution Command

`/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log`

## Artifact Set

| File | Function |
|---|---|
| `frp_m16_pkg.sv` | balanced ternary encodings, scheduler states, transition classes, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` potakt execution |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-polarity storage and completion |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | temporal and architectural assertion layer |
| `frp_m16_tb.sv` | deterministic executable testbench |

## Toolchain Record

| Field | Recorded value |
|---|---|
| Verilator version | |
| C++ compiler version | |
| Build result | |
| Execution result | |
| Assertion result | |
| Repository commit | |
| Execution date | |

## Testbench Configuration

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

Transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

For eight retained cells:

`REQUEST_LANES = 2`

## Balanced Ternary Encoding

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The state `0` is the active neutral processor state.

## Reset Record

The reset sequence establishes:

- every retained processor cell at `0`
- every pending-route slot at `0`
- scheduler mode `free`
- scheduler state `free`
- scheduler counters at `0`

Recorded reset result:

| Relation | Recorded value |
|---|---|
| `state_out = 0` | |
| `pending_route_out = 0` | |
| `ticks_recorded_q = 0` | |

## Free-Mode Record

The free-mode sequence contains:

`16 enabled ticks`

Scheduler relation:

| Scheduler state | Required count | Recorded count |
|---|---:|---:|
| `free` | `16` | |
| `balance` | `0` | |
| `commit` | `0` | |
| `excite` | `0` | |
| `neutralize` | `0` | |

The free-mode sequence executes:

- `0 → +1`
- `+1 → 0 → -1`
- `-1 → 0 → +1`
- pending-route creation
- pending-route completion
- two-transition capacity saturation
- scheduler-counter clearing with retained state preserved

Recorded free-mode result:

| Relation | Recorded value |
|---|---|
| `+1 → 0 → -1` | |
| `-1 → 0 → +1` | |
| opposite target retained in `pending_route` | |
| pending route cleared after completion | |
| two accepted changes in one tick | |
| retained state preserved by counter clear | |

## 7/1 Scheduler Record

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

The testbench executes:

`64 enabled ticks`

Scheduler relation:

| Scheduler state | Required count | Recorded count |
|---|---:|---:|
| `free` | `0` | |
| `balance` | `56` | |
| `commit` | `8` | |
| `excite` | `0` | |
| `neutralize` | `0` | |

The `7/1` execution sequence verifies:

- zero-to-nonzero release is retained during balance ticks
- zero-to-nonzero release executes during the commit tick
- opposite-polarity first-leg routing executes during a balance tick
- pending polarity remains retained through the following balance ticks
- pending completion executes during the following commit tick

Recorded `7/1` result:

| Relation | Recorded value |
|---|---|
| seven balance ticks followed by one commit tick | |
| `balance = 56` | |
| `commit = 8` | |
| first route leg executed during balance | |
| pending polarity retained through balance | |
| completion executed during commit | |

## 1/7 Scheduler Record

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

The testbench executes:

`16 enabled ticks`

Scheduler relation:

| Scheduler state | Required count | Recorded count |
|---|---:|---:|
| `free` | `0` | |
| `balance` | `0` | |
| `commit` | `0` | |
| `excite` | `2` | |
| `neutralize` | `14` | |

The `1/7` execution sequence verifies:

- zero-to-nonzero release executes during an excite tick
- opposite-polarity first-leg routing executes during a neutralize tick
- pending polarity remains retained through the following neutralize ticks
- pending completion executes during the following excite tick

Recorded `1/7` result:

| Relation | Recorded value |
|---|---|
| one excite tick followed by seven neutralize ticks | |
| `excite = 2` | |
| `neutralize = 14` | |
| first route leg executed during neutralize | |
| pending polarity retained through neutralize | |
| completion executed during excite | |

## Transition-Capacity Record

Required relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

Recorded transition-capacity result:

| Relation | Recorded value |
|---|---|
| `accepted_changes <= REQUEST_LANES` | |
| `capacity_remaining` relation | |
| `capacity_exhausted` relation | |
| `switch_load_numerator` relation | |
| pending completion priority | |
| ascending request-lane order | |

## Active-Neutral Routing Record

Forbidden retained-state transitions:

`-1 → +1`

`+1 → -1`

Executed routes:

`-1 → 0 → +1`

`+1 → 0 → -1`

Recorded routing result:

| Relation | Recorded value |
|---|---|
| direct `-1 → +1` absent | |
| direct `+1 → -1` absent | |
| `-1 → 0 → +1` executed | |
| `+1 → 0 → -1` executed | |
| pending target polarity preserved | |
| completion executed only from `0` | |

## Assertion Record

The assertion layer verifies:

- canonical retained-state encoding
- canonical pending-route encoding
- reset to active neutral state `0`
- disabled-tick state retention
- disabled-tick pending-route retention
- state-change authorization
- direct opposite-polarity exclusion
- active-neutral first-leg execution
- exact pending-polarity retention
- pending-route deferral
- completion only from retained state `0`
- scheduler-mode validity
- scheduler-state validity
- scheduler-counter relation
- request acceptance and rejection separation
- transition-capacity relations
- switch-load relation
- integrated invariant flags

Recorded assertion result:

| Assertion boundary | Recorded value |
|---|---|
| state-domain assertions | |
| pending-route assertions | |
| scheduler assertions | |
| active-neutral assertions | |
| capacity assertions | |
| retained-state writeback assertions | |
| integrated invariant assertions | |

## Terminal Output

The exact console output from:

`/tmp/frp_m16_execution.log`

is recorded below.

## Console Output


## Terminal Relations

| Output relation | Recorded value |
|---|---|
| `FRP M16 deterministic RTL testbench completed.` | |
| `CELLS=8 REQUEST_LANES=2` | |
| `ticks_recorded=16` | |
| `actual_direct_events=0` | |
| `reserved_state_events=0` | |
| `queue_overflow_events=0` | |

## Integrated Invariant Record

| Invariant | Recorded value |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | |
| `FRP_INV_PENDING_POLARITY_VALID` | |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | |
| `FRP_INV_STATE_UPDATE_VALID` | |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | |
| `FRP_INV_NO_RESERVED_STATE` | |
| `FRP_INV_NO_QUEUE_OVERFLOW` | |

## Execution Result

| Qualification boundary | Recorded result |
|---|---|
| SystemVerilog compilation | |
| module elaboration | |
| executable testbench | |
| assertion execution | |
| free scheduler sequence | |
| `7/1` scheduler sequence | |
| `1/7` scheduler sequence | |
| active-neutral routing | |
| retained pending polarity | |
| transition-capacity enforcement | |
| retained-state writeback | |
| zero actual direct events | |
| zero reserved-state events | |
| zero queue-overflow events | |

## Author

Maksym Marnov

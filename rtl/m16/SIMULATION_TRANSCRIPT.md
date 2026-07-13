# FRP M16 RTL Simulation Transcript

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Qualification Record

Workflow:

`FRP M16 RTL Artifact Boundary`

Repository commit:

`0abed8d`

Branch:

`main`

Result:

`PASS`

SystemVerilog compilation:

`PASS`

Module elaboration:

`PASS`

Executable testbench:

`PASS`

Assertion execution:

`PASS`

Terminal marker validation:

`PASS`

Repository integrity:

`PASS`

## Simulation Boundary

Simulation source:

`rtl/m16/frp_m16_tb.sv`

Top-level simulation module:

`frp_m16_tb`

Top-level synthesis module:

`frp_m16_core`

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

## Artifact Boundary

The qualified RTL boundary contains ten SystemVerilog artifacts:

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

The RTL documentation boundary contains:

| File | Function |
|---|---|
| `README.md` | M16 RTL architecture and execution semantics |
| `ARTIFACTS.md` | RTL artifact manifest |
| `SIMULATION.md` | build and execution procedure |
| `SIMULATION_TRANSCRIPT.md` | executable qualification record |
| `CLOSURE.md` | M16 RTL closure record |

Artifact relation:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

Artifact-boundary validation:

`PASS`

## Testbench Configuration

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

Transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified relation:

`8 cells → 2 request lanes`

Result:

`PASS`

## Balanced Ternary Encoding

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The state `0` executed as the active neutral processor state.

Canonical retained-state domain:

`PASS`

Canonical pending-route domain:

`PASS`

Reserved encoding exclusion:

`PASS`

## Reset Record

Reset established:

- every retained processor cell at `0`
- every pending-route slot at `0`
- scheduler mode `free`
- scheduler state `free`
- scheduler tick counter at `0`
- every scheduler-state counter at `0`

| Reset relation | Result |
|---|---|
| `state_out = 0` | `PASS` |
| `pending_route_out = 0` | `PASS` |
| `ticks_recorded_q = 0` | `PASS` |
| scheduler counters equal `0` | `PASS` |

## Free-Mode Record

Executed ticks:

`16`

Scheduler-state counts:

| Scheduler state | Recorded count |
|---|---:|
| `free` | `16` |
| `balance` | `0` |
| `commit` | `0` |
| `excite` | `0` |
| `neutralize` | `0` |

Scheduler relation:

`16 ticks → free = 16`

Result:

`PASS`

### Zero-to-Positive Transition

Executed transition:

`0 → +1`

Result:

`PASS`

### Positive-to-Negative Route

Requested transition:

`+1 → -1`

First tick:

`+1 → 0`

Retained route:

`pending_route = -1`

Following eligible tick:

`0 → -1`

Completed route:

`+1 → 0 → -1`

Result:

`PASS`

### Negative-to-Positive Route

Requested transition:

`-1 → +1`

First tick:

`-1 → 0`

Retained route:

`pending_route = +1`

Following eligible tick:

`0 → +1`

Completed route:

`-1 → 0 → +1`

Result:

`PASS`

### Free-Mode Capacity

Executed during one tick:

`cell 1: 0 → +1`

`cell 2: 0 → +1`

Recorded relation:

| Capacity signal | Value |
|---|---:|
| `accepted_changes` | `2` |
| `capacity_remaining` | `0` |
| `capacity_exhausted` | `1` |
| `switch_load_numerator` | `2` |

Result:

`PASS`

### Scheduler Counter Clear

The scheduler counter bank was cleared while retained balanced ternary state and pending-route state remained unchanged.

Result:

`PASS`

## 7/1 Scheduler Record

Executed ticks:

`64`

Repeating scheduler sequence:

`balance → balance → balance → balance → balance → balance → balance → commit`

Scheduler-state counts:

| Scheduler state | Recorded count |
|---|---:|
| `free` | `0` |
| `balance` | `56` |
| `commit` | `8` |
| `excite` | `0` |
| `neutralize` | `0` |

Required relation:

`64 ticks → balance = 56, commit = 8`

Result:

`PASS`

### 7/1 Zero Release

During balance ticks:

`0 → +1` remained uncommitted.

During the commit tick:

`0 → +1` executed.

Result:

`PASS`

### 7/1 Active-Neutral Route

During a balance tick:

`+1 → 0`

Retained route:

`pending_route = -1`

During the following balance ticks:

`state = 0`

`pending_route = -1`

During the following commit tick:

`0 → -1`

Completed route:

`+1 → 0 → -1`

Result:

`PASS`

Pending polarity retained across the balance interval:

`PASS`

Pending completion restricted to the commit tick:

`PASS`

## 1/7 Scheduler Record

Executed ticks:

`16`

Repeating scheduler sequence:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

Scheduler-state counts:

| Scheduler state | Recorded count |
|---|---:|
| `free` | `0` |
| `balance` | `0` |
| `commit` | `0` |
| `excite` | `2` |
| `neutralize` | `14` |

Required relation:

`16 ticks → excite = 2, neutralize = 14`

Result:

`PASS`

### 1/7 Zero Release

During the excite tick:

`0 → +1`

Result:

`PASS`

### 1/7 Active-Neutral Route

During a neutralize tick:

`+1 → 0`

Retained route:

`pending_route = -1`

During the following neutralize ticks:

`state = 0`

`pending_route = -1`

During the following excite tick:

`0 → -1`

Completed route:

`+1 → 0 → -1`

Result:

`PASS`

Pending polarity retained across the neutralize interval:

`PASS`

Pending completion restricted to the excite tick:

`PASS`

## Active-Neutral Routing Record

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Executed tick-separated routes:

`-1 → 0 → +1`

`+1 → 0 → -1`

| Routing relation | Result |
|---|---|
| active neutral `0` executed as the intermediate state | `PASS` |
| direct `-1 → +1` absent | `PASS` |
| direct `+1 → -1` absent | `PASS` |
| `-1 → 0 → +1` executed | `PASS` |
| `+1 → 0 → -1` executed | `PASS` |
| requested opposite polarity retained | `PASS` |
| pending completion executed only from `0` | `PASS` |
| pending route cleared after completion | `PASS` |

## Pending-Route Record

| Pending-route relation | Result |
|---|---|
| one retained route slot per cell | `PASS` |
| exact requested polarity retained | `PASS` |
| pending route owns its cell | `PASS` |
| new same-cell request cannot overwrite pending route | `PASS` |
| scheduler deferral preserves pending route | `PASS` |
| transition-capacity deferral preserves pending route | `PASS` |
| completion requires retained state `0` | `PASS` |
| accepted completion clears pending route | `PASS` |
| pending-route overflow absent | `PASS` |

## Transition-Capacity Record

| Relation | Result |
|---|---|
| `accepted_changes <= REQUEST_LANES` | `PASS` |
| `capacity_remaining = REQUEST_LANES - accepted_changes` | `PASS` |
| `capacity_exhausted = (accepted_changes == REQUEST_LANES)` | `PASS` |
| `switch_load_numerator = accepted_changes` | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has capacity priority | `PASS` |
| explicit requests retain ascending lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

## Assertion Record

| Assertion boundary | Result |
|---|---|
| retained-state domain | `PASS` |
| pending-route domain | `PASS` |
| reset state | `PASS` |
| disabled-tick state retention | `PASS` |
| disabled-tick pending-route retention | `PASS` |
| state-change authorization | `PASS` |
| direct opposite-polarity exclusion | `PASS` |
| active-neutral first-leg execution | `PASS` |
| retained pending polarity | `PASS` |
| pending-route deferral | `PASS` |
| completion only from active neutral `0` | `PASS` |
| scheduler mode and state | `PASS` |
| scheduler-state counters | `PASS` |
| request acceptance and rejection separation | `PASS` |
| transition-capacity relations | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariant flags | `PASS` |

## Integrated Invariant Record

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

## Terminal Output

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

## Terminal Relations

| Output relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| final `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal output validation:

`PASS`

## Repository Integrity

The build directory and simulator logs were generated under `/tmp`.

Repository-local simulator directories were absent after execution.

Repository source modification during qualification:

`NONE`

Repository integrity result:

`PASS`

## Qualification Result

| Qualification boundary | Result |
|---|---|
| artifact inventory | `PASS` |
| SystemVerilog compilation | `PASS` |
| module elaboration | `PASS` |
| executable testbench | `PASS` |
| assertion execution | `PASS` |
| `free` scheduler sequence | `PASS` |
| `7/1` scheduler sequence | `PASS` |
| `1/7` scheduler sequence | `PASS` |
| active-neutral routing | `PASS` |
| retained pending polarity | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |

Final M16 RTL simulation result:

`PASS`

## Author

Maksym Marnov

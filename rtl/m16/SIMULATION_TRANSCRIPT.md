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

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Trigger:

`workflow_dispatch`

Workflow run:

`#82`

Repository commit:

`a68a2af`

Branch:

`main`

Final workflow status:

`SUCCESS`

Qualification artifact count:

`1`

## Final Qualified Source State

The successful qualification run was executed after correction of:

- SystemVerilog assertion message syntax in `frp_m16_assertions.sv`
- inferred combinational latches in `frp_m16_state_update.sv`
- inferred combinational latches in `frp_m16_request_lanes.sv`

The final qualified source boundary therefore includes the complete corrected M16 RTL chain at commit:

`a68a2af`

## Qualification Boundary

The workflow completed:

- repository checkout
- exact M16 artifact-boundary validation
- obsolete-workflow absence validation
- isolated simulation-path preparation
- Verilator toolchain installation
- M16 source-hash generation
- integrated SystemVerilog testbench build
- module elaboration
- executable testbench generation
- architectural testbench execution
- assertion execution
- terminal marker validation
- qualification result generation
- repository-integrity validation
- qualification evidence upload
- GitHub Actions summary publication

Overall qualification result:

`PASS`

## Simulation Entry Point

Simulation source:

`rtl/m16/frp_m16_tb.sv`

Top-level simulation module:

`frp_m16_tb`

Top-level synthesis boundary:

`frp_m16_core`

SystemVerilog include path:

`rtl/m16`

Build directory:

`/tmp/frp_m16_obj`

Build log:

`/tmp/frp_m16_build.log`

Execution log:

`/tmp/frp_m16_execution.log`

Toolchain log:

`/tmp/frp_m16_toolchain.log`

Source-hash record:

`/tmp/frp_m16_sources.sha256`

Qualification record:

`/tmp/frp_m16_qualification.txt`

## Toolchain Record

Execution environment:

`GitHub Actions — ubuntu-latest`

Installed toolchain components:

- `verilator`
- `g++`

Toolchain installation command:

`sudo apt-get install --yes verilator g++`

Toolchain version record command:

`verilator --version`

Compiler version record command:

`g++ --version | head -n 1`

Toolchain record path:

`/tmp/frp_m16_toolchain.log`

Toolchain installation and version-record generation:

`PASS`

## Build Command

`verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log`

## Execution Command

`/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log`

## Artifact Boundary

The qualified M16 RTL boundary contains ten SystemVerilog artifacts:

| File | Function |
|---|---|
| `frp_m16_pkg.sv` | balanced ternary encoding, scheduler types, transition classes, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-polarity creation, retention, completion, and clearing |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | temporal and architectural assertion layer |
| `frp_m16_tb.sv` | deterministic executable testbench |

The qualified documentation boundary contains five artifacts:

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

Qualified parameter relation:

`8 cells → 2 request lanes`

Result:

`PASS`

## Balanced Ternary Encoding

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

The state `0` executes as the active neutral processor state.

Qualified relations:

| Relation | Result |
|---|---|
| canonical retained-state encoding | `PASS` |
| canonical pending-route encoding | `PASS` |
| active neutral state `0` | `PASS` |
| reserved encoding excluded | `PASS` |

## Reset Record

Reset establishes:

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

Qualified scheduler relation:

`16 ticks → free = 16`

Result:

`PASS`

### Zero-to-Positive Transition

Executed transition:

`0 → 1`

Result:

`PASS`

### Positive-to-Negative Route

Requested transition:

`1 → -1`

First eligible tick:

`1 → 0`

Retained route:

`pending_route = -1`

Following eligible tick:

`0 → -1`

Completed route:

`1 → 0 → -1`

Result:

`PASS`

### Negative-to-Positive Route

Requested transition:

`-1 → 1`

First eligible tick:

`-1 → 0`

Retained route:

`pending_route = 1`

Following eligible tick:

`0 → 1`

Completed route:

`-1 → 0 → 1`

Result:

`PASS`

### Free-Mode Capacity

Two retained-state changes execute during one tick:

`cell 1: 0 → 1`

`cell 2: 0 → 1`

| Capacity signal | Value |
|---|---:|
| `accepted_changes` | `2` |
| `capacity_remaining` | `0` |
| `capacity_exhausted` | `1` |
| `switch_load_numerator` | `2` |

Result:

`PASS`

### Scheduler Counter Clear

The scheduler counter bank clears while preserving:

- retained balanced ternary state
- retained pending-route state

Result:

`PASS`

## 7/1 Scheduler Record

Executed ticks:

`64`

Repeating eight-tick sequence:

`balance → balance → balance → balance → balance → balance → balance → commit`

Scheduler-state counts:

| Scheduler state | Recorded count |
|---|---:|
| `free` | `0` |
| `balance` | `56` |
| `commit` | `8` |
| `excite` | `0` |
| `neutralize` | `0` |

Qualified scheduler relation:

`64 ticks → balance = 56, commit = 8`

Result:

`PASS`

### 7/1 Zero Release

During balance ticks:

`0 → 1` remains uncommitted.

During the commit tick:

`0 → 1` executes.

Result:

`PASS`

### 7/1 Active-Neutral Route

During a balance tick:

`1 → 0`

Retained route:

`pending_route = -1`

During the following balance ticks:

`state = 0`

`pending_route = -1`

During the following commit tick:

`0 → -1`

Completed route:

`1 → 0 → -1`

| Relation | Result |
|---|---|
| first route leg during balance | `PASS` |
| pending polarity retained through balance | `PASS` |
| completion during commit | `PASS` |

## 1/7 Scheduler Record

Executed ticks:

`16`

Repeating eight-tick sequence:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

Scheduler-state counts:

| Scheduler state | Recorded count |
|---|---:|
| `free` | `0` |
| `balance` | `0` |
| `commit` | `0` |
| `excite` | `2` |
| `neutralize` | `14` |

Qualified scheduler relation:

`16 ticks → excite = 2, neutralize = 14`

Result:

`PASS`

### 1/7 Zero Release

During the excite tick:

`0 → 1`

Result:

`PASS`

### 1/7 Active-Neutral Route

During a neutralize tick:

`1 → 0`

Retained route:

`pending_route = -1`

During the following neutralize ticks:

`state = 0`

`pending_route = -1`

During the following excite tick:

`0 → -1`

Completed route:

`1 → 0 → -1`

| Relation | Result |
|---|---|
| first route leg during neutralize | `PASS` |
| pending polarity retained through neutralize | `PASS` |
| completion during excite | `PASS` |

## Active-Neutral Routing Record

Forbidden direct retained-state transitions:

`-1 → 1`

`1 → -1`

Qualified tick-separated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

| Routing relation | Result |
|---|---|
| active neutral `0` executed as intermediate state | `PASS` |
| direct `-1 → 1` absent | `PASS` |
| direct `1 → -1` absent | `PASS` |
| `-1 → 0 → 1` executed | `PASS` |
| `1 → 0 → -1` executed | `PASS` |
| requested opposite polarity retained | `PASS` |
| pending completion executed only from `0` | `PASS` |
| pending route cleared after completion | `PASS` |

## Pending-Route Record

| Pending-route relation | Result |
|---|---|
| one retained route slot per cell | `PASS` |
| exact requested polarity retained | `PASS` |
| pending route owns its cell | `PASS` |
| same-cell overwrite prevented | `PASS` |
| scheduler deferral preserves route | `PASS` |
| transition-capacity deferral preserves route | `PASS` |
| completion requires retained state `0` | `PASS` |
| accepted completion clears route | `PASS` |
| pending-route overflow absent | `PASS` |

## Request-Lane Arbitration Record

The request boundary executes deterministic ascending lane order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

Qualified relations:

| Relation | Result |
|---|---|
| canonical request-target validation | `PASS` |
| valid cell-index enforcement | `PASS` |
| one accepted request per cell per tick | `PASS` |
| earlier accepted-lane ownership | `PASS` |
| pending-route ownership priority | `PASS` |
| scheduler transition eligibility | `PASS` |
| acceptance and rejection separation | `PASS` |
| latch-free combinational arbitration | `PASS` |

## Transition-Capacity Record

Qualified relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

| Capacity relation | Result |
|---|---|
| bounded accepted changes | `PASS` |
| capacity-remaining relation | `PASS` |
| capacity-exhausted relation | `PASS` |
| switch-load relation | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has priority | `PASS` |
| explicit requests preserve lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

## Retained-State Writeback Record

| Writeback relation | Result |
|---|---|
| reset initializes active neutral state | `PASS` |
| disabled ticks retain state | `PASS` |
| state-changing writeback requires capacity | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| opposite polarity commits first leg only | `PASS` |
| pending completion commits from `0` | `PASS` |
| capacity rejection preserves retained state | `PASS` |
| reserved encoding is not committed | `PASS` |
| direct opposite-polarity writeback is absent | `PASS` |
| latch-free combinational writeback | `PASS` |

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
| assertion message syntax | `PASS` |

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

## Console Output

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

Terminal marker validation:

`PASS`

## Repository Integrity

The simulator build directory and logs were generated under:

`/tmp`

Repository-local simulator directories were absent after qualification.

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## Qualification Evidence

The workflow uploaded one qualification artifact containing:

- toolchain record
- SystemVerilog source hashes
- Verilator build log
- architectural execution log
- qualification result record

Qualification evidence result:

`PASS`

## Execution Result

| Qualification boundary | Result |
|---|---|
| artifact inventory | `PASS` |
| documentation inventory | `PASS` |
| SystemVerilog parsing | `PASS` |
| module elaboration | `PASS` |
| latch-free required combinational boundaries | `PASS` |
| executable testbench generation | `PASS` |
| assertion execution | `PASS` |
| `free` scheduler sequence | `PASS` |
| `7/1` scheduler sequence | `PASS` |
| `1/7` scheduler sequence | `PASS` |
| active-neutral routing | `PASS` |
| retained pending polarity | `PASS` |
| request-lane arbitration | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariants | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |
| qualification evidence upload | `PASS` |

Final workflow record:

`FRP M16 RTL Artifact Boundary #82`

Final qualified commit:

`a68a2af`

Final M16 RTL simulation result:

`PASS`

## Author

Maksym Marnov

## Qualification Rerun Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Trigger | `workflow_dispatch` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

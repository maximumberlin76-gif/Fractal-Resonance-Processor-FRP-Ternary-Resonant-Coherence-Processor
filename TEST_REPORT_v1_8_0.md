# FRP v1.8.0 Test Report

## M16 RTL Core Realization and Execution Semantics Package

## Validation Status

`PASS`

## Validated Release Layer

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## Main Executable Semantic Reference File

`frp_prototype_v1_7_0.py`

The executable semantic reference remains the M15-qualified Python reference inherited by M16.

## Validation Environment

`GitHub Actions`

Workflow runner:

`ubuntu-latest`

RTL and FPGA preparation simulation toolchain:

- Verilator SystemVerilog parsing;

- Verilator module elaboration;

- Verilator executable testbench generation;

- compiled architectural simulation;

- SystemVerilog assertion execution.

## Validated Workflow Stack

Inherited M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

M16 RTL workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

M16 FPGA preparation workflow:

`.github/workflows/frp-m16-fpga-preparation.yml`

M16 maintenance workflows:

- `.github/workflows/frp-m16-canonical-core-domain.yml`;

- `.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

## Qualification Record Summary

| Layer | Workflow run | Qualified commit | Result | Artifact count | Status |
|---|---:|---|---|---:|---|
| M16 RTL initial closure | `#82` | `a68a2af` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 RTL qualification rerun | `#84` | `ede53cf` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation initial closure | `#1` | `326b69e` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| M16 FPGA preparation qualification rerun | `#2` | `ede53cf` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

## Validation Role

FRP v1.8.0 validates the executable M16 realization of the M15-qualified semantic and implementation-mapping boundary.

Validated execution chain:

`M15 floating semantic reference`

→ `M15 stateful quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 SystemVerilog scheduler, request, routing, capacity, and writeback`

→ `M16 integrated invariant evaluation`

→ `M16 target-independent FPGA reset and execution gating`

→ `M16 FPGA preparation qualification closure`

## Inherited M15 Qualification Boundary

Inherited release:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited executable semantic reference:

`frp_prototype_v1_7_0.py`

Inherited structured-output schema:

`frp.structured_output.v1.7.0`

Inherited benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 qualification results:

| Qualification record | Result |
|---|---:|
| M15 self-test suite | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Inherited qualification result:

`PASS`

## Foundation Document Validation

Validated mathematical foundation path:

`docs/mathematical_foundation.md`

Validated physical foundation path:

`docs/physical_foundation.md`

Repository path validation:

`PASS`

## Balanced Ternary Core Validation

Validated retained-state domain:

`{-1, 0, 1}`

Validated active neutral state:

`0`

Validated canonical encoding:

| Ternary state | Encoding | Result |
|---|---|---:|
| `-1` | `2'b11` | `PASS` |
| `0` | `2'b00` | `PASS` |
| `1` | `2'b01` | `PASS` |
| reserved | `2'b10` | excluded |

Validated encoding relations:

| Relation | Result |
|---|---:|
| canonical retained-state encoding | `PASS` |
| canonical phase-derived target encoding | `PASS` |
| canonical request-target encoding | `PASS` |
| canonical transition-candidate encoding | `PASS` |
| canonical pending-route encoding | `PASS` |
| active neutral state `0` remains executable | `PASS` |
| reserved encoding remains excluded from retained state | `PASS` |

## Active-Neutral Route Validation

Forbidden retained-state transitions:

`-1 → 1`

`1 → -1`

Validated tick-separated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated route relations:

| Relation | Result |
|---|---:|
| active neutral state `0` executes as the intermediate state | `PASS` |
| direct `-1 → 1` retained-state writeback is absent | `PASS` |
| direct `1 → -1` retained-state writeback is absent | `PASS` |
| `-1 → 0 → 1` executes across eligible ticks | `PASS` |
| `1 → 0 → -1` executes across eligible ticks | `PASS` |
| exact requested opposite polarity remains retained | `PASS` |
| pending completion executes only from `0` | `PASS` |
| pending route clears after accepted completion | `PASS` |

## M16 RTL Source Boundary Validation

Validated RTL directory:

`rtl/m16/`

Validated SystemVerilog artifact count:

`10`

| SystemVerilog artifact | Inventory result |
|---|---:|
| `rtl/m16/frp_m16_pkg.sv` | `PASS` |
| `rtl/m16/frp_m16_scheduler.sv` | `PASS` |
| `rtl/m16/frp_m16_request_lanes.sv` | `PASS` |
| `rtl/m16/frp_m16_pending_routes.sv` | `PASS` |
| `rtl/m16/frp_m16_active_neutral.sv` | `PASS` |
| `rtl/m16/frp_m16_capacity_guard.sv` | `PASS` |
| `rtl/m16/frp_m16_state_update.sv` | `PASS` |
| `rtl/m16/frp_m16_core.sv` | `PASS` |
| `rtl/m16/frp_m16_assertions.sv` | `PASS` |
| `rtl/m16/frp_m16_tb.sv` | `PASS` |

Validated RTL documentation count:

`5`

| Documentation artifact | Inventory result |
|---|---:|
| `rtl/m16/README.md` | `PASS` |
| `rtl/m16/ARTIFACTS.md` | `PASS` |
| `rtl/m16/SIMULATION.md` | `PASS` |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | `PASS` |
| `rtl/m16/CLOSURE.md` | `PASS` |

RTL artifact-boundary validation:

`PASS`

## M16 RTL Testbench Configuration

RTL testbench:

`rtl/m16/frp_m16_tb.sv`

Top-level testbench module:

`frp_m16_tb`

Integrated synthesis boundary:

`frp_m16_core`

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

Configuration result:

`PASS`

## M16 RTL Build and Execution

Build command:

```bash
verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log
```

Execution command:

```bash
/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log
```

| Execution boundary | Result |
|---|---:|
| SystemVerilog parsing | `PASS` |
| module elaboration | `PASS` |
| executable testbench generation | `PASS` |
| architectural testbench execution | `PASS` |
| SystemVerilog assertion execution | `PASS` |

## M16 RTL Reset Validation

Reset establishes:

- every retained processor state at `0`;

- every pending-route slot at `0`;

- scheduler mode `free`;

- scheduler state `free`;

- scheduler tick counter at `0`;

- every scheduler-state counter at `0`.

| Reset relation | Result |
|---|---:|
| `state_out = 0` | `PASS` |
| `pending_route_out = 0` | `PASS` |
| `ticks_recorded_q = 0` | `PASS` |
| scheduler counters equal `0` | `PASS` |

## Free Scheduler Validation

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

Qualified relation:

`16 ticks → free = 16`

Validation result:

`PASS`

### Free Zero-to-Positive Transition

Executed transition:

`0 → 1`

Validation result:

`PASS`

### Free Positive-to-Negative Route

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

Validation result:

`PASS`

### Free Negative-to-Positive Route

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

Validation result:

`PASS`

### Free Transition-Capacity Saturation

Two retained-state changes execute during one tick:

`cell 1: 0 → 1`

`cell 2: 0 → 1`

| Capacity signal | Value |
|---|---:|
| `accepted_changes` | `2` |
| `capacity_remaining` | `0` |
| `capacity_exhausted` | `1` |
| `switch_load_numerator` | `2` |

Validation result:

`PASS`

### Scheduler Counter Clear

The scheduler counter bank clears while preserving:

- retained balanced ternary state;

- retained pending-route state.

Validation result:

`PASS`

## 7/1 Scheduler Validation

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

Qualified relation:

`64 ticks → balance = 56, commit = 8`

Validation result:

`PASS`

### 7/1 Zero Release

During balance ticks:

`0 → 1` remains uncommitted.

During the commit tick:

`0 → 1` executes.

Validation result:

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
|---|---:|
| first route leg during balance | `PASS` |
| pending polarity retained through balance | `PASS` |
| completion during commit | `PASS` |

## 1/7 Scheduler Validation

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

Qualified relation:

`16 ticks → excite = 2, neutralize = 14`

Validation result:

`PASS`

### 1/7 Zero Release

During the excite tick:

`0 → 1`

Validation result:

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
|---|---:|
| first route leg during neutralize | `PASS` |
| pending polarity retained through neutralize | `PASS` |
| completion during excite | `PASS` |

## Pending-Route Validation

| Pending-route relation | Result |
|---|---:|
| one retained route slot per cell | `PASS` |
| exact requested polarity retained | `PASS` |
| pending route owns its cell | `PASS` |
| same-cell overwrite prevented | `PASS` |
| scheduler deferral preserves route | `PASS` |
| transition-capacity deferral preserves route | `PASS` |
| completion requires retained state `0` | `PASS` |
| accepted completion clears route | `PASS` |
| pending-route overflow absent | `PASS` |

## Request-Lane Arbitration Validation

Validated order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

| Arbitration relation | Result |
|---|---:|
| canonical request-target validation | `PASS` |
| valid cell-index enforcement | `PASS` |
| one accepted request per cell per tick | `PASS` |
| earlier accepted-lane ownership | `PASS` |
| pending-route ownership priority | `PASS` |
| scheduler transition eligibility | `PASS` |
| acceptance and rejection separation | `PASS` |
| latch-free combinational arbitration | `PASS` |

## Transition-Capacity Validation

Validated relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

| Capacity relation | Result |
|---|---:|
| bounded accepted changes | `PASS` |
| capacity-remaining relation | `PASS` |
| capacity-exhausted relation | `PASS` |
| switch-load relation | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has priority | `PASS` |
| explicit requests preserve lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

## Retained-State Writeback Validation

| Writeback relation | Result |
|---|---:|
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

## M16 RTL Assertion Validation

| Assertion boundary | Result |
|---|---:|
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

## M16 RTL Integrated Invariant Validation

| Invariant | Result |
|---|---:|
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

Integrated invariant vector:

`1111111111`

## M16 RTL Terminal Output Validation

Terminal markers:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| final `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal marker validation:

`PASS`

## M16 RTL Diagnostic Validation

| Diagnostic boundary | Result |
|---|---:|
| inferred latch diagnostics | `0` |
| multidriven diagnostics | `0` |
| latch-diagnostic rejection | `PASS` |
| multidriven-diagnostic rejection | `PASS` |

## M16 RTL Repository-Integrity Validation

Build directory and logs:

`/tmp`

Repository-local simulator directories after qualification:

`ABSENT`

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## M16 RTL Qualification Evidence

The qualification artifact contains:

- toolchain record;

- SystemVerilog source hashes;

- Verilator build log;

- architectural execution log;

- qualification result record.

Qualification artifact count:

`1`

Qualification evidence result:

`PASS`

## M16 RTL Final Qualification Table

| Qualification boundary | Result |
|---|---:|
| artifact inventory | `PASS` |
| documentation inventory | `PASS` |
| SystemVerilog parsing | `PASS` |
| module elaboration | `PASS` |
| latch-free required combinational boundaries | `PASS` |
| executable testbench generation | `PASS` |
| architectural simulation | `PASS` |
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

RTL qualification result:

`PASS`

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## M16 RTL Qualification Records

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification artifact count | `1` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |

## M16 FPGA Preparation Source Boundary Validation

Validated FPGA preparation directory:

`fpga/m16/`

Validated FPGA SystemVerilog artifact count:

`2`

| FPGA SystemVerilog artifact | Inventory result |
|---|---:|
| `fpga/m16/frp_m16_fpga_top.sv` | `PASS` |
| `fpga/m16/frp_m16_fpga_tb.sv` | `PASS` |

Validated FPGA documentation count:

`2`

| FPGA documentation artifact | Inventory result |
|---|---:|
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | `PASS` |
| `fpga/m16/CLOSURE.md` | `PASS` |

Validated inherited RTL dependency count:

`9`

| Inherited RTL dependency | Inventory result |
|---|---:|
| `rtl/m16/frp_m16_pkg.sv` | `PASS` |
| `rtl/m16/frp_m16_scheduler.sv` | `PASS` |
| `rtl/m16/frp_m16_request_lanes.sv` | `PASS` |
| `rtl/m16/frp_m16_pending_routes.sv` | `PASS` |
| `rtl/m16/frp_m16_active_neutral.sv` | `PASS` |
| `rtl/m16/frp_m16_capacity_guard.sv` | `PASS` |
| `rtl/m16/frp_m16_state_update.sv` | `PASS` |
| `rtl/m16/frp_m16_core.sv` | `PASS` |
| `rtl/m16/frp_m16_assertions.sv` | `PASS` |

FPGA source-boundary validation:

`PASS`

## M16 FPGA Preparation Testbench Configuration

FPGA integration top:

`frp_m16_fpga_top`

FPGA testbench:

`frp_m16_fpga_tb`

Instantiated execution core:

`frp_m16_core`

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

Qualified parameter relation:

`8 cells → 2 request lanes`

Configuration result:

`PASS`

## M16 FPGA Preparation Build and Execution

FPGA top elaboration command:

```bash
verilator --sv --lint-only --top-module frp_m16_fpga_top -Irtl/m16 -Ifpga/m16 fpga/m16/frp_m16_fpga_top.sv
```

FPGA testbench build command:

```bash
verilator --sv --timing --assert --binary --top-module frp_m16_fpga_tb -Irtl/m16 -Ifpga/m16 --Mdir /tmp/frp_m16_fpga_obj fpga/m16/frp_m16_fpga_tb.sv
```

FPGA testbench execution command:

```bash
/tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb
```

| Execution boundary | Result |
|---|---:|
| FPGA top parsing | `PASS` |
| FPGA top elaboration | `PASS` |
| FPGA testbench build | `PASS` |
| FPGA testbench execution | `PASS` |

## M16 FPGA Diagnostic Validation

| Diagnostic boundary | Result |
|---|---:|
| inferred latch diagnostics | `0` |
| multidriven diagnostics | `0` |
| latch-diagnostic rejection | `PASS` |
| multidriven-diagnostic rejection | `PASS` |

## M16 FPGA Balanced Ternary Validation

| Relation | Result |
|---|---:|
| retained state uses canonical balanced ternary encoding | `PASS` |
| pending route uses canonical balanced ternary encoding | `PASS` |
| active neutral state remains executable | `PASS` |
| reserved encoding remains excluded | `PASS` |

## M16 FPGA Reset-Synchronization Validation

External reset input:

`rst_n_async`

Internal core reset:

`rst_n_core`

Validated sequence:

1. external reset asserts asynchronously;
2. the synchronization register clears;
3. the first release edge remains blocked;
4. the second release edge activates `rst_n_core` and `core_ready`.

| Reset relation | Result |
|---|---:|
| asynchronous reset assertion | `PASS` |
| synchronization register cleared | `PASS` |
| first release edge remains blocked | `PASS` |
| second release edge activates `core_ready` | `PASS` |
| retained state remains `0` during reset | `PASS` |
| pending-route bank remains `0` during reset | `PASS` |
| scheduler counters remain `0` during reset | `PASS` |

Reset-synchronization result:

`PASS`

## M16 FPGA Core-Ready Input-Gating Validation

Validated relations:

`core_ready = rst_n_core`

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Before `core_ready`:

- ticks do not reach the core;

- counter-clear events do not reach the core;

- request-valid events do not reach the core;

- no request is accepted;

- retained state remains unchanged;

- pending routes remain unchanged;

- scheduler counters remain unchanged.

| Input-gating relation | Result |
|---|---:|
| tick blocking before readiness | `PASS` |
| counter-clear blocking before readiness | `PASS` |
| request blocking before readiness | `PASS` |
| retained-state preservation before readiness | `PASS` |
| pending-route preservation before readiness | `PASS` |
| scheduler-counter preservation before readiness | `PASS` |

Input-gating result:

`PASS`

## M16 FPGA Scheduler-Propagation Validation

Validated scheduler modes:

- `free`;

- `7/1`;

- `1/7`.

Validated scheduler states:

- `free`;

- `balance`;

- `commit`;

- `excite`;

- `neutralize`.

| Scheduler relation | Result |
|---|---:|
| free-mode propagation | `PASS` |
| 7/1-mode propagation | `PASS` |
| 1/7-mode propagation | `PASS` |
| scheduler-mode registration preserves retained state | `PASS` |
| scheduler-mode registration preserves pending routes | `PASS` |

Scheduler-propagation result:

`PASS`

## M16 FPGA Request-Propagation Validation

Qualified request:

`cell 0: 0 → 1`

| Request signal | Recorded value |
|---|---:|
| `request_accept[0]` | `1` |
| `request_reject[0]` | `0` |
| `accepted_changes` | `1` |

Retained-state result:

`cell 0 state = 1`

Pending-route result:

`cell 0 pending route = 0`

Request-propagation result:

`PASS`

## M16 FPGA Active-Neutral Routing Validation

Requested transition:

`1 → -1`

First eligible tick:

`1 → 0`

Retained pending target:

`pending_route = -1`

Following eligible tick:

`0 → -1`

Completed route:

`1 → 0 → -1`

| Event | Recorded value |
|---|---:|
| `requested_direct_events` | `1` |
| `prevented_direct_events` | `1` |
| `neutral_routed_events` | `1` |
| `actual_direct_events` | `0` |

| Routing relation | Result |
|---|---:|
| opposite-polarity request detected | `PASS` |
| direct transition prevented | `PASS` |
| active-neutral first leg executed | `PASS` |
| exact requested polarity retained | `PASS` |
| pending completion executed from `0` | `PASS` |
| pending route cleared after completion | `PASS` |
| direct retained-state transition absent | `PASS` |

Active-neutral routing result:

`PASS`

## M16 FPGA Retained Pending-Route Completion

Retained route before completion:

`pending_route = -1`

Completion state before execution:

`state = 0`

Completion state after execution:

`state = -1`

Pending route after completion:

`pending_route = 0`

Completion capacity record:

| Signal | Recorded value |
|---|---:|
| `accepted_changes` | `1` |

Pending-route completion result:

`PASS`

## M16 FPGA Integrated Invariant Validation

Terminal invariant vector:

`1111111111`

| Invariant | Result |
|---|---:|
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

## M16 FPGA Terminal Output Validation

Terminal markers:

`FRP M16 FPGA integration testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Terminal output result:

`PASS`

## M16 FPGA Repository-Integrity Validation

Isolated build directory:

`/tmp/frp_m16_fpga_obj`

Repository-local simulator directories after qualification:

`ABSENT`

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## M16 FPGA Qualification Evidence

The qualification artifact contains:

- Verilator and compiler toolchain record;

- FPGA and inherited RTL source hashes;

- FPGA top lint and elaboration log;

- FPGA testbench build log;

- FPGA execution log;

- qualification result record.

Qualification artifact count:

`1`

Qualification evidence result:

`PASS`

## M16 FPGA Final Qualification Table

| Qualification boundary | Result |
|---|---:|
| FPGA artifact inventory | `PASS` |
| qualified RTL dependency inventory | `PASS` |
| FPGA top parsing | `PASS` |
| FPGA top elaboration | `PASS` |
| FPGA testbench build | `PASS` |
| FPGA testbench execution | `PASS` |
| latch diagnostic rejection | `PASS` |
| multidriven diagnostic rejection | `PASS` |
| asynchronous reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| execution-input gating | `PASS` |
| scheduler propagation | `PASS` |
| request propagation | `PASS` |
| active-neutral routing | `PASS` |
| retained pending-route completion | `PASS` |
| transition-capacity correlation | `PASS` |
| all ten invariant flags | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |
| qualification evidence upload | `PASS` |

FPGA preparation qualification result:

`PASS`

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## M16 FPGA Preparation Qualification Records

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow run | `#1` |
| Qualified repository commit | `326b69e` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `1m 7s` |
| Qualification artifact count | `1` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |

## Release Benchmark Record Validation

Historical transition benchmark record:

`TEST_REPORT_v0_9_3.md`

Historical transition benchmark relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded representations:

- `15.69× lower heat_peak`;

- `93.63% lower heat_peak`.

Canonical architecture comparison result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical comparison-package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Hardware-sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Record-path validation:

`PASS`

Digest-record validation:

`PASS`

## Comparative Architecture Tick-Level Validation

| Architecture | Completion ticks | Mean latency ticks | Maximum latency ticks | Throughput commands per tick |
|---|---:|---:|---:|---:|
| `binary_synchronous_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `binary_clock_gated_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `direct_ternary_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `frp_v1_7_0_quantized_shadow` | `413` | `1.48828125` | `2` | `0.6198547215496368` |

Recorded semantic result for all four profiles:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

Tick-level record validation:

`PASS`

## FRP Arithmetic Event-Total Validation

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Event-total record validation:

`PASS`

## Candidate Invariant Validation

Validated inherited M15 invariants:

- `actual_direct_events = 0`;

- `reserved_state_events = 0`;

- `queue_overflow_events = 0`;

- `fixed_point_topology_sum_exact = True`;

- `fixed_point_thermal_sum_exact = True`.

Validated M16 RTL invariants:

- scheduler-count relation;

- request-lane ordering;

- retained pending polarity;

- active-neutral routing;

- transition-capacity enforcement;

- retained-state writeback;

- zero actual direct events;

- zero reserved-state events;

- zero queue-overflow events.

Validated M16 FPGA preparation relations:

- asynchronous reset assertion;

- two-stage synchronous reset release;

- `core_ready` generation;

- execution-input gating;

- scheduler propagation;

- request propagation;

- active-neutral first-leg execution;

- retained pending-route completion;

- ten integrated invariant flags.

Candidate invariant result:

`PASS`

## Validation Evidence Files

M15 qualification evidence:

- `TEST_REPORT_v1_7_0.md`;

- `FRP_VALIDATION_INDEX_v1_7_0.md`;

- `RELEASE_NOTES_v1_7_0.md`;

- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`.

M16 RTL qualification evidence:

- `rtl/m16/SIMULATION_TRANSCRIPT.md`;

- `rtl/m16/CLOSURE.md`;

- `docs/m16_rtl_artifact_boundary_qualification.md`;

- `docs/m16_qualification_manifest.md`;

- `docs/m16_qualification_index.md`.

M16 FPGA preparation evidence:

- `fpga/m16/SIMULATION_TRANSCRIPT.md`;

- `fpga/m16/CLOSURE.md`.

Foundation evidence:

- `docs/mathematical_foundation.md`;

- `docs/physical_foundation.md`.

Evidence-path validation:

`PASS`

## Final Result

Release:

`FRP v1.8.0`

Milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Inherited M15 qualification:

`41 / 41 PASS`

M16 RTL qualification:

`PASS`

M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

M16 FPGA preparation qualification:

`PASS`

M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

Final release qualification state:

`FRP v1.8.0 / M16 — PASS`

## Author

Maksym Marnov

Fractal Resonance Processor (FRP) Project

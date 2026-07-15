# FRP Validation Index v1.8.0

## M16 RTL Core Realization and Execution Semantics Package

## Validation Status

`PASS`

## Validated Release Layer

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## Main Executable Semantic Reference File

`frp_prototype_v1_7_0.py`

The M15-qualified Python executable remains the semantic reference inherited by M16.

## Stable Structured Schemas

Structured-output schema:

`frp.structured_output.v1.7.0`

Benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

M16 adds RTL execution and FPGA preparation layers without renaming the qualified M15 Python executable or schema identifiers.

## Validation Environment

`GitHub Actions`

Workflow runner:

`ubuntu-latest`

SystemVerilog toolchain:

`Verilator`

## Validation Index Role

This index records the FRP v1.8.0 validation and qualification evidence for:

- the inherited M15 semantic and implementation-mapping foundation;

- the M16 integrated SystemVerilog RTL core;

- temporal scheduler execution;

- request-lane arbitration;

- active-neutral transition routing;

- retained pending-route completion;

- distributed transition-capacity enforcement;

- retained-state writeback;

- SystemVerilog assertion execution;

- ten integrated invariant flags;

- the target-independent FPGA integration boundary;

- asynchronous reset assertion;

- two-stage synchronous reset release;

- `core_ready` generation;

- execution-input gating;

- M16 RTL qualification closure;

- M16 FPGA preparation qualification closure;

- historical and current benchmark evidence paths;

- release-facing evidence files.

## Validated Architecture Chain

`M14 floating semantic reference`

→ `M15 deterministic fixed-point interface`

→ `M15 stateful quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M15 SystemVerilog correlation contract`

→ `M15 qualification closure`

→ `M16 integrated SystemVerilog RTL execution`

→ `M16 architectural assertion qualification`

→ `M16 RTL execution closure`

→ `M16 target-independent FPGA integration`

→ `M16 reset synchronization and execution gating`

→ `M16 FPGA preparation qualification closure`

## Inherited M15 Validation Boundary

Inherited release:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited executable semantic reference:

`frp_prototype_v1_7_0.py`

Inherited workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Inherited evidence files:

- `RELEASE_NOTES_v1_7_0.md`;

- `TEST_REPORT_v1_7_0.md`;

- `FRP_VALIDATION_INDEX_v1_7_0.md`;

- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`.

## Inherited M15 Qualification Results

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

Inherited M15 validation status:

`PASS`

## Mathematical Foundation Evidence

Evidence file:

`docs/mathematical_foundation.md`

Indexed mathematical domains:

- balanced ternary retained-state domain;

- active neutral state `0`;

- tick-separated opposite-polarity routing;

- Kuramoto-Sakaguchi resonant phase dynamics;

- phase synchronization;

- phase coherence;

- endogenous structural coherence;

- processor-specific quantities `C_FRP(t)`, `P_FRP(t)`, and `Delta_FRP(t)`;

- thermal-state feedback;

- hierarchical and multiscale processor organization.

Evidence-path result:

`PASS`

## Physical Foundation Evidence

Evidence file:

`docs/physical_foundation.md`

Indexed physical implementation domains:

- retained balanced ternary state;

- active neutral state execution;

- transition-capacity distribution;

- endogenous thermal-state feedback;

- hardware-facing fixed-point representation;

- RTL realization;

- target-independent FPGA preparation.

Evidence-path result:

`PASS`

## Balanced Ternary Core Index

Validated retained-state domain:

`{-1, 0, 1}`

Validated states:

`-1`

`0`

`1`

Validated active neutral state:

`0`

Core-domain validation result:

`PASS`

## Canonical Hardware Encoding Index

| Ternary state | Encoding | Validation result |
|---|---|---:|
| `-1` | `2'b11` | `PASS` |
| `0` | `2'b00` | `PASS` |
| `1` | `2'b01` | `PASS` |
| reserved | `2'b10` | excluded |

Encoding domains:

- retained processor state;

- phase-derived target state;

- request target state;

- transition candidate state;

- retained pending-route polarity.

Reserved-state terminal record:

`reserved_state_events = 0`

Encoding validation result:

`PASS`

## Active-Neutral Route Index

Forbidden retained-state routes:

`-1 → 1`

`1 → -1`

Validated tick-separated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Indexed execution relation:

`tick N: retained polarity → active neutral state 0`

→ `requested opposite polarity retained in pending_route`

→ `tick N + 1 or later: 0 → retained pending polarity`

Direct-transition terminal record:

`actual_direct_events = 0`

Route validation result:

`PASS`

## Temporal Scheduler Index

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

Scheduler-count relation:

`sum(scheduler_counts) = ticks_recorded`

Counter clearing preserves retained state, pending routes, scheduler mode, and scheduler tick position.

Scheduler validation result:

`PASS`

## Free Scheduler Qualification Index

Recorded execution:

`16 ticks → free = 16`

Indexed execution cases:

- `0 → 1`;

- `1 → 0 → -1`;

- `-1 → 0 → 1`;

- two retained-state changes in one tick;

- scheduler counter clearing with retained state preserved.

Qualification result:

`PASS`

## 7/1 Scheduler Qualification Index

Repeating sequence:

`balance → balance → balance → balance → balance → balance → balance → commit`

Recorded scheduler counts:

`64 ticks → balance = 56, commit = 8`

Indexed execution cases:

- zero-to-polarity release on commit;

- opposite-polarity first leg during balance;

- pending polarity retention through balance;

- pending completion during commit.

Qualification result:

`PASS`

## 1/7 Scheduler Qualification Index

Repeating sequence:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

Recorded scheduler counts:

`16 ticks → excite = 2, neutralize = 14`

Indexed execution cases:

- zero-to-polarity release on excite;

- opposite-polarity first leg during neutralize;

- pending polarity retention through neutralize;

- pending completion during excite.

Qualification result:

`PASS`

## Transition-Class Index

Indexed transition classes:

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
| `0 → -1` or `0 → 1` | yes | no |
| `-1 → 0` or `1 → 0` | no | yes |
| opposite-polarity first leg to `0` | no | yes |
| pending completion from `0` | yes | no |

Transition-class validation result:

`PASS`

## Request-Lane Arbitration Index

Validated processing order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

Indexed request relations:

| Relation | Result |
|---|---:|
| canonical request-target validation | `PASS` |
| valid cell-index enforcement | `PASS` |
| one accepted request per cell per tick | `PASS` |
| earlier accepted-lane ownership | `PASS` |
| retained pending-route ownership priority | `PASS` |
| scheduler transition eligibility | `PASS` |
| acceptance and rejection separation | `PASS` |
| latch-free combinational arbitration | `PASS` |

Qualified parameter profile:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Request-lane validation result:

`PASS`

## Pending-Route State Index

Indexed pending-route relations:

| Relation | Result |
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

Queue terminal record:

`queue_overflow_events = 0`

Pending-route validation result:

`PASS`

## Distributed Transition-Capacity Index

Transition fraction:

`transition_fraction = 0.25`

Capacity relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Indexed cell profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Validated capacity relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

| Relation | Result |
|---|---:|
| bounded accepted changes | `PASS` |
| capacity-remaining relation | `PASS` |
| capacity-exhausted relation | `PASS` |
| switch-load relation | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has priority | `PASS` |
| explicit requests preserve lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

Transition-capacity validation result:

`PASS`

## Retained-State Writeback Index

Indexed writeback relations:

| Relation | Result |
|---|---:|
| reset initializes active neutral state | `PASS` |
| disabled ticks retain state | `PASS` |
| state-changing writeback requires capacity | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| opposite-polarity request commits the first leg only | `PASS` |
| pending completion commits from `0` | `PASS` |
| capacity rejection preserves retained state | `PASS` |
| reserved encoding is not committed | `PASS` |
| direct opposite-polarity writeback is absent | `PASS` |
| latch-free combinational writeback | `PASS` |

Retained-state writeback validation result:

`PASS`

## Integrated Invariant Index

The M16 RTL core exposes ten integrated invariant flags:

1. `FRP_INV_STATE_DOMAIN_VALID`;
2. `FRP_INV_SCHEDULER_COUNTS_VALID`;
3. `FRP_INV_REQUEST_LANE_ORDER_VALID`;
4. `FRP_INV_PENDING_POLARITY_VALID`;
5. `FRP_INV_ACTIVE_NEUTRAL_VALID`;
6. `FRP_INV_TRANSITION_CAPACITY_VALID`;
7. `FRP_INV_STATE_UPDATE_VALID`;
8. `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
9. `FRP_INV_NO_RESERVED_STATE`;
10. `FRP_INV_NO_QUEUE_OVERFLOW`.

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

Integrated invariant validation result:

`PASS`

## M16 RTL Artifact Index

RTL directory:

`rtl/m16/`

| SystemVerilog artifact | Indexed function |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | canonical encodings, scheduler types, transition classes, invariant indexes, capacity parameters, and shared functions |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-route creation, ownership, deferral, completion, and clearing |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition-candidate generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `rtl/m16/frp_m16_state_update.sv` | capacity-approved retained-state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL execution and synthesis boundary |
| `rtl/m16/frp_m16_assertions.sv` | temporal, domain, routing, capacity, and writeback assertions |
| `rtl/m16/frp_m16_tb.sv` | deterministic executable architectural testbench |

SystemVerilog artifact count:

`10`

Artifact-index result:

`PASS`

## M16 RTL Documentation Index

| Documentation artifact | Indexed function |
|---|---|
| `rtl/m16/README.md` | M16 RTL architecture and execution semantics |
| `rtl/m16/ARTIFACTS.md` | RTL artifact manifest |
| `rtl/m16/SIMULATION.md` | simulator build and execution procedure |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | executable RTL qualification record |
| `rtl/m16/CLOSURE.md` | M16 RTL closure record |

RTL documentation count:

`5`

Documentation-index result:

`PASS`

## M16 RTL Build and Execution Index

Top-level testbench:

`frp_m16_tb`

Top-level synthesis boundary:

`frp_m16_core`

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
| architectural simulation | `PASS` |
| assertion execution | `PASS` |

## M16 RTL Assertion Index

Indexed assertion domains:

- retained-state domain;

- pending-route domain;

- reset state;

- disabled-tick retained-state stability;

- disabled-tick pending-route stability;

- state-change authorization;

- direct opposite-polarity exclusion;

- active-neutral first-leg execution;

- exact pending-polarity retention;

- pending-route deferral;

- completion only from active neutral state `0`;

- scheduler mode and state;

- scheduler-state counters;

- request acceptance and rejection separation;

- transition-capacity relations;

- retained-state writeback;

- integrated invariant flags;

- assertion message syntax.

Assertion validation result:

`PASS`

## M16 RTL Terminal Record Index

Terminal markers:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

| Terminal value | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal-record result:

`PASS`

## M16 RTL Qualification Workflow Index

Workflow name:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow trigger:

`workflow_dispatch`

Indexed qualification domains:

- exact artifact inventory;

- exact documentation inventory;

- Verilator parsing;

- module elaboration;

- executable testbench generation;

- architectural simulation;

- assertion execution;

- latch-diagnostic rejection;

- multidriven-diagnostic rejection;

- scheduler validation;

- request-lane arbitration;

- active-neutral routing;

- pending-route completion;

- transition-capacity enforcement;

- retained-state writeback;

- ten invariant flags;

- terminal marker validation;

- repository-integrity validation;

- qualification evidence generation.

## M16 RTL Qualification Record Index

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

RTL qualification record result:

`PASS`

## M16 FPGA Preparation Artifact Index

FPGA preparation directory:

`fpga/m16/`

| FPGA artifact | Indexed function |
|---|---|
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation simulation and qualification record |
| `fpga/m16/CLOSURE.md` | FPGA preparation closure record |

FPGA SystemVerilog artifact count:

`2`

FPGA documentation artifact count:

`2`

Artifact-index result:

`PASS`

## M16 FPGA RTL Dependency Index

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

Inherited RTL dependency count:

`9`

Dependency-index result:

`PASS`

## M16 FPGA Integration-Top Index

Top-level module:

`frp_m16_fpga_top`

Instantiated core:

`frp_m16_core`

Indexed interface domains:

- FPGA clock input;

- asynchronous external reset input;

- tick-enable input;

- counter-clear input;

- scheduler-mode input;

- request-valid lanes;

- request cell indexes;

- balanced ternary request targets;

- phase-derived target bank;

- retained balanced ternary state bank;

- retained pending-route bank;

- scheduler state and counters;

- request acceptance and rejection;

- transition-capacity telemetry;

- switching-load telemetry;

- direct-transition telemetry;

- reserved-state telemetry;

- queue-overflow telemetry;

- ten integrated invariant flags.

Integration-top elaboration result:

`PASS`

## M16 FPGA Build and Execution Index

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
| latch-diagnostic rejection | `PASS` |
| multidriven-diagnostic rejection | `PASS` |

## M16 FPGA Reset-Synchronization Index

External reset:

`rst_n_async`

Internal core reset:

`rst_n_core`

Indexed reset sequence:

1. external reset asserts asynchronously;
2. the synchronization register clears;
3. the first release edge remains blocked;
4. the second release edge activates `rst_n_core` and `core_ready`.

| Reset relation | Result |
|---|---:|
| asynchronous external reset assertion | `PASS` |
| synchronization register clear | `PASS` |
| first release edge remains blocked | `PASS` |
| second release edge activates `core_ready` | `PASS` |
| retained state remains `0` during reset | `PASS` |
| pending-route bank remains `0` during reset | `PASS` |
| scheduler counters remain `0` during reset | `PASS` |

Reset-synchronization result:

`PASS`

## M16 FPGA Core-Ready and Input-Gating Index

Readiness relation:

`core_ready = rst_n_core`

Input-gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

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

## M16 FPGA Scheduler-Propagation Index

Indexed modes:

- `free`;

- `7/1`;

- `1/7`.

Indexed scheduler states:

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

## M16 FPGA Request-Propagation Index

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

## M16 FPGA Active-Neutral Route Index

Requested transition:

`1 → -1`

Executed route:

`1 → 0 → -1`

Retained pending polarity:

`pending_route = -1`

| Event | Recorded value |
|---|---:|
| `requested_direct_events` | `1` |
| `prevented_direct_events` | `1` |
| `neutral_routed_events` | `1` |
| `actual_direct_events` | `0` |

| Route relation | Result |
|---|---:|
| opposite-polarity request detected | `PASS` |
| direct transition prevented | `PASS` |
| active-neutral first leg executed | `PASS` |
| exact requested polarity retained | `PASS` |
| pending completion executed from `0` | `PASS` |
| pending route cleared after completion | `PASS` |
| direct retained-state transition absent | `PASS` |

Active-neutral route result:

`PASS`

## M16 FPGA Pending-Route Completion Index

State before completion:

`state = 0`

Retained route before completion:

`pending_route = -1`

State after completion:

`state = -1`

Pending route after completion:

`pending_route = 0`

Accepted completion changes:

`accepted_changes = 1`

Pending-route completion result:

`PASS`

## M16 FPGA Integrated Invariant Index

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

Invariant-index result:

`PASS`

## M16 FPGA Terminal Record Index

Terminal markers:

`FRP M16 FPGA integration testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

| Terminal value | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Terminal-record result:

`PASS`

## M16 FPGA Preparation Workflow Index

Workflow name:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

Workflow trigger:

`workflow_dispatch`

Indexed qualification domains:

- exact FPGA artifact inventory;

- exact inherited M16 RTL dependency inventory;

- FPGA top parsing;

- FPGA top elaboration;

- executable FPGA testbench generation;

- FPGA testbench execution;

- latch-diagnostic rejection;

- multidriven-diagnostic rejection;

- asynchronous reset assertion;

- two-stage synchronous reset release;

- `core_ready` generation;

- execution-input gating;

- scheduler propagation;

- request propagation;

- active-neutral routing;

- retained pending-route completion;

- transition-capacity correlation;

- ten invariant flags;

- terminal marker validation;

- repository-integrity validation;

- qualification evidence generation.

## M16 FPGA Preparation Qualification Record Index

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow run | `#1` |
| Qualified repository commit | `326b69e` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `1m 7s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

FPGA preparation qualification record result:

`PASS`

## M16 Public Architecture Document Index

| Document | Indexed domain |
|---|---|
| `docs/m16_rtl_core_realization_execution_semantics.md` | M16 RTL execution layer |
| `docs/m16_scheduler_state_rtl_realization.md` | scheduler state realization |
| `docs/m16_request_lane_arbitration_module.md` | request-lane arbitration |
| `docs/m16_pending_route_register_module.md` | pending-route registers |
| `docs/m16_active_neutral_transition_module.md` | active-neutral transition execution |
| `docs/m16_transition_capacity_guard_module.md` | transition-capacity guard |
| `docs/m16_retained_state_update_module.md` | retained-state update |
| `docs/m16_rtl_core_interface_contract.md` | RTL core interface contract |
| `docs/m16_balanced_ternary_state_register_map.md` | balanced ternary state register map |
| `docs/m16_invariant_assertion_set.md` | invariant assertion set |
| `docs/m16_external_simulator_execution_plan.md` | external simulator execution plan |
| `docs/m16_rtl_artifact_boundary_qualification.md` | RTL artifact-boundary qualification |
| `docs/m16_artifact_boundary_test_stability_policy.md` | artifact-boundary test stability policy |
| `docs/m16_m15_vector_replay_compatibility_report.md` | M15 vector replay compatibility |
| `docs/m16_qualification_manifest.md` | M16 qualification manifest |
| `docs/m16_qualification_index.md` | M16 qualification index |
| `docs/m16_public_status_snapshot.md` | M16 public status snapshot |

Public M16 document count:

`17`

Document-index result:

`PASS`

## M16 Workflow File Index

| Workflow file | Workflow name | Indexed role |
|---|---|---|
| `.github/workflows/frp-m16-rtl-artifact-boundary.yml` | `FRP M16 RTL Artifact Boundary` | RTL execution qualification |
| `.github/workflows/frp-m16-fpga-preparation.yml` | `FRP M16 FPGA Preparation` | FPGA preparation qualification |
| `.github/workflows/frp-m16-canonical-core-domain.yml` | `FRP M16 Canonical Core Domain` | canonical M16 core-domain notation |
| `.github/workflows/frp-m16-reserved-cell-cleanup.yml` | `FRP M16 Reserved Cell Cleanup` | reserved-cell identifier cleanup |

Workflow-file index result:

`PASS`

## Historical Benchmark Evidence Index

Indexed benchmark and qualification contours:

- FRP v0.9.3 transition execution;

- FRP v0.9.4 text and structured JSON output;

- FRP v0.9.5 through FRP v1.3.0 M3 benchmark matrices;

- FRP v1.4.0 transition-pressure and feedback-stress execution;

- FRP v1.5.0 thermal-survival and stability-boundary execution;

- FRP v1.6.0 hierarchical scaling, acceleration, and hotspot-containment execution;

- FRP v1.7.0 M15 implementation-mapping execution;

- Comparative Architecture Benchmark Suite;

- Hardware-Informed Sensitivity Qualification;

- M16 RTL execution qualification;

- M16 FPGA preparation qualification.

## FRP v0.9.3 Transition Benchmark Index

Evidence file:

`TEST_REPORT_v0_9_3.md`

| Architecture | `heat_peak` | `switch_load_peak` | `actual_direct_events` |
|---|---:|---:|---:|
| `binary_style_forced_switch` | `0.051000` | `1.000000` | `2052` |
| `direct_ternary_commit` | `0.051000` | `1.000000` | `2052` |
| `distributed_neutral_ternary` | `0.003250` | `0.250000` | `0` |
| `frp_distributed_resonant` | `0.107000` | `0.250000` | `0` |

Recorded relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded numerical representations:

- `15.69× lower heat_peak`;

- `93.63% lower heat_peak`.

Measurement contour:

`FRP v0.9.3 transition benchmark model and defined workload`

Evidence-index result:

`PASS`

## FRP v0.9.4 Structured Benchmark Index

Executable:

`frp_prototype_v0_9_4.py`

Schema:

`frp.structured_output.v0.9.4`

Output formats:

- text;

- structured JSON.

Evidence-index result:

`PASS`

## M3 Benchmark Matrix Index

Indexed schemas:

- `frp.m3.benchmark_matrix.v0.9.5`;

- `frp.m3.benchmark_matrix.v0.9.6`;

- `frp.m3.benchmark_matrix.v0.9.7`;

- `frp.m3.benchmark_matrix.v0.9.8`;

- `frp.m3.benchmark_matrix.v0.9.9`;

- `frp.m3.benchmark_matrix.v1.0.0`;

- `frp.m3.benchmark_matrix.v1.1.0`;

- `frp.m3.benchmark_matrix.v1.2.0`;

- `frp.m3.benchmark_matrix.v1.3.0`;

- `frp.m3.benchmark_matrix.v1.4.0`;

- `frp.m3.benchmark_matrix.v1.5.0`;

- `frp.m3.benchmark_matrix.v1.6.0`;

- `frp.m3.benchmark_matrix.v1.7.0`.

## M15 Benchmark Matrix Index

Executable:

`frp_prototype_v1_7_0.py`

Schema:

`frp.m3.benchmark_matrix.v1.7.0`

Indexed rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Evidence-index result:

`PASS`

## Comparative Architecture Benchmark Index

Benchmark directory:

`benchmarks/architecture_comparison/`

Schema:

`frp.benchmark.architecture_comparison.v1`

Architecture order:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical comparison-package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Integrity status:

`PASS`

Qualification status:

`PASS`

## Comparative Architecture Tick-Level Index

| Architecture | Completion ticks | Mean latency ticks | Maximum latency ticks | Throughput commands per tick |
|---|---:|---:|---:|---:|
| `binary_synchronous_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `binary_clock_gated_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `direct_ternary_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `frp_v1_7_0_quantized_shadow` | `413` | `1.48828125` | `2` | `0.6198547215496368` |

Recorded semantic results for all four profiles:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

Tick-level evidence-index result:

`PASS`

## Canonical FRP Workload Index

| Metric | Recorded value |
|---|---:|
| `semantic_completion_ratio` | `1.0` |
| `semantic_output_match` | `1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `pending_route_count_final` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |
| `global_phase_coherence_final` | `0.9999997103586793` |
| `C_minus_P_min` | `0.856201171875` |
| `C_minus_P_final` | `1.2415313720703125` |

Workload evidence-index result:

`PASS`

## FRP Arithmetic Event-Total Index

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Event-total evidence-index result:

`PASS`

## Hardware-Informed Sensitivity Index

Schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Indexed scenarios:

- `lower_bound`;

- `nominal`;

- `upper_bound`.

Recorded stability fields:

`ranking_stable = true`

`ranking_sensitive = false`

Ranking basis:

`ascending_total_normalized_energy`

Recorded ranking:

`binary_clock_gated_reference`

→ `direct_ternary_reference`

→ `binary_synchronous_reference`

→ `frp_v1_7_0_quantized_shadow`

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Profile qualification status:

`PASS`

Comparison qualification status:

`PASS`

## Qualification Evidence Path Index

| Qualification domain | Primary evidence paths |
|---|---|
| M15 semantic and implementation mapping | `TEST_REPORT_v1_7_0.md`, `FRP_VALIDATION_INDEX_v1_7_0.md`, `RELEASE_NOTES_v1_7_0.md` |
| M15 architecture closure | `docs/m15_implementation_mapping_domain_interface_qualification_closure.md` |
| mathematical foundation | `docs/mathematical_foundation.md` |
| physical foundation | `docs/physical_foundation.md` |
| M16 RTL architecture | `rtl/m16/README.md`, `rtl/m16/ARTIFACTS.md` |
| M16 RTL simulation | `rtl/m16/SIMULATION.md`, `rtl/m16/SIMULATION_TRANSCRIPT.md` |
| M16 RTL closure | `rtl/m16/CLOSURE.md` |
| M16 RTL public qualification | `docs/m16_rtl_artifact_boundary_qualification.md`, `docs/m16_qualification_manifest.md`, `docs/m16_qualification_index.md` |
| M16 FPGA simulation | `fpga/m16/SIMULATION_TRANSCRIPT.md` |
| M16 FPGA closure | `fpga/m16/CLOSURE.md` |
| comparative architecture benchmark | `benchmarks/architecture_comparison/results/reference_comparison_seed_76.json` |
| hardware sensitivity | `benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json` |

Evidence-path index result:

`PASS`

## Release-Facing File Index

Updated release-facing files:

- `README.md`;

- `CI.md`;

- `CHANGELOG.md`;

- `CITATION.cff`.

FRP v1.8.0 release evidence files:

- `RELEASE_NOTES_v1_8_0.md`;

- `TEST_REPORT_v1_8_0.md`;

- `FRP_VALIDATION_INDEX_v1_8_0.md`.

Release architecture image:

`docs/frp_v1_8_0_m16_architecture-1.gif`

Inherited M15 release evidence files:

- `RELEASE_NOTES_v1_7_0.md`;

- `TEST_REPORT_v1_7_0.md`;

- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## Candidate Invariant Index

Inherited M15 invariant records:

- `actual_direct_events = 0`;

- `reserved_state_events = 0`;

- `queue_overflow_events = 0`;

- `fixed_point_topology_sum_exact = True`;

- `fixed_point_thermal_sum_exact = True`.

M16 RTL invariant records:

- scheduler counts correspond to executed ticks;

- request-lane ordering remains deterministic;

- pending polarity remains retained through deferral;

- opposite-polarity routes execute through active neutral state `0`;

- committed state changes remain within transition capacity;

- retained-state writeback matches admitted transitions;

- all ten integrated invariant flags equal `1`;

- `actual_direct_events = 0`;

- `reserved_state_events = 0`;

- `queue_overflow_events = 0`.

M16 FPGA preparation invariant records:

- asynchronous reset assertion passes;

- two-stage synchronous reset release passes;

- `core_ready = 1` after reset release;

- execution inputs remain gated before readiness;

- scheduler modes propagate through the FPGA boundary;

- requests propagate through the FPGA boundary;

- active-neutral first-leg execution passes;

- retained pending-route completion passes;

- all ten integrated invariant flags equal `1`;

- `actual_direct_events = 0`;

- `reserved_state_events = 0`;

- `queue_overflow_events = 0`.

Candidate invariant index result:

`PASS`

## Validation Summary Index

| Validation layer | Result |
|---|---:|
| inherited M15 semantic qualification | `41 / 41 PASS` |
| inherited M15 deterministic vector regeneration | `10 / 10 byte-identical` |
| inherited M15 semantic correlation | `5 / 5 = 1.0` |
| inherited M15 deterministic replay | `6 / 6 = 1.0` |
| mathematical foundation evidence | `PASS` |
| physical foundation evidence | `PASS` |
| M16 RTL artifact inventory | `PASS` |
| M16 RTL documentation inventory | `PASS` |
| M16 RTL parsing and elaboration | `PASS` |
| M16 RTL executable testbench | `PASS` |
| M16 RTL assertion execution | `PASS` |
| M16 scheduler qualification | `PASS` |
| M16 request-lane arbitration | `PASS` |
| M16 active-neutral routing | `PASS` |
| M16 pending-route completion | `PASS` |
| M16 transition-capacity enforcement | `PASS` |
| M16 retained-state writeback | `PASS` |
| M16 ten-invariant vector | `PASS` |
| M16 RTL repository integrity | `PASS` |
| M16 RTL qualification evidence | `PASS` |
| M16 FPGA artifact inventory | `PASS` |
| M16 FPGA inherited RTL dependency inventory | `PASS` |
| M16 FPGA top parsing and elaboration | `PASS` |
| M16 FPGA executable testbench | `PASS` |
| M16 FPGA asynchronous reset assertion | `PASS` |
| M16 FPGA two-stage reset release | `PASS` |
| M16 FPGA `core_ready` generation | `PASS` |
| M16 FPGA execution-input gating | `PASS` |
| M16 FPGA scheduler propagation | `PASS` |
| M16 FPGA request propagation | `PASS` |
| M16 FPGA active-neutral routing | `PASS` |
| M16 FPGA pending-route completion | `PASS` |
| M16 FPGA ten-invariant vector | `PASS` |
| M16 FPGA repository integrity | `PASS` |
| M16 FPGA qualification evidence | `PASS` |
| comparative architecture benchmark integrity | `PASS` |
| hardware-sensitivity profile qualification | `PASS` |
| hardware-sensitivity comparison qualification | `PASS` |

## Final Validation Result

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

Final validation state:

`FRP v1.8.0 / M16 — PASS`

## Author

Maksym Marnov

Fractal Resonance Processor (FRP) Project



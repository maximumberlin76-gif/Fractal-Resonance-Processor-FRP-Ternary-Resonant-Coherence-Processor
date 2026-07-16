# FRP M16 RTL Core Realization and Execution Semantics Package

## Status

`Current RTL execution and FPGA preparation layer`

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## M16 Position

M16 begins after the qualified M15 semantic and implementation-mapping boundary.

M15 established:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

Qualified M15 result:

`41 / 41 PASS`

M16 realizes the M15-qualified retained-state execution contract as an executable SystemVerilog RTL core and target-independent FPGA preparation boundary.

M15 remains the qualified semantic and implementation-mapping foundation of M16.

## Executable Semantic Reference Boundary

The qualified Python executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The qualified structured-output schema remains:

`frp.structured_output.v1.7.0`

The qualified benchmark-matrix schema remains:

`frp.m3.benchmark_matrix.v1.7.0`

M16 does not introduce or rename the Python executable semantic reference.

M16 does not create a new semantic processor model.

The M16 RTL layer realizes the qualified M15 execution contract in SystemVerilog form.

## Processor Identity Preserved by M16

FRP remains a:

`Ternary Fractal Resonant Coherence Processor`

The computational architecture remains:

`Kuramoto-Sakaguchi resonant phase dynamics`

→ `hierarchical fractal coupling`

→ `multiscale phase coherence`

→ `stateful delay dynamics`

→ `distributed local thermal fields`

→ `local correlated gamma drift`

→ `nonlinear coherence compression`

→ `dynamic stability C(t) - P(t)`

→ `phase-derived ternary target`

→ `distributed ternary commit`

→ `mandatory tick-separated routing through active neutral state 0`

→ `retained coherent ternary state`

M16 does not replace this architecture with a conventional ternary finite-state machine.

The M16 SystemVerilog boundary realizes the qualified retained-state execution semantics of this architecture.

## Mathematical and Physical Foundation

FRP mathematical foundation:

`docs/mathematical_foundation.md`

FRP physical foundation:

`docs/physical_foundation.md`

The mathematical foundation records:

- balanced ternary retained state;
- active-neutral transition routing;
- Kuramoto-Sakaguchi resonant phase dynamics;
- phase synchronization and phase coherence;
- endogenous structural coherence;
- operational quantities `C_FRP(t)`, `P_FRP(t)`, and `Delta_FRP(t)`;
- thermal-state feedback;
- hierarchical and multiscale processor organization.

The physical foundation records:

- retained balanced ternary state;
- active neutral state execution;
- transition-capacity distribution;
- endogenous thermal-state feedback;
- hardware-facing fixed-point representation;
- RTL realization;
- target-independent FPGA preparation.

## Realized M16 Scope

The executable M16 RTL boundary realizes:

- retained balanced ternary state registers;
- canonical two-bit ternary encoding;
- scheduler execution modes;
- deterministic request-lane arbitration;
- retained pending routes;
- active-neutral routing;
- transition-capacity enforcement;
- retained-state writeback;
- scheduler and architectural counters;
- direct-transition telemetry;
- reserved-state telemetry;
- queue-overflow telemetry;
- deterministic tick execution;
- architectural and temporal assertions;
- ten integrated invariant flags;
- deterministic executable RTL testbench;
- RTL qualification evidence.

The M16 FPGA preparation boundary realizes:

- target-independent FPGA integration top;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick, counter-clear, and request-valid gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- transition-capacity correlation;
- retained-state writeback;
- integrated invariant propagation;
- FPGA preparation qualification evidence.

The inherited M15 interface mapping retains the hardware-facing domains for:

- phase words;
- frequency state;
- fixed-point coupling inputs;
- thermal state;
- gamma state;
- coherence telemetry;
- stability telemetry.

## M16 SystemVerilog Artifact Boundary

The qualified RTL source boundary is:

`rtl/m16/`

Qualified SystemVerilog artifacts:

| File | Function |
|---|---|
| `frp_m16_pkg.sv` | constants, encodings, types, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-route management |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `frp_m16_assertions.sv` | architectural and temporal assertion layer |
| `frp_m16_tb.sv` | deterministic executable architectural testbench |

Qualified RTL documentation:

| File | Function |
|---|---|
| `rtl/m16/README.md` | RTL architecture and execution semantics |
| `rtl/m16/ARTIFACTS.md` | RTL artifact manifest |
| `rtl/m16/SIMULATION.md` | Verilator build and execution procedure |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | executable RTL qualification record |
| `rtl/m16/CLOSURE.md` | M16 RTL closure record |

Qualified RTL boundary:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

## Explicit Execution Modes

M16 preserves the three temporal execution modes:

- `free`;
- `7/1`;
- `1/7`.

These are processor execution semantics.

They are not external benchmark labels.

The scheduler counter relation is:

`sum(scheduler_counts) = ticks_recorded`

Counter clearing preserves:

- retained ternary state;
- retained pending routes;
- scheduler mode;
- scheduler tick position.

### Free Mode

Every enabled tick is:

`free`

The `free` scheduler state is commit-capable and neutralize-capable.

Recorded profile:

`16 ticks → free = 16`

### 7/1 Mode

The repeating sequence is:

`balance → balance → balance → balance → balance → balance → balance → commit`

Recorded profiles:

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

### 1/7 Mode

The repeating sequence is:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

Recorded profile:

`16 ticks → excite = 2, neutralize = 14`

## Balanced Ternary Encoding

M16 preserves the canonical M15 hardware encoding:

| Ternary state | RTL encoding | Integer encoding |
|---|---|---:|
| `-1` | `2'b11` | `3` |
| `0` | `2'b00` | `0` |
| `1` | `2'b01` | `1` |
| reserved | `2'b10` | `2` |

The active neutral state is:

`0`

The reserved state is invalid.

Qualified invariant:

`reserved_state_events = 0`

## Active-Neutral Routing

Opposite-polarity transitions pass through active neutral state `0`.

Qualified routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity retained-state transitions are forbidden:

`-1 → 1`

`1 → -1`

Qualified invariant:

`actual_direct_events = 0`

## Pending-Route Semantics

For an opposite-polarity request:

`state_i × target_i = -1`

the first eligible neutralization tick executes:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick executes:

`0 → pending_route_i`

Each retained cell contains one pending-route slot.

A retained pending route:

- owns its cell until completion;
- has priority over a new request for the same cell;
- retains its exact polarity across scheduler-ineligible ticks;
- retains its exact polarity across transition-capacity deferral;
- completes only from retained state `0`;
- clears only after the corresponding state writeback;
- cannot be overwritten by another route.

Qualified queue record:

`queue_overflow_events = 0`

## Transition Capacity

M16 preserves the M15 transition boundary:

`transition_fraction = 0.25`

The maximum accepted state changes per tick are:

`max_changes = max(1, round(CELLS × transition_fraction))`

The hardware-facing request-lane relation is:

`REQUEST_LANES = max_changes`

Qualified configurations:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Capacity is consumed by an actual retained-state change.

Same-state retention consumes no transition capacity.

The two legs of an opposite-polarity route consume capacity on separate eligible ticks.

Capacity order:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit request lanes in ascending lane order.

Qualified relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

`switch_load = switch_load_numerator / CELLS`

## Request-Lane Arbitration

The request-lane boundary receives:

- request-valid bits;
- cell indexes;
- balanced ternary targets;
- retained cell state;
- retained pending-route state;
- scheduler state.

Request lanes are processed in ascending lane order.

For each enabled tick:

1. invalid cell indexes are rejected;
2. reserved target encodings are rejected;
3. an earlier accepted lane owns its cell for the tick;
4. a retained pending route owns its cell;
5. scheduler-ineligible transitions are rejected;
6. eligible lanes become transition candidates.

One cell receives at most one explicit request acceptance per tick.

Qualified request profile:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

## RTL Core Interface Boundary

Top-level RTL module:

`frp_m16_core`

The integrated core exposes:

- clock;
- active-low reset;
- tick enable;
- counter clear;
- scheduler mode;
- request-valid lanes;
- request cell indexes;
- request targets;
- phase-derived target bank;
- retained-state output bank;
- retained pending-route output bank;
- registered scheduler mode and state;
- scheduler counters;
- request acceptance and rejection;
- accepted-cell mask;
- neutral-routed-cell mask;
- accepted-change mask;
- transition-capacity telemetry;
- switching-load telemetry;
- direct-transition telemetry;
- reserved-state telemetry;
- queue-overflow telemetry;
- ten integrated invariant flags.

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

## Retained-State Writeback

Retained-state writeback commits only capacity-approved transition candidates.

The writeback boundary records:

- retained balanced ternary state;
- retained pending-route state;
- accepted-cell mask;
- neutral-routed-cell mask;
- accepted-change mask;
- accepted-change count;
- transition-capacity telemetry;
- switching-load telemetry;
- direct-transition telemetry;
- reserved-state telemetry;
- queue-overflow telemetry.

## Integrated Invariant Boundary

The integrated M16 core exposes ten invariant flags:

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

Qualified terminal invariant vector:

`1111111111`

Qualified terminal event values:

| Event | Value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

## SystemVerilog Assertion Boundary

The assertion layer checks:

- canonical ternary state and pending-route encodings;
- reset to active neutral state `0`;
- retained-state and pending-route stability while ticks are disabled;
- state changes only through accepted-change masks;
- absence of direct opposite-polarity retained-state writeback;
- first-leg routing through active neutral state `0`;
- retention of the exact requested pending polarity;
- completion only from active neutral state `0`;
- pending-route stability during scheduler and capacity deferral;
- scheduler mode, scheduler state, and counter relations;
- request acceptance and rejection separation;
- transition-capacity and switch-load relations;
- zero direct, reserved-state, and queue-overflow events;
- all ten integrated invariant flags.

## M15-to-M16 Qualification Correlation

The M16 realization preserves correlation with:

- the M15 stateful quantized hardware shadow;
- the M15 cycle-exact integer golden trace;
- the M15 deterministic RTL comparison-vector package;
- the M15 SystemVerilog testbench interface map;
- the M15 assertion-correlation harness;
- the M15 reference RTL equivalence report.

M16 retains the qualified M15 semantic reference:

`frp_prototype_v1_7_0.py`

M16 realizes the retained-state execution contract in RTL core form.

## M16 Qualification Documents

| Document | Record |
|---|---|
| `docs/m16_rtl_core_interface_contract.md` | RTL core interface contract |
| `docs/m16_balanced_ternary_state_register_map.md` | balanced ternary state-register map |
| `docs/m16_scheduler_state_rtl_realization.md` | scheduler-state RTL realization |
| `docs/m16_request_lane_arbitration_module.md` | request-lane arbitration module |
| `docs/m16_pending_route_register_module.md` | pending-route register module |
| `docs/m16_active_neutral_transition_module.md` | active-neutral transition module |
| `docs/m16_transition_capacity_guard_module.md` | transition-capacity guard module |
| `docs/m16_retained_state_update_module.md` | retained-state update module |
| `docs/m16_invariant_assertion_set.md` | invariant assertion set |
| `docs/m16_m15_vector_replay_compatibility_report.md` | M15 vector replay compatibility record |
| `docs/m16_rtl_artifact_boundary_qualification.md` | RTL artifact-boundary qualification record |
| `docs/m16_qualification_manifest.md` | M16 qualification manifest |
| `docs/m16_qualification_index.md` | M16 qualification index |
| `docs/m16_artifact_boundary_test_stability_policy.md` | artifact-boundary test stability policy |
| `docs/m16_external_simulator_execution_plan.md` | external simulator execution-plan record |
| `docs/m16_public_status_snapshot.md` | public-status snapshot record |

## M16 RTL Qualification Scope

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

The workflow qualifies:

- exact M16 RTL artifact inventory;
- exact M16 RTL documentation inventory;
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
- all ten invariant flags;
- terminal zero-event validation;
- repository-integrity validation;
- qualification artifact generation.

## M16 RTL Qualification Records

| Qualification record | Workflow run | Qualified commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---|---:|---|
| Initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | — | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| Qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `52s` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

Qualified RTL terminal records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

## M16 FPGA Preparation Boundary

FPGA preparation directory:

`fpga/m16/`

The closed FPGA preparation boundary contains:

`2 SystemVerilog artifacts + 2 documentation artifacts`

Qualified artifacts:

| File | Function |
|---|---|
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation qualification record |
| `fpga/m16/CLOSURE.md` | FPGA preparation closure record |

Top-level integration module:

`frp_m16_fpga_top`

Instantiated execution core:

`frp_m16_core`

External reset input:

`rst_n_async`

Internal core reset:

`rst_n_core`

Qualified reset sequence:

1. external reset asserts asynchronously;
2. the synchronization register clears;
3. the first release edge remains blocked;
4. the second release edge activates `rst_n_core`;
5. `core_ready` becomes active.

Readiness relation:

`core_ready = rst_n_core`

Input-gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

## M16 FPGA Preparation Qualification Records

| Qualification record | Workflow run | Qualified commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---|---:|---|
| Initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1m 7s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| Qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `36s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

Qualified FPGA preparation terminal records:

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

## Current Release Records

Current test report:

`TEST_REPORT_v1_8_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`RELEASE_NOTES_v1_8_0.md`

Inherited M15 architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

## Current M16 Closure State

Current release:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Python executable semantic reference:

`frp_prototype_v1_7_0.py`

Inherited M15 qualification result:

`41 / 41 PASS`

Current M16 RTL result:

`PASS`

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation result:

`PASS`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

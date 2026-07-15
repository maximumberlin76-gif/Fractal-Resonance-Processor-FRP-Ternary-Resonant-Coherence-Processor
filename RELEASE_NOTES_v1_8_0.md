# Fractal Resonance Processor (FRP) v1.8.0

## M16 RTL Core Realization and Execution Semantics Package

FRP v1.8.0 establishes the M16 RTL Core Realization and Execution Semantics Package of the Ternary Fractal Resonant Coherence Processor architecture.

M16 realizes the M15-qualified semantic and implementation-mapping boundary as:

`M15 floating semantic reference`

→ `M15 stateful quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 executable SystemVerilog RTL core`

→ `M16 target-independent FPGA integration boundary`

→ `M16 RTL and FPGA preparation qualification closure`

M15 remains the qualified semantic and implementation-mapping foundation of M16.

M16 is the current RTL execution and FPGA preparation layer.

## Main Executable Semantic Reference File

`frp_prototype_v1_7_0.py`

The executable semantic reference remains attached to the M15-qualified Python layer.

M16 does not introduce or rename the Python executable semantic reference.

## Release Role

FRP v1.8.0 contains:

- the M15-qualified executable semantic reference;

- the M15 deterministic implementation-mapping foundation;

- an integrated ten-file SystemVerilog RTL execution boundary;

- executable temporal scheduler semantics;

- deterministic request-lane arbitration;

- retained pending-route execution;

- active-neutral opposite-polarity routing;

- distributed transition-capacity enforcement;

- retained balanced ternary state writeback;

- integrated architectural assertions;

- ten integrated invariant flags;

- an executable architectural RTL testbench;

- a target-independent FPGA integration top;

- an executable FPGA integration testbench;

- asynchronous external reset assertion;

- two-stage synchronous reset release;

- `core_ready` execution gating;

- RTL and FPGA preparation qualification evidence.

Binary hardware can model nonlinear dynamics; FRP transfers selected nonlinear dynamic mechanisms into the organization of computation itself.

## Inherited M15 Qualification Foundation

Inherited release:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

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

The inherited M15 execution chain is:

`M14 floating semantic reference`

→ `M15 deterministic fixed-point interface`

→ `stateful quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog correlation contract`

→ `synthesizable RTL reference-core mapping`

→ `RTL assertion correlation`

→ `reference RTL equivalence`

→ `exact deterministic replay`

→ `M15 qualification closure`

## Mathematical Foundation

FRP mathematical foundation:

`docs/mathematical_foundation.md`

The document records the processor-specific mathematical relations for:

- balanced ternary retained state;

- active neutral transition routing;

- Kuramoto-Sakaguchi resonant phase dynamics;

- phase synchronization and phase coherence;

- endogenous structural coherence;

- operational quantities `C_FRP(t)`, `P_FRP(t)`, and `Delta_FRP(t)`;

- thermal-state feedback;

- hierarchical and multiscale processor organization.

## Physical Foundation

FRP physical foundation:

`docs/physical_foundation.md`

The document records the FRP physical implementation relations for:

- retained balanced ternary state;

- active neutral state execution;

- transition-capacity distribution;

- endogenous thermal-state feedback;

- hardware-facing fixed-point representation;

- RTL realization;

- target-independent FPGA preparation.

## Balanced Ternary Retained-State Domain

The retained processor-state domain is:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative, inhibitory, counter-phase, or suppressive potential |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive, excitatory, phase-supporting, or constructive potential |

The active neutral state is:

`0`

The active neutral state participates in:

- logical neutrality;

- phase damping;

- balancing;

- transition buffering;

- conflict neutralization;

- polarity bridging;

- switching-load distribution;

- temporal scheduling control;

- retained-state stabilization.

## Canonical Hardware Encoding

| Ternary state | Two-bit encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

The same canonical encoding is used for:

- retained processor state;

- phase-derived target state;

- request target state;

- transition candidates;

- pending-route polarity.

Qualified reserved-state record:

`reserved_state_events = 0`

## Active-Neutral Transition Semantics

Direct opposite-polarity retained-state transitions are forbidden:

`-1 → 1`

`1 → -1`

Opposite-polarity transitions follow:

`-1 → 0 → 1`

`1 → 0 → -1`

For:

`state_i × target_i = -1`

the first eligible neutralization tick performs:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick performs:

`0 → pending_route_i`

Qualified direct-event record:

`actual_direct_events = 0`

## M16 RTL Artifact Boundary

RTL source directory:

`rtl/m16/`

The closed RTL boundary contains:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

Integrated synthesis boundary:

`frp_m16_core`

Executable simulation boundary:

`frp_m16_tb`

## M16 SystemVerilog Artifact Inventory

| File | Function |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | canonical encodings, scheduler states, transition classes, invariant indexes, capacity parameters, and shared functions |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal scheduler execution and scheduler counters |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-polarity creation, ownership, deferral, completion, and clearing |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition-candidate generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `rtl/m16/frp_m16_state_update.sv` | capacity-approved retained balanced ternary state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL execution and synthesis boundary |
| `rtl/m16/frp_m16_assertions.sv` | temporal, domain, routing, capacity, and writeback assertions |
| `rtl/m16/frp_m16_tb.sv` | deterministic executable architectural testbench |

## M16 RTL Documentation Inventory

| File | Function |
|---|---|
| `rtl/m16/README.md` | M16 RTL architecture and execution semantics |
| `rtl/m16/ARTIFACTS.md` | RTL source and documentation manifest |
| `rtl/m16/SIMULATION.md` | simulator build and execution commands |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | simulator execution and qualification transcript |
| `rtl/m16/CLOSURE.md` | M16 RTL closure record |

## M16 Temporal Scheduler

The M16 RTL core preserves three execution modes:

- `free`;

- `7/1`;

- `1/7`.

The scheduler state determines which transition classes execute on each enabled tick.

The scheduler counter relation is:

`sum(scheduler_counts) = ticks_recorded`

Counter clearing preserves retained ternary state, retained pending routes, scheduler mode, and scheduler tick position.

### Free Mode

Every enabled tick is:

`free`

The `free` scheduler state is commit-capable and neutralize-capable.

It executes:

- same-state retention;

- `0 → -1`;

- `0 → 1`;

- `-1 → 0`;

- `1 → 0`;

- the first leg of an opposite-polarity route;

- pending-route completion from active neutral state `0`.

### 7/1 Mode

The repeating scheduler sequence is:

`balance → balance → balance → balance → balance → balance → balance → commit`

The `balance` state is neutralize-capable.

The `commit` state is commit-capable.

Recorded scheduler relations:

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

An opposite-polarity route initiated during a balance tick remains retained until a commit-capable tick.

### 1/7 Mode

The repeating scheduler sequence is:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

The `excite` state is commit-capable.

The `neutralize` state is neutralize-capable.

Recorded scheduler relation:

`16 ticks → excite = 2, neutralize = 14`

An opposite-polarity route initiated during a neutralize tick remains retained until an excite tick.

## M16 Transition Classes

The M16 transition classifier distinguishes:

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

The `free` scheduler state belongs to both capability classes.

## M16 Request-Lane Arbitration

The request-lane boundary accepts:

- request-valid bits;

- cell indexes;

- balanced ternary targets;

- retained cell state;

- retained pending-route state;

- scheduler state.

Request lanes are processed in ascending lane order.

For each tick:

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

## M16 Pending-Route State

Each retained cell contains one pending-route slot.

A retained pending route:

- owns its cell until completion;

- has priority over a new request for the same cell;

- retains its exact polarity across scheduler-ineligible ticks;

- retains its exact polarity across transition-capacity deferral;

- completes only from retained state `0`;

- clears only after the corresponding state writeback;

- cannot be overwritten by another route.

For `1 → -1`:

`1 → 0`

→ `pending_route = -1`

→ `0 → -1`

→ `pending_route = 0`

For `-1 → 1`:

`-1 → 0`

→ `pending_route = 1`

→ `0 → 1`

→ `pending_route = 0`

Qualified queue record:

`queue_overflow_events = 0`

## M16 Distributed Transition Capacity

Transition fraction:

`transition_fraction = 0.25`

Capacity relation:

`max_changes = max(1, round(CELLS × transition_fraction))`

`REQUEST_LANES = max_changes`

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Capacity is consumed by an actual retained-state change.

Same-state retention consumes no transition capacity.

The two legs of an opposite-polarity route consume capacity on separate eligible ticks:

- first leg: retained polarity to active neutral state `0`;

- completion leg: active neutral state `0` to retained pending polarity.

Capacity order:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit request lanes in ascending lane order.

A capacity-deferred route retains its state and pending polarity.

Qualified capacity relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

`switch_load = switch_load_numerator / CELLS`

## M16 Retained-State Tick Order

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

## M16 Retained-State Writeback

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

## M16 Integrated Invariant Boundary

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

## M16 Assertion Boundary

The SystemVerilog assertion layer checks:

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

## M16 Deterministic RTL Testbench

RTL testbench:

`rtl/m16/frp_m16_tb.sv`

Top-level testbench module:

`frp_m16_tb`

Testbench configuration:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

The executable testbench covers:

- reset to active neutral state `0`;

- `free` scheduler execution;

- `7/1` scheduler execution;

- `1/7` scheduler execution;

- both opposite-polarity routes;

- pending-route creation;

- pending-route retention;

- pending-route completion;

- two-lane transition-capacity saturation;

- counter clearing with retained state preserved;

- all ten invariant flags;

- terminal zero-event counters.

## M16 RTL Simulation Commands

Build command:

```bash
verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log
```

Execution command:

```bash
/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log
```

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

## M16 RTL Initial Closure Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

## M16 RTL Qualification Rerun Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

## M16 FPGA Preparation Boundary

FPGA preparation directory:

`fpga/m16/`

The closed FPGA preparation boundary contains:

`2 SystemVerilog artifacts + 2 documentation artifacts`

The FPGA preparation layer is target-independent.

The qualified M16 RTL core remains instantiated inside:

`frp_m16_core`

## M16 FPGA Preparation Artifact Inventory

| File | Function |
|---|---|
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation simulation and qualification transcript |
| `fpga/m16/CLOSURE.md` | FPGA preparation closure record |

The FPGA preparation layer inherits nine M16 RTL dependencies:

- `rtl/m16/frp_m16_pkg.sv`;

- `rtl/m16/frp_m16_scheduler.sv`;

- `rtl/m16/frp_m16_request_lanes.sv`;

- `rtl/m16/frp_m16_pending_routes.sv`;

- `rtl/m16/frp_m16_active_neutral.sv`;

- `rtl/m16/frp_m16_capacity_guard.sv`;

- `rtl/m16/frp_m16_state_update.sv`;

- `rtl/m16/frp_m16_core.sv`;

- `rtl/m16/frp_m16_assertions.sv`.

Inherited RTL dependency validation:

`PASS`

## FPGA Integration Top

Top-level module:

`frp_m16_fpga_top`

Instantiated execution core:

`frp_m16_core`

The integration top exposes:

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

- scheduler mode and scheduler state;

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

FPGA integration-top elaboration:

`PASS`

## FPGA Reset Synchronization

External reset input:

`rst_n_async`

Internal core reset:

`rst_n_core`

Qualified reset sequence:

1. the external reset asserts asynchronously;
2. the synchronization register clears;
3. the first release edge remains blocked;
4. the second release edge activates `rst_n_core`;
5. `core_ready` becomes active.

Qualified reset relations:

| Relation | Result |
|---|---:|
| asynchronous external reset assertion | `PASS` |
| synchronization register clear | `PASS` |
| first release edge remains blocked | `PASS` |
| second release edge activates `core_ready` | `PASS` |
| retained state remains active neutral during reset | `PASS` |
| pending-route bank remains clear during reset | `PASS` |
| scheduler counters remain clear during reset | `PASS` |

## FPGA Core-Ready and Execution-Input Gating

Readiness relation:

`core_ready = rst_n_core`

Input-gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Before `core_ready` becomes active:

- ticks do not reach the M16 core;

- counter-clear events do not reach the M16 core;

- request-valid events do not reach the M16 core;

- requests are not accepted;

- retained state remains unchanged;

- pending routes remain unchanged;

- scheduler counters remain unchanged.

Qualified input-gating relations:

| Relation | Result |
|---|---:|
| tick blocking before readiness | `PASS` |
| counter-clear blocking before readiness | `PASS` |
| request blocking before readiness | `PASS` |
| retained-state preservation | `PASS` |
| pending-route preservation | `PASS` |
| scheduler-counter preservation | `PASS` |

## FPGA Scheduler and Request Propagation

Qualified scheduler modes:

- `free`;

- `7/1`;

- `1/7`.

Qualified scheduler states:

- `free`;

- `balance`;

- `commit`;

- `excite`;

- `neutralize`.

Qualified request profile:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Qualified request propagation record:

| Signal | Value |
|---|---:|
| `request_accept[0]` | `1` |
| `request_reject[0]` | `0` |

Scheduler propagation:

`PASS`

Request-interface propagation:

`PASS`

## FPGA Active-Neutral and Pending-Route Execution

Qualified opposite-polarity request route:

`1 → 0 → -1`

Retained pending polarity:

`pending_route = -1`

Qualified relations:

| Relation | Result |
|---|---:|
| opposite-polarity request detected | `PASS` |
| direct transition prevented | `PASS` |
| active-neutral first leg executed | `PASS` |
| exact requested polarity retained | `PASS` |
| pending completion executed from `0` | `PASS` |
| pending route cleared after completion | `PASS` |
| direct retained-state writeback absent | `PASS` |

Qualified event record:

| Event | Value |
|---|---:|
| `requested_direct_events` | `1` |
| `actual_direct_events` | `0` |

## FPGA Integrated Invariant Record

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

## FPGA Terminal Output Record

| Terminal value | Recorded value |
|---|---:|
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Terminal output validation:

`PASS`

## M16 FPGA Preparation Qualification Scope

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

The workflow qualifies:

- exact FPGA artifact inventory;

- exact inherited M16 RTL dependency inventory;

- FPGA top parsing;

- FPGA integration-top elaboration;

- executable FPGA testbench generation;

- executable FPGA testbench execution;

- latch-diagnostic rejection;

- multidriven-diagnostic rejection;

- asynchronous reset assertion;

- two-stage synchronous reset release;

- `core_ready` generation;

- execution-input gating;

- scheduler propagation;

- request-interface propagation;

- active-neutral first-leg execution;

- retained pending-route completion;

- transition-capacity correlation;

- all ten invariant flags;

- terminal zero-event validation;

- repository-integrity validation;

- qualification evidence generation.

## M16 FPGA Preparation Initial Closure Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#1` |
| Qualified repository commit | `326b69e` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `1m 7s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

## M16 FPGA Preparation Qualification Rerun Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

## M16 Public Architecture Documents

The M16 public architecture document set contains:

- `docs/m16_rtl_core_realization_execution_semantics.md`;

- `docs/m16_scheduler_state_rtl_realization.md`;

- `docs/m16_request_lane_arbitration_module.md`;

- `docs/m16_pending_route_register_module.md`;

- `docs/m16_active_neutral_transition_module.md`;

- `docs/m16_transition_capacity_guard_module.md`;

- `docs/m16_retained_state_update_module.md`;

- `docs/m16_rtl_core_interface_contract.md`;

- `docs/m16_balanced_ternary_state_register_map.md`;

- `docs/m16_invariant_assertion_set.md`;

- `docs/m16_external_simulator_execution_plan.md`;

- `docs/m16_rtl_artifact_boundary_qualification.md`;

- `docs/m16_artifact_boundary_test_stability_policy.md`;

- `docs/m16_m15_vector_replay_compatibility_report.md`;

- `docs/m16_qualification_manifest.md`;

- `docs/m16_qualification_index.md`;

- `docs/m16_public_status_snapshot.md`.

## M16 Workflow Boundary

M16 workflow files:

- `.github/workflows/frp-m16-rtl-artifact-boundary.yml`;

- `.github/workflows/frp-m16-fpga-preparation.yml`;

- `.github/workflows/frp-m16-canonical-core-domain.yml`;

- `.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

Workflow names:

- `FRP M16 RTL Artifact Boundary`;

- `FRP M16 FPGA Preparation`;

- `FRP M16 Canonical Core Domain`;

- `FRP M16 Reserved Cell Cleanup`.

## Historical Benchmark Contours

The repository preserves separate benchmark and qualification records for:

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

## FRP v0.9.3 Transition Benchmark

Benchmark record:

`TEST_REPORT_v0_9_3.md`

Benchmark parameters:

| Parameter | Value |
|---|---|
| `N` | `8, 16, 32, 64` |
| seeds | `0..4` |
| cycle modes | `free`, `7/1`, `1/7` |
| operations | `neg`, `add`, `sub`, `compare`, `consensus` |
| steps | `128` |

Recorded results:

| Architecture | Match | `C-P_min` | `heat_peak` | `switch_load_peak` | `actual_direct_events` | `prevented_direct_events` | `neutralized_conflicts` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

Recorded heat-peak relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded numerical representations:

- `15.69× lower heat_peak`;

- `93.63% lower heat_peak`.

Measurement contour:

`FRP v0.9.3 transition benchmark model and defined workload`

## FRP v0.9.4 Structured Benchmark

Executable:

`frp_prototype_v0_9_4.py`

Schema:

`frp.structured_output.v0.9.4`

Output formats:

- text;

- structured JSON.

Architecture labels:

- `binary_style_forced_switch`;

- `direct_ternary_commit`;

- `distributed_neutral_ternary`;

- `frp_distributed_resonant`.

## M3 Benchmark Matrix History

Validated historical schemas:

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

Recorded historical execution domains include:

- distributed-neutral ternary execution;

- external implementation feedback;

- transition pressure;

- aggressive feedback stress;

- stateful thermal-delay stabilization;

- bounded thermal survival;

- thermal stability-boundary sweep;

- dyadic hierarchical topology;

- dense hierarchical reference interaction;

- accelerated hierarchical interaction;

- distributed local thermal fields;

- localized hotspot containment;

- M15 implementation mapping and qualification closure.

## FRP v1.7.0 M15 Benchmark Matrix

Executable:

`frp_prototype_v1_7_0.py`

Schema:

`frp.m3.benchmark_matrix.v1.7.0`

Validated rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Recorded M15 qualification results:

| Qualification record | Result |
|---|---:|
| M15 self-test | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation markers | `5 / 5 matches = 1.0` |
| deterministic replay markers | `6 / 6 matches = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

## Comparative Architecture Benchmark Suite

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

## Comparative Architecture Tick-Level Record

| Architecture | Completion ticks | Mean latency ticks | Maximum latency ticks | Throughput commands per tick |
|---|---:|---:|---:|---:|
| `binary_synchronous_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `binary_clock_gated_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `direct_ternary_reference` | `288` | `1.0` | `1` | `0.8888888888888888` |
| `frp_v1_7_0_quantized_shadow` | `413` | `1.48828125` | `2` | `0.6198547215496368` |

Recorded semantic results for all four architecture profiles:

- `semantic_completion_ratio = 1.0`;

- `semantic_output_match = 1.0`.

The canonical unit-event comparison records identical completion ticks, mean latency ticks, maximum latency ticks, and throughput per tick for:

- `binary_synchronous_reference`;

- `binary_clock_gated_reference`;

- `direct_ternary_reference`.

## Canonical FRP Workload Record

| Metric | Value |
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

## FRP Quantized-Shadow Arithmetic Record

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Measurement contour:

`FRP v1.7.0 M15 quantized hardware shadow under the canonical comparative workload`

## Hardware-Informed Sensitivity Qualification

Schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Validated scenarios:

- `lower_bound`;

- `nominal`;

- `upper_bound`.

Recorded stability fields:

`ranking_stable = true`

`ranking_sensitive = false`

Ranking basis:

`ascending_total_normalized_energy`

Recorded ranking for all three scenarios:

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

## Retained-Route Completion and Capacity-Deferral Record

Qualified M16 execution records include:

- retained pending-route completion;

- deterministic pending-route priority;

- pending-route polarity retention across scheduler-ineligible ticks;

- pending-route polarity retention across transition-capacity deferral;

- transition-capacity enforcement;

- clean capacity rejection;

- retained-state preservation during deferral;

- `actual_direct_events = 0`;

- `reserved_state_events = 0`;

- `queue_overflow_events = 0`.

## Qutrit-Oriented Research Direction

The balanced ternary `{-1, 0, 1}` state domain, active neutral state `0`, and resonant phase dynamics define a future research direction for qutrit-oriented resonant computation.

## Stable Executable and Schemas

Executable semantic reference:

`frp_prototype_v1_7_0.py`

Structured-output schema:

`frp.structured_output.v1.7.0`

Benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

M16 adds the executable RTL and FPGA preparation layers without renaming the qualified M15 Python executable or its structured schema identifiers.

## Release Files

Updated release-facing files:

- `README.md`;

- `CI.md`;

- `CHANGELOG.md`;

- `CITATION.cff`.

M16 release files:

- `RELEASE_NOTES_v1_8_0.md`;

- `TEST_REPORT_v1_8_0.md`;

- `FRP_VALIDATION_INDEX_v1_8_0.md`.

Release architecture image:

`docs/frp_v1_8_0_m16_architecture-1.gif`

Inherited M15 release records:

- `RELEASE_NOTES_v1_7_0.md`;

- `TEST_REPORT_v1_7_0.md`;

- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## Release Tag

Release tag:

`v1.8.0`

## Release Status

Release:

`FRP v1.8.0`

Milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualification state:

`FRP v1.8.0 / M16 — PASS`

RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## Author

Maksym Marnov

Fractal Resonance Processor (FRP) Project



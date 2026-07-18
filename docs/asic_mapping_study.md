# ASIC Mapping Study — Fractal Resonance Processor (FRP)

**Ternary Fractal Resonant Coherence Processor**

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the current ASIC-oriented implementation and cost study for the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current public repository package:

`executable processor reference, structured output, reproducibility, verification, benchmark, comparative architecture, hardware-sensitivity, implementation-mapping, RTL execution, FPGA preparation, qualification, documentation, governance, and release-evidence layers`

Executable semantic reference:

`../frp_prototype_v1_7_0.py`

Structured-output schema:

`frp.structured_output.v1.7.0`

M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Qualified M15 architecture document:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 RTL architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

Current hardware pathway:

`./hardware_pathway.md`

Current FPGA mapping study:

`./fpga_mapping_study.md`

Current physical validation plan:

`./physical_validation_plan.md`

Current mathematical foundation:

`./mathematical_foundation.md`

Current physical foundation:

`./physical_foundation.md`

Current test report:

`../TEST_REPORT_v1_8_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`../RELEASE_NOTES_v1_8_0.md`

Qualified M15 foundation workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Current M16 RTL qualification record:

| Field | Value |
|---|---|
| workflow run | `#84` |
| qualified source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification record:

| Field | Value |
|---|---|
| workflow run | `#2` |
| qualified repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current published validation result:

`PASS`

Qualified M15 self-test result:

`41 / 41 PASS`

## 1. Purpose

The purpose of this document is to define how the qualified M15 semantic and implementation-mapping foundation and the closed M16 RTL execution layer are carried into an ASIC-oriented architectural, datapath, storage, control, activity, power, performance, area, verification, and physical-correlation study.

The ASIC study connects:

- balanced ternary state and retained-result semantics;
- active neutral transition routing;
- pending neutral-route persistence;
- distributed commit capacity;
- request-lane processing;
- scheduler execution;
- deterministic fixed-point arithmetic;
- Kuramoto-Sakaguchi resonant phase dynamics;
- asymmetric local gamma;
- dyadic hierarchical fractal coupling;
- phase velocity and phase evolution;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- distributed local thermal dynamics;
- correlated local gamma drift;
- nonlinear coherence compression;
- operational coherence `C(t)`;
- destabilizing load `P(t)`;
- dynamic stability `C(t) - P(t)`;
- phase-derived ternary targets;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized reference equivalence;
- exact deterministic replay;
- M15 qualification closure;
- M16 scheduler execution;
- M16 request-lane arbitration;
- M16 retained pending-route execution;
- M16 active-neutral routing;
- M16 transition-capacity enforcement;
- M16 retained-state writeback;
- M16 architectural assertion execution;
- M16 integrated invariant flags;
- M16 RTL execution closure;
- target-independent FPGA integration;
- FPGA reset and readiness control;
- FPGA request-interface propagation;
- FPGA preparation closure;
- target-specific FPGA timing correlation;
- ASIC datapath partitioning;
- ASIC state-storage architecture;
- arithmetic and lookup implementation studies;
- clocking and control studies;
- power, performance, and area record structure;
- test and trace interfaces;
- physical-validation preparation.

The ASIC study uses the M15 deterministic comparison domain, the M16 RTL execution boundary, and the M16 target-independent FPGA preparation boundary as separate source layers.

## 2. Current Reference Model and Validated Layer

The executable semantic-reference class is:

`FractalResonanceProcessor`

The stateful finite-word reference class is:

`QuantizedReferenceShadowProcessor`

The qualified executable semantic reference defines:

- balanced ternary state execution;
- active neutral routing;
- pending neutral routes;
- request-lane order;
- transition-fraction control;
- scheduler behavior;
- Kuramoto-Sakaguchi resonant phase dynamics;
- hierarchical topology;
- stateful delay dynamics;
- distributed local thermal dynamics;
- correlated gamma dynamics;
- multiscale phase coherence;
- operational coherence;
- destabilizing load;
- dynamic stability;
- structured telemetry;
- M15 implementation-mapping artifact generation.

The qualified semantic and implementation-mapping layer is:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The qualified M15 implementation chain is:

`floating semantic reference`

↓

`hardware-facing numeric profile`

↓

`balanced ternary hardware encoding`

↓

`stateful quantized hardware shadow`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure PASS`

The current RTL execution layer is:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

The current M16 RTL execution chain is:

`canonical balanced ternary package`

↓

`scheduler`

↓

`request-lane arbitration`

↓

`retained pending-route processing`

↓

`active-neutral transition generation`

↓

`transition-capacity admission`

↓

`retained-state writeback`

↓

`architectural assertions`

↓

`deterministic executable RTL testbench`

↓

`M16 RTL EXECUTION LAYER CLOSED`

The current M16 FPGA preparation chain is:

`qualified M16 RTL core`

↓

`target-independent FPGA integration top`

↓

`asynchronous external reset assertion`

↓

`two-stage synchronous reset release`

↓

`core_ready`

↓

`execution-input gating`

↓

`FPGA integration testbench`

↓

`M16 FPGA PREPARATION LAYER CLOSED`

The ASIC-oriented study uses the qualified M15 source chain and the closed M16 RTL and FPGA preparation layers.

## 3. ASIC Mapping Objective

The ASIC mapping objective is:

`translate the qualified FRP execution contract into chip-oriented architectural blocks and measurable implementation records while preserving state, scheduler, route, fixed-point, trace, invariant, and dynamic-stability correlation`

The ASIC study records:

- canonical balanced ternary state representation;
- active neutral routing-cell behavior;
- pending neutral-route storage;
- local transition control;
- distributed commit timing and activity-control structure;
- request-lane organization;
- scheduler control logic;
- state and parameter storage structures;
- deterministic fixed-point datapaths;
- trigonometric lookup and approximation structures;
- hierarchical coupling datapaths;
- delay-state datapaths;
- distributed thermal-state datapaths;
- gamma-state datapaths;
- nonlinear coherence-compression datapaths;
- multiscale coherence processing;
- `C(t)`, `P(t)`, and `C_minus_P` processing;
- telemetry, debug, and test interfaces;
- cycle-exact ASIC simulation correlation;
- power, performance, and area study fields;
- implementation activity counts;
- implementation cost-model fields;
- M15 deterministic comparison identities;
- M16 RTL execution identities;
- target-specific implementation identities;
- physical-correlation identities.

The ASIC study records deterministic correlation, architectural partitioning, timing, activity, power, performance, area, trace, and implementation identities as separate fields.

## 4. Current Validated Invariants for ASIC Study

The ASIC-oriented study inherits the qualified M15 processor invariants:

| Invariant | Required Result |
|---|---|
| balanced ternary state domain | `{-1, 0, 1}` |
| opposite-polarity routing | `-1 → 0 → 1` and `1 → 0 → -1` |
| direct opposite-polarity execution | `actual_direct_events = 0` |
| reserved hardware state | `reserved_state_events = 0` |
| pending-route queue | `queue_overflow_events = 0` |
| dynamic stability | `C_minus_P_min > 0.0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |
| topology closure | `fixed_point_topology_sum_exact = True` |
| thermal closure | `fixed_point_thermal_sum_exact = True` |
| semantic state sequence | match `1.0` |
| semantic scheduler sequence | match `1.0` |
| semantic neutral-route sequence | match `1.0` |
| semantic `C_minus_P` sign | match `1.0` |
| semantic boundary order | match `1.0` |
| exact shadow state replay | match `1.0` |
| exact shadow scheduler replay | match `1.0` |
| exact pending-route replay | match `1.0` |
| exact counter replay | match `1.0` |
| exact trace replay | match `1.0` |
| exact cell-trace replay | match `1.0` |

The M16 RTL execution boundary adds ten integrated invariant flags:

| Invariant Flag | Required Result |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | `1` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `1` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `1` |
| `FRP_INV_PENDING_POLARITY_VALID` | `1` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `1` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `1` |
| `FRP_INV_STATE_UPDATE_VALID` | `1` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `1` |
| `FRP_INV_NO_RESERVED_STATE` | `1` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `1` |

The qualified terminal invariant vector is:

`1111111111`

These invariants are retained as ASIC comparison fields.

## 5. Current Source Hierarchy for ASIC Correlation

The ASIC study uses the following source hierarchy:

1. `../frp_prototype_v1_7_0.py` — executable semantic reference and M15 artifact generator;
2. `./m15_implementation_mapping_domain_interface_qualification_closure.md` — qualified M15 implementation-mapping architecture;
3. `../TEST_REPORT_v1_7_0.md` — qualified M15 test and qualification evidence;
4. `../FRP_VALIDATION_INDEX_v1_7_0.md` — qualified M15 validation registry;
5. `../RELEASE_NOTES_v1_7_0.md` — M15 release evidence;
6. M15 fixed-point, encoding, shadow, trace, vector, interface, RTL-map, assertion, equivalence, and closure artifacts;
7. `../rtl/m16/` — current M16 RTL execution source boundary;
8. `./m16_rtl_core_realization_execution_semantics.md` — current M16 RTL architecture record;
9. `./m16_m15_vector_replay_compatibility_report.md` — M15-to-M16 compatibility record;
10. `./m16_rtl_artifact_boundary_qualification.md` — M16 RTL qualification record;
11. `./m16_qualification_index.md` — M16 qualification index;
12. `./m16_qualification_manifest.md` — M16 qualification manifest;
13. `../fpga/m16/` — current target-independent FPGA preparation boundary;
14. `./hardware_pathway.md` — current hardware-facing path;
15. `./fpga_mapping_study.md` — programmable-hardware mapping and execution-correlation study;
16. `./physical_validation_plan.md` — synchronized digital, timing, electrical, and physical thermal validation structure;
17. target-specific ASIC synthesis, timing, activity, power, performance, area, test, trace, and correlation outputs.

The M15 vector and trace domain supplies the integer comparison source.

The M16 RTL execution boundary supplies the executable scheduler, request-lane, pending-route, active-neutral, capacity, retained-state, telemetry, assertion, and invariant source.

## 6. Ternary State Representation

FRP uses the balanced ternary state and retained-result domain:

`{-1, 0, 1}`

The state roles are:

| State | Role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

The ASIC study preserves the semantic role of all three states.

The canonical implementation path is:

`encoded two-bit balanced ternary state`

Additional chip-oriented research paths retained from the study are:

| Representation Path | Study Record |
|---|---|
| encoded binary-hosted ternary | deterministic digital implementation representation |
| multi-line ternary representation | separate negative, neutral, and positive state lines |
| voltage-level ternary representation | direct physical ternary signaling research record |
| symbolic ternary element abstraction | element-behavior definition before physical specialization |
| mixed-control representation | binary control combined with ternary state semantics |

Study fields:

- exact ternary state decoding;
- active neutral state preservation;
- deterministic transition control;
- compatibility with local transition elements;
- compatibility with distributed commit control;
- compatibility with pending-route storage;
- compatibility with telemetry and test interfaces;
- compatibility with M15 vector replay;
- compatibility with the M16 RTL execution boundary;
- compatibility with target-specific physical implementation records.

## 7. Canonical Balanced Ternary Hardware Encoding

The canonical two-bit hardware encoding is:

`-1 → 2'b11`

`0 → 2'b00`

`1 → 2'b01`

The reserved encoding is:

`2'b10`

The canonical integer encoding is:

`-1 → 3`

`0 → 0`

`1 → 1`

The reserved integer code is:

`2`

The packed state-vector relation is:

`2 bits per element`

The default configured width is:

`16 elements × 2 bits = 32 bits`

The element packing relation is:

`element i → [2i+1:2i]`

The element-zero relation is:

`element 0 → [1:0]`

The reserved-state invariant is:

`reserved_state_events = 0`

The M16 package constants are:

| State | SystemVerilog Constant | Encoding |
|---|---|---|
| `-1` | `FRP_TERN_NEG` | `2'b11` |
| `0` | `FRP_TERN_ZERO` | `2'b00` |
| `1` | `FRP_TERN_POS` | `2'b01` |
| reserved | `FRP_TERN_RESERVED` | `2'b10` |

The ASIC study preserves this encoding through:

- state registers;
- packed state vectors;
- pending-route registers;
- preload artifacts;
- cycle-exact traces;
- vector packages;
- testbench interfaces;
- assertion correlation;
- scan and debug visibility;
- exact replay.

## 8. Active Neutral Routing Cell

Opposite-polarity execution follows the mandatory routes:

`-1 → 0 → 1`

`1 → 0 → -1`

The tick-separated execution relation is:

`tick N: active polarity → 0`

↓

`pending target polarity retained`

↓

`tick N+1 or later eligible tick: 0 → target polarity`

Active-neutral routing inputs include:

- current retained state;
- requested target state;
- scheduler state;
- tick enable;
- request acceptance;
- request neutralization state;
- request cell index;
- transition-capacity state;
- current pending-route state;
- pending-completion eligibility.

Active-neutral routing outputs include:

- next-state candidate;
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
- route-event counters;
- transition-domain invariant state.

The retained-state routing table is:

| Current State | Target State | Execution Relation |
|---|---|---|
| `-1` | `1` | `-1 → 0`, retain target, later `0 → 1` |
| `1` | `-1` | `1 → 0`, retain target, later `0 → -1` |
| `-1` | `0` | `-1 → 0` |
| `1` | `0` | `1 → 0` |
| `0` | `-1` | `0 → -1` |
| `0` | `1` | `0 → 1` |

The route invariant is:

`actual_direct_events = 0`

The current M16 active-neutral artifact is:

`../rtl/m16/frp_m16_active_neutral.sv`

## 9. Pending Neutral-Route Storage

### Qualified M15 Pending-Route Record

The qualified M15 execution model preserves pending routes across ticks.

Each M15 pending-route entry retains:

- cell index;
- target polarity;
- earliest ready tick.

The qualified M15 default queue capacity is:

`16`

The qualified M15 queue result is:

`queue_overflow_events = 0`

### Current M16 Pending-Route Register Layer

The current M16 execution layer retains one packed pending-route state for each retained-state element.

The M16 pending-route output is:

`pending_route_out`

The packed pending-route width is:

`CELLS × STATE_BITS`

The pending-route domain is:

`{-1, 0, 1}`

A pending-route value of `0` records no pending opposite-polarity target for that element.

A pending-route value of `-1` or `1` records the exact retained target polarity.

The M16 execution layer preserves:

- deterministic pending-route ownership;
- retained target polarity;
- pending-route persistence across disabled ticks;
- scheduler deferral;
- capacity deferral;
- completion only from retained state `0`;
- clearing after accepted completion;
- same-element pending overwrite prevention;
- exact pending-route output visibility;
- queue-overflow event visibility.

The qualified M16 queue result is:

`queue_overflow_events = 0`

The current M16 pending-route artifact is:

`../rtl/m16/frp_m16_pending_routes.sv`

ASIC storage structures recorded by the study include:

- register-based pending-route entries;
- compact FIFO structures;
- indexed pending-route tables;
- valid-bit arrays;
- element-index fields;
- target-state fields;
- eligibility fields;
- occupancy counters.

The ASIC comparison fields include:

- deterministic allocation order;
- deterministic ready-route processing order;
- route persistence across clock edges;
- completion eligibility;
- exact pending-route count or packed pending-route state;
- exact queue-overflow counter behavior;
- exact trace visibility.

## 10. Local Transition Controller

A ternary element or local retained-state group can use a transition controller.

Controller responsibilities include:

- compare current state with target state;
- detect opposite-polarity conflict;
- apply active neutral insertion;
- respect scheduler eligibility;
- respect tick enable;
- respect transition capacity;
- create retained pending routes;
- complete eligible pending routes;
- update retained state;
- expose local transition telemetry;
- update route counters;
- preserve the defined execution order.

Candidate local controller signals are:

| Signal | Recorded Role |
|---|---|
| `current_state` | current encoded ternary state |
| `target_state` | requested or phase-derived target |
| `next_state` | resolved next ternary state |
| `tick_enable` | enables execution for the current tick |
| `scheduler_state` | supplies the current temporal execution state |
| `commit_enable` | permits an eligible retained-state update |
| `neutral_insert` | routes an opposite-polarity change through active neutral state |
| `transition_defer` | retains an update for a later eligible tick |
| `pending_route_valid` | records a retained target route |
| `pending_route_ready` | authorizes retained-route completion |
| `local_switch_event` | contributes to the switch-load numerator |
| `local_conflict_event` | contributes to route-event records |

The current M16 transition-control boundary is distributed across:

- `../rtl/m16/frp_m16_request_lanes.sv`;
- `../rtl/m16/frp_m16_pending_routes.sv`;
- `../rtl/m16/frp_m16_active_neutral.sv`;
- `../rtl/m16/frp_m16_capacity_guard.sv`;
- `../rtl/m16/frp_m16_state_update.sv`.

These artifacts define request admission, retained-route state, transition classification, capacity admission, and retained-state writeback as separate RTL boundaries.

## 11. Distributed Commit Timing and Activity-Control Network

The qualified transition fraction is:

`0.25`

The qualified commit-capacity relation is:

`max_changes = max(1, round(cells × transition_fraction))`

The M16 RTL request-lane relation is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

The qualified transition-load relation is:

`switch_load_peak <= transition_fraction`

The M16 accepted-change relations are:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

The distributed commit bandwidth and current-tick activity capacity are recorded through:

- `REQUEST_LANES`;
- `accepted_changes`;
- `capacity_remaining`;
- `capacity_exhausted`;
- `switch_load_numerator`;
- `switch_load`.

The capacity order is:

1. eligible pending-route completions in ascending element-index order;
2. accepted explicit requests in ascending lane order.

A capacity-deferred route retains its state and pending target polarity.

Timing and control components include:

- global tick source;
- scheduler state generator;
- commit-capacity counter;
- transition-budget allocator;
- local commit-enable distribution;
- staged update network;
- pending-route service control;
- request-lane service control;
- transition-activity monitor;
- switch-load accumulator.

The current M16 capacity artifact is:

`../rtl/m16/frp_m16_capacity_guard.sv`

The execution relation is:

`control the fraction of eligible retained-state elements updated per tick while preserving deterministic pending-route, element-index, and request-lane order`

## 12. Request-Lane Organization

The qualified request-lane relation is:

`REQUEST_LANES = max_changes`

The qualified scaling profiles are:

| Cells | Hierarchy Depth | Request Lanes | Packed State Width |
|---:|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

The request-lane processing order is:

`ascending lane index`

### M15 Request Interface

The qualified M15 SystemVerilog interface map records:

- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

### M16 Request Interface

The current M16 RTL core receives:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

The current M16 request-lane outputs include:

- `request_accept`;
- `request_reject`;
- `accepted_cell_mask`;
- `neutral_routed_cell_mask`;
- `accepted_change_mask`.

The M16 request-lane boundary validates:

- enabled-tick execution;
- scheduler eligibility;
- valid element index;
- canonical target state;
- one accepted request per element per tick;
- ascending lane ownership;
- pending-route ownership;
- transition-capacity availability;
- acceptance and rejection separation.

The M16 internal rejection domains include:

- invalid element index;
- invalid target;
- duplicate element;
- scheduler rejection;
- capacity rejection;
- pending-route ownership;
- disabled tick.

ASIC request-lane blocks include:

- request-lane input registers;
- ascending lane-order processor;
- transition-capacity counter;
- target decoder;
- pending-route ownership check;
- scheduler-eligibility check;
- route-request issue logic;
- packed state update path;
- per-element switch-activity registers;
- switch-load output.

The current M16 request-lane artifact is:

`../rtl/m16/frp_m16_request_lanes.sv`

## 13. Scheduler Control Logic

The qualified scheduler modes are:

- `free`;
- `7/1`;
- `1/7`.

The qualified 16-tick profiles are:

| Scheduler | Counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

The qualified 64-tick `7/1` profile is:

`balance = 56`

`commit = 8`

### M15 Scheduler Encoding

The qualified M15 scheduler-mode encoding is:

| Code | Mode |
|---:|---|
| `0` | `free` |
| `1` | `7/1` |
| `2` | `1/7` |

The qualified M15 scheduler-state encoding is:

| Code | State |
|---:|---|
| `0` | `free` |
| `1` | `balance` |
| `2` | `commit` |
| `3` | `excite` |
| `4` | `neutralize` |

The qualified semantic scheduler phase push is:

| Scheduler State | Phase Push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all remaining states | `0.003` |

### M16 Scheduler Encoding

The current M16 scheduler-mode encoding is:

| Encoding | Mode |
|---|---|
| `2'b00` | `free` |
| `2'b01` | `7/1` |
| `2'b10` | `1/7` |
| `2'b11` | reserved |

The current M16 scheduler-state encoding is:

| Encoding | State |
|---|---|
| `3'b000` | `free` |
| `3'b001` | `balance` |
| `3'b010` | `commit` |
| `3'b011` | `excite` |
| `3'b100` | `neutralize` |
| `3'b111` | invalid |

The M16 scheduler outputs include:

- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`.

The scheduler count relation is:

`scheduler_count_free_q + scheduler_count_balance_q + scheduler_count_commit_q + scheduler_count_excite_q + scheduler_count_neutralize_q = ticks_recorded_q`

Scheduler control signals include:

| Signal | Recorded Role |
|---|---|
| `tick_index_q` | retained global tick index |
| `period_index_q` | current eight-tick period index |
| `scheduler_mode` | selected temporal execution mode |
| `scheduler_mode_q` | retained scheduler mode |
| `scheduler_state_q` | current scheduler state |
| `free_enable` | identifies free execution |
| `balance_enable` | identifies balance execution |
| `commit_enable` | identifies commit execution |
| `excite_enable` | identifies excite execution |
| `neutralize_enable` | identifies neutralize execution |
| scheduler counters | record executed state counts |

Scheduler blocks include:

- cycle counter;
- period-index counter;
- mode register;
- state decoder;
- per-state enable generation;
- per-state counters;
- scheduler trace output.

The current M16 scheduler artifact is:

`../rtl/m16/frp_m16_scheduler.sv`

## 14. State Storage and Register Architecture

The qualified M15 execution domain carries explicit per-element and global state.

The M15 state groups include:

| Register Group | Purpose |
|---|---|
| ternary state registers | current encoded state per element |
| packed state register | cycle-exact vector comparison |
| pending-route registers | target and ready-tick retention |
| scheduler registers | mode, state, and cycle count |
| phase registers | `PHASE_U32` state |
| base-frequency registers | per-element base frequency |
| target-frequency registers | per-element current target frequency |
| current-frequency registers | per-element lagged frequency state |
| thermal registers | local heat and overload |
| gamma registers | target, correlation state, and effective gamma |
| coherence registers | multiscale and global phase-order values |
| stability registers | `C`, `P`, and `C_minus_P` |
| route counters | requested, prevented, routed, conflict, and actual events |
| trace registers | post-tick comparison outputs |
| control registers | scheduler, target, preload, and execution control |
| test registers | correlation, scan, debug, and test access |

The current M16 RTL execution boundary contains:

| Register Group | Current RTL Record |
|---|---|
| retained ternary state | `state_out` |
| retained pending-route state | `pending_route_out` |
| scheduler mode | `scheduler_mode_q` |
| scheduler state | `scheduler_state_q` |
| tick count | `ticks_recorded_q` |
| scheduler counters | five state-specific counters |
| request result | `request_accept`, `request_reject` |
| accepted execution masks | element, neutral-route, and state-change masks |
| capacity state | accepted changes, remaining capacity, exhaustion |
| switch-load state | `switch_load_numerator` |
| route-event totals | requested, prevented, neutral-routed, and actual-direct events |
| domain-event totals | reserved-state and queue-overflow events |
| invariant state | ten integrated invariant flags |

Reset establishes:

- every retained ternary element at active neutral state `0`;
- every pending-route slot at `0`;
- scheduler mode `free`;
- scheduler state `free`;
- scheduler tick and event counters at zero.

ASIC storage structures include:

- encoded ternary register arrays;
- local retained-state groups;
- packed state registers;
- packed pending-route registers;
- scheduler state registers;
- fixed-point scalar register banks;
- phase-state arrays;
- frequency-state arrays;
- local thermal and gamma state arrays;
- coherence and stability registers;
- trace-capture buffers;
- test-access registers.

## 15. Hardware-Facing Numeric Profile

The qualified M15 numeric representations are:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

The qualified `S32Q16` profile is:

- signed;
- 32-bit width;
- 16 fractional bits;
- scale `65536`.

The qualified `S32Q30` profile is:

- signed;
- 32-bit width;
- 30 fractional bits;
- scale `1073741824`.

The qualified `PHASE_U32` profile is:

- unsigned;
- 32-bit width;
- full-cycle relation `2^32 phase units = 2π`;
- modulo `2^32` wrap.

The qualified rounding rule is:

`round-to-nearest, half cases away from zero`

The qualified saturation rule is:

`signed destination saturation`

The qualified multiplication rules are:

`mul_q16 = round_shift(a × b, 16)`

`mul_q16_q30 = round_shift(a × b, 30)`

`mul_q30 = round_shift(a × b, 30)`

The current M16 retained-state execution profile additionally records:

| Domain | Representation |
|---|---|
| one retained ternary state | `2 bits` |
| one retained pending-route state | `2 bits` |
| scheduler mode | `2 bits` |
| scheduler state | `3 bits` |
| period index | `3 bits` |
| telemetry counter | `32 bits` |

The M15 fixed-point numeric profile and M16 retained-state execution profile retain separate interface identities.

## 16. Fixed-Point Arithmetic Datapath Study

The ASIC arithmetic study records the following M15 fixed-point operation domains:

- Q16 additions;
- Q16 subtractions;
- Q16 multiplications;
- Q30 additions;
- Q30 subtractions;
- Q30 multiplications;
- mixed Q16 × Q30 multiplications;
- rounded shifts;
- saturation blocks;
- phase-word additions;
- phase wrapping;
- absolute-value operations;
- threshold comparisons;
- reduction trees;
- means;
- squares;
- magnitude calculations.

The recorded implementation structures include:

- dedicated multipliers;
- shared multipliers;
- pipelined multipliers;
- iterative arithmetic units;
- distributed arithmetic;
- operand-width specialization;
- constant-coefficient multiplication;
- reduction-tree pipelining;
- time-multiplexed datapaths.

Each arithmetic study profile retains:

- M15 integer comparison outputs;
- operation-domain identity;
- operand-width identity;
- rounding-rule identity;
- saturation-rule identity;
- pipeline-stage identity;
- latency identity;
- throughput identity;
- activity-count identity;
- area record;
- timing record;
- electrical record.

## 17. Trigonometric Lookup and Phase Approximation Study

The qualified deterministic trigonometric profile uses:

`4096 entries`

The qualified address width is:

`12 bits`

The qualified index relation is:

`phase_word >> 20`

The qualified output type is:

`S32Q30`

The qualified vector file is:

`frp_m15_trig_lut_q30.vec`

The M15 mapped RTL-domain identifier is:

`frp_m15_trig_lut_pkg.sv`

The recorded ASIC implementation structures include:

- ROM-based lookup;
- compiled memory macro;
- distributed combinational table;
- piecewise approximation;
- CORDIC-style approximation;
- hybrid lookup and arithmetic;
- shared lookup ports;
- replicated lookup banks;
- phase-domain symmetry reduction.

Study fields:

- integer output identity at the M15 correlation boundary;
- address relation;
- output width;
- read bandwidth;
- access latency;
- area;
- switching activity;
- electrical power;
- timing;
- integration with phase coupling;
- integration with coherence processing.

The phase-derived target vector produced by the semantic phase layer is supplied to the M16 RTL execution boundary through:

`target_q`

## 18. Kuramoto-Sakaguchi Phase Layer Mapping

The qualified resonant pair interaction is:

`sin(phase_j - phase_i - gamma_effective_i)`

The qualified nominal phase lag is:

`gamma = 0.30 × pi`

The source constant is:

`DEFAULT_GAMMA = 0.30 × pi`

The qualified nominal coupling strength is:

`coupling_nominal = 0.28`

The qualified phase velocity is:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

The qualified phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

ASIC phase-layer records include:

- phase register;
- phase-difference datapath;
- gamma-offset datapath;
- phase-word wrap logic;
- sine lookup interface;
- hierarchical weight interface;
- thermal pair-factor interface;
- coupling accumulator;
- phase-velocity datapath;
- scheduler-push input;
- cycle-exact phase output.

The phase-layer comparison fields include:

- phase-word input;
- gamma-effective input;
- scheduler-state identity;
- coupling-field input;
- phase-velocity output;
- wrapped phase output;
- tick index;
- trace identity.

Kuramoto-Sakaguchi resonant phase dynamics and balanced ternary retained-state execution remain separate computational layers connected through the phase-derived packed target vector.

## 19. Hierarchical Fractal Coupling Mapping

The qualified architecture uses a dyadic hierarchical ultrametric topology.

The qualified default element count is:

`16`

The qualified default hierarchy depth is:

`4`

The hierarchy-depth relation is:

`cells.bit_length() - 1`

The hierarchical distance between distinct elements is:

`(i XOR j).bit_length()`

The shell population is:

`2^(distance - 1)`

The qualified fractal exponent is:

`fractal_alpha = 0.70`

The qualified exactness marker is:

`fixed_point_topology_sum_exact = True`

The recorded ASIC implementation structures include:

- precomputed shell weights;
- ROM-based weight storage;
- constant-coefficient networks;
- grouped pair traversal;
- parallel pair engines;
- pipelined accumulation;
- time-multiplexed coupling units;
- hierarchy-level scheduling;
- reduction trees.

The M15 mapped RTL-domain identifier is:

`frp_m15_hierarchical_coupling.sv`

The hierarchical coupling comparison fields include:

- element-index pair;
- hierarchical distance;
- shell identity;
- normalized shell weight;
- topology-sum identity;
- phase-difference input;
- thermal pair factor;
- weighted interaction output;
- accumulated coupling field.

## 20. Stateful Delay Dynamics Mapping

Each qualified semantic-reference element maintains:

- base frequency;
- target frequency;
- current frequency.

The qualified frequency-target relation is:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

The qualified delayed response is:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

The qualified delay coefficient is:

`delay_alpha = 0.30`

The remaining frequency lag participates in:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

ASIC delay-layer records include:

- base-frequency register;
- target-frequency datapath;
- current-frequency register;
- frequency-difference datapath;
- delay-coefficient multiplier;
- lag register;
- cycle-exact output field.

The M15 mapped RTL-domain identifier is:

`frp_m15_delay_dynamics.sv`

Additional storage paths retained from the study are:

| Delay Structure | Study Record |
|---|---|
| logic delay chain | staged discrete-state history |
| coupling delay chain | staged coupling history |
| phase history buffer | phase-state trace and analysis |
| state history buffer | prior ternary-state trace |
| telemetry trace buffer | selected validation values |

The delay-layer comparison fields include:

- base-frequency input;
- target-frequency input;
- current-frequency input;
- state input;
- switch-activity input;
- delayed-frequency output;
- frequency-lag output;
- tick identity.

## 21. Distributed Local Thermal Mapping

Each qualified semantic-reference element tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

The qualified generated-power relation is:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

The qualified thermal-dissipation relation is:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

The qualified thermal parameters are:

| Parameter | Value |
|---|---:|
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| thermal diffusion gain | `0.035` |
| thermal topology exponent | `1.20` |
| thermal coupling gain | `2.50` |

The qualified exactness marker is:

`fixed_point_thermal_sum_exact = True`

ASIC thermal-state records include:

- generated-power datapath;
- thermal-dissipation datapath;
- hierarchical thermal-diffusion accumulator;
- local heat register;
- overload comparator;
- global heat reduction path;
- thermal exactness output.

The M15 mapped RTL-domain identifier is:

`frp_m15_thermal_field.sv`

Model thermal state, electrical power, electrical energy, and physical temperature retain separate measurement identities.

Physical electrical power uses:

`P_elec`

## 22. Thermal Coupling Feedback Mapping

The qualified local thermal overload is:

`max(0, local_heat - thermal_soft_limit)`

The qualified thermal node factor is:

`exp(-0.5 × thermal_coupling_gain × overload)`

The qualified thermal coupling gain is:

`2.50`

The thermal-feedback chain is:

`local thermal overload`

↓

`thermal node factor`

↓

`effective resonant coupling`

↓

`phase evolution`

↓

`coherence`

↓

`dynamic stability`

ASIC thermal-feedback records include:

- overload calculation;
- nonlinear-response lookup;
- normalized node-factor output;
- pair-factor combination;
- coupling-field modulation;
- local overload trace;
- thermal node-factor trace;
- coupling-field trace;
- tick identity.

Thermal state participates in endogenous processor feedback.

## 23. Correlated Gamma Drift Mapping

The qualified semantic reference tracks:

- nominal gamma;
- deterministic gamma-noise target;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

The qualified gamma-noise target refresh interval is:

`8 ticks`

The qualified target range is:

`[-1.0, 1.0]`

The qualified correlated update is:

`gamma_noise_state += 0.15 × (gamma_noise_target - gamma_noise_state)`

The qualified effective local gamma relation is:

`gamma_effective = gamma_nominal + 0.08 × thermal_overload × gamma_noise_state`

The M15 verification-sideband inputs include:

- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

ASIC gamma-state records include:

- gamma-noise target register;
- refresh counter;
- correlated-state datapath;
- overload multiplier;
- effective gamma adder;
- gamma trace output;
- deterministic stimulus identity;
- tick identity.

The M15 mapped RTL-domain identifier is:

`frp_m15_gamma_drift.sv`

## 24. Nonlinear Response and Coherence Compression Mapping

The qualified stability soft margin is:

`0.25`

The qualified margin pressure is:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

The qualified nonlinear compression relation is:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

The qualified effective coherence relation is:

`effective_coherence = raw_phase_coherence × coherence_compression`

The qualified exponential profile is:

- input domain `S32Q16` from `0` to `524288`;
- output type `S32Q30`;
- table entries `4096`.

The recorded ASIC implementation structures include:

- deterministic exponential lookup;
- ROM-based nonlinear response;
- piecewise approximation;
- bounded arithmetic;
- pipelined square and weighted-sum datapaths;
- shared lookup resources;
- replicated lookup resources;
- time-multiplexed compression units.

The comparison fields include:

- thermal-overload mean;
- previous `C_minus_P`;
- margin pressure;
- squared thermal-overload term;
- squared margin-pressure term;
- exponential-profile address;
- coherence-compression output;
- raw phase coherence;
- effective coherence;
- tick identity.

## 25. Kuramoto Order Parameter and Multiscale Coherence Mapping

The qualified global phase-order relation is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation is applied to hierarchical groups.

The qualified coherence domains are:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

The qualified outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

ASIC coherence records include:

- sine lookup path;
- cosine lookup path;
- hierarchical accumulation;
- mean calculation;
- magnitude calculation;
- minimum tracking;
- coherence-dispersion calculation;
- normalized Q30 outputs.

The M15 mapped RTL-domain identifier is:

`frp_m15_multiscale_coherence.sv`

The coherence comparison fields include:

- phase-word input set;
- hierarchy-group identity;
- sine accumulation;
- cosine accumulation;
- group mean;
- magnitude output;
- minimum output;
- dispersion output;
- global phase-order output;
- tick identity.

Phase synchronization and phase coherence are not interchangeable.

The global phase-order parameter `R(t)` is not identical to the general endogenous structural coherence quantity `C(t)`.

## 26. Operational Coherence, Load Tracking, and Dynamic-Stability Mapping

The qualified operational coherence relation is:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

The qualified destabilizing-load relation is:

`P = heat + switch_load`

The qualified dynamic-stability margin is:

`C_minus_P = C - P`

The qualified condition is:

`C_minus_P_min > 0.0`

The qualified semantic correlation markers are:

`semantic_C_minus_P_sign_match = True`

`semantic_boundary_order_match = True`

ASIC stability records include:

- effective-coherence contribution;
- cluster-coherence contribution;
- neutral-fraction contribution;
- mean-frequency-lag contribution;
- global heat input;
- switch-load input;
- `C` output register;
- `P` output register;
- `C_minus_P` output register;
- minimum-margin register;
- first stability-crossing detector.

The M15 mapped RTL-domain identifier is:

`frp_m15_stability_telemetry.sv`

The stability comparison fields include:

- `C`;
- `P`;
- `C_minus_P`;
- minimum `C_minus_P`;
- final `C_minus_P`;
- first boundary-crossing identity;
- sign-sequence correlation;
- boundary-order correlation;
- tick identity.

FRP operational `C` and `P` are processor-specific quantities.

Physical electrical power retains the separate symbol:

`P_elec`

## 27. Phase-Derived Ternary Target Mapping

The qualified automatic target relation is:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The cross-tick relation is:

`evolved phase field`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active-neutral routing`

↓

`retained ternary state`

↓

`subsequent resonant evolution`

The M15 execution control includes:

`auto_targets_enable`

The current M16 RTL execution boundary receives the phase-derived packed target vector through:

`target_q`

The M16 RTL execution boundary also receives explicit request inputs through:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

ASIC target-mapping records include:

- sine lookup read;
- positive-threshold comparator;
- negative-threshold comparator;
- ternary target encoder;
- automatic-target enable logic;
- packed target vector;
- explicit request lanes;
- request and automatic-target arbitration;
- resulting retained-state transition.

The target state domain is:

`{-1, 0, 1}`

## 28. Telemetry and Test Interface

### M15 Structured Telemetry

The qualified M15 execution domain provides compact deterministic summaries and optional full traces.

Compact execution records include:

- configuration;
- kernel contract;
- hardware profile;
- execution summary;
- preload digest;
- trace digest;
- cell-trace digest.

Full trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

The qualified default trace sizes are:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

The qualified M15 telemetry fields include:

- tick;
- scheduler state;
- packed ternary state;
- pending-route count;
- neutral-state count;
- positive-state count;
- negative-state count;
- switch load;
- route-counter deltas;
- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`;
- per-element phase;
- per-element frequency;
- per-element heat;
- per-element gamma state;
- per-element thermal node factor;
- per-element coupling field.

### M16 RTL Telemetry

The current M16 RTL execution boundary exposes:

- retained packed state;
- retained packed pending-route state;
- scheduler mode;
- scheduler state;
- recorded tick count;
- scheduler-state counters;
- request acceptance;
- request rejection;
- accepted-element mask;
- neutral-routed-element mask;
- accepted-change mask;
- accepted-change count;
- remaining capacity;
- capacity-exhausted state;
- switch-load numerator;
- requested-direct event count;
- prevented-direct event count;
- neutral-routed event count;
- actual-direct event count;
- reserved-state event count;
- queue-overflow event count;
- ten integrated invariant flags.

The current M16 FPGA integration boundary additionally exposes:

`core_ready`

The qualified FPGA invariant vector is:

`1111111111`

Candidate ASIC telemetry and test interfaces include:

- memory-mapped register interface;
- scan-visible register set;
- simulation trace export;
- debug bus;
- logic-analyzer signal group;
- structured host-side export;
- benchmark summary register block;
- on-chip trace buffer;
- external test port.

The telemetry comparison boundary records:

`M15 quantized reference`

↓

`M15 cycle-exact integer trace`

↓

`M15 deterministic RTL comparison vectors`

↓

`M16 executable RTL outputs`

↓

`M16 FPGA integration outputs`

↓

`target-specific ASIC simulation or measured trace outputs`

## 29. Current SystemVerilog Testbench Interface Map

### Qualified M15 Testbench Interface Map

The qualified M15 schema is:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

The qualified M15 default parameters are:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The qualified M15 execution inputs are:

- `clk`;
- `reset_n`;
- `scheduler_mode`;
- `auto_targets_enable`;
- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

The qualified M15 verification-stimulus inputs are:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

The qualified M15 comparison outputs are:

- `states_packed`;
- `scheduler_state`;
- `pending_route_count`;
- `switch_load_q`;
- `heat_global_q`;
- `global_phase_coherence_q`;
- `C_q`;
- `P_q`;
- `C_minus_P_q`;
- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`;
- `actual_direct_events`.

### Current M16 RTL Core Interface

The current M16 RTL core is:

`../rtl/m16/frp_m16_core.sv`

The M16 core parameters are:

| Parameter | Relation or Default |
|---|---|
| `CELLS` | default `16` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` |
| `CELL_INDEX_BITS` | `(CELLS <= 1) ? 1 : $clog2(CELLS)` |
| `COUNTER_BITS` | `32` |

The M16 core inputs are:

- `clk`;
- `rst_n`;
- `tick_enable`;
- `clear_counters`;
- `scheduler_mode`;
- `request_valid`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

The M16 core outputs are:

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`;
- `request_accept`;
- `request_reject`;
- `accepted_cell_mask`;
- `neutral_routed_cell_mask`;
- `accepted_change_mask`;
- `accepted_changes`;
- `capacity_remaining`;
- `capacity_exhausted`;
- `switch_load_numerator`;
- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `actual_direct_events`;
- `reserved_state_events`;
- `queue_overflow_events`;
- `invariant_flags`.

### Current M16 FPGA Integration Interface

The target-independent FPGA integration top is:

`../fpga/m16/frp_m16_fpga_top.sv`

The FPGA integration boundary uses:

- `clk`;
- `rst_n_async`;
- `tick_enable`;
- `clear_counters`;
- scheduler-mode input;
- request-lane inputs;
- phase-derived packed target vector;
- `core_ready`;
- M16 RTL execution outputs.

The readiness-gating relations are:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

These interfaces retain separate M15, M16 RTL, and M16 FPGA preparation identities.

## 30. Current Synthesizable RTL Reference-Core Mapping

### Qualified M15 Reference-Core Mapping

The qualified M15 schema is:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

The M15 mapped RTL domains are:

- `rtl/m15/frp_m15_types_pkg.sv`;
- `rtl/m15/frp_m15_fixed_point_pkg.sv`;
- `rtl/m15/frp_m15_trig_lut_pkg.sv`;
- `rtl/m15/frp_m15_scheduler.sv`;
- `rtl/m15/frp_m15_transition_core.sv`;
- `rtl/m15/frp_m15_neutral_route_queue.sv`;
- `rtl/m15/frp_m15_delay_dynamics.sv`;
- `rtl/m15/frp_m15_thermal_field.sv`;
- `rtl/m15/frp_m15_gamma_drift.sv`;
- `rtl/m15/frp_m15_hierarchical_coupling.sv`;
- `rtl/m15/frp_m15_multiscale_coherence.sv`;
- `rtl/m15/frp_m15_stability_telemetry.sv`;
- `rtl/m15/frp_m15_top.sv`.

The M15 artifact records this file set as the qualified synthesizable RTL reference-core mapping.

### Current M16 RTL Realization

The current M16 RTL source boundary contains:

1. `../rtl/m16/frp_m16_pkg.sv`;
2. `../rtl/m16/frp_m16_scheduler.sv`;
3. `../rtl/m16/frp_m16_request_lanes.sv`;
4. `../rtl/m16/frp_m16_pending_routes.sv`;
5. `../rtl/m16/frp_m16_active_neutral.sv`;
6. `../rtl/m16/frp_m16_capacity_guard.sv`;
7. `../rtl/m16/frp_m16_state_update.sv`;
8. `../rtl/m16/frp_m16_core.sv`;
9. `../rtl/m16/frp_m16_assertions.sv`;
10. `../rtl/m16/frp_m16_tb.sv`.

The M16 RTL source artifact count is:

`10`

The current M16 RTL domain partition is:

| RTL Artifact | Execution Domain |
|---|---|
| `frp_m16_pkg.sv` | constants, encodings, types, invariant indexes, and shared functions |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` scheduler execution |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-route management |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | transition-capacity admission |
| `frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `frp_m16_core.sv` | integrated RTL execution boundary |
| `frp_m16_assertions.sv` | architectural and temporal assertion layer |
| `frp_m16_tb.sv` | deterministic executable architectural testbench |

The current M16 RTL closure status is:

`M16 RTL EXECUTION LAYER CLOSED`

The target-independent FPGA preparation artifacts are:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

The current FPGA preparation closure status is:

`M16 FPGA PREPARATION LAYER CLOSED`

The ASIC study records the M15 mapped domains, M16 executable RTL domains, and target-specific ASIC implementation domains as separate correlation layers.

## 31. M15 Exact Tick Execution Order

The M15 quantized hardware shadow and RTL reference-core domain use the same ordered 26-stage tick sequence:

1. resolve scheduler state;
2. clear current-tick switch-change counters;
3. clear current-tick per-element switch activity;
4. process ready pending neutral routes;
5. process external request lanes in ascending order;
6. process phase-derived targets when enabled;
7. calculate switch load;
8. update frequency targets;
9. update lagged frequencies;
10. calculate local generated power;
11. calculate local thermal dissipation;
12. calculate hierarchical thermal diffusion;
13. update local heat;
14. calculate local thermal overload;
15. update gamma-noise correlation states;
16. update local gamma-effective values;
17. update thermal node factors;
18. calculate hierarchical phase-coupling field;
19. update phase velocities;
20. update wrapped phase words;
21. calculate multiscale phase coherence;
22. calculate `C(t)`;
23. calculate `P(t)`;
24. calculate `C_minus_P`;
25. detect first stability crossing;
26. capture post-tick outputs.

The ASIC implementation study retains this ordered execution relation at the M15 cycle-correlation boundary.

### M16 Retained-State Tick Order

The current M16 RTL execution layer uses the following ordered retained-state sequence for every enabled tick:

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

The M15 26-stage semantic sequence and the M16 14-stage retained-state RTL sequence retain separate correlation identities.

## 32. Deterministic RTL Comparison Vector Package

The qualified schema is:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

The qualified package file count is:

`10`

The qualified files are:

- `frp_m15_kernel_vectors.vec`;
- `frp_m15_pending_routes.trace`;
- `frp_m15_scheduler_free_vectors.vec`;
- `frp_m15_scheduler_7_1_vectors.vec`;
- `frp_m15_scheduler_1_7_vectors.vec`;
- `frp_m15_full_correlation_vectors.vec`;
- `frp_m15_cell_trace.vec`;
- `frp_m15_reference_preload.json`;
- `frp_m15_trig_lut_q30.vec`;
- `frp_m15_sha256_manifest.json`.

The qualified deterministic package digest is:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The qualified deterministic regeneration result is:

`10 / 10 files byte-identical`

The qualified self-test marker is:

`vector_determinism_pass = True`

The M15 workflow generates two independent package directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

The workflow comparison command is:

`diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b`

The M15-to-M16 replay compatibility record is:

`./m16_m15_vector_replay_compatibility_report.md`

The recorded compatibility result is:

`PASS`

The ASIC study records this package as the cycle-exact simulation, post-synthesis replay, and trace-correlation source.

## 33. ASIC Testbench Strategy

The ASIC mapping study retains the qualified M15 testbench structure and the current M16 executable RTL boundary.

### M15 Testbench Inputs

- clock;
- reset;
- initial ternary state vector;
- preload state;
- scheduler mode;
- automatic-target enable;
- request-lane valid signals;
- request element identifiers;
- request target states;
- deterministic gamma-noise target stimulus;
- transition fraction;
- M15 vector rows;
- scaling profile;
- step count.

### M15 Testbench Outputs

- final ternary state vector;
- packed state vector;
- scheduler state;
- pending-route count;
- route counters;
- switch load;
- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`;
- trace-visible values;
- optional per-element trace fields;
- benchmark-compatible summary values.

### M16 RTL Testbench Inputs

- `clk`;
- `rst_n`;
- `tick_enable`;
- `clear_counters`;
- `scheduler_mode`;
- `request_valid`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

### M16 RTL Testbench Outputs

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler-state counters;
- request acceptance and rejection;
- accepted-element masks;
- neutral-routed-element mask;
- accepted-change mask;
- accepted-change count;
- remaining capacity;
- capacity-exhausted state;
- switch-load numerator;
- requested-direct event count;
- prevented-direct event count;
- neutral-routed event count;
- actual-direct event count;
- reserved-state event count;
- queue-overflow event count;
- ten integrated invariant flags.

### Deterministic Replay Order

The qualified replay order is:

1. parse the vector row;
2. drive input signals before the active clock edge;
3. apply verification-sideband stimulus;
4. execute one processor clock edge;
5. allow registered outputs to settle;
6. sample post-tick outputs;
7. compare sampled outputs against expected integer values;
8. execute invariant assertions;
9. stop immediately on mismatch.

The exact integer comparison rule is:

`actual integer field == expected integer field`

The FPGA integration replay additionally records:

1. asynchronous reset assertion;
2. two-stage synchronous reset release;
3. `core_ready`;
4. execution-input gating before readiness;
5. one enabled execution tick;
6. retained-state and pending-route outputs;
7. all ten invariant flags;
8. terminal event totals.

## 34. RTL Assertion Correlation

### Qualified M15 Assertion Correlation

The qualified M15 assertion count is:

`13`

The qualified M15 assertion domains are:

1. valid balanced ternary encoding;
2. reserved-state exclusion;
3. direct polarity-transition exclusion;
4. active neutral-route insertion;
5. target application after ready tick;
6. `actual_direct_events = 0`;
7. transition-limit enforcement;
8. scheduler sequence;
9. scheduler count consistency;
10. phase-topology fixed-point normalization;
11. thermal-topology fixed-point normalization;
12. deterministic trace tick count;
13. exact cycle-output comparison contract.

The qualified M15 assertion result is:

`PASS`

### Current M16 Assertion Correlation

The current M16 assertion artifact is:

`../rtl/m16/frp_m16_assertions.sv`

The M16 assertion domains include:

- reset establishment of active-neutral retained state;
- reset clearing of pending routes;
- reset clearing of scheduler counters;
- retained-state domain;
- pending-route domain;
- disabled-tick state retention;
- disabled-tick pending-route retention;
- accepted-change authorization;
- direct opposite-polarity writeback exclusion;
- active-neutral first-leg execution;
- retained pending-polarity validation;
- pending-route deferral;
- completion from retained state `0`;
- scheduler-mode validity;
- scheduler-state validity;
- scheduler count-sum relation;
- scheduler-mode execution;
- scheduler-counter retention;
- scheduler-counter clearing;
- request acceptance and rejection separation;
- disabled-tick request rejection;
- request-lane capacity;
- accepted-change count;
- neutral-route mask correlation;
- capacity-remaining relation;
- capacity-exhausted relation;
- switch-load numerator relation;
- zero actual-direct events;
- zero reserved-state events;
- zero queue-overflow events;
- all ten integrated invariant flags.

The M16 assertion execution result is:

`PASS`

The ASIC verification records apply these assertion domains to:

- RTL simulation;
- gate-level simulation;
- formal property sets;
- post-synthesis replay;
- scan and debug checks;
- physical trace correlation.

## 35. Floating-to-Quantized Reference Equivalence

The qualified floating semantic reference to quantized hardware-shadow correlation records:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`neutral_route_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

The qualified semantic correlation result is:

`5 / 5 required semantic correlation matches = 1.0`

The qualified maximum numeric errors are:

| Field | Recorded Maximum Error | Required Maximum |
|---|---:|---:|
| phase | `0.010957534368146086` | `0.02` |
| frequency | `0.000022803546471550362` | `0.0001` |
| heat | `0.00004701887369061575` | `0.001` |
| gamma | `0.0` | `0.000001` |
| coherence | `0.002228678310501553` | `0.01` |
| `C` | `0.0007545911459079235` | `0.01` |
| `P` | `0.000014974864477032557` | `0.001` |
| `C_minus_P` | `0.0007535557740776522` | `0.01` |

The qualified numeric correlation result is:

`PASS`

These relations define the semantic comparison boundary carried into ASIC execution records.

## 36. Exact Quantized Deterministic Replay

The qualified exact quantized replay records:

`shadow_replay_state_match = 1.0`

`shadow_replay_scheduler_match = 1.0`

`shadow_replay_pending_route_match = 1.0`

`shadow_replay_counter_match = 1.0`

`shadow_replay_trace_match = 1.0`

`shadow_replay_cell_trace_match = 1.0`

The qualified exact deterministic replay result is:

`6 / 6 deterministic replay matches = 1.0`

The qualified reference trace digest is:

`06be197a6f7620796daad6420091e21392295cb0e182b394da2d9990324415be`

The qualified cell-trace digest is:

`ba7d5f5a5f45d1c6808a0d4c7d7f612916bb2e2c4d33faf5e182810d704ad544`

The M15-to-M16 compatibility result is:

`PASS`

The ASIC correlation record extends this deterministic integer domain through:

- M16 RTL execution;
- M16 FPGA integration;
- target-specific ASIC RTL;
- gate-level execution;
- post-synthesis replay;
- physical trace capture.

## 37. Validation Against the Current Reference

The ASIC study compares chip-oriented execution records against the qualified M15 reference domain and the current M16 RTL execution boundary.

The qualified reference command is:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

The qualified full-trace command is:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

The qualified self-test command is:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

The qualified vector-package export command is:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

The qualified SystemVerilog interface-map export command is:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

The qualified RTL reference-core map export command is:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

The qualified equivalence-report export command is:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

The qualified closure-manifest export command is:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

The semantic and implementation-mapping comparison categories are:

- balanced ternary state validity;
- final state sequence;
- per-tick state sequence;
- scheduler sequence;
- request-lane order;
- active neutral-route sequence;
- pending-route sequence;
- route counters;
- switch load;
- local and global model thermal state;
- phase state;
- frequency state;
- gamma state;
- multiscale coherence;
- `C`;
- `P`;
- `C_minus_P`;
- trace identity;
- cell-trace identity.

The M16 retained-state comparison categories are:

- retained packed state;
- retained packed pending-route state;
- scheduler state;
- scheduler counters;
- request acceptance and rejection;
- accepted-change masks;
- accepted-change count;
- remaining capacity;
- capacity-exhausted state;
- switch-load numerator;
- event totals;
- integrated invariant flags;
- terminal-marker identity.

The M15 quantized hardware shadow remains the integer comparison source for semantic and implementation-mapping replay.

The M16 RTL core supplies the executable retained-state comparison boundary.

## 38. Qualification Closure

### M15 Qualification Closure

FRP v1.7.0 M15 defines ten qualified artifact layers:

1. `fixed_point_interface_profile`;
2. `balanced_ternary_hardware_encoding_map`;
3. `quantized_reference_shadow_model`;
4. `cycle_exact_reference_trace`;
5. `rtl_comparison_vector_package`;
6. `systemverilog_testbench_interface_map`;
7. `synthesizable_rtl_reference_core`;
8. `rtl_assertion_correlation_harness`;
9. `reference_rtl_equivalence_report`;
10. `qualification_closure_manifest`.

The qualified M15 artifact-layer count is:

`10`

The qualified M15 closure result is:

`PASS`

The M15 closure chain is:

`fixed-point interface`

↓

`balanced ternary encoding`

↓

`quantized hardware shadow`

↓

`cycle-exact trace`

↓

`RTL comparison vectors`

↓

`SystemVerilog interface map`

↓

`synthesizable RTL reference-core map`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

### M16 RTL Execution Closure

The current M16 RTL boundary records:

| Qualification Field | Result |
|---|---:|
| SystemVerilog source artifacts | `10` |
| RTL documentation artifacts | `5` |
| Verilator parsing and elaboration | `PASS` |
| executable architectural testbench | `PASS` |
| architectural assertion execution | `PASS` |
| all ten integrated invariant flags | `PASS` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The M16 RTL closure status is:

`M16 RTL EXECUTION LAYER CLOSED`

### M16 FPGA Preparation Closure

The current target-independent FPGA preparation boundary records:

| Qualification Field | Result |
|---|---:|
| FPGA SystemVerilog artifacts | `2` |
| integration-top elaboration | `PASS` |
| executable FPGA integration testbench | `PASS` |
| asynchronous external reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` | `1` |
| execution-input gating | `PASS` |
| all ten invariant flags | `1111111111` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The M16 FPGA preparation closure status is:

`M16 FPGA PREPARATION LAYER CLOSED`

## 39. Candidate ASIC Block Diagram

### Complete Semantic and ASIC Correlation Structure

The complete logical block structure is:

`request lanes and phase-derived targets`

↓

`balanced ternary state decoder`

↓

`local transition controller`

↓

`active neutral routing`

↓

`pending neutral-route storage`

↓

`distributed commit timing and activity-control network`

↓

`ternary retained-state register bank`

↓

`stateful delay dynamics`

↓

`distributed thermal-field update`

↓

`correlated gamma-drift update`

↓

`hierarchical Kuramoto-Sakaguchi coupling`

↓

`phase velocity and wrapped phase update`

↓

`multiscale coherence processing`

↓

`nonlinear coherence compression`

↓

`C(t), P(t), and C_minus_P processing`

↓

`post-tick trace capture`

↓

`M15 vector comparison and assertion layer`

### Current M16 Retained-State RTL Structure

The current M16 executable RTL structure is:

`canonical balanced ternary package`

↓

`scheduler`

↓

`request-lane arbitration`

↓

`pending-route processing`

↓

`active-neutral transition generation`

↓

`transition-capacity admission`

↓

`retained-state writeback`

↓

`architectural telemetry`

↓

`integrated invariant evaluation`

↓

`SystemVerilog assertion layer`

↓

`deterministic executable testbench`

The M15 semantic structure and M16 retained-state RTL structure retain separate artifact and trace identities.

## 40. ASIC Study Profiles

The ASIC study profiles include:

| Profile | Recorded Subject |
|---|---|
| ternary element profile | encoded ternary state representation |
| alternate ternary representation profile | multi-line, voltage-level, symbolic, or mixed-control paths |
| active neutral routing profile | `-1 → 0 → 1` and `1 → 0 → -1` |
| pending-route profile | retained route state and completion eligibility |
| distributed commit profile | `transition_fraction = 0.25` |
| request-lane profile | ascending lane order |
| scheduler profile | `free`, `7/1`, and `1/7` modes |
| fixed-point profile | S32Q16, S32Q30, PHASE_U32, and GAMMA_S32 |
| trigonometric profile | 4096-entry lookup identity |
| phase-coupling profile | cycle-exact resonant phase behavior |
| delay profile | target/current frequency lag |
| thermal profile | local and global model thermal state |
| gamma profile | deterministic gamma-noise stimulus |
| nonlinear compression profile | coherence-compression behavior |
| coherence profile | hierarchical phase-order outputs |
| stability profile | `C`, `P`, and `C_minus_P` |
| telemetry profile | counters and trace outputs |
| M15 full-correlation profile | complete deterministic vector replay |
| M16 RTL execution profile | scheduler, requests, routes, capacity, state, assertions, and invariants |
| M16 FPGA integration profile | reset, readiness, gating, propagation, execution, and invariants |
| scaling profile | 8-, 16-, and 32-element configurations |
| synthesis profile | area and timing records after logic synthesis |
| activity profile | per-domain switching-activity records |
| electrical profile | voltage, current, power, and energy records |
| physical thermal profile | ambient and device temperature records |
| physical-correlation profile | trace identity for measured execution |

Each profile retains:

- source identity;
- workload identity;
- vector identity;
- parameter identity;
- target identity;
- toolchain identity;
- output identity;
- digest identity;
- qualification state.

## 41. Datapath Partitioning Study

The ASIC datapath study partitions the complete semantic execution model into:

- transition-control datapath;
- pending-route datapath;
- scheduler-control datapath;
- fixed-point scalar datapath;
- phase datapath;
- trigonometric lookup datapath;
- hierarchical coupling datapath;
- delay-state datapath;
- thermal-state datapath;
- gamma-state datapath;
- coherence datapath;
- nonlinear compression datapath;
- stability datapath;
- telemetry datapath.

The current M16 retained-state execution boundary partitions into:

- scheduler execution;
- request-lane arbitration;
- pending-route processing;
- active-neutral transition generation;
- transition-capacity admission;
- retained-state writeback;
- architectural telemetry;
- integrated invariant evaluation;
- assertion execution.

Partitioning fields include:

- timing depth;
- arithmetic reuse;
- retained-state locality;
- pending-route locality;
- memory bandwidth;
- lookup bandwidth;
- reduction-tree depth;
- switching activity;
- clocking boundaries;
- reset boundaries;
- readiness boundaries;
- test visibility;
- correlation visibility;
- parameterized scaling;
- pipeline-stage identity;
- cycle-latency identity.

Each partition retains its source, interface, parameter, trace, and comparison identities.

## 42. Memory and State-Storage Study

The ASIC storage domains include:

| Data Domain | Recorded Storage Structure |
|---|---|
| retained ternary state | register bank or compact encoded state memory |
| packed retained state | correlation register |
| retained pending routes | register table, packed register bank, FIFO, or compact SRAM-backed structure |
| scheduler mode and state | control registers |
| scheduler counters | counter register bank |
| phase words | register bank or local SRAM |
| base frequency | constant or programmable register bank |
| target frequency | register bank |
| current frequency | register bank |
| local heat | register bank or local SRAM |
| thermal overload | register bank or local SRAM |
| gamma target and state | register bank or local SRAM |
| hierarchical weights | ROM or constant network |
| trigonometric lookup | ROM or memory macro |
| exponential lookup | ROM or memory macro |
| coherence values | scalar and hierarchical register banks |
| stability values | `C`, `P`, and `C_minus_P` registers |
| event counters | telemetry counter bank |
| invariant flags | status register |
| trace buffer | SRAM or debug buffer |
| preload state | test-access storage |

The current M16 retained-state storage relations are:

`state width = CELLS × STATE_BITS`

`pending-route width = CELLS × STATE_BITS`

`STATE_BITS = 2`

The current M16 reset values are:

`state_out = 0`

`pending_route_out = 0`

The M16 state output domain is:

`{-1, 0, 1}`

The M16 pending-route output domain is:

`{-1, 0, 1}`

Storage-study fields include:

- access bandwidth;
- read-port count;
- write-port count;
- retained-state locality;
- pending-route locality;
- clock frequency;
- area;
- switching activity;
- trace access;
- scan access;
- reset behavior;
- retention behavior;
- scaling behavior;
- source identity;
- output identity.

## 43. Clocking and Control Study

### M15 Correlation Clocking Boundary

The qualified M15 execution contract uses:

- `clk`;
- `reset_n`;
- scheduler state;
- request-lane timing;
- deterministic sideband stimulus;
- post-tick registered outputs.

### M16 RTL Clocking Boundary

The current M16 RTL core uses:

- `clk`;
- `rst_n`;
- `tick_enable`;
- `clear_counters`;
- scheduler-mode input;
- explicit request-lane inputs;
- phase-derived packed target input;
- post-tick retained outputs.

### M16 FPGA Clocking and Readiness Boundary

The target-independent FPGA integration top uses:

- `clk`;
- `rst_n_async`;
- two-stage synchronous reset release;
- `core_ready`;
- gated tick input;
- gated counter-clear input;
- gated request-valid inputs.

The readiness-gating relations are:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

The ASIC clocking study records:

- primary processor clock;
- local clock-enable domains;
- scheduler control domain;
- request-capture timing;
- pending-route service timing;
- state-writeback timing;
- lookup access timing;
- reduction-tree pipeline boundaries;
- trace-capture timing;
- test clocking;
- scan clocking;
- reset assertion;
- reset release;
- readiness indication.

Clocking and control outputs include:

- state-machine partitioning;
- cycle sequencing;
- clock-enable structure;
- pipeline-stage boundaries;
- latency accounting;
- cycle-correlation mapping;
- reset timing record;
- readiness timing record;
- clock constraint identity.

## 44. Reset and Preload Mapping

### Qualified M15 Reset and Preload Boundary

The qualified M15 correlation inputs include:

- `reset_n`;
- `preload_valid`;
- deterministic preload state;
- deterministic gamma-noise sideband stimulus.

The qualified preload identity remains attached to:

- the deterministic M15 vector package;
- the reference preload file;
- the cycle-exact trace;
- the cell trace;
- the package SHA-256 manifest.

### Current M16 RTL Reset Boundary

M16 RTL reset establishes:

- every retained ternary element at active neutral state `0`;
- every pending-route slot at `0`;
- scheduler mode `free`;
- scheduler state `free`;
- tick counter at zero;
- scheduler counters at zero;
- architectural event counters at zero.

The M16 RTL core reset input is:

`rst_n`

### Current M16 FPGA Reset and Readiness Boundary

The FPGA integration reset input is:

`rst_n_async`

The FPGA reset relation is:

`asynchronous external assertion → two-stage synchronous release → core_ready`

Before `core_ready = 1`:

- processor ticks are gated;
- counter-clear inputs are gated;
- request-valid inputs are gated.

Reset and preload study fields include:

- reset assertion behavior;
- reset release sequence;
- active-neutral retained-state initialization;
- pending-route initialization;
- scheduler initialization;
- counter initialization;
- preload entry sequence;
- preload data path;
- preload completion indication;
- test-mode preload access;
- vector-package preload identity;
- post-preload execution start;
- readiness indication.

## 45. Arithmetic Implementation Study

The recorded M15 arithmetic operation domains include:

- Q16 multiplication;
- Q30 multiplication;
- mixed Q16 × Q30 multiplication;
- constant-coefficient multiplication;
- accumulation;
- addition;
- subtraction;
- comparison;
- saturation;
- rounding;
- phase wrapping;
- square operations;
- mean calculation;
- magnitude calculation;
- exponential lookup;
- sine lookup;
- cosine lookup;
- hierarchical reduction.

The recorded canonical FRP event totals are:

| Event Field | Recorded Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

ASIC arithmetic configurations recorded by the study include:

- full-custom arithmetic blocks;
- standard-cell arithmetic;
- shared multipliers;
- replicated multipliers;
- pipelined accumulators;
- iterative arithmetic;
- constant-coefficient structures;
- operand isolation;
- local clock enables;
- time-multiplexed execution.

Each arithmetic configuration retains:

- M15 vector-package identity;
- M15 invariant comparison;
- operand-width identity;
- arithmetic-rule identity;
- rounding identity;
- saturation identity;
- pipeline-stage identity;
- latency identity;
- activity record;
- area record;
- timing record;
- electrical record.

## 46. Power, Performance, and Area Study Structure

The ASIC-oriented study records the following fields.

### Area

- standard-cell area;
- sequential-cell area;
- combinational area;
- memory-macro area;
- lookup-storage area;
- clock-tree area;
- test-logic area;
- trace-buffer area;
- per-domain area;
- total implementation area.

### Performance

- target clock period;
- achieved setup timing;
- achieved hold timing;
- critical path;
- critical-path domain;
- cycle latency;
- throughput;
- scheduler-mode timing;
- active-neutral route latency;
- pending-route completion latency;
- scaling behavior;
- correlation-capture timing.

### Power and Activity

- total switching activity;
- clock activity;
- transition-control activity;
- scheduler activity;
- request-lane activity;
- pending-route activity;
- retained-state writeback activity;
- fixed-point arithmetic activity;
- lookup activity;
- hierarchical coupling activity;
- thermal-processing activity;
- gamma-processing activity;
- coherence-processing activity;
- memory activity;
- trace activity;
- debug activity;
- leakage estimate;
- dynamic power estimate.

Each reported result retains:

- source version;
- source commit;
- semantic-reference identity;
- M15 vector-package identity;
- M16 RTL source identity;
- toolchain identity;
- technology-library identity;
- constraint identity;
- workload identity;
- activity-capture identity;
- clock-profile identity;
- report-generation identity.

Cycle counts, wall-clock timing, normalized activity cost, electrical power, electrical energy, model thermal state, thermal proxy, and physical temperature retain separate metric identities.

## 47. Current Comparative Architecture Evidence

The Comparative Architecture Benchmark Suite directory is:

`../benchmarks/architecture_comparison/`

The suite schema is:

`frp.benchmark.architecture_comparison.v1`

The evaluated architecture identifiers are:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The canonical workload records:

- `256 commands`;
- `16 cells`;
- `seed 76`;
- `transaction_serial` execution;
- maximum `64` completion cycles per command;
- final cooldown `32` cycles.

All architecture rows record:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

The canonical unit-event profile is:

`unit_event_cost_v1`

The canonical result is:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

The canonical comparison-package digest is:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

The recorded unit-event baseline results are:

| Architecture | Normalized Activity Cost | Peak Temperature Proxy |
|---|---:|---:|
| `binary_synchronous_reference` | `5412.0` | `3.8474206768140564` |
| `binary_clock_gated_reference` | `934.0` | `0.771273768299779` |
| `direct_ternary_reference` | `1242.0` | `1.119499710224827` |
| `frp_v1_7_0_quantized_shadow` | `1393509.0` | `675.0796999541329` |

The recorded FRP route evidence is:

`requested_direct_events = 125`

`prevented_direct_events = 125`

`neutral_insertions = 125`

`neutral_routed_events = 125`

`actual_direct_events = 0`

`pending_route_count_final = 0`

`queue_overflow_events = 0`

`reserved_state_events = 0`

The recorded FRP stability evidence is:

`global_phase_coherence_final = 0.9999997103586793`

`C_minus_P_min = 0.856201171875`

`C_minus_P_final = 1.2415313720703125`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The canonical suite records normalized activity cost and peak temperature proxy as separate output fields.

ASIC area, timing, switching activity, electrical power, electrical energy, and physical temperature retain separate measurement fields.

## 48. Current Hardware-Sensitivity Evidence

The hardware-sensitivity schema is:

`frp.benchmark.hardware_sensitivity_comparison.v1`

The canonical result is:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

The hardware-sensitivity profile is:

`literature_anchored_cmos45_sensitivity_v1`

The normalization is:

`32-bit integer addition = 1.0`

The reference energy is:

`0.1 pJ`

The technology context is:

`45 nm CMOS`

The recorded scenarios are:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

The recorded results are:

| Scenario | Binary Synchronous | Binary Clock Gated | Direct Ternary | FRP v1.7.0 Quantized Shadow |
|---|---:|---:|---:|---:|
| `lower_bound` | `181.078125` | `111.109375` | `118.078125` | `14457825.125` |
| `nominal` | `724.3125` | `444.4375` | `472.3125` | `25157118.0` |
| `upper_bound` | `4049.25` | `2929.75` | `3041.25` | `39955490.0` |

The recorded ranking across all three scenarios is:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

The recorded ranking state is:

`ranking_stable = true`

`ranking_sensitive = false`

The hardware-sensitivity package digest is:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

The recorded package result is:

`PASS`

The coefficient-sensitivity records, ASIC implementation records, and physical measurement records retain separate artifact identities.

## 49. Current ASIC Activity Records

The canonical FRP operation-event totals are:

| Event Field | Recorded Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

The canonical comparison profile is:

`unit_event_cost_v1`

The canonical comparison result is:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

The canonical hardware-sensitivity profile is:

`literature_anchored_cmos45_sensitivity_v1`

The canonical hardware-sensitivity result is:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

The activity record preserves:

- event-field identity;
- event-total identity;
- architecture identity;
- workload identity;
- profile identity;
- result-file identity;
- package-digest identity.

Operation-event totals, normalized activity cost, area, timing, switching activity, electrical power, electrical energy, model thermal state, thermal proxy, and physical temperature retain separate fields.

## 50. Design-for-Test, Debug, and Trace Study

The telemetry and exact replay architecture define the test-oriented chip-study boundary.

Test and debug structures include:

- scan-accessible retained-state registers;
- scan-accessible pending-route registers;
- scan-accessible scheduler registers;
- scan-accessible route counters;
- packed state observation;
- scheduler-mode observation;
- scheduler-state observation;
- pending-route observation;
- request acceptance and rejection observation;
- accepted-change observation;
- capacity-state observation;
- switch-load numerator observation;
- phase-state observation;
- thermal-state observation;
- gamma-state observation;
- coherence-output observation;
- `C`, `P`, and `C_minus_P` observation;
- M16 invariant-status registers;
- signature registers;
- trace SRAM;
- vector preload interface;
- deterministic gamma-sideband interface;
- terminal-marker register;
- source-identity register;
- workload-identity register.

The test record includes:

- M15 preload identity;
- deterministic vector-input replay;
- post-tick integer-output capture;
- retained-state sequence;
- pending-route sequence;
- scheduler sequence;
- request-acceptance sequence;
- request-rejection sequence;
- route counters;
- accepted-change count;
- capacity state;
- invariant vector;
- trace digest;
- cell-trace digest;
- mismatch tick;
- mismatch field;
- mismatch expected value;
- mismatch recorded value.

The M16 observable zero-event fields are:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The M16 observable invariant vector is:

`1111111111`

The test and trace package retains:

- semantic-reference identity;
- M15 vector-package identity;
- M16 RTL source identity;
- target-specific ASIC source identity;
- toolchain identity;
- target identity;
- workload identity;
- capture identity;
- digest identity.

## 51. Physical Validation Interface Preparation

The physical-validation document is:

`./physical_validation_plan.md`

The ASIC study prepares interfaces for measurement and correlation of:

- balanced ternary state correctness;
- scheduler sequence;
- request-lane sequence;
- active-neutral route sequence;
- pending-route sequence;
- accepted-change sequence;
- transition-capacity state;
- retained-state transitions;
- phase evolution;
- frequency evolution;
- local model thermal state;
- global model thermal state;
- coherence trajectory;
- `C(t)`;
- `P(t)`;
- `C_minus_P`;
- clock timing;
- execution timing;
- switching activity;
- voltage;
- current;
- electrical power;
- electrical energy;
- ambient temperature;
- device temperature;
- repeatability;
- trace identity;
- workload identity;
- device identity;
- setup identity.

The M16 digital physical-correlation fields include:

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler counters;
- `request_accept`;
- `request_reject`;
- `accepted_cell_mask`;
- `neutral_routed_cell_mask`;
- `accepted_change_mask`;
- `accepted_changes`;
- `capacity_remaining`;
- `capacity_exhausted`;
- `switch_load_numerator`;
- route-event totals;
- `actual_direct_events`;
- `reserved_state_events`;
- `queue_overflow_events`;
- `invariant_flags`;
- `core_ready` at the FPGA integration boundary.

A physical correlation package preserves:

- FRP release identity;
- M15 semantic-reference identity;
- M15 vector-package identity;
- M16 RTL source identity;
- target-specific ASIC source identity;
- configuration identity;
- preload identity;
- workload digest;
- clock profile;
- reset profile;
- readiness profile;
- measurement setup profile;
- instrument and calibration identity;
- environmental conditions;
- raw measurement data;
- derived metric data;
- correlation result;
- review record;
- integrity manifest.

Model thermal state, thermal proxy, electrical power, electrical energy, and physical temperature retain separate field identities.

Physical electrical power uses:

`P_elec`

## 52. Earlier Silicon- and Production-Oriented Repository Layers

The repository preserves earlier silicon- and production-oriented architecture layers.

The relevant documents include:

- `./m9_silicon_heterogeneous_architecture.md`;
- `./m10_silicon_production_tapeout_readiness.md`;
- `./m11_production_integration_external_handoff.md`;
- `./m13_production_scaling_implementation_stabilization.md`;
- `./m14_physical_implementation_correlation_production_qualification.md`.

The current ASIC study uses the following correlation source chain:

`qualified FRP v1.7.0 semantic reference`

↓

`qualified M15 implementation-mapping package`

↓

`M15 deterministic vectors and exact replay`

↓

`closed M16 RTL execution layer`

↓

`closed target-independent M16 FPGA preparation layer`

↓

`target-specific ASIC architecture, synthesis, timing, activity, test, trace, and physical-correlation records`

The earlier silicon- and production-oriented documents retain their release-specific identities.

## 53. Current Default Validation Profile

### Qualified M15 Default Profile

The qualified M15 default profile is:

| Parameter | Value |
|---|---:|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |
| hierarchy depth | `4` |
| request lanes | `4` |
| packed state width | `32 bits` |

The qualified M15 summary is:

| Metric | Value |
|---|---:|
| ticks recorded | `64` |
| scheduler balance ticks | `56` |
| scheduler commit ticks | `8` |
| `C_minus_P_min` | `0.6142730712890625` |
| `C_minus_P_final` | `0.88287353515625` |
| `switch_load_peak` | `0.25` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |
| result | `PASS` |

### Current M16 RTL Execution Profile

The qualified M16 RTL testbench profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

The qualified M16 RTL terminal record is:

| Metric | Value |
|---|---:|
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| result | `PASS` |

### Current M16 FPGA Preparation Profile

The qualified M16 FPGA integration-testbench profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |
| result | `PASS` |

The M15, M16 RTL, and M16 FPGA preparation profiles retain separate source, parameter, execution, and trace identities.

## 54. Current Scaling Profiles

The qualified M15 scaling profiles are:

| Cells | Hierarchy Depth | Request Lanes | `C_minus_P_min` | Switch Load Peak |
|---:|---:|---:|---:|---:|
| `8` | `3` | `2` | `0.828887939453125` | `0.25` |
| `16` | `4` | `4` | `0.6142730712890625` | `0.25` |
| `32` | `5` | `8` | `0.6628875732421875` | `0.25` |

Each qualified scaling profile records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The inherited request-lane relation is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

The retained-state scaling profiles are:

| Elements | Request Lanes | Packed State Width | Packed Pending-Route Width |
|---:|---:|---:|---:|
| `8` | `2` | `16 bits` | `16 bits` |
| `16` | `4` | `32 bits` | `32 bits` |
| `32` | `8` | `64 bits` | `64 bits` |

The scaling record contains:

- element count;
- hierarchy depth;
- request-lane count;
- packed retained-state width;
- packed pending-route width;
- scheduler profile;
- execution-tick count;
- operation-event totals;
- memory inventory;
- area record;
- timing record;
- switching-activity record;
- trace identity;
- qualification state.

## 55. Implementation Risk Register

The ASIC implementation risk register is:

| Risk | Validation Control |
|---|---|
| fixed-point drift | cycle-exact integer comparison |
| lookup identity drift | SHA-256 and vector-package verification |
| core-domain drift | verify the canonical `{-1, 0, 1}` state domain |
| reserved encoding emission | record `reserved_state_events` and invariant state |
| direct opposite-polarity writeback | record `actual_direct_events` and active-neutral evidence |
| route-order drift | pending-route sequence comparison |
| pending-route overwrite | retained-polarity and queue-overflow checks |
| scheduler drift | scheduler-vector replay |
| scheduler counter drift | count-sum and mode-profile assertions |
| request-lane reordering | ascending lane-order assertions |
| duplicate element ownership | request acceptance and rejection comparison |
| transition-capacity drift | accepted-change and capacity-relation validation |
| retained-state writeback drift | state-update assertion comparison |
| reset-state drift | active-neutral reset-state validation |
| reset-release drift | asynchronous assertion and synchronous-release record |
| readiness drift | `core_ready` and execution-input gating record |
| invariant-vector drift | capture all ten M16 invariant flags |
| thermal accumulation drift | fixed-point thermal exactness checks |
| topology normalization drift | fixed-point topology exactness checks |
| gamma-stimulus drift | deterministic sideband-stimulus replay |
| pipeline latency mismatch | cycle-correlation mapping |
| state-storage bandwidth mismatch | access-profile and banking record |
| arithmetic-event mismatch | per-domain event-total comparison |
| lookup-event mismatch | lookup-event comparison |
| reduction-tree timing mismatch | pipeline and hierarchy timing record |
| debug-logic overhead | separate implementation and capture profiles |
| test-logic overhead | DFT area and timing records |
| physical trace mismatch | shared workload and vector identity |
| metric-domain mixing | separate proxy, model, timing, electrical, and physical thermal fields |

## 56. Expected ASIC Study Deliverables

The ASIC study defines the following deliverables:

- updated ASIC mapping study;
- selected ASIC study profile;
- technology and library identity record;
- source and toolchain identity record;
- top-level architectural partition;
- balanced ternary state-representation record;
- active neutral routing-element record;
- pending-route storage record;
- local transition-controller record;
- distributed commit-control record;
- request-lane organization record;
- scheduler-control record;
- retained-state storage record;
- pending-route storage record;
- fixed-point arithmetic record;
- trigonometric lookup record;
- exponential lookup record;
- hierarchical coupling record;
- delay-dynamics record;
- thermal-field record;
- gamma-drift record;
- nonlinear coherence-compression record;
- multiscale coherence record;
- stability telemetry record;
- chip-oriented testbench plan;
- M15 vector replay result;
- M15 assertion result;
- M15-to-M16 compatibility record;
- M16 RTL execution-correlation result;
- target-specific ASIC RTL result;
- synthesis report;
- timing report;
- area report;
- switching-activity report;
- electrical power-estimation report;
- memory inventory;
- arithmetic event inventory;
- lookup event inventory;
- test and debug interface plan;
- physical-validation interface plan;
- implementation-configuration report;
- ASIC-to-reference correlation report;
- integrity manifest.

Each deliverable retains:

- release identity;
- source identity;
- source-commit identity;
- reference identity;
- workload identity;
- vector identity;
- target identity;
- toolchain identity;
- result identity;
- digest identity.

## 57. Funding and Partner Relevance

The ASIC mapping study contains records for:

- RTL engineering review;
- ASIC architecture planning;
- verification planning;
- semiconductor research collaboration;
- grant preparation;
- laboratory collaboration;
- implementation-configuration study;
- power, performance, and area study;
- physical-validation planning;
- technical investor review;
- engineering partner review.

Current project assets include:

- FRP v1.8.0 release identity;
- M16 RTL Core Realization and Execution Semantics Package;
- qualified `frp_prototype_v1_7_0.py` executable semantic reference;
- `frp.structured_output.v1.7.0`;
- `frp.m3.benchmark_matrix.v1.7.0`;
- M15 `41 / 41 PASS`;
- M15 `10 / 10` byte-identical deterministic vector files;
- M15 `5 / 5` required semantic correlation matches equal to `1.0`;
- M15 `6 / 6` deterministic replay matches equal to `1.0`;
- reproducibility commands;
- structured benchmark output;
- Comparative Architecture Benchmark Suite;
- hardware-sensitivity qualification;
- deterministic fixed-point mapping;
- exact integer traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- exact deterministic replay;
- M15 qualification closure;
- ten M16 SystemVerilog RTL artifacts;
- five M16 RTL qualification documents;
- executable M16 RTL architectural simulation;
- M16 architectural assertion execution;
- ten M16 integrated invariant flags;
- `M16 RTL EXECUTION LAYER CLOSED`;
- target-independent M16 FPGA integration top;
- executable M16 FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- execution-input gating;
- `M16 FPGA PREPARATION LAYER CLOSED`;
- current hardware pathway;
- current FPGA mapping study;
- current ASIC mapping study structure;
- current physical-validation planning structure;
- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`.

The current partner-facing technical record is:

`FRP v1.8.0 contains the qualified M15 semantic and implementation-mapping foundation, the closed M16 RTL execution layer, the closed target-independent M16 FPGA preparation layer, deterministic fixed-point and vector artifacts, architectural assertions, integrated invariant records, and the ASIC-oriented implementation-study structure.`

The current engineering record is:

`The ASIC study records datapath partitioning, retained-state and pending-route storage, scheduler and request control, arithmetic and lookup event totals, timing, area, switching activity, test and trace interfaces, exact M15 comparison, M16 RTL correlation, and target-specific physical-correlation identities.`

## 58. Recommended ASIC Development Sequence

The ASIC development sequence is:

1. preserve the qualified `frp_prototype_v1_7_0.py` executable semantic reference;
2. preserve the ten qualified M15 artifact schemas;
3. preserve the canonical balanced ternary domain `{-1, 0, 1}`;
4. preserve the qualified M15 26-stage semantic tick order;
5. preserve deterministic preload and lookup identities;
6. preserve the M15 vector-package digest;
7. retain the closed M16 RTL execution layer;
8. replay kernel transition vectors;
9. replay scheduler vectors;
10. replay pending-route traces;
11. replay full-correlation vectors;
12. retain exact M15-to-M16 integer correlation;
13. retain the closed target-independent M16 FPGA preparation layer;
14. select the target-specific ASIC technology and library profile;
15. define ASIC datapath partitioning;
16. define retained-state and pending-route storage;
17. map fixed-point arithmetic;
18. map trigonometric and exponential lookup structures;
19. map hierarchical coupling;
20. map delay, thermal, gamma, coherence, and stability domains;
21. define clocking and control;
22. define reset and readiness behavior;
23. define test, debug, and trace structures;
24. synthesize against the selected technology-study profile;
25. record timing;
26. record area;
27. capture switching activity;
28. record operation-event totals;
29. record implementation electrical estimates;
30. repeat M15 vector replay;
31. repeat exact integer correlation;
32. compare target-specific execution against the M16 RTL boundary;
33. prepare physical measurement interfaces;
34. correlate measured traces with the same reference, workload, vector, device, setup, and timing identities;
35. archive source, raw data, derived data, reports, and integrity manifests.

## 59. Current Reproduction Commands

The commands in this section are executed from the `docs/` directory.

Compile the current executable semantic reference:

    python -m py_compile ../frp_prototype_v1_7_0.py

Run the current default structured execution:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Run the current full trace:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run the current 41-check self-test:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Export the current M15 benchmark matrix:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

Export the current fixed-point interface profile:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Export the current balanced ternary hardware encoding map:

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Export the current quantized reference shadow model:

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Export the current cycle-exact reference trace:

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Export the current RTL comparison vector package:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Export the current SystemVerilog testbench interface map:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Export the current synthesizable RTL reference-core map:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Export the current RTL assertion-correlation harness:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Export the current reference-equivalence report:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Export the current qualification-closure manifest:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Build and execute the integrated M16 RTL testbench:

    rm -rf /tmp/frp_m16_obj
    mkdir -p /tmp/frp_m16_obj

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_tb \
      -I../rtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      ../rtl/m16/frp_m16_tb.sv

    /tmp/frp_m16_obj/Vfrp_m16_tb

Elaborate the M16 FPGA integration top:

    verilator \
      --sv \
      --lint-only \
      --top-module frp_m16_fpga_top \
      -I../rtl/m16 \
      -I../fpga/m16 \
      ../fpga/m16/frp_m16_fpga_top.sv

Build and execute the M16 FPGA integration testbench:

    rm -rf /tmp/frp_m16_fpga_obj
    mkdir -p /tmp/frp_m16_fpga_obj

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_fpga_tb \
      -I../rtl/m16 \
      -I../fpga/m16 \
      --Mdir /tmp/frp_m16_fpga_obj \
      ../fpga/m16/frp_m16_fpga_tb.sv

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

The qualified M16 RTL terminal execution markers are:

    FRP M16 deterministic RTL testbench completed.
    CELLS=8 REQUEST_LANES=2
    ticks_recorded=16
    actual_direct_events=0
    reserved_state_events=0
    queue_overflow_events=0

The qualified M16 FPGA terminal execution markers are:

    FRP M16 FPGA integration testbench completed.
    CELLS=8 REQUEST_LANES=2
    core_ready=1
    ticks_recorded=1
    actual_direct_events=0
    reserved_state_events=0
    queue_overflow_events=0
    invariant_flags=1111111111

## 60. Current GitHub Actions Validation Context

Current repository workflow-file count:

`23`

Current root README GitHub Actions workflow-status badge count:

`2`

Current `CI.md` GitHub Actions workflow-status badge count:

`23`

The current workflow environment includes:

| Workflow layer | Runner | Toolchain |
|---|---|---|
| Python semantic and qualification workflows | `ubuntu-latest` | Python `3.12` |
| M16 RTL qualification | `ubuntu-latest` | Verilator and `g++` |
| M16 FPGA preparation qualification | `ubuntu-latest` | Verilator and `g++` |

The qualified M15 workflow is:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

The M15 workflow stages include:

1. repository checkout;
2. Python setup;
3. compilation of `frp_prototype_v1_7_0.py`;
4. generation of M15 qualification outputs;
5. deterministic vector-package regeneration;
6. comparison of deterministic vector packages;
7. validation of M15 schemas;
8. validation of kernel invariants;
9. validation of the fixed-point contract;
10. validation of reference and RTL-map equivalence;
11. deterministic vector-package integrity validation;
12. M15 architecture-document contract validation;
13. qualification-artifact upload.

The current M16 RTL workflow is:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Job name:

`M16 RTL Architecture Qualification`

Trigger:

`workflow_dispatch`

The M16 RTL workflow stages include:

1. repository checkout;
2. verification of the ten-file SystemVerilog artifact boundary;
3. verification of the five-file RTL documentation boundary;
4. verification that obsolete M16 Verilator workflows are absent;
5. preparation of isolated simulation paths;
6. installation and recording of the Verilator and `g++` toolchain;
7. recording of M16 source hashes;
8. integrated M16 RTL testbench generation;
9. executable testbench build;
10. architectural testbench execution;
11. assertion execution;
12. terminal execution-marker validation;
13. qualification-result recording;
14. repository-integrity validation;
15. qualification-evidence upload;
16. qualification-summary publication.

The current M16 FPGA preparation workflow is:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Workflow name:

`FRP M16 FPGA Preparation`

Job name:

`M16 FPGA Integration Qualification`

Trigger:

`workflow_dispatch`

The M16 FPGA preparation workflow stages include:

1. repository checkout;
2. verification of the two-file FPGA SystemVerilog artifact boundary;
3. verification of the required qualified M16 RTL dependencies;
4. preparation of isolated FPGA simulation paths;
5. installation and recording of the Verilator and `g++` toolchain;
6. recording of M16 FPGA and RTL source hashes;
7. FPGA integration-top parsing and elaboration;
8. executable FPGA integration-testbench generation;
9. FPGA integration-testbench build;
10. latch-diagnostic rejection;
11. multidriven-diagnostic rejection;
12. FPGA integration-testbench execution;
13. terminal execution-marker validation;
14. qualification-result recording;
15. repository-integrity validation;
16. qualification-evidence upload;
17. qualification-summary publication.

The M16 canonical core-domain maintenance workflow is:

`../.github/workflows/frp-m16-canonical-core-domain.yml`

Workflow name:

`FRP M16 Canonical Core Domain`

The workflow checks the M16 core domain:

`{-1, 0, 1}`

The workflow checks the M16 RTL encodings:

| Retained state | RTL encoding |
|---:|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |

The M16 reserved-cell maintenance workflow is:

`../.github/workflows/frp-m16-reserved-cell-cleanup.yml`

Workflow name:

`FRP M16 Reserved Cell Cleanup`

Its change boundary is:

`rtl/m16/*.sv`

## 61. Current Release Validation Evidence

Current release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Inherited semantic and implementation-mapping foundation:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M3 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current validation environment:

`GitHub Actions CI execution`

The inherited M15 qualification results are:

| Qualification record | Result |
|---|---:|
| self-test checks | `41 / 41 PASS` |
| deterministic vector files regenerated byte-identically | `10 / 10` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| exact deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The M16 RTL qualification records are:

| Record | Workflow run | Commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| Initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| Qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

The M16 RTL qualification rerun duration is:

`52s`

The qualified M16 RTL boundary contains ten SystemVerilog files:

1. `../rtl/m16/frp_m16_pkg.sv`;
2. `../rtl/m16/frp_m16_scheduler.sv`;
3. `../rtl/m16/frp_m16_request_lanes.sv`;
4. `../rtl/m16/frp_m16_pending_routes.sv`;
5. `../rtl/m16/frp_m16_active_neutral.sv`;
6. `../rtl/m16/frp_m16_capacity_guard.sv`;
7. `../rtl/m16/frp_m16_state_update.sv`;
8. `../rtl/m16/frp_m16_core.sv`;
9. `../rtl/m16/frp_m16_assertions.sv`;
10. `../rtl/m16/frp_m16_tb.sv`.

The qualified M16 RTL documentation boundary contains:

1. `../rtl/m16/README.md`;
2. `../rtl/m16/ARTIFACTS.md`;
3. `../rtl/m16/SIMULATION.md`;
4. `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
5. `../rtl/m16/CLOSURE.md`.

The qualified RTL testbench profile is:

| Quantity | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| recorded ticks | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The ten qualified M16 invariant flags are:

| Index | Invariant flag | Qualified result |
|---:|---|---|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` | `PASS` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` | `PASS` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` | `PASS` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` |
| `8` | `FRP_INV_NO_RESERVED_STATE` | `PASS` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` |

The integrated RTL invariant vector is:

`1111111111`

The M16 FPGA preparation qualification records are:

| Record | Workflow run | Commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---:|---:|---|
| Initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1m 7s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| Qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `36s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

The qualified M16 FPGA preparation boundary contains:

1. `../fpga/m16/frp_m16_fpga_top.sv`;
2. `../fpga/m16/frp_m16_fpga_tb.sv`;
3. `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
4. `../fpga/m16/CLOSURE.md`.

The qualified FPGA integration record includes:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- tick gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten invariant flags equal to `1`;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`.

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current overall release qualification result:

`PASS`

## 62. Current File Alignment

This ASIC mapping study is aligned with the current release-facing files:

- `../README.md`;
- `../CI.md`;
- `../CHANGELOG.md`;
- `../CITATION.cff`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../RELEASE_CHECKLIST_v1_8_0.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../MILESTONES.md`;
- `../PROJECT_STRUCTURE.md`;
- `../ROADMAP.md`;
- `../NOTICE.md`;
- `../SECURITY.md`;
- `../funding_brief.md`.

It is aligned with the inherited M15 semantic and implementation-mapping foundation:

- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`;
- `../RELEASE_CHECKLIST_v1_7_0.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

It is aligned with the FRP foundation and architecture documents:

- `./mathematical_foundation.md`;
- `./physical_foundation.md`;
- `./README.md`;
- `./core_principles.md`;
- `./resonance_computation.md`;
- `./architecture.md`;
- `./implementation_layers.md`;
- `./hardware_pathway.md`;
- `./fpga_mapping_study.md`;
- `./physical_validation_plan.md`;
- `./output_schema.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`.

It is aligned with the historical implementation-layer documents:

- `./m9_silicon_heterogeneous_architecture.md`;
- `./m10_silicon_production_tapeout_readiness.md`;
- `./m11_production_integration_external_handoff.md`;
- `./m12_external_implementation_feedback_iteration.md`;
- `./m13_production_scaling_implementation_stabilization.md`;
- `./m14_physical_implementation_correlation_production_qualification.md`.

It is aligned with the M16 architecture and qualification documents:

- `./m16_rtl_core_realization_execution_semantics.md`;
- `./m16_rtl_core_interface_contract.md`;
- `./m16_balanced_ternary_state_register_map.md`;
- `./m16_scheduler_state_rtl_realization.md`;
- `./m16_request_lane_arbitration_module.md`;
- `./m16_pending_route_register_module.md`;
- `./m16_active_neutral_transition_module.md`;
- `./m16_transition_capacity_guard_module.md`;
- `./m16_retained_state_update_module.md`;
- `./m16_invariant_assertion_set.md`;
- `./m16_m15_vector_replay_compatibility_report.md`;
- `./m16_rtl_artifact_boundary_qualification.md`;
- `./m16_external_simulator_execution_plan.md`;
- `./m16_artifact_boundary_test_stability_policy.md`;
- `./m16_qualification_index.md`;
- `./m16_qualification_manifest.md`.

It is aligned with the M16 RTL artifacts:

- `../rtl/m16/frp_m16_pkg.sv`;
- `../rtl/m16/frp_m16_scheduler.sv`;
- `../rtl/m16/frp_m16_request_lanes.sv`;
- `../rtl/m16/frp_m16_pending_routes.sv`;
- `../rtl/m16/frp_m16_active_neutral.sv`;
- `../rtl/m16/frp_m16_capacity_guard.sv`;
- `../rtl/m16/frp_m16_state_update.sv`;
- `../rtl/m16/frp_m16_core.sv`;
- `../rtl/m16/frp_m16_assertions.sv`;
- `../rtl/m16/frp_m16_tb.sv`;
- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`.

It is aligned with the M16 FPGA preparation artifacts:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

It is aligned with the current M16 workflow files:

- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`;
- `../.github/workflows/frp-m16-canonical-core-domain.yml`;
- `../.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

It is aligned with the verification and example documents:

- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../examples/README.md`;
- `../examples/resonance_convergence_example.md`.

## 63. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Fractal Resonant Coherence Processor`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M3 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current semantic and implementation-mapping foundation:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current M15 self-test result:

`41 / 41 PASS`

Current deterministic vector package:

`10 files`

Current deterministic vector regeneration:

`10 / 10 files byte-identical`

Current required semantic correlation result:

`5 / 5 = 1.0`

Current exact deterministic replay result:

`6 / 6 = 1.0`

Current exact tick-order count:

`26`

Current assertion-domain count:

`13`

Current retained-state domain:

`{-1, 0, 1}`

Current active-neutral retained-state routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Current M16 default RTL parameters:

| Parameter | Value |
|---|---:|
| `CELLS` | `16` |
| `STATE_BITS` | `2` |
| `COUNTER_BITS` | `32` |

Current qualified RTL and FPGA testbench profile:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Current M16 RTL artifact count:

`10 SystemVerilog files`

Current M16 RTL documentation count:

`5 Markdown files`

Current M16 FPGA preparation artifact count:

`2 SystemVerilog files and 2 Markdown files`

Current integrated invariant-flag count:

`10`

Current integrated invariant vector:

`1111111111`

Current direct-transition event result:

`actual_direct_events = 0`

Current reserved-state event result:

`reserved_state_events = 0`

Current queue-overflow event result:

`queue_overflow_events = 0`

Current M16 RTL qualification record:

| Field | Value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Qualified workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification record:

| Field | Value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Qualified workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current repository workflow-file count:

`23`

Current hardware-facing chain:

`qualified M15 semantic and implementation-mapping foundation → M16 RTL core realization → M16 executable architectural simulation → M16 assertion execution → target-independent FPGA integration top → executable FPGA integration testbench → target-specific ASIC mapping and correlation procedures`

Current processor chain:

`Kuramoto-Sakaguchi resonant phase dynamics → hierarchical fractal coupling → phase evolution → Kuramoto order parameter R → multiscale phase coherence → stateful delay dynamics → distributed local thermal dynamics → correlated gamma drift → nonlinear coherence compression → C(t) → P(t) → C(t) - P(t) → phase-derived ternary targets → distributed commit → active-neutral routing → retained coherent ternary state`

Current ASIC study scope:

`chip-oriented architectural partitioning, synthesis, timing, activity, power, performance, area, test, trace, and correlation against the qualified M15 semantic domain and the qualified M16 RTL execution layer`

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current qualification state:

`FRP v1.8.0 / M16 — PASS`








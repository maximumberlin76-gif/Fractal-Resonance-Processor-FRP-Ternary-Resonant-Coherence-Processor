# FRP M16 M15 Vector Replay Compatibility Report

## Status

`QUALIFIED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Purpose

This document records the compatibility boundary between the qualified M15 deterministic implementation-mapping package and the qualified M16 RTL execution layer.

M15 provides:

- the quantized hardware shadow model;
- the cycle-exact integer reference trace;
- the deterministic RTL comparison-vector package;
- the SystemVerilog testbench interface map;
- the synthesizable RTL reference-core map;
- the RTL assertion correlation harness;
- the reference RTL equivalence report;
- the qualification closure manifest.

M16 provides:

- the executable SystemVerilog retained-state core;
- deterministic scheduler execution;
- deterministic request-lane arbitration;
- retained pending-route execution;
- active-neutral transition routing;
- transition-capacity enforcement;
- retained-state writeback;
- executable architectural assertions;
- target-independent FPGA integration qualification.

The executable Python semantic reference remains:

`frp_prototype_v1_7_0.py`

## Qualification Evidence Boundary

The compatibility record contains three qualified evidence layers.

| Evidence layer | Workflow | Qualified result |
|---|---|:---:|
| M15 deterministic implementation mapping and replay | `FRP M15 Implementation Mapping and Qualification Closure` | `PASS` |
| M16 executable RTL realization | `FRP M16 RTL Artifact Boundary` | `PASS` |
| M16 target-independent FPGA integration | `FRP M16 FPGA Preparation` | `PASS` |

The M15 workflow performs:

- deterministic artifact generation;
- two-package vector generation;
- byte-identical vector-directory comparison;
- schema validation;
- semantic correlation validation;
- exact quantized-shadow deterministic replay validation;
- qualification-closure validation.

The M16 RTL workflow performs:

- SystemVerilog parsing;
- module elaboration;
- executable testbench generation;
- deterministic architectural simulation;
- assertion execution;
- terminal marker validation;
- repository-integrity validation.

The M16 FPGA preparation workflow performs:

- FPGA integration-top elaboration;
- executable FPGA testbench generation;
- reset-control qualification;
- execution-input gating qualification;
- scheduler and request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten integrated invariant checks.

## Compatibility Chain

The qualified compatibility chain is:

`M15 floating semantic reference`

→ `M15 quantized hardware shadow`

→ `M15 cycle-exact integer trace`

→ `M15 deterministic RTL comparison vectors`

→ `M15 exact deterministic replay record`

→ `M16 executable RTL execution boundary`

→ `M16 architectural assertion boundary`

→ `M16 target-independent FPGA preparation boundary`

M15 remains the qualified semantic and implementation-mapping foundation.

M16 realizes the qualified retained-state execution contract as an executable RTL and FPGA preparation layer.

## Compatibility Scope

The M15-to-M16 compatibility boundary covers:

- canonical balanced ternary encoding;
- active neutral state `0`;
- scheduler modes and scheduler-state counts;
- request-lane profiles;
- deterministic request ordering;
- tick-separated opposite-polarity routing;
- retained pending-route polarity;
- pending completion only from `0`;
- transition-capacity enforcement;
- retained-state writeback;
- direct-transition event relations;
- reserved-state event relations;
- queue-overflow event relations;
- integrated invariant relations;
- executable assertion results.

The phase, thermal, gamma, topology, coherence, `C(t)`, and `P(t)` domains remain part of the qualified M15 semantic and implementation-mapping package.

The M16 RTL core consumes phase-derived balanced ternary targets at its execution interface.

## Canonical Balanced Ternary Compatibility

The M15 and M16 retained processor-state domain is:

`{-1, 0, 1}`

The canonical hardware encoding is:

| Retained state | Encoding | Compatibility relation |
|---:|:---:|---|
| `-1` | `2'b11` | identical M15 and M16 negative-state encoding |
| `0` | `2'b00` | identical M15 and M16 active-neutral encoding |
| `1` | `2'b01` | identical M15 and M16 positive-state encoding |
| reserved | `2'b10` | invalid retained-state encoding |

Required routed transitions are:

`-1 → 0 → 1`

`1 → 0 → -1`

Forbidden direct retained-state transitions are:

`-1 → 1`

`1 → -1`

Qualified global relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## M15 Qualification Source

Workflow:

`FRP M15 Implementation Mapping and Qualification Closure`

Workflow file:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Qualified workflow run:

`#1`

Python version used by the workflow:

`3.12`

Executable reference:

`frp_prototype_v1_7_0.py`

M15 milestone identifier:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

## M15 Qualification Record

| Qualification relation | Result |
|---|---:|
| self-test checks | `41 / 41 PASS` |
| deterministic vector files byte-identical | `10 / 10` |
| required semantic correlation matches equal to `1.0` | `5 / 5` |
| deterministic replay matches equal to `1.0` | `6 / 6` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

M15 qualification status:

`PASS`

## M15 Structured Schema Boundary

The structured output schema remains:

`frp.structured_output.v1.7.0`

The benchmark-matrix schema remains:

`frp.m3.benchmark_matrix.v1.7.0`

The M15 implementation-mapping schemas are:

| Artifact layer | Schema |
|---|---|
| fixed-point interface profile | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| balanced ternary hardware encoding map | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| quantized reference shadow model | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| cycle-exact reference trace | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| RTL comparison vector package | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| SystemVerilog testbench interface map | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| synthesizable RTL reference core | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| RTL assertion correlation harness | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| reference RTL equivalence report | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| qualification closure manifest | `frp.m15.qualification_closure_manifest.v1.7.0` |

## M15 Hardware-Facing Interface Profile

The qualified M15 SystemVerilog interface map records:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The verification stimulus interface includes:

`gamma_noise_target_q`

The qualified scaling profiles are:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---:|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

The request-lane relation is:

`REQUEST_LANES = max_changes`

The inherited transition fraction is:

`transition_fraction = 0.25`

## M15 Deterministic Vector Package

Vector-package schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

The M15 workflow generates two independent vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

The workflow compares the directories with:

`diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b`

Qualified comparison result:

`10 / 10 deterministic vector files byte-identical`

The deterministic vector package contains:

| Vector file | Package role |
|---|---|
| `frp_m15_kernel_vectors.vec` | kernel comparison vectors |
| `frp_m15_pending_routes.trace` | pending-route trace |
| `frp_m15_scheduler_free_vectors.vec` | `free` scheduler vectors |
| `frp_m15_scheduler_7_1_vectors.vec` | `7/1` scheduler vectors |
| `frp_m15_scheduler_1_7_vectors.vec` | `1/7` scheduler vectors |
| `frp_m15_full_correlation_vectors.vec` | full correlation vectors |
| `frp_m15_cell_trace.vec` | per-cell trace |
| `frp_m15_reference_preload.json` | deterministic reference preload |
| `frp_m15_trig_lut_q30.vec` | quantized trigonometric lookup table |
| `frp_m15_sha256_manifest.json` | vector-package SHA-256 manifest |

Manifest file count:

`10`

The workflow validates:

- exactly ten files in each generated package;
- presence of `frp_m15_sha256_manifest.json`;
- SHA-256 equality for every manifest-bound file;
- byte-identical equality between package A and package B.

Deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

## M15 Reference-to-RTL Equivalence Record

Reference-equivalence schema:

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

The qualified M15 report contains two comparison levels:

1. floating semantic reference to quantized hardware shadow correlation;
2. exact quantized-shadow deterministic replay.

## Floating Reference to Quantized Shadow Correlation

The required semantic correlation fields are:

| Correlation field | Recorded value |
|---|---:|
| `state_sequence_match` | `1.0` |
| `scheduler_sequence_match` | `1.0` |
| `neutral_route_sequence_match` | `1.0` |
| `C_minus_P_sign_match` | `1.0` |
| `boundary_order_match` | `1.0` |

Qualified semantic correlation result:

`5 / 5 required semantic correlation matches = 1.0`

## Numeric Correlation Bounds

The M15 workflow validates bounded numeric correlation between the floating semantic reference and quantized hardware shadow.

| Field | Recorded maximum error | Required maximum |
|---|---:|---:|
| phase | `0.010957534368146086` | `0.02` |
| frequency | `0.000022803546471550362` | `0.0001` |
| heat | `0.00004701887369061575` | `0.001` |
| gamma | `0.0` | `0.000001` |
| coherence | `0.002228678310501553` | `0.01` |
| `C` | `0.0007545911459079235` | `0.01` |
| `P` | `0.000014974864477032557` | `0.001` |
| `C_minus_P` | `0.0007535557740776522` | `0.01` |

Numeric correlation result:

`PASS`

## M15 Cycle-Exact Reference Trace

Cycle-exact trace schema:

`frp.m15.cycle_exact_reference_trace.v1.7.0`

Trace row count:

`64`

The workflow validates:

- exactly `64` trace rows;
- `16` gamma-noise target values in every trace row;
- `reserved_state_events = 0` in every trace row;
- `actual_direct_events = 0` in every trace row.

The exported cycle-exact trace summary records:

| Field | Recorded value |
|---|---:|
| `cells` | `16` |
| `hierarchy_depth` | `4` |
| `request_lanes` | `4` |
| `ticks_recorded` | `64` |
| scheduler | `7/1` |
| balance ticks | `56` |
| commit ticks | `8` |
| `scheduler_counts_valid` | `True` |
| `transition_fraction` | `0.25` |
| `switch_load_peak` | `0.25` |
| `requested_direct_events` | `9` |
| `prevented_direct_events` | `14` |
| `neutral_routed_events` | `14` |
| `neutralized_conflicts` | `14` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `pending_route_count_final` | `0` |
| `balanced_ternary_state_domain` | `True` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Cycle-exact trace qualification result:

`PASS`

## M15 Assertion Correlation Harness

Assertion-harness schema:

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

Assertion count:

`13`

Exact comparison rule:

`actual integer field == expected integer field`

The qualified M15 assertion contract contains:

1. `valid balanced ternary encoding`;
2. `reserved-state exclusion`;
3. `direct polarity transition exclusion`;
4. `active neutral route insertion`;
5. `target application after ready tick`;
6. `actual_direct_events = 0`;
7. `transition-limit enforcement`;
8. `scheduler sequence`;
9. `scheduler count consistency`;
10. `phase topology fixed-point normalization`;
11. `thermal topology fixed-point normalization`;
12. `deterministic trace tick count`;
13. `exact cycle-output match`.

M15 assertion correlation result:

`PASS`

## M15 Exact Deterministic Replay Record

The exact deterministic replay section of the reference-equivalence report records:

| Replay field | Recorded value |
|---|---:|
| `shadow_replay_state_match` | `1.0` |
| `shadow_replay_scheduler_match` | `1.0` |
| `shadow_replay_pending_route_match` | `1.0` |
| `shadow_replay_counter_match` | `1.0` |
| `shadow_replay_trace_match` | `1.0` |
| `shadow_replay_cell_trace_match` | `1.0` |

Qualified deterministic replay result:

`6 / 6 deterministic replay matches = 1.0`

Reference trace digest:

`06be197a6f7620796daad6420091e21392295cb0e182b394da2d9990324415be`

Cell trace digest:

`ba7d5f5a5f45d1c6808a0d4c7d7f612916bb2e2c4d33faf5e182810d704ad544`

Deterministic replay qualification result:

`PASS`

## M15 Qualification Closure Manifest

Qualification-closure schema:

`frp.m15.qualification_closure_manifest.v1.7.0`

The closure manifest records:

- status `PASS`;
- all closure checks equal to `True`;
- exactly ten M15 artifact layers.

Qualification closure result:

`PASS`

## M16 RTL Compatibility Boundary

The qualified M16 RTL execution boundary is located under:

`rtl/m16/`

The compatibility-relevant RTL artifacts are:

| M16 artifact | Compatibility function |
|---|---|
| `frp_m16_pkg.sv` | canonical ternary encoding, scheduler types, transition classes, and invariant indexes |
| `frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` scheduler execution |
| `frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `frp_m16_pending_routes.sv` | retained pending-polarity creation, retention, completion, and clearing |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | transition-capacity admission |
| `frp_m16_state_update.sv` | retained balanced ternary writeback |
| `frp_m16_core.sv` | integrated execution, telemetry, and invariant aggregation |
| `frp_m16_assertions.sv` | executable architectural assertions |
| `frp_m16_tb.sv` | deterministic architectural qualification testbench |

Qualified M16 testbench profile:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

This profile is included in the qualified M15 scaling set:

`8 cells → 2 request lanes → 16-bit packed retained-state bank`

## Scheduler Compatibility Record

The M15 and M16 qualification records contain the following scheduler profiles:

| Scheduler mode | Qualified execution relation | M16 result |
|---|---|:---:|
| `free` | `16 ticks → free = 16` | `PASS` |
| `7/1` | `64 ticks → balance = 56, commit = 8` | `PASS` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` | `PASS` |

Required count relation:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

M16 scheduler-count assertion result:

`PASS`

## Retained-State Execution Compatibility Record

| Execution relation | M15 qualified contract | M16 executable result |
|---|:---:|:---:|
| retained-state domain is `{-1, 0, 1}` | `PASS` | `PASS` |
| active neutral state is `0` | `PASS` | `PASS` |
| reserved encoding `2'b10` is excluded | `PASS` | `PASS` |
| direct `-1 → 1` writeback is forbidden | `PASS` | `PASS` |
| direct `1 → -1` writeback is forbidden | `PASS` | `PASS` |
| `-1 → 0 → 1` uses separate eligible ticks | `PASS` | `PASS` |
| `1 → 0 → -1` uses separate eligible ticks | `PASS` | `PASS` |
| pending target polarity is retained | `PASS` | `PASS` |
| pending completion starts from retained state `0` | `PASS` | `PASS` |
| capacity rejection preserves retained state | `PASS` | `PASS` |
| capacity rejection preserves pending route | `PASS` | `PASS` |
| accepted changes remain within request-lane capacity | `PASS` | `PASS` |
| switch-load numerator equals accepted changes | `PASS` | `PASS` |
| actual direct events remain zero | `PASS` | `PASS` |
| reserved-state events remain zero | `PASS` | `PASS` |
| queue-overflow events remain zero | `PASS` | `PASS` |

## Interface and Evidence Correlation

| Compatibility class | M15 evidence | M16 executable evidence |
|---|---|---|
| state encoding | balanced ternary hardware encoding map | `frp_m16_pkg.sv` domain helpers and state constants |
| scheduler | cycle-exact trace and scheduler vector files | scheduler module, testbench sequences, and counter assertions |
| request lanes | SystemVerilog interface map and kernel vectors | deterministic request-lane module and capacity assertions |
| pending routes | pending-route trace and cell trace | retained pending-route module and temporal assertions |
| active neutral | state and neutral-route sequence correlation | transition module, state-update module, and route assertions |
| capacity | request-lane profile and transition-limit assertion | capacity guard, accepted-change count, and switch-load assertions |
| retained state | state replay match and full correlation vectors | state-update module and retained-state assertions |
| event counters | counter replay match | public M16 event totals and zero-event assertions |
| invariant status | qualification closure checks | ten integrated invariant flags |
| deterministic execution | trace and cell-trace digests | deterministic RTL terminal markers and source-hash record |

Compatibility correlation result:

`PASS`

## M16 RTL Qualification Record

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Trigger:

`workflow_dispatch`

### Initial Closure Record

| Field | Value |
|---|---|
| workflow run | `#82` |
| repository commit | `a68a2af` |
| branch | `main` |
| workflow result | `SUCCESS` |
| qualification artifact count | `1` |
| qualification result | `PASS` |

### Synchronized Qualification Record

| Field | Value |
|---|---|
| workflow run | `#84` |
| qualified source commit | `ede53cf` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `52s` |
| qualification artifact count | `1` |

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## M16 RTL Execution Qualification

The RTL workflow qualifies:

- ten SystemVerilog artifacts;
- five RTL documentation artifacts;
- Verilator SystemVerilog parsing;
- module elaboration;
- executable testbench generation;
- deterministic architectural simulation;
- architectural assertion execution;
- terminal marker validation;
- source-hash generation;
- repository-integrity validation;
- qualification evidence generation.

Top-level simulation module:

`frp_m16_tb`

Integrated execution core:

`frp_m16_core`

Assertion module:

`frp_m16_assertions`

RTL execution result:

`PASS`

## M16 RTL Scheduler Record

| Scheduler mode | Executed ticks | Recorded state counts | Result |
|---|---:|---|:---:|
| `free` | `16` | `free = 16` | `PASS` |
| `7/1` | `64` | `balance = 56, commit = 8` | `PASS` |
| `1/7` | `16` | `excite = 2, neutralize = 14` | `PASS` |

Scheduler counter-clear behavior:

`PASS`

Scheduler count-sum relation:

`PASS`

## M16 RTL Active-Neutral and Pending-Route Record

| Qualified relation | Result |
|---|:---:|
| active neutral `0` executes as the intermediate retained state | `PASS` |
| direct `-1 → 1` retained-state writeback is absent | `PASS` |
| direct `1 → -1` retained-state writeback is absent | `PASS` |
| `-1 → 0 → 1` executes on separate eligible ticks | `PASS` |
| `1 → 0 → -1` executes on separate eligible ticks | `PASS` |
| exact requested polarity is retained | `PASS` |
| pending-route cell ownership is retained | `PASS` |
| same-cell pending overwrite is prevented | `PASS` |
| scheduler deferral preserves the pending route | `PASS` |
| capacity deferral preserves the pending route | `PASS` |
| completion requires retained state `0` | `PASS` |
| accepted completion clears the pending route | `PASS` |
| pending-route overflow is absent | `PASS` |

## M16 RTL Request and Capacity Record

Deterministic arbitration order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

| Qualified relation | Result |
|---|:---:|
| canonical request-target validation | `PASS` |
| valid cell-index enforcement | `PASS` |
| one accepted request per cell per tick | `PASS` |
| earlier accepted-lane ownership | `PASS` |
| pending-route ownership priority | `PASS` |
| scheduler transition eligibility | `PASS` |
| acceptance and rejection separation | `PASS` |
| bounded accepted changes | `PASS` |
| `capacity_remaining = REQUEST_LANES - accepted_changes` | `PASS` |
| `capacity_exhausted = (accepted_changes = REQUEST_LANES)` | `PASS` |
| `switch_load_numerator = accepted_changes` | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

Qualified eight-cell capacity event:

| Signal | Recorded value |
|---|---:|
| `accepted_changes` | `2` |
| `capacity_remaining` | `0` |
| `capacity_exhausted` | `1` |
| `switch_load_numerator` | `2` |

## M16 RTL Retained-State and Assertion Record

| Qualified relation | Result |
|---|:---:|
| reset initializes retained state to `0` | `PASS` |
| disabled ticks retain state | `PASS` |
| state-changing writeback requires capacity | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| opposite polarity commits the first leg through `0` | `PASS` |
| pending completion commits from `0` | `PASS` |
| capacity rejection preserves retained state | `PASS` |
| reserved encoding is not committed | `PASS` |
| direct opposite-polarity writeback is absent | `PASS` |
| retained-state domain assertion | `PASS` |
| pending-route domain assertion | `PASS` |
| state-change authorization assertion | `PASS` |
| active-neutral first-leg assertion | `PASS` |
| retained pending-polarity assertion | `PASS` |
| pending-route deferral assertion | `PASS` |
| scheduler-state counter assertions | `PASS` |
| transition-capacity assertions | `PASS` |
| integrated invariant assertions | `PASS` |

## M16 RTL Integrated Invariant Record

| Invariant | Result |
|---|:---:|
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

## M16 RTL Terminal Evidence

Terminal marker:

`FRP M16 deterministic RTL testbench completed.`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal marker validation:

`PASS`

## M16 FPGA Preparation Qualification Record

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

### Initial Closure Record

| Field | Value |
|---|---|
| workflow run | `#1` |
| qualified repository commit | `326b69e` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `1m 7s` |
| qualification artifact count | `1` |
| qualification result | `PASS` |

### Synchronized Qualification Record

| Field | Value |
|---|---|
| workflow run | `#2` |
| qualified repository commit | `ede53cf` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `36s` |
| qualification artifact count | `1` |

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## M16 FPGA Compatibility Record

| Qualified relation | Result |
|---|:---:|
| FPGA integration-top elaboration | `PASS` |
| executable FPGA testbench generation | `PASS` |
| asynchronous external reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| tick gating before readiness | `PASS` |
| counter-clear gating before readiness | `PASS` |
| request-valid gating before readiness | `PASS` |
| scheduler-mode propagation | `PASS` |
| request-interface propagation | `PASS` |
| active-neutral first-leg execution | `PASS` |
| retained pending-route completion | `PASS` |
| all ten invariant flags | `PASS` |

FPGA terminal evidence:

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

The FPGA preparation qualification is target-independent.

## Workflow Evidence Correlation

| Workflow layer | Generated evidence |
|---|---|
| M15 qualification | structured outputs, ten implementation-mapping exports, two deterministic vector directories, scaling outputs, schema checks, equivalence checks, and closure manifest |
| M16 RTL qualification | SystemVerilog source hashes, Verilator build log, architectural execution log, and qualification result record |
| M16 FPGA preparation | FPGA and RTL source hashes, top-elaboration log, testbench build log, execution log, and qualification result record |

The M15 deterministic vector comparison is recorded by the M15 workflow.

The M16 executable RTL and FPGA preparation results are recorded by the two M16 workflows.

## Final Compatibility Record

| Compatibility boundary | Result |
|---|:---:|
| canonical balanced ternary encoding | `PASS` |
| active neutral state `0` | `PASS` |
| scheduler profile correlation | `PASS` |
| request-lane profile correlation | `PASS` |
| deterministic request ordering | `PASS` |
| retained pending-route polarity | `PASS` |
| tick-separated opposite-polarity routing | `PASS` |
| transition-capacity correlation | `PASS` |
| retained-state writeback correlation | `PASS` |
| direct-event zero relation | `PASS` |
| reserved-state zero relation | `PASS` |
| queue-overflow zero relation | `PASS` |
| integrated invariant correlation | `PASS` |
| executable assertion correlation | `PASS` |
| M15 deterministic vector integrity | `PASS` |
| M15 exact deterministic replay | `PASS` |
| M16 RTL execution qualification | `PASS` |
| M16 FPGA preparation qualification | `PASS` |

Final compatibility status:

`PASS`

## Qualification State

M15 qualification state:

`PASS`

M16 RTL execution-layer state:

`M16 RTL EXECUTION LAYER CLOSED`

M16 FPGA preparation-layer state:

`M16 FPGA PREPARATION LAYER CLOSED`

## Author

Maksym Marnov


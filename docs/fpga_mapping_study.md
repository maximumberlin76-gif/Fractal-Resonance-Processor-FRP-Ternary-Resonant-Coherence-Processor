# FPGA Mapping Study — Fractal Resonance Processor (FRP)

**Ternary Fractal Resonant Coherence Processor — FPGA Mapping and Execution Correlation Study**

This document defines the current FPGA-oriented mapping, integration, and execution-correlation study for the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

Current hardware pathway:

`./hardware_pathway.md`

Current test report:

`../TEST_REPORT_v1_8_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`../RELEASE_NOTES_v1_8_0.md`

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Current published validation result:

`PASS`

Inherited M15 self-test result:

`41/41 PASS`

Current M16 RTL qualification result:

`PASS`

Current M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation qualification result:

`PASS`

Current M16 FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## 1. Purpose

The purpose of this document is to define how the qualified FRP v1.7.0 processor semantics and M15 deterministic implementation-mapping package are carried through the executable FRP v1.8.0 / M16 RTL core and target-independent FPGA preparation boundary.

The current FPGA study covers:

- balanced ternary state encoding;
- active neutral transition routing;
- pending neutral-route storage;
- distributed commit capacity;
- request-lane processing;
- scheduler execution;
- fixed-point numeric representation;
- Kuramoto-Sakaguchi resonant phase dynamics;
- hierarchical fractal coupling;
- stateful delay dynamics;
- distributed local thermal dynamics;
- correlated local gamma drift;
- nonlinear coherence compression;
- multiscale phase coherence;
- operational coherence `C(t)`;
- destabilizing load `P(t)`;
- dynamic stability `C(t) - P(t)`;
- phase-derived ternary targets;
- cycle-exact integer traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- executable M16 RTL core realization;
- target-independent FPGA integration top;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating before readiness;
- FPGA resource mapping;
- timing-correlation planning;
- trace capture;
- cycle-exact comparison against the inherited M15 reference domain;
- integrated invariant propagation;
- RTL qualification closure;
- FPGA preparation qualification closure.

The current study uses the qualified M15 package as the semantic and implementation-mapping source domain.

The current executable hardware-facing boundary is:

`M15 qualified semantic reference`

↓

`M16 executable SystemVerilog RTL core`

↓

`M16 target-independent FPGA preparation boundary`

## 2. Current Reference Position

The current validated release layer is:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

The qualified executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The current implementation chain is:

`M15 floating semantic reference`

↓

`M15 hardware-facing numeric profile`

↓

`M15 balanced ternary hardware encoding`

↓

`M15 stateful quantized hardware shadow`

↓

`M15 cycle-exact integer golden trace`

↓

`M15 deterministic RTL comparison vectors`

↓

`M15 SystemVerilog interface mapping`

↓

`M15 synthesizable RTL reference-core mapping`

↓

`M15 RTL assertion correlation`

↓

`M15 reference equivalence`

↓

`M15 qualification closure PASS`

↓

`M16 synthesizable RTL core realization`

↓

`M16 scheduler-state execution`

↓

`M16 deterministic request-lane arbitration`

↓

`M16 retained pending-route execution`

↓

`M16 active-neutral transition generation`

↓

`M16 distributed transition-capacity admission`

↓

`M16 retained-state writeback`

↓

`M16 architectural telemetry`

↓

`M16 integrated invariant evaluation`

↓

`M16 RTL execution-layer closure`

↓

`M16 target-independent FPGA integration top`

↓

`M16 FPGA reset synchronization and readiness gating`

↓

`M16 FPGA integration testbench`

↓

`M16 FPGA preparation-layer closure`

The current FPGA preparation boundary contains no vendor-specific primitive.

The target-independent FPGA top can be connected to a target-specific layer containing:

- clock-generation resources;
- pin assignments;
- device constraints;
- physical timing constraints;
- target-specific reset sources;
- board-level input and output routing.

The closed M16 retained-state execution semantics remain inside:

`frp_m16_core`

## 3. FPGA Mapping Objective

The primary FPGA mapping objective is:

`carry the qualified FRP retained-state execution contract into a target-independent programmable-hardware integration boundary while preserving state, scheduler, route, capacity, fixed-point, trace, telemetry, and invariant correlation`

Current FPGA mapping subjects:

- map the canonical two-bit balanced ternary encoding;
- map active-neutral route control;
- map retained pending neutral routes;
- map deterministic request lanes;
- map transition-fraction capacity;
- map scheduler execution;
- map retained-state writeback;
- map architectural counters;
- map direct-transition telemetry;
- map reserved-state telemetry;
- map queue-overflow telemetry;
- map fixed-point phase and scalar domains;
- map the 4096-entry trigonometric lookup table;
- map hierarchical coupling;
- map stateful delay dynamics;
- map distributed thermal fields;
- map correlated gamma dynamics;
- map multiscale coherence;
- map `C(t)`, `P(t)`, and `C_minus_P`;
- preserve deterministic M15 vector compatibility;
- capture post-tick RTL and FPGA outputs;
- compare integer outputs against the M15 golden domain;
- preserve cycle-exact correlation;
- expose all ten integrated M16 invariant flags;
- qualify the target-independent FPGA integration boundary;
- preserve the source boundary for later target-specific synthesis, utilization, timing, and implementation evidence.

The current M16 FPGA preparation boundary provides:

- `frp_m16_fpga_top`;
- `frp_m16_fpga_tb`;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick-enable gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- scheduler-mode propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- transition-capacity correlation;
- retained-state writeback;
- integrated invariant propagation.

Current FPGA preparation result:

`PASS`

## 4. Current Validated Invariants for FPGA Study

The FPGA-oriented study inherits the qualified M15 processor invariants:

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

The current M16 executable RTL boundary exposes ten integrated invariant flags:

| M16 invariant flag | Required Result |
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

Qualified terminal invariant vector:

`invariant_flags = 1111111111`

Current FPGA integration conditions:

| Integration condition | Required Result |
|---|---|
| asynchronous external reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| tick blocking before `core_ready` | `PASS` |
| counter-clear blocking before `core_ready` | `PASS` |
| request blocking before `core_ready` | `PASS` |
| scheduler-mode propagation | `PASS` |
| request-interface propagation | `PASS` |
| active-neutral first-leg execution | `PASS` |
| retained pending-route completion | `PASS` |
| integrated invariant propagation | `PASS` |

These inherited M15 invariants and current M16 executable relations form the FPGA comparison and preparation contract.

## 5. Current Source Hierarchy for FPGA Correlation

The FPGA study uses the following source hierarchy:

1. `../frp_prototype_v1_7_0.py` — qualified executable semantic reference and inherited M15 artifact generator;
2. `./m15_implementation_mapping_domain_interface_qualification_closure.md` — inherited M15 implementation-mapping architecture;
3. `./m16_rtl_core_realization_execution_semantics.md` — current M16 RTL realization and execution-semantics architecture;
4. `../TEST_REPORT_v1_8_0.md` — current test and qualification evidence;
5. `../FRP_VALIDATION_INDEX_v1_8_0.md` — current validation registry;
6. `../RELEASE_NOTES_v1_8_0.md` — current release evidence;
7. inherited M15 fixed-point, encoding, shadow, trace, vector, interface, RTL-map, assertion, equivalence, and closure artifacts;
8. `../rtl/m16/` — current synthesizable RTL source boundary;
9. `../rtl/m16/SIMULATION_TRANSCRIPT.md` — current RTL execution evidence;
10. `../rtl/m16/CLOSURE.md` — current RTL qualification closure;
11. `../fpga/m16/frp_m16_fpga_top.sv` — current target-independent FPGA integration top;
12. `../fpga/m16/frp_m16_fpga_tb.sv` — current FPGA integration testbench;
13. `../fpga/m16/SIMULATION_TRANSCRIPT.md` — current FPGA preparation execution evidence;
14. `../fpga/m16/CLOSURE.md` — current FPGA preparation qualification closure;
15. `./hardware_pathway.md` — current overall hardware-facing path;
16. target-specific synthesis, timing, utilization, trace, and implementation outputs generated by a later device-specific implementation layer.

The inherited M15 vector and trace domain provides the direct integer comparison source for M16 RTL and FPGA replay.

The M16 RTL and FPGA preparation records provide the current executable hardware-facing qualification evidence.

## 6. Balanced Ternary State Encoding

FRP uses the balanced ternary state and retained-result domain:

`{-1, 0, 1}`

Current computational roles:

| State | Role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

Current two-bit hardware encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Current packed state-vector relation:

`2 bits per cell`

Current default configured width:

`16 cells × 2 bits = 32 bits`

Current cell packing relation:

`cell i → [2i+1:2i]`

Current cell-zero relation:

`cell 0 → [1:0]`

Current FPGA mapping criteria:

- deterministic encode and decode;
- reserved-state monitoring;
- packed-vector replay;
- direct comparison against inherited M15 trace fields;
- direct correlation with M16 retained-state outputs;
- compatibility with request targets;
- compatibility with pending-route state;
- compatibility with FPGA trace capture.

Current M16 reserved-state invariant:

`FRP_INV_NO_RESERVED_STATE = 1`

## 7. Active-Neutral Transition Routing

Opposite-polarity execution follows the mandatory routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

The current M16 RTL route path maps:

- current ternary state;
- requested target state;
- polarity-conflict detection;
- neutral insertion;
- pending-route allocation;
- earliest-ready tick;
- ready-route processing;
- target completion;
- route counters;
- transition-valid output;
- transition-cell output;
- transition-target output.

Current M16 route modules:

- `../rtl/m16/frp_m16_active_neutral.sv`;
- `../rtl/m16/frp_m16_pending_routes.sv`.

Current route counters include:

- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`;
- `actual_direct_events`.

Current route invariant:

`actual_direct_events = 0`

Current integrated M16 route flags:

`FRP_INV_PENDING_POLARITY_VALID = 1`

`FRP_INV_ACTIVE_NEUTRAL_VALID = 1`

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS = 1`

## 8. Pending Neutral-Route Storage

The inherited M15 execution model and current M16 RTL execution preserve pending routes across ticks.

Each pending route retains:

- cell index;
- target polarity;
- earliest ready tick;
- validity state.

Inherited default queue capacity:

`16`

Qualified queue result:

`queue_overflow_events = 0`

Current M16 pending-route implementation:

`../rtl/m16/frp_m16_pending_routes.sv`

Hardware storage subjects include:

- distributed registers;
- indexed pending-route table;
- valid-bit state;
- cell-index field;
- target-state field;
- ready-tick field;
- deterministic route-selection state.

The implementation preserves:

- deterministic allocation order;
- deterministic ready-route processing order;
- route persistence across clock edges;
- exact pending-route count;
- exact queue-overflow counter behavior;
- target-polarity validity;
- tick-separated route completion.

Current integrated M16 pending-route flags:

`FRP_INV_PENDING_POLARITY_VALID = 1`

`FRP_INV_NO_QUEUE_OVERFLOW = 1`

## 9. Distributed Commit and Request-Lane Mapping

Current default transition fraction:

`0.25`

Current commit-capacity relation:

`max_changes = max(1, round(cells × transition_fraction))`

Current request-lane relation:

`REQUEST_LANES = max_changes`

Current validated scaling profiles:

| Cells | Hierarchy Depth | Request Lanes | Packed State Width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Current request-lane order:

`ascending lane index`

Current default request interface:

- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Current default request-lane profile:

`4 lanes`

Current M16 request-lane and commit path includes:

- request-lane input mapping;
- ascending lane-order arbitration;
- request-valid evaluation;
- cell-index validation;
- target-state validation;
- transition-capacity counter;
- state-change counter;
- active-neutral route issue logic;
- retained pending-route priority;
- packed retained-state update path;
- switch-load output;
- request-lane invariant evaluation;
- transition-capacity invariant evaluation.

Current M16 request and capacity modules:

- `../rtl/m16/frp_m16_request_lanes.sv`;
- `../rtl/m16/frp_m16_capacity_guard.sv`;
- `../rtl/m16/frp_m16_state_update.sv`.

Current integrated M16 request and capacity flags:

`FRP_INV_REQUEST_LANE_ORDER_VALID = 1`

`FRP_INV_TRANSITION_CAPACITY_VALID = 1`

`FRP_INV_STATE_UPDATE_VALID = 1`

## 10. Scheduler Modes

Current scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current validated 16-tick profiles:

| Scheduler | Counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Inherited M15 default 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

Current scheduler-mode encoding:

| Code | Mode |
|---:|---|
| `0` | `free` |
| `1` | `7/1` |
| `2` | `1/7` |

Current scheduler-state encoding:

| Code | State |
|---:|---|
| `0` | `free` |
| `1` | `balance` |
| `2` | `commit` |
| `3` | `excite` |
| `4` | `neutralize` |

Inherited M15 scheduler phase push:

| Scheduler State | Phase Push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all remaining states | `0.003` |

Current M16 scheduler module:

`../rtl/m16/frp_m16_scheduler.sv`

The executable M16 scheduler realizes:

- scheduler-mode registration;
- modulo-8 period position;
- deterministic scheduler-state decoding;
- commit and neutralize enable generation;
- per-state scheduler counters;
- total recorded-tick counter;
- scheduler-state validity;
- scheduler-count validity.

Current M16 scheduler count relation:

`sum(scheduler_counts) = ticks_recorded`

The inherited phase-push mapping remains part of the M15 hardware-facing resonant-datapath contract.

## 11. State and Interface Register Mapping

The inherited M15 hardware-facing domain carries state through explicit execution and comparison interfaces.

FPGA register groups can include:

| Register Group | Purpose |
|---|---|
| ternary state registers | current encoded state per cell |
| packed state register | cycle-exact vector comparison |
| pending-route registers | target and ready-tick retention |
| scheduler registers | mode, state, cycle count |
| phase registers | `PHASE_U32` state |
| frequency registers | base, target, and current frequency |
| thermal registers | local heat and overload |
| gamma registers | target, correlation state, effective gamma |
| coherence registers | multiscale and global phase-order values |
| stability registers | `C`, `P`, and `C_minus_P` |
| route counters | requested, prevented, routed, conflict, actual |
| trace registers | post-tick comparison outputs |

The inherited M15 default SystemVerilog interface parameters are:

`NUM_CELLS = 16`

`HIERARCHY_DEPTH = 4`

`REQUEST_LANES = 4`

`CELL_ID_WIDTH = 4`

`STATE_VECTOR_WIDTH = 32`

`SCALAR_WIDTH = 32`

`PHASE_WIDTH = 32`

The current qualified M16 RTL and FPGA preparation configuration is:

| Parameter | Qualified Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `CELL_INDEX_BITS` | `3` |
| `COUNTER_BITS` | `32` |
| packed retained-state width | `16 bits` |

The current M16 FPGA boundary exposes:

- retained ternary state;
- retained pending-route state;
- scheduler mode and state;
- scheduler-state counters;
- request acceptance and rejection;
- accepted-cell masks;
- neutral-routed-cell masks;
- accepted-change masks;
- architectural route counters;
- integrated invariant flags;
- `core_ready`.

Current M16 FPGA integration top:

`../fpga/m16/frp_m16_fpga_top.sv`

## 12. Stateful Delay Dynamics Mapping

The inherited M15 FRP delay domain uses three frequency states per cell:

- base frequency;
- target frequency;
- current frequency.

Current qualified frequency-target relation:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

Current qualified delayed response:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Current default delay coefficient:

`delay_alpha = 0.30`

The remaining frequency lag feeds:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

FPGA mapping blocks include:

- base-frequency register;
- target-frequency datapath;
- current-frequency register;
- frequency-difference datapath;
- delay-coefficient multiplier;
- lag register;
- cycle-exact output field.

Inherited M15 mapped RTL domain:

`frp_m15_delay_dynamics.sv`

This name remains part of the inherited M15 synthesizable RTL reference-core mapping.

Within FRP v1.8.0 / M16, the delay-dynamics domain remains part of the qualified M15 resonant-datapath mapping inherited by the current executable retained-state RTL boundary.

## 13. Hardware-Facing Numeric Profile

Inherited M15 primary numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current qualified `S32Q16` profile:

- signed;
- 32-bit width;
- 16 fractional bits;
- scale `65536`.

Current qualified `S32Q30` profile:

- signed;
- 32-bit width;
- 30 fractional bits;
- scale `1073741824`.

Current qualified `PHASE_U32` profile:

- unsigned;
- 32-bit width;
- full cycle relation `2^32 phase units = 2π`;
- modulo `2^32` wrap.

Current rounding rule:

`round-to-nearest, half cases away from zero`

Current saturation rule:

`signed destination saturation`

Current multiplication rules:

`mul_q16 = round_shift(a × b, 16)`

`mul_q16_q30 = round_shift(a × b, 30)`

`mul_q30 = round_shift(a × b, 30)`

The current executable M16 retained-state boundary uses:

- canonical two-bit balanced ternary state encoding;
- derived cell-index widths;
- 32-bit architectural counters;
- deterministic packed retained-state vectors.

The inherited M15 fixed-point profile remains the numeric correlation source for later resonant-datapath FPGA implementation.

## 14. Trigonometric Lookup Mapping

The inherited M15 deterministic trigonometric profile uses:

`4096 entries`

Current address width:

`12 bits`

Current index relation:

`phase_word >> 20`

Current output type:

`S32Q30`

Current vector file:

`frp_m15_trig_lut_q30.vec`

Inherited M15 mapped RTL domain:

`frp_m15_trig_lut_pkg.sv`

FPGA implementation options include:

- block RAM initialization;
- distributed ROM;
- generated SystemVerilog package data;
- vendor-specific memory initialization;
- host-loaded verification image.

The FPGA study preserves lookup-table identity through:

- the inherited M15 vector package;
- `frp_m15_trig_lut_q30.vec`;
- `frp_m15_sha256_manifest.json`;
- deterministic byte-identical vector regeneration.

Within FRP v1.8.0 / M16, this lookup-table profile remains part of the qualified M15 resonant-datapath implementation-mapping contract inherited by the executable RTL and FPGA preparation layers.

## 15. Kuramoto-Sakaguchi Phase Layer Mapping

The inherited M15 resonant pair interaction is:

`sin(phase_j - phase_i - gamma_effective_i)`

Current qualified nominal phase lag:

`gamma = 0.30 × pi`

Qualified source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current qualified nominal coupling strength:

`coupling_nominal = 0.28`

Current qualified phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current qualified phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

FPGA phase blocks include:

- phase register;
- phase-difference datapath;
- gamma-offset datapath;
- phase-word wrap logic;
- sine lookup interface;
- hierarchical weight interface;
- thermal pair-factor interface;
- coupling accumulator;
- phase-velocity datapath;
- cycle-exact phase output.

Within FRP v1.8.0 / M16, this phase-layer mapping remains part of the qualified M15 resonant-datapath contract inherited by the current executable RTL and FPGA preparation layers.

## 16. Hierarchical Fractal Coupling Mapping

The qualified architecture uses a dyadic hierarchical ultrametric topology.

Inherited M15 default cell count:

`16`

Inherited M15 default hierarchy depth:

`4`

Hierarchy depth relation:

`cells.bit_length() - 1`

Hierarchical distance between distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current qualified fractal exponent:

`fractal_alpha = 0.70`

Current exactness marker:

`fixed_point_topology_sum_exact = True`

FPGA mapping options include:

- precomputed shell weights;
- ROM-based weight storage;
- grouped pair traversal;
- pipelined accumulation;
- time-multiplexed coupling units;
- parallel coupling units;
- multiscale group scheduling.

Inherited M15 mapped RTL domain:

`frp_m15_hierarchical_coupling.sv`

Within FRP v1.8.0 / M16, this hierarchical coupling domain remains part of the qualified M15 resonant-datapath implementation-mapping contract.

## 17. Distributed Local Thermal Mapping

Each qualified processor cell tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

Current qualified generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current qualified thermal-dissipation relation:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

Current qualified thermal parameters:

| Parameter | Value |
|---|---:|
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| thermal diffusion gain | `0.035` |
| thermal topology exponent | `1.20` |
| thermal coupling gain | `2.50` |

Current exactness marker:

`fixed_point_thermal_sum_exact = True`

FPGA blocks include:

- generated-power datapath;
- thermal-dissipation datapath;
- hierarchical thermal-diffusion accumulator;
- local heat register;
- overload comparator;
- global heat reduction path;
- thermal exactness output.

Inherited M15 mapped RTL domain:

`frp_m15_thermal_field.sv`

Within FRP v1.8.0 / M16, this thermal-field domain remains part of the qualified M15 resonant-datapath implementation-mapping contract.

## 18. Correlated Gamma Drift Mapping

The qualified processor tracks:

- nominal gamma;
- deterministic gamma-noise target;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

Current qualified gamma-noise target refresh interval:

`8 ticks`

Current qualified target range:

`[-1.0, 1.0]`

Current qualified correlated update:

`gamma_noise_state += 0.15 × (gamma_noise_target - gamma_noise_state)`

Current qualified effective local gamma:

`gamma_effective = gamma_nominal + 0.08 × thermal_overload × gamma_noise_state`

Inherited M15 verification-sideband inputs include:

- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

FPGA blocks include:

- gamma-noise target register;
- refresh counter;
- correlated-state datapath;
- overload multiplier;
- effective gamma adder;
- gamma trace output.

Inherited M15 mapped RTL domain:

`frp_m15_gamma_drift.sv`

Within FRP v1.8.0 / M16, this gamma-drift domain remains part of the qualified M15 resonant-datapath implementation-mapping contract.

## 19. Nonlinear Coherence Compression Mapping

Current qualified stability soft margin:

`0.25`

Current qualified margin pressure:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

Current qualified nonlinear compression:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Current qualified effective coherence:

`effective_coherence = raw_phase_coherence × coherence_compression`

Current inherited M15 exponential profile:

- input domain `S32Q16` from `0` to `524288`;
- output type `S32Q30`;
- table entries `4096`.

FPGA mapping options include:

- deterministic exponential lookup;
- ROM-based nonlinear response;
- pipelined square and weighted-sum datapaths;
- shared lookup resource;
- replicated lookup resource;
- time-multiplexed compression unit.

The FPGA implementation target preserves the qualified M15 fixed-point relation and deterministic vector identity inherited by FRP v1.8.0 / M16.

## 20. Kuramoto Order Parameter and Multiscale Coherence Mapping

The inherited M15 global phase-order relation is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation is applied to hierarchical groups.

Inherited M15 coherence domains:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Inherited M15 outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

FPGA mapping blocks include:

- sine lookup path;
- cosine lookup path;
- hierarchical accumulation;
- mean calculation;
- magnitude calculation;
- minimum tracking;
- coherence-dispersion calculation;
- normalized Q30 outputs.

Inherited M15 mapped RTL domain:

`frp_m15_multiscale_coherence.sv`

Within FRP v1.8.0 / M16, this multiscale-coherence domain remains part of the qualified M15 resonant-datapath implementation-mapping contract.

## 21. Operational Coherence and Stability Mapping

Inherited M15 operational coherence:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Inherited M15 destabilizing load:

`P = heat + switch_load`

Inherited M15 dynamic-stability margin:

`C_minus_P = C - P`

Current validated condition:

`C_minus_P_min > 0.0`

FPGA mapping blocks include:

- effective-coherence contribution;
- cluster-coherence contribution;
- neutral-fraction contribution;
- mean-frequency-lag contribution;
- global heat input;
- switch-load input;
- `C` output register;
- `P` output register;
- `C_minus_P` output register;
- first stability-crossing detector.

Inherited M15 mapped RTL domain:

`frp_m15_stability_telemetry.sv`

Within FRP v1.8.0 / M16, this operational-coherence and stability domain remains part of the qualified M15 resonant-datapath implementation-mapping contract.

## 22. Phase-Derived Ternary Target Mapping

Inherited M15 automatic target relation:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The inherited cross-tick relation is:

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

Inherited M15 execution control includes:

`auto_targets_enable`

FPGA mapping blocks include:

- sine lookup read;
- positive threshold comparator;
- negative threshold comparator;
- ternary target encoder;
- automatic-target enable logic;
- request and automatic-target arbitration.

The current M16 executable retained-state boundary receives the packed automatic-target vector through:

`target_q`

Current M16 target-vector width:

`CELLS × STATE_BITS`

The M16 core combines the target-vector domain with:

- explicit request lanes;
- scheduler execution;
- retained pending routes;
- transition-capacity admission;
- active-neutral routing;
- retained-state writeback.

## 23. Telemetry Mapping

The inherited M15 execution domain provides compact deterministic summaries and optional full traces.

Compact inherited M15 execution records include:

- configuration;
- kernel contract;
- hardware profile;
- execution summary;
- preload digest;
- trace digest;
- cell-trace digest.

Inherited M15 full-trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Inherited M15 default trace sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

The current M16 RTL and FPGA preparation boundaries expose:

- `core_ready` at the FPGA integration boundary;
- retained packed ternary state;
- retained packed pending-route state;
- registered scheduler mode;
- registered scheduler state;
- recorded-tick count;
- free-state scheduler count;
- balance-state scheduler count;
- commit-state scheduler count;
- excite-state scheduler count;
- neutralize-state scheduler count;
- request-accept vector;
- request-reject vector;
- accepted-cell mask;
- neutral-routed-cell mask;
- accepted-change mask;
- accepted-change count;
- remaining transition capacity;
- transition-capacity exhausted flag;
- switch-load numerator;
- requested direct-event count;
- prevented direct-event count;
- neutral-routed-event count;
- actual direct-event count;
- reserved-state-event count;
- queue-overflow-event count;
- integrated invariant vector.

Later resonant-datapath FPGA telemetry can expose:

- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`;
- per-cell phase;
- per-cell frequency;
- per-cell heat;
- per-cell gamma state;
- per-cell thermal-node factor;
- per-cell coupling field.

Candidate capture interfaces:

- BRAM trace buffer;
- AXI-lite register window;
- UART debug stream;
- JTAG-accessible debug registers;
- Integrated Logic Analyzer signal group;
- host-side structured export.

## 24. Current SystemVerilog Testbench Interface Map

Inherited M15 schema:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

Inherited M15 default parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

Inherited M15 execution inputs:

- `clk`;
- `reset_n`;
- `scheduler_mode`;
- `auto_targets_enable`;
- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Inherited M15 verification stimulus inputs:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Inherited M15 comparison outputs:

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

The current qualified M16 RTL and FPGA preparation configuration is:

| Parameter | Qualified Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `CELL_INDEX_BITS` | `3` |
| `COUNTER_BITS` | `32` |
| packed retained-state width | `16 bits` |

Current M16 core execution inputs:

- `clk`;
- `rst_n`;
- `tick_enable`;
- `clear_counters`;
- `scheduler_mode`;
- `request_valid`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

The current FPGA integration top replaces the core reset input with:

`rst_n_async`

The FPGA top generates the synchronized internal reset and exposes:

`core_ready`

Current M16 comparison outputs:

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

The inherited M15 interface map defines the semantic and implementation-mapping comparison source.

The current M16 core and FPGA-top interfaces define the executable RTL and FPGA preparation correlation boundaries.

## 25. Current Synthesizable RTL Reference-Core Mapping

Inherited M15 schema:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

Inherited M15 mapped RTL domains:

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

The M15 artifact defines this file set as the inherited synthesizable RTL reference-core mapping.

The current M16 executable RTL source boundary contains:

- `../rtl/m16/frp_m16_pkg.sv`;
- `../rtl/m16/frp_m16_scheduler.sv`;
- `../rtl/m16/frp_m16_request_lanes.sv`;
- `../rtl/m16/frp_m16_pending_routes.sv`;
- `../rtl/m16/frp_m16_active_neutral.sv`;
- `../rtl/m16/frp_m16_capacity_guard.sv`;
- `../rtl/m16/frp_m16_state_update.sv`;
- `../rtl/m16/frp_m16_core.sv`;
- `../rtl/m16/frp_m16_assertions.sv`.

The current M16 RTL boundary realizes:

- canonical balanced ternary encoding;
- retained ternary state;
- scheduler execution;
- deterministic request-lane arbitration;
- retained pending routes;
- active-neutral transition generation;
- distributed transition-capacity admission;
- retained-state writeback;
- architectural telemetry;
- integrated invariant evaluation;
- architectural and temporal assertions.

The current M16 FPGA preparation boundary instantiates:

`frp_m16_core`

through:

`../fpga/m16/frp_m16_fpga_top.sv`

## 26. M15 Exact Tick Execution Order

The inherited M15 quantized shadow and RTL reference-core domain use the same ordered 26-stage tick sequence:

1. resolve scheduler state;
2. clear current-tick switch-change counters;
3. clear current-tick per-cell switch activity;
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

The inherited M15 FPGA implementation sequence preserves this ordered execution relation at the complete resonant-datapath cycle-correlation boundary.

The current M16 executable retained-state tick order is:

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

## 27. Deterministic RTL Comparison Vector Package

Inherited M15 schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

Inherited M15 package file count:

`10`

Inherited M15 files:

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

Inherited M15 deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

Inherited M15 deterministic regeneration result:

`10/10 files byte-identical`

Inherited M15 self-test marker:

`vector_determinism_pass = True`

The FPGA study retains this package as the deterministic cycle-exact comparison source for the complete inherited M15 implementation-mapping domain.

The current M16 RTL and FPGA preparation qualification records remain separate executable evidence domains for the realized retained-state execution boundary.

## 28. FPGA Vector Replay Order

Inherited M15 vector replay order:

1. parse vector row;
2. drive input signals before active clock edge;
3. apply verification sideband stimulus;
4. execute one processor clock edge;
5. allow registered outputs to settle;
6. sample post-tick outputs;
7. compare sampled outputs against expected integer values;
8. execute invariant assertions;
9. stop immediately on mismatch.

The inherited exact integer comparison rule is:

`actual integer field == expected integer field`

This replay order remains the direct comparison contract for the complete inherited M15 resonant-datapath implementation.

The current M16 RTL and FPGA testbenches execute deterministic retained-state qualification scenarios through:

- controlled reset;
- scheduler-mode stimulus;
- request-lane stimulus;
- phase-derived target-bank stimulus;
- enabled tick execution;
- post-tick retained-state checks;
- pending-route checks;
- scheduler-counter checks;
- architectural-counter checks;
- integrated invariant checks;
- immediate termination on mismatch.

## 29. FPGA Testbench Strategy

The current executable FPGA integration testbench is:

`../fpga/m16/frp_m16_fpga_tb.sv`

Current testbench input domains:

- `clk`;
- `rst_n_async`;
- `tick_enable`;
- `clear_counters`;
- `scheduler_mode`;
- `request_valid`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

Current testbench output domains:

- `core_ready`;
- retained packed ternary state;
- retained packed pending-route state;
- registered scheduler mode;
- registered scheduler state;
- recorded-tick count;
- scheduler-state counters;
- request-accept vector;
- request-reject vector;
- accepted-cell mask;
- neutral-routed-cell mask;
- accepted-change mask;
- accepted-change count;
- remaining transition capacity;
- transition-capacity exhausted flag;
- switch-load numerator;
- requested direct-event count;
- prevented direct-event count;
- neutral-routed-event count;
- actual direct-event count;
- reserved-state-event count;
- queue-overflow-event count;
- integrated invariant vector.

Current executable FPGA testbench qualification covers:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- generation of `core_ready`;
- tick blocking before `core_ready`;
- counter-clear blocking before `core_ready`;
- request blocking before `core_ready`;
- scheduler-mode propagation;
- request-interface propagation;
- active-neutral opposite-polarity routing;
- retained pending-route completion;
- transition-capacity correlation;
- retained-state writeback;
- integrated architectural assertions;
- all ten M16 invariant flags;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events.

Current executable FPGA testbench result:

`PASS`

The inherited M15 complete resonant-datapath testbench domain additionally includes:

- automatic-target enable;
- preload state;
- deterministic gamma-noise target stimulus;
- M15 vector rows;
- switch load;
- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`;
- optional per-cell trace fields.

Inherited M15 comparison categories include:

- balanced ternary state validity;
- scheduler sequence;
- route sequence;
- pending-route sequence;
- transition-load bound;
- topology exactness;
- thermal exactness;
- integer output identity;
- trace digest identity;
- cell-trace digest identity.

## 30. RTL Assertion Correlation

Inherited M15 assertion-correlation harness count:

`13`

Inherited M15 assertion domains:

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

The current M16 assertion layer checks:

- canonical ternary state encoding;
- canonical pending-route encoding;
- reset to active neutral state `0`;
- reset clearing of scheduler counters;
- retained-state stability while `tick_enable = 0`;
- pending-route stability while `tick_enable = 0`;
- state changes only through `accepted_change_mask`;
- absence of direct opposite-polarity retained-state transitions;
- opposite-polarity first-leg routing through active neutral state `0`;
- retention of the requested pending polarity;
- pending-route completion only from retained state `0`;
- pending-route retention during scheduler or capacity deferral;
- scheduler mode, scheduler state, and counter relations;
- request acceptance and rejection separation;
- transition-capacity and switch-load relations;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- all ten integrated invariant flags.

Current M16 assertion module:

`../rtl/m16/frp_m16_assertions.sv`

Current terminal invariant vector:

`invariant_flags = 1111111111`

The FPGA integration testbench carries these assertion domains through the target-independent FPGA preparation boundary.

## 31. FPGA Study Profiles

Current FPGA study profiles include:

| Profile | Purpose |
|---|---|
| reset profile | verify asynchronous assertion and two-stage synchronous release |
| readiness profile | verify `core_ready` generation and execution-input gating |
| encoding profile | verify `-1`, `0`, `1`, and reserved-code handling |
| route profile | verify `-1 → 0 → 1` and `1 → 0 → -1` |
| queue profile | verify retained pending-route persistence and completion |
| scheduler profile | verify `free`, `7/1`, and `1/7` sequences |
| request-lane profile | verify ascending lane-order arbitration |
| transition-capacity profile | verify the derived `REQUEST_LANES` limit |
| retained-state profile | verify capacity-approved state writeback |
| telemetry profile | verify architectural counters and masks |
| invariant profile | verify all ten integrated M16 invariant flags |
| FPGA integration profile | verify top-level propagation through `frp_m16_fpga_top` |
| fixed-point profile | verify inherited S32Q16, S32Q30, PHASE_U32, and GAMMA_S32 domains |
| LUT profile | verify inherited 4096-entry trigonometric lookup identity |
| phase profile | verify inherited cycle-exact phase evolution |
| delay profile | verify inherited target/current frequency lag |
| thermal profile | verify inherited local and global thermal state |
| gamma profile | verify inherited deterministic gamma-noise stimulus |
| coherence profile | verify inherited hierarchical coherence outputs |
| stability profile | verify inherited `C`, `P`, and `C_minus_P` outputs |
| full correlation profile | replay the complete inherited M15 vector package |
| scaling profile | evaluate 8, 16, and 32-cell configurations |

The current executable M16 FPGA preparation profile uses:

`CELLS = 8`

`REQUEST_LANES = 2`

The inherited M15 vector package remains the complete resonant-datapath correlation source.

## 32. Suggested FPGA Block Diagram

Current executable M16 FPGA preparation structure:

`asynchronous external reset`

↓

`two-stage reset synchronizer`

↓

`core_ready generation`

↓

`execution-input gating`

↓

`scheduler mode and explicit request lanes`

↓

`deterministic request-lane arbitration`

↓

`retained pending-route selection`

↓

`active-neutral transition generation`

↓

`transition-capacity admission`

↓

`retained ternary state writeback`

↓

`retained pending-route update`

↓

`architectural telemetry`

↓

`integrated invariant evaluation`

↓

`FPGA integration testbench comparison`

Current FPGA integration module:

`frp_m16_fpga_top`

Current instantiated execution core:

`frp_m16_core`

The inherited complete M15 resonant-datapath extension is:

`retained ternary state`

↓

`stateful delay dynamics`

↓

`thermal-field update`

↓

`gamma-drift update`

↓

`hierarchical Kuramoto-Sakaguchi coupling`

↓

`phase velocity and wrapped phase update`

↓

`multiscale coherence calculation`

↓

`C(t), P(t), and C_minus_P`

↓

`post-tick trace capture`

↓

`M15 vector comparison and assertion layer`

The M16 block structure follows the current retained-state tick order.

The inherited M15 extension follows the qualified 26-stage resonant-datapath execution order.

## 33. Clock and Reset Mapping

The current M16 FPGA integration inputs include:

- `clk`;
- `rst_n_async`.

Internal core reset:

`rst_n_core`

Qualified reset sequence:

1. external reset asserts asynchronously;
2. the two-stage synchronization register clears;
3. the first release clock edge remains blocked;
4. the second release clock edge activates `rst_n_core`;
5. `core_ready` becomes active.

Qualified readiness relation:

`core_ready = rst_n_core`

Qualified input-gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Current reset and readiness qualification:

| Condition | Result |
|---|---|
| asynchronous reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| tick blocking before readiness | `PASS` |
| counter-clear blocking before readiness | `PASS` |
| request blocking before readiness | `PASS` |

The target-specific timing study can define:

- primary clock period;
- external reset-source timing;
- synchronized reset-release timing;
- execution-input setup timing;
- registered output sampling window;
- trace-capture timing;
- host-interface timing.

The timing-closure process can separate:

- functional clock target;
- initial synthesis clock target;
- post-place-and-route achieved frequency;
- vector replay frequency;
- debug capture frequency.

All reported timing results retain the exact device, implementation configuration, workflow revision, and constraint-file identity.

## 34. FPGA Resource Mapping

Current qualified M16 FPGA preparation resource subjects include:

- reset synchronization registers;
- readiness state;
- execution-input gating logic;
- balanced ternary retained-state registers;
- packed retained-state output;
- retained pending-route registers;
- scheduler mode and scheduler-state registers;
- scheduler counters;
- request-lane arbitration logic;
- accepted-cell masks;
- neutral-routed-cell masks;
- transition-capacity logic;
- retained-state writeback logic;
- route-event counters;
- reserved-state and queue-overflow counters;
- integrated invariant logic.

Inherited M15 complete resonant-datapath resource subjects include:

- phase registers;
- frequency registers;
- thermal-state registers;
- gamma-state registers;
- fixed-point arithmetic units;
- trigonometric lookup memory;
- exponential lookup memory;
- hierarchical coupling-weight memory;
- multiscale coherence accumulators;
- stability telemetry registers;
- trace buffers;
- vector-comparison logic.

A target-specific implementation report records:

- LUT utilization;
- flip-flop utilization;
- BRAM utilization;
- DSP utilization;
- clock resources;
- reset resources;
- routing congestion indicators;
- hierarchy-level resource distribution;
- debug-resource overhead;
- comparison-harness overhead.

The current M16 FPGA preparation layer preserves the target-independent source boundary for later device-specific synthesis, utilization, timing, placement, routing, and implementation evidence.

## 35. Memory and Storage Mapping

Current M16 and inherited M15 memory domains include:

| Data Domain | Candidate FPGA Resource |
|---|---|
| retained ternary state | register bank |
| retained pending routes | registers or small RAM |
| scheduler state and counters | register bank |
| request and transition masks | registers |
| architectural counters | register bank |
| integrated invariant flags | registers |
| trigonometric LUT | BRAM or distributed ROM |
| exponential LUT | BRAM or distributed ROM |
| hierarchical weights | ROM or constant arrays |
| per-cell phase | register bank |
| per-cell frequency state | register bank or RAM |
| per-cell thermal state | register bank or RAM |
| per-cell gamma state | register bank or RAM |
| trace buffer | BRAM |
| vector preload | host memory or initialization file |

The current M16 executable boundary retains:

- packed ternary state;
- packed pending-route state;
- scheduler mode and scheduler state;
- scheduler counters;
- request-accept and request-reject vectors;
- accepted-cell masks;
- neutral-routed-cell masks;
- accepted-change masks;
- route-event counters;
- reserved-state counters;
- queue-overflow counters;
- integrated invariant flags.

The inherited M15 resonant-datapath mapping retains the lookup, phase, frequency, thermal, gamma, coherence, stability, trace, and vector-preload memory domains.

Deterministic initialization and digest identity remain part of the replay-sensitive inherited M15 artifact contract.

## 36. Arithmetic Implementation Study

The inherited M15 hardware-sensitivity and comparative-architecture evidence identifies fixed-point arithmetic and lookup activity as primary implementation subjects.

Inherited M15 FPGA arithmetic study areas include:

- Q16 multiplication;
- Q30 multiplication;
- mixed Q16 × Q30 multiplication;
- accumulation width;
- saturation;
- rounding;
- phase wrapping;
- square operations;
- mean calculation;
- square-root or magnitude calculation;
- exponential lookup;
- sine and cosine lookup.

Current M16 retained-state arithmetic and control subjects include:

- derived cell-index widths;
- packed two-bit ternary-state extraction;
- request-lane index arithmetic;
- transition-capacity counting;
- accepted-change counting;
- remaining-capacity calculation;
- switch-load numerator calculation;
- scheduler period counting;
- 32-bit architectural counter updates;
- integrated invariant reduction.

Implementation options for the inherited complete resonant datapath include:

- DSP-based multiplication;
- LUT-based multiplication;
- shared multipliers;
- replicated multipliers;
- pipelined accumulators;
- time-multiplexed arithmetic;
- hierarchical scheduling of shared resources.

Each implementation stage preserves:

- the inherited M15 deterministic vector domain;
- the defined integer comparison outputs;
- the current M16 retained-state execution contract;
- the ten integrated M16 invariant flags.

## 37. Synthesis and Utilization Deliverables

A target-specific FPGA implementation layer can produce:

- synthesis tool and version;
- FPGA device identifier;
- top-level module identifier;
- source commit identifier;
- constraint-file identifier;
- synthesis status;
- LUT utilization;
- register utilization;
- BRAM utilization;
- DSP utilization;
- clock-resource utilization;
- reset-resource utilization;
- inferred memory inventory;
- inferred arithmetic inventory;
- hierarchy report;
- warnings and implementation notes.

The current target-independent M16 source boundary provides:

- `frp_m16_fpga_top`;
- `frp_m16_core`;
- the M16 RTL module hierarchy;
- the FPGA integration testbench;
- deterministic simulation evidence;
- RTL closure evidence;
- FPGA preparation closure evidence.

These outputs form the structural source for later target-specific synthesis, utilization, placement, routing, and timing records.

## 38. Timing Correlation Deliverables

A target-specific FPGA timing study can record:

- target clock period;
- achieved setup timing;
- achieved hold timing;
- worst negative slack;
- total negative slack;
- critical path;
- critical path domain;
- post-route frequency;
- reset-release timing;
- execution-input gating timing;
- per-block timing concentration;
- trace-capture timing;
- vector-replay timing.

Timing results remain attached to:

- exact FRP release version;
- exact source commit;
- exact FPGA device;
- exact top-level module;
- exact synthesis strategy;
- exact implementation strategy;
- exact constraint set;
- exact clock definition;
- exact reset definition;
- exact workflow revision.

The current M16 FPGA preparation boundary preserves the reset, readiness, execution-input, retained-state, pending-route, scheduler, telemetry, and invariant interfaces required for later timing correlation.

## 39. Validation Against the Inherited M15 Reference and Current M16 Boundary

Qualified semantic-reference command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Qualified full-trace command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Qualified self-test command:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Inherited M15 vector-package export:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Inherited M15 SystemVerilog interface-map export:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Inherited M15 RTL reference-core map export:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Inherited M15 equivalence-report export:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Inherited M15 qualification-closure export:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Current M16 RTL qualification sources:

- `../rtl/m16/frp_m16_tb.sv`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`.

Current M16 FPGA preparation qualification sources:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Inherited M15 comparison categories:

- state sequence;
- scheduler sequence;
- neutral-route sequence;
- pending-route sequence;
- route counters;
- switch load;
- heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`;
- trace identity;
- cell-trace identity.

Current M16 RTL and FPGA preparation comparison categories:

- reset and readiness sequence;
- retained ternary-state sequence;
- retained pending-route sequence;
- scheduler mode and scheduler-state sequence;
- scheduler-counter consistency;
- ascending request-lane order;
- request acceptance and rejection;
- active-neutral first-leg execution;
- pending-route completion;
- transition-capacity admission;
- retained-state writeback;
- architectural route counters;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- integrated invariant vector identity.

Inherited M15 qualification result:

`PASS`

Current M16 RTL qualification result:

`PASS`

Current M16 FPGA preparation qualification result:

`PASS`

## 40. Current Default Validation Profile

The inherited M15 default validation profile retained by FRP v1.8.0 / M16 is:

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

Inherited M15 verified summary:

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

The current qualified M16 RTL profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `CELL_INDEX_BITS` | `3` |
| `COUNTER_BITS` | `32` |
| packed state width | `16 bits` |

Current M16 RTL terminal values:

| Metric | Value |
|---|---:|
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| result | `PASS` |

Current M16 FPGA preparation terminal values:

| Metric | Value |
|---|---:|
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |
| result | `PASS` |

## 41. Current Scaling Profiles

Inherited M15 validated scaling profiles:

| Cells | Hierarchy Depth | Request Lanes | `C_minus_P_min` | Switch Load Peak |
|---|---:|---:|---:|---:|
| `8` | `3` | `2` | `0.828887939453125` | `0.25` |
| `16` | `4` | `4` | `0.6142730712890625` | `0.25` |
| `32` | `5` | `8` | `0.6628875732421875` | `0.25` |

Each inherited M15 validated profile records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

These profiles provide the inherited 8-cell, 16-cell, and 32-cell FPGA parameterization targets.

The current qualified M16 executable RTL and FPGA preparation configuration uses:

`CELLS = 8`

`HIERARCHY_DEPTH = 3`

`REQUEST_LANES = 2`

`packed state width = 16 bits`

Current M16 capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

## 42. Floating-to-Quantized and Exact Replay Evidence

Inherited M15 floating semantic reference to quantized-shadow correlation:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`neutral_route_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

Inherited M15 semantic-correlation result:

`PASS`

Inherited M15 exact quantized replay:

`shadow_replay_state_match = 1.0`

`shadow_replay_scheduler_match = 1.0`

`shadow_replay_pending_route_match = 1.0`

`shadow_replay_counter_match = 1.0`

`shadow_replay_trace_match = 1.0`

`shadow_replay_cell_trace_match = 1.0`

Inherited M15 exact deterministic replay result:

`PASS`

FRP v1.8.0 / M16 carries this qualified semantic and deterministic integer domain into:

- executable retained-state RTL;
- deterministic request-lane arbitration;
- active-neutral routing;
- retained pending-route execution;
- transition-capacity admission;
- retained-state writeback;
- integrated invariant evaluation;
- target-independent FPGA preparation.

Current M16 RTL qualification result:

`PASS`

Current M16 FPGA preparation qualification result:

`PASS`

## 43. Earlier FPGA-Oriented M7 Scaffold Layer

The repository preserves the earlier FPGA-oriented scaffold layer:

`FRP v0.9.9 — M7 FPGA Synthesis Package and Timing Constraint Scaffold`

Primary historical M7 document:

`./m7_fpga_synthesis_timing.md`

Primary historical M7 workflow:

`../.github/workflows/frp-m7-fpga-synthesis.yml`

Historical M7 artifact targets:

- `fpga_synthesis_manifest`;
- `timing_constraint_profile`;
- `resource_estimate_map`;
- `implementation_handoff_scaffold`.

The inherited M15 deterministic implementation-mapping package carries the FPGA-facing subject beyond the earlier scaffold through:

- fixed-point interface mapping;
- balanced ternary hardware encoding;
- quantized hardware-shadow execution;
- cycle-exact integer traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- reference equivalence;
- qualification closure.

The current M16 layer carries the same subject into:

- executable synthesizable RTL;
- deterministic retained-state execution;
- target-independent FPGA integration;
- reset synchronization;
- readiness gating;
- FPGA integration-testbench execution;
- FPGA preparation qualification closure.

## 44. Current Comparative Architecture Evidence

The current Comparative Architecture Benchmark Suite evaluates:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Current canonical workload:

- `256 commands`;
- `16 cells`;
- `seed 76`;
- `transaction_serial` execution;
- maximum `64` completion cycles per command;
- final cooldown `32` cycles.

All architecture rows record:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

Current unit-event baseline results:

| Architecture | Normalized Activity Cost | Peak Temperature Proxy |
|---|---:|---:|
| `binary_synchronous_reference` | `5412.0` | `3.8474206768140564` |
| `binary_clock_gated_reference` | `934.0` | `0.771273768299779` |
| `direct_ternary_reference` | `1242.0` | `1.119499710224827` |
| `frp_v1_7_0_quantized_shadow` | `1393509.0` | `675.0796999541329` |

The FRP row records:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`pending_route_count_final = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The comparative architecture benchmark remains a separate inherited M15 measurement contour.

The current M16 RTL and FPGA preparation results remain executable qualification contours with their own source, testbench, transcript, closure, workflow, and terminal evidence.

## 45. Current Hardware-Sensitivity Evidence

Inherited M15 hardware-sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Current normalization:

`32-bit integer addition = 1.0`

Reference energy:

`0.1 pJ`

Technology context:

`45 nm CMOS`

Qualified scenarios:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Qualified results:

| Scenario | Binary Synchronous | Binary Clock Gated | Direct Ternary | FRP v1.7.0 Quantized Shadow |
|---|---:|---:|---:|---:|
| `lower_bound` | `181.078125` | `111.109375` | `118.078125` | `14457825.125` |
| `nominal` | `724.3125` | `444.4375` | `472.3125` | `25157118.0` |
| `upper_bound` | `4049.25` | `2929.75` | `3041.25` | `39955490.0` |

Qualified ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

Qualified package result:

`PASS`

This inherited sensitivity contour provides the implementation-cost study input for target-specific FPGA optimization beyond the current M16 target-independent FPGA preparation boundary.

## 46. Current FPGA Optimization Targets

The inherited M15 event profile identifies major activity-cost concentration in:

- fixed-point arithmetic volume;
- trigonometric lookup volume;
- hierarchical coupling activity;
- distributed thermal processing;
- multiscale coherence processing.

The current M16 executable retained-state boundary additionally exposes optimization subjects in:

- request-lane arbitration;
- pending-route storage;
- active-neutral transition generation;
- transition-capacity admission;
- retained-state writeback;
- scheduler-state counters;
- architectural telemetry;
- integrated invariant evaluation;
- FPGA reset synchronization;
- readiness and execution-input gating.

Target-specific FPGA optimization study areas include:

- arithmetic sharing;
- arithmetic pipelining;
- DSP allocation;
- LUT and ROM placement;
- coupling-unit parallelism;
- coupling-unit time multiplexing;
- thermal datapath scheduling;
- coherence reduction-tree structure;
- request-lane arbitration structure;
- pending-route storage structure;
- retained-state register placement;
- trace-buffer sizing;
- debug-overhead isolation;
- clock-frequency tradeoffs;
- resource and latency tradeoffs.

Every optimization stage preserves:

- the inherited M15 vector and invariant comparison domain;
- the current M16 retained-state execution contract;
- the ten integrated M16 invariant flags;
- the M16 FPGA reset and readiness contract.

## 47. Implementation Risk Register

Primary FPGA implementation risks include:

| Risk | Study Response |
|---|---|
| fixed-point drift | cycle-exact integer comparison |
| LUT identity drift | SHA-256 and vector-package verification |
| route-order drift | pending-route sequence comparison |
| scheduler drift | scheduler-vector replay and scheduler-counter checks |
| request-lane reordering | ascending lane-order assertions |
| transition-capacity drift | accepted-change and switch-load validation |
| retained-state writeback drift | accepted-change-mask correlation |
| pending-route retention drift | cross-tick pending-route checks |
| active-neutral routing drift | direct-transition exclusion and retained-target checks |
| reserved-state generation | reserved-state counter and invariant checks |
| queue-overflow generation | queue-overflow counter and invariant checks |
| reset-release drift | two-stage synchronous-release checks |
| execution before readiness | `core_ready` input-gating checks |
| thermal accumulation drift | fixed-point thermal exactness checks |
| topology normalization drift | fixed-point topology exactness checks |
| gamma stimulus drift | deterministic sideband stimulus replay |
| trace timing drift | post-tick sampling contract |
| debug logic timing impact | separate synthesis profiles |
| resource pressure | per-domain utilization reporting |
| critical-path concentration | block-level timing reports |

## 48. Expected FPGA Study Deliverables

Current completed M16 target-independent deliverables:

- synthesizable M16 RTL source boundary;
- `frp_m16_core` realization;
- balanced ternary retained-state datapath;
- active-neutral route controller;
- retained pending-route storage;
- scheduler realization;
- request-lane realization;
- transition-capacity realization;
- retained-state writeback;
- architectural telemetry;
- integrated invariant evaluation;
- architectural and temporal assertions;
- target-independent `frp_m16_fpga_top`;
- executable `frp_m16_fpga_tb`;
- asynchronous reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating;
- deterministic RTL simulation transcript;
- deterministic FPGA preparation simulation transcript;
- RTL qualification closure;
- FPGA preparation qualification closure.

Inherited M15 correlation deliverables:

- fixed-point phase profile;
- trigonometric lookup profile;
- hierarchical coupling mapping;
- delay-dynamics mapping;
- thermal-field mapping;
- gamma-drift mapping;
- multiscale coherence mapping;
- stability telemetry mapping;
- cycle-exact integer trace;
- deterministic RTL comparison vectors;
- SystemVerilog interface map;
- assertion-correlation harness;
- reference-equivalence report;
- qualification-closure manifest.

Later target-specific FPGA deliverables:

- selected FPGA target profile;
- source and toolchain identity record;
- target-specific top-level wrapper;
- device constraint files;
- clock and reset resource mapping;
- synthesis report;
- utilization report;
- timing report;
- placement and routing report;
- trace-capture report;
- optimization report;
- FPGA-to-reference correlation report.

## 49. Funding and Partner Relevance

The current FPGA mapping study supports:

- RTL engineering review;
- FPGA implementation planning;
- verification planning;
- grant preparation;
- laboratory collaboration;
- semiconductor research partnership;
- implementation optimization study;
- later ASIC-oriented development;
- physical validation planning.

Current partner-facing technical message:

`FRP v1.8.0 carries the qualified v1.7.0 processor reference, deterministic fixed-point mapping, exact integer traces, deterministic RTL comparison vectors, SystemVerilog interface mapping, and M15 qualification closure into an executable M16 RTL core and a qualified target-independent FPGA preparation boundary.`

Current engineering message:

`The target-specific FPGA layer can synthesize, place, route, measure, and optimize the processor while preserving the inherited M15 state, scheduler, route, fixed-point, trace, and dynamic-stability comparison domain together with the current M16 retained-state, reset, readiness, telemetry, and integrated-invariant execution contract.`

## 50. Recommended FPGA Development Sequence

Recommended sequence:

1. preserve the qualified FRP v1.7.0 executable semantic reference;
2. preserve the ten inherited M15 artifact schemas;
3. preserve canonical balanced ternary encoding;
4. preserve the inherited M15 26-stage resonant-datapath order and current M16 retained-state tick order;
5. preserve deterministic preload and lookup identities;
6. retain the qualified M16 RTL core and target-independent FPGA preparation boundary;
7. replay kernel transition vectors;
8. replay scheduler vectors;
9. replay pending-route traces;
10. replay full correlation vectors;
11. close exact integer correlation;
12. connect the target-specific FPGA wrapper;
13. synthesize for the selected FPGA target;
14. record utilization;
15. record timing;
16. identify critical activity and timing concentration;
17. optimize arithmetic, lookup, coupling, thermal, coherence, routing, and retained-state domains;
18. repeat inherited M15 vector replay and exact integer correlation;
19. capture FPGA telemetry;
20. prepare the physical validation interface.

## 51. Current Reproduction Commands

Compile the qualified executable semantic reference:

    python -m py_compile ../frp_prototype_v1_7_0.py

Run the qualified default structured execution:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Run the qualified full trace:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run the qualified 41-check self-test:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Export the inherited M15 benchmark matrix:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

Export the inherited M15 vector package:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Export the inherited M15 SystemVerilog testbench interface map:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Export the inherited M15 synthesizable RTL reference-core map:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Export the inherited M15 RTL assertion-correlation harness:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Export the inherited M15 reference-equivalence report:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Export the inherited M15 qualification-closure manifest:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Run the current M16 RTL build from the repository root:

    verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv

Run the current M16 RTL testbench:

    /tmp/frp_m16_obj/Vfrp_m16_tb

Elaborate the current M16 FPGA integration top:

    verilator --sv --lint-only --top-module frp_m16_fpga_top -Irtl/m16 -Ifpga/m16 fpga/m16/frp_m16_fpga_top.sv

Build the current M16 FPGA integration testbench:

    verilator --sv --timing --assert --binary --top-module frp_m16_fpga_tb -Irtl/m16 -Ifpga/m16 --Mdir /tmp/frp_m16_fpga_obj fpga/m16/frp_m16_fpga_tb.sv

Run the current M16 FPGA integration testbench:

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

## 52. Current GitHub Actions Validation Context

Current repository workflow count:

`23`

Current root README active passing workflow badge count:

`2`

Current primary M16 RTL workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Workflow name:

`FRP M16 FPGA Preparation`

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Inherited workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Current workflow environment:

`ubuntu-latest`

Inherited M15 qualification Python version:

`3.12`

Current M16 RTL toolchain:

- system `python3`;
- Verilator;
- `g++`.

Current M16 RTL workflow stages:

1. checkout repository;
2. verify the M16 RTL artifact boundary;
3. verify obsolete M16 workflows are absent;
4. prepare isolated simulation paths;
5. install the Verilator toolchain;
6. record M16 RTL source hashes;
7. build the integrated M16 RTL testbench;
8. execute the architectural testbench;
9. validate terminal execution markers;
10. reject latch and multidriven diagnostics;
11. validate the RTL transcript and closure records;
12. generate and upload qualification evidence.

Current M16 FPGA preparation workflow stages:

1. checkout repository;
2. verify the M16 FPGA artifact boundary and RTL dependencies;
3. prepare isolated FPGA simulation paths;
4. install the Verilator toolchain;
5. record FPGA and RTL source hashes;
6. elaborate the FPGA integration top;
7. build the FPGA integration testbench;
8. execute the FPGA integration testbench;
9. validate terminal execution markers;
10. reject latch and multidriven diagnostics;
11. validate the FPGA transcript and closure records;
12. generate and upload qualification evidence.

## 53. Current Release Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Current validation environment:

`GitHub Actions hardware-backed CI execution`

Final synchronized M16 qualification commit:

`ede53cf`

Inherited M15 qualification evidence:

- `41 / 41 PASS`;
- qualification closure `PASS`;
- two independently generated vector packages with `10/10 files byte-identical`.

Recorded M16 RTL qualification stack:

| Qualification record | Workflow run | Qualified commit | Result |
|---|---:|---|---|
| initial RTL closure | `#82` | `a68a2af` | `SUCCESS` |
| synchronized RTL qualification rerun | `#84` | `ede53cf` | `SUCCESS` |

M16 RTL qualification result:

`PASS`

M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Recorded M16 FPGA preparation qualification stack:

| Qualification record | Workflow run | Qualified commit | Result |
|---|---:|---|---|
| initial FPGA preparation closure | `#1` | `326b69e` | `SUCCESS` |
| synchronized FPGA preparation qualification rerun | `#2` | `ede53cf` | `SUCCESS` |

M16 FPGA preparation qualification result:

`PASS`

M16 FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current overall published result:

`PASS`

## 54. Current File Alignment

This FPGA mapping study is aligned with:

- `../README.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../CI.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../funding_brief.md`;
- `./README.md`;
- `./core_principles.md`;
- `./resonance_computation.md`;
- `./architecture.md`;
- `./implementation_layers.md`;
- `./hardware_pathway.md`;
- `./asic_mapping_study.md`;
- `./physical_validation_plan.md`;
- `./output_schema.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `./m16_rtl_core_realization_execution_semantics.md`;
- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../examples/README.md`;
- `../examples/resonance_convergence_example.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Earlier FPGA-oriented scaffold evidence remains aligned with:

- `./m7_fpga_synthesis_timing.md`;
- `../.github/workflows/frp-m7-fpga-synthesis.yml`.

## 55. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current FPGA correlation source:

`inherited M15 deterministic fixed-point, trace, vector, interface, assertion, equivalence, and qualification package → executable M16 RTL core → target-independent M16 FPGA preparation boundary`

Inherited M15 self-test result:

`41/41 PASS`

Inherited M15 artifact layer count:

`10`

Inherited M15 deterministic vector package:

`10 files`

Inherited M15 deterministic vector regeneration:

`10/10 files byte-identical`

Inherited M15 exact tick-order count:

`26`

Inherited M15 assertion-domain count:

`13`

Inherited M15 semantic correlation result:

`PASS`

Inherited M15 exact deterministic replay result:

`PASS`

Inherited M15 qualification closure result:

`PASS`

Current M16 RTL qualification result:

`PASS`

Current M16 FPGA preparation qualification result:

`PASS`

Current published validation result:

`PASS`

Current FPGA study objective:

`programmable-hardware realization, synthesis, timing, trace capture, optimization, and cycle-exact correlation against the inherited qualified M15 reference domain and current executable M16 RTL and FPGA preparation boundaries`

Current engineering optimization target:

`fixed-point arithmetic, trigonometric lookup, hierarchical coupling, thermal processing, multiscale coherence, request-lane arbitration, retained pending routes, transition-capacity admission, retained-state writeback, and integrated invariant evaluation`

Current M16 closure state:

`M16 RTL EXECUTION LAYER CLOSED`

`M16 FPGA PREPARATION LAYER CLOSED`
















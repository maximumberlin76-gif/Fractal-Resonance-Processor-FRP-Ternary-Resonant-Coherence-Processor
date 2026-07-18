# Physical Validation Plan — Fractal Resonance Processor (FRP)

**Ternary Fractal Resonant Coherence Processor — Physical Validation Plan**

This document defines the current physical-validation planning structure for the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current public repository package:

`qualified executable semantic reference, structured output, reproducibility, verification, benchmark, comparative architecture, hardware sensitivity, M15 implementation mapping, M16 RTL execution, M16 FPGA preparation, qualification, documentation, governance, and release-evidence layers`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 architecture document:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

Current hardware pathway:

`./hardware_pathway.md`

Current FPGA mapping study:

`./fpga_mapping_study.md`

Current ASIC mapping study:

`./asic_mapping_study.md`

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

The purpose of this document is to define how physical FRP implementations are measured and correlated against the qualified M15 semantic and implementation-mapping foundation and the current M16 RTL execution and FPGA preparation contracts.

The physical-validation plan connects:

`qualified M15 floating semantic reference`

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

`M15 assertion correlation and exact replay`

↓

`M15 qualification closure`

↓

`M16 executable RTL core realization`

↓

`M16 scheduler and request-lane execution`

↓

`M16 active-neutral routing`

↓

`M16 retained pending-route execution`

↓

`M16 transition-capacity enforcement`

↓

`M16 retained-state writeback`

↓

`M16 integrated invariant evaluation`

↓

`M16 RTL qualification closure`

↓

`M16 target-independent FPGA integration top`

↓

`M16 asynchronous reset assertion`

↓

`M16 two-stage synchronous reset release`

↓

`M16 core readiness and execution-input gating`

↓

`M16 FPGA preparation qualification closure`

↓

`FPGA implementation and timing correlation`

↓

`ASIC-oriented implementation and cost study`

↓

`physical measurement setup identity`

↓

`timing, activity, electrical-energy, and thermal measurement`

↓

`trace and telemetry comparison`

↓

`repeatability and review record`

This document covers:

- validation purpose;
- reference-model alignment;
- balanced ternary state correctness;
- active neutral transition routing;
- pending neutral-route persistence;
- distributed commit behavior;
- request-lane order;
- scheduler behavior;
- fixed-point correlation;
- phase evolution;
- delay dynamics;
- distributed thermal dynamics;
- correlated gamma dynamics;
- multiscale phase coherence;
- `C(t)`, `P(t)`, and `C_minus_P` correlation;
- telemetry consistency;
- cycle-exact trace identity;
- M16 retained-state execution;
- M16 architectural event telemetry;
- M16 invariant propagation;
- FPGA reset and readiness behavior;
- timing behavior;
- switching activity;
- electrical power and energy behavior;
- physical thermal behavior;
- benchmark repeatability;
- workload identity;
- vector-package identity;
- measurement protocol structure;
- validation deliverables;
- laboratory, engineering, funding, and partner records.

## 2. Current Reference Domain

The qualified executable semantic representation is:

`FractalResonanceProcessor`

The qualified stateful finite-word representation is:

`QuantizedReferenceShadowProcessor`

Qualified executable reference:

`../frp_prototype_v1_7_0.py`

The qualified M15 reference domain includes:

- balanced ternary state and retained-result domain `{-1, 0, 1}`;
- active neutral transition routing;
- pending neutral routes;
- request-lane processing;
- distributed commit capacity;
- `free`, `7/1`, and `1/7` scheduler modes;
- Kuramoto-Sakaguchi resonant phase dynamics;
- asymmetric Sakaguchi phase lag gamma;
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
- structured processor-tick telemetry;
- structured per-cell telemetry;
- deterministic fixed-point mapping;
- canonical balanced ternary hardware encoding;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference equivalence;
- exact deterministic replay;
- qualification closure.

The current M16 execution domain includes:

- executable SystemVerilog retained-state core;
- deterministic scheduler execution;
- deterministic ascending request-lane arbitration;
- active-neutral opposite-polarity routing;
- retained pending-route polarity;
- pending-route completion;
- distributed transition-capacity enforcement;
- retained-state writeback;
- architectural event counters;
- ten integrated invariant flags;
- executable RTL assertions;
- target-independent FPGA integration top;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- execution-input gating;
- FPGA integration testbench.

Reference role:

`qualified behavioral, numeric, state, route, scheduler, trace, execution, and stability source for physical measurement and correlation`

## 3. Validation Objective

The primary validation objective is:

`compare physical FRP execution against the qualified M15 reference identities and the M16 execution contracts under preserved configuration, preload, workload, scheduler, request, stimulus, trace, interface, and metric definitions`

The validation structure preserves traceability between:

- executable semantic output;
- quantized-shadow output;
- M15 benchmark output;
- M15 cycle-exact reference traces;
- M15 deterministic vector packages;
- M15 semantic correlation;
- M15 exact deterministic replay;
- M15 qualification closure;
- M16 RTL execution;
- M16 architectural assertions;
- M16 FPGA preparation execution;
- GitHub Actions qualification evidence;
- FPGA implementation output;
- ASIC-oriented simulation and implementation records;
- physical measurement output;
- processor invariants.

Validation goals include:

- confirm balanced ternary state correctness;
- confirm active neutral route behavior;
- confirm retained pending-route polarity;
- confirm pending-route completion from active neutral state `0`;
- confirm direct opposite-polarity event count remains zero;
- confirm reserved-state event count remains zero;
- confirm queue-overflow event count remains zero;
- confirm distributed transition-capacity behavior;
- confirm deterministic request-lane order;
- confirm scheduler sequence;
- confirm retained-state writeback;
- confirm all ten M16 invariant flags;
- confirm fixed-point topology and thermal exactness;
- confirm phase and frequency evolution correlation;
- confirm thermal and gamma state correlation;
- confirm multiscale coherence correlation;
- confirm `C(t)`, `P(t)`, and `C_minus_P` correlation;
- confirm telemetry consistency;
- confirm cycle-exact trace identity;
- confirm reset assertion and release behavior;
- confirm core-readiness behavior;
- confirm execution-input gating;
- measure timing behavior;
- measure switching activity;
- measure electrical power and energy behavior;
- measure physical thermal behavior;
- compare measured execution with the qualified reference package.

## 4. Current Validated Invariants for Physical Validation

Physical validation inherits the qualified M15 and M16 processor invariants:

| Invariant | Required result |
|---|---|
| balanced ternary state domain | `{-1, 0, 1}` |
| opposite-polarity routing | `-1 → 0 → 1` and `1 → 0 → -1` |
| direct opposite-polarity execution | `actual_direct_events = 0` |
| reserved hardware state | `reserved_state_events = 0` |
| pending-route queue | `queue_overflow_events = 0` |
| dynamic stability | `C_minus_P_min > 0.0` |
| transition load | `switch_load_peak <= transition_fraction` |
| M15 telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |
| request-lane order | deterministic ascending order |
| pending-route polarity | retained until qualified completion |
| pending-route priority | completion candidates precede new requests |
| transition capacity | state changes do not exceed `REQUEST_LANES` |
| retained-state writeback | only capacity-qualified candidates commit |
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
| M16 integrated invariant flags | `1111111111` |
| FPGA core readiness | `core_ready = 1` after synchronized reset release |
| execution before readiness | tick, counter-clear, and request-valid inputs gated |

Current M16 integrated invariant set:

- `FRP_INV_STATE_DOMAIN_VALID`;
- `FRP_INV_SCHEDULER_COUNTS_VALID`;
- `FRP_INV_REQUEST_LANE_ORDER_VALID`;
- `FRP_INV_PENDING_POLARITY_VALID`;
- `FRP_INV_ACTIVE_NEUTRAL_VALID`;
- `FRP_INV_TRANSITION_CAPACITY_VALID`;
- `FRP_INV_STATE_UPDATE_VALID`;
- `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
- `FRP_INV_NO_RESERVED_STATE`;
- `FRP_INV_NO_QUEUE_OVERFLOW`.

These invariants define the digital correlation boundary inherited by physical validation.

## 5. Validation Categories

Physical validation is organized into the following categories:

| Category | Recorded purpose |
|---|---|
| logical correctness | confirm balanced ternary state and target behavior |
| transition routing | confirm opposite-polarity changes use active neutral routing |
| pending-route behavior | confirm route retention and qualified completion |
| distributed commit | confirm controlled transition capacity per tick |
| request-lane behavior | confirm ascending lane-order execution |
| scheduler behavior | confirm `free`, `7/1`, and `1/7` sequences |
| retained-state writeback | confirm only admitted state changes commit |
| integrated invariants | confirm all ten M16 invariant flags |
| reset behavior | confirm asynchronous assertion and synchronous release |
| readiness behavior | confirm `core_ready` and execution-input gating |
| fixed-point correlation | confirm hardware-facing numeric identity |
| phase behavior | confirm phase-word and coupling evolution |
| delay behavior | confirm target/current frequency lag |
| thermal behavior | confirm model thermal-state correlation and physical temperature response |
| gamma behavior | confirm deterministic correlated gamma state |
| coherence behavior | confirm pair, cluster, supercluster, and global phase coherence |
| stability telemetry | confirm `C(t)`, `P(t)`, and `C_minus_P` |
| telemetry consistency | confirm counters, summaries, and trace outputs |
| timing behavior | measure execution timing and phase-update timing |
| switching activity | measure transition and implementation activity |
| electrical energy | measure voltage, current, power, and energy |
| physical thermal response | measure device and environment temperature behavior |
| benchmark repeatability | repeat qualified workload profiles |
| reference comparison | compare physical output with the qualified reference domain |

Each category maps to an explicit reference identity, interface field, invariant, or measurement record.

## 6. Balanced Ternary Logical Correctness Validation

Logical-correctness validation confirms that a physical implementation preserves the balanced ternary state and retained-result domain.

State domain:

`{-1, 0, 1}`

State roles:

| State | Role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

Validation inputs include:

- initial encoded ternary state vector;
- preload identity;
- explicit target requests;
- phase-derived targets;
- scheduler mode;
- transition fraction;
- request-lane profile;
- step count;
- deterministic vector-package profile.

Validation outputs include:

- per-tick packed ternary state;
- final packed ternary state;
- per-cell ternary state code;
- negative-state count;
- neutral-state count;
- positive-state count;
- pending-route count;
- transition-counter summary;
- scheduler-counter summary;
- invariant flags;
- trace digest;
- cell-trace digest.

Validation criteria:

| Metric | Required comparison |
|---|---|
| packed state vector | exact cycle comparison |
| per-cell state code | exact local-state comparison |
| state counts | population consistency |
| pending-route count | retained-route consistency |
| scheduler counts | execution-sequence consistency |
| invariant flags | all ten flags equal to `1` |
| trace digest | complete processor-tick trace identity |
| cell-trace digest | complete per-cell trace identity |

Exact integer state fields use direct equality against the qualified M15 golden domain and the M16 execution record.

## 7. Canonical Hardware Encoding Validation

Canonical two-bit hardware encoding:

`-1 → 2'b11`

`0 → 2'b00`

`1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding:

`-1 → 3`

`0 → 0`

`1 → 1`

Reserved integer code:

`2`

Qualified M15 default packed state width:

`16 cells × 2 bits = 32 bits`

Current M16 testbench packed state width:

`8 cells × 2 bits = 16 bits`

Packing relation:

`cell i → [2i+1:2i]`

M16 package symbols:

| State | Symbol | Encoding |
|---|---|---|
| `-1` | `FRP_TERN_NEG` | `2'b11` |
| `0` | `FRP_TERN_ZERO` | `2'b00` |
| `1` | `FRP_TERN_POS` | `2'b01` |
| reserved | `FRP_TERN_RESERVED` | `2'b10` |

Validation outputs include:

- encoded state per cell;
- packed state vector;
- reserved-state event counter;
- encode/decode comparison table;
- preload-state comparison;
- post-tick state comparison;
- state-domain invariant flag.

Required invariant:

`reserved_state_events = 0`

Required M16 invariant:

`FRP_INV_STATE_DOMAIN_VALID = 1`

## 8. Active Neutral Transition Routing Validation

Opposite-polarity execution follows the mandatory routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Validation metrics include:

- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`;
- `actual_direct_events`;
- pending-route allocation count;
- pending-route completion count;
- per-tick route-event trace;
- active-neutral invariant flag.

Routing test cases:

| Current state | Target state | Required path |
|---|---|---|
| `-1` | `1` | `-1 → 0`, retain route, later `0 → 1` |
| `1` | `-1` | `1 → 0`, retain route, later `0 → -1` |
| `-1` | `0` | `-1 → 0` |
| `1` | `0` | `1 → 0` |
| `0` | `-1` | `0 → -1` |
| `0` | `1` | `0 → 1` |

Current M16 RTL artifacts associated with route validation include:

- `../rtl/m16/frp_m16_request_lanes.sv`;
- `../rtl/m16/frp_m16_active_neutral.sv`;
- `../rtl/m16/frp_m16_pending_routes.sv`;
- `../rtl/m16/frp_m16_capacity_guard.sv`;
- `../rtl/m16/frp_m16_state_update.sv`;
- `../rtl/m16/frp_m16_assertions.sv`;
- `../rtl/m16/frp_m16_tb.sv`.

Required route invariant:

`actual_direct_events = 0`

Required M16 invariant:

`FRP_INV_ACTIVE_NEUTRAL_VALID = 1`

Required direct-event invariant:

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS = 1`

## 9. Pending Neutral-Route Validation

The qualified M15 pending-route record retains:

- cell index;
- target polarity;
- earliest ready tick.

Qualified M15 default queue capacity:

`16`

The current M16 pending-route state retains:

- per-cell pending-valid state;
- per-cell pending target polarity;
- pending completion candidate state;
- pending completion acceptance state;
- pending creation state;
- pending completion state;
- pending clear state;
- pending retention state.

Validation outputs include:

- pending-route count per tick;
- allocation sequence;
- cell-index sequence;
- target-state sequence;
- ready-tick sequence;
- completion sequence;
- retained-route sequence;
- capacity-deferred sequence;
- queue-overflow event count;
- pending-polarity invariant flag;
- pending non-overwrite result.

Validation criteria include:

- deterministic allocation order;
- deterministic ready-route processing order;
- route persistence across scheduler-ineligible ticks;
- route persistence across transition-capacity deferral;
- earliest-ready-tick enforcement in the M15 reference;
- pending completion from active neutral state `0`;
- pending completion priority before new explicit requests;
- exact pending-route count;
- exact route-completion sequence;
- retained polarity preservation;
- pending-route non-overwrite.

Required queue invariant:

`queue_overflow_events = 0`

Required M16 pending-route invariant:

`FRP_INV_PENDING_POLARITY_VALID = 1`

Required M16 queue invariant:

`FRP_INV_NO_QUEUE_OVERFLOW = 1`

## 10. Distributed Commit Validation

Qualified M15 default transition fraction:

`0.25`

Qualified M15 commit-capacity relation:

`max_changes = max(1, round(cells × transition_fraction))`

Qualified request-lane profiles:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Current M16 transition-capacity relation:

`maximum admitted state changes per enabled tick = REQUEST_LANES`

Current M16 testbench parameters:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| transition capacity | `2` |

Validation records include:

- eligible transition count;
- accepted transition count;
- capacity-rejected transition count;
- scheduler-rejected transition count;
- deferred transition count;
- completed pending-route count;
- current-tick state-change count;
- `switch_load`;
- `switch_load_numerator`;
- accepted-change mask;
- capacity-rejection mask;
- capacity remaining;
- capacity-exhausted state;
- scheduler state;
- per-tick update distribution.

Validation criteria:

| Metric | Required relation |
|---|---|
| `switch_load_peak` | does not exceed the qualified transition fraction |
| accepted transition count | equals admitted current-tick state changes |
| capacity-rejected count | records candidates outside available capacity |
| deferred transition count | retains state and route information |
| completed pending-route count | records admitted route completions |
| accepted-change mask | identifies admitted per-cell state changes |
| capacity remaining | records unused transition capacity |
| per-tick update distribution | matches the deterministic capacity order |

Qualified M15 relation:

`switch_load_peak <= transition_fraction`

Required M16 invariant:

`FRP_INV_TRANSITION_CAPACITY_VALID = 1`

## 11. Request-Lane Validation

Qualified request-lane processing order:

`ascending lane index`

Qualified M15 request-interface fields:

- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Qualified M15 default request-lane profile:

`4 lanes`

Current M16 request-interface fields:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

Current M16 testbench request-lane profile:

`2 lanes`

The current M16 request-lane execution records:

- request-valid state;
- request cell index;
- request target;
- duplicate-cell rejection;
- pending-busy rejection;
- scheduler rejection;
- capacity rejection;
- request-neutralized state;
- requested direct-event count;
- prevented direct-event count;
- neutral-routed event count;
- deterministic lane-order validity.

Validation outputs include:

- lane-valid sequence;
- cell-index sequence;
- target-state sequence;
- accepted-lane sequence;
- duplicate-rejected sequence;
- pending-busy-rejected sequence;
- scheduler-rejected sequence;
- capacity-rejected sequence;
- transition-capacity counter;
- resulting state events;
- resulting route events.

Validation criteria include:

- ascending lane-order preservation;
- exact accepted request sequence;
- exact rejection-class sequence;
- exact route-allocation sequence;
- exact transition-capacity behavior;
- exact packed-state result;
- no duplicate accepted cell index within one tick;
- no overwrite of an existing pending route.

Required M16 invariant:

`FRP_INV_REQUEST_LANE_ORDER_VALID = 1`

## 12. Scheduler Behavior Validation

Qualified scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Qualified scheduler-state profiles:

| Scheduler | Ticks | Recorded counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Qualified M15 scheduler phase push:

| Scheduler state | Phase push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all remaining states | `0.003` |

Current M16 scheduler modes:

- `FRP_MODE_FREE`;
- `FRP_MODE_7_1`;
- `FRP_MODE_1_7`.

Current M16 scheduler states:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`.

Physical validation confirms:

- selected scheduler mode;
- scheduler-state sequence;
- scheduler-count accuracy;
- request-service timing;
- commit-capacity timing;
- neutralize-capable timing;
- transition-eligibility timing;
- M15 phase-push selection;
- telemetry-capture timing.

Validation outputs include:

- tick trace;
- scheduler-mode trace;
- scheduler-state trace;
- scheduler-counter summary;
- state-specific timing summary;
- cycle-exact scheduler comparison;
- scheduler-count invariant flag.

Required scheduler counter relation:

`sum(scheduler-state counts) = recorded enabled ticks`

Required M16 invariant:

`FRP_INV_SCHEDULER_COUNTS_VALID = 1`

## 13. Hardware-Facing Numeric Validation

Qualified M15 primary numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Qualified `S32Q16` profile:

- signed;
- 32-bit width;
- 16 fractional bits;
- scale `65536`.

Qualified `S32Q30` profile:

- signed;
- 32-bit width;
- 30 fractional bits;
- scale `1073741824`.

Qualified `PHASE_U32` profile:

- unsigned;
- 32-bit width;
- full-cycle relation `2^32 phase units = 2π`;
- modulo `2^32` wrap.

Qualified rounding rule:

`round-to-nearest, half cases away from zero`

Qualified saturation rule:

`signed destination saturation`

Qualified multiplication rules:

`mul_q16 = round_shift(a × b, 16)`

`mul_q16_q30 = round_shift(a × b, 30)`

`mul_q30 = round_shift(a × b, 30)`

Digital execution validation uses exact integer comparison at the defined M15 numeric boundary.

The M16 retained-state execution boundary uses the canonical two-bit balanced ternary encoding and parameterized architectural counters.

Numeric validation preserves separate identities for:

- M15 fixed-point semantic fields;
- M15 phase and gamma fields;
- M16 packed ternary state fields;
- M16 request cell-index fields;
- M16 scheduler fields;
- M16 event counters;
- M16 invariant flags.

## 14. Trigonometric Lookup Validation

Qualified deterministic trigonometric profile:

`4096 entries`

Qualified address width:

`12 bits`

Qualified index relation:

`phase_word >> 20`

Qualified output type:

`S32Q30`

Qualified vector file:

`frp_m15_trig_lut_q30.vec`

Validation outputs include:

- lookup-image identity;
- address sequence;
- sine-output sequence;
- cosine-output sequence;
- SHA-256 manifest comparison;
- replay-mismatch count.

Lookup identity remains attached to the qualified M15 vector package.

Qualified trigonometric lookup result:

`PASS`

The phase-derived balanced ternary target generated from the qualified phase path is consumed by the M16 retained-state execution interface.

## 15. Kuramoto-Sakaguchi Phase Validation

Qualified M15 resonant pair interaction:

`sin(phase_j - phase_i - gamma_effective_i)`

Qualified default nominal phase lag:

`gamma = 0.30 × pi`

Qualified source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Qualified default nominal coupling strength:

`coupling_nominal = 0.28`

Qualified phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Qualified phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

Validation inputs include:

- phase preload;
- frequency preload;
- gamma state;
- scheduler state;
- hierarchical weights;
- thermal node factors;
- deterministic gamma-target stimulus.

Validation outputs include:

- phase word per cell per tick;
- phase velocity per cell per tick;
- coupling field per cell per tick;
- gamma-effective value per cell per tick;
- global phase coherence;
- phase-derived balanced ternary target;
- cycle-exact phase comparison.

Cross-layer validation relation:

`qualified M15 phase evolution`

↓

`qualified phase-derived balanced ternary target`

↓

`M16 packed target-state input`

↓

`M16 temporal retained-state execution`

## 16. Hierarchical Fractal Coupling Validation

The qualified semantic architecture uses a dyadic hierarchical ultrametric topology.

Qualified default cell count:

`16`

Qualified default hierarchy depth:

`4`

Hierarchy-depth relation:

`cells.bit_length() - 1`

Hierarchical distance between distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Qualified default fractal exponent:

`fractal_alpha = 0.70`

Qualified topology exactness marker:

`fixed_point_topology_sum_exact = True`

Qualified thermal-topology exactness marker:

`fixed_point_thermal_sum_exact = True`

Validation outputs include:

- hierarchy configuration;
- shell-weight identity;
- phase-topology normalization result;
- thermal-topology normalization result;
- coupling accumulation result;
- multiscale group identity;
- fixed-point coefficient digest.

Exact aggregate phase-topology relation:

`sum(all off-diagonal Q30 phase-coupling coefficients) = cells × 2^30`

Exact aggregate thermal-topology relation:

`sum(all off-diagonal Q30 thermal-diffusion coefficients) = cells × 2^30`

The topology records remain part of the qualified M15 reference package inherited by M16.

## 17. Stateful Delay Validation

Each qualified semantic processor cell maintains:

- base frequency;
- target frequency;
- current frequency.

Qualified frequency-target relation:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

Qualified delayed response:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Qualified default delay coefficient:

`delay_alpha = 0.30`

Validation outputs include:

- base frequency;
- target frequency;
- current frequency;
- frequency lag;
- per-tick frequency sequence;
- cycle-exact delay-state comparison.

The remaining frequency lag feeds:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

Cross-layer state relation:

`M16 retained balanced ternary state`

↓

`qualified M15 frequency target`

↓

`qualified delayed frequency response`

↓

`qualified phase evolution`

↓

`phase-derived balanced ternary target`

↓

`M16 retained-state execution`

## 18. Distributed Thermal-State Validation

Each qualified semantic processor cell tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

Qualified generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Qualified thermal-dissipation relation:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

Qualified default thermal parameters:

| Parameter | Value |
|---|---:|
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| thermal diffusion gain | `0.035` |
| thermal topology exponent | `1.20` |
| thermal coupling gain | `2.50` |

Qualified exactness marker:

`fixed_point_thermal_sum_exact = True`

Digital-correlation outputs include:

- generated power per cell;
- local heat per cell;
- local overload per cell;
- global heat;
- thermal-diffusion state;
- thermal exactness marker.

The M16 execution layer supplies:

- retained-state transition events;
- accepted-change counts;
- switching-load numerator;
- neutral-routed event counts;
- pending-route completion events.

Physical thermal measurements are recorded separately from model thermal-state quantities and use the same workload identity, execution window, state-transition record, and timing reference.

Thermal state participates in endogenous processor feedback.

## 19. Thermal Coupling Feedback Validation

The qualified semantic reference calculates local thermal overload as:

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

Validation outputs:

- local overload sequence;
- thermal node-factor sequence;
- coupling-field sequence;
- coherence sequence;
- dynamic-stability sequence.

The thermal-feedback sequences remain part of the qualified M15 semantic and implementation-mapping foundation.

The M16 RTL execution layer receives the phase-derived packed target vector through `target_q` and executes the retained balanced ternary state transitions.

## 20. Correlated Gamma Drift Validation

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

The M15 verification-sideband inputs are:

- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Validation outputs:

- target refresh sequence;
- gamma-noise target sequence;
- correlated gamma-noise state;
- effective local gamma;
- cycle-exact gamma comparison.

## 21. Nonlinear Coherence-Compression Validation

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

Validation outputs:

- thermal-overload mean;
- margin pressure;
- compression factor;
- raw phase coherence;
- effective coherence;
- cycle-exact compression comparison.

## 22. Multiscale Phase-Coherence Validation

The qualified global phase-order relation is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation is applied to the hierarchical groups.

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

Validation compares the complete coherence trajectory under the same preload, workload, scheduler, and vector identities.

Phase synchronization and phase coherence are not interchangeable.

The global phase-order parameter `R(t)` is not identical to the general endogenous structural coherence quantity `C(t)`.

## 23. Operational Coherence and Dynamic-Stability Validation

The qualified operational coherence relation is:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

The qualified destabilizing-load relation is:

`P = heat + switch_load`

The qualified dynamic-stability margin is:

`C_minus_P = C - P`

The qualified validation condition is:

`C_minus_P_min > 0.0`

The qualified semantic correlation markers are:

`semantic_C_minus_P_sign_match = True`

`semantic_boundary_order_match = True`

Validation outputs:

- `C` per tick;
- `P` per tick;
- `C_minus_P` per tick;
- minimum `C_minus_P`;
- final `C_minus_P`;
- first stability-boundary crossing identity;
- sign-sequence correlation;
- boundary-order correlation.

FRP operational `C` and `P` are processor-specific quantities.

Physical electrical power uses the separate symbol `P_elec` in this document.

## 24. Phase-Derived Ternary Target Validation

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

The M16 RTL core receives the phase-derived packed target vector through:

`target_q`

The M16 RTL core also receives explicit request-lane inputs through:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

Validation outputs:

- phase-derived target per cell;
- explicit request target per lane;
- target arbitration result;
- resulting route event;
- resulting retained state.

The retained balanced ternary state domain is:

`{-1, 0, 1}`

The opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity retained-state transitions are forbidden.

## 25. Structured Telemetry Consistency Validation

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

Processor-tick trace fields include domains associated with:

- tick;
- scheduler state;
- packed ternary state;
- pending-route count;
- negative, neutral, and positive state counts;
- switch load;
- route counters;
- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`.

Per-cell trace fields include domains associated with:

- cell identifier;
- ternary state code;
- phase word;
- target frequency;
- current frequency;
- frequency lag;
- generated power;
- heat;
- thermal overload;
- gamma-noise state;
- effective gamma;
- thermal node factor;
- coupling field.

The M16 RTL execution boundary exposes:

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler-state counters;
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

The M16 executable RTL testbench records:

| Field | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The M16 FPGA integration boundary additionally exposes:

`core_ready`

The qualified FPGA terminal invariant vector is:

`invariant_flags = 1111111111`

Candidate physical telemetry interfaces:

- memory-mapped register interface;
- debug bus;
- scan-visible register set;
- UART debug stream;
- trace buffer;
- logic-analyzer signal group;
- structured host-side export;
- on-chip trace SRAM;
- external test port.

## 26. Current SystemVerilog Correlation Interface

### Qualified M15 Correlation Interface

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

`rtl/m16/frp_m16_core.sv`

The M16 shared package is:

`rtl/m16/frp_m16_pkg.sv`

The M16 core parameters are:

| Parameter | Relation or default |
|---|---|
| `CELLS` | default `16` |
| `STATE_BITS` | canonical value `2` |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` |
| `CELL_INDEX_BITS` | `(CELLS <= 1) ? 1 : $clog2(CELLS)` |
| `COUNTER_BITS` | canonical value `32` |

The request-lane relation is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

The qualified profiles include:

| Cells | Request lanes | Packed retained-state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

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

The ten M16 integrated invariant flags are:

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

### Current M16 FPGA Integration Interface

The current target-independent FPGA integration top is:

`fpga/m16/frp_m16_fpga_top.sv`

The FPGA integration top uses:

- asynchronous external reset input `rst_n_async`;
- two-stage synchronous reset release;
- readiness output `core_ready`;
- tick gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- the M16 RTL core input and output domains.

The qualified readiness-gating relations are:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

## 27. M15 Exact Tick Execution Order

### Qualified M15 Tick Order

The M15 quantized shadow and RTL reference-core domain use the same ordered 26-stage tick sequence:

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

### Current M16 Retained-State Tick Order

For every enabled M16 RTL tick:

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

Physical correlation records the applicable M15 and M16 execution order at their respective digital trace boundaries.

## 28. Deterministic RTL Comparison Vector Package

The qualified M15 schema is:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

The qualified package file count is:

`10`

The package files are:

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

The M15 qualification workflow generates two independent vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

The workflow compares the directories with:

`diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b`

The qualified deterministic package digest is:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The qualified deterministic regeneration result is:

`10/10 files byte-identical`

The qualified self-test marker is:

`vector_determinism_pass = True`

The M15-to-M16 compatibility record is:

`docs/m16_m15_vector_replay_compatibility_report.md`

The recorded M15-to-M16 compatibility result is:

`PASS`

The physical validation package retains the vector-package identity for each replay and measurement campaign.

## 19. Thermal Coupling Feedback Validation

The qualified semantic reference calculates local thermal overload as:

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

Validation outputs:

- local overload sequence;
- thermal node-factor sequence;
- coupling-field sequence;
- coherence sequence;
- dynamic-stability sequence.

The thermal-feedback sequences remain part of the qualified M15 semantic and implementation-mapping foundation.

The M16 RTL execution layer receives the phase-derived packed target vector through `target_q` and executes the retained balanced ternary state transitions.

## 20. Correlated Gamma Drift Validation

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

The M15 verification-sideband inputs are:

- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Validation outputs:

- target refresh sequence;
- gamma-noise target sequence;
- correlated gamma-noise state;
- effective local gamma;
- cycle-exact gamma comparison.

## 21. Nonlinear Coherence-Compression Validation

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

Validation outputs:

- thermal-overload mean;
- margin pressure;
- compression factor;
- raw phase coherence;
- effective coherence;
- cycle-exact compression comparison.

## 22. Multiscale Phase-Coherence Validation

The qualified global phase-order relation is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order relation is applied to the hierarchical groups.

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

Validation compares the complete coherence trajectory under the same preload, workload, scheduler, and vector identities.

Phase synchronization and phase coherence are not interchangeable.

The global phase-order parameter `R(t)` is not identical to the general endogenous structural coherence quantity `C(t)`.

## 23. Operational Coherence and Dynamic-Stability Validation

The qualified operational coherence relation is:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

The qualified destabilizing-load relation is:

`P = heat + switch_load`

The qualified dynamic-stability margin is:

`C_minus_P = C - P`

The qualified validation condition is:

`C_minus_P_min > 0.0`

The qualified semantic correlation markers are:

`semantic_C_minus_P_sign_match = True`

`semantic_boundary_order_match = True`

Validation outputs:

- `C` per tick;
- `P` per tick;
- `C_minus_P` per tick;
- minimum `C_minus_P`;
- final `C_minus_P`;
- first stability-boundary crossing identity;
- sign-sequence correlation;
- boundary-order correlation.

FRP operational `C` and `P` are processor-specific quantities.

Physical electrical power uses the separate symbol `P_elec` in this document.

## 24. Phase-Derived Ternary Target Validation

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

The M16 RTL core receives the phase-derived packed target vector through:

`target_q`

The M16 RTL core also receives explicit request-lane inputs through:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

Validation outputs:

- phase-derived target per cell;
- explicit request target per lane;
- target arbitration result;
- resulting route event;
- resulting retained state.

The retained balanced ternary state domain is:

`{-1, 0, 1}`

The opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity retained-state transitions are forbidden.

## 25. Structured Telemetry Consistency Validation

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

Processor-tick trace fields include domains associated with:

- tick;
- scheduler state;
- packed ternary state;
- pending-route count;
- negative, neutral, and positive state counts;
- switch load;
- route counters;
- global heat;
- global phase coherence;
- `C`;
- `P`;
- `C_minus_P`.

Per-cell trace fields include domains associated with:

- cell identifier;
- ternary state code;
- phase word;
- target frequency;
- current frequency;
- frequency lag;
- generated power;
- heat;
- thermal overload;
- gamma-noise state;
- effective gamma;
- thermal node factor;
- coupling field.

The M16 RTL execution boundary exposes:

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler-state counters;
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

The M16 executable RTL testbench records:

| Field | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The M16 FPGA integration boundary additionally exposes:

`core_ready`

The qualified FPGA terminal invariant vector is:

`invariant_flags = 1111111111`

Candidate physical telemetry interfaces:

- memory-mapped register interface;
- debug bus;
- scan-visible register set;
- UART debug stream;
- trace buffer;
- logic-analyzer signal group;
- structured host-side export;
- on-chip trace SRAM;
- external test port.

## 26. Current SystemVerilog Correlation Interface

### Qualified M15 Correlation Interface

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

`rtl/m16/frp_m16_core.sv`

The M16 shared package is:

`rtl/m16/frp_m16_pkg.sv`

The M16 core parameters are:

| Parameter | Relation or default |
|---|---|
| `CELLS` | default `16` |
| `STATE_BITS` | canonical value `2` |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` |
| `CELL_INDEX_BITS` | `(CELLS <= 1) ? 1 : $clog2(CELLS)` |
| `COUNTER_BITS` | canonical value `32` |

The request-lane relation is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

The qualified profiles include:

| Cells | Request lanes | Packed retained-state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

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

The ten M16 integrated invariant flags are:

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

### Current M16 FPGA Integration Interface

The current target-independent FPGA integration top is:

`fpga/m16/frp_m16_fpga_top.sv`

The FPGA integration top uses:

- asynchronous external reset input `rst_n_async`;
- two-stage synchronous reset release;
- readiness output `core_ready`;
- tick gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- the M16 RTL core input and output domains.

The qualified readiness-gating relations are:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

## 27. M15 Exact Tick Execution Order

### Qualified M15 Tick Order

The M15 quantized shadow and RTL reference-core domain use the same ordered 26-stage tick sequence:

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

### Current M16 Retained-State Tick Order

For every enabled M16 RTL tick:

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

Physical correlation records the applicable M15 and M16 execution order at their respective digital trace boundaries.

## 28. Deterministic RTL Comparison Vector Package

The qualified M15 schema is:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

The qualified package file count is:

`10`

The package files are:

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

The M15 qualification workflow generates two independent vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

The workflow compares the directories with:

`diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b`

The qualified deterministic package digest is:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The qualified deterministic regeneration result is:

`10/10 files byte-identical`

The qualified self-test marker is:

`vector_determinism_pass = True`

The M15-to-M16 compatibility record is:

`docs/m16_m15_vector_replay_compatibility_report.md`

The recorded M15-to-M16 compatibility result is:

`PASS`

The physical validation package retains the vector-package identity for each replay and measurement campaign.

## 29. Vector Replay and Capture Order

The qualified M15 replay order is:

1. parse the vector row;
2. drive input signals before the active clock edge;
3. apply verification-sideband stimulus;
4. execute one processor clock edge;
5. allow registered outputs to settle;
6. sample post-tick outputs;
7. compare sampled outputs against expected integer values;
8. execute invariant assertions;
9. stop immediately on mismatch.

The qualified exact integer comparison rule is:

`actual integer field == expected integer field`

The M16 RTL replay boundary applies the following execution sequence:

1. establish reset state;
2. release reset;
3. select the scheduler mode;
4. drive the phase-derived packed target vector;
5. drive explicit request-lane inputs;
6. execute an enabled processor tick;
7. sample retained state and pending-route state;
8. sample scheduler, request, capacity, and event outputs;
9. execute the architectural assertion layer;
10. validate all ten integrated invariant flags;
11. validate terminal event totals;
12. validate the deterministic completion marker.

The M16 FPGA integration replay additionally applies:

1. assert `rst_n_async`;
2. release `rst_n_async`;
3. complete the two-stage synchronous reset release;
4. wait for `core_ready = 1`;
5. apply scheduler, target, and request inputs;
6. execute an enabled core tick;
7. capture FPGA integration outputs;
8. compare the outputs with the M16 RTL execution boundary.

A physical capture implementation can apply the same logical sequence through synchronized host stimulus, processor clocking, output capture, and post-run comparison.

## 30. RTL Assertion Correlation

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

`rtl/m16/frp_m16_assertions.sv`

The M16 assertion layer covers:

- reset establishment of active-neutral retained state;
- reset clearing of pending routes;
- reset clearing of scheduler counters;
- retained-state domain validation;
- pending-route domain validation;
- disabled-tick state retention;
- disabled-tick pending-route retention;
- accepted-change authorization;
- direct opposite-polarity writeback exclusion;
- active-neutral first-leg execution;
- retained pending-polarity validation;
- deferred pending-route retention;
- pending completion from retained state `0`;
- scheduler-mode validation;
- scheduler-state validation;
- scheduler count-sum validation;
- `free` scheduler execution;
- `7/1` scheduler execution;
- `1/7` scheduler execution;
- scheduler-counter retention;
- scheduler-counter clearing;
- clear-plus-tick counter behavior;
- request acceptance and rejection separation;
- disabled-tick request rejection;
- request-lane capacity enforcement;
- accepted-change count correlation;
- neutral-route mask correlation;
- capacity-remaining correlation;
- capacity-exhausted correlation;
- switch-load numerator correlation;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- requested-direct and prevented-direct event correlation;
- prevented-direct and neutral-routed event correlation;
- all ten integrated invariant flags.

The M16 assertion execution result is:

`PASS`

The validation plan applies these assertion domains to:

- RTL simulation;
- FPGA integration simulation;
- target-specific FPGA execution replay;
- gate-level simulation;
- ASIC-oriented verification;
- physical trace post-processing.

## 31. Floating-to-Quantized Reference Correlation

The qualified floating semantic reference to quantized hardware-shadow correlation records:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`neutral_route_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

The qualified semantic correlation result is:

`5 / 5 required semantic correlation matches = 1.0`

The qualified maximum numeric errors are:

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

The qualified numeric correlation result is:

`PASS`

These relations define the semantic preservation boundary inherited by the M16 RTL execution layer and the target-independent FPGA preparation layer.

## 32. Exact Quantized Deterministic Replay

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

The deterministic replay qualification result is:

`PASS`

The M16 replay compatibility record is:

`docs/m16_m15_vector_replay_compatibility_report.md`

The recorded M15-to-M16 compatibility status is:

`PASS`

The physical validation target extends the deterministic integer comparison domain through later target-specific FPGA, ASIC-oriented, and measured execution layers.

## 33. Qualification Closure

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

The qualified M15 closure results are:

| Qualification record | Result |
|---|---:|
| self-test checks | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The M15 qualification closure result is:

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

The M16 RTL source boundary contains ten SystemVerilog artifacts:

1. `rtl/m16/frp_m16_pkg.sv`;
2. `rtl/m16/frp_m16_scheduler.sv`;
3. `rtl/m16/frp_m16_request_lanes.sv`;
4. `rtl/m16/frp_m16_pending_routes.sv`;
5. `rtl/m16/frp_m16_active_neutral.sv`;
6. `rtl/m16/frp_m16_capacity_guard.sv`;
7. `rtl/m16/frp_m16_state_update.sv`;
8. `rtl/m16/frp_m16_core.sv`;
9. `rtl/m16/frp_m16_assertions.sv`;
10. `rtl/m16/frp_m16_tb.sv`.

The M16 RTL documentation boundary contains:

- `rtl/m16/README.md`;
- `rtl/m16/ARTIFACTS.md`;
- `rtl/m16/SIMULATION.md`;
- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`.

The M16 RTL qualification result is:

`PASS`

The M16 RTL closure status is:

`M16 RTL EXECUTION LAYER CLOSED`

### M16 FPGA Preparation Closure

The M16 target-independent FPGA preparation artifacts are:

- `fpga/m16/frp_m16_fpga_top.sv`;
- `fpga/m16/frp_m16_fpga_tb.sv`;
- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`.

The M16 FPGA preparation qualification result is:

`PASS`

The M16 FPGA preparation closure status is:

`M16 FPGA PREPARATION LAYER CLOSED`

The current qualification chain is:

`M15 semantic and implementation-mapping foundation`

↓

`M16 RTL execution boundary`

↓

`M16 architectural assertion layer`

↓

`M16 executable RTL simulation`

↓

`M16 target-independent FPGA integration boundary`

↓

`M16 FPGA preparation qualification`

## 34. Physical Validation Stage Model

The physical validation plan uses staged correlation.

### Stage A — Qualified M15 Deterministic Reference

Reference subjects:

- floating semantic execution;
- quantized hardware-shadow execution;
- cycle-exact traces;
- deterministic vector package;
- SystemVerilog interface mapping;
- assertion correlation;
- reference equivalence;
- qualification closure.

Qualification state:

`PASS`

### Stage B — Closed M16 RTL Execution Layer

Execution subjects:

- canonical balanced ternary retained-state encoding;
- explicit RTL execution semantics;
- scheduler sequencing;
- request-lane arbitration;
- pending-route retention and completion;
- active-neutral state-transition sequencing;
- transition-capacity enforcement;
- retained-state writeback;
- architectural telemetry;
- integrated invariant flags;
- executable assertion correlation;
- M15 deterministic vector compatibility.

Qualification state:

`M16 RTL EXECUTION LAYER CLOSED`

### Stage C — FPGA Correlation

The current target-independent FPGA preparation subjects are:

- FPGA integration-top elaboration;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- execution-input gating;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten integrated invariant flags.

Current preparation state:

`M16 FPGA PREPARATION LAYER CLOSED`

Target-specific FPGA execution subjects include:

- target-device synthesis;
- implementation constraints;
- achieved timing;
- utilization;
- trace capture;
- deterministic vector replay;
- cycle-exact output comparison;
- electrical measurement;
- physical temperature measurement.

### Stage D — ASIC-Oriented Implementation Correlation

Reference subjects:

- datapath partitioning;
- retained-state storage;
- pending-route storage;
- clocking and control;
- synthesis;
- timing;
- switching activity;
- power, performance, and area records;
- test interfaces;
- trace interfaces.

### Stage E — Physical Measurement Correlation

Reference subjects:

- device and setup identity;
- workload identity;
- vector-package identity;
- timing measurement;
- electrical power and energy measurement;
- physical temperature measurement;
- telemetry and trace capture;
- repeatability;
- correlation review.

## 35. Timing Behavior Validation

Timing validation measures execution across clocks, ticks, scheduler phases, update windows, readiness boundaries, and trace-capture boundaries.

Candidate timing measurements:

- reference clock frequency;
- achieved processor clock frequency;
- clock period;
- asynchronous reset-assertion duration;
- synchronous reset-release duration;
- `core_ready` activation time;
- preload duration;
- request setup time;
- request hold time;
- scheduler-state duration;
- tick duration;
- active-neutral first-leg latency;
- pending-route completion latency;
- phase-update latency;
- delay-datapath latency;
- thermal-datapath latency;
- coherence-datapath latency;
- telemetry sampling timing;
- trace-buffer write timing;
- host transfer timing.

Validation outputs:

- timing trace;
- clock profile;
- reset and readiness timing record;
- scheduler timing report;
- route-latency report;
- datapath-latency report;
- trace-capture timing report;
- cycle-correlation map.

Cycle-count measurements and wall-clock measurements are recorded as separate fields.

Every timing result retains:

- implementation identity;
- toolchain identity;
- target identity;
- clock constraint identity;
- workload identity;
- vector-package identity;
- capture configuration.

## 36. Switching Activity Validation

Switching-activity validation measures state-transition behavior and implementation activity under a defined workload.

Candidate logical activity measurements:

- requested transition events;
- requested direct-transition events;
- prevented direct-transition events;
- active-neutral insertion events;
- neutral-routed events;
- actual direct events;
- accepted transition events;
- rejected transition events;
- deferred transition events;
- completed pending routes;
- per-tick state-change count;
- accepted-change count;
- switch-load numerator;
- `switch_load`.

The current M16 terminal event relations are:

| Event field | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

The current M16 capacity relations are:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

Candidate implementation activity measurements:

- clock activity;
- reset and readiness-control activity;
- scheduler-control activity;
- request-lane arbitration activity;
- pending-route activity;
- retained-state writeback activity;
- transition-capacity control activity;
- fixed-point arithmetic activity;
- trigonometric lookup activity;
- hierarchical coupling activity;
- thermal-processing activity;
- gamma-processing activity;
- coherence-processing activity;
- memory activity;
- trace and debug activity.

Validation outputs:

- switching-activity table;
- transition-activity trace;
- `switch_load` summary;
- scheduler-correlated activity profile;
- per-domain activity report;
- workload identity;
- target identity;
- capture-window identity.

## 37. Electrical Power and Energy Validation

Physical electrical power uses the symbol:

`P_elec`

The FRP model destabilizing load retains the symbol:

`P(t)`

These quantities are recorded as separate domains.

Candidate electrical measurements:

- supply voltage;
- supply current;
- instantaneous electrical power;
- average electrical power;
- peak electrical power;
- idle electrical power;
- active electrical power;
- energy per benchmark run;
- energy per processor tick;
- energy per semantic command;
- energy per committed transition;
- energy per scheduler mode;
- energy per validation profile.

The electrical relations are:

`P_elec(t) = V(t) × I(t)`

`E_run = integral of P_elec(t) over the measured run window`

`E_per_tick = E_run / measured_ticks`

Candidate derived metrics:

| Metric | Recorded domain |
|---|---|
| average `P_elec` | profile-level electrical load |
| peak `P_elec` | transient electrical load |
| `E_run` | benchmark-level electrical energy |
| `E_per_tick` | tick-normalized energy |
| energy per semantic command | workload-normalized energy |
| energy per committed transition | transition-normalized energy |

Every electrical result retains:

- exact workload identity;
- timing-window identity;
- measured tick count;
- voltage-rail identity;
- instrument identity;
- sampling profile;
- calibration identity;
- target and board identity.

## 38. Physical Thermal Behavior Validation

Physical thermal behavior measures device and environment temperature during defined execution profiles.

Candidate measurements:

- ambient temperature;
- starting device temperature;
- ending device temperature;
- peak device temperature;
- temperature delta;
- temperature over time;
- temperature per benchmark profile;
- temperature per scheduler mode;
- temperature under repeated runs;
- cooling-interval behavior;
- thermal steady-state approach;
- local hotspot observations where instrumentation permits.

Candidate physical thermal outputs:

- ambient temperature record;
- device temperature trace;
- peak temperature summary;
- temperature-delta summary;
- repeated-run thermal profile;
- cooling profile;
- workload-correlated thermal report.

Every physical thermal result retains:

- exact workload identity;
- board or device identity;
- package and heatsink identity;
- airflow condition;
- ambient condition;
- sensor identity;
- sensor position;
- sampling rate;
- run duration;
- cooling interval.

## 39. Model Thermal State and Physical Temperature Correlation

The FRP model thermal state and measured physical temperature are separate measurement domains connected through shared workload identity and execution timing.

Model thermal outputs include:

- generated power state;
- local heat state;
- local thermal overload;
- global heat state;
- thermal node factor;
- `fixed_point_thermal_sum_exact`.

Physical outputs include:

- electrical power;
- electrical energy;
- device temperature;
- ambient temperature;
- temperature delta;
- cooling response.

The correlation record contains:

`reference workload identity`

+

`reference tick and trace identity`

+

`measured timing identity`

+

`measured electrical profile`

+

`measured physical thermal profile`

Model heat, thermal overload, thermal node factor, electrical power, electrical energy, and physical temperature retain separate field identities.

The correlation package records the shared workload, tick window, execution profile, device, setup, and measurement interval.

## 40. Benchmark Repeatability Validation

Benchmark repeatability applies the same qualified profile across repeated executions and records each result.

The qualified default semantic-reference command is:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

The qualified full-trace command is:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

The qualified self-test command is:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

The qualified M15 benchmark-matrix export command is:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

The qualified M15 vector-package export command is:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

The Python executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The structured-output schema remains:

`frp.structured_output.v1.7.0`

The benchmark-matrix schema remains:

`frp.m3.benchmark_matrix.v1.7.0`

Physical benchmark profiles define:

- implementation identifier;
- target identifier;
- cell count;
- hierarchy depth;
- request-lane count;
- preload identity;
- scheduler mode;
- step count;
- transition fraction;
- deterministic gamma-target profile;
- vector-package digest;
- RTL source identity;
- FPGA integration source identity;
- clock profile;
- reset profile;
- readiness profile;
- measurement interval;
- telemetry mode;
- run count.

Repeatability outputs:

- run count;
- exact digital match count;
- invariant match count;
- terminal event-total match count;
- timing mean and spread;
- electrical power mean and spread;
- energy mean and spread;
- temperature mean and spread;
- trace comparison;
- benchmark summary table.

## 41. Current Default Validation Profile

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

The qualified M16 executable RTL testbench profile is:

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
| RTL execution result | `PASS` |

### Current M16 FPGA Preparation Profile

The qualified FPGA integration-testbench profile is:

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
| FPGA preparation result | `PASS` |

The M15, M16 RTL, and M16 FPGA preparation profiles retain separate execution and evidence identities.

## 42. Current Scaling Profiles

The qualified M15 scaling profiles are:

| Cells | Hierarchy Depth | Request Lanes | `C_minus_P_min` | Switch Load Peak |
|---:|---:|---:|---:|---:|
| `8` | `3` | `2` | `0.828887939453125` | `0.25` |
| `16` | `4` | `4` | `0.6142730712890625` | `0.25` |
| `32` | `5` | `8` | `0.6628875732421875` | `0.25` |

Each qualified M15 scaling profile records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The inherited request-lane relation is:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

The packed retained-state profiles are:

| Cells | Request Lanes | Packed State Width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

The M16 RTL package records the same request-lane relation.

These profiles retain separate workload, hierarchy, request-lane, packed-state, trace, and qualification identities.

## 43. Current M15 Benchmark-Matrix Validation

The qualified schema is:

`frp.m3.benchmark_matrix.v1.7.0`

The qualified rows are:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

The qualified row count is:

`5`

The matrix records:

- floating semantic execution;
- quantized hardware-shadow execution;
- cycle-exact vector generation;
- SystemVerilog correlation-contract generation;
- M15 qualification closure.

The M15 benchmark-matrix identity remains attached to the v1.7.0 schema.

## 44. Current Comparative Architecture Evidence

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

Normalized activity cost, peak temperature proxy, model thermal state, operation counts, measured electrical power, measured electrical energy, and measured physical temperature retain separate metric identities.

Physical validation records the same semantic workload identity with separate timing, electrical, thermal, device, and setup fields.

## 45. Current Hardware-Sensitivity Evidence

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

The physical validation record stores technology, device, workload, timing, electrical, thermal, instrument, and setup identities separately from the coefficient-sensitivity package.

## 46. Historical v0.9.3 Transition Benchmark Repeatability

The repository preserves the historical v0.9.3 transition benchmark as a separate release-specific evidence contour.

The historical reference command is:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The historical architecture set is:

- `binary_style_forced_switch`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `frp_distributed_resonant`.

The historical benchmark evidence source is:

`../TEST_REPORT_v0_9_3.md`

The recorded historical benchmark is:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

The recorded values used in the heat-peak relation are:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

The exact ratio is:

`0.051000 / 0.003250 = 15.6923076923`

The recorded numerical representation is:

`15.69× lower heat_peak`

`93.63% lower heat_peak`

The historical contour retains its original model, workload, metric definitions, release identity, and evidence source.

## 47. Evidence-Domain Separation for Physical Validation

The physical validation plan preserves seven distinct evidence contours.

### 47.1 Preliminary Kuramoto Contour

Recorded subject:

`simplified oscillator phase synchronization under external driving`

Primary records:

- `../models/kuramoto_frp_background_model.md`;
- `../simulations/initial_kuramoto_result.md`.

### 47.2 Historical v0.9.3 Transition Contour

Recorded subject:

`route activity, switching load, historical heat_peak, and historical dynamic stability`

Primary evidence:

`../TEST_REPORT_v0_9_3.md`

### 47.3 Qualified FRP v1.7.0 Semantic Contour

Recorded subject:

`resonant phase dynamics, hierarchical coherence, delay, distributed thermal state, gamma drift, balanced ternary routing, and C(t) - P(t)`

Primary executable:

`../frp_prototype_v1_7_0.py`

Structured-output schema:

`frp.structured_output.v1.7.0`

### 47.4 Qualified M15 Implementation-Mapping Contour

Recorded subject:

`fixed-point mapping, quantized execution, cycle-exact traces, RTL vectors, interface mapping, equivalence, and qualification closure`

Primary architecture document:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

Qualification state:

`41 / 41 PASS`

### 47.5 Current M16 RTL Execution Contour

Recorded subject:

`scheduler execution, request-lane arbitration, pending-route retention, active-neutral routing, transition-capacity enforcement, retained-state writeback, architectural assertions, and integrated invariant flags`

Primary source directory:

`../rtl/m16/`

Primary closure record:

`../rtl/m16/CLOSURE.md`

Qualification state:

`M16 RTL EXECUTION LAYER CLOSED`

### 47.6 Current M16 FPGA Preparation Contour

Recorded subject:

`FPGA integration top, executable integration testbench, reset synchronization, core readiness, execution-input gating, scheduler propagation, request-interface propagation, active-neutral execution, pending-route completion, and invariant propagation`

Primary source directory:

`../fpga/m16/`

Primary closure record:

`../fpga/m16/CLOSURE.md`

Qualification state:

`M16 FPGA PREPARATION LAYER CLOSED`

This contour is target-independent.

### 47.7 Target-Specific Physical Measurement Contour

Recorded subject:

`implementation timing, switching activity, electrical power, electrical energy, physical temperature, trace identity, and repeatability under a recorded device and setup profile`

Each contour retains its architecture identifiers, workload, metric definitions, qualification state, and evidence records.

## 48. Comparison Against the Current M15 Reference

The qualified M15 reference commands are:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

The M15-to-M16 digital comparison categories are:

- balanced ternary state validity;
- final state sequence;
- per-tick state sequence;
- scheduler sequence;
- request-lane order;
- active neutral-route sequence;
- pending-route sequence;
- route counters;
- accepted-change count;
- capacity state;
- switch-load numerator;
- retained-state identity;
- integrated invariant flags;
- deterministic terminal markers.

The semantic and implementation-mapping comparison categories are:

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
- cell-trace identity;
- vector-package identity.

The physical measurement comparison categories are:

- measured clock timing;
- measured execution timing;
- measured switching activity;
- measured electrical power;
- measured electrical energy;
- measured physical temperature;
- measurement-window identity;
- device identity;
- setup identity;
- instrument identity.

Comparison output includes:

- reference configuration identity;
- reference preload identity;
- vector-package identity;
- M16 RTL source identity;
- FPGA integration source identity;
- reference output;
- RTL execution output;
- target-specific physical implementation output;
- exact digital comparison table;
- timing comparison table;
- electrical measurement table;
- physical thermal measurement table;
- trace comparison record;
- measurement setup description;
- validation summary.

## 49. Measurement Protocol Structure

A physical validation protocol records the following information.

### 49.1 Device and Setup Identity

- implementation type;
- FPGA, ASIC, board, or prototype identifier;
- target-device identifier;
- silicon or device revision;
- bitstream identifier;
- firmware identifier;
- RTL source identifier;
- FPGA integration-source identifier;
- implementation identifier;
- source commit identifier;
- toolchain identity;
- clock configuration;
- reset configuration;
- readiness configuration;
- power-supply configuration;
- cooling configuration;
- measurement instruments;
- calibration records;
- temperature measurement method;
- host system;
- testbench version;
- trace-capture configuration.

### 49.2 Reference Identity

- FRP version;
- milestone;
- executable semantic-reference file;
- structured-output schema;
- benchmark-matrix schema;
- M15 implementation-mapping artifact schemas;
- M15 vector-package digest;
- preload digest;
- trigonometric lookup identity;
- workload digest;
- reference-output digest;
- M16 RTL source identity;
- M16 FPGA integration-source identity;
- M16 qualification-record identity;
- validation-index identity.

The current release identity is:

`FRP v1.8.0`

The current milestone is:

`M16 — RTL Core Realization and Execution Semantics Package`

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The structured-output schema remains:

`frp.structured_output.v1.7.0`

The benchmark-matrix schema remains:

`frp.m3.benchmark_matrix.v1.7.0`

The qualified M15 vector-package digest is:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

### 49.3 Execution Profile

- test-profile name;
- implementation layer;
- cell count;
- hierarchy depth;
- request-lane count;
- packed state width;
- scheduler mode;
- transition fraction;
- step count;
- seed;
- deterministic vector profile;
- gamma-stimulus profile;
- run count;
- telemetry mode;
- trace mode;
- clock profile;
- reset profile;
- readiness profile;
- request-input profile;
- phase-derived target profile.

The retained balanced ternary state domain is:

`{-1, 0, 1}`

The opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

### 49.4 Timing Measurement Profile

- instrument identity;
- trigger source;
- time base;
- sample rate;
- reference clock;
- measured clock;
- reset-assertion interval;
- reset-release interval;
- `core_ready` activation interval;
- measured run window;
- trace-synchronization method;
- timestamp source;
- capture duration;
- measured tick count.

### 49.5 Electrical Measurement Profile

- voltage-rail identifier;
- voltage measurement point;
- current measurement point;
- instrument identity;
- bandwidth;
- sample rate;
- shunt or probe identity;
- calibration identity;
- idle window;
- active window;
- integration window;
- trigger relationship;
- clock relationship;
- measured tick window.

### 49.6 Physical Thermal Measurement Profile

- ambient-sensor identity;
- device-sensor identity;
- sensor position;
- imaging or contact method;
- sample rate;
- airflow condition;
- heatsink condition;
- package condition;
- starting temperature;
- run duration;
- cooling interval;
- repeated-run interval.

### 49.7 Captured Digital Outputs

The M15 semantic and implementation-mapping capture fields include:

- final state vector;
- per-tick state vector;
- scheduler sequence;
- pending-route sequence;
- transition counters;
- switch-load trace;
- model heat trace;
- phase trace;
- frequency trace;
- gamma trace;
- coherence trace;
- `C`, `P`, and `C_minus_P` trace;
- trace digest;
- cell-trace digest.

The M16 RTL and FPGA integration capture fields include:

- `core_ready` where the FPGA integration boundary is used;
- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler-state counters;
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

### 49.8 Measured Physical Outputs

- timing measurements;
- switching-activity measurements;
- voltage trace;
- current trace;
- electrical power trace;
- electrical energy result;
- ambient-temperature trace;
- device-temperature trace;
- benchmark summary.

Physical electrical power uses:

`P_elec`

The FRP model destabilizing-load quantity retains:

`P(t)`

Model thermal state and measured physical temperature retain separate field identities.

### 49.9 Reference Comparison

- reference command;
- reference configuration;
- reference output;
- M16 RTL execution output;
- FPGA integration output;
- target-specific physical implementation output;
- exact digital comparison table;
- analog measurement-tolerance profile;
- trace-comparison record;
- timing-comparison record;
- electrical-comparison record;
- thermal-comparison record;
- validation summary.

## 50. Measurement Synchronization Structure

A complete physical measurement campaign synchronizes:

`reference configuration`

+

`preload`

+

`vector stimulus`

+

`reset and readiness sequence`

+

`processor clock`

+

`digital trace capture`

+

`electrical sampling`

+

`thermal sampling`

The synchronization record includes:

- common start trigger;
- asynchronous reset-assertion index;
- synchronous reset-release index;
- `core_ready` activation index;
- first enabled-tick index;
- clock-to-sample relationship;
- trace tick index;
- electrical sample index;
- thermal sample index;
- run start timestamp;
- run end timestamp;
- measurement-window boundaries;
- final enabled-tick index;
- cooling-window boundaries.

The synchronized record maps:

| Domain | Synchronization identity |
|---|---|
| semantic reference | configuration, preload, seed, scheduler, tick index |
| M15 vectors | package digest, vector row, expected output row |
| M16 RTL | clock edge, tick index, retained-state output |
| M16 FPGA integration | reset release, `core_ready`, clock edge, tick index |
| electrical measurement | sample index and integration window |
| physical thermal measurement | sample index, sensor identity, and measurement window |

## 51. Repeatability and Statistical Record

Each physical validation profile records:

- run count;
- warm-up policy;
- cooling policy;
- idle interval;
- starting-condition policy;
- initial retained-state identity;
- preload identity;
- vector-package identity;
- clock-profile identity;
- exact digital match count;
- invariant-vector match count;
- zero-event total match count;
- timing mean;
- timing minimum;
- timing maximum;
- timing spread;
- electrical power mean;
- electrical power peak;
- electrical energy mean;
- electrical energy spread;
- temperature mean;
- temperature peak;
- temperature spread.

The exact digital record includes:

- state-sequence match;
- scheduler-sequence match;
- pending-route-sequence match;
- request-acceptance match;
- request-rejection match;
- accepted-change match;
- capacity-state match;
- event-counter match;
- invariant-vector match;
- terminal-marker match.

The report preserves raw runs together with derived summaries.

Raw measurements and derived summaries retain separate artifact identities.

## 52. Data and Artifact Structure

A physical validation package can include:

- `validation_manifest.json`;
- `device_profile.json`;
- `reference_identity.json`;
- `execution_profile.json`;
- `instrument_profile.json`;
- `timing_trace.csv`;
- `electrical_trace.csv`;
- `thermal_trace.csv`;
- `digital_trace.vec`;
- `cell_trace.vec`;
- `comparison_report.json`;
- `sha256_manifest.json`;
- human-readable validation report.

Each package preserves:

- file identity;
- schema identity;
- digest identity;
- source identity;
- source-commit identity;
- workload identity;
- vector-package identity;
- device identity;
- implementation identity;
- measurement identity;
- instrument identity;
- calibration identity;
- execution-window identity.

The package manifest records:

| Manifest field | Recorded identity |
|---|---|
| release | FRP version and milestone |
| semantic reference | executable filename and schema |
| M15 foundation | artifact schemas and vector-package digest |
| M16 RTL | source paths, source hashes, and qualification record |
| M16 FPGA preparation | integration-source paths, source hashes, and qualification record |
| target implementation | device, board, bitstream, firmware, and toolchain |
| workload | profile, seed, preload, scheduler, and vector identity |
| measurement | instruments, calibration, sampling, timing, and environment |
| integrity | file list and SHA-256 manifest |

## 53. Validation Deliverables

The physical validation plan defines the following deliverables:

- physical validation protocol;
- device and setup description;
- reference identity record;
- test-profile definitions;
- instrument and calibration record;
- telemetry-mapping document;
- benchmark repeatability report;
- timing-measurement report;
- switching-activity report;
- electrical power-measurement report;
- electrical energy-measurement report;
- physical thermal-measurement report;
- digital trace-correlation report;
- M15 reference-comparison report;
- M15-to-M16 compatibility record;
- M16 RTL execution-correlation report;
- FPGA integration-correlation report;
- target-specific FPGA-to-reference correlation report;
- ASIC-oriented correlation report;
- validation summary table;
- implementation-layer review notes;
- raw measurement package;
- derived metric package;
- integrity manifest.

The deliverable records retain:

- release identity;
- architecture-layer identity;
- workload identity;
- reference identity;
- implementation identity;
- device identity;
- measurement identity;
- digest identity;
- qualification state.

## 54. Implementation Risk Register

The physical validation risk register is:

| Risk | Validation Control |
|---|---|
| reference drift | preserve version, commit, artifact, schema, and digest identity |
| workload drift | preserve preload, seed, scheduler, and vector-package identity |
| fixed-point drift | apply exact integer comparison |
| lookup identity drift | apply SHA-256 and vector-package verification |
| core-domain notation drift | verify the canonical `{-1, 0, 1}` domain |
| reserved encoding emission | record `reserved_state_events` and the corresponding invariant flag |
| direct opposite-polarity writeback | record `actual_direct_events` and active-neutral route evidence |
| route-order drift | compare pending-route sequences |
| scheduler drift | replay scheduler vectors and compare scheduler counters |
| request-lane reordering | apply ascending lane-order checks |
| duplicate cell ownership | compare request acceptance and rejection records |
| transition-capacity drift | validate accepted-change and capacity relations |
| pending-route overwrite | validate retained pending-polarity and queue-overflow records |
| reset-sequence drift | record asynchronous assertion and synchronous release |
| readiness-sequence drift | record `core_ready` and execution-input gating |
| invariant-state drift | capture and compare all ten M16 invariant flags |
| thermal accumulation drift | apply fixed-point thermal exactness checks |
| topology-normalization drift | apply fixed-point topology exactness checks |
| gamma-stimulus drift | replay deterministic sideband stimulus |
| capture-window drift | preserve synchronized trigger and timestamp records |
| electrical measurement drift | preserve calibration and rail-identity records |
| thermal measurement drift | preserve sensor, position, airflow, and ambient records |
| debug overhead | preserve separate implementation and capture profiles |
| run-to-run condition drift | preserve starting-condition and cooling policies |
| physical trace mismatch | preserve shared workload and vector identities |
| target-boundary mixing | preserve target-independent and target-specific artifact identities |

## 55. Funding and Partner Relevance

The physical validation plan contains records for:

- engineering partner review;
- RTL and FPGA collaboration;
- ASIC architecture collaboration;
- laboratory collaboration;
- grant preparation;
- prototype validation planning;
- measurement protocol planning;
- implementation research planning;
- technical investor review;
- funding package preparation.

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
- structured output;
- qualified M15 benchmark matrix;
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
- current ASIC mapping study;
- current physical validation planning structure;
- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`.

The current partner-facing technical record is:

`FRP v1.8.0 contains the qualified M15 semantic and implementation-mapping foundation, the closed M16 RTL execution layer, the closed target-independent M16 FPGA preparation layer, deterministic comparison artifacts, architectural assertions, integrated invariant records, and the physical measurement protocol structure.`

The current engineering record is:

`The M15 digital comparison domain is retained as the semantic and implementation-mapping foundation for M16. The M16 RTL execution layer records scheduler execution, request-lane arbitration, active-neutral routing, pending-route completion, transition-capacity enforcement, retained-state writeback, event counters, and ten integrated invariant flags. The M16 FPGA preparation layer records reset synchronization, core readiness, execution-input gating, interface propagation, active-neutral execution, pending-route completion, and invariant propagation.`

## 56. Recommended Physical Validation Sequence

The physical validation sequence is:

1. preserve the qualified `frp_prototype_v1_7_0.py` executable semantic reference;
2. preserve the ten qualified M15 artifact schemas;
3. preserve the canonical balanced ternary domain `{-1, 0, 1}`;
4. preserve the qualified M15 26-stage semantic tick order;
5. preserve deterministic preload and lookup identities;
6. preserve the M15 vector-package digest;
7. retain the closed M16 RTL execution layer;
8. retain exact M15-to-M16 integer correlation;
9. retain the closed target-independent M16 FPGA preparation layer;
10. select the target-specific FPGA device and toolchain;
11. execute target-specific FPGA synthesis and timing correlation;
12. define the ASIC-oriented datapath and state-storage architecture;
13. preserve test, debug, and trace visibility;
14. select the physical validation workload;
15. freeze the device and setup identity;
16. freeze the instrument and calibration identity;
17. capture the synchronized digital trace;
18. capture timing data;
19. capture switching-activity data;
20. capture voltage and current data;
21. calculate electrical power and electrical energy;
22. capture ambient and device temperature data;
23. repeat the profile under the same starting-condition policy;
24. compare exact digital outputs against the M15 reference;
25. compare target-specific execution against the M16 RTL execution boundary;
26. correlate timing, electrical, and thermal records with the same tick and workload identities;
27. archive raw data, derived data, reports, source identities, and integrity manifests;
28. complete the engineering review record.

The sequence retains separate identities for:

- M15 semantic execution;
- M15 implementation mapping;
- M16 RTL execution;
- M16 target-independent FPGA preparation;
- target-specific FPGA implementation;
- ASIC-oriented implementation study;
- physical measurement.

## 57. Current Reproduction Commands

The commands in this section are executed from the `docs/` directory.

### 57.1 M15 Executable Semantic Reference

Compile the qualified executable semantic reference:

    python -m py_compile ../frp_prototype_v1_7_0.py

Run the qualified default structured execution:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Run the qualified full trace:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run the qualified 41-check self-test:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Export the qualified M15 benchmark matrix:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

Export the qualified fixed-point interface profile:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Export the qualified balanced ternary hardware encoding map:

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Export the qualified quantized reference shadow model:

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Export the qualified cycle-exact reference trace:

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Export the qualified RTL comparison vector package:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Export the qualified SystemVerilog testbench interface map:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Export the qualified synthesizable RTL reference-core map:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Export the qualified RTL assertion-correlation harness:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Export the qualified reference-equivalence report:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Export the qualified qualification-closure manifest:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

### 57.2 M16 RTL Architectural Simulation

Prepare the M16 RTL build directory:

    rm -rf /tmp/frp_m16_obj
    mkdir -p /tmp/frp_m16_obj

Build the integrated M16 RTL testbench:

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_tb \
      -I../rtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      ../rtl/m16/frp_m16_tb.sv

Execute the M16 RTL architectural testbench:

    /tmp/frp_m16_obj/Vfrp_m16_tb

The qualified RTL terminal markers include:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

### 57.3 M16 FPGA Integration Simulation

Elaborate the target-independent FPGA integration top:

    verilator \
      --sv \
      --lint-only \
      --top-module frp_m16_fpga_top \
      -I../rtl/m16 \
      -I../fpga/m16 \
      ../fpga/m16/frp_m16_fpga_top.sv

Prepare the FPGA integration-testbench build directory:

    rm -rf /tmp/frp_m16_fpga_obj
    mkdir -p /tmp/frp_m16_fpga_obj

Build the M16 FPGA integration testbench:

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

Execute the M16 FPGA integration testbench:

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

The qualified FPGA terminal markers include:

`FRP M16 FPGA integration testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

## 58. Current GitHub Actions Validation Context

The repository contains:

`23 GitHub Actions workflow files`

The root `README.md` contains:

`2 GitHub Actions workflow status badges`

The root `README.md` also contains:

- version badge;
- Python badge;
- license badge;
- linked M16 architecture image.

The current `CI.md` workflow badge count is:

`23`

The current workflow environment includes:

`ubuntu-latest`

The current M15 Python version is:

`3.12`

The current M16 simulation toolchain includes:

- Verilator;
- `g++`.

### 58.1 M15 Qualification Workflow

The qualified M15 workflow is:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

The M15 workflow stages include:

1. checkout repository;
2. set up Python;
3. compile the FRP v1.7.0 executable semantic reference;
4. generate M15 qualification outputs;
5. generate two deterministic vector packages;
6. compare deterministic vector packages;
7. validate M15 schemas;
8. validate kernel invariants;
9. validate the fixed-point contract;
10. validate semantic correlation;
11. validate exact deterministic replay;
12. validate deterministic vector-package integrity;
13. validate the M15 architecture-document contract;
14. upload M15 qualification artifacts.

The qualified M15 workflow result is:

`PASS`

### 58.2 M16 RTL Qualification Workflow

The current M16 RTL workflow is:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Job name:

`M16 RTL Architecture Qualification`

Trigger:

`workflow_dispatch`

The M16 RTL workflow validates:

- the ten-file SystemVerilog artifact boundary;
- the five-file RTL documentation boundary;
- Verilator SystemVerilog parsing;
- module elaboration;
- executable testbench generation;
- deterministic architectural simulation;
- architectural assertion execution;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- scheduler validation;
- request-lane arbitration;
- active-neutral routing;
- pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- all ten integrated invariant flags;
- source-hash generation;
- repository-integrity validation;
- terminal-marker validation;
- qualification-artifact generation.

The M16 RTL workflow result is:

`SUCCESS`

The M16 RTL closure status is:

`M16 RTL EXECUTION LAYER CLOSED`

### 58.3 M16 FPGA Preparation Workflow

The current M16 FPGA preparation workflow is:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Workflow name:

`FRP M16 FPGA Preparation`

Job name:

`M16 FPGA Integration Qualification`

Trigger:

`workflow_dispatch`

The M16 FPGA preparation workflow validates:

- the two-file FPGA SystemVerilog artifact boundary;
- the required M16 RTL dependencies;
- FPGA integration-top elaboration;
- executable FPGA integration-testbench generation;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- tick gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- scheduler-mode propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten integrated invariant flags;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- source-hash generation;
- terminal-marker validation;
- qualification-artifact generation.

The M16 FPGA preparation workflow result is:

`SUCCESS`

The M16 FPGA preparation closure status is:

`M16 FPGA PREPARATION LAYER CLOSED`

### 58.4 M16 Repository-Maintenance Workflows

The M16 canonical core-domain workflow is:

`../.github/workflows/frp-m16-canonical-core-domain.yml`

Workflow name:

`FRP M16 Canonical Core Domain`

Its defined modification boundary covers M16 RTL, FPGA, documentation, and workflow text files.

Its defined canonical core-domain record is:

`{-1, 0, 1}`

The M16 reserved-cell cleanup workflow is:

`../.github/workflows/frp-m16-reserved-cell-cleanup.yml`

Workflow name:

`FRP M16 Reserved Cell Cleanup`

Its defined modification boundary is:

`rtl/m16/*.sv`

These two workflows respond to:

`workflow_dispatch`

## 59. Current Release Validation Evidence

The current release layer is:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

The inherited qualified foundation is:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current validation environment is:

`GitHub Actions CI execution`

### 59.1 M15 Qualification Evidence

| Qualification record | Result |
|---|---:|
| self-test checks | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

M15 qualification state:

`PASS`

### 59.2 M16 RTL Qualification Evidence

Initial M16 RTL closure record:

| Field | Value |
|---|---|
| workflow run | `#82` |
| qualified source commit | `a68a2af` |
| branch | `main` |
| result | `SUCCESS` |
| qualification artifact count | `1` |

Synchronized M16 RTL qualification record:

| Field | Value |
|---|---|
| workflow run | `#84` |
| qualified source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| qualification artifact count | `1` |

M16 RTL qualification state:

`M16 RTL EXECUTION LAYER CLOSED`

### 59.3 M16 FPGA Preparation Evidence

Initial M16 FPGA preparation closure record:

| Field | Value |
|---|---|
| workflow run | `#1` |
| qualified repository commit | `326b69e` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `1m 7s` |
| qualification artifact count | `1` |

Synchronized M16 FPGA preparation qualification record:

| Field | Value |
|---|---|
| workflow run | `#2` |
| qualified repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `36s` |
| qualification artifact count | `1` |

M16 FPGA preparation qualification state:

`M16 FPGA PREPARATION LAYER CLOSED`

The current release validation result is:

`PASS`

## 60. Current File Alignment

This physical validation plan is aligned with the current release-facing files:

- `../README.md`;
- `../CI.md`;
- `../CHANGELOG.md`;
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

This plan is aligned with the qualified M15 foundation files:

- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`;
- `../RELEASE_CHECKLIST_v1_7_0.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

This plan is aligned with the FRP foundation documents:

- `./mathematical_foundation.md`;
- `./physical_foundation.md`.

This plan is aligned with the architecture and implementation documents:

- `./README.md`;
- `./core_principles.md`;
- `./resonance_computation.md`;
- `./architecture.md`;
- `./implementation_layers.md`;
- `./hardware_pathway.md`;
- `./fpga_mapping_study.md`;
- `./asic_mapping_study.md`;
- `./output_schema.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`;
- `./physical_validation_plan.md`.

This plan is aligned with the M16 qualification documents:

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

This plan is aligned with the M16 RTL execution boundary:

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

This plan is aligned with the M16 FPGA preparation boundary:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

This plan is aligned with the current M16 workflows:

- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`;
- `../.github/workflows/frp-m16-canonical-core-domain.yml`;
- `../.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

This plan is aligned with the repository validation, model, simulation, and example documents:

- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../models/README.md`;
- `../models/kuramoto_frp_background_model.md`;
- `../simulations/README.md`;
- `../simulations/initial_kuramoto_result.md`;
- `../examples/README.md`;
- `../examples/resonance_convergence_example.md`.

Historical transition evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 61. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Fractal Resonant Coherence Processor`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Executable semantic reference:

`../frp_prototype_v1_7_0.py`

Structured-output schema:

`frp.structured_output.v1.7.0`

Benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Qualified semantic and implementation-mapping foundation:

`M15 deterministic fixed-point, trace, vector, interface, assertion, equivalence, and qualification package`

Current RTL execution layer:

`M16 RTL EXECUTION LAYER CLOSED`

Current FPGA preparation layer:

`M16 FPGA PREPARATION LAYER CLOSED`

Current hardware-facing chain:

`qualified M15 processor semantics → fixed-point interface → balanced ternary hardware encoding → stateful quantized hardware shadow → cycle-exact integer golden trace → deterministic RTL comparison vectors → SystemVerilog interface mapping → M16 scheduler → M16 request-lane arbitration → M16 pending-route retention → M16 active-neutral routing → M16 transition-capacity enforcement → M16 retained-state writeback → M16 assertion execution → M16 RTL execution closure → target-independent M16 FPGA preparation closure`

Current physical validation chain:

`qualified M15 reference → closed M16 RTL execution layer → closed target-independent M16 FPGA preparation layer → target-specific FPGA implementation → ASIC-oriented implementation study → device and setup identity → synchronized digital, timing, electrical, and thermal capture → repeatability → reference correlation → review record`

Qualified M15 self-test result:

`41 / 41 PASS`

Qualified M15 artifact-layer count:

`10`

Qualified deterministic vector package:

`10 files`

Qualified deterministic vector regeneration:

`10 / 10 files byte-identical`

Qualified M15 exact tick-order count:

`26`

Qualified M15 assertion-domain count:

`13`

Qualified semantic correlation result:

`5 / 5 required semantic correlation matches = 1.0`

Qualified exact deterministic replay result:

`6 / 6 deterministic replay matches = 1.0`

Qualified M15 closure result:

`PASS`

M16 RTL SystemVerilog artifact count:

`10`

M16 RTL documentation artifact count:

`5`

M16 integrated invariant count:

`10`

M16 RTL terminal event totals:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

M16 FPGA preparation terminal state:

`core_ready = 1`

`invariant_flags = 1111111111`

M16 FPGA preparation terminal event totals:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current repository workflow-file count:

`23`

Current physical validation objective:

`measure FRP implementations under preserved reference, workload, vector, setup, device, instrument, timing, and trace identities and correlate exact digital execution with switching activity, electrical power, electrical energy, physical temperature, and repeatability evidence`

Current qualification state:

`FRP v1.8.0 / M16 — PASS`







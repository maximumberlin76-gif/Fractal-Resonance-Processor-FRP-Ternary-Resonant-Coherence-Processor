# Resonance-Based Computation — Fractal Resonance Processor (FRP)

**Ternary Fractal Resonant Coherence Processor**

This document defines the current computational mechanism of the Fractal Resonance Processor (FRP).

FRP combines:

- Kuramoto-Sakaguchi resonant phase dynamics;
- hierarchical fractal coupling;
- multiscale phase-coherence evolution;
- stateful delay dynamics;
- endogenous thermal feedback;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation;
- phase-derived balanced ternary targets;
- distributed commit;
- active-neutral routing;
- retained coherent ternary state;
- M16 RTL retained-state execution;
- target-independent FPGA preparation.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified Python executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified M3 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Qualified M15 semantic and implementation-mapping foundation:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

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

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Recorded M15 qualification results:

| Qualification record | Result |
|---|---:|
| self-test | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 matches = 1.0` |
| deterministic replay matches | `6 / 6 matches = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Current M16 qualification records:

| Layer | Workflow run | Commit | Branch | Result | Status |
|---|---:|---|---|---|---|
| RTL execution | `#84` | `ede53cf` | `main` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| FPGA preparation | `#2` | `ede53cf` | `main` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |

Current release qualification state:

`FRP v1.8.0 / M16 — PASS`

## 1. Computational Identity

The M15-qualified FRP computational chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric Sakaguchi phase lag gamma`

↓

`hierarchical fractal coupling`

↓

`phase velocity and phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`stateful delay dynamics`

↓

`local thermal-phase interaction`

↓

`local correlated gamma drift`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed ternary commit`

↓

`mandatory tick-separated routing through active neutral state 0`

↓

`retained coherent ternary state`

The M16 RTL execution chain is:

`scheduler execution`

↓

`request-lane arbitration`

↓

`pending-route processing`

↓

`active-neutral transition generation`

↓

`transition-capacity enforcement`

↓

`retained-state writeback`

↓

`integrated invariant evaluation`

The resonant dynamic domain drives the evolving computation.

The balanced ternary domain provides the state, target, transition, and retained-result layer.

M15 supplies the qualified semantic and implementation-mapping foundation.

M16 realizes the qualified retained-state execution semantics in SystemVerilog RTL and the target-independent FPGA integration layer.

## 2. Two Connected Computational Domains

### 2.1 Resonant Dynamic Domain

The resonant dynamic domain contains:

- phase state;
- base frequency;
- target frequency;
- current frequency;
- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- scheduler-dependent phase contribution;
- delayed frequency response;
- distributed local thermal state;
- thermal coupling-factor evolution;
- local correlated gamma drift;
- phase evolution;
- global phase order;
- multiscale phase coherence;
- nonlinear coherence compression;
- dynamic stability evaluation.

The qualified executable semantic reference for this domain is:

`../frp_prototype_v1_7_0.py`

### 2.2 Balanced Ternary State and Retained-Result Domain

The balanced ternary domain contains:

- states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- explicit transition requests;
- distributed commit;
- transition-fraction limits;
- request lanes;
- pending neutral routes;
- mandatory tick separation;
- scheduler-controlled execution;
- retained ternary state.

The M16 RTL core realizes this domain through:

- scheduler-state propagation;
- deterministic request-lane order;
- pending-route target retention;
- active-neutral routing;
- transition-capacity guarding;
- retained-state writeback;
- invariant counters and flags.

The resonant dynamic domain and balanced ternary retained-state domain remain coupled across processor ticks.

## 3. Balanced Ternary State Domain

Current state domain:

`{-1, 0, 1}`

State roles:

| State | Computational role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

The active neutral state participates directly in:

- polarity transition;
- conflict neutralization;
- transition buffering;
- switching-load control;
- stability support;
- retained-route completion.

Canonical M16 two-bit encoding:

| State | Encoding |
|---:|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

Canonical integer encoding:

| State | Integer code |
|---:|---:|
| `-1` | `3` |
| `0` | `0` |
| `1` | `1` |
| reserved | `2` |

M15 state-domain marker:

`balanced_ternary_state_domain = True`

M15 reserved-state marker:

`reserved_state_events = 0`

M16 RTL reserved-state result:

`reserved_state_events = 0`

M16 FPGA preparation reserved-state result:

`reserved_state_events = 0`

## 4. Mandatory Active-Neutral Routing

Opposite-polarity retained-state execution follows:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: retained polarity → 0`

↓

`pending target polarity retained`

↓

`tick N+1 or later: 0 → target polarity`

Direct opposite-polarity retained-state transitions are forbidden.

A pending route records:

- cell index;
- target polarity;
- route-valid state;
- earliest ready tick.

A pending route completes when:

- the ready tick has been reached;
- transition capacity remains;
- the current cell state is neutral.

M15 recorded route invariants:

| Invariant | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `queue_overflow_events` | `0` |
| `reserved_state_events` | `0` |

M16 RTL recorded route invariants:

| Invariant | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `queue_overflow_events` | `0` |
| `reserved_state_events` | `0` |

M16 FPGA preparation recorded route invariants:

| Invariant | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `queue_overflow_events` | `0` |
| `reserved_state_events` | `0` |

## 5. Current Tick Execution Order

The M15-qualified Python semantic reference executes each processor tick in this order:

`scheduler-state selection`

↓

`switch-activity reset`

↓

`maximum transition-capacity calculation`

↓

`pending neutral-route processing`

↓

`explicit transition-request processing`

↓

`phase-derived ternary target processing`

↓

`switch-load update`

↓

`delay-dynamics update`

↓

`local thermal-field update`

↓

`local gamma-drift update`

↓

`thermal coupling-factor update`

↓

`Kuramoto-Sakaguchi phase-field update`

↓

`multiscale phase-coherence evaluation`

↓

`cluster-metric evaluation`

↓

`nonlinear coherence compression and global stability update`

↓

`structured telemetry capture`

The M16 RTL retained-state execution chain is:

`frp_m16_scheduler`

↓

`frp_m16_request_lanes`

↓

`frp_m16_pending_routes`

↓

`frp_m16_active_neutral`

↓

`frp_m16_capacity_guard`

↓

`frp_m16_state_update`

↓

`frp_m16_core integrated counters and invariant outputs`

The M16 RTL qualification executes this chain through:

- Verilator parsing;
- module elaboration;
- executable testbench generation;
- architectural simulation;
- assertion execution;
- scheduler validation;
- request-lane arbitration;
- active-neutral routing;
- pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten invariant flags.

## 6. Temporal Relation Between Phase Evolution and Ternary Targets

The M15-qualified semantic reference extracts automatic ternary targets from the phase field present at the beginning of the target-processing stage.

The same semantic tick then updates:

- delay state;
- thermal state;
- gamma state;
- coupling field;
- phase state;
- coherence state;
- dynamic stability state.

Across successive semantic ticks, the relation is:

`phase field produced by previous evolution`

↓

`current tick ternary target extraction`

↓

`distributed ternary transition`

↓

`delay and thermal update`

↓

`Kuramoto-Sakaguchi phase evolution`

↓

`new phase field`

↓

`next tick ternary target extraction`

The M16 opposite-polarity execution relation is:

`tick N: opposite-polarity target accepted`

↓

`retained state written to 0`

↓

`target polarity stored as a pending route`

↓

`tick N+1 or later: pending route becomes eligible`

↓

`0 written to retained target polarity`

The M16 pending-route completion remains subject to:

- scheduler state;
- route readiness;
- transition capacity;
- retained neutral state;
- request-lane ordering.

## 7. Kuramoto-Sakaguchi Resonant Phase Interaction

The M15-qualified Python semantic reference uses:

`sin(phase_j - phase_i - gamma_effective_i)`

The pair interaction combines:

- hierarchical coupling weight;
- local thermal factor of cell `i`;
- local thermal factor of cell `j`;
- asymmetric local phase lag;
- nominal coupling strength.

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

The phase interaction uses a locally weighted asymmetric resonant field.

The M16 RTL execution layer receives balanced ternary target and explicit request interfaces defined by the M15-qualified execution contract.

The current M16 RTL core interface includes:

- packed ternary target state;
- request-valid lanes;
- request cell indices;
- request target values;
- scheduler mode;
- tick control;
- retained state;
- pending-route state;
- transition and invariant counters.

## 8. Hierarchical Fractal Coupling

The M15-qualified semantic reference uses a dyadic hierarchical ultrametric topology.

Current default semantic cell count:

`16`

Current default hierarchy depth:

`4`

The cell-count domain uses powers of two beginning at:

`2`

Hierarchy depth:

`cells.bit_length() - 1`

Hierarchical distance between two distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

The hierarchical field aggregates sibling-shell phase contributions across every hierarchy level.

M15 fixed-point topology exactness marker:

`fixed_point_topology_sum_exact = True`

M16 retained-state execution is parameterized by:

`CELLS`

and:

`REQUEST_LANES`

M16 request-lane relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified mappings:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Current M16 default retained-state cell count:

`FRP_M16_DEFAULT_CELLS = 16`

## 9. Dense and Hierarchical Coupling Paths

The M15-qualified executable semantic reference contains two phase-coupling representations:

- dense reference path;
- hierarchical accelerated path.

The dense path evaluates pair interactions directly across cells.

The hierarchical path aggregates weighted sibling-shell phase projections across the dyadic hierarchy.

Both paths use the same computational relation:

`hierarchical weight`

×

`thermal pair factor`

×

`Kuramoto-Sakaguchi phase interaction`

×

`nominal coupling strength`

Recorded correlation and exactness markers include:

`fixed_point_topology_sum_exact = True`

`5 / 5 required semantic correlation matches = 1.0`

The dense and hierarchical paths are retained in the M15 semantic and implementation-mapping foundation of M16.

## 10. Scheduler Contribution to Resonant Computation

Qualified scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

The M15-qualified semantic reference applies scheduler-state contributions to phase velocity.

Semantic scheduler phase push:

| Scheduler state | Phase push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all other scheduler states | `0.003` |

The M16 scheduler-mode encodings are:

| Scheduler mode | Encoding |
|---|---|
| `free` | `2'b00` |
| `7/1` | `2'b01` |
| `1/7` | `2'b10` |
| reserved | `2'b11` |

The M16 scheduler-state encodings are:

| Scheduler state | Encoding |
|---|---|
| `free` | `3'b000` |
| `balance` | `3'b001` |
| `commit` | `3'b010` |
| `excite` | `3'b011` |
| `neutralize` | `3'b100` |
| invalid | `3'b111` |

M16 scheduler period:

`FRP_M16_PERIOD_TICKS = 8`

Validated 16-tick scheduler profiles:

| Scheduler mode | Recorded counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Recorded scheduler invariant:

`sum(scheduler_counts) = ticks_recorded`

Validated M15 default 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

In the M15 semantic reference, scheduler state contributes to phase velocity and transition timing.

In the M16 RTL execution layer, scheduler state controls execution eligibility and propagates through the integrated core and FPGA preparation top.

## 11. Phase Velocity and Phase Evolution

The M15-qualified semantic-reference phase velocity is:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The resulting phase state contains contributions from:

- delayed oscillator frequency;
- scheduler state;
- hierarchical resonant coupling;
- thermal coupling degradation;
- local gamma drift.

Phase evolution produces the dynamic computational field from which subsequent balanced ternary targets are derived.

The qualified executable implementation of this relation is:

`../frp_prototype_v1_7_0.py`

## 12. Resonance Selection

FRP uses resonance as selective support of dynamically compatible phase structures.

Compatible phase relations contribute to:

- phase-order accumulation;
- multiscale coherence formation;
- coherent target development;
- retained-state formation.

Conflicting phase relations contribute to:

- phase dispersion;
- reduced effective coupling;
- neutralization;
- damping;
- lower effective coherence.

The qualified resonance-selection path is:

`phase relation`

↓

`asymmetric gamma offset`

↓

`hierarchical weighted coupling`

↓

`thermal pair weighting`

↓

`phase velocity`

↓

`phase evolution`

↓

`phase order and multiscale coherence`

The resulting phase field supplies phase-derived balanced ternary targets to the retained-state execution path.

## 13. Kuramoto Order Parameter R

The global phase-order parameter is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The qualified executable semantic reference evaluates this relation through:

`phase_order(phases)`

The same phase-order relation is applied to hierarchical groups.

`R(t)` is the global phase-order measure of the current cell field.

Phase synchronization and phase coherence are not interchangeable.

`R(t)` is not identical to general endogenous structural coherence `C(t)`.

The structured computational result records `R` together with:

- multiscale phase coherence;
- balanced ternary state;
- route history;
- local thermal state;
- operational coherence;
- destabilizing load;
- dynamic stability margin.

## 14. Multiscale Phase Coherence

The qualified hierarchy evaluates phase coherence across:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Current multiscale outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

These quantities are recorded in the structured semantic output and M15 benchmark-matrix layers.

The M15 implementation-mapping layer carries the qualified coherence quantities into deterministic fixed-point representation and correlation records.

## 15. Stateful Delay Dynamics

Each semantic-reference cell maintains:

- base frequency;
- frequency target;
- current frequency.

Current frequency-target relation:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

Current delayed response:

`frequency_next = frequency_current + 0.30 × (frequency_target - frequency_current)`

Current default delay coefficient:

`delay_alpha = 0.30`

The remaining frequency lag participates in:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

The delay layer retains temporal state inside the resonant computational path.

## 16. Local Thermal-Phase Interaction

The M15-qualified semantic reference maintains a distributed local thermal field.

Each cell records:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

Current generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current thermal-dissipation relation:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

Current default thermal parameters:

| Parameter | Value |
|---|---:|
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| thermal diffusion gain | `0.035` |
| thermal topology exponent | `1.20` |

The thermal state participates in endogenous processor feedback.

The local thermal field contributes to:

- generated-power accounting;
- diffusion state;
- overload state;
- local coupling factors;
- local gamma drift;
- operational stability quantities.

## 17. Thermal Coupling Degradation

Current local thermal overload:

`max(0, local_heat - thermal_soft_limit)`

Current local thermal node factor:

`exp(-0.5 × thermal_coupling_gain × overload)`

Current thermal coupling gain:

`2.50`

The dense pair interaction uses:

`thermal_node_factor_i × thermal_node_factor_j`

The hierarchical semantic path uses the same local thermal weighting relation.

The endogenous feedback chain is:

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

Recorded M15 fixed-point thermal exactness marker:

`fixed_point_thermal_sum_exact = True`

## 18. Local Correlated Gamma Drift

The qualified semantic reference tracks:

- nominal gamma;
- deterministic gamma-noise targets;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

Gamma-noise targets refresh every:

`8 ticks`

Current target range:

`[-1.0, 1.0]`

Current correlated update:

`gamma_noise_state += 0.15 × (gamma_noise_target - gamma_noise_state)`

Current effective local gamma:

`gamma_effective = gamma_nominal + 0.08 × thermal_overload × gamma_noise_state`

The resulting local gamma enters the Kuramoto-Sakaguchi interaction for the corresponding cell.

The deterministic semantic reference records the local gamma state in its structured telemetry.

## 19. Nonlinear Coherence Compression

The qualified semantic reference applies nonlinear compression to raw phase coherence.

Current thermal-overload mean:

`mean(local thermal overload)`

Current margin pressure:

`max(0, stability_soft_margin - previous_C_minus_P)`

Current stability soft margin:

`0.25`

Current compression relation:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Current effective coherence:

`effective_coherence = raw_phase_coherence × coherence_compression`

This relation feeds thermal-overload state and stability-margin pressure into the effective coherence quantity.

The structured output records:

- raw phase coherence;
- thermal-overload mean;
- margin pressure;
- coherence-compression factor;
- effective coherence.

## 20. Dynamic Stability

The qualified semantic reference tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current operational coherence:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current destabilizing load:

`P = heat + switch_load`

Current stability margin:

`C_minus_P = C - P`

Current validated default condition:

`C_minus_P_min > 0.0`

FRP operational `C` and `P` are processor-specific quantities.

The dynamic-stability calculation contains:

- effective phase coherence;
- multiscale coherence;
- neutral-state fraction;
- frequency lag;
- heat;
- switching load.

The structured output records:

- `C`;
- `P`;
- `C_minus_P`;
- `C_minus_P_min`;
- `C_minus_P_final`;
- stability-state markers.

## 21. Phase-Derived Ternary Targets

The M15-qualified executable semantic reference maps the evolving phase field into balanced ternary targets.

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The mapping relation is:

`resonant phase field`

↓

`balanced ternary target domain {-1, 0, 1}`

The resulting target enters:

- transition-capacity control;
- distributed commit;
- pending-route processing;
- active-neutral routing;
- retained-state formation.

The M16 RTL execution layer receives balanced ternary targets through:

- packed `target_q` inputs;
- request-valid lanes;
- request cell indices;
- request target values.

The M16 target domain uses the canonical two-bit encoding:

| Target | Encoding |
|---:|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

## 22. Distributed Commit

Qualified transition fraction:

`0.25`

Maximum-change relation:

`max_changes = max(1, round(cells × transition_fraction))`

M16 constant relation:

`FRP_M16_TRANSITION_FRACTION_NUM / FRP_M16_TRANSITION_FRACTION_DEN = 1 / 4`

Qualified cell and request-lane mappings:

| Cells | Request lanes | Maximum retained-state changes per tick |
|---:|---:|---:|
| `8` | `2` | `2` |
| `16` | `4` | `4` |
| `32` | `8` | `8` |

Current default semantic configuration:

`16 cells`

Current default request lanes:

`4`

M15 validated switching relation:

`switch_load_peak <= transition_fraction`

M15 default validated boundary:

`switch_load_peak <= 0.25`

The M16 transition-capacity guard receives:

- candidate retained-state changes;
- current accepted-change count;
- per-tick transition capacity;
- request-lane order;
- pending-route completion candidates.

The M16 capacity qualification flag is:

`FRP_INV_TRANSITION_CAPACITY_VALID = PASS`

Distributed commit bounds retained-state changes per tick.

Switching activity participates in the M15 thermal and dynamic-stability quantities.

## 23. Retained Coherent Ternary State

The retained ternary state is produced through the complete qualified semantic execution path.

The semantic evidence chain contains:

- phase evolution;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- delay state;
- thermal state;
- gamma drift;
- nonlinear coherence compression;
- dynamic stability;
- phase-derived target;
- transition history;
- active-neutral route history;
- final balanced ternary vector.

The M16 retained-state execution chain contains:

- scheduler state;
- ordered request lanes;
- packed balanced ternary targets;
- retained pending-route targets;
- active-neutral first-leg transitions;
- pending-route completion transitions;
- transition-capacity acceptance;
- retained-state writeback;
- integrated counters;
- invariant flags.

Current retained-state domain:

`{-1, 0, 1}`

Current active-neutral state:

`0`

Canonical opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

M16 retained-state outputs include:

- `state_out`;
- `pending_route_out`.

Recorded M16 RTL terminal route values:

| Terminal value | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Recorded M16 FPGA preparation terminal route values:

| Terminal value | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

## 24. Structured Telemetry

The qualified structured-output schema is:

`frp.structured_output.v1.7.0`

The qualified semantic execution records compact deterministic digests by default.

Full-trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Current default full-trace sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

Semantic telemetry includes:

- scheduler state;
- ternary cell state;
- phase state;
- frequency target;
- current frequency;
- frequency lag;
- switching load;
- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload;
- effective gamma;
- gamma drift;
- thermal coupling factor;
- coupling field;
- raw phase coherence;
- coherence compression;
- effective coherence;
- multiscale coherence;
- `C(t)`;
- `P(t)`;
- `C(t) - P(t)`;
- route counters;
- pending-route count.

M16 RTL execution outputs include:

- recorded tick count;
- scheduler-state counts;
- requested lane events;
- accepted lane events;
- rejected lane events;
- accepted retained-state changes;
- remaining transition capacity;
- switch-load numerator;
- requested direct events;
- prevented direct events;
- neutral-routed events;
- pending-route completion events;
- actual direct events;
- reserved-state events;
- queue-overflow events;
- ten invariant flags.

M16 executable evidence is recorded in:

- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

## 25. Current Default Configuration

M15-qualified semantic-reference defaults:

| Parameter | Default |
|---|---:|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |
| gamma | `0.30 × pi` |
| fractal alpha | `0.70` |
| thermal beta | `1.20` |
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| nominal coupling | `0.28` |
| delay alpha | `0.30` |
| thermal diffusion gain | `0.035` |
| equivalence tolerance | `1e-12` |

Derived semantic-reference defaults:

| Derived parameter | Value |
|---|---:|
| hierarchy depth | `4` |
| request lanes | `4` |
| packed ternary state width | `32 bits` |

M16 shared RTL defaults:

| Constant | Value |
|---|---:|
| `FRP_M16_STATE_BITS` | `2` |
| `FRP_M16_SCHED_MODE_BITS` | `2` |
| `FRP_M16_SCHED_BITS` | `3` |
| `FRP_M16_PERIOD_BITS` | `3` |
| `FRP_M16_PERIOD_TICKS` | `8` |
| `FRP_M16_TRANSITION_CLASS_BITS` | `4` |
| `FRP_M16_REJECT_REASON_BITS` | `4` |
| `FRP_M16_COUNTER_BITS` | `32` |
| `FRP_M16_DEFAULT_CELLS` | `16` |
| `FRP_M16_TRANSITION_FRACTION_NUM` | `1` |
| `FRP_M16_TRANSITION_FRACTION_DEN` | `4` |

Derived M16 default request-lane count:

`4`

Derived M16 default packed retained-state width:

`32 bits`

## 26. Current Scaling Domain

Validated M15 scaling profiles:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

For every validated M15 scaling profile, the recorded qualification values include:

- balanced ternary state-domain validity;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- valid scheduler counts;
- exact fixed-point topology closure;
- exact fixed-point thermal closure.

M16 request-lane relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

M16 qualified mappings:

| Cells | Request lanes | Packed retained-state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

M16 RTL qualification profile:

| Parameter | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |

M16 FPGA preparation qualification profile:

| Parameter | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |

## 27. M15 Hardware-Facing Mapping

M15 numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Balanced ternary hardware encoding:

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

Recorded exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

M15 maps the resonant computational state and retained balanced ternary state into deterministic hardware-facing domains.

M16 uses the same qualified retained-state domain and two-bit balanced ternary encoding.

## 28. M15 Artifact Layers and M16 RTL Realization

FRP v1.7.0 defines ten qualified M15 artifact layers:

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

The M15 implementation-mapping chain is:

`floating semantic reference`

↓

`fixed-point interface`

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

`qualification closure`

The M16 RTL execution boundary contains ten SystemVerilog files:

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

The M16 RTL documentation boundary contains:

- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`.

The M16 FPGA preparation boundary contains:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

M15 remains the qualified semantic and implementation-mapping foundation of the M16 RTL and FPGA preparation layers.

## 29. Validation Invariants

The qualified M15 self-test package contains:

`41 checks`

Recorded result:

`41 / 41 PASS`

M15 validated invariants include:

`balanced_ternary_state_domain = True`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`scheduler_counts_valid = True`

`switch_load_peak <= transition_fraction`

`C_minus_P_min > 0.0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

M15 qualification closure result:

`PASS`

M16 RTL qualification executes ten invariant flags:

| Invariant flag | Result |
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

Recorded M16 RTL invariant vector:

`1111111111`

Recorded M16 FPGA preparation invariant vector:

`1111111111`

Recorded M16 RTL and FPGA preparation event totals:

| Event | RTL | FPGA preparation |
|---|---:|---:|
| `actual_direct_events` | `0` | `0` |
| `reserved_state_events` | `0` | `0` |
| `queue_overflow_events` | `0` | `0` |

## 30. Release Validation Evidence

Current published release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Qualified M15 foundation layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Recorded M15 release commit:

`5fd9a4f`

Recorded M15 workflow results:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Current M16 RTL qualification record:

| Field | Recorded value |
|---|---|
| workflow | `FRP M16 RTL Artifact Boundary` |
| workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| workflow run | `#84` |
| source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `52s` |
| artifact count | `1` |
| qualification result | `PASS` |
| status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification record:

| Field | Recorded value |
|---|---|
| workflow | `FRP M16 FPGA Preparation` |
| workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| workflow run | `#2` |
| repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `36s` |
| artifact count | `1` |
| qualification result | `PASS` |
| status | `M16 FPGA PREPARATION LAYER CLOSED` |

The root `README.md` exposes:

`2 M16 qualification workflow badges`

The root `CI.md` exposes:

`23 workflow badges`

The repository contains:

`23 GitHub Actions workflow files`

## 31. Historical Archived Transition Benchmark

The repository preserves a release-specific historical transition benchmark in:

`../TEST_REPORT_v0_9_3.md`

Historical executable:

`../frp_prototype_v0_9_3_mobile.py`

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded historical result:

| Architecture | Match | `C-P_min` | `heat_peak` | `switch_load_peak` | `actual_direct_events` | `prevented_direct_events` | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

Measurement contour:

`FRP v0.9.3 historical transition benchmark`

## 32. Archived Ternary-to-Binary Thermal Result

The historical benchmark records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Recorded numerical representation:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent recorded relative reduction:

`93.63% lower heat_peak`

The same archived result records:

| Metric | `binary_style_forced_switch` | `distributed_neutral_ternary` |
|---|---:|---:|
| `heat_peak` | `0.051000` | `0.003250` |
| `switch_load_peak` | `1.000000` | `0.250000` |
| `actual_direct_events` | `2052` | `0` |
| neutralized events | `0` | `2052` |
| `C-P_min` | `-0.551000` | `0.174750` |

These values belong to the historical FRP v0.9.3 transition benchmark model and workload.

## 33. Historical FRP Resonant Row and Ternary Transition Row

The historical benchmark records:

`distributed_neutral_ternary heat_peak = 0.003250`

`frp_distributed_resonant heat_peak = 0.107000`

The `distributed_neutral_ternary` row records the neutral-mediated ternary transition mechanism.

The `frp_distributed_resonant` row includes the following computational layers from that release:

- Kuramoto-Sakaguchi resonant phase dynamics;
- nonlinear saturation;
- compression;
- delay dynamics;
- resonant phase evolution.

Recorded comparison:

| Metric | `distributed_neutral_ternary` | `frp_distributed_resonant` |
|---|---:|---:|
| match | `1.000` | `1.000` |
| `C-P_min` | `0.174750` | `0.144750` |
| `heat_peak` | `0.003250` | `0.107000` |
| `switch_load_peak` | `0.250000` | `0.250000` |
| `actual_direct_events` | `0` | `0` |
| `prevented_direct_events` | `0` | `3820` |
| neutralized events | `2052` | `2392` |

The two rows retain separate architecture identifiers and recorded event totals.

## 34. Relationship Between Historical and Current Computation

The historical FRP v0.9.3 transition contour records:

- active-neutral routing;
- actual direct-event totals;
- prevented direct-event totals;
- neutralized-event totals;
- switching-load peak;
- historical heat proxy;
- `C-P_min`.

Historical evidence files:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

The FRP v1.7.0 M15 semantic and implementation-mapping contour records:

- hierarchical fractal coupling;
- local thermal-field dynamics;
- local correlated gamma drift;
- multiscale phase coherence;
- nonlinear coherence compression;
- stateful quantized hardware-shadow execution;
- cycle-exact traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference equivalence;
- qualification closure.

M15 recorded qualification results:

| Qualification record | Result |
|---|---:|
| self-test | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 matches = 1.0` |
| deterministic replay matches | `6 / 6 matches = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The FRP v1.8.0 M16 RTL execution contour records:

- scheduler execution;
- deterministic request-lane arbitration;
- pending-route target retention;
- active-neutral first-leg execution;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- integrated counters;
- ten invariant flags;
- executable architectural simulation;
- assertion execution.

M16 RTL qualification record:

| Field | Recorded value |
|---|---|
| workflow run | `#84` |
| source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |
| status | `M16 RTL EXECUTION LAYER CLOSED` |

The FRP v1.8.0 target-independent FPGA preparation contour records:

- FPGA integration-top elaboration;
- executable FPGA testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- execution-input gating;
- scheduler propagation;
- request-interface propagation;
- active-neutral routing;
- retained pending-route completion;
- ten invariant flags.

M16 FPGA preparation qualification record:

| Field | Recorded value |
|---|---|
| workflow run | `#2` |
| repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| `core_ready` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |
| status | `M16 FPGA PREPARATION LAYER CLOSED` |

Each contour retains its release version, execution layer, measurement domain, artifact set, and qualification record.

## 35. Comparative Architecture Context

The Comparative Architecture Benchmark Suite is located at:

`../benchmarks/architecture_comparison/`

Comparison schema:

`frp.benchmark.architecture_comparison.v1`

Architecture set:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The comparison chain is:

`one deterministic semantic workload`

↓

`architecture-specific execution`

↓

`raw architecture event counters`

↓

`one common normalized cost model`

↓

`one common thermal proxy model`

↓

`machine-readable comparison matrix`

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical comparison-package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Integrity status:

`PASS`

Qualification status:

`PASS`

Canonical FRP workload results:

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

Hardware-sensitivity schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical hardware-sensitivity result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Hardware-sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Validated scenarios:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

Recorded ranking stability:

`ranking_stable = true`

Recorded ranking sensitivity:

`ranking_sensitive = false`

Ranking basis:

`ascending_total_normalized_energy`

Recorded ranking for all three scenarios:

`binary_clock_gated_reference`

→ `direct_ternary_reference`

→ `binary_synchronous_reference`

→ `frp_v1_7_0_quantized_shadow`

Canonical hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Recorded FRP activity-cost event totals:

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Measurement contour:

`FRP v1.7.0 M15 quantized hardware shadow under the canonical comparative workload and hardware-sensitivity profile`

## 36. Exact Computation Statement

The qualified FRP semantic computation statement is:

`FRP computes through Kuramoto-Sakaguchi resonant phase dynamics with asymmetric local phase lag, hierarchical fractal coupling, stateful delay dynamics, local thermal-phase interaction, multiscale phase coherence, nonlinear coherence compression, dynamic stability evaluation, phase-derived balanced ternary targets, distributed commit, mandatory tick-separated active-neutral routing, and retained coherent ternary state.`

The M16 execution statement is:

`M16 realizes the M15-qualified balanced ternary retained-state execution contract through scheduler execution, deterministic request-lane arbitration, retained pending routes, active-neutral transition generation, transition-capacity enforcement, retained-state writeback, integrated counters, and ten invariant flags.`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Canonical opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity retained-state transitions are forbidden.

The current computational and implementation chain is:

`M15-qualified resonant semantic computation`

↓

`M15 deterministic implementation mapping`

↓

`M16 executable RTL retained-state realization`

↓

`M16 target-independent FPGA preparation`

## 37. Current File Alignment

This document is aligned with the current release-facing files:

- `../README.md`;
- `../CI.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../RELEASE_CHECKLIST_v1_8_0.md`;
- `../CHANGELOG.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../CONTRIBUTING.md`;
- `../MILESTONES.md`;
- `../PROJECT_STRUCTURE.md`;
- `../ROADMAP.md`.

This document is aligned with the foundation and architecture files:

- `./README.md`;
- `./architecture.md`;
- `./core_principles.md`;
- `./mathematical_foundation.md`;
- `./physical_foundation.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `./m16_rtl_core_realization_execution_semantics.md`;
- `./m16_rtl_core_interface_contract.md`;
- `./m16_scheduler_state_rtl_realization.md`;
- `./m16_request_lane_arbitration_module.md`;
- `./m16_pending_route_register_module.md`;
- `./m16_active_neutral_transition_module.md`;
- `./m16_transition_capacity_guard_module.md`;
- `./m16_retained_state_update_module.md`;
- `./m16_invariant_assertion_set.md`.

This document is aligned with the M16 execution evidence:

- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

This document is aligned with the qualification workflows:

- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Historical benchmark evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 38. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Architecture:

`Ternary Fractal Resonant Coherence Processor`

Processor class:

`Ternary Resonant Coherence Processor`

Qualified semantic computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with asymmetric phase lag, hierarchical fractal coupling, phase evolution, resonance selection, Kuramoto order parameter R, multiscale phase coherence, stateful delay dynamics, local thermal-phase interaction, local correlated gamma drift, nonlinear coherence compression, dynamic stability evaluation, phase-derived ternary targets, distributed commit, mandatory active-neutral routing, and retained coherent ternary state`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current release:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified Python executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified M3 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

M15 semantic and implementation-mapping foundation:

| Qualification record | Result |
|---|---:|
| self-test | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 matches = 1.0` |
| deterministic replay matches | `6 / 6 matches = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

M16 RTL execution qualification:

| Field | Recorded value |
|---|---|
| workflow run | `#84` |
| source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| invariant flags | `1111111111` |
| status | `M16 RTL EXECUTION LAYER CLOSED` |

M16 FPGA preparation qualification:

| Field | Recorded value |
|---|---|
| workflow run | `#2` |
| repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| `core_ready` | `1` |
| invariant flags | `1111111111` |
| status | `M16 FPGA PREPARATION LAYER CLOSED` |

Historical archived transition result:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch under the historical FRP v0.9.3 transition benchmark model`

Current release qualification state:

`FRP v1.8.0 / M16 — PASS`

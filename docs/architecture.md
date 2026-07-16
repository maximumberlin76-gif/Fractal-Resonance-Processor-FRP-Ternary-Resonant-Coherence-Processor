# FRP Architecture

**Ternary Fractal Resonant Coherence Processor**

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the current architecture of the Fractal Resonance Processor (FRP).

FRP combines:

- Kuramoto-Sakaguchi resonant phase dynamics;
- hierarchical fractal coupling;
- multiscale phase coherence;
- stateful delay and endogenous thermal feedback;
- phase-derived balanced ternary retained-state execution.

Current architecture state:

| Field | Current value |
|---|---|
| version | `FRP v1.8.0` |
| milestone | `M16 — RTL Core Realization and Execution Semantics Package` |
| executable semantic reference | `../frp_prototype_v1_7_0.py` |
| structured-output schema | `frp.structured_output.v1.7.0` |
| benchmark-matrix schema | `frp.m3.benchmark_matrix.v1.7.0` |
| M15 semantic and implementation-mapping qualification | `41 / 41 PASS` |
| M16 RTL execution qualification | `PASS` |
| M16 FPGA preparation qualification | `PASS` |
| M16 RTL status | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current release-facing records:

- `../RELEASE_NOTES_v1_8_0.md`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_CHECKLIST_v1_8_0.md`.

Foundation documents:

- `./mathematical_foundation.md`;
- `./physical_foundation.md`.

M15 semantic and implementation-mapping foundation:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

## FRP v1.8.0 — M16 RTL Core Realization Layer

FRP v1.8.0 M16 realizes the M15-qualified retained-state execution contract as an executable SystemVerilog RTL core and a target-independent FPGA integration boundary.

The M16 RTL source boundary is:

`../rtl/m16/`

The M16 FPGA preparation boundary is:

`../fpga/m16/`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`../frp_prototype_v1_7_0.py`

M15 remains the qualified semantic and implementation-mapping foundation of M16.

### M16 Retained-State Execution Chain

The M16 RTL execution chain is:

`phase-derived balanced ternary target`

→ `temporal scheduler state`

→ `retained pending-route completion priority`

→ `deterministic request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `distributed transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry`

→ `integrated invariant evaluation`

The FPGA preparation boundary adds:

`asynchronous external reset assertion`

→ `two-stage synchronous reset release`

→ `core_ready`

→ `qualified tick, counter-clear, and request inputs`

→ `frp_m16_core execution`

### M16 RTL Artifacts

| Path | Architecture function |
|---|---|
| `../rtl/m16/frp_m16_pkg.sv` | canonical encodings, scheduler types, transition classes, invariant indexes, and shared functions |
| `../rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `../rtl/m16/frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `../rtl/m16/frp_m16_pending_routes.sv` | retained pending-polarity creation, ownership, retention, completion, and clearing |
| `../rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation |
| `../rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `../rtl/m16/frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `../rtl/m16/frp_m16_core.sv` | integrated RTL execution and synthesis boundary |
| `../rtl/m16/frp_m16_assertions.sv` | architectural, temporal, routing, capacity, domain, and writeback assertions |
| `../rtl/m16/frp_m16_tb.sv` | deterministic executable architectural testbench |

M16 RTL documentation:

| Path | Architecture function |
|---|---|
| `../rtl/m16/README.md` | RTL architecture and execution semantics |
| `../rtl/m16/ARTIFACTS.md` | qualified RTL artifact manifest |
| `../rtl/m16/SIMULATION.md` | Verilator build and execution procedure |
| `../rtl/m16/SIMULATION_TRANSCRIPT.md` | executable qualification record |
| `../rtl/m16/CLOSURE.md` | M16 RTL closure record |

### M16 FPGA Preparation Artifacts

| Path | Architecture function |
|---|---|
| `../fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `../fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `../fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation qualification record |
| `../fpga/m16/CLOSURE.md` | FPGA preparation closure record |

### M16 Qualification Records

| Layer | Workflow | Run | Commit | Result |
|---|---|---:|---|:---:|
| M16 RTL execution | `FRP M16 RTL Artifact Boundary` | `#84` | `ede53cf` | `SUCCESS` |
| M16 FPGA preparation | `FRP M16 FPGA Preparation` | `#2` | `ede53cf` | `SUCCESS` |

Workflow files:

- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Qualified global relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

FPGA terminal invariant vector:

`invariant_flags = 1111111111`

## 1. Architecture Identity

The complete current architecture chain is:

`cell phase and frequency state`

→ `Kuramoto-Sakaguchi resonant phase coupling`

→ `asymmetric Sakaguchi phase lag gamma`

→ `dyadic hierarchical fractal coupling`

→ `phase velocity and wrapped phase evolution`

→ `resonance selection`

→ `Kuramoto order parameter R`

→ `multiscale phase coherence`

→ `stateful delay dynamics`

→ `distributed local thermal field`

→ `local correlated gamma drift`

→ `nonlinear coherence compression`

→ `dynamic stability C(t) - P(t)`

→ `phase-derived balanced ternary target`

→ `distributed ternary commit`

→ `mandatory tick-separated routing through active neutral state 0`

→ `retained coherent ternary state`

→ `deterministic fixed-point implementation mapping`

→ `stateful quantized hardware-shadow execution`

→ `cycle-exact integer reference trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog interface mapping`

→ `reference RTL equivalence and exact replay`

→ `M15 qualification closure`

→ `M16 executable SystemVerilog RTL core`

→ `M16 architectural assertions`

→ `M16 target-independent FPGA integration`

→ `M16 FPGA preparation qualification closure`

The resonant dynamic domain evolves the phase, frequency, coupling, delay, thermal, gamma, coherence, and stability state.

The balanced ternary domain carries state, target, transition, and retained result.

The M15 layer defines the qualified deterministic numeric and interface mapping.

The M16 layer implements the retained-state execution boundary in RTL and exposes it through target-independent FPGA integration.

The mathematical relations are recorded in:

`./mathematical_foundation.md`

The physical-domain relations and evidence boundary are recorded in:

`./physical_foundation.md`

## 2. Two Connected Computational Domains

### 2.1 Resonant Dynamic Domain

The resonant dynamic domain contains:

- cell phase;
- base frequency;
- target frequency;
- current frequency;
- frequency lag;
- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- scheduler-dependent phase contribution;
- delayed frequency response;
- distributed local thermal state;
- thermal coupling-factor evolution;
- local correlated gamma drift;
- wrapped phase evolution;
- global Kuramoto order parameter `R`;
- pair-domain phase coherence;
- cluster phase coherence;
- supercluster phase coherence;
- global phase coherence;
- nonlinear coherence compression;
- dynamic stability evaluation.

### 2.2 Balanced Ternary State and Retained-Result Domain

The balanced ternary domain contains:

- retained states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- explicit transition requests;
- distributed commit;
- transition-fraction limits;
- request lanes;
- retained pending routes;
- mandatory tick separation;
- scheduler-controlled transition eligibility;
- retained ternary result.

The resonant dynamic domain supplies the phase-derived ternary target boundary.

The balanced ternary domain executes and retains the resulting state transitions.

## 3. Current Executable Architecture

The current repository contains four connected execution representations.

| Representation | Source | Architecture role |
|---|---|---|
| `FractalResonanceProcessor` | `../frp_prototype_v1_7_0.py` | floating semantic reference |
| `QuantizedReferenceShadowProcessor` | `../frp_prototype_v1_7_0.py` | stateful fixed-point hardware-shadow reference |
| `frp_m16_core` | `../rtl/m16/frp_m16_core.sv` | executable retained-state RTL core |
| `frp_m16_fpga_top` | `../fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration boundary |

The floating semantic reference executes the resonant and balanced ternary architecture in continuous numeric form.

The quantized hardware-shadow reference maps the same semantic architecture into deterministic fixed-point execution.

The M16 RTL core executes scheduler control, request arbitration, pending-route handling, active-neutral routing, transition-capacity admission, retained-state writeback, telemetry, and invariant aggregation.

The FPGA top adds reset synchronization, readiness state, and execution-input gating around the qualified M16 RTL core.

The default structured demo path records:

- configuration;
- kernel contract;
- hardware profile;
- execution summary;
- preload digest;
- trace digest;
- cell-trace digest.

Full trace mode adds:

- processor-tick trace;
- cell-tick trace;
- route events.

## 4. Balanced Ternary State Space

The retained state, target, transition, and result domain is:

`{-1, 0, 1}`

| State | RTL encoding | Architecture role |
|---:|:---:|---|
| `-1` | `2'b11` | negative target polarity and retained negative state |
| `0` | `2'b00` | active neutral balancing, damping, transition, and stabilization state |
| `1` | `2'b01` | positive target polarity and retained positive state |
| reserved | `2'b10` | invalid retained-state encoding |

State-domain relations:

`balanced_ternary_state_domain = True`

`reserved_state_events = 0`

The ternary domain carries:

- current retained state;
- phase-derived target;
- explicit request target;
- transition path;
- pending route;
- retained result.

## 5. Active Neutral Routing Architecture

Opposite-polarity retained-state execution follows:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity retained-state transitions are forbidden:

`-1 → 1`

`1 → -1`

Tick-separated execution is:

`tick N: active polarity → 0`

→ `pending target polarity retained`

→ `tick N+1 or later: 0 → target polarity`

The pending route preserves:

- cell ownership;
- requested target polarity;
- scheduler deferral;
- transition-capacity deferral;
- completion eligibility from retained state `0`.

Required routing relations:

`actual_direct_events = 0`

`queue_overflow_events = 0`

The active neutral state `0` executes as the balancing, damping, transition, and stabilization state between opposite retained polarities.

## 6. Current Tick Architecture

The current floating semantic reference is:

`frp_prototype_v1_7_0.py`

Its processor tick executes in the following order:

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

The floating semantic tick is implemented by:

`FractalResonanceProcessor.tick(...)`

The M15 exact-integer shadow preserves the same semantic ordering through fixed-point state, arithmetic, lookup, topology, telemetry, and deterministic vector layers.

The M16 RTL core receives the qualified phase-derived ternary target boundary and explicit request interface, then executes:

`scheduler state`

→ `pending-route completion priority`

→ `request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `transition-capacity enforcement`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry and invariant evaluation`

The Python semantic reference remains `frp_prototype_v1_7_0.py`. The M16 RTL layer does not create or rename a Python prototype.

## 7. Cross-Tick Phase-to-State Architecture

The floating semantic tick derives automatic ternary targets from the phase field present at the beginning of the target-processing stage.

The same tick then advances:

- delay state;
- thermal state;
- gamma state;
- coupling field;
- phase state;
- coherence state;
- dynamic stability state.

Across successive ticks, the phase-to-state relation is:

`phase field produced by previous evolution`

↓

`current-tick ternary target extraction`

↓

`distributed ternary transition`

↓

`delay and thermal update`

↓

`Kuramoto-Sakaguchi phase evolution`

↓

`new phase field`

↓

`next-tick ternary target extraction`

The M15 implementation-mapping layer represents the phase-derived ternary target boundary in the exact-integer execution path.

The M16 RTL interface receives that boundary as:

`target_q`

and receives explicit retained-state transition requests through:

- `request_valid`;
- `request_cell_index`;
- `request_target`.

The phase-derived target boundary, explicit request interface, active-neutral routing, pending-route retention, and retained-state writeback are separate stages of the same processor execution path.

## 8. Kuramoto-Sakaguchi Resonant Phase Layer

For cells `i` and `j`, the floating semantic interaction term is:

`sin(phase_j - phase_i - gamma_effective_i)`

The effective pair coefficient is:

`K_ij = K_nominal × W_ij × T_i × T_j`

where:

- `K_nominal` is the nominal coupling strength;
- `W_ij` is the hierarchical pair weight;
- `T_i` and `T_j` are the local thermal coupling factors.

The coupling field of cell `i` is:

`coupling_field_i = sum_(j != i) K_ij × sin(phase_j - phase_i - gamma_effective_i)`

The phase lag is asymmetric because the interaction of cell `i` uses:

`gamma_effective_i`

Current default nominal phase lag:

`gamma_nominal = 0.30 × pi`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

The phase field produced by this layer is used by the subsequent phase-derived ternary target boundary.

## 9. Phase Velocity and Phase Evolution

The current floating semantic phase velocity is:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2pi`

The phase state includes the current values of:

- delayed oscillator frequency;
- scheduler phase push;
- hierarchical resonant coupling;
- thermal coupling factors;
- local gamma drift.

After phase evolution, the executable evaluates:

- global phase order;
- multiscale phase order;
- cluster metrics;
- processor-specific operational coherence and pressure quantities.

The evolved phase field is retained for the next tick's ternary target extraction.

## 10. Dyadic Hierarchical Fractal Topology

The current architecture uses a dyadic hierarchical ultrametric topology.

The valid cell-count domain uses powers of two beginning at:

`2`

Current default cell count:

`cells = 16`

Current default hierarchy depth:

`hierarchy_depth = 4`

For a valid power-of-two cell count:

`hierarchy_depth = cells.bit_length() - 1`

For two distinct cells `i` and `j`, hierarchical distance is:

`distance(i, j) = (i XOR j).bit_length()`

For hierarchy distance `d`, shell population is:

`shell_population(d) = 2^(d - 1)`

For exponent `alpha`, the floating shell normalizer is:

`Z_alpha = sum_(d = 1 to hierarchy_depth) 1 / d^alpha`

The normalized pair weight at distance `d` is:

`W(d) = 1 / (shell_population(d) × d^alpha × Z_alpha)`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

The exact-integer topology uses Q2.30 pair weights and applies residual closure to the distance-1 weight.

The qualified fixed-point topology relation is:

`sum_d shell_population(d) × pair_weight_q30(d) = 2^30`

Current fixed-point topology exactness marker:

`fixed_point_topology_sum_exact = True`

## 11. Dense and Hierarchical Coupling Representations

The executable semantic reference contains two coupling paths:

- `dense`;
- `hierarchical`.

The dense path evaluates every non-self pair interaction directly.

The hierarchical path evaluates dyadic sibling shells through weighted phase-prefix accumulation.

Both paths evaluate the same interaction components:

`hierarchical pair weight`

× `local thermal factor of cell i`

× `local thermal factor of cell j`

× `Kuramoto-Sakaguchi phase interaction`

× `nominal coupling strength`

The selected path is recorded by:

`coupling_path`

The dense and hierarchical representations are included in the deterministic validation and semantic-correlation contours.

## 12. Scheduler Architecture

The processor scheduler modes are:

- `free`;
- `7/1`;
- `1/7`.

### Floating Semantic Scheduler Phase Push

The floating phase layer applies:

| Scheduler state | Phase push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all other scheduler states | `0.003` |

### Free Mode

Every enabled tick is:

`free`

The M16 `free` state is commit-capable and neutralize-capable.

### 7/1 Mode

The repeating eight-tick sequence contains:

- seven `balance` ticks;
- one `commit` tick.

The `commit` state occurs when:

`(tick + 1) mod 8 = 0`

All other period positions are:

`balance`

The M16 `balance` state is neutralize-capable. The M16 `commit` state is commit-capable.

### 1/7 Mode

The repeating eight-tick sequence contains:

- one `excite` tick;
- seven `neutralize` ticks.

The `excite` state occurs when:

`tick mod 8 = 0`

All other period positions are:

`neutralize`

The M16 `excite` state is commit-capable. The M16 `neutralize` state is neutralize-capable.

### Validated Scheduler Counts

Current validated 16-tick profiles:

| Scheduler mode | Counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Current validated 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

The scheduler counter relation is:

`sum(scheduler_counts) = ticks_recorded`

## 13. Kuramoto Order Parameter R

For a phase field containing `N` cells, define:

`mean_cos = (1 / N) × sum_i cos(phase_i)`

`mean_sin = (1 / N) × sum_i sin(phase_i)`

The Kuramoto phase-order parameter is:

`R = sqrt(mean_cos^2 + mean_sin^2)`

The executable floating reference evaluates this relation through:

`phase_order(phases)`

The exact-integer shadow evaluates the corresponding Q2.30 relation through:

`phase_order_q30(phase_words)`

The same phase-order relation is applied to hierarchical groups.

The range is:

`0 <= R <= 1`

`R` is the Kuramoto phase-order quantity of the current cell field.

Phase synchronization and phase coherence are not interchangeable with general endogenous structural coherence.

`R` is not identical to general endogenous structural coherence `C(t)`.

`R` is also distinct from the processor-specific operational quantity `C_FRP`.

## 14. Multiscale Coherence Architecture

The dyadic hierarchy evaluates phase order across:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

For hierarchy level `level`, group size is:

`group_size = 2^level`

The executable partitions the phase field into contiguous groups of that size and applies the phase-order relation to each group.

Current structured outputs include:

- `pair_domain_coherence_mean`;
- `pair_domain_coherence_min`;
- `cluster_coherence_mean`;
- `cluster_coherence_min`;
- `supercluster_coherence_mean`;
- `supercluster_coherence_min`;
- `global_phase_coherence`;
- `coherence_dispersion_across_clusters`.

The exact-integer shadow records corresponding fixed-point values, including:

- `pair_domain_coherence_mean_q30`;
- `pair_domain_coherence_min_q30`;
- `cluster_coherence_mean_q30`;
- `cluster_coherence_min_q30`;
- `supercluster_coherence_mean_q30`;
- `supercluster_coherence_min_q30`;
- `global_phase_coherence_q30`;
- `coherence_dispersion_across_clusters_q30`.

The multiscale phase-order map and processor-specific operational coherence quantity remain separate recorded structures.

## 15. Stateful Delay Architecture

Each cell retains:

- base frequency;
- frequency target;
- current frequency.

The current floating frequency-target relation is:

`frequency_target_i = base_frequency_i + 0.06 × abs(state_i) + 0.12 × switch_activity_i`

The delayed response is:

`frequency_next_i = frequency_current_i + 0.30 × (frequency_target_i - frequency_current_i)`

Current default delay coefficient:

`delay_alpha = 0.30`

The remaining frequency lag is:

`frequency_lag_i = abs(frequency_target_i - frequency_next_i)`

The retained delay state is recorded through:

- `base_frequency`;
- `frequency_target`;
- `frequency_current`;
- `frequency_lag`.

The M15 exact-integer shadow preserves the same relations through Q16.16 state and arithmetic.

The frequency lag is used by the phase-velocity, generated-power, operational-coherence, and dynamic-stability calculations.

## 16. Distributed Local Thermal Architecture

The floating semantic reference and M15 exact-integer shadow maintain a distributed local thermal field.

Each cell tracks:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The current floating generated-power relation is:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

The current thermal-dissipation relation is:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

The current hierarchical thermal-diffusion relation is:

`thermal_diffusion_i = thermal_diffusion_gain × sum_j thermal_weight_ij × (previous_heat_j - previous_heat_i)`

The local heat update is:

`heat_i = max(ambient_heat, previous_heat_i + generated_power_i - thermal_dissipation_i + thermal_diffusion_i)`

The processor-wide heat quantity is:

`heat = mean_i(heat_i)`

Current default thermal parameters:

| Parameter | Value |
|---|---:|
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| thermal diffusion gain | `0.035` |
| thermal topology exponent | `1.20` |

The thermal state is an endogenous processor feedback variable in the executable FRP model.

## 17. Thermal Coupling Feedback

The current local thermal overload is:

`thermal_overload_i = max(0, heat_i - thermal_soft_limit)`

The current local thermal node factor is:

`thermal_node_factor_i = exp(-0.5 × thermal_coupling_gain × thermal_overload_i)`

Current thermal coupling gain:

`thermal_coupling_gain = 2.50`

For cells `i` and `j`, the effective pair coupling includes:

`thermal_node_factor_i × thermal_node_factor_j`

The feedback chain recorded by the semantic model is:

`local thermal overload`

↓

`thermal node factor`

↓

`effective resonant coupling`

↓

`phase evolution`

↓

`phase-order quantities`

↓

`processor-specific operational stability quantities`

The M15 exact-integer thermal topology uses Q2.30 weights with the qualified relation:

`sum_d shell_population(d) × thermal_pair_weight_q30(d) = 2^30`

Current fixed-point thermal exactness marker:

`fixed_point_thermal_sum_exact = True`

## 18. Local Correlated Gamma Architecture

The semantic processor tracks:

- nominal gamma;
- deterministic gamma-noise targets;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

Gamma-noise targets refresh when:

`tick mod 8 = 0`

Current floating target range:

`[-1.0, 1.0]`

The correlated update is:

`gamma_noise_state_i = gamma_noise_state_i + 0.15 × (gamma_noise_target_i - gamma_noise_state_i)`

The effective local phase lag is:

`gamma_effective_i = gamma_nominal + 0.08 × thermal_overload_i × gamma_noise_state_i`

The local drift is:

`gamma_drift_i = gamma_effective_i - gamma_nominal`

The Kuramoto-Sakaguchi interaction of cell `i` uses:

`gamma_effective_i`

The M15 exact-integer shadow records gamma target, gamma state, effective gamma, and gamma drift through the qualified fixed-point representation.

## 19. Nonlinear Coherence Compression

The semantic processor applies nonlinear compression to the raw phase-order quantity.

The current margin pressure is:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

Current stability soft margin:

`stability_soft_margin = 0.25`

The mean thermal overload is:

`thermal_overload_mean = mean_i(thermal_overload_i)`

The compression relation is:

`coherence_compression = exp(-(3.0 × thermal_overload_mean^2 + 1.5 × margin_pressure^2))`

The effective phase-order support quantity is:

`effective_coherence = raw_phase_coherence × coherence_compression`

The current compression inputs are the local thermal-overload mean and the preceding processor-specific operational margin.

## 20. Dynamic Stability Architecture

The executable processor records the structured fields:

- `C`;
- `P`;
- `C_minus_P`.

The corresponding processor-specific operational quantities are:

- `C_FRP`;
- `P_FRP`;
- `Delta_FRP = C_FRP - P_FRP`.

The current operational coherence relation is:

`C_FRP = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

The current operational destabilizing-load relation is:

`P_FRP = heat + switch_load`

The current operational stability margin is:

`Delta_FRP = C_FRP - P_FRP`

The executable field mapping is:

| Structured field | Operational quantity |
|---|---|
| `C` | `C_FRP` |
| `P` | `P_FRP` |
| `C_minus_P` | `Delta_FRP` |

The current validated relation is:

`C_minus_P_min > 0.0`

The operational calculation includes:

- effective phase-order support;
- cluster phase order;
- neutral-state fraction;
- mean frequency lag;
- processor heat state;
- switching load.

`C_FRP` and `P_FRP` are processor-specific operational quantities.

`C_FRP` is not identical to general endogenous structural coherence `C(t)`.

## 21. Phase-Derived Ternary Target Boundary

The executable semantic reference maps the evolving phase field into the balanced ternary target domain:

`{-1, 0, 1}`

The current mapping is:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The phase-derived target boundary is:

`resonant phase field`

↓

`balanced ternary target`

↓

`transition request and capacity processing`

↓

`active-neutral route processing`

↓

`retained ternary state`

The M15 exact-integer shadow represents the phase-derived targets through canonical two-bit ternary encodings.

The M16 RTL core receives the packed phase-derived target vector through:

`target_q`

## 22. Distributed Commit Architecture

Current transition fraction:

`transition_fraction = 0.25`

The maximum-change relation is:

`max_changes = max(1, round(cells × transition_fraction))`

The M15 request-lane relation is:

`request_lanes = max_changes`

The M16 RTL relation is:

`REQUEST_LANES = frp_calc_request_lanes(CELLS)`

Qualified profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

An actual retained-state change consumes one unit of transition capacity.

Same-state retention consumes no transition capacity.

The two legs of an opposite-polarity route consume capacity on separate eligible ticks:

`-1 → 0`

followed by:

`0 → 1`

or:

`1 → 0`

followed by:

`0 → -1`

The switching-load relation is:

`switch_load = accepted_changes / cells`

The validated transition-capacity relation is:

`switch_load_peak <= transition_fraction`

Current default boundary:

`switch_load_peak <= 0.25`

## 23. Retained Coherent State Architecture

The retained processor result is the balanced ternary state produced through the connected semantic execution path.

The retained-state path includes:

- phase evolution;
- Kuramoto order parameter `R`;
- multiscale phase-order values;
- delay state;
- thermal state;
- gamma drift;
- nonlinear coherence compression;
- processor-specific operational stability quantities;
- phase-derived ternary targets;
- explicit transition requests;
- transition-capacity enforcement;
- active-neutral routing;
- pending-route retention;
- final balanced ternary vector.

The retained state domain is:

`{-1, 0, 1}`

Direct opposite-polarity retained-state transitions are forbidden.

Opposite-polarity transitions use:

`-1 → 0 → 1`

`1 → 0 → -1`

The M16 RTL outputs the retained processor state through:

`state_out`

and the retained pending-route state through:

`pending_route_out`

## 24. Structured Telemetry Architecture

The Python semantic reference uses:

`frp.structured_output.v1.7.0`

The benchmark matrix uses:

`frp.m3.benchmark_matrix.v1.7.0`

Compact structured execution records include deterministic trace and cell-trace digests by default.

Full trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Current default full-trace sizes are:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

Semantic and M15 telemetry includes:

- scheduler state and counts;
- balanced ternary state;
- packed retained state;
- phase state;
- frequency target, current frequency, and frequency lag;
- switching load;
- generated power;
- thermal dissipation and diffusion;
- local heat and thermal overload;
- effective gamma and gamma drift;
- thermal coupling factor;
- coupling field;
- raw phase order;
- coherence compression;
- effective coherence;
- multiscale phase-order values;
- `C`;
- `P`;
- `C_minus_P`;
- route counters;
- pending-route count.

M16 RTL telemetry includes:

- scheduler mode and scheduler state;
- scheduler counters;
- request acceptance and rejection;
- accepted, neutral-routed, and changed-cell masks;
- accepted changes and remaining capacity;
- switch-load numerator;
- requested, prevented, neutral-routed, actual-direct, reserved-state, and queue-overflow counters;
- ten invariant flags.

## 25. Current Default Architecture Profile

### Semantic and M15 Reference Defaults

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

Derived default values:

| Derived parameter | Value |
|---|---:|
| hierarchy depth | `4` |
| request lanes | `4` |
| packed ternary state width | `32 bits` |

### M16 RTL Package Defaults

| Parameter | Default |
|---|---:|
| `FRP_M16_DEFAULT_CELLS` | `16` |
| `FRP_M16_STATE_BITS` | `2` |
| `FRP_M16_COUNTER_BITS` | `32` |
| transition fraction numerator | `1` |
| transition fraction denominator | `4` |
| derived request lanes | `4` |
| packed ternary state width | `32 bits` |

The qualified M16 RTL and FPGA integration testbenches use:

| Parameter | Qualified value |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| packed ternary state width | `16 bits` |

## 26. Scaling Architecture

The qualified M15 scaling profiles are:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---:|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

The scaling relations are:

`hierarchy_depth = cells.bit_length() - 1`

`request_lanes = max(1, round(cells × transition_fraction))`

`packed_state_width = 2 × cells`

Each qualified profile records:

- balanced ternary state-domain validity;
- hierarchy-depth validity;
- request-lane validity;
- packed-state-width validity;
- transition-capacity validity;
- scheduler-count validity;
- topology validation `PASS`;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

The M16 package preserves the same request-lane relation for `8`, `16`, and `32` cells.

## 27. M15 Hardware-Facing Numeric Architecture

The qualified M15 numeric representations are:

| Domain | Representation | Width | Fraction or phase relation |
|---|---|---:|---|
| general dynamic scalar | `S32Q16` | `32` | `16` fractional bits |
| normalized coefficient | `S32Q30` | `32` | `30` fractional bits |
| phase | `PHASE_U32` | `32` | `2^32` units = `2pi` |
| Sakaguchi gamma | `GAMMA_S32` | `32` | `PHASE_U32` scale |

The arithmetic rules include:

- round to nearest;
- half cases away from zero;
- signed destination saturation;
- phase overflow modulo `2^32`;
- `mul_q30 = round_shift(a × b, 30)`;
- `mul_q16 = round_shift(a × b, 16)`;
- `mul_q16_q30 = round_shift(a × b, 30)`.

The deterministic trigonometric profile is:

| Field | Value |
|---|---:|
| table entries | `4096` |
| address bits | `12` |
| index relation | `phase_word >> 20` |
| output type | `S32Q30` |

The deterministic exponential profile is:

| Field | Value |
|---|---:|
| table entries | `4096` |
| input domain | `[0, 8 × 2^16]` |
| output type | `S32Q30` |

The exact fixed-point normalization markers are:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 28. Balanced Ternary Hardware Encoding

The M15 hardware-facing two-bit encoding is:

| Ternary state | Two-bit code | Integer code |
|---:|---|---:|
| `-1` | `2'b11` | `3` |
| `0` | `2'b00` | `0` |
| `1` | `2'b01` | `1` |
| reserved | `2'b10` | `2` |

The executable maps are:

`STATE_TO_CODE = {-1: 0b11, 0: 0b00, 1: 0b01}`

`CODE_TO_STATE = {0b11: -1, 0b00: 0, 0b01: 1}`

The canonical retained-state domain is:

`{-1, 0, 1}`

The reserved-state invariant is:

`reserved_state_events = 0`

The M16 RTL package preserves the same state codes through:

- `FRP_TERN_NEG`;
- `FRP_TERN_ZERO`;
- `FRP_TERN_POS`;
- `FRP_TERN_RESERVED`.

## 29. Ten M15 Artifact Layers

FRP v1.7.0 defines ten qualified M15 artifact layers:

| # | Artifact layer | Schema |
|---:|---|---|
| `1` | `fixed_point_interface_profile` | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| `2` | `balanced_ternary_hardware_encoding_map` | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| `3` | `quantized_reference_shadow_model` | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| `4` | `cycle_exact_reference_trace` | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| `5` | `rtl_comparison_vector_package` | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| `6` | `systemverilog_testbench_interface_map` | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| `7` | `synthesizable_rtl_reference_core` | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| `8` | `rtl_assertion_correlation_harness` | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| `9` | `reference_rtl_equivalence_report` | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| `10` | `qualification_closure_manifest` | `frp.m15.qualification_closure_manifest.v1.7.0` |

The implementation-mapping chain is:

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

## 30. Exact M15 Tick Execution Architecture

The M15 quantized shadow and RTL reference-core contract preserve the same 26-stage tick order:

1. resolve scheduler state for the tick;
2. clear current-tick switch-change counters;
3. clear current-tick per-cell switch activity;
4. process ready pending neutral routes;
5. process external request lanes in ascending lane order;
6. process phase-derived reference targets when `auto_targets_enable = 1`;
7. calculate current-tick switch load;
8. update frequency targets;
9. update lagged frequency states;
10. calculate local generated power;
11. calculate local thermal dissipation;
12. calculate hierarchical thermal diffusion;
13. update local heat states;
14. calculate local thermal overload;
15. update deterministic gamma-noise correlation states;
16. update local gamma-effective values;
17. update thermal node factors;
18. calculate hierarchical phase-coupling field;
19. update phase velocities;
20. update wrapped phase words;
21. calculate multiscale phase-order values;
22. calculate processor-specific operational `C_FRP`, recorded as `C`;
23. calculate processor-specific operational `P_FRP`, recorded as `P`;
24. calculate `C_minus_P`;
25. detect the first positive-to-nonpositive operational-margin crossing;
26. capture post-tick trace outputs.

This order defines the M15 cycle-correlation contract that supplies the semantic and implementation-mapping foundation for the M16 retained-state execution boundary.

## 31. Cycle-Exact Trace Architecture

The cycle-exact reference trace provides the integer golden path between:

`stateful quantized processor execution`

and:

`deterministic RTL comparison`

Current default trace length:

`64 ticks`

The trace records integer state for:

- scheduler correlation;
- packed balanced ternary state correlation;
- pending-route correlation;
- transition-counter correlation;
- phase-word correlation;
- fixed-point frequency correlation;
- fixed-point thermal correlation;
- gamma correlation;
- coupling-field correlation;
- multiscale phase-order correlation;
- operational `C`, `P`, and `C_minus_P` correlation.

Each trace row is captured after completion of the corresponding processor tick.

## 32. Deterministic RTL Vector Architecture

The M15 vector package contains ten files:

1. `frp_m15_kernel_vectors.vec`;
2. `frp_m15_pending_routes.trace`;
3. `frp_m15_scheduler_free_vectors.vec`;
4. `frp_m15_scheduler_7_1_vectors.vec`;
5. `frp_m15_scheduler_1_7_vectors.vec`;
6. `frp_m15_full_correlation_vectors.vec`;
7. `frp_m15_cell_trace.vec`;
8. `frp_m15_reference_preload.json`;
9. `frp_m15_trig_lut_q30.vec`;
10. `frp_m15_sha256_manifest.json`.

The deterministic qualification generates two independent vector directories and compares the files byte for byte.

Qualified result:

`10 / 10 vector files byte-identical`

Canonical M15 vector-package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The SHA-256 manifest records the exact generated package content.

## 33. SystemVerilog and RTL Interface Architecture

The M15 `systemverilog_testbench_interface_map` default parameters are:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

Execution inputs:

- `clk`;
- `reset_n`;
- `scheduler_mode`;
- `auto_targets_enable`;
- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Verification-stimulus inputs:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Comparison outputs:

- `states_packed`;
- `scheduler_state`;
- `pending_route_count`;
- `switch_load_q`;
- `heat_global_q`;
- `global_phase_coherence_q`;
- `C_q`;
- `P_q`;
- `C_minus_P_q`;
- direct-transition and neutral-route counters.

The M15 `synthesizable_rtl_reference_core` artifact records the exact execution contract and the planned reference-core module set.

The realized M16 SystemVerilog execution core is located under:

`rtl/m16/`

## 34. Assertion and Equivalence Architecture

The M15 RTL assertion-correlation artifact contains:

`13 assertions`

The assertion subjects are:

1. valid balanced ternary encoding;
2. reserved-state exclusion;
3. direct polarity-transition exclusion;
4. active-neutral route insertion;
5. target application after the ready tick;
6. `actual_direct_events = 0`;
7. transition-limit enforcement;
8. scheduler sequence;
9. scheduler-count consistency;
10. phase-topology fixed-point normalization;
11. thermal-topology fixed-point normalization;
12. deterministic trace tick count;
13. exact cycle-output match.

The exact integer comparison rule is:

`actual integer field == expected integer field`

The M15 equivalence architecture contains two boundaries.

### 34.1 Floating Semantic Reference to Quantized Shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Required maximum error bounds:

| Field | Maximum error |
|---|---:|
| phase | `0.02` |
| frequency | `0.0001` |
| heat | `0.001` |
| gamma | `0.000001` |
| coherence | `0.01` |
| `C` | `0.01` |
| `P` | `0.001` |
| `C_minus_P` | `0.01` |

### 34.2 Quantized Shadow Deterministic Replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 35. Qualification Architecture

### 35.1 M15 Semantic and Implementation-Mapping Foundation

The qualified M15 self-test package contains:

`41 checks`

Qualified result:

`41 / 41 PASS`

The M15 qualification record includes:

- `10 / 10` deterministic vector files byte-identical;
- `5 / 5` required semantic correlation matches equal to `1.0`;
- `6 / 6` deterministic replay matches equal to `1.0`;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- `scheduler_counts_valid = True`;
- `switch_load_peak <= transition_fraction`;
- `C_minus_P_min > 0.0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

M15 qualification closure result:

`PASS`

### 35.2 M16 RTL Execution Qualification

Current synchronized qualification record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `52s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Recorded terminal values:

| Field | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

The ten qualified invariant flags are:

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

### 35.3 M16 FPGA Preparation Qualification

Current synchronized qualification record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

Recorded terminal values:

| Field | Value |
|---|---:|
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

The qualified FPGA preparation boundary includes:

- target-independent FPGA integration-top elaboration;
- executable FPGA integration testbench execution;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten invariant flags.

## 36. Current M15 Workflow Architecture

The M15 qualification workflow is:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

The workflow performs nine stages:

1. checkout repository;
2. set up Python;
3. compile `frp_prototype_v1_7_0.py`;
4. generate M15 qualification outputs;
5. compare deterministic vector packages;
6. validate M15 schemas, kernel invariants, fixed-point contract, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture-document contract;
9. upload M15 qualification artifacts.

The current M16 workflow boundary contains:

| Workflow name | Workflow file | Role |
|---|---|---|
| `FRP M16 RTL Artifact Boundary` | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` | RTL execution qualification |
| `FRP M16 FPGA Preparation` | `.github/workflows/frp-m16-fpga-preparation.yml` | FPGA preparation qualification |
| `FRP M16 Canonical Core Domain` | `.github/workflows/frp-m16-canonical-core-domain.yml` | M16 core-domain notation maintenance |
| `FRP M16 Reserved Cell Cleanup` | `.github/workflows/frp-m16-reserved-cell-cleanup.yml` | M16 RTL identifier maintenance |

## 37. Published Validation Chain

Current release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

The synchronized M16 qualification records are:

| Layer | Run | Commit | Result | Status |
|---|---:|---|---|---|
| RTL execution | `#84` | `ede53cf` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| FPGA preparation | `#2` | `ede53cf` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |

The initial M16 closure records are:

| Layer | Run | Commit | Result |
|---|---:|---|---|
| RTL execution | `#82` | `a68a2af` | `SUCCESS` |
| FPGA preparation | `#1` | `326b69e` | `SUCCESS` |

The retained M15 release-validation records are:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

M15 release-record validated commit:

`5fd9a4f`

Qualification evidence paths:

- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`;
- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`;
- `TEST_REPORT_v1_8_0.md`;
- `FRP_VALIDATION_INDEX_v1_8_0.md`.

## 38. Comparative Architecture Context

The Comparative Architecture Benchmark Suite is located at:

`benchmarks/architecture_comparison/`

Schema:

`frp.benchmark.architecture_comparison.v1`

Architecture set:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

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

Hardware-sensitivity schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical hardware-sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Scenarios:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

Recorded fields:

`ranking_stable = true`

`ranking_sensitive = false`

Recorded ranking:

`binary_clock_gated_reference` → `direct_ternary_reference` → `binary_synchronous_reference` → `frp_v1_7_0_quantized_shadow`

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Recorded FRP event totals:

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

## 39. Historical Archived Ternary Thermal Evidence

The historical transition benchmark is recorded in:

`TEST_REPORT_v0_9_3.md`

Recorded values:

| Architecture | `heat_peak` | `switch_load_peak` | `actual_direct_events` |
|---|---:|---:|---:|
| `binary_style_forced_switch` | `0.051000` | `1.000000` | `2052` |
| `direct_ternary_commit` | `0.051000` | `1.000000` | `2052` |
| `distributed_neutral_ternary` | `0.003250` | `0.250000` | `0` |
| `frp_distributed_resonant` | `0.107000` | `0.250000` | `0` |

Recorded mathematical relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded numerical representations:

`15.69× lower heat_peak`

`93.63% lower heat_peak`

## 40. Relationship Between Historical and Current Architecture Layers

The historical v0.9.3 transition contour records:

- active-neutral routing;
- direct-event activity;
- switching load;
- historical heat proxy;
- dynamic stability.

The v1.7.0 M15 implementation-mapping contour records:

- fixed-point interface mapping;
- balanced ternary hardware encoding;
- quantized hardware-shadow execution;
- cycle-exact traces;
- deterministic vector packages;
- semantic correlation;
- exact deterministic replay;
- qualification closure.

The v1.8.0 M16 contour records:

- realized SystemVerilog retained-state execution;
- scheduler execution;
- request-lane arbitration;
- active-neutral routing;
- pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten invariant flags;
- target-independent FPGA integration preparation.

The historical heat proxy, comparative normalized-energy model, M15 operation counts, M16 RTL qualification, and M16 FPGA preparation qualification remain separate measurement and qualification contours.

## 41. Architecture Progression

The published architecture progression is:

`structured machine-readable processor execution`

↓

`benchmark and hardware signal mapping`

↓

`HDL trace and testbench preparation`

↓

`RTL interface and assertion contracts`

↓

`formal verification and equivalence scaffolds`

↓

`FPGA synthesis and timing structures`

↓

`production release packaging`

↓

`silicon and heterogeneous implementation architecture`

↓

`silicon production and tapeout readiness`

↓

`production integration and external implementation handoff`

↓

`external implementation feedback and production iteration`

↓

`production scaling and implementation stabilization`

↓

`physical implementation correlation and production qualification`

↓

`M15 fixed-point implementation mapping and qualification closure`

↓

`M16 RTL core realization and execution semantics`

↓

`M16 target-independent FPGA preparation`

The current qualification hierarchy is:

`M15 qualified semantic and implementation-mapping foundation`

→ `M16 qualified RTL execution layer`

→ `M16 qualified FPGA preparation layer`

## 42. Current File Alignment

This document is aligned with:

- `README.md`;
- `CI.md`;
- `frp_prototype_v1_7_0.py`;
- `RELEASE_NOTES_v1_8_0.md`;
- `TEST_REPORT_v1_8_0.md`;
- `FRP_VALIDATION_INDEX_v1_8_0.md`;
- `REPRODUCIBILITY.md`;
- `USAGE.md`;
- `INSTALL.md`;
- `CONTRIBUTING.md`;
- `docs/README.md`;
- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `docs/m16_rtl_core_realization_execution_semantics.md`;
- `docs/m16_scheduler_state_rtl_realization.md`;
- `docs/m16_request_lane_arbitration_module.md`;
- `docs/m16_pending_route_register_module.md`;
- `docs/m16_active_neutral_transition_module.md`;
- `docs/m16_transition_capacity_guard_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`;
- `docs/m16_qualification_manifest.md`;
- `docs/m16_qualification_index.md`;
- `rtl/m16/README.md`;
- `rtl/m16/ARTIFACTS.md`;
- `rtl/m16/SIMULATION.md`;
- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`;
- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `.github/workflows/frp-m16-fpga-preparation.yml`.

Historical benchmark alignment includes:

- `TEST_REPORT_v0_9_3.md`;
- `frp_prototype_v0_9_3_mobile.py`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

## 43. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Fractal Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with asymmetric phase lag, hierarchical fractal coupling, phase evolution, resonance selection, Kuramoto order parameter R, multiscale phase coherence, stateful delay dynamics, local thermal-phase interaction, local correlated gamma drift, nonlinear coherence compression, dynamic stability evaluation, phase-derived ternary targets, distributed commit, mandatory active-neutral routing, and retained coherent ternary state`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Executable semantic reference:

`frp_prototype_v1_7_0.py`

Structured output schema:

`frp.structured_output.v1.7.0`

Benchmark matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current realized RTL form:

`ten integrated SystemVerilog M16 artifacts under rtl/m16/`

Current FPGA preparation form:

`target-independent FPGA integration top and executable FPGA integration testbench under fpga/m16/`

M15 foundation result:

`41 / 41 PASS`

M16 RTL result:

`M16 RTL EXECUTION LAYER CLOSED`

M16 FPGA preparation result:

`M16 FPGA PREPARATION LAYER CLOSED`

Current release qualification state:

`FRP v1.8.0 / M16 — PASS`





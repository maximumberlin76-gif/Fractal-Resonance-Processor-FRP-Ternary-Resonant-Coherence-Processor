# Model Layer — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This directory defines the model registry of the Fractal Resonance Processor (FRP) and connects the retained background model record to the current validated processor architecture.

FRP is a ternary resonant coherence processor.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current architecture document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`../TEST_REPORT_v1_7_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`../RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

## 1. Directory Role

The `models/` directory serves two connected purposes:

1. define the current FRP model registry;
2. preserve preliminary model background with explicit release and architecture context.

The current model source is:

`../frp_prototype_v1_7_0.py`

The current implementation-mapping source is:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

The retained preliminary background file is:

`kuramoto_frp_background_model.md`

## 2. Directory Contents

| File | Role |
|---|---|
| `README.md` | current FRP model registry |
| `kuramoto_frp_background_model.md` | preliminary Kuramoto-type resonance-phase background record |

The active processor models are implemented in the current executable reference and exposed through structured telemetry, M15 artifact exports, validation records, and qualification workflows.

## 3. Current Model Registry

The current FRP model stack contains:

1. balanced ternary state and retained-result model;
2. active-neutral transition-route model;
3. distributed commit model;
4. scheduler model;
5. cell phase and frequency-state model;
6. Kuramoto-Sakaguchi resonant interaction model;
7. asymmetric local gamma model;
8. dyadic hierarchical fractal topology model;
9. dense and hierarchical coupling representations;
10. phase velocity and phase-evolution model;
11. Kuramoto order-parameter model;
12. multiscale phase-coherence model;
13. stateful delay model;
14. distributed local thermal model;
15. thermal coupling-feedback model;
16. correlated gamma-drift model;
17. nonlinear coherence-compression model;
18. operational coherence model;
19. destabilizing-load model;
20. dynamic-stability model;
21. phase-derived ternary-target model;
22. structured telemetry model;
23. fixed-point interface model;
24. balanced ternary hardware-encoding model;
25. stateful quantized hardware-shadow model;
26. cycle-exact integer golden-trace model;
27. deterministic RTL comparison-vector model;
28. SystemVerilog interface model;
29. synthesizable RTL reference-core mapping model;
30. assertion-correlation model;
31. reference-equivalence model;
32. qualification-closure model.

## 4. Complete Computational Model Chain

The current model chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric Sakaguchi phase lag gamma`

↓

`dyadic hierarchical fractal coupling`

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

`distributed local thermal field`

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

The resonant dynamic domain drives the evolving computation.

The balanced ternary domain provides the state, target, transition, and retained-result layer.

## 5. Floating Semantic Reference Model

Current processor representation:

`FractalResonanceProcessor`

This model implements the current processor semantics in floating numeric form.

It contains:

- ternary state execution;
- active-neutral routing;
- scheduler behavior;
- hierarchical resonant coupling;
- delay dynamics;
- distributed local thermal dynamics;
- local gamma dynamics;
- phase evolution;
- multiscale coherence;
- operational coherence;
- destabilizing load;
- dynamic stability;
- structured telemetry.

Engineering role:

`semantic source for current implementation mapping and correlation`

## 6. Balanced Ternary State Model

Current state and retained-result domain:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

Current state-domain marker:

`balanced_ternary_state_domain = True`

Current reserved-state invariant:

`reserved_state_events = 0`

## 7. Active-Neutral Transition Model

Opposite-polarity execution follows the mandatory routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Current route invariant:

`actual_direct_events = 0`

Current queue invariant:

`queue_overflow_events = 0`

The pending-route model retains:

- cell index;
- target polarity;
- earliest ready tick.

## 8. Distributed Commit Model

Current default transition fraction:

`0.25`

Current maximum-change relation:

`max_changes = max(1, round(cells × transition_fraction))`

Current validated request-lane profiles:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Current validated relation:

`switch_load_peak <= transition_fraction`

The distributed commit model bounds state changes per tick and couples transition activity into thermal and stability dynamics.

## 9. Scheduler Model

Current scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current scheduler phase push:

| Scheduler state | Phase push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all other scheduler states | `0.003` |

Current validated 16-tick profiles:

| Scheduler | Counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Current validated default 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

## 10. Cell Phase and Frequency-State Model

Each current processor cell maintains:

- phase;
- base frequency;
- target frequency;
- current frequency;
- local ternary state;
- local switching activity;
- local thermal state;
- local gamma state.

The cell state evolves through the connected resonant, delay, thermal, coherence, and ternary execution layers.

## 11. Kuramoto-Sakaguchi Resonant Interaction Model

Current floating interaction:

`sin(phase_j - phase_i - gamma_effective_i)`

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

The pair interaction combines:

- hierarchical coupling weight;
- thermal factor of cell `i`;
- thermal factor of cell `j`;
- effective local gamma;
- nominal coupling strength.

## 12. Asymmetric Local Gamma Model

The current processor tracks:

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

## 13. Dyadic Hierarchical Fractal Topology Model

The current architecture uses a dyadic hierarchical ultrametric topology.

Current default cell count:

`16`

Current default hierarchy depth:

`4`

Hierarchy depth:

`cells.bit_length() - 1`

Hierarchical distance between distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current default fractal exponent:

`fractal_alpha = 0.70`

Current exactness marker:

`fixed_point_topology_sum_exact = True`

## 14. Dense and Hierarchical Coupling Models

The current executable preserves two coupling representations:

- dense pair-interaction reference path;
- hierarchical accelerated coupling path.

Both representations preserve the same interaction subject:

`hierarchical weight`

×

`thermal pair factor`

×

`Kuramoto-Sakaguchi phase interaction`

×

`nominal coupling strength`

These representations support semantic correlation, topology verification, and implementation mapping.

## 15. Phase Velocity and Phase-Evolution Model

Current floating phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The phase field carries the combined effect of:

- delayed oscillator frequency;
- scheduler state;
- hierarchical resonant coupling;
- thermal node factors;
- effective local gamma.

## 16. Kuramoto Order-Parameter Model

Current global phase order:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable evaluates the same phase-order relation across hierarchical groups.

`R` is therefore the base phase-order metric for global and multiscale coherence evaluation.

## 17. Multiscale Phase-Coherence Model

The current hierarchy evaluates:

- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence.

Current outputs include:

- pair-domain coherence mean and minimum;
- cluster coherence mean and minimum;
- supercluster coherence mean and minimum;
- global phase coherence;
- coherence dispersion across clusters.

The model carries local, intermediate, and global phase-order evidence through one processor state.

## 18. Stateful Delay Model

Current frequency-target relation:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

Current delayed response:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Current default delay coefficient:

`delay_alpha = 0.30`

The remaining frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

## 19. Distributed Local Thermal Model

Each cell tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

Current generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current thermal dissipation relation:

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

Current exactness marker:

`fixed_point_thermal_sum_exact = True`

## 20. Thermal Coupling-Feedback Model

Current local thermal overload:

`max(0, local_heat - thermal_soft_limit)`

Current local thermal node factor:

`exp(-0.5 × thermal_coupling_gain × overload)`

Current thermal coupling gain:

`2.50`

The feedback chain is:

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

## 21. Nonlinear Coherence-Compression Model

Current stability soft margin:

`0.25`

Current margin pressure:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

Current compression relation:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Current effective coherence:

`effective_coherence = raw_phase_coherence × coherence_compression`

This model couples thermal pressure and stability-margin pressure back into effective phase coherence.

## 22. Operational Coherence Model

Current operational coherence:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current component map:

| Component | Coefficient |
|---|---:|
| base coherence term | `0.82` |
| effective coherence | `0.34` |
| cluster coherence mean | `0.16` |
| neutral-state fraction | `0.08` |
| mean frequency lag | `-0.10` |

The current coherence model connects resonant phase order, hierarchical coherence, active-neutral participation, and delayed frequency response.

## 23. Destabilizing-Load Model

Current relation:

`P = heat + switch_load`

Current switching load:

`switch_load = switched_nodes / total_nodes`

The load model combines:

- global mean thermal state;
- current-tick state-transition activity.

## 24. Dynamic-Stability Model

Current relation:

`C_minus_P = C - P`

Current validated condition:

`C_minus_P_min > 0.0`

The current M15 correlation layer also validates:

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

The stability model therefore exists in both floating semantic and deterministic fixed-point execution domains.

## 25. Phase-Derived Ternary-Target Model

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The cross-tick model is:

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

## 26. Structured Telemetry Model

Compact current execution records:

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

Current default sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

## 27. Fixed-Point Interface Model

Current M15 numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Current exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 28. Balanced Ternary Hardware-Encoding Model

Current two-bit encoding:

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

Current reserved-state invariant:

`reserved_state_events = 0`

## 29. Quantized Hardware-Shadow Model

Current processor representation:

`QuantizedReferenceShadowProcessor`

The quantized model preserves:

- balanced ternary state execution;
- active-neutral routing;
- pending neutral routes;
- scheduler behavior;
- transition-fraction control;
- hierarchical coupling;
- stateful delay dynamics;
- distributed local thermal dynamics;
- local gamma dynamics;
- phase evolution;
- multiscale coherence;
- global dynamic stability telemetry.

Engineering role:

`stateful finite-word reference for deterministic implementation correlation`

## 30. Cycle-Exact Integer Golden-Trace Model

Artifact layer:

`cycle_exact_reference_trace`

Current default trace length:

`64 ticks`

The trace preserves deterministic correlation fields for:

- scheduler state;
- packed ternary state;
- pending routes;
- phase;
- frequency;
- thermal state;
- gamma state;
- coherence;
- dynamic stability.

## 31. Deterministic RTL Comparison-Vector Model

Artifact layer:

`rtl_comparison_vector_package`

Current vector-package file count:

`10`

Current files:

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

Current deterministic qualification generates two independent packages and requires byte-identical equality.

## 32. SystemVerilog Interface and RTL Reference-Core Models

Current default interface parameters include:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The current RTL reference-core mapping covers:

- balanced ternary state execution;
- scheduler behavior;
- active-neutral routing;
- pending neutral routes;
- transition limits;
- fixed-point phase behavior;
- hierarchical coupling;
- thermal field behavior;
- multiscale phase coherence;
- deterministic reference comparison.

## 33. Assertion-Correlation Model

Artifact layer:

`rtl_assertion_correlation_harness`

Current assertion-correlation harness count:

`13`

Current exact integer comparison rule:

`actual integer field == expected integer field`

The assertion model binds current kernel invariants and cycle-exact reference fields to RTL-facing checks.

## 34. Reference-Equivalence Model

The current equivalence model has two correlation boundaries.

### 34.1 Floating semantic reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Current maximum error bounds:

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

### 34.2 Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 35. Qualification-Closure Model

FRP v1.7.0 defines ten current M15 artifact layers:

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

Current qualification result:

`PASS`

The closure chain is:

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

## 36. Current Scaling Model

Current validated M15 scaling profiles:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Each profile preserves:

`balanced_ternary_state_domain = True`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`scheduler_counts_valid = True`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 37. Current Verification Model

Current self-test result:

`41/41 PASS`

The current check registry covers:

- route qualification;
- scheduler qualification;
- request-lane order;
- balanced ternary encoding;
- fixed-point boundaries;
- exact topology closure;
- exact thermal closure;
- trigonometric lookup behavior;
- quantized-shadow invariants;
- semantic correlation;
- exact deterministic replay;
- vector determinism;
- 8-cell, 16-cell, and 32-cell scaling;
- qualification closure.

## 38. Current Five-Row M15 Benchmark Model

Current benchmark rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Current schema:

`frp.m3.benchmark_matrix.v1.7.0`

This matrix records the implementation progression from floating semantics through qualification closure.

## 39. Comparative Architecture Model Layer

Current comparative directory:

`../benchmarks/architecture_comparison/`

Current architecture set:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Current comparison chain:

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

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 40. Hardware-Sensitivity Model Layer

Current sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Current normalization:

`32-bit integer addition = 1.0`

Reference energy:

`0.1 pJ`

Technology context:

`45 nm CMOS`

Current scenario order:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Current ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

This layer applies one shared coefficient vector to every architecture inside each scenario.

## 41. Preliminary Kuramoto Background Model

File:

`kuramoto_frp_background_model.md`

This file preserves the preliminary nonlinear oscillator model that influenced the resonance-phase direction of the FRP project.

Its primary subjects are:

- oscillator phase interaction;
- external resonant driving;
- global phase-order development;
- convergence behavior.

Its early simplified relation is:

`dφ_i/dt = ω_i + (K/N) × Σ sin(φ_j - φ_i) + F_ext × sin(ω_ext × t - φ_i) + η`

Its historical global order parameter is:

`R = |(1/N) × Σ exp(i × φ_j)|`

The file remains a preliminary resonance-phase background record.

The current FRP model extends that background through asymmetric Sakaguchi phase lag, balanced ternary state retention, hierarchical fractal coupling, delay, distributed thermal dynamics, gamma drift, multiscale coherence, dynamic stability, fixed-point mapping, and qualification closure.

## 42. Historical v0.9.3 Transition Model Contour

Historical evidence source:

`../TEST_REPORT_v0_9_3.md`

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

## 43. Archived Ternary-to-Binary Thermal Model Result

The historical transition benchmark records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Under the historical v0.9.3 transition benchmark model and workload:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent relative reduction:

`93.63% lower heat_peak`

The same archived result records:

`distributed_neutral_ternary actual_direct_events = 0`

`binary_style_forced_switch actual_direct_events = 2052`

`distributed_neutral_ternary switch_load_peak = 0.25`

`binary_style_forced_switch switch_load_peak = 1.0`

The archived benchmark preserves direct evidence for the distributed-neutral ternary transition model inside that release-specific workload and metric domain.

## 44. Historical and Current Model Contours

The model layer preserves four distinct contours.

### Preliminary Kuramoto contour

Measured subject:

`oscillator phase interaction, external resonant driving, phase order, and convergence`

Primary file:

`kuramoto_frp_background_model.md`

### Historical v0.9.3 transition contour

Measured subject:

`route activity, switching load, historical heat_peak, and historical dynamic stability`

Primary evidence:

`../TEST_REPORT_v0_9_3.md`

### Current FRP v1.7.0 semantic model contour

Measured subject:

`resonant phase dynamics, hierarchical coherence, delay, distributed thermal state, gamma drift, ternary routing, and C(t) - P(t)`

Primary executable:

`../frp_prototype_v1_7_0.py`

### Current M15 implementation-mapping contour

Measured subject:

`fixed-point mapping, quantized execution, cycle-exact traces, RTL vectors, interface mapping, equivalence, and qualification closure`

Primary architecture document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Each contour retains its release-specific model identity, metric definitions, and evidence records.

## 45. Model Evidence Registry

| Model subject | Primary evidence source |
|---|---|
| current processor semantics | `frp_prototype_v1_7_0.py` |
| current fixed-point domains | `fixed_point_interface_profile` |
| current ternary encoding | `balanced_ternary_hardware_encoding_map` |
| current quantized execution | `quantized_reference_shadow_model` |
| current cycle-exact state | `cycle_exact_reference_trace` |
| current deterministic replay package | `rtl_comparison_vector_package` |
| current interface mapping | `systemverilog_testbench_interface_map` |
| current RTL mapping | `synthesizable_rtl_reference_core` |
| current assertion correlation | `rtl_assertion_correlation_harness` |
| current semantic and replay correlation | `reference_rtl_equivalence_report` |
| current final qualification | `qualification_closure_manifest` |
| preliminary resonance-phase background | `kuramoto_frp_background_model.md` |
| historical transition benchmark | `TEST_REPORT_v0_9_3.md` |

## 46. Current GitHub Actions Validation Context

Current repository workflow count:

`19`

Current root README active passing badge count:

`18`

Current primary M15 workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current environment:

`ubuntu-latest`

Current Python version:

`3.12`

Current M15 workflow stages:

1. checkout repository;
2. set up Python;
3. compile the FRP v1.7.0 reference file;
4. generate M15 qualification outputs;
5. compare deterministic vector packages;
6. validate M15 schemas, kernel invariants, fixed-point contract, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture document contract;
9. upload M15 qualification artifacts.

## 47. Current Release Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current validation environment:

`GitHub Actions hardware-backed CI execution`

Validated release commit:

`5fd9a4f`

Recorded workflow stack:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Current overall published result:

`PASS`

## 48. Current File Alignment

This model layer is aligned with:

- `../README.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`;
- `../CI.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../CONTRIBUTING.md`;
- `../docs/README.md`;
- `../docs/core_principles.md`;
- `../docs/resonance_computation.md`;
- `../docs/architecture.md`;
- `../docs/implementation_layers.md`;
- `../docs/benchmark_interpretation.md`;
- `../docs/limitations.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../simulations/README.md`;
- `../examples/README.md`;
- `../examples/resonance_convergence_example.md`;
- `../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Historical transition evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

Preliminary resonance-phase background remains preserved in:

- `./kuramoto_frp_background_model.md`.

## 49. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current model chain:

`balanced ternary state → active-neutral routing → Kuramoto-Sakaguchi resonant phase dynamics → hierarchical fractal coupling → phase evolution → Kuramoto order parameter R → multiscale phase coherence → stateful delay dynamics → distributed local thermal dynamics → correlated gamma drift → nonlinear coherence compression → C(t) → P(t) → C(t) - P(t) → phase-derived ternary targets → distributed commit → retained coherent ternary state → fixed-point mapping → quantized hardware shadow → cycle-exact trace → RTL comparison vectors → SystemVerilog mapping → RTL reference-core mapping → equivalence → qualification closure`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current self-test result:

`41/41 PASS`

Current qualification closure result:

`PASS`

Current published validation result:

`PASS`

Historical archived ternary-to-binary thermal result:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch under the historical v0.9.3 transition benchmark model`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 13. Dyadic Hierarchical Fractal Topology Model

The current architecture uses a dyadic hierarchical ultrametric topology.

Current default cell count:

`16`

Current default hierarchy depth:

`4`

Hierarchy depth:

`cells.bit_length() - 1`

Hierarchical distance between distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current default fractal exponent:

`fractal_alpha = 0.70`

Current exactness marker:

`fixed_point_topology_sum_exact = True`

## 14. Dense and Hierarchical Coupling Models

The current executable preserves two coupling representations:

- dense pair-interaction reference path;
- hierarchical accelerated coupling path.

Both representations preserve the same interaction subject:

`hierarchical weight`

×

`thermal pair factor`

×

`Kuramoto-Sakaguchi phase interaction`

×

`nominal coupling strength`

These representations support semantic correlation, topology verification, and implementation mapping.

## 15. Phase Velocity and Phase-Evolution Model

Current floating phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The phase field carries the combined effect of:

- delayed oscillator frequency;
- scheduler state;
- hierarchical resonant coupling;
- thermal node factors;
- effective local gamma.

## 16. Kuramoto Order-Parameter Model

Current global phase order:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable evaluates the same phase-order relation across hierarchical groups.

`R` is therefore the base phase-order metric for global and multiscale coherence evaluation.

## 17. Multiscale Phase-Coherence Model

The current hierarchy evaluates:

- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence.

Current outputs include:

- pair-domain coherence mean and minimum;
- cluster coherence mean and minimum;
- supercluster coherence mean and minimum;
- global phase coherence;
- coherence dispersion across clusters.

The model carries local, intermediate, and global phase-order evidence through one processor state.

## 18. Stateful Delay Model

Current frequency-target relation:

`frequency_target = base_frequency + 0.06 × abs(state) + 0.12 × switch_activity`

Current delayed response:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Current default delay coefficient:

`delay_alpha = 0.30`

The remaining frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

## 19. Distributed Local Thermal Model

Each cell tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

Current generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current thermal dissipation relation:

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

Current exactness marker:

`fixed_point_thermal_sum_exact = True`

## 20. Thermal Coupling-Feedback Model

Current local thermal overload:

`max(0, local_heat - thermal_soft_limit)`

Current local thermal node factor:

`exp(-0.5 × thermal_coupling_gain × overload)`

Current thermal coupling gain:

`2.50`

The feedback chain is:

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

## 21. Nonlinear Coherence-Compression Model

Current stability soft margin:

`0.25`

Current margin pressure:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

Current compression relation:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Current effective coherence:

`effective_coherence = raw_phase_coherence × coherence_compression`

This model couples thermal pressure and stability-margin pressure back into effective phase coherence.

## 22. Operational Coherence Model

Current operational coherence:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current component map:

| Component | Coefficient |
|---|---:|
| base coherence term | `0.82` |
| effective coherence | `0.34` |
| cluster coherence mean | `0.16` |
| neutral-state fraction | `0.08` |
| mean frequency lag | `-0.10` |

The current coherence model connects resonant phase order, hierarchical coherence, active-neutral participation, and delayed frequency response.

## 23. Destabilizing-Load Model

Current relation:

`P = heat + switch_load`

Current switching load:

`switch_load = switched_nodes / total_nodes`

The load model combines:

- global mean thermal state;
- current-tick state-transition activity.

## 24. Dynamic-Stability Model

Current relation:

`C_minus_P = C - P`

Current validated condition:

`C_minus_P_min > 0.0`

The current M15 correlation layer also validates:

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

The stability model therefore exists in both floating semantic and deterministic fixed-point execution domains.

## 25. Phase-Derived Ternary-Target Model

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The cross-tick model is:

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

## 26. Structured Telemetry Model

Compact current execution records:

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

Current default sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

## 27. M15 Fixed-Point Interface Model

Current M15 numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Current exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 28. M15 Balanced Ternary Hardware-Encoding Model

Current two-bit encoding:

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

Current reserved-state invariant:

`reserved_state_events = 0`

## 29. M15 Quantized Hardware-Shadow Model

Current processor representation:

`QuantizedReferenceShadowProcessor`

The quantized model preserves:

- balanced ternary state execution;
- active-neutral routing;
- pending neutral routes;
- scheduler behavior;
- transition-fraction control;
- hierarchical coupling;
- stateful delay dynamics;
- distributed local thermal dynamics;
- local gamma dynamics;
- phase evolution;
- multiscale coherence;
- global dynamic stability telemetry.

Engineering role:

`stateful finite-word reference for deterministic implementation correlation`

## 30. M15 Cycle-Exact Integer Golden-Trace Model

Artifact layer:

`cycle_exact_reference_trace`

Current default trace length:

`64 ticks`

The trace preserves deterministic correlation fields for:

- scheduler state;
- packed ternary state;
- pending routes;
- phase;
- frequency;
- thermal state;
- gamma state;
- coherence;
- dynamic stability.

## 31. M15 Deterministic RTL Comparison-Vector Model

Artifact layer:

`rtl_comparison_vector_package`

Current vector-package file count:

`10`

Current files:

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

Current deterministic qualification generates two independent packages and requires byte-identical equality.

## 32. M15 SystemVerilog Interface and RTL Reference-Core Mapping Models

Current default interface parameters include:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The current RTL reference-core mapping covers:

- balanced ternary state execution;
- scheduler behavior;
- active-neutral routing;
- pending neutral routes;
- transition limits;
- fixed-point phase behavior;
- hierarchical coupling;
- thermal field behavior;
- multiscale phase coherence;
- deterministic reference comparison.

## 33. M15 Assertion-Correlation Model

Artifact layer:

`rtl_assertion_correlation_harness`

Current assertion-correlation harness count:

`13`

Current exact integer comparison rule:

`actual integer field == expected integer field`

The assertion model binds current kernel invariants and cycle-exact reference fields to RTL-facing checks.

## 34. M15 Reference-Equivalence Model

The current equivalence model has two correlation boundaries.

### 34.1 Floating semantic reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Current maximum error bounds:

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

### 34.2 Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 35. M15 Qualification-Closure Model

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

Current qualification result:

`PASS`

The closure chain is:

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

## 36. M16 RTL Execution-Boundary Model

The M16 SystemVerilog layer implements the retained balanced ternary execution boundary of FRP.

The retained processor-state domain is:

`{-1, 0, 1}`

The M16 boundary receives:

- phase-derived packed ternary targets;
- explicit request-valid lanes;
- requested cell indexes;
- requested ternary targets;
- scheduler mode;
- tick enable;
- counter clear;
- clock and reset.

The M16 execution chain is:

`phase-derived ternary target`

→ `temporal scheduler state`

→ `pending-route completion priority`

→ `deterministic request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `distributed transition-capacity guard`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry and invariants`

The boundary exposes:

- retained balanced ternary state;
- retained pending-route state;
- scheduler state and counters;
- request acceptance and rejection;
- accepted-cell, neutral-routed-cell, and accepted-change masks;
- accepted-change count, remaining capacity, capacity exhaustion, and switch-load numerator;
- requested, prevented, neutral-routed, actual-direct, reserved-state, and queue-overflow event counts;
- ten integrated invariant flags.

M15 remains the qualified semantic and implementation-mapping foundation of the M16 execution layer and provides the phase-derived target, fixed-point mapping, cycle-exact traces, and deterministic comparison vectors inherited by M16.

## 37. M16 SystemVerilog Module Model

The closed M16 RTL boundary contains ten SystemVerilog files:

| File | Module role |
|---|---|
| `../rtl/m16/frp_m16_pkg.sv` | canonical encodings, scheduler states, transition classes, invariant indexes, and shared functions |
| `../rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution and scheduler counters |
| `../rtl/m16/frp_m16_request_lanes.sv` | deterministic request arbitration and pending-cell ownership |
| `../rtl/m16/frp_m16_pending_routes.sv` | retained opposite-polarity target storage and completion clearing |
| `../rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition-candidate generation |
| `../rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `../rtl/m16/frp_m16_state_update.sv` | capacity-approved retained-state writeback |
| `../rtl/m16/frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `../rtl/m16/frp_m16_assertions.sv` | temporal, domain, routing, capacity, and writeback assertions |
| `../rtl/m16/frp_m16_tb.sv` | deterministic executable architecture testbench |

The integrated hierarchy is rooted at:

`frp_m16_core`

The executable RTL qualification top is:

`frp_m16_tb`

The RTL documentation boundary contains:

- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`.

## 38. M16 Scheduler, Request-Lane, and Capacity Models

M16 implements three temporal scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Recorded scheduler relations:

| Mode | Executed relation |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `16 ticks → balance = 14, commit = 2` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Scheduler counter relation:

`sum(scheduler_counts) = ticks_recorded`

The request-lane arbitration order is:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

For each enabled tick:

1. retained pending-route completion has priority for its cell;
2. valid explicit request lanes are evaluated in ascending lane order;
3. an earlier accepted lane owns its cell for that tick;
4. one cell receives at most one explicit request acceptance per tick;
5. invalid, duplicate-cell, pending-owned, and capacity-deferred requests are rejected or deferred according to the RTL interface.

The transition-capacity relation is:

`max_changes = max(1, round(CELLS × transition_fraction))`

For the current M16 RTL profile:

`transition_fraction = 0.25`

`REQUEST_LANES = max_changes`

Capacity telemetry relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load = switch_load_numerator / CELLS`

Each state-changing leg of an opposite-polarity route consumes capacity on its own eligible tick.

## 39. M16 Active-Neutral, Pending-Route, and Retained-State Models

Direct opposite-polarity retained-state transitions are forbidden:

`-1 → +1`

`+1 → -1`

The implemented tick-separated routes are:

`-1 → 0 → +1`

`+1 → 0 → -1`

For:

`state_i × target_i = -1`

the first eligible neutralize-capable tick performs:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick performs:

`0 → pending_route_i`

Each cell contains one retained pending-route slot.

A retained pending route:

- owns its cell until completion;
- has priority over a new request for the same cell;
- retains its polarity across scheduler-ineligible ticks and capacity deferral;
- completes only from retained state `0`;
- clears only after the corresponding `0 → pending polarity` state writeback;
- cannot be overwritten by another route.

The retained-state register commits only transition candidates admitted by the transition-capacity guard.

The state produced by tick `N` is the retained input state of tick `N + 1`.

Required zero-event relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## 40. M16 Integrated Invariant and Assertion Model

The M16 core exposes ten integrated invariant flags:

| Invariant | Recorded relation |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | retained state, target, candidate, and pending-route values remain in the canonical ternary domain |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | scheduler states and counters correspond to executed ticks |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | request arbitration preserves ascending lane order and one accepted request per cell |
| `FRP_INV_PENDING_POLARITY_VALID` | pending polarity remains retained until eligible completion |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | every opposite-polarity transition is separated through active neutral `0` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | committed state changes remain inside the per-tick transition boundary |
| `FRP_INV_STATE_UPDATE_VALID` | retained-state writeback matches admitted transition candidates |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | no direct opposite-polarity transition reaches retained state |
| `FRP_INV_NO_RESERVED_STATE` | reserved ternary encoding never reaches the retained processor boundary |
| `FRP_INV_NO_QUEUE_OVERFLOW` | retained pending-route storage is never overwritten |

The assertion layer checks:

- canonical ternary state and pending-route encodings;
- reset to active neutral state `0`;
- retained-state and pending-route stability while ticks are disabled;
- state changes only through accepted-change masks;
- absence of direct opposite-polarity writeback;
- first-leg routing to active neutral `0`;
- retention of the exact opposite pending polarity;
- completion only from active neutral `0`;
- pending-route stability during deferral;
- scheduler mode, scheduler state, and counter relations;
- request acceptance and rejection separation;
- transition-capacity and switch-load relations;
- zero direct, reserved-state, and queue-overflow events;
- all ten integrated invariant flags.

## 41. M16 RTL Executable Qualification Model

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Trigger:

`workflow_dispatch`

The workflow qualifies:

- Verilator SystemVerilog parsing;
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
- repository-integrity validation;
- qualification artifact generation.

Testbench configuration:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Validated terminal output:

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

Qualification records:

| Record | Run | Commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

## 42. M16 FPGA Preparation Model

The M16 FPGA preparation layer is a target-independent FPGA integration boundary for the qualified M16 RTL core.

FPGA preparation artifacts:

| File | Role |
|---|---|
| `../fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration and synthesis boundary |
| `../fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA integration qualification boundary |
| `../fpga/m16/SIMULATION_TRANSCRIPT.md` | FPGA preparation qualification transcript |
| `../fpga/m16/CLOSURE.md` | FPGA preparation closure record |

External reset input:

`rst_n_async`

Internal core reset:

`rst_n_core`

Reset synchronizer:

`2 stages`

Reset assertion is asynchronous.

Reset release is synchronized to the FPGA clock domain across two rising clock edges.

Readiness relation:

`core_ready = rst_n_core`

Execution-input gating relations:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

The executable FPGA integration qualification covers:

- FPGA integration-top elaboration;
- executable FPGA testbench generation and execution;
- asynchronous reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg routing;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- all ten integrated invariant flags;
- zero-event counters;
- repository-integrity validation;
- qualification evidence generation.

Validated terminal output:

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

Qualification records:

| Record | Run | Commit | Branch | Result | Duration | Artifact count | Status |
|---|---:|---|---|---|---|---:|---|
| initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1m 7s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `36s` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

## 43. M15 Qualified Scaling Model

Current validated M15 scaling profiles:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Each profile preserves:

`balanced_ternary_state_domain = True`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`scheduler_counts_valid = True`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 44. M15 Verification Foundation

Qualified M15 self-test result:

`41/41 PASS`

The M15 check registry covers:

- route qualification;
- scheduler qualification;
- request-lane order;
- balanced ternary encoding;
- fixed-point boundaries;
- exact topology closure;
- exact thermal closure;
- trigonometric lookup behavior;
- quantized-shadow invariants;
- semantic correlation;
- exact deterministic replay;
- vector determinism;
- 8-cell, 16-cell, and 32-cell scaling;
- qualification closure.

## 45. M15 Five-Row Benchmark Model

M15 benchmark rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Current schema:

`frp.m3.benchmark_matrix.v1.7.0`

This matrix records the implementation progression from floating semantics through qualification closure.

## 46. Comparative Architecture Model Layer

Current comparative directory:

`../benchmarks/architecture_comparison/`

Current architecture set:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Current comparison chain:

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

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 47. Hardware-Sensitivity Model Layer

Current sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Current normalization:

`32-bit integer addition = 1.0`

Reference energy:

`0.1 pJ`

Technology context:

`45 nm CMOS`

Current scenario order:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Current ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

This layer applies one shared coefficient vector to every architecture inside each scenario.

## 48. Preliminary Kuramoto Background Model

File:

`kuramoto_frp_background_model.md`

This file preserves the preliminary nonlinear oscillator model that influenced the resonance-phase direction of the FRP project.

Its primary subjects are:

- oscillator phase interaction;
- external resonant driving;
- global phase-order development;
- convergence behavior.

Its early simplified relation is:

`dφ_i/dt = ω_i + (K/N) × Σ sin(φ_j - φ_i) + F_ext × sin(ω_ext × t - φ_i) + η`

Its historical global order parameter is:

`R = |(1/N) × Σ exp(i × φ_j)|`

The file remains a preliminary resonance-phase background record.

The current FRP model extends that background through asymmetric Sakaguchi phase lag, balanced ternary state retention, hierarchical fractal coupling, delay, distributed thermal dynamics, gamma drift, multiscale coherence, dynamic stability, fixed-point mapping, and qualification closure.

## 49. Historical v0.9.3 Transition Model Contour

Historical evidence source:

`../TEST_REPORT_v0_9_3.md`

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

## 50. Archived Ternary-to-Binary Thermal Model Result

The historical transition benchmark records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Under the historical v0.9.3 transition benchmark model and workload:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent relative reduction:

`93.63% lower heat_peak`

The same archived result records:

`distributed_neutral_ternary actual_direct_events = 0`

`binary_style_forced_switch actual_direct_events = 2052`

`distributed_neutral_ternary switch_load_peak = 0.25`

`binary_style_forced_switch switch_load_peak = 1.0`

The archived benchmark preserves direct evidence for the distributed-neutral ternary transition model inside that release-specific workload and metric domain.

## 51. Historical and Current Model Contours

The model layer preserves six distinct contours.

### Preliminary Kuramoto contour

Measured subject:

`oscillator phase interaction, external resonant driving, phase order, and convergence`

Primary file:

`kuramoto_frp_background_model.md`

### Historical v0.9.3 transition contour

Measured subject:

`route activity, switching load, historical heat_peak, and historical dynamic stability`

Primary evidence:

`../TEST_REPORT_v0_9_3.md`

### M15-qualified FRP v1.7.0 semantic model contour

Measured subject:

`resonant phase dynamics, hierarchical coherence, delay, distributed thermal state, gamma drift, ternary routing, and C(t) - P(t)`

Primary executable:

`../frp_prototype_v1_7_0.py`

### M15 implementation-mapping contour

Measured subject:

`fixed-point mapping, quantized execution, cycle-exact traces, RTL vectors, interface mapping, equivalence, and qualification closure`

Primary architecture document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

### Current M16 RTL execution contour

Qualified subject:

`SystemVerilog scheduler execution, request-lane arbitration, active-neutral routing, pending-route retention and completion, transition-capacity enforcement, retained-state writeback, telemetry, assertions, and ten integrated invariants`

Primary source boundary:

`../rtl/m16/`

Primary qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

### Current M16 FPGA preparation contour

Qualified subject:

`target-independent FPGA integration top, asynchronous reset assertion, two-stage synchronous reset release, core_ready, execution-input gating, scheduler and request propagation, active-neutral routing, pending-route completion, telemetry, and ten integrated invariants`

Primary source boundary:

`../fpga/m16/`

Primary qualification workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Each contour retains its release-specific model identity, metric definitions, and evidence records.

## 52. Model Evidence Registry

| Model subject | Primary evidence source |
|---|---|
| M15-qualified executable processor semantics | `../frp_prototype_v1_7_0.py` |
| M15 fixed-point domains | `fixed_point_interface_profile` |
| M15 ternary encoding | `balanced_ternary_hardware_encoding_map` |
| M15 quantized execution | `quantized_reference_shadow_model` |
| M15 cycle-exact state | `cycle_exact_reference_trace` |
| M15 deterministic replay package | `rtl_comparison_vector_package` |
| M15 interface mapping | `systemverilog_testbench_interface_map` |
| M15 RTL mapping | `synthesizable_rtl_reference_core` |
| M15 assertion correlation | `rtl_assertion_correlation_harness` |
| M15 semantic and replay correlation | `reference_rtl_equivalence_report` |
| M15 qualification closure | `qualification_closure_manifest` |
| M16 RTL execution source | `../rtl/m16/` |
| M16 RTL architecture record | `../rtl/m16/README.md` |
| M16 RTL simulation record | `../rtl/m16/SIMULATION_TRANSCRIPT.md` |
| M16 RTL closure record | `../rtl/m16/CLOSURE.md` |
| M16 FPGA integration source | `../fpga/m16/` |
| M16 FPGA simulation record | `../fpga/m16/SIMULATION_TRANSCRIPT.md` |
| M16 FPGA closure record | `../fpga/m16/CLOSURE.md` |
| mathematical foundation | `../docs/mathematical_foundation.md` |
| physical foundation | `../docs/physical_foundation.md` |
| preliminary resonance-phase background | `kuramoto_frp_background_model.md` |
| historical transition benchmark | `../TEST_REPORT_v0_9_3.md` |

## 53. Current GitHub Actions Validation Context

Current repository workflow count:

`23`

Current `CI.md` workflow badge count:

`23`

Current root README linked architecture image count:

`1`

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Current M16 repository-maintenance workflows:

- `../.github/workflows/frp-m16-canonical-core-domain.yml`;
- `../.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

Current environment:

`ubuntu-latest`

Current Python version:

`3.12`

Inherited M15 workflow stages:

1. checkout repository;
2. set up Python;
3. compile the FRP v1.7.0 reference file;
4. generate M15 qualification outputs;
5. compare deterministic vector packages;
6. validate M15 schemas, kernel invariants, fixed-point contract, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture document contract;
9. upload M15 qualification artifacts.

The M16 RTL workflow executes SystemVerilog parsing, module elaboration, executable testbench generation, architectural simulation, assertion execution, diagnostic rejection, architectural relation validation, repository-integrity validation, and qualification artifact generation.

The M16 FPGA workflow executes FPGA integration-top elaboration, executable FPGA testbench generation and execution, reset synchronization validation, `core_ready` validation, execution-input gating validation, scheduler and request propagation, active-neutral route execution, pending-route completion, invariant validation, repository-integrity validation, and qualification artifact generation.

## 54. Current Release Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Current validation environment:

`GitHub Actions ubuntu-latest execution with Python 3.12 and Verilator`

Inherited M15 validated release commit:

`5fd9a4f`

Inherited M15 workflow stack:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Current M16 qualification records:

| Layer | Workflow run | Qualified commit | Branch | Result | Closure status |
|---|---:|---|---|---|---|
| RTL execution initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| RTL execution qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| FPGA preparation initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |
| FPGA preparation qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |

Current overall published result:

`FRP v1.8.0 / M16 — PASS`

## 55. Current File Alignment

This model layer is aligned with:

- `../README.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../CI.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../CONTRIBUTING.md`;
- `../docs/README.md`;
- `../docs/core_principles.md`;
- `../docs/resonance_computation.md`;
- `../docs/architecture.md`;
- `../docs/implementation_layers.md`;
- `../docs/mathematical_foundation.md`;
- `../docs/physical_foundation.md`;
- `../docs/benchmark_interpretation.md`;
- `../docs/limitations.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../simulations/README.md`;
- `../examples/README.md`;
- `../examples/resonance_convergence_example.md`.

The inherited M15 semantic and implementation-mapping foundation remains aligned with:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`;
- `../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

The M16 RTL execution model remains aligned with:

- `../docs/m16_rtl_core_realization_execution_semantics.md`;
- `../docs/m16_rtl_core_interface_contract.md`;
- `../docs/m16_qualification_index.md`;
- `../docs/m16_qualification_manifest.md`;
- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`.

The M16 FPGA preparation model remains aligned with:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Historical transition evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

Preliminary resonance-phase background remains preserved in:

- `./kuramoto_frp_background_model.md`.

## 56. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current model chain:

`balanced ternary state → active-neutral routing → Kuramoto-Sakaguchi resonant phase dynamics → hierarchical fractal coupling → phase evolution → Kuramoto order parameter R → multiscale phase coherence → stateful delay dynamics → distributed local thermal dynamics → correlated gamma drift → nonlinear coherence compression → C(t) → P(t) → C(t) - P(t) → phase-derived ternary targets → distributed commit → retained coherent ternary state → M15 fixed-point mapping → M15 quantized hardware shadow → M15 cycle-exact trace → M15 RTL comparison vectors → M15 SystemVerilog interface mapping → M15 RTL reference-core mapping → M15 equivalence and qualification closure → M16 temporal scheduler → M16 pending-route completion priority → M16 request-lane arbitration → M16 active-neutral transition generation → M16 transition-capacity guard → M16 retained-state writeback → M16 integrated invariants → M16 target-independent FPGA reset, readiness, and execution-input gating`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 self-test result:

`41/41 PASS`

Inherited M15 deterministic vector result:

`10/10 deterministic vector files byte-identical`

Inherited M15 semantic correlation result:

`5/5 required semantic correlation matches = 1.0`

Inherited M15 deterministic replay result:

`6/6 deterministic replay matches = 1.0`

Current M16 RTL qualification record:

| Field | Value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification record:

| Field | Value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current zero-event relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current fixed-point exactness relations:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

Current qualification result:

`PASS`

Current published validation result:

`FRP v1.8.0 / M16 — PASS`

Historical archived ternary-to-binary thermal result:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch under the historical v0.9.3 transition benchmark model`

Current M16 closure states:

`M16 RTL EXECUTION LAYER CLOSED`

`M16 FPGA PREPARATION LAYER CLOSED`






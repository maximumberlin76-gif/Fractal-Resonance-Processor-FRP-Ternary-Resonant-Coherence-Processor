# Coherence Metrics — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the current phase-coherence, multiscale-coherence, compression, thermal-load, switching-load, and dynamic-stability metrics used by the Fractal Resonance Processor (FRP).

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

Inherited M15 semantic and implementation-mapping document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 architecture document:

`../docs/m16_rtl_core_realization_execution_semantics.md`

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

Current validated M15 self-test result:

`41/41 PASS`

Current M16 RTL qualification result:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation qualification result:

`M16 FPGA PREPARATION LAYER CLOSED`

## 1. Purpose

The coherence-metrics layer measures the dynamic state that connects resonant phase evolution to retained balanced ternary computation.

The current metric chain is:

`phase state`

↓

`Kuramoto order parameter R`

↓

`pair-domain phase coherence`

↓

`cluster phase coherence`

↓

`supercluster phase coherence`

↓

`global phase coherence`

↓

`thermal-overload pressure`

↓

`stability-margin pressure`

↓

`nonlinear coherence compression`

↓

`effective coherence`

↓

`operational coherence C(t)`

↓

`destabilizing load P(t)`

↓

`dynamic stability C(t) - P(t)`

The current metrics also preserve traceability to:

- frequency lag;
- neutral-state fraction;
- switching load;
- local thermal state;
- active-neutral routing;
- deterministic fixed-point representation;
- semantic correlation;
- exact quantized replay;
- M16 scheduler and request-interface propagation;
- M16 active-neutral route execution;
- M16 retained pending-route completion;
- M16 transition-capacity and retained-state results;
- M16 invariant flags and zero-event counters.

## 2. Current Stability Condition

The current operational stability relation is:

`C(t) > P(t)`

Current symbols:

| Symbol | Current meaning |
|---|---|
| `C(t)` | operational coherence assembled from effective coherence, cluster coherence, neutral-state fraction, and frequency lag |
| `P(t)` | destabilizing load assembled from global heat and switching load |
| `C_minus_P` | dynamic-stability margin `C(t) - P(t)` |

Current destabilizing-load relation:

`P(t) = heat + switch_load`

Current validated condition:

`C_minus_P_min > 0.0`

The qualified M15 workflow checks this condition directly in the structured execution summary and the quantized hardware-shadow summary.

## 3. Metric Architecture

The current coherence metric architecture has five connected levels:

1. raw global phase order;
2. hierarchical multiscale phase coherence;
3. nonlinear coherence compression;
4. operational coherence `C(t)`;
5. dynamic-stability margin `C(t) - P(t)`.

The complete relation is:

`raw phase coherence`

+

`cluster coherence`

+

`neutral-state contribution`

−

`frequency-lag contribution`

with:

`thermal-overload pressure`

and:

`stability-margin pressure`

acting through the coherence-compression path.

## 4. Kuramoto Order Parameter R

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable evaluates this relation through:

`phase_order(phases)`

The same phase-order relation is applied to hierarchical cell groups.

The `R` domain therefore provides:

- global phase order;
- local pair-domain order;
- cluster-domain order;
- supercluster-domain order;
- global hierarchical order.

The current processor uses phase order as a dynamic computational metric inside a larger coherence and stability chain.

## 5. Raw Phase Coherence

After the phase field evolves, the current floating semantic reference calculates:

`raw_phase_coherence = phase_order(phases)`

The phase field already contains the current influence of:

- delayed oscillator frequency;
- scheduler push;
- hierarchical Kuramoto-Sakaguchi coupling;
- local thermal coupling factors;
- effective local gamma.

The raw phase-coherence path is therefore:

`frequency state`

+

`scheduler state`

+

`hierarchical coupling field`

+

`local gamma state`

+

`thermal coupling state`

↓

`phase velocity`

↓

`phase evolution`

↓

`raw phase coherence`

## 6. Phase Interaction Behind the Coherence Metrics

The current floating phase interaction uses:

`sin(phase_j - phase_i - gamma_effective_i)`

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The coherence metrics therefore measure the evolving result of asymmetric resonant phase interaction across the hierarchical processor topology.

## 7. Hierarchical Multiscale Phase Coherence

The current architecture uses a dyadic hierarchical ultrametric topology.

For each hierarchy level:

`group_size = 2^level`

The current executable calculates the phase order of every group at that level.

For each level it records:

- group phase-coherence values;
- level mean phase coherence;
- level minimum phase coherence;
- level maximum phase coherence;
- level coherence dispersion.

The current named coherence domains are:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

## 8. Pair-Domain Coherence

The pair domain is the first hierarchy level.

Current floating metrics:

`pair_domain_coherence_mean`

`pair_domain_coherence_min`

Current quantized representation:

`pair_domain_coherence_mean_q30`

`pair_domain_coherence_min_q30`

The pair domain captures the smallest validated hierarchical phase-order scale.

## 9. Cluster Coherence

The cluster domain is the current second hierarchy level for the standard 16-cell profile.

Current floating metrics:

`cluster_coherence_mean`

`cluster_coherence_min`

Current quantized representation:

`cluster_coherence_mean_q30`

`cluster_coherence_min_q30`

The current operational coherence formula uses:

`cluster_coherence_mean`

with coefficient:

`0.16`

## 10. Supercluster Coherence

Current floating metrics:

`supercluster_coherence_mean`

`supercluster_coherence_min`

Current quantized representation:

`supercluster_coherence_mean_q30`

`supercluster_coherence_min_q30`

This domain exposes intermediate large-scale phase order between the cluster and global domains.

## 11. Global Phase Coherence

Current floating metric:

`global_phase_coherence`

Current quantized trace metric:

`global_phase_coherence_q30`

The global hierarchical level evaluates the phase order across the full processor state.

The current M15 cycle-exact trace exports:

`global_phase_coherence_q30`

for every processor tick.

## 12. Coherence Dispersion Across Clusters

Current floating metric:

`coherence_dispersion_across_clusters`

Current quantized metric:

`coherence_dispersion_across_clusters_q30`

The metric is derived from the cluster-level phase-coherence distribution.

It records the spread of cluster coherence around the cluster-level mean and exposes spatial coherence asymmetry across the processor hierarchy.

## 13. Thermal-Overload Pressure

Current local thermal overload is:

`max(0, local_heat - thermal_soft_limit)`

Current default thermal soft limit:

`0.22`

The current coherence-compression path uses the mean local thermal overload:

`thermal_overload_mean = mean(local thermal overload)`

Current thermal compression gain:

`3.0`

Thermal pressure enters coherence compression quadratically.

## 14. Stability-Margin Pressure

Current stability soft margin:

`0.25`

Current margin pressure:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

Current margin-compression gain:

`1.5`

The current processor therefore increases coherence compression as the previous dynamic-stability margin approaches the soft-margin region.

## 15. Nonlinear Coherence Compression

Current floating relation:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Current quantized relation uses:

- Q16 thermal-overload mean;
- Q16 margin pressure;
- Q16 squared pressure terms;
- deterministic fixed-point multiplication;
- `exp_neg_q30`.

Current quantized output:

`coherence_compression_q30`

The compression factor links local thermal pressure and global stability-margin pressure to effective phase coherence.

## 16. Effective Coherence

Current floating relation:

`effective_coherence = raw_phase_coherence × coherence_compression`

Current quantized relation:

`effective_coherence_q30 = raw_phase_coherence_q30 × coherence_compression_q30`

The effective-coherence layer is the direct phase-coherence input to the current operational coherence formula.

## 17. Neutral-State Fraction

Current neutral fraction:

`neutral_fraction = states.count(0) / cells`

Current contribution to `C(t)`:

`+ 0.08 × neutral_fraction`

The active neutral state contributes to:

- balancing;
- damping;
- transition routing;
- conflict neutralization;
- retained-route completion;
- switching-load control.

Its positive coefficient in `C(t)` reflects the current processor architecture.

## 18. Mean Frequency Lag

Current per-cell frequency lag:

`abs(frequency_target_i - frequency_i)`

Current mean frequency lag:

`mean_frequency_lag = mean(abs(frequency_target - frequency))`

Current contribution to `C(t)`:

`- 0.10 × mean_frequency_lag`

The lag metric carries stateful delay dynamics into the operational coherence calculation.

## 19. Operational Coherence C(t)

The current floating semantic reference calculates:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current coefficient map:

| Component | Coefficient |
|---|---:|
| base coherence term | `0.82` |
| effective coherence | `0.34` |
| cluster coherence mean | `0.16` |
| neutral-state fraction | `0.08` |
| mean frequency lag | `-0.10` |

This formula connects:

`phase coherence`

+

`hierarchical cluster coherence`

+

`active neutral participation`

+

`stateful delay response`

into one operational coherence metric.

## 20. Quantized Operational Coherence

The M15 quantized hardware shadow maps the same current formula into deterministic fixed-point arithmetic.

Current base term:

`quantize_q16(0.82)`

Current effective-coherence term:

`mul_q16_q30(quantize_q16(0.34), effective_coherence_q30)`

Current cluster-coherence term:

`mul_q16_q30(quantize_q16(0.16), cluster_coherence_mean_q30)`

Current neutral-fraction term:

`mul_q16_q30(quantize_q16(0.08), neutral_fraction_q30)`

Current frequency-lag term:

`mul_q16(quantize_q16(0.10), mean_lag_q16)`

Current quantized output:

`C_q16`

## 21. Destabilizing Load P(t)

The current relation is:

`P(t) = heat + switch_load`

Current floating inputs:

- global heat;
- current-tick switching load.

Current quantized inputs:

- `heat_global_q16`;
- `switch_load_q16`.

Current quantized relation:

`P_q16 = heat_global_q16 + switch_load_q16`

The metric combines the current thermal state and state-transition activity into one destabilizing-load term.

## 22. Dynamic-Stability Margin C_minus_P

Current floating relation:

`C_minus_P = C - P`

Current quantized relation:

`C_minus_P_q16 = C_q16 - P_q16`

Current validated condition:

`C_minus_P_min > 0.0`

The current M15 validation path checks:

- minimum margin;
- final margin;
- sign correlation;
- stability-boundary ordering;
- exact quantized replay.

## 23. Stability-Boundary Detection

The current processor records the first positive-to-nonpositive stability transition when the condition appears.

Current floating record:

`first_C_minus_P_crossing`

Current summary fields:

`boundary_detected`

`first_C_minus_P_crossing`

Current semantic correlation fields:

`float_boundary_tick`

`shadow_boundary_tick`

`boundary_order_match`

Current validated semantic relation:

`boundary_order_match = 1.0`

## 24. Current Floating Semantic Correlation Metrics

The current M15 reference-equivalence export records the floating semantic reference under the deterministic correlation workload.

Current floating summary:

| Metric | Current value |
|---|---:|
| `raw_phase_coherence_final` | `0.989218` |
| `raw_phase_coherence_min` | `0.182354` |
| `coherence_compression_final` | `1.0` |
| `coherence_compression_min` | `1.0` |
| `effective_coherence_final` | `0.989218` |
| `effective_coherence_min` | `0.182354` |
| `pair_domain_coherence_mean_final` | `0.999981` |
| `pair_domain_coherence_min` | `0.007127` |
| `cluster_coherence_mean_final` | `0.999973` |
| `cluster_coherence_min` | `0.229896` |
| `supercluster_coherence_mean_final` | `0.999248` |
| `supercluster_coherence_min` | `0.21869` |
| `coherence_dispersion_across_clusters_peak` | `0.162956` |
| `global_phase_coherence_final` | `0.989218` |
| `mean_frequency_lag_final` | `0.001963` |
| `mean_frequency_lag_peak` | `0.016005` |
| `C_minus_P_final` | `1.255549` |
| `C_minus_P_min` | `0.776998` |

Current floating boundary state:

`boundary_detected = False`

These values are recorded in the current M15 floating-reference-to-quantized-shadow equivalence artifact.

## 25. Current Default Quantized Structured Metrics

The current default structured execution uses the M15 quantized hardware-shadow path.

Current default profile:

`16 cells`

`64 steps`

`seed 76`

`scheduler 7/1`

Current summary values:

| Metric | Current value |
|---|---:|
| `C_minus_P_final` | `0.88287353515625` |
| `C_minus_P_final_q16` | `57860` |
| `C_minus_P_min` | `0.6142730712890625` |
| `C_minus_P_min_q16` | `40257` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `switch_load_peak` | `0.25` |
| `ticks_recorded` | `64` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Current default quantized boundary state:

`boundary_detected = False`

## 26. Current Quantized Trace Metrics

The M15 cycle-exact trace records one row per processor tick.

Current coherence and stability fields include:

- `global_phase_coherence_q30`;
- `C_q16`;
- `P_q16`;
- `C_minus_P_q16`;
- `heat_global_q16`;
- `switch_load_q16`.

Current route and execution fields include:

- `actual_direct_events`;
- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`;
- `pending_route_count`;
- `reserved_state_events`;
- `queue_overflow_events`;
- `scheduler_state`;
- `states_packed`.

The current default trace contains:

`64 processor-tick rows`

The current default cell trace contains:

`1024 cell-tick rows`

## 27. Per-Cell Metrics

The current M15 cell trace records:

- `cell_id`;
- `state_code`;
- `phase_word`;
- `frequency_target_q16`;
- `frequency_current_q16`;
- `frequency_lag_q16`;
- `generated_power_q16`;
- `heat_q16`;
- `thermal_overload_q16`;
- `gamma_noise_state_q16`;
- `gamma_effective_word`;
- `thermal_node_factor_q30`;
- `coupling_field_q16`.

These fields provide the local state needed to diagnose changes in global coherence and dynamic stability.

## 28. Cluster Metrics

The current floating semantic reference also computes per-cluster metrics.

Current cluster fields:

- cluster index;
- cell range;
- heat mean;
- heat peak;
- switching load;
- phase coherence;
- pressure;
- coherence margin;
- ternary state counts.

Current cluster pressure:

`cluster_pressure = cluster_heat_mean + cluster_switch_load`

Current cluster coherence margin:

`cluster_coherence_margin = cluster_phase_coherence - cluster_pressure`

These metrics provide a local coherence-pressure view alongside the global `C(t) - P(t)` relation.

## 29. Switching Load

Current switching load:

`switch_load = switched_nodes / total_nodes`

Current default transition fraction:

`0.25`

Current validated relation:

`switch_load_peak <= transition_fraction`

Current default validated boundary:

`switch_load_peak <= 0.25`

Switching load enters `P(t)` directly.

## 30. Local Thermal Metrics

The current processor tracks:

- generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

Current generated-power relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current thermal dissipation relation:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

Current thermal-overload relation:

`thermal_overload_i = max(0, local_heat_i - thermal_soft_limit)`

These metrics feed the current coupling, compression, and stability paths.

## 31. Thermal Coupling Metrics

Current thermal node factor:

`thermal_node_factor_i = exp(-0.5 × thermal_coupling_gain × overload_i)`

Current thermal coupling gain:

`2.50`

The thermal node factors modify the effective resonant coupling field.

Current fixed-point thermal closure marker:

`fixed_point_thermal_sum_exact = True`

## 32. Gamma Drift Metrics

The current processor tracks:

- nominal gamma;
- gamma-noise target;
- gamma-noise state;
- effective local gamma;
- gamma drift.

Current gamma-noise target refresh interval:

`8 ticks`

Current correlated update:

`gamma_noise_state += 0.15 × (gamma_noise_target - gamma_noise_state)`

Current effective local gamma:

`gamma_effective = gamma_nominal + 0.08 × thermal_overload × gamma_noise_state`

The effective gamma enters the Kuramoto-Sakaguchi phase interaction and therefore contributes indirectly to the coherence metrics.

## 33. Phase-Derived Ternary Target Metrics

The current phase-to-target relation is:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The target path is:

`evolved phase field`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active-neutral routing`

↓

`retained ternary state`

The coherence metric layer and ternary state layer therefore remain connected across successive processor ticks.

## 34. Active-Neutral Route Metrics

Current route metrics include:

- `requested_direct_events`;
- `prevented_direct_events`;
- `actual_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`;
- `pending_route_count`;
- `queue_overflow_events`.

Current required route invariant:

`actual_direct_events = 0`

Current reserved-state invariant:

`reserved_state_events = 0`

Current queue invariant:

`queue_overflow_events = 0`

The route metrics provide the transition-state context for the neutral fraction, switching load, thermal load, and retained-state path.

## 35. Scheduler Metrics

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

Current validated default 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

Current scheduler integrity marker:

`scheduler_counts_valid = True`

Scheduler state contributes directly to phase velocity and therefore to the coherence trajectory.

## 36. Current 41-Check Coherence and Stability Coverage

The current `41/41 PASS` self-test registry includes direct checks for:

- `fixed_point_thermal_sum_exact`;
- `fixed_point_topology_sum_exact`;
- `semantic_C_minus_P_sign_match`;
- `semantic_boundary_order_match`;
- `shadow_switch_load_within_transition_fraction`;
- `shadow_ticks_recorded_equals_steps`;
- `shadow_scheduler_counts_valid`;
- `shadow_actual_direct_events_zero`;
- `shadow_reserved_state_events_zero`;
- `shadow_queue_overflow_events_zero`;
- exact shadow state replay;
- exact shadow scheduler replay;
- exact pending-route replay;
- exact counter replay;
- exact trace replay;
- exact cell-trace replay;
- 8-cell scaling;
- 16-cell scaling;
- 32-cell scaling;
- 8-cell topology;
- 16-cell topology;
- 32-cell topology.

Current self-test result:

`41/41 PASS`

## 37. Floating-to-Quantized Semantic Correlation

The current M15 equivalence layer compares the floating semantic reference with the quantized hardware shadow.

Required exact sequence relations:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Current recorded result:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`neutral_route_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

`boundary_order_match = 1.0`

## 38. Current Semantic Error Results

The current generated equivalence report records:

| Field | Current maximum error | Qualification bound |
|---|---:|---:|
| phase | `0.010957534368146086` | `0.02` |
| frequency | `0.000022803546471550362` | `0.0001` |
| heat | `0.00004701887369061575` | `0.001` |
| gamma | `0.0` | `0.000001` |
| phase coherence | `0.002228678310501553` | `0.01` |
| `C` | `0.0007545911459079235` | `0.01` |
| `P` | `0.000014974864477032557` | `0.001` |
| `C_minus_P` | `0.0007535557740776522` | `0.01` |

Current semantic correlation result:

`PASS`

## 39. Exact Quantized Replay

The current exact replay boundary validates:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

Current result:

`shadow_replay_state_match = 1.0`

`shadow_replay_scheduler_match = 1.0`

`shadow_replay_pending_route_match = 1.0`

`shadow_replay_counter_match = 1.0`

`shadow_replay_trace_match = 1.0`

`shadow_replay_cell_trace_match = 1.0`

## 40. Scaling Verification

Current validated profiles:

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

## 41. M15 Artifact Layers Carrying Coherence Evidence

The qualified M15 package contains ten artifact layers:

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

The coherence and stability path appears across:

`fixed-point scalar and unit domains`

↓

`quantized shadow state`

↓

`global phase-coherence trace`

↓

`C_q16`

↓

`P_q16`

↓

`C_minus_P_q16`

↓

`reference equivalence`

↓

`qualification closure`

## 42. Inherited M15 Workflow Verification

Inherited qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

The workflow directly validates:

`C_minus_P_min > 0.0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

`check_count = 41`

`assertion_count = 13`

`C_minus_P_sign_match = 1.0`

`max_coherence_error <= 0.01`

`max_C_minus_P_error <= 0.01`

and the complete exact quantized replay set.

Qualified workflow result:

`PASS`

## 43. M16 Execution-Side Coherence Boundary Verification

The FRP v1.7.0 M15 executable semantic reference remains the source of the current phase-coherence, multiscale-coherence, thermal, `C(t)`, `P(t)`, and `C_minus_P` quantities.

The FRP v1.8.0 M16 execution layer begins at the phase-derived balanced ternary target and request boundary.

Current metric and execution binding:

| Quantity or boundary | Qualified source | M16 execution relation |
|---|---|---|
| Kuramoto order parameter `R` | M15 executable semantic reference | phase-derived target source |
| multiscale phase coherence | M15 executable semantic reference | phase-derived target source |
| thermal state | M15 executable semantic reference | endogenous target-generation input |
| operational coherence `C(t)` | M15 executable semantic reference | semantic qualification source |
| destabilizing load `P(t)` | M15 executable semantic reference | semantic qualification source |
| `C_minus_P` | M15 executable semantic reference | semantic qualification source |
| balanced ternary target | M15-to-M16 interface boundary | request target input |
| scheduler state | M16 RTL execution layer | transition eligibility |
| request-lane order | M16 RTL execution layer | deterministic request arbitration |
| pending route | M16 RTL execution layer | retained opposite-polarity target |
| active neutral state `0` | M16 RTL execution layer | mandatory intermediate retained state |
| accepted changes | M16 RTL execution layer | transition-capacity record |
| switch-load numerator | M16 RTL execution layer | `switch_load_numerator = accepted_changes` |

Qualified M16 RTL execution relations:

- `free`, `7/1`, and `1/7` scheduler execution;
- deterministic request-lane arbitration;
- active-neutral first-leg execution;
- retained pending polarity;
- pending-route completion only from retained state `0`;
- transition-capacity enforcement;
- retained-state writeback;
- canonical retained-state encoding;
- canonical pending-route encoding.

Qualified M16 FPGA preparation relations:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating;
- scheduler propagation;
- request-interface propagation;
- active-neutral route execution;
- retained pending-route completion.

Qualified M16 terminal records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`invariant_flags = 1111111111`

M16 RTL qualification record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Initial workflow run | `#82` |
| Initial qualified commit | `a68a2af` |
| Qualification rerun | `#84` |
| Rerun qualified commit | `ede53cf` |
| Result | `SUCCESS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

M16 FPGA preparation qualification record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Initial workflow run | `#1` |
| Initial qualified commit | `326b69e` |
| Qualification rerun | `#2` |
| Rerun qualified commit | `ede53cf` |
| Result | `SUCCESS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

## 44. Current Comparative Workload Coherence Evidence

The current Comparative Architecture Benchmark Suite preserves a separate 256-command, 16-cell, seed-76, `transaction_serial` workload contour.

Current FRP architecture identifier:

`frp_v1_7_0_quantized_shadow`

Current FRP comparative coherence and stability results:

`global_phase_coherence_final = 0.9999997103586793`

`global_phase_coherence_final_q30 = 1073741513`

`C_minus_P_min = 0.856201171875`

`C_minus_P_min_q16 = 56112`

`C_minus_P_final = 1.2415313720703125`

`C_minus_P_final_q16 = 81365`

The same comparative row records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`pending_route_count_final = 0`

This is the workload-specific M15 comparison contour retained by FRP v1.8.0.

## 45. Historical Archived Transition Benchmark

The repository preserves the historical transition benchmark in:

`../TEST_REPORT_v0_9_3.md`

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded historical result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

## 46. Archived Ternary-to-Binary Thermal Result

The archived benchmark directly records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Therefore, under the historical v0.9.3 transition benchmark model and workload:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent relative reduction:

`93.63% lower heat_peak`

The same archived result records:

`distributed_neutral_ternary C_minus_P_min = 0.174750`

`binary_style_forced_switch C_minus_P_min = -0.551000`

`distributed_neutral_ternary actual_direct_events = 0`

`binary_style_forced_switch actual_direct_events = 2052`

`distributed_neutral_ternary switch_load_peak = 0.25`

`binary_style_forced_switch switch_load_peak = 1.0`

This archived run preserves direct repository evidence that the distributed-neutral ternary transition path ran substantially colder than the binary-style forced-switching path inside that release-specific benchmark model.

## 47. Historical and Current Metric Contours

The historical v0.9.3 contour measures:

- target match;
- historical operational coherence;
- historical destabilizing load;
- historical stability margin;
- transition routing;
- switching load;
- historical `heat_peak`.

The inherited v1.7.0 M15 contour measures:

- raw phase coherence;
- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence;
- coherence dispersion;
- nonlinear coherence compression;
- effective coherence;
- neutral-state contribution;
- mean frequency lag;
- current operational coherence `C(t)`;
- current destabilizing load `P(t)`;
- current dynamic stability `C(t) - P(t)`;
- quantized correlation;
- exact deterministic replay.

The current v1.8.0 M16 execution-side contour verifies:

- propagation of phase-derived balanced ternary targets through the request interface;
- scheduler-qualified transition eligibility;
- deterministic request-lane arbitration;
- active-neutral route execution;
- retained pending-route completion;
- transition-capacity records;
- retained-state writeback;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- ten integrated invariant flags;
- target-independent FPGA integration propagation.

Each contour retains its release-specific metric definitions and result records.

## 48. Metric Interpretation Registry

Use the following evidence mapping:

| Metric | Interpretation source |
|---|---|
| `raw_phase_coherence` | current floating phase field |
| pair, cluster, supercluster coherence | current hierarchical phase groups |
| `global_phase_coherence` | current full processor phase field |
| `coherence_compression` | current thermal-overload and margin-pressure response |
| `effective_coherence` | compressed current phase coherence |
| `C(t)` | current operational coherence formula |
| `P(t)` | current global heat plus switching load |
| `C_minus_P` | current dynamic-stability margin |
| `global_phase_coherence_q30` | current M15 cycle-exact quantized trace |
| `C_q16`, `P_q16`, `C_minus_P_q16` | current M15 fixed-point stability path |
| historical `heat_peak` | release-specific v0.9.3 transition benchmark |
| comparative `temperature_proxy` | current common RC thermal-proxy model |
| `accepted_changes` | current M16 transition-capacity record |
| `switch_load_numerator` | current M16 accepted state-change count |
| `invariant_flags` | current M16 integrated execution-invariant vector |

This registry keeps each metric attached to the model that generates it.

## 49. Reproduction Commands

Compile the current executable:

    python -m py_compile frp_prototype_v1_7_0.py

Run the current self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

`41/41 PASS`

Run the current default structured execution:

    python frp_prototype_v1_7_0.py --mode demo --output json

Run the current full trace:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Generate the current equivalence report:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Generate the current qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Build and run the current M16 RTL testbench:

    verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv

    /tmp/frp_m16_obj/Vfrp_m16_tb

Elaborate the current M16 FPGA integration top:

    verilator --sv --lint-only --top-module frp_m16_fpga_top -Irtl/m16 -Ifpga/m16 fpga/m16/frp_m16_fpga_top.sv

Build and run the current M16 FPGA preparation testbench:

    verilator --sv --timing --assert --binary --top-module frp_m16_fpga_tb -Irtl/m16 -Ifpga/m16 --Mdir /tmp/frp_m16_fpga_obj fpga/m16/frp_m16_fpga_tb.sv

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

## 50. Coherence-Metric Failure Diagnosis

When a coherence or stability result changes, inspect the first affected layer in this order:

`phase words or floating phases`

↓

`frequency state and frequency lag`

↓

`hierarchical coupling field`

↓

`local gamma state`

↓

`local thermal state`

↓

`raw phase coherence`

↓

`multiscale coherence`

↓

`coherence compression`

↓

`effective coherence`

↓

`neutral-state fraction`

↓

`C(t)`

↓

`P(t)`

↓

`C_minus_P`

↓

`semantic correlation`

↓

`exact quantized replay`

↓

`M16 target and request-interface boundary`

↓

`M16 scheduler, request-lane, pending-route, active-neutral, capacity, and writeback execution`

↓

`M16 invariant and zero-event records`

↓

`M16 FPGA reset, gating, scheduler, request, and route propagation`

Record:

- first changed tick;
- first changed cell;
- first changed phase or frequency field;
- first changed coherence field;
- first changed stability field;
- first changed deterministic digest.

## 51. Current Release Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Current validation environment:

`GitHub Actions hardware-backed CI execution`

Inherited M15 semantic and implementation-mapping qualification:

`41/41 PASS`

M16 RTL qualification records:

| Record | Workflow run | Qualified commit | Result |
|---|---:|---|---:|
| initial closure | `#82` | `a68a2af` | `SUCCESS` |
| qualification rerun | `#84` | `ede53cf` | `SUCCESS` |

M16 FPGA preparation qualification records:

| Record | Workflow run | Qualified commit | Result |
|---|---:|---|---:|
| initial closure | `#1` | `326b69e` | `SUCCESS` |
| qualification rerun | `#2` | `ede53cf` | `SUCCESS` |

Current overall published result:

`PASS`

## 52. Current File Alignment

This coherence-metrics layer is aligned with:

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
- `../docs/benchmark_interpretation.md`;
- `../docs/limitations.md`;
- `../docs/mathematical_foundation.md`;
- `../docs/physical_foundation.md`;
- `../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../docs/m16_rtl_core_realization_execution_semantics.md`;
- `./README.md`;
- `../rtl/m16/README.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

Inherited M15 release evidence remains aligned with:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

Historical thermal evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 53. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current coherence chain:

`Kuramoto order parameter R → multiscale phase coherence → thermal and margin pressure → nonlinear coherence compression → effective coherence → C(t) → P(t) → C(t) - P(t)`

Current operational coherence formula:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current destabilizing-load formula:

`P = heat + switch_load`

Current validated stability condition:

`C_minus_P_min > 0.0`

Current executable semantic-reference form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current self-test result:

`41/41 PASS`

Inherited M15 qualification closure result:

`PASS`

Current M16 RTL qualification result:

`PASS`

Current M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation qualification result:

`PASS`

Current M16 FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current published validation result:

`PASS`

Historical archived ternary-to-binary thermal result:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch under the historical v0.9.3 transition benchmark model`

Current release qualification state:

`FRP v1.8.0 / M16 — PASS`




    



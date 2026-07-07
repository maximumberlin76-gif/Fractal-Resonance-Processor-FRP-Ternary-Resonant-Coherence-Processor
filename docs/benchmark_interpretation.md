# Benchmark Interpretation — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines how to interpret the current benchmark, comparative architecture, normalized activity-cost, thermal-proxy, and hardware-sensitivity results published in the Fractal Resonance Processor (FRP) repository.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current comparative architecture schema:

`frp.benchmark.architecture_comparison.v1`

Current hardware-sensitivity comparison schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Current primary M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current comparative architecture workflow:

`../.github/workflows/frp-architecture-comparison.yml`

Current hardware-sensitivity profile workflow:

`../.github/workflows/frp-hardware-sensitivity-profile.yml`

Current hardware-sensitivity comparison workflow:

`../.github/workflows/frp-hardware-sensitivity-comparison.yml`

Current published M15 validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current canonical comparative package qualification status:

`PASS`

Current canonical hardware-sensitivity package qualification status:

`PASS`

## 1. Benchmark Interpretation Role

The current repository contains four connected benchmark and validation contours:

1. the FRP v1.7.0 structured execution contour;
2. the M15 implementation-mapping benchmark matrix;
3. the Comparative Architecture Benchmark Suite;
4. the hardware-informed sensitivity layer.

These contours answer different technical questions.

The structured execution contour records the current processor state and kernel invariants.

The M15 benchmark matrix records the implementation-mapping progression from the M14 floating semantic reference through qualification closure.

The Comparative Architecture Benchmark Suite applies one deterministic semantic workload to four architecture references and records architecture-specific event traces under shared comparison models.

The hardware-informed sensitivity layer applies three globally shared coefficient scenarios to the same raw architecture execution results.

The interpretation chain is:

`processor execution`

↓

`raw state, route, phase, coherence, thermal, and stability evidence`

↓

`M15 implementation-mapping position`

↓

`common semantic workload`

↓

`architecture-specific execution`

↓

`raw event counters`

↓

`shared normalized activity-cost profile`

↓

`shared thermal proxy`

↓

`hardware-informed coefficient scenarios`

↓

`machine-readable benchmark evidence`

## 2. FRP Computational Subject

FRP is a ternary resonant coherence processor.

Its computational mechanism combines:

- Kuramoto-Sakaguchi resonant phase coupling;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- phase evolution;
- resonance selection;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- local thermal-phase interaction;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability `C(t) - P(t)`;
- phase-derived ternary targets;
- distributed ternary commit;
- mandatory tick-separated routing through active neutral state `0`;
- retained coherent ternary state.

The complete processor chain is:

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

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay dynamics`

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

`mandatory active-neutral routing`

↓

`retained coherent ternary state`

The comparative benchmark counts the execution activity produced by this current M15 quantized hardware-shadow path.

## 3. Balanced Ternary State and Routing Invariants

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Validated opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Current validated invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The current comparative FRP result also records:

`requested_direct_events = 125`

`prevented_direct_events = 125`

`neutral_insertions = 125`

`neutral_routed_events = 125`

`neutralized_conflicts = 125`

`pending_route_count_final = 0`

`pending_route_peak = 1`

These values describe the current FRP route activity under the canonical 256-command comparative workload.

## 4. Current Benchmark Layers

### 4.1 Structured execution

Command:

    python frp_prototype_v1_7_0.py --mode demo --output json

Primary evidence:

- current processor configuration;
- scheduler counts;
- balanced ternary state-domain validity;
- direct-event counter;
- reserved-state counter;
- queue-overflow counter;
- switch-load peak;
- dynamic stability minimum;
- fixed-point topology exactness;
- fixed-point thermal exactness.

### 4.2 M15 benchmark matrix

Command:

    python frp_prototype_v1_7_0.py --mode benchmark

Equivalent export:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

Primary evidence:

- implementation-mapping progression;
- current M15 reference layers;
- qualification closure position.

### 4.3 Comparative architecture suite

Directory:

`../benchmarks/architecture_comparison/`

Primary evidence:

- common workload;
- architecture-specific raw traces;
- common event taxonomy;
- shared normalized activity-cost profile;
- shared thermal proxy;
- deterministic package integrity.

### 4.4 Hardware-informed sensitivity layer

Primary evidence:

- calibration contract;
- coefficient provenance map;
- literature-anchored sensitivity profile;
- lower-bound scenario;
- nominal scenario;
- upper-bound scenario;
- ranking-stability matrix;
- deterministic package integrity.

## 5. Current M15 Benchmark Matrix

The current M15 benchmark matrix contains five rows.

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

This matrix records the current implementation-mapping chain:

`M14 floating semantic reference`

↓

`M15 quantized hardware shadow`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog correlation contract`

↓

`qualification closure`

The M15 matrix interprets the processor architecture across implementation and verification layers.

## 6. Comparative Architecture Set

The current comparative suite contains four architecture references.

| Architecture identifier | Architecture role |
|---|---|
| `binary_synchronous_reference` | globally clocked binary reference |
| `binary_clock_gated_reference` | clock-gated binary reference |
| `direct_ternary_reference` | direct ternary state-transition reference |
| `frp_v1_7_0_quantized_shadow` | current FRP v1.7.0 M15 quantized hardware-shadow reference |

Every architecture receives the same ordered semantic command list.

Every architecture executes the workload independently.

Every architecture records raw activity through one common event taxonomy.

Every architecture is evaluated through the same cost profile and the same thermal proxy profile.

## 7. Binary Synchronous Reference

Identifier:

`binary_synchronous_reference`

State domain:

`0`

`1`

Semantic mapping:

`NEGATIVE_TARGET → 0`

`POSITIVE_TARGET → 1`

The reference uses a globally clocked execution profile.

The event model records:

- semantic commands;
- state changes;
- encoded bit toggles;
- clocked cycles;
- clocked state bits;
- register writes;
- comparison events;
- control events.

Current canonical architecture-specific metric:

`direct_binary_switches = 130`

## 8. Binary Clock-Gated Reference

Identifier:

`binary_clock_gated_reference`

State domain:

`0`

`1`

Semantic mapping:

`NEGATIVE_TARGET → 0`

`POSITIVE_TARGET → 1`

The logical transition behavior follows the binary reference mapping.

The clock-activity model records activity across the active architectural state domain defined by the suite.

Current canonical architecture-specific metrics:

`direct_binary_switches = 130`

`gated_cycles = 158`

`clock_gate_active_fraction = 0.4513888888888889`

## 9. Direct Ternary Reference

Identifier:

`direct_ternary_reference`

State domain:

`{-1, 0, 1}`

Semantic mapping:

`NEGATIVE_TARGET → -1`

`POSITIVE_TARGET → +1`

Opposite semantic targets are applied through direct polarity changes.

Current canonical architecture-specific metrics:

`direct_opposite_polarity_changes = 122`

`neutral_state_exits = 16`

`gated_cycles = 150`

This reference provides the ternary state-representation comparison path.

## 10. FRP v1.7.0 Quantized Hardware-Shadow Reference

Identifier:

`frp_v1_7_0_quantized_shadow`

Reference source:

`../frp_prototype_v1_7_0.py`

The comparative adapter uses the current M15 quantized hardware-shadow execution path.

State domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current route invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current fixed-point invariants:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

Current canonical final phase-coherence value:

`global_phase_coherence_final = 0.9999997103586793`

Current canonical minimum dynamic stability:

`C_minus_P_min = 0.856201171875`

Current canonical final dynamic stability:

`C_minus_P_final = 1.2415313720703125`

The FRP comparative row therefore includes both semantic completion and current processor-specific route, phase-coherence, fixed-point, and stability evidence.

## 11. Canonical Semantic Workload

Current workload profile:

| Parameter | Value |
|---|---:|
| cells | `16` |
| commands | `256` |
| seed | `76` |
| issue policy | `transaction_serial` |
| maximum completion cycles per command | `64` |
| final cooldown cycles | `32` |

Semantic target domain:

`NEGATIVE_TARGET`

`POSITIVE_TARGET`

Each workload record contains:

`command_index`

`cell_id`

`semantic_target`

Current workload digest:

`8386174d0a4751af26cc68bf46a5494cf0e58a3c14fc59ff46830a21645f0562`

All four architecture results carry this same workload digest.

## 12. Transaction-Serial Execution Policy

For each architecture, the current profile performs:

1. read the next semantic command;
2. issue the command;
3. execute architecture cycles until semantic completion;
4. record command latency;
5. proceed to the next command;
6. execute the fixed final cooldown period after the final command.

Each architecture therefore processes the same command order and records its own completion timing.

The measured timing fields are:

- `completion_ticks`;
- `mean_latency_ticks`;
- `p95_latency_ticks`;
- `maximum_latency_ticks`;
- `throughput_commands_per_tick`.

## 13. Semantic Completion Rule

Binary completion:

`NEGATIVE_TARGET → state 0`

`POSITIVE_TARGET → state 1`

Direct ternary completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state +1`

FRP completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state +1`

For FRP opposite-polarity migration, the active neutral state provides the intermediate route stage.

Command completion occurs when the retained target polarity is applied.

## 14. Common State Encodings

Binary encoding:

`0 → 1'b0`

`1 → 1'b1`

Direct ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

FRP v1.7.0 encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved FRP encoding:

`2'b10`

The suite records:

`logical_state_changes`

and:

`encoded_bit_toggles`

as distinct metrics.

## 15. Common Raw Event Taxonomy

Every architecture emits the common event-counter set:

- `semantic_commands_issued`;
- `semantic_commands_completed`;
- `processor_cycles`;
- `active_clocked_cycles`;
- `logical_state_changes`;
- `encoded_bit_toggles`;
- `clocked_state_bits`;
- `register_write_bits`;
- `comparison_events`;
- `control_events`;
- `queue_reads`;
- `queue_writes`;
- `lut_reads_32`;
- `fixed_point_multiplies_32x32`;
- `fixed_point_accumulates_64`;
- `fixed_point_adds_32`;
- `fixed_point_compares_32`.

This taxonomy makes architecture-specific execution activity visible in one shared result structure.

## 16. Common Unit-Event Cost Profile

Current base profile:

`unit_event_cost_v1`

Current cost unit:

`normalized_activity_unit`

Every supported event class has coefficient:

`1.0`

The base profile therefore interprets the event stream as explicit operation volume under a uniform event-counting scale.

Current cost-profile digest:

`4c4a470150ecc182c9a51eaefc0bcba0353e71160d16c6c6afd28a39c23b05bc`

## 17. Common Thermal Proxy

Current thermal profile:

`common_rc_thermal_proxy_v1`

Current temperature unit:

`normalized_temperature_proxy`

Current parameters:

| Parameter | Value |
|---|---:|
| ambient temperature proxy | `0.0` |
| thermal decay | `0.95` |
| thermal gain | `0.01` |

Current thermal-profile digest:

`8cc2992f5699c47c88e81c17a4a5f0c8ff5bb7a5b32ebf73ab0e5a0f9c5494c8`

The proxy receives the normalized activity stream from every architecture through the same recurrence and parameter set.

Its outputs are:

- `peak_temperature_proxy`;
- `final_temperature_proxy`;
- temperature-proxy trace digest.

## 18. Canonical Comparative Result

Current canonical result file:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Current package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Current integrity status:

`PASS`

Current qualification status:

`PASS`

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 19. Canonical Comparative Matrix

| Architecture | Completion ticks | Mean latency | Throughput | Total normalized activity cost | Cost per command | Peak temperature proxy | Final temperature proxy |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_synchronous_reference` | `288` | `1.0` | `0.8888888888888888` | `5412.0` | `21.140625` | `3.8474206768140564` | `3.479815488235824` |
| `binary_clock_gated_reference` | `288` | `1.0` | `0.8888888888888888` | `934.0` | `3.6484375` | `0.771273768299779` | `0.3003540042045561` |
| `direct_ternary_reference` | `288` | `1.0` | `0.8888888888888888` | `1242.0` | `4.8515625` | `1.119499710224827` | `0.3414291661285317` |
| `frp_v1_7_0_quantized_shadow` | `413` | `1.48828125` | `0.6198547215496368` | `1393509.0` | `5443.39453125` | `675.0796999541329` | `673.7075352972579` |

All four architectures record:

`semantic_completion_ratio = 1.0`

`semantic_output_match = 1.0`

The current matrix therefore provides a common semantic-completion baseline together with architecture-specific latency, event volume, normalized activity cost, and thermal-proxy response.

## 20. Binary Synchronous Result Interpretation

Current canonical values:

`processor_cycles = 288`

`active_clocked_cycles = 288`

`active_clock_fraction = 1.0`

`logical_state_changes = 130`

`encoded_bit_toggles = 130`

`total_normalized_energy = 5412.0`

`peak_temperature_proxy = 3.8474206768140564`

The base profile shows the cost contribution of globally active clocked state bits across the canonical execution.

## 21. Binary Clock-Gated Result Interpretation

Current canonical values:

`processor_cycles = 288`

`active_clocked_cycles = 130`

`active_clock_fraction = 0.4513888888888889`

`logical_state_changes = 130`

`encoded_bit_toggles = 130`

`total_normalized_energy = 934.0`

`peak_temperature_proxy = 0.771273768299779`

The base profile shows the reduction in counted clock activity produced by the current clock-gated reference contract.

## 22. Direct Ternary Result Interpretation

Current canonical values:

`processor_cycles = 288`

`active_clocked_cycles = 138`

`active_clock_fraction = 0.4791666666666667`

`logical_state_changes = 138`

`encoded_bit_toggles = 146`

`direct_opposite_polarity_changes = 122`

`total_normalized_energy = 1242.0`

`peak_temperature_proxy = 1.119499710224827`

The direct ternary row records ternary state representation with direct opposite-polarity application under the suite contract.

## 23. FRP Quantized-Shadow Result Interpretation

Current canonical values:

`processor_cycles = 413`

`active_clocked_cycles = 413`

`active_clock_fraction = 1.0`

`logical_state_changes = 261`

`encoded_bit_toggles = 392`

`mean_latency_ticks = 1.48828125`

`maximum_latency_ticks = 2`

`throughput_commands_per_tick = 0.6198547215496368`

`total_normalized_energy = 1393509.0`

`normalized_energy_per_completed_command = 5443.39453125`

`peak_temperature_proxy = 675.0796999541329`

`final_temperature_proxy = 673.7075352972579`

The current M15 quantized-shadow row explicitly counts:

- fixed-point arithmetic;
- trigonometric lookup activity;
- hierarchy activity;
- queue activity;
- thermal-field activity;
- coherence activity;
- state-transition activity.

The canonical base profile therefore records the complete declared activity volume of the current M15 quantized hardware-shadow execution path.

## 24. FRP Raw Activity Concentration

Current FRP raw event totals include:

| Event class | Count |
|---|---:|
| fixed-point multiplies 32×32 | `518728` |
| fixed-point accumulates 64 | `296534` |
| fixed-point adds 32 | `339899` |
| fixed-point compares 32 | `45430` |
| lookup-table reads 32 | `172221` |
| clocked state bits | `13216` |
| comparison events | `5904` |
| register write bits | `522` |
| encoded bit toggles | `392` |
| logical state changes | `261` |
| queue reads | `125` |
| queue writes | `125` |

The dominant current cost concentration is:

`fixed-point arithmetic volume`

plus:

`trigonometric lookup volume`

This concentration explains the current FRP position in both the uniform unit-event profile and the literature-anchored sensitivity scenarios.

## 25. Latency Interpretation

Current canonical mean latency:

| Architecture | Mean latency ticks |
|---|---:|
| binary synchronous | `1.0` |
| binary clock-gated | `1.0` |
| direct ternary | `1.0` |
| FRP quantized shadow | `1.48828125` |

Current canonical maximum latency:

| Architecture | Maximum latency ticks |
|---|---:|
| binary synchronous | `1` |
| binary clock-gated | `1` |
| direct ternary | `1` |
| FRP quantized shadow | `2` |

The FRP timing values record the active-neutral route path under transaction-serial command completion.

The current canonical workload contains 125 requested opposite-polarity events, and the FRP row routes all 125 through the active neutral state.

## 26. Throughput Interpretation

Throughput relation:

`throughput_commands_per_tick = semantic_commands_completed / completion_ticks`

Current canonical values:

| Architecture | Throughput commands per tick |
|---|---:|
| binary synchronous | `0.8888888888888888` |
| binary clock-gated | `0.8888888888888888` |
| direct ternary | `0.8888888888888888` |
| FRP quantized shadow | `0.6198547215496368` |

The current throughput difference follows from the architecture-specific completion timing recorded under the shared transaction-serial policy.

## 27. Semantic Output Interpretation

Current canonical result:

`semantic_completion_ratio = 1.0`

for every architecture.

Current canonical result:

`semantic_output_match = 1.0`

for every architecture.

This establishes a common semantic completion baseline for the architecture-level cost, latency, throughput, transition, and thermal-proxy comparison.

## 28. Route-Safety Interpretation

The FRP canonical result records:

`requested_direct_events = 125`

`prevented_direct_events = 125`

`neutral_insertions = 125`

`neutral_routed_events = 125`

`actual_direct_events = 0`

`pending_route_count_final = 0`

`queue_overflow_events = 0`

`reserved_state_events = 0`

The route evidence demonstrates complete active-neutral handling of the canonical opposite-polarity request set.

## 29. Dynamic Stability Interpretation

Current FRP canonical minimum:

`C_minus_P_min = 0.856201171875`

Current FRP canonical final value:

`C_minus_P_final = 1.2415313720703125`

Current fixed-point representations:

`C_minus_P_min_q16 = 56112`

`C_minus_P_final_q16 = 81365`

The comparative FRP row therefore preserves the current positive dynamic-stability condition throughout the canonical workload.

## 30. Phase-Coherence Interpretation

Current FRP canonical final value:

`global_phase_coherence_final = 0.9999997103586793`

Current fixed-point representation:

`global_phase_coherence_final_q30 = 1073741513`

The comparative FRP row therefore retains direct phase-coherence evidence together with route, stability, and activity-cost evidence.

## 31. Current Base-Profile Cost Interpretation

The unit-event profile assigns coefficient `1.0` to every supported event class.

Under this profile, the canonical architecture ordering by ascending total normalized activity cost is:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

The current FRP M15 quantized-shadow row carries the largest declared event volume because the suite counts its full fixed-point resonant, lookup, hierarchy, queue, thermal, coherence, and state-transition activity.

## 32. Thermal-Proxy Interpretation

The current common RC proxy receives the normalized activity stream generated under the base unit-event profile.

Current peak temperature-proxy ordering is:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

The current FRP thermal-proxy position follows from its high counted activity volume under the current M15 quantized-shadow event taxonomy.

The benchmark therefore exposes the relationship:

`declared architecture activity`

↓

`normalized activity cost`

↓

`common thermal-proxy response`

## 33. Hardware-Informed Sensitivity Layer

Current profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

Current profile role:

`hardware_informed_sensitivity`

Normalization reference:

`32-bit integer addition = 1.0`

Reference energy value:

`0.1 pJ`

Reference technology context:

`45 nm CMOS`

The sensitivity profile is defined through:

`hardware cost calibration contract`

↓

`coefficient provenance map`

↓

`hardware sensitivity profile`

↓

`strict machine validation`

↓

`profile qualification workflow`

↓

`sensitivity comparison runner`

↓

`comparison qualification workflow`

↓

`canonical sensitivity result`

## 34. Hardware-Sensitivity Control Files

Calibration contract:

`../benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md`

Coefficient provenance map:

`../benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`

Sensitivity profile:

`../benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`

Profile validator:

`../benchmarks/architecture_comparison/validate_hardware_sensitivity_profile.py`

Sensitivity runner:

`../benchmarks/architecture_comparison/run_hardware_sensitivity_comparison.py`

Canonical sensitivity result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

## 35. Global Sensitivity Scenarios

Current scenario order:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

The same global coefficient vector is applied to all four architecture results within each scenario.

The same raw architecture results feed every scenario.

The same raw event traces feed every scenario.

The same workload digest remains bound across every scenario.

The sensitivity layer therefore measures the response of the recorded architecture activity to three declared coefficient vectors.

## 36. Canonical Hardware-Sensitivity Results

| Scenario | Binary Synchronous | Binary Clock-Gated | Direct Ternary | FRP v1.7.0 Quantized Shadow |
|---|---:|---:|---:|---:|
| `lower_bound` | `181.078125` | `111.109375` | `118.078125` | `14457825.125` |
| `nominal` | `724.3125` | `444.4375` | `472.3125` | `25157118.0` |
| `upper_bound` | `4049.25` | `2929.75` | `3041.25` | `39955490.0` |

Current ranking basis:

`ascending_total_normalized_energy`

Current ranking in every scenario:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Current recorded ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

## 37. Sensitivity Result Interpretation

The current sensitivity result preserves the same ranking across:

`lower_bound`

`nominal`

`upper_bound`

The FRP row remains the highest declared normalized cost across all three scenarios.

The current cost concentration remains dominated by:

- fixed-point multiplies;
- fixed-point accumulates;
- fixed-point adds;
- fixed-point compares;
- trigonometric lookup reads.

The sensitivity layer therefore confirms the same current implementation-mapping cost concentration under three globally shared coefficient scenarios.

## 38. Pairwise Stability Interpretation

The canonical sensitivity result contains six pairwise relations.

| Left architecture | Right architecture | Classification |
|---|---|---|
| `binary_synchronous_reference` | `binary_clock_gated_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `direct_ternary_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `direct_ternary_reference` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `direct_ternary_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |

Every relation remains unchanged across all three scenarios.

## 39. Canonical Hardware-Sensitivity Package

Current result schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Current package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Current integrity status:

`PASS`

Current qualification status:

`PASS`

Current profile validation status:

`PASS`

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 40. Comparative Architecture Qualification Contract

Current workflow:

`../.github/workflows/frp-architecture-comparison.yml`

Workflow name:

`FRP Comparative Architecture Benchmark`

Job name:

`Comparative Architecture Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

The workflow performs:

- source checkout;
- Python setup;
- compilation;
- workload-profile validation;
- normalized cost-profile validation;
- thermal-profile validation;
- common-model self-tests;
- architecture-reference self-tests;
- FRP adapter self-test;
- end-to-end comparison self-test;
- canonical package generation;
- independent package regeneration;
- byte-identical package comparison;
- package integrity validation;
- qualification-contract validation;
- SHA-256 manifest generation;
- artifact upload;
- canonical result update on the main branch.

## 41. Canonical Comparative Command

From:

`../benchmarks/architecture_comparison/`

run:

    python run_architecture_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --cost-profile profiles/normalized_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write results/reference_comparison_seed_76.json \
      --output text

Generate an independent repeat:

    python run_architecture_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --cost-profile profiles/normalized_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write .qualification/reference_comparison_seed_76_repeat.json \
      --output text

Compare:

    cmp \
      results/reference_comparison_seed_76.json \
      .qualification/reference_comparison_seed_76_repeat.json

Required deterministic result:

`byte-identical equality`

## 42. Hardware-Sensitivity Profile Qualification Contract

Current workflow:

`../.github/workflows/frp-hardware-sensitivity-profile.yml`

Workflow name:

`FRP Hardware Sensitivity Profile Qualification`

Job name:

`Hardware Sensitivity Profile Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`15 minutes`

The workflow performs:

- profile-validator compilation;
- canonical profile validation;
- machine-readable validation capture;
- validator self-test;
- independent validation regeneration;
- byte-identical validation comparison;
- qualification-contract validation;
- SHA-256 manifest generation;
- artifact upload.

The root README exposes this workflow with a current `passing` badge.

## 43. Hardware-Sensitivity Comparison Qualification Contract

Current workflow:

`../.github/workflows/frp-hardware-sensitivity-comparison.yml`

Workflow name:

`FRP Hardware Sensitivity Comparison`

Job name:

`Hardware Sensitivity Comparison Qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

The workflow performs:

- sensitivity execution-chain compilation;
- canonical baseline checksum capture;
- hardware-sensitivity profile validation;
- profile-validator self-test;
- sensitivity-runner self-test;
- canonical sensitivity result generation;
- independent sensitivity result regeneration;
- byte-identical result comparison;
- canonical baseline checksum verification;
- sensitivity package-contract validation;
- SHA-256 manifest generation;
- artifact upload;
- canonical sensitivity-result update on the main branch.

The root README exposes this workflow with a current `passing` badge.

## 44. Current Qualification Checks

The canonical comparative package validates:

- all architectures completed the workload;
- architecture order matches the contract;
- cost trace closes;
- thermal trace closes;
- numeric metrics remain finite;
- FRP actual direct-event count equals zero;
- FRP pending-route count finishes at zero;
- FRP queue-overflow count equals zero;
- FRP reserved-state count equals zero;
- all architectures share the workload digest;
- all architectures share the cost-profile digest;
- all architectures share the thermal-profile digest;
- semantic output match equals one.

The canonical hardware-sensitivity package additionally validates:

- three exact global scenario vectors;
- architecture result digests match the baseline;
- raw event traces remain identical across scenarios;
- the common thermal profile remains identical across scenarios;
- pairwise analysis is complete;
- ranking analysis is complete;
- the profile validator reports `PASS`;
- all scenario integrity checks report `PASS`.

## 45. Current Comparison Policy

The current machine-readable policy identifier is:

`integrity_only_no_winner_assertions`

The current winner-assertion array is:

`[]`

The qualification layer validates:

- shared inputs;
- deterministic execution;
- exact profile binding;
- raw-trace closure;
- metric finiteness;
- route invariants;
- package integrity;
- repeatability.

The measured matrix remains the published comparison evidence.

## 46. Historical v0.9.3 Transition Benchmark Contour

The repository also preserves the original v0.9.3 transition benchmark as a release-specific historical benchmark contour.

Historical executable:

`../frp_prototype_v0_9_3_mobile.py`

Historical test report:

`../TEST_REPORT_v0_9_3.md`

Historical benchmark command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

The historical contour records transition behavior, stability margin, heat metric, switching load, direct-event activity, prevented direct-event activity, and neutralized conflict activity for the v0.9.3 release layer.

## 47. Historical v0.9.3 Result Record

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

This historical result remains bound to the v0.9.3 benchmark model and its release-specific metrics.

The current M15 comparative suite defines the active architecture-level comparison contour for FRP v1.7.0.

## 48. Relationship Between the Historical and Current Contours

The historical v0.9.3 contour emphasizes:

- transition routing;
- stability margin;
- switching load;
- historical heat metric;
- prevented direct-event activity;
- neutralized conflicts.

The current M15 comparative contour emphasizes:

- identical semantic workload;
- architecture-specific execution timing;
- common state-encoding metrics;
- raw event taxonomy;
- normalized activity cost;
- common thermal proxy;
- deterministic package integrity;
- hardware-informed sensitivity;
- current FRP M15 route, coherence, fixed-point, and stability invariants.

Both remain part of the repository's benchmark history, each bound to its release-specific architecture layer.

## 49. Interpretation of Current FRP Comparative Cost

The current canonical result records the FRP v1.7.0 quantized hardware shadow as the highest-cost architecture under:

- the unit-event base profile;
- the lower-bound hardware-informed scenario;
- the nominal hardware-informed scenario;
- the upper-bound hardware-informed scenario.

The current raw event ledger identifies the dominant source as:

`fixed-point arithmetic volume`

plus:

`trigonometric lookup volume`

This is the current implementation-mapping evidence.

The next architecture layer can use this evidence to target implementation realization, arithmetic structure, lookup structure, scheduling, data movement, and execution semantics with direct before-and-after benchmark comparison.

## 50. Interpretation of Current FRP Route and Coherence Results

The same canonical FRP row records:

`semantic_output_match = 1.0`

`semantic_completion_ratio = 1.0`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`pending_route_count_final = 0`

`global_phase_coherence_final = 0.9999997103586793`

`C_minus_P_min = 0.856201171875`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The current benchmark evidence therefore records both:

`high current implementation-mapping activity cost`

and:

`preserved FRP computational invariants under the canonical workload`

These are simultaneous properties of the current M15 quantized-shadow result.

## 51. Benchmark Evidence Hierarchy

Use the following evidence hierarchy.

### Processor behavior

Use:

- `../frp_prototype_v1_7_0.py`;
- structured demo output;
- self-test output;
- full traces.

### M15 implementation-mapping position

Use:

- M15 benchmark matrix;
- ten M15 export schemas;
- qualification closure manifest.

### Comparative architecture result

Use:

- `../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`.

### Hardware-sensitivity result

Use:

- `../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`.

### Workflow qualification

Use:

- comparative architecture workflow;
- hardware-sensitivity profile workflow;
- hardware-sensitivity comparison workflow.

### Release evidence

Use:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

## 52. Benchmark Reproduction Path

From the repository root, enter:

    cd benchmarks/architecture_comparison

Run common self-tests:

    python common_workload.py --self-test --output text

    python common_cost_model.py --self-test --output text

    python common_thermal_model.py --self-test --output text

Run architecture self-tests:

    python binary_synchronous_reference.py --self-test --output text

    python binary_clock_gated_reference.py --self-test --output text

    python direct_ternary_reference.py --self-test --output text

    python frp_v1_7_0_adapter.py --self-test --output text

Run the end-to-end comparison self-test:

    python run_architecture_comparison.py --self-test --output text

Generate the canonical package and an independent repeat as shown in Section 41.

Required deterministic result:

`byte-identical equality`

## 53. Hardware-Sensitivity Reproduction Path

From:

`benchmarks/architecture_comparison/`

validate the profile:

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --output text

Run the validator self-test:

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output text

Run the sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output json

Generate the canonical sensitivity result:

    python run_hardware_sensitivity_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write results/reference_comparison_seed_76_hardware_sensitivity_v1.json \
      --output text

Generate an independent repeat and compare both result files byte-for-byte.

## 54. Current Root README Validation Context

The root `README.md` exposes current `passing` badges for:

- `FRP Hardware Sensitivity Profile Qualification`;
- `FRP Hardware Sensitivity Comparison`.

The root `README.md` also exposes the complete active M3-M15 milestone validation chain together with:

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

The comparative architecture suite remains part of the 19-file GitHub Actions workflow inventory.

## 55. Current Benchmark Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current M15 benchmark matrix:

`5 implementation-mapping rows`

Current comparative architecture set:

`4 architecture references`

Current canonical semantic workload:

`256 commands, 16 cells, seed 76, transaction_serial`

Current canonical comparative package:

`PASS`

Current canonical hardware-sensitivity package:

`PASS`

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

Current FRP comparative route invariant:

`actual_direct_events = 0`

Current FRP comparative minimum dynamic stability:

`C_minus_P_min = 0.856201171875`

Current FRP comparative final phase coherence:

`global_phase_coherence_final = 0.9999997103586793`

Current base-profile interpretation:

`the FRP v1.7.0 quantized hardware shadow records the highest declared normalized activity cost and thermal-proxy response in the canonical unit-event comparison`

Current hardware-sensitivity interpretation:

`the FRP v1.7.0 quantized hardware shadow records the highest declared normalized cost across lower_bound, nominal, and upper_bound scenarios, with cost concentration dominated by fixed-point arithmetic and trigonometric lookup activity`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

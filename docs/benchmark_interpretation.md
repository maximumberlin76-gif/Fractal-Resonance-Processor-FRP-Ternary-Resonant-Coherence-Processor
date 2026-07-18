# Benchmark Interpretation — Fractal Resonance Processor (FRP)

**Ternary Fractal Resonant Coherence Processor — Benchmark and Qualification Evidence**

This document records the benchmark contours, comparative architecture contracts, measured results, normalized activity-cost data, thermal-proxy data, hardware-sensitivity data, and qualification evidence published in the Fractal Resonance Processor (FRP) repository.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified M3 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current comparative architecture schema:

`frp.benchmark.architecture_comparison.v1`

Current hardware-sensitivity comparison schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Inherited M15 semantic and implementation-mapping foundation:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

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

Current comparative architecture workflow:

`../.github/workflows/frp-architecture-comparison.yml`

Current hardware-sensitivity profile workflow:

`../.github/workflows/frp-hardware-sensitivity-profile.yml`

Current hardware-sensitivity comparison workflow:

`../.github/workflows/frp-hardware-sensitivity-comparison.yml`

Inherited M15 validation result:

`PASS`

Inherited M15 self-test result:

`41 / 41 PASS`

Current canonical comparative package qualification status:

`PASS`

Current canonical hardware-sensitivity package qualification status:

`PASS`

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

Current release qualification state:

`FRP v1.8.0 / M16 — PASS`

## 1. Benchmark Interpretation Role

The current repository contains six distinct benchmark and qualification contours:

1. the qualified FRP v1.7.0 executable semantic-reference contour;
2. the qualified M15 implementation-mapping benchmark matrix;
3. the Comparative Architecture Benchmark Suite;
4. the Hardware-Informed Sensitivity Qualification layer;
5. the M16 RTL execution qualification contour;
6. the M16 FPGA preparation qualification contour.

The qualified executable semantic-reference contour records processor state, scheduler state, route state, phase state, coherence quantities, thermal state, stability quantities, structured output, and kernel invariants.

The M15 benchmark matrix records the implementation-mapping progression from the M14 floating semantic reference through M15 qualification closure.

The Comparative Architecture Benchmark Suite applies one deterministic semantic workload to four architecture references and records architecture-specific event traces under shared comparison models.

The hardware-informed sensitivity layer applies three globally shared coefficient scenarios to the same recorded raw architecture execution results.

The M16 RTL qualification contour records executable SystemVerilog realization, architectural simulation, assertion execution, scheduler execution, request-lane arbitration, active-neutral routing, retained pending-route completion, transition-capacity enforcement, retained-state writeback, and ten integrated invariant flags.

The M16 FPGA preparation qualification contour records FPGA integration-top elaboration, executable FPGA integration-testbench execution, asynchronous reset assertion, two-stage synchronous reset release, `core_ready`, execution-input gating, scheduler propagation, request-interface propagation, active-neutral route execution, retained pending-route completion, event counters, and ten integrated invariant flags.

The benchmark evidence chain is:

`qualified executable semantic reference`

↓

`raw state, route, phase, coherence, thermal, and stability records`

↓

`M15 implementation-mapping matrix`

↓

`common semantic workload`

↓

`architecture-specific execution`

↓

`raw event counters`

↓

`shared normalized activity-cost profile`

↓

`shared thermal-proxy profile`

↓

`hardware-informed coefficient scenarios`

↓

`machine-readable benchmark packages`

The M16 implementation qualification chain is:

`qualified M15 semantic and implementation-mapping foundation`

↓

`executable M16 SystemVerilog RTL core`

↓

`architectural simulation`

↓

`assertion execution`

↓

`ten integrated invariant flags`

↓

`M16 RTL qualification closure`

↓

`target-independent FPGA integration top`

↓

`executable FPGA integration testbench`

↓

`reset, readiness, scheduler, request, route, and writeback validation`

↓

`M16 FPGA preparation qualification closure`

The Comparative Architecture Benchmark Suite uses:

`frp_v1_7_0_quantized_shadow`

The M16 RTL and FPGA preparation results are recorded in separate qualification contours.

## 2. FRP Computational Subject

FRP is a Ternary Fractal Resonant Coherence Processor.

Its computational mechanism combines:

- Kuramoto-Sakaguchi resonant phase coupling;
- asymmetric phase lag `gamma`;
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

The Comparative Architecture Benchmark Suite records the execution activity produced by the qualified FRP v1.7.0 M15 quantized hardware-shadow reference.

The M16 qualification layer records the executable RTL realization of the qualified M15 semantic and implementation-mapping foundation.

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

Inherited qualified M15 invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The canonical comparative FRP result records:

`requested_direct_events = 125`

`prevented_direct_events = 125`

`neutral_insertions = 125`

`neutral_routed_events = 125`

`neutralized_conflicts = 125`

`pending_route_count_final = 0`

`pending_route_peak = 1`

These values are recorded for the FRP quantized hardware-shadow reference under the canonical 256-command comparative workload.

The qualified M16 RTL execution records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The qualified M16 FPGA preparation execution records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The qualified M16 integrated invariant vector is:

`1111111111`

## 4. Current Benchmark Layers

### 4.1 Qualified structured execution

Command from the repository root:

    python frp_prototype_v1_7_0.py --mode demo --output json

Primary records:

- processor configuration;
- scheduler counts;
- balanced ternary state-domain validity;
- direct-event counter;
- reserved-state counter;
- queue-overflow counter;
- switch-load peak;
- dynamic stability minimum;
- fixed-point topology exactness;
- fixed-point thermal exactness.

### 4.2 Qualified M15 benchmark matrix

Command from the repository root:

    python frp_prototype_v1_7_0.py --mode benchmark

Equivalent export:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

Primary records:

- implementation-mapping progression;
- M15 reference layers;
- qualification-closure position.

### 4.3 Comparative Architecture Benchmark Suite

Directory:

`../benchmarks/architecture_comparison/`

Schema:

`frp.benchmark.architecture_comparison.v1`

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Primary records:

- common deterministic semantic workload;
- architecture-specific raw traces;
- common event taxonomy;
- shared normalized activity-cost profile;
- shared thermal-proxy profile;
- deterministic package integrity.

### 4.4 Hardware-Informed Sensitivity Qualification

Schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Scenarios:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Primary records:

- calibration contract;
- coefficient provenance map;
- literature-anchored sensitivity profile;
- lower-bound scenario;
- nominal scenario;
- upper-bound scenario;
- ranking-stability matrix;
- deterministic package integrity.

### 4.5 M16 RTL qualification

Workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Qualified SystemVerilog artifact count:

`10`

Qualified RTL documentation artifact count:

`5`

Qualified RTL testbench profile:

| Quantity | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| recorded ticks | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Qualification result:

`SUCCESS`

Closure status:

`M16 RTL EXECUTION LAYER CLOSED`

### 4.6 M16 FPGA preparation qualification

Workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Qualified FPGA SystemVerilog artifact count:

`2`

Qualified FPGA documentation artifact count:

`2`

Qualified FPGA integration-testbench profile:

| Quantity | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| recorded ticks | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Qualification result:

`SUCCESS`

Closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## 5. Current M15 Benchmark Matrix

The qualified M15 benchmark matrix contains five rows.

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

The recorded implementation-mapping chain is:

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

The five rows record the M15 processor architecture across the implementation-mapping and qualification layers.

M16 retains this qualified matrix as its semantic and implementation-mapping foundation.

## 6. Comparative Architecture Set

Directory:

`../benchmarks/architecture_comparison/`

The comparative suite contains four architecture references.

| Architecture identifier | Recorded architecture role |
|---|---|
| `binary_synchronous_reference` | globally clocked binary reference |
| `binary_clock_gated_reference` | clock-gated binary reference |
| `direct_ternary_reference` | direct ternary state-transition reference |
| `frp_v1_7_0_quantized_shadow` | qualified FRP v1.7.0 M15 quantized hardware-shadow reference |

Every architecture receives the same ordered semantic command list.

Every architecture executes the workload independently.

Every architecture records raw activity through one common event taxonomy.

Every architecture is evaluated through the same unit-event cost profile and the same thermal-proxy profile.

The Comparative Architecture Benchmark Suite and the M16 RTL and FPGA preparation qualification contours retain separate result packages.

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

Recorded canonical architecture-specific metric:

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

Recorded canonical architecture-specific metrics:

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

`POSITIVE_TARGET → 1`

Opposite semantic targets are applied through direct polarity changes.

Recorded canonical architecture-specific metrics:

`direct_opposite_polarity_changes = 122`

`neutral_state_exits = 16`

`gated_cycles = 150`

This reference records the direct ternary state-transition comparison path.

## 10. FRP v1.7.0 Quantized Hardware-Shadow Reference

Identifier:

`frp_v1_7_0_quantized_shadow`

Reference source:

`../frp_prototype_v1_7_0.py`

Semantic and implementation-mapping layer:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The comparative adapter uses the qualified M15 quantized hardware-shadow execution path.

State domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Qualified route invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Qualified fixed-point invariants:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

Recorded canonical final phase-coherence value:

`global_phase_coherence_final = 0.9999997103586793`

Recorded canonical minimum dynamic stability:

`C_minus_P_min = 0.856201171875`

Recorded canonical final dynamic stability:

`C_minus_P_final = 1.2415313720703125`

Recorded canonical route values:

| Quantity | Value |
|---|---:|
| `requested_direct_events` | `125` |
| `prevented_direct_events` | `125` |
| `actual_direct_events` | `0` |
| `neutral_insertions` | `125` |
| `neutral_routed_events` | `125` |
| `neutralized_conflicts` | `125` |
| `pending_route_count_final` | `0` |
| `pending_route_peak` | `1` |

The FRP comparative row contains:

- semantic completion records;
- retained-state records;
- route-event records;
- phase-coherence records;
- fixed-point exactness records;
- dynamic-stability records;
- raw event totals;
- normalized activity-cost records;
- thermal-proxy records.

The M16 RTL and FPGA preparation qualification results are recorded through their separate M16 qualification contours.

## 11. Canonical Semantic Workload

Canonical workload profile:

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

- `command_index`;
- `cell_id`;
- `semantic_target`.

Canonical workload digest:

`8386174d0a4751af26cc68bf46a5494cf0e58a3c14fc59ff46830a21645f0562`

All four architecture results carry the same workload digest.

The architecture identifiers are:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

## 12. Transaction-Serial Execution Policy

For each architecture, the canonical profile performs:

1. read the next semantic command;
2. issue the command;
3. execute architecture cycles until semantic completion;
4. record command latency;
5. proceed to the next command;
6. execute the fixed final cooldown period after the final command.

Each architecture processes the same command order.

Each architecture records its own completion timing.

The recorded timing fields are:

- `completion_ticks`;
- `mean_latency_ticks`;
- `p95_latency_ticks`;
- `maximum_latency_ticks`;
- `throughput_commands_per_tick`.

The common semantic command count is:

`256`

The final cooldown cycle count is:

`32`

## 13. Semantic Completion Rule

Binary completion:

`NEGATIVE_TARGET → state 0`

`POSITIVE_TARGET → state 1`

Direct ternary completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state 1`

FRP completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state 1`

For an FRP opposite-polarity retained-state migration, active neutral state `0` is the intermediate execution state.

The retained-state routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

FRP command completion occurs when the retained target polarity is applied.

The canonical result records:

`semantic_completion_ratio = 1.0`

for all four architecture references.

The canonical result records:

`semantic_output_match = 1.0`

for all four architecture references.

## 14. Common State Encodings

Binary encoding:

`0 → 1'b0`

`1 → 1'b1`

Direct ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`1 → 2'b01`

FRP v1.7.0 encoding:

`-1 → 2'b11`

`0 → 2'b00`

`1 → 2'b01`

Reserved FRP encoding:

`2'b10`

The suite records the following as distinct metrics:

`logical_state_changes`

`encoded_bit_toggles`

The qualified M15 result records:

`reserved_state_events = 0`

The qualified M16 RTL result records:

`reserved_state_events = 0`

The qualified M16 FPGA preparation result records:

`reserved_state_events = 0`

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

The shared result structure records the architecture-specific values for each event class.

Architecture-specific metrics are recorded separately from the common event-counter set.

The common event totals are retained independently from:

- normalized activity-cost totals;
- thermal-proxy traces;
- semantic completion values;
- architecture-specific route metrics;
- processor-specific coherence and stability quantities.

## 16. Common Unit-Event Cost Profile

Canonical base profile:

`unit_event_cost_v1`

Cost unit:

`normalized_activity_unit`

Every supported event class has coefficient:

`1.0`

The canonical profile records the event stream under a uniform event-counting scale.

The package field for the summed normalized activity value is:

`total_normalized_energy`

Its declared unit is:

`normalized_activity_unit`

The per-command field is:

`normalized_energy_per_completed_command`

The profile also records:

- `peak_cycle_normalized_energy`;
- `cycle_normalized_energy_sha256`;
- `cost_contribution_totals`;
- `event_totals`.

Canonical cost-profile digest:

`4c4a470150ecc182c9a51eaefc0bcba0353e71160d16c6c6afd28a39c23b05bc`

## 17. Common Thermal Proxy

Canonical thermal profile:

`common_rc_thermal_proxy_v1`

Temperature unit:

`normalized_temperature_proxy`

Canonical parameters:

| Parameter | Value |
|---|---:|
| ambient temperature proxy | `0.0` |
| thermal decay | `0.95` |
| thermal gain | `0.01` |

Canonical thermal-profile digest:

`8cc2992f5699c47c88e81c17a4a5f0c8ff5bb7a5b32ebf73ab0e5a0f9c5494c8`

The same recurrence and parameter set are applied to the normalized activity stream of every architecture reference.

The thermal-proxy record contains:

- `profile_name`;
- `temperature_unit`;
- `thermal_profile_sha256`;
- `peak_temperature_proxy`;
- `final_temperature_proxy`;
- `temperature_proxy_trace_sha256`.

The thermal-proxy quantities and raw operation-count quantities remain separate fields in the canonical package.

## 18. Canonical Comparative Result

Canonical result file:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Schema:

`frp.benchmark.architecture_comparison.v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Integrity status:

`PASS`

Qualification status:

`PASS`

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

Architecture count:

`4`

Semantic command count:

`256`

Workload seed:

`76`

The package records:

- workload configuration and digest;
- architecture-specific execution results;
- comparison metrics;
- raw event totals;
- normalized activity-cost values;
- normalized activity-cost contribution totals;
- thermal-proxy values;
- trace digests;
- integrity checks;
- qualification status.

## 19. Canonical Comparative Matrix

| Architecture | Completion ticks | Mean latency | Throughput | Total normalized activity cost | Cost per command | Peak temperature proxy | Final temperature proxy |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_synchronous_reference` | `288` | `1.0` | `0.8888888888888888` | `5412.0` | `21.140625` | `3.8474206768140564` | `3.479815488235824` |
| `binary_clock_gated_reference` | `288` | `1.0` | `0.8888888888888888` | `934.0` | `3.6484375` | `0.771273768299779` | `0.3003540042045561` |
| `direct_ternary_reference` | `288` | `1.0` | `0.8888888888888888` | `1242.0` | `4.8515625` | `1.119499710224827` | `0.3414291661285317` |
| `frp_v1_7_0_quantized_shadow` | `413` | `1.48828125` | `0.6198547215496368` | `1393509.0` | `5443.39453125` | `675.0796999541329` | `673.7075352972579` |

All four architecture references record:

`semantic_completion_ratio = 1.0`

All four architecture references record:

`semantic_output_match = 1.0`

The matrix contains separate fields for:

- completion timing;
- command latency;
- throughput;
- raw event totals;
- total normalized activity cost;
- normalized activity cost per completed command;
- peak normalized temperature proxy;
- final normalized temperature proxy.

The matrix uses the `unit_event_cost_v1` profile and the `common_rc_thermal_proxy_v1` profile.

## 20. Binary Synchronous Result Interpretation

Recorded canonical values:

| Quantity | Value |
|---|---:|
| `semantic_commands_issued` | `256` |
| `semantic_commands_completed` | `256` |
| `processor_cycles` | `288` |
| `active_clocked_cycles` | `288` |
| `active_clock_fraction` | `1.0` |
| `logical_state_changes` | `130` |
| `encoded_bit_toggles` | `130` |
| `clocked_state_bits` | `4608` |
| `register_write_bits` | `130` |
| `comparison_events` | `256` |
| `control_events` | `288` |
| `total_normalized_energy` | `5412.0` |
| `normalized_energy_per_completed_command` | `21.140625` |
| `peak_cycle_normalized_energy` | `20.0` |
| `peak_temperature_proxy` | `3.8474206768140564` |
| `final_temperature_proxy` | `3.479815488235824` |

Architecture-specific metric:

`direct_binary_switches = 130`

Semantic completion ratio:

`1.0`

Semantic output match:

`1.0`

## 21. Binary Clock-Gated Result Interpretation

Recorded canonical values:

| Quantity | Value |
|---|---:|
| `semantic_commands_issued` | `256` |
| `semantic_commands_completed` | `256` |
| `processor_cycles` | `288` |
| `active_clocked_cycles` | `130` |
| `active_clock_fraction` | `0.4513888888888889` |
| `logical_state_changes` | `130` |
| `encoded_bit_toggles` | `130` |
| `clocked_state_bits` | `130` |
| `register_write_bits` | `130` |
| `comparison_events` | `256` |
| `control_events` | `288` |
| `total_normalized_energy` | `934.0` |
| `normalized_energy_per_completed_command` | `3.6484375` |
| `peak_cycle_normalized_energy` | `5.0` |
| `peak_temperature_proxy` | `0.771273768299779` |
| `final_temperature_proxy` | `0.3003540042045561` |

Architecture-specific metrics:

`direct_binary_switches = 130`

`gated_cycles = 158`

`clock_gate_active_fraction = 0.4513888888888889`

Semantic completion ratio:

`1.0`

Semantic output match:

`1.0`

## 22. Direct Ternary Result Interpretation

Recorded canonical values:

| Quantity | Value |
|---|---:|
| `semantic_commands_issued` | `256` |
| `semantic_commands_completed` | `256` |
| `processor_cycles` | `288` |
| `active_clocked_cycles` | `138` |
| `active_clock_fraction` | `0.4791666666666667` |
| `logical_state_changes` | `138` |
| `encoded_bit_toggles` | `146` |
| `clocked_state_bits` | `276` |
| `register_write_bits` | `276` |
| `comparison_events` | `256` |
| `control_events` | `288` |
| `total_normalized_energy` | `1242.0` |
| `normalized_energy_per_completed_command` | `4.8515625` |
| `peak_cycle_normalized_energy` | `8.0` |
| `peak_temperature_proxy` | `1.119499710224827` |
| `final_temperature_proxy` | `0.3414291661285317` |

Architecture-specific metrics:

`direct_opposite_polarity_changes = 122`

`neutral_state_exits = 16`

`gated_cycles = 150`

Semantic completion ratio:

`1.0`

Semantic output match:

`1.0`

The recorded direct ternary execution applies opposite-polarity targets directly.

## 23. FRP Quantized-Shadow Result Interpretation

Recorded canonical values:

| Quantity | Value |
|---|---:|
| `semantic_commands_issued` | `256` |
| `semantic_commands_completed` | `256` |
| `processor_cycles` | `413` |
| `active_clocked_cycles` | `413` |
| `active_clock_fraction` | `1.0` |
| `logical_state_changes` | `261` |
| `encoded_bit_toggles` | `392` |
| `mean_latency_ticks` | `1.48828125` |
| `p95_latency_ticks` | `2.0` |
| `maximum_latency_ticks` | `2` |
| `throughput_commands_per_tick` | `0.6198547215496368` |
| `total_normalized_energy` | `1393509.0` |
| `normalized_energy_per_completed_command` | `5443.39453125` |
| `peak_temperature_proxy` | `675.0796999541329` |
| `final_temperature_proxy` | `673.7075352972579` |
| `global_phase_coherence_final` | `0.9999997103586793` |
| `C_minus_P_min` | `0.856201171875` |
| `C_minus_P_final` | `1.2415313720703125` |
| `actual_direct_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The FRP quantized hardware-shadow raw event record contains:

- fixed-point multiplication events;
- fixed-point accumulation events;
- fixed-point addition events;
- fixed-point comparison events;
- trigonometric lookup events;
- hierarchy activity;
- queue reads;
- queue writes;
- thermal-field activity;
- coherence activity;
- retained-state transition activity.

Semantic completion ratio:

`1.0`

Semantic output match:

`1.0`

Reference layer:

`FRP v1.7.0 / M15 quantized hardware shadow`

Current M16 relationship:

`qualified M15 semantic and implementation-mapping foundation → executable M16 RTL realization`

## 24. FRP Raw Activity Concentration

Recorded FRP dominant event totals:

| Event class | Count |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Additional recorded FRP raw event totals:

| Event class | Count |
|---|---:|
| `clocked_state_bits` | `13216` |
| `comparison_events` | `5904` |
| `control_events` | `413` |
| `register_write_bits` | `522` |
| `encoded_bit_toggles` | `392` |
| `logical_state_changes` | `261` |
| `queue_reads` | `125` |
| `queue_writes` | `125` |

Recorded semantic totals:

| Event class | Count |
|---|---:|
| `semantic_commands_issued` | `256` |
| `semantic_commands_completed` | `256` |

Recorded route totals:

| Quantity | Value |
|---|---:|
| `requested_direct_events` | `125` |
| `prevented_direct_events` | `125` |
| `actual_direct_events` | `0` |
| `neutral_insertions` | `125` |
| `neutral_routed_events` | `125` |
| `neutralized_conflicts` | `125` |
| `pending_route_count_final` | `0` |
| `pending_route_peak` | `1` |
| `queue_overflow_events` | `0` |
| `reserved_state_events` | `0` |

These values are the raw event totals recorded for:

`frp_v1_7_0_quantized_shadow`

under the canonical 256-command workload.

## 25. Latency Interpretation

Recorded canonical mean latency:

| Architecture | Mean latency ticks |
|---|---:|
| `binary_synchronous_reference` | `1.0` |
| `binary_clock_gated_reference` | `1.0` |
| `direct_ternary_reference` | `1.0` |
| `frp_v1_7_0_quantized_shadow` | `1.48828125` |

Recorded canonical p95 latency:

| Architecture | P95 latency ticks |
|---|---:|
| `binary_synchronous_reference` | `1.0` |
| `binary_clock_gated_reference` | `1.0` |
| `direct_ternary_reference` | `1.0` |
| `frp_v1_7_0_quantized_shadow` | `2.0` |

Recorded canonical maximum latency:

| Architecture | Maximum latency ticks |
|---|---:|
| `binary_synchronous_reference` | `1` |
| `binary_clock_gated_reference` | `1` |
| `direct_ternary_reference` | `1` |
| `frp_v1_7_0_quantized_shadow` | `2` |

The canonical workload records:

`requested_direct_events = 125`

The FRP quantized hardware-shadow row records:

`neutral_insertions = 125`

`neutral_routed_events = 125`

`actual_direct_events = 0`

The active-neutral retained-state routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

## 26. Throughput Interpretation

Throughput relation:

`throughput_commands_per_tick = semantic_commands_completed / completion_ticks`

Recorded canonical values:

| Architecture | Completed commands | Completion ticks | Throughput commands per tick |
|---|---:|---:|---:|
| `binary_synchronous_reference` | `256` | `288` | `0.8888888888888888` |
| `binary_clock_gated_reference` | `256` | `288` | `0.8888888888888888` |
| `direct_ternary_reference` | `256` | `288` | `0.8888888888888888` |
| `frp_v1_7_0_quantized_shadow` | `256` | `413` | `0.6198547215496368` |

Recorded relations:

`256 / 288 = 0.8888888888888888`

`256 / 413 = 0.6198547215496368`

Issue policy:

`transaction_serial`

Final cooldown cycles:

`32`

## 27. Semantic Output Interpretation

Recorded canonical result for every architecture:

`semantic_completion_ratio = 1.0`

Recorded canonical result for every architecture:

`semantic_output_match = 1.0`

Architecture records:

| Architecture | Semantic completion ratio | Semantic output match |
|---|---:|---:|
| `binary_synchronous_reference` | `1.0` | `1.0` |
| `binary_clock_gated_reference` | `1.0` | `1.0` |
| `direct_ternary_reference` | `1.0` | `1.0` |
| `frp_v1_7_0_quantized_shadow` | `1.0` | `1.0` |

Workload digest recorded by every architecture:

`8386174d0a4751af26cc68bf46a5494cf0e58a3c14fc59ff46830a21645f0562`

## 28. Route-Safety Interpretation

The canonical FRP result records:

| Quantity | Value |
|---|---:|
| `requested_direct_events` | `125` |
| `prevented_direct_events` | `125` |
| `neutral_insertions` | `125` |
| `neutral_routed_events` | `125` |
| `neutralized_conflicts` | `125` |
| `actual_direct_events` | `0` |
| `pending_route_count_final` | `0` |
| `pending_route_peak` | `1` |
| `queue_overflow_events` | `0` |
| `reserved_state_events` | `0` |

Recorded equality:

`requested_direct_events = prevented_direct_events = neutral_insertions = neutral_routed_events = neutralized_conflicts = 125`

Recorded zero-event relation:

`actual_direct_events = reserved_state_events = queue_overflow_events = 0`

Recorded final pending-route value:

`pending_route_count_final = 0`

The qualified M16 RTL execution also records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The qualified M16 FPGA preparation execution also records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## 29. Dynamic Stability Interpretation

Recorded FRP canonical minimum:

`C_minus_P_min = 0.856201171875`

Recorded FRP canonical final value:

`C_minus_P_final = 1.2415313720703125`

Recorded fixed-point representations:

`C_minus_P_min_q16 = 56112`

`C_minus_P_final_q16 = 81365`

Recorded relations:

`C_minus_P_min = 0.856201171875 > 0`

`C_minus_P_final = 1.2415313720703125 > 0`

Fixed-point conversion relations:

`56112 / 65536 = 0.856201171875`

`81365 / 65536 = 1.2415313720703125`

## 30. Phase-Coherence Interpretation

Recorded FRP canonical final value:

`global_phase_coherence_final = 0.9999997103586793`

Recorded fixed-point representation:

`global_phase_coherence_final_q30 = 1073741513`

Fixed-point scale:

`2^30 = 1073741824`

Recorded relation:

`1073741513 / 1073741824 = 0.9999997103586793`

The phase-coherence quantity is recorded separately from:

- Kuramoto order parameter `R`;
- endogenous structural coherence `C(t)`;
- generated-power quantity `P(t)`;
- dynamic-stability margin `C(t) - P(t)`.

## 31. Current Base-Profile Cost Interpretation

Base profile:

`unit_event_cost_v1`

Cost unit:

`normalized_activity_unit`

Coefficient assigned to every supported event class:

`1.0`

Recorded canonical total normalized activity-cost values:

| Architecture | Total normalized activity cost |
|---|---:|
| `binary_clock_gated_reference` | `934.0` |
| `direct_ternary_reference` | `1242.0` |
| `binary_synchronous_reference` | `5412.0` |
| `frp_v1_7_0_quantized_shadow` | `1393509.0` |

Recorded canonical ordering by:

`ascending_total_normalized_energy`

is:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded normalized activity cost per completed command:

| Architecture | Normalized activity cost per completed command |
|---|---:|
| `binary_clock_gated_reference` | `3.6484375` |
| `direct_ternary_reference` | `4.8515625` |
| `binary_synchronous_reference` | `21.140625` |
| `frp_v1_7_0_quantized_shadow` | `5443.39453125` |

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

## 32. Thermal-Proxy Interpretation

Thermal profile:

`common_rc_thermal_proxy_v1`

Temperature unit:

`normalized_temperature_proxy`

Recorded peak temperature-proxy values under the base unit-event profile:

| Architecture | Peak temperature proxy |
|---|---:|
| `binary_clock_gated_reference` | `0.771273768299779` |
| `direct_ternary_reference` | `1.119499710224827` |
| `binary_synchronous_reference` | `3.8474206768140564` |
| `frp_v1_7_0_quantized_shadow` | `675.0796999541329` |

Recorded ordering by ascending peak temperature proxy:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded final temperature-proxy values:

| Architecture | Final temperature proxy |
|---|---:|
| `binary_clock_gated_reference` | `0.3003540042045561` |
| `direct_ternary_reference` | `0.3414291661285317` |
| `binary_synchronous_reference` | `3.479815488235824` |
| `frp_v1_7_0_quantized_shadow` | `673.7075352972579` |

The canonical package records the following as separate layers:

`raw architecture event totals`

↓

`normalized activity-cost values`

↓

`common thermal-proxy values`

## 33. Hardware-Informed Sensitivity Layer

Profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

Profile schema:

`frp.benchmark.hardware_sensitivity_cost_profile.v1`

Profile role:

`hardware_informed_sensitivity`

Profile status:

`reference_sensitivity_profile`

Normalization reference primitive:

`32-bit integer addition`

Normalized reference weight:

`1.0`

Reference energy record:

`0.1 pJ`

Reference technology node record:

`45 nm`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Scenario count:

`3`

Coefficient count:

`12`

The sensitivity package records the following chain:

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

Profile-qualification workflow:

`../.github/workflows/frp-hardware-sensitivity-profile.yml`

Sensitivity-comparison workflow:

`../.github/workflows/frp-hardware-sensitivity-comparison.yml`

Baseline comparative result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

## 35. Global Sensitivity Scenarios

Recorded scenario order:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

The same global coefficient vector is applied to all four architecture results within each scenario.

The same recorded architecture results are used by every scenario.

The same raw event traces are used by every scenario.

The same workload digest is recorded across every scenario:

`8386174d0a4751af26cc68bf46a5494cf0e58a3c14fc59ff46830a21645f0562`

The same thermal-profile digest is recorded across every scenario:

`8cc2992f5699c47c88e81c17a4a5f0c8ff5bb7a5b32ebf73ab0e5a0f9c5494c8`

The scenario vectors are applied globally and exactly.

Scenario count:

`3`

Architecture count per scenario:

`4`

## 36. Canonical Hardware-Sensitivity Results

Cost unit:

`normalized_32bit_add_equivalent`

Recorded total normalized values:

| Scenario | Binary Synchronous | Binary Clock-Gated | Direct Ternary | FRP v1.7.0 Quantized Shadow |
|---|---:|---:|---:|---:|
| `lower_bound` | `181.078125` | `111.109375` | `118.078125` | `14457825.125` |
| `nominal` | `724.3125` | `444.4375` | `472.3125` | `25157118.0` |
| `upper_bound` | `4049.25` | `2929.75` | `3041.25` | `39955490.0` |

Recorded ranking basis:

`ascending_total_normalized_energy`

Recorded ranking in the `lower_bound` scenario:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded ranking in the `nominal` scenario:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded ranking in the `upper_bound` scenario:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

Recorded ties state:

`ties_present = false`

## 37. Sensitivity Result Interpretation

The canonical sensitivity package records the same architecture order for:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

The FRP raw event totals used in every scenario include:

| Event class | Count |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

The same architecture-result digests are recorded across all three scenarios.

The same raw-event-trace digests are recorded across all three scenarios.

The same semantic workload is recorded across all three scenarios.

The same thermal profile is recorded across all three scenarios.

Recorded integrity checks:

| Check | Result |
|---|---:|
| `all_scenario_integrity_pass` | `true` |
| `architecture_order_match` | `true` |
| `architecture_result_digests_match_baseline` | `true` |
| `baseline_package_contract_pass` | `true` |
| `current_execution_baseline_binding_pass` | `true` |
| `finite_numeric_values` | `true` |
| `pairwise_analysis_complete` | `true` |
| `profile_validation_pass` | `true` |
| `ranking_analysis_complete` | `true` |
| `same_architecture_result_digests_all_scenarios` | `true` |
| `same_raw_event_trace_digests_all_scenarios` | `true` |
| `same_thermal_profile_digest_all_scenarios` | `true` |
| `same_workload_digest` | `true` |
| `scenario_cost_profiles_unique` | `true` |
| `scenario_count_three` | `true` |
| `scenario_order_match` | `true` |
| `scenario_vectors_exact` | `true` |
| `winner_assertions_absent` | `true` |

## 38. Pairwise Stability Interpretation

The canonical sensitivity package contains six pairwise records.

Interpretation basis recorded in the package:

`left_architecture_total_normalized_energy_relative_to_right`

| Left architecture | Right architecture | Classification |
|---|---|---|
| `binary_synchronous_reference` | `binary_clock_gated_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `direct_ternary_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `direct_ternary_reference` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `direct_ternary_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |

Each pairwise record contains scenario relations for:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

The classification recorded for each pair remains identical across the three scenarios.

## 39. Canonical Hardware-Sensitivity Package

Result schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Profile schema:

`frp.benchmark.hardware_sensitivity_cost_profile.v1`

Profile name:

`literature_anchored_cmos45_sensitivity_v1`

Hardware-sensitivity profile digest:

`3814925a54d274bd43ab4576b6e60b53f60a2dfca9520d533ab49700c11dd553`

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Integrity status:

`PASS`

Qualification status:

`PASS`

Profile-validation status:

`PASS`

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

Ranking basis:

`ascending_total_normalized_energy`

Ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

Qualification checks include:

| Check | Result |
|---|---:|
| `all_architectures_completed_workload` | `true` |
| `frp_actual_direct_events_zero` | `true` |
| `frp_neutral_insertions_equal_neutral_routed` | `true` |
| `frp_pending_route_count_final_zero` | `true` |
| `frp_queue_overflow_events_zero` | `true` |
| `frp_requested_direct_events_equal_prevented` | `true` |
| `frp_reserved_state_events_zero` | `true` |
| `integrity_status_pass` | `true` |
| `no_winner_assertions` | `true` |
| `same_architecture_results_used_for_all_scenarios` | `true` |
| `same_raw_traces_used_for_all_scenarios` | `true` |
| `scenario_vectors_global_and_exact` | `true` |
| `semantic_completion_ratio_one_all` | `true` |
| `semantic_output_match_one_all` | `true` |

## 40. Comparative Architecture Qualification Contract

Workflow file:

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

Triggers:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

The workflow performs:

1. repository checkout;
2. Python setup;
3. execution-chain compilation;
4. workload-profile validation;
5. normalized cost-profile validation;
6. thermal-profile validation;
7. common-model self-tests;
8. architecture-reference self-tests;
9. FRP adapter self-test;
10. end-to-end comparison self-test;
11. canonical package generation;
12. independent package regeneration;
13. byte-identical package comparison;
14. package-integrity validation;
15. qualification-contract validation;
16. SHA-256 manifest generation;
17. artifact upload;
18. canonical result update on the `main` branch.

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical result schema:

`frp.benchmark.architecture_comparison.v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Qualification status:

`PASS`

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

Compare the canonical and independently regenerated packages:

    cmp \
      results/reference_comparison_seed_76.json \
      .qualification/reference_comparison_seed_76_repeat.json

Required deterministic result:

`byte-identical equality`

Canonical scheduler:

`7/1`

Canonical workload seed:

`76`

Canonical command count:

`256`

Canonical workload digest:

`8386174d0a4751af26cc68bf46a5494cf0e58a3c14fc59ff46830a21645f0562`

## 42. Hardware-Sensitivity Profile Qualification Contract

Workflow file:

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

Triggers:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

The workflow performs:

1. repository checkout;
2. Python setup;
3. profile-validator compilation;
4. canonical profile validation;
5. machine-readable validation capture;
6. validator self-test;
7. independent validation regeneration;
8. byte-identical validation comparison;
9. qualification-contract validation;
10. SHA-256 manifest generation;
11. artifact upload.

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Profile schema:

`frp.benchmark.hardware_sensitivity_cost_profile.v1`

Profile digest:

`3814925a54d274bd43ab4576b6e60b53f60a2dfca9520d533ab49700c11dd553`

Profile-validation status:

`PASS`

The workflow status badge is recorded in:

`../CI.md`

## 43. Hardware-Sensitivity Comparison Qualification Contract

Workflow file:

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

Triggers:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

The workflow performs:

1. repository checkout;
2. Python setup;
3. sensitivity execution-chain compilation;
4. canonical baseline checksum capture;
5. hardware-sensitivity profile validation;
6. profile-validator self-test;
7. sensitivity-runner self-test;
8. canonical sensitivity-result generation;
9. independent sensitivity-result regeneration;
10. byte-identical result comparison;
11. canonical baseline checksum verification;
12. sensitivity package-contract validation;
13. SHA-256 manifest generation;
14. artifact upload;
15. canonical sensitivity-result update on the `main` branch.

Canonical sensitivity result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Canonical result schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Qualification status:

`PASS`

The workflow status badge is recorded in:

`../CI.md`

## 44. Current Qualification Checks

The canonical comparative package validates:

| Check | Required result |
|---|---:|
| all architectures completed the workload | `true` |
| architecture order matches the contract | `true` |
| cost trace closes | `true` |
| thermal trace closes | `true` |
| numeric metrics remain finite | `true` |
| FRP actual direct-event count equals zero | `true` |
| FRP pending-route count finishes at zero | `true` |
| FRP queue-overflow count equals zero | `true` |
| FRP reserved-state count equals zero | `true` |
| all architectures share the workload digest | `true` |
| all architectures share the cost-profile digest | `true` |
| all architectures share the thermal-profile digest | `true` |
| semantic completion ratio equals one | `true` |
| semantic output match equals one | `true` |

The canonical hardware-sensitivity package additionally validates:

| Check | Required result |
|---|---:|
| three exact global scenario vectors | `true` |
| scenario order matches the profile | `true` |
| architecture-result digests match the baseline | `true` |
| the same architecture-result digests are used across all scenarios | `true` |
| raw-event traces remain identical across scenarios | `true` |
| workload digest remains identical across scenarios | `true` |
| thermal-profile digest remains identical across scenarios | `true` |
| pairwise analysis is complete | `true` |
| ranking analysis is complete | `true` |
| profile validator reports `PASS` | `true` |
| all scenario-integrity checks report `PASS` | `true` |
| winner assertions are absent | `true` |

Recorded comparative package integrity status:

`PASS`

Recorded hardware-sensitivity package integrity status:

`PASS`

## 45. Current Comparison Policy

Machine-readable policy identifier:

`integrity_only_no_winner_assertions`

Winner-assertion array:

`[]`

The qualification layer validates:

- shared workload input;
- shared workload digest;
- deterministic execution;
- exact profile binding;
- raw-event-trace closure;
- cost-cycle closure;
- thermal-cycle closure;
- finite numeric metrics;
- route invariants;
- semantic completion;
- semantic output match;
- package integrity;
- independent repeatability.

Canonical comparative qualification status:

`PASS`

Canonical hardware-sensitivity qualification status:

`PASS`

The measured matrices and machine-readable packages are retained as the published comparison records.

## 46. Historical v0.9.3 Transition Benchmark Contour

The repository preserves the v0.9.3 transition benchmark as a release-specific historical benchmark contour.

Historical executable:

`../frp_prototype_v0_9_3_mobile.py`

Historical test report:

`../TEST_REPORT_v0_9_3.md`

Historical release notes:

`../RELEASE_NOTES_v0_9_3.md`

Historical release checklist:

`../RELEASE_CHECKLIST_v0_9_3.md`

Historical benchmark command from the `docs/` directory:

    python3 ../frp_prototype_v0_9_3_mobile.py \
      --mode bench \
      --steps 128 \
      --seeds 5

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

The historical contour records:

- transition behavior;
- stability margin;
- historical heat metric;
- switching load;
- actual direct-event activity;
- prevented direct-event activity;
- neutralized conflict activity.

Historical workload parameters:

| Parameter | Value |
|---|---:|
| steps | `128` |
| seeds | `5` |

## 47. Historical v0.9.3 Result Record

| Architecture | Match | `C-P_min` | `heat_peak` | `switch_load_peak` | `actual_direct_events` | `prevented_direct_events` | `neutralized_conflicts` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

Recorded historical heat-peak relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded numerical representation:

`distributed_neutral_ternary heat_peak = 15.69× lower than binary_style_forced_switch heat_peak`

Recorded relative reduction:

`(0.051000 - 0.003250) / 0.051000 × 100 = 93.63%`

Recorded historical result:

`distributed_neutral_ternary heat_peak is 93.63% lower than binary_style_forced_switch heat_peak`

Recorded switch-load relation:

`1.000000 / 0.250000 = 4.0`

Recorded actual-direct-event values:

`binary_style_forced_switch actual_direct_events = 2052`

`direct_ternary_commit actual_direct_events = 2052`

`distributed_neutral_ternary actual_direct_events = 0`

`frp_distributed_resonant actual_direct_events = 0`

These values remain bound to the v0.9.3 transition benchmark model and its release-specific metrics.

## 48. Relationship Between the Historical and Current Contours

The historical v0.9.3 contour records:

- transition routing;
- stability margin;
- switching load;
- historical `heat_peak`;
- prevented direct-event activity;
- neutralized conflicts.

The qualified M15 comparative contour records:

- an identical semantic workload across four architecture references;
- architecture-specific execution timing;
- common state-encoding metrics;
- a common raw-event taxonomy;
- normalized activity-cost values;
- a common thermal proxy;
- deterministic package integrity;
- hardware-informed sensitivity;
- FRP route quantities;
- FRP phase-coherence quantities;
- FRP fixed-point quantities;
- FRP dynamic-stability quantities.

The current M16 qualification contours record:

- executable SystemVerilog RTL realization;
- scheduler execution;
- request-lane arbitration;
- active-neutral routing;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten integrated invariant flags;
- target-independent FPGA integration;
- reset and readiness behavior;
- FPGA integration-testbench execution.

The historical v0.9.3 transition benchmark uses:

`heat_peak`

The Comparative Architecture Benchmark Suite uses:

`normalized_activity_unit`

and:

`normalized_temperature_proxy`

The Hardware-Informed Sensitivity Qualification layer uses:

`normalized_32bit_add_equivalent`

The historical transition contour, comparative architecture contour, hardware-sensitivity contour, M16 RTL qualification contour, and M16 FPGA preparation contour retain separate result records.

## 49. Interpretation of Current FRP Comparative Cost

Comparative reference:

`frp_v1_7_0_quantized_shadow`

Base profile:

`unit_event_cost_v1`

Recorded base-profile total:

`total_normalized_energy = 1393509.0`

Recorded base-profile ranking basis:

`ascending_total_normalized_energy`

Recorded base-profile rank:

`4`

Recorded hardware-sensitivity totals:

| Scenario | `total_normalized_energy` | Recorded rank |
|---|---:|---:|
| `lower_bound` | `14457825.125` | `4` |
| `nominal` | `25157118.0` | `4` |
| `upper_bound` | `39955490.0` | `4` |

Recorded hardware-sensitivity ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

Recorded FRP raw event totals:

| Event class | Count |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

## 50. Interpretation of Current FRP Route and Coherence Results

The canonical FRP quantized hardware-shadow row records:

| Quantity | Value |
|---|---:|
| `semantic_output_match` | `1.0` |
| `semantic_completion_ratio` | `1.0` |
| `requested_direct_events` | `125` |
| `prevented_direct_events` | `125` |
| `neutral_insertions` | `125` |
| `neutral_routed_events` | `125` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `pending_route_count_final` | `0` |
| `global_phase_coherence_final` | `0.9999997103586793` |
| `C_minus_P_min` | `0.856201171875` |
| `C_minus_P_final` | `1.2415313720703125` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Recorded route relations:

`requested_direct_events = prevented_direct_events = neutral_insertions = neutral_routed_events = 125`

`actual_direct_events = reserved_state_events = queue_overflow_events = 0`

Recorded dynamic-stability relations:

`C_minus_P_min = 0.856201171875 > 0`

`C_minus_P_final = 1.2415313720703125 > 0`

The qualified M16 RTL execution records:

| Quantity | Value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| integrated invariant flags | `1111111111` |

The qualified M16 FPGA preparation execution records:

| Quantity | Value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| integrated invariant flags | `1111111111` |

## 51. Benchmark Evidence Hierarchy

### Qualified executable semantic reference

Evidence files and outputs:

- `../frp_prototype_v1_7_0.py`;
- structured demo output;
- structured self-test output;
- full processor-tick trace;
- per-cell trace;
- route-event trace.

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

### M15 semantic and implementation-mapping foundation

Evidence files and outputs:

- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- M15 benchmark matrix;
- ten M15 export schemas;
- deterministic cycle-exact reference trace;
- deterministic RTL comparison vectors;
- SystemVerilog interface map;
- synthesizable RTL reference-core map;
- assertion-correlation harness;
- reference-equivalence report;
- qualification-closure manifest.

Qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Qualification result:

`41 / 41 PASS`

### Comparative Architecture Benchmark Suite

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Schema:

`frp.benchmark.architecture_comparison.v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Qualification workflow:

`../.github/workflows/frp-architecture-comparison.yml`

Qualification result:

`PASS`

### Hardware-Informed Sensitivity Qualification

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Profile:

`literature_anchored_cmos45_sensitivity_v1`

Canonical package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Qualification workflows:

- `../.github/workflows/frp-hardware-sensitivity-profile.yml`;
- `../.github/workflows/frp-hardware-sensitivity-comparison.yml`.

Qualification result:

`PASS`

### M16 RTL execution qualification

Architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

Qualification documents:

- `./m16_rtl_artifact_boundary_qualification.md`;
- `./m16_invariant_assertion_set.md`;
- `./m16_qualification_index.md`;
- `./m16_qualification_manifest.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`.

Qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Qualified workflow run:

`#84`

Qualified source commit:

`ede53cf`

Result:

`SUCCESS`

Status:

`M16 RTL EXECUTION LAYER CLOSED`

### M16 FPGA preparation qualification

Qualification documents:

- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`.

Qualification workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Qualified workflow run:

`#2`

Qualified repository commit:

`ede53cf`

Result:

`SUCCESS`

Status:

`M16 FPGA PREPARATION LAYER CLOSED`

### Current release evidence

Release evidence files:

- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../RELEASE_CHECKLIST_v1_8_0.md`;
- `../README.md`;
- `../CI.md`;
- `../CHANGELOG.md`.

Current qualification state:

`FRP v1.8.0 / M16 — PASS`

## 52. Benchmark Reproduction Path

From the repository root, enter:

    cd benchmarks/architecture_comparison

Run the common workload self-test:

    python common_workload.py --self-test --output text

Run the common normalized cost-model self-test:

    python common_cost_model.py --self-test --output text

Run the common thermal-model self-test:

    python common_thermal_model.py --self-test --output text

Run the binary synchronous reference self-test:

    python binary_synchronous_reference.py --self-test --output text

Run the binary clock-gated reference self-test:

    python binary_clock_gated_reference.py --self-test --output text

Run the direct ternary reference self-test:

    python direct_ternary_reference.py --self-test --output text

Run the FRP v1.7.0 adapter self-test:

    python frp_v1_7_0_adapter.py --self-test --output text

Run the end-to-end comparative architecture self-test:

    python run_architecture_comparison.py --self-test --output text

Generate the canonical comparative package:

    python run_architecture_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --cost-profile profiles/normalized_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write results/reference_comparison_seed_76.json \
      --output text

Generate an independent repeat:

    mkdir -p .qualification

    python run_architecture_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --cost-profile profiles/normalized_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write .qualification/reference_comparison_seed_76_repeat.json \
      --output text

Compare both packages byte-for-byte:

    cmp \
      results/reference_comparison_seed_76.json \
      .qualification/reference_comparison_seed_76_repeat.json

Required deterministic result:

`byte-identical equality`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Qualification result:

`PASS`

## 53. Hardware-Sensitivity Reproduction Path

From:

`benchmarks/architecture_comparison/`

validate the hardware-sensitivity profile:

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --output text

Run the profile-validator self-test:

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output text

Run the hardware-sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output json

Generate the canonical hardware-sensitivity result:

    python run_hardware_sensitivity_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write results/reference_comparison_seed_76_hardware_sensitivity_v1.json \
      --output text

Generate an independent repeat:

    mkdir -p .qualification

    python run_hardware_sensitivity_comparison.py \
      --workload-profile profiles/workload_profile_v1.json \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --thermal-profile profiles/thermal_proxy_profile_v1.json \
      --frp-scheduler "7/1" \
      --write .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json \
      --output text

Compare both packages byte-for-byte:

    cmp \
      results/reference_comparison_seed_76_hardware_sensitivity_v1.json \
      .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json

Required deterministic result:

`byte-identical equality`

Canonical hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Qualification result:

`PASS`

## 54. Current Root README Validation Context

Current repository workflow-file count:

`23`

Current root `README.md` GitHub Actions workflow-status badge count:

`2`

The root `README.md` exposes workflow-status badges for:

- `FRP M16 RTL Artifact Boundary`;
- `FRP M16 FPGA Preparation`.

Current `CI.md` GitHub Actions workflow-status badge count:

`23`

The `CI.md` workflow-status badge set contains:

- `FRP M16 RTL Artifact Boundary`;
- `FRP M16 FPGA Preparation`;
- `FRP M16 Canonical Core Domain`;
- `FRP M16 Reserved Cell Cleanup`;
- `FRP M15 Implementation Mapping and Qualification Closure`;
- `FRP M14 Physical Implementation Correlation and Production Qualification`;
- `FRP M13 Production Scaling and Implementation Stabilization`;
- `FRP M12 External Implementation Feedback and Production Iteration`;
- `FRP M11 Production Integration and External Handoff`;
- `FRP M10 Silicon Production and Tapeout Readiness`;
- `FRP M9 Silicon and Heterogeneous Architecture`;
- `FRP M8 Production Release Package`;
- `FRP M7 FPGA Synthesis and Timing Scaffold`;
- `FRP M6 Formal Verification and Equivalence Scaffold`;
- `FRP M5 RTL Interface and Assertion Harness`;
- `FRP M4 HDL Trace and Testbench`;
- `FRP M3 Benchmark and Signal Map`;
- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`;
- `FRP Comparative Architecture Benchmark`;
- `FRP Hardware Sensitivity Profile Qualification`;
- `FRP Hardware Sensitivity Comparison`.

The root `README.md` also records:

| Qualification layer | Record |
|---|---|
| inherited M15 semantic and implementation-mapping foundation | `41 / 41 PASS` |
| M16 RTL workflow run | `#84` |
| M16 RTL qualified source commit | `ede53cf` |
| M16 RTL result | `SUCCESS` |
| M16 RTL status | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation workflow run | `#2` |
| M16 FPGA qualified repository commit | `ede53cf` |
| M16 FPGA result | `SUCCESS` |
| M16 FPGA status | `M16 FPGA PREPARATION LAYER CLOSED` |

## 55. Current Benchmark Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Fractal Resonant Coherence Processor`

Current release:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited semantic and implementation-mapping foundation:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited M15 self-test result:

`41 / 41 PASS`

Inherited M15 deterministic vector package:

`10 files`

Inherited M15 deterministic vector regeneration:

`10 / 10 files byte-identical`

Inherited M15 semantic correlation result:

`5 / 5 = 1.0`

Inherited M15 deterministic replay result:

`6 / 6 = 1.0`

Inherited M15 event results:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Inherited M15 fixed-point results:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

Qualified M15 benchmark matrix:

`5 implementation-mapping rows`

Comparative architecture set:

`4 architecture references`

Canonical semantic workload:

`256 commands, 16 cells, seed 76, transaction_serial`

Canonical comparative package:

| Field | Value |
|---|---|
| schema | `frp.benchmark.architecture_comparison.v1` |
| result | `PASS` |
| package digest | `5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a` |

Canonical hardware-sensitivity package:

| Field | Value |
|---|---|
| schema | `frp.benchmark.hardware_sensitivity_comparison.v1` |
| profile | `literature_anchored_cmos45_sensitivity_v1` |
| result | `PASS` |
| package digest | `a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0` |

Qualification policy:

`integrity_only_no_winner_assertions`

Winner assertions:

`[]`

Recorded hardware-sensitivity ranking state:

`ranking_stable = true`

`ranking_sensitive = false`

Recorded hardware-sensitivity ranking:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

Recorded FRP comparative route result:

`actual_direct_events = 0`

Recorded FRP comparative minimum dynamic stability:

`C_minus_P_min = 0.856201171875`

Recorded FRP comparative final dynamic stability:

`C_minus_P_final = 1.2415313720703125`

Recorded FRP comparative final phase coherence:

`global_phase_coherence_final = 0.9999997103586793`

Recorded historical v0.9.3 heat-peak relation:

`0.051000 / 0.003250 = 15.6923076923`

Recorded historical v0.9.3 numerical representation:

`distributed_neutral_ternary heat_peak = 15.69× lower than binary_style_forced_switch heat_peak`

Recorded historical v0.9.3 relative reduction:

`93.63% lower heat_peak`

Current M16 RTL qualification:

| Field | Value |
|---|---|
| workflow | `FRP M16 RTL Artifact Boundary` |
| workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| qualified workflow run | `#84` |
| qualified source commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| SystemVerilog artifacts | `10` |
| RTL documentation artifacts | `5` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |
| status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification:

| Field | Value |
|---|---|
| workflow | `FRP M16 FPGA Preparation` |
| workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| qualified workflow run | `#2` |
| qualified repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| FPGA SystemVerilog artifacts | `2` |
| FPGA documentation artifacts | `2` |
| `core_ready` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |
| status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current repository workflow-file count:

`23`

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current qualification state:

`FRP v1.8.0 / M16 — PASS`





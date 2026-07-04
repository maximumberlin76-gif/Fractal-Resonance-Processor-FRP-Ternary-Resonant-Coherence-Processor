# FRP Comparative Architecture Benchmark Suite

## Suite Scope

The FRP Comparative Architecture Benchmark Suite defines a deterministic, architecture-neutral comparison framework for evaluating the execution behavior of the current Fractal Resonance Processor reference architecture against explicit baseline architectures.

The suite is aligned with:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The comparison framework is additive.

It does not modify the validated M15 computational kernel, M15 schemas, M15 qualification workflow, or M15 release boundary.

The suite compares:

`Binary Synchronous Reference`

`Binary Clock-Gated Reference`

`Direct Ternary Reference`

`FRP v1.7.0 Quantized Hardware Shadow Reference`

The comparison is based on:

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

## Benchmark Role

The benchmark suite is designed to answer the following questions:

- how many processor cycles are required to complete the same ordered semantic workload;

- how many logical state transitions are produced;

- how many encoded state-bit toggles are produced;

- how much clock activity is generated;

- how many queue, lookup, multiplication, accumulation, comparison, and register-update events are generated;

- how much normalized activity cost is accumulated under one common cost profile;

- how the same normalized activity stream propagates through one common thermal proxy model;

- how architectural latency and throughput differ;

- which architectural mechanisms create measurable cost;

- which architectural mechanisms reduce or redistribute measurable cost;

- which FRP-specific invariants remain preserved during comparative execution.

The benchmark suite does not predetermine which architecture must produce the lowest energy proxy, temperature proxy, latency, or execution cost.

Comparison results are recorded as benchmark results.

## Fairness Principles

The benchmark suite uses the following non-negotiable comparison principles.

### Identical Semantic Workload

Every architecture receives the same ordered semantic command list.

The workload digest must be identical across all architecture runs.

### Architecture-Neutral Semantic Targets

The common workload uses:

`NEGATIVE_TARGET`

and:

`POSITIVE_TARGET`

The common semantic workload does not directly command the FRP neutral state.

The neutral state remains an internal FRP architectural mechanism.

### Architecture-Specific State Mapping

Binary references map:

`NEGATIVE_TARGET → 0`

`POSITIVE_TARGET → 1`

The Direct Ternary Reference maps:

`NEGATIVE_TARGET → -1`

`POSITIVE_TARGET → +1`

FRP v1.7.0 maps:

`NEGATIVE_TARGET → -1`

`POSITIVE_TARGET → +1`

FRP retains the active neutral state:

`0`

for tick-separated opposite-polarity routing.

### Independent Architecture Execution

Every architecture executes the same semantic command sequence independently.

Execution timing is measured independently for each architecture.

The command order remains identical.

### Common Cost Model

Architecture classes do not assign their own energy or thermal coefficients.

Every architecture emits raw event counts.

One shared normalized cost profile converts those event counts into normalized activity cost.

### Common Thermal Proxy Model

Every architecture uses the same thermal proxy equations and the same thermal parameters.

Architecture classes do not define their own thermal gain or thermal dissipation coefficients.

### Explicit Architecture Overhead

FRP phase, hierarchy, fixed-point, lookup-table, queue, thermal-field, and coherence operations must be represented in the event stream.

The comparison must not count only FRP state-transition advantages while omitting FRP computational overhead.

### No Winner Assertions

The qualification workflow must not contain assertions such as:

`FRP energy < binary energy`

`FRP temperature < binary temperature`

`FRP latency < binary latency`

The qualification workflow validates comparison integrity.

The measured result remains data.

## Architecture Set

The initial benchmark suite defines four architecture profiles.

## Binary Synchronous Reference

Identifier:

`binary_synchronous_reference`

State domain:

`0`

`1`

Semantic mapping:

`NEGATIVE_TARGET → 0`

`POSITIVE_TARGET → 1`

Opposite semantic targets may produce direct:

`0 → 1`

or:

`1 → 0`

The reference uses a globally clocked execution profile.

The event model records:

- semantic commands;

- state changes;

- encoded bit toggles;

- clocked cycles;

- clocked state bits;

- state register writes;

- comparison events;

- control events.

## Binary Clock-Gated Reference

Identifier:

`binary_clock_gated_reference`

State domain:

`0`

`1`

Semantic mapping:

`NEGATIVE_TARGET → 0`

`POSITIVE_TARGET → 1`

The logical transition behavior remains equivalent to the Binary Synchronous Reference.

The clock-activity model differs.

The clock-gated reference records clock activity only for the active architectural state domain defined by the benchmark implementation contract.

The comparison therefore distinguishes:

`binary state-transition behavior`

from:

`binary clock-distribution behavior`

The event model records:

- semantic commands;

- state changes;

- encoded bit toggles;

- total processor cycles;

- active clocked cycles;

- active clocked state bits;

- state register writes;

- comparison events;

- control events.

## Direct Ternary Reference

Identifier:

`direct_ternary_reference`

State domain:

`-1`

`0`

`1`

Semantic workload mapping:

`NEGATIVE_TARGET → -1`

`POSITIVE_TARGET → +1`

Opposite semantic targets are applied directly:

`-1 → +1`

`+1 → -1`

The neutral state exists in the state encoding but is not automatically inserted between opposite semantic targets.

The Direct Ternary Reference provides a comparison boundary between:

`ternary state representation`

and:

`FRP neutral-route execution semantics`

The event model records:

- semantic commands;

- state changes;

- encoded bit toggles;

- direct opposite-polarity changes;

- clocked cycles;

- clocked state bits;

- state register writes;

- comparison events;

- control events.

## FRP v1.7.0 Quantized Hardware Shadow Reference

Identifier:

`frp_v1_7_0_quantized_shadow`

Reference source:

`frp_prototype_v1_7_0.py`

The benchmark adapter must use the current M15 quantized hardware shadow execution path.

The benchmark adapter must not duplicate or reimplement the FRP kernel.

The FRP state domain remains:

`-1`

`0`

`1`

The active neutral state remains:

`0`

Validated opposite-polarity routes remain:

`-1 → 0 → +1`

`+1 → 0 → -1`

The tick-separated route remains:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

The FRP adapter must preserve:

`actual_direct_events = 0`

`reserved_state_events = 0`

The event model records:

- semantic commands;

- state changes;

- encoded bit toggles;

- neutral insertions;

- pending-route queue events;

- clocked cycles;

- clocked state bits;

- state register writes;

- trigonometric lookup events;

- fixed-point multiplication events;

- fixed-point accumulation events;

- comparison events;

- queue reads;

- queue writes;

- control events;

- FRP kernel counters;

- FRP stability telemetry.

## Common Semantic Workload

The first benchmark profile uses a deterministic ordered command list.

Default profile:

`num_cells = 16`

`command_count = 256`

`seed = 76`

Semantic target domain:

`NEGATIVE_TARGET`

`POSITIVE_TARGET`

Default issue policy:

`transaction_serial`

Maximum completion cycles per command:

`64`

Final cooldown cycles:

`32`

The workload generator creates records containing:

`command_index`

`cell_id`

`semantic_target`

The workload contains no architecture-specific state values.

The workload contains no architecture-specific timing coefficients.

The workload contains no architecture-specific energy coefficients.

## Transaction-Serial Execution Policy

The initial benchmark profile uses:

`transaction_serial`

For each architecture:

1. read the next semantic command;

2. issue the semantic command;

3. execute architecture cycles until the semantic target is complete;

4. record command latency;

5. proceed to the next semantic command;

6. execute the fixed final cooldown period after the final command.

Each architecture therefore receives the same ordered command list.

Each architecture measures its own completion time.

This permits direct comparison of:

`completion_ticks`

`mean_latency_ticks`

`p95_latency_ticks`

`maximum_latency_ticks`

`throughput_commands_per_tick`

## Semantic Completion Rule

A command is complete when the architecture-visible logical state of the selected cell matches the semantic target mapping.

Binary completion:

`NEGATIVE_TARGET → state 0`

`POSITIVE_TARGET → state 1`

Direct ternary completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state +1`

FRP completion:

`NEGATIVE_TARGET → state -1`

`POSITIVE_TARGET → state +1`

For FRP opposite-polarity migration, the intermediate neutral state does not complete the command.

The command completes only when the retained target polarity is applied on a subsequent processor tick.

## Workload Integrity

The generated semantic workload is serialized deterministically.

The suite records:

`workload_sha256`

Every architecture result must contain the same:

`workload_sha256`

The qualification workflow must fail when workload digests differ.

## Common State Encoding Profiles

The benchmark records encoded state-bit toggles separately from logical state changes.

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

The benchmark records:

`logical_state_changes`

and:

`encoded_bit_toggles`

as separate metrics.

## Common Raw Event Taxonomy

Every architecture emits a common event-counter object.

Required common event counters:

`semantic_commands_issued`

`semantic_commands_completed`

`processor_cycles`

`active_clocked_cycles`

`logical_state_changes`

`encoded_bit_toggles`

`clocked_state_bits`

`register_write_bits`

`comparison_events`

`control_events`

The normalized cost model additionally supports:

`queue_reads`

`queue_writes`

`lut_reads_32`

`fixed_point_multiplies_32x32`

`fixed_point_accumulates_64`

`fixed_point_adds_32`

`fixed_point_compares_32`

An architecture may legitimately emit zero for event classes it does not use.

The event schema remains common.

## Architecture-Specific Raw Metrics

The Binary Synchronous Reference records:

`direct_binary_switches`

The Binary Clock-Gated Reference records:

`direct_binary_switches`

`clock_gate_active_fraction`

The Direct Ternary Reference records:

`direct_opposite_polarity_changes`

The FRP v1.7.0 adapter records:

`requested_direct_events`

`prevented_direct_events`

`actual_direct_events`

`neutral_routed_events`

`neutralized_conflicts`

`neutral_insertions`

`pending_route_peak`

`queue_overflow_events`

`reserved_state_events`

`C_minus_P_min`

`C_minus_P_final`

`global_phase_coherence_final`

FRP-specific telemetry remains architecture-specific.

Binary and Direct Ternary references do not receive synthetic FRP `C(t)` or `C_minus_P` values.

## Common Normalized Cost Model

The benchmark suite uses one shared normalized cost profile.

Planned profile file:

`profiles/normalized_cost_profile_v1.json`

The cost model assigns a normalized cost to each declared event class.

Supported cost classes include:

`encoded_bit_toggle`

`clocked_state_bit`

`register_write_bit`

`comparison_event`

`control_event`

`queue_read`

`queue_write`

`lut_read_32`

`fixed_point_multiply_32x32`

`fixed_point_accumulate_64`

`fixed_point_add_32`

`fixed_point_compare_32`

For architecture a:

`normalized_cycle_cost_a(t) = sum_k(event_count_a,k(t) × normalized_cost_k)`

Cumulative normalized cost:

`total_normalized_energy = sum_t(normalized_cycle_cost(t))`

The term:

`normalized_energy`

is a benchmark activity metric.

The cost profile does not claim a fabricated physical joule value.

## Cost Profile Integrity

The suite records:

`cost_profile_sha256`

Every architecture result in one comparison package must use the same:

`cost_profile_sha256`

The qualification workflow must fail when cost-profile digests differ.

## Common Thermal Proxy Model

The benchmark suite uses one thermal proxy model for all architectures.

The architecture classes emit normalized activity cost.

The common thermal model converts the activity stream into a normalized thermal response.

Required common parameters:

`ambient_temperature_proxy`

`thermal_decay`

`thermal_gain`

For benchmark cycle t:

`temperature_proxy_next = ambient_temperature_proxy + (temperature_proxy - ambient_temperature_proxy) × thermal_decay + normalized_cycle_cost × thermal_gain`

The same equation and parameter values are used for every architecture.

The model reports:

`peak_temperature_proxy`

`final_temperature_proxy`

The temperature proxy is a normalized comparative metric.

## Common Comparison Metrics

Every architecture result records:

`architecture_id`

`workload_sha256`

`cost_profile_sha256`

`semantic_commands_issued`

`semantic_commands_completed`

`semantic_completion_ratio`

`semantic_output_match`

`completion_ticks`

`mean_latency_ticks`

`p95_latency_ticks`

`maximum_latency_ticks`

`throughput_commands_per_tick`

`logical_state_changes`

`encoded_bit_toggles`

`peak_cycle_normalized_energy`

`total_normalized_energy`

`normalized_energy_per_completed_command`

`peak_temperature_proxy`

`final_temperature_proxy`

`processor_cycles`

`active_clocked_cycles`

`active_clock_fraction`

## Semantic Output Match

The benchmark validates that every architecture completes the same semantic command sequence.

Required target:

`semantic_output_match = 1.000`

This metric compares semantic target completion.

It does not require internal state trajectories to match.

The internal execution mechanisms are intentionally different.

## Latency Metrics

Per-command latency is measured in architecture cycles.

Recorded metrics:

`mean_latency_ticks`

`p95_latency_ticks`

`maximum_latency_ticks`

FRP neutral routing may create multi-tick command completion.

The measured latency remains part of the comparison result.

The benchmark must not hide the latency cost of neutral routing.

## Throughput Metric

Throughput is:

`throughput_commands_per_tick = semantic_commands_completed / completion_ticks`

The same relation is used for every architecture.

## Transition Metrics

The benchmark distinguishes:

`semantic target changes`

`logical state changes`

`encoded bit toggles`

These metrics must not be merged into one number.

A single semantic command may create different internal transition paths in different architectures.

## Comparative Result Matrix

The machine-readable comparison output contains one row per architecture.

Required architecture order:

1. `binary_synchronous_reference`;

2. `binary_clock_gated_reference`;

3. `direct_ternary_reference`;

4. `frp_v1_7_0_quantized_shadow`.

The comparison matrix records measured metrics.

The matrix does not rewrite results into predetermined winner labels.

## Comparison Schema

Planned comparison schema:

`frp.benchmark.architecture_comparison.v1`

Required top-level fields:

`schema`

`suite_name`

`frp_reference_version`

`workload_profile`

`workload_sha256`

`cost_profile`

`cost_profile_sha256`

`architectures`

`comparison_matrix`

`integrity`

`qualification`

## Deterministic Execution

The benchmark suite must produce deterministic output from identical:

`FRP version`

`workload profile`

`workload seed`

`cost profile`

`architecture set`

Repeated execution must preserve:

`workload_sha256`

`cost_profile_sha256`

`architecture result ordering`

`raw event counts`

`comparison metrics`

`complete comparison package digest`

## No Winner Assertion Policy

The benchmark qualification workflow validates:

`same workload digest`

`same cost-profile digest`

`deterministic workload generation`

`deterministic architecture execution`

`all architectures completed workload`

`semantic_output_match = 1.000`

`finite metric values`

`valid schema`

`byte-identical repeated generation`

`FRP actual_direct_events = 0`

`FRP reserved_state_events = 0`

`FRP queue_overflow_events = 0`

The workflow does not validate:

`FRP total_normalized_energy < baseline total_normalized_energy`

The workflow does not validate:

`FRP peak_temperature_proxy < baseline peak_temperature_proxy`

The workflow does not validate:

`FRP latency < baseline latency`

The workflow does not validate:

`FRP throughput > baseline throughput`

Those values remain measured comparison results.

## Hardware-Informed Sensitivity Layer

The hardware-informed sensitivity layer is an additive comparison branch.

It does not replace:

`unit_event_cost_v1`

It does not replace the canonical unit-event result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

The canonical unit-event baseline remains bound to:

`comparison_package_sha256 = 5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

The hardware-informed sensitivity layer applies one literature-anchored cost profile to the same raw architecture execution results.

Profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

Profile role:

`hardware_informed_sensitivity`

Normalization reference:

`32-bit integer addition = 1.0`

Reference energy value:

`0.1 pJ`

Reference technology context:

`45 nm CMOS`

Primary literature anchor:

`Mark Horowitz, 1.1 Computing's Energy Problem (and What We Can Do About It), ISSCC 2014, DOI: 10.1109/ISSCC.2014.6757323`

The literature values are treated as rough technology-context anchors for sensitivity analysis.

They are not treated as universal physical constants.

### Calibration and Provenance Chain

The sensitivity layer is defined by:

`hardware cost calibration contract`

↓

`coefficient provenance map`

↓

`literature-anchored hardware sensitivity profile`

↓

`strict machine validator`

↓

`GitHub Actions profile qualification`

↓

`hardware sensitivity runner`

↓

`GitHub Actions comparison qualification`

↓

`canonical sensitivity result`

Calibration contract:

`benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md`

Coefficient provenance map:

`benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`

Sensitivity profile:

`benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`

Profile validator:

`benchmarks/architecture_comparison/validate_hardware_sensitivity_profile.py`

Sensitivity runner:

`benchmarks/architecture_comparison/run_hardware_sensitivity_comparison.py`

Canonical sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

### Global Scenario Contract

The scenario order is fixed:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

The same global scenario vector is applied to every architecture.

No architecture-specific coefficient vectors are permitted.

The same raw architecture results are used for all three scenarios.

The same raw event traces are used for all three scenarios.

The sensitivity layer therefore measures ranking response to declared coefficient uncertainty without changing architecture execution.

### Canonical Sensitivity Results

The ranking basis is:

`ascending_total_normalized_energy`

| Scenario | Binary Synchronous Reference | Binary Clock-Gated Reference | Direct Ternary Reference | FRP v1.7.0 Quantized Shadow |
|---|---:|---:|---:|---:|
| `lower_bound` | 181.078125 | 111.109375 | 118.078125 | 14457825.125 |
| `nominal` | 724.3125 | 444.4375 | 472.3125 | 25157118.0 |
| `upper_bound` | 4049.25 | 2929.75 | 3041.25 | 39955490.0 |

The ranking is identical in all three scenarios:

`binary_clock_gated_reference`

↓

`direct_ternary_reference`

↓

`binary_synchronous_reference`

↓

`frp_v1_7_0_quantized_shadow`

The canonical result records:

`ranking_stable = true`

`ranking_sensitive = false`

### Pairwise Stability Classification

The canonical result contains six pairwise stability relations.

| Left Architecture | Right Architecture | Classification |
|---|---|---|
| `binary_synchronous_reference` | `binary_clock_gated_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `direct_ternary_reference` | `stable_higher_cost` |
| `binary_synchronous_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `direct_ternary_reference` | `stable_lower_cost` |
| `binary_clock_gated_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |
| `direct_ternary_reference` | `frp_v1_7_0_quantized_shadow` | `stable_lower_cost` |

Every pairwise relation remains unchanged across:

`lower_bound`

`nominal`

`upper_bound`

### FRP Cost Concentration in the Current Sensitivity Model

The current M15 quantized shadow records the following raw event totals:

`fixed_point_multiplies_32x32 = 518728`

`lut_reads_32 = 172221`

`fixed_point_accumulates_64 = 296534`

`fixed_point_adds_32 = 339899`

`fixed_point_compares_32 = 45430`

The sensitivity result therefore identifies the current dominant declared cost concentration as:

`fixed-point arithmetic volume`

plus:

`trigonometric lookup volume`

This is a direct result of the current M15 quantized hardware shadow execution path under the declared event taxonomy and the declared global coefficient vectors.

The result is not a physical silicon energy measurement.

The result does not establish universal energy ordering between binary, ternary, and FRP hardware.

The result does establish that the current M15 quantized shadow produces the highest declared normalized activity cost in all three hardware-informed sensitivity scenarios.

This result is retained without coefficient adjustment and without winner assertions.

### Separation from the Original v0.9.3 Thermal Benchmark

The M15 Comparative Architecture Benchmark Suite and the original v0.9.3 benchmark are separate measurement contours.

The M15 suite compares:

`binary_synchronous_reference`

`binary_clock_gated_reference`

`direct_ternary_reference`

`frp_v1_7_0_quantized_shadow`

The original v0.9.3 benchmark separately compared:

`binary_style_forced_switch`

`direct_ternary_commit`

`distributed_neutral_ternary`

and the FRP model of that release.

In the canonical v0.9.3 benchmark table:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| `direct_ternary_commit` | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| `distributed_neutral_ternary` | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| `frp_distributed_resonant` | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

The lowest heat peak in that benchmark was produced by:

`distributed_neutral_ternary`

with:

`heat_peak = 0.003250`

and:

`switch_load_peak = 0.25`

The direct ternary commit path did not produce that advantage.

It matched the binary-style forced-switch result in the recorded benchmark table.

The measured distinction therefore belongs to the distributed neutral-transition architecture:

`active neutral state 0`

plus:

`prohibited direct polarity reversal`

plus:

`tick-separated neutral routing`

plus:

`distributed transition load`

The original benchmark result is preserved as a thermal-proxy result.

It is not replaced or invalidated by the M15 hardware-informed sensitivity result.

The M15 sensitivity result measures the declared event cost of the much larger quantized FRP execution stack, including phase, hierarchy, fixed-point arithmetic, lookup-table activity, queue activity, thermal-field computation, and coherence computation.

The two benchmark contours answer different questions and must not be merged into one ranking claim.

### Canonical Sensitivity Package Integrity

The canonical hardware sensitivity package records:

`hardware_sensitivity_package_sha256 = a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

The result preserves:

`same architecture results for all scenarios`

`same raw traces for all scenarios`

`global exact scenario vectors`

`semantic completion ratio = 1.000 for all architectures`

`semantic output match = 1.000 for all architectures`

`FRP actual_direct_events = 0`

`FRP reserved_state_events = 0`

`FRP queue_overflow_events = 0`

`winner_assertions = []`

The qualification role remains:

`integrity_only_no_winner_assertions`

## Planned File Set

Suite documentation:

`benchmarks/architecture_comparison/README.md`

Common semantic workload:

`benchmarks/architecture_comparison/common_workload.py`

Common normalized cost model:

`benchmarks/architecture_comparison/common_cost_model.py`

Common thermal proxy model:

`benchmarks/architecture_comparison/common_thermal_model.py`

Binary synchronous reference:

`benchmarks/architecture_comparison/binary_synchronous_reference.py`

Binary clock-gated reference:

`benchmarks/architecture_comparison/binary_clock_gated_reference.py`

Direct ternary reference:

`benchmarks/architecture_comparison/direct_ternary_reference.py`

FRP v1.7.0 adapter:

`benchmarks/architecture_comparison/frp_v1_7_0_adapter.py`

Comparison runner:

`benchmarks/architecture_comparison/run_architecture_comparison.py`

Workload profile:

`benchmarks/architecture_comparison/profiles/workload_profile_v1.json`

Normalized cost profile:

`benchmarks/architecture_comparison/profiles/normalized_cost_profile_v1.json`

Reference result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Qualification workflow:

`.github/workflows/frp-architecture-comparison.yml`

## Planned Validation Sequence

The benchmark suite implementation sequence is:

`comparison contract`

↓

`deterministic semantic workload`

↓

`common event taxonomy`

↓

`common normalized cost model`

↓

`common thermal proxy model`

↓

`binary synchronous reference`

↓

`binary clock-gated reference`

↓

`direct ternary reference`

↓

`FRP v1.7.0 quantized shadow adapter`

↓

`comparison runner`

↓

`machine-readable result matrix`

↓

`deterministic repeat validation`

↓

`GitHub Actions qualification`

## Relationship to M15

The current validated M15 chain remains:

`M14 floating semantic reference`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation mapping`

↓

`qualification closure`

The comparative benchmark suite consumes the validated M15 reference side through:

`frp_v1_7_0_adapter.py`

The benchmark suite must not replace:

`frp_prototype_v1_7_0.py`

The benchmark suite must not duplicate the FRP transition kernel.

The benchmark suite must not redefine the M15 fixed-point contract.

## Benchmark Technical Chain

`one deterministic semantic workload`

↓

`architecture-specific state mapping`

↓

`architecture-specific execution`

↓

`raw event traces`

↓

`common normalized event-cost profile`

↓

`common thermal proxy response`

↓

`latency and throughput measurement`

↓

`machine-readable comparison matrix`

↓

`deterministic package integrity`

↓

`qualification without predetermined winner assertions`

## Current Benchmark Position

The benchmark suite begins as an independent comparative package aligned with FRP v1.7.0.

The initial implementation target is:

`Binary Synchronous Reference`

vs

`Binary Clock-Gated Reference`

vs

`Direct Ternary Reference`

vs

`FRP v1.7.0 Quantized Hardware Shadow Reference`

The benchmark result must expose both:

`architectural advantages`

and:

`architectural costs`

through the same declared measurement framework.

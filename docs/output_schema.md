# Output Schema — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the current console, structured JSON, benchmark-matrix, deterministic trace, hardware-facing export, equivalence, and qualification-closure output schemas for the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current M15 export-schema count:

`10`

Current total release-facing schema count:

`12`

Current architecture document:

`./m15_implementation_mapping_domain_interface_qualification_closure.md`

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

## 1. Purpose

The current FRP output layer provides machine-readable and human-readable representations of:

- processor configuration;
- balanced ternary kernel identity;
- hardware-facing numeric profile;
- deterministic quantized execution;
- current execution summary;
- scheduler behavior;
- active neutral transition routing;
- pending neutral routes;
- route counters;
- fixed-point topology exactness;
- fixed-point thermal exactness;
- dynamic stability;
- processor-tick traces;
- per-cell traces;
- route-event traces;
- SHA-256 trace identity;
- self-test qualification;
- benchmark-matrix progression;
- fixed-point interface mapping;
- balanced ternary hardware encoding;
- quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized semantic correlation;
- exact deterministic replay;
- qualification closure.

The current structured-output chain is:

`FRP processor execution`

↓

`structured configuration and kernel identity`

↓

`quantized execution summary`

↓

`optional cycle-exact trace`

↓

`optional per-cell trace`

↓

`optional route-event trace`

↓

`SHA-256 trace identity`

↓

`M15 export schemas`

↓

`semantic correlation`

↓

`exact deterministic replay`

↓

`qualification closure`

The current output layer supports:

- reproducibility;
- CI qualification;
- deterministic artifact generation;
- benchmark inspection;
- hardware-facing implementation mapping;
- SystemVerilog correlation;
- RTL vector replay;
- FPGA execution correlation;
- ASIC-oriented implementation study;
- physical-validation planning;
- archival release evidence.

## 2. Current Output Architecture

The current executable exposes four output families.

| Output Family | Primary Role |
|---|---|
| structured processor output | current processor configuration, kernel, hardware profile, summary, and optional traces |
| self-test output | 41-check M15 qualification registry and detailed validation objects |
| benchmark matrix | five-row implementation progression from M14 floating semantics through M15 qualification closure |
| M15 export package | ten hardware-facing implementation-mapping and qualification schemas |

The current schema chain is:

`frp.structured_output.v1.7.0`

+

`frp.m3.benchmark_matrix.v1.7.0`

+

`10 M15 export schemas`

=

`12 release-facing schemas`

Current validated release-facing schema count:

`12`

Current validation result:

`PASS`

## 3. Output Modes

The current executable supports two presentation formats:

| Output Mode | CLI Option | Role |
|---|---|---|
| text | `--output text` | compact human-readable report |
| json | `--output json` | machine-readable structured output |

Default output mode:

`text`

JSON mode:

`json`

Current demo behavior:

- text output through `--output text`;
- structured JSON through `--output json`;
- complete trace inclusion through `--include-trace`.

Current self-test behavior:

- compact text report through `--output text`;
- complete qualification object through `--output json`.

Current benchmark behavior:

- benchmark-matrix JSON output.

Current export behavior:

- every M15 export flag produces JSON.

## 4. Current Command-Line Output Controls

Current primary mode arguments:

| Argument | Values | Default | Role |
|---|---|---|---|
| `--mode` | `demo`, `self-test`, `benchmark` | `demo` | selects current execution family |
| `--output` | `text`, `json` | `text` | selects presentation format |
| `--include-trace` | flag | disabled | adds complete demo trace objects |

Current execution-profile arguments:

| Argument | Default | Role |
|---|---:|---|
| `--scheduler` | `7/1` | selects scheduler mode |
| `--cells` | `16` | sets cell count |
| `--steps` | `64` | sets processor-tick count |
| `--seed` | `76` | sets deterministic seed |
| `--transition-fraction` | `0.25` | sets distributed commit capacity |
| `--gamma` | `0.30 × pi` | sets nominal Sakaguchi phase lag |
| `--fractal-alpha` | `0.70` | sets hierarchical coupling exponent |
| `--thermal-beta` | `1.20` | sets thermal topology exponent |
| `--ambient-heat` | `0.05` | sets ambient model heat |
| `--thermal-time-constant` | `14.0` | sets thermal dissipation time constant |
| `--thermal-soft-limit` | `0.22` | sets thermal soft limit |
| `--thermal-hard-limit` | `0.90` | sets thermal hard limit |
| `--coupling-nominal` | `0.28` | sets nominal resonant coupling |
| `--delay-alpha` | `0.30` | sets stateful delay coefficient |
| `--thermal-diffusion-gain` | `0.035` | sets hierarchical thermal diffusion gain |
| `--equivalence-tolerance` | `1e-12` | sets floating correlation tolerance |
| `--vector-output-dir` | `None` | optional deterministic vector-package output directory |

Current cell-count requirement:

`cells = power of two and cells >= 2`

Current scheduler values:

- `free`;
- `7/1`;
- `1/7`.

## 5. Current Execution Commands

Current default structured demo:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Current full trace:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Current text demo:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Current self-test JSON:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Current self-test text:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Current benchmark matrix:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

Equivalent benchmark export:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

## 6. Stable v1.7.0 Schema Registry

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current benchmark schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current M15 export schemas:

1. `frp.m15.fixed_point_interface_profile.v1.7.0`;
2. `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`;
3. `frp.m15.quantized_reference_shadow_model.v1.7.0`;
4. `frp.m15.cycle_exact_reference_trace.v1.7.0`;
5. `frp.m15.rtl_comparison_vector_package.v1.7.0`;
6. `frp.m15.systemverilog_testbench_interface_map.v1.7.0`;
7. `frp.m15.synthesizable_rtl_reference_core.v1.7.0`;
8. `frp.m15.rtl_assertion_correlation_harness.v1.7.0`;
9. `frp.m15.reference_rtl_equivalence_report.v1.7.0`;
10. `frp.m15.qualification_closure_manifest.v1.7.0`.

Current total release-facing schema count:

`12`

Current self-test schema-count markers:

`export_schema_count_10 = True`

`all_export_schemas_exact = True`

## 7. Shared Release-Facing Envelope

Current structured and exported JSON objects use the following common identity fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | exact schema identifier |
| `kind` | string | output or artifact type |
| `version` | string | FRP version |
| `milestone` | string | current milestone identity |

Current version value:

`1.7.0`

Current milestone value:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current JSON serialization:

- two-space indentation;
- sorted keys;
- Unicode preservation.

The executable prints structured JSON through:

`json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False)`

## 8. Canonical Digest Serialization

Digest-producing objects use canonical JSON bytes.

Current canonical serialization properties:

- sorted keys;
- compact separators;
- Unicode preservation;
- trailing newline;
- UTF-8 encoding.

Current relation:

`canonical JSON object`

↓

`UTF-8 bytes`

↓

`SHA-256`

Current digest function:

`sha256`

Current digest representation:

`64-character lowercase hexadecimal string`

This digest structure is used for:

- preload identity;
- processor-tick trace identity;
- per-cell trace identity;
- deterministic vector-package integrity.

## 9. Current Demo JSON Output

Command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Current top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | `frp.structured_output.v1.7.0` |
| `kind` | string | `demo` |
| `version` | string | `1.7.0` |
| `milestone` | string | current M15 milestone |
| `configuration` | object | current execution profile |
| `kernel` | object | processor-kernel identity |
| `hardware_profile` | object | hardware-facing numeric and state profile |
| `summary` | object | aggregate quantized execution result |
| `preload_digest` | string | SHA-256 preload identity |
| `trace_digest` | string | SHA-256 processor-tick trace identity |
| `cell_trace_digest` | string | SHA-256 per-cell trace identity |

Full trace mode adds:

| Field | Type | Meaning |
|---|---|---|
| `trace` | array | processor-tick rows |
| `cell_trace` | array | per-cell per-tick rows |
| `route_events` | array | pending and applied neutral-route events |

## 10. Configuration Object

The current `configuration` object records the complete primary execution profile.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `cells` | integer | processor cell count |
| `steps` | integer | processor-tick count |
| `seed` | integer | deterministic seed |
| `scheduler` | string | scheduler mode |
| `transition_fraction` | number | distributed commit fraction |
| `request_lanes` | integer | derived request-lane count |
| `gamma_nominal` | number | nominal Sakaguchi phase lag |
| `fractal_alpha` | number | hierarchical coupling exponent |
| `thermal_beta` | number | thermal topology exponent |
| `ambient_heat` | number | ambient model heat |
| `thermal_time_constant` | number | thermal dissipation time constant |
| `thermal_soft_limit` | number | thermal soft limit |
| `thermal_hard_limit` | number | thermal hard limit |
| `coupling_nominal` | number | nominal resonant coupling |
| `delay_alpha` | number | stateful delay coefficient |
| `thermal_diffusion_gain` | number | hierarchical thermal diffusion gain |

Current default configuration:

| Field | Value |
|---|---:|
| `cells` | `16` |
| `steps` | `64` |
| `seed` | `76` |
| `scheduler` | `7/1` |
| `transition_fraction` | `0.25` |
| `request_lanes` | `4` |
| `gamma_nominal` | `0.9424777960769379` |
| `fractal_alpha` | `0.7` |
| `thermal_beta` | `1.2` |
| `ambient_heat` | `0.05` |
| `thermal_time_constant` | `14.0` |
| `thermal_soft_limit` | `0.22` |
| `thermal_hard_limit` | `0.9` |
| `coupling_nominal` | `0.28` |
| `delay_alpha` | `0.3` |
| `thermal_diffusion_gain` | `0.035` |

## 11. Kernel Object

The current `kernel` object identifies the processor kernel carried by the structured output.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `balanced_ternary_states` | array | current ternary state domain |
| `active_neutral_state` | integer | active neutral state |
| `neutral_routes` | array | mandatory opposite-polarity routes |
| `scheduler_modes` | array | available scheduler modes |
| `actual_direct_events_target` | integer | validated direct-event target |

Current values:

`balanced_ternary_states = [-1, 0, 1]`

`active_neutral_state = 0`

Current neutral routes:

`-1 -> 0 -> 1`

`1 -> 0 -> -1`

Current scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current direct-event target:

`actual_direct_events_target = 0`

## 12. Hardware Profile Object

The current `hardware_profile` object records the primary hardware-facing numeric and encoding domains.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `scalar` | string | general dynamic scalar representation |
| `unit` | string | normalized coefficient representation |
| `phase` | string | phase representation |
| `gamma` | string | Sakaguchi gamma representation |
| `state_encoding` | object | balanced ternary encoding |

Current values:

`scalar = S32Q16`

`unit = S32Q30`

`phase = PHASE_U32`

`gamma = GAMMA_S32`

Current state encoding:

| Ternary State | Two-Bit Encoding |
|---|---|
| `-1` | `11` |
| `0` | `00` |
| `1` | `01` |
| reserved | `10` |

## 13. Current Summary Object

The current demo and quantized-shadow `summary` object records aggregate execution state and validated invariants.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `version` | string | FRP version |
| `milestone` | string | milestone identity |
| `cells` | integer | cell count |
| `hierarchy_depth` | integer | dyadic hierarchy depth |
| `request_lanes` | integer | request-lane count |
| `steps` | integer | requested tick count |
| `ticks_recorded` | integer | recorded tick count |
| `scheduler` | string | scheduler mode |
| `scheduler_counts` | object | scheduler-state counts |
| `scheduler_counts_valid` | boolean | scheduler-count validation |
| `transition_fraction` | number | distributed commit fraction |
| `balanced_ternary_state_domain` | boolean | current-state domain validation |
| `reserved_state_events` | integer | reserved encoding events |
| `actual_direct_events` | integer | direct opposite-polarity events |
| `requested_direct_events` | integer | opposite-polarity requests |
| `prevented_direct_events` | integer | intercepted direct requests |
| `neutral_routed_events` | integer | completed neutral routes |
| `neutralized_conflicts` | integer | neutralized transition conflicts |
| `pending_route_count_final` | integer | final pending-route count |
| `neutral_route_queue_capacity` | integer | pending-route queue capacity |
| `queue_overflow_events` | integer | queue-overflow counter |
| `switch_load_peak_q16` | integer | peak transition load in Q16 |
| `switch_load_peak` | number | dequantized peak transition load |
| `C_minus_P_final_q16` | integer | final dynamic-stability margin in Q16 |
| `C_minus_P_final` | number | final dequantized dynamic-stability margin |
| `C_minus_P_min_q16` | integer | minimum dynamic-stability margin in Q16 |
| `C_minus_P_min` | number | minimum dequantized dynamic-stability margin |
| `boundary_detected` | boolean | stability-boundary crossing state |
| `fixed_point_topology_sum_exact` | boolean | exact topology-weight closure |
| `fixed_point_thermal_sum_exact` | boolean | exact thermal-weight closure |

## 14. Current Default Summary Evidence

Current default structured execution records:

| Metric | Value |
|---|---:|
| `cells` | `16` |
| `hierarchy_depth` | `4` |
| `request_lanes` | `4` |
| `steps` | `64` |
| `ticks_recorded` | `64` |
| `scheduler` | `7/1` |
| `balance` | `56` |
| `commit` | `8` |
| `scheduler_counts_valid` | `True` |
| `transition_fraction` | `0.25` |
| `balanced_ternary_state_domain` | `True` |
| `reserved_state_events` | `0` |
| `actual_direct_events` | `0` |
| `queue_overflow_events` | `0` |
| `pending_route_count_final` | `0` |
| `switch_load_peak_q16` | `16384` |
| `switch_load_peak` | `0.25` |
| `C_minus_P_min_q16` | `40257` |
| `C_minus_P_min` | `0.6142730712890625` |
| `C_minus_P_final_q16` | `57860` |
| `C_minus_P_final` | `0.88287353515625` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Current default result:

`PASS`

## 15. Digest Fields

The compact demo output records three deterministic digests.

| Field | Source |
|---|---|
| `preload_digest` | canonical preload object |
| `trace_digest` | canonical processor-tick trace |
| `cell_trace_digest` | canonical per-cell trace |

Current default execution digests:

`preload_digest = fbd4ce8153133a30bacb4004ef6b126858e64da1f464b763439d29fd8c98b5af`

`trace_digest = 06be197a6f7620796daad6420091e21392295cb0e182b394da2d9990324415be`

`cell_trace_digest = ba7d5f5a5f45d1c6808a0d4c7d7f612916bb2e2c4d33faf5e182810d704ad544`

These values correspond to the current default deterministic execution profile.

## 16. Full Trace Mode

Command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Full trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Current default trace lengths:

`trace = 64 rows`

`cell_trace = 1024 rows`

Current relation:

`64 ticks × 16 cells = 1024 cell-trace rows`

The same digests remain present in the full trace output.

## 17. Processor-Tick Trace Row

Each current `trace` row records one post-tick quantized processor state.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | processor-tick index |
| `reset_n` | integer | reset state |
| `scheduler_mode` | integer | encoded scheduler mode |
| `scheduler_state` | integer | encoded scheduler state |
| `scheduler_state_name` | string | scheduler-state name |
| `auto_targets_enable` | integer | automatic target control |
| `request_valid_mask` | integer | active request-lane bit mask |
| `request_cell_ids` | array | request cell identifiers |
| `request_target_states` | array | encoded request target states |
| `gamma_noise_update_valid` | integer | gamma target update marker |
| `gamma_noise_target_q16` | array | per-cell deterministic gamma targets |
| `states_packed` | integer | packed ternary state vector |
| `states_packed_hex` | string | packed hexadecimal state vector |
| `states_human` | string | human ternary state string |
| `pending_route_count` | integer | active pending-route count |
| `switch_load_q16` | integer | current transition load |
| `heat_global_q16` | integer | global model heat |
| `global_phase_coherence_q30` | integer | global phase coherence |
| `C_q16` | integer | operational coherence |
| `P_q16` | integer | destabilizing load |
| `C_minus_P_q16` | integer | dynamic-stability margin |
| `requested_direct_events` | integer | accumulated direct requests |
| `prevented_direct_events` | integer | accumulated intercepted requests |
| `neutral_routed_events` | integer | accumulated completed neutral routes |
| `neutralized_conflicts` | integer | accumulated neutralized conflicts |
| `actual_direct_events` | integer | accumulated direct opposite-polarity events |
| `reserved_state_events` | integer | accumulated reserved-state events |
| `queue_overflow_events` | integer | accumulated queue-overflow events |
| `changes` | integer | current-tick state changes |

The trace row is the primary cycle-exact integer comparison unit.

## 18. Scheduler Encoding in Trace Rows

Current scheduler-mode encoding:

| Mode | Code |
|---|---:|
| `free` | `0` |
| `7/1` | `1` |
| `1/7` | `2` |

Current scheduler-state encoding:

| State | Code |
|---|---:|
| `free` | `0` |
| `balance` | `1` |
| `commit` | `2` |
| `excite` | `3` |
| `neutralize` | `4` |

The trace carries both:

- encoded scheduler state;
- human-readable scheduler-state name.

## 19. Packed Ternary State Fields

Current trace state fields:

- `states_packed`;
- `states_packed_hex`;
- `states_human`.

Current human-state symbols:

| Ternary State | Human Symbol |
|---|---|
| `-1` | `M` |
| `0` | `N` |
| `1` | `P` |

Current packed state relation:

`2 bits per cell`

Current default packed width:

`32 bits`

Current cell mapping:

`cell i → [2i+1:2i]`

## 20. Per-Cell Trace Row

Each current `cell_trace` row records one cell at one processor tick.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | processor-tick index |
| `cell_id` | integer | cell identifier |
| `state_code` | integer | encoded balanced ternary state |
| `phase_word` | integer | `PHASE_U32` state |
| `frequency_target_q16` | integer | target frequency |
| `frequency_current_q16` | integer | current delayed frequency |
| `frequency_lag_q16` | integer | remaining frequency lag |
| `generated_power_q16` | integer | current generated-power state |
| `heat_q16` | integer | local model heat |
| `thermal_overload_q16` | integer | local thermal overload |
| `gamma_noise_state_q16` | integer | correlated gamma-noise state |
| `gamma_effective_word` | integer | effective gamma word |
| `thermal_node_factor_q30` | integer | thermal coupling node factor |
| `coupling_field_q16` | integer | hierarchical resonant coupling field |

The per-cell trace supplies the detailed deterministic comparison domain for:

- state;
- phase;
- frequency;
- delay;
- thermal state;
- gamma state;
- thermal coupling;
- resonant coupling.

## 21. Route Event Object

Each current `route_events` row records one pending or applied active-neutral route event.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | event tick |
| `cell_id` | integer | affected cell |
| `target_state` | integer | retained target polarity |
| `ready_tick` | integer | earliest route-completion tick |
| `route_status` | string | route event state |

Current route-status values:

- `pending`;
- `applied`.

Current route relation:

`opposite-polarity request`

↓

`current state → 0`

↓

`pending route event`

↓

`ready tick retained`

↓

`applied route event`

↓

`0 → target polarity`

## 22. Current Text Output Compatibility

The compact text output remains available for demo and self-test modes.

Current demo text command:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Current demo text fields include:

- FRP version;
- milestone;
- `kind`;
- `balanced_ternary_state_domain`;
- `reserved_state_events`;
- `actual_direct_events`;
- `scheduler`;
- `scheduler_counts`;
- `switch_load_peak`;
- `C_minus_P_min`;
- `fixed_point_topology_sum_exact`;
- `fixed_point_thermal_sum_exact`.

Current default demo text markers:

`FRP v1.7.0`

`kind: demo`

`balanced_ternary_state_domain: True`

`reserved_state_events: 0`

`actual_direct_events: 0`

`C_minus_P_min: 0.6142730712890625`

Current self-test text command:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Current self-test text markers:

`FRP v1.7.0`

`kind: self_test`

`status: PASS`

`check_count: 41`

## 23. Current Self-Test JSON Output

Command:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Current top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | `frp.structured_output.v1.7.0` |
| `kind` | string | `self_test` |
| `version` | string | `1.7.0` |
| `milestone` | string | current M15 milestone |
| `status` | string | qualification status |
| `check_count` | integer | check count |
| `checks` | object | complete boolean check registry |
| `neutral_route_validation` | object | both route directions |
| `scheduler_validation` | object | three scheduler modes |
| `request_lane_order_validation` | object | deterministic request order |
| `queue_exhaustion_validation` | object | queue behavior |
| `fixed_point_validation` | object | arithmetic boundaries |
| `encoding_validation` | object | ternary and scheduler encoding |
| `topology_validation` | object | 8, 16, and 32-cell topology |
| `trigonometric_lut_validation` | object | lookup-table qualification |
| `semantic_correlation` | object | floating-to-quantized correlation |
| `exact_shadow_replay` | object | exact deterministic replay |
| `vector_determinism` | object | vector-package determinism |
| `scaling_validation` | object | 8, 16, and 32-cell execution |

Current status:

`PASS`

Current check count:

`41`

## 24. Current 41-Check Registry

Current check registry:

1. `1_7_scheduler_pass`;
2. `7_1_scheduler_pass`;
3. `all_export_schemas_exact`;
4. `artifact_layer_count_10`;
5. `encoding_pass`;
6. `exact_reference_cell_trace_replay_match`;
7. `exact_reference_vector_replay_match`;
8. `exact_shadow_counter_match`;
9. `exact_shadow_pending_route_match`;
10. `exact_shadow_scheduler_match`;
11. `exact_shadow_state_match`;
12. `export_schema_count_10`;
13. `fixed_point_boundary_pass`;
14. `fixed_point_thermal_sum_exact`;
15. `fixed_point_topology_sum_exact`;
16. `free_scheduler_pass`;
17. `qualification_closure_pass`;
18. `queue_exhaustion_detection_pass`;
19. `request_lane_order_pass`;
20. `route_minus_to_plus_pass`;
21. `route_plus_to_minus_pass`;
22. `scale_16_pass`;
23. `scale_32_pass`;
24. `scale_8_pass`;
25. `semantic_C_minus_P_sign_match`;
26. `semantic_boundary_order_match`;
27. `semantic_neutral_route_sequence_match`;
28. `semantic_scheduler_sequence_match`;
29. `semantic_state_sequence_match`;
30. `shadow_actual_direct_events_zero`;
31. `shadow_balanced_ternary_domain`;
32. `shadow_queue_overflow_events_zero`;
33. `shadow_reserved_state_events_zero`;
34. `shadow_scheduler_counts_valid`;
35. `shadow_switch_load_within_transition_fraction`;
36. `shadow_ticks_recorded_equals_steps`;
37. `topology_16_pass`;
38. `topology_32_pass`;
39. `topology_8_pass`;
40. `trig_lut_pass`;
41. `vector_determinism_pass`.

Current required result:

`all 41 values = True`

Current result:

`41/41 PASS`

## 25. Neutral Route Validation Object

Current `neutral_route_validation` contains:

- `-1_to_0_to_1`;
- `1_to_0_to_-1`.

Each direction object contains:

| Field | Type | Meaning |
|---|---|---|
| `direction` | string | route direction |
| `state_tick_0` | integer | state after first route tick |
| `state_tick_1` | integer | state after subsequent route tick |
| `checks` | object | direction-specific checks |
| `summary` | object | quantized execution summary |
| `status` | string | validation status |

Current route validation result:

`PASS`

## 26. Scheduler Validation Object

Current `scheduler_validation` contains:

- `free`;
- `7/1`;
- `1/7`.

Each scheduler object contains:

| Field | Type | Meaning |
|---|---|---|
| `scheduler` | string | tested scheduler |
| `checks` | object | scheduler validation checks |
| `summary` | object | quantized execution summary |
| `status` | string | validation status |

Current result for all scheduler modes:

`PASS`

## 27. Request-Lane Order Validation Object

Current `request_lane_order_validation` contains:

- `checks`;
- `summary`;
- `status`.

Current checks include:

- request lanes at least two;
- lane zero applied first;
- lane one opposite request intercepted;
- same-tick result neutral;
- pending target equals negative one;
- actual direct events remain zero.

Current status:

`PASS`

## 28. Queue Exhaustion Validation Object

Current `queue_exhaustion_validation` contains:

- `checks`;
- `summary`;
- `status`.

Current checks include:

- queue capacity equals cell count;
- queue length remains bounded;
- overflow detection activates under the dedicated exhaustion test;
- same-tick result remains neutral;
- actual direct events remain zero.

Current status:

`PASS`

## 29. Fixed-Point Validation Object

Current `fixed_point_validation` contains:

- `checks`;
- `status`.

Current checks include:

- Q16 one identity;
- Q30 one identity;
- Q16 multiplication identity;
- Q30 multiplication identity;
- positive half rounding away from zero;
- negative half rounding away from zero;
- positive Q16 half-LSB rounding;
- negative Q16 half-LSB rounding;
- positive saturation;
- negative saturation;
- phase zero;
- phase quarter cycle;
- phase half cycle;
- phase wrap;
- negative phase wrap.

Current status:

`PASS`

## 30. Encoding Validation Object

Current `encoding_validation` contains:

- `sample_states`;
- `packed_hex`;
- `checks`;
- `status`.

Current checks include:

- negative-state code;
- neutral-state code;
- positive-state code;
- reserved code equals `10`;
- reserved state rejection;
- packed round trip;
- cell zero occupies the low bits;
- scheduler mode encoding for `free`;
- scheduler mode encoding for `7/1`;
- scheduler mode encoding for `1/7`;
- unique scheduler-state encodings.

Current status:

`PASS`

## 31. Topology Validation Object

Current `topology_validation` contains profiles for:

- `8` cells;
- `16` cells;
- `32` cells.

Each profile contains:

| Field | Type | Meaning |
|---|---|---|
| `cells` | integer | cell count |
| `coupling_sum_q30` | integer | exact topology aggregate |
| `thermal_sum_q30` | integer | exact thermal aggregate |
| `checks` | object | topology checks |
| `status` | string | profile status |

Current status for all three profiles:

`PASS`

## 32. Trigonometric LUT Validation Object

Current `trigonometric_lut_validation` contains:

- `checks`;
- `sha256`;
- `status`.

Current checks include:

- entry count;
- sine zero;
- sine quarter cycle;
- sine half cycle;
- cosine relation;
- deterministic rebuild.

Current trigonometric lookup SHA-256:

`acb0dfe2c00998840f9ca00f9ef9e3b46011db6c745faa59a9db13c4121cc57b`

Current status:

`PASS`

## 33. Semantic Correlation Object

Current `semantic_correlation` compares:

`floating semantic reference`

with:

`quantized hardware shadow`

Current sequence-correlation fields:

| Field | Current Value |
|---|---:|
| `state_sequence_match` | `1.0` |
| `scheduler_sequence_match` | `1.0` |
| `neutral_route_sequence_match` | `1.0` |
| `C_minus_P_sign_match` | `1.0` |
| `boundary_order_match` | `1.0` |

Current error fields:

- `max_phase_error`;
- `max_frequency_error`;
- `max_heat_error`;
- `max_gamma_error`;
- `max_coherence_error`;
- `max_C_error`;
- `max_P_error`;
- `max_C_minus_P_error`.

Current boundary fields:

- `float_boundary_tick`;
- `shadow_boundary_tick`.

Current summary objects:

- `float_summary`;
- `shadow_summary`.

Current semantic correlation result:

`PASS`

## 34. Exact Shadow Replay Object

Current `exact_shadow_replay` fields:

| Field | Current Value |
|---|---:|
| `shadow_replay_state_match` | `1.0` |
| `shadow_replay_scheduler_match` | `1.0` |
| `shadow_replay_pending_route_match` | `1.0` |
| `shadow_replay_counter_match` | `1.0` |
| `shadow_replay_trace_match` | `1.0` |
| `shadow_replay_cell_trace_match` | `1.0` |

The object also carries:

- `trace_digest`;
- `cell_trace_digest`.

Current exact deterministic replay result:

`PASS`

## 35. Vector Determinism Object

Current `vector_determinism` contains:

- `checks`;
- `byte_matches`;
- `manifest`;
- `package_digest`;
- `status`.

Current checks include:

- identical file set;
- all files byte-identical;
- kernel vectors present;
- free scheduler vectors present;
- `7/1` scheduler vectors present;
- `1/7` scheduler vectors present;
- full correlation vectors present;
- cell trace present;
- preload manifest present;
- trigonometric LUT present;
- SHA-256 manifest present.

Current deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

Current file count:

`10`

Current independent regeneration result:

`10/10 files byte-identical`

Current status:

`PASS`

## 36. Scaling Validation Object

Current `scaling_validation` contains:

- `8`;
- `16`;
- `32`.

Each profile contains:

| Field | Type | Meaning |
|---|---|---|
| `cells` | integer | profile cell count |
| `checks` | object | scaling checks |
| `summary` | object | quantized execution summary |
| `topology` | object | topology validation data |
| `status` | string | scaling status |

Current validated scaling results:

| Cells | Hierarchy Depth | Request Lanes | `C_minus_P_min` | Switch Load Peak |
|---|---:|---:|---:|---:|
| `8` | `3` | `2` | `0.828887939453125` | `0.25` |
| `16` | `4` | `4` | `0.6142730712890625` | `0.25` |
| `32` | `5` | `8` | `0.6628875732421875` | `0.25` |

Current status for all profiles:

`PASS`

## 37. Current Benchmark JSON Output

Command:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

Equivalent export:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

Current top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | benchmark schema |
| `kind` | string | `benchmark_matrix` |
| `version` | string | `1.7.0` |
| `milestone` | string | current M15 milestone |
| `rows` | array | five implementation-progression rows |

Current schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current row count:

`5`

## 38. Benchmark Matrix Rows

Current rows:

### Row 1

Architecture:

`frp_v1_6_0_m14_floating_semantic_reference`

Fields:

- `architecture`;
- `numeric_domain`;
- `cycle_exact_integer_trace`;
- `hardware_facing_encoding`;
- `interaction_scaling`.

Current numeric domain:

`floating semantic reference`

Current interaction scaling:

`O(N log N) hierarchical reference path`

### Row 2

Architecture:

`frp_v1_7_0_quantized_hardware_shadow`

Additional fields:

- `state_sequence_match`;
- `scheduler_sequence_match`;
- `C_minus_P_sign_match`.

Current sequence values:

`1.0`

Current numeric domain:

`S32Q16 / S32Q30 / PHASE_U32 / GAMMA_S32`

Current interaction scaling:

`O(N^2) shadow evaluation with exact dyadic weights`

### Row 3

Architecture:

`frp_v1_7_0_cycle_exact_vector_package`

Current numeric domain:

`integer and hexadecimal vectors`

Current field:

`vector_repeat_match = 1.0`

### Row 4

Architecture:

`frp_v1_7_0_systemverilog_correlation_contract`

Current numeric domain:

`exact integer comparison`

Current comparison rule:

`actual == expected`

### Row 5

Architecture:

`frp_v1_7_0_qualification_closure`

Current numeric domain:

`semantic correlation plus exact integer replay`

Current artifact layer count:

`10`

## 39. Current M15 Export Architecture

FRP v1.7.0 defines ten M15 export schemas.

Current chain:

`fixed-point interface profile`

↓

`balanced ternary hardware encoding map`

↓

`quantized reference shadow model`

↓

`cycle-exact reference trace`

↓

`RTL comparison vector package`

↓

`SystemVerilog testbench interface map`

↓

`synthesizable RTL reference-core map`

↓

`RTL assertion correlation harness`

↓

`reference RTL equivalence report`

↓

`qualification closure manifest`

Every export carries:

- `schema`;
- `kind`;
- `version`;
- `milestone`.

## 40. Fixed-Point Interface Profile Export

Command:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Schema:

`frp.m15.fixed_point_interface_profile.v1.7.0`

Kind:

`fixed_point_interface_profile`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `inherited_boundary`;
- `profile`;
- `topology_fixed_point_profile`;
- `thermal_fixed_point_profile`;
- `fixed_point_topology_sum_exact`;
- `fixed_point_thermal_sum_exact`.

Current primary profile domains:

- `general_scalar`;
- `normalized_coefficient`;
- `phase`;
- `gamma`;
- `rounding`;
- `saturation`;
- `phase_overflow`;
- `multiply_rules`;
- `trigonometric_profile`;
- `exponential_profile`.

Current fixed-point result:

`PASS`

## 41. Fixed-Point Profile Fields

Current general scalar:

`S32Q16`

Properties:

- signed;
- 32-bit width;
- 16 fractional bits;
- scale `65536`.

Current normalized coefficient:

`S32Q30`

Properties:

- signed;
- 32-bit width;
- 30 fractional bits;
- scale `1073741824`.

Current phase:

`PHASE_U32`

Properties:

- unsigned;
- 32-bit width;
- modulus `4294967296`;
- full-cycle relation `2^32 phase units = 2 pi`.

Current gamma:

`GAMMA_S32`

Current rounding:

`round-to-nearest, half cases away from zero`

Current saturation:

`signed destination saturation`

Current phase overflow:

`modulo 2^32 wrap`

Current multiplication rules:

`mul_q16 = round_shift(a * b, 16)`

`mul_q16_q30 = round_shift(a * b, 30)`

`mul_q30 = round_shift(a * b, 30)`

## 42. Trigonometric and Exponential Profile Fields

Current trigonometric profile:

| Field | Value |
|---|---|
| table entries | `4096` |
| address bits | `12` |
| index relation | `phase_word >> 20` |
| output type | `S32Q30` |

Current sine LUT SHA-256:

`acb0dfe2c00998840f9ca00f9ef9e3b46011db6c745faa59a9db13c4121cc57b`

Current exponential profile:

| Field | Value |
|---|---|
| table entries | `4096` |
| input domain Q16 | `[0, 524288]` |
| output type | `S32Q30` |

Current exponential LUT SHA-256:

`350499727643d6eb7e123a0c2256ed05a7d76f316e4181acce170101ae78bf0a`

## 43. Balanced Ternary Hardware Encoding Map Export

Command:

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Schema:

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

Kind:

`balanced_ternary_hardware_encoding_map`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `inherited_boundary`;
- `state_encoding`;
- `reserved_state_code`;
- `packed_state_vector`;
- `request_interface`;
- `scheduler_mode_encoding`;
- `scheduler_state_encoding`.

Current state encoding:

`-1 → integer code 3`

`0 → integer code 0`

`1 → integer code 1`

Reserved integer code:

`2`

## 44. Quantized Reference Shadow Model Export

Command:

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Schema:

`frp.m15.quantized_reference_shadow_model.v1.7.0`

Kind:

`quantized_reference_shadow_model`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `inherited_boundary`;
- `execution_model`;
- `configuration`;
- `numeric_profile`;
- `preload`;
- `summary`;
- `trace_digest`;
- `cell_trace_digest`.

Current execution model:

`stateful fixed-point feedback`

Current numeric profile:

- `S32Q16`;
- `S32Q30`;
- `PHASE_U32`;
- `GAMMA_S32`.

## 45. Preload Object

The current quantized shadow and cycle-exact trace carry deterministic preload state.

Current preload fields:

| Field | Type | Meaning |
|---|---|---|
| `cells` | integer | cell count |
| `scheduler` | string | scheduler profile |
| `seed` | integer | deterministic seed |
| `states` | array | initial ternary states |
| `states_packed_hex` | string | packed initial state |
| `phase_words` | array | initial phase words |
| `frequency_target_q16` | array | initial target frequencies |
| `frequency_current_q16` | array | initial current frequencies |
| `heat_q16` | array | initial local heat |
| `gamma_noise_state_q16` | array | initial gamma-noise states |
| `gamma_noise_target_q16` | array | initial gamma-noise targets |

The preload object provides deterministic execution initialization.

## 46. Cycle-Exact Reference Trace Export

Command:

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Schema:

`frp.m15.cycle_exact_reference_trace.v1.7.0`

Kind:

`cycle_exact_reference_trace`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `configuration`;
- `preload`;
- `summary`;
- `trace`;
- `route_events`.

Current default trace length:

`64`

Current trace comparison role:

`cycle-exact integer golden reference`

## 47. RTL Comparison Vector Package Export

Command:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

Kind:

`rtl_comparison_vector_package`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `vector_classes`;
- `manifest`;
- `deterministic_package_digest`.

Current vector classes:

- `kernel_transition_vectors`;
- `scheduler_vectors`;
- `full_correlation_vectors`.

Current manifest fields:

- `file_count`;
- `files`.

Current file count:

`10`

Current deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

## 48. Current Vector Package Files

Current files:

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

The manifest records file identity through:

- filename;
- SHA-256;
- byte size.

Current independent regeneration result:

`10/10 files byte-identical`

## 49. Vector Output Directory

Optional command:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir <directory>

Current role:

`write the deterministic M15 vector package into the selected directory`

The JSON export remains available together with the written package.

## 50. SystemVerilog Testbench Interface Map Export

Command:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Schema:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

Kind:

`systemverilog_testbench_interface_map`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `parameters`;
- `execution_inputs`;
- `verification_stimulus_inputs`;
- `comparison_outputs`;
- `vector_replay_order`.

Current parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

## 51. SystemVerilog Execution Inputs

Current execution inputs:

- `clk`;
- `reset_n`;
- `scheduler_mode`;
- `auto_targets_enable`;
- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Current verification stimulus inputs:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Current comparison outputs include:

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

## 52. Vector Replay Order

Current vector replay order contains nine stages:

1. parse vector row;
2. drive input signals before active clock edge;
3. apply verification sideband stimulus;
4. execute one processor clock edge;
5. allow registered outputs to settle;
6. sample post-tick outputs;
7. compare sampled outputs against expected integer values;
8. execute invariant assertions;
9. stop immediately on mismatch.

Current exact integer comparison rule:

`actual integer field == expected integer field`

## 53. Synthesizable RTL Reference-Core Export

Command:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Schema:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

Kind:

`synthesizable_rtl_reference_core`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `kernel_requirements`;
- `planned_rtl_files`;
- `exact_tick_execution_order`.

Current planned RTL file count:

`13`

Current exact tick-order count:

`26`

## 54. Current Planned RTL File Set

Current mapped RTL domains:

1. `rtl/m15/frp_m15_types_pkg.sv`;
2. `rtl/m15/frp_m15_fixed_point_pkg.sv`;
3. `rtl/m15/frp_m15_trig_lut_pkg.sv`;
4. `rtl/m15/frp_m15_scheduler.sv`;
5. `rtl/m15/frp_m15_transition_core.sv`;
6. `rtl/m15/frp_m15_neutral_route_queue.sv`;
7. `rtl/m15/frp_m15_delay_dynamics.sv`;
8. `rtl/m15/frp_m15_thermal_field.sv`;
9. `rtl/m15/frp_m15_gamma_drift.sv`;
10. `rtl/m15/frp_m15_hierarchical_coupling.sv`;
11. `rtl/m15/frp_m15_multiscale_coherence.sv`;
12. `rtl/m15/frp_m15_stability_telemetry.sv`;
13. `rtl/m15/frp_m15_top.sv`.

## 55. Exact Tick Execution Order

Current exact 26-stage execution order:

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

This sequence defines the current cycle-correlation order.

## 56. RTL Assertion Correlation Harness Export

Command:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Schema:

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

Kind:

`rtl_assertion_correlation_harness`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `assertion_count`;
- `assertions`;
- `direct_transition_rules`;
- `scheduler_modes`;
- `exact_comparison_rule`.

Current assertion count:

`13`

Current exact comparison rule:

`actual integer field == expected integer field`

## 57. Current Assertion Domains

Current assertion domains:

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

## 58. Reference RTL Equivalence Report Export

Command:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Schema:

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

Kind:

`reference_rtl_equivalence_report`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `floating_reference_to_quantized_shadow`;
- `quantized_shadow_deterministic_replay`;
- `rtl_exact_integer_comparison_contract`.

The report carries two correlation boundaries:

`floating semantic reference → quantized hardware shadow`

and:

`quantized hardware shadow → exact deterministic replay`

## 59. Qualification Closure Manifest Export

Command:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Schema:

`frp.m15.qualification_closure_manifest.v1.7.0`

Kind:

`qualification_closure_manifest`

Top-level fields:

- `schema`;
- `kind`;
- `version`;
- `milestone`;
- `artifact_layers`;
- `checks`;
- `semantic_correlation`;
- `exact_shadow_replay`;
- `vector_manifest`;
- `status`.

Current artifact layer count:

`10`

Current status:

`PASS`

## 60. Qualification Closure Checks

Current qualification-closure checks include:

- balanced ternary state-sequence match;
- scheduler-sequence match;
- neutral-route sequence match;
- `C_minus_P` sign match;
- boundary-order match;
- exact topology fixed-point closure;
- exact thermal fixed-point closure;
- exact trace replay;
- exact cell-trace replay;
- complete vector-package presence.

Current result:

`PASS`

## 61. Current Primary Validation Markers

Current structured-output validation markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `milestone` | current M15 milestone |
| `kind` | `demo` or `self_test` |
| `summary.balanced_ternary_state_domain` | `True` |
| `summary.reserved_state_events` | `0` |
| `summary.actual_direct_events` | `0` |
| `summary.queue_overflow_events` | `0` |
| `summary.scheduler_counts_valid` | `True` |
| `summary.ticks_recorded` | requested steps |
| `summary.switch_load_peak` | `<= transition_fraction` |
| `summary.C_minus_P_min` | `> 0.0` |
| `summary.fixed_point_topology_sum_exact` | `True` |
| `summary.fixed_point_thermal_sum_exact` | `True` |

Current self-test markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `kind` | `self_test` |
| `status` | `PASS` |
| `check_count` | `41` |
| `len(checks)` | `41` |
| every `checks` value | `True` |

## 62. Current Benchmark Validation Markers

Current benchmark markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.m3.benchmark_matrix.v1.7.0` |
| `kind` | `benchmark_matrix` |
| `version` | `1.7.0` |
| row count | `5` |

Required architecture rows:

- `frp_v1_6_0_m14_floating_semantic_reference`;
- `frp_v1_7_0_quantized_hardware_shadow`;
- `frp_v1_7_0_cycle_exact_vector_package`;
- `frp_v1_7_0_systemverilog_correlation_contract`;
- `frp_v1_7_0_qualification_closure`.

Current semantic markers:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

Current vector marker:

`vector_repeat_match = 1.0`

Current qualification artifact count:

`10`

## 63. Recommended CI Checks for Structured Demo Output

Recommended checks:

- JSON parses successfully;
- `schema` equals `frp.structured_output.v1.7.0`;
- `version` equals `1.7.0`;
- `milestone` equals the current M15 milestone;
- `kind` equals `demo`;
- `summary.cells` equals the selected cell count;
- `summary.ticks_recorded` equals the selected step count;
- `summary.scheduler` equals the selected scheduler;
- `summary.scheduler_counts_valid` equals `True`;
- `summary.balanced_ternary_state_domain` equals `True`;
- `summary.reserved_state_events` equals `0`;
- `summary.actual_direct_events` equals `0`;
- `summary.queue_overflow_events` equals `0`;
- `summary.switch_load_peak` stays within transition fraction;
- `summary.C_minus_P_min` stays positive;
- topology fixed-point exactness equals `True`;
- thermal fixed-point exactness equals `True`;
- digest fields contain 64 hexadecimal characters.

## 64. Recommended CI Checks for Full Trace Output

Recommended full trace checks:

- `trace` length equals `steps`;
- `cell_trace` length equals `steps × cells`;
- every trace row carries the required integer comparison fields;
- every cell-trace row carries the required per-cell fields;
- every trace row records `reserved_state_events = 0`;
- every trace row records `actual_direct_events = 0`;
- every gamma target array length equals cell count;
- trace digest reproduces from canonical trace serialization;
- cell-trace digest reproduces from canonical cell-trace serialization;
- route-event rows use the defined field set;
- route-status values remain inside `pending` and `applied`.

## 65. Recommended CI Checks for M15 Exports

Recommended export checks:

- every export parses as JSON;
- every export schema equals its exact v1.7.0 schema;
- every export version equals `1.7.0`;
- every export milestone equals the M15 milestone;
- M15 export-schema count equals `10`;
- artifact-layer count equals `10`;
- fixed-point topology sum exactness equals `True`;
- fixed-point thermal sum exactness equals `True`;
- balanced ternary encoding equals `{-1: 3, 0: 0, 1: 1}`;
- reserved integer state code equals `2`;
- deterministic vector file count equals `10`;
- deterministic package digest contains 64 hexadecimal characters;
- SystemVerilog parameters equal the current default interface contract;
- assertion count equals `13`;
- exact tick execution order contains `26` stages;
- semantic sequence matches equal `1.0`;
- exact deterministic replay matches equal `1.0`;
- qualification closure status equals `PASS`.

## 66. Current GitHub Actions Validation Context

Current primary current-schema validation workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Job name:

`M15 implementation mapping qualification`

Current environment:

`ubuntu-latest`

Current Python version:

`3.12`

Current timeout:

`30 minutes`

Current permissions:

`contents: read`

Current triggers:

- push;
- pull request;
- workflow dispatch.

## 67. Current M15 Workflow Output Generation

The current M15 workflow generates:

- structured demo output;
- default self-test output;
- free-scheduler self-test output;
- `7/1` self-test output;
- `1/7` self-test output;
- fixed-point interface profile;
- balanced ternary hardware encoding map;
- quantized reference shadow model;
- cycle-exact reference trace;
- RTL comparison vector package;
- SystemVerilog testbench interface map;
- synthesizable RTL reference-core map;
- RTL assertion correlation harness;
- reference RTL equivalence report;
- qualification closure manifest;
- benchmark matrix;
- 8-cell scaling output;
- 16-cell scaling output;
- 32-cell scaling output;
- independent vector package A;
- independent vector package B.

## 68. Current M15 Workflow Validation Stages

Current workflow stages:

1. checkout repository;
2. set up Python;
3. compile the FRP v1.7.0 reference file;
4. generate M15 qualification outputs;
5. compare deterministic vector packages;
6. validate schemas, kernel invariants, fixed-point contract, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture-document contract;
9. upload M15 qualification artifacts.

Current result:

`PASS`

## 69. Current Workflow Schema Validation

The M15 workflow validates:

`frp.structured_output.v1.7.0`

The workflow also validates all ten M15 export schemas and:

`frp.m3.benchmark_matrix.v1.7.0`

Current validated release-facing schema count:

`12`

Current result:

`PASS`

## 70. Current Release Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current validation environment:

`GitHub Actions hardware-backed CI execution`

Validated processor-evidence commit recorded in the release artifacts:

`5fd9a4f`

Recorded workflow stack:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Current overall published result:

`PASS`

## 71. Earlier Structured Output Workflow Layer

The repository also preserves the earlier workflow:

`../.github/workflows/frp-structured-output.yml`

Workflow name:

`FRP Structured Output`

This workflow validates the historical v0.9.4 structured-output layer.

Historical executable:

`frp_prototype_v0_9_4.py`

Historical schema:

`frp.structured_output.v0.9.4`

Historical workflow Python version:

`3.11`

Historical workflow subjects include:

- text self-test;
- text benchmark;
- JSON self-test;
- JSON benchmark;
- JSON demo;
- JSON telemetry demo.

The current v1.7.0 schema qualification is carried by the M15 workflow.

The earlier structured-output workflow remains a historical schema-validation layer.

## 72. Historical v0.9.4 Structured-Output Layer

The repository preserves the earlier v0.9.4 structured-output architecture as historical evidence.

Historical structured-output version:

`v0.9.4`

Historical schema marker:

`frp.structured_output.v0.9.4`

Historical executable:

`frp_prototype_v0_9_4.py`

Historical previous reference prototype:

`frp_prototype_v0_9_3_mobile.py`

The historical layer introduced machine-readable output around the earlier processor workflow.

Historical purposes included:

- automated validation;
- reproducibility checks;
- benchmark inspection;
- telemetry export;
- CI verification;
- external tooling;
- hardware-facing signal mapping preparation;
- FPGA testbench comparison preparation;
- ASIC validation comparison preparation.

## 73. Historical v0.9.4 Output Modes

Historical output modes:

| Output Mode | CLI Option | Role |
|---|---|---|
| text | `--output text` | human-readable console output |
| json | `--output json` | machine-readable structured output |

Historical default mode:

`--output text`

Historical structured mode:

`--output json`

Historical optional telemetry flag:

`--include-telemetry`

## 74. Historical v0.9.4 Command-Line Controls

Historical output-related arguments:

| Argument | Values | Default | Role |
|---|---|---|---|
| `--output` | `text`, `json` | `text` | selected console or structured output |
| `--include-telemetry` | flag | disabled | included per-tick telemetry where applicable |

Historical example:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Historical telemetry example:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

## 75. Historical Shared JSON Envelope

Historical common top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | historical schema marker |
| `project` | string | project name |
| `version` | string | prototype version |
| `kind` | string | output kind |
| `parameters` | object | command-line execution parameters |

Historical schema value:

`frp.structured_output.v0.9.4`

Historical project value:

`Fractal Resonance Processor`

Historical version value:

`v0.9.4`

Historical `kind` values:

- `demo`;
- `self_test`;
- `benchmark`.

## 76. Historical Parameters Object

Historical fields:

- `mode`;
- `N`;
- `steps`;
- `seeds`;
- `seed`;
- `amp`;
- `cycle_mode`;
- `gamma`;
- `logic_delay_ticks`;
- `coupling_delay_ticks`;
- `saturation_beta`;
- `compression_gain`;
- `transition_fraction`;
- `telemetry_every`;
- `output`;
- `include_telemetry`;
- `stop_on_fail`.

Historical scheduler values:

- `free`;
- `7/1`;
- `1/7`.

Historical default phase shift:

`gamma = 0.30 pi`

Historical default transition fraction:

`transition_fraction = 0.25`

## 77. Historical Demo JSON Output

Historical command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Historical top-level demo fields:

- `schema`;
- `project`;
- `version`;
- `kind`;
- `parameters`;
- `log`;
- `final_report`.

Historical `log` row fields:

- `pc`;
- `instruction`;
- `status`;
- `failures`;
- `result`.

Historical instruction fields:

- `op`;
- `dst`;
- `src_a`;
- `src_b`;
- `imm`;
- `comment`.

Historical supported processor instructions:

- `load`;
- `rand`;
- `zero`;
- `mov`;
- `neg`;
- `add`;
- `sub`;
- `compare`;
- `consensus`;
- `halt`.

Historical `final_report` fields:

- `instructions_executed`;
- `failures`;
- `halted`;
- `registers`.

## 78. Historical Operation Result Object

Historical operation result fields:

- `op`;
- `target`;
- `output`;
- `overflow`;
- `compare`;
- `match`;
- `summary`;
- `diag`;
- `telemetry`.

Historical telemetry inclusion control:

`--include-telemetry`

## 79. Historical Summary Object

Historical summary fields:

- `ticks_recorded`;
- `C_minus_P_min`;
- `C_minus_P_avg`;
- `heat_peak`;
- `heat_avg`;
- `switch_load_peak`;
- `switch_load_avg`;
- `neutral_peak`;
- `neutral_avg`;
- `logical_match_final`;
- `logical_match_avg`;
- `actual_direct_events_total`;
- `prevented_direct_events_total`;
- `neutralized_conflicts_total`.

Historical primary invariant fields:

| Field | Historical Required Condition |
|---|---|
| `ticks_recorded` | equals requested steps |
| `C_minus_P_min` | greater than zero |
| `switch_load_peak` | within transition fraction |
| `logical_match_final` | equals `1.000` |
| `actual_direct_events_total` | equals `0` |

## 80. Historical Diagnostic Object

Historical diagnostic fields:

- `C`;
- `P`;
- `C_minus_P`;
- `R`;
- `logical_match`;
- `actual_direct_events`;
- `prevented_direct_events`;
- `neutralized_conflicts`;
- `commits`;
- `excites`;
- `balances`;
- `neutralizes`.

Historical scheduler counts were checked against the selected cycle mode.

## 81. Historical Telemetry Object

Historical telemetry fields:

- `tick`;
- `phase`;
- `R`;
- `phi`;
- `neutral`;
- `positive`;
- `negative`;
- `heat`;
- `thermal_scale`;
- `switch_load`;
- `actual_direct_events_delta`;
- `prevented_direct_events_delta`;
- `neutralized_conflicts_delta`;
- `logical_match`;
- `transition_debt`;
- `direct_conflict_fraction`;
- `C`;
- `P`;
- `C_minus_P`.

Historical mapping path:

`Python model`

↓

`JSON telemetry`

↓

`benchmark export`

↓

`hardware-facing signal map`

↓

`FPGA register map`

↓

`testbench comparison`

The current M15 layer carries this output subject into deterministic fixed-point, trace, vector, interface, equivalence, and qualification schemas.

## 82. Historical Self-Test JSON Output

Historical command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Historical top-level fields:

- `schema`;
- `project`;
- `version`;
- `kind`;
- `parameters`;
- `metrics`;
- `failures`;
- `first_failure`;
- `result`.

Historical metrics fields:

- `runs`;
- `C_minus_P_min`;
- `heat_peak`;
- `switch_load_peak`;
- `actual_direct_events`;
- `prevented_direct_events`;
- `neutralized_conflicts`.

Historical expected result:

`PASS`

## 83. Historical First Failure Object

Historical `first_failure` fields:

- `N`;
- `seed`;
- `mode`;
- `op`;
- `fail`;
- `summary`;
- `diag`;
- `telemetry`.

Historical failure labels included:

- `match < 1.0`;
- `actual direct event`;
- `C-P <= 0`;
- `tick mismatch`;
- `scheduler mismatch`.

The current M15 self-test expresses validation detail through the 41-check registry and dedicated validation objects.

## 84. Historical Benchmark JSON Output

Historical command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Historical top-level fields:

- `schema`;
- `project`;
- `version`;
- `kind`;
- `parameters`;
- `architectures`;
- `benchmark_supported_position`.

Historical architecture fields:

- `architecture`;
- `cases`;
- `match`;
- `C_minus_P_min`;
- `heat_peak`;
- `switch_load_peak`;
- `actual_direct_events_total`;
- `prevented_direct_events_total`;
- `neutralized_conflicts_total`.

Historical architecture set:

- `binary_style_forced_switch`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `frp_distributed_resonant`.

Historical benchmark-supported technical position:

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.`

## 85. Historical Text Output Compatibility

Historical text self-test command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Historical key markers:

`FRP SELF TEST v0.9.4`

`failures=0`

`result=PASS`

Historical text benchmark command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Historical architecture labels:

- `binary_style_forced_switch`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `frp_distributed_resonant`.

## 86. Historical JSON Validation Markers

Historical validation markers:

| Marker | Historical Value |
|---|---|
| `schema` | `frp.structured_output.v0.9.4` |
| `version` | `v0.9.4` |
| `kind` | `self_test`, `benchmark`, or `demo` |
| `result` | `PASS` for successful self-test |
| `failures` | `0` for successful self-test |

Historical self-test CI checks included:

- JSON parsing;
- exact schema identity;
- exact version identity;
- self-test kind;
- result `PASS`;
- failures `0`;
- actual direct events `0`;
- positive minimum stability margin.

Historical benchmark CI checks included:

- JSON parsing;
- exact schema identity;
- exact version identity;
- benchmark kind;
- complete four-architecture label set.

## 87. Historical v0.9.4 Candidate Invariants

Historical candidate invariants:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

The current M15 layer carries the corresponding processor invariants into:

- quantized execution;
- exact fixed-point closure;
- deterministic traces;
- RTL vectors;
- semantic correlation;
- exact replay;
- qualification closure.

## 88. Output Evidence-Domain Separation

The repository preserves distinct output-schema and evidence domains.

### 88.1 Historical v0.9.4 structured-output contour

Primary schema:

`frp.structured_output.v0.9.4`

Primary executable:

`frp_prototype_v0_9_4.py`

Primary subjects:

- earlier text output;
- earlier JSON output;
- operation logs;
- operation summaries;
- diagnostic objects;
- optional telemetry;
- historical self-test JSON;
- historical architecture benchmark JSON.

### 88.2 Current FRP v1.7.0 structured-output contour

Primary schema:

`frp.structured_output.v1.7.0`

Primary executable:

`frp_prototype_v1_7_0.py`

Primary subjects:

- configuration identity;
- kernel identity;
- hardware profile;
- quantized execution summary;
- deterministic digests;
- optional complete processor-tick trace;
- optional complete per-cell trace;
- optional route-event trace;
- 41-check self-test qualification.

### 88.3 Current M15 benchmark contour

Primary schema:

`frp.m3.benchmark_matrix.v1.7.0`

Primary subject:

`five-stage implementation progression from M14 floating semantics through M15 qualification closure`

### 88.4 Current M15 hardware-facing export contour

Primary subjects:

- fixed-point interface;
- ternary encoding;
- quantized shadow execution;
- cycle-exact trace;
- deterministic vector package;
- SystemVerilog interface;
- RTL reference-core mapping;
- assertion correlation;
- equivalence;
- qualification closure.

Each contour retains its own:

- version;
- schema;
- executable;
- field set;
- workflow context;
- validation evidence.

## 89. Current Reproduction Commands

Compile the current executable:

    python -m py_compile ../frp_prototype_v1_7_0.py

Run compact structured output:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Run complete trace output:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run compact text output:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Run current self-test JSON:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Run current self-test text:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Run current benchmark matrix:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

## 90. Current M15 Export Commands

Fixed-point interface profile:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Balanced ternary hardware encoding map:

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Quantized reference shadow model:

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Cycle-exact reference trace:

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

RTL comparison vector package:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

SystemVerilog testbench interface map:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Synthesizable RTL reference core:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

RTL assertion correlation harness:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Reference RTL equivalence report:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Qualification closure manifest:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Benchmark matrix:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

## 91. Current File Alignment

This output schema document is aligned with:

- `../README.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`;
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
- `./fpga_mapping_study.md`;
- `./asic_mapping_study.md`;
- `./physical_validation_plan.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../models/README.md`;
- `../simulations/README.md`;
- `../examples/README.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Historical structured-output evidence remains aligned with:

- `../frp_prototype_v0_9_4.py`;
- `../.github/workflows/frp-structured-output.yml`.

Historical transition evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 92. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current M15 export-schema count:

`10`

Current release-facing schema count:

`12`

Current structured output:

`configuration + kernel + hardware profile + quantized summary + deterministic digests`

Current full trace output:

`processor-tick trace + per-cell trace + route-event trace`

Current self-test output:

`41-check qualification registry + detailed validation objects`

Current benchmark output:

`five-row M14-to-M15 implementation progression matrix`

Current M15 export output:

`fixed-point interface → balanced ternary encoding → quantized shadow → cycle-exact trace → deterministic vectors → SystemVerilog interface → RTL reference-core map → assertion correlation → equivalence → qualification closure`

Current self-test result:

`41/41 PASS`

Current semantic correlation result:

`PASS`

Current exact deterministic replay result:

`PASS`

Current vector regeneration result:

`10/10 files byte-identical`

Current qualification closure result:

`PASS`

Current published validation result:

`PASS`

Current output-schema role:

`provide deterministic machine-readable processor execution, qualification, hardware-facing implementation mapping, cycle-exact correlation, reproducibility, CI validation, and release evidence`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

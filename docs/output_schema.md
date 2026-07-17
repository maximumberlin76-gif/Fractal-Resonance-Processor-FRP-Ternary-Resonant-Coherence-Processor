# Output Schema — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the console, structured JSON, benchmark-matrix, deterministic trace, hardware-facing export, equivalence, qualification-closure, and M16 execution-evidence output schemas for the Fractal Resonance Processor (FRP) project.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Structured-output schema:

`frp.structured_output.v1.7.0`

Benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 export-schema count:

`10`

Total release-facing schema count:

`12`

Current architecture document:

`./m16_rtl_core_realization_execution_semantics.md`

Current test report:

`../TEST_REPORT_v1_8_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`../RELEASE_NOTES_v1_8_0.md`

Current primary qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Validated qualification result:

`PASS`

Inherited M15 self-test result:

`41/41 PASS`

## 1. Purpose

The FRP output layer provides machine-readable and human-readable representations of:

- processor configuration;
- balanced ternary kernel identity;
- hardware-facing numeric profile;
- deterministic quantized execution;
- execution summary;
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
- qualification closure;
- M16 RTL execution evidence;
- M16 scheduler-state execution;
- M16 request-lane arbitration;
- M16 active-neutral routing;
- M16 retained pending-route behavior;
- M16 transition-capacity enforcement;
- M16 retained-state writeback;
- M16 integrated invariant evaluation;
- M16 FPGA preparation evidence.

The structured-output chain is:

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

`inherited M15 export schemas`

↓

`semantic correlation`

↓

`exact deterministic replay`

↓

`M15 qualification closure`

↓

`M16 RTL execution evidence`

↓

`M16 FPGA preparation evidence`

The output layer supports:

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

## 2. Output Architecture

The qualified executable semantic reference exposes four output families.

| Output Family | Primary Role |
|---|---|
| structured processor output | processor configuration, kernel, hardware profile, summary, and optional traces |
| self-test output | 41-check inherited M15 qualification registry and detailed validation objects |
| benchmark matrix | five-row implementation progression from M14 floating semantics through M15 qualification closure |
| M15 export package | ten hardware-facing implementation-mapping and qualification schemas |

The release-facing schema chain is:

`frp.structured_output.v1.7.0`

+

`frp.m3.benchmark_matrix.v1.7.0`

+

`10 inherited M15 export schemas`

=

`12 release-facing schemas`

Validated release-facing schema count:

`12`

Validation result:

`PASS`

The M16 layer adds executable RTL and FPGA qualification evidence while retaining the qualified M15 structured-output and export-schema identities.

## 3. Output Modes

The qualified executable semantic reference supports two presentation formats:

| Output Mode | CLI Option | Role |
|---|---|---|
| text | `--output text` | compact human-readable report |
| json | `--output json` | machine-readable structured output |

Default output mode:

`text`

JSON mode:

`json`

Demo behavior:

- text output through `--output text`;
- structured JSON through `--output json`;
- complete trace inclusion through `--include-trace`.

Self-test behavior:

- compact text report through `--output text`;
- complete qualification object through `--output json`.

Benchmark behavior:

- benchmark-matrix JSON output.

Export behavior:

- every inherited M15 export flag produces JSON.

M16 RTL and FPGA qualification evidence is recorded through:

- executable SystemVerilog testbench output;
- invariant flags;
- event counters;
- scheduler counters;
- retained-state and pending-route observations;
- GitHub Actions qualification records;
- simulation transcripts;
- closure records.

## 4. Command-Line Output Controls

Primary mode arguments:

| Argument | Values | Default | Role |
|---|---|---|---|
| `--mode` | `demo`, `self-test`, `benchmark` | `demo` | selects execution family |
| `--output` | `text`, `json` | `text` | selects presentation format |
| `--include-trace` | flag | disabled | adds complete demo trace objects |

Execution-profile arguments:

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

Cell-count requirement:

`cells = power of two and cells >= 2`

## 5. Qualified Semantic-Reference Execution Commands

Default structured demo:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Full trace:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Text demo:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Self-test JSON:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Self-test text:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Benchmark matrix:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

Equivalent benchmark export:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

These commands execute the qualified FRP v1.7.0 semantic reference retained by the FRP v1.8.0 / M16 release package.

## 6. Stable Inherited v1.7.0 Schema Registry

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 export schemas:

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

Inherited release-facing schema count:

`12`

Inherited M15 self-test schema-count markers:

`export_schema_count_10 = True`

`all_export_schemas_exact = True`

The M16 executable RTL and FPGA preparation layers retain these schema identifiers without renaming or rewriting the qualified M15 output contract.

## 7. Shared Inherited Release-Facing Envelope

The qualified structured and exported JSON objects use the following common identity fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | exact schema identifier |
| `kind` | string | output or artifact type |
| `version` | string | semantic-reference version |
| `milestone` | string | inherited semantic-reference milestone identity |

Qualified semantic-reference version value:

`1.7.0`

Inherited milestone value:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

These values identify the retained M15 semantic-reference and export artifacts. They do not redefine the repository release state, which is:

`FRP v1.8.0 / M16`

JSON serialization:

- two-space indentation;
- sorted keys;
- Unicode preservation.

The qualified executable prints structured JSON through:

`json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False)`

## 8. Canonical Digest Serialization

Digest-producing objects use canonical JSON bytes.

Canonical serialization properties:

- sorted keys;
- compact separators;
- Unicode preservation;
- trailing newline;
- UTF-8 encoding.

Canonical relation:

`canonical JSON object`

↓

`UTF-8 bytes`

↓

`SHA-256`

Digest function:

`sha256`

Digest representation:

`64-character lowercase hexadecimal string`

This digest structure is used for:

- preload identity;
- processor-tick trace identity;
- per-cell trace identity;
- deterministic vector-package integrity.

## 9. Qualified Semantic-Reference Demo JSON Output

Command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | `frp.structured_output.v1.7.0` |
| `kind` | string | `demo` |
| `version` | string | `1.7.0` semantic-reference identity |
| `milestone` | string | inherited M15 milestone identity |
| `configuration` | object | execution profile |
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

The demo JSON remains an inherited qualified M15 semantic-reference artifact inside the FRP v1.8.0 / M16 release package.

## 10. Configuration Object

The inherited M15 `configuration` object records the complete primary execution profile of the qualified semantic reference.

Fields:

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

Qualified default configuration:

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

The inherited M15 `kernel` object identifies the processor kernel carried by the qualified structured output.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `balanced_ternary_states` | array | ternary state domain |
| `active_neutral_state` | integer | active neutral state |
| `neutral_routes` | array | mandatory opposite-polarity routes |
| `scheduler_modes` | array | available scheduler modes |
| `actual_direct_events_target` | integer | validated direct-event target |

Qualified values:

`balanced_ternary_states = [-1, 0, 1]`

`active_neutral_state = 0`

Neutral routes:

`-1 -> 0 -> 1`

`1 -> 0 -> -1`

Scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Direct-event target:

`actual_direct_events_target = 0`

## 12. Hardware Profile Object

The inherited M15 `hardware_profile` object records the primary hardware-facing numeric and encoding domains.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `scalar` | string | general dynamic scalar representation |
| `unit` | string | normalized coefficient representation |
| `phase` | string | phase representation |
| `gamma` | string | Sakaguchi gamma representation |
| `state_encoding` | object | balanced ternary encoding |

Qualified values:

`scalar = S32Q16`

`unit = S32Q30`

`phase = PHASE_U32`

`gamma = GAMMA_S32`

State encoding:

| Ternary State | Two-Bit Encoding |
|---|---|
| `-1` | `11` |
| `0` | `00` |
| `1` | `01` |
| reserved | `10` |

The M16 RTL execution layer retains the same canonical balanced ternary state encoding.

## 13. Summary Object

The inherited M15 demo and quantized-shadow `summary` object records aggregate execution state and validated invariants.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `version` | string | semantic-reference version |
| `milestone` | string | semantic-reference milestone identity |
| `cells` | integer | cell count |
| `hierarchy_depth` | integer | dyadic hierarchy depth |
| `request_lanes` | integer | request-lane count |
| `steps` | integer | requested tick count |
| `ticks_recorded` | integer | recorded tick count |
| `scheduler` | string | scheduler mode |
| `scheduler_counts` | object | scheduler-state counts |
| `scheduler_counts_valid` | boolean | scheduler-count validation |
| `transition_fraction` | number | distributed commit fraction |
| `balanced_ternary_state_domain` | boolean | state-domain validation |
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

## 14. Qualified Default Summary Evidence

The qualified default semantic-reference execution records:

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

Qualified result:

`PASS`

## 15. Digest Fields

The compact inherited M15 demo output records three deterministic digests.

| Field | Source |
|---|---|
| `preload_digest` | canonical preload object |
| `trace_digest` | canonical processor-tick trace |
| `cell_trace_digest` | canonical per-cell trace |

Qualified default execution digests:

`preload_digest = fbd4ce8153133a30bacb4004ef6b126858e64da1f464b763439d29fd8c98b5af`

`trace_digest = 06be197a6f7620796daad6420091e21392295cb0e182b394da2d9990324415be`

`cell_trace_digest = ba7d5f5a5f45d1c6808a0d4c7d7f612916bb2e2c4d33faf5e182810d704ad544`

These values correspond to the qualified default deterministic semantic-reference execution profile.

## 16. Full Trace Mode

Command:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Full trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Qualified default trace lengths:

`trace = 64 rows`

`cell_trace = 1024 rows`

Trace relation:

`64 ticks × 16 cells = 1024 cell-trace rows`

The same digests remain present in the full trace output.

## 17. Processor-Tick Trace Row

Each inherited M15 `trace` row records one post-tick quantized processor state.

Fields:

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
| `switch_load_q16` | integer | transition load |
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
| `changes` | integer | state changes for the recorded tick |

The trace row is the primary cycle-exact integer comparison unit of the inherited M15 reference package.

## 18. Scheduler Encoding in Trace Rows

Scheduler-mode encoding:

| Mode | Code |
|---|---:|
| `free` | `0` |
| `7/1` | `1` |
| `1/7` | `2` |

Scheduler-state encoding:

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

The M16 RTL execution layer retains the same scheduler-mode and scheduler-state identities.

## 19. Packed Ternary State Fields

Trace state fields:

- `states_packed`;
- `states_packed_hex`;
- `states_human`.

Human-state symbols:

| Ternary State | Human Symbol |
|---|---|
| `-1` | `M` |
| `0` | `N` |
| `1` | `P` |

Packed-state relation:

`2 bits per cell`

Qualified default packed width:

`32 bits`

Cell mapping:

`cell i → [2i+1:2i]`

The M16 retained-state boundary uses the same two-bit-per-cell balanced ternary encoding.

## 20. Per-Cell Trace Row

Each inherited M15 `cell_trace` row records one cell at one processor tick.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | processor-tick index |
| `cell_id` | integer | cell identifier |
| `state_code` | integer | encoded balanced ternary state |
| `phase_word` | integer | `PHASE_U32` state |
| `frequency_target_q16` | integer | target frequency |
| `frequency_current_q16` | integer | delayed frequency state |
| `frequency_lag_q16` | integer | remaining frequency lag |
| `generated_power_q16` | integer | generated-power state |
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

Each inherited M15 `route_events` row records one pending or applied active-neutral route event.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | event tick |
| `cell_id` | integer | affected cell |
| `target_state` | integer | retained target polarity |
| `ready_tick` | integer | earliest route-completion tick |
| `route_status` | string | route event state |

Route-status values:

- `pending`;
- `applied`.

Route relation:

`opposite-polarity request`

↓

`retained state → 0`

↓

`pending route event`

↓

`ready tick retained`

↓

`applied route event`

↓

`0 → target polarity`

The M16 RTL execution layer implements the same tick-separated active-neutral route relation through retained pending-route state.

## 22. Text Output Compatibility

The compact text output remains available for demo and self-test modes of the qualified semantic reference.

Demo text command:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Demo text fields include:

- FRP semantic-reference version;
- inherited milestone identity;
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

Qualified default demo text markers:

`FRP v1.7.0`

`kind: demo`

`balanced_ternary_state_domain: True`

`reserved_state_events: 0`

`actual_direct_events: 0`

`C_minus_P_min: 0.6142730712890625`

Self-test text command:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Qualified self-test text markers:

`FRP v1.7.0`

`kind: self_test`

`status: PASS`

`check_count: 41`

These markers identify the inherited M15 semantic-reference output and do not redefine the repository release state.

## 23. Self-Test JSON Output

Command:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | `frp.structured_output.v1.7.0` |
| `kind` | string | `self_test` |
| `version` | string | `1.7.0` semantic-reference identity |
| `milestone` | string | inherited M15 milestone identity |
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

Qualified status:

`PASS`

Qualified check count:

`41`

## 24. Qualified 41-Check Registry

Check registry:

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

Required result:

`all 41 values = True`

Qualified result:

`41/41 PASS`

## 25. Benchmark Matrix Output

Command:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

Schema:

`frp.m3.benchmark_matrix.v1.7.0`

Top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | benchmark schema identifier |
| `kind` | string | benchmark matrix |
| `version` | string | semantic-reference version |
| `milestone` | string | inherited semantic-reference milestone |
| `rows` | array | implementation progression |
| `qualification` | object | benchmark qualification summary |

The benchmark matrix remains the qualified inherited M15 benchmark artifact retained by the FRP v1.8.0 / M16 release.

## 26. Benchmark Matrix Rows

The qualified benchmark matrix records five implementation layers.

| Layer | Description |
|---|---|
| M11 | floating semantic reference |
| M12 | balanced ternary transition architecture |
| M13 | thermal and delay semantic model |
| M14 | implementation mapping |
| M15 | qualification closure |

Each benchmark row records:

- implementation layer;
- execution profile;
- scheduler mode;
- deterministic execution;
- active-neutral routing;
- dynamic-stability metrics;
- thermal metrics;
- validation status.

The benchmark matrix is retained unchanged for cross-release reproducibility.

## 27. Export Schema Package

The inherited M15 export package contains ten qualified implementation artifacts.

Export package:

1. fixed-point interface profile;
2. balanced ternary hardware encoding map;
3. quantized reference shadow model;
4. cycle-exact reference trace;
5. RTL comparison vector package;
6. SystemVerilog interface map;
7. synthesizable RTL reference core;
8. RTL assertion correlation harness;
9. reference RTL equivalence report;
10. qualification closure manifest.

Qualified export count:

`10`

Qualified result:

`PASS`

The M16 execution layer consumes these artifacts without changing their schema identities.

## 28. M16 Execution Evidence

The M16 release extends the inherited semantic-reference package with executable RTL qualification evidence.

Evidence sources include:

- synthesizable SystemVerilog modules;
- executable RTL testbench;
- deterministic scheduler execution;
- request-lane arbitration;
- retained pending-route execution;
- active-neutral transition execution;
- transition-capacity enforcement;
- retained-state writeback;
- invariant verification;
- simulation transcript;
- qualification closure;
- FPGA preparation layer.

These artifacts supplement the inherited semantic-reference package while preserving the qualified output schemas.

## 29. FPGA Preparation Evidence

The FPGA preparation layer records:

- top-level FPGA wrapper;
- FPGA-oriented testbench;
- implementation mapping;
- execution transcript;
- qualification closure;
- workflow qualification.

The FPGA preparation package preserves semantic equivalence with the inherited M15 reference while extending executable implementation evidence.

## 30. Release Compatibility

FRP v1.8.0 preserves compatibility with the qualified structured-output package.

Retained components:

- executable semantic reference;
- structured-output schema;
- benchmark schema;
- export schemas;
- deterministic digests;
- balanced ternary encoding;
- scheduler encoding;
- request-lane ordering;
- active-neutral routing semantics;
- deterministic replay.

Repository additions in M16:

- RTL execution layer;
- executable SystemVerilog package;
- simulation transcript;
- qualification closure;
- FPGA preparation layer.

## 31. Output Stability Statement

The structured-output contract remains stable across the FRP v1.8.0 / M16 release.

The retained semantic-reference executable continues to generate:

- deterministic structured JSON;
- deterministic benchmark matrices;
- deterministic export artifacts;
- deterministic trace digests;
- deterministic validation evidence.

The M16 release extends executable implementation evidence while preserving the qualified structured-output contract established by the inherited M15 semantic-reference package.

## 25. Neutral Route Validation Object

The inherited M15 `neutral_route_validation` object contains:

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

Qualified route validation result:

`PASS`

The M16 RTL execution layer retains the same tick-separated active-neutral route semantics.

## 26. Scheduler Validation Object

The inherited M15 `scheduler_validation` object contains:

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

Qualified result for all scheduler modes:

`PASS`

The M16 scheduler execution layer retains the same three scheduler modes and their encoded execution states.

## 27. Request-Lane Order Validation Object

The inherited M15 `request_lane_order_validation` object contains:

- `checks`;
- `summary`;
- `status`.

Qualified checks include:

- request lanes at least two;
- lane zero applied first;
- lane one opposite request intercepted;
- same-tick result neutral;
- pending target equals negative one;
- actual direct events remain zero.

Qualified status:

`PASS`

The M16 request-lane arbitration layer preserves deterministic lane ordering and active-neutral interception.

## 28. Queue Exhaustion Validation Object

The inherited M15 `queue_exhaustion_validation` object contains:

- `checks`;
- `summary`;
- `status`.

Qualified checks include:

- queue capacity equals cell count;
- queue length remains bounded;
- overflow detection activates under the dedicated exhaustion test;
- same-tick result remains neutral;
- actual direct events remain zero.

Qualified status:

`PASS`

The M16 retained pending-route layer preserves bounded pending-route storage and queue-overflow accounting.

## 29. Fixed-Point Validation Object

The inherited M15 `fixed_point_validation` object contains:

- `checks`;
- `status`.

Qualified checks include:

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

Qualified status:

`PASS`

These fixed-point validation results remain the arithmetic reference for M16 RTL execution correlation.

## 30. Encoding Validation Object

The inherited M15 `encoding_validation` object contains:

- `sample_states`;
- `packed_hex`;
- `checks`;
- `status`.

Qualified checks include:

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

Qualified status:

`PASS`

The M16 RTL package retains the same balanced ternary state codes, packed-state order, scheduler-mode codes, and scheduler-state codes.

## 31. Topology Validation Object

The inherited M15 `topology_validation` object contains profiles for:

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

Qualified status for all three profiles:

`PASS`

The validated topology profiles remain the fixed-point topology reference for the FRP v1.8.0 / M16 release package.

## 32. Trigonometric LUT Validation Object

The inherited M15 `trigonometric_lut_validation` object contains:

- `checks`;
- `sha256`;
- `status`.

Qualified checks include:

- entry count;
- sine zero;
- sine quarter cycle;
- sine half cycle;
- cosine relation;
- deterministic rebuild.

Qualified trigonometric lookup SHA-256:

`acb0dfe2c00998840f9ca00f9ef9e3b46011db6c745faa59a9db13c4121cc57b`

Qualified status:

`PASS`

The validated lookup-table identity remains the trigonometric arithmetic reference for M16 RTL execution correlation.

## 33. Semantic Correlation Object

The inherited M15 `semantic_correlation` object compares:

`floating semantic reference`

with:

`quantized hardware shadow`

Qualified sequence-correlation fields:

| Field | Qualified Value |
|---|---:|
| `state_sequence_match` | `1.0` |
| `scheduler_sequence_match` | `1.0` |
| `neutral_route_sequence_match` | `1.0` |
| `C_minus_P_sign_match` | `1.0` |
| `boundary_order_match` | `1.0` |

Recorded error fields:

- `max_phase_error`;
- `max_frequency_error`;
- `max_heat_error`;
- `max_gamma_error`;
- `max_coherence_error`;
- `max_C_error`;
- `max_P_error`;
- `max_C_minus_P_error`.

Recorded boundary fields:

- `float_boundary_tick`;
- `shadow_boundary_tick`.

Recorded summary objects:

- `float_summary`;
- `shadow_summary`.

Qualified semantic-correlation result:

`PASS`

This correlation object remains the inherited semantic comparison basis for the M16 executable RTL layer.

## 34. Exact Shadow Replay Object

The inherited M15 `exact_shadow_replay` fields are:

| Field | Qualified Value |
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

Qualified exact deterministic replay result:

`PASS`

The M16 RTL execution package retains these deterministic replay identities as implementation-correlation evidence.

## 35. Vector Determinism Object

The inherited M15 `vector_determinism` object contains:

- `checks`;
- `byte_matches`;
- `manifest`;
- `package_digest`;
- `status`.

Qualified checks include:

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

Qualified deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

Qualified file count:

`10`

Independent regeneration result:

`10/10 files byte-identical`

Qualified status:

`PASS`

The deterministic vector package remains the inherited replay input set for M16 RTL qualification.

## 36. Scaling Validation Object

The inherited M15 `scaling_validation` object contains:

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

Qualified scaling results:

| Cells | Hierarchy Depth | Request Lanes | `C_minus_P_min` | Switch Load Peak |
|---|---:|---:|---:|---:|
| `8` | `3` | `2` | `0.828887939453125` | `0.25` |
| `16` | `4` | `4` | `0.6142730712890625` | `0.25` |
| `32` | `5` | `8` | `0.6628875732421875` | `0.25` |

Qualified status for all profiles:

`PASS`

These validated scaling profiles remain the inherited fixed-point execution reference for FRP v1.8.0 / M16.

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

Inherited M15 vector classes:

- `kernel_transition_vectors`;
- `scheduler_vectors`;
- `full_correlation_vectors`.

Manifest fields:

- `file_count`;
- `files`.

Qualified file count:

`10`

Qualified deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The deterministic vector package remains the inherited exact replay input set for FRP v1.8.0 / M16 RTL qualification.

## 48. Vector Package Files

Qualified files:

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

Qualified independent regeneration result:

`10/10 files byte-identical`

## 49. Vector Output Directory

Optional command:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir <directory>

Role:

`write the deterministic inherited M15 vector package into the selected directory`

The JSON export remains available together with the written package.

The generated vectors provide exact deterministic replay inputs for the M16 executable RTL layer.

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

Qualified inherited M15 parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The M16 executable RTL package retains these interface dimensions for correlation with the inherited SystemVerilog contract.

## 51. SystemVerilog Execution Inputs

Execution inputs:

- `clk`;
- `reset_n`;
- `scheduler_mode`;
- `auto_targets_enable`;
- `request_valid`;
- `request_cell_id`;
- `request_target_state`.

Verification stimulus inputs:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Comparison outputs include:

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

These inputs and outputs define the inherited exact integer correlation boundary used by the FRP v1.8.0 / M16 RTL execution package.

## 52. Vector Replay Order

The inherited M15 vector replay order contains nine stages:

1. parse vector row;
2. drive input signals before active clock edge;
3. apply verification sideband stimulus;
4. execute one processor clock edge;
5. allow registered outputs to settle;
6. sample post-tick outputs;
7. compare sampled outputs against expected integer values;
8. execute invariant assertions;
9. stop immediately on mismatch.

Exact integer comparison rule:

`actual integer field == expected integer field`

This replay order remains the deterministic comparison procedure used by the M16 executable RTL qualification layer.

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

Inherited M15 mapped RTL file count:

`13`

Exact tick-order count:

`26`

This export remains the qualified implementation map inherited by the FRP v1.8.0 / M16 executable RTL package.

## 54. Inherited M15 RTL Mapping Set

The inherited M15 reference-core export maps the following RTL domains:

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

These paths identify the inherited M15 implementation-mapping contract. The current executable RTL realization is provided by the M16 RTL package under:

`rtl/m16/`

## 55. Exact Tick Execution Order

The inherited exact 26-stage execution order is:

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

This sequence defines the inherited cycle-correlation order retained by the M16 RTL execution layer.

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

Inherited assertion count:

`13`

Exact comparison rule:

`actual integer field == expected integer field`

The M16 executable RTL package retains these assertion domains and exact integer comparison rules as qualification evidence.

## 57. Assertion Domains

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

These assertion domains remain the inherited qualification basis for the FRP v1.8.0 / M16 executable RTL package.

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

The report carries two inherited correlation boundaries:

`floating semantic reference → quantized hardware shadow`

and:

`quantized hardware shadow → exact deterministic replay`

The M16 RTL execution layer extends this chain with executable SystemVerilog qualification evidence while preserving both inherited correlation boundaries.

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

Inherited M15 artifact layer count:

`10`

Qualified status:

`PASS`

The qualification closure manifest remains the inherited semantic-reference closure record retained by FRP v1.8.0 / M16.

## 60. Qualification Closure Checks

Inherited M15 qualification-closure checks include:

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

Qualified result:

`PASS`

The M16 package adds RTL artifact-boundary and FPGA preparation qualification without changing these inherited closure checks.

## 61. Primary Validation Markers

Qualified structured-output validation markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `milestone` | inherited M15 milestone identity |
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

Qualified self-test markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `kind` | `self_test` |
| `status` | `PASS` |
| `check_count` | `41` |
| `len(checks)` | `41` |
| every `checks` value | `True` |

These markers identify the inherited M15 semantic-reference output contract retained by the FRP v1.8.0 / M16 release package.

## 62. Benchmark Validation Markers

Qualified inherited benchmark markers:

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

Qualified semantic markers:

`state_sequence_match = 1.0`

`scheduler_sequence_match = 1.0`

`C_minus_P_sign_match = 1.0`

Qualified vector marker:

`vector_repeat_match = 1.0`

Qualified artifact-layer count:

`10`

These markers belong to the inherited M15 benchmark and qualification package retained by FRP v1.8.0 / M16.

## 63. CI Checks for Structured Demo Output

Structured demo checks:

- JSON parses successfully;
- `schema` equals `frp.structured_output.v1.7.0`;
- `version` equals `1.7.0`;
- `milestone` equals the inherited M15 milestone identity;
- `kind` equals `demo`;
- `summary.cells` equals the selected cell count;
- `summary.ticks_recorded` equals the selected step count;
- `summary.scheduler` equals the selected scheduler;
- `summary.scheduler_counts_valid` equals `True`;
- `summary.balanced_ternary_state_domain` equals `True`;
- `summary.reserved_state_events` equals `0`;
- `summary.actual_direct_events` equals `0`;
- `summary.queue_overflow_events` equals `0`;
- `summary.switch_load_peak` stays within the transition fraction;
- `summary.C_minus_P_min` stays positive;
- topology fixed-point exactness equals `True`;
- thermal fixed-point exactness equals `True`;
- digest fields contain 64 hexadecimal characters.

These checks validate the retained semantic-reference output contract.

## 64. CI Checks for Full Trace Output

Full trace checks:

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

These checks preserve deterministic trace compatibility between the inherited M15 reference package and the M16 execution layer.

## 65. CI Checks for Inherited M15 Exports

Inherited M15 export checks:

- every export parses as JSON;
- every export schema equals its exact v1.7.0 schema;
- every export version equals `1.7.0`;
- every export milestone equals the inherited M15 milestone identity;
- M15 export-schema count equals `10`;
- artifact-layer count equals `10`;
- fixed-point topology sum exactness equals `True`;
- fixed-point thermal sum exactness equals `True`;
- balanced ternary encoding equals `{-1: 3, 0: 0, 1: 1}`;
- reserved integer state code equals `2`;
- deterministic vector file count equals `10`;
- deterministic package digest contains 64 hexadecimal characters;
- SystemVerilog parameters equal the inherited interface contract;
- assertion count equals `13`;
- exact tick execution order contains `26` stages;
- semantic sequence matches equal `1.0`;
- exact deterministic replay matches equal `1.0`;
- qualification closure status equals `PASS`.

These checks preserve the qualified M15 export boundary used by the FRP v1.8.0 / M16 package.

## 66. GitHub Actions Validation Context

Primary M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Job name:

`M16 RTL Architecture Qualification`

Execution environment:

`ubuntu-latest`

Timeout:

`20 minutes`

Permissions:

`contents: read`

Trigger:

`workflow_dispatch`

Primary M16 FPGA qualification workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Workflow name:

`FRP M16 FPGA Preparation`

Job name:

`M16 FPGA Integration Qualification`

Execution environment:

`ubuntu-latest`

Timeout:

`20 minutes`

Permissions:

`contents: read`

Trigger:

`workflow_dispatch`

The inherited M15 implementation-mapping workflow remains preserved as qualification evidence for the semantic-reference and export-schema package.

## 67. Inherited M15 Workflow Output Generation

The inherited M15 qualification workflow generates:

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

These outputs remain the qualified semantic-reference and implementation-mapping evidence inherited by FRP v1.8.0 / M16.

## 68. M16 Qualification Workflow Stages

The M16 qualification stack contains two executable workflow layers.

### 68.1 RTL Artifact Boundary

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Qualification stages:

1. checkout repository;
2. install the SystemVerilog execution toolchain;
3. validate the M16 RTL artifact inventory;
4. validate the M16 RTL documentation inventory;
5. parse the SystemVerilog package and modules;
6. elaborate the integrated RTL core and testbench;
7. reject combinational latch diagnostics;
8. build the executable testbench;
9. execute scheduler-mode qualification;
10. execute request-lane arbitration;
11. execute active-neutral routing;
12. execute retained pending-route completion;
13. execute transition-capacity enforcement;
14. execute retained-state writeback;
15. evaluate the ten integrated invariant flags;
16. validate repository integrity;
17. upload qualification evidence.

Qualified result:

`PASS`

### 68.2 FPGA Preparation

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Qualification stages:

1. checkout repository;
2. install the SystemVerilog execution toolchain;
3. validate the FPGA artifact inventory;
4. validate the inherited M16 RTL dependency inventory;
5. parse and elaborate the FPGA integration top;
6. build and execute the FPGA testbench;
7. reject latch and multidriven diagnostics;
8. validate asynchronous external reset assertion;
9. validate two-stage synchronous reset release;
10. validate `core_ready` generation;
11. validate execution-input gating before readiness;
12. validate scheduler propagation;
13. validate request propagation;
14. validate active-neutral routing;
15. validate retained pending-route completion;
16. evaluate the ten integrated invariant flags;
17. validate repository integrity;
18. upload qualification evidence.

Qualified result:

`PASS`

## 69. Workflow Schema and Execution Validation

The inherited M15 workflow validates:

`frp.structured_output.v1.7.0`

The inherited workflow also validates all ten M15 export schemas and:

`frp.m3.benchmark_matrix.v1.7.0`

Validated inherited release-facing schema count:

`12`

The M16 RTL workflow validates the executable realization of:

- balanced ternary retained-state encoding;
- scheduler-mode and scheduler-state execution;
- deterministic request-lane arbitration;
- retained pending polarity;
- active-neutral routing;
- transition-capacity enforcement;
- retained-state writeback;
- integrated invariant evaluation;
- zero actual direct events;
- zero reserved-state events;
- zero queue-overflow events.

The M16 FPGA workflow validates:

- FPGA integration-top parsing and elaboration;
- executable FPGA testbench behavior;
- reset synchronization;
- readiness gating;
- scheduler and request propagation;
- retained pending-route completion;
- active-neutral routing;
- integrated invariant preservation.

Current result:

`PASS`

## 70. FRP v1.8.0 Release Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Validation environment:

`GitHub Actions SystemVerilog execution and qualification`

Qualified M16 RTL workflow records:

| Workflow Run | Qualified Commit | Result | Duration |
|---|---|---|---|
| `#82` | `a68a2af` | `SUCCESS` | recorded in the RTL closure artifact |
| `#84` | `ede53cf` | `SUCCESS` | `52s` |

Qualified M16 FPGA preparation workflow records:

| Workflow Run | Qualified Commit | Result | Duration |
|---|---|---|---|
| `#1` | `326b69e` | `SUCCESS` | `1m 7s` |
| `#2` | `ede53cf` | `SUCCESS` | `36s` |

Inherited semantic-reference qualification:

`M15 self-test suite — 41/41 PASS`

M16 RTL qualification:

`PASS`

M16 FPGA preparation qualification:

`PASS`

Current overall release result:

`FRP v1.8.0 / M16 — PASS`

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

The qualified v1.7.0 schema is retained by the inherited M15 workflow and remains part of the FRP v1.8.0 / M16 release package.

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

The inherited M15 layer carries this output subject into deterministic fixed-point, trace, vector, interface, equivalence, and qualification schemas retained by FRP v1.8.0 / M16.

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

The inherited M15 self-test expresses validation detail through the 41-check registry and dedicated validation objects retained by FRP v1.8.0 / M16.

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

The inherited M15 layer carries the corresponding processor invariants into:

- quantized execution;
- exact fixed-point closure;
- deterministic traces;
- RTL vectors;
- semantic correlation;
- exact replay;
- qualification closure.

The M16 layer carries the same invariant domains into executable RTL and FPGA preparation qualification.

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

### 88.2 Inherited FRP v1.7.0 structured-output contour

Primary schema:

`frp.structured_output.v1.7.0`

Qualified executable semantic reference:

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

### 88.3 Inherited M15 benchmark contour

Primary schema:

`frp.m3.benchmark_matrix.v1.7.0`

Primary subject:

`five-stage implementation progression from M14 floating semantics through M15 qualification closure`

### 88.4 Inherited M15 hardware-facing export contour

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

### 88.5 Current M16 executable RTL contour

Primary subjects:

- synthesizable RTL realization;
- scheduler-state execution;
- request-lane arbitration;
- active-neutral routing;
- retained pending-route behavior;
- transition-capacity enforcement;
- retained-state writeback;
- integrated invariant evaluation;
- executable SystemVerilog testbench;
- RTL simulation transcript;
- RTL qualification closure.

### 88.6 Current M16 FPGA preparation contour

Primary subjects:

- FPGA integration top;
- FPGA-oriented testbench;
- reset synchronization;
- readiness gating;
- scheduler propagation;
- request propagation;
- active-neutral route completion;
- integrated invariant preservation;
- FPGA simulation transcript;
- FPGA qualification closure.

Each contour retains its own:

- version;
- schema or artifact identity;
- executable;
- field set;
- workflow context;
- validation evidence.

## 89. Current Reproduction Commands

Compile the qualified semantic-reference executable:

    python -m py_compile ../frp_prototype_v1_7_0.py

Run compact structured output:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Run complete trace output:

    python ../frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run compact text output:

    python ../frp_prototype_v1_7_0.py --mode demo --output text

Run self-test JSON:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Run self-test text:

    python ../frp_prototype_v1_7_0.py --mode self-test --output text

Run benchmark matrix:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

These commands reproduce the inherited qualified semantic-reference outputs retained by FRP v1.8.0 / M16.

## 90. Inherited M15 Export Commands

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
- `./fpga_mapping_study.md`;
- `./asic_mapping_study.md`;
- `./physical_validation_plan.md`;
- `./benchmark_interpretation.md`;
- `./limitations.md`;
- `./m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `./m16_rtl_core_realization_execution_semantics.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../models/README.md`;
- `../simulations/README.md`;
- `../examples/README.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`.

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

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Qualified executable semantic reference:

`../frp_prototype_v1_7_0.py`

Qualified structured-output schema:

`frp.structured_output.v1.7.0`

Qualified benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 export-schema count:

`10`

Release-facing schema count:

`12`

Current structured output:

`configuration + kernel + hardware profile + quantized summary + deterministic digests`

Current full trace output:

`processor-tick trace + per-cell trace + route-event trace`

Current self-test output:

`41-check qualification registry + detailed validation objects`

Current benchmark output:

`five-row M14-to-M15 implementation progression matrix`

Inherited M15 export output:

`fixed-point interface → balanced ternary encoding → quantized shadow → cycle-exact trace → deterministic vectors → SystemVerilog interface → RTL reference-core map → assertion correlation → equivalence → qualification closure`

Current M16 executable evidence:

`RTL core realization → scheduler execution → request-lane arbitration → active-neutral routing → retained pending routes → transition-capacity enforcement → retained-state writeback → integrated invariant evaluation`

Current M16 FPGA preparation evidence:

`FPGA integration top → reset synchronization → readiness gating → scheduler and request propagation → retained route completion → integrated invariant preservation`

Inherited self-test result:

`41/41 PASS`

Inherited semantic correlation result:

`PASS`

Inherited exact deterministic replay result:

`PASS`

Inherited vector regeneration result:

`10/10 files byte-identical`

Inherited M15 qualification closure result:

`PASS`

M16 RTL qualification result:

`PASS`

M16 FPGA preparation qualification result:

`PASS`

Current published validation result:

`PASS`

Current output-schema role:

`provide deterministic machine-readable processor execution, qualification, hardware-facing implementation mapping, cycle-exact correlation, executable RTL evidence, FPGA preparation evidence, reproducibility, CI validation, and release evidence`


  







# Verification Layer — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This directory defines the current verification layer of the Fractal Resonance Processor (FRP).

FRP verification connects the complete resonant computational mechanism, balanced ternary state execution, deterministic structured telemetry, fixed-point implementation mapping, cycle-exact traces, RTL comparison vectors, SystemVerilog interface correlation, reference equivalence, scaling qualification, executable M16 RTL realization, assertion execution, target-independent FPGA integration, benchmark evidence, and GitHub Actions qualification closure.

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

## 1. Verification Identity

The current verification layer validates the complete FRP computational chain:

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

↓

`deterministic fixed-point implementation mapping`

↓

`stateful quantized hardware-shadow execution`

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

`M15 qualification closure`

↓

`M16 SystemVerilog RTL execution core`

↓

`scheduler, request-lane, pending-route, active-neutral, capacity, and state-update execution`

↓

`M16 assertion execution and ten integrated invariant flags`

↓

`target-independent FPGA integration top and executable FPGA testbench`

↓

`asynchronous reset assertion, two-stage synchronous release, core-ready gating, and interface propagation`

↓

`M16 RTL and FPGA preparation qualification closure`

## 2. Verification Source Hierarchy

Current verification follows this evidence hierarchy:

`current executable reference`

↓

`structured execution output`

↓

`self-test result`

↓

`M15 generated artifacts`

↓

`deterministic vector packages`

↓

`reference equivalence report`

↓

`M15 qualification closure manifest`

↓

`M16 RTL source boundary and executable testbench`

↓

`M16 RTL assertion and invariant results`

↓

`M16 RTL qualification workflow result`

↓

`M16 FPGA integration top and executable testbench`

↓

`M16 FPGA reset, gating, propagation, route-completion, and invariant results`

↓

`M16 FPGA preparation workflow result`

↓

`GitHub Actions workflow result`

↓

`test report`

↓

`validation index`

↓

`release notes`

The root `README.md` provides the visible current validation badge chain.

## 3. Current Verification Targets

The active verification targets are:

| Target | Current reference |
|---|---|
| processor semantics | `FractalResonanceProcessor` |
| fixed-point execution | `QuantizedReferenceShadowProcessor` |
| structured output | `frp.structured_output.v1.7.0` |
| M15 artifacts | ten versioned export layers |
| cycle correlation | 64-tick default integer golden trace |
| vector replay | deterministic M15 vector package |
| interface mapping | SystemVerilog testbench interface map |
| RTL mapping | synthesizable RTL reference-core map |
| invariant mapping | 13 assertion-correlation domains |
| semantic correlation | floating reference ↔ quantized shadow |
| exact replay | quantized shadow ↔ deterministic reference replay |
| scaling | 8, 16, and 32 cells |
| inherited semantic qualification | M15 qualification closure |
| M16 RTL execution | ten SystemVerilog RTL artifacts |
| M16 RTL assertions | executable assertion layer and ten invariant flags |
| M16 FPGA integration | `frp_m16_fpga_top` |
| M16 FPGA testbench | `frp_m16_fpga_tb` |
| M16 reset boundary | asynchronous assertion and two-stage synchronous release |
| M16 readiness boundary | `core_ready` and execution-input gating |
| release qualification | M16 RTL execution closure and FPGA preparation closure |

## 4. Core Verification Invariants

The current processor contract preserves:

| Invariant | Required condition |
|---|---|
| balanced ternary state domain | `balanced_ternary_state_domain = True` |
| direct opposite-polarity execution count | `actual_direct_events = 0` |
| reserved-state execution count | `reserved_state_events = 0` |
| route-queue overflow count | `queue_overflow_events = 0` |
| scheduler count integrity | `scheduler_counts_valid = True` |
| transition-load bound | `switch_load_peak <= transition_fraction` |
| telemetry count | `ticks_recorded = steps` |
| dynamic stability | `C_minus_P_min > 0.0` |
| fixed-point phase-topology closure | `fixed_point_topology_sum_exact = True` |
| fixed-point thermal-topology closure | `fixed_point_thermal_sum_exact = True` |

The M16 RTL and FPGA preparation layers additionally expose these ten integrated invariant flags:

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

Qualified M16 invariant-vector result:

`1111111111`

Current default transition fraction:

`0.25`

Current default scheduler:

`7/1`

Current default seed:

`76`

## 5. Balanced Ternary Verification

Current state and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Validated opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Current route result:

`actual_direct_events = 0`

## 6. Transition Counter Verification

The current verification chain preserves these transition counters:

- `requested_direct_events`;
- `prevented_direct_events`;
- `actual_direct_events`;
- `neutral_routed_events`;
- `neutralized_conflicts`.

These counters remain traceable through:

`structured execution`

↓

`quantized shadow execution`

↓

`cycle-exact trace`

↓

`RTL comparison vectors`

↓

`deterministic replay`

↓

`qualification closure`

## 7. Balanced Ternary Hardware Encoding Verification

Current canonical two-bit encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer mapping:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Current reserved-state result:

`reserved_state_events = 0`

## 8. Packed State Vector Verification

Current packing relation:

`cell 0 occupies bits [1:0]`

`cell 1 occupies bits [3:2]`

`cell i occupies bits [2i+1:2i]`

Packed-state width:

`2N bits`

Current validated scaling widths:

| Cells | Packed state width |
|---:|---:|
| `8` | `16 bits` |
| `16` | `32 bits` |
| `32` | `64 bits` |

Normative machine-readable state field:

`states_packed`

## 9. Standard Compile Verification

From the repository root, run:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

The M15 workflow performs this compile stage before generating qualification artifacts.

## 10. Standard Self-Test Verification

Run:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

`status = PASS`

Required check count:

`41`

Required check state:

`all 41 checks = True`

Current validated release result:

`41/41 PASS`

## 11. Scheduler Matrix Verification

Run the complete scheduler matrix:

    python frp_prototype_v1_7_0.py --mode self-test --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Each result should preserve:

- version `1.7.0`;
- milestone `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`;
- status `PASS`;
- check count `41`;
- all checks `True`.

## 12. Exact 41-Check Registry

The current self-test registry contains:

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

## 13. Current Default Structured Execution Verification

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json

Current default configuration:

| Parameter | Value |
|---|---:|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| request lanes | `4` |
| transition fraction | `0.25` |
| hierarchy depth | `4` |

Current default reference summary:

`balance = 56`

`commit = 8`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`switch_load_peak = 0.25`

`C_minus_P_min = 0.6142730712890625`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

These values describe the current default executable reference state.

The published release validation chain remains bound to the GitHub Actions evidence recorded in the current test report, validation index, and release notes.

## 14. Scheduler Verification

Supported scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current validated 16-tick profiles:

| Scheduler | Required counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Current validated default 64-tick `7/1` profile:

`balance = 56`

`commit = 8`

Required scheduler relation:

`sum(scheduler_counts) = ticks_recorded`

Current scheduler integrity marker:

`scheduler_counts_valid = True`

## 15. Request-Lane Verification

Current request-lane relation:

`REQUEST_LANES = max_changes`

Current scaling:

`8 cells → 2 request lanes`

`16 cells → 4 request lanes`

`32 cells → 8 request lanes`

Request lanes execute in ascending order:

`lane 0`

↓

`lane 1`

↓

`lane 2`

↓

`...`

Current self-test marker:

`request_lane_order_pass = True`

## 16. Pending Neutral Route Queue Verification

The current queue contract preserves:

- bounded capacity;
- deterministic processing order;
- pending target retention;
- ready-tick enforcement;
- overflow detection;
- route event tracing.

Current default queue result:

`queue_overflow_events = 0`

Current queue-exhaustion self-test marker:

`queue_exhaustion_detection_pass = True`

## 17. Dynamic Stability Verification

The current processor tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing-load relation:

`P(t) = heat + switch_load`

Required current condition:

`C_minus_P_min > 0.0`

The current semantic correlation layer also validates:

`semantic_C_minus_P_sign_match = True`

and:

`semantic_boundary_order_match = True`

## 18. Phase and Coherence Verification

Current resonant verification covers:

- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag gamma;
- phase velocity;
- wrapped phase update;
- Kuramoto order parameter `R`;
- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence;
- nonlinear coherence compression;
- phase-derived ternary targets.

Current phase interaction:

`sin(phase_j - phase_i - gamma_effective_i)`

Current phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

Global phase order:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

## 19. Hierarchical Topology Verification

The current architecture uses a dyadic hierarchical ultrametric topology.

Hierarchy relation:

`num_cells = 2^L`

Hierarchical distance:

`hierarchical_distance(i,j) = bit_length(i XOR j)`

for distinct cells.

Diagonal relation:

`hierarchical_distance(i,i) = 0`

Shell population:

`shell_population(d) = 2^(d - 1)`

Current validated topology profiles:

| Cells | Hierarchy depth | Shell populations |
|---|---:|---|
| `8` | `3` | `1, 2, 4` |
| `16` | `4` | `1, 2, 4, 8` |
| `32` | `5` | `1, 2, 4, 8, 16` |

## 20. Fixed-Point Topology and Thermal Closure

Current phase-coupling closure:

`sum_d(shell_population(d) × W_level_q[d]) = 2^30`

Current thermal-diffusion closure:

`sum_d(shell_population(d) × T_level_q[d]) = 2^30`

Required exact markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

These relations are validated across the current 8-cell, 16-cell, and 32-cell profiles.

## 21. Hardware-Facing Numeric Verification

Current M15 numeric domains:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Current self-test markers include:

`fixed_point_boundary_pass = True`

`trig_lut_pass = True`

## 22. Quantized Hardware-Shadow Verification

Current quantized execution representation:

`QuantizedReferenceShadowProcessor`

The quantized shadow preserves:

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
- multiscale phase coherence;
- global dynamic stability telemetry.

Current shadow invariants:

`shadow_actual_direct_events_zero = True`

`shadow_balanced_ternary_domain = True`

`shadow_queue_overflow_events_zero = True`

`shadow_reserved_state_events_zero = True`

`shadow_scheduler_counts_valid = True`

`shadow_switch_load_within_transition_fraction = True`

`shadow_ticks_recorded_equals_steps = True`

## 23. Exact M15 Tick Execution Order

The M15 quantized shadow and RTL reference-core contract preserve the same 26-stage tick sequence:

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
21. calculate multiscale phase-coherence values;
22. calculate global `C(t)`;
23. calculate global `P(t)`;
24. calculate `C_minus_P`;
25. detect the first positive-to-nonpositive stability crossing;
26. capture post-tick trace outputs.

Current validated execution-order entry count:

`26`

## 24. Cycle-Exact Reference Trace Verification

Artifact layer:

`cycle_exact_reference_trace`

Current default trace length:

`64 ticks`

The trace preserves correlation fields for:

- scheduler state;
- packed ternary state;
- pending routes;
- phase;
- frequency;
- thermal state;
- gamma state;
- coherence;
- dynamic stability.

Current exact replay markers:

`exact_reference_vector_replay_match = True`

`exact_reference_cell_trace_replay_match = True`

## 25. RTL Comparison Vector Verification

Artifact layer:

`rtl_comparison_vector_package`

Current vector files:

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

Current vector-package file count:

`10`

## 26. Deterministic Vector Reproduction

Generate package A:

    mkdir -p vectors_a

    python frp_prototype_v1_7_0.py \
      --export-rtl-comparison-vector-package \
      --vector-output-dir vectors_a \
      > vector-package-a.json

Generate package B independently:

    mkdir -p vectors_b

    python frp_prototype_v1_7_0.py \
      --export-rtl-comparison-vector-package \
      --vector-output-dir vectors_b \
      > vector-package-b.json

Compare:

    diff -qr vectors_a vectors_b

Required result:

`byte-identical equality`

Current self-test marker:

`vector_determinism_pass = True`

## 27. SHA-256 Vector Integrity Verification

Current manifest:

`frp_m15_sha256_manifest.json`

Integrity verification performs:

1. manifest loading;
2. vector-file discovery;
3. SHA-256 calculation for every recorded file;
4. exact digest comparison;
5. complete package presence verification.

Current qualification result:

`PASS`

## 28. SystemVerilog Interface Verification

Artifact layer:

`systemverilog_testbench_interface_map`

Current default parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

Current deterministic verification stimulus includes:

- `preload_valid`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`.

Current interface-map validation result:

`PASS`

## 29. Synthesizable RTL Reference-Core Mapping Verification

Artifact layer:

`synthesizable_rtl_reference_core`

Current validated mapping covers:

- balanced ternary state execution;
- active-neutral transition core;
- pending neutral-route queue;
- scheduler;
- request lanes;
- transition limits;
- fixed-point phase behavior;
- hierarchical coupling datapath;
- thermal-field datapath;
- multiscale phase-coherence datapath;
- dynamic-stability output mapping.

Current validated execution-order entry count:

`26`

Current mapping result:

`PASS`

## 30. RTL Assertion Correlation Verification

Artifact layer:

`rtl_assertion_correlation_harness`

Current assertion count:

`13`

Current assertion domains:

1. balanced ternary encoding;
2. reserved-state zero-event condition;
3. opposite-polarity active-neutral route enforcement;
4. neutral route insertion;
5. ready-tick enforcement;
6. `actual_direct_events = 0`;
7. transition-limit enforcement;
8. scheduler sequence;
9. scheduler count consistency;
10. phase-topology fixed-point normalization;
11. thermal-topology fixed-point normalization;
12. deterministic trace tick count;
13. exact cycle-output comparison contract.

Current integer comparison rule:

`actual integer field == expected integer field`

Current result:

`PASS`

## 31. Floating Semantic Reference to Quantized Shadow Correlation

The current semantic correlation boundary validates exact sequence relations:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- stability-boundary ordering match `1.0`.

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

Current semantic self-test markers:

`semantic_state_sequence_match = True`

`semantic_scheduler_sequence_match = True`

`semantic_neutral_route_sequence_match = True`

`semantic_C_minus_P_sign_match = True`

`semantic_boundary_order_match = True`

## 32. Exact Quantized Deterministic Replay

The current exact replay boundary validates:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

Current exact replay self-test markers:

`exact_shadow_state_match = True`

`exact_shadow_scheduler_match = True`

`exact_shadow_pending_route_match = True`

`exact_shadow_counter_match = True`

`exact_reference_vector_replay_match = True`

`exact_reference_cell_trace_replay_match = True`

## 33. Scaling Qualification

Run:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

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

Current self-test markers:

`scale_8_pass = True`

`scale_16_pass = True`

`scale_32_pass = True`

`topology_8_pass = True`

`topology_16_pass = True`

`topology_32_pass = True`

## 34. Ten M15 Artifact Layers

FRP v1.7.0 verifies ten M15 artifact layers:

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

Current self-test markers:

`artifact_layer_count_10 = True`

`export_schema_count_10 = True`

`all_export_schemas_exact = True`

## 35. M15 Artifact Export Commands

Generate the M15 artifact set:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Current qualification closure result:

`PASS`

## 36. Current M15 Schema Registry

Current schemas:

`frp.m15.fixed_point_interface_profile.v1.7.0`

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

`frp.m15.quantized_reference_shadow_model.v1.7.0`

`frp.m15.cycle_exact_reference_trace.v1.7.0`

`frp.m15.rtl_comparison_vector_package.v1.7.0`

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

`frp.m15.qualification_closure_manifest.v1.7.0`

Current schema verification result:

`PASS`

## 37. Benchmark Matrix Verification

Generate:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

Current schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current architecture rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Current row count:

`5`

Current result:

`PASS`

## 38. Architecture Document Contract Verification

Inherited M15 architecture document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Qualified M15 architecture markers include:

- `M14 floating semantic reference`;
- `M15 quantized hardware shadow model`;
- `cycle-exact integer golden trace`;
- `synthesizable RTL reference core`;
- `exact quantized shadow ↔ RTL equivalence`;
- `actual_direct_events = 0`;
- `-1 → 0 → 1`;
- `1 → 0 → -1`;
- `free`;
- `7/1`;
- `1/7`;
- `S32Q16`;
- `S32Q30`;
- `PHASE_U32`;
- `GAMMA_S32`;
- `GAMMA_NOISE_TARGETS_Q`.

Qualified M15 primary vector-row ordering:

`GAMMA_UPDATE_VALID`

↓

`GAMMA_NOISE_TARGETS_Q`

↓

`STATES_PACKED`

Current result:

`PASS`

## 39. M15 Qualification Workflow

Inherited qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Job name:

`M15 implementation mapping qualification`

Execution environment:

`ubuntu-latest`

Python version:

`3.12`

Timeout:

`30 minutes`

Permissions:

`contents: read`

Qualified workflow stages:

1. Checkout repository;
2. Set up Python;
3. Compile FRP v1.7.0 reference file;
4. Generate M15 qualification outputs;
5. Compare deterministic vector packages;
6. Validate M15 schemas, kernel invariants, fixed-point contract, and equivalence;
7. Validate deterministic vector package integrity;
8. Validate M15 architecture document contract;
9. Upload M15 qualification artifacts.

## 40. Current Workflow Inventory

The repository contains 23 GitHub Actions workflow files:

1. `.github/workflows/frp-architecture-comparison.yml`;
2. `.github/workflows/frp-benchmark-smoke.yml`;
3. `.github/workflows/frp-hardware-sensitivity-comparison.yml`;
4. `.github/workflows/frp-hardware-sensitivity-profile.yml`;
5. `.github/workflows/frp-m10-silicon-production-tapeout.yml`;
6. `.github/workflows/frp-m11-production-integration-handoff.yml`;
7. `.github/workflows/frp-m12-feedback-iteration.yml`;
8. `.github/workflows/frp-m13-production-scaling-stabilization.yml`;
9. `.github/workflows/frp-m14-physical-implementation-qualification.yml`;
10. `.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
11. `.github/workflows/frp-m16-canonical-core-domain.yml`;
12. `.github/workflows/frp-m16-fpga-preparation.yml`;
13. `.github/workflows/frp-m16-reserved-cell-cleanup.yml`;
14. `.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
15. `.github/workflows/frp-m3-benchmark-signal-map.yml`;
16. `.github/workflows/frp-m4-hdl-trace.yml`;
17. `.github/workflows/frp-m5-rtl-assertion-harness.yml`;
18. `.github/workflows/frp-m6-formal-verification.yml`;
19. `.github/workflows/frp-m7-fpga-synthesis.yml`;
20. `.github/workflows/frp-m8-production-release.yml`;
21. `.github/workflows/frp-m9-silicon-architecture.yml`;
22. `.github/workflows/frp-self-test.yml`;
23. `.github/workflows/frp-structured-output.yml`.

`CI.md` exposes one workflow badge for each of the 23 workflow files.

The root `README.md` exposes the current M16 RTL Artifact Boundary and M16 FPGA Preparation workflow badges together with the release-version, Python, and license badges.

## 41. Published Release Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Inherited M15 semantic and implementation-mapping qualification:

`41/41 PASS`

M16 RTL qualification records:

| Record | Workflow run | Qualified commit | Result | Closure status |
|---|---:|---|---:|---|
| initial closure | `#82` | `a68a2af` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| qualification rerun | `#84` | `ede53cf` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |

M16 FPGA preparation qualification records:

| Record | Workflow run | Qualified commit | Result | Closure status |
|---|---:|---|---:|---|
| initial closure | `#1` | `326b69e` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |
| qualification rerun | `#2` | `ede53cf` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |

Overall published result:

`PASS`

## 42. M16 RTL Execution Verification

Workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Validated RTL directory:

`../rtl/m16/`

Validated SystemVerilog artifact count:

`10`

Validated SystemVerilog artifacts:

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

Validated RTL documentation count:

`5`

Validated RTL documentation:

1. `../rtl/m16/README.md`;
2. `../rtl/m16/ARTIFACTS.md`;
3. `../rtl/m16/SIMULATION.md`;
4. `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
5. `../rtl/m16/CLOSURE.md`.

RTL testbench:

`frp_m16_tb`

Integrated synthesis boundary:

`frp_m16_core`

Qualified configuration:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

Transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified parameter relation:

`8 cells → 2 request lanes`

Build command:

    verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log

Execution command:

    /tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log

Qualified scheduler records:

| Scheduler mode | Executed ticks | Recorded state counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Qualified transition-capacity relations:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

Integrated invariant results:

| Invariant | Result |
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

Integrated invariant vector:

`1111111111`

Terminal execution record:

| Field | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Final qualification table:

| Qualification boundary | Result |
|---|---:|
| artifact inventory | `PASS` |
| documentation inventory | `PASS` |
| SystemVerilog parsing | `PASS` |
| module elaboration | `PASS` |
| latch-free required combinational boundaries | `PASS` |
| executable testbench generation | `PASS` |
| architectural simulation | `PASS` |
| assertion execution | `PASS` |
| `free` scheduler sequence | `PASS` |
| `7/1` scheduler sequence | `PASS` |
| `1/7` scheduler sequence | `PASS` |
| active-neutral routing | `PASS` |
| retained pending polarity | `PASS` |
| request-lane arbitration | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariants | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |
| qualification evidence upload | `PASS` |

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Qualification artifact count | `1` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |

RTL qualification result:

`PASS`

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## 43. M16 FPGA Preparation Verification

Workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Workflow name:

`FRP M16 FPGA Preparation`

Validated FPGA preparation directory:

`../fpga/m16/`

Validated FPGA SystemVerilog artifacts:

1. `../fpga/m16/frp_m16_fpga_top.sv`;
2. `../fpga/m16/frp_m16_fpga_tb.sv`.

Validated FPGA documentation:

1. `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
2. `../fpga/m16/CLOSURE.md`.

Validated inherited RTL dependency count:

`9`

Validated inherited RTL dependencies:

1. `../rtl/m16/frp_m16_pkg.sv`;
2. `../rtl/m16/frp_m16_scheduler.sv`;
3. `../rtl/m16/frp_m16_request_lanes.sv`;
4. `../rtl/m16/frp_m16_pending_routes.sv`;
5. `../rtl/m16/frp_m16_active_neutral.sv`;
6. `../rtl/m16/frp_m16_capacity_guard.sv`;
7. `../rtl/m16/frp_m16_state_update.sv`;
8. `../rtl/m16/frp_m16_core.sv`;
9. `../rtl/m16/frp_m16_assertions.sv`.

FPGA integration top:

`frp_m16_fpga_top`

FPGA testbench:

`frp_m16_fpga_tb`

Instantiated execution core:

`frp_m16_core`

Qualified configuration:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

FPGA top elaboration command:

    verilator --sv --lint-only --top-module frp_m16_fpga_top -Irtl/m16 -Ifpga/m16 fpga/m16/frp_m16_fpga_top.sv

FPGA testbench build command:

    verilator --sv --timing --assert --binary --top-module frp_m16_fpga_tb -Irtl/m16 -Ifpga/m16 --Mdir /tmp/frp_m16_fpga_obj fpga/m16/frp_m16_fpga_tb.sv

FPGA testbench execution command:

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

Diagnostic validation:

| Diagnostic boundary | Result |
|---|---:|
| inferred latch diagnostics | `0` |
| multidriven diagnostics | `0` |
| latch-diagnostic rejection | `PASS` |
| multidriven-diagnostic rejection | `PASS` |

Validated reset sequence:

1. external reset asserts asynchronously;
2. the synchronization register clears;
3. the first release edge remains blocked;
4. the second release edge activates `rst_n_core` and `core_ready`.

Reset-synchronization results:

| Reset relation | Result |
|---|---:|
| asynchronous reset assertion | `PASS` |
| synchronization register cleared | `PASS` |
| first release edge remains blocked | `PASS` |
| second release edge activates `core_ready` | `PASS` |
| retained state remains `0` during reset | `PASS` |
| pending-route bank remains `0` during reset | `PASS` |
| scheduler counters remain `0` during reset | `PASS` |

Validated readiness and input-gating relations:

`core_ready = rst_n_core`

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Before `core_ready`:

- ticks do not reach the core;
- counter-clear events do not reach the core;
- request-valid events do not reach the core;
- no request is accepted;
- retained state remains unchanged;
- pending routes remain unchanged;
- scheduler counters remain unchanged.

Validated scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Validated scheduler states:

- `free`;
- `balance`;
- `commit`;
- `excite`;
- `neutralize`.

Qualified request:

`cell 0: 0 → 1`

Request-propagation record:

| Signal | Recorded value |
|---|---:|
| `request_accept[0]` | `1` |
| `request_reject[0]` | `0` |
| `accepted_changes` | `1` |
| retained cell 0 state | `1` |
| retained cell 0 pending route | `0` |

Qualified opposite-polarity route:

`1 → 0 → -1`

Active-neutral routing record:

| Event | Recorded value |
|---|---:|
| `requested_direct_events` | `1` |
| `prevented_direct_events` | `1` |
| `neutral_routed_events` | `1` |
| `actual_direct_events` | `0` |

Pending-route completion record:

| Relation | Recorded value |
|---|---:|
| retained route before completion | `-1` |
| state before completion | `0` |
| state after completion | `-1` |
| pending route after completion | `0` |
| `accepted_changes` | `1` |

Integrated invariant results:

| Invariant | Result |
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

Terminal invariant vector:

`1111111111`

Terminal execution record:

| Field | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Final qualification table:

| Qualification boundary | Result |
|---|---:|
| FPGA artifact inventory | `PASS` |
| qualified RTL dependency inventory | `PASS` |
| FPGA top parsing | `PASS` |
| FPGA top elaboration | `PASS` |
| FPGA testbench build | `PASS` |
| FPGA testbench execution | `PASS` |
| latch diagnostic rejection | `PASS` |
| multidriven diagnostic rejection | `PASS` |
| asynchronous reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| execution-input gating | `PASS` |
| scheduler propagation | `PASS` |
| request propagation | `PASS` |
| active-neutral routing | `PASS` |
| retained pending-route completion | `PASS` |
| transition-capacity correlation | `PASS` |
| all ten invariant flags | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |
| qualification evidence upload | `PASS` |

Initial closure record:

| Field | Recorded value |
|---|---|
| Workflow run | `#1` |
| Qualified repository commit | `326b69e` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `1m 7s` |
| Qualification artifact count | `1` |

Qualification rerun record:

| Field | Recorded value |
|---|---|
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |

FPGA preparation qualification result:

`PASS`

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## 44. Comparative Architecture Verification Support

Current comparative directory:

`../benchmarks/architecture_comparison/`

Current schema:

`frp.benchmark.architecture_comparison.v1`

Current architecture set:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical comparison-package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

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

Current canonical comparative package result:

`PASS`

Current qualification policy identifier:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

## 45. Comparative Architecture Verification Commands

From:

`benchmarks/architecture_comparison/`

run:

    python common_workload.py --self-test --output text

    python common_cost_model.py --self-test --output text

    python common_thermal_model.py --self-test --output text

    python binary_synchronous_reference.py --self-test --output text

    python binary_clock_gated_reference.py --self-test --output text

    python direct_ternary_reference.py --self-test --output text

    python frp_v1_7_0_adapter.py --self-test --output text

    python run_architecture_comparison.py --self-test --output text

The comparison package should regenerate deterministically from the same source state and declared profiles.

## 46. Hardware-Sensitivity Verification Support

Current schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Current sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Current canonical result:

`../benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

Current scenario order:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Current canonical package results:

`profile validation = PASS`

`comparison qualification = PASS`

`ranking_stable = true`

`ranking_sensitive = false`

Recorded ranking for all three scenarios:

`binary_clock_gated_reference`

→ `direct_ternary_reference`

→ `binary_synchronous_reference`

→ `frp_v1_7_0_quantized_shadow`

The same global coefficient vector applies to every architecture inside each scenario.

## 47. Hardware-Sensitivity Verification Commands

From:

`benchmarks/architecture_comparison/`

run:

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --output text

    python validate_hardware_sensitivity_profile.py \
      --profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output text

    python run_hardware_sensitivity_comparison.py \
      --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json \
      --self-test \
      --output json

## 48. Historical Archived Transition Verification

The repository preserves the historical transition benchmark in:

`../TEST_REPORT_v0_9_3.md`

Historical executable:

`../frp_prototype_v0_9_3_mobile.py`

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

## 49. Archived Ternary-to-Binary Thermal Verification Result

The historical benchmark directly records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Therefore, under the historical v0.9.3 transition benchmark model and workload:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent relative reduction:

`93.63% lower heat_peak`

The same historical run records:

`distributed_neutral_ternary actual_direct_events = 0`

`binary_style_forced_switch actual_direct_events = 2052`

`distributed_neutral_ternary switch_load_peak = 0.25`

`binary_style_forced_switch switch_load_peak = 1.0`

This archived run preserves direct repository evidence that the distributed-neutral ternary transition path ran substantially colder than the binary-style forced-switching path inside that release-specific benchmark model.


## 50. Historical and Current Verification Contours

The historical v0.9.3 transition contour verifies:

- active-neutral routing;
- direct-event activity;
- switching load;
- historical heat proxy;
- dynamic stability.

The inherited v1.7.0 M15 contour verifies:

- balanced ternary execution;
- hierarchical fractal coupling;
- multiscale phase coherence;
- stateful delay dynamics;
- distributed local thermal dynamics;
- local correlated gamma drift;
- nonlinear coherence compression;
- fixed-point implementation mapping;
- quantized hardware-shadow execution;
- cycle-exact traces;
- deterministic RTL vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- assertion correlation;
- semantic correlation;
- exact deterministic replay;
- scaling qualification;
- qualification closure.

The current v1.8.0 M16 contour verifies:

- ten integrated SystemVerilog RTL artifacts;
- executable Verilator RTL testbench generation;
- architectural RTL simulation;
- SystemVerilog assertion execution;
- `free`, `7/1`, and `1/7` scheduler sequences;
- request-lane arbitration;
- active-neutral routing;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- ten integrated invariant flags;
- target-independent FPGA integration-top elaboration;
- executable FPGA integration testbench;
- asynchronous reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating;
- scheduler propagation;
- request-interface propagation;
- zero actual direct events;
- zero reserved-state events;
- zero queue-overflow events;
- M16 RTL execution closure;
- M16 FPGA preparation closure.

Each contour retains its release-specific architecture identifiers, metrics, and evidence records.

## 51. Reproducibility Record

A complete verification record should preserve:

- source revision;
- working-tree state;
- Python version;
- dependency versions;
- command;
- seed;
- scheduler;
- cell count;
- step count;
- transition fraction;
- gamma;
- fractal alpha;
- thermal parameters;
- delay alpha;
- generated artifact paths;
- comparison method;
- result status.

Current CI-aligned Python version:

`3.12`

Repository external dependency:

`numpy>=1.26.0`

NumPy is used by the historical FRP v0.9.3 and v0.9.4 executable layers. The current FRP v1.7.0 executable semantic reference and Comparative Architecture Benchmark Suite use the Python standard library and repository-local modules.

The M16 RTL and FPGA preparation workflows record the Verilator and compiler toolchains, source hashes, build logs, execution logs, and qualification result records.

## 52. Verification Failure Diagnosis

When a current verification check changes state, inspect the first affected layer in this order:

`source configuration`

↓

`kernel state`

↓

`scheduler and request lanes`

↓

`pending neutral routes`

↓

`phase and frequency state`

↓

`thermal and gamma state`

↓

`coherence and dynamic stability`

↓

`fixed-point mapping`

↓

`cycle-exact trace`

↓

`vector package`

↓

`interface mapping`

↓

`equivalence report`

↓

`M15 qualification closure`

↓

`M16 RTL parsing and module elaboration`

↓

`M16 scheduler, request-lane, pending-route, active-neutral, capacity, and writeback execution`

↓

`M16 assertion and invariant execution`

↓

`M16 FPGA integration-top and testbench execution`

↓

`M16 reset synchronization, core-ready gating, and interface propagation`

↓

`M16 RTL and FPGA preparation qualification closure`

Record the first changed invariant, first changed tick, first changed cell, and first changed deterministic artifact digest.

## 53. Historical Verification Record Preservation

Historical verification records retain:

- original release identity;
- original executable binding;
- original metric definitions;
- original command lines;
- original result tables;
- original benchmark architecture identifiers.

Current verification records use the FRP v1.8.0 release identity, the FRP v1.7.0 executable semantic reference and schemas, the qualified M15 artifact foundation, and the qualified M16 RTL and FPGA preparation workflow evidence.

This separation preserves the full architecture progression and the exact meaning of each published result.

## 54. Current File Alignment

This verification layer is aligned with:

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
- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`;
- `../.github/workflows/frp-m16-canonical-core-domain.yml`;
- `../.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

Inherited M15 release evidence remains aligned with:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

Historical thermal evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 55. Current Verification Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with asymmetric phase lag, hierarchical fractal coupling, phase evolution, resonance selection, Kuramoto order parameter R, multiscale phase coherence, stateful delay dynamics, local thermal-phase interaction, local correlated gamma drift, nonlinear coherence compression, dynamic stability evaluation, phase-derived ternary targets, distributed commit, mandatory active-neutral routing, and retained coherent ternary state`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

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





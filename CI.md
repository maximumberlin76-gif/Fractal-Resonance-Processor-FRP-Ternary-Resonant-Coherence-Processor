# CI — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document defines the Continuous Integration validation structure of the Fractal Resonance Processor (FRP) repository.

FRP is a ternary resonant coherence processor.

The CI subject is not limited to static validation of the symbols `-1`, `0`, and `1`.

The complete computational subject preserved across the current validation chain is:

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

`multiscale phase-coherence evaluation`

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

↓

`deterministic fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

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

The balanced ternary state and retained-result domain is:

`{-1, 0, 1}`

The active neutral state is:

`0`

Validated opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated kernel invariant:

`actual_direct_events = 0`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current release validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current release validation record:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

## 1. Purpose

The FRP Continuous Integration layer preserves validation traceability across the complete published processor architecture progression.

The repository CI structure contains:

- foundational executable validation;
- foundational resonant benchmark smoke validation;
- structured machine-readable output validation;
- release-specific architecture milestone validation;
- current M15 implementation-mapping qualification;
- deterministic fixed-point qualification;
- balanced ternary hardware-interface validation;
- quantized resonant-state execution validation;
- cycle-exact reference validation;
- RTL comparison-vector qualification;
- reference equivalence validation;
- comparative architecture benchmark qualification;
- hardware-sensitivity profile qualification;
- hardware-sensitivity comparison qualification.

The current release-validation boundary is:

`FRP v1.7.0 executable reference`

↓

`complete resonant phase-coherence computational core`

↓

`balanced ternary state-retention mechanism`

↓

`M15 fixed-point implementation mapping`

↓

`quantized hardware shadow`

↓

`cycle-exact integer reference`

↓

`deterministic RTL comparison domain`

↓

`SystemVerilog interface contract`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

Historical workflows remain bound to the release-specific executable files they were created to validate.

They are not silently redirected to the current executable reference.

## 2. CI Validation Subject

The current processor has two inseparable computational domains.

### 2.1 Resonant dynamic domain

The resonant dynamic domain contains:

- cell phase;
- base frequency;
- target frequency;
- current frequency;
- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- scheduler-dependent phase contribution;
- delayed frequency response;
- distributed thermal state;
- thermal coupling degradation;
- local correlated gamma drift;
- phase evolution;
- global Kuramoto order parameter `R`;
- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence;
- nonlinear coherence compression;
- dynamic stability evaluation.

### 2.2 Balanced ternary state and retention domain

The balanced ternary domain contains:

- states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- transition requests;
- distributed commit;
- transition-fraction limits;
- pending neutral routes;
- mandatory tick separation;
- scheduler-controlled execution;
- retained ternary state.

The resonant dynamic domain drives the evolving computation.

The ternary domain provides the state, target, transition, and retained-result layer.

The CI chain must preserve both.

## 3. Complete Computational Core Under Validation

The complete current computational path is:

`current phase field`

↓

`current frequency state`

↓

`current ternary state`

↓

`scheduler state`

↓

`pending neutral-route processing`

↓

`transition-request processing`

↓

`phase-derived ternary target extraction`

↓

`distributed transition-limit enforcement`

↓

`frequency-target formation`

↓

`delayed frequency response`

↓

`local generated power`

↓

`distributed thermal update`

↓

`local thermal overload`

↓

`correlated gamma-noise update`

↓

`local effective Sakaguchi phase lag`

↓

`thermal coupling-factor update`

↓

`hierarchical Kuramoto-Sakaguchi coupling field`

↓

`phase velocity`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`nonlinear coherence compression`

↓

`C(t), P(t), and C(t) - P(t)`

↓

`structured trace capture`

↓

`next processor tick`

The current CI does not reduce this path to a final ternary vector.

The M15 qualification chain checks different boundaries of this computation through:

- executable self-tests;
- structured-output invariants;
- fixed-point contracts;
- phase-domain mapping;
- gamma-domain mapping;
- quantized shadow execution;
- cycle-exact traces;
- deterministic vector packages;
- floating-to-quantized correlation;
- exact quantized replay.

## 4. Kuramoto-Sakaguchi Core Validation Subject

The current resonant phase interaction uses:

`sin(phase_j - phase_i - gamma_effective_i)`

The interaction is combined with:

- hierarchical coupling weights;
- local thermal coupling factors;
- nominal coupling strength;
- local effective gamma.

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

The current M15 qualification chain preserves this domain through:

- phase fixed-point representation;
- gamma fixed-point representation;
- deterministic trigonometric lookup;
- quantized phase execution;
- cycle-exact phase traces;
- deterministic gamma-noise stimulus;
- phase error bounds in reference equivalence.

The current CI does not contain one isolated assertion named:

`Kuramoto-Sakaguchi PASS`

Instead, the resonant core is validated through the complete set of phase, gamma, topology, trace, self-test, and equivalence contracts.

## 5. Phase Evolution Validation Subject

The current floating reference phase velocity is composed from:

`0.060 × current frequency`

+

`scheduler push`

+

`coupling field`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The CI chain preserves:

- deterministic current-frequency state;
- deterministic scheduler sequence;
- deterministic coupling topology;
- phase wrapping;
- phase fixed-point representation;
- cycle-exact trace behavior;
- floating-to-quantized phase correlation.

Current maximum floating-to-quantized phase error:

`0.02`

## 6. Kuramoto Order Parameter R and Coherence Validation Subject

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The current architecture also evaluates phase coherence across:

- pair domains;
- cluster domains;
- supercluster domains;
- the global phase field.

The M15 CI path validates coherence through:

- deterministic executable behavior;
- self-test package coverage;
- quantized shadow execution;
- cycle-exact traces;
- floating-to-quantized coherence correlation;
- `C(t)` correlation;
- `C(t) - P(t)` sign correlation.

Current maximum floating-to-quantized coherence error:

`0.01`

Current maximum floating-to-quantized `C` error:

`0.01`

The phase-order and coherence path is part of the processor computation.

It is not only presentation telemetry.

## 7. Hierarchical Fractal Coupling Validation Subject

The current architecture uses a dyadic hierarchical ultrametric topology.

The cell count must be:

- a power of two;
- at least `2`.

Current default cell count:

`16`

Current default hierarchy depth:

`4`

Current validated scaling profiles:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

The CI chain validates:

- topology generation at 8 cells;
- topology generation at 16 cells;
- topology generation at 32 cells;
- scaling execution at 8 cells;
- scaling execution at 16 cells;
- scaling execution at 32 cells;
- exact fixed-point topology normalization.

Required marker:

`fixed_point_topology_sum_exact = True`

## 8. Delay-Dynamics Validation Subject

Each current processor cell maintains:

- base frequency;
- target frequency;
- current frequency.

Current delayed frequency relation:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Current default:

`delay_alpha = 0.30`

Frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

The M15 equivalence layer includes a frequency correlation boundary.

Current maximum floating-to-quantized frequency error:

`0.0001`

## 9. Thermal-Phase Validation Subject

The current architecture maintains a distributed local thermal field.

The thermal path includes:

- local generated power;
- switching contribution;
- frequency-lag contribution;
- thermal dissipation;
- hierarchical thermal diffusion;
- local heat;
- local thermal overload.

The thermal field feeds back into:

- effective coupling;
- effective gamma;
- nonlinear coherence compression.

The current CI validates this domain through:

- exact fixed-point thermal normalization;
- quantized shadow execution;
- cycle-exact trace generation;
- floating-to-quantized heat correlation;
- `P(t)` correlation;
- `C(t) - P(t)` correlation.

Required exactness marker:

`fixed_point_thermal_sum_exact = True`

Current maximum floating-to-quantized heat error:

`0.001`

Current maximum floating-to-quantized `P` error:

`0.001`

## 10. Local Gamma-Drift Validation Subject

The current processor tracks:

- nominal gamma;
- gamma-noise targets;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

The M15 deterministic interface externalizes gamma-noise targets.

Current cycle-exact traces contain gamma-noise target vectors for all cells.

Current default configuration requires:

`16 gamma-noise target values per trace row`

The SystemVerilog verification stimulus interface includes:

`gamma_noise_target_q`

The M15 architecture contract also requires:

`GAMMA_NOISE_TARGETS_Q`

The current maximum floating-to-quantized gamma error is:

`0.000001`

## 11. Nonlinear Coherence Compression Validation Subject

The current processor applies nonlinear compression to raw phase coherence.

The computational relation is:

`effective coherence = raw phase coherence × coherence compression`

The compression factor responds to:

- mean thermal overload;
- stability-margin pressure.

The CI path preserves this behavior through:

- deterministic executable execution;
- quantized shadow behavior;
- coherence correlation;
- `C(t)` correlation;
- `C(t) - P(t)` sign correlation;
- exact quantized replay.

The CI must not validate a replacement path that bypasses the current nonlinear coherence stage while presenting it as equivalent processor behavior.

## 12. Dynamic Stability Validation Subject

The current processor tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing load:

`P(t) = heat + switch_load`

Required current condition:

`C_minus_P_min > 0.0`

The M15 CI validates:

- positive minimum stability margin;
- floating-to-quantized `C(t)` correlation;
- floating-to-quantized `P(t)` correlation;
- floating-to-quantized `C(t) - P(t)` correlation;
- exact `C(t) - P(t)` sign match;
- exact boundary-order match.

Current maximum floating-to-quantized error:

| Field | Maximum error |
|---|---:|
| `C` | `0.01` |
| `P` | `0.001` |
| `C_minus_P` | `0.01` |

## 13. Phase-Derived Ternary Target Validation Subject

The current executable maps the evolving phase field into balanced ternary targets.

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This connects:

`resonant phase field`

to:

`balanced ternary target domain`

The target remains subject to:

- transition-fraction limits;
- distributed commit;
- scheduler timing;
- pending routes;
- active neutral routing.

The current CI preserves this path through:

- deterministic state sequences;
- semantic state-sequence correlation;
- exact quantized state replay;
- route-sequence correlation;
- cycle-exact traces.

## 14. Balanced Ternary State Domain

The processor state and retained-result domain is:

`{-1, 0, 1}`

The valid states are:

`-1`

`0`

`1`

The active neutral state is:

`0`

Required current state-domain condition:

`balanced_ternary_state_domain = True`

Required reserved-state condition:

`reserved_state_events = 0`

The balanced ternary domain is the state and retained-result layer.

It is not the complete FRP computational mechanism.

## 15. Mandatory Active-Neutral Routing

Direct opposite-polarity execution is prohibited.

Prohibited direct execution:

`-1 ↔ 1`

Validated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

The CI validates both route directions.

Current exact self-test checks include:

`route_minus_to_plus_pass`

and:

`route_plus_to_minus_pass`

The final state alone is not sufficient.

The route history is part of the validated execution semantics.

## 16. Pending Neutral-Route Validation

Pending neutral routes preserve:

- cell identity;
- target polarity;
- route ordering;
- earliest valid execution tick.

The current CI validates:

- both opposite-polarity routes;
- pending-route replay;
- queue-exhaustion detection;
- request-lane order;
- zero queue-overflow events.

Required condition:

`queue_overflow_events = 0`

Exact current self-test checks include:

- `exact_shadow_pending_route_match`;
- `queue_exhaustion_detection_pass`;
- `request_lane_order_pass`;
- `shadow_queue_overflow_events_zero`.

## 17. Distributed Commit Validation

Current default transition fraction:

`0.25`

Current maximum-change relation:

`max_changes = max(1, round(cells × transition_fraction))`

Default 16-cell configuration:

`request_lanes = 4`

Required current boundary:

`switch_load_peak <= transition_fraction`

Default required boundary:

`switch_load_peak <= 0.25`

The CI validates:

`shadow_switch_load_within_transition_fraction`

Distributed commit remains the bounded connection between phase-derived targets and retained ternary state.

## 18. CI Layering Rule

The repository contains three distinct CI roles.

### 18.1 Foundational validation

These workflows preserve the original executable, resonant benchmark, and structured-output validation layers:

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

They remain attached to their historical executable references.

### 18.2 Architecture milestone validation

These workflows preserve the architecture progression from M3 through the current M15 layer.

Each milestone workflow validates its own release-specific executable reference and architecture package.

### 18.3 Supporting comparative validation

These workflows validate:

- comparative architecture execution;
- hardware-sensitivity profiles;
- hardware-sensitivity comparisons.

They are supporting validation contours.

They do not define or replace the primary FRP architecture progression.

## 19. Workflow Inventory

The repository contains 19 GitHub Actions workflows.

### Foundational workflows

| Workflow file | Workflow name | Validation role |
|---|---|---|
| `.github/workflows/frp-self-test.yml` | `FRP Self Test` | foundational executable self-test |
| `.github/workflows/frp-benchmark-smoke.yml` | `FRP Benchmark Smoke Test` | foundational resonant benchmark smoke validation |
| `.github/workflows/frp-structured-output.yml` | `FRP Structured Output` | M2 structured-output validation |

### Architecture milestone workflows

| Workflow file | Workflow name |
|---|---|
| `.github/workflows/frp-m3-benchmark-signal-map.yml` | `FRP M3 Benchmark and Signal Map` |
| `.github/workflows/frp-m4-hdl-trace.yml` | `FRP M4 HDL Trace and Testbench` |
| `.github/workflows/frp-m5-rtl-assertion-harness.yml` | `FRP M5 RTL Interface and Assertion Harness` |
| `.github/workflows/frp-m6-formal-verification.yml` | `FRP M6 Formal Verification and Equivalence Scaffold` |
| `.github/workflows/frp-m7-fpga-synthesis.yml` | `FRP M7 FPGA Synthesis and Timing Scaffold` |
| `.github/workflows/frp-m8-production-release.yml` | `FRP M8 Production Release Package` |
| `.github/workflows/frp-m9-silicon-architecture.yml` | `FRP M9 Silicon and Heterogeneous Architecture` |
| `.github/workflows/frp-m10-silicon-production-tapeout.yml` | `FRP M10 Silicon Production and Tapeout Readiness` |
| `.github/workflows/frp-m11-production-integration-handoff.yml` | `FRP M11 Production Integration and External Handoff` |
| `.github/workflows/frp-m12-feedback-iteration.yml` | `FRP M12 External Implementation Feedback and Production Iteration` |
| `.github/workflows/frp-m13-production-scaling-stabilization.yml` | `FRP M13 Production Scaling and Implementation Stabilization` |
| `.github/workflows/frp-m14-physical-implementation-qualification.yml` | `FRP M14 Physical Implementation Correlation and Production Qualification` |
| `.github/workflows/frp-m15-implementation-mapping-qualification.yml` | `FRP M15 Implementation Mapping and Qualification Closure` |

### Supporting comparative workflows

| Workflow file | Workflow name |
|---|---|
| `.github/workflows/frp-architecture-comparison.yml` | `FRP Comparative Architecture Benchmark` |
| `.github/workflows/frp-hardware-sensitivity-comparison.yml` | `FRP Hardware Sensitivity Comparison` |
| `.github/workflows/frp-hardware-sensitivity-profile.yml` | `FRP Hardware Sensitivity Profile Qualification` |

## 20. Current M15 Qualification Workflow

Current primary release workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

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

The workflow is triggered by changes to:

- `frp_prototype_v1_7_0.py`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `rtl/m15/**`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Supported triggers:

- `push`;
- `pull_request`;
- `workflow_dispatch`.

## 21. M15 Workflow Step Sequence

The current M15 workflow executes these major stages:

1. checkout repository;
2. set up Python 3.12;
3. compile the FRP v1.7.0 reference file;
4. generate M15 qualification outputs;
5. compare independent deterministic vector packages;
6. validate M15 schemas, processor invariants, fixed-point contracts, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture-document contract;
9. upload the M15 qualification artifact directory.

This sequence establishes the current CI relation:

`source`

↓

`compile`

↓

`execute`

↓

`generate`

↓

`repeat`

↓

`compare`

↓

`validate`

↓

`correlate`

↓

`close`

↓

`archive`

## 22. M15 Compile Gate

The first executable gate is:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

This verifies Python syntax before generation of the M15 qualification package.

## 23. M15 Structured Output Generation

The workflow generates:

    python frp_prototype_v1_7_0.py --mode demo --output json

Output:

`artifacts/m15/structured-output.json`

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The structured-output validation requires:

- `cells = 16`;
- `hierarchy_depth = 4`;
- `request_lanes = 4`;
- `ticks_recorded = 64`;
- scheduler `7/1`;
- scheduler count `balance = 56`;
- scheduler count `commit = 8`;
- valid scheduler counts;
- balanced ternary state-domain validity;
- zero reserved-state events;
- zero actual direct events;
- zero queue-overflow events;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

These summary assertions are not the complete processor validation by themselves.

They are the structured-output boundary of the larger M15 qualification chain.

## 24. M15 Self-Test Matrix

The current workflow runs four self-test variants.

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Required result for every self-test:

- schema equals `frp.structured_output.v1.7.0`;
- version equals `1.7.0`;
- status equals `PASS`;
- check count equals `41`;
- all 41 checks equal `True`.

Current validated result:

`41/41 PASS`

## 25. Exact Current 41-Check Coverage

The current self-test package contains exactly these 41 checks:

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

The 41 checks cover:

- scheduler behavior;
- both mandatory opposite-polarity routes;
- queue behavior;
- request-lane ordering;
- balanced ternary encoding;
- fixed-point boundaries;
- topology scaling;
- execution scaling;
- semantic sequence preservation;
- stability-sign preservation;
- quantized shadow invariants;
- exact replay;
- deterministic vector generation;
- all ten M15 schemas;
- qualification closure.

## 26. Resonant-Core Coverage Across the M15 CI Stack

The resonant computational core is distributed across several CI layers.

### Kuramoto-Sakaguchi phase path

Covered through:

- phase fixed-point profile;
- gamma fixed-point profile;
- deterministic trigonometric lookup;
- quantized shadow execution;
- phase correlation;
- exact trace replay.

### Hierarchical fractal coupling

Covered through:

- topology tests at 8 cells;
- topology tests at 16 cells;
- topology tests at 32 cells;
- exact fixed-point topology sum;
- scaling execution.

### Phase coherence

Covered through:

- deterministic executable behavior;
- floating-to-quantized coherence error bounds;
- `C(t)` correlation;
- stability-sign preservation.

### Delay dynamics

Covered through:

- frequency-state correlation;
- deterministic quantized execution;
- cycle-exact replay.

### Thermal-phase interaction

Covered through:

- exact fixed-point thermal sum;
- heat correlation;
- `P(t)` correlation;
- `C(t) - P(t)` correlation.

### Local gamma drift

Covered through:

- deterministic gamma-noise targets;
- gamma fixed-point representation;
- gamma correlation;
- SystemVerilog stimulus mapping.

### Ternary state retention

Covered through:

- state-sequence correlation;
- exact shadow state match;
- route-sequence correlation;
- exact pending-route replay;
- zero direct events;
- zero reserved-state events.

The complete processor is therefore validated across connected boundaries rather than by one static final-state assertion.

## 27. M15 Artifact Package

The current workflow generates ten primary M15 artifact layers.

### 27.1 Fixed-point interface profile

Command:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Schema:

`frp.m15.fixed_point_interface_profile.v1.7.0`

Output:

`artifacts/m15/fixed-point-interface-profile.json`

### 27.2 Balanced ternary hardware encoding map

Command:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Schema:

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

Output:

`artifacts/m15/balanced-ternary-hardware-encoding-map.json`

### 27.3 Quantized reference shadow model

Command:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Schema:

`frp.m15.quantized_reference_shadow_model.v1.7.0`

Output:

`artifacts/m15/quantized-reference-shadow-model.json`

### 27.4 Cycle-exact reference trace

Command:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Schema:

`frp.m15.cycle_exact_reference_trace.v1.7.0`

Output:

`artifacts/m15/cycle-exact-reference-trace.json`

### 27.5 RTL comparison vector package

Command:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Schema:

`frp.m15.rtl_comparison_vector_package.v1.7.0`

Output:

`artifacts/m15/rtl-comparison-vector-package.json`

### 27.6 SystemVerilog testbench interface map

Command:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Schema:

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

Output:

`artifacts/m15/systemverilog-testbench-interface-map.json`

### 27.7 Synthesizable RTL reference core

Command:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Schema:

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

Output:

`artifacts/m15/synthesizable-rtl-reference-core.json`

### 27.8 RTL assertion correlation harness

Command:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Schema:

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

Output:

`artifacts/m15/rtl-assertion-correlation-harness.json`

### 27.9 Reference RTL equivalence report

Command:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Schema:

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

Output:

`artifacts/m15/reference-rtl-equivalence-report.json`

### 27.10 Qualification closure manifest

Command:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Schema:

`frp.m15.qualification_closure_manifest.v1.7.0`

Output:

`artifacts/m15/qualification-closure-manifest.json`

## 28. Additional M15 Qualification Outputs

The current workflow also generates:

- benchmark matrix;
- 8-cell scaling output;
- 16-cell scaling output;
- 32-cell scaling output;
- deterministic vector package A;
- deterministic vector package B.

Benchmark matrix command:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

Output:

`artifacts/m15/benchmark-matrix.json`

Scaling commands:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Outputs:

- `artifacts/m15/scaling-8.json`;
- `artifacts/m15/scaling-16.json`;
- `artifacts/m15/scaling-32.json`.

## 29. M15 Fixed-Point Contract

The current workflow validates the following hardware-facing numeric representations.

General dynamic scalar:

`S32Q16`

Normalized coefficient:

`S32Q30`

Phase representation:

`PHASE_U32`

Sakaguchi gamma representation:

`GAMMA_S32`

Trigonometric table entries:

`4096`

Required exactness markers:

- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

The fixed-point contract maps the resonant computational domain.

It is not limited to ternary state encoding.

## 30. Balanced Ternary Hardware Encoding

The current workflow validates the canonical two-bit balanced ternary hardware encoding.

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Integer encoding map:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

The request interface validates:

- `request_lanes = 4`;
- `cell_id_width = 4`.

Required invariant:

`reserved_state_events = 0`

The encoding represents the processor state domain.

It does not replace the resonant phase-coherence computational mechanism.

## 31. Quantized Shadow Validation

The quantized reference shadow model preserves stateful processor domains including:

- ternary state;
- scheduler state;
- pending neutral routes;
- phase;
- frequency;
- gamma;
- local thermal state;
- coherence;
- dynamic stability;
- event counters.

The current workflow requires:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- valid scheduler counts;
- `ticks_recorded = 64`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

The quantized shadow is the stateful hardware-facing continuation of the processor semantics.

## 32. Cycle-Exact Trace Validation

The current workflow validates:

- exactly `64` trace rows;
- zero actual direct events;
- zero reserved-state events;
- per-tick gamma-noise target vectors for all `16` cells.

The cycle-exact trace is the deterministic integer reference path between:

`stateful quantized processor execution`

and:

`RTL-facing comparison vectors`

The trace preserves more than ternary state.

It also carries the execution fields required for deterministic correlation.

## 33. Deterministic RTL Vector Qualification

The M15 workflow generates two independent RTL comparison-vector directories:

- `artifacts/m15/vectors_a`;
- `artifacts/m15/vectors_b`.

Both packages are generated from the same deterministic reference configuration.

The workflow compares them with:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required result:

`no differences`

The vector package contains exactly ten files:

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

## 34. Deterministic Vector Integrity

The SHA-256 manifest validates the nine non-manifest vector files.

The workflow requires:

- every expected file to exist;
- every recorded digest to match the generated file;
- package structure to match the current contract;
- independent package A and package B to be byte-identical.

Semantic similarity is not sufficient.

The current requirement is deterministic identity.

## 35. SystemVerilog Interface Contract

The current workflow validates these M15 interface parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

The verification stimulus interface includes:

`gamma_noise_target_q`

This field preserves deterministic gamma-noise target injection in the RTL-facing verification path.

## 36. Synthesizable RTL Reference-Core Contract

The current workflow validates:

- `26` exact tick-execution stages;
- `actual_direct_events = 0`;
- tick-separated neutral routing;
- scheduler modes `free`, `7/1`, and `1/7`.

The M15 RTL reference-core contract is downstream of the full resonant computational reference.

It does not redefine FRP as static ternary switching.

## 37. RTL Assertion Correlation Contract

The current M15 RTL assertion correlation harness validates:

- assertion count `13`;
- exact integer comparison behavior.

Exact comparison rule:

`actual integer field == expected integer field`

The assertion layer connects:

`deterministic reference vectors`

to:

`RTL-facing execution fields`

## 38. Reference Equivalence Validation

The current M15 workflow validates two distinct boundaries.

### 38.1 Floating semantic reference to quantized shadow

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

This boundary directly preserves the resonant phase, delay, thermal, gamma, coherence, state, route, and stability domains.

### 38.2 Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

This boundary requires exact deterministic replay.

## 39. Qualification Closure

The qualification closure manifest requires:

- status `PASS`;
- all closure checks equal `True`;
- exactly ten M15 artifact layers.

The qualification closure manifest defines the current M15 release-validation endpoint.

The closure endpoint is:

`floating resonant semantic reference`

↓

`hardware-facing numeric mapping`

↓

`stateful quantized shadow`

↓

`cycle-exact integer reference`

↓

`deterministic RTL vectors`

↓

`interface correlation`

↓

`equivalence`

↓

`PASS`

## 40. M15 Scaling Checks

The current M15 workflow validates execution at:

- `8` cells;
- `16` cells;
- `32` cells.

Expected scaling structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Every scaling output must preserve:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- valid scheduler counts;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

Scaling also changes:

- hierarchy depth;
- shell structure;
- phase-coupling topology;
- thermal topology;
- multiscale coherence domains;
- request-lane count;
- packed state width.

## 41. M15 Benchmark Matrix Validation

The current workflow generates:

`artifacts/m15/benchmark-matrix.json`

Expected schema:

`frp.m3.benchmark_matrix.v1.7.0`

Expected row count:

`5`

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

This matrix represents the current implementation-mapping and qualification chain.

It is separate from the Comparative Architecture Benchmark Suite.

## 42. M15 Architecture Document Contract

The current workflow validates:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Required architecture markers include:

- `M14 floating semantic reference`;
- `M15 quantized hardware shadow model`;
- `cycle-exact integer golden trace`;
- `synthesizable RTL reference core`;
- `exact quantized shadow ↔ RTL equivalence`;
- `actual_direct_events = 0`;
- both mandatory neutral routes;
- scheduler modes `free`, `7/1`, and `1/7`;
- `S32Q16`;
- `S32Q30`;
- `PHASE_U32`;
- `GAMMA_S32`;
- `GAMMA_NOISE_TARGETS_Q`;
- `quantized_reference_shadow_model`;
- `rtl_comparison_vector_package`;
- `reference_rtl_equivalence_report`;
- `qualification_closure_manifest`;
- planned M16 architecture boundary.

The workflow also validates the primary vector-row field order.

Required ordering:

`GAMMA_UPDATE_VALID`

before:

`GAMMA_NOISE_TARGETS_Q`

before:

`STATES_PACKED`

## 43. M15 Artifact Upload

The workflow uploads:

`artifacts/m15`

Artifact name:

`frp-v1.7.0-m15-qualification-artifacts`

Missing artifact output is treated as an error.

The uploaded package preserves the current qualification evidence generated by the workflow run.

## 44. Foundational FRP Self-Test Workflow

Workflow:

`.github/workflows/frp-self-test.yml`

Workflow name:

`FRP Self Test`

Job name:

`Run FRP v0.9.3 self-test`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_3_mobile.py`

Command:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Required output marker:

`result=PASS`

This is a foundational historical validation workflow.

It is not the current M15 release qualification workflow.

## 45. Foundational Resonant Benchmark Smoke Workflow

Workflow:

`.github/workflows/frp-benchmark-smoke.yml`

Workflow name:

`FRP Benchmark Smoke Test`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_3_mobile.py`

Command:

    python frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Required architecture markers:

- `frp_distributed_resonant`;
- `distributed_neutral_ternary`;
- `direct_ternary_commit`;
- `binary_style_forced_switch`.

This historical workflow is important because it preserves the distinction between:

`FRP resonant phase layer + distributed active-neutral ternary routing`

and:

`distributed neutral ternary routing without the resonant phase layer`

The two architectures are not the same.

## 46. Structured Output Workflow

Workflow:

`.github/workflows/frp-structured-output.yml`

Workflow name:

`FRP Structured Output`

Job name:

`Validate FRP v0.9.4 structured output`

Python version:

`3.11`

Executable:

`frp_prototype_v0_9_4.py`

Structured-output schema:

`frp.structured_output.v0.9.4`

The workflow validates:

- Python compilation;
- text self-test;
- text benchmark;
- JSON self-test;
- JSON benchmark;
- JSON demo;
- JSON telemetry output;
- schema identity;
- repository identity;
- version identity;
- self-test PASS state;
- zero failures;
- zero actual direct events;
- positive stability margin;
- benchmark architecture labels;
- telemetry structure.

Historical telemetry fields include:

- `tick`;
- `phase`;
- `R`;
- `phi`;
- `C`;
- `P`;
- `C_minus_P`.

This historical structured-output workflow therefore already preserves visible evidence that FRP execution includes a phase-coherence layer and Kuramoto order parameter `R`.

It is not rewritten as the M15 workflow.

## 47. Architecture Milestone Workflow Chain

The release-specific architecture workflow chain is:

| Milestone | Executable reference | Workflow |
|---|---|---|
| M3 | `frp_prototype_v0_9_5.py` | `frp-m3-benchmark-signal-map.yml` |
| M4 | `frp_prototype_v0_9_6.py` | `frp-m4-hdl-trace.yml` |
| M5 | `frp_prototype_v0_9_7.py` | `frp-m5-rtl-assertion-harness.yml` |
| M6 | `frp_prototype_v0_9_8.py` | `frp-m6-formal-verification.yml` |
| M7 | `frp_prototype_v0_9_9.py` | `frp-m7-fpga-synthesis.yml` |
| M8 | `frp_prototype_v1_0_0.py` | `frp-m8-production-release.yml` |
| M9 | `frp_prototype_v1_1_0.py` | `frp-m9-silicon-architecture.yml` |
| M10 | `frp_prototype_v1_2_0.py` | `frp-m10-silicon-production-tapeout.yml` |
| M11 | `frp_prototype_v1_3_0.py` | `frp-m11-production-integration-handoff.yml` |
| M12 | `frp_prototype_v1_4_0.py` | `frp-m12-feedback-iteration.yml` |
| M13 | `frp_prototype_v1_5_0.py` | `frp-m13-production-scaling-stabilization.yml` |
| M14 | `frp_prototype_v1_6_0.py` | `frp-m14-physical-implementation-qualification.yml` |
| M15 | `frp_prototype_v1_7_0.py` | `frp-m15-implementation-mapping-qualification.yml` |

Each workflow preserves its own release-specific validation boundary.

The current architecture endpoint is:

`M15 / FRP v1.7.0`

## 48. Architecture Progression Preserved by CI

The published workflow progression is:

`structured machine-readable validation`

↓

`benchmark export and hardware signal mapping`

↓

`HDL trace and testbench preparation`

↓

`RTL interface and assertion contracts`

↓

`formal verification and equivalence scaffolds`

↓

`FPGA synthesis and timing structures`

↓

`stable production interface freeze`

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

`fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

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

The computational core remains upstream and semantically continuous throughout this progression.

## 49. Comparative Architecture Benchmark Workflow

Workflow:

`.github/workflows/frp-architecture-comparison.yml`

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

The suite compares:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The workflow validates the separate benchmark package under:

`benchmarks/architecture_comparison/`

Validation layers include:

- Python compilation;
- deterministic workload validation;
- normalized cost-model validation;
- thermal proxy-model validation;
- architecture reference self-tests;
- FRP adapter self-test;
- canonical comparison generation;
- deterministic repeat generation;
- machine-readable result validation;
- artifact handling.

The FRP reference must remain represented as a resonant phase-coherence architecture.

It must not be reduced to static ternary switching.

## 50. Comparative Benchmark Integrity Boundary

The comparative workflow preserves:

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

The qualification policy is:

`integrity_only_no_winner_assertions`

Required winner assertions:

`[]`

The workflow does not require:

`FRP energy < binary energy`

`FRP temperature < binary temperature`

`FRP latency < binary latency`

The result remains data.

## 51. Hardware-Sensitivity Profile Workflow

Workflow:

`.github/workflows/frp-hardware-sensitivity-profile.yml`

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

The workflow validates:

- hardware-cost calibration references;
- coefficient provenance;
- hardware-sensitivity cost-profile structure;
- coefficient constraints;
- scenario ordering;
- profile SHA-256;
- validator self-tests;
- deterministic byte-identical repeat validation.

The profile layer remains separate from the primary M15 architecture workflow.

## 52. Hardware-Sensitivity Comparison Workflow

Workflow:

`.github/workflows/frp-hardware-sensitivity-comparison.yml`

Workflow name:

`FRP Hardware Sensitivity Comparison`

The workflow validates the hardware-informed sensitivity comparison layer under:

`benchmarks/architecture_comparison/`

Its role is to preserve:

- hardware-sensitivity runner self-tests;
- deterministic comparison generation;
- machine-readable sensitivity outputs;
- qualification status;
- raw trace integrity;
- profile binding;
- result reproducibility.

This workflow remains a supporting validation contour.

It does not redefine the FRP architecture progression.

## 53. Dependency Handling

The foundational workflows:

- `frp-self-test.yml`;
- `frp-benchmark-smoke.yml`;
- `frp-structured-output.yml`;

install dependencies with:

    python -m pip install --upgrade pip

    pip install -r requirements.txt

The current M15 workflow:

- sets up Python `3.12`;
- compiles the current executable;
- executes the current reference and M15 artifact-generation path directly.

Dependency behavior is therefore workflow-specific.

Current declared external dependency:

`numpy>=1.26.0`

## 54. Minimal Current M15 Validation Commands

Compile:

    python -m py_compile frp_prototype_v1_7_0.py

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Qualification closure:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Required current results:

`Python compilation PASS`

`all self-tests 41/41 PASS`

`qualification closure PASS`

## 55. Full Local CI-Reproduction Sequence

Create the M15 artifact directories:

    mkdir -p artifacts/m15/vectors_a
    mkdir -p artifacts/m15/vectors_b

Generate structured execution:

    python frp_prototype_v1_7_0.py --mode demo --output json > artifacts/m15/structured-output.json

Generate all four self-test outputs:

    python frp_prototype_v1_7_0.py --mode self-test --output json > artifacts/m15/self-test.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json > artifacts/m15/self-test-free.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json > artifacts/m15/self-test-7-1.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json > artifacts/m15/self-test-1-7.json

Generate the ten M15 exports:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile > artifacts/m15/fixed-point-interface-profile.json

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map > artifacts/m15/balanced-ternary-hardware-encoding-map.json

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model > artifacts/m15/quantized-reference-shadow-model.json

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace > artifacts/m15/cycle-exact-reference-trace.json

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package > artifacts/m15/rtl-comparison-vector-package.json

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map > artifacts/m15/systemverilog-testbench-interface-map.json

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core > artifacts/m15/synthesizable-rtl-reference-core.json

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness > artifacts/m15/rtl-assertion-correlation-harness.json

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report > artifacts/m15/reference-rtl-equivalence-report.json

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > artifacts/m15/qualification-closure-manifest.json

Generate the benchmark matrix:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix > artifacts/m15/benchmark-matrix.json

Generate scaling outputs:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json > artifacts/m15/scaling-8.json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json > artifacts/m15/scaling-16.json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json > artifacts/m15/scaling-32.json

Generate independent vector packages:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_a > artifacts/m15/vector-package-a.json

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_b > artifacts/m15/vector-package-b.json

Compare:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required result:

`no differences`

## 56. Current Release Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Release-record validated commit:

`5fd9a4f`

Validated workflow stack recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Recorded validation result:

`PASS`

Recorded M15 self-test result:

`41/41 PASS`

Primary release-validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

The validated commit and workflow-run numbers belong to the published v1.7.0 validation record.

They are release-specific evidence and are not used as a statement about later documentation-only commits.

## 57. CI Traceability Rule

Every release-specific architecture layer must preserve traceability between:

`processor computational mechanism`

↓

`executable reference`

↓

`workflow`

↓

`generated artifacts`

↓

`schema validation`

↓

`phase and coherence correlation`

↓

`ternary state and route invariants`

↓

`fixed-point contracts`

↓

`deterministic replay`

↓

`test report`

↓

`validation index`

↓

`release notes`

Historical workflows must remain bound to their historical release-specific executable files.

The current release workflow must remain bound to:

- the current executable reference;
- the current architecture document;
- the current M15 artifact contract.

Supporting comparative workflows must remain separate from the primary architecture milestone chain.

## 58. Computational-Core Documentation Rule

When a CI-facing document explains what FRP validates, it must preserve the complete computational subject.

Required semantic chain:

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`hierarchical fractal phase interaction`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay dynamics`

↓

`thermal-phase feedback`

↓

`local gamma drift`

↓

`nonlinear coherence compression`

↓

`dynamic stability`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active neutral routing`

↓

`retained state`

A CI description that begins and ends with `{-1, 0, 1}` and transition routing is incomplete.

The ternary state domain is essential.

The resonant phase-coherence mechanism is also essential.

## 59. Repository Alignment Rule

When the current architecture layer changes, review:

- `README.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `PROJECT_STRUCTURE.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `CHANGELOG.md`;
- current executable reference;
- current test report;
- current validation index;
- current release notes;
- current architecture document;
- current milestone workflow;
- `docs/README.md`;
- `docs/core_principles.md`;
- `docs/resonance_computation.md`.

Historical release-specific workflows must not be silently redirected to a newer executable.

A new architecture layer should preserve the existing release-validation history and add its own explicit validation boundary.

Supporting comparative workflows must remain secondary to the FRP architecture progression.

## 60. Current CI Technical Chain

The complete current CI chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric local phase lag gamma`

↓

`hierarchical fractal phase interaction`

↓

`stateful delay dynamics`

↓

`distributed local thermal field`

↓

`thermal coupling degradation`

↓

`local correlated gamma drift`

↓

`phase velocity`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed transition limit`

↓

`mandatory active-neutral routing`

↓

`retained coherent ternary state`

↓

`structured machine-readable execution`

↓

`41-check self-test matrix`

↓

`fixed-point implementation profile`

↓

`balanced ternary hardware encoding`

↓

`stateful quantized hardware shadow`

↓

`cycle-exact integer golden trace`

↓

`independent deterministic RTL vector packages`

↓

`SHA-256 package integrity`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`floating-to-quantized reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

↓

`artifact preservation`

The resonant phase-coherence mechanism remains the processor core throughout this chain.

The balanced ternary domain remains the state and retained-result domain throughout this chain.

## 61. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with asymmetric phase lag, hierarchical fractal coupling, phase evolution, Kuramoto order parameter R, multiscale phase coherence, stateful delay dynamics, local thermal-phase interaction, local correlated gamma drift, nonlinear coherence compression, dynamic stability evaluation, phase-derived ternary targets, distributed commit, mandatory active-neutral routing, and retained coherent ternary state`

State and retained-result domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current CI role:

`preserve the complete FRP computational and validation chain from Kuramoto-Sakaguchi resonant phase evolution, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained state through deterministic M15 fixed-point mapping, cycle-exact execution, RTL correlation, reference equivalence, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

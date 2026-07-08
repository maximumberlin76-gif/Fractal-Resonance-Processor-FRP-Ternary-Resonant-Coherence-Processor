# Contributing — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

Thank you for contributing to the Fractal Resonance Processor (FRP).

FRP is a ternary resonant coherence processor.

Its computational mechanism combines resonant phase dynamics, coherence evolution, stateful feedback, and balanced ternary state retention.

The complete current processor path is:

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

The balanced ternary state and retained-result domain is:

`{-1, 0, 1}`

The active neutral state is:

`0`

Validated opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Validated kernel invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## 1. Contribution Principle

Every contribution should preserve or intentionally advance the published FRP architecture.

The contribution path is:

`identify the affected architecture layer`

↓

`read the current control files`

↓

`make one coherent technical change`

↓

`run the relevant validation set`

↓

`regenerate affected deterministic artifacts`

↓

`check architecture and documentation alignment`

↓

`submit traceable evidence`

The current repository state is defined by the connected set of:

- executable reference;
- GitHub Actions workflows;
- structured outputs;
- test reports;
- validation indices;
- release notes;
- architecture documents;
- generated artifacts;
- current root README validation badge chain.

## 2. Read the Current Control Files

Before changing a current FRP layer, read the files connected to that layer.

Primary current files:

- `README.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `PROJECT_STRUCTURE.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `CHANGELOG.md`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`;
- `docs/README.md`;
- `docs/core_principles.md`;
- `docs/resonance_computation.md`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `SECURITY.md`.

For comparative architecture work, also read:

- `benchmarks/architecture_comparison/README.md`;
- `benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md`;
- `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`;
- `benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`.

Historical architecture files retain their release-specific architecture identity.

Current-layer contributions use current-layer files.

Historical corrections use the corresponding historical files.

Planned M16 material remains identified as the next architecture layer until its implementation package is published.

## 3. Processor Identity

Use the processor name consistently:

`FRP — Fractal Resonance Processor`

Processor class:

`Ternary Resonant Coherence Processor`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

The processor identity includes the complete resonant phase-coherence mechanism and the balanced ternary state-retention mechanism.

The balanced ternary domain provides:

- state;
- target;
- transition;
- retained result.

The resonant dynamic domain provides:

- phase evolution;
- frequency evolution;
- resonant coupling;
- coherence development;
- coupled feedback;
- dynamic state formation.

Together these domains define the current FRP computation.

## 4. Two Connected Computational Domains

The FRP computational core contains two connected domains.

### 4.1 Resonant dynamic domain

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
- thermal coupling-factor evolution;
- local correlated gamma drift;
- phase evolution;
- global Kuramoto order parameter `R`;
- pair-domain phase coherence;
- cluster phase coherence;
- supercluster phase coherence;
- global phase coherence;
- nonlinear coherence compression;
- dynamic stability evaluation.

### 4.2 Balanced ternary state and retained-result domain

The balanced ternary domain contains:

- states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- transition requests;
- distributed commit;
- transition-fraction limits;
- request lanes;
- pending neutral routes;
- mandatory tick separation;
- scheduler-controlled execution;
- retained ternary state.

The resonant dynamic domain drives the evolving computation.

The balanced ternary domain provides the state, target, transition, and retained-result layer.

## 5. Current Tick Execution Chain

The current executable preserves the following operational sequence:

`scheduler-state selection`

↓

`pending neutral-route processing`

↓

`transition-request processing`

↓

`phase-derived ternary target processing`

↓

`distributed transition-limit enforcement`

↓

`frequency-target formation`

↓

`stateful delayed frequency response`

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

`structured telemetry and trace capture`

Across successive ticks:

`evolved phase field`

↓

`next phase-derived ternary target`

↓

`distributed transition`

↓

`active neutral routing`

↓

`retained coherent ternary state`

Changes affecting execution order require explicit architecture review and complete regression validation.

## 6. Kuramoto-Sakaguchi Resonant Phase Layer

The current phase interaction uses:

`sin(phase_j - phase_i - gamma_effective_i)`

The interaction combines:

- hierarchical coupling weights;
- local thermal coupling factors;
- nominal coupling strength;
- local effective gamma.

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

A contribution affecting the phase field should preserve explicit traceability across:

`phase state`

↓

`frequency state`

↓

`effective coupling`

↓

`phase lag`

↓

`scheduler contribution`

↓

`phase velocity`

↓

`phase evolution`

## 7. Phase Evolution

The current floating reference phase velocity combines:

`0.060 × current frequency`

+

`scheduler push`

+

`coupling field`

The current relation is:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

The phase update is:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

Contributions affecting phase evolution should preserve:

- deterministic update order;
- scheduler contribution;
- frequency contribution;
- coupling contribution;
- phase wrapping;
- downstream target extraction;
- downstream coherence evaluation.

## 8. Phase Lag Gamma

The current architecture tracks:

- nominal gamma;
- deterministic gamma-noise targets;
- correlated gamma-noise state;
- local thermal overload;
- effective local gamma;
- gamma drift.

The M15 verification path maps this domain through:

- `GAMMA_S32`;
- `gamma_noise_update_valid`;
- `gamma_noise_target_q`;
- deterministic cycle-exact gamma stimulus;
- floating-to-quantized gamma correlation.

A gamma contribution should preserve traceability across:

`nominal gamma`

↓

`local gamma dynamics`

↓

`effective phase offset`

↓

`coupling field`

↓

`phase evolution`

↓

`reference trace`

↓

`quantized shadow`

↓

`RTL-facing comparison artifacts`

## 9. Kuramoto Order Parameter R

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable reference evaluates this through:

`phase_order(phases)`

The same phase-order relation supports hierarchical coherence evaluation.

Contributions affecting:

- phase generation;
- coupling;
- delay;
- gamma;
- hierarchy;
- scheduler interaction;

should inspect resulting phase-order behavior.

The operational processor result includes the phase path, coherence path, transition path, and retained ternary state.

## 10. Multiscale Phase Coherence

Current coherence domains include:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Current outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

Changes affecting phase topology should inspect every affected coherence scale.

A contribution should connect local effects, cluster effects, supercluster effects, and global effects where the architecture change spans those domains.

## 11. Hierarchical Fractal Coupling

The current architecture uses a dyadic hierarchical ultrametric topology.

Current default cell count:

`16`

Current default hierarchy depth:

`4`

The cell count requirement is:

- a power of two;
- at least `2`.

Hierarchy depth:

`cells.bit_length() - 1`

Hierarchical distance between two distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current default fractal exponent:

`0.70`

Contributions affecting topology should preserve:

- hierarchy depth;
- shell structure;
- coupling normalization;
- deterministic cell grouping;
- dense-reference correlation;
- hierarchical-reference correlation;
- multiscale coherence behavior.

## 12. Fixed-Point Topology Closure

The current M15 fixed-point mapping preserves exact normalized topology closure.

Required marker:

`fixed_point_topology_sum_exact = True`

Changes affecting:

- hierarchy weights;
- shell populations;
- fractal exponent mapping;
- fixed-point normalization;
- rounding;
- accumulation order;

should preserve this exactness marker or advance it through an explicit versioned architecture transition.

## 13. Resonance Selection

FRP uses resonance as selective support of dynamically compatible phase structures.

Compatible structures support:

- coherence accumulation;
- target-oriented transition;
- coherent state retention.

Conflicting structures produce:

- neutralization;
- damping;
- suppression.

The current resonance computation includes:

- Kuramoto-Sakaguchi phase coupling;
- phase lag gamma;
- phase evolution;
- multiscale coherence;
- delay dynamics;
- thermal-phase interaction;
- nonlinear coherence compression;
- distributed commit.

Contributions affecting resonance should preserve the connected dynamic path from phase interaction through retained state.

## 14. Phase-Derived Ternary Target

The current executable maps the evolving phase field into ternary targets.

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This relation connects:

`resonant phase field`

↓

`balanced ternary target domain`

The target then enters:

- transition-fraction control;
- distributed commit;
- pending-route handling;
- active neutral routing;
- retained state.

Changes to this boundary are computational-core changes and require full resonant, state, route, and M15 regression validation.

## 15. Retained Coherent State

The current processor result is represented by the complete connected execution path.

Relevant evidence includes:

- target correspondence;
- phase evolution;
- Kuramoto order parameter `R`;
- multiscale coherence;
- delay state;
- thermal state;
- gamma drift;
- switching load;
- stability margin;
- active neutral routing;
- final retained ternary vector.

A contribution should preserve traceability from the dynamic process to the retained state.

## 16. Delay Dynamics

Current default delay coefficient:

`delay_alpha = 0.30`

Each cell preserves:

- base frequency;
- frequency target;
- current frequency.

The delayed response is:

`frequency_next = frequency_current + delay_alpha × (frequency_target - frequency_current)`

Frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

Contributions affecting delay should preserve:

- deterministic update order;
- frequency-target behavior;
- current-frequency behavior;
- frequency-lag telemetry;
- downstream thermal response;
- downstream coherence response.

## 17. Local Thermal-Phase Interaction

Each cell tracks:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The thermal field feeds into:

- effective resonant coupling;
- local gamma drift;
- nonlinear coherence compression.

The current feedback chain is:

`frequency lag and switching activity`

↓

`generated power`

↓

`local thermal field`

↓

`thermal overload`

↓

`effective coupling and gamma drift`

↓

`phase evolution`

↓

`coherence`

↓

`stability`

Contributions affecting one stage should inspect the connected downstream stages.

## 18. Fixed-Point Thermal Closure

Required current thermal exactness marker:

`fixed_point_thermal_sum_exact = True`

Changes affecting:

- thermal weights;
- thermal diffusion topology;
- fixed-point thermal arithmetic;
- rounding;
- accumulation order;

should preserve this exactness marker or advance it through an explicit versioned architecture transition.

## 19. Nonlinear Coherence Compression

The current processor applies:

`effective coherence = raw phase coherence × coherence compression`

The compression factor responds to:

- mean thermal overload;
- stability-margin pressure.

Current internal gains include:

`thermal_compression_gain = 3.0`

`margin_compression_gain = 1.5`

Current stability soft margin:

`0.25`

Contributions affecting coherence compression should preserve the current nonlinear relationship or introduce an explicit versioned architecture transition with complete validation evidence.

## 20. Dynamic Stability

The current processor tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing load:

`P(t) = heat + switch_load`

Required validated condition:

`C_minus_P_min > 0.0`

The current coherence state includes contributions from:

- effective phase coherence;
- cluster coherence;
- neutral-state fraction;
- frequency-lag penalty.

A stability-related contribution should validate every upstream input that affects the changed stability result.

Threshold changes require explicit technical rationale, versioned architecture placement, and regression evidence.

## 21. Balanced Ternary State Domain

The processor state and retained-result domain is:

`{-1, 0, 1}`

Valid states:

`-1`

`0`

`1`

The active neutral state is:

`0`

The neutral state supports:

- balancing;
- damping;
- transition;
- stabilization;
- conflict neutralization;
- switching-load control.

Required state-domain marker:

`balanced_ternary_state_domain = True`

Required reserved-state marker:

`reserved_state_events = 0`

## 22. Mandatory Active-Neutral Routing

Opposite-polarity execution follows the mandatory routes:

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

Route-sensitive contributions should preserve:

- active neutral insertion;
- pending target retention;
- tick separation;
- deterministic route ordering;
- exact direct-event count.

## 23. Pending Neutral Route Integrity

Pending neutral routes preserve:

- cell index;
- target polarity;
- earliest ready tick.

A route is applied when:

- its ready tick has been reached;
- transition capacity remains;
- the current state is neutral.

Required current conditions:

`actual_direct_events = 0`

`queue_overflow_events = 0`

Route changes require validation of:

- state sequence;
- pending-route sequence;
- actual direct-event count;
- scheduler sequence;
- cycle-exact trace.

## 24. Distributed Commit

Current default transition fraction:

`0.25`

Maximum state changes per tick:

`max(1, round(cells × transition_fraction))`

Default 16-cell result:

`request_lanes = 4`

Required validated relation:

`switch_load_peak <= transition_fraction`

Default validated boundary:

`switch_load_peak <= 0.25`

Commit-related contributions should inspect:

- phase-derived target generation;
- scheduler state;
- transition capacity;
- pending routes;
- switching load;
- thermal behavior;
- dynamic stability.

## 25. Scheduler Layer

Current scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Current validated 16-tick profiles:

| Scheduler | Required counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Current validated default 64-tick profile:

`balance = 56`

`commit = 8`

Required relation:

`sum(scheduler_counts) = ticks_recorded`

Required marker:

`scheduler_counts_valid = True`

The scheduler also contributes to phase velocity.

Scheduler changes may affect:

- phase evolution;
- coherence;
- transition timing;
- target commit;
- stability.

## 26. Current M15 Position

FRP v1.7.0 establishes:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current M15 bridge is:

`M14 floating semantic reference`

↓

`hardware-facing numeric types`

↓

`balanced ternary hardware encoding`

↓

`deterministic fixed-point arithmetic`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`verification preload and deterministic stimulus`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation mapping`

↓

`floating semantic reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

M15 maps and qualifies the complete processor semantics.

The resonant phase-coherence architecture remains the computational source for this mapping chain.

## 27. Current M15 Artifact Layers

FRP v1.7.0 defines ten M15 artifact layers:

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

Current dependency direction:

`floating semantic reference`

↓

`fixed-point interface`

↓

`quantized hardware shadow`

↓

`cycle-exact trace`

↓

`RTL comparison vectors`

↓

`SystemVerilog interface map`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

A contribution affecting one layer should validate each dependent downstream layer.

## 28. Current Hardware-Facing Numeric Profile

Current representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

The fixed-point path covers:

- phase;
- frequency;
- gamma;
- coherence;
- hierarchy weights;
- thermal weights;
- dynamic stability values;
- ternary transition execution.

## 29. Balanced Ternary Hardware Encoding

Current two-bit balanced ternary encoding:

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

Required invariant:

`reserved_state_events = 0`

The hardware-facing encoding represents the balanced ternary state domain inside the complete FRP computational mechanism.

## 30. Current Stable Schemas

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current M15 schemas:

- `frp.m15.fixed_point_interface_profile.v1.7.0`;
- `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`;
- `frp.m15.quantized_reference_shadow_model.v1.7.0`;
- `frp.m15.cycle_exact_reference_trace.v1.7.0`;
- `frp.m15.rtl_comparison_vector_package.v1.7.0`;
- `frp.m15.systemverilog_testbench_interface_map.v1.7.0`;
- `frp.m15.synthesizable_rtl_reference_core.v1.7.0`;
- `frp.m15.rtl_assertion_correlation_harness.v1.7.0`;
- `frp.m15.reference_rtl_equivalence_report.v1.7.0`;
- `frp.m15.qualification_closure_manifest.v1.7.0`.

A schema change is an interface change.

Schema contributions should explicitly identify:

- schema identifier;
- required field names;
- field types;
- ordering contracts;
- semantic meaning;
- migration impact;
- validation updates.

## 31. Contribution Areas

Contributions may address:

- resonant phase dynamics;
- Kuramoto-Sakaguchi coupling;
- gamma dynamics;
- hierarchical fractal coupling;
- phase-coherence measurement;
- multiscale coherence;
- delay dynamics;
- thermal-phase interaction;
- nonlinear coherence compression;
- target-state mapping;
- balanced ternary routing;
- distributed commit;
- scheduler behavior;
- transition-fraction control;
- request-lane behavior;
- structured output;
- M15 artifact generation;
- fixed-point mapping;
- hardware encoding;
- quantized shadow execution;
- cycle-exact traces;
- deterministic RTL vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- reference equivalence;
- qualification closure;
- benchmark integrity;
- hardware-sensitivity qualification;
- deterministic reproducibility;
- Continuous Integration;
- documentation;
- release traceability;
- installation and usage;
- verification coverage;
- bug fixes;
- terminology consistency;
- dependency maintenance.

A contribution should improve one or more of:

- correctness;
- deterministic reproducibility;
- traceability;
- validation strength;
- implementation clarity;
- documentation accuracy;
- maintainability.

## 32. Contribution Placement

Place each contribution in the architecture layer where it belongs.

Current executable correction:

`frp_prototype_v1_7_0.py`

Current M15 architecture correction:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M15 qualification correction:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Comparative benchmark correction:

`benchmarks/architecture_comparison/`

Historical release correction:

`the corresponding historical release-specific file`

Current M15 behavior belongs to the current M15 layer.

Planned M16 behavior belongs to the M16 planning and implementation path.

Historical behavior retains its historical file and release identity.

## 33. Current Validation Stack

The repository contains 19 GitHub Actions workflow files.

### 33.1 Foundational validation

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

### 33.2 Architecture progression

- `FRP M3 Benchmark and Signal Map`;
- `FRP M4 HDL Trace and Testbench`;
- `FRP M5 RTL Interface and Assertion Harness`;
- `FRP M6 Formal Verification and Equivalence Scaffold`;
- `FRP M7 FPGA Synthesis and Timing Scaffold`;
- `FRP M8 Production Release Package`;
- `FRP M9 Silicon and Heterogeneous Architecture`;
- `FRP M10 Silicon Production and Tapeout Readiness`;
- `FRP M11 Production Integration and External Handoff`;
- `FRP M12 External Implementation Feedback and Production Iteration`;
- `FRP M13 Production Scaling and Implementation Stabilization`;
- `FRP M14 Physical Implementation Correlation and Production Qualification`;
- `FRP M15 Implementation Mapping and Qualification Closure`.

### 33.3 Supporting comparative validation

- `FRP Comparative Architecture Benchmark`;
- `FRP Hardware Sensitivity Profile Qualification`;
- `FRP Hardware Sensitivity Comparison`.

Current primary architecture workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Each contribution should preserve every validation layer affected by the change.

## 34. Root README Active Validation Badge Chain

The root `README.md` exposes 18 active validation badges.

Current badge-visible passing chain:

| Validation workflow | Status |
|---|---|
| `FRP M15 Implementation Mapping and Qualification Closure` | `passing` |
| `FRP Hardware Sensitivity Profile Qualification` | `passing` |
| `FRP Hardware Sensitivity Comparison` | `passing` |
| `FRP M14 Physical Implementation Correlation and Production Qualification` | `passing` |
| `FRP M13 Production Scaling and Implementation Stabilization` | `passing` |
| `FRP M12 External Implementation Feedback and Production Iteration` | `passing` |
| `FRP M11 Production Integration and External Handoff` | `passing` |
| `FRP M10 Silicon Production and Tapeout Readiness` | `passing` |
| `FRP M9 Silicon and Heterogeneous Architecture` | `passing` |
| `FRP M8 Production Release Package` | `passing` |
| `FRP M7 FPGA Synthesis and Timing Scaffold` | `passing` |
| `FRP M6 Formal Verification and Equivalence Scaffold` | `passing` |
| `FRP M5 RTL Interface and Assertion Harness` | `passing` |
| `FRP M4 HDL Trace and Testbench` | `passing` |
| `FRP M3 Benchmark and Signal Map` | `passing` |
| `FRP Self Test` | `passing` |
| `FRP Benchmark Smoke Test` | `passing` |
| `FRP Structured Output` | `passing` |

The Comparative Architecture Benchmark workflow completes the 19-file workflow inventory.

## 35. Minimum Validation for Current Executable Changes

Compile:

    python -m py_compile frp_prototype_v1_7_0.py

Run the default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

`41/41 PASS`

Run the free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

Run the 7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

Run the 1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every scheduler-specific self-test should report:

- version `1.7.0`;
- status `PASS`;
- check count `41`;
- all checks `True`.

## 36. Structured Execution Check

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json

The current default execution should preserve:

- schema `frp.structured_output.v1.7.0`;
- version `1.7.0`;
- M15 milestone identity;
- `cells = 16`;
- `hierarchy_depth = 4`;
- `request_lanes = 4`;
- `ticks_recorded = 64`;
- scheduler `7/1`;
- `balance = 56`;
- `commit = 8`;
- `scheduler_counts_valid = True`;
- `balanced_ternary_state_domain = True`;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

Changes affecting phase dynamics should additionally inspect:

- raw phase coherence;
- effective coherence;
- multiscale coherence;
- gamma drift;
- frequency lag;
- effective coupling;
- thermal behavior.

## 37. Resonant-Dynamics Change Checklist

For a change affecting the resonant dynamic domain, verify:

- the Kuramoto-Sakaguchi interaction remains intentional;
- phase lag gamma remains correctly applied;
- hierarchical weights remain normalized;
- phase velocities remain deterministic;
- phase wrapping remains correct;
- Kuramoto order parameter calculation remains correct;
- phase-derived target-state mapping remains correct;
- scheduler influence remains intentional;
- delay dynamics remain consistent;
- thermal feedback remains consistent;
- multiscale coherence remains valid;
- reference-equivalence constraints remain satisfied.

## 38. M15 Export Validation

Generate:

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

Qualification closure should report:

`PASS`

Every closure check should remain:

`True`

Artifact layer count:

`10`

## 39. Deterministic Vector Requirements

Changes affecting:

- phase state;
- frequency state;
- quantized coupling;
- scheduler execution;
- pending routes;
- gamma stimulus;
- state packing;
- cell traces;
- interface mapping;
- RTL comparison behavior;

should regenerate and compare deterministic vector packages.

Generate package A:

    mkdir -p vectors_a

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_a > vector-package-a.json

Generate package B independently:

    mkdir -p vectors_b

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_b > vector-package-b.json

Compare:

    diff -qr vectors_a vectors_b

Required result:

`byte-identical equality`

Expected vector files:

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

Deterministic vector qualification uses byte-identical output.

## 40. Vector SHA-256 Integrity

Each generated vector directory contains:

`frp_m15_sha256_manifest.json`

The manifest binds the generated vector package to exact content.

A complete integrity check should:

1. load the manifest;
2. locate every named vector file;
3. calculate its SHA-256 digest;
4. compare it with the recorded digest;
5. require exact equality.

The two independently generated vector directories should also be byte-identical.

## 41. Reference Equivalence Requirements

The current reference-equivalence layer distinguishes two boundaries.

### 41.1 Floating semantic reference to quantized shadow

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

### 41.2 Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

Equivalence threshold changes require explicit architecture rationale, version placement, and regression evidence.

## 42. Scaling Requirements

Changes affecting topology, cell count, request lanes, state packing, hierarchy, or phase coupling should test:

`8 cells`

`16 cells`

`32 cells`

Run:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Every scaling result should preserve:

- `balanced_ternary_state_domain = True`;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- `scheduler_counts_valid = True`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

Phase and hierarchy changes should also inspect multiscale coherence across the tested sizes.

## 43. Comparative Architecture Benchmark Role

The Comparative Architecture Benchmark Suite provides a supporting validation contour.

Directory:

`benchmarks/architecture_comparison/`

Compared architecture references:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

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

The FRP reference preserves the resonant phase-coherence architecture inside this comparison path.

## 44. Comparative Benchmark Integrity Rules

### 44.1 Identical semantic workload

Every architecture receives the same ordered semantic command list.

The workload digest remains identical across architecture runs.

### 44.2 Architecture-neutral targets

The common workload uses:

`NEGATIVE_TARGET`

and:

`POSITIVE_TARGET`

The FRP active neutral state remains an internal processor mechanism.

### 44.3 Independent execution

Each architecture executes the same semantic command sequence independently.

### 44.4 Common normalized cost model

Architecture implementations emit raw events.

The common cost model assigns the normalized coefficients.

### 44.5 Common thermal proxy model

Every architecture uses the same thermal proxy equations and parameters.

### 44.6 Explicit FRP overhead

FRP-specific event accounting includes:

- phase operations;
- hierarchy operations;
- fixed-point operations;
- lookup-table operations;
- queue operations;
- thermal-field operations;
- coherence operations.

### 44.7 Machine-readable result policy

Current qualification policy:

`integrity_only_no_winner_assertions`

Current winner assertions:

`[]`

The qualification workflow validates comparison integrity.

The machine-readable result remains the comparison evidence.

## 45. Original Resonant Benchmark Identity

The original FRP benchmark distinguished:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

The published technical position records:

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

The `frp_distributed_resonant` architecture combines:

- resonant phase computation;
- distributed neutral ternary transition logic;
- coherent state retention.

The `distributed_neutral_ternary` architecture represents the distributed neutral transition reference.

These architecture labels retain distinct computational identities.

## 46. Comparative Benchmark Validation

From:

`benchmarks/architecture_comparison/`

run:

    python run_architecture_comparison.py --self-test --output text

Common model self-tests:

    python common_workload.py --self-test --output text

    python common_cost_model.py --self-test --output text

    python common_thermal_model.py --self-test --output text

Architecture self-tests:

    python binary_synchronous_reference.py --self-test --output text

    python binary_clock_gated_reference.py --self-test --output text

    python direct_ternary_reference.py --self-test --output text

    python frp_v1_7_0_adapter.py --self-test --output text

The comparison runner should regenerate deterministically from the same source state and declared inputs.

## 47. Hardware-Sensitivity Rules

The hardware-sensitivity layer uses the same global coefficient scenarios for all compared architectures.

Current scenarios:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Coefficient changes require:

- calibration rationale;
- provenance;
- profile validation;
- deterministic regeneration;
- baseline-preservation checks.

Relevant files:

- `benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md`;
- `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`;
- `benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`.

The same global scenario set applies to every compared architecture.

## 48. Hardware-Sensitivity Validation

From:

`benchmarks/architecture_comparison/`

validate the profile:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --output text

Run the validator self-test:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output text

Run the sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output json

Changes affecting hardware-sensitivity results should preserve deterministic regeneration and profile provenance.

## 49. Evidence Discipline

Technical statements should map to the evidence type that supports them.

Evidence may include:

- executable behavior;
- structured output;
- self-test;
- phase telemetry;
- benchmark result;
- generated artifact;
- qualification workflow;
- release record;
- architecture document.

Use the following evidence mapping:

| Statement type | Primary evidence |
|---|---|
| processor computational identity | executable reference plus architecture documentation |
| balanced ternary state domain | executable kernel plus structured output |
| resonant phase dynamics | executable phase path plus telemetry and architecture documentation |
| generated implementation mapping | M15 export artifact |
| deterministic replay | vector package and equivalence report |
| benchmark observation | machine-readable comparison result |
| workflow qualification | GitHub Actions run and validation contract |
| release evidence | test report, validation index, and release notes |

A ternary encoding map describes the hardware-facing state representation.

A benchmark result describes the recorded comparison under its declared workload, cost model, thermal proxy, and profile.

An architecture document describes the architecture layer it names.

A generated M15 artifact describes the implementation-mapping layer identified by its schema.

## 50. Current Release Evidence

Current published release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Published validation environment:

`GitHub Actions hardware-backed CI execution`

Validated release commit recorded in the current release evidence:

`5fd9a4f`

Validated workflow stack recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Published result:

`PASS`

Published M15 self-test result:

`41/41 PASS`

These values remain release-specific evidence.

Later documentation and maintenance commits retain their own commit identities.

## 51. Historical Architecture Preservation

Historical executable references remain part of the published architecture chain.

The chain includes:

- `frp_prototype_v0_9_3_mobile.py`;
- `frp_prototype_v0_9_4.py`;
- `frp_prototype_v0_9_5.py`;
- `frp_prototype_v0_9_6.py`;
- `frp_prototype_v0_9_7.py`;
- `frp_prototype_v0_9_8.py`;
- `frp_prototype_v0_9_9.py`;
- `frp_prototype_v1_0_0.py`;
- `frp_prototype_v1_1_0.py`;
- `frp_prototype_v1_2_0.py`;
- `frp_prototype_v1_3_0.py`;
- `frp_prototype_v1_4_0.py`;
- `frp_prototype_v1_5_0.py`;
- `frp_prototype_v1_6_0.py`;
- `frp_prototype_v1_7_0.py`.

Historical files retain:

- release-specific version identity;
- release-specific executable binding;
- release-specific workflow binding;
- release-specific schema identity;
- release-specific test-report identity.

Current files describe the current layer.

Historical files describe their published historical layers.

## 52. Documentation Requirements

When behavior changes, update the files that define, validate, or reproduce that behavior.

Relevant files may include:

- `README.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `PROJECT_STRUCTURE.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `CHANGELOG.md`;
- `docs/README.md`;
- `docs/core_principles.md`;
- `docs/resonance_computation.md`;
- current test report;
- current validation index;
- current release notes;
- current architecture document;
- current workflow.

Documents that explain FRP computation should preserve the connected relation between:

`resonant computational mechanism`

and:

`balanced ternary state and retained-result domain`

## 53. Computational-Core Documentation Rule

When a document explains what FRP is or how FRP computes, preserve the complete subject chain at the level appropriate to that document:

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay and thermal-phase dynamics`

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

`retained coherent ternary state`

The balanced ternary encoding layer should remain identified as the hardware-facing representation of the state domain.

The resonant phase-coherence path should remain identified as the computational mechanism.

## 54. Documentation Delta Discipline

When correcting one defined issue:

1. preserve the source file as the control standard;
2. change the required point;
3. compare the result with the source;
4. verify paths and filenames;
5. verify current version and milestone references;
6. verify computational-core continuity;
7. verify historical evidence identity;
8. verify the connected validation chain.

The final delta should contain the intended technical correction and the required alignment updates.

## 55. Reproducibility Requirements

A reproducibility-sensitive contribution should record:

- exact source revision;
- working-tree state;
- Python version;
- dependency versions;
- exact command;
- deterministic inputs;
- output path;
- comparison method.

For deterministic outputs, use an independent repeat.

Accepted comparison examples:

    cmp first.json second.json

or:

    diff -qr first_directory second_directory

When checksums are part of the artifact contract, preserve SHA-256 evidence.

## 56. Code Style

Code contributions should prioritize:

- deterministic behavior;
- explicit phase-state updates;
- explicit state transitions;
- explicit telemetry;
- clear invariants;
- readable function boundaries;
- simple dependency structure;
- documented assumptions;
- stable machine-readable output;
- reproducible tests.

Prefer:

- small explicit functions;
- deterministic iteration order;
- visible state updates;
- direct validation conditions;
- explicit schema construction;
- traceable constants;
- focused tests.

Kernel shortcuts require explicit architecture rationale and complete validation evidence.

## 57. Determinism Rules

Where deterministic execution is part of the contract, preserve:

- declared seed;
- stable iteration order;
- explicit scheduler order;
- explicit request-lane order;
- deterministic phase-update order;
- deterministic gamma-noise generation;
- controlled hash behavior;
- recorded time context for release evidence;
- controlled locale behavior;
- declared external input state.

A deterministic artifact should regenerate identically from the same source state and declared inputs.

## 58. Dependency Changes

Repository external dependency:

`numpy>=1.26.0`

NumPy is used by the historical FRP v0.9.3 and v0.9.4 executable layers. The current FRP v1.7.0 executable and Comparative Architecture Benchmark Suite use the Python standard library and repository-local modules.

Dependency changes should update:

- `requirements.txt`;
- `INSTALL.md`;
- `REPRODUCIBILITY.md`;
- relevant CI workflows;
- any affected release documentation.

## 59. Security and Public Repository Discipline

Public commits should contain public technical material aligned with the repository security policy.

Credentials, access tokens, private keys, API secrets, authentication material, private identity data, unrelated personal data, hidden network access, and unauthorized telemetry remain outside the repository.

Security-sensitive issues follow:

`SECURITY.md`

Private vulnerability reporting uses the private reporting path defined there.

## 60. Generated Artifact Discipline

Generated artifacts should remain traceable to:

- source version;
- generator;
- command;
- input configuration;
- schema;
- deterministic seed where applicable.

Generator-produced outputs should come directly from the generator path identified in the contribution record.

When a canonical result changes, identify the corresponding change in:

- code;
- profile;
- declared input;
- schema;
- architecture layer.

## 61. Pull Request Structure

A pull request should state:

### Change

What changed.

### Reason

Why the change was required.

### Architecture layer

Which FRP version or milestone the change belongs to.

### Computational layer

Which part is affected:

- phase dynamics;
- coherence;
- delay;
- thermal interaction;
- ternary commit;
- neutral routing;
- M15 mapping;
- benchmark;
- documentation.

### Affected files

Which files changed.

### Preserved invariants

Which processor invariants were checked.

### Validation

Which commands were run.

### Result

Which validation results were obtained.

### Artifact impact

Which schemas, generated outputs, canonical results, or release records changed.

Keep each pull request focused on one coherent technical change.

## 62. Pull Request Review Criteria

A contribution is reviewed for:

- correct architecture placement;
- preservation of resonant computational identity;
- correct Kuramoto-Sakaguchi phase behavior;
- phase-coherence continuity;
- preservation of balanced ternary state domain;
- preservation of active neutral routing;
- `actual_direct_events = 0`;
- deterministic behavior;
- scheduler correctness;
- structured-output compatibility;
- M15 artifact consistency;
- reproducibility;
- benchmark integrity where applicable;
- historical traceability;
- documentation alignment;
- security.

Architecture-contract changes should arrive as explicit versioned transitions with corresponding validation and documentation.

## 63. Current Executable Pull Request Checklist

For changes to:

`frp_prototype_v1_7_0.py`

confirm:

- Python compilation passes;
- default self-test reports `41/41 PASS`;
- free scheduler self-test reports `41/41 PASS`;
- 7/1 scheduler self-test reports `41/41 PASS`;
- 1/7 scheduler self-test reports `41/41 PASS`;
- phase evolution remains deterministic;
- Kuramoto order calculation remains valid;
- hierarchical coupling remains normalized;
- phase-derived target mapping remains valid;
- balanced ternary state domain remains valid;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- scheduler counts remain valid;
- `switch_load_peak <= transition_fraction`;
- `C_minus_P_min > 0.0`;
- fixed-point topology sum remains exact;
- fixed-point thermal sum remains exact;
- affected M15 artifacts remain valid;
- affected documentation is aligned.

## 64. Resonant-Core Pull Request Checklist

For changes affecting the computational core, confirm:

- phase states remain explicit;
- oscillator frequencies remain explicit;
- Kuramoto-Sakaguchi interaction remains correct;
- gamma application remains correct;
- hierarchical coupling remains deterministic;
- phase coherence remains measurable;
- Kuramoto order parameter remains valid;
- multiscale coherence remains valid;
- delay dynamics remain intentional;
- nonlinear coherence compression remains intentional;
- thermal-phase coupling remains traceable;
- target-state extraction remains correct;
- ternary commit remains distributed;
- opposite-polarity routing remains neutral-mediated;
- stable state retention remains validated.

## 65. M15 Artifact Pull Request Checklist

For changes affecting M15 implementation mapping, confirm:

- all affected exports complete;
- schema identifiers are correct;
- version identity is correct;
- milestone identity is correct;
- phase-domain fixed-point representation remains valid;
- gamma representation remains valid;
- trigonometric lookup behavior remains valid;
- deterministic vector packages regenerate;
- independent vector directories are byte-identical;
- hardware encoding remains canonical;
- reserved encoding remains absent from executed state events;
- reference equivalence remains within contract;
- qualification closure reports `PASS`.

## 66. Comparative Benchmark Pull Request Checklist

For changes under:

`benchmarks/architecture_comparison/`

confirm:

- identical semantic workload remains preserved;
- workload digest remains common;
- architecture runs remain independent;
- FRP remains represented as a resonant phase-coherence architecture;
- common cost model remains common;
- common thermal proxy remains common;
- FRP overhead remains explicit;
- global coefficient scenarios remain common;
- winner assertions remain `[]`;
- all relevant component self-tests pass;
- end-to-end comparison self-test passes;
- canonical outputs regenerate deterministically where applicable.

## 67. Hardware-Sensitivity Pull Request Checklist

Confirm:

- coefficient provenance is documented;
- the same global scenario set applies to all architectures;
- profile validation passes;
- profile validator self-test passes;
- sensitivity comparison self-test passes;
- deterministic regeneration passes;
- canonical unit-event baseline remains traceable;
- scenario order remains `lower_bound`, `nominal`, `upper_bound`.

## 68. Documentation Pull Request Checklist

Confirm:

- current version references are correct;
- current milestone references are correct;
- current executable filename is correct;
- current test report is correct;
- current validation index is correct;
- current release notes are correct;
- current workflow paths are correct;
- current root README validation badge chain is reflected accurately where relevant;
- historical release records retain their historical identity;
- Kuramoto-Sakaguchi resonant phase dynamics remain visible where computational identity is described;
- the balanced ternary state and retained-result domain remains explicit;
- coherence and stable retention remain visible where computational behavior is described;
- commands match the current CLI;
- referenced paths exist;
- the final delta contains the intended technical change.

## 69. Final Pull Request Checklist

Before submission, confirm:

- the change belongs to the stated architecture layer;
- the technical reason is documented;
- the processor identity remains clear;
- the resonant phase computational mechanism remains intact;
- the balanced ternary state domain remains `{-1, 0, 1}`;
- the neutral state remains active;
- opposite-polarity transitions remain tick-separated;
- `actual_direct_events = 0`;
- relevant phase and coherence validation passes;
- relevant M15 validation passes;
- deterministic outputs remain deterministic;
- benchmark roles remain correctly scoped;
- documentation is aligned;
- historical release evidence is preserved;
- public repository content follows `SECURITY.md`.

## 70. Current Contribution Status

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

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current published validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current contribution role:

`preserve and advance the complete FRP computational chain from Kuramoto-Sakaguchi resonant phase evolution, hierarchical fractal interaction, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained coherent state through deterministic M15 implementation mapping, RTL correlation, reference equivalence, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

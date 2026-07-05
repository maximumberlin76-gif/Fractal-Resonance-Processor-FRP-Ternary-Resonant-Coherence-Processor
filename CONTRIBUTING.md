# Contributing — Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

**Ternary Resonant Coherence Processor — Structured Output Prototype**

Thank you for your interest in contributing to the Fractal Resonance Processor (FRP).

FRP is a ternary resonant coherence processor.

It does not treat computation as literal bit toggling or static enumeration of ternary symbols.

Its computational identity combines:

`balanced ternary target domain {-1, 0, 1}`

↓

`phase encoding and oscillator state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric phase lag gamma`

↓

`hierarchical fractal coupling`

↓

`resonance selection`

↓

`phase evolution`

↓

`phase-coherence accumulation`

↓

`Kuramoto order parameter R`

↓

`multiscale coherence evaluation`

↓

`delay dynamics`

↓

`nonlinear coherence compression`

↓

`target-oriented resonant transition`

↓

`distributed ternary commit`

↓

`mandatory tick-separated routing through active neutral state 0`

↓

`stable coherent state retention`

The balanced ternary states:

`{-1, 0, 1}`

define the processor state and retained-result domain.

The resonant phase layer defines the dynamic computational transition mechanism.

The neutral state:

`0`

is an active balancing, damping, transition, and stabilization state.

Validated opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Validated kernel invariant:

`actual_direct_events = 0`

The current executable reference is:

`frp_prototype_v1_7_0.py`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current published validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

## 1. Before Contributing

Before proposing changes, read the current files relevant to the intended change.

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
- `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`.

Historical architecture files remain preserved because they define earlier validated layers.

Do not treat an older release file as the current architecture merely because it remains in the repository.

## 2. Processor Identity

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

The executable prototype is the current reference form of the processor.

The processor identity is not reducible to:

- three static symbols;
- a ternary register;
- a ternary encoding table;
- a direct state-switching mechanism.

The complete computational identity includes the resonant phase-dynamics layer.

## 3. Computational Core

A contribution must preserve the distinction between:

`state domain`

and:

`computational dynamics`

The balanced ternary state domain is:

`{-1, 0, 1}`

The computational process is dynamic.

The current processor evolves coupled phase states and derives ternary targets from the resulting phase field.

The computational chain is:

`cell phases and frequencies`

↓

`hierarchical coupling field`

↓

`Kuramoto-Sakaguchi interaction`

↓

`asymmetric phase offset`

↓

`phase velocity`

↓

`phase evolution`

↓

`phase-coherence measurement`

↓

`multiscale coherence evaluation`

↓

`stability and pressure evaluation`

↓

`target-state extraction`

↓

`distributed commit`

↓

`active neutral routing`

↓

`retained ternary state`

FRP therefore does not compute by merely flipping a ternary state from one symbol to another.

The ternary state is the target and retained state domain around which the resonant phase dynamics evolve.

## 4. Kuramoto-Sakaguchi Resonant Phase Layer

The processor uses a Kuramoto-Sakaguchi type coupled-oscillator phase layer.

The current coupling relation contains the phase interaction term:

`sin(phase_j - phase_i - gamma_i)`

The interaction is combined with:

- hierarchical coupling weights;
- thermal pair factors;
- nominal coupling strength;
- local phase state;
- local effective gamma.

The current dense coupling path is constructed from weighted pair interactions.

The current hierarchical coupling path evaluates the same phase-interaction structure through hierarchical shell aggregation.

A contribution affecting the phase field must preserve the distinction between:

- phase state;
- oscillator frequency;
- effective coupling;
- phase lag;
- scheduler contribution;
- resulting phase velocity.

## 5. Current Phase Evolution

For each cell, the current phase velocity is composed from:

`frequency contribution`

+

`scheduler push`

+

`coupling field`

The current executable reference uses:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

The phase state then evolves as:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

This phase evolution occurs before the current target-oriented ternary commit layer evaluates the state transition path.

A contribution must not replace this dynamic phase-evolution path with a static direct ternary assignment while still describing the result as equivalent FRP behavior.

## 6. Phase Lag Gamma

Current default phase lag:

`gamma = 0.30π`

Current source constant:

`DEFAULT_GAMMA = 0.30 × pi`

The phase lag is part of the asymmetric Kuramoto-Sakaguchi coupling structure.

The current architecture also tracks:

- nominal gamma;
- effective local gamma;
- correlated gamma-noise state;
- gamma-noise target;
- thermal contribution to gamma drift;
- gamma-drift peak.

Changes affecting gamma must preserve traceability between:

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

## 7. Phase-Coherence Measurement

The current processor calculates phase coherence from the oscillator phase field.

The current global phase-order relation is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable reference implements this through:

`phase_order(phases)`

The resulting value is the Kuramoto phase-order parameter.

The phase-order parameter is not a decorative telemetry field.

It is part of the processor's operational dynamic state.

The current telemetry and validation layers track phase coherence at multiple scales.

## 8. Kuramoto Order Parameter R

The Kuramoto order parameter:

`R`

measures collective phase alignment.

The current architecture uses phase-order evaluation for:

- global phase coherence;
- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- multiscale phase-coherence analysis.

A contribution affecting:

- phase generation;
- coupling;
- delay;
- gamma;
- hierarchy;
- scheduler interaction;

must check the resulting coherence behavior.

Do not describe a final ternary vector alone as a complete FRP computational result.

The phase path and coherence path are part of the computation.

## 9. Hierarchical Fractal Coupling

The current executable reference inherits the M14 hierarchical ultrametric coupling architecture.

Current hierarchy requirements include:

- power-of-two cell count;
- dyadic hierarchy depth;
- hierarchical distance;
- shell population;
- level-dependent coupling weights;
- exact normalized fixed-point weight closure.

Current default:

`cells = 16`

Current default hierarchy depth:

`4`

The current hierarchical distance relation is derived from the binary index relation between cells.

The current shell population is:

`2^(distance - 1)`

The current coupling weights are normalized across hierarchy levels.

A contribution affecting topology must preserve:

- hierarchy depth;
- shell structure;
- coupling normalization;
- deterministic cell grouping;
- dense-to-hierarchical equivalence contracts where applicable.

## 10. Fractal Coupling Weight Map

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

The current coupling architecture assigns distance-dependent hierarchical weights.

The weight structure depends on:

- hierarchical distance;
- shell population;
- fractal exponent;
- global normalization.

The current fixed-point implementation closes the aggregate topology weight exactly.

Required invariant:

`fixed_point_topology_sum_exact = True`

Changes affecting coupling weights must preserve or explicitly version:

- floating reference behavior;
- quantized weight behavior;
- aggregate normalization;
- cycle-exact reference behavior.

## 11. Resonance Selection

FRP treats resonance as selective support of dynamically compatible modes.

Resonance is not used merely as a synonym for amplification.

Compatible phase structures support:

- coherence accumulation;
- convergence toward the target state;
- coherent state retention.

Incompatible or conflicting structures are routed toward:

- neutralization;
- damping;
- suppression.

The preserved resonance computation layer includes:

- Kuramoto-Sakaguchi phase coupling;
- phase lag gamma;
- phase evolution;
- nonlinear response;
- compression dynamics;
- delay dynamics;
- distributed commit.

The current executable reference extends this through:

- hierarchical phase coupling;
- multiscale coherence;
- local thermal fields;
- effective coupling modulation;
- nonlinear coherence compression.

## 12. Target-Oriented Resonant Computation

The processor combines a target-state layer with a resonant phase-evolution layer.

The target layer does not eliminate the resonant dynamics.

The resonant dynamics do not eliminate the ternary state domain.

The relationship is:

`balanced ternary target`

↓

`dynamic phase evolution`

↓

`resonance selection`

↓

`coherence development`

↓

`target-state extraction`

↓

`distributed state transition`

↓

`stable retained result`

The historical executable chain includes target generation from ternary operations.

The current v1.7.0 executable reference also derives target states from the evolving phase field.

Current target-state mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This mapping connects the phase-dynamics domain to the balanced ternary state domain.

Changes to this boundary are computational-core changes.

## 13. Stable Mode Retention

A coherent FRP computational result is not only a final vector.

The retained state must be reached through the valid dynamic path.

The complete result therefore includes:

- target correspondence;
- phase evolution;
- coherence behavior;
- transition debt;
- direct-conflict behavior;
- thermal state;
- switching load;
- stability margin;
- neutral-routing integrity.

The processor's computation chain ends in stable state retention rather than immediate untracked symbolic replacement.

## 14. Multiscale Phase Coherence

The current architecture evaluates coherence across multiple hierarchical scales.

Current layers include:

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

Changes affecting phase topology must be reviewed against all affected coherence scales.

A global average alone is not sufficient when a change alters local or cluster dynamics.

## 15. Delay Dynamics

The current architecture includes dynamic frequency lag.

Current default:

`delay_alpha = 0.30`

Each cell maintains:

- base frequency;
- frequency target;
- current frequency.

The current frequency target includes contributions from:

- cell state;
- switching activity.

The current frequency state approaches its target through the delay relation.

The resulting frequency lag contributes to:

- local thermal behavior;
- coherence evaluation;
- stability evaluation.

A contribution affecting delay dynamics must preserve:

- deterministic update order;
- frequency target behavior;
- current frequency behavior;
- frequency-lag telemetry;
- downstream thermal and coherence interactions.

## 16. Nonlinear Dynamics

The published FRP architecture chain includes nonlinear response.

The preserved foundational resonance layer includes:

- nonlinear saturation;
- compression dynamics.

The current v1.7.0 reference architecture includes nonlinear coherence compression driven by:

- thermal overload;
- stability-margin pressure.

The current coherence-compression relation is applied to raw phase coherence.

Current relation:

`effective_coherence = raw_phase_coherence × coherence_compression`

The current compression factor decreases under increasing thermal overload and margin pressure.

A contribution must not remove nonlinear behavior while describing the result as an equivalent resonant computational path.

## 17. Dynamic Coherence and Stability

The current processor tracks:

`C`

`P`

`C_minus_P`

The stability relation is:

`C_minus_P = C - P`

The current destabilizing load is:

`P = heat + switch_load`

Required current validation condition:

`C_minus_P_min > 0.0`

The current coherence state includes contributions from:

- effective phase coherence;
- cluster coherence;
- neutral-state fraction;
- frequency-lag penalty.

Changes affecting any of these layers must revalidate the stability path.

Do not modify a stability threshold merely to make a failing change pass.

## 18. Computational Core Chain

The complete computational-core chain to preserve is:

`balanced ternary target domain {-1, 0, 1}`

↓

`cell phase state`

↓

`cell frequency state`

↓

`hierarchical fractal coupling`

↓

`Kuramoto-Sakaguchi interaction`

↓

`phase lag gamma`

↓

`local effective coupling`

↓

`phase velocity`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay dynamics`

↓

`thermal interaction`

↓

`nonlinear coherence compression`

↓

`dynamic stability C - P`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active neutral transition routing`

↓

`retained coherent ternary state`

This chain is the computational identity that must not be collapsed into a static ternary-switch description.

## 19. Balanced Ternary State Domain

The processor state domain is:

`{-1, 0, 1}`

Validated states:

`-1`

`0`

`1`

The neutral state:

`0`

is active.

It is used for:

- balancing;
- damping;
- transition;
- stabilization;
- conflict neutralization;
- switching-load control.

Required state-domain condition:

`balanced_ternary_state_domain = True`

Reserved-state condition:

`reserved_state_events = 0`

## 20. Mandatory Neutral Routing

Direct opposite-polarity execution is prohibited.

Prohibited execution:

`-1 ↔ 1`

Validated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Required execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

A final state vector alone is insufficient evidence of correct execution.

The complete transition path must preserve:

- active neutral routing;
- pending target retention;
- tick separation;
- zero actual direct events.

## 21. Pending Neutral Route Integrity

Pending neutral routes are processor execution state.

Changes affecting route creation, retention, consumption, or ordering must preserve:

- deterministic pending-route behavior;
- valid cell targeting;
- tick-separated application;
- bounded route handling;
- zero queue-overflow events.

Required invariant:

`queue_overflow_events = 0`

Route changes require validation of:

- state sequence;
- pending-route sequence;
- actual direct-event count;
- scheduler sequence;
- cycle-exact trace.

## 22. Distributed Commit

The processor does not force the complete state vector to switch simultaneously by default.

Current default transition fraction:

`0.25`

Required condition:

`switch_load_peak <= transition_fraction`

Default required condition:

`switch_load_peak <= 0.25`

The distributed commit layer is part of the relation between resonant phase evolution and retained ternary state.

Changes to commit behavior must be reviewed against:

- phase-derived target generation;
- scheduler state;
- transition limit;
- pending routes;
- switching load;
- thermal behavior;
- stability.

## 23. Scheduler Layer

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

The scheduler also contributes to the current phase-velocity path.

Scheduler changes are therefore not only state-machine changes.

They may also affect:

- phase evolution;
- coherence;
- transition timing;
- target commit;
- stability.

## 24. Local Thermal Field

The current architecture tracks distributed thermal state.

Each cell maintains thermal behavior influenced by:

- base power;
- switching activity;
- frequency lag;
- dissipation;
- thermal diffusion.

The current architecture includes:

- local heat;
- local generated power;
- thermal dissipation;
- thermal overload;
- cluster-local thermal metrics.

Changes affecting thermal behavior must preserve the relation between:

`frequency lag`

↓

`generated power`

↓

`local thermal field`

↓

`effective coupling`

↓

`gamma drift`

↓

`phase evolution`

↓

`coherence`

↓

`stability`

## 25. Coupled Thermal-Phase Dynamics

The current processor architecture couples thermal and phase behavior.

Thermal state affects:

- local coupling factors;
- local gamma drift;
- coherence compression.

Phase and frequency dynamics affect:

- coherence;
- frequency lag;
- thermal generation.

This feedback structure must not be reduced to independent unrelated metrics.

A contribution modifying one layer must inspect its coupled downstream effects.

## 26. Current M15 Position

FRP v1.7.0 establishes:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

The M15 bridge is:

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

M15 maps the complete processor behavior into deterministic hardware-facing representation.

It does not replace the resonant phase computational core.

## 27. M15 Artifact Layers

Current M15 artifact layers:

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

A contribution affecting one artifact layer must be checked against dependent layers.

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

## 28. Fixed-Point Phase Representation

The current M15 layer maps the phase-dynamics domain into fixed-point hardware-facing representations.

Current representations:

| Domain | Representation |
|---|---|
| general scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| gamma | `GAMMA_S32` |

Current trigonometric lookup-table entries:

`4096`

The fixed-point path includes:

- phase representation;
- gamma representation;
- trigonometric lookup;
- phase-order calculation;
- hierarchical coupling weights;
- nonlinear coherence compression.

Changes to quantized phase behavior must be checked against the floating semantic reference.

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

Hardware encoding is a representation of the processor state domain.

It is not the whole computational mechanism.

Do not describe the encoding table as though it were the FRP computation itself.

## 30. Fixed-Point Exactness

Required current exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

Changes affecting:

- hierarchy weights;
- thermal weights;
- fixed-point arithmetic;
- rounding;
- saturation;
- lookup tables;

must preserve or explicitly version these contracts.

## 31. Current Stable Schemas

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

Do not silently alter:

- schema identifier;
- required field name;
- field type;
- ordering contract;
- semantic meaning.

## 32. Contribution Areas

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
- continuous integration;
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

## 33. Contribution Placement

Place a change in the architecture layer where it belongs.

Current executable correction:

`frp_prototype_v1_7_0.py`

Current M15 architecture correction:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M15 qualification correction:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Comparative benchmark correction:

`benchmarks/architecture_comparison/`

Historical release correction:

the relevant historical release-specific file.

Do not silently move historical behavior into the current layer.

Do not silently describe a current M15 behavior as a future M16 behavior.

## 34. Current Validation Stack

The repository contains 19 GitHub Actions workflows.

### Foundational validation

- `FRP Self Test`;
- `FRP Benchmark Smoke Test`;
- `FRP Structured Output`.

### Architecture progression

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

### Supporting comparative validation

- `FRP Comparative Architecture Benchmark`;
- `FRP Hardware Sensitivity Profile Qualification`;
- `FRP Hardware Sensitivity Comparison`.

Current primary architecture workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Do not disable an unrelated validation layer merely to make a change pass.

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

Every scheduler-specific self-test must report:

- version `1.7.0`;
- status `PASS`;
- check count `41`;
- all checks `True`.

## 36. Structured Execution Check

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json

The current default execution must preserve:

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
- valid scheduler counts;
- balanced ternary state-domain validity;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

Changes affecting phase dynamics must additionally inspect:

- raw phase coherence;
- effective coherence;
- multiscale coherence;
- gamma drift;
- frequency lag;
- effective coupling;
- thermal behavior.

## 37. Phase-Dynamics Change Checklist

For a change affecting the resonant phase layer, verify:

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

Qualification closure must report:

`PASS`

All closure checks must remain:

`True`

The manifest must preserve exactly ten M15 artifact layers.

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

must regenerate and compare deterministic vector packages.

Generate package A:

    mkdir -p vectors_a

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_a > vector-package-a.json

Generate package B independently:

    mkdir -p vectors_b

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_b > vector-package-b.json

Compare:

    diff -qr vectors_a vectors_b

Required result:

`no differences`

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

Deterministic equality means byte-identical output.

Semantic similarity is insufficient.

## 40. Reference Equivalence Requirements

The current reference-equivalence layer distinguishes two boundaries.

### Floating semantic reference to quantized shadow

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

### Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

Do not weaken equivalence thresholds merely to make a regression pass.

## 41. Scaling Requirements

Changes affecting topology, cell count, request lanes, state packing, hierarchy, or phase coupling must test:

`8 cells`

`16 cells`

`32 cells`

Run:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Every scaling result must preserve:

- balanced ternary state-domain validity;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- valid scheduler counts;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

Phase and hierarchy changes should also inspect multiscale coherence across the tested sizes.

## 42. Comparative Architecture Benchmark Boundary

The Comparative Architecture Benchmark Suite is a separate supporting validation contour.

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

The FRP reference in this suite must preserve the fact that FRP contains the resonant phase layer.

Do not compare FRP as though it were merely another static ternary switch model.

## 43. Comparative Benchmark Fairness Rules

### Identical semantic workload

Every architecture receives the same ordered semantic command list.

The workload digest must remain identical across architecture runs.

### Architecture-neutral targets

The common workload uses:

`NEGATIVE_TARGET`

and:

`POSITIVE_TARGET`

The common workload does not directly command the FRP neutral state.

The neutral state remains an internal FRP mechanism.

### Independent execution

Each architecture executes the same semantic command sequence independently.

### Common normalized cost model

Architecture implementations emit raw events.

They do not assign their own cost coefficients.

### Common thermal proxy model

Every architecture uses the same thermal proxy equations and parameters.

### Explicit FRP overhead

FRP-specific:

- phase operations;
- hierarchy operations;
- fixed-point operations;
- lookup-table operations;
- queue operations;
- thermal-field operations;
- coherence operations;

must remain represented.

Do not count only favorable FRP mechanisms while omitting resonant-computation overhead.

### No winner assertions

The qualification workflow must not assert:

`FRP energy < binary energy`

`FRP temperature < binary temperature`

`FRP latency < binary latency`

The workflow validates comparison integrity.

The result remains data.

Do not tune the benchmark to force FRP to win.

## 44. Original Resonant Benchmark Identity

The original FRP benchmark distinguished:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

The published technical position records:

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

This distinction is essential.

The FRP architecture is not equivalent to:

`distributed_neutral_ternary`

because FRP additionally contains the resonant phase computational layer.

Do not collapse these two architectures into one description.

## 45. Comparative Benchmark Validation

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

The comparison runner must remain deterministic.

## 46. Hardware-Sensitivity Rules

The hardware-sensitivity layer uses the same global coefficient scenarios for all compared architectures.

Current scenarios:

1. `lower_bound`;
2. `nominal`;
3. `upper_bound`.

Do not add architecture-specific coefficient vectors merely to improve one architecture's ranking.

Changes require:

- calibration rationale;
- provenance;
- profile validation;
- deterministic regeneration;
- baseline-preservation checks.

Relevant files:

- `benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md`;
- `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md`;
- `benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`.

## 47. Hardware-Sensitivity Validation

From:

`benchmarks/architecture_comparison/`

validate the profile:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --output text

Run the validator self-test:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output text

Run the sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output json

Changes affecting hardware-sensitivity results must preserve deterministic regeneration.

## 48. Claim Discipline

Technical statements must be traceable to appropriate evidence.

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

Distinguish clearly between:

- processor computational identity;
- balanced ternary state domain;
- resonant phase dynamics;
- executable reference behavior;
- generated implementation-mapping artifacts;
- benchmark results;
- workflow validation;
- historical release evidence.

Do not rewrite:

- a ternary encoding map into the whole processor computation;
- a benchmark result into a universal processor claim;
- an architecture document into a measurement claim;
- a generated mapping layer into a different implementation layer.

## 49. Current Release Evidence

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

These values are release-specific evidence.

Later documentation or maintenance commits must not be presented as the original validated release commit.

## 50. Historical Architecture Preservation

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

Historical files must retain their version identity.

Do not silently redirect a historical workflow to the current executable.

Do not rewrite an old test report as a current-state report.

Do not replace a historical schema identifier with a current schema identifier.

## 51. Documentation Requirements

When behavior changes, update the files that define or reproduce that behavior.

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

Documentation must preserve the distinction between:

`resonant computational mechanism`

and:

`ternary state and retention domain`

A document that describes the computational core must not reduce FRP to static ternary routing.

## 52. Computational-Core Documentation Rule

When a document explains what FRP is or how FRP computes, it should preserve the full subject chain:

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`phase evolution`

↓

`phase coherence`

↓

`resonance selection`

↓

`delay and nonlinear dynamics`

↓

`target-oriented transition`

↓

`balanced ternary commit`

↓

`active neutral routing`

↓

`stable retained state`

The exact level of detail may vary by document purpose.

The computational mechanism itself must not disappear.

## 53. Documentation Delta Discipline

When correcting one defined issue:

1. preserve the source file as the control standard;
2. change the required point;
3. check that no unrelated technical meaning was altered;
4. verify paths and filenames;
5. verify current version and milestone references;
6. verify computational-core continuity;
7. verify historical evidence remains historical.

A documentation correction must not introduce another inconsistency.

## 54. Reproducibility Requirements

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

## 55. Code Style

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

Avoid:

- hidden random-state dependencies;
- environment-dependent output;
- silent exception handling;
- unexplained threshold changes;
- unnecessary dependencies;
- undocumented schema changes;
- benchmark-specific shortcuts inside the processor kernel;
- replacement of dynamic phase computation with hard-coded target results.

## 56. Determinism Rules

Where deterministic execution is part of the contract:

- preserve the declared seed;
- preserve stable iteration order;
- preserve explicit scheduler order;
- preserve explicit request-lane order;
- preserve deterministic phase-update order;
- preserve deterministic gamma-noise generation;
- avoid uncontrolled hash ordering;
- avoid local-time dependence;
- avoid locale dependence;
- avoid unrecorded external data.

A deterministic artifact must regenerate identically from the same source state and declared inputs.

## 57. Dependency Changes

Current declared external dependency:

`numpy>=1.26.0`

A new dependency should be added only when it provides a clear technical need that cannot reasonably be satisfied by:

- the Python standard library;
- the existing dependency set;
- a small transparent implementation.

Dependency changes must update:

- `requirements.txt`;
- `INSTALL.md`;
- `REPRODUCIBILITY.md`;
- relevant CI workflows when required.

## 58. Security and Public Boundary

Do not commit:

- credentials;
- access tokens;
- private keys;
- API secrets;
- authentication material;
- private identity data;
- unrelated personal data;
- malicious code;
- hidden network access;
- unauthorized telemetry;
- material that violates the repository security policy.

Security-sensitive issues should follow:

`SECURITY.md`

Do not place a vulnerability disclosure into a public pull request when private reporting is required.

## 59. Generated Artifact Discipline

Generated artifacts must remain traceable to:

- source version;
- generator;
- command;
- input configuration;
- schema;
- deterministic seed where applicable.

Do not manually edit generated output and then present it as generator output.

When a canonical result changes, the corresponding code, profile, or declared input change must explain why.

## 60. Pull Request Structure

A pull request should state:

### Change

What was changed.

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

Which files were changed.

### Preserved invariants

Which processor invariants were checked.

### Validation

Which commands were run.

### Result

Whether validation passed.

### Artifact impact

Whether schemas, generated outputs, canonical results, or release records changed.

Keep a pull request focused on one coherent technical change.

## 61. Pull Request Review Criteria

A contribution is reviewed for:

- correct architecture placement;
- preservation of resonant computational identity;
- correct Kuramoto-Sakaguchi phase behavior;
- phase-coherence continuity;
- preservation of balanced ternary state domain;
- preservation of active neutral routing;
- zero actual direct events;
- deterministic behavior;
- scheduler correctness;
- structured-output compatibility;
- M15 artifact consistency;
- reproducibility;
- benchmark fairness where applicable;
- historical traceability;
- documentation alignment;
- security.

A technically interesting change may still be rejected if it breaks the published architecture contract without an explicit versioned transition.

## 62. Current Executable Pull Request Checklist

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
- documentation is updated where required.

## 63. Resonant-Core Pull Request Checklist

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

## 64. M15 Artifact Pull Request Checklist

For changes affecting M15 implementation mapping, confirm:

- all affected exports complete;
- schema identifiers are correct;
- version remains correct;
- milestone remains correct;
- phase-domain fixed-point representation remains valid;
- gamma representation remains valid;
- trigonometric lookup behavior remains valid;
- deterministic vector packages regenerate;
- independent vector directories are byte-identical;
- hardware encoding remains canonical;
- reserved encoding remains rejected;
- reference equivalence remains within contract;
- qualification closure reports `PASS`.

## 65. Comparative Benchmark Pull Request Checklist

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
- no architecture-specific winner tuning was introduced;
- no winner assertions were introduced;
- all relevant component self-tests pass;
- end-to-end comparison self-test passes;
- canonical outputs regenerate deterministically where applicable.

## 66. Hardware-Sensitivity Pull Request Checklist

Confirm:

- coefficient provenance is documented;
- the same global scenario set applies to all architectures;
- no architecture-specific coefficient vector was introduced;
- profile validation passes;
- profile validator self-test passes;
- sensitivity comparison self-test passes;
- deterministic regeneration passes;
- canonical unit-event baseline remains unchanged unless intentionally revised.

## 67. Documentation Pull Request Checklist

Confirm:

- current version references are correct;
- current milestone references are correct;
- current executable filename is correct;
- current test report is correct;
- current validation index is correct;
- current release notes are correct;
- current workflow paths are correct;
- obsolete current-state wording was not reintroduced;
- historical release records remain historical;
- the processor is not reduced to static ternary switching;
- Kuramoto-Sakaguchi resonant phase dynamics remain visible where computational identity is described;
- coherence and stable retention remain visible where computational behavior is described;
- commands match the current CLI;
- referenced paths exist.

## 68. Final Pull Request Checklist

Before submission, confirm:

- the change belongs to the stated architecture layer;
- the change is technically necessary;
- the processor identity remains clear;
- the resonant phase computational mechanism remains intact;
- the balanced ternary state domain remains `{-1, 0, 1}`;
- the neutral state remains active;
- opposite-polarity transitions remain tick-separated;
- `actual_direct_events = 0`;
- relevant phase and coherence validation passes;
- relevant M15 validation passes;
- deterministic outputs remain deterministic;
- benchmark boundaries remain separate;
- documentation is aligned;
- historical release evidence is preserved;
- no sensitive material is included.

## 69. Current Contribution Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with hierarchical coupling, phase-coherence evaluation, delay dynamics, nonlinear coherence compression, target-oriented transition, distributed ternary commit, and active neutral routing`

State domain:

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

Current published validation result:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current contribution boundary:

`preserve the complete FRP computational core from Kuramoto-Sakaguchi resonant phase evolution and phase-coherence dynamics through balanced ternary target formation, distributed commit, mandatory active-neutral routing, deterministic M15 implementation mapping, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

# Repository Structure — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This document describes the current public repository structure of the Fractal Resonance Processor (FRP).

FRP is a ternary resonant coherence processor.

Its computational identity is not defined by static enumeration or direct switching of the symbols `-1`, `0`, and `1`.

The complete processor structure connects:

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

`structured machine-readable validation`

↓

`hardware-facing implementation mapping`

↓

`cycle-exact reference execution`

↓

`RTL correlation`

↓

`qualification closure`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

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

## 1. Repository Role

The repository preserves the complete published FRP architecture progression.

The progression begins with the executable resonant phase-coherence processor and its balanced ternary state-retention mechanism.

It continues through:

- structured validation;
- hardware-facing signal mapping;
- HDL trace generation;
- RTL interface contracts;
- assertion layers;
- formal verification and equivalence scaffolds;
- FPGA mapping;
- production interface stabilization;
- silicon and heterogeneous architecture;
- tapeout-readiness structures;
- production handoff;
- scaling and stabilization;
- physical implementation correlation;
- deterministic fixed-point mapping;
- quantized hardware shadow execution;
- cycle-exact reference traces;
- RTL comparison vectors;
- SystemVerilog interface mapping;
- RTL assertion correlation;
- reference equivalence;
- qualification closure.

The primary architecture chain is:

`resonant phase-coherence computational core`

↓

`balanced ternary state and retained-result domain`

↓

`structured executable validation`

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

`production release and stable interface freeze`

↓

`silicon and heterogeneous implementation architecture`

↓

`silicon production and tapeout readiness`

↓

`production integration and external implementation handoff`

↓

`external feedback and production iteration`

↓

`production scaling and implementation stabilization`

↓

`physical implementation correlation and production qualification`

↓

`fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

↓

`cycle-exact integer reference traces`

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

The Comparative Architecture Benchmark Suite remains a supporting validation contour.

It does not replace or redefine the FRP architecture chain.

## 2. Complete Processor Subject

The repository must be read as one continuous processor architecture.

The complete computational subject contains two inseparable domains.

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
- delayed internal response;
- distributed thermal state;
- local thermal coupling degradation;
- local correlated gamma drift;
- phase evolution;
- global Kuramoto order parameter `R`;
- pair-domain phase coherence;
- cluster phase coherence;
- supercluster phase coherence;
- global phase coherence;
- nonlinear coherence compression;
- dynamic stability.

### 2.2 Balanced ternary state and retained-result domain

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

Neither domain alone defines the complete processor.

## 3. Complete Computational Core

The current processor execution path is:

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

`structured telemetry`

↓

`next processor tick`

Across successive ticks:

`evolved phase field`

↓

`next phase-derived ternary target`

↓

`distributed transition`

↓

`active neutral routing when required`

↓

`retained ternary state`

The repository structure must preserve this complete causal chain.

## 4. Kuramoto-Sakaguchi Resonant Phase Layer

The current executable reference contains a coupled-oscillator phase layer.

The phase interaction uses:

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

The resonant phase layer is a primary processor mechanism.

It must not be reduced to static ternary state switching.

## 5. Phase Evolution Layer

Each processor cell maintains:

- phase;
- base frequency;
- frequency target;
- current frequency.

The current phase velocity is composed from:

`frequency contribution`

+

`scheduler contribution`

+

`resonant coupling field`

The current floating reference relation is:

`phase_velocity_i = 0.060 × current_frequency_i + scheduler_push + coupling_field_i`

The phase then evolves through:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

The evolving phase field feeds subsequent ternary target formation.

## 6. Kuramoto Order Parameter R

The current executable calculates collective phase alignment through:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The current implementation evaluates this through:

`phase_order(phases)`

The Kuramoto order parameter is part of the operational processor state.

It is not only a display metric.

## 7. Multiscale Phase Coherence

The current architecture evaluates phase coherence across the dyadic hierarchy.

Current coherence domains include:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Current multiscale outputs include:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

The repository contains current executable, documentation, validation, and implementation-mapping layers that preserve this multiscale phase-coherence domain.

## 8. Hierarchical Fractal Coupling

The current architecture uses a dyadic hierarchical ultrametric topology.

The cell count must be:

- a power of two;
- at least `2`.

Current default:

`16 cells`

Current default hierarchy depth:

`4`

Current hierarchical distance is derived from the relation between cell indices.

Current shell population:

`2^(distance - 1)`

Current coupling weights depend on:

- hierarchical distance;
- shell population;
- fractal exponent;
- global normalization.

Required fixed-point topology condition:

`fixed_point_topology_sum_exact = True`

The current executable preserves:

- dense coupling reference path;
- hierarchical coupling path;
- dense-to-hierarchical correlation structures.

## 9. Stateful Delay Dynamics

The current processor contains stateful internal frequency delay.

Each cell maintains:

- base frequency;
- frequency target;
- current frequency.

Current default delay coefficient:

`delay_alpha = 0.30`

The delayed frequency response contributes to:

- phase velocity;
- generated power;
- coherence;
- dynamic stability.

The delay layer is part of the computational mechanism.

## 10. Local Thermal-Phase Interaction

The current processor maintains a distributed local thermal field.

Each cell tracks:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The local thermal field is affected by:

- base activity;
- switching activity;
- frequency lag;
- ambient heat;
- thermal relaxation;
- thermal diffusion.

The thermal field feeds back into:

- effective resonant coupling;
- local gamma drift;
- nonlinear coherence compression.

The repository therefore preserves a coupled relation:

`phase and frequency dynamics`

↓

`generated power`

↓

`local thermal field`

↓

`effective coupling and gamma drift`

↓

`phase evolution`

↓

`coherence`

↓

`stability`

## 11. Local Correlated Gamma Drift

The current architecture maintains:

- nominal gamma;
- deterministic gamma-noise targets;
- correlated gamma-noise states;
- thermal overload;
- effective local gamma;
- gamma drift.

The resulting effective local gamma enters the Kuramoto-Sakaguchi phase interaction.

The M15 hardware-facing path externalizes deterministic gamma-noise targets into the verification stimulus domain.

Relevant current fields include:

`gamma_noise_update_valid`

`gamma_noise_target_q`

The current fixed-point gamma representation is:

`GAMMA_S32`

## 12. Nonlinear Coherence Compression

The current architecture applies nonlinear compression to raw phase coherence.

The current relation is:

`effective coherence = raw phase coherence × coherence compression`

The compression response depends on:

- thermal overload;
- stability-margin pressure.

This layer links:

`phase coherence`

↓

`thermal and stability pressure`

↓

`effective coherence`

The nonlinear coherence-compression layer is part of current processor behavior.

## 13. Dynamic Stability

The current executable tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing load:

`P(t) = heat + switch_load`

Required current condition:

`C_minus_P_min > 0.0`

The current operational coherence includes contributions from:

- effective phase coherence;
- cluster coherence;
- neutral-state fraction;
- frequency-lag penalty.

The dynamic stability domain is therefore connected to:

- resonant phase dynamics;
- multiscale coherence;
- delay;
- thermal state;
- switching load;
- active neutral state.

## 14. Phase-Derived Ternary Target

The current executable maps the evolving phase field into balanced ternary targets.

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This relation connects:

`resonant phase field`

to:

`balanced ternary target domain`

The target is then processed through:

- distributed commit;
- transition-fraction control;
- scheduler timing;
- pending routes;
- active neutral routing.

The target is not applied as unrestricted immediate state replacement.

## 15. Balanced Ternary State and Retained-Result Domain

The processor state and retained-result domain is:

`{-1, 0, 1}`

Validated states:

`-1`

`0`

`1`

Active neutral state:

`0`

The neutral state remains an active:

- balancing state;
- damping state;
- transition state;
- stabilization state;
- conflict-neutralization state;
- switching-load-control state.

Required state-domain marker:

`balanced_ternary_state_domain = True`

Required reserved-state condition:

`reserved_state_events = 0`

## 16. Mandatory Active-Neutral Routing

Direct opposite-polarity execution is prohibited.

Prohibited direct execution:

`-1 ↔ 1`

Validated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

The final state vector alone is not sufficient evidence of correct processor execution.

The transition path must preserve the active neutral route.

## 17. Distributed Commit

The current processor does not force the entire state vector to switch simultaneously by default.

Current default transition fraction:

`0.25`

Current maximum-change relation:

`max_changes = max(1, round(cells × transition_fraction))`

Current default 16-cell configuration:

`request_lanes = 4`

Required current condition:

`switch_load_peak <= transition_fraction`

Default validated boundary:

`switch_load_peak <= 0.25`

Distributed commit connects the phase-derived target domain to bounded retained-state transition.

## 18. Scheduler Layer

The current executable preserves three scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Validated 16-tick profiles:

| Scheduler | Validated counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Validated default 64-tick profile:

`balance = 56`

`commit = 8`

Required relation:

`sum(scheduler_counts) = ticks_recorded`

The scheduler affects:

- temporal transition structure;
- phase velocity;
- distributed commit timing.

## 19. Repository Root

The repository root contains:

- the current executable reference;
- the complete historical executable version chain;
- current and historical test reports;
- current and historical release notes;
- validation indices;
- architecture tracking documents;
- installation and usage documentation;
- reproducibility documentation;
- continuous integration documentation;
- contribution and security policies;
- citation and licensing metadata.

Current primary files:

| File | Purpose |
|---|---|
| `README.md` | main public processor overview and current architecture layer |
| `frp_prototype_v1_7_0.py` | current FRP v1.7.0 executable reference |
| `TEST_REPORT_v1_7_0.md` | current M15 validation record |
| `FRP_VALIDATION_INDEX_v1_7_0.md` | current M15 validation index |
| `RELEASE_NOTES_v1_7_0.md` | current release notes |
| `ROADMAP.md` | architecture progression through M15 and next planned M16 layer |
| `MILESTONES.md` | milestone chain from M0 through current M15 and planned M16 |
| `PROJECT_STRUCTURE.md` | repository structure guide |
| `CHANGELOG.md` | version history and release chronology |
| `INSTALL.md` | installation and first-run path |
| `USAGE.md` | execution, command, export, and validation reference |
| `REPRODUCIBILITY.md` | full computational and M15 reproducibility path |
| `CI.md` | Continuous Integration and qualification structure |
| `CONTRIBUTING.md` | contribution and validation guide |
| `SECURITY.md` | security policy |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `funding_brief.md` | partner and funding-facing technical brief |
| `requirements.txt` | Python dependency list |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | repository notice |
| `.gitignore` | ignored local files |

## 20. Current Executable Reference Layer

Current executable reference:

`frp_prototype_v1_7_0.py`

Current architecture layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The current executable preserves the full resonant phase-coherence computational mechanism and balanced ternary state-retention mechanism.

It extends the M14 floating semantic reference into deterministic hardware-facing representation and correlation layers.

The M15 bridge is:

`M14 floating semantic reference`

↓

`hardware-facing numeric types`

↓

`balanced ternary hardware encoding`

↓

`deterministic fixed-point arithmetic`

↓

`stateful quantized hardware shadow execution`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`verification preload and deterministic stimulus`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation mapping`

↓

`floating semantic correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

M15 maps the processor behavior.

It does not replace the resonant computational core.

## 21. Current M15 Artifact Layers

The current executable defines ten M15 implementation-mapping and qualification layers:

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

The dependency direction is:

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

`synthesizable RTL reference-core map`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

## 22. M15 Hardware-Facing Numeric Domain

Current primary numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Required exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The fixed-point domain maps:

- phase;
- frequency;
- gamma;
- coherence;
- hierarchy weights;
- thermal weights;
- stability values;
- state-transition execution.

## 23. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Required invariant:

`reserved_state_events = 0`

The encoding represents the ternary state domain.

It is not the complete processor computation.

## 24. Current Structured-Output Layer

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current default configuration:

| Parameter | Value |
|---|---:|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |
| gamma | `0.30 × pi` |
| fractal alpha | `0.70` |
| thermal beta | `1.20` |
| ambient heat | `0.05` |
| thermal time constant | `14.0` |
| thermal soft limit | `0.22` |
| thermal hard limit | `0.90` |
| nominal coupling | `0.28` |
| delay alpha | `0.30` |
| thermal diffusion gain | `0.035` |

Derived default structure:

| Parameter | Value |
|---|---:|
| hierarchy depth | `4` |
| request lanes | `4` |
| packed ternary state width | `32 bits` |

Required current invariants include:

- balanced ternary state-domain validity;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- valid scheduler counts;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 25. Executable Version Chain

The repository preserves the complete executable architecture chain.

| File | Architecture layer |
|---|---|
| `frp_prototype_v0_9_3_mobile.py` | original stabilized executable resonant reference layer |
| `frp_prototype_v0_9_4.py` | structured output and machine-readable validation |
| `frp_prototype_v0_9_5.py` | benchmark export and hardware signal mapping |
| `frp_prototype_v0_9_6.py` | HDL trace export and testbench scaffold |
| `frp_prototype_v0_9_7.py` | RTL interface contract and assertion harness |
| `frp_prototype_v0_9_8.py` | formal verification hooks and equivalence scaffold |
| `frp_prototype_v0_9_9.py` | FPGA synthesis and timing constraint scaffold |
| `frp_prototype_v1_0_0.py` | production release and stable interface freeze |
| `frp_prototype_v1_1_0.py` | silicon and heterogeneous implementation architecture |
| `frp_prototype_v1_2_0.py` | silicon production and tapeout readiness |
| `frp_prototype_v1_3_0.py` | production integration and external implementation handoff |
| `frp_prototype_v1_4_0.py` | external implementation feedback and production iteration |
| `frp_prototype_v1_5_0.py` | production scaling and implementation stabilization |
| `frp_prototype_v1_6_0.py` | physical implementation correlation and production qualification |
| `frp_prototype_v1_7_0.py` | implementation mapping, domain interface, and qualification closure |

Historical executable files remain release-specific architecture records.

The current executable reference is:

`frp_prototype_v1_7_0.py`

## 26. Foundational Resonant Layer

The earliest executable and documentation layers establish the foundational FRP relation:

`balanced ternary transformation`

↓

`resonance selection`

↓

`Kuramoto-Sakaguchi phase evolution`

↓

`coherence accumulation`

↓

`neutral conflict routing`

↓

`distributed commit`

↓

`stable mode retention`

The foundational processor distinction is:

`FRP resonant phase layer + distributed active-neutral ternary routing`

versus:

`distributed neutral ternary routing without the resonant phase layer`

These are not the same architecture.

The repository preserves that distinction in:

- foundational executable history;
- foundational benchmark evidence;
- core documentation;
- resonance-computation documentation;
- historical structured telemetry.

## 27. M14 Inherited Dynamic Architecture

The current v1.7.0 executable inherits M14 architecture domains.

Inherited schema families include:

- hierarchical ultrametric topology;
- fractal coupling weights;
- multiscale phase coherence;
- cluster-local thermal fields;
- cross-cluster propagation;
- localized hotspot containment;
- dense-to-hierarchical equivalence;
- physical-domain correlation.

The current executable preserves these domains while adding the M15 implementation-mapping and qualification layer.

## 28. M13 Inherited Stabilization Architecture

The current architecture also inherits the stabilization domains established before M14.

These include:

- delay dynamics;
- nonlinear coherence compression;
- thermal Sakaguchi gamma drift;
- stability-boundary detection;
- recovery dynamics;
- production scaling pressure.

The current v1.7.0 executable preserves:

- stateful frequency lag;
- thermal-phase interaction;
- correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation.

## 29. Validation Record Chain

The repository preserves release-specific test reports.

Files:

- `TEST_REPORT_v0_9_3.md`;
- `TEST_REPORT_v0_9_4.md`;
- `TEST_REPORT_v0_9_5.md`;
- `TEST_REPORT_v0_9_6.md`;
- `TEST_REPORT_v0_9_7.md`;
- `TEST_REPORT_v0_9_8.md`;
- `TEST_REPORT_v0_9_9.md`;
- `TEST_REPORT_v1_0_0.md`;
- `TEST_REPORT_v1_1_0.md`;
- `TEST_REPORT_v1_2_0.md`;
- `TEST_REPORT_v1_3_0.md`;
- `TEST_REPORT_v1_4_0.md`;
- `TEST_REPORT_v1_5_0.md`;
- `TEST_REPORT_v1_6_0.md`;
- `TEST_REPORT_v1_7_0.md`.

Current validation record:

`TEST_REPORT_v1_7_0.md`

Current validation status:

`PASS`

Current validated M15 self-test result:

`41/41 PASS`

Historical test reports remain release-specific evidence.

## 30. Validation Index Chain

Validation indices are preserved from the M7 release layer through current M15.

Files:

- `FRP_VALIDATION_INDEX_v0_9_9.md`;
- `FRP_VALIDATION_INDEX_v1_0_0.md`;
- `FRP_VALIDATION_INDEX_v1_1_0.md`;
- `FRP_VALIDATION_INDEX_v1_2_0.md`;
- `FRP_VALIDATION_INDEX_v1_3_0.md`;
- `FRP_VALIDATION_INDEX_v1_4_0.md`;
- `FRP_VALIDATION_INDEX_v1_5_0.md`;
- `FRP_VALIDATION_INDEX_v1_6_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Historical validation indices remain release-specific records.

## 31. Release Record Chain

The repository preserves release notes for every published architecture layer.

Files:

- `RELEASE_NOTES_v0_9_3.md`;
- `RELEASE_NOTES_v0_9_4.md`;
- `RELEASE_NOTES_v0_9_5.md`;
- `RELEASE_NOTES_v0_9_6.md`;
- `RELEASE_NOTES_v0_9_7.md`;
- `RELEASE_NOTES_v0_9_8.md`;
- `RELEASE_NOTES_v0_9_9.md`;
- `RELEASE_NOTES_v1_0_0.md`;
- `RELEASE_NOTES_v1_1_0.md`;
- `RELEASE_NOTES_v1_2_0.md`;
- `RELEASE_NOTES_v1_3_0.md`;
- `RELEASE_NOTES_v1_4_0.md`;
- `RELEASE_NOTES_v1_5_0.md`;
- `RELEASE_NOTES_v1_6_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

The repository also preserves:

- `RELEASE_CHECKLIST_v0_9_3.md`;
- `FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md`.

Historical release records remain bound to their corresponding architecture layers.

## 32. Documentation Directory

Directory:

`docs/`

The `docs/` directory contains the public technical documentation chain.

The directory combines:

- foundational processor documentation;
- implementation pathway documentation;
- hardware-facing mapping documents;
- milestone architecture packages;
- validation interpretation documents.

## 33. Documentation Directory Index

Primary index:

`docs/README.md`

The index organizes:

- current architecture documentation;
- foundational computational documents;
- hardware-facing pathway documents;
- milestone-specific architecture packages;
- validation interpretation documents.

The current architecture endpoint is:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

## 34. Foundational Computational Documentation

| File | Purpose |
|---|---|
| `docs/core_principles.md` | foundational processor principles |
| `docs/resonance_computation.md` | resonance-based computational interpretation |
| `docs/architecture.md` | architecture documentation |
| `docs/output_schema.md` | structured output and machine-readable validation structure |
| `docs/benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `docs/limitations.md` | documented evidence and validation boundaries |

The foundational computational documents contain the original public explanation of:

- balanced ternary states;
- active neutral state;
- Kuramoto-Sakaguchi phase coupling;
- phase lag gamma;
- resonance selection;
- nonlinear response;
- delay;
- coherence;
- distributed commit;
- stable mode retention.

Historical version wording inside older documentation remains historical and should not be treated as the current release identity.

## 35. Hardware-Facing Pathway Documentation

| File | Purpose |
|---|---|
| `docs/hardware_pathway.md` | hardware-facing development pathway |
| `docs/implementation_layers.md` | staged implementation layers |
| `docs/fpga_mapping_study.md` | FPGA-oriented mapping study |
| `docs/asic_mapping_study.md` | ASIC-oriented mapping study |
| `docs/physical_validation_plan.md` | physical validation planning |

These files connect the executable architecture to hardware-facing implementation domains.

## 36. M3 Documentation

| File | Purpose |
|---|---|
| `docs/m3_validation_targets.md` | M3 validation targets |
| `docs/benchmark_matrix.md` | benchmark export structure |
| `docs/hardware_signal_mapping.md` | hardware-facing signal mapping |
| `docs/fpga_register_map_draft.md` | FPGA register-map draft |
| `docs/testbench_comparison_plan.md` | testbench comparison plan |

M3 establishes the first explicit export and hardware-signal mapping layer.

## 37. M4 Through M15 Architecture Documents

| File | Architecture layer |
|---|---|
| `docs/m4_hdl_trace_testbench.md` | M4 HDL Trace Export and Testbench Scaffold |
| `docs/m5_rtl_interface_assertion_harness.md` | M5 RTL Interface Contract and Assertion Harness |
| `docs/m6_formal_verification_equivalence.md` | M6 Formal Verification Hooks and Equivalence Scaffold |
| `docs/m7_fpga_synthesis_timing.md` | M7 FPGA Synthesis Package and Timing Constraint Scaffold |
| `docs/m8_production_release_package.md` | M8 Production Release Package and Stable Interface Freeze |
| `docs/m9_silicon_heterogeneous_architecture.md` | M9 Silicon and Heterogeneous Implementation Architecture |
| `docs/m10_silicon_production_tapeout_readiness.md` | M10 Silicon Production and Tapeout Readiness Package |
| `docs/m11_production_integration_external_handoff.md` | M11 Production Integration and External Implementation Handoff |
| `docs/m12_external_implementation_feedback_iteration.md` | M12 External Implementation Feedback and Production Iteration Loop |
| `docs/m13_production_scaling_implementation_stabilization.md` | M13 Production Scaling and Implementation Stabilization Package |
| `docs/m14_physical_implementation_correlation_production_qualification.md` | M14 Physical Implementation Correlation and Production Qualification Package |
| `docs/m15_implementation_mapping_domain_interface_qualification_closure.md` | current M15 Implementation Mapping, Domain Interface, and Qualification Closure Package |

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

The repository also preserves the root-level M5 companion file:

`m5_rtl_interface_assertion_harness.md`

## 38. Verification Directory

Directory:

`verification/`

Files:

| File | Purpose |
|---|---|
| `verification/README.md` | verification layer overview |
| `verification/coherence_metrics.md` | coherence and operational metric definitions |

The verification layer supports interpretation of:

- phase coherence;
- operational coherence;
- dynamic stability;
- execution telemetry.

It remains supporting documentation around the executable reference and release-specific validation records.

## 39. Examples Directory

Directory:

`examples/`

Files:

| File | Purpose |
|---|---|
| `examples/README.md` | examples overview |
| `examples/resonance_convergence_example.md` | resonance-convergence example |

The examples layer provides practical interpretation material for repository review.

It does not replace executable validation.

## 40. Simulations Directory

Directory:

`simulations/`

Files:

| File | Purpose |
|---|---|
| `simulations/README.md` | simulation background index |
| `simulations/initial_kuramoto_result.md` | preliminary Kuramoto background result |

The simulation directory preserves supporting historical background material.

It does not define the current FRP v1.7.0 release identity.

It does not replace:

- the current executable reference;
- the current test report;
- the current validation index;
- the current M15 architecture package.

## 41. Models Directory

Directory:

`models/`

Files:

| File | Purpose |
|---|---|
| `models/README.md` | model background index |
| `models/kuramoto_frp_background_model.md` | Kuramoto-type background model context |

The model directory preserves conceptual and mathematical background.

The current processor implementation is defined by:

`frp_prototype_v1_7_0.py`

and the complete published architecture chain.

## 42. Comparative Architecture Benchmark Directory

Directory:

`benchmarks/architecture_comparison/`

The Comparative Architecture Benchmark Suite is a supporting validation contour aligned with:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

The suite compares:

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

The suite is additive.

It does not modify:

- the FRP resonant computational core;
- the balanced ternary state-retention mechanism;
- M15 schemas;
- the M15 qualification workflow;
- the M15 release boundary.

## 43. Comparative Benchmark Execution Files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/run_architecture_comparison.py` | canonical comparative architecture benchmark runner |
| `benchmarks/architecture_comparison/run_hardware_sensitivity_comparison.py` | hardware-informed sensitivity comparison runner |
| `benchmarks/architecture_comparison/validate_hardware_sensitivity_profile.py` | hardware-sensitivity profile validator |

## 44. Comparative Architecture Reference Files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/binary_synchronous_reference.py` | binary synchronous reference |
| `benchmarks/architecture_comparison/binary_clock_gated_reference.py` | binary clock-gated reference |
| `benchmarks/architecture_comparison/direct_ternary_reference.py` | direct ternary reference |
| `benchmarks/architecture_comparison/frp_v1_7_0_adapter.py` | FRP v1.7.0 benchmark adapter |

The FRP reference remains a resonant phase-coherence architecture.

It must not be interpreted as a static ternary switching reference.

## 45. Shared Benchmark Model Files

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/common_workload.py` | shared deterministic semantic workload |
| `benchmarks/architecture_comparison/common_cost_model.py` | common normalized cost model |
| `benchmarks/architecture_comparison/common_thermal_model.py` | common thermal proxy model |

The common workload and common models preserve comparison consistency across architecture references.

## 46. Benchmark Profiles

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/profiles/workload_profile_v1.json` | deterministic workload profile |
| `benchmarks/architecture_comparison/profiles/normalized_cost_profile_v1.json` | normalized cost profile |
| `benchmarks/architecture_comparison/profiles/thermal_proxy_profile_v1.json` | common thermal proxy profile |
| `benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json` | hardware-sensitivity cost profile |

## 47. Calibration and Coefficient Provenance

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/calibration/hardware_cost_calibration_v1.md` | hardware-cost calibration layer |
| `benchmarks/architecture_comparison/calibration/coefficient_provenance_map_v1.md` | coefficient provenance map |

The hardware-sensitivity layer uses common scenario profiles across compared architectures.

## 48. Machine-Readable Comparison Results

| File | Purpose |
|---|---|
| `benchmarks/architecture_comparison/results/reference_comparison_seed_76.json` | canonical comparative architecture result |
| `benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json` | hardware-sensitivity comparison result |

The comparison policy remains:

`integrity_only_no_winner_assertions`

Required winner assertions:

`[]`

The result remains data.

## 49. Original Resonant Benchmark Distinction

The foundational benchmark preserves the distinction between:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

The essential architecture distinction is:

`FRP = resonant phase layer + distributed active-neutral ternary routing`

The architecture:

`distributed_neutral_ternary`

does not contain the full resonant phase computational layer.

These two execution models must not be collapsed into one description.

## 50. GitHub Actions Directory

Directory:

`.github/workflows/`

The repository contains:

`19`

GitHub Actions workflows.

The workflow structure covers:

- foundational executable validation;
- foundational resonant benchmark validation;
- structured output validation;
- architecture milestone qualification;
- comparative architecture qualification;
- hardware-sensitivity qualification.

## 51. Foundational Validation Workflows

| Workflow | Purpose |
|---|---|
| `frp-self-test.yml` | foundational FRP executable self-test |
| `frp-benchmark-smoke.yml` | foundational resonant benchmark smoke validation |
| `frp-structured-output.yml` | structured output validation |

These workflows remain bound to their historical executable references.

They are not silently redirected to `frp_prototype_v1_7_0.py`.

## 52. Architecture Milestone Workflows

| Workflow | Architecture layer |
|---|---|
| `frp-m3-benchmark-signal-map.yml` | M3 Benchmark Export and Hardware Signal Mapping |
| `frp-m4-hdl-trace.yml` | M4 HDL Trace and Testbench |
| `frp-m5-rtl-assertion-harness.yml` | M5 RTL Interface and Assertion Harness |
| `frp-m6-formal-verification.yml` | M6 Formal Verification and Equivalence |
| `frp-m7-fpga-synthesis.yml` | M7 FPGA Synthesis and Timing |
| `frp-m8-production-release.yml` | M8 Production Release Package |
| `frp-m9-silicon-architecture.yml` | M9 Silicon and Heterogeneous Architecture |
| `frp-m10-silicon-production-tapeout.yml` | M10 Silicon Production and Tapeout Readiness |
| `frp-m11-production-integration-handoff.yml` | M11 Production Integration and External Handoff |
| `frp-m12-feedback-iteration.yml` | M12 External Implementation Feedback and Production Iteration |
| `frp-m13-production-scaling-stabilization.yml` | M13 Production Scaling and Implementation Stabilization |
| `frp-m14-physical-implementation-qualification.yml` | M14 Physical Implementation Correlation and Production Qualification |
| `frp-m15-implementation-mapping-qualification.yml` | current M15 Implementation Mapping and Qualification Closure |

Current primary milestone workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

## 53. Supporting Comparative Workflows

| Workflow | Purpose |
|---|---|
| `frp-architecture-comparison.yml` | comparative architecture benchmark qualification |
| `frp-hardware-sensitivity-comparison.yml` | hardware-sensitivity comparison qualification |
| `frp-hardware-sensitivity-profile.yml` | hardware-sensitivity profile qualification |

These workflows remain supporting validation contours.

They do not replace the architecture milestone chain.

## 54. Current M15 Workflow Role

Current workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

The workflow validates:

- Python compilation;
- current structured output;
- the four-profile self-test matrix;
- the ten M15 artifact layers;
- current schemas;
- processor invariants;
- fixed-point contracts;
- scaling behavior;
- quantized shadow execution;
- cycle-exact traces;
- deterministic vector packages;
- SHA-256 vector integrity;
- SystemVerilog interface mapping;
- RTL reference-core contract;
- RTL assertion correlation;
- floating-to-quantized reference equivalence;
- exact quantized replay;
- qualification closure.

## 55. Current M15 Self-Test Structure

Current validated self-test check count:

`41`

Current result:

`41/41 PASS`

The self-test package covers:

- scheduler behavior;
- both opposite-polarity neutral routes;
- queue behavior;
- request-lane ordering;
- balanced ternary encoding;
- fixed-point boundaries;
- topology scaling;
- execution scaling;
- semantic sequence preservation;
- dynamic stability-sign preservation;
- quantized shadow invariants;
- exact replay;
- deterministic vector generation;
- all ten M15 schemas;
- qualification closure.

The self-test does not reduce the processor to a final state-vector assertion.

## 56. Deterministic Vector Package

The current M15 vector package contains exactly:

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

Two independently generated vector directories must be:

`byte-identical`

The SHA-256 manifest binds the non-manifest vector files to exact generated content.

## 57. Reference Equivalence Structure

The current M15 equivalence layer distinguishes two boundaries.

### 57.1 Floating semantic reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Current maximum numeric error bounds:

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

This boundary preserves the resonant phase, delay, thermal, gamma, coherence, state, route, and stability domains.

### 57.2 Exact quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 58. Qualification Closure Structure

The current qualification closure manifest requires:

- status `PASS`;
- all closure checks equal `True`;
- exactly ten M15 artifact layers.

The current closure path is:

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

`SystemVerilog interface mapping`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

## 59. Current Validation Evidence

Current validated release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Release-record validated commit:

`5fd9a4f`

Validated workflow stack recorded in:

`TEST_REPORT_v1_7_0.md`

Recorded workflow runs:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Current validation result:

`PASS`

Current M15 self-test result:

`41/41 PASS`

Primary validation records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

The validated commit and workflow-run numbers are release-specific evidence.

Later documentation commits must not be presented as the original validated release commit.

## 60. Architecture Milestone Chain

The repository preserves the following progression:

| Milestone | Version | Architecture layer | Status |
|---|---|---|---|
| M0 | v0.9.3-mobile | Repository Stabilization | Completed |
| M1 | v0.9.3 | Archival Release and DOI | Completed |
| M2 | v0.9.4 | Structured Output and Machine-Readable Validation | Completed |
| M3 | v0.9.5 | Benchmark Export and Hardware Signal Mapping | Completed |
| M4 | v0.9.6 | HDL Trace Export and Testbench Scaffold | Completed |
| M5 | v0.9.7 | RTL Interface Contract and Assertion Harness | Completed |
| M6 | v0.9.8 | Formal Verification Hooks and Equivalence Scaffold | Completed |
| M7 | v0.9.9 | FPGA Synthesis Package and Timing Constraint Scaffold | Completed |
| M8 | v1.0.0 | Production Release Package and Stable Interface Freeze | Completed |
| M9 | v1.1.0 | Silicon and Heterogeneous Implementation Architecture | Completed |
| M10 | v1.2.0 | Silicon Production and Tapeout Readiness Package | Completed |
| M11 | v1.3.0 | Production Integration and External Implementation Handoff | Completed |
| M12 | v1.4.0 | External Implementation Feedback and Production Iteration Loop | Completed |
| M13 | v1.5.0 | Production Scaling and Implementation Stabilization Package | Completed |
| M14 | v1.6.0 | Physical Implementation Correlation and Production Qualification Package | Completed |
| M15 | v1.7.0 | Implementation Mapping, Domain Interface, and Qualification Closure Package | Current validated layer |
| M16 | v1.8.0 | RTL Core Realization and Execution Semantics Package | Next planned layer |

Architecture tracking is maintained in:

- `ROADMAP.md`;
- `MILESTONES.md`.

## 61. Reproducibility Layer

The current reproducibility chain is:

`INSTALL.md`

↓

`USAGE.md`

↓

`REPRODUCIBILITY.md`

↓

`CI.md`

↓

`current executable reference`

↓

`current test report`

↓

`current validation index`

↓

`current release notes`

The current executable reference is:

`frp_prototype_v1_7_0.py`

The current reproducibility documents preserve the complete computational path:

`Kuramoto-Sakaguchi coupling`

↓

`hierarchical phase interaction`

↓

`phase evolution`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay dynamics`

↓

`thermal-phase interaction`

↓

`gamma drift`

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

↓

`M15 deterministic mapping`

## 62. Release and Metadata Layer

Repository metadata files include:

| File | Purpose |
|---|---|
| `CHANGELOG.md` | version chronology |
| `ROADMAP.md` | architecture progression |
| `MILESTONES.md` | milestone structure |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache License 2.0 |
| `NOTICE` | repository notice |
| `SECURITY.md` | security policy |
| `CONTRIBUTING.md` | contribution guide |
| `CODE_OF_CONDUCT.md` | participation and conduct policy |
| `funding_brief.md` | partner and funding-facing technical brief |

Historical test reports, release notes, validation indices, and release manifests remain preserved as release-specific records.

## 63. Repository Naming Discipline

Processor name:

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

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Historical files must retain their historical version identity.

They must not be rewritten as current-state files.

## 64. Computational-Core Documentation Rule

When a repository-facing file explains what FRP is or how FRP computes, it must preserve the complete computational subject.

Required semantic chain:

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`hierarchical fractal phase interaction`

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

`retained ternary state`

A description that begins and ends with `{-1, 0, 1}` and neutral routing is incomplete.

The balanced ternary domain is essential.

The resonant phase-coherence mechanism is also essential.

## 65. Architecture Continuity Rule

The processor architecture must not be split into disconnected descriptions.

The correct continuity is:

`resonant dynamic computation`

↓

`phase-derived state formation`

↓

`balanced ternary transition control`

↓

`retained coherent state`

↓

`structured validation`

↓

`hardware-facing mapping`

↓

`cycle-exact implementation correlation`

↓

`qualification closure`

Later implementation layers map earlier processor semantics.

They do not replace those semantics.

## 66. Historical Preservation Rule

Historical files preserve release-specific architecture states.

Do not silently:

- redirect an old workflow to the current executable;
- replace an old schema identifier with a current schema identifier;
- rewrite an old test report as a current report;
- rewrite historical benchmark evidence as current M15 evidence;
- remove the historical distinction between resonant FRP execution and non-resonant neutral ternary baselines.

Historical records remain historical.

Current files must describe the current architecture.

## 67. Comparative Benchmark Boundary Rule

The Comparative Architecture Benchmark Suite is a supporting validation contour.

It does not define:

- the processor computational core;
- the architecture milestone chain;
- the M15 implementation-mapping contract;
- the M15 qualification closure boundary.

The comparison suite must preserve:

- identical semantic workload;
- independent architecture execution;
- one common normalized cost model;
- one common thermal proxy model;
- explicit FRP computational overhead;
- no winner assertions.

## 68. Repository Alignment Rule

When the current architecture layer changes, review:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CHANGELOG.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `CONTRIBUTING.md`;
- current executable reference;
- current `TEST_REPORT`;
- current `FRP_VALIDATION_INDEX`;
- current `RELEASE_NOTES`;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

Where computational identity is described, verify that the complete resonant core remains visible.

Where version state is described, verify:

- current version;
- current milestone;
- current executable filename;
- current validation result;
- current schema names;
- current workflow path.

Historical release records must remain historical.

## 69. Current Public Repository Structure

The current public repository contains:

- the complete executable FRP version chain from v0.9.3-mobile through v1.7.0;
- the current FRP v1.7.0 M15 executable reference;
- the Kuramoto-Sakaguchi resonant phase computational mechanism;
- hierarchical fractal phase coupling;
- phase evolution;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- distributed local thermal dynamics;
- thermal coupling degradation;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation;
- phase-derived balanced ternary target formation;
- the balanced ternary state domain `{-1, 0, 1}`;
- active neutral state `0`;
- mandatory tick-separated neutral routing;
- distributed commit;
- retained ternary state;
- release-specific test reports;
- release-specific release notes;
- validation indices through M15;
- M3 through M15 architecture documentation;
- structured output validation;
- hardware-facing signal mapping;
- HDL and testbench preparation;
- RTL interface and assertion layers;
- formal verification and equivalence scaffolds;
- FPGA synthesis and timing structures;
- stable production interface structures;
- silicon and heterogeneous implementation architecture;
- tapeout-readiness structures;
- external implementation handoff structures;
- production iteration and stabilization layers;
- physical implementation correlation and qualification;
- fixed-point implementation mapping;
- balanced ternary hardware encoding;
- stateful quantized hardware shadow execution;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized reference correlation;
- exact quantized deterministic replay;
- qualification closure;
- reproducibility documentation;
- 19 GitHub Actions workflows;
- comparative architecture benchmark support;
- hardware-sensitivity qualification;
- documentation, verification, examples, simulations, and model layers;
- citation and licensing metadata.

## 70. Complete Current Repository Chain

The complete current repository chain is:

`Fractal Resonance Processor`

↓

`ternary resonant coherence processor`

↓

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

`resonance selection`

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

`release-specific validation`

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

`balanced ternary hardware encoding`

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

`floating-to-quantized reference correlation`

↓

`exact quantized deterministic replay`

↓

`qualification closure`

The resonant phase-coherence mechanism remains the computational core throughout this chain.

The balanced ternary domain remains the state and retained-result domain throughout this chain.

## 71. Current Status

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

Current repository role:

`preserve the complete Fractal Resonance Processor architecture from Kuramoto-Sakaguchi resonant phase evolution, multiscale phase coherence, delay and thermal-phase dynamics, nonlinear coherence compression, phase-derived balanced ternary state formation, distributed active-neutral routing, and retained state through deterministic hardware-facing implementation mapping, cycle-exact execution, RTL correlation, reference equivalence, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

# Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

## Reproducibility

This document defines the complete reproducibility path for the current Fractal Resonance Processor (FRP) executable reference, resonant computational mechanism, balanced ternary state-retention mechanism, M15 deterministic implementation mapping, and qualification closure.

FRP is a ternary resonant coherence processor.

FRP computes through resonant phase dynamics, coherence evolution, stateful feedback, and balanced ternary state retention.

The complete current computational path combines:

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

`delay dynamics`

↓

`local thermal-phase interaction`

↓

`local gamma drift`

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

## 1. Reproducibility Target

The reproducibility target is the complete dynamic computational path together with the final retained ternary state vector.

A complete reproduction must preserve the dynamic computational path that produces and retains that state.

The primary reproducibility chain is:

`source revision`

↓

`execution environment`

↓

`deterministic initialization`

↓

`processor configuration`

↓

`balanced ternary state domain`

↓

`phase and frequency initialization`

↓

`hierarchical coupling topology`

↓

`Kuramoto-Sakaguchi phase interaction`

↓

`delay and thermal dynamics`

↓

`local gamma dynamics`

↓

`phase evolution`

↓

`global and multiscale phase coherence`

↓

`nonlinear coherence compression`

↓

`dynamic stability`

↓

`phase-derived ternary target formation`

↓

`distributed commit`

↓

`active neutral routing`

↓

`retained state`

↓

`structured telemetry`

↓

`independent deterministic repeat`

↓

`M15 fixed-point mapping`

↓

`quantized hardware shadow`

↓

`cycle-exact reference trace`

↓

`deterministic RTL vector regeneration`

↓

`reference equivalence`

↓

`qualification closure`

A complete reproduction verifies the connected set of:

- the final `{-1, 0, 1}` vector;
- the two-bit ternary encoding;
- the resonant phase-coherence execution path;
- the retained ternary state path;
- all required M15 artifacts;
- the complete self-test matrix.

The resonant phase-coherence path and the retained ternary state path remain connected throughout the reproduction sequence.

## 2. Two Inseparable Reproducibility Domains

The FRP computational core contains two inseparable reproducibility domains.

### 2.1 Resonant dynamic domain

The resonant dynamic domain contains:

- cell phase;
- base frequency;
- target frequency;
- current frequency;
- Kuramoto-Sakaguchi interaction;
- asymmetric phase lag;
- hierarchical fractal coupling;
- scheduler-dependent phase push;
- delayed frequency response;
- distributed thermal state;
- local thermal coupling degradation;
- local gamma drift;
- phase evolution;
- global phase order;
- multiscale phase coherence;
- nonlinear coherence compression;
- dynamic stability.

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

The ternary domain provides the target, state, transition, and retained-result layer.

A valid reproduction must preserve both.

## 3. Current Executable Reference

Use:

`frp_prototype_v1_7_0.py`

Current FRP v1.7.0 M15 reproduction uses `frp_prototype_v1_7_0.py`.

Historical executable references remain preserved for their corresponding historical architecture layers.

The current executable reference contains:

- the floating semantic reference path inherited through M14;
- the current M15 fixed-point interface contract;
- the stateful quantized hardware shadow;
- deterministic reference traces;
- deterministic vector generation;
- SystemVerilog interface mapping;
- RTL correlation contracts;
- qualification closure.

## 4. Environment

Current M15 GitHub Actions environment:

| Parameter | Value |
|---|---|
| runner | `ubuntu-latest` |
| Python | `3.12` |
| workflow timeout | `30 minutes` |

Recommended local environment:

`Python 3.12`

The declared dependency file is:

`requirements.txt`

Repository external dependency:

`numpy>=1.26.0`

NumPy is used by the historical FRP v0.9.3 and v0.9.4 executable layers. The current FRP v1.7.0 executable and Comparative Architecture Benchmark Suite use the Python standard library and repository-local modules.

Install from the repository root:

    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt

On systems where the interpreter command is:

`python3`

replace `python` with `python3`.

## 5. Record the Exact Source State

Before running a reproducibility sequence, record:

    git rev-parse HEAD
    git status --short
    python --version
    python -m pip freeze

Preserve:

- exact commit hash;
- working-tree state;
- Python version;
- installed dependency versions;
- operating environment;
- execution date;
- exact commands used.

Record the working-tree state exactly, including every uncommitted source difference, because those differences can alter deterministic output.

## 6. Required Current Files

Primary executable and dependency files:

- `frp_prototype_v1_7_0.py`;
- `requirements.txt`.

Current architecture and validation files:

- `README.md`;
- `INSTALL.md`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `docs/core_principles.md`;
- `docs/resonance_computation.md`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

Current primary qualification workflow:

- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Historical files preserve release-specific evidence.

The current v1.7.0 reproduction path uses the current v1.7.0 executable, architecture, validation, and workflow files.

## 7. Install and Compile

Install dependencies:

    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt

Compile the current executable reference:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

A successful compile gate completes with exit status `0`.

## 8. Current Default Configuration

The current default execution configuration is:

| Parameter | Default |
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
| equivalence tolerance | `1e-12` |

Derived default values:

| Derived parameter | Value |
|---|---:|
| hierarchy depth | `4` |
| request lanes | `4` |
| packed ternary state width | `32 bits` |

## 9. Internal Deterministic Constants

The current executable also contains internal constants that contribute to deterministic behavior.

Frequency and delay:

| Parameter | Value |
|---|---:|
| state frequency gain | `0.06` |
| switching frequency gain | `0.12` |
| delay alpha | `0.30` |

Thermal generation:

| Parameter | Value |
|---|---:|
| base power per cell | `0.0018` |
| switching power gain | `0.052` |
| frequency-lag power gain | `0.018` |

Thermal coupling:

| Parameter | Value |
|---|---:|
| thermal coupling gain | `2.50` |

Gamma dynamics:

| Parameter | Value |
|---|---:|
| gamma correlation alpha | `0.15` |
| gamma thermal gain | `0.08` |

Nonlinear coherence compression:

| Parameter | Value |
|---|---:|
| thermal compression gain | `3.0` |
| margin compression gain | `1.5` |
| stability soft margin | `0.25` |

Scheduler phase push:

| Scheduler state | Phase push |
|---|---:|
| `commit` | `0.010` |
| `excite` | `0.006` |
| all other states | `0.003` |

These constants are part of the current executable reference behavior.

## 10. Deterministic Initialization

Current default deterministic seed:

`76`

Use:

    python frp_prototype_v1_7_0.py --seed 76 --mode demo --output json

The seed contributes to deterministic initialization and deterministic correlated gamma-noise behavior.

A reproducibility record must preserve the exact seed.

Changing the seed creates a different deterministic execution.

## 11. Exact Tick Execution Order

The current floating reference tick executes in this order:

`scheduler-state selection`

↓

`switch-activity reset`

↓

`maximum transition capacity calculation`

↓

`pending neutral-route processing`

↓

`explicit transition-request processing`

↓

`phase-derived ternary target processing`

↓

`switch-load update`

↓

`delay-dynamics update`

↓

`local thermal-field update`

↓

`local gamma-drift update`

↓

`thermal coupling-factor update`

↓

`Kuramoto-Sakaguchi phase-field update`

↓

`multiscale phase-coherence evaluation`

↓

`cluster-metric evaluation`

↓

`nonlinear coherence compression and global stability update`

↓

`structured telemetry capture`

This order is part of the current semantic reference.

A change in update order can alter deterministic behavior even if every individual formula remains unchanged.

## 12. Phase-to-Target Temporal Relation

The current tick extracts automatic ternary targets from the phase field that exists at the beginning of the target-processing stage.

The same tick then updates:

- delay state;
- thermal state;
- gamma state;
- coupling field;
- phase state;
- coherence state.

Therefore, across successive ticks, the temporal relation is:

`phase field produced by previous evolution`

↓

`current tick ternary target extraction`

↓

`distributed transition`

↓

`delay and thermal update`

↓

`Kuramoto-Sakaguchi phase evolution`

↓

`new phase field`

↓

`next tick ternary target extraction`

This distinction must be preserved.

The reproduction preserves this stateful cross-tick relation exactly.

## 13. Kuramoto-Sakaguchi Resonant Phase Interaction

The current floating reference uses the phase-interaction term:

`sin(phase_j - phase_i - gamma_effective_i)`

The dense reference path evaluates:

`coupling_nominal × sum(weight_ij × thermal_factor_i × thermal_factor_j × sin(phase_j - phase_i - gamma_effective_i))`

The current default nominal coupling strength is:

`0.28`

The current default nominal phase lag is:

`0.30 × pi`

The current hierarchical path evaluates the same interaction through dyadic shell aggregation.

The dense and hierarchical paths provide two reference representations for correlation and equivalence work.

## 14. Hierarchical Fractal Coupling

The current architecture uses a dyadic hierarchical ultrametric topology.

The cell count must be:

- a power of two;
- at least `2`.

Hierarchy depth:

`cells.bit_length() - 1`

Current default:

`16 cells → hierarchy depth 4`

Hierarchical distance between two distinct cells:

`(i XOR j).bit_length()`

Shell population:

`2^(distance - 1)`

Current default fractal exponent:

`0.70`

The current shell-normalized coupling weights preserve exact normalized closure in the M15 fixed-point representation.

Required marker:

`fixed_point_topology_sum_exact = True`

## 15. Hierarchical Coupling Reproducibility

Changes affecting:

- cell count;
- hierarchy depth;
- hierarchical distance;
- shell population;
- coupling weight normalization;
- fractal exponent;
- dense reference path;
- hierarchical accelerated path;

must reproduce:

- deterministic topology;
- exact fixed-point topology closure;
- reference correlation;
- phase-field behavior;
- multiscale coherence behavior.

Topology reproduction covers deterministic topology, exact fixed-point closure, reference correlation, phase-field behavior, multiscale coherence behavior, and the final state.

## 16. Phase Velocity

The current floating reference phase velocity is:

`phase_velocity_i = 0.060 × current_frequency_i + scheduler_push + coupling_field_i`

The scheduler push is:

`commit → 0.010`

`excite → 0.006`

`other scheduler states → 0.003`

The phase then evolves as:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

A valid reproduction must preserve:

- frequency contribution;
- scheduler contribution;
- coupling contribution;
- phase wrapping.

## 17. Global Kuramoto Order Parameter R

The current global phase order is:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The executable calculates this through:

`phase_order(phases)`

The same phase-order calculation is used for hierarchical coherence domains.

The phase-order path is part of the processor operational state, and reproduction preserves `R` as a required computational metric.

## 18. Multiscale Phase-Coherence Reproduction

Current coherence domains include:

- pair domain;
- cluster domain;
- supercluster domain;
- global domain.

Current telemetry includes:

- pair-domain coherence mean;
- pair-domain coherence minimum;
- cluster coherence mean;
- cluster coherence minimum;
- supercluster coherence mean;
- supercluster coherence minimum;
- global phase coherence;
- coherence dispersion across clusters.

A change affecting the phase field should inspect all affected scales.

Changes affecting local or hierarchical dynamics are evaluated across every affected coherence scale together with global phase order.

## 19. Delay Dynamics

Each cell maintains:

- base frequency;
- frequency target;
- current frequency.

The current frequency target is:

`base_frequency`

+

`0.06 × abs(ternary state)`

+

`0.12 × local switching activity`

The delayed update is:

`frequency_current += 0.30 × (frequency_target - frequency_current)`

The remaining frequency lag is:

`abs(frequency_target - frequency_current)`

Frequency lag contributes to:

- phase velocity;
- generated power;
- operational coherence;
- dynamic stability.

A valid reproduction must preserve the stateful delayed frequency path.

## 20. Local Thermal Field

The current generated power per cell is:

`base power`

+

`switching power`

+

`frequency-lag power`

Current relation:

`generated_power_i = 0.0018 + 0.052 × switch_activity_i + 0.018 × frequency_lag_i`

Current thermal dissipation relation:

`thermal_dissipation_i = (previous_heat_i - ambient_heat) / thermal_time_constant`

Current thermal diffusion relation uses:

- the hierarchical thermal matrix;
- temperature differences between cells;
- thermal diffusion gain.

The next local heat state is bounded below by ambient heat.

Current default ambient heat:

`0.05`

Current default thermal time constant:

`14.0`

Current default thermal diffusion gain:

`0.035`

## 21. Thermal Overload

Current local thermal overload is:

`max(0, local_heat - thermal_soft_limit)`

Current default thermal soft limit:

`0.22`

The overload field affects:

- local thermal coupling degradation;
- local gamma drift;
- nonlinear coherence compression.

The thermal field is therefore coupled back into the resonant phase computation.

## 22. Thermal Coupling Degradation

Current local thermal node factor:

`exp(-0.5 × thermal_coupling_gain × overload)`

Current thermal coupling gain:

`2.50`

The dense pair interaction uses:

`thermal_node_factor_i × thermal_node_factor_j`

The hierarchical path preserves the same local thermal weighting structure.

A valid reproduction must preserve the feedback chain:

`local thermal overload`

↓

`thermal node factor`

↓

`effective coupling`

↓

`phase evolution`

↓

`coherence`

↓

`stability`

## 23. Local Gamma Drift

The current gamma-noise target field is refreshed every:

`8 ticks`

Current target range:

`[-1.0, 1.0]`

The correlated gamma-noise state approaches its target through:

`gamma_noise_state += 0.15 × (gamma_noise_target - gamma_noise_state)`

The effective local gamma is:

`gamma_nominal + 0.08 × thermal_overload × gamma_noise_state`

The local gamma drift is:

`gamma_effective - gamma_nominal`

The resulting local gamma enters the Kuramoto-Sakaguchi phase interaction.

A valid reproduction must preserve:

- deterministic target generation;
- update cadence;
- correlated state evolution;
- thermal coupling;
- effective local phase lag.

## 24. Nonlinear Coherence Compression

The current processor applies nonlinear compression to raw phase coherence.

Thermal overload mean:

`mean(local thermal overload)`

Margin pressure:

`max(0, stability_soft_margin - previous_C_minus_P)`

Current stability soft margin:

`0.25`

Current compression relation:

`coherence_compression = exp(-(3.0 × thermal_overload_mean² + 1.5 × margin_pressure²))`

Effective coherence:

`effective_coherence = raw_phase_coherence × coherence_compression`

This nonlinear relation is part of current v1.7.0 execution.

The reproduction uses the current effective-coherence relation exactly: raw phase coherence multiplied by coherence compression.

## 25. Dynamic Stability

The current processor tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current operational coherence:

`C = 0.82`

+

`0.34 × effective_coherence`

+

`0.16 × cluster_coherence_mean`

+

`0.08 × neutral_fraction`

-

`0.10 × mean_frequency_lag`

Current destabilizing load:

`P = heat + switch_load`

Current stability margin:

`C_minus_P = C - P`

Required default validation condition:

`C_minus_P_min > 0.0`

A reproduction must preserve the relationship between:

- phase coherence;
- multiscale coherence;
- neutral-state fraction;
- frequency lag;
- heat;
- switching load.

## 26. Phase-Derived Ternary Target

Current target mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This mapping connects:

`resonant phase field`

to:

`balanced ternary target domain`

The derived target remains subject to:

- transition-fraction limits;
- distributed commit;
- pending routes;
- active neutral routing.

The target enters distributed commit and route processing under transition-capacity and active-neutral execution rules.

## 27. Balanced Ternary State Domain

The state and retained-result domain is:

`{-1, 0, 1}`

Valid states:

`-1`

`0`

`1`

Active neutral state:

`0`

Required marker:

`balanced_ternary_state_domain = True`

Reserved-state requirement:

`reserved_state_events = 0`

## 28. Mandatory Active-Neutral Routing

Opposite-polarity execution follows mandatory active-neutral routes.

Validated routing relation:

`-1 → 0 → 1`

`1 → 0 → -1`

Current execution rule:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

The transition history must preserve the route.

Route evidence includes transition history and route counters together with the final state vector.

## 29. Pending Neutral Routes

Pending neutral routes preserve:

- cell index;
- target polarity;
- earliest ready tick.

A route is applied when all of the following conditions hold:

- its ready tick has been reached;
- transition capacity remains;
- the current state is neutral.

Current required conditions include:

`actual_direct_events = 0`

`queue_overflow_events = 0`

Changes affecting pending routes require exact trace validation.

## 30. Distributed Commit

Current default transition fraction:

`0.25`

Maximum state changes per tick:

`max(1, round(cells × transition_fraction))`

Default:

`16 cells × 0.25 → 4 request lanes`

Current required default boundary:

`switch_load_peak <= 0.25`

Distributed commit is part of the connection between:

`phase-derived target`

and:

`retained ternary state`

## 31. Standard Structured Reproduction

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json > demo-a.json

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Required default summary values:

| Field | Required value |
|---|---|
| `cells` | `16` |
| `hierarchy_depth` | `4` |
| `request_lanes` | `4` |
| `ticks_recorded` | `64` |
| `scheduler` | `7/1` |
| `scheduler_counts.balance` | `56` |
| `scheduler_counts.commit` | `8` |
| `scheduler_counts_valid` | `True` |
| `balanced_ternary_state_domain` | `True` |
| `reserved_state_events` | `0` |
| `actual_direct_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Additional required conditions:

`switch_load_peak <= 0.25`

`C_minus_P_min > 0.0`

## 32. Independent Structured Repeat

Generate the first output:

    python frp_prototype_v1_7_0.py --mode demo --output json > demo-a.json

Generate an independent second output:

    python frp_prototype_v1_7_0.py --mode demo --output json > demo-b.json

Compare:

    cmp demo-a.json demo-b.json

Required result:

`byte-identical`

The two runs must use:

- the same source revision;
- the same Python environment;
- the same dependency versions;
- the same configuration;
- the same seed.

## 33. Full Trace Reproduction

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace > demo-full-trace.json

The full output adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Default expected sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

The full trace exposes:

- scheduler state;
- ternary cell state;
- phase state;
- frequency target;
- current frequency;
- frequency lag;
- switching load;
- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload;
- effective gamma;
- gamma drift;
- thermal coupling factors;
- coupling field;
- raw phase coherence;
- coherence compression;
- effective coherence;
- multiscale coherence;
- C(t);
- P(t);
- C(t) - P(t);
- direct-event counters;
- neutral-route counters;
- pending-route count.

## 34. Digest Reproduction

Standard structured execution omits the `--include-trace` flag and preserves:

- preload digest;
- trace digest;
- cell-trace digest.

Use digest execution for:

- compact deterministic identity;
- routine CI validation;
- reproducibility comparisons.

Use full trace output for:

- phase-dynamics inspection;
- route inspection;
- cell-level analysis;
- correlation work.

## 35. Standard Self-Test

Run:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

| Field | Required value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `status` | `PASS` |
| `check_count` | `41` |
| all values in `checks` | `True` |

Current validated result:

`41/41 PASS`

## 36. Complete Scheduler Self-Test Matrix

Default profile:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every output must report:

`status = PASS`

`check_count = 41`

All checks must be:

`True`

## 37. Scheduler Reproduction

Current scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Validated 16-tick profiles:

| Scheduler | Required counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Validated default 64-tick profile:

`balance = 56`

`commit = 8`

Required relation:

`sum(scheduler_counts) = ticks_recorded`

Required marker:

`scheduler_counts_valid = True`

## 38. Current M15 Artifact Layers

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

The current M15 chain maps the complete processor behavior into deterministic hardware-facing representation.

The resonant phase-coherence computational core remains the source computational mechanism for the M15 mapping chain.

## 39. Generate the M15 Qualification Directory

Create:

    mkdir -p artifacts/m15/vectors_a
    mkdir -p artifacts/m15/vectors_b

Generate the standard structured output:

    python frp_prototype_v1_7_0.py --mode demo --output json > artifacts/m15/structured-output.json

Generate the self-test matrix:

    python frp_prototype_v1_7_0.py --mode self-test --output json > artifacts/m15/self-test.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json > artifacts/m15/self-test-free.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json > artifacts/m15/self-test-7-1.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json > artifacts/m15/self-test-1-7.json

## 40. Generate the Ten M15 Artifact Layers

Fixed-point interface profile:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile > artifacts/m15/fixed-point-interface-profile.json

Balanced ternary hardware encoding map:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map > artifacts/m15/balanced-ternary-hardware-encoding-map.json

Quantized reference shadow model:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model > artifacts/m15/quantized-reference-shadow-model.json

Cycle-exact reference trace:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace > artifacts/m15/cycle-exact-reference-trace.json

RTL comparison vector package:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package > artifacts/m15/rtl-comparison-vector-package.json

SystemVerilog testbench interface map:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map > artifacts/m15/systemverilog-testbench-interface-map.json

Synthesizable RTL reference core:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core > artifacts/m15/synthesizable-rtl-reference-core.json

RTL assertion correlation harness:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness > artifacts/m15/rtl-assertion-correlation-harness.json

Reference RTL equivalence report:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report > artifacts/m15/reference-rtl-equivalence-report.json

Qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > artifacts/m15/qualification-closure-manifest.json

## 41. Expected M15 Schemas

| Artifact | Required schema |
|---|---|
| fixed-point interface profile | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| balanced ternary hardware encoding map | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| quantized reference shadow model | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| cycle-exact reference trace | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| RTL comparison vector package | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| SystemVerilog testbench interface map | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| synthesizable RTL reference core | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| RTL assertion correlation harness | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| reference RTL equivalence report | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| qualification closure manifest | `frp.m15.qualification_closure_manifest.v1.7.0` |

Every artifact must report:

`version = 1.7.0`

and:

`milestone = M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

## 42. Fixed-Point Interface Reproduction

Current hardware-facing numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma offset | `GAMMA_S32` |

Current trigonometric profile:

`4096-entry full-cycle lookup table`

Required exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The fixed-point mapping covers the resonant phase domain together with the balanced ternary state domain.

## 43. Balanced Ternary Hardware Encoding

Current two-bit encoding:

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

Required interface values:

`request_lanes = 4`

`cell_id_width = 4`

Required invariant:

`reserved_state_events = 0`

The encoding represents the balanced ternary state domain inside the complete resonant processor computation.

## 44. Quantized Hardware Shadow Reproduction

Generate:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model > quantized-reference-shadow-model.json

The stateful quantized shadow preserves processor domains including:

- ternary state;
- scheduler state;
- pending neutral routes;
- phase;
- frequency;
- gamma;
- thermal state;
- coherence;
- stability;
- event counters.

Required summary conditions:

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

## 45. Cycle-Exact Reference Trace

Generate:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace > cycle-exact-reference-trace.json

Current default trace length:

`64`

Required trace conditions:

- every row has zero actual direct events;
- every row has zero reserved-state events;
- each row contains gamma-noise target data for all 16 cells.

The cycle-exact trace is the integer reference path between:

`stateful quantized processor execution`

and:

`deterministic RTL comparison`

## 46. Deterministic RTL Vector Package

Generate package A:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_a > artifacts/m15/vector-package-a.json

Generate package B independently:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_b > artifacts/m15/vector-package-b.json

Expected files in each vector directory:

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

Expected file count:

`10`

## 47. Deterministic Vector Repeat

Compare:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required result:

`byte-identical equality`

Every corresponding generated file must be byte-identical.

Acceptance requires byte-identical equality.

## 48. Vector SHA-256 Integrity

Each generated vector directory contains:

`frp_m15_sha256_manifest.json`

The manifest contains SHA-256 digests for the nine non-manifest vector files.

A complete integrity check must:

1. load the manifest;
2. locate every named vector file;
3. calculate its SHA-256 digest;
4. compare it with the recorded digest;
5. require exact equality.

The two independently generated vector directories must also be byte-identical.

## 49. SystemVerilog Interface Mapping

Generate:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map > systemverilog-testbench-interface-map.json

Current default interface parameters:

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

This preserves deterministic externalization of gamma-noise targets.

## 50. Synthesizable RTL Reference-Core Contract

Generate:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core > synthesizable-rtl-reference-core.json

The current export defines:

`26`

exact tick-execution stages.

Required kernel conditions include:

`actual_direct_events = 0`

`tick_separated_neutral_routing = True`

Supported scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

The RTL mapping remains a representation of the full processor execution semantics.

## 51. RTL Assertion Correlation

Generate:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness > rtl-assertion-correlation-harness.json

Current assertion count:

`13`

Current exact comparison rule:

`actual integer field == expected integer field`

The assertion layer connects RTL-facing execution to deterministic reference vectors.

## 52. Floating Reference to Quantized Shadow Equivalence

Generate:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report > reference-rtl-equivalence-report.json

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

These thresholds correlate the floating semantic reference with the quantized hardware shadow.

## 53. Exact Quantized Shadow Replay

The same equivalence report validates exact deterministic replay.

Required exact values:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

This is a stricter boundary than floating-to-quantized numeric correlation.

## 54. Qualification Closure

Generate:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > qualification-closure-manifest.json

Required result:

`status = PASS`

All closure checks must be:

`True`

Current artifact-layer count:

`10`

The qualification closure manifest is the current M15 qualification endpoint.

## 55. M15 Benchmark Matrix

Generate:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix > artifacts/m15/benchmark-matrix.json

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

This matrix represents the M15 implementation-mapping chain.

The Comparative Architecture Benchmark Suite provides its own supporting comparison contour.

## 56. Scaling Reproduction

Generate 8-cell execution:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json > artifacts/m15/scaling-8.json

Generate 16-cell execution:

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json > artifacts/m15/scaling-16.json

Generate 32-cell execution:

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json > artifacts/m15/scaling-32.json

Expected structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

## 57. Scaling Invariants

Every scaling output must preserve:

- balanced ternary state-domain validity;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
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
- packed ternary state width.

A complete scaling analysis should inspect these coupled changes.

## 58. Reproducibility Acceptance Criteria

The current FRP v1.7.0 M15 layer is reproducible when:

- the source revision is recorded;
- the working-tree state is recorded;
- the Python version is recorded;
- dependency versions are recorded;
- the executable compiles;
- deterministic initialization is preserved;
- the default structured run completes;
- an independent structured repeat is byte-identical;
- the Kuramoto-Sakaguchi phase path executes;
- phase evolution remains deterministic;
- global phase order remains available;
- multiscale coherence remains available;
- delay dynamics remain stateful;
- local thermal behavior remains coupled;
- local gamma drift remains deterministic;
- nonlinear coherence compression remains active;
- dynamic stability remains positive in the validated default profile;
- phase-derived ternary targets remain connected to the evolving phase field;
- balanced ternary state-domain validity remains true;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- all four self-test profiles report `41/41 PASS`;
- all ten M15 artifact layers are generated;
- every M15 artifact reports the expected schema;
- the quantized hardware shadow preserves the kernel invariants;
- the cycle-exact trace contains 64 rows;
- independently generated vector directories are byte-identical;
- SHA-256 vector integrity passes;
- floating-to-quantized correlation stays within contract;
- exact quantized replay reports full equality;
- the qualification closure manifest reports `PASS`.

## 59. Minimal Current Reproduction Sequence

Record source state:

    git rev-parse HEAD
    git status --short
    python --version
    python -m pip freeze

Compile:

    python -m py_compile frp_prototype_v1_7_0.py

Run the current processor:

    python frp_prototype_v1_7_0.py --mode demo --output json > demo-a.json

Repeat independently:

    python frp_prototype_v1_7_0.py --mode demo --output json > demo-b.json

Compare:

    cmp demo-a.json demo-b.json

Run the full scheduler self-test matrix:

    python frp_prototype_v1_7_0.py --mode self-test --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Generate qualification closure:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Required results:

`Python compilation PASS`

`structured repeat byte-identical`

`all self-tests 41/41 PASS`

`qualification closure PASS`

## 60. Complete M15 Reproduction Sequence

Create the artifact directories:

    mkdir -p artifacts/m15/vectors_a
    mkdir -p artifacts/m15/vectors_b

Generate structured output and self-tests:

    python frp_prototype_v1_7_0.py --mode demo --output json > artifacts/m15/structured-output.json

    python frp_prototype_v1_7_0.py --mode self-test --output json > artifacts/m15/self-test.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json > artifacts/m15/self-test-free.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json > artifacts/m15/self-test-7-1.json

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json > artifacts/m15/self-test-1-7.json

Generate all ten M15 exports:

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

Generate benchmark matrix:

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

`byte-identical equality`

## 61. Published FRP v1.7.0 Validation Evidence

Published release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated release commit:

`5fd9a4f`

Validated workflow runs recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Published result:

`PASS`

Published M15 self-test result:

`41/41 PASS`

These values are release-specific validation evidence.

The validated release commit remains recorded exactly as `5fd9a4f`, while later documentation and maintenance commits retain their own commit identities.

## 62. Historical Release Preservation

Historical executable references remain bound to their own release layers.

Examples:

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

Historical workflows retain their release-specific executable bindings.

Historical schemas retain their release-specific schema identities.

Historical test reports remain release-specific records.

## 63. Supporting Comparative Architecture Reproduction

The Comparative Architecture Benchmark Suite adds a supporting validation contour.

Directory:

`benchmarks/architecture_comparison/`

Compared architecture references:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The FRP reference remains a resonant phase-coherence architecture with balanced ternary state retention.

## 64. Comparative Architecture Self-Test

Enter:

    cd benchmarks/architecture_comparison

Run:

    python run_architecture_comparison.py --self-test --output text

The comparison suite runs alongside the primary M15 qualification path as a supporting validation contour.

## 65. Canonical Comparative Architecture Run

From:

`benchmarks/architecture_comparison/`

run:

    python run_architecture_comparison.py --workload-profile profiles/workload_profile_v1.json --cost-profile profiles/normalized_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write results/reference_comparison_seed_76.json --output text

Generate an independent repeat:

    mkdir -p .qualification

    python run_architecture_comparison.py --workload-profile profiles/workload_profile_v1.json --cost-profile profiles/normalized_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write .qualification/reference_comparison_seed_76_repeat.json --output text

Compare:

    cmp results/reference_comparison_seed_76.json .qualification/reference_comparison_seed_76_repeat.json

Required result:

`byte-identical`

## 66. Comparative Qualification Policy

Current qualification policy:

`integrity_only_no_winner_assertions`

Required winner assertions:

`[]`

The comparison result remains machine-readable data.

Reproducibility verifies deterministic comparison integrity under the recorded qualification policy.

## 67. Supporting Hardware-Sensitivity Reproduction

From:

`benchmarks/architecture_comparison/`

validate the profile:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --output text

Run the profile validator self-test:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output text

Run the hardware-sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output json

Generate the canonical sensitivity result:

    python run_hardware_sensitivity_comparison.py --workload-profile profiles/workload_profile_v1.json --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write results/reference_comparison_seed_76_hardware_sensitivity_v1.json --output text

Generate an independent repeat:

    python run_hardware_sensitivity_comparison.py --workload-profile profiles/workload_profile_v1.json --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json --output text

Compare:

    cmp results/reference_comparison_seed_76_hardware_sensitivity_v1.json .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json

Required result:

`byte-identical`

## 68. Failure Diagnosis

When a reproduction fails, first record:

    git rev-parse HEAD
    git status --short
    python --version
    python -m pip freeze

Then identify which boundary failed.

### Compile failure

Check:

- Python version;
- source integrity;
- incomplete file replacement;
- merge markers.

### Structured-output mismatch

Check:

- seed;
- scheduler;
- cell count;
- steps;
- command-line parameters;
- source revision.

### Phase or coherence mismatch

Check:

- gamma;
- fractal alpha;
- nominal coupling;
- delay alpha;
- scheduler state;
- thermal parameters;
- update order.

### Ternary-state mismatch

Check:

- phase-derived target mapping;
- transition fraction;
- pending neutral routes;
- scheduler behavior;
- active neutral routing.

### M15 quantized mismatch

Check:

- fixed-point formats;
- rounding behavior;
- phase wrapping;
- trigonometric lookup;
- quantized hierarchy weights;
- gamma stimulus.

### Vector mismatch

Check:

- source revision;
- output directory contents;
- deterministic seed;
- generator changes;
- manifest digests.

Preserve the recorded thresholds during regression diagnosis.

## 69. Reproducibility Record Template

A reproducibility record should preserve:

### Source

`commit:`

`working tree:`

### Environment

`operating system:`

`Python version:`

`dependency versions:`

### Processor configuration

`cells:`

`steps:`

`seed:`

`scheduler:`

`transition fraction:`

`gamma:`

`fractal alpha:`

`thermal beta:`

`ambient heat:`

`thermal time constant:`

`thermal limits:`

`nominal coupling:`

`delay alpha:`

`thermal diffusion gain:`

### Commands

`exact commands executed:`

### Dynamic result

`structured-output schema:`

`trace digest:`

`cell-trace digest:`

`actual_direct_events:`

`C_minus_P_min:`

`phase-coherence markers:`

### Self-test result

`status:`

`check count:`

### M15 result

`artifact schemas:`

`vector repeat:`

`equivalence result:`

`qualification closure:`

## 70. Repository Alignment Rule

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

Files describing FRP computation preserve the complete computational subject where relevant:

`Kuramoto-Sakaguchi resonant phase dynamics`

↓

`phase evolution`

↓

`resonance selection`

↓

`phase coherence`

↓

`delay and thermal feedback`

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

## 71. Complete Current Technical Chain

The current reproducible technical chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`deterministic phase and frequency initialization`

↓

`dyadic hierarchical ultrametric topology`

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

`mandatory active-neutral route`

↓

`retained coherent ternary state`

↓

`structured machine-readable telemetry`

↓

`independent byte-identical execution repeat`

↓

`fixed-point implementation profile`

↓

`balanced ternary hardware encoding`

↓

`stateful quantized hardware shadow`

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

## 72. Current Status

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

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current published validation result:

`PASS`

Current validated self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

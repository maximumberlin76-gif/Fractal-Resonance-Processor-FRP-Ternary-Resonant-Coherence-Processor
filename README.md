# Fractal Resonance Processor (FRP)

<p align="center">
  <a href="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml"><img src="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml/badge.svg" alt="FRP Self Test"></a>
  <a href="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-structured-output.yml"><img src="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-structured-output.yml/badge.svg" alt="FRP Structured Output"></a>
  <a href="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml"><img src="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml/badge.svg" alt="FRP Benchmark Smoke Test"></a>
  <a href="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m16-rtl-artifact-boundary.yml"><img src="https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m16-rtl-artifact-boundary.yml/badge.svg" alt="FRP M16 RTL Artifact Boundary"></a>
  <img src="https://img.shields.io/badge/license-Apache--2.0-blue" alt="License: Apache-2.0">
  <img src="https://img.shields.io/badge/python-3.11%2B-blue" alt="Python 3.11+">
  <img src="https://img.shields.io/badge/version-v1.8.0-purple" alt="FRP v1.8.0">
  <img src="https://img.shields.io/badge/workflows-latest%20PASS-brightgreen" alt="Latest workflows PASS">
  <img src="https://img.shields.io/badge/M15-41%2F41%20PASS-brightgreen" alt="M15 41/41 PASS">
  <img src="https://img.shields.io/badge/M16-artifact%20boundary%20PASS-brightgreen" alt="M16 artifact boundary PASS">
  <img src="https://img.shields.io/badge/RTL-artifacts%20present-brightgreen" alt="RTL artifacts present">
  <img src="https://img.shields.io/badge/simulator-external%20pending-yellow" alt="External simulator pending">
  <img src="https://img.shields.io/badge/release-v1.8.0%20M16-blue" alt="Release v1.8.0 M16">
  <a href="https://doi.org/10.5281/zenodo.21183966"><img src="https://img.shields.io/badge/DOI-10.5281%2Fzenodo.21183966-blue" alt="DOI"></a>
</p>

**Ternary Resonant Coherence Processor — Structured Output Prototype**

**(Ternary Architecture)**

Fractal Resonance Processor (FRP) is a **Ternary Resonant Coherence Processor** reference architecture.

FRP combines two inseparable computational layers:

- resonant phase-coherence dynamics based on the **Kuramoto-Sakaguchi model**;
- the balanced ternary domain `{-1, 0, 1}` for state, target, transition, and retained result.

Each processor cell carries an evolving phase and frequency state.

Computation develops through:

- Kuramoto-Sakaguchi resonant phase interaction;
- asymmetric Sakaguchi phase lag;
- hierarchical fractal coupling;
- phase velocity and phase evolution;
- Kuramoto order parameter `R`;
- multiscale phase coherence;
- stateful delay dynamics;
- local thermal-phase interaction;
- local correlated gamma drift;
- nonlinear coherence compression;
- dynamic stability through `C(t) - P(t)`;
- phase-derived ternary target formation;
- distributed ternary commit;
- mandatory tick-separated routing through the active neutral state `0`;
- retained coherent ternary state.

The balanced ternary layer does not replace the resonant phase-coherence dynamics.

The two layers perform different computational roles:

- the Kuramoto-Sakaguchi and hierarchical resonant layer evolves the computation;
- the balanced ternary domain retains state, target, transition, and result;
- the active neutral state `0` provides the mandatory intermediate state for opposite-polarity transitions.

## Current Architecture Layer

| Field | Current value |
|---|---|
| Version | `FRP v1.7.0` |
| Milestone | `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package` |
| Main executable | `frp_prototype_v1_7_0.py` |
| Validation status | `PASS` |
| M15 self-test | `41 / 41 PASS` |
| Next planned layer | `FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package` |

FRP v1.7.0 extends the published M14 floating semantic reference into a deterministic fixed-point hardware-interface domain.

The current M15 layer provides:

- a deterministic fixed-point interface profile;
- canonical balanced ternary hardware encoding;
- a stateful quantized hardware shadow;
- cycle-exact integer reference traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

The current implementation chain is:

`M14 floating semantic reference → M15 quantized hardware shadow → cycle-exact integer golden trace → deterministic RTL comparison vectors → SystemVerilog correlation contract → RTL equivalence and exact replay → qualification closure`

Current M15 qualification evidence:

- `41 / 41 PASS` self-test assertions;
- `10 / 10` deterministic vector files byte-identical after regeneration;
- `5 / 5` required semantic correlation matches equal to `1.0`;
- `6 / 6` exact deterministic replay matches equal to `1.0`;
- zero actual direct events;
- zero reserved-state events;
- zero queue-overflow events;
- exact fixed-point topology closure;
- exact fixed-point thermal closure.

## FRP v1.8.0 — M16 RTL Core Realization Layer

FRP v1.8.0 M16 introduces the first concrete SystemVerilog RTL realization boundary for the Ternary Fractal Resonant Coherence Processor.

The M16 RTL layer preserves the M15-qualified retained-state execution contract and exposes the processor boundary as explicit RTL artifacts under:

`rtl/m16/`

The M16 RTL layer does not redefine the FRP processor model.

It realizes the already-qualified M15 execution semantics in RTL module form.

Primary M16 execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Primary preserved invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

M16 RTL documentation:

| Path | Purpose |
|---|---|
| `rtl/m16/README.md` | RTL layer overview |
| `rtl/m16/ARTIFACTS.md` | RTL artifact manifest |
| `rtl/m16/SIMULATION.md` | simulator execution instructions |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | simulation transcript template |
| `rtl/m16/CLOSURE.md` | RTL closure report |

M16 RTL source artifacts:

| Path | Purpose |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | constants, encodings, helper functions |
| `rtl/m16/frp_m16_scheduler.sv` | scheduler-state realization |
| `rtl/m16/frp_m16_request_lanes.sv` | request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | pending-route register layer |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | transition-capacity enforcement |
| `rtl/m16/frp_m16_state_update.sv` | retained-state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated RTL core |
| `rtl/m16/frp_m16_assertions.sv` | assertion binding layer |
| `rtl/m16/frp_m16_tb.sv` | deterministic RTL smoke testbench |

Current M16 status:

`RTL artifact boundary complete`

Current final simulator qualification status:

`pending external simulator execution`

## Quick Start

Recommended CI-aligned Python version:

`Python 3.12`

Install the repository dependency:

`python -m pip install -r requirements.txt`

Repository external dependency:

`numpy>=1.26.0`

NumPy supports the historical FRP v0.9.3 and v0.9.4 executable layers.

The current FRP v1.7.0 executable and Comparative Architecture Benchmark Suite use the Python standard library and repository-local modules.

Run the default processor execution:

`python frp_prototype_v1_7_0.py`

Run the explicit demo mode:

`python frp_prototype_v1_7_0.py --mode demo`

Run structured JSON output:

`python frp_prototype_v1_7_0.py --mode demo --output json`

Run structured JSON output with full trace data:

`python frp_prototype_v1_7_0.py --mode demo --output json --include-trace`

Run the current M15 self-test:

`python frp_prototype_v1_7_0.py --mode self-test --output json`

Run the explicit `free` temporal execution mode:

`python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json`

Run the explicit `7/1` temporal execution mode:

`python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json`

Run the explicit `1/7` temporal execution mode:

`python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json`

Generate the current M15 benchmark matrix:

`python frp_prototype_v1_7_0.py --mode benchmark`

Detailed execution references:

- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `docs/output_schema.md`.

## Processor Architecture

### Computational State and Tick Order

FRP evolves a distributed processor state across discrete ticks.

Each cell maintains:

- balanced ternary state `state_i ∈ {-1, 0, 1}`;
- phase `phase_i`;
- base frequency `base_frequency_i`;
- frequency target `frequency_target_i`;
- current frequency `frequency_current_i`;
- frequency lag `frequency_lag_i`;
- switching activity `switch_activity_i`;
- generated power `generated_power_i`;
- local heat `heat_i`;
- thermal dissipation `thermal_dissipation_i`;
- thermal diffusion `thermal_diffusion_i`;
- thermal overload `thermal_overload_i`;
- correlated gamma-noise state `gamma_noise_state_i`;
- gamma-noise target `gamma_noise_target_i`;
- effective local Sakaguchi phase shift `gamma_effective_i`;
- gamma drift `gamma_drift_i`;
- thermal coupling factor `thermal_node_factor_i`;
- phase-coupling contribution;
- pending neutral-route state.

For each tick, the processor executes the following ordered computational path:

1. determine the temporal execution state;
2. process pending neutral routes;
3. process explicit transition requests;
4. derive phase-based ternary targets;
5. apply the distributed transition-capacity boundary;
6. update switching load;
7. update state-dependent frequency targets and delay dynamics;
8. update distributed local thermal fields;
9. update local correlated gamma drift;
10. update thermal coupling factors;
11. evaluate the resonant phase-coupling field;
12. update phase velocity and phase state;
13. evaluate raw phase coherence;
14. evaluate multiscale phase coherence;
15. evaluate nonlinear coherence compression;
16. calculate `C(t)`, `P(t)`, and `C_minus_P`;
17. retain the resulting ternary processor state and telemetry.

The coupled processor path is therefore:

`ternary state → frequency target → delayed frequency response → local dynamic power → distributed thermal field → local gamma drift → thermally modified Kuramoto-Sakaguchi coupling → phase velocity → phase evolution → multiscale phase coherence → nonlinear coherence compression → C(t) - P(t) → phase-derived ternary target → retained ternary state`

### Balanced Ternary Computational Kernel

The processor state domain is:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | active neutral balancing / damping / transition / stabilization state |
| `1` | positive / excitatory / phase-supporting / constructive potential |

The neutral state `0` is an active processor state.

It provides:

- logical neutrality;
- phase damping;
- transition buffering;
- conflict neutralization;
- polarity bridging;
- switching-load distribution;
- scheduling control;
- stabilization.

The phase-derived ternary target is determined from:

`x_i = sin(phase_i)`

with:

`target_i = 1`, when `x_i > 0.33`

`target_i = -1`, when `x_i < -0.33`

`target_i = 0`, otherwise.

Opposite-polarity transitions cannot execute directly.

Validated routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

The transition is tick-separated.

For an opposite-polarity request:

`state_i × target_i = -1`

the current tick performs:

`state_i → 0`

and stores:

`pending_route_i = target_i`

The retained target is applied only on a subsequent eligible tick.

Validated invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

### Balanced Ternary Hardware Encoding

The canonical two-bit hardware encoding is:

| Ternary state | Two-bit encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The valid processor state domain excludes:

`2'b10`

Validated invariant:

`reserved_state_events = 0`

### Temporal Execution Architecture

FRP preserves three explicit processor execution modes:

`free`

`7/1`

`1/7`

These modes are execution semantics of the processor.

They are preserved across:

- the floating semantic reference;
- the stateful quantized hardware shadow;
- cycle-exact vector generation;
- scheduler-specific qualification;
- SystemVerilog interface mapping;
- the synthesizable RTL reference core;
- qualification closure.

The scheduler-state relations are:

For `free`:

`scheduler_state(tick) = free`

For `7/1`:

`scheduler_state(tick) = commit`, when `(tick + 1) mod 8 = 0`

`scheduler_state(tick) = balance`, otherwise.

For `1/7`:

`scheduler_state(tick) = excite`, when `tick mod 8 = 0`

`scheduler_state(tick) = neutralize`, otherwise.

Validated profiles:

`free: 16 ticks → free = 16`

`7/1: 16 ticks → balance = 14, commit = 2`

`7/1: 64 ticks → balance = 56, commit = 8`

`1/7: 16 ticks → excite = 2, neutralize = 14`

Validated scheduler-count relation:

`sum(scheduler_counts) = ticks_recorded`

The scheduler also contributes a phase-velocity push:

`push = 0.010`, for `commit`

`push = 0.006`, for `excite`

`push = 0.003`, otherwise.

### Transition Capacity and Request-Lane Interface

The distributed transition boundary is defined by:

`transition_fraction = 0.25`

The maximum number of state changes per tick is:

`max_changes = max(1, round(cells × transition_fraction))`

The hardware-facing request-lane relation is:

`REQUEST_LANES = max_changes`

Validated configurations:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Request lanes are processed in ascending lane order.

The per-tick switching load is:

`switch_load = current_switch_changes / cells`

Validated relation:

`switch_load_peak <= transition_fraction`

Current default boundary:

`switch_load_peak <= 0.25`

### Kuramoto-Sakaguchi Resonant Phase Model

The resonant dynamical foundation of FRP is the **Kuramoto-Sakaguchi phase-coupling model**.

Each cell carries an evolving phase:

`phase_i`

and an evolving internal frequency:

`frequency_current_i`

The nominal Sakaguchi phase shift is:

`gamma_nominal = 0.30 × pi`

The nominal coupling strength is:

`coupling_nominal = 0.28`

For each pair of distinct cells `i` and `j`, the phase interaction is based on:

`sin(phase_j - phase_i - gamma_effective_i)`

The effective pair coupling is:

`K_eff(i,j) = coupling_nominal × W_ij × thermal_pair_factor(i,j)`

The dense reference coupling field is:

`coupling_dense_i = sum_j(K_eff(i,j) × sin(phase_j - phase_i - gamma_effective_i))`

where:

`j != i`

The complete phase velocity is:

`phase_velocity_i = 0.060 × frequency_current_i + scheduler_push + coupling_field_i`

The phase update is:

`phase_i_next = (phase_i + phase_velocity_i) mod 2pi`

The raw global Kuramoto order parameter is evaluated from:

`c = mean_i(cos(phase_i))`

`s = mean_i(sin(phase_i))`

`R = sqrt(c^2 + s^2)`

The processor records:

`raw_phase_coherence = R`

The Kuramoto-Sakaguchi layer is therefore part of the computational core that determines:

- phase evolution;
- resonance structure;
- phase coherence;
- dynamic stability;
- phase-derived ternary targets;
- subsequent retained ternary state.

### Dyadic Hierarchical Ultrametric Topology

The exact hierarchical topology requires:

`num_cells = 2^L`

where:

`L = hierarchy depth`

Validated scaling configurations:

`8 cells → hierarchy depth 3`

`16 cells → hierarchy depth 4`

`32 cells → hierarchy depth 5`

The hierarchy resolves from individual cells through progressively larger dyadic domains:

`individual cell → pair domain → local cluster → supercluster → global cell domain`

### Hierarchical Ultrametric Distance

For distinct cells `i` and `j`:

`hierarchical_distance(i,j) = bit_length(i XOR j)`

For the same cell:

`hierarchical_distance(i,i) = 0`

For the sixteen-cell reference domain:

`distance(0,1) = 1`

`distance(0,2) = 2`

`distance(0,3) = 2`

`distance(0,4) = 3`

`distance(0,7) = 3`

`distance(0,8) = 4`

`distance(0,15) = 4`

### Shell Population

For hierarchy distance `d`:

`shell_population(d) = 2^(d - 1)`

Validated shell populations:

`8 cells → 1, 2, 4`

`16 cells → 1, 2, 4, 8`

`32 cells → 1, 2, 4, 8, 16`

### Shell-Normalized Fractal Coupling

The raw hierarchical pair weight is:

`W_raw(i,j) = 1 / (2^(d - 1) × d^alpha)`

where:

`d = hierarchical_distance(i,j)`

and:

`i != j`

The diagonal relation is:

`W_raw(i,i) = 0`

The normalized phase-coupling weight is:

`W_ij = W_raw(i,j) / sum_j(W_raw(i,j))`

Validated coupling-topology relations:

`sum_j(W_ij) = 1`

`W_ij = W_ji`

`W_ii = 0`

Current hierarchical scaling exponent:

`fractal_alpha = 0.70`

Each hierarchical shell contains:

`2^(d - 1)`

cells.

Because the raw pair weight contains the shell-population factor:

`2^(d - 1)`

the aggregate influence of shell `d` is proportional to:

`1 / d^alpha`

The aggregate shell influence therefore decreases with hierarchical distance:

`nearest shell → second shell → third shell → highest shell`

Validated marker:

`shell_influence_monotonic = True`

### Phase-Coupling and Thermal-Diffusion Topology Separation

FRP preserves two independent hierarchical interaction paths.

Phase-coupling topology:

`W_ij`

Thermal-diffusion topology:

`T_ij`

The phase-coupling topology controls:

- Kuramoto-Sakaguchi phase interaction;
- hierarchical phase-coherence propagation;
- local coupling dominance;
- cross-cluster phase influence.

The thermal-diffusion topology controls:

- local heat propagation;
- inter-cell thermal diffusion;
- cross-cluster thermal leakage;
- hotspot containment.

The architecture does not require:

`W_ij = T_ij`

### Thermal-Diffusion Topology

Current thermal hierarchical scaling exponent:

`thermal_beta = 1.20`

The raw thermal pair relation is:

`T_raw(i,j) = 1 / (2^(d - 1) × d^beta)`

where:

`d = hierarchical_distance(i,j)`

and:

`i != j`

The diagonal relation is:

`T_raw(i,i) = 0`

The normalized thermal-diffusion weight is:

`T_ij = T_raw(i,j) / sum_j(T_raw(i,j))`

Validated thermal-topology relations:

`sum_j(T_ij) = 1`

`T_ij = T_ji`

`T_ii = 0`

Validated thermal-topology markers:

`row_sum_match = True`

`symmetry_match = True`

`diagonal_zero = True`

`shell_influence_monotonic = True`

### Cluster-Local Thermal Field

FRP maintains a distributed thermal state for every cell.

Each cell carries:

`heat_i`

`generated_power_i`

`thermal_dissipation_i`

`thermal_diffusion_i`

`thermal_overload_i`

`heat_peak_i`

The inherited global heat telemetry is:

`heat = mean_i(heat_i)`

The global heat peak is:

`heat_peak = max_t(heat)`

The local heat peak is:

`local_heat_peak = max_i,t(heat_i)`

### Local Dynamic Power Generation

For each cell `i`:

`generated_power_i = base_power_cell + switch_power_gain × switch_activity_i + lag_power_gain × frequency_lag_i`

The local dynamic-power path is:

`local state transition → local switching activity → local frequency target displacement → local frequency lag → local dynamic power generation`

### Hierarchical Thermal Diffusion

For each cell `i`:

`thermal_diffusion_i = thermal_diffusion_gain × sum_j(T_ij × (heat_j - heat_i))`

The local heat update is:

`heat_i_next = max(ambient_heat, heat_i + generated_power_i - thermal_dissipation_i + thermal_diffusion_i)`

The thermal path is:

`local generated power → local heat accumulation → local thermal dissipation → hierarchical thermal diffusion → neighbor-domain heating → cross-cluster thermal propagation`

### Local Thermal Overload

For each cell `i`:

`thermal_overload_i = max(0, heat_i - thermal_soft_limit)`

The processor retains local thermal telemetry for:

- per-cell heat;
- per-cell thermal overload;
- per-cluster mean heat;
- per-cluster peak heat;
- active-cluster heat peak;
- inactive-cluster heat mean;
- remote-cluster heat peak;
- cross-cluster thermal propagation ratio.

### Factorized Thermal Coupling Degradation

For each cell `i`:

`thermal_node_factor_i = exp(-0.5 × thermal_coupling_gain × thermal_overload_i)`

For cells `i` and `j`:

`thermal_pair_factor(i,j) = thermal_node_factor_i × thermal_node_factor_j`

The effective pair coupling is:

`K_eff(i,j) = coupling_nominal × W_ij × thermal_pair_factor(i,j)`

Equivalent relation:

`K_eff(i,j) = coupling_nominal × W_ij × exp(-thermal_coupling_gain × (thermal_overload_i + thermal_overload_j) / 2)`

The complete pair interaction therefore couples:

- nominal Kuramoto-Sakaguchi interaction strength;
- hierarchical fractal weight `W_ij`;
- local thermal overload of cell `i`;
- local thermal overload of cell `j`;
- local effective Sakaguchi phase shift.

The interaction term is:

`K_eff(i,j) × sin(phase_j - phase_i - gamma_effective_i)`

### Local Correlated Gamma Drift

Each cell maintains:

`gamma_noise_state_i`

`gamma_noise_target_i`

`gamma_effective_i`

`gamma_drift_i`

The correlated gamma-noise state evolves as:

`gamma_noise_next_i = gamma_noise_state_i + gamma_correlation_alpha × (gamma_noise_target_i - gamma_noise_state_i)`

The effective local Sakaguchi phase shift is:

`gamma_effective_i = gamma_nominal + gamma_thermal_gain × thermal_overload_i × gamma_noise_state_i`

The local gamma drift is:

`gamma_drift_i = gamma_effective_i - gamma_nominal`

The nominal Sakaguchi phase shift remains:

`gamma_nominal = 0.30 × pi`

The local interaction phase term therefore becomes:

`sin(phase_j - phase_i - gamma_effective_i)`

rather than:

`sin(phase_j - phase_i - gamma_nominal)`

The local gamma path is:

`thermal overload → correlated gamma-noise state → local effective Sakaguchi phase shift → asymmetric local phase interaction`

### Dense Reference Interaction Path

The dense reference path evaluates every pair of distinct cells.

For each cell `i`:

`coupling_dense_i = sum_j(K_eff(i,j) × sin(phase_j - phase_i - gamma_effective_i))`

where:

`j != i`

The dense reference path preserves:

- exact pairwise hierarchical weights;
- exact pairwise thermal factors;
- exact local gamma shift;
- exact phase difference;
- complete cross-cell interaction.

Computational scaling:

`O(N^2)`

The dense path remains the reference interaction path used for correlation against the hierarchical accelerated path.

### Hierarchical Accelerated Interaction Path

The hierarchical accelerated path uses the exact dyadic topology to aggregate interaction domains.

The interaction hierarchy is:

`leaf phase states → pair-domain reduction → cluster reduction → supercluster reduction → global-domain reduction → per-cell shell lookup → hierarchical coupling accumulation`

For each cell, the interaction field is reconstructed through hierarchical shells rather than by explicitly traversing every pair.

The hierarchy preserves the same dyadic domain structure used by:

- `hierarchical_distance(i,j)`;
- `shell_population(d)`;
- `W_ij`;
- multiscale phase-coherence domains.

The computational scaling target is:

`O(N log N)`

The hierarchical path is therefore the accelerated implementation path, while the dense path remains the exact reference path.

### Dense-Hierarchical Equivalence

FRP validates the dense reference interaction path against the hierarchical accelerated interaction path.

The required topology relation is:

`topology_match = 1.000`

The equivalence conditions are:

`max_coupling_error <= equivalence_tolerance`

`max_phase_velocity_error <= equivalence_tolerance`

`max_phase_error <= equivalence_tolerance`

The equivalence path is validated across:

- the default configuration;
- `7/1`;
- `1/7`.

The architecture therefore preserves one semantic interaction model across:

`dense exact reference → hierarchical accelerated execution`

without changing the processor coupling topology.

### Multiscale Phase-Coherence Map

FRP evaluates phase coherence across the same dyadic hierarchy used by the coupling topology.

For a dyadic group `G`:

`R_G = magnitude(mean_i(exp(i × phase_i)))`

Equivalent real-component form:

`c_G = mean_i(cos(phase_i))`

`s_G = mean_i(sin(phase_i))`

`R_G = sqrt(c_G^2 + s_G^2)`

For the sixteen-cell reference configuration:

`group size 2 → group count 8`

`group size 4 → group count 4`

`group size 8 → group count 2`

`group size 16 → group count 1`

The hierarchy therefore evaluates:

`pair-domain phase coherence`

`cluster phase coherence`

`supercluster phase coherence`

`global phase coherence`

Validated multiscale telemetry:

- `pair_domain_coherence_mean`;
- `pair_domain_coherence_min`;
- `cluster_coherence_mean`;
- `cluster_coherence_min`;
- `supercluster_coherence_mean`;
- `supercluster_coherence_min`;
- `global_phase_coherence`;
- `coherence_dispersion_across_clusters`.

The global Kuramoto order parameter remains:

`R = sqrt(c^2 + s^2)`

where:

`c = mean_i(cos(phase_i))`

`s = mean_i(sin(phase_i))`

The processor records:

`raw_phase_coherence = R`

The local-to-global coherence structure is:

`cell`

→ `pair-domain phase coherence`

→ `cluster phase coherence`

→ `supercluster phase coherence`

→ `global phase coherence`

The architecture is therefore:

`locally coherent`

→ `hierarchically coupled`

→ `globally adaptive`

### State-Dependent Delay Dynamics

FRP maintains a delayed internal frequency response for every cell.

Each cell carries:

`base_frequency_i`

`frequency_target_i`

`frequency_current_i`

`frequency_lag_i`

The frequency target is:

`frequency_target_i = base_frequency_i + state_frequency_gain × abs(state_i) + switching_frequency_gain × switch_activity_i`

The internal frequency response is:

`frequency_next_i = frequency_current_i + delay_alpha × (frequency_target_i - frequency_current_i)`

The remaining frequency lag is:

`frequency_lag_i = abs(frequency_target_i - frequency_current_i)`

The delay path is:

`retained ternary state`

→ `state-dependent frequency target`

→ `switching-dependent frequency target displacement`

→ `partial internal frequency response`

→ `residual frequency lag`

→ `subsequent tick inheritance`

→ `progressive frequency convergence`

The processor therefore does not force the internal frequency state to reach its target instantaneously.

The lagged frequency state contributes directly to:

- local dynamic power generation;
- thermal accumulation;
- subsequent phase velocity;
- future phase evolution.

### Global Thermal Saturation Relation

The inherited global thermal telemetry is:

`heat = mean_i(heat_i)`

The global generated power is:

`generated_power = mean_i(generated_power_i)`

The global thermal dissipation relation is:

`thermal_dissipation = (heat - ambient_heat) / thermal_time_constant`

The global thermal overload is:

`thermal_overload = max(0, heat - thermal_soft_limit)`

The global heat peak is:

`heat_peak = max_t(heat)`

The local heat peak is:

`local_heat_peak = max_i,t(heat_i)`

The global thermal relation preserves the aggregate view of the distributed local thermal field.

### Nonlinear Coherence Compression

FRP couples thermal overload and reduced stability margin to nonlinear coherence compression.

The margin pressure is:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

The nonlinear compression relation is:

`coherence_compression = exp(-(thermal_compression_gain × thermal_overload^2 + margin_compression_gain × margin_pressure^2))`

The effective coherence is:

`effective_coherence = raw_phase_coherence × coherence_compression`

The compression path is:

`raw phase coherence`

→ `thermal overload`

→ `reduced stability margin`

→ `nonlinear compression pressure`

→ `exponential coherence compression`

→ `effective coherence`

The nonlinear compression layer therefore couples:

- current phase coherence;
- accumulated thermal pressure;
- inherited stability margin;
- subsequent operational coherence.

### Operational Coherence C(t)

The processor operational coherence is derived from the effective coherence field.

The architecture preserves:

`C(t) > P(t)`

The operational coherence term is:

`C(t) = effective_coherence`

where:

`effective_coherence = raw_phase_coherence × coherence_compression`

The complete coherence relation is therefore:

`C(t) = R × exp(-(thermal_compression_gain × thermal_overload^2 + margin_compression_gain × margin_pressure^2))`

with:

`R = raw_phase_coherence`

and:

`margin_pressure = max(0, stability_soft_margin - previous_C_minus_P)`

### Destabilizing Load P(t)

The destabilizing load is:

`P(t) = heat + switch_load`

where:

`heat = mean_i(heat_i)`

and:

`switch_load = current_switch_changes / cells`

The destabilizing-load term therefore combines:

- accumulated thermal pressure;
- current distributed switching pressure.

### Dynamic Stability Margin

The dynamic stability margin is:

`C_minus_P = C(t) - P(t)`

The processor stability condition is:

`C(t) > P(t)`

Equivalent relation:

`C_minus_P > 0`

The processor records:

- `C(t)`;
- `P(t)`;
- `C_minus_P`;
- `C_minus_P_min`;
- `C_minus_P_final`.

The complete stability path is:

`Kuramoto-Sakaguchi phase evolution`

→ `raw phase coherence R`

→ `multiscale coherence evaluation`

→ `thermal and stability compression pressure`

→ `effective coherence C(t)`

→ `heat + switching load P(t)`

→ `C_minus_P`

→ `phase-derived ternary target`

→ `distributed retained-state execution`

### Hardware-Facing Numeric Profile

FRP v1.7.0 maps the floating semantic architecture into deterministic finite-word hardware-facing representations.

The primary numeric domains are:

`S32Q16`

`S32Q30`

`PHASE_U32`

`GAMMA_S32`

General dynamic scalar type:

`S32Q16`

Normalized coefficient type:

`S32Q30`

Binary phase type:

`PHASE_U32`

Sakaguchi gamma phase-offset type:

`GAMMA_S32`

The hardware-facing numeric layer preserves:

- balanced ternary state semantics;
- phase evolution;
- hierarchical coupling;
- thermal diffusion;
- local gamma drift;
- multiscale coherence;
- dynamic stability;
- pending neutral routes;
- temporal execution modes.

### Deterministic Quantization

The quantization rule is:

`round-to-nearest with half cases away from zero`

For a nonnegative scaled value `x`:

`quantized = floor(x + 0.5)`

For a negative scaled value `x`:

`quantized = ceil(x - 0.5)`

The fixed-point layer validates:

- positive half-case rounding;
- negative half-case rounding;
- signed saturation;
- fixed-point multiplication;
- phase wrapping.

The finite-word mapping is deterministic.

Identical input state, parameters, and deterministic stimulus therefore produce identical quantized output state.

### Exact Q30 Hierarchical Closure

The phase-coupling topology is quantized into Q30 coefficients.

The exact aggregate phase-topology relation is:

`sum_d(shell_population(d) × W_level_q[d]) = 2^30`

The thermal-diffusion topology is independently quantized into Q30 coefficients.

The exact aggregate thermal-topology relation is:

`sum_d(shell_population(d) × T_level_q[d]) = 2^30`

Validated invariants:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The quantized hierarchical topology therefore preserves exact normalized closure in the integer hardware domain.

### Deterministic Trigonometric Profile

The finite-word resonant phase model uses a deterministic full-cycle trigonometric lookup profile.

Validated lookup-table size:

`4096 entries`

Validated lookup address width:

`12 bits`

The phase word is:

`PHASE_U32`

The lookup index is:

`lut_index = phase_word >> 20`

The sine table is defined by:

`sin_lut[k] = quantize_q30(sin(2 pi k / 4096))`

The cosine table is derived from the quarter-cycle offset:

`cos_lut[k] = sin_lut[(k + 1024) mod 4096]`

The lookup path is:

`PHASE_U32`

→ `12-bit LUT index`

→ `Q30 sine / cosine value`

→ `quantized Kuramoto-Sakaguchi interaction`

The deterministic trigonometric profile preserves the phase-coupling path without runtime floating-point trigonometric evaluation.

### Quantized Kuramoto-Sakaguchi Interaction

The floating interaction term:

`sin(phase_j - phase_i - gamma_effective_i)`

is mapped into the finite-word phase domain.

The quantized phase-difference path is:

`phase_j_q - phase_i_q - gamma_effective_i_q`

followed by:

`phase wrapping`

→ `LUT index extraction`

→ `Q30 sine lookup`

→ `fixed-point pair weighting`

The quantized effective pair interaction retains:

`coupling_nominal_q`

× `W_ij_q`

× `thermal_pair_factor_q`

× `sin_lut_q`

The quantized architecture therefore preserves the same computational order as the floating semantic reference:

`hierarchical weight`

→ `thermal pair degradation`

→ `local Sakaguchi phase offset`

→ `phase interaction`

→ `coupling accumulation`

### Stateful Quantized Hardware Shadow Model

The M15 quantized hardware shadow is a stateful finite-word execution path.

The quantized state generated at tick `N` becomes the input state for tick `N + 1`.

Validated relation:

`quantized state at tick N`

→ `input state for quantized tick N+1`

The shadow model retains quantized forms of:

- balanced ternary states;
- phases;
- current frequencies;
- frequency targets;
- frequency lags;
- local heat;
- thermal overload;
- gamma-noise state;
- effective local gamma;
- pending neutral routes;
- scheduler state;
- transition counters;
- coherence telemetry;
- stability telemetry.

Cycle-exact hardware-facing vectors are generated from:

`quantized_reference_shadow_model`

The hardware shadow is therefore not a stateless conversion of floating outputs.

It is a persistent processor execution path whose quantized internal state is inherited from tick to tick.

### Cycle-Exact Integer Golden Trace

The M15 cycle-exact trace is generated from the stateful quantized hardware shadow.

The trace preserves the processor state at each tick in deterministic integer form.

For every recorded cycle, the trace contains:

- tick index;
- scheduler state;
- balanced ternary cell state;
- phase word;
- current frequency;
- frequency target;
- frequency lag;
- local heat;
- thermal overload;
- gamma-noise state;
- effective local gamma;
- pending neutral-route state;
- request-lane state;
- transition counters;
- raw phase coherence;
- multiscale coherence;
- `C(t)`;
- `P(t)`;
- `C_minus_P`.

The cycle-exact progression is:

`initial quantized state`

→ `quantized tick execution`

→ `cycle N integer state`

→ `cycle N state retained`

→ `cycle N+1 integer execution`

The trace therefore acts as the integer golden reference for downstream RTL comparison.

### Deterministic RTL Comparison Vector Package

The RTL comparison-vector package is derived directly from the cycle-exact integer golden trace.

The vector package preserves:

- input state;
- expected output state;
- scheduler state;
- request-lane ordering;
- pending-route state;
- phase state;
- frequency state;
- thermal state;
- gamma state;
- coherence state;
- stability state;
- transition counters.

The comparison path is:

`stateful quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

The vector package is deterministic.

For identical:

- processor parameters;
- seed;
- temporal execution mode;
- initial state;
- deterministic stimulus;

the generated vector files must be byte-identical.

Validated regeneration result:

`10 / 10 vector files byte-identical`

Validated package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

### SystemVerilog Testbench Interface Mapping

The SystemVerilog testbench interface maps the M15 vector package into explicit RTL comparison signals.

The interface preserves:

- balanced ternary state encoding;
- phase words;
- frequency words;
- thermal words;
- gamma words;
- scheduler state;
- request lanes;
- pending neutral routes;
- transition counters;
- coherence telemetry;
- stability telemetry.

The comparison contract is:

`vector input`

→ `RTL tick execution`

→ `observed RTL output`

→ `cycle-exact golden comparison`

The interface therefore preserves the processor execution semantics across:

`Python semantic reference`

→ `quantized hardware shadow`

→ `integer golden trace`

→ `SystemVerilog testbench`

### Synthesizable RTL Reference Core Mapping

The M15 synthesizable RTL reference core maps the processor execution contract into a hardware-oriented sequential structure.

The reference core preserves:

- canonical balanced ternary encoding;
- explicit temporal execution modes;
- deterministic request-lane ordering;
- transition-capacity limits;
- pending neutral routes;
- mandatory active-neutral routing;
- tick-separated opposite-polarity transitions;
- retained processor state.

The core relation is:

`current retained state`

→ `scheduler state`

→ `request-lane evaluation`

→ `transition-capacity enforcement`

→ `neutral-route processing`

→ `next retained state`

The reference RTL core is therefore aligned with the same ternary transition semantics used by the executable processor reference.

### RTL Assertion Correlation Harness

The assertion harness validates the processor invariants at the RTL comparison boundary.

Required assertions include:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`accepted_changes <= REQUEST_LANES`

`switch_load_peak <= transition_fraction`

`pending routes preserve requested target polarity`

`opposite-polarity transitions pass through 0`

`scheduler counts match ticks recorded`

The assertion path is:

`cycle-exact vector`

→ `RTL execution`

→ `signal observation`

→ `invariant assertion`

→ `correlation result`

The harness validates processor semantics in addition to output equality.

### Reference RTL Equivalence

The M15 equivalence layer compares the reference RTL execution contract with the quantized hardware shadow.

Required semantic correlation matches are:

`state_sequence_match = 1.000`

`scheduler_sequence_match = 1.000`

`neutral_route_sequence_match = 1.000`

`C_minus_P_sign_match = 1.000`

`boundary_order_match = 1.000`

Validated result:

`5 / 5 required semantic matches = 1.0`

The equivalence layer therefore checks:

- retained state order;
- temporal execution order;
- neutral-route order;
- dynamic stability sign;
- transition-boundary order.

### Exact Deterministic Quantized-Shadow Replay

The M15 replay layer regenerates the quantized execution from the retained deterministic state.

Required replay matches are:

`shadow_replay_state_match = 1.000`

`shadow_replay_scheduler_match = 1.000`

`shadow_replay_pending_route_match = 1.000`

`shadow_replay_counter_match = 1.000`

`shadow_replay_trace_match = 1.000`

`shadow_replay_cell_trace_match = 1.000`

Validated result:

`6 / 6 replay matches = 1.0`

The replay path is:

`retained quantized initial state`

→ `deterministic tick execution`

→ `regenerated processor trace`

→ `exact comparison with reference trace`

### M15 Qualification Closure

The qualification-closure layer combines:

- fixed-point interface qualification;
- ternary encoding qualification;
- quantized-shadow qualification;
- cycle-exact trace qualification;
- RTL vector-package qualification;
- SystemVerilog interface qualification;
- RTL reference-core mapping;
- assertion correlation;
- reference RTL equivalence;
- exact deterministic replay.

Current result:

`PASS`

The complete M15 implementation-mapping path is:

`M14 floating semantic reference`

→ `M15 deterministic fixed-point interface`

→ `stateful quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog correlation interface`

→ `synthesizable RTL reference-core mapping`

→ `RTL assertion correlation`

→ `reference RTL equivalence`

→ `exact deterministic replay`

→ `qualification closure`

### Scaling Qualification

The M15 hardware-facing architecture is qualified across three exact dyadic processor sizes:

`8 cells`

`16 cells`

`32 cells`

Validated scaling profiles:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

The scaling relations are:

`hierarchy_depth = log2(cells)`

`request_lanes = max(1, round(cells × transition_fraction))`

with:

`transition_fraction = 0.25`

The balanced ternary packed-state width is:

`packed_state_width = 2 × cells`

because each ternary state is represented by the canonical two-bit encoding.

Validated profiles:

`8 cells → hierarchy depth 3 → request lanes 2 → packed state width 16 bits`

`16 cells → hierarchy depth 4 → request lanes 4 → packed state width 32 bits`

`32 cells → hierarchy depth 5 → request lanes 8 → packed state width 64 bits`

Every validated scaling profile preserves:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`balanced_ternary_state_domain = True`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The processor therefore preserves the same computational semantics across the validated scaling set:

`balanced ternary state domain`

→ `free / 7/1 / 1/7 temporal execution`

→ `Kuramoto-Sakaguchi phase interaction`

→ `dyadic hierarchical coupling`

→ `distributed thermal field`

→ `multiscale phase coherence`

→ `dynamic stability`

→ `distributed ternary commit`

→ `mandatory active-neutral routing`

→ `retained coherent ternary state`

Validation result:

`PASS`

### M15 Architecture Artifacts

The M15 implementation package contains ten validated architecture layers:

| Artifact layer | Role |
|---|---|
| `fixed_point_interface_profile` | deterministic finite-word interface definition |
| `balanced_ternary_hardware_encoding_map` | canonical two-bit ternary encoding |
| `quantized_reference_shadow_model` | stateful finite-word processor execution |
| `cycle_exact_reference_trace` | integer golden execution trace |
| `rtl_comparison_vector_package` | deterministic RTL comparison vectors |
| `systemverilog_testbench_interface_map` | SystemVerilog comparison interface |
| `synthesizable_rtl_reference_core` | synthesizable reference-core mapping |
| `rtl_assertion_correlation_harness` | invariant and correlation contract |
| `reference_rtl_equivalence_report` | reference-side equivalence evidence |
| `qualification_closure_manifest` | M15 qualification closure |

The current architecture chain is:

`published M14 semantic reference → deterministic fixed-point interface → balanced ternary hardware encoding → stateful quantized hardware shadow → cycle-exact integer golden trace → deterministic RTL comparison vectors → SystemVerilog interface mapping → synthesizable RTL reference-core mapping → RTL assertion correlation → reference RTL equivalence → exact deterministic replay → qualification closure`

### M15 Architecture Files

M15 architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

M15 executable reference:

`frp_prototype_v1_7_0.py`

M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

M15 release evidence:

- `RELEASE_NOTES_v1_7_0.md`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `CHANGELOG.md`.

### Architecture Progression

The validated FRP architecture progression is:

`executable resonant phase-coherence reference → structured machine-readable output → benchmark export and hardware-facing signal mapping → HDL trace and testbench scaffold → RTL interface contract and assertion harness → formal verification and equivalence scaffold → FPGA synthesis and timing scaffold → production release package → silicon and heterogeneous implementation architecture → tapeout-readiness package → production integration and external handoff → implementation feedback and production iteration → thermal-delay stabilization and scaling → hierarchical physical-domain correlation → deterministic implementation mapping and qualification closure`

The current M15 layer terminates at:

`qualification closure`

The next architecture layer begins from that validated boundary.

### Next Architecture Layer

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## Structured Output and Trace

Current structured output schema:

`frp.structured_output.v1.7.0`

Current benchmark matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Supported execution modes:

- `demo`;
- `self-test`;
- `benchmark`.

Supported output modes:

- `text`;
- `json`.

Full trace data is enabled through:

`--include-trace`

The structured output layer preserves the processor execution state in machine-readable form.

The top-level execution record includes:

- schema identity;
- FRP version;
- execution mode;
- scheduler mode;
- cell count;
- step count;
- seed;
- transition fraction;
- hierarchy depth;
- final processor state;
- execution summary;
- validation result.

The trace layer records the processor state tick by tick.

Per-tick trace data includes:

- tick index;
- scheduler state;
- balanced ternary states;
- phase states;
- frequency targets;
- current frequencies;
- frequency lags;
- switching activity;
- generated power;
- local heat;
- thermal overload;
- gamma-noise state;
- effective local gamma;
- pending neutral routes;
- request-lane ordering;
- raw phase coherence;
- multiscale phase coherence;
- `C(t)`;
- `P(t)`;
- `C_minus_P`.

The retained-state trace preserves the relation:

`tick N output state → tick N+1 input state`

The current output layer therefore exposes the complete execution path:

`initial processor state`

→ `tick-by-tick state evolution`

→ `phase-coherence dynamics`

→ `thermal and gamma dynamics`

→ `ternary transition execution`

→ `retained final state`

### Execution Summary

The execution summary records:

- ticks recorded;
- scheduler counts;
- requested direct events;
- prevented direct events;
- neutral-routed events;
- actual direct events;
- reserved-state events;
- queue-overflow events;
- switch-load peak;
- heat peak;
- local heat peak;
- raw phase-coherence final value;
- global phase-coherence final value;
- `C_minus_P_min`;
- `C_minus_P_final`;
- pending-route count final;
- fixed-point topology exactness;
- fixed-point thermal exactness.

Current default validated execution records:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`switch_load_peak = 0.25`

`C_minus_P_min = 0.6142730712890625`

`C_minus_P_final = 0.88287353515625`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

### Benchmark Export

The benchmark mode generates the current M15 benchmark matrix.

Run:

`python frp_prototype_v1_7_0.py --mode benchmark`

Export the benchmark matrix directly:

`python frp_prototype_v1_7_0.py --export-benchmark-matrix`

The benchmark matrix preserves:

- schema identity;
- version identity;
- workload identity;
- architecture-row identity;
- processor configuration;
- execution result;
- qualification result.

Detailed schema definitions are maintained in:

`docs/output_schema.md`

## Validation and Qualification

Validation environment:

`GitHub Actions hardware-backed CI execution`

Current validation status:

`PASS`

Current M15 qualification evidence:

| Qualification layer | Result |
|---|---|
| M15 self-test suite | `41 / 41 PASS` |
| deterministic vector regeneration | `10 / 10 files byte-identical` |
| semantic reference-to-quantized correlation | `5 / 5 required matches = 1.0` |
| exact deterministic quantized-shadow replay | `6 / 6 replay matches = 1.0` |
| Comparative Architecture Benchmark | `PASS` |
| Hardware Sensitivity Profile Qualification | `PASS` |
| Hardware Sensitivity Comparison | `PASS` |
| M15 qualification closure | `PASS` |

Validated deterministic package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The five required semantic correlation matches are:

`state_sequence_match = 1.000`

`scheduler_sequence_match = 1.000`

`neutral_route_sequence_match = 1.000`

`C_minus_P_sign_match = 1.000`

`boundary_order_match = 1.000`

The six exact deterministic replay matches are:

`shadow_replay_state_match = 1.000`

`shadow_replay_scheduler_match = 1.000`

`shadow_replay_pending_route_match = 1.000`

`shadow_replay_counter_match = 1.000`

`shadow_replay_trace_match = 1.000`

`shadow_replay_cell_trace_match = 1.000`

Detailed validation evidence:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

## Benchmark Summary

The FRP benchmark record is cumulative.

Each benchmark layer measures a distinct architecture contour and remains part of the project evidence chain.

The benchmark history includes:

- v0.9.3 transition behavior;
- v0.9.4 text and structured JSON benchmark execution;
- v0.9.5 through v1.3.0 M3 benchmark matrices;
- v1.4.0 transition-pressure and feedback-stress evaluation;
- v1.5.0 thermal-survival and stability-boundary evaluation;
- v1.6.0 hierarchical scaling, acceleration, and hotspot containment;
- v1.7.0 M15 implementation-mapping qualification;
- Comparative Architecture Benchmark Suite;
- hardware-informed sensitivity qualification.

### FRP v0.9.3 Transition Benchmark

The historical transition benchmark uses:

| Parameter | Value |
|---|---|
| N | `8, 16, 32, 64` |
| seeds | `0..4` |
| cycle modes | `free`, `7/1`, `1/7` |
| operations | `neg`, `add`, `sub`, `compare`, `consensus` |
| steps | `128` |

Compared architectures:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

Within this historical benchmark model and workload:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Measured result:

`15.69× lower heat_peak`

Equivalent reduction:

`93.63% lower heat_peak`

The measured transition contour is:

`active neutral state 0`

→ `mandatory active-neutral routing`

→ `tick-separated neutral routing`

→ `distributed transition load`

The result belongs specifically to the historical v0.9.3 benchmark model and workload.

### FRP v0.9.4 Text and Structured JSON Benchmark

Historical commands:

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5`

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json`

Architecture labels:

- `binary_style_forced_switch`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `frp_distributed_resonant`.

Structured output schema:

`frp.structured_output.v0.9.4`

The v0.9.4 layer preserves the transition benchmark through both human-readable output and structured JSON export.

### M3 Benchmark Matrix History — FRP v0.9.5 through FRP v1.3.0

Validated schemas:

- `frp.m3.benchmark_matrix.v0.9.5`;
- `frp.m3.benchmark_matrix.v0.9.6`;
- `frp.m3.benchmark_matrix.v0.9.7`;
- `frp.m3.benchmark_matrix.v0.9.8`;
- `frp.m3.benchmark_matrix.v0.9.9`;
- `frp.m3.benchmark_matrix.v1.0.0`;
- `frp.m3.benchmark_matrix.v1.1.0`;
- `frp.m3.benchmark_matrix.v1.2.0`;
- `frp.m3.benchmark_matrix.v1.3.0`.

Validated architecture rows across this sequence:

1. `binary_style_forced_switch`;
2. `direct_ternary_commit`;
3. `distributed_neutral_ternary`;
4. `frp_distributed_resonant`.

This sequence preserves the cumulative M3 benchmark and signal-mapping history across the repository architecture progression.

### FRP v1.4.0 Benchmark Matrix

Schema:

`frp.m3.benchmark_matrix.v1.4.0`

Validated rows:

1. `binary_style_forced_switch`;
2. `direct_ternary_commit`;
3. `frp_distributed_resonant`;
4. `frp_aggressive_feedback_stress_harness`.

The v1.4.0 matrix extends the benchmark history into:

- external implementation feedback;
- transition pressure;
- aggressive feedback stress.

### FRP v1.5.0 Benchmark Matrix

Schema:

`frp.m3.benchmark_matrix.v1.5.0`

Validated rows:

1. `binary_style_forced_switch`;
2. `frp_v1_4_0_transition_pressure_layer`;
3. `frp_v1_5_0_bounded_thermal_survival`;
4. `frp_v1_5_0_thermal_stability_boundary_sweep`.

The v1.5.0 matrix extends the benchmark history into:

- stateful thermal-delay stabilization;
- bounded thermal survival;
- thermal stability-boundary qualification.

### FRP v1.6.0 Benchmark Matrix

Schema:

`frp.m3.benchmark_matrix.v1.6.0`

Validated rows:

1. `all_to_all_uniform_reference`;
2. `frp_v1_5_0_thermal_delay_stabilization`;
3. `frp_v1_6_0_dense_hierarchical_reference`;
4. `frp_v1_6_0_hierarchical_accelerated_path`;
5. `frp_v1_6_0_localized_hotspot_containment`.

The v1.6.0 matrix extends the benchmark history into:

- dyadic hierarchical topology;
- dense hierarchical reference interaction;
- accelerated hierarchical interaction;
- distributed local thermal fields;
- localized hotspot containment.

### Current FRP v1.7.0 M15 Benchmark Matrix

Run:

`python frp_prototype_v1_7_0.py --mode benchmark`

Export:

`python frp_prototype_v1_7_0.py --export-benchmark-matrix`

Schema:

`frp.m3.benchmark_matrix.v1.7.0`

Validated rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

The M15 benchmark progression is:

`M14 floating semantic reference`

→ `M15 quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog correlation contract`

→ `qualification closure`

Validation result:

`PASS`

### Comparative Architecture Benchmark Suite

Benchmark directory:

`benchmarks/architecture_comparison/`

Schema:

`frp.benchmark.architecture_comparison.v1`

The suite compares four independently executed architecture references under one deterministic semantic workload:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

The benchmark applies one common event taxonomy and one common normalized unit-event cost model.

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical unit-event profile:

`unit_event_cost_v1`

Canonical package digest:

`5a4be61ce7fd6bc680bbd8bc28bfe7cc9d2ad35adddf642cecff111fbd503d6a`

Integrity status:

`PASS`

Qualification status:

`PASS`

The FRP benchmark row includes the declared activity of the complete M15 quantized processor path:

- fixed-point arithmetic;
- deterministic trigonometric lookup;
- hierarchical phase coupling;
- distributed thermal processing;
- multiscale coherence processing;
- stateful delay dynamics;
- local gamma drift;
- active-neutral routing;
- pending-route processing;
- retained-state execution.

The benchmark therefore evaluates the declared activity cost of the full processor stack represented by the M15 quantized hardware shadow.

It does not reduce the FRP row to ternary state switching alone.

Current canonical FRP workload result:

| Metric | Value |
|---|---:|
| `semantic_completion_ratio` | `1.0` |
| `semantic_output_match` | `1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `pending_route_count_final` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |
| `global_phase_coherence_final` | `0.9999997103586793` |
| `C_minus_P_min` | `0.856201171875` |
| `C_minus_P_final` | `1.2415313720703125` |

The comparative architecture suite preserves two separate result layers:

`semantic correctness`

and:

`declared normalized activity cost`

The semantic layer verifies that the workload is completed correctly.

The activity-cost layer counts the declared architecture events generated by that execution.

### Hardware-Informed Sensitivity Qualification

Schema:

`frp.benchmark.hardware_sensitivity_comparison.v1`

Canonical result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Hardware-sensitivity profile:

`literature_anchored_cmos45_sensitivity_v1`

Validated scenarios:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

All four architectures use the same global coefficient vector within each scenario.

The sensitivity comparison therefore varies the common event-cost assumptions without assigning architecture-specific coefficients inside the same scenario.

Profile qualification status:

`PASS`

Comparison qualification status:

`PASS`

Validated ranking stability:

`ranking_stable = true`

Validated ranking sensitivity:

`ranking_sensitive = false`

The ranking remains unchanged across all three scenarios:

`binary_clock_gated_reference`

→ `direct_ternary_reference`

→ `binary_synchronous_reference`

→ `frp_v1_7_0_quantized_shadow`

The current M15 FRP row evaluates the declared activity cost of the complete quantized resonant phase-coherence execution stack.

The result is therefore a full-stack activity-cost contour.

It is not a universal energy-superiority claim.

### Dominant FRP Activity-Cost Events

The current hardware-informed sensitivity result identifies the dominant FRP event totals as:

| Event | Total |
|---|---:|
| `fixed_point_multiplies_32x32` | `518728` |
| `fixed_point_accumulates_64` | `296534` |
| `fixed_point_adds_32` | `339899` |
| `fixed_point_compares_32` | `45430` |
| `lut_reads_32` | `172221` |

The dominant implementation-cost concentration is therefore associated with:

`fixed-point arithmetic volume`

and:

`trigonometric lookup volume`

These event classes identify the primary implementation targets for the next architecture layer.

The current sensitivity result therefore supports the development path toward:

- fixed-point arithmetic reduction;
- multiplier restructuring;
- accumulation-path optimization;
- trigonometric lookup optimization;
- architecture-level reduction of repeated interaction cost.

Canonical hardware-sensitivity package digest:

`a44cf392d946e3b5c21dffbaa1d726d31da326a007e2908914f6477215261ea0`

### Benchmark Evidence Continuity

The cumulative benchmark record preserves the following distinct measurement contours:

- v0.9.3 transition `heat_peak` behavior;
- v0.9.4 text and structured JSON benchmark execution;
- v0.9.5 through v1.3.0 M3 architecture benchmark matrices;
- v1.4.0 transition-pressure and feedback-stress benchmark matrix;
- v1.5.0 thermal-survival and stability-boundary benchmark matrix;
- v1.6.0 hierarchical scaling, acceleration, and hotspot-containment benchmark matrix;
- v1.7.0 M15 implementation-mapping benchmark matrix;
- Comparative Architecture Benchmark Suite;
- hardware-informed sensitivity qualification.

These are separate evidence contours.

The historical transition benchmark does not replace the current full-stack architecture comparison.

The current full-stack architecture comparison does not erase the historical transition benchmark.

Execution-speed benchmarking is a separate future measurement contour.

No execution-speed claim is made by the current benchmark record.

Detailed benchmark interpretation:

`docs/benchmark_interpretation.md`

## Benchmark-Supported Technical Position

FRP performs evolving computation through resonant phase-coherence dynamics and retains the resulting processor state through the balanced ternary domain:

`{-1, 0, 1}`

The benchmark record supports distinct technical conclusions for distinct measurement contours.

### Historical Transition Contour

Within the validated FRP v0.9.3 benchmark model and workload:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`15.6923076923`

Measured result:

`15.69× lower heat_peak`

Equivalent reduction:

`93.63% lower heat_peak`

This result belongs specifically to the historical transition benchmark contour:

`direct forced switching`

versus:

`distributed active-neutral ternary routing`

The measured transition architecture is:

`active neutral state 0`

→ `mandatory active-neutral routing`

→ `tick-separated neutral routing`

→ `distributed transition load`

This historical result does not describe the full computational cost of the current M15 processor architecture.

### Current M15 Execution Contour

The current M15 execution preserves:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`pending_route_count_final = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

The current processor execution also preserves:

- explicit `free`, `7/1`, and `1/7` temporal execution semantics;
- mandatory tick-separated opposite-polarity routing;
- deterministic request-lane ordering;
- bounded transition capacity;
- stateful quantized execution;
- hierarchical phase coupling;
- distributed local thermal fields;
- multiscale phase coherence;
- dynamic stability telemetry.

The current validated processor path is:

`Kuramoto-Sakaguchi phase evolution`

→ `hierarchical resonant coupling`

→ `multiscale phase coherence`

→ `stateful delay dynamics`

→ `distributed thermal response`

→ `local correlated gamma drift`

→ `nonlinear coherence compression`

→ `C(t) - P(t)`

→ `phase-derived ternary target`

→ `distributed ternary commit`

→ `mandatory active-neutral routing`

→ `retained coherent ternary state`

### Current Comparative Architecture Contour

The Comparative Architecture Benchmark Suite evaluates the declared activity cost of four independently executed architecture references under one deterministic semantic workload.

The current FRP row represents the complete M15 quantized execution stack.

It includes:

- fixed-point arithmetic;
- deterministic trigonometric lookup;
- hierarchical coupling;
- distributed thermal processing;
- multiscale coherence processing;
- stateful delay dynamics;
- local gamma drift;
- active-neutral routing;
- pending-route processing;
- retained-state execution.

The current hardware-informed sensitivity qualification preserves the ranking:

`binary_clock_gated_reference`

→ `direct_ternary_reference`

→ `binary_synchronous_reference`

→ `frp_v1_7_0_quantized_shadow`

across:

- `lower_bound`;
- `nominal`;
- `upper_bound`.

Validated result:

`ranking_stable = true`

`ranking_sensitive = false`

This result is a declared full-stack activity-cost contour.

It is not a universal energy-superiority claim.

### Current Implementation-Cost Concentration

The dominant declared FRP event totals are:

`fixed_point_multiplies_32x32 = 518728`

`fixed_point_accumulates_64 = 296534`

`fixed_point_adds_32 = 339899`

`fixed_point_compares_32 = 45430`

`lut_reads_32 = 172221`

The current implementation-cost concentration is therefore associated primarily with:

`fixed-point arithmetic volume`

and:

`trigonometric lookup volume`

These event classes define the primary optimization targets for the next architecture layer.

### Current Qualification Position

The M15 implementation-mapping chain converts the processor architecture into:

`floating semantic reference`

→ `deterministic fixed-point interface`

→ `stateful quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog correlation contract`

→ `synthesizable RTL reference-core mapping`

→ `RTL assertion correlation`

→ `reference RTL equivalence`

→ `exact deterministic replay`

→ `qualification closure`

Current qualification result:

`PASS`

Validated qualification evidence:

`41 / 41 PASS`

`10 / 10 vector files byte-identical`

`5 / 5 semantic matches = 1.0`

`6 / 6 replay matches = 1.0`

The current benchmark and qualification record therefore establishes:

- a validated resonant phase-coherence computational reference;
- a balanced ternary retained-state architecture;
- deterministic finite-word hardware mapping;
- exact integer reference traces;
- deterministic RTL comparison vectors;
- full implementation-cost concentration data for the current M15 processor stack.

Execution-speed benchmarking remains a separate future measurement contour.

No execution-speed claim is made by the current repository.

## Hardware-Facing Development Path

The current hardware-facing development path preserves the processor semantics from the executable reference through deterministic implementation mapping.

The progression is:

1. executable resonant phase-coherence reference;
2. structured machine-readable output and trace;
3. benchmark export and hardware-facing signal mapping;
4. HDL trace and testbench scaffold;
5. RTL interface contract and assertion harness;
6. formal verification and equivalence scaffold;
7. FPGA synthesis and timing scaffold;
8. production release package;
9. silicon and heterogeneous implementation architecture;
10. tapeout-readiness package;
11. production integration and external implementation handoff;
12. implementation feedback and production iteration;
13. thermal-delay stabilization and scaling;
14. hierarchical physical-domain correlation;
15. deterministic fixed-point interface mapping;
16. stateful quantized hardware-shadow execution;
17. cycle-exact integer golden-trace generation;
18. deterministic RTL comparison-vector generation;
19. SystemVerilog testbench interface mapping;
20. synthesizable RTL reference-core mapping;
21. RTL assertion correlation;
22. reference RTL equivalence;
23. exact deterministic replay;
24. M15 qualification closure;
25. M16 RTL core realization and execution semantics;
26. FPGA execution correlation;
27. ASIC-oriented implementation and cost study;
28. physical validation and measurement correlation.

The current M15 hardware-facing contract preserves:

- the balanced ternary state domain `{-1, 0, 1}`;
- canonical two-bit ternary encoding;
- active neutral state `0`;
- tick-separated opposite-polarity routing;
- pending-route semantics;
- bounded transition capacity;
- deterministic request-lane ordering;
- explicit `free`, `7/1`, and `1/7` temporal execution modes;
- Kuramoto-Sakaguchi resonant phase interaction;
- asymmetric local Sakaguchi phase lag;
- dyadic hierarchical coupling;
- distributed local thermal fields;
- stateful delay dynamics;
- multiscale phase coherence;
- nonlinear coherence compression;
- `C(t)`;
- `P(t)`;
- `C_minus_P`;
- exact fixed-point topology closure;
- exact fixed-point thermal closure.

The current implementation boundary is:

`qualified M15 quantized reference and RTL comparison contract`

The next architecture boundary is:

`M16 RTL core realization and execution semantics`

### Current Hardware-Facing Documentation

Core hardware pathway:

`docs/hardware_pathway.md`

Implementation layers:

`docs/implementation_layers.md`

FPGA mapping study:

`docs/fpga_mapping_study.md`

ASIC mapping study:

`docs/asic_mapping_study.md`

Physical validation plan:

`docs/physical_validation_plan.md`

FPGA register-map draft:

`docs/fpga_register_map_draft.md`

Testbench comparison plan:

`docs/testbench_comparison_plan.md`

M15 implementation-mapping architecture:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

### Current Implementation Targets

The current full-stack activity-cost contour identifies two dominant implementation targets:

`fixed-point arithmetic volume`

and:

`trigonometric lookup volume`

Primary next-layer optimization targets include:

- multiplier restructuring;
- fixed-point arithmetic reduction;
- accumulation-path optimization;
- deterministic trigonometric lookup optimization;
- reduction of repeated hierarchical interaction cost;
- preservation of exact topology closure;
- preservation of exact thermal closure;
- preservation of ternary transition semantics;
- preservation of `free`, `7/1`, and `1/7` execution semantics.

The next architecture layer must therefore preserve the qualified processor semantics while reducing implementation cost.

Next planned layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## Project Milestones

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

Complete milestone definitions and evidence references are maintained in:

`MILESTONES.md`

## Historical Technical Archive

The detailed release-by-release technical history remains preserved in dedicated repository files rather than repeated inside this README.

The historical evidence chain is maintained through:

- `RELEASE_NOTES_v*.md`;
- `TEST_REPORT_v*.md`;
- `FRP_VALIDATION_INDEX_v*.md`;
- `CHANGELOG.md`;
- `MILESTONES.md`;
- architecture-layer documentation in `docs/`.

The complete executable progression remains preserved from:

`frp_prototype_v0_9_3_mobile.py`

through:

`frp_prototype_v1_7_0.py`

Historical release notes preserve:

- architecture changes;
- implementation-layer changes;
- interface changes;
- benchmark changes;
- validation changes;
- release-specific qualification state.

Historical test reports preserve:

- executable test results;
- benchmark results;
- scheduler qualification;
- invariant qualification;
- export qualification;
- hardware-facing qualification.

Historical validation indexes preserve:

- workflow evidence;
- release evidence;
- validation artifacts;
- qualification references.

The architecture-layer documentation preserves the detailed progression from M3 through M15 without duplicating the full archive inside the public README.

Primary archive layers:

`RELEASE_NOTES_v*.md`

`TEST_REPORT_v*.md`

`FRP_VALIDATION_INDEX_v*.md`

`CHANGELOG.md`

`MILESTONES.md`

`docs/m3_*.md` through `docs/m15_*.md`

The current public README therefore presents:

- current processor identity;
- current architecture;
- complete computational equations;
- current qualification state;
- cumulative benchmark evidence;
- hardware-facing development path;
- release and citation information.

The detailed historical record remains in the dedicated repository archive.

## Repository Navigation

### Current Executable Layer

Current FRP executable reference:

`frp_prototype_v1_7_0.py`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

### Architecture and Mathematical Definition

Core principles:

`docs/core_principles.md`

Resonance computation:

`docs/resonance_computation.md`

Processor architecture:

`docs/architecture.md`

Structured output and schema definition:

`docs/output_schema.md`

Benchmark interpretation:

`docs/benchmark_interpretation.md`

### M15 Implementation Mapping

M15 architecture definition:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current executable implementation:

`frp_prototype_v1_7_0.py`

Current M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current release evidence:

- `RELEASE_NOTES_v1_7_0.md`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`.

### Comparative Architecture Benchmark

Benchmark directory:

`benchmarks/architecture_comparison/`

Canonical comparative result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76.json`

Canonical hardware-sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

Benchmark interpretation:

`docs/benchmark_interpretation.md`

### Hardware-Facing Development

Hardware pathway:

`docs/hardware_pathway.md`

Implementation layers:

`docs/implementation_layers.md`

FPGA mapping study:

`docs/fpga_mapping_study.md`

ASIC mapping study:

`docs/asic_mapping_study.md`

Physical validation plan:

`docs/physical_validation_plan.md`

FPGA register-map draft:

`docs/fpga_register_map_draft.md`

Testbench comparison plan:

`docs/testbench_comparison_plan.md`

### Execution and Reproducibility

Usage reference:

`USAGE.md`

Installation reference:

`INSTALL.md`

Reproducibility procedure:

`REPRODUCIBILITY.md`

Continuous integration reference:

`CI.md`

Verification registry:

`verification/README.md`

### Project Structure and Release History

Repository structure:

`PROJECT_STRUCTURE.md`

Documentation index:

`docs/README.md`

Milestone history:

`MILESTONES.md`

Version history:

`CHANGELOG.md`

Citation metadata:

`CITATION.cff`

Funding brief:

`funding_brief.md`

## Release Status

Current release:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current validation status:

`PASS`

Current M15 self-test result:

`41 / 41 PASS`

Current deterministic vector-regeneration result:

`10 / 10 files byte-identical`

Current semantic correlation result:

`5 / 5 required matches = 1.0`

Current deterministic replay result:

`6 / 6 replay matches = 1.0`

Current Comparative Architecture Benchmark status:

`PASS`

Current Hardware Sensitivity Profile Qualification status:

`PASS`

Current Hardware Sensitivity Comparison status:

`PASS`

Current M15 qualification closure status:

`PASS`

The current release package contains:

- the executable FRP v1.7.0 reference;
- structured machine-readable output;
- full execution trace;
- cumulative benchmark history;
- Comparative Architecture Benchmark Suite;
- hardware-informed sensitivity qualification;
- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- M15 qualification closure;
- FPGA mapping documentation;
- ASIC mapping documentation;
- physical validation planning;
- reproducibility documentation;
- citation metadata;
- archival release evidence.

Current DOI:

`10.5281/zenodo.21183966`

Current release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

## License

Apache License 2.0.

Full license text:

`LICENSE`

## Citation

Citation metadata:

`CITATION.cff`

Current project title:

`Fractal Resonance Processor (FRP): Ternary Resonant Coherence Processor`

Current version:

`v1.7.0`

Author:

`Maksym Marnov`

Current DOI:

`10.5281/zenodo.21183966`

DOI:

`https://doi.org/10.5281/zenodo.21183966`

Recommended citation:

`Maksym Marnov. Fractal Resonance Processor (FRP): Ternary Resonant Coherence Processor. Version v1.7.0. Zenodo. DOI: 10.5281/zenodo.21183966`

Historical archived release:

`FRP v0.9.3 — Ternary Resonant Coherence Processor`

Historical archived DOI:

`10.5281/zenodo.21112439`

---

**Author:**

Maksym Marnov (Alchimist)

**Berlin, 8 July 2026**














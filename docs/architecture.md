# FRP Architecture

## Fractal Resonance Processor v0.9.3-mobile

FRP — Fractal Resonance Processor — is a ternary resonant coherence processor simulation architecture.

The current implementation is a Python simulation prototype. It is not a hardware implementation.

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current candidate version:

    v0.9.3-mobile

## Architectural Definition

FRP treats computation as a dynamic process of:

- balanced ternary state transformation
- neutral transition control
- distributed commit
- resonant phase evolution
- coherence accumulation
- stability tracking
- retained output formation

The architecture does not model computation as immediate forced switching between static states. It models computation as a controlled transition process in which unstable or conflicting transitions are routed through the neutral state.

## Core State Model

FRP uses balanced ternary states:

| State | Role |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The direct transition between -1 and 1 is forbidden in the operational model.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The neutral state 0 is not treated as absence. It is an active architectural state used for:

- logical neutrality
- transition buffering
- phase damping
- conflict neutralization
- refractory behavior
- switching-load control

## Stability Condition

The operational stability condition is:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| C(t) | operational coherence |
| P(t) | destabilizing load |
| C_minus_P | C(t) - P(t) |

In the current prototype:

    P(t) = heat + switch_load

A stable computation requires:

    C_minus_P > 0

The prototype tracks this value per tick.

## High-Level Processing Pipeline

FRP execution follows this pipeline:

    input ternary state
        ↓
    target operation selection
        ↓
    balanced ternary ALU target generation
        ↓
    phase encoding
        ↓
    Kuramoto-Sakaguchi resonant phase evolution
        ↓
    nonlinear saturation
        ↓
    compression
        ↓
    independent delay buffers
        ↓
    neutral transition logic
        ↓
    distributed commit
        ↓
    stability telemetry
        ↓
    retained ternary output

## Main Architectural Layers

### 1. Balanced Ternary Logic Layer

The balanced ternary logic layer defines the computational state space.

Supported ternary ALU operations:

| Operation | Description |
|---|---|
| neg | ternary negation |
| add | balanced ternary addition |
| sub | balanced ternary subtraction |
| compare | ternary comparison |
| consensus | neutral conflict-resolving consensus |

This layer produces the target state for the dynamic transition layer.

### 2. Neutral Transition Layer

The neutral transition layer enforces the rule that a direct transition from -1 to 1 or from 1 to -1 is not executed directly.

Instead, conflicting transitions are routed through 0.

This layer tracks:

| Metric | Meaning |
|---|---|
| actual_direct_events | direct -1 ↔ 1 transitions that actually occurred |
| prevented_direct_events | direct transition attempts prevented by the model |
| neutralized_conflicts | conflicts routed into neutral 0 |

The required condition for the candidate prototype is:

    actual_direct_events = 0

### 3. Distributed Commit Layer

The distributed commit layer prevents too many nodes from changing state in a single tick.

Default parameter:

    transition_fraction = 0.25

This means that, by default, no more than 25 percent of the ternary state vector may change during one tick.

The purpose of this layer is to reduce switching load and avoid abrupt global transitions.

### 4. Resonant Phase Layer

The resonant phase layer uses Kuramoto-Sakaguchi type phase dynamics.

This layer models coupled oscillator behavior with phase lag.

The phase lag gamma represents asymmetric coupling, delay, dissipation, or nonlinear phase shift.

Default parameter:

    gamma = 0.30π

This layer does not replace ternary logic. It acts as a dynamic phase-evolution layer around the ternary transition process.

### 5. Nonlinear Channel Layer

The nonlinear channel limits transition amplitude before quantization.

It contains:

- cubic saturation
- nonlinear compression

Cubic saturation:

    x / (1 + beta * abs(x)^3)

Compression:

    tanh(gain * x)

Default parameters:

| Parameter | Value |
|---|---:|
| saturation_beta | 0.75 |
| compression_gain | 1.20 |

The purpose of this layer is to constrain excessive signal growth while preserving dynamic response.

### 6. Delay Layer

FRP v0.9.3-mobile uses independent delay buffers for:

- logic delay
- coupling delay

The buffers advance once per internal tick.

This is required because the numerical phase integrator uses RK2 and calls the phase derivative function more than once per step. Advancing delay buffers inside each derivative call would distort the tact-by-tact delay model.

### 7. Scheduler Layer

The scheduler controls commit, balance, excite, and neutralize phases.

Supported scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Scheduler counts are validated against internal tick count.

The scheduler is not counted by telemetry rows. It is counted by actual internal steps.

### 8. Processor Layer

The processor layer wraps the FRP core into a minimal instruction execution model.

It includes:

- register file
- program counter
- instruction execution
- demo program
- self-test mode
- benchmark mode

Supported instructions:

| Instruction | Role |
|---|---|
| load | load immediate ternary vector into register |
| rand | generate random ternary vector |
| zero | zero a register |
| mov | copy register |
| neg | execute ternary negation |
| add | execute ternary addition |
| sub | execute ternary subtraction |
| compare | execute ternary comparison |
| consensus | execute ternary consensus |
| halt | stop execution |

## Core Classes

The single-file prototype contains the following main classes:

| Class | Role |
|---|---|
| FRPCore | dynamic ternary resonant execution core |
| Instruction | instruction data structure |
| RegisterFile | ternary register storage |
| FRPProcessor | processor wrapper around FRPCore |

## Core Functions

Important functional groups:

| Function Group | Functions |
|---|---|
| ternary validation | trits, rand_trits |
| quantization | q, qW |
| phase mapping | phase_from_trits |
| nonlinear shaping | cubic_saturation, nonlinear_channel |
| ternary arithmetic | normalize_trit, t_neg, t_add, t_sub, t_value, t_compare, t_consensus |
| target generation | target_for |
| scheduler validation | expected_scheduler_counts |
| baselines | direct_baseline, distributed_neutral_baseline, binary_forced_baseline |
| command modes | run_demo, run_test, run_bench |

## Telemetry Model

Per-tick telemetry is mandatory in v0.9.3-mobile.

Telemetry fields:

| Field | Meaning |
|---|---|
| tick | internal tick number |
| phase | current scheduler phase |
| R | global Kuramoto order parameter |
| phi | mean phase angle |
| neutral | fraction of nodes in state 0 |
| positive | fraction of nodes in state 1 |
| negative | fraction of nodes in state -1 |
| heat | simulated heat variable |
| thermal_scale | heat-dependent scaling factor |
| switch_load | fraction of nodes switched during the tick |
| actual_direct_events_delta | actual direct -1 ↔ 1 events during the tick |
| prevented_direct_events_delta | direct transition attempts prevented during the tick |
| neutralized_conflicts_delta | conflicts neutralized through 0 during the tick |
| logical_match | fraction of nodes matching target |
| transition_debt | fraction of nodes not yet matching target |
| direct_conflict_fraction | fraction of nodes in direct conflict with target |
| C | operational coherence |
| P | destabilizing load |
| C_minus_P | operational stability margin |

Telemetry skipping is disabled in the candidate version because it may hide transient instability.

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Candidate Invariants

The v0.9.3-mobile candidate is expected to satisfy:

| Invariant | Required Condition |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## Baseline Comparison Model

The prototype includes three baseline models:

| Baseline | Purpose |
|---|---|
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

These baselines are included for simulation comparison only.

The current benchmark does not support the claim that FRP is always colder than distributed neutral ternary switching.

The supported claim is narrower:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

## Current Status

FRP v0.9.3-mobile is a working candidate prototype.

It is suitable for repository packaging as a simulation prototype.

It is not a hardware implementation and does not establish hardware-level thermal, electrical, timing, fabrication, or performance claims.

## Related Files

| File | Purpose |
|---|---|
| README.md | project overview |
| frp_prototype_v0_9_3_mobile.py | main prototype |
| TEST_REPORT_v0_9_3.md | candidate test report |
| docs/architecture.md | architecture description |
| docs/benchmark_interpretation.md | benchmark interpretation |
| docs/limitations.md | simulation limitations |

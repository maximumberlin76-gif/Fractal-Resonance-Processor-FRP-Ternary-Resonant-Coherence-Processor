# Verification Layer

This directory contains the verification layer for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## Verification Scope

The verification layer is focused on reproducible validation of the current FRP candidate prototype.

The current verification scope includes:

- balanced ternary ALU correctness
- target match validation
- direct transition safety
- neutral conflict routing
- distributed commit validation
- C_minus_P stability monitoring
- heat and switch_load tracking
- scheduler count validation
- per-tick telemetry validation
- benchmark comparison against baseline transition models

## Candidate Version

The active verification target is:

    FRP v0.9.3-mobile

The active prototype file is:

    frp_prototype_v0_9_3_mobile.py

The active test report is:

    TEST_REPORT_v0_9_3.md

Older verification documents may use the previous project name:

    FPR

The current project name is:

    FRP — Fractal Resonance Processor

Legacy verification files should be reviewed before deletion or replacement.

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Core Verification Invariants

The v0.9.3-mobile candidate is verified against the following invariants:

| Invariant | Required Condition |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability margin | C_minus_P_min > 0 |
| distributed transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

Default transition cap:

    transition_fraction = 0.25

Default telemetry mode:

    telemetry_every = 1

Per-tick telemetry is mandatory for the current candidate.

Telemetry skipping is not allowed because it may hide transient instability.

## Verification Metrics

The current prototype reports the following verification metrics:

| Metric | Meaning |
|---|---|
| match | fraction of output nodes matching the target |
| C_minus_P_min | minimum stability margin during execution |
| heat_peak | maximum simulated heat value |
| switch_load_peak | maximum fraction of nodes switched during one tick |
| actual_direct_events | actual direct -1 ↔ 1 transitions |
| prevented_direct_events | direct transition attempts prevented by the model |
| neutralized_conflicts | conflicts routed through neutral 0 |
| ticks_recorded | number of telemetry records |
| commits | number of commit scheduler ticks |
| excites | number of excite scheduler ticks |
| balances | number of balance scheduler ticks |
| neutralizes | number of neutralize scheduler ticks |

## Direct Transition Safety

The FRP operational model forbids direct transitions between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The required verification result is:

    actual_direct_events = 0

The model distinguishes:

| Event Type | Meaning |
|---|---|
| actual_direct_events | direct -1 ↔ 1 transitions that actually occurred |
| prevented_direct_events | direct transition attempts blocked by the model |
| neutralized_conflicts | conflicts routed into neutral 0 |

## Stability Verification

The core stability condition is:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| C(t) | operational coherence |
| P(t) | destabilizing load |
| C_minus_P | C(t) - P(t) |

In the current prototype:

    P(t) = heat + switch_load

The required verification result is:

    C_minus_P_min > 0

## Scheduler Verification

The scheduler is validated by internal tick count.

Supported scheduler modes:

| Mode | Expected Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Scheduler counts are not inferred from documentation.

They are checked directly during test execution.

## Standard Verification Command

Run standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

Expected standard test summary:

| Metric | Value |
|---|---:|
| runs | 300 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 3820 |
| neutralized_conflicts | 2392 |
| failures | 0 |
| result | PASS |

## Heavy Verification Command

Run heavy self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Expected heavy test summary:

| Metric | Value |
|---|---:|
| runs | 600 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 7913 |
| neutralized_conflicts | 4921 |
| failures | 0 |
| result | PASS |

## Benchmark Verification Command

Run benchmark:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The benchmark compares:

| Architecture | Purpose |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit baseline |
| distributed_neutral_ternary | distributed neutral transition baseline |
| binary_style_forced_switch | rail-style forced switching baseline |

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Benchmark Interpretation

The direct ternary and binary-style forced switching baselines reach the target state, but they allow actual direct -1 ↔ 1 transitions.

The distributed neutral ternary baseline prevents actual direct transitions and is colder in the current simulation because it does not include the Kuramoto-Sakaguchi resonant phase layer.

The FRP distributed resonant mode preserves:

- match = 1.000
- actual_direct_events = 0
- C_minus_P_min > 0
- switch_load_peak = 0.25

The supported claim is:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The unsupported claim is:

    FRP is always colder than distributed neutral ternary switching.

## Reproducibility Requirements

A verification run should record:

- prototype version
- command used
- steps
- seeds
- N values
- cycle modes
- operations
- result status
- first failure, if any
- C_minus_P_min
- heat_peak
- switch_load_peak
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

The current test report records the verified v0.9.3-mobile candidate results.

## Legacy Verification Files

Older verification files may still describe:

- coherence measurement
- synchronization state validation
- dynamic stability monitoring
- simulation reproducibility
- hash-chain logging
- integrity proofs

These concepts may remain useful as background, but they must be aligned with the current v0.9.3-mobile prototype before being treated as active verification material.

Legacy files should be handled as follows:

| Legacy Condition | Action |
|---|---|
| still technically valid | update terminology from FPR to FRP |
| partially outdated | rewrite or move to legacy |
| conflicting with v0.9.3-mobile | replace or remove |
| conceptual only | keep only if clearly marked as background |

## Simulation Boundary

The current verification layer validates a Python simulation prototype.

It does not verify:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- universal superiority over all ternary transition baselines

All current verification claims are limited to the tested simulation domain.

## Current Status

FRP v0.9.3-mobile is verified as a working candidate prototype in the tested operational domain.

This verification layer should remain aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/core_principles.md
- ../docs/resonance_computation.md

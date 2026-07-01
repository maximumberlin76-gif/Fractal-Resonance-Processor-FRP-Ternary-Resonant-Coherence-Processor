# Usage

This document explains how to run and interpret the current Fractal Resonance Processor (FRP) simulation prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Basic Command Format

The prototype is executed from the repository root:

    python3 frp_prototype_v0_9_3_mobile.py --mode <mode> [options]

If `python3` is not available, use:

    python frp_prototype_v0_9_3_mobile.py --mode <mode> [options]

## 2. Available Modes

The prototype supports three main modes:

| Mode | Purpose |
|---|---|
| demo | run a small processor demonstration program |
| test | run self-test verification |
| bench | run benchmark comparison |

## 3. Demo Mode

Run the default demo:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo

Run a demo with explicit parameters:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

The demo mode demonstrates:

- balanced ternary register operations
- target-oriented instruction execution
- neutral transition routing
- distributed commit
- Kuramoto-Sakaguchi resonant phase dynamics
- telemetry summary

The demo program includes:

- load
- add
- sub
- neg
- compare
- consensus
- halt

## 4. Test Mode

Run the standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

The standard self-test verifies:

- target match
- actual_direct_events = 0
- C_minus_P_min > 0
- switch_load_peak <= transition_fraction
- ticks_recorded = steps
- scheduler count correctness

Expected standard summary:

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

## 5. Heavy Self-Test

Run the heavier self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Expected heavy summary:

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

## 6. Benchmark Mode

Run the benchmark:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The benchmark compares:

| Architecture | Purpose |
|---|---|
| binary_style_forced_switch | rail-style forced switching comparison |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| frp_distributed_resonant | FRP resonant distributed ternary transition model |

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 7. Command Options

| Option | Meaning | Example |
|---|---|---|
| --mode | execution mode | --mode demo |
| --N | number of ternary nodes | --N 16 |
| --steps | internal simulation ticks | --steps 128 |
| --seeds | number of random seeds for test or benchmark | --seeds 5 |
| --cycle-mode | scheduler mode | --cycle-mode 7/1 |

## 8. Scheduler Modes

The prototype supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Run demo with free mode:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode free

Run demo with 7/1 mode:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run demo with 1/7 mode:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 1/7

## 9. Balanced Ternary States

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The neutral state 0 is active.

It is used for:

- transition routing
- damping
- conflict neutralization
- safe polarity change
- distributed state update

## 10. Forbidden Direct Transition

FRP forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The key safety invariant is:

    actual_direct_events = 0

## 11. Distributed Commit

The prototype limits how much of the ternary state vector can change during one tick.

Default transition cap:

    transition_fraction = 0.25

Required condition:

    switch_load_peak <= transition_fraction

This prevents full-vector forced switching under default settings.

## 12. C_minus_P Stability

The prototype tracks operational stability through:

    C_minus_P = C - P

where:

| Symbol | Meaning |
|---|---|
| C | operational coherence |
| P | destabilizing load |
| C_minus_P | stability margin |

In the current prototype:

    P = heat + switch_load

Required condition:

    C_minus_P_min > 0

## 13. Key Metrics

| Metric | Meaning |
|---|---|
| match | final target match |
| C_minus_P_min | minimum stability margin during execution |
| heat_peak | maximum simulated heat metric |
| switch_load_peak | maximum transition load |
| actual_direct_events | actual forbidden direct -1 ↔ 1 events |
| prevented_direct_events | direct conflicts prevented by the transition logic |
| neutralized_conflicts | conflicts routed through neutral 0 |
| failures | failed self-test cases |
| result | PASS or FAIL |

## 14. PASS Interpretation

A test result is valid only if the candidate invariants hold together.

Required conditions:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy the safety and stability conditions.

## 15. Supported Claim

The current supported claim is:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

## 16. Unsupported Claims

The current prototype does not support the claim:

    FRP is always colder than distributed neutral ternary switching.

The current prototype also does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all transition baselines

## 17. Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## 18. Simulation Boundary

All current results are simulation results.

They are produced inside the Python model.

They are not hardware measurements.

The current prototype should be described as:

    Python simulation prototype

It should not be described as:

- fabricated hardware processor
- production-ready computing device
- hardware-validated chip architecture
- measured thermal processor
- measured electrical switching-energy device

## 19. Related Files

This usage guide is aligned with:

- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- INSTALL.md
- requirements.txt
- README.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- verification/README.md
- verification/coherence_metrics.md

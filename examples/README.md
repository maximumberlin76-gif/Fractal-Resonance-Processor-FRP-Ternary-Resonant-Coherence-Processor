# Example Scenarios

This directory contains public example scenarios for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## Example Scope

The examples layer demonstrates how to run and interpret the current FRP simulation prototype.

The current examples focus on:

- balanced ternary operations
- neutral transition routing
- forbidden direct -1 ↔ 1 transition prevention
- distributed ternary commit
- Kuramoto-Sakaguchi resonant phase dynamics
- scheduler modes
- per-tick telemetry
- C_minus_P stability tracking
- benchmark comparison
- simulation-only interpretation

## Active Example Entry Point

The active example entry point is:

    ../frp_prototype_v0_9_3_mobile.py

The prototype provides three command modes:

| Mode | Purpose |
|---|---|
| demo | run a small processor demonstration program |
| test | run self-test verification |
| bench | run benchmark comparison |

## Demo Example

Run a basic FRP processor demo:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

The demo program demonstrates:

- register loading
- balanced ternary ALU operations
- target-oriented execution
- distributed transition
- per-operation telemetry summary

The demo program includes:

- load
- add
- sub
- neg
- compare
- consensus
- halt

## Standard Self-Test Example

Run the standard self-test:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

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

## Heavy Self-Test Example

Run the heavier self-test:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

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

## Benchmark Example

Run the benchmark:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The benchmark compares:

| Architecture | Purpose |
|---|---|
| frp_distributed_resonant | FRP resonant distributed ternary transition model |
| direct_ternary_commit | direct ternary state commit without neutral routing |
| distributed_neutral_ternary | distributed neutral transition without resonant phase layer |
| binary_style_forced_switch | rail-style forced switching comparison |

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Scheduler Examples

FRP supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Run demo with free mode:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode free

Run demo with 7/1 mode:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run demo with 1/7 mode:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 1/7

## Balanced Ternary Example

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive potential |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive potential |

The direct transition between -1 and 1 is forbidden.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The required condition is:

    actual_direct_events = 0

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Example Interpretation

Example runs should be interpreted as simulation demonstrations.

They show behavior inside the current Python model.

They do not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all transition baselines

## Current Alignment

Examples in this directory should align with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ../verification/README.md
- ../verification/coherence_metrics.md
- ../models/README.md
- ../simulations/README.md

## Current Status

The examples layer is aligned with the FRP v0.9.3-mobile candidate prototype.

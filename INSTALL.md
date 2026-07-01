# Installation

This document explains how to install and run the current Fractal Resonance Processor (FRP) simulation prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

Dependency file:

    requirements.txt

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## Requirements

Required:

- Python 3.10 or newer
- pip
- numpy

The only external Python dependency is listed in:

    requirements.txt

Current dependency:

    numpy>=1.26.0

## Clone the Repository

Clone the repository:

    git clone https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor.git

Enter the repository directory:

    cd Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

## Optional Virtual Environment

Create a virtual environment:

    python3 -m venv .venv

Activate it on Linux or macOS:

    source .venv/bin/activate

Activate it on Windows PowerShell:

    .venv\Scripts\Activate.ps1

## Install Dependencies

Install dependencies:

    pip install -r requirements.txt

## Run Demo

Run the basic FRP processor demo:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

The demo runs a small processor program using:

- balanced ternary operations
- register operations
- distributed transition
- resonant phase dynamics
- telemetry summary

## Run Standard Self-Test

Run the standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

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

## Run Heavy Self-Test

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

## Run Benchmark

Run the benchmark:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## Scheduler Modes

The prototype supports three scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Example:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode free

Example:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Example:

    python3 frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 1/7

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Troubleshooting

If Python cannot find numpy, reinstall dependencies:

    pip install -r requirements.txt

If the command `python3` is not available, try:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

If the virtual environment does not activate, run the commands directly with the system Python installation.

## Current Status

This installation guide is aligned with:

- frp_prototype_v0_9_3_mobile.py
- requirements.txt
- TEST_REPORT_v0_9_3.md
- README.md
- docs/limitations.md

# Initial Kuramoto Synchronization Result

This document records an early Kuramoto-type synchronization simulation used as preliminary background for the Fractal Resonance Processor (FRP) project.

This file is retained as a legacy preliminary simulation note.

It is not the current FRP v0.9.3-mobile benchmark.

Current candidate version:

    v0.9.3-mobile

Current main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## Status

This simulation predates the current FRP v0.9.3-mobile prototype.

It should be interpreted as a preliminary Kuramoto synchronization experiment, not as validation of the current ternary resonant coherence processor candidate.

The current FRP prototype now includes:

- balanced ternary states: -1, 0, 1
- forbidden direct -1 ↔ 1 transition
- neutral 0 transition routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear saturation
- compression
- independent logic and coupling delay buffers
- per-tick telemetry
- C_minus_P stability tracking
- benchmark comparison against transition baselines

This legacy simulation only addresses phase synchronization behavior in a simplified oscillator model.

## Simulation Objective

The simulation was designed to evaluate how external resonant driving influences phase synchronization speed and coherence formation within a nonlinear oscillator system.

The simulation focused on:

- phase synchronization
- convergence time
- global coherence
- external resonant driving
- comparison between baseline, resonance, off-resonance, and pulsed scenarios

## Core Interaction Model

The simplified interaction model was:

    dφ_i/dt = ω_i + (K/N) · Σ sin(φ_j - φ_i) + F_ext · sin(ω_ext · t - φ_i) + η

where:

| Symbol | Meaning |
|---|---|
| φ_i | phase of oscillator i |
| ω_i | natural frequency of oscillator i |
| K | coupling strength |
| N | number of oscillators |
| F_ext | external driving amplitude |
| ω_ext | external driving frequency |
| η | noise or fluctuation term |

## Coherence Metric

The simulation used the Kuramoto order parameter:

    R = |(1/N) · Σ exp(i · φ_j)|

where:

| R Value | Interpretation |
|---|---|
| R → 1 | high global phase synchronization |
| R → 0 | incoherent phase dynamics |

## Simulation Results

| Scenario | R_final | R_max | Convergence Time |
|---|---:|---:|---:|
| Baseline | 0.980 | 0.980 | 3.35 |
| Resonance | 0.997 | 0.997 | 1.42 |
| Off-resonance | 0.996 | 0.996 | 1.38 |
| Pulsed | 0.986 | 0.992 | 2.65 |

## Observations

The resonant scenario demonstrated accelerated convergence toward global phase synchronization.

Convergence time decreased from:

    3.35 → 1.42

This corresponds to an acceleration factor of approximately:

    2.36x

The result suggested that external driving can accelerate phase coherence formation in a simplified nonlinear oscillator system.

## Current Interpretation

This result supports only a limited preliminary observation:

    selective external driving may accelerate global phase synchronization in a simplified Kuramoto-type oscillator model.

It does not by itself validate the full FRP v0.9.3-mobile architecture.

The current FRP candidate uses a more specific model that includes:

- balanced ternary target states
- neutral transition routing
- direct transition prevention
- distributed commit
- Kuramoto-Sakaguchi phase lag
- nonlinear saturation
- compression
- delay buffers
- per-tick operational stability telemetry

## Relation to FRP v0.9.3-mobile

The legacy Kuramoto result is relevant as background for the resonant phase layer.

However, the current FRP prototype does not use global order parameter R alone as the main correctness metric.

Reason:

A valid distributed ternary target may intentionally contain mixed -1, 0, and 1 states.

Such a state may be computationally correct even when global phase order R is not maximal.

Therefore, FRP v0.9.3-mobile evaluates target-mode coherence through operational metrics such as:

- logical_match
- transition_debt
- direct_conflict_fraction
- heat
- switch_load
- C_minus_P
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

## Current Benchmark Boundary

The current validated benchmark is documented in:

    ../TEST_REPORT_v0_9_3.md

The current benchmark supports the following claim:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

This legacy Kuramoto simulation does not support claims about:

- balanced ternary computation
- direct -1 ↔ 1 transition prevention
- neutral conflict routing
- distributed commit
- C_minus_P stability
- hardware thermal efficiency
- electrical switching energy reduction
- hardware performance

## Simulation Boundary

This file documents a preliminary numerical synchronization experiment.

It does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- universal superiority over baseline transition models
- validation of the full FRP v0.9.3-mobile candidate

All claims in this file are limited to the original simplified Kuramoto-type synchronization experiment.

## Current Status

This file is retained as historical background for the resonance-phase direction of the FRP project.

It should be read together with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ./README.md

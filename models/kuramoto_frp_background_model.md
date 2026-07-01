# Kuramoto Background Model

This document describes the preliminary Kuramoto-type phase model retained as historical background for the Fractal Resonance Processor (FRP) project.

This file is a legacy model note.

It is not the full active model of the current FRP v0.9.3-mobile candidate prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## Status

This document preserves the early nonlinear phase-synchronization basis that influenced the resonance layer of the FRP project.

It predates the current active FRP architecture.

The current prototype now includes:

- balanced ternary states: -1, 0, 1
- forbidden direct -1 ↔ 1 transition
- neutral 0 routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear saturation
- compression
- independent logic and coupling delay buffers
- per-tick telemetry
- operational coherence tracking
- C_minus_P stability tracking
- benchmark comparison against baseline transition models

This legacy file only describes the phase-synchronization background layer.

## Purpose

The purpose of this model is to describe the early nonlinear oscillator interaction logic that motivated the resonance-phase direction of the FRP framework.

This background model focuses on:

- oscillator phase interaction
- external resonant driving
- global synchronization behavior
- coherence growth
- convergence dynamics in open interacting systems

## Core Dynamic Equation

The early simplified interaction model is:

    dφ_i/dt = ω_i + (K/N) · Σ sin(φ_j - φ_i) + F_ext · sin(ω_ext · t - φ_i) + η

where:

| Symbol | Meaning |
|---|---|
| φ_i | phase state of oscillator i |
| ω_i | natural frequency of oscillator i |
| K | coupling strength |
| N | number of interacting oscillators |
| F_ext | external resonant driving force |
| ω_ext | external driving frequency |
| η | fluctuation or noise component |

This equation represents a Kuramoto-type synchronization model.

## Relation to the Current FRP Prototype

The current FRP v0.9.3-mobile candidate does not use this equation alone as its full computational model.

The active prototype extends the early phase-synchronization idea by adding:

- balanced ternary target states
- explicit transition logic
- neutral conflict routing
- distributed commit control
- phase lag through Kuramoto-Sakaguchi dynamics
- nonlinear shaping
- delay-buffer structure
- operational stability metrics

Therefore, this file should be read as preliminary model background, not as the complete current FRP architecture.

## Current Resonance-Phase Interpretation

In the current project direction, the resonance-phase layer is interpreted as a dynamic support layer for ternary transition behavior.

This means that phase evolution does not replace computation.

Instead, it modulates and supports the controlled evolution of ternary states toward stable target configurations.

## Coherence Measurement

The early model measures global synchronization coherence using the order parameter:

    R = |(1/N) · Σ exp(i · φ_j)|

where:

| R Value | Interpretation |
|---|---|
| R → 1 | high global phase synchronization |
| R → 0 | incoherent phase dynamics |

This metric remains useful as a background indicator of phase order.

However, in the current FRP prototype, R alone is not sufficient to determine computational correctness.

## Why R Is Not Enough for FRP

A valid FRP target state may intentionally contain mixed ternary values:

- -1
- 0
- 1

Such a distributed ternary state may be computationally correct even when the global phase order parameter R is not maximal.

Therefore, the current FRP prototype evaluates target-mode behavior using operational metrics such as:

- logical_match
- transition_debt
- direct_conflict_fraction
- heat
- switch_load
- C_minus_P
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts

## Early FPR Interpretation and Current FRP Interpretation

Legacy interpretation:

- computation as dynamic phase evolution
- resonance as selective coherent mode support
- synchronization as coherence growth
- stable states as retained coherent structures

Current FRP interpretation:

- computation as balanced ternary transition control
- resonance as a dynamic phase-support layer
- coherence as an operational target-sensitive metric
- stable output as retained ternary state after safe distributed transition

The current FRP interpretation is therefore narrower and more structured than the original FPR wording.

## Dynamic Stability Principle

The core stability principle remains:

    C(t) > P(t)

where:

| Symbol | Meaning |
|---|---|
| C(t) | operational coherence |
| P(t) | destabilizing load |
| C_minus_P | C(t) - P(t) |

In the current prototype:

    P(t) = heat + switch_load

Important boundary:

This is an operational simulation metric.

It is not presented here as a universal physical law.

## Current FRP Phase Layer Extension

The current FRP prototype uses a Kuramoto-Sakaguchi type extension rather than the original plain Kuramoto-only form.

Default phase lag:

    gamma = 0.30π

The phase lag introduces asymmetric coupling behavior and better matches the current tact-by-tact resonant control logic.

So the active prototype is more accurately described as using a Kuramoto-Sakaguchi phase layer, not only a simple Kuramoto layer.

## Model Boundary

This legacy model file does not by itself describe:

- balanced ternary arithmetic
- direct -1 ↔ 1 transition prevention
- neutral transition routing
- distributed commit control
- benchmark baselines
- scheduler behavior
- per-tick telemetry structure
- operational target matching
- full FRP v0.9.3-mobile architecture

Those elements are described in the current active documentation.

## Supported Background Claim

This file supports the following limited background claim:

    nonlinear phase synchronization and external resonant driving provide a conceptual background for the resonance-phase layer of the FRP project.

This file does not support the following full-system claim:

    the early Kuramoto-type model alone defines the current FRP processor architecture.

That would be false.

## Simulation Boundary

This file describes a preliminary mathematical background model.

It does not establish:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- hardware timing behavior
- validation of the full FRP v0.9.3-mobile candidate
- universal superiority over other processor models

All claims in this file are limited to the early nonlinear synchronization background layer.

## Current Status

This file is retained as historical model background and should be read together with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../README.md
- ./README.md
- ../docs/architecture.md
- ../docs/benchmark_interpretation.md
- ../docs/limitations.md
- ../verification/coherence_metrics.md

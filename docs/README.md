# Documentation Layer

This directory contains the public documentation layer for the Fractal Resonance Processor (FRP) project.

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## Documentation Scope

The documentation layer explains the public architecture, behavior, limitations, benchmark interpretation, verification metrics, and output structure of the current FRP simulation prototype.

It covers:

- balanced ternary state logic
- neutral transition routing
- forbidden direct -1 ↔ 1 transition prevention
- distributed ternary commit
- Kuramoto-Sakaguchi resonant phase dynamics
- nonlinear saturation and compression
- independent logic and coupling delay buffers
- scheduler modes: free, 7/1, 1/7
- per-tick telemetry
- C_minus_P stability tracking
- benchmark interpretation
- output schema
- simulation limitations
- public claim boundaries

## Current Documentation Files

| File | Purpose |
|---|---|
| README.md | documentation layer index |
| core_principles.md | core FRP principles |
| resonance_computation.md | resonance computation explanation |
| architecture.md | architecture description for FRP v0.9.3-mobile |
| benchmark_interpretation.md | interpretation of benchmark results and baseline comparison |
| limitations.md | simulation limitations and claim boundaries |
| output_schema.md | console output fields, test markers, benchmark markers, CI checks, and future JSON output direction |

## Primary Documentation Priority

The active documentation priority is:

1. architecture.md
2. benchmark_interpretation.md
3. limitations.md
4. output_schema.md
5. core_principles.md
6. resonance_computation.md

These files should align with:

- ../README.md
- ../TEST_REPORT_v0_9_3.md
- ../REPRODUCIBILITY.md
- ../USAGE.md
- ../CI.md
- ../frp_prototype_v0_9_3_mobile.py

## Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy direct-transition safety, distributed switching, telemetry, scheduler, and stability conditions.

## Important Claim Boundary

The current FRP repository describes a Python simulation prototype.

It does not claim hardware implementation.

The following claims are allowed:

- FRP demonstrates a working Python simulation prototype.
- FRP uses balanced ternary states -1, 0, 1.
- FRP uses neutral 0 as an active transition, damping, and balancing state.
- FRP prevents actual direct -1 ↔ 1 transitions in the tested operational domain.
- FRP routes conflicting transitions through neutral 0.
- FRP uses distributed commit with transition_fraction = 0.25.
- FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of distributed neutral ternary transition logic.
- FRP tracks C_minus_P, heat, switch_load, transition debt, and direct transition events.
- FRP self-test and benchmark commands are covered by GitHub Actions CI.

The following claims are not established:

- hardware thermal efficiency
- physical electrical switching-energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- universal superiority over all neutral transition baselines
- proof that FRP is always colder than distributed neutral ternary switching

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Update Rule

When the prototype changes, review whether the following documentation files must also change:

- architecture.md
- benchmark_interpretation.md
- limitations.md
- output_schema.md
- ../TEST_REPORT_v0_9_3.md
- ../REPRODUCIBILITY.md
- ../USAGE.md
- ../CI.md
- ../RELEASE_NOTES_v0_9_3.md
- ../CHANGELOG.md

Documentation must remain aligned with executable behavior.

## Current Status

The documentation layer is aligned with the FRP v0.9.3-mobile candidate prototype.

All current documentation remains limited to the Python simulation domain.

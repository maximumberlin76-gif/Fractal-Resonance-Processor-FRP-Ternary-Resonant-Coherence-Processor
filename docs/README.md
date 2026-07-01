# Documentation Layer

This directory contains the documentation layer for the Fractal Resonance Processor (FRP) project.

FRP is currently developed as a ternary resonant coherence processor simulation architecture.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## Documentation Scope

The documentation layer explains the public architecture of the current FRP simulation prototype.

It covers:

- balanced ternary state logic
- neutral transition control
- forbidden direct -1 ↔ 1 transition
- distributed ternary commit
- Kuramoto-Sakaguchi resonant phase dynamics
- nonlinear saturation and compression
- independent logic and coupling delay buffers
- scheduler modes: free, 7/1, 1/7
- per-tick telemetry
- benchmark interpretation
- simulation limitations

## Current Documentation Files

Recommended documentation structure:

| File | Purpose |
|---|---|
| README.md | documentation layer index |
| architecture.md | architecture description for FRP v0.9.3-mobile |
| benchmark_interpretation.md | interpretation of benchmark results and baseline comparison |
| limitations.md | simulation limitations and claim boundaries |

## Existing Legacy Files

This repository may still contain older documentation files created before the current FRP v0.9.3-mobile candidate.

Older files may use the previous name:

    FPR

The current project name is:

    FRP — Fractal Resonance Processor

Legacy documents should be reviewed before deletion or replacement.

Recommended handling:

| Legacy File Type | Action |
|---|---|
| still technically valid | update terminology from FPR to FRP |
| partially outdated | move to legacy or rewrite |
| conflicting with v0.9.3-mobile | replace or remove |
| conceptual but not implementation-specific | keep only if clearly marked as background |

## Current Candidate Documentation Priority

The active documentation priority is:

1. architecture.md
2. benchmark_interpretation.md
3. limitations.md

These files should align with:

- README.md
- TEST_REPORT_v0_9_3.md
- frp_prototype_v0_9_3_mobile.py

## Important Claim Boundary

The current FRP repository describes a Python simulation prototype.

It does not claim hardware implementation.

The following claims are allowed:

- FRP demonstrates a working Python simulation prototype.
- FRP uses balanced ternary states -1, 0, 1.
- FRP prevents actual direct -1 ↔ 1 transitions in the tested operational domain.
- FRP routes conflicting transitions through neutral 0.
- FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of distributed neutral ternary transition logic.
- FRP tracks C_minus_P, heat, switch_load, transition debt, and direct transition events per tick.

The following claims are not established:

- hardware thermal efficiency
- physical electrical switching energy reduction
- fabrication-level performance
- universal superiority over all neutral transition baselines
- proof that FRP is always colder than distributed neutral ternary switching

## Operational Domain

The tested operational domain is:

    N >= 8

Smaller values such as N = 2 or N = 3 may be used only as micro-tests of ternary logic.

They are not representative operational workloads.

## Current Status

FRP v0.9.3-mobile is a working candidate prototype suitable for repository packaging.

Documentation in this directory should now be aligned with the candidate source code and test report.

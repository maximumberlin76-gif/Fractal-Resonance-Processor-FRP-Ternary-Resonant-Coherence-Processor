# Contributing

Thank you for your interest in contributing to the Fractal Resonance Processor (FRP) project.

This repository contains the public simulation, documentation, and verification layer of the FRP v0.9.3-mobile candidate prototype.

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Before Contributing

Before proposing changes, please read:

- README.md
- INSTALL.md
- USAGE.md
- REPRODUCIBILITY.md
- TEST_REPORT_v0_9_3.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- SECURITY.md

Contributions should remain aligned with the current simulation scope and documented limitations.

## 2. Contribution Scope

Acceptable contribution areas include:

- Python simulation improvements
- bug fixes
- documentation corrections
- reproducibility improvements
- benchmark clarification
- telemetry explanation
- test coverage improvement
- terminology consistency
- installation and usage improvements

Contributions should improve clarity, reproducibility, correctness, or maintainability.

## 3. Required Terminology

Use the current project name consistently:

    FRP — Fractal Resonance Processor

Use the current candidate version when referring to the active prototype:

    v0.9.3-mobile

Use the current main prototype filename:

    frp_prototype_v0_9_3_mobile.py

Use the current test report filename:

    TEST_REPORT_v0_9_3.md

## 4. Simulation Boundary

All current technical claims must remain limited to the Python simulation domain.

The project should be described as:

    Python simulation prototype

It should not be described as:

- fabricated hardware processor
- production-ready computing device
- hardware-validated chip architecture
- measured thermal processor
- measured electrical switching-energy device
- deployment-ready hardware platform

## 5. Claim Discipline

New claims must be supported by code, tests, benchmark output, or documentation.

A claim is acceptable only if it is reproducible within the repository.

The current supported claim is:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.

The current prototype does not support the claim:

    FRP is always colder than distributed neutral ternary switching.

## 6. Candidate Invariants

Code changes must preserve the current candidate invariants unless the change explicitly updates the prototype version and test report.

Required invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy safety, stability, telemetry, and scheduler conditions.

## 7. Direct Transition Safety

FRP forbids direct transition between -1 and 1.

Forbidden transition:

    -1 ↔ 1

Allowed transition paths:

    -1 → 0 → 1
     1 → 0 → -1

The required invariant is:

    actual_direct_events = 0

Any change that produces actual direct -1 ↔ 1 transitions is not compatible with the current candidate.

## 8. Distributed Commit Boundary

The default transition cap is:

    transition_fraction = 0.25

The required condition is:

    switch_load_peak <= transition_fraction

Changes that alter switching behavior must update tests, benchmark interpretation, and documentation.

## 9. Stability Boundary

The prototype tracks:

    C_minus_P = C - P

where:

| Symbol | Meaning |
|---|---|
| C | operational coherence |
| P | destabilizing load |
| C_minus_P | stability margin |

In the current prototype:

    P = heat + switch_load

The required condition is:

    C_minus_P_min > 0

Changes that alter C, P, heat, switch_load, or C_minus_P must update the test report and reproducibility documentation.

## 10. Testing Requirements

Before submitting a code change, run the standard self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

For broader verification, run the heavy self-test:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Run the benchmark when changing transition logic, phase dynamics, telemetry, scheduler behavior, or metrics:

    python3 frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

## 11. Documentation Requirements

Documentation changes should be precise and consistent.

When updating behavior, also update the related documentation.

Relevant files may include:

- README.md
- INSTALL.md
- USAGE.md
- REPRODUCIBILITY.md
- TEST_REPORT_v0_9_3.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- verification/README.md
- verification/coherence_metrics.md

Do not introduce claims that exceed the current simulation evidence.

## 12. Security and Public Boundary

Do not add:

- credentials, tokens, keys, or secrets
- private access-control material
- deployment-sensitive operational details
- unpublished restricted design layers
- private identity or authentication data
- unsafe implementation instructions
- any material that compromises privacy, safety, or responsible disclosure boundaries

The public repository must remain limited to public simulation, documentation, and verification material.

## 13. Code Style

Code contributions should prioritize:

- clarity
- reproducibility
- explicit telemetry
- simple dependencies
- deterministic test behavior
- readable function boundaries
- documented assumptions

Avoid unnecessary dependencies.

The current external dependency is:

    numpy>=1.26.0

## 14. Pull Request Checklist

Before submitting a pull request, confirm:

- the standard self-test passes
- the relevant benchmark still runs
- candidate invariants remain valid
- documentation is updated where needed
- terminology is consistent
- simulation boundaries are respected
- no private or sensitive material is included
- no unsupported hardware claims are added

## 15. Current Status

This contribution guide is aligned with:

- FRP v0.9.3-mobile
- frp_prototype_v0_9_3_mobile.py
- TEST_REPORT_v0_9_3.md
- README.md
- INSTALL.md
- USAGE.md
- REPRODUCIBILITY.md
- SECURITY.md
- docs/limitations.md

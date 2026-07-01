# Continuous Integration

This document describes the GitHub Actions continuous integration checks used by the Fractal Resonance Processor (FRP) repository.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. CI Purpose

The CI layer verifies that the public repository remains executable after changes.

The current CI checks cover:

- dependency installation
- standard self-test execution
- benchmark command execution
- workflow status visibility through README badges

CI does not validate hardware behavior.

CI does not establish physical thermal performance or electrical switching-energy reduction.

## 2. Active Workflows

The repository currently uses two GitHub Actions workflows:

| Workflow | File | Purpose |
|---|---|---|
| FRP Self Test | .github/workflows/frp-self-test.yml | runs the standard FRP self-test |
| FRP Benchmark Smoke Test | .github/workflows/frp-benchmark-smoke.yml | verifies benchmark execution and expected architecture labels |

## 3. FRP Self Test Workflow

Workflow file:

    .github/workflows/frp-self-test.yml

The workflow runs on:

- push to main
- pull request to main
- manual workflow dispatch

The workflow installs dependencies and runs:

    python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected output condition:

    result=PASS

The workflow checks for:

    result=PASS

If this string is not present in the output, the workflow fails.

## 4. FRP Benchmark Smoke Test Workflow

Workflow file:

    .github/workflows/frp-benchmark-smoke.yml

The workflow runs on:

- push to main
- pull request to main
- manual workflow dispatch

The workflow installs dependencies and runs:

    python frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The benchmark smoke test verifies that the output includes all four comparison architectures:

- frp_distributed_resonant
- distributed_neutral_ternary
- direct_ternary_commit
- binary_style_forced_switch

This workflow verifies that benchmark execution works.

It does not enforce exact numerical benchmark values line by line.

## 5. README Badges

The root README.md displays CI status badges for:

- FRP Self Test
- FRP Benchmark Smoke Test

A green passing badge means that the latest workflow run completed successfully.

A failing badge means that the corresponding workflow failed and the logs should be inspected.

## 6. Required Dependency File

Both workflows install dependencies from:

    requirements.txt

Current external dependency:

    numpy>=1.26.0

Python standard-library modules are not listed in requirements.txt.

## 7. Candidate Invariants Checked by CI

The self-test workflow checks the current standard self-test command.

The candidate invariants covered by the standard test include:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## 8. CI Boundary

The CI layer confirms that the current Python simulation commands run successfully in GitHub Actions.

CI does not establish:

- hardware thermal efficiency
- physical electrical switching-energy reduction
- fabrication-level performance
- hardware timing behavior
- measured physical heat
- measured physical power consumption
- production readiness

All CI results remain limited to the documented Python simulation domain.

## 9. When to Update CI

Update CI workflow files when changing:

- prototype filename
- command-line interface
- dependency list
- test command
- benchmark command
- expected output markers
- workflow names
- supported Python version

If the prototype version changes, update this file together with:

- README.md
- REPRODUCIBILITY.md
- RELEASE_NOTES file
- TEST_REPORT file
- CHANGELOG.md

## 10. Current Status

The current CI layer is aligned with:

- FRP v0.9.3-mobile
- frp_prototype_v0_9_3_mobile.py
- requirements.txt
- README.md
- REPRODUCIBILITY.md
- RELEASE_NOTES_v0_9_3.md
- TEST_REPORT_v0_9_3.md
- .github/workflows/frp-self-test.yml
- .github/workflows/frp-benchmark-smoke.yml

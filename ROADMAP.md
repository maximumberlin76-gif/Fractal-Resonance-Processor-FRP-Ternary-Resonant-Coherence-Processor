# Roadmap

This document defines the public development roadmap for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Current Status

FRP v0.9.3-mobile is a public candidate simulation prototype.

Current repository state includes:

- working Python simulation prototype
- balanced ternary state model
- neutral transition routing
- forbidden direct -1 ↔ 1 transition prevention
- distributed commit
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay buffers
- scheduler modes
- per-tick telemetry
- self-test mode
- benchmark mode
- reproducibility documentation
- release notes
- citation metadata
- Apache-2.0 license
- public security and contribution policies

## 2. Stable Candidate Invariants

Future development should preserve the current candidate invariants unless the prototype version, test report, and documentation are explicitly updated.

Required invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## 3. Immediate Next Steps

Priority tasks for the next candidate layer:

- add GitHub Actions CI workflow
- run the standard self-test automatically
- add benchmark smoke test automation
- add structured JSON output option
- add version field to CLI output
- add explicit `--json` mode
- improve test report generation
- add reproducible output snapshots
- verify documentation consistency after each prototype change

## 4. v0.9.4 Target

Planned focus:

    automated verification

Expected additions:

- GitHub Actions workflow
- automated dependency installation
- automated standard self-test
- automated benchmark smoke test
- CI badge in README
- failure boundary documentation
- CI reproducibility notes

Required result:

    CI must pass the standard self-test.

## 5. v0.9.5 Target

Planned focus:

    structured output and reproducible reporting

Expected additions:

- JSON output mode
- machine-readable test summaries
- machine-readable benchmark summaries
- saved report examples
- clearer telemetry export structure
- stable output schema documentation

Possible files:

- docs/output_schema.md
- examples/json_output_example.md
- reports/

## 6. v0.9.6 Target

Planned focus:

    expanded benchmark discipline

Expected additions:

- additional seed ranges
- larger N tests
- benchmark matrix by N
- benchmark matrix by scheduler mode
- comparison of transition_fraction values
- clearer heat metric boundary
- clearer C_minus_P interpretation

Possible benchmark axes:

| Axis | Values |
|---|---|
| N | 8, 16, 32, 64 |
| steps | 128, 256, 512 |
| seeds | 5, 10, 20 |
| cycle-mode | free, 7/1, 1/7 |
| transition_fraction | 0.125, 0.25, 0.5 |

## 7. v0.9.7 Target

Planned focus:

    internal architecture cleanup

Expected additions:

- separate prototype modules
- clearer class boundaries
- separated telemetry module
- separated benchmark module
- separated baseline models
- separated CLI entry point
- preserved single-file mobile prototype as reference

Possible structure:

    frp/
      core.py
      processor.py
      telemetry.py
      benchmark.py
      baselines.py
      cli.py

## 8. v1.0.0 Target

Planned focus:

    stable public simulation release

Expected requirements:

- all public documentation aligned
- CI workflow passing
- reproducibility file updated
- release notes finalized
- citation metadata updated
- changelog updated
- test report regenerated
- benchmark report regenerated
- Zenodo archival release prepared
- DOI added after archival release

v1.0.0 should remain a simulation release unless hardware validation exists.

## 9. Research Directions

Future research directions may include:

- deeper ternary logic analysis
- alternative neutral transition schedules
- additional resonant phase coupling models
- stability comparison across nonlinear coupling forms
- expanded operational coherence metrics
- larger benchmark domains
- additional baseline models
- formal transition safety proofs
- deterministic replay mode
- report generation pipeline

## 10. Hardware Boundary

The current roadmap does not claim hardware validation.

Before any hardware-related claim is made, the project would require:

- separate hardware specification
- physical implementation model
- measurable electrical assumptions
- testable switching-energy model
- physical thermal measurement protocol
- fabrication or emulation evidence
- external validation boundary

Until then, all current claims remain limited to:

    Python simulation prototype

## 11. Documentation Roadmap

Documentation should remain aligned with:

- README.md
- INSTALL.md
- USAGE.md
- REPRODUCIBILITY.md
- TEST_REPORT_v0_9_3.md
- RELEASE_NOTES_v0_9_3.md
- CHANGELOG.md
- docs/architecture.md
- docs/benchmark_interpretation.md
- docs/limitations.md
- verification/coherence_metrics.md

Any code change that alters results must update:

- TEST_REPORT file
- REPRODUCIBILITY.md
- RELEASE_NOTES file
- benchmark interpretation where needed

## 12. Release Discipline

Each future candidate should include:

- version label
- test report
- release notes
- changelog entry
- reproducibility commands
- supported claims
- unsupported claims
- simulation boundary
- known limitations

## 13. Current Development Priority

The next practical repository task is:

    add GitHub Actions CI workflow

Target workflow:

    .github/workflows/frp-self-test.yml

The workflow should install dependencies and run:

    python3 frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

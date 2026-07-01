# Release Notes — Fractal Resonance Processor (FRP) v0.9.4

## Release Title

Fractal Resonance Processor (FRP) v0.9.4 — Structured Output and Machine-Readable Validation

## Version

v0.9.4

## Milestone

M2 — Structured Output

## Main Prototype File

frp_prototype_v0_9_4.py

## Schema Marker

frp.structured_output.v0.9.4

## License

Apache License 2.0

## Summary

FRP v0.9.4 adds the structured output layer for the Fractal Resonance Processor prototype.

This release introduces machine-readable JSON output for demo execution, self-test execution, benchmark execution, and optional per-tick telemetry export.

The processor logic remains aligned with the v0.9.3 reference model.

FRP v0.9.4 does not change the core processor model. It adds a structured validation and export layer around the existing ternary resonant coherence processor.

## Core Continuity from v0.9.3

The following processor logic is preserved:

- balanced ternary states -1, 0, 1
- neutral transition routing
- direct polarity transition safety
- distributed ternary commit
- transition fraction control
- scheduler modes free, 7/1, and 1/7
- Kuramoto-Sakaguchi resonant phase coupling
- nonlinear cubic saturation
- nonlinear compression
- logic delay buffers
- coupling delay buffers
- per-tick telemetry inside the model
- processor instruction execution
- self-test mode
- benchmark mode

The v0.9.4 release extends output and validation access without changing the tested core logic.

## New Output Controls

FRP v0.9.4 adds:

    --output text
    --output json
    --include-telemetry

Default output mode:

    --output text

Structured output mode:

    --output json

Optional telemetry export:

    --include-telemetry

The default text workflow remains available for human-readable console inspection.

The JSON workflow provides machine-readable validation output.

## Structured JSON Output

FRP v0.9.4 adds a shared JSON envelope with the following top-level markers:

    schema
    project
    version
    kind
    parameters

Current schema marker:

    frp.structured_output.v0.9.4

Current version marker:

    v0.9.4

Supported JSON output kinds:

    demo
    self_test
    benchmark

## Demo JSON Output

Demo mode can now emit structured JSON:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Demo JSON includes:

- schema marker
- project marker
- version marker
- execution parameters
- processor instruction log
- final processor report

Demo mode can also export telemetry:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

## Self-Test JSON Output

Self-test mode can now emit structured JSON:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Self-test JSON includes:

- schema marker
- project marker
- version marker
- execution parameters
- aggregate metrics
- failure count
- first failure object
- PASS or FAIL result

Expected successful markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "self_test"
    "failures": 0
    "result": "PASS"

## Benchmark JSON Output

Benchmark mode can now emit structured JSON:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Benchmark JSON includes:

- schema marker
- project marker
- version marker
- execution parameters
- architecture summaries
- benchmark-supported technical position

Current benchmark architectures:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

## Optional Telemetry Export

FRP v0.9.4 supports optional telemetry emission in JSON output.

Telemetry can include:

- tick
- scheduler phase
- Kuramoto order parameter R
- mean phase angle phi
- neutral-state fraction
- positive-state fraction
- negative-state fraction
- heat
- thermal scale
- switch load
- actual direct event delta
- prevented direct event delta
- neutralized conflict delta
- logical match
- transition debt
- direct conflict fraction
- C
- P
- C_minus_P

Telemetry export supports the later hardware-facing path:

    Python model
    → JSON telemetry
    → benchmark export
    → hardware-facing signal map
    → FPGA register map
    → testbench comparison

## CI Validation

FRP v0.9.4 adds a dedicated GitHub Actions workflow:

    FRP Structured Output

Workflow file:

    .github/workflows/frp-structured-output.yml

The workflow validates:

- Python syntax for frp_prototype_v0_9_4.py
- dependency installation
- text self-test output
- text benchmark output
- JSON self-test output
- JSON benchmark output
- JSON demo output
- JSON telemetry output
- schema marker
- version marker
- self-test PASS result
- zero actual direct transition events
- positive C_minus_P stability margin
- benchmark architecture labels
- telemetry fields required for future hardware-facing signal mapping

Observed status:

    PASS

## Existing Workflow Compatibility

Existing workflows remained compatible after adding v0.9.4 structured output:

    FRP Self Test
    FRP Benchmark Smoke Test

Observed status:

    PASS

This confirms that the new structured output layer does not break the existing validation path.

## Candidate Invariants

The current candidate invariants remain:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

In v0.9.4 these invariants can now be inspected through structured JSON output.

## Benchmark-Supported Technical Position

The benchmark-supported technical position remains:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

This position is now included in benchmark JSON output.

## Updated Documentation

The following documentation was updated for v0.9.4:

    docs/output_schema.md
    USAGE.md
    REPRODUCIBILITY.md
    CI.md

The following validation record was added:

    TEST_REPORT_v0_9_4.md

The following workflow was added:

    .github/workflows/frp-structured-output.yml

## Release Role

FRP v0.9.4 is the M2 structured output release.

Its role is to provide:

- machine-readable validation
- structured JSON output
- schema marker consistency
- self-test JSON output
- benchmark JSON output
- demo JSON output
- optional telemetry export
- CI validation for structured output
- future hardware-facing telemetry mapping path

## Release Readiness

FRP v0.9.4 is ready for:

- changelog update
- README version update
- GitHub Release v0.9.4
- Zenodo archival version record

## Final Status

FRP v0.9.4 M2 Structured Output status:

    PASS

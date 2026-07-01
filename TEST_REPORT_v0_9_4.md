# Test Report — Fractal Resonance Processor (FRP) v0.9.4

## 1. Release Target

Project:

    Fractal Resonance Processor (FRP)

Version:

    v0.9.4

Milestone:

    M2 — Structured Output

Main prototype file:

    frp_prototype_v0_9_4.py

Schema marker:

    frp.structured_output.v0.9.4

License:

    Apache License 2.0

## 2. Purpose

This test report documents the validation status of FRP v0.9.4.

FRP v0.9.4 adds the M2 structured output layer to the existing Fractal Resonance Processor prototype.

The v0.9.4 release preserves the v0.9.3 processor logic and adds:

- structured JSON output
- machine-readable schema marker
- JSON self-test output
- JSON benchmark output
- JSON demo output
- optional per-tick telemetry export
- CI validation for structured output
- telemetry path for future hardware-facing signal mapping

The processor logic, scheduler logic, transition rules, transition fraction, and Kuramoto-Sakaguchi phase-coupling layer remain aligned with the v0.9.3 reference model.

## 3. Validated Files

Current prototype:

    frp_prototype_v0_9_4.py

Documentation updated for v0.9.4:

    docs/output_schema.md
    USAGE.md
    REPRODUCIBILITY.md
    CI.md

Workflow added for v0.9.4:

    .github/workflows/frp-structured-output.yml

Reference prototype:

    frp_prototype_v0_9_3_mobile.py

Previous validation report:

    TEST_REPORT_v0_9_3.md

## 4. Structured Output Controls

FRP v0.9.4 adds the following command-line output controls:

    --output text
    --output json
    --include-telemetry

Default output mode:

    --output text

Structured output mode:

    --output json

Telemetry output control:

    --include-telemetry

Internal telemetry rule:

    telemetry_every = 1

Per-tick telemetry remains mandatory inside the model.

The `--include-telemetry` flag controls whether telemetry is emitted in JSON output.

## 5. Validation Scope

The v0.9.4 validation scope includes:

- Python syntax validation
- dependency installation
- text self-test execution
- text benchmark execution
- JSON self-test execution
- JSON benchmark execution
- JSON demo execution
- JSON telemetry execution
- JSON parsing
- schema marker validation
- version marker validation
- self-test result validation
- direct transition safety validation
- positive C_minus_P stability validation
- benchmark architecture label validation
- telemetry field validation

## 6. Candidate Invariants

The current candidate invariants remain:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

These invariants are checked internally by the self-test and exposed through structured JSON output.

## 7. Standard Text Self-Test

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Expected text markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Expected result:

    PASS

Expected validation properties:

- no self-test failures
- zero actual direct transition events
- positive C_minus_P stability margin
- telemetry length equals requested steps
- scheduler counts match selected cycle mode
- target match reaches 1.000 in tested operations

## 8. Text Benchmark

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Expected text marker:

    FRP BENCHMARK v0.9.4

Expected benchmark architecture labels:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

Expected result:

    benchmark output generated successfully

## 9. JSON Self-Test

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "self_test"
    "failures": 0
    "result": "PASS"

Expected JSON metric conditions:

    metrics.actual_direct_events = 0
    metrics.C_minus_P_min > 0

Expected result:

    PASS

## 10. JSON Benchmark

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "benchmark"

Expected architecture labels inside `architectures`:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

Expected result:

    benchmark JSON generated and validated successfully

## 11. JSON Demo

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "demo"

Expected top-level fields:

    schema
    project
    version
    kind
    parameters
    log
    final_report

Expected result:

    demo JSON generated and validated successfully

## 12. JSON Telemetry Demo

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 32 --cycle-mode 7/1 --output json --include-telemetry

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "demo"

Expected telemetry fields:

    tick
    phase
    R
    phi
    C
    P
    C_minus_P

Expected result:

    telemetry JSON generated and validated successfully

## 13. GitHub Actions Validation

Workflow:

    FRP Structured Output

Workflow file:

    .github/workflows/frp-structured-output.yml

Observed status:

    PASS

Observed run:

    FRP Structured Output #1

Validated CI stages:

- checkout repository
- set up Python
- install dependencies
- compile `frp_prototype_v0_9_4.py`
- run text self-test
- run text benchmark
- run JSON self-test
- validate JSON self-test
- run JSON benchmark
- validate JSON benchmark
- run JSON demo
- validate JSON demo
- run JSON telemetry demo
- validate JSON telemetry demo

Observed result:

    all structured-output checks passed

## 14. Existing Workflow Compatibility

Existing workflows also completed successfully on the same commit:

    FRP Self Test
    FRP Benchmark Smoke Test

Observed status:

    PASS

This confirms that adding the v0.9.4 structured output workflow did not break the existing validation path.

## 15. Technical Position Validated by Benchmark

The current benchmark-supported technical position remains:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

This position is preserved in v0.9.4 and is now available in machine-readable benchmark JSON output.

## 16. Structured Output Result

FRP v0.9.4 successfully adds a structured output layer with:

- stable schema marker
- version marker
- JSON self-test output
- JSON benchmark output
- JSON demo output
- optional telemetry export
- machine-readable validation fields
- CI validation path

Current schema marker:

    frp.structured_output.v0.9.4

Current version marker:

    v0.9.4

Current structured-output milestone status:

    PASS

## 17. Hardware-Facing Relevance

The v0.9.4 structured output layer establishes the data path required for later hardware-facing stages.

Current path:

    Python model
    → JSON telemetry
    → benchmark export
    → hardware-facing signal map
    → FPGA register map
    → testbench comparison

This release does not implement FPGA logic.

It prepares the machine-readable validation layer required before FPGA mapping.

## 18. Final Result

FRP v0.9.4 M2 Structured Output validation result:

    PASS

Release readiness:

    ready for release notes
    ready for changelog update
    ready for README version update
    ready for GitHub Release v0.9.4 preparation

# Reproducibility — Fractal Resonance Processor (FRP)

This document defines the reproducibility procedure for the Fractal Resonance Processor (FRP) prototype.

Current structured-output version:

    v0.9.4

Current prototype file:

    frp_prototype_v0_9_4.py

Previous reference prototype:

    frp_prototype_v0_9_3_mobile.py

Current schema marker:

    frp.structured_output.v0.9.4

## 1. Purpose

FRP v0.9.4 adds structured machine-readable output to the existing reproducibility workflow.

The purpose of this document is to make the current FRP results reproducible through:

- installation commands
- text self-test execution
- text benchmark execution
- JSON self-test execution
- JSON benchmark execution
- JSON schema inspection
- telemetry export checks
- CI-oriented validation commands

The v0.9.4 reproducibility layer preserves the v0.9.3 processor logic while adding structured output for automated validation and future hardware-facing comparison.

## 2. Environment

Recommended environment:

    Python 3.10 or newer

Install dependencies from the repository root:

    pip install -r requirements.txt

Current dependency:

    numpy>=1.26.0

## 3. Files Required

Required files for v0.9.4 reproducibility:

    frp_prototype_v0_9_4.py
    requirements.txt
    docs/output_schema.md
    USAGE.md
    REPRODUCIBILITY.md

Reference validation files:

    frp_prototype_v0_9_3_mobile.py
    TEST_REPORT_v0_9_3.md

## 4. Reproducibility Scope

Current reproducibility scope:

    software validation layer
    structured output layer
    benchmark layer
    CI verification layer
    telemetry export layer

The current reproducibility package verifies:

- executable Python reference model
- balanced ternary state behavior
- neutral transition routing
- direct polarity transition safety
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- self-test result
- benchmark result
- JSON output parsing
- schema marker
- machine-readable validation markers

## 5. Standard Text Self-Test

Run:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Expected text markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Expected candidate result:

    PASS

Expected invariant state:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

## 6. Heavy Text Self-Test

Run:

    python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10

Expected text markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Expected candidate result:

    PASS

This command provides a heavier validation profile over more steps and seeds.

## 7. Standard Text Benchmark

Run:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Expected text marker:

    FRP BENCHMARK v0.9.4

Expected benchmark architecture labels:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

The benchmark compares FRP distributed resonant behavior against baseline transition architectures.

## 8. JSON Self-Test

Run:

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
    metrics.switch_load_peak <= transition_fraction

## 9. JSON Benchmark

Run:

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

Expected benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

## 10. JSON Demo

Run:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "demo"

Expected top-level demo fields:

    schema
    project
    version
    kind
    parameters
    log
    final_report

## 11. JSON Demo With Telemetry

Run:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

Expected behavior:

    operation results inside the demo log include telemetry arrays where applicable

Telemetry fields include:

- tick
- phase
- R
- phi
- neutral
- positive
- negative
- heat
- thermal_scale
- switch_load
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- logical_match
- transition_debt
- direct_conflict_fraction
- C
- P
- C_minus_P

Telemetry role:

    Python model
    → JSON telemetry
    → benchmark export
    → hardware-facing signal map
    → FPGA register map
    → testbench comparison

## 12. JSON File Export

Export self-test JSON:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json > frp_self_test_v0_9_4.json

Inspect self-test JSON:

    python3 -m json.tool frp_self_test_v0_9_4.json

Export benchmark JSON:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json > frp_benchmark_v0_9_4.json

Inspect benchmark JSON:

    python3 -m json.tool frp_benchmark_v0_9_4.json

Export demo telemetry JSON:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry > frp_demo_telemetry_v0_9_4.json

Inspect demo telemetry JSON:

    python3 -m json.tool frp_demo_telemetry_v0_9_4.json

## 13. Machine-Readable Self-Test Validation

A successful self-test JSON output must satisfy:

| Field | Required Value |
|---|---|
| `schema` | `frp.structured_output.v0.9.4` |
| `version` | `v0.9.4` |
| `kind` | `self_test` |
| `result` | `PASS` |
| `failures` | `0` |
| `metrics.actual_direct_events` | `0` |
| `metrics.C_minus_P_min` | greater than `0` |

The following command can be used for manual inspection:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

## 14. Machine-Readable Benchmark Validation

A successful benchmark JSON output must satisfy:

| Field | Required Value |
|---|---|
| `schema` | `frp.structured_output.v0.9.4` |
| `version` | `v0.9.4` |
| `kind` | `benchmark` |

The benchmark architecture list must contain:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

The following command can be used for manual inspection:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

## 15. Scheduler Reproducibility

Scheduler modes:

| Mode | Behavior |
|---|---|
| `free` | commit every tick |
| `7/1` | seven balance ticks and one commit tick |
| `1/7` | one excite tick and seven neutralize ticks |

The self-test checks scheduler counts against expected scheduler behavior.

For a selected number of steps, expected scheduler counts are computed internally and compared with observed counts.

Scheduler mismatch is reported as a failure.

## 16. Operational Domain

The tested operational domain remains:

    N >= 8

The standard self-test uses:

    N = 8, 16, 32, 64

Default transition fraction:

    transition_fraction = 0.25

Default Kuramoto-Sakaguchi phase shift:

    gamma = 0.30 pi

Default telemetry interval:

    telemetry_every = 1

Telemetry rule:

    per-tick telemetry is mandatory in the internal model

Output rule:

    --include-telemetry controls whether telemetry is emitted in JSON output

## 17. Baseline Comparison

The benchmark compares:

| Architecture | Role |
|---|---|
| `binary_style_forced_switch` | binary-style forced switch baseline |
| `direct_ternary_commit` | direct ternary commit baseline |
| `distributed_neutral_ternary` | distributed neutral ternary baseline |
| `frp_distributed_resonant` | FRP distributed resonant mode |

Benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

## 18. Expected v0.9.4 Role

FRP v0.9.4 provides the M2 structured output layer.

This release stage adds:

- JSON self-test output
- JSON benchmark output
- JSON demo output
- optional telemetry export
- machine-readable schema marker
- reproducibility inspection commands
- CI-oriented JSON validation path

The v0.9.4 layer prepares the project for:

- expanded benchmark profiles
- automated result comparison
- structured telemetry export
- hardware-facing signal mapping
- FPGA register mapping
- testbench comparison

## 19. Recommended Reproducibility Sequence

Run the following sequence from the repository root:

    pip install -r requirements.txt

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

    python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

Expected overall result:

    text self-test PASS
    heavy text self-test PASS
    benchmark architecture labels present
    JSON self-test parses successfully
    JSON benchmark parses successfully
    JSON demo telemetry parses successfully

## 20. Current Status

FRP v0.9.4 reproducibility confirms the structured output layer.

Current reproducibility path supports:

- text validation
- JSON validation
- benchmark inspection
- telemetry export
- schema marker inspection
- CI-oriented structured checks
- future hardware-facing comparison workflow

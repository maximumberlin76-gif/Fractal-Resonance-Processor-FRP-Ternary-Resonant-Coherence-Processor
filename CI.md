# CI — Fractal Resonance Processor (FRP)

This document defines the current Continuous Integration validation path for the Fractal Resonance Processor (FRP) prototype.

Current structured-output version:

    v0.9.4

Current prototype file:

    frp_prototype_v0_9_4.py

Previous reference prototype:

    frp_prototype_v0_9_3_mobile.py

Current schema marker:

    frp.structured_output.v0.9.4

## 1. Purpose

FRP v0.9.4 adds structured machine-readable output to the CI validation path.

The CI layer validates:

- executable Python prototype
- dependency installation
- text self-test execution
- text benchmark execution
- JSON self-test execution
- JSON benchmark execution
- JSON parsing
- schema marker consistency
- version marker consistency
- self-test PASS result
- zero failure count
- direct transition safety
- positive stability margin
- benchmark architecture labels

The v0.9.4 CI layer does not change the processor logic.

It adds machine-readable validation around the existing FRP model.

## 2. CI Validation Layers

Current CI validation layers:

| Layer | Role |
|---|---|
| dependency layer | installs Python dependencies |
| syntax layer | verifies Python file execution |
| text self-test layer | checks console self-test output |
| text benchmark layer | checks console benchmark output |
| JSON self-test layer | checks machine-readable self-test output |
| JSON benchmark layer | checks machine-readable benchmark output |
| schema layer | checks structured output marker |
| invariant layer | checks critical validation markers |

## 3. Required Files

Current CI-relevant files:

    frp_prototype_v0_9_4.py
    requirements.txt
    USAGE.md
    REPRODUCIBILITY.md
    docs/output_schema.md
    CI.md

Reference files:

    frp_prototype_v0_9_3_mobile.py
    TEST_REPORT_v0_9_3.md

Expected workflow directory:

    .github/workflows/

## 4. Dependency Installation

CI should install dependencies from the repository root:

    pip install -r requirements.txt

Current dependency:

    numpy>=1.26.0

Recommended Python version:

    Python 3.10 or newer

## 5. Text Self-Test Check

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Expected markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Required CI conditions:

- process exits with code 0
- output contains `FRP SELF TEST v0.9.4`
- output contains `failures=0`
- output contains `result=PASS`

## 6. Heavy Text Self-Test Check

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10

Expected markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Required CI conditions:

- process exits with code 0
- output contains `FRP SELF TEST v0.9.4`
- output contains `failures=0`
- output contains `result=PASS`

## 7. Text Benchmark Check

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Expected marker:

    FRP BENCHMARK v0.9.4

Expected benchmark architecture labels:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

Required CI conditions:

- process exits with code 0
- output contains `FRP BENCHMARK v0.9.4`
- output contains all four benchmark architecture labels

## 8. JSON Self-Test Check

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "self_test"
    "failures": 0
    "result": "PASS"

Required CI conditions:

- process exits with code 0
- output parses as JSON
- `schema` equals `frp.structured_output.v0.9.4`
- `version` equals `v0.9.4`
- `kind` equals `self_test`
- `result` equals `PASS`
- `failures` equals `0`
- `metrics.actual_direct_events` equals `0`
- `metrics.C_minus_P_min` is greater than `0`

## 9. JSON Benchmark Check

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "benchmark"

Expected benchmark architecture labels:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

Required CI conditions:

- process exits with code 0
- output parses as JSON
- `schema` equals `frp.structured_output.v0.9.4`
- `version` equals `v0.9.4`
- `kind` equals `benchmark`
- `architectures` contains all four benchmark architecture labels

## 10. JSON Demo Check

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "demo"

Required CI conditions:

- process exits with code 0
- output parses as JSON
- `schema` equals `frp.structured_output.v0.9.4`
- `version` equals `v0.9.4`
- `kind` equals `demo`
- `log` exists
- `final_report` exists

## 11. JSON Telemetry Check

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 32 --cycle-mode 7/1 --output json --include-telemetry

Expected JSON markers:

    "schema": "frp.structured_output.v0.9.4"
    "version": "v0.9.4"
    "kind": "demo"

Expected telemetry behavior:

    operation results include telemetry arrays where applicable

Required CI conditions:

- process exits with code 0
- output parses as JSON
- at least one operation result contains telemetry
- telemetry records contain `tick`
- telemetry records contain `phase`
- telemetry records contain `R`
- telemetry records contain `C_minus_P`

## 12. Candidate Invariants Checked by CI

Current candidate invariants:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

The text self-test checks these internally.

The JSON self-test exposes the relevant aggregate markers for machine-readable inspection.

## 13. Recommended GitHub Actions Workflow

Recommended workflow file:

    .github/workflows/frp-structured-output.yml

Recommended workflow name:

    FRP Structured Output

Recommended workflow jobs:

- checkout repository
- set up Python
- install dependencies
- run text self-test
- run text benchmark
- run JSON self-test
- validate JSON self-test markers
- run JSON benchmark
- validate JSON benchmark markers
- run JSON demo
- validate JSON demo markers
- run JSON telemetry demo
- validate telemetry markers

## 14. Minimal CI Commands

Minimal command set:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

## 15. Recommended CI Validation Script Snippets

Self-test JSON validation:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json > frp_self_test_v0_9_4.json

    python3 - <<'PY'
    import json

    with open("frp_self_test_v0_9_4.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    assert data["schema"] == "frp.structured_output.v0.9.4"
    assert data["version"] == "v0.9.4"
    assert data["kind"] == "self_test"
    assert data["result"] == "PASS"
    assert data["failures"] == 0
    assert data["metrics"]["actual_direct_events"] == 0
    assert data["metrics"]["C_minus_P_min"] > 0.0

    print("self-test JSON validation PASS")
    PY

Benchmark JSON validation:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json > frp_benchmark_v0_9_4.json

    python3 - <<'PY'
    import json

    with open("frp_benchmark_v0_9_4.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    assert data["schema"] == "frp.structured_output.v0.9.4"
    assert data["version"] == "v0.9.4"
    assert data["kind"] == "benchmark"

    expected = {
        "binary_style_forced_switch",
        "direct_ternary_commit",
        "distributed_neutral_ternary",
        "frp_distributed_resonant",
    }

    got = {row["architecture"] for row in data["architectures"]}

    assert expected.issubset(got)

    print("benchmark JSON validation PASS")
    PY

Demo JSON validation:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json > frp_demo_v0_9_4.json

    python3 - <<'PY'
    import json

    with open("frp_demo_v0_9_4.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    assert data["schema"] == "frp.structured_output.v0.9.4"
    assert data["version"] == "v0.9.4"
    assert data["kind"] == "demo"
    assert isinstance(data["log"], list)
    assert isinstance(data["final_report"], dict)

    print("demo JSON validation PASS")
    PY

Telemetry JSON validation:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 32 --cycle-mode 7/1 --output json --include-telemetry > frp_demo_telemetry_v0_9_4.json

    python3 - <<'PY'
    import json

    with open("frp_demo_telemetry_v0_9_4.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    assert data["schema"] == "frp.structured_output.v0.9.4"
    assert data["version"] == "v0.9.4"
    assert data["kind"] == "demo"

    telemetry_found = False

    for row in data["log"]:
        result = row.get("result")
        if not result:
            continue

        telemetry = result.get("telemetry")
        if telemetry:
            telemetry_found = True
            first = telemetry[0]
            assert "tick" in first
            assert "phase" in first
            assert "R" in first
            assert "C_minus_P" in first
            break

    assert telemetry_found

    print("telemetry JSON validation PASS")
    PY

## 16. Current Workflow Relationship

Existing v0.9.3 workflows may continue to validate the previous reference prototype.

The v0.9.4 structured-output workflow should validate:

    frp_prototype_v0_9_4.py

Recommended workflow separation:

| Workflow | Prototype | Role |
|---|---|---|
| FRP Self Test | v0.9.3 or current reference | text self-test |
| FRP Benchmark Smoke Test | v0.9.3 or current reference | benchmark smoke check |
| FRP Structured Output | v0.9.4 | JSON and structured-output validation |

## 17. Release Gate for v0.9.4

Before publishing v0.9.4, CI should confirm:

- text self-test passes
- heavy text self-test passes
- text benchmark runs
- JSON self-test parses
- JSON self-test passes
- JSON benchmark parses
- JSON benchmark contains all architecture labels
- JSON demo parses
- JSON telemetry demo contains telemetry records
- documentation references v0.9.4 consistently

Recommended release gate:

    all v0.9.4 structured-output checks pass on GitHub Actions

## 18. Current Status

FRP v0.9.4 CI validates the M2 structured output layer.

Current CI path supports:

- text validation
- JSON validation
- schema marker validation
- version marker validation
- self-test invariant inspection
- benchmark architecture inspection
- telemetry export inspection
- future hardware-facing testbench comparison path

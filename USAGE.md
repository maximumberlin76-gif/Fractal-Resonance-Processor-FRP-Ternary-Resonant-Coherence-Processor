# Usage — Fractal Resonance Processor (FRP)

This document describes how to run the current Fractal Resonance Processor (FRP) prototype.

Current structured-output version:

    v0.9.4

Current prototype file:

    frp_prototype_v0_9_4.py

Previous reference prototype:

    frp_prototype_v0_9_3_mobile.py

Current schema marker:

    frp.structured_output.v0.9.4

## 1. Purpose

FRP v0.9.4 adds structured machine-readable output while preserving the existing text console workflow.

The prototype can be used for:

- demonstration execution
- standard self-test execution
- benchmark execution
- JSON self-test summary
- JSON benchmark summary
- JSON demo execution log
- optional per-tick telemetry export
- reproducibility checks
- CI verification
- future hardware-facing signal mapping
- future FPGA/testbench comparison

The v0.9.4 usage layer does not change the FRP processor logic.

It adds structured output controls around the existing model.

## 2. Installation

Install dependencies from the repository root:

    pip install -r requirements.txt

Current dependency:

    numpy>=1.26.0

## 3. Basic Command Structure

General command form:

    python3 frp_prototype_v0_9_4.py --mode <mode> [options]

Available modes:

| Mode | Role |
|---|---|
| `demo` | runs a demonstration program |
| `test` | runs the FRP self-test suite |
| `bench` | runs the benchmark comparison |

Output options:

| Option | Role |
|---|---|
| `--output text` | human-readable console output |
| `--output json` | structured machine-readable JSON output |
| `--include-telemetry` | includes per-tick telemetry in JSON where applicable |

Default output mode:

    --output text

## 4. Quick Start

Run a demonstration:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Run the standard self-test:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Run the heavier self-test:

    python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10

Run the benchmark:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Run the standard self-test as JSON:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Run the benchmark as JSON:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Run a demo with JSON telemetry:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

## 5. CLI Options

Current command-line options:

| Option | Values | Default | Role |
|---|---|---|---|
| `--mode` | `demo`, `test`, `bench` | `demo` | execution mode |
| `--N` | integer | `32` | number of ternary cells for demo mode |
| `--steps` | integer | `128` | number of execution ticks |
| `--seeds` | integer | `5` | number of seeds for test and benchmark modes |
| `--seed` | integer | `42` | seed for demo mode |
| `--amp` | number | `0.30` | external drive amplitude |
| `--cycle-mode` | `free`, `7/1`, `1/7` | `7/1` | scheduler mode |
| `--gamma` | number | `0.30 pi` | Kuramoto-Sakaguchi phase shift |
| `--logic-delay-ticks` | integer or null | `None` | logic delay override |
| `--coupling-delay-ticks` | integer or null | `None` | coupling delay override |
| `--saturation-beta` | number | `0.75` | nonlinear saturation parameter |
| `--compression-gain` | number | `1.20` | nonlinear compression gain |
| `--transition-fraction` | number | `0.25` | maximum transition fraction per tick |
| `--telemetry-every` | integer | `1` | telemetry interval |
| `--stop-on-fail` | flag | disabled | stop test on first failure |
| `--output` | `text`, `json` | `text` | output format |
| `--include-telemetry` | flag | disabled | include per-tick telemetry in JSON output |

Telemetry interval rule:

    telemetry_every must be 1

Per-tick telemetry is mandatory in the internal model.

The `--include-telemetry` flag controls whether telemetry is printed in JSON output.

## 6. Scheduler Modes

FRP supports three scheduler modes.

| Mode | Behavior |
|---|---|
| `free` | commit every tick |
| `7/1` | seven balance ticks and one commit tick |
| `1/7` | one excite tick and seven neutralize ticks |

### 6.1 Free Mode

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --cycle-mode free

Role:

    every tick allows commit behavior

### 6.2 7/1 Mode

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --cycle-mode 7/1

Role:

    ticks 0 through 6 are balance ticks
    tick 7 is a commit tick

The 7/1 scheduler separates preparation from commitment.

### 6.3 1/7 Mode

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --cycle-mode 1/7

Role:

    tick 0 is an excite tick
    ticks 1 through 7 are neutralize ticks

The 1/7 scheduler separates excitation from recovery and damping.

## 7. Demo Mode

Demo mode runs a small processor program using the register file and instruction layer.

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

The demo program executes:

- `load`
- `add`
- `sub`
- `neg`
- `compare`
- `consensus`
- `halt`

Text output includes:

- program counter
- operation
- instruction status
- match
- C_minus_P minimum
- heat peak
- switch peak
- actual direct events
- prevented direct events
- neutralized conflicts
- final register report

Demo JSON command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Demo JSON with telemetry:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

Demo JSON top-level fields:

- `schema`
- `project`
- `version`
- `kind`
- `parameters`
- `log`
- `final_report`

Expected `kind`:

    demo

Expected schema:

    frp.structured_output.v0.9.4

## 8. Self-Test Mode

Self-test mode runs FRP operations across vector sizes, seeds, scheduler modes, and ternary operations.

Standard self-test command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Expected result:

    result=PASS

Heavy self-test command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10

Expected result:

    result=PASS

Self-test operations:

- `neg`
- `add`
- `sub`
- `compare`
- `consensus`

Self-test scheduler modes:

- `free`
- `7/1`
- `1/7`

Self-test vector sizes:

- `8`
- `16`
- `32`
- `64`

Self-test text output includes:

- aggregate metrics
- failure count
- final result marker

Important text markers:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

## 9. Self-Test JSON Output

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Expected JSON fields:

- `schema`
- `project`
- `version`
- `kind`
- `parameters`
- `metrics`
- `failures`
- `first_failure`
- `result`

Expected values:

    schema = frp.structured_output.v0.9.4
    version = v0.9.4
    kind = self_test
    result = PASS
    failures = 0

Expected invariant checks:

    metrics.actual_direct_events = 0
    metrics.C_minus_P_min > 0
    metrics.switch_load_peak <= transition_fraction

Self-test JSON with telemetry on first failure path:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json --include-telemetry --stop-on-fail

The `--include-telemetry` flag adds telemetry to the first failure object when a failure is present.

## 10. Benchmark Mode

Benchmark mode compares FRP against baseline architectures.

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Benchmark architectures:

- `binary_style_forced_switch`
- `direct_ternary_commit`
- `distributed_neutral_ternary`
- `frp_distributed_resonant`

Text output includes:

- architecture name
- case count
- match
- C_minus_P minimum
- heat peak
- switch peak
- actual direct events
- prevented direct events
- neutralized conflicts

Important text markers:

    FRP BENCHMARK v0.9.4
    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

## 11. Benchmark JSON Output

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Expected JSON fields:

- `schema`
- `project`
- `version`
- `kind`
- `parameters`
- `architectures`
- `benchmark_supported_position`

Expected values:

    schema = frp.structured_output.v0.9.4
    version = v0.9.4
    kind = benchmark

Each architecture entry contains:

- `architecture`
- `cases`
- `match`
- `C_minus_P_min`
- `heat_peak`
- `switch_load_peak`
- `actual_direct_events_total`
- `prevented_direct_events_total`
- `neutralized_conflicts_total`

Benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

## 12. Candidate Invariants

The current FRP candidate invariants are:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

In v0.9.4 these invariants can be inspected through both text output and JSON output.

## 13. Structured Output Validation Commands

Validate self-test JSON manually:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Validate benchmark JSON manually:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Validate demo JSON manually:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Validate demo JSON with telemetry:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

## 14. Python JSON Inspection Examples

Self-test JSON can be inspected with Python:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json > frp_self_test_v0_9_4.json

    python3 -m json.tool frp_self_test_v0_9_4.json

Benchmark JSON can be inspected with Python:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json > frp_benchmark_v0_9_4.json

    python3 -m json.tool frp_benchmark_v0_9_4.json

## 15. Text Compatibility Commands

The previous console workflow remains available.

Self-test text command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

Benchmark text command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

Demo text command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

This allows existing text-based checks to continue while structured JSON validation is added.

## 16. Operational Domain

The tested operational domain remains:

    N >= 8

The self-test uses:

    N = 8, 16, 32, 64

The default transition cap is:

    transition_fraction = 0.25

The default Kuramoto-Sakaguchi phase shift is:

    gamma = 0.30 pi

The default telemetry rule is:

    telemetry_every = 1

## 17. Output Schema Reference

For the detailed structured output schema, see:

    docs/output_schema.md

That document defines:

- shared JSON envelope
- parameters object
- demo JSON output
- self-test JSON output
- benchmark JSON output
- operation result object
- summary object
- diagnostic object
- telemetry object
- JSON validation markers
- CI-oriented validation checks

## 18. Current Status

FRP v0.9.4 adds the M2 structured output layer.

Current usage layer supports:

- text demo output
- text self-test output
- text benchmark output
- JSON demo output
- JSON self-test output
- JSON benchmark output
- optional telemetry export
- machine-readable schema marker
- reproducibility inspection
- CI-oriented validation
- future hardware-facing telemetry mapping

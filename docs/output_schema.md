# Output Schema

This document describes the current output structure of the Fractal Resonance Processor (FRP) v0.9.3-mobile Python simulation prototype.

Current candidate version:

    v0.9.3-mobile

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

FRP is currently implemented as a Python simulation prototype of a ternary resonant coherence processor.

It is not a hardware implementation.

## 1. Scope

The current prototype produces console output.

It does not yet provide a formal JSON output mode.

This document describes:

- current command output structure
- expected output fields
- test output markers
- benchmark output markers
- candidate invariant fields
- future JSON output direction

## 2. Command Modes

The prototype supports three command modes:

| Mode | Purpose |
|---|---|
| demo | run a small processor demonstration program |
| test | run self-test verification |
| bench | run benchmark comparison |

General command format:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode <mode> [options]

## 3. Common Command Options

| Option | Meaning |
|---|---|
| --mode | execution mode |
| --N | number of ternary nodes |
| --steps | internal simulation ticks |
| --seeds | number of random seeds for test or benchmark |
| --cycle-mode | scheduler mode |

Supported scheduler modes:

| Mode | Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

## 4. Demo Output

Demo command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode demo --N 16 --steps 128 --cycle-mode 7/1

Demo output is intended for human-readable inspection.

It may include:

- program execution summary
- register operation results
- target-oriented ternary execution
- telemetry summary
- final state information

Demo output is not currently treated as the authoritative verification output.

For reproducibility and release validation, use test mode and benchmark mode.

## 5. Test Output

Standard self-test command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

Required final marker:

    result=PASS

The GitHub Actions self-test workflow checks for:

    result=PASS

If this marker is missing, the CI self-test fails.

## 6. Standard Test Expected Fields

The standard test summary should include the following fields:

| Field | Meaning |
|---|---|
| runs | number of executed test runs |
| C_minus_P_min | minimum observed stability margin |
| heat_peak | maximum simulated heat metric |
| switch_load_peak | maximum transition load |
| actual_direct_events | actual forbidden direct -1 ↔ 1 events |
| prevented_direct_events | direct conflicts prevented by transition logic |
| neutralized_conflicts | conflicts routed through neutral 0 |
| failures | failed test cases |
| result | PASS or FAIL |

Expected standard summary:

| Field | Expected Value |
|---|---:|
| runs | 300 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 3820 |
| neutralized_conflicts | 2392 |
| failures | 0 |
| result | PASS |

## 7. Heavy Test Output

Heavy self-test command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 256 --seeds 10

Required final marker:

    result=PASS

Expected heavy summary:

| Field | Expected Value |
|---|---:|
| runs | 600 |
| C_minus_P_min | 0.14475 |
| heat_peak | 0.10700 |
| switch_load_peak | 0.25 |
| actual_direct_events | 0 |
| prevented_direct_events | 7913 |
| neutralized_conflicts | 4921 |
| failures | 0 |
| result | PASS |

## 8. Benchmark Output

Benchmark command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

The benchmark output must include all four comparison architectures:

- frp_distributed_resonant
- distributed_neutral_ternary
- direct_ternary_commit
- binary_style_forced_switch

The GitHub Actions benchmark smoke test checks for these architecture labels.

## 9. Benchmark Fields

The benchmark summary uses the following fields:

| Field | Meaning |
|---|---|
| Architecture | compared architecture or transition model |
| Match | final target match |
| C-P_min | minimum observed C_minus_P value |
| Heat Peak | maximum simulated heat metric |
| Switch Peak | maximum transition load |
| Actual Direct | actual forbidden direct -1 ↔ 1 events |
| Prevented Direct | direct conflicts prevented by transition logic |
| Neutralized | conflicts routed through neutral 0 |

Expected benchmark summary:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| binary_style_forced_switch | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| direct_ternary_commit | 1.000 | -0.551000 | 0.051000 | 1.000000 | 2052 | 0 | 0 |
| distributed_neutral_ternary | 1.000 | 0.174750 | 0.003250 | 0.250000 | 0 | 0 | 2052 |
| frp_distributed_resonant | 1.000 | 0.144750 | 0.107000 | 0.250000 | 0 | 3820 | 2392 |

## 10. Candidate Invariant Fields

The current output fields support the following candidate invariants:

| Invariant | Field | Required Result |
|---|---|---|
| target match | match / Match | 1.000 |
| direct transition safety | actual_direct_events / Actual Direct | 0 |
| stability | C_minus_P_min / C-P_min | greater than 0 |
| transition load | switch_load_peak / Switch Peak | less than or equal to transition_fraction |
| telemetry | ticks_recorded | equal to steps |
| scheduler | scheduler counts | match selected cycle mode |

## 11. Direct Transition Safety Output

The most important safety field is:

    actual_direct_events

Required value:

    0

Meaning:

    no actual direct -1 ↔ 1 transitions occurred during execution

Related fields:

| Field | Meaning |
|---|---|
| prevented_direct_events | direct polarity conflicts prevented before direct transition occurred |
| neutralized_conflicts | polarity conflicts routed through neutral 0 |

## 12. Stability Output

The stability margin is reported as:

    C_minus_P_min

or in benchmark tables as:

    C-P_min

Required condition:

    C_minus_P_min > 0

Interpretation:

    operational coherence remains above destabilizing load during the tested run

In the current prototype:

    P = heat + switch_load

## 13. Transition Load Output

The transition load is reported as:

    switch_load_peak

or in benchmark tables as:

    Switch Peak

Default transition cap:

    transition_fraction = 0.25

Required condition:

    switch_load_peak <= transition_fraction

Expected value in the current candidate:

    0.25

## 14. Current CI Output Checks

Current CI workflows do not enforce every numerical value line by line.

Current CI checks:

| Workflow | Output Check |
|---|---|
| FRP Self Test | checks for result=PASS |
| FRP Benchmark Smoke Test | checks for all four benchmark architecture labels |

Workflow files:

- ../.github/workflows/frp-self-test.yml
- ../.github/workflows/frp-benchmark-smoke.yml

## 15. Future JSON Output Direction

A future prototype version may add a formal JSON output mode.

Possible command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5 --json

This mode does not exist in the current v0.9.3-mobile candidate.

A future JSON test output may use a structure similar to:

    {
      "version": "v0.9.3-mobile",
      "mode": "test",
      "steps": 128,
      "seeds": 5,
      "runs": 300,
      "C_minus_P_min": 0.14475,
      "heat_peak": 0.10700,
      "switch_load_peak": 0.25,
      "actual_direct_events": 0,
      "prevented_direct_events": 3820,
      "neutralized_conflicts": 2392,
      "failures": 0,
      "result": "PASS"
    }

A future JSON benchmark output may use a structure similar to:

    {
      "version": "v0.9.3-mobile",
      "mode": "bench",
      "steps": 128,
      "seeds": 5,
      "architectures": [
        {
          "name": "frp_distributed_resonant",
          "match": 1.000,
          "C_minus_P_min": 0.144750,
          "heat_peak": 0.107000,
          "switch_peak": 0.250000,
          "actual_direct": 0,
          "prevented_direct": 3820,
          "neutralized": 2392
        }
      ]
    }

These JSON examples are forward-looking schema sketches.

They are not current CLI output.

## 16. Output Boundary

Current output values are simulation values.

They do not represent:

- measured physical heat
- measured physical power consumption
- physical electrical switching energy
- hardware timing behavior
- chip fabrication performance
- production deployment metrics

All current output interpretation remains limited to the Python simulation domain.

## 17. Update Rule

This file must be updated if any of the following change:

- command-line output format
- field names
- benchmark architecture labels
- test summary format
- CI output checks
- result marker
- prototype version
- JSON output support
- telemetry export behavior

## 18. Current Status

The current output schema documentation is aligned with:

- ../frp_prototype_v0_9_3_mobile.py
- ../TEST_REPORT_v0_9_3.md
- ../REPRODUCIBILITY.md
- ../USAGE.md
- ../CI.md
- ../.github/workflows/frp-self-test.yml
- ../.github/workflows/frp-benchmark-smoke.yml

# Output Schema — Fractal Resonance Processor (FRP)

This document defines the current console and structured output schema for the Fractal Resonance Processor (FRP) prototype.

Current structured-output version:

    v0.9.4

Current schema marker:

    frp.structured_output.v0.9.4

Current prototype file:

    frp_prototype_v0_9_4.py

Previous reference prototype:

    frp_prototype_v0_9_3_mobile.py

## 1. Purpose

FRP v0.9.4 adds machine-readable structured output while preserving the existing console workflow.

The purpose of the structured output layer is to make FRP execution results usable for:

- automated validation
- reproducibility checks
- benchmark inspection
- telemetry export
- CI verification
- external tooling
- future hardware-facing signal mapping
- future FPGA testbench comparison
- future ASIC validation comparison

The v0.9.4 structured output layer does not change the processor logic.

It adds output control around the existing FRP model.

## 2. Output Modes

The prototype supports two output formats:

| Output Mode | CLI Option | Role |
|---|---|---|
| text | `--output text` | human-readable console output |
| json | `--output json` | machine-readable structured output |

Default mode:

    --output text

Structured output mode:

    --output json

Optional telemetry inclusion:

    --include-telemetry

## 3. Command-Line Output Controls

Current output-related CLI arguments:

| Argument | Values | Default | Role |
|---|---|---|---|
| `--output` | `text`, `json` | `text` | selects console or structured output |
| `--include-telemetry` | flag | disabled | includes per-tick telemetry in JSON where applicable |

Example:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Example with telemetry:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry

## 4. Shared JSON Envelope

All JSON outputs use a shared top-level structure.

Common top-level fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | structured output schema marker |
| `project` | string | project name |
| `version` | string | prototype version |
| `kind` | string | output kind |
| `parameters` | object | command-line execution parameters |

Current schema value:

    frp.structured_output.v0.9.4

Current project value:

    Fractal Resonance Processor

Current version value:

    v0.9.4

Possible `kind` values:

| Kind | Mode |
|---|---|
| `demo` | `--mode demo` |
| `self_test` | `--mode test` |
| `benchmark` | `--mode bench` |

## 5. Parameters Object

The `parameters` object records the execution profile.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `mode` | string | selected execution mode |
| `N` | integer | number of ternary cells for demo mode |
| `steps` | integer | number of execution ticks |
| `seeds` | integer | number of seeds for test and benchmark modes |
| `seed` | integer | seed for demo mode |
| `amp` | number | external drive amplitude |
| `cycle_mode` | string | scheduler mode |
| `gamma` | number | Kuramoto-Sakaguchi phase shift |
| `logic_delay_ticks` | integer or null | logic delay buffer length override |
| `coupling_delay_ticks` | integer or null | coupling delay buffer length override |
| `saturation_beta` | number | nonlinear cubic saturation parameter |
| `compression_gain` | number | nonlinear compression gain |
| `transition_fraction` | number | maximum transition fraction per tick |
| `telemetry_every` | integer | telemetry interval, currently required to be 1 |
| `output` | string | selected output mode |
| `include_telemetry` | boolean | telemetry inclusion flag |
| `stop_on_fail` | boolean | stop self-test on first failure |

Current scheduler values:

| Value | Meaning |
|---|---|
| `free` | commit every tick |
| `7/1` | seven balance ticks and one commit tick |
| `1/7` | one excite tick and seven neutralize ticks |

Current default phase shift:

    gamma = 0.30 pi

Current default transition fraction:

    transition_fraction = 0.25

## 6. Demo JSON Output

Command:

    python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json

Top-level demo fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | schema marker |
| `project` | string | project name |
| `version` | string | prototype version |
| `kind` | string | `demo` |
| `parameters` | object | execution parameters |
| `log` | array | processor instruction execution log |
| `final_report` | object | final processor report |

Demo `log` entries contain:

| Field | Type | Meaning |
|---|---|---|
| `pc` | integer | program counter |
| `instruction` | object | executed instruction |
| `status` | string | instruction status |
| `failures` | array | instruction-level failures |
| `result` | object or null | FRP operation result |

Instruction object fields:

| Field | Type | Meaning |
|---|---|---|
| `op` | string | instruction operation |
| `dst` | string | destination register |
| `src_a` | string | first source register |
| `src_b` | string | second source register |
| `imm` | array or null | immediate ternary vector |
| `comment` | string | optional instruction comment |

Supported processor instructions:

- `load`
- `rand`
- `zero`
- `mov`
- `neg`
- `add`
- `sub`
- `compare`
- `consensus`
- `halt`

Demo `final_report` fields:

| Field | Type | Meaning |
|---|---|---|
| `instructions_executed` | integer | number of executed instructions |
| `failures` | integer | number of failed instructions |
| `halted` | boolean | halt status |
| `registers` | object | register snapshot |

## 7. Operation Result Object

Operation results appear inside demo instruction logs and failure diagnostics.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `op` | string | operation name |
| `target` | array | expected ternary target vector |
| `output` | array | produced ternary output vector |
| `overflow` | integer | balanced ternary carry / overflow marker |
| `compare` | integer or null | compare result |
| `match` | number | fraction of target cells matched |
| `summary` | object | aggregate execution summary |
| `diag` | object | final diagnostic state |
| `telemetry` | array | optional per-tick telemetry |

The `telemetry` field is included only when requested with:

    --include-telemetry

## 8. Summary Object

The `summary` object records aggregate execution metrics.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `ticks_recorded` | integer | number of telemetry records |
| `C_minus_P_min` | number | minimum observed stability margin |
| `C_minus_P_avg` | number | average stability margin |
| `heat_peak` | number | maximum observed heat |
| `heat_avg` | number | average heat |
| `switch_load_peak` | number | maximum transition load |
| `switch_load_avg` | number | average transition load |
| `neutral_peak` | number | maximum neutral-state fraction |
| `neutral_avg` | number | average neutral-state fraction |
| `logical_match_final` | number | final logical match |
| `logical_match_avg` | number | average logical match |
| `actual_direct_events_total` | integer | total actual direct polarity transitions |
| `prevented_direct_events_total` | integer | total prevented direct polarity transitions |
| `neutralized_conflicts_total` | integer | total neutralized conflicts |

Primary candidate invariant fields:

| Field | Required Condition |
|---|---|
| `ticks_recorded` | equals requested `steps` |
| `C_minus_P_min` | greater than 0 |
| `switch_load_peak` | less than or equal to `transition_fraction` |
| `logical_match_final` | equals 1.000 |
| `actual_direct_events_total` | equals 0 |

## 9. Diagnostic Object

The `diag` object records the final diagnostic state of one FRP operation.

Current fields:

| Field | Type | Meaning |
|---|---|---|
| `C` | number | final operational coherence |
| `P` | number | final destabilizing load |
| `C_minus_P` | number | final stability margin |
| `R` | number | final Kuramoto order parameter |
| `logical_match` | number | final logical match |
| `actual_direct_events` | integer | accumulated actual direct events |
| `prevented_direct_events` | integer | accumulated prevented direct events |
| `neutralized_conflicts` | integer | accumulated neutralized conflicts |
| `commits` | integer | commit tick count |
| `excites` | integer | excite tick count |
| `balances` | integer | balance tick count |
| `neutralizes` | integer | neutralize tick count |

Scheduler counts are checked against the selected cycle mode.

## 10. Telemetry Object

Per-tick telemetry is available through:

    --include-telemetry

Telemetry is recorded once per tick.

Current telemetry fields:

| Field | Type | Meaning |
|---|---|---|
| `tick` | integer | tick index |
| `phase` | string | scheduler phase |
| `R` | number | Kuramoto order parameter |
| `phi` | number | mean phase angle |
| `neutral` | number | neutral-state fraction |
| `positive` | number | positive-state fraction |
| `negative` | number | negative-state fraction |
| `heat` | number | current heat |
| `thermal_scale` | number | thermal scaling factor |
| `switch_load` | number | current transition load |
| `actual_direct_events_delta` | integer | actual direct events on the tick |
| `prevented_direct_events_delta` | integer | prevented direct events on the tick |
| `neutralized_conflicts_delta` | integer | neutralized conflicts on the tick |
| `logical_match` | number | current logical match |
| `transition_debt` | number | fraction not yet at target |
| `direct_conflict_fraction` | number | direct conflict fraction |
| `C` | number | operational coherence |
| `P` | number | destabilizing load |
| `C_minus_P` | number | stability margin |

Telemetry supports the future mapping path:

    Python model
    → JSON telemetry
    → benchmark export
    → hardware-facing signal map
    → FPGA register map
    → testbench comparison

## 11. Self-Test JSON Output

Command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json

Top-level self-test fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | schema marker |
| `project` | string | project name |
| `version` | string | prototype version |
| `kind` | string | `self_test` |
| `parameters` | object | execution parameters |
| `metrics` | object | aggregate self-test metrics |
| `failures` | integer | failure count |
| `first_failure` | object or null | first failure details |
| `result` | string | `PASS` or `FAIL` |

Self-test `metrics` fields:

| Field | Type | Meaning |
|---|---|---|
| `runs` | integer | number of test cases |
| `C_minus_P_min` | number | minimum stability margin |
| `heat_peak` | number | maximum heat |
| `switch_load_peak` | number | maximum transition load |
| `actual_direct_events` | integer | total actual direct events |
| `prevented_direct_events` | integer | total prevented direct events |
| `neutralized_conflicts` | integer | total neutralized conflicts |

Expected standard self-test result:

    result = PASS

Expected standard self-test metrics for v0.9.4 remain aligned with the v0.9.3 validation baseline when executed with the same parameters.

## 12. First Failure Object

When a self-test failure occurs, `first_failure` records the first observed failing case.

Fields:

| Field | Type | Meaning |
|---|---|---|
| `N` | integer | vector size |
| `seed` | integer | random seed |
| `mode` | string | scheduler mode |
| `op` | string | tested operation |
| `fail` | array | failure labels |
| `summary` | object | operation summary |
| `diag` | object | operation diagnostics |
| `telemetry` | array | optional telemetry if requested |

Possible failure labels:

| Label | Meaning |
|---|---|
| `match < 1.0` | target output was not fully matched |
| `actual direct event` | direct -1 to 1 or 1 to -1 transition occurred |
| `C-P <= 0` | stability margin reached non-positive value |
| `tick mismatch` | telemetry length did not match requested steps |
| `scheduler mismatch` | scheduler counts did not match expected mode counts |

## 13. Benchmark JSON Output

Command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json

Top-level benchmark fields:

| Field | Type | Meaning |
|---|---|---|
| `schema` | string | schema marker |
| `project` | string | project name |
| `version` | string | prototype version |
| `kind` | string | `benchmark` |
| `parameters` | object | execution parameters |
| `architectures` | array | benchmark architecture summaries |
| `benchmark_supported_position` | string | benchmark-supported technical position |

Benchmark architecture fields:

| Field | Type | Meaning |
|---|---|---|
| `architecture` | string | architecture name |
| `cases` | integer | number of benchmark cases |
| `match` | number | minimum match |
| `C_minus_P_min` | number | minimum stability margin |
| `heat_peak` | number | maximum heat |
| `switch_load_peak` | number | maximum transition load |
| `actual_direct_events_total` | integer | total actual direct events |
| `prevented_direct_events_total` | integer | total prevented direct events |
| `neutralized_conflicts_total` | integer | total neutralized conflicts |

Current benchmark architectures:

- `binary_style_forced_switch`
- `direct_ternary_commit`
- `distributed_neutral_ternary`
- `frp_distributed_resonant`

Current benchmark-supported technical position:

    FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 <-> 1 transitions in the tested operational domain.

## 14. Text Output Compatibility

The default text output remains available.

Standard text self-test command:

    python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5

The text self-test output preserves the key markers used by the previous CI workflow:

    FRP SELF TEST v0.9.4
    failures=0
    result=PASS

Standard text benchmark command:

    python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5

The text benchmark output preserves architecture labels:

    binary_style_forced_switch
    direct_ternary_commit
    distributed_neutral_ternary
    frp_distributed_resonant

This keeps the console workflow readable while adding JSON output for machine-readable validation.

## 15. JSON Validation Markers

Useful JSON validation markers:

| Marker | Expected Value |
|---|---|
| `schema` | `frp.structured_output.v0.9.4` |
| `version` | `v0.9.4` |
| `kind` | `self_test`, `benchmark`, or `demo` |
| `result` | `PASS` for successful self-test |
| `failures` | `0` for successful self-test |
| `architectures[].architecture` | benchmark architecture labels |

Recommended CI checks for self-test JSON:

- JSON parses successfully
- `schema` equals `frp.structured_output.v0.9.4`
- `version` equals `v0.9.4`
- `kind` equals `self_test`
- `result` equals `PASS`
- `failures` equals `0`
- `metrics.actual_direct_events` equals `0`
- `metrics.C_minus_P_min` is greater than `0`

Recommended CI checks for benchmark JSON:

- JSON parses successfully
- `schema` equals `frp.structured_output.v0.9.4`
- `version` equals `v0.9.4`
- `kind` equals `benchmark`
- architecture list contains all four benchmark architecture labels

## 16. Candidate Invariants

The current candidate invariants remain:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

In v0.9.4, these invariants can now be inspected through both console output and structured JSON output.

## 17. Current Status

FRP v0.9.4 adds the M2 structured output layer.

The current output schema supports:

- text output
- JSON output
- self-test JSON summary
- benchmark JSON summary
- demo JSON execution log
- optional telemetry export
- machine-readable schema marker
- CI-oriented JSON validation
- future hardware-facing telemetry mapping

Current role:

    provide machine-readable validation output for reproducibility, benchmark inspection, CI verification, and future FPGA/testbench comparison work

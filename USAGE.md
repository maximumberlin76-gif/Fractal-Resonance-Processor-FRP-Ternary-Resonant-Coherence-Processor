# Usage — Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

This document defines the current command-line usage of the FRP v1.7.0 executable reference.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation status:

`PASS`

## 1. Current Execution Boundary

FRP v1.7.0 provides:

- demonstration execution;
- text output;
- structured JSON output;
- optional full trace output;
- M15 self-test execution;
- scheduler-specific self-test execution;
- M15 benchmark-matrix generation;
- fixed-point interface export;
- balanced ternary hardware-encoding export;
- quantized hardware shadow export;
- cycle-exact reference-trace export;
- deterministic RTL comparison-vector export;
- SystemVerilog testbench interface export;
- synthesizable RTL reference-core export;
- RTL assertion correlation export;
- reference RTL equivalence export;
- qualification-closure export.

The current executable preserves the balanced ternary computational kernel and exposes the M15 hardware-facing qualification layers through one command-line interface.

## 2. Installation

Run commands from the repository root.

Install declared dependencies:

    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt

Current declared dependency:

    numpy>=1.26.0

Verify the executable reference before use:

    python -m py_compile frp_prototype_v1_7_0.py

## 3. Basic Command Structure

General command form:

    python frp_prototype_v1_7_0.py [options]

Primary execution modes:

| Mode | Role |
|---|---|
| `demo` | runs the current FRP structured reference execution |
| `self-test` | runs the M15 self-test package |
| `benchmark` | emits the current M15 benchmark matrix |

General mode form:

    python frp_prototype_v1_7_0.py --mode <mode>

Default mode:

`demo`

## 4. Quick Start

Run the default demo:

    python frp_prototype_v1_7_0.py

Run the demo as JSON:

    python frp_prototype_v1_7_0.py --mode demo --output json

Run the demo with full trace data:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace

Run the default M15 self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Run the free-scheduler self-test:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

Run the 7/1-scheduler self-test:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

Run the 1/7-scheduler self-test:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Generate the current M15 benchmark matrix:

    python frp_prototype_v1_7_0.py --mode benchmark

## 5. Current CLI Options

| Option | Values | Default | Role |
|---|---|---|---|
| `--mode` | `demo`, `self-test`, `benchmark` | `demo` | selects execution mode |
| `--output` | `text`, `json` | `text` | selects output format where applicable |
| `--include-trace` | flag | disabled | includes full demo trace data |
| `--scheduler` | `free`, `7/1`, `1/7` | `7/1` | selects scheduler mode |
| `--cells` | power-of-two integer, at least `2` | `16` | selects cell count |
| `--steps` | integer | `64` | selects execution length |
| `--seed` | integer | `76` | selects deterministic seed |
| `--transition-fraction` | number | `0.25` | sets maximum transition fraction per tick |
| `--gamma` | number | `0.30 × pi` | sets phase-shift parameter |
| `--fractal-alpha` | number | `0.70` | sets hierarchical coupling exponent |
| `--thermal-beta` | number | `1.20` | sets local thermal nonlinearity coefficient |
| `--ambient-heat` | number | `0.05` | sets ambient heat baseline |
| `--thermal-time-constant` | number | `14.0` | sets thermal relaxation time constant |
| `--thermal-soft-limit` | number | `0.22` | sets thermal soft limit |
| `--thermal-hard-limit` | number | `0.90` | sets thermal hard limit |
| `--coupling-nominal` | number | `0.28` | sets nominal coupling strength |
| `--delay-alpha` | number | `0.30` | sets delay-coupling parameter |
| `--thermal-diffusion-gain` | number | `0.035` | sets thermal diffusion gain |
| `--equivalence-tolerance` | number | `1e-12` | sets equivalence comparison tolerance |
| `--vector-output-dir` | directory path | none | writes deterministic M15 vector files |

## 6. Cell-Count Rule

The `--cells` value must be:

- a power of two;
- at least `2`.

Valid examples:

    --cells 2
    --cells 8
    --cells 16
    --cells 32

Invalid examples:

    --cells 1
    --cells 10
    --cells 24

Invalid cell counts are rejected by the command-line parser.

## 7. Scheduler Modes

FRP v1.7.0 supports three scheduler modes.

| Scheduler | Role |
|---|---|
| `free` | free commit behavior |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Free scheduler:

    python frp_prototype_v1_7_0.py --mode demo --scheduler free

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode demo --scheduler 7/1

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode demo --scheduler 1/7

Validated 16-tick scheduler profiles:

| Scheduler | Expected counts |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Validated default 64-tick 7/1 profile:

`balance = 56`

`commit = 8`

## 8. Demo Mode

Default command:

    python frp_prototype_v1_7_0.py --mode demo

Default configuration:

| Parameter | Value |
|---|---|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |

The default text report includes:

- FRP version;
- M15 milestone;
- execution kind;
- balanced ternary state-domain status;
- reserved-state event count;
- actual direct-event count;
- scheduler;
- scheduler counts;
- switch-load peak;
- minimum `C_minus_P`;
- fixed-point topology exactness;
- fixed-point thermal exactness.

Expected default text markers include:

`FRP v1.7.0`

`kind: demo`

`balanced_ternary_state_domain: True`

`reserved_state_events: 0`

`actual_direct_events: 0`

`fixed_point_topology_sum_exact: True`

`fixed_point_thermal_sum_exact: True`

## 9. Demo JSON Output

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Expected kind:

`demo`

Default top-level fields:

- `cell_trace_digest`;
- `configuration`;
- `hardware_profile`;
- `kernel`;
- `kind`;
- `milestone`;
- `preload_digest`;
- `schema`;
- `summary`;
- `trace_digest`;
- `version`.

The default structured output contains digests for the reference preload, execution trace, and cell trace without embedding the complete trace arrays.

## 10. Full Trace Output

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace

The full trace output adds:

- `trace`;
- `cell_trace`;
- `route_events`.

With the default configuration:

- `trace` contains `64` tick rows;
- `cell_trace` contains `1024` cell-tick rows;
- `route_events` records neutral-routing activity.

Use full trace output for exact per-tick or per-cell inspection.

Use digest-only structured output when the full arrays are not required.

## 11. Demo Summary Invariants

The default demo summary must preserve:

- `balanced_ternary_state_domain = True`;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `scheduler_counts_valid = True`;
- `transition_fraction = 0.25`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

The default validation boundary also requires:

- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`.

## 12. Balanced Ternary Routing

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Mandatory opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

## 13. Self-Test Mode

Run the default self-test as text:

    python frp_prototype_v1_7_0.py --mode self-test

Expected text markers:

`FRP v1.7.0`

`kind: self_test`

`status: PASS`

`check_count: 41`

Run the complete self-test package as JSON:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Expected schema:

`frp.structured_output.v1.7.0`

Expected kind:

`self_test`

Expected status:

`PASS`

Expected check count:

`41`

All values in:

`checks`

must be:

`True`

## 14. Scheduler-Specific Self-Tests

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every scheduler-specific self-test must report:

- version `1.7.0`;
- M15 milestone;
- status `PASS`;
- check count `41`;
- all checks `True`.

## 15. Benchmark Mode

Run:

    python frp_prototype_v1_7_0.py --mode benchmark

Benchmark mode emits JSON.

Expected schema:

`frp.m3.benchmark_matrix.v1.7.0`

Expected kind:

`benchmark_matrix`

Expected row count:

`5`

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Equivalent export command:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix

## 16. M15 Export Commands

| Artifact | Command flag | Required schema |
|---|---|---|
| Fixed-Point Interface Profile | `--export-fixed-point-interface-profile` | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| Balanced Ternary Hardware Encoding Map | `--export-balanced-ternary-hardware-encoding-map` | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| Quantized Reference Shadow Model | `--export-quantized-reference-shadow-model` | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| Cycle-Exact Reference Trace | `--export-cycle-exact-reference-trace` | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| RTL Comparison Vector Package | `--export-rtl-comparison-vector-package` | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| SystemVerilog Testbench Interface Map | `--export-systemverilog-testbench-interface-map` | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| Synthesizable RTL Reference Core | `--export-synthesizable-rtl-reference-core` | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| RTL Assertion Correlation Harness | `--export-rtl-assertion-correlation-harness` | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| Reference RTL Equivalence Report | `--export-reference-rtl-equivalence-report` | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| Qualification Closure Manifest | `--export-qualification-closure-manifest` | `frp.m15.qualification_closure_manifest.v1.7.0` |

Generate each artifact:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile
    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map
    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model
    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace
    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package
    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map
    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core
    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness
    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report
    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Export flags emit JSON.

The qualification closure manifest must report:

`status = PASS`

## 17. Deterministic RTL Vector Files

Create an output directory:

    mkdir -p vectors_a

Generate the package and write vector files:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_a > vector-package-a.json

Expected vector files:

- `frp_m15_kernel_vectors.vec`;
- `frp_m15_pending_routes.trace`;
- `frp_m15_scheduler_free_vectors.vec`;
- `frp_m15_scheduler_7_1_vectors.vec`;
- `frp_m15_scheduler_1_7_vectors.vec`;
- `frp_m15_full_correlation_vectors.vec`;
- `frp_m15_cell_trace.vec`;
- `frp_m15_reference_preload.json`;
- `frp_m15_trig_lut_q30.vec`;
- `frp_m15_sha256_manifest.json`.

## 18. Deterministic Repeat Check

Generate package A:

    mkdir -p vectors_a
    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_a > vector-package-a.json

Generate package B independently:

    mkdir -p vectors_b
    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_b > vector-package-b.json

Compare both vector directories:

    diff -qr vectors_a vectors_b

Required result:

`no differences`

This verifies deterministic byte-identical vector generation from the same source state and inputs.

## 19. Scaling Execution

Run 8 cells:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

Run 16 cells:

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

Run 32 cells:

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Expected structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---|---|---|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Every scaling run must preserve:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- scheduler-count validity;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 20. Saving Output

Save the default demo JSON:

    python frp_prototype_v1_7_0.py --mode demo --output json > frp-v1.7.0-demo.json

Save the full demo trace:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace > frp-v1.7.0-demo-trace.json

Save the self-test package:

    python frp_prototype_v1_7_0.py --mode self-test --output json > frp-v1.7.0-self-test.json

Save the benchmark matrix:

    python frp_prototype_v1_7_0.py --mode benchmark > frp-v1.7.0-benchmark-matrix.json

## 21. Minimal Current Validation Sequence

Compile:

    python -m py_compile frp_prototype_v1_7_0.py

Run the default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Run the three scheduler-specific self-tests:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json
    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json
    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Generate the qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Required current result:

`PASS`

## 22. Supporting Comparative Architecture Suite

The separate comparative architecture suite is located at:

`benchmarks/architecture_comparison/`

It compares:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

Run its end-to-end self-test from that directory:

    python run_architecture_comparison.py --self-test --output text

Canonical comparison output:

`results/reference_comparison_seed_76.json`

Detailed usage:

`benchmarks/architecture_comparison/README.md`

This suite is a supporting validation contour and does not replace the FRP v1.7.0 M15 execution path.

## 23. Current Usage Status

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current default scheduler:

`7/1`

Current default cells:

`16`

Current default steps:

`64`

Current default seed:

`76`

Current validated self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

# Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

**Ternary Resonant Coherence Processor — Structured Output Prototype**

## Installation

This document defines the installation and first-run path for the current Fractal Resonance Processor (FRP) release layer.

FRP is a balanced ternary resonant coherence processor operating on the state domain:

`{-1, 0, 1}`

The neutral state is:

`0`

The neutral state is an active balancing, damping, transition, and stabilization state.

Validated opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Validated kernel invariant:

`actual_direct_events = 0`

FRP v1.7.0 is the current ready executable structured-output prototype and current reference architecture of the processor.

The repository preserves the complete published technical specification chain from executable reference behavior through structured validation, hardware-facing signal mapping, HDL and testbench preparation, RTL interface and assertion layers, formal verification and equivalence scaffolds, FPGA synthesis and timing structures, stable production interfaces, silicon and heterogeneous architecture, silicon production and tapeout readiness, production integration and external handoff, production scaling and stabilization, physical implementation correlation, deterministic implementation mapping, cycle-exact reference execution, SystemVerilog interface mapping, RTL correlation, and qualification closure.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Dependency file:

`requirements.txt`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation status:

`PASS`

## 1. Processor Identity and Preserved Kernel

The processor operates on three balanced ternary states:

`-1`

`0`

`1`

The preserved computational kernel is defined by:

- balanced ternary state domain `{-1, 0, 1}`;
- active neutral state `0`;
- no direct opposite-polarity execution;
- tick-separated neutral routing;
- retained pending target polarity;
- scheduler modes `free`, `7/1`, and `1/7`;
- transition-fraction control;
- deterministic request-lane ordering.

The core route invariant remains:

`-1 → 0 → 1`

`1 → 0 → -1`

The validated direct-transition invariant remains:

`actual_direct_events = 0`

The M15 layer extends this preserved processor kernel into deterministic hardware-facing representation and qualification layers.

## 2. Current Technical Position

The current executable reference is:

`frp_prototype_v1_7_0.py`

The current M15 architecture defines the bridge:

`M14 floating semantic reference`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation mapping`

↓

`qualification closure`

The current M15 artifact layers are:

1. `fixed_point_interface_profile`;
2. `balanced_ternary_hardware_encoding_map`;
3. `quantized_reference_shadow_model`;
4. `cycle_exact_reference_trace`;
5. `rtl_comparison_vector_package`;
6. `systemverilog_testbench_interface_map`;
7. `synthesizable_rtl_reference_core`;
8. `rtl_assertion_correlation_harness`;
9. `reference_rtl_equivalence_report`;
10. `qualification_closure_manifest`.

## 3. Required Tools

Use the current CI-aligned Python environment:

`Python 3.12`

Required:

- Python;
- pip;
- Git when cloning the repository.

The current dependency file declares:

`numpy>=1.26.0`

Check the local tools:

    python --version
    python -m pip --version
    git --version

On systems where the interpreter command is:

`python3`

replace `python` with `python3` throughout.

## 4. Obtain the Repository

Clone:

    git clone https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor.git

Enter the repository directory:

    cd Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

Confirm that the current executable reference exists:

    python -c "from pathlib import Path; p=Path('frp_prototype_v1_7_0.py'); print(p, p.exists())"

Required result:

`frp_prototype_v1_7_0.py True`

## 5. Create a Virtual Environment

Create:

    python -m venv .venv

### Linux and macOS

Activate:

    source .venv/bin/activate

### Windows PowerShell

Activate:

    .venv\Scripts\Activate.ps1

### Windows Command Prompt

Activate:

    .venv\Scripts\activate.bat

After activation, verify:

    python --version

## 6. Install Dependencies

Upgrade pip:

    python -m pip install --upgrade pip

Install the declared dependencies:

    python -m pip install -r requirements.txt

Verify NumPy:

    python -c "import numpy; print(numpy.__version__)"

The installed version must satisfy:

`numpy>=1.26.0`

## 7. Compile Gate

Run:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

A successful compile gate returns without an error message.

## 8. Inspect the Current Command Interface

Run:

    python frp_prototype_v1_7_0.py --help

The current command interface includes:

- `--mode {demo,self-test,benchmark}`;
- `--output {text,json}`;
- `--include-trace`;
- `--scheduler {free,7/1,1/7}`;
- `--cells`;
- `--steps`;
- `--seed`;
- `--transition-fraction`;
- `--gamma`;
- `--fractal-alpha`;
- `--thermal-beta`;
- `--ambient-heat`;
- `--thermal-time-constant`;
- `--thermal-soft-limit`;
- `--thermal-hard-limit`;
- `--coupling-nominal`;
- `--delay-alpha`;
- `--thermal-diffusion-gain`;
- `--equivalence-tolerance`;
- `--vector-output-dir`;
- ten M15 export flags;
- `--export-benchmark-matrix`.

## 9. First Processor Run

Run the current FRP v1.7.0 executable reference:

    python frp_prototype_v1_7_0.py --mode demo

Expected leading markers:

`FRP v1.7.0`

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

`kind: demo`

Expected preserved-kernel markers:

- `balanced_ternary_state_domain: True`;
- `reserved_state_events: 0`;
- `actual_direct_events: 0`;
- `fixed_point_topology_sum_exact: True`;
- `fixed_point_thermal_sum_exact: True`.

Default scheduler:

`7/1`

Default 64-tick scheduler counts:

`balance = 56`

`commit = 8`

## 10. Structured JSON First Run

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json

Expected schema:

`frp.structured_output.v1.7.0`

Expected version:

`1.7.0`

Expected milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Default configuration:

| Parameter | Value |
|---|---:|
| cells | `16` |
| hierarchy depth | `4` |
| request lanes | `4` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |

Required default summary invariants:

- `balanced_ternary_state_domain = True`;
- `reserved_state_events = 0`;
- `actual_direct_events = 0`;
- `queue_overflow_events = 0`;
- `scheduler_counts_valid = True`;
- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`;
- `switch_load_peak <= 0.25`;
- `C_minus_P_min > 0.0`.

## 11. Standard Self-Test

Run:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

| Field | Required value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `status` | `PASS` |
| `check_count` | `41` |
| all values in `checks` | `True` |

Current validated result:

`41/41 PASS`

## 12. Full Scheduler Self-Test Matrix

Default profile:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every profile must report:

`status = PASS`

`check_count = 41`

All 41 checks must be:

`True`

## 13. Scheduler Layer

FRP v1.7.0 preserves three scheduler modes.

| Scheduler | Validated profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `16 ticks → balance = 14, commit = 2` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Validated default 64-tick 7/1 profile:

`balance = 56`

`commit = 8`

Validated relation:

`sum(scheduler_counts) = ticks_recorded`

## 14. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Validated invariant:

`reserved_state_events = 0`

## 15. Benchmark-Matrix Smoke Check

Run:

    python frp_prototype_v1_7_0.py --mode benchmark

Expected schema:

`frp.m3.benchmark_matrix.v1.7.0`

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

## 16. M15 Export Smoke Check

Generate the fixed-point interface profile:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Generate the balanced ternary hardware encoding map:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Generate the quantized reference shadow model:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Generate the cycle-exact reference trace:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Generate the RTL comparison vector package:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Generate the SystemVerilog testbench interface map:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Generate the synthesizable RTL reference core:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

Generate the RTL assertion correlation harness:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Generate the reference RTL equivalence report:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

Generate the qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest

The qualification closure manifest must report:

`status = PASS`

The manifest must contain:

`10`

M15 artifact layers.

## 17. Deterministic Vector Check

Create two output directories:

    mkdir -p vectors_a
    mkdir -p vectors_b

Generate package A:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_a > vector-package-a.json

Generate package B independently:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir vectors_b > vector-package-b.json

Compare the generated vector directories:

    diff -qr vectors_a vectors_b

Required result:

`no differences`

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

## 18. Scaling Smoke Check

Run 8 cells:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json

Run 16 cells:

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json

Run 32 cells:

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json

Expected structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---:|---:|---:|
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

## 19. Installation Acceptance Criteria

The current processor installation is ready when:

- the repository has been cloned or unpacked completely;
- `frp_prototype_v1_7_0.py` exists;
- the declared dependency is installed;
- Python compilation completes without error;
- the default processor demo runs;
- the structured output reports schema `frp.structured_output.v1.7.0`;
- the preserved balanced ternary state domain is valid;
- `actual_direct_events = 0`;
- the standard self-test reports `41/41 PASS`;
- the scheduler-specific self-tests report `41/41 PASS`;
- the benchmark matrix reports the five expected architecture rows;
- the qualification closure manifest reports `PASS`.

For complete deterministic vector reproduction, also require byte-identical equality between independently generated vector directories.

## 20. Running Without Virtual-Environment Activation

Activation is optional.

### Linux and macOS

Use the virtual-environment interpreter directly:

    ./.venv/bin/python -m pip install -r requirements.txt
    ./.venv/bin/python -m py_compile frp_prototype_v1_7_0.py
    ./.venv/bin/python frp_prototype_v1_7_0.py --mode self-test --output json

### Windows PowerShell

Use:

    .venv\Scripts\python.exe -m pip install -r requirements.txt
    .venv\Scripts\python.exe -m py_compile frp_prototype_v1_7_0.py
    .venv\Scripts\python.exe frp_prototype_v1_7_0.py --mode self-test --output json

## 21. Updating an Existing Clone

Enter the repository directory:

    cd Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

Inspect the working tree before updating:

    git status

Update the current branch:

    git pull

Refresh dependencies:

    python -m pip install -r requirements.txt

Re-run the compile gate:

    python -m py_compile frp_prototype_v1_7_0.py

Re-run the current self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

## 22. Troubleshooting

### Python command not found

Try:

    python3 --version

Then use `python3` instead of `python` in the commands above.

### pip is not available as a standalone command

Use:

    python -m pip install -r requirements.txt

### NumPy import fails

Run:

    python -m pip install -r requirements.txt

Then verify:

    python -c "import numpy; print(numpy.__version__)"

### Virtual environment does not activate

Use the virtual-environment interpreter directly as shown in Section 20.

### PowerShell blocks activation

Use:

    .venv\Scripts\python.exe frp_prototype_v1_7_0.py --mode self-test --output json

Activation is not required when the interpreter is invoked directly.

### `--cells` is rejected

The current executable requires:

- a power-of-two cell count;
- at least `2` cells.

Valid examples:

`2`

`8`

`16`

`32`

### Self-test does not report PASS

Record:

    git rev-parse HEAD
    git status --short
    python --version
    python -m pip freeze

Then compare the local source revision and environment with:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`.

## 23. Current Technical Chain

The repository preserves the processor development and qualification chain:

`balanced ternary computational kernel`

↓

`structured machine-readable validation`

↓

`benchmark export and hardware signal mapping`

↓

`HDL trace and testbench preparation`

↓

`RTL interface and assertion contracts`

↓

`formal verification and equivalence scaffolds`

↓

`FPGA synthesis and timing structures`

↓

`stable production interface freeze`

↓

`silicon and heterogeneous implementation architecture`

↓

`silicon production and tapeout readiness`

↓

`production integration and external implementation handoff`

↓

`external implementation feedback and production iteration`

↓

`production scaling and implementation stabilization`

↓

`physical implementation correlation and production qualification`

↓

`fixed-point implementation mapping`

↓

`stateful quantized hardware shadow execution`

↓

`cycle-exact integer golden trace`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`synthesizable RTL reference-core mapping`

↓

`RTL assertion correlation`

↓

`qualification closure`

## 24. Current File Alignment

This installation path is aligned with:

- `README.md`;
- `frp_prototype_v1_7_0.py`;
- `requirements.txt`;
- `USAGE.md`;
- `REPRODUCIBILITY.md`;
- `CI.md`;
- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Historical executable files and historical release records remain bound to their corresponding release layers.

## 25. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Balanced Ternary Resonant Coherence Processor`

State domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Current executable form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current published release validation result:

`PASS`

Current validated self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

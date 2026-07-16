# Example Scenarios — Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

This directory provides executable example scenarios for the Fractal Resonance Processor (FRP) and connects the M15-qualified executable semantic reference to the current M16 SystemVerilog RTL execution layer and the current M16 target-independent FPGA preparation layer.

FRP is a ternary resonant coherence processor.

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

M15 semantic and implementation-mapping foundation:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current M16 architecture document:

`../docs/m16_rtl_core_realization_execution_semantics.md`

Current test report:

`../TEST_REPORT_v1_8_0.md`

Current validation index:

`../FRP_VALIDATION_INDEX_v1_8_0.md`

Current release notes:

`../RELEASE_NOTES_v1_8_0.md`

Inherited M15 qualification workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Current published validation result:

`PASS`

Inherited M15 self-test result:

`41/41 PASS`

Current M16 RTL status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## 1. Directory Role

The `examples/` directory provides copyable execution scenarios for:

- structured processor execution;
- full trace generation;
- balanced ternary state observation;
- active-neutral route observation;
- scheduler variation;
- 8-cell, 16-cell, and 32-cell scaling;
- M15 self-test qualification;
- five-row M15 benchmark export;
- ten M15 artifact exports;
- deterministic RTL vector generation;
- semantic correlation;
- exact quantized replay;
- M15 qualification closure;
- M16 RTL build and executable testbench execution;
- M16 FPGA integration-top elaboration and executable testbench execution.

The example chain is:

`M15-qualified executable semantic reference`

↓

`structured execution`

↓

`trace and state inspection`

↓

`self-test qualification`

↓

`implementation-mapping exports`

↓

`deterministic vector reproduction`

↓

`reference equivalence`

↓

`qualification closure`

↓

`M16 executable SystemVerilog RTL core`

↓

`M16 target-independent FPGA integration and preparation qualification`

## 2. Directory Contents

| File | Role |
|---|---|
| `README.md` | current executable example index |
| `resonance_convergence_example.md` | release-specific convergence example record |

Current processor commands and current metric definitions are taken from:

`../frp_prototype_v1_7_0.py`

Current release validation is taken from:

- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`.

## 3. Current Computational Subject

The complete current FRP chain is:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric Sakaguchi phase lag gamma`

↓

`dyadic hierarchical fractal coupling`

↓

`phase velocity and phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`stateful delay dynamics`

↓

`distributed local thermal field`

↓

`local correlated gamma drift`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed ternary commit`

↓

`mandatory tick-separated routing through active neutral state 0`

↓

`retained coherent ternary state`

↓

`M15 fixed-point mapping, quantized execution, deterministic vectors, and qualification closure`

↓

`M16 scheduler, request-lane arbitration, active-neutral routing, transition-capacity enforcement, and retained-state writeback`

↓

`M16 target-independent FPGA reset, readiness, and execution-input gating`

The resonant dynamic domain drives the evolving computation.

The balanced ternary domain provides the state, target, transition, and retained-result layer.

M15 remains the qualified semantic and implementation-mapping foundation of M16.

## 4. Current Command Interface

The current executable semantic reference provides three command modes:

| Mode | Purpose |
|---|---|
| `demo` | execute the current processor reference |
| `self-test` | execute the current deterministic 41-check qualification package |
| `benchmark` | emit the current five-row M15 implementation-mapping matrix |

Current output formats:

- `text`;
- `json`.

Current trace option:

`--include-trace`

Current scheduler choices:

- `free`;
- `7/1`;
- `1/7`.

The M16 RTL and FPGA executable examples use Verilator and are provided after the M15 artifact-export examples.

## 5. Compile Example

From the repository root:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

The inherited M15 workflow performs this compile stage before artifact generation.

## 6. Default Structured Execution Example

From the repository root:

    python frp_prototype_v1_7_0.py --mode demo --output json

From the `examples/` directory:

    python ../frp_prototype_v1_7_0.py --mode demo --output json

Current default profile:

| Parameter | Value |
|---|---:|
| cells | `16` |
| steps | `64` |
| seed | `76` |
| scheduler | `7/1` |
| transition fraction | `0.25` |
| hierarchy depth | `4` |
| request lanes | `4` |
| packed ternary state width | `32 bits` |

## 7. M15-Qualified Verified Default Result

The M15-qualified executable semantic reference produces:

| Metric | Value |
|---|---:|
| version | `1.7.0` |
| ticks recorded | `64` |
| scheduler balance ticks | `56` |
| scheduler commit ticks | `8` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `switch_load_peak` | `0.25` |
| `C_minus_P_min` | `0.6142730712890625` |
| `C_minus_P_final` | `0.88287353515625` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

This example exposes the current default quantized hardware-shadow execution path.

## 8. Full Trace Example

Run:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --output json \
      --include-trace

Full trace mode adds:

- `trace`;
- `cell_trace`;
- `route_events`.

Current default trace sizes:

`trace = 64 processor-tick rows`

`cell_trace = 1024 cell-tick rows`

Use full trace mode to inspect:

- scheduler state;
- packed ternary state;
- pending routes;
- phase state;
- frequency state;
- local thermal state;
- local gamma state;
- multiscale coherence;
- `C(t)`;
- `P(t)`;
- `C(t) - P(t)`.

## 9. Balanced Ternary State Example

Current state and retained-result domain:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative target polarity and retained negative state |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive target polarity and retained positive state |

Current state-domain marker:

`balanced_ternary_state_domain = True`

Current reserved-state invariant:

`reserved_state_events = 0`

## 10. Active-Neutral Route Example

Opposite-polarity execution follows the mandatory routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Current route invariant:

`actual_direct_events = 0`

Current queue invariant:

`queue_overflow_events = 0`

## 11. Phase-Derived Ternary Target Example

Current target mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

The cross-tick execution path is:

`evolved resonant phase field`

↓

`phase-derived ternary target`

↓

`transition-capacity control`

↓

`distributed commit`

↓

`active-neutral route processing`

↓

`retained ternary state`

↓

`subsequent resonant evolution`

## 12. Resonant Phase Example

The current floating semantic reference uses:

`sin(phase_j - phase_i - gamma_effective_i)`

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current phase velocity:

`phase_velocity_i = 0.060 × frequency_i + scheduler_push + coupling_field_i`

Current phase update:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

Current global phase-order metric:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

## 13. Coherence and Stability Example

The current metric chain is:

`raw phase coherence`

↓

`multiscale phase coherence`

↓

`thermal-overload pressure`

↓

`stability-margin pressure`

↓

`nonlinear coherence compression`

↓

`effective coherence`

↓

`C(t)`

↓

`P(t)`

↓

`C(t) - P(t)`

Current operational coherence:

`C = 0.82 + 0.34 × effective_coherence + 0.16 × cluster_coherence_mean + 0.08 × neutral_fraction - 0.10 × mean_frequency_lag`

Current destabilizing load:

`P = heat + switch_load`

Current dynamic-stability margin:

`C_minus_P = C - P`

Current validated condition:

`C_minus_P_min > 0.0`

## 14. Scheduler Example — free

Run:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --scheduler free \
      --steps 16 \
      --output json

Current validated 16-tick count:

`free = 16`

Current scheduler phase push for the free state:

`0.003`

## 15. Scheduler Example — 7/1

Run:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --scheduler 7/1 \
      --steps 16 \
      --output json

Current validated 16-tick counts:

`balance = 14`

`commit = 2`

Current scheduler phase push:

`commit → 0.010`

`balance → 0.003`

## 16. Scheduler Example — 1/7

Run:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --scheduler 1/7 \
      --steps 16 \
      --output json

Current validated 16-tick counts:

`excite = 2`

`neutralize = 14`

Current scheduler phase push:

`excite → 0.006`

`neutralize → 0.003`

## 17. Scaling Example — 8 Cells

Run:

    python ../frp_prototype_v1_7_0.py \
      --cells 8 \
      --steps 16 \
      --mode demo \
      --output json

Validated profile:

| Field | Value |
|---|---:|
| cells | `8` |
| hierarchy depth | `3` |
| request lanes | `2` |
| packed state width | `16 bits` |

## 18. Scaling Example — 16 Cells

Run:

    python ../frp_prototype_v1_7_0.py \
      --cells 16 \
      --steps 16 \
      --mode demo \
      --output json

Validated profile:

| Field | Value |
|---|---:|
| cells | `16` |
| hierarchy depth | `4` |
| request lanes | `4` |
| packed state width | `32 bits` |

## 19. Scaling Example — 32 Cells

Run:

    python ../frp_prototype_v1_7_0.py \
      --cells 32 \
      --steps 16 \
      --mode demo \
      --output json

Validated profile:

| Field | Value |
|---|---:|
| cells | `32` |
| hierarchy depth | `5` |
| request lanes | `8` |
| packed state width | `64 bits` |

Each validated scaling profile preserves:

`balanced_ternary_state_domain = True`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`scheduler_counts_valid = True`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 20. Transition-Fraction Example

Current default transition fraction:

`0.25`

Run a 16-cell example with the current default bound:

    python ../frp_prototype_v1_7_0.py \
      --cells 16 \
      --steps 64 \
      --transition-fraction 0.25 \
      --mode demo \
      --output json

Current transition-capacity relation:

`max_changes = max(1, round(cells × transition_fraction))`

Current default request lanes:

`16 cells → 4`

Current validated relation:

`switch_load_peak <= transition_fraction`

## 21. Resonance-Parameter Example

Run a current processor example with explicit resonant parameters:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --cells 16 \
      --steps 64 \
      --seed 76 \
      --scheduler 7/1 \
      --gamma 0.9424777960769379 \
      --fractal-alpha 0.70 \
      --coupling-nominal 0.28 \
      --delay-alpha 0.30 \
      --output json

The explicit gamma value corresponds to:

`0.30 × pi`

## 22. Thermal-Parameter Example

Run with the current default thermal profile written explicitly:

    python ../frp_prototype_v1_7_0.py \
      --mode demo \
      --ambient-heat 0.05 \
      --thermal-time-constant 14.0 \
      --thermal-soft-limit 0.22 \
      --thermal-hard-limit 0.90 \
      --thermal-beta 1.20 \
      --thermal-diffusion-gain 0.035 \
      --output json

These parameters participate in:

- local generated power;
- thermal dissipation;
- hierarchical thermal diffusion;
- local thermal overload;
- thermal node factors;
- local gamma drift;
- coherence compression;
- dynamic stability.

## 23. Self-Test Example

Run:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

Required result:

`status = PASS`

Required check count:

`41`

Required check state:

`all 41 checks = True`

Current validated result:

`41/41 PASS`

## 24. Scheduler Self-Test Matrix

Run:

    python ../frp_prototype_v1_7_0.py --mode self-test --output json

    python ../frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

    python ../frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

    python ../frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Each M15 executable result preserves:

- version `1.7.0`;
- M15 milestone identity;
- status `PASS`;
- check count `41`;
- complete true check set.

## 25. M15 Benchmark Matrix Example

Run:

    python ../frp_prototype_v1_7_0.py --mode benchmark --output json

Equivalent export:

    python ../frp_prototype_v1_7_0.py --export-benchmark-matrix

Current schema:

`frp.m3.benchmark_matrix.v1.7.0`

Current rows:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

Current row count:

`5`

## 26. Fixed-Point Interface Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

Current numeric domains:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma | `GAMMA_S32` |

Current trigonometric profile:

`4096-entry full-cycle lookup table`

## 27. Balanced Ternary Encoding Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

Current encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Current integer mapping:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

## 28. Quantized Hardware-Shadow Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

Current representation:

`QuantizedReferenceShadowProcessor`

This export carries:

- ternary state execution;
- active-neutral routing;
- scheduler behavior;
- hierarchical coupling;
- delay dynamics;
- thermal dynamics;
- gamma dynamics;
- phase evolution;
- multiscale coherence;
- `C(t) - P(t)` telemetry.

## 29. Cycle-Exact Trace Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

Current default trace length:

`64 ticks`

The trace carries deterministic integer correlation fields for:

- scheduler state;
- packed ternary state;
- pending routes;
- phase;
- frequency;
- thermal state;
- gamma state;
- coherence;
- dynamic stability.

## 30. RTL Comparison Vector Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

Current vector-package file count:

`10`

Current package includes:

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

## 31. Deterministic Vector Directory Example

Generate package A:

    mkdir -p vectors_a

    python ../frp_prototype_v1_7_0.py \
      --export-rtl-comparison-vector-package \
      --vector-output-dir vectors_a \
      > vector-package-a.json

Generate package B independently:

    mkdir -p vectors_b

    python ../frp_prototype_v1_7_0.py \
      --export-rtl-comparison-vector-package \
      --vector-output-dir vectors_b \
      > vector-package-b.json

Compare:

    diff -qr vectors_a vectors_b

Required result:

`byte-identical equality`

Current self-test marker:

`vector_determinism_pass = True`

## 32. SystemVerilog Interface Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

Current default interface parameters:

| Parameter | Value |
|---|---:|
| `NUM_CELLS` | `16` |
| `HIERARCHY_DEPTH` | `4` |
| `REQUEST_LANES` | `4` |
| `CELL_ID_WIDTH` | `4` |
| `STATE_VECTOR_WIDTH` | `32` |
| `SCALAR_WIDTH` | `32` |
| `PHASE_WIDTH` | `32` |

## 33. Synthesizable RTL Reference-Core Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

The current mapping covers:

- balanced ternary state execution;
- active-neutral transition core;
- pending neutral-route queue;
- scheduler;
- request lanes;
- transition limits;
- fixed-point phase behavior;
- hierarchical coupling datapath;
- thermal-field datapath;
- multiscale phase-coherence datapath;
- dynamic-stability output mapping.

## 34. RTL Assertion Correlation Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

Current assertion-correlation harness count:

`13`

Current exact integer comparison rule:

`actual integer field == expected integer field`

## 35. Reference Equivalence Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

The current equivalence architecture contains two boundaries.

Floating semantic reference to quantized shadow:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Exact quantized replay:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 36. Qualification Closure Export Example

Run:

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

Current artifact-layer count:

`10`

Current result:

`PASS`

The closure chain is:

`fixed-point interface`

↓

`balanced ternary encoding`

↓

`quantized hardware shadow`

↓

`cycle-exact trace`

↓

`RTL comparison vectors`

↓

`SystemVerilog interface map`

↓

`synthesizable RTL reference-core map`

↓

`RTL assertion correlation`

↓

`reference equivalence`

↓

`qualification closure`

## 37. Ten M15 Artifact Commands

Run the complete current export set:

    python ../frp_prototype_v1_7_0.py --export-fixed-point-interface-profile

    python ../frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map

    python ../frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model

    python ../frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace

    python ../frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package

    python ../frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map

    python ../frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core

    python ../frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness

    python ../frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report

    python ../frp_prototype_v1_7_0.py --export-qualification-closure-manifest

## 38. M15 Schema Registry

Current schemas:

`frp.m15.fixed_point_interface_profile.v1.7.0`

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

`frp.m15.quantized_reference_shadow_model.v1.7.0`

`frp.m15.cycle_exact_reference_trace.v1.7.0`

`frp.m15.rtl_comparison_vector_package.v1.7.0`

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

`frp.m15.qualification_closure_manifest.v1.7.0`

Current schema qualification result:

`PASS`

## 39. Current Validation Example Chain

Current release validation connects:

`structured output`

↓

`41-check self-test`

↓

`8-cell, 16-cell, and 32-cell scaling`

↓

`fixed-point topology exactness`

↓

`fixed-point thermal exactness`

↓

`quantized hardware-shadow execution`

↓

`cycle-exact integer trace`

↓

`deterministic RTL vectors`

↓

`13 assertion-correlation domains`

↓

`semantic correlation`

↓

`exact deterministic replay`

↓

`qualification closure PASS`

↓

`M16 executable RTL build and architectural testbench`

↓

`M16 FPGA integration-top elaboration and executable testbench`

## 40. Inherited M15 Qualification Workflow Example

Inherited workflow:

`../.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Workflow name:

`FRP M15 Implementation Mapping and Qualification Closure`

Current environment:

`ubuntu-latest`

Current Python version:

`3.12`

The workflow executes nine stages:

1. checkout repository;
2. set up Python;
3. compile the FRP v1.7.0 reference file;
4. generate M15 qualification outputs;
5. compare deterministic vector packages;
6. validate schemas, kernel invariants, fixed-point contract, and equivalence;
7. validate deterministic vector-package integrity;
8. validate the M15 architecture document contract;
9. upload M15 qualification artifacts.

## 41. M16 RTL Build and Execution Example

From the `examples/` directory, build the executable M16 RTL testbench:

    verilator --sv --timing --assert --binary \
      --top-module frp_m16_tb \
      -I../rtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      ../rtl/m16/frp_m16_tb.sv

Generated executable:

`/tmp/frp_m16_obj/Vfrp_m16_tb`

Run:

    /tmp/frp_m16_obj/Vfrp_m16_tb

Validated testbench configuration:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

Validated terminal output:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

The executable testbench covers:

- `free` scheduler execution;
- `7/1` scheduler execution;
- `1/7` scheduler execution;
- request-lane arbitration;
- active-neutral first-leg execution;
- retained pending-route completion;
- two-lane transition-capacity saturation;
- retained-state writeback;
- counter clearing with retained state preserved;
- assertion execution;
- all ten integrated invariant flags.

## 42. M16 FPGA Integration Example

From the `examples/` directory, elaborate the target-independent FPGA integration top:

    verilator --sv --lint-only \
      --top-module frp_m16_fpga_top \
      -I../rtl/m16 \
      -I../fpga/m16 \
      ../fpga/m16/frp_m16_fpga_top.sv

Build the executable FPGA integration testbench:

    verilator --sv --timing --assert --binary \
      --top-module frp_m16_fpga_tb \
      -I../rtl/m16 \
      -I../fpga/m16 \
      --Mdir /tmp/frp_m16_fpga_obj \
      ../fpga/m16/frp_m16_fpga_tb.sv

Generated executable:

`/tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb`

Run:

    /tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb

Validated terminal output:

`FRP M16 FPGA integration testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

The FPGA integration example covers:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick, counter-clear, and request-valid gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- all ten integrated invariant flags.

## 43. M16 Qualification Workflow Examples

M16 RTL qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

M16 FPGA preparation workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Qualification records:

| Layer | Workflow run | Qualified commit | Branch | Result | Closure status |
|---|---:|---|---|---|---|
| RTL execution initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| RTL execution qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `M16 RTL EXECUTION LAYER CLOSED` |
| FPGA preparation initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |
| FPGA preparation qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `M16 FPGA PREPARATION LAYER CLOSED` |

## 44. Published Validation Evidence

Current validated release layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

Current validation environment:

`GitHub Actions`

Workflow runner:

`ubuntu-latest`

Inherited M15 Python toolchain:

`Python 3.12`

M16 RTL and FPGA preparation toolchain:

`Verilator and g++`

Inherited M15 validated release commit:

`5fd9a4f`

Inherited M15 workflow stack:

- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

Current M16 qualification records:

| Layer | Workflow run | Qualified commit | Branch | Result | Artifact count | Closure status |
|---|---:|---|---|---|---:|---|
| RTL execution initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| RTL execution qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| FPGA preparation initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| FPGA preparation qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

Current `CI.md` workflow status badge count:

`23`

Current repository workflow count:

`23`

Current root README linked architecture image count:

`1`

Current published validation result:

`PASS`

## 45. Historical Transition Benchmark Example Contour

The repository preserves the historical transition benchmark in:

`../TEST_REPORT_v0_9_3.md`

Historical architecture set:

- `frp_distributed_resonant`;
- `direct_ternary_commit`;
- `distributed_neutral_ternary`;
- `binary_style_forced_switch`.

Recorded historical result:

| Architecture | Match | C-P_min | Heat Peak | Switch Peak | Actual Direct | Prevented Direct | Neutralized |
|---|---:|---:|---:|---:|---:|---:|---:|
| `binary_style_forced_switch` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `direct_ternary_commit` | `1.000` | `-0.551000` | `0.051000` | `1.000000` | `2052` | `0` | `0` |
| `distributed_neutral_ternary` | `1.000` | `0.174750` | `0.003250` | `0.250000` | `0` | `0` | `2052` |
| `frp_distributed_resonant` | `1.000` | `0.144750` | `0.107000` | `0.250000` | `0` | `3820` | `2392` |

## 46. Archived Ternary-to-Binary Thermal Example

The historical transition benchmark records:

`binary_style_forced_switch heat_peak = 0.051000`

`distributed_neutral_ternary heat_peak = 0.003250`

Exact ratio:

`0.051000 / 0.003250 = 15.6923076923`

Under the historical v0.9.3 transition benchmark model and workload:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch`

Equivalent relative reduction:

`93.63% lower heat_peak`

The same archived run records:

`distributed_neutral_ternary actual_direct_events = 0`

`binary_style_forced_switch actual_direct_events = 2052`

`distributed_neutral_ternary switch_load_peak = 0.25`

`binary_style_forced_switch switch_load_peak = 1.0`

This release-specific example preserves the measured transition-path contrast inside the historical benchmark model.

## 47. Historical and Current Example Contours

The examples layer preserves distinct execution contours.

### Historical transition contour

Measured subject:

`route activity, switching load, historical heat_peak, and dynamic stability`

Primary evidence:

`../TEST_REPORT_v0_9_3.md`

### M15-qualified semantic execution contour

Measured subject:

`resonant phase dynamics, multiscale coherence, delay, local thermal dynamics, gamma drift, ternary routing, and dynamic stability`

Primary executable:

`../frp_prototype_v1_7_0.py`

### Inherited M15 implementation-mapping contour

Measured subject:

`fixed-point mapping, quantized execution, cycle-exact traces, RTL vectors, interface mapping, equivalence, and qualification closure`

Primary architecture document:

`../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

### Current M16 RTL execution contour

Qualified subject:

`scheduler execution, request-lane arbitration, active-neutral routing, retained pending-route completion, transition-capacity enforcement, retained-state writeback, assertions, and ten integrated invariant flags`

Primary executable testbench:

`../rtl/m16/frp_m16_tb.sv`

Qualification workflow:

`../.github/workflows/frp-m16-rtl-artifact-boundary.yml`

### Current M16 FPGA preparation contour

Qualified subject:

`target-independent FPGA integration, asynchronous reset assertion, two-stage synchronous reset release, core_ready generation, execution-input gating, scheduler propagation, request-interface propagation, active-neutral routing, retained pending-route completion, and ten integrated invariant flags`

Primary integration sources:

- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`.

Qualification workflow:

`../.github/workflows/frp-m16-fpga-preparation.yml`

Each contour retains its release-specific architecture identifiers, commands, metrics, and evidence records.

## 48. Companion Convergence Example

Companion file:

`resonance_convergence_example.md`

Its subject is resonance-driven convergence toward a retained ternary state.

The current execution chain relevant to that example is:

`phase evolution`

↓

`multiscale phase coherence`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active-neutral routing`

↓

`dynamic stability`

↓

`retained coherent ternary state`

The companion record remains part of the examples directory as a release-specific convergence scenario. Its execution commands and metric definitions are provided by this README and the M15-qualified FRP v1.7.0 executable semantic reference.

## 49. Example Evidence Registry

| Example subject | Primary source |
|---|---|
| M15-qualified structured execution | `../frp_prototype_v1_7_0.py` |
| M15-qualified self-test | `../TEST_REPORT_v1_7_0.md` and executable self-test output |
| M15 implementation mapping | M15 export schemas and `../docs/m15_implementation_mapping_domain_interface_qualification_closure.md` |
| M15 deterministic vectors | `rtl_comparison_vector_package` |
| M15 semantic correlation | `reference_rtl_equivalence_report` |
| M15 qualification closure | `qualification_closure_manifest` |
| M16 RTL executable testbench | `../rtl/m16/frp_m16_tb.sv` |
| M16 RTL qualification | `../rtl/m16/CLOSURE.md` and `../.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| M16 FPGA integration | `../fpga/m16/frp_m16_fpga_top.sv` and `../fpga/m16/frp_m16_fpga_tb.sv` |
| M16 FPGA preparation qualification | `../fpga/m16/CLOSURE.md` and `../.github/workflows/frp-m16-fpga-preparation.yml` |
| current release test report | `../TEST_REPORT_v1_8_0.md` |
| current validation index | `../FRP_VALIDATION_INDEX_v1_8_0.md` |
| mathematical foundation | `../docs/mathematical_foundation.md` |
| physical foundation | `../docs/physical_foundation.md` |
| historical transition thermal result | `../TEST_REPORT_v0_9_3.md` |
| companion convergence record | `resonance_convergence_example.md` |

This registry keeps each example attached to its generating release layer and metric domain.

## 50. Current File Alignment

This examples layer is aligned with:

- `../README.md`;
- `../frp_prototype_v1_7_0.py`;
- `../TEST_REPORT_v1_8_0.md`;
- `../FRP_VALIDATION_INDEX_v1_8_0.md`;
- `../RELEASE_NOTES_v1_8_0.md`;
- `../CI.md`;
- `../REPRODUCIBILITY.md`;
- `../USAGE.md`;
- `../INSTALL.md`;
- `../CONTRIBUTING.md`;
- `../docs/README.md`;
- `../docs/core_principles.md`;
- `../docs/resonance_computation.md`;
- `../docs/architecture.md`;
- `../docs/implementation_layers.md`;
- `../docs/benchmark_interpretation.md`;
- `../docs/limitations.md`;
- `../docs/mathematical_foundation.md`;
- `../docs/physical_foundation.md`;
- `../verification/README.md`;
- `../verification/coherence_metrics.md`;
- `../simulations/README.md`;
- `../docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `../docs/m16_rtl_core_realization_execution_semantics.md`;
- `../docs/m16_qualification_index.md`;
- `../docs/m16_qualification_manifest.md`;
- `../rtl/m16/README.md`;
- `../rtl/m16/ARTIFACTS.md`;
- `../rtl/m16/SIMULATION.md`;
- `../rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `../rtl/m16/CLOSURE.md`;
- `../fpga/m16/frp_m16_fpga_top.sv`;
- `../fpga/m16/frp_m16_fpga_tb.sv`;
- `../fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `../fpga/m16/CLOSURE.md`;
- `../.github/workflows/frp-m15-implementation-mapping-qualification.yml`;
- `../.github/workflows/frp-m16-rtl-artifact-boundary.yml`;
- `../.github/workflows/frp-m16-fpga-preparation.yml`;
- `../.github/workflows/frp-m16-canonical-core-domain.yml`;
- `../.github/workflows/frp-m16-reserved-cell-cleanup.yml`.

Inherited M15 release evidence remains aligned with:

- `../TEST_REPORT_v1_7_0.md`;
- `../FRP_VALIDATION_INDEX_v1_7_0.md`;
- `../RELEASE_NOTES_v1_7_0.md`.

Historical transition evidence remains aligned with:

- `../TEST_REPORT_v0_9_3.md`;
- `../frp_prototype_v0_9_3_mobile.py`.

## 51. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Current example execution chain:

`structured execution → full trace → scheduler and scaling scenarios → 41-check self-test → five-row M15 benchmark matrix → ten M15 artifact exports → deterministic RTL vector generation → semantic correlation → exact quantized replay → M15 qualification closure → M16 executable RTL testbench → M16 FPGA integration-top elaboration and executable integration testbench`

Current executable semantic reference form:

`Ternary Resonant Coherence Processor — Structured Output Prototype`

Current RTL execution form:

`Integrated SystemVerilog RTL core and executable architectural testbench`

Current FPGA preparation form:

`Target-independent FPGA integration top and executable integration testbench`

Current version:

`FRP v1.8.0`

Current milestone:

`M16 — RTL Core Realization and Execution Semantics Package`

Current executable semantic reference:

`../frp_prototype_v1_7_0.py`

Current structured-output schema:

`frp.structured_output.v1.7.0`

Current M15 benchmark-matrix schema:

`frp.m3.benchmark_matrix.v1.7.0`

Inherited M15 qualification results:

| Qualification record | Result |
|---|---:|
| M15 self-test suite | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Inherited M15 qualification closure result:

`PASS`

Current M16 RTL qualification:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `../.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 RTL EXECUTION LAYER CLOSED` |

Current M16 FPGA preparation qualification:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `../.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Status | `M16 FPGA PREPARATION LAYER CLOSED` |

Current M16 zero-event record:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Current integrated invariant record:

`invariant_flags = 1111111111`

Current published validation result:

`PASS`

Historical archived ternary-to-binary thermal result:

`distributed_neutral_ternary recorded a 15.69× lower heat_peak than binary_style_forced_switch under the historical v0.9.3 transition benchmark model`



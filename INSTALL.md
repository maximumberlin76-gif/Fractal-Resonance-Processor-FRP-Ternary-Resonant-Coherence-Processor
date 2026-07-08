# Fractal Resonance Processor (FRP)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

## Installation

This document defines the installation, first-run, validation, and deterministic reproduction path for the current Fractal Resonance Processor (FRP) release layer.

FRP is a ternary resonant coherence processor.

Its computational mechanism combines resonant phase dynamics, coherence evolution, stateful feedback, and balanced ternary state retention.

The processor combines:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`cell phase and frequency state`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`asymmetric phase lag gamma`

↓

`hierarchical fractal coupling`

↓

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R and multiscale phase coherence`

↓

`delay dynamics`

↓

`local thermal-phase interaction`

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

The balanced ternary domain is:

`{-1, 0, 1}`

The neutral state is:

`0`

The neutral state remains an active balancing, damping, transition, and stabilization state.

Validated opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated kernel invariant:

`actual_direct_events = 0`

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published validation status:

`PASS`

Current validated self-test result:

`41/41 PASS`

## 1. Processor Identity and Computational Core

FRP v1.7.0 is the current executable structured-output prototype and reference architecture of the processor.

The word `prototype` identifies the executable reference form.

The processor computational core contains two inseparable domains.

### 1.1 Resonant dynamic domain

The resonant dynamic domain contains:

- cell phases;
- cell frequencies;
- Kuramoto-Sakaguchi phase interaction;
- asymmetric phase lag;
- hierarchical fractal coupling;
- phase evolution;
- resonance selection;
- global and multiscale phase coherence;
- delay dynamics;
- local thermal interaction;
- gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation.

### 1.2 Ternary state and retention domain

The ternary state and retained-result domain contains:

- balanced ternary states `{-1, 0, 1}`;
- active neutral state `0`;
- phase-derived ternary targets;
- distributed commit;
- transition-fraction control;
- pending neutral routes;
- mandatory tick-separated opposite-polarity routing;
- retained ternary state.

The resonant phase layer drives the dynamic computation.

The ternary layer provides the state, target, transition, and retained-result domain.

Together these domains form the complete FRP computational mechanism.

## 2. What the Current Executable Runs

The current executable reference is:

`frp_prototype_v1_7_0.py`

The default execution path performs the following sequence on every tick:

`scheduler state selection`

↓

`pending neutral-route processing`

↓

`transition-request processing`

↓

`phase-derived target-state processing`

↓

`distributed transition-limit enforcement`

↓

`frequency-delay update`

↓

`local thermal-field update`

↓

`local gamma-drift update`

↓

`thermal coupling-factor update`

↓

`hierarchical Kuramoto-Sakaguchi phase-field update`

↓

`multiscale phase-coherence evaluation`

↓

`nonlinear coherence compression`

↓

`C(t), P(t), and C(t) - P(t) evaluation`

↓

`structured telemetry and trace capture`

Across successive ticks, this execution produces the complete computational relation:

`phase evolution`

↓

`resonance selection`

↓

`phase-coherence accumulation`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active neutral routing`

↓

`retained ternary state`

This is the current processor execution path that the installation commands below prepare and run.

## 3. Kuramoto-Sakaguchi Resonant Phase Layer

Each processor cell has a phase.

The current floating reference coupling path evaluates phase interaction through the term:

`sin(phase_j - phase_i - gamma_effective_i)`

The interaction is combined with:

- hierarchical coupling weights;
- local thermal coupling factors;
- nominal coupling strength;
- local effective gamma.

Current default nominal phase lag:

`gamma = 0.30 × pi`

Current default nominal coupling strength:

`coupling_nominal = 0.28`

Current default fractal coupling exponent:

`fractal_alpha = 0.70`

The current phase velocity is composed from:

`0.060 × current frequency`

+

`scheduler push`

+

`coupling field`

The phase then evolves as:

`phase_i = (phase_i + phase_velocity_i) mod 2π`

This resonant phase evolution forms the processor's evolving computational mechanism.

## 4. Phase Coherence and Kuramoto Order Parameter R

The current executable calculates global phase coherence through the Kuramoto order parameter:

`R = sqrt(mean(cos(phase))² + mean(sin(phase))²)`

The same phase-order calculation is applied across hierarchical domains.

Current multiscale coherence includes:

- pair-domain coherence;
- cluster coherence;
- supercluster coherence;
- global phase coherence;
- coherence dispersion across clusters.

The phase field and coherence field are part of the computation.

The complete FRP execution path includes the phase field, coherence field, transition history, and retained ternary vector.

## 5. Hierarchical Fractal Coupling

The current reference architecture uses a dyadic hierarchical ultrametric topology.

Current default cell count:

`16`

Current default hierarchy depth:

`4`

Current default fractal coupling exponent:

`0.70`

The coupling field is constructed from hierarchy-level interactions with level-dependent connection weights.

The hierarchical path includes:

- dyadic hierarchy depth;
- hierarchical distance;
- shell population;
- level-dependent phase-coupling weights;
- exact normalized fixed-point topology closure.

Current validated topology exactness marker:

`fixed_point_topology_sum_exact = True`

The current floating reference also preserves a dense interaction path for correlation and equivalence analysis.

## 6. Delay Dynamics

Current default delay coefficient:

`delay_alpha = 0.30`

Each cell maintains:

- base frequency;
- frequency target;
- current frequency.

The current frequency target includes contributions from:

- base frequency;
- current ternary state;
- switching activity.

The current frequency approaches its target through the delayed relation:

`current frequency += delay_alpha × (target frequency - current frequency)`

The resulting frequency lag contributes to:

- local generated power;
- phase evolution;
- coherence evaluation;
- dynamic stability.

The delay layer is therefore part of the resonant computational path.

## 7. Local Thermal-Phase Interaction

The current architecture tracks distributed local thermal state.

Each cell contains:

- generated power;
- thermal dissipation;
- thermal diffusion;
- local heat;
- thermal overload.

The local thermal field is affected by:

- switching activity;
- frequency lag;
- ambient heat;
- thermal relaxation;
- thermal diffusion.

Thermal state feeds back into the resonant phase layer through:

- local thermal coupling factors;
- local gamma drift;
- nonlinear coherence compression.

The current processor therefore contains a coupled dynamic relation:

`phase and frequency dynamics`

↓

`local generated power`

↓

`thermal field`

↓

`effective coupling and gamma drift`

↓

`phase evolution`

↓

`coherence`

↓

`stability`

## 8. Local Gamma Drift

The current architecture uses:

- nominal gamma;
- deterministic correlated gamma-noise targets;
- gamma-noise state;
- thermal overload;
- effective local gamma.

The effective local gamma is derived from the nominal phase lag plus a thermal and correlated-noise contribution.

The resulting local gamma enters the Kuramoto-Sakaguchi phase interaction.

The current M15 hardware-facing path also externalizes deterministic gamma-noise targets into the verification stimulus stream.

Validated verification fields include:

`gamma_noise_update_valid`

`gamma_noise_target_q[cell]`

## 9. Nonlinear Coherence Compression

The current executable applies nonlinear coherence compression to raw phase coherence.

The resulting relation is:

`effective coherence = raw phase coherence × coherence compression`

The compression factor decreases under increasing:

- thermal overload;
- stability-margin pressure.

This nonlinear layer preserves a bounded effective coherence response under increasing coupled load.

It is part of the current v1.7.0 processor behavior.

## 10. Dynamic Stability

The current processor tracks:

`C(t)`

`P(t)`

`C(t) - P(t)`

Current destabilizing load:

`P(t) = heat + switch_load`

Required validated condition:

`C_minus_P_min > 0.0`

The current coherence state includes contributions from:

- effective phase coherence;
- cluster coherence;
- neutral-state fraction;
- frequency-lag penalty.

The stability layer therefore remains coupled to the phase, delay, thermal, coherence, and ternary-transition layers.

## 11. Phase-Derived Ternary Targets

The current executable derives automatic ternary targets from the evolving phase field.

Current mapping:

`sin(phase) > 0.33 → 1`

`sin(phase) < -0.33 → -1`

`otherwise → 0`

This mapping connects the resonant phase domain to the balanced ternary state domain.

The ternary target enters bounded distributed transition processing.

The target is processed through:

- transition-fraction control;
- distributed commit;
- active neutral routing;
- pending-route retention;
- scheduler timing.

## 12. Active Neutral Routing

The current processor prohibits actual direct opposite-polarity execution.

Prohibited direct transition:

`-1 ↔ 1`

Validated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Validated tick-separated relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariant:

`actual_direct_events = 0`

Additional current invariants:

`reserved_state_events = 0`

`queue_overflow_events = 0`

## 13. Distributed Commit

The current processor applies bounded distributed transition capacity to the ternary state vector.

Current default transition fraction:

`0.25`

Current relation:

`maximum changes per tick = round(cells × transition_fraction)`

For the default 16-cell configuration:

`request_lanes = 4`

The current default validated switching boundary is:

`switch_load_peak <= 0.25`

Distributed commit connects the resonant phase-derived target path to bounded state transition and retained ternary state.

## 14. Requirements

Use the current CI-aligned Python environment:

`Python 3.12`

Required tools:

- Python;
- pip;
- Git when cloning the repository.

The current dependency file is:

`requirements.txt`

Repository external dependency:

`numpy>=1.26.0`

NumPy is used by the historical FRP v0.9.3 and v0.9.4 executable layers. The current FRP v1.7.0 executable and Comparative Architecture Benchmark Suite use the Python standard library and repository-local modules.

Check the local tools:

    python --version
    python -m pip --version
    git --version

On systems where the interpreter command is:

`python3`

replace `python` with `python3` throughout.

## 15. Obtain the Repository

Clone:

    git clone https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor.git

Enter the repository directory:

    cd Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

Confirm that the current executable reference exists:

    python -c "from pathlib import Path; p=Path('frp_prototype_v1_7_0.py'); print(p, p.exists())"

Required result:

`frp_prototype_v1_7_0.py True`

When using a downloaded archive instead of Git, unpack the complete archive and run the remaining commands from the repository root.

## 16. Create a Virtual Environment

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

## 17. Install Dependencies

Upgrade pip:

    python -m pip install --upgrade pip

Install the declared dependency set:

    python -m pip install -r requirements.txt

Verify NumPy:

    python -c "import numpy; print(numpy.__version__)"

The installed version must satisfy:

`numpy>=1.26.0`

## 18. Compile Gate

Run:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

A successful compile gate completes with exit status `0`.

## 19. Inspect the Current Command Interface

Run:

    python frp_prototype_v1_7_0.py --help

The current interface includes:

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
- `--export-fixed-point-interface-profile`;
- `--export-balanced-ternary-hardware-encoding-map`;
- `--export-quantized-reference-shadow-model`;
- `--export-cycle-exact-reference-trace`;
- `--export-rtl-comparison-vector-package`;
- `--export-systemverilog-testbench-interface-map`;
- `--export-synthesizable-rtl-reference-core`;
- `--export-rtl-assertion-correlation-harness`;
- `--export-reference-rtl-equivalence-report`;
- `--export-qualification-closure-manifest`;
- `--export-benchmark-matrix`.

## 20. First Processor Run

Run the current executable reference:

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

## 21. What the First Run Demonstrates

The first run executes the current coupled processor path:

`phase and frequency state`

↓

`Kuramoto-Sakaguchi coupling`

↓

`hierarchical resonant interaction`

↓

`phase evolution`

↓

`resonance selection`

↓

`global and multiscale coherence`

↓

`delay and thermal feedback`

↓

`nonlinear coherence compression`

↓

`dynamic stability evaluation`

↓

`phase-derived ternary target`

↓

`distributed transition`

↓

`active neutral routing`

↓

`retained ternary state`

The first run therefore exercises both the resonant computational mechanism and the balanced ternary state-retention mechanism.

## 22. Structured JSON First Run

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
| gamma | `0.30 × pi` |
| fractal alpha | `0.70` |
| coupling nominal | `0.28` |
| delay alpha | `0.30` |

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

## 23. Full Trace Output

Run:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace

The full structured output adds:

- `trace`;
- `cell_trace`;
- `route_events`.

The default configuration records:

- `64` processor ticks;
- `1024` cell-tick rows;
- route-event history;
- phase and coherence telemetry;
- thermal and stability telemetry.

Use full trace output when exact tick-by-tick or cell-by-cell inspection is required.

## 24. Standard Self-Test

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

## 25. Full Scheduler Self-Test Matrix

Run the default profile:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Run the free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

Run the 7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

Run the 1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every profile must report:

`status = PASS`

`check_count = 41`

All 41 checks must be:

`True`

## 26. Scheduler Layer

The current executable preserves three scheduler modes.

| Scheduler | 16-tick validated profile |
|---|---|
| `free` | `free = 16` |
| `7/1` | `balance = 14`, `commit = 2` |
| `1/7` | `excite = 2`, `neutralize = 14` |

Validated default 64-tick 7/1 profile:

`balance = 56`

`commit = 8`

The scheduler contributes directly to the resonant phase layer.

The current executable also applies scheduler-dependent phase push during phase evolution.

## 27. Cell-Count Rule

The `--cells` value must be:

- a power of two;
- at least `2`.

Valid examples:

`2`

`8`

`16`

`32`

The current command interface validates this cell-count rule before execution.

## 28. Balanced Ternary Hardware Encoding

FRP v1.7.0 defines the canonical two-bit balanced ternary encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Required invariant:

`reserved_state_events = 0`

The hardware encoding provides the hardware-facing representation of the ternary state domain within the complete FRP computational mechanism.

The resonant phase-coherence core remains upstream of the ternary target, transition, and retained-state path.

## 29. M15 Hardware-Facing Numeric Profile

Current primary numeric representations:

| Domain | Representation |
|---|---|
| general dynamic scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| Sakaguchi gamma offset | `GAMMA_S32` |

Current deterministic trigonometric profile:

`4096-entry full-cycle lookup table`

Validated exactness markers:

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

## 30. Benchmark-Matrix Smoke Check

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

## 31. M15 Export Smoke Check

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

## 32. M15 Artifact Schemas

| Artifact | Required schema |
|---|---|
| fixed-point interface profile | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| balanced ternary hardware encoding map | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| quantized reference shadow model | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| cycle-exact reference trace | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| RTL comparison vector package | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| SystemVerilog testbench interface map | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| synthesizable RTL reference core | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| RTL assertion correlation harness | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| reference RTL equivalence report | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| qualification closure manifest | `frp.m15.qualification_closure_manifest.v1.7.0` |

## 33. Deterministic RTL Vector Check

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

`byte-identical equality`

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

The independently generated vector directories must be byte-identical.

## 34. Scaling Smoke Check

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
- valid scheduler counts;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 35. Installation Acceptance Criteria

The current processor installation is ready when:

- the repository has been cloned or unpacked completely;
- `frp_prototype_v1_7_0.py` exists;
- the declared dependency is installed;
- the compile gate completes with exit status `0`;
- the default processor demo runs;
- the structured output reports schema `frp.structured_output.v1.7.0`;
- the Kuramoto-Sakaguchi resonant phase layer executes;
- the phase-evolution path executes;
- the Kuramoto order parameter and multiscale coherence path execute;
- the phase-derived ternary target path executes;
- the balanced ternary state domain remains valid;
- `actual_direct_events = 0`;
- the standard self-test reports `41/41 PASS`;
- all scheduler-specific self-tests report `41/41 PASS`;
- the benchmark matrix reports the five expected rows;
- the qualification closure manifest reports `PASS`.

For complete deterministic vector reproduction, also require byte-identical equality between independently generated vector directories.

### Published GitHub Actions validation evidence

The root `README.md` exposes 18 active validation badges for the published FRP workflow chain.

The repository contains 19 GitHub Actions workflow files.

The current release evidence recorded in `TEST_REPORT_v1_7_0.md` and `RELEASE_NOTES_v1_7_0.md` includes:

- validated release commit `5fd9a4f`;
- `FRP Structured Output #113 — PASS`;
- `FRP M15 Implementation Mapping and Qualification Closure #1 — PASS`;
- `FRP Self Test #154 — PASS`;
- `FRP Benchmark Smoke Test #152 — PASS`.

The current published M15 result is:

`PASS`

The current validated M15 self-test result is:

`41/41 PASS`

## 36. Saving Output

Save the default structured demo:

    python frp_prototype_v1_7_0.py --mode demo --output json > frp-v1.7.0-demo.json

Save the full trace:

    python frp_prototype_v1_7_0.py --mode demo --output json --include-trace > frp-v1.7.0-demo-trace.json

Save the self-test result:

    python frp_prototype_v1_7_0.py --mode self-test --output json > frp-v1.7.0-self-test.json

Save the benchmark matrix:

    python frp_prototype_v1_7_0.py --mode benchmark > frp-v1.7.0-benchmark-matrix.json

Save the qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > frp-v1.7.0-qualification-closure.json

## 37. Running Through the Virtual-Environment Interpreter

Direct interpreter invocation provides the complete virtual-environment execution path.

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

## 38. Updating an Existing Clone

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

## 39. Troubleshooting

### Python command resolution

Check the available interpreter command:

    python3 --version

Use `python3` for the remaining commands when that interpreter is available.

### pip command resolution

Use:

    python -m pip install -r requirements.txt

### NumPy import verification

Run:

    python -m pip install -r requirements.txt

Then verify:

    python -c "import numpy; print(numpy.__version__)"

### Virtual-environment interpreter path

Use the virtual-environment interpreter directly as shown in Section 37.

### PowerShell blocks activation

Use:

    .venv\Scripts\python.exe frp_prototype_v1_7_0.py --mode self-test --output json

Direct interpreter invocation uses the virtual environment immediately.

### `--cells` validation

The current executable requires:

- a power-of-two cell count;
- at least `2` cells.

Valid examples:

`2`

`8`

`16`

`32`

### Self-test result diagnosis

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

## 40. Complete Current Technical Chain

The repository preserves the processor architecture and qualification chain:

`balanced ternary state and retained-result domain {-1, 0, 1}`

↓

`Kuramoto-Sakaguchi resonant phase coupling`

↓

`hierarchical fractal phase interaction`

↓

`phase evolution`

↓

`resonance selection`

↓

`Kuramoto order parameter R`

↓

`multiscale phase coherence`

↓

`delay dynamics`

↓

`local thermal-phase interaction`

↓

`local correlated gamma drift`

↓

`nonlinear coherence compression`

↓

`dynamic stability C(t) - P(t)`

↓

`phase-derived ternary target`

↓

`distributed commit`

↓

`active neutral routing`

↓

`retained ternary state`

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

`reference equivalence`

↓

`qualification closure`

The resonant computational core remains the processor mechanism throughout this chain.

The balanced ternary domain remains the state and retained-result domain throughout this chain.

## 41. Current File Alignment

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

## 42. Current Status

Processor:

`Fractal Resonance Processor (FRP)`

Processor class:

`Ternary Resonant Coherence Processor`

Computational mechanism:

`Kuramoto-Sakaguchi resonant phase dynamics with hierarchical fractal coupling, phase evolution, resonance selection, Kuramoto order parameter R, multiscale phase coherence, delay dynamics, coupled thermal-phase behavior, nonlinear coherence compression, phase-derived ternary targets, distributed commit, and mandatory active-neutral routing`

State and retained-result domain:

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

Current published validation result:

`PASS`

Current validated self-test result:

`41/41 PASS`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`






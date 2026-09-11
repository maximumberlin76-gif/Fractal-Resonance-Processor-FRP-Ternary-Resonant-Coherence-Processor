# FRP M32 FPGA Integration Boundary Closure

## Boundary identity

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Closed directory | `fpga/m32/` |
| FPGA top | `frp_m32_fpga_top` |
| Integrated core | `frp_m32_core` |
| Qualification testbench | `frp_m32_fpga_tb` |
| Qualified configuration | `8` cells, `2` request lanes |
| Canonical ternary kernel | `-1/0/1` |
| Scheduler modes | `free`, `7/1`, `1/7` |
| Qualification commit | `e40e90d8e32847aa783030aba7e1e5f7963ef312` |
| Documentation antecedent commit | `5c519886a56ba33f6ef63fdd5271d221055c3d93` |
| Closure status | `M32 FPGA INTEGRATION BOUNDARY CLOSED` |

This closure covers the implemented FPGA wrapper, complete M32 core
integration, reset control, operation gating, deterministic integration
simulation, and flattened memory-preserving synthesis through
`Yosys synth -run begin:fine`.

## Qualification authority

| Record | Value |
|---|---|
| Workflow | [FRP M32 FPGA Integration Qualification](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) |
| Successful run | [#2](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| Run ID | `34531635873` |
| Run attempt | `1` |
| Job ID | `103053501919` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Run started | `2026-09-10T21:20:28Z` |
| Run updated | `2026-09-10T21:23:12Z` |
| Recorded duration | `2m 44s` |
| Status | `completed` |
| Conclusion | `success` |
| Stable qualification result | `FRP M32 FPGA integration qualification: PASS` |

The [qualified workflow source](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/e40e90d8e32847aa783030aba7e1e5f7963ef312/.github/workflows/frp-m32-fpga-integration-qualification.yml)
defines the source identities, execution commands, replay comparisons,
structural checks, and evidence outputs used by this closure.

The complete qualification record is preserved in
[SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md), committed at
`5c519886a56ba33f6ef63fdd5271d221055c3d93`. Repository checks for that
documentation commit completed successfully:

| Repository check | Result |
|---|---|
| [FRP Self Test #724](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34578739016) | `SUCCESS` |
| [FRP Structured Output #680](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34578739121) | `SUCCESS` |
| [FRP Benchmark Smoke Test #720](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34578738997) | `SUCCESS` |

## Closed artifacts

| Artifact | Function |
|---|---|
| [frp_m32_fpga_top.sv](frp_m32_fpga_top.sv) | complete M32 core integration, asynchronous reset assertion, two-stage release, and operation gating |
| [frp_m32_fpga_tb.sv](frp_m32_fpga_tb.sv) | deterministic FPGA integration scenarios and output comparison against a separate M32 core |
| [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md) | successful run, source identities, simulation record, synthesis checks, and published artifact metadata |
| [CLOSURE.md](CLOSURE.md) | FPGA integration closure scope and accepted qualification results |

The FPGA wrapper instantiates
[frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv). Its inherited M32 RTL
boundary is recorded in [rtl/m32/CLOSURE.md](../../rtl/m32/CLOSURE.md).

The FPGA qualification manifest verifies `19` canonical inputs:

| Input class | Files |
|---|---:|
| M31 SystemVerilog dependencies | 13 |
| M32 SystemVerilog dependencies | 3 |
| FPGA top and testbench | 2 |
| Canonical sine ROM | 1 |
| Total | 19 |

The workflow identity is recorded separately. Exact byte lengths and
SHA-256 values are retained in `source-manifest.json` and
`canonical-sources.sha256`, with the workflow SHA-256 in the manifest.

## Integration and execution closure

The FPGA top forwards the complete M32 core output interface and exposes
`core_ready` from the second reset-release stage. Phase-derived targets,
registered targets, execution requests, retained ternary states, and
pending routes retain their separate core interfaces.

| Qualification check | Accepted result |
|---|---|
| Complete FPGA interface | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| Forwarded core outputs | all `59` outputs compared against a separate `frp_m32_core` instance |
| Output samples | `1019` per simulation replay |
| Readiness | checked separately against the release edge supplied by each test scenario |
| External reset assertion | asynchronous, exercised between clock edges |
| Reset release | two rising edges; enabled core operation first sampled on the following rising edge |
| Interrupted release | reset reassertion restarts both release stages |
| Controls before readiness | tick, counter clear, phase load, automatic request selection, and external request validity blocked |
| Startup pulses | pulses ending before readiness discarded |
| Held controls | delivered at the first active core edge |
| Phase and frequency loading | checked with `tick_enable` low |
| Registered-target capture | first capture matches the phase target sampled before the active edge |
| Paused execution | retained state, pending routes, targets, phase, frequency, scheduler state, and thermal sample count preserved |
| Isolated counter clear | counters clear while retained data is preserved |
| Concurrent clear and tick | scheduler records one tick; target-capture and thermal counters retain clear priority |
| Simulation replay | two complete, byte-identical semantic terminal records |

## Balanced ternary and scheduler closure

The retained state domain is `-1/0/1`. State `0` is active and retained,
including during the intermediate leg of an opposite-polarity route.

| State | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| Reserved | `2'b10` |

Both mandatory routes are exercised as separate retained transitions:

| Route | Verified intermediate state | Verified completion |
|---|---|---|
| `1 -> 0 -> -1` | active zero with pending `-1`, retained during three paused cycles | next enabled tick without a new request |
| `-1 -> 0 -> 1` | active zero with pending `1`, retained during three paused cycles | next enabled tick without a new request |

Direct transitions `1 -> -1` and `-1 -> 1` are rejected by the testbench.
`actual_direct_events`, `reserved_state_events`, and `queue_overflow_events`
remain zero throughout the checked samples.

Both scheduler modes are present in the qualified execution:

| Mode | Repeating eight-tick cadence |
|---|---|
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Each scenario records `97` ticks and `97` accepted target captures. The
initial tick executes the reset scheduler state `FREE`; the following
`96` ticks cover twelve complete periods for `7/1` and `1/7`.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE |
|---|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 |
| `7/1` | 1 | 84 | 12 | 0 | 0 |
| `1/7` | 1 | 0 | 0 | 12 | 84 |

## Complete integration synthesis closure

The qualified synthesis uses `yowasp-yosys==0.68.0.0.post1208`, the
`read_slang` frontend with IEEE `1800-2017`, and the complete
`frp_m32_fpga_top` hierarchy at `CELLS=8` and `REQUEST_LANES=2`.

The synthesis source view is prepared outside the Git working tree. Its
verified phase-source transformation retains `$readmemh` initialization;
the transformation is recorded in `synthesis-view.patch`.

| Synthesis check | Accepted result |
|---|---|
| Flow | `synth -top frp_m32_fpga_top -run begin:fine` |
| Structural check | `check -assert` |
| Flattened top | one module named `frp_m32_fpga_top` |
| Port contract | exact names, directions, and widths for all `75` ports |
| Remaining processes | `0` |
| Latch cells | `0` |
| Unresolved module instances | `0` |
| Memory cells | `2` cells of type `$mem_v2` |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Core readiness and core reset consumers | driven by the second synchronizer stage |
| Sine ROM | `4096 x 32`, `12` address bits, `72` read ports, `0` write ports |
| Sine ROM contents | exact match to all `4096` canonical initialization words |
| Statistics consistency | cell count and cell-type inventory match the JSON netlist |
| Synthesis replay | two byte-identical JSON netlists, Verilog netlists, and statistics records |
| Repository integrity | canonical sources, workflow identity, checked-out commit, and clean working tree verified |

The generated cell count and cell-type inventory are retained in
`qualification.json`, `stat-run-1.json`, and `stat-run-2.json`.

## Evidence closure

| Evidence field | Recorded value |
|---|---|
| Qualification schema | `frp.m32.fpga-integration-qualification.v1` |
| Published artifact ID | `10173809390` |
| Published artifact name | `frp-m32-fpga-qualification-e40e90d8e32847aa783030aba7e1e5f7963ef312-1` |
| Run association | `34531635873`, attempt `1` |
| Source association | `e40e90d8e32847aa783030aba7e1e5f7963ef312` |
| Runtime records | toolchain, lint, build, simulation, and synthesis logs |
| Reproducibility records | source manifest, canonical source hashes, synthesis scripts, replay outputs, and `artifacts.sha256` |
| Qualification result | `PASS` |

The [published-artifact record](SIMULATION_TRANSCRIPT.md#published-qualification-artifact)
contains the archive metadata and workflow-produced evidence-file inventory.
The [committed transcript](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/5c519886a56ba33f6ef63fdd5271d221055c3d93/fpga/m32/SIMULATION_TRANSCRIPT.md)
preserves the qualification record at the documentation antecedent commit.

## Closure result

`M32 FPGA INTEGRATION BOUNDARY CLOSED`

`FRP M32 FPGA Integration Qualification #2: SUCCESS`

`FRP M32 FPGA integration qualification: PASS`

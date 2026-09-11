# FRP M32 FPGA Integration and Post-Synthesis Boundary Closure

## Boundary identity

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Closed directory | `fpga/m32/` |
| FPGA top | `frp_m32_fpga_top` |
| Integrated core | `frp_m32_core` |
| Integration testbench | `frp_m32_fpga_tb` |
| Post-synthesis testbench | `frp_m32_fpga_post_synthesis_tb` |
| Generated simulation DUT | `frp_m32_fpga_netlist` |
| Qualified configuration | `8` cells, `2` request lanes |
| Canonical ternary kernel | `-1/0/1` |
| Scheduler modes | `free`, `7/1`, `1/7` |
| Integration qualification commit | `e40e90d8e32847aa783030aba7e1e5f7963ef312` |
| Integration transcript commit | `5c519886a56ba33f6ef63fdd5271d221055c3d93` |
| Post-synthesis source baseline | `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1` |
| Post-synthesis transcript commit | `20ac396` |
| Integration closure status | `M32 FPGA INTEGRATION BOUNDARY CLOSED` |
| Post-synthesis closure status | `M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED` |

This closure covers the implemented FPGA wrapper, complete M32 core
integration, reset control, operation gating, deterministic integration
simulation, flattened memory-preserving synthesis through
`Yosys synth -run begin:fine`, simulation netlist export, and deterministic
comparison of the synthesized FPGA netlist against a separate M32 RTL core.

The closed configuration is `8` cells and `2` request lanes. Each
simulation qualification executes two replays with `1019` checked samples
per replay, covering all `59` forwarded core outputs and independent
readiness checks.

## Qualification authority

### FPGA integration qualification

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

### FPGA post-synthesis qualification

| Record | Value |
|---|---|
| Workflow | [FRP M32 FPGA Post-Synthesis Qualification](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| Successful workflow run | `#1` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Recorded duration | `13m 36s` |
| Conclusion | `success` |
| Repository source baseline | `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1` |
| Job name defined by the workflow | `Synthesize and simulate the complete M32 FPGA netlist` |
| Qualification terminal record | `FRP M32 FPGA post-synthesis qualification: PASS` |

The successful manual run is recorded in the
[post-synthesis workflow run list](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml).
The [workflow at the source baseline](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/16a40d0687df20ea62dacdfb72e39ef6c22ec9c1/.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml)
defines the source identities, synthesis and export checks, simulator
inputs, ordered terminal records, and evidence binding.

The [post-synthesis transcript](POST_SYNTHESIS_TRANSCRIPT.md), committed at
[`20ac396`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/commit/20ac396),
records the successful run and the workflow acceptance contract.
Repository checks for that documentation commit completed successfully:

| Repository check | Result |
|---|---|
| FRP Self Test #730 | `SUCCESS` |
| FRP Structured Output #686 | `SUCCESS` |
| FRP Benchmark Smoke Test #726 | `SUCCESS` |

The generated post-synthesis `qualification.json` binds the execution to
its exact `source_commit`, `run_id`, and `run_attempt`.

## Closed artifacts

| Artifact | Function |
|---|---|
| [frp_m32_fpga_top.sv](frp_m32_fpga_top.sv) | complete M32 core integration, asynchronous reset assertion, two-stage release, and operation gating |
| [frp_m32_fpga_tb.sv](frp_m32_fpga_tb.sv) | deterministic FPGA integration scenarios and output comparison against a separate M32 core |
| [frp_m32_fpga_post_synthesis_tb.sv](frp_m32_fpga_post_synthesis_tb.sv) | deterministic synthesized-netlist comparison against a separate M32 RTL core |
| [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md) | successful run, source identities, simulation record, synthesis checks, and published artifact metadata |
| [POST_SYNTHESIS_TRANSCRIPT.md](POST_SYNTHESIS_TRANSCRIPT.md) | successful post-synthesis run, source boundary, export checks, simulation records, and evidence layout |
| [Integration qualification workflow](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) | manual FPGA integration simulation and synthesis qualification |
| [Post-synthesis qualification workflow](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) | manual synthesis, simulation export, netlist comparison, and evidence binding |
| [CLOSURE.md](CLOSURE.md) | FPGA integration and post-synthesis closure scopes and accepted results |

The FPGA wrapper instantiates
[frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv). Its inherited M32 RTL
boundary is recorded in [rtl/m32/CLOSURE.md](../../rtl/m32/CLOSURE.md).

Each FPGA qualification manifest verifies `19` canonical inputs:

| Input class | Files |
|---|---:|
| M31 SystemVerilog dependencies | 13 |
| M32 SystemVerilog dependencies | 3 |
| FPGA top and the selected qualification testbench | 2 |
| Canonical sine ROM | 1 |
| Total | 19 |

The two manifests share the same `18` non-testbench inputs with identical
byte lengths and SHA-256 values. Integration simulation selects
`frp_m32_fpga_tb.sv`; post-synthesis simulation selects
`frp_m32_fpga_post_synthesis_tb.sv`.

Each workflow identity is recorded separately. Exact byte lengths and
SHA-256 values are retained in that workflow's `source-manifest.json` and
`canonical-sources.sha256`, with its workflow SHA-256 in the manifest.

## Integration and execution closure

The FPGA top forwards the complete M32 core output interface and exposes
`core_ready` from the second reset-release stage. Phase-derived targets,
registered targets, execution requests, retained ternary states, and
pending routes retain their separate core interfaces.

The integration and post-synthesis workflows enforce the following
checks. Both testbenches compare outputs against separate `frp_m32_core`
reference instances.

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

Direct transitions `1 -> -1` and `-1 -> 1` are rejected by both testbenches.
`actual_direct_events`, `reserved_state_events`, and `queue_overflow_events`
remain zero throughout the checked samples.

Both scheduler modes are present in integration and post-synthesis
qualification:

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
| Integrated logic size check | at least `7000` synthesized cells |
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
The post-synthesis workflow additionally retains the structural results
in `structure.json` before producing the final qualification report.

## Post-synthesis closure

Each synthesized JSON netlist is read into the same pinned Yosys package
and exported for simulation using this sequence:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_fpga_top frp_m32_fpga_netlist

The standard `$shiftx` map produces explicit selection logic for signed
indices. The original synthesis JSON files retain their byte identities.
The two resulting simulation JSON files match each other byte for byte;
the two simulation Verilog files also match each other byte for byte.

| Post-synthesis check | Accepted result |
|---|---|
| Synthesized DUT | generated module `frp_m32_fpga_netlist` |
| Simulation top | `frp_m32_fpga_post_synthesis_tb` |
| Reference | separate `frp_m32_core` RTL instance |
| Exported module set | one flattened simulation module |
| Exported port contract | names, directions, widths, and signedness preserved from synthesis |
| Memory contract | all `$mem_v2` parameters and initialization preserved |
| Remaining processes and latch cells | `0` |
| Remaining `$shiftx` and `$connect` cells | `0` |
| Reset-qualified observation wires | five names and widths preserved |
| Simulation cell models | `simlib.v` from `yowasp-yosys==0.68.0.0.post1208` |
| Forwarded core outputs | all `59` compared against the RTL reference |
| Checked samples | `1019` per replay |
| Readiness | checked against scenario-defined release independently of the DUT |
| Scheduler scenarios | `free`, `7/1`, `1/7` |
| Active-zero routes | `1 -> 0 -> -1` and `-1 -> 0 -> 1`, with pending polarity retained during pause |
| Simulation replays | two complete, byte-identical semantic terminal records |

The five observed flattened wires correspond to `tick_enable`,
`clear_counters`, `phase_load_valid`, `auto_target_enable`, and
`external_request_valid` inside `u_m32_core`. They are observed only;
the reference reset is supplied by independent scenario expectations.

The simulator uses the generated DUT Verilog together with the
post-synthesis testbench and the recorded Yosys `simlib.v`. The build uses
`--timing --assert` and `-DSIMLIB_NOCONNECT`, following the export check
that requires no `$connect` cell in the design.

The reference reads the canonical sine ROM file. The synthesized DUT
uses the ROM initialization embedded in the exported netlist. Both the
synthesis content check and the export parameter check preserve the
canonical ROM boundary.

The workflow requires these ordered terminal records in each replay:

    PASS: startup pulses discarded; phase load without tick
    PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause
    PASS: reset reassertion restarts both release stages
    PASS: free, 97 ticks, pause, isolated and concurrent clear
    PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear
    PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear
    PASS: 59 synthesized outputs match standalone M32 across 1019 samples
    FRP M32 FPGA post-synthesis testbench PASS

The ordered records are saved as `post-synthesis-run-1.txt` and
`post-synthesis-run-2.txt` and compared byte for byte. Complete simulator
output is retained in `post-synthesis-run-1.log` and
`post-synthesis-run-2.log`.

Both workflows reject `PINMISSING`, `IMPLICIT`, and `MULTIDRIVEN`
diagnostics in the top lint and testbench build logs.

## Evidence closure

### Integration evidence

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

### Post-synthesis evidence

| Evidence field | Recorded contract |
|---|---|
| Qualification schema | `frp.m32.fpga-post-synthesis-qualification.v1` |
| Artifact name expression | `frp-m32-fpga-post-synthesis-${{ github.sha }}-${{ github.run_attempt }}` |
| Source and execution association | `source_commit`, `run_id`, and `run_attempt` in `qualification.json` |
| Canonical source identities | `source-manifest.json`, `canonical-sources.sha256` |
| Synthesis records | both synthesis scripts, logs, JSON netlists, Verilog netlists, and statistics |
| Structural result | `structure.json` |
| Simulation export records | both export scripts, logs, JSON netlists, and Verilog netlists |
| Export identity and contract checks | `simulation-export.json` |
| Yosys support files | `yosys-simlib.v`, `yosys-techmap.v`, and `cell-models.json` |
| Simulation records | both complete logs and both semantic terminal records |
| Final qualification report | `qualification.json` |
| Evidence checksums | `artifacts.sha256` |
| Required nonempty inputs to the final report | `35` evidence files |
| Complete evidence directory | `37` files, including the final report and checksum list |
| Configured artifact retention | `30` days |
| Qualification result | `PASS` |

The final report is written after structural checks, simulation export,
both simulation replays, and repository-integrity checks succeed. It
records the sizes and SHA-256 values of all `35` required evidence files.
The checksum list covers the other `36` files, including the final report.

Before writing that result, the workflow rechecks all canonical source
identities, its own identity, the checked-out commit, the clean Git
working tree, and the copied Yosys support-file identities.

The complete workflow-defined evidence inventory is preserved in
[POST_SYNTHESIS_TRANSCRIPT.md](POST_SYNTHESIS_TRANSCRIPT.md). The
[committed post-synthesis transcript](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/20ac396/fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md)
records the successful run and the source baseline used by this closure.

## Closure result

`M32 FPGA INTEGRATION BOUNDARY CLOSED`

`M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED`

`FRP M32 FPGA Integration Qualification #2: SUCCESS`

`FRP M32 FPGA Post-Synthesis Qualification #1: SUCCESS`

`FRP M32 FPGA integration qualification: PASS`

`FRP M32 FPGA post-synthesis qualification: PASS`

# FRP M32 CSR Integration Simulation and Synthesis Transcript

## Qualification record

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Layer | CSR control and telemetry around the complete M32 FPGA integration |
| Workflow | `FRP M32 CSR Integration Qualification` |
| Workflow file | [frp-m32-csr-integration-qualification.yml](../../.github/workflows/frp-m32-csr-integration-qualification.yml) |
| Successful run | [#1](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270) |
| Run ID | `34689613270` |
| Run attempt | `1` |
| Qualified commit | `8e619504c7826ba6351d4967d5944685963363f0` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Run started | `2026-09-12T10:53:11Z` |
| Run updated | `2026-09-12T10:55:47Z` |
| Recorded run duration | `2m 36s` |
| Status | `completed` |
| Conclusion | `success` |
| Job ID | `103542454966` |
| Job | `Simulate and synthesize the complete M32 CSR integration` |
| Job conclusion | `success` |

The [run record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270)
and [job record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270/jobs)
publish the execution identity and step conclusions. The checks and
terminal records below are defined by the
[workflow at the qualified commit](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/8e619504c7826ba6351d4967d5944685963363f0/.github/workflows/frp-m32-csr-integration-qualification.yml).

## Qualified source boundary

| Component | Source | Configuration |
|---|---|---|
| CSR top | [frp_m32_csr_top.sv](frp_m32_csr_top.sv) | `frp_m32_csr_top`, 8 cells, 2 request lanes, 32-bit words and counters |
| CSR testbench | [frp_m32_csr_tb.sv](frp_m32_csr_tb.sv) | `frp_m32_csr_tb`, independent host stimulus and reset model |
| FPGA integration | [frp_m32_fpga_top.sv](../m32/frp_m32_fpga_top.sv) | `dut.u_fpga`, complete M32 core and two-stage reset release |
| Reference core | [frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv) | separate core instance with the same fixed profile |
| Base CSR definitions | [frp_m22_csr_pkg.sv](../../rtl/m22/frp_m22_csr_pkg.sv) | existing register and command definitions |
| Sine ROM | [frp_m31_sin_q30.mem](../../rtl/m31/frp_m31_sin_q30.mem) | 4096 words, 32 bits per word |

The workflow verifies byte lengths and SHA-256 identities for the complete
include closure and ROM initialization file.

| Source class | Files |
|---|---:|
| M22 CSR package | 1 |
| M31 SystemVerilog dependencies | 13 |
| M32 SystemVerilog dependencies | 3 |
| FPGA top | 1 |
| CSR top and testbench | 2 |
| Sine ROM initialization file | 1 |
| Total canonical inputs | 21 |

The workflow records its own identity separately from these 21 inputs.

| File | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32_csr/frp_m32_csr_top.sv` | 21826 | `c3d5e9060f8142acfb39310f2e47cca5a3f38c786a9bfdbb6686b2c86ff60344` |
| `fpga/m32_csr/frp_m32_csr_tb.sv` | 30914 | `af2795bf906c4c0c9aa2c2eac502bb3aa952fd5c179e2760c228a69bbc6a5a33` |
| `rtl/m31/frp_m31_sin_q30.mem` | 36864 | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| `.github/workflows/frp-m32-csr-integration-qualification.yml` | 27500 | `ec1aa8b7c0132c40f1b17718630e27fb51f139ad443e176b411491ebf7db966e` |

## Execution configuration

| Setting | Value |
|---|---|
| Runner image | `ubuntu-24.04` |
| Python selection | `3.12` |
| Simulation and lint | Verilator |
| Native build tools | `g++`, `make` |
| C++ build flags | `-std=c++20 -O0` |
| Native build jobs | `2` |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017`, one worker |
| Locale and time zone | `C.UTF-8`, `UTC` |
| Python hash seed | `0` |
| Simulation replays | `2` |
| Synthesis replays | `2` |

Resolved tool versions are recorded in `toolchain.log`; Python package
versions are recorded in `python-packages.txt`.

Temporary evidence, source and build directories are initialized from
`RUNNER_TEMP` and passed to later steps through `GITHUB_ENV`.

| Variable | Directory |
|---|---|
| `M32_EVIDENCE` | `$RUNNER_TEMP/frp-m32-csr-evidence` |
| `M32_SOURCE` | `$RUNNER_TEMP/frp-m32-csr-source` |
| `M32_BUILD` | `$RUNNER_TEMP/frp-m32-csr-build` |

## Completed qualification steps

GitHub records `success` for every workflow step below.

| Step | Result |
|---|---|
| Initialize temporary paths | `success` |
| Check out dispatched commit | `success` |
| Set up Python 3.12 | `success` |
| Require manual main execution and prepare reports | `success` |
| Verify exact sources and include closure | `success` |
| Install and record simulation and synthesis tools | `success` |
| Lint the complete CSR top | `success` |
| Build the complete CSR integration testbench | `success` |
| Execute and compare two complete simulation runs | `success` |
| Prepare the verified synthesis source view | `success` |
| Synthesize the complete CSR integration twice | `success` |
| Validate ports, reset stages, ROM, and repository integrity | `success` |
| Upload qualification reports and diagnostic logs | `success` |
| Publish qualification summary | `success` |

The lint and build checks reject `PINMISSING`, `IMPLICIT` and
`MULTIDRIVEN` diagnostics. Complete diagnostic output is retained in
`top-lint.log` and `testbench-build.log`.

## Simulation record

The testbench compares all 59 core outputs exposed by `dut.u_fpga` against
a separate `frp_m32_core` instance after each rising clock edge. The
reference inputs and reset model are driven from the test stimulus;
expected CSR responses are independent of DUT ready/error decisions.

The successful simulation step requires exactly one occurrence of this
terminal record in each replay:

    FRP_M32_CSR_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

| Field | Meaning |
|---|---|
| `checks=6905` | full 59-output comparison rounds plus explicit CSR read checks |
| `ticks=306` | executed stimulus ticks across all reset epochs |
| `rejected_transfers=449` | completed transfers expected to report a CSR error |
| `core_outputs=59` | outputs compared in every core comparison round |

Both complete simulator logs are compared byte for byte. A failed
comparison or testbench timeout terminates simulation with `$fatal`.

### CSR transfer and reset checks

| Scenario | Checked behavior |
|---|---|
| Asynchronous reset assertion | bus readiness, error and read data are zero |
| Two-stage reset release | commands cannot execute before qualified readiness |
| Startup tick withdrawn before readiness | no recorded tick or target capture |
| 192 unaligned addresses | both reads and writes are rejected: 384 transfers |
| 52 read-only register addresses | writes are rejected |
| Invalid command and payload cases | 13 additional rejected transfers |
| Invalid payload coverage | CONTROL, mode, lane, request cell, selected cell, ternary target, request-valid and auto-target fields |
| Idle, write and error responses | unused read data remains zero |
| Staged requests | each accepted tick clears staged request-valid bits |
| Request clear | staged valid bits clear without issuing a tick |
| Both request lanes | independently staged requests reach their selected cells |
| Duplicate-cell requests | lane 0 accepted, lane 1 rejected in the directed scenario |
| Consecutive valid transfers | three consecutive accepted edges produce three ticks |
| Reset after staged requests and auto mode | staged state and captured results are cleared |

The rejected-transfer total is `384 + 52 + 13 = 449`.

### Active-zero routing and retained state

The ternary kernel is `-1/0/1`, with active state `0`. Direct transitions
`-1 -> 1` and `1 -> -1` are forbidden; the testbench exercises both routes
through active zero on separate enabled ticks.

| Route | Intermediate checks | Completion |
|---|---|---|
| `1 -> 0 -> -1` | executed state `0`, pending target `-1`; pending route retained through CSR scans and counter clear | later tick completes `0 -> -1` without a new request |
| `-1 -> 0 -> 1` | executed state `0`, pending target `1`; repeated reads preserve the pending route | later tick completes `0 -> 1` without a new request |

Scenario checkpoints require zero `actual_direct_events`,
`reserved_state_events` and `queue_overflow_events`. Counter clear retains
the pending route and active-zero state while resetting the recorded tick
counter.

### Phase, frequency and telemetry checks

All eight phase and frequency words are staged through the selected-cell
CSR window. Live phase and frequency remain unchanged during staging;
the load command applies all eight staged pairs on one edge.

The patterns exercise signed frequency words and phase wraparound.
Distinct per-cell gamma and thermal-factor words exercise every
configuration slice. Automatic requests use the registered phase-target
path of the complete M32 core.

CSR scans compare live phase, retained frequency, coupling, projection,
phase targets, registered targets, executed states, pending routes,
scheduler counters, coherence, thermal and stability outputs. Last-tick
snapshots are checked against reference events sampled before the tick
edge, including request decisions, routing masks and capture decisions.

### Scheduler records

Each mode scenario configures the mode during idle clocks before its
first tick and records 97 ticks and 97 accepted target captures.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 | 97 |
| `7/1` | 0 | 85 | 12 | 0 | 0 | 97 |
| `1/7` | 0 | 0 | 0 | 13 | 84 | 97 |

`7/1` uses seven BALANCE ticks followed by one COMMIT tick. `1/7` uses one
EXCITE tick followed by seven NEUTRALIZE ticks.

A separate consecutive-transfer scenario writes mode `7/1` and issues a
tick on the immediately following rising edge. That tick uses the prior
FREE scheduler state; a later tick records BALANCE. This checks the
existing one-clock mode-registration delay.

## Complete CSR integration synthesis

| Setting | Value |
|---|---|
| Top | `frp_m32_csr_top` |
| Integrated FPGA instance | `u_fpga` |
| Integrated core instance | `u_fpga.u_m32_core` |
| Profile | 8 cells, 2 request lanes, 32-bit words and counters |
| Flow | `synth -top frp_m32_csr_top -noshare -run begin:fine` |
| Structural check | `check -assert` |
| Output structure | one flattened module with retained memories |
| Replay comparison | JSON netlist, Verilog netlist and JSON statistics, byte for byte |

Synthesis uses a temporary copy of the verified inputs. Four post-load
ROM simulation checks are removed from that copy of
`frp_m31_phase_interference.sv`; `$readmemh` initialization is retained.
The transformation is recorded in `synthesis-view.patch`.

The transformed phase source is checked against 10853 bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.
Canonical repository sources retain their original identities.

The successful structural validation step enforces these results:

| Check | Required result |
|---|---|
| Flattened top modules | 1, named `frp_m32_csr_top` |
| Interface | 9 ports: 6 inputs and 3 outputs |
| Total port bits | 78 |
| Port names, directions and widths | exact match to the CSR interface contract |
| Integrated logic guard | at least 7000 Yosys cells |
| Remaining processes | 0 |
| Latch cells | 0 |
| Unresolved module instances | 0 |
| Memory cells | 2 cells of type `$mem_v2`, both read-only |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Synchronizer input | constant `1` into the first stage; first stage into the second |
| Readiness and remaining asynchronous reset consumers | driven by the second synchronizer stage |
| Sine ROM | 4096 x 32, 12 address bits, 72 read ports, 0 write ports |
| Sine ROM initialization | exact match to all 4096 canonical words |
| Statistics | cell count and cell-type inventory agree with the JSON netlist |
| Repeated synthesis | identical JSON netlists, Verilog netlists and statistics |

The resulting cell count and complete inventory are recorded in
`qualification.json`, `stat-run-1.json` and `stat-run-2.json`.

Before writing the qualification result, the workflow rechecks canonical
source identities, workflow identity, checked-out commit and the clean
Git working tree.

Stable qualification terminal record:

    FRP M32 CSR integration qualification: PASS

## Published qualification artifact

The [artifact metadata for this run](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270/artifacts)
records the following archive.

| Field | Recorded value |
|---|---|
| Artifact ID | `10297126685` |
| Artifact name | `frp-m32-csr-qualification-8e619504c7826ba6351d4967d5944685963363f0-1` |
| Size reported by GitHub | `4605171` bytes |
| SHA-256 digest reported by GitHub | `9b72c35d479060365a55dc033c5ddfa4489ad15860131db56d6319f18974ad81` |
| Configured retention | 30 days |
| Qualification schema | `frp.m32.csr-integration-qualification.v1` |

The workflow writes the following evidence files to the uploaded directory.

| Files | Contents |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | 21 canonical input identities and the separate workflow identity record |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, Python packages and synthesis frontend help |
| `top-lint.log`, `testbench-build.log` | CSR top lint and testbench build output |
| `simulation-run-1.log`, `simulation-run-2.log` | complete simulator output, compared byte for byte |
| `synthesis-view.patch` | verified temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys` | executed synthesis commands |
| `synthesis-run-1.log`, `synthesis-run-2.log` | synthesis logs |
| `netlist-run-1.json`, `netlist-run-2.json` | flattened JSON netlists |
| `netlist-run-1.v`, `netlist-run-2.v` | emitted Verilog netlists |
| `stat-run-1.json`, `stat-run-2.json` | synthesis statistics and cell-type inventories |
| `qualification.json` | result, source commit, run identity, simulation, synthesis, reset, ROM and repository-integrity records |
| `artifacts.sha256` | SHA-256 values for the other evidence files |

## Result

`FRP M32 CSR Integration Qualification #1: SUCCESS`

`FRP M32 CSR integration qualification: PASS`

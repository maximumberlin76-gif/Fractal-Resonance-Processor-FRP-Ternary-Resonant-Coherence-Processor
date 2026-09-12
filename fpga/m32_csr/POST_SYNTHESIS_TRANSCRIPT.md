# FRP M32 CSR Post-Synthesis Qualification Transcript

## Qualification record

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Layer | Post-synthesis simulation of the complete CSR integration netlist |
| Workflow | `FRP M32 CSR Post-Synthesis Qualification` |
| Workflow file | [frp-m32-csr-post-synthesis-qualification.yml](../../.github/workflows/frp-m32-csr-post-synthesis-qualification.yml) |
| Successful run | [#1](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701) |
| Run ID | `34699370701` |
| Run attempt | `1` |
| Qualified commit | `dcade95d59457dbd7bd296f7dc2d902f4fa61ddf` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Run started | `2026-09-12T14:28:08Z` |
| Run updated | `2026-09-12T14:41:55Z` |
| Recorded run duration | `13m 47s` |
| Status | `completed` |
| Conclusion | `success` |
| Job ID | `103568293849` |
| Job | `Qualify the synthesized M32 CSR integration` |
| Job conclusion | `success` |

The [run record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701)
and [job record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701/jobs)
publish the execution identity and step conclusions. Commands, mandatory
checks and evidence layout below are taken from the
[workflow at the qualified commit](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/dcade95d59457dbd7bd296f7dc2d902f4fa61ddf/.github/workflows/frp-m32-csr-post-synthesis-qualification.yml)
and its pinned post-synthesis testbench.

## Qualified source and comparison boundary

| Component | Source or module | Configuration |
|---|---|---|
| CSR synthesis top | [frp_m32_csr_top.sv](frp_m32_csr_top.sv) | `frp_m32_csr_top`, 8 cells, 2 request lanes, 32-bit words and counters |
| FPGA integration | [frp_m32_fpga_top.sv](../m32/frp_m32_fpga_top.sv) | complete M32 core with two-stage reset release |
| Post-synthesis testbench | [frp_m32_csr_post_synthesis_tb.sv](frp_m32_csr_post_synthesis_tb.sv) | `frp_m32_csr_post_synthesis_tb` |
| Synthesized DUT | `frp_m32_csr_netlist` | generated from the complete flattened CSR synthesis JSON |
| Independent RTL reference | [frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv) | separate core instance driven by host stimulus and reference reset model |
| Base CSR definitions | [frp_m22_csr_pkg.sv](../../rtl/m22/frp_m22_csr_pkg.sv) | existing register and command definitions |
| Canonical sine ROM | [frp_m31_sin_q30.mem](../../rtl/m31/frp_m31_sin_q30.mem) | 4096 words of 32 bits |

The distinct DUT module name requires the generated simulation netlist.
The reference reads the canonical ROM file; the synthesized DUT uses its
embedded ROM initialization. The testbench observes all 59 core outputs
through retained flattened `u_fpga.*` wires and checks CSR responses
against expectations independent of DUT ready/error decisions.

The workflow verifies byte lengths, SHA-256 identities and the complete
include closure for 21 canonical inputs: one M22 package, 13 M31
SystemVerilog files, three M32 SystemVerilog files, the FPGA top, the CSR
top, the post-synthesis testbench and one sine ROM file. The workflow
identity is recorded separately.

| File | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32_csr/frp_m32_csr_top.sv` | 21826 | `c3d5e9060f8142acfb39310f2e47cca5a3f38c786a9bfdbb6686b2c86ff60344` |
| `fpga/m32_csr/frp_m32_csr_post_synthesis_tb.sv` | 32248 | `788a90ed854871f71f05cd6fac5d2052a289781a011083ff6a58301a5f185281` |
| `rtl/m31/frp_m31_sin_q30.mem` | 36864 | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| `.github/workflows/frp-m32-csr-post-synthesis-qualification.yml` | 36875 | `f5f0be52c41de12130b84fa0f809783049b7d8b8b88df64bc1dbafa16b2f1dca` |

## Execution configuration

| Setting | Value defined by the workflow |
|---|---|
| Runner image | `ubuntu-24.04` |
| Python selection | `3.12` |
| Simulation and lint | Verilator |
| Native build tools | `g++`, `make` |
| C++ build flags | `-std=c++20 -O0` |
| Build workers / output split | `2` / `20000` |
| Simulation options | `--sv --timing --assert --binary` |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017`, one worker |
| Locale / time zone / Python hash seed | `C.UTF-8` / `UTC` / `0` |
| Synthesis / export / simulation replays | `2` / `2` / `2` |
| Each synthesis or export timeout | 300 seconds |
| Each simulation timeout | 120 seconds |
| Job timeout | 30 minutes |
| Repository permission | `contents: read` |

Resolved versions are recorded in `toolchain.log` and
`python-packages.txt`. The workflow requires a manual `main` execution,
the dispatched commit and a clean working tree. Checkout credentials are
not persisted.

Temporary paths are initialized from `RUNNER_TEMP` through `GITHUB_ENV`.

| Variable | Directory |
|---|---|
| `M32_EVIDENCE` | `$RUNNER_TEMP/frp-m32-csr-post-synthesis-evidence` |
| `M32_SOURCE` | `$RUNNER_TEMP/frp-m32-csr-post-synthesis-source` |
| `M32_BUILD` | `$RUNNER_TEMP/frp-m32-csr-post-synthesis-build` |

## Completed qualification steps

GitHub records `success` for all 17 workflow-defined steps.

| Step | Result |
|---|---|
| Initialize temporary paths | `success` |
| Check out dispatched commit | `success` |
| Set up Python 3.12 | `success` |
| Require manual main execution and prepare reports | `success` |
| Verify exact sources and include closure | `success` |
| Install and record simulation and synthesis tools | `success` |
| Record the pinned synthesis cell models | `success` |
| Lint the complete CSR top | `success` |
| Prepare the verified synthesis source view | `success` |
| Synthesize the complete CSR integration twice | `success` |
| Validate the synthesized CSR structure and ROM | `success` |
| Export and verify two simulation netlists | `success` |
| Build the CSR post-synthesis testbench | `success` |
| Execute and compare two post-synthesis simulations | `success` |
| Verify repository integrity and seal qualification reports | `success` |
| Upload qualification reports and diagnostic logs | `success` |
| Publish qualification summary | `success` |

## Complete CSR integration synthesis

Each synthesis replay reads the complete CSR top through `read_slang`
with `--std 1800-2017 --ignore-assertions -j 1`, then executes:

    synth -top frp_m32_csr_top -noshare -run begin:fine
    check -assert

Both JSON netlists, both emitted Verilog netlists and both JSON
statistics records must match byte for byte.

Synthesis uses a verified temporary source copy. Four post-load ROM
simulation checks are removed from that copy of
`frp_m31_phase_interference.sv`; `$readmemh` initialization is retained.
The transformation is recorded in `synthesis-view.patch`. The transformed
source must have 10853 bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.

| Structural check | Required result |
|---|---|
| Flattened top | one module named `frp_m32_csr_top` |
| CSR interface | exact port names, directions and widths: 9 ports, 6 inputs, 3 outputs, 78 bits |
| Integrated logic guard | at least 7000 synthesized cells |
| Processes / latch cells / unresolved module instances | `0` / `0` / `0` |
| Retained memories | two read-only `$mem_v2` cells |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Synchronizer input | constant `1` into stage one; stage one into stage two |
| Readiness and remaining asynchronous reset consumers | driven by stage two |
| Primary sine ROM | 4096 x 32, 12 address bits, 72 read ports, 0 write ports |
| Primary ROM initialization | exact match to all 4096 canonical words |
| Statistics | cell count and cell-type inventory agree with the JSON netlist |

The exact synthesized cell count and inventory are written to
`synthesis-structure.json` and both `stat-run-*.json` files, then included
in the final `qualification.json`.

## Verified simulation netlist export and build

Each synthesis JSON is exported with this transformation:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_csr_top frp_m32_csr_netlist

The two exports must produce byte-identical JSON files and byte-identical
Verilog files. Original synthesis JSON files retain their initial bytes.

| Export check | Required result |
|---|---|
| Module set | one module named `frp_m32_csr_netlist` |
| Port contract | names, directions, widths and signedness preserved |
| Both memories | every parameter, including initialization, preserved |
| Core observation wires | all 59 distinct `u_fpga.*` names, widths and signedness preserved |
| Processes / latch cells / unresolved module instances | `0` / `0` / `0` |
| Remaining `$shiftx` / `$connect` cells | `0` / `0` |
| Export records | input and output SHA-256 identities retained in `simulation-export.json` |

`simlib.v` and `techmap.v` come from the pinned Yosys package. Their copies
are retained as `yosys-simlib.v` and `yosys-techmap.v`, with sizes and
SHA-256 identities in `cell-models.json`.

The build uses `simulation-netlist-1.v`, the post-synthesis testbench and
the recorded simulation cell library. `-DSIMLIB_NOCONNECT` is used after
the export check has required zero `$connect` cells.

Lint and build checks reject `PINMISSING`, `IMPLICIT` and `MULTIDRIVEN`
diagnostics. Complete output is retained in `top-lint.log` and
`post-synthesis-build.log`.

## Post-synthesis simulation record

The successful simulation step requires exactly one occurrence of this
terminal record in each replay:

    FRP_M32_CSR_POST_SYNTHESIS_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

| Field | Meaning per replay |
|---|---|
| `checks=6905` | full 59-output comparison rounds plus explicit CSR read checks |
| `ticks=306` | executed stimulus ticks across all reset epochs |
| `rejected_transfers=449` | completed transfers expected to report a CSR error |
| `core_outputs=59` | outputs compared in every core comparison round |

The testbench compares the synthesized core outputs against the separate
RTL reference after each rising clock edge. Both complete simulator logs
must match byte for byte. A failed assertion or testbench timeout
terminates simulation with `$fatal`.

### CSR transfers, reset and retained state

| Scenario | Checked behavior |
|---|---|
| Asynchronous reset assertion | CSR readiness, error and read data are zero |
| Two-stage reset release | commands cannot execute before qualified readiness |
| Startup tick withdrawn before readiness | no recorded tick or target capture |
| 192 unaligned addresses | both reads and writes rejected: 384 transfers |
| 52 read-only register addresses | writes rejected |
| Invalid commands and payloads | 13 additional rejected transfers |
| Idle, write and error responses | unused read data remains zero |
| Staged requests | accepted ticks consume staged request-valid bits; request clear issues no tick |
| Both request lanes | independently staged requests reach their selected cells |
| Duplicate-cell requests | lane 0 accepted and lane 1 rejected in the directed scenario |
| Consecutive accepted transfers | three consecutive edges produce three ticks |
| Reset after staging and auto mode | staged state and captured results cleared |

The rejected-transfer total is `384 + 52 + 13 = 449`.

The ternary kernel is `-1/0/1`, with active state `0`. Direct transitions
`-1 -> 1` and `1 -> -1` are forbidden. Both exercised routes pass through
active zero on separate enabled ticks.

| Route | Intermediate checks | Completion |
|---|---|---|
| `1 -> 0 -> -1` | active zero and pending `-1` retained through CSR scans and counter clear | later tick completes `0 -> -1` without a new request |
| `-1 -> 0 -> 1` | active zero and pending `1` retained through repeated reads | later tick completes `0 -> 1` without a new request |

Scenario checkpoints require zero `actual_direct_events`,
`reserved_state_events` and `queue_overflow_events`.

### Phase, frequency and telemetry

All eight phase and frequency pairs are staged through the selected-cell
CSR window while live values remain unchanged. The load command applies
all eight staged pairs on one edge. Patterns exercise signed frequencies
and phase wraparound; distinct gamma and thermal-factor words exercise
every configuration slice.

Automatic requests use the registered phase-target path. CSR scans check
live phase, frequency, coupling, projection, targets, executed states,
pending routes, scheduler counters, coherence, thermal and stability
outputs. Last-tick snapshots are compared against reference events sampled
before the tick edge, including request, routing and capture decisions.

### Scheduler records

Each mode scenario configures its mode during idle clocks before its
first tick and records 97 ticks and 97 accepted target captures.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 | 97 |
| `7/1` | 0 | 85 | 12 | 0 | 0 | 97 |
| `1/7` | 0 | 0 | 0 | 13 | 84 | 97 |

`7/1` executes seven BALANCE ticks followed by one COMMIT tick; `1/7`
executes one EXCITE tick followed by seven NEUTRALIZE ticks.

A separate consecutive-transfer scenario writes mode `7/1` and issues a
tick on the immediately following rising edge. That tick uses the prior
FREE scheduler state; a later tick records BALANCE. This checks the
existing one-clock mode-registration delay.

## Qualification sealing and published artifact

After simulation, the workflow rechecks all 21 canonical input identities,
the workflow identity, the checked-out commit and the clean Git working
tree. It requires successful structural and export reports and identical
complete simulation logs before writing `qualification.json` with schema
`frp.m32.csr-post-synthesis-qualification.v1`.

The qualification report binds the result to `source_commit`, `run_id`
and `run_attempt`. The sealing step records SHA-256 identities for the
other evidence files in `artifacts.sha256`.

Required qualification terminal record:

    FRP M32 CSR post-synthesis qualification: PASS

The [artifact metadata](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701/artifacts)
records the published archive identity below.

| Field | Recorded value |
|---|---|
| Artifact ID | `10300161633` |
| Artifact name | `frp-m32-csr-post-synthesis-qualification-dcade95d59457dbd7bd296f7dc2d902f4fa61ddf-1` |
| Size reported by GitHub | `9530965` bytes |
| SHA-256 digest reported by GitHub | `b67e2349c124316e96ee1e55610081b7b5c6e63c77d2f7749dc669ca03cd8fa6` |
| Created | `2026-09-12T14:41:53Z` |
| Configured retention | 30 days |
| Recorded expiry | `2026-10-12T14:41:51Z` |

The workflow writes the following evidence files to the uploaded directory.

| Files | Contents |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | 21 canonical input identities and separate workflow identity |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, packages and frontend help |
| `yosys-simlib.v`, `yosys-techmap.v`, `cell-models.json` | pinned simulation library and technology map with recorded identities |
| `top-lint.log`, `post-synthesis-build.log` | complete lint and build diagnostics |
| `synthesis-view.patch` | verified temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys`, `synthesis-run-1.log`, `synthesis-run-2.log` | synthesis commands and logs |
| `netlist-run-1.json`, `netlist-run-2.json`, `netlist-run-1.v`, `netlist-run-2.v` | original flattened synthesis netlists |
| `stat-run-1.json`, `stat-run-2.json`, `synthesis-structure.json` | statistics, cell inventory, port, reset and ROM checks |
| `simulation-netlist-1.ys`, `simulation-netlist-2.ys`, `simulation-netlist-1.log`, `simulation-netlist-2.log` | simulation export commands and logs |
| `simulation-netlist-1.json`, `simulation-netlist-2.json`, `simulation-netlist-1.v`, `simulation-netlist-2.v` | verified simulation netlists |
| `simulation-export.json` | export identities, preserved contracts and 59 observation wires |
| `post-synthesis-run-1.log`, `post-synthesis-run-2.log` | complete simulation output, compared byte for byte |
| `qualification.json` | final result, execution identity, simulation, synthesis, export, reset, ROM and repository-integrity records |
| `artifacts.sha256` | SHA-256 values for the other evidence files |

## Result

`FRP M32 CSR Post-Synthesis Qualification #1: SUCCESS`

This record extends the
[CSR integration simulation and synthesis transcript](SIMULATION_TRANSCRIPT.md)
with successful simulation of the generated complete CSR netlist against
the independent M32 RTL reference for the qualified testbench scenarios.

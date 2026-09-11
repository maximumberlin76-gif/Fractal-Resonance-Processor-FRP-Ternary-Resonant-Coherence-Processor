# FRP M32 FPGA Integration Simulation and Synthesis Transcript

## Qualification record

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Layer | FPGA integration of the complete registered-target core |
| Workflow | `FRP M32 FPGA Integration Qualification` |
| Workflow file | [frp-m32-fpga-integration-qualification.yml](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) |
| Successful run | [#2](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| Run ID | `34531635873` |
| Run attempt | `1` |
| Qualified commit | `e40e90d8e32847aa783030aba7e1e5f7963ef312` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Run started | `2026-09-10T21:20:28Z` |
| Run updated | `2026-09-10T21:23:12Z` |
| Recorded run duration | `2m 44s` |
| Status | `completed` |
| Conclusion | `success` |
| Job ID | `103053501919` |
| Job | `Simulate and synthesize the complete M32 FPGA integration` |
| Job conclusion | `success` |

Run and job records are published by GitHub for the linked qualification
run. The checks and ordered terminal records below are defined by the
[workflow at the qualified commit](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/e40e90d8e32847aa783030aba7e1e5f7963ef312/.github/workflows/frp-m32-fpga-integration-qualification.yml).

## Qualified source boundary

| Component | Source | Qualified configuration |
|---|---|---|
| FPGA top | [frp_m32_fpga_top.sv](frp_m32_fpga_top.sv) | `frp_m32_fpga_top`, `8` cells, `2` request lanes |
| Integration testbench | [frp_m32_fpga_tb.sv](frp_m32_fpga_tb.sv) | `frp_m32_fpga_tb`, `59` core outputs compared |
| Integrated core | [frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv) | complete registered-target M32 core |
| Sine ROM | [frp_m31_sin_q30.mem](../../rtl/m31/frp_m31_sin_q30.mem) | `4096` words, `32` bits per word |

The source manifest checks byte lengths and SHA-256 identities for the
complete include closure of the FPGA top and testbench:

| Source class | Files |
|---|---:|
| M31 SystemVerilog dependencies | 13 |
| M32 SystemVerilog dependencies | 3 |
| FPGA top and testbench | 2 |
| Sine ROM initialization file | 1 |
| Total canonical inputs | 19 |

The workflow records its own SHA-256 identity separately from these
nineteen inputs.

| File | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32/frp_m32_fpga_top.sv` | 11355 | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32/frp_m32_fpga_tb.sv` | 37172 | `75a0b2e261fff6a8b955c758415c60f360d58c091b598e0af5d2e61ade6a6c18` |
| `rtl/m31/frp_m31_sin_q30.mem` | 36864 | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| `.github/workflows/frp-m32-fpga-integration-qualification.yml` | 30337 | `14fba7469ecc1b76e3547d11db7f34986f15272d983e3aea19b52dbafb8e9145` |

## Execution configuration

| Setting | Value |
|---|---|
| Runner image | `ubuntu-24.04` |
| Python selection | `3.12` |
| Simulation and lint | Verilator |
| Native build tools | `g++`, `make` |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017` |
| Synthesis frontend workers | `1` |
| Locale | `C.UTF-8` |
| Time zone | `UTC` |
| Python hash seed | `0` |
| Simulation replays | `2` |
| Synthesis replays | `2` |

Resolved tool versions are written to `toolchain.log`; Python package
versions are written to `python-packages.txt`.

The first workflow step derives these paths from `RUNNER_TEMP` and exports
them through `GITHUB_ENV` for subsequent steps:

| Variable | Directory |
|---|---|
| `M32_EVIDENCE` | `$RUNNER_TEMP/frp-m32-fpga-evidence` |
| `M32_SOURCE` | `$RUNNER_TEMP/frp-m32-fpga-source` |
| `M32_BUILD` | `$RUNNER_TEMP/frp-m32-fpga-build` |

## Completed qualification steps

GitHub records `success` for each of the following workflow steps:

| Step | Result |
|---|---|
| Initialize temporary paths | `success` |
| Check out dispatched commit | `success` |
| Set up Python 3.12 | `success` |
| Require manual main execution and prepare reports | `success` |
| Verify exact sources and include closure | `success` |
| Install and record simulation and synthesis tools | `success` |
| Lint the complete FPGA top | `success` |
| Build the complete FPGA integration testbench | `success` |
| Execute and compare two complete simulation runs | `success` |
| Prepare the verified synthesis source view | `success` |
| Synthesize the complete FPGA integration twice | `success` |
| Validate ports, reset stages, ROM, and repository integrity | `success` |
| Upload qualification reports and diagnostic logs | `success` |
| Publish qualification summary | `success` |

The lint and build checks reject `PINMISSING`, `IMPLICIT`, and
`MULTIDRIVEN` diagnostics. Complete diagnostic output is retained in
`top-lint.log` and `testbench-build.log`.

## Simulation record

The testbench compares all `59` forwarded core outputs against a separate
`frp_m32_core` instance over `1019` samples per replay. It checks
`core_ready` separately against the release edge specified by each test
scenario; the reference reset is driven by that scenario expectation.

The workflow validates this ordered terminal record in each replay:

    PASS: startup pulses discarded; phase load without tick
    PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause
    PASS: reset reassertion restarts both release stages
    PASS: free, 97 ticks, pause, isolated and concurrent clear
    PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear
    PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear
    PASS: 59 outputs match standalone M32 across 1019 samples
    FRP M32 FPGA integration testbench PASS

These semantic lines are saved as `simulation-run-1.txt` and
`simulation-run-2.txt` and compared byte for byte. Complete simulator
output is retained separately in `simulation-run-1.log` and
`simulation-run-2.log`.

### Reset and control qualification

The testbench checks asynchronous reset assertion between clock edges,
two-stage synchronous release, and release restart after reset interrupts
the first stage. `core_ready` rises after the second release edge; an
enabled core operation can first be sampled on the following rising edge.

While `core_ready` is low, the FPGA wrapper blocks `tick_enable`,
`clear_counters`, `phase_load_valid`, `auto_target_enable`, and
`external_request_valid`. Startup pulses that end before readiness are
discarded. Held controls are checked at the first active core edge.

Phase and frequency loading is exercised with `tick_enable` low. The first
registered target capture is compared against the phase target sampled
before the active edge.

### Active-zero routing and retained state

The qualified ternary kernel is `-1/0/1`, with active state `0`. Both
opposite-polarity routes are exercised:

| Route | Intermediate behavior | Completion |
|---|---|---|
| `1 -> 0 -> -1` | active zero and pending `-1` retained during three paused cycles | next enabled tick, with no new request |
| `-1 -> 0 -> 1` | active zero and pending `1` retained during three paused cycles | next enabled tick, with no new request |

The testbench checks for reserved states and direct polarity changes at
each output comparison. `actual_direct_events`, `reserved_state_events`,
and `queue_overflow_events` are required to remain zero.

### Scheduler records

Each mode scenario records `97` ticks and `97` accepted target captures.
The first tick executes the reset scheduler state `FREE`; the next `96`
ticks cover twelve complete eight-tick periods for `7/1` and `1/7`.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 | 97 |
| `7/1` | 1 | 84 | 12 | 0 | 0 | 97 |
| `1/7` | 1 | 0 | 0 | 12 | 84 | 97 |

The scenarios alternate automatic and external request selection while
varying `gamma_effective_word`, `thermal_node_factor_q30`, request cell
indexes, request targets, and the external target bank.

Four paused cycles preserve retained state, pending routes, registered
targets, phase, frequency, scheduler state, and thermal sample count.
Isolated counter clear preserves retained data. With clear and tick
asserted together, the scheduler records one tick while target-capture
and thermal event counters retain clear priority.

## Complete FPGA integration synthesis

| Setting | Value |
|---|---|
| Top | `frp_m32_fpga_top` |
| Integrated core instance | `u_m32_core` |
| Profile | `CELLS=8`, `REQUEST_LANES=2` |
| Flow | `synth -top frp_m32_fpga_top -run begin:fine` |
| Structural check | `check -assert` |
| Output structure | one flattened module with retained memories |
| Replay comparison | JSON netlist, Verilog netlist, and JSON statistics, byte for byte |

Synthesis uses a temporary copy of the verified canonical inputs. In that
copy, four post-`$readmemh` ROM simulation checks are removed from
`frp_m31_phase_interference.sv`; `$readmemh` initialization is retained.
The exact transformation is recorded in `synthesis-view.patch`.

The transformed phase source is checked against `10853` bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.
Canonical repository sources retain their original byte identities.

The successful validation step enforces these structural results:

| Check | Required result |
|---|---|
| Flattened top modules | `1`, named `frp_m32_fpga_top` |
| Interface | `75` ports: `15` inputs and `60` outputs |
| Total port bits | `3136` |
| Port names, directions, and widths | exact match to the complete FPGA interface contract |
| Remaining processes | `0` |
| Latch cells | `0` |
| Unresolved module instances | `0` |
| Memory cells | `2` cells of type `$mem_v2` |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Synchronizer input | constant `1` into the first stage; first stage into the second |
| Core readiness and asynchronous reset consumers | driven by the second synchronizer stage |
| Sine ROM | `4096 x 32`, `12` address bits, `72` read ports, `0` write ports |
| Sine ROM initialization | exact match to all `4096` canonical words |
| Statistics | cell count and cell-type inventory agree with the JSON netlist |
| Repeated synthesis | identical JSON netlists, Verilog netlists, and statistics |

The resulting cell count and complete cell-type inventory are recorded in
`qualification.json`, `stat-run-1.json`, and `stat-run-2.json`.

Before writing the qualification result, the workflow rechecks all
canonical source identities, the workflow identity, the checked-out
commit, and the clean Git working tree.

Stable qualification terminal record:

    FRP M32 FPGA integration qualification: PASS

## Published qualification artifact

The [artifact metadata for this run](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873/artifacts)
records the following archive:

| Field | Recorded value |
|---|---|
| Artifact ID | `10173809390` |
| Artifact name | `frp-m32-fpga-qualification-e40e90d8e32847aa783030aba7e1e5f7963ef312-1` |
| Size reported by GitHub | `4482172` bytes |
| SHA-256 digest reported by GitHub | `fc74edd654a80c77d9779b4b49ff5f47f5e153a5d6367f6c5d5db492092024c2` |
| Configured retention | `30` days |
| Qualification schema | `frp.m32.fpga-integration-qualification.v1` |

The workflow writes the following evidence files to the uploaded directory:

| Files | Contents |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | nineteen canonical input identities and the workflow identity record |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, Python packages, and synthesis frontend help |
| `top-lint.log`, `testbench-build.log` | FPGA top lint and testbench build output |
| `simulation-run-1.log`, `simulation-run-2.log` | complete simulator output for both executions |
| `simulation-run-1.txt`, `simulation-run-2.txt` | exactly compared semantic terminal records |
| `synthesis-view.patch` | verified temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys` | executed synthesis commands |
| `synthesis-run-1.log`, `synthesis-run-2.log` | complete synthesis logs |
| `netlist-run-1.json`, `netlist-run-2.json` | flattened JSON netlists |
| `netlist-run-1.v`, `netlist-run-2.v` | emitted Verilog netlists |
| `stat-run-1.json`, `stat-run-2.json` | synthesis statistics and cell-type inventories |
| `qualification.json` | qualification result, source commit, run identity, simulation, synthesis, reset, ROM, and repository-integrity results |
| `artifacts.sha256` | SHA-256 values for the other evidence files |

## Result

`FRP M32 FPGA Integration Qualification #2: SUCCESS`

`FRP M32 FPGA integration qualification: PASS`

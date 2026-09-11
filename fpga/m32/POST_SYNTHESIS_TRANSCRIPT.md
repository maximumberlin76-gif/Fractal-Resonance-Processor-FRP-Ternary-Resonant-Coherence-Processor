# FRP M32 FPGA Post-Synthesis Qualification Transcript

## Qualification record

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Layer | Post-synthesis simulation of the complete FPGA integration netlist |
| Workflow | `FRP M32 FPGA Post-Synthesis Qualification` |
| Workflow file | [frp-m32-fpga-post-synthesis-qualification.yml](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| Successful workflow run | `#1` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Recorded run duration | `13m 36s` |
| Conclusion | `success` |
| Repository source baseline | `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1` |
| Job name defined by the workflow | `Synthesize and simulate the complete M32 FPGA netlist` |

The successful manual run is recorded in the
[workflow run list](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml).
The source identities, commands, acceptance checks, terminal records, and
evidence layout below are defined by the
[workflow at the source baseline](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/16a40d0687df20ea62dacdfb72e39ef6c22ec9c1/.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml).

The generated `qualification.json` binds the execution to its exact
`source_commit`, `run_id`, and `run_attempt`.

## Source and comparison boundary

| Component | Source or generated module | Configuration |
|---|---|---|
| FPGA synthesis top | [frp_m32_fpga_top.sv](frp_m32_fpga_top.sv) | `frp_m32_fpga_top`, `8` cells, `2` request lanes |
| Post-synthesis testbench | [frp_m32_fpga_post_synthesis_tb.sv](frp_m32_fpga_post_synthesis_tb.sv) | `frp_m32_fpga_post_synthesis_tb` |
| Synthesized DUT | `frp_m32_fpga_netlist` | generated from the complete flattened FPGA synthesis JSON |
| RTL reference | [frp_m32_core.sv](../../rtl/m32/frp_m32_core.sv) | a separate complete M32 core instance |
| Canonical sine ROM | [frp_m31_sin_q30.mem](../../rtl/m31/frp_m31_sin_q30.mem) | `4096` words of `32` bits |
| Compared core interface | all `59` forwarded core outputs | `1019` samples per replay |
| Independent readiness check | `core_ready` | checked against scenario-defined reset release |

The distinct DUT module name requires the generated simulation netlist as
a build input. The RTL reference reads the canonical sine ROM file; the
synthesized DUT uses the ROM initialization embedded in its netlist.

The workflow verifies byte lengths and SHA-256 identities for the complete
include closure of the FPGA top and post-synthesis testbench:

| Source class | Files |
|---|---:|
| M31 SystemVerilog dependencies | 13 |
| M32 SystemVerilog dependencies | 3 |
| FPGA top and post-synthesis testbench | 2 |
| Canonical sine ROM | 1 |
| Total canonical inputs | 19 |

The workflow records its own SHA-256 identity separately from these
nineteen inputs.

| File | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32/frp_m32_fpga_top.sv` | 11355 | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32/frp_m32_fpga_post_synthesis_tb.sv` | 38441 | `f619094e59932cc48d54a27a6650d8913ede84e754069f1b911ef3e692d953d8` |
| `rtl/m32/frp_m32_core.sv` | 10564 | `925342326b7ad555a1382e8ee3bc5754ed3012ba60e0eabf512113731e0ee6c9` |
| `rtl/m31/frp_m31_sin_q30.mem` | 36864 | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| `.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml` | 40054 | `d240b6be6f2e1d30b5bd69b3a92b0b801d9895a1b37efcda39488c9d7b77bed5` |

## Execution configuration

| Setting | Value defined by the workflow |
|---|---|
| Runner image | `ubuntu-24.04` |
| Python selection | `3.12` |
| Simulation and lint | Verilator |
| Native build tools | `g++`, `make` |
| C++ compilation standard | `-std=c++20` |
| Simulation options | `--sv --timing --assert --binary` |
| Simulation build workers | `2` |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017`, one worker |
| Locale and time zone | `C.UTF-8`, `UTC` |
| Python hash seed | `0` |
| Synthesis replays | `2` |
| Simulation exports | `2` |
| Post-synthesis simulation replays | `2` |
| Each synthesis or export timeout | `300` seconds |
| Each simulation replay timeout | `120` seconds |
| Job timeout | `30` minutes |
| Repository permission | `contents: read` |

Resolved tool versions are written to `toolchain.log`; installed Python
package versions are written to `python-packages.txt`.

The first step exports temporary paths through `GITHUB_ENV`:

| Variable | Directory |
|---|---|
| `M32_EVIDENCE` | `$RUNNER_TEMP/frp-m32-post-synthesis-evidence` |
| `M32_SOURCE` | `$RUNNER_TEMP/frp-m32-post-synthesis-source` |
| `M32_BUILD` | `$RUNNER_TEMP/frp-m32-post-synthesis-build` |

The checkout uses the dispatched commit with persisted credentials
disabled. The workflow requires a manual `main` execution, the expected
checked-out commit, and a clean working tree before qualification.

## Complete FPGA integration synthesis

Each synthesis replay reads the complete FPGA top with `CELLS=8` and
`REQUEST_LANES=2`, then executes:

    synth -top frp_m32_fpga_top -run begin:fine
    check -assert

The workflow compares both JSON netlists, both emitted Verilog netlists,
and both JSON statistics records byte for byte.

Synthesis uses a temporary copy of the verified canonical inputs. In that
copy, four post-`$readmemh` ROM simulation checks are removed from
`frp_m31_phase_interference.sv`; ROM initialization remains present.
The exact transformation is retained in `synthesis-view.patch`.

The transformed phase source must have `10853` bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.

| Structural check | Required result |
|---|---|
| Flattened top | one module named `frp_m32_fpga_top` |
| Complete interface | `75` ports: `15` inputs and `60` outputs |
| Total port bits | `3136` |
| Port contract | exact names, directions, and widths |
| Integrated logic size check | at least `7000` synthesized cells |
| Remaining processes | `0` |
| Latch cells | `0` |
| Unresolved module instances | `0` |
| Retained memory cells | `2` cells of type `$mem_v2` |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Synchronizer input | constant `1` into stage one; stage one into stage two |
| Core readiness and core reset consumers | driven by stage two |
| Sine ROM dimensions | `4096 x 32`, `12` address bits |
| Sine ROM ports | `72` read ports, `0` write ports |
| Sine ROM initialization | exact match to all `4096` canonical words |
| Statistics | cell count and cell-type inventory agree with the JSON netlist |

The exact cell count and inventory are stored in `structure.json`,
`stat-run-1.json`, and `stat-run-2.json` and included in the final
qualification report.

## Simulation netlist export

Each verified synthesis JSON is read into Yosys. Before emission, the
workflow applies this sequence:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_fpga_top frp_m32_fpga_netlist

The standard Yosys `$shiftx` map produces explicit selection logic for
signed indices. The original synthesis JSON files remain byte-identical
to their pre-export contents.

The two exports produce `simulation-netlist-1.json`,
`simulation-netlist-2.json`, `simulation-netlist-1.v`, and
`simulation-netlist-2.v`. JSON outputs must match each other byte for byte;
Verilog outputs must also match each other byte for byte.

| Export check | Required result |
|---|---|
| Module set | one module named `frp_m32_fpga_netlist` |
| Port names, directions, widths, and signedness | preserved from synthesis |
| All `$mem_v2` parameters and initialization | preserved from synthesis |
| Remaining processes and latch cells | `0` |
| Remaining `$shiftx` and `$connect` cells | `0` |
| Reset-qualified observation wires | all five names and widths preserved |
| Original synthesis JSON | unchanged |
| Repeated export | identical JSON and Verilog |

The five observed wires are `u_m32_core.tick_enable`,
`u_m32_core.clear_counters`, `u_m32_core.phase_load_valid`,
`u_m32_core.auto_target_enable`, and
`u_m32_core.external_request_valid`. They are observed by the testbench;
the reference reset follows independent scenario expectations.

The simulator uses `simlib.v` from the same pinned Yosys package. Copies of
`simlib.v` and `techmap.v` are retained as `yosys-simlib.v` and
`yosys-techmap.v`; their sizes and hashes are recorded in `cell-models.json`.
The build uses `-DSIMLIB_NOCONNECT`, after the export check has required
that the design contain no `$connect` cell.

The lint and build checks reject `PINMISSING`, `IMPLICIT`, and
`MULTIDRIVEN` diagnostics. Complete output is retained in `top-lint.log`
and `post-synthesis-build.log`.

## Post-synthesis simulation record

The compiled testbench is executed twice. Each replay compares all `59`
forwarded core outputs against the separate RTL reference over `1019`
samples and checks `core_ready` independently.

The workflow requires the following ordered terminal records in each
replay:

    PASS: startup pulses discarded; phase load without tick
    PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause
    PASS: reset reassertion restarts both release stages
    PASS: free, 97 ticks, pause, isolated and concurrent clear
    PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear
    PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear
    PASS: 59 synthesized outputs match standalone M32 across 1019 samples
    FRP M32 FPGA post-synthesis testbench PASS

These records are written to `post-synthesis-run-1.txt` and
`post-synthesis-run-2.txt` and compared byte for byte. Complete simulator
output is retained separately in `post-synthesis-run-1.log` and
`post-synthesis-run-2.log`.

### Reset, readiness, and registered-target checks

The testbench exercises asynchronous reset assertion between clock edges,
two-stage synchronous release, and release restart when reset interrupts
the first stage. `core_ready` rises after the second release edge; an
enabled core operation can first be sampled on the following rising edge.

Before readiness, tick, counter clear, phase load, automatic request
selection, and external request validity are blocked. Startup pulses that
end before readiness are discarded. Held controls are checked at the
first active core edge.

Phase and frequency loading is exercised with `tick_enable` low. The first
registered target capture is checked against the phase target sampled
before the active edge.

### Active-zero and polarity-route checks

The retained ternary kernel is `-1/0/1`. State `0` is active and retained.

| Required route | Intermediate state | Completion |
|---|---|---|
| `1 -> 0 -> -1` | active zero and pending `-1` retained for three paused cycles | next enabled tick without a new request |
| `-1 -> 0 -> 1` | active zero and pending `1` retained for three paused cycles | next enabled tick without a new request |

The testbench rejects reserved states and direct polarity changes at
each comparison. `actual_direct_events`, `reserved_state_events`, and
`queue_overflow_events` must remain zero.

### Scheduler, pause, and counter-clear checks

Each mode scenario records `97` ticks and `97` accepted target captures.
The first tick executes the reset scheduler state `FREE`; the next `96`
ticks cover twelve complete eight-tick periods for `7/1` and `1/7`.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 | 97 |
| `7/1` | 1 | 84 | 12 | 0 | 0 | 97 |
| `1/7` | 1 | 0 | 0 | 12 | 84 | 97 |

Mode `7/1` executes seven balance ticks followed by one commit tick. Mode
`1/7` executes one excite tick followed by seven neutralize ticks.

The scenarios alternate automatic and external requests while varying
gamma, thermal factors, request indexes, request targets, and the external
target bank. Four paused cycles preserve retained state, pending routes,
registered targets, phase, frequency, scheduler state, and thermal sample
count.

Isolated counter clear preserves retained data. Concurrent clear and tick
leave one scheduler tick recorded while target-capture and thermal event
counters retain clear priority.

## Evidence and integrity binding

After the simulation checks, the workflow rechecks all nineteen canonical
source identities, its own identity, the checked-out commit, and the clean
working tree. It also rechecks the recorded Yosys support-file identities.

The final report is written only after the structural, export, simulation,
and integrity steps succeed and all `35` required evidence files exist
with nonzero length. `qualification.json` records their sizes and SHA-256
values. `artifacts.sha256` then covers the other `36` files, including
`qualification.json`.

| Files | Contents |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | canonical input identities, workflow identity, repository, and source commit |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, installed packages, and frontend help |
| `cell-models.json`, `yosys-simlib.v`, `yosys-techmap.v` | Yosys support files and their recorded identities |
| `top-lint.log`, `post-synthesis-build.log` | complete top lint and simulation build output |
| `synthesis-view.patch` | exact temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys` | synthesis commands |
| `synthesis-run-1.log`, `synthesis-run-2.log` | synthesis logs |
| `netlist-run-1.json`, `netlist-run-2.json` | original flattened synthesis JSON |
| `netlist-run-1.v`, `netlist-run-2.v` | synthesis Verilog exports |
| `stat-run-1.json`, `stat-run-2.json`, `structure.json` | synthesis statistics, cell inventory, reset, interface, and ROM checks |
| `simulation-netlist-1.ys`, `simulation-netlist-2.ys` | simulation export commands |
| `simulation-netlist-1.log`, `simulation-netlist-2.log` | simulation export logs |
| `simulation-netlist-1.json`, `simulation-netlist-2.json` | mapped simulation JSON |
| `simulation-netlist-1.v`, `simulation-netlist-2.v` | generated simulation DUT Verilog |
| `simulation-export.json` | export comparisons, preserved contracts, input and output hashes, and mapped `$shiftx` counts |
| `post-synthesis-run-1.log`, `post-synthesis-run-2.log` | complete simulator output |
| `post-synthesis-run-1.txt`, `post-synthesis-run-2.txt` | ordered semantic terminal records |
| `qualification.json` | final result and execution, source, synthesis, export, simulation, model, and integrity records |
| `artifacts.sha256` | hashes of the other evidence files |

| Publication setting | Workflow value |
|---|---|
| Qualification schema | `frp.m32.fpga-post-synthesis-qualification.v1` |
| Artifact name expression | `frp-m32-fpga-post-synthesis-${{ github.sha }}-${{ github.run_attempt }}` |
| Artifact directory | `$RUNNER_TEMP/frp-m32-post-synthesis-evidence/` |
| Configured retention | `30` days |
| Upload and summary conditions | `always()` |

The summary reports the job status and the generated qualification result.
Diagnostic upload and summary steps also execute when an earlier step fails.

## Related qualification records

The preceding FPGA integration simulation and synthesis run is documented
in [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md). Its integration
boundary is recorded in [CLOSURE.md](CLOSURE.md).

The inherited registered-target RTL boundary is documented in
[rtl/m32/CLOSURE.md](../../rtl/m32/CLOSURE.md).

## Result

`FRP M32 FPGA Post-Synthesis Qualification #1: SUCCESS`

Workflow qualification terminal record:

    FRP M32 FPGA post-synthesis qualification: PASS

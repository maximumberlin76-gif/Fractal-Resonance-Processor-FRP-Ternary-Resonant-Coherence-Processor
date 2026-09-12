# FRP M32 CSR Integration and Post-Synthesis Boundary Closure

## Boundary identity

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Closed directory | `fpga/m32_csr/` |
| CSR top | `frp_m32_csr_top` |
| Integration testbench | `frp_m32_csr_tb` |
| Post-synthesis testbench | `frp_m32_csr_post_synthesis_tb` |
| Generated simulation DUT | `frp_m32_csr_netlist` |
| Wrapped FPGA top | `frp_m32_fpga_top` |
| Integrated core | `frp_m32_core` |
| Qualified profile | 8 cells, 2 request lanes, 32-bit words and counters |
| Host clock contract | CSR inputs synchronous to `clk` |
| Ternary kernel | `-1/0/1`, with active state `0` |
| Scheduler modes | `free`, `7/1`, `1/7` |
| Integration qualification commit | `8e619504c7826ba6351d4967d5944685963363f0` |
| Integration transcript commit | `6567d6cfd45705931b89a88a782b0f0fb1112ffd` |
| Post-synthesis qualification commit | `dcade95d59457dbd7bd296f7dc2d902f4fa61ddf` |
| Post-synthesis transcript commit | `4074fbfdac3621883b2b1a0ecad171510214def0` |
| Integration closure status | `M32 CSR INTEGRATION BOUNDARY CLOSED` |
| Post-synthesis closure status | `M32 CSR POST-SYNTHESIS BOUNDARY CLOSED` |

This closure covers the implemented CSR wrapper, host transaction
handling, reset qualification, command delivery, configuration staging,
telemetry readback, deterministic RTL integration simulation, complete
hierarchy structural synthesis through `Yosys synth -noshare -run begin:fine`,
verified simulation netlist export and deterministic comparison of the
synthesized CSR netlist against a separate M32 RTL core.

The inherited FPGA integration and core boundaries are recorded in
[fpga/m32/CLOSURE.md](../m32/CLOSURE.md) and
[rtl/m32/CLOSURE.md](../../rtl/m32/CLOSURE.md). The CSR wrapper controls the
existing M32 execution path through `u_fpga.u_m32_core`.

## Qualification authority

### CSR integration qualification

| Record | Value |
|---|---|
| Workflow | [FRP M32 CSR Integration Qualification](../../.github/workflows/frp-m32-csr-integration-qualification.yml) |
| Successful run | [#1](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270) |
| Run ID and attempt | `34689613270`, attempt `1` |
| Job ID | `103542454966` |
| Job | `Simulate and synthesize the complete M32 CSR integration` |
| Trigger and branch | `workflow_dispatch`, `main` |
| Run started | `2026-09-12T10:53:11Z` |
| Run updated | `2026-09-12T10:55:47Z` |
| Recorded duration | `2m 36s` |
| Status and conclusion | `completed`, `success` |
| Qualification result | `FRP M32 CSR integration qualification: PASS` |

The [qualified workflow source](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/8e619504c7826ba6351d4967d5944685963363f0/.github/workflows/frp-m32-csr-integration-qualification.yml)
defines the source identities, execution commands, simulation markers,
synthesis comparisons and structural checks. GitHub records success for
all 14 workflow steps in the
[qualification job record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270/jobs).

The qualification record is preserved in
[SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md), committed at
`6567d6cfd45705931b89a88a782b0f0fb1112ffd`. Repository checks for that
documentation commit completed successfully:

| Repository check | Result |
|---|---|
| [FRP Self Test #744](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34691386746) | `SUCCESS` |
| [FRP Structured Output #700](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34691386743) | `SUCCESS` |
| [FRP Benchmark Smoke Test #740](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34691386704) | `SUCCESS` |

### CSR post-synthesis qualification

| Record | Value |
|---|---|
| Workflow | [FRP M32 CSR Post-Synthesis Qualification](../../.github/workflows/frp-m32-csr-post-synthesis-qualification.yml) |
| Successful run | [#1](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701) |
| Run ID and attempt | `34699370701`, attempt `1` |
| Job ID | `103568293849` |
| Job | `Qualify the synthesized M32 CSR integration` |
| Trigger and branch | `workflow_dispatch`, `main` |
| Run started | `2026-09-12T14:28:08Z` |
| Run updated | `2026-09-12T14:41:55Z` |
| Recorded duration | `13m 47s` |
| Status and conclusion | `completed`, `success` |
| Qualification result | `FRP M32 CSR post-synthesis qualification: PASS` |

The [qualified post-synthesis workflow](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/dcade95d59457dbd7bd296f7dc2d902f4fa61ddf/.github/workflows/frp-m32-csr-post-synthesis-qualification.yml)
defines the source identities, synthesis and export checks, generated DUT,
simulation marker and final evidence binding. GitHub records success for
all 17 workflow-defined steps in the
[post-synthesis job record](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701/jobs).

The qualification record is preserved in
[POST_SYNTHESIS_TRANSCRIPT.md](POST_SYNTHESIS_TRANSCRIPT.md), committed at
`4074fbfdac3621883b2b1a0ecad171510214def0`. Repository checks for that
documentation commit completed successfully:

| Repository check | Result |
|---|---|
| [FRP Self Test #748](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34702922192) | `SUCCESS` |
| [FRP Structured Output #704](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34702922190) | `SUCCESS` |
| [FRP Benchmark Smoke Test #744](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34702922199) | `SUCCESS` |

## Closed artifacts and source identities

| Artifact | Function |
|---|---|
| [frp_m32_csr_top.sv](frp_m32_csr_top.sv) | CSR transactions, command generation, staged configuration and telemetry access |
| [frp_m32_csr_tb.sv](frp_m32_csr_tb.sv) | deterministic host scenarios, independent reference inputs and complete core-output comparison |
| [frp_m32_csr_post_synthesis_tb.sv](frp_m32_csr_post_synthesis_tb.sv) | generated CSR netlist comparison against an independent M32 RTL core |
| [Integration qualification workflow](../../.github/workflows/frp-m32-csr-integration-qualification.yml) | manual simulation, structural synthesis, replay comparison and evidence publication |
| [Post-synthesis qualification workflow](../../.github/workflows/frp-m32-csr-post-synthesis-qualification.yml) | manual synthesis, verified export, netlist simulation and final evidence binding |
| [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md) | successful run, source identities, checked scenarios and artifact metadata |
| [POST_SYNTHESIS_TRANSCRIPT.md](POST_SYNTHESIS_TRANSCRIPT.md) | successful post-synthesis run, export checks, simulation contract and artifact metadata |
| [CLOSURE.md](CLOSURE.md) | integration and post-synthesis scopes, accepted contracts and closure results |

Each qualified manifest checks 21 canonical inputs: one M22 CSR package,
13 M31 SystemVerilog dependencies, three M32 SystemVerilog dependencies,
the FPGA top, the CSR top and selected testbench, and the sine ROM
initialization file. The manifests share the same 20 non-testbench inputs
with identical byte lengths and SHA-256 identities. Integration selects
`frp_m32_csr_tb.sv`; post-synthesis selects
`frp_m32_csr_post_synthesis_tb.sv`. Each workflow checks its complete
include closure and records its own identity separately.

Exact byte lengths and SHA-256 identities are recorded in
`source-manifest.json` and `canonical-sources.sha256`. The committed
[integration source-boundary record](SIMULATION_TRANSCRIPT.md#qualified-source-boundary)
and [post-synthesis source-boundary record](POST_SYNTHESIS_TRANSCRIPT.md#qualified-source-and-comparison-boundary)
preserve the qualified CSR, selected testbench, ROM and workflow identities.

## CSR control and observation contract

| Contract | Qualified behavior |
|---|---|
| External interface | 9 ports, 78 bits: 6 inputs and 3 outputs |
| Transfer edge | each rising edge with `csr_valid && csr_ready` completes one transfer |
| Access width and alignment | full 32-bit words at aligned 8-bit byte addresses |
| Consecutive transfers | holding valid across ready edges performs successive transfers |
| Reset | asynchronous assertion and two-stage synchronous release through the FPGA wrapper |
| Startup commands | commands withdrawn before qualified readiness are discarded |
| Rejected transfers | error response without register changes or an execution tick |
| Read-data defaults | zero during idle, writes, errors and reset release |
| CONTROL at `0x00` | one exact command word: `1` tick, `2` clear counters/results, `4` clear staged requests, `8` load phase/frequency bank |
| Mode at `0x04` | `0` free, `1` for `7/1`, `2` for `1/7` |
| Mode registration | the core registers a CSR mode write on the next rising edge; an immediately following tick uses the prior scheduler state |
| Request selection | lanes `0..1`, cells `0..7`, ternary targets `-1/0/1` |
| Request consumption | every tick clears both staged request-valid bits, including automatic-mode ticks |
| Request clear | clears staged validity without issuing a tick |
| Phase/frequency load | atomically loads all eight staged pairs without issuing a tick |
| Gamma and thermal-factor writes | update the selected cell's live configuration words |
| Signed Q-format fields | preserve the core's raw two's-complement representation |
| Counter clear | clears counters and saved results while retaining phase, registered targets, state and pending routes |
| Live telemetry | phase, frequency, targets, state, scheduler counters, coherence, thermal and stability values |
| Event telemetry | saved results from the last executed tick, retained until tick, clear or reset |
| Interface identity | `0x46523201` at `0xFC` |

The complete address map and per-register behavior are defined in
[frp_m32_csr_top.sv](frp_m32_csr_top.sv). Before ticking in a newly written
mode, the host allows one idle clock or reads `MODE_ACTIVE` at `0x20`.

## Simulation and ternary execution closure

Both testbenches compare all 59 core outputs against separate
`frp_m32_core` reference instances. The integration testbench observes
`dut.u_fpga`; the post-synthesis testbench observes the retained flattened
`u_fpga.*` wires of `frp_m32_csr_netlist`. Reference inputs and reset come
from the test stimulus; expected CSR responses are independent of DUT
ready/error decisions.

| Qualification measure | Accepted result per replay |
|---|---|
| Core-output comparisons and explicit CSR read checks | 6905 aggregate checks |
| Stimulus ticks across reset epochs | 306 |
| Rejected CSR transfers | 449 |
| Unaligned accesses | all 192 unaligned addresses, tested for reads and writes |
| Read-only write rejection | 52 addresses |
| Other invalid command/payload cases | 13 transfers |
| Configuration coverage | all eight phase/frequency pairs and all eight gamma/thermal-factor slices |
| Request coverage | both lanes, one-shot consumption, request clear and duplicate-cell arbitration |
| Consecutive transfer scenario | three accepted edges produce three ticks |
| Simulation replay | two complete simulator logs match byte for byte |

The testbench requires the retained ternary domain `-1/0/1`. State `0` is
active and can retain an intermediate route while execution is paused.

| State | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| Reserved | `2'b10` |

Both opposite-polarity routes are exercised on separate enabled ticks:

| Route | Verified intermediate behavior | Verified completion |
|---|---|---|
| `1 -> 0 -> -1` | active zero and pending `-1` retained through CSR scans and counter clear | later tick completes the route without a new request |
| `-1 -> 0 -> 1` | active zero and pending `1` retained through repeated reads | later tick completes the route without a new request |

Direct transitions `1 -> -1` and `-1 -> 1` are forbidden. Scenario
checkpoints require zero `actual_direct_events`, `reserved_state_events`
and `queue_overflow_events`.

Both scheduler cadences are exercised: seven BALANCE ticks followed by
one COMMIT tick for `7/1`; one EXCITE tick followed by seven NEUTRALIZE
ticks for `1/7`. Each mode scenario configures the mode before its first
tick and records 97 ticks and 97 accepted target captures.

| Mode | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | 97 | 0 | 0 | 0 | 0 | 97 |
| `7/1` | 0 | 85 | 12 | 0 | 0 | 97 |
| `1/7` | 0 | 0 | 0 | 13 | 84 | 97 |

A separate immediate mode-write/tick scenario checks the prior FREE
state on the first tick and BALANCE on a later tick. Every failed
comparison and the testbench timeout terminate with `$fatal`.

Required RTL integration simulation terminal record:

    FRP_M32_CSR_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

## Structural synthesis closure

Both workflows synthesize the complete CSR hierarchy using
`yowasp-yosys==0.68.0.0.post1208`, the `read_slang` frontend and IEEE
`1800-2017`. The fixed profile includes the complete M32 core at
`u_fpga.u_m32_core`.

The temporary synthesis source view retains `$readmemh` and removes four
ROM startup simulation checks from its copy of the phase source. The
workflow verifies the transformed source against 10853 bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.
The exact transformation is retained in `synthesis-view.patch`.

| Synthesis check | Accepted result |
|---|---|
| Flow | `synth -top frp_m32_csr_top -noshare -run begin:fine` |
| Structural validation | `check -assert` |
| Flattened top | one module named `frp_m32_csr_top` |
| Interface | exact CSR port names, directions and widths: 9 ports, 78 bits |
| Integrated logic guard | at least 7000 Yosys cells |
| Remaining processes, latch cells and unresolved module instances | 0 |
| Memory cells | two read-only `$mem_v2` cells |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Reset-stage connections | constant `1` into stage one; stage one into stage two |
| Readiness and remaining asynchronous reset consumers | driven by the second synchronizer stage |
| Sine ROM | 4096 x 32, 12 address bits, 72 read ports, 0 write ports |
| ROM initialization | exact match to all 4096 canonical words |
| Statistics | cell count and cell-type inventory match the JSON netlist |
| Synthesis replay | two byte-identical JSON netlists, Verilog netlists and statistics records |

The resulting cell count and inventory are retained in
`qualification.json`, `stat-run-1.json` and `stat-run-2.json`. Before
writing the final result, each workflow rechecks all canonical source
identities, its own identity, the checked-out commit and the clean Git
working tree.

The post-synthesis workflow first writes the structural result to
`synthesis-structure.json`. Its final qualification report is written
after the verified export, both simulation replays and repository-integrity
checks succeed.

## Post-synthesis closure

Each synthesized JSON netlist is exported through the same pinned Yosys
package with this transformation:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_csr_top frp_m32_csr_netlist

The original synthesis JSON files retain their byte identities. Both
simulation JSON exports must match byte for byte; both simulation Verilog
exports must also match byte for byte.

| Post-synthesis check | Accepted result |
|---|---|
| Generated DUT | `frp_m32_csr_netlist` |
| Simulation top | `frp_m32_csr_post_synthesis_tb` |
| Reference | separate `frp_m32_core` RTL instance |
| Exported module set | one flattened simulation module |
| Port contract | all 9 port names, directions, widths and signedness preserved |
| Memory contract | all parameters of both `$mem_v2` cells, including initialization, preserved |
| Core observation contract | all 59 distinct `u_fpga.*` names, widths and signedness preserved |
| Remaining processes, latch cells and unresolved module instances | 0 |
| Remaining `$shiftx` and `$connect` cells | 0 |
| Cell models and technology map | `simlib.v` and `techmap.v` from `yowasp-yosys==0.68.0.0.post1208` |
| Compared core outputs | all 59, against the independent RTL reference |
| Checks, ticks and rejected CSR transfers | 6905, 306 and 449 per replay |
| Scheduler scenarios | `free`, `7/1`, `1/7` |
| Active-zero routes | `1 -> 0 -> -1` and `-1 -> 0 -> 1`, with pending targets retained between enabled ticks |
| Simulation replay | two complete simulator logs match byte for byte |

The post-synthesis testbench uses the generated DUT Verilog and recorded
Yosys simulation library. Its core-output observation wires are read-only;
reference controls and expected CSR responses are supplied independently
by the host stimulus.

The reference reads the canonical sine ROM file. The synthesized DUT uses
the initialization embedded in its exported netlist. Structural validation
checks every canonical ROM word; export validation preserves all memory
parameters, including initialization.

The build uses Verilator with `--sv --timing --assert --binary`,
`-std=c++20 -O0`, two workers and `--output-split 20000`.
`-DSIMLIB_NOCONNECT` follows the export check requiring zero `$connect`
cells. Both workflows reject `PINMISSING`, `IMPLICIT` and `MULTIDRIVEN`
diagnostics in their top lint and testbench build logs.

The post-synthesis workflow requires exactly one occurrence of this
terminal record in each replay, then compares both complete logs:

    FRP_M32_CSR_POST_SYNTHESIS_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

The records are retained in `post-synthesis-run-1.log` and
`post-synthesis-run-2.log`. The final qualification step requires both
successful structural and export reports and identical complete
simulation logs before producing its result.

## Evidence closure

### Integration evidence

| Evidence field | Recorded value or artifact |
|---|---|
| Qualification schema | `frp.m32.csr-integration-qualification.v1` |
| Published artifact ID | `10297126685` |
| Published artifact name | `frp-m32-csr-qualification-8e619504c7826ba6351d4967d5944685963363f0-1` |
| Source and run association | commit `8e619504c7826ba6351d4967d5944685963363f0`, run `34689613270`, attempt `1` |
| Source records | `source-manifest.json`, `canonical-sources.sha256` |
| Tool records | `toolchain.log`, `python-packages.txt`, `read-slang-help.log` |
| Lint and build records | `top-lint.log`, `testbench-build.log` |
| Simulation records | both complete simulator logs |
| Synthesis records | temporary source patch, both scripts, both logs, both JSON netlists, both Verilog netlists and both statistics files |
| Final report | `qualification.json` |
| Evidence checksums | `artifacts.sha256` |
| Configured artifact retention | 30 days |
| Qualification result | `PASS` |

The [published-artifact record](SIMULATION_TRANSCRIPT.md#published-qualification-artifact)
preserves the archive ID, size, SHA-256 digest and complete evidence-file
inventory. The final report binds the checked sources and results to
`source_commit`, `run_id` and `run_attempt`.

### Post-synthesis evidence

| Evidence field | Recorded value or artifact |
|---|---|
| Qualification schema | `frp.m32.csr-post-synthesis-qualification.v1` |
| Published artifact ID | `10300161633` |
| Published artifact name | `frp-m32-csr-post-synthesis-qualification-dcade95d59457dbd7bd296f7dc2d902f4fa61ddf-1` |
| Source and run association | commit `dcade95d59457dbd7bd296f7dc2d902f4fa61ddf`, run `34699370701`, attempt `1` |
| Source records | `source-manifest.json`, `canonical-sources.sha256` |
| Tool records | `toolchain.log`, `python-packages.txt`, `read-slang-help.log` |
| Yosys support files | `yosys-simlib.v`, `yosys-techmap.v`, `cell-models.json` |
| Lint and build records | `top-lint.log`, `post-synthesis-build.log` |
| Synthesis records | temporary source patch, both scripts, logs, JSON netlists, Verilog netlists and statistics |
| Structural result | `synthesis-structure.json` |
| Export records | both simulation export scripts, logs, JSON netlists and Verilog netlists |
| Export identities and contracts | `simulation-export.json` |
| Simulation records | `post-synthesis-run-1.log`, `post-synthesis-run-2.log` |
| Final report | `qualification.json` |
| Evidence checksums | `artifacts.sha256` |
| Configured artifact retention | 30 days |
| Qualification result | `PASS` |

The [post-synthesis artifact record](POST_SYNTHESIS_TRANSCRIPT.md#qualification-sealing-and-published-artifact)
preserves the archive ID, size, SHA-256 digest, retention dates and complete
workflow-defined evidence inventory. The
[committed post-synthesis transcript](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/4074fbfdac3621883b2b1a0ecad171510214def0/fpga/m32_csr/POST_SYNTHESIS_TRANSCRIPT.md)
preserves the execution identity and acceptance contract for this closure.

The final report binds `source_commit`, `run_id` and `run_attempt` to the
simulation, synthesis, export, reset, ROM, cell-model and repository-integrity
records. `artifacts.sha256` covers the other evidence files, including the
final qualification report.

## Closure result

`M32 CSR INTEGRATION BOUNDARY CLOSED`

`M32 CSR POST-SYNTHESIS BOUNDARY CLOSED`

`FRP M32 CSR Integration Qualification #1: SUCCESS`

`FRP M32 CSR Post-Synthesis Qualification #1: SUCCESS`

`FRP M32 CSR integration qualification: PASS`

`FRP M32 CSR post-synthesis qualification: PASS`

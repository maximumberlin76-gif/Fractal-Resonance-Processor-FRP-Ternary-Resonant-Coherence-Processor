# FRP M32 CSR Integration Boundary Closure

## Boundary identity

| Field | Recorded value |
|---|---|
| Project | Fractal Resonance Processor (FRP) |
| Milestone | `M32` |
| Closed directory | `fpga/m32_csr/` |
| CSR top | `frp_m32_csr_top` |
| Integration testbench | `frp_m32_csr_tb` |
| Wrapped FPGA top | `frp_m32_fpga_top` |
| Integrated core | `frp_m32_core` |
| Qualified profile | 8 cells, 2 request lanes, 32-bit words and counters |
| Host clock contract | CSR inputs synchronous to `clk` |
| Ternary kernel | `-1/0/1`, with active state `0` |
| Scheduler modes | `free`, `7/1`, `1/7` |
| Qualification commit | `8e619504c7826ba6351d4967d5944685963363f0` |
| Transcript commit | `6567d6cfd45705931b89a88a782b0f0fb1112ffd` |
| Closure status | `M32 CSR INTEGRATION BOUNDARY CLOSED` |

This closure covers the implemented CSR wrapper, host transaction
handling, reset qualification, command delivery, configuration staging,
telemetry readback, deterministic RTL integration simulation and complete
hierarchy structural synthesis through `Yosys synth -noshare -run begin:fine`.

The inherited FPGA integration and core boundaries are recorded in
[fpga/m32/CLOSURE.md](../m32/CLOSURE.md) and
[rtl/m32/CLOSURE.md](../../rtl/m32/CLOSURE.md). The CSR wrapper controls the
existing M32 execution path through `u_fpga.u_m32_core`.

## Qualification authority

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

## Closed artifacts and source identities

| Artifact | Function |
|---|---|
| [frp_m32_csr_top.sv](frp_m32_csr_top.sv) | CSR transactions, command generation, staged configuration and telemetry access |
| [frp_m32_csr_tb.sv](frp_m32_csr_tb.sv) | deterministic host scenarios, independent reference inputs and complete core-output comparison |
| [Qualification workflow](../../.github/workflows/frp-m32-csr-integration-qualification.yml) | manual simulation, structural synthesis, replay comparison and evidence publication |
| [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md) | successful run, source identities, checked scenarios and artifact metadata |
| [CLOSURE.md](CLOSURE.md) | qualified scope, accepted contracts and closure result |

The qualified manifest checks 21 canonical inputs: one M22 CSR package,
13 M31 SystemVerilog dependencies, three M32 SystemVerilog dependencies,
the FPGA top, the CSR top and testbench, and the sine ROM initialization
file. It checks the complete include closure and records the workflow
identity separately.

Exact byte lengths and SHA-256 identities are recorded in
`source-manifest.json` and `canonical-sources.sha256`. The committed
[source-boundary record](SIMULATION_TRANSCRIPT.md#qualified-source-boundary)
preserves the qualified CSR, testbench, ROM and workflow identities.

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

Each simulation replay compares all 59 core outputs exposed by
`dut.u_fpga` against a separate `frp_m32_core` instance. Reference inputs
and reset come from the test stimulus; expected CSR responses are
independent of DUT ready/error decisions.

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

Required simulation terminal record:

    FRP_M32_CSR_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

## Structural synthesis closure

The complete CSR hierarchy is synthesized using
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
writing the final result, the workflow rechecks all canonical source
identities, its own identity, the checked-out commit and the clean Git
working tree.

## Evidence closure

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

## Closure result

`M32 CSR INTEGRATION BOUNDARY CLOSED`

`FRP M32 CSR Integration Qualification #1: SUCCESS`

`FRP M32 CSR integration qualification: PASS`

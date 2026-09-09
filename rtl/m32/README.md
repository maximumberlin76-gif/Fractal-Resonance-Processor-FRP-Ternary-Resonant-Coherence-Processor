# FRP M32 Registered-Target, Full Integrated-Core Synthesis, and Deterministic RTL Trace Boundary

**SystemVerilog registered-target integration, full integrated-core synthesis,
and deterministic trace publication over the qualified M31 RTL contour**

## Boundary identity

| Field | Value |
|---|---|
| Project | `Fractal Resonance Processor (FRP)` |
| Milestone | `M32` |
| RTL source boundary commit | `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| Top-level integration module | `frp_m32_core` |
| Qualified integrated configuration | `8` cells, `2` request lanes |
| Full integrated-core synthesis profile | `8` cells, `2` request lanes |
| Registered-boundary synthesis profiles | `8`, `16`, and `32` cells |
| Scheduler trace modes | `7/1` and `1/7` |
| Canonical ternary notation | `-1/0/1` |
| Trace schema | `frp.m32.deterministic_rtl_trace_bundle.v1` |
| Trace qualification | `38 / 38 PASS` |
| Full synthesis evidence schema | `frp.m32.full-integrated-core-synthesis.v1` |
| Full synthesis qualification run | [`#1 SUCCESS`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34351066791) |
| License | Apache-2.0 |

M32 inserts a clocked registered boundary between the phase-derived target
bank and automatic request formation. The phase-derived source target,
registered target, request target, execution target, retained state, and
pending route remain separately observable quantities.

The M32 integration consumes the existing M31 phase-interference, scheduler,
request, pending-route, active-state-`0`, capacity, retained-writeback,
thermal-proxy, and stability modules at their recorded source identities. M32
does not duplicate those modules.

The full integrated-core synthesis qualifies the complete `frp_m32_core`
hierarchy at the canonical M32 configuration. Two synthesis executions produce
byte-identical JSON netlists, Verilog netlists, and statistics records while
retaining the initialized `4096 x 32` sine lookup table.

## Execution chain

The automatic phase-derived path is:

```
M31 retained phase dynamics
-> M31 relative-phase interference with local effective gamma
-> M31 phase-to-ternary source target
-> M32 registered target boundary
-> M32 registered request gate
-> M31 deterministic request formation
-> M31 scheduler and request handling
-> M31 pending opposite-polarity routing
-> active state 0
-> M31 capacity control
-> M31 retained writeback
-> M31 invariant, thermal, and stability records
```

The relative-phase term remains:

```
sin(theta_j - theta_i - gamma_effective_i)
```

`gamma_effective_i` is local to cell `i`. The phase word remains an unsigned
32-bit value normalized by modular wrap over one complete turn.

## Architectural separation

| Stage | RTL quantity | Role |
|---|---|---|
| Upstream phase result | `phase_target_source` | phase-derived target bank in the canonical ternary domain |
| Registered boundary | `registered_target_q` | accepted target bank retained across the clock boundary |
| Registered validity | `registered_target_valid_q` | records that an accepted upstream bank has been captured |
| Automatic request formation | `phase_request_target` | targets selected from the registered bank for request lanes |
| Execution request | `execution_request_target` | automatic or external request presented to the execution core |
| Execution target bank | `execution_target_bank` | automatic registered bank or external target bank selected by the request mux |
| Retained execution state | `state_out` | state committed by scheduler, routing, arbitration, and capacity logic |
| Retained pending route | `pending_route_out` | unfinished destination polarity retained after a first route leg |

The following identities are therefore false:

```
phase_target_source == executed state
registered_target_q == executed state
request target == retained writeback
phase-order record == coherence-capacity record
```

Each equality may occur for a particular sample, but none is an architectural
identity.

## Registered-target capture

`frp_m32_registered_target_boundary` accepts a source bank only when all of
the following are true:

```
tick_enable
&& phase_target_valid
&& phase_target_domain_valid
```

Every cell symbol is checked against the canonical encodings for `-1`, `0`,
and `1`. A reserved encoding rejects the complete capture transaction. A
rejected or disabled capture retains the previously registered bank and its
validity state.

Reset initializes every registered target cell to active state `0` and clears
the validity bit. The validity bit records accepted upstream capture history;
it does not change the active meaning of state `0`.

The boundary exposes independent, saturating counters for accepted and
rejected capture events. `clear_counters` clears these counters without
replacing the retained registered target bank.

## Registered request formation

`frp_m32_registered_target_request_path` enables automatic requests only when:

```
auto_target_enable
&& registered_target_valid_q
&& registered_target_domain_valid
```

The inherited request adapter receives the registered target together with
the current retained state, pending-route bank, and scheduler state. An
unregistered phase-derived source cannot form an automatic request or bypass
the clocked target boundary.

When `auto_target_enable` is clear, `frp_m32_core` selects the explicit
external request lanes and external target bank. The automatic registered path
and the explicit external path remain separate inputs to the execution mux.

## Active state `0` and route legs

State `0` is retained and executable. Within the M32 trace boundary it is
recorded in its mediation, balancing, routing, damping, transition-staging,
retained-state, pending-route, and controlled-neutralization roles.

Direct opposite-polarity retained transitions are excluded:

```
-1 -> 1
1 -> -1
```

The required routes are:

```
-1 -> 0 -> 1
1 -> 0 -> -1
```

The first route leg commits active state `0` and retains the requested
destination in `pending_route_out`. The second route leg commits that retained
destination on a later eligible tick and clears the pending route. The trace
monitor records `first_route_leg` and `second_route_leg` independently.

## Scheduler-specific trace records

The two cadence modes have separate testbenches, transcripts, structured
records, and replay identities.

| Record | Mode `7/1` | Mode `1/7` |
|---|---:|---:|
| Source ticks | `16` | `17` |
| Cadence counts | `14 balance / 2 commit` | `3 excite / 14 neutralize` |
| Sample records | `16` | `17` |
| Packed-bank records | `16` | `17` |
| Per-cell records | `128` | `136` |
| Request-lane records | `32` | `34` |
| Total structured records | `192` | `204` |
| Active-state-`0` cell observations | `115` | `123` |
| First route leg | source tick `9`, cell `0` | source tick `10`, cell `0` |
| Second route leg | source tick `15`, cell `0` | source tick `16`, cell `0` |

The combined canonical bundle contains:

```
33 source ticks
33 sample records
33 packed-bank records
264 per-cell records
66 request-lane records
396 structured records
```

## Trace record classes

`frp_m32_trace_monitor` emits four record classes for every enabled source
tick.

| Prefix | Cardinality per tick | Recorded boundary |
|---|---:|---|
| `M32_TRACE_SAMPLE` | `1` | scheduler state, capture state, counters, capacity, invariants, phase-order, thermal, and stability telemetry |
| `M32_TRACE_BANK` | `1` | packed source, registered, execution, retained, pending-route, acceptance, and route-leg banks |
| `M32_TRACE_CELL` | `8` | cell coordinates, phase, retained frequency, local effective gamma, interference contribution, targets, retained state, active state `0`, and route state |
| `M32_TRACE_REQUEST` | `2` | request-lane coordinates, automatic and execution request values, and acceptance state |

The exporter parses these records without replacing their source coordinates.
It preserves source transcript identities and produces canonical JSON with
deterministic key ordering and serialization.

## RTL and formal artifacts

| Path | Role |
|---|---|
| [`frp_m32_registered_target_boundary.sv`](frp_m32_registered_target_boundary.sv) | clocked target capture, domain checks, and capture counters |
| [`frp_m32_registered_target_boundary_tb.sv`](frp_m32_registered_target_boundary_tb.sv) | deterministic boundary testbench |
| [`frp_m32_registered_target_request_path.sv`](frp_m32_registered_target_request_path.sv) | registered target to automatic request formation |
| [`frp_m32_registered_target_request_path_tb.sv`](frp_m32_registered_target_request_path_tb.sv) | deterministic request-path testbench |
| [`frp_m32_core.sv`](frp_m32_core.sv) | integrated M32 top-level over the M31 RTL contour |
| [`frp_m32_core_tb.sv`](frp_m32_core_tb.sv) | integrated registered-target execution testbench |
| [`frp_m32_mode_7_1_tb.sv`](frp_m32_mode_7_1_tb.sv) | scheduler mode `7/1` execution testbench |
| [`frp_m32_mode_1_7_tb.sv`](frp_m32_mode_1_7_tb.sv) | scheduler mode `1/7` execution testbench |
| [`frp_m32_trace_monitor.sv`](frp_m32_trace_monitor.sv) | deterministic structured trace monitor |
| [`frp_m32_mode_7_1_trace_tb.sv`](frp_m32_mode_7_1_trace_tb.sv) | full mode `7/1` trace wrapper |
| [`frp_m32_mode_1_7_trace_tb.sv`](frp_m32_mode_1_7_trace_tb.sv) | full mode `1/7` trace wrapper |
| [`../../formal/m32/frp_m32_registered_target_boundary_formal.sv`](../../formal/m32/frp_m32_registered_target_boundary_formal.sv) | bounded safety and capture-sequence harnesses |

## Full integrated-core synthesis boundary

The full synthesis workflow elaborates and synthesizes the complete
`frp_m32_core` hierarchy with the following qualified boundary:

| Property | Recorded value |
|---|---:|
| Qualified profile | `8` cells, `2` request lanes |
| Exact source identities | `17 / 17` |
| SystemVerilog frontend | Yosys `read_slang` |
| Language standard | IEEE `1800-2017` |
| Synthesis flow | coarse, flattened, memory-preserving |
| Synthesis executions | `2` |
| Flattened modules | `1` |
| Remaining processes | `0` |
| Synthesized cells | `7571` |
| Synthesized cell types | `24` |
| Unresolved or black-box cells | `0` |
| Final structural problems | `0` |
| Top-level ports | `74` |
| Top-level port bits | `3135` |
| Input ports | `15` |
| Output ports | `59` |

The canonical phase-interference source contains four post-load simulation
checks implemented with `$fatal`. The workflow leaves the committed source
unchanged and creates a runner-temporary synthesis view that removes exactly
those four checks. The synthesis view retains the canonical `$readmemh`
operation and the exact `frp_m31_sin_q30.mem` source identity.

The synthesized `u_phase_interference.sin_lut` cell remains a `$mem_v2`
memory with this recorded contract:

| Property | Recorded value |
|---|---:|
| Width | `32` bits |
| Depth | `4096` words |
| Address width | `12` bits |
| Read ports | `72` |
| Write ports | `0` |
| Initialization | `131072` bits |
| Canonical contents | bit-exact match |

The two synthesis executions produced byte-identical outputs:

| Output | SHA-256 |
|---|---|
| JSON netlist | `8a3efadabc04e042f59345f40703a14da3d480f9d7870b7ed0fcf44ed12026c8` |
| Verilog netlist | `12ed610244c495fcad3c6b9c6f2dce1101f4a2ce610e66b84a7d4656fbee5ce4` |
| Synthesis statistics | `a1fc59d17f1a7e4250e2a711a597563e127bb5a0ddfbc4ffd0de046e3caf169a` |

The successful manual workflow run qualified commit
`4bd5f97422b6b749c4db33d5658cf98b211f8850` and uploaded the two replay
netlists, two statistics records, two logs, source manifest, synthesis-view
patch, toolchain record, structured evidence, and artifact digest manifest.

## Formal, synthesis, and simulation qualification

The registered-target and full integrated-core synthesis workflows record the
following qualification scope:

| Operation | Recorded result |
|---|---|
| Exact implementation identities | `28` RTL and formal source files |
| Verilator lint | M31/M32 integrated and trace contours `PASS` |
| Registered-boundary synthesis | deterministic `8`, `16`, and `32` cell profiles |
| Full integrated-core synthesis | `8` cells, `2` request lanes, `2/2` deterministic executions |
| Full integrated-core structure | `7571` cells, `74` ports, `3135` port bits, `0` processes |
| Retained sine ROM | `4096 x 32`, `72` read ports, `0` write ports, canonical contents `PASS` |
| Safety harness | `10` assertions, depth `4`, `2/2` deterministic replays |
| Capture-sequence harness | `4` assertions, depth `4`, `2/2` deterministic replays |
| Boundary execution | `2/2` deterministic executions |
| Request-path execution | `2/2` deterministic executions |
| Integrated core execution | `2/2` deterministic executions |
| Mode `7/1` execution | `2/2` deterministic executions |
| Mode `1/7` execution | `2/2` deterministic executions |
| Mode `7/1` full trace | `2/2` byte-identical executions |
| Mode `1/7` full trace | `2/2` byte-identical executions |

The registered-boundary synthesis applies to
`frp_m32_registered_target_boundary` for the three listed cell profiles. The
full synthesis workflow separately qualifies `frp_m32_core` at `8` cells and
`2` request lanes. The integrated top is also compiled, linted, simulated, and
traced by the M32 qualification workflows.

## Canonical publication artifacts

| Record | Repository path |
|---|---|
| Trace schema | [`../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json`](../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json) |
| Trace bundle | [`../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json`](../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json) |
| Manifest | [`../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json`](../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json) |
| Qualification | [`../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json`](../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json) |
| Exporter | [`../../frp_m32_deterministic_rtl_trace_export.py`](../../frp_m32_deterministic_rtl_trace_export.py) |
| Independent exporter tests | [`../../tests/test_frp_m32_deterministic_rtl_trace_export.py`](../../tests/test_frp_m32_deterministic_rtl_trace_export.py) |

The canonical bundle records `29` source identities: `28` RTL and formal
source files plus the registered-target workflow. The manifest records exact
paths, byte lengths, and SHA-256 identities for the schema and trace bundle.
The qualification record references the schema, bundle, and manifest and
records `38 / 38 PASS`. The export workflow also compares all four generated
outputs byte-for-byte with their tracked repository counterparts.

The full integrated-core synthesis evidence is retained as a workflow-run
artifact. It is separate from the four canonical deterministic trace
publication outputs.

## Workflows

| Workflow | Scope |
|---|---|
| [`FRP M32 Registered Target Core`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) | source identities, lint, registered-boundary synthesis, bounded proofs, deterministic simulations, scheduler traces, and uploaded records |
| [`FRP M32 Full Integrated Core Synthesis`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) | exact source identities, memory-preserving full-core synthesis, deterministic netlists, complete port contract, retained sine ROM, and uploaded evidence |
| [`FRP M32 Deterministic RTL Trace Export`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) | transcript replay, exporter tests, canonical generation, schema validation, mutation rejection, published-artifact comparison, and uploaded records |

All three workflows use `workflow_dispatch` and are executed manually on
`main`.

## Provenance boundary

The canonical bundle assigns the M32 sources and their inherited M31 RTL
dependencies to the `upstream_frp_systemverilog_rtl` provenance class. The
bundle does not contain downstream Observatory implementation artifacts.

The M32 layer is additive. It retains all earlier RTL, FPGA, evidence,
benchmark, schema, workflow, release, and deterministic identity records at
their established repository paths.

## Author

**Maksym Marnov (Alchimist)**  
Berlin, Germany  
ORCID: `0009-0000-0832-9597`

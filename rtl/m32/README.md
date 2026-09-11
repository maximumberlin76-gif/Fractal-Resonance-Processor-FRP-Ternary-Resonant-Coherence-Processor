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
| FPGA integration top | `frp_m32_fpga_top` |
| FPGA qualification profile | `8` cells, `2` request lanes |
| Canonical inputs per FPGA qualification | `19 / 19 exact` |
| FPGA integration evidence schema | `frp.m32.fpga-integration-qualification.v1` |
| FPGA integration qualification run | [`#2 SUCCESS`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| Generated post-synthesis DUT | `frp_m32_fpga_netlist` |
| FPGA post-synthesis evidence schema | `frp.m32.fpga-post-synthesis-qualification.v1` |
| FPGA post-synthesis qualification run | `#1 SUCCESS`, recorded duration `13m 36s` |
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

The FPGA wrapper instantiates the complete M32 core and adds reset-release
control, operation gating, and `core_ready`. Integration simulation and
post-synthesis simulation each compare all `59` forwarded core outputs
against a separate M32 RTL reference over `1019` samples per replay.

## Execution chain

The automatic phase-derived path is:

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

The relative-phase term remains:

    sin(theta_j - theta_i - gamma_effective_i)

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

    phase_target_source == executed state
    registered_target_q == executed state
    request target == retained writeback
    phase-order record == coherence-capacity record

Each equality may occur for a particular sample, but none is an architectural
identity.

## Registered-target capture

`frp_m32_registered_target_boundary` accepts a source bank only when all of
the following are true:

    tick_enable
    && phase_target_valid
    && phase_target_domain_valid

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

    auto_target_enable
    && registered_target_valid_q
    && registered_target_domain_valid

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

    -1 -> 1
    1 -> -1

The required routes are:

    -1 -> 0 -> 1
    1 -> 0 -> -1

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

    33 source ticks
    33 sample records
    33 packed-bank records
    264 per-cell records
    66 request-lane records
    396 structured records

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

## FPGA integration and post-synthesis qualification

The FPGA qualification source manifests each contain the same `17`
full-core inputs, the FPGA top, and one selected testbench. Their `18`
common non-testbench inputs have identical byte lengths and SHA-256
values. Integration simulation selects `frp_m32_fpga_tb.sv`;
post-synthesis simulation selects `frp_m32_fpga_post_synthesis_tb.sv`.

### Complete FPGA integration

The integration qualification is recorded by successful manual run
[`#2`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873)
at commit `e40e90d8e32847aa783030aba7e1e5f7963ef312`, with recorded duration
`2m 44s`.

| Qualification property | Recorded boundary |
|---|---|
| FPGA top | `frp_m32_fpga_top` |
| Complete core | `frp_m32_core` |
| Qualified configuration | `8` cells, `2` request lanes |
| Integration testbench | `frp_m32_fpga_tb` |
| Complete interface | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| Forwarded core interface | all `59` outputs compared against a separate M32 core |
| Readiness | `core_ready`, checked against independent reset-release expectations |
| Simulation executions | two replays, `1019` comparison samples per replay |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| Synthesis frontend | `read_slang`, IEEE `1800-2017` |
| Synthesis flow | `synth -top frp_m32_fpga_top -run begin:fine`, followed by `check -assert` |
| Synthesis executions | two byte-identical JSON netlists, Verilog netlists, and statistics records |
| Flattened top | one module named `frp_m32_fpga_top` |
| Remaining processes, latch cells, and unresolved instances | `0` |
| Retained memories | two `$mem_v2` cells |
| Sine ROM | `4096 x 32`, `72` read ports, `0` write ports, exact canonical initialization |

External reset assertion is asynchronous. Release passes through two
clocked stages; enabled core operation is first sampled on the following
rising edge. Tick, counter clear, phase load, automatic request selection,
and external request validity are gated before readiness. A reset that
interrupts release restarts both stages.

The synthesis view uses the verified temporary phase-source transformation
described above, retaining the canonical ROM initialization. The exact
FPGA cell count and cell-type inventory are recorded in the integration
qualification report and both statistics files.

### Synthesized-netlist comparison

The successful manual post-synthesis qualification run `#1`, with recorded
duration `13m 36s`, is documented in
[POST_SYNTHESIS_TRANSCRIPT.md](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md)
against source baseline `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1`.
The [workflow run list](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml)
records the manual execution.

| Qualification property | Workflow acceptance contract |
|---|---|
| Synthesis input | complete `frp_m32_fpga_top` hierarchy at `8` cells and `2` request lanes |
| Generated DUT | `frp_m32_fpga_netlist` |
| Simulation top | `frp_m32_fpga_post_synthesis_tb` |
| Reference | separate complete `frp_m32_core` RTL instance |
| Synthesis replay | two identical JSON netlists, Verilog netlists, and statistics records |
| Simulation export replay | two identical JSON exports and two identical Verilog exports |
| Exported interface | port names, directions, widths, and signedness preserved |
| Exported memories | all `$mem_v2` parameters and initialization preserved |
| Simulation models | `simlib.v` from the same pinned Yosys package |
| Core output comparison | all `59` forwarded outputs at each of `1019` samples per replay |
| Reference reset and readiness | independently supplied scenario expectations |
| Simulation replay | two identical ordered semantic terminal records |

The workflow reads each synthesized JSON into Yosys, applies the standard
`$shiftx` map from `techmap.v`, and renames the exported top to
`frp_m32_fpga_netlist`. It checks that no `$shiftx` or `$connect` cell
remains and that both original synthesis JSON files retain their byte
identities. The distinct DUT name requires the generated netlist as a
simulator input.

Five flattened reset-qualified control wires are observed by the
testbench. Their names and widths are checked during export; the RTL
reference reset follows the independent test scenario. The reference
reads the canonical sine ROM file, while the synthesized DUT uses the
initialization embedded in its netlist.

### Active-zero, scheduler, pause, and clear scenarios

Both FPGA testbenches exercise startup control blocking, interrupted
reset release, phase loading without a tick, registered-target capture,
and both opposite-polarity routes:

    -1 -> 0 -> 1
    1 -> 0 -> -1

Active zero and the pending destination polarity remain retained during
three paused cycles. Each route then completes on an enabled tick without
a new request. Direct polarity transitions, reserved states, and pending
overflow events are rejected throughout the checked samples.

Each FPGA scheduler scenario records `97` ticks and `97` accepted target
captures. The initial tick executes the reset scheduler state `FREE`;
the following `96` ticks cover twelve complete periods for `7/1` and
`1/7`.

| FPGA scenario | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE |
|---|---:|---:|---:|---:|---:|
| `free` | `97` | `0` | `0` | `0` | `0` |
| `7/1` | `1` | `84` | `12` | `0` | `0` |
| `1/7` | `1` | `0` | `0` | `12` | `84` |

Four paused cycles preserve retained state, pending routes, registered
targets, phase, frequency, scheduler state, and thermal sample count.
Isolated counter clear preserves retained data. Concurrent clear and tick
record one scheduler tick while target-capture and thermal event counters
retain clear priority.

### FPGA artifacts and evidence

| Artifact | Recorded scope |
|---|---|
| [frp_m32_fpga_top.sv](../../fpga/m32/frp_m32_fpga_top.sv) | complete core integration, reset-release control, operation gating, and readiness |
| [frp_m32_fpga_tb.sv](../../fpga/m32/frp_m32_fpga_tb.sv) | deterministic integration simulation and output comparison |
| [frp_m32_fpga_post_synthesis_tb.sv](../../fpga/m32/frp_m32_fpga_post_synthesis_tb.sv) | deterministic generated-netlist comparison against the separate RTL reference |
| [FPGA integration transcript](../../fpga/m32/SIMULATION_TRANSCRIPT.md) | successful run, source identities, simulation, synthesis, and published artifact metadata |
| [FPGA post-synthesis transcript](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) | successful run, source baseline, simulation export, ordered terminal records, and evidence inventory |
| [FPGA closure](../../fpga/m32/CLOSURE.md) | integration and post-synthesis closure at `8` cells and `2` request lanes |

The integration workflow defines `24` evidence files. The post-synthesis
workflow requires `35` nonempty files before writing `qualification.json`;
that report records their sizes and SHA-256 values. `artifacts.sha256`
covers the other `36` files, including the final report, giving a complete
post-synthesis evidence directory of `37` files.

Both workflows retain complete simulation logs separately from the ordered
semantic records compared between replays. Source identities, workflow
identity, checked-out commit, and working-tree integrity are rechecked
before the final result; the post-synthesis workflow also rechecks its
recorded Yosys support files.

The FPGA closure records:

    M32 FPGA INTEGRATION BOUNDARY CLOSED
    M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED

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

The full integrated-core synthesis, FPGA integration, and FPGA
post-synthesis evidence are retained as separate workflow-run artifacts.
The four canonical deterministic trace publication outputs retain their
recorded identities.

## Workflows

| Workflow | Scope |
|---|---|
| [`FRP M32 Registered Target Core`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) | source identities, lint, registered-boundary synthesis, bounded proofs, deterministic simulations, scheduler traces, and uploaded records |
| [`FRP M32 Full Integrated Core Synthesis`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) | exact source identities, memory-preserving full-core synthesis, deterministic netlists, complete port contract, retained sine ROM, and uploaded evidence |
| [`FRP M32 FPGA Integration Qualification`](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) | exact sources, complete wrapper simulation, reset and operation gating, full integration synthesis, and uploaded evidence |
| [`FRP M32 FPGA Post-Synthesis Qualification`](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) | full FPGA synthesis, verified simulation export, generated-netlist comparison, deterministic replays, and evidence binding |
| [`FRP M32 Deterministic RTL Trace Export`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) | transcript replay, exporter tests, canonical generation, schema validation, mutation rejection, published-artifact comparison, and uploaded records |

All five workflows use `workflow_dispatch` and are executed manually on
`main`.

## Documentation

| Document | Scope |
|---|---|
| [SIMULATION.md](SIMULATION.md) | reproducible RTL, formal, full-core synthesis, and trace-export procedures |
| [SIMULATION_TRANSCRIPT.md](SIMULATION_TRANSCRIPT.md) | recorded RTL, formal, full-core synthesis, and trace qualification evidence |
| [ARTIFACTS.md](ARTIFACTS.md) | canonical source identities, synthesis and FPGA input sets, workflows, evidence inventories, and documentation revisions |
| [CLOSURE.md](CLOSURE.md) | registered-target RTL, formal, deterministic trace, and full integrated-core synthesis closure |

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

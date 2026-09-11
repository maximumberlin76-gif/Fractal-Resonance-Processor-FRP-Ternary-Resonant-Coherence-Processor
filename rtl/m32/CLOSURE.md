# FRP M32 Registered-Target, Full Integrated-Core Synthesis, and Deterministic RTL Trace Boundary Closure

## Boundary identity

| Field | Recorded value |
|---|---|
| Project | `Fractal Resonance Processor (FRP)` |
| Released upstream baseline | `FRP v3.3.0 / M31` |
| Implementation milestone | `M32` |
| Closed directory | `rtl/m32/` |
| Linked FPGA directory | `fpga/m32/` |
| Linked FPGA top and qualified profile | `frp_m32_fpga_top`, `8` cells, `2` request lanes |
| Linked FPGA closure record | [`fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) |
| RTL source boundary commit | `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| Full integrated-core synthesis qualification commit | `4bd5f97422b6b749c4db33d5658cf98b211f8850` |
| Trace-export qualification commit | `c9944b801d5c84464130d4705b7aa47919acd9ca` |
| Documentation antecedent commit | `31cb6f07e7a60882a76cc9917d7991afefca2794` |
| Integrated top module | `frp_m32_core` |
| Full integrated-core synthesis profile | `8` cells, `2` request lanes |
| Registered-boundary synthesis top | `frp_m32_registered_target_boundary` |
| Registered-boundary synthesis profiles | `8`, `16`, and `32` cells |
| Scheduler modes | `7/1` and `1/7` |
| Canonical ternary notation | `-1/0/1` |
| Trace schema | `frp.m32.deterministic_rtl_trace_bundle.v1` |
| Full synthesis evidence schema | `frp.m32.full-integrated-core-synthesis.v1` |
| License | Apache-2.0 |
| Closure status | `M32 REGISTERED-TARGET, FULL INTEGRATED-CORE SYNTHESIS, AND DETERMINISTIC RTL TRACE BOUNDARY CLOSED` |

This closure applies to the implemented M32 registered-target integration,
its bounded formal and registered-boundary synthesis records, full
integrated-core synthesis, deterministic SystemVerilog execution,
scheduler-specific traces, exact trace exporter, and canonical publication
artifacts. It also links the qualified FPGA integration and post-synthesis
boundaries through their own source manifests, execution records, and
closure statuses. The released upstream baseline remains `FRP v3.3.0 / M31`; this
closure does not assign a new release version.

## Closure authority

The M32 implementation and publication boundary is supported by three
successful manual GitHub Actions records.

| Qualification boundary | Workflow | Successful run | Qualified commit | Result |
|---|---|---|---|---|
| registered-target RTL, synthesis, bounded proofs, simulations, and traces | [`FRP M32 Registered Target Core`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) | [`#6`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34254436439) | `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` | `SUCCESS` |
| full integrated-core synthesis, deterministic netlists, complete port contract, and retained sine ROM | [`FRP M32 Full Integrated Core Synthesis`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) | [`#1`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34351066791) | `4bd5f97422b6b749c4db33d5658cf98b211f8850` | `SUCCESS` |
| deterministic transcript replay, canonical generation, verification, and published-output comparison | [`FRP M32 Deterministic RTL Trace Export`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) | [`#2`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34292365277) | `c9944b801d5c84464130d4705b7aa47919acd9ca` | `SUCCESS` |

The synchronized artifact index at documentation antecedent commit
`31cb6f07e7a60882a76cc9917d7991afefca2794` was followed by these successful
repository checks. The four antecedent document identities below are taken
from that commit.

| Workflow record | Result |
|---|---|
| `FRP Self Test #718` | `SUCCESS` |
| `FRP Structured Output #674` | `SUCCESS` |
| `FRP Benchmark Smoke Test #714` | `SUCCESS` |

The later FPGA qualification records are indexed in
[Linked FPGA integration and post-synthesis closure](#linked-fpga-integration-and-post-synthesis-closure).
Subsequent documentation commits and their repository checks are recorded in
[Documentation closure](#documentation-closure).

## Closed artifact classes

The M32 closure keeps implementation, formal, synthesis-output, workflow,
exporter, publication, and documentation identities distinct.

| Artifact class | Count | Bytes | Identity authority |
|---|---:|---:|---|
| inherited M31 RTL sources | `16` | `252826` | canonical M32 manifest |
| M32 RTL sources and testbenches | `11` | `140680` | canonical M32 manifest |
| M32 bounded-formal source | `1` | `7698` | canonical M32 manifest |
| registered-target workflow | `1` | `41712` | canonical M32 manifest |
| complete canonical source boundary | `29` | `442916` | source commit `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| full integrated-core synthesis source set | `17` | `242432` | exact synthesis-workflow manifest; subset of the canonical source boundary |
| full integrated-core synthesis workflow | `1` | `26799` | repository identity recorded in `ARTIFACTS.md` |
| deterministic full-core synthesis outputs | `6` | `32506080` | three byte-identical replay pairs |
| deterministic trace exporter | `1` | `64267` | exact export-workflow identity |
| independent exporter tests | `1` | `30889` | exact export-workflow identity |
| deterministic export workflow | `1` | `20361` | repository identity recorded in `ARTIFACTS.md` |
| canonical publication outputs | `4` | `458096` | raw and embedded SHA-256 records |
| antecedent M32 documentation | `4` | `106481` | exact identities at documentation antecedent commit |
| this closure record | `1` | self-excluded | repository path `rtl/m32/CLOSURE.md` |

The five-file M32 documentation boundary is:

- `README.md`;
- `ARTIFACTS.md`;
- `SIMULATION.md`;
- `SIMULATION_TRANSCRIPT.md`;
- `CLOSURE.md`.

`CLOSURE.md` is excluded from its own byte and SHA-256 table to avoid a
self-referential identity.

## M32 implementation artifact closure

| Artifact | Closed function | Qualification record |
|---|---|---|
| `frp_m32_registered_target_boundary.sv` | clocked target capture, ternary-domain validation, retained valid state, and capture counters | lint, `8/16/32`-cell synthesis, bounded proof, deterministic simulation |
| `frp_m32_registered_target_boundary_tb.sv` | accepted, rejected, disabled, reset, retained-bank, and counter-clear capture sequences | `2/2` byte-identical executions |
| `frp_m32_registered_target_request_path.sv` | registered target gate and M31 request-adapter composition | lint and deterministic simulation |
| `frp_m32_registered_target_request_path_tb.sv` | source, registered, request, pending-route, and scheduler separation | `2/2` byte-identical executions |
| `frp_m32_core.sv` | integrated registered-target top-level over the M31 phase, execution, thermal, and stability contour | lint, deterministic simulation, and full synthesis at `8` cells with `2` request lanes |
| `frp_m32_core_tb.sv` | integrated capture, request, execution, routing, frequency, thermal, stability, and invariant sequence | `2/2` byte-identical executions |
| `frp_m32_mode_7_1_tb.sv` | dedicated `7/1` cadence and two-leg route sequence | `2/2` byte-identical executions |
| `frp_m32_mode_1_7_tb.sv` | dedicated `1/7` cadence and two-leg route sequence | `2/2` byte-identical executions |
| `frp_m32_trace_monitor.sv` | deterministic sample, bank, cell, and request records | lint and structured trace execution |
| `frp_m32_mode_7_1_trace_tb.sv` | mode `7/1` testbench and trace-monitor composition | `2/2` byte-identical full transcripts |
| `frp_m32_mode_1_7_trace_tb.sv` | mode `1/7` testbench and trace-monitor composition | `2/2` byte-identical full transcripts |
| `formal/m32/frp_m32_registered_target_boundary_formal.sv` | registered-target safety and capture-sequence harnesses | `14` assertions at depth `4`, each harness `2/2` deterministic |

Implementation artifact result:

    PASS

## Integrated execution-chain closure

The qualified automatic execution chain is:

    M31 retained phase and frequency dynamics
    -> M31 relative-phase interference with local gamma_effective_i
    -> M31 phase-to-ternary source target
    -> M32 registered target boundary
    -> M32 registered request gate
    -> M31 deterministic request formation
    -> M31 scheduler and request handling
    -> M31 pending opposite-polarity routing
    -> active state 0
    -> M31 capacity control
    -> M31 retained-state writeback
    -> M31 invariant, thermal, and stability records
    -> M32 deterministic structured trace monitor
    -> M32 canonical trace exporter

The relative-phase term remains:

    sin(theta_j - theta_i - gamma_effective_i)

The receiving-cell value `gamma_effective_i` is used throughout the local
interaction sum. Phase remains a retained unsigned 32-bit modular word, and
retained frequency remains a signed Q16 dynamic state with relaxation toward
its target.

Integrated execution-chain result:

    PASS

## Registered-target closure

The registered boundary accepts a phase-derived target bank only when:

    tick_enable
    && phase_target_valid
    && phase_target_domain_valid

The complete capture transaction is rejected when any cell contains the
reserved encoding. A rejected or disabled capture retains the preceding
registered target bank and registered-valid state.

| Registered-target relation | Result |
|---|---|
| reset target bank equals active state `0` | `PASS` |
| reset registered-valid state is clear | `PASS` |
| valid enabled source bank is captured on the clock edge | `PASS` |
| invalid source bank is rejected as one transaction | `PASS` |
| disabled capture retains the registered bank | `PASS` |
| source target remains separate from registered target | `PASS` |
| registered target remains separate from executed state | `PASS` |
| unregistered source cannot form an automatic request | `PASS` |
| accepted and rejected capture counters saturate independently | `PASS` |
| counter clearing preserves the registered target bank | `PASS` |

Registered-target boundary result:

    PASS

## Balanced ternary execution closure

The retained processor-state domain is exactly:

    T = {-1, 0, 1}

| State | Encoding | Recorded execution role |
|---:|---|---|
| `-1` | `2'b11` | negative-polarity retained state |
| `0` | `2'b00` | mediation, balancing, routing, damping, transition staging, retained-state participation, pending-route handling, and controlled neutralization |
| `1` | `2'b01` | positive-polarity retained state |
| reserved | `2'b10` | excluded encoding |

State `0` is retained, executable, and separately observable. It is the
first retained state of an opposite-polarity route before the later pending
destination writeback.

Direct opposite-polarity retained transitions remain excluded:

    -1 -> 1
    1 -> -1

The required routes remain:

    -1 -> 0 -> 1
    1 -> 0 -> -1

The M32 canonical full traces record the `1 -> 0 -> -1` route with separate
first and second legs in both scheduler modes.

| Mode | First leg | Second leg | Direct-event count | Result |
|---|---|---|---:|---|
| `7/1` | source tick `9`, cell `0`, retained state `0`, pending target `-1` | source tick `15`, cell `0`, retained state `-1`, pending cleared | `0` | `PASS` |
| `1/7` | source tick `10`, cell `0`, retained state `0`, pending target `-1` | source tick `16`, cell `0`, retained state `-1`, pending cleared | `0` | `PASS` |

Balanced ternary execution result:

    PASS

## Scheduler closure

The two scheduler modes retain separate testbenches, traces, records, and
transcript identities.

| Record | Mode `7/1` | Mode `1/7` |
|---|---:|---:|
| source ticks | `16` | `17` |
| cadence | `14 balance / 2 commit` | `3 excite / 14 neutralize` |
| sample records | `16` | `17` |
| packed-bank records | `16` | `17` |
| per-cell records | `128` | `136` |
| request-lane records | `32` | `34` |
| total structured records | `192` | `204` |
| active-state-`0` cell observations | `115` | `123` |
| full-transcript replay | `2/2` byte-identical | `2/2` byte-identical |

Scheduler closure result:

    PASS

## Trace-observation closure

`frp_m32_trace_monitor` emits four deterministic record classes for every
enabled source tick.

| Record class | Cardinality per tick | Closed observation boundary |
|---|---:|---|
| `M32_TRACE_SAMPLE` | `1` | scheduler, capture, counters, capacity, invariants, phase order, coherence capacity, thermal, and stability records |
| `M32_TRACE_BANK` | `1` | packed source, registered, execution, retained, pending, acceptance, and route-leg banks |
| `M32_TRACE_CELL` | `8` | source coordinates, phase, retained frequency, local gamma, interference, targets, retained state, active state `0`, and pending route |
| `M32_TRACE_REQUEST` | `2` | request-lane coordinates, automatic request, execution request, target, and acceptance state |

The combined canonical trace contains:

    33 source ticks
    33 sample records
    33 packed-bank records
    264 per-cell records
    66 request-lane records
    396 structured records

The trace records preserve pair, cluster, and global phase-order fields as
separate quantities. `coherence_capacity_q16` remains distinct from these
phase-order fields.

| Trace invariant | Recorded result |
|---|---|
| source-tick coordinates complete | `PASS` |
| cell coordinates complete | `PASS` |
| request-lane coordinates complete | `PASS` |
| packed banks match cell records | `PASS` |
| packed masks match cell records | `PASS` |
| ternary code/value pairs valid | `PASS` |
| active-state-`0` markers exact | `PASS` |
| first and second route legs separately observable | `PASS` |
| phase evolution records present | `PASS` |
| local effective gamma records present | `PASS` |
| relative-phase interference records present | `PASS` |
| retained-frequency dynamics observed | `PASS` |
| thermal telemetry present | `PASS` |
| stability telemetry present | `PASS` |
| invariant flags valid for every sample | `PASS` |
| direct opposite-polarity events | `0` |
| reserved-state events | `0` |
| queue-overflow events | `0` |

Trace-observation closure result:

    PASS

## Lint, synthesis, and bounded-formal closure

| Qualification operation | Exact scope | Recorded result |
|---|---|---|
| Verilator lint | `11` M32 implementation and trace tops | `11/11 PASS` |
| registered-boundary synthesis | `frp_m32_registered_target_boundary` at `8`, `16`, and `32` cells | `3/3 profiles, 2/2 byte-identical netlists per profile` |
| full integrated-core synthesis | `frp_m32_core` at `8` cells and `2` request lanes | `2/2 byte-identical JSON, Verilog, and statistics records` |
| safety bounded proof | `frp_m32_registered_target_boundary_safety_formal`, `10` assertions, depth `4` | `2/2 deterministic filtered records` |
| capture-sequence bounded proof | `frp_m32_registered_target_boundary_sequence_formal`, `4` assertions, depth `4` | `2/2 deterministic filtered records` |

The registered-boundary synthesis record applies to
`frp_m32_registered_target_boundary` at the three listed cell profiles. The
separate full integrated-core synthesis record applies to `frp_m32_core` at
`8` cells and `2` request lanes. The integrated top also remains qualified by
lint, deterministic simulation, assertion execution, and deterministic trace
generation. The bounded proofs apply to the two registered-target harnesses
at depth `4`.

Lint, synthesis, and bounded-formal result:

    PASS

## Full integrated-core synthesis closure

The successful full synthesis workflow elaborates the complete
`frp_m32_core` hierarchy from `17` exact source identities. The set contains
`14` inherited M31 packages, RTL modules, and sine-memory files plus `3` M32
registered-target and integrated-core modules. Its `242432` bytes are a
subset of the fixed `29`-identity canonical source boundary.

| Synthesis record | Recorded value |
|---|---|
| workflow bytes | `26799` |
| workflow SHA-256 | `1bd49d55d6f0842170b18547562cdf0122eea389015a7aae25d97725ba70c955` |
| successful run | `34351066791` |
| successful job | `102464192260` |
| qualified commit | `4bd5f97422b6b749c4db33d5658cf98b211f8850` |
| top module | `frp_m32_core` |
| qualified profile | `8` cells, `2` request lanes |
| source identities | `17/17 exact` |
| source-identity record SHA-256 | `762962e82a310c648ffa98f904fd654811801d9de38f22149a8de53c43f4e9e0` |
| synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | Yosys `read_slang` |
| language standard | IEEE `1800-2017` |
| synthesis flow | `yosys-coarse-memory-preserving` |
| synthesis pass boundary | `synth -top frp_m32_core -run begin:fine` |
| evidence schema | `frp.m32.full-integrated-core-synthesis.v1` |
| synthesis executions | `2` |
| flattened modules | `1` |
| remaining processes | `0` |
| synthesized cells | `7571` |
| synthesized cell types | `24` |
| unresolved or black-box cells | `0` |
| final structural problems | `0` |
| top-level ports | `74` |
| top-level port bits | `3135` |
| input ports | `15` |
| output ports | `59` |

The complete port contract is checked by exact name, direction, and width.
Both synthesis executions use the same source identities, parameters,
frontend, language standard, pass boundary, and output commands.

The workflow prepares a temporary synthesis view of the canonical source.
It removes exactly four simulation-only post-load `$fatal` checks from the
staged phase-interference module and retains exactly one canonical
`$readmemh` operation. The tracked source and canonical sine-memory file
retain their recorded identities.

| Phase-source record | Canonical source | Temporary synthesis view |
|---|---:|---:|
| bytes | `11245` | `10853` |
| SHA-256 | `e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0` | `571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8` |
| retained `$readmemh` statements | `1` | `1` |

The synthesized `u_phase_interference.sin_lut` cell remains a `$mem_v2`
memory with initialization checked bit-for-bit against
`rtl/m31/frp_m31_sin_q30.mem`.

| Sine-ROM record | Recorded value |
|---|---|
| canonical memory file bytes | `36864` |
| canonical memory file SHA-256 | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| width | `32` bits |
| depth | `4096` words |
| address width | `12` bits |
| read ports | `72` |
| write ports | `0` |
| initialization length | `131072` bits |
| canonical big-endian word-stream SHA-256 | `74d1dcc6b7a1e55409c24fcf05b08f14b28ea4614d11d9eddcfe2dcbc7014816` |
| synthesized initialization matches canonical memory | `true` |

The two synthesis executions produce three byte-identical replay pairs:

| Output | Executions | Bytes per output | SHA-256 | Comparison |
|---|---:|---:|---|---|
| JSON netlist | `2` | `13768027` | `8a3efadabc04e042f59345f40703a14da3d480f9d7870b7ed0fcf44ed12026c8` | byte-identical |
| Verilog netlist | `2` | `2482578` | `12ed610244c495fcad3c6b9c6f2dce1101f4a2ce610e66b84a7d4656fbee5ce4` | byte-identical |
| synthesis statistics | `2` | `2435` | `a1fc59d17f1a7e4250e2a711a597563e127bb5a0ddfbc4ffd0de046e3caf169a` | byte-identical |

These six deterministic files contain `32506080` bytes in total. Their
artifact member names and individual identities are recorded in
[`ARTIFACTS.md`](ARTIFACTS.md).

| Uploaded synthesis artifact | Recorded value |
|---|---|
| artifact ID | `10103769648` |
| artifact name | `frp-m32-full-integrated-core-synthesis-4bd5f97422b6b749c4db33d5658cf98b211f8850` |
| archive bytes | `4458199` |
| archive digest | `sha256:ecfd84de6eb0a0f12e5c3b997cc3223be661ded3f53ecd5241948201b17b1e94` |
| created | `2026-09-09T12:28:36Z` |
| recorded expiry | `2026-10-09T12:28:35Z` |
| retention | `30` days |

The uploaded synthesis evidence also contains both synthesis logs, the exact
source-identity record and manifest, synthesis-view patch, toolchain record,
`read_slang` frontend record, structured evidence, and synthesis-artifact
digest manifest. This workflow-run artifact is separate from the four
tracked canonical deterministic trace publication outputs.

Full integrated-core synthesis result:

    PASS

## Linked FPGA integration and post-synthesis closure

The FPGA boundary composes `frp_m32_fpga_top` with the complete
`frp_m32_core` at `8` cells and `2` request lanes. Its two successful manual
qualifications on `main` are preserved in
[`fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md).

| Qualification | Workflow | Successful run | Source association | Duration | Result |
|---|---|---|---|---|---|
| FPGA integration | [FRP M32 FPGA Integration Qualification](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) | [#2](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) | qualified commit `e40e90d8e32847aa783030aba7e1e5f7963ef312` | `2m 44s` | `SUCCESS` |
| FPGA post-synthesis | [FRP M32 FPGA Post-Synthesis Qualification](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) | `#1`; [workflow run list](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml) | source baseline `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1` | `13m 36s` | `SUCCESS` |

The integration record identifies run `34531635873`, attempt `1`, and job
`103053501919`. The post-synthesis `qualification.json` binds its execution
to `source_commit`, `run_id`, and `run_attempt`. The committed transcripts
preserve each qualification's recorded evidence:

- [FPGA integration transcript](../../fpga/m32/SIMULATION_TRANSCRIPT.md);
- [FPGA post-synthesis transcript](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md).

### Linked source identities

Each FPGA workflow checks `19` canonical inputs: `13` inherited M31
SystemVerilog files, `3` M32 SystemVerilog files, the FPGA top, its selected
testbench, and the canonical sine-memory file. The `18` common inputs contain
`253787` bytes. With the integration testbench the input set contains
`290959` bytes; with the post-synthesis testbench it contains `292228` bytes.
These FPGA manifests retain their own identity scope alongside the fixed
`29`-identity RTL boundary and its `17`-identity full-core synthesis subset.

| FPGA source or workflow | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32/frp_m32_fpga_top.sv` | `11355` | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32/frp_m32_fpga_tb.sv` | `37172` | `75a0b2e261fff6a8b955c758415c60f360d58c091b598e0af5d2e61ade6a6c18` |
| `fpga/m32/frp_m32_fpga_post_synthesis_tb.sv` | `38441` | `f619094e59932cc48d54a27a6650d8913ede84e754069f1b911ef3e692d953d8` |
| `.github/workflows/frp-m32-fpga-integration-qualification.yml` | `30337` | `14fba7469ecc1b76e3547d11db7f34986f15272d983e3aea19b52dbafb8e9145` |
| `.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml` | `40054` | `d240b6be6f2e1d30b5bd69b3a92b0b801d9895a1b37efcda39488c9d7b77bed5` |

### Linked execution and synthesis results

| Qualified relation | Recorded result |
|---|---|
| complete FPGA interface | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| forwarded core interface | all `59` outputs compared with a standalone `frp_m32_core` reference |
| readiness output | `core_ready` checked against the independently modeled reset-release sequence |
| reset behavior | asynchronous assertion, two-stage synchronous release, operation on the following rising edge |
| startup controls | startup pulses discarded; controls held through release act on the first operational edge |
| reset reassertion | both release stages restart |
| integration simulation | `2` replays, `1019` checked samples per replay |
| post-synthesis simulation | generated `frp_m32_fpga_netlist` DUT, separate RTL reference, `2` replays, `1019` checked samples per replay |
| retained-state domain | `-1/0/1`, with executable and retained active state `0` |
| opposite-polarity routes | `-1 -> 0 -> 1` and `1 -> 0 -> -1`; pending target retained through `3` paused cycles; second leg completes without a new request |
| pause and clear | retained banks, phase, frequency, and counters checked during pause; isolated clear retains data; concurrent tick and clear follow the recorded counter priorities |
| synthesis frontend and package | IEEE `1800-2017`, `read_slang`, `yowasp-yosys==0.68.0.0.post1208` |
| complete FPGA synthesis | `synth -top frp_m32_fpga_top -run begin:fine`, flattened and memory-preserving |
| synthesized structure | `1` module, at least `7000` cells, `0` processes, `0` latches, `0` unresolved cells, `2` `$mem_v2` memories |
| reset-release structure | two-bit `$adff`, rising-edge clock, active-low asynchronous reset to zero, verified stage connectivity |
| retained sine ROM | `4096 x 32`, `72` read ports, `0` write ports, complete initialization checked against the canonical memory |
| synthesis replay | `2` executions; JSON, Verilog, and statistics pairs byte-identical |

The FPGA mode scenarios each contain `97` ticks and `97` accepted target
captures. Their counts are recorded independently of the `16`-tick and
`17`-tick canonical RTL trace scenarios above.

| FPGA scenario | FREE | BALANCE | COMMIT | EXCITE | NEUTRALIZE | Total ticks |
|---|---:|---:|---:|---:|---:|---:|
| `free` | `97` | `0` | `0` | `0` | `0` | `97` |
| `7/1` | `1` | `84` | `12` | `0` | `0` | `97` |
| `1/7` | `1` | `0` | `0` | `12` | `84` | `97` |

The two scheduled scenarios include the reset `FREE` tick followed by `96`
ticks spanning complete scheduler periods.

### Post-synthesis export and evidence binding

The post-synthesis workflow retains both original synthesized netlists and
exports simulation copies. The export lowers `$shiftx` through the pinned
Yosys `techmap.v`, runs cleanup and structural checks, and renames the DUT
to `frp_m32_fpga_netlist`. It verifies every port name, direction, width,
and signedness; memory parameters and initialization; and five retained
control-observation wires. Those wires remain observation points while the
reference reset and readiness model is driven independently.

The two exported JSON and Verilog pairs are byte-identical. The simulator
uses `yosys-simlib.v` from the pinned package. `cell-models.json` records
its identity and that of the package's `yosys-techmap.v`. Each replay compares
all `59` synthesized outputs with the standalone RTL reference over the
recorded `1019` samples. Replay comparison uses the extracted semantic
records; the evidence also retains both complete runtime logs.

The temporary synthesis view preserves the canonical phase source and sine
memory identities. Source, workflow, staged-view, and cell-model integrity
checks remain part of qualification.

| Evidence record | FPGA integration | FPGA post-synthesis |
|---|---|---|
| qualification schema | `frp.m32.fpga-integration-qualification.v1` | `frp.m32.fpga-post-synthesis-qualification.v1` |
| evidence directory | `24` files | `37` files |
| simulation terminal | `FRP M32 FPGA integration testbench PASS` | `FRP M32 FPGA post-synthesis testbench PASS` |
| qualification terminal | `FRP M32 FPGA integration qualification: PASS` | `FRP M32 FPGA post-synthesis qualification: PASS` |
| closure status | `M32 FPGA INTEGRATION BOUNDARY CLOSED` | `M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED` |

The post-synthesis report records `35` required nonempty evidence files with
their sizes and SHA-256 values. Adding `qualification.json` gives the `36`
files covered by the checksum list; the checksum list is the `37th` file.
The exact member inventory is indexed in
[`ARTIFACTS.md`](ARTIFACTS.md), and the complete execution procedure is in
[`SIMULATION.md`](SIMULATION.md).

## Deterministic execution closure

Each executable top was built once and executed twice. Each runtime pair was
compared byte-for-byte.

| Executable top | Stable terminal marker | Replay result |
|---|---|---|
| `frp_m32_registered_target_boundary_tb` | `FRP_M32_REGISTERED_TARGET_BOUNDARY_TB: PASS` | `2/2 byte-identical` |
| `frp_m32_registered_target_request_path_tb` | `FRP_M32_REGISTERED_TARGET_REQUEST_PATH_TB: PASS` | `2/2 byte-identical` |
| `frp_m32_core_tb` | `FRP_M32_INTEGRATED_REGISTERED_TARGET_CORE_TB: PASS` | `2/2 byte-identical` |
| `frp_m32_mode_7_1_tb` | `FRP_M32_REGISTERED_TARGET_MODE_7_1_TB: PASS` | `2/2 byte-identical` |
| `frp_m32_mode_1_7_tb` | `FRP_M32_REGISTERED_TARGET_MODE_1_7_TB: PASS` | `2/2 byte-identical` |
| `frp_m32_mode_7_1_trace_tb` | `FRP_M32_MODE_7_1_TRACE_TB: PASS samples=16` | `2/2 byte-identical` |
| `frp_m32_mode_1_7_trace_tb` | `FRP_M32_MODE_1_7_TRACE_TB: PASS samples=17` | `2/2 byte-identical` |

Deterministic execution result:

    PASS

## Exact transcript closure

| Scheduler mode | Replay | Bytes | SHA-256 |
|---|---:|---:|---|
| `7/1` | `1` | `105702` | `9517a02cd1ce2c687365f3712a453a9370e505ee4267e151fd05b266977ce915` |
| `7/1` | `2` | `105702` | `9517a02cd1ce2c687365f3712a453a9370e505ee4267e151fd05b266977ce915` |
| `1/7` | `1` | `112364` | `41de8e92c28f150f8d163fc1438b4d4381fa42d76a970f9246bbda4679491d89` |
| `1/7` | `2` | `112364` | `41de8e92c28f150f8d163fc1438b4d4381fa42d76a970f9246bbda4679491d89` |

Exact transcript closure result:

    PASS

## Deterministic exporter closure

| Exporter boundary | Recorded value |
|---|---|
| exporter path | `frp_m32_deterministic_rtl_trace_export.py` |
| exporter bytes | `64267` |
| exporter SHA-256 | `1a575482d0c62f977afc72f25c8d8eacb0daa35981f39cb64b7f85069e5c43cd` |
| independent test path | `tests/test_frp_m32_deterministic_rtl_trace_export.py` |
| independent test bytes | `30889` |
| independent test SHA-256 | `e2b53c9973219b02c0fce2eda835bef87de0d8681ab61af89ef621fbafdfe774` |
| focused tests | `49/49 PASS` |
| deterministic generation replays | `2` |
| rejected mutations | `4/4` |
| source identities | `29/29 exact` |
| transcript identities | `4/4 exact` |
| output verification state | `EXACT` |
| published-output comparison | `4/4 byte-identical` |

Deterministic exporter result:

    PASS

## Canonical publication closure

| Canonical output | Bytes | Raw SHA-256 | Result |
|---|---:|---|---|
| `schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json` | `34066` | `534db8227218184cac5d1cabb461dd63b1b61a99e0269c98535539ad3f7d7da2` | `PASS` |
| `artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json` | `412195` | `62d8c1e6d205b9262a5c950883d3259275d5049f7a896ae12956a210cb75b7e0` | `PASS` |
| `artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json` | `7211` | `da011dbc726d6d1fc0b7dbae12afe1e13d8240df64b9474fd0130c94ba005859` | `PASS` |
| `artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json` | `4624` | `26ec2d3eadd73b490eb023572101bb78cf5d11561ead91b78b1a30e690458273` | `PASS` |
| **Total** | **`458096`** | **`4` exact files** | **`PASS`** |

| Canonical record | Embedded SHA-256 |
|---|---|
| trace bundle | `63b36c1fb29d28a33bb5387d7658c97fc0a51f6823f79dc71382132236685f9b` |
| manifest | `a9dd7d470fd094cb1dbb6fa360f6c28bf50d4aae4bf2f1ba34ad223655968c2e` |
| qualification | `a695ccb3c7f083e219ff6908dfc38e6f4e7ef37fca6da22f40c6303117027c5d` |

The qualification record contains `38` checks, `38` passed checks, and `0`
failed checks. It qualifies the schema, trace bundle, and manifest. The
qualification record itself is the fourth generated file.

Canonical publication result:

    38 / 38 PASS

## Documentation closure

### Preserved antecedent snapshot

The following byte lengths and SHA-256 values identify the documentation at
antecedent commit `31cb6f07e7a60882a76cc9917d7991afefca2794`. They remain
bound to that historical snapshot. Later revisions are indexed separately
below by their confirmed commits.

| Documentation artifact | Bytes | SHA-256 | Status |
|---|---:|---|---|
| `README.md` | `16442` | `0adc5cdf3500fd140bba5f36d16ec12bab5e98e9d93da80881705e091d37072d` | `COMPLETE` |
| `ARTIFACTS.md` | `25395` | `0554bf98714ecfd7404e5df40f129f3c168b6491c38aa5d2f1cb1e0ff3cf6190` | `COMPLETE` |
| `SIMULATION.md` | `31343` | `fc16a800914d2440e6b0b68d368066bc167c56a50a0b60ac1c2a7c8b73aa8005` | `COMPLETE` |
| `SIMULATION_TRANSCRIPT.md` | `33301` | `2808384360e3910770f8e59f6133e481409720c593a02e6d833b7854fe66692a` | `COMPLETE` |
| `CLOSURE.md` | self-excluded | self-excluded | `COMPLETE` |

The four antecedent documents contain `106481` bytes in total and match the
recorded documentation antecedent commit. This closure records their exact
identities without embedding its own digest.

### Subsequent documentation revisions

| Repository path | Confirmed commit | Recorded update |
|---|---|---|
| [`fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md`](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) | `20ac396` | successful FPGA post-synthesis qualification, source association, checked simulation records, and evidence inventory |
| [`fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) | `07c0249` | FPGA integration and post-synthesis closure records |
| [`README.md`](../../README.md) | `88c7650` | repository-level FPGA post-synthesis qualification reference |
| [`rtl/m32/ARTIFACTS.md`](ARTIFACTS.md) | `1203250` | exact FPGA inputs, workflow identities, and post-synthesis evidence inventory |
| [`rtl/m32/README.md`](README.md) | `c4f4774` | M32 architecture links to qualified FPGA integration and post-synthesis records |
| [`rtl/m32/SIMULATION.md`](SIMULATION.md) | `75549ec` | FPGA integration and post-synthesis execution procedures and verification records |

The three updated M32 documents were followed by these successful repository
checks, as confirmed in the supplied GitHub Actions records:

| Documentation commit | FRP Self Test | FRP Structured Output | FRP Benchmark Smoke Test |
|---|---|---|---|
| `1203250` | `#733 SUCCESS` | `#689 SUCCESS` | `#729 SUCCESS` |
| `c4f4774` | `#734 SUCCESS` | `#690 SUCCESS` | `#730 SUCCESS` |
| `75549ec` | `#735 SUCCESS` | `#691 SUCCESS` | `#731 SUCCESS` |

These records identify the documentation checks. The RTL, full-core
synthesis, trace-export, FPGA integration, and FPGA post-synthesis
qualification runs retain their own recorded commits and results above.

Documentation closure:

    5 / 5 COMPLETE

## Provenance closure

The canonical bundle assigns the exact M31/M32 source boundary to:

    upstream_frp_systemverilog_rtl

The bundle records repository source paths, source byte lengths, source
SHA-256 values, transcript identities, and source coordinates. It contains no
downstream Observatory implementation artifact.

The trace schema, bundle, manifest, and qualification records form the exact
read-only artifact boundary available to downstream intake.

Provenance closure result:

    PASS

## Historical preservation closure

The registered-target and deterministic trace-export workflows ended with a
clean-repository comparison and the stable terminal record:

    Repository preservation: PASS

The full integrated-core synthesis workflow checks a clean dispatched
checkout before execution, uses read-only repository permissions with
persisted checkout credentials disabled, and writes its staged source and
synthesis outputs under `RUNNER_TEMP`. The canonical phase source retains
its recorded identity after synthesis-view preparation.

The M32 boundary is additive. Earlier evidence, benchmark, manifest, schema,
workflow, failed-run, successful-run, release, tag, archive, FPGA, RTL, and
deterministic identity history remains at its established repository and
GitHub paths.

The preserved repair workflow remains at:

    .github/workflows/frp-m32-canonical-trace-bundle-repair.yml

It records the guarded restoration of the exact canonical bundle after
manual multipart insertion. It is not part of the canonical source identity
set and does not replace the deterministic export workflow.

Historical preservation result:

    PASS

## Final closure table

| Closure boundary | Recorded result |
|---|---|
| fixed RTL source boundary commit | `PASS` |
| inherited M31 RTL identities | `16/16 exact` |
| M32 RTL identities | `11/11 exact` |
| M32 bounded-formal identity | `1/1 exact` |
| registered-target workflow identity | `1/1 exact` |
| complete canonical source boundary | `29/29 exact` |
| full integrated-core synthesis source set | `17/17 exact` |
| full integrated-core synthesis workflow identity | `1/1 exact` |
| registered target capture and retention | `PASS` |
| phase-derived, registered, request, execution, and retained-state separation | `PASS` |
| canonical `-1/0/1` domain | `PASS` |
| active state `0` execution and observation | `PASS` |
| tick-separated pending-route legs | `PASS` |
| direct opposite-polarity events | `0` |
| reserved-state events | `0` |
| queue-overflow events | `0` |
| scheduler mode `7/1` | separate deterministic trace `PASS` |
| scheduler mode `1/7` | separate deterministic trace `PASS` |
| Verilator lint tops | `11/11 PASS` |
| registered-boundary synthesis profiles | `3/3 PASS` |
| full integrated-core synthesis profile | `8` cells, `2` request lanes, `PASS` |
| flattened integrated-core modules | `1` |
| remaining integrated-core processes | `0` |
| synthesized integrated-core cells | `7571` |
| complete integrated-core port contract | `74` ports, `3135` bits, `PASS` |
| retained sine ROM | `4096 x 32`, `72` read ports, `0` write ports, canonical contents `PASS` |
| deterministic synthesis output pairs | `3/3 byte-identical` |
| synthesis source staging | temporary view; canonical phase identity preserved |
| bounded formal assertions | `14/14 PASS at depth 4` |
| deterministic testbench pairs | `7/7 byte-identical` |
| deterministic transcript identities | `4/4 exact` |
| focused exporter tests | `49/49 PASS` |
| mutation rejections | `4/4 PASS` |
| source ticks | `33` |
| structured trace records | `396` |
| canonical qualification checks | `38/38 PASS` |
| canonical publication files | `4/4 exact` |
| linked FPGA integration source manifest | `19/19 exact` |
| linked FPGA post-synthesis source manifest | `19/19 exact` |
| linked FPGA interface | `75` ports, `3136` bits, `PASS` |
| linked FPGA integration simulation | `59` outputs, `1019` samples per replay, `2/2 PASS` |
| linked FPGA complete synthesis | `8` cells, `2` request lanes, deterministic synthesis and structural checks `PASS` |
| linked FPGA post-synthesis simulation | generated netlist DUT, `59` outputs, `1019` samples per replay, `2/2 PASS` |
| linked FPGA integration and post-synthesis evidence | `24` integration files; `37` post-synthesis files |
| linked FPGA integration boundary | `CLOSED` |
| linked FPGA post-synthesis boundary | `CLOSED` |
| M32 documentation files | `5/5 COMPLETE` |
| provenance boundary | `PASS` |
| repository preservation | `PASS` |
| M32 registered-target, full integrated-core synthesis, and deterministic RTL trace boundary | `CLOSED` |

## Closure statement

The FRP M32 registered-target, full integrated-core synthesis, and
deterministic RTL trace boundary is closed.

The closed technical boundary contains:

- the exact `29`-identity M31/M32 source boundary;
- the exact `17`-identity full integrated-core synthesis source subset;
- the integrated `frp_m32_core` top module;
- clocked registered capture of valid phase-derived ternary target banks;
- separate phase-derived, registered, request, execution, retained-state,
  and pending-route quantities;
- inherited relative-phase interference using local `gamma_effective_i`;
- inherited retained modular phase and retained-frequency dynamics;
- active state `0` mediation and separately observable route staging;
- separate scheduler modes `7/1` and `1/7`;
- tick-separated pending-route first and second legs;
- deterministic request formation, capacity control, and retained writeback;
- pair, cluster, and global phase-order records separated from coherence
  capacity;
- thermal, stability, and invariant telemetry;
- eleven linted M32 implementation and trace tops;
- deterministic `8`, `16`, and `32` cell registered-boundary synthesis
  profiles;
- full `frp_m32_core` synthesis at `8` cells and `2` request lanes;
- one flattened integrated-core module with `7571` synthesized cells and
  `0` remaining processes;
- the exact `74`-port, `3135`-bit integrated-core interface;
- the retained `4096 x 32` sine ROM with bit-exact canonical initialization;
- three byte-identical JSON, Verilog, and statistics synthesis replay pairs;
- the recorded full-synthesis workflow identity and uploaded evidence;
- fourteen bounded assertions at depth `4`;
- seven byte-identical deterministic simulation pairs;
- four exact scheduler transcript identities;
- `33` source ticks and `396` structured records;
- forty-nine independent exporter tests;
- four deterministic mutation rejections;
- four exact canonical publication files;
- thirty-eight passed canonical qualification checks;
- five synchronized M32 documentation records;
- preserved historical repository records.

The linked `fpga/m32/` closure additionally records the complete FPGA top,
reset and readiness contract, exact input manifests, complete integration
synthesis, deterministic simulation exports, and the qualified output
comparisons against the standalone M32 RTL reference. Its final workflow
records are `FRP M32 FPGA Integration Qualification #2` and
`FRP M32 FPGA Post-Synthesis Qualification #1`. Their respective statuses
remain `M32 FPGA INTEGRATION BOUNDARY CLOSED` and
`M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED`.

Final registered-target workflow:

    FRP M32 Registered Target Core #6

Final full integrated-core synthesis workflow:

    FRP M32 Full Integrated Core Synthesis #1

Final trace-export workflow:

    FRP M32 Deterministic RTL Trace Export #2

Final technical closure status:

    M32 REGISTERED-TARGET, FULL INTEGRATED-CORE SYNTHESIS, AND DETERMINISTIC RTL TRACE BOUNDARY CLOSED

No GitHub Release, release tag, release date, or Zenodo deposit is created or
modified by this technical closure record.

## Closure references

| Record | Path |
|---|---|
| M32 architecture and boundary | [`README.md`](README.md) |
| exact artifact index | [`ARTIFACTS.md`](ARTIFACTS.md) |
| reproducible execution procedure | [`SIMULATION.md`](SIMULATION.md) |
| successful qualification transcript | [`SIMULATION_TRANSCRIPT.md`](SIMULATION_TRANSCRIPT.md) |
| FPGA integration and post-synthesis closure | [`../../fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) |
| FPGA integration qualification transcript | [`../../fpga/m32/SIMULATION_TRANSCRIPT.md`](../../fpga/m32/SIMULATION_TRANSCRIPT.md) |
| FPGA post-synthesis qualification transcript | [`../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md`](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) |
| complete FPGA integration top | [`../../fpga/m32/frp_m32_fpga_top.sv`](../../fpga/m32/frp_m32_fpga_top.sv) |
| FPGA integration testbench | [`../../fpga/m32/frp_m32_fpga_tb.sv`](../../fpga/m32/frp_m32_fpga_tb.sv) |
| FPGA post-synthesis testbench | [`../../fpga/m32/frp_m32_fpga_post_synthesis_tb.sv`](../../fpga/m32/frp_m32_fpga_post_synthesis_tb.sv) |
| FPGA integration qualification workflow | [`../../.github/workflows/frp-m32-fpga-integration-qualification.yml`](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) |
| FPGA post-synthesis qualification workflow | [`../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml`](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| registered-target workflow | [`../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) |
| full integrated-core synthesis workflow | [`../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) |
| deterministic trace-export workflow | [`../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) |
| bounded formal harness | [`../../formal/m32/frp_m32_registered_target_boundary_formal.sv`](../../formal/m32/frp_m32_registered_target_boundary_formal.sv) |
| trace exporter | [`../../frp_m32_deterministic_rtl_trace_export.py`](../../frp_m32_deterministic_rtl_trace_export.py) |
| independent exporter tests | [`../../tests/test_frp_m32_deterministic_rtl_trace_export.py`](../../tests/test_frp_m32_deterministic_rtl_trace_export.py) |
| trace schema | [`../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json`](../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json) |
| trace bundle | [`../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json`](../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json) |
| manifest | [`../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json`](../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json) |
| qualification | [`../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json`](../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json) |
| repository license | [`../../LICENSE`](../../LICENSE) |

## Author

**Maksym Marnov (Alchimist)**  
Berlin, Germany  
ORCID: `0009-0000-0832-9597`

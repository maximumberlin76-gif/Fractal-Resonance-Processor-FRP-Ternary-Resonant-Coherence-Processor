# FRP M32 Artifact Index

## Boundary identity

| Field | Value |
|---|---|
| Project | `Fractal Resonance Processor (FRP)` |
| Released upstream baseline | `FRP v3.3.0 / M31` |
| Implementation milestone | `M32` |
| RTL source boundary commit | `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| Top-level integration module | `frp_m32_core` |
| Canonical source identities | `29 / 29 exact` |
| Full synthesis source identities | `17 / 17 exact` |
| Full integrated-core synthesis profile | `8` cells, `2` request lanes |
| Full synthesis evidence schema | `frp.m32.full-integrated-core-synthesis.v1` |
| Full synthesis qualification run | [`#1 SUCCESS`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34351066791) |
| FPGA integration top | `frp_m32_fpga_top` |
| FPGA qualification source identities | `19 / 19 exact` |
| FPGA integration profile | `8` cells, `2` request lanes |
| FPGA qualification schema | `frp.m32.fpga-integration-qualification.v1` |
| FPGA qualification run | [`#2 SUCCESS`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| FPGA post-synthesis source identities | `19 / 19 exact` |
| FPGA post-synthesis profile | `8` cells, `2` request lanes |
| Generated simulation DUT | `frp_m32_fpga_netlist` |
| FPGA post-synthesis schema | `frp.m32.fpga-post-synthesis-qualification.v1` |
| FPGA post-synthesis qualification run | `#1 SUCCESS`, recorded duration `13m 36s` |
| FPGA post-synthesis evidence directory | `37` files, including the final report and checksum list |
| FPGA integration closure | `M32 FPGA INTEGRATION BOUNDARY CLOSED` |
| FPGA post-synthesis closure | `M32 FPGA POST-SYNTHESIS BOUNDARY CLOSED` |
| Canonical publication outputs | `4 / 4 exact` |
| Trace qualification checks | `38 / 38 PASS` |
| Canonical ternary notation | `-1/0/1` |
| License | Apache-2.0 |

This index records the implemented M32 registered-target RTL boundary, its
exact inherited M31 dependencies, formal harnesses, full integrated-core
synthesis, complete FPGA integration, post-synthesis netlist simulation,
deterministic trace exporter, qualification workflows, and canonical
publication outputs.

## Artifact classes

| Class | Count | Bytes | Identity authority |
|---|---:|---:|---|
| Inherited M31 RTL sources | `16` | `252826` | canonical M32 trace bundle source identities |
| M32 RTL sources and testbenches | `11` | `140680` | canonical M32 trace bundle source identities |
| M32 formal source | `1` | `7698` | canonical M32 trace bundle source identities |
| Registered-target qualification workflow | `1` | `41712` | canonical M32 trace bundle source identities |
| Complete canonical source boundary | `29` | `442916` | source commit `c0bc0fbc2c1c2e500b19d0ba84b3431a813e3941` |
| Full integrated-core synthesis source set | `17` | `242432` | exact workflow source-identity manifest; subset of the canonical source boundary |
| Full integrated-core synthesis workflow | `1` | `26799` | workflow SHA-256 and successful run `#1` |
| Deterministic full-core synthesis outputs | `6` | `32506080` | two byte-identical JSON, Verilog, and statistics replay pairs |
| FPGA top and integration testbench | `2` | `48527` | exact FPGA qualification source manifest |
| Complete FPGA qualification input set | `19` | `290959` | full-core source set plus FPGA top and testbench |
| FPGA integration qualification workflow | `1` | `30337` | workflow SHA-256 and successful run `#2` |
| FPGA top and post-synthesis testbench | `2` | `49796` | exact post-synthesis qualification source manifest |
| Complete FPGA post-synthesis input set | `19` | `292228` | full-core source set plus FPGA top and post-synthesis testbench |
| FPGA post-synthesis qualification workflow | `1` | `40054` | workflow SHA-256 and successful run `#1` |
| FPGA transcript and closure at documentation baseline | `2` | `23251` | documentation commit `4ac296d64823695b9f51dd97d9fdf6961c7d76b4` |
| Canonical publication outputs | `4` | `458096` | manifest, qualification, and exact export workflow comparison |

Source-set rows overlap: the `17` full-core synthesis inputs are included
in each `19`-file FPGA qualification manifest and in the `29` canonical
source identities. The two FPGA manifests share `18` exact non-testbench
inputs and select different testbenches. These rows describe qualification
scopes, not disjoint totals. The documentation-baseline row retains the
historical byte total; later documentation revisions are indexed below.

The full synthesis workflow, FPGA integration files, deterministic trace
exporter, independent exporter tests, export workflow, M32 documentation,
and preserved repair workflow were added after the fixed RTL source
boundary. Their identities are recorded separately and do not alter the
source commit embedded in the canonical bundle.

## M32 implementation inventory

| Artifact | Role | Qualification boundary |
|---|---|---|
| `rtl/m32/frp_m32_registered_target_boundary.sv` | clocked capture of valid phase-derived target banks, domain validation, and capture counters | lint, `8/16/32`-cell synthesis, bounded proofs, deterministic simulation |
| `rtl/m32/frp_m32_registered_target_boundary_tb.sv` | accepted, rejected, disabled-tick, counter-clear, reset, and retained-bank test sequence | deterministic simulation replay |
| `rtl/m32/frp_m32_registered_target_request_path.sv` | registered target gate and inherited request-adapter composition | lint and deterministic simulation replay |
| `rtl/m32/frp_m32_registered_target_request_path_tb.sv` | source/registered/request separation, scheduler eligibility, pending ownership, and invalid-source tests | deterministic simulation replay |
| `rtl/m32/frp_m32_core.sv` | integrated registered-target top-level over the M31 phase, execution, thermal, and stability contour | lint, deterministic simulation replay, and full synthesis at `8` cells with `2` request lanes |
| `rtl/m32/frp_m32_core_tb.sv` | integrated phase-source, registered-target, request, execution, route, frequency, thermal, stability, and invariant test sequence | deterministic simulation replay |
| `rtl/m32/frp_m32_mode_7_1_tb.sv` | dedicated `7/1` cadence and two-leg route sequence | deterministic simulation replay |
| `rtl/m32/frp_m32_mode_1_7_tb.sv` | dedicated `1/7` cadence and two-leg route sequence | deterministic simulation replay |
| `rtl/m32/frp_m32_trace_monitor.sv` | structured sample, bank, cell, and request records | lint and deterministic transcript generation |
| `rtl/m32/frp_m32_mode_7_1_trace_tb.sv` | mode `7/1` testbench plus trace-monitor composition | `2/2` byte-identical full-trace executions |
| `rtl/m32/frp_m32_mode_1_7_trace_tb.sv` | mode `1/7` testbench plus trace-monitor composition | `2/2` byte-identical full-trace executions |
| `formal/m32/frp_m32_registered_target_boundary_formal.sv` | safety and capture-sequence bounded formal harnesses | `10` safety and `4` sequence assertions at depth `4`, each with `2/2` deterministic replays |
| `fpga/m32/frp_m32_fpga_top.sv` | complete M32 core interface, asynchronous reset assertion, two-stage release, and operation gating | top lint and full integration synthesis at `8` cells with `2` request lanes |
| `fpga/m32/frp_m32_fpga_tb.sv` | startup, reset interruption, registered capture, active-state-`0` routes, pause, counter clear, and `free`, `7/1`, `1/7` scenarios | `59` core outputs compared across `1019` samples per replay; two deterministic simulation executions |
| `fpga/m32/frp_m32_fpga_post_synthesis_tb.sv` | generated FPGA netlist compared against a separate M32 RTL core, with independent reset-release and readiness expectations | all `59` forwarded core outputs across `1019` samples per replay; two deterministic post-synthesis simulation executions |

## Exact source identity boundary

These `29` records are reproduced from the canonical bundle and verified
against the current repository files.

### Inherited M31 RTL sources

| Path | Bytes | SHA-256 |
|---|---:|---|
| `rtl/m31/frp_m31_pkg.sv` | `18531` | `762302f1c7a7f7f40cb029f5ada6a111fc8c3e3f6be9920e9b2401b95e179c94` |
| `rtl/m31/frp_m31_fixed_point_pkg.sv` | `7278` | `6b2afb8d1583c93d95d2386ba25dd1eaef6bb5bd9a4e1c9e9abff1dd004cbf24` |
| `rtl/m31/frp_m31_scheduler.sv` | `10560` | `fc9de24b41736e5c5a9f9e464318c80adbfda9dc8cc4362c0c55bfed403bf97f` |
| `rtl/m31/frp_m31_request_lanes.sv` | `18290` | `32f75cc70df5dba3f4fbb511397be9a5921236c2afd16cfeb1350eca3f6e8109` |
| `rtl/m31/frp_m31_pending_routes.sv` | `17005` | `18889d85e78b23b844f1db4c46a35a6b7d01e609e3f1f0e6263a39a6c5729411` |
| `rtl/m31/frp_m31_active_neutral.sv` | `25909` | `765429b33df3f843626bdc411ad8371fd963738a58ab10201abef75dcdafcaf0` |
| `rtl/m31/frp_m31_capacity_guard.sv` | `20787` | `d0587897f955ce49923aca807b5d3e0c637383c88e5d5e0dfa8405f47917c123` |
| `rtl/m31/frp_m31_state_update.sv` | `18147` | `ebad1f7ee952a577239445d33d99cae799afaaff5c181c7162514bbcea6eab90` |
| `rtl/m31/frp_m31_execution_core.sv` | `33724` | `e516a5cd378bd2ddecdadc5abb13ddef26c63fafe5bda65b47a6bd859ca66f92` |
| `rtl/m31/frp_m31_phase_interference.sv` | `11245` | `e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0` |
| `rtl/m31/frp_m31_phase_request_adapter.sv` | `2251` | `fa78bcfe965270cc74855908aa392989d857575a2097a126539aabb1aab8990d` |
| `rtl/m31/frp_m31_thermal_proxy.sv` | `1883` | `34df4ebfc5dfad8e3e5e454e560404585de5c881e6f75abaae367d3bd9fb11bd` |
| `rtl/m31/frp_m31_stability.sv` | `2203` | `69c06833e6dfbb28e25b74a5787dcd03756dddf0f66726de3ea47c1ad2931931` |
| `rtl/m31/frp_m31_assertions.sv` | `24366` | `16a6abea57d2161a58ad5660c62f86cf057e65dbb1d9ae76e355e912a378077b` |
| `rtl/m31/frp_m31_phase_thermal_assertions.sv` | `3783` | `fe7b06073e65fc64acf7232038911230db27fe3a5ce000d0e1d421e2f49b1b3b` |
| `rtl/m31/frp_m31_sin_q30.mem` | `36864` | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| **Subtotal** | **`252826`** | **`16` inherited identities** |

### M32 RTL and formal sources

| Path | Bytes | SHA-256 |
|---|---:|---|
| `rtl/m32/frp_m32_registered_target_boundary.sv` | `3947` | `9626474b49d32b411e107d7ccc8ee5aa7f42728e9a6f70d634d16d3f2a414c5e` |
| `rtl/m32/frp_m32_registered_target_boundary_tb.sv` | `6748` | `0824e781f276f325aa86bb9a6a136f1d4da910920b64d15fafe5d7d017e5288a` |
| `rtl/m32/frp_m32_registered_target_request_path.sv` | `3244` | `02250069a68737f055a419cd67bf2d439b3f63b3f6a7a245f40e9bf29d1958eb` |
| `rtl/m32/frp_m32_registered_target_request_path_tb.sv` | `12135` | `a615d9b3bd456f60b37715433862830a4f3f8170859a2b12415d4b4b071faea5` |
| `rtl/m32/frp_m32_core.sv` | `10564` | `925342326b7ad555a1382e8ee3bc5754ed3012ba60e0eabf512113731e0ee6c9` |
| `rtl/m32/frp_m32_core_tb.sv` | `19348` | `4a2ac2778192199d02700c324da7d0cfba4a2f83730ea148497099e1a640d800` |
| `rtl/m32/frp_m32_mode_7_1_tb.sv` | `22207` | `7a6d610435bbd3f11441cb518bb64ab05b3748f5bb866092b1a734eab99c08f8` |
| `rtl/m32/frp_m32_mode_1_7_tb.sv` | `22388` | `3dcd66dbd8edc6989294298adb14d4e3b314e0af62512b5a1398b789cb510b97` |
| `rtl/m32/frp_m32_trace_monitor.sv` | `13827` | `556dd0759d91188b1947ae3abf61a0606cec238b67ff268f243eab370b01fc7c` |
| `rtl/m32/frp_m32_mode_7_1_trace_tb.sv` | `13136` | `4d02db27a3ae080c7c2a029e27d1b2c66bdbd2ad35c64ad3e020792c0bb841ca` |
| `rtl/m32/frp_m32_mode_1_7_trace_tb.sv` | `13136` | `bfb4b58f95f09e2fcbb81df3fae1c452a2e83111da7a9076dfaaefd2d76ab6cb` |
| `formal/m32/frp_m32_registered_target_boundary_formal.sv` | `7698` | `b4880df9c8ca6a3f220a26d4937c14b63e3b97277cdff16ce50de725c7f840d2` |
| **Subtotal** | **`148378`** | **`12` M32 RTL and formal identities** |

### Source qualification workflow

| Path | Bytes | SHA-256 |
|---|---:|---|
| `.github/workflows/frp-m32-registered-target-boundary-workflow.yml` | `41712` | `c0e3a9d134201d1d4d855f43d5740138155291d2074663207456841a08470afe` |
| **Complete source boundary** | **`442916`** | **`29` exact identities** |

## Full integrated-core synthesis source set

The full synthesis workflow independently checks the exact `17` files needed
to elaborate `frp_m32_core`. These records are a strict subset of the fixed
canonical source boundary above; no testbench, assertion-only source, or
workflow file is presented to the synthesis frontend.

| Path | Bytes | SHA-256 |
|---|---:|---|
| `rtl/m31/frp_m31_pkg.sv` | `18531` | `762302f1c7a7f7f40cb029f5ada6a111fc8c3e3f6be9920e9b2401b95e179c94` |
| `rtl/m31/frp_m31_fixed_point_pkg.sv` | `7278` | `6b2afb8d1583c93d95d2386ba25dd1eaef6bb5bd9a4e1c9e9abff1dd004cbf24` |
| `rtl/m31/frp_m31_scheduler.sv` | `10560` | `fc9de24b41736e5c5a9f9e464318c80adbfda9dc8cc4362c0c55bfed403bf97f` |
| `rtl/m31/frp_m31_request_lanes.sv` | `18290` | `32f75cc70df5dba3f4fbb511397be9a5921236c2afd16cfeb1350eca3f6e8109` |
| `rtl/m31/frp_m31_pending_routes.sv` | `17005` | `18889d85e78b23b844f1db4c46a35a6b7d01e609e3f1f0e6263a39a6c5729411` |
| `rtl/m31/frp_m31_active_neutral.sv` | `25909` | `765429b33df3f843626bdc411ad8371fd963738a58ab10201abef75dcdafcaf0` |
| `rtl/m31/frp_m31_capacity_guard.sv` | `20787` | `d0587897f955ce49923aca807b5d3e0c637383c88e5d5e0dfa8405f47917c123` |
| `rtl/m31/frp_m31_state_update.sv` | `18147` | `ebad1f7ee952a577239445d33d99cae799afaaff5c181c7162514bbcea6eab90` |
| `rtl/m31/frp_m31_execution_core.sv` | `33724` | `e516a5cd378bd2ddecdadc5abb13ddef26c63fafe5bda65b47a6bd859ca66f92` |
| `rtl/m31/frp_m31_phase_interference.sv` | `11245` | `e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0` |
| `rtl/m31/frp_m31_phase_request_adapter.sv` | `2251` | `fa78bcfe965270cc74855908aa392989d857575a2097a126539aabb1aab8990d` |
| `rtl/m31/frp_m31_thermal_proxy.sv` | `1883` | `34df4ebfc5dfad8e3e5e454e560404585de5c881e6f75abaae367d3bd9fb11bd` |
| `rtl/m31/frp_m31_stability.sv` | `2203` | `69c06833e6dfbb28e25b74a5787dcd03756dddf0f66726de3ea47c1ad2931931` |
| `rtl/m31/frp_m31_sin_q30.mem` | `36864` | `adbb4b94fcf8fa0bfc981d654679fd7518a5c4c9c97b611a35cd8accaf28233d` |
| `rtl/m32/frp_m32_registered_target_boundary.sv` | `3947` | `9626474b49d32b411e107d7ccc8ee5aa7f42728e9a6f70d634d16d3f2a414c5e` |
| `rtl/m32/frp_m32_registered_target_request_path.sv` | `3244` | `02250069a68737f055a419cd67bf2d439b3f63b3f6a7a245f40e9bf29d1958eb` |
| `rtl/m32/frp_m32_core.sv` | `10564` | `925342326b7ad555a1382e8ee3bc5754ed3012ba60e0eabf512113731e0ee6c9` |
| **Total** | **`242432`** | **`17 / 17` exact identities** |

The generated source-identity record has SHA-256
`762962e82a310c648ffa98f904fd654811801d9de38f22149a8de53c43f4e9e0`.

## Full integrated-core synthesis workflow identity

| Field | Recorded value |
|---|---|
| Workflow | `FRP M32 Full Integrated Core Synthesis` |
| Repository path | `.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml` |
| Workflow bytes | `26799` |
| Workflow SHA-256 | `1bd49d55d6f0842170b18547562cdf0122eea389015a7aae25d97725ba70c955` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Successful run | [`#1`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34351066791) |
| Run ID | `34351066791` |
| Job ID | `102464192260` |
| Qualified commit | `4bd5f97422b6b749c4db33d5658cf98b211f8850` |
| Run created | `2026-09-09T12:26:53Z` |
| Run updated | `2026-09-09T12:28:39Z` |
| Recorded duration | `1m 46s` |
| Status | `completed` |
| Conclusion | `success` |

The workflow uses Yosys `read_slang` with IEEE `1800-2017` input and the
`yosys-coarse-memory-preserving` synthesis flow. Two complete executions use
the same exact source set, parameters, frontend, synthesis boundary, and
output commands.

## Full integrated-core synthesis records

### Complete flattened netlist

| Property | Recorded value |
|---|---:|
| Evidence schema | `frp.m32.full-integrated-core-synthesis.v1` |
| Top module | `frp_m32_core` |
| Qualified profile | `8` cells, `2` request lanes |
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

The complete synthesized cell distribution is:

| Cell type | Count | Cell type | Count |
|---|---:|---|---:|
| `$adff` | `9` | `$adffe` | `26` |
| `$alu` | `1181` | `$and` | `13` |
| `$bmux` | `17` | `$bwmux` | `20` |
| `$demux` | `9` | `$eq` | `249` |
| `$logic_and` | `549` | `$logic_not` | `252` |
| `$logic_or` | `323` | `$macc_v2` | `580` |
| `$mem_v2` | `2` | `$mux` | `2353` |
| `$ne` | `36` | `$not` | `258` |
| `$or` | `212` | `$pmux` | `20` |
| `$reduce_and` | `424` | `$reduce_bool` | `8` |
| `$reduce_or` | `290` | `$shift` | `16` |
| `$shiftx` | `18` | `$xor` | `706` |

### Memory-preserving synthesis view

The committed phase-interference source remains unchanged. The workflow
copies the source tree into runner-temporary storage and removes exactly four
simulation-only post-load `$fatal` checks from the staged copy. The staged
view retains exactly one canonical `$readmemh` operation and the exact
`frp_m31_sin_q30.mem` file.

| Record | Canonical source | Temporary synthesis view |
|---|---:|---:|
| Phase source bytes | `11245` | `10853` |
| Phase source SHA-256 | `e8ceb80feb0b30db5e28d70bc4d68d51506da4d596b46a73c0137465d1455fe0` | `571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8` |
| `$readmemh` statements | `1` | `1` |
| Tracked source modified | no | not applicable |

The synthesized `u_phase_interference.sin_lut` cell remains a `$mem_v2`
memory with the following exact record:

| Property | Recorded value |
|---|---:|
| Width | `32` bits |
| Depth | `4096` words |
| Address width | `12` bits |
| Read ports | `72` |
| Write ports | `0` |
| Initialization | `131072` bits |
| Canonical big-endian word-stream SHA-256 | `74d1dcc6b7a1e55409c24fcf05b08f14b28ea4614d11d9eddcfe2dcbc7014816` |
| Synthesized initialization matches canonical memory | `true` |

### Deterministic synthesis output identities

| Artifact member | Replay | Bytes | SHA-256 |
|---|---:|---:|---|
| `m32-full-core-run-1.json` | `1` | `13768027` | `8a3efadabc04e042f59345f40703a14da3d480f9d7870b7ed0fcf44ed12026c8` |
| `m32-full-core-run-2.json` | `2` | `13768027` | `8a3efadabc04e042f59345f40703a14da3d480f9d7870b7ed0fcf44ed12026c8` |
| `m32-full-core-run-1.v` | `1` | `2482578` | `12ed610244c495fcad3c6b9c6f2dce1101f4a2ce610e66b84a7d4656fbee5ce4` |
| `m32-full-core-run-2.v` | `2` | `2482578` | `12ed610244c495fcad3c6b9c6f2dce1101f4a2ce610e66b84a7d4656fbee5ce4` |
| `m32-full-core-stat-run-1.json` | `1` | `2435` | `a1fc59d17f1a7e4250e2a711a597563e127bb5a0ddfbc4ffd0de046e3caf169a` |
| `m32-full-core-stat-run-2.json` | `2` | `2435` | `a1fc59d17f1a7e4250e2a711a597563e127bb5a0ddfbc4ffd0de046e3caf169a` |
| **Total** | **`6`** | **`32506080`** | **`3` byte-identical replay pairs** |

### Uploaded synthesis artifact

| Field | Recorded value |
|---|---|
| Artifact ID | `10103769648` |
| Artifact name | `frp-m32-full-integrated-core-synthesis-4bd5f97422b6b749c4db33d5658cf98b211f8850` |
| Archive bytes | `4458199` |
| Archive digest | `sha256:ecfd84de6eb0a0f12e5c3b997cc3223be661ded3f53ecd5241948201b17b1e94` |
| Created | `2026-09-09T12:28:36Z` |
| Expires | `2026-10-09T12:28:35Z` |
| Retention | `30` days |

The uploaded artifact additionally contains both synthesis logs, the exact
source-identity record and manifest, synthesis-view patch, toolchain record,
`read_slang` frontend record, structured evidence record, and
synthesis-artifact digest manifest. It is separate from the four tracked
canonical deterministic trace outputs.

## FPGA integration source set

The FPGA qualification verifies the `17` full integrated-core synthesis
inputs listed above together with these two additional SystemVerilog files:

| Path | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32/frp_m32_fpga_top.sv` | `11355` | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32/frp_m32_fpga_tb.sv` | `37172` | `75a0b2e261fff6a8b955c758415c60f360d58c091b598e0af5d2e61ade6a6c18` |
| **Additional FPGA inputs** | **`48527`** | **`2` exact identities** |

The complete qualification manifest contains `19` inputs totaling `290959`
bytes: `13` inherited M31 SystemVerilog files, `3` M32 SystemVerilog files,
the FPGA top, the FPGA testbench, and the sine ROM initialization file.
The include-closure check starts from both FPGA source roots. Simulation
builds `frp_m32_fpga_tb`; synthesis elaborates `frp_m32_fpga_top`.

The workflow identity is recorded separately from the nineteen canonical
inputs. Source byte lengths and SHA-256 values are checked before execution
and rechecked before the final qualification result.

### FPGA qualification workflow identity

| Field | Recorded value |
|---|---|
| Workflow | `FRP M32 FPGA Integration Qualification` |
| Repository path | `.github/workflows/frp-m32-fpga-integration-qualification.yml` |
| Workflow bytes | `30337` |
| Workflow SHA-256 | `14fba7469ecc1b76e3547d11db7f34986f15272d983e3aea19b52dbafb8e9145` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Repository permission | `contents: read` |
| Successful run | [`#2`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| Run ID | `34531635873` |
| Run attempt | `1` |
| Job ID | `103053501919` |
| Qualified commit | `e40e90d8e32847aa783030aba7e1e5f7963ef312` |
| Run started | `2026-09-10T21:20:28Z` |
| Run updated | `2026-09-10T21:23:12Z` |
| Recorded duration | `2m 44s` |
| Status | `completed` |
| Conclusion | `success` |

The [workflow at the qualified commit](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/e40e90d8e32847aa783030aba7e1e5f7963ef312/.github/workflows/frp-m32-fpga-integration-qualification.yml)
defines the source checks, simulation comparisons, synthesis checks, and
uploaded evidence inventory.

### FPGA simulation and synthesis records

| Qualification record | Accepted result |
|---|---|
| Evidence schema | `frp.m32.fpga-integration-qualification.v1` |
| Simulation top | `frp_m32_fpga_tb` |
| Forwarded core outputs | all `59` compared against a separate `frp_m32_core` |
| Samples per simulation replay | `1019` |
| Readiness check | independent expected reset-release edge |
| Simulation replays | `2`, identical ordered semantic PASS records |
| Scheduler scenarios | `free`, `7/1`, and `1/7` |
| Opposite-polarity routes | `-1 -> 0 -> 1` and `1 -> 0 -> -1`, with active zero and retained pending routes |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017` |
| Synthesis flow | `synth -top frp_m32_fpga_top -run begin:fine` |
| Structural check | `check -assert` |
| Synthesis replays | `2`, identical JSON netlists, Verilog netlists, and statistics |
| Flattened modules | `1`, named `frp_m32_fpga_top` |
| Complete port contract | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| Remaining processes | `0` |
| Latch cells | `0` |
| Unresolved module instances | `0` |
| Memory cells | `2` cells of type `$mem_v2` |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear |
| Core readiness and core reset | driven by the second reset-release stage |
| Sine ROM | `u_m32_core.u_phase_interference.sin_lut`, `4096 x 32`, `12` address bits, `72` read ports, `0` write ports |
| Sine ROM initialization | exact match to all `4096` canonical words |
| Statistics consistency | cell count and cell-type inventory match the JSON netlist |
| Repository integrity | source identities, workflow identity, checked-out commit, and clean working tree verified |

The temporary synthesis view retains the canonical `$readmemh` operation
and applies the same four-check phase-source transformation recorded in
the full-core synthesis section. The FPGA workflow saves its transformation
as `synthesis-view.patch`.

The FPGA cell count and complete cell-type inventory are recorded in
`qualification.json`, `stat-run-1.json`, and `stat-run-2.json`. The full
simulator output is retained in the two `.log` files; the two `.txt` files
contain the exact semantic terminal records used for replay comparison.

### Uploaded FPGA qualification artifact

The [GitHub artifact metadata](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873/artifacts)
records the archive associated with the successful FPGA qualification run:

| Field | Recorded value |
|---|---|
| Artifact ID | `10173809390` |
| Artifact name | `frp-m32-fpga-qualification-e40e90d8e32847aa783030aba7e1e5f7963ef312-1` |
| Archive bytes reported by GitHub | `4482172` |
| Archive SHA-256 reported by GitHub | `fc74edd654a80c77d9779b4b49ff5f47f5e153a5d6367f6c5d5db492092024c2` |
| Configured retention | `30` days |

The workflow writes these `24` evidence files to the uploaded directory:

| Artifact members | Recorded content |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | canonical input identities and workflow identity record |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, installed Python packages, and frontend help |
| `top-lint.log`, `testbench-build.log` | top lint and integration testbench build |
| `simulation-run-1.log`, `simulation-run-2.log` | complete simulation output |
| `simulation-run-1.txt`, `simulation-run-2.txt` | compared semantic terminal records |
| `synthesis-view.patch` | verified temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys` | executed synthesis commands |
| `synthesis-run-1.log`, `synthesis-run-2.log` | complete synthesis output |
| `netlist-run-1.json`, `netlist-run-2.json` | flattened JSON netlists |
| `netlist-run-1.v`, `netlist-run-2.v` | emitted Verilog netlists |
| `stat-run-1.json`, `stat-run-2.json` | synthesis statistics and cell-type inventories |
| `qualification.json` | source and run identities, simulation, synthesis, reset, ROM, integrity, and final qualification result |
| `artifacts.sha256` | SHA-256 values for the other evidence files |

The committed FPGA [transcript](../../fpga/m32/SIMULATION_TRANSCRIPT.md)
and [closure](../../fpga/m32/CLOSURE.md) record the accepted qualification
boundary and the result `FRP M32 FPGA integration qualification: PASS`.

## FPGA post-synthesis source set

Post-synthesis qualification uses the same `17` full integrated-core
synthesis inputs and the same FPGA top as integration qualification. It
selects the dedicated post-synthesis testbench:

| Path | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32/frp_m32_fpga_top.sv` | `11355` | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32/frp_m32_fpga_post_synthesis_tb.sv` | `38441` | `f619094e59932cc48d54a27a6650d8913ede84e754069f1b911ef3e692d953d8` |
| **Additional FPGA inputs** | **`49796`** | **`2` exact identities** |
| **Complete post-synthesis input set** | **`292228`** | **`19 / 19` exact identities** |

The `18` common non-testbench inputs total `253787` bytes. The integration
manifest adds the `37172`-byte integration testbench; the post-synthesis
manifest adds the `38441`-byte post-synthesis testbench. Each manifest
contains exactly `19` files and verifies its complete SystemVerilog
include closure together with the canonical sine ROM.

The post-synthesis testbench includes `frp_m32_core.sv` for the separate
RTL reference and instantiates `frp_m32_fpga_netlist` as the DUT. That
distinct module name requires the generated simulation netlist as a build
input. The source manifest records the testbench identity; the generated
netlists and Yosys support files have separate evidence identities.

### Post-synthesis qualification workflow identity

| Field | Recorded value |
|---|---|
| Workflow | `FRP M32 FPGA Post-Synthesis Qualification` |
| Repository path | `.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml` |
| Workflow bytes | `40054` |
| Workflow SHA-256 | `d240b6be6f2e1d30b5bd69b3a92b0b801d9895a1b37efcda39488c9d7b77bed5` |
| Job name | `Synthesize and simulate the complete M32 FPGA netlist` |
| Trigger | `workflow_dispatch` |
| Branch | `main` |
| Repository permission | `contents: read` |
| Successful workflow run | `#1` |
| Repository source baseline | `16a40d0687df20ea62dacdfb72e39ef6c22ec9c1` |
| Recorded duration | `13m 36s` |
| Conclusion | `success` |
| Evidence schema | `frp.m32.fpga-post-synthesis-qualification.v1` |

The successful manual execution is recorded in the
[post-synthesis workflow run list](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml).
The [workflow at the source baseline](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/blob/16a40d0687df20ea62dacdfb72e39ef6c22ec9c1/.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml)
defines the acceptance checks and evidence inventory below. The generated
`qualification.json` binds the execution to its exact `source_commit`,
`run_id`, and `run_attempt`.

### Post-synthesis qualification records

| Qualification check | Workflow acceptance contract |
|---|---|
| Canonical inputs | `19` exact byte lengths and SHA-256 values, with complete include closure |
| Qualified configuration | `CELLS=8`, `REQUEST_LANES=2` |
| Synthesis package | `yowasp-yosys==0.68.0.0.post1208` |
| SystemVerilog frontend | `read_slang`, IEEE `1800-2017` |
| Synthesis flow | `synth -top frp_m32_fpga_top -run begin:fine`, followed by `check -assert` |
| Synthesis replays | two byte-identical JSON netlists, Verilog netlists, and statistics records |
| Flattened synthesis top | one module named `frp_m32_fpga_top` |
| Complete port contract | `75` ports, `3136` bits, `15` inputs, `60` outputs |
| Integrated logic size check | at least `7000` synthesized cells |
| Remaining processes, latch cells, and unresolved instances | `0` |
| Retained memories | two `$mem_v2` cells |
| Reset synchronizer | two-bit `$adff`, rising-edge clock, active-low asynchronous clear to zero |
| Reset-release connectivity | constant `1` into stage one; stage one into stage two; stage two drives readiness and core reset consumers |
| Sine ROM | `4096 x 32`, `12` address bits, `72` read ports, `0` write ports |
| Sine ROM initialization | exact match to all `4096` canonical words |
| Statistics consistency | cell count and cell-type inventory match the JSON netlist |
| Source transformation | verified temporary phase-source view, canonical `$readmemh` retained |

The temporary phase source has `10853` bytes and SHA-256
`571a1df102318fc5b62d2b0977aa57625e7abd999db3487e62fe2d270f190bb8`.
Its four-check transformation is recorded in `synthesis-view.patch`.
The exact synthesized cell count and distribution are retained in
`structure.json`, both statistics files, and the final qualification report.

### Simulation export and comparison records

Each synthesis JSON is read into the same pinned Yosys package and
exported using the following transformation:

    techmap -map +/techmap.v t:$shiftx
    opt_clean
    check -assert
    select -assert-none t:$shiftx t:$connect
    rename frp_m32_fpga_top frp_m32_fpga_netlist

The standard Yosys `$shiftx` map produces explicit selection logic for
signed indices. Both original synthesis JSON files retain their byte
identities throughout simulation export.

| Export or simulation check | Workflow acceptance contract |
|---|---|
| Generated DUT | one flattened module named `frp_m32_fpga_netlist` |
| Exported port contract | names, directions, widths, and signedness preserved from synthesis |
| Exported memory contract | all `$mem_v2` parameters and initialization preserved |
| Remaining processes and latch cells | `0` |
| Remaining `$shiftx` and `$connect` cells | `0` |
| Observation wires | five reset-qualified control names and widths preserved |
| Simulation exports | two byte-identical JSON outputs and two byte-identical Verilog outputs |
| Cell models | `simlib.v` from the same pinned Yosys package |
| Simulation top | `frp_m32_fpga_post_synthesis_tb` |
| RTL reference | a separate complete `frp_m32_core` instance |
| Forwarded core outputs | all `59` compared at each of `1019` samples per replay |
| Readiness and reference reset | checked against independently supplied scenario expectations |
| Simulation replays | two identical ordered semantic terminal records |
| Rejected lint and build diagnostics | `PINMISSING`, `IMPLICIT`, `MULTIDRIVEN` |

The observed flattened wires are `u_m32_core.tick_enable`,
`u_m32_core.clear_counters`, `u_m32_core.phase_load_valid`,
`u_m32_core.auto_target_enable`, and
`u_m32_core.external_request_valid`. They are observed only; the reference
reset follows the test scenario.

The reference reads the canonical sine ROM file, while the synthesized
DUT uses the initialization embedded in its generated netlist. The
Verilator build uses `--timing --assert --binary`, `-DSIMLIB_NOCONNECT`,
and the recorded Yosys support files.

Each replay must produce these ordered semantic terminal records:

    PASS: startup pulses discarded; phase load without tick
    PASS: 1 -> 0 -> -1 and -1 -> 0 -> 1; pending retained during pause
    PASS: reset reassertion restarts both release stages
    PASS: free, 97 ticks, pause, isolated and concurrent clear
    PASS: 7/1, 84 balance + 12 commit, reset FREE tick, clear
    PASS: 1/7, 12 excite + 84 neutralize, reset FREE tick, clear
    PASS: 59 synthesized outputs match standalone M32 across 1019 samples
    FRP M32 FPGA post-synthesis testbench PASS

Both polarity routes retain active zero and the pending polarity during
three paused cycles, then complete on the next enabled tick without a
new request. Each scheduler scenario records `97` ticks and `97` accepted
target captures. For `7/1` and `1/7`, the initial reset `FREE` tick is
followed by twelve complete eight-tick periods.

The two `.txt` files contain the compared semantic records. Complete
simulator output is retained separately in the two `.log` files.

### Post-synthesis evidence inventory

| Artifact members | Recorded content |
|---|---|
| `source-manifest.json`, `canonical-sources.sha256` | canonical input identities, workflow identity, repository, and source commit |
| `toolchain.log`, `python-packages.txt`, `read-slang-help.log` | resolved tools, installed packages, and frontend help |
| `cell-models.json`, `yosys-simlib.v`, `yosys-techmap.v` | exact Yosys support files and their byte identities |
| `top-lint.log`, `post-synthesis-build.log` | complete lint and simulation build output |
| `synthesis-view.patch` | verified temporary phase-source transformation |
| `synthesis-run-1.ys`, `synthesis-run-2.ys` | synthesis commands |
| `synthesis-run-1.log`, `synthesis-run-2.log` | complete synthesis logs |
| `netlist-run-1.json`, `netlist-run-2.json` | original flattened synthesis JSON |
| `netlist-run-1.v`, `netlist-run-2.v` | original synthesis Verilog exports |
| `stat-run-1.json`, `stat-run-2.json`, `structure.json` | synthesis statistics, cell inventory, port, reset, and ROM checks |
| `simulation-netlist-1.ys`, `simulation-netlist-2.ys` | simulation export commands |
| `simulation-netlist-1.log`, `simulation-netlist-2.log` | complete simulation export logs |
| `simulation-netlist-1.json`, `simulation-netlist-2.json` | mapped simulation JSON |
| `simulation-netlist-1.v`, `simulation-netlist-2.v` | generated simulation DUT Verilog |
| `simulation-export.json` | export comparisons, preserved contracts, and input and output identities |
| `post-synthesis-run-1.log`, `post-synthesis-run-2.log` | complete simulator output |
| `post-synthesis-run-1.txt`, `post-synthesis-run-2.txt` | compared ordered semantic terminal records |
| `qualification.json` | final result and execution, source, synthesis, export, simulation, model, and integrity records |
| `artifacts.sha256` | SHA-256 values for the other evidence files |

The final report requires `35` nonempty evidence files and records the
byte length and SHA-256 value of each one. `artifacts.sha256` covers the
other `36` files, including `qualification.json`; the complete successful
evidence directory contains `37` files.

| Publication setting | Workflow value |
|---|---|
| Qualification schema | `frp.m32.fpga-post-synthesis-qualification.v1` |
| Artifact name expression | `frp-m32-fpga-post-synthesis-${{ github.sha }}-${{ github.run_attempt }}` |
| Artifact directory | `$RUNNER_TEMP/frp-m32-post-synthesis-evidence/` |
| Configured retention | `30` days |
| Upload and summary conditions | `always()` |

Before writing the final result, the workflow rechecks all canonical
source identities, its own identity, the checked-out commit, the clean
working tree, and the copied Yosys support-file identities. Diagnostic
upload and summary steps also execute after an earlier failure.

The [post-synthesis transcript](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md)
records the successful run and this workflow-defined evidence contract.
The [FPGA closure](../../fpga/m32/CLOSURE.md) records both integration and
post-synthesis closure scopes. The post-synthesis terminal result is:

    FRP M32 FPGA post-synthesis qualification: PASS

## CSR integration and post-synthesis artifacts

The CSR qualification covers the complete M32 FPGA integration through
`frp_m32_csr_top` at `8` cells, `2` request lanes and `32`-bit words and
counters. Its host interface contains `9` ports and `78` port bits.

| Artifact | Role |
|---|---|
| [frp_m32_csr_top.sv](../../fpga/m32_csr/frp_m32_csr_top.sv) | host transactions, command delivery, configuration staging and telemetry |
| [frp_m32_csr_tb.sv](../../fpga/m32_csr/frp_m32_csr_tb.sv) | deterministic RTL integration scenarios with independent host and core expectations |
| [frp_m32_csr_post_synthesis_tb.sv](../../fpga/m32_csr/frp_m32_csr_post_synthesis_tb.sv) | generated `frp_m32_csr_netlist` compared against a separate `frp_m32_core` RTL reference |

### Exact CSR qualification input sets

Both manifests include the same `17` inputs from the
[full integrated-core synthesis source set](#full-integrated-core-synthesis-source-set),
plus the M22 CSR package, FPGA top and CSR top. They select different
testbenches from the exact identities below.

| Path | Bytes | SHA-256 |
|---|---:|---|
| `rtl/m22/frp_m22_csr_pkg.sv` | `5586` | `0f3de8054e3704548088b035c43e993d194d5182a2ac1bc32cdad92663a11206` |
| `fpga/m32/frp_m32_fpga_top.sv` | `11355` | `4893b157fba0ce090766d73429bce154a8b06dbb4118ec4a6dcb7e4a4c4a3348` |
| `fpga/m32_csr/frp_m32_csr_top.sv` | `21826` | `c3d5e9060f8142acfb39310f2e47cca5a3f38c786a9bfdbb6686b2c86ff60344` |
| `fpga/m32_csr/frp_m32_csr_tb.sv` | `30914` | `af2795bf906c4c0c9aa2c2eac502bb3aa952fd5c179e2760c228a69bbc6a5a33` |
| `fpga/m32_csr/frp_m32_csr_post_synthesis_tb.sv` | `32248` | `788a90ed854871f71f05cd6fac5d2052a289781a011083ff6a58301a5f185281` |

| Qualification input set | Files | Bytes |
|---|---:|---:|
| Shared inputs, including the canonical sine ROM | `20` | `281199` |
| Complete CSR integration set, including its RTL testbench | `21` | `312113` |
| Complete CSR post-synthesis set, including its netlist testbench | `21` | `313447` |

The shared `20` inputs have identical byte lengths and SHA-256 values in
both manifests. Each complete set contains `20` SystemVerilog files and
one sine ROM file. These are overlapping qualification scopes; the
workflow file is recorded separately from each input set.

### CSR workflow identities and successful runs

| Path | Bytes | SHA-256 |
|---|---:|---|
| `.github/workflows/frp-m32-csr-integration-qualification.yml` | `27500` | `ec1aa8b7c0132c40f1b17718630e27fb51f139ad443e176b411491ebf7db966e` |
| `.github/workflows/frp-m32-csr-post-synthesis-qualification.yml` | `36875` | `f5f0be52c41de12130b84fa0f809783049b7d8b8b88df64bc1dbafa16b2f1dca` |

| Record | CSR integration | CSR post-synthesis |
|---|---|---|
| Workflow | [FRP M32 CSR Integration Qualification](../../.github/workflows/frp-m32-csr-integration-qualification.yml) | [FRP M32 CSR Post-Synthesis Qualification](../../.github/workflows/frp-m32-csr-post-synthesis-qualification.yml) |
| Qualified source commit | `8e619504c7826ba6351d4967d5944685963363f0` | `dcade95d59457dbd7bd296f7dc2d902f4fa61ddf` |
| Successful run | [#1 SUCCESS](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270) | [#1 SUCCESS](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701) |
| Run ID / attempt | `34689613270` / `1` | `34699370701` / `1` |
| Job ID | `103542454966` | `103568293849` |
| Trigger / branch | `workflow_dispatch` / `main` | `workflow_dispatch` / `main` |
| Recorded duration | `2m 36s` | `13m 47s` |
| Successful workflow-defined steps | `14` | `17` |
| Evidence schema | `frp.m32.csr-integration-qualification.v1` | `frp.m32.csr-post-synthesis-qualification.v1` |

Both workflows verify the complete include closure and exact source
identities, execute two synthesis replays, and compare both JSON
netlists, Verilog netlists and statistics byte for byte. Their synthesis
flow is `synth -top frp_m32_csr_top -noshare -run begin:fine` with
`yowasp-yosys==0.68.0.0.post1208` and the `read_slang` frontend.

The post-synthesis workflow additionally verifies two simulation exports:
the CSR port contract, both memory parameter sets and all `59` flattened
core-observation wire contracts are preserved. The generated DUT uses
embedded ROM initialization; its independent RTL reference reads the
canonical sine ROM file.

Each simulation qualification requires two byte-identical complete logs
and the following result per replay: `6905` aggregate checks, `306`
stimulus ticks, `449` rejected CSR transfers and `59` compared core outputs.
The required simulation terminal records are:

    FRP_M32_CSR_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59
    FRP_M32_CSR_POST_SYNTHESIS_TB: PASS checks=6905 ticks=306 rejected_transfers=449 core_outputs=59

Both qualifications exercise `free`, `7/1` and `1/7`. The retained kernel
is `-1/0/1`; state `0` is active. Both routes, `1 -> 0 -> -1` and
`-1 -> 0 -> 1`, retain their intermediate state and pending target between
separate enabled ticks. Direct opposite-polarity transitions are forbidden.

### Published CSR qualification artifacts

The archive identities below are recorded in the public
[integration artifact metadata](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34689613270/artifacts)
and [post-synthesis artifact metadata](https://api.github.com/repos/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34699370701/artifacts).

| Archive field | CSR integration | CSR post-synthesis |
|---|---|---|
| Artifact ID | `10297126685` | `10300161633` |
| Artifact name | `frp-m32-csr-qualification-8e619504c7826ba6351d4967d5944685963363f0-1` | `frp-m32-csr-post-synthesis-qualification-dcade95d59457dbd7bd296f7dc2d902f4fa61ddf-1` |
| Size reported by GitHub | `4605171` bytes | `9530965` bytes |
| SHA-256 digest reported by GitHub | `9b72c35d479060365a55dc033c5ddfa4489ad15860131db56d6319f18974ad81` | `b67e2349c124316e96ee1e55610081b7b5c6e63c77d2f7749dc669ca03cd8fa6` |
| Configured retention | `30` days | `30` days |
| Final report | `qualification.json` | `qualification.json` |
| Evidence checksums | `artifacts.sha256` | `artifacts.sha256` |

Each workflow writes `source-manifest.json`, `canonical-sources.sha256`,
tool records, lint and build logs, both simulation logs, the verified
synthesis source patch, both synthesis scripts, logs, netlists and
statistics. Its final report binds the result to `source_commit`,
`run_id` and `run_attempt` after the source and repository-integrity checks.

Post-synthesis evidence also includes `synthesis-structure.json`, both
simulation export scripts, logs and netlists, `simulation-export.json`,
`yosys-simlib.v`, `yosys-techmap.v` and `cell-models.json`. The final result
is written after the structural checks, verified export, both simulation
replays and repository-integrity checks succeed.

The complete inventories and acceptance records are preserved in the
[integration transcript](../../fpga/m32_csr/SIMULATION_TRANSCRIPT.md)
and [post-synthesis transcript](../../fpga/m32_csr/POST_SYNTHESIS_TRANSCRIPT.md).

### Committed CSR documentation identities

These identities apply at documentation commit
`4f1f97e70df93c164996fd5a31b6a5cc221d9a03`.

| Path | Bytes | SHA-256 |
|---|---:|---|
| `fpga/m32_csr/SIMULATION_TRANSCRIPT.md` | `14770` | `89d88c223b42fdbc91a614ad4aa7afeb9c7cc24353eb925972f3b910d47aa81f` |
| `fpga/m32_csr/POST_SYNTHESIS_TRANSCRIPT.md` | `17189` | `05da64b417d86fd216b19665ee3fcc0f6f540d6824c1f8221c9de44f9025bd8f` |
| `fpga/m32_csr/CLOSURE.md` | `22414` | `f08cc8514df4f242c1fe7d1014fbed21d13bebabbe69edd5cb93a74bb08a7bff` |

The transcripts were committed at `6567d6cfd45705931b89a88a782b0f0fb1112ffd`
and `4074fbfdac3621883b2b1a0ecad171510214def0`, respectively. The
[CSR closure](../../fpga/m32_csr/CLOSURE.md), updated at the documentation
commit above, records both accepted boundaries:

    M32 CSR INTEGRATION BOUNDARY CLOSED
    M32 CSR POST-SYNTHESIS BOUNDARY CLOSED

The qualification workflows require these final terminal results:

    FRP M32 CSR integration qualification: PASS
    FRP M32 CSR post-synthesis qualification: PASS

## Deterministic transcript identities

| Scheduler mode | Replay | Artifact member | Bytes | SHA-256 |
|---|---:|---|---:|---|
| `7/1` | `1` | `m32-mode-7-1-full-trace-run-1.log` | `105702` | `9517a02cd1ce2c687365f3712a453a9370e505ee4267e151fd05b266977ce915` |
| `7/1` | `2` | `m32-mode-7-1-full-trace-run-2.log` | `105702` | `9517a02cd1ce2c687365f3712a453a9370e505ee4267e151fd05b266977ce915` |
| `1/7` | `1` | `m32-mode-1-7-full-trace-run-1.log` | `112364` | `41de8e92c28f150f8d163fc1438b4d4381fa42d76a970f9246bbda4679491d89` |
| `1/7` | `2` | `m32-mode-1-7-full-trace-run-2.log` | `112364` | `41de8e92c28f150f8d163fc1438b4d4381fa42d76a970f9246bbda4679491d89` |

Each replay pair is byte-identical within its scheduler mode. The two modes
retain separate transcripts and identities.

## Canonical publication output identities

| Path | Bytes | Raw SHA-256 |
|---|---:|---|
| `schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json` | `34066` | `534db8227218184cac5d1cabb461dd63b1b61a99e0269c98535539ad3f7d7da2` |
| `artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json` | `412195` | `62d8c1e6d205b9262a5c950883d3259275d5049f7a896ae12956a210cb75b7e0` |
| `artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json` | `7211` | `da011dbc726d6d1fc0b7dbae12afe1e13d8240df64b9474fd0130c94ba005859` |
| `artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json` | `4624` | `26ec2d3eadd73b490eb023572101bb78cf5d11561ead91b78b1a30e690458273` |
| **Total** | **`458096`** | **`4` canonical outputs** |

Canonical payload digests embedded in the records are:

| Record | Digest scope | Embedded SHA-256 |
|---|---|---|
| Trace bundle | canonical JSON without `bundle_sha256` | `63b36c1fb29d28a33bb5387d7658c97fc0a51f6823f79dc71382132236685f9b` |
| Manifest | canonical JSON without `manifest_sha256` | `a9dd7d470fd094cb1dbb6fa360f6c28bf50d4aae4bf2f1ba34ad223655968c2e` |
| Qualification | canonical JSON without `qualification_sha256` | `a695ccb3c7f083e219ff6908dfc38e6f4e7ef37fca6da22f40c6303117027c5d` |

The qualification record contains `38` checks, `38` passed checks, and `0`
failed checks. It references the schema, bundle, and manifest. The
qualification file is the fourth generated output and is not included in its
own three-artifact antecedent list.

## Exporter and workflow identities

| Path | Role | Bytes | SHA-256 |
|---|---|---:|---|
| `frp_m32_deterministic_rtl_trace_export.py` | canonical parser, validator, generator, verifier, deterministic self-test, and mutation rejection | `64267` | `1a575482d0c62f977afc72f25c8d8eacb0daa35981f39cb64b7f85069e5c43cd` |
| `tests/test_frp_m32_deterministic_rtl_trace_export.py` | `49` independent exporter tests | `30889` | `e2b53c9973219b02c0fce2eda835bef87de0d8681ab61af89ef621fbafdfe774` |
| `.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml` | exact transcript replay, canonical generation, verification, mutation rejection, and published-output comparison | `20361` | `6636eb82c736db4452692105babda97ce94542e2deeb7dfaf2b3bb3d8aba960e` |

The export workflow verifies all four generated files against fixed byte
counts and raw SHA-256 values and compares each generated file byte-for-byte
with its tracked repository counterpart.

## Documentation identity

### Preserved documentation baseline

The following table preserves the documentation identities at commit
`4ac296d64823695b9f51dd97d9fdf6961c7d76b4`. These byte lengths and hashes
apply to that historical snapshot. Later documentation revisions are
indexed separately below.

| Path | Role | Bytes | SHA-256 |
|---|---|---:|---|
| `README.md` | repository entry point with M32 RTL, full synthesis, FPGA qualification, and evidence navigation | `15143` | `aa85826d00ec03eb3815c7affd9fcc49b5d5aceccfc33416f0baaee17b9bb34a` |
| `rtl/m32/README.md` | M32 registered-target, full synthesis, deterministic trace, publication, and provenance boundary | `16442` | `0adc5cdf3500fd140bba5f36d16ec12bab5e98e9d93da80881705e091d37072d` |
| `rtl/m32/SIMULATION.md` | reproducible registered-target, full-core synthesis, formal, simulation, trace-export, and verification procedure | `31343` | `fc16a800914d2440e6b0b68d368066bc167c56a50a0b60ac1c2a7c8b73aa8005` |
| `rtl/m32/SIMULATION_TRANSCRIPT.md` | recorded successful workflow runs, synthesis structure, ROM, output, formal, simulation, and trace evidence | `33301` | `2808384360e3910770f8e59f6133e481409720c593a02e6d833b7854fe66692a` |
| `rtl/m32/CLOSURE.md` | registered-target RTL, deterministic trace, formal, and full integrated-core synthesis closure | `32903` | `fe1b281bcc73671a29e374305e487e12a9f5d09cadda6fe379fbf2b7ba5d679b` |
| `fpga/m32/SIMULATION_TRANSCRIPT.md` | FPGA qualification run, source identities, simulation, complete synthesis, and artifact inventory | `13012` | `07bf5e93cd53ebaf9199e55133a526df6b0eea3aae176b5ddaa7a4242d2cde2e` |
| `fpga/m32/CLOSURE.md` | complete FPGA integration, reset, execution, synthesis, and evidence closure | `10239` | `5e62a25f2418b5dff311c6cbb3fe181f47f05904b2b3ce9f3d634cbef35d7079` |

### Post-synthesis documentation updates

| Path | Documentation commit | Recorded scope |
|---|---|---|
| [`fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md`](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) | [`20ac396`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/commit/20ac396) | successful post-synthesis run `#1`, exact source boundary, simulation export, ordered terminal records, and complete evidence inventory |
| [`fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) | [`07c0249`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/commit/07c0249) | integration and post-synthesis closure at `8` cells and `2` request lanes |
| [`README.md`](../../README.md) | [`88c7650`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/commit/88c7650) | repository entry point with FPGA post-synthesis qualification and evidence navigation |

These records identify the later documentation revisions by path and
commit. The inherited integration transcript remains available at
`fpga/m32/SIMULATION_TRANSCRIPT.md` with its recorded byte identity above.

`rtl/m32/ARTIFACTS.md` is excluded from its own identity tables to avoid a
self-referential digest.

## Preserved repair workflow

| Path | Historical role | Bytes | SHA-256 |
|---|---|---:|---|
| `.github/workflows/frp-m32-canonical-trace-bundle-repair.yml` | guarded restoration of the exact canonical bundle serialization after manual multipart insertion | `4850` | `961978c90e2b862df0c07866d0fae3a9f57c4be1d4b80e24311c555cb9a486a4` |

The repair workflow is preserved as workflow history. It is not a member of
the canonical RTL source identity set and does not replace the deterministic
export workflow.

## Composition boundary

`frp_m32_core.sv` includes:

- `frp_m31_execution_core.sv`;
- `frp_m31_phase_interference.sv`;
- `frp_m32_registered_target_request_path.sv`;
- `frp_m31_thermal_proxy.sv`;
- `frp_m31_stability.sv`.

`frp_m32_registered_target_request_path.sv` includes:

- `frp_m32_registered_target_boundary.sv`;
- `frp_m31_phase_request_adapter.sv`.

Each full-trace wrapper includes its dedicated scheduler-mode testbench and
`frp_m32_trace_monitor.sv`. The integrated source root uses include paths
`rtl/m31` and `rtl/m32` in the qualification workflows.

The registered-boundary synthesis evidence applies to
`frp_m32_registered_target_boundary` at `8`, `16`, and `32` cells. The
separate full integrated-core workflow qualifies `frp_m32_core` at `8` cells
and `2` request lanes. It produces one flattened module with `0` remaining
processes, validates the complete top-level port contract, and retains the
initialized `4096 x 32` phase-interference sine ROM. The integrated top also
remains covered by lint, deterministic simulation, assertion execution, and
trace generation in the other M32 workflows.

`fpga/m32/frp_m32_fpga_top.sv` includes and instantiates the complete
`frp_m32_core`. The FPGA testbench includes the FPGA top and instantiates a
separate core for output comparison. FPGA qualification uses include paths
`rtl/m31`, `rtl/m32`, and `fpga/m32`.

The wrapper forwards all core outputs and adds `core_ready`. Reset release
passes through two clocked stages; enabled core operation is first sampled
on the following rising edge. Operation gating, interrupted reset release,
active-zero routes, pending-route retention, and both `7/1` and `1/7`
cadences are covered by the FPGA qualification records.

`fpga/m32/frp_m32_fpga_post_synthesis_tb.sv` includes the standalone M32
core for its RTL reference. Its DUT is the separately generated
`frp_m32_fpga_netlist` module, built with the recorded Yosys cell models.
Post-synthesis qualification retains the original synthesis outputs,
checks the simulation export, and executes two complete comparison
replays at the same `8`-cell, `2`-request-lane profile.

## Processor-state identity

The retained processor domain is exactly:

    T = {-1, 0, 1}

State `0` is an active retained state used for mediation, balancing, routing,
damping, transition staging, retained-state participation, pending-route
handling, and controlled neutralization.

Opposite-polarity routes retain two separately observable legs:

    -1 -> 0 -> 1
    1 -> 0 -> -1

The canonical traces contain no direct opposite-polarity retained transition,
reserved-state event, or pending-route overflow event.

## Evidence links

| Record | Path |
|---|---|
| M32 boundary documentation | [`README.md`](README.md) |
| Reproducible simulation and synthesis procedure | [`SIMULATION.md`](SIMULATION.md) |
| Recorded qualification transcript | [`SIMULATION_TRANSCRIPT.md`](SIMULATION_TRANSCRIPT.md) |
| RTL closure | [`CLOSURE.md`](CLOSURE.md) |
| Registered-target workflow | [`../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml`](../../.github/workflows/frp-m32-registered-target-boundary-workflow.yml) |
| Full integrated-core synthesis workflow | [`../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml`](../../.github/workflows/frp-m32-full-integrated-core-synthesis-workflow.yml) |
| Successful full integrated-core synthesis run | [`#1`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34351066791) |
| FPGA integration top | [`../../fpga/m32/frp_m32_fpga_top.sv`](../../fpga/m32/frp_m32_fpga_top.sv) |
| FPGA integration testbench | [`../../fpga/m32/frp_m32_fpga_tb.sv`](../../fpga/m32/frp_m32_fpga_tb.sv) |
| FPGA qualification workflow | [`../../.github/workflows/frp-m32-fpga-integration-qualification.yml`](../../.github/workflows/frp-m32-fpga-integration-qualification.yml) |
| Successful FPGA qualification run | [`#2`](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/runs/34531635873) |
| FPGA qualification transcript | [`../../fpga/m32/SIMULATION_TRANSCRIPT.md`](../../fpga/m32/SIMULATION_TRANSCRIPT.md) |
| FPGA post-synthesis testbench | [`../../fpga/m32/frp_m32_fpga_post_synthesis_tb.sv`](../../fpga/m32/frp_m32_fpga_post_synthesis_tb.sv) |
| FPGA post-synthesis qualification workflow | [`../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml`](../../.github/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| FPGA post-synthesis workflow run list | [workflow runs](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m32-fpga-post-synthesis-qualification.yml) |
| FPGA post-synthesis qualification transcript | [`../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md`](../../fpga/m32/POST_SYNTHESIS_TRANSCRIPT.md) |
| FPGA integration and post-synthesis closure | [`../../fpga/m32/CLOSURE.md`](../../fpga/m32/CLOSURE.md) |
| Repository entry point | [`../../README.md`](../../README.md) |
| Deterministic export workflow | [`../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml`](../../.github/workflows/frp-m32-deterministic-rtl-trace-export-workflow.yml) |
| Trace exporter | [`../../frp_m32_deterministic_rtl_trace_export.py`](../../frp_m32_deterministic_rtl_trace_export.py) |
| Independent exporter tests | [`../../tests/test_frp_m32_deterministic_rtl_trace_export.py`](../../tests/test_frp_m32_deterministic_rtl_trace_export.py) |
| Trace schema | [`../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json`](../../schemas/m32/frp.m32.deterministic_rtl_trace_bundle.v1.schema.json) |
| Trace bundle | [`../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json`](../../artifacts/m32/exports/m32-deterministic-rtl-trace-bundle.json) |
| Manifest | [`../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json`](../../artifacts/m32/manifests/m32-deterministic-rtl-trace-manifest.json) |
| Qualification | [`../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json`](../../artifacts/m32/qualification/m32-deterministic-rtl-trace-qualification.json) |

## Provenance and preservation

The canonical trace bundle assigns the `upstream_frp_systemverilog_rtl`
provenance class to the exact M31/M32 source boundary. No downstream
Observatory implementation artifact is included in this identity set.

M32 is additive over M31. Earlier RTL, FPGA, evidence, benchmark, schema,
workflow, release, and deterministic identity records remain at their
established repository paths.

## Author

**Maksym Marnov (Alchimist)**  
Berlin, Germany  
ORCID: `0009-0000-0832-9597`

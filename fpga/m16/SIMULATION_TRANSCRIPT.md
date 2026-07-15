# FRP M16 FPGA Preparation Simulation Transcript

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Layer

`FPGA Preparation Layer`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Qualification Record

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

Trigger:

`workflow_dispatch`

Workflow run:

`#1`

Repository commit:

`326b69e`

Branch:

`main`

Final workflow status:

`SUCCESS`

Total workflow duration:

`1m 7s`

Qualification artifact count:

`1`

Final qualification result:

`PASS`

## Qualified FPGA Source Boundary

The qualified FPGA preparation source boundary contains:

| File | Function |
|---|---|
| `frp_m16_fpga_top.sv` | target-independent FPGA integration boundary for the qualified M16 RTL core |
| `frp_m16_fpga_tb.sv` | executable FPGA integration qualification testbench |

Qualified FPGA SystemVerilog artifacts:

`2`

Qualified M16 RTL dependencies:

`9`

FPGA artifact-boundary validation:

`PASS`

## Qualified RTL Dependency Boundary

The FPGA preparation layer inherits the following M16 RTL artifacts:

| File | Function |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | balanced ternary encoding, scheduler types, transition classes, invariant indexes, and shared functions |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal execution |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-route management |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `rtl/m16/frp_m16_state_update.sv` | retained balanced ternary state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL execution boundary |
| `rtl/m16/frp_m16_assertions.sv` | architectural and temporal assertion layer |

Qualified RTL dependency inventory:

`PASS`

## FPGA Synthesis Boundary

Synthesis top:

`frp_m16_fpga_top`

Source:

`fpga/m16/frp_m16_fpga_top.sv`

The synthesis boundary instantiates:

`frp_m16_core`

The FPGA top preserves:

- canonical balanced ternary encoding
- active neutral state `0`
- `free`, `7/1`, and `1/7` temporal execution
- deterministic request-lane arbitration
- retained pending-route polarity
- tick-separated opposite-polarity routing through `0`
- distributed transition-capacity enforcement
- retained-state writeback
- architectural telemetry
- integrated invariant outputs

FPGA synthesis-boundary elaboration:

`PASS`

## FPGA Simulation Boundary

Simulation top:

`frp_m16_fpga_tb`

Source:

`fpga/m16/frp_m16_fpga_tb.sv`

The testbench verifies:

- asynchronous external reset assertion
- two-stage synchronous reset release
- generation of `core_ready`
- tick blocking before `core_ready`
- counter-clear blocking before `core_ready`
- request blocking before `core_ready`
- scheduler-mode propagation
- request-interface propagation
- active-neutral opposite-polarity routing
- retained pending-route completion
- integrated architectural assertions
- all ten M16 invariant flags
- zero actual direct-transition events
- zero reserved-state events
- zero queue-overflow events

FPGA simulation boundary:

`PASS`

## Isolated Build Paths

FPGA build directory:

`/tmp/frp_m16_fpga_obj`

Top elaboration log:

`/tmp/frp_m16_fpga_top_lint.log`

Testbench build log:

`/tmp/frp_m16_fpga_build.log`

Execution log:

`/tmp/frp_m16_fpga_execution.log`

Toolchain record:

`/tmp/frp_m16_fpga_toolchain.log`

Source-hash record:

`/tmp/frp_m16_fpga_sources.sha256`

Qualification record:

`/tmp/frp_m16_fpga_qualification.txt`

Repository-local simulator build directories were not used.

## FPGA Top Elaboration Command

`verilator --sv --lint-only --top-module frp_m16_fpga_top -Irtl/m16 -Ifpga/m16 fpga/m16/frp_m16_fpga_top.sv`

Elaboration result:

`PASS`

## FPGA Testbench Build Command

`verilator --sv --timing --assert --binary --top-module frp_m16_fpga_tb -Irtl/m16 -Ifpga/m16 --Mdir /tmp/frp_m16_fpga_obj fpga/m16/frp_m16_fpga_tb.sv`

Generated executable:

`/tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb`

Build result:

`PASS`

## FPGA Testbench Execution Command

`/tmp/frp_m16_fpga_obj/Vfrp_m16_fpga_tb`

Execution result:

`PASS`

## Diagnostic Qualification

The workflow explicitly rejected:

- `%Warning-LATCH`
- `%Warning-MULTIDRIVEN`

| Diagnostic boundary | Result |
|---|---|
| inferred combinational latches | `NONE` |
| multidriven signals | `NONE` |
| FPGA top elaboration errors | `NONE` |
| FPGA testbench build errors | `NONE` |

Diagnostic qualification:

`PASS`

## Parameter Configuration

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `CELL_INDEX_BITS` | `3` |
| `COUNTER_BITS` | `32` |

Transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Qualified relation:

`8 cells → 2 request lanes`

Parameter qualification:

`PASS`

## Balanced Ternary Encoding

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The state `0` remains the active neutral processor state.

| Encoding relation | Result |
|---|---|
| retained state uses canonical balanced ternary encoding | `PASS` |
| pending route uses canonical balanced ternary encoding | `PASS` |
| active neutral state remains executable | `PASS` |
| reserved encoding is excluded | `PASS` |

## Reset Synchronization Record

External reset input:

`rst_n_async`

Internal core reset:

`rst_n_core`

Reset synchronizer stages:

`2`

Reset sequence:

1. `rst_n_async = 0` asynchronously clears both synchronization stages.
2. First rising clock edge after release sets synchronization stage `0`.
3. Second rising clock edge sets synchronization stage `1`.
4. `rst_n_core` and `core_ready` become active.
5. Qualified execution inputs are admitted to `frp_m16_core`.

Qualified reset relations:

| Reset relation | Result |
|---|---|
| asynchronous reset assertion | `PASS` |
| synchronization register cleared | `PASS` |
| first release edge remains blocked | `PASS` |
| second release edge activates `core_ready` | `PASS` |
| retained state remains `0` during reset | `PASS` |
| pending-route bank remains `0` during reset | `PASS` |
| scheduler counters remain `0` during reset | `PASS` |

Reset synchronization qualification:

`PASS`

## Core-Ready Input Gating

The FPGA top qualifies execution inputs as:

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

Before `core_ready`:

- no tick reaches the M16 core
- no counter-clear command reaches the M16 core
- no request-valid event reaches the M16 core
- no retained-state transition is executed
- no pending route is created
- no request is accepted

| Input-gating relation | Result |
|---|---|
| tick blocking before readiness | `PASS` |
| counter-clear blocking before readiness | `PASS` |
| request blocking before readiness | `PASS` |
| state preservation before readiness | `PASS` |
| pending-route preservation before readiness | `PASS` |

Core-ready input-gating qualification:

`PASS`

## Scheduler Propagation Record

Qualified scheduler modes:

- `FRP_MODE_FREE`
- `FRP_MODE_7_1`
- `FRP_MODE_1_7`

Qualified scheduler states observed through the FPGA boundary:

- `FRP_SCHED_FREE`
- `FRP_SCHED_BALANCE`
- `FRP_SCHED_EXCITE`
- `FRP_SCHED_NEUTRALIZE`

| Scheduler relation | Result |
|---|---|
| free mode propagation | `PASS` |
| 7/1 mode propagation | `PASS` |
| 1/7 mode propagation | `PASS` |
| scheduler mode registration preserves retained state | `PASS` |
| scheduler mode registration preserves pending routes | `PASS` |

Scheduler propagation qualification:

`PASS`

## Request Propagation Record

Qualified request:

`cell 0: 0 → +1`

The request crossed the FPGA boundary with:

| Signal | Qualified value |
|---|---:|
| `request_accept[0]` | `1` |
| `request_reject[0]` | `0` |
| `accepted_cell_mask[0]` | `1` |
| `accepted_change_mask[0]` | `1` |
| `accepted_changes` | `1` |
| `switch_load_numerator` | `1` |

Retained result:

`cell 0 = +1`

Pending-route result:

`cell 0 pending route = 0`

Request propagation qualification:

`PASS`

## Active-Neutral Routing Record

Requested opposite-polarity transition:

`+1 → -1`

Direct retained-state writeback is excluded.

First qualified tick:

`+1 → 0`

Retained pending target:

`pending_route = -1`

Following qualified tick:

`0 → -1`

Completed route:

`+1 → 0 → -1`

Qualified telemetry:

| Relation | Value |
|---|---:|
| `requested_direct_events` | `1` |
| `prevented_direct_events` | `1` |
| `neutral_routed_events` | `1` |
| `actual_direct_events` | `0` |

| Active-neutral relation | Result |
|---|---|
| opposite-polarity request detected | `PASS` |
| direct transition prevented | `PASS` |
| active neutral first leg executed | `PASS` |
| requested polarity retained | `PASS` |
| pending completion executed from `0` | `PASS` |
| pending route cleared after completion | `PASS` |
| direct retained-state transition absent | `PASS` |

Active-neutral routing qualification:

`PASS`

## Retained Pending-Route Completion

First route leg:

`+1 → 0`

Retained route:

`pending_route = -1`

Completion leg:

`0 → -1`

Completion capacity record:

| Signal | Value |
|---|---:|
| `accepted_change_mask[0]` | `1` |
| `accepted_changes` | `1` |
| `switch_load_numerator` | `1` |

Pending-route completion qualification:

`PASS`

## Integrated Invariant Record

The M16 core exposes ten integrated invariant flags.

Terminal invariant value:

`1111111111`

| Invariant | Result |
|---|---|
| `FRP_INV_STATE_DOMAIN_VALID` | `PASS` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` |
| `FRP_INV_PENDING_POLARITY_VALID` | `PASS` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID` | `PASS` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` |
| `FRP_INV_NO_RESERVED_STATE` | `PASS` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` |

Integrated invariant qualification:

`PASS`

## Terminal Output Validation

The workflow validated the following exact terminal markers:

`FRP M16 FPGA integration testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`core_ready=1`

`ticks_recorded=1`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

`invariant_flags=1111111111`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Terminal marker validation:

`PASS`

## Zero-Event Closure

| Event counter | Final value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Zero-event qualification:

`PASS`

## Repository Integrity

Source and build separation:

- source artifacts remained under `rtl/m16/` and `fpga/m16/`
- simulator output was generated under `/tmp`
- repository-local `obj_dir` directories were absent
- repository files remained unchanged during qualification

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## Qualification Evidence

Uploaded artifact:

`frp-m16-fpga-preparation-1`

The qualification artifact contains:

- Verilator and compiler toolchain record
- M16 RTL and FPGA SystemVerilog source hashes
- FPGA top elaboration log
- FPGA testbench build log
- FPGA testbench execution log
- final FPGA qualification record

Qualification evidence result:

`PASS`

## Final Qualification Table

| Qualification boundary | Result |
|---|---|
| FPGA artifact inventory | `PASS` |
| qualified RTL dependency inventory | `PASS` |
| FPGA top parsing | `PASS` |
| FPGA top elaboration | `PASS` |
| FPGA testbench build | `PASS` |
| FPGA testbench execution | `PASS` |
| latch diagnostic rejection | `PASS` |
| multidriven diagnostic rejection | `PASS` |
| asynchronous reset assertion | `PASS` |
| two-stage synchronous reset release | `PASS` |
| `core_ready` generation | `PASS` |
| execution-input gating | `PASS` |
| scheduler propagation | `PASS` |
| request propagation | `PASS` |
| active-neutral routing | `PASS` |
| retained pending-route completion | `PASS` |
| transition-capacity correlation | `PASS` |
| all ten invariant flags | `PASS` |
| zero actual direct events | `PASS` |
| zero reserved-state events | `PASS` |
| zero queue-overflow events | `PASS` |
| repository integrity | `PASS` |
| qualification evidence upload | `PASS` |

## Final Qualification Result

Workflow:

`FRP M16 FPGA Preparation #1`

Qualified commit:

`326b69e`

Branch:

`main`

Workflow status:

`SUCCESS`

FPGA preparation qualification:

`PASS`

## Author

Maksym Marnov

## Qualification Rerun Record

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Trigger | `workflow_dispatch` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

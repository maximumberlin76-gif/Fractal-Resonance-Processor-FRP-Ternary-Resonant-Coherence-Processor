# Fractal Resonance Processor (FRP) v1.8.0

## M16 RTL Core Realization and Execution Semantics Package

FRP v1.8.0 establishes the M16 RTL Core Realization and Execution Semantics Package of the Ternary Fractal Resonant Coherence Processor architecture.

M16 realizes the M15-qualified semantic and implementation-mapping boundary as:

`M15 floating semantic reference`

→ `M15 stateful quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 executable SystemVerilog RTL core`

→ `M16 target-independent FPGA integration boundary`

→ `M16 RTL and FPGA preparation qualification closure`

M15 remains the qualified semantic and implementation-mapping foundation of M16.

M16 is the current RTL execution and FPGA preparation layer.

## Main Executable Semantic Reference File

`frp_prototype_v1_7_0.py`

The executable semantic reference remains attached to the M15-qualified Python layer.

M16 does not introduce or rename the Python executable semantic reference.

## Release Role

FRP v1.8.0 contains:

- the M15-qualified executable semantic reference;

- the M15 deterministic implementation-mapping foundation;

- an integrated ten-file SystemVerilog RTL execution boundary;

- executable temporal scheduler semantics;

- deterministic request-lane arbitration;

- retained pending-route execution;

- active-neutral opposite-polarity routing;

- distributed transition-capacity enforcement;

- retained balanced ternary state writeback;

- integrated architectural assertions;

- ten integrated invariant flags;

- an executable architectural RTL testbench;

- a target-independent FPGA integration top;

- an executable FPGA integration testbench;

- asynchronous external reset assertion;

- two-stage synchronous reset release;

- `core_ready` execution gating;

- RTL and FPGA preparation qualification evidence.

Binary hardware can model nonlinear dynamics; FRP transfers selected nonlinear dynamic mechanisms into the organization of computation itself.

## Inherited M15 Qualification Foundation

Inherited release:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Inherited workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Inherited M15 qualification results:

| Qualification record | Result |
|---|---:|
| M15 self-test suite | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The inherited M15 execution chain is:

`M14 floating semantic reference`

→ `M15 deterministic fixed-point interface`

→ `stateful quantized hardware shadow`

→ `cycle-exact integer golden trace`

→ `deterministic RTL comparison vectors`

→ `SystemVerilog correlation contract`

→ `synthesizable RTL reference-core mapping`

→ `RTL assertion correlation`

→ `reference RTL equivalence`

→ `exact deterministic replay`

→ `M15 qualification closure`

## Mathematical Foundation

FRP mathematical foundation:

`docs/mathematical_foundation.md`

The document records the processor-specific mathematical relations for:

- balanced ternary retained state;

- active neutral transition routing;

- Kuramoto-Sakaguchi resonant phase dynamics;

- phase synchronization and phase coherence;

- endogenous structural coherence;

- operational quantities `C_FRP(t)`, `P_FRP(t)`, and `Delta_FRP(t)`;

- thermal-state feedback;

- hierarchical and multiscale processor organization.

## Physical Foundation

FRP physical foundation:

`docs/physical_foundation.md`

The document records the FRP physical implementation relations for:

- retained balanced ternary state;

- active neutral state execution;

- transition-capacity distribution;

- endogenous thermal-state feedback;

- hardware-facing fixed-point representation;

- RTL realization;

- target-independent FPGA preparation.

## Balanced Ternary Retained-State Domain

The retained processor-state domain is:

`{-1, 0, 1}`

| State | Computational role |
|---|---|
| `-1` | negative, inhibitory, counter-phase, or suppressive potential |
| `0` | active neutral balancing, damping, transition, and stabilization state |
| `1` | positive, excitatory, phase-supporting, or constructive potential |

The active neutral state is:

`0`

The active neutral state participates in:

- logical neutrality;

- phase damping;

- balancing;

- transition buffering;

- conflict neutralization;

- polarity bridging;

- switching-load distribution;

- temporal scheduling control;

- retained-state stabilization.

## Canonical Hardware Encoding

| Ternary state | Two-bit encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `1` | `2'b01` |
| reserved | `2'b10` |

The same canonical encoding is used for:

- retained processor state;

- phase-derived target state;

- request target state;

- transition candidates;

- pending-route polarity.

Qualified reserved-state record:

`reserved_state_events = 0`

## Active-Neutral Transition Semantics

Direct opposite-polarity retained-state transitions are forbidden:

`-1 → 1`

`1 → -1`

Opposite-polarity transitions follow:

`-1 → 0 → 1`

`1 → 0 → -1`

For:

`state_i × target_i = -1`

the first eligible neutralization tick performs:

`state_i → 0`

and retains:

`pending_route_i = target_i`

A later commit-capable tick performs:

`0 → pending_route_i`

Qualified direct-event record:

`actual_direct_events = 0`

## M16 RTL Artifact Boundary

RTL source directory:

`rtl/m16/`

The closed RTL boundary contains:

`10 SystemVerilog artifacts + 5 RTL documentation artifacts`

Integrated synthesis boundary:

`frp_m16_core`

Executable simulation boundary:

`frp_m16_tb`

## M16 SystemVerilog Artifact Inventory

| File | Function |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | canonical encodings, scheduler states, transition classes, invariant indexes, capacity parameters, and shared functions |
| `rtl/m16/frp_m16_scheduler.sv` | `free`, `7/1`, and `1/7` temporal scheduler execution and scheduler counters |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic ascending request-lane arbitration |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-polarity creation, ownership, deferral, completion, and clearing |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition-candidate generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | distributed transition-capacity admission |
| `rtl/m16/frp_m16_state_update.sv` | capacity-approved retained balanced ternary state writeback |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL execution and synthesis boundary |
| `rtl/m16/frp_m16_assertions.sv` | temporal, domain, routing, capacity, and writeback assertions |
| `rtl/m16/frp_m16_tb.sv` | deterministic executable architectural testbench |

## M16 RTL Documentation Inventory

| File | Function |
|---|---|
| `rtl/m16/README.md` | M16 RTL architecture and execution semantics |
| `rtl/m16/ARTIFACTS.md` | RTL source and documentation manifest |
| `rtl/m16/SIMULATION.md` | simulator build and execution commands |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | simulator execution and qualification transcript |
| `rtl/m16/CLOSURE.md` | M16 RTL closure record |

## M16 Temporal Scheduler

The M16 RTL core preserves three execution modes:

- `free`;

- `7/1`;

- `1/7`.

The scheduler state determines which transition classes execute on each enabled tick.

The scheduler counter relation is:

`sum(scheduler_counts) = ticks_recorded`

Counter clearing preserves retained ternary state, retained pending routes, scheduler mode, and scheduler tick position.

### Free Mode

Every enabled tick is:

`free`

The `free` scheduler state is commit-capable and neutralize-capable.

It executes:

- same-state retention;

- `0 → -1`;

- `0 → 1`;

- `-1 → 0`;

- `1 → 0`;

- the first leg of an opposite-polarity route;

- pending-route completion from active neutral state `0`.

### 7/1 Mode

The repeating scheduler sequence is:

`balance → balance → balance → balance → balance → balance → balance → commit`

The `balance` state is neutralize-capable.

The `commit` state is commit-capable.

Recorded scheduler relations:

`16 ticks → balance = 14, commit = 2`

`64 ticks → balance = 56, commit = 8`

An opposite-polarity route initiated during a balance tick remains retained until a commit-capable tick.

### 1/7 Mode

The repeating scheduler sequence is:

`excite → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize → neutralize`

The `excite` state is commit-capable.

The `neutralize` state is neutralize-capable.

Recorded scheduler relation:

`16 ticks → excite = 2, neutralize = 14`

An opposite-polarity route initiated during a neutralize tick remains retained until an excite tick.

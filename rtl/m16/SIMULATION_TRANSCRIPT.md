# FRP M16 RTL Simulation Transcript

## Status

Pending external simulator execution.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the transcript format for the M16 RTL simulation boundary of the:

`Ternary Fractal Resonant Coherence Processor`

The transcript records the deterministic simulator output for the integrated M16 RTL core, assertion layer, and smoke testbench.

M16 does not introduce a new processor model.

M16 verifies that the concrete RTL artifact set preserves the M15-qualified retained-state execution contract.

## Simulation Boundary

The transcript corresponds to the RTL simulation defined in:

`rtl/m16/SIMULATION.md`

Simulation target:

`rtl/m16/frp_m16_tb.sv`

Required command shape:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Run command:

    ./obj_dir/Vfrp_m16_tb

## RTL Artifact Set Under Test

The simulation transcript covers the following RTL artifact set:

| File | Role |
|---|---|
| `frp_m16_pkg.sv` | constants, encodings, helper functions |
| `frp_m16_scheduler.sv` | scheduler execution modes |
| `frp_m16_request_lanes.sv` | request-lane arbitration |
| `frp_m16_pending_routes.sv` | pending-route register layer |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement |
| `frp_m16_state_update.sv` | retained-state writeback |
| `frp_m16_core.sv` | integrated RTL core |
| `frp_m16_assertions.sv` | assertion binding layer |
| `frp_m16_tb.sv` | deterministic smoke testbench |

## Expected Console Completion Marker

A successful run must reach:

    FRP M16 deterministic RTL testbench completed.

The simulation must terminate through:

`$finish`

The simulation must not terminate through:

`$fatal`

## Required Final Counter Values

The following final counters must be zero:

| Counter | Required value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Required invariant:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Required Invariant Flags

The following invariant flags must be asserted:

| Flag | Required value |
|---|---|
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `1` |
| `FRP_INV_NO_RESERVED_STATE` | `1` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `1` |

The assertion layer also checks the complete invariant flag set exposed by the integrated core.

## Expected Smoke-Test Scope

The deterministic smoke simulation covers:

- reset-to-neutral retained-state initialization;
- pending-route reset to zero;
- free scheduler mode;
- `7/1` scheduler smoke profile;
- `1/7` scheduler smoke profile;
- neutral release `0 → +1`;
- neutralization `+1 → 0`;
- opposite-polarity request `+1 → -1`;
- active-neutral route `+1 → 0`;
- retained pending route to `-1`;
- pending-route completion `0 → -1`;
- invariant flag checks;
- final zero-event qualification counters.

## Transcript Capture Template

Paste the simulator output below after external execution.

### Command

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

### Run

    ./obj_dir/Vfrp_m16_tb

### Output

Pending external simulator execution.

## Expected PASS Summary

The expected PASS summary should contain:

    FRP M16 deterministic RTL testbench completed.
    CELLS=8 REQUEST_LANES=2
    actual_direct_events=0
    reserved_state_events=0
    queue_overflow_events=0

The exact `ticks_recorded` value is determined by the deterministic smoke sequence.

## Assertion Result

Current assertion result:

`pending external simulator execution`

Required final result:

`PASS`

No assertion failure is allowed.

## Simulation Result Table

| Check | Required result | Current result |
|---|---|---|
| RTL compilation | `PASS` | pending |
| RTL elaboration | `PASS` | pending |
| deterministic testbench run | `PASS` | pending |
| assertion layer | `PASS` | pending |
| reset-to-neutral state | `PASS` | pending |
| pending-route reset | `PASS` | pending |
| free-mode smoke | `PASS` | pending |
| `7/1` scheduler smoke | `PASS` | pending |
| `1/7` scheduler smoke | `PASS` | pending |
| active-neutral routing | `PASS` | pending |
| pending-route completion | `PASS` | pending |
| transition-capacity boundary | `PASS` | pending |
| `actual_direct_events = 0` | `PASS` | pending |
| `reserved_state_events = 0` | `PASS` | pending |
| `queue_overflow_events = 0` | `PASS` | pending |

## Failure Classification

If simulation fails, classify the failure by boundary.

| Failure category | Boundary |
|---|---|
| `compile_failure` | simulator parse or compile failure |
| `elaboration_failure` | module parameter or connection failure |
| `scheduler_failure` | scheduler state or counter failure |
| `state_domain_failure` | reserved ternary state emitted |
| `request_lane_failure` | request accept/reject mismatch |
| `pending_route_failure` | pending route creation, retention, or completion failure |
| `active_neutral_failure` | direct opposite-polarity transition detected |
| `capacity_failure` | accepted changes exceed `REQUEST_LANES` |
| `state_update_failure` | retained-state writeback failure |
| `assertion_failure` | assertion layer failure |
| `counter_failure` | final zero-event counters fail |
| `transcript_failure` | simulator output does not reach completion marker |

Unclassified simulation failure is not allowed.

## M15 Compatibility Position

This transcript is the first concrete RTL simulation evidence layer for M16.

The full compatibility chain remains:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 simulation transcript`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

## Current Status

Current transcript status:

`pending external simulator execution`

This file defines the expected transcript structure before simulator execution.

It does not claim completed simulation until external simulator output is captured.

## Next Step

The next file should define the M16 RTL closure report structure:

`rtl/m16/CLOSURE.md`

## Author

Maksym Marnov

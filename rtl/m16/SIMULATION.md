# FRP M16 RTL Simulation Instructions

## Status

Initial simulation instruction layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the initial simulator execution instructions for the M16 RTL core realization layer of the:

`Ternary Fractal Resonant Coherence Processor`

The simulation boundary validates that the concrete RTL artifact set preserves the M15-qualified retained-state execution semantics.

M16 does not introduce a new processor model.

M16 realizes the M15-qualified execution contract in RTL form and prepares the next step toward deterministic simulation transcript capture.

## Simulation Boundary

The current simulation boundary covers:

- package loading;
- integrated RTL core elaboration;
- assertion binding layer;
- deterministic smoke testbench;
- reset-to-neutral behavior;
- scheduler smoke profiles;
- active-neutral routing;
- pending-route creation;
- pending-route completion;
- transition-capacity boundary;
- invariant-flag checks;
- zero-event qualification counters.

Required final simulation invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## RTL Artifact Set

The simulation boundary uses the following files:

| File | Role |
|---|---|
| `frp_m16_pkg.sv` | constants, encodings, helper functions |
| `frp_m16_scheduler.sv` | scheduler execution modes |
| `frp_m16_request_lanes.sv` | request-lane arbitration |
| `frp_m16_pending_routes.sv` | pending-route registers |
| `frp_m16_active_neutral.sv` | active-neutral transition generation |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement |
| `frp_m16_state_update.sv` | retained-state writeback |
| `frp_m16_core.sv` | integrated RTL core |
| `frp_m16_assertions.sv` | assertion binding layer |
| `frp_m16_tb.sv` | deterministic smoke testbench |

## Recommended Working Directory

Run simulation commands from the repository root.

Expected RTL directory:

`rtl/m16`

## Include Path

The simulator must include:

`rtl/m16`

The SystemVerilog files use local include directives for the M16 RTL layer.

## Verilator Command Shape

Reference command shape:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Expected generated binary location:

    obj_dir/Vfrp_m16_tb

Run command:

    ./obj_dir/Vfrp_m16_tb

## Alternative File-List Shape

A simulator may also be driven by an explicit file-list boundary.

Recommended order:

    rtl/m16/frp_m16_pkg.sv
    rtl/m16/frp_m16_scheduler.sv
    rtl/m16/frp_m16_request_lanes.sv
    rtl/m16/frp_m16_pending_routes.sv
    rtl/m16/frp_m16_active_neutral.sv
    rtl/m16/frp_m16_capacity_guard.sv
    rtl/m16/frp_m16_state_update.sv
    rtl/m16/frp_m16_core.sv
    rtl/m16/frp_m16_assertions.sv
    rtl/m16/frp_m16_tb.sv

The package must be visible before all dependent modules.

## Expected Testbench Scope

The deterministic smoke testbench exercises:

- reset-to-neutral retained-state initialization;
- reset-to-zero pending-route initialization;
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

## Expected Console Markers

A successful deterministic smoke simulation should emit:

    FRP M16 deterministic RTL testbench completed.

The final report should include:

    CELLS=8 REQUEST_LANES=2
    actual_direct_events=0
    reserved_state_events=0
    queue_overflow_events=0

The exact `ticks_recorded` value is determined by the current deterministic smoke sequence.

## Required PASS Conditions

A simulation pass requires:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`invariant_flags[FRP_INV_NO_ACTUAL_DIRECT_EVENTS] = 1`

`invariant_flags[FRP_INV_NO_RESERVED_STATE] = 1`

`invariant_flags[FRP_INV_NO_QUEUE_OVERFLOW] = 1`

The assertion layer must not emit a fatal assertion failure.

The testbench must reach:

`$finish`

## Assertion Boundary

The assertion layer checks:

- valid retained-state ternary domain;
- valid pending-route ternary domain;
- valid scheduler mode;
- valid scheduler state;
- scheduler counter sum;
- request accept/reject separation;
- accepted cell count within `REQUEST_LANES`;
- accepted change count within `REQUEST_LANES`;
- capacity remaining relation;
- capacity exhaustion relation;
- switch-load numerator relation;
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events;
- invariant-flag validity;
- tick-disabled hold behavior.

## Scheduler Simulation Targets

The simulation must preserve the scheduler identities:

| Mode | Required behavior |
|---|---|
| `free` | every enabled tick is free / commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

The smoke testbench currently exercises all three modes.

## Transition Simulation Targets

The simulation must preserve legal transition behavior:

| Transition | Status |
|---|---|
| `0 → +1` | legal |
| `0 → -1` | legal |
| `+1 → 0` | legal |
| `-1 → 0` | legal |
| `+1 → -1` | forbidden direct transition |
| `-1 → +1` | forbidden direct transition |

Required routed sequences:

`+1 → 0 → -1`

`-1 → 0 → +1`

## Capacity Simulation Targets

For the current smoke profile:

`CELLS = 8`

Required relation:

`REQUEST_LANES = 2`

Required invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load numerator:

`switch_load_numerator = accepted_changes`

## Pending-Route Simulation Targets

For an opposite-polarity request:

`+1 → -1`

Required M16 behavior:

`+1 → 0`

with:

`pending_route = -1`

Later eligible completion:

`0 → -1`

Required pending-route invariants:

`pending routes preserve requested target polarity`

`pending completion starts from 0`

`queue_overflow_events = 0`

## Failure Classification

Any simulation failure should be classified by boundary:

| Failure category | Boundary |
|---|---|
| `compile_failure` | simulator cannot parse or elaborate RTL |
| `scheduler_failure` | scheduler mode or counter mismatch |
| `state_domain_failure` | reserved ternary state emitted |
| `request_lane_failure` | request accept/reject mismatch |
| `pending_route_failure` | pending route creation or completion mismatch |
| `active_neutral_failure` | direct opposite-polarity transition detected |
| `capacity_failure` | accepted changes exceed `REQUEST_LANES` |
| `state_update_failure` | retained-state writeback mismatch |
| `assertion_failure` | assertion layer reports failure |
| `counter_failure` | final zero-event counters fail |

Unclassified simulation failure is not allowed.

## Current Simulation Status

Current repository status:

| Layer | Status |
|---|---|
| RTL files | implemented |
| integrated core | implemented |
| assertion layer | implemented |
| deterministic smoke testbench | implemented |
| simulation instructions | current file |
| external simulator transcript | pending |
| CI simulator workflow | pending |
| deterministic replay adapter | pending |
| M16 closure report | pending |

## M15 Compatibility Position

The simulation layer is a preliminary RTL smoke boundary.

The full M15 replay boundary remains:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 deterministic replay transcript`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

## External FPGA Review Position

After simulation transcript capture, the M16 RTL layer can be prepared for external FPGA review.

External review may evaluate:

- synthesis feasibility;
- LUT utilization;
- FF utilization;
- BRAM usage;
- DSP usage;
- timing closure;
- clock strategy;
- reset strategy;
- target FPGA class.

External review must not redefine FRP processor semantics.

## Next Step

The next file should define the simulation transcript placeholder and result format:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

## Author

Maksym Marnov

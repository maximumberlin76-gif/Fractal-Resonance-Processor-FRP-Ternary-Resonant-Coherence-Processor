# FRP M16 External Simulator Execution Plan

## Status

`PLANNED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the external simulator execution plan for the M16 RTL layer of the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL artifact boundary has passed repository-level qualification.

The next required M16 closure step is external simulator execution of the integrated RTL core, assertion layer, and deterministic smoke testbench.

This document does not claim completed simulation.

It defines the simulator execution boundary that must be run and captured in the simulation transcript.

## Current Artifact-Boundary Result

Current M16 RTL artifact-boundary result:

`PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Passing workflow run:

`FRP M16 RTL Artifact Boundary #8`

Passing commit:

`12a3431`

Current external simulator result:

`pending external simulator execution`

Current final M16 closure result:

`pending simulator transcript capture`

## Simulation Target

Primary simulation target:

`rtl/m16/frp_m16_tb.sv`

The testbench instantiates:

- `rtl/m16/frp_m16_core.sv`;
- `rtl/m16/frp_m16_assertions.sv`.

The integrated core connects:

- `frp_m16_scheduler`;
- `frp_m16_request_lanes`;
- `frp_m16_pending_routes`;
- `frp_m16_active_neutral`;
- `frp_m16_capacity_guard`;
- `frp_m16_state_update`.

## Required RTL Source Set

The external simulator must use the following RTL source artifacts:

| Path | Status |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | required |
| `rtl/m16/frp_m16_scheduler.sv` | required |
| `rtl/m16/frp_m16_request_lanes.sv` | required |
| `rtl/m16/frp_m16_pending_routes.sv` | required |
| `rtl/m16/frp_m16_active_neutral.sv` | required |
| `rtl/m16/frp_m16_capacity_guard.sv` | required |
| `rtl/m16/frp_m16_state_update.sv` | required |
| `rtl/m16/frp_m16_core.sv` | required |
| `rtl/m16/frp_m16_assertions.sv` | required |
| `rtl/m16/frp_m16_tb.sv` | required |

## Required Include Boundary

The simulator must include:

`rtl/m16`

The package and module include chain assumes the M16 RTL directory is available as an include path.

## Primary Verilator Command

Reference command:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Expected generated binary:

    obj_dir/Vfrp_m16_tb

Run command:

    ./obj_dir/Vfrp_m16_tb

## Required Completion Marker

The simulation must emit:

    FRP M16 deterministic RTL testbench completed.

The simulation must terminate through:

`$finish`

The simulation must not terminate through:

`$fatal`

## Required Final Counters

The following final counters must be zero:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

These counters preserve the M16 zero-event qualification boundary.

## Required Invariant Flags

The simulator run must preserve:

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS = 1`

`FRP_INV_NO_RESERVED_STATE = 1`

`FRP_INV_NO_QUEUE_OVERFLOW = 1`

The assertion layer also checks the complete invariant flag set exposed by the integrated core.

## Smoke-Test Execution Scope

The deterministic smoke testbench exercises:

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
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events.

## Scheduler Targets

The simulator run must preserve the M16 scheduler identities:

| Mode | Required behavior |
|---|---|
| `free` | every enabled tick is free / commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

## Transition Targets

Allowed direct retained-state transitions:

`0 → +1`

`0 → -1`

`+1 → 0`

`-1 → 0`

Forbidden direct retained-state transitions:

`+1 → -1`

`-1 → +1`

Required routed sequences:

`+1 → 0 → -1`

`-1 → 0 → +1`

Required direct-transition result:

`actual_direct_events = 0`

## Capacity Targets

For the current smoke testbench:

`CELLS = 8`

Required lane relation:

`REQUEST_LANES = 2`

Required transition-capacity invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load numerator relation:

`switch_load_numerator = accepted_changes`

## Pending-Route Targets

For the opposite-polarity request:

`+1 → -1`

Required execution:

`+1 → 0`

Required retained pending route:

`pending_route = -1`

Required later completion:

`0 → -1`

Required pending-route invariant:

`queue_overflow_events = 0`

## Assertion Targets

The external simulator must not report assertion failure.

Assertion coverage includes:

- retained-state domain validity;
- pending-route domain validity;
- scheduler mode validity;
- scheduler state validity;
- scheduler counter consistency;
- request accept/reject separation;
- transition-capacity boundary;
- capacity remaining relation;
- capacity exhaustion relation;
- switch-load numerator relation;
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events;
- invariant-flag validity;
- tick-disabled hold behavior.

## Transcript Capture Target

The simulator output must be copied into:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

The transcript must record:

- simulator command;
- run command;
- console output;
- completion marker;
- final counters;
- assertion result;
- PASS / FAIL table;
- failure classification if any failure occurs.

## Required Transcript Result

Required final transcript result:

`PASS`

Required transcript counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Required transcript marker:

`FRP M16 deterministic RTL testbench completed.`

## Failure Classification

Any external simulator failure must be mapped to one of the following boundaries:

| Failure category | Boundary |
|---|---|
| `compile_failure` | simulator parse or compile failure |
| `elaboration_failure` | module parameter or connection failure |
| `scheduler_failure` | scheduler state or counter mismatch |
| `state_domain_failure` | reserved ternary state emitted |
| `request_lane_failure` | request accept/reject mismatch |
| `pending_route_failure` | pending route creation, retention, or completion failure |
| `active_neutral_failure` | direct opposite-polarity transition detected |
| `capacity_failure` | accepted changes exceed `REQUEST_LANES` |
| `state_update_failure` | retained-state writeback failure |
| `assertion_failure` | assertion layer failure |
| `counter_failure` | final zero-event counters fail |
| `transcript_failure` | simulator output does not reach completion marker |

Unclassified simulator failure is not allowed.

## M15 Compatibility Position

The external simulator execution remains part of the M15-to-M16 compatibility chain:

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

## Current Execution State

Current state:

`artifact-boundary PASS`

Remaining required state:

`external simulator execution`

Current transcript state:

`pending external simulator execution`

Current final closure state:

`pending simulator transcript capture`

## Next Step

After external simulator execution, update:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

Then update:

`rtl/m16/CLOSURE.md`

Then create:

`docs/m16_final_qualification_closure.md`

## Author

Maksym Marnov

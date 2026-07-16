# FRP M16 External Simulator Execution Plan and Qualification Record

## Status

`M16 RTL EXECUTION LAYER CLOSED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document records the external simulator execution boundary and completed Verilator qualification for the M16 RTL layer of the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL artifact boundary is implemented under:

`rtl/m16/`

The qualified execution includes:

- SystemVerilog parsing;
- module elaboration;
- executable testbench generation;
- architectural simulation;
- assertion execution;
- scheduler validation;
- request-lane arbitration;
- active-neutral routing;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- integrated invariant validation;
- terminal counter validation;
- repository-integrity validation;
- qualification evidence generation.

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

## Qualification Result

Current external simulator result:

`PASS`

Current simulator transcript result:

`PASS`

Current M16 RTL qualification result:

`PASS`

Current M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current synchronized workflow record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 RTL Artifact Boundary` |
| Workflow file | `.github/workflows/frp-m16-rtl-artifact-boundary.yml` |
| Trigger | `workflow_dispatch` |
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Initial qualified workflow record:

| Field | Recorded value |
|---|---|
| Workflow run | `#82` |
| Qualified source commit | `a68a2af` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

## Simulation Target

Primary simulation target:

`rtl/m16/frp_m16_tb.sv`

Testbench top module:

`frp_m16_tb`

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

## Qualified RTL Source Set

The qualified simulator execution uses the following RTL source artifacts:

| Path | Qualified function | Status |
|---|---|---|
| `rtl/m16/frp_m16_pkg.sv` | shared package, canonical encodings, types, functions, and invariant indexes | present |
| `rtl/m16/frp_m16_scheduler.sv` | temporal scheduler execution | present |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic request-lane arbitration | present |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-route processing | present |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition generation | present |
| `rtl/m16/frp_m16_capacity_guard.sv` | transition-capacity admission | present |
| `rtl/m16/frp_m16_state_update.sv` | retained-state writeback | present |
| `rtl/m16/frp_m16_core.sv` | integrated M16 RTL core | present |
| `rtl/m16/frp_m16_assertions.sv` | architectural assertion layer | present |
| `rtl/m16/frp_m16_tb.sv` | executable deterministic testbench | present |

Qualified SystemVerilog artifact count:

`10`

RTL source inventory result:

`PASS`

Unexpected SystemVerilog artifacts:

`NONE`

Empty required SystemVerilog artifacts:

`NONE`

## Qualified Include Boundary

Qualified include path:

`rtl/m16`

The package and module include chain resolves through the M16 RTL directory.

Include-boundary result:

`PASS`

## Qualified Verilator Commands

Qualified build command:

    verilator \
      --sv \
      --timing \
      --assert \
      --binary \
      --top-module frp_m16_tb \
      -Irtl/m16 \
      --Mdir /tmp/frp_m16_obj \
      rtl/m16/frp_m16_tb.sv

Qualified generated binary:

    /tmp/frp_m16_obj/Vfrp_m16_tb

Qualified execution command:

    /tmp/frp_m16_obj/Vfrp_m16_tb

Verilator parsing result:

`PASS`

Module elaboration result:

`PASS`

Executable testbench generation result:

`PASS`

Architectural simulation result:

`PASS`

Assertion execution result:

`PASS`

## Qualified Completion Marker

The qualified simulation emitted:

`FRP M16 deterministic RTL testbench completed.`

Simulation termination:

`$finish`

Qualified-run `$fatal` termination:

`NONE`

Completion-marker result:

`PASS`

## Qualified Terminal Record

Qualified terminal configuration:

| Field | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| integrated invariant flags | `1111111111` |

Terminal counter result:

`PASS`

## Qualified Invariant Flags

The integrated M16 core exposes ten invariant flags:

| Index | Invariant flag | Result |
|---:|---|---|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` | `PASS` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` | `PASS` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` | `PASS` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` |
| `8` | `FRP_INV_NO_RESERVED_STATE` | `PASS` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` |

Invariant-vector width:

`FRP_M16_INVARIANT_FLAGS = 10`

Qualified invariant vector:

`1111111111`

Integrated invariant result:

`PASS`

## Qualified Testbench Execution Scope

The deterministic testbench validates:

- reset-to-neutral retained-state initialization;
- pending-route reset to zero;
- `free` scheduler execution;
- `7/1` scheduler execution;
- `1/7` scheduler execution;
- scheduler-state counters;
- scheduler-count sum relation;
- deterministic request-lane ordering;
- transition-capacity saturation;
- neutral release `0 → 1`;
- neutralization `1 → 0`;
- opposite-polarity request `1 → -1`;
- active-neutral first leg `1 → 0`;
- retained pending route to `-1`;
- pending-route completion `0 → -1`;
- retained-state writeback;
- assertion execution;
- integrated invariant flags;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- scheduler counter clearing;
- retained-state preservation across counter clearing;
- pending-route preservation across counter clearing.

Testbench execution-scope result:

`PASS`

## Scheduler Qualification Record

Qualified scheduler modes:

| Mode | Execution sequence |
|---|---|
| `free` | every enabled tick is free and commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Qualified scheduler profiles:

| Mode | Qualified tick count | Qualified scheduler-state counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Required scheduler relation:

`sum(scheduler_state_counts) = ticks_recorded`

Scheduler qualification result:

`PASS`

## Transition Qualification Record

Canonical retained-state domain:

`{-1, 0, 1}`

Allowed direct retained-state transitions:

`0 → 1`

`0 → -1`

`1 → 0`

`-1 → 0`

Forbidden direct retained-state transitions:

`1 → -1`

`-1 → 1`

Required routed sequences:

`1 → 0 → -1`

`-1 → 0 → 1`

Required direct-transition counter:

`actual_direct_events = 0`

Transition qualification result:

`PASS`

## Capacity Qualification Record

Qualified testbench configuration:

`CELLS = 8`

Qualified request-lane count:

`REQUEST_LANES = 2`

Required transition-capacity relation:

`accepted_changes <= REQUEST_LANES`

Required capacity-remaining relation:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required capacity-exhausted relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

Required switch-load numerator relation:

`switch_load_numerator = accepted_changes`

Transition-capacity qualification result:

`PASS`

## Pending-Route Qualification Record

For the opposite-polarity request:

`1 → -1`

the qualified first route leg is:

`1 → 0`

The exact requested polarity is retained as:

`pending_route = -1`

The qualified later completion is:

`0 → -1`

The pending-route boundary validates:

- one retained route slot per cell;
- exact requested-polarity retention;
- pending-route ownership of its cell;
- pending-route priority over new same-cell requests;
- retention across scheduler-ineligible ticks;
- retention across transition-capacity deferral;
- completion only from active neutral state `0`;
- clearing after accepted completion writeback.

Required queue-overflow counter:

`queue_overflow_events = 0`

Pending-route qualification result:

`PASS`

## Assertion Qualification Record

Assertion layer:

`rtl/m16/frp_m16_assertions.sv`

Assertion execution validates:

- retained-state domain validity;
- pending-route domain validity;
- scheduler mode validity;
- scheduler-state validity;
- scheduler-counter consistency;
- request acceptance and rejection separation;
- deterministic request-lane order;
- pending-route polarity retention;
- active-neutral route execution;
- transition-capacity enforcement;
- capacity-remaining relation;
- capacity-exhausted relation;
- switch-load numerator relation;
- retained-state writeback;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- all ten integrated invariant flags;
- tick-disabled hold behavior.

Assertion failures in the qualified run:

`0`

Assertion qualification result:

`PASS`

## Simulation Transcript Record

Simulation instructions:

`rtl/m16/SIMULATION.md`

Qualified simulation transcript:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

RTL closure record:

`rtl/m16/CLOSURE.md`

The qualified transcript records:

- simulator command;
- testbench execution command;
- SystemVerilog artifact inventory;
- simulator build result;
- architectural execution result;
- completion marker;
- scheduler execution;
- active-neutral routing;
- retained pending-route completion;
- transition-capacity enforcement;
- retained-state writeback;
- assertion execution;
- final counters;
- repository-integrity result;
- qualification evidence result;
- final PASS table.

Transcript result:

`PASS`

Transcript completion marker:

`FRP M16 deterministic RTL testbench completed.`

Transcript terminal counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Transcript qualification state:

`M16 RTL EXECUTION LAYER CLOSED`

## Qualification Evidence Record

Qualification evidence artifact:

`frp-m16-rtl-qualification-${{ github.run_number }}`

The artifact contains:

- toolchain record;
- SystemVerilog source hashes;
- Verilator build log;
- architectural execution log;
- qualification-result record.

Qualification evidence retention:

`30 days`

Qualification evidence count for workflow run `#84`:

`1`

Qualification evidence result:

`PASS`

## Repository Integrity Record

The simulator build directory and execution logs were generated under:

`/tmp`

Repository-local simulator build directories after execution:

`NONE`

Repository source modification during qualification:

`NONE`

Repository-integrity result:

`PASS`

## Failure Classification

The execution plan classifies failed simulator runs through the following boundaries:

| Failure category | Boundary |
|---|---|
| `compile_failure` | simulator parse or compile failure |
| `elaboration_failure` | module parameter or connection failure |
| `scheduler_failure` | scheduler state or counter mismatch |
| `state_domain_failure` | reserved ternary state emitted |
| `request_lane_failure` | request acceptance or rejection mismatch |
| `pending_route_failure` | pending-route creation, retention, or completion failure |
| `active_neutral_failure` | direct opposite-polarity transition detected |
| `capacity_failure` | accepted changes exceed `REQUEST_LANES` |
| `state_update_failure` | retained-state writeback failure |
| `assertion_failure` | assertion-layer failure |
| `counter_failure` | zero-event terminal counter failure |
| `transcript_failure` | simulator output does not reach the completion marker |

Qualified workflow run `#84` failure classification:

`NONE`

## M15 Compatibility Position

The M16 simulator qualification inherits the M15 semantic and implementation-mapping foundation.

M15 qualified state:

`M15 41/41 PASS`

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

Compatibility chain:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M15 SystemVerilog interface mapping`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 executable architectural simulation`

→ `M16 RTL execution closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

M15-to-M16 compatibility result:

`PASS`

## FPGA Preparation Handoff

The target-independent FPGA preparation layer inherits the qualified M16 RTL core.

FPGA integration top:

`fpga/m16/frp_m16_fpga_top.sv`

FPGA integration testbench:

`fpga/m16/frp_m16_fpga_tb.sv`

Current FPGA preparation record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

FPGA preparation handoff result:

`PASS`

## Current Execution State

| Execution boundary | Current state |
|---|---|
| RTL artifact inventory | `PASS` |
| RTL documentation inventory | `PASS` |
| Verilator parsing | `PASS` |
| module elaboration | `PASS` |
| executable testbench generation | `PASS` |
| architectural simulation | `PASS` |
| assertion execution | `PASS` |
| scheduler execution | `PASS` |
| request-lane arbitration | `PASS` |
| active-neutral routing | `PASS` |
| retained pending-route completion | `PASS` |
| transition-capacity enforcement | `PASS` |
| retained-state writeback | `PASS` |
| ten integrated invariant flags | `PASS` |
| zero-event terminal counters | `PASS` |
| simulation transcript | `PASS` |
| repository integrity | `PASS` |
| qualification evidence | `PASS` |
| M16 RTL qualification | `PASS` |
| M16 RTL execution layer | `M16 RTL EXECUTION LAYER CLOSED` |
| M16 FPGA preparation layer | `M16 FPGA PREPARATION LAYER CLOSED` |

Current release qualification:

`FRP v1.8.0 / M16 — PASS`

## Author

Maksym Marnov

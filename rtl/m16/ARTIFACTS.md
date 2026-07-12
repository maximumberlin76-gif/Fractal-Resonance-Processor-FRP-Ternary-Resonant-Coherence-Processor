# FRP M16 RTL Artifact Manifest

## Status

`ARTIFACT-BOUNDARY PASS`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This manifest records the concrete RTL artifacts introduced for the M16 RTL core realization layer of the:

`Ternary Fractal Resonant Coherence Processor`

The manifest defines the artifact inventory, semantic role, integration position, workflow qualification state, and remaining simulator boundary for each SystemVerilog and documentation artifact in `rtl/m16`.

M16 does not introduce a new processor model.

M16 realizes the M15-qualified retained-state execution contract in RTL artifact form.

## Current Qualification Result

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

## Preserved Execution Contract

The M16 RTL artifact set preserves the retained-state execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Required global invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Canonical Encoding

The artifact set preserves the canonical M15 balanced ternary encoding:

| Ternary state | Encoding | Status |
|---|---|---|
| `-1` | `2'b11` | valid |
| `0` | `2'b00` | valid active neutral |
| `+1` | `2'b01` | valid |
| reserved | `2'b10` | invalid |

Required invariant:

`reserved_state_events = 0`

## Artifact Inventory

| File | Artifact role | Status |
|---|---|---|
| `frp_m16_pkg.sv` | constants, encodings, helper functions, scheduler decoding, transition classification, capacity calculation | present |
| `frp_m16_scheduler.sv` | scheduler-state realization for `free`, `7/1`, and `1/7` execution modes | present |
| `frp_m16_request_lanes.sv` | deterministic request-lane arbitration | present |
| `frp_m16_pending_routes.sv` | pending-route register layer | present |
| `frp_m16_active_neutral.sv` | active-neutral transition generation | present |
| `frp_m16_capacity_guard.sv` | transition-capacity enforcement | present |
| `frp_m16_state_update.sv` | retained-state writeback | present |
| `frp_m16_core.sv` | integrated M16 RTL core | present |
| `frp_m16_assertions.sv` | assertion binding layer | present |
| `frp_m16_tb.sv` | deterministic smoke testbench | present |
| `README.md` | RTL layer overview | present |
| `ARTIFACTS.md` | current artifact manifest | current file |
| `SIMULATION.md` | simulator execution instructions | present |
| `SIMULATION_TRANSCRIPT.md` | simulation transcript template | present |
| `CLOSURE.md` | RTL closure report | present |

## Artifact Dependency Order

Recommended compile and dependency order:

    frp_m16_pkg.sv
    frp_m16_scheduler.sv
    frp_m16_request_lanes.sv
    frp_m16_pending_routes.sv
    frp_m16_active_neutral.sv
    frp_m16_capacity_guard.sv
    frp_m16_state_update.sv
    frp_m16_core.sv
    frp_m16_assertions.sv
    frp_m16_tb.sv

The package file must be visible before all dependent modules.

The integrated core imports and connects the module boundary.

The testbench instantiates the integrated core and assertion layer.

## Qualified Test Boundary

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

The test validates:

- `rtl/m16/` directory existence;
- required RTL source artifact existence;
- required RTL documentation artifact existence;
- canonical balanced ternary package symbols;
- integrated core module references;
- assertion-layer zero-event invariants;
- deterministic RTL smoke-testbench scope;
- simulation instruction boundary;
- simulation transcript placeholder boundary;
- closure document status;
- root README exposure;
- project-structure exposure;
- documentation README exposure;
- architecture document exposure.

## Qualified Workflow Boundary

Qualified workflow:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Workflow name:

`FRP M16 RTL Artifact Boundary`

Workflow result:

`PASS`

Passing run:

`FRP M16 RTL Artifact Boundary #8`

Passing commit:

`12a3431`

Workflow validation command:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

## Package Artifact

File:

`frp_m16_pkg.sv`

Role:

Defines the shared RTL constants and semantic encodings used across M16.

Includes:

- `FRP_M16_STATE_BITS`;
- `FRP_M16_SCHED_MODE_BITS`;
- `FRP_M16_SCHED_BITS`;
- `FRP_M16_COUNTER_BITS`;
- balanced ternary state encoding;
- scheduler mode encoding;
- scheduler state encoding;
- transition class encoding;
- request rejection reason encoding;
- invariant flag indexes;
- ternary-domain helper functions;
- transition-classification helper;
- scheduler decoding helpers;
- request-lane capacity calculation.

Required package invariant:

`FRP_M16_REQUEST_LANES_8_CELLS = 2`

`FRP_M16_REQUEST_LANES_16_CELLS = 4`

`FRP_M16_REQUEST_LANES_32_CELLS = 8`

## Scheduler Artifact

File:

`frp_m16_scheduler.sv`

Role:

Implements the M16 scheduler-state realization.

Preserved modes:

- `free`;
- `7/1`;
- `1/7`.

Required profiles:

| Mode | Required profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Required scheduler invariant:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

## Request-Lane Artifact

File:

`frp_m16_request_lanes.sv`

Role:

Implements deterministic request-lane arbitration.

Preserved properties:

- ascending lane order;
- valid cell-index checking;
- valid target-domain checking;
- duplicate-cell rejection;
- scheduler eligibility gating;
- pending-route priority protection;
- active-neutral routing classification;
- transition-capacity compatibility.

Required request-lane invariant:

`request_accept & request_reject = 0`

## Pending-Route Artifact

File:

`frp_m16_pending_routes.sv`

Role:

Implements retained pending-route state for opposite-polarity transitions.

Preserved sequence:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required pending-route invariants:

`pending routes preserve requested target polarity`

`pending completion starts from 0`

`queue_overflow_events = 0`

## Active-Neutral Artifact

File:

`frp_m16_active_neutral.sv`

Role:

Implements legal retained-state transition generation.

Allowed transitions:

`0 → +1`

`0 → -1`

`+1 → 0`

`-1 → 0`

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required active-neutral invariant:

`actual_direct_events = 0`

## Capacity-Guard Artifact

File:

`frp_m16_capacity_guard.sv`

Role:

Implements the transition-capacity boundary.

Preserved relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Required capacity invariant:

`accepted_changes <= REQUEST_LANES`

Switch-load numerator:

`switch_load_numerator = accepted_changes`

## State-Update Artifact

File:

`frp_m16_state_update.sv`

Role:

Implements final retained-state writeback.

Preserved writeback rules:

- reset initializes retained state to `0`;
- tick-disabled cycles preserve retained state;
- state-changing writeback requires capacity approval;
- same-state retention does not consume capacity;
- active-neutral routed writeback terminates in `0`;
- pending-route completion starts from `0`;
- reserved state output is forbidden;
- direct opposite-polarity writeback is forbidden.

Required state-update invariant:

`state_out` contains no `2'b10`

## Integrated Core Artifact

File:

`frp_m16_core.sv`

Role:

Integrates the M16 RTL execution modules into one core boundary.

Integrated modules:

- scheduler;
- request-lane arbitration;
- active-neutral transition;
- transition-capacity guard;
- pending-route register layer;
- retained-state update layer.

Core outputs include:

- retained state;
- pending-route state;
- scheduler counters;
- request accept/reject masks;
- accepted-change mask;
- accepted-change count;
- capacity remaining;
- capacity exhausted;
- switch-load numerator;
- event counters;
- invariant flags.

Required core invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Assertion Artifact

File:

`frp_m16_assertions.sv`

Role:

Defines assertion checks for the integrated RTL boundary.

Assertion coverage includes:

- state-domain validity;
- pending-route-domain validity;
- scheduler validity;
- scheduler counter consistency;
- request accept/reject separation;
- accepted-change capacity boundary;
- capacity remaining relation;
- capacity exhaustion relation;
- switch-load numerator relation;
- event-counter invariants;
- invariant-flag validity;
- tick-disabled hold behavior.

Required assertion result:

`PASS`

Current assertion source-artifact boundary result:

`PASS`

Current external simulator assertion result:

`pending external simulator execution`

## Testbench Artifact

File:

`frp_m16_tb.sv`

Role:

Provides the first deterministic RTL smoke testbench.

Current testbench exercises:

- reset-to-neutral initialization;
- free scheduler mode;
- `7/1` scheduler smoke profile;
- `1/7` scheduler smoke profile;
- neutral release `0 → +1`;
- neutralization `+1 → 0`;
- opposite-polarity request `+1 → -1`;
- active-neutral route `+1 → 0`;
- retained pending route to `-1`;
- pending completion `0 → -1`;
- invariant flag checks.

Required final testbench counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Documentation Artifact

File:

`README.md`

Role:

Documents the RTL layer, artifact set, compile order, scheduler semantics, ternary encoding, transition-capacity boundary, active-neutral routing, pending-route behavior, assertion boundary, M15 compatibility position, artifact-boundary PASS status, and external FPGA review boundary.

## Manifest Artifact

File:

`ARTIFACTS.md`

Role:

Records the current artifact set and defines the M16 RTL artifact inventory for qualification tracking.

## Simulation Instructions Artifact

File:

`SIMULATION.md`

Role:

Defines simulator command shape, artifact set under test, expected console markers, PASS conditions, assertion boundary, scheduler targets, transition targets, capacity targets, pending-route targets, and failure classification.

Current status:

`present`

## Simulation Transcript Artifact

File:

`SIMULATION_TRANSCRIPT.md`

Role:

Defines the expected transcript format for external simulator execution.

Current status:

`pending external simulator execution`

## Closure Artifact

File:

`CLOSURE.md`

Role:

Records the M16 RTL closure boundary, artifact-boundary PASS status, preserved execution semantics, M15 compatibility boundary, simulation boundary, corrective qualification event, closure table, and remaining simulator transcript requirements.

Current status:

`ARTIFACT-BOUNDARY PASS`

## Corrective Qualification Event

The M16 artifact-boundary workflow exposed a missing required RTL source artifact:

`rtl/m16/frp_m16_pending_routes.sv`

The missing pending-route RTL source artifact was added.

After correction, the M16 artifact-boundary workflow passed.

Corrected current result:

`FRP M16 RTL Artifact Boundary #8 — PASS`

Corrected commit:

`12a3431`

## Current Qualification Status

| Qualification group | Status |
|---|---|
| RTL artifact inventory | PASS |
| package artifact | present |
| scheduler artifact | present |
| request-lane artifact | present |
| pending-route artifact | present |
| active-neutral artifact | present |
| capacity-guard artifact | present |
| state-update artifact | present |
| integrated core artifact | present |
| assertion artifact | present |
| testbench artifact | present |
| documentation artifact set | present |
| artifact-boundary workflow | PASS |
| artifact-boundary qualification report | PASS |
| M16 qualification index | implemented |
| M16 qualification manifest | ACTIVE |
| simulator execution transcript | pending |
| deterministic replay adapter | pending |
| M16 final closure report | pending simulator transcript capture |
| FPGA synthesis report | pending |

## M15 Compatibility Position

The M16 RTL artifact set is designed to preserve the M15 deterministic retained-state boundary.

Compatibility chain:

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

## External Review Boundary

The M16 RTL artifact set defines the architecture and execution semantics internally.

An external FPGA or circuit-level reviewer may evaluate:

- synthesis feasibility;
- LUT utilization;
- FF utilization;
- BRAM usage;
- DSP usage;
- timing closure;
- reset strategy;
- clock strategy;
- constraints;
- target FPGA class.

External review must not redefine the FRP processor semantics.

## Manifest Closure Criteria

This artifact manifest is valid when:

- all implemented RTL files are listed;
- every artifact has a defined role;
- compile order is explicit;
- preserved invariants are stated;
- artifact-boundary workflow result is recorded;
- M15 compatibility boundary is stated;
- pending qualification artifacts are identified;
- external review boundary is constrained.

Current manifest result:

`PASS`

Current final simulator result:

`pending external simulator execution`

## Next Step

The next repository step should expose artifact-boundary PASS status from:

`docs/README.md`

## Author

Maksym Marnov

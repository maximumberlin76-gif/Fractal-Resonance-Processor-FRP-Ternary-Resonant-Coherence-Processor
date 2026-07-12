# FRP M16 Qualification Manifest

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the M16 qualification manifest for the RTL core realization layer.

The manifest preserves the M15-qualified execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 defines the qualification boundary required to move from documented RTL execution semantics into concrete SystemVerilog-oriented core realization and deterministic replay.

## Qualification Boundary

The M16 qualification boundary covers:

- RTL core realization scope;
- RTL core interface contract;
- balanced ternary state-register map;
- scheduler-state RTL realization;
- request-lane arbitration;
- pending-route register module;
- active-neutral transition module;
- transition-capacity guard module;
- retained-state update module;
- invariant assertion set;
- M15 vector replay compatibility;
- module-level closure gates;
- core-level closure gates;
- future SystemVerilog skeleton boundary.

The qualification manifest does not redefine:

- Kuramoto-Sakaguchi phase coupling;
- hierarchical fractal coupling;
- thermal-state dynamics;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary target generation.

Those upstream layers remain inherited from the M15-qualified reference chain.

## Core Identity Preserved

M16 preserves the FRP execution identity:

`Ternary Fractal Resonant Coherence Processor`

The retained execution chain remains:

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

## M15 Inherited Qualification Base

M16 starts from the completed M15 qualification boundary.

M15 established:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vector package;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

M16 must preserve deterministic compatibility with this M15 boundary.

## M16 Documented Artifact Set

The M16 documented artifact set consists of the following files:

| Artifact | Path | Status |
|---|---|---|
| RTL core realization scope | `docs/m16_rtl_core_realization_execution_semantics.md` | documented |
| RTL core interface contract | `docs/m16_rtl_core_interface_contract.md` | documented |
| balanced ternary state-register map | `docs/m16_balanced_ternary_state_register_map.md` | documented |
| scheduler-state RTL realization | `docs/m16_scheduler_state_rtl_realization.md` | documented |
| request-lane arbitration module | `docs/m16_request_lane_arbitration_module.md` | documented |
| pending-route register module | `docs/m16_pending_route_register_module.md` | documented |
| active-neutral transition module | `docs/m16_active_neutral_transition_module.md` | documented |
| transition-capacity guard module | `docs/m16_transition_capacity_guard_module.md` | documented |
| retained-state update module | `docs/m16_retained_state_update_module.md` | documented |
| invariant assertion set | `docs/m16_invariant_assertion_set.md` | documented |
| M15 vector replay compatibility report | `docs/m16_m15_vector_replay_compatibility_report.md` | documented |
| M16 qualification manifest | `docs/m16_qualification_manifest.md` | current file |

## Canonical Ternary Encoding Qualification

M16 preserves the canonical M15 two-bit ternary encoding:

| Ternary state | Encoding | Qualification status |
|---|---|---|
| `-1` | `2'b11` | required |
| `0` | `2'b00` | required |
| `+1` | `2'b01` | required |
| reserved | `2'b10` | forbidden |

Required qualification invariant:

`reserved_state_events = 0`

Required output-domain invariant:

`state_out` must never contain `2'b10`.

## Scheduler Qualification

M16 preserves three explicit processor execution modes:

- `free`;
- `7/1`;
- `1/7`.

These are processor execution semantics.

They are not external benchmark labels.

Required scheduler qualification profiles:

| Mode | Required profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Required scheduler invariant:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

Required scheduler flag:

`scheduler_counts_valid = True`

## Request-Lane Qualification

M16 preserves deterministic request-lane ordering.

Required lane order:

`lane 0`

→ `lane 1`

→ `lane 2`

→ `...`

→ `lane REQUEST_LANES - 1`

Required request-lane properties:

- valid cell-index checking;
- valid target-domain checking;
- reserved target rejection;
- duplicate-cell rejection;
- scheduler eligibility gating;
- transition-capacity gating;
- deterministic acceptance and rejection masks.

Required request-lane invariants:

`request_lane_order_valid = True`

`request_cell_domain_valid = True`

`request_target_domain_valid = True`

`duplicate_cell_guard_valid = True`

## Transition-Capacity Qualification

M16 preserves the inherited M15 transition boundary:

`transition_fraction = 0.25`

Required request-lane relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Validated inherited profiles:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required capacity invariant:

`accepted_changes <= REQUEST_LANES`

Required switch-load relation:

`switch_load = accepted_changes / CELLS`

Required switch-load bound:

`switch_load_peak <= transition_fraction`

## Active-Neutral Routing Qualification

M16 preserves mandatory active-neutral routing.

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required direct-transition invariant:

`actual_direct_events = 0`

Required active-neutral flag:

`active_neutral_routing_valid = True`

## Pending-Route Qualification

M16 preserves retained pending-route semantics for opposite-polarity requests.

Required pending-route creation:

`state_q_i × request_target_i = -1`

→ first legal transition:

`state_q_i → 0`

→ retained continuation:

`pending_route_d_i = request_target_i`

Required pending-route completion:

`state_q_i = 0`

and:

`pending_route_q_i != 0`

→ later legal transition:

`0 → pending_route_q_i`

→ pending clear:

`pending_route_d_i = 0`

Required pending-route invariants:

`pending routes preserve requested target polarity`

`pending completion starts from 0`

`pending route is not overwritten before completion`

`queue_overflow_events = 0`

## Retained-State Update Qualification

M16 preserves deterministic retained-state writeback.

Required retained-state update conditions:

- reset initializes retained state to active neutral `0`;
- tick-disabled cycles preserve retained state;
- state-changing writeback requires capacity approval;
- same-state retention does not consume capacity;
- active-neutral routed writeback terminates in `0`;
- pending-route completion starts from `0`;
- reserved state output is forbidden;
- direct opposite-polarity writeback is forbidden.

Required retained-state invariants:

`state_domain_valid = True`

`state_update_valid = True`

`no_reserved_state = True`

`no_actual_direct_events = True`

## Event-Counter Qualification

M16 preserves M15-compatible event counters.

Required counters:

| Counter | Required relation |
|---|---|
| `ticks_recorded` | exact executed tick count |
| `requested_direct_events` | direct opposite-polarity requests observed |
| `prevented_direct_events` | `>= requested_direct_events` |
| `neutral_routed_events` | `>= prevented_direct_events` |
| `actual_direct_events` | `= 0` |
| `reserved_state_events` | `= 0` |
| `queue_overflow_events` | `= 0` |
| `accepted_change_events` | sum of accepted retained-state changes |
| `pending_created_events` | accepted opposite-polarity pending creations |
| `pending_completed_events` | completed routes from active neutral `0` |

Required event-counter invariant:

`event counters remain internally consistent`

## Invariant-Flag Qualification

M16 exposes compact invariant flags for replay and assertion correlation.

Required flags:

| Flag | Required value |
|---|---|
| `state_domain_valid` | `True` |
| `scheduler_counts_valid` | `True` |
| `request_lane_order_valid` | `True` |
| `pending_polarity_valid` | `True` |
| `active_neutral_routing_valid` | `True` |
| `transition_capacity_valid` | `True` |
| `state_update_valid` | `True` |
| `no_actual_direct_events` | `True` |
| `no_reserved_state` | `True` |
| `no_queue_overflow` | `True` |

Required invariant-flag relation:

`invariant flags correlate with assertion results`

## Assertion Qualification

M16 requires module-level and core-level assertion groups.

Required assertion groups:

| Assertion group | Required status |
|---|---|
| state-domain assertions | `PASS` |
| reset assertions | `PASS` |
| tick-enable assertions | `PASS` |
| scheduler assertions | `PASS` |
| request-lane assertions | `PASS` |
| pending-route assertions | `PASS` |
| active-neutral transition assertions | `PASS` |
| transition-capacity assertions | `PASS` |
| retained-state update assertions | `PASS` |
| event-counter assertions | `PASS` |
| invariant-flag assertions | `PASS` |
| M15 vector replay assertions | `PASS` |

M16 is not qualified until every required assertion group passes.

## M15 Vector Replay Qualification

M16 must replay the M15 deterministic vector package at the retained-state boundary.

Required replay groups:

| Replay group | Required result |
|---|---|
| scheduler replay | `PASS` |
| request-lane replay | `PASS` |
| pending-route replay | `PASS` |
| active-neutral replay | `PASS` |
| transition-capacity replay | `PASS` |
| retained-state replay | `PASS` |
| event-counter replay | `PASS` |
| invariant-flag replay | `PASS` |
| assertion-status replay | `PASS` |
| final deterministic replay | `PASS` |

Replay target:

`deterministic boundary equivalence`

Replay target is not approximate behavioral similarity.

## Module-Level Closure Gates

Each M16 module must satisfy its local closure gate.

| Module | Required closure condition |
|---|---|
| scheduler-state RTL realization | scheduler profiles and counters match M15 |
| request-lane arbitration | deterministic lane acceptance and rejection match M15 |
| pending-route register module | pending-route polarity and completion match M15 |
| active-neutral transition module | routed transitions and masks match M15 |
| transition-capacity guard | accepted changes and capacity masks match M15 |
| retained-state update module | final retained state matches M15 |
| invariant assertion set | all required assertion groups are represented |
| vector replay compatibility report | replay boundary and failure classes are defined |

Every module-level closure gate must pass before core-level closure.

## Core-Level Closure Gates

M16 core-level closure requires:

- canonical ternary encoding preserved;
- scheduler profiles preserved;
- request-lane ordering preserved;
- transition capacity preserved;
- active-neutral routing preserved;
- pending-route semantics preserved;
- retained-state update semantics preserved;
- event-counter relations preserved;
- invariant flags preserved;
- assertion groups passed;
- M15 vector replay passed;
- deterministic replay digest generated.

Required final core status:

`PASS`

## Failure Classification

Any M16 qualification failure must map to a specific boundary.

Required failure categories:

| Failure category | Boundary |
|---|---|
| `state_domain_failure` | ternary encoding or reserved state |
| `scheduler_failure` | scheduler state, profile, or counter |
| `request_lane_failure` | arbitration acceptance or rejection |
| `pending_route_failure` | pending storage, polarity, or completion |
| `active_neutral_failure` | routed transition or direct-transition guard |
| `capacity_failure` | accepted-change or switch-load boundary |
| `retained_state_failure` | final state writeback |
| `counter_failure` | event-counter relation |
| `invariant_flag_failure` | flag/assertion mismatch |
| `vector_replay_failure` | M15 replay mismatch |
| `digest_failure` | deterministic digest mismatch |

Unclassified qualification failure is not allowed.

## M16 Artifact Generation Boundary

This manifest is a documentation-level qualification boundary.

Concrete M16 artifact generation should follow after this manifest.

Expected future generated artifacts:

1. SystemVerilog module skeletons;
2. M16 interface package;
3. M16 assertion package;
4. M16 testbench harness;
5. M15 vector replay adapter;
6. M16 replay result manifest;
7. M16 deterministic digest manifest;
8. M16 closure report.

These artifacts must not change the M15-qualified execution semantics.

## Expected SystemVerilog Module Set

The future M16 SystemVerilog layer should include:

| Module | Expected purpose |
|---|---|
| `frp_m16_pkg.sv` | constants, encodings, parameters |
| `frp_m16_scheduler.sv` | scheduler-state realization |
| `frp_m16_request_lanes.sv` | request-lane arbitration |
| `frp_m16_pending_routes.sv` | pending-route register module |
| `frp_m16_active_neutral.sv` | legal transition module |
| `frp_m16_capacity_guard.sv` | transition-capacity guard |
| `frp_m16_state_update.sv` | retained-state writeback |
| `frp_m16_core.sv` | integrated RTL core |
| `frp_m16_assertions.sv` | assertion binding layer |
| `frp_m16_tb.sv` | deterministic replay testbench |

This module list is the starting boundary for concrete RTL realization.

## Required M16 Qualification Invariants

M16 qualification is valid only if:

Canonical ternary encoding is preserved.

Reserved state `2'b10` is never emitted as valid state.

Reset initializes retained state to active neutral `0`.

Tick-disabled cycles preserve retained state.

Scheduler profiles match M15 references.

Request lanes are deterministic.

Accepted changes never exceed `REQUEST_LANES`.

Switch load remains bounded by `transition_fraction`.

Opposite-polarity transitions pass through `0`.

Direct opposite-polarity execution remains zero.

Pending routes preserve target polarity.

Pending routes complete only from `0`.

Capacity rejection does not clear pending routes.

Queue overflow events remain zero.

Event counters remain internally consistent.

Invariant flags correlate with assertion results.

M15 vector replay remains deterministic.

Concrete RTL artifacts do not modify M15-qualified processor semantics.

## Qualification Status Table

Current documentation-level M16 status:

| Qualification group | Status |
|---|---|
| RTL core realization scope | documented |
| RTL core interface contract | documented |
| state-register map | documented |
| scheduler realization | documented |
| request-lane arbitration | documented |
| pending-route module | documented |
| active-neutral transition module | documented |
| transition-capacity guard | documented |
| retained-state update module | documented |
| invariant assertion set | documented |
| M15 replay compatibility report | documented |
| qualification manifest | documented |
| concrete SystemVerilog modules | pending |
| concrete replay adapter | pending |
| concrete replay result digest | pending |
| M16 closure report | pending |

## Qualification Closure Rule

M16 is not closed by documentation alone.

M16 closes only when the concrete RTL-oriented artifact chain demonstrates:

- module-level assertion pass;
- core-level assertion pass;
- M15 vector replay pass;
- deterministic digest generation;
- zero direct opposite-polarity events;
- zero reserved-state events;
- zero queue-overflow events;
- preserved scheduler profiles;
- preserved retained-state sequences;
- preserved pending-route sequences.

Required final qualification result:

`PASS`

## Next Step

After this manifest is committed, the next layer should introduce the first concrete RTL artifact boundary:

`rtl/m16/frp_m16_pkg.sv`

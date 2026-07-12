# FRP M16 M15 Vector Replay Compatibility Report

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the M16 compatibility report structure for replaying the M15 deterministic vector package against the M16 RTL core realization layer.

The report preserves the M15-qualified execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 must replay the M15 deterministic execution contract through an explicit RTL-oriented core boundary.

## Replay Boundary

The M16 replay boundary compares the M16 RTL core realization against the M15 deterministic reference package.

The replay boundary covers:

- scheduler-state replay;
- request-lane replay;
- pending-route replay;
- active-neutral transition replay;
- transition-capacity replay;
- retained-state update replay;
- event-counter replay;
- invariant-flag replay;
- assertion-status replay;
- final qualification compatibility.

The replay boundary does not recompute:

- Kuramoto-Sakaguchi phase coupling;
- phase words;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary target generation.

Those upstream values are inherited as deterministic M15 vector inputs.

## Compatibility Position

M16 is compatible with M15 only if the RTL core realization preserves the M15 execution contract exactly at the retained-state boundary.

The required compatibility chain is:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core replay`

→ `M16 invariant assertion set`

→ `M16 qualification closure`

The M16 replay target is not approximate behavioral similarity.

The replay target is deterministic boundary equivalence.

## M15 Reference Sources

The M16 replay report is grounded in the M15 artifact chain:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden trace;
- deterministic RTL comparison vector package;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

## Core Identity Preserved

The replay report protects the FRP execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Required global replay invariant:

`actual_direct_events = 0`

Required state-domain replay invariant:

`reserved_state_events = 0`

Required queue replay invariant:

`queue_overflow_events = 0`

## Canonical Replay Encoding

M16 replay preserves the M15 canonical two-bit ternary encoding:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The reserved encoding is invalid.

Required replay invariant:

`reserved_state_events = 0`

## Replay Profiles

M16 must preserve the inherited M15 validated profile set:

| Cells | Request lanes | Packed state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

Required relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Inherited transition boundary:

`transition_fraction = 0.25`

Required bound:

`accepted_changes <= REQUEST_LANES`

## Scheduler Replay Targets

M16 must replay the three M15 execution modes:

| Mode | Required replay profile |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Required scheduler relation:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

Required replay flag:

`scheduler_counts_valid = True`

## Replay Input Set

The M16 replay input set is the deterministic input boundary inherited from M15.

Required replay inputs:

| Input | Meaning |
|---|---|
| `tick_index` | deterministic tick index |
| `tick_enable` | tick execution enable |
| `scheduler_mode` | selected execution mode |
| `scheduler_state_expected` | expected scheduler state from M15 |
| `state_q` | retained ternary state at tick start |
| `target_q` | phase-derived ternary target vector |
| `pending_route_q` | retained pending-route vector |
| `request_valid` | request-lane valid flags |
| `request_cell_index` | requested cell index per lane |
| `request_target` | requested ternary target per lane |
| `REQUEST_LANES` | transition-capacity lane count |
| `CELLS` | processor-cell count |

The replay input set must be sufficient to reproduce one deterministic M16 tick.

## Replay Output Set

The M16 replay output set is the deterministic output boundary compared against M15.

Required replay outputs:

| Output | Meaning |
|---|---|
| `scheduler_state` | actual M16 scheduler state |
| `scheduler counters` | emitted M16 scheduler counters |
| `request_accept` | accepted request lanes |
| `request_reject` | rejected request lanes |
| `accepted_cell_mask` | accepted cells for tick |
| `neutral_routed_mask` | cells routed through active neutral `0` |
| `pending_route_d` | next pending-route state |
| `state_d` | next retained state |
| `state_out` | committed retained state |
| `accepted_change_mask` | retained-state changes accepted |
| `accepted_changes` | number of accepted retained-state changes |
| `capacity_remaining` | unused capacity for tick |
| `capacity_exhausted` | capacity exhaustion flag |
| `event counter deltas` | tick-level counter deltas |
| `invariant flags` | compact invariant status |
| `assertion status` | assertion pass/fail status |

## Replay Comparison Classes

M16 compatibility is evaluated through the following comparison classes:

1. scheduler replay;
2. request-lane replay;
3. pending-route replay;
4. active-neutral transition replay;
5. transition-capacity replay;
6. retained-state replay;
7. event-counter replay;
8. invariant-flag replay;
9. assertion-status replay;
10. final digest replay.

Each comparison class must pass independently.

## Scheduler Replay Comparison

Scheduler replay compares:

`M15 scheduler state`

against:

`M16 scheduler state`

Required comparisons:

| Field | Required result |
|---|---|
| `scheduler_state` | exact match |
| `scheduler_count_free` | exact match |
| `scheduler_count_balance` | exact match |
| `scheduler_count_commit` | exact match |
| `scheduler_count_excite` | exact match |
| `scheduler_count_neutralize` | exact match |
| `ticks_recorded` | exact match |
| `scheduler_counts_valid` | exact match |

Required replay result:

`PASS`

## Request-Lane Replay Comparison

Request-lane replay compares deterministic arbitration outputs.

Required comparisons:

| Field | Required result |
|---|---|
| `request_accept` | exact match |
| `request_reject` | exact match |
| `request_reject_invalid_cell` | exact match |
| `request_reject_invalid_target` | exact match |
| `request_reject_duplicate_cell` | exact match |
| `request_reject_scheduler` | exact match |
| `request_reject_capacity` | exact match |
| `accepted_cell_mask` | exact match |
| `rejected_cell_mask` | exact match |
| `neutral_routed_cell_mask` | exact match |

Required replay result:

`PASS`

## Pending-Route Replay Comparison

Pending-route replay compares retained pending-route evolution.

Required comparisons:

| Field | Required result |
|---|---|
| `pending_route_q` | exact input match |
| `pending_route_d` | exact output match |
| `pending_created_mask` | exact match |
| `pending_completed_mask` | exact match |
| `pending_retained_mask` | exact match |
| `pending_blocked_mask` | exact match |
| `pending_reserved_mask` | exact match |

Required replay result:

`PASS`

Required invariant:

`pending routes preserve requested target polarity`

## Active-Neutral Replay Comparison

Active-neutral replay compares legal ternary transition behavior.

Required comparisons:

| Field | Required result |
|---|---|
| `same_state_mask` | exact match |
| `zero_to_nonzero_mask` | exact match |
| `nonzero_to_zero_mask` | exact match |
| `opposite_polarity_mask` | exact match |
| `neutral_routed_mask` | exact match |
| `pending_completion_mask` | exact match |
| `actual_direct_mask` | exact match |
| `reserved_transition_mask` | exact match |

Required replay result:

`PASS`

Required invariant:

`actual_direct_events = 0`

## Transition-Capacity Replay Comparison

Transition-capacity replay compares capacity admission and rejection.

Required comparisons:

| Field | Required result |
|---|---|
| `request_accept_capacity` | exact match |
| `request_reject_capacity` | exact match |
| `capacity_accept_mask` | exact match |
| `capacity_reject_mask` | exact match |
| `accepted_change_mask` | exact match |
| `accepted_changes` | exact match |
| `capacity_remaining` | exact match |
| `capacity_exhausted` | exact match |
| `switch_load_numerator` | exact match |

Required replay result:

`PASS`

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Retained-State Replay Comparison

Retained-state replay compares final state writeback.

Required comparisons:

| Field | Required result |
|---|---|
| `state_q` | exact input match |
| `state_candidate_d` | exact candidate match |
| `state_d` | exact output match |
| `state_out` | exact committed-state match |
| `state_write_enable_mask` | exact match |
| `state_hold_mask` | exact match |
| `state_reserved_mask` | exact match |
| `accepted_changes` | exact match |

Required replay result:

`PASS`

Required invariant:

`state_out` contains no `2'b10`

## Event-Counter Replay Comparison

Event-counter replay compares tick-level deltas and cumulative totals.

Required counters:

| Counter | Required result |
|---|---|
| `ticks_recorded` | exact match |
| `requested_direct_events` | exact match |
| `prevented_direct_events` | exact match |
| `neutral_routed_events` | exact match |
| `actual_direct_events` | exact match |
| `reserved_state_events` | exact match |
| `queue_overflow_events` | exact match |
| `accepted_change_events` | exact match |
| `pending_created_events` | exact match |
| `pending_completed_events` | exact match |
| `capacity_reject_events` | exact match |

Required replay result:

`PASS`

Required event-counter invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

## Invariant-Flag Replay Comparison

Invariant-flag replay compares compact M16 flags against M15 replay expectations.

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

Required replay result:

`PASS`

## Assertion-Status Replay Comparison

Assertion-status replay compares module-level and core-level assertion outcomes.

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

Required replay result:

`PASS`

## Digest Replay Boundary

The M16 replay report should preserve deterministic digest generation for replay artifacts.

Digest inputs should include:

- replay input vectors;
- replay output vectors;
- event-counter deltas;
- invariant flags;
- assertion statuses;
- replay summary manifest.

Required digest property:

`same replay inputs → same digest`

Required replay result:

`PASS`

The M15 package digest remains:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

A future M16 digest should be generated only after concrete M16 replay artifacts exist.

## Replay Failure Classification

A replay mismatch must be classified by module boundary.

Required failure categories:

| Failure category | Meaning |
|---|---|
| `scheduler_mismatch` | scheduler state or counter mismatch |
| `request_lane_mismatch` | arbitration output mismatch |
| `pending_route_mismatch` | pending-route state mismatch |
| `active_neutral_mismatch` | transition mask or route mismatch |
| `capacity_mismatch` | capacity admission or count mismatch |
| `retained_state_mismatch` | final retained-state mismatch |
| `counter_mismatch` | event-counter mismatch |
| `invariant_flag_mismatch` | invariant flag mismatch |
| `assertion_status_mismatch` | assertion pass/fail mismatch |
| `digest_mismatch` | deterministic digest mismatch |

Every failure must map to one boundary.

Unclassified replay mismatch is not allowed.

## Replay Pass Criteria

A replay comparison passes only when:

- scheduler replay matches exactly;
- request-lane replay matches exactly;
- pending-route replay matches exactly;
- active-neutral transition replay matches exactly;
- transition-capacity replay matches exactly;
- retained-state replay matches exactly;
- event-counter replay matches exactly;
- invariant-flag replay matches exactly;
- assertion-status replay passes;
- deterministic digest generation is stable.

Required final replay status:

`PASS`

## Required M16 Replay Invariants

The M16 M15 vector replay compatibility layer is valid only if:

M16 consumes the M15 deterministic vector boundary without semantic reinterpretation.

M16 scheduler profiles match M15 references.

M16 request-lane arbitration matches M15 references.

M16 pending-route evolution matches M15 references.

M16 active-neutral routing matches M15 references.

M16 transition-capacity behavior matches M15 references.

M16 retained-state output matches M15 references.

M16 event counters match M15 references.

M16 invariant flags match M15 expectations.

M16 assertions pass at module and core level.

Direct opposite-polarity execution remains zero.

Reserved state events remain zero.

Queue overflow events remain zero.

M15 vector replay remains deterministic.

## Compatibility Report Table

The M16 replay report should emit the following summary table:

| Replay group | Status | Required result |
|---|---|---|
| scheduler replay | pending until M16 artifact generation | `PASS` |
| request-lane replay | pending until M16 artifact generation | `PASS` |
| pending-route replay | pending until M16 artifact generation | `PASS` |
| active-neutral replay | pending until M16 artifact generation | `PASS` |
| transition-capacity replay | pending until M16 artifact generation | `PASS` |
| retained-state replay | pending until M16 artifact generation | `PASS` |
| event-counter replay | pending until M16 artifact generation | `PASS` |
| invariant-flag replay | pending until M16 artifact generation | `PASS` |
| assertion-status replay | pending until M16 artifact generation | `PASS` |
| final deterministic replay | pending until M16 artifact generation | `PASS` |

## Closure Criteria

The M16 M15 vector replay compatibility report can be considered ready when it defines:

- replay input boundary;
- replay output boundary;
- scheduler replay comparison;
- request-lane replay comparison;
- pending-route replay comparison;
- active-neutral replay comparison;
- transition-capacity replay comparison;
- retained-state replay comparison;
- event-counter replay comparison;
- invariant-flag replay comparison;
- assertion-status replay comparison;
- digest replay boundary;
- replay failure classification;
- final pass criteria.

## Next Step

The next M16 file should define the qualification manifest:

`docs/m16_qualification_manifest.md`

# FRP M16 Transition Capacity Guard Module

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the transition-capacity guard module for the M16 RTL core realization layer.

The transition-capacity guard preserves the M15-qualified switching boundary of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 realizes the retained-state transition-capacity law in an explicit RTL-oriented guard module.

## Capacity Boundary

The transition-capacity guard controls how many retained-state changes may be accepted during one processor tick.

It covers:

- transition-capacity parameterization;
- request-lane capacity relation;
- accepted-change counting;
- capacity admission;
- capacity rejection;
- switch-load numerator generation;
- scheduler-state interaction;
- pending-route completion capacity;
- active-neutral routing capacity;
- capacity invariant flags;
- event-counter source generation;
- assertion correlation;
- M15 vector replay compatibility.

The guard does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary target generation.

## Core Identity Preserved

The transition-capacity guard preserves the M15 execution boundary:

`transition_fraction = 0.25`

This means only a bounded fraction of retained ternary cells may change during one tick.

The guard prevents uncontrolled simultaneous switching and preserves deterministic replay against the M15 cycle-exact integer golden trace.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Capacity Formula

The inherited M15 relation is:

`max_changes = max(1, round(CELLS × transition_fraction))`

The M16 hardware-facing relation is:

`REQUEST_LANES = max_changes`

Inherited default:

`transition_fraction = 0.25`

Validated inherited profiles:

| Cells | Transition fraction | Request lanes |
|---:|---:|---:|
| `8` | `0.25` | `2` |
| `16` | `0.25` | `4` |
| `32` | `0.25` | `8` |

Required relation:

`REQUEST_LANES = max_changes`

Required invariant:

`accepted_changes <= REQUEST_LANES`

## RTL Parameter Boundary

The M16 transition-capacity guard is parameterized by:

| Parameter | Meaning |
|---|---|
| `CELLS` | number of processor cells |
| `REQUEST_LANES` | maximum accepted retained-state changes per tick |
| `STATE_BITS` | ternary state encoding width |
| `COUNTER_BITS` | event-counter width |

Required relation:

`STATE_BITS = 2`

Required implementation relation:

`REQUEST_LANES` is a compile-time hardware parameter derived from the selected `CELLS` profile.

For the current M16 qualified profiles, `REQUEST_LANES` is not dynamically recomputed at runtime.

## Module Inputs

The transition-capacity guard consumes:

| Signal | Width | Meaning |
|---|---:|---|
| `tick_enable` | `1` | enables one processor tick |
| `scheduler_state` | scheduler-state width | current scheduler state |
| `request_valid` | `REQUEST_LANES` | valid request lanes |
| `request_accept_candidate` | `REQUEST_LANES` | request lanes eligible before capacity guard |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | requested cell index per lane |
| `transition_class` | per-lane class width | classified transition type |
| `pending_completion_candidate` | `CELLS` | pending completions eligible before capacity guard |
| `neutral_routed_candidate` | `CELLS` | active-neutral routes eligible before capacity guard |
| `state_q` | `CELLS × STATE_BITS` | retained ternary state at tick start |
| `state_candidate_d` | `CELLS × STATE_BITS` | candidate next retained state before capacity guard |

Required relation:

`state_candidate_d` must already preserve the active-neutral transition law.

The capacity guard must not authorize illegal direct opposite-polarity transitions.

## Module Outputs

The transition-capacity guard emits:

| Signal | Width | Meaning |
|---|---:|---|
| `request_accept_capacity` | `REQUEST_LANES` | request lanes accepted after capacity guard |
| `request_reject_capacity` | `REQUEST_LANES` | request lanes rejected due to capacity |
| `capacity_accept_mask` | `CELLS` | cells accepted by capacity guard |
| `capacity_reject_mask` | `CELLS` | cells rejected by capacity guard |
| `accepted_change_mask` | `CELLS` | retained-state changes accepted for this tick |
| `accepted_changes` | counter width | number of accepted retained-state changes |
| `capacity_remaining` | counter width | unused transition capacity for this tick |
| `capacity_exhausted` | `1` | high when no more retained-state changes may be accepted |
| `transition_capacity_valid` | `1` | capacity invariant flag |
| `switch_load_numerator` | counter width | accepted retained-state changes |

Required relation:

`switch_load_numerator = accepted_changes`

## Accepted Change Definition

A retained-state change occurs when:

`state_d_i != state_q_i`

Same-state retention does not consume transition capacity.

Rejected requests do not consume transition capacity.

Invalid requests do not consume transition capacity.

Required relation:

`accepted_changes = popcount(accepted_change_mask)`

Required bound:

`accepted_changes <= REQUEST_LANES`

## Capacity Admission Rule

A transition candidate may be accepted only if accepting it does not exceed:

`REQUEST_LANES`

For deterministic lane order, the guard evaluates candidates in the order produced by the request-lane arbitration layer.

Required admission relation:

`accepted_changes_next <= REQUEST_LANES`

If the relation holds, the candidate may be accepted.

If the relation does not hold, the candidate must be rejected by capacity.

## Capacity Rejection Rule

If accepting a candidate transition would exceed:

`REQUEST_LANES`

then the candidate is rejected:

`request_reject_capacity = 1`

and:

`request_accept_capacity = 0`

Capacity rejection must not create:

- invalid retained state;
- invalid pending-route state;
- direct opposite-polarity transition;
- queue overflow;
- scheduler counter mismatch.

Required invariant:

`queue_overflow_events = 0`

Capacity rejection is not queue overflow when the request is cleanly rejected and no state corruption occurs.

## Tick-Enable Behavior

If:

`tick_enable = 0`

then:

`accepted_changes = 0`

`accepted_change_mask = 0`

`request_accept_capacity = 0`

`request_reject_capacity = 0`

`capacity_exhausted = 0`

No retained-state transition is accepted.

Required invariant:

`tick_enable = 0 → no capacity consumption`

## Deterministic Candidate Order

The guard preserves deterministic ordering inherited from request-lane arbitration.

Order:

`lane 0`

→ `lane 1`

→ `lane 2`

→ `...`

→ `lane REQUEST_LANES - 1`

Pending-route completion candidates preserve the deterministic cell order or the M15 vector-defined replay order.

Required invariant:

`capacity guard does not reorder accepted candidates`

## Same-State Capacity Rule

If a candidate does not change retained state:

`state_candidate_d_i = state_q_i`

then it does not consume capacity.

Same-state metadata may be replayed for trace compatibility, but it must not increase:

`accepted_changes`

Required invariant:

`same-state retention does not consume transition capacity`

## Zero-to-Nonzero Capacity Rule

A legal transition:

`0 → -1`

or:

`0 → +1`

consumes one transition-capacity slot.

Required relation:

`zero_to_nonzero accepted → accepted_changes += 1`

## Nonzero-to-Zero Capacity Rule

A legal transition:

`-1 → 0`

or:

`+1 → 0`

consumes one transition-capacity slot.

Required relation:

`nonzero_to_zero accepted → accepted_changes += 1`

## Active-Neutral Routing Capacity Rule

An opposite-polarity request routed through active neutral:

`-1 → 0`

or:

`+1 → 0`

consumes one transition-capacity slot for the current tick.

The later completion:

`0 → +1`

or:

`0 → -1`

consumes one transition-capacity slot on its completion tick.

Required invariant:

`opposite-polarity route is capacity-counted per legal tick transition`

## Pending-Completion Capacity Rule

A pending-route completion:

`0 → pending_route_q_i`

consumes one transition-capacity slot.

If capacity is exhausted, pending-route completion must be deferred without clearing the pending route.

Required invariant:

`capacity rejection does not clear pending route`

## Scheduler Interaction

The scheduler defines temporal eligibility.

The transition-capacity guard defines how many eligible transitions may be accepted.

The scheduler must not bypass the capacity guard.

The capacity guard must not redefine scheduler semantics.

Required invariant:

`scheduler-eligible transitions remain capacity-bounded`

## Free-State Capacity Behavior

In `free` scheduler state, all eligible legal transition classes remain subject to the capacity guard.

Allowed capacity-counted transitions may include:

- pending-route completion;
- `0 → ±1`;
- `±1 → 0`;
- active-neutral routing through `0`.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Balance-State Capacity Behavior

In `balance` scheduler state, accepted retained-state changes remain capacity-bounded.

Balance-state accepted changes may include:

- `±1 → 0`;
- active-neutral routing through `0`.

Commit release remains controlled by commit-capable scheduler states.

Required invariant:

`actual_direct_events = 0`

## Commit-State Capacity Behavior

In `commit` scheduler state, accepted retained-state changes remain capacity-bounded.

Commit-state accepted changes may include:

- pending-route completion;
- `0 → ±1`;
- retained-state commit transitions.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Excite-State Capacity Behavior

In `excite` scheduler state, accepted retained-state changes remain capacity-bounded.

Excite-state accepted changes may include:

- `0 → ±1`;
- pending-route completion when eligible;
- nonzero target acceptance.

Required invariant:

`switch_load_peak <= transition_fraction`

## Neutralize-State Capacity Behavior

In `neutralize` scheduler state, accepted retained-state changes remain capacity-bounded.

Neutralize-state accepted changes may include:

- `±1 → 0`;
- active-neutral routing through `0`.

Required invariant:

`actual_direct_events = 0`

## Switch Load Relation

The transition-capacity guard emits:

`switch_load_numerator = accepted_changes`

The inherited switch-load relation is:

`switch_load = accepted_changes / CELLS`

Required bound:

`switch_load_peak <= transition_fraction`

For the current validated profiles:

| Cells | Request lanes | Maximum switch load |
|---:|---:|---:|
| `8` | `2` | `0.25` |
| `16` | `4` | `0.25` |
| `32` | `8` | `0.25` |

## Capacity Exhaustion

Capacity is exhausted when:

`accepted_changes = REQUEST_LANES`

When capacity is exhausted, additional state-changing candidates must be rejected or deferred.

Required relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

Capacity exhaustion must not invalidate already accepted legal transitions.

## Capacity Remaining

Capacity remaining is:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required bound:

`0 <= capacity_remaining <= REQUEST_LANES`

The value is a tick-local diagnostic and comparison output.

## Interaction With Pending Routes

The capacity guard must preserve pending-route safety.

If a pending route cannot complete because capacity is exhausted:

`pending_route_d_i = pending_route_q_i`

The pending route remains retained for a later eligible tick.

Required invariant:

`pending route polarity remains stable under capacity rejection`

## Interaction With Active-Neutral Routing

If an opposite-polarity request cannot be routed through `0` because capacity is exhausted, the direct transition remains forbidden.

The request must be rejected or deferred.

Required invariant:

`capacity exhaustion cannot authorize direct opposite-polarity transition`

## Interaction With Reserved States

The capacity guard must not accept transitions involving reserved encodings.

Reserved encoding:

`2'b10`

Required invariant:

`reserved transition candidates are not capacity-accepted`

The capacity guard is not a repair mechanism for reserved-state corruption.

Reserved-state detection remains part of the state-domain and transition-domain guards.

## Event Counter Sources

The transition-capacity guard provides counter sources for:

| Counter source | Meaning |
|---|---|
| `capacity_candidate_events` | state-changing candidates observed |
| `capacity_accept_events` | candidates accepted by capacity guard |
| `capacity_reject_events` | candidates rejected by capacity guard |
| `capacity_exhausted_events` | ticks where capacity was exhausted |
| `accepted_change_events` | accepted retained-state changes |
| `switch_load_numerator_events` | accepted-change count for switch-load calculation |

Required relation:

`capacity_accept_events = accepted_change_events`

Required bound:

`accepted_change_events <= REQUEST_LANES per tick`

## Capacity Invariant Flags

The transition-capacity guard exposes:

| Flag | Required value |
|---|---|
| `transition_capacity_valid` | `True` |
| `accepted_changes_within_limit` | `True` |
| `capacity_remaining_valid` | `True` |
| `capacity_exhaustion_valid` | `True` |
| `same_state_capacity_valid` | `True` |
| `pending_capacity_valid` | `True` |
| `active_neutral_capacity_valid` | `True` |
| `switch_load_bound_valid` | `True` |
| `no_queue_overflow` | `True` |
| `no_actual_direct_events` | `True` |

These flags must correlate with the M16 assertion set and M15 vector replay expectations.

## Assertion Support

The M16 transition-capacity guard module supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_accepted_changes_within_lanes` | `accepted_changes <= REQUEST_LANES` |
| `assert_capacity_remaining_nonnegative` | `capacity_remaining >= 0` |
| `assert_capacity_remaining_bounded` | `capacity_remaining <= REQUEST_LANES` |
| `assert_capacity_exhausted_equivalence` | `capacity_exhausted = (accepted_changes == REQUEST_LANES)` |
| `assert_same_state_no_capacity_use` | same-state retention does not consume capacity |
| `assert_no_accept_on_tick_disable` | no transition is accepted when tick disabled |
| `assert_pending_not_cleared_on_capacity_reject` | rejected pending completion remains pending |
| `assert_no_direct_transition_on_capacity_exhaustion` | capacity exhaustion cannot authorize direct opposite transition |
| `assert_switch_load_bound` | `accepted_changes / CELLS <= transition_fraction` |
| `assert_capacity_guard_replay_deterministic` | same input sequence produces same capacity outputs |

## M15 Vector Replay Boundary

The transition-capacity guard must replay against the M15 deterministic vector package.

Comparison inputs:

`tick_enable`

`scheduler_state`

`request_accept_candidate`

`request_cell_index`

`transition_class`

`pending_completion_candidate`

`neutral_routed_candidate`

`state_q`

`state_candidate_d`

`REQUEST_LANES`

Comparison outputs:

`request_accept_capacity`

`request_reject_capacity`

`capacity_accept_mask`

`capacity_reject_mask`

`accepted_change_mask`

`accepted_changes`

`capacity_remaining`

`capacity_exhausted`

`switch_load_numerator`

`counter deltas`

`invariant flags`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 Capacity Invariants

The M16 transition-capacity guard is valid only if:

Accepted retained-state changes never exceed `REQUEST_LANES`.

Same-state retention does not consume capacity.

Capacity rejection does not alter retained state incorrectly.

Capacity rejection does not clear pending routes.

Capacity exhaustion does not authorize direct opposite-polarity transitions.

Pending-route completion remains capacity-bounded.

Active-neutral routing remains capacity-bounded.

Switch load remains bounded by `transition_fraction`.

Queue overflow events remain zero.

Direct opposite-polarity execution remains zero.

M15 vector replay remains deterministic.

## Closure Criteria

This transition-capacity guard module can be considered M16-ready when it supports:

- compile-time request-lane capacity relation;
- deterministic candidate ordering;
- accepted-change counting;
- capacity admission;
- capacity rejection;
- capacity exhaustion detection;
- capacity remaining output;
- switch-load numerator generation;
- pending-route capacity protection;
- active-neutral capacity protection;
- event-counter source generation;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

## Next Step

The next M16 file should define the retained-state update layer:

`docs/m16_retained_state_update_module.md`

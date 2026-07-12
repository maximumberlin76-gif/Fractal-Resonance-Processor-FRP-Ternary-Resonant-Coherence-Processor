# FRP M16 Pending Route Register Module

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the pending-route register module for the M16 RTL core realization layer.

The pending-route register module preserves the M15-qualified active-neutral routing semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 realizes the retained opposite-polarity transition contract in an explicit RTL-oriented pending-route register structure.

## Pending Route Boundary

The pending-route register module controls the retained continuation state for opposite-polarity requests that cannot be executed directly.

It covers:

- pending-route storage;
- pending-route creation;
- pending-route completion;
- pending-route clearing;
- pending-route polarity preservation;
- pending-route reserved-state detection;
- interaction with request-lane arbitration;
- interaction with scheduler-state eligibility;
- interaction with transition-capacity enforcement;
- event-counter source generation;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

The pending-route register module does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets.

## Core Identity Preserved

The pending-route register module preserves the required FRP route sequence:

`-1 → 0 → +1`

and:

`+1 → 0 → -1`

The module prevents direct retained-state execution of:

`-1 → +1`

and:

`+1 → -1`

Required invariant:

`actual_direct_events = 0`

## Canonical Pending-Route Encoding

Pending routes use the same canonical two-bit ternary encoding as retained state:

| Pending route | Encoding | Meaning |
|---|---|---|
| `-1` | `2'b11` | retained target is `-1` |
| `0` | `2'b00` | no pending route |
| `+1` | `2'b01` | retained target is `+1` |
| reserved | `2'b10` | invalid pending route |

The reserved encoding is invalid.

Required invariant:

`pending_route_reserved_events = 0`

## Register Set

The pending-route module uses:

| Register | Width | Meaning |
|---|---:|---|
| `pending_route_q` | `CELLS × STATE_BITS` | retained pending-route state |
| `pending_route_d` | `CELLS × STATE_BITS` | next pending-route state |
| `pending_created_mask` | `CELLS` | pending routes created during the tick |
| `pending_completed_mask` | `CELLS` | pending routes completed during the tick |
| `pending_cleared_mask` | `CELLS` | pending routes cleared during the tick |
| `pending_reserved_mask` | `CELLS` | cells containing reserved pending encoding |

Required relation:

`STATE_BITS = 2`

## Reset Behavior

On reset:

`pending_route_q = all 0`

This means:

`no pending routes exist after reset`

Required reset invariants:

`all pending routes = 0`

`pending_route_reserved_events = 0`

`actual_direct_events = 0`

`queue_overflow_events = 0`

## Pending Route Meaning

A pending route stores the retained target polarity of an opposite-polarity request that has already been neutralized through `0`.

If:

`pending_route_q_i = 0`

then cell `i` has no retained opposite-polarity continuation.

If:

`pending_route_q_i = -1`

then cell `i` must complete toward `-1` on a later eligible tick.

If:

`pending_route_q_i = +1`

then cell `i` must complete toward `+1` on a later eligible tick.

Required invariant:

`pending routes preserve requested target polarity`

## Pending Route Creation

A pending route is created only by an accepted opposite-polarity request.

If:

`state_q_i = -1`

and:

`request_target_i = +1`

then direct execution is forbidden.

The tick action is:

`state_d_i = 0`

and:

`pending_route_d_i = +1`

If:

`state_q_i = +1`

and:

`request_target_i = -1`

then direct execution is forbidden.

The tick action is:

`state_d_i = 0`

and:

`pending_route_d_i = -1`

Required relation:

`pending_route_d_i = request_target_i`

for an accepted opposite-polarity request.

## Pending Route Completion

A pending route may complete only when the retained state is active neutral `0`.

If:

`state_q_i = 0`

and:

`pending_route_q_i = -1`

then the eligible completion is:

`0 → -1`

and:

`pending_route_d_i = 0`

If:

`state_q_i = 0`

and:

`pending_route_q_i = +1`

then the eligible completion is:

`0 → +1`

and:

`pending_route_d_i = 0`

Completion remains subject to:

- scheduler eligibility;
- request-lane arbitration;
- transition-capacity boundary;
- deterministic lane order.

## Forbidden Completion

A pending route must not complete when the retained state is not `0`.

Forbidden examples:

`state_q_i = -1` and `pending_route_q_i = +1`

`state_q_i = +1` and `pending_route_q_i = -1`

The module must first preserve or restore the active-neutral boundary.

Required invariant:

`pending completion starts from 0`

## Pending Route Priority

Pending-route completion has priority over new same-cell requests.

For a cell `i`, if:

`pending_route_q_i != 0`

and:

`state_q_i = 0`

then the pending route is evaluated before a new request for the same cell.

A new same-cell request may be rejected or deferred.

Required invariant:

`retained pending route is not overwritten by a new request`

## Pending Route Non-Overwrite Rule

A valid pending route must not be overwritten by a different target polarity before completion.

If:

`pending_route_q_i = +1`

then a new same-cell request must not replace it with:

`-1`

If:

`pending_route_q_i = -1`

then a new same-cell request must not replace it with:

`+1`

Required invariant:

`pending route polarity remains stable until completion or reset`

## Pending Route Clearing

A pending route may be cleared only by:

- reset;
- successful pending-route completion;
- explicit counter-safe diagnostic clear, if separately defined by a higher-level test mode.

Normal processor execution clears a pending route only after completion.

Required relation:

`pending_completed_mask_i = 1 → pending_route_d_i = 0`

## Interaction With Request-Lane Arbitration

The request-lane arbitration module provides:

| Signal | Meaning |
|---|---|
| `request_accept` | accepted request lane |
| `request_cell_index` | requested cell index |
| `request_target` | requested ternary target |
| `request_neutralized` | accepted opposite-polarity request routed through `0` |
| `accepted_cell_mask` | accepted cells for this tick |

The pending-route module consumes these signals to create pending routes for accepted opposite-polarity requests.

Required invariant:

`pending route creation requires accepted request`

## Interaction With Scheduler State

Scheduler state may gate pending-route completion.

The scheduler must not erase pending-route polarity.

Pending-route completion may be eligible in:

- `free`;
- `commit`;
- `excite`;

Pending-route retention may occur in:

- `balance`;
- `neutralize`;
- any tick where completion is not eligible.

Required invariant:

`scheduler state does not modify pending polarity directly`

## Interaction With Transition Capacity

Pending-route completion counts as a retained-state change.

Therefore it contributes to:

`accepted_changes`

Required bound:

`accepted_changes <= REQUEST_LANES`

If transition capacity is exhausted, pending completion must be deferred without losing pending-route polarity.

Required invariant:

`capacity rejection does not clear pending route`

## Interaction With Active Neutral Routing

The pending-route module is the retained continuation layer of active-neutral routing.

For an opposite-polarity request:

`state_q_i × request_target_i = -1`

the route is split into two legal transitions:

First eligible tick:

`state_q_i → 0`

with:

`pending_route_d_i = request_target_i`

Later eligible tick:

`0 → pending_route_q_i`

with:

`pending_route_d_i = 0`

Required invariant:

`opposite-polarity transition is tick-separated`

## Reserved Pending-Route Detection

The module detects reserved pending-route encoding:

`2'b10`

Detection signals:

| Signal | Width | Meaning |
|---|---:|---|
| `pending_reserved_mask` | `CELLS` | one bit per cell with reserved pending encoding |
| `pending_reserved_any` | `1` | high when any pending route is reserved |

Required relation:

`pending_reserved_any = OR(pending_reserved_mask)`

Required invariant:

`pending_reserved_any = 0`

## Pending Route Counter Sources

The pending-route module provides counter sources for:

| Counter source | Meaning |
|---|---|
| `pending_created_events` | newly created pending routes |
| `pending_completed_events` | completed pending routes |
| `pending_cleared_events` | cleared pending routes |
| `pending_retained_events` | pending routes retained without completion |
| `pending_reserved_events` | reserved pending-route encoding observations |
| `neutral_routed_events` | opposite-polarity requests routed through `0` |
| `prevented_direct_events` | direct opposite-polarity executions prevented |
| `actual_direct_events` | direct opposite-polarity executions detected |

Required relations:

`neutral_routed_events >= pending_created_events`

`prevented_direct_events >= pending_created_events`

`actual_direct_events = 0`

`pending_reserved_events = 0`

## Pending Route Masks

The module exposes:

| Mask | Width | Meaning |
|---|---:|---|
| `pending_active_mask` | `CELLS` | cells with pending route |
| `pending_created_mask` | `CELLS` | cells creating pending route this tick |
| `pending_completed_mask` | `CELLS` | cells completing pending route this tick |
| `pending_retained_mask` | `CELLS` | cells retaining pending route this tick |
| `pending_blocked_mask` | `CELLS` | cells blocked by scheduler or capacity |
| `pending_reserved_mask` | `CELLS` | cells with invalid pending encoding |

Required relation:

`pending_active_count = popcount(pending_active_mask)`

## Pending Route Completion Target

The completion target is always:

`pending_route_q_i`

not a newly supplied request target.

This preserves the original requested polarity of the opposite-polarity request.

Required invariant:

`completion target equals retained pending route`

## Pending Route Determinism

For the same input sequence:

`state_q`

`request_target`

`pending_route_q`

`scheduler_state`

`request_lane_order`

`transition_capacity`

the module must produce the same:

`pending_route_d`

`pending_created_mask`

`pending_completed_mask`

`pending_retained_mask`

`pending counter deltas`

Required invariant:

`pending route replay is deterministic`

## Queue Overflow Semantics

The M16 pending-route module uses one retained pending-route slot per cell.

A queue overflow would occur only if the design attempted to store more than one pending target for the same cell without completing the existing pending route.

M16 must avoid this by rejecting or deferring new same-cell requests when a pending route already exists.

Required invariant:

`queue_overflow_events = 0`

## Pending Route Safety Rule

The pending-route module must never convert a retained pending route into a direct opposite-polarity state jump.

Forbidden:

`state_q_i = -1`

`pending_route_q_i = +1`

directly producing:

`state_d_i = +1`

Forbidden:

`state_q_i = +1`

`pending_route_q_i = -1`

directly producing:

`state_d_i = -1`

Required invariant:

`pending completion requires state_q_i = 0`

## Invariant Flags

The pending-route module exposes:

| Flag | Required value |
|---|---|
| `pending_domain_valid` | `True` |
| `pending_polarity_valid` | `True` |
| `pending_completion_from_zero_valid` | `True` |
| `pending_non_overwrite_valid` | `True` |
| `pending_capacity_valid` | `True` |
| `pending_replay_deterministic` | `True` |
| `no_pending_reserved_state` | `True` |
| `no_queue_overflow` | `True` |
| `no_actual_direct_events` | `True` |

These flags must correlate with the M16 assertion set and M15 vector replay expectations.

## Assertion Support

The M16 pending-route register module supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_no_reserved_pending_q` | `pending_route_q` contains no `2'b10` |
| `assert_no_reserved_pending_d` | `pending_route_d` contains no `2'b10` |
| `assert_pending_created_from_opposite_request` | pending creation follows accepted opposite-polarity request |
| `assert_pending_target_preserved` | pending route equals original requested polarity |
| `assert_pending_completion_from_zero` | pending completion starts from state `0` |
| `assert_pending_cleared_after_completion` | completed route clears pending register |
| `assert_pending_not_overwritten` | existing pending route is not replaced by another polarity |
| `assert_no_pending_queue_overflow` | one pending route per cell is never exceeded |
| `assert_pending_capacity_guard` | pending completion respects `REQUEST_LANES` |
| `assert_no_direct_completion_jump` | pending route never creates direct opposite-polarity jump |

## M15 Vector Replay Boundary

The pending-route module must replay against the M15 deterministic vector package.

Comparison inputs:

`state_q`

`target_q`

`pending_route_q`

`request_accept`

`request_cell_index`

`request_target`

`request_neutralized`

`scheduler_state`

`accepted_changes`

`REQUEST_LANES`

Comparison outputs:

`pending_route_d`

`pending_created_mask`

`pending_completed_mask`

`pending_retained_mask`

`pending_blocked_mask`

`pending_reserved_mask`

`pending counter deltas`

`invariant flags`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 Pending-Route Invariants

The M16 pending-route register module is valid only if:

Pending routes use canonical ternary encoding.

Reserved pending-route encoding is never valid.

Pending routes initialize to `0`.

Pending routes are created only by accepted opposite-polarity requests.

Pending routes preserve requested target polarity.

Pending routes complete only from active neutral state `0`.

Pending completion clears the pending route.

Existing pending routes are not overwritten before completion.

Capacity rejection does not clear pending routes.

Scheduler gating does not erase pending-route polarity.

Queue overflow events remain zero.

Direct opposite-polarity execution remains zero.

M15 vector replay remains deterministic.

## Closure Criteria

This pending-route register module can be considered M16-ready when it supports:

- reset to no pending routes;
- canonical pending-route encoding;
- reserved pending-route detection;
- pending-route creation;
- pending-route completion;
- pending-route clearing;
- pending-route non-overwrite protection;
- scheduler-gated retention;
- transition-capacity guarding;
- queue-overflow prevention;
- event-counter source generation;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

## Next Step

The next M16 file should define the active-neutral transition module:

`docs/m16_active_neutral_transition_module.md`

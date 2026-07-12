# FRP M16 Invariant Assertion Set

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the M16 invariant assertion set for the RTL core realization layer.

The assertion set preserves the M15-qualified execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 converts the already-qualified M15 semantic invariants into an RTL-facing assertion structure for module-level and core-level verification.

## Assertion Boundary

The M16 assertion set covers:

- canonical balanced ternary state-domain assertions;
- scheduler-state assertions;
- request-lane arbitration assertions;
- pending-route assertions;
- active-neutral transition assertions;
- transition-capacity assertions;
- retained-state update assertions;
- event-counter relation assertions;
- invariant-flag correlation assertions;
- M15 vector replay assertions;
- M16 closure assertions.

The assertion set does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets.

The assertion set verifies that the RTL core preserves the M15-qualified retained-state execution contract.

## Core Identity Preserved

The assertion set protects the FRP execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Required global invariant:

`actual_direct_events = 0`

Required global state-domain invariant:

`reserved_state_events = 0`

Required global queue invariant:

`queue_overflow_events = 0`

## Assertion Layers

The M16 assertion set is organized into the following layers:

1. state-domain assertions;
2. scheduler assertions;
3. request-lane assertions;
4. pending-route assertions;
5. active-neutral transition assertions;
6. transition-capacity assertions;
7. retained-state update assertions;
8. event-counter assertions;
9. invariant-flag assertions;
10. M15 vector replay assertions;
11. M16 closure assertions.

Each layer may be implemented as SystemVerilog assertions, simulation checks, trace validators, or deterministic replay checks.

## Canonical Ternary Encoding Assertions

M16 preserves the canonical two-bit ternary encoding:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The reserved encoding is invalid.

### `assert_state_q_domain`

Condition:

`state_q_i != 2'b10`

for every cell `i`.

Required result:

`PASS`

### `assert_state_d_domain`

Condition:

`state_d_i != 2'b10`

for every cell `i`.

Required result:

`PASS`

### `assert_state_out_domain`

Condition:

`state_out_i != 2'b10`

for every cell `i`.

Required result:

`PASS`

### `assert_target_domain`

Condition:

`target_q_i != 2'b10`

for every cell `i` during qualified replay.

Required result:

`PASS`

### `assert_pending_route_domain`

Condition:

`pending_route_q_i != 2'b10`

and:

`pending_route_d_i != 2'b10`

for every cell `i`.

Required result:

`PASS`

### Required state-domain relation

`reserved_state_events = 0`

## Reset Assertions

Reset establishes the active-neutral baseline.

### `assert_reset_state_to_neutral`

When reset is active:

`state_out_i = 0`

for every cell `i`.

Required result:

`PASS`

### `assert_reset_pending_to_zero`

When reset is active:

`pending_route_q_i = 0`

for every cell `i`.

Required result:

`PASS`

### `assert_reset_counters_to_zero`

When reset is active:

`ticks_recorded = 0`

`scheduler counters = 0`

`event counters = 0`

Required result:

`PASS`

### `assert_reset_no_reserved_state`

After reset:

`reserved_state_events = 0`

Required result:

`PASS`

## Tick-Enable Assertions

Tick execution advances only when:

`tick_enable = 1`

### `assert_tick_disable_holds_state`

When:

`tick_enable = 0`

then:

`state_d = state_q`

Required result:

`PASS`

### `assert_tick_disable_no_accepted_changes`

When:

`tick_enable = 0`

then:

`accepted_changes = 0`

Required result:

`PASS`

### `assert_tick_disable_scheduler_hold`

When:

`tick_enable = 0`

then scheduler counters do not advance.

Required result:

`PASS`

### `assert_tick_disable_no_pending_clear`

When:

`tick_enable = 0`

then pending routes are not cleared by execution.

Required result:

`PASS`

## Scheduler Assertions

M16 preserves three execution modes:

- `free`;
- `7/1`;
- `1/7`.

### `assert_valid_scheduler_mode`

Condition:

`scheduler_mode != reserved`

Required result:

`PASS`

### `assert_valid_scheduler_state`

Condition:

`scheduler_state` is one of:

- `free`;
- `balance`;
- `commit`;
- `excite`;
- `neutralize`.

Required result:

`PASS`

### `assert_onehot_scheduler_enable`

Exactly one scheduler-state enable is active per valid enabled tick.

Required relation:

`popcount(scheduler_state_enable_vector) = 1`

Required result:

`PASS`

### `assert_free_mode_profile`

For a run entirely in `free` mode:

`free_count = ticks_recorded`

Required inherited profile:

`16 ticks → free = 16`

Required result:

`PASS`

### `assert_7_1_mode_profile`

For a run entirely in `7/1` mode:

`commit_count = floor(ticks_recorded / 8)`

`balance_count = ticks_recorded - commit_count`

Required inherited profile:

`64 ticks → balance = 56, commit = 8`

Required result:

`PASS`

### `assert_1_7_mode_profile`

For a run entirely in `1/7` mode:

`excite_count = floor((ticks_recorded + 7) / 8)`

`neutralize_count = ticks_recorded - excite_count`

Required inherited profile:

`16 ticks → excite = 2, neutralize = 14`

Required result:

`PASS`

### `assert_scheduler_counts_sum`

Required relation:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

Required result:

`PASS`

### `assert_scheduler_no_direct_transition_authority`

No scheduler state may authorize:

`-1 → +1`

or:

`+1 → -1`

Required result:

`PASS`

## Request-Lane Arbitration Assertions

Request lanes are deterministic execution-control inputs.

### `assert_request_lane_order`

Request lanes are evaluated in ascending order:

`0 → REQUEST_LANES - 1`

Required result:

`PASS`

### `assert_request_cell_index_valid`

Every accepted request uses:

`request_cell_index < CELLS`

Required result:

`PASS`

### `assert_request_target_valid`

Every accepted request target is one of:

`2'b11`

`2'b00`

`2'b01`

Required result:

`PASS`

### `assert_request_target_not_reserved`

No accepted request target may be:

`2'b10`

Required result:

`PASS`

### `assert_one_accepted_request_per_cell`

At most one request may be accepted for a cell during one tick.

Required relation:

`accepted_cell_mask_i <= 1`

Required result:

`PASS`

### `assert_duplicate_cell_rejection`

If two valid request lanes target the same cell, only the lowest-numbered lane may be accepted.

Later same-cell lanes must be rejected.

Required result:

`PASS`

### `assert_no_request_accept_on_tick_disable`

When:

`tick_enable = 0`

then:

`request_accept = 0`

Required result:

`PASS`

### `assert_scheduler_gate_applied`

A request may be accepted only when its transition class is eligible under the current scheduler state.

Required result:

`PASS`

## Pending-Route Assertions

Pending routes preserve the deferred target polarity of an opposite-polarity request.

### `assert_pending_created_from_opposite_request`

A pending route may be created only when an accepted request is opposite-polarity.

Required condition:

`state_q_i × request_target_i = -1`

Required result:

`PASS`

### `assert_pending_target_preserved`

When a pending route is created:

`pending_route_d_i = request_target_i`

Required result:

`PASS`

### `assert_pending_completion_from_zero`

A pending route may complete only when:

`state_q_i = 0`

Required result:

`PASS`

### `assert_pending_completion_uses_pending_target`

Pending completion target must equal:

`pending_route_q_i`

not a new request target.

Required result:

`PASS`

### `assert_pending_cleared_after_completion`

After successful completion:

`pending_route_d_i = 0`

Required result:

`PASS`

### `assert_pending_not_overwritten`

An existing pending route must not be overwritten by a different polarity before completion.

Required result:

`PASS`

### `assert_pending_capacity_guard`

If capacity rejects pending completion, the pending route remains retained.

Required relation:

`capacity reject → pending_route_d_i = pending_route_q_i`

Required result:

`PASS`

### `assert_no_pending_queue_overflow`

One cell may not hold more than one pending route.

Required relation:

`queue_overflow_events = 0`

Required result:

`PASS`

### `assert_pending_domain_valid`

Pending-route encoding must never use:

`2'b10`

Required result:

`PASS`

## Active-Neutral Transition Assertions

Active neutral `0` is a functional routing state.

### `assert_no_direct_negative_to_positive`

Forbidden transition:

`-1 → +1`

Required relation:

`not(state_q_i = -1 and state_d_i = +1)`

Required result:

`PASS`

### `assert_no_direct_positive_to_negative`

Forbidden transition:

`+1 → -1`

Required relation:

`not(state_q_i = +1 and state_d_i = -1)`

Required result:

`PASS`

### `assert_opposite_request_routes_to_zero`

For accepted opposite-polarity request:

`state_d_i = 0`

Required result:

`PASS`

### `assert_negative_to_positive_route_sequence`

Required route:

`-1 → 0 → +1`

Direct route:

`-1 → +1`

must remain impossible.

Required result:

`PASS`

### `assert_positive_to_negative_route_sequence`

Required route:

`+1 → 0 → -1`

Direct route:

`+1 → -1`

must remain impossible.

Required result:

`PASS`

### `assert_zero_to_nonzero_starts_from_zero`

For transition:

`0 → ±1`

the previous retained state must be:

`0`

Required result:

`PASS`

### `assert_nonzero_to_zero_terminates_in_zero`

For transition:

`±1 → 0`

the next retained state must be:

`0`

Required result:

`PASS`

### `assert_pending_completion_not_direct_jump`

A pending route must not complete from a nonzero retained state.

Required result:

`PASS`

## Transition-Capacity Assertions

M16 preserves:

`transition_fraction = 0.25`

and:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

### `assert_request_lanes_profile_8`

For:

`CELLS = 8`

required:

`REQUEST_LANES = 2`

Required result:

`PASS`

### `assert_request_lanes_profile_16`

For:

`CELLS = 16`

required:

`REQUEST_LANES = 4`

Required result:

`PASS`

### `assert_request_lanes_profile_32`

For:

`CELLS = 32`

required:

`REQUEST_LANES = 8`

Required result:

`PASS`

### `assert_accepted_changes_within_lanes`

Required relation:

`accepted_changes <= REQUEST_LANES`

Required result:

`PASS`

### `assert_capacity_remaining_valid`

Required relation:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required result:

`PASS`

### `assert_capacity_remaining_nonnegative`

Required relation:

`capacity_remaining >= 0`

Required result:

`PASS`

### `assert_capacity_exhausted_equivalence`

Required relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

Required result:

`PASS`

### `assert_same_state_no_capacity_use`

Same-state retention must not increase:

`accepted_changes`

Required result:

`PASS`

### `assert_capacity_reject_preserves_state`

A capacity-rejected transition must not corrupt retained state.

Required result:

`PASS`

### `assert_capacity_reject_preserves_pending`

A capacity-rejected pending completion must not clear pending route.

Required result:

`PASS`

### `assert_capacity_exhaustion_no_direct_transition`

Capacity exhaustion cannot authorize:

`-1 → +1`

or:

`+1 → -1`

Required result:

`PASS`

### `assert_switch_load_bound`

Required relation:

`switch_load = accepted_changes / CELLS`

Required bound:

`switch_load <= transition_fraction`

Required result:

`PASS`

## Retained-State Update Assertions

The retained-state update layer commits only legal, capacity-approved transitions.

### `assert_writeback_requires_capacity`

A state-changing writeback requires capacity approval.

Required result:

`PASS`

### `assert_state_write_count_within_lanes`

Required relation:

`state_write_enable_count <= REQUEST_LANES`

Required result:

`PASS`

### `assert_state_write_mask_matches_change`

Required relation:

`state_write_enable_mask_i = 1`

only when:

`state_d_i != state_q_i`

Required result:

`PASS`

### `assert_state_hold_mask_valid`

If a cell is held:

`state_d_i = state_q_i`

Required result:

`PASS`

### `assert_reserved_candidate_not_committed`

A candidate state equal to:

`2'b10`

must not be committed.

Required result:

`PASS`

### `assert_neutral_routed_writeback_to_zero`

For active-neutral routed opposite-polarity request:

`state_d_i = 0`

Required result:

`PASS`

### `assert_pending_completion_writeback_from_zero`

For pending completion:

`state_q_i = 0`

Required result:

`PASS`

### `assert_state_output_not_reserved`

Output retained state must never contain:

`2'b10`

Required result:

`PASS`

## Event-Counter Assertions

Event counters must remain consistent with the execution trace.

### `assert_actual_direct_events_zero`

Required relation:

`actual_direct_events = 0`

Required result:

`PASS`

### `assert_reserved_state_events_zero`

Required relation:

`reserved_state_events = 0`

Required result:

`PASS`

### `assert_queue_overflow_events_zero`

Required relation:

`queue_overflow_events = 0`

Required result:

`PASS`

### `assert_prevented_direct_events_relation`

Required relation:

`prevented_direct_events >= requested_direct_events`

Required result:

`PASS`

### `assert_neutral_routed_events_relation`

Required relation:

`neutral_routed_events >= prevented_direct_events`

Required result:

`PASS`

### `assert_accepted_change_events_relation`

Required relation:

`accepted_change_events = sum(accepted_changes per tick)`

Required result:

`PASS`

### `assert_pending_created_relation`

Pending-created events must correspond to accepted opposite-polarity requests.

Required result:

`PASS`

### `assert_pending_completed_relation`

Pending-completed events must correspond to completions from active neutral `0`.

Required result:

`PASS`

## Invariant-Flag Assertions

Invariant flags are the compact replay-facing form of assertion status.

### `assert_state_domain_flag`

Required value:

`state_domain_valid = True`

Required result:

`PASS`

### `assert_scheduler_counts_flag`

Required value:

`scheduler_counts_valid = True`

Required result:

`PASS`

### `assert_request_lane_order_flag`

Required value:

`request_lane_order_valid = True`

Required result:

`PASS`

### `assert_pending_polarity_flag`

Required value:

`pending_polarity_valid = True`

Required result:

`PASS`

### `assert_active_neutral_flag`

Required value:

`active_neutral_routing_valid = True`

Required result:

`PASS`

### `assert_transition_capacity_flag`

Required value:

`transition_capacity_valid = True`

Required result:

`PASS`

### `assert_state_update_flag`

Required value:

`state_update_valid = True`

Required result:

`PASS`

### `assert_no_actual_direct_flag`

Required value:

`no_actual_direct_events = True`

Required result:

`PASS`

### `assert_no_reserved_state_flag`

Required value:

`no_reserved_state = True`

Required result:

`PASS`

### `assert_no_queue_overflow_flag`

Required value:

`no_queue_overflow = True`

Required result:

`PASS`

## M15 Vector Replay Assertions

M16 must remain replay-compatible with the M15 deterministic vector package.

### `assert_m15_state_replay_match`

M16 retained-state outputs must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_pending_replay_match`

M16 pending-route outputs must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_scheduler_replay_match`

M16 scheduler states and counters must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_request_replay_match`

M16 request-lane acceptance and rejection masks must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_transition_replay_match`

M16 transition masks must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_counter_replay_match`

M16 event-counter deltas must match the M15 cycle-exact integer golden trace.

Required result:

`PASS`

### `assert_m15_invariant_flag_replay_match`

M16 invariant flags must match the M15 replay expectations.

Required result:

`PASS`

## Module-Level Assertion Matrix

| Module | Required assertion group |
|---|---|
| `scheduler_state_rtl_realization` | scheduler assertions |
| `request_lane_arbitration_module` | request-lane assertions |
| `pending_route_register_module` | pending-route assertions |
| `active_neutral_transition_module` | active-neutral transition assertions |
| `transition_capacity_guard_module` | transition-capacity assertions |
| `retained_state_update_module` | retained-state update assertions |

Each module-level assertion group must pass independently before M16 core-level closure.

## Core-Level Assertion Matrix

The core-level assertion matrix requires:

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

## Required M16 Global Invariants

The M16 RTL core realization is valid only if:

Canonical ternary encoding is preserved.

Reserved state `2'b10` is never emitted as valid state.

Reset initializes retained state to active neutral `0`.

Tick-disabled cycles preserve retained state.

Scheduler profiles match `free`, `7/1`, and `1/7`.

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

## Closure Criteria

The M16 invariant assertion set can be considered ready when:

- every module-level assertion group is defined;
- every core-level assertion group is defined;
- all required M15 invariants are represented;
- assertion names are stable;
- invariant flags map to assertion groups;
- event-counter relations are defined;
- M15 vector replay assertions are defined;
- M16 closure assertions are explicit.

## Next Step

The next M16 file should define the M15 vector replay compatibility layer:

`docs/m16_m15_vector_replay_compatibility_report.md`

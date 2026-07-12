# FRP M16 Request-Lane Arbitration Module

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the request-lane arbitration module for the M16 RTL core realization layer.

The request-lane arbitration layer preserves the M15-qualified execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 realizes deterministic request acceptance, request rejection, transition-capacity enforcement, and request-order preservation for the M15-qualified retained-state transition contract.

## Arbitration Boundary

The request-lane arbitration module receives deterministic transition requests for the current tick.

It controls:

- request validity;
- request cell-index validity;
- request target validity;
- deterministic lane order;
- duplicate-cell request handling;
- scheduler-state eligibility;
- transition-capacity enforcement;
- accepted request masks;
- rejected request masks;
- neutral-routing request classification;
- event-counter source generation;
- M15 vector replay compatibility.

The arbitration module does not compute:

- Kuramoto-Sakaguchi phase coupling;
- phase words;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived target generation.

The upstream resonant computation layer remains responsible for generating the phase-derived ternary target vector.

## Core Identity Preserved

The request-lane arbitration module preserves the M16 execution chain:

`phase-derived ternary target`

→ `request-lane evaluation`

→ `deterministic lane arbitration`

→ `transition-capacity boundary`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

Request arbitration is therefore a deterministic execution-control layer, not a replacement for FRP resonant computation.

## Canonical Ternary Encoding

The arbitration module uses the inherited canonical ternary encoding:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The reserved encoding is invalid.

Required invariant:

`reserved_state_events = 0`

## Request-Lane Count

M16 preserves the M15 transition boundary:

`transition_fraction = 0.25`

The maximum accepted state changes per tick are:

`max_changes = max(1, round(CELLS × transition_fraction))`

The request-lane count is:

`REQUEST_LANES = max_changes`

Validated inherited profiles:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Request-Lane Inputs

The request-lane arbitration module consumes:

| Signal | Width | Meaning |
|---|---:|---|
| `request_valid` | `REQUEST_LANES` | valid flag per request lane |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | requested cell index per lane |
| `request_target` | `REQUEST_LANES × STATE_BITS` | requested ternary target per lane |
| `state_q` | `CELLS × STATE_BITS` | retained ternary state at tick start |
| `target_q` | `CELLS × STATE_BITS` | registered phase-derived target vector |
| `pending_route_q` | `CELLS × STATE_BITS` | retained pending-route vector |
| `scheduler_state` | scheduler-state width | current scheduler state |
| `tick_enable` | `1` | enables one processor tick |

Required relation:

`STATE_BITS = 2`

## Request-Lane Outputs

The arbitration module emits:

| Signal | Width | Meaning |
|---|---:|---|
| `request_accept` | `REQUEST_LANES` | accepted request lanes |
| `request_reject` | `REQUEST_LANES` | rejected request lanes |
| `request_reject_invalid_cell` | `REQUEST_LANES` | lane rejected due to invalid cell index |
| `request_reject_invalid_target` | `REQUEST_LANES` | lane rejected due to reserved target encoding |
| `request_reject_duplicate_cell` | `REQUEST_LANES` | lane rejected due to duplicate cell request |
| `request_reject_scheduler` | `REQUEST_LANES` | lane rejected due to scheduler ineligibility |
| `request_reject_capacity` | `REQUEST_LANES` | lane rejected due to transition-capacity boundary |
| `request_neutralized` | `REQUEST_LANES` | accepted request routed through active neutral `0` |
| `accepted_cell_mask` | `CELLS` | accepted cells for this tick |
| `rejected_cell_mask` | `CELLS` | rejected cells for this tick |
| `neutral_routed_cell_mask` | `CELLS` | cells routed through active neutral `0` |
| `accepted_changes` | counter width | number of accepted retained-state changes |

Required relation:

`request_accept & request_reject = 0`

for every lane.

## Deterministic Lane Order

Request lanes are evaluated in deterministic ascending lane order:

`lane 0`

→ `lane 1`

→ `lane 2`

→ `...`

→ `lane REQUEST_LANES - 1`

A lower-numbered valid lane has priority over a higher-numbered valid lane when both target the same cell.

Required invariant:

`request-lane order is deterministic`

## Cell-Index Validity

A request cell index is valid only when:

`request_cell_index < CELLS`

If:

`request_cell_index >= CELLS`

then:

`request_reject_invalid_cell = 1`

and:

`request_accept = 0`

Invalid cell-index requests must not alter:

- retained state;
- pending-route state;
- event counters related to accepted changes;
- active-neutral routing state.

## Target Validity

A request target is valid only when its encoding is one of:

`2'b11`

`2'b00`

`2'b01`

A request target is invalid when its encoding is:

`2'b10`

If:

`request_target = 2'b10`

then:

`request_reject_invalid_target = 1`

and:

`request_accept = 0`

Required invariant:

`reserved target encodings are never accepted`

## Duplicate-Cell Handling

If multiple valid request lanes target the same cell during the same tick, only the first valid lane in ascending lane order may be accepted.

All later lanes targeting the same cell must be rejected as duplicate-cell requests.

Required relation:

`accepted_cell_mask[cell]` may be set by at most one lane per tick.

Required invariant:

`one accepted request per cell per tick`

## Tick-Enable Gating

If:

`tick_enable = 0`

then:

`request_accept = 0`

`request_reject = 0`

`accepted_changes = 0`

No request may alter retained-state or pending-route state while tick execution is disabled.

Required invariant:

`tick_enable = 0 → no accepted request`

## Scheduler Eligibility

The scheduler provides temporal eligibility for request acceptance.

The arbitration module must preserve the scheduler semantics defined by M16:

- `free`;
- `balance`;
- `commit`;
- `excite`;
- `neutralize`.

The scheduler may gate whether a request is eligible for accepted retained-state update during the current tick.

The scheduler must not reorder request lanes.

Required invariant:

`scheduler state must not alter lane ordering`

## Free-State Arbitration

In `free` scheduler state, the arbitration module may accept eligible requests for:

- pending-route completion;
- zero-to-nonzero target release;
- nonzero-to-zero neutralization;
- opposite-polarity active-neutral routing;
- unchanged-state retention.

The transition-capacity boundary still applies.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Balance-State Arbitration

In `balance` scheduler state, the arbitration module preserves the balance phase of `7/1` execution.

Balance-state arbitration may accept eligible requests for:

- nonzero-to-zero neutralization;
- active-neutral routing of opposite-polarity requests;
- unchanged-state retention;
- pending-route retention.

Commit release remains controlled by the commit state.

Required invariant:

`actual_direct_events = 0`

## Commit-State Arbitration

In `commit` scheduler state, the arbitration module may accept eligible commit-capable requests for:

- pending-route completion;
- zero-to-nonzero target release;
- retained-state update;
- event-counter emission.

The transition-capacity boundary still applies.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Excite-State Arbitration

In `excite` scheduler state, the arbitration module may accept eligible excitation requests for:

- zero-to-nonzero target release;
- nonzero target acceptance;
- pending-route completion when eligible;
- event-counter emission.

Required invariant:

`switch_load_peak <= transition_fraction`

## Neutralize-State Arbitration

In `neutralize` scheduler state, the arbitration module may accept eligible neutralization requests for:

- nonzero-to-zero neutralization;
- active-neutral routing of opposite-polarity requests;
- pending-route retention;
- unchanged-state retention.

Required invariant:

`actual_direct_events = 0`

## Request Classification

For each valid request lane, the arbitration module classifies the request using:

`state_q_i`

`request_target_i`

`pending_route_q_i`

where `i` is the requested cell index.

Classification types:

| Classification | Condition |
|---|---|
| `same_state` | `state_q_i = request_target_i` |
| `zero_to_nonzero` | `state_q_i = 0` and `request_target_i != 0` |
| `nonzero_to_zero` | `state_q_i != 0` and `request_target_i = 0` |
| `opposite_polarity` | `state_q_i × request_target_i = -1` |
| `pending_completion` | `state_q_i = 0` and `pending_route_q_i != 0` |
| `invalid_reserved` | any operand contains reserved encoding |

Reserved encodings are blocked before transition acceptance.

## Same-State Request

If:

`state_q_i = request_target_i`

then the request does not require a retained-state change.

The request may be treated as accepted for deterministic replay metadata, but it must not increase:

`accepted_changes`

No pending route is created.

No neutral-routing event is counted.

## Zero-to-Nonzero Request

If:

`state_q_i = 0`

and:

`request_target_i = -1 or +1`

then the request is eligible as:

`0 → request_target_i`

This is valid because the transition starts from active neutral state `0`.

## Nonzero-to-Zero Request

If:

`state_q_i = -1 or +1`

and:

`request_target_i = 0`

then the request is eligible as:

`state_q_i → 0`

This is valid because the transition terminates in active neutral state `0`.

## Opposite-Polarity Request

If:

`state_q_i = -1`

and:

`request_target_i = +1`

then direct execution is forbidden.

The accepted routed action is:

`-1 → 0`

and:

`pending_route_d_i = +1`

If:

`state_q_i = +1`

and:

`request_target_i = -1`

then direct execution is forbidden.

The accepted routed action is:

`+1 → 0`

and:

`pending_route_d_i = -1`

Required invariant:

`actual_direct_events = 0`

## Pending-Completion Request

If:

`state_q_i = 0`

and:

`pending_route_q_i = -1 or +1`

then pending completion may be accepted as:

`0 → pending_route_q_i`

and:

`pending_route_d_i = 0`

Pending completion remains subject to:

- scheduler eligibility;
- deterministic lane order;
- transition-capacity boundary.

## Pending-Completion Priority

Pending-route completion has priority over a new request for the same cell.

If a cell has:

`pending_route_q_i != 0`

and also receives a new valid request lane, the pending-route completion is evaluated first.

A new request for that cell may be rejected or deferred.

Required invariant:

`pending routes preserve requested target polarity`

## Transition-Capacity Boundary

The arbitration module enforces:

`accepted_changes <= REQUEST_LANES`

A retained-state change counts toward `accepted_changes` when the cell state changes during the tick.

Same-state retention does not increase `accepted_changes`.

Rejected lanes must not increase `accepted_changes`.

Required relation:

`accepted_changes = popcount(accepted_change_mask)`

## Capacity Rejection

If accepting a valid request would cause:

`accepted_changes > REQUEST_LANES`

then the lane must be rejected:

`request_reject_capacity = 1`

and:

`request_accept = 0`

Required invariant:

`queue_overflow_events = 0`

Capacity rejection is not a queue overflow when the request is cleanly rejected and no invalid state is produced.

## Active-Neutral Routing Preservation

The arbitration module must preserve mandatory active-neutral routing.

Forbidden direct executions:

`-1 → +1`

`+1 → -1`

Allowed routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required relation:

`request_neutralized = 1`

for accepted opposite-polarity requests routed through `0`.

Required invariant:

`actual_direct_events = 0`

## Request Acceptance Conditions

A request lane may be accepted only if all required conditions hold:

- `tick_enable = 1`;
- request lane is valid;
- requested cell index is valid;
- requested target encoding is valid;
- request is not a duplicate-cell request;
- scheduler state allows the request class;
- transition-capacity boundary is not exceeded;
- request does not require a direct opposite-polarity transition;
- reserved encodings are not present.

## Request Rejection Conditions

A request lane must be rejected if any condition holds:

- `tick_enable = 0`;
- request lane is invalid;
- requested cell index is outside `CELLS`;
- requested target is reserved encoding `2'b10`;
- requested cell was already accepted by an earlier lane;
- scheduler state rejects the request class;
- transition-capacity boundary would be exceeded;
- request would produce an invalid retained state;
- request would produce a direct opposite-polarity transition.

## Event Counter Sources

The arbitration module provides counter sources for:

| Counter source | Meaning |
|---|---|
| `requested_lane_events` | valid request lanes observed |
| `accepted_lane_events` | request lanes accepted |
| `rejected_lane_events` | request lanes rejected |
| `rejected_invalid_cell_events` | invalid cell-index rejections |
| `rejected_invalid_target_events` | reserved target rejections |
| `rejected_duplicate_cell_events` | duplicate-cell rejections |
| `rejected_scheduler_events` | scheduler-gated rejections |
| `rejected_capacity_events` | transition-capacity rejections |
| `requested_direct_events` | opposite-polarity requests observed |
| `prevented_direct_events` | opposite-polarity direct executions prevented |
| `neutral_routed_events` | opposite-polarity requests routed through `0` |
| `accepted_change_events` | accepted retained-state changes |

Required inherited relations:

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

`actual_direct_events = 0`

## Arbitration Invariant Flags

The arbitration module exposes invariant flags:

| Flag | Required value |
|---|---|
| `request_lane_order_valid` | `True` |
| `request_cell_domain_valid` | `True` |
| `request_target_domain_valid` | `True` |
| `duplicate_cell_guard_valid` | `True` |
| `scheduler_gate_valid` | `True` |
| `transition_capacity_valid` | `True` |
| `active_neutral_routing_valid` | `True` |
| `no_actual_direct_events` | `True` |
| `no_queue_overflow` | `True` |

These flags must correlate with the M16 assertion set and M15 vector replay expectations.

## Assertion Support

The M16 request-lane arbitration module supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_valid_request_cell_index` | accepted requests use valid cell indexes |
| `assert_valid_request_target` | accepted targets are not reserved |
| `assert_deterministic_lane_order` | lower lanes have priority |
| `assert_one_request_per_cell` | at most one accepted request per cell per tick |
| `assert_capacity_not_exceeded` | `accepted_changes <= REQUEST_LANES` |
| `assert_no_accept_on_tick_disable` | no request accepted when tick disabled |
| `assert_scheduler_gate_applied` | scheduler eligibility is enforced |
| `assert_no_direct_opposite_transition` | no `-1 → +1` or `+1 → -1` execution |
| `assert_neutralized_direct_request` | opposite-polarity requests are routed through `0` |
| `assert_pending_priority` | pending completion is evaluated before new same-cell request |

## M15 Vector Replay Boundary

The request-lane arbitration module must replay against the M15 deterministic vector package.

Comparison inputs:

`request_valid`

`request_cell_index`

`request_target`

`state_q`

`target_q`

`pending_route_q`

`scheduler_state`

`tick_enable`

Comparison outputs:

`request_accept`

`request_reject`

`request_neutralized`

`accepted_cell_mask`

`rejected_cell_mask`

`neutral_routed_cell_mask`

`accepted_changes`

`counter deltas`

`invariant flags`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 Arbitration Invariants

The M16 request-lane arbitration module is valid only if:

Request lanes are processed in deterministic ascending order.

Invalid cell indexes are rejected.

Reserved target encodings are rejected.

Duplicate-cell requests are rejected after the first accepted lane.

Scheduler state gates request eligibility without reordering lanes.

Accepted changes never exceed `REQUEST_LANES`.

Capacity rejection does not produce queue overflow.

Opposite-polarity requests are routed through active neutral `0`.

Direct opposite-polarity execution remains zero.

Pending-route polarity is preserved.

M15 vector replay remains deterministic.

## Closure Criteria

This arbitration module can be considered M16-ready when it supports:

- deterministic request-lane ordering;
- request cell-index validation;
- request target validation;
- duplicate-cell guarding;
- scheduler-state eligibility;
- pending-route priority;
- active-neutral routing classification;
- transition-capacity enforcement;
- accepted and rejected request masks;
- event-counter source generation;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

## Next Step

The next M16 file should define the pending-route register layer:

`docs/m16_pending_route_register_module.md`

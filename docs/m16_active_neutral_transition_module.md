# FRP M16 Active Neutral Transition Module

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the active-neutral transition module for the M16 RTL core realization layer.

The active-neutral transition module preserves the M15-qualified transition semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new processor model.

M16 realizes the qualified retained-state transition law in an explicit RTL-oriented transition module.

## Active Neutral Boundary

The active-neutral transition module controls the legal retained-state transition path between ternary states.

It covers:

- canonical ternary state decoding;
- legal transition classification;
- direct opposite-polarity prevention;
- active-neutral routing through `0`;
- pending-route creation trigger;
- pending-route completion trigger;
- retained-state next-value generation;
- transition event masks;
- direct-transition detection;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

The module does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary target generation.

## Core Identity Preserved

The active-neutral transition module preserves the central FRP retained-state rule:

Opposite-polarity transitions are never executed directly.

Forbidden direct transitions:

`-1 → +1`

`+1 → -1`

Required routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

## Canonical Ternary Encoding

The module uses the inherited canonical two-bit ternary encoding:

| Ternary state | Encoding | Meaning |
|---|---|---|
| `-1` | `2'b11` | negative retained polarity |
| `0` | `2'b00` | active neutral state |
| `+1` | `2'b01` | positive retained polarity |
| reserved | `2'b10` | invalid state |

The reserved encoding is invalid.

Required invariant:

`reserved_state_events = 0`

## Module Inputs

The active-neutral transition module consumes:

| Signal | Width | Meaning |
|---|---:|---|
| `state_q` | `CELLS × STATE_BITS` | retained ternary state at tick start |
| `request_target` | `REQUEST_LANES × STATE_BITS` | requested ternary target per lane |
| `request_accept` | `REQUEST_LANES` | accepted request lanes |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | accepted request cell indexes |
| `pending_route_q` | `CELLS × STATE_BITS` | retained pending-route state |
| `pending_completion_enable` | `CELLS` | pending completion eligibility mask |
| `scheduler_state` | scheduler-state width | current scheduler state |
| `tick_enable` | `1` | enables one processor tick |

Required relation:

`STATE_BITS = 2`

## Module Outputs

The active-neutral transition module emits:

| Signal | Width | Meaning |
|---|---:|---|
| `state_d` | `CELLS × STATE_BITS` | next retained ternary state |
| `transition_valid_mask` | `CELLS` | cells with valid legal transition |
| `same_state_mask` | `CELLS` | cells retaining same state |
| `zero_to_nonzero_mask` | `CELLS` | cells executing `0 → ±1` |
| `nonzero_to_zero_mask` | `CELLS` | cells executing `±1 → 0` |
| `opposite_polarity_mask` | `CELLS` | cells with opposite-polarity request |
| `neutral_routed_mask` | `CELLS` | cells routed through active neutral `0` |
| `pending_completion_mask` | `CELLS` | cells completing pending route |
| `actual_direct_mask` | `CELLS` | cells with detected direct opposite-polarity transition |
| `reserved_transition_mask` | `CELLS` | cells blocked due to reserved encoding |

Required invariant:

`actual_direct_mask = 0`

## Transition Classification

For each cell `i`, the module classifies the relation between:

`state_q_i`

and the selected target for that cell.

The selected target may be:

- accepted request target;
- retained pending-route target;
- active neutral target;
- retained current state.

Transition classes:

| Transition class | Condition |
|---|---|
| `same_state` | `state_q_i = selected_target_i` |
| `zero_to_nonzero` | `state_q_i = 0` and `selected_target_i != 0` |
| `nonzero_to_zero` | `state_q_i != 0` and `selected_target_i = 0` |
| `opposite_polarity` | `state_q_i × selected_target_i = -1` |
| `pending_completion` | `state_q_i = 0` and `pending_route_q_i != 0` |
| `reserved_transition` | state or target contains `2'b10` |

Reserved encodings are never legal transition operands.

## Same-State Transition

If:

`state_q_i = selected_target_i`

then:

`state_d_i = state_q_i`

No retained-state change occurs.

No pending route is created.

No active-neutral routing event is counted.

No direct-transition event is counted.

## Neutral Release Transition

If:

`state_q_i = 0`

and:

`selected_target_i = -1 or +1`

then the legal transition is:

`0 → selected_target_i`

This transition is valid because it starts from active neutral state `0`.

Required relation:

`zero_to_nonzero_mask_i = 1`

## Neutralization Transition

If:

`state_q_i = -1 or +1`

and:

`selected_target_i = 0`

then the legal transition is:

`state_q_i → 0`

This transition is valid because it terminates in active neutral state `0`.

Required relation:

`nonzero_to_zero_mask_i = 1`

## Opposite-Polarity Transition Request

If:

`state_q_i = -1`

and:

`selected_target_i = +1`

then direct execution is forbidden.

The legal tick action is:

`state_d_i = 0`

and the requested target must be retained by the pending-route module as:

`pending_route_d_i = +1`

If:

`state_q_i = +1`

and:

`selected_target_i = -1`

then direct execution is forbidden.

The legal tick action is:

`state_d_i = 0`

and the requested target must be retained by the pending-route module as:

`pending_route_d_i = -1`

Required relation:

`neutral_routed_mask_i = 1`

Required invariant:

`actual_direct_events = 0`

## Pending Route Completion Transition

If:

`state_q_i = 0`

and:

`pending_route_q_i = -1 or +1`

and:

`pending_completion_enable_i = 1`

then the legal transition is:

`0 → pending_route_q_i`

and the pending-route module clears:

`pending_route_d_i = 0`

Pending completion remains subject to:

- scheduler eligibility;
- request-lane arbitration;
- transition-capacity boundary.

Required relation:

`pending_completion_mask_i = 1`

## Forbidden Pending Completion

A pending route must not complete from a nonzero retained state.

Forbidden:

`state_q_i = -1`

and:

`pending_route_q_i = +1`

directly producing:

`state_d_i = +1`

Forbidden:

`state_q_i = +1`

and:

`pending_route_q_i = -1`

directly producing:

`state_d_i = -1`

Required invariant:

`pending completion starts from 0`

## Direct Transition Detection

The module must detect any illegal direct opposite-polarity transition attempt.

Detected direct transitions:

`state_q_i = -1` and `state_d_i = +1`

`state_q_i = +1` and `state_d_i = -1`

Required detection output:

`actual_direct_mask_i = 1`

Required qualified value:

`actual_direct_mask_i = 0`

Required invariant:

`actual_direct_events = 0`

## Reserved Transition Guard

A transition is invalid if any participating encoded value is:

`2'b10`

The module must reject or block transitions involving reserved encodings.

Reserved operands include:

- retained state;
- selected target;
- pending route;
- request target.

Required relation:

`reserved_transition_mask_i = 1`

when any participating value is reserved.

Required invariant:

`reserved_state_events = 0`

## Selected Target Priority

The active-neutral transition module uses deterministic selected-target priority:

1. reset target;
2. pending-route completion target;
3. accepted request target;
4. active neutral routing target;
5. retained current state.

Priority relation:

`pending-route completion` precedes `new accepted request`

This preserves deterministic continuation of already-retained opposite-polarity routes.

## State Next-Value Generation

For each cell `i`, `state_d_i` is generated according to legal transition class:

| Condition | `state_d_i` |
|---|---|
| reset | `0` |
| reserved transition | `state_q_i` or safe `0`, according to higher-level guard |
| pending completion from `0` | `pending_route_q_i` |
| same state | `state_q_i` |
| `0 → ±1` | `selected_target_i` |
| `±1 → 0` | `0` |
| opposite-polarity request | `0` |
| no eligible transition | `state_q_i` |

The qualified replay path must never emit reserved encoding.

Required invariant:

`state_d_i != 2'b10`

## Tick-Enable Behavior

If:

`tick_enable = 0`

then:

`state_d = state_q`

No transition masks may indicate accepted retained-state change.

Required relation:

`tick_enable = 0 → accepted_changes = 0`

Required invariant:

`tick_enable = 0 → no retained-state transition`

## Scheduler Interaction

The scheduler provides temporal eligibility.

The active-neutral transition module must preserve legal transition rules in every scheduler state.

Forbidden transitions remain forbidden in:

- `free`;
- `balance`;
- `commit`;
- `excite`;
- `neutralize`.

Required invariant:

`scheduler state cannot authorize direct opposite-polarity transition`

## Free-State Transition Behavior

In `free` scheduler state, legal transitions may include:

- pending-route completion;
- `0 → ±1`;
- `±1 → 0`;
- opposite-polarity routing through `0`;
- same-state retention.

The transition-capacity boundary still applies.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Balance-State Transition Behavior

In `balance` scheduler state, legal transitions may include:

- same-state retention;
- `±1 → 0`;
- opposite-polarity routing through `0`;
- pending-route retention.

Commit release is deferred to commit-eligible states.

Required invariant:

`actual_direct_events = 0`

## Commit-State Transition Behavior

In `commit` scheduler state, legal transitions may include:

- pending-route completion;
- `0 → ±1`;
- accepted retained-state update;
- same-state retention.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Excite-State Transition Behavior

In `excite` scheduler state, legal transitions may include:

- `0 → ±1`;
- pending-route completion when eligible;
- nonzero target acceptance;
- same-state retention.

Required invariant:

`switch_load_peak <= transition_fraction`

## Neutralize-State Transition Behavior

In `neutralize` scheduler state, legal transitions may include:

- `±1 → 0`;
- opposite-polarity routing through `0`;
- pending-route retention;
- same-state retention.

Required invariant:

`actual_direct_events = 0`

## Transition Event Sources

The active-neutral transition module provides counter sources for:

| Counter source | Meaning |
|---|---|
| `same_state_events` | cells retaining the same state |
| `zero_to_nonzero_events` | legal `0 → ±1` transitions |
| `nonzero_to_zero_events` | legal `±1 → 0` transitions |
| `requested_direct_events` | opposite-polarity requests observed |
| `prevented_direct_events` | direct opposite-polarity transitions prevented |
| `neutral_routed_events` | opposite-polarity requests routed through `0` |
| `pending_completion_events` | pending routes completed from `0` |
| `actual_direct_events` | illegal direct opposite-polarity executions detected |
| `reserved_transition_events` | reserved operand transitions detected |
| `accepted_change_events` | retained-state changes accepted |

Required inherited relations:

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

`actual_direct_events = 0`

`reserved_transition_events = 0`

## Accepted Change Relation

A retained-state change occurs when:

`state_d_i != state_q_i`

The accepted-change mask is:

`accepted_change_mask_i = 1`

when the transition is legal and the retained state changes.

Required relation:

`accepted_changes = popcount(accepted_change_mask)`

Required bound:

`accepted_changes <= REQUEST_LANES`

## Switch Load Relation

The transition module provides the numerator for switch-load calculation:

`accepted_changes`

The inherited relation is:

`switch_load = accepted_changes / CELLS`

Required bound:

`switch_load_peak <= transition_fraction`

## Active Neutral Route Determinism

For the same input sequence:

`state_q`

`selected_target`

`pending_route_q`

`request_accept`

`scheduler_state`

`transition_capacity`

the module must produce the same:

`state_d`

`transition masks`

`event counter deltas`

`invariant flags`

Required invariant:

`active-neutral transition replay is deterministic`

## Invariant Flags

The active-neutral transition module exposes:

| Flag | Required value |
|---|---|
| `transition_domain_valid` | `True` |
| `active_neutral_routing_valid` | `True` |
| `pending_completion_from_zero_valid` | `True` |
| `no_reserved_transition` | `True` |
| `no_actual_direct_events` | `True` |
| `transition_capacity_valid` | `True` |
| `state_output_domain_valid` | `True` |
| `transition_replay_deterministic` | `True` |

These flags must correlate with the M16 assertion set and M15 vector replay expectations.

## Assertion Support

The M16 active-neutral transition module supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_no_reserved_state_operand` | transition operands do not contain `2'b10` |
| `assert_no_reserved_state_output` | `state_d` does not contain `2'b10` |
| `assert_no_direct_negative_to_positive` | no `-1 → +1` retained transition |
| `assert_no_direct_positive_to_negative` | no `+1 → -1` retained transition |
| `assert_opposite_request_routes_to_zero` | opposite-polarity request produces `state_d = 0` |
| `assert_pending_completion_from_zero` | pending route completes only from `0` |
| `assert_pending_target_used_for_completion` | completion target equals retained pending route |
| `assert_tick_disable_holds_state` | `tick_enable = 0` preserves `state_q` |
| `assert_scheduler_cannot_authorize_direct_transition` | no scheduler state permits direct opposite transition |
| `assert_capacity_not_exceeded` | `accepted_changes <= REQUEST_LANES` |

## M15 Vector Replay Boundary

The active-neutral transition module must replay against the M15 deterministic vector package.

Comparison inputs:

`state_q`

`request_target`

`request_accept`

`request_cell_index`

`pending_route_q`

`pending_completion_enable`

`scheduler_state`

`tick_enable`

`REQUEST_LANES`

Comparison outputs:

`state_d`

`same_state_mask`

`zero_to_nonzero_mask`

`nonzero_to_zero_mask`

`opposite_polarity_mask`

`neutral_routed_mask`

`pending_completion_mask`

`actual_direct_mask`

`reserved_transition_mask`

`accepted_change_mask`

`counter deltas`

`invariant flags`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 Active-Neutral Invariants

The M16 active-neutral transition module is valid only if:

Canonical ternary encoding is preserved.

Reserved transition operands are rejected or blocked.

Reserved state output is never emitted.

Same-state retention produces no retained-state change.

Neutral release starts from `0`.

Neutralization terminates in `0`.

Opposite-polarity requests are routed through `0`.

Pending routes complete only from `0`.

Direct opposite-polarity execution remains zero.

Accepted changes never exceed `REQUEST_LANES`.

Switch load remains bounded by `transition_fraction`.

M15 vector replay remains deterministic.

## Closure Criteria

This active-neutral transition module can be considered M16-ready when it supports:

- canonical ternary transition decoding;
- legal same-state retention;
- legal `0 → ±1` release;
- legal `±1 → 0` neutralization;
- forbidden direct opposite-polarity transition blocking;
- active-neutral route generation;
- pending-route completion from `0`;
- direct-transition detection;
- reserved-transition detection;
- accepted-change mask generation;
- event-counter source generation;
- invariant flag generation;
- assertion correlation;
- M15 vector replay compatibility.

## Next Step

The next M16 file should define the transition-capacity guard module:

`docs/m16_transition_capacity_guard_module.md`

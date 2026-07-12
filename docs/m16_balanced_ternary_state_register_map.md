# FRP M16 Balanced Ternary State Register Map

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the balanced ternary state-register map for the M16 RTL core realization layer.

The register map preserves the M15-qualified retained-state semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not redefine the FRP computational model.

M16 maps the qualified retained-state execution contract into an explicit RTL-oriented register structure.

## Register-Map Boundary

The M16 balanced ternary state-register map covers:

- retained ternary state registers;
- phase-derived target input registers;
- pending-route registers;
- transition-intent masks;
- neutral-routing masks;
- accepted-change masks;
- reserved-state detection;
- state-domain invariant flags;
- M15-compatible state-output comparison.

The register map is the retained-state memory boundary of the RTL core.

It is not the upstream resonant phase-computation layer.

## Canonical Ternary Encoding

M16 preserves the canonical M15 two-bit ternary encoding:

| Ternary state | Encoding | Meaning |
|---|---|---|
| `-1` | `2'b11` | negative retained polarity |
| `0` | `2'b00` | active neutral state |
| `+1` | `2'b01` | positive retained polarity |
| reserved | `2'b10` | invalid state |

The reserved encoding is never valid.

Required invariant:

`reserved_state_events = 0`

## Register Widths

Each processor cell uses:

`STATE_BITS = 2`

For `CELLS` processor cells:

`PACKED_STATE_BITS = CELLS × STATE_BITS`

Validated inherited M15 profiles:

| Cells | State bits per cell | Packed state width |
|---|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `2` | `32 bits` |
| `32` | `2` | `64 bits` |

## Packed State Layout

The packed retained-state vector is ordered by cell index.

For cell `i`:

`state_i = state_vector[(2 × i) +: 2]`

Cell `0` occupies the least significant two-bit field.

Cell `CELLS - 1` occupies the most significant two-bit field.

Required layout relation:

| Cell index | Bit slice |
|---:|---|
| `0` | `[1:0]` |
| `1` | `[3:2]` |
| `2` | `[5:4]` |
| `i` | `[(2 × i) + 1 : (2 × i)]` |
| `CELLS - 1` | `[(2 × CELLS) - 1 : (2 × CELLS) - 2]` |

## Core State Register Bank

The M16 state register bank contains:

| Register | Width | Meaning |
|---|---:|---|
| `state_q` | `PACKED_STATE_BITS` | retained ternary state at tick start |
| `state_d` | `PACKED_STATE_BITS` | next retained ternary state |
| `target_q` | `PACKED_STATE_BITS` | registered phase-derived ternary target |
| `pending_route_q` | `PACKED_STATE_BITS` | retained pending opposite-polarity route |
| `pending_route_d` | `PACKED_STATE_BITS` | next pending-route state |

The committed retained state after a tick is:

`state_q <= state_d`

The committed pending-route state after a tick is:

`pending_route_q <= pending_route_d`

## Reset State

On reset:

`state_q = all 0`

`pending_route_q = all 0`

`target_q = all 0`

This means every cell starts in the active neutral state:

`0`

Required reset invariants:

`all retained states = 0`

`all pending routes = 0`

`reserved_state_events = 0`

`actual_direct_events = 0`

## State-Domain Validity

A retained-state cell is valid only when its encoding is one of:

`2'b11`

`2'b00`

`2'b01`

A retained-state cell is invalid when its encoding is:

`2'b10`

The state-register map exposes a reserved-state detection mask:

| Signal | Width | Meaning |
|---|---:|---|
| `reserved_state_mask` | `CELLS` | one bit per cell indicating reserved encoding |
| `reserved_state_any` | `1` | high when any cell contains reserved encoding |

Required relation:

`reserved_state_any = OR(reserved_state_mask)`

Required invariant:

`reserved_state_any = 0`

## Target Register Semantics

The target register holds the phase-derived ternary target vector generated upstream.

M16 consumes:

`target_q`

M16 does not redefine the target-generation rule.

Inherited M15 target rule:

`target_i = +1`, when `sin(phase_i) > 0.33`

`target_i = -1`, when `sin(phase_i) < -0.33`

`target_i = 0`, otherwise.

The state-register map treats `target_q` as deterministic input for the current tick.

## Pending-Route Register Semantics

The pending-route register stores the retained target polarity for an opposite-polarity route that must pass through active neutral state `0`.

Pending-route encoding:

| Pending value | Encoding | Meaning |
|---|---|---|
| `-1` | `2'b11` | retained target is `-1` |
| `0` | `2'b00` | no pending route |
| `+1` | `2'b01` | retained target is `+1` |
| reserved | `2'b10` | invalid pending-route state |

Required invariant:

`pending_route_q` must never contain `2'b10`.

## Transition Classification

For each cell `i`, M16 classifies the relation between:

`state_q_i`

and:

`target_q_i`

The classification mask bank contains:

| Mask | Width | Meaning |
|---|---:|---|
| `same_state_mask` | `CELLS` | `state_q_i = target_q_i` |
| `zero_to_nonzero_mask` | `CELLS` | `state_q_i = 0` and `target_q_i != 0` |
| `nonzero_to_zero_mask` | `CELLS` | `state_q_i != 0` and `target_q_i = 0` |
| `opposite_polarity_mask` | `CELLS` | `state_q_i × target_q_i = -1` |
| `pending_completion_mask` | `CELLS` | `state_q_i = 0` and `pending_route_q_i != 0` |

Only valid ternary states participate in transition classification.

Reserved encodings are blocked by the state-domain guard.

## Same-State Rule

If:

`state_q_i = target_q_i`

then:

`state_d_i = state_q_i`

No retained-state change is counted.

No pending route is created.

No neutral-routing event is counted.

## Zero-to-Nonzero Rule

If:

`state_q_i = 0`

and:

`target_q_i = -1 or +1`

then the eligible direct neutral release is:

`0 → target_q_i`

This transition is valid because it starts from the active neutral state.

## Nonzero-to-Zero Rule

If:

`state_q_i = -1 or +1`

and:

`target_q_i = 0`

then the eligible neutralization transition is:

`state_q_i → 0`

This transition is valid because it terminates in the active neutral state.

## Opposite-Polarity Rule

If:

`state_q_i = -1`

and:

`target_q_i = +1`

then the direct transition is forbidden.

The required tick action is:

`-1 → 0`

and:

`pending_route_d_i = +1`

If:

`state_q_i = +1`

and:

`target_q_i = -1`

then the direct transition is forbidden.

The required tick action is:

`+1 → 0`

and:

`pending_route_d_i = -1`

Required invariant:

`actual_direct_events = 0`

## Pending-Completion Rule

If:

`state_q_i = 0`

and:

`pending_route_q_i = -1 or +1`

then a later eligible tick may complete:

`0 → pending_route_q_i`

and clear:

`pending_route_d_i = 0`

Completion remains subject to:

- scheduler eligibility;
- request-lane ordering;
- transition-capacity boundary.

## State Update Priority

For each cell, the M16 state-register map uses deterministic update priority:

1. reset;
2. reserved-state guard;
3. pending-route completion;
4. accepted current-tick request;
5. retained previous state.

Priority relation:

`pending completion` precedes `new opposite-polarity request`

This preserves deterministic continuation of already-retained neutral routes.

## Accepted Change Mask

The register map exposes:

| Signal | Width | Meaning |
|---|---:|---|
| `accepted_change_mask` | `CELLS` | cells changed during the tick |
| `neutral_routed_mask` | `CELLS` | cells routed through `0` due to opposite-polarity request |
| `pending_created_mask` | `CELLS` | cells that created a pending route |
| `pending_completed_mask` | `CELLS` | cells that completed a pending route |
| `unchanged_mask` | `CELLS` | cells retained without change |

Required relation:

`accepted_changes = popcount(accepted_change_mask)`

Required bound:

`accepted_changes <= REQUEST_LANES`

## Transition Capacity

M16 preserves the inherited M15 transition boundary:

`transition_fraction = 0.25`

The maximum number of accepted retained-state changes per tick is:

`max_changes = max(1, round(CELLS × transition_fraction))`

The hardware-facing relation is:

`REQUEST_LANES = max_changes`

Validated inherited profiles:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Switch Load Relation

The register map emits the tick-level switch-load numerator:

`accepted_changes`

The inherited switch-load relation is:

`switch_load = accepted_changes / CELLS`

Required bound:

`switch_load_peak <= transition_fraction`

## Direct-Transition Guard

The state-register map must prevent all direct opposite-polarity retained-state transitions.

Forbidden retained-state changes:

`-1 → +1`

`+1 → -1`

Allowed routed sequences:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required counter relation:

`actual_direct_events = 0`

## Event Counter Sources

The state-register map provides counter sources for:

| Counter source | Origin |
|---|---|
| `requested_direct_events` | popcount of opposite-polarity requests |
| `prevented_direct_events` | opposite-polarity requests blocked from direct execution |
| `neutral_routed_events` | opposite-polarity requests routed through `0` |
| `actual_direct_events` | detected direct opposite-polarity execution |
| `reserved_state_events` | reserved encoding observations |
| `accepted_change_events` | accepted retained-state changes |
| `pending_created_events` | newly retained pending routes |
| `pending_completed_events` | completed pending routes |

Required relations:

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

`actual_direct_events = 0`

`reserved_state_events = 0`

## State-Domain Assertion Set

The M16 state-register map supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_no_reserved_state_q` | `state_q` contains no `2'b10` |
| `assert_no_reserved_state_d` | `state_d` contains no `2'b10` |
| `assert_no_reserved_pending_q` | `pending_route_q` contains no `2'b10` |
| `assert_no_reserved_pending_d` | `pending_route_d` contains no `2'b10` |
| `assert_no_direct_negative_to_positive` | no `-1 → +1` retained transition |
| `assert_no_direct_positive_to_negative` | no `+1 → -1` retained transition |
| `assert_capacity_not_exceeded` | `accepted_changes <= REQUEST_LANES` |
| `assert_pending_polarity_preserved` | pending route equals requested target polarity |

## M15 Vector Replay Boundary

The M16 state-register map must be replay-compatible with the M15 deterministic vector package.

Comparison inputs:

`state_q`

`target_q`

`pending_route_q`

`scheduler_state`

`request lane order`

Comparison outputs:

`state_d`

`pending_route_d`

`accepted_change_mask`

`neutral_routed_mask`

`pending_created_mask`

`pending_completed_mask`

`reserved_state_mask`

`event counter deltas`

`invariant flags`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 State-Register Invariants

The M16 balanced ternary state-register map is valid only if:

`state_q` uses only canonical ternary encodings.

`state_d` uses only canonical ternary encodings.

`pending_route_q` uses only canonical ternary encodings.

`pending_route_d` uses only canonical ternary encodings.

`2'b10` is never emitted as a valid retained state.

Opposite-polarity transitions pass through `0`.

Direct opposite-polarity transitions remain zero.

Pending routes preserve target polarity.

Accepted changes never exceed `REQUEST_LANES`.

Switch load remains bounded by `transition_fraction`.

M15 vector replay remains deterministic.

## Closure Criteria

This register map can be considered M16-ready when it supports:

- deterministic reset to active neutral `0`;
- packed retained-state layout;
- canonical two-bit ternary encoding;
- reserved-state detection;
- pending-route storage;
- pending-route completion;
- accepted-change masks;
- neutral-routing masks;
- transition-capacity enforcement;
- event-counter source generation;
- invariant assertion support;
- M15 vector replay comparison.

## Next Step

The next M16 file should define the scheduler execution realization:

`docs/m16_scheduler_state_rtl_realization.md`

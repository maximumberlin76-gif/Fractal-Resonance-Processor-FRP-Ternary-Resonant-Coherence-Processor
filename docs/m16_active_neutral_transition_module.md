# FRP M16 Active Neutral Transition Module

## Status

Qualified RTL execution artifact.

Qualification result:

`PASS`

Closure state:

`M16 RTL EXECUTION LAYER CLOSED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document records the implemented active-neutral transition module for the M16 RTL core realization layer.

The implemented artifact is:

`rtl/m16/frp_m16_active_neutral.sv`

The module is:

`frp_m16_active_neutral`

The active-neutral transition layer preserves the M15-qualified retained-state transition semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The module generates the complete pre-capacity retained-state transition candidate for the integrated M16 RTL execution chain.

Final transition-capacity admission is performed downstream by:

`rtl/m16/frp_m16_capacity_guard.sv`

Final retained-state writeback is performed by:

`rtl/m16/frp_m16_state_update.sv`

## Implemented Artifact Boundary

The active-neutral transition module implements:

- canonical balanced ternary operand validation;
- retained-state and pending-route domain validation;
- explicit request transition classification;
- pending-route completion candidate generation;
- pending-completion priority;
- same-state candidate generation;
- zero-to-nonzero candidate generation;
- nonzero-to-zero candidate generation;
- opposite-polarity first-leg generation;
- active-neutral routing through `0`;
- direct opposite-polarity candidate detection;
- reserved-transition detection;
- deterministic ascending cell processing;
- deterministic ascending request-lane processing;
- transition masks;
- transition event telemetry;
- pre-capacity accepted-change candidate accounting;
- invariant outputs.

The module does not compute:

- Kuramoto-Sakaguchi phase coupling;
- phase words;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets;
- request-lane acceptance;
- final transition-capacity admission;
- pending-route register writeback;
- retained-state register writeback.

## Integrated Execution Position

The explicit request path is:

`registered scheduler state`

→ `request-lane arbitration`

→ `active-neutral transition candidate generation`

→ `transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

The retained pending-completion path is:

`retained state and retained pending target`

→ `pending-completion candidate derivation`

→ `active-neutral completion candidate generation`

→ `transition-capacity admission`

→ `pending-route clearing`

→ `retained-state writeback`

The active-neutral module receives pre-capacity accepted explicit request lanes.

It produces:

`state_candidate_d`

The capacity guard selects the bounded subset that may reach retained-state writeback.

## Core Identity Preserved

The active-neutral transition module preserves:

- the balanced ternary retained-state domain `{-1, 0, 1}`;
- active neutral state `0`;
- same-state retention;
- zero-to-nonzero release;
- nonzero-to-zero neutralization;
- forbidden direct retained-state transitions between `-1` and `1`;
- opposite-polarity routing through active neutral `0`;
- retained pending target polarity;
- pending completion only from retained state `0`;
- pending completion priority over new same-cell requests;
- deterministic transition classification;
- downstream transition-capacity enforcement;
- zero reserved-state emission;
- zero actual direct events.

The required routed sequences are:

`-1 → 0 → 1`

`1 → 0 → -1`

Required integrated relation:

`actual_direct_events = 0`

## Canonical Ternary Encoding

The module imports the canonical two-bit balanced ternary encoding from:

`rtl/m16/frp_m16_pkg.sv`

| Ternary state | SystemVerilog symbol | Encoding | Function |
|---|---|---|---|
| `-1` | `FRP_TERN_NEG` | `2'b11` | negative retained polarity |
| `0` | `FRP_TERN_ZERO` | `2'b00` | active neutral state |
| `1` | `FRP_TERN_POS` | `2'b01` | positive retained polarity |
| reserved | `FRP_TERN_RESERVED` | `2'b10` | invalid state |

The corresponding shared constants are:

- `FRP_STATE_NEG`;
- `FRP_STATE_ZERO`;
- `FRP_STATE_POS`;
- `FRP_STATE_RESERVED`.

The active-neutral constant is:

`FRP_ACTIVE_NEUTRAL = FRP_STATE_ZERO`

Required relations:

`reserved_transition_events = 0`

`reserved_state_events = 0`

## Module Parameterization

The module parameters are:

| Parameter | Definition |
|---|---|
| `CELLS` | number of retained balanced ternary cells |
| `STATE_BITS` | packed width of one ternary state |
| `REQUEST_LANES` | number of explicit request lanes |
| `CELL_INDEX_BITS` | packed cell-index width |
| `COUNTER_BITS` | transition event-counter width |

Default parameter sources are:

| Parameter | Default source |
|---|---|
| `CELLS` | `frp_m16_pkg::FRP_M16_DEFAULT_CELLS` |
| `STATE_BITS` | `frp_m16_pkg::FRP_M16_STATE_BITS` |
| `REQUEST_LANES` | `frp_m16_pkg::frp_calc_request_lanes(CELLS)` |
| `CELL_INDEX_BITS` | `(CELLS <= 1) ? 1 : $clog2(CELLS)` |
| `COUNTER_BITS` | `frp_m16_pkg::FRP_M16_COUNTER_BITS` |

Required state width:

`STATE_BITS = 2`

The qualified architectural simulation profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |

## Module Inputs

The active-neutral transition module consumes:

| Signal | Width | Function |
|---|---:|---|
| `tick_enable` | `1` | enables transition candidate evaluation |
| `scheduler_state` | scheduler-state width | registered temporal scheduler state |
| `state_q` | `CELLS × STATE_BITS` | retained balanced ternary state |
| `pending_route_q` | `CELLS × STATE_BITS` | retained pending-route target state |
| `request_accept` | `REQUEST_LANES` | pre-capacity accepted explicit request lanes |
| `request_neutralized` | `REQUEST_LANES` | accepted opposite-polarity request classification |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | requested cell index for each lane |
| `request_target` | `REQUEST_LANES × STATE_BITS` | requested balanced ternary target for each lane |
| `pending_completion_enable` | `CELLS` | scheduler-qualified pending-completion candidate mask |

Within `frp_m16_core`, the connected explicit request input is:

`request_accept_lane`

The connected pending-completion input is:

`pending_completion_candidate`

Final capacity acceptance is not an input to this module.

## Candidate-State Output

The primary candidate output is:

`state_candidate_d`

Its width is:

`CELLS × STATE_BITS`

The candidate-state base is:

`state_candidate_next = state_q`

A cell retains its current state unless a legal enabled transition candidate changes it.

The final combinational assignment is:

`state_candidate_d = state_candidate_next`

`state_candidate_d` is not the retained-state register.

The downstream capacity guard selects admitted cells.

The retained-state update module commits only capacity-approved candidate cells.

## Transition Mask Outputs

The module emits:

| Signal | Width | Function |
|---|---:|---|
| `transition_valid_mask` | `CELLS` | cells with a classified legal transition candidate |
| `same_state_mask` | `CELLS` | cells with accepted same-state requests |
| `zero_to_nonzero_mask` | `CELLS` | cells with `0` to nonzero candidates |
| `nonzero_to_zero_mask` | `CELLS` | cells with nonzero to `0` candidates |
| `opposite_polarity_mask` | `CELLS` | cells with accepted opposite-polarity requests |
| `neutral_routed_mask` | `CELLS` | opposite-polarity candidates routed through active neutral `0` |
| `pending_completion_mask` | `CELLS` | cells with legal pending-completion candidates |
| `actual_direct_mask` | `CELLS` | cells whose final candidate crosses directly between `-1` and `1` |
| `reserved_transition_mask` | `CELLS` | cells containing invalid transition operands or candidate values |
| `accepted_change_candidate_mask` | `CELLS` | cells whose candidate state differs from retained state |

A same-state request sets:

`transition_valid_mask`

and:

`same_state_mask`

It does not set:

`accepted_change_candidate_mask`

## Transition Event Outputs

The module emits:

| Signal | Function |
|---|---|
| `same_state_events` | accepted same-state explicit requests |
| `zero_to_nonzero_events` | zero-to-nonzero explicit requests and pending completions |
| `nonzero_to_zero_events` | nonzero-to-zero explicit requests and opposite-polarity first legs |
| `requested_direct_events` | accepted opposite-polarity explicit requests |
| `prevented_direct_events` | accepted opposite-polarity requests routed to `0` |
| `neutral_routed_events` | accepted opposite-polarity requests routed through active neutral `0` |
| `pending_completion_events` | legal pending-completion candidates |
| `actual_direct_events` | final candidate states that cross directly between `-1` and `1` |
| `reserved_transition_events` | invalid retained, pending, request, or transition operands |
| `accepted_change_candidate_events` | state-changing transition candidates |

The integrated public direct-event counters use this transition-stage telemetry.

Actual retained-state execution is checked again at the retained-state writeback boundary.

## Transition Invariant Outputs

The module emits:

- `transition_domain_valid`;
- `active_neutral_routing_valid`;
- `pending_completion_from_zero_valid`;
- `no_reserved_transition`;
- `no_actual_direct_events`;
- `transition_capacity_valid`;
- `state_output_domain_valid`;
- `transition_replay_deterministic`.

These outputs participate in the integrated M16 invariant vector.

## Combinational Evaluation Boundary

The active-neutral transition module is combinational.

At the beginning of every evaluation:

`state_candidate_next = state_q`

All masks are initialized to zero.

All transition event outputs are initialized to zero.

All transition invariant outputs are initialized to one before validation.

The RTL qualification rejects inferred combinational latches.

The qualified active-neutral implementation contains:

`zero inferred latches`

## Scheduler-State Validation

The module validates:

`scheduler_state`

through:

`frp_scheduler_state_is_valid`

The valid scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`.

The final replay relation requires a valid scheduler state.

## Complete Operand-Domain Validation

Before transition candidate generation, the module scans every cell in ascending cell-index order.

For every cell, it validates:

- retained state from `state_q`;
- retained pending target from `pending_route_q`.

If either value is outside `{-1, 0, 1}`, the module:

- sets `reserved_transition_mask[cell]`;
- increments `reserved_transition_events`;
- clears `transition_domain_valid`;
- clears `no_reserved_transition`.

Invalid operands are not converted into legal transition candidates.

## Pending-Completion Evaluation Priority

Pending-route completion is evaluated before explicit request lanes.

Pending-completion cells are processed in ascending cell-index order:

`cell 0 → cell 1 → ... → cell CELLS - 1`

For each cell, completion is requested when:

`tick_enable = 1`

and:

`pending_completion_enable[cell] = 1`

A legal completion additionally requires:

- retained state belongs to `{-1, 0, 1}`;
- retained state is `0`;
- retained pending target belongs to `{-1, 0, 1}`;
- retained pending target is nonzero;
- scheduler state is valid;
- scheduler state is commit-capable.

Commit-capable scheduler states are:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

A legal completion claims the cell through:

`pending_completion_mask[cell]`

This claim precedes explicit request processing.

## Explicit Request-Lane Evaluation

After pending-completion evaluation, accepted explicit request lanes are processed in ascending order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

The request-lane arbitration module has already applied:

- cell-index validation;
- target-domain validation;
- duplicate-cell guarding;
- retained pending-route ownership;
- scheduler transition eligibility.

The active-neutral module validates the accepted inputs again.

For each accepted lane, it extracts:

- cell index;
- retained cell state;
- requested target;
- pending-completion ownership.

If an accepted lane has an invalid cell index, the module clears:

- `transition_domain_valid`;
- `no_reserved_transition`;
- `transition_replay_deterministic`.

If retained state or request target is invalid, the module:

- sets `reserved_transition_mask`;
- increments `reserved_transition_events`;
- clears `transition_domain_valid`;
- clears `no_reserved_transition`;
- clears `transition_replay_deterministic`.

If a pending completion already owns the cell, no explicit request candidate replaces it.

The module clears:

`transition_replay_deterministic`

for this invalid ownership condition.

## Explicit Transition Classification

For a valid accepted explicit request, the module calls:

`frp_classify_transition(retained_state, requested_target, FRP_STATE_ZERO)`

The explicit transition classes are:

| Transition class | Condition |
|---|---|
| `FRP_TRANS_SAME_STATE` | retained state equals requested target |
| `FRP_TRANS_ZERO_TO_NONZERO` | retained state is `0` and target is `-1` or `1` |
| `FRP_TRANS_NONZERO_TO_ZERO` | retained state is `-1` or `1` and target is `0` |
| `FRP_TRANS_OPPOSITE_POLARITY` | retained state and target are opposite nonzero polarities |
| `FRP_TRANS_RESERVED_OPERAND` | retained state or target is outside `{-1, 0, 1}` |
| `FRP_TRANS_INVALID` | no defined transition relation matches |

The module evaluates scheduler eligibility through:

`frp_scheduler_allows_transition`

## Same-State Transition

A same-state explicit request satisfies:

`state_q[cell] = request_target[lane]`

The candidate value remains:

`state_candidate_d[cell] = state_q[cell]`

The module sets:

`transition_valid_mask[cell] = 1`

`same_state_mask[cell] = 1`

and increments:

`same_state_events`

It does not set:

`accepted_change_candidate_mask[cell]`

It does not increment:

`accepted_change_candidate_events`

No pending route is created.

No direct-event counter is incremented.

## Neutral Release Transition

A neutral release satisfies:

`state_q[cell] = 0`

and:

`request_target[lane] ∈ {-1, 1}`

The transition is scheduler-eligible in:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

For an eligible accepted request:

`state_candidate_d[cell] = request_target[lane]`

The module sets:

`transition_valid_mask[cell] = 1`

`zero_to_nonzero_mask[cell] = 1`

`accepted_change_candidate_mask[cell] = 1`

and increments:

`zero_to_nonzero_events`

`accepted_change_candidate_events`

The candidate remains subject to downstream transition-capacity admission.

## Neutralization Transition

A neutralization satisfies:

`state_q[cell] ∈ {-1, 1}`

and:

`request_target[lane] = 0`

The transition is scheduler-eligible in:

- `FREE`;
- `BALANCE`;
- `NEUTRALIZE`.

For an eligible accepted request:

`state_candidate_d[cell] = FRP_ACTIVE_NEUTRAL`

The module sets:

`transition_valid_mask[cell] = 1`

`nonzero_to_zero_mask[cell] = 1`

`accepted_change_candidate_mask[cell] = 1`

and increments:

`nonzero_to_zero_events`

`accepted_change_candidate_events`

The candidate remains subject to downstream transition-capacity admission.

## Opposite-Polarity Transition Request

An opposite-polarity request satisfies either:

`state_q[cell] = -1`

and:

`request_target[lane] = 1`

or:

`state_q[cell] = 1`

and:

`request_target[lane] = -1`

The request is scheduler-eligible in:

- `FREE`;
- `BALANCE`;
- `NEUTRALIZE`.

For each accepted opposite-polarity request, the module increments:

`requested_direct_events`

A legal active-neutral route additionally requires:

`request_neutralized[lane] = 1`

and scheduler eligibility.

The candidate is:

`state_candidate_d[cell] = FRP_ACTIVE_NEUTRAL`

The module sets:

`transition_valid_mask[cell] = 1`

`opposite_polarity_mask[cell] = 1`

`neutral_routed_mask[cell] = 1`

`nonzero_to_zero_mask[cell] = 1`

`accepted_change_candidate_mask[cell] = 1`

It increments:

`prevented_direct_events`

`neutral_routed_events`

`nonzero_to_zero_events`

`accepted_change_candidate_events`

The requested opposite target remains available on:

`request_target`

The pending-route module stores that target only if the first route leg receives downstream transition capacity.

If `request_neutralized` or scheduler eligibility is absent for an accepted opposite-polarity request, the module clears:

`active_neutral_routing_valid`

## Active-Neutral First Leg

For:

`-1 → 1`

the candidate first leg is:

`-1 → 0`

The pending target is:

`1`

For:

`1 → -1`

the candidate first leg is:

`1 → 0`

The pending target is:

`-1`

Direct candidate execution between opposite nonzero polarities is not generated by the legal routing branch.

Each first-leg candidate remains subject to downstream transition-capacity admission.

## Pending Route Completion Transition

A pending completion satisfies:

`state_q[cell] = 0`

and:

`pending_route_q[cell] ∈ {-1, 1}`

and:

`pending_completion_enable[cell] = 1`

and:

`scheduler_state ∈ {FREE, COMMIT, EXCITE}`

For a legal completion:

`state_candidate_d[cell] = pending_route_q[cell]`

The module sets:

`transition_valid_mask[cell] = 1`

`zero_to_nonzero_mask[cell] = 1`

`pending_completion_mask[cell] = 1`

`accepted_change_candidate_mask[cell] = 1`

It increments:

`zero_to_nonzero_events`

`pending_completion_events`

`accepted_change_candidate_events`

The candidate remains subject to downstream transition-capacity admission.

The pending-route module clears the retained pending target only after the completion receives capacity.

## Forbidden Pending Completion

Pending completion is legal only from retained active neutral state:

`state_q[cell] = 0`

A completion request from retained state `-1` or `1` is invalid.

A completion request with a zero pending target is invalid.

A completion request with a reserved retained state or reserved pending target is invalid.

A completion request during a scheduler state that is not commit-capable is invalid.

For an invalid completion request, the module clears:

- `pending_completion_from_zero_valid`;
- `transition_replay_deterministic`.

If the completion operands are invalid, the module also:

- sets `reserved_transition_mask[cell]`;
- clears `transition_domain_valid`;
- clears `no_reserved_transition`.

Required relation:

`pending completion starts from retained state 0`

## Direct Transition Detection

After pending-completion and explicit-request candidate generation, the module scans every cell in ascending cell-index order.

For each cell, it compares:

`state_q[cell]`

with:

`state_candidate_d[cell]`

A direct opposite-polarity candidate exists when:

`state_q[cell] = -1`

and:

`state_candidate_d[cell] = 1`

or when:

`state_q[cell] = 1`

and:

`state_candidate_d[cell] = -1`

For a detected direct candidate, the module sets:

`actual_direct_mask[cell] = 1`

increments:

`actual_direct_events`

and clears:

`no_actual_direct_events`

Qualified values:

`actual_direct_mask = 0`

`actual_direct_events = 0`

## Reserved Transition Guard

The reserved balanced ternary encoding is:

`2'b10`

The module validates:

- every retained state;
- every retained pending target;
- every accepted request target;
- every final candidate state.

An invalid retained state or retained pending target:

- sets `reserved_transition_mask`;
- increments `reserved_transition_events`;
- clears `transition_domain_valid`;
- clears `no_reserved_transition`.

An invalid accepted request target or retained request cell state also clears:

`transition_replay_deterministic`

An invalid final candidate state:

- sets `reserved_transition_mask`;
- clears `state_output_domain_valid`;
- clears `no_reserved_transition`.

The final domain relation is:

`transition_domain_valid = transition_domain_valid && state_output_domain_valid && no_reserved_transition`

Qualified values:

`reserved_transition_events = 0`

`reserved_state_events = 0`

## Selected Target Priority

The candidate-state base is:

`state_candidate_next = state_q`

The implemented priority order is:

1. retained current state;
2. legal pending-route completion candidate;
3. accepted explicit request candidate.

Pending completion is processed before explicit request lanes.

A pending completion claims its cell through:

`pending_completion_mask`

An accepted explicit request targeting a claimed completion cell does not replace the pending completion candidate.

Within an explicit request:

- same-state classification retains the current state;
- zero-to-nonzero classification selects the explicit request target;
- nonzero-to-zero classification selects active neutral `0`;
- opposite-polarity classification selects active neutral `0`.

The module has no reset input.

Reset-state generation is performed by the retained-state register layer.

## State Candidate Generation

The implemented candidate relations are:

| Condition | Candidate state |
|---|---|
| no enabled legal transition | `state_q[cell]` |
| accepted same-state request | `state_q[cell]` |
| accepted zero-to-nonzero request | `request_target[lane]` |
| accepted nonzero-to-zero request | `0` |
| accepted opposite-polarity request | `0` |
| legal pending completion | `pending_route_q[cell]` |
| invalid transition operand | retained candidate remains unchanged and invariant outputs are cleared |

The active-neutral module emits:

`state_candidate_d`

The capacity guard determines which candidate cells receive final admission.

The state-update module commits only capacity-approved candidate cells.

Required candidate-domain relation:

`state_candidate_d[cell] ∈ {-1, 0, 1}`

## Tick-Enable Behavior

When:

`tick_enable = 0`

pending-completion evaluation is disabled.

Explicit request transition evaluation is disabled.

The candidate-state base remains unchanged:

`state_candidate_d = state_q`

The state-changing candidate mask remains:

`accepted_change_candidate_mask = 0`

The state-changing candidate event count remains:

`accepted_change_candidate_events = 0`

Transition-domain validation still evaluates the current retained-state and pending-route domains.

Required integrated relation:

`tick_enable = 0 → no retained-state writeback`

## Scheduler Interaction

The active-neutral module validates the registered scheduler state and applies the shared scheduler transition rules.

The scheduler cannot authorize a direct transition between `-1` and `1`.

Explicit zero-to-nonzero transitions require a commit-capable state.

Explicit nonzero-to-zero transitions require a neutralize-capable state.

Opposite-polarity first legs require a neutralize-capable state.

Pending completion requires a commit-capable state.

Same-state retention is legal in every valid scheduler state.

## Free-State Transition Behavior

`FREE` is both commit-capable and neutralize-capable.

The integrated `FREE` path admits:

- same-state retention;
- zero-to-nonzero release;
- nonzero-to-zero neutralization;
- opposite-polarity first-leg routing through `0`;
- retained pending-route completion from `0`.

Every state-changing candidate remains subject to downstream capacity admission.

## Balance-State Transition Behavior

`BALANCE` is neutralize-capable.

The integrated `BALANCE` path admits:

- same-state retention;
- nonzero-to-zero neutralization;
- opposite-polarity first-leg routing through `0`.

It does not admit:

- zero-to-nonzero release;
- pending-route completion.

A pending target remains retained during `BALANCE`.

## Commit-State Transition Behavior

`COMMIT` is commit-capable.

The integrated `COMMIT` path admits:

- same-state retention;
- zero-to-nonzero release;
- retained pending-route completion from `0`.

It does not admit:

- nonzero-to-zero explicit requests;
- opposite-polarity explicit requests.

## Excite-State Transition Behavior

`EXCITE` is commit-capable.

The integrated `EXCITE` path admits:

- same-state retention;
- zero-to-nonzero release;
- retained pending-route completion from `0`.

It does not admit:

- nonzero-to-zero explicit requests;
- opposite-polarity explicit requests.

## Neutralize-State Transition Behavior

`NEUTRALIZE` is neutralize-capable.

The integrated `NEUTRALIZE` path admits:

- same-state retention;
- nonzero-to-zero neutralization;
- opposite-polarity first-leg routing through `0`.

It does not admit:

- zero-to-nonzero release;
- pending-route completion.

A pending target remains retained during `NEUTRALIZE`.

## Transition Event Relations

The active-neutral module records:

| Event output | Recorded transition |
|---|---|
| `same_state_events` | accepted same-state request |
| `zero_to_nonzero_events` | explicit neutral release or pending completion |
| `nonzero_to_zero_events` | explicit neutralization or opposite-polarity first leg |
| `requested_direct_events` | accepted opposite-polarity request |
| `prevented_direct_events` | opposite-polarity request assigned to active-neutral routing |
| `neutral_routed_events` | opposite-polarity request routed through `0` |
| `pending_completion_events` | legal pending completion candidate |
| `actual_direct_events` | direct opposite-polarity candidate detected |
| `reserved_transition_events` | invalid transition operand detected |
| `accepted_change_candidate_events` | state-changing pre-capacity candidate |

The active-neutral routing relations are:

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

`actual_direct_events = 0`

The qualified opposite-polarity test ticks record:

`requested_direct_events = 1`

`prevented_direct_events = 1`

`neutral_routed_events = 1`

`actual_direct_events = 0`

## Accepted Change Candidate Relation

The active-neutral module produces a pre-capacity candidate mask:

`accepted_change_candidate_mask`

A bit is set for:

- zero-to-nonzero explicit transition;
- nonzero-to-zero explicit transition;
- opposite-polarity first leg;
- pending-route completion.

A same-state request does not set the mask.

The candidate accounting relation is:

```systemverilog
accepted_change_candidate_events
==
$countones(accepted_change_candidate_mask)
```

The direct-candidate exclusion relation is:

```systemverilog
(
    accepted_change_candidate_mask
    & actual_direct_mask
)
==
0
```

These two relations form the module output:

`transition_capacity_valid`

The active-neutral module does not apply the final bound:

`accepted_changes <= REQUEST_LANES`

That bound is applied by:

`frp_m16_capacity_guard`

## Final Capacity and Switch-Load Boundary

The capacity guard consumes:

- `state_q`;
- `state_candidate_d`;
- `accepted_change_candidate_mask`;
- `neutral_routed_mask`;
- pending-completion candidates;
- pre-capacity accepted request lanes.

The capacity guard produces:

- `capacity_accept_mask`;
- `capacity_reject_mask`;
- `accepted_change_mask`;
- `accepted_changes`;
- `capacity_remaining`;
- `capacity_exhausted`;
- `switch_load_numerator`.

The integrated relations are:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

The active-neutral candidate count and final accepted-change count are separate execution-stage quantities.

## Active-Neutral Route Determinism

Deterministic processing order is:

1. complete retained-state and pending-route domain scan;
2. pending completions in ascending cell-index order;
3. accepted explicit requests in ascending lane order;
4. final candidate-state domain and direct-transition scan in ascending cell-index order.

The candidate-state base is always copied from:

`state_q`

The same input values and parameters produce the same:

- `state_candidate_d`;
- transition-valid mask;
- transition-class masks;
- neutral-routing mask;
- pending-completion mask;
- direct-transition mask;
- reserved-transition mask;
- accepted-change candidate mask;
- transition event telemetry;
- invariant outputs.

The replay-valid output is:

`transition_replay_deterministic`

It is cleared by:

- invalid scheduler state;
- invalid retained-state or pending-route domain;
- invalid explicit request input;
- illegal pending completion;
- explicit request conflict with a pending completion;
- incomplete active-neutral routing;
- detected direct opposite-polarity candidate.

## Active-Neutral Invariant Relations

The active-neutral routing relation is:

```systemverilog
active_neutral_routing_valid =
    active_neutral_routing_valid
    && (
        prevented_direct_events
        >= requested_direct_events
    )
    && (
        neutral_routed_events
        >= prevented_direct_events
    )
    && no_actual_direct_events;
```

The candidate accounting relation is:

```systemverilog
transition_capacity_valid =
    (
        accepted_change_candidate_events
        ==
        $countones(
            accepted_change_candidate_mask
        )
    )
    && (
        (
            accepted_change_candidate_mask
            & actual_direct_mask
        )
        == 0
    );
```

The replay relation is:

```systemverilog
transition_replay_deterministic =
    transition_replay_deterministic
    && scheduler_state_valid
    && transition_domain_valid
    && pending_completion_from_zero_valid
    && active_neutral_routing_valid
    && no_actual_direct_events;
```

## Integrated Active-Neutral Invariant Flag

The integrated active-neutral flag is:

`FRP_INV_ACTIVE_NEUTRAL_VALID`

It includes:

- request-stage active-neutral routing validation;
- transition-stage active-neutral routing validation;
- pending completion from retained state `0`;
- transition replay determinism;
- active-neutral capacity validation;
- active-neutral retained-state writeback validation;
- pending-completion writeback validation;
- transition-stage zero direct-event validation;
- state-update zero direct-event validation.

The active-neutral module outputs also participate in:

- `FRP_INV_STATE_DOMAIN_VALID`;
- `FRP_INV_PENDING_POLARITY_VALID`;
- `FRP_INV_TRANSITION_CAPACITY_VALID`;
- `FRP_INV_STATE_UPDATE_VALID`;
- `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
- `FRP_INV_NO_RESERVED_STATE`.

The qualified integrated invariant vector is:

`1111111111`

## Assertion Support

The bound assertion artifact is:

`rtl/m16/frp_m16_assertions.sv`

The integrated assertion relations include:

| Assertion boundary | Required relation |
|---|---|
| retained-state domain | every state belongs to `{-1, 0, 1}` |
| pending-route domain | every pending target belongs to `{-1, 0, 1}` |
| disabled tick | retained state and pending route remain stable |
| state-change authorization | retained-state change requires `accepted_change_mask` |
| direct-transition guard | no retained-state transition crosses directly between `-1` and `1` |
| active-neutral first leg | accepted opposite-polarity request writes retained state `0` |
| retained pending polarity | pending target is opposite to the prior retained state |
| deferred route | pending target remains stable without accepted completion |
| completion source | pending completion starts from retained state `0` |
| completion target | retained state receives the prior pending target |
| completion clearing | pending route becomes `0` |
| neutral-route ownership | every neutral-routed cell is capacity accepted |
| active-neutral invariant flag | `FRP_INV_ACTIVE_NEUTRAL_VALID = 1` |
| direct-event invariant flag | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS = 1` |

## Deterministic RTL Testbench Record

The executable testbench is:

`rtl/m16/frp_m16_tb.sv`

The qualified parameter profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |

The free-mode sequence executes:

`0 → 1`

`1 → 0 → -1`

`-1 → 0 → 1`

The opposite-polarity first-leg ticks record:

- `neutral_routed_cell_mask[0] = 1`;
- `requested_direct_events = 1`;
- `prevented_direct_events = 1`;
- `neutral_routed_events = 1`;
- `actual_direct_events = 0`.

The retained pending target completes on the following eligible tick.

The `7/1` sequence records:

- zero-to-nonzero deferral during `BALANCE`;
- zero-to-nonzero release during `COMMIT`;
- opposite-polarity first leg during `BALANCE`;
- retained state `0` and pending target retention;
- completion during the following `COMMIT`.

The `1/7` sequence records:

- zero-to-nonzero release during `EXCITE`;
- opposite-polarity first leg during `NEUTRALIZE`;
- retained state `0` and pending target retention;
- completion during the following `EXCITE`.

## Active-Neutral Qualification Record

| Routing relation | Result |
|---|---|
| active neutral `0` executed as intermediate state | `PASS` |
| direct `-1 → 1` absent | `PASS` |
| direct `1 → -1` absent | `PASS` |
| `-1 → 0 → 1` executed | `PASS` |
| `1 → 0 → -1` executed | `PASS` |
| requested opposite polarity retained | `PASS` |
| pending completion executed only from `0` | `PASS` |
| pending route cleared after completion | `PASS` |

The pending-route relations are:

| Pending-route relation | Result |
|---|---|
| exact requested polarity retained | `PASS` |
| same-cell overwrite prevented | `PASS` |
| scheduler deferral preserves route | `PASS` |
| capacity deferral preserves route | `PASS` |
| completion executes only from `0` | `PASS` |
| accepted completion clears route | `PASS` |
| pending-route overflow absent | `PASS` |

## M15 Semantic Foundation

M15 remains the qualified semantic and implementation-mapping foundation for M16.

The M15 qualification record is:

| Qualification relation | Result |
|---|---:|
| qualification checks | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

The M16 active-neutral implementation retains:

- M15 balanced ternary encoding;
- active neutral state `0`;
- same-state retention;
- zero-to-nonzero release;
- nonzero-to-zero neutralization;
- tick-separated opposite-polarity routing;
- exact pending-target polarity;
- completion from retained state `0`;
- transition-capacity qualification;
- zero actual direct events;
- zero reserved-state events;
- zero queue-overflow events.

## RTL Workflow Record

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Initial closed workflow record:

| Field | Value |
|---|---|
| Run | `#82` |
| Source commit | `a68a2af` |
| Branch | `main` |
| Result | `SUCCESS` |
| Artifact count | `1` |

Synchronized workflow record:

| Field | Value |
|---|---|
| Run | `#84` |
| Repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `52s` |
| Artifact count | `1` |

Active-neutral qualification result:

`PASS`

RTL closure state:

`M16 RTL EXECUTION LAYER CLOSED`

## FPGA Integration Qualification Record

The target-independent FPGA integration top is:

`fpga/m16/frp_m16_fpga_top.sv`

The executable FPGA integration testbench is:

`fpga/m16/frp_m16_fpga_tb.sv`

The FPGA testbench executes:

`0 → 1`

then:

`1 → 0`

with retained:

`pending_route = -1`

and then:

`0 → -1`

During the opposite-polarity first leg, the recorded relations are:

`request_accept[0] = 1`

`neutral_routed_cell_mask[0] = 1`

`requested_direct_events = 1`

`prevented_direct_events = 1`

`neutral_routed_events = 1`

`actual_direct_events = 0`

After the first leg:

- retained state is `0`;
- retained pending target is `-1`.

After completion:

- retained state is `-1`;
- retained pending target is `0`.

The synchronized FPGA preparation record is:

| Field | Value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Run | `#2` |
| Repository commit | `ede53cf` |
| Branch | `main` |
| Result | `SUCCESS` |
| Duration | `36s` |
| Artifact count | `1` |

FPGA preparation qualification records:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready`;
- execution-input gating before readiness;
- scheduler propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten invariant flags equal to `1`;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`.

FPGA preparation closure state:

`M16 FPGA PREPARATION LAYER CLOSED`

## Terminal Qualification Record

The deterministic RTL testbench terminal output is:

```text
FRP M16 deterministic RTL testbench completed.
CELLS=8 REQUEST_LANES=2
ticks_recorded=16
actual_direct_events=0
reserved_state_events=0
queue_overflow_events=0
```

Recorded terminal relations:

| Relation | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| final `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal marker validation:

`PASS`

## Qualification Closure

The implemented active-neutral artifact records:

- canonical balanced ternary operand validation;
- deterministic pending-completion priority;
- deterministic ascending request-lane evaluation;
- same-state retention;
- zero-to-nonzero candidate generation;
- nonzero-to-zero candidate generation;
- opposite-polarity first-leg routing through `0`;
- retained pending-target completion from `0`;
- direct-transition detection;
- reserved-transition detection;
- candidate-state domain validation;
- pre-capacity change-mask generation;
- transition event telemetry;
- invariant generation;
- downstream capacity qualification;
- retained-state writeback correlation;
- assertion execution;
- executable deterministic testbench coverage;
- FPGA integration propagation;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- repository-integrity validation;
- qualification artifact generation.

Final active-neutral result:

`PASS`

Final event values:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Final RTL closure state:

`M16 RTL EXECUTION LAYER CLOSED`

## Related M16 Artifacts

- `rtl/m16/frp_m16_pkg.sv`;
- `rtl/m16/frp_m16_scheduler.sv`;
- `rtl/m16/frp_m16_request_lanes.sv`;
- `rtl/m16/frp_m16_pending_routes.sv`;
- `rtl/m16/frp_m16_active_neutral.sv`;
- `rtl/m16/frp_m16_capacity_guard.sv`;
- `rtl/m16/frp_m16_state_update.sv`;
- `rtl/m16/frp_m16_core.sv`;
- `rtl/m16/frp_m16_assertions.sv`;
- `rtl/m16/frp_m16_tb.sv`;
- `rtl/m16/SIMULATION_TRANSCRIPT.md`;
- `rtl/m16/CLOSURE.md`;
- `fpga/m16/frp_m16_fpga_top.sv`;
- `fpga/m16/frp_m16_fpga_tb.sv`;
- `fpga/m16/SIMULATION_TRANSCRIPT.md`;
- `fpga/m16/CLOSURE.md`;
- `docs/m16_request_lane_arbitration_module.md`;
- `docs/m16_pending_route_register_module.md`;
- `docs/m16_transition_capacity_guard_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`.

## Author

Maksym Marnov

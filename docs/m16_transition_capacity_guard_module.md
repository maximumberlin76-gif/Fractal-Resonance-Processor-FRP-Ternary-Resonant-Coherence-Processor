# FRP M16 Transition Capacity Guard Module

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

This document records the implemented transition-capacity guard module for the M16 RTL core realization layer.

The implemented artifact is:

`rtl/m16/frp_m16_capacity_guard.sv`

The module is:

`frp_m16_capacity_guard`

The transition-capacity guard preserves the M15-qualified per-tick retained-state transition boundary of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The guard selects the bounded subset of legal pre-capacity transition candidates that may reach retained-state and pending-route writeback.

## Implemented Capacity Boundary

The transition-capacity guard implements:

- compile-time transition-capacity parameterization;
- pending-completion priority;
- deterministic ascending cell-index processing;
- deterministic ascending request-lane processing;
- candidate-state domain validation;
- explicit transition-class validation;
- same-state acceptance without capacity consumption;
- state-changing capacity admission;
- capacity rejection;
- active-neutral first-leg validation;
- direct opposite-polarity candidate rejection;
- accepted-cell mask generation;
- accepted-change mask generation;
- capacity-remaining calculation;
- capacity-exhausted calculation;
- switch-load numerator generation;
- per-evaluation event telemetry;
- invariant outputs.

The guard does not compute:

- Kuramoto-Sakaguchi phase coupling;
- phase words;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets;
- scheduler-state decoding;
- request-lane arbitration;
- active-neutral candidate generation;
- pending-route next-state generation;
- retained-state writeback.

## Integrated Execution Position

The integrated M16 execution order is:

`registered scheduler state`

→ `request-lane arbitration`

→ `active-neutral transition candidate generation`

→ `transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

The capacity guard receives:

- pre-capacity accepted explicit request lanes;
- explicit transition classes;
- pending-completion candidates;
- active-neutral routing candidates;
- retained current state;
- complete pre-capacity candidate state.

It produces:

- capacity-approved explicit request lanes;
- capacity-rejected explicit request lanes;
- capacity-approved cell mask;
- capacity-rejected cell mask;
- accepted-change mask;
- accepted-change count;
- capacity telemetry;
- capacity invariant signals.

## Core Identity Preserved

The transition-capacity guard preserves:

- the balanced ternary domain `{-1, 0, 1}`;
- active neutral state `0`;
- `transition_fraction = 0.25`;
- pending-completion priority over explicit request lanes;
- deterministic ascending explicit request order;
- same-state retention without capacity consumption;
- one capacity slot per accepted state-changing tick leg;
- tick-separated opposite-polarity routing;
- retained pending polarity during capacity deferral;
- forbidden direct retained-state transitions between `-1` and `1`;
- zero queue-overflow events in qualified execution;
- zero actual direct events.

Required integrated relation:

`accepted_changes <= REQUEST_LANES`

## Capacity Formula

The package constants are:

`FRP_M16_TRANSITION_FRACTION_NUM = 1`

`FRP_M16_TRANSITION_FRACTION_DEN = 4`

The exact RTL request-lane calculation is:

```systemverilog
rounded_value =
    (
        (cells * FRP_M16_TRANSITION_FRACTION_NUM)
        + (FRP_M16_TRANSITION_FRACTION_DEN / 2)
    )
    / FRP_M16_TRANSITION_FRACTION_DEN;
```

The minimum request-lane count is one:

```systemverilog
REQUEST_LANES = max(1, rounded_value)
```

The capacity guard defines:

```systemverilog
CAPACITY_LIMIT = REQUEST_LANES
```

The qualified profiles are:

| Cells | Transition fraction | Request lanes | Capacity limit |
|---:|---:|---:|---:|
| `8` | `0.25` | `2` | `2` |
| `16` | `0.25` | `4` | `4` |
| `32` | `0.25` | `8` | `8` |

The qualified M16 architectural simulation uses:

`CELLS = 8`

`REQUEST_LANES = 2`

`CAPACITY_LIMIT = 2`

## Module Parameterization

The module parameters are:

| Parameter | Definition |
|---|---|
| `CELLS` | number of retained balanced ternary cells |
| `STATE_BITS` | packed width of one ternary state |
| `REQUEST_LANES` | per-tick transition-capacity limit |
| `CELL_INDEX_BITS` | packed cell-index width |
| `COUNTER_BITS` | capacity event-counter width |

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

`REQUEST_LANES` is a compile-time module parameter.

It is not recomputed during processor execution.

## Module Inputs

The transition-capacity guard consumes:

| Signal | Width | Function |
|---|---:|---|
| `tick_enable` | `1` | enables capacity evaluation for the processor tick |
| `scheduler_state` | scheduler-state width | registered scheduler state used by final capacity validation |
| `request_accept_candidate` | `REQUEST_LANES` | pre-capacity accepted explicit request lanes |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | requested cell index for each lane |
| `transition_class` | `REQUEST_LANES × 4` | packed transition class for each explicit request lane |
| `pending_completion_candidate` | `CELLS` | scheduler-qualified retained pending completions |
| `neutral_routed_candidate` | `CELLS` | active-neutral first-leg candidates |
| `state_q` | `CELLS × STATE_BITS` | retained balanced ternary state |
| `state_candidate_d` | `CELLS × STATE_BITS` | complete pre-capacity candidate state |

The module has no `request_valid` input.

Request validity and pre-capacity request acceptance are resolved upstream by:

`rtl/m16/frp_m16_request_lanes.sv`

The candidate state is generated upstream by:

`rtl/m16/frp_m16_active_neutral.sv`

## Request-Lane Capacity Outputs

The module emits:

| Signal | Width | Function |
|---|---:|---|
| `request_accept_capacity` | `REQUEST_LANES` | explicit request lanes admitted by the capacity boundary |
| `request_reject_capacity` | `REQUEST_LANES` | explicit request lanes rejected at the capacity boundary |

`request_reject_capacity` records capacity-boundary rejection caused by:

- invalid cell index;
- pending-completion ownership;
- earlier capacity ownership;
- invalid state operand;
- invalid candidate state;
- unsupported transition class;
- detected direct opposite-polarity candidate;
- invalid active-neutral route relation;
- transition-class and state-change mismatch;
- unavailable state-changing capacity.

The integrated core publishes:

`request_accept = request_accept_capacity`

and:

`request_reject = request_reject_lane | request_reject_capacity`

## Cell-Mask Outputs

The module emits:

| Signal | Width | Function |
|---|---:|---|
| `capacity_accept_mask` | `CELLS` | cells admitted at the capacity boundary |
| `capacity_reject_mask` | `CELLS` | cells rejected at the capacity boundary |
| `accepted_change_mask` | `CELLS` | capacity-admitted cells whose retained state changes |

`capacity_accept_mask` includes:

- accepted state-changing cells;
- accepted same-state explicit request cells.

`accepted_change_mask` includes only accepted state-changing cells.

Required relation:

`popcount(accepted_change_mask) = accepted_changes`

## Capacity-State Outputs

The module emits:

| Signal | Function |
|---|---|
| `accepted_changes` | number of capacity-admitted retained-state changes |
| `capacity_remaining` | unused state-changing capacity |
| `capacity_exhausted` | indicates that accepted changes equal the capacity limit |
| `switch_load_numerator` | accepted retained-state changes |

The required relations are:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

## Capacity Event Outputs

The module emits:

| Signal | Function |
|---|---|
| `capacity_candidate_events` | valid state-changing candidates presented for capacity admission |
| `capacity_accept_events` | accepted state-changing candidates |
| `capacity_reject_events` | candidates or lanes rejected at the capacity boundary |
| `capacity_exhausted_events` | one event when accepted changes fill the capacity limit |
| `accepted_change_events` | accepted state-changing candidates |

Same-state acceptance does not increment:

- `capacity_candidate_events`;
- `capacity_accept_events`;
- `accepted_change_events`.

The implemented same-state relation is:

`capacity_accept_events = accepted_change_events`

## Capacity Invariant Outputs

The module emits:

- `transition_capacity_valid`;
- `accepted_changes_within_limit`;
- `capacity_remaining_valid`;
- `capacity_exhaustion_valid`;
- `same_state_capacity_valid`;
- `pending_capacity_valid`;
- `active_neutral_capacity_valid`;
- `switch_load_bound_valid`;
- `no_queue_overflow`;
- `no_actual_direct_events`.

These signals feed the integrated M16 transition-capacity and zero-event invariant flags.

## Combinational Capacity Evaluation

The transition-capacity guard is combinational.

At the beginning of each evaluation:

`request_accept_capacity = 0`

`request_reject_capacity = 0`

`capacity_accept_mask = 0`

`capacity_reject_mask = 0`

`accepted_change_mask = 0`

`accepted_changes = 0`

`capacity_remaining = CAPACITY_LIMIT`

`capacity_exhausted = 0`

`switch_load_numerator = 0`

All capacity event outputs are initialized to zero.

All capacity invariant outputs are initialized to one before validation.

The RTL qualification rejects inferred combinational latches.

The qualified capacity implementation contains:

`zero inferred latches`

## Tick-Enable Behavior

When:

`tick_enable = 0`

the pending-completion loop does not admit candidates.

The explicit request-lane loop does not admit candidates.

The outputs remain:

`request_accept_capacity = 0`

`request_reject_capacity = 0`

`capacity_accept_mask = 0`

`capacity_reject_mask = 0`

`accepted_change_mask = 0`

`accepted_changes = 0`

`capacity_remaining = REQUEST_LANES`

`capacity_exhausted = 0`

`switch_load_numerator = 0`

Required integrated relation:

`tick_enable = 0 → no retained-state writeback`

## Accepted Change Definition

A state-changing candidate satisfies:

`state_q[cell] != state_candidate_d[cell]`

An accepted state-changing candidate:

- sets `capacity_accept_mask[cell]`;
- sets `accepted_change_mask[cell]`;
- increments `accepted_changes`;
- increments `capacity_accept_events`;
- increments `accepted_change_events`.

A same-state accepted request:

- sets `request_accept_capacity[lane]`;
- sets `capacity_accept_mask[cell]`;
- does not set `accepted_change_mask[cell]`;
- does not increment `accepted_changes`.

A rejected candidate does not set:

`accepted_change_mask`

and does not increment:

`accepted_changes`

## Deterministic Candidate Order

The capacity guard evaluates candidates in this order:

1. pending-completion candidates in ascending cell-index order;
2. pre-capacity accepted explicit request lanes in ascending lane order.

Pending-completion order is:

`cell 0 → cell 1 → ... → cell CELLS - 1`

Explicit request order is:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

The value of `accepted_changes` is updated after every accepted state-changing candidate.

Each following candidate observes the updated remaining capacity.

## Pending-Completion Admission

For each pending-completion candidate, the guard reads:

- current retained state from `state_q`;
- candidate completion state from `state_candidate_d`;
- current accepted-change count.

A pending completion is structurally valid when:

- current retained state belongs to `{-1, 0, 1}`;
- candidate completion state belongs to `{-1, 0, 1}`;
- current retained state is `0`;
- candidate completion state is nonzero;
- candidate completion changes retained state.

For a structurally valid completion, the guard increments:

`capacity_candidate_events`

If capacity is available, it:

- sets `capacity_accept_mask[cell]`;
- sets `accepted_change_mask[cell]`;
- increments `accepted_changes`;
- increments `capacity_accept_events`;
- increments `accepted_change_events`.

If capacity is unavailable, it:

- sets `capacity_reject_mask[cell]`;
- increments `capacity_reject_events`.

A structurally invalid completion:

- sets `capacity_reject_mask[cell]`;
- increments `capacity_reject_events`;
- clears `pending_capacity_valid`.

## Explicit Request-Lane Admission

For each pre-capacity accepted explicit request lane, the guard extracts:

- requested cell index;
- transition class;
- current retained state;
- pre-capacity candidate state.

Supported explicit transition classes are:

- `FRP_TRANS_SAME_STATE`;
- `FRP_TRANS_ZERO_TO_NONZERO`;
- `FRP_TRANS_NONZERO_TO_ZERO`;
- `FRP_TRANS_OPPOSITE_POLARITY`.

The explicit lane is rejected at the capacity boundary when the first matching condition is:

1. invalid cell index;
2. pending-completion candidate owns the cell;
3. an earlier capacity-accepted candidate owns the cell;
4. current state is invalid;
5. candidate state is invalid;
6. transition class is unsupported;
7. current state and candidate state are directly opposite;
8. opposite-polarity class lacks a legal active-neutral candidate;
9. transition class and state-change relation do not match;
10. no state-changing capacity remains.

A valid same-state request remains admissible without consuming state-changing capacity.

## Capacity Admission Rule

Capacity is available when:

`accepted_changes < CAPACITY_LIMIT`

A valid state-changing candidate is admitted when capacity is available.

Admission sets:

`capacity_accept_mask[cell] = 1`

`accepted_change_mask[cell] = 1`

For an explicit request lane, admission also sets:

`request_accept_capacity[lane] = 1`

The accepted-change count becomes:

`accepted_changes + 1`

Required bound:

`accepted_changes <= CAPACITY_LIMIT`

## Capacity Rejection Rule

A valid state-changing candidate is rejected when:

`accepted_changes = CAPACITY_LIMIT`

For an explicit request lane, rejection sets:

`request_reject_capacity[lane] = 1`

For the affected cell, rejection sets:

`capacity_reject_mask[cell] = 1`

Rejection increments:

`capacity_reject_events`

Capacity rejection does not authorize:

- retained-state writeback;
- pending-route creation;
- pending-route clearing;
- direct transition between `-1` and `1`;
- reserved-state writeback.

A clean capacity rejection does not increment:

`queue_overflow_events`

## Same-State Capacity Rule

A same-state explicit request satisfies:

`state_q[cell] = state_candidate_d[cell]`

and:

`transition_class = FRP_TRANS_SAME_STATE`

The request is accepted regardless of remaining state-changing capacity when no higher-priority candidate owns the cell.

The guard sets:

`request_accept_capacity[lane] = 1`

`capacity_accept_mask[cell] = 1`

It does not set:

`accepted_change_mask[cell]`

It does not increment:

`accepted_changes`

It does not increment:

`capacity_candidate_events`

It does not increment:

`capacity_accept_events`

Required relation:

`same-state retention consumes zero transition capacity`

## Zero-to-Nonzero Capacity Rule

A legal zero-to-nonzero candidate satisfies:

`state_q[cell] = 0`

and:

`state_candidate_d[cell] ∈ {-1, 1}`

and:

`transition_class = FRP_TRANS_ZERO_TO_NONZERO`

An accepted zero-to-nonzero candidate consumes one transition-capacity slot.

The accepted transition is:

`0 → -1`

or:

`0 → 1`

## Nonzero-to-Zero Capacity Rule

A legal nonzero-to-zero candidate satisfies:

`state_q[cell] ∈ {-1, 1}`

and:

`state_candidate_d[cell] = 0`

and:

`transition_class = FRP_TRANS_NONZERO_TO_ZERO`

An accepted nonzero-to-zero candidate consumes one transition-capacity slot.

The accepted transition is:

`-1 → 0`

or:

`1 → 0`

## Active-Neutral Routing Capacity Rule

For an explicit opposite-polarity class, a legal first-leg candidate requires:

- `transition_class = FRP_TRANS_OPPOSITE_POLARITY`;
- current retained state is nonzero;
- candidate state is `0`;
- current and candidate states differ;
- `neutral_routed_candidate[cell] = 1`.

The admitted first leg is:

`-1 → 0`

or:

`1 → 0`

It consumes one transition-capacity slot.

The originally requested opposite polarity is stored by the pending-route module only after this first leg receives capacity.

If the active-neutral relation is invalid, the guard:

- sets `request_reject_capacity`;
- sets `capacity_reject_mask`;
- increments `capacity_reject_events`;
- clears `active_neutral_capacity_valid`.

The guard never replaces a rejected first leg with a direct opposite-polarity transition.

## Pending-Completion Capacity Rule

A legal pending-route completion is:

`0 → pending_route_q[cell]`

where:

`pending_route_q[cell] ∈ {-1, 1}`

The completion consumes one transition-capacity slot.

Pending completions are evaluated before explicit request lanes.

If capacity is unavailable:

- the completion is not added to `capacity_accept_mask`;
- the completion is added to `capacity_reject_mask`;
- `accepted_change_mask` remains clear for that cell;
- the pending-route register retains its target;
- a new explicit request for the same cell remains blocked by pending-completion ownership.

Required relation:

`capacity deferral does not clear retained pending polarity`

## Scheduler Interaction

Scheduler transition eligibility is resolved upstream by:

- `frp_m16_request_lanes`;
- `frp_m16_active_neutral`;
- pending-completion candidate generation in `frp_m16_core`.

The capacity guard receives already classified transition candidates.

It does not redefine scheduler-state transition classes.

The capacity guard validates that:

`scheduler_state`

belongs to the valid scheduler-state domain.

The final `transition_capacity_valid` relation requires:

`frp_scheduler_state_is_valid(scheduler_state) = 1`

Every state-changing candidate admitted in any valid scheduler state remains subject to:

`accepted_changes <= REQUEST_LANES`

## Free-State Capacity Behavior

In `FREE`, upstream execution may present:

- zero-to-nonzero candidates;
- nonzero-to-zero candidates;
- opposite-polarity first-leg candidates;
- pending-completion candidates;
- same-state requests.

The capacity guard applies:

1. pending-completion priority;
2. ascending explicit request-lane order;
3. one capacity slot per accepted state-changing candidate;
4. zero capacity slots for same-state retention.

## Balance-State Capacity Behavior

In `BALANCE`, upstream execution may present:

- nonzero-to-zero candidates;
- opposite-polarity first-leg candidates;
- same-state requests.

Pending-route completion and zero-to-nonzero release are not scheduler-eligible in `BALANCE`.

Every admitted state-changing candidate remains capacity-bounded.

## Commit-State Capacity Behavior

In `COMMIT`, upstream execution may present:

- pending-route completion candidates;
- zero-to-nonzero candidates;
- same-state requests.

Pending completions are evaluated before explicit zero-to-nonzero request lanes.

Every admitted state-changing candidate remains capacity-bounded.

## Excite-State Capacity Behavior

In `EXCITE`, upstream execution may present:

- pending-route completion candidates;
- zero-to-nonzero candidates;
- same-state requests.

Pending completions retain priority over explicit request lanes.

Every admitted state-changing candidate remains capacity-bounded.

## Neutralize-State Capacity Behavior

In `NEUTRALIZE`, upstream execution may present:

- nonzero-to-zero candidates;
- opposite-polarity first-leg candidates;
- same-state requests.

Pending-route completion and zero-to-nonzero release are not scheduler-eligible in `NEUTRALIZE`.

Every admitted state-changing candidate remains capacity-bounded.

## Switch-Load Relation

The capacity guard emits:

`switch_load_numerator`

The implemented relation is:

`switch_load_numerator = accepted_changes`

The normalized processor quantity is:

`switch_load = switch_load_numerator / CELLS`

For the qualified profiles:

| Cells | Request lanes | Maximum numerator | Maximum normalized switch load |
|---:|---:|---:|---:|
| `8` | `2` | `2` | `0.25` |
| `16` | `4` | `4` | `0.25` |
| `32` | `8` | `8` | `0.25` |

The RTL capacity guard emits the integer numerator.

It does not perform physical thermal measurement.

## Capacity Exhaustion

Capacity is exhausted when:

`accepted_changes = REQUEST_LANES`

The module then sets:

`capacity_exhausted = 1`

and:

`capacity_exhausted_events = 1`

Additional state-changing candidates are rejected.

Same-state requests may remain admissible without increasing `accepted_changes`.

Required relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

## Capacity Remaining

During enabled execution:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required bounds:

`capacity_remaining >= 0`

`capacity_remaining <= REQUEST_LANES`

When `tick_enable = 0`:

`accepted_changes = 0`

and:

`capacity_remaining = REQUEST_LANES`

The value is recomputed for each combinational capacity evaluation.

## Interaction With Pending Routes

Pending completion candidates are evaluated before explicit request lanes.

An accepted pending completion:

- sets `capacity_accept_mask`;
- sets `accepted_change_mask`;
- increments `accepted_changes`;
- authorizes pending-route clearing;
- authorizes retained-state completion writeback.

A capacity-rejected pending completion:

- sets `capacity_reject_mask`;
- does not set `accepted_change_mask`;
- does not authorize pending-route clearing;
- does not authorize retained-state completion writeback.

The retained pending target remains available for a later eligible tick.

A new explicit request for the same cell remains blocked by pending-completion ownership even when the completion is deferred by exhausted capacity.

Required relation:

`capacity deferral preserves retained pending polarity`

## Interaction With Active-Neutral Routing

An opposite-polarity request reaches the capacity guard as a first-leg candidate:

`-1 → 0`

or:

`1 → 0`

The capacity guard verifies:

- current state is nonzero;
- candidate state is `0`;
- current and candidate states differ;
- `neutral_routed_candidate[cell] = 1`;
- current and candidate states are not directly opposite.

An accepted first leg:

- consumes one capacity slot;
- sets `capacity_accept_mask`;
- sets `accepted_change_mask`;
- permits pending-route creation;
- permits retained-state writeback to `0`.

A rejected first leg:

- does not create a pending route;
- does not modify retained state;
- does not authorize a direct transition between `-1` and `1`.

The later completion leg consumes a separate capacity slot on its completion tick.

## Direct Candidate Guard

For each explicit request cell, the guard compares:

`state_q[cell]`

with:

`state_candidate_d[cell]`

If they are opposite nonzero polarities, the module sets:

`direct_candidate_mask[cell] = 1`

The lane is rejected at the capacity boundary.

The module clears:

`transition_capacity_valid`

and:

`active_neutral_capacity_valid`

The final direct-candidate relation is:

```systemverilog
(
    capacity_accept_mask
    & direct_candidate_mask
)
==
0
```

The corresponding module output is:

`no_actual_direct_events`

Qualified value:

`actual_direct_events = 0`

## Interaction With Reserved States

The capacity guard validates:

- current retained state;
- candidate state;
- explicit transition class.

A lane is rejected when:

- current retained state is outside `{-1, 0, 1}`;
- candidate state is outside `{-1, 0, 1}`;
- transition class is unsupported.

A structurally invalid pending completion is also rejected.

The guard does not convert a reserved value into an accepted transition.

Reserved-state aggregation remains connected to the active-neutral, pending-route, and retained-state writeback stages.

Qualified value:

`reserved_state_events = 0`

## Capacity Event Relations

The event relations are:

`capacity_accept_events = accepted_change_events`

`accepted_change_events = accepted_changes`

for accepted state-changing candidates in the current combinational evaluation.

A same-state accepted request does not increment either count.

The exhaustion event relation is:

`capacity_exhausted_events = 1`

when:

`accepted_changes = REQUEST_LANES`

Otherwise:

`capacity_exhausted_events = 0`

The switch-load relation is:

`switch_load_numerator = accepted_changes`

## Accepted-Change Correlation

The capacity guard produces:

`accepted_change_mask`

The integrated assertion layer requires:

```systemverilog
$countones(accepted_change_mask)
==
accepted_changes
```

The retained-state update module receives:

- `state_candidate_d`;
- `capacity_accept_mask`;
- `accepted_change_candidate_mask`.

The integrated transition-capacity flag also requires:

`capacity_accepted_changes = state_update_accepted_changes`

`capacity_accepted_change_mask = state_write_enable_mask`

`capacity_switch_load_numerator = state_update_switch_load_numerator`

## Capacity Invariant Relations

The accepted-change bound is:

```systemverilog
accepted_changes_within_limit =
    (accepted_changes <= CAPACITY_LIMIT);
```

The remaining-capacity relation is:

```systemverilog
capacity_remaining_valid =
    accepted_changes_within_limit
    && (capacity_remaining <= CAPACITY_LIMIT)
    && (
        capacity_remaining
        ==
        (CAPACITY_LIMIT - accepted_changes)
    );
```

The exhaustion relation is:

```systemverilog
capacity_exhaustion_valid =
    (
        capacity_exhausted
        ==
        (accepted_changes == CAPACITY_LIMIT)
    );
```

The same-state relation includes:

```systemverilog
capacity_accept_events
==
accepted_change_events
```

The active-neutral capacity relation is:

```systemverilog
(
    accepted_change_mask
    & neutral_routed_candidate
)
==
(
    capacity_accept_mask
    & neutral_routed_candidate
)
```

The switch-load relation is:

```systemverilog
switch_load_numerator <= CAPACITY_LIMIT
```

and:

```systemverilog
switch_load_numerator == accepted_changes
```

## Final Capacity Invariant Output

The module calculates:

```systemverilog
transition_capacity_valid =
    transition_capacity_valid
    && frp_scheduler_state_is_valid(scheduler_state)
    && accepted_changes_within_limit
    && capacity_remaining_valid
    && capacity_exhaustion_valid
    && same_state_capacity_valid
    && pending_capacity_valid
    && active_neutral_capacity_valid
    && switch_load_bound_valid
    && no_queue_overflow
    && no_actual_direct_events;
```

The module-level queue relation is:

`no_queue_overflow = 1`

The capacity guard contains no pending-route queue.

Pending-route queue-overflow detection is performed by:

`frp_m16_pending_routes`

A clean capacity rejection is not a queue-overflow event.

## Integrated Transition-Capacity Invariant Flag

The integrated flag is:

`FRP_INV_TRANSITION_CAPACITY_VALID`

It includes:

- request-stage capacity bound;
- active-neutral candidate accounting;
- capacity-guard validation;
- accepted-change bound;
- capacity-remaining relation;
- capacity-exhaustion relation;
- same-state capacity relation;
- pending-completion capacity validation;
- active-neutral capacity validation;
- switch-load relation;
- capacity and writeback accepted-change count equality;
- capacity and writeback mask equality;
- capacity and writeback switch-load equality.

The qualified integrated invariant vector is:

`1111111111`

## Assertion Support

The bound assertion artifact is:

`rtl/m16/frp_m16_assertions.sv`

The integrated capacity assertions check:

| Assertion boundary | Required relation |
|---|---|
| disabled tick | no accepted request, cell, change mask, or accepted change |
| accepted-cell bound | `popcount(accepted_cell_mask) <= REQUEST_LANES` |
| accepted-change correlation | `popcount(accepted_change_mask) = accepted_changes` |
| neutral-route ownership | neutral-routed cells are accepted cells |
| neutral-route change | neutral-routed cells are accepted changes |
| accepted-change bound | `accepted_changes <= REQUEST_LANES` |
| remaining capacity | `capacity_remaining = REQUEST_LANES - accepted_changes` |
| exhausted capacity | `capacity_exhausted = (accepted_changes == REQUEST_LANES)` |
| switch-load numerator | `switch_load_numerator = accepted_changes` |
| actual direct events | `actual_direct_events = 0` |
| reserved-state events | `reserved_state_events = 0` |
| queue-overflow events | `queue_overflow_events = 0` |
| transition-capacity flag | `FRP_INV_TRANSITION_CAPACITY_VALID = 1` |

Per-cell assertions also require:

- state-changing writeback has an accepted-change bit;
- capacity rejection preserves retained state;
- neutral-route writeback is capacity accepted;
- pending completion is capacity accepted before writeback;
- direct opposite-polarity writeback remains absent.

## Deterministic RTL Testbench Record

The executable testbench is:

`rtl/m16/frp_m16_tb.sv`

The qualified parameter profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |

During the free-mode capacity tick, two explicit state-changing requests are admitted:

`cell 1: 0 → 1`

`cell 2: 0 → 1`

Recorded values:

`accepted_changes = 2`

`capacity_remaining = 0`

`capacity_exhausted = 1`

`switch_load_numerator = 2`

The testbench also executes:

- opposite-polarity first-leg capacity admission;
- pending-completion capacity admission;
- same-state retention without capacity consumption;
- capacity correlation with retained-state writeback;
- exact zero-event checks after every qualified tick.

## Transition-Capacity Qualification Record

The recorded relations are:

| Capacity relation | Result |
|---|---|
| bounded accepted changes | `PASS` |
| capacity-remaining relation | `PASS` |
| capacity-exhausted relation | `PASS` |
| switch-load relation | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has priority | `PASS` |
| explicit requests preserve lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |
| capacity rejection preserves retained state | `PASS` |
| direct opposite-polarity capacity acceptance absent | `PASS` |
| queue-overflow event absent | `PASS` |

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

The M16 capacity implementation retains:

- `transition_fraction = 0.25`;
- compile-time request-lane capacity;
- pending-completion priority;
- deterministic explicit request ordering;
- same-state retention without capacity use;
- one capacity slot per state-changing tick leg;
- active-neutral first-leg capacity admission;
- separate completion-leg capacity admission;
- retained pending polarity during deferral;
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

Transition-capacity qualification result:

`PASS`

RTL closure state:

`M16 RTL EXECUTION LAYER CLOSED`

## FPGA Integration Qualification Record

The target-independent FPGA integration top is:

`fpga/m16/frp_m16_fpga_top.sv`

The executable FPGA integration testbench is:

`fpga/m16/frp_m16_fpga_tb.sv`

The FPGA testbench records a zero-to-nonzero request with:

`request_accept[0] = 1`

`accepted_cell_mask[0] = 1`

`accepted_change_mask[0] = 1`

`accepted_changes = 1`

`switch_load_numerator = 1`

The active-neutral first leg records one accepted state change.

The retained pending completion also records:

`accepted_change_mask[0] = 1`

`accepted_changes = 1`

`switch_load_numerator = 1`

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

The implemented transition-capacity artifact records:

- compile-time capacity parameterization;
- pending-completion priority;
- deterministic ascending cell order;
- deterministic ascending request-lane order;
- supported transition-class validation;
- same-state acceptance without capacity consumption;
- state-changing candidate admission;
- capacity rejection;
- capacity-exhaustion detection;
- capacity-remaining calculation;
- accepted-change mask and count correlation;
- switch-load numerator generation;
- active-neutral first-leg validation;
- pending-completion capacity validation;
- direct-candidate rejection;
- reserved-candidate rejection;
- retained-state writeback correlation;
- assertion execution;
- executable deterministic testbench coverage;
- FPGA integration propagation;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- repository-integrity validation;
- qualification artifact generation.

Final transition-capacity result:

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
- `docs/m16_active_neutral_transition_module.md`;
- `docs/m16_pending_route_register_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`.

## Author

Maksym Marnov

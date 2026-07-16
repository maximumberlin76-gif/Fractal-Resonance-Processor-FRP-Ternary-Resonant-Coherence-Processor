# FRP M16 Request-Lane Arbitration Module

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

This document records the implemented request-lane arbitration module for the M16 RTL core realization layer.

The implemented artifact is:

`rtl/m16/frp_m16_request_lanes.sv`

The module is:

`frp_m16_request_lanes`

The request-lane arbitration layer preserves the M15-qualified execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

M16 realizes deterministic request acceptance, request rejection, request ordering, scheduler-qualified admission, pending-route ownership, opposite-polarity request classification, and pre-capacity request telemetry in SystemVerilog.

Final transition-capacity admission is performed by:

`rtl/m16/frp_m16_capacity_guard.sv`

## Implemented Artifact Boundary

The request-lane arbitration module receives deterministic explicit transition requests for the current tick.

It processes:

- request-valid flags;
- packed request cell indexes;
- packed balanced ternary request targets;
- retained balanced ternary state;
- registered phase-derived target state;
- retained pending-route state;
- current registered scheduler state;
- tick execution enable;
- deterministic ascending request-lane order;
- cell-index validity;
- target-domain validity;
- duplicate-cell ownership;
- retained pending-route ownership;
- scheduler transition eligibility;
- accepted-lane candidates;
- rejected-lane results;
- active-neutral request classification;
- request-stage event telemetry;
- request-stage invariant signals.

The module does not compute:

- Kuramoto-Sakaguchi phase coupling;
- phase words;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived target generation;
- final transition-capacity admission;
- retained pending-route writeback;
- retained-state writeback.

The upstream resonant computation layer remains responsible for generating the registered phase-derived ternary target vector.

The downstream M16 RTL execution chain performs:

- active-neutral transition candidate generation;
- transition-capacity admission;
- pending-route register update;
- retained-state writeback;
- integrated invariant aggregation.

## Integrated Execution Position

For explicit request lanes, the implemented execution order is:

`registered scheduler state`

→ `explicit request-lane evaluation`

→ `deterministic ascending-lane arbitration`

→ `active-neutral transition candidate generation`

→ `transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

The integrated files are:

- `rtl/m16/frp_m16_scheduler.sv`;
- `rtl/m16/frp_m16_request_lanes.sv`;
- `rtl/m16/frp_m16_active_neutral.sv`;
- `rtl/m16/frp_m16_capacity_guard.sv`;
- `rtl/m16/frp_m16_pending_routes.sv`;
- `rtl/m16/frp_m16_state_update.sv`;
- `rtl/m16/frp_m16_core.sv`.

Retained pending-route completion candidates are derived independently from explicit request lanes and enter the transition-capacity boundary before retained-state writeback.

## Core Identity Preserved

The request-lane arbitration module preserves:

- the balanced ternary retained-state domain `{-1, 0, 1}`;
- active neutral state `0`;
- forbidden direct retained-state transitions between `-1` and `1`;
- opposite-polarity routing through active neutral `0`;
- deterministic ascending request-lane order;
- one accepted explicit request per cell per tick;
- retained pending-route ownership before new same-cell requests;
- scheduler-qualified transition admission;
- distributed transition-capacity enforcement;
- deterministic event accounting;
- M15 semantic compatibility.

The required opposite-polarity execution paths remain:

`-1 → 0 → 1`

`1 → 0 → -1`

## Canonical Ternary Encoding

The request-lane arbitration module imports the canonical encoding from:

`rtl/m16/frp_m16_pkg.sv`

| Ternary state | SystemVerilog symbol | Encoding |
|---|---|---|
| `-1` | `FRP_TERN_NEG` | `2'b11` |
| `0` | `FRP_TERN_ZERO` | `2'b00` |
| `1` | `FRP_TERN_POS` | `2'b01` |
| reserved | `FRP_TERN_RESERVED` | `2'b10` |

The corresponding shared state constants are:

| Ternary state | Shared constant |
|---|---|
| `-1` | `FRP_STATE_NEG` |
| `0` | `FRP_STATE_ZERO` |
| `1` | `FRP_STATE_POS` |
| reserved | `FRP_STATE_RESERVED` |

The active-neutral constant is:

`FRP_ACTIVE_NEUTRAL = FRP_STATE_ZERO`

The reserved encoding is outside the valid retained-state and request-target domain.

Required integrated relation:

`reserved_state_events = 0`

## Module Parameterization

The module parameters are:

| Parameter | Definition |
|---|---|
| `CELLS` | number of retained balanced ternary cells |
| `STATE_BITS` | packed width of one ternary state |
| `REQUEST_LANES` | number of explicit request lanes |
| `CELL_INDEX_BITS` | packed cell-index width |
| `COUNTER_BITS` | request-stage event-counter width |

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

## Request-Lane Count

M16 preserves the M15 transition-fraction boundary:

`transition_fraction = 0.25`

The package constants are:

`FRP_M16_TRANSITION_FRACTION_NUM = 1`

`FRP_M16_TRANSITION_FRACTION_DEN = 4`

The exact RTL calculation is:

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

The qualified profiles are:

| Cells | Request lanes |
|---:|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

For the qualified M16 architectural simulation:

`CELLS = 8`

`REQUEST_LANES = 2`

Required integrated relation:

`accepted_changes <= REQUEST_LANES`

## Request-Lane Inputs

The request-lane arbitration module consumes:

| Signal | Width | Function |
|---|---:|---|
| `tick_enable` | `1` | enables request evaluation for the current processor tick |
| `scheduler_state` | scheduler-state width | registered temporal scheduler state |
| `request_valid` | `REQUEST_LANES` | valid flag for each explicit request lane |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | packed requested cell index for each lane |
| `request_target` | `REQUEST_LANES × STATE_BITS` | packed balanced ternary target for each lane |
| `state_q` | `CELLS × STATE_BITS` | retained balanced ternary state at tick start |
| `target_q` | `CELLS × STATE_BITS` | registered phase-derived target vector |
| `pending_route_q` | `CELLS × STATE_BITS` | retained pending-route vector |

The explicit request classification uses:

- the selected cell value from `state_q`;
- the selected lane value from `request_target`;
- `FRP_STATE_ZERO` as the pending operand for explicit-lane classification.

The complete `target_q` vector participates in domain validation.

The complete `pending_route_q` vector participates in domain validation and per-cell pending ownership.

## Lane-Decision Outputs

The module emits the following lane-decision signals:

| Signal | Width | Function |
|---|---:|---|
| `request_accept` | `REQUEST_LANES` | pre-capacity accepted explicit request lanes |
| `request_reject` | `REQUEST_LANES` | explicit request lanes rejected during arbitration |
| `request_reject_invalid_cell` | `REQUEST_LANES` | rejection caused by an out-of-range cell index |
| `request_reject_invalid_target` | `REQUEST_LANES` | rejection caused by a reserved request-target encoding |
| `request_reject_duplicate_cell` | `REQUEST_LANES` | rejection caused by earlier accepted ownership of the same cell |
| `request_reject_scheduler` | `REQUEST_LANES` | rejection caused by scheduler ineligibility |
| `request_reject_capacity` | `REQUEST_LANES` | local capacity-rejection output |
| `request_reject_pending_busy` | `REQUEST_LANES` | rejection caused by retained pending-route ownership |
| `request_reject_tick_disabled` | `REQUEST_LANES` | valid lanes observed while tick execution is disabled |
| `request_neutralized` | `REQUEST_LANES` | accepted opposite-polarity requests assigned to active-neutral routing |

Within `frp_m16_request_lanes`:

`request_reject_capacity = 0`

Final capacity rejection is produced by:

`frp_m16_capacity_guard`

The integrated core publishes:

`request_accept = request_accept_capacity`

and:

`request_reject = request_reject_lane | request_reject_capacity`

## Cell-Mask Outputs

The module emits:

| Signal | Width | Function |
|---|---:|---|
| `accepted_cell_mask` | `CELLS` | cells owned by pre-capacity accepted explicit requests |
| `rejected_cell_mask` | `CELLS` | valid indexed cells rejected during arbitration |
| `neutral_routed_cell_mask` | `CELLS` | accepted opposite-polarity request cells assigned to neutral routing |
| `requested_direct_cell_mask` | `CELLS` | accepted opposite-polarity request cells |

The integrated core applies the downstream capacity mask:

`accepted_cell_mask = request_accepted_cell_mask & capacity_accept_mask`

and:

`neutral_routed_cell_mask = transition_neutral_routed_mask & capacity_accept_mask`

## Request-Stage Telemetry Outputs

The request-lane module emits:

| Signal | Function |
|---|---|
| `accepted_changes` | pre-capacity accepted explicit lanes whose requested target differs from retained state |
| `requested_lane_events` | valid explicit lanes evaluated while `tick_enable = 1` |
| `accepted_lane_events` | explicit lanes accepted before capacity admission |
| `rejected_lane_events` | explicit lanes rejected during request arbitration |
| `requested_direct_events` | accepted opposite-polarity requests |
| `prevented_direct_events` | accepted opposite-polarity requests assigned to neutral routing |
| `neutral_routed_events` | accepted opposite-polarity requests assigned to active neutral `0` |

A same-state accepted request does not increment:

`accepted_changes`

The integrated public direct-event counters are sourced from the active-neutral transition stage so that the same transition is not counted repeatedly at multiple execution stages.

## Request-Stage Invariant Outputs

The module emits:

- `request_lane_order_valid`;
- `request_cell_domain_valid`;
- `request_target_domain_valid`;
- `duplicate_cell_guard_valid`;
- `scheduler_gate_valid`;
- `transition_capacity_valid`;
- `active_neutral_routing_valid`;
- `no_actual_direct_events`;
- `no_queue_overflow`.

These signals participate in the integrated M16 invariant vector.

The request-lane invariant flag is assembled from:

```systemverilog
request_lane_order_valid
&& request_cell_domain_valid
&& request_target_domain_valid
&& duplicate_cell_guard_valid
&& request_scheduler_gate_valid
&& request_transition_capacity_valid
&& request_active_neutral_routing_valid
```

## Deterministic Combinational Evaluation

The request-lane module is combinational.

All public outputs, internal per-cell values, internal per-lane values, masks, counters, and invariant signals receive default assignments before request evaluation.

The RTL qualification rejects inferred combinational latches.

The qualified request-lane implementation contains:

`zero inferred latches`

## Domain Validation

Before explicit lane evaluation, the module scans every retained cell.

For each cell:

- `state_q` must contain one of `{-1, 0, 1}`;
- `target_q` must contain one of `{-1, 0, 1}`;
- `pending_route_q` must contain one of `{-1, 0, 1}`.

An invalid value in `state_q` clears:

`request_cell_domain_valid`

An invalid value in `target_q` clears:

`request_target_domain_valid`

An invalid value in `pending_route_q` clears:

`request_target_domain_valid`

Per-lane validation also clears the corresponding domain-valid signal when an invalid cell index or invalid target encoding is evaluated.

## Tick-Enable Gating

When:

`tick_enable = 0`

the module assigns:

`request_accept = 0`

`request_reject = 0`

`accepted_changes = 0`

`requested_lane_events = 0`

`accepted_lane_events = 0`

`rejected_lane_events = 0`

and:

`request_reject_tick_disabled = request_valid`

No explicit request proceeds to active-neutral candidate generation while tick execution is disabled.

Required relation:

`tick_enable = 0 → request_accept = 0`

## Deterministic Lane Order

When `tick_enable = 1`, explicit request lanes are evaluated in ascending order:

`lane 0`

→ `lane 1`

→ `lane 2`

→ `...`

→ `lane REQUEST_LANES - 1`

Each accepted lane updates `accepted_cell_mask` before the next lane is evaluated.

A later lane targeting a cell already owned by an earlier accepted lane is classified as a duplicate-cell request.

An earlier rejected lane does not claim accepted ownership of the cell.

Required relation:

`one pre-capacity accepted explicit request per cell per tick`

## Cell-Index Validity

For each valid request lane, the packed cell index is extracted from:

`request_cell_index`

A request cell index is valid when:

`request_cell_index < CELLS`

If:

`request_cell_index >= CELLS`

then:

`request_reject = 1`

`request_reject_invalid_cell = 1`

`request_accept = 0`

and:

`request_cell_domain_valid = 0`

An invalid cell index does not set a bit in:

- `accepted_cell_mask`;
- `rejected_cell_mask`;
- `neutral_routed_cell_mask`;
- `requested_direct_cell_mask`.

## Target Validity

For each lane, the packed request target is extracted from:

`request_target`

A request target is valid only when its encoding represents:

`-1`

`0`

`1`

The reserved encoding is:

`2'b10`

If the target encoding is reserved:

`request_reject = 1`

`request_reject_invalid_target = 1`

`request_accept = 0`

and:

`request_target_domain_valid = 0`

For a valid cell index, the rejected cell is recorded in:

`rejected_cell_mask`

Required relation:

`reserved request targets are never accepted`

## Duplicate-Cell Handling

A lane is a duplicate when:

- its cell index is valid; and
- the corresponding bit is already set in `accepted_cell_mask`.

The first accepted lane in ascending order owns the cell for the current tick.

A later valid lane requesting the same cell receives:

`request_reject = 1`

`request_reject_duplicate_cell = 1`

`request_accept = 0`

The rejected cell is recorded in:

`rejected_cell_mask`

The duplicate-cell guard requires:

```systemverilog
(request_accept & request_reject_duplicate_cell) == 0
```

## Retained Pending-Route Ownership

For each valid indexed lane, the module reads the corresponding value from:

`pending_route_q`

A cell is pending-busy when:

`pending_route_q[cell] != 0`

A new explicit request targeting a pending-busy cell receives:

`request_reject = 1`

`request_reject_pending_busy = 1`

`request_accept = 0`

The rejected cell is recorded in:

`rejected_cell_mask`

Pending-route completion is not classified as a new explicit request-lane operation.

Pending-route completion candidates are derived separately in `frp_m16_core` from:

- retained state equal to `0`;
- retained pending target different from `0`;
- commit-capable scheduler state;
- enabled processor tick.

## Explicit Request Classification

For each lane, the request module calls:

`frp_classify_transition(retained_state, requested_target, FRP_STATE_ZERO)`

The explicit request classes are:

| Transition class | Condition |
|---|---|
| `FRP_TRANS_SAME_STATE` | retained state equals requested target |
| `FRP_TRANS_ZERO_TO_NONZERO` | retained state is `0` and requested target is `-1` or `1` |
| `FRP_TRANS_NONZERO_TO_ZERO` | retained state is `-1` or `1` and requested target is `0` |
| `FRP_TRANS_OPPOSITE_POLARITY` | retained state and requested target are opposite nonzero polarities |
| `FRP_TRANS_RESERVED_OPERAND` | retained state or requested target is outside `{-1, 0, 1}` |
| `FRP_TRANS_INVALID` | no defined transition relation matches |

Retained pending-route ownership is checked separately and blocks the new explicit request before scheduler-qualified acceptance.

## Rejection Evaluation Order

For each valid asserted request lane, the implemented decision order is:

1. invalid cell index;
2. invalid request target;
3. duplicate ownership by an earlier accepted lane;
4. retained pending-route ownership;
5. scheduler ineligibility;
6. pre-capacity acceptance.

Only one request-arbitration rejection class is selected for an evaluated lane.

Transition-capacity rejection is applied later by:

`frp_m16_capacity_guard`

## Acceptance and Rejection Separation

For every lane:

```systemverilog
(request_accept & request_reject) == 0
```

When `tick_enable = 1`, every asserted request-valid lane is assigned either pre-capacity acceptance or request-stage rejection:

```systemverilog
(request_accept | request_reject) == request_valid
```

The request-lane order relation is:

```systemverilog
request_lane_order_valid =
    ((request_accept & request_reject) == 0)
    && (
        !tick_enable
        || ((request_accept | request_reject) == request_valid)
    );
```

## Scheduler Eligibility

The request-lane module receives the registered scheduler state from:

`frp_m16_scheduler`

Valid scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`.

For explicit request classes, scheduler admission is:

| Explicit transition class | Eligible scheduler states |
|---|---|
| `FRP_TRANS_SAME_STATE` | every valid scheduler state |
| `FRP_TRANS_ZERO_TO_NONZERO` | `FREE`, `COMMIT`, `EXCITE` |
| `FRP_TRANS_NONZERO_TO_ZERO` | `FREE`, `BALANCE`, `NEUTRALIZE` |
| `FRP_TRANS_OPPOSITE_POLARITY` | `FREE`, `BALANCE`, `NEUTRALIZE` |
| reserved or invalid class | none |

The commit-capable scheduler states are:

`FREE`

`COMMIT`

`EXCITE`

The neutralize-capable scheduler states are:

`FREE`

`BALANCE`

`NEUTRALIZE`

If the scheduler does not admit the classified request:

`request_reject = 1`

`request_reject_scheduler = 1`

`request_accept = 0`

The scheduler gate relation requires:

```systemverilog
(request_accept & request_reject_scheduler) == 0
```

The scheduler state does not alter ascending lane order.

## Free-State Arbitration

The `FREE` scheduler state is both:

- commit-capable;
- neutralize-capable.

Subject to request validation, duplicate-cell guarding, pending-route ownership, and downstream transition capacity, `FREE` admits:

- same-state requests;
- zero-to-nonzero requests;
- nonzero-to-zero requests;
- opposite-polarity requests routed through active neutral `0`.

In `FREE`, retained pending-route completion candidates are eligible when:

- the retained state is `0`;
- the retained pending target is `-1` or `1`;
- `tick_enable = 1`.

The qualified free-mode testbench executes:

`16` ticks

Recorded scheduler counts:

| Scheduler state | Count |
|---|---:|
| `FREE` | `16` |
| `BALANCE` | `0` |
| `COMMIT` | `0` |
| `EXCITE` | `0` |
| `NEUTRALIZE` | `0` |

## Balance-State Arbitration

The `BALANCE` scheduler state is neutralize-capable.

Subject to request validation, pending-route ownership, and downstream transition capacity, `BALANCE` admits:

- same-state requests;
- nonzero-to-zero requests;
- opposite-polarity requests routed through active neutral `0`.

`BALANCE` does not admit:

- zero-to-nonzero explicit requests;
- pending-route completion.

A zero-to-nonzero explicit request receives:

`request_reject_scheduler = 1`

A retained pending route remains stored until a commit-capable scheduler state and available transition capacity coincide.

In the `7/1` profile, `BALANCE` occupies period indexes:

`0` through `6`

## Commit-State Arbitration

The `COMMIT` scheduler state is commit-capable.

Subject to request validation, pending-route ownership, and downstream transition capacity, `COMMIT` admits:

- same-state requests;
- zero-to-nonzero explicit requests;
- retained pending-route completion candidates.

`COMMIT` does not admit:

- nonzero-to-zero explicit requests;
- opposite-polarity explicit requests.

In the `7/1` profile, `COMMIT` occupies period index:

`7`

The qualified `7/1` testbench executes:

`64` ticks

Recorded scheduler counts:

| Scheduler state | Count |
|---|---:|
| `FREE` | `0` |
| `BALANCE` | `56` |
| `COMMIT` | `8` |
| `EXCITE` | `0` |
| `NEUTRALIZE` | `0` |

## Excite-State Arbitration

The `EXCITE` scheduler state is commit-capable.

Subject to request validation, pending-route ownership, and downstream transition capacity, `EXCITE` admits:

- same-state requests;
- zero-to-nonzero explicit requests;
- retained pending-route completion candidates.

`EXCITE` does not admit:

- nonzero-to-zero explicit requests;
- opposite-polarity explicit requests.

In the `1/7` profile, `EXCITE` occupies period index:

`0`

## Neutralize-State Arbitration

The `NEUTRALIZE` scheduler state is neutralize-capable.

Subject to request validation, pending-route ownership, and downstream transition capacity, `NEUTRALIZE` admits:

- same-state requests;
- nonzero-to-zero explicit requests;
- opposite-polarity explicit requests routed through active neutral `0`.

`NEUTRALIZE` does not admit:

- zero-to-nonzero explicit requests;
- pending-route completion.

In the `1/7` profile, `NEUTRALIZE` occupies period indexes:

`1` through `7`

The qualified `1/7` testbench executes:

`16` ticks

Recorded scheduler counts:

| Scheduler state | Count |
|---|---:|
| `FREE` | `0` |
| `BALANCE` | `0` |
| `COMMIT` | `0` |
| `EXCITE` | `2` |
| `NEUTRALIZE` | `14` |

## Same-State Request

A same-state request satisfies:

`state_q[cell] = request_target[lane]`

The request is eligible in every valid scheduler state.

At the request-lane stage, an accepted same-state request:

- sets `request_accept`;
- claims the corresponding bit in `accepted_cell_mask`;
- increments `accepted_lane_events`;
- does not increment `accepted_changes`;
- does not set `request_neutralized`;
- does not increment direct-request counters;
- does not create a pending route.

At the transition-capacity boundary, same-state retention does not consume a capacity slot.

Required relation:

`same-state retention → accepted_changes increment = 0`

## Zero-to-Nonzero Request

A zero-to-nonzero request satisfies:

`state_q[cell] = 0`

and:

`request_target[lane] ∈ {-1, 1}`

The legal retained-state transition is:

`0 → -1`

or:

`0 → 1`

The request is scheduler-eligible in:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

A state-changing zero-to-nonzero transition consumes one transition-capacity slot.

No pending route is created.

## Nonzero-to-Zero Request

A nonzero-to-zero request satisfies:

`state_q[cell] ∈ {-1, 1}`

and:

`request_target[lane] = 0`

The legal retained-state transition is:

`-1 → 0`

or:

`1 → 0`

The request is scheduler-eligible in:

- `FREE`;
- `BALANCE`;
- `NEUTRALIZE`.

A state-changing nonzero-to-zero transition consumes one transition-capacity slot.

No pending route is created unless the request is the first leg of an opposite-polarity route.

## Opposite-Polarity Request

An opposite-polarity request satisfies either:

`state_q[cell] = -1`

and:

`request_target[lane] = 1`

or:

`state_q[cell] = 1`

and:

`request_target[lane] = -1`

Direct retained-state execution is forbidden.

The legal execution sequences are:

`-1 → 0 → 1`

`1 → 0 → -1`

The request is scheduler-eligible in:

- `FREE`;
- `BALANCE`;
- `NEUTRALIZE`.

For an accepted pre-capacity opposite-polarity request, the request-lane module sets:

`request_neutralized[lane] = 1`

The request-lane module also sets the corresponding bits in:

- `requested_direct_cell_mask`;
- `neutral_routed_cell_mask`.

The request-stage counters increment as:

`requested_direct_events += 1`

`prevented_direct_events += 1`

`neutral_routed_events += 1`

The downstream active-neutral module selects:

`state_candidate_d[cell] = 0`

The pending-route module retains the originally requested opposite polarity after capacity admission of the first leg.

## Active-Neutral Routing Boundary

The first leg of an opposite-polarity route is:

`-1 → 0`

or:

`1 → 0`

The first leg:

- requires scheduler eligibility;
- requires one transition-capacity slot;
- commits retained state `0`;
- stores the requested opposite polarity in `pending_route_q`.

The second leg is:

`0 → 1`

or:

`0 → -1`

The second leg:

- occurs on a later enabled tick;
- requires a commit-capable scheduler state;
- requires one transition-capacity slot;
- uses the retained pending target;
- clears the pending route after accepted completion.

Each leg independently consumes transition capacity.

Required integrated relations:

`actual_direct_events = 0`

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

## Pending-Completion Boundary

Pending-route completion is not accepted through a new explicit request lane.

The integrated core derives:

`pending_completion_candidate`

for each cell when:

- `tick_enable = 1`;
- retained state is `0`;
- retained pending target is `-1` or `1`;
- the registered scheduler state is commit-capable.

Commit-capable states are:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

The transition-capacity guard evaluates pending completion candidates before explicit request lanes.

Pending completion candidates are evaluated in ascending cell-index order.

An accepted pending completion:

- consumes one transition-capacity slot;
- sets the corresponding bit in `capacity_accept_mask`;
- sets the corresponding bit in `accepted_change_mask`;
- increments `accepted_changes`;
- writes the retained pending polarity into retained state;
- clears the accepted pending route.

A pending completion rejected because capacity is exhausted remains retained for a later eligible tick.

## Pending-Completion Priority

The implemented priority order is:

1. pending completion candidates in ascending cell-index order;
2. pre-capacity accepted explicit requests in ascending lane order.

A new explicit request targeting a cell with a retained pending route is rejected by the request-lane module through:

`request_reject_pending_busy`

The transition-capacity guard also prevents an explicit request from taking ownership of a cell with a pending completion candidate.

Required relations:

- pending-route target polarity remains unchanged during deferral;
- pending completion occurs only from retained state `0`;
- an accepted completion clears the pending route;
- a rejected completion does not clear the pending route.

## Transition-Capacity Boundary

The request-lane module produces pre-capacity accepted explicit request candidates.

Its local bound is:

`request_accepted_changes <= REQUEST_LANES`

Final integrated transition-capacity admission is performed by:

`rtl/m16/frp_m16_capacity_guard.sv`

The final admission order is:

1. pending completion candidates in ascending cell-index order;
2. explicit request candidates in ascending request-lane order.

The capacity limit is:

`CAPACITY_LIMIT = REQUEST_LANES`

A state-changing operation consumes one capacity slot for each accepted tick leg.

Capacity-consuming transition classes are:

- `FRP_TRANS_ZERO_TO_NONZERO`;
- `FRP_TRANS_NONZERO_TO_ZERO`;
- `FRP_TRANS_OPPOSITE_POLARITY`;
- `FRP_TRANS_PENDING_COMPLETION`.

Same-state retention consumes no capacity.

The integrated relations are:

```systemverilog
accepted_changes <= REQUEST_LANES
```

```systemverilog
capacity_remaining =
    REQUEST_LANES - accepted_changes
```

```systemverilog
capacity_exhausted =
    (accepted_changes == REQUEST_LANES)
```

```systemverilog
switch_load_numerator =
    accepted_changes
```

```systemverilog
popcount(accepted_change_mask) =
    accepted_changes
```

## Capacity Rejection

If a state-changing candidate reaches the capacity boundary when:

`accepted_changes = REQUEST_LANES`

the capacity guard sets:

`request_reject_capacity = 1`

for the affected explicit request lane.

The capacity guard does not set:

`request_accept_capacity`

for that lane.

The integrated core publishes:

`request_accept = request_accept_capacity`

and:

`request_reject = request_reject_lane | request_reject_capacity`

A capacity-rejected explicit request does not alter:

- retained state;
- pending-route state;
- accepted-change mask;
- accepted-change count.

A capacity-deferred pending completion remains in the retained pending-route bank.

A clean capacity rejection does not increment:

`queue_overflow_events`

Required relation:

`queue_overflow_events = 0`

## Request Acceptance Conditions

A valid explicit request becomes a pre-capacity accepted request only when:

- `tick_enable = 1`;
- `request_valid[lane] = 1`;
- the requested cell index is less than `CELLS`;
- the requested target belongs to `{-1, 0, 1}`;
- no earlier accepted lane owns the requested cell;
- no retained pending route owns the requested cell;
- the registered scheduler state admits the explicit transition class.

A pre-capacity accepted request becomes an integrated accepted request only when the transition-capacity guard also admits it.

For an opposite-polarity request, capacity admission additionally requires:

- active-neutral candidate state equal to `0`;
- retained current state different from `0`;
- `neutral_routed_candidate[cell] = 1`;
- no direct opposite-polarity candidate write.

## Request Rejection Conditions

During an enabled tick, an asserted explicit request lane is rejected by request arbitration when the first matching condition is:

1. invalid cell index;
2. reserved request target;
3. duplicate ownership by an earlier accepted lane;
4. retained pending-route ownership;
5. scheduler ineligibility.

A pre-capacity accepted request is rejected by the downstream capacity guard when:

- its cell index is invalid at the capacity boundary;
- a higher-priority pending completion owns the cell;
- an earlier capacity-accepted candidate owns the cell;
- current or candidate state is outside `{-1, 0, 1}`;
- the transition class is unsupported;
- the candidate state would directly cross between `-1` and `1`;
- an opposite-polarity candidate is not routed to active neutral `0`;
- no capacity slot remains for a state-changing candidate;
- the transition class and state-change relation do not match.

When `tick_enable = 0`, explicit request execution remains disabled and:

`request_reject_tick_disabled = request_valid`

## Event Counter Sources

The request-lane module produces the following per-evaluation telemetry:

| Counter | Source |
|---|---|
| `requested_lane_events` | asserted explicit request lanes evaluated during an enabled tick |
| `accepted_lane_events` | explicit request lanes accepted before capacity admission |
| `rejected_lane_events` | explicit request lanes rejected during request arbitration |
| `accepted_changes` | pre-capacity accepted explicit requests that differ from retained state |
| `requested_direct_events` | accepted opposite-polarity explicit requests |
| `prevented_direct_events` | accepted opposite-polarity requests assigned to neutral routing |
| `neutral_routed_events` | accepted opposite-polarity requests routed through active neutral `0` |

Rejection reasons are exposed as lane masks:

- `request_reject_invalid_cell`;
- `request_reject_invalid_target`;
- `request_reject_duplicate_cell`;
- `request_reject_scheduler`;
- `request_reject_pending_busy`;
- `request_reject_tick_disabled`.

The downstream capacity guard separately produces:

- `capacity_candidate_events`;
- `capacity_accept_events`;
- `capacity_reject_events`;
- `capacity_exhausted_events`;
- `accepted_change_events`.

The integrated public direct-event counters use the active-neutral transition-stage sources.

Actual retained-state execution is counted at the retained-state writeback boundary.

## Arbitration Invariant Relations

The request-lane module calculates:

```systemverilog
request_lane_order_valid =
    ((request_accept & request_reject) == 0)
    && (
        !tick_enable
        || ((request_accept | request_reject) == request_valid)
    );
```

```systemverilog
duplicate_cell_guard_valid =
    ((request_accept & request_reject_duplicate_cell) == 0);
```

```systemverilog
scheduler_gate_valid =
    ((request_accept & request_reject_scheduler) == 0);
```

```systemverilog
transition_capacity_valid =
    (accepted_changes <= REQUEST_LANES);
```

```systemverilog
active_neutral_routing_valid =
    (prevented_direct_events >= requested_direct_events)
    && (neutral_routed_events >= prevented_direct_events);
```

At the request-lane module boundary:

`no_actual_direct_events = 1`

`no_queue_overflow = 1`

The corresponding integrated conditions are also checked at the active-neutral, pending-route, capacity, and retained-state writeback boundaries.

## Integrated Request-Lane Invariant Flag

The request-lane relations feed:

`FRP_INV_REQUEST_LANE_ORDER_VALID`

The integrated flag is asserted only when all of the following are true:

- request acceptance and rejection remain disjoint;
- enabled-tick request coverage is complete;
- retained-state cell-domain validation passes;
- target and pending-route domain validation passes;
- duplicate-cell guarding passes;
- scheduler gating passes;
- pre-capacity accepted changes remain bounded;
- request-stage active-neutral routing relations pass.

The qualified M16 terminal invariant vector is:

`1111111111`

## Assertion Support

The bound assertion layer is:

`rtl/m16/frp_m16_assertions.sv`

The request-lane and capacity assertions check:

| Assertion relation | Required condition |
|---|---|
| acceptance and rejection separation | `(request_accept & request_reject) == 0` |
| disabled-tick execution gating | no accepted lane, cell, change mask, or accepted change |
| accepted-cell bound | `popcount(accepted_cell_mask) <= REQUEST_LANES` |
| accepted-change correlation | `popcount(accepted_change_mask) == accepted_changes` |
| neutral-route ownership | neutral-routed cells are accepted cells |
| neutral-route state change | neutral-routed cells are accepted changes |
| accepted-change bound | `accepted_changes <= REQUEST_LANES` |
| remaining-capacity relation | `capacity_remaining = REQUEST_LANES - accepted_changes` |
| capacity-exhausted relation | `capacity_exhausted = (accepted_changes == REQUEST_LANES)` |
| switch-load relation | `switch_load_numerator = accepted_changes` |
| direct-event zero relation | `actual_direct_events = 0` |
| reserved-state zero relation | `reserved_state_events = 0` |
| queue-overflow zero relation | `queue_overflow_events = 0` |
| request-lane invariant flag | `FRP_INV_REQUEST_LANE_ORDER_VALID = 1` |
| transition-capacity invariant flag | `FRP_INV_TRANSITION_CAPACITY_VALID = 1` |

Per-cell assertions also check:

- state changes require `accepted_change_mask`;
- no retained-state transition crosses directly between `-1` and `1`;
- accepted opposite-polarity requests write active neutral `0`;
- accepted opposite-polarity requests retain the requested pending polarity;
- deferred pending routes remain stable;
- pending completion executes from `0`;
- pending completion clears the retained route.

## Deterministic Testbench Record

The executable testbench is:

`rtl/m16/frp_m16_tb.sv`

The qualified parameter profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |

The free-mode sequence includes:

- zero-to-nonzero execution;
- both opposite-polarity routing directions;
- both pending-route completion directions;
- simultaneous two-lane state-changing acceptance;
- full transition-capacity occupancy.

At the two-lane capacity point, the recorded relations are:

`accepted_changes = 2`

`capacity_remaining = 0`

`capacity_exhausted = 1`

`switch_load_numerator = 2`

The `7/1` sequence checks:

- zero-to-nonzero rejection during `BALANCE`;
- zero-to-nonzero acceptance during `COMMIT`;
- opposite-polarity first-leg routing during `BALANCE`;
- retained pending-route completion during the next `COMMIT`;
- exact `56 / 8` scheduler-state count relation over `64` ticks.

The `1/7` sequence checks:

- zero-to-nonzero acceptance during `EXCITE`;
- opposite-polarity first-leg routing during `NEUTRALIZE`;
- retained pending-route completion during the next `EXCITE`;
- exact `2 / 14` scheduler-state count relation over `16` ticks.

## Request-Lane Qualification Record

The recorded request-lane results are:

| Relation | Result |
|---|---|
| canonical request-target validation | `PASS` |
| valid cell-index enforcement | `PASS` |
| one accepted request per cell per tick | `PASS` |
| earlier accepted-lane ownership | `PASS` |
| pending-route ownership priority | `PASS` |
| scheduler transition eligibility | `PASS` |
| acceptance and rejection separation | `PASS` |
| latch-free combinational arbitration | `PASS` |

The recorded transition-capacity results are:

| Relation | Result |
|---|---|
| bounded accepted changes | `PASS` |
| capacity-remaining relation | `PASS` |
| capacity-exhausted relation | `PASS` |
| switch-load relation | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| pending completion has priority | `PASS` |
| explicit requests preserve lane order | `PASS` |
| each route leg consumes capacity on its own tick | `PASS` |

## M15 Semantic Foundation

M15 remains the semantic and implementation-mapping foundation for M16.

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

The M16 request-lane implementation retains:

- the M15 request-lane count relation;
- deterministic request ordering;
- balanced ternary target validation;
- active-neutral routing;
- retained pending-route ownership;
- scheduler transition eligibility;
- transition-capacity bounds;
- zero direct-event execution;
- zero reserved-state emission;
- zero queue-overflow qualification.

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

Request-lane qualification result:

`PASS`

## FPGA Integration Propagation Record

The target-independent FPGA preparation layer integrates the M16 core request interface through:

`fpga/m16/frp_m16_fpga_top.sv`

The FPGA integration testbench is:

`fpga/m16/frp_m16_fpga_tb.sv`

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

The FPGA preparation qualification records:

- request-valid gating before `core_ready`;
- request-interface propagation after reset release;
- scheduler propagation;
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

The implemented request-lane artifact records:

- deterministic ascending request-lane order;
- canonical balanced ternary request-target validation;
- cell-index validation;
- duplicate-cell guarding;
- retained pending-route ownership;
- scheduler-qualified explicit request admission;
- pre-capacity acceptance and rejection;
- active-neutral opposite-polarity classification;
- downstream pending-completion priority;
- downstream transition-capacity admission;
- request-stage event telemetry;
- request-stage invariant generation;
- assertion execution;
- executable deterministic testbench coverage;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- repository-integrity validation;
- qualification artifact generation.

Final request-lane arbitration result:

`PASS`

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
- `docs/m16_scheduler_state_rtl_realization.md`;
- `docs/m16_pending_route_register_module.md`;
- `docs/m16_active_neutral_transition_module.md`;
- `docs/m16_transition_capacity_guard_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`.

## Author

Maksym Marnov

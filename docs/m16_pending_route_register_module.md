# FRP M16 Pending Route Register Module

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

This document records the implemented pending-route register module for the M16 RTL core realization layer.

The implemented artifact is:

`rtl/m16/frp_m16_pending_routes.sv`

The module is:

`frp_m16_pending_routes`

The pending-route register layer preserves the M15-qualified active-neutral execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The M16 module retains the requested target polarity of every capacity-approved opposite-polarity request while the retained ternary state executes the mandatory active-neutral route.

## Implemented Artifact Boundary

The pending-route module implements:

- one retained pending-route slot per cell;
- canonical balanced ternary pending-route encoding;
- asynchronous active-low reset;
- tick-qualified register update;
- pending-route creation;
- pending-route retention;
- pending-route completion;
- pending-route clearing;
- pending-route polarity preservation;
- completion priority over new same-cell route creation;
- non-overwrite validation;
- scheduler and capacity deferral;
- reserved-state detection;
- queue-overflow detection;
- deterministic ascending request-lane processing;
- per-evaluation masks;
- per-evaluation event telemetry;
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
- scheduler-state decoding;
- request-lane acceptance;
- transition-capacity admission;
- retained-state candidate generation;
- retained-state writeback.

The surrounding integrated M16 core supplies the scheduler-qualified and capacity-approved control inputs.

## Integrated Execution Position

The integrated pending-route execution path is:

`retained state and retained pending-route state`

→ `pending-completion candidate derivation`

→ `active-neutral candidate generation`

→ `transition-capacity admission`

→ `pending-route next-state generation`

→ `pending-route register update`

→ `retained-state writeback`

For opposite-polarity explicit requests, the path is:

`request-lane arbitration`

→ `active-neutral first-leg candidate`

→ `transition-capacity admission`

→ `pending-route creation`

→ `retained state 0`

For retained pending completion, the path is:

`retained state 0 and retained pending target`

→ `commit-capable scheduler state`

→ `pending-completion candidate`

→ `transition-capacity admission`

→ `pending-route clearing`

→ `retained target writeback`

The integrated files are:

- `rtl/m16/frp_m16_pkg.sv`;
- `rtl/m16/frp_m16_scheduler.sv`;
- `rtl/m16/frp_m16_request_lanes.sv`;
- `rtl/m16/frp_m16_active_neutral.sv`;
- `rtl/m16/frp_m16_capacity_guard.sv`;
- `rtl/m16/frp_m16_pending_routes.sv`;
- `rtl/m16/frp_m16_state_update.sv`;
- `rtl/m16/frp_m16_core.sv`.

## Core Identity Preserved

The pending-route register module preserves:

- the balanced ternary retained-state domain `{-1, 0, 1}`;
- active neutral state `0`;
- the retained target polarity of an interrupted opposite-polarity route;
- tick-separated opposite-polarity execution;
- one retained pending-route slot per cell;
- pending completion only from retained state `0`;
- pending completion priority over new same-cell requests;
- retained polarity during scheduler deferral;
- retained polarity during capacity deferral;
- zero direct opposite-polarity retained-state execution;
- zero reserved-state emission;
- zero queue overflow in qualified execution.

The required routed sequences are:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct retained-state transitions between `-1` and `1` remain forbidden.

Required integrated relation:

`actual_direct_events = 0`

## Canonical Pending-Route Encoding

The pending-route register uses the canonical two-bit balanced ternary encoding imported from:

`rtl/m16/frp_m16_pkg.sv`

| Pending-route value | SystemVerilog symbol | Encoding | Meaning |
|---|---|---|---|
| `-1` | `FRP_TERN_NEG` | `2'b11` | retained completion target is `-1` |
| `0` | `FRP_TERN_ZERO` | `2'b00` | no pending route |
| `1` | `FRP_TERN_POS` | `2'b01` | retained completion target is `1` |
| reserved | `FRP_TERN_RESERVED` | `2'b10` | invalid pending-route value |

The shared state constants are:

- `FRP_STATE_NEG`;
- `FRP_STATE_ZERO`;
- `FRP_STATE_POS`;
- `FRP_STATE_RESERVED`.

The active-neutral value is:

`FRP_ACTIVE_NEUTRAL = FRP_STATE_ZERO`

Required relations:

`pending_reserved_events = 0`

`reserved_state_events = 0`

## Module Parameterization

The module parameters are:

| Parameter | Definition |
|---|---|
| `CELLS` | number of retained balanced ternary cells |
| `STATE_BITS` | packed width of one ternary value |
| `REQUEST_LANES` | number of explicit request lanes |
| `CELL_INDEX_BITS` | packed cell-index width |
| `COUNTER_BITS` | event-counter width |

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

The pending-route module consumes:

| Signal | Width | Function |
|---|---:|---|
| `clk` | `1` | sequential register clock |
| `rst_n` | `1` | asynchronous active-low reset |
| `tick_enable` | `1` | enables pending-route register update |
| `state_q` | `CELLS × STATE_BITS` | retained balanced ternary state before writeback |
| `request_accept` | `REQUEST_LANES` | capacity-approved explicit request lanes |
| `request_neutralized` | `REQUEST_LANES` | accepted opposite-polarity request classification |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | requested cell index for each lane |
| `request_target` | `REQUEST_LANES × STATE_BITS` | requested balanced ternary target for each lane |
| `pending_completion_accept_mask` | `CELLS` | capacity-approved retained pending completions |

Within `frp_m16_core`, the connected explicit-request acceptance signal is:

`request_accept_capacity`

The connected pending-completion acceptance mask is:

`capacity_accept_mask & pending_completion_candidate`

A new route is created only when both are asserted for the same explicit request lane:

`request_accept[lane]`

and:

`request_neutralized[lane]`

## Retained Register

The retained pending-route register is:

`pending_route_q`

Its width is:

`CELLS × STATE_BITS`

Each cell owns one two-bit pending-route slot.

The combinational next-state value is:

`pending_route_next`

The public next-state output is:

`pending_route_d`

The assignment is:

`pending_route_d = pending_route_next`

At the beginning of combinational evaluation:

`pending_route_next = pending_route_q`

Every route therefore remains retained unless a qualified creation or qualified completion changes its cell slot.

## Pending-Route Mask Outputs

The module emits:

| Signal | Width | Function |
|---|---:|---|
| `pending_active_mask` | `CELLS` | cells with a retained nonzero pending target |
| `pending_created_mask` | `CELLS` | cells receiving a new pending target |
| `pending_completed_mask` | `CELLS` | cells with an accepted pending completion |
| `pending_cleared_mask` | `CELLS` | cells cleared after accepted completion |
| `pending_retained_mask` | `CELLS` | active routes retained during the current evaluation |
| `pending_blocked_mask` | `CELLS` | cells whose route operation is retained or blocked |
| `pending_reserved_mask` | `CELLS` | cells containing a reserved pending-route encoding |
| `pending_overflow_mask` | `CELLS` | cells receiving an invalid overwrite or duplicate creation attempt |

The masks are combinational outputs derived from:

- current retained pending-route state;
- capacity-approved completion inputs;
- capacity-approved explicit request inputs;
- route-creation validation;
- route-completion validation.

## Pending-Route Telemetry Outputs

The module emits:

| Signal | Function |
|---|---|
| `pending_active_count` | number of current retained nonzero pending routes |
| `pending_created_events` | new pending routes created during the current evaluation |
| `pending_completed_events` | pending routes completed during the current evaluation |
| `pending_cleared_events` | pending-route slots cleared during the current evaluation |
| `pending_retained_events` | active routes retained during an enabled tick |
| `pending_reserved_events` | current retained reserved pending-route values |
| `neutral_routed_events` | capacity-approved neutral-routed explicit requests presented to the module |
| `prevented_direct_events` | capacity-approved opposite-polarity direct transitions prevented |
| `queue_overflow_events` | invalid pending-route overwrite or duplicate-creation attempts |
| `actual_direct_events` | direct opposite-polarity executions at this module boundary |

These telemetry values are combinational per-evaluation outputs.

The integrated core uses the pending-route sources for:

- reserved-state aggregation;
- queue-overflow aggregation;
- integrated invariant generation.

The public direct-event counters are sourced from the active-neutral transition stage.

## Pending-Route Invariant Outputs

The module emits:

- `pending_domain_valid`;
- `pending_polarity_valid`;
- `pending_completion_from_zero_valid`;
- `pending_non_overwrite_valid`;
- `pending_capacity_valid`;
- `pending_replay_deterministic`;
- `no_pending_reserved_state`;
- `no_queue_overflow`;
- `no_actual_direct_events`.

These outputs feed the integrated pending-route invariant flag:

`FRP_INV_PENDING_POLARITY_VALID`

They also participate in the integrated flags for:

- active-neutral routing;
- transition capacity;
- no actual direct events;
- no reserved state;
- no queue overflow.

## Reset Behavior

The pending-route register uses:

`always_ff @(posedge clk or negedge rst_n)`

When:

`rst_n = 0`

the module assigns:

`pending_route_q = 0`

Every pending-route slot is initialized to:

`FRP_STATE_ZERO`

The reset state means:

`no retained pending routes`

Required reset relations:

`pending_route_out = 0`

`pending_active_count = 0`

`pending_reserved_events = 0`

`actual_direct_events = 0`

`queue_overflow_events = 0`

The reset boundary is checked by the executable M16 assertion layer and deterministic testbench.

## Tick-Qualified Register Update

When:

`rst_n = 1`

and:

`tick_enable = 1`

the register commits:

`pending_route_q <= pending_route_d`

When:

`rst_n = 1`

and:

`tick_enable = 0`

the register retains its current value.

Required relation:

`tick_enable = 0 → pending_route_q remains stable`

The pending-route register does not consume:

`clear_counters`

Clearing the scheduler counter bank does not clear or modify retained pending routes.

## Pending Route Meaning

A pending route stores the exact requested target polarity of an opposite-polarity request whose first legal leg was admitted through active neutral `0`.

If:

`pending_route_q[cell] = 0`

then the cell has no retained opposite-polarity continuation.

If:

`pending_route_q[cell] = -1`

then the retained completion target is:

`-1`

If:

`pending_route_q[cell] = 1`

then the retained completion target is:

`1`

A valid active pending route is always nonzero.

Required relation:

`active pending route ∈ {-1, 1}`

## Current Pending-Route Scan

At the start of combinational evaluation, the module scans every cell in ascending cell-index order.

For each current `pending_route_q` value:

- a reserved encoding sets `pending_reserved_mask`;
- a reserved encoding increments `pending_reserved_events`;
- a reserved encoding clears `pending_domain_valid`;
- a reserved encoding clears `no_pending_reserved_state`;
- a valid nonzero value sets `pending_active_mask`;
- a valid nonzero value increments `pending_active_count`;
- a valid zero value represents an unoccupied pending-route slot.

The scan does not modify the retained route.

## Pending Route Creation

A new pending route is created only for a capacity-approved opposite-polarity request whose first leg is classified for active-neutral routing.

For each explicit request lane, the route-creation condition is:

`tick_enable = 1`

and:

`request_accept[lane] = 1`

and:

`request_neutralized[lane] = 1`

The module then validates:

- requested cell index is less than `CELLS`;
- current retained state belongs to `{-1, 0, 1}`;
- current retained state is nonzero;
- requested target belongs to `{-1, 0, 1}`;
- requested target is nonzero;
- current retained state and requested target have opposite polarity;
- current pending-route slot is valid;
- current pending-route slot is `0`;
- no accepted completion owns the cell;
- no earlier request lane has claimed route creation for the cell.

For a valid creation:

`pending_route_d[cell] = request_target[lane]`

The module sets:

`creation_claimed_mask[cell] = 1`

`pending_created_mask[cell] = 1`

and increments:

`pending_created_events`

Route-creation requests are processed in deterministic ascending request-lane order.

## Negative-to-Positive Route Creation

For:

`state_q[cell] = -1`

and:

`request_target[lane] = 1`

the first admitted retained-state leg is:

`-1 → 0`

The pending-route next state is:

`pending_route_d[cell] = 1`

After the qualified clock boundary:

- retained state is `0`;
- retained pending target is `1`.

The later completion leg is:

`0 → 1`

## Positive-to-Negative Route Creation

For:

`state_q[cell] = 1`

and:

`request_target[lane] = -1`

the first admitted retained-state leg is:

`1 → 0`

The pending-route next state is:

`pending_route_d[cell] = -1`

After the qualified clock boundary:

- retained state is `0`;
- retained pending target is `-1`.

The later completion leg is:

`0 → -1`

## Invalid Route-Creation Conditions

A route-creation input with an invalid cell index clears:

- `pending_domain_valid`;
- `pending_replay_deterministic`.

A route-creation input with an invalid polarity relation clears:

- `pending_polarity_valid`;
- `pending_replay_deterministic`.

A route-creation input is blocked when:

- the pending-route slot is already active;
- an accepted completion owns the cell;
- an earlier request lane already claimed route creation for the cell.

For a blocked overwrite or duplicate creation, the module sets:

`pending_blocked_mask[cell] = 1`

`pending_overflow_mask[cell] = 1`

and increments:

`queue_overflow_events`

It also clears:

- `pending_non_overwrite_valid`;
- `pending_replay_deterministic`.

Qualified execution records:

`queue_overflow_events = 0`

## Pending Route Completion

Pending completion candidates are derived in:

`rtl/m16/frp_m16_core.sv`

A cell becomes a pending-completion candidate when:

- `tick_enable = 1`;
- retained state is `0`;
- retained pending target is nonzero;
- scheduler state is commit-capable.

Commit-capable scheduler states are:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

The transition-capacity guard evaluates pending completion candidates before new explicit request lanes.

The pending-route module receives only capacity-approved completion cells through:

`pending_completion_accept_mask`

For each accepted completion, the module validates:

- retained state belongs to `{-1, 0, 1}`;
- retained state is `0`;
- pending-route value belongs to `{-1, 0, 1}`;
- pending-route value is nonzero.

For a legal accepted completion:

`pending_route_d[cell] = 0`

The module sets:

`pending_completed_mask[cell] = 1`

`pending_cleared_mask[cell] = 1`

and increments:

`pending_completed_events`

`pending_cleared_events`

The retained-state update layer writes the previously retained pending target into the cell state.

## Deferred Pending Route

When a valid nonzero pending route does not receive an accepted legal completion, the module retains the route.

It sets:

`pending_retained_mask[cell] = 1`

`pending_blocked_mask[cell] = 1`

During an enabled tick, it increments:

`pending_retained_events`

Scheduler ineligibility does not modify the retained pending target.

Capacity deferral does not modify the retained pending target.

A pending route remains active until:

- accepted legal completion; or
- asynchronous reset.

## Forbidden Completion

Pending completion is legal only when:

`state_q[cell] = 0`

and:

`pending_route_q[cell] ∈ {-1, 1}`

A completion request from retained state `-1` or `1` is invalid.

A completion request without an active nonzero pending route is invalid.

If an accepted completion input is not legal, the module clears:

- `pending_completion_from_zero_valid`;
- `pending_capacity_valid`;
- `pending_replay_deterministic`.

Required relation:

`pending completion starts from retained state 0`

## Pending Route Priority

Capacity-approved pending completions are processed before new route creation.

For each cell, an accepted completion sets:

`pending_completed_mask[cell] = 1`

A new route-creation request for the same cell during the same evaluation is blocked by:

`completion_owns_cell`

The request-lane arbitration stage also rejects new explicit requests targeting a cell with a retained nonzero pending route.

The transition-capacity guard evaluates:

1. pending completion candidates in ascending cell-index order;
2. explicit request candidates in ascending request-lane order.

Required relation:

`retained pending-route ownership precedes new same-cell request ownership`

## Pending Route Non-Overwrite Rule

A retained nonzero pending route may change only when its accepted completion clears the slot to `0`.

For every cell, the next-state validation checks:

- current pending route is nonzero;
- the route is not marked completed;
- next pending route equals current pending route.

If an active route changes without accepted completion, the module clears:

- `pending_non_overwrite_valid`;
- `pending_polarity_valid`.

A newly created route must produce a nonzero next pending-route value.

If a created route does not produce a nonzero next value, the module clears:

`pending_polarity_valid`

Required relation:

`pending route polarity remains stable until accepted completion or reset`

## Pending Route Clearing

A retained pending route is cleared only by:

- asynchronous active-low reset; or
- capacity-approved legal pending completion.

For a legal accepted completion:

`pending_route_d[cell] = 0`

The module sets:

`pending_completed_mask[cell] = 1`

and:

`pending_cleared_mask[cell] = 1`

The corresponding event relation is:

`pending_completed_events = pending_cleared_events`

The mask relation is:

`pending_completed_mask = pending_cleared_mask`

The pending-route module has no `clear_counters` input.

Clearing the scheduler counter bank does not clear:

- `pending_route_q`;
- `pending_active_mask`;
- retained pending target polarity.

## Interaction With Request-Lane Arbitration

The request-lane arbitration artifact is:

`rtl/m16/frp_m16_request_lanes.sv`

It provides:

| Signal | Pending-route function |
|---|---|
| `request_accept` | pre-capacity explicit request acceptance |
| `request_cell_index` | cell selected by each explicit lane |
| `request_target` | balanced ternary target selected by each explicit lane |
| `request_neutralized` | opposite-polarity request assigned to active-neutral routing |
| `request_reject_pending_busy` | new explicit request rejected because a pending route owns the cell |

The transition-capacity guard converts pre-capacity request acceptance into:

`request_accept_capacity`

The pending-route module receives:

`request_accept = request_accept_capacity`

A new route is created only when the same lane has:

`request_accept_capacity = 1`

and:

`request_neutralized = 1`

A new explicit request targeting a cell with:

`pending_route_q[cell] != 0`

is rejected before route creation.

Required relation:

`pending route creation requires capacity-approved request acceptance`

## Interaction With Scheduler State

The pending-route module does not decode scheduler state directly.

Scheduler-qualified completion candidates are derived in:

`rtl/m16/frp_m16_core.sv`

A completion candidate requires:

- `tick_enable = 1`;
- retained state equal to `0`;
- retained pending target different from `0`;
- commit-capable registered scheduler state.

Commit-capable scheduler states are:

- `FREE`;
- `COMMIT`;
- `EXCITE`.

During:

- `BALANCE`;
- `NEUTRALIZE`;

a retained pending target remains stored.

A retained route also remains stored on any tick where completion does not receive transition capacity.

Required relation:

`scheduler deferral does not modify pending-route polarity`

## Interaction With Transition Capacity

The transition-capacity artifact is:

`rtl/m16/frp_m16_capacity_guard.sv`

Pending completion is evaluated before explicit request lanes.

A valid pending completion consumes one transition-capacity slot.

The accepted completion contributes to:

- `capacity_accept_mask`;
- `accepted_change_mask`;
- `accepted_changes`;
- `capacity_accept_events`;
- `accepted_change_events`.

The capacity relations are:

`accepted_changes <= REQUEST_LANES`

`capacity_remaining = REQUEST_LANES - accepted_changes`

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

`switch_load_numerator = accepted_changes`

The pending-route module receives:

`pending_completion_accept_mask = capacity_accept_mask & pending_completion_candidate`

If a completion candidate does not receive capacity:

- `pending_completed_mask[cell] = 0`;
- `pending_cleared_mask[cell] = 0`;
- `pending_route_d[cell] = pending_route_q[cell]`.

Required relation:

`capacity deferral does not clear the pending route`

## Interaction With Active-Neutral Routing

The active-neutral transition artifact is:

`rtl/m16/frp_m16_active_neutral.sv`

For an opposite-polarity request, the first admitted leg is:

`-1 → 0`

or:

`1 → 0`

The pending-route module stores:

`pending_route_d[cell] = request_target[lane]`

The later admitted completion leg is:

`0 → pending_route_q[cell]`

The pending-route module then clears:

`pending_route_d[cell] = 0`

The complete tick-separated routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Each route leg receives independent scheduler and transition-capacity qualification.

## Pending Route Completion Target

The completion target is the retained value:

`pending_route_q[cell]`

The completion target is not taken from a new explicit request lane.

The active-neutral transition module selects the retained pending target when:

- retained state is `0`;
- pending completion is enabled;
- pending target is nonzero;
- scheduler state is commit-capable.

Required relation:

`completion target = retained pending-route target`

## Reserved Pending-Route Detection

The reserved pending-route encoding is:

`2'b10`

The module detects a reserved current value through:

`pending_reserved_mask`

and:

`pending_reserved_events`

A reserved current value clears:

`pending_domain_valid`

and:

`no_pending_reserved_state`

The module also validates every next pending-route value.

A reserved next value:

- sets `pending_reserved_mask`;
- clears `pending_domain_valid`;
- clears `no_pending_reserved_state`.

The integrated reserved-state count includes:

`pending_reserved_events`

Qualified execution records:

`pending_reserved_events = 0`

`reserved_state_events = 0`

## Pending-Route Counter Relations

The current active-route relation is:

`pending_active_count = popcount(pending_active_mask)`

For accepted neutral-routed inputs:

`neutral_routed_events >= pending_created_events`

and:

`prevented_direct_events >= pending_created_events`

For completion capacity:

`pending_completed_events <= REQUEST_LANES`

For qualified execution:

`pending_created_events` records route creation.

`pending_completed_events` records accepted completion.

`pending_cleared_events` records accepted completion clearing.

`pending_retained_events` records active-route retention during enabled ticks.

`pending_reserved_events` records current reserved pending values.

`queue_overflow_events` records blocked overwrite or duplicate-creation attempts.

`actual_direct_events` remains zero at the pending-route module boundary.

## Pending-Route Mask Relations

The module records:

| Mask | Recorded condition |
|---|---|
| `pending_active_mask` | current retained pending value is nonzero |
| `pending_created_mask` | a capacity-approved opposite-polarity request creates a route |
| `pending_completed_mask` | a capacity-approved legal completion executes |
| `pending_cleared_mask` | an accepted completion clears the route |
| `pending_retained_mask` | an active route remains stored |
| `pending_blocked_mask` | an active route is retained or a new creation is blocked |
| `pending_reserved_mask` | a current or next pending value is reserved |
| `pending_overflow_mask` | an overwrite or duplicate-creation attempt is detected |

Required relations:

`pending_completed_mask = pending_cleared_mask`

`pending_created_mask & pending_overflow_mask = 0`

`pending_completed_mask & pending_retained_mask = 0`

## Pending Route Determinism

The combinational next-state base is always:

`pending_route_next = pending_route_q`

Completion processing uses deterministic ascending cell-index order:

`cell 0 → cell 1 → ... → cell CELLS - 1`

Route creation uses deterministic ascending request-lane order:

`lane 0 → lane 1 → ... → lane REQUEST_LANES - 1`

Completion processing precedes route creation.

The first accepted route-creation lane claims its cell through:

`creation_claimed_mask`

The next-state validation scans every cell in ascending cell-index order.

For the same inputs and parameters, the module produces the same:

- `pending_route_d`;
- creation mask;
- completion mask;
- clearing mask;
- retention mask;
- blocked mask;
- reserved mask;
- overflow mask;
- event telemetry;
- invariant outputs.

The implemented replay-valid signal is:

`pending_replay_deterministic`

It is cleared by:

- invalid route-creation cell index;
- invalid opposite-polarity route relation;
- overwrite or duplicate-creation attempt;
- illegal completion request;
- completion request without an active route.

## Queue Overflow Semantics

The pending-route structure provides:

`one retained pending-route slot per cell`

A queue-overflow event is generated when a capacity-approved neutral-routed request attempts route creation and:

- the cell already contains an active pending route;
- accepted completion owns the same cell;
- an earlier lane already claimed creation for the same cell.

The module then sets:

`pending_blocked_mask[cell] = 1`

`pending_overflow_mask[cell] = 1`

and increments:

`queue_overflow_events`

It also clears:

- `pending_non_overwrite_valid`;
- `pending_replay_deterministic`.

The request-lane pending-busy guard and capacity ownership order prevent these conditions during qualified execution.

Qualified result:

`queue_overflow_events = 0`

## Pending Route Safety Relations

The pending-route module records the following relations:

- every retained pending value belongs to `{-1, 0, 1}`;
- every active pending route is nonzero;
- every created route retains the exact requested opposite polarity;
- every accepted completion starts from retained state `0`;
- every accepted completion uses the retained pending target;
- every accepted completion clears its route;
- every deferred route retains its polarity;
- no active route is overwritten before completion;
- no route completion creates a direct transition between `-1` and `1`;
- no reserved pending value is emitted;
- no queue-overflow event occurs in qualified execution.

Required integrated values:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## Pending-Route Invariant Relations

The module calculates:

`no_queue_overflow = (queue_overflow_events == 0)`

and:

`no_actual_direct_events = (actual_direct_events == 0)`

The domain relation is:

`pending_domain_valid = pending_domain_valid && no_pending_reserved_state`

The polarity relation includes:

`neutral_routed_events >= pending_created_events`

and:

`prevented_direct_events >= pending_created_events`

The capacity relation includes:

`pending_completed_events <= REQUEST_LANES`

The non-overwrite relation requires an active route to remain unchanged unless its accepted completion clears it.

The completion relation requires:

`retained state = 0`

and:

`active pending route = 1`

before clearing.

## Integrated Pending-Route Invariant Flag

The integrated pending-route flag is:

`FRP_INV_PENDING_POLARITY_VALID`

It is assembled from:

```systemverilog
pending_domain_valid
&& pending_polarity_valid
&& pending_completion_from_zero_valid
&& pending_non_overwrite_valid
&& pending_capacity_valid
&& pending_replay_deterministic
&& no_pending_reserved_state
```

Pending-route outputs also participate in:

- `FRP_INV_STATE_DOMAIN_VALID`;
- `FRP_INV_ACTIVE_NEUTRAL_VALID`;
- `FRP_INV_TRANSITION_CAPACITY_VALID`;
- `FRP_INV_STATE_UPDATE_VALID`;
- `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
- `FRP_INV_NO_RESERVED_STATE`;
- `FRP_INV_NO_QUEUE_OVERFLOW`.

The qualified integrated invariant vector is:

`1111111111`

## Assertion Support

The bound assertion artifact is:

`rtl/m16/frp_m16_assertions.sv`

The pending-route assertion relations are:

| Assertion boundary | Required relation |
|---|---|
| reset | `pending_route_out = 0` |
| pending-route domain | every cell belongs to `{-1, 0, 1}` |
| disabled tick | pending-route value remains stable |
| deferred route | active pending target remains stable without accepted change |
| active-neutral first leg | retained state becomes `0` and pending target remains nonzero |
| retained polarity | pending target is opposite to the prior retained state |
| completion source | completion starts from retained state `0` |
| completion target | retained state receives the prior pending target |
| completion clearing | pending route becomes `0` |
| nonzero-state guard | route does not complete from nonzero retained state |
| direct-transition guard | retained state does not cross directly between `-1` and `1` |
| pending invariant flag | `FRP_INV_PENDING_POLARITY_VALID = 1` |
| no-overflow flag | `FRP_INV_NO_QUEUE_OVERFLOW = 1` |

## Deterministic RTL Testbench Record

The executable testbench is:

`rtl/m16/frp_m16_tb.sv`

The qualified parameter profile is:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |

The free-mode sequence executes both routed directions:

`1 → 0 → -1`

and:

`-1 → 0 → 1`

For each direction, the testbench records:

- active-neutral first-leg execution;
- exact requested pending polarity;
- retained state `0` between route legs;
- completion from `0`;
- pending-route clearing after completion.

The `7/1` sequence records:

- first route leg during `BALANCE`;
- retained pending polarity through following `BALANCE` ticks;
- completion during `COMMIT`.

The `1/7` sequence records:

- first route leg during `NEUTRALIZE`;
- retained pending polarity through following `NEUTRALIZE` ticks;
- completion during `EXCITE`.

## Pending-Route Qualification Record

| Pending-route relation | Result |
|---|---|
| one retained route slot per cell | `PASS` |
| exact requested polarity retained | `PASS` |
| pending route owns its cell | `PASS` |
| same-cell overwrite prevented | `PASS` |
| scheduler deferral preserves route | `PASS` |
| transition-capacity deferral preserves route | `PASS` |
| completion requires retained state `0` | `PASS` |
| accepted completion clears route | `PASS` |
| pending-route overflow absent | `PASS` |

The active-neutral routing record is:

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

The M16 pending-route implementation retains:

- M15 balanced ternary state encoding;
- active-neutral routing through `0`;
- retained opposite-polarity target;
- tick-separated route completion;
- scheduler-qualified completion;
- transition-capacity qualification;
- deterministic route ownership;
- zero direct-event execution;
- zero reserved-state emission;
- zero queue overflow.

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

Pending-route qualification result:

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

After the first routed leg:

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

The implemented pending-route artifact records:

- canonical balanced ternary pending-route encoding;
- one retained route slot per cell;
- asynchronous reset to zero;
- tick-qualified route retention;
- capacity-approved route creation;
- exact requested polarity retention;
- scheduler-qualified completion;
- capacity-approved completion;
- completion priority;
- same-cell non-overwrite enforcement;
- completion only from active neutral state `0`;
- accepted-completion clearing;
- scheduler-deferral retention;
- capacity-deferral retention;
- reserved-state detection;
- queue-overflow detection;
- deterministic cell and request-lane order;
- invariant generation;
- assertion execution;
- executable deterministic testbench coverage;
- FPGA integration propagation;
- repository-integrity validation;
- qualification artifact generation.

Final pending-route result:

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
- `docs/m16_active_neutral_transition_module.md`;
- `docs/m16_transition_capacity_guard_module.md`;
- `docs/m16_retained_state_update_module.md`;
- `docs/m16_invariant_assertion_set.md`;
- `docs/m16_m15_vector_replay_compatibility_report.md`.

## Author

Maksym Marnov

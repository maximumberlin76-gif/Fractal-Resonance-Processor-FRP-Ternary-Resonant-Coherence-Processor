# FRP M16 RTL Core Interface Contract

## Status

`M16 RTL EXECUTION LAYER CLOSED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the qualified RTL-facing interface contract for the M16 core realization layer of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not introduce a new Python semantic reference.

The executable semantic reference remains:

`frp_prototype_v1_7_0.py`

The M16 interface realizes the M15-qualified retained-state execution contract through:

- canonical balanced ternary encoding;
- internally retained processor state;
- internally retained pending-route state;
- explicit `free`, `7/1`, and `1/7` scheduler modes;
- deterministic request-lane ordering;
- active-neutral routing through state `0`;
- transition-capacity enforcement;
- retained-state writeback;
- architectural event counters;
- ten integrated invariant flags;
- executable SystemVerilog qualification.

Primary integrated RTL core:

`rtl/m16/frp_m16_core.sv`

## Core Identity

The M16 RTL core realizes the retained-state execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

The closed execution chain is:

`phase-derived balanced ternary target`

→ `temporal scheduler state`

→ `pending-route completion priority`

→ `deterministic request-lane arbitration`

→ `balanced ternary transition classification`

→ `active-neutral transition generation`

→ `distributed transition-capacity admission`

→ `pending-route register update`

→ `retained-state writeback`

→ `architectural telemetry`

→ `integrated invariant evaluation`

The upstream M15 quantized semantic reference remains responsible for:

- phase words;
- frequency state;
- hierarchical coupling;
- thermal state;
- gamma state;
- coherence telemetry;
- `C(t)`;
- `P(t)`;
- `C_minus_P`;
- phase-derived ternary targets.

The M16 RTL core consumes the phase-derived ternary target vector and explicit request-lane inputs.

The M16 RTL core owns the retained balanced ternary processor state and retained pending-route state.

## Qualified Interface Record

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current qualified workflow record:

| Field | Recorded value |
|---|---|
| Workflow run | `#84` |
| Qualified source commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `52s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 RTL EXECUTION LAYER CLOSED` |

Qualified core configuration:

| Parameter | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `CELL_INDEX_BITS` | `3` |
| `COUNTER_BITS` | `32` |

Qualified terminal record:

| Field | Recorded value |
|---|---:|
| `ticks_recorded_q` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Interface qualification result:

`PASS`

## Canonical Balanced Ternary Encoding

The canonical retained processor-state domain is:

`{-1, 0, 1}`

Canonical hardware encoding:

| Ternary state | Encoding | Package symbol |
|---:|---|---|
| `-1` | `2'b11` | `FRP_TERN_NEG` |
| `0` | `2'b00` | `FRP_TERN_ZERO` |
| `1` | `2'b01` | `FRP_TERN_POS` |
| reserved | `2'b10` | `FRP_TERN_RESERVED` |

Retained-state aliases:

| Alias | Package value |
|---|---|
| `FRP_STATE_NEG` | `FRP_TERN_NEG` |
| `FRP_STATE_ZERO` | `FRP_TERN_ZERO` |
| `FRP_STATE_POS` | `FRP_TERN_POS` |
| `FRP_STATE_RESERVED` | `FRP_TERN_RESERVED` |

Active neutral encoding:

`FRP_ACTIVE_NEUTRAL = FRP_STATE_ZERO`

Required state-domain relation:

`state_out[cell] ∈ {-1, 0, 1}`

Required pending-route relation:

`pending_route_out[cell] ∈ {-1, 0, 1}`

Required reserved-state counter:

`reserved_state_events = 0`

Canonical encoding qualification result:

`PASS`

## Parameter Set

The integrated M16 core declares:

| Parameter | Default or derived value | Meaning |
|---|---|---|
| `CELLS` | `FRP_M16_DEFAULT_CELLS` | number of retained processor cells |
| `STATE_BITS` | `FRP_M16_STATE_BITS` | encoding width per ternary state |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` | request-lane and transition-capacity count |
| `CELL_INDEX_BITS` | `(CELLS <= 1) ? 1 : $clog2(CELLS)` | packed cell-index width per request lane |
| `COUNTER_BITS` | `FRP_M16_COUNTER_BITS` | architectural counter width |

Package constants:

| Constant | Value |
|---|---:|
| `FRP_M16_DEFAULT_CELLS` | `16` |
| `FRP_M16_STATE_BITS` | `2` |
| `FRP_M16_COUNTER_BITS` | `32` |
| `FRP_M16_TRANSITION_FRACTION_NUM` | `1` |
| `FRP_M16_TRANSITION_FRACTION_DEN` | `4` |
| `FRP_M16_SCHED_MODE_BITS` | `2` |
| `FRP_M16_SCHED_BITS` | `3` |
| `FRP_M16_PERIOD_TICKS` | `8` |
| `FRP_M16_INVARIANT_FLAGS` | `10` |

Required transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

Validated profiles:

| Cells | Request lanes | Packed retained-state width |
|---:|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

Derived packed-vector widths:

| Vector | Width |
|---|---|
| `target_q` | `CELLS × STATE_BITS` |
| `state_out` | `CELLS × STATE_BITS` |
| `pending_route_out` | `CELLS × STATE_BITS` |
| `request_valid` | `REQUEST_LANES` |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` |
| `request_target` | `REQUEST_LANES × STATE_BITS` |
| `request_accept` | `REQUEST_LANES` |
| `request_reject` | `REQUEST_LANES` |
| `accepted_cell_mask` | `CELLS` |
| `neutral_routed_cell_mask` | `CELLS` |
| `accepted_change_mask` | `CELLS` |
| `invariant_flags` | `FRP_M16_INVARIANT_FLAGS` |

Parameter-boundary qualification result:

`PASS`

## Public Core Port Summary

The public `frp_m16_core` interface contains:

### Control inputs

| Signal | Direction | Width or type |
|---|---|---|
| `clk` | input | `logic` |
| `rst_n` | input | `logic` |
| `tick_enable` | input | `logic` |
| `clear_counters` | input | `logic` |

### Scheduler input

| Signal | Direction | Width or type |
|---|---|---|
| `scheduler_mode` | input | `frp_m16_scheduler_mode_e` |

### Request-lane inputs

| Signal | Direction | Width |
|---|---|---:|
| `request_valid` | input | `REQUEST_LANES` |
| `request_cell_index` | input | `REQUEST_LANES × CELL_INDEX_BITS` |
| `request_target` | input | `REQUEST_LANES × STATE_BITS` |

### Phase-derived target input

| Signal | Direction | Width |
|---|---|---:|
| `target_q` | input | `CELLS × STATE_BITS` |

### Retained execution outputs

| Signal | Direction | Width |
|---|---|---:|
| `state_out` | output | `CELLS × STATE_BITS` |
| `pending_route_out` | output | `CELLS × STATE_BITS` |

### Scheduler outputs

| Signal | Direction | Width or type |
|---|---|---|
| `scheduler_mode_q` | output | `frp_m16_scheduler_mode_e` |
| `scheduler_state_q` | output | `frp_m16_scheduler_state_e` |
| `ticks_recorded_q` | output | `COUNTER_BITS` |
| `scheduler_count_free_q` | output | `COUNTER_BITS` |
| `scheduler_count_balance_q` | output | `COUNTER_BITS` |
| `scheduler_count_commit_q` | output | `COUNTER_BITS` |
| `scheduler_count_excite_q` | output | `COUNTER_BITS` |
| `scheduler_count_neutralize_q` | output | `COUNTER_BITS` |

### Request disposition outputs

| Signal | Direction | Width |
|---|---|---:|
| `request_accept` | output | `REQUEST_LANES` |
| `request_reject` | output | `REQUEST_LANES` |

### Cell-mask outputs

| Signal | Direction | Width |
|---|---|---:|
| `accepted_cell_mask` | output | `CELLS` |
| `neutral_routed_cell_mask` | output | `CELLS` |
| `accepted_change_mask` | output | `CELLS` |

### Capacity outputs

| Signal | Direction | Width |
|---|---|---:|
| `accepted_changes` | output | `COUNTER_BITS` |
| `capacity_remaining` | output | `COUNTER_BITS` |
| `capacity_exhausted` | output | `1` |
| `switch_load_numerator` | output | `COUNTER_BITS` |

### Event-counter outputs

| Signal | Direction | Width |
|---|---|---:|
| `requested_direct_events` | output | `COUNTER_BITS` |
| `prevented_direct_events` | output | `COUNTER_BITS` |
| `neutral_routed_events` | output | `COUNTER_BITS` |
| `actual_direct_events` | output | `COUNTER_BITS` |
| `reserved_state_events` | output | `COUNTER_BITS` |
| `queue_overflow_events` | output | `COUNTER_BITS` |

### Integrated invariant output

| Signal | Direction | Width |
|---|---|---:|
| `invariant_flags` | output | `FRP_M16_INVARIANT_FLAGS` |

## Clock and Reset Interface

The M16 core uses:

- positive-edge sequential state updates;
- asynchronous active-low reset assertion.

Control signals:

| Signal | Meaning |
|---|---|
| `clk` | processor clock |
| `rst_n` | asynchronous active-low core reset |
| `tick_enable` | enables retained execution for one processor tick |
| `clear_counters` | clears the scheduler counter bank |

Reset values:

| Retained quantity | Reset value |
|---|---|
| retained processor state | `0` for every cell |
| retained pending route | `0` for every cell |
| scheduler mode | `FRP_MODE_FREE` |
| scheduler state | `FRP_SCHED_FREE` |
| scheduler tick index | `0` |
| scheduler period index | `0` |
| `ticks_recorded_q` | `0` |
| all scheduler-state counters | `0` |

Required reset relations:

`state_out = 0`

`pending_route_out = 0`

`ticks_recorded_q = 0`

`reserved_state_events = 0`

The `clear_counters` input clears:

- `ticks_recorded_q`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`.

The `clear_counters` input preserves:

- retained processor state;
- retained pending-route state;
- scheduler tick index;
- scheduler period index;
- scheduler mode;
- scheduler-state progression.

Clock and reset qualification result:

`PASS`

## Scheduler Mode and State Interface

Scheduler mode input:

| Signal | Type | Meaning |
|---|---|---|
| `scheduler_mode` | `frp_m16_scheduler_mode_e` | selected temporal execution mode |

Scheduler mode encodings:

| Mode | Encoding |
|---|---|
| `FRP_MODE_FREE` | `2'b00` |
| `FRP_MODE_7_1` | `2'b01` |
| `FRP_MODE_1_7` | `2'b10` |
| `FRP_MODE_RESERVED` | `2'b11` |

Scheduler-state output:

| Signal | Type | Meaning |
|---|---|---|
| `scheduler_mode_q` | `frp_m16_scheduler_mode_e` | registered scheduler mode |
| `scheduler_state_q` | `frp_m16_scheduler_state_e` | scheduler state used by the execution chain |

Scheduler-state encodings:

| Scheduler state | Encoding |
|---|---|
| `FRP_SCHED_FREE` | `3'b000` |
| `FRP_SCHED_BALANCE` | `3'b001` |
| `FRP_SCHED_COMMIT` | `3'b010` |
| `FRP_SCHED_EXCITE` | `3'b011` |
| `FRP_SCHED_NEUTRALIZE` | `3'b100` |
| `FRP_SCHED_INVALID` | `3'b111` |

Public scheduler counters:

- `ticks_recorded_q`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`.

Required scheduler relation:

`sum(scheduler_state_counts) = ticks_recorded_q`

Qualified scheduler profiles:

| Mode | Qualified relation |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Scheduler interface qualification result:

`PASS`

## Request-Lane Input Interface

Request-lane inputs:

| Signal | Width | Meaning |
|---|---:|---|
| `request_valid` | `REQUEST_LANES` | per-lane request-valid flags |
| `request_cell_index` | `REQUEST_LANES × CELL_INDEX_BITS` | packed cell index for each request lane |
| `request_target` | `REQUEST_LANES × STATE_BITS` | packed ternary target for each request lane |

Per-lane packing relations:

`request_valid[lane]`

`request_cell_index[(lane × CELL_INDEX_BITS) +: CELL_INDEX_BITS]`

`request_target[(lane × STATE_BITS) +: STATE_BITS]`

Request lanes are evaluated in deterministic ascending lane order.

Request validation includes:

- tick-enable state;
- cell-index range;
- canonical target encoding;
- duplicate-cell rejection;
- retained pending-route ownership;
- scheduler eligibility;
- transition classification;
- transition-capacity admission.

Public request disposition outputs:

| Signal | Width | Meaning |
|---|---:|---|
| `request_accept` | `REQUEST_LANES` | accepted request flags after capacity admission |
| `request_reject` | `REQUEST_LANES` | combined request rejection flags |

Required request disposition relation:

`request_accept & request_reject = 0`

Required lane-order invariant:

`FRP_INV_REQUEST_LANE_ORDER_VALID = 1`

Request-lane interface qualification result:

`PASS`

## Phase-Derived Target Interface

Full target-vector input:

| Signal | Width | Meaning |
|---|---:|---|
| `target_q` | `CELLS × STATE_BITS` | packed phase-derived balanced ternary target vector |

Per-cell packing relation:

`target_q[(cell × STATE_BITS) +: STATE_BITS]`

The target vector is generated upstream by the resonant computation layer.

M16 does not redefine the target-generation rule.

Inherited M15 target rule:

`target_i = 1`, when `sin(phase_i) > 0.33`

`target_i = -1`, when `sin(phase_i) < -0.33`

`target_i = 0`, otherwise.

Required target-domain relation:

`target_q[cell] ∈ {-1, 0, 1}`

The full `target_q` vector participates in target-domain validation.

The per-lane `request_target` vector supplies the explicit requested target associated with each valid request lane.

Phase-derived target interface qualification result:

`PASS`

## Retained State and Pending Route Output Interface

The M16 core owns retained processor state internally.

Public retained-state output:

| Signal | Width | Meaning |
|---|---:|---|
| `state_out` | `CELLS × STATE_BITS` | packed retained balanced ternary processor state |

Per-cell retained-state relation:

`state_out[(cell × STATE_BITS) +: STATE_BITS]`

Required retained-state domain:

`state_out[cell] ∈ {-1, 0, 1}`

The M16 core owns retained pending-route state internally.

Public pending-route output:

| Signal | Width | Meaning |
|---|---:|---|
| `pending_route_out` | `CELLS × STATE_BITS` | packed retained pending polarity for each processor cell |

Per-cell pending-route relation:

`pending_route_out[(cell × STATE_BITS) +: STATE_BITS]`

Pending-route meanings:

| Ternary value | Meaning |
|---:|---|
| `0` | no retained opposite-polarity route |
| `-1` | retained target polarity `-1` |
| `1` | retained target polarity `1` |

Required pending-route domain:

`pending_route_out[cell] ∈ {-1, 0, 1}`

Required retained pending-polarity invariant:

`FRP_INV_PENDING_POLARITY_VALID = 1`

Retained-state and pending-route interface qualification result:

`PASS`

## Public Arbitration and Capacity Interface

Public request disposition outputs:

| Signal | Width | Meaning |
|---|---:|---|
| `request_accept` | `REQUEST_LANES` | request lanes accepted after transition-capacity admission |
| `request_reject` | `REQUEST_LANES` | combined request-lane and capacity rejection flags |

Public cell-mask outputs:

| Signal | Width | Meaning |
|---|---:|---|
| `accepted_cell_mask` | `CELLS` | accepted explicit-request cells after capacity admission |
| `neutral_routed_cell_mask` | `CELLS` | accepted cells executing an active-neutral route leg |
| `accepted_change_mask` | `CELLS` | admitted retained-state changes |

Public transition-capacity outputs:

| Signal | Width | Meaning |
|---|---:|---|
| `accepted_changes` | `COUNTER_BITS` | number of admitted retained-state changes |
| `capacity_remaining` | `COUNTER_BITS` | unused transition capacity for the tick |
| `capacity_exhausted` | `1` | transition-capacity exhaustion flag |
| `switch_load_numerator` | `COUNTER_BITS` | accepted-change numerator used by the switch-load relation |

Public output assignments:

`request_accept = request_accept_capacity`

`request_reject = request_reject_lane | request_reject_capacity`

`accepted_cell_mask = request_accepted_cell_mask & capacity_accept_mask`

`neutral_routed_cell_mask = transition_neutral_routed_mask & capacity_accept_mask`

`accepted_change_mask = capacity_accepted_change_mask`

`accepted_changes = capacity_accepted_changes`

`switch_load_numerator = capacity_switch_load_numerator`

Required request disposition relation:

`request_accept & request_reject = 0`

Required capacity-bound relation:

`accepted_changes <= REQUEST_LANES`

Required capacity-remaining relation:

`capacity_remaining = REQUEST_LANES - accepted_changes`

Required capacity-exhausted relation:

`capacity_exhausted = (accepted_changes == REQUEST_LANES)`

Required switch-load relation:

`switch_load_numerator = accepted_changes`

Admission priority:

1. pending-route completion candidates in ascending cell order;
2. accepted explicit requests in ascending request-lane order.

Same-state retention consumes no transition capacity.

Each accepted state-changing route leg consumes transition capacity on its execution tick.

Arbitration and capacity interface qualification result:

`PASS`

## Event Telemetry Interface

The public M16 core exposes the following event telemetry outputs:

| Signal | Width | Meaning |
|---|---:|---|
| `requested_direct_events` | `COUNTER_BITS` | requested opposite-polarity transitions |
| `prevented_direct_events` | `COUNTER_BITS` | requested direct transitions prevented by active-neutral routing |
| `neutral_routed_events` | `COUNTER_BITS` | transitions routed through active neutral state `0` |
| `actual_direct_events` | `COUNTER_BITS` | direct opposite-polarity transitions committed at retained-state writeback |
| `reserved_state_events` | `COUNTER_BITS` | reserved ternary encodings detected across the execution chain |
| `queue_overflow_events` | `COUNTER_BITS` | retained pending-route overflow events |

Canonical public event sources:

`requested_direct_events = transition_requested_direct_events`

`prevented_direct_events = transition_prevented_direct_events`

`neutral_routed_events = transition_neutral_routed_events`

`actual_direct_events = state_actual_direct_events`

`reserved_state_events = reserved_transition_events + pending_reserved_events + state_reserved_state_events`

`queue_overflow_events = pending_queue_overflow_events`

Required event relations:

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Qualified terminal event record:

| Event output | Recorded value |
|---|---:|
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Event telemetry interface qualification result:

`PASS`

## Integrated Invariant Flag Interface

Public invariant output:

| Signal | Width |
|---|---:|
| `invariant_flags` | `FRP_M16_INVARIANT_FLAGS` |

Invariant-vector width:

`FRP_M16_INVARIANT_FLAGS = 10`

Invariant indexes:

| Index | Invariant flag |
|---:|---|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` |
| `8` | `FRP_INV_NO_RESERVED_STATE` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` |

The integrated core computes:

`FRP_INV_STATE_DOMAIN_VALID`

from:

- request-cell domain validity;
- request-target domain validity;
- transition domain validity;
- transition output domain validity;
- pending-route domain validity;
- retained-state domain validity;
- retained-state output domain validity.

The integrated core computes:

`FRP_INV_SCHEDULER_COUNTS_VALID`

from:

- scheduler mode and state validity;
- scheduler counter consistency.

The integrated core computes:

`FRP_INV_REQUEST_LANE_ORDER_VALID`

from:

- deterministic lane ordering;
- request-cell domain validity;
- request-target domain validity;
- duplicate-cell protection;
- scheduler gating;
- transition-capacity validity;
- active-neutral routing validity.

The integrated core computes:

`FRP_INV_PENDING_POLARITY_VALID`

from:

- pending-route domain validity;
- exact pending-polarity retention;
- completion only from state `0`;
- non-overwrite behavior;
- transition-capacity validity;
- deterministic pending-route replay;
- absence of reserved pending-route state.

The integrated core computes:

`FRP_INV_ACTIVE_NEUTRAL_VALID`

from:

- request active-neutral routing;
- active-neutral transition generation;
- pending completion from state `0`;
- deterministic transition replay;
- active-neutral capacity admission;
- active-neutral writeback;
- pending-completion writeback;
- zero actual direct transitions.

The integrated core computes:

`FRP_INV_TRANSITION_CAPACITY_VALID`

from:

- request transition-capacity validity;
- transition-stage capacity validity;
- capacity-guard validity;
- accepted-change limit;
- capacity-remaining relation;
- capacity-exhaustion relation;
- same-state capacity relation;
- pending-route capacity relation;
- active-neutral capacity relation;
- switch-load bound;
- capacity-to-writeback correlation.

The integrated core computes:

`FRP_INV_STATE_UPDATE_VALID`

from:

- retained-state update validity;
- retained-state domain validity;
- retained-state output validity;
- capacity-qualified writeback;
- same-state hold validity;
- active-neutral writeback validity;
- pending-completion writeback validity;
- absence of reserved-state output;
- absence of direct opposite-polarity writeback.

The final three flags require:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Qualified integrated invariant vector:

`1111111111`

Integrated invariant interface qualification result:

`PASS`

## Transition Semantics

For a same-state request:

`state_i = request_target_i`

the retained result is:

`state_out_i = state_i`

No retained-state change is admitted.

For a neutral-to-nonzero request:

`state_i = 0`

and:

`request_target_i ∈ {-1, 1}`

the eligible transition is:

`0 → request_target_i`

For a nonzero-to-neutral request:

`state_i ∈ {-1, 1}`

and:

`request_target_i = 0`

the eligible transition is:

`state_i → 0`

For the opposite-polarity request:

`state_i = -1`

and:

`request_target_i = 1`

direct retained-state writeback is forbidden.

The first eligible route leg is:

`-1 → 0`

The exact requested polarity is retained as:

`pending_route_i = 1`

For the opposite-polarity request:

`state_i = 1`

and:

`request_target_i = -1`

direct retained-state writeback is forbidden.

The first eligible route leg is:

`1 → 0`

The exact requested polarity is retained as:

`pending_route_i = -1`

Required routed sequences:

`-1 → 0 → 1`

`1 → 0 → -1`

Required direct-transition relation:

`actual_direct_events = 0`

Transition-semantics qualification result:

`PASS`

## Pending Route Completion

Each retained processor cell contains one pending-route slot.

A pending-route slot records:

- no pending route as `0`;
- retained target polarity `-1`;
- retained target polarity `1`.

Pending-route completion has priority over new explicit requests for the same cell.

If:

`state_i = 0`

and:

`pending_route_i ∈ {-1, 1}`

and the scheduler permits completion,

and transition capacity is available,

then the eligible completion is:

`0 → pending_route_i`

After accepted completion:

`pending_route_i = 0`

Pending-route state is retained across:

- scheduler-ineligible ticks;
- transition-capacity deferral;
- disabled ticks.

Required pending-route relations:

`pending completion starts from state 0`

`pending completion preserves retained target polarity`

`pending route clears after accepted completion`

`queue_overflow_events = 0`

Pending-route completion qualification result:

`PASS`

## Retained Execution Tick Order

For each enabled processor tick, the integrated execution order is:

1. use the registered scheduler state;
2. identify pending-route completion candidates;
3. evaluate explicit request lanes in ascending lane order;
4. classify retained-state and requested-target relations;
5. generate active-neutral route candidates;
6. apply distributed transition-capacity admission;
7. update retained pending-route state;
8. commit capacity-qualified retained-state writeback;
9. expose architectural event telemetry;
10. evaluate the ten integrated invariant flags.

Pending-route completion candidates are admitted before new explicit requests.

Only capacity-qualified state-changing candidates reach retained-state writeback.

Retained execution tick-order qualification result:

`PASS`

## Scheduler Execution Relations

The public scheduler mode input selects:

- `FRP_MODE_FREE`;
- `FRP_MODE_7_1`;
- `FRP_MODE_1_7`.

For `FRP_MODE_FREE`:

`scheduler_state_q = FRP_SCHED_FREE`

For `FRP_MODE_7_1`:

- seven balance ticks use `FRP_SCHED_BALANCE`;
- one commit tick uses `FRP_SCHED_COMMIT`.

For `FRP_MODE_1_7`:

- one excite tick uses `FRP_SCHED_EXCITE`;
- seven neutralize ticks use `FRP_SCHED_NEUTRALIZE`.

Qualified scheduler records:

| Mode | Ticks | Recorded scheduler counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Required scheduler counter relation:

`sum(scheduler_state_counts) = ticks_recorded_q`

Scheduler execution qualification result:

`PASS`

## Assertion Correlation Boundary

Assertion module:

`rtl/m16/frp_m16_assertions.sv`

Executable testbench:

`rtl/m16/frp_m16_tb.sv`

The assertion module is connected to the public M16 core interface and internal architectural observation signals by the executable testbench.

Assertion coverage includes:

- reset-state behavior;
- tick-disabled retained-state hold;
- tick-disabled pending-route hold;
- scheduler mode validity;
- scheduler-state validity;
- scheduler counter consistency;
- clear-counter behavior;
- canonical retained-state encoding;
- canonical pending-route encoding;
- deterministic request-lane order;
- request acceptance and rejection separation;
- pending-route polarity retention;
- pending-route completion from state `0`;
- active-neutral route execution;
- transition-capacity enforcement;
- retained-state writeback;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- all ten integrated invariant flags.

Assertion execution result:

`PASS`

## M15 RTL Comparison Boundary

M16 inherits the qualified M15 semantic and implementation-mapping foundation.

M15 executable semantic reference:

`frp_prototype_v1_7_0.py`

M15 qualification record:

| Qualification record | Result |
|---|---:|
| self-test assertions | `41 / 41 PASS` |
| deterministic vector files | `10 / 10 byte-identical` |
| required semantic correlation matches | `5 / 5 = 1.0` |
| deterministic replay matches | `6 / 6 = 1.0` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The M15-to-M16 interface comparison boundary contains:

### Driven execution inputs

- `rst_n`;
- `tick_enable`;
- `clear_counters`;
- `scheduler_mode`;
- `request_valid`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

### Internally retained M16 execution state

- retained balanced ternary processor state;
- retained pending-route state;
- scheduler mode and state;
- scheduler tick and period indexes;
- scheduler counter bank.

### Compared execution outputs

- `state_out`;
- `pending_route_out`;
- `scheduler_mode_q`;
- `scheduler_state_q`;
- `ticks_recorded_q`;
- scheduler-state counters;
- `request_accept`;
- `request_reject`;
- accepted and neutral-routed cell masks;
- transition-capacity outputs;
- event telemetry outputs;
- `invariant_flags`.

M15-to-M16 compatibility document:

`docs/m16_m15_vector_replay_compatibility_report.md`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

M15-to-M16 interface compatibility result:

`PASS`

## FPGA Integration Interface

Target-independent FPGA integration top:

`fpga/m16/frp_m16_fpga_top.sv`

The FPGA integration top instantiates:

`frp_m16_core`

with the same parameter and public execution interface.

External reset input:

`rst_n_async`

The integration top implements:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick gating before `core_ready`;
- counter-clear gating before `core_ready`;
- request-valid gating before `core_ready`.

Qualified integration relations:

`core_ready = rst_n_core`

`tick_enable_core = tick_enable && core_ready`

`clear_counters_core = clear_counters && core_ready`

`request_valid_core = request_valid & {REQUEST_LANES{core_ready}}`

The FPGA integration top passes the following signals directly to the M16 core after readiness qualification:

- `scheduler_mode`;
- `request_cell_index`;
- `request_target`;
- `target_q`.

The integration top exposes the M16 core outputs:

- retained processor state;
- retained pending-route state;
- scheduler mode and state;
- scheduler counters;
- request acceptance and rejection;
- cell masks;
- transition-capacity telemetry;
- event telemetry;
- integrated invariant flags.

Qualified FPGA preparation record:

| Field | Recorded value |
|---|---|
| Workflow | `FRP M16 FPGA Preparation` |
| Workflow file | `.github/workflows/frp-m16-fpga-preparation.yml` |
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

FPGA integration interface result:

`PASS`

## M16 Interface Closure Criteria

The M16 core interface preserves:

- canonical balanced ternary encoding;
- retained processor-state ownership;
- retained pending-route ownership;
- asynchronous active-low core reset;
- explicit scheduler-mode input;
- registered scheduler mode and state outputs;
- deterministic request-lane order;
- canonical request-target validation;
- transition-capacity admission;
- mandatory active-neutral routing;
- pending-route completion priority;
- retained-state writeback;
- scheduler counter telemetry;
- architectural event telemetry;
- zero direct opposite-polarity execution;
- zero reserved-state events;
- zero queue-overflow events;
- ten integrated invariant flags;
- assertion correlation;
- M15 interface compatibility;
- target-independent FPGA integration.

## Interface Qualification Result

| Interface boundary | Result |
|---|---|
| canonical ternary encoding | `PASS` |
| parameter relations | `PASS` |
| clock and reset interface | `PASS` |
| scheduler input and output interface | `PASS` |
| request-lane input interface | `PASS` |
| phase-derived target interface | `PASS` |
| retained-state output interface | `PASS` |
| pending-route output interface | `PASS` |
| request disposition interface | `PASS` |
| cell-mask interface | `PASS` |
| transition-capacity interface | `PASS` |
| event telemetry interface | `PASS` |
| integrated invariant interface | `PASS` |
| transition semantics | `PASS` |
| pending-route completion | `PASS` |
| retained execution tick order | `PASS` |
| assertion correlation | `PASS` |
| M15 interface compatibility | `PASS` |
| FPGA integration interface | `PASS` |
| M16 RTL core interface contract | `PASS` |

Qualified RTL workflow:

`FRP M16 RTL Artifact Boundary #84`

Qualified RTL source commit:

`ede53cf`

RTL workflow result:

`SUCCESS`

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

Current release qualification:

`FRP v1.8.0 / M16 — PASS`

## Author

Maksym Marnov

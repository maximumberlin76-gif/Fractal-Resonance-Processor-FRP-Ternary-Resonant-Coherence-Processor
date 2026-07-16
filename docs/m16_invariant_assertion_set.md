# FRP M16 Invariant Assertion Set

## Status

`QUALIFIED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Qualified RTL Artifact

`rtl/m16/frp_m16_assertions.sv`

## Purpose

This document records the executable invariant assertion set for the M16 RTL core realization and FPGA preparation layers.

The assertion module observes the externally visible retained-state execution boundary and checks:

- canonical balanced ternary state and pending-route domains;
- reset initialization;
- tick-disabled state and pending-route retention;
- accepted-change authorization;
- active-neutral routing;
- pending-route retention and completion;
- scheduler-mode and scheduler-counter relations;
- request acceptance and rejection separation;
- transition-capacity relations;
- global zero-event relations;
- all ten integrated invariant flags.

M15 remains the qualified semantic and implementation-mapping foundation of these M16 RTL assertions.

The executable Python semantic reference remains:

`frp_prototype_v1_7_0.py`

## Assertion Execution Boundary

SystemVerilog assertion module:

`frp_m16_assertions`

The module is included and instantiated by:

- `rtl/m16/frp_m16_tb.sv`;
- `fpga/m16/frp_m16_fpga_tb.sv`.

The RTL testbench supplies:

- `rst_n` as the assertion reset boundary;
- the core `tick_enable` input;
- the core `clear_counters` input;
- all observed core outputs and counters.

The FPGA testbench supplies:

- `core_ready` as the assertion reset boundary;
- `tick_enable_qualified` as the assertion tick input;
- `clear_counters_qualified` as the assertion counter-clear input;
- all observed core outputs and counters.

The assertion module is compiled and executed with Verilator assertion support.

RTL build option:

`--assert`

FPGA testbench build option:

`--assert`

## Assertion Parameters

| Parameter | Default source | Function |
|---|---|---|
| `CELLS` | `FRP_M16_DEFAULT_CELLS` | number of retained processor cells |
| `STATE_BITS` | `FRP_M16_STATE_BITS` | retained-state width per cell |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` | request-lane and transition-capacity limit |
| `COUNTER_BITS` | `FRP_M16_COUNTER_BITS` | observed counter width |

Qualified testbench parameter relation:

`CELLS = 8`

`STATE_BITS = 2`

`REQUEST_LANES = 2`

`COUNTER_BITS = 32`

## Assertion Inputs

### Clock, Reset, and Execution Inputs

| Input | Width | Function |
|---|---:|---|
| `clk` | `1` | assertion sampling clock |
| `rst_n` | `1` | active-low assertion reset boundary |
| `tick_enable` | `1` | observed execution-tick enable |
| `clear_counters` | `1` | observed scheduler-counter clear |

### Scheduler Inputs

| Input | Width | Function |
|---|---:|---|
| `scheduler_mode_q` | scheduler-mode width | retained scheduler mode |
| `scheduler_state_q` | scheduler-state width | current scheduler state |
| `ticks_recorded_q` | `COUNTER_BITS` | recorded execution ticks |
| `scheduler_count_free_q` | `COUNTER_BITS` | recorded `free` ticks |
| `scheduler_count_balance_q` | `COUNTER_BITS` | recorded `balance` ticks |
| `scheduler_count_commit_q` | `COUNTER_BITS` | recorded `commit` ticks |
| `scheduler_count_excite_q` | `COUNTER_BITS` | recorded `excite` ticks |
| `scheduler_count_neutralize_q` | `COUNTER_BITS` | recorded `neutralize` ticks |

### State and Route Inputs

| Input | Width | Function |
|---|---:|---|
| `state_out` | `CELLS × STATE_BITS` | retained balanced ternary state bank |
| `pending_route_out` | `CELLS × STATE_BITS` | retained pending-route polarity bank |

### Request and Capacity Inputs

| Input | Width | Function |
|---|---:|---|
| `request_accept` | `REQUEST_LANES` | accepted request-lane vector |
| `request_reject` | `REQUEST_LANES` | rejected request-lane vector |
| `accepted_cell_mask` | `CELLS` | accepted cell mask |
| `neutral_routed_cell_mask` | `CELLS` | accepted active-neutral route mask |
| `accepted_change_mask` | `CELLS` | accepted retained-state change mask |
| `accepted_changes` | `COUNTER_BITS` | accepted retained-state change count |
| `capacity_remaining` | `COUNTER_BITS` | remaining tick-local transition capacity |
| `capacity_exhausted` | `1` | transition-capacity exhaustion flag |
| `switch_load_numerator` | `COUNTER_BITS` | accepted-change switch-load numerator |

### Event and Invariant Inputs

| Input | Width | Function |
|---|---:|---|
| `requested_direct_events` | `COUNTER_BITS` | requested opposite-polarity events |
| `prevented_direct_events` | `COUNTER_BITS` | prevented opposite-polarity direct events |
| `neutral_routed_events` | `COUNTER_BITS` | active-neutral routed events |
| `actual_direct_events` | `COUNTER_BITS` | executed direct opposite-polarity events |
| `reserved_state_events` | `COUNTER_BITS` | reserved-state events |
| `queue_overflow_events` | `COUNTER_BITS` | pending-route queue-overflow events |
| `invariant_flags` | `FRP_M16_INVARIANT_FLAGS` | integrated invariant vector |

## Assertion Clock and Temporal Operators

The default assertion clock is:

`@(posedge clk)`

Clocked assertion checks outside the reset and coverage sections use:

`disable iff (!rst_n)`

The implemented assertion relations use:

| Operator | Recorded use |
|---|---|
| `|->` | overlapped implication at the current sampled edge |
| `|=>` | non-overlapped implication at the next sampled edge |
| `$past(...)` | prior sampled retained state or pending-route value |
| `$stable(...)` | unchanged sampled value |
| `$countones(...)` | population count for accepted masks |

## Canonical Balanced Ternary Domain

The retained processor-state domain is:

`{-1, 0, 1}`

The canonical two-bit encoding is:

| Retained state | Encoding | State relation |
|---:|:---:|---|
| `-1` | `2'b11` | canonical negative retained state |
| `0` | `2'b00` | active neutral retained state |
| `1` | `2'b01` | canonical positive retained state |
| reserved | `2'b10` | invalid retained-state encoding |

Required opposite-polarity routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Forbidden direct retained-state transitions are:

`-1 → 1`

`1 → -1`

The state `0` is an executable balancing, damping, transition, and stabilization state.

## Static Request-Lane Profile Assertions

The assertion module evaluates three static parameter relations during initialization.

| Cell profile | Required request lanes | Failure action |
|---:|---:|---|
| `CELLS = 8` | `REQUEST_LANES = 2` | `$fatal(1, ...)` |
| `CELLS = 16` | `REQUEST_LANES = 4` | `$fatal(1, ...)` |
| `CELLS = 32` | `REQUEST_LANES = 8` | `$fatal(1, ...)` |

The qualified RTL and FPGA testbench profile satisfies:

`8 cells → 2 request lanes`

Qualification result:

`PASS`

## Reset Assertions

The reset properties are sampled on the default positive-edge assertion clock.

### Active-Neutral State and Pending-Route Reset

Antecedent:

`rst_n = 0`

Required current-edge relation:

`state_out = 0`

and:

`pending_route_out = 0`

Failure message:

`FRP M16 assertion failed: reset did not establish active-neutral retained state`

Qualification result:

`PASS`

### Scheduler-Counter Reset

Antecedent:

`rst_n = 0`

Required current-edge relations:

`ticks_recorded_q = 0`

`scheduler_count_free_q = 0`

`scheduler_count_balance_q = 0`

`scheduler_count_commit_q = 0`

`scheduler_count_excite_q = 0`

`scheduler_count_neutralize_q = 0`

Failure message:

`FRP M16 assertion failed: reset did not clear scheduler counters`

Qualification result:

`PASS`

## Per-Cell Retained-State and Pending-Route Assertions

The assertion module generates the following property set for every cell index from `0` through `CELLS - 1`.

For cell `i`:

`CELL_LSB = i × STATE_BITS`

### Retained-State Domain

Required relation:

`frp_is_valid_ternary(state_out_i) = 1`

Failure message:

`FRP M16 assertion failed: state_out contains reserved ternary encoding`

Qualification result:

`PASS`

### Pending-Route Domain

Required relation:

`frp_is_valid_ternary(pending_route_out_i) = 1`

Failure message:

`FRP M16 assertion failed: pending_route_out contains reserved encoding`

Qualification result:

`PASS`

### Tick-Disabled Retained-State Stability

Antecedent:

`tick_enable = 0`

Required next-edge relation:

`state_out_i remains stable`

Failure message:

`FRP M16 assertion failed: retained state changed while tick_enable was low`

Qualification result:

`PASS`

### Tick-Disabled Pending-Route Stability

Antecedent:

`tick_enable = 0`

Required next-edge relation:

`pending_route_out_i remains stable`

Failure message:

`FRP M16 assertion failed: pending route changed while tick_enable was low`

Qualification result:

`PASS`

### Accepted-Change Authorization

Antecedent:

`tick_enable = 1 AND accepted_change_mask_i = 0`

Required next-edge relation:

`state_out_i remains stable`

Failure message:

`FRP M16 assertion failed: state changed without accepted_change_mask`

Qualification result:

`PASS`

### Direct Opposite-Polarity Exclusion

Antecedent:

`tick_enable = 1`

Required next-edge relation:

`frp_is_opposite_polarity(previous state_out_i, current state_out_i) = 0`

This property excludes:

`-1 → 1`

and:

`1 → -1`

Failure message:

`FRP M16 assertion failed: direct opposite-polarity retained-state transition`

Qualification result:

`PASS`

### Active-Neutral First-Leg Execution

Antecedent:

`tick_enable = 1`

`neutral_routed_cell_mask_i = 1`

`accepted_change_mask_i = 1`

Required next-edge relations:

`state_out_i = 0`

`pending_route_out_i is nonzero`

`pending_route_out_i is opposite in polarity to the previous state_out_i`

Failure message:

`FRP M16 assertion failed: opposite-polarity request did not route through active neutral with retained pending polarity`

Qualification result:

`PASS`

### Deferred Pending-Route Retention

Antecedent:

`tick_enable = 1`

`pending_route_out_i is nonzero`

`accepted_change_mask_i = 0`

Required next-edge relation:

`pending_route_out_i remains stable`

Failure message:

`FRP M16 assertion failed: deferred pending route was cleared or overwritten`

Qualification result:

`PASS`

### Pending-Route Completion

Antecedent:

`tick_enable = 1`

`state_out_i = 0`

`pending_route_out_i is nonzero`

`accepted_change_mask_i = 1`

`neutral_routed_cell_mask_i = 0`

Required next-edge relations:

`state_out_i = previous pending_route_out_i`

`pending_route_out_i = 0`

Failure message:

`FRP M16 assertion failed: pending completion did not execute 0 to retained target`

Qualification result:

`PASS`

### Pending Completion Only From Active Neutral

Antecedent:

`tick_enable = 1`

`state_out_i is nonzero`

`pending_route_out_i is nonzero`

Required next-edge relation:

`pending_route_out_i remains stable`

Failure message:

`FRP M16 assertion failed: pending route completed from nonzero retained state`

Qualification result:

`PASS`

## Scheduler Assertions

The assertion module observes the retained scheduler mode, current scheduler state, total tick count, and five scheduler-state counters.

The scheduler-count sum is:

`scheduler_count_sum = scheduler_count_free_q + scheduler_count_balance_q + scheduler_count_commit_q + scheduler_count_excite_q + scheduler_count_neutralize_q`

### Scheduler-Mode Domain

Required relation:

`frp_is_valid_scheduler_mode(scheduler_mode_q) = 1`

Failure message:

`FRP M16 assertion failed: invalid scheduler mode`

Qualification result:

`PASS`

### Scheduler-State Domain

Required relation:

`frp_scheduler_state_is_valid(scheduler_state_q) = 1`

Valid scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`.

Failure message:

`FRP M16 assertion failed: invalid scheduler state`

Qualification result:

`PASS`

### Scheduler-Counter Sum

Required relation:

`scheduler_count_sum = ticks_recorded_q`

Failure message:

`FRP M16 assertion failed: scheduler counters do not sum to ticks_recorded`

Qualification result:

`PASS`

### Free-Mode State Relation

Antecedent:

`scheduler_mode_q = FRP_MODE_FREE`

Required current-edge relation:

`scheduler_state_q = FRP_SCHED_FREE`

Failure message:

`FRP M16 assertion failed: free mode emitted non-free scheduler state`

Qualification result:

`PASS`

### 7/1-Mode State Relation

Antecedent:

`scheduler_mode_q = FRP_MODE_7_1`

Required current-edge relation:

`scheduler_state_q = FRP_SCHED_BALANCE`

or:

`scheduler_state_q = FRP_SCHED_COMMIT`

Failure message:

`FRP M16 assertion failed: 7/1 mode emitted invalid scheduler state`

Qualification result:

`PASS`

### 1/7-Mode State Relation

Antecedent:

`scheduler_mode_q = FRP_MODE_1_7`

Required current-edge relation:

`scheduler_state_q = FRP_SCHED_EXCITE`

or:

`scheduler_state_q = FRP_SCHED_NEUTRALIZE`

Failure message:

`FRP M16 assertion failed: 1/7 mode emitted invalid scheduler state`

Qualification result:

`PASS`

### Scheduler-Counter Hold

Antecedent:

`tick_enable = 0`

`clear_counters = 0`

Required next-edge relations:

`ticks_recorded_q remains stable`

`scheduler_count_free_q remains stable`

`scheduler_count_balance_q remains stable`

`scheduler_count_commit_q remains stable`

`scheduler_count_excite_q remains stable`

`scheduler_count_neutralize_q remains stable`

Failure message:

`FRP M16 assertion failed: scheduler counters changed without tick or clear`

Qualification result:

`PASS`

### Counter Clear Without Tick

Antecedent:

`clear_counters = 1`

`tick_enable = 0`

Required next-edge relations:

`ticks_recorded_q = 0`

`scheduler_count_free_q = 0`

`scheduler_count_balance_q = 0`

`scheduler_count_commit_q = 0`

`scheduler_count_excite_q = 0`

`scheduler_count_neutralize_q = 0`

Failure message:

`FRP M16 assertion failed: clear_counters did not clear the scheduler counter bank`

Qualification result:

`PASS`

### Counter Clear With Tick

Antecedent:

`clear_counters = 1`

`tick_enable = 1`

Required next-edge relations:

`ticks_recorded_q = 1`

`scheduler_count_sum = 1`

Failure message:

`FRP M16 assertion failed: clear-plus-tick did not record exactly one scheduler event`

Qualification result:

`PASS`

## Request-Lane and Transition-Capacity Assertions

The assertion module observes final request acceptance, request rejection, accepted cells, active-neutral routes, retained-state changes, and transition-capacity telemetry.

The counter-width request-lane limit is:

`REQUEST_LANE_LIMIT = REQUEST_LANES`

### Request Acceptance and Rejection Separation

Required relation:

`request_accept AND request_reject = 0`

No request lane may be accepted and rejected in the same sampled cycle.

Failure message:

`FRP M16 assertion failed: request lane accepted and rejected simultaneously`

Qualification result:

`PASS`

### Tick-Disabled Execution Gating

Antecedent:

`tick_enable = 0`

Required current-edge relations:

`request_accept = 0`

`accepted_cell_mask = 0`

`accepted_change_mask = 0`

`accepted_changes = 0`

Failure message:

`FRP M16 assertion failed: execution was accepted while tick_enable was low`

Qualification result:

`PASS`

### Accepted-Cell Request-Lane Bound

Required relation:

`popcount(accepted_cell_mask) <= REQUEST_LANES`

Failure message:

`FRP M16 assertion failed: accepted_cell_mask exceeds request-lane boundary`

Qualification result:

`PASS`

### Accepted-Change Mask and Count Correlation

Required relation:

`popcount(accepted_change_mask) = accepted_changes`

Failure message:

`FRP M16 assertion failed: accepted_change_mask does not match accepted_changes`

Qualification result:

`PASS`

### Active-Neutral Route and Accepted-Cell Correlation

Required relation:

`neutral_routed_cell_mask AND NOT accepted_cell_mask = 0`

Every recorded active-neutral route belongs to the accepted-cell mask.

Failure message:

`FRP M16 assertion failed: neutral route exists outside accepted-element_index mask`

Qualification result:

`PASS`

### Active-Neutral Route and Accepted-Change Correlation

Required relation:

`neutral_routed_cell_mask AND NOT accepted_change_mask = 0`

Every recorded active-neutral route belongs to the accepted retained-state change mask.

Failure message:

`FRP M16 assertion failed: neutral route exists without an accepted state change`

Qualification result:

`PASS`

### Accepted-Change Capacity Bound

Required relation:

`accepted_changes <= REQUEST_LANE_LIMIT`

For the qualified eight-cell profile:

`accepted_changes <= 2`

Failure message:

`FRP M16 assertion failed: accepted_changes exceeds REQUEST_LANES`

Qualification result:

`PASS`

### Capacity-Remaining Relation

Required relation:

`capacity_remaining = REQUEST_LANE_LIMIT - accepted_changes`

Failure message:

`FRP M16 assertion failed: capacity_remaining relation mismatch`

Qualification result:

`PASS`

### Capacity-Exhausted Relation

Required relation:

`capacity_exhausted = (accepted_changes = REQUEST_LANE_LIMIT)`

Failure message:

`FRP M16 assertion failed: capacity_exhausted relation mismatch`

Qualification result:

`PASS`

### Switch-Load Numerator Relation

Required relation:

`switch_load_numerator = accepted_changes`

Failure message:

`FRP M16 assertion failed: switch_load_numerator must equal accepted_changes`

Qualification result:

`PASS`

## Event and Global Zero-Event Assertions

The event assertions operate on the public event totals emitted by `frp_m16_core`.

### Actual Direct Events

Required relation:

`actual_direct_events = 0`

The core sources actual execution from the retained-state writeback boundary.

Failure message:

`FRP M16 assertion failed: actual_direct_events must remain zero`

Qualification result:

`PASS`

### Reserved-State Events

Required relation:

`reserved_state_events = 0`

Failure message:

`FRP M16 assertion failed: reserved_state_events must remain zero`

Qualification result:

`PASS`

### Queue-Overflow Events

Required relation:

`queue_overflow_events = 0`

Failure message:

`FRP M16 assertion failed: queue_overflow_events must remain zero`

Qualification result:

`PASS`

### Requested and Prevented Direct-Event Relation

Required relation:

`prevented_direct_events >= requested_direct_events`

Failure message:

`FRP M16 assertion failed: requested direct event was not prevented`

Qualification result:

`PASS`

### Prevented and Active-Neutral Routed-Event Relation

Required relation:

`neutral_routed_events >= prevented_direct_events`

Failure message:

`FRP M16 assertion failed: prevented direct event was not neutral-routed`

Qualification result:

`PASS`

## Integrated Invariant-Flag Assertions

The M16 core exposes an invariant vector with ten indexed flags.

Invariant count:

`FRP_M16_INVARIANT_FLAGS = 10`

| Index | Invariant flag | Required value |
|---:|---|:---:|
| `0` | `FRP_INV_STATE_DOMAIN_VALID` | `1` |
| `1` | `FRP_INV_SCHEDULER_COUNTS_VALID` | `1` |
| `2` | `FRP_INV_REQUEST_LANE_ORDER_VALID` | `1` |
| `3` | `FRP_INV_PENDING_POLARITY_VALID` | `1` |
| `4` | `FRP_INV_ACTIVE_NEUTRAL_VALID` | `1` |
| `5` | `FRP_INV_TRANSITION_CAPACITY_VALID` | `1` |
| `6` | `FRP_INV_STATE_UPDATE_VALID` | `1` |
| `7` | `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `1` |
| `8` | `FRP_INV_NO_RESERVED_STATE` | `1` |
| `9` | `FRP_INV_NO_QUEUE_OVERFLOW` | `1` |

Each indexed flag is asserted independently by `frp_m16_assertions` while `rst_n = 1`.

## Core Invariant Aggregation

The invariant vector is assembled by `frp_m16_core` from module-local validity relations and public event totals.

### State-Domain Invariant

`FRP_INV_STATE_DOMAIN_VALID` is the conjunction of:

- `request_cell_domain_valid`;
- `request_target_domain_valid`;
- `transition_domain_valid`;
- `transition_state_output_domain_valid`;
- `pending_domain_valid`;
- `state_domain_valid`;
- `state_output_domain_valid`.

Required result:

`FRP_INV_STATE_DOMAIN_VALID = 1`

### Scheduler-Count Invariant

`FRP_INV_SCHEDULER_COUNTS_VALID` is the conjunction of:

- `scheduler_valid`;
- `scheduler_counts_valid`.

Required result:

`FRP_INV_SCHEDULER_COUNTS_VALID = 1`

### Request-Lane Order Invariant

`FRP_INV_REQUEST_LANE_ORDER_VALID` is the conjunction of:

- `request_lane_order_valid`;
- `request_cell_domain_valid`;
- `request_target_domain_valid`;
- `duplicate_cell_guard_valid`;
- `request_scheduler_gate_valid`;
- `request_transition_capacity_valid`;
- `request_active_neutral_routing_valid`.

Required result:

`FRP_INV_REQUEST_LANE_ORDER_VALID = 1`

### Pending-Polarity Invariant

`FRP_INV_PENDING_POLARITY_VALID` is the conjunction of:

- `pending_domain_valid`;
- `pending_polarity_valid`;
- `pending_completion_from_zero_valid`;
- `pending_non_overwrite_valid`;
- `pending_capacity_valid`;
- `pending_replay_deterministic`;
- `no_pending_reserved_state`.

Required result:

`FRP_INV_PENDING_POLARITY_VALID = 1`

### Active-Neutral Invariant

`FRP_INV_ACTIVE_NEUTRAL_VALID` is the conjunction of:

- `request_active_neutral_routing_valid`;
- `active_neutral_routing_valid`;
- `transition_pending_completion_from_zero_valid`;
- `transition_replay_deterministic`;
- `capacity_active_neutral_capacity_valid`;
- `active_neutral_writeback_valid`;
- `pending_completion_writeback_valid`;
- `transition_no_actual_direct_events`;
- `state_update_no_actual_direct_events`.

Required result:

`FRP_INV_ACTIVE_NEUTRAL_VALID = 1`

### Transition-Capacity Invariant

`FRP_INV_TRANSITION_CAPACITY_VALID` is the conjunction of:

- `request_transition_capacity_valid`;
- `transition_capacity_valid_local`;
- `capacity_transition_capacity_valid`;
- `accepted_changes_within_limit`;
- `capacity_remaining_valid`;
- `capacity_exhaustion_valid`;
- `same_state_capacity_valid`;
- `capacity_pending_capacity_valid`;
- `capacity_active_neutral_capacity_valid`;
- `switch_load_bound_valid`;
- `capacity_accepted_changes = state_update_accepted_changes`;
- `capacity_accepted_change_mask = state_write_enable_mask`;
- `capacity_switch_load_numerator = state_update_switch_load_numerator`.

Required result:

`FRP_INV_TRANSITION_CAPACITY_VALID = 1`

### State-Update Invariant

`FRP_INV_STATE_UPDATE_VALID` is the conjunction of:

- `state_update_valid`;
- `state_domain_valid`;
- `state_output_domain_valid`;
- `state_write_capacity_valid`;
- `same_state_hold_valid`;
- `active_neutral_writeback_valid`;
- `pending_completion_writeback_valid`;
- `no_reserved_state_output`;
- `state_update_no_actual_direct_events`.

Required result:

`FRP_INV_STATE_UPDATE_VALID = 1`

### No-Actual-Direct-Events Invariant

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS` is the conjunction of:

- `request_no_actual_direct_events`;
- `transition_no_actual_direct_events`;
- `pending_no_actual_direct_events`;
- `capacity_no_actual_direct_events`;
- `state_update_no_actual_direct_events`;
- `actual_direct_events = 0`.

Required result:

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS = 1`

### No-Reserved-State Invariant

`FRP_INV_NO_RESERVED_STATE` is the conjunction of:

- `no_reserved_transition`;
- `no_pending_reserved_state`;
- `no_reserved_state_output`;
- `reserved_state_events = 0`.

Required result:

`FRP_INV_NO_RESERVED_STATE = 1`

### No-Queue-Overflow Invariant

`FRP_INV_NO_QUEUE_OVERFLOW` is the conjunction of:

- `request_no_queue_overflow`;
- `pending_no_queue_overflow`;
- `capacity_no_queue_overflow`;
- `queue_overflow_events = 0`.

Required result:

`FRP_INV_NO_QUEUE_OVERFLOW = 1`

## Invariant-Flag Assertion Matrix

| Invariant flag | Failure message | Qualified result |
|---|---|:---:|
| `FRP_INV_STATE_DOMAIN_VALID` | `FRP M16 assertion failed: state-domain invariant flag is false` | `PASS` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `FRP M16 assertion failed: scheduler-count invariant flag is false` | `PASS` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `FRP M16 assertion failed: request-lane invariant flag is false` | `PASS` |
| `FRP_INV_PENDING_POLARITY_VALID` | `FRP M16 assertion failed: pending-polarity invariant flag is false` | `PASS` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `FRP M16 assertion failed: active-neutral invariant flag is false` | `PASS` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `FRP M16 assertion failed: transition-capacity invariant flag is false` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID` | `FRP M16 assertion failed: state-update invariant flag is false` | `PASS` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `FRP M16 assertion failed: no-actual-direct-events flag is false` | `PASS` |
| `FRP_INV_NO_RESERVED_STATE` | `FRP M16 assertion failed: no-reserved-state flag is false` | `PASS` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `FRP M16 assertion failed: no-queue-overflow flag is false` | `PASS` |

## Qualification Coverage Properties

The assertion module contains six executable coverage properties.

### Free Scheduler Mode Coverage

Covered relation:

`scheduler_mode_q = FRP_MODE_FREE`

Qualification result:

`PASS`

### 7/1 Scheduler Mode Coverage

Covered relation:

`scheduler_mode_q = FRP_MODE_7_1`

Qualification result:

`PASS`

### 1/7 Scheduler Mode Coverage

Covered relation:

`scheduler_mode_q = FRP_MODE_1_7`

Qualification result:

`PASS`

### Active-Neutral Route Coverage

Covered relation:

`neutral_routed_cell_mask != 0`

Qualification result:

`PASS`

### Accepted Change With Retained Pending Route Coverage

Covered relation:

`accepted_change_mask != 0`

and:

`pending_route_out != 0`

Qualification result:

`PASS`

### Capacity-Exhaustion Coverage

Covered relation:

`capacity_exhausted = 1`

Qualification result:

`PASS`

## Integrated Invariant Qualification Record

RTL qualification result:

| Invariant | Result |
|---|:---:|
| `FRP_INV_STATE_DOMAIN_VALID` | `PASS` |
| `FRP_INV_SCHEDULER_COUNTS_VALID` | `PASS` |
| `FRP_INV_REQUEST_LANE_ORDER_VALID` | `PASS` |
| `FRP_INV_PENDING_POLARITY_VALID` | `PASS` |
| `FRP_INV_ACTIVE_NEUTRAL_VALID` | `PASS` |
| `FRP_INV_TRANSITION_CAPACITY_VALID` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID` | `PASS` |
| `FRP_INV_NO_ACTUAL_DIRECT_EVENTS` | `PASS` |
| `FRP_INV_NO_RESERVED_STATE` | `PASS` |
| `FRP_INV_NO_QUEUE_OVERFLOW` | `PASS` |

FPGA terminal invariant vector:

`invariant_flags = 1111111111`

FPGA integrated invariant qualification:

`PASS`

## M15 Semantic and Implementation-Mapping Foundation

M15 remains the qualified semantic and implementation-mapping foundation of the M16 invariant assertion set.

M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Qualified workflow run:

`#1`

The M15 qualification record is:

| Qualification relation | Result |
|---|---:|
| implementation-mapping qualification | `41 / 41 PASS` |
| deterministic vector files byte-identical | `10 / 10` |
| required semantic correlation matches equal to `1.0` | `5 / 5` |
| deterministic replay matches equal to `1.0` | `6 / 6` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `fixed_point_topology_sum_exact` | `True` |
| `fixed_point_thermal_sum_exact` | `True` |

M15 qualification package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

The M16 assertion set realizes the retained-state, routing, capacity, scheduler, event, and invariant relations of this qualified semantic foundation at the RTL execution boundary.

## M16 RTL Assertion Qualification

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Trigger:

`workflow_dispatch`

### Initial Closure Record

| Field | Value |
|---|---|
| workflow run | `#82` |
| repository commit | `a68a2af` |
| branch | `main` |
| workflow result | `SUCCESS` |
| qualification artifact count | `1` |
| final qualification result | `PASS` |

### Synchronized Qualification Record

| Field | Value |
|---|---|
| workflow run | `#84` |
| qualified source commit | `ede53cf` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `52s` |
| qualification artifact count | `1` |

RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

## RTL Assertion Execution Boundary

Simulation source:

`rtl/m16/frp_m16_tb.sv`

Assertion source:

`rtl/m16/frp_m16_assertions.sv`

Simulation top:

`frp_m16_tb`

Synthesis boundary under test:

`frp_m16_core`

Qualified execution includes:

- SystemVerilog parsing;
- module elaboration;
- executable testbench generation;
- architectural simulation;
- assertion execution;
- terminal marker validation;
- latch-diagnostic rejection;
- multidriven-diagnostic rejection;
- repository-integrity validation;
- qualification evidence generation.

Assertion execution result:

`PASS`

Assertion-message syntax result:

`PASS`

## RTL Qualified Relation Matrix

| Assertion boundary | Result |
|---|:---:|
| retained-state domain | `PASS` |
| pending-route domain | `PASS` |
| reset state | `PASS` |
| disabled-tick retained-state retention | `PASS` |
| disabled-tick pending-route retention | `PASS` |
| state-change authorization | `PASS` |
| direct opposite-polarity exclusion | `PASS` |
| active-neutral first-leg execution | `PASS` |
| retained pending polarity | `PASS` |
| pending-route deferral | `PASS` |
| completion only from active neutral `0` | `PASS` |
| scheduler mode and state | `PASS` |
| scheduler-state counters | `PASS` |
| request acceptance and rejection separation | `PASS` |
| transition-capacity relations | `PASS` |
| retained-state writeback | `PASS` |
| integrated invariant flags | `PASS` |
| assertion message syntax | `PASS` |

## RTL Terminal Evidence

Terminal marker:

`FRP M16 deterministic RTL testbench completed.`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

Terminal marker validation:

`PASS`

## M16 FPGA Assertion Qualification

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

Trigger:

`workflow_dispatch`

### Initial Closure Record

| Field | Value |
|---|---|
| workflow run | `#1` |
| qualified repository commit | `326b69e` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `1m 7s` |
| qualification artifact count | `1` |
| final qualification result | `PASS` |

### Synchronized Qualification Record

| Field | Value |
|---|---|
| workflow run | `#2` |
| qualified repository commit | `ede53cf` |
| branch | `main` |
| workflow result | `SUCCESS` |
| duration | `36s` |
| qualification artifact count | `1` |

FPGA preparation closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

## FPGA Assertion Execution Boundary

FPGA integration top:

`fpga/m16/frp_m16_fpga_top.sv`

FPGA executable testbench:

`fpga/m16/frp_m16_fpga_tb.sv`

Assertion source:

`rtl/m16/frp_m16_assertions.sv`

The FPGA testbench connects the assertion module to:

`rst_n = core_ready`

`tick_enable = tick_enable_qualified`

`clear_counters = clear_counters_qualified`

The FPGA assertion execution boundary includes:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick gating before readiness;
- counter-clear gating before readiness;
- request-valid gating before readiness;
- scheduler-mode propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten invariant flags;
- zero actual direct events;
- zero reserved-state events;
- zero queue-overflow events.

FPGA assertion execution result:

`PASS`

## FPGA Terminal Evidence

Terminal marker:

`FRP M16 FPGA integration testbench completed.`

| Terminal relation | Recorded value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

Terminal marker validation:

`PASS`

The FPGA preparation qualification is target-independent.

## Qualified Artifact Correlation

| Artifact | Assertion-set relation |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | canonical state encoding, scheduler definitions, helper functions, and invariant indexes |
| `rtl/m16/frp_m16_scheduler.sv` | scheduler mode, state, and counter sources |
| `rtl/m16/frp_m16_request_lanes.sv` | deterministic request acceptance and rejection sources |
| `rtl/m16/frp_m16_pending_routes.sv` | retained pending-route state and event sources |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral transition and routing sources |
| `rtl/m16/frp_m16_capacity_guard.sv` | transition-capacity and accepted-change sources |
| `rtl/m16/frp_m16_state_update.sv` | retained-state writeback and actual direct-event source |
| `rtl/m16/frp_m16_core.sv` | public telemetry and integrated invariant aggregation |
| `rtl/m16/frp_m16_assertions.sv` | executable assertion and coverage properties |
| `rtl/m16/frp_m16_tb.sv` | executable RTL assertion qualification |
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration boundary |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA assertion qualification |

## Qualification State

The M16 invariant assertion-set qualification state is:

`PASS`

The M16 RTL execution-layer state is:

`M16 RTL EXECUTION LAYER CLOSED`

The M16 FPGA preparation-layer state is:

`M16 FPGA PREPARATION LAYER CLOSED`

## Author

Maksym Marnov



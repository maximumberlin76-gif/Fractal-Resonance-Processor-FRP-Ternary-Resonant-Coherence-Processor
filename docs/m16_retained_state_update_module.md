# FRP M16 Retained State Update Module

## Status

`QUALIFIED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Qualified RTL Artifact

`rtl/m16/frp_m16_state_update.sv`

## Purpose

This document records the qualified retained-state update module of the M16 RTL core realization layer.

The module owns the retained balanced ternary register bank and performs the final tick-level writeback after:

- scheduler propagation;
- request-lane arbitration;
- pending-route processing;
- active-neutral transition generation;
- transition-capacity admission.

The module implements the M15-qualified retained-state execution semantics in SystemVerilog.

The executable Python semantic reference remains:

`frp_prototype_v1_7_0.py`

## Module Boundary

SystemVerilog module:

`frp_m16_state_update`

The module contains:

- the retained register `state_q`;
- the combinational next-state bank `state_next`;
- the public next-state output `state_d`;
- the public retained-state output `state_out`;
- per-cell write, hold, reset, and reserved-state masks;
- accepted-change and writeback event counts;
- active-neutral and pending-completion commit counts;
- state-domain, capacity, route, and direct-transition validity outputs.

The module does not calculate:

- phase words;
- Kuramoto-Sakaguchi interaction;
- phase-derived ternary targets;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`.

## Canonical Retained-State Domain

The retained processor-state domain is:

`{-1, 0, 1}`

The canonical two-bit encoding is:

| Retained state | Encoding | State relation |
|---:|:---:|---|
| `-1` | `2'b11` | canonical negative retained state |
| `0` | `2'b00` | active neutral retained state |
| `1` | `2'b01` | canonical positive retained state |
| reserved | `2'b10` | invalid retained-state encoding |

The state `0` is an executable balancing, damping, transition, and stabilization state.

Required retained-state routes are:

`-1 → 0 → 1`

`1 → 0 → -1`

Forbidden direct retained-state transitions are:

`-1 → 1`

`1 → -1`

## Parameter Boundary

| Parameter | Default source | Function |
|---|---|---|
| `CELLS` | `FRP_M16_DEFAULT_CELLS` | number of retained processor cells |
| `STATE_BITS` | `FRP_M16_STATE_BITS` | state width per cell |
| `REQUEST_LANES` | `frp_calc_request_lanes(CELLS)` | maximum accepted state changes per tick |
| `COUNTER_BITS` | `FRP_M16_COUNTER_BITS` | telemetry-counter width |

Required state-width relation:

`STATE_BITS = 2`

Qualified testbench profile:

`CELLS = 8`

`REQUEST_LANES = 2`

## Module Inputs

| Input | Width | Function |
|---|---:|---|
| `clk` | `1` | processor clock |
| `rst_n` | `1` | asynchronous active-low reset |
| `tick_enable` | `1` | retained-state tick enable |
| `scheduler_state` | scheduler-state width | current qualified scheduler state |
| `state_candidate_d` | `CELLS × STATE_BITS` | candidate retained-state bank |
| `capacity_accept_mask` | `CELLS` | transition-capacity admission mask |
| `accepted_change_candidate_mask` | `CELLS` | state-changing candidate mask |
| `neutral_routed_mask` | `CELLS` | active-neutral first-leg classification mask |
| `pending_completion_mask` | `CELLS` | retained pending-route completion mask |
| `reserved_transition_mask` | `CELLS` | reserved-transition detection mask |
| `actual_direct_mask` | `CELLS` | direct opposite-polarity candidate mask |

`state_q` is owned by the state-update module and is not supplied as an input.

## Module Outputs

### Retained-State Outputs

| Output | Width | Function |
|---|---:|---|
| `state_q` | `CELLS × STATE_BITS` | retained balanced ternary register bank |
| `state_d` | `CELLS × STATE_BITS` | combinational next-state bank |
| `state_out` | `CELLS × STATE_BITS` | public retained-state bank |

The output assignments are:

`state_d = state_next`

`state_out = state_q`

### Per-Cell Masks

| Output | Width | Function |
|---|---:|---|
| `state_write_enable_mask` | `CELLS` | final state-changing writeback mask |
| `state_hold_mask` | `CELLS` | final unchanged-state mask |
| `state_reset_mask` | `CELLS` | asynchronous reset initialization mask |
| `state_reserved_mask` | `CELLS` | invalid current, candidate, transition, or final-state mask |

### Telemetry Outputs

| Output | Width | Function |
|---|---:|---|
| `accepted_changes` | `COUNTER_BITS` | final number of changed retained cells |
| `switch_load_numerator` | `COUNTER_BITS` | switch-load numerator |
| `state_write_events` | `COUNTER_BITS` | final retained-state write count |
| `state_hold_events` | `COUNTER_BITS` | final retained-state hold count |
| `state_reset_events` | `COUNTER_BITS` | reset-initialized cell count |
| `accepted_change_events` | `COUNTER_BITS` | final accepted-change count |
| `neutral_routed_commit_events` | `COUNTER_BITS` | committed active-neutral first legs |
| `pending_completion_commit_events` | `COUNTER_BITS` | committed pending-route completions |
| `reserved_state_events` | `COUNTER_BITS` | invalid state or reserved-transition observations |
| `actual_direct_events` | `COUNTER_BITS` | direct opposite-polarity retained-state writebacks |

### Validity Outputs

| Output | Required value |
|---|:---:|
| `state_domain_valid` | `1` |
| `state_output_domain_valid` | `1` |
| `state_update_valid` | `1` |
| `state_write_capacity_valid` | `1` |
| `same_state_hold_valid` | `1` |
| `active_neutral_writeback_valid` | `1` |
| `pending_completion_writeback_valid` | `1` |
| `no_reserved_state_output` | `1` |
| `no_actual_direct_events` | `1` |

## Retained Register Execution

The retained register is updated by:

`always_ff @(posedge clk or negedge rst_n)`

The sequential relation is:

| Condition | Retained-register action |
|---|---|
| `rst_n = 0` | `state_q = 0` for every cell |
| `rst_n = 1` and `tick_enable = 1` | `state_q = state_d` |
| `rst_n = 1` and `tick_enable = 0` | `state_q` retains its previous value |

## Asynchronous Reset

Asynchronous reset sets the complete retained-state bank to active neutral `0`.

While reset is asserted, the combinational state-update boundary records:

`state_next = 0`

`state_reset_mask = all cells`

`state_reset_events = CELLS`

The qualified reset relation is:

`state_out = 0`

## Tick-Disabled Retention

The combinational default is:

`state_next = state_q`

When `tick_enable = 0`, no candidate is committed.

The sequential retained bank does not write while `tick_enable = 0`.

The assertion relation is:

`tick_enable = 0 → state_out remains stable`

The integrated execution outputs also require:

`request_accept = 0`

`accepted_cell_mask = 0`

`accepted_change_mask = 0`

`accepted_changes = 0`

## Per-Cell Pre-Write Evaluation

For each cell `i`, the module evaluates:

`current_valid_i = frp_is_valid_ternary(state_q_i)`

`candidate_valid_i = frp_is_valid_ternary(state_candidate_d_i)`

`state_changes_i = (state_q_i != state_candidate_d_i)`

`direct_candidate_i = actual_direct_mask_i OR frp_is_opposite_polarity(state_q_i, state_candidate_d_i)`

The opposite-polarity function is evaluated only for canonical current and candidate states.

## Reserved-State Guard

The per-cell reserved-state condition is asserted when any of the following is true:

- the current retained state is not canonical;
- the candidate retained state is not canonical;
- `reserved_transition_mask_i = 1`.

For an observed reserved-state condition:

`state_reserved_mask_i = 1`

`reserved_state_events = reserved_state_events + 1`

`state_domain_valid = 0`

`writeback_contract_valid = 0`

A final noncanonical `state_next_i` also clears:

`state_output_domain_valid`

`no_reserved_state_output`

Qualified terminal relation:

`reserved_state_events = 0`

## Direct-Transition Guard

A direct opposite-polarity candidate clears the per-cell metadata legality relation and the writeback-contract validity relation.

The final state bank is scanned independently for an executed direct opposite-polarity transition.

For each final direct transition:

`actual_direct_events = actual_direct_events + 1`

`no_actual_direct_events = 0`

`writeback_contract_valid = 0`

Qualified terminal relation:

`actual_direct_events = 0`

## Route-Metadata Exclusivity

For one cell and one tick, these masks cannot both be asserted:

`neutral_routed_mask_i`

`pending_completion_mask_i`

If both are asserted, the module clears:

- `active_neutral_writeback_valid`;
- `pending_completion_writeback_valid`;
- the cell metadata legality relation;
- the writeback-contract validity relation.

## Same-State Relation

If `accepted_change_candidate_mask_i = 1`, the candidate must change retained state.

Required relation:

`accepted_change_candidate_mask_i = 1 → state_candidate_d_i != state_q_i`

A same-state cell is represented by `state_hold_mask_i`, not by `state_write_enable_mask_i`.

The final masks satisfy:

`state_write_enable_mask AND state_hold_mask = 0`

Outside reset, every cell is classified as write or hold.

During reset, every cell is classified by `state_reset_mask`.

The complete mask relation is:

`state_write_enable_mask OR state_hold_mask OR state_reset_mask = all cells`

## Scheduler Legality

Valid scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`.

Commit-capable scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`.

Neutralize-capable scheduler states are:

- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_NEUTRALIZE`.

The state-update legality table is:

| Candidate relation | Required scheduler capability |
|---|---|
| active-neutral first leg, nonzero to `0` | neutralize-capable |
| pending-route completion, `0` to nonzero | commit-capable |
| ordinary `0` to nonzero | commit-capable |
| ordinary nonzero to `0` | neutralize-capable |

Any other state-changing relation is scheduler-illegal at the retained-state writeback boundary.

## Active-Neutral First-Leg Writeback

For `neutral_routed_mask_i = 1`, the required relation is:

`state_q_i is nonzero`

`state_candidate_d_i = 0`

`scheduler_state is neutralize-capable`

The committed first leg is:

`-1 → 0`

or:

`1 → 0`

When the final writeback satisfies this relation:

`neutral_routed_commit_events = neutral_routed_commit_events + 1`

## Pending-Completion Writeback

For `pending_completion_mask_i = 1`, the required relation is:

`state_q_i = 0`

`state_candidate_d_i is nonzero`

`scheduler_state is commit-capable`

The committed completion is:

`0 → -1`

or:

`0 → 1`

When the final writeback satisfies this relation:

`pending_completion_commit_events = pending_completion_commit_events + 1`

## Commit-Authorization Relation

For each cell `i`, writeback is allowed only when every term below is true:

`tick_enable`

`current_valid_i`

`candidate_valid_i`

`state_changes_i`

`capacity_accept_mask_i`

`accepted_change_candidate_mask_i`

`NOT reserved_transition_mask_i`

`NOT direct_candidate_i`

`scheduler_legal_i`

`metadata_legal_i`

The complete Boolean relation is:

`commit_allowed_i = tick_enable AND current_valid_i AND candidate_valid_i AND state_changes_i AND capacity_accept_mask_i AND accepted_change_candidate_mask_i AND NOT reserved_transition_mask_i AND NOT direct_candidate_i AND scheduler_legal_i AND metadata_legal_i`

If `commit_allowed_i = 1`:

`state_next_i = state_candidate_d_i`

If `commit_allowed_i = 0`:

`state_next_i = state_q_i`

## Capacity Correlation

Every final retained-state change must be included in both:

`capacity_accept_mask`

`accepted_change_candidate_mask`

The module checks:

`accepted_changes <= REQUEST_LANES`

`state_write_enable_mask AND NOT capacity_accept_mask = 0`

`state_write_enable_mask AND NOT accepted_change_candidate_mask = 0`

The integrated core additionally requires:

`capacity_accepted_changes = state_update_accepted_changes`

`capacity_accepted_change_mask = state_write_enable_mask`

`capacity_switch_load_numerator = state_update_switch_load_numerator`

## Final Write and Hold Classification

For each cell:

`final_state_changed_i = (state_q_i != state_next_i)`

If `final_state_changed_i = 1`:

`state_write_enable_mask_i = 1`

`accepted_changes = accepted_changes + 1`

`state_write_events = state_write_events + 1`

`accepted_change_events = accepted_change_events + 1`

If `final_state_changed_i = 0`:

`state_hold_mask_i = 1`

`state_hold_events = state_hold_events + 1`

## Telemetry Equalities

The state-update module establishes:

`accepted_changes = state_write_events`

`accepted_changes = accepted_change_events`

`accepted_changes = popcount(state_write_enable_mask)`

`switch_load_numerator = accepted_changes`

The public core sources are:

`accepted_change_mask = capacity_accepted_change_mask`

`accepted_changes = capacity_accepted_changes`

`switch_load_numerator = capacity_switch_load_numerator`

Actual retained execution is sourced from the state-update boundary:

`actual_direct_events = state_actual_direct_events`

## State-Update Validity Relation

The module combines its preliminary state-domain result with:

`final state_domain_valid = preliminary state_domain_valid AND state_output_domain_valid AND no_reserved_state_output`

The final state-update validity relation is the conjunction of:

- `writeback_contract_valid`;
- a valid scheduler state;
- `state_domain_valid`;
- `state_write_capacity_valid`;
- `same_state_hold_valid`;
- `active_neutral_writeback_valid`;
- `pending_completion_writeback_valid`;
- `no_reserved_state_output`;
- `no_actual_direct_events`.

Required result:

`state_update_valid = 1`

## Integrated Invariant Correlation

The state-update module contributes directly to:

- `FRP_INV_STATE_DOMAIN_VALID`;
- `FRP_INV_ACTIVE_NEUTRAL_VALID`;
- `FRP_INV_TRANSITION_CAPACITY_VALID`;
- `FRP_INV_STATE_UPDATE_VALID`;
- `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
- `FRP_INV_NO_RESERVED_STATE`.

The integrated M16 invariant vector contains ten flags:

| Index | Invariant |
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

Qualified FPGA terminal vector:

`invariant_flags = 1111111111`

## Assertion Correlation

The integrated assertion layer verifies the following retained-state relations:

| Assertion relation | Qualified result |
|---|:---:|
| `state_out` contains only canonical ternary encodings | `PASS` |
| retained state remains stable while `tick_enable = 0` | `PASS` |
| a cell without `accepted_change_mask` remains stable | `PASS` |
| direct opposite-polarity retained-state transitions are absent | `PASS` |
| an accepted active-neutral route writes `0` and retains the requested pending polarity | `PASS` |
| a deferred pending route remains stable | `PASS` |
| an accepted pending completion executes from `0` and clears the route | `PASS` |
| `popcount(accepted_change_mask) = accepted_changes` | `PASS` |
| `accepted_changes <= REQUEST_LANES` | `PASS` |
| `switch_load_numerator = accepted_changes` | `PASS` |
| `actual_direct_events = 0` | `PASS` |
| `reserved_state_events = 0` | `PASS` |
| `FRP_INV_STATE_UPDATE_VALID = 1` | `PASS` |

## M15 Semantic Foundation

M15 remains the qualified semantic and implementation-mapping foundation of the M16 retained-state update module.

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

M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Qualified M15 workflow run:

`#1`

## M16 RTL Qualification

Workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Initial closure record:

| Field | Value |
|---|---|
| workflow run | `#82` |
| repository commit | `a68a2af` |
| branch | `main` |
| result | `SUCCESS` |
| qualification artifact count | `1` |

Synchronized qualification record:

| Field | Value |
|---|---|
| workflow run | `#84` |
| repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `52s` |
| qualification artifact count | `1` |

Closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Qualified retained-state writeback relations:

| Relation | Result |
|---|:---:|
| reset initializes active neutral state | `PASS` |
| disabled ticks retain state | `PASS` |
| state-changing writeback requires capacity | `PASS` |
| same-state retention consumes no capacity | `PASS` |
| opposite polarity commits the first leg through `0` | `PASS` |
| pending completion commits from `0` | `PASS` |
| capacity rejection preserves retained state | `PASS` |
| reserved encoding is not committed | `PASS` |
| direct opposite-polarity writeback is absent | `PASS` |
| combinational writeback has no inferred latch diagnostic | `PASS` |

RTL terminal record:

| Field | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |

## M16 FPGA Preparation Qualification

Workflow:

`FRP M16 FPGA Preparation`

Workflow file:

`.github/workflows/frp-m16-fpga-preparation.yml`

Initial closure record:

| Field | Value |
|---|---|
| workflow run | `#1` |
| repository commit | `326b69e` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `1m 7s` |
| qualification artifact count | `1` |

Synchronized qualification record:

| Field | Value |
|---|---|
| workflow run | `#2` |
| repository commit | `ede53cf` |
| branch | `main` |
| result | `SUCCESS` |
| duration | `36s` |
| qualification artifact count | `1` |

Closure status:

`M16 FPGA PREPARATION LAYER CLOSED`

The FPGA qualification propagates the retained-state update module through:

- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- execution-input gating before readiness;
- scheduler-mode propagation;
- request-interface propagation;
- active-neutral first-leg execution;
- retained pending-route completion;
- all ten invariant flags.

FPGA terminal record:

| Field | Value |
|---|---:|
| `CELLS` | `8` |
| `REQUEST_LANES` | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| `invariant_flags` | `1111111111` |

The FPGA preparation qualification is target-independent.

## Qualified Source Correlation

| Source | Recorded function |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | canonical ternary domain, scheduler states, helper functions, and invariant indexes |
| `rtl/m16/frp_m16_active_neutral.sv` | active-neutral candidate generation |
| `rtl/m16/frp_m16_capacity_guard.sv` | transition-capacity admission |
| `rtl/m16/frp_m16_state_update.sv` | retained-state register and final writeback |
| `rtl/m16/frp_m16_core.sv` | integrated telemetry and invariant aggregation |
| `rtl/m16/frp_m16_assertions.sv` | retained-state and integrated invariant assertions |
| `rtl/m16/frp_m16_tb.sv` | executable RTL qualification |
| `fpga/m16/frp_m16_fpga_top.sv` | target-independent FPGA integration top |
| `fpga/m16/frp_m16_fpga_tb.sv` | executable FPGA preparation qualification |

## Qualification State

The retained-state update module qualification state is:

`PASS`

The M16 RTL execution-layer state is:

`M16 RTL EXECUTION LAYER CLOSED`

The M16 FPGA preparation-layer state is:

`M16 FPGA PREPARATION LAYER CLOSED`

## Author

Maksym Marnov

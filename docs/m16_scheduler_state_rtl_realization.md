# FRP M16 Scheduler State RTL Realization

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the RTL-oriented scheduler-state realization for the M16 core layer.

The scheduler-state layer preserves the M15-qualified temporal execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

M16 does not treat `free`, `7/1`, and `1/7` as benchmark labels.

They are explicit processor execution semantics.

## Scheduler Boundary

The M16 scheduler controls tick-level execution state.

It does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma drift;
- coherence compression;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets.

The scheduler provides deterministic temporal gating for:

- retained-state update eligibility;
- request-lane arbitration;
- pending-route completion;
- active-neutral routing;
- transition-capacity application;
- scheduler event counting;
- M15 vector replay alignment.

## Scheduler Modes

M16 preserves three scheduler modes:

| Mode | Meaning |
|---|---|
| `free` | every tick is commit-capable |
| `7/1` | seven balance ticks followed by one commit tick |
| `1/7` | one excite tick followed by seven neutralize ticks |

Required inherited validation profiles:

| Mode | Ticks | Expected scheduler counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

## Scheduler Mode Encoding

Recommended RTL mode encoding:

| Scheduler mode | Encoding |
|---|---|
| `free` | `2'b00` |
| `7/1` | `2'b01` |
| `1/7` | `2'b10` |
| reserved | `2'b11` |

The reserved scheduler mode is invalid.

Required invariant:

`scheduler_mode_reserved_events = 0`

## Scheduler State Encoding

Recommended RTL scheduler-state encoding:

| Scheduler state | Encoding |
|---|---|
| `free` | `3'b000` |
| `balance` | `3'b001` |
| `commit` | `3'b010` |
| `excite` | `3'b011` |
| `neutralize` | `3'b100` |
| reserved | `3'b101` to `3'b111` |

Required invariant:

`scheduler_state_reserved_events = 0`

## Scheduler Registers

The scheduler-state realization uses:

| Register | Width | Meaning |
|---|---:|---|
| `scheduler_mode_q` | `2` | registered scheduler mode |
| `scheduler_state_q` | `3` | current scheduler state |
| `tick_index_q` | `COUNTER_BITS` | executed tick index |
| `period_index_q` | `3` | modulo-8 scheduler period index |
| `ticks_recorded_q` | `COUNTER_BITS` | executed tick counter |
| `free_count_q` | `COUNTER_BITS` | free-state tick counter |
| `balance_count_q` | `COUNTER_BITS` | balance-state tick counter |
| `commit_count_q` | `COUNTER_BITS` | commit-state tick counter |
| `excite_count_q` | `COUNTER_BITS` | excite-state tick counter |
| `neutralize_count_q` | `COUNTER_BITS` | neutralize-state tick counter |

Required relation:

`period_index_q = tick_index_q mod 8`

## Reset Behavior

On reset:

`scheduler_state_q = free`

`tick_index_q = 0`

`period_index_q = 0`

`ticks_recorded_q = 0`

`free_count_q = 0`

`balance_count_q = 0`

`commit_count_q = 0`

`excite_count_q = 0`

`neutralize_count_q = 0`

Required reset invariant:

`sum(scheduler_counts) = 0`

## Tick Enable Behavior

The scheduler advances only when:

`tick_enable = 1`

When:

`tick_enable = 0`

the scheduler must preserve:

- scheduler state;
- tick index;
- period index;
- scheduler counters;
- retained-state timing boundary.

Required invariant:

`tick_enable = 0 → ticks_recorded_q unchanged`

## Counter Clear Behavior

When:

`clear_counters = 1`

the scheduler clears event counters without changing:

- retained ternary state;
- pending-route state;
- scheduler mode;
- scheduler-state logic;
- reset domain.

Required relation:

`clear_counters` does not force retained state to `0`.

Only reset initializes retained state.

## Free Mode Realization

For:

`scheduler_mode_q = free`

the scheduler state is:

`scheduler_state_q = free`

Every enabled tick is commit-capable.

Required counter update:

`free_count_q += 1`

Required relation:

`free_count_q = ticks_recorded_q`

for a run containing only free-mode ticks after counter clear.

Required inherited validation profile:

`16 ticks → free = 16`

## 7/1 Mode Realization

For:

`scheduler_mode_q = 7/1`

the scheduler uses an eight-tick period.

The period relation is:

`period_index_q = tick_index_q mod 8`

Commit tick condition:

`period_index_q = 7`

Balance tick condition:

`period_index_q != 7`

Therefore:

`ticks 0,1,2,3,4,5,6 → balance`

`tick 7 → commit`

and the pattern repeats.

Required inherited validation profile:

`64 ticks → balance = 56, commit = 8`

## 1/7 Mode Realization

For:

`scheduler_mode_q = 1/7`

the scheduler uses an eight-tick period.

The period relation is:

`period_index_q = tick_index_q mod 8`

Excite tick condition:

`period_index_q = 0`

Neutralize tick condition:

`period_index_q != 0`

Therefore:

`tick 0 → excite`

`ticks 1,2,3,4,5,6,7 → neutralize`

and the pattern repeats.

Required inherited validation profile:

`16 ticks → excite = 2, neutralize = 14`

## Scheduler Output Enables

The scheduler emits execution enables to the downstream arbitration and transition layers.

| Enable | Active in state |
|---|---|
| `free_enable` | `free` |
| `balance_enable` | `balance` |
| `commit_enable` | `commit` |
| `excite_enable` | `excite` |
| `neutralize_enable` | `neutralize` |

Exactly one scheduler-state enable is active per enabled tick.

Required invariant:

`popcount(scheduler_state_enable_vector) = 1`

for every valid enabled tick.

## Free-State Semantics

In `free` state, the downstream transition layer may evaluate all eligible deterministic transition classes:

- pending-route completion;
- zero-to-nonzero target release;
- nonzero-to-zero neutralization;
- opposite-polarity active-neutral routing;
- unchanged-state retention.

The transition-capacity boundary still applies.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Balance-State Semantics

In `balance` state, the downstream transition layer preserves the balance phase of the `7/1` execution mode.

Balance ticks are used for deterministic stabilization before commit ticks.

The balance state may support:

- unchanged-state retention;
- nonzero-to-zero neutralization;
- active-neutral routing of opposite-polarity requests;
- pending-route retention.

Commit release is controlled by the commit state.

Required invariant:

`actual_direct_events = 0`

## Commit-State Semantics

In `commit` state, the downstream transition layer performs commit-capable retained-state updates for the `7/1` execution mode.

Commit ticks may support:

- pending-route completion;
- zero-to-nonzero target release;
- accepted retained-state update;
- event-counter emission.

The transition-capacity boundary still applies.

Required invariant:

`accepted_changes <= REQUEST_LANES`

## Excite-State Semantics

In `excite` state, the downstream transition layer preserves the excitation phase of the `1/7` execution mode.

Excite ticks may support:

- zero-to-nonzero target release;
- phase-derived nonzero target acceptance;
- pending-route completion when eligible;
- event-counter emission.

The transition-capacity boundary still applies.

Required invariant:

`switch_load_peak <= transition_fraction`

## Neutralize-State Semantics

In `neutralize` state, the downstream transition layer preserves the neutralization phase of the `1/7` execution mode.

Neutralize ticks may support:

- nonzero-to-zero neutralization;
- active-neutral routing of opposite-polarity requests;
- pending-route retention;
- unchanged-state retention.

Required invariant:

`actual_direct_events = 0`

## Scheduler Count Relations

The scheduler exposes M15-compatible counters:

| Counter | Meaning |
|---|---|
| `ticks_recorded` | total enabled ticks |
| `scheduler_count_free` | free ticks |
| `scheduler_count_balance` | balance ticks |
| `scheduler_count_commit` | commit ticks |
| `scheduler_count_excite` | excite ticks |
| `scheduler_count_neutralize` | neutralize ticks |

Required global relation:

`scheduler_count_free + scheduler_count_balance + scheduler_count_commit + scheduler_count_excite + scheduler_count_neutralize = ticks_recorded`

Required flag:

`scheduler_counts_valid = True`

## 7/1 Count Formula

For a run entirely in `7/1` mode:

`commit_count = floor(ticks_recorded / 8)`

when tick indexing starts at `0` and commit occurs at period index `7`.

`balance_count = ticks_recorded - commit_count`

Validated example:

`ticks_recorded = 64`

`commit_count = 8`

`balance_count = 56`

## 1/7 Count Formula

For a run entirely in `1/7` mode:

`excite_count = floor((ticks_recorded + 7) / 8)`

when tick indexing starts at `0` and excite occurs at period index `0`.

`neutralize_count = ticks_recorded - excite_count`

Validated example:

`ticks_recorded = 16`

`excite_count = 2`

`neutralize_count = 14`

## Mode-Switch Boundary

M16 should treat scheduler-mode switching as a deterministic control boundary.

A mode switch must not create:

- invalid scheduler state;
- invalid ternary state;
- pending-route polarity loss;
- direct opposite-polarity transition;
- counter inconsistency.

Recommended mode-switch rule:

`scheduler_mode_q` may update only at a tick boundary.

Required invariant:

`mode switch does not modify retained ternary state directly`

## Scheduler Reserved-State Guard

The scheduler must detect invalid mode or state encodings.

Required detection signals:

| Signal | Meaning |
|---|---|
| `scheduler_mode_reserved` | selected mode is `2'b11` |
| `scheduler_state_reserved` | scheduler state is `3'b101` to `3'b111` |
| `scheduler_valid` | no reserved scheduler condition |

Required invariant:

`scheduler_valid = True`

during qualified replay.

## Interaction With Request-Lane Arbitration

The scheduler does not reorder request lanes.

Request-lane order remains deterministic ascending lane order.

The scheduler only provides temporal eligibility.

Required invariant:

`scheduler state must not alter lane ordering`

## Interaction With Pending Routes

The scheduler may gate when a pending route can complete.

The scheduler must not erase pending-route polarity.

Required invariant:

`pending routes preserve requested target polarity`

Pending-route completion remains subject to:

- scheduler state;
- transition-capacity boundary;
- request-lane arbitration;
- active-neutral transition rules.

## Interaction With Active Neutral Routing

The scheduler must preserve mandatory active-neutral routing.

Forbidden transitions remain forbidden in every scheduler state:

`-1 → +1`

`+1 → -1`

Allowed routed sequences remain:

`-1 → 0 → +1`

`+1 → 0 → -1`

Required invariant:

`actual_direct_events = 0`

## Assertion Support

The M16 scheduler-state realization supports the following assertion layer:

| Assertion | Required condition |
|---|---|
| `assert_valid_scheduler_mode` | scheduler mode is not reserved |
| `assert_valid_scheduler_state` | scheduler state is not reserved |
| `assert_onehot_scheduler_enable` | exactly one state enable is active |
| `assert_scheduler_counts_sum` | scheduler counts sum to ticks recorded |
| `assert_free_count_profile` | free mode count matches ticks |
| `assert_7_1_profile` | 7/1 mode count profile matches expected period |
| `assert_1_7_profile` | 1/7 mode count profile matches expected period |
| `assert_no_state_change_on_tick_disable` | scheduler does not advance without tick enable |
| `assert_mode_switch_boundary` | mode switch does not alter retained state directly |

## M15 Vector Replay Boundary

The M16 scheduler must replay against the M15 deterministic vector package.

Comparison inputs:

`scheduler_mode`

`tick_index`

`tick_enable`

`clear_counters`

Comparison outputs:

`scheduler_state`

`scheduler_state_enable_vector`

`scheduler_count_free`

`scheduler_count_balance`

`scheduler_count_commit`

`scheduler_count_excite`

`scheduler_count_neutralize`

`ticks_recorded`

`scheduler_counts_valid`

Expected source:

`M15 cycle-exact integer golden trace`

## Required M16 Scheduler Invariants

The M16 scheduler-state realization is valid only if:

`free` mode emits only free scheduler state.

`7/1` mode emits seven balance ticks followed by one commit tick.

`1/7` mode emits one excite tick followed by seven neutralize ticks.

Scheduler counts sum to ticks recorded.

Reserved scheduler modes are rejected.

Reserved scheduler states are rejected.

Exactly one scheduler-state enable is active per valid enabled tick.

Tick-disabled cycles do not advance scheduler state.

Mode switching does not directly modify retained ternary state.

Request-lane order remains deterministic.

Active-neutral routing remains mandatory.

Direct opposite-polarity execution remains zero.

## Closure Criteria

This scheduler realization can be considered M16-ready when it supports:

- explicit scheduler-mode encoding;
- explicit scheduler-state encoding;
- deterministic modulo-8 period realization;
- valid `free` profile;
- valid `7/1` profile;
- valid `1/7` profile;
- scheduler counter emission;
- scheduler invariant flags;
- assertion correlation;
- M15 vector replay compatibility.

## Next Step

The next M16 file should define the request-lane arbitration layer:

`docs/m16_request_lane_arbitration_module.md`

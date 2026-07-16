# FRP M16 Scheduler State RTL Realization

## Status

`M16 RTL EXECUTION LAYER CLOSED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the qualified scheduler-state RTL realization for the M16 core layer of the:

`Ternary Fractal Resonant Coherence Processor`

The scheduler preserves the M15-qualified temporal execution modes:

- `free`;
- `7/1`;
- `1/7`.

These modes are explicit processor execution semantics.

The scheduler supplies the temporal execution state used by:

- request-lane arbitration;
- pending-route completion;
- active-neutral routing;
- transition-capacity admission;
- retained-state writeback;
- scheduler event counting;
- integrated invariant evaluation;
- architectural assertion execution.

Primary scheduler implementation:

`rtl/m16/frp_m16_scheduler.sv`

Shared scheduler types and functions:

`rtl/m16/frp_m16_pkg.sv`

## Qualified Scheduler Record

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

Qualified scheduler profiles:

| Mode | Qualified tick count | Qualified scheduler-state counts |
|---|---:|---|
| `free` | `16` | `free = 16` |
| `7/1` | `64` | `balance = 56`, `commit = 8` |
| `1/7` | `16` | `excite = 2`, `neutralize = 14` |

Required scheduler-count relation:

`sum(scheduler_state_counts) = ticks_recorded_q`

Scheduler qualification result:

`PASS`

## Scheduler Boundary

The M16 scheduler controls tick-level temporal execution state.

The scheduler receives:

- processor clock;
- asynchronous active-low reset;
- tick enable;
- scheduler-counter clear;
- selected scheduler mode.

The scheduler retains:

- registered scheduler mode;
- registered scheduler state;
- tick index;
- modulo-eight period index;
- total executed-tick count;
- per-state scheduler counters.

The scheduler emits:

- registered scheduler mode;
- registered scheduler state;
- temporal execution enables;
- scheduler validity signals;
- scheduler-count validity.

The scheduler does not compute:

- phase words;
- Kuramoto-Sakaguchi coupling;
- thermal state;
- gamma state;
- coherence telemetry;
- `C(t)`;
- `P(t)`;
- phase-derived ternary targets.

## Scheduler Module Interface

Module:

`frp_m16_scheduler`

Module parameter:

| Parameter | Default | Meaning |
|---|---|---|
| `COUNTER_BITS` | `FRP_M16_COUNTER_BITS` | scheduler index and counter width |

Qualified counter width:

`COUNTER_BITS = 32`

Control inputs:

| Signal | Direction | Meaning |
|---|---|---|
| `clk` | input | processor clock |
| `rst_n` | input | asynchronous active-low reset |
| `tick_enable` | input | enables one scheduler execution tick |
| `clear_counters` | input | clears the scheduler counter bank |
| `scheduler_mode` | input | selected scheduler mode |

Registered outputs:

| Signal | Width or type | Meaning |
|---|---|---|
| `scheduler_mode_q` | `frp_m16_scheduler_mode_e` | registered scheduler mode |
| `scheduler_state_q` | `frp_m16_scheduler_state_e` | registered scheduler state used by the execution chain |
| `tick_index_q` | `COUNTER_BITS` | scheduler execution index |
| `period_index_q` | `3` | modulo-eight scheduler period index |
| `ticks_recorded_q` | `COUNTER_BITS` | enabled scheduler-tick count |
| `scheduler_count_free_q` | `COUNTER_BITS` | free-state tick count |
| `scheduler_count_balance_q` | `COUNTER_BITS` | balance-state tick count |
| `scheduler_count_commit_q` | `COUNTER_BITS` | commit-state tick count |
| `scheduler_count_excite_q` | `COUNTER_BITS` | excite-state tick count |
| `scheduler_count_neutralize_q` | `COUNTER_BITS` | neutralize-state tick count |

Execution-enable outputs:

| Signal | Meaning |
|---|---|
| `free_enable` | current enabled tick uses `FRP_SCHED_FREE` |
| `balance_enable` | current enabled tick uses `FRP_SCHED_BALANCE` |
| `commit_enable` | current enabled tick uses `FRP_SCHED_COMMIT` |
| `excite_enable` | current enabled tick uses `FRP_SCHED_EXCITE` |
| `neutralize_enable` | current enabled tick uses `FRP_SCHED_NEUTRALIZE` |

Validity outputs:

| Signal | Meaning |
|---|---|
| `scheduler_mode_reserved` | registered scheduler mode is invalid |
| `scheduler_state_reserved` | registered scheduler state is invalid |
| `scheduler_valid` | mode, state, period, and enable relations are valid |
| `scheduler_counts_valid` | scheduler-state counter sum equals `ticks_recorded_q` |

## Scheduler Modes

Qualified scheduler modes:

| Mode | Package symbol | Execution sequence |
|---|---|---|
| `free` | `FRP_MODE_FREE` | every enabled tick uses `free` |
| `7/1` | `FRP_MODE_7_1` | seven `balance` ticks followed by one `commit` tick |
| `1/7` | `FRP_MODE_1_7` | one `excite` tick followed by seven `neutralize` ticks |

Scheduler period length:

`FRP_M16_PERIOD_TICKS = 8`

Scheduler period-index width:

`FRP_M16_PERIOD_BITS = 3`

## Scheduler Mode Encoding

Scheduler mode type:

`frp_m16_scheduler_mode_e`

Canonical mode encodings:

| Scheduler mode | Package symbol | Encoding |
|---|---|---|
| `free` | `FRP_MODE_FREE` | `2'b00` |
| `7/1` | `FRP_MODE_7_1` | `2'b01` |
| `1/7` | `FRP_MODE_1_7` | `2'b10` |
| reserved | `FRP_MODE_RESERVED` | `2'b11` |

Valid-mode function:

`frp_is_valid_scheduler_mode`

The valid-mode set is:

`{FRP_MODE_FREE, FRP_MODE_7_1, FRP_MODE_1_7}`

An invalid selected mode is registered as:

`FRP_MODE_RESERVED`

Required qualified result:

`scheduler_mode_reserved = 0`

Scheduler-mode encoding result:

`PASS`

## Scheduler State Encoding

Scheduler-state type:

`frp_m16_scheduler_state_e`

Canonical scheduler-state encodings:

| Scheduler state | Package symbol | Encoding |
|---|---|---|
| `free` | `FRP_SCHED_FREE` | `3'b000` |
| `balance` | `FRP_SCHED_BALANCE` | `3'b001` |
| `commit` | `FRP_SCHED_COMMIT` | `3'b010` |
| `excite` | `FRP_SCHED_EXCITE` | `3'b011` |
| `neutralize` | `FRP_SCHED_NEUTRALIZE` | `3'b100` |
| invalid | `FRP_SCHED_INVALID` | `3'b111` |

Valid-state function:

`frp_scheduler_state_is_valid`

The valid-state set is:

`{FRP_SCHED_FREE, FRP_SCHED_BALANCE, FRP_SCHED_COMMIT, FRP_SCHED_EXCITE, FRP_SCHED_NEUTRALIZE}`

Any encoding outside the valid-state set is invalid.

Required qualified result:

`scheduler_state_reserved = 0`

Scheduler-state encoding result:

`PASS`

## Scheduler Registers

The scheduler register bank contains:

| Register | Width | Reset value |
|---|---:|---|
| `scheduler_mode_q` | `2` | `FRP_MODE_FREE` |
| `scheduler_state_q` | `3` | `FRP_SCHED_FREE` |
| `tick_index_q` | `COUNTER_BITS` | `0` |
| `period_index_q` | `3` | `0` |
| `ticks_recorded_q` | `COUNTER_BITS` | `0` |
| `scheduler_count_free_q` | `COUNTER_BITS` | `0` |
| `scheduler_count_balance_q` | `COUNTER_BITS` | `0` |
| `scheduler_count_commit_q` | `COUNTER_BITS` | `0` |
| `scheduler_count_excite_q` | `COUNTER_BITS` | `0` |
| `scheduler_count_neutralize_q` | `COUNTER_BITS` | `0` |

Required period relation:

`period_index_q = tick_index_q[2:0]`

Equivalent numeric relation:

`period_index_q = tick_index_q mod 8`

Scheduler-register qualification result:

`PASS`

## Reset Behavior

The scheduler uses asynchronous active-low reset assertion:

`always_ff @(posedge clk or negedge rst_n)`

When:

`rst_n = 0`

the scheduler registers become:

`scheduler_mode_q = FRP_MODE_FREE`

`scheduler_state_q = FRP_SCHED_FREE`

`tick_index_q = 0`

`period_index_q = 0`

`ticks_recorded_q = 0`

`scheduler_count_free_q = 0`

`scheduler_count_balance_q = 0`

`scheduler_count_commit_q = 0`

`scheduler_count_excite_q = 0`

`scheduler_count_neutralize_q = 0`

Required reset relation:

`sum(scheduler_state_counts) = 0`

Reset qualification result:

`PASS`

## Scheduler Mode Capture

The selected input mode is evaluated on every scheduler clock update.

For a valid input:

`scheduler_mode_d = scheduler_mode`

For an invalid input:

`scheduler_mode_d = FRP_MODE_RESERVED`

The next scheduler state is decoded from:

`scheduler_mode_d`

and:

`period_index_d`

Mode reconfiguration does not consume a processor tick.

Mode reconfiguration does not directly modify:

- retained balanced ternary processor state;
- retained pending-route state;
- tick index;
- scheduler event counters.

Scheduler-mode capture result:

`PASS`

## Tick Enable Behavior

When:

`tick_enable = 1`

the scheduler:

- uses `scheduler_state_q` for the current execution tick;
- increments `tick_index_q`;
- increments `ticks_recorded_q`;
- increments the counter associated with `scheduler_state_q`;
- updates `period_index_q` from the incremented tick index;
- decodes the next scheduler state.

Required tick-index relation:

`tick_index_d = tick_index_q + 1`

Required tick-count relation:

`ticks_recorded_d = ticks_recorded_q + 1`

When:

`tick_enable = 0`

the scheduler preserves:

- `tick_index_q`;
- `period_index_q`;
- `ticks_recorded_q`;
- all scheduler-state counters.

Scheduler mode capture and scheduler-state decoding remain active at the clock boundary.

All execution-enable outputs remain zero while:

`tick_enable = 0`

Required disabled-tick relations:

`tick_index_d = tick_index_q`

`ticks_recorded_d = ticks_recorded_q`

`scheduler_enable_vector = 5'b00000`

Tick-enable qualification result:

`PASS`

## Counter Clear Behavior

The `clear_counters` input applies to the scheduler counter bank.

When:

`clear_counters = 1`

and:

`tick_enable = 0`

the following registers become zero:

- `ticks_recorded_q`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`.

Counter clear does not reset:

- `tick_index_q`;
- `period_index_q`;
- `scheduler_mode_q`;
- scheduler-state progression;
- retained balanced ternary processor state;
- retained pending-route state.

When `clear_counters` and `tick_enable` are active in the same update:

1. the scheduler counter bank is cleared;
2. the enabled tick is recorded;
3. the counter associated with `scheduler_state_q` is incremented.

Required clear relation with `tick_enable = 0`:

`ticks_recorded_q = 0`

`sum(scheduler_state_counts) = 0`

Counter-clear qualification result:

`PASS`

## Scheduler-State Decode

Scheduler-state decode function:

`frp_decode_scheduler_state`

Decode inputs:

- selected scheduler mode;
- three-bit period index.

Decode relation for `FRP_MODE_FREE`:

`scheduler_state = FRP_SCHED_FREE`

Decode relation for `FRP_MODE_7_1`:

`period_index = 7 → scheduler_state = FRP_SCHED_COMMIT`

`period_index != 7 → scheduler_state = FRP_SCHED_BALANCE`

Decode relation for `FRP_MODE_1_7`:

`period_index = 0 → scheduler_state = FRP_SCHED_EXCITE`

`period_index != 0 → scheduler_state = FRP_SCHED_NEUTRALIZE`

Decode relation for an invalid mode:

`scheduler_state = FRP_SCHED_INVALID`

Scheduler-state decode result:

`PASS`

## Scheduler Output Enables

The execution-enable vector is:

`{neutralize_enable, excite_enable, commit_enable, balance_enable, free_enable}`

For an enabled tick in a valid scheduler state:

`$countones(scheduler_enable_vector) = 1`

Enable mapping:

| Registered scheduler state | Active enable |
|---|---|
| `FRP_SCHED_FREE` | `free_enable` |
| `FRP_SCHED_BALANCE` | `balance_enable` |
| `FRP_SCHED_COMMIT` | `commit_enable` |
| `FRP_SCHED_EXCITE` | `excite_enable` |
| `FRP_SCHED_NEUTRALIZE` | `neutralize_enable` |

For:

`tick_enable = 0`

all five execution enables equal `0`.

For an invalid scheduler state:

all five execution enables equal `0`.

Scheduler-output-enable qualification result:

`PASS`

## Free Mode Qualification

For:

`scheduler_mode_q = FRP_MODE_FREE`

the scheduler emits:

`scheduler_state_q = FRP_SCHED_FREE`

Every enabled tick increments:

- `tick_index_q`;
- `ticks_recorded_q`;
- `scheduler_count_free_q`.

The other scheduler-state counters remain unchanged.

Qualified free-mode profile:

| Field | Recorded value |
|---|---:|
| enabled ticks | `16` |
| `scheduler_count_free_q` | `16` |
| `scheduler_count_balance_q` | `0` |
| `scheduler_count_commit_q` | `0` |
| `scheduler_count_excite_q` | `0` |
| `scheduler_count_neutralize_q` | `0` |

Required free-mode relation:

`scheduler_count_free_q = ticks_recorded_q`

Free-mode qualification result:

`PASS`

## 7/1 Mode Qualification

For:

`scheduler_mode_q = FRP_MODE_7_1`

the scheduler uses an eight-tick period.

Period relation:

`period_index_q = tick_index_q mod 8`

Scheduler-state decode:

| Period index | Scheduler state |
|---:|---|
| `0` | `FRP_SCHED_BALANCE` |
| `1` | `FRP_SCHED_BALANCE` |
| `2` | `FRP_SCHED_BALANCE` |
| `3` | `FRP_SCHED_BALANCE` |
| `4` | `FRP_SCHED_BALANCE` |
| `5` | `FRP_SCHED_BALANCE` |
| `6` | `FRP_SCHED_BALANCE` |
| `7` | `FRP_SCHED_COMMIT` |

Qualified `7/1` profile:

| Field | Recorded value |
|---|---:|
| enabled ticks | `64` |
| `scheduler_count_balance_q` | `56` |
| `scheduler_count_commit_q` | `8` |
| `scheduler_count_free_q` | `0` |
| `scheduler_count_excite_q` | `0` |
| `scheduler_count_neutralize_q` | `0` |

For a run starting at period index `0`:

`commit_count = floor(ticks_recorded_q / 8)`

`balance_count = ticks_recorded_q - commit_count`

Validated relation:

`64 ticks → balance = 56, commit = 8`

The qualified testbench records:

- zero-to-nonzero release rejected during balance ticks;
- zero-to-nonzero release accepted during a commit tick;
- opposite-polarity active-neutral routing accepted during a balance tick;
- retained pending polarity completed on a later commit tick.

`7/1` qualification result:

`PASS`

## 1/7 Mode Qualification

For:

`scheduler_mode_q = FRP_MODE_1_7`

the scheduler uses an eight-tick period.

Period relation:

`period_index_q = tick_index_q mod 8`

Scheduler-state decode:

| Period index | Scheduler state |
|---:|---|
| `0` | `FRP_SCHED_EXCITE` |
| `1` | `FRP_SCHED_NEUTRALIZE` |
| `2` | `FRP_SCHED_NEUTRALIZE` |
| `3` | `FRP_SCHED_NEUTRALIZE` |
| `4` | `FRP_SCHED_NEUTRALIZE` |
| `5` | `FRP_SCHED_NEUTRALIZE` |
| `6` | `FRP_SCHED_NEUTRALIZE` |
| `7` | `FRP_SCHED_NEUTRALIZE` |

Qualified `1/7` profile:

| Field | Recorded value |
|---|---:|
| enabled ticks | `16` |
| `scheduler_count_excite_q` | `2` |
| `scheduler_count_neutralize_q` | `14` |
| `scheduler_count_free_q` | `0` |
| `scheduler_count_balance_q` | `0` |
| `scheduler_count_commit_q` | `0` |

For a run starting at period index `0`:

`excite_count = floor((ticks_recorded_q + 7) / 8)`

`neutralize_count = ticks_recorded_q - excite_count`

Validated relation:

`16 ticks → excite = 2, neutralize = 14`

The qualified testbench records:

- zero-to-nonzero release accepted during an excite tick;
- opposite-polarity active-neutral routing accepted during a neutralize tick;
- retained pending polarity completed on a later excite tick.

`1/7` qualification result:

`PASS`

## Scheduler Transition Eligibility

Scheduler transition eligibility is defined by:

`frp_scheduler_allows_transition`

The scheduler first validates:

`frp_scheduler_state_is_valid(scheduler_state)`

Transition eligibility:

| Transition class | Eligible scheduler states |
|---|---|
| `FRP_TRANS_SAME_STATE` | all valid scheduler states |
| `FRP_TRANS_HOLD` | all valid scheduler states |
| `FRP_TRANS_ZERO_TO_NONZERO` | `free`, `commit`, `excite` |
| `FRP_TRANS_PENDING_COMPLETION` | `free`, `commit`, `excite` |
| `FRP_TRANS_NONZERO_TO_ZERO` | `free`, `balance`, `neutralize` |
| `FRP_TRANS_OPPOSITE_POLARITY` | `free`, `balance`, `neutralize` |
| reserved, rejected, or invalid transition class | none |

Commit-capable helper:

`frp_scheduler_is_commit_capable`

Commit-capable states:

`{FRP_SCHED_FREE, FRP_SCHED_COMMIT, FRP_SCHED_EXCITE}`

Neutralize-capable helper:

`frp_scheduler_is_neutralize_capable`

Neutralize-capable states:

`{FRP_SCHED_FREE, FRP_SCHED_BALANCE, FRP_SCHED_NEUTRALIZE}`

Scheduler transition-eligibility result:

`PASS`

## Free-State Semantics

`FRP_SCHED_FREE` is both:

- commit-capable;
- neutralize-capable.

Eligible transition classes include:

- same-state retention;
- hold;
- zero-to-nonzero release;
- nonzero-to-zero neutralization;
- opposite-polarity active-neutral first leg;
- pending-route completion.

The transition-capacity boundary remains:

`accepted_changes <= REQUEST_LANES`

Free-state execution result:

`PASS`

## Balance-State Semantics

`FRP_SCHED_BALANCE` is neutralize-capable.

Eligible transition classes include:

- same-state retention;
- hold;
- nonzero-to-zero neutralization;
- opposite-polarity active-neutral first leg.

The balance state does not admit:

- zero-to-nonzero release;
- pending-route completion.

Retained pending polarity remains stored until a commit-capable scheduler state.

Required direct-transition relation:

`actual_direct_events = 0`

Balance-state execution result:

`PASS`

## Commit-State Semantics

`FRP_SCHED_COMMIT` is commit-capable.

Eligible transition classes include:

- same-state retention;
- hold;
- zero-to-nonzero release;
- pending-route completion.

The commit state does not admit:

- nonzero-to-zero neutralization;
- opposite-polarity active-neutral first leg.

The transition-capacity boundary remains:

`accepted_changes <= REQUEST_LANES`

Commit-state execution result:

`PASS`

## Excite-State Semantics

`FRP_SCHED_EXCITE` is commit-capable.

Eligible transition classes include:

- same-state retention;
- hold;
- zero-to-nonzero release;
- pending-route completion.

The excite state does not admit:

- nonzero-to-zero neutralization;
- opposite-polarity active-neutral first leg.

The transition-capacity boundary remains:

`accepted_changes <= REQUEST_LANES`

Excite-state execution result:

`PASS`

## Neutralize-State Semantics

`FRP_SCHED_NEUTRALIZE` is neutralize-capable.

Eligible transition classes include:

- same-state retention;
- hold;
- nonzero-to-zero neutralization;
- opposite-polarity active-neutral first leg.

The neutralize state does not admit:

- zero-to-nonzero release;
- pending-route completion.

Required direct-transition relation:

`actual_direct_events = 0`

Neutralize-state execution result:

`PASS`

## Scheduler Count Relations

The scheduler exposes:

| Counter | Meaning |
|---|---|
| `ticks_recorded_q` | enabled scheduler ticks |
| `scheduler_count_free_q` | enabled free-state ticks |
| `scheduler_count_balance_q` | enabled balance-state ticks |
| `scheduler_count_commit_q` | enabled commit-state ticks |
| `scheduler_count_excite_q` | enabled excite-state ticks |
| `scheduler_count_neutralize_q` | enabled neutralize-state ticks |

Scheduler counter sum:

`scheduler_count_sum = scheduler_count_free_q + scheduler_count_balance_q + scheduler_count_commit_q + scheduler_count_excite_q + scheduler_count_neutralize_q`

Required global relation:

`scheduler_count_sum = ticks_recorded_q`

Required validity signal:

`scheduler_counts_valid = 1`

Scheduler-count qualification result:

`PASS`

## Mode-Switch Boundary

The selected scheduler mode is registered at the clock boundary.

A valid selected mode becomes:

`scheduler_mode_q`

The next scheduler state is decoded from:

- the selected valid mode;
- the current or incremented period index.

Mode switching does not consume a processor tick when:

`tick_enable = 0`

Mode switching does not directly modify:

- retained balanced ternary processor state;
- retained pending-route state;
- request-lane ordering;
- transition-capacity state;
- architectural event telemetry.

The current enabled tick uses:

`scheduler_state_q`

The newly decoded scheduler state becomes available after the register update.

Mode-switch qualification result:

`PASS`

## Scheduler Reserved-State Guard

Registered mode validation:

`scheduler_mode_reserved = !frp_is_valid_scheduler_mode(scheduler_mode_q)`

Registered state validation:

`scheduler_state_reserved = !frp_scheduler_state_is_valid(scheduler_state_q)`

Scheduler validity relation:

`scheduler_valid = !scheduler_mode_reserved && !scheduler_state_reserved && (period_index_q == tick_index_q[2:0]) && (!tick_enable || $countones(scheduler_enable_vector) == 1)`

Required qualified values:

`scheduler_mode_reserved = 0`

`scheduler_state_reserved = 0`

`scheduler_valid = 1`

Scheduler reserved-state guard result:

`PASS`

## Interaction With Request-Lane Arbitration

The scheduler supplies temporal eligibility to:

`frp_m16_request_lanes`

Request lanes remain ordered in deterministic ascending lane order.

Scheduler state may accept or reject a transition class.

Scheduler state does not change request-lane ordering.

Required request-lane invariant:

`FRP_INV_REQUEST_LANE_ORDER_VALID = 1`

Scheduler-to-request-lane qualification result:

`PASS`

## Interaction With Pending Routes

Pending-route completion requires a commit-capable scheduler state:

`FRP_SCHED_FREE`

`FRP_SCHED_COMMIT`

or:

`FRP_SCHED_EXCITE`

A scheduler-ineligible pending route remains retained.

Scheduler gating does not change retained pending polarity.

Required pending-route invariant:

`FRP_INV_PENDING_POLARITY_VALID = 1`

Scheduler-to-pending-route qualification result:

`PASS`

## Interaction With Active Neutral Routing

An opposite-polarity first route leg requires a neutralize-capable scheduler state:

`FRP_SCHED_FREE`

`FRP_SCHED_BALANCE`

or:

`FRP_SCHED_NEUTRALIZE`

Forbidden direct retained-state transitions:

`-1 → 1`

`1 → -1`

Required routed retained-state transitions:

`-1 → 0 → 1`

`1 → 0 → -1`

Required direct-transition counter:

`actual_direct_events = 0`

Required active-neutral invariant:

`FRP_INV_ACTIVE_NEUTRAL_VALID = 1`

Scheduler-to-active-neutral qualification result:

`PASS`

## Interaction With Transition Capacity

Scheduler eligibility is evaluated before final transition-capacity admission.

An eligible transition may execute only when admitted by:

`frp_m16_capacity_guard`

Required capacity relation:

`accepted_changes <= REQUEST_LANES`

Required capacity invariant:

`FRP_INV_TRANSITION_CAPACITY_VALID = 1`

Scheduler-to-capacity qualification result:

`PASS`

## Assertion Support

Assertion module:

`rtl/m16/frp_m16_assertions.sv`

The assertion boundary validates:

- registered scheduler-mode validity;
- registered scheduler-state validity;
- scheduler counter-sum equality;
- `free` mode emits only `FRP_SCHED_FREE`;
- `7/1` mode emits only `FRP_SCHED_BALANCE` or `FRP_SCHED_COMMIT`;
- `1/7` mode emits only `FRP_SCHED_EXCITE` or `FRP_SCHED_NEUTRALIZE`;
- scheduler counters remain stable without tick or clear;
- counter clear with no tick produces zero scheduler counters;
- counter clear with an enabled tick records exactly one scheduler event;
- scheduler-state counter consistency;
- integrated scheduler invariant flag.

Required integrated invariant:

`FRP_INV_SCHEDULER_COUNTS_VALID = 1`

Assertion execution result:

`PASS`

## Deterministic Testbench Boundary

Executable testbench:

`rtl/m16/frp_m16_tb.sv`

The testbench validates:

- reset to `FRP_MODE_FREE` and `FRP_SCHED_FREE`;
- exact 16-tick free profile;
- counter clearing without retained-state reset;
- exact 64-tick `7/1` profile;
- balance-state zero-release rejection;
- commit-state zero-release acceptance;
- balance-state active-neutral routing;
- commit-state pending-route completion;
- exact 16-tick `1/7` profile;
- excite-state zero-release acceptance;
- neutralize-state active-neutral routing;
- excite-state pending-route completion;
- scheduler counters sum to recorded ticks;
- zero actual direct-transition events;
- zero reserved-state events;
- zero queue-overflow events;
- all ten integrated invariant flags.

Testbench scheduler result:

`PASS`

## M15 Comparison Boundary

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

M15-to-M16 scheduler comparison inputs:

- `scheduler_mode`;
- `tick_enable`;
- `clear_counters`;
- reset state.

M15-to-M16 scheduler comparison outputs:

- `scheduler_mode_q`;
- `scheduler_state_q`;
- `tick_index_q`;
- `period_index_q`;
- `ticks_recorded_q`;
- all five scheduler-state counters;
- scheduler execution enables;
- `scheduler_valid`;
- `scheduler_counts_valid`.

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

M15 scheduler comparison-boundary result:

`PASS`

## FPGA Scheduler Propagation

Target-independent FPGA integration top:

`fpga/m16/frp_m16_fpga_top.sv`

The integration top passes:

`scheduler_mode`

to:

`frp_m16_core`

The integration top gates scheduler execution through:

`tick_enable_core = tick_enable && core_ready`

Before:

`core_ready = 1`

no enabled processor tick reaches the M16 scheduler.

Qualified FPGA terminal record:

| Field | Recorded value |
|---|---:|
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `invariant_flags` | `1111111111` |

FPGA preparation workflow:

`FRP M16 FPGA Preparation`

Current FPGA preparation record:

| Field | Recorded value |
|---|---|
| Workflow run | `#2` |
| Qualified repository commit | `ede53cf` |
| Branch | `main` |
| Workflow result | `SUCCESS` |
| Workflow duration | `36s` |
| Qualification artifact count | `1` |
| Qualification result | `PASS` |
| Closure status | `M16 FPGA PREPARATION LAYER CLOSED` |

FPGA scheduler-propagation result:

`PASS`

## Required M16 Scheduler Invariants

The qualified M16 scheduler records:

`free` mode emits only `FRP_SCHED_FREE`.

`7/1` mode emits seven balance ticks followed by one commit tick.

`1/7` mode emits one excite tick followed by seven neutralize ticks.

`period_index_q = tick_index_q mod 8`.

Scheduler-state counters sum to `ticks_recorded_q`.

Invalid scheduler modes are exposed through `scheduler_mode_reserved`.

Invalid scheduler states are exposed through `scheduler_state_reserved`.

Exactly one scheduler execution enable is active for each valid enabled tick.

All scheduler execution enables are zero when `tick_enable = 0`.

Counter clear preserves scheduler position and retained execution state.

Request-lane order remains deterministic.

Scheduler-ineligible pending routes retain their polarity.

Opposite-polarity transitions remain routed through active neutral state `0`.

`actual_direct_events = 0`.

`reserved_state_events = 0`.

`queue_overflow_events = 0`.

`FRP_INV_SCHEDULER_COUNTS_VALID = 1`.

## Scheduler Qualification Result

| Scheduler boundary | Result |
|---|---|
| scheduler mode encoding | `PASS` |
| scheduler state encoding | `PASS` |
| scheduler register reset | `PASS` |
| scheduler mode capture | `PASS` |
| tick-enable behavior | `PASS` |
| counter-clear behavior | `PASS` |
| scheduler-state decode | `PASS` |
| scheduler execution enables | `PASS` |
| free-mode profile | `PASS` |
| `7/1` profile | `PASS` |
| `1/7` profile | `PASS` |
| transition-class eligibility | `PASS` |
| scheduler counter relations | `PASS` |
| mode-switch boundary | `PASS` |
| reserved-state guard | `PASS` |
| request-lane interaction | `PASS` |
| pending-route interaction | `PASS` |
| active-neutral interaction | `PASS` |
| transition-capacity interaction | `PASS` |
| assertion execution | `PASS` |
| deterministic testbench | `PASS` |
| M15 comparison boundary | `PASS` |
| FPGA scheduler propagation | `PASS` |
| M16 scheduler-state RTL realization | `PASS` |

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

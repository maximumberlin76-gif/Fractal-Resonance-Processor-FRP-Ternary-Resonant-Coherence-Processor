# FRP M16 RTL Core Interface Contract

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the first concrete RTL-facing interface contract for the M16 core realization layer.

M16 does not introduce a new semantic processor model.

M16 realizes the M15-qualified execution contract in an explicit RTL core interface.

The interface must preserve:

- balanced ternary retained-state semantics;
- canonical two-bit ternary encoding;
- explicit `free`, `7/1`, and `1/7` temporal execution modes;
- deterministic request-lane ordering;
- transition-capacity enforcement;
- pending neutral-route semantics;
- mandatory active-neutral routing through state `0`;
- M15-compatible event counters;
- M15-compatible invariant flags;
- deterministic comparison against M15 cycle-exact integer golden traces.

## Core Identity

The M16 RTL core realizes the execution semantics of the:

`Ternary Fractal Resonant Coherence Processor`

The computational chain preserved by the interface is:

`phase-derived ternary target`

→ `request-lane evaluation`

→ `transition-capacity boundary`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

The RTL core interface does not replace the upstream resonant computation layer.

The upstream M15 quantized reference remains responsible for:

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

The M16 core consumes the ternary target and retained execution state and realizes the deterministic retained-state transition semantics.

## Canonical Ternary Encoding

The canonical RTL encoding is:

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The reserved encoding is invalid.

Required invariant:

`reserved_state_events = 0`

## Parameter Set

The initial M16 core interface is parameterized by:

| Parameter | Meaning |
|---|---|
| `CELLS` | number of processor cells |
| `STATE_BITS` | ternary state encoding width per cell |
| `REQUEST_LANES` | maximum accepted state-change lanes per tick |
| `SCHEDULER_BITS` | scheduler-state encoding width |
| `COUNTER_BITS` | event-counter width |

Required relation:

`STATE_BITS = 2`

Required transition relation:

`REQUEST_LANES = max(1, round(CELLS × transition_fraction))`

Inherited default:

`transition_fraction = 0.25`

Validated inherited profiles:

| Cells | Request lanes | Packed state width |
|---|---:|---:|
| `8` | `2` | `16 bits` |
| `16` | `4` | `32 bits` |
| `32` | `8` | `64 bits` |

Packed state width:

`PACKED_STATE_BITS = CELLS × STATE_BITS`

## Clock and Reset Interface

The M16 RTL core uses a synchronous tick interface.

Required control signals:

| Signal | Direction | Meaning |
|---|---|---|
| `clk` | input | processor clock |
| `rst_n` | input | active-low reset |
| `tick_enable` | input | enables one processor tick |
| `clear_counters` | input | clears event counters without changing retained state |

Reset behavior:

- retained ternary state initializes to `0`;
- pending-route state initializes to `0`;
- counters initialize to `0`;
- invariant flags initialize to valid non-error state;
- no reserved ternary encoding is emitted after reset.

Required reset invariant:

`all retained states = 0`

`all pending routes = 0`

`reserved_state_events = 0`

## Scheduler Mode Interface

M16 preserves three explicit scheduler modes:

- `free`;
- `7/1`;
- `1/7`.

Scheduler input signal:

| Signal | Direction | Meaning |
|---|---|---|
| `scheduler_mode` | input | selected temporal execution mode |

Scheduler output signals:

| Signal | Direction | Meaning |
|---|---|---|
| `scheduler_state` | output | current tick scheduler state |
| `scheduler_count_free` | output | free tick counter |
| `scheduler_count_balance` | output | balance tick counter |
| `scheduler_count_commit` | output | commit tick counter |
| `scheduler_count_excite` | output | excite tick counter |
| `scheduler_count_neutralize` | output | neutralize tick counter |

Required scheduler relations:

For `free`:

`scheduler_state = free`

For `7/1`:

`scheduler_state = commit`, when `(tick_index + 1) mod 8 = 0`

`scheduler_state = balance`, otherwise.

For `1/7`:

`scheduler_state = excite`, when `tick_index mod 8 = 0`

`scheduler_state = neutralize`, otherwise.

Required invariant:

`sum(scheduler_counts) = ticks_recorded`

## Retained State Interface

Input retained state:

| Signal | Direction | Meaning |
|---|---|---|
| `state_in` | input | packed retained ternary state at tick start |

Output retained state:

| Signal | Direction | Meaning |
|---|---|---|
| `state_out` | output | packed retained ternary state after tick execution |

State packing relation:

`state[cell] = state_vector[(2 × cell) +: 2]`

Valid state encodings:

`2'b11`

`2'b00`

`2'b01`

Invalid state encoding:

`2'b10`

Required invariant:

`state_out` must never contain `2'b10`.

## Target State Interface

Input target state:

| Signal | Direction | Meaning |
|---|---|---|
| `target_in` | input | packed phase-derived ternary target state |

The target is generated upstream by the resonant computation layer.

M16 does not redefine the target-generation rule.

Inherited M15 target rule:

`target_i = 1`, when `sin(phase_i) > 0.33`

`target_i = -1`, when `sin(phase_i) < -0.33`

`target_i = 0`, otherwise.

The M16 interface treats `target_in` as the deterministic input target vector for the tick.

## Pending Route Interface

Input pending-route state:

| Signal | Direction | Meaning |
|---|---|---|
| `pending_route_in` | input | packed pending route at tick start |

Output pending-route state:

| Signal | Direction | Meaning |
|---|---|---|
| `pending_route_out` | output | packed pending route after tick execution |

Pending-route encoding uses the same ternary encoding as retained state.

Meaning:

- `0` means no pending opposite-polarity target;
- `-1` means target `-1` is retained for later completion;
- `+1` means target `+1` is retained for later completion.

Required pending-route invariant:

`pending routes preserve requested target polarity`

## Request-Lane Interface

Request-lane inputs:

| Signal | Direction | Meaning |
|---|---|---|
| `request_valid[REQUEST_LANES-1:0]` | input | request lane valid flags |
| `request_cell_index[REQUEST_LANES]` | input | requested cell index per lane |
| `request_target[REQUEST_LANES]` | input | requested ternary target per lane |

Request-lane outputs:

| Signal | Direction | Meaning |
|---|---|---|
| `request_accept[REQUEST_LANES-1:0]` | output | accepted request flags |
| `request_neutralized[REQUEST_LANES-1:0]` | output | opposite-polarity request routed through `0` |
| `request_rejected[REQUEST_LANES-1:0]` | output | request rejected by boundary or invalidity |

Request lanes are processed in deterministic ascending lane order.

Required relation:

`accepted_changes <= REQUEST_LANES`

## Transition Semantics

If:

`state_i = target_i`

then:

`state_out_i = state_i`

No change is counted.

If:

`state_i = 0`

and:

`target_i = -1 or +1`

then the eligible transition is:

`0 → target_i`

If:

`state_i = -1`

and:

`target_i = 0`

then:

`-1 → 0`

If:

`state_i = +1`

and:

`target_i = 0`

then:

`+1 → 0`

If:

`state_i = -1`

and:

`target_i = +1`

then direct transition is forbidden.

The tick must execute:

`-1 → 0`

and retain:

`pending_route_i = +1`

If:

`state_i = +1`

and:

`target_i = -1`

then direct transition is forbidden.

The tick must execute:

`+1 → 0`

and retain:

`pending_route_i = -1`

Required invariant:

`actual_direct_events = 0`

## Pending Route Completion

If:

`state_i = 0`

and:

`pending_route_i = -1 or +1`

then a later eligible tick may execute:

`0 → pending_route_i`

and clear:

`pending_route_i = 0`

Completion is subject to:

- scheduler eligibility;
- transition-capacity boundary;
- deterministic lane order.

Required final qualification target:

`pending_route_count_final = 0`

## Event Counter Interface

M16 exposes M15-compatible event counters.

Required counters:

| Counter | Meaning |
|---|---|
| `ticks_recorded` | executed tick count |
| `requested_direct_events` | requested direct opposite-polarity events |
| `prevented_direct_events` | direct opposite-polarity requests prevented |
| `neutral_routed_events` | requests routed through active neutral `0` |
| `actual_direct_events` | actual direct opposite-polarity executions |
| `reserved_state_events` | invalid reserved-state observations |
| `queue_overflow_events` | pending-route capacity failures |
| `accepted_change_events` | accepted retained-state changes |

Required relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`prevented_direct_events >= requested_direct_events`

`neutral_routed_events >= prevented_direct_events`

## Invariant Flag Interface

M16 exposes invariant flags for RTL assertion correlation.

Required flags:

| Flag | Required value |
|---|---|
| `valid_state_domain` | `True` |
| `no_reserved_state` | `True` |
| `no_actual_direct_events` | `True` |
| `no_queue_overflow` | `True` |
| `transition_capacity_valid` | `True` |
| `pending_route_polarity_valid` | `True` |
| `scheduler_counts_valid` | `True` |

These flags must correlate with the assertion harness and M15 vector replay expectations.

## RTL Comparison Boundary

The M16 core must compare against the M15 vector package at the following boundary:

`state_in`

`target_in`

`pending_route_in`

`scheduler_mode`

`tick_index`

`request lanes`

→ `M16 RTL tick execution`

→ `state_out`

`pending_route_out`

`event counters`

`invariant flags`

The expected output source is the M15 cycle-exact integer golden trace.

## M16 Interface Closure Criteria

The M16 interface contract is valid only if it preserves:

- canonical ternary encoding;
- zero reserved states;
- explicit scheduler execution semantics;
- deterministic request-lane order;
- transition-capacity boundary;
- mandatory active-neutral routing;
- pending-route retention;
- zero direct opposite-polarity execution;
- M15-compatible event counters;
- M15-compatible invariant flags;
- replay compatibility with M15 vector packages.

## Next Step

The next M16 file should define the first module-level design document:

`docs/m16_balanced_ternary_state_register_map.md`

# FRP M16 RTL Core Realization and Execution Semantics Package

## Status

Planned architecture layer.

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## M16 Position

M16 begins after the completed M15 qualification boundary.

M15 established:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

M16 moves from reference-core mapping into explicit RTL core realization and execution semantics.

The M16 layer must preserve the qualified M15 processor semantics without changing the computational identity of FRP.

## Processor Identity Preserved by M16

FRP remains a:

`Ternary Fractal Resonant Coherence Processor`

The computational core remains:

`Kuramoto-Sakaguchi resonant phase dynamics`

→ `hierarchical fractal coupling`

→ `multiscale phase coherence`

→ `stateful delay dynamics`

→ `distributed local thermal fields`

→ `local correlated gamma drift`

→ `nonlinear coherence compression`

→ `dynamic stability C(t) - P(t)`

→ `phase-derived ternary target`

→ `distributed ternary commit`

→ `mandatory tick-separated routing through active neutral state 0`

→ `retained coherent ternary state`

M16 does not replace this architecture with a conventional ternary finite-state machine.

M16 realizes the already-qualified execution semantics in an explicit RTL-oriented core structure.

## M16 Scope

M16 defines the RTL realization boundary for:

- retained balanced ternary state registers;
- canonical two-bit ternary encoding;
- scheduler execution modes;
- request-lane evaluation;
- transition-capacity enforcement;
- pending neutral routes;
- active-neutral routing;
- phase-word registers;
- frequency-state registers;
- fixed-point coupling inputs;
- thermal-state registers;
- gamma-state registers;
- coherence and stability telemetry registers;
- deterministic tick execution;
- RTL comparison boundary.

## Explicit Execution Modes

M16 preserves the three temporal execution modes:

- `free`;
- `7/1`;
- `1/7`.

These are processor execution semantics.

They are not external benchmark labels.

### Free Mode

`free`

Every tick is commit-capable.

Validated profile inherited from M15:

`16 ticks → free = 16`

### 7/1 Mode

`7/1`

Seven balance ticks followed by one commit tick.

Validated profile inherited from M15:

`64 ticks → balance = 56, commit = 8`

### 1/7 Mode

`1/7`

One excite tick followed by seven neutralize ticks.

Validated profile inherited from M15:

`16 ticks → excite = 2, neutralize = 14`

## Balanced Ternary Encoding

M16 preserves the canonical M15 hardware encoding:

| Ternary state | RTL encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The reserved state is invalid.

Required invariant:

`reserved_state_events = 0`

## Active Neutral Routing

Opposite-polarity transitions must pass through the active neutral state `0`.

Validated routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct routes are forbidden:

`-1 → 1`

`1 → -1`

Required invariant:

`actual_direct_events = 0`

## Pending Route Semantics

For an opposite-polarity request:

`state_i × target_i = -1`

M16 must execute:

`state_i → 0`

and retain:

`pending_route_i = target_i`

The retained pending route may only be completed on a later eligible tick:

`0 → target_i`

The pending-route mechanism must preserve:

- requested target polarity;
- tick separation;
- deterministic continuation;
- zero direct opposite-polarity events.

## Transition Capacity

M16 preserves the M15 transition boundary:

`transition_fraction = 0.25`

The maximum accepted state changes per tick are:

`max_changes = max(1, round(cells × transition_fraction))`

The hardware-facing request-lane relation is:

`REQUEST_LANES = max_changes`

Validated inherited configurations:

| Cells | Request lanes |
|---|---:|
| `8` | `2` |
| `16` | `4` |
| `32` | `8` |

Required invariant:

`accepted_changes <= REQUEST_LANES`

Equivalent switching relation:

`switch_load = accepted_changes / cells`

Required bound:

`switch_load_peak <= transition_fraction`

## RTL Core Realization Boundary

The M16 RTL core should expose a deterministic tick interface:

- clock;
- reset;
- scheduler mode;
- current retained ternary state;
- phase-derived target state;
- request-lane inputs;
- pending-route inputs;
- retained-state outputs;
- pending-route outputs;
- event counters;
- invariant flags;
- telemetry outputs.

The M16 core must support deterministic comparison against the M15 cycle-exact integer golden trace.

## Required M16 Invariants

M16 must preserve the following inherited M15 invariants:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`accepted_changes <= REQUEST_LANES`

`switch_load_peak <= transition_fraction`

`pending routes preserve target polarity`

`opposite-polarity transitions pass through 0`

`scheduler counts match ticks_recorded`

`state sequence matches M15 quantized reference`

`neutral route sequence matches M15 quantized reference`

## M16 Qualification Direction

M16 qualification should compare the RTL core realization against:

- M15 quantized hardware shadow;
- M15 cycle-exact integer golden trace;
- M15 deterministic RTL comparison vector package;
- M15 SystemVerilog testbench interface map;
- M15 assertion correlation harness;
- M15 reference RTL equivalence report.

M16 should not create a new semantic processor model.

M16 should realize the M15-qualified execution contract in RTL core form.

## M16 Expected Artifacts

Expected M16 artifact layers:

1. RTL core execution-semantics specification;
2. balanced ternary state-register map;
3. scheduler-state RTL realization;
4. request-lane arbitration module;
5. pending-route register module;
6. active-neutral transition module;
7. transition-capacity guard module;
8. retained-state update module;
9. invariant assertion set;
10. M15 vector replay compatibility report;
11. M16 qualification manifest.

## M16 Closure Gate

M16 can be considered qualified only if:

- RTL execution semantics preserve M15 state order;
- scheduler sequences match M15 references;
- pending-route sequences match M15 references;
- opposite-polarity transitions remain tick-separated;
- direct opposite-polarity events remain zero;
- reserved states remain zero;
- request-lane capacity is never exceeded;
- M15 comparison vectors remain replay-compatible;
- all M16 invariants pass.

## Next Step

After this document is committed, the next file should define the first concrete M16 interface layer:

`docs/m16_rtl_core_interface_contract.md`

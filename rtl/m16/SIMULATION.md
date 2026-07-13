# FRP M16 RTL Simulation

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Processor

`FRP — Ternary Fractal Resonant Coherence Processor`

## Simulation Entry Point

Simulation source:

`rtl/m16/frp_m16_tb.sv`

Top-level simulation module:

`frp_m16_tb`

SystemVerilog include path:

`rtl/m16`

The testbench includes:

- `frp_m16_pkg.sv`
- `frp_m16_core.sv`
- `frp_m16_assertions.sv`

The integrated core includes:

- `frp_m16_scheduler.sv`
- `frp_m16_request_lanes.sv`
- `frp_m16_pending_routes.sv`
- `frp_m16_active_neutral.sv`
- `frp_m16_capacity_guard.sv`
- `frp_m16_state_update.sv`

## Simulation Toolchain

The M16 RTL simulation uses:

- Verilator
- SystemVerilog mode
- timing execution
- assertion execution
- generated executable testbench

Commands are executed from the repository root.

Verilator version:

`verilator --version`

C++ compiler version:

`g++ --version`

## Simulation Paths

Build directory:

`/tmp/frp_m16_obj`

Build log:

`/tmp/frp_m16_build.log`

Execution log:

`/tmp/frp_m16_execution.log`

Remove the previous build directory:

`rm -rf /tmp/frp_m16_obj`

Remove the previous build log:

`rm -f /tmp/frp_m16_build.log`

Remove the previous execution log:

`rm -f /tmp/frp_m16_execution.log`

Create the build directory:

`mkdir -p /tmp/frp_m16_obj`

## Build Command

Build the integrated M16 RTL testbench:

`verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log`

Generated executable:

`/tmp/frp_m16_obj/Vfrp_m16_tb`

Check the executable:

`test -x /tmp/frp_m16_obj/Vfrp_m16_tb`

## Execution Command

Run the integrated M16 RTL testbench:

`/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log`

## Complete Command Sequence

1. `rm -rf /tmp/frp_m16_obj`
2. `rm -f /tmp/frp_m16_build.log`
3. `rm -f /tmp/frp_m16_execution.log`
4. `mkdir -p /tmp/frp_m16_obj`
5. `verilator --sv --timing --assert --binary --top-module frp_m16_tb -Irtl/m16 --Mdir /tmp/frp_m16_obj rtl/m16/frp_m16_tb.sv 2>&1 | tee /tmp/frp_m16_build.log`
6. `test -x /tmp/frp_m16_obj/Vfrp_m16_tb`
7. `/tmp/frp_m16_obj/Vfrp_m16_tb 2>&1 | tee /tmp/frp_m16_execution.log`

## Testbench Configuration

The executable testbench uses:

| Parameter | Value |
|---|---:|
| `CELLS` | `8` |
| `STATE_BITS` | `2` |
| `REQUEST_LANES` | `2` |
| `COUNTER_BITS` | `32` |

Transition-capacity relation:

`REQUEST_LANES = max(1, round(CELLS × 0.25))`

For eight retained cells:

`REQUEST_LANES = 2`

## Balanced Ternary Encoding

| Ternary state | Encoding |
|---|---|
| `-1` | `2'b11` |
| `0` | `2'b00` |
| `+1` | `2'b01` |
| reserved | `2'b10` |

The state `0` is the active neutral processor state.

Reset establishes:

- every retained processor cell at `0`
- every pending-route slot at `0`
- scheduler mode `free`
- scheduler state `free`
- scheduler counters at `0`

## Clock

The testbench clock toggles every five time units.

Clock period:

`10 ns`

Request values are prepared at the negative clock edge.

Retained state and pending-route registers update at the positive clock edge.

Updated values are checked after the following negative clock edge.

## Reset Sequence

For each scheduler mode, the testbench:

1. disables tick execution
2. disables scheduler-counter clearing
3. clears all request lanes
4. selects the scheduler mode
5. drives `rst_n = 0`
6. holds reset for three negative clock edges
7. drives `rst_n = 1`
8. waits two negative clock edges
9. checks retained state
10. checks pending-route state
11. checks scheduler counters

Reset relations:

`state_out = 0`

`pending_route_out = 0`

`ticks_recorded_q = 0`

## Free Mode

The free-mode sequence executes:

`16 enabled ticks`

Scheduler count relation:

| Scheduler state | Count |
|---|---:|
| `free` | `16` |
| `balance` | `0` |
| `commit` | `0` |
| `excite` | `0` |
| `neutralize` | `0` |

The `free` scheduler state is commit-capable and neutralize-capable.

It executes:

- same-state retention
- `0 → -1`
- `0 → +1`
- `-1 → 0`
- `+1 → 0`
- opposite-polarity first-leg routing
- pending-route completion

### Free Tick 0

Request:

`cell 0: 0 → +1`

Result:

`state[0] = +1`

`pending_route[0] = 0`

### Free Tick 1

Request:

`cell 0: +1 → -1`

The first active-neutral route leg executes:

`+1 → 0`

The requested opposite polarity is retained:

`pending_route[0] = -1`

Result:

`state[0] = 0`

`pending_route[0] = -1`

`requested_direct_events = 1`

`prevented_direct_events = 1`

`neutral_routed_events = 1`

`actual_direct_events = 0`

### Free Tick 2

The pending route completes:

`0 → -1`

Result:

`state[0] = -1`

`pending_route[0] = 0`

Completed route:

`+1 → 0 → -1`

### Free Tick 3

Request:

`cell 0: -1 → +1`

The first active-neutral route leg executes:

`-1 → 0`

The requested opposite polarity is retained:

`pending_route[0] = +1`

Result:

`state[0] = 0`

`pending_route[0] = +1`

`requested_direct_events = 1`

`prevented_direct_events = 1`

`neutral_routed_events = 1`

`actual_direct_events = 0`

### Free Tick 4

The pending route completes:

`0 → +1`

Result:

`state[0] = +1`

`pending_route[0] = 0`

Completed route:

`-1 → 0 → +1`

### Free Tick 5

Two state-changing requests execute during the same tick:

`cell 1: 0 → +1`

`cell 2: 0 → +1`

Capacity relation:

`accepted_changes = 2`

`capacity_remaining = 0`

`capacity_exhausted = 1`

`switch_load_numerator = 2`

## Scheduler Counter Clear

The counter-clear sequence uses:

`clear_counters = 1`

`tick_enable = 0`

The operation clears:

- `ticks_recorded_q`
- `scheduler_count_free_q`
- `scheduler_count_balance_q`
- `scheduler_count_commit_q`
- `scheduler_count_excite_q`
- `scheduler_count_neutralize_q`

The operation preserves:

- retained balanced ternary state
- retained pending-route state

## 7/1 Mode

The `7/1` sequence executes:

`64 enabled ticks`

The repeating eight-tick scheduler sequence is:

| Period index | Scheduler state |
|---:|---|
| `0` | `balance` |
| `1` | `balance` |
| `2` | `balance` |
| `3` | `balance` |
| `4` | `balance` |
| `5` | `balance` |
| `6` | `balance` |
| `7` | `commit` |

Scheduler count relation:

| Scheduler state | Count |
|---|---:|
| `free` | `0` |
| `balance` | `56` |
| `commit` | `8` |
| `excite` | `0` |
| `neutralize` | `0` |

### Ticks 0–6

Request:

`cell 0: 0 → +1`

The balance ticks retain:

`state[0] = 0`

`pending_route[0] = 0`

### Tick 7

Scheduler state:

`commit`

Executed transition:

`0 → +1`

Result:

`state[0] = +1`

`pending_route[0] = 0`

### Tick 8

Scheduler state:

`balance`

Request:

`cell 0: +1 → -1`

The first active-neutral route leg executes:

`+1 → 0`

Result:

`state[0] = 0`

`pending_route[0] = -1`

### Ticks 9–14

Scheduler state:

`balance`

The pending route remains retained:

`state[0] = 0`

`pending_route[0] = -1`

The balance ticks do not execute:

`0 → pending_route`

### Tick 15

Scheduler state:

`commit`

The retained pending route completes:

`0 → -1`

Result:

`state[0] = -1`

`pending_route[0] = 0`

The complete route is:

`+1 → 0 → -1`

The first leg executes during a balance tick.

The completion leg executes during the following commit tick.

## 1/7 Mode

The `1/7` sequence executes:

`16 enabled ticks`

The repeating eight-tick scheduler sequence is:

| Period index | Scheduler state |
|---:|---|
| `0` | `excite` |
| `1` | `neutralize` |
| `2` | `neutralize` |
| `3` | `neutralize` |
| `4` | `neutralize` |
| `5` | `neutralize` |
| `6` | `neutralize` |
| `7` | `neutralize` |

Scheduler count relation:

| Scheduler state | Count |
|---|---:|
| `free` | `0` |
| `balance` | `0` |
| `commit` | `0` |
| `excite` | `2` |
| `neutralize` | `14` |

### Tick 0

Scheduler state:

`excite`

Request:

`cell 0: 0 → +1`

Result:

`state[0] = +1`

`pending_route[0] = 0`

### Tick 1

Scheduler state:

`neutralize`

Request:

`cell 0: +1 → -1`

The first active-neutral route leg executes:

`+1 → 0`

Result:

`state[0] = 0`

`pending_route[0] = -1`

### Ticks 2–7

Scheduler state:

`neutralize`

The pending route remains retained:

`state[0] = 0`

`pending_route[0] = -1`

The neutralize ticks do not execute:

`0 → pending_route`

### Tick 8

Scheduler state:

`excite`

The retained pending route completes:

`0 → -1`

Result:

`state[0] = -1`

`pending_route[0] = 0`

The complete route is:

`+1 → 0 → -1`

The first leg executes during a neutralize tick.

The completion leg executes during the following excite tick.

## Assertion Execution

Assertion execution is enabled by:

`--assert`

The assertion layer checks:

- canonical retained-state encoding
- canonical pending-route encoding
- reset to active neutral state `0`
- retained-state stability while `tick_enable = 0`
- pending-route stability while `tick_enable = 0`
- state changes only through `accepted_change_mask`
- absence of direct opposite-polarity writeback
- opposite-polarity first-leg execution through `0`
- retention of the requested pending polarity
- pending-route stability during scheduler deferral
- pending-route stability during capacity deferral
- completion only from retained state `0`
- pending-route clearing after accepted completion
- scheduler-mode validity
- scheduler-state validity
- scheduler-counter relation
- request acceptance and rejection separation
- transition-capacity relation
- switch-load relation
- integrated invariant flags

## Terminal Output

The testbench prints:

`FRP M16 deterministic RTL testbench completed.`

`CELLS=8 REQUEST_LANES=2`

`ticks_recorded=16`

`actual_direct_events=0`

`reserved_state_events=0`

`queue_overflow_events=0`

The final value `ticks_recorded=16` belongs to the final `1/7` sequence.

## Result Validation

Completion marker:

`grep -Fqx "FRP M16 deterministic RTL testbench completed." /tmp/frp_m16_execution.log`

Parameter relation:

`grep -Fqx "CELLS=8 REQUEST_LANES=2" /tmp/frp_m16_execution.log`

Final tick count:

`grep -Fqx "ticks_recorded=16" /tmp/frp_m16_execution.log`

Direct-transition relation:

`grep -Fqx "actual_direct_events=0" /tmp/frp_m16_execution.log`

Reserved-state relation:

`grep -Fqx "reserved_state_events=0" /tmp/frp_m16_execution.log`

Pending-route overflow relation:

`grep -Fqx "queue_overflow_events=0" /tmp/frp_m16_execution.log`

## Execution Relations

The simulation verifies:

- `free = 16`
- `balance = 56`
- `commit = 8`
- `excite = 2`
- `neutralize = 14`
- `+1 → 0 → -1`
- `-1 → 0 → +1`
- pending polarity retention
- pending completion only from active neutral `0`
- deterministic request-lane order
- pending-route completion priority
- two-transition capacity for eight cells
- `accepted_changes <= REQUEST_LANES`
- `capacity_remaining = REQUEST_LANES - accepted_changes`
- `capacity_exhausted = (accepted_changes == REQUEST_LANES)`
- `switch_load_numerator = accepted_changes`
- `actual_direct_events = 0`
- `reserved_state_events = 0`
- `queue_overflow_events = 0`

## Simulation Output Files

Build directory:

`/tmp/frp_m16_obj`

Build log:

`/tmp/frp_m16_build.log`

Execution log:

`/tmp/frp_m16_execution.log`

The execution log is recorded in:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

## Author

Maksym Marnov

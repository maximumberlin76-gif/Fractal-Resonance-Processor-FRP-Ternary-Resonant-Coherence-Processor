# FRP M16 Artifact-Boundary Test Stability Policy

## Status

`ACTIVE`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the stability policy for M16 RTL artifact-boundary tests of the:

`Ternary Fractal Resonant Coherence Processor`

The policy separates:

- stable repository facts;
- stable architectural relations;
- stable simulation commands;
- stable completion markers;
- stable invariant terms;
- mutable workflow metadata;
- mutable qualification-history records.

The tests validate the current repository artifact and execution contract without depending on workflow run numbers, commit hashes, timestamps, durations, or temporary development-status phrases.

## Current Boundary

Primary RTL directory:

`rtl/m16/`

Primary artifact-manifest test:

`tests/test_m16_rtl_artifact_manifest.py`

Artifact-manifest pytest command:

    python -m pytest tests/test_m16_rtl_artifact_manifest.py -q

Artifact-manifest test-function count:

`21`

M16 RTL qualification workflow:

`FRP M16 RTL Artifact Boundary`

Workflow file:

`.github/workflows/frp-m16-rtl-artifact-boundary.yml`

Current RTL qualification result:

`PASS`

Current RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current external simulator result:

`PASS`

Current FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## Stability Rule

Artifact-boundary tests must validate durable repository and architectural facts.

Workflow run numbers, commit hashes, timestamps, durations, actors, and user-interface status text may be recorded in qualification documents.

Artifact-boundary tests must not require specific values for mutable qualification metadata.

## Allowed Stable Test Targets

Stable test targets include:

- required directory existence;
- exact required SystemVerilog file inventory;
- required documentation file inventory;
- nonempty required artifacts;
- canonical package symbols;
- canonical balanced ternary encodings;
- temporal scheduler symbols;
- scheduler execution-mode relations;
- RTL module declarations;
- deterministic request-lane ordering terms;
- retained pending-route terms;
- active-neutral routing terms;
- transition-capacity terms;
- retained-state update terms;
- integrated core instance names;
- assertion invariant terms;
- deterministic testbench scheduler profiles;
- terminal event-marker format strings;
- simulator command components;
- simulator completion marker;
- zero-event invariant declarations;
- RTL documentation section names;
- simulation-transcript record structure;
- closure-artifact existence.

## Disallowed Unstable Test Targets

Artifact-boundary tests must not require exact values for:

- GitHub Actions workflow run numbers;
- current commit hashes;
- workflow timestamps;
- workflow durations;
- workflow actors;
- branch-specific history order;
- qualification artifact instance numbers;
- UI-only status text;
- old failed workflow runs;
- temporary development-status phrases.

Historical qualification records include:

- workflow run `#82`;
- source commit `a68a2af`;
- workflow run `#84`;
- source commit `ede53cf`.

These values may remain in qualification evidence and documentation.

The artifact-manifest test does not require these values.

## M16 RTL Source Inventory Test Rule

The artifact-manifest test requires the exact M16 SystemVerilog source set:

| Path | Required |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | yes |
| `rtl/m16/frp_m16_scheduler.sv` | yes |
| `rtl/m16/frp_m16_request_lanes.sv` | yes |
| `rtl/m16/frp_m16_pending_routes.sv` | yes |
| `rtl/m16/frp_m16_active_neutral.sv` | yes |
| `rtl/m16/frp_m16_capacity_guard.sv` | yes |
| `rtl/m16/frp_m16_state_update.sv` | yes |
| `rtl/m16/frp_m16_core.sv` | yes |
| `rtl/m16/frp_m16_assertions.sv` | yes |
| `rtl/m16/frp_m16_tb.sv` | yes |

Required SystemVerilog artifact count:

`10`

The test rejects:

- missing required SystemVerilog artifacts;
- unexpected SystemVerilog artifacts;
- empty required SystemVerilog artifacts.

Source-inventory test result:

`PASS`

## M16 RTL Documentation Inventory Test Rule

The artifact-manifest test requires the following RTL documentation artifacts:

| Path | Required |
|---|---|
| `rtl/m16/README.md` | yes |
| `rtl/m16/ARTIFACTS.md` | yes |
| `rtl/m16/SIMULATION.md` | yes |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | yes |
| `rtl/m16/CLOSURE.md` | yes |

Required RTL documentation artifact count:

`5`

The test rejects:

- missing required RTL documentation artifacts;
- empty required RTL documentation artifacts.

Documentation-inventory test result:

`PASS`

## Package Symbol Test Rule

The package test validates:

`rtl/m16/frp_m16_pkg.sv`

Required canonical encoding terms:

- `FRP_TERN_ZERO     = 2'b00`;
- `FRP_TERN_POS      = 2'b01`;
- `FRP_TERN_RESERVED = 2'b10`;
- `FRP_TERN_NEG      = 2'b11`;
- `FRP_ACTIVE_NEUTRAL`.

Canonical retained-state domain:

`{-1, 0, 1}`

Required package functions:

- `frp_is_valid_ternary`;
- `frp_is_opposite_polarity`;
- `frp_classify_transition`;
- `frp_calc_request_lanes`.

Package-symbol test result:

`PASS`

## Temporal Execution Symbol Test Rule

The package test requires:

- `FRP_MODE_FREE`;
- `FRP_MODE_7_1`;
- `FRP_MODE_1_7`;
- `FRP_SCHED_FREE`;
- `FRP_SCHED_BALANCE`;
- `FRP_SCHED_COMMIT`;
- `FRP_SCHED_EXCITE`;
- `FRP_SCHED_NEUTRALIZE`;
- `frp_scheduler_is_commit_capable`;
- `frp_scheduler_is_neutralize_capable`;
- `frp_scheduler_allows_transition`.

Temporal execution symbol result:

`PASS`

## Scheduler Module Test Rule

The scheduler test validates:

`rtl/m16/frp_m16_scheduler.sv`

Required scheduler terms include:

- `module frp_m16_scheduler`;
- `frp_decode_scheduler_state`;
- `period_index_d`;
- `tick_index_d[2:0]`;
- `scheduler_count_free_q`;
- `scheduler_count_balance_q`;
- `scheduler_count_commit_q`;
- `scheduler_count_excite_q`;
- `scheduler_count_neutralize_q`;
- `scheduler_counts_valid`.

Qualified scheduler profiles:

| Mode | Qualified relation |
|---|---|
| `free` | `16 ticks → free = 16` |
| `7/1` | `64 ticks → balance = 56, commit = 8` |
| `1/7` | `16 ticks → excite = 2, neutralize = 14` |

Scheduler-module test result:

`PASS`

## Request-Lane Test Rule

The request-lane test validates:

`rtl/m16/frp_m16_request_lanes.sv`

Required request-lane terms include:

- `module frp_m16_request_lanes`;
- `lane_index < REQUEST_LANES`;
- `request_reject_duplicate_cell`;
- `request_reject_pending_busy`;
- `request_reject_scheduler`;
- `request_neutralized`;
- `requested_direct_events`;
- `prevented_direct_events`;
- `neutral_routed_events`;
- `request_lane_order_valid`.

Request-lane test result:

`PASS`

## Pending-Route Test Rule

The pending-route test validates:

`rtl/m16/frp_m16_pending_routes.sv`

Required pending-route terms include:

- `module frp_m16_pending_routes`;
- `pending_completion_accept_mask`;
- `pending_created_mask`;
- `pending_completed_mask`;
- `pending_cleared_mask`;
- `pending_retained_mask`;
- `pending_non_overwrite_valid`;
- `pending_polarity_valid`;
- `no_queue_overflow`;
- `no_actual_direct_events`.

Pending-route test result:

`PASS`

## Active-Neutral Test Rule

The active-neutral test validates:

`rtl/m16/frp_m16_active_neutral.sv`

Required active-neutral terms include:

- `module frp_m16_active_neutral`;
- `FRP_TRANS_OPPOSITE_POLARITY`;
- `FRP_ACTIVE_NEUTRAL`;
- `pending_completion_enable`;
- `neutral_routed_mask`;
- `pending_completion_mask`;
- `actual_direct_mask`;
- `no_actual_direct_events`.

Required routed transitions:

`-1 → 0 → 1`

`1 → 0 → -1`

Active-neutral test result:

`PASS`

## Transition-Capacity Test Rule

The transition-capacity test validates:

`rtl/m16/frp_m16_capacity_guard.sv`

Required transition-capacity terms include:

- `module frp_m16_capacity_guard`;
- `request_accept_capacity`;
- `request_reject_capacity`;
- `pending_completion_candidate`;
- `capacity_accept_mask`;
- `capacity_reject_mask`;
- `accepted_change_mask`;
- `accepted_changes`;
- `capacity_remaining`;
- `capacity_exhausted`;
- `switch_load_numerator`.

Required capacity relation:

`accepted_changes <= REQUEST_LANES`

Transition-capacity test result:

`PASS`

## Retained-State Update Test Rule

The retained-state update test validates:

`rtl/m16/frp_m16_state_update.sv`

Required state-update terms include:

- `module frp_m16_state_update`;
- `state_candidate_d`;
- `capacity_accept_mask`;
- `accepted_change_candidate_mask`;
- `neutral_routed_mask`;
- `pending_completion_mask`;
- `state_write_enable_mask`;
- `state_update_valid`;
- `no_reserved_state_output`;
- `no_actual_direct_events`.

Retained-state update test result:

`PASS`

## Core Integration Test Rule

The core integration test validates:

`rtl/m16/frp_m16_core.sv`

Required core-integration terms include:

- `module frp_m16_core`;
- `u_scheduler`;
- `u_request_lanes`;
- `u_active_neutral`;
- `u_capacity_guard`;
- `u_pending_routes`;
- `u_state_update`;
- `pending_completion_candidate`;
- `pending_completion_accept_mask`;
- `invariant_flags`.

Core-integration test result:

`PASS`

## Assertion Test Rule

The assertion test validates:

`rtl/m16/frp_m16_assertions.sv`

Required assertion terms include:

- `module frp_m16_assertions`;
- `frp_is_opposite_polarity`;
- `neutral_routed_cell_mask`;
- `pending_route_out`;
- `scheduler_count_sum`;
- `actual_direct_events`;
- `reserved_state_events`;
- `queue_overflow_events`;
- `FRP_INV_ACTIVE_NEUTRAL_VALID`;
- `FRP_INV_NO_ACTUAL_DIRECT_EVENTS`;
- `FRP_INV_NO_RESERVED_STATE`;
- `FRP_INV_NO_QUEUE_OVERFLOW`.

Required zero-event relations:

`actual_direct_events == '0`

`reserved_state_events == '0`

`queue_overflow_events == '0`

Assertion test result:

`PASS`

## Deterministic Testbench Test Rule

The deterministic testbench test validates:

`rtl/m16/frp_m16_tb.sv`

Required scheduler-profile terms include:

- `FRP_MODE_FREE`;
- `FRP_MODE_7_1`;
- `FRP_MODE_1_7`;
- `ticks_recorded_q !== 16`;
- `scheduler_count_free_q !== 16`;
- `scheduler_count_balance_q !== 56`;
- `scheduler_count_commit_q !== 8`;
- `scheduler_count_excite_q !== 2`;
- `scheduler_count_neutralize_q !== 14`.

Additional required testbench terms include:

- `neutral_routed_cell_mask`;
- `capacity_remaining !== 0`;
- `FRP M16 deterministic RTL testbench completed.`

Required terminal event-marker formats:

- `"actual_direct_events=%0d"`;
- `"reserved_state_events=%0d"`;
- `"queue_overflow_events=%0d"`.

Deterministic testbench test result:

`PASS`

## RTL Documentation Content Test Rule

The RTL README test validates:

`rtl/m16/README.md`

Required architecture section terms include:

- `Balanced Ternary State Domain`;
- `Active-Neutral Polarity Routing`;
- `Pending-Route State`;
- `Temporal Execution Architecture`;
- `7/1 Mode`;
- `1/7 Mode`;
- `Distributed Transition Capacity`;
- `Retained-State Tick Order`.

The RTL artifact-manifest test validates:

`rtl/m16/ARTIFACTS.md`

Required artifact-manifest section terms include:

- `Temporal Execution Artifacts`;
- `Active-Neutral Routing Artifacts`;
- `Pending-Route Artifact Contract`;
- `Transition-Capacity Artifacts`;
- `Include and Elaboration Graph`;
- `Integrated Invariant Set`.

Each RTL source artifact and RTL documentation artifact must be indexed in:

`rtl/m16/ARTIFACTS.md`

RTL documentation content result:

`PASS`

## Simulation Boundary Test Rule

The simulation test validates:

`rtl/m16/SIMULATION.md`

Required Verilator command terms include:

- `verilator --sv --timing --assert --binary`;
- `--top-module frp_m16_tb`;
- `-Irtl/m16`;
- `--Mdir /tmp/frp_m16_obj`;
- `rtl/m16/frp_m16_tb.sv`;
- `/tmp/frp_m16_obj/Vfrp_m16_tb`;
- `/tmp/frp_m16_execution.log`.

Required completion marker:

`FRP M16 deterministic RTL testbench completed.`

Required scheduler section terms:

- `7/1 Mode`;
- `1/7 Mode`.

Required zero-event relations:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

Simulation-boundary test result:

`PASS`

## Simulation Transcript Test Rule

The simulation-transcript test validates:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

Required transcript section terms include:

- `FRP M16 RTL Simulation Transcript`;
- `Toolchain Record`;
- `Free-Mode Record`;
- `7/1 Scheduler Record`;
- `1/7 Scheduler Record`;
- `Transition-Capacity Record`;
- `Active-Neutral Routing Record`;
- `Assertion Record`;
- `Console Output`;
- `Terminal Relations`;
- `Integrated Invariant Record`;
- `Execution Result`.

Required completion marker:

`FRP M16 deterministic RTL testbench completed.`

Simulation-transcript test result:

`PASS`

## Closure Artifact Test Rule

The closure test validates:

`rtl/m16/CLOSURE.md`

Required closure identity:

`FRP M16`

Closure-artifact test result:

`PASS`

The closure test does not require:

- a specific workflow run number;
- a specific commit hash;
- a specific workflow duration;
- a temporary development-status phrase.

## Corrective Event Handling

Historical corrective events may remain documented in qualification records.

Tests validate the current durable repository state.

When a corrective event changes a required artifact:

1. update the artifact implementation;
2. update the stable artifact inventory if the boundary changed;
3. update the corresponding stable semantic test terms;
4. run the artifact-manifest pytest boundary;
5. run the applicable qualification workflow;
6. record mutable workflow metadata in qualification documentation;
7. keep mutable workflow metadata outside stable test assertions.

## Current Policy Result

| Policy boundary | Result |
|---|---|
| stable repository-fact validation | `ACTIVE` |
| exact RTL source inventory validation | `PASS` |
| RTL documentation inventory validation | `PASS` |
| canonical package-symbol validation | `PASS` |
| scheduler validation | `PASS` |
| request-lane validation | `PASS` |
| pending-route validation | `PASS` |
| active-neutral validation | `PASS` |
| transition-capacity validation | `PASS` |
| retained-state update validation | `PASS` |
| integrated core validation | `PASS` |
| assertion validation | `PASS` |
| deterministic testbench validation | `PASS` |
| simulation-command validation | `PASS` |
| simulation-transcript structure validation | `PASS` |
| closure-artifact validation | `PASS` |
| mutable workflow-metadata exclusion | `ACTIVE` |

Current M16 RTL qualification:

`PASS`

Current M16 RTL closure status:

`M16 RTL EXECUTION LAYER CLOSED`

Current M16 FPGA preparation status:

`M16 FPGA PREPARATION LAYER CLOSED`

## Author

Maksym Marnov

# FRP M16 Artifact-Boundary Test Stability Policy

## Status

`ACTIVE`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document defines the stability policy for M16 artifact-boundary tests of the:

`Ternary Fractal Resonant Coherence Processor`

The M16 RTL artifact-boundary workflow has passed.

Future tests must validate stable semantic requirements, not unstable GitHub run numbers or commit hashes.

## Current Boundary

Primary RTL directory:

`rtl/m16/`

Primary test file:

`tests/test_m16_rtl_artifact_manifest.py`

Primary workflow:

`FRP M16 RTL Artifact Boundary`

Current artifact-boundary status:

`PASS`

Current external simulator status:

`pending external simulator execution`

## Stability Rule

Artifact-boundary tests must validate durable repository facts.

They must not depend on live GitHub metadata that changes after every commit.

## Allowed Stable Test Targets

Stable test targets include:

- required file existence;
- required directory existence;
- canonical package symbols;
- RTL module references;
- assertion invariant terms;
- simulator command boundary;
- testbench completion marker;
- zero-event invariant declarations;
- repository documentation exposure;
- artifact-boundary status terms;
- external simulator pending status;
- M15 inherited package digest.

## Disallowed Unstable Test Targets

Tests must not require exact values for:

- GitHub Actions run numbers;
- current commit hashes;
- workflow timestamps;
- workflow duration;
- branch-specific history order;
- UI-only status text;
- old failed workflow runs.

Examples of unstable terms:

`FRP M16 RTL Artifact Boundary #8`

`12a3431`

These may be recorded in documentation as historical evidence, but tests should not require them.

## Stable PASS Terms

The following terms are stable and may be tested:

`ARTIFACT-BOUNDARY PASS`

`FRP M16 RTL Artifact Boundary`

`PASS`

`pending external simulator execution`

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## M16 RTL Source Inventory Test Rule

The test must require the following RTL source artifacts to exist:

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

## M16 RTL Documentation Inventory Test Rule

The test must require the following RTL documentation artifacts to exist:

| Path | Required |
|---|---|
| `rtl/m16/README.md` | yes |
| `rtl/m16/ARTIFACTS.md` | yes |
| `rtl/m16/SIMULATION.md` | yes |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | yes |
| `rtl/m16/CLOSURE.md` | yes |

## Package Symbol Test Rule

The test must require the canonical package symbols:

- `FRP_TERN_ZERO`;
- `FRP_TERN_POS`;
- `FRP_TERN_RESERVED`;
- `FRP_TERN_NEG`;
- `FRP_STATE_ZERO`;
- `FRP_STATE_POS`;
- `FRP_STATE_NEG`;
- `frp_is_valid_ternary`;
- `frp_is_opposite_polarity`;
- `frp_classify_transition`;
- `frp_calc_request_lanes`.

## Core Integration Test Rule

The test must require the integrated core to reference:

- `frp_m16_scheduler`;
- `frp_m16_request_lanes`;
- `frp_m16_active_neutral`;
- `frp_m16_capacity_guard`;
- `frp_m16_pending_routes`;
- `frp_m16_state_update`.

## Assertion Test Rule

The test must require assertion-layer terms for:

`actual_direct_events == '0`

`reserved_state_events == '0`

`queue_overflow_events == '0`

`FRP_INV_NO_ACTUAL_DIRECT_EVENTS`

`FRP_INV_NO_RESERVED_STATE`

`FRP_INV_NO_QUEUE_OVERFLOW`

## Simulation Boundary Test Rule

The test may require the stable simulator command:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

The test may require the stable run command:

    ./obj_dir/Vfrp_m16_tb

The test may require the stable completion marker:

    FRP M16 deterministic RTL testbench completed.

The test must not require a captured simulator transcript until external simulator execution is actually completed.

## Documentation Exposure Test Rule

The test must require M16 exposure from:

- `README.md`;
- `PROJECT_STRUCTURE.md`;
- `docs/README.md`;
- `docs/architecture.md`;
- `docs/m16_external_simulator_execution_plan.md`.

## Closure Boundary Test Rule

The closure test should validate:

`ARTIFACT-BOUNDARY PASS`

`FRP M16 RTL Artifact Boundary`

`PASS`

`pending external simulator execution`

It must not require a specific GitHub Actions run number.

It must not require a specific commit hash.

## Corrective Event Handling

Historical corrective events may remain documented.

Example:

`rtl/m16/frp_m16_pending_routes.sv`

was added after the artifact-boundary workflow exposed the missing required source artifact.

This event may be described in documents, but tests should validate the current durable state:

`frp_m16_pending_routes.sv` exists.

## Current Policy Result

Current policy result:

`ACTIVE`

Current artifact-boundary result:

`PASS`

Current simulator result:

`pending external simulator execution`

## Next Step

The next repository step should expose this stability policy from:

`docs/README.md`

and include it in the M16 workflow path filters.

## Author

Maksym Marnov

# FRP M16 Public Status Snapshot

## Status

`PUBLIC STATUS SYNCHRONIZED`

## Version

`FRP v1.8.0`

## Milestone

`M16 — RTL Core Realization and Execution Semantics Package`

## Purpose

This document records the current public-facing status snapshot for the:

`Ternary Fractal Resonant Coherence Processor`

The snapshot aligns the repository README badge panel, GitHub About description, M16 RTL artifact-boundary qualification, M15 inherited qualification evidence, DOI reference, and next external simulator / FPGA preparation boundary.

## Current Public Status

Current public repository status:

`M16 RTL artifact-boundary PASS`

Current release layer:

`FRP v1.8.0 — M16 RTL`

Current public qualification position:

`pre-external-simulator / pre-FPGA synthesis preparation`

Current external simulator status:

`pending external simulator execution`

Current FPGA / synthesis status:

`preparation layer next`

## README Badge Panel Status

The README badge panel has been updated to show the current evidence surface.

Displayed primary workflow badges:

- `FRP Self Test`;
- `FRP Structured Output`;
- `FRP Benchmark Smoke Test`;
- `FRP M16 RTL Artifact Boundary`.

Displayed repository status badges:

- `license Apache-2.0`;
- `python 3.11+`;
- `version v1.8.0`;
- `workflows latest PASS`;
- `M15 41/41 PASS`;
- `M16 artifact boundary PASS`;
- `RTL artifacts present`;
- `simulator external pending`;
- `release v1.8.0 M16`;
- `DOI 10.5281/zenodo.21183966`.

README badge panel result:

`public status panel synchronized`

## GitHub About Status

GitHub About / Description has been updated to reflect the current M16 state.

Current public description:

`FRP — Ternary Fractal Resonant Coherence Processor with M15 41/41 qualification, M16 RTL artifact-boundary PASS, active-neutral balanced ternary state retention, and external simulator / FPGA preparation layer.`

GitHub About result:

`public repository description synchronized`

## M15 Qualification Evidence

M15 remains the inherited qualification base.

Current M15 evidence:

`41 / 41 PASS`

M15 qualification includes:

- deterministic fixed-point interface mapping;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vector package;
- SystemVerilog testbench interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- reference RTL equivalence;
- exact deterministic replay;
- qualification closure.

Validated M15 package digest:

`703dd4b56f4b34289a2c5bc5521ad4ddc3113bdec8c38238c3244c69cb4d58df`

## M16 Artifact-Boundary Evidence

Current M16 artifact-boundary result:

`PASS`

Qualified workflow:

`FRP M16 RTL Artifact Boundary`

Qualified test file:

`tests/test_m16_rtl_artifact_manifest.py`

Current M16 source boundary:

`rtl/m16/`

Qualified RTL source artifacts:

| Path | Status |
|---|---|
| `rtl/m16/frp_m16_pkg.sv` | present |
| `rtl/m16/frp_m16_scheduler.sv` | present |
| `rtl/m16/frp_m16_request_lanes.sv` | present |
| `rtl/m16/frp_m16_pending_routes.sv` | present |
| `rtl/m16/frp_m16_active_neutral.sv` | present |
| `rtl/m16/frp_m16_capacity_guard.sv` | present |
| `rtl/m16/frp_m16_state_update.sv` | present |
| `rtl/m16/frp_m16_core.sv` | present |
| `rtl/m16/frp_m16_assertions.sv` | present |
| `rtl/m16/frp_m16_tb.sv` | present |

Qualified RTL documentation artifacts:

| Path | Status |
|---|---|
| `rtl/m16/README.md` | present |
| `rtl/m16/ARTIFACTS.md` | present |
| `rtl/m16/SIMULATION.md` | present |
| `rtl/m16/SIMULATION_TRANSCRIPT.md` | present |
| `rtl/m16/CLOSURE.md` | present |

## Preserved Execution Chain

The public M16 status preserves the retained-state execution chain:

`phase-derived ternary target`

→ `request-lane arbitration`

→ `transition-capacity guard`

→ `pending-route processing`

→ `active-neutral routing through 0`

→ `retained balanced ternary state`

## Preserved Public Invariants

The current public status preserves the zero-event invariant boundary:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

These are documented artifact-boundary invariants and external simulator closure targets.

## Canonical Balanced Ternary Encoding

The current public M16 layer preserves the canonical balanced ternary encoding:

| Ternary state | Encoding | Status |
|---|---|---|
| `-1` | `2'b11` | valid |
| `0` | `2'b00` | valid active neutral |
| `+1` | `2'b01` | valid |
| reserved | `2'b10` | invalid |

Required invariant:

`reserved_state_events = 0`

## DOI Status

Current DOI:

`10.5281/zenodo.21183966`

DOI URL:

`https://doi.org/10.5281/zenodo.21183966`

DOI status:

`active public reference`

## External Simulator Boundary

Current external simulator status:

`pending external simulator execution`

Simulation instructions:

`rtl/m16/SIMULATION.md`

Transcript template:

`rtl/m16/SIMULATION_TRANSCRIPT.md`

Required command shape:

    verilator --sv --timing --assert --binary -Irtl/m16 rtl/m16/frp_m16_tb.sv

Required run command:

    ./obj_dir/Vfrp_m16_tb

Required completion marker:

    FRP M16 deterministic RTL testbench completed.

Required final zero-event counters:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

## FPGA / Synthesis Preparation Boundary

Current FPGA / synthesis status:

`preparation layer next`

The repository now exposes:

- M15 qualified retained-state boundary;
- M16 RTL source artifact boundary;
- M16 assertion layer;
- deterministic smoke testbench;
- external simulator execution plan;
- simulator transcript template;
- closure report structure.

The next technical layer may evaluate:

- external simulator execution;
- assertion PASS under simulator execution;
- synthesis feasibility;
- LUT utilization;
- FF utilization;
- BRAM usage;
- DSP usage;
- timing closure;
- reset strategy;
- clock strategy;
- target FPGA class.

External FPGA or circuit-level review must not redefine the FRP processor semantics.

## M15 to M16 Public Compatibility Chain

Public compatibility chain:

`M15 quantized hardware shadow`

→ `M15 cycle-exact integer golden trace`

→ `M15 deterministic RTL comparison vectors`

→ `M16 RTL core`

→ `M16 assertion layer`

→ `M16 simulation transcript`

→ `M16 qualification closure`

Replay target:

`deterministic boundary equivalence`

The replay target is not approximate behavioral similarity.

## Current Public Result

Current public snapshot result:

`README badge panel synchronized`

`GitHub About synchronized`

`M15 qualification evidence exposed`

`M16 RTL artifact-boundary PASS exposed`

`RTL artifacts present`

`external simulator pending`

`FPGA / synthesis preparation next`

`DOI active`

## Next Step

Next repository step:

Expose this public status snapshot from:

- `docs/README.md`;
- `docs/m16_qualification_index.md`;
- `docs/m16_qualification_manifest.md`.

Then continue toward:

`external simulator execution`

## Author

Maksym Marnov

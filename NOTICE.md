# Notice

**Fractal Resonance Processor (FRP)**

**Ternary Fractal Resonant Coherence Processor**

Copyright 2026 Maksym Marnov

This project is licensed under the Apache License, Version 2.0.

## Current Release

**Version:** `FRP v1.8.0`

**Milestone:** `M16 — RTL Core Realization and Execution Semantics Package`

**Current Python executable semantic reference:** `frp_prototype_v1_7_0.py`

**Python executable semantic-reference form:** `Ternary Resonant Coherence Processor — Structured Output Prototype`

**Structured-output schema:** `frp.structured_output.v1.7.0`

**Benchmark-matrix schema:** `frp.m3.benchmark_matrix.v1.7.0`

**Qualified semantic and implementation-mapping foundation:** `FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

**Current RTL qualification workflow:** `.github/workflows/frp-m16-rtl-artifact-boundary.yml`

**Current FPGA preparation qualification workflow:** `.github/workflows/frp-m16-fpga-preparation.yml`

## Repository Scope

The Fractal Resonance Processor (FRP) repository contains the public executable processor reference, structured output, reproducibility, verification, benchmark, comparative architecture, hardware-sensitivity, implementation-mapping, qualification, SystemVerilog RTL execution, target-independent FPGA preparation, documentation, governance, and release-evidence layers of the project.

FRP v1.8.0 establishes the current M16 RTL Core Realization and Execution Semantics Package layer.

M16 retains the qualified M15 Python executable semantic reference, structured-output schema, benchmark-matrix schema, and semantic and implementation-mapping foundation.

The current release package includes:

- Kuramoto-Sakaguchi resonant phase dynamics;
- asymmetric phase lag gamma;
- hierarchical fractal coupling;
- phase evolution and resonance selection;
- Kuramoto order parameter `R(t)`;
- multiscale phase coherence;
- endogenous structural coherence `C(t)`;
- operational pressure `P(t)`;
- stateful delay dynamics;
- distributed local thermal dynamics;
- thermal coupling-factor evolution;
- correlated local gamma drift;
- nonlinear coherence compression;
- dynamic stability evaluation;
- phase-derived balanced ternary target formation;
- balanced ternary state and retained-result domain `{-1, 0, 1}`;
- active neutral state `0`;
- mandatory opposite-polarity routing through state `0`;
- distributed commit behavior;
- deterministic scheduler modes `free`, `7/1`, and `1/7`;
- deterministic request-lane arbitration;
- retained pending-route execution;
- distributed transition-capacity enforcement;
- retained-state writeback;
- hardware-facing fixed-point representation;
- canonical balanced ternary hardware encoding;
- stateful quantized hardware-shadow execution;
- cycle-exact integer golden traces;
- deterministic RTL comparison vectors;
- SystemVerilog interface mapping;
- synthesizable RTL reference-core mapping;
- RTL assertion correlation;
- floating-to-quantized semantic correlation;
- exact deterministic replay;
- M15 qualification closure;
- ten M16 SystemVerilog RTL source files;
- five M16 RTL documentation artifacts;
- executable Verilator RTL architectural simulation;
- SystemVerilog assertion execution;
- ten integrated invariant flags;
- target-independent FPGA integration top;
- executable FPGA integration testbench;
- asynchronous external reset assertion;
- two-stage synchronous reset release;
- `core_ready` generation;
- tick, counter-clear, and request-valid gating before readiness;
- scheduler and request-interface propagation;
- retained pending-route completion;
- M16 RTL qualification closure;
- M16 FPGA preparation qualification closure.

## Current Qualification State

**Published validation result:** `PASS`

**Inherited validated M15 self-test:** `41/41 PASS`

**M15 artifact layers:** `10`

**Deterministic vector package:** `10/10 files byte-identical`

**Required semantic correlation matches:** `5/5 = 1.0`

**Exact deterministic replay matches:** `6/6 = 1.0`

### M16 RTL Qualification Records

| Qualification record | Workflow run | Qualified source commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| Initial closure | `#82` | `a68a2af` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |
| Qualification rerun | `#84` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 RTL EXECUTION LAYER CLOSED` |

### M16 FPGA Preparation Qualification Records

| Qualification record | Workflow run | Qualified repository commit | Branch | Result | Artifact count | Status |
|---|---:|---|---|---|---:|---|
| Initial closure | `#1` | `326b69e` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |
| Qualification rerun | `#2` | `ede53cf` | `main` | `SUCCESS` | `1` | `M16 FPGA PREPARATION LAYER CLOSED` |

### M16 RTL Terminal Execution Records

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `ticks_recorded` | `16` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

### M16 FPGA Preparation Terminal Execution Records

| Record | Result |
|---|---:|
| cells | `8` |
| request lanes | `2` |
| `core_ready` | `1` |
| `ticks_recorded` | `1` |
| `actual_direct_events` | `0` |
| `reserved_state_events` | `0` |
| `queue_overflow_events` | `0` |
| invariant flags | `1111111111` |

## Foundation Documents

- `docs/mathematical_foundation.md`;
- `docs/physical_foundation.md`.

## License

See `LICENSE` for the complete Apache License 2.0 terms.

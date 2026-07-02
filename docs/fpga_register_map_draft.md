# FRP M3 FPGA Register Map Draft

## Fractal Resonance Processor v0.9.5

Milestone: M3 — Benchmark Export and Hardware Signal Mapping

Prototype:

`frp_prototype_v0_9_5.py`

Schema:

`frp.m3.fpga_register_map_draft.v0.9.5`

## Purpose

This document defines the FPGA register map draft layer for FRP v0.9.5.

The register map draft translates the FRP M3 signal map into a preliminary memory-mapped register structure for future FPGA, ASIC, external testbench, and hardware-facing comparison workflows.

This document is a draft interface specification.

It is not HDL.

It is not a timing-closed FPGA design.

It is not a final ASIC register specification.

It is not a silicon tapeout document.

## M3 Export Command

The FPGA register map draft can be exported with:

`python frp_prototype_v0_9_5.py --export-register-map`

The export is JSON by default for this M3 export mode.

## Register Map Schema

Current schema marker:

`frp.m3.fpga_register_map_draft.v0.9.5`

Current output kind:

`fpga_register_map_draft`

## Register Map Assumptions

Current draft assumptions:

- register width: `32-bit`;

- draft endianness: `little-endian`;

- access types: `RO`, `RW`;

- fixed-point telemetry format: `Q16`;

- signed stability margin format: signed `Q16`;

- this map is intended for interface discussion and testbench preparation.

## Register Table

| Offset | Name | Width | Access | Reset | Description |
|---|---|---:|---|---|---|
| `0x00` | `FRP_VERSION` | 32 | RO | `0x00090500` | Packed FRP version marker for v0.9.5. |
| `0x04` | `CONTROL` | 32 | RW | `0x00000000` | Run, reset, step, and export control flags. |
| `0x08` | `SCHEDULER_MODE` | 32 | RW | `0x00000000` | Scheduler mode selector. |
| `0x0C` | `TRANSITION_FRACTION_Q16` | 32 | RW | `0x00004000` | Distributed commit fraction in Q16 fixed-point format. |
| `0x10` | `GAMMA_Q16` | 32 | RW | `0x0000F15C` | Sakaguchi phase shift gamma in Q16 fixed-point radians. |
| `0x14` | `CELL_COUNT` | 32 | RW | `0x00000020` | Number of active processor cells. |
| `0x18` | `STEP_COUNT` | 32 | RW | `0x00000040` | Number of ticks to execute in batch mode. |
| `0x1C` | `STATUS` | 32 | RO | `0x00000000` | Pass, fail, busy, and telemetry-ready status flags. |
| `0x20` | `ACTUAL_DIRECT_EVENTS` | 32 | RO | `0x00000000` | Counter for actual direct `-1 ↔ 1` transitions. |
| `0x24` | `PREVENTED_DIRECT_EVENTS` | 32 | RO | `0x00000000` | Counter for direct transitions prevented through neutral routing. |
| `0x28` | `NEUTRALIZED_CONFLICTS` | 32 | RO | `0x00000000` | Counter for neutralized polarity conflicts. |
| `0x2C` | `SWITCH_LOAD_PEAK_Q16` | 32 | RO | `0x00000000` | Peak switch load in Q16 fixed-point format. |
| `0x30` | `HEAT_PEAK_Q16` | 32 | RO | `0x00000000` | Peak heat/load proxy in Q16 fixed-point format. |
| `0x34` | `C_MINUS_P_MIN_Q16` | 32 | RO | `0x00000000` | Minimum operational stability margin in signed Q16 fixed-point format. |
| `0x38` | `PHASE_ORDER_R_Q16` | 32 | RO | `0x00000000` | Final phase order parameter in Q16 fixed-point format. |
| `0x3C` | `TELEMETRY_READ_INDEX` | 32 | RW | `0x00000000` | Telemetry buffer read index. |

## Register Definitions

### FRP_VERSION

Offset:

`0x00`

Access:

`RO`

Description:

Packed FRP version marker for v0.9.5.

Current reset value:

`0x00090500`

## CONTROL

Offset:

`0x04`

Access:

`RW`

Description:

Control register for future run, reset, step, and export flags.

Draft bit layout:

- bit `0`: run;

- bit `1`: reset;

- bit `2`: single-step;

- bit `3`: export telemetry;

- bit `4`: export benchmark matrix;

- bit `5`: export signal map;

- bit `6`: export testbench vector.

## SCHEDULER_MODE

Offset:

`0x08`

Access:

`RW`

Description:

Scheduler mode selector.

Draft encoding:

`0 = free`

`1 = 7/1`

`2 = 1/7`

The scheduler mode controls the preparation, commit, excitation, neutralization, and recovery pattern.

## TRANSITION_FRACTION_Q16

Offset:

`0x0C`

Access:

`RW`

Description:

Distributed commit fraction in Q16 fixed-point format.

Current default semantic value:

`transition_fraction = 0.25`

Candidate invariant marker:

`switch_load_peak <= transition_fraction`

## GAMMA_Q16

Offset:

`0x10`

Access:

`RW`

Description:

Sakaguchi phase shift parameter in Q16 fixed-point radians.

Current default semantic value:

`gamma = 0.30 pi`

This parameter belongs to the Kuramoto-Sakaguchi resonant phase-coupling layer.

## CELL_COUNT

Offset:

`0x14`

Access:

`RW`

Description:

Number of active processor cells in the reference configuration.

Current default value:

`32`

## STEP_COUNT

Offset:

`0x18`

Access:

`RW`

Description:

Number of ticks to execute in batch mode.

Current default value:

`64`

## STATUS

Offset:

`0x1C`

Access:

`RO`

Description:

Status register for future pass, fail, busy, and telemetry-ready flags.

Draft bit layout:

- bit `0`: pass;

- bit `1`: fail;

- bit `2`: busy;

- bit `3`: telemetry ready;

- bit `4`: benchmark ready;

- bit `5`: signal map ready;

- bit `6`: testbench vector ready.

## ACTUAL_DIRECT_EVENTS

Offset:

`0x20`

Access:

`RO`

Description:

Counter for actual direct polarity jumps:

`-1 ↔ 1`

Candidate invariant marker for FRP distributed resonant operation:

`actual_direct_events = 0`

## PREVENTED_DIRECT_EVENTS

Offset:

`0x24`

Access:

`RO`

Description:

Counter for polarity jumps prevented through neutral routing.

Neutral-routed transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

## NEUTRALIZED_CONFLICTS

Offset:

`0x28`

Access:

`RO`

Description:

Counter for polarity conflicts neutralized by the active neutral state `0`.

The neutral state is treated as a transition buffer, damping state, conflict neutralizer, switching-load regulator, and phase-stabilizing bridge.

## SWITCH_LOAD_PEAK_Q16

Offset:

`0x2C`

Access:

`RO`

Description:

Peak switch load in Q16 fixed-point format.

This register tracks the maximum observed fraction of cells changing state during a tick.

Candidate invariant marker:

`switch_load_peak <= transition_fraction`

## HEAT_PEAK_Q16

Offset:

`0x30`

Access:

`RO`

Description:

Peak heat/load proxy in Q16 fixed-point format.

In the current software reference model:

`P(t) = heat + switch_load`

## C_MINUS_P_MIN_Q16

Offset:

`0x34`

Access:

`RO`

Description:

Minimum operational stability margin in signed Q16 fixed-point format.

FRP tracks:

`C_minus_P = C(t) - P(t)`

Stable operation requires:

`C_minus_P > 0`

Candidate invariant marker:

`C_minus_P_min > 0`

## PHASE_ORDER_R_Q16

Offset:

`0x38`

Access:

`RO`

Description:

Final phase order parameter in Q16 fixed-point format.

The value represents a Kuramoto-style resonant coherence marker:

`0 <= R <= 1`

## TELEMETRY_READ_INDEX

Offset:

`0x3C`

Access:

`RW`

Description:

Telemetry buffer read index for future hardware-facing telemetry extraction.

## Hardware Translation Role

This register map draft provides a bridge between:

- FRP software reference fields;

- structured JSON export;

- hardware-facing signal mapping;

- register-level testbench comparison;

- future FPGA and ASIC interface planning.

## Candidate Register-Level Invariants

The following candidate invariants should remain visible at register or telemetry level:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Non-Goals

This document is not HDL.

This document is not Verilog.

This document is not VHDL.

This document is not SystemVerilog.

This document is not a timing-closed FPGA implementation.

This document is not a final ASIC register specification.

The role of this document is to define a structured draft register map for future hardware-facing development.

## Related M3 Export Layers

FRP v0.9.5 defines four M3 export layers:

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

This document covers the FPGA register map draft layer.

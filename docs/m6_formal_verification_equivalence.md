# FRP v0.9.8 — M6 Formal Verification Hooks and Equivalence Scaffold

## Milestone Scope

FRP v0.9.8 establishes the M6 Formal Verification Hooks and Equivalence Scaffold layer.

This milestone extends the M5 RTL interface contract and assertion harness layer into formal property records, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.

## M6 Position in the FRP Roadmap

M1 established the executable FRP reference layer.

M2 established structured output and machine-readable validation.

M3 established benchmark export and hardware-facing signal mapping.

M4 established HDL trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

M5 established RTL interface contract, assertion manifest export, RTL signal binding, and assertion harness scaffold generation.

M6 establishes formal verification hooks and equivalence scaffold preparation.

## M6 Core Artifacts

M6 introduces the following artifact targets:

- `formal_property_set`;

- `equivalence_trace_map`;

- `bounded_verification_config`;

- `formal_harness_scaffold`.

## Planned M6 Executable Reference File

Main executable reference file target:

`frp_prototype_v0_9_8.py`

## Planned M6 Export Commands

Formal property set export:

`python frp_prototype_v0_9_8.py --export-formal-property-set`

Equivalence trace map export:

`python frp_prototype_v0_9_8.py --export-equivalence-trace-map`

Bounded verification config export:

`python frp_prototype_v0_9_8.py --export-bounded-verification-config`

Formal harness scaffold export:

`python frp_prototype_v0_9_8.py --export-formal-harness`

## Planned M6 Schemas

M6 defines the following schema targets:

`frp.m6.formal_property_set.v0.9.8`

`frp.m6.equivalence_trace_map.v0.9.8`

`frp.m6.bounded_verification_config.v0.9.8`

`frp.m6.formal_harness_scaffold.v0.9.8`

## Formal Property Set

The formal property set maps FRP candidate invariants into formal verification property records.

Primary property targets:

- actual direct transition counter equals zero;

- match marker equals one;

- C_minus_P minimum remains positive;

- switch load peak remains within transition fraction;

- recorded tick count equals configured step count;

- scheduler accounting matches configured cycle mode;

- neutral-routed transition path is preserved.

## Equivalence Trace Map

The equivalence trace map links executable FRP trace fields to RTL-facing signal records.

Trace equivalence targets:

- `cell_state` to `frp_cell_state`;

- `phase_q16` to `frp_phase_q16`;

- `scheduler_state` to `frp_scheduler_state`;

- `switch_load_q16` to `frp_switch_load_q16`;

- `heat_q16` to `frp_heat_q16`;

- `C_minus_P_q16` to `frp_C_minus_P_q16`;

- `phase_order_R_q16` to `frp_phase_order_R_q16`;

- `actual_direct_events` to `frp_actual_direct_events`;

- `prevented_direct_events` to `frp_prevented_direct_events`;

- `neutralized_conflicts` to `frp_neutralized_conflicts`.

## Bounded Verification Config

The bounded verification config defines deterministic verification bounds for formal and equivalence workflows.

Configuration targets:

- cell count;

- step count;

- scheduler mode;

- transition fraction Q16;

- gamma Q16;

- seed;

- invariant set;

- trace comparison depth;

- assertion set.

## Formal Harness Scaffold

The formal harness scaffold provides a generated structure for formal verification preparation.

The scaffold includes:

- module declaration;

- clock and reset structure;

- bounded-step counter;

- signal declarations;

- property placeholders;

- assumption placeholders;

- cover placeholders;

- equivalence mapping placeholders;

- final status reporting section.

## Candidate M6 Validation Targets

M6 validation targets:

- generated formal property set contains required property records;

- generated equivalence trace map preserves M5 signal binding names;

- generated bounded verification config contains deterministic bounds;

- generated formal harness scaffold contains clock, reset, bounded counter, signal, property, assumption, cover, equivalence, and final status sections;

- generated artifacts preserve candidate invariant markers;

- GitHub Actions validates M6 export schemas and generated artifact structure.

## M6 Technical Position

FRP v0.9.8 extends the M5 RTL interface contract and assertion harness layer into formal property export, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.

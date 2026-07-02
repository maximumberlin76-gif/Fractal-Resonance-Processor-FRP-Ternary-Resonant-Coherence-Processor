# FRP v0.9.7 — M5 RTL Interface Contract and Assertion Harness

## Milestone Scope

FRP v0.9.7 establishes the M5 RTL Interface Contract and Assertion Harness layer.

This milestone extends the M4 HDL trace and testbench scaffold layer into RTL-facing signal contract definition, deterministic interface records, assertion target mapping, and machine-readable RTL harness preparation.

## M5 Position in the FRP Roadmap

M1 established the executable FRP reference layer.

M2 established structured output and machine-readable validation.

M3 established benchmark export and hardware-facing signal mapping.

M4 established HDL trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

M5 establishes RTL interface contract and assertion harness preparation.

## M5 Core Artifacts

M5 introduces the following artifact targets:

- `rtl_interface_contract`;

- `assertion_manifest`;

- `rtl_signal_binding`;

- `assertion_harness_scaffold`.

## Planned M5 Executable Reference File

Main executable reference file target:

`frp_prototype_v0_9_7.py`

## Planned M5 Export Commands

RTL interface contract export:

`python frp_prototype_v0_9_7.py --export-rtl-interface-contract`

Assertion manifest export:

`python frp_prototype_v0_9_7.py --export-assertion-manifest`

RTL signal binding export:

`python frp_prototype_v0_9_7.py --export-rtl-signal-binding`

Assertion harness scaffold export:

`python frp_prototype_v0_9_7.py --export-assertion-harness`

## Planned M5 Schemas

M5 defines the following schema targets:

`frp.m5.rtl_interface_contract.v0.9.7`

`frp.m5.assertion_manifest.v0.9.7`

`frp.m5.rtl_signal_binding.v0.9.7`

`frp.m5.assertion_harness_scaffold.v0.9.7`

## RTL Interface Contract

The RTL interface contract defines the canonical signal interface between the FRP executable reference layer and HDL-facing processor workflow artifacts.

Primary interface groups:

- clock and reset;

- scheduler control;

- ternary cell state;

- phase telemetry;

- transition routing counters;

- stability telemetry;

- phase-order telemetry;

- benchmark invariant outputs.

## Assertion Manifest

The assertion manifest maps FRP validation targets into machine-readable assertion records.

Primary assertion targets:

- actual direct transition counter equals zero;

- match marker equals one;

- C_minus_P minimum remains positive;

- switch load peak remains within transition fraction;

- recorded tick count equals configured step count;

- scheduler accounting matches configured cycle mode.

## RTL Signal Binding

The RTL signal binding maps FRP signal names into RTL-facing signal records.

Binding targets:

- `cell_state`;

- `phase_q16`;

- `scheduler_state`;

- `transition_fraction_q16`;

- `gamma_q16`;

- `switch_load_q16`;

- `heat_q16`;

- `C_minus_P_q16`;

- `phase_order_R_q16`;

- `actual_direct_events`;

- `prevented_direct_events`;

- `neutralized_conflicts`.

## Assertion Harness Scaffold

The assertion harness scaffold provides a generated RTL-facing assertion structure.

The scaffold includes:

- module declaration;

- clock and reset structure;

- signal declarations;

- parameter declarations;

- assertion placeholders;

- invariant comparison placeholders;

- telemetry binding placeholders;

- final status reporting section.

## Candidate M5 Validation Targets

M5 validation targets:

- generated RTL interface contract contains required signal groups;

- generated assertion manifest contains required invariant assertions;

- generated RTL signal binding preserves M4 signal names;

- generated assertion harness scaffold contains clock, reset, signal, parameter, assertion, telemetry, and final status sections;

- generated artifacts preserve candidate invariant markers;

- GitHub Actions validates M5 export schemas and generated artifact structure.

## M5 Technical Position

FRP v0.9.7 extends the M4 HDL trace and testbench scaffold layer into RTL interface contract definition, assertion manifest export, RTL signal binding, and assertion harness scaffold generation.

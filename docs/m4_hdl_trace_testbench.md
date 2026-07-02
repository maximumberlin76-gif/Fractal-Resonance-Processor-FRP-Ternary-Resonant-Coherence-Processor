# FRP v0.9.6 — M4 HDL Trace Export and Testbench Scaffold

## Milestone Scope

FRP v0.9.6 establishes the M4 HDL Trace Export and Testbench Scaffold layer.

This milestone extends the M3 benchmark and hardware-facing signal mapping layer into HDL-oriented trace export, signal fixture generation, VCD-style waveform preparation, and Verilog testbench scaffold generation.

## M4 Position in the FRP Roadmap

M1 established the executable FRP reference prototype.

M2 established structured output and machine-readable validation.

M3 established benchmark export and hardware-facing signal mapping.

M4 establishes HDL trace export and testbench scaffold preparation.

## M4 Core Artifacts

M4 introduces the following artifact targets:

- `hdl_trace`;

- `vcd_trace`;

- `signal_fixture`;

- `verilog_testbench_scaffold`.

## Planned M4 Prototype

Main prototype target:

`frp_prototype_v0_9_6.py`

## Planned M4 Export Commands

HDL trace export:

`python frp_prototype_v0_9_6.py --export-hdl-trace`

VCD-style trace export:

`python frp_prototype_v0_9_6.py --export-vcd-trace`

Signal fixture export:

`python frp_prototype_v0_9_6.py --export-signal-fixture`

Verilog testbench scaffold export:

`python frp_prototype_v0_9_6.py --export-verilog-testbench`

## Planned M4 Schemas

M4 defines the following schema targets:

`frp.m4.hdl_trace.v0.9.6`

`frp.m4.vcd_trace.v0.9.6`

`frp.m4.signal_fixture.v0.9.6`

`frp.m4.verilog_testbench_scaffold.v0.9.6`

## HDL Trace Export

The HDL trace export maps per-tick FRP runtime state into HDL-facing signal records.

Primary signal groups:

- ternary cell state;

- phase state;

- scheduler state;

- transition routing counters;

- stability telemetry;

- phase-order telemetry;

- benchmark invariant markers.

## VCD-Style Trace Export

The VCD-style trace export prepares waveform-oriented signal timelines.

Primary waveform targets:

- `cell_state`;

- `scheduler_tick`;

- `switch_load`;

- `heat`;

- `C_minus_P`;

- `phase_order_R`;

- `actual_direct_events`;

- `prevented_direct_events`;

- `neutralized_conflicts`.

## Signal Fixture Export

The signal fixture export defines deterministic input and expected-output records for testbench comparison.

Fixture targets:

- initial ternary state vector;

- scheduler mode;

- transition fraction;

- gamma value;

- tick count;

- expected direct-event counter;

- expected stability bounds;

- expected scheduler accounting.

## Verilog Testbench Scaffold

The Verilog testbench scaffold provides a generated HDL-facing testbench structure.

The scaffold includes:

- module declaration;

- clock/reset structure;

- parameter placeholders;

- signal declarations;

- input fixture placeholders;

- expected-output comparison placeholders;

- telemetry assertion placeholders.

## Candidate M4 Validation Targets

M4 validation targets:

- generated HDL trace contains tick-indexed signal records;

- generated VCD-style trace contains waveform-oriented signal records;

- generated signal fixture contains deterministic input and expected-output fields;

- generated Verilog testbench scaffold contains module, clock, reset, signal, fixture, and assertion sections;

- generated artifacts preserve M3 signal names;

- generated artifacts preserve M3 candidate invariant markers;

- GitHub Actions validates M4 export schemas and generated artifact structure.

## M4 Technical Position

FRP v0.9.6 extends the M3 benchmark and hardware-facing signal mapping layer into HDL trace export, signal fixture generation, VCD-style waveform preparation, and Verilog testbench scaffold generation.

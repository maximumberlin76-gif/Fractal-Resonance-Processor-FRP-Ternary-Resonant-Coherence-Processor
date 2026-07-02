# FRP v0.9.6 Release Notes

## Release Layer

Fractal Resonance Processor (FRP) v0.9.6

M4 — HDL Trace Export and Testbench Scaffold

## Main Prototype

`frp_prototype_v0_9_6.py`

## Release Scope

FRP v0.9.6 establishes the M4 HDL Trace Export and Testbench Scaffold layer.

This release extends the M3 benchmark and hardware-facing signal mapping layer into HDL-oriented trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

## M4 Export Layers

FRP v0.9.6 defines the following M4 export layers:

- `hdl_trace`;

- `vcd_trace`;

- `signal_fixture`;

- `verilog_testbench_scaffold`.

## M4 Export Commands

HDL trace export:

`python frp_prototype_v0_9_6.py --export-hdl-trace`

VCD-style trace export:

`python frp_prototype_v0_9_6.py --export-vcd-trace`

Signal fixture export:

`python frp_prototype_v0_9_6.py --export-signal-fixture`

Verilog testbench scaffold export:

`python frp_prototype_v0_9_6.py --export-verilog-testbench`

Benchmark matrix export:

`python frp_prototype_v0_9_6.py --export-benchmark-matrix`

## Structured Output Schema

`frp.structured_output.v0.9.6`

## M4 Export Schemas

`frp.m4.hdl_trace.v0.9.6`

`frp.m4.vcd_trace.v0.9.6`

`frp.m4.signal_fixture.v0.9.6`

`frp.m4.verilog_testbench_scaffold.v0.9.6`

## GitHub Actions Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`3d0963b`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M4 HDL Trace and Testbench.

## M4 Workflow Validation

Workflow:

`FRP M4 HDL Trace and Testbench`

Observed result:

`PASS`

Validated stages:

- compile FRP v0.9.6 prototype;

- generate M4 JSON artifacts;

- validate M4 schemas and invariants;

- validate M4 documentation markers.

## M4 Signal Groups

Validated M4 signal groups:

- ternary cell state;

- phase state Q16;

- scheduler state;

- transition routing counters;

- stability telemetry Q16;

- phase-order telemetry Q16.

## Candidate Invariants

FRP v0.9.6 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Documentation Added

M4 documentation file:

- `docs/m4_hdl_trace_testbench.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_6.md`;

- `TEST_REPORT_v0_9_6.md`.

## M4 Technical Position

FRP v0.9.6 extends the M3 benchmark and hardware-facing signal mapping layer into HDL trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

The release provides machine-readable M4 artifacts for HDL-facing workflow validation and processor testbench preparation.

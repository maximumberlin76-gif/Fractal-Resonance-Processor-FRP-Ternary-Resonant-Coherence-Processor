# FRP v0.9.6 Test Report

## Release Layer

Fractal Resonance Processor (FRP) v0.9.6

M4 — HDL Trace Export and Testbench Scaffold

## Main Prototype

`frp_prototype_v0_9_6.py`

## Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`3d0963b`

## Validated Workflows

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M4 HDL Trace and Testbench.

## M4 Workflow

Workflow:

`FRP M4 HDL Trace and Testbench`

Observed result:

`PASS`

Validated workflow stages:

- compile FRP v0.9.6 prototype;

- generate M4 JSON artifacts;

- validate M4 schemas and invariants;

- validate M4 documentation markers.

## Validated M4 Export Layers

HDL trace export:

`frp.m4.hdl_trace.v0.9.6`

VCD-style trace export:

`frp.m4.vcd_trace.v0.9.6`

Signal fixture export:

`frp.m4.signal_fixture.v0.9.6`

Verilog testbench scaffold export:

`frp.m4.verilog_testbench_scaffold.v0.9.6`

## Validated Commands

Structured demo output:

`python frp_prototype_v0_9_6.py --mode demo --output json`

Self-test output:

`python frp_prototype_v0_9_6.py --mode self-test --output json`

Benchmark matrix output:

`python frp_prototype_v0_9_6.py --mode benchmark`

Benchmark matrix export:

`python frp_prototype_v0_9_6.py --export-benchmark-matrix`

HDL trace export:

`python frp_prototype_v0_9_6.py --export-hdl-trace`

VCD-style trace export:

`python frp_prototype_v0_9_6.py --export-vcd-trace`

Signal fixture export:

`python frp_prototype_v0_9_6.py --export-signal-fixture`

Verilog testbench scaffold export:

`python frp_prototype_v0_9_6.py --export-verilog-testbench`

## Candidate Invariants

Validated candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## M4 Artifact Validation

Validated generated artifact classes:

- structured JSON output;

- benchmark matrix export;

- HDL trace export;

- VCD-style trace export;

- signal fixture export;

- Verilog testbench scaffold export.

## Signal Validation

Validated M4 signal groups:

- ternary cell state;

- phase state Q16;

- scheduler state;

- transition routing counters;

- stability telemetry Q16;

- phase-order telemetry Q16.

## Documentation Validation

Validated documentation file:

`docs/m4_hdl_trace_testbench.md`

Validated documentation markers:

`FRP v0.9.6`

`M4 HDL Trace Export and Testbench Scaffold`

`frp.m4.hdl_trace.v0.9.6`

`frp.m4.vcd_trace.v0.9.6`

`frp.m4.signal_fixture.v0.9.6`

`frp.m4.verilog_testbench_scaffold.v0.9.6`

## Final Result

`PASS`

FRP v0.9.6 M4 HDL Trace Export and Testbench Scaffold passed GitHub Actions hardware-backed CI validation.

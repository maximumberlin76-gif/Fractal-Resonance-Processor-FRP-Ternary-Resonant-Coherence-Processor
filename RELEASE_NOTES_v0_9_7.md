# FRP v0.9.7 Release Notes

## Release Layer

Fractal Resonance Processor (FRP) v0.9.7

M5 — RTL Interface Contract and Assertion Harness

## Main Executable Reference File

`frp_prototype_v0_9_7.py`

## Release Scope

FRP v0.9.7 establishes the M5 RTL Interface Contract and Assertion Harness layer.

This release extends the M4 HDL trace and testbench scaffold layer into RTL-facing signal contract definition, deterministic interface records, assertion target mapping, RTL signal binding, and machine-readable assertion harness preparation.

## M5 Export Layers

FRP v0.9.7 defines the following M5 export layers:

- `rtl_interface_contract`;

- `assertion_manifest`;

- `rtl_signal_binding`;

- `assertion_harness_scaffold`.

## M5 Export Commands

RTL interface contract export:

`python frp_prototype_v0_9_7.py --export-rtl-interface-contract`

Assertion manifest export:

`python frp_prototype_v0_9_7.py --export-assertion-manifest`

RTL signal binding export:

`python frp_prototype_v0_9_7.py --export-rtl-signal-binding`

Assertion harness scaffold export:

`python frp_prototype_v0_9_7.py --export-assertion-harness`

Benchmark matrix export:

`python frp_prototype_v0_9_7.py --export-benchmark-matrix`

## Structured Output Schema

`frp.structured_output.v0.9.7`

## M5 Export Schemas

`frp.m5.rtl_interface_contract.v0.9.7`

`frp.m5.assertion_manifest.v0.9.7`

`frp.m5.rtl_signal_binding.v0.9.7`

`frp.m5.assertion_harness_scaffold.v0.9.7`

## GitHub Actions Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`5857131`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M5 RTL Interface and Assertion Harness.

## M5 Workflow Validation

Workflow:

`FRP M5 RTL Interface and Assertion Harness`

Observed result:

`PASS`

Validated stages:

- compile FRP v0.9.7 executable reference file;

- generate M5 JSON artifacts;

- validate M5 schemas and invariants;

- validate M5 documentation markers.

## RTL Interface Groups

Validated RTL interface groups:

- clock and reset;

- scheduler control;

- ternary cell state;

- phase telemetry Q16;

- transition routing counters;

- stability telemetry Q16;

- phase-order telemetry Q16;

- benchmark invariant outputs.

## Assertion Targets

Validated assertion targets:

- `A_DIRECT_EVENTS_ZERO`;

- `A_MATCH_EQUALS_ONE`;

- `A_C_MINUS_P_POSITIVE`;

- `A_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION`;

- `A_TICKS_RECORDED_EQUALS_STEPS`;

- `A_SCHEDULER_COUNTS_SUM_EQUALS_STEPS`.

## Candidate Invariants

FRP v0.9.7 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## Documentation Added

M5 documentation file:

- `docs/m5_rtl_interface_assertion_harness.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_7.md`;

- `TEST_REPORT_v0_9_7.md`.

## M5 Technical Position

FRP v0.9.7 extends the M4 HDL trace and testbench scaffold layer into RTL interface contract definition, assertion manifest export, RTL signal binding, and assertion harness scaffold generation.

The release provides machine-readable M5 artifacts for RTL-facing interface validation, assertion mapping, signal binding, and processor assertion harness preparation.

# FRP v0.9.7 Test Report

## Release Layer

Fractal Resonance Processor (FRP) v0.9.7

M5 — RTL Interface Contract and Assertion Harness

## Main Executable Reference File

`frp_prototype_v0_9_7.py`

## Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`5857131`

## Validated Workflows

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M5 RTL Interface and Assertion Harness.

## M5 Workflow

Workflow:

`FRP M5 RTL Interface and Assertion Harness`

Observed result:

`PASS`

Validated workflow stages:

- compile FRP v0.9.7 executable reference file;

- generate M5 JSON artifacts;

- validate M5 schemas and invariants;

- validate M5 documentation markers.

## Validated M5 Export Layers

RTL interface contract export:

`frp.m5.rtl_interface_contract.v0.9.7`

Assertion manifest export:

`frp.m5.assertion_manifest.v0.9.7`

RTL signal binding export:

`frp.m5.rtl_signal_binding.v0.9.7`

Assertion harness scaffold export:

`frp.m5.assertion_harness_scaffold.v0.9.7`

## Validated Commands

Structured demo output:

`python frp_prototype_v0_9_7.py --mode demo --output json`

Self-test output:

`python frp_prototype_v0_9_7.py --mode self-test --output json`

Benchmark matrix output:

`python frp_prototype_v0_9_7.py --mode benchmark`

Benchmark matrix export:

`python frp_prototype_v0_9_7.py --export-benchmark-matrix`

RTL interface contract export:

`python frp_prototype_v0_9_7.py --export-rtl-interface-contract`

Assertion manifest export:

`python frp_prototype_v0_9_7.py --export-assertion-manifest`

RTL signal binding export:

`python frp_prototype_v0_9_7.py --export-rtl-signal-binding`

Assertion harness scaffold export:

`python frp_prototype_v0_9_7.py --export-assertion-harness`

## Candidate Invariants

Validated candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

## M5 Artifact Validation

Validated generated artifact classes:

- structured JSON output;

- benchmark matrix export;

- RTL interface contract export;

- assertion manifest export;

- RTL signal binding export;

- assertion harness scaffold export.

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

## Documentation Validation

Validated documentation file:

`docs/m5_rtl_interface_assertion_harness.md`

Validated documentation markers:

`FRP v0.9.7`

`M5 RTL Interface Contract and Assertion Harness`

`frp.m5.rtl_interface_contract.v0.9.7`

`frp.m5.assertion_manifest.v0.9.7`

`frp.m5.rtl_signal_binding.v0.9.7`

`frp.m5.assertion_harness_scaffold.v0.9.7`

## Final Result

`PASS`

FRP v0.9.7 M5 RTL Interface Contract and Assertion Harness passed GitHub Actions hardware-backed CI validation.

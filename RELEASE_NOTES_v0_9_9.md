# FRP v0.9.9 Release Notes

## Release Layer

Fractal Resonance Processor (FRP) v0.9.9

M7 — FPGA Synthesis Package and Timing Constraint Scaffold

## Main Executable Reference File

`frp_prototype_v0_9_9.py`

## Release Scope

FRP v0.9.9 establishes the M7 FPGA Synthesis Package and Timing Constraint Scaffold layer.

This release extends the M6 formal verification hooks and equivalence scaffold layer into FPGA-oriented synthesis metadata, timing constraint preparation, resource estimate mapping, and implementation handoff scaffold generation.

## M7 Export Layers

FRP v0.9.9 defines the following M7 export layers:

- `fpga_synthesis_manifest`;

- `timing_constraint_profile`;

- `resource_estimate_map`;

- `implementation_handoff_scaffold`.

## M7 Export Commands

FPGA synthesis manifest export:

`python frp_prototype_v0_9_9.py --export-fpga-synthesis-manifest`

Timing constraint profile export:

`python frp_prototype_v0_9_9.py --export-timing-constraint-profile`

Resource estimate map export:

`python frp_prototype_v0_9_9.py --export-resource-estimate-map`

Implementation handoff scaffold export:

`python frp_prototype_v0_9_9.py --export-implementation-handoff`

Benchmark matrix export:

`python frp_prototype_v0_9_9.py --export-benchmark-matrix`

## Structured Output Schema

`frp.structured_output.v0.9.9`

## M7 Export Schemas

`frp.m7.fpga_synthesis_manifest.v0.9.9`

`frp.m7.timing_constraint_profile.v0.9.9`

`frp.m7.resource_estimate_map.v0.9.9`

`frp.m7.implementation_handoff_scaffold.v0.9.9`

## GitHub Actions Validation

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`dcf54f2`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M7 FPGA Synthesis and Timing Scaffold.

## M7 Workflow Validation

Workflow:

`FRP M7 FPGA Synthesis and Timing Scaffold`

Observed result:

`PASS`

Validated stages:

- compile FRP v0.9.9 executable reference file;

- generate M7 JSON artifacts;

- validate M7 schemas and invariants;

- validate M7 documentation markers.

## FPGA Synthesis Manifest

Validated FPGA synthesis manifest targets:

- top module name;

- clock domain definition;

- reset domain definition;

- RTL signal groups;

- assertion groups;

- formal property groups;

- equivalence trace groups;

- synthesis source groups;

- generated artifact references.

Validated top module:

`frp_top_v0_9_9`

## Timing Constraint Profile

Validated timing constraint targets:

- `T_PRIMARY_CLOCK_PERIOD`;

- `T_RESET_RELEASE_WINDOW`;

- `T_BOUNDED_STEP_COUNTER`;

- `T_SCHEDULER_STATE`;

- `T_PHASE_TELEMETRY_Q16`;

- `T_STABILITY_TELEMETRY_Q16`;

- `T_TRANSITION_COUNTERS`;

- `T_EQUIVALENCE_TRACE_SAMPLING`.

## Resource Estimate Map

Validated resource estimate categories:

- `R_TERNARY_CELL_STATE_REGISTERS`;

- `R_PHASE_Q16_REGISTERS`;

- `R_SCHEDULER_REGISTERS`;

- `R_TRANSITION_COUNTER_REGISTERS`;

- `R_STABILITY_TELEMETRY_REGISTERS`;

- `R_PHASE_ORDER_TELEMETRY_REGISTERS`;

- `R_ASSERTION_COMPARISON_LOGIC`;

- `R_EQUIVALENCE_TRACE_COMPARISON_LOGIC`;

- `R_BOUNDED_STEP_COUNTER_LOGIC`;

- `R_FORMAL_HARNESS_SUPPORT_LOGIC`.

## Implementation Handoff Scaffold

Validated implementation handoff scaffold sections:

- project metadata;

- top module target;

- source file groups;

- constraint file groups;

- timing profile references;

- resource estimate references;

- assertion manifest references;

- formal property references;

- equivalence trace references;

- validation checklist.

## Candidate Invariants

FRP v0.9.9 preserves the following candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

`neutralized_conflicts tracked`

## Documentation Added

M7 documentation file:

- `docs/m7_fpga_synthesis_timing.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_9.md`;

- `TEST_REPORT_v0_9_9.md`.

## M7 Technical Position

FRP v0.9.9 extends the M6 formal verification hooks and equivalence scaffold layer into FPGA synthesis manifest export, timing constraint profile export, resource estimate map export, and implementation handoff scaffold generation.

The release provides machine-readable M7 artifacts for FPGA synthesis package preparation, timing constraint preparation, resource estimate mapping, and implementation handoff preparation.

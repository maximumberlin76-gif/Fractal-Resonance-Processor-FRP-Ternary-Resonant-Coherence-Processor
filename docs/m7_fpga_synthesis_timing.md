# FRP v0.9.9 — M7 FPGA Synthesis Package and Timing Constraint Scaffold

## Milestone Scope

FRP v0.9.9 establishes the M7 FPGA Synthesis Package and Timing Constraint Scaffold layer.

This milestone extends the M6 formal verification hooks and equivalence scaffold layer into FPGA-oriented synthesis metadata, timing constraint preparation, resource estimate mapping, and implementation handoff scaffold generation.

## M7 Position in the FRP Roadmap

M1 established the executable FRP reference layer.

M2 established structured output and machine-readable validation.

M3 established benchmark export and hardware-facing signal mapping.

M4 established HDL trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

M5 established RTL interface contract, assertion manifest export, RTL signal binding, and assertion harness scaffold generation.

M6 established formal property records, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.

M7 establishes FPGA synthesis package and timing constraint scaffold preparation.

## M7 Core Artifacts

M7 introduces the following artifact targets:

- `fpga_synthesis_manifest`;

- `timing_constraint_profile`;

- `resource_estimate_map`;

- `implementation_handoff_scaffold`.

## Planned M7 Executable Reference File

Main executable reference file target:

`frp_prototype_v0_9_9.py`

## Planned M7 Export Commands

FPGA synthesis manifest export:

`python frp_prototype_v0_9_9.py --export-fpga-synthesis-manifest`

Timing constraint profile export:

`python frp_prototype_v0_9_9.py --export-timing-constraint-profile`

Resource estimate map export:

`python frp_prototype_v0_9_9.py --export-resource-estimate-map`

Implementation handoff scaffold export:

`python frp_prototype_v0_9_9.py --export-implementation-handoff`

## Planned M7 Schemas

M7 defines the following schema targets:

`frp.m7.fpga_synthesis_manifest.v0.9.9`

`frp.m7.timing_constraint_profile.v0.9.9`

`frp.m7.resource_estimate_map.v0.9.9`

`frp.m7.implementation_handoff_scaffold.v0.9.9`

## FPGA Synthesis Manifest

The FPGA synthesis manifest defines the synthesis-facing package metadata for FRP implementation preparation.

Primary synthesis manifest targets:

- top module name;

- clock domain definition;

- reset domain definition;

- RTL signal groups;

- assertion groups;

- formal property groups;

- equivalence trace groups;

- synthesis source groups;

- generated artifact references.

## Timing Constraint Profile

The timing constraint profile defines deterministic timing records for FPGA-oriented implementation preparation.

Primary timing constraint targets:

- primary clock period;

- reset release window;

- bounded step counter timing;

- scheduler state timing;

- phase telemetry Q16 timing;

- stability telemetry Q16 timing;

- transition counter timing;

- equivalence trace sampling timing.

## Resource Estimate Map

The resource estimate map defines structural resource categories for FPGA-oriented synthesis planning.

Primary resource estimate categories:

- ternary cell state registers;

- phase Q16 registers;

- scheduler registers;

- transition counter registers;

- stability telemetry registers;

- phase-order telemetry registers;

- assertion comparison logic;

- equivalence trace comparison logic;

- bounded-step counter logic;

- formal harness support logic.

## Implementation Handoff Scaffold

The implementation handoff scaffold provides a generated FPGA-oriented handoff structure.

The scaffold includes:

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

## Candidate M7 Validation Targets

M7 validation targets:

- generated FPGA synthesis manifest contains required synthesis package records;

- generated timing constraint profile contains deterministic clock, reset, scheduler, telemetry, counter, and trace timing records;

- generated resource estimate map contains required structural resource categories;

- generated implementation handoff scaffold contains project metadata, top module target, source groups, constraint groups, timing references, resource references, assertion references, formal property references, equivalence trace references, and validation checklist;

- generated artifacts preserve candidate invariant markers;

- GitHub Actions validates M7 export schemas and generated artifact structure.

## M7 Technical Position

FRP v0.9.9 extends the M6 formal verification hooks and equivalence scaffold layer into FPGA synthesis manifest export, timing constraint profile export, resource estimate map export, and implementation handoff scaffold generation.

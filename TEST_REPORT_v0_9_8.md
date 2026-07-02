# FRP v0.9.8 Test Report

## Release Layer

Fractal Resonance Processor (FRP) v0.9.8

M6 — Formal Verification Hooks and Equivalence Scaffold

## Main Executable Reference File

`frp_prototype_v0_9_8.py`

## Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`8c9fdd3`

## Validated Workflows

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M6 Formal Verification and Equivalence Scaffold.

## M6 Workflow

Workflow:

`FRP M6 Formal Verification and Equivalence Scaffold`

Observed result:

`PASS`

Validated workflow stages:

- compile FRP v0.9.8 executable reference file;

- generate M6 JSON artifacts;

- validate M6 schemas and invariants;

- validate M6 documentation markers.

## Validated M6 Export Layers

Formal property set export:

`frp.m6.formal_property_set.v0.9.8`

Equivalence trace map export:

`frp.m6.equivalence_trace_map.v0.9.8`

Bounded verification config export:

`frp.m6.bounded_verification_config.v0.9.8`

Formal harness scaffold export:

`frp.m6.formal_harness_scaffold.v0.9.8`

## Validated Commands

Structured demo output:

`python frp_prototype_v0_9_8.py --mode demo --output json`

Self-test output:

`python frp_prototype_v0_9_8.py --mode self-test --output json`

Benchmark matrix output:

`python frp_prototype_v0_9_8.py --mode benchmark`

Benchmark matrix export:

`python frp_prototype_v0_9_8.py --export-benchmark-matrix`

Formal property set export:

`python frp_prototype_v0_9_8.py --export-formal-property-set`

Equivalence trace map export:

`python frp_prototype_v0_9_8.py --export-equivalence-trace-map`

Bounded verification config export:

`python frp_prototype_v0_9_8.py --export-bounded-verification-config`

Formal harness scaffold export:

`python frp_prototype_v0_9_8.py --export-formal-harness`

## Candidate Invariants

Validated candidate invariant markers:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

`neutral-routed transition path is preserved`

## Formal Property Targets

Validated formal property targets:

- `P_DIRECT_EVENTS_ZERO`;

- `P_MATCH_EQUALS_ONE`;

- `P_C_MINUS_P_POSITIVE`;

- `P_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION`;

- `P_TICKS_RECORDED_EQUALS_STEPS`;

- `P_SCHEDULER_COUNTS_SUM_EQUALS_STEPS`;

- `P_NEUTRAL_ROUTED_TRANSITION_PATH`.

## Equivalence Trace Mapping

Validated equivalence trace mappings:

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

Validated bounded verification config targets:

- cell count;

- step count;

- seed;

- scheduler mode;

- transition fraction Q16;

- gamma Q16;

- trace comparison depth;

- property identifiers;

- equivalence fields.

## Formal Harness Scaffold

Validated formal harness scaffold sections:

- module declaration;

- clock and reset structure;

- bounded-step counter;

- signal declarations;

- formal property placeholders;

- assumption placeholders;

- cover placeholders;

- equivalence mapping placeholders;

- final status reporting section.

## Documentation Validation

Validated documentation file:

`docs/m6_formal_verification_equivalence.md`

Validated documentation markers:

`FRP v0.9.8`

`M6 Formal Verification Hooks and Equivalence Scaffold`

`frp.m6.formal_property_set.v0.9.8`

`frp.m6.equivalence_trace_map.v0.9.8`

`frp.m6.bounded_verification_config.v0.9.8`

`frp.m6.formal_harness_scaffold.v0.9.8`

## Final Result

`PASS`

FRP v0.9.8 M6 Formal Verification Hooks and Equivalence Scaffold passed GitHub Actions hardware-backed CI validation.

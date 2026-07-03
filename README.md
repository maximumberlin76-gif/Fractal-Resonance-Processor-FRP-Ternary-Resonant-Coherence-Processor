# Fractal Resonance Processor (FRP)

[![FRP M10 Silicon Production and Tapeout Readiness](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m10-silicon-production-tapeout.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m10-silicon-production-tapeout.yml)

[![FRP M9 Silicon and Heterogeneous Architecture](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m9-silicon-architecture.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m9-silicon-architecture.yml)

[![FRP M8 Production Release Package](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m8-production-release.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m8-production-release.yml)

[![FRP M7 FPGA Synthesis and Timing Scaffold](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m7-fpga-synthesis.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m7-fpga-synthesis.yml)

[![FRP M6 Formal Verification and Equivalence Scaffold](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m6-formal-verification.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m6-formal-verification.yml)

[![FRP M5 RTL Interface and Assertion Harness](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m5-rtl-assertion-harness.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m5-rtl-assertion-harness.yml)

[![FRP M4 HDL Trace and Testbench](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m4-hdl-trace.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m4-hdl-trace.yml)

[![FRP M3 Benchmark and Signal Map](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m3-benchmark-signal-map.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-m3-benchmark-signal-map.yml)

[![FRP Self Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-self-test.yml)

[![FRP Benchmark Smoke Test](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-benchmark-smoke.yml)

[![FRP Structured Output](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-structured-output.yml/badge.svg)](https://github.com/maximumberlin76-gif/Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor/actions/workflows/frp-structured-output.yml)

**Ternary Resonant Coherence Processor — Structured Output Prototype**

## Current Architecture Layer

**Current version:** `FRP v1.2.0`

**Current milestone:** `M10 — Silicon Production and Tapeout Readiness Package`

**Main executable reference file:** `frp_prototype_v1_2_0.py`

FRP v1.2.0 establishes the M10 Silicon Production and Tapeout Readiness Package layer of the Fractal Resonance Processor reference architecture.

This release extends the validated FRP v1.1.0 Silicon and Heterogeneous Implementation Architecture layer into a production-readiness and tapeout-readiness architecture package.

The M10 layer defines the structured readiness bridge from silicon-facing architecture mapping toward production planning, tapeout package organization, implementation freeze control, verification closure mapping, constraint readiness, timing readiness, register interface readiness, test readiness, and release handoff structure.

## Inherited Architecture Boundary

FRP v1.2.0 inherits the validated v1.1.0 architecture boundary:

`FRP v1.1.0 — M9 Silicon and Heterogeneous Implementation Architecture`

Inherited executable reference file:

`frp_prototype_v1_1_0.py`

Inherited validation index:

`FRP_VALIDATION_INDEX_v1_1_0.md`

Inherited release notes:

`RELEASE_NOTES_v1_1_0.md`

Inherited test report:

`TEST_REPORT_v1_1_0.md`

## M10 Export Layers

FRP v1.2.0 defines nine M10 export layers:

- `silicon_production_readiness_manifest`;

- `tapeout_readiness_checklist`;

- `rtl_freeze_map`;

- `verification_closure_matrix`;

- `timing_constraint_readiness_map`;

- `memory_register_production_map`;

- `test_observability_readiness_plan`;

- `implementation_signoff_package_index`;

- `production_handoff_manifest`.

## M10 Export Commands

Silicon production readiness manifest export:

`python frp_prototype_v1_2_0.py --export-silicon-production-readiness-manifest`

Tapeout readiness checklist export:

`python frp_prototype_v1_2_0.py --export-tapeout-readiness-checklist`

RTL freeze map export:

`python frp_prototype_v1_2_0.py --export-rtl-freeze-map`

Verification closure matrix export:

`python frp_prototype_v1_2_0.py --export-verification-closure-matrix`

Timing and constraint readiness map export:

`python frp_prototype_v1_2_0.py --export-timing-constraint-readiness-map`

Memory/register production map export:

`python frp_prototype_v1_2_0.py --export-memory-register-production-map`

Test and observability readiness plan export:

`python frp_prototype_v1_2_0.py --export-test-observability-readiness-plan`

Implementation signoff package index export:

`python frp_prototype_v1_2_0.py --export-implementation-signoff-package-index`

Production handoff manifest export:

`python frp_prototype_v1_2_0.py --export-production-handoff-manifest`

Benchmark matrix export:

`python frp_prototype_v1_2_0.py --export-benchmark-matrix`

## Stable v1.2.0 Schemas

Structured output schema:

`frp.structured_output.v1.2.0`

Benchmark matrix schema:

`frp.m3.benchmark_matrix.v1.2.0`

M10 export schemas:

`frp.m10.silicon_production_readiness_manifest.v1.2.0`

`frp.m10.tapeout_readiness_checklist.v1.2.0`

`frp.m10.rtl_freeze_map.v1.2.0`

`frp.m10.verification_closure_matrix.v1.2.0`

`frp.m10.timing_constraint_readiness_map.v1.2.0`

`frp.m10.memory_register_production_map.v1.2.0`

`frp.m10.test_observability_readiness_plan.v1.2.0`

`frp.m10.implementation_signoff_package_index.v1.2.0`

`frp.m10.production_handoff_manifest.v1.2.0`

## M10 Validation Status

Validation status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`ae161cc`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M10 Silicon Production and Tapeout Readiness.

## M10 Readiness Domains

FRP v1.2.0 validates the following readiness domains:

- silicon production readiness manifest;

- tapeout readiness checklist;

- RTL freeze map;

- verification closure matrix;

- timing and constraint readiness map;

- memory/register production map;

- test and observability readiness plan;

- implementation signoff package index;

- production handoff manifest.

## M10 Production Readiness Files

M10 documentation file:

- `docs/m10_silicon_production_tapeout_readiness.md`.

M10 executable reference file:

- `frp_prototype_v1_2_0.py`.

M10 workflow file:

- `.github/workflows/frp-m10-silicon-production-tapeout.yml`.

M10 release-facing files:

- `RELEASE_NOTES_v1_2_0.md`;

- `TEST_REPORT_v1_2_0.md`;

- `FRP_VALIDATION_INDEX_v1_2_0.md`;

- `CHANGELOG.md`.

## Architecture Progression

FRP v1.2.0 preserves the validated architecture progression:

`production reference prototype`

↓  

`stable production release package`

↓  

`stable interface freeze`

↓  

`silicon interface model`

↓  

`heterogeneous implementation map`

↓  

`compute fabric mapping`

↓  

`memory/register interface map`

↓  

`clock/reset domain map`

↓  

`signal pipeline architecture`

↓  

`accelerator integration profile`

↓  

`FPGA-to-silicon migration path`

↓  

`silicon production readiness manifest`

↓  

`tapeout readiness checklist`

↓  

`RTL freeze map`

↓  

`verification closure matrix`

↓  

`timing and constraint readiness map`

↓  

`memory/register production map`

↓  

`test and observability readiness plan`

↓  

`implementation signoff package index`

↓  

`production handoff manifest`

## Next Architecture Layer

Next planned architecture layer:

`FRP v1.3.0 — M11 Production Integration and External Implementation Handoff`

## Previous Architecture Layer — FRP v1.1.0 / M9

**Current version:** `FRP v1.1.0`

**Current milestone:** `M9 — Silicon and Heterogeneous Implementation Architecture`

**Main executable reference file:** `frp_prototype_v1_1_0.py`

FRP v1.1.0 establishes the M9 Silicon and Heterogeneous Implementation Architecture layer of the Fractal Resonance Processor reference architecture.

This release extends the stable FRP v1.0.0 production reference prototype into a silicon-facing and heterogeneous implementation architecture layer.

The M9 layer defines the architecture bridge from stable production release package to silicon interface modeling, heterogeneous compute mapping, signal pipeline organization, memory/register interface mapping, clock/reset domain mapping, accelerator integration, and FPGA-to-silicon migration planning.

## Inherited Production Boundary

FRP v1.1.0 inherits the stable v1.0.0 production release boundary:

`FRP v1.0.0 — M8 Production Release Package and Stable Interface Freeze`

Inherited executable reference file:

`frp_prototype_v1_0_0.py`

Inherited validation index:

`FRP_VALIDATION_INDEX_v1_0_0.md`

Inherited production release manifest:

`FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md`

## M9 Export Layers

FRP v1.1.0 defines eight M9 export layers:

- `silicon_interface_model`;

- `heterogeneous_implementation_map`;

- `compute_fabric_mapping`;

- `memory_register_interface_map`;

- `clock_reset_domain_map`;

- `signal_pipeline_architecture`;

- `accelerator_integration_profile`;

- `fpga_to_silicon_migration_path`.

## M9 Export Commands

Silicon interface model export:

`python frp_prototype_v1_1_0.py --export-silicon-interface-model`

Heterogeneous implementation map export:

`python frp_prototype_v1_1_0.py --export-heterogeneous-implementation-map`

Compute fabric mapping export:

`python frp_prototype_v1_1_0.py --export-compute-fabric-mapping`

Memory/register interface map export:

`python frp_prototype_v1_1_0.py --export-memory-register-interface-map`

Clock/reset domain map export:

`python frp_prototype_v1_1_0.py --export-clock-reset-domain-map`

Signal pipeline architecture export:

`python frp_prototype_v1_1_0.py --export-signal-pipeline-architecture`

Accelerator integration profile export:

`python frp_prototype_v1_1_0.py --export-accelerator-integration-profile`

FPGA-to-silicon migration path export:

`python frp_prototype_v1_1_0.py --export-fpga-to-silicon-migration-path`

Benchmark matrix export:

`python frp_prototype_v1_1_0.py --export-benchmark-matrix`

## Stable v1.1.0 Schemas

Structured output schema:

`frp.structured_output.v1.1.0`

Benchmark matrix schema:

`frp.m3.benchmark_matrix.v1.1.0`

M9 export schemas:

`frp.m9.silicon_interface_model.v1.1.0`

`frp.m9.heterogeneous_implementation_map.v1.1.0`

`frp.m9.compute_fabric_mapping.v1.1.0`

`frp.m9.memory_register_interface_map.v1.1.0`

`frp.m9.clock_reset_domain_map.v1.1.0`

`frp.m9.signal_pipeline_architecture.v1.1.0`

`frp.m9.accelerator_integration_profile.v1.1.0`

`frp.m9.fpga_to_silicon_migration_path.v1.1.0`

## M9 Validation Status

Validation status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated commit:

`4050e8c`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M9 Silicon and Heterogeneous Architecture.

## M9 Architecture Domains

FRP v1.1.0 validates the following architecture domains:

- silicon interface model;

- heterogeneous implementation map;

- compute fabric mapping;

- memory/register interface map;

- clock/reset domain map;

- signal pipeline architecture;

- accelerator integration profile;

- FPGA-to-silicon migration path.

## M9 Production Architecture Files

M9 documentation file:

- `docs/m9_silicon_heterogeneous_architecture.md`.

M9 executable reference file:

- `frp_prototype_v1_1_0.py`.

M9 workflow file:

- `.github/workflows/frp-m9-silicon-architecture.yml`.

M9 release-facing files:

- `RELEASE_NOTES_v1_1_0.md`;

- `TEST_REPORT_v1_1_0.md`;

- `FRP_VALIDATION_INDEX_v1_1_0.md`;

- `CHANGELOG.md`.

## Architecture Progression

FRP v1.1.0 preserves the validated architecture progression:

`production reference prototype`

↓  

`stable production release package`

↓  

`stable interface freeze`

↓  

`silicon interface model`

↓  

`heterogeneous implementation map`

↓  

`compute fabric mapping`

↓  

`memory/register interface map`

↓  

`clock/reset domain map`

↓  

`signal pipeline architecture`

↓  

`accelerator integration profile`

↓  

`FPGA-to-silicon migration path`

## Next Architecture Layer

Next planned architecture layer:

`FRP v1.2.0 — M10 Silicon Production and Tapeout Readiness Package`

## Previous Production Release Layer — FRP v1.0.0 / M8

**Current version:** `FRP v1.0.0`

**Current milestone:** `M8 — Production Release Package and Stable Interface Freeze`

**Main executable reference file:** `frp_prototype_v1_0_0.py`

FRP v1.0.0 establishes the M8 Production Release Package and Stable Interface Freeze layer.

This release consolidates the validated M3 through M7 milestone stack into the first stable production release package of the Fractal Resonance Processor reference architecture.

The v1.0.0 release freezes the public interface boundary for the current FRP release line and prepares the next architecture layer:

`M9 — Silicon and Heterogeneous Implementation Architecture`

## M8 Export Layers

FRP v1.0.0 defines four M8 export layers:

- `production_release_manifest`;

- `stable_interface_contract`;

- `artifact_package_index`;

- `release_freeze_checklist`.

## M8 Export Commands

Production release manifest export:

`python frp_prototype_v1_0_0.py --export-production-release-manifest`

Stable interface contract export:

`python frp_prototype_v1_0_0.py --export-stable-interface-contract`

Artifact package index export:

`python frp_prototype_v1_0_0.py --export-artifact-package-index`

Release freeze checklist export:

`python frp_prototype_v1_0_0.py --export-release-freeze-checklist`

Benchmark matrix export:

`python frp_prototype_v1_0_0.py --export-benchmark-matrix`

## M8 Schemas

Structured output schema:

`frp.structured_output.v1.0.0`

Benchmark matrix schema:

`frp.m3.benchmark_matrix.v1.0.0`

Production release manifest schema:

`frp.m8.production_release_manifest.v1.0.0`

Stable interface contract schema:

`frp.m8.stable_interface_contract.v1.0.0`

Artifact package index schema:

`frp.m8.artifact_package_index.v1.0.0`

Release freeze checklist schema:

`frp.m8.release_freeze_checklist.v1.0.0`

## M8 Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M8 Production Release Package.

Validated M8 workflow stages:

- compile FRP v1.0.0 executable reference file;

- generate M8 JSON artifacts;

- validate M8 schemas and invariants;

- validate M8 documentation markers.

## Stable v1.0.0 CLI Command Set

Stable v1.0.0 commands:

- `--mode demo --output json`;

- `--mode self-test --output json`;

- `--mode benchmark`;

- `--export-benchmark-matrix`;

- `--export-production-release-manifest`;

- `--export-stable-interface-contract`;

- `--export-artifact-package-index`;

- `--export-release-freeze-checklist`.

## Stable v1.0.0 Artifact Layers

Stable v1.0.0 artifact layers:

- `benchmark_matrix`;

- `hardware_signal_mapping`;

- `hdl_trace`;

- `vcd_trace`;

- `signal_fixture`;

- `verilog_testbench_scaffold`;

- `rtl_interface_contract`;

- `assertion_manifest`;

- `rtl_signal_binding`;

- `assertion_harness_scaffold`;

- `formal_property_set`;

- `equivalence_trace_map`;

- `bounded_verification_config`;

- `formal_harness_scaffold`;

- `fpga_synthesis_manifest`;

- `timing_constraint_profile`;

- `resource_estimate_map`;

- `implementation_handoff_scaffold`;

- `production_release_manifest`;

- `stable_interface_contract`;

- `artifact_package_index`;

- `release_freeze_checklist`.

## M8 Production Release Files

M8 documentation file:

- `docs/m8_production_release_package.md`.

Release-facing files:

- `RELEASE_NOTES_v1_0_0.md`;

- `TEST_REPORT_v1_0_0.md`;

- `FRP_PRODUCTION_RELEASE_MANIFEST_v1_0_0.md`;

  - `FRP_VALIDATION_INDEX_v1_0_0.md`;

- `CHANGELOG.md`.

## Stable Interface Freeze

The v1.0.0 release freezes the following public interface categories:

- CLI command names;

- JSON schema identifiers;

- export artifact names;

- signal group names;

- invariant marker names;

- workflow names;

- documentation file paths;

- release file paths.

## Previous Release Layer — FRP v0.9.9 / M7

**Current version:** `FRP v0.9.9`

**Current milestone:** `M7 — FPGA Synthesis Package and Timing Constraint Scaffold`

**Main executable reference file:** `frp_prototype_v0_9_9.py`

FRP v0.9.9 establishes the M7 FPGA Synthesis Package and Timing Constraint Scaffold layer.

This release extends the M6 formal verification hooks and equivalence scaffold layer into FPGA-oriented synthesis metadata, timing constraint preparation, resource estimate mapping, and implementation handoff scaffold generation.

## M7 Export Layers

FRP v0.9.9 defines four M7 export layers:

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

## M7 Schemas

Structured output schema:

`frp.structured_output.v0.9.9`

FPGA synthesis manifest schema:

`frp.m7.fpga_synthesis_manifest.v0.9.9`

Timing constraint profile schema:

`frp.m7.timing_constraint_profile.v0.9.9`

Resource estimate map schema:

`frp.m7.resource_estimate_map.v0.9.9`

Implementation handoff scaffold schema:

`frp.m7.implementation_handoff_scaffold.v0.9.9`

## M7 Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M7 FPGA Synthesis and Timing Scaffold.

Validated M7 workflow stages:

- compile FRP v0.9.9 executable reference file;

- generate M7 JSON artifacts;

- validate M7 schemas and invariants;

- validate M7 documentation markers.

## M7 FPGA Synthesis Manifest

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

## M7 Timing Constraint Profile

Validated timing constraint targets:

- `T_PRIMARY_CLOCK_PERIOD`;

- `T_RESET_RELEASE_WINDOW`;

- `T_BOUNDED_STEP_COUNTER`;

- `T_SCHEDULER_STATE`;

- `T_PHASE_TELEMETRY_Q16`;

- `T_STABILITY_TELEMETRY_Q16`;

- `T_TRANSITION_COUNTERS`;

- `T_EQUIVALENCE_TRACE_SAMPLING`.

## M7 Resource Estimate Map

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

## M7 Documentation

M7 documentation file:

- `docs/m7_fpga_synthesis_timing.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_9.md`;

- `TEST_REPORT_v0_9_9.md`;

- `CHANGELOG.md`.

## Previous Release Layer — FRP v0.9.8 / M6

**Current version:** `FRP v0.9.8`

**Current milestone:** `M6 — Formal Verification Hooks and Equivalence Scaffold`

**Main executable reference file:** `frp_prototype_v0_9_8.py`

FRP v0.9.8 establishes the M6 Formal Verification Hooks and Equivalence Scaffold layer.

This release extends the M5 RTL interface contract and assertion harness layer into formal property records, equivalence trace mapping, bounded verification configuration, and formal harness scaffold generation.

## M6 Export Layers

FRP v0.9.8 defines four M6 export layers:

- `formal_property_set`;

- `equivalence_trace_map`;

- `bounded_verification_config`;

- `formal_harness_scaffold`.

## M6 Export Commands

Formal property set export:

`python frp_prototype_v0_9_8.py --export-formal-property-set`

Equivalence trace map export:

`python frp_prototype_v0_9_8.py --export-equivalence-trace-map`

Bounded verification config export:

`python frp_prototype_v0_9_8.py --export-bounded-verification-config`

Formal harness scaffold export:

`python frp_prototype_v0_9_8.py --export-formal-harness`

Benchmark matrix export:

`python frp_prototype_v0_9_8.py --export-benchmark-matrix`

## M6 Schemas

Structured output schema:

`frp.structured_output.v0.9.8`

Formal property set schema:

`frp.m6.formal_property_set.v0.9.8`

Equivalence trace map schema:

`frp.m6.equivalence_trace_map.v0.9.8`

Bounded verification config schema:

`frp.m6.bounded_verification_config.v0.9.8`

Formal harness scaffold schema:

`frp.m6.formal_harness_scaffold.v0.9.8`

## M6 Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M6 Formal Verification and Equivalence Scaffold.

Validated M6 workflow stages:

- compile FRP v0.9.8 executable reference file;

- generate M6 JSON artifacts;

- validate M6 schemas and invariants;

- validate M6 documentation markers.

## M6 Formal Property Targets

Validated formal property targets:

- `P_DIRECT_EVENTS_ZERO`;

- `P_MATCH_EQUALS_ONE`;

- `P_C_MINUS_P_POSITIVE`;

- `P_SWITCH_LOAD_WITHIN_TRANSITION_FRACTION`;

- `P_TICKS_RECORDED_EQUALS_STEPS`;

- `P_SCHEDULER_COUNTS_SUM_EQUALS_STEPS`;

- `P_NEUTRAL_ROUTED_TRANSITION_PATH`.

## M6 Equivalence Trace Mapping

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

## M6 Documentation

M6 documentation file:

- `docs/m6_formal_verification_equivalence.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_8.md`;

- `TEST_REPORT_v0_9_8.md`;

- `CHANGELOG.md`.

## Current Release Layer

**Current version:** `FRP v0.9.7`

**Current milestone:** `M5 — RTL Interface Contract and Assertion Harness`

**Main executable reference file:** `frp_prototype_v0_9_7.py`

FRP v0.9.7 establishes the M5 RTL Interface Contract and Assertion Harness layer.

This release extends the M4 HDL trace and testbench scaffold layer into RTL-facing signal contract definition, deterministic interface records, assertion target mapping, RTL signal binding, and machine-readable assertion harness preparation.

## M5 Export Layers

FRP v0.9.7 defines four M5 export layers:

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

## M5 Schemas

Structured output schema:

`frp.structured_output.v0.9.7`

RTL interface contract schema:

`frp.m5.rtl_interface_contract.v0.9.7`

Assertion manifest schema:

`frp.m5.assertion_manifest.v0.9.7`

RTL signal binding schema:

`frp.m5.rtl_signal_binding.v0.9.7`

Assertion harness scaffold schema:

`frp.m5.assertion_harness_scaffold.v0.9.7`

## M5 Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M5 RTL Interface and Assertion Harness.

Validated M5 workflow stages:

- compile FRP v0.9.7 executable reference file;

- generate M5 JSON artifacts;

- validate M5 schemas and invariants;

- validate M5 documentation markers.

## M5 Documentation

M5 documentation file:

- `docs/m5_rtl_interface_assertion_harness.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_7.md`;

- `TEST_REPORT_v0_9_7.md`;

- `CHANGELOG.md`.

## Previous Release Layer — FRP v0.9.6 / M4

**Current version:** `FRP v0.9.6`

**Current milestone:** `M4 — HDL Trace Export and Testbench Scaffold`

**Main prototype:** `frp_prototype_v0_9_6.py`

FRP v0.9.6 establishes the M4 HDL Trace Export and Testbench Scaffold layer.

This release extends the M3 benchmark and hardware-facing signal mapping layer into HDL-oriented trace export, VCD-style waveform preparation, signal fixture generation, and Verilog testbench scaffold generation.

## M4 Export Layers

FRP v0.9.6 defines four M4 export layers:

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

## M4 Schemas

Structured output schema:

`frp.structured_output.v0.9.6`

HDL trace schema:

`frp.m4.hdl_trace.v0.9.6`

VCD-style trace schema:

`frp.m4.vcd_trace.v0.9.6`

Signal fixture schema:

`frp.m4.signal_fixture.v0.9.6`

Verilog testbench scaffold schema:

`frp.m4.verilog_testbench_scaffold.v0.9.6`

## M4 Validation Status

Observed status:

`PASS`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated workflows:

- FRP Self Test;

- FRP Benchmark Smoke Test;

- FRP Structured Output;

- FRP M4 HDL Trace and Testbench.

Validated M4 workflow stages:

- compile FRP v0.9.6 prototype;

- generate M4 JSON artifacts;

- validate M4 schemas and invariants;

- validate M4 documentation markers.

## M4 Documentation

M4 documentation file:

- `docs/m4_hdl_trace_testbench.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_6.md`;

- `TEST_REPORT_v0_9_6.md`;

- `CHANGELOG.md`.

## Current Release Layer

**Current version:** `FRP v0.9.5`

**Current milestone:** `M3 — Benchmark Export and Hardware Signal Mapping`

**Main prototype:** `frp_prototype_v0_9_5.py`

FRP v0.9.5 extends the structured-output layer into benchmark export and hardware-facing signal mapping.

This release defines machine-readable benchmark matrices, signal-map fields, FPGA register-map draft structures, and testbench comparison vectors for future FPGA, ASIC, and external architecture comparison workflows.

## M3 Export Layers

- `benchmark_matrix`;

- `hardware_signal_map`;

- `fpga_register_map_draft`;

- `testbench_vector`.

## M3 Export Commands

Benchmark matrix export:

`python frp_prototype_v0_9_5.py --export-benchmark-matrix`

Hardware signal map export:

`python frp_prototype_v0_9_5.py --export-signal-map`

FPGA register map draft export:

`python frp_prototype_v0_9_5.py --export-register-map`

Testbench vector export:

`python frp_prototype_v0_9_5.py --export-testbench-vector`

## M3 Validation Status

Validated GitHub Actions workflow:

`FRP M3 Benchmark and Signal Map`

Observed status:

`PASS`

## M3 Documentation

- `docs/benchmark_matrix.md`;

- `docs/hardware_signal_mapping.md`;

- `docs/fpga_register_map_draft.md`;

- `docs/testbench_comparison_plan.md`;

- `docs/m3_validation_targets.md`.

Release-facing files:

- `RELEASE_NOTES_v0_9_5.md`;

- `TEST_REPORT_v0_9_5.md`;

- `CHANGELOG.md`.

Version: `v0.9.4`  
Status: `candidate prototype`  
Type: `single-file Python simulation with structured JSON output`  
Milestone: `M2 — Structured Output`  
Schema: `frp.structured_output.v0.9.4`  
License: `Apache License 2.0`  
Archived DOI: [`10.5281/zenodo.21112439`](https://doi.org/10.5281/zenodo.21112439)

## 1. Overview

Fractal Resonance Processor (FRP) is a ternary resonant coherence processor architecture.

FRP is based on:

- balanced ternary states
- neutral transition routing
- distributed commit behavior
- resonant phase dynamics
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- operational coherence tracking
- stability-bound execution
- per-tick telemetry
- structured machine-readable output
- reproducible benchmark execution
- staged hardware-facing documentation pathway

FRP treats computation as a dynamic process of target-oriented ternary transition, neutral conflict routing, resonance-supported phase evolution, distributed commit, and retained coherent output.

The current repository establishes the public software validation and structured-output layer of the FRP architecture.

This layer provides the executable reference model for hardware-facing specification, FPGA mapping study, ASIC mapping study, physical validation planning, partner review, funding preparation, and later testbench comparison work.

## 2. Current Repository Position

FRP v0.9.4 currently provides:

- executable Python source code
- balanced ternary state logic
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- processor instruction layer
- self-test mode
- benchmark mode
- structured JSON output
- machine-readable schema marker
- JSON demo output
- JSON self-test output
- JSON benchmark output
- optional telemetry export
- reproducibility commands
- benchmark output
- GitHub Actions CI verification
- structured-output GitHub Actions workflow
- documentation package
- release notes
- test report
- release checklist
- roadmap
- milestone structure
- funding brief
- hardware pathway documentation
- implementation layer documentation
- FPGA mapping study
- ASIC mapping study
- physical validation plan
- citation metadata
- Apache-2.0 license

The current software layer has been executed and verified on general-purpose computing infrastructure through Python execution, reproducibility commands, benchmark execution, structured JSON validation, telemetry export checks, and automated CI workflows.

## 3. Engineering Trajectory

The FRP development trajectory is organized as:

`software validation → architecture stabilization → archival release → structured output → expanded benchmark layer → hardware-facing specification → FPGA mapping study → ASIC mapping study → chip-oriented implementation research → physical validation planning → partner and funding package → stable public software architecture release`

The current repository package establishes the validated public software and structured-output foundation for this trajectory.

Current milestone position:

`M2 — Structured Output`

Next planned technical direction:

`M3 — Extended Benchmark Layer`

Hardware-facing trajectory after structured benchmark stabilization:

`M4 — FPGA Mapping Package`

## 4. Current Prototype

The active prototype file is:

`frp_prototype_v0_9_4.py`

The previous archived reference prototype file is:

`frp_prototype_v0_9_3_mobile.py`

The active test report file is:

`TEST_REPORT_v0_9_4.md`

The previous archived test report file is:

`TEST_REPORT_v0_9_3.md`

The active candidate version is:

`v0.9.4`

The current structured-output schema is:

`frp.structured_output.v0.9.4`

The prototype implements:

- balanced ternary states: `-1`, `0`, `1`
- neutral `0` as active balancing, damping, and transition state
- direct polarity transition safety
- neutral transition routing
- distributed ternary commit
- Kuramoto-Sakaguchi phase coupling
- nonlinear cubic saturation
- nonlinear compression
- independent logic and coupling delay buffers
- scheduler modes: `free`, `7/1`, `1/7`
- per-tick telemetry
- register file
- processor instruction layer
- demonstration mode
- self-test mode
- benchmark mode
- structured JSON output
- optional telemetry export
- command-line interface

## 5. Installation

Install dependencies from the repository root:

`pip install -r requirements.txt`

The current external Python dependency is:

`numpy>=1.26.0`

For detailed installation instructions, see:

`INSTALL.md`

Recommended Python version:

`Python 3.10 or newer`

## 6. Quick Start

Run a demonstration:

`python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1`

Run the standard self-test:

`python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5`

Run the heavier self-test:

`python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10`

Run the benchmark:

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5`

Run the standard self-test as JSON:

`python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json`

Run the benchmark as JSON:

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json`

Run a demo with JSON telemetry:

`python3 frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json --include-telemetry`

For detailed usage instructions, see:

`USAGE.md`

For reproducibility instructions, see:

`REPRODUCIBILITY.md`

For structured output schema details, see:

`docs/output_schema.md`

## 7. Core Ternary Principle

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive potential |
| `0` | neutral balancing / damping / transition state |
| `1` | positive / excitatory / phase-supporting / constructive potential |

The direct polarity transition is routed through the neutral state.

Reference transition paths:

`-1 → 0 → 1`

`1 → 0 → -1`

The neutral state `0` acts as:

- logical neutral state
- phase damper
- transition buffer
- conflict neutralizer
- switching-load guard
- polarity bridge
- scheduling control point

In FRP, `0` is not treated as a passive empty value.

It is an active transition and stabilization state.

## 8. Dynamic Stability Principle

The core stability condition is:

`C(t) > P(t)`

where:

| Symbol | Meaning |
|---|---|
| `C(t)` | operational coherence |
| `P(t)` | destabilizing load |

In the current prototype:

`P(t) = heat + switch_load`

Stable execution requires:

`C_minus_P = C(t) - P(t) > 0`

The prototype tracks this condition during execution.

The processor does not only check whether the final ternary target state was reached.

It also checks whether the transition path preserved:

- direct transition safety
- distributed switching limits
- scheduler consistency
- telemetry completeness
- positive operational stability

## 9. Operational Domain

The tested operational domain is:

`N >= 8`

Smaller values such as `N = 2` or `N = 3` may be used as micro-tests of ternary logic.

Default transition cap:

`transition_fraction = 0.25`

This limits the maximum distributed state transition load per tick under default settings.

Default Kuramoto-Sakaguchi phase shift:

`gamma = 0.30 pi`

Default telemetry interval:

`telemetry_every = 1`

Per-tick telemetry is mandatory inside the model.

The `--include-telemetry` flag controls whether telemetry is emitted in JSON output.

## 10. Scheduler Modes

FRP currently supports three scheduler modes:

| Mode | Tick Behavior |
|---|---|
| `free` | every tick is commit |
| `7/1` | ticks `0..6` are balance, tick `7` is commit |
| `1/7` | tick `0` is excite, ticks `1..7` are neutralize |

The scheduler is validated by internal tick counts.

### 10.1 Free Mode

In `free` mode, commit behavior is allowed every tick.

Role:

`simple execution mode for comparison and inspection`

### 10.2 7/1 Mode

The `7/1` mode is an eight-tick operating cycle:

`seven balance ticks`

`one commit tick`

Ticks `0..6` are used for:

- balance
- stabilization
- phase adjustment
- neutral routing
- transition preparation

Tick `7` is used as the commit tick.

Purpose:

`separate preparation from commitment`

### 10.3 1/7 Mode

The `1/7` mode is the complementary operating cycle:

`one excite tick`

`seven neutralize ticks`

One tick introduces excitation or transition pressure.

The following seven ticks are used for:

- neutralization
- damping
- stabilization
- coherence recovery

Purpose:

`separate excitation from recovery`

## 11. Kuramoto-Sakaguchi Resonant Phase Layer

FRP includes a resonant phase-coupling layer based on a Kuramoto-Sakaguchi model.

Each processor cell has a phase.

The phase field evolves through coupled oscillator dynamics.

The Sakaguchi phase shift introduces asymmetric phase coupling.

Current default phase shift:

`gamma = 0.30 pi`

This resonant phase layer separates FRP from a purely logical ternary transition model.

FRP combines:

- ternary state logic
- resonant phase coupling
- nonlinear shaping
- delayed interaction
- scheduler-controlled transition
- operational coherence tracking

## 12. Processor Layer

The current processor layer includes:

- register file
- instruction execution
- demonstration program
- self-test mode
- benchmark mode

Supported instructions:

- `load`
- `rand`
- `zero`
- `mov`
- `neg`
- `add`
- `sub`
- `compare`
- `consensus`
- `halt`

Balanced ternary arithmetic and logical operations:

- `neg`
- `add`
- `sub`
- `compare`
- `consensus`

The processor layer uses the FRP core to execute ternary operations while tracking transition safety, stability, scheduler behavior, and telemetry.

## 13. Per-Tick Telemetry

Per-tick telemetry is part of the current candidate.

The prototype records:

- `tick`
- `phase`
- `R`
- `phi`
- `neutral`
- `positive`
- `negative`
- `heat`
- `thermal_scale`
- `switch_load`
- `actual_direct_events_delta`
- `prevented_direct_events_delta`
- `neutralized_conflicts_delta`
- `logical_match`
- `transition_debt`
- `direct_conflict_fraction`
- `C`
- `P`
- `C_minus_P`

Telemetry supports:

- execution inspection
- candidate invariant verification
- benchmark interpretation
- output schema documentation
- structured output
- hardware-facing telemetry mapping
- physical validation planning
- future FPGA register mapping
- future testbench comparison

Telemetry path:

`Python model → JSON telemetry → benchmark export → hardware-facing signal map → FPGA register map → testbench comparison`

## 14. Structured Output

FRP v0.9.4 adds structured machine-readable output.

New output controls:

`--output text`

`--output json`

`--include-telemetry`

Default output mode:

`--output text`

Structured output mode:

`--output json`

Optional telemetry export:

`--include-telemetry`

Current schema marker:

`frp.structured_output.v0.9.4`

Supported JSON output kinds:

| Kind | Mode |
|---|---|
| `demo` | `--mode demo` |
| `self_test` | `--mode test` |
| `benchmark` | `--mode bench` |

Common JSON envelope fields:

- `schema`
- `project`
- `version`
- `kind`
- `parameters`

For the detailed structured output schema, see:

`docs/output_schema.md`

## 15. Candidate Invariants

The current candidate is organized around the following invariants:

| Invariant | Required Result |
|---|---|
| target match | `match = 1.000` |
| direct transition safety | `actual_direct_events = 0` |
| stability | `C_minus_P_min > 0` |
| transition load | `switch_load_peak <= transition_fraction` |
| telemetry | `ticks_recorded = steps` |
| scheduler | counts match selected cycle mode |

A final ternary vector alone is not sufficient.

The transition path must also satisfy safety, stability, telemetry, scheduler, and distributed transition conditions.

In v0.9.4 these invariants can be inspected through both text output and structured JSON output.

## 16. Test Status

Current candidate result:

`v0.9.4: PASS`

Structured-output milestone result:

`M2 — PASS`

### 16.1 Standard Self-Test

Command:

`python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5`

Expected result:

`result=PASS`

Expected text markers:

`FRP SELF TEST v0.9.4`

`failures=0`

`result=PASS`

Expected candidate properties:

- no self-test failures
- zero actual direct transition events
- positive C_minus_P stability margin
- telemetry length equals requested steps
- scheduler counts match selected cycle mode
- target match reaches `1.000` in tested operations

### 16.2 Heavy Self-Test

Command:

`python3 frp_prototype_v0_9_4.py --mode test --steps 256 --seeds 10`

Expected result:

`result=PASS`

Expected text markers:

`FRP SELF TEST v0.9.4`

`failures=0`

`result=PASS`

### 16.3 JSON Self-Test

Command:

`python3 frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json`

Expected JSON markers:

`"schema": "frp.structured_output.v0.9.4"`

`"version": "v0.9.4"`

`"kind": "self_test"`

`"failures": 0`

`"result": "PASS"`

Expected JSON metric conditions:

`metrics.actual_direct_events = 0`

`metrics.C_minus_P_min > 0`

## 17. Benchmark Summary

Benchmark command:

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5`

JSON benchmark command:

`python3 frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json`

Benchmark architectures:

- `frp_distributed_resonant`
- `direct_ternary_commit`
- `distributed_neutral_ternary`
- `binary_style_forced_switch`

Expected benchmark architecture labels:

| Architecture |
|---|
| `binary_style_forced_switch` |
| `direct_ternary_commit` |
| `distributed_neutral_ternary` |
| `frp_distributed_resonant` |

The benchmark compares FRP distributed resonant behavior against baseline transition architectures.

In v0.9.4, benchmark output is available in both console and structured JSON form.

## 18. Benchmark-Supported Technical Position

The current benchmark supports the following technical position:

`FRP adds a Kuramoto-Sakaguchi resonant phase layer on top of safe distributed neutral ternary transition logic while preserving zero actual direct -1 ↔ 1 transitions in the tested operational domain.`

Current benchmark interpretation:

- FRP distributed resonant mode preserves `match = 1.000`
- FRP distributed resonant mode preserves `actual_direct_events = 0`
- FRP distributed resonant mode preserves `C_minus_P_min > 0`
- FRP distributed resonant mode preserves distributed transition load under the configured transition fraction
- FRP includes the Kuramoto-Sakaguchi resonant phase layer
- FRP includes nonlinear saturation
- FRP includes compression dynamics
- FRP includes delay dynamics
- FRP includes resonant phase evolution
- FRP emits structured benchmark JSON in v0.9.4

For detailed benchmark interpretation, see:

`docs/benchmark_interpretation.md`

## 19. General-Purpose Hardware Execution

The FRP software layer has been executed and verified on general-purpose computing infrastructure.

Validated through:

- local Python execution path
- reproducibility commands
- benchmark execution
- JSON structured output execution
- telemetry export execution
- GitHub Actions workflow execution
- CI status verification

Engineering role:

`establish an executable software reference model for hardware-facing specification and implementation-layer work`

## 20. Hardware-Facing Development Path

The current hardware-facing development path is organized as:

`software validation → structured output → benchmark export → hardware-facing specification → FPGA mapping study → ASIC mapping study → chip-oriented implementation research → physical validation planning`

Current hardware-facing documents:

| File | Role |
|---|---|
| `docs/hardware_pathway.md` | defines the path from software validation toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning |
| `docs/implementation_layers.md` | defines the staged layer structure of FRP |
| `docs/fpga_mapping_study.md` | defines the FPGA-oriented mapping study |
| `docs/asic_mapping_study.md` | defines the ASIC-oriented mapping study |
| `docs/physical_validation_plan.md` | defines the physical validation planning structure |

Current structured-output bridge toward hardware-facing work:

`Python model → JSON telemetry → benchmark export → hardware-facing signal map → FPGA register map → testbench comparison`

## 21. Funding and Partner Package

Current funding and partner document:

`funding_brief.md`

The funding brief provides:

- executive summary
- current validated asset list
- software validation evidence
- benchmark summary
- structured-output validation evidence
- general-purpose hardware execution summary
- hardware-facing development path
- funding objective
- proposed funding milestones
- resource needs
- partner profile
- technical value proposition
- review package structure
- funding-facing technical message

Core funding-facing technical message:

`FRP has a validated public software reference layer, reproducibility commands, benchmark output, structured JSON output, CI verification, and a documented pathway toward FPGA mapping, ASIC mapping, chip-oriented implementation research, and physical validation planning.`

## 22. Project Milestones

Current milestone document:

`MILESTONES.md`

The milestone structure defines:

| Milestone | Name | Primary Output |
|---|---|---|
| M0 | Repository Stabilization | stable repository package |
| M1 | Archival Release and DOI | GitHub release, Zenodo archive, DOI |
| M2 | Structured Output | JSON and machine-readable summaries |
| M3 | Extended Benchmark Layer | expanded benchmark profiles and exports |
| M4 | FPGA Mapping Package | FPGA-oriented implementation package |
| M5 | ASIC Mapping Package | chip-oriented implementation research package |
| M6 | Physical Validation Protocol | measurement and validation protocol package |
| M7 | Funding and Partner Package | review package for partners, labs, grants, and investors |
| M8 | v1.0.0 Public Software Architecture Release | stable public software architecture release |

Current active milestone:

`M2 — Structured Output`

Current milestone status:

`PASS`

## 23. Repository Navigation

### 23.1 Core Root Files

| File | Purpose |
|---|---|
| `README.md` | main public project overview |
| `frp_prototype_v0_9_4.py` | current executable Python prototype with structured output |
| `frp_prototype_v0_9_3_mobile.py` | previous archived reference prototype |
| `TEST_REPORT_v0_9_4.md` | current candidate test report |
| `TEST_REPORT_v0_9_3.md` | previous archived test report |
| `CHANGELOG.md` | version history |
| `RELEASE_NOTES_v0_9_4.md` | release notes for v0.9.4 |
| `RELEASE_NOTES_v0_9_3.md` | release notes for v0.9.3-mobile |
| `RELEASE_CHECKLIST_v0_9_3.md` | release readiness checklist for v0.9.3 |
| `ROADMAP.md` | staged project roadmap |
| `MILESTONES.md` | staged project milestones |
| `funding_brief.md` | partner and funding-facing technical brief |
| `PROJECT_STRUCTURE.md` | repository structure guide |
| `INSTALL.md` | installation guide |
| `USAGE.md` | usage guide |
| `REPRODUCIBILITY.md` | reproducibility guide |
| `CI.md` | continuous integration documentation |
| `requirements.txt` | Python dependency list |
| `CITATION.cff` | citation metadata |
| `LICENSE` | Apache-2.0 license text |
| `NOTICE` | project notice |
| `SECURITY.md` | security policy |
| `CONTRIBUTING.md` | contribution guide |
| `CODE_OF_CONDUCT.md` | code of conduct |

### 23.2 Documentation Files

| File | Purpose |
|---|---|
| `docs/README.md` | documentation layer index |
| `docs/core_principles.md` | core FRP principles |
| `docs/resonance_computation.md` | resonance computation explanation |
| `docs/architecture.md` | FRP architecture documentation |
| `docs/benchmark_interpretation.md` | benchmark interpretation and evidence scope |
| `docs/limitations.md` | current simulation evidence boundaries and scope notes |
| `docs/output_schema.md` | structured output schema, JSON fields, test markers, benchmark markers, telemetry fields, and CI checks |
| `docs/hardware_pathway.md` | hardware-facing development pathway |
| `docs/implementation_layers.md` | staged implementation layer structure |
| `docs/fpga_mapping_study.md` | FPGA-oriented mapping study |
| `docs/asic_mapping_study.md` | ASIC-oriented mapping study |
| `docs/physical_validation_plan.md` | physical validation planning structure |

### 23.3 Verification Files

| File | Purpose |
|---|---|
| `verification/README.md` | verification layer overview |
| `verification/coherence_metrics.md` | operational coherence and metric definitions |

### 23.4 Examples

| File | Purpose |
|---|---|
| `examples/README.md` | examples overview |
| `examples/resonance_convergence_example.md` | resonance convergence example |

### 23.5 Models and Simulations

| File | Purpose |
|---|---|
| `models/README.md` | model layer overview |
| `models/kuramoto_frp_background_model.md` | background Kuramoto-type model context |
| `simulations/README.md` | simulation layer overview |
| `simulations/initial_kuramoto_result.md` | preliminary Kuramoto background result |

### 23.6 Continuous Integration

| File | Purpose |
|---|---|
| `.github/workflows/frp-self-test.yml` | automated standard FRP self-test |
| `.github/workflows/frp-benchmark-smoke.yml` | automated benchmark smoke test |
| `.github/workflows/frp-structured-output.yml` | automated v0.9.4 structured-output validation |

## 24. Continuous Integration

The repository currently has three GitHub Actions workflows:

| Workflow | Purpose | Status |
|---|---|---|
| FRP Self Test | runs the standard FRP self-test | passing |
| FRP Benchmark Smoke Test | runs the benchmark smoke test | passing |
| FRP Structured Output | validates v0.9.4 structured JSON output and telemetry export | passing |

The self-test workflow runs:

`python frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5`

The benchmark smoke test workflow runs:

`python frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5`

The structured output workflow validates:

`python frp_prototype_v0_9_4.py --mode test --steps 128 --seeds 5 --output json`

`python frp_prototype_v0_9_4.py --mode bench --steps 128 --seeds 5 --output json`

`python frp_prototype_v0_9_4.py --mode demo --N 16 --steps 128 --cycle-mode 7/1 --output json`

`python frp_prototype_v0_9_4.py --mode demo --N 16 --steps 32 --cycle-mode 7/1 --output json --include-telemetry`

For detailed continuous integration documentation, see:

`CI.md`

## 25. Release Readiness

Current release readiness files:

- `RELEASE_NOTES_v0_9_4.md`
- `TEST_REPORT_v0_9_4.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `MILESTONES.md`
- `funding_brief.md`
- `PROJECT_STRUCTURE.md`
- `docs/output_schema.md`

Current readiness state:

- prototype present
- tests documented
- benchmark documented
- structured output documented
- JSON output documented
- telemetry export documented
- CI passing
- structured-output CI passing
- installation documented
- usage documented
- reproducibility documented
- release scope documented
- engineering trajectory documented
- hardware pathway documented
- implementation layers documented
- FPGA mapping study documented
- ASIC mapping study documented
- physical validation plan documented
- funding brief documented
- milestones documented
- citation metadata present
- license present
- notice present
- security policy present
- contribution guide present
- code of conduct present
- output schema documented

Current release preparation target:

`GitHub Release v0.9.4`

Current archival status:

`v0.9.3 DOI exists`

Existing archived DOI:

`https://doi.org/10.5281/zenodo.21112439`

## 26. Archival Path

Current archival status:

`FRP v0.9.3 has a Zenodo DOI`

Archived DOI:

`https://doi.org/10.5281/zenodo.21112439`

Recommended v0.9.4 archival sequence:

1. final repository stabilization
2. confirm CI passing
3. confirm structured-output workflow passing
4. confirm release notes
5. confirm test report
6. confirm changelog
7. create GitHub release tag `v0.9.4`
8. create Zenodo archival version record
9. update DOI metadata if a new version DOI is issued
10. update `CITATION.cff` if needed
11. update README citation section if needed
12. prepare next milestone branch or release path

## 27. Release History

### v0.9.4 — Structured Output and Machine-Readable Validation

Release title:

`Fractal Resonance Processor (FRP) v0.9.4 — Structured Output and Machine-Readable Validation`

Milestone:

`M2 — Structured Output`

Main prototype:

`frp_prototype_v0_9_4.py`

Schema marker:

`frp.structured_output.v0.9.4`

Added:

- structured JSON output
- `--output text`
- `--output json`
- `--include-telemetry`
- JSON demo output
- JSON self-test output
- JSON benchmark output
- optional telemetry export
- structured-output GitHub Actions workflow
- machine-readable validation layer

Status:

`PASS`

### v0.9.3 — Ternary Resonant Coherence Processor

Release title:

`Fractal Resonance Processor (FRP) v0.9.3 — Ternary Resonant Coherence Processor`

Main prototype:

`frp_prototype_v0_9_3_mobile.py`

Archived DOI:

`https://doi.org/10.5281/zenodo.21112439`

DOI:

`10.5281/zenodo.21112439`

Role:

`executable software reference model and public validation baseline`

Status:

`PASS`

## 28. License

Apache License 2.0.

See the full license text in:

`LICENSE`

## 29. Citation

Citation metadata is available in:

`CITATION.cff`

Current archived DOI:

`https://doi.org/10.5281/zenodo.21112439`

DOI:

`10.5281/zenodo.21112439`

Recommended citation:

`Maksym Marnov. Fractal Resonance Processor (FRP) v0.9.3 — Ternary Resonant Coherence Processor. Zenodo. DOI: 10.5281/zenodo.21112439`

The v0.9.4 archival version record should be created after publishing the GitHub Release v0.9.4.

# Physical Validation Plan — Fractal Resonance Processor (FRP)

This document defines the physical validation planning structure for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, CI verification layer, and hardware-facing documentation pathway

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

Related documents:

    hardware_pathway.md
    implementation_layers.md
    fpga_mapping_study.md
    asic_mapping_study.md

## 1. Purpose

The purpose of this document is to define how future physical implementations of the Fractal Resonance Processor can be validated against the current FRP software reference model.

The physical validation plan connects:

    software reference behavior
    → FPGA-oriented mapping
    → ASIC-oriented mapping
    → physical prototype measurement
    → comparison against documented candidate invariants

This document focuses on:

- validation purpose
- reference model alignment
- logical correctness
- direct transition safety
- neutral transition routing
- distributed commit behavior
- scheduler behavior
- telemetry consistency
- timing behavior
- energy behavior
- thermal behavior
- benchmark repeatability
- comparison against the Python reference model
- measurement protocol structure
- validation deliverables
- funding and partner relevance

## 2. Current Reference Model

The current executable reference model is:

    ../frp_prototype_v0_9_3_mobile.py

The current test report is:

    ../TEST_REPORT_v0_9_3.md

The reference model includes:

- balanced ternary states: -1, 0, 1
- neutral transition routing
- direct polarity transition safety
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear cubic saturation
- nonlinear compression
- delay buffers
- scheduler modes
- per-tick telemetry
- register file
- processor instruction layer
- self-test mode
- benchmark mode
- command-line interface

The physical validation plan uses the software reference model as the behavioral anchor for future measurement and comparison.

## 3. Validation Objective

The primary validation objective is:

    compare future physical FRP implementation behavior against the current software reference model

The validation structure should preserve traceability between:

- software output
- benchmark output
- CI-verified behavior
- FPGA-oriented mapping
- ASIC-oriented mapping
- physical measurement output
- candidate invariants

Initial validation goals:

- confirm logical correctness
- confirm target matching behavior
- confirm direct transition safety
- confirm neutral transition routing
- confirm distributed commit behavior
- confirm scheduler behavior
- confirm telemetry consistency
- measure timing behavior
- measure switching activity
- measure energy behavior
- measure thermal behavior
- compare physical outputs against reference outputs

## 4. Candidate Invariants for Physical Validation

Physical validation should preserve the current candidate invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants provide the first bridge between the software validation layer and physical measurement planning.

## 5. Validation Categories

Physical validation is organized into the following categories:

| Category | Purpose |
|---|---|
| logical correctness | confirm state and target behavior |
| transition safety | confirm polarity changes route through neutral state |
| neutral routing | confirm -1 → 0 → 1 and 1 → 0 → -1 behavior |
| distributed commit | confirm controlled transition fraction per tick |
| scheduler behavior | confirm free, 7/1, and 1/7 timing behavior |
| telemetry consistency | confirm observable counters and trace outputs |
| timing behavior | measure execution timing and phase behavior |
| switching activity | measure transition activity and load behavior |
| energy behavior | measure energy-related activity |
| thermal behavior | measure temperature-related behavior |
| benchmark repeatability | repeat reference benchmark profiles |
| reference comparison | compare physical outputs with Python reference behavior |

Each category should map back to the software reference model.

## 6. Logical Correctness Validation

Logical correctness validation confirms that a future physical implementation produces the expected ternary state behavior.

Validation inputs:

- initial ternary state vector
- target ternary state vector
- scheduler mode
- transition_fraction
- step count
- deterministic test vector profile
- benchmark-derived vector profile

Validation outputs:

- final ternary state vector
- target match value
- state count summary
- transition counter summary
- scheduler counter summary
- telemetry summary

Validation criteria:

| Metric | Expected Role |
|---|---|
| final state vector | compared with target vector |
| logical_match | confirms target matching |
| neutral count | confirms neutral-state behavior |
| positive count | confirms positive-state behavior |
| negative count | confirms negative-state behavior |
| scheduler counts | confirms phase timing behavior |

The physical result should be compared against the Python reference output for the same input profile.

## 7. Direct Transition Safety Validation

Direct transition safety validation confirms that polarity changes preserve the FRP neutral routing principle.

Reference transition paths:

    -1 → 0 → 1
     1 → 0 → -1

Validation metrics:

- actual_direct_events
- prevented_direct_events
- neutralized_conflicts
- transition_debt
- direct_conflict_fraction

Validation criteria:

| Metric | Expected Role |
|---|---|
| actual_direct_events | confirms direct polarity transition safety |
| prevented_direct_events | counts prevented polarity conflicts |
| neutralized_conflicts | counts conflicts routed through neutral state |
| transition_debt | tracks deferred transitions |
| direct_conflict_fraction | tracks conflict ratio |

The direct transition safety layer is a core validation category for future physical implementations.

## 8. Neutral Routing Validation

Neutral routing validation confirms the functional role of the neutral state.

Neutral state roles:

- transition buffer
- conflict neutralizer
- damping state
- polarity bridge
- switching-load guard
- scheduling control point

Validation test cases:

| Current State | Target State | Expected Path |
|---|---|---|
| -1 | 1 | -1 → 0 → 1 |
| 1 | -1 | 1 → 0 → -1 |
| -1 | 0 | -1 → 0 |
| 1 | 0 | 1 → 0 |
| 0 | -1 | 0 → -1 |
| 0 | 1 | 0 → 1 |

Validation outputs:

- routed transition count
- neutral insertion count
- neutralized conflict count
- transition debt count
- per-tick state trace

The neutral routing validation should preserve alignment with the software reference model.

## 9. Distributed Commit Validation

Distributed commit validation confirms that state updates are controlled by a commit fraction.

Default transition cap:

    transition_fraction = 0.25

Physical validation should measure:

- eligible transition count
- committed transition count
- deferred transition count
- switch_load
- transition_debt
- commit phase count
- per-tick update distribution

Validation criteria:

| Metric | Expected Role |
|---|---|
| switch_load_peak | confirms commit load behavior |
| transition_debt | confirms deferred transition behavior |
| committed transition count | confirms staged update behavior |
| eligible transition count | confirms transition demand |
| commit window activity | confirms scheduler-controlled updates |

The distributed commit validation should compare measured behavior against the Python reference model.

## 10. Scheduler Behavior Validation

Current scheduler modes:

| Mode | Tick Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

Physical validation should confirm:

- scheduler counter accuracy
- phase sequence accuracy
- commit_enable timing
- balance_enable timing
- excite_enable timing
- neutralize_enable timing
- telemetry_sample timing

Validation outputs:

- tick trace
- scheduler phase trace
- phase counter summary
- commit phase count
- balance phase count
- excite phase count
- neutralize phase count

The scheduler behavior should remain comparable to the software reference telemetry.

## 11. Telemetry Consistency Validation

The software reference model records per-tick telemetry.

Initial telemetry fields for physical validation:

- tick
- scheduler phase
- neutral count
- positive count
- negative count
- switch_load
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- transition_debt
- logical_match
- C
- P
- C_minus_P

Candidate physical telemetry interfaces:

- memory-mapped register interface
- debug bus
- scan-visible register set
- UART debug stream
- trace buffer
- logic analyzer signal group
- structured host-side export

Validation criteria:

| Telemetry Property | Expected Role |
|---|---|
| tick completeness | confirms per-tick trace continuity |
| scheduler phase trace | confirms timing structure |
| transition counters | confirms routing behavior |
| state counters | confirms ternary state behavior |
| C, P, C_minus_P | confirms stability metric mapping |
| benchmark summary | confirms profile-level comparison |

Telemetry consistency provides the main comparison bridge between physical behavior and the Python reference model.

## 12. Timing Behavior Validation

Timing validation measures how the implementation behaves across ticks, phases, and update windows.

Candidate timing measurements:

- clock frequency
- tick duration
- commit window duration
- balance phase duration
- neutralize phase duration
- transition propagation time
- delay buffer timing
- telemetry sampling timing
- register update timing
- phase approximation update timing

Validation outputs:

- timing trace
- scheduler timing report
- commit timing report
- delay buffer timing report
- phase block timing report
- telemetry sampling report

Timing validation supports the implementation-layer comparison between FPGA, ASIC-oriented study, and future physical prototypes.

## 13. Switching Activity Validation

Switching activity validation measures transition behavior and update activity.

Candidate measurements:

- total transition events
- committed transition events
- deferred transition events
- neutral insertion events
- prevented direct transition events
- neutralized conflict events
- active state-cell count
- per-tick transition count
- switch_load estimate or measurement

Validation outputs:

- switching activity table
- transition activity trace
- switch_load summary
- transition_debt summary
- scheduler-correlated switching activity

Switching activity validation connects physical behavior to the software switch_load metric.

## 14. Energy Behavior Validation

Energy behavior validation measures implementation activity through energy-related metrics.

Candidate measurements:

- supply voltage
- supply current
- instantaneous power
- average power
- peak power
- energy per benchmark run
- energy per tick
- energy per committed transition
- energy per scheduler mode
- energy per test profile

Candidate derived metrics:

| Metric | Role |
|---|---|
| average power | profile-level energy behavior |
| peak power | transient load behavior |
| energy per run | benchmark-level energy comparison |
| energy per tick | scheduler-level comparison |
| energy per transition | transition activity comparison |

Energy behavior should be reported together with the executed validation profile and telemetry summary.

## 15. Thermal Behavior Validation

Thermal behavior validation measures temperature-related behavior during execution.

Candidate measurements:

- starting temperature
- ending temperature
- peak temperature
- temperature delta
- temperature over time
- temperature per benchmark profile
- temperature per scheduler mode
- temperature under repeated runs
- cooling interval behavior

Candidate thermal outputs:

- temperature trace
- peak temperature summary
- thermal delta summary
- repeated-run thermal profile
- benchmark-correlated thermal report

Thermal behavior validation should be linked to the exact workload, board, measurement setup, and run duration.

## 16. Benchmark Repeatability Validation

Benchmark repeatability validation confirms that the same profile can be executed repeatedly and compared.

Reference benchmark command:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Reference benchmark architectures:

- binary_style_forced_switch
- direct_ternary_commit
- distributed_neutral_ternary
- frp_distributed_resonant

Physical benchmark profile should define:

- state vector size
- initial vector profile
- target vector profile
- scheduler mode
- step count
- transition_fraction
- phase parameters
- measurement interval
- telemetry output format

Repeatability outputs:

- run count
- mean metric values
- peak metric values
- variance or spread
- trace comparison
- benchmark summary table

Benchmark repeatability connects the physical validation process with the existing software benchmark structure.

## 17. Comparison Against Python Reference

Physical validation should compare implementation behavior against the Python reference model.

Reference commands:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Comparison categories:

- final state match
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts
- switch_load_peak
- transition_debt
- scheduler counts
- telemetry length
- C_minus_P behavior
- benchmark summary fields
- profile-level repeatability

Comparison output should include:

- Python reference output
- physical implementation output
- metric alignment table
- trace alignment notes
- measurement setup description

## 18. Measurement Protocol Structure

A physical validation protocol should record the following information.

### 18.1 Device and Setup

- implementation type
- board or prototype identifier
- clock configuration
- power supply configuration
- measurement instruments
- temperature measurement method
- host system
- firmware or bitstream identifier
- testbench version

### 18.2 Execution Profile

- test profile name
- state vector size
- scheduler mode
- transition_fraction
- step count
- seed or deterministic vector profile
- phase parameters
- run count
- telemetry mode

### 18.3 Measured Outputs

- final state vector
- transition counters
- scheduler counters
- telemetry trace
- timing measurements
- energy measurements
- thermal measurements
- benchmark summary

### 18.4 Reference Comparison

- Python reference command
- Python reference output
- physical output
- metric comparison table
- trace comparison notes
- validation summary

## 19. Validation Deliverables

Expected validation deliverables:

- physical validation protocol
- measurement setup description
- test profile definitions
- telemetry mapping document
- benchmark repeatability report
- timing measurement report
- energy measurement report
- thermal measurement report
- Python-reference comparison report
- validation summary table
- implementation-layer review notes

These deliverables support engineering review, partner discussion, funding preparation, and archival technical documentation.

## 20. Funding and Partner Relevance

The physical validation plan supports partner and funding conversations by defining how future physical implementations can be tested.

Current project assets:

- executable software reference model
- reproducibility commands
- benchmark output
- CI verification
- hardware pathway document
- implementation layers document
- FPGA mapping study document
- ASIC mapping study document
- physical validation planning structure

Funding-facing technical message:

    FRP has a validated software reference layer, hardware-facing mapping documents, and a defined physical validation planning structure.

This supports:

- engineering partner review
- laboratory collaboration
- grant preparation
- prototype validation planning
- measurement protocol planning
- implementation research planning
- funding package preparation

## 21. Current Status

The physical validation plan defines the measurement and comparison structure for future FRP physical implementation stages.

The document provides a validation planning structure for:

- logical correctness
- direct transition safety
- neutral transition routing
- distributed commit behavior
- scheduler behavior
- telemetry consistency
- timing behavior
- switching activity
- energy behavior
- thermal behavior
- benchmark repeatability
- comparison against the Python reference model
- measurement protocol structure
- validation deliverables
- funding and partner technical review

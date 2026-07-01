# FPGA Mapping Study — Fractal Resonance Processor (FRP)

This document defines the FPGA-oriented mapping study for the Fractal Resonance Processor (FRP) project.

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

## 1. Purpose

The purpose of this document is to describe how the current FRP software validation layer can be mapped into an FPGA-oriented implementation study.

The FPGA mapping study is the first programmable-hardware bridge between the executable Python reference model and implementation-layer research.

This document focuses on:

- ternary state encoding
- neutral transition routing
- distributed commit scheduling
- register representation
- delay buffer mapping
- phase layer approximation
- nonlinear block approximation
- telemetry counters
- FPGA testbench structure
- comparison against the Python reference model

## 2. Current Reference Model

The current executable reference model is:

    ../frp_prototype_v0_9_3_mobile.py

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

The FPGA mapping study preserves behavioral equivalence with this reference model as the first engineering target.

## 3. FPGA Mapping Objective

The primary FPGA mapping objective is:

    reproduce the FRP software reference behavior through programmable hardware structures

Initial FPGA study goals:

- encode balanced ternary states
- implement neutral transition routing
- implement distributed commit scheduling
- implement register-level state storage
- implement delay buffers
- approximate the phase layer
- approximate nonlinear saturation and compression
- expose telemetry counters
- run testbench comparisons against Python output
- preserve candidate invariants

The first FPGA study prioritizes traceability and verification before compactness or optimization.

## 4. Candidate Invariants for FPGA Study

The FPGA-oriented study preserves the current candidate invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants connect the FPGA study back to the current software validation layer.

## 5. Balanced Ternary State Encoding

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive state |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive state |

FPGA fabrics are typically binary at the physical logic level.

The first FPGA study can represent ternary states through encoded binary signals.

Candidate encoding:

| Ternary State | Example Binary Encoding |
|---|---|
| -1 | 10 |
| 0 | 00 |
| 1 | 01 |

Study criteria:

- simple decoding
- safe neutral representation
- efficient transition control
- reserved-code handling
- compatibility with telemetry counters
- compatibility with register arrays
- compatibility with testbench comparison

The selected encoding preserves the semantic role of the neutral state.

## 6. Neutral Transition Routing

The current FRP transition principle routes polarity changes through the neutral state.

Transition path:

    -1 → 0 → 1
     1 → 0 → -1

FPGA mapping implements this as transition-control logic.

Candidate blocks:

- current_state register
- target_state register
- transition_request detector
- polarity_conflict detector
- neutral_insert controller
- staged_commit controller
- transition_debt counter
- prevented_direct_events counter
- neutralized_conflicts counter

Neutral routing behavior:

| Current State | Target State | Commit Behavior | Routed Path |
|---|---|---|---|
| -1 | 1 | neutral first | -1 → 0 → 1 |
| 1 | -1 | neutral first | 1 → 0 → -1 |
| -1 | 0 | direct neutral commit | -1 → 0 |
| 1 | 0 | direct neutral commit | 1 → 0 |
| 0 | -1 | direct polarity commit | 0 → -1 |
| 0 | 1 | direct polarity commit | 0 → 1 |

The FPGA controller counts and exposes routed polarity transitions for validation.

## 7. Distributed Commit Scheduler

The current software layer uses distributed commit behavior.

Default transition cap:

    transition_fraction = 0.25

FPGA interpretation:

    transition_fraction becomes a commit bandwidth constraint

Candidate implementation blocks:

- global tick counter
- active transition mask
- commit eligibility selector
- transition budget counter
- staged update controller
- deferred transition queue
- transition_debt counter
- switch_load counter

Initial FPGA mapping target:

    update only a controlled fraction of eligible state cells per tick

This reproduces distributed transition behavior from the software model.

## 8. Scheduler Modes

Current scheduler modes:

| Mode | Tick Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

FPGA mapping may implement scheduler behavior through:

- scheduler counter
- cycle-mode register
- commit_phase signal
- balance_phase signal
- excite_phase signal
- neutralize_phase signal
- phase-specific enable signals

Candidate scheduler outputs:

| Signal | Role |
|---|---|
| commit_enable | permits staged state update |
| balance_enable | permits balancing phase behavior |
| excite_enable | permits excitation phase behavior |
| neutralize_enable | permits neutralization phase behavior |
| telemetry_sample_enable | enables per-tick telemetry capture |

The scheduler exposes counts for verification against the software reference behavior.

## 9. Register File Mapping

The current prototype includes a register file and processor instruction layer.

FPGA mapping may represent the register file as:

- small synchronous register array
- encoded ternary register bank
- instruction-visible state storage
- target-vector storage
- current-vector storage
- telemetry-visible state region

Candidate register groups:

| Register Group | Purpose |
|---|---|
| state_registers | current ternary state |
| target_registers | desired ternary target state |
| phase_registers | phase layer state |
| scheduler_registers | cycle mode and tick counters |
| metric_registers | C, P, C_minus_P, switch_load, transition debt |
| telemetry_registers | trace-visible counters and summary fields |

The first FPGA study can use a compact register file before exploring larger vector sizes.

## 10. Delay Buffer Mapping

The software model includes independent logic and coupling delay buffers.

FPGA mapping options:

- shift registers
- circular buffers
- small FIFO structures
- phase-history buffers
- state-history buffers
- coupling-history buffers

Candidate delay blocks:

| Delay Block | FPGA Structure |
|---|---|
| logic delay buffer | shift register or circular buffer |
| coupling delay buffer | shift register or circular buffer |
| phase delay buffer | fixed-depth phase-history register |
| telemetry delay trace | trace buffer or debug register bank |

Study objective:

    preserve timing relationship between current state, delayed state, and phase coupling behavior

## 11. Phase Layer Approximation

The current software layer includes a Kuramoto-Sakaguchi resonant phase layer.

Current phase parameter:

    gamma = 0.30π

FPGA mapping may approximate this layer through:

- fixed-point phase registers
- lookup tables
- iterative phase update logic
- reduced sine approximation
- phase-coupling approximation
- oscillator-inspired control block

Candidate phase block components:

| Component | Role |
|---|---|
| phase_register | stores current phase |
| omega_register | stores phase velocity or update parameter |
| gamma_parameter | stores phase offset parameter |
| coupling_block | applies approximate phase coupling |
| sine_lut | lookup table for sine approximation |
| phase_update_controller | updates phase per tick |
| R_metric_block | computes or approximates coherence-related phase metric |

Initial FPGA study priority:

    functional approximation aligned with software telemetry

Optimization can be handled in later implementation stages.

## 12. Nonlinear Saturation and Compression Mapping

The software layer includes:

- nonlinear cubic saturation
- nonlinear compression

FPGA mapping options:

- fixed-point arithmetic
- lookup-table approximation
- piecewise-linear approximation
- bounded arithmetic block
- saturation clamp logic
- compression scaling block

Candidate blocks:

| Block | Role |
|---|---|
| saturation_block | bounds nonlinear response |
| compression_block | applies controlled compression behavior |
| fixed_point_scaler | maps floating values into FPGA-friendly representation |
| lookup_table | supports approximate nonlinear response |
| clamp_logic | preserves bounded output behavior |

Study objective:

    reproduce the qualitative behavior of the software layer while keeping the block inspectable and testable

## 13. Coherence and Load Metric Mapping

Current software metrics include:

    C
    P
    C_minus_P
    heat
    thermal_scale
    switch_load
    transition_debt
    direct_conflict_fraction

FPGA mapping may represent these as:

- counters
- fixed-point accumulators
- summary registers
- trace outputs
- debug-visible telemetry values

Candidate metric blocks:

| Metric | FPGA-Oriented Representation |
|---|---|
| C | coherence accumulator or approximation register |
| P | load accumulator |
| C_minus_P | stability-margin register |
| heat | model-level activity metric |
| switch_load | transition activity metric |
| transition_debt | deferred transition counter |
| direct_conflict_fraction | conflict-ratio approximation |
| logical_match | target-match comparator output |

These metrics provide comparison points against Python reference runs.

## 14. Telemetry Mapping

The software reference model records per-tick telemetry.

FPGA mapping should expose a practical telemetry subset first.

Initial telemetry fields:

- tick
- scheduler phase
- current state counts
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

Candidate telemetry interfaces:

- memory-mapped register view
- UART debug stream
- simulation trace file
- FPGA testbench signal dump
- logic analyzer signal group
- structured host-side export

Telemetry objective:

    enable comparison against Python reference behavior and benchmark expectations

## 15. FPGA Testbench Strategy

The FPGA study includes a testbench plan.

Testbench inputs:

- initial ternary state vector
- target ternary state vector
- scheduler mode
- transition_fraction
- seed profile or deterministic vector profile
- phase parameters
- step count

Testbench outputs:

- final ternary state vector
- transition counters
- scheduler counters
- telemetry summary
- benchmark-compatible summary values

Testbench comparison target:

    Python reference output from frp_prototype_v0_9_3_mobile.py

Recommended comparison categories:

- final match
- actual_direct_events
- prevented_direct_events
- neutralized_conflicts
- switch_load_peak
- transition_debt
- scheduler counts
- telemetry length
- C_minus_P behavior

## 16. FPGA Study Profiles

Initial FPGA study profiles may include:

| Profile | Purpose |
|---|---|
| micro-state profile | small vector validation of ternary routing |
| scheduler profile | verify free, 7/1, and 1/7 scheduler behavior |
| neutral-routing profile | verify -1 → 0 → 1 and 1 → 0 → -1 routing |
| distributed-commit profile | verify transition_fraction behavior |
| telemetry profile | verify per-tick trace fields |
| benchmark-alignment profile | compare against Python benchmark output |

The first study favors clear traceability.

## 17. Suggested FPGA Block Diagram

Logical block structure:

    input vector
    → ternary decoder
    → transition request detector
    → neutral transition controller
    → distributed commit scheduler
    → state register bank
    → delay buffers
    → phase approximation block
    → nonlinear saturation and compression block
    → coherence and load metric block
    → telemetry output
    → testbench comparison layer

This block structure preserves the relationship between the software reference model and the FPGA-oriented study.

## 18. Validation Against Software Reference

The FPGA study compares outputs against the software reference model.

Reference command examples:

    python3 ../frp_prototype_v0_9_3_mobile.py --mode test --steps 128 --seeds 5

    python3 ../frp_prototype_v0_9_3_mobile.py --mode bench --steps 128 --seeds 5

Comparison categories:

- candidate invariants
- final state match
- direct transition safety
- distributed commit behavior
- scheduler behavior
- telemetry length
- benchmark architecture labels
- metric summary consistency

The Python reference model remains the behavioral anchor for the first FPGA study.

## 19. Expected FPGA Study Deliverables

Expected study deliverables:

- FPGA mapping study document
- state encoding proposal
- transition controller proposal
- scheduler mapping proposal
- delay buffer mapping proposal
- phase approximation proposal
- nonlinear block approximation proposal
- telemetry register proposal
- testbench plan
- Python-reference comparison plan
- implementation risk list
- FPGA prototype planning structure

## 20. Funding and Partner Relevance

The FPGA mapping study supports partner and funding conversations by showing a concrete implementation bridge.

Current project assets:

- executable software reference model
- reproducibility commands
- benchmark output
- CI verification
- hardware pathway document
- implementation layers document
- FPGA mapping study plan

Funding-facing technical message:

    FRP has a validated software reference layer and a concrete FPGA-oriented mapping path for implementation study.

This supports:

- engineering partner review
- FPGA development planning
- grant preparation
- laboratory collaboration
- implementation research planning
- later ASIC pathway development

## 21. Current Status

The FPGA mapping study defines the first programmable-hardware bridge from the current FRP software validation layer toward implementation-layer research.

The document provides an FPGA-oriented mapping structure for:

- ternary state encoding
- neutral transition routing
- distributed commit scheduling
- scheduler behavior
- register file mapping
- delay buffer mapping
- phase layer approximation
- nonlinear saturation and compression mapping
- coherence and load metric mapping
- telemetry mapping
- FPGA testbench planning
- comparison against the Python reference model
- funding and partner technical review

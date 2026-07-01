# ASIC Mapping Study — Fractal Resonance Processor (FRP)

This document defines the ASIC-oriented mapping study for the Fractal Resonance Processor (FRP) project.

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

## 1. Purpose

The purpose of this document is to describe how the current FRP software validation layer can be translated into an ASIC-oriented implementation study.

The ASIC mapping study connects the executable Python reference model with chip-oriented implementation research.

This document focuses on:

- ternary state representation
- neutral routing cell structure
- distributed commit timing network
- scheduler control logic
- local transition controller
- register and state storage structure
- phase approximation block
- nonlinear response block
- delay buffer cell structure
- coherence and load tracking
- telemetry and test interface
- validation against the Python reference model
- chip-oriented implementation research structure

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

The ASIC mapping study uses the software reference model as the behavioral anchor.

## 3. ASIC Mapping Objective

The primary ASIC mapping objective is:

    translate the FRP software reference behavior into chip-oriented architectural blocks

Initial ASIC study goals:

- define ternary state representation
- define neutral routing cell behavior
- define local transition control
- define distributed commit timing structure
- define scheduler control logic
- define register and state storage structures
- define phase approximation block
- define nonlinear response block
- define delay buffer structure
- define coherence and load metric blocks
- define telemetry and test interface
- preserve candidate invariants

The first ASIC study prioritizes behavioral traceability, implementation clarity, and validation structure.

## 4. Candidate Invariants for ASIC Study

The ASIC-oriented study preserves the current candidate invariants:

| Invariant | Required Result |
|---|---|
| target match | match = 1.000 |
| direct transition safety | actual_direct_events = 0 |
| stability | C_minus_P_min > 0 |
| transition load | switch_load_peak <= transition_fraction |
| telemetry | ticks_recorded = steps |
| scheduler | counts match selected cycle mode |

These invariants connect the ASIC study back to the current software validation layer.

## 5. Ternary State Representation

FRP uses balanced ternary states:

| State | Meaning |
|---|---|
| -1 | negative / inhibitory / counter-phase / suppressive state |
| 0 | neutral balancing / damping / transition state |
| 1 | positive / excitatory / phase-supporting / constructive state |

ASIC-oriented study may evaluate several representation strategies.

Candidate representation paths:

| Representation Path | Study Role |
|---|---|
| encoded binary-hosted ternary | practical digital abstraction for early ASIC study |
| multi-line ternary representation | separates negative, neutral, and positive state lines |
| voltage-level ternary representation | studies direct physical ternary signaling |
| symbolic ternary cell abstraction | defines cell behavior before physical specialization |
| mixed-control representation | combines binary control with ternary state semantics |

Initial study criteria:

- clear ternary state decoding
- neutral state preservation
- efficient transition control
- compatibility with local transition cells
- compatibility with distributed commit timing
- compatibility with telemetry and test interface
- compatibility with benchmark comparison

The selected representation should preserve the semantic role of the neutral state.

## 6. Neutral Routing Cell

The current FRP transition principle routes polarity changes through the neutral state.

Transition path:

    -1 → 0 → 1
     1 → 0 → -1

ASIC mapping may represent this behavior through a neutral routing cell.

Candidate neutral routing cell inputs:

- current_state
- target_state
- commit_enable
- scheduler_phase
- transition_budget_available
- local_conflict_detected

Candidate neutral routing cell outputs:

- next_state
- neutral_inserted
- transition_deferred
- direct_event_counter_enable
- prevented_event_counter_enable
- neutralized_conflict_counter_enable
- transition_debt_increment

Neutral routing behavior:

| Current State | Target State | Commit Behavior | Routed Path |
|---|---|---|---|
| -1 | 1 | neutral first | -1 → 0 → 1 |
| 1 | -1 | neutral first | 1 → 0 → -1 |
| -1 | 0 | direct neutral commit | -1 → 0 |
| 1 | 0 | direct neutral commit | 1 → 0 |
| 0 | -1 | direct polarity commit | 0 → -1 |
| 0 | 1 | direct polarity commit | 0 → 1 |

The neutral routing cell is a core ASIC-facing building block.

## 7. Local Transition Controller

Each ternary cell or local state group may require a transition controller.

Candidate controller responsibilities:

- compare current state with target state
- detect polarity conflict
- apply neutral insertion
- respect commit enable
- respect transition budget
- update local state
- expose local transition telemetry
- update transition debt
- provide validation counters

Candidate local controller signals:

| Signal | Role |
|---|---|
| current_state | current ternary state |
| target_state | desired ternary target |
| next_state | resolved next ternary state |
| commit_enable | permits local update |
| neutral_insert | routes polarity change through neutral |
| transition_defer | delays update into later commit window |
| local_switch_event | contributes to switch_load |
| local_conflict_event | contributes to conflict metrics |

The local transition controller translates the FRP transition rule into implementation-oriented logic.

## 8. Distributed Commit Timing Network

The current software layer uses distributed commit behavior.

Default transition cap:

    transition_fraction = 0.25

ASIC interpretation:

    transition_fraction becomes a distributed commit timing and activity-control parameter

Candidate timing network components:

- global tick source
- scheduler phase generator
- commit window generator
- transition budget allocator
- local commit enable distribution
- staged update network
- deferred transition queue
- transition activity monitor
- switch_load accumulator

Initial ASIC mapping target:

    control the fraction of eligible state cells updated per tick

This structure preserves distributed transition behavior from the software reference model.

## 9. Scheduler Control Logic

Current scheduler modes:

| Mode | Tick Behavior |
|---|---|
| free | every tick is commit |
| 7/1 | ticks 0..6 are balance, tick 7 is commit |
| 1/7 | tick 0 is excite, ticks 1..7 are neutralize |

ASIC mapping may implement scheduler behavior through a timing-control block.

Candidate scheduler signals:

| Signal | Role |
|---|---|
| tick_counter | global tick index |
| cycle_mode | selected scheduler mode |
| commit_phase | enables commit behavior |
| balance_phase | enables balancing behavior |
| excite_phase | enables excitation behavior |
| neutralize_phase | enables neutralization behavior |
| telemetry_sample_enable | enables per-tick telemetry capture |

Candidate scheduler blocks:

- cycle counter
- mode register
- phase decoder
- commit enable generator
- balance enable generator
- excite enable generator
- neutralize enable generator
- telemetry sampling control

The scheduler control logic provides the timing structure for distributed FRP behavior.

## 10. State Storage and Register Structure

The current prototype includes a register file and processor instruction layer.

ASIC mapping may define multiple register categories.

Candidate register groups:

| Register Group | Purpose |
|---|---|
| state_registers | current ternary state storage |
| target_registers | desired target state storage |
| phase_registers | phase layer state |
| scheduler_registers | cycle mode and tick counters |
| metric_registers | C, P, C_minus_P, switch_load, transition debt |
| telemetry_registers | trace-visible counters and summary fields |
| control_registers | execution mode, step count, validation configuration |
| test_registers | testbench and scan-facing signals |

Candidate storage structures:

- encoded ternary register array
- local state cell group
- target state buffer
- scheduler state register
- metric accumulator register
- telemetry trace register
- test access register

The storage structure should preserve comparison against the software reference model.

## 11. Delay Buffer Cell Structure

The software model includes independent logic and coupling delay buffers.

ASIC mapping may represent delay behavior through dedicated buffer structures.

Candidate delay structures:

| Delay Structure | Role |
|---|---|
| logic delay chain | stores previous logic states |
| coupling delay chain | stores previous coupling values |
| phase history buffer | stores phase-history values |
| state history buffer | stores prior ternary states |
| telemetry trace buffer | stores selected validation values |

Possible implementation structures:

- shift register chain
- local delay cell array
- circular buffer abstraction
- staged history register
- small memory-backed trace buffer

Study objective:

    preserve timing relationship between current state, delayed state, and phase coupling behavior

## 12. Phase Approximation Block

The current software layer includes a Kuramoto-Sakaguchi resonant phase layer.

Current phase parameter:

    gamma = 0.30π

ASIC mapping may represent this layer through an approximation block.

Candidate phase block components:

| Component | Role |
|---|---|
| phase_register | stores current phase |
| omega_register | stores phase velocity or update parameter |
| gamma_parameter | stores phase offset parameter |
| coupling_block | applies approximate phase coupling |
| sine_approximation | provides trigonometric approximation |
| phase_update_controller | updates phase per tick |
| R_metric_block | computes or approximates coherence-related phase metric |

Candidate approximation strategies:

- fixed-point arithmetic
- lookup table
- piecewise approximation
- CORDIC-style approximation
- oscillator-inspired control structure
- hybrid lookup and arithmetic approach

Initial ASIC study priority:

    functional alignment with software telemetry and benchmark behavior

## 13. Nonlinear Response Block

The software layer includes:

- nonlinear cubic saturation
- nonlinear compression

ASIC mapping may represent these through a nonlinear response block.

Candidate block components:

| Block | Role |
|---|---|
| saturation_block | bounds nonlinear response |
| compression_block | applies controlled compression behavior |
| fixed_point_scaler | maps software values into implementation-friendly representation |
| lookup_table | supports approximate nonlinear response |
| clamp_logic | preserves bounded output behavior |
| response_accumulator | collects nonlinear response contribution |

Candidate approximation strategies:

- fixed-point cubic approximation
- lookup table approximation
- piecewise-linear approximation
- bounded arithmetic
- scaling and clamp logic

Study objective:

    preserve the functional behavior of nonlinear response while keeping the block inspectable and testable

## 14. Coherence and Load Tracking

Current software metrics include:

    C
    P
    C_minus_P
    heat
    thermal_scale
    switch_load
    transition_debt
    direct_conflict_fraction

ASIC mapping may represent these as:

- counters
- fixed-point accumulators
- summary registers
- test-visible values
- telemetry registers

Candidate metric blocks:

| Metric | ASIC-Oriented Representation |
|---|---|
| C | coherence accumulator or approximation register |
| P | load accumulator |
| C_minus_P | stability-margin register |
| heat | model-level activity metric |
| thermal_scale | scaling parameter |
| switch_load | transition activity metric |
| transition_debt | deferred transition counter |
| direct_conflict_fraction | conflict-ratio approximation |
| logical_match | target-match comparator output |

These metric blocks support validation against Python reference runs.

## 15. Telemetry and Test Interface

The software reference model records per-tick telemetry.

ASIC-oriented study may define a telemetry and test interface.

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

- memory-mapped register interface
- scan-visible register set
- simulation trace export
- debug bus
- logic analyzer signal group
- structured host-side export
- benchmark summary register block

Telemetry objective:

    enable comparison against Python reference behavior and benchmark expectations

## 16. ASIC Testbench Strategy

The ASIC mapping study includes a testbench structure.

Testbench inputs:

- initial ternary state vector
- target ternary state vector
- scheduler mode
- transition_fraction
- deterministic vector profile
- seed-derived vector profile
- phase parameters
- step count

Testbench outputs:

- final ternary state vector
- transition counters
- scheduler counters
- telemetry summary
- benchmark-compatible summary values
- trace-visible validation values

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
- metric summary consistency

## 17. Candidate ASIC Block Diagram

Logical block structure:

    input vector
    → ternary state decoder
    → local transition controller
    → neutral routing cell
    → distributed commit timing network
    → state storage array
    → delay buffer cells
    → phase approximation block
    → nonlinear response block
    → coherence and load tracking block
    → telemetry and test interface
    → Python-reference comparison layer

This block structure preserves traceability between the software reference model and ASIC-oriented implementation research.

## 18. Validation Against Software Reference

The ASIC study compares behavior against the software reference model.

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
- transition counters
- coherence and load behavior

The Python reference model remains the behavioral anchor for the ASIC study.

## 19. ASIC Study Profiles

Initial ASIC study profiles may include:

| Profile | Purpose |
|---|---|
| ternary cell profile | validates ternary state representation |
| neutral routing profile | validates polarity routing through neutral state |
| distributed commit profile | validates transition_fraction behavior |
| scheduler profile | validates free, 7/1, and 1/7 scheduler modes |
| phase approximation profile | validates phase block behavior against software reference |
| nonlinear response profile | validates saturation and compression approximation |
| telemetry profile | validates counters and trace outputs |
| benchmark-alignment profile | compares ASIC-oriented behavior against Python benchmark output |

The first ASIC study favors clear validation structure and traceability.

## 20. Expected ASIC Study Deliverables

Expected study deliverables:

- ASIC mapping study document
- ternary state representation proposal
- neutral routing cell proposal
- local transition controller proposal
- distributed commit timing proposal
- scheduler control proposal
- state storage proposal
- phase approximation proposal
- nonlinear response proposal
- telemetry and test interface proposal
- ASIC testbench plan
- Python-reference comparison plan
- implementation risk list
- chip-oriented implementation research structure

## 21. Funding and Partner Relevance

The ASIC mapping study supports partner and funding conversations by showing a chip-oriented implementation path.

Current project assets:

- executable software reference model
- reproducibility commands
- benchmark output
- CI verification
- hardware pathway document
- implementation layers document
- FPGA mapping study document
- ASIC mapping study structure

Funding-facing technical message:

    FRP has a validated software reference layer and a chip-oriented mapping path for implementation research.

This supports:

- engineering partner review
- chip-oriented implementation planning
- grant preparation
- laboratory collaboration
- implementation research planning
- physical validation planning

## 22. Current Status

The ASIC mapping study defines the chip-oriented implementation research bridge from the current FRP software validation layer toward ASIC-level architectural study.

The document provides an ASIC-oriented mapping structure for:

- ternary state representation
- neutral routing cell structure
- local transition control
- distributed commit timing network
- scheduler control logic
- state storage and register structure
- delay buffer cell structure
- phase approximation block
- nonlinear response block
- coherence and load tracking
- telemetry and test interface
- ASIC testbench planning
- comparison against the Python reference model
- funding and partner technical review

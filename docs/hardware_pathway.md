# Hardware Pathway — Fractal Resonance Processor (FRP)

This document defines the hardware-facing development pathway for the Fractal Resonance Processor (FRP) project.

Current candidate version:

    v0.9.3-mobile

Current public repository package:

    software validation layer, documentation layer, reproducibility layer, benchmark layer, and CI verification layer

Main prototype file:

    ../frp_prototype_v0_9_3_mobile.py

Current test report:

    ../TEST_REPORT_v0_9_3.md

## 1. Purpose

The purpose of this document is to describe how the current FRP software validation layer can support later hardware-facing specification, FPGA mapping, ASIC mapping, chip-oriented implementation research, and physical validation planning.

The current public repository establishes an executable software foundation.

That foundation includes:

- balanced ternary state logic
- neutral transition routing
- distributed commit behavior
- Kuramoto-Sakaguchi resonant phase layer
- nonlinear saturation
- nonlinear compression
- delay dynamics
- scheduler modes
- per-tick telemetry
- benchmark execution
- reproducibility commands
- automated CI verification

This software layer provides the current engineering basis for the next hardware-facing development stages.

## 2. Current Validated Layer

The current validated layer is the FRP software execution layer.

It is validated through:

- Python source execution
- standard self-test
- heavy self-test
- benchmark execution
- reproducibility commands
- GitHub Actions workflow execution
- documented candidate invariants
- public repository documentation

The current software package has been executed on general-purpose computing infrastructure.

This provides an executable reference model for later implementation-layer work.

## 3. Engineering Trajectory

The FRP hardware pathway follows this staged trajectory:

    software validation
    → architecture stabilization
    → hardware-facing specification
    → FPGA mapping study
    → ASIC mapping study
    → chip-oriented implementation research
    → physical validation planning

Each stage inherits from the previous stage.

The software layer defines the operational behavior.

The hardware-facing layer translates that behavior into implementation-oriented terms.

The FPGA and ASIC studies evaluate possible implementation routes.

The physical validation layer defines measurement, test, and verification procedures for future physical implementations.

## 4. Software Layer as Executable Reference

The current prototype acts as an executable reference model.

It defines:

- state space
- transition rules
- neutral routing behavior
- distributed commit logic
- scheduler behavior
- phase evolution behavior
- coherence tracking
- destabilizing load tracking
- benchmark behavior
- telemetry structure

The executable reference model is important because later hardware-facing work requires a stable behavioral target.

The software layer provides that target.

## 5. Balanced Ternary State Mapping

FRP uses balanced ternary states:

| State | Functional Meaning |
|---|---|
| `-1` | negative / inhibitory / counter-phase / suppressive state |
| `0` | neutral balancing / damping / transition state |
| `1` | positive / excitatory / phase-supporting / constructive state |

A hardware-facing representation must preserve the ternary state model.

Possible implementation study topics:

- ternary state encoding
- binary-hosted ternary encoding
- multi-line ternary representation
- voltage-level ternary representation
- symbolic ternary representation for FPGA study
- logic-cell representation for ASIC study
- neutral-state preservation
- polarity-safe transition control

The first hardware-facing objective is behavioral equivalence with the software layer.

## 6. Neutral Transition Routing

The current software layer routes polarity changes through the neutral state.

Transition pattern:

    -1 → 0 → 1
     1 → 0 → -1

The neutral state acts as:

- transition buffer
- conflict neutralizer
- damping state
- polarity bridge
- switching-load guard
- scheduling control point

Hardware-facing work should preserve this routing principle.

Candidate implementation topics:

- neutral transition controller
- transition staging register
- conflict detection logic
- neutral insertion logic
- direct polarity event counter
- transition debt counter
- distributed commit controller

The neutral transition path is a core FRP invariant.

## 7. Distributed Commit as Scheduling Constraint

The current prototype uses distributed commit behavior.

Default transition cap:

    transition_fraction = 0.25

This means the software layer limits the fraction of state transitions committed per tick under default settings.

Hardware-facing interpretation:

- distributed commit can be treated as a scheduling constraint
- transition load can be treated as an implementation-level control metric
- transition_fraction can be mapped to commit bandwidth
- staged transition groups can be mapped to controlled update regions
- scheduler cycles can be mapped to timing phases

Candidate implementation topics:

- commit scheduler
- grouped state update
- phased transition controller
- tick-level commit window
- local transition budget
- global transition budget
- transition load telemetry

## 8. Scheduler Mapping

Current scheduler modes:

| Mode | Tick Behavior |
|---|---|
| `free` | every tick is commit |
| `7/1` | ticks `0..6` are balance, tick `7` is commit |
| `1/7` | tick `0` is excite, ticks `1..7` are neutralize |

Hardware-facing interpretation:

- scheduler mode can become a timing-control layer
- balance ticks can become stabilization phases
- commit ticks can become state-update phases
- excite ticks can become activation phases
- neutralize ticks can become damping or balancing phases

Candidate implementation topics:

- clock-domain planning
- timing-phase controller
- scheduler counter
- phase-select logic
- commit enable signal
- balance enable signal
- neutralization enable signal

## 9. Kuramoto-Sakaguchi Phase Layer Mapping

The current software layer includes a Kuramoto-Sakaguchi resonant phase layer.

Current phase parameter:

    gamma = 0.30π

Hardware-facing interpretation:

- the phase layer can be represented as a numerical phase engine
- the phase layer can be approximated through lookup tables
- the phase layer can be mapped to fixed-point arithmetic
- the phase layer can be represented through oscillator-inspired control logic
- the phase layer can be evaluated as a separate implementation block

Candidate implementation topics:

- phase register
- phase coupling approximation
- fixed-point phase representation
- phase drift update
- coupling coefficient representation
- sine approximation
- lookup-table strategy
- oscillator-inspired mapping
- resonant phase telemetry

The first hardware-facing goal is functional equivalence with the software phase behavior.

## 10. Nonlinear Saturation and Compression Mapping

The current software layer includes:

- nonlinear cubic saturation
- nonlinear compression

Hardware-facing interpretation:

- nonlinear behavior can be mapped through arithmetic approximation
- saturation can be implemented as bounded response logic
- compression can be implemented as controlled scaling
- lookup tables may support efficient approximations
- fixed-point design may support implementation-layer study

Candidate implementation topics:

- saturation block
- compression block
- lookup-table approximation
- fixed-point scaling
- bounded arithmetic
- overflow behavior
- telemetry of nonlinear response

## 11. Delay Buffer Mapping

The current prototype includes independent logic and coupling delay buffers.

Hardware-facing interpretation:

- delay buffers can map to shift registers
- delay buffers can map to FIFO-like structures
- coupling delay can map to staged signal history
- logic delay can map to state-history registers

Candidate implementation topics:

- delay register chain
- circular buffer
- phase delay buffer
- logic delay buffer
- coupling history buffer
- delay-depth parameterization

Delay behavior must remain aligned with the software reference model.

## 12. Coherence and Load Metrics

The current software layer tracks:

    C(t)
    P(t)
    C_minus_P

where:

| Symbol | Meaning |
|---|---|
| `C(t)` | operational coherence |
| `P(t)` | destabilizing load |
| `C_minus_P` | stability margin |

Current relation:

    C_minus_P = C(t) - P(t)

Current load model:

    P(t) = heat + switch_load

Hardware-facing interpretation:

- C can become an operational coherence metric
- P can become an implementation-level load metric
- C_minus_P can become a stability-margin metric
- switch_load can become a transition activity metric
- heat can become a model-to-measurement bridge in later validation stages

Candidate implementation topics:

- coherence counter
- transition activity counter
- switching-load monitor
- stability-margin register
- telemetry bus
- benchmark metric export
- validation metric mapping

## 13. Per-Tick Telemetry Mapping

The current software layer records per-tick telemetry.

Telemetry fields include:

- tick
- phase
- R
- phi
- neutral
- positive
- negative
- heat
- thermal_scale
- switch_load
- actual_direct_events_delta
- prevented_direct_events_delta
- neutralized_conflicts_delta
- logical_match
- transition_debt
- direct_conflict_fraction
- C
- P
- C_minus_P

Hardware-facing interpretation:

- telemetry can become debug output
- telemetry can become simulation trace output
- telemetry can become validation signal set
- telemetry can become benchmark measurement interface
- telemetry can guide physical validation planning

Candidate implementation topics:

- telemetry register map
- trace buffer
- debug interface
- benchmark interface
- validation counters
- structured output profile

## 14. FPGA Mapping Study Path

An FPGA mapping study may evaluate FRP behavior through programmable hardware.

Candidate study areas:

- ternary state encoding on binary FPGA fabric
- neutral transition routing
- distributed commit scheduler
- register file mapping
- phase layer approximation
- nonlinear saturation approximation
- compression approximation
- delay buffer implementation
- telemetry counters
- benchmark harness
- reproducibility profile
- validation against software reference output

Expected FPGA study output:

- FPGA mapping document
- implementation block diagram
- state encoding proposal
- scheduler mapping proposal
- telemetry mapping proposal
- testbench plan
- comparison plan against the Python reference model

## 15. ASIC Mapping Study Path

An ASIC mapping study may evaluate chip-oriented implementation routes for FRP architecture.

Candidate study areas:

- ternary logic cell representation
- neutral routing cell
- distributed commit timing network
- local transition controller
- phase approximation block
- coherence tracking block
- transition load monitor
- delay buffer cells
- telemetry and test interface
- physical measurement planning
- chip-oriented validation harness

Expected ASIC study output:

- ASIC mapping document
- cell-level abstraction plan
- timing model outline
- test structure outline
- validation metric list
- physical measurement plan
- chip-oriented implementation research plan

## 16. Physical Validation Planning

Physical validation planning should define how a future implementation can be tested.

Candidate validation categories:

- logical correctness
- target matching
- direct transition safety
- neutral routing behavior
- distributed commit behavior
- scheduler behavior
- transition activity
- coherence behavior
- load behavior
- timing behavior
- energy behavior
- thermal behavior
- benchmark repeatability

Expected physical validation outputs:

- validation protocol
- measurement plan
- testbench design
- benchmark profile
- telemetry mapping
- comparison method against the software reference model

## 17. Funding and Partner Relevance

The current FRP repository provides a financing-facing technical foundation.

Current validated assets:

- executable software model
- documented candidate invariants
- reproducibility commands
- benchmark output
- automated CI workflows
- documentation package
- release checklist
- roadmap
- licensing and citation metadata

Funding-facing message:

    FRP has a public software validation layer and a defined engineering pathway toward hardware-facing specification, FPGA/ASIC mapping, chip-oriented implementation research, and physical validation planning.

This creates a clear basis for:

- engineering partnership
- laboratory collaboration
- grant application
- prototype planning
- implementation research
- archival release preparation
- investor-facing technical review

## 18. Recommended Next Documents

Recommended next hardware-facing documents:

1. docs/implementation_layers.md
2. docs/fpga_mapping_study.md
3. docs/asic_mapping_study.md
4. docs/physical_validation_plan.md
5. funding_brief.md

Recommended next technical focus:

    connect each hardware-facing document back to the validated software reference model

## 19. Current Status

The FRP v0.9.3-mobile repository establishes the public software validation layer.

The current software layer has been executed and verified on general-purpose computing infrastructure.

This layer provides the executable reference model for:

- hardware-facing specification
- FPGA mapping study
- ASIC mapping study
- chip-oriented implementation research
- physical validation planning
- funding and partner preparation

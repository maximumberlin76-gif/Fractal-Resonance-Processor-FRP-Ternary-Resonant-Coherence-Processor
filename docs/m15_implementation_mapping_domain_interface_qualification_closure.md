# FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package

## Milestone Scope

FRP v1.7.0 establishes the M15 Implementation Mapping, Domain Interface, and Qualification Closure Package layer of the Fractal Resonance Processor reference architecture.

M15 extends the published FRP v1.6.0 Physical Implementation Correlation and Production Qualification Package layer into a quantized hardware-interface, cycle-exact reference-trace, RTL comparison-vector, synthesizable RTL reference-core, SystemVerilog correlation, and qualification-closure layer.

The M15 architecture defines the bridge:

`M14 floating semantic reference`

↓

`M15 quantized hardware shadow model`

↓

`cycle-exact integer golden trace`

↓

`synthesizable RTL reference core`

↓

`SystemVerilog comparison harness`

↓

`exact quantized shadow ↔ RTL equivalence`

M15 does not replace the validated M14 semantic reference architecture.

M15 maps the validated M14 architecture into deterministic hardware-facing representations while preserving the FRP computational kernel.

## M15 Position in the FRP Roadmap

M8 established the stable production release package and public interface freeze.

M9 established the silicon-facing and heterogeneous implementation architecture layer.

M10 established the silicon production and tapeout readiness package.

M11 established the production integration and external implementation handoff layer.

M12 established the external implementation feedback and production iteration loop.

M13 established thermal saturation dynamics, lagged frequency response, nonlinear coherence compression, correlated thermal Sakaguchi gamma drift, stability-boundary detection, recovery dynamics, and production scaling stability-envelope generation.

M14 established dyadic hierarchical ultrametric topology, shell-normalized fractal coupling, local phase-coherence domains, cluster-local thermal fields, independent phase-coupling and thermal-diffusion topologies, localized hotspot containment, dense-to-hierarchical equivalence, and physical-domain production qualification.

M15 extends the published M14 architecture into:

- explicit hardware-facing binary encodings;

- deterministic fixed-point arithmetic profiles;

- quantized hardware shadow execution;

- cycle-exact reference traces;

- deterministic RTL comparison vectors;

- parameterized request-lane interfaces;

- verification preload and deterministic stimulus sidebands;

- synthesizable RTL reference-core targets;

- SystemVerilog vector replay;

- assertion-based cycle correlation;

- semantic reference-to-quantized correlation;

- exact quantized reference-to-RTL equivalence;

- qualification closure.

## Published M14 Validation Boundary

Published release boundary:

`FRP v1.6.0 — M14 Physical Implementation Correlation and Production Qualification Package`

Published release status:

`GitHub Release: PUBLISHED`

Inherited executable reference file:

`frp_prototype_v1_6_0.py`

Inherited validation index:

`FRP_VALIDATION_INDEX_v1_6_0.md`

Inherited release notes:

`RELEASE_NOTES_v1_6_0.md`

Inherited test report:

`TEST_REPORT_v1_6_0.md`

Inherited validated commit:

`09141fc`

Inherited validation environment:

`GitHub Actions hardware-backed CI execution`

Inherited validated M14 workflow:

`FRP M14 Physical Implementation Correlation and Production Qualification #1`

## Main Executable Reference File Target

Main executable reference file target:

`frp_prototype_v1_7_0.py`

## M15 Non-Negotiable Kernel Boundary

M15 preserves the validated FRP computational kernel.

Balanced ternary states remain:

`-1`

`0`

`1`

The neutral state remains:

`0`

The neutral state remains an active balancing, damping, transition, and stabilization state.

Validated polarity-transition routes remain:

`-1 → 0 → 1`

`1 → 0 → -1`

Direct opposite-polarity requests remain intercepted.

The target polarity remains retained through the pending neutral transition route.

The target polarity remains applied on a subsequent processor tick.

The following relation remains forbidden:

`-1 → 1 in one processor tick`

The following relation remains forbidden:

`1 → -1 in one processor tick`

The inherited counters remain:

`requested_direct_events`

`prevented_direct_events`

`actual_direct_events`

`neutral_routed_events`

`neutralized_conflicts`

The inherited kernel invariant remains:

`actual_direct_events = 0`

## Tick-Separated Neutral Route Preservation

The M15 hardware-facing execution contract preserves:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

The neutral-route state must remain externally traceable.

The M15 trace layer records:

- pending route count;

- pending route cell identifier;

- pending route target state;

- pending route ready tick;

- route application tick.

The M15 RTL assertion layer must detect:

- same-tick opposite-polarity application;

- target application before ready tick;

- dropped pending route;

- duplicated route application;

- unexpected nonzero `actual_direct_events`.

## Preserved Scheduler Boundary

M15 preserves:

`free`

`7/1`

`1/7`

The scheduler modes remain independent of the hierarchical interaction topology.

The scheduler modes remain explicit runtime or configuration values.

The scheduler count relation remains:

`sum(scheduler_counts) = ticks_recorded`

The M15 vector package must contain explicit qualification suites for:

`free`

`7/1`

`1/7`

The scheduler layer must remain present in:

- the Python semantic reference path;

- the M15 quantized shadow path;

- the cycle-exact vector package;

- the synthesizable RTL reference core;

- the SystemVerilog comparison harness.

## Preserved Transition-Fraction Boundary

M15 preserves:

`transition_fraction`

The default reference value remains:

`transition_fraction = 0.25`

The maximum number of state applications per tick remains derived from the configured transition limit.

For hardware-facing profiles, the request-lane count is exported as an explicit integer configuration value.

Reference relation:

`REQUEST_LANES = max_changes`

Reference scaling profiles:

`8 cells → 2 request lanes`

`16 cells → 4 request lanes`

`32 cells → 8 request lanes`

for:

`transition_fraction = 0.25`

The RTL interface must not recompute request-lane count from floating-point values.

The request-lane count is a fixed configuration parameter for each generated profile.

## Preserved M14 Hierarchical Topology

M15 preserves the M14 exact dyadic topology.

Required relation:

`num_cells = 2^L`

where:

`L = hierarchy depth`

Inherited hierarchical distance:

`hierarchical_distance(i,j) = bit_length(i XOR j)`

for:

`i != j`

Inherited diagonal relation:

`hierarchical_distance(i,i) = 0`

Inherited shell population:

`shell_population(d) = 2^(d - 1)`

Inherited shell-normalized phase coupling:

`W_raw(i,j) = 1 / (2^(d - 1) × d^alpha)`

Inherited shell-normalized thermal diffusion:

`T_raw(i,j) = 1 / (2^(d - 1) × d^beta)`

M15 must preserve:

- topology row normalization;

- topology symmetry;

- topology zero diagonal;

- shell-population relation;

- shell-influence monotonicity;

- independent `W_ij` and `T_ij` interaction paths.

## Preserved M14 Thermal and Coherence Domains

M15 preserves:

`heat_i`

`generated_power_i`

`thermal_dissipation_i`

`thermal_diffusion_i`

`thermal_overload_i`

`gamma_noise_state_i`

`gamma_noise_target_i`

`gamma_effective_i`

`gamma_drift_i`

`pair_domain_coherence`

`cluster_coherence`

`supercluster_coherence`

`global_phase_coherence`

`C(t)`

`P(t)`

`C_minus_P`

The inherited global candidate stability relation remains:

`C(t) > P(t)`

The inherited pressure relation remains:

`P(t) = heat + switch_load`

M15 must not reduce the M14 distributed thermal field back to one undifferentiated local state.

## M15 Architecture Role

M15 defines the Implementation Mapping, Domain Interface, and Qualification Closure Package layer.

The M15 architecture separates three execution domains:

`floating semantic reference`

↓

`quantized hardware shadow reference`

↓

`RTL implementation`

The domains have distinct validation roles.

The floating semantic reference preserves the published M14 architecture.

The quantized hardware shadow reference defines the exact integer arithmetic contract.

The RTL implementation must match the quantized hardware shadow reference cycle by cycle.

## Two-Level Equivalence Model

M15 defines two different equivalence relations.

### Level 1 — Semantic Correlation

`M14 floating semantic reference`

↔

`M15 quantized hardware shadow reference`

This comparison allows bounded numeric quantization error.

It must preserve categorical and structural invariants.

Required preserved invariants include:

`balanced ternary state sequence`

`neutral-route sequence`

`scheduler sequence`

`actual_direct_events = 0`

`topology hierarchy`

`C_minus_P sign`

`boundary-event ordering`

### Level 2 — Exact Cycle Equivalence

`M15 quantized hardware shadow reference`

↔

`M15 RTL reference core`

This comparison is integer exact.

Required relation:

`all compared integer fields match exactly`

The RTL layer is not compared directly against unconstrained floating-point values.

## M15 Core Artifact Layers

M15 defines ten primary artifact layers:

1. `fixed_point_interface_profile`;

2. `balanced_ternary_hardware_encoding_map`;

3. `quantized_reference_shadow_model`;

4. `cycle_exact_reference_trace`;

5. `rtl_comparison_vector_package`;

6. `systemverilog_testbench_interface_map`;

7. `synthesizable_rtl_reference_core`;

8. `rtl_assertion_correlation_harness`;

9. `reference_rtl_equivalence_report`;

10. `qualification_closure_manifest`.

## Planned M15 Export Commands

Fixed-point interface profile:

`python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile`

Balanced ternary hardware encoding map:

`python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map`

Quantized reference shadow model:

`python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model`

Cycle-exact reference trace:

`python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace`

RTL comparison vector package:

`python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package`

SystemVerilog testbench interface map:

`python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map`

Synthesizable RTL reference core map:

`python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core`

RTL assertion correlation harness:

`python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness`

Reference RTL equivalence report:

`python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report`

Qualification closure manifest:

`python frp_prototype_v1_7_0.py --export-qualification-closure-manifest`

Benchmark matrix:

`python frp_prototype_v1_7_0.py --export-benchmark-matrix`

## Planned M15 Schemas

`frp.m15.fixed_point_interface_profile.v1.7.0`

`frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0`

`frp.m15.quantized_reference_shadow_model.v1.7.0`

`frp.m15.cycle_exact_reference_trace.v1.7.0`

`frp.m15.rtl_comparison_vector_package.v1.7.0`

`frp.m15.systemverilog_testbench_interface_map.v1.7.0`

`frp.m15.synthesizable_rtl_reference_core.v1.7.0`

`frp.m15.rtl_assertion_correlation_harness.v1.7.0`

`frp.m15.reference_rtl_equivalence_report.v1.7.0`

`frp.m15.qualification_closure_manifest.v1.7.0`

## Fixed-Point Interface Profile

M15 defines explicit hardware-facing numeric types.

The fixed-point profile must define:

- total word width;

- fractional width;

- signedness;

- quantization rule;

- saturation rule;

- overflow rule;

- phase wrapping rule;

- multiply rule;

- accumulation rule;

- comparison rule.

## Canonical Scalar Fixed-Point Type

General dynamic scalar type:

`S32Q16`

Definition:

`signed 32-bit integer`

with:

`16 fractional bits`

Scale relation:

`real_value = integer_value / 65536`

The type is used for:

- frequency;

- frequency target;

- frequency lag;

- generated power;

- heat;

- thermal dissipation;

- thermal diffusion;

- thermal overload;

- coupling field;

- C(t);

- P(t);

- C_minus_P.

## Canonical Unit-Interval Type

Normalized coefficient type:

`S32Q30`

Definition:

`signed 32-bit integer`

with:

`30 fractional bits`

The type is used for:

- sine output;

- cosine output;

- normalized phase-coupling weights;

- normalized thermal-diffusion weights;

- thermal node factors;

- phase-coherence values;

- coherence compression factors.

Nominal numeric domain:

`[-1, 1]`

for trigonometric values.

Nominal numeric domain:

`[0, 1]`

for normalized weights and coherence values.

## Binary Phase Representation

M15 maps phase into a 32-bit binary phase word.

Type:

`PHASE_U32`

Definition:

`unsigned 32-bit phase accumulator`

Mapping:

`0x00000000 → 0`

`0x40000000 → pi / 2`

`0x80000000 → pi`

`0xC0000000 → 3 pi / 2`

Phase wrap relation:

`2^32 phase units → 2 pi`

Floating-to-phase mapping:

`phase_word = round((phase mod 2 pi) / (2 pi) × 2^32) mod 2^32`

The M15 RTL phase datapath operates on binary phase words.

## Gamma Phase-Offset Representation

The Sakaguchi gamma phase offset uses the same phase scale.

Type:

`GAMMA_S32`

Definition:

`signed 32-bit phase offset`

Mapping relation:

`gamma_word = round(gamma / (2 pi) × 2^32)`

The nominal M14 value remains:

`gamma_nominal = 0.30 pi`

The nominal gamma value is quantized into the M15 phase-offset domain.

## Deterministic Quantization Rule

M15 uses explicit round-to-nearest with half cases away from zero.

For nonnegative scaled value x:

`quantized = floor(x + 0.5)`

For negative scaled value x:

`quantized = ceil(x - 0.5)`

The quantization rule must be identical in:

- Python quantized shadow execution;

- vector generation;

- SystemVerilog helper functions;

- RTL arithmetic units.

Python implementation-defined default rounding behavior must not be used as the normative hardware contract.

## Saturation Rule

Every destination type uses deterministic saturation.

For signed width W:

`minimum = -2^(W - 1)`

`maximum = 2^(W - 1) - 1`

Values below minimum saturate to minimum.

Values above maximum saturate to maximum.

Wraparound overflow is not the M15 default numeric behavior.

Phase accumulation remains the explicit exception.

Phase accumulation wraps modulo:

`2^32`

## Canonical Fixed-Point Multiply Operators

M15 defines explicit multiply operators.

For two `S32Q30` values:

`mul_q30(a,b) = round_shift(a × b, 30)`

For two `S32Q16` values:

`mul_q16(a,b) = round_shift(a × b, 16)`

For `S32Q16 × S32Q30`:

`mul_q16_q30(a,b) = round_shift(a × b, 30)`

The multiplication product uses a wider intermediate representation before rounding and saturation.

## Accumulation Rule

Per-cell interaction sums use widened signed accumulators.

The accumulator width must prevent intermediate overflow for the configured:

- cell count;

- hierarchy depth;

- request-lane count;

- weight profile.

The final accumulator result is rounded and saturated only when written into its destination type.

M15 validation must detect:

- accumulator overflow;

- unexpected saturation;

- width mismatch.

## Deterministic Trigonometric Profile

The M15 quantized hardware shadow and RTL reference core require the same trigonometric contract.

Reference trigonometric profile:

`4096-entry full-cycle lookup table`

Lookup address width:

`12 bits`

Phase index relation:

`lut_index = phase_word >> 20`

Sine table relation:

`sin_lut[k] = quantize_q30(sin(2 pi k / 4096))`

Cosine relation:

`cos_lut[k] = sin_lut[(k + 1024) mod 4096]`

The same generated lookup-table values must be used by:

- Python quantized shadow execution;

- committed RTL lookup-table package;

- SystemVerilog correlation harness.

No simulator-native real-number sine or cosine function is normative for exact RTL equivalence.

## Balanced Ternary Hardware Encoding

M15 defines a two-bit hardware encoding.

Canonical mapping:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

The reserved encoding must never appear as a valid FRP cell state.

The RTL assertion layer must fail on:

`state_code == 2'b10`

## Packed State Vector

Each cell occupies two bits.

Cell ordering:

`cell 0 occupies bits [1:0]`

`cell 1 occupies bits [3:2]`

`cell i occupies bits [2i+1:2i]`

Packed relation:

`states_packed = sum(state_code_i << (2 × i))`

For N cells:

`packed state width = 2N bits`

The machine-readable vector format uses hexadecimal packed-state representation.

A human-readable ternary string may be emitted as an auxiliary field.

The normative comparison value is:

`states_packed`

## Scheduler Mode Encoding

M15 defines:

`free → 2'b00`

`7/1 → 2'b01`

`1/7 → 2'b10`

Reserved:

`2'b11`

## Scheduler State Encoding

M15 defines:

`free → 3'b000`

`balance → 3'b001`

`commit → 3'b010`

`excite → 3'b011`

`neutralize → 3'b100`

Reserved:

`3'b101`

`3'b110`

`3'b111`

The scheduler-state code must be recorded in every cycle-exact vector row.

## Request-Lane Interface

The old single-request testbench model is not sufficient for the validated M14 transition-pressure behavior.

M15 defines a parameterized request-lane interface.

For each processor tick:

`request_valid[lane]`

`request_cell_id[lane]`

`request_target_state[lane]`

Request lanes are processed in ascending lane order.

Reference lane order:

`lane 0`

↓

`lane 1`

↓

`lane 2`

↓

`...`

The request interface preserves deterministic transition ordering.

## Request-Lane Widths

For N cells:

`CELL_ID_WIDTH = ceil(log2(N))`

For each request lane:

`request_valid = 1 bit`

`request_cell_id = CELL_ID_WIDTH bits`

`request_target_state = 2 bits`

The target-state encoding uses the balanced ternary hardware map.

## Auto-Target Control

M15 exposes:

`auto_targets_enable`

The input selects whether the phase-derived reference state-target path is active.

This preserves the distinction between:

- default reference execution;

- externally driven kernel transition testing;

- localized hotspot stress execution.

## Verification Preload Sideband

The M14 reference prototype uses deterministic seeded initial conditions.

Hardware power-up state is not assumed to reproduce Python pseudo-random initialization.

M15 therefore separates:

`reset state`

from:

`reference preload state`

The verification preload sideband may load:

- initial balanced ternary states;

- initial phase words;

- initial frequencies;

- initial frequency targets;

- initial heat states;

- initial gamma noise states;

- initial gamma noise targets;

- counters required by the selected trace suite.

The preload sideband is a verification interface.

It is not automatically defined as a production execution interface.

## Reset Profile

The M15 reset profile clears:

- pending neutral routes;

- transition counters;

- scheduler counters;

- tick counter;

- switch activity;

- switch load;

- boundary-detection state;

- comparison-error state.

The reset profile must not create:

`actual_direct_events`

The reset profile must not generate the reserved balanced ternary state code.

## Reference Preload Profile

Full M14 correlation vectors use:

`reference_preload`

The preload manifest records the deterministic initial state derived from the selected:

- seed;

- cell count;

- scheduler mode;

- topology parameters;

- thermal parameters.

The reference preload occurs before the first compared processor tick.

The first compared tick remains:

`tick 0`

## Deterministic Gamma-Noise Stimulus

The M14 floating reference uses seeded pseudo-random gamma-noise target updates.

M15 does not require the RTL reference core to reproduce the Python pseudo-random generator.

The deterministic gamma-noise target sequence is externalized into the verification stimulus stream.

M15 defines:

`gamma_noise_update_valid`

and:

`gamma_noise_target_q[cell]`

At the configured update ticks, the comparison vector package provides the exact quantized target values.

Between update ticks, the target values remain retained.

This preserves deterministic seeded behavior without requiring Python pseudo-random generator implementation inside the RTL core.

## M15 Exact Tick Execution Order

The M15 quantized shadow and RTL reference core must execute the same ordered tick sequence.

The normative order is:

1. resolve scheduler state for tick;

2. clear current-tick switch-change counters;

3. clear current-tick per-cell switch activity;

4. process ready pending neutral routes;

5. process external request lanes in ascending lane order;

6. process phase-derived reference targets when `auto_targets_enable = 1`;

7. calculate current tick switch load;

8. update frequency targets;

9. update lagged frequency states;

10. calculate local generated power;

11. calculate local thermal dissipation;

12. calculate hierarchical thermal diffusion;

13. update local heat states;

14. calculate local thermal overload;

15. update deterministic gamma-noise correlation states;

16. update local gamma-effective values;

17. update thermal node factors;

18. calculate hierarchical phase-coupling field;

19. update phase velocities;

20. update wrapped phase words;

21. calculate multiscale phase-coherence values;

22. calculate global C(t);

23. calculate global P(t);

24. calculate C_minus_P;

25. detect first positive-to-nonpositive stability crossing;

26. capture post-tick trace outputs.

The same order is mandatory for exact cycle equivalence.

## Quantized Topology Weight Profile

M15 maps hierarchical shell pair weights into `S32Q30`.

For phase coupling:

`W_level_q[d]`

For thermal diffusion:

`T_level_q[d]`

The hierarchical accelerated path uses one pair-weight value per hierarchy distance.

The full dense matrix is not required as the normative RTL storage format.

## Fixed-Point Row-Normalization Closure

Direct fixed-point quantization may create a small row-normalization residual.

M15 defines deterministic residual closure.

For phase coupling:

`residual_W = 2^30 - sum_d(shell_population(d) × W_level_q[d])`

The residual is applied to:

`distance 1 pair weight`

For thermal diffusion:

`residual_T = 2^30 - sum_d(shell_population(d) × T_level_q[d])`

The residual is applied to:

`distance 1 thermal pair weight`

The resulting fixed-point aggregate relations are:

`sum_d(shell_population(d) × W_level_q[d]) = 2^30`

and:

`sum_d(shell_population(d) × T_level_q[d]) = 2^30`

The workflow must validate both relations exactly.

## Quantized Reference Shadow Model

The M15 quantized hardware shadow model is not a post-processing formatter.

It is a stateful execution path.

Mapped state variables are quantized at defined cycle boundaries.

The quantized state becomes the input state for the next quantized cycle.

The quantized shadow model therefore reproduces the same finite-word feedback behavior expected from the RTL implementation.

Golden RTL vectors are generated from:

`quantized_reference_shadow_model`

They are not generated by simply rounding the final output of the floating semantic reference.

## Semantic Reference Preservation

The M14 floating reference remains the semantic control path.

The quantized shadow model must not replace:

`frp_prototype_v1_6_0.py`

The M15 comparison stack is:

`M14 floating reference`

↕

`M15 quantized shadow reference`

↕

`M15 RTL reference core`

## Floating-to-Quantized Correlation

The floating-to-quantized correlation report records:

- state-sequence match;

- scheduler-sequence match;

- neutral-route-sequence match;

- direct-event invariant match;

- maximum phase quantization error;

- maximum frequency error;

- maximum heat error;

- maximum gamma error;

- maximum phase-coherence error;

- maximum C(t) error;

- maximum P(t) error;

- maximum C_minus_P error;

- C_minus_P sign match;

- stability-boundary ordering match.

Direct interface quantization error must remain bounded by the target representation.

Trajectory correlation envelopes are recorded by the executable reference model and validated through the M15 workflow.

## Cycle-Exact Reference Trace

The cycle-exact reference trace records input stimuli and post-tick expected outputs.

The normative cycle relation is:

`inputs presented for tick t`

↓

`processor executes tick t`

↓

`post-tick state captured`

↓

`RTL outputs compared`

Every trace row represents one completed processor tick.

## Primary Cycle Input Fields

Each cycle input record contains:

`tick`

`reset_n`

`scheduler_mode`

`auto_targets_enable`

`request_valid_mask`

`request_cell_id[lane]`

`request_target_state[lane]`

`gamma_noise_update_valid`

`gamma_noise_target_q[cell]`

## Primary Cycle Output Fields

Each cycle output record contains:

`states_packed`

`scheduler_state`

`pending_route_count`

`switch_load_q`

`heat_global_q`

`global_phase_coherence_q`

`C_q`

`P_q`

`C_minus_P_q`

`requested_direct_events`

`prevented_direct_events`

`neutral_routed_events`

`neutralized_conflicts`

`actual_direct_events`

## Per-Cell Cycle Trace Fields

The companion per-cell trace records:

`tick`

`cell_id`

`state_code`

`phase_word`

`frequency_target_q`

`frequency_current_q`

`frequency_lag_q`

`generated_power_q`

`heat_q`

`thermal_overload_q`

`gamma_noise_state_q`

`gamma_effective_word`

`thermal_node_factor_q`

`coupling_field_q`

## Pending Neutral Route Trace

The pending-route companion trace records:

`tick`

`route_index`

`cell_id`

`target_state_code`

`ready_tick`

`route_status`

Route status values include:

`pending`

`applied`

The route trace is used to validate exact tick separation.

## RTL Comparison Vector Package

M15 defines three primary vector classes.

### Kernel Transition Vectors

Kernel vectors validate:

`-1`

`0`

`1`

`-1 → 0 → 1`

`1 → 0 → -1`

`pending neutral route`

`actual_direct_events = 0`

Primary files:

`rtl/m15/frp_m15_kernel_vectors.vec`

`rtl/m15/frp_m15_pending_routes.trace`

### Scheduler Vectors

Scheduler vectors validate:

`free`

`7/1`

`1/7`

Primary files:

`rtl/m15/frp_m15_scheduler_free_vectors.vec`

`rtl/m15/frp_m15_scheduler_7_1_vectors.vec`

`rtl/m15/frp_m15_scheduler_1_7_vectors.vec`

### Full Correlation Vectors

Full correlation vectors validate:

- hierarchical phase coupling;

- local thermal fields;

- thermal diffusion;

- gamma drift;

- multiscale phase coherence;

- global stability telemetry;

- dense-to-hierarchical semantic continuity;

- fixed-point shadow execution.

Primary files:

`rtl/m15/frp_m15_full_correlation_vectors.vec`

`rtl/m15/frp_m15_cell_trace.vec`

## Vector Package Metadata Header

Every vector file begins with a machine-readable metadata header.

Required header markers:

`format_version`

`frp_version`

`milestone`

`cells`

`hierarchy_depth`

`request_lanes`

`transition_fraction`

`scheduler_mode`

`fractal_alpha`

`thermal_beta`

`scalar_format`

`unit_format`

`phase_format`

`seed`

`trace_steps`

`column_definition`

## Primary Vector Row Format

The normative primary row contains:

`TICK`

`RESET_N`

`SCHED_MODE`

`SCHED_STATE`

`AUTO_TARGETS_ENABLE`

`REQ_VALID_MASK`

`REQ_CELL_IDS`

`REQ_TARGET_STATES`

`GAMMA_UPDATE_VALID`

`STATES_PACKED`

`PENDING_ROUTE_COUNT`

`SWITCH_LOAD_Q`

`HEAT_GLOBAL_Q`

`COHERENCE_GLOBAL_Q`

`C_Q`

`P_Q`

`C_MINUS_P_Q`

`REQUESTED_DIRECT_EVENTS`

`PREVENTED_DIRECT_EVENTS`

`NEUTRAL_ROUTED_EVENTS`

`NEUTRALIZED_CONFLICTS`

`ACTUAL_DIRECT_EVENTS`

The normative numeric fields are integer or hexadecimal fields.

Floating-point decimal comparison is not used for RTL equivalence.

## Vector Cell Ordering

Cell ordering is always ascending:

`0`

`1`

`2`

`...`

`N - 1`

Request lane ordering is always ascending:

`0`

`1`

`2`

`...`

`REQUEST_LANES - 1`

Array order must not depend on dictionary iteration order.

## Deterministic Vector Package Generation

The complete vector package must be reproducible from:

- FRP version;

- configuration values;

- deterministic seed;

- trace type;

- cell count;

- scheduler mode.

Repeated generation with identical configuration must produce byte-identical vector files.

The workflow compares repeated packages directly.

## Vector Package Integrity

The qualification closure manifest records a SHA-256 digest for every generated vector and trace file.

The digest set includes:

- kernel vectors;

- pending-route trace;

- free scheduler vectors;

- 7/1 scheduler vectors;

- 1/7 scheduler vectors;

- full correlation vectors;

- per-cell trace;

- preload manifest;

- lookup-table package.

## SystemVerilog Testbench Interface Map

M15 defines a parameterized SystemVerilog comparison interface.

Primary parameters:

`NUM_CELLS`

`HIERARCHY_DEPTH`

`REQUEST_LANES`

`CELL_ID_WIDTH`

`STATE_VECTOR_WIDTH`

`SCALAR_WIDTH`

`PHASE_WIDTH`

Primary execution inputs:

`clk`

`reset_n`

`scheduler_mode`

`auto_targets_enable`

`request_valid`

`request_cell_id`

`request_target_state`

Primary verification stimulus inputs:

`preload_valid`

`gamma_noise_update_valid`

`gamma_noise_target_q`

Primary comparison outputs:

`states_packed`

`scheduler_state`

`pending_route_count`

`switch_load_q`

`heat_global_q`

`global_phase_coherence_q`

`C_q`

`P_q`

`C_minus_P_q`

transition counters.

## SystemVerilog Vector Replay Semantics

The testbench executes the following sequence for every vector row:

1. parse next vector row;

2. drive tick input signals before the active clock edge;

3. apply verification-sideband stimulus;

4. execute one processor clock edge;

5. allow deterministic registered outputs to settle;

6. sample post-tick outputs;

7. compare sampled outputs against expected integer values;

8. execute invariant assertions;

9. stop immediately on mismatch.

The first mismatch report records:

- vector file;

- vector row;

- tick;

- field name;

- expected value;

- actual value.

## Synthesizable RTL Reference Core

M15 defines the synthesizable RTL reference-core target.

Primary planned RTL files:

`rtl/m15/frp_m15_types_pkg.sv`

`rtl/m15/frp_m15_fixed_point_pkg.sv`

`rtl/m15/frp_m15_trig_lut_pkg.sv`

`rtl/m15/frp_m15_scheduler.sv`

`rtl/m15/frp_m15_transition_core.sv`

`rtl/m15/frp_m15_neutral_route_queue.sv`

`rtl/m15/frp_m15_delay_dynamics.sv`

`rtl/m15/frp_m15_thermal_field.sv`

`rtl/m15/frp_m15_gamma_drift.sv`

`rtl/m15/frp_m15_hierarchical_coupling.sv`

`rtl/m15/frp_m15_multiscale_coherence.sv`

`rtl/m15/frp_m15_stability_telemetry.sv`

`rtl/m15/frp_m15_top.sv`

The RTL reference core must preserve the M15 exact tick execution order.

## RTL Transition Core

The RTL transition core must support only:

`-1`

`0`

`1`

Reserved state:

`2'b10`

must never be committed.

The transition core must preserve:

`actual_direct_events = 0`

Opposite-polarity requests must produce:

`current polarity → 0`

and create a pending route.

The target polarity must not be applied in the same tick.

## RTL Neutral Route Queue

The neutral-route queue stores:

`valid`

`cell_id`

`target_state`

`ready_tick`

The queue must preserve deterministic processing order.

The queue must expose sufficient trace state for exact correlation.

The queue must reject or report overflow.

Queue overflow is a qualification failure.

## RTL Scheduler

The RTL scheduler must implement:

`free`

`7/1`

`1/7`

The scheduler state sequence must match the Python and quantized shadow sequences exactly.

For sixteen ticks:

`free → free = 16`

`7/1 → balance = 14, commit = 2`

`1/7 → excite = 2, neutralize = 14`

## RTL Hierarchical Coupling Datapath

The M15 RTL reference core uses the M14 exact dyadic shell structure.

The interaction path is:

`cell phase words`

↓

`trigonometric lookup`

↓

`thermally weighted phasors`

↓

`dyadic shell aggregation`

↓

`per-level pair weighting`

↓

`hierarchical coupling accumulation`

↓

`phase velocity`

↓

`wrapped phase update`

The RTL path must preserve the M14 hierarchical shell membership relation.

## RTL Thermal Field Datapath

The RTL thermal field remains per-cell.

The datapath must retain:

`generated_power_i`

`thermal_dissipation_i`

`thermal_diffusion_i`

`heat_i`

`thermal_overload_i`

The thermal-diffusion topology remains separate from the phase-coupling topology.

## RTL Multiscale Phase-Coherence Datapath

The RTL reference core must produce hierarchy-level phase-coherence telemetry for:

- pair domains;

- local clusters;

- superclusters;

- global domain.

The exact integer representation must match the M15 quantized shadow profile.

## RTL Assertion Correlation Harness

M15 defines assertions for:

- valid balanced ternary encoding;

- reserved-state exclusion;

- direct polarity transition exclusion;

- active neutral route insertion;

- target application after ready tick;

- `actual_direct_events = 0`;

- transition-limit enforcement;

- scheduler sequence;

- scheduler count consistency;

- topology fixed-point normalization;

- thermal-topology fixed-point normalization;

- deterministic trace tick count;

- exact cycle-output match.

## Direct Transition Assertion

For each cell:

`previous_state = -1`

and:

`current_state = +1`

in adjacent processor snapshots is a failure.

For each cell:

`previous_state = +1`

and:

`current_state = -1`

in adjacent processor snapshots is a failure.

Valid opposite-polarity migration requires a captured intermediate:

`0`

## Scheduler Assertions

The assertion harness validates:

`free`

`7/1`

`1/7`

The assertion harness validates:

`sum(scheduler_counts) = ticks_recorded`

The assertion harness validates the configured sequence periodicity.

## Exact RTL Comparison Rule

The cycle-exact RTL comparison does not use tolerance.

For mapped integer fields:

`actual == expected`

Required exact domains include:

- packed ternary states;

- scheduler state;

- pending route count;

- fixed-point scalar outputs;

- phase words;

- counters;

- per-cell thermal values;

- per-cell gamma values;

- coupling-field values.

## Reference RTL Equivalence Report

The M15 equivalence report contains two sections.

### Floating Reference ↔ Quantized Shadow

Status markers:

`state_sequence_match`

`scheduler_sequence_match`

`neutral_route_sequence_match`

`C_minus_P_sign_match`

`boundary_order_match`

`max_phase_error`

`max_frequency_error`

`max_heat_error`

`max_gamma_error`

`max_coherence_error`

`max_C_minus_P_error`

### Quantized Shadow ↔ RTL

Status markers:

`rtl_state_match`

`rtl_scheduler_match`

`rtl_pending_route_match`

`rtl_counter_match`

`rtl_phase_match`

`rtl_thermal_match`

`rtl_gamma_match`

`rtl_coherence_match`

`rtl_stability_telemetry_match`

`rtl_cycle_match`

Primary target:

`rtl_cycle_match = 1.000`

## M15 Kernel Vector Qualification

Kernel vectors must validate both directions:

`-1 → 0 → 1`

and:

`1 → 0 → -1`

The qualification set must include:

- one-cell isolated request;

- multiple request lanes;

- simultaneous nonconflicting transitions;

- simultaneous opposite-polarity requests;

- transition limit saturation;

- pending route carryover;

- delayed target application;

- queue exhaustion.

The kernel suite must preserve:

`actual_direct_events = 0`

## M15 Scheduler Vector Qualification

Separate vector packages must validate:

`free`

`7/1`

`1/7`

The scheduler vector suites must preserve:

- ternary state domain;

- tick-separated neutral routing;

- request-lane ordering;

- transition fraction;

- scheduler counts;

- exact quantized trace determinism.

## M15 Full Correlation Qualification

The full correlation trace must include:

- default reference execution;

- localized request pressure;

- distributed request pressure;

- local thermal response;

- cross-cluster thermal propagation;

- multiscale phase-coherence response;

- dense-to-hierarchical semantic comparison;

- recovery sequence.

## M15 Scaling Qualification

M15 qualification targets:

`8 cells`

`16 cells`

`32 cells`

For every scaling profile, the workflow must validate:

- hierarchy depth;

- shell populations;

- request-lane count;

- packed-state width;

- topology normalization;

- thermal-topology normalization;

- vector determinism;

- kernel invariants;

- scheduler modes;

- quantized shadow execution;

- RTL comparison.

## M15 Candidate Invariants

M15 preserves:

`match = 1.000`

`actual_direct_events = 0`

`C_minus_P_min > 0`

`switch_load_peak <= transition_fraction`

`ticks_recorded = steps`

`scheduler counts match selected cycle mode`

`neutral-routed transition path is preserved`

`neutralized_conflicts tracked`

M15 additionally defines:

`reserved_state_events = 0`

`fixed_point_topology_sum_exact = True`

`fixed_point_thermal_sum_exact = True`

`quantized_state_sequence_match = 1.000`

`quantized_scheduler_sequence_match = 1.000`

`quantized_neutral_route_sequence_match = 1.000`

`C_minus_P_sign_match = 1.000`

`vector_repeat_match = 1.000`

`rtl_state_match = 1.000`

`rtl_scheduler_match = 1.000`

`rtl_pending_route_match = 1.000`

`rtl_counter_match = 1.000`

`rtl_cycle_match = 1.000`

## Planned M15 File Set

Architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Executable reference file:

`frp_prototype_v1_7_0.py`

Fixed-point documentation:

`docs/m15_fixed_point_interface_profile.md`

Balanced ternary encoding documentation:

`docs/m15_balanced_ternary_hardware_encoding.md`

Vector format documentation:

`rtl/m15/frp_m15_vector_format.md`

Kernel vectors:

`rtl/m15/frp_m15_kernel_vectors.vec`

Pending-route trace:

`rtl/m15/frp_m15_pending_routes.trace`

Free scheduler vectors:

`rtl/m15/frp_m15_scheduler_free_vectors.vec`

7/1 scheduler vectors:

`rtl/m15/frp_m15_scheduler_7_1_vectors.vec`

1/7 scheduler vectors:

`rtl/m15/frp_m15_scheduler_1_7_vectors.vec`

Full correlation vectors:

`rtl/m15/frp_m15_full_correlation_vectors.vec`

Per-cell trace:

`rtl/m15/frp_m15_cell_trace.vec`

RTL type package:

`rtl/m15/frp_m15_types_pkg.sv`

RTL fixed-point package:

`rtl/m15/frp_m15_fixed_point_pkg.sv`

RTL trigonometric lookup-table package:

`rtl/m15/frp_m15_trig_lut_pkg.sv`

RTL scheduler:

`rtl/m15/frp_m15_scheduler.sv`

RTL transition core:

`rtl/m15/frp_m15_transition_core.sv`

RTL neutral-route queue:

`rtl/m15/frp_m15_neutral_route_queue.sv`

RTL delay dynamics:

`rtl/m15/frp_m15_delay_dynamics.sv`

RTL thermal field:

`rtl/m15/frp_m15_thermal_field.sv`

RTL gamma drift:

`rtl/m15/frp_m15_gamma_drift.sv`

RTL hierarchical coupling:

`rtl/m15/frp_m15_hierarchical_coupling.sv`

RTL multiscale coherence:

`rtl/m15/frp_m15_multiscale_coherence.sv`

RTL stability telemetry:

`rtl/m15/frp_m15_stability_telemetry.sv`

RTL top:

`rtl/m15/frp_m15_top.sv`

SystemVerilog vector reader:

`rtl/m15/tb/frp_m15_vector_reader_tb.sv`

SystemVerilog assertions:

`rtl/m15/tb/frp_m15_assertions.sv`

M15 workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Release-facing files:

`TEST_REPORT_v1_7_0.md`

`RELEASE_NOTES_v1_7_0.md`

`FRP_VALIDATION_INDEX_v1_7_0.md`

## M15 Validation Targets

M15 validation targets:

- balanced ternary state domain remains exactly `-1`, `0`, and `1`;

- reserved state code `2'b10` never appears;

- active neutral state remains `0`;

- opposite-polarity requests remain intercepted;

- target polarity remains separated by at least one processor tick;

- `actual_direct_events = 0`;

- pending neutral routes remain traceable;

- request lanes preserve deterministic lane order;

- `free` scheduler remains preserved;

- `7/1` scheduler remains preserved;

- `1/7` scheduler remains preserved;

- transition-fraction control remains preserved;

- M14 hierarchical shell topology remains preserved;

- fixed-point topology aggregate sum is exact;

- fixed-point thermal topology aggregate sum is exact;

- M14 local thermal fields remain distributed per cell;

- M14 multiscale phase-coherence domains remain present;

- floating reference and quantized shadow preserve categorical invariants;

- C_minus_P sign remains correlated;

- quantized shadow execution is deterministic;

- repeated vector packages are byte-identical;

- vector package digests are recorded;

- SystemVerilog vector replay preserves tick ordering;

- synthesizable RTL reference core uses the same fixed-point contract;

- quantized shadow and RTL outputs match exactly for compared integer fields;

- kernel vector suite passes;

- scheduler vector suites pass;

- full correlation vector suite passes;

- 8-cell scaling qualification passes;

- 16-cell scaling qualification passes;

- 32-cell scaling qualification passes;

- qualification closure manifest reports complete closure.

## M15 Pre-Issuance Executable Validation Gate

Before `frp_prototype_v1_7_0.py` is issued, the following checks are required:

- Python compilation;

- inherited M14 kernel preservation;

- balanced ternary domain validation;

- active neutral-state validation;

- both opposite-polarity route directions;

- tick-separated neutral-route validation;

- `actual_direct_events = 0`;

- free scheduler validation;

- 7/1 scheduler validation;

- 1/7 scheduler validation;

- request-lane ordering validation;

- transition-fraction validation;

- fixed-point quantizer boundary tests;

- positive half-case rounding test;

- negative half-case rounding test;

- signed saturation tests;

- phase-wrap tests;

- balanced ternary encoding tests;

- reserved-state rejection;

- scheduler encoding tests;

- Q30 topology residual-closure validation;

- Q30 thermal residual-closure validation;

- trigonometric lookup determinism;

- quantized shadow deterministic repeat;

- floating-to-quantized correlation report;

- C_minus_P sign correlation;

- kernel vector generation;

- pending-route trace generation;

- free scheduler vector generation;

- 7/1 scheduler vector generation;

- 1/7 scheduler vector generation;

- full correlation vector generation;

- per-cell trace generation;

- byte-identical repeated vector generation;

- vector SHA-256 manifest generation;

- all M15 export commands;

- all M15 schema checks;

- 8-cell profile validation;

- 16-cell profile validation;

- 32-cell profile validation.

The executable reference file proceeds to repository commit only after the complete validation gate passes.

## M15 RTL Qualification Gate

The M15 RTL reference-core package proceeds to release qualification only after:

- SystemVerilog compilation;

- package dependency validation;

- fixed-point helper validation;

- lookup-table validation;

- transition-core validation;

- neutral-route queue validation;

- scheduler validation;

- local thermal-field validation;

- hierarchical coupling validation;

- multiscale phase-coherence validation;

- global stability telemetry validation;

- kernel vector replay;

- free scheduler vector replay;

- 7/1 scheduler vector replay;

- 1/7 scheduler vector replay;

- full correlation vector replay;

- exact cycle comparison;

- assertion pass;

- qualification closure manifest completion.

## M15 Technical Chain

`published M14 semantic reference`

↓

`hardware-facing numeric types`

↓

`balanced ternary binary encoding`

↓

`deterministic fixed-point arithmetic`

↓

`quantized hardware shadow execution`

↓

`cycle-exact golden trace`

↓

`RTL comparison vectors`

↓

`verification preload and deterministic stimulus`

↓

`synthesizable RTL reference core`

↓

`SystemVerilog vector replay`

↓

`assertion-based cycle correlation`

↓

`floating semantic correlation`

↓

`exact quantized shadow ↔ RTL equivalence`

↓

`qualification closure`

## Architecture Progression

FRP v1.7.0 extends the validated architecture progression:

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

↓

`production integration manifest`

↓

`external implementation handoff package`

↓

`external feedback intake manifest`

↓

`production iteration plan`

↓

`thermal saturation model`

↓

`delay dynamics model`

↓

`nonlinear coherence compression model`

↓

`thermal gamma drift model`

↓

`thermal stability boundary sweep`

↓

`recovery dynamics map`

↓

`production scaling stability envelope`

↓

`hierarchical ultrametric topology model`

↓

`shell-normalized fractal coupling`

↓

`multiscale phase-coherence map`

↓

`cluster-local thermal field`

↓

`cross-cluster propagation map`

↓

`localized hotspot-containment harness`

↓

`dense-hierarchical equivalence map`

↓

`physical-domain correlation package`

↓

`fixed-point interface profile`

↓

`balanced ternary hardware encoding map`

↓

`quantized reference shadow model`

↓

`cycle-exact reference trace`

↓

`RTL comparison vector package`

↓

`SystemVerilog testbench interface map`

↓

`synthesizable RTL reference core`

↓

`RTL assertion correlation harness`

↓

`reference RTL equivalence report`

↓

`qualification closure manifest`

## M15 Technical Position

FRP v1.7.0 defines the bridge between the published M14 semantic reference architecture and an exact hardware-facing RTL comparison domain.

The M15 architecture preserves the balanced ternary `-1`, `0`, and `1` kernel, the active neutral state, tick-separated neutral routing, the pending neutral route, `free`, `7/1`, and `1/7` scheduler modes, M14 hierarchical topology, distributed thermal fields, multiscale phase-coherence domains, and the global C(t) - P(t) stability telemetry.

M15 adds an explicit quantized hardware shadow layer so that finite-word arithmetic becomes a stateful reference execution path rather than a post-processing conversion.

The cycle-exact golden vectors are generated from the quantized hardware shadow reference.

The synthesizable RTL reference core is compared against the quantized hardware shadow reference using exact integer equality.

## Next Architecture Layer

The next planned architecture layer is:

`M16 — RTL Core Realization and Execution Semantics Package`

M16 is the planned point for extending the qualified M15 RTL reference core toward explicit execution semantics and the later definition of a processor instruction architecture.

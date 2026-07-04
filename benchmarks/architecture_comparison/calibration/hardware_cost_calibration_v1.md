# FRP Comparative Architecture Hardware Cost Calibration Contract v1

## Calibration Role

This document defines the calibration contract for the second cost-analysis layer of the FRP Comparative Architecture Benchmark Suite.

The existing canonical profile remains:

`unit_event_cost_v1`

The existing canonical result remains:

`results/reference_comparison_seed_76.json`

Neither file is replaced, rewritten, reinterpreted, or removed.

The unit-event profile continues to answer:

`How many declared architecture events are produced when every declared event class has equal unit cost?`

The hardware-calibrated sensitivity layer answers a different question:

`How do comparative results change when declared event classes receive explicit hardware-informed relative weights?`

The second layer is additive.

## Non-Replacement Rule

The following canonical chain remains preserved:

`one deterministic semantic workload`

↓

`four architecture execution paths`

↓

`raw architecture event traces`

↓

`unit_event_cost_v1`

↓

`common_rc_thermal_proxy_v1`

↓

`reference_comparison_seed_76.json`

The hardware-calibrated sensitivity layer is added beside this chain.

It does not replace it.

## Current Canonical Unit-Event Result

The current canonical comparison package uses:

`unit_event_cost_v1`

where every declared event class has:

`normalized cost = 1.0`

The canonical result therefore measures:

`declared architecture event volume`

rather than:

`physical silicon energy`

The current result must remain available as the architecture-neutral event-count baseline.

## Calibration Principle

A hardware-calibrated coefficient must not be introduced solely because it improves the ranking of any architecture.

Every non-unit coefficient must have an explicit calibration basis.

Allowed basis classes are:

`literature_anchor`

`derived_from_literature_anchor`

`implementation_assumption`

`eda_measurement`

`silicon_measurement`

Each coefficient must declare its basis class.

## No Predetermined Winner Rule

The calibration layer must not contain a rule requiring:

`FRP total cost < binary total cost`

`FRP temperature proxy < binary temperature proxy`

`FRP latency < binary latency`

`FRP throughput > binary throughput`

`Direct Ternary total cost < binary total cost`

The sensitivity result remains measured data.

## Calibration Layers

The calibration program is divided into two stages.

### Stage A — Literature-Anchored Sensitivity Profile

The first hardware-informed profile uses published digital hardware energy relationships as relative anchors.

Planned profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

This profile is a sensitivity profile.

It is not described as:

`measured FRP silicon energy`

It is not described as:

`absolute processor power`

It is not described as:

`physical junction temperature`

Its purpose is:

`to test whether the architecture ranking changes under a declared non-unit hardware cost hierarchy`

### Stage B — EDA-Calibrated Implementation Profile

A later calibration stage may derive event weights from explicit hardware primitive implementations.

Planned profile class:

`eda_calibrated_implementation_profile`

This stage requires:

`declared RTL primitive`

↓

`declared technology library`

↓

`declared synthesis flow`

↓

`declared switching activity`

↓

`declared timing conditions`

↓

`declared power-estimation flow`

↓

`measured relative primitive cost`

The EDA-calibrated profile must remain separate from the literature-anchored profile.

## Reference Basis

The initial literature calibration basis includes the following reference class:

`digital CMOS operation-energy hierarchy`

Primary reference:

`Mark Horowitz`

`1.1 Computing's Energy Problem (and What We Can Do About It)`

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

The calibration also recognizes that:

- arithmetic operations do not have equal hardware cost;

- data access does not have the same cost as arithmetic;

- memory cost depends on memory type and implementation;

- clock-distribution cost depends on clock load and physical implementation;

- operation cost depends on technology node, voltage, frequency, bit width, circuit topology, and physical design.

Therefore no literature-derived number is treated as a universal hardware constant.

## Normalization Rule

The first literature-anchored profile uses a declared relative reference operation.

Planned normalization reference:

`32-bit integer addition`

The normalized reference weight is:

`1.0`

Every other coefficient is expressed relative to the same reference.

The profile must record:

`normalization_reference`

`reference_energy_value`

`reference_energy_unit`

`reference_technology_node`

`reference_voltage`

`reference_source`

A coefficient without a common normalization basis is invalid.

## Event Calibration Classes

The current benchmark event taxonomy is divided into four calibration classes.

## Class A — Direct Arithmetic Primitive Events

Events:

`fixed_point_adds_32`

`fixed_point_multiplies_32x32`

`fixed_point_accumulates_64`

`fixed_point_compares_32`

These events may receive literature-anchored relative weights when the mapped primitive and bit width are explicit.

Required coefficient metadata:

`event_field`

`cost_class`

`primitive_width`

`basis_type`

`reference_source`

`source_value`

`source_unit`

`normalized_weight`

`derivation_rule`

`uncertainty_class`

## Class B — Storage-Implementation-Dependent Events

Events:

`queue_reads`

`queue_writes`

`lut_reads_32`

These events cannot be assigned one universal physical weight without an implementation assumption.

A lookup-table read may be implemented as:

`combinational logic`

`distributed ROM`

`register array`

`SRAM`

`FPGA LUT fabric`

These implementations do not have identical energy cost.

A queue may be implemented as:

`flip-flop bank`

`register file`

`SRAM`

Therefore every Class B coefficient must declare:

`implementation_assumption`

Required examples:

`lut_implementation`

`lut_capacity`

`lut_word_width`

`queue_implementation`

`queue_depth`

`queue_entry_width`

A storage coefficient without an implementation assumption is invalid.

## Class C — Physical-Topology-Dependent Events

Events:

`encoded_bit_toggles`

`clocked_state_bits`

`register_write_bits`

These events depend strongly on physical implementation.

Relevant variables include:

`switched capacitance`

`supply voltage`

`clock load`

`fanout`

`wire length`

`buffer topology`

`register implementation`

`placement`

`routing`

Therefore the literature-anchored profile may use only explicitly declared proxy weights for these event classes.

Every proxy coefficient must be labeled:

`implementation_assumption`

or:

`derived_from_literature_anchor`

It must not be presented as directly measured FRP silicon energy.

## Class D — Aggregate Control Proxy Events

Events:

`comparison_events`

`control_events`

These counters represent declared architecture-level control activity.

They are not one-to-one physical gates.

Their coefficients must therefore remain explicit proxy coefficients.

The calibration file must record:

`control_event_mapping_assumption`

and:

`comparison_event_mapping_assumption`

A hidden control coefficient is invalid.

## Coefficient Provenance Contract

Every cost coefficient in the hardware sensitivity profile must contain provenance.

Required fields:

`event_field`

`cost_class`

`normalized_weight`

`basis_type`

`reference`

`technology_node_nm`

`voltage_v`

`implementation_assumption`

`derivation_rule`

`uncertainty_class`

Allowed uncertainty classes:

`low`

`medium`

`high`

A coefficient without provenance must fail profile validation.

## Source-Anchored and Derived Coefficients

A source-anchored coefficient is one where the declared event maps directly to the published primitive.

Example structure:

`32-bit fixed-point multiply`

↓

`32-bit integer multiply reference`

↓

`published reference value`

↓

`normalized relative weight`

A derived coefficient is one where additional transformation is required.

Example structure:

`64-bit fixed-point accumulation`

↓

`declared accumulation implementation assumption`

↓

`declared derivation from arithmetic reference`

↓

`normalized relative weight`

Derived coefficients must expose the derivation rule.

## Sensitivity Requirement

The first hardware-informed analysis must not rely on only one coefficient set.

At minimum, the calibration package must support:

`nominal`

`lower_bound`

`upper_bound`

for coefficients with:

`medium`

or:

`high`

uncertainty.

The benchmark may therefore generate:

`nominal sensitivity result`

`lower-bound sensitivity result`

`upper-bound sensitivity result`

This permits evaluation of whether an architecture ranking is:

`stable across the declared coefficient range`

or:

`sensitive to calibration assumptions`

## Ranking Stability Rule

The sensitivity analysis may report:

`ranking_stable = true`

only when the architecture ordering remains unchanged across the declared coefficient range.

The analysis may report:

`ranking_sensitive = true`

when the architecture ordering changes under allowed coefficient variation.

Neither result is a failure.

Both are benchmark results.

## Clock Activity Calibration

Clock activity must remain explicitly represented.

The benchmark currently distinguishes:

`processor_cycles`

`active_clocked_cycles`

`clocked_state_bits`

Clocked state activity must not be removed from the hardware sensitivity profile.

The Binary Synchronous Reference records globally active state-clock behavior.

The Binary Clock-Gated Reference records state-clock activity only when its declared state-register clock is active.

The Direct Ternary Reference records its declared two-bit state-register clock activity.

The FRP v1.7.0 Quantized Hardware Shadow Reference records its declared synchronous state domain.

Any future modification to the clock-cost interpretation must preserve the raw counters.

## FRP Overhead Preservation Rule

The hardware sensitivity profile must preserve explicit FRP computational overhead.

The following event classes must not be removed because they make FRP expensive:

`lut_reads_32`

`fixed_point_multiplies_32x32`

`fixed_point_accumulates_64`

`fixed_point_adds_32`

`fixed_point_compares_32`

`queue_reads`

`queue_writes`

The sensitivity profile changes only event weights.

It does not delete measured event classes.

## Baseline Overhead Preservation Rule

The hardware sensitivity profile must also preserve baseline overhead.

The following baseline activity must remain counted where declared:

`clocked_state_bits`

`register_write_bits`

`encoded_bit_toggles`

`comparison_events`

`control_events`

No baseline cost class may be removed to improve FRP ranking.

## Semantic Equivalence Requirement

Every sensitivity run must continue to require:

`same workload_sha256`

`same semantic command order`

`same semantic command count`

`semantic_completion_ratio = 1.000`

`semantic_output_match = 1.000`

A hardware sensitivity profile must not alter workload semantics.

## FRP Invariant Requirement

Every sensitivity run must continue to require:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

`pending_route_count_final = 0`

`requested_direct_events = prevented_direct_events`

`neutral_insertions = neutral_routed_events`

The cost profile must not modify FRP execution semantics.

## Thermal Proxy Rule

The first hardware sensitivity analysis continues to use the common:

`common_rc_thermal_proxy_v1`

The same thermal recurrence remains applied to all architectures.

The sensitivity analysis changes:

`normalized_cycle_cost`

It does not introduce architecture-specific thermal gain or cooling coefficients.

## Planned Profile Package

Planned file:

`benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`

Planned profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

The profile must contain:

`schema`

`suite_name`

`profile_name`

`profile_role`

`normalization_reference`

`reference_basis`

`coefficients`

`uncertainty_ranges`

`provenance`

`cost_profile_sha256`

## Planned Sensitivity Result Package

Planned canonical sensitivity result:

`benchmarks/architecture_comparison/results/reference_comparison_seed_76_hardware_sensitivity_v1.json`

This file must exist beside:

`reference_comparison_seed_76.json`

The unit-event result remains the primary neutral event-volume baseline.

The hardware sensitivity result remains the secondary weighted analysis.

## Comparison Chain

The extended comparison chain becomes:

`one deterministic semantic workload`

↓

`four architecture execution paths`

↓

`raw architecture event traces`

↓

`branch A: unit_event_cost_v1`

↓

`canonical unit-event result`

and independently:

`raw architecture event traces`

↓

`branch B: literature_anchored_cmos45_sensitivity_v1`

↓

`nominal coefficient evaluation`

↓

`lower-bound coefficient evaluation`

↓

`upper-bound coefficient evaluation`

↓

`ranking stability analysis`

↓

`hardware sensitivity result`

## Validation Policy

The hardware sensitivity workflow must validate:

`profile schema`

`coefficient provenance`

`common normalization reference`

`same workload digest`

`same architecture order`

`same raw architecture results`

`deterministic profile digest`

`deterministic repeated generation`

`finite weighted metrics`

`semantic_output_match = 1.000`

`FRP actual_direct_events = 0`

`FRP reserved_state_events = 0`

`FRP queue_overflow_events = 0`

`FRP pending-route closure`

The workflow must not validate:

`FRP must rank first`

`Direct Ternary must rank first`

`Binary must rank last`

The measured ranking remains data.

## Publication Rule

Published comparison text must distinguish:

`unit-event activity result`

from:

`hardware-informed sensitivity result`

and from:

`EDA-measured implementation result`

These terms are not interchangeable.

The repository must not describe a literature-weighted sensitivity result as direct silicon power measurement.

## Current Calibration Position

The current repository has completed:

`unit-event benchmark contract`

↓

`deterministic semantic workload`

↓

`shared cost model`

↓

`shared thermal proxy model`

↓

`Binary Synchronous Reference`

↓

`Binary Clock-Gated Reference`

↓

`Direct Ternary Reference`

↓

`FRP v1.7.0 Quantized Hardware Shadow Reference`

↓

`end-to-end comparison runner`

↓

`GitHub Actions qualification`

↓

`canonical unit-event comparison result`

The next implementation layer is:

`coefficient provenance map`

↓

`literature-anchored hardware sensitivity profile`

↓

`nominal, lower-bound, and upper-bound sensitivity execution`

↓

`ranking stability analysis`

↓

`deterministic sensitivity qualification`

# FRP Comparative Architecture Coefficient Provenance Map v1

## Map Role

This document defines the coefficient provenance map for the hardware-informed sensitivity layer of the FRP Comparative Architecture Benchmark Suite.

The map is aligned with:

`hardware_cost_calibration_v1.md`

The existing canonical unit-event profile remains:

`unit_event_cost_v1`

The existing canonical unit-event result remains:

`results/reference_comparison_seed_76.json`

The present map defines a separate coefficient branch.

It does not replace the unit-event baseline.

## Calibration Branch

The comparison framework now contains two distinct cost-analysis branches.

Branch A:

`raw architecture event traces`

↓

`unit_event_cost_v1`

↓

`canonical unit-event comparison result`

Branch B:

`raw architecture event traces`

↓

`coefficient provenance map`

↓

`literature_anchored_cmos45_sensitivity_v1`

↓

`lower-bound evaluation`

↓

`nominal evaluation`

↓

`upper-bound evaluation`

↓

`ranking stability analysis`

↓

`hardware-informed sensitivity result`

The same raw architecture events are used by both branches.

## Profile Identifier

Planned profile identifier:

`literature_anchored_cmos45_sensitivity_v1`

Profile role:

`hardware_informed_sensitivity`

Normalization reference:

`32-bit integer addition`

Normalization value:

`1.0`

Reference energy:

`0.1 pJ`

Reference technology node:

`45 nm CMOS`

Reference voltage:

`not fixed by the rough-energy table`

Primary source:

`Mark Horowitz`

`1.1 Computing's Energy Problem (and What We Can Do About It)`

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

`ISSCC 2014`

`pages 10–14`

DOI:

`10.1109/ISSCC.2014.6757323`

## Primary Literature Anchor

The primary calibration source provides rough digital operation-energy values for a 45 nm CMOS process.

The values used by this provenance map are:

`32-bit integer addition = 0.1 pJ`

`32-bit integer multiplication = approximately 3 pJ`

The same source also provides local memory-access energy examples, including:

`64-bit access to an 8 KB cache = approximately 10 pJ`

The hardware sensitivity profile converts these values into relative weights.

The normalization relation is:

`normalized_weight = source_energy_pJ / 0.1 pJ`

Therefore:

`32-bit integer addition → 1.0`

`32-bit integer multiplication → 30.0`

A derived 32-bit half-width proxy from the 64-bit 8 KB cache anchor gives:

`5 pJ / 0.1 pJ = 50.0`

for the nominal lookup-table read proxy.

The memory derivation remains explicitly marked as:

`derived_from_literature_anchor`

because:

`32-bit M15 lookup-table read`

is not identical to:

`64-bit 8 KB cache access`

## Calibration Integrity Rule

A coefficient is valid only when the map exposes:

`event_field`

`cost_class`

`nominal_weight`

`lower_bound`

`upper_bound`

`basis_type`

`reference_key`

`source_value`

`source_unit`

`technology_node_nm`

`voltage_v`

`implementation_assumption`

`derivation_rule`

`uncertainty_class`

No hidden coefficient is permitted.

## Basis Types

Allowed values:

`literature_anchor`

`derived_from_literature_anchor`

`implementation_assumption`

`eda_measurement`

`silicon_measurement`

The first sensitivity profile uses only:

`literature_anchor`

`derived_from_literature_anchor`

`implementation_assumption`

## Uncertainty Classes

Allowed values:

`low`

`medium`

`high`

Interpretation:

`low`

means the event maps directly to the declared literature primitive and normalization basis.

`medium`

means the event is derived from a direct literature anchor through an explicit width or operation transformation.

`high`

means physical implementation details materially affect the coefficient and the current value is an explicit sensitivity assumption.

## Bound Semantics

Every coefficient contains:

`lower_bound`

`nominal_weight`

`upper_bound`

with the required relation:

`0 <= lower_bound <= nominal_weight <= upper_bound`

The three profile scenarios are:

`lower_bound`

`nominal`

`upper_bound`

The scenario vectors change event weights.

They do not change:

`workload`

`architecture execution`

`raw event counts`

`semantic completion`

`FRP transition semantics`

## Event Taxonomy Coverage

The current common cost model contains twelve cost classes.

All twelve are covered by this provenance map:

`encoded_bit_toggle`

`clocked_state_bit`

`register_write_bit`

`comparison_event`

`control_event`

`queue_read`

`queue_write`

`lut_read_32`

`fixed_point_multiply_32x32`

`fixed_point_accumulate_64`

`fixed_point_add_32`

`fixed_point_compare_32`

A sensitivity profile that omits any declared cost class is invalid.

# Coefficient Summary

| Event Field | Cost Class | Lower | Nominal | Upper | Basis | Uncertainty |
|---|---|---:|---:|---:|---|---|
| `encoded_bit_toggles` | `encoded_bit_toggle` | 0.0078125 | 0.03125 | 0.125 | `implementation_assumption` | `high` |
| `clocked_state_bits` | `clocked_state_bit` | 0.015625 | 0.0625 | 0.25 | `implementation_assumption` | `high` |
| `register_write_bits` | `register_write_bit` | 0.03125 | 0.125 | 0.5 | `implementation_assumption` | `high` |
| `comparison_events` | `comparison_event` | 0.125 | 0.5 | 2.0 | `implementation_assumption` | `high` |
| `control_events` | `control_event` | 0.25 | 1.0 | 8.0 | `implementation_assumption` | `high` |
| `queue_reads` | `queue_read` | 1.0 | 5.0 | 30.0 | `implementation_assumption` | `high` |
| `queue_writes` | `queue_write` | 1.5 | 7.5 | 40.0 | `implementation_assumption` | `high` |
| `lut_reads_32` | `lut_read_32` | 20.0 | 50.0 | 100.0 | `derived_from_literature_anchor` | `high` |
| `fixed_point_multiplies_32x32` | `fixed_point_multiply_32x32` | 20.0 | 30.0 | 40.0 | `literature_anchor` | `medium` |
| `fixed_point_accumulates_64` | `fixed_point_accumulate_64` | 1.5 | 2.0 | 4.0 | `derived_from_literature_anchor` | `medium` |
| `fixed_point_adds_32` | `fixed_point_add_32` | 0.5 | 1.0 | 2.0 | `literature_anchor` | `low` |
| `fixed_point_compares_32` | `fixed_point_compare_32` | 0.5 | 1.0 | 2.0 | `implementation_assumption` | `high` |

# Detailed Provenance Records

## 1. Encoded Bit Toggle

Event field:

`encoded_bit_toggles`

Cost class:

`encoded_bit_toggle`

Lower bound:

`0.0078125`

Nominal weight:

`0.03125`

Upper bound:

`0.125`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one local encoded state-bit toggle`

Derivation rule:

`nominal = normalized 32-bit add weight / 32`

Therefore:

`1.0 / 32 = 0.03125`

The lower bound is:

`nominal / 4`

The upper bound is:

`nominal × 4`

The coefficient is intentionally broad because physical switching energy depends on:

`switched capacitance`

`supply voltage`

`wire length`

`fanout`

`placement`

`routing`

`driver topology`

Uncertainty class:

`high`

Calibration note:

The coefficient is a local switching proxy.

It is not derived from a direct measurement of the FRP, binary, or direct ternary state node.

The same coefficient is applied to every architecture.

## 2. Clocked State Bit

Event field:

`clocked_state_bits`

Cost class:

`clocked_state_bit`

Lower bound:

`0.015625`

Nominal weight:

`0.0625`

Upper bound:

`0.25`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one state bit exposed to an active local clock event`

Derivation rule:

`nominal = 2 × encoded_bit_toggle nominal`

Therefore:

`2 × 0.03125 = 0.0625`

The lower bound is:

`nominal / 4`

The upper bound is:

`nominal × 4`

Uncertainty class:

`high`

Calibration note:

Clock activity depends strongly on:

`clock-tree topology`

`clock-gating granularity`

`clock-buffer hierarchy`

`clock-wire capacitance`

`flip-flop clock-pin capacitance`

The raw metric:

`clocked_state_bits`

remains unchanged.

Only its sensitivity weight changes.

## 3. Register Write Bit

Event field:

`register_write_bits`

Cost class:

`register_write_bit`

Lower bound:

`0.03125`

Nominal weight:

`0.125`

Upper bound:

`0.5`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one written architectural state bit including local data-path and storage-node activity`

Derivation rule:

`nominal = 4 × encoded_bit_toggle nominal`

Therefore:

`4 × 0.03125 = 0.125`

The lower bound is:

`nominal / 4`

The upper bound is:

`nominal × 4`

Uncertainty class:

`high`

Calibration note:

This coefficient is separate from:

`encoded_bit_toggle`

and:

`clocked_state_bit`

because the current benchmark event taxonomy records:

`logical data transition`

`clock exposure`

and:

`architectural write activity`

as separate raw events.

The sensitivity analysis preserves that declared taxonomy.

Potential physical overlap is addressed through the wide uncertainty range and later EDA calibration.

## 4. Comparison Event

Event field:

`comparison_events`

Cost class:

`comparison_event`

Lower bound:

`0.125`

Nominal weight:

`0.5`

Upper bound:

`2.0`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one architecture-level comparison proxy`

Derivation rule:

`nominal = 0.5 × normalized 32-bit add`

Therefore:

`0.5 × 1.0 = 0.5`

Uncertainty class:

`high`

Calibration note:

The benchmark counter:

`comparison_events`

does not guarantee that every event is implemented by one identical 32-bit comparator.

The coefficient is therefore an explicit control-path sensitivity proxy.

## 5. Control Event

Event field:

`control_events`

Cost class:

`control_event`

Lower bound:

`0.25`

Nominal weight:

`1.0`

Upper bound:

`8.0`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one aggregate architecture-level processor-cycle control event`

Derivation rule:

`nominal = normalized 32-bit add weight`

Therefore:

`1.0`

Uncertainty class:

`high`

Calibration note:

The counter:

`control_events`

is not a one-to-one gate count.

It is an aggregate benchmark event.

The wide range:

`0.25 → 8.0`

tests sensitivity to control-path implementation cost without assigning the event a hidden physical interpretation.

## 6. Queue Read

Event field:

`queue_reads`

Cost class:

`queue_read`

Lower bound:

`1.0`

Nominal weight:

`5.0`

Upper bound:

`30.0`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY`

Source value:

`implementation dependent`

Source unit:

`normalized relative weight`

Technology node:

`45 nm reference context`

Voltage:

`not specified`

Implementation assumption:

`small bounded pending-route queue implemented as a local register-array or compact local storage structure`

Derivation rule:

`nominal small-local-storage proxy = 5 × normalized 32-bit add`

Uncertainty class:

`high`

Calibration note:

The queue coefficient is not mapped directly to the 8 KB cache anchor because the FRP pending-route queue is substantially smaller than an 8 KB cache.

The range permits:

`compact register implementation`

through:

`higher-overhead local storage implementation`

The queue event count remains unchanged.

## 7. Queue Write

Event field:

`queue_writes`

Cost class:

`queue_write`

Lower bound:

`1.5`

Nominal weight:

`7.5`

Upper bound:

`40.0`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY`

Source value:

`implementation dependent`

Source unit:

`normalized relative weight`

Technology node:

`45 nm reference context`

Voltage:

`not specified`

Implementation assumption:

`small bounded pending-route queue write into a local register-array or compact local storage structure`

Derivation rule:

`nominal = 1.5 × queue_read nominal`

Therefore:

`1.5 × 5.0 = 7.5`

Uncertainty class:

`high`

Calibration note:

The write coefficient is higher than the read coefficient in the nominal scenario because the proxy includes:

`storage update`

and:

`write control activity`

The relation remains a sensitivity assumption.

## 8. 32-Bit Lookup-Table Read

Event field:

`lut_reads_32`

Cost class:

`lut_read_32`

Lower bound:

`20.0`

Nominal weight:

`50.0`

Upper bound:

`100.0`

Basis type:

`derived_from_literature_anchor`

Reference key:

`HOROWITZ_ISSCC_2014_8KB_CACHE_64BIT_ACCESS`

Source value:

`10`

Source unit:

`pJ per 64-bit 8 KB cache access`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`M15 4096-entry 32-bit trigonometric table represented by a local ROM, SRAM-like table, or equivalent mapped lookup structure`

Derivation rule:

`64-bit 8 KB access = 10 pJ`

Width-normalized 32-bit proxy:

`10 pJ × 32 / 64 = 5 pJ`

Normalized against:

`0.1 pJ 32-bit integer add`

Therefore:

`5 pJ / 0.1 pJ = 50.0`

Uncertainty class:

`high`

Calibration note:

The M15 trigonometric lookup structure is not identical to an 8 KB cache.

The coefficient range permits implementation variation between:

`logic or ROM-oriented mapping`

`compact local memory mapping`

`higher-cost table implementation`

The later EDA-calibrated profile must replace this proxy with an implementation-derived value.

## 9. 32 × 32 Fixed-Point Multiply

Event field:

`fixed_point_multiplies_32x32`

Cost class:

`fixed_point_multiply_32x32`

Lower bound:

`20.0`

Nominal weight:

`30.0`

Upper bound:

`40.0`

Basis type:

`literature_anchor`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_MULT`

Source value:

`approximately 3`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`32 × 32 fixed-point multiply is mapped to the published 32-bit integer multiplication energy class`

Derivation rule:

`3 pJ / 0.1 pJ = 30.0`

Lower and upper values provide sensitivity around the rough literature estimate.

Uncertainty class:

`medium`

Calibration note:

This is the strongest direct non-unit arithmetic anchor in the first sensitivity profile.

The same multiplication coefficient applies wherever the declared event class occurs.

## 10. 64-Bit Fixed-Point Accumulate

Event field:

`fixed_point_accumulates_64`

Cost class:

`fixed_point_accumulate_64`

Lower bound:

`1.5`

Nominal weight:

`2.0`

Upper bound:

`4.0`

Basis type:

`derived_from_literature_anchor`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one 64-bit fixed-point accumulation arithmetic event`

Derivation rule:

`nominal width scaling = 2 × 32-bit integer add`

Therefore:

`2 × 1.0 = 2.0`

Uncertainty class:

`medium`

Calibration note:

The derivation does not claim exact linear physical scaling with width.

The range:

`1.5 → 4.0`

covers variation from efficient carry structure or fused accumulation through higher-cost implementation.

## 11. 32-Bit Fixed-Point Add

Event field:

`fixed_point_adds_32`

Cost class:

`fixed_point_add_32`

Lower bound:

`0.5`

Nominal weight:

`1.0`

Upper bound:

`2.0`

Basis type:

`literature_anchor`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`32-bit fixed-point addition maps to the 32-bit integer addition reference class`

Derivation rule:

`0.1 pJ / 0.1 pJ = 1.0`

Uncertainty class:

`low`

Calibration note:

This coefficient defines the normalization basis.

All other relative weights are interpreted against this event.

## 12. 32-Bit Fixed-Point Compare

Event field:

`fixed_point_compares_32`

Cost class:

`fixed_point_compare_32`

Lower bound:

`0.5`

Nominal weight:

`1.0`

Upper bound:

`2.0`

Basis type:

`implementation_assumption`

Reference key:

`HOROWITZ_ISSCC_2014_32BIT_INT_ADD`

Source value:

`0.1`

Source unit:

`pJ`

Technology node:

`45 nm`

Voltage:

`not specified as one fixed value in the rough-energy table`

Implementation assumption:

`one 32-bit fixed-point comparison is represented by one 32-bit-add-equivalent nominal cost`

Derivation rule:

`nominal = 1.0 × normalized 32-bit add`

Uncertainty class:

`high`

Calibration note:

The coefficient remains an implementation assumption because:

`equality comparison`

`magnitude comparison`

`saturation comparison`

and:

`boundary comparison`

may map to different physical structures.

# Reference Keys

## HOROWITZ_ISSCC_2014_32BIT_INT_ADD

Author:

`Mark Horowitz`

Title:

`1.1 Computing's Energy Problem (and What We Can Do About It)`

Venue:

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

Year:

`2014`

Pages:

`10–14`

DOI:

`10.1109/ISSCC.2014.6757323`

Primitive:

`32-bit integer addition`

Reference energy:

`0.1 pJ`

Role:

`normalization anchor`

## HOROWITZ_ISSCC_2014_32BIT_INT_MULT

Author:

`Mark Horowitz`

Title:

`1.1 Computing's Energy Problem (and What We Can Do About It)`

Venue:

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

Year:

`2014`

Pages:

`10–14`

DOI:

`10.1109/ISSCC.2014.6757323`

Primitive:

`32-bit integer multiplication`

Reference energy:

`approximately 3 pJ`

Normalized weight:

`30.0`

Role:

`direct arithmetic anchor`

## HOROWITZ_ISSCC_2014_8KB_CACHE_64BIT_ACCESS

Author:

`Mark Horowitz`

Title:

`1.1 Computing's Energy Problem (and What We Can Do About It)`

Venue:

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

Year:

`2014`

Pages:

`10–14`

DOI:

`10.1109/ISSCC.2014.6757323`

Primitive:

`64-bit access to 8 KB local cache`

Reference energy:

`approximately 10 pJ`

Role:

`local memory hierarchy anchor`

Use in this profile:

`derived 32-bit lookup-table sensitivity proxy`

## HOROWITZ_ISSCC_2014_LOCAL_MEMORY_HIERARCHY

Author:

`Mark Horowitz`

Title:

`1.1 Computing's Energy Problem (and What We Can Do About It)`

Venue:

`2014 IEEE International Solid-State Circuits Conference Digest of Technical Papers`

Year:

`2014`

Pages:

`10–14`

DOI:

`10.1109/ISSCC.2014.6757323`

Role:

`qualitative local-storage cost hierarchy reference`

Use in this profile:

`queue implementation sensitivity context`

# JSON-Ready Scenario Vectors

## Lower-Bound Vector

```text
encoded_bit_toggle = 0.0078125
clocked_state_bit = 0.015625
register_write_bit = 0.03125
comparison_event = 0.125
control_event = 0.25
queue_read = 1.0
queue_write = 1.5
lut_read_32 = 20.0
fixed_point_multiply_32x32 = 20.0
fixed_point_accumulate_64 = 1.5
fixed_point_add_32 = 0.5
fixed_point_compare_32 = 0.5
```

## Nominal Vector

```text
encoded_bit_toggle = 0.03125
clocked_state_bit = 0.0625
register_write_bit = 0.125
comparison_event = 0.5
control_event = 1.0
queue_read = 5.0
queue_write = 7.5
lut_read_32 = 50.0
fixed_point_multiply_32x32 = 30.0
fixed_point_accumulate_64 = 2.0
fixed_point_add_32 = 1.0
fixed_point_compare_32 = 1.0
```

## Upper-Bound Vector

```text
encoded_bit_toggle = 0.125
clocked_state_bit = 0.25
register_write_bit = 0.5
comparison_event = 2.0
control_event = 8.0
queue_read = 30.0
queue_write = 40.0
lut_read_32 = 100.0
fixed_point_multiply_32x32 = 40.0
fixed_point_accumulate_64 = 4.0
fixed_point_add_32 = 2.0
fixed_point_compare_32 = 2.0
```

# Scenario Integrity Rules

The lower-bound scenario must use:

`all lower_bound values`

The nominal scenario must use:

`all nominal_weight values`

The upper-bound scenario must use:

`all upper_bound values`

The first sensitivity package does not independently optimize each coefficient to favor or penalize one architecture.

The scenario vectors are global.

Every architecture receives the same coefficient vector.

## Required Scenario Order

The required result order is:

1. `lower_bound`;

2. `nominal`;

3. `upper_bound`.

## Raw Event Preservation

For every scenario:

`raw event traces must remain byte-identical`

The following must remain unchanged:

`workload_sha256`

`architecture_result_sha256`

`semantic command order`

`semantic command count`

`processor execution`

`logical state changes`

`encoded bit toggles`

`queue events`

`fixed-point operation counts`

`FRP invariant counters`

Only:

`cost coefficients`

may change.

# Potential Event-Overlap Register

The current event taxonomy intentionally exposes multiple activity layers.

Potential physical overlap exists between:

`encoded_bit_toggles`

`clocked_state_bits`

`register_write_bits`

The sensitivity profile preserves these events because they represent distinct declared architectural activities.

The current literature-anchored layer handles overlap by:

`low nominal per-bit weights`

and:

`wide uncertainty ranges`

The later EDA-calibrated profile must determine whether physical implementation requires:

`independent coefficients`

or:

`an overlap-corrected composite model`

The raw counters must remain preserved in either case.

# Anti-Bias Checks

Before the hardware sensitivity profile is accepted, validation must confirm:

`all twelve cost classes are present`

`all coefficients are nonnegative`

`lower <= nominal <= upper`

`every coefficient has a basis type`

`every coefficient has a derivation rule`

`every coefficient has an uncertainty class`

`all literature anchors resolve to declared reference keys`

`all implementation assumptions are explicit`

`the same scenario vector is applied to all architectures`

`no architecture-specific cost coefficient exists`

`no winner condition exists`

`unit_event_cost_v1 remains unchanged`

`reference_comparison_seed_76.json remains unchanged`

# Ranking Stability Analysis

For each scenario, architectures are ordered by:

`total_normalized_energy`

The analysis records:

`lower_bound_ranking`

`nominal_ranking`

`upper_bound_ranking`

The analysis also records:

`ranking_stable`

The value is:

`true`

only when all three complete architecture orderings are identical.

The analysis records:

`ranking_sensitive`

The value is:

`true`

when at least one architecture ordering differs between scenarios.

The analysis also records pairwise stability for:

`Binary Synchronous vs Binary Clock-Gated`

`Binary Synchronous vs Direct Ternary`

`Binary Synchronous vs FRP`

`Binary Clock-Gated vs Direct Ternary`

`Binary Clock-Gated vs FRP`

`Direct Ternary vs FRP`

A pairwise relation may be:

`stable_lower_cost`

`stable_higher_cost`

`crosses_within_sensitivity_range`

No pairwise result is a qualification failure.

# Thermal Sensitivity Rule

Each weighted cycle-cost trace is passed through the same:

`common_rc_thermal_proxy_v1`

Therefore the three scenarios produce:

`lower-bound thermal proxy result`

`nominal thermal proxy result`

`upper-bound thermal proxy result`

The thermal model parameters remain unchanged.

The following remain common across architectures:

`ambient_temperature_proxy`

`thermal_decay`

`thermal_gain`

No architecture-specific thermal coefficient is introduced.

# Required Next Profile

The next file is:

`benchmarks/architecture_comparison/profiles/hardware_sensitivity_cost_profile_v1.json`

That profile must encode:

`lower_bound`

`nominal`

`upper_bound`

for all twelve cost classes.

The profile must also encode:

`reference_basis`

`normalization_reference`

`provenance_map`

`uncertainty_class`

`derivation_rule`

The profile digest must be deterministic.

# Required Sensitivity Runner Extension

The comparison runner must later support:

`--hardware-sensitivity-profile`

The sensitivity execution chain must:

1. load the existing deterministic workload;

2. execute each architecture once;

3. preserve the raw architecture results;

4. evaluate the same raw traces under the lower-bound vector;

5. evaluate the same raw traces under the nominal vector;

6. evaluate the same raw traces under the upper-bound vector;

7. calculate ranking stability;

8. calculate pairwise stability;

9. apply the same common thermal proxy to every scenario;

10. emit one deterministic hardware sensitivity package.

# Qualification Requirements

The sensitivity qualification workflow must require:

`provenance map coverage = 12 / 12`

`coefficient order exact`

`scenario order exact`

`lower <= nominal <= upper`

`same workload digest`

`same architecture result digests`

`same raw event traces`

`semantic_output_match = 1.000`

`FRP actual_direct_events = 0`

`FRP reserved_state_events = 0`

`FRP queue_overflow_events = 0`

`FRP pending_route_count_final = 0`

`deterministic profile digest`

`deterministic package digest`

`byte-identical repeated generation`

The workflow must not require any architecture to rank first.

# Current Position

The calibration chain is now:

`hardware cost calibration contract`

↓

`coefficient provenance map`

↓

`literature-anchored reference values`

↓

`explicit derived coefficients`

↓

`explicit implementation assumptions`

↓

`lower-bound vector`

↓

`nominal vector`

↓

`upper-bound vector`

The next implementation step is:

`hardware_sensitivity_cost_profile_v1.json`

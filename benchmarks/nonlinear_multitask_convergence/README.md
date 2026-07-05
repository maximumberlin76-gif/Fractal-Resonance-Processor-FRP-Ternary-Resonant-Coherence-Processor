# FRP Nonlinear Multitask Phase-Coherence Convergence Benchmark

## Purpose

This benchmark tests whether the Fractal Resonance Processor architecture can reduce time-to-solution for concurrent nonlinear coupled-state workloads while operating under the same declared thermal ceiling as the comparison architectures.

The benchmark does not assume a winner.

The benchmark tests a specific architectural hypothesis:

`increasing nonlinear coupling`

plus:

`increasing concurrent task count`

may produce different latency and throughput scaling between:

`sequential or explicitly scheduled state evaluation`

and:

`collective phase-coherence convergence`

The benchmark is designed to determine whether the FRP phase-coherence execution path can resolve the same semantic workload with lower time-to-solution degradation as concurrency and nonlinear coupling increase.

## Benchmark Separation

This benchmark is a separate measurement contour.

It does not replace:

`benchmarks/architecture_comparison/README.md`

It does not replace:

`unit_event_cost_v1`

It does not replace:

`literature_anchored_cmos45_sensitivity_v1`

It does not replace:

`TEST_REPORT_v0_9_3.md`

It does not modify the original v0.9.3 thermal benchmark result.

It does not modify the M15 Comparative Architecture Benchmark Suite.

The benchmark answers a different technical question:

`under one shared thermal ceiling, how does time-to-solution scale as nonlinear workload concurrency increases?`

## Architectural Hypothesis

Null hypothesis:

`H0`

The FRP phase-coherence execution path does not reduce time-to-solution scaling relative to the comparison architectures under the same semantic workload and the same declared thermal ceiling.

Alternative hypothesis:

`H1`

The FRP phase-coherence execution path preserves lower time-to-solution degradation or higher throughput retention as concurrent nonlinear coupled-state workload increases under the same declared thermal ceiling.

The benchmark must preserve both hypotheses until canonical results exist.

No ranking result may be written before the canonical machine-readable result is generated.

## Architecture Set

The benchmark compares:

1. `binary_synchronous_reference`;

2. `binary_clock_gated_reference`;

3. `direct_ternary_reference`;

4. `frp_v1_7_0_quantized_shadow`.

The architecture set is preserved from the existing Comparative Architecture Benchmark Suite.

The existing FRP kernel must not be duplicated inside benchmark code.

The FRP execution path must be accessed through an adapter bound to:

`frp_prototype_v1_7_0.py`

The current canonical M15 source digest is:

`a65e2c352157ac5b0fc34b3a09605bad53cd62a1ae0d39855ed35f979b507f85`

The obsolete digest:

`104e6f1e0030f948a55783ee01d78330b389033d70d3113e4a5325349d8f8182`

must not be used.

## Semantic Workload

The benchmark workload consists of deterministic batches of concurrent nonlinear coupled-state domains.

Each domain contains:

- a finite state population;

- deterministic initial conditions;

- local coupling relations;

- nonlinear interaction terms;

- phase relations;

- externally declared drive terms;

- one common convergence predicate;

- one common semantic output contract.

Every architecture receives the same workload definition.

Every architecture receives the same deterministic seed.

Every architecture receives the same domain topology.

Every architecture receives the same initial state.

Every architecture receives the same convergence tolerance.

Every architecture receives the same required output precision.

Every architecture must produce the same semantic result.

The architecture-specific execution mechanism may differ.

## Initial Domain Scaling Matrix

The initial canonical domain sizes are:

`8`

`16`

`32`

These sizes align with the existing M15 scaling qualification surface.

The initial concurrent-domain counts are:

`1`

`2`

`4`

`8`

The benchmark therefore evaluates increasing nonlinear multitask pressure without changing the semantic definition of an individual task.

The canonical execution order is:

`domain size`

↓

`concurrent domain count`

↓

`deterministic workload instance`

↓

`architecture-specific execution`

↓

`shared convergence test`

↓

`shared thermal-ceiling test`

↓

`machine-readable result`

## Nonlinearity Scaling

Each workload instance must declare one global nonlinearity class.

The initial canonical classes are:

1. `low`;

2. `medium`;

3. `high`.

The class definition must be machine-readable.

The same class parameters must be applied to every architecture.

No architecture-specific nonlinearity parameters are permitted.

The purpose of the scaling axis is to test whether explicit state evaluation and collective phase-coherence convergence produce different time-to-solution behavior as coupling complexity increases.

## Shared Thermal Ceiling

The benchmark must operate under one common declared thermal ceiling.

The same thermal ceiling must apply to every architecture.

No architecture-specific thermal ceiling is permitted.

The benchmark must use:

`common_rc_thermal_proxy_v1`

The thermal ceiling must be declared before the canonical comparison run.

The thermal ceiling must not be changed after observing ranking results.

The canonical thermal-ceiling value must be stored in the machine-readable workload or benchmark profile.

An architecture that exceeds the common thermal ceiling must not be silently allowed to continue at unrestricted activity.

The execution contract must explicitly record one of:

`within_ceiling`

`throttled`

`ceiling_violation`

The throttling rule must be deterministic.

The same throttling rule must apply to every architecture.

## Speed Measurement Contract

Python wall-clock runtime is not the primary benchmark metric.

Python interpreter timing must not be used as the canonical architecture-speed result.

The primary speed question is:

`how many declared benchmark ticks are required to reach the same semantic solution under the same thermal ceiling?`

Primary metrics:

`time_to_first_solution_ticks`

`time_to_all_solutions_ticks`

`solutions_completed`

`steady_state_throughput`

`throughput_retention_ratio`

`latency_growth_ratio`

Secondary metrics:

`heat_peak`

`thermal_ceiling_status`

`thermal_throttle_ticks`

`total_normalized_energy`

`semantic_completion_ratio`

`semantic_output_match`

Diagnostic-only metrics may include host wall-clock time.

Diagnostic host timing must not determine the canonical ranking.

## Multitask Pressure

The benchmark must distinguish between:

`single-task latency`

and:

`concurrent-task throughput`

The central scaling question is not limited to:

`which architecture completes one small task first?`

The benchmark must also measure:

`how much latency grows when concurrent task count increases`

and:

`how much throughput is retained when concurrent task count increases`

The canonical scaling chain is:

`1 concurrent domain`

↓

`2 concurrent domains`

↓

`4 concurrent domains`

↓

`8 concurrent domains`

A possible binary advantage at low concurrency must be preserved if observed.

A possible FRP advantage at high concurrency must be preserved if observed.

No result may be hidden because it conflicts with the architectural hypothesis.

## Phase-Coherence Execution Question

The benchmark specifically tests whether:

`many coupled states`

↓

`collective phase interaction`

↓

`phase-coherence convergence`

↓

`stable attractor or converged semantic state`

can reach the required result with a different scaling law from:

`many coupled states`

↓

`explicit state evaluation`

↓

`scheduled update sequence`

↓

`iterative convergence`

The benchmark must not treat these execution paths as identical implementations.

The semantic task must be identical.

The execution architecture may differ.

## Resource Fairness

The benchmark must declare all resource assumptions explicitly.

At minimum, the machine-readable benchmark contract must record:

- active architecture lanes;

- state population;

- concurrent domain count;

- domain size;

- input precision;

- output precision;

- maximum benchmark ticks;

- thermal ceiling;

- thermal proxy identifier;

- deterministic seed;

- convergence tolerance;

- scheduler mode;

- architecture source digest.

No hidden architecture-specific resource multiplier is permitted.

No architecture may receive a larger semantic workload partitioning advantage without that difference being recorded.

## Semantic Completion Contract

A task is complete only when the common convergence predicate is satisfied.

Early termination without satisfying the semantic convergence predicate is not completion.

The benchmark must record:

`semantic_completion_ratio`

The benchmark must record:

`semantic_output_match`

A faster result with incorrect semantic output is not a valid speed result.

The canonical comparison requires:

`semantic_completion_ratio = 1.000`

and:

`semantic_output_match = 1.000`

for any architecture included in final speed ranking.

## FRP Invariants

The FRP benchmark path must preserve:

`actual_direct_events = 0`

`reserved_state_events = 0`

`queue_overflow_events = 0`

The FRP benchmark path must preserve mandatory neutral routing:

`-1 → 0 → 1`

`1 → 0 → -1`

The FRP benchmark path must preserve tick separation:

`tick N: active polarity → 0`

`later tick: 0 → target polarity`

The FRP benchmark path must preserve:

`transition_fraction = 0.25`

The FRP benchmark path must preserve deterministic seeded execution.

## No-Winner-Assertion Policy

CI must not assert:

`FRP must be faster`

`binary must be slower`

`FRP must retain higher throughput`

`binary must fail under multitasking`

`FRP must rank first`

`binary must rank last`

CI may assert only:

- workload integrity;

- deterministic execution;

- semantic completion;

- semantic equivalence;

- thermal-ceiling contract integrity;

- trace integrity;

- source-digest binding;

- FRP invariant preservation;

- byte-identical repeated generation.

Ranking must be produced only from canonical machine-readable results.

## Canonical Result Requirements

The canonical result must contain:

- benchmark identifier;

- workload profile identifier;

- architecture source digests;

- deterministic seed;

- complete workload matrix;

- domain sizes;

- concurrent domain counts;

- nonlinearity classes;

- thermal ceiling;

- thermal proxy identifier;

- raw architecture traces;

- raw event counters;

- time-to-first-solution values;

- time-to-all-solutions values;

- throughput values;

- throughput-retention values;

- latency-growth values;

- thermal-ceiling status;

- semantic completion ratios;

- semantic output-match values;

- FRP invariants;

- deterministic package SHA-256.

The canonical result must be generated twice.

The two generated files must be byte-identical.

## Canonical Question

The benchmark exists to answer one question:

`when nonlinear coupled-state multitask pressure increases, which architecture reaches the same semantic solution sooner while remaining under the same declared thermal ceiling?`

The answer must come from the canonical result.

The answer must not be written in advance.

## Planned File Set

Initial benchmark contract:

`benchmarks/nonlinear_multitask_convergence/README.md`

Planned workload profile:

`benchmarks/nonlinear_multitask_convergence/workloads/nonlinear_multitask_workload_v1.json`

Planned workload validator:

`benchmarks/nonlinear_multitask_convergence/validate_nonlinear_multitask_workload.py`

Planned architecture adapters:

`benchmarks/nonlinear_multitask_convergence/adapters/`

Planned benchmark runner:

`benchmarks/nonlinear_multitask_convergence/run_nonlinear_multitask_convergence.py`

Planned canonical result:

`benchmarks/nonlinear_multitask_convergence/results/reference_nonlinear_multitask_seed_76.json`

Planned GitHub Actions qualification workflow:

`.github/workflows/frp-nonlinear-multitask-convergence.yml`

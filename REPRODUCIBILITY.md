# Reproducibility — Fractal-Resonance-Processor-FRP-Ternary-Resonant-Coherence-Processor

This document defines the reproducibility path for the current Fractal Resonance Processor (FRP) release layer.

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Main executable reference file:

`frp_prototype_v1_7_0.py`

Current architecture document:

`docs/m15_implementation_mapping_domain_interface_qualification_closure.md`

Current test report:

`TEST_REPORT_v1_7_0.md`

Current validation index:

`FRP_VALIDATION_INDEX_v1_7_0.md`

Current release notes:

`RELEASE_NOTES_v1_7_0.md`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation status:

`PASS`

## 1. Reproducibility Target

The current reproducibility chain is:

`source revision`

↓

`execution environment`

↓

`Python compilation`

↓

`M15 self-test matrix`

↓

`structured reference execution`

↓

`fixed-point interface artifacts`

↓

`quantized hardware shadow execution`

↓

`cycle-exact integer reference traces`

↓

`deterministic RTL comparison vectors`

↓

`SystemVerilog interface mapping`

↓

`RTL assertion correlation`

↓

`reference equivalence validation`

↓

`qualification closure`

The primary reproducibility target is the current FRP v1.7.0 M15 architecture layer.

Comparative architecture and hardware-sensitivity suites remain supporting validation contours and are reproduced separately.

## 2. Environment

Current M15 GitHub Actions environment:

- runner: `ubuntu-latest`;
- Python: `3.12`;
- workflow timeout: `30 minutes`.

Recommended local environment:

    Python 3.12

Install declared dependencies from the repository root:

    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt

Current declared dependency:

    numpy>=1.26.0

Before execution, record:

    git rev-parse HEAD
    git status --short
    python --version
    python -m pip freeze

A clean reproducibility record should preserve:

- exact commit hash;
- clean or explicitly documented working-tree state;
- Python version;
- installed dependency versions.

## 3. Required Current Files

Current M15 reproduction requires:

- `frp_prototype_v1_7_0.py`;
- `requirements.txt`;
- `docs/m15_implementation_mapping_domain_interface_qualification_closure.md`;
- `.github/workflows/frp-m15-implementation-mapping-qualification.yml`.

Current release-traceability records:

- `TEST_REPORT_v1_7_0.md`;
- `FRP_VALIDATION_INDEX_v1_7_0.md`;
- `RELEASE_NOTES_v1_7_0.md`.

Historical executable references and historical release records remain version-specific evidence.

They are not substituted for the current M15 executable reference.

## 4. Compile Gate

Run from the repository root:

    python -m py_compile frp_prototype_v1_7_0.py

Required result:

`PASS`

## 5. M15 Self-Test Matrix

Default self-test:

    python frp_prototype_v1_7_0.py --mode self-test --output json

Free scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler free --output json

7/1 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 7/1 --output json

1/7 scheduler:

    python frp_prototype_v1_7_0.py --mode self-test --scheduler 1/7 --output json

Every self-test output must satisfy:

| Field | Required value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `status` | `PASS` |
| `check_count` | `41` |
| all values in `checks` | `True` |

Current validated result:

`41/41 PASS`

## 6. Structured Reference Execution

Generate the default M15 structured output:

    python frp_prototype_v1_7_0.py --mode demo --output json > structured-output.json

Required values:

| Field | Required value |
|---|---|
| `schema` | `frp.structured_output.v1.7.0` |
| `version` | `1.7.0` |
| `milestone` | `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package` |
| `summary.cells` | `16` |
| `summary.hierarchy_depth` | `4` |
| `summary.request_lanes` | `4` |
| `summary.ticks_recorded` | `64` |
| `summary.scheduler` | `7/1` |
| `summary.scheduler_counts.balance` | `56` |
| `summary.scheduler_counts.commit` | `8` |
| `summary.scheduler_counts_valid` | `True` |
| `summary.balanced_ternary_state_domain` | `True` |
| `summary.reserved_state_events` | `0` |
| `summary.actual_direct_events` | `0` |
| `summary.queue_overflow_events` | `0` |
| `summary.fixed_point_topology_sum_exact` | `True` |
| `summary.fixed_point_thermal_sum_exact` | `True` |

Additional required conditions:

- `summary.switch_load_peak <= 0.25`;
- `summary.C_minus_P_min > 0.0`.

## 7. Preserved Computational Kernel Invariants

Balanced ternary state domain:

`{-1, 0, 1}`

Active neutral state:

`0`

Mandatory opposite-polarity routes:

`-1 → 0 → 1`

`1 → 0 → -1`

Tick-separated execution relation:

`tick N: active polarity → 0`

↓

`pending neutral route retained`

↓

`tick N+1 or later: 0 → target polarity`

Required invariants:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- scheduler-count validity;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

The reproducibility path must not relax these invariants.

## 8. Generate the Current M15 Artifact Package

Create directories:

    mkdir -p artifacts/m15/vectors_a
    mkdir -p artifacts/m15/vectors_b

Generate the fixed-point interface profile:

    python frp_prototype_v1_7_0.py --export-fixed-point-interface-profile > artifacts/m15/fixed-point-interface-profile.json

Generate the balanced ternary hardware encoding map:

    python frp_prototype_v1_7_0.py --export-balanced-ternary-hardware-encoding-map > artifacts/m15/balanced-ternary-hardware-encoding-map.json

Generate the quantized reference shadow model:

    python frp_prototype_v1_7_0.py --export-quantized-reference-shadow-model > artifacts/m15/quantized-reference-shadow-model.json

Generate the cycle-exact reference trace:

    python frp_prototype_v1_7_0.py --export-cycle-exact-reference-trace > artifacts/m15/cycle-exact-reference-trace.json

Generate the RTL comparison vector package:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package > artifacts/m15/rtl-comparison-vector-package.json

Generate the SystemVerilog testbench interface map:

    python frp_prototype_v1_7_0.py --export-systemverilog-testbench-interface-map > artifacts/m15/systemverilog-testbench-interface-map.json

Generate the synthesizable RTL reference core:

    python frp_prototype_v1_7_0.py --export-synthesizable-rtl-reference-core > artifacts/m15/synthesizable-rtl-reference-core.json

Generate the RTL assertion correlation harness:

    python frp_prototype_v1_7_0.py --export-rtl-assertion-correlation-harness > artifacts/m15/rtl-assertion-correlation-harness.json

Generate the reference RTL equivalence report:

    python frp_prototype_v1_7_0.py --export-reference-rtl-equivalence-report > artifacts/m15/reference-rtl-equivalence-report.json

Generate the qualification closure manifest:

    python frp_prototype_v1_7_0.py --export-qualification-closure-manifest > artifacts/m15/qualification-closure-manifest.json

## 9. Expected M15 Artifact Schemas

| Artifact | Required schema |
|---|---|
| `fixed-point-interface-profile.json` | `frp.m15.fixed_point_interface_profile.v1.7.0` |
| `balanced-ternary-hardware-encoding-map.json` | `frp.m15.balanced_ternary_hardware_encoding_map.v1.7.0` |
| `quantized-reference-shadow-model.json` | `frp.m15.quantized_reference_shadow_model.v1.7.0` |
| `cycle-exact-reference-trace.json` | `frp.m15.cycle_exact_reference_trace.v1.7.0` |
| `rtl-comparison-vector-package.json` | `frp.m15.rtl_comparison_vector_package.v1.7.0` |
| `systemverilog-testbench-interface-map.json` | `frp.m15.systemverilog_testbench_interface_map.v1.7.0` |
| `synthesizable-rtl-reference-core.json` | `frp.m15.synthesizable_rtl_reference_core.v1.7.0` |
| `rtl-assertion-correlation-harness.json` | `frp.m15.rtl_assertion_correlation_harness.v1.7.0` |
| `reference-rtl-equivalence-report.json` | `frp.m15.reference_rtl_equivalence_report.v1.7.0` |
| `qualification-closure-manifest.json` | `frp.m15.qualification_closure_manifest.v1.7.0` |

Every artifact must also report:

- version `1.7.0`;
- milestone `M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`.

## 10. Fixed-Point Contract

Required representations:

| Domain | Representation |
|---|---|
| general scalar | `S32Q16` |
| normalized coefficient | `S32Q30` |
| phase | `PHASE_U32` |
| gamma | `GAMMA_S32` |
| trigonometric table entries | `4096` |

Required exactness markers:

- `fixed_point_topology_sum_exact = True`;
- `fixed_point_thermal_sum_exact = True`.

## 11. Balanced Ternary Hardware Encoding

Canonical two-bit encoding:

`-1 → 2'b11`

`0 → 2'b00`

`+1 → 2'b01`

Reserved encoding:

`2'b10`

Canonical integer encoding map:

`-1 → 3`

`0 → 0`

`+1 → 1`

Reserved integer code:

`2`

Required interface values:

- `request_lanes = 4`;
- `cell_id_width = 4`.

Required invariant:

`reserved_state_events = 0`

## 12. Deterministic RTL Vector Package

Generate package A:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_a > artifacts/m15/vector-package-a.json

Generate package B independently:

    python frp_prototype_v1_7_0.py --export-rtl-comparison-vector-package --vector-output-dir artifacts/m15/vectors_b > artifacts/m15/vector-package-b.json

Compare both directories:

    diff -qr artifacts/m15/vectors_a artifacts/m15/vectors_b

Required result:

`no differences`

Expected files:

- `frp_m15_kernel_vectors.vec`;
- `frp_m15_pending_routes.trace`;
- `frp_m15_scheduler_free_vectors.vec`;
- `frp_m15_scheduler_7_1_vectors.vec`;
- `frp_m15_scheduler_1_7_vectors.vec`;
- `frp_m15_full_correlation_vectors.vec`;
- `frp_m15_cell_trace.vec`;
- `frp_m15_reference_preload.json`;
- `frp_m15_trig_lut_q30.vec`;
- `frp_m15_sha256_manifest.json`.

Both independently generated packages must be byte-identical.

## 13. Cycle-Exact Trace Contract

The cycle-exact reference trace must preserve:

- exactly `64` trace rows;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- deterministic gamma-noise target vectors for all `16` cells.

The cycle-exact trace is the integer reference path between the quantized hardware shadow and the deterministic RTL comparison vector domain.

## 14. Scaling Reproduction

Generate the 8-cell output:

    python frp_prototype_v1_7_0.py --cells 8 --steps 16 --mode demo --output json > artifacts/m15/scaling-8.json

Generate the 16-cell output:

    python frp_prototype_v1_7_0.py --cells 16 --steps 16 --mode demo --output json > artifacts/m15/scaling-16.json

Generate the 32-cell output:

    python frp_prototype_v1_7_0.py --cells 32 --steps 16 --mode demo --output json > artifacts/m15/scaling-32.json

Expected structure:

| Cells | Hierarchy depth | Request lanes | Packed state width |
|---|---|---|---|
| `8` | `3` | `2` | `16 bits` |
| `16` | `4` | `4` | `32 bits` |
| `32` | `5` | `8` | `64 bits` |

Packed state width is derived as:

`2 × cells`

Every scaling output must preserve:

- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- balanced ternary state-domain validity;
- scheduler-count validity;
- exact fixed-point topology sum;
- exact fixed-point thermal sum.

## 15. M15 Benchmark Matrix

Generate the current M15 benchmark matrix:

    python frp_prototype_v1_7_0.py --export-benchmark-matrix > artifacts/m15/benchmark-matrix.json

Expected schema:

`frp.m3.benchmark_matrix.v1.7.0`

Expected row count:

`5`

Expected architecture order:

1. `frp_v1_6_0_m14_floating_semantic_reference`;
2. `frp_v1_7_0_quantized_hardware_shadow`;
3. `frp_v1_7_0_cycle_exact_vector_package`;
4. `frp_v1_7_0_systemverilog_correlation_contract`;
5. `frp_v1_7_0_qualification_closure`.

This matrix belongs to the M15 qualification package and does not replace the primary M15 architecture-validation path.

## 16. Reference Equivalence Contract

### Floating reference to quantized shadow

Required exact sequence matches:

- state sequence match `1.0`;
- scheduler sequence match `1.0`;
- neutral-route sequence match `1.0`;
- `C_minus_P` sign match `1.0`;
- boundary-order match `1.0`.

Required maximum error bounds:

| Field | Maximum error |
|---|---|
| phase | `0.02` |
| frequency | `0.0001` |
| heat | `0.001` |
| gamma | `0.000001` |
| coherence | `0.01` |
| `C` | `0.01` |
| `P` | `0.001` |
| `C_minus_P` | `0.01` |

### Quantized shadow deterministic replay

Required exact replay matches:

- state match `1.0`;
- scheduler match `1.0`;
- pending-route match `1.0`;
- counter match `1.0`;
- trace match `1.0`;
- cell-trace match `1.0`.

## 17. Qualification Closure

The qualification closure manifest must report:

- status `PASS`;
- all values in `checks` equal `True`;
- exactly ten M15 artifact layers.

The qualification closure manifest is the current M15 release-validation endpoint.

## 18. Independent Repeat Rule

A deterministic reproducibility claim requires an independent repeat.

Required procedure:

1. generate the first output;
2. generate the second output independently from the same declared source state and inputs;
3. compare the complete files or directories;
4. require byte-identical equality.

Accepted comparison commands:

    cmp first.json second.json

or:

    diff -qr first_directory second_directory

Semantic resemblance is not a deterministic repeat.

## 19. SHA-256 Evidence

Record SHA-256 values after successful generation.

M15 JSON artifacts:

    sha256sum artifacts/m15/*.json > artifacts/m15/sha256-manifest.txt

Deterministic vector packages:

    sha256sum artifacts/m15/vectors_a/* > artifacts/m15/vectors-a-sha256.txt
    sha256sum artifacts/m15/vectors_b/* > artifacts/m15/vectors-b-sha256.txt

Retain the manifests with:

- source commit;
- Python version;
- dependency versions;
- execution date;
- operating environment.

## 20. Published FRP v1.7.0 Validation Evidence

Published release layer:

`FRP v1.7.0 — M15 Implementation Mapping, Domain Interface, and Qualification Closure Package`

Validation environment:

`GitHub Actions hardware-backed CI execution`

Validated release commit:

`5fd9a4f`

Validated workflow runs recorded in `TEST_REPORT_v1_7_0.md`:

- `FRP Structured Output #113`;
- `FRP M15 Implementation Mapping and Qualification Closure #1`;
- `FRP Self Test #154`;
- `FRP Benchmark Smoke Test #152`.

Published validation result:

`PASS`

Published M15 self-test result:

`41/41 PASS`

These values are release evidence for the validated v1.7.0 layer and are not statements about later documentation-only commits.

## 21. Historical Release Rule

Historical executable references remain bound to their historical release records and workflows.

Examples:

- `frp_prototype_v0_9_3_mobile.py` remains bound to the foundational self-test and benchmark smoke workflows;
- `frp_prototype_v0_9_4.py` remains bound to the structured-output workflow;
- M3 through M14 executable references remain bound to their release-specific milestone workflows;
- `frp_prototype_v1_7_0.py` remains the current M15 executable reference.

Historical workflows must not be silently redirected to the current executable reference.

Current reproducibility must not rewrite historical release evidence.

## 22. Supporting Comparative Architecture Reproduction

The comparative architecture benchmark is a supporting validation contour.

Directory:

`benchmarks/architecture_comparison/`

Compared references:

1. `binary_synchronous_reference`;
2. `binary_clock_gated_reference`;
3. `direct_ternary_reference`;
4. `frp_v1_7_0_quantized_shadow`.

From `benchmarks/architecture_comparison/`, prepare the local qualification directory:

    mkdir -p .qualification

Run the end-to-end self-test:

    python run_architecture_comparison.py --self-test --output text

Generate the canonical comparison package:

    python run_architecture_comparison.py --workload-profile profiles/workload_profile_v1.json --cost-profile profiles/normalized_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write results/reference_comparison_seed_76.json --output text

Generate an independent repeat:

    python run_architecture_comparison.py --workload-profile profiles/workload_profile_v1.json --cost-profile profiles/normalized_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write .qualification/reference_comparison_seed_76_repeat.json --output text

Compare:

    cmp results/reference_comparison_seed_76.json .qualification/reference_comparison_seed_76_repeat.json

Required result:

`byte-identical`

Qualification policy:

`integrity_only_no_winner_assertions`

Required winner assertions:

`[]`

This supporting benchmark does not define the FRP architecture milestone chain.

## 23. Supporting Hardware-Sensitivity Reproduction

From `benchmarks/architecture_comparison/`, prepare the local qualification directory:

    mkdir -p .qualification

Validate the profile:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --output text

Run the profile validator self-test:

    python validate_hardware_sensitivity_profile.py --profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output text

Run the sensitivity comparison self-test:

    python run_hardware_sensitivity_comparison.py --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --self-test --output json

Generate the canonical sensitivity result:

    python run_hardware_sensitivity_comparison.py --workload-profile profiles/workload_profile_v1.json --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write results/reference_comparison_seed_76_hardware_sensitivity_v1.json --output text

Generate an independent repeat:

    python run_hardware_sensitivity_comparison.py --workload-profile profiles/workload_profile_v1.json --hardware-sensitivity-profile profiles/hardware_sensitivity_cost_profile_v1.json --thermal-profile profiles/thermal_proxy_profile_v1.json --frp-scheduler "7/1" --write .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json --output text

Compare:

    cmp results/reference_comparison_seed_76_hardware_sensitivity_v1.json .qualification/reference_comparison_seed_76_hardware_sensitivity_v1_repeat.json

Required result:

`byte-identical`

The hardware-sensitivity layer remains separate from the primary M15 architecture-validation path.

## 24. Reproducibility Acceptance Criteria

The current FRP v1.7.0 M15 layer is reproducible when:

- source revision is recorded;
- environment is recorded;
- `frp_prototype_v1_7_0.py` compiles;
- all four self-test variants report `41/41 PASS`;
- structured output matches the v1.7.0 schema and M15 milestone;
- balanced ternary state-domain validity remains true;
- `actual_direct_events = 0`;
- `reserved_state_events = 0`;
- `queue_overflow_events = 0`;
- fixed-point topology sum remains exact;
- fixed-point thermal sum remains exact;
- all ten M15 artifact layers are generated;
- every M15 artifact reports the expected schema, version, and milestone;
- deterministic vector packages are byte-identical;
- scaling outputs preserve all required invariants;
- reference equivalence checks satisfy their exact-match and bounded-error contracts;
- qualification closure reports `PASS`.

Supporting comparative claims additionally require their own independent byte-identical regeneration.

## 25. Repository Alignment Rule

When the current architecture layer changes, review:

- `README.md`;
- `ROADMAP.md`;
- `MILESTONES.md`;
- `PROJECT_STRUCTURE.md`;
- `CI.md`;
- `REPRODUCIBILITY.md`;
- `USAGE.md`;
- current executable reference;
- current test report;
- current validation index;
- current release notes;
- current architecture document;
- current milestone workflow;
- `docs/README.md`.

Historical release records remain historical.

Supporting comparative validation remains separate from the primary FRP architecture progression.

## 26. Current Status

Current version:

`FRP v1.7.0`

Current milestone:

`M15 — Implementation Mapping, Domain Interface, and Qualification Closure Package`

Current executable reference:

`frp_prototype_v1_7_0.py`

Current primary qualification workflow:

`.github/workflows/frp-m15-implementation-mapping-qualification.yml`

Current published release validation result:

`PASS`

Current validated M15 self-test count:

`41/41`

Current reproducibility role:

`preserve exact traceability from the FRP v1.7.0 source revision through deterministic M15 execution, hardware-facing artifact generation, reference equivalence validation, and qualification closure`

Next planned architecture layer:

`FRP v1.8.0 — M16 RTL Core Realization and Execution Semantics Package`

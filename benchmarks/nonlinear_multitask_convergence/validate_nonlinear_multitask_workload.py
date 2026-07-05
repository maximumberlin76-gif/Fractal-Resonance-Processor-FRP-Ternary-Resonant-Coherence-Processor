#!/usr/bin/env python3
"""Validate the FRP nonlinear multitask workload profile v1.

The validator checks the predeclared 36-case matrix, repository digest bindings,
shared thermal-ceiling contract, semantic-convergence rules, FRP invariants,
resource fairness, deterministic workload digest, and the no-winner policy.
It does not execute the benchmark and does not produce architecture rankings.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import itertools
import json
import math
import sys
from pathlib import Path
from typing import Any, Mapping, NoReturn, Sequence


SCHEMA = "frp.benchmark.nonlinear_multitask_workload_profile.v1"
SUITE_NAME = "FRP Nonlinear Multitask Phase-Coherence Convergence Benchmark"
PROFILE_NAME = "nonlinear_multitask_workload_v1"
PROFILE_ROLE = "predeclared_canonical_workload_contract"
PROFILE_STATUS = "reference_workload_profile"
BENCHMARK_QUESTION = (
    "when nonlinear coupled-state multitask pressure increases, which "
    "architecture reaches the same semantic solution sooner while remaining "
    "under the same declared thermal ceiling?"
)
SEED = 76
CASE_COUNT = 36

ARCHITECTURE_ORDER = [
    "binary_synchronous_reference",
    "binary_clock_gated_reference",
    "direct_ternary_reference",
    "frp_v1_7_0_quantized_shadow",
]

FRP_SOURCE_PATH = "frp_prototype_v1_7_0.py"
FRP_SOURCE_SHA256 = (
    "a65e2c352157ac5b0fc34b3a09605bad53cd62a1ae0d39855ed35f979b507f85"
)
OBSOLETE_FRP_SOURCE_SHA256 = (
    "104e6f1e0030f948a55783ee01d78330b389033d70d3113e4a5325349d8f8182"
)

EXECUTION_ORDER = [
    "domain_size",
    "concurrent_domain_count",
    "nonlinearity_class",
]
DOMAIN_SIZE_ORDER = [8, 16, 32]
CONCURRENT_DOMAIN_COUNT_ORDER = [1, 2, 4, 8]
NONLINEARITY_CLASS_ORDER = ["low", "medium", "high"]

THERMAL_PROFILE_PATH = (
    "benchmarks/architecture_comparison/profiles/thermal_proxy_profile_v1.json"
)
THERMAL_PROFILE_NAME = "common_rc_thermal_proxy_v1"
THERMAL_PROFILE_FILE_SHA256 = (
    "aeafebc3e71d1311a3445bd1528cbe7322546f79d6a5099dfed3a9590fc4a25b"
)
COST_PROFILE_PATH = (
    "benchmarks/architecture_comparison/profiles/"
    "hardware_sensitivity_cost_profile_v1.json"
)
COST_PROFILE_NAME = "literature_anchored_cmos45_sensitivity_v1"
COST_PROFILE_FILE_SHA256 = (
    "79c1c17c924bde6947dce477c2b8b64600684c993e7f42c1f00f6ffca0228a1c"
)

EXPECTED_ROOT_FIELDS = {
    "schema",
    "suite_name",
    "profile_name",
    "profile_role",
    "profile_status",
    "benchmark_question",
    "seed",
    "case_count",
    "architecture_order",
    "frp_reference",
    "execution_order",
    "domain_size_order",
    "concurrent_domain_count_order",
    "nonlinearity_class_order",
    "scheduler_mode",
    "transition_fraction",
    "auto_targets_enable",
    "shared_problem_model",
    "deterministic_initialization",
    "nonlinearity_classes",
    "resource_fairness_contract",
    "convergence_contract",
    "thermal_ceiling_contract",
    "primary_metrics",
    "secondary_metrics",
    "frp_invariant_contract",
    "ranking_eligibility_contract",
    "validation_contract",
    "digest_contract",
    "workload_profile_sha256",
}

EXPECTED_FRP_REFERENCE = {
    "version": "v1.7.0",
    "source_path": FRP_SOURCE_PATH,
    "source_sha256": FRP_SOURCE_SHA256,
    "adapter_rule": "import_existing_kernel_without_duplication",
}

EXPECTED_SHARED_PROBLEM_MODEL = {
    "name": "hierarchical_kuramoto_sakaguchi_phase_convergence_v1",
    "phase_domain": "PHASE_U32",
    "balanced_ternary_state_domain": [-1, 0, 1],
    "topology": "deterministic_dyadic_hierarchical_v1",
    "fractal_alpha": 0.7,
    "thermal_beta": 1.2,
    "ambient_heat": 0.05,
    "thermal_time_constant": 14.0,
    "thermal_soft_limit": 0.22,
    "thermal_hard_limit": 0.9,
    "thermal_diffusion_gain": 0.035,
    "base_frequency": 1.0,
    "phase_velocity_base_gain": 0.06,
    "scheduler_push_free": 0.003,
    "state_projection_rule": {
        "positive": "sin(phase) > 0.33",
        "neutral": "-0.33 <= sin(phase) <= 0.33",
        "negative": "sin(phase) < -0.33",
    },
    "cross_domain_coupling_gain": 0.0,
    "domain_independence": True,
}

EXPECTED_DETERMINISTIC_INITIALIZATION = {
    "domain_seed_derivation": (
        "sha256(seed || domain_size || concurrent_domain_count || "
        "nonlinearity_class || domain_index)"
    ),
    "initial_states": "uniform_seeded_choice_from_-1_0_1",
    "initial_phases": "uniform_seeded_phase_words_over_full_cycle",
    "initial_frequency_target_q16": 65536,
    "initial_frequency_current_q16": 65536,
    "initial_heat_q16": 3277,
    "gamma_noise_target_generation": "uniform_seeded_signed_q16_with_class_scale",
    "same_initial_state_for_all_architectures": True,
    "same_initial_phase_for_all_architectures": True,
    "same_gamma_noise_target_for_all_architectures": True,
}

EXPECTED_NONLINEARITY_CLASSES = {
    "low": {
        "class_index": 0,
        "coupling_nominal": 0.14,
        "gamma_nominal_ratio_pi": 0.15,
        "gamma_nominal_radians": 0.471238898038469,
        "delay_alpha": 0.15,
        "gamma_noise_target_scale": 0.025,
        "parameter_rule": (
            "0.5x M15 nominal coupling, gamma, and delay; "
            "0.5x medium gamma-noise scale"
        ),
    },
    "medium": {
        "class_index": 1,
        "coupling_nominal": 0.28,
        "gamma_nominal_ratio_pi": 0.3,
        "gamma_nominal_radians": 0.942477796076938,
        "delay_alpha": 0.3,
        "gamma_noise_target_scale": 0.05,
        "parameter_rule": "M15 nominal coupling, gamma, and delay",
    },
    "high": {
        "class_index": 2,
        "coupling_nominal": 0.42,
        "gamma_nominal_ratio_pi": 0.45,
        "gamma_nominal_radians": 1.413716694115407,
        "delay_alpha": 0.45,
        "gamma_noise_target_scale": 0.1,
        "parameter_rule": (
            "1.5x M15 nominal coupling, gamma, and delay; "
            "2.0x medium gamma-noise scale"
        ),
    },
}

EXPECTED_RESOURCE_FAIRNESS = {
    "engine_contexts_per_case": "equal_to_concurrent_domain_count",
    "state_lanes_per_engine_context": "equal_to_domain_size",
    "total_state_lanes_per_case": "domain_size * concurrent_domain_count",
    "same_engine_context_count_for_all_architectures": True,
    "same_total_state_lane_count_for_all_architectures": True,
    "additional_architecture_specific_engine_contexts": False,
    "hidden_parallelism": False,
    "domain_execution_order": "domain_index_ascending_round_robin",
    "shared_aggregate_thermal_ceiling_per_case": True,
}

EXPECTED_CONVERGENCE_CONTRACT = {
    "state_stability_ticks": 8,
    "phase_velocity_dispersion_max_radians_per_tick": 0.01,
    "phase_coherence_delta_max": 0.001,
    "semantic_state_output": "exact_balanced_ternary_state_vector",
    "semantic_completion_ratio_required": 1.0,
    "semantic_output_match_required": 1.0,
    "maximum_logical_iterations_per_domain": 4096,
    "maximum_benchmark_ticks_per_case": 262144,
    "completion_requires_all_predicates": True,
}

EXPECTED_THERMAL_CEILING_CONTRACT = {
    "thermal_profile_path": THERMAL_PROFILE_PATH,
    "thermal_profile_name": THERMAL_PROFILE_NAME,
    "thermal_profile_sha256": THERMAL_PROFILE_FILE_SHA256,
    "cost_profile_path": COST_PROFILE_PATH,
    "cost_profile_name": COST_PROFILE_NAME,
    "cost_profile_sha256": COST_PROFILE_FILE_SHA256,
    "cost_scenario": "nominal",
    "temperature_unit": "normalized_temperature_proxy",
    "ambient_temperature_proxy": 0.0,
    "thermal_decay": 0.95,
    "thermal_gain": 0.01,
    "thermal_ceiling": 1.0,
    "normalized_activity_quantum_per_benchmark_tick": 4.0,
    "full_quantum_steady_state_temperature_proxy": 0.8,
    "activity_slicing_rule": (
        "preserve_declared_event_order_and_split_aggregate_cost_into_exact_4.0_"
        "or_final_remainder_quanta"
    ),
    "cooling_tick_cost": 0.0,
    "throttle_policy": (
        "insert_zero_activity_cooling_tick_when_next_activity_quantum_would_"
        "exceed_thermal_ceiling"
    ),
    "resume_condition": (
        "predicted_temperature_after_next_activity_quantum <= thermal_ceiling"
    ),
    "ceiling_status_values": [
        "within_ceiling",
        "throttled",
        "ceiling_violation",
    ],
    "ceiling_violation_condition": (
        "maximum_benchmark_ticks_per_case_exhausted_before_semantic_completion"
    ),
}

EXPECTED_PRIMARY_METRICS = [
    "time_to_first_solution_ticks",
    "time_to_all_solutions_ticks",
    "solutions_completed",
    "steady_state_throughput",
    "throughput_retention_ratio",
    "latency_growth_ratio",
]

EXPECTED_SECONDARY_METRICS = [
    "heat_peak",
    "thermal_ceiling_status",
    "thermal_throttle_ticks",
    "total_normalized_energy",
    "semantic_completion_ratio",
    "semantic_output_match",
]

EXPECTED_FRP_INVARIANTS = {
    "actual_direct_events": 0,
    "reserved_state_events": 0,
    "queue_overflow_events": 0,
    "pending_route_count_final": 0,
    "transition_fraction": 0.25,
    "mandatory_routes": [
        "-1 -> 0 -> 1",
        "1 -> 0 -> -1",
    ],
    "tick_separated_neutral_route": True,
    "deterministic_seeded_execution": True,
}

EXPECTED_RANKING_ELIGIBILITY = {
    "require_semantic_completion_ratio": 1.0,
    "require_semantic_output_match": 1.0,
    "require_thermal_ceiling_status_not_equal": "ceiling_violation",
    "require_frp_invariants_for_frp": True,
}

EXPECTED_VALIDATION_CONTRACT = {
    "require_exact_architecture_order": True,
    "require_exact_domain_size_order": True,
    "require_exact_concurrent_domain_count_order": True,
    "require_exact_nonlinearity_class_order": True,
    "require_exact_case_count": 36,
    "require_same_workload_for_all_architectures": True,
    "require_same_initial_state_for_all_architectures": True,
    "require_same_initial_phase_for_all_architectures": True,
    "require_same_gamma_noise_target_for_all_architectures": True,
    "require_same_thermal_profile": True,
    "require_same_cost_profile_and_scenario": True,
    "require_same_thermal_ceiling": True,
    "require_same_activity_quantum": True,
    "require_same_resource_envelope_per_case": True,
    "require_frp_source_digest_binding": True,
    "require_deterministic_workload_digest": True,
    "winner_assertions": [],
}

EXPECTED_DIGEST_CONTRACT = {
    "algorithm": "sha256",
    "canonicalization": (
        "json.dumps(sort_keys=True,separators=(',',':'),ensure_ascii=False,"
        "allow_nan=False)"
    ),
    "excluded_field": "workload_profile_sha256",
}


class WorkloadValidationError(ValueError):
    """Raised when the nonlinear multitask workload violates its contract."""


def fail(message: str) -> NoReturn:
    raise WorkloadValidationError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def reject_nonfinite_constant(token: str) -> NoReturn:
    fail(f"non-finite JSON numeric constant is forbidden: {token}")


def require_exact(actual: Any, expected: Any, path: str) -> None:
    require(actual == expected, f"{path} mismatch")


def require_finite_numbers(value: Any, path: str = "profile") -> None:
    if isinstance(value, bool) or value is None or isinstance(value, str):
        return
    if isinstance(value, (int, float)):
        require(math.isfinite(float(value)), f"{path} must be finite")
        return
    if isinstance(value, list):
        for index, item in enumerate(value):
            require_finite_numbers(item, f"{path}[{index}]")
        return
    if isinstance(value, dict):
        for key, item in value.items():
            require_finite_numbers(item, f"{path}.{key}")
        return
    fail(f"{path} contains unsupported JSON value type")


def load_json_object(path: Path, label: str) -> dict[str, Any]:
    require(path.is_file(), f"{label} file not found: {path}")

    try:
        value = json.loads(
            path.read_text(encoding="utf-8"),
            parse_constant=reject_nonfinite_constant,
        )
    except WorkloadValidationError:
        raise
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"unable to load {label} JSON: {exc}")

    require(isinstance(value, dict), f"{label} root must be a JSON object")
    require_finite_numbers(value, label)

    return value


def sha256_file(path: Path) -> str:
    require(path.is_file(), f"bound file not found: {path}")

    digest = hashlib.sha256()

    try:
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
    except OSError as exc:
        fail(f"unable to hash bound file {path}: {exc}")

    return digest.hexdigest()


def canonical_profile_bytes(profile: Mapping[str, Any]) -> bytes:
    canonical = copy.deepcopy(dict(profile))

    require(
        "workload_profile_sha256" in canonical,
        "workload_profile_sha256 field missing",
    )

    canonical.pop("workload_profile_sha256")

    try:
        encoded = json.dumps(
            canonical,
            sort_keys=True,
            separators=(",", ":"),
            ensure_ascii=False,
            allow_nan=False,
        )
    except (TypeError, ValueError) as exc:
        fail(f"unable to canonicalize workload profile: {exc}")

    return encoded.encode("utf-8")


def compute_profile_digest(profile: Mapping[str, Any]) -> str:
    return hashlib.sha256(canonical_profile_bytes(profile)).hexdigest()


def refresh_profile_digest(profile: dict[str, Any]) -> None:
    profile["workload_profile_sha256"] = compute_profile_digest(profile)


def validate_repository_binding(
    repository_root: Path,
    relative_path: str,
    expected_sha256: str,
    label: str,
) -> Path:
    path = repository_root / relative_path
    actual_sha256 = sha256_file(path)

    require(
        actual_sha256 == expected_sha256,
        f"{label} SHA-256 mismatch: "
        f"expected {expected_sha256}, got {actual_sha256}",
    )

    return path


def validate_profile(
    profile: Mapping[str, Any],
    repository_root: Path | None,
) -> dict[str, Any]:
    require_exact(set(profile.keys()), EXPECTED_ROOT_FIELDS, "root fields")

    require_exact(profile["schema"], SCHEMA, "schema")
    require_exact(profile["suite_name"], SUITE_NAME, "suite_name")
    require_exact(profile["profile_name"], PROFILE_NAME, "profile_name")
    require_exact(profile["profile_role"], PROFILE_ROLE, "profile_role")
    require_exact(profile["profile_status"], PROFILE_STATUS, "profile_status")
    require_exact(
        profile["benchmark_question"],
        BENCHMARK_QUESTION,
        "benchmark_question",
    )
    require_exact(profile["seed"], SEED, "seed")
    require_exact(profile["case_count"], CASE_COUNT, "case_count")
    require_exact(
        profile["architecture_order"],
        ARCHITECTURE_ORDER,
        "architecture_order",
    )
    require_exact(
        profile["frp_reference"],
        EXPECTED_FRP_REFERENCE,
        "frp_reference",
    )

    require(
        profile["frp_reference"]["source_sha256"]
        != OBSOLETE_FRP_SOURCE_SHA256,
        "obsolete FRP source digest is forbidden",
    )

    require_exact(
        profile["execution_order"],
        EXECUTION_ORDER,
        "execution_order",
    )
    require_exact(
        profile["domain_size_order"],
        DOMAIN_SIZE_ORDER,
        "domain_size_order",
    )
    require_exact(
        profile["concurrent_domain_count_order"],
        CONCURRENT_DOMAIN_COUNT_ORDER,
        "concurrent_domain_count_order",
    )
    require_exact(
        profile["nonlinearity_class_order"],
        NONLINEARITY_CLASS_ORDER,
        "nonlinearity_class_order",
    )
    require_exact(
        profile["scheduler_mode"],
        "free",
        "scheduler_mode",
    )
    require_exact(
        profile["transition_fraction"],
        0.25,
        "transition_fraction",
    )
    require_exact(
        profile["auto_targets_enable"],
        True,
        "auto_targets_enable",
    )

    require_exact(
        profile["shared_problem_model"],
        EXPECTED_SHARED_PROBLEM_MODEL,
        "shared_problem_model",
    )
    require_exact(
        profile["deterministic_initialization"],
        EXPECTED_DETERMINISTIC_INITIALIZATION,
        "deterministic_initialization",
    )
    require_exact(
        profile["nonlinearity_classes"],
        EXPECTED_NONLINEARITY_CLASSES,
        "nonlinearity_classes",
    )
    require_exact(
        profile["resource_fairness_contract"],
        EXPECTED_RESOURCE_FAIRNESS,
        "resource_fairness_contract",
    )
    require_exact(
        profile["convergence_contract"],
        EXPECTED_CONVERGENCE_CONTRACT,
        "convergence_contract",
    )
    require_exact(
        profile["thermal_ceiling_contract"],
        EXPECTED_THERMAL_CEILING_CONTRACT,
        "thermal_ceiling_contract",
    )
    require_exact(
        profile["primary_metrics"],
        EXPECTED_PRIMARY_METRICS,
        "primary_metrics",
    )
    require_exact(
        profile["secondary_metrics"],
        EXPECTED_SECONDARY_METRICS,
        "secondary_metrics",
    )
    require_exact(
        profile["frp_invariant_contract"],
        EXPECTED_FRP_INVARIANTS,
        "frp_invariant_contract",
    )
    require_exact(
        profile["ranking_eligibility_contract"],
        EXPECTED_RANKING_ELIGIBILITY,
        "ranking_eligibility_contract",
    )
    require_exact(
        profile["validation_contract"],
        EXPECTED_VALIDATION_CONTRACT,
        "validation_contract",
    )
    require_exact(
        profile["digest_contract"],
        EXPECTED_DIGEST_CONTRACT,
        "digest_contract",
    )

    cases = list(
        itertools.product(
            profile["domain_size_order"],
            profile["concurrent_domain_count_order"],
            profile["nonlinearity_class_order"],
        )
    )

    require(
        len(cases) == CASE_COUNT,
        "derived case count mismatch",
    )
    require(
        len(set(cases)) == CASE_COUNT,
        "derived case matrix contains duplicates",
    )

    require(
        profile["validation_contract"]["winner_assertions"] == [],
        "winner_assertions must be empty",
    )
    require(
        profile["shared_problem_model"]["cross_domain_coupling_gain"] == 0.0,
        "cross_domain_coupling_gain must remain 0.0",
    )
    require(
        profile["shared_problem_model"]["domain_independence"] is True,
        "domain_independence must remain true",
    )
    require(
        profile["convergence_contract"][
            "semantic_completion_ratio_required"
        ]
        == 1.0,
        "semantic completion requirement must remain 1.0",
    )
    require(
        profile["convergence_contract"]["semantic_output_match_required"]
        == 1.0,
        "semantic output-match requirement must remain 1.0",
    )

    declared_digest = profile["workload_profile_sha256"]

    require(
        isinstance(declared_digest, str) and len(declared_digest) == 64,
        "workload_profile_sha256 must be a 64-character hexadecimal string",
    )

    try:
        int(declared_digest, 16)
    except ValueError:
        fail("workload_profile_sha256 must be hexadecimal")

    computed_digest = compute_profile_digest(profile)

    require(
        declared_digest == computed_digest,
        "workload_profile_sha256 mismatch: "
        f"expected {computed_digest}, got {declared_digest}",
    )

    if repository_root is not None:
        source_path = validate_repository_binding(
            repository_root,
            FRP_SOURCE_PATH,
            FRP_SOURCE_SHA256,
            "FRP source",
        )
        thermal_path = validate_repository_binding(
            repository_root,
            THERMAL_PROFILE_PATH,
            THERMAL_PROFILE_FILE_SHA256,
            "thermal profile file",
        )
        cost_path = validate_repository_binding(
            repository_root,
            COST_PROFILE_PATH,
            COST_PROFILE_FILE_SHA256,
            "cost profile file",
        )

        thermal_profile = load_json_object(
            thermal_path,
            "thermal profile",
        )

        require_exact(
            thermal_profile.get("profile_name"),
            THERMAL_PROFILE_NAME,
            "thermal profile name",
        )
        require_exact(
            thermal_profile.get("temperature_unit"),
            "normalized_temperature_proxy",
            "thermal profile temperature_unit",
        )
        require_exact(
            thermal_profile.get("ambient_temperature_proxy"),
            0.0,
            "thermal profile ambient_temperature_proxy",
        )
        require_exact(
            thermal_profile.get("thermal_decay"),
            0.95,
            "thermal profile thermal_decay",
        )
        require_exact(
            thermal_profile.get("thermal_gain"),
            0.01,
            "thermal profile thermal_gain",
        )

        cost_profile = load_json_object(
            cost_path,
            "cost profile",
        )

        require_exact(
            cost_profile.get("profile_name"),
            COST_PROFILE_NAME,
            "cost profile name",
        )

        require(
            "nominal" in cost_profile.get("scenario_vectors", {}),
            "cost profile nominal scenario missing",
        )

        repository_bindings = {
            "frp_source": str(
                source_path.relative_to(repository_root)
            ),
            "thermal_profile": str(
                thermal_path.relative_to(repository_root)
            ),
            "cost_profile": str(
                cost_path.relative_to(repository_root)
            ),
        }
    else:
        repository_bindings = {
            "frp_source": FRP_SOURCE_PATH,
            "thermal_profile": THERMAL_PROFILE_PATH,
            "cost_profile": COST_PROFILE_PATH,
        }

    return {
        "status": "PASS",
        "schema": SCHEMA,
        "profile_name": PROFILE_NAME,
        "seed": SEED,
        "case_count": CASE_COUNT,
        "case_matrix": {
            "domain_sizes": DOMAIN_SIZE_ORDER,
            "concurrent_domain_counts": CONCURRENT_DOMAIN_COUNT_ORDER,
            "nonlinearity_classes": NONLINEARITY_CLASS_ORDER,
        },
        "thermal_ceiling": EXPECTED_THERMAL_CEILING_CONTRACT[
            "thermal_ceiling"
        ],
        "activity_quantum": EXPECTED_THERMAL_CEILING_CONTRACT[
            "normalized_activity_quantum_per_benchmark_tick"
        ],
        "cost_scenario": "nominal",
        "winner_assertions": [],
        "workload_profile_sha256": declared_digest,
        "repository_bindings": repository_bindings,
    }


def expect_validation_failure(
    name: str,
    profile: Mapping[str, Any],
    repository_root: Path | None,
    expected_fragment: str,
) -> str:
    try:
        validate_profile(
            profile,
            repository_root=repository_root,
        )
    except WorkloadValidationError as exc:
        require(
            expected_fragment in str(exc),
            f"self-test {name} failed with unexpected error: {exc}",
        )
        return name

    fail(f"self-test {name} did not fail")


def run_self_test(
    profile: Mapping[str, Any],
    repository_root: Path | None,
) -> dict[str, Any]:
    validate_profile(
        profile,
        repository_root=repository_root,
    )

    completed: list[str] = []

    bad_architecture_order = copy.deepcopy(dict(profile))
    bad_architecture_order["architecture_order"] = list(
        reversed(ARCHITECTURE_ORDER)
    )
    refresh_profile_digest(bad_architecture_order)

    completed.append(
        expect_validation_failure(
            "reject_architecture_order_change",
            bad_architecture_order,
            repository_root,
            "architecture_order mismatch",
        )
    )

    bad_case_count = copy.deepcopy(dict(profile))
    bad_case_count["case_count"] = 35
    refresh_profile_digest(bad_case_count)

    completed.append(
        expect_validation_failure(
            "reject_case_count_change",
            bad_case_count,
            repository_root,
            "case_count mismatch",
        )
    )

    bad_thermal_ceiling = copy.deepcopy(dict(profile))
    bad_thermal_ceiling["thermal_ceiling_contract"][
        "thermal_ceiling"
    ] = 1.1
    refresh_profile_digest(bad_thermal_ceiling)

    completed.append(
        expect_validation_failure(
            "reject_thermal_ceiling_change",
            bad_thermal_ceiling,
            repository_root,
            "thermal_ceiling_contract mismatch",
        )
    )

    bad_winner_assertion = copy.deepcopy(dict(profile))
    bad_winner_assertion["validation_contract"][
        "winner_assertions"
    ] = [
        "FRP must be faster"
    ]
    refresh_profile_digest(bad_winner_assertion)

    completed.append(
        expect_validation_failure(
            "reject_winner_assertion",
            bad_winner_assertion,
            repository_root,
            "validation_contract mismatch",
        )
    )

    bad_source_digest = copy.deepcopy(dict(profile))
    bad_source_digest["frp_reference"][
        "source_sha256"
    ] = OBSOLETE_FRP_SOURCE_SHA256
    refresh_profile_digest(bad_source_digest)

    completed.append(
        expect_validation_failure(
            "reject_obsolete_frp_source_digest",
            bad_source_digest,
            repository_root,
            "frp_reference mismatch",
        )
    )

    bad_profile_binding = copy.deepcopy(dict(profile))
    bad_profile_binding["thermal_ceiling_contract"][
        "cost_profile_sha256"
    ] = "0" * 64
    refresh_profile_digest(bad_profile_binding)

    completed.append(
        expect_validation_failure(
            "reject_cost_profile_digest_change",
            bad_profile_binding,
            repository_root,
            "thermal_ceiling_contract mismatch",
        )
    )

    bad_workload_digest = copy.deepcopy(dict(profile))
    bad_workload_digest["workload_profile_sha256"] = "0" * 64

    completed.append(
        expect_validation_failure(
            "reject_workload_digest_mismatch",
            bad_workload_digest,
            repository_root,
            "workload_profile_sha256 mismatch",
        )
    )

    return {
        "status": "PASS",
        "self_test_count": len(completed),
        "self_tests": completed,
    }


def format_text(result: Mapping[str, Any]) -> str:
    if "self_tests" in result:
        lines = [
            "nonlinear multitask workload validator self-test: PASS",
            f"self_test_count={result['self_test_count']}",
        ]

        lines.extend(
            f"PASS {name}"
            for name in result["self_tests"]
        )

        return "\n".join(lines)

    matrix = result["case_matrix"]

    return "\n".join(
        [
            "nonlinear multitask workload validation: PASS",
            f"schema={result['schema']}",
            f"profile_name={result['profile_name']}",
            f"seed={result['seed']}",
            f"case_count={result['case_count']}",
            "domain_sizes="
            + ",".join(
                str(value)
                for value in matrix["domain_sizes"]
            ),
            "concurrent_domain_counts="
            + ",".join(
                str(value)
                for value in matrix[
                    "concurrent_domain_counts"
                ]
            ),
            "nonlinearity_classes="
            + ",".join(
                matrix["nonlinearity_classes"]
            ),
            f"thermal_ceiling={result['thermal_ceiling']}",
            f"activity_quantum={result['activity_quantum']}",
            f"cost_scenario={result['cost_scenario']}",
            "workload_profile_sha256="
            f"{result['workload_profile_sha256']}",
            "winner_assertions=[]",
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    script_dir = Path(__file__).resolve().parent

    default_profile = (
        script_dir
        / "workloads"
        / "nonlinear_multitask_workload_v1.json"
    )

    parser = argparse.ArgumentParser(
        description=(
            "Validate the FRP nonlinear multitask "
            "workload profile v1."
        )
    )

    parser.add_argument(
        "--profile",
        default=str(default_profile),
        help="Path to nonlinear_multitask_workload_v1.json",
    )

    parser.add_argument(
        "--self-test",
        action="store_true",
        help=(
            "Run positive and negative validator "
            "contract tests."
        ),
    )

    parser.add_argument(
        "--output",
        choices=("text", "json"),
        default="text",
        help="Output format.",
    )

    parser.add_argument(
        "--skip-repository-path-checks",
        action="store_true",
        help=(
            "Skip repository file existence and "
            "SHA-256 binding checks."
        ),
    )

    return parser


def main(
    argv: Sequence[str] | None = None,
) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    profile_path = (
        Path(args.profile)
        .expanduser()
        .resolve()
    )

    script_dir = Path(__file__).resolve().parent

    repository_root = (
        None
        if args.skip_repository_path_checks
        else script_dir.parents[1]
    )

    try:
        profile = load_json_object(
            profile_path,
            "workload profile",
        )

        if args.self_test:
            result = run_self_test(
                profile,
                repository_root=repository_root,
            )
        else:
            result = validate_profile(
                profile,
                repository_root=repository_root,
            )

    except WorkloadValidationError as exc:
        if args.output == "json":
            print(
                json.dumps(
                    {
                        "status": "FAIL",
                        "error": str(exc),
                    },
                    ensure_ascii=False,
                    sort_keys=True,
                    indent=2,
                )
            )
        else:
            print(
                "nonlinear multitask workload "
                "validation: FAIL\n"
                f"error={exc}"
            )

        return 1

    if args.output == "json":
        print(
            json.dumps(
                result,
                ensure_ascii=False,
                sort_keys=True,
                indent=2,
            )
        )
    else:
        print(format_text(result))

    return 0


if __name__ == "__main__":
    sys.exit(main())
